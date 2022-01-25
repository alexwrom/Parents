unit uTreeFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uLibrary,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, Generics.Collections, Math,
  FMX.Edit, FMX.EditBox, FMX.SpinBox, Data.DB, System.ImageList, FMX.ImgList,
  FMX.ExtCtrls, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

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
    selRect: TRectangle;
    ShadowEffect1: TShadowEffect;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Layout1: TLayout;
    GridPanelLayout1: TGridPanelLayout;
    Layout3: TLayout;
    Circle1: TCircle;
    SpeedButton1: TSpeedButton;
    Layout4: TLayout;
    Circle2: TCircle;
    SpeedButton2: TSpeedButton;
    Layout5: TLayout;
    Circle3: TCircle;
    SpeedButton3: TSpeedButton;
    Layout6: TLayout;
    Circle4: TCircle;
    SpeedButton4: TSpeedButton;
    layBS: TLayout;
    procedure spGenerationChange(Sender: TObject);
    procedure btnIncZoomClick(Sender: TObject);
    procedure btnDecZoomClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure layPanoClick(Sender: TObject);
    procedure PanoClick(Sender: TObject);
  private
    Stack: TList<rChild>;
    firstChild: integer;
    procedure CreatePeople(parentObj: TFMXObject; ID: integer; childName, childSex: string; photo: TField; photoExist: integer; IsDead: integer; posParent, posChild: TPosition; BS: integer = 0);
    procedure GetChildParents(childID: integer);
    function GetPosChild(ID: integer; childSex: string): TPosition;
    procedure GetBrothersSisters(childID: integer);
    function GetPosition(ID: integer; childSex: string): TPosition;
    procedure btnPeopleSel(Sender: TObject);
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
  if layPano.Scale.X - 0.1 >= 0.1 then
  begin
    layPano.Scale.X := layPano.Scale.X - 0.1;
    layPano.Scale.Y := layPano.Scale.Y - 0.1;
  end;
end;

procedure TTreeFrame.btnIncZoomClick(Sender: TObject);
begin
  if layPano.Scale.X + 0.1 <= 1.5 then
  begin
    layPano.Scale.X := layPano.Scale.X + 0.1;
    layPano.Scale.Y := layPano.Scale.Y + 0.1;
  end;
end;

procedure TTreeFrame.btnPrintClick(Sender: TObject);
begin
  layPano.MakeScreenshot.SaveToFile(ExtractFilePath(paramstr(0)) + '\Screen.bmp');
end;

constructor TTreeFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Stack := TList<rChild>.Create;
  spGenerationChange(nil);
  Pano.ScrollTo(Pano.Width, Pano.Height);
  Pano.RecalcSize;

end;

procedure TTreeFrame.GetChildParents(childID: integer);
var
  tmpChild: rChild;
  posParent, posChild: TPosition;
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
          posParent := GetPosition(tmpChild.child, FieldByName('sex').AsString);
          posChild := GetPosChild(tmpChild.child, FieldByName('sex').AsString);
          if ((Round(posParent.Y) < Round(250 * spGeneration.Value)) and (posParent.Y > 0)) or (tmpChild.child = firstChild) then

            CreatePeople(layPano, tmpChild.child, FieldByName('name').AsString, FieldByName('sex').AsString, FieldByName('photo'), FieldByName('photoExist').AsInteger, FieldByName('IsDead').AsInteger, posParent, posChild);

        end;
      end;

    end;
  end;
end;

procedure TTreeFrame.GetBrothersSisters(childID: integer);
var
  tmpChild: rChild;
  i: integer;
  posParent, posChild: TPosition;
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
            posParent := GetPosition(tmpChild.child, FieldByName('sex').AsString);
            posParent.X := posParent.X + 170;
            posChild := GetPosChild(tmpChild.child, FieldByName('sex').AsString);
            CreatePeople(layPano, tmpChild.child, FieldByName('name').AsString, FieldByName('sex').AsString, FieldByName('photo'), FieldByName('photoExist').AsInteger, FieldByName('IsDead').AsInteger, posParent, posChild, i);
          end;
        end;
        inc(i);
        Next;
      end;
  end;
end;

procedure TTreeFrame.btnPeopleSel(Sender: TObject);
var
  i, k: integer;
  childID, childBS: integer;
  posChild: TPosition;
  posParent: TPosition;
begin

  childID := (Sender as TSpeedButton).Tag;
  if (childID = selRect.Tag) and selRect.Visible then
  begin
    selRect.Visible := false;
    selRect.Tag := 0;
  end
  else
  begin
    k := 0;
    for i := 0 to layBS.ControlsCount - 1 do
    begin

      if (layBS.Controls[k] is TLayout) then
      begin
        (layBS.Controls[k] as TLayout).Parent := nil;
      end
      else
        inc(k);

    end;

    for i := 0 to layPano.ChildrenCount - 1 do
      if layPano.Children[i] is TLayout then
      begin
        if (layPano.Children[i] as TLayout).Tag = childID then
        begin
          selRect.Tag := childID;

          // -----
          k := 1;
          ExeActive('select * from brothers_sisters where child_id = ' + childID.ToString + ' and bs <> ' + childID.ToString + ' order by born_year');

          if tmpQuery.RecordCount = 0 then
          begin
            selRect.Width := 210;
            selRect.Height := 70;
          end
          else
          begin
            if tmpQuery.RecordCount = 1 then
              selRect.Width := 210
            else
              selRect.Width := tmpQuery.RecordCount * 150;
            selRect.Height := 280;
          end;
          // Position
          selRect.Position.X := ABS((layPano.Children[i] as TLayout).Position.X + (layPano.Children[i] as TLayout).Width / 2 - selRect.Width / 2);
          selRect.Position.Y := (layPano.Children[i] as TLayout).Position.Y - selRect.Height;
          if selRect.Position.Y < 0 then
          begin
            selRect.Position.Y := (layPano.Children[i] as TLayout).Position.Y;
            selRect.Position.X :=  (layPano.Children[i] as TLayout).Position.X + (layPano.Children[i] as TLayout).Width;
          end;

          selRect.BringToFront;

          with tmpQuery do
            while NOT EOF do
            begin
              begin
                childBS := FieldByName('bs').AsInteger;
                posChild := TPosition.Create(TPointF.Create(0, 0));
                if tmpQuery.RecordCount = 1 then
                  posParent := TPosition.Create(TPointF.Create(30, 0))
                else
                  posParent := TPosition.Create(TPointF.Create((k - 1) * 150, 0));
                CreatePeople(layBS, childBS, FieldByName('name').AsString, FieldByName('sex').AsString, FieldByName('photo'), FieldByName('photoExist').AsInteger, FieldByName('IsDead').AsInteger, posParent, posChild, k);
              end;
              inc(k);
              Next;
            end;
          // -----
          selRect.Visible := true;
          break;
        end;
      end;
  end;

end;

procedure TTreeFrame.CreatePeople(parentObj: TFMXObject; ID: integer; childName, childSex: string; photo: TField; photoExist: integer; IsDead: integer; posParent, posChild: TPosition; BS: integer = 0);
var
  tmpLay: TLayout;
  tmpCircle: TCircle;
  tmpName: TLabel;
  tmpLine: TLine;

  ChildPosition: TPosition;
  tmpBack: TRectangle;
  tmpSex: TRectangle;
begin

  if (BS = 0) and (ID <> firstChild) then
  begin
    tmpLine := TLine.Create(layPano);
    with tmpLine do
    begin
      tmpLine.Parent := layPano;
      if childSex = 'm' then
      begin
        tmpLine.Width := 220;
        tmpLine.Height := ABS(posChild.X - posParent.X);
        RotationAngle := 90;
        RotationCenter.X := 0;
        RotationCenter.Y := 0;
        tmpLine.Position.X := posChild.X + 75;
        tmpLine.Position.Y := posChild.Y + 75;
      end
      else
      begin
        tmpLine.Width := ABS(GetPosChild(ID, childSex).X - posParent.X);
        tmpLine.Height := 220;
        tmpLine.Position.X := posChild.X + 75;
        tmpLine.Position.Y := posChild.Y + 75;
      end;
      tmpLine.Stroke.Color := TAlphaColors.White;
      tmpLine.Stroke.Thickness := 3;
      tmpLine.SendToBack;
      tmpLine.Visible := true;
    end;
  end;

  tmpLay := TLayout.Create(parentObj);
  with tmpLay do
  begin
    Parent := parentObj;
    Height := 200;
    Width := 150;
    Position := posParent;
    Padding.Top := 5;
    Padding.Bottom := 5;
    Padding.Left := 5;
    Padding.Right := 5;
    Tag := ID;
    Hint := childSex;
    ClipChildren := true;
    if layPano.Width < tmpLay.Position.Y + Width then
      layPano.Width := tmpLay.Position.Y + Width
    else
      layPano.Width := Power(2, spGeneration.Value - 1) * 150;
  end;

  tmpSex := TRectangle.Create(tmpLay);
  with tmpSex do
  begin
    Parent := tmpLay;
    Align := TAlignLayout.Contents;
    Stroke.Kind := TBrushKind.None;
    Margins.Top := 5;
    Margins.Bottom := 5;
    Margins.Left := 5;
    Margins.Right := 5;
    XRadius := 10;
    YRadius := 10;
    if childSex = 'm' then
      Fill.Color := TAlphaColors.Skyblue
    else
      Fill.Color := TAlphaColors.Pink;
  end;

  with TShadowEffect.Create(tmpSex) do
  begin
    Parent := tmpSex;
  end;

  tmpBack := TRectangle.Create(tmpLay);
  with tmpBack do
  begin
    Parent := tmpLay;
    Align := TAlignLayout.Client;
    Stroke.Kind := TBrushKind.None;
    XRadius := 10;
    YRadius := 10;
    Margins.Top := 10;
    Fill.Color := TAlphaColors.Slategray;
    Padding.Top := 5;
    Padding.Bottom := 5;
    Padding.Left := 5;
    Padding.Right := 5;
  end;

  if IsDead = 1 then

    with TLine.Create(tmpBack) do
    begin
      Parent := tmpBack;
      Width := 100;
      Height := 100;

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
    Stroke.Thickness := 3;
    Stroke.Color := TAlphaColors.Slategray;

    Fill.Bitmap.Bitmap.Assign(photo);
    if photoExist = 0 then
      if childSex = 'm' then
        Fill.Bitmap.Bitmap.Assign(listNotPhoto.Source[0].MultiResBitmap[0].Bitmap)
      else
        Fill.Bitmap.Bitmap.Assign(listNotPhoto.Source[1].MultiResBitmap[0].Bitmap);

    Margins.Bottom := 50;
    Fill.Kind := TBrushKind.Bitmap;
    Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  end;

  with TSpeedButton.Create(tmpCircle) do
  begin
    Parent := tmpCircle;
    Align := TAlignLayout.Client;
    StyleLookup := 'transparentcirclebuttonstyle';
    Tag := ID;
    if parentObj = layPano then
      OnClick := btnPeopleSel;
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
    Font.Size := Font.Size;
    Text := childName;
  end;

end;

function TTreeFrame.GetPosChild(ID: integer; childSex: string): TPosition;
var
  tmpPoint: TPosition;
  i: integer;
  childID: integer;
  maxWidth: double;
begin
  maxWidth := Power(2, spGeneration.Value - 1) * 150;
  tmpPoint := TPosition.Create(TPointF.Create(0, 0));
  for i := 0 to Stack.Count - 1 do
    if (Stack[i].father = ID) or (Stack[i].mother = ID) then
    begin
      childID := Stack[i].child;
      break;
    end;

  for i := 0 to layPano.ChildrenCount - 1 do
    if layPano.Children[i] is TLayout then
    begin
      if (layPano.Children[i] as TLayout).Tag = childID then
      begin

        tmpPoint.X := (layPano.Children[i] as TLayout).Position.X;
        tmpPoint.Y := (layPano.Children[i] as TLayout).Position.Y;
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
  maxWidth := Power(2, spGeneration.Value - 1) * 150;
  tmpPoint := GetPosChild(ID, childSex);
  if NOT((tmpPoint.X = 0) and (tmpPoint.Y = 0)) then
  begin
    tmpPoint.Y := tmpPoint.Y + (250);

    nextCount := Trunc(Power(2, spGeneration.Value - 1) / Power(2, (tmpPoint.Y / (250))) - 1);
    if childSex = 'm' then
      tmpPoint.X := tmpPoint.X - (75) - (maxWidth / Power(2, (tmpPoint.Y / (250))) - (150)) / 2
    else
      tmpPoint.X := tmpPoint.X + (75) + (maxWidth / Power(2, (tmpPoint.Y / (250))) - (150)) / 2;

  end
  else
    tmpPoint.X := tmpPoint.X + maxWidth / 2 - (75);
  result := tmpPoint;
end;

procedure TTreeFrame.layPanoClick(Sender: TObject);
begin
  selRect.Visible := false;
end;

procedure TTreeFrame.PanoClick(Sender: TObject);
begin
  selRect.Visible := false;
end;

procedure TTreeFrame.spGenerationChange(Sender: TObject);
var
  child: rChild;

  i, j, k: integer;
  maxPosY: Single;
  treeCount: integer;
  startChild: integer;
begin
  selRect.Visible := false;
  firstChild := 17;
  Stack.Clear;
  layPano.Width := Power(2, spGeneration.Value - 1) * 150;
  layPano.Height := spGeneration.Value * 250;

  k := -1;
  for i := 0 to layPano.ControlsCount - 1 do
  begin
    if k + 1 < layPano.ControlsCount then
    begin
      inc(k);
      if (layPano.Controls[k] is TLayout) then
      begin
        (layPano.Controls[k] as TLayout).Parent := nil;
        dec(k);
        Continue;
      end;

      if (layPano.Controls[k] is TLine) then
      begin
        (layPano.Controls[k] as TLine).Parent := nil;
        dec(k);
      end;
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
