unit uTreeFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uLibrary,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, Generics.Collections, Math,
  FMX.Edit, FMX.EditBox, FMX.SpinBox, Data.DB, System.ImageList, FMX.ImgList,
  FMX.ExtCtrls, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.Gestures, uAddChildFrame, FireDAC.Comp.Client, StrUtils;

type
  rPeople = record
    child: integer;
    father: integer;
    mother: integer;
    married: integer;
    sex: string;
    gen: integer;
    photo: TBitmap;
    photo_exist: integer;
    is_active: boolean;
    name: string;
    born: string;
    dead: string;
    is_dead: integer;
    layParents: TLayout;
    layChildren: TLayout;
    layBS: TLayout;
  end;

  TTreeFrame = class(TFrame)
    Pano: TScrollBox;
    Layout2: TLayout;
    btnPrint: TSpeedButton;
    Rectangle: TRectangle;
    ShadowEffect1: TShadowEffect;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
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
    Layout6: TLayout;
    Circle4: TCircle;
    btnInfo: TSpeedButton;
    layBS: TLayout;
    HorzScrollBox1: THorzScrollBox;
    Circle5: TCircle;
    btnCloseSelRect: TSpeedButton;
    selRect: TLayout;
    Layout7: TLayout;
    Layout8: TLayout;
    ToolBar1: TToolBar;
    procedure btnPrintClick(Sender: TObject);

  private
    peopleActive: rPeople;
    listPeople: TList<rPeople>;
    listChildren: TList<rPeople>;
    listBrS: TList<rPeople>;
    listOther: TList<rPeople>;
    listPeopleInTree: TList<rPeople>;
    peopleMarried: rPeople;
    MaxGeneration: integer;
    layActive: TLayout;
    procedure LoadPeople;
    procedure GenericTree;
    function CreatePeople(vPeople: rPeople; typePeople: tTypePeople): TLayout;
    function GetPosition(vPeople: rPeople): TPosition;
    function GetPosChild(ChildID: integer): TPosition;
    function GetChildID(ParentID: integer): integer;

    { Private declarations }
  public
    { Public declarations }
    AddChildFrame: TAddChildFrame;
    constructor Create(AOwner: TComponent);
  end;

implementation

uses uMain;
{$R *.fmx}
{ TTreeFrame }

// Сделать скриншот древа
procedure TTreeFrame.btnPrintClick(Sender: TObject);
begin
  Pano.MakeScreenshot.SaveToFile(ExtractFilePath(paramstr(0)) + '\Screen.bmp');
end;

constructor TTreeFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  listPeople := TList<rPeople>.Create;
  listChildren := TList<rPeople>.Create;
  listBrS := TList<rPeople>.Create;
  listOther := TList<rPeople>.Create;
  listPeopleInTree := TList<rPeople>.Create;
  LoadPeople;
  GenericTree;

end;

// Строим дерево вверх
procedure TTreeFrame.GenericTree;
var
  I: integer;
  ChildID: integer;
begin
  MaxGeneration := 5;
  for I := 0 to listOther.Count - 1 do
  begin
    ChildID := GetChildID(listOther[I].child);
    if (ChildID > 0) and (listOther[I].gen < MaxGeneration + peopleActive.gen) then
      CreatePeople(listOther[I], Other);
  end;

end;

// Получение позиции
function TTreeFrame.GetPosition(vPeople: rPeople): TPosition;
var
  tmpPoint: TPosition;
  maxWidth: double;

begin
  maxWidth := Power(2, MaxGeneration - 1) * 150;
  tmpPoint := GetPosChild(GetChildID(vPeople.child));

  tmpPoint.Y := tmpPoint.Y - 250;
  if vPeople.sex = 'm' then
    tmpPoint.X := tmpPoint.X - (75) - (maxWidth / Power(2, vPeople.gen - peopleActive.gen) - (150)) / 2
  else
    tmpPoint.X := tmpPoint.X + (75) + (maxWidth / Power(2, vPeople.gen - peopleActive.gen) - (150)) / 2;

  result := tmpPoint;
end;

// Поиск ID ребенка
function TTreeFrame.GetChildID(ParentID: integer): integer;
var
  I: integer;
begin

  for I := 0 to listPeopleInTree.Count - 1 do
    if (listPeopleInTree[I].father = ParentID) or (listPeopleInTree[I].mother = ParentID) then
    begin
      result := listPeopleInTree[I].child;
      exit
    end;
  result := -1;
end;

// Поиск позиции ребенка
function TTreeFrame.GetPosChild(ChildID: integer): TPosition;
var
  tmpPoint: TPosition;
  I: integer;
begin
  tmpPoint := TPosition.Create(TPointF.Create(0, 0));

  for I := 0 to Pano.Content.ChildrenCount - 1 do
    if Pano.Content.Children[I] is TLayout then
    begin
      if (Pano.Content.Children[I] as TLayout).Tag = ChildID then
      begin

        tmpPoint.X := (Pano.Content.Children[I] as TLayout).Position.X;
        tmpPoint.Y := (Pano.Content.Children[I] as TLayout).Position.Y;
        break;
      end;
    end;

  result := tmpPoint;
end;

// Загрузка из базы и создание Первого, его суприга(и), детей, братьев
procedure TTreeFrame.LoadPeople();
var
  tmpRecord: rPeople;
  tmpPhoto: TBitmap;
begin
  ExeActive('select * from tree_data order by is_active desc,generation');
  tmpQuery.First;

  with tmpRecord do
  begin
    child := tmpQuery.FieldByName('child_id').AsInteger;
    father := tmpQuery.FieldByName('father_id').AsInteger;
    mother := tmpQuery.FieldByName('mother_id').AsInteger;
    married := tmpQuery.FieldByName('married').AsInteger;
    sex := tmpQuery.FieldByName('sex').AsString;
    gen := tmpQuery.FieldByName('generation').AsInteger;

    photo_exist := tmpQuery.FieldByName('photoExist').AsInteger;
    if photo_exist = 1 then
    begin
      photo := TBitmap.Create;
      photo.Assign(tmpQuery.FieldByName('photo'));
    end;

    is_active := tmpQuery.FieldByName('is_active').AsBoolean;
    name := tmpQuery.FieldByName('name').AsString;
    born := tmpQuery.FieldByName('born').AsString;
    dead := tmpQuery.FieldByName('dead').AsString;
    is_dead := tmpQuery.FieldByName('is_dead').AsInteger;
  end;
  listPeople.Add(tmpRecord);
  peopleActive := tmpRecord;
  layActive := TLayout.Create(nil);
  layActive := CreatePeople(peopleActive, Active);
  listPeopleInTree.Add(peopleActive);
  tmpQuery.Next;

  while NOT tmpQuery.EOF do
  begin
    with tmpRecord do
    begin
      child := tmpQuery.FieldByName('child_id').AsInteger;
      father := tmpQuery.FieldByName('father_id').AsInteger;
      mother := tmpQuery.FieldByName('mother_id').AsInteger;
      married := tmpQuery.FieldByName('married').AsInteger;
      sex := tmpQuery.FieldByName('sex').AsString;
      gen := tmpQuery.FieldByName('generation').AsInteger;

      photo_exist := tmpQuery.FieldByName('photoExist').AsInteger;
      if photo_exist = 1 then
      begin
        photo := TBitmap.Create;
        photo.Assign(tmpQuery.FieldByName('photo'));
      end;

      is_active := tmpQuery.FieldByName('is_active').AsBoolean;
      name := tmpQuery.FieldByName('name').AsString;
      born := tmpQuery.FieldByName('born').AsString;
      dead := tmpQuery.FieldByName('dead').AsString;
      is_dead := tmpQuery.FieldByName('is_dead').AsInteger;
    end;
    listPeople.Add(tmpRecord);

    if (tmpRecord.father = listPeople[0].child) or (tmpRecord.mother = listPeople[0].child) then
    begin
      listChildren.Add(tmpRecord);
      CreatePeople(tmpRecord, child);
    end
    else if (tmpRecord.father = listPeople[0].father) or (tmpRecord.mother = listPeople[0].mother) then
    begin
      listBrS.Add(tmpRecord);
      CreatePeople(tmpRecord, BrS);
    end
    else if (tmpRecord.child = listPeople[0].married) then
    begin
      peopleMarried := tmpRecord;
      CreatePeople(tmpRecord, married);
    end
    else
    begin
      listOther.Add(tmpRecord);
    end;

    tmpQuery.Next;
  end;

end;

// Механизм создания карточки
function TTreeFrame.CreatePeople(vPeople: rPeople; typePeople: tTypePeople): TLayout;
var
  tmpCircle: TCircle;
  tmpName: TLabel;
  tmpLine: TRectangle;
  tmpLay: TLayout;
  ChildPosition: TPosition;
  SelfPosition: TPosition;
  tmpBack: TRectangle;
  tmpSex: TRectangle;
  tmpExpand: TCircle;
begin

  ChildPosition := GetPosChild(GetChildID(vPeople.child));
  SelfPosition := GetPosition(vPeople);

  if vPeople.child = peopleActive.child then
  begin
    // Wife
    tmpLine := TRectangle.Create(Pano);
    with tmpLine do
    begin
      Parent := Pano;
      Width := 250;
      Height := 3;
      Position.Y := 100;
      Corners := [];
      Sides := [TSide.Top];
      Position.X := 75;
      Fill.Kind := TBrushKind.None;
      Stroke.Color := TAlphaColors.Slategray;
      Stroke.Thickness := 3;
      SendToBack;
    end;

    with TCircle.Create(Pano) do
    begin
      Parent := Pano;
      Position.X := 200 - 24;
      Position.Y := 100 - 24;
      Width := 48;
      Height := 48;
      Stroke.Thickness := 4;
      Stroke.Color := TAlphaColors.Slategray;
    end;

    // BrS
    tmpLine := TRectangle.Create(Pano);
    with tmpLine do
    begin
      Parent := Pano;
      Width := 250;
      Height := 3;
      Position.Y := 100;
      Corners := [];
      Sides := [TSide.Top];
      Position.X := -175;
      Fill.Kind := TBrushKind.None;
      Stroke.Color := TAlphaColors.Slategray;
      Stroke.Thickness := 3;
      SendToBack;
    end;

    with TCircle.Create(Pano) do
    begin
      Parent := Pano;
      Position.X := -50 - 24;
      Position.Y := 100 - 24;
      Width := 48;
      Height := 48;
      Stroke.Thickness := 4;
      Stroke.Color := TAlphaColors.Slategray;
    end;

    // Children
    tmpLine := TRectangle.Create(Pano);
    with tmpLine do
    begin
      Parent := Pano;
      Width := 3;
      Height := 290;
      Position.Y := 100;
      Corners := [];
      Sides := [TSide.Left];
      Position.X := 75;
      Fill.Kind := TBrushKind.None;
      Stroke.Color := TAlphaColors.Slategray;
      Stroke.Thickness := 3;
      SendToBack;
    end;

    with TCircle.Create(Pano) do
    begin
      Parent := Pano;
      Position.X := 75 - 24 + 1.5;
      Position.Y := 250 - 24;
      Width := 48;
      Height := 48;
      Stroke.Thickness := 4;
      Stroke.Color := TAlphaColors.Slategray;
    end;
  end
  else
  begin
    tmpLine := TRectangle.Create(Pano);

    with tmpLine do
    begin
      Parent := Pano;

      Width := ABS(ChildPosition.X - SelfPosition.X);

      Height := 220;
      Position.Y := ChildPosition.Y - 135;

      if vPeople.sex = 'm' then
      begin
        Corners := [TCorner.TopRight];
        Sides := [TSide.Right, TSide.Top];
        Position.X := SelfPosition.X + 77;
      end
      else
      begin
        Corners := [TCorner.TopLeft];
        Sides := [TSide.Left, TSide.Top];

        Position.X := ChildPosition.X + 74;
      end;
      CornerType := TCornerType.Round;
      XRadius := 15;
      YRadius := 15;
      Fill.Kind := TBrushKind.None;
      Stroke.Color := TAlphaColors.Slategray;
      Stroke.Thickness := 3;
      SendToBack;
      Visible := true;
    end;
  end;

  // Главный слой
  tmpLay := TLayout.Create(Pano);
  with tmpLay do
  begin
    Parent := Pano;
    Height := 200; // Высота карточки
    Width := 150; // Ширина карточки
    Tag := vPeople.child;
    Hint := vPeople.sex;
    case typePeople of
      Active:
        begin
          Position.X := 0;
          Position.Y := 0;
        end;
      child:
        begin
          Position.X := layActive.Position.X + (listChildren.Count - 1) * 160;
          Position.Y := layActive.Position.Y + 300;
        end;
      BrS:
        begin
          Position.X := layActive.Position.X + (listBrS.Count - 1) * (-160) - 250;
          Position.Y := layActive.Position.Y;
        end;
      married:
        begin
          Position.X := layActive.Position.X + 250;
          Position.Y := layActive.Position.Y;
        end;
      Other:
        begin
          Position := GetPosition(vPeople);
          listPeopleInTree.Add(vPeople);
        end;
    end;

    Padding.Top := 5;
    Padding.Bottom := 5;
    Padding.Left := 5;
    Padding.Right := 5;

    ShowHint := false;

  end;

  // Кнопка расширения дерева
  { if BS = 0 then
    begin
    tmpExpand := TCircle.Create(tmpLay);
    with tmpExpand do
    begin
    Parent := tmpLay;
    Position.X := 75 - 24;
    Position.Y := 200;
    Width := 48;
    Height := 48;
    ClipChildren := true;
    Stroke.Thickness := 6;
    Stroke.Color := TAlphaColors.Slategray;
    end;

    with TSpeedButton.Create(tmpExpand) do
    begin
    Parent := tmpExpand;
    Align := TAlignLayout.Client;

    if Ignore = 0 then
    StyleLookup := 'arrowuptoolbutton'
    else
    StyleLookup := 'arrowdowntoolbutton';

    Text := '+';
    Tag := ID;
    OnClick := btnExpand;
    end;

    end; }

  // Фон пола
  tmpSex := TRectangle.Create(tmpLay);
  with tmpSex do
  begin
    Parent := tmpLay;
    Align := TAlignLayout.Contents;
    Stroke.Kind := TBrushKind.None;
    XRadius := 10;
    YRadius := 10;
    Margins.Top := 5;
    Margins.Bottom := 5;
    Margins.Left := 10;
    Margins.Right := 10;
    if vPeople.sex = 'm' then
      Fill.Color := TAlphaColors.Skyblue
    else
      Fill.Color := TAlphaColors.Pink;
  end;

  // Тень
  with TShadowEffect.Create(tmpLay) do
  begin
    Parent := tmpLay;
  end;

  tmpBack := TRectangle.Create(tmpSex);
  with tmpBack do
  begin
    Parent := tmpSex;
    Align := TAlignLayout.Client;
    Stroke.Kind := TBrushKind.None;
    XRadius := 10;
    YRadius := 10;
    Margins.Top := 10;
    Fill.Color := TAlphaColors.Slategray;
    ClipChildren := true;
    Margins.Top := 10;

  end;

  if vPeople.is_dead = 1 then

    with TLine.Create(tmpBack) do
    begin
      Parent := tmpBack;
      Width := 80;
      Height := 80;

      RotationCenter.X := 0;
      RotationCenter.Y := 0;
      RotationAngle := 90;
      Stroke.Thickness := 20;
      Position.X := tmpBack.Width + 30;
      Position.Y := tmpBack.Height - 70;
      Opacity := 0.5;
    end;

  tmpCircle := TCircle.Create(tmpLay);
  with tmpCircle do
  begin
    Parent := tmpLay;
    Align := TAlignLayout.Client;
    Stroke.Thickness := 6;
    Stroke.Color := TAlphaColors.Slategray;

    Fill.Bitmap.Bitmap.Assign(vPeople.photo);
    if vPeople.photo_exist = 0 then
      if vPeople.sex = 'm' then
        Fill.Bitmap.Bitmap.Assign(MainForm.listNotPhoto.Source[0].MultiResBitmap[0].Bitmap)
      else
        Fill.Bitmap.Bitmap.Assign(MainForm.listNotPhoto.Source[1].MultiResBitmap[0].Bitmap);

    Margins.Bottom := 50;
    Fill.Kind := TBrushKind.Bitmap;
    Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  end;

  with TSpeedButton.Create(tmpCircle) do
  begin
    Parent := tmpCircle;
    Align := TAlignLayout.Client;
    StyleLookup := 'transparentcirclebuttonstyle';
    Tag := vPeople.child;
    Hint := vPeople.sex;
    ShowHint := false;
    { if parentObj = layPano then
      OnClick := btnPeopleSel; }
  end;

  tmpName := TLabel.Create(tmpBack);
  with tmpName do
  begin
    Parent := tmpBack;
    StyledSettings := [];
    Align := TAlignLayout.Bottom;
    Height := 50;
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.FontColor := TAlphaColors.White;
    TextSettings.Font.Family := 'Roboto';
    Font.Size := 10;
    Text := vPeople.name + #13 + vPeople.born + StrUtils.IfThen(vPeople.is_dead = 1, ' - ' + vPeople.dead);
  end;

end;

end.
