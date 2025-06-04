unit HexGoto;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TGotoType = (gtFromChunk, gtFromFile, gtFromCurrentPos);

  TGotoDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    HexLabel: TLabel;
    HexEdit: TEdit;
    DecimalLabel: TLabel;
    DecimalEdit: TEdit;
    procedure OKBtnClick(Sender: TObject);
    procedure DecimalChanged(Sender: TObject);
    procedure HexChanged(Sender: TObject);
    procedure HexEditKeyPress(Sender: TObject; var Key: Char);
    procedure DecimalEditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    Offset: longint;
    Typ: TGotoType;
    { Public declarations }
  end;

var
  GotoDialog: TGotoDialog;

implementation

uses
  StrLib;

{$R *.DFM}

procedure TGotoDialog.OKBtnClick(Sender: TObject);
begin
  Offset:=strtointdef(DecimalEdit.Text,0);
  Typ:=gtFromChunk;
  HexEdit.SetFocus;
  ModalResult:=42;
end;

procedure TGotoDialog.HexChanged(Sender: TObject);
begin
  if HexEdit.Modified then
  begin
    DecimalEdit.Text:=inttostr(HexToIntDef(HexEdit.Text,0));
  end;
end;

procedure TGotoDialog.DecimalChanged(Sender: TObject);
begin
  if DecimalEdit.Modified then
  begin
    HexEdit.Text:=inttohex(StrToIntDef(DecimalEdit.Text,0),1);
  end;
end;

procedure TGotoDialog.DecimalEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key<#32 then Exit;
  if (Key<'0') or (Key>'9') then Key:=#0;
end;

procedure TGotoDialog.HexEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key<#32 then Exit;
  if ((Key<'0') or (Key>'9')) and ((UpCase(Key)<'A') or (UpCase(Key)>'F')) then Key:=#0;
end;

end.
