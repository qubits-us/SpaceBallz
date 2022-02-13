program SpaceBallz;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMain in 'frmMain.pas' {MainFrm},
  dmMaterials in 'dmMaterials.pas' {MaterialsDm: TDataModule},
  uGlobs in 'uGlobs.pas',
  uDlg3dCtrls in '..\3dBase\common\uDlg3dCtrls.pas',
  uDlg3dTextures in '..\3dBase\common\uDlg3dTextures.pas',
  uCommon3dDlgs in '..\3dBase\common\uCommon3dDlgs.pas',
  uInertiaTimer in '..\3dBase\common\uInertiaTimer.pas',
  uSpaceBallz in 'uSpaceBallz.pas',
  uNumPadDlg in '..\3dBase\common\uNumPadDlg.pas',
  uNumSelectDlg in '..\3dBase\common\uNumSelectDlg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape];
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
