unit AnnotDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Dialogs;

type
  TAnnotDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    TitleTitleLabel: TLabel;
    TitleEdit: TEdit;
    AuthorTitleLabel: TLabel;
    AuthorEdit: TEdit;
    FileNameTitleLabel: TLabel;
    FileNameEdit: TEdit;
    BrowseButton: TButton;
    GameFileTitleLabel: TLabel;
    GameFileLabel: TLabel;
    GameFileSizeTitleLabel: TLabel;
    GameFileSizeLabel: TLabel;
    SaveDialog: TSaveDialog;
    procedure OKBtnClick(Sender: TObject);
    procedure BrowseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    Title: string;
    Author: string;
    FileName: string;
    { Public declarations }
  end;

var
  AnnotDialog: TAnnotDialog;

implementation

{$R *.DFM}

procedure TAnnotDialog.OKBtnClick(Sender: TObject);
begin
  Title:=TitleEdit.Text;
  Author:=AuthorEdit.Text;
  FileName:=FileNameEdit.Text;
  ModalResult:=42;
end;

procedure TAnnotDialog.BrowseButtonClick(Sender: TObject);
begin
  if SaveDialog.Execute then
    FileNameEdit.Text:=ExtractFileName(SaveDialog.FileName);
end;

end.
