{ Packet Definitions and helpers..
  2.2.2022- q

  be it harm none, do as ye wish..

}

unit uPacketDefs;

interface
uses
  System.SysUtils, System.Classes, System.SyncObjs,System.Generics.Collections,uSpaceBallzData;


const
//Packet Ident - SpaceBallz
Ident_Packet :array[0..9] of byte =(83,112,97,99,101,66,97,108,108,122);
//max items in the q before we start dropping
MAX_QUES=101;

//Command bytes
CMD_NOP=0;//no opertation
CMD_GMR=1;//gamer
CMD_DEF=2;//game definition
CMD_ERR=3;//error no in option byte

ERR_BADHASH=1;//bad hash recv
ERR_ENTRIES=2;//no entries left

//used in game definition
MAX_BALLS=12;
MAX_SPEED=12;
MAX_LEVELS=12;





//type used in helper function
type
 TIdentArray = array[0..9] of byte;

    //udp discovery packets broadcast from server..
  type
     pDiscoveryPacket=^tDiscoveryPacket;
     tDiscoveryPacket =packed record
       PacketIdent:TIdentArray;
       ServerName :array[0..25] of byte;
       ServerIp   :array[0..13] of byte;
       ServerPort :array[0..13] of byte;
     end;


//packet header, preceeds all packets..
type
 pPacketHdr=^tPacketHdr;
 tPacketHdr= packed record
  Ident:TIdentArray;//10 bytes
  Command:byte;//1 byte
  Option:byte;//1 byte
  DataSize:integer;//4 bytes -addional data size after header and not including header..
end;


type
  tGamerPacket = packed record
     hdr:tPacketHdr;
     gamer:tGamerRec;
  end;


type
  tGameDefinitionPacket = packed record
    hdr:tPacketHdr;
    gameDef:tGameDefinitionRec;
  end;



function  CheckPacketIdent(Const AIdent:TIdentArray):boolean;
procedure FillPacketIdent(var aIdent:tIdentArray);
function SwapBytes(Value: Cardinal): Cardinal;





implementation


//does it match our packet identifier
function CheckPacketIdent(Const AIdent:TIdentArray):boolean;
var
i:integer;
begin
   Result:=true;
     for I := Low(AIdent) to High(AIdent) do
       if AIdent[i]<>Ident_Packet[i] then result:=false;
end;
//fill our identifier
procedure FillPacketIdent(var aIdent:TIdentArray);
var
i:integer;
begin
     for I := Low(aIdent) to High(aIdent) do
        aIdent[i]:=Ident_Packet[i];

end;


function SwapBytes(Value: Cardinal): Cardinal;
type
  Bytes = packed array[0..3] of Byte;

begin
  Bytes(Result)[0]:= Bytes(Value)[3];
  Bytes(Result)[1]:= Bytes(Value)[2];
  Bytes(Result)[2]:= Bytes(Value)[1];
  Bytes(Result)[3]:= Bytes(Value)[0];
end;



end.
