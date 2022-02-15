unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, IoUtils, uTreeFrame, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.UI, FMX.TabControl, System.ImageList, FMX.ImgList,
  FMX.Controls.Presentation, FMX.StdCtrls, uAddChildFrame, uFrameAdd;

type
  TMainForm = class(TForm)
    Conn: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    controlMain: TTabControl;
    tabTree: TTabItem;
    tabAdd: TTabItem;
    listNotPhoto: TImageList;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    TreeFrame: TTreeFrame;
    addFrame: TFrameAdd;
    AddChildFrame: TAddChildFrame;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin

  Conn.Connected := false;

{$IFDEF ANDROID}
  Conn.Params.Values['Database'] := IoUtils.TPath.Combine(IoUtils.TPath.GetDocumentsPath, 'base.db');
  self.FullScreen := true;
{$ELSE}
  Conn.Params.Database := ExtractFilePath(paramstr(0)) + '\base.db';

{$ENDIF}
  try
    Conn.Connected := true;
  except
    ShowMessage('');
  end;

  TreeFrame := TTreeFrame.Create(nil);
  TreeFrame.Parent := tabTree;
end;

end.