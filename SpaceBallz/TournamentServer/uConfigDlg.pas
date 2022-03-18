unit uConfigDlg;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, System.Math.Vectors, FMX.Ani, FMX.Controls3D,FMX.Layers3d,
  FMX.MaterialSources, FMX.Objects3D, FMX.Effects, FMX.Filter.Effects,FMX.Objects,
  uDlg3dCtrls,uNumPadDlg,uNumSelectDlg,uSpaceBallzData;





  type
     tDlgConfig= class(TDummy)
       private
       //priv

       fGameDef:TGameDefinitionRec;
       fServerIP:String;
       fServerPort:String;
       fNumLevels:byte;
       fSkipped:Boolean;
       fBtnServerIP:tDlgInputButton;
       fBtnServerPort:tDlgInputButton;
       fBtnPaddleSize:tDlgInputButton;
       fBtnBallSize:tDlgInputButton;
       fBtnBallSpeed:tDlgInputButton;
       fBtnMaxEntries:tDlgInputButton;

       fBtnNext:tDlgButton;
       fBtnPrev:tDlgButton;
       fBtnHeader:array of tDlgButton;
       fBtnNumBalls: array of tDlgInputButton;
       fBtnDelay: array of tDlgInputButton;
       fBtnCancel:tDlgButton;
       fBtnDone:tDlgButton;
       fIm:TImage3d;
       fMat:TDlgMaterial;
       fDoneEvent:TDlgDoneClick_Event;
       fCancelEvent:tDlgCancelClick_Event;
       fNumPad:TDlgNumPad;
       fNumSel:tDlgNumSel;
       fStartNum:byte;
       fDlgUp:boolean;
       fCleanedUp:boolean;




       protected
       //prots
       procedure DoPaddleClick(sender:tObject);
       procedure DoSizeClick(sender:tObject);
       procedure DoSpeedClick(sender:tObject);
       procedure OnSpeedDone(sender:tObject);
       procedure DoEntriesClick(sender:tObject);
       procedure OnEntriesDone(sender:tObject;aExitType:integer);
       procedure DoPortClick(sender:tObject);
       procedure OnPortDone(sender:tObject;aExitType:integer);
       procedure DoDoneClick(sender:tObject);
       procedure DoCancelClick(sender:tObject);
       procedure DoNextClick(sender:tObject);
       procedure DoPrevClick(sender:tObject);
       procedure DoNumBallsClick(sender:tObject);
       procedure NumBallsDone(sender:tObject);
       procedure DoDelayClick(sender:tObject);
       procedure DelayDone(sender:tObject;aExitType:integer);
       procedure DoNameClick(sender:tObject);
       procedure Refresh;

       public
       //pubs
       constructor Create(aOwner:TComponent;aMat:TDlgMaterial;aWidth,aHeight,aX,aY:single); reintroduce;
       destructor  Destroy;override;
       procedure   CleanUp;
       property GameDef:tGameDefinitionRec read fGameDef write fGameDef;
       property BackIm:TImage3d read fim write fim;
       property OnDone:TDlgDoneClick_Event read fDoneEvent write fDoneEvent;
       property OnCancel:TDlgCancelClick_Event read fCancelEvent write fCancelEvent;
       property Port:string read fServerPort write fServerPort;
       property CleanedUp:boolean read fCleanedUp;
     end;






implementation

uses dmFMXPacketSrv,uGlobs;








Constructor tDlgConfig.Create(aOwner: TComponent; aMat: TDlgMaterial;
                aWidth: Single; aHeight: Single; aX: Single; aY: Single);
var
i,j,k:integer;
newx,newy:single;
aButtonHeight,aButtonWidth,aParamWidth:single;
aColGap,aRowGap:single;
SectionHeight:single;
ah,af,ap:single;
begin
inherited Create(aOwner);
//create things
  //set our cam first always!!!
  Projection:=TProjection.Screen;

 fCleanedUp:=false;

 Opacity:=0.85;

  fMat:=aMat;
  fDlgUp:=false;

  fNumPad:=nil;
  fNumSel:=nil;

  fServerIP:=ServerIp;
  fServerPort:=ServerPort;

  fStartNum:=0;
  fNumLevels:=MAX_LEVELS;

  //set w,h and pos
  Width:=(aWidth);
  Height:=(aHeight);
  Position.X:=aX;
  Position.Y:=aY;
  Depth:=1;

  fIm:=TImage3d.Create(self);
  fIm.Projection:=tProjection.Screen;
  fIm.WrapMode:=TImageWrapMode.Stretch;
  fIm.TwoSide:=false;
  fIm.Width:=aWidth;
  fIm.Height:=aHeight;
  fIm.HitTest:=false;
  fIm.Position.X:=0;
  fIm.Position.Y:=0;
  fIm.Position.Z:=0;
  fIm.Parent:=self;
  fIm.Opacity:=0.85;
  fIm.Bitmap.Assign(fMat.BackImage);




  if Width>600 then
  SectionHeight:=80 else
  SectionHeight:=50;

  aColGap:=2;
  aRowGap:=2;
  aButtonWidth:=(aWidth/3);//divide width by max keys in a row
  aButtonWidth:=aButtonWidth-aColGap;
  aParamWidth:=Trunc(Width/7);
  aParamWidth:=aParamWidth-aColGap;

  fMat.FontSize:=32;

  ah:=(Height / 6);// divide height by number of rows..
  SectionHeight:=ah;
  SectionHeight:=SectionHeight-aRowGap;

if SectionHeight>(aButtonWidth+aColGap) then
   begin
     ah:=SectionHeight-(aButtonWidth+aColGap);
     SectionHeight:=(SectionHeight-(ah/2));
   end;


//change font size..
  if SectionHeight>79 then
    begin
     fMat.FontSize:=24;
    end else
    begin
      fMat.FontSize:=18;
    end;

  if SectionHeight>100 then
     begin
     fMat.FontSize:=28;
     end;



  newy:=(((aHeight/2)*-1)+(SectionHeight/2))+aRowGap;//top
  newx:=(((aWidth/2)*-1)+(aButtonWidth/2))+aColGap;//left

      fBtnServerIP:=tDlgInputButton.Create(self,aButtonwidth,SectionHeight,newx,newy);
      fBtnServerIP.Projection:=TProjection.Screen;
      fBtnServerIP.Parent:=self;
      fBtnServerIP.Opacity:=0.95;
      fBtnServerIP.MaterialSource:=fMat.Large.Rect;
    fBtnServerIP.TextColor:=fMat.Buttons.TextColor.Color;
    fBtnServerIP.LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnServerIP.FontSize:=fMat.FontSize;
    fBtnServerIP.BtnBitMap.Assign(fMat.Large.Rect.Texture);

      fBtnServerIP.OnClick:=DoNameClick;
      fBtnServerIP.Text:=ServerIP;

      fBtnServerIP.LabelText:='Server IP';

      newx:=(newx+(aButtonWidth/2)+(aButtonWidth/4))+aColGap;

      fBtnServerPort:=tDlgInputButton.Create(self,(aButtonwidth/2),SectionHeight,newx,newy);
      fBtnServerPort.Projection:=TProjection.Screen;
      fBtnServerPort.Parent:=self;
      fBtnServerPort.MaterialSource:=fMat.Buttons.Rect;
    fBtnServerPort.TextColor:=fMat.Buttons.TextColor.Color;
    fBtnServerPort.LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnServerPort.FontSize:=fMat.FontSize;
    fBtnServerPort.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
    fBtnServerPort.Text:=ServerPort;
    fBtnServerPort.LabelText:='Server Port';

      fBtnServerPort.OnClick:=DoPortClick;



      //new line
      newy:=newy+SectionHeight+aRowGap;
      newx:=((aWidth/2)*-1)+(aButtonWidth/2)+aColGap;//left
      newx:=(newx-(aButtonWidth/4));



      fBtnPaddleSize:=tDlgInputButton.Create(self,(aButtonwidth/2),SectionHeight,newx,newy);
      fBtnPaddleSize.Projection:=TProjection.Screen;
      fBtnPaddleSize.Parent:=self;
      fBtnPaddleSize.MaterialSource:=fMat.Buttons.Rect;
      fBtnPaddleSize.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnPaddleSize.LabelColor:=fMat.Buttons.TextColor.Color;
      fBtnPaddleSize.FontSize:=fMat.FontSize;
      fBtnPaddleSize.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
      fBtnPaddleSize.Text:='Medium';
      fBtnPaddleSize.LabelText:='Paddle Size';
      fBtnPaddleSize.OnClick:=DoPaddleClick;

      newx:=(newx+(aButtonWidth/2))+aColGap;


      fBtnBallSize:=tDlgInputButton.Create(self,(aButtonwidth/2),SectionHeight,newx,newy);
      fBtnBallSize.Projection:=TProjection.Screen;
      fBtnBallSize.Parent:=self;
      fBtnBallSize.MaterialSource:=fMat.Buttons.Rect;
    fBtnBallSize.TextColor:=fMat.Buttons.TextColor.Color;
    fBtnBallSize.LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnBallSize.FontSize:=fMat.FontSize;
    fBtnBallSize.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
    fBtnBallSize.Text:='Medium';
    fBtnBallSize.LabelText:='Ball Size';
      fBtnBallSize.OnClick:=DoSizeClick;

      newx:=(newx+(aButtonWidth/2))+aColGap;
      fBtnBallSpeed:=tDlgInputButton.Create(self,(aButtonwidth/2),SectionHeight,newx,newy);
      fBtnBallSpeed.Projection:=TProjection.Screen;
      fBtnBallSpeed.Parent:=self;
      fBtnBallSpeed.MaterialSource:=fMat.Buttons.Rect;
    fBtnBallSpeed.TextColor:=fMat.Buttons.TextColor.Color;
    fBtnBallSpeed.LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnBallSpeed.FontSize:=fMat.FontSize;
    fBtnBallSpeed.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
    fBtnBallSpeed.Text:='4';
    fBtnBallSpeed.LabelText:='Ball Speed';

      fBtnBallSpeed.OnClick:=DoSpeedClick;

      newx:=(newx+(aButtonWidth/2))+aColGap;
      fBtnMaxEntries:=tDlgInputButton.Create(self,(aButtonwidth/2),SectionHeight,newx,newy);
      fBtnMaxEntries.Projection:=TProjection.Screen;
      fBtnMaxEntries.Parent:=self;
      fBtnMaxEntries.MaterialSource:=fMat.Buttons.Rect;
      fBtnMaxEntries.TextColor:=fMat.Buttons.TextColor.Color;
      fBtnMaxEntries.LabelColor:=fMat.Buttons.TextColor.Color;
      fBtnMaxEntries.FontSize:=fMat.FontSize;
      fBtnMaxEntries.BtnBitMap.Assign(fMat.Buttons.Rect.Texture);
      fBtnMaxEntries.Text:='99';
      fBtnMaxEntries.LabelText:='Max Entries';
      fBtnMaxEntries.OnClick:=DoEntriesClick;
      fBtnMaxEntries.Visible:=false;

      //add this to space it up
      newy:=newy+(SectionHeight/4);


       newy:=newy+(SectionHeight/2)+aRowGap;
       newx:=(((aWidth/2)*-1)+(aParamWidth/4))+aColGap;//left
       newy:=(newy+(((SectionHeight*2.5)+(aRowGap*2))/2));

     fBtnPrev:=TDlgButton.Create(self,(aParamWidth/2),Trunc((SectionHeight*2.5)+(aRowGap*2)),newx,newy);
     fBtnPrev.Projection:=tProjection.Screen;
     fBtnPrev.Parent:=self;
     fBtnPrev.MaterialSource:=fMat.Small.VRect;
    fBtnPrev.TextColor:=fMat.Buttons.TextColor.Color;
    //fBtnPrev.LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnPrev.FontSize:=fMat.FontSize;
    fBtnPrev.BtnBitMap.Assign(fMat.Small.VRect.Texture);
    fBtnPrev.Text:='<';
     fBtnPrev.OnClick:=DoPrevClick;

     newx:=(((aWidth/2))-(aParamWidth/4))-aColGap;//left

     fBtnNext:=TDlgButton.Create(self,(aParamWidth/2),Trunc((SectionHeight*2.5)+(aRowGap*2)),newx,newy);
     fBtnNext.Projection:=tProjection.Screen;
     fBtnNext.Parent:=self;
     fBtnNext.MaterialSource:=fMat.Small.VRect;
    fBtnNext.TextColor:=fMat.Buttons.TextColor.Color;
    fBtnNext.FontSize:=fMat.FontSize;
    fBtnNext.BtnBitMap.Assign(fMat.Small.VRect.Texture);
    fBtnNext.Text:='>';
     fBtnNext.OnClick:=DoNextClick;


       newy:=newy-(((SectionHeight*2.5)+(aRowGap*2))/2);

     //init fLevels arrays
     for I := 0 to MAX_LEVELS-1 do
       begin
         fGameDef.Levels[i].Balls:=1;
         if i=0 then
         fGameDef.Levels[i].Seconds:=2 else
         fGameDef.Levels[i].Seconds:=i*60;
       end;
       fGameDef.BallSize:=1;
       fGameDef.PaddleSize:=1;
       fGameDef.BallSpeed:=4;
       fGameDef.MaxEntries:=99;




    SetLength(fBtnHeader,6);
   newx:=(((aWidth/2)*-1)+(aParamWidth/2)+(aParamWidth/2))+aColGap;//left
   newy:=(newy+SectionHeight/4);

        for I := Low(fBtnHeader) to High(fBtnHeader) do
   begin
    fBtnHeader[i]:=TDlgButton.Create(self,aParamwidth,Trunc(SectionHeight/2),newx,newy);
    fBtnHeader[i].Projection:=TProjection.Screen;
    fBtnHeader[i].Parent:=self;
    fBtnHeader[i].Tag:=i;
    fBtnHeader[i].MaterialSource:=fMat.Small.Rect;
    fBtnHeader[i].TextColor:=fMat.Buttons.TextColor.Color;
    fBtnHeader[i].FontSize:=fMat.FontSize;
    fBtnHeader[i].TextFixed:=true;
    fBtnHeader[i].BtnBitMap.Assign(fMat.Small.Rect.Texture);
    fBtnHeader[i].Text:=IntToStr(i+1);
    fBtnHeader[i].OnClick:=nil;

    newx:=newx+aParamWidth+aColGap;
    end;


      newy:=newy-SectionHeight/4;

      newy:=(newy+(SectionHeight))+aRowGap;

   //now the param buttons
      SetLength(fBtnNumBalls,6);
      newx:=(((aWidth/2)*-1)+(aParamWidth/2)+(aParamWidth/2))+aColGap;//left


        for I := Low(fBtnNumBalls) to High(fBtnNumBalls) do
   begin
    fBtnNumBalls[i]:=TDlgInputButton.Create(self,aParamwidth,SectionHeight,newx,newy);
    fBtnNumBalls[i].Projection:=TProjection.Screen;
    fBtnNumBalls[i].Parent:=self;
    fBtnNumBalls[i].Tag:=i;
    fBtnNumBalls[i].MaterialSource:=fMat.Small.Button;
    fBtnNumBalls[i].TextColor:=fMat.Buttons.TextColor.Color;
    fBtnNumBalls[i].LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnNumBalls[i].FontSize:=fMat.FontSize;
    fBtnNumBalls[i].LabelSize:=fMat.FontSize/1.5;
    fBtnNumBalls[i].LabelFixed:=true;
    fBtnNumBalls[i].BtnBitMap.Assign(fMat.Small.Button.Texture);
    fBtnNumBalls[i].Text:='1';
    fBtnNumBalls[i].LabelText:='Ballz Launched';

    fBtnNumBalls[i].OnClick:=DoNumBallsClick;
    fBtnNumBalls[i].RecordID:=i;
    fBtnNumBalls[i].ByteValue:=1;
    newx:=newx+aParamWidth+aColGap;
    end;



      SetLength(fBtnDelay,6);
      newx:=(((aWidth/2)*-1)+(aParamWidth/2)+(aParamWidth/2))+aColGap;//left
      newy:=newy+SectionHeight+aRowGap;// NL


        for I := Low(fBtnNumBalls) to High(fBtnNumBalls) do
   begin
    fBtnDelay[i]:=TDlgInputButton.Create(self,aParamwidth,SectionHeight,newx,newy);
    fBtnDelay[i].Projection:=TProjection.Screen;
    fBtnDelay[i].Parent:=self;
    fBtnDelay[i].Tag:=i;
    fBtnDelay[i].MaterialSource:=fMat.Small.Button;
    fBtnDelay[i].TextColor:=fMat.Buttons.TextColor.Color;
    fBtnDelay[i].LabelColor:=fMat.Buttons.TextColor.Color;
    fBtnDelay[i].FontSize:=fMat.FontSize;
    fBtnDelay[i].LabelSize:=fMat.FontSize/1.5;
    fBtnDelay[i].LabelFixed:=true;
    fBtnDelay[i].BtnBitMap.Assign(fMat.Small.Button.Texture);
    fBtnDelay[i].OnClick:=DoDelayClick;
    fBtnDelay[i].RecordID:=i;
    fBtnDelay[i].LabelText:='Launch Time';
    fBtnDelay[i].Text:='00:00';



    newx:=newx+aParamWidth+aColGap;
    end;









      newy:=newy+(SectionHeight/4);
      newy:=(newy+SectionHeight+aRowGap);// NL
      newx:=(((aWidth/2)*-1)+(aButtonWidth/2))+aColGap; //CR

     fBtnCancel:=TDlgButton.Create(self,aButtonWidth,SectionHeight,newx,newy);
     fBtnCancel.Projection:=tProjection.Screen;
     fBtnCancel.Parent:=self;
     fBtnCancel.MaterialSource:=fMat.Large.Rect;
     fBtnCancel.TextColor:=fMat.Buttons.TextColor.Color;
     fBtnCancel.FontSize:=fMat.FontSize;
     fBtnCancel.BtnBitMap.Assign(fMat.Large.Rect.Texture);
     fBtnCancel.Text:='Cancel';


     fBtnCancel.OnClick:=DoCancelClick;//
     //empty space
     Newx:=Newx+(aButtonWidth)+(aColGap);
     fBtnDone:=TDlgButton.Create(self,aButtonWidth,SectionHeight,newx,newy);
     fBtnDone.Projection:=tProjection.Screen;
     fBtnDone.Parent:=self;
     fBtnDone.MaterialSource:=fMat.Large.Rect;
     fBtnDone.TextColor:=fMat.Buttons.TextColor.Color;
     fBtnDone.FontSize:=fMat.FontSize;
     fBtnDone.BtnBitMap.Assign(fMat.Large.Rect.Texture);
     fBtnDone.Text:='Done';
     fBtnDone.Opacity:=0.95;

     fBtnDone.OnClick:=DoDoneClick;//


      Refresh;


end;

Destructor tDlgConfig.Destroy;
begin

 if not fCleanedUp then CleanUp;



inherited;
end;

procedure tDlgConfig.CleanUp;
var
i:integer;
temp:TComponent;
begin
//clean house

if fCleanedUp then exit;


if assigned(fNumPad) then
begin
 fNumPad.CleanUp;
 fNumPad.Free;
 fNumPad:=nil;
end;

if assigned(fNumSel) then
begin
 fNumSel.CleanUp;
 fNumSel.Free;
 fNumSel:=nil;
end;




fBtnPaddleSize.CleanUp;
fBtnPaddleSize.Free;
fBtnPaddleSize:=nil;

fBtnBallSize.CleanUp;
fBtnBallSize.Free;
fBtnBallSize:=nil;

fBtnBallSpeed.CleanUp;
fBtnBallSpeed.Free;
fBtnBallSpeed:=nil;

fBtnMaxEntries.CleanUp;
fBtnMaxEntries.Free;
fBtnMaxEntries:=nil;



fBtnDone.CleanUp;
fBtnDone.Free;
fBtnDone:=nil;

fBtnServerPort.CleanUp;
fBtnServerPort.Free;
fBtnServerPort:=nil;

fBtnCancel.CleanUp;
fBtnCancel.Free;
fBtnCancel:=nil;

fBtnNext.CleanUp;
fBtnNext.Free;
fBtnNext:=nil;

fBtnPrev.CleanUp;
fBtnPrev.Free;
fBtnPrev:=nil;

fBtnServerIP.CleanUp;
fBtnServerIP.Free;
fBtnServerIP:=nil;

for I := Low(fBtnNumBalls) to High(fBtnNumBalls) do
 begin
    fBtnNumBalls[i].CleanUp;
    fBtnNumBalls[i].Free;
    fBtnNumBalls[i]:=nil;
 end;

for I := Low(fBtnDelay) to High(fBtnDelay) do
begin
    fBtnDelay[i].CleanUp;
    fBtnDelay[i].Free;
    fBtnDelay[i]:=nil;
end;

for I := Low(fBtnHeader) to High(fBtnHeader) do
begin
    fBtnHeader[i].CleanUp;
    fBtnHeader[i].Free;
    fBtnHeader[i]:=nil;
end;

SetLength(fBtnNumBalls,0);
SetLength(fBtnDelay,0);
SetLength(fBtnHeader,0);
  fBtnNumBalls:=nil;
  fBtnDelay:=nil;
  fBtnHeader:=nil;


fIm.Free;
fIm:=nil;


fDoneEvent:=nil;
fCancelEvent:=nil;

fMat:=nil;
Parent:=nil;

fCleanedUp:=true;



end;



procedure tDlgConfig.DoDoneClick(sender: TObject);
begin
if fDlgUp then exit;

  if assigned(fDoneEvent) then
      fDoneEvent(self);
end;

procedure tDlgConfig.DoCancelClick(sender: TObject);
begin
if fDlgUp then exit;
  if assigned(fCancelEvent) then
      fCancelEvent(self);
end;


procedure tDlgConfig.DoNextClick(sender: TObject);
var
i:integer;
begin
if fDlgUp then exit;
//next
if fNumLevels>6 then
   begin
     if fStartNum<(fNumLevels-6) then
       begin
         fStartNum:=fStartNum+6;
          for I := Low(fBtnHeader) to High(fBtnHeader) do
              begin
                fBtnHeader[i].Tag:=fStartNum+i;
                fBtnHeader[i].Text:=IntToStr((fStartNum+1)+i);
                fBtnNumBalls[i].RecordID:=fStartNum+i;
                fBtnNumBalls[i].Text:=IntToStr(fGameDef.Levels[fStartNum+i].Balls);
                fBtnDelay[i].RecordID:=fStartNum+i;
                fBtnDelay[i].Text:=FormatBestScore(fGameDef.Levels[fStartNum+i].Seconds);
              end;
       end;
   end;
end;

procedure tDlgConfig.DoPrevClick(sender: TObject);
var
i:integer;
begin
if fDlgUp then exit;
//prev
if fNumLevels>6 then
   begin
     if fStartNum>=6 then
       begin
         fStartNum:=fStartNum-6;
          for I := Low(fBtnHeader) to High(fBtnHeader) do
              begin
                fBtnHeader[i].Tag:=fStartNum+i;
                fBtnHeader[i].Text:=IntToStr((fStartNum+1)+i);
                fBtnNumBalls[i].RecordID:=fStartNum+i;
                fBtnNumBalls[i].Text:=IntToStr(fGameDef.Levels[fStartNum+i].Balls);
                fBtnDelay[i].RecordID:=fStartNum+i;
                fBtnDelay[i].Text:=FormatBestScore(fGameDef.Levels[fStartNum+i].Seconds);

              end;
       end;
   end;
end;





procedure tDlgConfig.DoNumBallsClick(sender: TObject);
var
aRecId:integer;
begin
if fDlgUp then exit;

   if sender is tDlgInputButton then
     with sender as tDlgInputButton do
        begin
        aRecID:=RecordID;
        end;

  //open up a numsel..
     if not assigned(fNumSel) then
        begin
          fNumSel:=tDlgNumSel.Create(self,fmat,height,height/1.25,Width/2,Height/2);
        end;
          fNumSel.OnDone:=NumBallsDone;
          fNumSel.Parent:=self.Parent;
          fNumSel.Position.Z:=-10;
          fNumSel.Visible:=true;
          fNumSel.Tag:=aRecId;
          fDlgUp:=true;


end;

procedure tDlgConfig.NumBallsDone(sender: TObject);
var
aNum,i:integer;
aRecID:integer;
begin

  if assigned(fNumSel) then
    begin
    aNum:=fNumSel.Num;
    aRecID:=fNumSel.Tag;
    fNumSel.visible:=false;
    Self.Visible:=true;
    fGameDef.Levels[aRecID].Balls:=aNum;
     for I := Low(fBtnNumBalls) to High(fBtnNumBalls) do
     begin
       if fBtnNumBalls[i].RecordID=aRecID then
         begin
           fBtnNumBalls[i].Text:=IntToStr(aNum);
           break;
         end;
     end;
    end;

   fDlgUp:=false;
end;


procedure tDlgConfig.DoDelayClick(sender: TObject);
var
aRecID:integer;
begin
if fDlgUp then exit;
   if sender is tDlgInputButton then
     with sender as tDlgInputButton do
     begin

       aRecID:=RecordID;
     end;

     if not assigned(fNumPad) then
        begin

          fNumPad:=tDlgNumPad.Create(self,fmat,height,height/1.25,Width/2,Height/2);
        end;
          fNumPad.Number:=fGameDef.Levels[aRecID].Seconds;
          fNumPad.Tag:=aRecID;
          fNumPad.OnDone:=DelayDone;
          fNumPad.Parent:=self.Parent;
          fNumPad.Position.Z:=-10;
          fNumPad.Visible:=true;
          fDlgUp:=true;



end;

procedure tDlgConfig.DelayDone(sender: TObject; aExitType: Integer);
var
aNum,i:integer;
aRecID:integer;
begin

  if assigned(fNumPad) then
    begin
    aNum:=fNumPad.Number;
    aRecID:=fNumPad.Tag;
    fNumPad.visible:=false;
    Self.Visible:=true;
    fGameDef.Levels[aRecID].Seconds:=aNum;
     for I := Low(fBtnDelay) to High(fBtnDelay) do
     begin
       if fBtnDelay[i].RecordID=aRecID then
         begin
           fBtnDelay[i].Text:=FormatBestScore(aNum);
           break;
         end;
     end;
    end;

   fDlgUp:=false;


end;

procedure tDlgConfig.DoNameClick(sender: TObject);
begin
//nop
end;



procedure tDlgConfig.Refresh;
var
i:integer;
gd:tGameDefinitionRec;
begin

   fStartNum:=0;
  fBtnServerIP.Text:=fServerIP;
  fBtnServerPort.Text:=fServerPort;
  gd:=SrvCommsDm.GameData.GameDef;

  Move(gd,fGameDef,SizeOf(TGameDefinitionRec));


      case fGameDef.BallSize of
      0:fBtnBallSize.Text:='Small';
      1:fBtnBallSize.Text:='Medium';
      2:fBtnBallSize.Text:='Large';
      end;

      case fGameDef.PaddleSize of
      0:fBtnPaddleSize.Text:='Small';
      1:fBtnPaddleSize.Text:='Medium';
      2:fBtnPaddleSize.Text:='Large';
      end;


  fBtnBallSpeed.Text:=IntToStr(fGameDef.BallSpeed);
  fBtnMaxEntries.Text:=IntToStr(fGameDef.MaxEntries);


    for I := Low(fBtnHeader) to High(fBtnHeader) do
        begin
        fBtnHeader[i].Tag:=fStartNum+i;
        fBtnHeader[i].Text:=IntToStr(1+i);
        fBtnNumBalls[i].RecordID:=i;
        fBtnNumBalls[i].ByteValue:=fGameDef.Levels[i].Balls;
        fBtnNumBalls[i].Text:=IntToStr(fGameDef.Levels[i].Balls);
        fBtnDelay[i].RecordID:=fStartNum+i;
        fBtnDelay[i].Text:=FormatBestScore(fGameDef.Levels[i].Seconds);
        end;



end;


procedure tDlgConfig.DoSizeClick(sender: TObject);
var
aSize:integer;
begin
  //toggle ball size
if fDlgUp then exit;
    aSize:=fGameDef.BallSize;
    if aSize<2 then inc(aSize) else aSize:=0;
    fGameDef.BallSize:=aSize;
      case aSize of
      0:fBtnBallSize.Text:='Small';
      1:fBtnBallSize.Text:='Medium';
      2:fBtnBallSize.Text:='Large';
      end;



end;



procedure tDlgConfig.DoPaddleClick(sender: TObject);
var
aSize:byte;
begin
if fDlgUp then exit;
     //toggle paddle size
    aSize:=fGameDef.PaddleSize;
    if aSize<2 then inc(aSize) else aSize:=0;
    fGameDef.PaddleSize:=aSize;
      case aSize of
      0:fBtnPaddleSize.Text:='Small';
      1:fBtnPaddleSize.Text:='Medium';
      2:fBtnPaddleSize.Text:='Large';
      end;



end;




procedure tDlgConfig.DoSpeedClick(sender: TObject);
begin
if fDlgUp then exit;

  //open up a numsel..
     if not assigned(fNumSel) then
        begin
          fNumSel:=tDlgNumSel.Create(self,fmat,height,height/1.25,Width/2,Height/2);
        end;
          fNumSel.OnDone:=OnSpeedDone;
          fNumSel.Parent:=self.Parent;
          fNumSel.Position.Z:=-10;
          fNumSel.Visible:=true;
          fDlgUp:=true;




end;

procedure tDlgConfig.OnSpeedDone(sender: TObject);
var
aNum:integer;
begin

  if assigned(fNumSel) then
    begin
    aNum:=fNumSel.Num;
    fNumSel.visible:=false;
    Self.Visible:=true;
    fBtnBallSpeed.Text:=IntToStr(aNum);
    fGameDef.BallSpeed:=aNum;
    end;

   fDlgUp:=false;


end;

procedure tDlgConfig.DoEntriesClick(sender: TObject);
begin
  //open up a numpad..
  if fDlgUp then exit;

     if not assigned(fNumPad) then
        begin
        fNumPad:=tDlgNumPad.Create(self,fmat,height,height/1.25,Width/2,Height/2);
        end;
          fNumPad.Number:=fGameDef.MaxEntries;
          fNumPad.OnDone:=OnEntriesDone;
          fNumPad.Parent:=self.Parent;
          fNumPad.Position.Z:=-10;
          fNumPad.Visible:=true;
          fDlgUp:=true;





end;

procedure tDlgConfig.OnEntriesDone(sender: TObject;aExitType:integer);
var
aNum:integer;
begin

  aNum:=fGameDef.MaxEntries;

  if assigned(fNumPad) then
    begin
    if aExitType=0 then
      begin
         aNum:=fNumPad.Number;
         if aNum>99 then aNum:=99;
         if aNum<1 then aNum:=1;
       fBtnMaxEntries.Text:=IntToStr(aNum);
       fGameDef.MaxEntries:=aNum;
      end;
       fNumPad.Visible:=false;
    end;

   fDlgUp:=False;

end;



procedure tDlgConfig.DoPortClick(sender: TObject);
begin
  //open up a numpad..
  if fDlgUp then exit;

     if not assigned(fNumPad) then
        begin
          fNumPad:=tDlgNumPad.Create(self,fmat,height,height/1.25,Width/2,Height/2);
        end;
          fNumPad.Number:=StrToInt(fServerPort);
          fNumPad.OnDone:=OnPortDone;
          fNumPad.Parent:=self.Parent;
          fNumPad.Position.Z:=-10;
          fNumPad.Visible:=true;
          fDlgUp:=True;





end;

procedure tDlgConfig.OnPortDone(sender: TObject;aExitType:integer);
begin

  if assigned(fNumPad) then
    begin
    if aExitType=0 then
      begin
         fServerPort:=IntToStr(fNumPad.Number);
         fBtnServerPort.Text:=fServerPort;
      end;
       fNumPad.visible:=false;
    end;

   fDlgUp:=False;

end;




end.
