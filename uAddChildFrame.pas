unit uAddChildFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.DateTimeCtrls, FMX.Layouts, FMX.ScrollBox, FMX.Memo,
  FMX.TabControl, FMX.Edit, FMX.Objects, FMX.Controls.Presentation, uLibrary, StrUtils, FMX.DialogService;

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
    FirstName: TEdit;
    MiddleName: TEdit;
    LastName: TEdit;
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
    MaidenName: TEdit;
    layParent: TLayout;
    GridPanelLayout1: TGridPanelLayout;
    layFather: TLayout;
    layMother: TLayout;
    Photo: TCircle;
    Label13: TLabel;
    btnSave: TSpeedButton;
    btnDeleteChild: TSpeedButton;
    btnBack: TSpeedButton;
    VertScrollBox2: TVertScrollBox;
    VertScrollBox3: TVertScrollBox;
    procedure swDeadSwitch(Sender: TObject);
    procedure swSexSwitch(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnDeleteChildClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);
  end;

implementation

uses uMain, uTreeFrame;
{$R *.fmx}

procedure TAddChildFrame.btnBackClick(Sender: TObject);
begin
  MainForm.controlMain.ActiveTab := MainForm.tabTree;
  MainForm.TreeFrame.spGeneration.OnChange(nil);
  FreeAndNil(MainForm.TreeFrame.AddChildFrame);
end;

procedure TAddChildFrame.btnSaveClick(Sender: TObject);
var
  Sex: string;
  dd, mm, yyyy, yyD: string;
begin
  Sex := IfThen(swSex.IsChecked, 'f', 'm');
  DateTimeToString(dd, 'dd', dateBirth.Date);
  DateTimeToString(mm, 'mm', dateBirth.Date);
  DateTimeToString(yyyy, 'yyyy', dateBirth.Date);
  if swDead.IsChecked then
    DateTimeToString(yyD, 'yyyy', dateDeath.Date)
  else
    yyD := 'NULL';

  case Self.Hint.ToInteger of
    ttNewChild:
      begin
        ExeSQL(Format('insert into tree (father_id,mother_id,sex,firstname,lastname,middlename,old_fam,born_day,born_month,born_year,dead_year) values (%d,%d,''%s'',''%s'',''%s'',''%s'',%s,%s,%s,%s,%s)',
          [layFather.Tag, layMother.Tag, Sex, FirstName.Text, LastName.Text, MiddleName.Text, IfThen(MaidenName.Text = '', 'NULL', '''' + MaidenName.Text + ''''), dd, mm, yyyy, yyD]));
        ExeActive('select photo from tree where child_id = (select max(child_id) from tree)');
        tmpQuery.Edit;
        tmpQuery.FieldByName('photo').Assign(Photo.Fill.Bitmap.Bitmap);
        tmpQuery.Post;
      end;
    ttNewBS:
      begin
        ExeSQL(Format('insert into tree (father_id,mother_id,sex,firstname,lastname,middlename,old_fam,born_day,born_month,born_year,dead_year) values (%d,%d,''%s'',''%s'',''%s'',''%s'',%s,%s,%s,%s,%s)',
          [layFather.Tag, layMother.Tag, Sex, FirstName.Text, LastName.Text, MiddleName.Text, IfThen(MaidenName.Text = '', 'NULL', '''' + MaidenName.Text + ''''), dd, mm, yyyy, yyD]));
        ExeActive('select photo from tree where child_id = (select max(child_id) from tree)');
        tmpQuery.Edit;
        tmpQuery.FieldByName('photo').Assign(Photo.Fill.Bitmap.Bitmap);
        tmpQuery.Post;
      end;
    ttEdit:
      begin
        ExeSQL(Format('update tree set father_id = %d,mother_id = %d,firstname = ''%s'',lastname = ''%s'',middlename = ''%s'',old_fam = %s,born_day = %s,born_month = %s,born_year = %s,dead_year = %s where child_id = %d ',
          [layFather.Tag, layMother.Tag, FirstName.Text, LastName.Text, MiddleName.Text, IfThen(MaidenName.Text = '', 'NULL', '''' + MaidenName.Text + ''''), dd, mm, yyyy, yyD, Self.Tag]));
        ExeActive('select photo from tree where child_id = ' + Self.Tag.ToString);
        tmpQuery.Edit;
        tmpQuery.FieldByName('photo').Assign(Photo.Fill.Bitmap.Bitmap);
        tmpQuery.Post;
      end;
  end;

  btnBackClick(nil);
end;

constructor TAddChildFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TAddChildFrame.btnDeleteChildClick(Sender: TObject);
var
  fText: string;
begin
  // if AppForm.Langs.Lang = 'ru' then
  begin
    fText := 'Вы согласны с удалением?';
  end;
  // else if AppForm.Langs.Lang = 'en' then
  // begin
  // fText := 'Do you agree with the deletion?';
  // end
  // else if AppForm.Langs.Lang = 'es' then
  // begin
  // fText := '¿Estás de acuerdo con la eliminación?';
  // end;

  TDialogService.MessageDialog(fText, TmsgDlgType.mtInformation, [TmsgDlgBtn.mbYes, TmsgDlgBtn.mbNo], TmsgDlgBtn.mbYes, 0,
    procedure(const AResult: TmodalResult)
    begin
      if AResult = mrYes then
      begin
        ExeSQL('delete from tree where child_id = ' + Self.Tag.ToString);
        if swSex.IsChecked then
          ExeSQL('update tree set mother_id = NULL where mother_id = ' + Self.Tag.ToString)
        else
          ExeSQL('update tree set father_id = NULL where father_id = ' + Self.Tag.ToString);

        btnBackClick(nil);
      end;
    end);

end;

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
