unit StrLib;

interface
  function ForceExtension(FileName: string; Extension: string): string;
  function IntToBin(Integ: cardinal; NoOfBits: byte): string;
  function HexToIntDef(HexStr: string; Default: longint): longint;
implementation

uses
  SysUtils;

function HexToIntDef(HexStr: string; Default: longint): longint;
var
  n: cardinal;
begin
  result:=0;
  if HexStr='' then
  begin
    result:=Default;
    Exit;
  end;
  For n:=1 to length(HexStr) do
  begin
    result:=result shl 4;
    Case Upcase(HexStr[n]) of
      '0'..'9': result:=result+StrToInt(HexStr[n]);
      'A'     : result:=result+10;
      'B'     : result:=result+11;
      'C'     : result:=result+12;
      'D'     : result:=result+13;
      'E'     : result:=result+14;
      'F'     : result:=result+15;
    else
    begin
      result:=Default;
      Exit;
    end;
    end;
  end;
end;

function ForceExtension(FileName: string; Extension: string): string;
var
  OldExtension: string;
begin
  result:=FileName;
  OldExtension:=ExtractFileExt(FileName);
  Delete(result,pos(OldExtension,result),length(OldExtension));
  result:=result+Extension;
end;

function IntToBin(Integ: cardinal; NoOfBits: byte): string;
var
  n: cardinal;
begin
  result:='';
  for n:=1 to NoOfBits do
  begin
    if (Integ and 1) = 1 then
      result:='1'+result
    else
      result:='0'+result;
    Integ:=Integ shr 1;
  end;
end;

end.
