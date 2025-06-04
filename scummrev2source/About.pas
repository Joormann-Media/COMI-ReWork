unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, verslab, ShellAPI, GifImage;

const
  Egg : string = 'LAPOSTAL';

type
  TAboutBox = class(TForm)
    AboutPanel: TPanel;
    OKButton: TButton;
    VersionLabel: TVersionLabel;
    AuthorLabel: TLabel;
    ThanksLabel: TLabel;
    CopyrightLabel: TLabel;
    DisclaimerLabel: TLabel;
    Image1: TGIFImage;
    GraphicsLabel: TLabel;
    WebpageLabel: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure WebpageLabelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    EggIndex: byte;
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}
{$R image.RES}

procedure TAboutBox.FormShow(Sender: TObject);
begin
  EggIndex:=1;
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  ModalResult:=1;
end;

procedure TAboutBox.WebPageLabelClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://www.mixnmojo.com/scumm/scummrev',nil,nil,SW_SHOWNORMAL);
end;

procedure TAboutBox.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Upcase(Key)=Egg[EggIndex] then
  begin
    Inc(EggIndex);
    if EggIndex=length(Egg)+1 then
    begin
      Image1.Animate:=true;
      EggIndex:=1;
    end;
  end
  else
  begin
    EggIndex:=1;
    if Upcase(Key)=Egg[1] then
      Inc(EggIndex);
  end;
end;

procedure TAboutBox.FormHide(Sender: TObject);
begin
  Image1.Animate:=false;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  Image1.LoadFromResourceName(HINSTANCE, 'logo');
end;

end.

