program SCUMMRev;

uses
  Forms,
  main in 'main.pas' {MainForm},
  About in 'About.pas' {AboutBox},
  Analyze in 'Analyze.pas',
  Annot in 'Annot.pas',
  AnnotDlg in 'AnnotDlg.pas' {AnnotDialog},
  ChunkSpecs in 'ChunkSpecs.pas',
  IniFiles32 in 'IniFiles32.pas',
  Input in 'Input.pas',
  Options in 'Options.pas' {OptionsForm},
  Preanalyze in 'Preanalyze.pas',
  Spec in 'Spec.pas',
  SpecForm in 'SpecForm.pas' {SpecInfoForm},
  Tables in 'Tables.pas',
  Search in 'Search.pas',
  HexView in 'HexView.pas', {HexForm}
  HexGoto in 'HexGoto.pas'; {GotoDialog}
{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'SCUMM Revisited';
  Application.HelpFile := 'scummrev.chm';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TAnnotDialog, AnnotDialog);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TSpecInfoForm, SpecInfoForm);
  Application.CreateForm(THexForm, HexForm);
  Application.CreateForm(TGotoDialog, GotoDialog);
  Application.Run;
end.
