{Scene Space Ballz - bash around up to 12 balls with two fingers..

created 2.13.2022 -q


 Happy Birthday Delphi!!

  be it harm none, do as ye wish.

}
unit uSpaceBallz;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts,System.SyncObjs,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, System.Math.Vectors, FMX.Ani, FMX.Controls3D,FMX.Surfaces,
  FMX.MaterialSources, FMX.Objects3D, FMX.Effects, FMX.Filter.Effects,FMX.Layers3D,
  FMX.Objects,uDlg3dCtrls,uNumSelectDlg,uInertiaTimer;

 //our balls
type
    TSpaceBall = class(tSphere)
     private
      fHDirection:byte;
      fVDirection:byte;
      fAngle:single;
      fStep:single;
      fMaxStep:single;
      fLastY:single;
      fLaunched:Boolean;
      fLaunchDelay:word;
      fBallSize:byte;
     protected
     public
      constructor Create(aOwner:TComponent; aWidth: single; aHeight: single;ax,ay:single); reintroduce;
      destructor  Destroy;override;
      property    HorzDirection:byte read fHDirection write fHDirection;
      property    VertDirection:byte read fVdirection write fVDirection;
      property    Angle:single read fAngle write fAngle;
      property    Step:single read fStep write fStep;
      property    MaxStep:single read fMaxStep write fMaxStep;
      property    Launched:boolean read fLaunched write fLaunched;
      property    BallSize:byte read fBallSize write fBallSize;
    end;



  // SapceBallz game class
  type
    TSpaceBallz= class(TDummy)
      private
       fDlgUp:boolean;
       fGameRunning:Boolean;
       fLoopDone:TEvent;
       fMat:TDlgMaterial;
       fGameTmr:TInertiaTimer;
       fIm:TImage3d;
       fTxt:TText3d;
       fNumBalls:byte;
       fBalls:Array of TSpaceBall;
       fSlideLeftBtn:TDlgButton;
       fLeftY:single;
       fSlideRightBtn:TDlgButton;
       fLeftPaddle:TRectangle3d;
       fRightPaddle:TRectangle3d;
       fGameClock:tDlgButton;
       fGameBest:tDlgButton;
       fClockTick:byte;
       fSecs:byte;
       fMins:word;
       fBestTime:word;
       fStartDelay:byte;
       fBtnStart:tDlgButton;
       fBtnClose:tDlgButton;
       fBtnBalls:tDlgInputButton;
       fBtnBallSize:tDlgInputButton;
       fBtnPaddleSize:tDlgInputButton;
       fBallAreaTop:single;
       fBallAreaBottom:single;
       fBallAreaLeft:single;
       fBallAreaRight:single;
       fBallMaxSize:single;
       fPaddleMaxSize:single;
       fPaddleSize:byte;
       fBallSize:byte;
       fWebTxt:TText3d;
       fCloseOnce:boolean;
       fCloseEvent:TDlgDoneClick_Event;
       fCleanedUp:boolean;
      protected
       procedure StartGame(sender:tObject);
       procedure EndGame;
       procedure GameStep(sender:tObject);
       function  PaddleCollision(aSide:byte;aY:single;aBall:integer):boolean;
       procedure MoveLeftSlide(Y:single);
       procedure MoveRightSlide(Y:single);
       procedure DoClose(sender:tObject);
       procedure DoNumBalls(sender:tObject);
       procedure NumBallsDone(sender:tObject);
       procedure ReSizeBalls;
       procedure TogPaddleSize(sender:tObject);
       procedure TogBallSize(sender:tObject);

      public
       Constructor Create(Sender: TComponent;aWidth,aHeight,aX,aY:single);Reintroduce;
       procedure   CleanUp;
       Destructor  Destroy;override;
       Procedure   MovePaddles(lY:single;rY:single);
       property    OnClose:TDlgDoneClick_Event read fCloseEvent write fCloseEvent;
       property    CleanedUp:boolean read fCleanedUp;
    end;



implementation

uses dmMaterials,uGlobs;

Constructor TSpaceBall.Create(aOwner: TComponent; aWidth: Single; aHeight: Single; ax: Single; ay: Single);
begin
  //create
  Inherited Create(aOwner);
  //set our cam first always!!!
  Projection:=TProjection.Screen;
  Width:=aWidth;
  Height:=aHeight;
  Position.X:=ax;
  Position.Y:=ay;
  Position.Z:=aWidth;
  Opacity:=0.95;
  fHDirection:=0;
  fVDirection:=0;
  fAngle:=0;
  fStep:=2;
  fMaxStep:=10;
  fLastY:=0;
  fBallSize:=1;


end;

Destructor TSpaceBall.Destroy;
begin
//free all

  Inherited;
end;



Constructor TSpaceBallz.Create(Sender: TComponent;aWidth,aHeight,aX,aY:single);
var
aGap:Single;
aBtnWidth,aBtnHeight:single;
aSlideW,aSlideH:single;
newx,newy:single;
i:integer;

begin
  //create
  Inherited Create(nil);
  fCleanedUp:=false;
  fDlgUp:=False;
  fGameRunning:=false;
  fLoopDone:=TEvent.Create(nil,true,true,'');
  //set our cam first always!!!
  Projection:=TProjection.Screen;
  Parent:=TForm3d(sender);
  fMat:=dlgMaterial;
  fGameTmr:=TInertiaTimer.Create;
  fGameTmr.Interval:=10;
  fGameTmr.OnTimer:=GameStep;
  Width:=aWidth;
  Height:=aHeight;
  Position.X:=aX;
  Position.Y:=aY;
  aGap:=2;
  fCloseOnce:=false;
  HitTest:=False;
  fNumBalls:=2;
  fBallSize:=1;
  fPaddleSize:=1;

  //space.. make it deep...
  //increase im's w h in porportion to z
  fIm:=TImage3d.Create(nil);
  fIm.Projection:=tProjection.Screen;

  fIm.Bitmap:=MaterialsDm.tmStarsImg.Texture;
  fIm.Position.Z:=1500;
  fIm.Width:=aWidth+1500;
  if GoFullScreen then
  fIm.Height:=aHeight+1700 else
  fIm.Height:=aHeight+1500;
  fIm.Position.X:=aX;
  fIm.Position.Y:=aY;
  fIm.HitTest:=false;

  fIm.Parent:=self;

  //8 btns wide by 12 tall
  aBtnWidth:=(Width/8);
  aBtnHeight:=(Height/12)-aGap;
  aSlideW:=aBtnWidth-aGap;
  aSlideH:=Height-(aBtnHeight*2);
  aBtnWidth:=aBtnWidth-aGap;



  fBallMaxSize:=aBtnHeight;
  fPaddleMaxSize:=aBtnWidth;


  SetLength(fBalls,fNumBalls);


  newy:=((Height/2)*-1)+(aBtnHeight+(aBtnHeight/2))+aBtnHeight;
  for I := Low(fBalls) to High(fBalls) do
   begin
   fBalls[i]:=TSpaceBall.Create(self,aBtnHeight/2,aBtnHeight/2,0,newy);
   fBalls[i].Projection:=tProjection.Screen;
   fBalls[i].Angle:=1;
   fBalls[i].VertDirection:=0;
   if Odd(i+1) then
     fBalls[i].HorzDirection:=0 else
       fBalls[i].HorzDirection:=1;
   MaterialsDm.tmGlobeImg.Texture.FlipVertical;
   fBalls[i].MaterialSource:=MaterialsDm.tmGlobeImg;
   fBalls[i].Parent:=self;
   end;

     //top play area
    fBallAreaTop:=((Height/2)*-1)+fBalls[0].Height+aBtnHeight+aGap;

  newy:=0;
  newx:=((Width/2)*-1)+(aSlideW/2)+aGap;//left

     //left slide control
      fSlideLeftBtn:=tDlgButton.Create(self,aSlideW,aSlideH,newx,newy);
      fSlideLeftBtn.Projection:=TProjection.Screen;
      fSlideLeftBtn.Parent:=self;
      fSlideLeftBtn.MaterialSource:=MaterialsDm.tmSlides;
      fSlideLeftBtn.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fSlideLeftBtn.FontSize:=dlgMaterial.FontSize;
      fSlideLeftBtn.BtnBitMap.Assign(MaterialsDm.tmSlides.Texture);
      fSlideLeftBtn.Rotated:=true;
      fSlideLeftBtn.HitTest:=false;

    //left paddle
      newx:=newx+aSlideW+(aBtnHeight/4)+aGap;
      fLeftPaddle:=tRectangle3d.Create(self);
      fLeftPaddle.Projection:=tProjection.Screen;
      fLeftPaddle.Width:=aBtnHeight/2;
      fLeftPaddle.Height:=aBtnWidth/2;
      fLeftPaddle.Depth:=1;
      fLeftPaddle.Parent:=self;
      fLeftPaddle.Sides:=[TExtrudedShapeSide.Front];
      fLeftPaddle.Position.X:=newx;
      fLeftPaddle.Position.Y:=newy;
      fLeftPaddle.MaterialSource:=MaterialsDM.tmPaddleImg;
      fLeftY:=newY;

      fBallAreaLeft:=Newx+fLeftPaddle.Width;

      newx:=((Width/2))-(aSlideW/2)-aGap;//right
      //right slide control
      fSlideRightBtn:=tDlgButton.Create(self,aSlideW,aSlideH,newx,newy);
      fSlideRightBtn.Projection:=TProjection.Screen;
      fSlideRightBtn.Parent:=self;
      fSlideRightBtn.MaterialSource:=MaterialsDm.tmSlides;
      fSlideRightBtn.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fSlideRightBtn.FontSize:=dlgMaterial.FontSize;
      fSlideRightBtn.BtnBitMap.Assign(MaterialsDm.tmSlides.Texture);
      fSlideRightBtn.Rotated:=true;
      //right paddle
      newx:=newx-aSlideW-(aBtnHeight/4)-aGap;
      fRightPaddle:=tRectangle3d.Create(self);
      fRightPaddle.Projection:=tProjection.Screen;
      fRightPaddle.Width:=aBtnHeight/2;
      fRightPaddle.Height:=aBtnWidth/2;
      fRightPaddle.Depth:=1;
      fRightPaddle.Parent:=self;
      fRightPaddle.Sides:=[TExtrudedShapeSide.Front];
      fRightPaddle.Position.X:=newx;
      fRightPaddle.Position.Y:=newy;
      fRightPaddle.MaterialSource:=MaterialsDM.tmPaddleImg;
      fLeftY:=newY;

      fBallAreaRight:=newx-fRightPaddle.Width;

      newy:=((Height/2)*-1)+(aBtnHeight/2);//top

      //Game Clock
      fGameClock:=tDlgButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fGameClock.Projection:=TProjection.Screen;
      fGameClock.Parent:=self;
      fGameClock.MaterialSource:=dlgMaterial.Buttons.Button;
      fGameClock.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fGameClock.FontSize:=dlgMaterial.FontSize;
      fGameClock.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fGameClock.Text:='00:00';
      fGameClock.OnClick:=nil;

      newx:=(Width/2*-1)+(aBtnWidth/2)+aGap;
      newx:=newx+(aBtnWidth+aGap);
      //best time
      fGameBest:=tDlgButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fGameBest.Projection:=TProjection.Screen;
      fGameBest.Parent:=self;
      fGameBest.MaterialSource:=dlgMaterial.Buttons.Button;
      fGameBest.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fGameBest.FontSize:=dlgMaterial.FontSize;
      fGameBest.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fGameBest.Text:='00:00';
      fGameBest.OnClick:=nil;




      newy:=((Height/2))-((aBtnHeight/2)+(Height/55)+(aGap*2));
      fBallAreaBottom:=newy-fBalls[0].Height;


      newx:=((Width/2))-(aSlideW/2)-aGap;//right
      newx:=newx-aSlideW-(aBtnHeight/4)-aGap;
      aBtnHeight:=aBtnHeight+(Height/55);
      newy:=((Height/2))-((aBtnHeight/2)+(aGap));//bottom
      //close is in bottom right
      fBtnClose:=tDlgButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fBtnClose.Projection:=TProjection.Screen;
      fBtnClose.Parent:=self;
      fBtnClose.MaterialSource:=dlgMaterial.Buttons.Button;
      fBtnClose.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fBtnClose.FontSize:=dlgMaterial.FontSize;
      fBtnClose.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fBtnClose.Text:='Close';
      fBtnClose.OnClick:=DoClose;

      //now bottom left
      newx:=(Width/2*-1)+(aBtnWidth/2)+aGap;
      newx:=newx+(aBtnWidth+aGap);

      fBtnStart:=tDlgButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fBtnStart.Projection:=TProjection.Screen;
      fBtnStart.Parent:=self;
      fBtnStart.MaterialSource:=dlgMaterial.Buttons.Button;
      fBtnStart.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fBtnStart.FontSize:=dlgMaterial.FontSize;
      fBtnStart.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fBtnStart.Text:='Start';
      fBtnStart.OnClick:=StartGame;
      newx:=newx+(aBtnWidth+aGap);

      fBtnBalls:=tDlgInputButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fBtnBalls.Projection:=TProjection.Screen;
      fBtnBalls.Parent:=self;
      fBtnBalls.MaterialSource:=dlgMaterial.Buttons.Button;
      fBtnBalls.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fBtnBalls.FontSize:=dlgMaterial.FontSize;
      fBtnBalls.LabelSize:=dlgMaterial.FontSize/1.2;
      fBtnBalls.LabelColor:=dlgMaterial.TextColor.Color;
      fBtnBalls.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fBtnBalls.LabelText:='# Balls';
      fBtnBalls.Text:=IntToStr(fNumBalls);
      fBtnBalls.OnClick:=DoNumBalls;
      newx:=newx+(aBtnWidth+aGap);

      fBtnBallSize:=tDlgInputButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fBtnBallSize.Projection:=TProjection.Screen;
      fBtnBallSize.Parent:=self;
      fBtnBallSize.MaterialSource:=dlgMaterial.Buttons.Button;
      fBtnBallSize.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fBtnBallSize.FontSize:=dlgMaterial.FontSize;
      fBtnBallSize.LabelSize:=dlgMaterial.FontSize/1.2;
      fBtnBallSize.LabelColor:=dlgMaterial.TextColor.Color;
      fBtnBallSize.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fBtnBallSize.LabelText:='Ball Size';
      fBtnBallSize.Text:='Medium';
      fBtnBallSize.OnClick:=TogBallSize;

      newx:=newx+(aBtnWidth+aGap);
      fBtnPaddleSize:=tDlgInputButton.Create(self,aBtnWidth,aBtnHeight,newx,newy);
      fBtnPaddleSize.Projection:=TProjection.Screen;
      fBtnPaddleSize.Parent:=self;
      fBtnPaddleSize.MaterialSource:=dlgMaterial.Buttons.Button;
      fBtnPaddleSize.TextColor:=dlgMaterial.Buttons.TextColor.Color;
      fBtnPaddleSize.FontSize:=dlgMaterial.FontSize;
      fBtnPaddleSize.LabelSize:=dlgMaterial.FontSize/1.2;
      fBtnPaddleSize.LabelColor:=dlgMaterial.TextColor.Color;
      fBtnPaddleSize.BtnBitMap.Assign(dlgMaterial.Buttons.Rect.Texture);
      fBtnPaddleSize.LabelText:='Paddle Size';
      fBtnPaddleSize.Text:='Medium';
      fBtnPaddleSize.OnClick:=TogPaddleSize;
      newx:=newx+(aBtnWidth+aGap);





   //some text..
  fTxt:=TText3d.Create(nil);
  fTxt.Projection:=tProjection.Screen;
  fTxt.Parent:=self;
  fTxt.Depth:=2;
  fTxt.Stretch:=true;
  fTxt.WordWrap:=false;
  fTxt.Width:=Width/8;
  fTxt.Height:=Height/55;
  fTxt.Position.X:=((Width/2)*-1)+(fTxt.Width/2)+(aGap);
  fTxt.Position.Y:=((Height/2))-(fTxt.Height);
  fTxt.Position.Z:=-1;
  fTxt.Text:='Delphi-Future coded.'; //happy birthday delphi!!!
  fTxt.MaterialSource:=MaterialsDm.tmGold;
  fTxt.MaterialBackSource:=MaterialsDm.tmGold;
  fTxt.MaterialShaftSource:=MaterialsDm.tmGold;
  fTxt.OnClick:=DoClose;
  fTxt.Visible:=true;

  fWebTxt:=TText3d.Create(nil);
  fWebTxt.Projection:=tProjection.Screen;
  fWebTxt.Parent:=self;
  fWebTxt.Depth:=2;
  fWebTxt.Stretch:=true;
  fWebTxt.Width:=Width/8;
  fWebTxt.Height:=Height/55;
  fWebTxt.WordWrap:=false;
  fWebTxt.Position.X:=((Width/2)-(fWebTxt.Width/2))-aGap;
  fWebTxt.Position.Y:=((Height/2))-(fWebTxt.Height);
  fWebTxt.Position.Z:=-1;
  fWebTxt.Text:='www.qubits.us';
  fWebTxt.MaterialSource:=MaterialsDm.tmGold;
  fWebTxt.MaterialBackSource:=MaterialsDm.tmGold;
  fWebTxt.MaterialShaftSource:=MaterialsDm.tmGold;
  fWebTxt.OnClick:=DoClose;
  fWebTxt.Visible:=true;
   //not running yet
  fGameRunning:=false;




end;

Destructor TSpaceBallz.Destroy;
begin

  if not fCleanedUp then CleanUp;


  Inherited;
end;

procedure TSpaceBallz.CleanUp;
var
i:integer;
begin
  //destroy
  if fCleanedUp then exit;

  fCleanedUp:=true;





  fGameTmr.Enabled:=false;
  fLoopDone.WaitFor(1000);
  fGameTmr.Free;
  fLoopDone.Free;


  for I := Low(fBalls) to High(fBalls) do
     fBalls[i].Free;




  fGameClock.CleanUp;
  fGameClock.Free;
  fGameClock:=nil;

  fGameBest.CleanUp;
  fGameBest.Free;
  fGameBest:=nil;

  fSlideLeftBtn.CleanUp;
  fSlideLeftBtn.Free;
  fSlideLeftBtn:=nil;

  fLeftPaddle.Free;

  fSlideRightBtn.CleanUp;
  fSlideRightBtn.Free;
  fSlideRightBtn:=nil;

  fRightPaddle.Free;


  fBtnClose.CleanUp;
  fBtnClose.Free;
  fBtnClose:=nil;

  fBtnStart.CleanUp;
  fBtnStart.Free;
  fBtnStart:=nil;


  fBtnBalls.CleanUp;
  fBtnBalls.Free;
  fBtnBalls:=nil;

  fBtnBallSize.CleanUp;
  fBtnBallSize.Free;
  fBtnBallSize:=nil;

  fBtnPaddleSize.CleanUp;
  fBtnPaddleSize.Free;
  fBtnPaddleSize:=nil;

  fIm.Parent:=nil;
  fIm.OnClick:=nil;
  fIm.Bitmap:=nil;

  fIm.Free;
  fIm:=nil;



  fWebTxt.Text:='';
  fWebTxt.MaterialBackSource:=nil;
  fWebTxt.MaterialShaftSource:=nil;
  fWebTxt.MaterialSource:=nil;
  fWebTxt.Parent:=nil;
  fWebTxt.OnClick:=nil;
  fWebTxt.Free;
  fWebTxt:=nil;

  fTxt.Text:='';
  fTxt.MaterialBackSource:=nil;
  fTxt.MaterialShaftSource:=nil;
  fTxt.MaterialSource:=nil;
  fTxt.Parent:=nil;
  fTxt.OnClick:=nil;
  fTxt.Free;
  fTxt:=nil;

  fCloseEvent:=nil;
  Parent:=nil;

end;


procedure TSpaceBallz.DoClose(sender: TObject);
begin
if fCloseOnce then exit;//only one time please
  fCloseOnce:=true;

  if Assigned(fCloseEvent) then
      fCloseEvent(nil);
end;

procedure TSpaceBallz.DoNumBalls(sender: TObject);
begin
  //open up a numsel..
if fDlgUp then exit;
if fGameRunning then exit;

     if not assigned(NumSelDlg) then
        begin
          NumSelDlg:=tDlgNumSel.Create(self,fmat,height,height/1.25,Width/2,Height/2);
          NumSelDlg.OnDone:=NumBallsDone;
          NumSelDlg.Parent:=self.Parent;
          NumSelDlg.Position.Z:=-2;
          NumSelDlg.Opacity:=0.85;
          NumSelDlg.Visible:=true;
          fDlgUp:=true;
        end;

end;

procedure TSpaceBallz.NumBallsDone(sender: TObject);
begin
      fNumBalls:=NumSelDlg.Num;
      fBtnBalls.Text:=IntToStr(fNumBalls);
      NumSelDlg.Visible:=false;
      Tron.KillNumSel;
      fDlgUp:=false;
end;

procedure TSpaceBallz.ReSizeBalls;
var
i:integer;
aSize,newY:single;
aLaunchDelay:word;
begin
  //
    aSize:=fBallMaxSize;
     case fBallSize of
     0:aSize:=fBallMaxSize/3;
     1:aSize:=fBallMaxSize/2;
     3:aSize:=fBallMaxSize;
     end;

  for I := Low(fBalls) to High(fBalls) do
      fBalls[i].Free;
    SetLength(fBalls,0);

  SetLength(fBalls,fNumBalls);

  aLaunchDelay:=10;
  newy:=((Height/2)*-1)+((aSize*3)+(aSize));
  for I := Low(fBalls) to High(fBalls) do
   begin
   fBalls[i]:=TSpaceBall.Create(self,aSize,aSize,0,newy);
   fBalls[i].Projection:=tProjection.Screen;
   fBalls[i].Angle:=1;
   fBalls[i].VertDirection:=0;
   fBalls[i].Position.Z:=aSize;
   fBalls[i].fLaunchDelay:=aLaunchDelay*i;
   MaterialsDm.tmGlobeImg.Texture.FlipVertical;//look different
   fBalls[i].MaterialSource:=MaterialsDm.tmGlobeImg;
   fBalls[i].BallSize:=fBallSize;
   fBalls[i].Parent:=self;
   end;
end;


procedure TSpaceBallz.TogPaddleSize(sender: TObject);
begin
  if fPaddleSize<2 then Inc(fPaddleSize) else fPaddleSize:=0;

   case fPaddleSize of
   0:begin
      fBtnPaddleSize.Text:='Small';
      fLeftPaddle.Height:=fPaddleMaxSize/3;
      fRightPaddle.Height:=fPaddleMaxSize/3;
     end;
   1:begin
      fBtnPaddleSize.Text:='Medium';
      fLeftPaddle.Height:=fPaddleMaxSize/2;
      fRightPaddle.Height:=fPaddleMaxSize/2;
     end;
   2:begin
      fBtnPaddleSize.Text:='Large';
      fLeftPaddle.Height:=fPaddleMaxSize;
      fRightPaddle.Height:=fPaddleMaxSize;
     end;
   end;

end;



procedure TSpaceBallz.TogBallSize(sender: TObject);
begin
  if fBallSize<2 then Inc(fBallSize) else fBallSize:=0;

   case fBallSize of
   0:begin
      fBtnBallSize.Text:='Small';
     end;
   1:begin
      fBtnBallSize.Text:='Medium';
     end;
   2:begin
      fBtnBallSize.Text:='Large';
     end;
   end;

end;


procedure TSpaceBallz.StartGame(sender:tObject);
var
i:integer;
aHd:byte;
aSize:single;
begin
if fDlgUp then exit;
if fGameRunning then
begin
EndGame;
exit;
end;

    aSize:=fBallMaxSize;

     case fBallSize of
     0:aSize:=fBallMaxSize/3;
     1:aSize:=fBallMaxSize/2;
     3:aSize:=fBallMaxSize;
     end;


  fSecs:=0;
  fMins:=0;
  fClockTick:=0;
  fGameClock.Text:='00:00';
  fStartDelay:=50;
  aHd:=0;//horz dir
  if Length(fBalls)<>fNumBalls then ResizeBalls;



  for I := Low(fBalls) to High(fBalls) do
   begin
    fBalls[i].Position.Y:=fBallAreaTop;
    fBalls[i].Position.X:=0;
    fBalls[i].Angle:=1;
    fBalls[i].fHDirection:=aHd;
    fBalls[i].fVDirection:=0;
    fBalls[i].fLaunchDelay:=i*10;
    fBalls[i].Step:=2;
    fBalls[i].Launched:=false;
    if fBalls[i].BallSize<>fBallSize then
       begin
         fBalls[i].Width:=aSize;
         fBalls[i].Height:=aSize;
         fBalls[i].Position.Z:=aSize;
         fBalls[i].BallSize:=fBallSize;
       end;
    if aHd=0 then aHd:=1 else aHd:=0;
   end;

  fBtnBalls.Visible:=false;
  fBtnBallSize.Visible:=false;
  fBtnPaddleSize.Visible:=false;
  fBtnStart.Text:='Stop';


  //start game timer
  fGameTmr.Enabled:=true;
  fGameRunning:=true;


end;


procedure TSpaceBallz.EndGame;
var
i:integer;
aHd:byte;
aGT:word;
begin
  fGameTmr.Enabled:=false;
   aHd:=0;//horz dir
  for I := Low(fBalls) to High(fBalls) do
   begin
    fBalls[i].Position.Y:=fBallAreaTop;
    fBalls[i].Position.X:=0;
    fBalls[i].Angle:=1;
    fBalls[i].fHDirection:=aHd;
    fBalls[i].fVDirection:=0;
    if aHd=0 then aHd:=1 else aHd:=0;
   end;
 fGameRunning:=false;

    aGT:=fMins*60+fSecs;
    if aGT>fBestTime then
      begin
      fBestTime:=aGT;
      fGameBest.Text:=Format('%.2d',[fMins])+':'+Format('%.2d',[FSecs]);
      end;

   fBtnBalls.Visible:=true;
   fBtnBallSize.Visible:=true;
   fBtnPaddleSize.Visible:=true;
   fBtnStart.Text:='Start';

end;

procedure TSpaceBallz.GameStep(sender: TObject);
var
aX:single;
aY:single;
i:integer;
begin
  //step the game

    fLoopDone.ResetEvent;
 try

  if fStartDelay>0 then
     begin
       Dec(fStartDelay);
       exit;
     end;



     if fClockTick<99 then Inc(fClockTick) else
       begin
       fCLockTick:=0;
       if fSecs<60 then Inc(fSecs) else
        begin
         Inc(fMins);
         fSecs:=0;
         end;

         fGameClock.Text:=Format('%.2d',[fMins])+':'+Format('%.2d',[FSecs]);

       end;



 for I := Low(fBalls) to High(fBalls) do
  begin
  if fBalls[i].Launched then
   begin
    if fBalls[i].HorzDirection=0 then
       begin
        aX:=fBalls[i].Position.X-fBalls[i].fStep;
        if aX<=fBallAreaLeft then
          begin
          //check for left paddle collision
          if PaddleCollision(0,fBalls[i].Position.Y,i) then
           begin
            fBalls[i].HorzDirection:=1;
            aX:=aX+fBalls[i].fStep;
            fBalls[i].Position.X:=aX;
           end else EndGame;
          end else
            begin
             fBalls[i].Position.X:=ax;
             if fBalls[i].VertDirection=0 then
             aY:=fBalls[i].Position.Y+fBalls[i].Angle else
             aY:=fBalls[i].Position.Y-fBalls[i].Angle;
             if (aY>=fBallAreaBottom) or (aY<=fBallAreaTop) then
             begin
               //change vert direction
               if fBalls[i].VertDirection=0 then fBalls[i].VertDirection:=1 else fBalls[i].VertDirection:=0;

             end else fBalls[i].Position.Y:=ay;

            end;


       end else
         begin
          aX:=fBalls[i].Position.X+fBalls[i].fStep;
          if aX>=fBallAreaRight then
            begin
            //check for right paddle collision
            if PaddleCollision(1,fBalls[i].Position.Y,i) then
             begin
             fBalls[i].HorzDirection:=0;
             aX:=aX-fBalls[i].fStep;
             fBalls[i].Position.X:=aX;
             end else EndGame;
            end else
            begin
             fBalls[i].Position.X:=ax;
             if fBalls[i].VertDirection=0 then
             aY:=fBalls[i].Position.Y+fBalls[i].Angle else
             aY:=fBalls[i].Position.Y-fBalls[i].Angle;
             if (aY>=fBallAreaBottom) or (aY<=fBallAreaTop) then
             begin
               //change vert direction
               if fBalls[i].VertDirection=0 then fBalls[i].VertDirection:=1 else fBalls[i].VertDirection:=0;

             end else fBalls[i].Position.Y:=ay;
            end;

         end;
   end else
     begin
       if fBalls[i].fLaunchDelay>0 then
         Dec(fBalls[i].fLaunchDelay) else fBalls[i].Launched:=true;
     end;
  end;


 finally
   fLoopDone.SetEvent;
 end;

end;

function TSpaceBallz.PaddleCollision(aSide: Byte; aY: Single;aBall:integer): Boolean;
var
aTop,aBottom:single;
begin
//
  result:=false;
   if aSide=0 then
      begin
      //check left
      aTop:=fLeftPaddle.Position.Y+fLeftPaddle.Height/2;
      aBottom:=fLeftPaddle.Position.Y-fLeftPaddle.Height/2;
      if (aY>=aBottom) and (aY<=aTop) then
      begin
       result:=true;
       if (aY>=(fLeftPaddle.Position.Y-fBalls[aBall].Height)) and (aY<=(fLeftPaddle.Position.Y+fBalls[aBall].Height)) then
       begin
        fBalls[aBall].Angle:=1;
        if fBalls[aBall].fLastY<>aY then
          fBalls[aBall].fLastY:=aY else
              fBalls[aBall].Angle:=0.5;

        fBalls[aBall].fStep:=fBalls[aBall].fStep*2;
        if fBalls[aBall].fStep>fBalls[aBall].fMaxStep then fBalls[aBall].fStep:=fBalls[aBall].fMaxStep;

        end else
         begin
         fBalls[aBall].Angle:=2;
         fBalls[aBall].fStep:=2;
         if aY>fLeftPaddle.Position.Y then fBalls[aBall].VertDirection:=0 else fBalls[aBall].VertDirection:=1;
         end;

      end;
      end else
        begin
        //check right
        aTop:=fRightPaddle.Position.Y+fRightPaddle.Height/2;
        aBottom:=fRightPaddle.Position.Y-fRightPaddle.Height/2;
         if (aY>=aBottom) and (aY<=aTop) then
         begin
          result:=true;
          if (aY>=(fRightPaddle.Position.Y-fBalls[aBall].Height)) and (aY<=(fRightPaddle.Position.Y+fBalls[aBall].Height)) then
           begin
           fBalls[aBall].Angle:=1;
            if fBalls[aBall].fLastY<>aY then
                   fBalls[aBall].fLastY:=aY else
                        fBalls[aBall].Angle:=0.5;
           fBalls[aBall].fStep:=fBalls[aBall].fStep*2;
           if fBalls[aBall].fStep>fBalls[aBall].fMaxStep then fBalls[aBall].fStep:=fBalls[aBall].fMaxStep;
           end else
            begin
            fBalls[aBall].Angle:=2;
            fBalls[aBall].fStep:=2;
            if aY>fRightPaddle.Position.Y then fBalls[aBall].VertDirection:=0 else fBalls[aBall].VertDirection:=1;
            end;
         end;
        end;

end;


procedure TSpaceBallz.MoveLeftSlide(Y: Single);
begin
   fLeftPaddle.Position.Y:=Y;
end;


procedure TSpaceBallz.MoveRightSlide(Y: Single);
begin
   fRightPaddle.Position.Y:=Y;
end;

procedure TSpaceBallz.MovePaddles(lY: Single; rY: Single);
begin
   fLeftPaddle.Position.Y:=lY;
   fRightPaddle.Position.Y:=rY;
end;


end.
