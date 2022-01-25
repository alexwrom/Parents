unit uTreeFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uLibrary,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, Generics.Collections, Math,
  FMX.Edit, FMX.EditBox, FMX.SpinBox, Data.DB, System.ImageList, FMX.ImgList,
  FMX.ExtCtrls;

type
  rChild = record
    child: integer;
    father: integer;
    mother: integer;
  end;

  TTreeFrame = class(TFrame)
    Pano: TScrollBox;
    Layout2: TLayout;
    spGeneration: TSpinBox;
    listNotPhoto: TImageList;
    btnIncZoom: TSpeedButton;
    btnDecZoom: TSpeedButton;
    btnPrint: TSpeedButton;
    layPano: TLayout;
    procedure spGenerationChange(Sender: TObject);
    procedure btnIncZoomClick(Sender: TObject);
    procedure btnDecZoomClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    Stack: TList<rChild>;
    firstChild: integer;
    cScale: double;
    parentName: TLayout;
    procedure CreatePeople(ID: integer; childName, childSex: string; photo: TField; photoExist: integer; BS: integer = 0);
    procedure GetChildParents(childID: integer);
    function GetPosChild(ID: integer; childSex: string): TPosition;
    procedure GetBrothersSisters(childID: integer);
    function GetPosition(ID: integer; childSex: string): TPosition;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);
  end;

implementation

uses uMain;
{$R *.fmx}
{ TTreeFrame }

procedure TTreeFrame.btnDecZoomClick(Sender: TObject);
begin
  if cScale - 0.1 >= 0.1 then
  begin
    cScale := cScale - 0.1;
    spGenerationChange(nil);
  end;
end;

procedure TTreeFrame.btnIncZoomClick(Sender: TObject);
begin
  if cScale + 0.1 <= 1.5 then
  begin
    cScale := cScale + 0.1;
    spGenerationChange(nil);
  end;
end;

procedure TTreeFrame.btnPrintClick(Sender: TObject);
begin
  layPano.MakeScreenshot.SaveToFile(ExtractFilePath(paramstr(0)) + '\Screen.bmp');
end;

constructor TTreeFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  parentName := layPano;
  cScale := 1;
  Stack := TList<rChild>.Create;
  spGenerationChange(nil);
  Pano.ScrollTo(Pano.Width, Pano.Height);
  Pano.RecalcSize;

end;

procedure TTreeFrame.GetChildParents(childID: integer);
var
  tmpChild: rChild;
begin
  if childID > 0 then
  begin
    ExeActive('select * from tree_data where child_id = ' + childID.ToString);
    with tmpQuery do
    begin
      if RecordCount > 0 then
      begin
        tmpChild.child := childID;
        if FieldByName('father_id').AsInteger > 0 then
          tmpChild.father := FieldByName('father_id').AsInteger
        else
          tmpChild.father := 0;

        if FieldByName('mother_id').AsInteger > 0 then
          tmpChild.mother := FieldByName('mother_id').AsInteger
        else
          tmpChild.mother := 0;

        if Stack.IndexOf(tmpChild) < 0 then
        begin
          Stack.Add(tmpChild);
          CreatePeople(tmpChild.child, FieldByName('name').AsString, FieldByName('sex').AsString, FieldByName('photo'), FieldByName('photoExist').AsInteger);
        end;
      end;

    end;
  end;
end;

procedure TTreeFrame.GetBrothersSisters(childID: integer);
var
  tmpChild: rChild;
  i: integer;
begin
  if childID > 0 then
  begin
    i := 1;
    ExeActive('select * from brothers_sisters where child_id = ' + childID.ToString + ' and bs <> ' + childID.ToString);
    with tmpQuery do
      while NOT EOF do
      begin
        begin
          tmpChild.child := FieldByName('bs').AsInteger;

          if Stack.IndexOf(tmpChild) < 0 then
          begin
            Stack.Add(tmpChild);
            CreatePeople(tmpChild.child, FieldByName('name').AsString, FieldByName('sex').AsString, FieldByName('photo'), FieldByName('photoExist').AsInteger, i);
          end;
        end;
        inc(i);
        Next;
      end;
  end;
end;

procedure TTreeFrame.CreatePeople(ID: integer; childName, childSex: string; photo: TField; photoExist: integer; BS: integer = 0);
var
  tmpLay: TLayout;
  tmpCircle: TCircle;
  tmpRect: TCalloutRectangle;
  tmpName: TLabel;
  tmpLine: TLine;
  posParent: TPosition;
  ChildPosition: TPosition;

begin

  posParent := GetPosition(ID, childSex);
  posParent.X := posParent.X + 170 * BS * cScale;
  if ((Round(posParent.Y) < Round(170 * spGeneration.Value * cScale)) and (posParent.Y > 0)) or (ID = firstChild) or (BS > 0) then
  begin
    if (BS = 0) and (ID <> firstChild) then
    begin
      tmpLine := TLine.Create(parentName);
      with tmpLine do
      begin
        tmpLine.Parent := parentName;
        if childSex = 'm' then
        begin
          tmpLine.Width := 170 * cScale;
          tmpLine.Height := Abs(GetPosChild(ID, childSex).X - posParent.X);
          RotationAngle := 90;
          RotationCenter.X := 0;
          RotationCenter.Y := 0;
          tmpLine.Position.X := GetPosChild(ID, childSex).X + 75 * cScale;
          tmpLine.Position.Y := GetPosChild(ID, childSex).Y + 75 * cScale;
        end
        else
        begin
          tmpLine.Width := Abs(GetPosChild(ID, childSex).X - posParent.X);
          tmpLine.Height := 170 * cScale;
          tmpLine.Position.X := GetPosChild(ID, childSex).X + 75 * cScale;
          tmpLine.Position.Y := GetPosChild(ID, childSex).Y + 75 * cScale;
        end;
        tmpLine.Stroke.Color := TAlphaColors.White;
        tmpLine.Stroke.Thickness := 3;
        tmpLine.SendToBack;
        tmpLine.Visible := true;
      end;
    end;

    tmpLay := TLayout.Create(parentName);
    with tmpLay do
    begin
      Parent := parentName;
      Height := 150 * cScale;
      Width := 150 * cScale;
      Position := posParent;
      Tag := ID;
      Hint := childSex;
      tmpLay.Visible := true;
    end;

    tmpCircle := TCircle.Create(tmpLay);
    with tmpCircle do
    begin
      Parent := tmpLay;
      Align := TAlignLayout.Client;
      Stroke.Thickness := 2;
      Stroke.Color := TAlphaColors.Slategray;

      Fill.Bitmap.Bitmap.Assign(photo);
      if photoExist = 0 then
        if childSex = 'm' then
          Fill.Bitmap.Bitmap.Assign(listNotPhoto.Source[0].MultiResBitmap[0].Bitmap)
        else
          Fill.Bitmap.Bitmap.Assign(listNotPhoto.Source[1].MultiResBitmap[0].Bitmap);

      Fill.Kind := TBrushKind.Bitmap;
      Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
    end;

    tmpRect := TCalloutRectangle.Create(tmpLay);
    with tmpRect do
    begin
      Parent := tmpLay;
      Align := TAlignLayout.Bottom;
      Stroke.Kind := TBrushKind.None;
      Height := Height * cScale;
      Padding.Top := 10 * cScale;
      CalloutWidth := CalloutWidth * cScale;
      CalloutLength :=  CalloutLength * cScale;
      if childSex = 'm' then
        Fill.Color := TAlphaColors.Skyblue
      else
        Fill.Color := TAlphaColors.Pink;
    end;

    tmpName := TLabel.Create(parentName);
    with tmpName do
    begin
      Parent := tmpRect;
      Align := TAlignLayout.Client;
      TextSettings.HorzAlign := TTextAlign.Center;
      StyledSettings := [];
      Font.Size := Font.Size * cScale;
      Text := childName;
    end;
  end;
end;

function TTreeFrame.GetPosChild(ID: integer; childSex: string): TPosition;
var
  tmpPoint: TPosition;
  i: integer;
  childID: integer;
  maxWidth: double;
begin
  maxWidth := Power(2, spGeneration.Value - 1) * 150 * cScale;
  tmpPoint := TPosition.Create(TPointF.Create(0, 0));
  for i := 0 to Stack.Count - 1 do
    if (Stack[i].father = ID) or (Stack[i].mother = ID) then
    begin
      childID := Stack[i].child;
      break;
    end;

  for i := 0 to parentName.ChildrenCount - 1 do
    if parentName.Children[i] is TLayout then
    begin
      if (parentName.Children[i] as TLayout).Tag = childID then
      begin

        tmpPoint.X := (parentName.Children[i] as TLayout).Position.X;
        tmpPoint.Y := (parentName.Children[i] as TLayout).Position.Y;
        break;
      end;
    end;

  result := tmpPoint;
end;

function TTreeFrame.GetPosition(ID: integer; childSex: string): TPosition;
var
  tmpPoint: TPosition;
  maxWidth: double;
  nextCount: integer;
begin
  maxWidth := Power(2, spGeneration.Value - 1) * 150 * cScale;
  tmpPoint := GetPosChild(ID, childSex);
  if NOT((tmpPoint.X = 0) and (tmpPoint.Y = 0)) then
  begin
    tmpPoint.Y := tmpPoint.Y + (170 * cScale);

    nextCount := Trunc(Power(2, spGeneration.Value - 1) / Power(2, (tmpPoint.Y / (170 * cScale))) - 1);
    if childSex = 'm' then
      tmpPoint.X := tmpPoint.X - (75 * cScale) - (maxWidth / Power(2, (tmpPoint.Y / (170 * cScale))) - (150 * cScale)) / 2
    else
      tmpPoint.X := tmpPoint.X + (75 * cScale) + (maxWidth / Power(2, (tmpPoint.Y / (170 * cScale))) - (150 * cScale)) / 2;

  end
  else
    tmpPoint.X := tmpPoint.X + maxWidth / 2 - (75 * cScale);
  result := tmpPoint;
end;

procedure TTreeFrame.spGenerationChange(Sender: TObject);
var
  child: rChild;

  i, j, k: integer;
  maxPosY: Single;
  treeCount: integer;
  startChild: integer;
begin

  firstChild := 17;
  Stack.Clear;
  layPano.Width := Power(2, spGeneration.Value - 1) * 150 * cScale;
  layPano.Height := spGeneration.Value * 170 *cScale;

  k := -1;
  for i := 0 to parentName.ControlsCount - 1 do
  begin
    inc(k);
    if (parentName.Controls[k] is TLayout) then
    begin
      (parentName.Controls[k] as TLayout).Visible := false;
      (parentName.Controls[k] as TLayout).Parent := nil;
      dec(k);
      Continue;
    end;

    if (parentName.Controls[k] is TLine) then
    begin
      (parentName.Controls[k] as TLine).Visible := false;
      (parentName.Controls[k] as TLine).Parent := nil;
      dec(k);
    end;

  end;

  i := 0;
  GetChildParents(firstChild);
  GetBrothersSisters(firstChild);
  startChild := firstChild;
  while (i < Stack.Count) do
  begin
    startChild := Stack[i].child;
    if startChild > 0 then
    begin
      GetChildParents(startChild);
      if Stack[i].father > 0 then
        GetChildParents(Stack[i].father);
      if Stack[i].mother > 0 then
        GetChildParents(Stack[i].mother);
    end;

    inc(i);

  end;

  Pano.ScrollTo(Pano.Width, Pano.Height);

end;

end.
