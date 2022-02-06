unit uLibrary;

interface

uses FireDAC.Comp.Client, FMX.Graphics;

type
  tTypePeople = (Active,Child,BrS,Other,Married);

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
  end;

  // ----------------------------------Constants-----------------------------------------
const
   ttEdit = 0;
   ttNewChild = 1;
   ttNewBS = 2;
   ttNewParent = 3;

var
  tmpQuery: TFDQuery;
  // -------------------------------------- Procedures ----------------------------------
procedure ExeSQL(SQL: string);
procedure ExeActive(SQL: string);
procedure MyFreeAndNil(Obj : TObject);

implementation

uses uMain;

procedure ExeActive(SQL: string);

begin
  if tmpQuery = nil then
  begin
    tmpQuery := TFDQuery.Create(nil);
    tmpQuery.Connection := MainForm.Conn;
  end;
  tmpQuery.Active := false;
  tmpQuery.SQL.clear;
  tmpQuery.SQL.Add(SQL);
  tmpQuery.Active := true;
end;

procedure ExeSQL(SQL: string);
var
  tmpQuery: TFDQuery;
begin
  tmpQuery := TFDQuery.Create(nil);
  tmpQuery.Connection := MainForm.Conn;
  tmpQuery.SQL.clear;
  tmpQuery.SQL.Add(SQL);
  tmpQuery.ExecSQL;
  tmpQuery.Free;
end;

procedure MyFreeAndNil(Obj : TObject);
begin
  Pointer(Obj) := nil;
{$IFDEF WINDOWS}
  Obj.Free;
{$ELSE IF}
  Obj.DisposeOf;
{$ENDIF}
end;

end.
