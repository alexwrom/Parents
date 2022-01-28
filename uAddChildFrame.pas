unit uAddChildFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.DateTimeCtrls, FMX.Layouts, FMX.ScrollBox, FMX.Memo,
  FMX.TabControl, FMX.Edit, FMX.Objects, FMX.Controls.Presentation;

type
  TAddChildFrame = class(TFrame)
    ToolBar1: TToolBar;
    Layout1: TLayout;
    Layout2: TLayout;
    btnChangePhoto: TSpeedButton;
    swSex: TSwitch;
    Layout3: TLayout;
    Layout4: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    TabControl1: TTabControl;
    tabBorn: TTabItem;
    tabWork: TTabItem;
    tabAducation: TTabItem;
    tabOther: TTabItem;
    memoOther: TMemo;
    Layout9: TLayout;
    VertScrollBox1: TVertScrollBox;
    Label6: TLabel;
    dateBirth: TDateEdit;
    layDeath: TLayout;
    Label7: TLabel;
    dateDeath: TDateEdit;
    Layout10: TLayout;
    Layout11: TLayout;
    swDead: TSwitch;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Layout8: TLayout;
    Label11: TLabel;
    Edit4: TEdit;
    layMaidenName: TLayout;
    Label12: TLabel;
    Edit5: TEdit;
    layParent: TLayout;
    GridPanelLayout1: TGridPanelLayout;
    layFather: TLayout;
    layMother: TLayout;
    Photo: TCircle;
    Label13: TLabel;
    procedure swDeadSwitch(Sender: TObject);
    procedure swSexSwitch(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses uMain;
{$R *.fmx}

procedure TAddChildFrame.swDeadSwitch(Sender: TObject);
begin
  layDeath.Enabled := swDead.IsChecked;
end;

procedure TAddChildFrame.swSexSwitch(Sender: TObject);
begin
layMaidenName.Enabled := swSex.IsChecked;
if swSex.IsChecked then
        Photo.Fill.Bitmap.Bitmap.Assign(MainForm.listNotPhoto.Source[1].MultiResBitmap[0].Bitmap)
      else
        Photo.Fill.Bitmap.Bitmap.Assign(MainForm.listNotPhoto.Source[0].MultiResBitmap[0].Bitmap);
end;

end.
