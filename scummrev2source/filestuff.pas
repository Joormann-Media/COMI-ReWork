unit FileStuff;

interface
  function RecycleFile(FileName: string): boolean;

implementation

uses
  ShellAPI;

function RecycleFile(FileName: string): boolean;
var
  FileOpStruct: TSHFileOpStruct;
begin
  FillChar(FileOpStruct,SizeOf(TSHFileOpStruct),0);
  with FileOpStruct do
  begin
    wFunc:=FO_DELETE;
    pFrom:=PChar(FileName);
    fFlags:=FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  end;
  result:=(ShFileOperation(FileOpStruct) = 0);
end;

end.

