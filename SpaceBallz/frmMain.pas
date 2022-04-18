{Main Form for SpaceBallz - A Delphi Game

Created 2.13.2022 -q

be it harm none, do as ye wish.


}

unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs,FMX.MaterialSources,FMX.Objects,FMX.Layers3D,FMX.Objects3D,FMX.TextLayout.GPU,
  System.UIConsts,dmMaterials,System.SyncObjs, System.Math.Vectors,System.IniFiles,System.IOUtils,
  FMX.Controls3D,FMX.Platform{$IFDEF ANDROID},FMX.Platform.Android{$ENDIF},
  uDlg3dCtrls,uSpaceBallz,uDlg3dTextures,uGlobs;

type
  TMainFrm = class(TForm3D)
    im: TImage3D;
    procedure Form3DCreate(Sender: TObject);
    procedure InitSpaceBallz;
    procedure DoCloseApp(sender: TObject);
    procedure FormTouch(Sender: TObject; const Touches: TTouches; const Action: TTouchAction);
    function  HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    procedure Form3DClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;
  LeftPaddleY,RightPaddleY:single;

implementation

{$R *.fmx}

uses
  uPacketClientDm,uGameSound;


procedure WiggleHandle;
begin
{$IF RTLVersion111}
TGPUObjectsPool.Instance.Free;
{$ENDIF}
end;



//get our scale
function GetScreenScale: Single;var ScreenService: IFMXScreenService;
begin
  Result := 1;
  if TPlatformServices.Current.SupportsPlatformService (IFMXScreenService, IInterface(ScreenService)) then
    Result := ScreenService.GetScreenScale;
end;



function TMainFrm.HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  case AAppEvent of
    //TApplicationEvent.FinishedLaunching: Log('Finished Launching');
    TApplicationEvent.BecameActive:
     begin

       if Assigned(SpaceBallz) then
        begin
          SpaceBallz.PauseGame(false);
        end;
     end;
    //TApplicationEvent.WillBecomeInactive: Log('Will Become Inactive');
    TApplicationEvent.EnteredBackground:
     begin
       if Assigned(SpaceBallz) then
        begin
          SpaceBallz.PauseGame(true);
        end;
     end;
    //TApplicationEvent.WillBecomeForeground: Log('Will Become Foreground');
    //TApplicationEvent.WillTerminate: Log('Will Terminate');
    //TApplicationEvent.LowMemory: Log('Low Memory');
    //TApplicationEvent.TimeChange: Log('Time Change');
    //TApplicationEvent.OpenURL: Log('Open URL');
  end;
  Result := True;
end;




//handle two fingers, moving two paddles..
procedure TMainfrm.FormTouch(Sender: TObject; const Touches: TTouches; const Action: TTouchAction);
var
i:integer;
lY,rY,aBorder:single;
begin
   lY:=0;
   rY:=0;
   aBorder:=(Height/12)-2;
    for I := Low(Touches) to High(Touches) do
      begin
        if Touches[I].Location.X<(Width/8) then
        lY:=Touches[I].Location.Y else
        if Touches[I].Location.X>(Width-(Width/8)) then
        rY:=Touches[I].Location.Y;
      end;

     if ((lY-((Height/2)-aBorder))<>LeftPaddleY) or ((rY-((Height/2)-aBorder))<>RightPaddleY) then
       begin
         if (LeftPaddleY<>lY-((Height/2)-aBorder)) and (lY<>0) then
         LeftPaddleY:=lY-((Height/2)-aBorder);
         if (RightPaddleY<>rY-((Height/2)-aBorder)) AND (rY<>0) then
         RightPaddleY:=rY-((Height/2)-aBorder);
         if Assigned(SpaceBallz) then
            SpaceBallz.MovePaddles(LeftPaddleY,RightPaddleY);
       end;


end;


procedure TMainFrm.Form3DClose(Sender: TObject; var Action: TCloseAction);
var
aIni:TInifile;
begin
//all done
  if Assigned(SpaceBallz) then SpaceBallz.Free;

  dlgMaterial.Free;
  dlgMaterial:=nil;

  MaterialsDm.Free;


    GameSound.Free;

  PacketCli.Free;

  Tron.Free;

//save connection settings..
aini:=TIniFile.Create(TPath.Combine(DataPath,'SpaceBallz.ini'));
aIni.WriteString('Server','IP',SrvIP);
aIni.WriteString('Server','Port',SrvPort);
aIni.WriteString('Server','Nic',GamerNic);
aIni.WriteString('Server','Hash',GamerHash);
aIni.Free;





  {$IFDEF ANDROID}
  MainActivity.finish;
  {$ENDIF}


  {$IFDEF MSWINDOWS}
    WiggleHandle;
  {$ENDIF}




end;

procedure TMainFrm.Form3DCreate(Sender: TObject);
var
aIni:TIniFile;
FMXApplicationEventService: IFMXApplicationEventService;
begin

//in the beginning, there was only code..
   System.ReportMemoryLeaksOnShutdown:=true;//catch me if you can.. :P

   MaterialsDm:=TMaterialsDm.Create(self);//pics

   DlgMaterial:=tDlgMaterial.Create(self);//holds pics

   PacketCli:=tPacketClientDM.Create(self);

{$IFDEF ANDROID}
//location of sound file for robots
SoundPath:=tPath.GetDocumentsPath;
{$ENDIF}

{$IFDEF MSWINDOWS}
SoundPath:=ExtractFilePath(ParamStr(0));
{$ENDIF}


DataPath:=TPath.GetHomePath;
DataPath:=TPath.Combine(DataPath,'SpaceBallz');
if not TDirectory.Exists(DataPath,true) then
        tDirectory.CreateDirectory(DataPath);

aini:=TIniFile.Create(TPath.Combine(DataPath,'SpaceBallz.ini'));
aIni.WriteString('SpaceBallz','Version','1.0');
SrvIP:=aIni.ReadString('Server','IP','192.168.0.51');
SrvPort:=aIni.ReadString('Server','Port','9000');
GamerNic:=aIni.ReadString('Server','Nic','astro');
GamerHash:=aIni.ReadString('Server','Hash','');
aIni.Free;

 PacketCli.Gamer.Nic:=GamerNic;
 if GamerHash='' then
   begin
      GamerHash:='SpaceBallz';
      PacketCli.Gamer.SmokeHash(GamerHash);
      GamerHash:=PacketCli.Gamer.Hash;
   end else PacketCli.Gamer.Hash:=GamerHash;
 PacketCli.Port:=StrToInt(SrvPort);
 PacketCli.IP:=SrvIP;




   //hook up our touch event
   OnTouch:=FormTouch;

  SpaceBallz:=nil;
  DlgUp:=False;
  Tron:=TTron.Create;//cleans up after me..

  CurrentTheme:=3;//Aurora -my fave.. :)


      //everybody scales!!
      CurrentScale:=GetScreenScale;

  GameSound:=tGameSound.Create;
  //load sound effects
  if TFile.Exists(TPath.Combine(SoundPath,'womp.wav')) then
    GameSound.Add(TPath.Combine(SoundPath,'womp.wav'),'womp');
  if TFile.Exists(TPath.Combine(SoundPath,'womp2.wav')) then
    GameSound.Add(TPath.Combine(SoundPath,'womp2.wav'),'womp2');
  if TFile.Exists(TPath.Combine(SoundPath,'warning_horn.wav')) then
    GameSound.Add(TPath.Combine(SoundPath,'warning_horn.wav'),'warning');
  if TFile.Exists(TPath.Combine(SoundPath,'cannon_x.wav')) then
    GameSound.Add(TPath.Combine(SoundPath,'cannon_x.wav'),'cannon');
  if TFile.Exists(TPath.Combine(SoundPath,'buzzer_x.wav')) then
    GameSound.Add(TPath.Combine(SoundPath,'buzzer_x.wav'),'buzzer');
   //load background music
  if TFile.Exists(TPath.Combine(SoundPath,'music.mp3')) then
    GameSound.MusicFile:=TPath.Combine(SoundPath,'music.mp3');


     {Berlin gotta ya!!
       don't trunc and replace / with div
       those are ints, d11 singles}

    ClientWidth:=Trunc(Screen.Width-(Screen.Width / 2));//the first of many divisions..
    ClientHeight:=Trunc(Screen.Height-(Screen.Height / 2));
    Left:=50;
    Top:=10;

 if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(FMXApplicationEventService)) then
    FMXApplicationEventService.SetApplicationEventHandler(HandleAppEvent);


 {$IFDEF ANDROID} //robots
       GoFullScreen:=true;
       Caption:='';
       Width:=Trunc(Screen.Width);
       Height:=Trunc(Screen.Height);
       ClientWidth:=Trunc(Screen.Width);
       ClientHeight:=Trunc(Screen.Height);
       im.Width:=Width;
       im.Height:=Height;
       Left:=0;
       Top:=0;
       BorderStyle:=TFmxFormBorderStyle.None;
       FullScreen:=true;
       StartUpTmr.Enabled:=true;
       //wait 5 secs.. screen will be ready..
 {$ENDIF}

  {$IFDEF MSWINDOWS}  //windows
    GoFullScreen:=false;
    BorderStyle:=TFmxFormBorderStyle.ToolWindow;
    Caption:='SpaceBallz - www.qubits.us';
    //my 4k phone's res, but it's hdpi
//    ClientWidth:=916;
//    ClientHeight:=411;
    ClientWidth:=1280;
    ClientHeight:=800;
     {Berlin gotta ya!!
       don't trunc and replace / with div
       those are ints, d11 singles}
    Left:=Trunc((Screen.Width/2)-(ClientWidth/2));
    Top:=Trunc((Screen.Height/2)-(ClientHeight/2));
    InitSpaceBallz;
 {$ENDIF}





end;

procedure TMainFrm.InitSpaceBallz;
var
  newx,newy:single;

 begin
   //lift off..

   im.Visible:=false;

   DlgMaterial.GreenTxt.Color:=claGreen;
   DlgMaterial.RedTxt.Color:=claRed;

   MaterialsDm.LoadTheme;

   newx:=(MainFrm.ClientWidth/2);
   newy:=(MainFrm.ClientHeight/2);
   SpaceBallz:=TSpaceBallz.Create(MainFrm,MainFrm.ClientWidth,MainFrm.ClientHeight,newx,newy);
   SpaceBallz.Parent:=MainFrm;
   SpaceBallz.OnClose:=DoCloseApp;

 end;

procedure TMainFrm.DoCloseApp(sender: TObject);
 begin
   Close;
 end;



end.
