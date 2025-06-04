unit Search;

interface

uses
  Classes, SysUtils, Annot;

type
  TSearcher = class(TThread)
  private
    FSearchStr : string;
    FOffset : longint;
    FPosition: longint;
    FResultStr : string;
    ResultType: string;
    procedure AddItem;
  protected
    procedure Execute; override;
  public
    constructor Create(SearchStr: string; Offset: cardinal; Pri: integer);
    function FindBlock: longint;
    function FindAnnot(Annot: TAnnot; LineNo: longint): longint;
  end;

  procedure ClearSearchList;

var
  SearchList: TList;

const
  ResultBounds = 30;
  ASCIISet: set of Char = ['A'..'Z','a'..'z','0'..'9',' ','''','-','+','.',',','!','?','&','(',')','/'];

implementation

uses
  Main, StrLib;

constructor TSearcher.Create(SearchStr: string; Offset: cardinal; Pri: integer);
begin
  FSearchStr:=SearchStr;
  FOffset:=Offset;
  FreeOnTerminate := True;
  SearchList:=TList.Create;
  Priority:=TThreadPriority(Pri);
  inherited Create(False);
end;

procedure TSearcher.Execute;
var
  LineNo: longint;
  n: cardinal;
  Annot: TAnnot;
begin
  FPosition:=-1;
  LineNo:=-1;
  ResultType:='Annotation';
  if MainForm.AnnotationCheckListBox.Items.Count>0 then
  begin
    for n:=0 to MainForm.AnnotationCheckListBox.Items.Count-1 do
    begin
      if not MainForm.AnnotationCheckListBox.Checked[n] then
        Continue;
      Annot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[n]);
      repeat
        LineNo:=FindAnnot(Annot,LineNo+1);
        if Terminated then
          Exit;
      until (LineNo=-1);
    end;
  end;
  ResultType:='Block Content';
  repeat
    if Terminated then
      Exit;
  until (FindBlock=-1);
end;

procedure ClearSearchList;
begin
  MainForm.SearchListBox.Clear;
  if SearchList<>nil then
  begin
    SearchList.Free;
    SearchList:=nil;
  end;
end;

procedure TSearcher.AddItem;
begin
  MainForm.SearchListBox.Items.Add(Format('%s'^I'%-18s'^I'%s',[ResultType,ValueString(FPosition),FResultStr]));
  SearchList.Add(ptr(FPosition));
end;

function TSearcher.FindAnnot(Annot: TAnnot; LineNo: longint): longint;
var
  Found: TFindStringResult;
begin
  result:=-1;
  if not MainForm.SearchInAnnotationsCheckBox.Checked then
    Exit;
  repeat
    if MainForm.SearchCaseSensitiveCheckBox.Checked then
      Found:=Annot.FindString(FSearchStr,LineNo+1,true)
    else
      Found:=Annot.FindString(UpperCase(FSearchStr),LineNo+1,false);
    if Found.KeyStr<>'' then
    begin
      FPosition:=HexToIntDef(Found.KeyStr,-1);
      if (FPosition<>-1) then
      begin
        FResultStr:=Found.ValueStr;
        Synchronize(AddItem);
        result:=Found.LineNo;
        Exit;
      end;
    end;
  until Found.KeyStr='';
end;

function TSearcher.FindBlock: longint;
var
  Position: cardinal;
  PosOffs: cardinal;
  SurroundOffs: cardinal;
  ResultStrOffs: cardinal;
begin
  result:=-1;
  if (MainForm.SearchInBlockNamesCheckBox.Checked) or
     (MainForm.SearchInBlockContentsCheckBox.Checked) then
  begin
    for Position:=FOffset to Analyzer.InputFile.Size do
    begin
      if Terminated then Exit;
      if ((Chr(Analyzer.InputFile.ReadByte(Position))=FSearchStr[1])
        or ((not MainForm.SearchCaseSensitiveCheckBox.Checked)
          and (UpCase(Chr(Analyzer.InputFile.ReadByte(Position)))=FSearchStr[1]))) then
      begin
        for PosOffs:=1 to length(FSearchStr)-1 do
        begin
          if (MainForm.SearchCaseSensitiveCheckBox.Checked) then
          begin
            if (Chr(Analyzer.InputFile.ReadByte(Position+PosOffs))<>FSearchStr[PosOffs+1]) then
              Break;
          end
          else
          begin
            if (UpCase(Chr(Analyzer.InputFile.ReadByte(Position+PosOffs)))<>FSearchStr[PosOffs+1]) then
              Break;
          end;
          if PosOffs = length(FSearchStr)-1 then
          begin
            FPosition:=Position;
            SurroundOffs:=0;
            FResultStr:='';
            repeat
              Inc(SurroundOffs);
            until (not (Chr(Analyzer.InputFile.ReadByte(Position-SurroundOffs)) in ASCIISet)) or (SurroundOffs=ResultBounds);
            for ResultStrOffs:=((Position-SurroundOffs)+1) to (Position+length(FSearchStr)-1) do
            begin
              FResultStr:=FResultStr+Chr(Analyzer.InputFile.ReadByte(ResultStrOffs));
            end;
            SurroundOffs:=0;
            repeat
              Inc(SurroundOffs);
            until (not (Chr(Analyzer.InputFile.ReadByte(Position+length(FSearchStr)+SurroundOffs-1)) in ASCIISet)) or (SurroundOffs=ResultBounds);
            if SurroundOffs>1 then
            begin
              for ResultStrOffs:=(Position+length(FSearchStr)) to (Position+length(FSearchStr)+(SurroundOffs-2)) do
              begin
                FResultStr:=FResultStr+Chr(Analyzer.InputFile.ReadByte(ResultStrOffs));
              end;
            end;
            Synchronize(AddItem);
            FOffset:=Position+1;
            result:=Position;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

end.
