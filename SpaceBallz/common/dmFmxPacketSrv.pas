unit dmFmxPacketSrv;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections, Ics.Fmx.OverbyteIcsWndControl,System.IOUtils,
   Ics.Fmx.OverbyteIcsWSocket,Ics.Fmx.OverbyteIcsWSocketS,uPacketDefs,uSpaceBallzData;



 //our client class, each connection gets one..
type
  TPacketClient = class(TWSocketClient)
  public
    Buff        : array of byte; //buffer..
    Count:integer;//how much we've recvd
    ConnectTime : TDateTime;//when did we connect
    ClearToSend :boolean;//
    GoodHeader  :boolean;//did we get a good header
  end;

type
  TPacketData = class
    DataType:byte;
    Data:tBytes;
  end;

type
  TRecvPacket_Event  = procedure (Sender:TObject) of object;
  TDisplayLog_Event  = procedure (Sender:TObject) of object;




type
  TSrvCommsDM = class(TDataModule)
    srvSock: TWSocketServer;
    procedure srvSockClientCreate(Sender: TObject; Client: TWSocketClient);
    procedure srvSockClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure srvSockClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure srvSockDataAvailable(Sender: TObject; ErrCode: Word);
    procedure srvSockDataSent(Sender: TObject; ErrCode: Word);
    procedure ProcessData(Client : TPacketClient);
    procedure piRecvGamer(Client : TPacketClient);
    procedure piSendBadHash(Client : TPacketClient);
    procedure piSendGameDef(Client : TPacketClient);
    procedure piSendNop(Client : TPacketClient);
    procedure srvSockError(Sender: TObject);
    procedure srvSockException(Sender: TObject; SocExcept: ESocketException);
    procedure srvSockSocksError(Sender: TObject; Error: Integer; Msg: string);
    procedure srvSockBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    function  CheckPacketIdent(Const AIdent:TIdentArray):boolean;
    procedure LogMsg(const Msg: string);
    procedure PacketRecv;
    procedure SaveGameData;
    procedure LoadGameData;

  private
    { Private declarations }
    fRecvEvent:TRecvPacket_Event;
    fLogEvent:TDisplayLog_Event;
    fPacketQue:TQueue<tPacketData>;
    function  GetPacketCount:integer;
    procedure EmptyQ;

  public
    { Public declarations }
    GameData:tGameData;
    fLogList:TStringList;
    function  PopPacket:tPacketData;
    property  PacketCount:integer read GetPacketCount;
    property  OnRecvPacket:TRecvPacket_Event read fRecvEvent write fRecvEvent;
    property  OnDisplayLog:TDisplayLog_Event read fLogEvent write fLogEvent;
end;

var
  SrvCommsDM: TSrvCommsDM;
  LockDisplay : TCriticalSection;
  LockQ : TCriticalSection;


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses uGlobs,uEventLogging;

procedure TSrvCommsDM.DataModuleCreate(Sender: TObject);
begin
//
LockDisplay:=TCriticalSection.Create;
LockQ:=TCriticalSection.Create;
fLogList:=tStringList.Create;
fPacketQue:=TQueue<tPacketData>.Create;
GameData:=tGameData.Create;
srvSock.Proto:='tcp';
srvSock.Port:=ServerPort;
srvSock.Addr:=ServerIp;
srvSock.ClientClass:=tPacketClient;


end;

procedure TSrvCommsDM.DataModuleDestroy(Sender: TObject);
begin
//
EmptyQ;
fPacketQue.Free;
fLogList.Free;
LockDisplay.Free;
LockQ.Free;
GameData.Free;
srvSock.DisconnectAll;
srvSock.Close;


end;

procedure TSrvCommsDM.SaveGameData;
var
all:tEverything;
FileOfAll:TFileStream;
begin
  //save everything
  try
  FileOfAll:=TFileStream.Create(TPath.Combine(DataPath,'SpaceBallz.dat'),fmCreate);
  except on e:EFCreateError do exit;   //oops, we tried..
  end;
  all:=GameData.Give;
  FileOfAll.Write(all[0],Length(all));
  FileOfAll.Free;
  SetLength(all,0);
end;

procedure TSrvCommsDm.LoadGameData;
var
shit:tShit;
FileOfShit:TFileStream;
begin
  //load some shit
 try
  FileOfShit:=TFileStream.Create(TPath.Combine(DataPath,'SpaceBallz.dat'),fmOpenRead);
 except on e:EFOpenError do exit;   //shit, nothing to do but leave
 end;

 if FileOfShit.Size>0 then
  begin
   SetLength(shit,FileOfShit.Size);
   FileOfShit.Position:=0;
   FileOfShit.Read(shit[0],Length(shit));
    try
     GameData.Take(shit);
    finally
     FileOfShit.Free;
     SetLength(shit,0);
    end;
  end;
end;

//does it match our packet identifier
function TSrvCommsDM.CheckPacketIdent(Const AIdent:TIdentArray):boolean;
var
i:integer;
begin
   Result:=true;
     for I := Low(aIdent) to High(AIdent) do
       if AIdent[i]<>Ident_Packet[i] then result:=false;
end;




procedure TSrvCommsDM.srvSockBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
begin
//
        LogMsg('Socket background exception occured: ' + E.ClassName + ': ' + E.Message);
        CanClose := TRUE;   { Goodbye! }

end;

procedure TSrvCommsDM.srvSockClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
begin
//
    with Client as TPacketClient do begin
        LogMsg('Client connected.' +
                ' Remote: ' + PeerAddr + '/' + PeerPort +
                ' Local: '  + GetXAddr + '/' + GetXPort +
                'There is now ' +
                IntToStr(TWSocketServer(Sender).ClientCount) +
                ' clients connected.');

        Client.LineMode            := False;
        Client.LineEdit            := False;
        Client.BufSize             := Length(TPacketClient(Client).Buff);
        Client.OnDataAvailable     := srvSockDataAvailable;
        Client.OnBgException       := srvSockBgException;
        Client.OnDataSent          := srvSockDataSent;
        TPacketClient(Client).ConnectTime  := Now;

    end;


end;

procedure TSrvCommsDM.srvSockClientCreate(Sender: TObject; Client: TWSocketClient);
var
    Cli : TPacketClient;
begin
    Cli := Client as  TPacketClient;
    Cli.LineMode            := False;
    Cli.LineEdit            := False;
    SetLength(Cli.Buff,2000);//get a buffer of bytes
    Cli.BufSize             := Length(Cli.Buff);
    Cli.OnDataAvailable     := srvSockDataAvailable;
    Cli.OnBgException       := srvSockBgException;
    Cli.OnDataSent          := srvSockDataSent;
    Cli.ConnectTime         := Now;
    Cli.Count               :=0;
    Cli.ClearToSend         := true;
end;

procedure TSrvCommsDM.srvSockClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
var
    MyClient       : TPacketClient;
begin
    MyClient := Client as TPacketClient;

    LogMsg('Client disconnecting: ' + MyClient.PeerAddr + '   ' +
            'Duration: ' + FormatDateTime('hh:nn:ss',
            Now - MyClient.ConnectTime) + ' Error: ' + IntTostr(Error) +
            'There is now ' +
            IntToStr(TWSocketServer(Sender).ClientCount - 1) +
            ' clients connected.');
       SetLength(MyClient.Buff,0);//free buffer memory

end;

procedure TSrvCommsDM.srvSockDataAvailable(Sender: TObject; ErrCode: Word);
var
    Cli : TPacketClient;
    Len:integer;
    aPacketHdr:TPacketHdr;
begin
    Cli := Sender as TPacketClient;
    //recv bin data into our buffer..
    Len:=Cli.Receive(@Cli.Buff[Cli.Count],Length(Cli.Buff)-Cli.Count);

    //did we get some!!
    if Len <= 0 then
        Exit;

        //count it..
        Cli.Count:=Cli.Count +Len;
       //see if we got enough for a packet
     if Cli.Count>=SizeOf(TPacketHdr) then
        begin
        Move(Cli.Buff[0],aPacketHdr,SizeOf(aPacketHdr));
        if CheckPacketIdent(aPacketHdr.Ident) then
         begin
         Cli.GoodHeader:=true;
         LogMsg('Recvd Valid Header:DataSize='+IntToStr(aPacketHdr.DataSize));
          //packets can have extra data.. check for a datasize..
          if Cli.Count>=(aPacketHdr.DataSize+SizeOf(aPacketHdr)) then
           begin
            LogMsg('Received packet from ' + Cli.GetPeerAddr);
            ProcessData(Cli);
           end;
         end else
            begin
              Cli.GoodHeader:=false;
              LogMsg('Received bad header from '+Cli.GetPeerAddr);
              Cli.Count:=0;//start it all again
              FillChar(Cli.Buff[0],Length(Cli.Buff),#0);//zero the buffer
            end;
        end;

end;


procedure TSrvCommsDM.ProcessData(Client : TPacketClient);
var
aPacketHdr:TPacketHdr;
begin

        //copy our header out of buffer..
        Move(Client.Buff[0],aPacketHdr,SizeOf(aPacketHdr));
           //display header info.. :)
           LogMsg(' Command:'+IntToStr(aPacketHdr.Command)+
                   ' Expected:'+IntToStr(aPacketHdr.DataSize+SizeOf(aPacketHdr))+' Recv:'+IntToStr(Client.Count));

                //process command
                case aPacketHdr.Command of
                CMD_NOP:piSendNop(Client);//send just packet header command 0 to keep alive..
                CMD_GMR:piRecvGamer(Client);//extra data should be a gamer rec
                else
                     LogMsg('Unknowm Command.. ignoring packet');
                end;


        //always restart things..
        Client.Count:=0;//start it all again
        FillChar(Client.Buff[0],Length(Client.Buff),#0);//zero the buffer
end;


procedure TSrvCommsDM.piRecvGamer(Client: TPacketClient);
var
aPacket:tGamerPacket;
aGamer:tGamer;
aIndex:integer;
begin
  //

        Move(Client.Buff[0],aPacket,SizeOf(tGamerPacket));
        aGamer:=tGamer.Create;
        aGamer.Take(aPacket.gamer);
        aIndex:=GameData.FindGamer(aGamer.Nic);
        if aIndex = -1 then
          begin
          //not found add the gamer
          GameData.AddGamer(aGamer);
          piSendGameDef(Client);
          end
           else
             begin
              if GameData.CheckHash(aIndex,aGamer.Hash) then
                begin
                 if aGamer.BestScore>0 then
                  begin
                  GameData.UpdateGamer(aGamer.BestScore,aIndex);
                   if Assigned(fRecvEvent) then fRecvEvent(nil);

                  end;
                  piSendGameDef(Client);
                end else piSendBadHash(Client);

              aGamer.Free;
             end;
end;

procedure TSrvCommsDM.piSendBadHash(Client: TPacketClient);
var
aPacket:TPacketHdr;
begin
  //
  FillPacketIdent(aPacket.Ident);
  aPacket.Command:=CMD_ERR;
  aPacket.Option:=ERR_BADHASH;
  aPacket.DataSize:=0;
  Client.Send(@aPacket,SizeOf(tPacketHdr));
end;

procedure TSrvCommsDM.piSendGameDef(Client: TPacketClient);
var
aPacket:TGameDefinitionPacket;
gd:tGameDefinitionRec;
begin
   FillPacketIdent(aPacket.hdr.Ident);
   aPacket.hdr.Command:=CMD_DEF;
   aPacket.hdr.Option:=0;
   aPacket.hdr.DataSize:=SizeOf(tGameDefinitionRec);
   gd:=GameData.GameDef;
   Move(gd,aPacket.gameDef,SizeOf(tGameDefinitionRec));
   Client.Send(@aPacket,SizeOf(TGameDefinitionPacket));
end;

procedure TSrvCommsDM.piSendNop(Client: TPacketClient);
var
aPacket:TPacketHdr;
begin
  //
  FillPacketIdent(aPacket.Ident);
  aPacket.Command:=CMD_NOP;
  aPacket.Option:=0;
  aPacket.DataSize:=0;
  Client.Send(@aPacket,SizeOf(tPacketHdr));
end;


procedure TSrvCommsDM.srvSockDataSent(Sender: TObject; ErrCode: Word);
begin
//
end;

procedure TSrvCommsDM.srvSockError(Sender: TObject);
begin
 //
end;

procedure TSrvCommsDM.srvSockException(Sender: TObject; SocExcept: ESocketException);
begin
 //
end;

procedure TSrvCommsDM.srvSockSocksError(Sender: TObject; Error: Integer; Msg: string);
begin
//
end;


procedure TSrvCommsDM.PacketRecv;
begin
if assigned(fRecvEvent) then fRecvEvent(nil);
end;



//save debug messages into ouir tStringList..
procedure TSrvCommsDM.LogMsg(const Msg: string);
begin

  Logger.Log(Msg);

    LockDisplay.Enter;//one at a time boys..
    try
       //clear it if we need too..
       if fLogList.Count>100 then
           fLogList.Clear;
       FLogList.Add(Msg);//add the message
     finally
      LockDisplay.Leave;//get outta here..
    end;

  if assigned(fLogEvent) then fLogEvent(nil);


end;


function TSrvCommsDM.PopPacket:tPacketData;
begin
 result:=nil;
 LockQ.Enter;
 try
  if fPacketQue.Count>0 then
    result:=fPacketQue.Dequeue;
 finally
   LockQ.Leave;
 end;
end;

function TSrvCommsDM.GetPacketCount:integer;
begin
result:=-1;
 LockQ.Enter;
  try
    result:=fPacketQue.Count;
  finally
   LockQ.Leave;
  end;

end;

procedure TSrvCommsDM.EmptyQ;
var
i,j:integer;
aData:tPacketData;
begin
  LockQ.Enter;
  try
     J:=fPacketQue.Count-1;
    for I :=0 to J do
      begin
        aData:=fPacketQue.Dequeue;
        aData.Free;
      end;

  finally
   LockQ.Leave;
  end;
end;



end.
