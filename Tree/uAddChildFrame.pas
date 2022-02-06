unit uAddChildFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.DateTimeCtrls, FMX.Layouts, FMX.ScrollBox, FMX.Memo,
  FMX.TabControl, FMX.Edit, FMX.Objects, FMX.Controls.Presentation, uLibrary, StrUtils, FMX.DialogService,
  FMX.ListBox, Math;

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
    layDeath: TLayout;
    Label7: TLabel;
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
    Label14: TLabel;
    Label15: TLabel;
    btnAddFather: TCornerButton;
    AddMother: TCornerButton;
    Layout12: TLayout;
    Label16: TLabel;
    Layout13: TLayout;
    BornDay: TComboBox;
    Label20: TLabel;
    BornMonth: TComboBox;
    Label17: TLabel;
    BornYear: TComboBox;
    Label18: TLabel;
    DeadYear: TComboBox;
    procedure swDeadSwitch(Sender: TObject);
    procedure swSexSwitch(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnDeleteChildClick(Sender: TObject);
  private
    function FindPeople(peopleID: integer): rPeople;
    procedure GenericDayMonthYear;

    { Private declarations }
  public
    { Public declarations }
    procedure Load;
    constructor Create(AOwner: TComponent);
  end;

implementation

uses uMain, uTreeFrame;
{$R *.fmx}

procedure TAddChildFrame.btnBackClick(Sender: TObject);
begin
  MainForm.controlMain.ActiveTab := MainForm.tabTree;

  MainForm.TreeFrame.Close;

  MainForm.TreeFrame := TTreeFrame.Create(nil);
  MainForm.TreeFrame.Parent := MainForm.tabTree;

  MainForm.AddChildFrame.Parent := nil;
  FreeAndNil(MainForm.AddChildFrame);

end;

procedure TAddChildFrame.btnSaveClick(Sender: TObject);
var
  Sex: string;
  yyD: string;
begin
  Sex := IfThen(swSex.IsChecked, 'f', 'm');

  if swDead.IsChecked then
    yyD := '''' + DeadYear.Selected.Text + ''''
  else
    yyD := 'NULL';

  case Self.Hint.ToInteger of
    ttNewChild:
      begin
        ExeSQL(Format('insert into tree (father_id,mother_id,sex,firstname,lastname,middlename,old_fam,born_day,born_month,born_year,dead_year,generation) values (%d,%d,''%s'',''%s'',''%s'',''%s'',%s,%s,%s,%s,''%s'',%s)',
          [layFather.Tag, layMother.Tag, Sex, FirstName.Text, LastName.Text, MiddleName.Text, IfThen(MaidenName.Text = '', 'NULL', '''' + MaidenName.Text + ''''), BornDay.Selected.Text, BornMonth.Selected.Text, BornYear.Selected.Text, yyD]));
        ExeActive('select photo from tree where child_id = (select max(child_id) from tree)');
        tmpQuery.Edit;
        tmpQuery.FieldByName('photo').Assign(Photo.Fill.Bitmap.Bitmap);
        tmpQuery.Post;
      end;
    ttNewBS:
      begin
        ExeSQL(Format('insert into tree (father_id,mother_id,sex,firstname,lastname,middlename,old_fam,born_day,born_month,born_year,dead_year,generation) values (%d,%d,''%s'',''%s'',''%s'',''%s'',%s,%s,%s,%s,''%s'',%s)',
          [layFather.Tag, layMother.Tag, Sex, FirstName.Text, LastName.Text, MiddleName.Text, IfThen(MaidenName.Text = '', 'NULL', '''' + MaidenName.Text + ''''), BornDay.Selected.Text, BornMonth.Selected.Text, BornYear.Selected.Text, yyD]));
        ExeActive('select photo from tree where child_id = (select max(child_id) from tree)');
        tmpQuery.Edit;
        tmpQuery.FieldByName('photo').Assign(Photo.Fill.Bitmap.Bitmap);
        tmpQuery.Post;
      end;
    ttEdit:
      begin
        ExeSQL(Format('update tree set father_id = %d,mother_id = %d,firstname = ''%s'',lastname = ''%s'',middlename = ''%s'',old_fam = %s,born_day = %s,born_month = %s,born_year = ''%s'',dead_year = %s where child_id = %d ',
          [layFather.Tag, layMother.Tag, FirstName.Text, LastName.Text, MiddleName.Text, IfThen(MaidenName.Text = '', 'NULL', '''' + MaidenName.Text + ''''), BornDay.Selected.Text, BornMonth.Selected.Text, BornYear.Selected.Text, yyD,
          MainForm.TreeFrame.listPeople[Self.Tag].child]));
        ExeActive('select photo from tree where child_id = ' + MainForm.TreeFrame.listPeople[Self.Tag].child.ToString);
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

  GenericDayMonthYear;

end;

procedure TAddChildFrame.Load;
var
  father, mother: integer;
  Parent: rPeople;
begin
  case Self.Hint.ToInteger of
    ttNewChild:
      begin

      end;
    ttNewBS:
      begin

      end;
    ttEdit:
      begin
        btnDeleteChild.Visible := true;
        MainForm.controlMain.ActiveTab := MainForm.tabAdd;
        ExeActive('select * from tree where child_id = ' + MainForm.TreeFrame.listPeople[Self.Tag].child.ToString);
        father := tmpQuery.FieldByName('father_id').AsInteger;
        mother := tmpQuery.FieldByName('mother_id').AsInteger;

        swSex.IsChecked := MainForm.TreeFrame.listPeople[Self.Tag].Sex = 'f';
        swSex.Enabled := false;

        Photo.Fill.Bitmap.Bitmap.Assign(tmpQuery.FieldByName('photo'));

        FirstName.Text := tmpQuery.FieldByName('firstname').AsString;
        LastName.Text := tmpQuery.FieldByName('lastname').AsString;
        MiddleName.Text := tmpQuery.FieldByName('middlename').AsString;
        MaidenName.Text := tmpQuery.FieldByName('old_fam').AsString;

        BornDay.ItemIndex := tmpQuery.FieldByName('born_day').AsInteger;
        BornMonth.ItemIndex := tmpQuery.FieldByName('born_month').AsInteger;
        BornYear.ItemIndex := BornYear.Items.IndexOf(tmpQuery.FieldByName('born_year').AsString);

        swDead.IsChecked := tmpQuery.FieldByName('dead_year').AsString <> '';
        if tmpQuery.FieldByName('dead_year').AsString <> '' then
          DeadYear.ItemIndex := DeadYear.Items.IndexOf(tmpQuery.FieldByName('dead_year').AsString);

        Parent := FindPeople(father);
        if Parent.child > 0 then
        begin
          MainForm.AddChildFrame.layFather.Tag := Parent.child;
          MainForm.TreeFrame.CreatePeople(MainForm.AddChildFrame.layFather, Parent, Other);
        end;

        Parent := FindPeople(mother);

        if Parent.child > 0 then
        begin
          MainForm.AddChildFrame.layMother.Tag := Parent.child;
          MainForm.TreeFrame.CreatePeople(MainForm.AddChildFrame.layMother, Parent, Other);
        end;
      end;
  end;
end;

procedure TAddChildFrame.GenericDayMonthYear;
var
  I: integer;
  year: string;
begin
  // Days
  for I := 0 to 31 do
  begin
    with TListBoxItem.Create(nil) do
    begin
      Parent := BornDay;
      StyledSettings := [];
      Font.Family := 'Roboto';
      Font.Size := 11;
      FontColor := TAlphaColors.Slategray;

      if I = 0 then
        Text := '?'
      else
        Text := I.ToString;
    end;
  end;

  // Month
  for I := 0 to 12 do
  begin
    with TListBoxItem.Create(nil) do
    begin
      Parent := BornMonth;
      Parent := BornMonth;
      StyledSettings := [];
      Font.Family := 'Roboto';
      Font.Size := 11;
      FontColor := TAlphaColors.Slategray;

      if I = 0 then
        Text := '?'
      else
        Text := I.ToString;
    end;
  end;

  // Year
  for I := -1 to 200 do
  begin
    DateTimeToString(year, 'yyyy', NOW());

    with TListBoxItem.Create(nil) do
    begin
      Parent := BornYear;
      StyledSettings := [];
      Font.Family := 'Roboto';
      Font.Size := 11;
      FontColor := TAlphaColors.Slategray;

      if I = -1 then
        Text := '?'
      else
        Text := (year.ToInteger - I).ToString;
    end;

    with TListBoxItem.Create(nil) do
    begin
      Parent := DeadYear;
      StyledSettings := [];
      Font.Family := 'Roboto';
      Font.Size := 11;
      FontColor := TAlphaColors.Slategray;

      if I = -1 then
        Text := '?'
      else
        Text := (year.ToInteger - I).ToString;
    end;
  end;
end;

function TAddChildFrame.FindPeople(peopleID: integer): rPeople;
var
  I: integer;
begin
  for I := 0 to MainForm.TreeFrame.listPeople.Count - 1 do
    if (MainForm.TreeFrame.listPeople[I].child = peopleID) then
    begin
      result := MainForm.TreeFrame.listPeople[I];
      exit;
    end;
  result := MainForm.TreeFrame.listPeople[Self.Tag];
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
