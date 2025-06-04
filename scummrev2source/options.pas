unit Options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Registry, VolBar, Shortcut;

const
  PriorityTitles : array[0..6] of string =
    ('Idle','Lowest','Low','Normal','High','Highest','Time Critical');

type
  TPreferences = class
  protected
    SetRegistry: TRegistry;
    function ReadRegBool(AKey: string; ADefault: boolean): boolean;
    function ReadRegInteger(AKey: string; ADefault: integer): integer;
    function ReadRegString(AKey: string; ADefault: string): string;
    procedure ExecSettings;
  public
    TestBigChildren : boolean;
    UseAnnotations : boolean;
    UseFlashFiles  : boolean;
    SearchPriority: integer;
    UseIcons: boolean;
    SaveLayout: boolean;
    ASMDecomp: boolean;
    UseExDecomp: boolean;
    ShowProgress: boolean;
    procedure Load;
    procedure Save;
    procedure LayOutLoad;
    procedure LayoutSave;
    constructor Create;
    destructor Destroy; override;
  end;

  TOptionsForm = class(TForm)
    OptionPages: TPageControl;
    PerformancePage: TTabSheet;
    AppearancePage: TTabSheet;
    InstallationPage: TTabSheet;
    TestBigChildrenCheckBox: TCheckBox;
    OKButton: TButton;
    CancelButton: TButton;
    ApplyButton: TButton;
    UseAnnotationsCheckBox: TCheckBox;
    UseFlashFilesCheckBox: TCheckBox;
    SearchPriorityLabel: TLabel;
    SearchPriorityTrackBar: TVolTrackBar;
    SearchPriorityResultLabel: TLabel;
    SaveLayoutCheckBox: TCheckBox;
    UseIconsCheckBox: TCheckBox;
    UseExDecompCheckBox: TCheckBox;
    ShowProgressCheckBox: TCheckBox;
    DesktopIconButton: TButton;
    StartIconButton: TButton;
    UninstallButton: TButton;
    procedure OKButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchPriorityTrackBarChange(Sender: TObject);

    procedure DesktopIconButtonClick(Sender: TObject);
    procedure StartIconButtonClick(Sender: TObject);
    procedure UninstallButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure ApplySettings;
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.DFM}

uses
  Main, WinInfo;

constructor TPreferences.Create;
begin
  inherited;
  SetRegistry:=TRegistry.Create;
  SetRegistry.OpenKey('\Software\WaitingWorlds\SCUMMRev\Settings',true);
end;

destructor TPreferences.Destroy;
begin
  SetRegistry.Free;
  inherited;
end;

function TPreferences.ReadRegBool(AKey: string; ADefault: boolean): boolean;
begin
     try
        result:=SetRegistry.ReadBool(AKey);
     except
           on ERegistryException do
           begin
                SetRegistry.WriteBool(AKey,ADefault);
                result:=SetRegistry.ReadBool(AKey);
           end;
     end;
end;

function TPreferences.ReadRegInteger(AKey: String; ADefault: integer): integer;
begin
     try
        result:=SetRegistry.ReadInteger(AKey);
     except
           on ERegistryException do
           begin
                SetRegistry.WriteInteger(AKey,ADefault);
                result:=SetRegistry.ReadInteger(AKey);
           end;
     end;
end;

function TPreferences.ReadRegString(AKey: String; ADefault: String): string;
begin
     try
        result:=SetRegistry.ReadString(AKey);
        if result='' then // Work around lack of exception raise...
           begin
                SetRegistry.WriteString(AKey,ADefault);
                result:=SetRegistry.ReadString(AKey);
           end;
     except
           on ERegistryException do
           begin
                SetRegistry.WriteString(AKey,ADefault);
                result:=SetRegistry.ReadString(AKey);
           end;
     end;
end;

procedure TPreferences.Load;
begin
  TestBigChildren:=ReadRegBool('TestBigChildren',false);
  UseAnnotations:=ReadRegBool('UseAnnotations',true);
  UseFlashFiles:=ReadRegBool('UseFlashFiles',true);
  ShowProgress:=ReadRegBool('ShowProgress',true);
  SearchPriority:=ReadRegInteger('SearchPriority',3);

  SaveLayOut:=ReadRegBool('SaveLayout', false);
  UseIcons:=ReadRegBool('UseIcons',true);

  UseExDecomp:=ReadRegBool('UseExDecomp', false);
  LayOutLoad;
  ExecSettings;
end;

procedure TPreferences.LayoutLoad;
var
  Placement : TWindowPlacement;
  Top, Left, Height, Width: integer;
begin
  SetRegistry.OpenKey('\Software\WaitingWorlds\SCUMMRev\Layout',true);

  // Read MainForm Layout
  Placement.Length:=SizeOf(TWindowPlacement);

  if not ReadRegBool('MainMax',false) then
  begin
    MainForm.WindowState:=wsNormal;
    Top:=ReadRegInteger('MainTop',36);
    Left:=ReadRegInteger('MainLeft',50);
    Height:=ReadRegInteger('MainBottom',447)-Top;
    Width:=ReadRegInteger('MainRight',612)-Left;
    MainForm.SetBounds(Left,Top,Width,Height);
  end
  else
  begin
    Placement.rcNormalPosition.Top:=ReadRegInteger('MainTop',36);
    Placement.rcNormalPosition.Left:=ReadRegInteger('MainLeft',50);
    Placement.rcNormalPosition.Bottom:=ReadRegInteger('MainBottom',447);
    Placement.rcNormalPosition.Right:=ReadRegInteger('MainRight',612);
    Placement.ptMaxPosition.X:=0;
    Placement.ptMaxPosition.Y:=0;
    SetWindowPlacement(MainForm.Handle,@Placement);
    MainForm.WindowState:=wsMaximized;
  end;

  MainForm.ExplorerSplitter.Position:=ReadRegInteger('ExplorerSplitPos',260);
  MainForm.AnnotationSplitter.Position:=ReadRegInteger('AnnotSplitPos',260);
  MainForm.SearchSplitter.Position:=ReadRegInteger('SearchSplitPos',180);

  MainForm.Update;

  SetRegistry.OpenKey('\Software\WaitingWorlds\SCUMMRev\Settings',true);
end;

procedure TPreferences.Save;
begin
  SetRegistry.WriteBool('TestBigChildren',TestBigChildren);
  SetRegistry.WriteBool('UseAnnotations',UseAnnotations);
  SetRegistry.WriteBool('UseFlashFiles',UseFlashFiles);
  SetRegistry.WriteBool('ShowProgress',ShowProgress);
  SetRegistry.WriteInteger('SearchPriority',3);

  SetRegistry.WriteBool('UseIcons',UseIcons);
  SetRegistry.WriteBool('SaveLayout',SaveLayout);

  SetRegistry.WriteBool('UseExDecomp', UseExDecomp);
end;

procedure TPreferences.LayoutSave;
var
  Placement: TWindowPlacement;
begin
  SetRegistry.OpenKey('\Software\WaitingWorlds\SCUMMRev\Layout',true);
  MainForm.Hide;
  // Write MainForm Layout
  Placement.Length:=SizeOf(TWindowPlacement);
  GetWindowPlacement(MainForm.Handle,@Placement);
  SetRegistry.WriteInteger('MainTop',Placement.rcNormalPosition.Top);
  SetRegistry.WriteInteger('MainLeft',Placement.rcNormalPosition.Left);
  SetRegistry.WriteInteger('MainBottom',Placement.rcNormalPosition.Bottom);
  SetRegistry.WriteInteger('MainRight',Placement.rcNormalPosition.Right);

  SetRegistry.WriteInteger('ExplorerSplitPos',MainForm.ExplorerSplitter.Position);
  SetRegistry.WriteInteger('AnnotSplitPos',MainForm.AnnotationSplitter.Position);
  SetRegistry.WriteInteger('SearchSplitPos',MainForm.SearchSplitter.Position);

  if (MainForm.WindowState = wsNormal) or (MainForm.WindowState = wsMinimized) then
    SetRegistry.WriteBool('MainMax',false)
  else
    SetRegistry.WriteBool('MainMax',true);

  SetRegistry.OpenKey('\Software\WaitingWorlds\SCUMMRev\Settings',true);
end;

procedure TPreferences.ExecSettings;
begin
  if UseIcons then
  begin
    MainForm.ExplorerTreeView.Images:=MainForm.IconImageList;
  end
  else
  begin
    MainForm.ExplorerTreeView.Images:=nil;
  end;
end;

procedure TOptionsForm.ApplySettings;
begin
  with MainForm.Preferences do
  begin
    TestBigChildren:=TestBigChildrenCheckBox.Checked;
    UseAnnotations:=UseAnnotationsCheckBox.Checked;
    UseFlashFiles:=UseFlashFilesCheckBox.Checked;
    SearchPriority:=SearchPriorityTrackBar.Position;
    ShowProgress:=ShowProgressCheckBox.Checked;
    SaveLayout:=SaveLayoutCheckBox.Checked;
    UseIcons:=UseIconsCheckBox.Checked;

    UseExDecomp:=UseExDecompCheckBox.Checked;

    ExecSettings;
  end;
end;

procedure TOptionsForm.OKButtonClick(Sender: TObject);
begin
  ApplySettings;
  MainForm.Preferences.Save;
  ModalResult:=1;
end;

procedure TOptionsForm.ApplyButtonClick(Sender: TObject);
begin
  ApplySettings;
  ModalResult:=1;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
  ModalResult:=1;
end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  TestBigChildrenCheckBox.Checked:=MainForm.Preferences.TestBigChildren;
  UseAnnotationsCheckBox.Checked:=MainForm.Preferences.UseAnnotations;
  UseFlashFilesCheckBox.Checked:=MainForm.Preferences.UseFlashFiles;
  SearchPriorityTrackBar.Position:=MainForm.Preferences.SearchPriority;
  ShowProgressCheckBox.Checked:=MainForm.Preferences.ShowProgress;
  SearchPriorityResultLabel.Caption:=PriorityTitles[SearchPriorityTrackBar.Position];

  UseIconsCheckBox.Checked:=MainForm.Preferences.UseIcons;
  SaveLayoutCheckBox.Checked:=MainForm.Preferences.SaveLayout;

  UseExDecompCheckBox.Checked:=MainForm.Preferences.UseExDecomp;
end;

procedure TOptionsForm.SearchPriorityTrackBarChange(Sender: TObject);
begin
  SearchPriorityResultLabel.Caption:=PriorityTitles[SearchPriorityTrackBar.Position];
end;

procedure TOptionsForm.DesktopIconButtonClick(Sender: TObject);
begin
  CreateLink(Application.ExeName,'','','SCUMM Revisited.lnk',slDesktop);
end;

procedure TOptionsForm.StartIconButtonClick(Sender: TObject);
begin
  {$I-}
    MkDir(WindowsInfo.ProgramsDir+'\SCUMM Revisited');
  {$I+}
  CreateLink(ExtractFileDir(Application.ExeName)+'\SCUMMRev.chm','','','SCUMM Revisited\SCUMM Revisited Help.lnk',slPrograms);
  CreateLink(Application.ExeName,'','','SCUMM Revisited\SCUMM Revisited.lnk',slPrograms);
end;

procedure TOptionsForm.UninstallButtonClick(Sender: TObject);
begin
  if MessageDlg('This will remove all settings from the registry and delete Desktop/Start Menu icons. Are you sure?',mtWarning,[mbYes, mbNo],0) = mrYes then
  begin
    with MainForm.Preferences.SetRegistry do
    begin
      DeleteKey('\Software\WaitingWorlds\SCUMMRev\Settings');
      DeleteKey('\Software\WaitingWorlds\SCUMMRev\MRUF Items');
      DeleteKey('\Software\WaitingWorlds\SCUMMRev\Layout');
      DeleteKey('\Software\WaitingWorlds\SCUMMRev');
      if OpenKey('\Software\WaitingWorlds',false) then
      begin
        if not HasSubKeys then
        begin
          CloseKey;
          DeleteKey('Software\WaitingWorlds');
        end;
      end;
    end;
    DeleteFile(WindowsInfo.ProgramsDir+'\SCUMM Revisited\SCUMM Revisited.lnk');
    DeleteFile(WindowsInfo.ProgramsDir+'\SCUMM Revisited\SCUMM Revisited Help.lnk');
    RemoveDir(WindowsInfo.ProgramsDir+'\SCUMM Revisited');
    DeleteFile(WindowsInfo.DesktopDir+'\SCUMM Revisited.lnk');
    MainForm.Preferences.SaveLayout:=false;
    MainForm.MRUFileList.AutoSave:=false;
    CancelButtonClick(Self);
    MessageDlg('SCUMM Revisited has been uninstalled. If you later wish to reinstall, run '+#13+#10+Application.ExeName+'.'+#13+#10+'If not, you may safely delete the '+#13+#10+ExtractFileDir(Application.ExeName)+' directory.',mtInformation,[mbOK],0);
    MainForm.Close;
  end;
end;

end.
