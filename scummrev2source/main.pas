unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ExtCtrls, ComCtrls, ChunkSpecs, AdvSplitter, ZTreeView,
  About, Buttons, MRUFList, Analyze, PreAnalyze, Options, checklst, Spec,
  Search,{ HTMLHelpAPI,} ShellAPI, SpecForm, DFSStatusBar, TabListBox;

const
  pmSpec1Item = 0;
  pmSpec2Item = 1;
  pmSpec3Item = 2;

type
  THTMLHelp = function(hwndCaller : HWND; pszFile: PChar; uCommand : Integer; dwData : DWORD) : HWND; stdcall;
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileExitItem: TMenuItem;
    HelpItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    HelpContentsItem: TMenuItem;
    HelpIndexItem: TMenuItem;
    HelpWebPageItem: TMenuItem;
    ToolsItem: TMenuItem;
    ToolsStopSoundItem: TMenuItem;
    ToolsOptionsItem: TMenuItem;
    ToolsSaveFlashItem: TMenuItem;
    FileInfoSplitter: TAdvSplitter;
    FilePanel: TPanel;
    InputFileLabel: TLabel;
    DecValLabel: TLabel;
    FileFormatLabel: TLabel;
    InputFileEdit: TEdit;
    InputBrowseButton: TButton;
    DecValComboBox: TComboBox;
    FileTypeComboBox: TComboBox;
    PageControl: TPageControl;

    InfoItem: TMenuItem;

    ExplorerPage: TTabSheet;
    ExplorerSplitter: TAdvSplitter;
    ExplorerTreeView: TZTreeView;
    ExplorerInfoSplitter: TAdvSplitter;
    ExplorerPopupMenu: TPopupMenu;
    OpenDialog: TOpenDialog;
    MRUFileList: TMRUFileList;
    FileDumpButton: TButton;
    HexEditButton: TButton;
    AnalyzeButton: TButton;
    SaveDialog: TSaveDialog;
    FlashSaveDialog: TSaveDialog;
    InfoSplitter: TAdvSplitter;
    BlockInfoGroupBox: TGroupBox;
    BlockTypeLabel: TLabel;
    BlockOffsetLabel: TLabel;
    BlockSizeLabel: TLabel;
    BlockSizeFormatLabel: TLabel;
    BlockDescLabel: TLabel;
    BlockTypeResultLabel: TLabel;
    BlockOffsetResultEdit: TEdit;
    BlockSizeResultLabel: TLabel;
    BlockSizeFrmtResultLabel: TLabel;
    BlockDescResultLabel: TLabel;
    SpecInfoGroupBox: TGroupBox;
    ScrollBox1: TScrollBox;
    Spec1Button: TButton;
    Spec2Button: TButton;
    Spec3Button: TButton;

    AnnotationsPage: TTabSheet;
    AnnotationSplitter: TAdvSplitter;
    AnnotationCheckListBox: TCheckListBox;
    AnnotInfoSplitter: TAdvSplitter;
    NewAnnotButton: TButton;
    DeleteAnnotButton: TButton;
    CurrEditAnnotButton: TButton;
    EditAnnotButton: TButton;
    AnnotCurrentEditGroupBox: TGroupBox;
    AnnotInfoGroupBox: TGroupBox;
    AnnotTitleTitleLabel: TLabel;
    AnnotFileNameTitleLabel: TLabel;
    AnnotGameFileTitleLabel: TLabel;
    AnnotGameFileSizeTitleLabel: TLabel;
    AnnotAuthorTitleLabel: TLabel;
    AnnotTitleLabel: TLabel;
    AnnotAuthorLabel: TLabel;
    AnnotFileNameLabel: TLabel;
    AnnotGameFileLabel: TLabel;
    AnnotGameFileSizeLabel: TLabel;
    CurrEditLabel: TLabel;
    AnnotationTitleLabel: TLabel;
    AnnotationEdit: TEdit;
    StatusBar: TDFSStatusBar;
    IconImageList: TImageList;
    BlockIconImage: TImage;
    BlockIconPanel: TPanel;
    BigIconImageList: TImageList;

    SearchPage: TTabSheet;
    SearchSplitter: TAdvSplitter;
    SearchGroupBox: TGroupBox;
    SearchTypeLabel: TLabel;
    SearchTypeEdit: TEdit;
    SearchButton: TButton;

    SearchCaseSensitiveCheckBox: TCheckBox;
    SearchInBlockNamesCheckBox: TCheckBox;
    SearchInBlockContentsCheckBox: TCheckBox;
    SearchInAnnotationsCheckBox: TCheckBox;

    SearchListBox: TTabsListBox;

    procedure AnalyzeFile(AFile: string);
    procedure SetCurrFile(AFile: string);
    procedure ChooseInputFile;
    procedure Status(Panel: cardinal; Txt: string);

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;

    procedure FilePanelResize(Sender: TObject);
    procedure BlockInfoResize;
    procedure ExplorerSplitterPaneResize(Sender: TObject);
    procedure ExplorerSplitterResize(Sender: TObject);

    procedure HideSpecInfo;

    procedure InputBrowseButtonClick(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure HelpAboutItemClick(Sender: TObject);
    procedure HelpContentsItemClick(Sender: TObject);
    procedure HelpIndexItemClick(Sender: TObject);
    procedure HelpWebPageItemClick(Sender: TObject);
    procedure FileOpenItemClick(Sender: TObject);
    procedure MRUFileListMRUItemClick(Sender: TObject; AFilename: String);
    procedure AnalyzeButtonClick(Sender: TObject);

    procedure ExplorerTreeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure ExplorerTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure ExplorerTreeViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure ExplorerTreeViewCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure ExplorerTreeViewChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ExplorerTreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);

    procedure ExpandToPosition(Position: integer);

    procedure ToolsOptionsItemClick(Sender: TObject);
    procedure ToolsSaveFlashItemClick(Sender: TObject);
    procedure ToolsStopSoundItemClick(Sender: TObject);
    procedure FileDumpButtonClick(Sender: TObject);
    procedure HexEditButtonClick(Sender: TObject);
    procedure AnnotInfoSplitterPaneResize(Sender: TObject);
    procedure AnnotInfoSplitterResize(Sender: TObject);
    procedure AnnotationCheckListBoxClick(Sender: TObject);
    procedure AnnotationCheckListBoxKeyPress(Sender: TObject;
      var Key: Char);
    procedure NewAnnotButtonClick(Sender: TObject);
    procedure EditAnnotButtonClick(Sender: TObject);
    procedure DeleteAnnotButtonClick(Sender: TObject);
    procedure CurrEditAnnotButtonClick(Sender: TObject);
    procedure AnnotationEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AnnotationEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure PopupFileDumpItemClick(Sender: TObject);
    procedure PopupHexViewItemClick(Sender: TObject);
    procedure PopupInfoItemClick(Sender: TObject);

    procedure SearchListBoxDblClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure SearchSplitterPaneResize(Sender: TObject);
    procedure StopSearch(Sender: TObject);
  private
    { Private declarations }
    procedure SearchDone(Sender: TObject);
    procedure CreateSpecArrays;
    procedure WMGetMinMaxInfo(var MSG: Tmessage); message WM_GetMinMaxInfo;
    function HtmlHelpShowHelp : HWND;
    function HtmlHelpShowTopic(const aTopic : String) : HWND;
    function HtmlHelpShowContents : HWND;
    function HtmlHelpShowIndex : HWND;
public
    SpecTitleLabel: array[1..8] of TLabel;
    SpecLabel: array[1..8] of TLabel;
    Preferences: TPreferences;
    Searching: boolean;
    function CreateDir(Dir: string): string;
    { Public declarations }
  end;

  function ValueString(Val: cardinal): string;

var
  MainForm: TMainForm;
  Analyzer: TAnalyzer;
  Searcher: TSearcher;
  Info: TInfo;
  TempDir: string;
  FlashDir: string;
  HTMLHelpHandle: THandle;
  HTMLHelp: THTMLHelp;

implementation

uses
  Annot, HexView, Flash;

{$R *.DFM}

const
   HH_DISPLAY_TOPIC         = $0000;
   HH_DISPLAY_TOC           = $0001;
   HH_DISPLAY_INDEX         = $0002;

function TMainForm.HtmlHelpShowHelp : HWND;
begin
   Result:=HtmlHelp(0, PChar(Application.HelpFile), HH_DISPLAY_TOPIC, 0);
end;

function TMainForm.HtmlHelpShowTopic(const aTopic : String) : HWND;
begin
   Result:=HtmlHelp(0, PChar(Application.HelpFile+'::'+aTopic), HH_DISPLAY_TOPIC, 0);
end;

function TMainForm.HtmlHelpShowContents : HWND;
begin
   Result:=HtmlHelp(0, PChar(Application.HelpFile), HH_DISPLAY_TOC, 0);
end;

function TMainForm.HtmlHelpShowIndex : HWND;
begin
   Result:=HtmlHelp(0, PChar(Application.HelpFile), HH_DISPLAY_INDEX, 0);
end;

function ValueString(Val: Cardinal): string;
begin
  result:=IntToStr(Val)+' (0x'+IntToHex(Val,8)+')';
end;

function TMainForm.CreateDir(Dir: string): string;
begin
  result:=ExtractFileDir(Application.ExeName);
  if result[length(result)]='\' then
    result:=result+Dir
  else
    result:=result+'\'+Dir;

  if (FileGetAttr(result)=-1) or ((FileGetAttr(result) and faDirectory)=0) then
  begin
     {$I-}
     MkDir(result);
     {$I+}
     If IOResult <> 0 then
     begin
        MessageDlg('Unable to create '+Dir+' directory ('+result+')',mtError,[mbOK],0);
     end;
  end;
end;

procedure TMainForm.AnalyzeFile(AFile: string);
var
  PreAnalyzer: TPreAnalyzer;
begin
    Analyzer.Free;
    Analyzer:=nil;
    Screen.Cursor:=crHourGlass;
    Update;

    if (DecValComboBox.ItemIndex=DecValComboBox.Items.Count-1) or (FileTypeComboBox.ItemIndex=FileTypeComboBox.Items.Count-1) then
    begin
      Status(0,'Determining Fileformat...');
      try
        PreAnalyzer:=TPreAnalyzer.Create(AFile);
      except
        on EFOpenError do
        begin
          MessageDlg('File '+AFile+' not found or inaccessible!',mtError,[mbOK],0);
          Screen.Cursor:=crDefault;
          Status(0,' ');
          AnnotationEdit.Enabled:=false;
          FileDumpButton.Enabled:=false;
          HexEditButton.Enabled:=false;
          NewAnnotButton.Enabled:=false;
          SearchButton.Enabled:=false;
          ToolsSaveFlashItem.Enabled:=false;
          ExplorerTreeView.PopupMenu:=nil;
          Exit;
        end;
      end;
      if PreAnalyzer.FindFileFormat then
      begin
        Status(0,'Fileformat found!');
        DecValComboBox.ItemIndex:=PreAnalyzer.XORVal;
        FileTypeComboBox.ItemIndex:=ord(PreAnalyzer.FileType);
      end
      else
      begin
        Status(0,'Unable to determine fileformat!');
      end;
      PreAnalyzer.Free;
    end;
    if (DecValComboBox.ItemIndex<>Ord(ftUnknown)) and
       (FileTypeComboBox.ItemIndex<>256) then
    begin
      Status(0,'Analyzing...');
      try
        Analyzer:=TAnalyzer.Create(AFile);
      finally
        Screen.Cursor:=crDefault;
        Status(0,' ');
      end;
    end;

    if ExplorerTreeView.Items.Count>0 then
    begin
      ExplorerTreeView.Enabled:=true;
      ExplorerTreeView.Selected:=ExplorerTreeView.Items[0];
      FileDumpButton.Enabled:=True;
      HexEditButton.Enabled:=True;
      AnnotationEdit.Enabled:=True;
      NewAnnotButton.Enabled:=True;
      SearchButton.Enabled:=True;
      ToolsSaveFlashItem.Enabled:=True;
      ExplorerTreeView.PopupMenu:=ExplorerPopupMenu;
    end
    else
    begin
      AnnotationEdit.Enabled:=false;
      FileDumpButton.Enabled:=false;
      HexEditButton.Enabled:=false;
      NewAnnotButton.Enabled:=false;
      SearchButton.Enabled:=false;
      ToolsSaveFlashItem.Enabled:=false;
      ExplorerTreeView.PopupMenu:=nil;
    end;

    Screen.Cursor:=crDefault;
end;

procedure TMainForm.SetCurrFile(AFile: string);
begin
  if Searching then
  begin
    if MessageDlg('Search in progress! Terminate search and load file?',mtWarning,[mbYes, mbNo],0) = mrNo then
      Exit
    else
      Searcher.Terminate;
  end;
  InputFileEdit.Text:=AFile;
  if AFile<>'' then
  begin
    FileTypeComboBox.ItemIndex:=FileTypeComboBox.Items.Count-1;
    DecValComboBox.ItemIndex:=DecValComboBox.Items.Count-1;
    AnalyzeFile(AFile);
  end;
end;

procedure TMainForm.ChooseInputFile;
begin
  if OpenDialog.Execute then
  begin
    SetCurrFile(OpenDialog.FileName);
    MRUFileList.AddItem(OpenDialog.FileName);
  end;
end;

// ********************* RESIZING **********************

procedure TMainForm.WMGetMinMaxInfo(var Msg: TMessage);
Begin
  inherited;
  with PMinMaxInfo(Msg.lParam)^ do
  begin
    ptMinTrackSize.X := 576;
    ptMinTrackSize.Y := 411;
  end;
end;

procedure TMainForm.FilePanelResize(Sender: TObject);
begin
  InputFileEdit.Width:=FilePanel.ClientWidth-(InputFileEdit.Left+8+InputBrowseButton.Width+8);
  InputBrowseButton.Left:=FilePanel.ClientWidth-(InputBrowseButton.Width+8);
//  BigEndianCheckBox.Left:=InputFileEdit.Width+InputFileEdit.Left-BigEndianCheckBox.Width;
//  FileTypeComboBox.Width:=BigEndianCheckBox.Left-(FileTypeComboBox.Left+8);
  FileTypeComboBox.Width:=InputFileEdit.Width+InputFileEdit.Left-FileTypeComboBox.Left;
  AnalyzeButton.Left:=InputBrowseButton.Left;
end;

// Explorer
procedure TMainForm.BlockInfoResize;
begin
  BlockIconPanel.Left:=BlockInfoGroupBox.ClientWidth-(BlockIconPanel.Width+8);
  BlockTypeResultLabel.Width:=BlockInfoGroupBox.ClientWidth-(BlockTypeResultLabel.Left+2+40);
  BlockOffsetResultEdit.Width:=BlockInfoGroupBox.ClientWidth-(BlockOffsetResultEdit.Left+2+44);
  BlockSizeResultLabel.Width:=BlockInfoGroupBox.ClientWidth-(BlockSizeResultLabel.Left+2);
  BlockSizeFrmtResultLabel.Width:=BlockInfoGroupBox.ClientWidth-(BlockSizeFrmtResultLabel.Left+2);
  BlockDescResultLabel.Width:=BlockInfoGroupBox.ClientWidth-(BlockDescResultLabel.Left+2);
  AnnotationEdit.Width:=BlockInfoGroupBox.ClientWidth-(AnnotationEdit.Left+8);
end;

procedure TMainForm.ExplorerSplitterPaneResize(Sender: TObject);
begin
  BlockInfoResize;
end;

procedure TMainForm.ExplorerSplitterResize(Sender: TObject);
begin
  BlockInfoResize;
end;

// Annotation
procedure TMainForm.AnnotInfoSplitterPaneResize(Sender: TObject);
begin
  AnnotTitleLabel.Width:=AnnotInfoGroupBox.ClientWidth-(AnnotTitleLabel.Left+8);
  AnnotAuthorLabel.Width:=AnnotInfoGroupBox.ClientWidth-(AnnotAuthorLabel.Left+8);
  AnnotFileNameLabel.Width:=AnnotInfoGroupBox.ClientWidth-(AnnotFileNameLabel.Left+8);
  AnnotGameFileLabel.Width:=AnnotInfoGroupBox.ClientWidth-(AnnotGameFileLabel.Left+8);
  AnnotGameFileSizeLabel.Width:=AnnotInfoGroupBox.ClientWidth-(AnnotGameFileSizeLabel.Left+8);
  CurrEditLabel.Width:=AnnotCurrentEditGroupBox.ClientWidth-(CurrEditLabel.Left+8);
end;

procedure TMainForm.AnnotInfoSplitterResize(Sender: TObject);
begin
  CurrEditAnnotButton.Top:=AnnotInfoSplitter.Height-CurrEditAnnotButton.Height;
end;

// Search
procedure TMainForm.SearchSplitterPaneResize(Sender: TObject);
begin
  SearchButton.Left:=SearchGroupBox.ClientWidth-(SearchButton.Width+8);
  SearchTypeEdit.Width:=SearchButton.Left-(SearchTypeEdit.Left+8);
end;

// ********************* FORM CREATE ******************

procedure TMainForm.CreateSpecArrays;
var
  n: cardinal;
begin
  for n:=1 to 8 do
  begin
    SpecTitleLabel[n]:=TLabel.Create(Self);
    SpecTitleLabel[n].Parent:=ScrollBox1;
    SpecTitleLabel[n].Left:=8;
    SpecTitleLabel[n].Top:=(n-1)*16;
    SpecTitleLabel[n].Width:=17;
    SpecTitleLabel[n].Height:=13;
    SpecTitleLabel[n].Caption:='n/a';
    SpecLabel[n]:=TLabel.Create(Self);
    SpecLabel[n].Parent:=ScrollBox1;
    SpecLabel[n].Left:=120;
    SpecLabel[n].Top:=(n-1)*16;
    SpecLabel[n].Width:=17;
    SpecLabel[n].Height:=13;
    SpecLabel[n].Caption:='n/a';
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
const
  TVS_NOTOOLTIPS = $80;
var
  n : byte;
  FileType: TFileType;
begin
  //Load preferences
  Preferences:=TPreferences.Create;
  Preferences.Load;
  StatusBar.Panels[0].GaugeAttrs.Color:=ColorToRGB(clBtnFace) div 2;
  StatusBar.Panels[1].GaugeAttrs.Color:=ColorToRGB(clBtnFace) div 2;
  //Create SpecInfo arrays of labels
  CreateSpecArrays;

  //Init SpecInfo procs
  Info:=TInfo.Create;
  HideSpecInfo;
  // Create Decrypt Value Combobox
  for n:=0 to 255 do
  begin
    DecValComboBox.Items.Add('0x'+IntToHex(n,2)+' ('+IntToStr(n)+')');
  end;
  DecValComboBox.Items.Add('[Unknown]');
  DecValComboBox.ItemIndex:=DecValComboBox.Items.Count-1;
  // Create file type combobox
  for FileType:=ftStdSCUMM to ftUnknown do
  begin
    FileTypeComboBox.Items.Add(FileTypeName[FileType]);
  end;
  FileTypeComboBox.ItemIndex:=FileTypeComboBox.Items.Count-1;

  // Set filters
  OpenDialog.Filter:='Main Resource Files|*.001;*.la1;*.la2;*.lab;*.lfl;*.lec;*.sm1|';
  OpenDialog.Filter:=OpenDialog.Filter+'Directory Files|*.000;*.la0;*.lfl;*.sm0|';
  OpenDialog.Filter:=OpenDialog.Filter+'Bundle Files|*.lab;*.bun;*.mus|';
  OpenDialog.Filter:=OpenDialog.Filter+'Monster Sound Files|*.sou|';
  OpenDialog.Filter:=OpenDialog.Filter+'SMUSH Files|*.san;*.nut|';
  OpenDialog.Filter:=OpenDialog.Filter+'Savegames|*.0*;*.s0*;*.s1*;*.s2*;*.s3*;*.9*|';
  OpenDialog.Filter:=OpenDialog.Filter+'FLUP Files|*.flu|';
  OpenDialog.Filter:=OpenDialog.Filter+'SCUMM Revisited File Dumps|*.srb;*.imu;*.imc;*.imx;*.wav;*.lip;*.3do;*.cos;*.mat;*.key;*.bm;*.zbm;*.cmp;*.set;*.snm;*.lua|';
  OpenDialog.Filter:=OpenDialog.Filter+'All Supported Files|*.0*;*.la0;*.la1;*.la2;*.lab;*.lfl;*.lec;;*.sm0;*.sm1;*.9*;*.bun;*.sou;*.san;*.nut;*.s0*;*.s1*;*.s2*;*.s3*;*.flu;*.mus;*.srb;*.imu;*.imc;*.imx;*.wav;*.lip;*.3do;*.cos;*.mat;*.key;*.bm;*.zbm;*.cmp;*.set;*.snm;*.lua;*.tab|';
  OpenDialog.Filter:=OpenDialog.Filter+'All Files|*.*';
  OpenDialog.FilterIndex:=9;

  //Turn off TreeView Tooltips
  with ExplorerTreeView do
  begin
    SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) or TVS_NOTOOLTIPS);
  end;

  //Set active page to main page
  PageControl.ActivePage:=ExplorerPage;

  //Check for / Create Annotations Directory
  AnnotDir:=CreateDir('Annot');
  TempDir:=CreateDir('Temp');
  FlashDir:=CreateDir('Flash');
  HTMLHelpHandle:=LoadLibrary('hhctrl.ocx');
  if HTMLHelpHandle = 0 then
  begin
    HelpContentsItem.Enabled:=false;
    HelpIndexItem.Enabled:=false;
    InfoItem.Enabled:=false;
  end
  else
  begin
    @HTMLHelp:=GetProcAddress(HTMLHelpHandle,'HtmlHelpA');
    if @HTMLHelp = nil then
    begin
      HelpContentsItem.Enabled:=false;
      HelpIndexItem.Enabled:=false;
      InfoItem.Enabled:=false;
      FreeLibrary(HTMLHelpHandle);
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  n: cardinal;
begin
  Status(0,'Cleaning up...');
  Analyzer.Free;
  if Preferences.SaveLayout then
    Preferences.LayOutSave;
  Preferences.Free;
  Info.Free;
  SpecInfoForm.SpecInfoMediaPlayer.Close;
  DeleteFile(TempDir+'\temp.wav');
  DeleteFile(TempDir+'\temp.mid');
  DeleteFile(TempDir+'\temp.txt');
  DeleteFile(TempDir+'\temp.srb');
  DeleteFile(TempDir+'\temp.bmp');
  Status(0,' ');

  for n:=1 to 8 do
  begin
    SpecLabel[n].Free;
    SpecTitleLabel[n].Free;
  end;
  AboutBox.Image1.Threaded:=false;

  if @HTMLHelp<>nil then
    FreeLibrary(HTMLHelpHandle);
end;

// ********************* STATUS BAR ************************
procedure TMainForm.Status(Panel: cardinal; Txt: string);
begin
  StatusBar.Panels[Panel].Text:=Txt;
end;

// ********************* FILE INFO PANE ********************

procedure TMainForm.InputBrowseButtonClick(Sender: TObject);
begin
  ChooseInputFile;
end;

procedure TMainForm.AnalyzeButtonClick(Sender: TObject);
begin
  if InputFileEdit.Text<>'' then
  begin
    MRUFileList.AddItem(InputFileEdit.Text);
    AnalyzeFile(InputFileEdit.Text);
  end;
end;

// *************** FILE MENU *******************

procedure TMainForm.FileOpenItemClick(Sender: TObject);
begin
  ChooseInputFile;
end;

procedure TMainForm.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

// ****************** TOOLS MENU ******************

procedure TMainForm.ToolsOptionsItemClick(Sender: TObject);
begin
  OptionsForm.ShowModal;
end;

procedure TMainForm.ToolsSaveFlashItemClick(Sender: TObject);
begin
  SaveFlash;
end;

procedure TMainForm.ToolsStopSoundItemClick(Sender: TObject);
begin
  SpecInfoForm.SpecInfoMediaPlayer.Close;
end;

// **************** HELP MENU *******************

procedure TMainForm.HelpAboutItemClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.HelpIndexItemClick(Sender: TObject);
begin
  HTMLHelpShowIndex;
end;

procedure TMainForm.HelpContentsItemClick(Sender: TObject);
begin
  HTMLHelpShowContents;
end;

procedure TMainForm.HelpWebPageItemClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://www.mixnmojo.com/scumm/scummrev',nil,nil,SW_SHOWNORMAL);
end;

function TMainForm.FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
   Result:=(HtmlHelpShowHelp<>0);
end;

// ******************* Most Recently Used Files *********************

procedure TMainForm.MRUFileListMRUItemClick(Sender: TObject;
  AFilename: String);
begin
  SetCurrFile(AFileName);
end;

// ******************** Explorer Treeview *******************

procedure TMainForm.ExplorerTreeViewExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  Chunk:TChunk;
begin
  if Node.Expanded then
    Exit;
  Status(0,'Analyzing...');
  Screen.Cursor:=crHourGlass;
  try
    Chunk:=Node.Data;
    Analyzer.MaxRead:=Chunk.Offset+Chunk.Size;
    if Analyzer.ChunkHasChildren(Node.Data) then
      Analyzer.ReadChildChunks(Node.Data)
    else
      Node.HasChildren:=false;

  finally
    Screen.Cursor:=crDefault;
    Status(0,' ');
  end;
end;

procedure TMainForm.ExplorerTreeViewChange(Sender: TObject;
  Node: TTreeNode);
begin
  if (Node.Data <> nil) then
    Analyzer.UpdateInfo(Node.Data);
end;

procedure TMainForm.ExplorerTreeViewChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
var
  Chunk: TChunk;
begin
  if (Preferences.UseAnnotations) and (AnnotationEdit.Modified) then
  begin
    AnnotationEdit.Modified:=false;
    if (CurrAnnotEdit<>nil) then
    begin
      Chunk:=ExplorerTreeView.Selected.Data;
      CurrAnnotEdit.WriteAnnot(ChunkSpec[Chunk.Typ].Name,Chunk.Offset,Chunk.Annot);
    end
    else
      MessageDlg('You have not selected an annotation file to edit! Changes will not be saved.',mtError,[mbOK],0);
  end;
end;

procedure TMainForm.ExplorerTreeViewDeletion(Sender: TObject;
  Node: TTreeNode);
var
  Chunk: TChunk;
begin
  if Node.Text<>'x' then
  begin
    Chunk:=Node.Data;
    Chunk.Free;
  end;
end;

procedure TMainForm.ExplorerTreeViewCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
var
  Chunk: TChunk;
begin
  Node.DeleteChildren;
  Chunk:=Node.Data;
  Analyzer.MaxRead:=Chunk.Offset+Chunk.Size;
  if Analyzer.ChunkHasChildren(Chunk) then
    Node.HasChildren:=true;
  //ExplorerTreeView.Selected:=Node;
  Node.Selected:=true;
  if (Node.Data <> nil) then
    Analyzer.UpdateInfo(Node.Data);
end;

procedure TMainForm.ExplorerTreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var
  Node: TTreeNode;
  Pnt: TPoint;
begin
  if (Button<>mbRight) or not (htOnItem in ExplorerTreeView.GetHitTestInfoAt(X,Y)) then Exit;
  Node:=ExplorerTreeView.GetNodeAt(X,Y);
  if Node<>nil then
  begin
    ExplorerTreeView.Selected:=Node;
    Pnt:=ExplorerTreeView.ClientToScreen(Point(X,Y));
    ExplorerPopupMenu.Popup(Pnt.X,Pnt.Y);
  end;
end;

procedure TMainForm.ExpandToPosition(Position: integer);
var
  Chunk: TChunk;
  Node: TTreeNode;
  Found: boolean;
begin
  Found:=false;
  ExplorerTreeView.Items.BeginUpdate;
  try
    Chunk:=ExplorerTreeView.Items[0].Data;
    repeat
    while Chunk.Offset+Chunk.Size-1 < Position do
    begin
      Node:=Chunk.Node.GetNextSibling;
      Chunk:=Node.Data;
    end;
    if not Chunk.Node.HasChildren then
    begin
      Found:=true
    end
    else
    begin
      if not Chunk.Node.Expanded then
        Chunk.Node.Expand(false);
      Chunk:=Chunk.Node.GetFirstChild.Data;
      if Chunk.Offset>Position then
      begin
        Chunk:=Chunk.Node.Parent.Data;
        Chunk.Node.Collapse(false);
        Found:=true;
      end;
    end;
    until Found;
    Chunk.Node.Selected:=true;
    ExplorerTreeView.TopItem:=ExplorerTreeView.Selected;
  finally
    ExplorerTreeView.Items.EndUpdate;
  end;
end;

// ***************** Explorer Buttons *******************

procedure TMainForm.FileDumpButtonClick(Sender: TObject);
var
  Chunk: TChunk;
begin
  Chunk:=ExplorerTreeView.Selected.Data;
  Analyzer.FileDump(Chunk);
end;

procedure TMainForm.HexEditButtonClick(Sender: TObject);
begin
  HexForm.HexEdit(Self);
end;

procedure TMainForm.HideSpecInfo;
var
  n: cardinal;
begin
  for n:=1 to 8 do
  begin
    SpecLabel[n].Hide;
    SpecTitleLabel[n].Hide;
  end;

  ExplorerPopupMenu.Items[pmSpec1Item].Visible:=false;
  ExplorerPopupMenu.Items[pmSpec2Item].Visible:=false;
  ExplorerPopupMenu.Items[pmSpec3Item].Visible:=false;
  Spec1Button.Hide;
  Spec2Button.Hide;
  Spec3Button.Hide;
end;

// **************** Annotation Edit *****************

procedure TMainForm.AnnotationEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Chunk: TChunk;
begin
  if (Preferences.UseAnnotations) and (AnnotationEdit.Modified) then
    begin
      Chunk:=MainForm.ExplorerTreeView.Selected.Data;
      Chunk.Annot:=MainForm.AnnotationEdit.Text;
      if Chunk.Annot<>'' then
      begin
        if Chunk.FName='' then
          MainForm.ExplorerTreeView.Selected.Text:=ChunkSpec[Chunk.Typ].Name+' - '+Chunk.Annot
        else
          MainForm.ExplorerTreeView.Selected.Text:=Chunk.FName+' - '+Chunk.Annot
      end
      else
      begin
        if Chunk.FName='' then
          MainForm.ExplorerTreeView.Selected.Text:=ChunkSpec[Chunk.Typ].Name
        else
          MainForm.ExplorerTreeView.Selected.Text:=Chunk.FName;
      end;
    end;
end;

procedure TMainForm.AnnotationEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DOWN:  begin
                ExplorerTreeView.Perform(WM_KEYDOWN,Key,0);
                Key:=0;
              end;
    VK_UP  :  begin
                ExplorerTreeView.Perform(WM_KEYDOWN,Key,0);
                Key:=0;
              end;
    VK_RIGHT: begin
                if ssAlt in Shift then
                begin
                  ExplorerTreeView.Perform(WM_KEYDOWN,Key,0);
                  Key:=0;
                end;
              end;
    VK_LEFT : begin
                if ssAlt in Shift then
                begin
                  ExplorerTreeView.Perform(WM_KEYDOWN,Key,0);
                  Key:=0;
                end;
              end;
    VK_PRIOR,
    VK_NEXT : begin
                ExplorerTreeView.Perform(WM_KEYDOWN,Key,0);
                Key:=0;
              end
    end;
end;


// **************** ANNOTATION ******************

procedure TMainForm.AnnotationCheckListBoxClick(Sender: TObject);
begin
  UpdateAnnotView;
end;

procedure TMainForm.AnnotationCheckListBoxKeyPress(Sender: TObject;
  var Key: Char);
begin
  UpdateAnnotView;
end;

procedure TMainForm.NewAnnotButtonClick(Sender: TObject);
begin
  NewAnnot;
end;

procedure TMainForm.EditAnnotButtonClick(Sender: TObject);
begin
  EditAnnot;
end;

procedure TMainForm.DeleteAnnotButtonClick(Sender: TObject);
begin
  DeleteAnnot;
end;

procedure TMainForm.CurrEditAnnotButtonClick(Sender: TObject);
begin
  CurrEditAnnot;
end;

// **************** EXPLORER POPUP ******************

procedure TMainForm.PopupFileDumpItemClick(Sender: TObject);
var
  Chunk: TChunk;
begin
  Chunk:=ExplorerTreeView.Selected.Data;
  Analyzer.FileDump(Chunk);
end;

procedure TMainForm.PopupHexViewItemClick(Sender: TObject);
begin
  HexForm.HexEdit(Self);
end;

procedure TMainForm.PopupInfoItemClick(Sender: TObject);
var
  Chunk: TChunk;
  HelpItemName: string;
begin
  Chunk:=ExplorerTreeView.Selected.Data;
  if Chunk.Typ in HelpItems then
  begin
    HelpItemName:=ChunkSpec[Chunk.Typ].Name;
    if HelpItemName[1]='.' then
    begin
      delete(HelpItemName,1,1);
      HelpItemName:='f_'+HelpItemName;
    end;
    if HelpItemName[length(HelpItemName)]=' ' then
      delete(HelpItemName,length(HelpItemName),1);
    HTMLHelpShowTopic('/spec'+HelpItemName+'.html');
  end
  else
    MessageDlg('A help item for this block type does not yet exist.',mtError,[mbOK],0);
end;

// **************** SEARCH ******************

procedure TMainForm.SearchListBoxDblClick(Sender: TObject);
var
  Position : longint;
begin
  if SearchListBox.ItemIndex>=0 then
  begin
    Position:=integer(SearchList.Items[SearchListBox.ItemIndex]);
    PageControl.ActivePage:=ExplorerPage;
    ExpandToPosition(Position);
  end;
end;

procedure TMainForm.SearchButtonClick(Sender: TObject);
begin
  if (SearchTypeEdit.Text<>'') then
  begin
    ClearSearchList;
    Status(1,'Searching...');
    SearchButton.Caption:='Stop';
    if SearchCaseSensitiveCheckBox.Checked then
      Searcher:=TSearcher.Create(SearchTypeEdit.Text,0,Preferences.SearchPriority)
    else
      Searcher:=TSearcher.Create(UpperCase(SearchTypeEdit.Text),0,Preferences.SearchPriority);
    SearchButton.OnClick:=StopSearch;
    Searcher.OnTerminate:=SearchDone;
    Searching:=true;
  end;
end;

procedure TMainForm.StopSearch(Sender: TObject);
begin
  Searcher.Terminate;
end;

procedure TMainForm.SearchDone(Sender: TObject);
begin
  SearchButton.Caption:='Search';
  if SearchListBox.Items.Count<1 then
  begin
    Status(1,'Nothing found');
  end
  else
    if SearchListBox.Items.Count=1 then
      Status(1,'1 occurence found')
    else
      Status(1,inttostr(SearchListBox.Items.Count)+' occurences found');
  SearchButton.OnClick:=SearchButtonClick;
  Searching:=false;
end;

end.

