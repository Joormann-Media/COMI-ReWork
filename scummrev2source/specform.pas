unit SpecForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, AdvSplitter, Analyze, ChunkSpecs, Grids, Tables, strlib,
  MPlayer, ImagDec, Menus, Clipbrd, Boxes{, ZSTRDec}, TabListBox;

const
  EmptySpace = 4;

type
  TImageInfo = record
    Size : TPoint;
    CompStuff: cardinal;
    NoOfImages: cardinal;
    NoOfPalettes: cardinal;
  end;
  TSpecInfoForm = class(TForm)
    ImageSplitter: TAdvSplitter;
    ImageInfoSplitter: TAdvSplitter;
    ImageInfoGroupBox: TGroupBox;
    P1TitleLabel: TLabel;
    P2TitleLabel: TLabel;
    P3TitleLabel: TLabel;
    P4TitleLabel: TLabel;
    P1Label: TLabel;
    P2Label: TLabel;
    P3Label: TLabel;
    P4Label: TLabel;
    Param1TitleLabel: TLabel;
    Param2TitleLabel: TLabel;
    Param3TitleLabel: TLabel;
    Param4TitleLabel: TLabel;
    Param5TitleLabel: TLabel;
    Param1Label: TLabel;
    Param2Label: TLabel;
    Param3Label: TLabel;
    Param4Label: TLabel;
    Param5Label: TLabel;
    ImageScrollBox: TScrollBox;
    Spec1Image: TImage;
    Spec1Image16Bit: TImage;
    Spec1Image24Bit: TImage;
    ImageListBox: TListBox;
    SpecInfoSaveDialog: TSaveDialog;
    SpecInfoListBox: TTabsListBox;
    SpecInfoRichEdit: TRichEdit;
    SpecInfoMediaPlayer: TMediaPlayer;
    MainMenu: TMainMenu;
    FileItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    FileCloseItem: TMenuItem;
    EditItem: TMenuItem;
    EditCopyItem: TMenuItem;
    ViewItem: TMenuItem;
    ViewProjectItem: TMenuItem;
    ViewZBufferItem: TMenuItem;
    ViewZoomItem: TMenuItem;
    ViewZoom50Item: TMenuItem;
    ViewZoom100Item: TMenuItem;
    ViewZoom200Item: TMenuItem;
    ImagesItem: TMenuItem;
    PalettesItem: TMenuItem;
    PalettesAmigaItem: TMenuItem;
    PalettesNextItem: TMenuItem;
    PalettesPrevItem: TMenuItem;
    BoxViewer: TBoxViewer;

    procedure ImageSplitterResize(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileCloseItemClick(Sender: TObject);
    procedure ViewProjectItemClick(Sender: TObject);
    procedure ViewZBufferItemClick(Sender: TObject);
    procedure CopyImage(Sender: TObject);
    procedure ViewZoom50ItemClick(Sender: TObject);
    procedure ViewZoom100ItemClick(Sender: TObject);
    procedure ViewZoom200ItemClick(Sender: TObject);
    procedure ChangeImageItemClick(Sender: TObject);
    procedure ChangeMATImageItemClick(Sender: TObject);
    procedure ChangePaletteItemClick(Sender: TObject);
    procedure PalettesAmigaItemClick(Sender: TObject);
  private
    { Private declarations }
    procedure HideItems;
    procedure FitFormToImage(Image: TImage);
    function DecodeImage(ImageDecoder: TImageDecoder): boolean;
    procedure DecodeMAT(ImageNo: cardinal);
  public
    { Public declarations }
    ImageNo : cardinal;
    PaletteNo: cardinal;
    ImageType: TImageType;
    procedure SaveAsVOC(Sender: TObject);
    procedure SaveAsMID(Sender: TObject);
    procedure PlayMID(Sender: TObject);
    procedure ViewBoxes(Sender: TObject);
    function GetImageInfo: TImageInfo;
    procedure ViewIMAGImage(Sender: TObject);
    procedure ViewBOMPImage(Sender: TObject);
    procedure ViewBM(Sender: TObject);
    procedure ViewBMInfo(Sender: TObject);
    procedure ViewOFFS(Sender: TObject);
    procedure ViewPalette(Sender: TObject);
    procedure ChooseCMP(Sender: TObject);
    procedure ViewCMP(Sender: TObject);
    procedure ViewMAT(Sender: TObject);
    procedure ViewBMP(Sender: TObject);
    procedure ViewMCMP(Sender: TObject);
    procedure ViewCOMP(Sender: TObject);
    procedure ViewLOFF(Sender: TObject);
    procedure ASMDecomp(StartOffs: cardinal; EndOffs: cardinal);
    procedure DecompileGRIM(Sender: TObject);
    procedure DecompileCMI(Sender: TObject);
    procedure DecompressIMC2WAV(Sender: TObject);
    procedure SaveiMUS2WAV(Sender: TObject);
    procedure DecompressIMX2WAV(Sender: TObject);
    procedure PlayVOC(Sender: TObject);
    procedure PlayIMC(Sender: TObject);
    procedure PlayIMU(Sender: TObject);
    procedure PlayIMX(Sender: TObject);
    procedure PlayiMUS(Sender: TObject);
    procedure PlayWAV(Sender: TObject);
    function SaveCompiMUS(OutputFileName: string): boolean;
    function SaveUnCompiMUS(OutputFileName: string): boolean;
    procedure DecompressIMC(OutputFileName: string);
    procedure SaveVOCtoWAV(Sender: TObject);
    procedure SaveVOCasWAV(OutputFileName: string);
    procedure SaveIMU(OutputFileName: string);
    procedure SaveIMU2WAV(Sender: TObject);
    procedure SaveWAV(Sender: TObject);
    procedure ViewText(Sender: TObject);
    procedure DecryptRCNE(Sender: TObject);

    procedure ChooseBox(Sender: TObject);
    procedure SaveImage(Sender: TObject);
    procedure SaveText(Sender: TObject);
    procedure CopyText(Sender: TObject);
    procedure PaletteListChange(Sender: TObject);
    procedure PaletteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure ImageKeyPress(Sender: TObject; var Key: char);

    procedure OpCodePrint(Op: TOpCode);
    function ParameterPrint(Op: TOpCode; DecLoc: cardinal): cardinal;
    function StringPrint(Op: TOpCode; DecLoc: cardinal): cardinal;
    procedure WMGetMinMaxInfo(var MSG: Tmessage); message WM_GetMinMaxInfo;
  end;

var
  SpecInfoForm: TSpecInfoForm;

implementation

{$R *.DFM}

uses
  Main, GifImage, DFSStatusBar, LECHUCK, Unlua;

procedure TSpecInfoForm.HideItems;
var
  n : cardinal;
begin
  if ModalResult<>0 then
  begin
    ImageSplitter.Pane2Setting.Visible:=true;
    ImageSplitter.Hide;
    Spec1Image.Hide;
    Spec1Image24Bit.Hide;
    Spec1Image16Bit.Hide;
    ImageSplitter.AllowResize:=true;
    ImageInfoSplitter.Pane2Setting.Visible:=false;
    Spec1Image.Stretch:=false;
    SpecInfoListBox.Hide;
    SpecInfoRichEdit.Hide;
    FileSaveAsItem.Visible:=false;
    EditItem.Visible:=false;
    EditCopyItem.Enabled:=false;
    ViewItem.Visible:=false;
    ViewProjectItem.Visible:=false;
    ViewProjectItem.Checked:=false;
    ViewZBufferItem.Checked:=false;
    ViewZBufferItem.Visible:=false;
    ViewZoomItem.Visible:=false;
    ViewZoom50Item.Checked:=false;
    ViewZoom100Item.Checked:=true;
    ViewZoom200Item.Checked:=false;
    ImagesItem.Visible:=false;
    PalettesItem.Visible:=false;
    if ImagesItem.Count>0 then
    begin
      for n:=0 to ImagesItem.Count-1 do
      begin
        ImagesItem.Items[0].Free;
      end;
    end;
    if PalettesItem.Count>1 then
    begin
      for n:=0 to PalettesItem.Count-2 do
      begin
        PalettesItem.Items[0].Free;
      end;
    end;
    EditCopyItem.OnClick:=nil;
    FileSaveAsItem.OnClick:=nil;
    if BoxViewer<>nil then
    begin
      BoxViewer.Free;
      BoxViewer:=nil;
    end;
    Param3Label.Hide;
    Param4Label.Hide;
    Param5Label.Hide;
    Param3TitleLabel.Hide;
    Param4TitleLabel.Hide;
    Param5TitleLabel.Hide;
    OnKeyPress:=nil;
    ImageListBox.OnClick:=nil;
    Spec1Image24Bit.OnMouseDown:=nil;
  end;
end;

procedure TSpecInfoForm.FitFormToImage(Image: TImage);
begin
    if Image.Width>Screen.Width-16 then
    begin
      Left:=8;
      Width:=Screen.Width-16;
    end
    else
    begin
      ClientWidth:=Image.Width+EmptySpace;
      Left:=(Screen.Width - Width) div 2
    end;


    if Image.Height>Screen.Height-32 then
    begin
      Top:=4;
      Height:=Screen.Height-32;
    end
    else
    begin
      ClientHeight:=Image.Height+EmptySpace;
      Top:=(Screen.Height - Height) div 2
    end;
end;

procedure TSpecInfoForm.ViewBoxes(Sender: TObject);
var
  Chunk: TChunk;
  Count: cardinal;
  BoxList: TList;
  BoxNo: cardinal;
  PointNo: byte;
  ParamNo: byte;
  MaxX: longint;
  MaxY: longint;
  RMHDOffs: longint;
  SMAPOffs: longint;
  CRect: TRect;
  ParChunk: TChunk;
  ChunkSize: cardinal;
  ImageDecoder: TImageDecoder;
  P : array[0..4] of TPoint;
  Params: TParams;
  SplitPos: cardinal;
begin
  ParChunk:=MainForm.ExplorerTreeView.Selected.Parent.Data;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  ImageListBox.Clear;
  BoxViewer:=TBoxViewer.Create;
  if Chunk.Typ=ctBOXD then
  begin
    Count:=Analyzer.InputFile.ReadInvWord(Chunk.Offset+8);
    if Chunk.Size>Count*20+10 then
    begin //Doubleword
      for BoxNo:=0 to Count-1 do
      begin
        ImageListBox.Items.Add('Box '+inttostr(BoxNo));

        for PointNo:=0 to 3 do
        begin
          P[PointNo].X:=longint(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+BoxNo*52+12+PointNo*8));
          P[PointNo].Y:=longint(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+BoxNo*52+16+PointNo*8));
        end;
        for ParamNo:=0 to 4 do
        begin
          Params[ParamNo]:=longint(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+BoxNo*52+44+ParamNo*4));
        end;
        BoxViewer.NoOfParams:=5;
        BoxViewer.AddBox(P[0],P[1],P[2],P[3], Params);
      end;
    end
    else
    begin //Word
      for BoxNo:=0 to Count-1 do
      begin
        ImageListBox.Items.Add('Box '+inttostr(BoxNo));

        for PointNo:=0 to 3 do
        begin
          P[PointNo].X:=smallint(Analyzer.InputFile.ReadInvWord(Chunk.Offset+BoxNo*20+10+PointNo*4));
          P[PointNo].Y:=smallint(Analyzer.InputFile.ReadInvWord(Chunk.Offset+BoxNo*20+12+PointNo*4));
        end;
        for ParamNo:=0 to 1 do
        begin
          Params[ParamNo]:=0;
          Params[ParamNo]:=smallint(Analyzer.InputFile.ReadInvWord(Chunk.Offset+BoxNo*20+26+ParamNo*2));
        end;
        BoxViewer.NoOfParams:=2;
        BoxViewer.AddBox(P[0],P[1],P[2],P[3], Params);
      end;
    end;
  end
  else
  begin  // MI1 format
    Count:=Analyzer.InputFile.ReadByte(Chunk.Offset+6);
    for BoxNo:=0 to Count-1 do
    begin
      ImageListBox.Items.Add('Box '+inttostr(BoxNo));

      for PointNo:=0 to 3 do
      begin
        P[PointNo].X:=smallint(Analyzer.InputFile.ReadInvWord(Chunk.Offset+BoxNo*20+7+PointNo*4));
        P[PointNo].Y:=smallint(Analyzer.InputFile.ReadInvWord(Chunk.Offset+BoxNo*20+9+PointNo*4));
      end;
      for ParamNo:=0 to 1 do
      begin
        Params[ParamNo]:=smallint(Analyzer.InputFile.ReadInvWord(Chunk.Offset+BoxNo*20+23+ParamNo*2));
      end;
      BoxViewer.NoOfParams:=2;
      BoxViewer.AddBox(P[0],P[1],P[2],P[3], Params);
    end;
  end;

  MaxX:=0;
  MaxY:=0;
  for BoxNo:=1 to BoxViewer.BoxList.Count - 1 do // Exclude 'weird' box
  begin
    with PBox(BoxViewer.BoxList.Items[BoxNo])^ do
      for PointNo:=0 to 3 do
      begin
        begin
          if P[PointNo].X > MaxX then
            MaxX:=P[PointNo].X;
          if P[PointNo].Y > MaxY then
            MaxY:=P[PointNo].Y;
        end;
      end;
  end;

  ImageSplitter.Align:=alClient;
  RMHDOffs:=Analyzer.InputFile.FindBlock('RMHD',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
  if RMHDOffs=-1 then
  begin
    RMHDOffs:=Analyzer.InputFile.FindBlock('HD',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
    if RMHDOffs=-1 then
    begin
      Spec1Image.Picture.Bitmap.Width:=MaxX+20;
      Spec1Image.Picture.Bitmap.Height:=MaxY+20;
      Spec1Image.Width:=MaxX+20;
      Spec1Image.Height:=MaxY+20;
    end
    else
    begin
      Spec1Image.Picture.Bitmap.Width:=Analyzer.InputFile.ReadInvWord(RMHDOffs+2);
      Spec1Image.Picture.Bitmap.Height:=Analyzer.InputFile.ReadInvWord(RMHDOffs+4);
    end;
  end
  else
  begin
    if Chunk.Size<=Count*20+10 then
    begin
      ChunkSize:=Analyzer.InputFile.ReadDWord(RMHDOffs+4);
      if ChunkSize <> 18 then
      begin
        Spec1Image.Picture.Bitmap.Width:=Analyzer.InputFile.ReadInvWord(RMHDOffs+8);
        Spec1Image.Picture.Bitmap.Height:=Analyzer.InputFile.ReadInvWord(RMHDOffs+10);
      end
      else
      begin
        Spec1Image.Picture.Bitmap.Width:=Analyzer.InputFile.ReadInvWord(RMHDOffs+12);
        Spec1Image.Picture.Bitmap.Height:=Analyzer.InputFile.ReadInvWord(RMHDOffs+14);
      end;
    end
    else
    begin
      Spec1Image.Picture.Bitmap.Width:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+12);
      Spec1Image.Picture.Bitmap.Height:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+16);
      BoxViewer.CompStuff:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+28);
    end;
  end;

  Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width;
  Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height;

  Left:=8;
  if Spec1Image.Width>Screen.Width-(ImageSplitter.Pane2Setting.MinSize+ImageSplitter.Thickness+16) then
  begin
    ClientWidth:=Screen.Width-16;
  end
  else
  begin
    ClientWidth:=Spec1Image.Width+ImageSplitter.Pane2Setting.MinSize+ImageSplitter.Thickness+EmptySpace+1;
    Left:=(Screen.Width - Width) div 2
  end;

  Spec1Image.Canvas.Brush.Color:=clWhite;
  Spec1Image.Canvas.FillRect(Rect(0,0,Spec1Image.Width,Spec1Image.Height));

  ImageListBox.ItemIndex:=0;
  ChooseBox(Self);

  BoxViewer.DrawBoxes;
  BoxViewer.Pulsing:=false;

  ImageScrollBox.HorzScrollBar.Position:=0;
  ImageScrollBox.VertScrollBar.Position:=0;
  FileSaveAsItem.Visible:=true;
  FileSaveAsItem.OnClick:=SaveImage;
  EditCopyItem.OnClick:=CopyImage;
  ImageListBox.OnClick:=ChooseBox;

  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  ViewItem.Visible:=true;
  ImageInfoSplitter.Pane2Setting.Visible:=true;

  Spec1Image.Show;
  ImageSplitter.Show;
  ImageInfoSplitter.Show;
  SplitPos:=ImageListBox.ItemRect(ImageListBox.Items.Count-1).Bottom+ImageInfoSplitter.Thickness+1;
  If BoxViewer.NoOfParams = 5 then
  begin
    ImageInfoSplitter.Pane2Setting.MinSize:=Param5Label.Top+Param5Label.Height+3;
    ClientHeight:=SplitPos+ImageInfoSplitter.Thickness+1+Param5Label.Top+Param5Label.Height+3;
  end
  else
  begin
    ImageInfoSplitter.Pane2Setting.MinSize:=Param2Label.Top+Param2Label.Height+3;
    ClientHeight:=SplitPos+ImageInfoSplitter.Thickness+1+Param2Label.Top+Param2Label.Height+3;
  end;

  Top:=4;
  if (Height>Screen.Height-32) then
  begin
    Height:=Screen.Height-32;
  end;

  if (Spec1Image.Height>ClientHeight) then
  begin
    if Spec1Image.Height>Screen.Height-32 then
    begin
      Top:=4;
      Height:=Screen.Height-32;
    end
    else
    begin
      ClientHeight:=Spec1Image.Height+EmptySpace;
      Top:=(Screen.Height - Height) div 2
    end;
  end;

  ImageInfoSplitter.Position:=SplitPos;

  ViewProjectItem.Visible:=true;
  if BoxViewer.NoOfParams = 5 then
  begin
    Param3Label.Show;
    Param4Label.Show;
    Param5Label.Show;
    Param3TitleLabel.Show;
    Param4TitleLabel.Show;
    Param5TitleLabel.Show;
  end;

  ImageSplitter.Position:=ClientWidth-(ImageSplitter.Pane2Setting.MinSize+ImageSplitter.Thickness+1);

  Caption:='Boxes';
  ShowModal;
  HideItems;
end;

function TSpecInfoForm.GetImageInfo: TImageInfo;
var
  Chunk: TChunk;
  ParChunk: TChunk;
  RMHDOffs: longint;
  ChunkSize: cardinal;
  PALSOffs: longint;
  PALSEnd: longint;
begin
  result.Size.X:=0;
  result.Size.Y:=0;
  result.CompStuff:=0;
  result.NoOfImages:=0;
  result.NoOfPalettes:=1;
  PALSOffs:=-1;
  PALSEnd:=-1;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  if MainForm.ExplorerTreeView.Selected.Parent<>nil then
    ParChunk:=MainForm.ExplorerTreeView.Selected.Parent.Data
  else
    ParChunk:=nil;

  // GF
  if (Chunk.Typ=fctBM) then
  begin
    result.CompStuff:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+8);
    result.NoOfImages:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+16);
    result.Size.X:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+128);
    result.Size.Y:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+132);
    result.NoOfPalettes:=0;
    exit;
  end;

  // Object Images
  if (Chunk.Typ=ctOBIM) then
  begin
    RMHDOffs:=Analyzer.InputFile.FindBlock('IMHD',Chunk.Offset, Chunk.Offset+Chunk.Size);
    if Analyzer.InputFile.ReadInvWord(RMHDOffs+8)=730 then
      result.NoOfImages:=Analyzer.InputFile.ReadInvWord(RMHDOffs+14)
    else
      result.NoOfImages:=Analyzer.InputFile.ReadInvWord(RMHDOffs+10);
    result.Size.X:=Analyzer.InputFile.ReadInvWord(RMHDOffs+20);
    result.Size.Y:=Analyzer.InputFile.ReadInvWord(RMHDOffs+22);

    // Get No. of palettes
    if ParChunk<>nil then
    begin
      PALSOffs:=Analyzer.InputFile.FindBlock('PALS',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
      if PALSOffs<>-1 then
      begin
        PALSEnd:=PALSOffs+Analyzer.InputFile.ReadDWord(PALSOffs+4);
        PALSOffs:=Analyzer.InputFile.FindBlock('APAL',PALSOffs,PALSEnd);
      end;
    end;
  end;

  if ParChunk=nil then
    Exit;

  // Mid Age Rooms
  if (Chunk.Typ=ctRMIM) then
  begin
    RMHDOffs:=Analyzer.InputFile.FindBlock('RMHD',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
    if RMHDOffs<>-1 then
    begin
      ChunkSize:=Analyzer.InputFile.ReadDWord(RMHDOffs+4);
      if ChunkSize <=14 then
      begin
        result.Size.X:=Analyzer.InputFile.ReadInvWord(RMHDOffs+8);
        result.Size.Y:=Analyzer.InputFile.ReadInvWord(RMHDOffs+10);
      end
      else
      begin
        result.Size.X:=Analyzer.InputFile.ReadInvWord(RMHDOffs+12);
        result.Size.Y:=Analyzer.InputFile.ReadInvWord(RMHDOffs+14);
      end;
    end;
    PALSOffs:=Analyzer.InputFile.FindBlock('PALS',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
    if PALSOffs<>-1 then
    begin
      PALSEnd:=PALSOffs+Analyzer.InputFile.ReadDWord(PALSOffs+4);
      PALSOffs:=Analyzer.InputFile.FindBlock('APAL',PALSOffs,PALSEnd);
    end;
  end;

  // CMI Rooms
  if (Chunk.Typ=ctIMAG) then
  begin
    if ParChunk.Typ=ctOBIM then
    begin
      RMHDOffs:=Analyzer.InputFile.FindBlock('IMHD',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
      if RMHDOffs<>-1 then
      begin
        result.Size.X:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+64);
        result.Size.Y:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+68);
        result.NoOfImages:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+52);
        ParChunk:=ParChunk.Node.Parent.Data;
        PALSOffs:=Analyzer.InputFile.FindBlock('PALS',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
      end;
    end
    else
    begin
      RMHDOffs:=Analyzer.InputFile.FindBlock('RMHD',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
      if RMHDOffs<>-1 then
      begin
        result.Size.X:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+12);
        result.Size.Y:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+16);
        result.CompStuff:=Analyzer.InputFile.ReadInvDWord(RMHDOffs+28);
        PALSOffs:=Analyzer.InputFile.FindBlock('PALS',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
      end;
    end;
    if PALSOffs<>-1 then
    begin
      PALSEnd:=PALSOffs+Analyzer.InputFile.ReadDWord(PALSOffs+4);
      PALSOffs:=Analyzer.InputFile.FindBlock('APAL',PALSOffs,PALSEnd);
    end;
  end;

  // Old Rooms
  if (Chunk.Typ=ctBM) then
  begin
    RMHDOffs:=Analyzer.InputFile.FindBlock('HD',ParChunk.Offset, ParChunk.Offset+ParChunk.Size);
    if RMHDOffs<>-1 then
    begin
      result.Size.X:=Analyzer.InputFile.ReadInvWord(RMHDOffs+2);
      result.Size.Y:=Analyzer.InputFile.ReadInvWord(RMHDOffs+4);
    end;
  end;
  if (PALSOffs<>-1) and (PALSEnd<>-1) then
  begin
    repeat
      PALSOffs:=Analyzer.InputFile.FindBlock('APAL',PALSOffs+1,PALSEnd);
      if PALSOffs<>-1 then
        Inc(result.NoOfPalettes);
    until PALSOffs=-1;
  end;
end;

function TSpecInfoForm.DecodeImage(ImageDecoder: TImageDecoder): boolean;
var
  Chunk: TChunk;
  OFFSOffs: longint;
  n: cardinal;
begin
  result:=true;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  // Find OFFS within BSTR
  OFFSOffs:=-1;
  case Chunk.Typ of
      ctRMIM  : begin
                  OFFSOffs:=Analyzer.InputFile.FindBlock('SMAP',Chunk.Offset, Chunk.Offset+Chunk.Size);
                end;
      ctOBIM  : begin
                  If (ImageNo=0) then
                    ImageNo:=1;
                  OFFSOffs:=Analyzer.InputFile.FindBlock('IM'+inttohex(ImageNo,2),Chunk.Offset,Chunk.Offset+Chunk.Size);
                  OFFSOffs:=Analyzer.InputFile.FindBlock('SMAP',OFFSOffs, Chunk.Offset+Chunk.Size);
                  if OFFSOffs=-1 then
                  begin
                    OFFSOffs:=Analyzer.InputFile.FindBlock('IM'+inttohex(ImageNo,2),Chunk.Offset,Chunk.Offset+Chunk.Size);
                    OFFSOffs:=Analyzer.InputFile.FindBlock('BOMP',OFFSOffs, Chunk.Offset+Chunk.Size);
                    ImageDecoder.ImageType:=itBOMP;
                  end;
                end;
      ctIMAG  : begin
                  OFFSOffs:=Analyzer.InputFile.FindBlock('BSTR',Chunk.Offset, Chunk.Offset+Chunk.Size);
                  if OFFSOffs=-1 then
                  begin
                    OFFSOffs:=Analyzer.InputFile.FindBlock('BOMP',Chunk.Offset,Chunk.Offset+Chunk.Size);
                    if ImageNo>1 then
                    begin
                      for n:=2 to ImageNo do
                      begin
                        OFFSOffs:=Analyzer.InputFile.FindBlock('BOMP',OFFSOffs+1, Chunk.Offset+Chunk.Size);
                      end;
                    end;
                    ImageDecoder.ImageType:=itBOMP;
                  end
                  else
                  begin
                    if ImageNo>1 then
                    begin
                      for n:=2 to ImageNo do
                      begin
                        OFFSOffs:=Analyzer.InputFile.FindBlock('BSTR',OFFSOffs+1, Chunk.Offset+Chunk.Size);
                      end;
                    end;
                    OFFSOffs:=Analyzer.InputFile.FindBlock('OFFS',OFFSOffs,Chunk.Offset+Chunk.Size);
                    ImageDecoder.ImageType:=itImage;
                  end;
                end;
      ctBM    : OFFSOffs:=Chunk.Offset;
      fctBM   : begin
                  OFFSOffs:=Chunk.Offset+136;
                  if ImageNo=0 then ImageNo:=1;
                  if ImageNo>1 then
                  begin
                    for n:=2 to ImageNo do
                    begin
                      OFFSOffs:=OFFSOffs+ImageDecoder.Image.Width*ImageDecoder.Image.Height*2+8;
                      ImageDecoder.Image.Width:=Analyzer.InputFile.ReadInvDWord(OFFSOffs-8);
                      ImageDecoder.Image.Height:=Analyzer.InputFile.ReadInvDWord(OFFSOffs-4);
                    end;
                  end;
                  ImageDecoder.ImageType:=itBM;
                end;
  end;
  ImageType:=ImageDecoder.ImageType;
  if OFFSOffs=-1 then
  begin
    MessageDlg('Unknown image format!',mtError,[mbOK],0);
    Exit;
  end;

  ImageDecoder.PaletteNo:=PaletteNo;
  case Chunk.Typ of
    ctRMIM,
    ctOBIM,
    ctIMAG  : begin
                if ImageDecoder.ImageType=itBOMP then
                begin
                  if Chunk.Typ=ctIMAG then
                  begin
                    if not ImageDecoder.Decode(OFFSOffs+16,OFFSOffs) then
                    begin
                      result:=false;
                      Exit;
                    end
                  end
                  else
                  begin
                    if not ImageDecoder.Decode(OFFSOffs+18,OFFSOffs) then
                    begin
                      result:=false;
                      Exit;
                    end;
                  end;
                end
                else
                begin
                  if not ImageDecoder.Decode(OFFSOffs+8,OFFSOffs) then begin result:=false; Exit; end;
                end;
              end;
    ctBM    : if not ImageDecoder.Decode(OFFSOffs+10,OFFSOffs+6) then begin result:=false; Exit; end;
    fctBM   : if not ImageDecoder.Decode(OFFSOffs,OFFSOffs) then begin result:=false; Exit; end;
  end;
end;

{procedure TSpecInfoForm.DecodeZSTR(ZSTRDecoder: TZSTRDecoder);
var
  Chunk: TChunk;
  OFFSOffs: longint;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  // Find OFFS within BSTR
  OFFSOffs:=-1;
  case Chunk.Typ of
      ctRMIM  : begin
                  OFFSOffs:=Analyzer.InputFile.FindBlock('ZP'+inttohex(ZSTRNo,2),Chunk.Offset, Chunk.Offset+Chunk.Size);
                end;
      ctOBIM  : begin
                  If (ImageNo=0) then
                    ImageNo:=1;
                  OFFSOffs:=Analyzer.InputFile.FindBlock('IM'+inttohex(ImageNo,2),Chunk.Offset,Chunk.Offset+Chunk.Size);
                  OFFSOffs:=Analyzer.InputFile.FindBlock('ZP'+inttohex(ZSTRNo,2),OFFSOffs, Chunk.Offset+Chunk.Size);
                end;
  end;
  if OFFSOffs=-1 then
  begin
    MessageDlg('Unknown image format!',mtError,[mbOK],0);
    Exit;
  end;

  case Chunk.Typ of
    ctRMIM,
    ctOBIM,
    ctIMAG  : if not ZSTRDecoder.Decode(OFFSOffs+8,OFFSOffs) then Exit;
    ctBM    : if not ZSTRDecoder.Decode(OFFSOffs+10,OFFSOffs+6) then Exit;
  end;
end;}

procedure TSpecInfoForm.ViewIMAGImage(Sender: TObject);
var
  ImageDecoder: TImageDecoder;
  ImageInfo: TImageInfo;
  n: cardinal;
  ImagesNewItem: TMenuItem;
begin
  MainForm.Status(0,'Decompressing Image...');
  MainForm.Update;
  Screen.Cursor:=crHourGlass;
  try
    ImageInfo:=GetImageInfo;
    if ImageInfo.Size.X=0 then
    begin
      MessageDlg('Room width = 0 or no width found. Cannot decompress image.',mtError,[mbOK],0);
      Exit;
    end;
    Spec1Image.Picture.Bitmap.Width:=ImageInfo.Size.X;
    Spec1Image.Picture.Bitmap.Height:=ImageInfo.Size.Y;
    Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width;
    Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height;
    Spec1Image.Canvas.Brush.Color:=clWhite;
    Spec1Image.Canvas.FillRect(Rect(0,0,Spec1Image.Width,Spec1Image.Height));

    ImageDecoder:=TImageDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y,ImageInfo.CompStuff);
    try
      ImageNo:=0;
      PaletteNo:=1;
      if not DecodeImage(ImageDecoder) then Exit;
      Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image);
    finally
      ImageDecoder.Free;
    end;

    ImageSplitter.Align:=alClient;
    ImageSplitter.Pane2Setting.Visible:=false;
    Spec1Image.Show;
    ImageSplitter.Show;

    FitFormToImage(Spec1Image);

    Caption:='Image';
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
  end;
  FileSaveAsItem.Visible:=true;
  FileSaveAsItem.OnClick:=SaveImage;
  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  EditCopyItem.OnClick:=CopyImage;
  ViewItem.Visible:=true;
  ViewZoomItem.Visible:=true;
//  ViewZBufferItem.Visible:=true;
  OnKeyPress:=ImageKeyPress;
  ImageInfo:=GetImageInfo;
  if ImageInfo.NoOfImages>1 then
  begin
    for n:=1 to ImageInfo.NoOfImages do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Image '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangeImageItemClick;
      ImagesItem.Add(ImagesNewItem);
    end;
    ImagesItem.Visible:=true;
    ImagesItem.Items[0].Checked:=true;
  end;
  if ImageInfo.NoOfPalettes>1 then
  begin
    for n:=ImageInfo.NoOfPalettes downto 1 do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Palette '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangePaletteItemClick;
      PalettesItem.Add(ImagesNewItem);
      ImagesNewItem.MenuIndex:=0;
    end;
    PalettesItem.Items[0].Checked:=true;
  end;
  PalettesItem.Visible:=true;
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewBOMPImage(Sender: TObject);
var
  ImageDecoder: TImageDecoder;
  ImageInfo: TImageInfo;
  n: cardinal;
  ImagesNewItem: TMenuItem;
begin
  MainForm.Status(0,'Decompressing Image...');
  MainForm.Update;
  Screen.Cursor:=crHourGlass;
  try
    ImageInfo:=GetImageInfo;
    if ImageInfo.Size.X=0 then
    begin
      MessageDlg('Room width = 0 or no width found. Cannot decompress image.',mtError,[mbOK],0);
      Exit;
    end;
    Spec1Image.Picture.Bitmap.Width:=ImageInfo.Size.X;
    Spec1Image.Picture.Bitmap.Height:=ImageInfo.Size.Y;
    Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width;
    Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height;
    Spec1Image.Canvas.Brush.Color:=clWhite;
    Spec1Image.Canvas.FillRect(Rect(0,0,Spec1Image.Width,Spec1Image.Height));

    ImageDecoder:=TImageDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y,ImageInfo.CompStuff);
    try
      ImageNo:=0;
      PaletteNo:=1;
      if not DecodeImage(ImageDecoder) then Exit;
      Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image);
    finally
      ImageDecoder.Free;
    end;

    ImageSplitter.Align:=alClient;
    ImageSplitter.Pane2Setting.Visible:=false;
    Spec1Image.Show;
    ImageSplitter.Show;

    FitFormToImage(Spec1Image);

    Caption:='Image';
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
  end;
  FileSaveAsItem.Visible:=true;
  FileSaveAsItem.OnClick:=SaveImage;
  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  EditCopyItem.OnClick:=CopyImage;
  ViewItem.Visible:=true;
  ViewZoomItem.Visible:=true;
//  ViewZBufferItem.Visible:=true;
  OnKeyPress:=ImageKeyPress;
  ImageInfo:=GetImageInfo;
  if ImageInfo.NoOfImages>1 then
  begin
    for n:=1 to ImageInfo.NoOfImages do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Image '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangeImageItemClick;
      ImagesItem.Add(ImagesNewItem);
    end;
    ImagesItem.Visible:=true;
    ImagesItem.Items[0].Checked:=true;
  end;
  if ImageInfo.NoOfPalettes>1 then
  begin
    for n:=ImageInfo.NoOfPalettes downto 1 do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Palette '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangePaletteItemClick;
      PalettesItem.Add(ImagesNewItem);
      ImagesNewItem.MenuIndex:=0;
    end;
    PalettesItem.Items[0].Checked:=true;
  end;
  PalettesItem.Visible:=true;
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewBM(Sender: TObject);
var
  ImageInfo: TImageInfo;
  ImageDecoder: TImageDecoder;
  n: cardinal;
  ImagesNewItem: TMenuItem;
begin
  MainForm.Status(0,'Decompressing Image...');
  MainForm.Update;
  Screen.Cursor:=crHourGlass;
  try
    ImageInfo:=GetImageInfo;
    if ImageInfo.Size.X=0 then
    begin
      MessageDlg('Room width = 0 or no width found. Cannot decompress image.',mtError,[mbOK],0);
      Exit;
    end;
    Spec1Image16Bit.Picture.Bitmap.Width:=ImageInfo.Size.X;
    Spec1Image16Bit.Picture.Bitmap.Height:=ImageInfo.Size.Y;
    Spec1Image16Bit.Width:=Spec1Image16Bit.Picture.Bitmap.Width;
    Spec1Image16Bit.Height:=Spec1Image16Bit.Picture.Bitmap.Height;
    Spec1Image16Bit.Canvas.Brush.Color:=clWhite;
    Spec1Image16Bit.Canvas.FillRect(Rect(0,0,Spec1Image16Bit.Width,Spec1Image16Bit.Height));

    ImageDecoder:=TImageDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y,ImageInfo.CompStuff);
    try
      ImageNo:=0;
      PaletteNo:=1;
      if not DecodeImage(ImageDecoder) then Exit;
      Spec1Image16Bit.Picture.Bitmap.Assign(ImageDecoder.Image);
    finally
      ImageDecoder.Free;
    end;

    ImageSplitter.Align:=alClient;
    ImageSplitter.Pane2Setting.Visible:=false;
    Spec1Image16Bit.Show;
    ImageSplitter.Show;

    FitFormToImage(Spec1Image16Bit);

    Caption:='Image';
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
  end;
  FileSaveAsItem.Visible:=true;
  FileSaveAsItem.OnClick:=SaveImage;
  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  EditCopyItem.OnClick:=CopyImage;
  ViewItem.Visible:=true;
  ViewZoomItem.Visible:=true;
  OnKeyPress:=ImageKeyPress;
  ImageInfo:=GetImageInfo;
  if ImageInfo.NoOfImages>1 then
  begin
    for n:=1 to ImageInfo.NoOfImages do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Image '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangeImageItemClick;
      ImagesItem.Add(ImagesNewItem);
    end;
    ImagesItem.Visible:=true;
    ImagesItem.Items[0].Checked:=true;
  end;
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewBMInfo(Sender: TObject);
var
  Chunk: TChunk;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;

  SpecInfoListBox.Clear;
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+4)));
  SpecInfoListBox.Items.Add('Compression Type?: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+8)));
  SpecInfoListBox.Items.Add('Palette Included: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+12)));
  SpecInfoListBox.Items.Add('Number of Images: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+16)));
  SpecInfoListBox.Items.Add('X Position: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+20)));
  SpecInfoListBox.Items.Add('Y Position: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+24)));
  SpecInfoListBox.Items.Add('Transparent Color: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+28)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+32)));
  SpecInfoListBox.Items.Add('Bits per Pixel: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+36)));
  SpecInfoListBox.Items.Add('Blue Bits: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+40)));
  SpecInfoListBox.Items.Add('Green Bits: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+44)));
  SpecInfoListBox.Items.Add('Red Bits: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+48)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+52)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+56)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+60)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+64)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+68)));
  SpecInfoListBox.Items.Add('Unknown: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+72)));
  SpecInfoListBox.Items.Add('Width: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+128)));
  SpecInfoListBox.Items.Add('Height: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+132)));
  if Analyzer.InputFile.ReadInvDWord(Chunk.Offset+8)=3 then
    SpecInfoListBox.Items.Add('Compressed Size: '^I+ValueString(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+136)));
  SpecInfoListBox.Show;
  SpecInfoListBox.Align:=alClient;
  Caption:='Image Info';
  ShowModal;
  HideItems;
end;

{procedure TSpecInfoForm.ViewZSTRImage(Sender: TObject);
var
  ImageInfo: TImageInfo;
  ZSTRDecoder: TZStrDecoder;
  ImagesNewItem: TMenuItem;
  n: cardinal;
begin
  MainForm.Status(0,'Decoding Z-Buffer...');
  MainForm.Update;
  Screen.Cursor:=crHourGlass;
  try
    ImageInfo:=GetImageInfo;
    Spec1Image.Picture.Bitmap.Width:=ImageInfo.Size.X;
    Spec1Image.Picture.Bitmap.Height:=ImageInfo.Size.Y;
    Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width;
    Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height;
    Spec1Image.Canvas.Brush.Color:=clBlack;
    Spec1Image.Canvas.FillRect(Rect(0,0,Spec1Image.Width,Spec1Image.Height));

    ZSTRDecoder:=TZSTRDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y);
    try
      ImageNo:=0;
      ZSTRNo:=1;
      DecodeZSTR(ZSTRDecoder);
      Spec1Image.Picture.Bitmap.Assign(ZSTRDecoder.Image);
    finally
      ZSTRDecoder.Free;
    end;

    ImageSplitter.Align:=alClient;
    ImageSplitter.Pane2Setting.Visible:=false;
    Spec1Image.Show;
    ImageSplitter.Show;

    FitFormToImage(Spec1Image);

    Caption:='Image';
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
  end;
  //FileSaveAsItem.Visible:=true;
  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  EditCopyItem.OnClick:=CopyImage;
  ViewItem.Visible:=true;
  ViewZoomItem.Visible:=true;
  OnKeyPress:=ImageKeyPress;
  ImageInfo:=GetImageInfo;
  if ImageInfo.NoOfImages>1 then
  begin
    for n:=1 to ImageInfo.NoOfImages do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Image '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangeImageItemClick;
      ImagesItem.Add(ImagesNewItem);
    end;
    ImagesItem.Visible:=true;
    ImagesItem.Items[0].Checked:=true;
  end;
  ShowModal;
  HideItems;
end;}

procedure TSpecInfoForm.ViewOFFS(Sender: TObject);
var
  Chunk: TChunk;
  ChunkSize: cardinal;
  n: cardinal;
  CurrOffs: cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  ChunkSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+4);
  if ChunkSize<12 then Exit;
  SpecInfoListBox.Clear;
  For n:=0 to ((ChunkSize-8) div 4) - 1 do
  begin
    CurrOffs:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+8+n*4);
    SpecInfoListBox.Items.Add(Format('Offset %3d: %18s',[n,ValueString(CurrOffs)]));
  end;
  SpecInfoListBox.Align:=alClient;
  SpecInfoListBox.Show;
  Left:=60;
  Top:=50;
  Width:=500;
  Height:=400;
  Caption:='Offsets';

  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.PlayMID(Sender: TObject);
var
  Chunk: TChunk;
  Offset: cardinal;
  Size: cardinal;
begin
  SpecInfoMediaPlayer.Close;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  Offset:=Chunk.Offset+8;
  while Analyzer.InputFile.ReadDWord(Offset)<>$4D546864 do
  begin
    Offset:=Offset+8+Analyzer.InputFile.ReadDWord(Offset+4);
  end;
  Size:=Chunk.Size-(Offset-Chunk.Offset);
  Analyzer.InputFile.DumpFile(TempDir+'\temp.mid',Offset,Size);
  SpecInfoMediaPlayer.FileName:=TempDir+'\temp.mid';
  SpecInfoMediaPlayer.Open;
  SpecInfoMediaPlayer.Play;
end;

procedure TSpecInfoForm.SaveAsMID(Sender: TObject);
var
  OutputFileName: string;
  Chunk: TChunk;
  Offset: cardinal;
  Size: cardinal;
begin
  SpecInfoSaveDialog.Filter:='Standard MIDI file Format 2 (*.mid)|*.MID';
  SpecInfoSaveDialog.Title:='Save as .MID...';
  SpecInfoSaveDialog.FileName:='.mid';
  If SpecInfoSaveDialog.Execute then
  begin
    OutputFileName := ForceExtension(SpecInfoSaveDialog.FileName,'.mid');
    MainForm.Status(0,'Saving MIDI...');
    MainForm.Update;

    Chunk:=MainForm.ExplorerTreeView.Selected.Data;
    Offset:=Chunk.Offset+8;
    while Analyzer.InputFile.ReadDWord(Offset)<>$4D546864 do
    begin
      Offset:=Offset+8+Analyzer.InputFile.ReadDWord(Offset+4);
    end;

    Size:=Chunk.Size-(Offset-Chunk.Offset);
    Analyzer.InputFile.DumpFile(OutputFileName,Offset,Size);
    MainForm.Status(0,' ');
  end;
end;

procedure TSpecInfoForm.SaveAsVOC(Sender: TObject);
var
  OutputFileName: string;
  Chunk: TChunk;
  Offset: cardinal;
  Size: cardinal;
begin
  SpecInfoSaveDialog.Filter:='Creative Voice File (*.voc)|*.voc';
  SpecInfoSaveDialog.Title:='Save as .VOC...';
  SpecInfoSaveDialog.FileName:='.voc';
  If SpecInfoSaveDialog.Execute then
  begin
    OutputFileName := ForceExtension(SpecInfoSaveDialog.FileName,'.voc');
    MainForm.Status(0,'Saving Creative Voice File...');
    MainForm.Update;

    Chunk:=MainForm.ExplorerTreeView.Selected.Data;
    case Chunk.Typ of
      ctCrea :  begin
                  Offset:=Chunk.Offset;
                  Size:=Chunk.Size;
                end;
      ctVTLK :  begin
                  Offset:=Chunk.Offset+8;
                  Size:=Chunk.Size-8;
                end;
      else
      begin
        Offset:=Chunk.Offset;
        Size:=Chunk.Size;
      end;
    end;
    Analyzer.InputFile.DumpFile(OutputFileName,Offset,Size);
    MainForm.Status(0,' ');
  end;
end;

procedure TSpecInfoForm.SaveVOCToWAV(Sender: TObject);
var
  OutputFileName: string;
begin
  MainForm.SaveDialog.Filter:='Windows RIFF Wave (.wav)|*.wav';
  MainForm.SaveDialog.Title:='Save as...';
  MainForm.SaveDialog.FileName:='.wav';
  If SpecInfoSaveDialog.Execute then
  begin
    OutputFileName := ForceExtension(SpecInfoSaveDialog.FileName,'.wav');
    MainForm.Status(0,'Saving Wave File...');
    MainForm.Update;

    SaveVOCAsWAV(OutputFileName);
    MainForm.Status(0,' ');
  end;
end;

procedure TSpecInfoForm.ViewPalette(Sender: TObject);
var
  Chunk: TChunk;
  RedC, GreenC, BlueC : byte;
  x,y                 : byte;
  Col                 : TColor;
  MaxColor            : cardinal;
  CurrCol             : cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;

  ImageListBox.Clear;
  ImageSplitter.Align:=alClient;
  Spec1Image24Bit.Picture.Bitmap.Width:=320;
  Spec1Image24Bit.Picture.Bitmap.Height:=320;
  Spec1Image24Bit.Width:=320;
  Spec1Image24Bit.Height:=320;
  Spec1Image24Bit.Canvas.Brush.Color:=clBlack;
  Spec1Image24Bit.Canvas.Pen.Color:=clBlack;
  Spec1Image24Bit.Canvas.FillRect(Rect(0,0,Spec1Image24Bit.Width,Spec1Image24Bit.Height));
  if (Chunk.Size<776) and (Chunk.Typ<>ctRGBS) then
  begin
    MessageDlg('Invalid colortable!',mtError,[mbOK],0);
    Exit;
  end;
  MaxColor:=((Chunk.Size-8) div 3)-1;
  CurrCol:=0;
  for y:=0 to 15 do
  begin
    for x:=0 to 15 do
    begin
      RedC:=Analyzer.InputFile.ReadByte(Chunk.Offset+8+y*48+x*3);
      GreenC:=Analyzer.InputFile.ReadByte(Chunk.Offset+8+1+y*48+x*3);
      BlueC:=Analyzer.InputFile.ReadByte(Chunk.Offset+8+2+y*48+x*3);
      Col:=RedC+GreenC*256+BlueC*65536;
      Spec1Image24Bit.Canvas.Brush.Color:=Col;
      Spec1Image24Bit.Canvas.Rectangle(x*20,y*20,x*20+20,y*20+20);
      ImageListBox.Items.Add(inttohex(CurrCol,2)+': ('+inttohex(RedC,2)+','+inttohex(GreenC,2)+','+inttohex(BlueC,2)+') ');
      Inc(CurrCol);
      if CurrCol>MaxColor then Break;
    end;
    if CurrCol>MaxColor then Break;
  end;
  ImageSplitter.Show;
  Spec1Image24Bit.Show;
  Caption:='Palette';
  ClientHeight:=324;
  ClientWidth:=ImageSplitter.Pane2Setting.MinSize+325+ImageSplitter.Thickness;
  ImageSplitter.Position:=324;
  ImageSplitter.AllowResize:=false;
  ImageListBox.OnClick:=PaletteListChange;
  Spec1Image24Bit.OnMouseDown:=PaletteImageMouseDown;
  ImageListBox.ItemIndex:=0;
  ImageListBox.Tag:=0;
//  FileSaveAsItem.Visible:=true;

  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.DecodeMAT(ImageNo: cardinal);
var
  PScan: PByteArray;
  Col, Row: cardinal;
  Offset: cardinal;
  Chunk: TChunk;
  NoOfImages: cardinal;
  Image: TBitmap;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  NoOfImages:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+12);
  Image:=TBitmap.Create;
  Image.Width:=Spec1Image.Picture.Bitmap.Width;
  Image.Height:=Spec1Image.Picture.Bitmap.Height;
  Image.Assign(Spec1Image.Picture.Bitmap);
  try
    Offset:=Chunk.Offset+100+NoOfImages*40+(Image.Width*Image.Height+24)*(ImageNo-1);
    for Row:=0 to Image.Height - 1 do
    begin
      PScan:=Image.Scanline[Row];
      for Col:=0 to Image.Width - 1 do
      begin
        PScan[Col]:=Analyzer.InputFile.ReadByte(Offset+Col+Row*Image.Width);
      end;
    end;
    Spec1Image.Picture.Bitmap.Assign(Image);
  finally
    Image.Free;
  end;
end;

procedure TSpecInfoForm.ViewMAT(Sender: TObject);
var
  Chunk: TChunk;
  NoOfImages: cardinal;
  n: cardinal;
  ImagesNewItem: TMenuItem;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  NoOfImages:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+12);
  ImageListBox.Clear;
  ImageSplitter.Align:=alClient;
  Spec1Image.Picture.Bitmap.Width:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+76+NoOfImages*40);
  Spec1Image.Picture.Bitmap.Height:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+80+NoOfImages*40);
  Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width;
  Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height;
  Spec1Image.Canvas.Brush.Color:=clWhite;
  Spec1Image.Canvas.Pen.Color:=clWhite;
  Spec1Image.Canvas.FillRect(Rect(0,0,Spec1Image.Width,Spec1Image.Height));

  DecodeMAT(1);

  if NoOfImages>1 then
  begin
    for n:=1 to NoOfImages do
    begin
      ImagesNewItem:=TMenuItem.Create(Self);
      ImagesNewItem.Caption:='Image '+inttohex(n,2);
      ImagesNewItem.OnClick:=ChangeMATImageItemClick;
      ImagesItem.Add(ImagesNewItem);
    end;
    ImagesItem.Visible:=true;
    ImagesItem.Items[0].Checked:=true;
  end;
  FileSaveAsItem.Visible:=true;
  FileSaveAsItem.OnClick:=SaveImage;
  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  EditCopyItem.OnClick:=CopyImage;
  ViewItem.Visible:=true;
  ViewZoomItem.Visible:=true;
  OnKeyPress:=ImageKeyPress;
  Spec1Image.Show;
  ImageSplitter.Pane2Setting.Visible:=false;
  ImageSplitter.Show;
  FitFormToImage(Spec1Image);
  Caption:='Material';
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ChooseCMP(Sender: TObject);
var
  Chunk: TChunk;
  LPalette: PLOGPALETTE;
  PalSize: word;
  PalHandle: HPALETTE;
  APALOffs: longint;
  n: byte;
  RedC: byte;
  GreenC: byte;
  BlueC: byte;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  PalSize:=SizeOf(TLOGPALETTE)+SizeOf(TPALETTEENTRY)*256;
  APALOffs:=Chunk.Offset+64;
  GetMem(LPalette,PalSize);
  try
    With LPalette^ do
    begin
      palVersion:=$0300;
      palNumEntries:=256;
    end;
    for n:=0 to 255 do
    begin
      RedC:=Analyzer.InputFile.ReadByte(APALOffs+n*3);
      GreenC:=Analyzer.InputFile.ReadByte(APALOffs+1+n*3);
      BlueC:=Analyzer.InputFile.ReadByte(APALOffs+2+n*3);
    {$R-}
      with LPalette.palPalEntry[n] do
      begin
        peRed:=RedC;
        peGreen:=GreenC;
        peBlue:=BlueC;
        peFlags:=PC_NOCOLLAPSE;
      end;
  {$R+}
    end;
    PalHandle:=CreatePalette(LPalette^);
  finally
    FreeMem(LPalette,PalSize);
    if APALOffs=-1 then
      MessageDlg('Palette not found.',mtError,[mbOK],0);
  end;
  Spec1Image.Picture.Bitmap.Palette:=PalHandle;
end;

procedure TSpecInfoForm.ViewCMP(Sender: TObject);
var
  Chunk: TChunk;
  RedC, GreenC, BlueC : byte;
  x,y                 : byte;
  Col                 : TColor;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;

  ImageListBox.Clear;
  ImageSplitter.Align:=alClient;
  Spec1Image24Bit.Picture.Bitmap.Width:=320;
  Spec1Image24Bit.Picture.Bitmap.Height:=320;
  Spec1Image24Bit.Width:=320;
  Spec1Image24Bit.Height:=320;
  Spec1Image24Bit.Canvas.Brush.Color:=clBlack;
  Spec1Image24Bit.Canvas.Pen.Color:=clBlack;
  Spec1Image24Bit.Canvas.FillRect(Rect(0,0,Spec1Image24Bit.Width,Spec1Image24Bit.Height));
  if Chunk.Size<832 then
  begin
    MessageDlg('Invalid colortable!',mtError,[mbOK],0);
    Exit;
  end;
  for y:=0 to 15 do
  begin
    for x:=0 to 15 do
    begin
      RedC:=Analyzer.InputFile.ReadByte(Chunk.Offset+64+y*48+x*3);
      GreenC:=Analyzer.InputFile.ReadByte(Chunk.Offset+64+1+y*48+x*3);
      BlueC:=Analyzer.InputFile.ReadByte(Chunk.Offset+64+2+y*48+x*3);
      Col:=RedC+GreenC*256+BlueC*65536;
      Spec1Image24Bit.Canvas.Brush.Color:=Col;
      Spec1Image24Bit.Canvas.Rectangle(x*20,y*20,x*20+20,y*20+20);
      ImageListBox.Items.Add(inttohex(y*16+x,2)+': ('+inttohex(RedC,2)+','+inttohex(GreenC,2)+','+inttohex(BlueC,2)+') ');
    end;
  end;
  Spec1Image24Bit.Show;
  ImageSplitter.Show;
  Caption:='Palette';
  ClientHeight:=324;
  ClientWidth:=ImageSplitter.Pane2Setting.MinSize+325+ImageSplitter.Thickness;
  ImageSplitter.Position:=324;
  ImageSplitter.AllowResize:=false;
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewBMP(Sender: TObject);
var
  Chunk: TChunk;
begin
  MainForm.Status(0,'Opening Image...');
  Screen.Cursor:=crHourGlass;
  try
    Chunk:=MainForm.ExplorerTreeView.Selected.Data;

    Analyzer.InputFile.DumpFile(TempDir+'\temp.bmp',Chunk.Offset,Chunk.Size);
    Spec1Image16Bit.Picture.LoadFromFile(TempDir+'\temp.bmp');
    Spec1Image16Bit.Width:=Spec1Image16Bit.Picture.Bitmap.Width;
    Spec1Image16Bit.Height:=Spec1Image16Bit.Picture.Bitmap.Height;
    ImageSplitter.Align:=alClient;
    ImageSplitter.Pane2Setting.Visible:=false;
    Spec1Image16Bit.Show;
    ImageSplitter.Show;
    ImageType:=itBM;
    FitFormToImage(Spec1Image16Bit);

    Caption:='Image';
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
  end;
  FileSaveAsItem.Visible:=true;
  FileSaveAsItem.OnClick:=SaveImage;
  EditItem.Visible:=true;
  EditCopyItem.Enabled:=true;
  EditCopyItem.OnClick:=CopyImage;
  ViewItem.Visible:=true;
  ViewZoomItem.Visible:=true;
  OnKeyPress:=ImageKeyPress;
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewLOFF(Sender: TObject);
var
  Chunk: TChunk;
  NoOfEntries: cardinal;
  CurrEntry: cardinal;
  RoomNo: cardinal;
  RoomOffs: cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  NoOfEntries:=Analyzer.InputFile.ReadByte(Chunk.Offset+8);
  SpecInfoListBox.Clear;
  for CurrEntry:=0 to NoOfEntries-1 do
  begin
    RoomNo:=Analyzer.InputFile.ReadByte(Chunk.Offset+9+CurrEntry*5);
    RoomOffs:=Analyzer.InputFile.ReadInvDWord(Chunk.Offset+10+CurrEntry*5);
    SpecInfoListBox.Items.Add(Format('Room %3d: %22s',[RoomNo,ValueString(RoomOffs)]));
  end;
  SpecInfoListBox.Align:=alClient;
  SpecInfoListBox.Show;
  Left:=60;
  Top:=50;
  Width:=500;
  Height:=400;
  Caption:='Room Offset List';
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewMCMP(Sender: TObject);
type
  TEntry = record
    CompSize: cardinal;
    DeCompSize: cardinal;
    Typ: byte;
  end;
var
  Chunk: TChunk;
  NoOfEntries: cardinal;
  Entry: Cardinal;
  CodecNo: cardinal;
  Codec: string;
  CompSize: cardinal;
  DecompSize: cardinal;
  CompOffset: cardinal;
  DecompOffset: cardinal;
  n: cardinal;
  CodecNameOffset: cardinal;
begin
  CompOffset:=0;
  DecompOffset:=0;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  NoOfEntries:=Analyzer.InputFile.ReadWord(Chunk.Offset+4);

  SpecInfoListBox.Clear;
  for Entry:=0 to NoOfEntries-1 do
  begin
    CodecNo:=Analyzer.InputFile.ReadByte(Chunk.Offset+6+9*Entry);
    CodecNameOffset:=Chunk.Offset+8+9*NoOfEntries+CodecNo*5;
    Codec:='';
    for n:=0 to 3 do
    begin
      Codec:=Codec+chr(Analyzer.InputFile.ReadByte(CodecNameOffset+n));
    end;
    DecompSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+6+9*Entry+1);
    CompSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+6+9*Entry+5);
    SpecInfoListBox.Items.Add(Format('%4d - %4s - Comp: %18s [%18s] - Decomp: %18s [%18s]',[Entry,Codec,ValueString(CompSize),ValueString(CompOffset),ValueString(DecompSize),ValueString(DecompOffset)]));
    CompOffset:=CompOffset+CompSize;
    DecompOffset:=DecompOffset+DecompSize;
  end;
  SpecInfoListBox.Align:=alClient;
  SpecInfoListBox.Show;
  Caption:='Compression Info';
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.ViewCOMP(Sender: TObject);
type
  TEntry = record
    CompSize: cardinal;
    DeCompSize: cardinal;
    Typ: byte;
  end;
var
  Chunk: TChunk;
  NoOfEntries: cardinal;
  LastOutputSize: cardinal;
  Entry: Cardinal;
  CodecNo: cardinal;
  CompSize: cardinal;
  CompOffset: cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  NoOfEntries:=Analyzer.InputFile.ReadDWord(Chunk.Offset+4);
  LastOutputSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+12);
  SpecInfoListBox.Clear;
  SpecInfoListBox.Items.Add(Format('Last block decompressed size: %18s',[ValueString(LastOutputSize)]));
  for Entry:=0 to NoOfEntries-1 do
  begin
    CodecNo:=Analyzer.InputFile.ReadDWord(Chunk.Offset+16*(Entry+1)+8);
    CompOffset:=Analyzer.InputFile.ReadDWord(Chunk.Offset+16*(Entry+1));
    CompSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+16*(Entry+1)+4);
    SpecInfoListBox.Items.Add(Format('%4d - Codec: %4d - CompOffset: %18s - CompSize: %18s',[Entry,CodecNo,ValueString(CompOffset),ValueString(CompSize)]));
  end;
  SpecInfoListBox.Align:=alClient;
  SpecInfoListBox.Show;
  Caption:='Compression Info';
  ShowModal;
  HideItems;
end;

function TSpecInfoForm.ParameterPrint(Op: TOpCode; DecLoc: cardinal): cardinal;
begin
  SpecInfoRichEdit.Lines.Add(OpCodeName[Op]+' '
    +IntToHex(Analyzer.InputFile.ReadByte(DecLoc+3),2)+' '
    +IntToHex(Analyzer.InputFile.ReadByte(DecLoc+2),2)+' '
    +IntToHex(Analyzer.InputFile.ReadByte(DecLoc+1),2)+' '
    +IntToHex(Analyzer.InputFile.ReadByte(DecLoc),2));
  result:=4;
end;

procedure TSpecInfoForm.OpCodePrint(Op: TOpCode);
begin
  SpecInfoRichEdit.Lines.Add(OpCodeName[Op]);
end;

function TSpecInfoForm.StringPrint(Op: TOpCode; DecLoc: cardinal): cardinal;
var
  RByte: byte;
  EndString: string;
  n: byte;
begin
  n:=0;
  repeat
    RByte:=Analyzer.InputFile.ReadByte(DecLoc+n);
    if RByte<>0 then
      EndString:=EndString+Chr(RByte);
    Inc(n);
  until RByte=0;
  SpecInfoRichEdit.Lines.Add(OpCodeName[Op]+' '+EndString);
  Result:=n
end;

procedure TSpecInfoForm.ASMDecomp(StartOffs: cardinal; EndOffs: cardinal);
var
  Op: TOpCode;
  Stuff: boolean;
  DecLoc: cardinal;
begin
  DecLoc:=StartOffs;
  Stuff:=false;
  repeat
    if Stuff then
    begin
      Op:=TOpCode(Analyzer.InputFile.ReadByte(DecLoc)+256);
      Stuff:=false;
    end
    else
      Op:=TOpCode(Analyzer.InputFile.ReadByte(DecLoc));
    case Op of
      O_PUSH_NUMBER     : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_PUSH_VARIABLE   : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_STORE_VARIABLE  : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_DEC_VARIABLE    : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_INC_VARIABLE    : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_JUMP            : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_IF_NOT          : DecLoc:=DecLoc+ParameterPrint(Op, DecLoc+1);
      O_HEAP_STUFF      : begin OpCodePrint(Op); Stuff:=true; end;
      O_ROOM_STUFF      : begin OpCodePrint(Op); Stuff:=true; end;
      O_ACTOR_STUFF     : begin OpCodePrint(Op); Stuff:=true; end;
      O_CAMERA_STUFF    : begin OpCodePrint(Op); Stuff:=true; end;
      O_VERB_STUFF      : begin OpCodePrint(Op); Stuff:=true; end;
      O_WAIT_FOR_STUFF  : begin OpCodePrint(Op); Stuff:=true; end;
      O_BLAST_TEXT      : begin OpCodePrint(Op); Stuff:=true; end;
      SO_PRINT_STRING   : DecLoc:=DecLoc+StringPrint(Op, DecLoc+1);
      O_SAY_LINE        : DecLoc:=DecLoc+StringPrint(Op, DecLoc+1);
      O_SAY_LINE_SIMPLE : DecLoc:=DecLoc+StringPrint(Op, DecLoc+1);
      O_PRINT_DEBUG     : DecLoc:=DecLoc+StringPrint(Op, DecLoc+1);
      O_PRINT_LINE      : DecLoc:=DecLoc+StringPrint(Op, DecLoc+1);
      O_NEW_NAME_OF     : DecLoc:=DecLoc+StringPrint(Op, DecLoc+1);
    else
      OpCodePrint(Op);
    end;
    Inc(DecLoc);
    MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=((DecLoc-StartOffs)*100) div (EndOffs-StartOffs);
  until (DecLoc>=EndOffs) or (Op=O_END_SCRIPT);
end;

procedure TSpecInfoForm.DecompileGRIM(Sender: TObject);
var
  Undumper: TUndumper;
  Chunk: TChunk;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  SpecInfoRichEdit.Align:=alClient;
  SpecInfoRichEdit.Clear;
  SpecInfoRichEdit.Show;
  Caption:='Decompiled Script';
  Undumper:=TUndumper.Create(Chunk.Offset);
  Undumper.Undump;
  Undumper.Free;
  SpecInfoForm.SpecInfoRichEdit.SelStart:=0;
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.DecompileCMI(Sender: TObject);
var
  Chunk: TChunk;
  ObjectNo: cardinal;
  CurrOffs: cardinal;
  ScriptOffs: cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  SpecInfoRichEdit.Align:=alClient;
  SpecInfoRichEdit.Clear;
  SpecInfoRichEdit.Show;
  Caption:='Decompiled Script';
  Screen.Cursor:=crHourGlass;
  MainForm.Status(0,'Decompiling Script...');
  MainForm.Update;
  try
    MainForm.Preferences.ASMDecomp:=true;
    case Chunk.Typ of
      ctSCRP,
      ctEXCD,
      ctENCD        : begin
                        if MainForm.Preferences.ASMDecomp then
                          ASMDecomp(Chunk.Offset+8,Chunk.Offset+Chunk.Size)
                        else
                          LECHUCKDecomp(Chunk.Offset+8);
                      end;
      ctLSCR        : begin
                        SpecInfoRichEdit.Lines.Add('Script Number '+inttostr(Analyzer.InputFile.ReadInvDWord(Chunk.Offset+8)));
                        if MainForm.Preferences.ASMDecomp then
                          ASMDecomp(Chunk.Offset+12,Chunk.Offset+Chunk.Size)
                        else
                          LECHUCKDecomp(Chunk.Offset+12);
                      end;
      ctVERB        : begin
                        CurrOffs:=Chunk.Offset+8;
                        repeat
                          ObjectNo:=Analyzer.InputFile.ReadInvDWord(CurrOffs);
                          if ObjectNo<>0 then
                          begin
                            case ObjectNo of
                              5 : SpecInfoRichEdit.Lines.Add('Default "Use With"?:');
                              6 : SpecInfoRichEdit.Lines.Add('"Look":');
                              7 : SpecInfoRichEdit.Lines.Add('"Use/Pick Up":');
                              8 : SpecInfoRichEdit.Lines.Add('"Talk/Taste":');
                              9 : SpecInfoRichEdit.Lines.Add('"Walk To"?:');
                            else
                              SpecInfoRichEdit.Lines.Add('Object '+inttostr(ObjectNo)+':');
                            end;
                            Inc(CurrOffs,4);
                            ScriptOffs:=Analyzer.InputFile.ReadInvDWord(CurrOffs);
                            if MainForm.Preferences.ASMDecomp then
                              ASMDecomp(Chunk.Offset+8+ScriptOffs,Chunk.Offset+Chunk.Size)
                            else
                              LECHUCKDecomp(Chunk.Offset+8+ScriptOffs);
                            SpecInfoRichEdit.Lines.Add('');
                            Inc(CurrOffs,4);
                          end;
                        until ObjectNo=0;
                      end;
    end;
    SpecInfoRichEdit.SelStart:=0;
    FileSaveAsItem.visible:=true;
    FileSaveAsItem.OnClick:=SaveText;
    EditCopyItem.Enabled:=true;
    EditItem.visible:=true;
    EditCopyItem.visible:=true;
    EditCopyItem.OnClick:=CopyText;
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
    MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
  end;
  ShowModal;
  HideItems;
end;

procedure WriteWAVHeader(OutputFile: TFileStream; DataSize, Channels, SampleRate, BitsPerSample: cardinal);
type
  THugeBuffer = array[0..$7FFFFFFF-1] of byte;
var
  Buffer: Pointer;
  BytesPerSec: cardinal;
  BlockAlign: cardinal;
begin
      Buffer:=AllocMem(44);
      THugeBuffer(Buffer^)[0]:=ord('R');
      THugeBuffer(Buffer^)[1]:=ord('I');
      THugeBuffer(Buffer^)[2]:=ord('F');
      THugeBuffer(Buffer^)[3]:=ord('F');
      THugeBuffer(Buffer^)[4]:=lo(DataSize+36);          // Size
      THugeBuffer(Buffer^)[5]:=lo((DataSize+36) shr 8);
      THugeBuffer(Buffer^)[6]:=lo((DataSize+36) shr 16);
      THugeBuffer(Buffer^)[7]:=lo((DataSize+36) shr 24);
      THugeBuffer(Buffer^)[8]:=ord('W');
      THugeBuffer(Buffer^)[9]:=ord('A');
      THugeBuffer(Buffer^)[10]:=ord('V');
      THugeBuffer(Buffer^)[11]:=ord('E');
      THugeBuffer(Buffer^)[12]:=ord('f');
      THugeBuffer(Buffer^)[13]:=ord('m');
      THugeBuffer(Buffer^)[14]:=ord('t');
      THugeBuffer(Buffer^)[15]:=ord(' ');
      THugeBuffer(Buffer^)[16]:=16;                   // fmt chunk size
      THugeBuffer(Buffer^)[17]:=0;
      THugeBuffer(Buffer^)[18]:=0;
      THugeBuffer(Buffer^)[19]:=0;
      THugeBuffer(Buffer^)[20]:=1;                    // wFormatTag
      THugeBuffer(Buffer^)[21]:=0;
      THugeBuffer(Buffer^)[22]:=lo(Channels);
      THugeBuffer(Buffer^)[23]:=hi(Channels);
      THugeBuffer(Buffer^)[24]:=lo(SampleRate);
      THugeBuffer(Buffer^)[25]:=lo(SampleRate shr 8);
      THugeBuffer(Buffer^)[26]:=lo(SampleRate shr 16);
      THugeBuffer(Buffer^)[27]:=lo(SampleRate shr 24);
      BytesPerSec:=Channels*SampleRate*(BitsPerSample div 8);
      THugeBuffer(Buffer^)[28]:=lo(BytesPerSec);
      THugeBuffer(Buffer^)[29]:=lo(BytesPerSec shr 8);
      THugeBuffer(Buffer^)[30]:=lo(BytesPerSec shr 16);
      THugeBuffer(Buffer^)[31]:=lo(BytesPerSec shr 24);
      BlockAlign:=Channels*(BitsPerSample div 8);
      THugeBuffer(Buffer^)[32]:=lo(BlockAlign);
      THugeBuffer(Buffer^)[33]:=hi(BlockAlign);
      THugeBuffer(Buffer^)[34]:=lo(BitsPerSample);
      THugeBuffer(Buffer^)[35]:=hi(BitsPerSample);
      THugeBuffer(Buffer^)[36]:=ord('d');
      THugeBuffer(Buffer^)[37]:=ord('a');
      THugeBuffer(Buffer^)[38]:=ord('t');
      THugeBuffer(Buffer^)[39]:=ord('a');
      THugeBuffer(Buffer^)[40]:=lo(DataSize);
      THugeBuffer(Buffer^)[41]:=lo(DataSize shr 8);
      THugeBuffer(Buffer^)[42]:=lo(DataSize shr 16);
      THugeBuffer(Buffer^)[43]:=lo(DataSize shr 24);

      OutputFile.Position:=0;
      OutputFile.Write(Buffer^,44);
      FreeMem(Buffer);
end;

procedure TSpecInfoForm.SaveIMU(OutputFileName: string);
type
  THugeBuffer = array[0..$7FFFFFFF-1] of byte;
var
  OutputFile: TFileStream;
  Chunk: TChunk;
  FRMTOffs: cardinal;
  DATAOffs: cardinal;
  DATASize: cardinal;
  Buffer: pointer;
  BufferPos: cardinal;
  BitsPerSample: cardinal;
  SampleRate: cardinal;
  Channels: cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  OutputFile:=TFileStream.Create(OutputFileName,fmCreate);

  MainForm.Status(0,'Creating WAV header...');
  FRMTOffs:=Analyzer.InputFile.FindBlock('FRMT',Chunk.Offset, Chunk.Offset+Chunk.Size);
  if FRMTOffs=-1 then
  begin
    BitsPerSample:=16;
    SampleRate:=22050;
    Channels:=2;
    MessageDlg('FRMT Block not found! Using standard format values.',mtWarning,[mbOK],0);
  end
  else
  begin
    BitsPerSample:=Analyzer.InputFile.ReadDWord(FRMTOffs+16);
    SampleRate:=Analyzer.InputFile.ReadDWord(FRMTOffs+20);
    Channels:=Analyzer.InputFile.ReadDWord(FRMTOffs+24);
  end;

  DATAOffs:=Analyzer.InputFile.FindBlock('DATA',Chunk.Offset, Chunk.Offset+Chunk.Size);
  DataSize:=Analyzer.InputFile.ReadDWord(DATAOffs+4);

  WriteWAVHeader(OutputFile,DataSize,Channels,SampleRate,BitsPerSample);

  Buffer:=AllocMem(DATASize);
  for BufferPos:=0 to DATASize - 1 do
  begin
    THugeBuffer(Buffer^)[BufferPos]:=Analyzer.InputFile.ReadByte(DATAOffs+8+BufferPos);
  end;
  OutputFile.Write(Buffer^,DATASize);

  FreeMem(Buffer);
  OutputFile.Free;
end;

procedure TSpecInfoForm.SaveVOCasWAV(OutputFileName: string);
type
  THugeBuffer = array[0..$7FFFFFFF-1] of byte;
var
  Chunk: TChunk;
  BitsPerSample: cardinal;
  SampleRate: cardinal;
  Channels: cardinal;
  DataSize: cardinal;
  OutputFile: TFileStream;
  Offset: cardinal;
  BlockType: byte;
  Buffer: Pointer;
  ChunkLength: cardinal;
  EndPos: cardinal;
  DestOffs: cardinal;
begin
  BitsPerSample:=8;
  SampleRate:=11111;
  Channels:=1;
  DataSize:=0;
  Screen.Cursor:=crHourGlass;
  OutputFile:=TFileStream.Create(OutputFileName,fmCreate);
  try
    MainForm.Status(0,'Creating WAV header...');

    WriteWAVHeader(OutputFile,DataSize,Channels,SampleRate,BitsPerSample);

    MainForm.Status(0,'Converting VOC to WAV...');
    Chunk:=MainForm.ExplorerTreeView.Selected.Data;
    Offset:=Chunk.Offset+Analyzer.InputFile.ReadInvWord(Chunk.Offset+$14);
    repeat
      BlockType:=Analyzer.InputFile.ReadByte(Offset);
      Inc(Offset);
      case BlockType of
         1 :  begin
                ChunkLength:=Analyzer.InputFile.ReadInvTriByte(Offset);
                EndPos:=Offset+ChunkLength+3;
                Dec(ChunkLength,2);
                GetMem(Buffer,ChunkLength);
                Inc(Offset,3);
                SampleRate:=1000000 div (256-Analyzer.InputFile.ReadByte(Offset));
                Inc(Offset,2);
                DestOffs:=0;
                repeat
                  THugeBuffer(Buffer^)[DestOffs]:=Analyzer.InputFile.ReadByte(Offset);
                  Inc(Offset);
                  Inc(DestOffs);
                  if (MainForm.Preferences.ShowProgress) and (DestOffs mod 2 = 0) then
                    MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=((Offset-Chunk.Offset) * 100) div Chunk.Size;
                until Offset=EndPos;
                OutputFile.Write(Buffer^,DestOffs);
                FreeMem(Buffer);
                Inc(DataSize,DestOffs-1);
              end;
         2 : Inc(Offset,Analyzer.InputFile.ReadInvTriByte(Offset)+3);
         3 : Inc(Offset,6);
         4 : Inc(Offset,5);
         5 : Inc(Offset,Analyzer.InputFile.ReadInvTriByte(Offset)+3);
         6 : Inc(Offset,5);
         8 : Inc(Offset,7);
      end;
    until BlockType = 0;
  finally
    Screen.Cursor:=crDefault;
    MainForm.Status(0,' ');
    MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
    OutputFile.Position:=0;
    WriteWAVHeader(OutputFile,DataSize,Channels,SampleRate,BitsPerSample);
    OutputFile.Free;
  end;
end;

procedure TSpecInfoForm.DecompressIMC(OutputFileName: string);
type
  PCompInfo = ^TCompInfo;
  TCompInfo = record
    codec: TCodec;
    CompSize: cardinal;
    DecompSize: cardinal;
  end;
  THugeBuffer = array[0..$7FFFFFFF-1] of byte;
var
  DestTablePos : longint;
  DestTableStartPos: longint;
  Incer: longint;
  TableValue: longint;
  Count: longint;
  Put: word;
  DestTable: array[0..5785] of word;

  SBytes  : array[0..3] of byte;
  SWords  : array[0..3] of word;
  SourcePos: longint;
  DestPos: longint;
  SBytesPos: longint;
  SWordsPos: longint;
  CurrTablePos: longint;
  DecLength: longint;
  DestOffs: longint;
  SWordsOffs: longint;
  SourceBuffer: pointer;
  EntrySize: cardinal;
  NoOfEntries: cardinal;
  TableEntry: cardinal;
  DestPos_SWordsPos: cardinal;
  DecsToDo: cardinal;
  DecsLeft:cardinal;
  BytesToDec: cardinal;
  CurrTableVal: cardinal;
  var40: cardinal;
  NoOfEntriesDeced: cardinal;
  OutputWord: longint;
  Disp: longint;

  FRMTOffs: longint;
  DATAOffs: longint;
  DATASize: cardinal;
  BitsPerSample: cardinal;
  SampleRate: cardinal;
  Channels: cardinal;
  BytesPerSec: cardinal;
  BlockAlign: cardinal;
  Chunk   : TChunk;
  NoOfCompEntries: cardinal;
  CompList: TList;
  CompInfo: PCompInfo;
  CodecNo: cardinal;
  CodecName: string;
  CodecPos: cardinal;
  CodecOffset: cardinal;
  n: cardinal;
  CurrSourcePos: cardinal;
  OutputFile: TFileStream;
  Buffer: pointer;
  BufferPos: cardinal;
  IMCTable1Pos: cardinal;
  PrevOffset: cardinal;
begin
  MainForm.Status(0,'Preparing VIMA decompression table...');
  Screen.Cursor:=crHourGlass;
  try
    DestTablePos:=0;
    DestTableStartPos:=0;
    Incer:=0;
    repeat
      //Label3
      IMCTable1Pos:=0;
      repeat
        TableValue:=IMCTable1[IMCTable1Pos];
        Count:=32;
        Put:=0;
        repeat
          if (Incer and Count) <> 0 then
          begin
            Put:=Put+TableValue;
          end;
          TableValue:=TableValue shr 1;
          Count:=Count shr 1;
        until Count=0;
        DestTable[DestTablePos]:=Put and $0000FFFF;
//        DestTable[DestTablePos]:=word(Put);
        Inc(IMCTable1Pos);
        Inc(DestTablePos,64);
      until IMCTable1Pos>=IMCTable1Size;
      Inc(Incer);
      Inc(DestTableStartPos);
      DestTablePos:=DestTableStartPos;
    until DestTableStartPos>=64;

    Chunk:=MainForm.ExplorerTreeView.Selected.Data;
    if Chunk.Typ=ctiMUS then
      Chunk:=MainForm.ExplorerTreeView.Selected.GetPrevSibling.Data;
    if (Chunk.Typ<>fctIMC) and (Chunk.Typ<>fctWAV) and (Chunk.Typ<>ctMCMP) then
    begin
      MessageDlg('MCMP Block not found. Can''t decompress!',mtError,[mbOK],0);
      Exit;
    end;


    MainForm.Status(0,'Processing compression map...');

    NoOfCompEntries:=Analyzer.InputFile.ReadWord(Chunk.Offset+4);
    CodecOffset:=Chunk.Offset+NoOfCompEntries*9+8;
    CompList:=TList.Create;
    for n:=0 to NoOfCompEntries - 1 do
    begin
      CompInfo:=PCompInfo(new(PCompInfo));
      CodecNo:=Analyzer.InputFile.ReadByte(Chunk.Offset+6+9*n);
      CodecName:='';
      for CodecPos:=CodecOffset+CodecNo*5 to CodecOffset+CodecNo*5+3 do
      begin
        CodecName:=CodecName+chr(Analyzer.InputFile.ReadByte(CodecPos));
      end;
      if CodecName = 'VIMA' then
        CompInfo^.Codec:=codecVIMA;
      if CodecName = 'NULL' then
        CompInfo^.Codec:=codecNULL;
      if (CodecName <> 'NULL') and (CodecName <> 'VIMA') then
        CompInfo^.Codec:=codecUnknown;
      CompInfo^.DecompSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+7+9*n);
      CompInfo^.CompSize:=Analyzer.InputFile.ReadDWord(Chunk.Offset+11+9*n);
      CompList.Add(CompInfo);
    end;
    CurrSourcePos:=CodecOffset+Analyzer.InputFile.ReadWord(CodecOffset-2);

    Chunk:=MainForm.ExplorerTreeView.Selected.Data;

    OutputFile:=TFileStream.Create(OutputFileName,fmCreate);

    if (Uppercase(ExtractFileExt(Chunk.FName))='.IMC') or (Chunk.Typ=ctiMUS) then
    begin
      MainForm.Status(0,'Creating WAV header...');
      FRMTOffs:=Analyzer.InputFile.FindBlock('FRMT',Chunk.Offset, Chunk.Offset+Chunk.Size);
      if FRMTOffs=-1 then
      begin
        BitsPerSample:=16;
        SampleRate:=22050;
        Channels:=2;
        MessageDlg('FRMT Block not found! Using standard format values.',mtWarning,[mbOK],0);
      end
      else
      begin
        BitsPerSample:=Analyzer.InputFile.ReadDWord(FRMTOffs+16);
        SampleRate:=Analyzer.InputFile.ReadDWord(FRMTOffs+20);
        Channels:=Analyzer.InputFile.ReadDWord(FRMTOffs+24);
      end;

      DATAOffs:=Analyzer.InputFile.FindBlock('DATA',Chunk.Offset, Chunk.Offset+Chunk.Size);
      DataSize:=Analyzer.InputFile.ReadDWord(DATAOffs+4);

      WriteWAVHeader(OutputFile,DataSize,Channels,SampleRate,BitsPerSample);
    end;

    MainForm.Status(0,'Decompressing...');

    try
    for n:=0 to CompList.Count-1 do
    begin
      if (MainForm.Preferences.ShowProgress) and (n mod 2 = 0) then
        MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=(n * 100) div CompList.Count;
      CompInfo:=CompList.Items[n];
      Buffer:=AllocMem(CompInfo^.DecompSize);
      case CompInfo^.Codec of
        codecNULL : begin
                      for BufferPos:=0 to CompInfo^.CompSize - 1 do
                      begin
                        THugeBuffer(Buffer^)[BufferPos]:=Analyzer.InputFile.ReadByte(CurrSourcePos+BufferPos);
                      end;
                    end;
        codecVIMA : begin
                      SourceBuffer:=AllocMem(CompInfo^.CompSize);
                      for BufferPos:=0 to CompInfo^.CompSize - 1 do
                      begin
                        THugeBuffer(SourceBuffer^)[BufferPos]:=Analyzer.InputFile.ReadByte(CurrSourcePos+BufferPos);
                      end;
                      DecLength:=CompInfo^.DecompSize;
                      DestOffs:=integer(Buffer);
                      asm
                        PUSH    esp
                        PUSH    ebp
                        PUSH    ebx
                        PUSH    esi
                        PUSH    edi

                        MOV     ecx,SourceBuffer
                        MOV     esi,1
                        MOV     al,[ecx]
                        INC     ecx
                        TEST    al,al
                        MOV     byte ptr SBytes[0],al
                        JGE     @ReadWords
                        NOT     al
                        MOV     byte ptr SBytes[0],al
                        MOV     esi,2

                        @ReadWords:
                        MOV     ax,[ecx]
                        XOR     edx,edx
                        MOV     dh,al
                        ADD     ecx,2
                        MOV     dl,ah
                        CMP     esi,1
                        MOV     word ptr SWords[0],dx
                        JBE     @OneWord
                        MOV     al,[ecx]
                        INC     ecx
                        MOV     byte ptr SBytes[1],al
                        XOR     edx,edx
                        MOV     ax,[ecx]
                        ADD     ecx,2
                        MOV     dh,al
                        MOV     dl,ah
                        MOV     word ptr SWords[2],dx

                        @OneWord:
                        MOV     eax,DecLength
                        MOV     CurrTablePos,1
                        MOV     EntrySize,esi
                        ADD     esi,esi
                        XOR     edx,edx
                        DIV     esi
                        MOV     DecsToDo,eax
                        MOV     SourcePos,ecx

                        XOR     ebx,ebx

                        MOV     eax,CurrTablePos
                        XOR     edi,edi
                        CMP     eax,edi
                        JNZ     @Label1
                        MOV     SBytes[1],0
                        MOV     SBytes[0],0
                        MOV     word ptr SWords[2],di
                        MOV     word ptr SWords[0],di

                        @Label1:
                        MOV     esi,SourcePos
                        MOV     edx,EntrySize
                        XOR     ecx,ecx
                        MOV     ch,[esi]
                        LEA     eax,[esi+1]
                        XOR     esi,esi
                        MOV     cl,[eax]
                        INC     eax
                        CMP     edx,edi
                        MOV     TableEntry,ecx
                        MOV     SourcePos,eax
                        MOV     SBytesPos,esi
                        JBE     @ExitMainDec
                        MOV     edi,DestOffs
                        LEA     eax,SWords
                        SUB     edi,eax
                        MOV     SWordsPos,eax
                        MOV     DestPos_SWordsPos,edi

                        @NextByte:
                        LEA     ecx,[edi+eax]
                        MOV     DestPos,ecx
                        MOVSX   ecx,byte ptr SBytes[esi]
                        MOV     CurrTablePos, ecx
                        MOVSX   ecx, word ptr [eax]
                        MOV     OutputWord,ecx
                        MOV     ecx,DecsToDo
                        TEST    ecx,ecx
                        JZ      @Done
                        ADD     edx,edx
                        MOV     DecsLeft,ecx
                        MOV     BytesToDec,edx

                        @NextDec:
                        MOV     eax,CurrTablePos
                        MOV     edx,1
                        MOV     cl,byte ptr IMCTable2[eax]
                        MOV     byte ptr CurrTableVal,cl
                        MOV     esi,CurrTableVal
                        AND     esi,$FF
                        ADD     ebx,esi
                        LEA     ecx,[esi-1]
                        MOV     DestOffs,ebx
                        SHL     edx,cl
                        MOV     cl,$10
                        SUB     cl,bl
                        MOV     al,dl
                        DEC     al
                        MOV     byte ptr var40,al
                        MOV     eax,TableEntry
                        MOV     edi,var40
                        AND     eax,$FFFF
                        SHR     eax,cl
                        AND     edi,$FF
                        MOV     ecx,edx
                        OR      ecx,edi
                        AND     eax,ecx
                        CMP     ebx,7
                        JLE     @Label2
                        MOV     ebx,SourcePos
                        XOR     ecx,ecx
                        MOV     ch,byte ptr TableEntry
                        MOVZX   bx,byte ptr [ebx]
                        OR      ecx,ebx
                        MOV     ebx,SourcePos
                        INC     ebx
                        MOV     TableEntry,ecx
                        MOV     SourcePos,ebx
                        MOV     ebx,DestOffs
                        SUB     ebx,8
                        MOV     DestOffs,ebx
                        JMP     @Label3

                        @Label2:
                        MOV     ecx,TableEntry

                        @Label3:
                        TEST    eax,edx
                        JZ      @ClearEDX
                        XOR     eax,edx
                        JMP     @NoClear

                        @ClearEDX:
                        XOR     edx,edx

                        @NoClear:
                        CMP     eax,edi
                        JNZ     @Label4
                        MOV     edx,ecx
                        MOV     ecx,ebx
                        SHL     edx,cl
                        MOV     ecx,SourcePos
                        MOVZX   di,byte ptr [ecx]
                        PUSH    ecx
                        //MOVSX  ebp,dx
                        MOVSX   ecx,dx
                        XOR     edx,edx
                        AND     ecx,$FFFFFF00
                        MOV     OutputWord,ecx
                        POP     ecx
                        MOV     dh,byte ptr TableEntry
                        OR      edx,edi
                        INC     ecx
                        MOV     SourcePos,ecx
                        MOV     cx,8
                        SUB     cx,bx
                        MOV     edi,edx
                        SHR     di,cl
                        XOR     ecx,ecx
                        MOV     ebx,DestOffs
                        MOV     ch,dl
                        MOV     edx,ecx
                        MOV     ecx,SourcePos
                        AND     edi,$FF
                        PUSH    ecx
                        // OR     ebp,edi
                        MOV     ecx,OutputWord
                        OR      ecx,edi
                        MOV     OutputWord,ecx
                        POP     ecx
                        MOVZX   di,byte ptr [ecx]

                        OR      edx,edi
                        INC     ecx
                        MOV     TableEntry,edx
                        MOV     SourcePos,ecx
                        JMP     @WriteDec

                        @Label4:
                        MOV     ecx,7
                        MOV     edi,eax
                        SUB     ecx,esi
                        SHL     edi,cl
                        MOV     ecx,CurrTablePos
                        SHL     ecx,6
                        OR      edi,ecx
                        XOR     ecx,ecx
                        TEST    eax,eax
                        MOV     cx,word ptr DestTable[edi*2]
                        MOV     DestOffs,ecx
                        JZ      @Label5
                        MOV     edi,CurrTablePos
                        XOR     ecx,ecx
                        MOV     cx,word ptr IMCTable1[edi*2]
                        MOV     edi,ecx
                        LEA     ecx,[esi-1]
                        SHR     edi,cl
                        MOV     ecx,DestOffs
                        ADD     ecx,edi

                        @Label5:
                        TEST    edx,edx
                        JZ      @Label6
                        NEG     ecx

                        @Label6:
                        MOV     edx,OutputWord
                        ADD     edx,ecx
                        CMP     edx,$FFFF8000
                        JGE     @Label7
                        MOV     edx,$FFFF8000
                        MOV     OutputWord,edx
                        JMP     @WriteDec

                        @Label7:
                        CMP     edx,$7FFF
                        MOV     OutputWord,edx
                        JLE     @WriteDec
                        MOV     edx,$7FFF
                        MOV     OutputWord,edx

                        @WriteDec:
                        MOV     ecx,DestPos
                        MOV     edx,BytesToDec
                        PUSH    eax
                        MOV     eax,OutputWord
                        MOV     [ecx],ax
                        ADD     ecx,edx
                        MOV     edx,dword ptr Offsets[esi*4]
                        MOV     DestPos,ecx
                        MOV     ecx,CurrTablePos
                        POP     eax
                        MOVSX   eax,byte ptr [edx+eax]
                        ADD     ecx,eax
                        MOV     CurrTablePos,ecx
                        JNS     @Label8
                        MOV     CurrTablePos,0
                        JMP     @Done

                        @Label8:
                        MOV     ecx,CurrTablePos
                        MOV     eax,$58
                        CMP     ecx,eax
                        JLE     @Done
                        MOV     CurrTablePos,eax

                        @Done:
                        MOV     eax,DecsLeft
                        DEC     eax
                        MOV     DecsLeft,eax
                        JNZ     @NextDec
                        MOV     edx,EntrySize
                        MOV     esi,SBytesPos
                        MOV     eax,SWordsPos
                        MOV     edi,DestPos_SWordsPos
                        MOV     cl,byte ptr CurrTablePos
                        ADD     eax,2
                        MOV     byte ptr SBytes[esi],cl
                        PUSH    ebx
                        MOV     ebx,OutputWord
                        MOV     [eax-2],bx
                        POP     ebx
                        INC     esi
                        MOV     SWordsPos,eax
                        CMP     esi,edx
                        MOV     SBytesPos,esi
                        JB      @NextByte

                        @ExitMainDec:
                        POP     edi
                        POP     esi
                        POP     ebx
                        POP     ebp
                        POP     esp
                      end;
                      FreeMem(SourceBuffer);
                    end;
      end;
      Inc(CurrSourcePos,CompInfo^.CompSize);
      if (n>0) or (UpperCase(ExtractFileExt(Chunk.FName))='.WAV') then
        OutputFile.Write(Buffer^,CompInfo^.DecompSize);
      FreeMem(Buffer);
    end;
    finally
      OutputFile.Free;
    end;

    for n:=0 to CompList.Count-1 do
    begin
      CompInfo:=CompList.Items[n];
      Dispose(CompInfo);
    end;
    CompList.Free;
  finally
    MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
    MainForm.Status(0,' ');
    Screen.Cursor:=crDefault;
  end;
end;

function TSpecInfoForm.SaveCOMPiMUS(OutputFileName: string): boolean;
type
  PCompInfo = ^TCompInfo;
  TCompInfo = record
    codec: TCodec;
    CompOffs: cardinal;
    CompSize: cardinal;
  end;
  THugeBuffer = array[0..$7FFFFFFF-1] of byte;
var
  DestTablePos : longint;
  DestTable2Pos: longint;
  DestTableStartPos: longint;
  Incer: longint;
  TableValue: longint;
  Count: longint;
  Put: word;
  PutD: dword;
  DestTable: array[0..92] of byte;
  DestTable2: array[0..5696] of dword;
  COMPOffset: longint;
  FirstWord: word;

  SByte  : array[0..3] of byte;
  SDWord  : array[0..3] of dword;
  ReadWord: word;
  DecompTable: byte;
  CurrTableEntry: byte;
  ReadPos: cardinal;
  SourcePos: longint;
  DestPos: longint;
  StartPos: longint;
  Channel: longint;
  OtherTablePos: byte;
  ESIReg: longint;
  Adder: longint;
  SBytesPos: longint;
  SWordsPos: longint;
  CurrTablePos: shortint;
  DecLength: longint;
  DestOffs: longint;
  SWordsOffs: longint;
  SourceBuffer: pointer;
  EntrySize: cardinal;
  EBPReg: longint;
  NoOfEntriesLeft: cardinal;
  NoOfWordsLeft: cardinal;
  TableEntry: cardinal;
  TableEntrySum: longint;
  DestPos_SWordsPos: cardinal;
  DecsToDo: cardinal;
  DecsLeft:cardinal;
  BytesToDec: cardinal;
  CurrTableVal: cardinal;
  var_3B: byte;
  var_36: word;
  var40: cardinal;
  NoOfEntriesDeced: cardinal;
  OutputWord: longint;
  Disp: longint;

  CopyOffs: longint;
  FRMTOffs: longint;
  DATAOffs: longint;
  DATASize: cardinal;
  BitsPerSample: cardinal;
  SampleRate: cardinal;
  Channels: cardinal;
  BytesPerSec: cardinal;
  BlockAlign: cardinal;
  Chunk   : TChunk;
  NoOfCompEntries: cardinal;
  CompList: TList;
  CompInfo: PCompInfo;
  CodecNo: cardinal;
  CodecName: string;
  CodecPos: cardinal;
  CodecOffset: cardinal;
  n: cardinal;
  CurrSourcePos: cardinal;
  OutputFile: TFileStream;
  Buffer: pointer;
  BufferPos: cardinal;
  IMCTable1Pos: cardinal;
  IMCTableEntry: longint;
  PrevOffset: cardinal;
  CurrBit: cardinal;
  CurrBitWord: cardinal;
  i : longint;
  OutputSize: cardinal;
  LastOutputSize: cardinal;
  OutputPtr: pointer;
function NextBit: byte;
begin
  result:=lo(CurrBitWord and 1);
  Dec(CurrBit);
  if CurrBit=0 then
  begin
    CurrBitWord:=Analyzer.InputFile.ReadInvWord(CurrSourcePos);
    Inc(CurrSourcePos,2);
    CurrBit:=16;
  end
  else
  begin
    CurrBitWord:=CurrBitWord shr 1;
  end;
end;

function GetDWord(Position: cardinal): longint;
var
  DWordPos: cardinal;
begin
  result:=0;
  for DWordPos:=Position to Position+3 do
  begin
    result:=result shl 8;
    result:=result+THugeBuffer(Buffer^)[DWordPos];
  end;
end;

begin
  result:=false;
  MainForm.Status(0,'Preparing decompression table...');
  Screen.Cursor:=crHourGlass;
  try
    DestTablePos:=0;
    IMCTable1Pos:=0;
    repeat
      Put:=1;
      TableValue:=((IMCTable1[IMCTable1Pos] shl 2) div 7) div 2;
      if TableValue<>0 then
      begin
        repeat
          TableValue:=TableValue div 2;
          Inc(Put);
        until TableValue=0;
      end;
      if Put<3 then
        Put:=3;
      if Put>8 then
        Put:=8;
      Dec(Put);
      Inc(IMCTable1Pos);
      DestTable[DestTablePos]:=Put;
      Inc(DestTablePos);
    until IMCTable1Pos>IMCTable1Size-1;
    DestTable[IMCTable1Size]:=0;

    for n:=0 to $3F do
    begin
      IMCTable1Pos:=0;
      DestTable2Pos:=n;
      repeat
        Count:=$20;
        PutD:=0;
        TableValue:=IMCTable1[IMCTable1Pos];
        repeat
          if (Count and n)<>0 then
            PutD:=PutD+TableValue;
          Count:=Count shr 1;
          TableValue:=TableValue shr 1;
        until (Count = 0);
        DestTable2[DestTable2Pos]:=PutD;
        Inc(DestTable2Pos,$40);
        Inc(IMCTable1Pos);
      until IMCTable1Pos>IMCTable1Size-1;
    end;

    MainForm.Status(0,'Processing compression map...');

    Chunk:=MainForm.ExplorerTreeView.Selected.Data;

    if Chunk.Typ=ctiMUS then
      Chunk:=MainForm.ExplorerTreeView.Selected.Parent.Data;

    COMPOffset:=Analyzer.InputFile.FindBlock('COMP',Chunk.Offset,Chunk.Offset+Chunk.Size);

    NoOfCompEntries:=Analyzer.InputFile.ReadDWord(COMPOffset+4);
    LastOutputSize:=Analyzer.InputFile.ReadDWord(COMPOffset+12);
    CompList:=TList.Create;
    try
      for n:=0 to NoOfCompEntries - 1 do
      begin
        CompInfo:=PCompInfo(new(PCompInfo));
        CompInfo^.Codec:=codecVIMA;
        CompInfo^.CompOffs:=Analyzer.InputFile.ReadDWord(COMPOffset+16*(n+1));
        CompInfo^.CompSize:=Analyzer.InputFile.ReadDWord(COMPOffset+16*(n+1)+4);
        CodecNo:=Analyzer.InputFile.ReadDWord(CompOffset+16*(n+1)+8);
        case CodecNo of
          0   : CompInfo^.Codec:=codecNULL;
          1   : CompInfo^.Codec:=codec0x0001;
          2   : CompInfo^.Codec:=codec0x0002;
          3   : CompInfo^.Codec:=codec0x0003;
          $A,$B,$C  : begin
                        MessageDlg('Unsupported Sound Codec: '+ValueString(CodecNo),mtError,[mbOK],0);
                        Exit;
                      end;
          $D  : CompInfo^.Codec:=codec0x000D;
          $F  : CompInfo^.Codec:=codec0x000F;
        else
        begin
          MessageDlg('Unknown Sound Codec: '+ValueString(CodecNo),mtError,[mbOK],0);
          Exit;
        end;
      end;
      CompList.Add(CompInfo);
      end;

      OutputFile:=TFileStream.Create(OutputFileName,fmCreate);

      Chunk:=MainForm.ExplorerTreeView.Selected.Data;
      MainForm.Status(0,'Creating WAV header...');
      CompInfo:=CompList.Items[0];
      BitsPerSample:=16;
      SampleRate:=22050;
      Channels:=2;
      if (CompInfo^.Codec<>codec0x0001) and
       (CompInfo^.Codec<>codec0x0002) and
       (CompInfo^.Codec<>codec0x0003) then
      begin
        FRMTOffs:=Analyzer.InputFile.FindBlock('FRMT',Chunk.Offset, Chunk.Offset+Chunk.Size);
        if FRMTOffs=-1 then
        begin
          MessageDlg('FRMT Block not found! Using standard format values.',mtWarning,[mbOK],0);
        end
        else
        begin
          BitsPerSample:=Analyzer.InputFile.ReadDWord(FRMTOffs+16);
          SampleRate:=Analyzer.InputFile.ReadDWord(FRMTOffs+20);
          Channels:=Analyzer.InputFile.ReadDWord(FRMTOffs+24);
        end;
        DATAOffs:=Analyzer.InputFile.FindBlock('DATA',Chunk.Offset, Chunk.Offset+Chunk.Size);
        DataSize:=Analyzer.InputFile.ReadDWord(DATAOffs+4);

        WriteWAVHeader(OutputFile,DataSize,Channels,SampleRate,BitsPerSample);
      end;

      MainForm.Status(0,'Decompressing...');
      MainForm.Update;
      try
      for n:=0 to CompList.Count-1 do
      begin
        if (MainForm.Preferences.ShowProgress) and (n mod 2 = 0) then
          MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=(n * 100) div CompList.Count;
        CompInfo:=CompList.Items[n];
        CurrSourcePos:=COMPOffset+CompInfo^.CompOffs;
        Buffer:=AllocMem($2500);
        OutputPtr:=Buffer;
        case CompInfo^.Codec of
          codecNULL : begin
                        for BufferPos:=0 to CompInfo^.CompSize - 1 do
                        begin
                          THugeBuffer(Buffer^)[BufferPos]:=Analyzer.InputFile.ReadByte(CurrSourcePos+BufferPos);
                        end;
                      end;
          codec0x0001, codec0x0002, codec0x0003
                    : begin
                        DestPos:=0;
                        CurrBit:=16;
                        CurrBitWord:=Analyzer.InputFile.ReadInvWord(CurrSourcePos);
                        Inc(CurrSourcePos,2);
                        repeat
                          if NextBit=1 then // 1
                          begin
                            THugeBuffer(Buffer^)[DestPos]:=lo(Analyzer.InputFile.ReadByte(CurrSourcePos));
                            Inc(CurrSourcePos);
                            Inc(DestPos);
                          end
                          else
                          begin // 0
                            if NextBit=1 then // 10
                            begin
                              CopyOffs:=Analyzer.InputFile.ReadByte(CurrSourcePos);
                              Inc(CurrSourcePos);
                              Adder:=Analyzer.InputFile.ReadByte(CurrSourcePos);
                              Inc(CurrSourcePos);
                              CopyOffs:=CopyOffs or (((Adder and $00F0) shl 4)-$1000);
                              Adder:=(Adder and $000F)+3;
                              if Adder = 3 then
                              begin
                                Adder:=Analyzer.InputFile.ReadByte(CurrSourcePos)+1;
                                Inc(CurrSourcePos);
                              end;
                            end
                            else
                            begin // 00
                              Adder:=NextBit shl 1;
                              Adder:=(Adder or NextBit)+3;
                              CopyOffs:=Analyzer.InputFile.ReadByte(CurrSourcePos) or $FFFFFF00;
                              Inc(CurrSourcePos);
                            end;
                            for i:=0 to Adder-1 do
                            begin
                              THugeBuffer(Buffer^)[DestPos+i]:=THugeBuffer(Buffer^)[DestPos+i+CopyOffs];
                            end;
                            Inc(DestPos,Adder);
                          end;
                        until CurrSourcePos>=COMPOffset+CompInfo^.CompOffs+CompInfo^.CompSize;

                        if CompInfo^.Codec = codec0x0002 then
                        begin
                          for i:=1 to DestPos do
                          begin
                            Inc(THugeBuffer(Buffer^)[i],THugeBuffer(Buffer^)[i-1]);
                          end;
                        end;

                        if CompInfo^.Codec = codec0x0003 then
                        begin
                          for i:=2 to DestPos do
                          begin
                            Inc(THugeBuffer(Buffer^)[i],THugeBuffer(Buffer^)[i-1]);
                          end;
                          for i:=1 to DestPos do
                          begin
                            Inc(THugeBuffer(Buffer^)[i],THugeBuffer(Buffer^)[i-1]);
                          end;
                        end;

                        if n=0 then
                        begin
                          OutputSize:=DestPos-1;
                          for i:=8 to DestPos do
                          begin
                            if GetDWord(i-8)=$46524D54 then // FRMT
                            begin
                               BitsPerSample:=GetDWord(i+8);
                               SampleRate:=GetDWord(i+12);
                               Channels:=GetDWord(i+16);
//                               MessageDlg('FRMT Block found! '+inttostr(BitsPerSample)+' '+inttostr(SampleRate)+' '+inttostr(Channels),mtInformation,[mbOK],0);
                            end;
                            if GetDWord(i-8)=$44415441 then
                            begin
//                               MessageDlg('DATA Block found!',mtInformation,[mbOK],0);
                               OutputPtr:=@(THugeBuffer(Buffer^)[i]);
                               OutputSize:=OutputSize-i;
                               DataSize:=GetDWord(i-4);
                               WriteWAVHeader(OutputFile,DataSize-(i),Channels,SampleRate,BitsPerSample);
                            end;
                          end;
                        end
                        else
                        begin
                          if n=CompList.Count-1 then
                            OutputSize:=LastOutputSize
                          else
                            OutputSize:=DestPos-1;
                        end;
                      end;
          codec0x000A, codec0x000B, codec0x000C
                    : begin
                      end;
          codecVIMA, codec0x000D, codec0x000F
                    : begin
                        FirstWord:=Analyzer.InputFile.ReadWord(CurrSourcePos);
                        Inc(CurrSourcePos,2);
                        if FirstWord<>0 then
                        begin
                          if n=0 then
                          begin
                            StartPos:=0;
                          end
                          else
                          begin
                            for BufferPos:=0 to FirstWord-1 do
                            begin
                              THugeBuffer(Buffer^)[BufferPos]:=Analyzer.InputFile.ReadByte(CurrSourcePos+BufferPos);
                            end;
                            StartPos:=FirstWord;
                          end;
                          CurrSourcePos:=CurrSourcePos+FirstWord;
                          NoOfEntriesLeft:=$2000-FirstWord;
                        end
                        else
                        begin
                            SByte[0]:=Analyzer.InputFile.ReadByte(CurrSourcePos);
                            Inc(CurrSourcePos);
                            SDWord[0]:=Analyzer.InputFile.ReadDWord(CurrSourcePos);
                            Inc(CurrSourcePos,4);
                            SDWord[1]:=Analyzer.InputFile.ReadDWord(CurrSourcePos);
                            Inc(CurrSourcePos,4);
                            if Channels>1 then
                            begin
                              SByte[1]:=Analyzer.InputFile.ReadByte(CurrSourcePos);
                              Inc(CurrSourcePos);
                              SDWord[2]:=Analyzer.InputFile.ReadDWord(CurrSourcePos);
                              Inc(CurrSourcePos,4);
                              SDWord[3]:=Analyzer.InputFile.ReadDWord(CurrSourcePos);
                              Inc(CurrSourcePos,4);
                            end;
                            StartPos:=0;
                            NoOfEntriesLeft:=$2000;
                        end;
                        TableEntrySum:=0;
                        for Channel:=0 to Channels-1 do
                        begin
                          if FirstWord=0 then
                          begin
                            CurrTablePos:=SByte[Channel];
                            OutputWord:=SDWord[Channel*2+1];
                            IMCTableEntry:=SDWord[Channel*2];
                          end
                          else
                          begin
                            CurrTablePos:=0;
                            OutputWord:=0;
                            IMCTableEntry:=7;
                          end;
                          NoOfWordsLeft:=((NoOfEntriesLeft div 2)+1) div Channels;
                          DestPos:=StartPos+2*Channel;
                          repeat
                            CurrTableEntry:=DestTable[CurrTablePos];
                            DecompTable:=CurrTableEntry-2;
                            var_3B:=(1 shl DecompTable) * 2;
                            ReadPos:=CurrSourcePos+(TableEntrySum shr 3);

                            ReadWord:=word((Analyzer.InputFile.ReadWord(ReadPos)) shl (TableEntrySum and $7));
                            OtherTablePos:=lo(ReadWord shr ($10 - CurrTableEntry));
                            Inc(TableEntrySum,CurrTableEntry);
                            ESIReg:=IMXShortTable[CurrTableEntry];
                            ESIReg:=(ESIReg and OtherTablePos) shl (7-CurrTableEntry);
                            Inc(ESIReg,CurrTablePos shl 6);

                            IMCTableEntry:=IMCTableEntry shr (CurrTableEntry-1);

                            Adder:=IMCTableEntry+DestTable2[ESIReg];
                            if (OtherTablePos and var_3B)<>0 then
                              Adder:=-Adder;
                            Inc(OutputWord,Adder);
                            if OutputWord>$7FFF then
                              OutputWord:=$7FFF;
                            if OutputWord<$FFFF8000 then
                              OutputWord:=$FFFF8000;
                            THugeBuffer(Buffer^)[DestPos]:=lo(OutputWord);
                            THugeBuffer(Buffer^)[DestPos+1]:=hi(OutputWord);
                            case DecompTable of
                              0 : Inc(CurrTablePos, IMXOtherTable1[OtherTablePos]);
                              1 : Inc(CurrTablePos, IMXOtherTable2[OtherTablePos]);
                              2 : Inc(CurrTablePos, IMXOtherTable3[OtherTablePos]);
                              3 : Inc(CurrTablePos, IMXOtherTable4[OtherTablePos]);
                              4 : Inc(CurrTablePos, IMXOtherTable5[OtherTablePos]);
                              5 : Inc(CurrTablePos, IMXOtherTable6[OtherTablePos]);
                            end;
                            if CurrTablePos<0 then
                              CurrTablePos:=0;
                            if CurrTablePos>$58 then
                              CurrTablePos:=$58;
                            Inc(DestPos,2*Channels);
                            IMCTableEntry:=IMCTable1[CurrTablePos];
                            Dec(NoOfWordsLeft);
                          until NoOfWordsLeft=0;
                        end;
                        if n=0 then
                          OutputSize:=$2000-FirstWord
                        else
                        begin
                          if n=CompList.Count-1 then
                            OutputSize:=DATASize+44-OutputFile.Position
                          else
                            OutputSize:=$2000;
                        end;
                      end;
        end;
        OutputFile.Write(OutputPtr^,OutputSize);
        FreeMem(Buffer);
      end;
      finally
        OutputFile.Free;
      end;

      for n:=0 to CompList.Count-1 do
      begin
        CompInfo:=CompList.Items[n];
        Dispose(CompInfo);
      end;
    finally
      CompList.Free;
    end;
  finally
    MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
    MainForm.Status(0,' ');
    Screen.Cursor:=crDefault;
  end;
  result:=true;
end;

function TSpecInfoForm.SaveUnCompiMUS(OutputFileName: string): boolean;
type
  THugeBuffer = array[0..$3FFFFFFF] of byte;
var
  Chunk: TChunk;
  FRMTOffs: longint;
  DATAOffs: longint;
  DataSize: cardinal;
  Bit12: boolean;
  OutputFile: TFileStream;
  Buffer: pointer;
  Offset: cardinal;
  DestOffs: cardinal;
  BitsPerSample: cardinal;
  SampleRate: cardinal;
  Channels: cardinal;
  Byte1, Byte2, Byte3: smallint;
  Word1, Word2: smallint;
begin
  result:=false;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  FRMTOffs:=Analyzer.InputFile.FindBlock('FRMT',Chunk.Offset,Chunk.Offset+Chunk.Size);
  DATAOffs:=Analyzer.InputFile.FindBlock('DATA',Chunk.Offset,Chunk.Offset+Chunk.Size);

  Bit12:=false;

  if FRMTOffs<>-1 then
  begin
    BitsPerSample:=Analyzer.InputFile.ReadDWord(FRMTOffs+16);
    SampleRate:=Analyzer.InputFile.ReadDWord(FRMTOffs+20);
    Channels:=Analyzer.InputFile.ReadDWord(FRMTOffs+24);
    if BitsPerSample = 12 then
    begin
      BitsPerSample:=16;
      Bit12:=true;
    end;
  end
  else
    Exit;
  if DATAOffs<>-1 then
  begin
    DataSize:=Analyzer.InputFile.ReadDWord(DATAOffs+4);
    if Bit12 then
      DataSize:=(DataSize*4) div 3;
  end
  else
    Exit;

  GetMem(Buffer,DataSize+4);
  MainForm.Status(0,'Converting to WAV...');
  try
    OutputFile:=TFileStream.Create(OutputFileName,fmCreate);
    DestOffs:=0;
    try
      WriteWAVHeader(OutputFile,DataSize,Channels,SampleRate,BitsPerSample);

      Offset:=DATAOffs+8;
      if not(Bit12) then
      repeat
        if Chunk.Typ=fctIMU then
        begin
          Word1:=Analyzer.InputFile.ReadInvWord(Offset);
          THugeBuffer(Buffer^)[DestOffs]:=hi(Word1);
          THugeBuffer(Buffer^)[DestOffs+1]:=lo(Word1);
          Inc(Offset,2);
          Inc(DestOffs,2);
        end
        else
        begin
          THugeBuffer(Buffer^)[DestOffs]:=Analyzer.InputFile.ReadByte(Offset);
          Inc(Offset);
          Inc(DestOffs);
        end;
        if (MainForm.Preferences.ShowProgress) and (DestOffs mod 2 = 0) then
          MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=((Offset-DATAOffs) * 100) div DataSize;
      until DestOffs>=DataSize
      else
      repeat
        Byte1:=Analyzer.InputFile.ReadByte(Offset);
        Byte2:=Analyzer.InputFile.ReadByte(Offset+1);
        Byte3:=Analyzer.InputFile.ReadByte(Offset+2);
        Word1:=((Byte1 or ((Byte2 and $F) shl 8)) shl 4)-$8000;
        Word2:=((Byte3 or ((Byte2 and $F0) shl 4)) shl 4)-$8000;
        THugeBuffer(Buffer^)[DestOffs]:=lo(Word1);
        THugeBuffer(Buffer^)[DestOffs+1]:=hi(Word1);
        THugeBuffer(Buffer^)[DestOffs+2]:=lo(Word2);
        THugeBuffer(Buffer^)[DestOffs+3]:=hi(Word2);
        Inc(Offset,3);
        Inc(DestOffs,4);
        if (MainForm.Preferences.ShowProgress) and (DestOffs mod 8 = 0) then
          MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=((DestOffs) * 100) div DataSize;
      until DestOffs>=DataSize;
    finally
      OutputFile.Write(Buffer^,DestOffs);
      OutputFile.Free;
      MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
      MainForm.Status(0,' ');
    end;
  finally
    FreeMem(Buffer);
  end;
  result:=true;
end;

procedure TSpecInfoForm.PlayVOC(Sender: TObject);
begin
  SpecInfoMediaPlayer.Close;
  SaveVOCasWAV(TempDir+'\temp.wav');
  SpecInfoMediaPlayer.FileName:=TempDir+'\temp.wav';
  SpecInfoMediaPlayer.Open;
  SpecInfoMediaPlayer.Play;
end;

procedure TSpecInfoForm.PlayIMC(Sender: TObject);
begin
  SpecInfoMediaPlayer.Close;
  DecompressIMC(TempDir+'\temp.wav');
  SpecInfoMediaPlayer.FileName:=TempDir+'\temp.wav';
  SpecInfoMediaPlayer.Open;
  SpecInfoMediaPlayer.Play;
end;

procedure TSpecInfoForm.PlayIMU(Sender: TObject);
begin
  SpecInfoMediaPlayer.Close;
  SaveIMU(TempDir+'\temp.wav');
  SpecInfoMediaPlayer.FileName:=TempDir+'\temp.wav';
  SpecInfoMediaPlayer.Open;
  SpecInfoMediaPlayer.Play;
end;

procedure TSpecInfoForm.PlayIMX(Sender: TObject);
begin
  SpecInfoMediaPlayer.Close;
  if SaveCOMPiMUS(TempDir+'\temp.wav') then
  begin
    SpecInfoMediaPlayer.FileName:=TempDir+'\temp.wav';
    SpecInfoMediaPlayer.Open;
    SpecInfoMediaPlayer.Play;
  end;
end;

procedure TSpecInfoForm.PlayWAV(Sender: TObject);
var
  Chunk: TChunk;
begin
  SpecInfoMediaPlayer.Close;
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  Analyzer.InputFile.DumpFile(TempDir+'\temp.wav',Chunk.Offset,Chunk.Size);
  SpecInfoMediaPlayer.FileName:=TempDir+'\temp.wav';
  SpecInfoMediaPlayer.Open;
  SpecInfoMediaPlayer.Play;
end;

procedure TSpecInfoForm.PlayiMUS(Sender: TObject);
begin
  SpecInfoMediaPlayer.Close;
  if SaveUnCompiMUS(TempDir+'\temp.wav') then
  begin
    SpecInfoMediaPlayer.FileName:=TempDir+'\temp.wav';
    SpecInfoMediaPlayer.Open;
    SpecInfoMediaPlayer.Play;
  end;
end;

procedure TSpecInfoForm.SaveIMU2WAV(Sender: TObject);
var
  Chunk: TChunk;
  OutputFileName: string;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  MainForm.SaveDialog.Filter:='Windows RIFF Wave (.wav)|*.wav';
  MainForm.SaveDialog.Title:='Save as...';
  MainForm.SaveDialog.FileName:=(ForceExtension(Chunk.FName,'.wav'));
  if MainForm.SaveDialog.Execute then
  begin
    OutputFileName:=MainForm.SaveDialog.FileName;
    MainForm.Update;
    SaveIMU(ForceExtension(OutputFileName,'.wav'));
  end;
end;

procedure TSpecInfoForm.SaveWAV(Sender: TObject);
var
  Chunk: TChunk;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  SpecInfoSaveDialog.Filter:='Windows RIFF Wave (.wav)|*.wav';
  SpecInfoSaveDialog.Title:='Save as...';
  SpecInfoSaveDialog.FileName:=Chunk.FName;
  If SpecInfoSaveDialog.Execute then
  begin
    Analyzer.InputFile.DumpFile(SpecInfoSaveDialog.FileName,Chunk.Offset,Chunk.Size);
  end;
end;

procedure TSpecInfoForm.DecompressIMX2WAV(Sender: TObject);
begin
  SpecInfoSaveDialog.Filter:='Windows RIFF Wave (.wav)|*.wav';
  SpecInfoSaveDialog.Title:='Save as...';
  SpecInfoSaveDialog.FileName:='.wav';
  If SpecInfoSaveDialog.Execute then
  begin
    MainForm.Update;
    SaveCOMPiMUS(ForceExtension(SpecInfoSaveDialog.FileName,'.wav'));
  end;
end;

procedure TSpecInfoForm.SaveiMUS2WAV(Sender: TObject);
begin
  SpecInfoSaveDialog.Filter:='Windows RIFF Wave (.wav)|*.wav';
  SpecInfoSaveDialog.Title:='Save as...';
  SpecInfoSaveDialog.FileName:='.wav';
  If SpecInfoSaveDialog.Execute then
  begin
    MainForm.Update;
    SaveUncompiMUS(ForceExtension(SpecInfoSaveDialog.FileName,'.wav'));
  end;
end;

procedure TSpecInfoForm.DecompressIMC2WAV(Sender: TObject);
var
  Chunk: TChunk;
  OutputFileName: string;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  MainForm.SaveDialog.Title:='Save as...';
  MainForm.SaveDialog.Filter:='Windows RIFF Wave (.wav)|*.wav';
  MainForm.SaveDialog.FileName:=(ForceExtension(Chunk.FName,'.wav'));
  if MainForm.SaveDialog.Execute then
  begin
    OutputFileName:=MainForm.SaveDialog.FileName;
    MainForm.Update;
    DecompressIMC(ForceExtension(OutputFileName,'.wav'));
  end;
end;

procedure TSpecInfoForm.ViewText(Sender: TObject);
var
  Chunk: TChunk;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  SpecInfoRichEdit.Align:=alClient;
  SpecInfoRichEdit.Clear;
  Analyzer.InputFile.DumpFile(TempDir+'\temp.txt',Chunk.Offset,Chunk.Size);

  SpecInfoRichEdit.Lines.LoadFromFile(TempDir+'\temp.txt');

  SpecInfoRichEdit.Show;
  Caption:='Textual Resource';
  ShowModal;
  HideItems;
end;

procedure TSpecInfoForm.DecryptRCNE(Sender: TObject);
var
  Chunk: TChunk;
  OutputFileName: string;
  XORValue: byte;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  MainForm.SaveDialog.Title:='Save as...';
  MainForm.SaveDialog.Filter:='Text file (.txt)|*.txt';
  MainForm.SaveDialog.FileName:='.wav';
  if MainForm.SaveDialog.Execute then
  begin
    OutputFileName:=MainForm.SaveDialog.FileName;
    MainForm.Update;
    XORValue:=Analyzer.InputFile.XORVal;
    try
      Analyzer.InputFile.XORVal:=$DD;
      MainForm.Status(0,'Decrypting file...');
      MainForm.Update;
      Analyzer.InputFile.DumpFile(OutputFileName,Chunk.Offset+4,Chunk.Size-4);
    finally
      Analyzer.InputFile.XORVal:=XORValue;
      MainForm.Status(0,' ');
    end;
  end;
end;

// *********************** RESIZE ***********************

procedure TSpecInfoForm.WMGetMinMaxInfo(var Msg: TMessage);
Begin
  inherited;
  with PMinMaxInfo(Msg.lParam)^ do
  begin
    ptMinTrackSize.X := 300;
    ptMinTrackSize.Y := 180;
  end;
end;

procedure TSpecInfoForm.ImageSplitterResize(Sender: TObject);
begin
  if not ImageSplitter.AllowResize then
    ImageSplitter.Position:=324;
end;

procedure TSpecInfoForm.FormHide(Sender: TObject);
begin
end;

procedure TSpecInfoForm.FormCreate(Sender: TObject);
begin
  ImageSplitter.Pane2Setting.Visible:=true;
  ImageInfoSplitter.Pane2Setting.Visible:=false;
  ImageSplitter.Hide;
  ImageSplitter.AllowResize:=true;
  Spec1Image.Picture.Bitmap.PixelFormat:=pf8Bit;
  Spec1Image16Bit.Picture.Bitmap.PixelFormat:=pf16Bit;
  Spec1Image24Bit.BringToFront;
  SpecInfoListBox.Hide;
  SpecInfoRichEdit.Hide;
end;

// ******** MENU CLICKS **********

procedure TSpecInfoForm.FileCloseItemClick(Sender: TObject);
begin
  ModalResult:=1;
end;

procedure TSpecInfoForm.CopyImage(Sender: TObject);
begin
  if ImageType<>itBM then
    ClipBoard.Assign(Spec1Image.Picture)
  else
    ClipBoard.Assign(Spec1Image16Bit.Picture);
end;

procedure TSpecInfoForm.ViewZBufferItemClick(Sender: TObject);
begin
  ViewZBufferItem.Checked:=not ViewZBufferItem.Checked;
  if not ViewZBufferItem.Checked then
    Exit;
  screen.cursor:=crHourGlass;
  try
  finally
    screen.cursor:=crDefault;
  end;
end;

procedure TSpecInfoForm.ViewProjectItemClick(Sender: TObject);
var
  ImageDecoder: TImageDecoder;
  SMAPOffs: longint;
  ParChunk: TChunk;
  ChunkSize: integer;
begin
  Screen.Cursor:=crHourGlass;
  try
    ViewProjectItem.Checked:=not ViewProjectItem.Checked;
    ParChunk:=MainForm.ExplorerTreeView.Selected.Parent.Data;
    Spec1Image.Canvas.Brush.Color:=clWhite;
    Spec1Image.Canvas.FillRect(Rect(0,0,Spec1Image.Width,Spec1Image.Height));

    if ViewProjectItem.Checked then
    begin
      ImageDecoder:=TImageDecoder.Create(Spec1Image.Width,Spec1Image.Height,BoxViewer.CompStuff);
      try
        SMAPOffs:=Analyzer.InputFile.FindBlock('RMIM',ParChunk.Offset,ParChunk.Offset+ParChunk.Size);
        if SMAPOffs=-1 then
        begin
          SMAPOffs:=Analyzer.InputFile.FindBlock('IMAG',ParChunk.Offset,ParChunk.Offset+ParChunk.Size);
          ChunkSize:=Analyzer.InputFile.ReadDWord(SMAPOffs+4);
          SMAPOffs:=Analyzer.InputFile.FindBlock('BSTR',SMAPOffs,ParChunk.Offset+ChunkSize);
          SMAPOffs:=Analyzer.InputFile.FindBlock('OFFS',SMAPOffs,ParChunk.Offset+ChunkSize);
        end
        else
          SMAPOffs:=Analyzer.InputFile.FindBlock('SMAP',ParChunk.Offset,ParChunk.Offset+ParChunk.Size);
        if SMAPOffs=-1 then // Old SCUMM
        begin
          SMAPOffs:=Analyzer.InputFile.FindBlock('BM',ParChunk.Offset,ParChunk.Offset+ParChunk.Size);
          if ImageDecoder.Decode(SMAPOffs+6,SMAPOffs+2) then
            Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image);
        end
        else
          if ImageDecoder.Decode(SMAPOffs+8,SMAPOffs) then
            Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image);

        BoxViewer.DrawBoxes;
        BoxViewer.Pulsing:=true;
      finally
        ImageDecoder.Free;
      end;
    end
    else
    begin
      BoxViewer.Pulsing:=false;
      BoxViewer.DrawBoxes;
    end;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TSpecInfoForm.ViewZoom50ItemClick(Sender: TObject);
begin
  ViewZoom50Item.Checked:=true;
  ViewZoom100Item.Checked:=false;
  ViewZoom200Item.Checked:=false;
  if ImageType<>itBM then
  begin
    Spec1Image.Stretch:=true;
    Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width div 2;
    Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height div 2;
    Hide;
    FitFormToImage(Spec1Image);
  end
  else
  begin
    Spec1Image16Bit.Stretch:=true;
    Spec1Image16Bit.Width:=Spec1Image16Bit.Picture.Bitmap.Width div 2;
    Spec1Image16Bit.Height:=Spec1Image16Bit.Picture.Bitmap.Height div 2;
    Hide;
    FitFormToImage(Spec1Image16Bit);
  end;
  Show;
end;

procedure TSpecInfoForm.ViewZoom100ItemClick(Sender: TObject);
begin
  ViewZoom50Item.Checked:=false;
  ViewZoom100Item.Checked:=true;
  ViewZoom200Item.Checked:=false;
  if ImageType<>itBM then
  begin
    Spec1Image.Stretch:=true;
    Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width;
    Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height;
    Hide;
    FitFormToImage(Spec1Image);
  end
  else
  begin
    Spec1Image16Bit.Stretch:=true;
    Spec1Image16Bit.Width:=Spec1Image16Bit.Picture.Bitmap.Width;
    Spec1Image16Bit.Height:=Spec1Image16Bit.Picture.Bitmap.Height;
    Hide;
    FitFormToImage(Spec1Image16Bit);
  end;
  Show;
end;

procedure TSpecInfoForm.ViewZoom200ItemClick(Sender: TObject);
begin
  ViewZoom50Item.Checked:=false;
  ViewZoom100Item.Checked:=false;
  ViewZoom200Item.Checked:=true;
  if ImageType<>itBM then
  begin
    Spec1Image.Stretch:=true;
    Spec1Image.Width:=Spec1Image.Picture.Bitmap.Width * 2;
    Spec1Image.Height:=Spec1Image.Picture.Bitmap.Height * 2;
    Hide;
    FitFormToImage(Spec1Image);
  end
  else
  begin
    Spec1Image16Bit.Stretch:=true;
    Spec1Image16Bit.Width:=Spec1Image16Bit.Picture.Bitmap.Width * 2;
    Spec1Image16Bit.Height:=Spec1Image16Bit.Picture.Bitmap.Height * 2;
    Hide;
    FitFormToImage(Spec1Image16Bit);
  end;
  Show;
end;

procedure TSpecInfoForm.ChooseBox(Sender: TObject);
begin
  BoxViewer.Selected:=ImageListBox.ItemIndex;
  with PBox(BoxViewer.BoxList.Items[BoxViewer.Selected])^ do
  begin
    SpecInfoForm.P1Label.Caption:='('+inttostr(P[0].X)+','+inttostr(P[0].Y)+')';
    SpecInfoForm.P2Label.Caption:='('+inttostr(P[1].X)+','+inttostr(P[1].Y)+')';
    SpecInfoForm.P3Label.Caption:='('+inttostr(P[2].X)+','+inttostr(P[2].Y)+')';
    SpecInfoForm.P4Label.Caption:='('+inttostr(P[3].X)+','+inttostr(P[3].Y)+')';
    SpecInfoForm.Param1Label.Caption:=inttostr(Params[0]);
    SpecInfoForm.Param2Label.Caption:=inttostr(Params[1]);
    if BoxViewer.NoOfParams=5 then
    begin
      SpecInfoForm.Param3Label.Caption:=inttostr(Params[2]);
      SpecInfoForm.Param4Label.Caption:=inttostr(Params[3]);
      SpecInfoForm.Param5Label.Caption:=inttostr(Params[4]);
    end;
  end;
  if not BoxViewer.Pulsing then
    BoxViewer.DrawBoxes;
end;

procedure TSpecInfoForm.SaveImage(Sender: TObject);
var
  OutputFileName: string;
  Image: TBitmap;
begin
  if ImageType<>itBM then
  begin
    SpecInfoSaveDialog.Filter:='Compuserve Graphics Interchange (*.gif)|*.gif|Windows Bitmap (*.bmp)|*.bmp';
    SpecInfoSaveDialog.Title:='Save image as...';
    SpecInfoSaveDialog.FileName:='.gif';
  end
  else
  begin
    SpecInfoSaveDialog.Filter:='Windows Bitmap (*.bmp)|*.bmp';
    SpecInfoSaveDialog.Title:='Save image as...';
    SpecInfoSaveDialog.FileName:='.bmp';
  end;
  If SpecInfoSaveDialog.Execute then
  begin
    case SpecInfoSaveDialog.FilterIndex of
      1 : OutputFileName := ForceExtension(SpecInfoSaveDialog.FileName,'.gif');
      2 : OutputFileName := ForceExtension(SpecInfoSaveDialog.FileName,'.bmp');
    end;
    Image:=TBitmap.Create;
    try
      if ImageType<>itBM then
        Image.Assign(Spec1Image.Picture.Bitmap)
      else
        Image.Assign(Spec1Image16Bit.Picture.Bitmap);
      case SpecInfoSaveDialog.FilterIndex of
        1 : begin
              SaveToFileSingle(OutputFileName,Image,false,false,0);
            end;
        2 : begin
              Image.SaveToFile(OutputFileName);
            end;
      end;
    finally
      Image.Free;
    end;
  end;
end;

procedure TSpecInfoForm.SaveText(Sender: TObject);
begin
  SpecInfoRichEdit.PlainText:=true;
  SpecInfoSaveDialog.Filter:='ASCII Text (*.txt)|*.txt|';
  SpecInfoSaveDialog.Title:='Save text as...';
  SpecInfoSaveDialog.FileName:='.txt';
  If SpecInfoSaveDialog.Execute then
  begin
    SpecInfoRichEdit.Lines.SaveToFile(SpecInfoSaveDialog.FileName);
  end;
end;

procedure TSpecInfoForm.ImageKeyPress(Sender: TObject; var Key: char);
begin
  case UpCase(Key) of
    '+' : begin
            if ViewZoom50Item.Checked then
            begin
              ViewZoom100ItemClick(Self);
            end
            else
            begin
              if ViewZoom100Item.Checked then
              begin
                ViewZoom200ItemClick(Self);
              end;
            end;
          end;
    '-' : begin
            if ViewZoom100Item.Checked then
            begin
              ViewZoom50ItemClick(Self);
            end
            else
            begin
              if ViewZoom200Item.Checked then
              begin
                ViewZoom100ItemClick(Self);
              end;
            end;
          end;
  end;
end;

procedure TSpecInfoForm.ChangeMATImageItemClick(Sender: TObject);
var
  n: cardinal;
begin
  Screen.Cursor:=crHourGlass;
  try
    for n:=0 to ImagesItem.Count - 1 do
    begin
      if Sender = ImagesItem.Items[n] then
      begin
        ImageNo:=n+1;
        ImagesItem.Items[n].Checked:=true;
      end
      else
        ImagesItem.Items[n].Checked:=false;
    end;
    DecodeMAT(ImageNo);
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TSpecInfoForm.ChangeImageItemClick(Sender: TObject);
var
  ImageInfo: TImageInfo;
  ImageDecoder: TImageDecoder;
  n: cardinal;
begin
  Screen.Cursor:=crHourGlass;
  try
    for n:=0 to ImagesItem.Count - 1 do
    begin
      if Sender = ImagesItem.Items[n] then
      begin
        ImageNo:=n+1;
        ImagesItem.Items[n].Checked:=true;
      end
      else
      begin
        ImagesItem.Items[n].Checked:=false;
      end;
    end;
    ImageInfo:=GetImageInfo;
    ImageDecoder:=TImageDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y, ImageInfo.CompStuff);
    ImageDecoder.ImageType:=ImageType;
    try
      DecodeImage(ImageDecoder);
      if ImageType<>itBM then
        Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image)
      else
        Spec1Image16Bit.Picture.Bitmap.Assign(ImageDecoder.Image);
    finally
      ImageDecoder.Free;
    end;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TSpecInfoForm.PalettesAmigaItemClick(Sender: TObject);
var
  ImageDecoder: TImageDecoder;
  ImageInfo: TImageInfo;
begin
  PalettesAmigaItem.Checked:=not PalettesAmigaItem.Checked;
  Screen.Cursor:=crHourGlass;
  try
    ImageInfo:=GetImageInfo;
    ImageDecoder:=TImageDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y, ImageInfo.CompStuff);
    ImageDecoder.ImageType:=ImageType;
    try
      DecodeImage(ImageDecoder);
      Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image);
      Spec1Image.Update;
    finally
      ImageDecoder.Free;
    end;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TSpecInfoForm.ChangePaletteItemClick(Sender: TObject);
var
  ImageInfo: TImageInfo;
  ImageDecoder: TImageDecoder;
  n: cardinal;
begin
  Screen.Cursor:=crHourGlass;
  try
    for n:=0 to PalettesItem.Count - 1 do
    begin
      if Sender = PalettesItem.Items[n] then
      begin
        PaletteNo:=n+1;
        PalettesItem.Items[n].Checked:=true;
      end
      else
      begin
        PalettesItem.Items[n].Checked:=false;
      end;
    end;
    ImageInfo:=GetImageInfo;
    ImageDecoder:=TImageDecoder.Create(ImageInfo.Size.X,ImageInfo.Size.Y, ImageInfo.CompStuff);
    ImageDecoder.ImageType:=ImageType;
    try
      DecodeImage(ImageDecoder);
      Spec1Image.Picture.Bitmap.Assign(ImageDecoder.Image);
    finally
      ImageDecoder.Free;
    end;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TSpecInfoForm.PaletteListChange(Sender: TObject);
var
  x,y : cardinal;
begin
  x:=ImageListBox.Tag mod 16;
  y:=ImageListBox.Tag div 16;
  Spec1Image24Bit.Canvas.Brush.Color:=clBlack;
  Spec1Image24Bit.Canvas.FrameRect(Rect(x*20,y*20,x*20+20,y*20+20));
  Spec1Image24Bit.Canvas.FrameRect(Rect(x*20-1,y*20-1,x*20+21,y*20+21));
  x:=ImageListBox.ItemIndex mod 16;
  y:=ImageListBox.ItemIndex div 16;
  Spec1Image24Bit.Canvas.Brush.Color:=clWhite;
  Spec1Image24Bit.Canvas.FrameRect(Rect(x*20,y*20,x*20+20,y*20+20));
  Spec1Image24Bit.Canvas.FrameRect(Rect(x*20-1,y*20-1,x*20+21,y*20+21));
  ImageListBox.Tag:=ImageListBox.ItemIndex;
end;

procedure TSpecInfoForm.PaletteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ImageListBox.ItemIndex:=(Y div 20)*16+(X div 20);
  PaletteListChange(Self);
end;

procedure TSpecInfoForm.CopyText(Sender: TObject);
begin
  SpecInfoRichEdit.CopyToClipboard;
end;

end.
