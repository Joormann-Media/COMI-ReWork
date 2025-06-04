unit Preanalyze;

interface

uses
  SysUtils, Input, ChunkSpecs, Dialogs;

type
  TPreAnalyzer = class
  protected
    InputFile: TInputFile;
  public
    XORVal: byte;
    FileType: TFileType;
    function FindFileFormat: boolean;
    constructor Create(AFile: string);
    destructor Destroy; override;
  end;

implementation

uses
  Main;

constructor TPreAnalyzer.Create(AFile: string);
begin
  InputFile:=TInputFile.Create(AFile,0);
end;

function TPreAnalyzer.FindFileFormat: boolean;
var
  Magic: string;
  i : cardinal;
  TempFileType: TFileType;
  TempChunkType: TChunkType;
  XORIndex: byte;
  Size: cardinal;
begin
  // Check various XOR Values for decryption looking for headers.
  for XORIndex:=0 to NoOfXORTries-1 do
  begin
    InputFile.XORVal:=XORTries[XORIndex];
    Magic:='';
    for i:=0 to 3 do
    begin
      Magic:=Magic+chr(InputFile.ReadByte(i));
    end;
    for TempFileType:=ftStdSCUMM to Pred(ftOld) do
    begin
      if Magic=ChunkSpec[HeaderSpec[TempFileType]].Name then
      begin
        if TempFileType=ftMonster then
        begin
          Size:=InputFile.ReadDWord(4);
          if Size<>0 then
            Continue;
        end;
        FileType:=TempFileType;
        XORVal:=InputFile.XORVal;
        result:=true;
        Exit;
      end;
    end;
  end;

  // Test for old format looking for headers
  for XORIndex:=0 to NoOfXORTries-1 do
  begin
    InputFile.XORVal:=XORTries[XORIndex];
    Magic:='';
    for i:=4 to 5 do
    begin
      Magic:=Magic+chr(InputFile.ReadByte(i));
    end;
    for TempFileType:=ftOld to ftOldRoom do
    begin
      if (Magic=ChunkSpec[HeaderSpec[TempFileType]].Name) then
      begin
        FileType:=TempFileType;
        XORVal:=InputFile.XORVal;
        result:=true;
        Exit;
      end;
    end;
  end;

  // Check various XOR Values for decryption looking for any known chunk.
  for XORIndex:=0 to NoOfXORTries-1 do
  begin
    InputFile.XORVal:=XORTries[XORIndex];
    Magic:='';
    for i:=0 to 3 do
    begin
      Magic:=Magic+chr(InputFile.ReadByte(i));
    end;
    for TempChunkType:=ctStart to ctEnd do
    begin
      if Magic=ChunkSpec[TempChunkType].Name then
      begin
        FileType:=ftStdSCUMM;
        XORVal:=InputFile.XORVal;
        MessageDlg('Unknown header! (but recognized chunk) Fileformat not certain - Guessing at: '+#13+#10+'Filetype: '+FileTypeName[FileType]+', Decrypt value: '+ValueString(XORVal),mtWarning,[mbOK],0);
        result:=true;
        Exit;
      end;
    end;
  end;

  // Test for old format looking for any known chunk.
  for XORIndex:=0 to NoOfXORTries-1 do
  begin
    InputFile.XORVal:=XORTries[XORIndex];
    Magic:='';
    for i:=4 to 5 do
    begin
      Magic:=Magic+chr(InputFile.ReadByte(i));
    end;
    for TempChunkType:=ctStart to ctEnd do
    begin
      if (Magic=ChunkSpec[TempChunkType].Name) then
      begin
        FileType:=ftOld;
        XORVal:=InputFile.XORVal;
        MessageDlg('Unknown header! (but recognized chunk) Fileformat not certain - Guessing at: '+#13+#10+'Filetype: '+FileTypeName[FileType]+', Decrypt value: '+ValueString(XORVal),mtWarning,[mbOK],0);
        result:=true;
        Exit;
      end;
    end;
  end;

  result:=false;
end;

destructor TPreAnalyzer.Destroy;
begin
  InputFile.Free;
  inherited;
end;

end.
