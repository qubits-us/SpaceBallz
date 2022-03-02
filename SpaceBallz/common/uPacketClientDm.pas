{  Cross platform packet client demo
    compiled and tested on windows/android
  2.4.2022 -q
  www.qubits.us


  be it harm none, do as ye wish..

}
unit uPacketClientDm;

interface

uses
  System.SysUtils, System.Classes,uClientCommsObj,IdComponent,FMX.Types,uPacketDefs,
  FMX.Graphics,uSpaceBallzData;


type
  TComm_Event                 = procedure (Sender:TObject) of object;
  TCommsError_Event           = procedure (Sender:TObject; aMsg:String) of Object;
  TRecvGameDef_Event          = procedure (Sender:TObject) of object;
  THashError_Event            = procedure (Sender:TObject) of object;
  TNoEntries_Event            = procedure (Sender:TObject) of object;





type
  TPacketClientDm = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure CreateComms;
    procedure DestroyComms;
    procedure PacketSent(sender:TObject);
    procedure PacketRecv(sender:tObject);
    procedure ThreadErrorEvent(sender:TObject;const aMsg:String);
    procedure ThreadStatusEvent(sender:tObject;const aStatus:TidStatus);
    procedure PacketAvailable(Sender: TObject);
    procedure ProcessIncoming;
    procedure piRecvGameDef;
    procedure piRecvError;
    procedure ConnectGamer;
    procedure UpdateScore;

  private
    { Private declarations }
    fConnected:boolean;
    fConnectEvent:tComm_Event;
    fDisconnectEvent:tComm_Event;
    fRecvEvent:tComm_Event;
    fSendEvent:tComm_Event;
    fCommsError:TCommsError_Event;
    fRecvDef:TRecvGameDef_Event;
    fGameDef:TGameDefinitionRec;
    fGamer:TGamer;
    fHashErr:tHashError_Event;
    fNoEntries:tNoEntries_Event;
    fIP:String;
    fPort:integer;


  public
    { Public declarations }
   ClientComms:TClientComms;
   rcvBuff  :Array[0..10000] of byte;
   rcvCount:integer;

   property  OnConnect:TComm_Event read fConnectEvent write fConnectEvent;
   property  OnDisconnect:TComm_Event read fDisconnectEvent write fDisconnectEvent;
   property  OnCommError:TCommsError_Event read fCommsError write fCommsError;
   property  OnRecvPacket:TComm_Event read fRecvEvent write fRecvEvent;
   property  OnSendPacket:TComm_Event read fSendEvent write fSendEvent;
   property  OnRecvDef:TRecvGameDef_Event read fRecvDef write fRecvDef;
   property  OnHashError:THashError_Event read fHashErr write fHashErr;
   property  OnNoEntries:tNoEntries_Event read fNoEntries write fNoEntries;
   property  Connected:boolean read fConnected;
   property  GameDef:tGameDefinitionRec read fGameDef write fGameDef;
   property  Gamer:TGamer read fGamer write fGamer;
   property  Port:integer read fPort write fPort;
   property  IP:String read fIp write fIp;
  end;

var
  PacketCli: TPacketClientDm;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}



procedure TPacketClientDm.DataModuleCreate(Sender: TObject);
begin
//create
fConnected:=False;
fIP:='192.168.0.51';
fPort:=9000;
fGamer:=TGamer.Create;
fGamer.Nic:='astro';
fGamer.SmokeHash('SapceBallz');
end;

procedure TPacketClientDm.DataModuleDestroy(Sender: TObject);
begin
//destroy
if Assigned(ClientComms) then
begin
 try
  if ClientComms.Connected then
  ClientComms.Disconnect;
 finally
  ClientComms.Free;
 end;
end;

fGamer.Free;

end;

procedure TPacketClientDm.CreateComms;
begin
ClientComms:=tClientComms.Create;
ClientComms.Port:=fPort;
ClientComms.Host:=fIP;
ClientComms.ServerName:='SRV';
ClientComms.OnError:=ThreadErrorEvent;
ClientComms.OnPacketSent:=PacketSent;
ClientComms.OnPacketRecvd:=PacketRecv;
ClientComms.OnStatusChange:=ThreadStatusEvent;
end;

procedure TPacketClientDm.DestroyComms;
begin
if Assigned(ClientComms) then
begin
 try
  if ClientComms.Connected then
  ClientComms.Disconnect;
 finally
  ClientComms.Free

 end;

end;
end;

procedure TPacketClientDm.PacketSent(sender:TObject);
begin
  if Assigned(fSendEvent) then
     fSendEvent(nil);
end;
procedure TPacketClientDm.PacketRecv(sender:tObject);
begin

//process packet
  PacketAvailable(sender);
//notify
  if Assigned(fRecvEvent) then
         fRecvEvent(nil);

end;

procedure TPacketClientDm.ThreadErrorEvent(sender:TObject;const aMsg:String);
begin
    if Assigned(fCommsError) then
          fCommsError(sender,aMsg);
end;

procedure TPacketClientDm.ThreadStatusEvent(sender:tObject;const aStatus:TidStatus);
begin
  //
   if Ord(aStatus) = Ord(hsConnected) then
    begin
     fConnected:=true;
     if Assigned(fConnectEvent) then
         fConnectEvent(nil);
    end;

   if Ord(AStatus) = Ord(hsDisconnected) then
   begin
    //we are disconnected
    fConnected:=False;
   if Assigned(fDisconnectEvent) then
       fDisconnectEvent(nil);
   end;

end;

procedure TPacketClientDm.PacketAvailable(Sender: TObject);
  var
  aPacket:tPacketHdr;
  aBuff:pDataBuff;
begin

           aBuff:=ClientComms.PopPacket;

        if Assigned(aBuff) then
          begin
           //set recv byte count
           rcvCount:=aBuff^.BufferType;
           //move packet into old rec buffer
           Move(aBuff^.DataP[0],RcvBuff[0],Length(aBuff^.DataP));
          end else RcvCount:=0;

       if Assigned(aBuff) then
         begin
           SetLength(aBuff^.DataP,0);
           Dispose(aBuff);//free this, done with it..
          end;

       //see if we got enough for a packet
     if rcvCount>=SizeOf(TPacketHdr) then
        begin
        Move(rcvBuff[0],aPacket,SizeOf(aPacket));
          if CheckPacketIdent(tIdentArray(aPacket.Ident)) then
           begin
              //packets can have extra data.. check for a datasize..
             if rcvCount>=(aPacket.DataSize+SizeOf(aPacket)) then
                begin
                 ProcessIncoming;
                 rcvCount:=0;//reset our count
                 FillChar(rcvBuff,SizeOf(rcvBuff),#0);//reset buffer..
                end;
           end else
              begin
                //invalid header!!
                rcvcount:=0;
                FillChar(rcvBuff,SizeOf(rcvBuff),#0);//reset buffer..
              end;
        end;
end;

procedure TPacketClientDm.ProcessIncoming;
  //process incoming packet
var
  aPacket:tPacketHdr;

begin

     if RcvCount>=SizeOf(TPacketHdr) then
        begin
        Move(rcvBuff,aPacket,SizeOf(aPacket));
          //packets can have extra data.. check for a datasize..
        if RcvCount>=(aPacket.DataSize+SizeOf(aPacket)) then
          begin
            case aPacket.Command of
            CMD_NOP:;
            CMD_DEF:piRecvGameDef;
            CMD_ERR:piRecvError;
            end;
          end;
        end;
end;

//receive a game definition
procedure TPacketClientDm.piRecvGameDef;
var
offset:integer;
begin
  offset:=SizeOf(tPacketHdr);
  Move(rcvBuff[offset],fGameDef,SizeOf(TGameDefinitionRec));
  if Assigned(fRecvDef) then fRecvDef(nil);


end;

//receive error
procedure TPacketClientDm.piRecvError;
var
aPacket:tPacketHdr;
err:byte;
begin
  //error
    Move(rcvBuff,aPacket,SizeOf(tPacketHdr));
     err:=aPacket.Option;
      case err of
      ERR_BADHASH:if assigned(fHashErr) then fHashErr(nil);
      ERR_ENTRIES:if assigned(fNoEntries) then fNoEntries(nil);
      end;

end;

procedure TPacketClientDm.ConnectGamer;
var
aPacket:tGamerPacket;
aRec:tGamerRec;
aBuff:pDataBuff;
begin
  //
    FillPacketIdent(aPacket.hdr.Ident);
    aPacket.hdr.Command:=CMD_GMR;
    aPacket.hdr.Option:=0;
    aPacket.hdr.DataSize:=SizeOf(tGamerRec);
    fGamer.BestScore:=0;
    aRec:=fGamer.Shit;
    Move(aRec,aPacket.gamer,SizeOf(tGamerRec));
    New(aBuff);
    aBuff^.BufferType:=0;
    SetLength(aBuff^.DataP,SizeOf(tGamerPacket));
    Move(aPacket,aBuff^.DataP[0],SizeOf(tGamerPacket));
    ClientComms.PushPacket(aBuff);
end;

procedure TPacketClientDm.UpdateScore;
var
aPacket:tGamerPacket;
aRec:tGamerRec;
aBuff:pDataBuff;
begin
  //
    FillPacketIdent(aPacket.hdr.Ident);
    aPacket.hdr.Command:=CMD_GMR;
    aPacket.hdr.Option:=0;
    aPacket.hdr.DataSize:=SizeOf(tGamerRec);
    aRec:=fGamer.Shit;
    Move(aRec,aPacket.gamer,SizeOf(tGamerRec));
    New(aBuff);
    aBuff^.BufferType:=0;
    SetLength(aBuff^.DataP,SizeOf(tGamerPacket));
    Move(aPacket,aBuff^.DataP[0],SizeOf(tGamerPacket));
    ClientComms.PushPacket(aBuff);

end;



end.
