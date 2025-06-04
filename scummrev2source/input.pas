unit Input;

interface

uses Classes, MMStream, SysUtils, Dialogs;

const
  BufferSize = $3FFFFFFF;

type
  FileBuffer= array[0..BufferSize] of byte;

  TInputFile  = class(TMMFile)
  public
    XORVal: byte;
    Attrs: integer;
    function ReadString(Offset: cardinal; MaxRead: cardinal): string;
    function ReadByte(Offset: cardinal): byte;
    function ReadInvTriByte(Offset: cardinal): longint;
    function ReadDWord(Offset: cardinal): longint;
    function ReadInvDWord(Offset: cardinal): longint;
    function ReadWord(Offset: cardinal): longint;
    function ReadInvWord(Offset: cardinal): longint;
    function FindBlock(SearchStr: string; StartOffs: cardinal; EndOffs: cardinal): longint;
    procedure DumpFile(AFile: string; AOffset: cardinal; ASize: cardinal);
    constructor Create(AFile: string; AXORVal: byte);
    destructor Destroy; override;
  end;


implementation

// *********** TInputFile ***********
constructor TInputFile.Create(AFile: string; AXORVal: byte);
begin
  XORVal:=AXORVal;
  Attrs:=FileGetAttr(AFile);
  if (Attrs and faReadOnly)>0 then
  begin
    FileSetAttr(AFile, $0);
  end;
  inherited Create(AFile,'',fmOpenReadWrite);
end;

destructor TInputFile.Destroy;
begin
  FileSetAttr(FileName, Attrs);
  inherited;
end;

function TInputFile.ReadString(Offset: cardinal; MaxRead: cardinal): string;
var
  CurrOffs: cardinal;
  RByte: byte;
begin
  CurrOffs:=Offset;
  result:='';
  repeat
    RByte:=ReadByte(CurrOffs);
    if RByte <> 00 then
      result:=result+chr(RByte);
    inc(CurrOffs);
  until (RByte = 00) or (CurrOffs>Offset+MaxRead);
end;

function TInputFile.ReadDWord(Offset: cardinal): longint;
begin
  if XORVal=0 then
  begin
  result:=  (FileBuffer(Memory^)[Offset]) shl 24
          + (FileBuffer(Memory^)[Offset+1]) shl 16
          + (FileBuffer(Memory^)[Offset+2]) shl 8
          + (FileBuffer(Memory^)[Offset+3]);
  end
  else
  begin
  result:=  (FileBuffer(Memory^)[Offset] xor XORVal) shl 24
          + (FileBuffer(Memory^)[Offset+1] xor XORVal) shl 16
          + (FileBuffer(Memory^)[Offset+2] xor XORVal) shl 8
          + (FileBuffer(Memory^)[Offset+3] xor XORVal);
  end;
end;

function TInputFile.ReadInvTriByte(Offset: cardinal): longint;
begin
  if XORVal=0 then
  begin
  result:=  (FileBuffer(Memory^)[Offset])
          + (FileBuffer(Memory^)[Offset+1]) shl 8
          + (FileBuffer(Memory^)[Offset+2]) shl 16;
  end
  else
  begin
  result:=  (FileBuffer(Memory^)[Offset] xor XORVal)
          + (FileBuffer(Memory^)[Offset+1] xor XORVal) shl 8
          + (FileBuffer(Memory^)[Offset+2] xor XORVal) shl 16;
  end;
end;

function TInputFile.ReadInvDWord(Offset: cardinal): longint;
begin
  if XORVal=0 then
  begin
  result:=  (FileBuffer(Memory^)[Offset])
          + (FileBuffer(Memory^)[Offset+1]) shl 8
          + (FileBuffer(Memory^)[Offset+2]) shl 16
          + (FileBuffer(Memory^)[Offset+3]) shl 24;
  end
  else
  begin
  result:=  (FileBuffer(Memory^)[Offset] xor XORVal)
          + (FileBuffer(Memory^)[Offset+1] xor XORVal) shl 8
          + (FileBuffer(Memory^)[Offset+2] xor XORVal) shl 16
          + (FileBuffer(Memory^)[Offset+3] xor XORVal) shl 24;
  end;
end;

function TInputFile.ReadWord(Offset: cardinal): longint;
begin
  if XORVal=0 then
  begin
  result:=  (FileBuffer(Memory^)[Offset]) shl 8
          + (FileBuffer(Memory^)[Offset+1]);
  end
  else
  begin
  result:=  (FileBuffer(Memory^)[Offset] xor XORVal) shl 8
          + (FileBuffer(Memory^)[Offset+1] xor XORVal);
  end;
end;

function TInputFile.ReadInvWord(Offset: cardinal): longint;
begin
  if XORVal=0 then
  begin
  result:=  (FileBuffer(Memory^)[Offset])
          + (FileBuffer(Memory^)[Offset+1]) shl 8;
  end
  else
  begin
  result:=  (FileBuffer(Memory^)[Offset] xor XORVal)
          + (FileBuffer(Memory^)[Offset+1] xor XORVal) shl 8;
  end;
end;

function TInputFile.ReadByte(Offset: cardinal): byte;
begin
  result:=0;
  try
  if XORVal=0 then
    result:= FileBuffer(Memory^)[Offset]
  else
    result:= FileBuffer(Memory^)[Offset] xor XORVal;
  except
    on EAccessViolation do
    begin
      MessageDlg('Read beyond end of file!',mtError,[mbOK],0);
    end;
  end;
end;

procedure TInputFile.DumpFile(AFile: string; AOffset: cardinal; ASize: cardinal);
const
  DumpBufferSize = 262144;
var
  OutputFile: TFileStream;
  Extracted: cardinal;
  Buffer: array[0..DumpBufferSize-1] of byte;
  BufferS: cardinal;
  n: cardinal;
begin
  OutputFile:=TFileStream.Create(AFile, fmCreate or fmShareCompat);
  Seek(AOffset,soFromBeginning);
  Extracted:=0;
  repeat
    if (Extracted+DumpBufferSize)<ASize then
      BufferS:=DumpBufferSize
    else
      BufferS:=ASize-Extracted;
    BufferS:=Read(Buffer,BufferS);
    for n:=0 to DumpBufferSize-1 do
    begin
      Buffer[n]:=Buffer[n] xor XORVal;
    end;
    OutputFile.Write(Buffer,BufferS);
    Extracted:=Extracted+BufferS;
  until (Extracted>=ASize) or (BufferS<DumpBufferSize);
  Seek(0,soFromBeginning);
  OutputFile.Free;
end;

function TInputFile.FindBlock(SearchStr: string; StartOffs: cardinal; EndOffs: cardinal): longint;
var
  Position: cardinal;
  PosOffs: cardinal;
begin
  result:=-1;
  for Position:=StartOffs to EndOffs do
  begin
    if Chr(ReadByte(Position))=SearchStr[1] then
    begin
      for PosOffs:=1 to length(SearchStr)-1 do
      begin
        if Chr(ReadByte(Position+PosOffs))<>SearchStr[PosOffs+1] then
          Break;
        if PosOffs = length(SearchStr)-1 then
        begin
          result:=Position;
          Exit;
        end;
      end;
    end;
  end;
end;

end.
