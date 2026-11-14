/*
 * Retail POS - register screen for the "POS Control" add-in.
 *
 * The screen holds no business data of its own. Every click is sent to AL as
 *   ActionRequested(action, jsonPayload)
 * and AL answers with Apply(json): the current receipt plus whatever else changed.
 * Because the receipt lives in Business Central tables, hold / recall / reload never lose a sale.
 */
(function () {
  'use strict';

  // ---------------------------------------------------------------- state
  var S = {
    cfg: {
      companyName: '', footer: '', headerPicture: '', footerPicture: '', startFullScreen: false, currency: '', maxDiscount: 0, precision: 0.01, idleMinutes: 0,
      paymentMethods: [], categories: [], setupIssues: []
    },
    session: { loggedIn: false, userName: '', isAdmin: false, hasUsers: true, terminal: null, terminals: [], idleMinutes: null },
    idleTimer: null,
    lastActivity: 0,
    receipt: null,
    products: [],
    customers: [],
    held: [],
    heldCount: 0,
    category: '',
    busy: false,
    queue: [],
    busyTimer: null,
    modal: null,       // { type, ... }
    pay: null,         // { list: [{method, amount}], buf: '' }
    prevQty: {},
    searchTimer: null,
    custTimer: null
  };

  var root;

  // -------------------------------------------------------------- helpers
  function esc(v) {
    return String(v === null || v === undefined ? '' : v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function round2(n) { return Math.round((n + Number.EPSILON) * 100) / 100; }

  function money(n) {
    return round2(Number(n) || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  function qtyText(n) {
    n = Number(n) || 0;
    return (Math.round(n * 100000) / 100000).toLocaleString(undefined, { maximumFractionDigits: 5 });
  }

  function hue(text) {
    var h = 0, i;
    for (i = 0; i < text.length; i++) { h = (h * 31 + text.charCodeAt(i)) % 360; }
    return h;
  }

  function initials(text) {
    var parts = String(text || '?').trim().split(/\s+/);
    var s = parts[0].charAt(0) + (parts.length > 1 ? parts[1].charAt(0) : (parts[0].charAt(1) || ''));
    return s.toUpperCase();
  }

  function $(sel) { return root.querySelector(sel); }

  function invoke(name, args) {
    try {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(name, args);
    } catch (e) {
      setBusy(false);
      toast('error', 'Cannot reach Business Central: ' + e.message);
    }
  }

  // ------------------------------------------------- talking to Business Central
  function send(action, payload) {
    S.queue.push({ a: action, p: payload || {} });
    pump();
  }

  function pump() {
    if (S.busy || !S.queue.length) { return; }
    var job = S.queue.shift();
    setBusy(true);
    invoke('ActionRequested', [job.a, JSON.stringify(job.p)]);
  }

  function setBusy(on) {
    S.busy = on;
    clearTimeout(S.busyTimer);
    var bar = $('#busybar');
    if (bar) { bar.classList.toggle('on', on); }
    root.classList.toggle('is-busy', on);
    if (on) {
      // Safety net: never leave the screen locked if an answer gets lost.
      S.busyTimer = setTimeout(function () {
        S.busy = false; S.queue = [];
        root.classList.remove('is-busy');
        if (bar) { bar.classList.remove('on'); }
        toast('error', 'Business Central did not answer. Check the receipt before continuing.');
        renderModal();
      }, 90000);
    }
    if (S.modal && S.modal.type === 'payment') { renderPaymentState(); }
  }

  // ----------------------------------------------------------- full screen
  // Two levels, both optional because they reach into the page around the add-in (Business Central offers no API for it):
  //  - screen: the browser's own full screen for the register's frame, so the tabs and address bar disappear as well (like F11);
  //  - window: the frame is lifted over the whole Business Central window. Used when the browser refuses the first one,
  //    which it does without a click or key press, so it is what "Start Full Screen" uses until the first interaction.
  // If the page cannot be reached the button is not shown and the register stays where it is.
  var full = { window: false, screen: false, saved: [], auto: false, armed: false };

  function pageFrame() {
    try { return window.frameElement || null; } catch (e) { return null; }
  }

  function canFull() {
    var f = pageFrame();
    try { return !!(f && f.ownerDocument && f.ownerDocument.defaultView); } catch (e) { return false; }
  }

  function isFull() { return full.window || full.screen; }

  function force(el, props) {
    full.saved.push({ el: el, css: el.style.cssText });
    Object.keys(props).forEach(function (k) { el.style.setProperty(k, props[k], 'important'); });
  }

  function enterWindow() {
    if (full.window || !canFull()) { return; }
    var f = pageFrame(), doc = f.ownerDocument, win = doc.defaultView;
    // Anything that makes a containing block or a stacking context would trap a fixed frame, so it is relaxed on every parent.
    for (var el = f.parentElement; el && el !== doc.documentElement; el = el.parentElement) {
      var cs = win.getComputedStyle(el), p = {};
      if (cs.transform !== 'none') { p.transform = 'none'; }
      if (cs.filter !== 'none') { p.filter = 'none'; }
      if (cs.perspective !== 'none') { p.perspective = 'none'; }
      if (cs.contain !== 'none') { p.contain = 'none'; }
      if (cs.willChange !== 'auto') { p['will-change'] = 'auto'; }
      if (cs.overflow !== 'visible') { p.overflow = 'visible'; }
      if (cs.position !== 'static') { p['z-index'] = '2147483000'; }
      if (Object.keys(p).length) { force(el, p); }
    }
    force(f, {
      position: 'fixed', top: '0', left: '0', right: '0', bottom: '0', width: '100vw', height: '100vh',
      'max-width': 'none', 'max-height': 'none', margin: '0', border: '0', 'z-index': '2147483001', background: '#fff'
    });
    full.window = true;
  }

  function leaveWindow() {
    for (var i = full.saved.length - 1; i >= 0; i--) {
      try { full.saved[i].el.style.cssText = full.saved[i].css; } catch (e) { /* element is gone */ }
    }
    full.saved = [];
    full.window = false;
  }

  // The browser's full screen for the frame. Resolves true when it is on.
  function enterScreen() {
    var f = pageFrame();
    if (!f) { return Promise.resolve(false); }
    var req = f.requestFullscreen || f.webkitRequestFullscreen;
    if (!req) { return Promise.resolve(false); }
    try {
      var r = req.call(f);
      return Promise.resolve(r).then(function () { full.screen = true; return true; }, function () { return false; });
    } catch (e) { return Promise.resolve(false); }
  }

  function leaveScreen() {
    full.screen = false;
    try {
      var d = pageFrame().ownerDocument;
      var el = d.fullscreenElement || d.webkitFullscreenElement;
      if (el === pageFrame()) { (d.exitFullscreen || d.webkitExitFullscreen).call(d); }
    } catch (e) { /* already gone */ }
  }

  // Esc or F11 in the browser ends the browser's full screen; then the whole mode ends, as a cashier expects.
  function onFullscreenChange() {
    if (!full.screen) { return; }
    try {
      var d = pageFrame().ownerDocument;
      if ((d.fullscreenElement || d.webkitFullscreenElement) !== pageFrame()) { leaveFull(); }
    } catch (e) { leaveFull(); }
  }

  // Called by the button (a click is the user gesture browsers require) and, for Start Full Screen, once at start.
  function enterFull(viaGesture) {
    if (isFull() || !canFull()) { return; }
    if (viaGesture) {
      enterScreen().then(function (ok) {
        if (!ok) { enterWindow(); }
        syncFullButton();
      });
    } else {
      enterWindow();
      armScreenUpgrade();
      syncFullButton();
    }
  }

  // After an automatic start no gesture exists yet; the first click or Enter key (for example signing in) switches on the browser's full screen too.
  function armScreenUpgrade() {
    if (full.armed) { return; }
    full.armed = true;
    var go = function (e) {
      if (e.type === 'keydown' && e.key !== 'Enter') { return; }
      document.removeEventListener('pointerdown', go, true);
      document.removeEventListener('keydown', go, true);
      if (full.window && !full.screen) { enterScreen().then(syncFullButton); }
    };
    document.addEventListener('pointerdown', go, true);
    document.addEventListener('keydown', go, true);
  }

  function leaveFull() {
    if (full.screen) { leaveScreen(); }
    if (full.window) { leaveWindow(); }
    syncFullButton();
  }

  function toggleFull() { if (isFull()) { leaveFull(); } else { enterFull(true); } }

  function syncFullButton() {
    var b = $('#fullBtn');
    if (b) { b.textContent = isFull() ? 'Exit full screen' : 'Full screen'; }
  }

  // ------------------------------------------------------------------ API
  function start() {
    root = document.getElementById('controlAddIn');
    root.innerHTML = skeleton();
    root.addEventListener('click', onClick);
    document.addEventListener('keydown', onKey, true);
    // Leaving the page removes this frame; give back the page's styles first so Business Central's own layout is untouched.
    window.addEventListener('pagehide', leaveFull);
    try {
      pageFrame().ownerDocument.addEventListener('fullscreenchange', onFullscreenChange);
      pageFrame().ownerDocument.addEventListener('webkitfullscreenchange', onFullscreenChange);
    } catch (e) { /* no page access */ }
    $('#fullBtn').hidden = !canFull();

    var scan = $('#scan');
    scan.addEventListener('input', function () {
      clearTimeout(S.searchTimer);
      S.searchTimer = setTimeout(function () {
        send('search-products', { text: scan.value, category: S.category });
      }, 300);
    });
    scan.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        clearTimeout(S.searchTimer);
        var code = scan.value.trim();
        scan.value = '';
        if (code) { send('scan', { code: code }); }
      } else if (e.key === 'Escape') {
        scan.value = '';
        send('search-products', { text: '', category: S.category });
      }
    });

    var form = $('#login-form');
    form.addEventListener('submit', function (e) { e.preventDefault(); submitLogin(); });
    ['mousedown', 'keydown', 'touchstart', 'wheel'].forEach(function (name) {
      document.addEventListener(name, noteActivity, true);
    });

    renderAll();
    renderSession();
    invoke('ControlReady', []);
  }

  // ------------------------------------------------------------------ session
  function submitLogin() {
    var user = $('#login-user'), pass = $('#login-pass'), term = $('#login-terminal');
    if (S.busy) { return; }
    setLoginError('');
    var terminalNo = term && !term.closest('.login-row').hidden ? term.value : '';
    if (terminalNo) { rememberTerminal(terminalNo); }
    send('login', { userName: user.value.trim(), password: pass.value, terminalNo: terminalNo });
    pass.value = '';   // the password is never kept in the page after it was sent
  }

  // The terminal last used on this device is preselected on the login screen. Storage can be blocked, so it is optional.
  function rememberTerminal(no) {
    S.lastTerminal = no;
    try { localStorage.setItem('pos.terminal', no); } catch (e) { /* ignore */ }
  }

  function lastTerminal() {
    if (S.lastTerminal) { return S.lastTerminal; }
    try { return localStorage.getItem('pos.terminal') || ''; } catch (e) { return ''; }
  }

  function renderTerminalPicker() {
    var sel = $('#login-terminal');
    if (!sel) { return; }
    var list = S.session.terminals || [];
    var row = sel.closest('.login-row');
    // No terminals defined at all: the register works without one.
    row.hidden = !list.length;
    var keep = sel.value || lastTerminal();
    var groups = {}, order = [];
    list.forEach(function (t) {
      if (!groups[t.storeNo]) { groups[t.storeNo] = { name: t.storeName || t.storeNo, items: [] }; order.push(t.storeNo); }
      groups[t.storeNo].items.push(t);
    });
    sel.innerHTML = order.map(function (no) {
      return '<optgroup label="' + esc(groups[no].name) + '">' + groups[no].items.map(function (t) {
        return '<option value="' + esc(t.no) + '">' + esc(t.no) + (t.description ? ' - ' + esc(t.description) : '') + '</option>';
      }).join('') + '</optgroup>';
    }).join('');
    var found = list.some(function (t) { return t.no === keep; });
    sel.value = found ? keep : (list.length ? list[0].no : '');
  }

  function setLoginError(text) {
    var el = $('#login-error');
    if (!el) { return; }
    el.textContent = text || '';
    el.hidden = !text;
  }

  function resetForLogout() {
    S.receipt = null; S.products = []; S.customers = []; S.held = []; S.heldCount = 0;
    S.category = ''; S.modal = null; S.pay = null; S.prevQty = {}; S.queue = [];
    var host = $('#modal-host'); if (host) { host.innerHTML = ''; }
    var scan = $('#scan'); if (scan) { scan.value = ''; }
    renderAll();
  }

  function applySession(se) {
    var was = S.session.loggedIn;
    S.session = {
      loggedIn: !!se.loggedIn, userName: se.userName || '', isAdmin: !!se.isAdmin,
      hasUsers: se.hasUsers !== false, terminal: se.terminal || null,
      terminals: se.terminals || [],
      idleMinutes: typeof se.idleMinutes === 'number' ? se.idleMinutes : null
    };
    if (se.themeCode && se.themeCode !== S.cfg.themeCode) { S.cfg.themeCode = se.themeCode; applyTheme(); }
    if (was && !S.session.loggedIn) { resetForLogout(); }
    renderSession();
    if (!S.session.loggedIn) {
      var noTerminal = S.cfg.hasTerminals && !S.session.terminals.length
        ? 'No terminal is active. Ask an administrator to activate one in POS Terminals.' : '';
      setLoginError(se.error || (S.session.hasUsers ? noTerminal : 'No users exist yet. Ask an administrator to create users in POS Users.'));
      var user = $('#login-user'), pass = $('#login-pass');
      if (user && pass) { (user.value ? pass : user).focus(); }
    } else {
      setLoginError('');
    }
    scheduleIdle();
  }

  function renderSession() {
    if (!root) { return; }
    var p = $('.pos');
    p.classList.toggle('is-admin', S.session.isAdmin);
    p.classList.toggle('logged-out', !S.session.loggedIn);
    $('#login').hidden = S.session.loggedIn;
    $('#login-company').textContent = S.cfg.companyName || 'Point of Sale';
    if (!S.session.loggedIn) { renderTerminalPicker(); }
    $('#logoutBtn').hidden = !S.session.loggedIn;
    renderTopbar();
  }

  function noteActivity() {
    var now = Date.now();
    if (now - S.lastActivity > 1000) { S.lastActivity = now; scheduleIdle(); }
  }

  function scheduleIdle() {
    clearTimeout(S.idleTimer);
    // The terminal can have its own auto sign-out time; the server sends the one that applies.
    var minutes = Number(S.session.idleMinutes !== null ? S.session.idleMinutes : S.cfg.idleMinutes) || 0;
    if (!S.session.loggedIn || minutes <= 0) { return; }
    S.idleTimer = setTimeout(function () {
      if (!S.session.loggedIn) { return; }
      // Never sign out in the middle of taking payment or while a request is running.
      if (S.busy || (S.modal && S.modal.type === 'payment')) { scheduleIdle(); return; }
      send('logout');
    }, minutes * 60000);
  }

  function initialize(json) {
    try { S.cfg = Object.assign(S.cfg, JSON.parse(json)); } catch (e) { toast('error', 'Configuration could not be read.'); }
    applyTheme();
    renderAll();
    renderSession();
    $('#fullBtn').hidden = !canFull();
    if (S.cfg.startFullScreen && !full.auto) { full.auto = true; enterFull(false); }
    focusScan();
  }

  function apply(json) {
    var r;
    try { r = JSON.parse(json); } catch (e) {
      setBusy(false);
      toast('error', 'Unreadable answer from Business Central.');
      return;
    }

    if (r.session) { applySession(r.session); }

    if (r.receipt && S.session.loggedIn) {
      S.prevQty = qtyMap(S.receipt);
      S.receipt = r.receipt;
      renderTicket();
    }
    if (r.products) { S.products = r.products; renderProducts(); }
    if (r.customers) { S.customers = r.customers; renderCustomerList(); }
    if (r.held) { S.held = r.held; }
    if (typeof r.heldCount === 'number') { S.heldCount = r.heldCount; renderTopbar(); }

    if (r.receiptDone) {
      S.pay = null;
      openModal({ type: 'receipt', receipt: r.receiptDone });
    } else if (r.openPanel === 'held') {
      openModal({ type: 'held' });
    } else if (S.modal && S.modal.type === 'held') {
      renderModal();
    }

    if (r.message) {
      if (S.session.loggedIn) { toast(r.message.type, r.message.text); }
      else if (!r.session || !r.session.error) { setLoginError(r.message.text); }
    }
    setBusy(false);
    if (!S.modal) { focusScan(); }
    pump();
  }

  function applyTheme() {
    var themes = S.cfg.themes || [];
    var current = null;
    themes.forEach(function (t) { if (t.code === S.cfg.themeCode) { current = t; } });
    POSTheme.apply(document.documentElement, current || themes[0] || null);
  }

  function qtyMap(receipt) {
    var m = {};
    if (receipt && receipt.lines) {
      receipt.lines.forEach(function (l) { m[l.lineNo] = l.qty; });
    }
    return m;
  }

  // -------------------------------------------------------------- rendering
  function skeleton() {
    return '' +
      '<div class="pos">' +
      '<header class="topbar">' +
      '<div class="brand"><span class="logo"></span><span id="company"></span></div>' +
      '<div class="who" id="who"></div>' +
      '<div class="top-actions">' +
      '<button class="btn ghost" data-act="toggle-full" id="fullBtn" hidden>Full screen</button>' +
      '<button class="btn ghost" data-act="open-themes" id="themeBtn" hidden>Theme</button>' +
      '<button class="btn ghost" data-act="open-held">Held <span class="badge" id="heldBadge">0</span></button>' +
      '<button class="btn ghost" data-act="last-receipt">Last receipt</button>' +
      '<button class="btn ghost danger admin-only" data-act="ask-void">Cancel sale</button>' +
      '<button class="btn ghost" data-act="logout" id="logoutBtn" hidden>Sign out</button>' +
      '</div>' +
      '</header>' +
      '<div class="banner" id="banner" hidden></div>' +
      '<main class="layout">' +
      '<section class="catalog">' +
      '<div class="searchbar">' +
      '<input id="scan" type="text" autocomplete="off" spellcheck="false" ' +
      'placeholder="Scan a barcode or search items   (F2)   -   tip: 3*barcode adds 3">' +
      '</div>' +
      '<div class="chips" id="chips"></div>' +
      '<div class="grid" id="grid"></div>' +
      '</section>' +
      '<aside class="ticket">' +
      '<button class="customer" data-act="open-customers" id="customerBtn"></button>' +
      '<div class="lines" id="lines"></div>' +
      '<div class="totals" id="totals"></div>' +
      '<div class="ticket-actions">' +
      '<button class="btn" data-act="hold">Hold <kbd>F8</kbd></button>' +
      '<button class="btn primary pay" data-act="open-pay" id="payBtn">Pay <kbd>F4</kbd></button>' +
      '</div>' +
      '</aside>' +
      '</main>' +
      '<div id="modal-host"></div>' +
      '<div class="login" id="login">' +
      '<form class="login-card" id="login-form" autocomplete="off">' +
      '<div class="login-logo"><span class="logo"></span></div>' +
      '<h1 id="login-company"></h1>' +
      '<p class="login-sub">Sign in to open the register</p>' +
      '<label for="login-user">User name</label>' +
      '<input id="login-user" class="text" type="text" autocomplete="off" autocapitalize="off" spellcheck="false" maxlength="50">' +
      '<label for="login-pass">Password</label>' +
      '<div class="pass-wrap">' +
      '<input id="login-pass" class="text" type="password" autocomplete="new-password" maxlength="100">' +
      '<button type="button" class="peek" data-act="peek-pass" tabindex="-1">Show</button>' +
      '</div>' +
      '<div class="login-row" hidden>' +
      '<label for="login-terminal">Terminal</label>' +
      '<select id="login-terminal" class="text"></select>' +
      '</div>' +
      '<div class="caps" id="login-caps" hidden>Caps Lock is on</div>' +
      '<div class="login-error" id="login-error" role="alert" hidden></div>' +
      '<button class="btn primary login-go" type="submit">Sign in</button>' +
      '</form>' +
      '</div>' +
      '<div id="toasts" aria-live="polite"></div>' +
      '<div id="busybar"></div>' +
      '</div>';
  }

  function renderAll() {
    renderTopbar();
    renderChips();
    renderProducts();
    renderTicket();
  }

  function renderTopbar() {
    if (!root) { return; }
    $('#company').textContent = S.cfg.companyName || 'Point of Sale';
    var t = S.session.terminal;
    var where = t ? (t.storeName || t.storeNo) + ' / ' + t.no : '';
    $('#who').textContent = S.session.loggedIn
      ? S.session.userName + (S.session.isAdmin ? ' (Admin)' : '') + (where ? '   -   ' + where : '') + (S.receipt ? '   -   Receipt ' + S.receipt.no : '')
      : '';
    $('#themeBtn').hidden = !(S.cfg.themes && S.cfg.themes.length > 1);
    var badge = $('#heldBadge');
    badge.textContent = S.heldCount;
    badge.classList.toggle('zero', !S.heldCount);

    var banner = $('#banner');
    if (S.cfg.setupIssues && S.cfg.setupIssues.length) {
      banner.hidden = false;
      banner.innerHTML = '<b>Setup incomplete.</b> ' + S.cfg.setupIssues.map(esc).join(' ') +
        ' Open <em>POS Setup</em> from the page menu.';
    } else {
      banner.hidden = true;
    }
  }

  function renderChips() {
    var html = '<button class="chip' + (S.category === '' ? ' on' : '') + '" data-act="category" data-code="">All</button>';
    (S.cfg.categories || []).forEach(function (c) {
      html += '<button class="chip' + (S.category === c.code ? ' on' : '') + '" data-act="category" data-code="' +
        esc(c.code) + '">' + esc(c.description || c.code) + '</button>';
    });
    $('#chips').innerHTML = html;
  }

  function renderProducts() {
    var grid = $('#grid');
    if (!S.products.length) {
      grid.innerHTML = '<div class="empty">No items found.</div>';
      return;
    }
    grid.innerHTML = S.products.map(function (p) {
      var h = hue(p.no);
      var stock = '';
      var cls = 'tile';
      if (p.tracked) {
        if (p.stock <= 0) { stock = 'Out of stock'; cls += ' out'; }
        else if (p.stock <= 5) { stock = qtyText(p.stock) + ' left'; cls += ' low'; }
        else { stock = qtyText(p.stock) + ' in stock'; }
      }
      return '<button class="' + cls + '" data-act="add-product" data-no="' + esc(p.no) + '" style="--h:' + h + '">' +
        '<span class="ini">' + esc(initials(p.description)) + '</span>' +
        '<span class="name">' + esc(p.description) + '</span>' +
        '<span class="meta"><b>' + money(p.price) + '</b><span class="stock">' + esc(stock) + '</span></span>' +
        '</button>';
    }).join('');
  }

  function renderTicket() {
    if (!root) { return; }
    var r = S.receipt;
    renderTopbar();

    var cust = $('#customerBtn');
    cust.innerHTML = r
      ? '<span class="c-label">Customer</span><span class="c-name">' + esc(r.customerName || r.customerNo || 'Select customer') + '</span><span class="c-go">Change</span>'
      : '<span class="c-name">Loading...</span>';

    var linesEl = $('#lines');
    var lines = r ? r.lines : [];
    if (!lines.length) {
      linesEl.innerHTML = '<div class="empty big"><div class="empty-ico">+</div>Scan an item or tap a product to start the sale.</div>';
    } else {
      var changed = null;
      linesEl.innerHTML = lines.map(function (l) {
        var isNew = S.prevQty[l.lineNo] === undefined || S.prevQty[l.lineNo] !== l.qty;
        if (isNew) { changed = l.lineNo; }
        var disc = l.discountPct ? '<span class="disc">-' + qtyText(l.discountPct) + '%</span>' : '';
        return '<div class="line' + (isNew ? ' flash' : '') + '" data-line="' + l.lineNo + '">' +
          '<div class="l-main"><div class="l-desc">' + esc(l.description) + '</div>' +
          '<div class="l-sub">' + money(l.unitPrice) + ' / ' + esc(l.uom) + ' ' + disc + '</div></div>' +
          '<div class="l-qty">' +
          '<button class="sq" data-act="qty-dec" data-line="' + l.lineNo + '" aria-label="Less"' +
          (!S.session.isAdmin && l.qty <= 1 ? ' disabled title="Only an administrator can remove a line"' : '') + '>-</button>' +
          '<button class="q" data-act="qty-edit" data-line="' + l.lineNo + '">' + qtyText(l.qty) + '</button>' +
          '<button class="sq" data-act="qty-inc" data-line="' + l.lineNo + '" aria-label="More">+</button>' +
          '</div>' +
          '<div class="l-amt">' + money(l.lineAmount) + '</div>' +
          '<div class="l-tools">' +
          '<button class="tool admin-only" data-act="disc-edit" data-line="' + l.lineNo + '" title="Discount">%</button>' +
          '<button class="tool del admin-only" data-act="line-remove" data-line="' + l.lineNo + '" title="Remove">&times;</button>' +
          '</div>' +
          '</div>';
      }).join('');
      if (changed !== null) {
        var el = linesEl.querySelector('[data-line="' + changed + '"]');
        if (el && el.scrollIntoView) { el.scrollIntoView({ block: 'nearest' }); }
      }
    }

    var cur = esc(S.cfg.currency);
    $('#totals').innerHTML = r
      ? '<div class="t-row"><span>Subtotal</span><span>' + money(r.subtotal) + '</span></div>' +
      (r.discount ? '<div class="t-row disc"><span>Discounts given</span><span>' + money(r.discount) + '</span></div>' : '') +
      '<div class="t-row"><span>VAT</span><span>' + money(r.vat) + '</span></div>' +
      '<div class="t-row grand"><span>Total ' + cur + '</span><span>' + money(r.total) + '</span></div>'
      : '';

    var hasLines = lines.length > 0;
    var pay = $('#payBtn');
    pay.disabled = !hasLines;
    pay.innerHTML = 'Pay ' + (hasLines ? money(r.total) : '') + ' <kbd>F4</kbd>';
    $('[data-act="hold"]').disabled = !hasLines;
  }

  // ------------------------------------------------------------------ modals
  function openModal(m) {
    S.modal = m;
    renderModal();
  }

  function closeModal() {
    S.modal = null;
    S.pay = null;
    $('#modal-host').innerHTML = '';
    focusScan();
  }

  function renderModal() {
    var host = $('#modal-host');
    var m = S.modal;
    if (!m) { host.innerHTML = ''; return; }
    var body = '';
    switch (m.type) {
      case 'keypad': body = keypadModal(m); break;
      case 'payment': body = paymentModal(); break;
      case 'customers': body = customersModal(); break;
      case 'held': body = heldModal(); break;
      case 'receipt': body = receiptModal(m.receipt); break;
      case 'confirm': body = confirmModal(m); break;
      case 'themes': body = themesModal(); break;
    }
    host.innerHTML = '<div class="overlay" data-act="overlay"><div class="modal modal-' + m.type + '" role="dialog">' + body + '</div></div>';
    if (m.type === 'customers') {
      var q = $('#cust-q');
      if (q) { q.focus(); }
      renderCustomerList();
    }
    if (m.type === 'payment') { renderPaymentState(); }
  }

  function keypadGrid() {
    var keys = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '.', '0', 'back'];
    return '<div class="kp-grid">' + keys.map(function (k) {
      return '<button class="key" data-act="kp" data-key="' + k + '">' + (k === 'back' ? '&#9003;' : k) + '</button>';
    }).join('') + '</div>';
  }

  function keypadModal(m) {
    return '<div class="m-head"><h2>' + esc(m.title) + '</h2><button class="x" data-act="close-modal">&times;</button></div>' +
      '<div class="kp-display" id="kp-display">' + esc(m.buf || '0') + '</div>' +
      (m.hint ? '<div class="hint">' + esc(m.hint) + '</div>' : '') +
      keypadGrid() +
      '<div class="m-foot"><button class="btn" data-act="close-modal">Cancel</button>' +
      '<button class="btn primary" data-act="kp-ok">OK</button></div>';
  }

  function confirmModal(m) {
    return '<div class="m-head"><h2>' + esc(m.title) + '</h2></div>' +
      '<p class="m-text">' + esc(m.text) + '</p>' +
      '<div class="m-foot"><button class="btn" data-act="close-modal">Keep selling</button>' +
      '<button class="btn danger-fill" data-act="confirm-yes">' + esc(m.yes) + '</button></div>';
  }

  // ---- themes
  function themesModal() {
    var rows = (S.cfg.themes || []).map(function (t) {
      var c = POSTheme.resolve(t);
      var on = t.code === S.cfg.themeCode;
      return '<button class="row theme' + (on ? ' on' : '') + '" data-act="pick-theme" data-code="' + esc(t.code) + '">' +
        '<span class="swatches">' + ['background', 'panel', 'accent', 'text'].map(function (k) {
          return '<i style="background:' + c[k] + '"></i>';
        }).join('') + '</span>' +
        '<span class="r-main"><b>' + esc(t.name || t.code) + '</b></span>' +
        (on ? '<span class="r-side">Active</span>' : '') + '</button>';
    }).join('');
    return '<div class="m-head"><h2>Choose a theme</h2><button class="x" data-act="close-modal">&times;</button></div>' +
      '<div class="list">' + rows + '</div>' +
      '<div class="hint">Your choice is remembered for your user. Managers can edit colors in POS Themes.</div>';
  }

  // ---- customers
  function customersModal() {
    return '<div class="m-head"><h2>Select customer</h2><button class="x" data-act="close-modal">&times;</button></div>' +
      '<input id="cust-q" class="text" type="text" placeholder="Search by name or number" autocomplete="off">' +
      '<div class="list" id="cust-list"></div>';
  }

  function renderCustomerList() {
    var el = $('#cust-list');
    if (!el || !S.modal || S.modal.type !== 'customers') { return; }
    if (!S.customers.length) { el.innerHTML = '<div class="empty">No customers found.</div>'; return; }
    el.innerHTML = S.customers.map(function (c) {
      return '<button class="row" data-act="pick-customer" data-no="' + esc(c.no) + '">' +
        '<span class="r-main"><b>' + esc(c.name) + '</b><small>' + esc(c.no) + (c.city ? ' - ' + esc(c.city) : '') + '</small></span>' +
        '<span class="r-side">' + esc(c.phone) + '</span></button>';
    }).join('');
  }

  // ---- held receipts
  function heldModal() {
    var rows = S.held.length ? S.held.map(function (h) {
      var who = S.session.isAdmin ? ' - ' + (h.mine ? 'you' : esc(h.cashier)) : '';
      var at = h.terminal ? ' - ' + esc(h.terminal) : '';
      return '<div class="row static">' +
        '<span class="r-main"><b>' + esc(h.no) + '</b><small>' + esc(h.time) + who + at + ' - ' + esc(h.customerName) + ' - ' + qtyText(h.itemCount) + ' items</small></span>' +
        '<span class="r-side"><b>' + money(h.total) + '</b></span>' +
        (h.mine === false && !S.session.isAdmin ? '' : '<button class="btn small primary" data-act="recall" data-no="' + esc(h.no) + '">Recall</button>') +
        '<button class="btn small admin-only" data-act="discard-held" data-no="' + esc(h.no) + '">Discard</button></div>';
    }).join('') : '<div class="empty">No receipts on hold.</div>';
    return '<div class="m-head"><h2>' + (S.session.isAdmin ? 'Receipts on hold (all cashiers)' : 'Receipts on hold') + '</h2><button class="x" data-act="close-modal">&times;</button></div>' +
      '<div class="list">' + rows + '</div>';
  }

  // ---- payment
  function paymentTotals() {
    var total = S.receipt ? S.receipt.total : 0;
    var paid = 0;
    S.pay.list.forEach(function (p) { paid += p.amount; });
    paid = round2(paid);
    return { total: total, paid: paid, remaining: round2(Math.max(0, total - paid)), change: round2(Math.max(0, paid - total)) };
  }

  function methodByCode(code) {
    var found = null;
    S.cfg.paymentMethods.forEach(function (m) { if (m.code === code) { found = m; } });
    return found;
  }

  function cashMethod() {
    var found = null;
    S.cfg.paymentMethods.forEach(function (m) { if (!found && m.isCash) { found = m; } });
    return found;
  }

  function paymentModal() {
    var cash = cashMethod();
    var quick = '';
    if (cash) {
      var amounts = String(cash.quickAmounts || '').split(',').map(function (a) { return parseFloat(a); })
        .filter(function (a) { return a > 0; }).slice(0, 5);
      quick = '<button class="quick" data-act="pay-exact">Exact</button>' + amounts.map(function (a) {
        return '<button class="quick" data-act="pay-quick" data-amount="' + a + '">' + money(a) + '</button>';
      }).join('');
    }
    var methods = S.cfg.paymentMethods.map(function (m) {
      return '<button class="method" data-act="pay-method" data-code="' + esc(m.code) + '">' + esc(m.description || m.code) + '</button>';
    }).join('');

    return '<div class="m-head"><h2>Payment</h2><button class="x" data-act="close-modal">&times;</button></div>' +
      '<div class="pay-wrap">' +
      '<div class="pay-left">' +
      '<div class="pay-due"><span>Amount due</span><b id="p-due"></b></div>' +
      '<div class="pay-list" id="p-list"></div>' +
      '<div class="pay-rem" id="p-rem"></div>' +
      '</div>' +
      '<div class="pay-right">' +
      '<div class="kp-display" id="p-display"></div>' +
      (quick ? '<div class="quick-row">' + quick + '</div>' : '') +
      keypadGrid() +
      '<div class="method-row">' + (methods || '<div class="empty">No payment methods set up.</div>') + '</div>' +
      '</div>' +
      '</div>' +
      '<div class="m-foot"><button class="btn" data-act="close-modal">Back</button>' +
      '<button class="btn primary big" data-act="pay-complete" id="p-complete">Complete sale <kbd>Enter</kbd></button></div>';
  }

  function renderPaymentState() {
    if (!S.pay || !S.modal || S.modal.type !== 'payment') { return; }
    var t = paymentTotals();
    $('#p-due').textContent = money(t.total);
    $('#p-display').innerHTML = S.pay.buf
      ? esc(S.pay.buf)
      : '<span class="ph">' + money(t.remaining) + '</span>';
    $('#p-list').innerHTML = S.pay.list.length
      ? S.pay.list.map(function (p, i) {
        var m = methodByCode(p.method);
        return '<div class="pay-row"><span>' + esc(m ? m.description : p.method) + '</span><b>' + money(p.amount) +
          '</b><button class="tool del" data-act="pay-remove" data-i="' + i + '">&times;</button></div>';
      }).join('')
      : '<div class="hint">Enter an amount and choose how it was paid. Leave it empty to pay the full remaining amount.</div>';
    $('#p-rem').className = 'pay-rem' + (t.remaining > 0 ? '' : ' done');
    $('#p-rem').innerHTML = t.change > 0
      ? '<span>Change to give</span><b>' + money(t.change) + '</b>'
      : '<span>Remaining</span><b>' + money(t.remaining) + '</b>';
    var btn = $('#p-complete');
    btn.disabled = S.busy || t.remaining > 0 || !S.pay.list.length;
  }

  function addPayment(code, amount) {
    var m = methodByCode(code);
    var t = paymentTotals();
    if (!m) { return; }
    if (t.remaining <= 0) { toast('info', 'The amount due is already covered.'); return; }
    amount = round2(amount);
    if (!(amount > 0)) { toast('error', 'Enter an amount greater than zero.'); return; }
    // Only cash may be more than what is due; the rest is given back as change.
    if (!m.isCash && amount > t.remaining) { amount = t.remaining; }
    S.pay.list.push({ method: code, amount: amount });
    S.pay.buf = '';
    renderPaymentState();
  }

  function enteredAmount() {
    return S.pay.buf ? parseFloat(S.pay.buf) : paymentTotals().remaining;
  }

  function completeSale() {
    if (S.busy) { return; }
    var t = paymentTotals();
    if (t.remaining > 0 || !S.pay.list.length) { return; }
    send('checkout', { payments: S.pay.list.map(function (p) { return { method: p.method, amount: p.amount }; }) });
  }

  // ---- receipt
  function receiptModal(r) {
    var change = r.change > 0
      ? '<div class="change-due"><span>Change to give</span><b>' + money(r.change) + '</b></div>' : '';
    return '<div class="m-head"><h2>Sale complete</h2></div>' + change +
      '<div class="rcpt-wrap">' + receiptHtml(r) + '</div>' +
      '<div class="m-foot"><button class="btn" data-act="print-receipt">Print receipt</button>' +
      '<button class="btn primary big" data-act="close-modal">New sale</button></div>';
  }

  function receiptHtml(r) {
    var cur = S.cfg.currency ? ' ' + esc(S.cfg.currency) : '';
    var lines = r.lines.map(function (l) {
      return '<div class="r-line"><div class="r-d">' + esc(l.description) + '</div>' +
        '<div class="r-q"><span>' + qtyText(l.qty) + ' x ' + money(l.unitPrice) + '</span><span>' + money(l.lineAmount + l.discountAmount) + '</span></div>' +
        (l.discountAmount ? '<div class="r-q"><span>Discount ' + qtyText(l.discountPct) + '%</span><span>-' + money(l.discountAmount) + '</span></div>' : '') +
        '</div>';
    }).join('');
    var pays = (r.payments || []).map(function (p) {
      return '<div class="r-row"><span>' + esc(p.description) + '</span><span>' + money(p.amount) + '</span></div>';
    }).join('');
    var st = r.store && r.store.name ? r.store : null;
    // Pictures chosen in POS Setup. Only data: image URLs are accepted, so a bad value cannot load anything from the web.
    var pic = function (src, cls) {
      return /^data:image\/(png|jpeg|gif|bmp);base64,[A-Za-z0-9+\/=]+$/.test(src || '')
        ? '<div class="r-pic ' + cls + '"><img alt="" src="' + src + '"></div>' : '';
    };
    return '<div class="rcpt">' +
      pic(S.cfg.headerPicture, 'r-pic-head') +
      '<div class="r-title">' + esc(S.cfg.companyName) + '</div>' +
      (st ? '<div class="r-center">' + esc(st.name) + '</div>' : '') +
      (st && st.address ? '<div class="r-center small">' + esc(st.address) + '</div>' : '') +
      (st && st.phone ? '<div class="r-center small">Tel ' + esc(st.phone) + '</div>' : '') +
      (st && st.taxNo ? '<div class="r-center small">Tax reg. ' + esc(st.taxNo) + '</div>' : '') +
      '<div class="r-center">Receipt ' + esc(r.no) + '</div>' +
      '<div class="r-center">' + esc(r.date) + ' ' + esc(r.time) + '</div>' +
      '<div class="r-center">Cashier: ' + esc(r.cashier) + (r.terminal ? '   Terminal: ' + esc(r.terminal) : '') + '</div>' +
      (r.customerName ? '<div class="r-center">' + esc(r.customerName) + '</div>' : '') +
      '<hr>' + lines + '<hr>' +
      '<div class="r-row"><span>Subtotal</span><span>' + money(r.subtotal) + '</span></div>' +
      (r.discount ? '<div class="r-row"><span>Discounts included</span><span>' + money(r.discount) + '</span></div>' : '') +
      '<div class="r-row"><span>VAT</span><span>' + money(r.vat) + '</span></div>' +
      '<div class="r-row r-total"><span>TOTAL' + cur + '</span><span>' + money(r.total) + '</span></div>' +
      '<hr>' + pays +
      (r.change > 0 ? '<div class="r-row"><span>Change</span><span>' + money(r.change) + '</span></div>' : '') +
      (r.invoiceNo ? '<hr><div class="r-center small">Invoice ' + esc(r.invoiceNo) + '</div>' : '') +
      (S.cfg.footer ? '<div class="r-center">' + esc(S.cfg.footer) + '</div>' : '') +
      pic(S.cfg.footerPicture, 'r-pic-foot') +
      '</div>';
  }

  var RECEIPT_PRINT_CSS =
    'body{margin:0;font:12px/1.35 "Courier New",monospace;color:#000;width:72mm}' +
    '.rcpt{padding:4mm 2mm}.r-title{text-align:center;font-weight:bold;font-size:14px}' +
    '.r-center{text-align:center}.small{font-size:11px}hr{border:0;border-top:1px dashed #000;margin:6px 0}' +
    '.r-row,.r-q{display:flex;justify-content:space-between;gap:8px}.r-total{font-weight:bold;font-size:14px}' +
    '.r-line{margin-bottom:4px}.r-d{word-break:break-word}' +
    '.r-pic{text-align:center;margin:4px 0}.r-pic img{max-width:100%;max-height:30mm;object-fit:contain}';

  function printReceipt(r) {
    var html = '<!doctype html><html><head><meta charset="utf-8"><title>' + esc(r.no) + '</title><style>' +
      RECEIPT_PRINT_CSS + '</style></head><body>' + receiptHtml(r) + '</body></html>';
    var frame = document.createElement('iframe');
    frame.style.cssText = 'position:fixed;right:0;bottom:0;width:0;height:0;border:0;';
    document.body.appendChild(frame);
    var doc = frame.contentWindow.document;
    doc.open(); doc.write(html); doc.close();
    setTimeout(function () {
      try {
        frame.contentWindow.focus();
        frame.contentWindow.print();
      } catch (e) {
        var w = window.open('', '_blank', 'width=380,height=640');
        if (w) { w.document.write(html); w.document.close(); w.focus(); w.print(); }
        else { toast('error', 'The browser blocked printing from this page.'); }
      }
      setTimeout(function () { if (frame.parentNode) { frame.parentNode.removeChild(frame); } }, 3000);
    }, 250);
  }

  // ------------------------------------------------------------------ toasts
  function toast(type, text) {
    var host = $('#toasts');
    if (!host || !text) { return; }
    var el = document.createElement('div');
    el.className = 'toast ' + (type || 'info');
    el.textContent = text;
    el.addEventListener('click', function () { el.remove(); });
    host.appendChild(el);
    while (host.children.length > 3) { host.removeChild(host.firstChild); }
    setTimeout(function () { if (el.parentNode) { el.remove(); } }, type === 'error' ? 9000 : 3500);
  }

  // ------------------------------------------------------------------ input
  function focusScan() {
    var s = $('#scan');
    if (s && !S.modal && S.session.loggedIn) { s.focus(); }
  }

  function lineById(id) {
    var found = null;
    if (S.receipt) { S.receipt.lines.forEach(function (l) { if (String(l.lineNo) === String(id)) { found = l; } }); }
    return found;
  }

  function onClick(e) {
    var t = e.target.closest('[data-act]');
    if (!t) { return; }
    var act = t.getAttribute('data-act');
    var d = t.dataset;
    if (act === 'overlay') {
      if (e.target === t && S.modal && (S.modal.type === 'customers' || S.modal.type === 'held' || S.modal.type === 'confirm' || S.modal.type === 'themes')) { closeModal(); }
      return;
    }
    if (t.disabled) { return; }

    switch (act) {
      case 'toggle-full': toggleFull(); focusScan(); break;
      case 'add-product': send('add-item', { itemNo: d.no, qty: 1 }); focusScan(); break;
      case 'category':
        S.category = d.code; renderChips();
        send('search-products', { text: $('#scan').value, category: S.category });
        break;
      case 'qty-inc': { var a = lineById(d.line); if (a) { send('set-qty', { lineNo: a.lineNo, qty: a.qty + 1 }); } break; }
      case 'qty-dec': { var b = lineById(d.line); if (b && (S.session.isAdmin || b.qty > 1)) { send('set-qty', { lineNo: b.lineNo, qty: b.qty - 1 }); } break; }
      case 'qty-edit': {
        var q = lineById(d.line);
        if (q) { openModal({ type: 'keypad', mode: 'qty', lineNo: q.lineNo, title: 'Quantity - ' + q.description, buf: '', hint: S.session.isAdmin ? 'Enter 0 to remove the line.' : 'Enter the new quantity.' }); }
        break;
      }
      case 'disc-edit': {
        var l = lineById(d.line);
        if (!l) { break; }
        if (!S.session.isAdmin) { toast('error', 'Only an administrator can give discounts.'); break; }
        if (!S.cfg.maxDiscount) { toast('error', 'Discounts are disabled in POS Setup.'); break; }
        openModal({ type: 'keypad', mode: 'disc', lineNo: l.lineNo, title: 'Discount % - ' + l.description, buf: '', hint: 'Maximum ' + qtyText(S.cfg.maxDiscount) + '%. Enter 0 to clear.' });
        break;
      }
      case 'line-remove': send('remove-line', { lineNo: Number(d.line) }); break;
      case 'open-customers':
        openModal({ type: 'customers' });
        S.customers = [];
        send('search-customers', { text: '' });
        break;
      case 'pick-customer': closeModal(); send('set-customer', { customerNo: d.no }); break;
      case 'open-themes': openModal({ type: 'themes' }); break;
      case 'pick-theme':
        S.cfg.themeCode = d.code; applyTheme(); closeModal();
        send('set-theme', { code: d.code });
        break;
      case 'hold': send('hold'); break;
      case 'open-held': send('list-held'); break;
      case 'recall': closeModal(); send('recall', { receiptNo: d.no }); break;
      case 'discard-held': send('discard-held', { receiptNo: d.no }); break;
      case 'last-receipt': send('reprint-last'); break;
      case 'logout': send('logout'); break;
      case 'peek-pass': {
        var pw = $('#login-pass');
        pw.type = pw.type === 'password' ? 'text' : 'password';
        t.textContent = pw.type === 'password' ? 'Show' : 'Hide';
        pw.focus();
        break;
      }
      case 'ask-void':
        if (!S.session.isAdmin) { toast('error', 'Only an administrator can cancel a sale.'); break; }
        if (S.receipt && S.receipt.lines.length) {
          openModal({ type: 'confirm', title: 'Cancel this sale?', text: 'All items on receipt ' + S.receipt.no + ' will be cleared and the receipt is marked as voided.', yes: 'Cancel sale', action: 'clear' });
        } else { toast('info', 'The sale is empty.'); }
        break;
      case 'confirm-yes': var action = S.modal && S.modal.action; closeModal(); if (action) { send(action); } break;
      case 'close-modal': closeModal(); break;
      case 'kp': keypadKey(d.key); break;
      case 'kp-ok': keypadOk(); break;
      case 'open-pay':
        if (S.receipt && S.receipt.lines.length) {
          S.pay = { list: [], buf: '' };
          openModal({ type: 'payment' });
        }
        break;
      case 'pay-method': addPayment(d.code, enteredAmount()); break;
      case 'pay-exact': { var c1 = cashMethod(); if (c1) { addPayment(c1.code, paymentTotals().remaining); } break; }
      case 'pay-quick': { var c2 = cashMethod(); if (c2) { addPayment(c2.code, parseFloat(d.amount)); } break; }
      case 'pay-remove': S.pay.list.splice(Number(d.i), 1); renderPaymentState(); break;
      case 'pay-complete': completeSale(); break;
      case 'print-receipt': if (S.modal && S.modal.receipt) { printReceipt(S.modal.receipt); } break;
    }
  }

  function keypadKey(k) {
    var target = (S.modal && S.modal.type === 'payment') ? S.pay : S.modal;
    if (!target) { return; }
    var buf = target.buf || '';
    if (k === 'back') { buf = buf.slice(0, -1); }
    else if (k === '.') { if (buf.indexOf('.') === -1) { buf = (buf || '0') + '.'; } }
    else {
      if (buf === '0') { buf = ''; }
      if (buf.replace('.', '').length < 9) { buf += k; }
    }
    target.buf = buf;
    if (S.modal.type === 'payment') { renderPaymentState(); }
    else { var el = $('#kp-display'); if (el) { el.textContent = buf || '0'; } }
  }

  function keypadOk() {
    var m = S.modal;
    if (!m || m.type !== 'keypad') { return; }
    var v = parseFloat(m.buf);
    if (isNaN(v)) { closeModal(); return; }
    if (m.mode === 'qty' && v <= 0 && !S.session.isAdmin) {
      toast('error', 'Only an administrator can remove a line. Enter a quantity of 1 or more.');
      return;
    }
    closeModal();
    if (m.mode === 'qty') { send('set-qty', { lineNo: m.lineNo, qty: v }); }
    if (m.mode === 'disc') { send('set-discount', { lineNo: m.lineNo, pct: v }); }
  }

  function onKey(e) {
    if (!S.session.loggedIn) {
      var caps = $('#login-caps');
      if (caps && e.getModifierState) { caps.hidden = !e.getModifierState('CapsLock'); }
      return;
    }
    var m = S.modal;
    if (!m) {
      if (e.key === 'F2') { e.preventDefault(); $('#scan').focus(); $('#scan').select(); }
      else if (e.key === 'F4') { e.preventDefault(); var pay = $('#payBtn'); if (!pay.disabled) { pay.click(); } }
      else if (e.key === 'F8') { e.preventDefault(); var hold = $('[data-act="hold"]'); if (!hold.disabled) { hold.click(); } }
      else if (e.key === 'F9') { e.preventDefault(); $('#customerBtn').click(); }
      return;
    }

    if (e.key === 'Escape') { e.preventDefault(); closeModal(); return; }
    if (m.type === 'customers') { return; }

    if (m.type === 'keypad' || m.type === 'payment') {
      if (/^[0-9]$/.test(e.key) || e.key === '.' || e.key === ',') { e.preventDefault(); keypadKey(e.key === ',' ? '.' : e.key); }
      else if (e.key === 'Backspace') { e.preventDefault(); keypadKey('back'); }
      else if (e.key === 'Enter') {
        e.preventDefault();
        if (m.type === 'keypad') { keypadOk(); }
        else if (paymentTotals().remaining > 0) {
          var def = cashMethod() || S.cfg.paymentMethods[0];
          if (def) { addPayment(def.code, enteredAmount()); }
        } else { completeSale(); }
      }
    } else if (m.type === 'receipt' && e.key === 'Enter') {
      e.preventDefault(); closeModal();
    }
  }

  // customer search box lives inside a modal that is re-rendered, so listen on the root
  document.addEventListener('input', function (e) {
    if (e.target && e.target.id === 'cust-q') {
      var value = e.target.value;
      clearTimeout(S.custTimer);
      S.custTimer = setTimeout(function () { send('search-customers', { text: value }); }, 250);
    }
  });

  // ---------------------------------------------------- public surface for BC
  window.POS = { start: start };
  window.Initialize = initialize;   // called by AL: CurrPage.POS.Initialize(...)
  window.Apply = apply;             // called by AL: CurrPage.POS.Apply(...)
})();