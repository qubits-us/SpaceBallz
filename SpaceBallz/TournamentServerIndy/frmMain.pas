{Main Form for the SpaceBallz Tournament Server
 Android TCP Packet Server using Indy

 Created 3.15.2022 -q


}
unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,System.UIConsts,System.IniFiles,System.IOUtils,
  IdStack,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics, FMX.TextLayout.GPU,
  FMX.Dialogs,FMX.Platform,uGlobs,uDlg3dCtrls,uSceneLeaderBoard, System.Math.Vectors, FMX.Controls3D, FMX.Layers3D
   {$IFDEF ANDROID},FMX.Platform.Android{$ENDIF};

type
  TMainFrm = class(TForm3D)
    im: TImage3D;
    procedure Form3DCreate(Sender: TObject);
    procedure Form3DClose(Sender: TObject; var Action: TCloseAction);
    procedure DoCloseApp(snder:tObject);
private
    { Private declarations }
  public
    { Public declarations }
    procedure InitLeaderBoard;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.fmx}

uses dmMaterials,uSpaceBallzData,uEventLogging,uIndySBPacketServer,uDroidScreenLock;

//get our scale
function GetScreenScale: Single;var ScreenService: IFMXScreenService;
begin
  Result := 1;
  if TPlatformServices.Current.SupportsPlatformService (IFMXScreenService, IInterface(ScreenService)) then
    Result := ScreenService.GetScreenScale;
end;


procedure WiggleHandle;
begin
{$IF RTLVersion111}
TGPUObjectsPool.Instance.Free;
{$ENDIF}
end;





procedure TMainFrm.Form3DClose(Sender: TObject; var Action: TCloseAction);
var
aIni:TIniFile;
begin
 if assigned(LeaderBoard) then
   begin
     LeaderBoard.StopAni;
     LeaderBoard.CleanUp;
     LeaderBoard.Free;
   end;

aini:=TIniFile.Create(TPath.Combine(DataPath,'SpaceBallz.ini'));
aIni.WriteString('SpaceBallz','Version','1.0');
aIni.WriteString('Server','Port',ServerPort);
aIni.WriteBool('General','FullScreen',GoFullScreen);
aIni.Free;


//Logger.Log('Shutting down..');
//Logger.Free;

  dlgMaterial.Free;
  dlgMaterial:=nil;

  MaterialsDm.Free;

  PacketSrv.Stop;
  PacketSrv.SaveGameData(DataPath);
  PacketSrv.Free;

  Tron.Free;
   {$IFDEF ANDROID}
   try
    ReleaseWakeLock;
    finally
    MainActivity.Finish;
    end;
    {$ENDIF}


  {$IFDEF MSWINDOWS}
    WiggleHandle;
  {$ENDIF}


end;

procedure TMainFrm.Form3DCreate(Sender: TObject);
var
aGamer:tGamer;
aIni:TIniFile;
aIp:String;
ls:tLogSettings;
begin
//in the beginning, there was only code..
   System.ReportMemoryLeaksOnShutdown:=true;//catch me if you can.. :P

   ServerPort:='9000';


DataPath:=TPath.GetHomePath;
DataPath:=TPath.Combine(DataPath,'SpaceBallzSrv');
if not TDirectory.Exists(DataPath,true) then
        tDirectory.CreateDirectory(DataPath);

//Logger:=tEventLogger.Create;
ls.LogPath:=DataPath;
ls.LoggingLevel:=10;
ls.FlushInterval:=100;
//Logger.Initialize(ls);


//Logger.Log('SpaceBallz Server Starting up..',50);
aini:=TIniFile.Create(TPath.Combine(DataPath,'SpaceBallz.ini'));
aIni.WriteString('SpaceBallz','Version','1.0');
//allow for overriding detected ip..
aIP:=aIni.ReadString('Server','IP','');
if aIP<>'' then
ServerIP:=aIP;
ServerPort:=aIni.ReadString('Server','Port','9000');

GoFullScreen:=aIni.ReadBool('General','FullScreen',False);
aIni.Free;


   MaterialsDm:=TMaterialsDm.Create(self);//pics

PacketSrv:=tPacketServer.Create;
PacketSrv.LoadGameData(DataPath);
PacketSrv.Port:=StrToInt(ServerPort);

//Windows - use GStack.LocalAddress seems to give correct ip..
{$IFDEF MSWINDOWS}
PacketSrv.IP:=GStack.LocalAddress;
ServerIp:=PacketSrv.IP;
{$ENDIF}
//Android - GStack doesn't give us what we want..
// pulling ip out of wifimanager when aquiring the multicast lock..
{$IFDEF ANDROID}
ServerIp:=PacketSrv.IP;
GoFullScreen:=true;
{$ENDIF}

PacketSrv.Start;


//Logger.Log('Server is listening..',50);

   DlgMaterial:=tDlgMaterial.Create(self);//holds pics

  DlgUp:=False;
  Tron:=TTron.Create;//cleans up after me..

  CurrentTheme:=3;//Aurora -my fave.. :)


      //everybody scales!!
      CurrentScale:=GetScreenScale;

     {Berlin gotta ya!!
       don't trunc and replace / with div
       those are ints, d11 singles}


   if not GoFullScreen then
    begin
    ClientWidth:=Trunc(Screen.Width-(Screen.Width / 2));//the first of many divisions..
    ClientHeight:=Trunc(Screen.Height-(Screen.Height / 2));
    Left:=50;
    Top:=10;
    BorderStyle:=TFmxFormBorderStyle.ToolWindow;
    Caption:='SpaceBallz Tournament Server - www.qubits.us';
     {Berlin gotta ya!!
       don't trunc and replace / with div
       those are ints, d11 singles}
    Left:=Trunc((Screen.Width/2)-(ClientWidth/2));
    Top:=Trunc((Screen.Height/2)-(ClientHeight/2));

    end else
       begin
       Caption:='';
       Width:=Trunc(Screen.Width);
       Height:=Trunc(Screen.Height);
       ClientWidth:=Trunc(Screen.Width);
       ClientHeight:=Trunc(Screen.Height);
       Left:=0;
       Top:=0;
       BorderStyle:=TFmxFormBorderStyle.None;
       FullScreen:=true;
       end;


   {$IFDEF MSWINDOWS}
    InitLeaderBoard;
    {$ENDIF}

   {$IFDEF ANDROID}
    AcquireWakeLock;
    StartUpTmr.Enabled:=true;
    {$ENDIF}


end;


procedure tMainFrm.InitLeaderBoard;
var
  newx,newy:single;

 begin

   im.Visible:=false;
   DlgMaterial.GreenTxt.Color:=claGreen;
   DlgMaterial.RedTxt.Color:=claRed;

   MaterialsDm.LoadTheme;

   newx:=(MainFrm.ClientWidth/2);
   newy:=(MainFrm.ClientHeight/2);
   LeaderBoard:=TDlgLeaderBoard.Create(MainFrm,DlgMaterial,MainFrm.ClientWidth,MainFrm.ClientHeight,newx,newy);
   LeaderBoard.Parent:=MainFrm;
   LeaderBoard.OnClose:=DoCloseApp;
   LeaderBoard.AniType:=2;
   LeaderBoard.StartAni;

 end;

procedure tMainFrm.DoCloseApp(snder: TObject);
begin
    Close;
end;

end.
