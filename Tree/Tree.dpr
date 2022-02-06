program Tree;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {MainForm},
  uTreeFrame in 'uTreeFrame.pas' {TreeFrame: TFrame},
  uLibrary in 'uLibrary.pas',
  uAddChildFrame in 'uAddChildFrame.pas' {AddChildFrame: TFrame},
  uFrameAdd in 'uFrameAdd.pas' {FrameAdd: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
