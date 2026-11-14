page 50201 "POS Setup"
{
    Caption = 'POS Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "POS Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default Customer No."; Rec."Default Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The customer that cash sales are posted to when the cashier does not pick another one. Use a customer with immediate payment terms.';
                }
                field("Default Location Code"; Rec."Default Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'The store location. Stock shown on the register and the posted sales use this location.';
                }
                field("Receipt Nos."; Rec."Receipt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number series for POS receipts.';
                }
            }
            group(Register)
            {
                Caption = 'Register';
                field("Max Line Discount %"; Rec."Max Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Product Tiles"; Rec."Product Tiles")
                {
                    ApplicationArea = All;
                }
                field("Auto Sign-out (minutes)"; Rec."Auto Sign-out (minutes)")
                {
                    ApplicationArea = All;
                }
                field("Default Theme Code"; Rec."Default Theme Code")
                {
                    ApplicationArea = All;
                }
                field("Start Full Screen"; Rec."Start Full Screen")
                {
                    ApplicationArea = All;
                }
            }
            group(ReceiptPrinting)
            {
                Caption = 'Receipt';
                field("Receipt Header Text"; Rec."Receipt Header Text")
                {
                    ApplicationArea = All;
                }
                field("Receipt Footer Text"; Rec."Receipt Footer Text")
                {
                    ApplicationArea = All;
                }
            }
            group(ReceiptPictures)
            {
                Caption = 'Receipt Pictures';
                field("Receipt Header Picture"; Rec."Receipt Header Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Printed at the top of the receipt. Use the Import Header Picture action to choose a file.';
                }
                field("Receipt Footer Picture"; Rec."Receipt Footer Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Printed at the bottom of the receipt. Use the Import Footer Picture action to choose a file.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportHeaderPicture)
            {
                Caption = 'Import Header Picture';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Choose the picture printed at the top of the receipt (PNG, JPG, GIF or BMP, up to 500 KB).';

                trigger OnAction()
                begin
                    ImportPicture(true);
                end;
            }
            action(DeleteHeaderPicture)
            {
                Caption = 'Remove Header Picture';
                ApplicationArea = All;
                Image = Delete;
                ToolTip = 'Stops printing a picture at the top of the receipt.';

                trigger OnAction()
                begin
                    Clear(Rec."Receipt Header Picture");
                    Rec.Modify(true);
                end;
            }
            action(ImportFooterPicture)
            {
                Caption = 'Import Footer Picture';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Choose the picture printed at the bottom of the receipt (PNG, JPG, GIF or BMP, up to 500 KB).';

                trigger OnAction()
                begin
                    ImportPicture(false);
                end;
            }
            action(DeleteFooterPicture)
            {
                Caption = 'Remove Footer Picture';
                ApplicationArea = All;
                Image = Delete;
                ToolTip = 'Stops printing a picture at the bottom of the receipt.';

                trigger OnAction()
                begin
                    Clear(Rec."Receipt Footer Picture");
                    Rec.Modify(true);
                end;
            }
        }
        area(Navigation)
        {
            action(PaymentMethods)
            {
                Caption = 'Payment Methods';
                ApplicationArea = All;
                Image = Payment;
                RunObject = page "POS Payment Methods";
            }
            action(Users)
            {
                Caption = 'POS Users';
                ApplicationArea = All;
                Image = Users;
                RunObject = page "POS Users";
                ToolTip = 'Create the users who can sign in to the register and choose who is an administrator.';
            }
            action(Stores)
            {
                Caption = 'Stores';
                ApplicationArea = All;
                Image = Warehouse;
                RunObject = page "POS Store List";
                ToolTip = 'Set up the stores: location, default customer, dimensions and receipt details.';
            }
            action(Terminals)
            {
                Caption = 'Terminals';
                ApplicationArea = All;
                Image = Register;
                RunObject = page "POS Terminal List";
                ToolTip = 'Set up the registers of each store: receipt numbers, auto sign-out and who may use them.';
            }
            action(Themes)
            {
                Caption = 'Themes';
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "POS Themes";
                ToolTip = 'Create and edit the colour themes of the register screen.';
            }
        }
        area(Promoted)
        {
            actionref(PaymentMethods_Promoted; PaymentMethods)
            {
            }
            actionref(Themes_Promoted; Themes)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;

    var
        PictureTooBigErr: Label 'The picture is %1 KB. The limit is 500 KB, because the picture is sent to the register every time it opens. Use a smaller picture.', Comment = '%1 = size in KB';
        PictureTypeErr: Label 'Choose a PNG, JPG, GIF or BMP picture.';
        PictureDialogTxt: Label 'Choose a picture';
        PictureFilterTxt: Label 'Pictures (*.png;*.jpg;*.jpeg;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.gif;*.bmp';

    local procedure ImportPicture(IsHeader: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        CopyInStream: InStream;
        OutStr: OutStream;
        FileName: Text;
        MimeType: Text;
    begin
        if not UploadIntoStream(PictureDialogTxt, '', PictureFilterTxt, FileName, FileInStream) then
            exit;

        MimeType := GetMimeType(FileName);
        if MimeType = '' then
            Error(PictureTypeErr);

        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, FileInStream);
        if TempBlob.Length() > 512000 then
            Error(PictureTooBigErr, Round(TempBlob.Length() / 1024, 1));
        TempBlob.CreateInStream(CopyInStream);

        if IsHeader then begin
            Clear(Rec."Receipt Header Picture");
            Rec."Receipt Header Picture".ImportStream(CopyInStream, FileName, MimeType);
        end else begin
            Clear(Rec."Receipt Footer Picture");
            Rec."Receipt Footer Picture".ImportStream(CopyInStream, FileName, MimeType);
        end;
        Rec.Modify(true);
    end;

    local procedure GetMimeType(FileName: Text): Text
    var
        Extension: Text;
        DotPos: Integer;
    begin
        DotPos := StrLen(FileName);
        while (DotPos > 0) and (FileName[DotPos] <> '.') do
            DotPos -= 1;
        if DotPos = 0 then
            exit('');
        Extension := LowerCase(CopyStr(FileName, DotPos + 1));
        case Extension of
            'png':
                exit('image/png');
            'jpg', 'jpeg':
                exit('image/jpeg');
            'gif':
                exit('image/gif');
            'bmp':
                exit('image/bmp');
        end;
        exit('');
    end;
}
