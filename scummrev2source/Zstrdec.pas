unit ZSTRDec;

interface

uses
  Graphics, SysUtils, ChunkSpecs;

type
  TZSTRDecoder = class
  public
    Image: TBitmap;

    constructor Create(Width: cardinal; Height: cardinal);
    destructor Destroy; override;
    function Decode(Offs: cardinal; RelOffs: cardinal): boolean;

  private
    CurrOffs: cardinal;
  end;

implementation

uses
  Main, SpecForm, Analyze, Dialogs;

constructor TZSTRDecoder.Create(Width: cardinal; Height: cardinal);
begin
  Image:=TBitmap.Create;
  if Width>0 then
    Image.Width:=Width;
  Image.Height:=Height;
//  Image.PixelFormaat:=pf24bit;
  Image.PixelFormat:=pf8bit;
end;

destructor TZSTRDecoder.Destroy;
begin
  Image.Free;
end;

function TZSTRDecoder.Decode(Offs: cardinal; RelOffs: cardinal): boolean;
var
  NoOfLines: cardinal;
  CurrLine: cardinal;
  CurrByte: byte;
  OtherByte: byte;
  Row: cardinal;
  PScan: PByteArray;
begin
  result:=true;
  if Image.Width=0 then
  begin
    MessageDlg('Room width = 0 or no width found. Cannot decompress image.',mtError,[mbOK],0);
    result:=false;
    Exit;
  end;
  NoOfLines:=Image.Width div 8;
  for CurrLine:=0 to NoOfLines - 1 do
  begin
    if MainForm.Preferences.ShowProgress then
      MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=(CurrLine*100) div NoOfLines;
    CurrOffs:=Analyzer.InputFile.ReadInvWord(Offs+CurrLine*2)+RelOffs;
    Row:=0;
    repeat
      CurrByte:=Analyzer.InputFile.ReadByte(CurrOffs);
      Inc(CurrOffs);
      if CurrByte and $80 <> 0 then
      begin
        CurrByte:=CurrByte and $7F;
        OtherByte:=Analyzer.InputFile.ReadByte(CurrOffs);
        Inc(CurrOffs);
        repeat
          PScan:=Image.ScanLine[Row];
          PScan[CurrLine*8]:=$FF;
          PScan[CurrLine*8+1]:=$FF;
          PScan[CurrLine*8+2]:=$FF;
          PScan[CurrLine*8+3]:=$FF;
          PScan[CurrLine*8+4]:=$FF;
          PScan[CurrLine*8+5]:=$FF;
          PScan[CurrLine*8+6]:=$FF;
          PScan[CurrLine*8+7]:=$FF;
          if OtherByte<>0 then
          begin
            if OtherByte and $80<>0 then
              PScan[CurrLine*8]:=PScan[CurrLine*8] or 1;
            if OtherByte and $40<>0 then
              PScan[CurrLine*8+1]:=PScan[CurrLine*8+1] or 1;
            if OtherByte and $20<>0 then
              PScan[CurrLine*8+2]:=PScan[CurrLine*8+2] or 1;
            if OtherByte and $10<>0 then
              PScan[CurrLine*8+3]:=PScan[CurrLine*8+3] or 1;
            if OtherByte and $8<>0 then
              PScan[CurrLine*8+4]:=PScan[CurrLine*8+4] or 1;
            if OtherByte and $4<>0 then
              PScan[CurrLine*8+5]:=PScan[CurrLine*8+5] or 1;
            if OtherByte and $2<>0 then
              PScan[CurrLine*8+6]:=PScan[CurrLine*8+6] or 1;
            if OtherByte and $1<>0 then
              PScan[CurrLine*8+7]:=PScan[CurrLine*8+7] or 1;
          end;
          Dec(CurrByte);
          Inc(Row);
        until (CurrByte=0) or (Row=Image.Height);
      end
      else
      begin
        repeat
          OtherByte:=Analyzer.InputFile.ReadByte(CurrOffs);
          Inc(CurrOffs);
          PScan:=Image.ScanLine[Row];
          PScan[CurrLine*8]:=$FF;
          PScan[CurrLine*8+1]:=$FF;
          PScan[CurrLine*8+2]:=$FF;
          PScan[CurrLine*8+3]:=$FF;
          PScan[CurrLine*8+4]:=$FF;
          PScan[CurrLine*8+5]:=$FF;
          PScan[CurrLine*8+6]:=$FF;
          PScan[CurrLine*8+7]:=$FF;
          if OtherByte<>0 then
          begin
            if OtherByte and $80<>0 then
              PScan[CurrLine*8]:=PScan[CurrLine*8] or 1;
            if OtherByte and $40<>0 then
              PScan[CurrLine*8+1]:=PScan[CurrLine*8+1] or 1;
            if OtherByte and $20<>0 then
              PScan[CurrLine*8+2]:=PScan[CurrLine*8+2] or 1;
            if OtherByte and $10<>0 then
              PScan[CurrLine*8+3]:=PScan[CurrLine*8+3] or 1;
            if OtherByte and $8<>0 then
              PScan[CurrLine*8+4]:=PScan[CurrLine*8+4] or 1;
            if OtherByte and $4<>0 then
              PScan[CurrLine*8+5]:=PScan[CurrLine*8+5] or 1;
            if OtherByte and $2<>0 then
              PScan[CurrLine*8+6]:=PScan[CurrLine*8+6] or 1;
            if OtherByte and $1<>0 then
              PScan[CurrLine*8+7]:=PScan[CurrLine*8+7] or 1;
          end;
          Dec(CurrByte);
          Inc(Row);
        until (CurrByte=0) or (Row=Image.Height);
      end;
    until Row=Image.Height;
  end;
  MainForm.StatusBar.Panels[0].GaugeAttrs.Position:=0;
end;

end.
