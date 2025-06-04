unit Annot;

interface
uses
  IniFiles32, SysUtils, AnnotDlg, Dialogs, Classes;

type
  TFindStringResult = record
    KeyStr: string;
    ValueStr: string;
    LineNo: cardinal;
  end;

  PAnnot = ^TAnnot;
  TAnnot = class(TIniFile32)
  public
    constructor Create(AFileName: string);
    destructor Destroy; override;
    function FindString(SearchStr: string; LineNo: cardinal; CaseSensitive: boolean): TFindStringResult;
    function ReadAnnot(AName: string; AOffset: cardinal): string;
    procedure WriteAnnot(AName: string; AOffset: cardinal; AText: string);
    function GetTitle: string;
    procedure SetTitle(ATitle: string);
    function GetGameFile: string;
    procedure SetGameFile(AFile: string);
    function GetGameFileSize: cardinal;
    procedure SetGameFileSize(ASize: cardinal);
    function GetAuthor: string;
    procedure SetAuthor(AAuthor: string);
  end;

  procedure FindAnnotations(AFileName: string; ASize: cardinal);
  procedure ClearAnnotations;
  procedure UpdateAnnotView;
  procedure NewAnnot;
  procedure EditAnnot;
  procedure DeleteAnnot;
  procedure CurrEditAnnot;

var
  AnnotDir : string;
  AnnotList: TList;
  CurrAnnotEdit: TAnnot;
  AnnotChanged: boolean = false;
implementation

uses
  Main, Graphics, FileStuff, StrLib;

const
  mrYes = 6;

constructor TAnnot.Create(AFileName: string);
begin
  inherited Create(AFileName);
end;

destructor TAnnot.Destroy;
begin
  inherited;
end;

function TAnnot.FindString(SearchStr: string; LineNo: cardinal; CaseSensitive: boolean): TFindStringResult;
var
  I: longint;
begin
  result.KeyStr:= '';
  result.LineNo:=0;
  result.ValueStr:='';
  if FileBuffer.Count > LineNo then
  begin
    for I:=LineNo to FileBuffer.Count-1 do
    begin
      if (not IsSection(FileBuffer[I])) then
      begin
        if (AnsiPos(SearchStr,FileBuffer[I])>AnsiPos('=',FileBuffer[I]))
          or ((not CaseSensitive) and (AnsiPos(SearchStr,Uppercase(FileBuffer[I]))>AnsiPos('=',FileBuffer[I]))) then
        begin
          result.LineNo:=I;
          result.KeyStr:=GetName(FileBuffer[I]);
          result.ValueStr:=GetValue(FileBuffer[I], result.KeyStr);
          if HexToIntDef(result.KeyStr,-1)<>-1 then
             Exit
          else
          begin
            result.KeyStr:='';
          end;
        end;
      end;
    end;
  end;
end;


function TAnnot.ReadAnnot(AName: string; AOffset: cardinal): string;
begin
  result:=ReadString(AName,inttohex(AOffset,10),'');
end;

procedure TAnnot.WriteAnnot(AName: string; AOffset: cardinal; AText: string);
begin
  if AText<>'' then
    WriteString(AName,inttohex(AOffset,10),AText)
  else
    DeleteKey(AName,inttohex(AOffset,10));
end;

function TAnnot.GetTitle: string;
begin
  result:=ReadString('Header','Title','');
end;

procedure TAnnot.SetTitle(ATitle: string);
begin
  WriteString('Header','Title',ATitle);
end;

function TAnnot.GetGameFile: string;
begin
  result:=ReadString('Header','File','');
end;

procedure TAnnot.SetGameFile(AFile: string);
begin
  WriteString('Header','File',AFile);
end;

function TAnnot.GetGameFileSize: cardinal;
begin
  result:=0;
  try
    result:=strtoint(ReadString('Header','Size',''));
  except
    on EConvertError do
    begin
      MessageDlg('Invalid annotation file: '+FileName,mtError,[mbOK],0);
    end;
  end;
end;

procedure TAnnot.SetGameFileSize(ASize: cardinal);
begin
  WriteString('Header','Size',inttostr(ASize))
end;

function TAnnot.GetAuthor: string;
begin
  result:=ReadString('Header','Author','');
end;

procedure TAnnot.SetAuthor(AAuthor: string);
begin
  WriteString('Header','Author',AAuthor);
end;

procedure FindAnnotations(AFileName: string; ASize: cardinal);
var
  Annot: TAnnot;
  SearchRec: TSearchRec;
  Found: longint;
begin
  AFileName:=ExtractFileName(AFileName);
  Found:=FindFirst(AnnotDir+'\*.sra',faAnyFile,SearchRec);
  while Found = 0 do
  begin
    Annot:=TAnnot.Create(AnnotDir+'\'+SearchRec.Name);
    If (UpperCase(Annot.GetGameFile) = UpperCase(AFileName))
       and (Annot.GetGameFileSize = ASize) then
    begin
      MainForm.AnnotationCheckListBox.Items.AddObject(Annot.GetTitle,Annot);
      MainForm.AnnotationCheckListBox.Checked[MainForm.AnnotationCheckListBox.Items.Count-1]:=true;
    end
    else
      Annot.Free;
    Found:=FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  CurrAnnotEdit:=nil;
  MainForm.CurrEditLabel.Caption:='n/a';
  MainForm.AnnotationEdit.ReadOnly:=true;
  MainForm.AnnotationEdit.Color:=clBtnFace;

  MainForm.EditAnnotButton.Enabled:=false;
  MainForm.DeleteAnnotButton.Enabled:=false;
  MainForm.CurrEditAnnotButton.Enabled:=false;
end;

procedure ClearAnnotations;
var
  n: cardinal;
  Annot: TAnnot;
begin
  if MainForm.AnnotationCheckListBox.Items.Count>0 then
  begin
    for n:=0 to MainForm.AnnotationCheckListBox.Items.Count-1 do
    begin
      Annot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[n]);
      Annot.Free;
    end;
    MainForm.AnnotationCheckListBox.Clear;
  end;
end;

procedure NewAnnot;
var
  Annot: TAnnot;
  NewFileName: string;
begin
  AnnotDialog.Caption:='New Annotation File...';
  AnnotDialog.TitleEdit.Text:='';
  AnnotDialog.AuthorEdit.Text:='';
  AnnotDialog.FileNameEdit.Text:='';
  AnnotDialog.FileNameEdit.ReadOnly:=false;
  AnnotDialog.BrowseButton.Enabled:=true;
  AnnotDialog.GameFileLabel.Caption:=ExtractFileName(Analyzer.InputFile.FileName);
  AnnotDialog.GameFileSizeLabel.Caption:=inttostr(Analyzer.InputFile.Size);
  AnnotDialog.SaveDialog.InitialDir:=AnnotDir;
  AnnotDialog.SaveDialog.Title:='Choose Annotation Filename...';
  if AnnotDialog.ShowModal = 42 then
  begin
    NewFileName:=AnnotDir+'\'+ExtractFileName(AnnotDialog.FileName);
    if ExtractFileExt(NewFileName)<>'.sra' then
      NewFileName:=NewFileName+'.sra';
    If FileExists(NewFileName) then
    begin
      DeleteFile(PChar(NewFileName));
    end;
    Annot:=TAnnot.Create(NewFileName);
    Annot.SetTitle(AnnotDialog.Title);
    Annot.SetAuthor(AnnotDialog.Author);
    Annot.SetGameFile(ExtractFileName(Analyzer.InputFile.FileName));
    Annot.SetGameFileSize(Analyzer.InputFile.Size);

    ClearAnnotations;

    FindAnnotations(Analyzer.InputFile.FileName,Analyzer.InputFile.Size);
  end;
end;

procedure EditAnnot;
var
  Annot: TAnnot;
begin
  AnnotDialog.Caption:='Edit Annotation File...';
  Annot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[MainForm.AnnotationCheckListBox.ItemIndex]);
  AnnotDialog.TitleEdit.Text:=Annot.GetTitle;
  AnnotDialog.AuthorEdit.Text:=Annot.GetAuthor;
  AnnotDialog.FileNameEdit.Text:=ExtractFileName(Annot.FileName);
  AnnotDialog.FileNameEdit.ReadOnly:=true;
  AnnotDialog.BrowseButton.Enabled:=false;
  AnnotDialog.GameFileLabel.Caption:=ExtractFileName(Annot.GetGameFile);
  AnnotDialog.GameFileSizeLabel.Caption:=inttostr(Annot.GetGameFileSize);

  if AnnotDialog.ShowModal = 42 then
  begin
    Annot.SetTitle(AnnotDialog.Title);
    Annot.SetAuthor(AnnotDialog.Author);
    Annot.SetGameFile(ExtractFileName(Analyzer.InputFile.FileName));
    Annot.SetGameFileSize(Analyzer.InputFile.Size);

    ClearAnnotations;

    FindAnnotations(Analyzer.InputFile.FileName,Analyzer.InputFile.Size);
  end;
end;

procedure DeleteAnnot;
var
  Annot: TAnnot;
  FileName: string;
begin
  if MainForm.AnnotationCheckListBox.ItemIndex>=0 then
  begin
    if MessageDlg('This will delete the actual Annotation file! Are you sure?',mtWarning,[mbYes,mbNo],0)=mrYes then
    begin
      Annot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[MainForm.AnnotationCheckListBox.ItemIndex]);
      FileName:=ExtractFileName(Annot.FileName);
      DeleteFile(AnnotDir+'\'+FileName);
      ClearAnnotations;
      FindAnnotations(Analyzer.InputFile.FileName,Analyzer.InputFile.Size);
    end;
  end;
end;

procedure CurrEditAnnot;
var
  Annot: TAnnot;
begin
  if MainForm.AnnotationCheckListBox.ItemIndex>=0 then
  begin
    Annot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[MainForm.AnnotationCheckListBox.ItemIndex]);
    MainForm.CurrEditLabel.Caption:=Annot.GetTitle;
    CurrAnnotEdit:=Annot;
    MainForm.AnnotationEdit.ReadOnly:=false;
    MainForm.AnnotationEdit.Color:=clWhite;
  end;
end;

procedure UpdateAnnotView;
var
  Annot: TAnnot;
begin
  Annot:=TAnnot(MainForm.AnnotationCheckListBox.Items.Objects[MainForm.AnnotationCheckListBox.ItemIndex]);
  MainForm.AnnotTitleLabel.Caption:=Annot.GetTitle;
  MainForm.AnnotAuthorLabel.Caption:=Annot.GetAuthor;
  MainForm.AnnotFileNameLabel.Caption:=ExtractFileName(Annot.FileName);
  MainForm.AnnotGameFileLabel.Caption:=Annot.GetGameFile;
  MainForm.AnnotGameFileSizeLabel.Caption:=inttostr(Annot.GetGameFileSize);

  MainForm.EditAnnotButton.Enabled:=true;
  MainForm.DeleteAnnotButton.Enabled:=true;
  MainForm.CurrEditAnnotButton.Enabled:=true;
end;

end.
