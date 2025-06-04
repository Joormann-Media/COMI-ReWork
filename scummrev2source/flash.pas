unit Flash;

interface
uses
  Input, Classes;

function FindFlash(AResFile: string; AResFileSize: cardinal): boolean;
procedure SaveFlash;

implementation
uses
  Controls, SysUtils, Forms, Main, Analyze, ComCtrls, ChunkSpecs, Dialogs, StrLib,
  Annot;

var
  Offset: cardinal;

function FindFlash(AResFile: string; AResFileSize: cardinal): boolean;
type
  Buffer = array[0..$3FFFFFFF] of byte;
var
  FlashFile: TFileStream;
  SearchRec: TSearchRec;
  Found: longint;
  FlashFileName: string;
  FlashFileSize: cardinal;
  Chunk: TChunk;
  ParentNode: TTreeNode;
  NoOfBlocks: cardinal;
  n, n1: cardinal;
  Level: cardinal;
  Name: string;
  Offset: cardinal;
  P: pointer;
  ChunkType: TChunkType;
  ChunkOffs: cardinal;
  Expand: boolean;

function ReadByte: byte;
begin
  result:=Buffer(P^)[Offset];
  Inc(Offset);
end;

function ReadWord: cardinal;
begin
  result:=Buffer(P^)[Offset] shl 8 +
    Buffer(P^)[Offset+1];
  Inc(Offset,2);
end;

function ReadDWord: cardinal;
begin
  result:=Buffer(P^)[Offset] shl 24 +
          Buffer(P^)[Offset+1] shl 16 +
          Buffer(P^)[Offset+2] shl 8 +
          Buffer(P^)[Offset+3];
  Inc(Offset,4);
end;

function ReadString: string;
var
  RByte: Byte;
begin
  result:='';
  repeat
    RByte:=ReadByte;
    if RByte<>0 then
      result:=result+char(RByte);
  until RByte = 0
end;

begin
  Offset:=0;
  FlashDir:=ExtractFileDir(Application.ExeName)+'\Flash';
  Found:=FindFirst(FlashDir+'\*.srf',faAnyFile,SearchRec);
  try
    repeat
      if Found = 0 then
      begin
        FlashFile:=TFileStream.Create(FlashDir+'\'+SearchRec.Name,fmOpenRead or fmShareCompat);
        GetMem(P, FlashFile.Size);
        FlashFile.Read(P^,FlashFile.Size);
        try
          Offset:=0;
          if ReadDWord=$666C7368 then // 'flsh'
          begin
            FlashFileName:=ReadString;
            if Uppercase(FlashFileName)=Uppercase(AResFile) then
            begin
              FlashFileSize:=ReadDWord;
              if FlashFileSize = AResFileSize then
              begin
                MainForm.Status(0,'Reading Flash File...');
                MainForm.Update;
                MainForm.ExplorerTreeView.Items.BeginUpdate;
                try
                  MainForm.ExplorerTreeView.OnExpanding:=nil;
                  NoOfBlocks:=ReadDWord;
                  ParentNode:=nil;
                  Expand:=false;
                  Chunk:=nil;
                  for n:=0 to NoOfBlocks-1 do
                  begin
                    Level:=ReadWord;
                    if Chunk<>nil then
                    begin
                      If Level>Chunk.Node.Level then
                      begin
                        ParentNode:=Chunk.Node; Expand:=true;
                      end;
                      if Level<Chunk.Node.Level then
                      begin
                        ParentNode:=Chunk.Node;
                        for n1:=Level to Chunk.Node.Level do
                        begin
                          ParentNode:=ParentNode.Parent;
                        end;
                      end;
                    end;
                    ChunkType:=TChunkType(ReadWord);
                    ChunkOffs:=ReadDWord;
                    Chunk:=TChunk.Create(ChunkType,ChunkOffs);
                    Name:=ReadString;
                    if Name='' then
                      Name:=ChunkSpec[Chunk.Typ].Name;
                    Chunk.Node:=MainForm.ExplorerTreeView.Items.AddChildObject(ParentNode,Name,Chunk);
                    Chunk.Size:=ReadDWord;
                    if ReadByte = 1 then
                      Chunk.Node.HasChildren:=true
                    else
                      Chunk.Node.HasChildren:=false;

                    if (MainForm.Preferences.UseAnnotations) then
                    begin
                      Chunk.Annot:=Analyzer.GetChunkAnnot(Chunk);
                      if Chunk.Annot<>'' then
                      begin
                        Chunk.Node.Text:=Chunk.Node.Text+' - '+Chunk.Annot;
                      end;
                    end;

                    Chunk.Node.ImageIndex:=ChunkSpec[Chunk.Typ].Image;
                    Chunk.Node.SelectedIndex:=ChunkSpec[Chunk.Typ].Image;
                    if Expand then
                    begin
                      Expand:=false;
                      ParentNode.Expand(false);
                    end;
                  end;
                  MainForm.ExplorerTreeView.OnExpanding:=MainForm.ExplorerTreeViewExpanding;
                  result:=true;
                  exit;
                finally
                  MainForm.ExplorerTreeView.Items.EndUpdate;
                end;
              end;
            end;
          end;
        finally
          FlashFile.Free;
          FreeMem(P);
        end;
      end;
      Found:=FindNext(SearchRec);
    until (Found <> 0);
  finally
    FindClose(SearchRec);
  end;
  result:=false;
end;

procedure SaveFlash;
var
  OutputFile: TFileStream;
  Buffer: array[0..1000] of byte;
  n: cardinal;
  FName: string;
  Chunk: TChunk;
  Ch: cardinal;
  Node: TTreeNode;

procedure WriteDWord(Value: cardinal);
begin
  Buffer[Offset]:=lo(Value shr 24);
  Buffer[Offset+1]:=lo(Value shr 16);
  Buffer[Offset+2]:=lo(Value shr 8);
  Buffer[Offset+3]:=lo(Value);
  Inc(Offset,4);
end;
procedure WriteWord(Value: cardinal);
begin
  Buffer[Offset]:=lo(Value shr 8);
  Buffer[Offset+1]:=lo(Value);
  Inc(Offset,2);
end;
begin
  FlashDir:=ExtractFileDir(Application.ExeName)+'\Flash';
  MainForm.FlashSaveDialog.InitialDir:=FlashDir;
  MainForm.FlashSaveDialog.FileName:=ForceExtension(ExtractFileName(Analyzer.InputFile.FileName),'.srf');

  if MainForm.FlashSaveDialog.Execute then
  begin
    Screen.Cursor:=crHourGlass;
    MainForm.Status(0,'Saving Flash File...');
    MainForm.Update;
    try
      Buffer[0]:=ord('f'); Buffer[1]:=ord('l'); Buffer[2]:=ord('s'); Buffer[3]:=ord('h');
      FName:=ExtractFileName(Analyzer.InputFile.FileName);
      for n:=1 to length(FName) do
      begin
        Buffer[3+n]:=ord(FName[n]);
      end;
      Offset:=4+length(FName);
      Buffer[Offset]:=0;
      Inc(Offset);
      WriteDWord(Analyzer.InputFile.Size);
      WriteDWord(MainForm.ExplorerTreeView.Items.Count);
      OutputFile:=TFileStream.Create(MainForm.FlashSaveDialog.FileName, fmCreate or fmShareCompat);
      OutputFile.Write(Buffer,Offset);
      Node:=MainForm.ExplorerTreeView.Items[0];
      repeat
        Chunk:=Node.Data;

        Offset:=0;

        // Write Tree Position
        WriteWord(Chunk.Node.Level);

        // Write Block Type
        WriteWord(ord(Chunk.Typ));

        // Write Block Offset
        WriteDWord(Chunk.Offset);

        // Write Block Filename if any
        if length(Chunk.FName)>0 then
        begin
          for Ch:=0 to length(Chunk.FName)-1 do
          begin
            Buffer[Offset+Ch]:=ord(Chunk.FName[Ch+1]);
          end;
        end;
        Inc(Offset,length(Chunk.FName));
        Buffer[Offset]:=0;
        Inc(Offset);

        // Write Block Size
        WriteDWord(Chunk.Size);

        // Write Block HasChildren
        if Chunk.Node.HasChildren then
          Buffer[Offset]:=1
        else
          Buffer[Offset]:=0;
        Inc(Offset);

        OutputFile.Write(Buffer,Offset);
        Node:=Chunk.Node.GetNext;
      until Node=nil;
      OutputFile.Free;
    finally
      Screen.Cursor:=crDefault;
      MainForm.Status(0,' ');
    end;
  end;
end;

end.
