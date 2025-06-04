unit Analyze;

interface

uses
  Windows, Classes, SysUtils, ComCtrls, ChunkSpecs, Input, Dialogs, Annot, Search;

type
  TChunk = class
  public
    Typ   : TChunkType;
    Offset: cardinal;
    Size  : cardinal;
    Node  : TTreeNode;
    Annot : string;
    FName : string;
    constructor Create(NewTyp: TChunkType; NewOffset: cardinal);
    destructor Destroy; override;
  end;

  TAnalyzer = class
  protected
    function ReadChunkName(Offset: Cardinal): string;
    function IsChunk(Name: string): boolean;
    function GetChunkType(Name: String): TChunkType;
    function GetChunkSize(Chunk: TChunk): cardinal;
    procedure ReadLABNChunks(ParentChunk: TChunk);
    procedure ReadLB83Chunks(ParentChunk: TChunk);
  public
    InputFile : TInputFile;
    MaxRead   : cardinal;
    function GetChunkAnnot(Chunk: TChunk): string;
    procedure ReadChildChunks(ParentChunk: TChunk);
    function ChunkHasChildren(Chunk: TChunk): boolean;
    procedure UpdateInfo(Chunk: TChunk);
    procedure FileDump(Chunk: TChunk);
    constructor Create(InputFileName: string);
    destructor Destroy; override;
  end;

implementation

uses
  Main, Flash;

function ValueString(Val: Cardinal): string;
begin
  result:=IntToStr(Val)+' (0x'+IntToHex(Val,8)+')';
end;

// *********** TChunk ***************
constructor TChunk.Create(NewTyp: TChunkType; NewOffset: cardinal);
begin
  Typ:=NewTyp;
  Offset:=NewOffset;
  FName:='';
end;

destructor TChunk.Destroy;
begin
  inherited;
end;

// *********** TAnalyzer ************
// Create Analyzer Object
constructor TAnalyzer.Create(InputFileName: string);
var
  NullChunk: TChunk;
begin
  InputFile:=TInputFile.Create(InputFileName,MainForm.DecValComboBox.ItemIndex);

  // Find fitting annotations
  FindAnnotations(InputFileName,InputFile.Size);
  //Create dummy chunk for parent to root
  NullChunk:=TChunk.Create(ctNull,0);
  try
    NullChunk.Size:=InputFile.Size;
    if (not MainForm.Preferences.UseFlashFiles) or (not FindFlash(ExtractFileName(InputFileName),InputFile.Size)) then
      ReadChildChunks(NullChunk);
  finally
    NullChunk.Free;
  end;
end;

destructor TAnalyzer.Destroy;
var
  n: cardinal;
begin
  ClearSearchList;
  MainForm.ExplorerTreeView.FullCollapse;
  MainForm.ExplorerTreeView.Items.Clear;

  if MainForm.AnnotationCheckListBox.Items.Count>0 then
  begin
  for n:=0 to MainForm.AnnotationCheckListBox.Items.Count-1 do
  begin
    MainForm.AnnotationCheckListBox.Items.Objects[n].Free;
  end;
  end;
  MainForm.AnnotationCheckListBox.Clear;
  InputFile.Free;
  SearchList.Free;
  MainForm.BlockIconImage.Picture.Icon.ReleaseHandle;
  MainForm.BigIconImageList.GetIcon(ImageNone,MainForm.BlockIconImage.Picture.Icon);
  MainForm.BlockTypeResultLabel.Caption:='n/a';
  MainForm.BlockOffsetResultEdit.Text:='n/a';
  MainForm.BlockSizeResultLabel.Caption:='n/a';
  MainForm.BlockSizeFrmtResultLabel.Caption:='n/a';
  MainForm.BlockDescResultLabel.Caption:='n/a';
  MainForm.AnnotationEdit.Text:='n/a';

  MainForm.AnnotTitleLabel.Caption:='n/a';
  MainForm.AnnotAuthorLabel.Caption:='n/a';
  MainForm.AnnotFileNameLabel.Caption:='n/a';
  MainForm.AnnotGameFileLabel.Caption:='n/a';
  MainForm.AnnotGameFileSizeLabel.Caption:='n/a';
  MainForm.CurrEditLabel.Caption:='n/a';
  inherited;
end;

function TAnalyzer.ReadChunkName(Offset: cardinal): string;
var
  i : cardinal;
begin
  result:='';
  if (MainForm.FileTypeComboBox.ItemIndex=Ord(ftOld)) or (MainForm.FileTypeComboBox.ItemIndex=Ord(ftOldRoom)) then
  begin
    for i:=Offset+4 to Offset+5 do
    begin
      result:=result+chr(InputFile.ReadByte(i));
    end;
  end
  else
  begin
    for i:=Offset to Offset+3 do
    begin
      result:=result+chr(InputFile.ReadByte(i));
    end;
  end;
end;

function TAnalyzer.IsChunk(Name: string): boolean;
var
  n : cardinal;
begin
  result:=true;
  if (Name='iMUS') or (Name='Crea') or (Name='Bl16') or (Name='Wave') then
    Exit;
  for n:=1 to length(Name) do
  begin
    If not (Name[n] in [' ','0'..'9','A'..'Z']) then
    begin
      result:=false;
    end;
  end;
end;

function TAnalyzer.GetChunkType(Name: String): TChunkType;
var
  n : TChunkType;
begin
  if (Name[length(Name)-2] in ['0'..'9']) and
     (Name[length(Name)-1] in ['0'..'9']) and
     (Name[length(Name)]   in ['0'..'9']) then
  begin
    result:=fctIMX;
    Exit;
  end;
  for n:=ctStart to ctEnd do
  begin
    if (ChunkSpec[n].Name[1]='.') and (pos('.',Name)>0) then
    begin
      if pos(ChunkSpec[n].Name,Uppercase(Name))=length(Name)-(length(ChunkSpec[n].Name)-1) then
      begin
        result:=n;
        Exit;
      end;
    end
    else
    begin
      if ChunkSpec[n].Name=Name then
      begin
        result:=n;
        Exit;
      end;
    end;
  end;
  result:=ctUnknown;
end;

function TAnalyzer.GetChunkSize(Chunk: TChunk): cardinal;
var
  Parent  : TChunk;
  Offset  : cardinal;
  BlockType: byte;
begin
  result:=0;
  case ChunkSpec[Chunk.Typ].SizeFrmt of
    csfStd  : result:=InputFile.ReadDWord(Chunk.Offset+4);
    csfNHS  : result:=InputFile.ReadDWord(Chunk.Offset+4)+8;
    csfNHSI : begin
                result:=InputFile.ReadDWord(Chunk.Offset+4)+8;
                while (Chunk.Offset+result<InputFile.Size) and not IsChunk(ReadChunkName(Chunk.Offset+result)) do
                begin
                  inc(result);
                end;
              end;
    csfInc  : result:=0;
    csfUnP  : begin
                if Chunk.Node.Parent<>nil then
                begin
                  Parent:=Chunk.Node.Parent.Data;
                  result:=Parent.Size-(Chunk.Offset-Parent.Offset);
                end
                else
                  result:=InputFile.Size;
              end;
    csfEnt  : case Chunk.Typ of
                ctCOMP : result:=InputFile.ReadDWord(Chunk.Offset+4)*16+18;
                ctMCMP : result:=InputFile.ReadWord(Chunk.Offset+4)*9+18;
              else
                result:=0;
              end;
    csfDir  : result:=0;
    csfOld  : result:=InputFile.ReadInvDWord(Chunk.Offset);
    csfCrea : begin
                if Chunk.Node.Parent.Parent=nil then
                begin
                  Offset:=Chunk.Offset+InputFile.ReadInvWord(Chunk.Offset+$14);
                  repeat
                    BlockType:=InputFile.ReadByte(Offset);
                    Inc(Offset);
                    case BlockType of
                      1 : Inc(Offset,InputFile.ReadInvTriByte(Offset)+3);
                      2 : Inc(Offset,InputFile.ReadInvTriByte(Offset)+3);
                      3 : Inc(Offset,6);
                      4 : Inc(Offset,5);
                      5 : Inc(Offset,InputFile.ReadInvTriByte(Offset)+3);
                      6 : Inc(Offset,5);
                      8 : Inc(Offset,7);
                    end;
                  until BlockType = 0;
                  result:=Offset-Chunk.Offset;
                end
                else
                begin
                  if Chunk.Node.Parent<>nil then
                  begin
                    Parent:=Chunk.Node.Parent.Data;
                    result:=Parent.Size-(Chunk.Offset-Parent.Offset);
                  end
                  else
                    result:=InputFile.Size;
                end;
              end;
    csfUnk  : begin
                if Chunk.Node.Parent<>nil then
                begin
                  Parent:=Chunk.Node.Parent.Data;
                  result:=Parent.Size-(Chunk.Offset-Parent.Offset);
                end
                else
                  result:=InputFile.Size;
              end;
  end;
end;

function TAnalyzer.GetChunkAnnot(Chunk: TChunk): string;
var
  n: cardinal;
  CurrAnnot: TAnnot;
begin
  result:='';
  if MainForm.AnnotationCheckListBox.Items.Count<1 then
  begin
    Exit;
  end;
  for n:=0 to MainForm.AnnotationCheckListBox.Items.Count-1 do
  begin
    if MainForm.AnnotationCheckListBox.Checked[n] then
    begin
      CurrAnnot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[n]);
      result:=CurrAnnot.ReadAnnot(ChunkSpec[Chunk.Typ].Name,Chunk.Offset);
      if result<>'' then Exit;
    end;
  end;
end;

function TAnalyzer.ChunkHasChildren(Chunk: TChunk): boolean;
var
  Offset: cardinal;
begin
    result:=false;
    case ChunkSpec[Chunk.Typ].ChildFrmt of
      co8 : begin
              Offset:=Chunk.Offset+8;
              if (Offset<MaxRead) and (IsChunk(ReadChunkName(Offset))) then
                result:=true
              else
                result:=false;
            end;
      co18: begin
              Offset:=Chunk.Offset+18;
              if (Offset<MaxRead) and (IsChunk(ReadChunkName(Offset))) then
                result:=true
              else
                result:=false;
            end;
      coLB83: begin
                Offset:=Chunk.Offset+8;
                if InputFile.ReadDWord(Offset)>0 then
                  result:=true
                else
                  result:=false;
              end;
      coLABN: begin
                Offset:=Chunk.Offset+8;
                if InputFile.ReadInvDWord(Offset)>0 then
                  result:=true
                else
                  result:=false;
              end;
      coFile: begin
                Offset:=Chunk.Offset;
                if (Offset<MaxRead) and (IsChunk(ReadChunkName(Offset))) then
                  result:=true
                else
                  result:=false;
              end;
      coOld : begin
                Offset:=Chunk.Offset+6;
                if (Offset<MaxRead) and (IsChunk(ReadChunkName(Offset))) then
                  result:=true
                else
                  result:=false;
              end;
      coOldS: begin
                Offset:=Chunk.Offset+8;
                if (Offset<MaxRead) and (IsChunk(ReadChunkName(Offset))) then
                  result:=true
                else
                  result:=false;
              end;
      coNone: begin
                result:=false;
              end;

    end;
end;

procedure TAnalyzer.ReadLABNChunks(ParentChunk: TChunk);
var
  DirOffset: cardinal;
  NameOffset: cardinal;
  NoOfFiles: cardinal;
  CurrFile: cardinal;
  Name: string;
  Typ: TChunkType;
  Offset: cardinal;
  Size: cardinal;
  Chunk: TChunk;
  RByte: byte;
begin
  NoOfFiles:=InputFile.ReadInvDWord(ParentChunk.Offset+8);
  DirOffset:=ParentChunk.Offset+20;
  NameOffset:=ParentChunk.Offset+NoOfFiles*16+16;
  MaxRead:=InputFile.Size;
  for CurrFile:=0 to NoOfFiles-1 do
  begin
    Name:='';
    Offset:=InputFile.ReadInvDWord(DirOffset);
    inc(DirOffset,4);
    Size:=InputFile.ReadInvDWord(DirOffset);
    inc(DirOffset,12);
    repeat
      RByte:=InputFile.ReadByte(NameOffset);
      if RByte<>0 then
          Name:=Name+chr(RByte);
      Inc(NameOffset);
    until (RByte=0);
    Typ:=GetChunkType(Name);
    if Typ=ctUnknown then Typ:=fctFileUnknown;
    Chunk:=TChunk.Create(Typ,Offset);
    Chunk.Size:=Size;
    Chunk.Node:=MainForm.ExplorerTreeView.Items.AddChildObject(ParentChunk.Node,Name,Chunk);
    Chunk.Node.ImageIndex:=ChunkSpec[Chunk.Typ].Image;
    Chunk.Node.SelectedIndex:=ChunkSpec[Chunk.Typ].Image;
    If MainForm.Preferences.TestBigChildren then
    begin
      If ChunkHasChildren(Chunk) then
      begin
        Chunk.Node.HasChildren:=true;
      end;
    end
    else
      Chunk.Node.HasChildren:=true;
    Chunk.FName:=Name;
    if (MainForm.Preferences.UseAnnotations) then
    begin
      Chunk.Annot:=GetChunkAnnot(Chunk);
      if Chunk.Annot<>'' then
      begin
        Chunk.Node.Text:=Chunk.Node.Text+' - '+Chunk.Annot;
      end;
    end;
  end;
end;

procedure TAnalyzer.ReadLB83Chunks(ParentChunk: TChunk);
var
  TableOffset: cardinal;
  DirOffset: cardinal;
  NoOfFiles: cardinal;
  CurrFile: cardinal;
  Name: string;
  Typ: TChunkType;
  Offset: cardinal;
  Chunk: TChunk;
  RByte: byte;
begin
  NoOfFiles:=InputFile.ReadDWord(ParentChunk.Offset+8);
  DirOffset:=ParentChunk.Offset+ParentChunk.Size;
  MaxRead:=InputFile.Size;
  for CurrFile:=0 to NoOfFiles-1 do
  begin
    Name:='';
    TableOffset:=DirOffset;
    repeat
      RByte:=InputFile.ReadByte(DirOffset);
      if RByte<>0 then
      begin
        if DirOffset=TableOffset+8 then
          Name:=Name+'.';
        Name:=Name+chr(RByte);
      end;
      Inc(DirOffset);
    until (DirOffset=TableOffset+11);
    Typ:=GetChunkType(Name);
    Inc(DirOffset);
    Offset:=InputFile.ReadDWord(DirOffset);
    Chunk:=TChunk.Create(Typ,Offset);
    Inc(DirOffset,4);
    Chunk.Size:=InputFile.ReadDWord(DirOffset);
    Inc(DirOffset,4);
    Chunk.Node:=MainForm.ExplorerTreeView.Items.AddChildObject(ParentChunk.Node,Name,Chunk);
    Chunk.Node.ImageIndex:=ChunkSpec[Chunk.Typ].Image;
    Chunk.Node.SelectedIndex:=ChunkSpec[Chunk.Typ].Image;
    If MainForm.Preferences.TestBigChildren then
    begin
      If ChunkHasChildren(Chunk) then
      begin
        Chunk.Node.HasChildren:=true;
      end;
    end
    else
      Chunk.Node.HasChildren:=true;
    if (MainForm.Preferences.UseAnnotations) then
    begin
      Chunk.Annot:=GetChunkAnnot(Chunk);
      if Chunk.Annot<>'' then
      begin
        Chunk.Node.Text:=Chunk.Node.Text+' - '+Chunk.Annot;
      end;
    end;
    Chunk.FName:=Name;
  end;
end;

procedure TAnalyzer.ReadChildChunks(ParentChunk: TChunk);
var
  Offset    : cardinal;
  Name      : string;
  Typ       : TChunkType;
  Chunk     : TChunk;
begin
  // Initialize Block reader
  Offset:=0;
  case ChunkSpec[ParentChunk.Typ].ChildFrmt of
    coNull    : Offset:=ParentChunk.Offset;
    co8       : Offset:=ParentChunk.Offset+8;
    co18      : Offset:=ParentChunk.Offset+18;
    coLB83    : begin
                  ReadLB83Chunks(ParentChunk);
                  Exit;
                end;
    coLABN    : begin
                  ReadLABNChunks(ParentChunk);
                  Exit;
                end;
    coFile    : Offset:=ParentChunk.Offset;
    coOld     : Offset:=ParentChunk.Offset+6;
    coOldS    : Offset:=ParentChunk.Offset+8;
    coNone    : begin
                  ParentChunk.Node.HasChildren:=false;
                  Exit;
                end;
  end;
  MaxRead:=ParentChunk.Offset+ParentChunk.Size;

  // Read sibling blocks loop
  repeat
    Name:=ReadChunkName(Offset);

    if IsChunk(Name) then
    begin
      Typ:=GetChunkType(Name);
      Chunk:=TChunk.Create(Typ,Offset);
    end
    else
    begin
      Typ:=ctUnknown;
      Chunk:=TChunk.Create(Typ,Offset);
      Name:=ChunkSpec[Chunk.Typ].Name;
    end;

    if ParentChunk.Typ=ctNull then
    begin
      Chunk.Node:=MainForm.ExplorerTreeView.Items.AddObject(nil,Name,Chunk);
    end
    else
    begin
      Chunk.Node:=MainForm.ExplorerTreeView.Items.AddChildObject(ParentChunk.Node,Name, Chunk);
    end;
    If (MainForm.Preferences.TestBigChildren) or (ParentChunk.Typ <> ctANIM) then
    begin
      If ChunkHasChildren(Chunk) then
      begin
        Chunk.Node.HasChildren:=true;
      end;
    end
    else
      Chunk.Node.HasChildren:=true;

    Chunk.Node.ImageIndex:=ChunkSpec[Chunk.Typ].Image;
    Chunk.Node.SelectedIndex:=ChunkSpec[Chunk.Typ].Image;
    Chunk.Size:=GetChunkSize(Chunk);
    if Chunk.Size > ParentChunk.Size then // Fix for chunks bigger than parents.
    begin
      Chunk.Typ:=ctUnknown;
      Chunk.Size:=GetChunkSize(Chunk);
    end;

  if (MainForm.Preferences.UseAnnotations) then
  begin
    Chunk.Annot:=GetChunkAnnot(Chunk);
    if Chunk.Annot<>'' then
    begin
      Chunk.Node.Text:=Chunk.Node.Text+' - '+Chunk.Annot;
    end;
  end;
    Offset:=Offset+Chunk.Size;

  //Patch for LB83
  if Chunk.Typ=ctLB83 then
    MaxRead:=Chunk.Offset+Chunk.Size;

  until Offset>=MaxRead;
end;

procedure TAnalyzer.UpdateInfo(Chunk: TChunk);
begin
  if (MainForm.BlockTypeResultLabel.Caption<>ChunkSpec[Chunk.Typ].Name)
  or (Chunk.Typ=ctOBIM)
  or (Chunk.Typ=ctIMAG)
  or (Chunk.Typ=ctRMIM) then
  begin
    MainForm.HideSpecInfo; // Hide all specific info controls
    MainForm.BlockIconImage.Picture.Icon.ReleaseHandle;
    MainForm.BigIconImageList.GetIcon(ChunkSpec[Chunk.Typ].Image,MainForm.BlockIconImage.Picture.Icon);
  end;
  MainForm.BlockTypeResultLabel.Caption:=ChunkSpec[Chunk.Typ].Name;
  MainForm.BlockOffsetResultEdit.Text:=ValueString(Chunk.Offset);
  MainForm.BlockSizeResultLabel.Caption:=ValueString(Chunk.Size);
  case ChunkSpec[Chunk.Typ].SizeFrmt of
    csfStd  : MainForm.BlockSizeFrmtResultLabel.Caption:='Standard';
    csfNHS  : MainForm.BlockSizeFrmtResultLabel.Caption:='Name and Size not Included';
    csfNHSI : MainForm.BlockSizeFrmtResultLabel.Caption:='Name and Size not Included - Inconsistent';
    csfInc  : MainForm.BlockSizeFrmtResultLabel.Caption:='Inconsistent';
    csfUnP  : MainForm.BlockSizeFrmtResultLabel.Caption:='Undefined - Based on Parent or Filesize';
    csfEnt  : MainForm.BlockSizeFrmtResultLabel.Caption:='Entry Based';
    csfDir  : MainForm.BlockSizeFrmtResultLabel.Caption:='Directory Table';
    csfOld  : MainForm.BlockSizeFrmtResultLabel.Caption:='Old SCUMM';
    csfCrea : MainForm.BlockSizeFrmtResultLabel.Caption:='VOC';
    csfUnk  : MainForm.BlockSizeFrmtResultLabel.Caption:='Unknown';
  end;
  MainForm.BlockDescResultLabel.Caption:=ChunkSpec[Chunk.Typ].Desc;
  MainForm.AnnotationEdit.Text:=Chunk.Annot;

  ChunkSpec[Chunk.Typ].SpecProc(Chunk.Offset, Chunk.Size);
end;

procedure TAnalyzer.FileDump(Chunk: TChunk);
var
  OutputFileName: string;
begin
  MainForm.SaveDialog.Filter:='';
  case Chunk.Typ of
    fctFileStart..fctFileUnknown : MainForm.SaveDialog.FileName:=Chunk.Node.Text;
  else
    MainForm.SaveDialog.FileName:=Chunk.Node.Text+'.srb';
  end;
  if MainForm.SaveDialog.Execute then
  begin
    OutputFileName:=MainForm.SaveDialog.FileName;
    MainForm.Status(0,'Dumping file to disk...');
    MainForm.Update;

    InputFile.DumpFile(OutputFileName,Chunk.Offset,Chunk.Size);

    MainForm.Status(0,' ');
  end;
end;

end.
