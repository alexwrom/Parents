unit uTreeFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uLibrary,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, Generics.Collections, Math,
  FMX.Edit, FMX.EditBox, FMX.SpinBox;

type
  rChild = record
    child: integer;
    father: integer;
    mother: integer;
  end;

  TTreeFrame = class(TFrame)
    Pano: TScrollBox;
    Image: TImage;
    Layout1: TLayout;
    Layout2: TLayout;
    spGeneration: TSpinBox;
    procedure spGenerationChange(Sender: TObject);
  private
    Stack: TList<rChild>;
    firstChild: integer;
    procedure CreatePeople(childID: integer; childName, childSex: string; isStart: boolean = false);
    procedure GetChildParents(childID: integer);
    function GetPosChild(ID: integer; childSex: string): TPosition;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);
  end;

implementation

uses uMain;
{$R *.fmx}
{ TTreeFrame }

constructor TTreeFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Stack := TList<rChild>.Create;
  spGenerationChange(nil);
end;

procedure TTreeFrame.GetChildParents(childID: integer);
var
  tmpChild: rChild;
begin
  if childID > 0 then
  begin
    ExeActive('select father_id, mother_id, name,sex from tree where child_id = ' + childID.ToString);
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
          CreatePeople(childID, FieldByName('name').AsString, FieldByName('sex').AsString, true);
        end;
      end;

    end;
  end;
end;

procedure TTreeFrame.CreatePeople(childID: integer; childName, childSex: string; isStart: boolean = false);
var
  tmpLay: TLayout;
  tmpCircle: TCircle;
  tmpRect: TCalloutRectangle;
  tmpName: TLabel;
  posChildY: double;
begin
  posChildY := GetPosChild(childID, childSex).Y;
  if ((posChildY < 170 * spGeneration.Value) and (posChildY > 0)) or (childID = firstChild) then
  begin
    tmpLay := TLayout.Create(Pano);
    with tmpLay do
    begin
      Parent := Pano;
      Height := 150;
      Width := 150;
      Position := GetPosChild(childID, childSex);
      Tag := childID;
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
    end;

    tmpRect := TCalloutRectangle.Create(tmpLay);
    with tmpRect do
    begin
      Parent := tmpLay;
      Align := TAlignLayout.Bottom;
      Stroke.Kind := TBrushKind.None;
      if childSex = 'm' then
        Fill.Color := TAlphaColors.Skyblue
      else
        Fill.Color := TAlphaColors.Pink;
    end;

    tmpName := TLabel.Create(Pano);
    with tmpName do
    begin
      Parent := tmpRect;
      Align := TAlignLayout.Client;
      TextSettings.HorzAlign := TTextAlign.Center;
      Text := childName;
    end;
  end;
end;

function TTreeFrame.GetPosChild(ID: integer; childSex: string): TPosition;
var
  tmpPoint: TPosition;
  i: integer;
  childID: integer;
  Sex: string;
  maxWidth: double;
  nextCount: integer;
begin
  maxWidth := Power(2, spGeneration.Value - 1) * 150;
  tmpPoint := TPosition.Create(TPointF.Create(0, 0));

  for i := 0 to Stack.Count - 1 do
    if (Stack[i].father = ID) or (Stack[i].mother = ID) then
    begin
      childID := Stack[i].child;
      break;
    end;

  for i := 0 to Pano.Content.ChildrenCount - 1 do
    if Pano.Content.Children[i] is TLayout then
    begin
      if (Pano.Content.Children[i] as TLayout).Tag = childID then
      begin

        tmpPoint.X := (Pano.Content.Children[i] as TLayout).Position.X;
        tmpPoint.Y := (Pano.Content.Children[i] as TLayout).Position.Y + 170;

        nextCount := Trunc(Power(2, spGeneration.Value - 1) / Power(2, (tmpPoint.Y / 170)) - 1);
        if childSex = 'm' then
          tmpPoint.X := tmpPoint.X - 75 - (maxWidth - nextCount * 75 - Power(2, (tmpPoint.Y / 170)) * 150) / Power(2, (tmpPoint.Y / 170))
        else
          tmpPoint.X := tmpPoint.X + 75 + (maxWidth - nextCount * 75 - Power(2, (tmpPoint.Y / 170)) * 150) / Power(2, (tmpPoint.Y / 170));

        { with Layout1.Canvas do
          begin
          BeginScene();
          Fill.Color := TAlphaColors.Black;
          //DrawLine(TPointF.Create(tmpPoint.X + 75, tmpPoint.Y),TPointF.Create((Pano.Content.Children[i] as TLayout).Position.X + 75, (Pano.Content.Children[i] as TLayout).Position.Y + 150),1);
          DrawLine(TPointF.Create(0,0),TPointF.Create(2, 2),1);
          EndScene;
          end; }
      end;
    end;

  result := tmpPoint;
end;

procedure TTreeFrame.spGenerationChange(Sender: TObject);
var
  child: rChild;

  i, j, k: integer;
  maxPosY: Single;
  treeCount: integer;
begin

  firstChild := 17;
  Stack.Clear;

  k := -1;
  for i := 0 to Pano.Content.ChildrenCount - 1 do
  begin
    inc(k);
    if (Pano.Content.Children[k] is TLayout) then
    begin
      (Pano.Content.Children[k] as TLayout).Visible := false;
      (Pano.Content.Children[k] as TLayout).Parent := nil;
      dec(k);
    end;

  end;

  i := 0;
  GetChildParents(firstChild);
  while (i < Stack.Count) do
  begin
    firstChild := Stack[i].child;
    if firstChild > 0 then
    begin
      GetChildParents(firstChild);
      if Stack[i].father > 0 then
        GetChildParents(Stack[i].father);
      if Stack[i].mother > 0 then
        GetChildParents(Stack[i].mother);
    end;
    inc(i);

  end;
end;

end.
