# Retail POS for Business Central

A point-of-sale register for Business Central, written in AL. The screen is plain JavaScript/CSS inside a control add-in. All data and rules stay in Business Central.

Target: BC 25+ (runtime 14), object IDs 50200-50249. If you use an older version, change `platform`/`application`/`runtime` in `app.json`. Versions before BC 24 also need the number series call in `POSReceiptHeader.Table.al` changed to `NoSeriesManagement`.

## How it works

```
JavaScript screen  --ActionRequested(action, json)-->  Page "POS Register" (50200)
                                                          |  Commit(); Codeunit.Run
                                                          v
                                                 Codeunit "POS Action Handler" (50202)
                                                          |
                          POS Management (50200)  ·  POS Json Builder (50201)  ·  POS Post Receipt (50203)
                                                          |
JavaScript screen  <--Apply(json): receipt, products, ----+
                      customers, held list, message
```

- The receipt is saved in `POS Receipt Header/Line/Payment` after every click, so hold, recall and a browser refresh never lose a sale.
- Each action runs with `Codeunit.Run`. If it fails (for example a posting error), everything it wrote is rolled back and the error text is shown in the screen.
- **Checkout** (`POS Post Receipt`, one transaction):
  1. Creates a standard **sales invoice** for the receipt customer and posts it. Inventory, G/L, VAT and customer ledger entries are standard.
  2. Posts one **customer payment** per tender, applied to that invoice, against the G/L or bank account of the payment method.
  3. Marks the receipt Posted and stores the invoice number.

## Role center

Profile **POS Manager** (role center page 50209). Pick it in *My Settings > Role Center*.

**Cashier role center:** profile **POS Cashier** (role center page 50217) contains only the register screen (page part 50216), with no other menu, list or setup in front of the cashier. Assign the profile to cashier users in *Users > Profile* or *My Settings*. The register inside a role center is sized by the control add-in (780 px high); if it feels cramped on a small screen, use the *Full Screen Register* action, which opens the same register as a page. Untested inside Business Central, like the rest of the AL code.

- **Cues:** receipts and sales today, cancelled today; cash / card / other payments today; sales in progress at registers and sales on hold. Each cue drills down to the matching list.
- **Recent Sales:** the latest completed receipts. Choose the number to open the receipt, which shows lines, payments and a link to the posted invoice.
- **Navigation:** New Sale, Receipts (all, completed, on hold), Items Sold, Payments, Customers, Items, Item Categories, Posted Sales Invoices, Customer / Item Ledger Entries, Bank Accounts, Chart of Accounts, POS Setup, Payment Methods, Locations, No. Series.
- "Today" means the work date. Cues cover all cashiers.

## Themes

The register screen is colored entirely by a **theme**: eight colors (accent, text on accent, screen background, panels, main text, secondary text, borders, warnings). Three ship with the app and are created on install: **Teal (light)**, **Midnight (dark)** and **Sunset (warm)**.

- **POS Themes** (list) and **POS Theme Card**: create a theme, pick colors with color pickers next to a live miniature of the register, or type hex values. A readability check flags color pairs that are hard to read. New themes start with the Teal colors. Page actions: *Use for Me*, *Use as Default Theme*, *Create Default Themes* (restores the shipped three).
- **POS Setup > Default Theme Code**: what cashiers start with.
- **On the register**: the *Theme* button on the top bar switches theme instantly; the choice is stored per user (table *POS User Setup*).
- Dark or light mode is detected from the background color. Invalid colors fall back to the defaults, so a theme can never make the screen unreadable.
- `preview/theme-editor.html` shows the editor in a browser without Business Central.

## Stores and terminals

Objects: **POS Store** (table 50210, page 50219 *POS Store List*), **POS Terminal** (table 50209, page 50218 *POS Terminal List*) and *Custom POS Hardware Profile* (table 50211, not used yet).

How they are used:

| Where | What happens |
|---|---|
| Login screen | Asks for the terminal (active terminals only, grouped by store; the last one used on the device is preselected). If no terminal exists yet the login works as before. |
| POS User | New field **Store No.**. A user with a store can only sign in to terminals of that store; blank = every store. |
| Terminal | *Status* must be Active, *Manager Privileges Required* = administrators only, *Auto Logoff After (Min.)* overrides POS Setup, *Receipt No. Series* overrides POS Setup, *Location Code* overrides the store location. |
| Store | *Location Code* (stock location of the sale and of the stock shown on the tiles), *Default Customer No.* (overrides POS Setup), *Global Dimension 1/2* (set on the sales invoice and the customer payments), name/address/phone/tax no. printed on the receipt, *Active*. |
| Receipts and payments | Stamped with **Store No.** and **POS No.** when created. Receipt lists, items sold, payments and recent sales show both. |
| Held sales | Limited to the store you are signed in to (plus sales held before stores existed). A sale held at one terminal can be recalled at another terminal of the same store. |
| Current sale | One open sale per cashier **and terminal**. |
| Role center | Store filter above the cues, *Sales by Store* and *Sales by Terminal* (the two lists show today's receipts and sales). |

A store or terminal that receipts refer to cannot be deleted; set it to inactive instead.

## Receipt pictures

In **POS Setup**, group *Receipt Pictures*, choose a **header picture** (for example the logo) and a **footer picture** (for example a promotion) with the actions *Import Header Picture* / *Import Footer Picture* (PNG, JPG, GIF or BMP, up to 500 KB each; *Remove ...* clears them). They are printed at the top and bottom of every receipt, on the receipt preview and on the printout. With no picture chosen nothing changes. The register receives the pictures once, when it opens, so a changed picture shows after the register is reopened.

## Login and users

The register opens on a **login screen**. Nothing of the sale is loaded until a user signs in.

- Table **POS User** (50208) has only three fields: **User Name**, **Password**, **Is Admin**. Manage users in **POS Users** (list 50214, card 50215), reachable from POS Setup, the register menu and the role center.
- **Create the first administrator in Business Central** (POS Users > New: user name, Is Admin on, password, *Set Password*). There is deliberately no way to create users from the login screen. Users without a password cannot sign in.
- The password is never stored: the field holds `salt$hash` (random salt, PBKDF2-SHA256 through the System Application codeunit *Rfc2898DeriveBytes*). Minimum length is 4 characters.
- The signed-in user lives in server memory (single-instance codeunit *POS Session*), not in the browser. Every register action except login checks it, so a modified page cannot skip the login.
- After 5 wrong passwords the login is blocked for 30 seconds; each failed attempt is also delayed by 0.7 s.
- **Administrators** can give line discounts, delete a line (including setting its quantity to 0), cancel (void) a sale and discard held receipts, and they see the held sales of **all** cashiers (the Held list shows who parked each one). An administrator can **recall** another cashier's held sale, take it over and, for example, give a discount on it; the receipt then belongs to the administrator and keeps the original cashier in *Taken Over From*. Cashiers can only recall their own. For other users those buttons are hidden, the minus button stops at quantity 1, and the server refuses the actions anyway.
- The user name is stored as *Cashier ID* on receipts, and each user keeps their own theme and their own held receipts.
- **Sign out** in the top bar, or automatically after *Auto Sign-out (minutes)* without activity (POS Setup, default 15, 0 = off). The open sale stays saved and returns at the next login. Auto sign-out waits while the payment window is open.
- At least one administrator must always exist; user names cannot be renamed (receipts refer to them).
- `preview/index.html` has two test users: `admin` / `admin123` and `anna` / `anna1234` (`?idle=0.1` for a 6-second auto sign-out, `?nousers` for the empty case).

## What the register does

Barcode scan (Enter), `3*barcode` for quantity, item search, category chips, tap-to-add tiles with stock badges, quantity keypad, line discount (capped by setup), customer change, hold / recall / discard, split payments (cash, card, other), change calculation, receipt preview and print, reprint last receipt, cancel sale (kept as Voided, administrators only).
Colors follow the selected theme (see Themes).
Keys: F2 search, F4 pay, F8 hold, F9 customer, Esc close.

## Setup

1. Publish the extension (F5 in VS Code) and give users the permission set **POS - ALL**. Users who sell also need normal sales posting rights.
2. Open **POS Setup**: default customer (a cash customer with immediate payment terms), location, and a receipt number series.
3. Open **POS Payment Methods**: create e.g. `CASH` (type Cash, G/L or bank account of the till) and `CARD` (type Card, bank account). Quick amounts such as `50,100,200` become buttons.
4. Make sure items have a VAT product posting group, and the default customer a VAT business posting group.
5. Open **POS Users** and create at least one administrator with a password.
6. Search for **POS Register**, open it and sign in.

`preview/index.html` opens the same screen in any browser with fake data (not part of the app).

## Known limits / next steps

- Prices come from `Item."Unit Price"` (excl. VAT). Plug in price lists or campaigns through the event `OnAfterGetUnitPrice` in `POS Management`.
- Local currency only. Posting date is the work date.
- No refunds or returns yet (a credit memo flow would be the next addition), no shift / cash-up, no serial or lot tracking, no dimensions.
- If the VAT on the posted invoice ever differs from the receipt total, the sale is rejected and rolled back with an explanatory message.
- This login is separate from Business Central's own users: anyone with the permission set can open the register page, and then needs a POS user. Passwords are managed by administrators; there is no self-service password change or password expiry.
- Printing uses the browser print dialog from inside the add-in. For thermal printers a Report-based receipt is the more robust option.
