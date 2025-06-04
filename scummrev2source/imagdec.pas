unit ImagDec;

interface

uses
  Graphics, SysUtils, ChunkSpecs;

const
  PC_NOCOLLAPSE = 4;
type
  TImageType = (itImage, itBOMP, itBM);

  PPaletteEntry = ^TPaletteEntry;
  TPaletteEntry = packed record
    peRed: byte;
    peGreen: byte;
    peBlue: byte;
    peFlags: byte;
  end;

  HPALETTE = integer;
  PLOGPALETTE = ^TLOGPALETTE;
  TLOGPALETTE = packed record
    palVersion : word;
    palNumEntries: word;
    palPalEntry: array[0..0] of TPaletteEntry;
  end;

  TImageDecoder = class
  public
    Palette: array[0..255] of longint;
    Image: TBitmap;
    ImageType: TImageType;
    CompValue: cardinal;
    PaletteNo: cardinal;
    constructor Create(Width: cardinal; Height: cardinal; CompStuff: cardinal);
    destructor Destroy; override;
    function Decode(Offs: cardinal; RelOffs: cardinal): boolean;
  private
    Line: cardinal;
    CurrBit: byte;
    CurrStream: cardinal;
    CurrPen: byte;
    CurrOffs: cardinal;
    function NextBit: byte;
    procedure GetPalette;
    procedure Dec0x01(CompType: byte);
    procedure Dec0x12(CompType: byte);
    procedure Dec0x1C(CompType: byte);
    procedure Dec0x26(CompType: byte);
    procedure Dec0x30(CompType: byte);
    procedure Dec0x44(CompType: byte);
    procedure Dec0x58(CompType: byte);
    procedure DecUnknown;
  end;

  function CreatePalette(const LogPalette: TLogPalette): HPalette; stdcall;

implementation

uses
  Main, SpecForm, Analyze, Dialogs;

function CreatePalette; external 'gdi32.dll' name 'CreatePalette';

constructor TImageDecoder.Create(Width: cardinal; Height: cardinal; CompStuff: cardinal);
begin
  Image:=TBitmap.Create;
  Image.Width:=Width;
  Image.Height:=Height;
  Image.PixelFormat:=pf8Bit;
  CompValue:=CompStuff;
  ImageType:=itImage;
  PaletteNo:=1;
end;

destructor TImageDecoder.Destroy;
begin
  Image.Free;
end;

function TImageDecoder.Decode(Offs: cardinal; RelOffs: cardinal): boolean;
var
  CompType: byte;
  NoOfLines: cardinal;
  CurrLine: cardinal;
  Row, Col: cardinal;
  PScan: PByteArray;
  SourcePos: cardinal;
  NextPos: cardinal;
  RByte: cardinal;
  RWord: word;
  n: cardinal;
begin
  result:=true;
  if ImageType<>itBM then
    GetPalette;
  case ImageType of
    itBOMP:
      begin
        Image.PixelFormat:=pf8bit;
        SourcePos:=Offs;
        Row:=0;

        repeat
          PScan:=Image.Scanline[Row];
          Inc(Row);
          if MainForm.Preferences.ShowProgress then
            MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=(Row*100) div Image.Height;
          Col:=0;
          NextPos:=SourcePos+Analyzer.InputFile.ReadInvWord(SourcePos)+2;

          Inc(SourcePos,2);
          repeat
            RByte:=Analyzer.InputFile.ReadByte(SourcePos);
            Inc(SourcePos);
            if (RByte and 1)<>0 then
            begin
              RByte:=RByte div 2;
              CurrPen:=Analyzer.InputFile.ReadByte(SourcePos);
              Inc(SourcePos);
              Inc(RByte);
              repeat
                PScan[Col]:=CurrPen;
                Inc(Col);
                Dec(RByte);
              until RByte=0
            end
            else
            begin
              RByte:=RByte div 2;
              Inc(RByte);
              for n:=0 to RByte-1 do
              begin
                PScan[Col]:=Analyzer.InputFile.ReadByte(SourcePos+n);
                Inc(Col);
              end;
              SourcePos:=SourcePos+RByte;
            end;
          until (SourcePos>=NextPos);
          SourcePos:=NextPos;
        until Row>=Image.Height;
      end;
    itImage:
      begin
        Image.PixelFormat:=pf8bit;
        NoOfLines:=Image.Width div 8;
        for CurrLine:=0 to NoOfLines - 1 do
        begin
          if MainForm.Preferences.ShowProgress then
            MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=(CurrLine*100) div NoOfLines;
          CurrOffs:=Analyzer.InputFile.ReadInvDWord(Offs+CurrLine*4)+RelOffs;
          CompType:=Analyzer.InputFile.ReadByte(CurrOffs);
          Inc(CurrOffs);
          CurrPen:=Analyzer.InputFile.ReadByte(CurrOffs);
          Inc(CurrOffs);
          Line:=CurrLine;
          CurrStream:=Analyzer.InputFile.ReadInvWord(CurrOffs);
          Inc(CurrOffs,2);
          CurrBit:=8;
          case CompType of
            $01      : Dec0x01(CompType);
            $0E..$12 : Dec0x12(CompType-$0B);
            $18..$1C : Dec0x1C(CompType-$15);
            $22..$26 : Dec0x26(CompType-$1F);
            $2C..$30 : Dec0x30(CompType-$29);
            $40..$44 : Dec0x44(CompType-$3D);
            $54..$58 : Dec0x58(CompType-$51);
            $68..$6C : Dec0x58(CompType-$65);
            $7C..$80 : Dec0x44(CompType-$79);
          else
            begin
              DecUnknown;
            end;
          end;
        end;
      end;
    itBM:
      begin
        Image.PixelFormat:=pf16bit;
        SourcePos:=Offs;
        Row:=0;
        Col:=0;

        case CompValue of
          0 : begin
                PScan:=Image.Scanline[Row];
                repeat
                  RWord:=Analyzer.InputFile.ReadWord(SourcePos);
                  Inc(SourcePos,2);
                  PScan[Col]:=hi(RWord);
                  PScan[Col+1]:=lo(RWord);
                  Inc(Col,2);
                  if Col>=Image.Width*2 then
                  begin
                    Col:=0;
                    Inc(Row);
                    PScan:=Image.Scanline[Row];
                    if MainForm.Preferences.ShowProgress then
                      MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=(Row*100) div Image.Height;
                  end;
                until (SourcePos>=Offs+Image.Width*Image.Height*2);
              end;
        else
          begin
            MessageDlg('Image compression layer '+inttostr(CompValue)+' not supported.',mtError,[mbOK],0);
            result:=false;
          end;
        end;
      end;
  end;

  // Support for Amiga-style palettes
  if ImageType<>itBM then
  begin
    if SpecInfoForm.PalettesAmigaItem.Checked then
    begin
      for Row:=0 to Image.Height - 1 do
      begin
        PScan:=Image.Scanline[Row];
        for Col:=0 to Image.Width - 1 do
        begin
          PScan[Col]:=PScan[Col]+16;
        end;
      end;
    end;
  end;
  MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
end;

procedure TImageDecoder.GetPalette;
var
  LPalette: PLOGPALETTE;
  PalSize: word;
  PalHandle: HPALETTE;
  ROOMChunk: TChunk;
  APALOffs: longint;
  PALSEnd: longint;
  n: byte;
  RedC: byte;
  GreenC: byte;
  BlueC: byte;
begin
  PalSize:=SizeOf(TLOGPALETTE)+SizeOf(TPALETTEENTRY)*256;
  APALOffs:=-1;
  GetMem(LPalette,PalSize);
  try
    With LPalette^ do
    begin
      palVersion:=$0300;
      palNumEntries:=256;
    end;
    if MainForm.ExplorerTreeView.Selected.Parent=nil then
      Exit;

    ROOMChunk:=MainForm.ExplorerTreeView.Selected.Parent.Data;

    if ROOMChunk.Typ=ctOBIM then
    begin
      if MainForm.ExplorerTreeView.Selected.Parent.Parent=nil then
        Exit;
      ROOMChunk:=MainForm.ExplorerTreeView.Selected.Parent.Parent.Data;
    end;

    APALOffs:=Analyzer.InputFile.FindBlock('PALS',ROOMChunk.Offset, ROOMChunk.Offset+ROOMChunk.Size);
    if APALOffs=-1 then
      APALOffs:=Analyzer.InputFile.FindBlock('CLUT',ROOMChunk.Offset, ROOMChunk.Offset+ROOMChunk.Size)
    else
    begin
      PALSEnd:=APALOffs+Analyzer.InputFile.ReadDWord(APALOffs+4);
      for n:=1 to PaletteNo do
      begin
        APALOffs:=Analyzer.InputFile.FindBlock('APAL',APALOffs+1, PALSEnd);
      end;
    end;

    if ROOMChunk.Typ=ctRO then
    begin
      APALOffs:=Analyzer.InputFile.FindBlock('PA',ROOMChunk.Offset, ROOMChunk.Offset+ROOMChunk.Size);
      for n:=0 to 255 do
      begin
          RedC:=Analyzer.InputFile.ReadByte(APALOffs+4+n*3);
          GreenC:=Analyzer.InputFile.ReadByte(APALOffs+4+1+n*3);
          BlueC:=Analyzer.InputFile.ReadByte(APALOffs+4+2+n*3);
          Palette[n]:=RedC+GreenC*256+BlueC*65536;
          with LPalette.palPalEntry[n] do
          begin
            peRed:=RedC;
            peGreen:=GreenC;
            peBlue:=BlueC;
            peFlags:=PC_NOCOLLAPSE;
          end;
      end;
    end
    else
    begin
      for n:=0 to 255 do
      begin
          RedC:=Analyzer.InputFile.ReadByte(APALOffs+8+n*3);
          GreenC:=Analyzer.InputFile.ReadByte(APALOffs+8+1+n*3);
          BlueC:=Analyzer.InputFile.ReadByte(APALOffs+8+2+n*3);
          Palette[n]:=RedC+GreenC*256+BlueC*65536;
  {$IFDEF DEBUG}
    {$R-}
  {$ENDIF}
          with LPalette.palPalEntry[n] do
          begin
            peRed:=RedC;
            peGreen:=GreenC;
            peBlue:=BlueC;
            peFlags:=PC_NOCOLLAPSE;
          end;
  {$IFDEF DEBUG}
    {$R+}
  {$ENDIF}
      end;
    end;
    PalHandle:=CreatePalette(LPalette^);
  finally
    FreeMem(LPalette,PalSize);
    if APALOffs=-1 then
      MessageDlg('Palette not found.',mtError,[mbOK],0);
  end;
  Image.Palette:=PalHandle;
end;

function TImageDecoder.NextBit: byte;
begin
  if CurrBit=0 then
  begin
    CurrBit:=8;
    CurrStream:=CurrStream + (Analyzer.InputFile.ReadByte(CurrOffs) shl 8);
    Inc(CurrOffs);
  end;
  result:=lo(CurrStream and 1);
  CurrStream:=CurrStream shr 1;
  Dec(CurrBit);
end;

procedure TImageDecoder.Dec0x01(CompType: byte);
var
  Col: cardinal;
  Row: cardinal;
  PScan: PByteArray;
  n: byte;
begin
  For Row:=0 to Image.Height - 1 do
  begin
    PScan:=Image.Scanline[Row];
    For Col:=0 to 7 do
    begin
      if (Col=0) and (Row=0) then
      begin
        PScan[Col+Line*8]:=CurrPen;
        Continue;
      end;
      PScan[Col+Line*8]:=lo(CurrStream);
      for n:=1 to 8 do
      begin
        NextBit;
      end;
    end;
  end;
end;

procedure TImageDecoder.Dec0x12(CompType: byte);
var
  Col: cardinal;
  Row: cardinal;
  PScan: PByteArray;
  TabValue: byte;
  SubVal: shortint;
  n: byte;
begin
  case CompType of
    3 : TabValue:=$0F;
    4 : TabValue:=$1F;
    5 : TabValue:=$3F;
    6 : TabValue:=$7F;
    7 : TabValue:=$FF;
  else
    TabValue:=0;
  end;
  SubVal:=1;
  For Col:=0 to 7 do
  begin
    For Row:=0 to Image.Height - 1 do
    begin
      PScan:=Image.Scanline[Row];
      if (Col=0) and (Row=0) then
      begin
        PScan[Col+Line*8]:=CurrPen;
        Continue;
      end;
      if NextBit = 0 then
      begin
        PScan[Col+Line*8]:=CurrPen;
      end
      else
      begin
        if NextBit = 0 then
        begin
          CurrPen:=lo(CurrStream) and TabValue;
          for n:=0 to CompType do
          begin
            NextBit;
          end;
          SubVal:=1;

          PScan[Col+Line*8]:=CurrPen;
        end
        else
        begin
          if NextBit = 0 then
          begin
            Dec(CurrPen,SubVal);
          end
          else
          begin
            SubVal:=-SubVal;
            Dec(CurrPen,SubVal);
          end;
          PScan[Col+Line*8]:=CurrPen;
        end;
      end;
    end;
  end;
end;

procedure TImageDecoder.Dec0x1C(CompType: byte);
var
  Col: cardinal;
  Row: cardinal;
  PScan: PByteArray;
  TabValue: byte;
  SubVal: shortint;
  n: byte;
begin
  case CompType of
    3 : TabValue:=$0F;
    4 : TabValue:=$1F;
    5 : TabValue:=$3F;
    6 : TabValue:=$7F;
    7 : TabValue:=$FF;
  else
    TabValue:=0;
  end;
  SubVal:=1;
  For Row:=0 to Image.Height - 1 do
  begin
    PScan:=Image.Scanline[Row];
    For Col:=0 to 7 do
    begin
      if (Col=0) and (Row=0) then
      begin
        PScan[Col+Line*8]:=CurrPen;
        Continue;
      end;
      if NextBit = 0 then
      begin
          PScan[Col+Line*8]:=CurrPen;
      end
      else
      begin
        if NextBit = 0 then
        begin
          CurrPen:=lo(CurrStream) and TabValue;
          for n:=0 to CompType do
          begin
            NextBit;
          end;
          SubVal:=1;
          PScan[Col+Line*8]:=CurrPen;
        end
        else
        begin
          if NextBit = 0 then
          begin
            Dec(CurrPen,SubVal);
          end
          else
          begin
            SubVal:=-SubVal;
            Dec(CurrPen,SubVal);
          end;
          PScan[Col+Line*8]:=CurrPen;
        end;
      end;
    end;
  end;
end;

procedure TImageDecoder.Dec0x26(CompType: byte);
var
  Col: cardinal;
  Row: cardinal;
  PScan: PByteArray;
  TabValue: byte;
  SubVal: shortint;
  n: byte;
begin
  case CompType of
    3 : TabValue:=$0F;
    4 : TabValue:=$1F;
    5 : TabValue:=$3F;
    6 : TabValue:=$7F;
    7 : TabValue:=$FF;
  else
    TabValue:=0;
  end;
  SubVal:=1;
  For Col:=0 to 7 do
  begin
    For Row:=0 to Image.Height - 1 do
    begin
      PScan:=Image.Scanline[Row];
      if (Col=0) and (Row=0) then
      begin
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
        Continue;
      end;
      if NextBit = 0 then
      begin
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
      end
      else
      begin
        if NextBit = 0 then
        begin
          CurrPen:=lo(CurrStream) and TabValue;
          for n:=0 to CompType do
          begin
            NextBit;
          end;
          SubVal:=1;

          if CurrPen<>CompValue then
            PScan[Col+Line*8]:=CurrPen
          else
            PScan[Col+Line*8]:=0;
        end
        else
        begin
          if NextBit = 0 then
          begin
            if SubVal>=0 then
              Dec(CurrPen)
            else
              Inc(CurrPen);
          end
          else
          begin
            Inc(CurrPen,SubVal);
            SubVal:=-SubVal;
          end;
          if CurrPen<>CompValue then
            PScan[Col+Line*8]:=CurrPen
          else
            PScan[Col+Line*8]:=0;
        end;
      end;
    end;
  end;
end;

procedure TImageDecoder.Dec0x30(CompType: byte);
var
  Col: cardinal;
  Row: cardinal;
  PScan: PByteArray;
  TabValue: byte;
  SubVal: shortint;
  n: byte;
begin
  case CompType of
    3 : TabValue:=$0F;
    4 : TabValue:=$1F;
    5 : TabValue:=$3F;
    6 : TabValue:=$7F;
    7 : TabValue:=$FF;
  else
    TabValue:=0;
  end;
  SubVal:=1;
  For Row:=0 to Image.Height - 1 do
  begin
    PScan:=Image.Scanline[Row];
    For Col:=0 to 7 do
    begin
      if (Col=0) and (Row=0) then
      begin
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
        Continue;
      end;
      if NextBit = 0 then
      begin
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
      end
      else
      begin
        if NextBit = 0 then
        begin
          CurrPen:=lo(CurrStream) and TabValue;
          for n:=0 to CompType do
          begin
            NextBit;
          end;
          SubVal:=1;

          if CurrPen<>CompValue then
            PScan[Col+Line*8]:=CurrPen
          else
            PScan[Col+Line*8]:=0;
        end
        else
        begin
          if NextBit = 0 then
          begin
            Dec(CurrPen,SubVal);
          end
          else
          begin
            SubVal:=-SubVal;
            Dec(CurrPen,SubVal);
          end;
          if CurrPen<>CompValue then
            PScan[Col+Line*8]:=CurrPen
          else
            PScan[Col+Line*8]:=0;
        end;
      end;
    end;
  end;
end;

procedure TImageDecoder.Dec0x44(CompType: byte);
var
  Row: cardinal;
  Col: cardinal;
  AddIdent: byte;
  PScan: PByteArray;
  TabValue: byte;
  n: byte;
  Count: byte;
begin
  case CompType of
    3 : TabValue:=$0F;
    4 : TabValue:=$1F;
    5 : TabValue:=$3F;
    6 : TabValue:=$7F;
    7 : TabValue:=$FF;
  else
    TabValue:=0;
  end;
  Count:=0;
  For Row:=0 to Image.Height - 1 do
  begin
    PScan:=Image.Scanline[Row];
    For Col:=0 to 7 do
    begin
      if (Col=0) and (Row=0) then
      begin
        PScan[Col+Line*8]:=CurrPen;
        Continue;
      end;
      if Count>0 then
      begin
        Dec(Count);
        PScan[Col+Line*8]:=CurrPen;
        Continue;
      end;
      if NextBit = 0 then
      begin
          PScan[Col+Line*8]:=CurrPen;
      end
      else
      begin
        if NextBit = 0 then
        begin
          CurrPen:=lo(CurrStream) and TabValue;
          for n:=0 to CompType do
          begin
            NextBit;
          end;
          PScan[Col+Line*8]:=CurrPen;
        end
        else
        begin
          AddIdent:=NextBit + NextBit shl 1 + NextBit shl 2;
          Case AddIdent of
            0 : Dec(CurrPen,4);
            1 : Dec(CurrPen,3);
            2 : Dec(CurrPen,2);
            3 : Dec(CurrPen,1);
            4 : begin
                  Count:=lo(CurrStream) -1;
                  for n:=1 to 8 do
                  begin
                    NextBit;
                  end;
                end;
            5 : Inc(CurrPen,1);
            6 : Inc(CurrPen,2);
            7 : Inc(CurrPen,3);
          end;
          PScan[Col+Line*8]:=CurrPen;
        end;
      end;
    end;
  end;
end;

procedure TImageDecoder.Dec0x58(CompType: byte);
var
  Row: cardinal;
  Col: cardinal;
  AddIdent: byte;
  PScan: PByteArray;
  TabValue: byte;
  n: byte;
  Count: byte;
begin
  Count:=0;
  case CompType of
    3 : TabValue:=$0F;
    4 : TabValue:=$1F;
    5 : TabValue:=$3F;
    6 : TabValue:=$7F;
    7 : TabValue:=$FF;
  else
    TabValue:=0;
  end;
  For Row:=0 to Image.Height - 1 do
  begin
    PScan:=Image.Scanline[Row];
    For Col:=0 to 7 do
    begin
      if (Col=0) and (Row=0) then
      begin
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
        Continue;
      end;
      if Count>0 then
      begin
        Dec(Count);
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
        Continue;
      end;
      if NextBit = 0 then
      begin
        if CurrPen<>CompValue then
          PScan[Col+Line*8]:=CurrPen
        else
          PScan[Col+Line*8]:=0;
      end
      else
      begin
        if NextBit = 0 then
        begin
          CurrPen:=lo(CurrStream) and TabValue;
          for n:=0 to CompType do
          begin
            NextBit;
          end;
          if CurrPen<>CompValue then
            PScan[Col+Line*8]:=CurrPen
          else
            PScan[Col+Line*8]:=0;
        end
        else
        begin
          AddIdent:=NextBit + NextBit shl 1 + NextBit shl 2;
          Case AddIdent of
            0 : Dec(CurrPen,4);
            1 : Dec(CurrPen,3);
            2 : Dec(CurrPen,2);
            3 : Dec(CurrPen,1);
            4 : begin
                  Count:=lo(CurrStream) -1;
                  for n:=1 to 8 do
                  begin
                    NextBit;
                  end;
                end;
            5 : Inc(CurrPen,1);
            6 : Inc(CurrPen,2);
            7 : Inc(CurrPen,3);
          end;
          if CurrPen<>CompValue then
            PScan[Col+Line*8]:=CurrPen
          else
            PScan[Col+Line*8]:=0;
        end;
      end;
    end;
  end;
end;

procedure TImageDecoder.DecUnknown;
begin
  Image.Canvas.Pixels[Line*8,0]:=Palette[CurrPen];
end;
end.
