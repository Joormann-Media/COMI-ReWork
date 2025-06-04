unit Boxes;

interface

uses
  Windows, Graphics, ExtCtrls, Classes;

const

  PulseColors: array[1..8] of TColor = ($000000,$444444,$888888,$CCCCCC,$FFFFFF,$CCCCCC,$888888,$444444);
  SelectedPulseColors: array[1..8] of TColor = ($FF0000,$0000FF,$FF0000,$0000FF,$FF0000,$0000FF,$FF0000,$0000FF);
type
  TParams = array[0..4] of longint;

  PBox = ^TBox;
  TBox = record
    P : array[0..3] of TPoint;
    Params: TParams;
  end;
  TBoxViewer  = class
  public
    BoxList : TList;
    NoOfParams: integer;
    CompStuff: cardinal;
    constructor Create;
    destructor Destroy; override;
    procedure DrawBoxes;
    procedure AddBox(Point1, Point2, Point3, Point4: TPoint; AParams: TParams);
    procedure TimerTrigger(Sender: TObject);
  private
    FPulsing : boolean;
    FColor   : TColor;
    FSelectedColor : TColor;
    FSelected: integer;
    PulseTimer : TTimer;
    CurrPulseColor : byte;
    procedure SetColor(Value: TColor);
    procedure SetPulsing(Value: boolean);
    procedure SetSelected(Value: integer);
  published
    property Color: TColor read FColor write SetColor;
    property SelectedColor: TColor read FSelectedColor write FSelectedColor;
    property Pulsing: boolean read FPulsing write SetPulsing;
    property Selected: integer read FSelected write SetSelected;
  end;

implementation
uses
  SpecForm, SysUtils;

constructor TBoxViewer.Create;
begin
  Pulsing:=false;
  BoxList:=TList.Create;
  Selected:=-1;
  Color:=$000000;
  SelectedColor:=$0000FF;
  CompStuff:=0;
end;

destructor TBoxViewer.Destroy;
var
  n: integer;
begin
  Pulsing:=false;
  for n:=0 to BoxList.Count-1 do
  begin
    Dispose(BoxList.Items[n]);
  end;
  BoxList.Free;
  inherited;
end;

procedure TBoxViewer.DrawBoxes;
var
  n: integer;
begin
  for n:=0 to BoxList.Count - 1 do
  begin
    if Pulsing then
      SpecInfoForm.Spec1Image.Canvas.Pen.Color:=PulseColors[CurrPulseColor]
    else
      SpecInfoForm.Spec1Image.Canvas.Pen.Color:=FColor;
    With PBox(BoxList.Items[n])^ do
    begin
      SpecInfoForm.Spec1Image.Canvas.PolyLine([P[0],P[1],P[2],P[3],P[0]]);
    end;
  end;
  if Pulsing then
    SpecInfoForm.Spec1Image.Canvas.Pen.Color:=SelectedPulseColors[CurrPulseColor]
  else
    SpecInfoForm.Spec1Image.Canvas.Pen.Color:=FSelectedColor;
  With PBox(BoxList.Items[FSelected])^ do
  begin
    SpecInfoForm.Spec1Image.Canvas.PolyLine([P[0],P[1],P[2],P[3],P[0]]);
  end;
end;

procedure TBoxViewer.AddBox(Point1, Point2, Point3, Point4: TPoint; AParams: TParams);
var
  PB: PBox;
begin
  New(PB);
  with PB^ do
  begin
    P[0]:=Point1;
    P[1]:=Point2;
    P[2]:=Point3;
    P[3]:=Point4;
    Params:=AParams
  end;
  BoxList.Add(PB);
end;

procedure TBoxViewer.SetColor(Value: TColor);
begin
  FColor:=Value;
end;

procedure TBoxViewer.TimerTrigger(Sender: TObject);
begin
  PulseTimer.Interval:=200;
  Inc(CurrPulseColor);
  if CurrPulseColor>8 then
    CurrPulseColor:=1;
  DrawBoxes;
end;

procedure TBoxViewer.SetSelected(Value: integer);
begin
  if Value<BoxList.Count then
  begin
    FSelected:=Value;
  end;
end;

procedure TBoxViewer.SetPulsing(Value: boolean);
begin
  FPulsing:=Value;
  if FPulsing then
  begin
    PulseTimer:=TTimer.Create(SpecInfoForm);
    PulseTimer.Interval:=200;
    PulseTimer.OnTimer:=TimerTrigger;
    CurrPulseColor:=1;
  end
  else
  begin
    if PulseTimer<>nil then
    begin
      PulseTimer.Enabled:=false;
      PulseTimer.Free;
      PulseTimer:=nil;
    end;
  end;
end;

end.
