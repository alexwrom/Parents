unit uFrameAdd;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Effects, uAddChildFrame, uLibrary;

type
  TFrameAdd = class(TFrame)
    selRect: TLayout;
    Rectangle: TRectangle;
    Rectangle1: TRectangle;
    ShadowEffect1: TShadowEffect;
    Layout1: TLayout;
    GridPanelLayout1: TGridPanelLayout;
    Layout3: TLayout;
    Circle1: TCircle;
    btnParent: TSpeedButton;
    Layout4: TLayout;
    Circle2: TCircle;
    btnAddBS: TSpeedButton;
    Layout5: TLayout;
    Circle3: TCircle;
    btnAddChild: TSpeedButton;
    Layout8: TLayout;
    Circle6: TCircle;
    addMarried: TSpeedButton;
    Layout6: TLayout;
    Circle4: TCircle;
    btnInfo: TSpeedButton;
    Layout7: TLayout;
    Circle5: TCircle;
    btnCloseSelRect: TSpeedButton;
    Circle7: TCircle;
    procedure btnCloseSelRectClick(Sender: TObject);
    procedure btnInfoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

implementation

uses uMain;
{$R *.fmx}

procedure TFrameAdd.btnCloseSelRectClick(Sender: TObject);
begin
  MainForm.addFrame.Parent := nil;
  FreeAndNil(MainForm.addFrame);
end;

procedure TFrameAdd.btnInfoClick(Sender: TObject);
begin
  if MainForm.AddChildFrame = nil then
    MainForm.AddChildFrame := TAddChildFrame.Create(nil);

  MainForm.AddChildFrame.Parent := MainForm.tabAdd;
  MainForm.AddChildFrame.Tag := Self.Tag;
  MainForm.AddChildFrame.Hint := ttEdit.ToString;
  MainForm.AddChildFrame.Load;

  btnCloseSelRectClick(nil);
end;


end.
