unit TabListBox; {enables tabs in a listbox}
interface

uses WinTypes, Classes, Controls, StdCtrls;

type
  TTabsListBox = class(TListBox)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

procedure TTabsListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style:= Params.Style or LBS_USETABSTOPS;
end;

end.
