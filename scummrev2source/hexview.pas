unit HexView;

interface

uses
  Windows, SysUtils, Forms, Classes, Controls, HexEditor, Menus, DFSStatusBar,
  ExtCtrls, StdCtrls, StrLib, Messages, HexGoto;

type
  THexForm = class(TForm)
    SpecHexEdit: THexEditor;
    HexMainMenu: TMainMenu;
    StatusBar: TDFSStatusBar;
    ViewDivsByteItem: TMenuItem;
    ViewDivsWordItem: TMenuItem;
    ViewDivsDWordItem: TMenuItem;
    ViewDivsQWordItem: TMenuItem;
    ViewDivsNoneItem: TMenuItem;

    ViewOffsetHexItem: TMenuItem;
    ViewOffsetDecItem: TMenuItem;
    ViewOffsetNoneItem: TMenuItem;

    ViewCharsetASCII7Item: TMenuItem;
    ViewCharsetASCII8Item: TMenuItem;
    ViewCharsetWindowsItem: TMenuItem;
    ViewCharSetMaskItem: TMenuItem;

    ViewConvBigEndianItem: TMenuItem;
    ViewConvSignedItem: TMenuItem;

    InfoPanel: TPanel;
    BinLabel: TLabel;
    HexLabel: TLabel;
    DecLabel: TLabel;
    BinTitleLabel: TLabel;
    HexTitleLabel: TLabel;
    DecTitleLabel: TLabel;
    procedure ClearDivsGroup;
    procedure ViewDivsByteItemClick(Sender: TObject);
    procedure ViewDivsWordItemClick(Sender: TObject);
    procedure ViewDivsDWordItemClick(Sender: TObject);
    procedure ViewDivsQWordItemClick(Sender: TObject);
    procedure ViewDivsNoneItemClick(Sender: TObject);

    procedure ClearOffsetGroup;
    procedure ViewOffsetHexItemClick(Sender: TObject);
    procedure ViewOffsetDecItemClick(Sender: TObject);
    procedure ViewOffsetNoneItemClick(Sender: TObject);

    procedure ClearCharSetGroup;
    procedure ViewCharSetASCII7ItemClick(Sender: TObject);
    procedure ViewCharSetASCII8ItemClick(Sender: TObject);
    procedure ViewCharSetWindowsItemClick(Sender: TObject);
    procedure ViewCharSetMaskItemClick(Sender: TObject);

    procedure ViewConvBigEndianItemClick(Sender: TObject);
    procedure ViewConvSignedItemClick(Sender: TObject);

    procedure SearchGotoItemClick(Sender: TObject);
    procedure HexEditStateChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InfoPanelResize(Sender: TObject);
  private
    procedure WMGetMinMaxInfo(var MSG: Tmessage); message WM_GetMinMaxInfo;
  public
    procedure HexEdit(Sender: TObject);
  end;

var
  HexForm: THexForm;

implementation

{$R *.DFM}
uses
  Main, Analyze, ChunkSpecs;

var
  Chunk: TChunk;

procedure THexForm.HexEdit(Sender: TObject);
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  Analyzer.InputFile.DumpFile(TempDir+'\temp.srb',Chunk.Offset,Chunk.Size);

  if Chunk.FName<>'' then
    Caption:='HexView - '+Chunk.FName
  else
    Caption:='HexView - '+ChunkSpec[Chunk.Typ].Name;

  SpecHexEdit.LoadFromFile(TempDir+'\temp.srb');
  ShowModal;
end;

procedure THexForm.HexEditStateChanged(Sender: TObject);
var
  Offs: cardinal;
  RByte: byte;
  RWord: word;
  RDWord: cardinal;
begin
  Offs:=SpecHexEdit.GetCursorPos;
  StatusBar.Panels[0].Text:='Block Offset: '+ValueString(Offs);
  Offs:=SpecHexEdit.GetCursorPos+Chunk.Offset;
  StatusBar.Panels[1].Text:='File Offset: '+ValueString(Offs);
  RByte:=Analyzer.InputFile.ReadByte(Offs);
  if not ViewConvBigEndianItem.Checked then
  begin
    RWord:=Analyzer.InputFile.ReadInvWord(Offs);
    RDWord:=Analyzer.InputFile.ReadInvDWord(Offs);
  end
  else
  begin
    RWord:=Analyzer.InputFile.ReadWord(Offs);
    RDWord:=Analyzer.InputFile.ReadDWord(Offs);
  end;
  HexLabel.Caption:=format('%8x %17x %33x',[RByte,RWord,RDWord]);
  BinLabel.Caption:=format('%8s %17s %33s',[inttobin(RByte,8),inttobin(RWord,16),inttobin(RDWord,32)]);
  if ViewConvSignedItem.Checked then
    DecLabel.Caption:=format('%8d %17d %33d',[ShortInt(RByte),SmallInt(RWord),LongInt(RDWord)])
  else
    DecLabel.Caption:=format('%8d %17d %33d',[DWORD(RByte),DWORD(RWord),DWORD(RDWord)]);
end;

procedure THexForm.ClearDivsGroup;
begin
  ViewDivsByteItem.Checked:=false;
  ViewDivsWordItem.Checked:=false;
  ViewDivsDWordItem.Checked:=false;
  ViewDivsQWordItem.Checked:=false;
  ViewDivsNoneItem.Checked:=false;
end;

procedure THexForm.ViewDivsByteItemClick(Sender: TObject);
begin
  ClearDivsGroup;
  ViewDivsByteItem.Checked:=true;
  SpecHexEdit.BytesPerColumn:=1;
end;

procedure THexForm.ViewDivsWordItemClick(Sender: TObject);
begin
  ClearDivsGroup;
  ViewDivsWordItem.Checked:=true;
  SpecHexEdit.BytesPerColumn:=2;
end;

procedure THexForm.ViewDivsDWordItemClick(Sender: TObject);
begin
  ClearDivsGroup;
  ViewDivsDWordItem.Checked:=true;
  SpecHexEdit.BytesPerColumn:=4;
end;

procedure THexForm.ViewDivsQWordItemClick(Sender: TObject);
begin
  ClearDivsGroup;
  ViewDivsQWordItem.Checked:=true;
  SpecHexEdit.BytesPerColumn:=8;
end;

procedure THexForm.ViewDivsNoneItemClick(Sender: TObject);
begin
  ClearDivsGroup;
  ViewDivsNoneItem.Checked:=true;
  SpecHexEdit.BytesPerColumn:=16;
end;

procedure THexForm.ClearOffsetGroup;
begin
  ViewOffsetHexItem.Checked:=false;
  ViewOffsetDecItem.Checked:=false;
  ViewOffsetNoneItem.Checked:=false;
end;

procedure THexForm.ViewOffsetHexItemClick(Sender: TObject);
begin
  ClearOffsetGroup;
  ViewOffsetHexItem.Checked:=true;
  SpecHexEdit.OffsetDisplay:=odHex;
end;

procedure THexForm.ViewOffsetDecItemClick(Sender: TObject);
begin
  ClearOffsetGroup;
  ViewOffsetDecItem.Checked:=true;
  SpecHexEdit.OffsetDisplay:=odDec;
end;
procedure THexForm.ViewOffsetNoneItemClick(Sender: TObject);
begin
  ClearOffsetGroup;
  ViewOffsetNoneItem.Checked:=true;
  SpecHexEdit.OffsetDisplay:=odNone;
end;

procedure THexForm.ClearCharSetGroup;
begin
  ViewCharSetASCII7Item.Checked:=false;
  ViewCharSetASCII8Item.Checked:=false;
  ViewCharSetWindowsItem.Checked:=false;
end;

procedure THexForm.ViewCharSetASCII7ItemClick(Sender: TObject);
begin
  ClearCharSetGroup;
  ViewCharSetASCII7Item.Checked:=true;
  SpecHexEdit.Translation:=ttASCII;
end;

procedure THexForm.ViewCharSetASCII8ItemClick(Sender: TObject);
begin
  ClearCharSetGroup;
  ViewCharSetASCII8Item.Checked:=true;
  SpecHexEdit.Translation:=ttDOS8;
end;

procedure THexForm.ViewCharSetWindowsItemClick(Sender: TObject);
begin
  ClearCharSetGroup;
  ViewCharSetWindowsItem.Checked:=true;
  SpecHexEdit.Translation:=ttANSI;
end;

procedure THexForm.ViewCharSetMaskItemClick(Sender: TObject);
begin
  ViewCharSetMaskItem.Checked:=not ViewCharSetMaskItem.Checked;
  SpecHexEdit.MaskWhiteSpaces:=not SpecHexEdit.MaskWhiteSpaces;
end;

procedure THexForm.ViewConvBigEndianItemClick(Sender: TObject);
begin
  ViewConvBigEndianItem.Checked:=not ViewConvBigEndianItem.Checked;
  if ViewConvBigEndianItem.Checked then
    StatusBar.Panels[2].Text:='BE'
  else
    StatusBar.Panels[2].Text:='LE';
  HexEditStateChanged(Self);
end;

procedure THexForm.ViewConvSignedItemClick(Sender: TObject);
begin
  ViewConvSignedItem.Checked:=not ViewConvSignedItem.Checked;
  if ViewConvSignedItem.Checked then
    StatusBar.Panels[3].Text:='S'
  else
    StatusBar.Panels[3].Text:='';
  HexEditStateChanged(Self);
end;

procedure THexForm.SearchGotoItemClick(Sender: TObject);
begin
  if GotoDialog.ShowModal=42 then
    SpecHexEdit.Seek(GotoDialog.Offset,soFromBeginning,false);
end;

procedure THexForm.FormCreate(Sender: TObject);
begin
end;

procedure THexForm.InfoPanelResize(Sender: TObject);
begin
  SpecHexEdit.Height:=InfoPanel.Height-60;
  HexLabel.Top:=SpecHexEdit.Height+4;
  DecLabel.Top:=SpecHexEdit.Height+20;
  BinLabel.Top:=SpecHexEdit.Height+36;
  HexTitleLabel.Top:=SpecHexEdit.Height+4;
  DecTitleLabel.Top:=SpecHexEdit.Height+20;
  BinTitleLabel.Top:=SpecHexEdit.Height+36;
end;

procedure THexForm.WMGetMinMaxInfo(var Msg: TMessage);
Begin
  inherited;
  with PMinMaxInfo(Msg.lParam)^ do
  begin
    ptMinTrackSize.X := 576;
    ptMinTrackSize.Y := 200;
  end;
end;

end.
