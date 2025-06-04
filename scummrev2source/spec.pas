unit Spec;

interface

uses
  Forms, ChunkSpecs, Analyze, SpecForm, Classes, Dialogs, Tables;

type
  TReadType = (rtByte, rtWord, rtInvWord, rtDWord, rtInvDWord, rtString);
  TInfo = class
  public
    procedure Nothing(AOffset: cardinal; ASize: cardinal);
    procedure LOFF(AOffset: cardinal; ASize: cardinal);
    procedure RMHD(AOffset: cardinal; ASize: cardinal);
    procedure TRNS(AOffset: cardinal; ASize: cardinal);
    procedure RMIM(AOffset: cardinal; ASize: cardinal);
    procedure RMIH(AOffset: cardinal; ASize: cardinal);
    procedure OFFS(AOffset: cardinal; ASize: cardinal);
    procedure IMAG(AOffset: cardinal; ASize: cardinal);
    procedure IMHD(AOffset: cardinal; ASize: cardinal);
    procedure BOXD(AOffset: cardinal; ASize: cardinal);
    procedure OBNA(AOffset: cardinal; ASize: cardinal);
    procedure MIDI(AOffset: cardinal; ASize: cardinal);
    procedure Crea(AOffset: cardinal; ASize: cardinal);
    procedure iMUS(AOffset: cardinal; ASize: cardinal);
    procedure AKHD(AOffset: cardinal; ASize: cardinal);

    procedure LB83(AOffset: cardinal; ASize: cardinal);
    procedure LABN(AOffset: cardinal; ASize: cardinal);
    procedure MCMP(AOffset: cardinal; ASize: cardinal);
    procedure COMP(AOffset: cardinal; ASize: cardinal);
    procedure FRMT(AOffset: cardinal; ASize: cardinal);
    procedure TEXT(AOffset: cardinal; ASize: cardinal);
    procedure REGN(AOffset: cardinal; ASize: cardinal);
    procedure JUMP(AOffset: cardinal; ASize: cardinal);
    procedure STOP(AOffset: cardinal; ASize: cardinal);
    procedure DATA(AOffset: cardinal; ASize: cardinal);
    procedure SCRP(AOffset: cardinal; ASize: cardinal);
    procedure fIMC(AOffset: cardinal; ASize: cardinal);
    procedure fIMU(AOffset: cardinal; ASize: cardinal);
    procedure fCMP(AOffset: cardinal; ASize: cardinal);

    procedure Palette(AOffset: cardinal; ASize: cardinal);

    procedure fIMX(AOffset: cardinal; ASize: cardinal);
    procedure fTXT(AOffset: cardinal; ASize: cardinal);
    procedure fCOS(AOffset: cardinal; ASize: cardinal);
    procedure fSET(AOffset: cardinal; ASize: cardinal);
    procedure fBM(AOffset: cardinal; ASize: cardinal);
    procedure fMAT(AOffset: cardinal; ASize: cardinal);
    procedure fBMP(AOffset: cardinal; ASize: cardinal);
    procedure fLUA(AOffset: cardinal; ASize: cardinal);

    procedure BM(AOffset: cardinal; ASize: cardinal);
    procedure HD(AOffset: cardinal; ASize: cardinal);
    procedure BX(AOffset: cardinal; ASize: cardinal);

    procedure RCNE(AOffset: cardinal; ASize: cardinal);

    constructor Create;
  private
    procedure ShowSpec1(Txt: String; Event: TNotifyEvent);
    procedure ShowSpec2(Txt: String; Event: TNotifyEvent);
    procedure ShowSpec3(Txt: String; Event: TNotifyEvent);
    procedure ShowLabel(LabelNo: cardinal; Txt: String; ReadType: TReadType; Offs: cardinal; Para: cardinal);
  end;

implementation

uses
  Main, SysUtils;

constructor TInfo.Create;
var
  ChunkType: TChunkType;
begin
  for ChunkType:=ctNull to ctEnd do
  begin
    ChunkSpec[ChunkType].SpecProc:=Nothing;
  end;
  ChunkSpec[ctLOFF].SpecProc:=LOFF;
  ChunkSpec[ctRMHD].SpecProc:=RMHD;
  ChunkSpec[ctTRNS].SpecProc:=TRNS;
  ChunkSpec[ctIMHD].SpecProc:=IMHD;
  ChunkSpec[ctRMIM].SpecProc:=RMIM;
  ChunkSpec[ctRMIH].SpecProc:=RMIH;
  ChunkSpec[ctOBIM].SpecProc:=RMIM;
  ChunkSpec[ctOFFS].SpecProc:=OFFS;
  ChunkSpec[ctIMAG].SpecProc:=IMAG;
  ChunkSpec[ctBOXD].SpecProc:=BOXD;
  ChunkSpec[ctOBNA].SpecProc:=OBNA;
  ChunkSpec[ctADL].SpecProc:=MIDI;
  ChunkSpec[ctROL].SpecProc:=MIDI;
  ChunkSpec[ctSPK].SpecProc:=MIDI;
  ChunkSpec[ctGMD].SpecProc:=MIDI;
  ChunkSpec[ctMIDI].SpecProc:=MIDI;
  ChunkSpec[ctAMI].SpecProc:=MIDI;
  ChunkSpec[ctCrea].SpecProc:=Crea;
  ChunkSpec[ctCLUT].SpecProc:=Palette;
  ChunkSpec[ctAPAL].SpecProc:=Palette;
  ChunkSpec[ctNPAL].SpecProc:=Palette;
  ChunkSpec[ctRGBS].SpecProc:=Palette;
  ChunkSpec[ctENCD].SpecProc:=SCRP;
  ChunkSpec[ctEXCD].SpecProc:=SCRP;
  ChunkSpec[ctVERB].SpecProc:=SCRP;
  ChunkSpec[ctLSCR].SpecProc:=SCRP;
  ChunkSpec[ctSCRP].SpecProc:=SCRP;
  ChunkSpec[ctiMUS].SpecProc:=iMUS;
  ChunkSpec[ctAKHD].SpecProc:=AKHD;

  ChunkSpec[ctLB83].SpecProc:=LB83;
  ChunkSpec[ctLABN].SpecProc:=LABN;
  ChunkSpec[ctMCMP].SpecProc:=MCMP;
  ChunkSpec[ctCOMP].SpecProc:=COMP;
  ChunkSpec[ctFRMT].SpecProc:=FRMT;
  ChunkSpec[ctTEXT].SpecProc:=TEXT;
  ChunkSpec[ctREGN].SpecProc:=REGN;
  ChunkSpec[ctJUMP].SpecProc:=JUMP;
  ChunkSpec[ctSTOP].SpecProc:=STOP;
  ChunkSpec[ctDATA].SpecProc:=DATA;
  ChunkSpec[fctIMC].SpecProc:=fIMC;
  ChunkSpec[fctWAV].SpecProc:=fIMC;
  ChunkSpec[fctIMX].SpecProc:=fIMX;
  ChunkSpec[fctIMU].SpecProc:=fIMU;
  ChunkSpec[fctCMP].SpecProc:=fCMP;
  ChunkSpec[fctMAT].SpecProc:=fMAT;
  ChunkSpec[fctBMP].SpecProc:=fBMP;
  ChunkSpec[fctLUA].SpecProc:=fLUA;

  ChunkSpec[ctHD].SpecProc:=HD;
  ChunkSpec[ctBX].SpecProc:=BX;
  ChunkSpec[ctBM].SpecProc:=BM;

  ChunkSpec[fctTXT].SpecProc:=fTXT;
  ChunkSpec[fctSET].SpecProc:=fSET;
  ChunkSpec[fctCOS].SpecProc:=fCOS;
  ChunkSpec[fctBM].SpecProc:=fBM;

  ChunkSpec[ctRCNE].SpecProc:=RCNE;

  ChunkSpec[ctPA].SpecProc:=Palette;

end;

procedure TInfo.ShowSpec1(Txt: String; Event: TNotifyEvent);
begin
  MainForm.Spec1Button.Caption:=Txt;
  MainForm.Spec1Button.OnClick:=Event;
  MainForm.Spec1Button.Show;

  MainForm.ExplorerPopupMenu.Items[pmSpec1Item].Caption:=Txt;
  MainForm.ExplorerPopupMenu.Items[pmSpec1Item].OnClick:=Event;
  MainForm.ExplorerPopupMenu.Items[pmSpec1Item].Visible:=true;
end;

procedure TInfo.ShowSpec2(Txt: String; Event: TNotifyEvent);
begin
  MainForm.Spec2Button.Caption:=Txt;
  MainForm.Spec2Button.OnClick:=Event;
  MainForm.Spec2Button.Show;

  MainForm.ExplorerPopupMenu.Items[pmSpec2Item].Caption:=Txt;
  MainForm.ExplorerPopupMenu.Items[pmSpec2Item].OnClick:=Event;
  MainForm.ExplorerPopupMenu.Items[pmSpec2Item].Visible:=true;
end;

procedure TInfo.ShowSpec3(Txt: String; Event: TNotifyEvent);
begin
  MainForm.Spec3Button.Caption:=Txt;
  MainForm.Spec3Button.OnClick:=Event;
  MainForm.Spec3Button.Show;

  MainForm.ExplorerPopupMenu.Items[pmSpec3Item].Caption:=Txt;
  MainForm.ExplorerPopupMenu.Items[pmSpec3Item].OnClick:=Event;
  MainForm.ExplorerPopupMenu.Items[pmSpec3Item].Visible:=true;
end;

procedure TInfo.ShowLabel(LabelNo: cardinal; Txt: String; ReadType: TReadType; Offs: cardinal; Para: cardinal);
begin
  MainForm.SpecTitleLabel[LabelNo].Caption:=Txt+':';
  case ReadType of
    rtByte:     MainForm.SpecLabel[LabelNo].Caption:=inttostr(Analyzer.InputFile.ReadByte(Offs));
    rtWord:     MainForm.SpecLabel[LabelNo].Caption:=inttostr(Analyzer.InputFile.ReadWord(Offs));
    rtInvWord:  MainForm.SpecLabel[LabelNo].Caption:=inttostr(Analyzer.InputFile.ReadInvWord(Offs));
    rtDWord:    MainForm.SpecLabel[LabelNo].Caption:=inttostr(Analyzer.InputFile.ReadDWord(Offs));
    rtInvDWord: MainForm.SpecLabel[LabelNo].Caption:=inttostr(Analyzer.InputFile.ReadInvDWord(Offs));
    rtString:   MainForm.SpecLabel[LabelNo].Caption:=Analyzer.InputFile.ReadString(Offs, Para);
  end;
  MainForm.SpecTitleLabel[LabelNo].Show;
  MainForm.SpecLabel[LabelNo].Show;
end;
// ********************** Nothing *******************

procedure TInfo.Nothing(AOffset: cardinal; ASize: cardinal);
begin
end;

// ********************** LOFF **********************

procedure TInfo.LOFF(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  ShowSpec1('View Room &List...',SpecInfoForm.ViewLOFF);
end;

// ********************** RMHD **********************

procedure TInfo.RMHD(AOffset: cardinal; ASize: cardinal);
begin
  if ASize<=14 then
  begin //Old
    ShowLabel(1,'Room Width',rtInvWord,AOffset+8,0);
    ShowLabel(2,'Room Height',rtInvWord,AOffset+10,0);
    ShowLabel(3,'No. of Objects',rtInvWord,AOffset+12,0);
  end
  else
  begin
    if ASize = 18 then
    begin //FT
      ShowLabel(1,'Unknown',rtInvDWord,AOffset+8,0);
      ShowLabel(2,'Room Width',rtInvWord,AOffset+12,0);
      ShowLabel(3,'Room Height',rtInvWord,AOffset+14,0);
      ShowLabel(4,'No. of Objects',rtInvWord,AOffset+16,0);
    end
    else
    begin //CMI
      ShowLabel(1,'MMucus Version',rtInvDWord,AOffset+8,0);
      ShowLabel(2,'Room Width',rtInvDWord,AOffset+12,0);
      ShowLabel(3,'Room Height',rtInvDWord,AOffset+16,0);
      ShowLabel(4,'No. of Objects',rtInvDWord,AOffset+20,0);
      ShowLabel(5,'No. of Z-Buffers',rtInvDWord,AOffset+24,0);
      ShowLabel(6,'Unknown',rtInvDWord,AOffset+28,0);
    end;
  end;
end;

// ********************** TRNS **********************

procedure TInfo.TRNS(AOffset: cardinal; ASize: cardinal);
begin
    ShowLabel(1,'Transparent Color?',rtInvWord,AOffset+8,0);
end;

// *********************** BM ***********************

procedure TInfo.BM(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  ShowSpec1('View &Image...',SpecInfoForm.ViewIMAGImage);
end;

// ********************** RMIH **********************

procedure TInfo.RMIH(AOffset: cardinal; ASize: cardinal);
begin
    ShowLabel(1,'No. of Z-Buffers',rtInvWord,AOffset+8,0);
end;

// ********************** RMIM **********************

procedure TInfo.RMIM(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  MainForm.Spec3Button.Top:=40;
//  ShowSpec1('View &Offsets...',SpecInfoForm.ViewRMIM);
  if Analyzer.InputFile.FindBlock('SMAP',AOffset,AOffset+ASize)<>-1 then
  begin
    if (Analyzer.InputFile.FindBlock('OBIM',AOffset,AOffset+ASize)<>-1) then
    begin
      if (Analyzer.InputFile.FindBlock('BSTR',AOffset,AOffset+ASize)=-1) then
      begin
        ShowSpec1('View &Image...',SpecInfoForm.ViewIMAGImage);
      end;
    end
    else
    begin
      ShowSpec1('View &Image...',SpecInfoForm.ViewIMAGImage);
    end;
  end
  else
  begin
    if (Analyzer.InputFile.FindBlock('IM01',AOffset,AOffset+ASize)<>-1) then
    begin
      ShowSpec1('View &Image...',SpecInfoForm.ViewBOMPImage);
    end;
  end;
{  if Analyzer.InputFile.FindBlock('SMAP',AOffset,AOffset+ASize)<>-1 then
  begin
    ShowSpec3('View &Z-Buffer...',SpecInfoForm.ViewZSTRImage);
  end;}
end;

// ********************** IMAG **********************

procedure TInfo.IMAG(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  If Analyzer.InputFile.FindBlock('BSTR',AOffset,AOffset+ASize)<>-1 then
  begin
    ShowSpec1('View &Image...',SpecInfoForm.ViewIMAGImage);
    Exit;
  end;
  If Analyzer.InputFile.FindBlock('BOMP',AOffset,AOffset+ASize)<>-1 then
  begin
    ShowSpec1('View &Image...',SpecInfoForm.ViewBOMPImage);
    Exit;
  end;
end;

// ********************** OFFS **********************

procedure TInfo.OFFS(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  ShowSpec1('View &Offsets...',SpecInfoForm.ViewOFFS);
end;

// ********************** IMHD **********************

procedure TInfo.IMHD(AOffset: cardinal; ASize: cardinal);
begin
  if (Analyzer.InputFile.ReadInvDWord(AOffset+48)=801) then
  begin
    ShowLabel(1,'Internal Name',rtString,AOffset+8,40);
    ShowLabel(2,'MMucus Version?',rtInvDWord,AOffset+48,0);
    ShowLabel(3,'No. of Images',rtInvDWord,AOffset+52,0);
    ShowLabel(4,'X Position',rtInvDWord,AOffset+56,0);
    ShowLabel(5,'Y Position',rtInvDWord,AOffset+60,0);
    ShowLabel(6,'Width',rtInvDWord,AOffset+64,0);
    ShowLabel(7,'Height',rtInvDWord,AOffset+68,0);
  end
  else
  begin
    if (Analyzer.InputFile.ReadInvWord(AOffset+8)=730) then
    begin
      ShowLabel(1,'MMucus Version?',rtInvWord,AOffset+8,0);
      ShowLabel(2,'Unknown',rtInvWord,AOffset+10,0);
      ShowLabel(3,'Identifier',rtInvWord,AOffset+12,0);
      ShowLabel(4,'No. of Images',rtInvWord,AOffset+14,0);
      ShowLabel(5,'X Position',rtInvWord,AOffset+16,0);
      ShowLabel(6,'Y Position',rtInvWord,AOffset+18,0);
      ShowLabel(7,'Width',rtInvWord,AOffset+20,0);
      ShowLabel(8,'Height',rtInvWord,AOffset+22,0);
    end
    else
    begin
      ShowLabel(1,'Identifier',rtInvWord,AOffset+8,0);
      ShowLabel(2,'No. of Images',rtInvWord,AOffset+10,0);
      ShowLabel(3,'Z-Buffers per Image',rtInvDWord,AOffset+12,0);
      ShowLabel(4,'X Position',rtInvWord,AOffset+16,0);
      ShowLabel(5,'Y Position',rtInvWord,AOffset+18,0);
      ShowLabel(6,'Width',rtInvWord,AOffset+20,0);
      ShowLabel(7,'Height',rtInvWord,AOffset+22,0);
      ShowLabel(8,'Unknown',rtInvDWord,AOffset+24,0);
    end;
  end;
end;

// *********************** BOXD *********************

procedure TInfo.BOXD(AOffset: cardinal; ASize: cardinal);
var
  Count: cardinal;
begin
  ShowLabel(1,'No. of Boxes',rtInvWord,AOffset+8,0);

  Count:=Analyzer.InputFile.ReadInvWord(AOffset+8);
  MainForm.SpecTitleLabel[2].Caption:='Format:';

  if (ASize > Count*20+10) then
  begin
    MainForm.SpecLabel[2].Caption:='Doubleword';
  end
  else
  begin
    MainForm.SpecLabel[2].Caption:='Word';
  end;
  MainForm.Spec1Button.Top:=36;

  ShowSpec1('View &Boxes...',SpecInfoForm.ViewBoxes);

  MainForm.SpecTitleLabel[2].Show;
  MainForm.SpecLabel[2].Show;
end;

// *********************** OBNA *********************

procedure TInfo.OBNA(AOffset: cardinal; ASize: cardinal);
begin
  if ASize=9 then
  begin
    MainForm.SpecTitleLabel[1].Caption:='Object Name:';
    MainForm.SpecLabel[1].Caption:='<unnamed>';
    MainForm.SpecTitleLabel[1].Show;
    MainForm.SpecLabel[1].Show;
  end
  else
  begin
    ShowLabel(1,'Object Name',rtString,AOffset+8,ASize-8);
  end;

end;

// **************** Palette *******************

procedure TInfo.Palette(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;

  ShowSpec1('View &Palette...',SpecInfoForm.ViewPalette);
end;

// *********************** MIDI **********************

procedure TInfo.MIDI(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;

  ShowSpec1('&Play',SpecInfoForm.PlayMID);
  ShowSpec2('&Save as .MID',SpecInfoForm.SaveAsMID);
end;

// *********************** AKHD *********************

procedure TInfo.AKHD(AOffset: cardinal; ASize: cardinal);
begin
  ShowLabel(1,'Unknown',rtInvWord,AOffset+8,0);
  ShowLabel(2,'Unknown',rtInvWord,AOffset+10,0);
  ShowLabel(3,'Unknown',rtInvWord,AOffset+12,0);
  ShowLabel(4,'Unknown',rtInvWord,AOffset+14,0);
  ShowLabel(5,'Codec',rtInvWord,AOffset+16,0);
  ShowLabel(6,'Unknown',rtInvWord,AOffset+18,0);
end;


// **************** Creative Voice File *******************

procedure TInfo.Crea(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  MainForm.Spec3Button.Top:=40;

  ShowSpec1('&Play',SpecInfoForm.PlayVOC);
  ShowSpec2('Save as .&VOC',SpecInfoForm.SaveAsVOC);
  ShowSpec3('Save as .&WAV',SpecInfoForm.SaveVOCToWAV);
end;

// *********************** LB83 *********************

procedure TInfo.LB83(AOffset: cardinal; ASize: cardinal);
var
  RByte: byte;
  RString: string;
  TextOffset: cardinal;
begin
    ShowLabel(1,'No. of Files',rtDWord,AOffset+8,0);

    TextOffset:=AOffset+13;
    repeat
      RByte:=Analyzer.InputFile.ReadByte(TextOffset);
      if RByte <> 00 then
        RString:=RString+chr(RByte);
      inc(TextOffset);
    until (RByte = 00) or (TextOffset >= AOffset + 32);

    MainForm.SpecTitleLabel[2].Caption:='Compile Date:';
    MainForm.SpecLabel[2].Caption:=RString;

    MainForm.SpecTitleLabel[3].Caption:='Unknown:';
    if TextOffset<=(AOffset + 28) then
      MainForm.SpecLabel[3].Caption:=ValueString(Analyzer.InputFile.ReadDWord(AOffset+28))
    else
      MainForm.SpecLabel[3].Caption:='No entry';

    MainForm.SpecTitleLabel[2].Show;
    MainForm.SpecLabel[2].Show;
    MainForm.SpecTitleLabel[3].Show;
    MainForm.SpecLabel[3].Show;
end;

// *********************** LABN *********************

procedure TInfo.LABN(AOffset: cardinal; ASize: cardinal);
var
  MajorVersion: cardinal;
  MinorVersion: cardinal;
begin
    MinorVersion:=Analyzer.InputFile.ReadInvWord(AOffset+4);
    MajorVersion:=Analyzer.InputFile.ReadInvWord(AOffset+6);
    MainForm.SpecTitleLabel[1].Caption:='Fileformat Version:';
    MainForm.SpecLabel[1].Caption:=IntToStr(MajorVersion)+'.'+IntToStr(MinorVersion);

    ShowLabel(2,'No. of Files',rtInvDWord,AOffset+8,0);

    MainForm.SpecTitleLabel[1].Show;
    MainForm.SpecLabel[1].Show;
end;

// **************** MCMP *******************

procedure TInfo.MCMP(AOffset: cardinal; ASize: cardinal);
begin
  ShowLabel(1,'No. of Entries',rtWord,AOffset+4,0);

  MainForm.Spec1Button.Top:=20;
  ShowSpec1('&Compression Info...',SpecInfoForm.ViewMCMP);
end;

// **************** COMP *******************

procedure TInfo.COMP(AOffset: cardinal; ASize: cardinal);
begin
  ShowLabel(1,'No. of Entries',rtDWord,AOffset+4,0);

  MainForm.Spec1Button.Top:=20;
  ShowSpec1('&Compression Info...',SpecInfoForm.ViewCOMP);
end;

// *********************** FRMT *********************

procedure TInfo.FRMT(AOffset: cardinal; ASize: cardinal);
begin
    ShowLabel(1,'Format Position',rtDWord,AOffset+8,0);
    ShowLabel(2,'Unknown',rtDWord,AOffset+12,0);
    ShowLabel(3,'Bits per Sample',rtDWord,AOffset+16,0);
    ShowLabel(4,'Samplerate',rtDWord,AOffset+20,0);
    ShowLabel(5,'Channels',rtDWord,AOffset+24,0);
    MainForm.SpecLabel[4].Caption:=MainForm.SpecLabel[4].Caption+' Hz';
end;

// *********************** TEXT *********************

procedure TInfo.TEXT(AOffset: cardinal; ASize: cardinal);
begin
    if (TFileType(MainForm.FileTypeComboBox.ItemIndex)=ftANIM) then
    begin
      ShowLabel(1,'Unknown',rtDWord,AOffset+8,0);
      ShowLabel(2,'Unknown',rtDWord,AOffset+12,0);
      ShowLabel(3,'Unknown',rtDWord,AOffset+16,0);
      ShowLabel(4,'Unknown',rtDWord,AOffset+20,0);
      ShowLabel(5,'Text',rtString,AOffset+24, ASize-24);
    end
    else
    begin
      ShowLabel(1,'Text Position',rtDWord,AOffset+8,0);
      ShowLabel(2,'Text',rtString,AOffset+12, ASize-12);
    end;
end;

// *********************** JUMP *********************

procedure TInfo.JUMP(AOffset: cardinal; ASize: cardinal);
begin
    ShowLabel(1,'Hook Position',rtDWord,AOffset+8,0);
    ShowLabel(2,'Jump Destination',rtDWord,AOffset+12,0);
    ShowLabel(3,'Hook ID',rtDWord,AOffset+16,0);
    ShowLabel(4,'Unknown',rtDWord,AOffset+20,0);
end;

// *********************** REGN *********************

procedure TInfo.REGN(AOffset: cardinal; ASize: cardinal);
begin
    ShowLabel(1,'Region Position',rtDWord,AOffset+8,0);
    ShowLabel(2,'Region Length',rtDWord,AOffset+12,0);
end;

// *********************** STOP *********************

procedure TInfo.STOP(AOffset: cardinal; ASize: cardinal);
begin
    ShowLabel(1,'Stop Position',rtDWord,AOffset+8,0);
end;

// *********************** DATA *********************

procedure TInfo.DATA(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.SpecTitleLabel[1].Caption:='Decompressed Size:';
    MainForm.SpecLabel[1].Caption:=ValueString(Analyzer.InputFile.ReadDWord(AOffset+4)+8);

    MainForm.SpecTitleLabel[1].Show;
    MainForm.SpecLabel[1].Show;
end;

// *********************** SCRP *********************

procedure TInfo.SCRP(AOffset: cardinal; ASize: cardinal);
begin
  if pos('COMI',Uppercase(ExtractFileName(Analyzer.InputFile.FileName)))=1 then
  begin
    MainForm.Spec1Button.Top:=8;
    ShowSpec1('&Decompile',SpecInfoForm.DecompileCMI);
  end;
end;

// *********************** iMUS *********************

procedure TInfo.iMUS(AOffset: cardinal; ASize: cardinal);
var
  ParChunk: TChunk;
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  if MainForm.ExplorerTreeView.Selected.Parent<>nil then
  begin
    ParChunk:=MainForm.ExplorerTreeView.Selected.Parent.Data;
    if Analyzer.InputFile.FindBlock('COMP',ParChunk.Offset,AOffset)<>-1 then
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayIMX);
      ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMX2WAV);
      Exit;
    end;
    if Analyzer.InputFile.FindBlock('MCMP',ParChunk.Offset,AOffset)<>-1 then
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayIMC);
      ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMC2WAV);
      Exit;
    end;
  end;
  if MainForm.ExplorerTreeView.Selected.GetPrevSibling<>nil then
  begin
    ParChunk:=MainForm.ExplorerTreeView.Selected.GetPrevSibling.Data;
    if ParChunk.Typ=ctCOMP then
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayIMX);
      ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMX2WAV);
      Exit;
    end;
    if ParChunk.Typ=ctMCMP then
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayIMC);
      ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMC2WAV);
      Exit;
    end;
  end;
  ShowSpec1('&Play',SpecInfoForm.PlayiMUS);
  ShowSpec2('&Save as .WAV',SpecInfoForm.SaveiMUS2WAV);
end;

// *********************** IMC **********************

procedure TInfo.fIMC(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.Spec1Button.Top:=8;
    MainForm.Spec2Button.Top:=8;

    if Analyzer.InputFile.ReadDWord(AOffset)=$4D434D50 then
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayIMC);
      ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMC2WAV)
    end
    else
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayWAV);
      ShowSpec2('&Save as .WAV',SpecInfoForm.SaveWAV);
    end;
end;

// *********************** IMX **********************

procedure TInfo.fIMX(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.Spec1Button.Top:=8;
    MainForm.Spec2Button.Top:=8;

    ShowSpec1('&Play',SpecInfoForm.PlayIMX);
    ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMX2WAV);
end;

// *********************** IMU **********************

procedure TInfo.fIMU(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.Spec1Button.Top:=8;
    MainForm.Spec2Button.Top:=8;

    if Analyzer.InputFile.FindBlock('COMP',AOffset,AOffset+20)<>-1 then
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayIMX);
      ShowSpec2('&Decompress to .WAV',SpecInfoForm.DecompressIMX2WAV);
    end
    else
    begin
      ShowSpec1('&Play',SpecInfoForm.PlayiMUS);
      ShowSpec2('&Save to .WAV',SpecInfoForm.SaveiMUS2WAV);
    end;
end;

// *********************** MAT **********************

procedure TInfo.fMAT(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.Spec1Button.Top:=8;

    ShowSpec1('View &Material',SpecInfoForm.ViewMAT);
end;

// *********************** CMP **********************

procedure TInfo.fCMP(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.Spec1Button.Top:=8;
    MainForm.Spec2Button.Top:=8;

    ShowSpec1('View &Palette',SpecInfoForm.ViewCMP);
    ShowSpec2('&Choose Palette', SpecInfoForm.ChooseCMP);
end;

// *********************** BMP **********************

procedure TInfo.fBMP(AOffset: cardinal; ASize: cardinal);
begin
    MainForm.Spec1Button.Top:=8;

    ShowSpec1('&View Image...',SpecInfoForm.ViewBMP);
end;

procedure TInfo.fLUA(AOffset: cardinal; ASize: cardinal);
begin
//    MainForm.Spec1Button.Top:=8;
//    ShowSpec1('&Undump...',SpecInfoForm.DecompileGRIM);
end;

procedure TInfo.fTXT(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  ShowSpec1('View &Text',SpecInfoForm.ViewText);
end;

procedure TInfo.fCOS(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  ShowSpec1('View &Costume script',SpecInfoForm.ViewText);
end;

procedure TInfo.fSET(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  ShowSpec1('View &Set',SpecInfoForm.ViewText);
end;

procedure TInfo.fBM(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  MainForm.Spec2Button.Top:=8;
  ShowSpec1('View &Image....',SpecInfoForm.ViewBM);
  ShowSpec2('View Image I&nfo...',SpecInfoForm.ViewBMInfo);
end;

// *********************** HD ***********************

procedure TInfo.HD(AOffset: cardinal; ASize: cardinal);
begin
  ShowLabel(1,'Room Width',rtInvWord,AOffset+6,0);
  ShowLabel(2,'Room Height',rtInvWord,AOffset+8,0);
  ShowLabel(3,'No. of Objects',rtInvWord,AOffset+10,0);
end;

procedure TInfo.BX(AOffset: cardinal; ASize: cardinal);
begin
  ShowLabel(1,'No. of Boxes',rtByte,AOffset+6,0);

  MainForm.Spec1Button.Top:=36;
  ShowSpec1('View &Boxes...',SpecInfoForm.ViewBoxes);
end;

procedure TInfo.RCNE(AOffset: cardinal; ASize: cardinal);
begin
  MainForm.Spec1Button.Top:=8;
  ShowSpec1('&Decrypt to Text....',SpecInfoForm.DecryptRCNE);
end;

end.
