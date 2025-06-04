unit SpecInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Chunks, OldChunks, LABChunks, StdCtrls, MPlayer, ExtCtrls, Opcodes,
  ChunkInfo, Menus;

type
  TSpecificInfoForm = class(TForm)
    SpecLabel1: TLabel;
    SpecResultLabel1: TLabel;
    SaveAsVocButton: TButton;
    SpecInfoSaveDialog: TSaveDialog;
    SaveAsMIDButton: TButton;
    PlayButton: TButton;
    MediaPlayer: TMediaPlayer;
    SpecListBox: TListBox;
    SpecMemo: TMemo;
    SpecLabel2: TLabel;
    SpecResultLabel2: TLabel;
    SpecLabel3: TLabel;
    SpecResultLabel3: TLabel;
    SpecLabel4: TLabel;
    SpecResultLabel4: TLabel;
    SpecLabel5: TLabel;
    SpecResultLabel5: TLabel;
    SpecScrollBox: TScrollBox;
    SpecImage: TImage;
    ImageSplitter: TSplitter;
    ImagePopupMenu: TPopupMenu;
    SaveImageItem: TMenuItem;
    DecompressButton: TButton;
    procedure SaveAsVocButtonClick(Sender: TObject);
    procedure SaveAsMIDButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SaveImageItemClick(Sender: TObject);
    procedure DecompressButtonClick(Sender: TObject);
  private
    MCMPSSize: array[1..1000] of Cardinal;
    MCMPDSize: array[1..1000] of Cardinal;
    ChunkType: TChunkType;
    OldChunkType: TOldChunkType;
    LabChunkType: TLABChunkType;
    { Private declarations }
    procedure InitTools;
    procedure InitImage;
    procedure iMUSRead;
    function ParameterPrint(Op: TOpcode): byte;
    function StringPrint(Op: TOpcode): byte;
    procedure OpcodePrint(Op: TOpcode);

    procedure ShowLOFFSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowMIDSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowBOXDSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowCLUTSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowOBNASpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowLSCRSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowSOUNSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowTEXTSpecs(Loc: Cardinal; Size: Cardinal);

    procedure ShowLABNSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowLB83Specs(Loc: Cardinal; Size: Cardinal);
    procedure ShowIMCSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowFRMTSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowBUNTEXTSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowJUMPSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowREGNSpecs(Loc: Cardinal; Size: Cardinal);
    procedure ShowSTOPSpecs(Loc: Cardinal; Size: Cardinal);

    procedure ShowPASpecs(Loc: Cardinal; Size: Cardinal);
  public
    { Public declarations }
    procedure ShowSpecs(SpecType: TChunkType; Loc: Cardinal; Size: Cardinal);
    procedure ShowOldSpecs(SpecType: TOldChunkType; Loc: Cardinal; Size: Cardinal);
    procedure ShowLABSpecs(SpecType: TLABChunkType; Loc: Cardinal; Size: Cardinal);
  end;

var
  SpecificInfoForm: TSpecificInfoForm;

const
  ColorPal          : array[1..10] of TColor = (
                      $000000, $FF0000, $00BB00, $0000FF, $FF9900,
                      $FF0099, $99FF00, $0099FF, $9900FF, $00FF99);

  ImageBorder       : integer = 20;
implementation
uses
    main, DecrypterThread, ShellAPI, ComFunc;
var
   Decrypter: TDecrypter;
   MaxX     : integer;
   MaxY     : integer;

{$R *.DFM}

procedure TSpecificInfoForm.InitTools;
begin
     SpecificInfoForm.Height:=362;
     SpecificInfoForm.Width:=458;
     SpecificInfoForm.Position:=poScreenCenter;
     SpecLabel1.Hide;
     SpecLabel2.Hide;
     SpecLabel3.Hide;
     SpecLabel4.Hide;
     SpecLabel5.Hide;
     SpecResultLabel1.Hide;
     SpecResultLabel2.Hide;
     SpecResultLabel3.Hide;
     SpecResultLabel4.Hide;
     SpecResultLabel5.Hide;
     PlayButton.Hide;
     DecompressButton.Hide;
     SaveAsVOCButton.Hide;
     SaveAsMIDButton.Hide;
     SpecMemo.Hide;
     SpecListBox.Hide;
     ImageSplitter.Hide;
     SpecScrollBox.Hide;

     SaveAsVOCButton.Top:=304;
     SaveAsMIDButton.Top:=304;
     DecompressButton.Top:=50;
     DecompressButton.Left:=10;

     SpecMemo.Left:=8;
     SpecMemo.Top:=8;
     SpecMemo.Width:=320;
     SpecMemo.Height:=320;
     SpecMemo.Clear;

     SpecListBox.Align:=alNone;
     SpecListBox.Left:=8;
     SpecListBox.Top:=8;
     SpecListBox.Width:=280;
     SpecListBox.Height:=320;
     SpecListBox.Clear;

     SpecResultLabel5.WordWrap:=false;
end;

procedure TSpecificInfoForm.InitImage;
begin
     //SpecImage.Align:=alLeft;
     SpecScrollBox.Width:=320;
     SpecScrollBox.HorzScrollBar.Position:=0;
     SpecScrollBox.VertScrollBar.Position:=0;

     SpecImage.Left:=0;
     SpecImage.Top:=0;
     SpecImage.Picture.Bitmap.Width:=2400;
     SpecImage.Picture.Bitmap.Height:=800;

     SpecListBox.Align:=alClient;

     SpecScrollBox.Show;
     ImageSplitter.Show;
     SpecListBox.Show;
end;

procedure TSpecificInfoForm.ShowIMCSpecs(Loc: Cardinal; Size: Cardinal);
begin
   SpecificInfoForm.Width:=400;
   SpecificInfoForm.Height:=120;
   DecompressButton.Show;
end;

procedure TSpecificInfoForm.ShowLOFFSpecs(Loc: Cardinal; Size: Cardinal);
var
   NoOfOffsets : cardinal;
   n,n1        : cardinal;
   OffSetString: string;
   OffSetNumber: cardinal;
   ValString: string;
begin
     Analyzer.InputFile.Seek(Loc+8);
     NoOfOffsets:=Analyzer.InputFile.ReadByte;
     For n:=1 to NoOfOffsets do
     begin
          OffsetNumber:=Analyzer.InputFile.ReadByte;
          OffSetString:='Room ';
          if OffsetNumber<100 then
             OffsetString:=OffsetString+' ';
          if OffsetNumber<10 then
             OffsetString:=Offsetstring+' ';
          OffsetString:=OffsetString+inttostr(OffsetNumber);
          OffsetString:=OffsetString+' : ';
          ValString:=ValueString(Analyzer.InputFile.ReadByte
                    +Analyzer.InputFile.ReadByte shl 8
                    +Analyzer.InputFile.ReadByte shl 16
                    +Analyzer.InputFile.ReadByte shl 24);
          for n1:=1 to 21-length(ValString) do
          begin
               OffSetString:=OffSetString+' ';
          end;
          OffsetString:=OffsetString+ValString;
          SpecListBox.Items.Add(OffsetString);
     end;
     SpecListBox.Show;
end;

procedure TSpecificInfoForm.ShowMIDSpecs(Loc: Cardinal; Size: Cardinal);
begin
     SaveAsMIDButton.Show;
end;

function ColorToString(index: byte; RedC: byte; GreenC: byte; BlueC: byte): string;
begin
   result:=(inttohex(index,2)+': '
      +inttohex(RedC,2)+inttohex(GreenC,2)+inttohex(BlueC,2)
      +' ('+inttostr(RedC)+','+inttostr(GreenC)+','+inttostr(BlueC)+')'
      );

end;

procedure TSpecificInfoForm.ShowPASpecs(Loc: Cardinal; Size: Cardinal);
var
   RedC, GreenC, BlueC : byte;
   x,y                 : byte;
   Col                 : TColor;
begin
     InitImage;
     SpecImage.Width:=320;
     SpecImage.Height:=320;
     Analyzer.InputFile.Seek(Loc+8);
     SpecImage.Canvas.Pen.Color:=clBlack;

     Analyzer.InputFile.Seek(Loc+8);
     For y:=0 to 15 do
     begin
          For x:=0 to 15 do
          begin
               If Analyzer.InputFile.FilePos>Loc+Size then
               begin
                    MessageDlg('Invalid colortable!',mtError,[mbOK],0);
                    Exit;
               end;
               RedC:=Analyzer.InputFile.ReadByte;
               GreenC:=Analyzer.InputFile.ReadByte;
               BlueC:=Analyzer.InputFile.ReadByte;
               Col:=RedC+GreenC*256+BlueC*65536;
               SpecImage.Canvas.Brush.Color:=Col;
               SpecImage.Canvas.Rectangle(x*20,y*20,x*20+20,y*20+20);
               SpecListBox.Items.Add(ColorToString(y*16+x,RedC,GreenC,BlueC));
          end;
     end;
     SpecImage.Show;
end;

procedure TSpecificInfoForm.ShowBOXDSpecs(Loc: Cardinal; Size: Cardinal);
var
   n        : cardinal;
   i        : byte;
   Param1   : integer;
   Param2   : integer;
   Param3   : integer;
   Param4   : integer;
   Param5   : integer;
   Coords   : array[1..5] of TPoint;
   Count    : integer;
begin
     InitImage;
     SpecImage.Width:=2400;
     SpecImage.Height:=800;
     SpecImage.Canvas.Brush.Color:=clWhite;
     SpecImage.Canvas.FillRect(Rect(0,0,SpecImage.Width, SpecImage.Height));
     MaxX:=0;
     MaxY:=0;

     if MainForm.CMICheckBox.Checked then
     begin
     Analyzer.InputFile.Seek(Loc+8);
     Count:=Analyzer.InputFile.ReadInvDWord;
     SpecListBox.Items.Add('Box 1');
     // The first weird box
     for n:=1 to 4 do
     begin
        SpecListBox.Items.Add('P'+inttostr(n)+': ('+inttostr(integer(Analyzer.InputFile.ReadInvDWord))
           +','+inttostr(integer(Analyzer.InputFile.ReadInvDWord))+')');
     end;
     SpecListBox.Items.Add('Params: '
     +     inttostr(integer(Analyzer.InputFile.ReadDWord))
     +', '+inttostr(integer(Analyzer.InputFile.ReadDWord))
     +', '+inttostr(integer(Analyzer.InputFile.ReadDWord))
     +', '+inttostr(integer(Analyzer.InputFile.ReadDWord))
     +', '+inttostr(integer(Analyzer.InputFile.ReadDWord)));
     // The rest.
     for n:=2 to Count do
     begin
           SpecListBox.Items.Add('');
           SpecListBox.Items.Add('Box '+inttostr(n));
           for i:=1 to 4 do
           begin
                Coords[i].X:=Integer(Analyzer.InputFile.ReadInvDWord);
                Coords[i].Y:=Integer(Analyzer.InputFile.ReadInvDWord);
                SpecListBox.Items.Add('P'+inttostr(i)+': ('+inttostr(Coords[i].X)
                   +','+inttostr(Coords[i].Y)+')');
                if Coords[i].X>MaxX then MaxX:=Coords[i].X;
                if Coords[i].Y>MaxY then MaxY:=Coords[i].Y;
           end;
           Param1:=Analyzer.InputFile.ReadInvDWord;
           Param2:=Analyzer.InputFile.ReadInvDWord;
           Param3:=Analyzer.InputFile.ReadInvDWord;
           Param4:=Analyzer.InputFile.ReadInvDWord;
           Param5:=Analyzer.InputFile.ReadInvDWord;
           SpecImage.Canvas.Pen.Color:=ColorPal[Param1];
           SpecListBox.Items.Add('Params: '+inttostr(Param1)+', '
              +inttostr(Param2)+', '+inttostr(Param3)+', '
              +inttostr(Param4)+', '+inttostr(Param5));
           Coords[5]:=Coords[1];  // Connect start point - end point.

           SpecImage.Canvas.Polyline(Coords);
     end;
     end
     else

     begin
        Analyzer.InputFile.Seek(Loc+8);
        Count:=Analyzer.InputFile.ReadInvWord;
        SpecListBox.Items.Add('Box 1');
        // The first weird box.
        for n:=1 to 4 do
        begin
           SpecListBox.Items.Add('P'+inttostr(n)+': ('+inttostr(smallint(Analyzer.InputFile.ReadInvWord))
              +','+inttostr(smallint(Analyzer.InputFile.ReadInvWord))+')');
        end;
        SpecListBox.Items.Add('Params: '
        +     inttostr(smallint(Analyzer.InputFile.ReadInvWord))
        +', '+inttostr(smallint(Analyzer.InputFile.ReadInvWord)));
        // The rest.
        for n:=2 to Count do
        begin
           SpecListBox.Items.Add('');
           SpecListBox.Items.Add('Box '+inttostr(n));
           for i:=1 to 4 do
           begin
                Coords[i].X:=smallint(Analyzer.InputFile.ReadInvWord);
                Coords[i].Y:=smallint(Analyzer.InputFile.ReadInvWord);
                SpecListBox.Items.Add('P'+inttostr(i)+': ('+inttostr(Coords[i].X)
                   +','+inttostr(Coords[i].Y)+')');
                if Coords[i].X>MaxX then MaxX:=Coords[i].X;
                if Coords[i].Y>MaxY then MaxY:=Coords[i].Y;
           end;
           Param1:=Analyzer.InputFile.ReadInvWord;
           Param2:=Analyzer.InputFile.ReadInvWord;
           SpecImage.Canvas.Pen.Color:=ColorPal[Param1];
           SpecListBox.Items.Add('Params: '+inttostr(Param1)+', '
              +inttostr(Param2));
           Coords[5]:=Coords[1];  // Connect start point - end point.

           SpecImage.Canvas.Polyline(Coords);
        end;
     end;
     SpecImage.Width:=MaxX + ImageBorder;  // Determine image size from bounds.
     SpecImage.Height:=MaxY + ImageBorder;
     SpecImage.Show;
     //SpecMemo.Show;

end;

procedure TSpecificInfoForm.ShowCLUTSpecs(Loc: Cardinal; Size: Cardinal);
var
   RedC, GreenC, BlueC : byte;
   x,y                 : byte;
   Col                 : TColor;
begin
     InitImage;
     SpecImage.Width:=320;
     SpecImage.Height:=320;
     Analyzer.InputFile.Seek(Loc+8);
     SpecImage.Canvas.Pen.Color:=clBlack;
     For y:=0 to 15 do
     begin
          For x:=0 to 15 do
          begin
               If Analyzer.InputFile.FilePos>Loc+Size then
               begin
                    MessageDlg('Invalid colortable!',mtError,[mbOK],0);
                    Exit;
               end;
               RedC:=Analyzer.InputFile.ReadByte;
               GreenC:=Analyzer.InputFile.ReadByte;
               BlueC:=Analyzer.InputFile.ReadByte;
               Col:=RedC+GreenC*256+BlueC*65536;
               SpecImage.Canvas.Brush.Color:=Col;
               SpecImage.Canvas.Rectangle(x*20,y*20,x*20+20,y*20+20);
               SpecListBox.Items.Add(ColorToString(y*16+x,RedC,GreenC,BlueC));
          end;
     end;
     SpecImage.Show;
end;

function TSpecificInfoForm.ParameterPrint(Op: TOpcode): byte;
begin
     SpecMemo.Lines.Add(OpCodeName[Op]+' '
                          +IntToHex(Analyzer.InputFile.ReadByte,2)+' '
                          +IntToHex(Analyzer.InputFile.ReadByte,2)+' '
                          +IntToHex(Analyzer.InputFile.ReadByte,2)+' '
                          +IntToHex(Analyzer.InputFile.ReadByte,2));
     result:=4;
end;

procedure TSpecificInfoForm.OpcodePrint(Op: TOpcode);
begin
     SpecMemo.Lines.Add(OpCodeName[Op]);
end;

function TSpecificInfoForm.StringPrint(Op: TOpcode): byte;
var
   RByte : byte;
   EndString: string;
   n : byte;
begin
     n:=0;
     repeat
           Inc(n);
           RByte:=Analyzer.InputFile.ReadByte;
           if RByte<>0 then
              EndString:=EndString+Chr(RByte);
     until RByte=0;
     SpecMemo.Lines.Add(OpCodeName[Op]+' '+EndString);
     Result:=n;
end;

procedure TSpecificInfoForm.ShowLSCRSpecs(Loc: Cardinal; Size: Cardinal);
var
   n        : cardinal;
   Op       : TOpcode;
   Stuff    : Boolean;
begin
     Screen.Cursor:=crHourglass;
     SpecMemo.Show;
     Analyzer.InputFile.Seek(Loc+8);
     Stuff:=False;
     n:=8;

     repeat
          Inc(n);
          if Stuff then
          begin
               Op:=TOpCode(Analyzer.InputFile.ReadByte + 256);
               Stuff:=False;
          end
          else
               Op:=TOpcode(Analyzer.InputFile.ReadByte);
          case Op of
              O_PUSH_NUMBER    : n:=n+ParameterPrint(Op);
              O_PUSH_VARIABLE  : n:=n+ParameterPrint(Op);
              O_STORE_VARIABLE : n:=n+ParameterPrint(Op);
              O_DEC_VARIABLE   : n:=n+ParameterPrint(Op);
              O_INC_VARIABLE   : n:=n+ParameterPrint(Op);
              O_JUMP           : n:=n+ParameterPrint(Op);
              O_HEAP_STUFF     : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              O_ROOM_STUFF     : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              O_ACTOR_STUFF    : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              O_CAMERA_STUFF   : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              O_VERB_STUFF   : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              O_WAIT_FOR_STUFF : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              O_BLAST_TEXT     : begin
                                    OpcodePrint(Op);
                                    Stuff:=True;
                                 end;
              SO_PRINT_STRING  :    n:=n+StringPrint(Op);
              O_SAY_LINE       :    n:=n+StringPrint(Op);
              O_SAY_LINE_SIMPLE:    n:=n+StringPrint(Op);
              O_PRINT_DEBUG    :    n:=n+StringPrint(Op);
          else
              OpcodePrint(Op);
          end;
     until n>=Size;
     Screen.Cursor := crDefault;
end;

procedure TSpecificInfoForm.ShowOBNASpecs(Loc: Cardinal; Size: Cardinal);
var
   n        : cardinal;
begin
     SpecificInfoForm.Height:=80;

     SpecLabel1.Caption:='Object Name:';
     SpecResultLabel1.Caption:='';
     Analyzer.InputFile.Seek(Loc+8);
     For n:=1 to Size-8 do
     begin
          SpecResultLabel1.Caption:=SpecResultLabel1.Caption+Chr(Analyzer.InputFile.ReadByte);
     end;
     If Size<=9 then
        SpecResultLabel1.Caption:='<nameless>';
     SpecLabel1.Show;
     SpecResultLabel1.Show;
end;

procedure TSpecificInfoForm.iMUSRead;
var
   FieldRead : String;
   n         : byte;
begin
     FieldRead:='';
     For n:=1 to 4 do
     begin
          FieldRead:=FieldRead+Chr(Analyzer.InputFile.ReadByte);
     end;
     If FieldRead='MAP ' then
     begin
     end;
     if FieldRead='FRMT' then
     begin
     end;
     if FieldRead='REGN' then
     begin
     end;
     if FieldRead='STOP' then
     begin
     end;
     if FieldRead='DATA' then
     begin
     end;
end;


procedure TSpecificInfoForm.ShowSOUNSpecs(Loc: Cardinal; Size: Cardinal);
var
   n        : cardinal;
   TypeRead : string;
begin
     SpecificInfoForm.Height:=80;

     SpecLabel1.Caption:='Sound Type:';
     TypeRead:='';
     Analyzer.InputFile.Seek(Loc+8);
     For n:=1 to 4 do
     begin
          TypeRead:=TypeRead+Chr(Analyzer.InputFile.ReadByte);
     end;
     SpecResultLabel1.Caption:='Unknown';
     if TypeRead='SOU ' then
        SpecResultLabel1.Caption:='Device Dependent Sound Files';
     if TypeRead='Crea' then
     begin
        SpecResultLabel1.Caption:='Creative Voice File (.VOC)';
        SaveAsVOCButton.Show;
        PlayButton.Show;
     end;
     if TypeRead='iMUS' then
     begin
        SpecResultLabel1.Caption:='iMUSE Digital Sound File';
        iMUSRead;
     end;

     SpecLabel1.Show;
     SpecResultLabel1.Show;
end;

procedure TSpecificInfoForm.ShowLABNSpecs(Loc: Cardinal; Size: Cardinal);
var
   MajorVersion: cardinal;
   MinorVersion: cardinal;
begin
     SpecificInfoForm.Height:=120;

     Analyzer.InputFile.Seek(Loc+4);
     SpecLabel1.Caption:='Fileformat Version:';
     MinorVersion:=Analyzer.InputFile.ReadInvWord;
     MajorVersion:=Analyzer.InputFile.ReadInvWord;
     SpecResultLabel1.Caption:=IntToStr(MajorVersion)+'.'+IntToStr(MinorVersion);
     SpecLabel2.Caption:='No. of files:';
     SpecResultLabel2.Caption:=ValueString(Analyzer.InputFile.ReadInvDWord);
     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
end;

procedure TSpecificInfoForm.ShowLB83Specs(Loc: Cardinal; Size: Cardinal);
var
   RString : string;
   RByte   : byte;
begin
     SpecificInfoForm.Height:=120;

     Analyzer.InputFile.Seek(Loc+8);
     SpecLabel1.Caption:='No. of files:';
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);
     Analyzer.InputFile.ReadByte;
     SpecLabel2.Caption:='Compile date:';
     RString:='';
     repeat
        RByte:=Analyzer.InputFile.ReadByte;
        if RByte <> 00 then
           RString:=RString+chr(RByte);
     until (RByte = 00) or (Analyzer.InputFile.FilePos >= (Loc + 32));
     SpecResultLabel2.Caption:=RString;

     SpecLabel3.Caption:='Unknown:';
     if Analyzer.InputFile.FilePos<=(Loc + 32 - 4) then
     begin
        Analyzer.InputFile.Seek(Loc+32-4);   // Go to last value
        SpecResultLabel3.Caption:=ValueString(Analyzer.InputFile.ReadDWord);
     end
     else
        SpecResultLabel3.Caption:='No entry';

     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
     SpecLabel3.Show;
     SpecResultLabel3.Show;
end;

procedure TSpecificInfoForm.ShowFRMTSpecs(Loc: Cardinal; Size: Cardinal);
begin
     SpecificInfoForm.Height:=180;
     SpecLabel1.Caption:='Sound Data Offset:';
     Analyzer.InputFile.Seek(Loc+8);
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel2.Caption:='Unknown:';
     SpecResultLabel2.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel3.Caption:='Bits per sample:';
     SpecResultLabel3.Caption:=IntToStr(Analyzer.InputFile.ReadDWord);

     SpecLabel4.Caption:='Samplerate:';
     SpecResultLabel4.Caption:=IntToStr(Analyzer.InputFile.ReadDWord)+' Hz';

     SpecLabel5.Caption:='Channels:';
     SpecResultLabel5.Caption:=IntToStr(Analyzer.InputFile.ReadDWord);

     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
     SpecLabel3.Show;
     SpecResultLabel3.Show;
     SpecLabel4.Show;
     SpecResultLabel4.Show;
     SpecLabel5.Show;
     SpecResultLabel5.Show;
end;

procedure TSpecificInfoForm.ShowTEXTSpecs(Loc: Cardinal; Size: Cardinal);
var
   RString : string;
   RByte   : byte;
begin
     SpecificInfoForm.Height:=180;

     SpecLabel1.Caption:='Unknown:';
     Analyzer.InputFile.Seek(Loc+8);
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel2.Caption:='Unknown:';
     SpecResultLabel2.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel3.Caption:='Unknown:';
     SpecResultLabel3.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel4.Caption:='Unknown:';
     SpecResultLabel4.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel5.Caption:='Text:';
     RString:='';
     repeat
        RByte:=Analyzer.InputFile.ReadByte;
        if RByte <> 00 then
           RString:=RString+chr(RByte);
     until (RByte = 00) or (Analyzer.InputFile.FilePos >= Loc + Size);
     SpecResultLabel5.Caption:=RString;
     SpecResultLabel5.WordWrap:=true;
     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
     SpecLabel3.Show;
     SpecResultLabel3.Show;
     SpecLabel4.Show;
     SpecResultLabel4.Show;
     SpecLabel5.Show;
     SpecResultLabel5.Show;
end;

procedure TSpecificInfoForm.ShowBUNTEXTSpecs(Loc: Cardinal; Size: Cardinal);
var
   RString : string;
   RByte   : byte;
begin
     SpecificInfoForm.Height:=120;

     SpecLabel1.Caption:='Sound Data Offset:';
     Analyzer.InputFile.Seek(Loc+8);
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel2.Caption:='Text:';
     RString:='';
     repeat
        RByte:=Analyzer.InputFile.ReadByte;
        if RByte <> 00 then
           RString:=RString+chr(RByte);
     until (RByte = 00) or (Analyzer.InputFile.FilePos >= Loc + Size);
     SpecResultLabel2.Caption:=RString;

     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
end;

procedure TSpecificInfoForm.ShowJUMPSpecs(Loc: Cardinal; Size: Cardinal);
begin
     SpecificInfoForm.Height:=180;
     SpecLabel1.Caption:='Hook position:';
     Analyzer.InputFile.Seek(Loc+8);
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel2.Caption:='Jump destination:';
     SpecResultLabel2.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel3.Caption:='Hook ID:';
     SpecResultLabel3.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel4.Caption:='Unknown:';
     SpecResultLabel4.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
     SpecLabel3.Show;
     SpecResultLabel3.Show;
     SpecLabel4.Show;
     SpecResultLabel4.Show;
end;

procedure TSpecificInfoForm.ShowREGNSpecs(Loc: Cardinal; Size: Cardinal);
begin
     SpecificInfoForm.Height:=100;
     SpecLabel1.Caption:='Region position:';
     Analyzer.InputFile.Seek(Loc+8);
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel2.Caption:='Length:';
     SpecResultLabel2.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel1.Show;
     SpecResultLabel1.Show;
     SpecLabel2.Show;
     SpecResultLabel2.Show;
end;

procedure TSpecificInfoForm.ShowSTOPSpecs(Loc: Cardinal; Size: Cardinal);
begin
     SpecificInfoForm.Height:=80;

     SpecLabel1.Caption:='Stop position:';
     Analyzer.InputFile.Seek(Loc+8);
     SpecResultLabel1.Caption:=ValueString(Analyzer.InputFile.ReadDWord);

     SpecLabel1.Show;
     SpecResultLabel1.Show;
end;

procedure TSpecificInfoForm.ShowSpecs(SpecType: TChunkType; Loc: Cardinal; Size: Cardinal);
begin
     InitTools;
     ChunkType:=SpecType;
     OldChunkType:=octUnknown;
     LABChunkType:=lctUnknown;
     //Jump to Chunk type specific view
     case SpecType of
         ctLOFF : ShowLOFFSpecs(Loc, Size);

         ctBOXD : ShowBOXDSpecs(Loc, Size);
         ctCLUT : ShowCLUTSpecs(Loc, Size);
         ctAPAL : ShowCLUTSpecs(Loc, Size);
         ctNPAL : ShowCLUTSpecs(Loc, Size);
         ctOBNA : ShowOBNASpecs(Loc, Size);

         ctVERB : ShowLSCRSpecs(Loc, Size);
         ctLSCR : ShowLSCRSpecs(Loc, Size);
         ctENCD : ShowLSCRSpecs(Loc, Size);
         ctEXCD : ShowLSCRSpecs(Loc, Size);
         ctSCRP : ShowLSCRSpecs(Loc, Size);
         ctSOUN : ShowSOUNSpecs(Loc, Size);

         ctADL  : ShowMIDSpecs(Loc, Size);
         ctROL  : ShowMIDSpecs(Loc, Size);
         ctGMD  : ShowMIDSpecs(Loc, Size);
         ctMIDI : ShowMIDSpecs(Loc, Size);
         ctSPK  : ShowMIDSpecs(Loc, Size);

         ctFRMT : ShowFRMTSpecs(Loc, Size);
         ctTEXT : ShowTEXTSpecs(Loc, Size);
     end;
end;

procedure TSpecificInfoForm.ShowLABSpecs(SpecType: TLABChunkType; Loc: Cardinal; Size: Cardinal);
begin
     InitTools;
     LABChunkType:=SpecType;
     ChunkType:=ctUnknown;
     OldChunkType:=octUnknown;
     //Jump to Chunk type specific view
     case SpecType of
         lctLABN  : ShowLABNSpecs(Loc, Size);
         lctLB83  : ShowLB83Specs(Loc, Size);
         lctIMC   : ShowIMCSpecs(Loc, Size);

         lctFRMT : ShowFRMTSpecs(Loc, Size);
         lctTEXT : ShowBUNTEXTSpecs(Loc, Size);
         lctREGN : ShowREGNSpecs(Loc, Size);
         lctJUMP : ShowJUMPSpecs(Loc, Size);
         lctSTOP : ShowSTOPSpecs(Loc, Size);
     end;
end;

procedure TSpecificInfoForm.ShowOldSpecs(SpecType: TOldChunkType; Loc: Cardinal; Size: Cardinal);
begin
     InitTools;
     OldChunkType:=SpecType;
     ChunkType:=ctUnknown;
     LABChunkType:=lctUnknown;
     //Jump to Chunk type specific view
     case SpecType of
         octPA  : ShowPASpecs(Loc, Size);
     end;
end;

procedure TSpecificInfoForm.SaveAsVocButtonClick(Sender: TObject);
var
   XORVal: byte;
   InputFileName: string;
   OutputFileName: string;
begin
     SpecInfoSaveDialog.Filter:='Creative VOC file|*.VOC';
     SpecInfoSaveDialog.Title:='Save as .VOC...';
     If SpecInfoSaveDialog.Execute then
     begin
            XORVal := MainForm.DecValueComboBox.ItemIndex;
            OutputFileName := SpecInfoSaveDialog.FileName;
            InputFileName := MainForm.InputFileEdit.Text;

            if FileExists(OutputFileName) then
            begin
               if MessageDlg('File already exists! Overwrite?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
                  Exit;
            end;
            Decrypter := TDecrypter.Create(XORVal, InputFileName, OutputFileName, Chunk[Analyzer.CurrChunk].Location+8, Chunk[Analyzer.CurrChunk].Location+Chunk[Analyzer.CurrChunk].Size);
            Decrypter.OnTerminate := MainForm.TermDecrypter;
     end;
end;

procedure TSpecificInfoForm.SaveAsMIDButtonClick(Sender: TObject);
var
   XORVal: byte;
   InputFileName: string;
   OutputFileName: string;
begin
     SpecInfoSaveDialog.Filter:='Standard MIDI file|*.MID';
     SpecInfoSaveDialog.Title:='Save as .MID...';
     If SpecInfoSaveDialog.Execute then
     begin
            XORVal := MainForm.DecValueComboBox.ItemIndex;
            OutputFileName := SpecInfoSaveDialog.FileName;
            InputFileName := MainForm.InputFileEdit.Text;

            if FileExists(OutputFileName) then
            begin
               if MessageDlg('File already exists! Overwrite?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
                  Exit;
            end;
            Analyzer.InputFile.Seek(Chunk[Analyzer.CurrChunk].Location+12);
            Decrypter := TDecrypter.Create(XORVal, InputFileName, OutputFileName,
              Chunk[Analyzer.CurrChunk].Location+Analyzer.InputFile.ReadDWord+16,
              Chunk[Analyzer.CurrChunk].Location+Chunk[Analyzer.CurrChunk].Size);
            Decrypter.OnTerminate := MainForm.TermDecrypter;
     end;
end;





procedure TSpecificInfoForm.FormResize(Sender: TObject);
begin
     Case ChunkType of
        ctCLUT, ctAPAL, ctNPAL : begin
                                 if (Width>(SpecImage.Width+ImageSplitter.MinSize)) then
                                   SpecScrollBox.Width:=SpecImage.Width
                                 else
                                   SpecScrollBox.Width:=Width-ImageSplitter.MinSize;
                                 end;
        ctBOXD : SpecScrollBox.Width:=Width-ImageSplitter.MinSize;
     end;
     Case OldChunkType of
        octPA : begin
                   if (Width>(SpecImage.Width+ImageSplitter.MinSize)) then
                     SpecScrollBox.Width:=SpecImage.Width
                   else
                     SpecScrollBox.Width:=Width-ImageSplitter.MinSize;
                end;
     end;
end;

procedure TSpecificInfoForm.SaveImageItemClick(Sender: TObject);
var
   OutputFileName: string;
   TempBitmap: TBitmap;
begin
     if SpecInfoSaveDialog.Execute then
     begin
        OutputFileName := SpecInfoSaveDialog.FileName;
        if FileExists(OutputFileName) then
        begin
           if MessageDlg('File already exists! Overwrite?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
              Exit;
        end;
        TempBitmap:=TBitmap.Create;
        TempBitmap.PixelFormat:=pf8bit;
        TempBitmap.Width:=MaxX+ImageBorder;
        TempBitmap.Height:=MaxY+ImageBorder;
        TempBitmap.Canvas.CopyRect(Rect(0,0,MaxX+ImageBorder,MaxY+ImageBorder),SpecImage.Canvas,Rect(0,0,MaxX+ImageBorder,MaxY+ImageBorder));
        TempBitmap.SaveToFile(OutputFileName);
        TempBitmap.Free;
     end;
end;

procedure TSpecificInfoForm.DecompressButtonClick(Sender: TObject);
var
   IMCLoc: Cardinal;
   IMCSize: Cardinal;
   NoOfMCMPs: Cardinal;
   n: Cardinal;
begin
     IMCLoc:=Chunk[Analyzer.CurrChunk].Location;
     IMCSize:=Chunk[Analyzer.CurrChunk].Size;
     Analyzer.InputFile.Seek(IMCLoc+4);
     NoOfMCMPs:=Analyzer.InputFile.ReadWord;
     for n:=0 to NoOfMCMPs-1 do
     begin
        Analyzer.InputFile.Seek(IMCLoc+7+n*9);
        MCMPDSize[n]:=Analyzer.InputFile.ReadDWord;
        MCMPSSize[n]:=Analyzer.InputFile.ReadDWord;
     end;

end;

end.
