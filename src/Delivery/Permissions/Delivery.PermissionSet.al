/// <summary>
/// Unknown POS - DELIVERY (ID 50201).
/// </summary>
permissionset 50201 "POS - DELIVERY"
{
    Assignable = true;
    Caption = 'POS - Delivery';

    Permissions =
        tabledata "Delivery Setup" = RIMD,
        tabledata "Delivery Zone" = RIMD,
        tabledata "Delivery Driver" = RIMD,
        tabledata "Delivery Order" = RIMD,
        tabledata "Delivery Status Log" = RIMD,
        tabledata "Delivery Cue" = RIMD,
        tabledata "POS Receipt Header" = R,
        tabledata "POS Receipt Line" = R,
        tabledata "POS Store" = R,
        tabledata "POS Payment Method" = R,
        tabledata "Delivery Client" = RIMD,
        table "Delivery Setup" = X,
        table "Delivery Zone" = X,
        table "Delivery Driver" = X,
        table "Delivery Order" = X,
        table "Delivery Status Log" = X,
        table "Delivery Cue" = X,
        table "Delivery Client" = X,
        codeunit "Delivery Management" = X,
        codeunit "Delivery Post Collection" = X,
        codeunit "Delivery Actions" = X,
        page "Delivery Setup" = X,
        page "Delivery Zones" = X,
        page "Delivery Drivers" = X,
        page "Delivery Orders" = X,
        page "Delivery Order" = X,
        page "Delivery Status Log" = X,
        page "Delivery Activities" = X,
        page "Delivery Active Orders" = X,
        page "Delivery Role Center" = X,
        page "My Deliveries" = X,
        page "Delivery Complete Dialog" = X,
        page "Delivery Client Card" = X,
        page "Delivery Client List" = X,
        page "Delivery Fail Dialog" = X,
        report "Delivery Order" = X,
        report "Delivery Run Sheet" = X,
        report "Delivery Status Summary" = X,
        report "COD Collection Report" = X,
        report "Driver Cash Reconciliation" = X;
}
