program Parents;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {MainForm},
  uTreeFrame in 'uTreeFrame.pas' {TreeFrame: TFrame},
  uLibrary in 'uLibrary.pas',
  uAddChildFrame in 'uAddChildFrame.pas' {AddChildFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
