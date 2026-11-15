/// <summary>
/// Posts the cash a driver collected on delivery as a customer payment, applied to the invoice of the order.
/// The balancing account comes from the POS payment method chosen in Delivery Setup.
/// </summary>
codeunit 50208 "Delivery Post Collection"
{
    procedure PostCollection(Order: Record "Delivery Order"; Amount: Decimal): Code[20]
    var
        DeliverySetup: Record "Delivery Setup";
        PaymentMethod: Record "POS Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        Store: Record "POS Store";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DeliveryClient: Record "Delivery Client";
    begin
        Order.TestField("Customer No.");
        DeliverySetup.GetSetup();
        DeliverySetup.TestField("COD Payment Method");
        PaymentMethod.Get(DeliverySetup."COD Payment Method");
        PaymentMethod.TestField("Balancing Account No.");
        SourceCodeSetup.Get();

        GenJnlLine.Init();
        GenJnlLine."Line No." := 10000;
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Document Date" := WorkDate();
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := Order."No.";
        GenJnlLine."External Document No." := Order."No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Delivery Client", Order."Customer No.");
        if DeliveryClient.Get(Order."Customer No.") then exit;
        GenJnlLine.Validate("Account No.", DeliveryClient."Customer No.");
        GenJnlLine.Description := CopyStr(StrSubstNo(DescriptionTxt, Order."No.", PaymentMethod.Description), 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine.Validate(Amount, -Amount);
        GenJnlLine."Bal. Account Type" := PaymentMethod."Balancing Account Type";
        GenJnlLine.Validate("Bal. Account No.", PaymentMethod."Balancing Account No.");
        if Order."Posted Sales Invoice No." <> '' then begin
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
            GenJnlLine."Applies-to Doc. No." := Order."Posted Sales Invoice No.";
        end;
        GenJnlLine."Source Code" := SourceCodeSetup."Cash Receipt Journal";
        if Store.Get(Order."Store No.") then begin
            if Store."Global Dimension 1 Code" <> '' then
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Store."Global Dimension 1 Code");
            if Store."Global Dimension 2 Code" <> '' then
                GenJnlLine.Validate("Shortcut Dimension 2 Code", Store."Global Dimension 2 Code");
        end;
        GenJnlPostLine.RunWithCheck(GenJnlLine);
        exit(GenJnlLine."Document No.");
    end;

    var
        DescriptionTxt: Label 'Delivery %1 %2', Comment = '%1 = delivery order no., %2 = payment method';
}
