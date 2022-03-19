unit uConnectDlg;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, System.Math.Vectors, FMX.Ani, FMX.Controls3D,FMX.Layers3d,
  FMX.MaterialSources, FMX.Objects3D, FMX.Effects, FMX.Filter.Effects,
  uDlg3dCtrls,uDlg3dTextures,uIPChangeDlg,uNumPadDlg,uKeyboardDlg;



  type
     tConnectDlg= class(TDummy)
       private
       //priv
       fDlgUp:boolean;
       fIP:String;
       fPort:integer;
       fnic:string;
       fpass:string;
       fConnected:boolean;
       fConnecting:boolean;
       fBtnIP:tDlgInputButton;
       fBtnPort:tDlgInputButton;
       fBtnNic:tDlgInputButton;
       fBtnHash:tDlgInputButton;
       fBtnConnect:tDlgButton;
       fBtnCancel:tDlgButton;
       fIm:TImage3d;
       fMat:TDlgMaterial;
       fDoneEvent:TDlgClick_Event;
       fCancelEvent:tDlgClick_Event;
       fIPNumPad:TDlgIPNumPad;
       fNumPad:TDlgNumPad;
       fCleanedUp:Boolean;
       protected
       //prots
       procedure IPClick(sender:tObject);
       procedure IPDone(Sender:TObject);
       procedure IPCancel(sender:tObject);
       procedure NicClick(sender:tobject);
       procedure NicDone(sender:tObject);
       procedure HashClick(sender:tobject);
       procedure HashDone(sender:tObject);

       procedure ConnectClick(sender:tObject);
       procedure OnConnect(sender:tObject);
       procedure OnBadHash(senrder:tObject);
       procedure ClearError(sender:tObject);
       procedure OnRecvGameDef(sender:tObject);
       procedure DoCancelClick(sender:tObject);
       procedure DoDone(sender:tObject);
       procedure SetPort(aPort:integer);
       procedure SetIP(aIP:string);
       procedure PortDone(sender:Tobject;aExitType:integer);
       procedure GetPort(sender:tObject);
       public
       //pubs
       constructor Create(aOwner:TComponent;aMat:TDlgMaterial;
                    aWidth,aHeight,aX,aY:single); reintroduce;
       destructor  Destroy;override;
       procedure   CleanUp;
       procedure  SetConnecting;
       procedure OnError(sender:tObject;aMsg:String);

       property BackIm:TImage3d read fim write fim;
       property Port:integer read fPort write SetPort;
       property IP:string read  fIP write SetIP;
       property OnDone:TDlgClick_Event read fDoneEvent write fDoneEvent;
       property OnCancel:TDlgClick_Event read fCancelEvent write fCancelEvent;
     end;




implementation

uses uGlobs,dmMaterials,uPacketClientDM;

Constructor tConnectDlg.Create(aOwner: TComponent; aMat: TDlgMaterial;
                aWidth: Single; aHeight: Single; aX: Single; aY: Single);
var
i:integer;
newx,newy:single;
aButtonHeight,aButtonWidth,aParamWidth:single;
aColGap,aRowGap:single;
SectionHeight:single;
ah,af,ap:single;
tmpBitmap:tBitmap;
begin
inherited Create(aOwner);
fCleanedUp:=false;
//create things
  //set our cam first always!!!
  Projection:=TProjection.Screen;

 // fCurrentMenu:=0;//default to 1st menu

  fMat:=aMat;
  fDlgUp:=False;
  fConnecting:=False;
  fConnected:=false;

  //set w,h and pos
  Width:=(aWidth);
  Height:=(aHeight);
  Position.X:=(aX);
  Position.Y:=(aY);
  Depth:=1;
  Opacity:=0.95;

  tmpBitmap:=MakeDlgBackGrnd(Width+22,Height+20,0,0,10);

  fIm:=TImage3d.Create(self);
  fIm.Projection:=tProjection.Screen;
  fIm.Bitmap.Assign(tmpBitmap);
  tmpBitmap.Free;
  fIm.Width:=aWidth+22;
  fIm.Height:=aHeight+20;
  fIm.HitTest:=false;
  fIm.Position.X:=0;//aWidth/2;
  fIm.Position.Y:=0;//aHeight/2;
  fIm.Position.Z:=0;
  fIm.Parent:=self;
  fIm.Opacity:=0.85;

  fIPNumPad:=nil;
  fNumPad:=nil;

   fip:=SrvIP;
   fnic:=GamerNic;
   fpass:=GamerHash;
   fPort:=StrToInt(SrvPort);


  if Width>600 then
  SectionHeight:=80 else
  SectionHeight:=50;

  aColGap:=2;
  aRowGap:=2;
  aButtonWidth:=aWidth-aColGap;//divide width by max keys in a row
  aParamWidth:=(aButtonWidth/2);

  fMat.FontSize:=32;

  ah:=Height / 4;// devide height by number of rows..
  SectionHeight:=ah;
  SectionHeight:=(SectionHeight-aRowGap);

if SectionHeight>(aButtonWidth+aColGap) then
   begin
     ah:=SectionHeight-(aButtonWidth+aColGap);
     SectionHeight:=(SectionHeight-(ah/2));
   end;


//change font size..
  if SectionHeight>70 then
    begin
     fMat.FontSize:=32;
    end else
    begin
      fMat.FontSize:=24;
    end;

  if SectionHeight>100 then
     begin
     fMat.FontSize:=36;
     end;



  newy:=(((aHeight/2)*-1)+(SectionHeight/2));//top
  newx:=(((aWidth/2)*-1)+((aButtonWidth/1.5)/2));//left

      fBtnIP:=tDlgInputButton.Create(self,aButtonwidth/1.5,SectionHeight,newx,newy);
      fBtnIP.Projection:=TProjection.Screen;
      fBtnIP.Parent:=self;
      fBtnIp.Position.Z:=-2;
      fBtnIP.Opacity:=0.95;
      fBtnIP.MaterialSource:=fMat.Large.Rect;
      fBtnIP.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnIP.LabelColor:=fMat.Buttons.TextColor.Color;
      fBtnIP.FontSize:=fMat.FontSize;
      fBtnIP.LabelSize:=fMat.FontSize/1.5;
      fBtnIP.BtnBitMap.Assign(fMat.Large.Rect.Texture);
      fBtnIP.Text:=fIp;
      fBtnIP.LabelText:='Server IP';
      fBtnIP.OnClick:=IPClick;//btnClick;
      newx:=newx+(aButtonWidth/1.5)+aColGap-((aButtonwidth-(aButtonwidth/1.5))/2);

      fBtnPort:=tDlgInputButton.Create(self,aButtonwidth-(aButtonwidth/1.5),SectionHeight,newx,newy);
      fBtnPort.Projection:=TProjection.Screen;
      fBtnPort.Parent:=self;
      fBtnPort.Position.Z:=-2;
      fBtnPort.Opacity:=0.95;
      fBtnPort.MaterialSource:=fMat.Large.Rect;
      fBtnPort.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnPort.LabelColor:=fMat.Buttons.TextColor.Color;
      fBtnPort.FontSize:=fMat.FontSize;
      fBtnPort.LabelSize:=fMat.FontSize/1.5;
      fBtnPort.BtnBitMap.Assign(fMat.Large.Rect.Texture);
      fBtnPort.Text:=IntToStr(fPort);
      fBtnPort.LabelText:='Port';
      fBtnPort.OnClick:=GetPort;



      //new line
      newy:=newy+SectionHeight+aRowGap;
     newx:=(((aWidth/2)*-1)+(aButtonWidth/2));//left


      fBtnNic:=tDlgInputButton.Create(self,aButtonwidth,SectionHeight,newx,newy);
      fBtnNic.Projection:=TProjection.Screen;
      fBtnNic.Parent:=self;
      fBtnNic.Position.Z:=-2;
      fBtnNic.Opacity:=0.95;
      fBtnNic.MaterialSource:=fMat.Large.Rect;
      fBtnNic.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnNic.LabelColor:=fMat.Buttons.TextColor.Color;
      fBtnNic.FontSize:=fMat.FontSize;
      fBtnNic.LabelSize:=fMat.FontSize/1.5;
      fBtnNic.BtnBitMap.Assign(fMat.Large.Rect.Texture);
      fBtnNic.Text:=fNic;
      fBtnNic.LabelText:='Nic';
      fBtnNic.OnClick:=NicClick;
      newy:=newy+SectionHeight+aRowGap;

      fBtnHash:=tDlgInputButton.Create(self,aButtonwidth,SectionHeight,newx,newy);
      fBtnHash.Projection:=TProjection.Screen;
      fBtnHash.Parent:=self;
      fBtnHash.Position.Z:=-2;
      fBtnHash.Opacity:=0.95;
      fBtnHash.MaterialSource:=fMat.Large.Rect;
      fBtnHash.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnHash.LabelColor:=fMat.Buttons.TextColor.Color;
      fBtnHash.FontSize:=fMat.FontSize;
      fBtnHash.LabelSize:=fMat.FontSize/1.5;
      fBtnHash.BtnBitMap.Assign(fMat.Large.Rect.Texture);
      fBtnHash.Text:='********';
      fBtnHash.LabelText:='Password';
      fBtnHash.OnClick:=HashClick;




     //now the bottom
      newy:=newy+SectionHeight+aRowGap;// NL
      newx:=(((aWidth/2)*-1)+(aParamWidth/2)); //left
     fBtnConnect:=TDlgButton.Create(self,aParamWidth,SectionHeight,newx,newy);
     fBtnConnect.Projection:=tProjection.Screen;
     fBtnConnect.Parent:=self;
     fBtnConnect.Position.Z:=-2;
     fBtnConnect.Opacity:=0.95;
     fBtnConnect.MaterialSource:=fMat.Buttons.Rect;
      fBtnConnect.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnConnect.FontSize:=fMat.FontSize;
      fBtnConnect.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
      fBtnConnect.Text:='Connect';
     fBtnConnect.OnClick:=ConnectClick;//

     Newx:=Newx+(aParamWidth)+(aColGap);
     fBtnCancel:=TDlgButton.Create(self,aParamWidth,SectionHeight,newx,newy);
     fBtnCancel.Projection:=tProjection.Screen;
     fBtnCancel.Parent:=self;
     fBtnCancel.Position.Z:=-2;
     fBtnCancel.Opacity:=0.95;
     fBtnCancel.MaterialSource:=fMat.Buttons.Rect;
      fBtnCancel.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnCancel.FontSize:=fMat.FontSize;
      fBtnCancel.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
      fBtnCancel.Text:='Cancel';
     fBtnCancel.OnClick:=DoCancelClick;//


      fIpNumPad:=nil;
      fNumPad:=nil;

 if not assigned(PacketCli.ClientComms) then
   PacketCli.CreateComms;



end;

Destructor tConnectDlg.Destroy;
var
i:integer;
begin

 if not fCleanedUp then CleanUp;


inherited;
end;

procedure tConnectDlg.CleanUp;
var
i:integer;
begin
//clean house
if fCleanedUp then Exit;



fBtnConnect.CleanUp;
fBtnConnect.Free;
fBtnConnect:=nil;

fBtnCancel.CleanUp;
fBtnCancel.Free;
fBtnCancel:=nil;

fBtnPort.CleanUp;
fBtnPort.Free;
fBtnPort:=nil;

fBtnNic.CleanUp;
fBtnNic.Free;
fBtnNic:=nil;

fBtnHash.CleanUp;
fBtnHash.Free;
fBtnHash:=nil;


fBtnIp.CleanUp;
fbtnIP.Free;
fBtnIp:=nil;

fIm.Free;

if assigned(fIpNumPad) then
 begin
 fIpNumPad.CleanUp;
 fIpNumPad.Free;
 fIpNumPad:=nil;
 end;

if assigned(fNumPad) then
 begin
 fNumPad.CleanUp;
 fNumPad.Free;
 fNumPad:=nil;
 end;


fMat:=nil;
Parent:=nil;

 fCleanedUp:=true;

end;

procedure tConnectDlg.SetConnecting;
begin
  fConnecting:=true;
  fBtnConnect.Text:='Connecting...';
  fBtnConnect.Repaint;
end;



procedure tConnectDlg.IPClick(sender: TObject);
begin
  if fDlgUp then exit;
  if fConnecting then exit;


     if not assigned(fIPNumPad) then
        begin
          //creae a keyboard here
          fIPNumPad:=tDlgIPNumPad.Create(self,fmat,Width,height,0,0);
        end;
          fIPNumPad.IP:=fIp;
          fIPNumPad.OnDone:=IPDone;
          fIpNumPad.OnCancel:=IpCancel;
          fIPNumPad.Parent:=self.Parent;
         // fIPNumPad.BackIm.Parent:=self.Parent;
          fIPNumPad.Position.Z:=-4;
          fIPNumPad.Visible:=true;
          fIpNumPad.BackIm.Visible:=true;
          Self.Visible:=false;
          fDlgUp:=true;
end;

procedure tConnectDlg.IPDone(Sender: TObject);
begin

    if assigned(fIPNumPad) then
    begin
      SetIP(fIPNumPad.IP);
      fIPNumPad.Visible:=false;
      fIpNumPad.BackIm.Visible:=false;
      Self.Visible:=true;
    end;
    fDlgUp:=false;


end;

procedure tConnectDlg.IPCancel(sender: TObject);
begin
    if assigned(fIPNumPad) then
    begin
      fIPNumPad.Visible:=false;
      fIpNumPad.BackIm.Visible:=false;
      Self.Visible:=true;
    end;
    fDlgUp:=false;

end;

procedure tConnectDlg.NicClick(sender: TObject);
begin
  if fDlgUp then exit;
  if fConnecting then exit;

  if not Assigned(KeyboardDlg) then
     KeyboardDlg:=tDlgKeyboard.Create(self,fmat,TDummy(Self.Parent).Width,TDummy(Self.Parent).Height,0,0);
  KeyboardDlg.Parent:=Self;
  KeyboardDlg.Position.Z:=-4;
  KeyBoardDlg.AllowSpec:=false;
  KeyboardDlg.OnDone:=NicDone;
  KeyboardDlg.StrGet:=fnic;
  KeyboardDlg.BtnLabel:='Enter your NIC..';
  fDlgUp:=true;
end;

procedure tConnectDlg.NicDone(sender: TObject);
var
aStr:String;
begin
  //
  aStr:=KeyboardDlg.StrGet;
  if aStr<>'' then
    begin
      fNic:=aStr;
      fBtnNic.Text:=aStr;
    end;
  Tron.KillKeyboard;
  fDlgUp:=false;
end;

procedure tConnectDlg.HashClick(sender: TObject);
begin
  if fDlgUp then exit;
  if fConnecting then exit;

  if not Assigned(KeyboardDlg) then
     KeyboardDlg:=tDlgKeyboard.Create(self,fmat,TDummy(Self.Parent).Width,TDummy(Self.Parent).Height,0,0);
  KeyboardDlg.Parent:=Self;
  KeyboardDlg.Position.Z:=-4;
  KeyboardDlg.OnDone:=HashDone;
  KeyBoardDlg.AllowSpec:=true;
  KeyboardDlg.StrGet:='';
  KeyboardDlg.BtnLabel:='Enter your password..';
  fDlgUp:=true;
end;

procedure tConnectDlg.HashDone(sender: TObject);
var
aStr:String;
begin
  //
  aStr:=KeyboardDlg.StrGet;
  if aStr<>'' then
    begin
    fpass:=aStr;
    aStr:=StringOfChar('*',Length(fpass));
    fBtnHash.Text:=aStr;
    end;
  Tron.KillKeyboard;
  fDlgUp:=false;
end;

procedure tConnectDlg.ConnectClick(sender: TObject);
begin

if fDlgUp then exit;
if fConnecting then exit;

  SetConnecting;


 if fPass<> GamerHash then
   begin
     PacketCli.Gamer.SmokeHash(fPass);
     GamerHash:=PacketCli.Gamer.Hash;
     fPass:=GamerHash;
   end;
 PacketCli.Gamer.Nic:=fNic;
 PacketCli.Port:=fPort;
 PacketCLi.IP:=fIP;
 if not assigned(PacketCli.ClientComms) then
   PacketCli.CreateComms;

 PacketCli.ClientComms.Host:=fIP;
 PacketCli.ClientComms.Port:=fPort;
 PacketCli.OnConnect:=OnConnect;
 PacketCli.OnRecvDef:=OnRecvGameDef;
 PacketCli.OnHashError:=OnBadHash;
 PacketCli.OnCommError:=OnError;

       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
            try
              PacketCli.ClientComms.Connect;
              except on e:exception do
               ConnectDlg.OnError(nil,e.Message);
            end;
             end);
         end).Start;



  {

  try
   PacketCli.ClientComms.Connect;
  except on e:exception do
  OnError(nil,e.Message);
  end;
   }

end;

procedure tConnectDlg.OnConnect(sender: TObject);
begin
  //connected
  PacketCli.ConnectGamer;
  fConnecting:=false;

end;

procedure tConnectDlg.OnError(sender: TObject; aMsg: string);
begin
  //
  fConnected:=false;
  fConnecting:=false;
  PacketCli.ClientComms.Disconnect;
  fDlgUp:=true;
  MsgOK(aMsg);
  InfoDlg.OnClick:=ClearError;
  fBtnConnect.Text:='Connect';

end;

procedure tConnectDlg.OnBadHash(senrder: TObject);
begin

OnError(nil,'Bad Password.');


end;

procedure tConnectDlg.ClearError(sender: TObject);
begin
  Tron.KillInfo(nil);
  fDlgUp:=False;

end;

procedure tConnectDlg.OnRecvGameDef(sender: TObject);
begin
  //gamer connected, game received, let's play

   PacketCli.OnConnect:=nil;
   PacketCli.OnRecvDef:=nil;
   PacketCli.OnHashError:=nil;
   PacketCli.OnCommError:=nil;
   PacketCli.ClientComms.Disconnect;
   //update globs, will be saved in app close..
   GamerNic:=PacketCli.Gamer.Nic;
   GamerHash:=PacketCli.Gamer.Hash;
   SrvIp:=fIp;
   SrvPort:=IntToStr(fPort);


  DoDone(nil);

end;

procedure tConnectDlg.DoCancelClick(sender: TObject);
begin
  if assigned(fCancelEvent) then
     fCancelEvent(nil);
end;

procedure tConnectDlg.DoDone(sender: TObject);
begin
  if Assigned(fDoneEvent) then
      fDoneEvent(nil);
end;


procedure tConnectDlg.SetPort(aPort: Integer);
begin
  fPort:=aPort;
  fBtnPort.Text:=IntToStr(fPort);
end;

procedure tConnectDlg.SetIP(aIP: string);
begin
  fIp:=aIp;
  fBtnIp.Text:=aIp;
end;


procedure tConnectDlg.GetPort(sender:tObject);
begin
if fDlgUp then exit;
if fConnecting then exit;

  //get new port number
       if not assigned(fNumPad) then
        begin
          //creae a keyboard here
          fNumPad:=tDlgNumPad.Create(self,fmat,Width,height,0,0);
        end;
          fNumPad.Number:=fPort;
          fNumPad.OnDone:=PortDone;
          fNumPad.Parent:=self.Parent;
          fNumPad.BackIm.Visible:=true;
          fNumPad.Position.Z:=-4;
          fNumPad.Visible:=true;
          Self.Visible:=false;
          fDlgUp:=true;
end;

procedure tConnectDlg.PortDone(sender: TObject;aExitType:integer);
begin
  //nada
    if assigned(fNumPad) then
    begin
    if aExitType=0 then
       SetPort(fNumPad.Number);
       fNumPad.Visible:=false;
       fNumPad.BackIm.Visible:=false;
       Self.Visible:=true;
    end;
    fDlgUp:=false;

end;

end.
