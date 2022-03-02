program SpaceBallzSrvr;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMain in 'frmMain.pas' {MainFrm},
  dmFmxPacketSrv in '..\common\dmFmxPacketSrv.pas' {SrvCommsDM: TDataModule},
  uPacketDefs in '..\common\uPacketDefs.pas',
  uSceneLeaderBoard in 'uSceneLeaderBoard.pas',
  uDlg3dCtrls in '..\..\3dBase\common\uDlg3dCtrls.pas',
  uCommon3dDlgs in '..\..\3dBase\common\uCommon3dDlgs.pas',
  uDlg3dTextures in '..\..\3dBase\common\uDlg3dTextures.pas',
  uInertiaTimer in '..\..\3dBase\common\uInertiaTimer.pas',
  dmMaterials in 'dmMaterials.pas' {MaterialsDm: TDataModule},
  uGlobs in 'uGlobs.pas',
  uNumSelectDlg in '..\..\3dBase\common\uNumSelectDlg.pas',
  uConfigDlg in 'uConfigDlg.pas',
  uNumPadDlg in '..\..\3dBase\common\uNumPadDlg.pas',
  uSpaceBallzData in '..\common\uSpaceBallzData.pas',
  uEventLogging in '..\common\uEventLogging.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
