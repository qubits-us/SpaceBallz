{Main Form for the SpaceBallz Tournament Server
 Windows TCP Packet Server using ICS

 Created 2.18.2022 -q


}
unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,System.UIConsts,System.IniFiles,System.IOUtils,
  IpHlpApi,IpTypes,Winapi.Windows, Winapi.Messages, //used by DiscoverMACIP
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs,FMX.Platform,uGlobs,uDlg3dCtrls,uSceneLeaderBoard;

type
  TMainFrm = class(TForm3D)
    procedure Form3DCreate(Sender: TObject);
    procedure Form3DClose(Sender: TObject; var Action: TCloseAction);
    procedure DoCloseApp(snder:tObject);
    procedure DiscoverMACIP;
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

uses dmMaterials,dmFMXPacketSrv,uSpaceBallzData;

//get our scale
function GetScreenScale: Single;var ScreenService: IFMXScreenService;
begin
  Result := 1;
  if TPlatformServices.Current.SupportsPlatformService (IFMXScreenService, IInterface(ScreenService)) then
    Result := ScreenService.GetScreenScale;
end;


procedure tMainFrm.DiscoverMACIP;
var
  pAdapterInfo, pTempAdapterInfo: PIP_ADAPTER_INFO;
  BufLen: DWORD;
  Status: DWORD;
  strMAC: String;
  i: Integer;
begin

  BufLen := SizeOf(IP_Adapter_Info);
  GetMem(pAdapterInfo, BufLen);
  try
    repeat
      Status := GetAdaptersInfo(pAdapterInfo, BufLen);
      if (Status = ERROR_SUCCESS) then
      begin
        if BufLen <> 0 then Break;
        Status := ERROR_NO_DATA;
      end;
      if (Status = ERROR_BUFFER_OVERFLOW) then
      begin
        ReallocMem(pAdapterInfo, BufLen);
      end else
      begin
        case Status of
          ERROR_NOT_SUPPORTED:
            ;
          ERROR_NO_DATA:
           ;
        else
           ;
        end;
        Exit;
      end;
    until False;

    pTempAdapterInfo := pAdapterInfo;
    while (pTempAdapterInfo <> nil) do
    begin
      strMAC := '';
      for I := 0 to pTempAdapterInfo^.AddressLength - 1 do
        strMAC := strMAC + '-' + IntToHex(pTempAdapterInfo^.Address[I], 2);
      Delete(strMAC, 1, 1);
      if pTempAdapterInfo^.IpAddressList.IpAddress.S<>'0.0.0.0' then
        begin
          ServerIp:=pTempAdapterInfo^.IpAddressList.IpAddress.S;
          ServerMAC:=StrMAC;
        end;
      pTempAdapterInfo := pTempAdapterInfo^.Next;
    end;
  finally
    FreeMem(pAdapterInfo);
  end;


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



  dlgMaterial.Free;
  dlgMaterial:=nil;

  MaterialsDm.Free;

  SrvCommsDm.SaveGameData;
  SrvCommsDm.Free;

  Tron.Free;

end;

procedure TMainFrm.Form3DCreate(Sender: TObject);
var
aGamer:tGamer;
aIni:TIniFile;
aIp:String;
begin
//in the beginning, there was only code..
   System.ReportMemoryLeaksOnShutdown:=true;//catch me if you can.. :P

   DiscoverMACIP;
   ServerPort:='9000';


DataPath:=TPath.GetHomePath;
DataPath:=TPath.Combine(DataPath,'SpaceBallzSrv');
if not TDirectory.Exists(DataPath,true) then
        tDirectory.CreateDirectory(DataPath);

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
   SrvCommsDm:=TSrvCommsDm.Create(self);
   SrvCommsDm.LoadGameData;
   SrvCommsDm.srvSock.Listen;


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
    //my 4k phone's res, but it's hdpi
    ClientWidth:=Trunc(Screen.Width / 2);
    ClientHeight:=Trunc(Screen.Height / 2);
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


    InitLeaderBoard;



end;


procedure tMainFrm.InitLeaderBoard;
var
  newx,newy:single;

 begin

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
