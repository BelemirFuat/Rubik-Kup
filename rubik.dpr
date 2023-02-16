program rubik;

uses
  System.StartUpCopy,
  FMX.Forms,
  merkez in 'merkez.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
