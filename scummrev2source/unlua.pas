unit UnLua;

interface

uses
  classes;

type
  TLuaType = (LUA_T_NIL, LUA_T_NUMBER, LUA_T_STRING, LUA_T_ARRAY, LUA_T_PROTO,
              LUA_T_CPROTO, LUA_T_CLOSURE);
  PLocVar = ^TLocVar;
  TLocVar = record
    VarName: string;
    Line: integer;
  end;

  TConst = record
    LuaType: TLuaType;
    Value: Pointer;
  end;

  TProtoFunc = record
    Code : Pointer;
    Consts: TList;
    LineDefined: integer;
    FileName: string;
    LocVars: TList;
  end;

  TUnDumper = class
  public
    constructor Create(Offset: cardinal);
    destructor Destroy; override;
    function Undump: TProtoFunc;
  private
    Size: cardinal;
    ChunkOffset: cardinal;
    LuaOffs: cardinal;
    ProtoFunc: TProtoFunc;
    procedure LoadBlock(CodePtr: Pointer; Size: cardinal);
    procedure LoadLocals;
    procedure LoadConstants;
    function LoadCode: pointer;
    function LoadByte: byte;
    function LoadWord: word;
    function LoadLong: cardinal;
    function LoadString: string;
    function LoadFunction: TProtoFunc;
    function LoadHeader: boolean;
    function LoadSignature: boolean;
    function LoadChunk: TProtoFunc;
  end;

const
  ID_CHUNK = 27;
  SIGNATURE = 'Lua';
  GRIMLuaVersion = $31;
  GRIMNumberRep = $0446;

implementation

uses
  Main, Dialogs, SysUtils, SpecForm, Analyze;

constructor TUndumper.Create(Offset: cardinal);
var
  Chunk: TChunk;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  Size:=Chunk.Size;
  ChunkOffset:=Offset;
  LuaOffs:=Offset;
  ProtoFunc.Code:=nil;
  ProtoFunc.LocVars:=TList.Create;
end;

destructor TUndumper.Destroy;
var
  n: cardinal;
begin
  if ProtoFunc.Code<>nil then
    FreeMem(ProtoFunc.Code);
  if ProtoFunc.LocVars.Count>0 then
  begin
    for n:=ProtoFunc.LocVars.Count-1 downto 0 do
    begin
      Dispose(ProtoFunc.LocVars.Items[n]);
    end;
  end;
  ProtoFunc.LocVars.Free;
end;

function TUndumper.LoadByte: byte;
begin
  result:=Analyzer.InputFile.ReadByte(LuaOffs);
  Inc(LuaOffs);
end;

function TUndumper.LoadWord: word;
begin
  result:=Analyzer.InputFile.ReadWord(LuaOffs);
  Inc(LuaOffs,2);
end;

function TUndumper.LoadLong: cardinal;
begin
  result:=Analyzer.InputFile.ReadDWord(LuaOffs);
  Inc(LuaOffs,4);
end;

function TUndumper.LoadString: string;
var
  Size: cardinal;
  n: cardinal;
  RByte: byte;
begin
  result:='';
  Size:=LoadWord;
  if Size>0 then
  begin
    for n:=1 to Size do
    begin
      RByte:=Analyzer.InputFile.ReadByte(LuaOffs) xor $FF;
      if RByte<>0 then
        result:=result+chr(RByte);
      Inc(LuaOffs);
    end;
  end;
end;

procedure TUndumper.LoadBlock(CodePtr: Pointer; Size: cardinal);
begin
  Analyzer.InputFile.Position:=LuaOffs;
  Analyzer.InputFile.ReadBuffer(CodePtr^,Size);
  Inc(LuaOffs,Size);
end;

function TUndumper.LoadCode: Pointer;
var
  Size: cardinal;
  CodePtr: Pointer;
begin
  Size:=LoadLong;
  CodePtr:=AllocMem(Size);
  LoadBlock(CodePtr,Size);
  result:=CodePtr;
end;

procedure TUndumper.LoadConstants;
var
  NoOfConstants: cardinal;
  n: cardinal;
begin
//  NoOfConstants:=LoadWord;
//  SpecInfoForm.SpecInfoRichEdit.Lines.Add('No. of Constants: '+inttostr(NoOfConstants));
  if NoOfConstants=0 then
    Exit;
  for n:=1 to NoOfConstants do
  begin
  end;
end;

procedure TUndumper.LoadLocals;
var
  NoOfLocals: cardinal;
  n: cardinal;
  LocVar: PLocVar;
  UnknownCode: boolean;
begin
  UnknownCode:=false;
  NoOfLocals:=LoadWord;
//  SpecInfoForm.SpecInfoRichEdit.Lines.Add('No. of Locals: '+inttostr(NoOfLocals));
  if NoOfLocals=0 then
    Exit;
  for n:=0 to NoOfLocals-1 do
  begin
    New(LocVar);
    LocVar^.VarName:='';
    repeat
      LocVar^.Line:=LoadByte;
      if LocVar^.Line<>0 then
        LocVar^.VarName:=LocVar^.VarName+chr(LocVar^.Line);
      case LocVar^.Line of
        $00: begin end;
        $23: begin end;
        $4E: begin LocVar^.VarName:=LocVar^.VarName+' '+inttostr(LoadLong); break; end;
        $46: begin end;
        $53: begin LocVar^.VarName:=LocVar^.VarName+' '+LoadString; break; end;
        $56: begin end;
      else
        begin
          LocVar^.VarName:=LocVar^.VarName+' Unknown code encountered: '+ValueString(LocVar^.Line);
          UnknownCode:=true;
        end;
      end;
    until UnknownCode;
    ProtoFunc.LocVars.Add(LocVar);
  end;
end;

function TUndumper.LoadFunction: TProtoFunc;
begin
  ProtoFunc.LineDefined:=LoadByte;
  ProtoFunc.FileName:=LoadString;
  ProtoFunc.Code:=LoadCode;
  LoadLocals;
  LoadConstants;
end;

function TUndumper.LoadSignature: boolean;
var
  Version: byte;
  Numberrep: word;
  i: cardinal;
begin
  for i:=1 to length(SIGNATURE) do
  begin
    if chr(Analyzer.InputFile.ReadByte(LuaOffs))<>SIGNATURE[i] then
    begin
      MessageDlg('Invalid Signature. Expected Lua.',mtError,[mbOK],0);
      result:=false;
      Exit;
    end;
    Inc(LuaOffs);
  end;
  version:=Analyzer.InputFile.ReadByte(LuaOffs);
  Inc(LuaOffs);
  if version<>GRIMLuaVersion then
  begin
    MessageDlg(Format('Code not supported: version=0x%02x; expected 0x%02x',[version, GRIMLuaVersion]),mtError,[mbOK],0);
    result:=false;
    Exit;
  end;
  numberrep:=Analyzer.InputFile.ReadWord(LuaOffs);
  Inc(LuaOffs,2);
  if numberrep<>GRIMNumberRep then
  begin
    MessageDlg(Format('Invalid Number representation: read 0x%04x; expected 0x%04x',[NumberRep, GRIMNumberRep]),mtError,[mbOK],0);
    result:=false;
    Exit;
  end;
  Inc(LuaOffs,4);
  result:=true;
end;

function TUndumper.LoadHeader: boolean;
begin
  if LoadSignature then
  begin
    result:=true;
  end
  else
    result:=false;
end;

function TUndumper.LoadChunk: TProtoFunc;
begin
  if LoadHeader=false then
    Exit;
  result:=LoadFunction;
end;

function TUndumper.Undump: TProtoFunc;
var
  n: cardinal;
begin
  if Analyzer.InputFile.ReadByte(LuaOffs) <> ID_CHUNK then // Esc
    Exit
  else
  begin
    inc(LuaOffs);
    result:=LoadChunk;
  end;

  SpecInfoForm.SpecInfoRichEdit.Lines.Add(ProtoFunc.FileName);
  SpecInfoForm.SpecInfoRichEdit.Lines.Add('');
  SpecInfoForm.SpecInfoRichEdit.Lines.Add('Local Variables ('+inttostr(ProtoFunc.LocVars.Count)+'):');
  if ProtoFunc.LocVars.Count>0 then
  begin
    for n:=0 to ProtoFunc.LocVars.Count-1 do
    begin
      SpecInfoForm.SpecInfoRichEdit.Lines.Add(TLocVar(ProtoFunc.LocVars.Items[n]^).VarName);
    end;
  end;
end;

end.
