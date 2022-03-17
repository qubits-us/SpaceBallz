unit uSceneLeaderBoard;


{Leader Board for SpaceBallz Tournaments Server
 created:2.18.2022 q



 be it harm none, do as ye wishes..


}



interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts,FMX.Layers3D,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, System.Math.Vectors, FMX.Ani, FMX.Controls3D,
  FMX.MaterialSources, FMX.Objects3D, FMX.Effects, FMX.Filter.Effects,uDlg3dCtrls;




type
TDlgLeaderBoard = class(TDummy)
  private
    fDlgUp:boolean;
    fTopLeftBtn:tDlgInputButton;
    fTopMiddleBtn:tDlgInputButton;
    fTopRightBtn:tDlgInputButton;
    //array of gamerz.. 4x3
    fGamerz: array of TDlgInputButton;
    fBottomLeftBtn:tDlgButton;
    fBottomMiddleBtn:tDlgButton;
    fBottomRightBtn:tDlgInputButton;
    fMenuMat:TDlgMaterial;
    fCurrentMenu:integer;
    fSelectedGamer:integer;
    fMenuSelect:tDlgSelect_Event;
    fCleanedUp:Boolean;
    fBottomField:tImage3d;
    fTopField:tImage3d;
    fIm:TImage3d;
    fIm2:TImage3d;
    fImAni:TBitmapAnimation;//merge
    fImFa1:TFloatAnimation;//slides
    fImFa2:TFloatAnimation;
    fAniType:byte;//0=none 1=slide 2=merge
    fOnClose:tDlgClick_Event;
  protected
    function    GetKey(aKeyNum:integer):TDlgInputButton;
    procedure   SetKey(aKeyNum:integer;value:TDlgInputButton);
    procedure   btnClick(sender:tObject);
    procedure   SetAniType(aValue:byte);
    procedure   fa1SlideImFinished(sender:tobject);
    procedure   fa2SlideImFinished(sender:tobject);
    procedure   ChangeText(aValue:integer);
    procedure   DoClose(sender:tObject);
    procedure   DoConfig(sender:tObject);
    procedure   DoGamerMenu(sender:tObject);
    procedure   GamerMenuClose(sender:tObject;menu:integer);
    procedure   PromptClearHash;
    procedure   DoClearHash(sender:tObject;sel:integer);
    procedure   PromptClearGamer;
    procedure   DoClearGamer(sender:tObject;sel:integer);
    procedure   DoTournMenu(sender:tObject);
    procedure   TournMenuClose(sender:tObject;menu:integer);
    procedure   ConfigCancel(sender:tObject);
    procedure   ConfigDone(sender:tobject);
    procedure   UpdateBoard(sender:tObject);
    procedure   PromptClearHashes;
    procedure   DoClearHashes(sender:tObject;sel:integer);
    procedure   PromptClearGamerz;
    procedure   DoClearGamerz(sender:tObject;sel:integer);
  public
    procedure   StartAni;
    procedure   StopAni;
    constructor Create(aOwner:TComponent;aMenuMat:TDlgMaterial;
                    aWidth,aHeight,aX,aY:single); reintroduce;
    destructor  Destroy;override;
    procedure   CleanUp;
    property    Keys[index:integer]:TDlgInputButton read GetKey write SetKey;
    property    OnSelect:TDlgSelect_Event read fMenuSelect write fMenuSelect;
    property    BackIm:TImage3d read fim write fim;
    property    AniType:byte read fAniType write SetAniType;
    property    OnClose:TDlgClick_Event read fOnClose write fOnClose;
end;





implementation

uses dmMaterials,uGlobs,uSpaceBallzData,uIndySBPacketServer,uDlg3dTextures;






constructor TDlgLeaderBoard.Create(aOwner: TComponent;aMenuMat:TDlgMaterial;
           aWidth: Single;aHeight: Single; aX: Single; aY: Single);
var
i:integer;
newx,newy:single;
aButtonHeight,aButtonWidth:single;
aColGap,aRowGap:single;
SectionHeight:single;
ah,af,ap:single;
numpadStart:single;
tmpBitmap:tBitmap;
begin

  inherited Create(aOwner);
  //set our cam first always!!!
  fCleanedUp:=false;
  Projection:=TProjection.Screen;
  fDlgUp:=False;


  fMenuMat:=aMenuMat;
  fSelectedGamer:=-1;

  //set w,h and pos
  Width:=aWidth;
  Height:=aHeight;
  Position.X:=aX;
  Position.Y:=aY;
  Depth:=1;
  fAniType:=0;//none
  Opacity:=0.85;
  fImAni:=nil;
  fImFa1:=nil;
  fImFa2:=nil;



  fIm:=TImage3d.Create(self);
  fIm.Projection:=tProjection.Screen;
  fIm.Bitmap:=aMenuMat.BackImage;
  fIm.Width:=aWidth;
  fIm.Height:=aHeight;
  fIm.HitTest:=false;
  fIm.Position.X:=0;
  fIm.Position.Y:=0;
  fIm.Position.Z:=0;
  fIm.Parent:=self;
  fIm.Visible:=true;

  fIm2:=TImage3d.Create(self);
  fIm2.Projection:=tProjection.Screen;
  fIm2.Bitmap:=aMenuMat.BackImage;
  fIm2.Width:=aWidth;
  fIm2.Height:=aHeight;
  fIm2.HitTest:=false;
  fIm2.Position.X:=(Width);//offscreen -->
  fIm2.Position.Y:=0;
  fIm2.Position.Z:=0;
  fIm2.Parent:=self;
  fIm2.Visible:=false;

  //Opacity:=0.85;
  if Width>600 then
  SectionHeight:=80 else
  SectionHeight:=50;

  aColGap:=2;
  aRowGap:=2;
  aButtonWidth:=aWidth/3;//divide width by max keys in a row
  aButtonWidth:=aButtonWidth-(aColGap)-(aColGap/4);

  fMenuMat.FontSize:=32;

  ah:=Height / (6);// devide height by number of rows..
  SectionHeight:=ah;
  SectionHeight:=SectionHeight-(aRowGap)-(aRowGap/6);

if SectionHeight>(aButtonWidth+aColGap) then
   begin
     ah:=SectionHeight-(aButtonWidth+aColGap);
     SectionHeight:=SectionHeight-(ah/2);
   end;


//change font size..
  if SectionHeight>79 then
    begin
     fMenuMat.FontSize:=32;
    end else
    begin
      fMenuMat.FontSize:=24;
    end;

  if SectionHeight>100 then
     begin
     fMenuMat.FontSize:=36;
     end;




   newy:=((aHeight/2)*-1)+(SectionHeight/2)+aRowGap;//top
   newx:=((aWidth/2)*-1)+(aButtonWidth/2)+aColGap;//left

    fTopLeftBtn:=tDlgInputButton.Create(self,aButtonWidth,SectionHeight,newx,newy);
    fTopLeftBtn.Projection:=TProjection.Screen;
    fTopLeftBtn.Parent:=self;
 //   fTopLeftBtn.MaterialSource:=fMenuMat.Buttons.Rect;
    fTopLeftBtn.TextColor:=fMenuMat.Buttons.TextColor.Color;
    fTopLeftBtn.FontSize:=fMenuMat.FontSize;
    fTopLeftBtn.LabelColor:=fMenuMat.Buttons.TextColor.Color;
    fTopLeftBtn.LabelSize:=fMenuMat.FontSize/1.25;
  //  fTopLeftBtn.BtnBitMap.Assign(fMenuMat.Buttons.Rect.Texture);
    fTopLeftBtn.LabelText:='Server IP';
    fTopLeftBtn.Text:=ServerIP;
    fTopLeftBtn.Opacity:=0.85;
    fTopLeftBtn.OnClick:=btnClick;
    newx:=newx+aButtonWidth+aColGap;

    fTopMiddleBtn:=tDlgInputButton.Create(self,aButtonWidth,SectionHeight,newx,newy);
    fTopMiddleBtn.Projection:=TProjection.Screen;
    fTopMiddleBtn.Parent:=self;
   // fTopMiddleBtn.MaterialSource:=fMenuMat.Buttons.Rect;
    fTopMiddleBtn.TextColor:=fMenuMat.Buttons.TextColor.Color;
    fTopMiddleBtn.FontSize:=fMenuMat.FontSize;
    fTopMiddleBtn.LabelColor:=fMenuMat.Buttons.TextColor.Color;
    fTopMiddleBtn.LabelSize:=fMenuMat.FontSize/1.25;
  //  fTopMiddleBtn.BtnBitMap.Assign(fMenuMat.Buttons.Rect.Texture);
    fTopMiddleBtn.LabelText:='SpaceBallz';
    fTopMiddleBtn.Text:='Top Gamerz';
    fTopMiddleBtn.Opacity:=0.85;
    fTopMiddleBtn.OnClick:=nil;
    newx:=newx+aButtonWidth+aColGap;

    fTopRightBtn:=tDlgInputButton.Create(self,aButtonWidth,SectionHeight,newx,newy);
    fTopRightBtn.Projection:=TProjection.Screen;
    fTopRightBtn.Parent:=self;
   // fTopRightBtn.MaterialSource:=fMenuMat.Buttons.Rect;
    fTopRightBtn.TextColor:=fMenuMat.Buttons.TextColor.Color;
    fTopRightBtn.FontSize:=fMenuMat.FontSize;
    fTopRightBtn.LabelColor:=fMenuMat.Buttons.TextColor.Color;
    fTopRightBtn.LabelSize:=fMenuMat.FontSize/1.25;
  //  fTopRightBtn.BtnBitMap.Assign(fMenuMat.Buttons.Rect.Texture);
    fTopRightBtn.LabelText:='Port';
    fTopRightBtn.Text:=ServerPort;
    fTopRightBtn.Opacity:=0.85;
    fTopRightBtn.OnClick:=btnClick;


   Newy:=newy+SectionHeight+aRowGap+10;
   newx:=((aWidth/2)*-1)+(aButtonWidth/2)+aColGap;//left

   SetLength(fGamerz,12);//12 at a time please..

  for I := Low(fGamerz) to High(fGamerz) do
   begin
    fGamerz[i]:=TDlgInputButton.Create(self,aButtonwidth,SectionHeight,newx,newy);
    fGamerz[i].Projection:=TProjection.Screen;
    fGamerz[i].Parent:=self;
    fGamerz[i].Tag:=i;
    fGamerz[i].MaterialSource:=MaterialsDm.tmGamerImg;
    fGamerz[i].TextColor:=fMenuMat.Buttons.TextColor.Color;
    fGamerz[i].FontSize:=fMenuMat.FontSize;
    fGamerz[i].LabelColor:=fMenuMat.Buttons.TextColor.Color;
    fGamerz[i].LabelSize:=fMenuMat.FontSize/1.25;
    fGamerz[i].LabelAlignment:=TAlignment.taCenter;
    fGamerz[i].TextVAlign:=TVerticalAlignment.taAlignBottom;
    fGamerz[i].BtnBitMap.Assign(MaterialsDm.tmGamerImg.Texture);
    fGamerz[i].Text:='Gamer '+IntToStr(i+1);
    fGamerz[i].LabelText:='00:00';
    fGamerz[i].Opacity:=0.85;
    fGamerz[i].Visible:=false;
    fGamerz[i].OnClick:=DoGamerMenu;

    if i in [2,5,8] then
     begin
      //CR
      newx:=((aWidth/2)*-1)+(aButtonWidth/2)+aColGap;//hard left
      newy:=newy+SectionHeight+aRowGap;//down 1
     end else
       newx:=newx+aButtonWidth+aColGap;//right 1
    end;

      newy:=newy+SectionHeight+aRowGap;//down 1
      newx:=((aWidth/2)*-1)+(aButtonWidth/2)+aColGap;//hard left

    fBottomLeftBtn:=tDlgButton.Create(self,aButtonWidth/2,SectionHeight/2,newx,newy);
    fBottomLeftBtn.Projection:=TProjection.Screen;
    fBottomLeftBtn.Parent:=self;
  //  fBottomLeftBtn.MaterialSource:=fMenuMat.Buttons.Rect;
    fBottomLeftBtn.TextColor:=fMenuMat.Buttons.TextColor.Color;
    fBottomLeftBtn.FontSize:=fMenuMat.FontSize;
 //   fBottomLeftBtn.BtnBitMap.Assign(fMenuMat.Buttons.Rect.Texture);
    fBottomLeftBtn.Text:='~';
    fBottomLeftBtn.Opacity:=0.85;
    fBottomLeftBtn.OnClick:=DoConfig;
    newx:=newx+aButtonWidth+aColGap;


    fBottomMiddleBtn:=tDlgButton.Create(self,aButtonWidth/2,SectionHeight/2,newx,newy);
    fBottomMiddleBtn.Projection:=TProjection.Screen;
    fBottomMiddleBtn.Parent:=self;
   // fBottomMiddleBtn.MaterialSource:=fMenuMat.Buttons.Rect;
    fBottomMiddleBtn.TextColor:=fMenuMat.Buttons.TextColor.Color;
    fBottomMiddleBtn.FontSize:=fMenuMat.FontSize;
  //  fBottomMiddleBtn.BtnBitMap.Assign(fMenuMat.Buttons.Rect.Texture);
    fBottomMiddleBtn.Text:='!';
    fBottomMiddleBtn.Opacity:=0.85;
    fBottomMiddleBtn.OnClick:=DoTournMenu;
    fBottomMiddleBtn.Visible:=true;

    newx:=newx+aButtonWidth+aColGap;
    fBottomRightBtn:=tDlgInputButton.Create(self,aButtonWidth/2,SectionHeight/2,newx,newy);
    fBottomRightBtn.Projection:=TProjection.Screen;
    fBottomRightBtn.Parent:=self;
   // fBottomRightBtn.Position.Z:=-1;
 //   fBottomRightBtn.MaterialSource:=MaterialsDm.tmGamerImg;
    fBottomRightBtn.TextColor:=fMenuMat.Buttons.TextColor.Color;
    fBottomRightBtn.FontSize:=fMenuMat.FontSize;
  //  fBottomRightBtn.BtnBitMap.Assign(MaterialsDm.tmGamerImg.Texture);
    fBottomRightBtn.Text:='x';
    fBottomRightBtn.Opacity:=0.85;
    fBottomRightBtn.OnClick:=DoClose;
    fBottomRightBtn.Visible:=true;

  newy:=newy-(SectionHeight/2)+10;
  fBottomField:=TImage3d.Create(self);
  fBottomField.Projection:=tProjection.Screen;
  tmpBitmap:=MakeTexture(Width,10,3,2,20,0);
  fBottomField.Bitmap.Assign(tmpBitmap);
  fBottomField.Position.Z:=-1;
  fBottomField.Width:=Width;
  fBottomField.Height:=10;
  fBottomField.Position.X:=0;//center
  fBottomField.Position.Y:=newy;
  fBottomField.HitTest:=false;
  fBottomField.Visible:=true;
  fBottomField.Parent:=self;

   newy:=((aHeight/2)*-1)+(SectionHeight)+aRowGap;//top
//   newy:=newy+SectionHeight+aRowGap;
  fTopField:=TImage3d.Create(self);
  fTopField.Projection:=tProjection.Screen;
  fTopField.Bitmap.Assign(tmpBitmap);
  fTopField.Position.Z:=-1;
  fTopField.Width:=Width;
  fTopField.Height:=10;
  fTopField.Position.X:=0;//center
  fTopField.Position.Y:=newy;
  fTopField.HitTest:=false;
  fTopField.Visible:=true;
  fTopField.Parent:=self;
  tmpBitmap.Free;





      UpdateBoard(nil);

      PacketSrv.OnGamer:=UpdateBoard;


end;


//clean up..
destructor TDlgLeaderBoard.Destroy;
var
temp:TComponent;
i:integer;
begin
  try
   if not fCleanedUp then CleanUp;
  finally
   inherited;
  end;
end;

procedure TDlgLeaderBoard.CleanUp;
var
temp:TComponent;
i:integer;
begin

    if fCleanedUp then Exit;


  try
   //all the gamerz
     for I := Low(fGamerz) to High(fGamerz) do
     begin
        fGamerz[i].OnClick:=nil;
        fGamerz[i].CleanUp;
        fGamerz[i].Free;
        fGamerz[i]:=nil;
     end;

   SetLength(fGamerz,0);
   fGamerz:=nil;

   fTopLeftBtn.CleanUp;
   fTopLeftBtn.Free;
   fTopLeftBtn:=nil;

   fTopMiddleBtn.CleanUp;
   fTopMiddleBtn.Free;
   fTopMiddleBtn:=nil;

   fTopRightBtn.CleanUp;
   fTopRightBtn.Free;
   fTopRightBtn:=nil;

   fBottomLeftBtn.CleanUp;
   fBottomLeftBtn.Free;
   fBottomLeftBtn:=nil;

   fBottomMiddleBtn.CleanUp;
   fBottomMiddleBtn.Free;
   fBottomMiddleBtn:=nil;

   fBottomRightBtn.CleanUp;
   fBottomRightBtn.Free;
   fBottomRightBtn:=nil;






   if Assigned(fImAni) then
    begin
    fImAni.Stop;
    fImAni.Enabled:=false;
    fImAni.Free;
    end;

   if Assigned(fImFa1) then
    begin
    fImFa1.Stop;
    fImFa1.Enabled:=false;
    fImFa1.Free;
    end;

   if Assigned(fImFa2) then
    begin
    fImFa2.Stop;
    fImFa2.Enabled:=false;
    fImFa2.Free;
    end;


   fBottomField.Free;
   fTopField.Free;

   fIm.Parent:=nil;
   fIm.Bitmap:=nil;
   fIm.Free;
   fIm:=nil;

   fIm2.Parent:=nil;
   fIm2.Bitmap:=nil;
   fIm2.Free;
   fIm2:=nil;

   fMenuSelect:=nil;

    fMenuMat:=nil;
    Parent:=nil;

  finally
   fCleanedUp:=true;
  end;
end;





procedure TDlgLeaderBoard.SetAniType(aValue: Byte);
begin
 if aValue>3 then exit;
 if aValue=fAniType then exit;

    StopAni;
    fAniType:=aValue;


end;

procedure TDlgLeaderBoard.StartAni;
begin
//start animations
              if fAniType=1 then
               begin

                 if not Assigned(fImFa1) then
                  begin
                  fIm2.Bitmap.Assign(fMenuMat.BackImage);
                  fIm2.Bitmap.FlipHorizontal;//magic
                  fim.Position.X:=0;
                  //im 2 just off screen
                  fim2.Position.X:=Width;
                  fim2.Visible:=true;
                  end;

                if not Assigned(fImFa1) then
                  begin
                  fImFa1:=TFloatAnimation.Create(self);
                  fImFa1.OnFinish:=fa1SlideImFinished;
                  fImFa1.StartFromCurrent:=true;
                  fImFa1.Parent:=fIm;
                  fImFa1.Duration:=120;
                  fImFa1.PropertyName:='Position.X';
                  fImFa1.StartValue:=0;
                  fImFa1.StopValue:=Width*-1;
                  fImFa1.Enabled:=true;
                  end else
                     fImFa1.Pause:=false;

                  if not Assigned(fImFa2) then
                    begin
                    fImFa2:=TFloatAnimation.Create(self);
                    fImFa2.OnFinish:=fa2SlideImFinished;
                    fImFa2.StartFromCurrent:=true;
                    fImFa2.Parent:=fim2;
                    fImFa2.Duration:=120;
                    fImFa2.PropertyName:='Position.X';
                    fImFa2.StartValue:=Width;
                    fImFa2.StopValue:=0;
                    fImFa2.Enabled:=true;
                    end else
                         fImFa2.Pause:=false;

               end else
               if fAniType=2 then
                 begin
                  if not Assigned(fImAni) then
                    begin
                    fim.Position.X:=0;
                    //im 2 just off screen
                    fim2.Position.X:=Width;
                    fim2.Visible:=False;
                    fImAni:=TBitmapAnimation.Create(fim);
                    fImAni.Enabled:=false;
                    fImAni.StartValue.Assign(fMenuMat.BackImage);
                    fImAni.StopValue.Assign(fMenuMat.BackImage);
                    fImAni.StopValue.FlipHorizontal;//magic
                    fImAni.PropertyName:='Bitmap';
                    fImAni.Duration:=10;
                    fImAni.Loop:=true;
                    fImAni.AutoReverse:=true;
                    fImAni.Parent:=fim;
                    fImAni.Enabled:=true;
                    end else
                      fImAni.Pause:=false;

                 end else
                   if fAniType = 3 then
                 begin

                   if not Assigned(fImFa1) then
                   begin
                     fIm2.Bitmap.Assign(fMenuMat.BackImage);
                     fIm2.Bitmap.FlipVertical; // magic
                     fIm2.Height:=Height;
                     fIm.Height:=Height;
                     fIm.Position.X := 0;
                     fIm.Position.Y := 0;
                     // im 2 just off screen
                     fIm2.Position.Y := ((Height) * -1);
                     fIm2.Position.X := 0;
                     fIm2.Visible := true;
                   end;

                   if not Assigned(fImFa1) then
                   begin
                     fImFa1 := TFloatAnimation.Create(self);
                     fImFa1.OnFinish := fa1SlideImFinished;
                     fImFa1.StartFromCurrent := true;
                     fImFa1.Parent := fIm;
                     fImFa1.Duration := 30;
                     fImFa1.PropertyName := 'Position.Y';
                     fImFa1.StartValue :=0;
                     fImFa1.StopValue := Height;// + (Height / 2);
                   end
                   else
                     fImFa1.Pause := false;

                   if not Assigned(fImFa2) then
                   begin
                     fImFa2 := TFloatAnimation.Create(self);
                     fImFa2.OnFinish := fa2SlideImFinished;
                     fImFa2.StartFromCurrent := true;
                     fImFa2.Parent := fIm2;
                     fImFa2.Duration := 30;
                     fImFa2.PropertyName := 'Position.Y';
                     fImFa2.StartValue := ((Height) * -1);
                     fImFa2.StopValue :=0;
                     fImFa2.Enabled := true;
                     fImFa1.Enabled := true;
                   end
                   else
                     fImFa2.Pause := false;


                 end;







end;

procedure TDlgLeaderBoard.StopAni;
begin
  //stop animations
  if fAniType in [1,3] then
    begin
     if Assigned(fImfa1) then
      fImFa1.Pause:=true;
     if Assigned(fImfa2) then
      fImFa2.Pause:=true;
    end else
      if fAniType=2 then
      begin
       if Assigned(fImAni) then
         fImAni.Pause:=true;
      end;



end;



procedure TDlgLeaderBoard.fa1SlideImFinished(Sender: TObject);
begin
// fa slide im1
       if fAniType=1 then
         begin
               //right to left
               if fImFa1.tag=1 then
                begin
                fImFa1.Tag:=0;
                fim.Position.X:=0;
                fImFa1.StartValue:=0;
                fImFa1.StopValue:=Width*-1;
                fImFa1.Enabled:=true;
                fImFa1.Start;
               end else
                  begin
                   fImFa1.Tag:=1;
                   fIm.Position.X:=Width;
                   fImFa1.StartValue:=Width;
                   fImFa1.StopValue:=0;
                   fImFa1.Enabled:=true;
                   fImFa1.Start;
                  end;
         end else
            begin
                 //top to bottom
               if fImFa1.tag=0 then
                begin
                fImFa1.Tag:=1;
                fim.Position.Y:=(Height)*-1;
                fImFa1.StartValue:=(Height)*-1;
                fImFa1.StopValue:=0;
               // fImFa1.Enabled:=true;
                fImFa1.Start;
               end else
                  begin
                   fImFa1.Tag:=0;
                   fim.Position.Y:=0;
                   fImFa1.StartValue:=0;
                   fImFa1.StopValue:=Height;//+(Height/2);
                  // fImFa1.Enabled:=true;
                   fImFa1.Start;
                  end;

            end;

end;

procedure TDlgLeaderBoard.fa2SlideImFinished(Sender: TObject);
begin
// fa slide im2
        if fAniType=1 then
          begin
               //right to left
               if fImFa2.tag=0 then
                begin
                fImFa2.Tag:=1;
                fim2.Position.X:=0;
                fImFa2.StartValue:=0;
                fImFa2.StopValue:=Width*-1;
                fImFa2.Enabled:=true;
                fImFa2.Start;
               end else
                  begin
                   fImFa2.Tag:=0;
                   fim2.Position.X:=Width;
                   fImFa2.StartValue:=Width;
                   fImFa2.StopValue:=0;
                   fImFa2.Enabled:=true;
                   fImFa2.Start;
                  end;
          end else
             begin
                 //top to bottom
               if fImFa2.tag=0 then
                begin
                fImFa2.Tag:=1;
                fim2.Position.Y:=0;
                fImFa2.StartValue:=0;
                fImFa2.StopValue:=Height;//+(Height/2);
               // fImFa2.Enabled:=true;
                fImFa2.Start;
               end else
                  begin
                   fImFa2.Tag:=0;
                   fim2.Position.Y:=((Height)*-1);
                   fImFa2.StartValue:=((Height)*-1);//minus 2 gets rid of black line
                   fImFa2.StopValue:=0;
                   //fImFa2.Enabled:=true;
                   fImFa2.Start;
                  end;

             end;

end;








procedure TDlgLeaderBoard.btnClick(sender: TObject);
var
aBtnNum:integer;
begin
aBtnNum:=0;
if fDlgUp then exit;

  //we got a click event..
  if sender is TRectangle3d then
     aBtnNum:=TRectangle3d(sender).Tag;


  if assigned(fMenuSelect) then
      fMenuSelect(sender,aBtnNum);
end;



//get and sets the menu button
procedure TDlgLeaderBoard.SetKey(aKeyNum: Integer; value: TDlgInputButton);
begin
if aKeyNum>High(fGamerz) then exit;//outa here
fGamerz[aKeyNum]:=value;
end;

function TDlgLeaderBoard.GetKey(aKeyNum: Integer):TDlgInputButton;
begin
result:=nil;//nil the result
if aKeyNum>High(fGamerz) then exit;//outa here
result:=fGamerz[aKeyNum];
end;




procedure TDlgLeaderBoard.ChangeText(aValue: Integer);
var
  i,j:integer;
begin

       j:=aValue*10;

       for I := Low(fGamerz) to High(fGamerz) do
        begin
         if not (i in[3,14]) then
          begin
           fGamerz[i].Text:=IntToStr(j);
           inc(j);
          end;
        end;
end;

procedure TDlgLeaderBoard.DoClose(sender: TObject);
begin
if fDlgUp then exit;

  if Assigned(fOnClose) then
    fOnClose(sender);

end;


procedure TDlgLeaderBoard.DoGamerMenu(sender: TObject);
begin
  //
if fDlgUp then exit;

  if sender is TRectangle3d then
     fSelectedGamer:=TRectangle3d(sender).Tag;



  if not Assigned(TournMenuDlg) then
    begin
      ShowGamerMenu;
      TournMenuDlg.OnMenuSelect:=GamerMenuClose;
      TournMenuDlg.Position.Z:=-2;
    end;
    fDlgUp:=True;

end;

procedure TDlgLeaderBoard.GamerMenuClose(sender: TObject; menu: Integer);
begin

  if Assigned(TournMenuDlg) then
   Tron.KillTournMenu;

   if menu=0 then
     PromptClearHash
       else if menu=1 then
          PromptClearGamer
            else
              fDlgUp:=False;
end;


procedure TDlgLeaderBoard.PromptClearHash;
begin

  ShowConfirm('Clear gamerz hash?');
  if assigned(ConfirmDlg) then
     begin
       ConfirmDlg.OnButtonClick:=DoClearHashes;
     end;

end;

procedure TDlgLeaderBoard.DoClearHash(sender: TObject; sel: Integer);
var
anic:string;
begin

   Tron.KillConfirm;
   if sel=0 then
    begin
      //they said yes..
      if fSelectedGamer>-1 then
       begin
        if fSelectedGamer<PacketSrv.GameData.GamerCount then
         begin
          PacketSrv.GameData.Gamer[fSelectedGamer].Hash:='';
          UpdateBoard(nil);
          fSelectedGamer:=-1;
         end;
       end;
    end;
   fDlgUp:=False;

end;

procedure TDlgLeaderBoard.PromptClearGamer;
begin

  ShowConfirm('Delete gamer?');
  if assigned(ConfirmDlg) then
     begin
       ConfirmDlg.OnButtonClick:=DoClearGamer;
     end;

end;

procedure TDlgLeaderBoard.DoClearGamer(sender: TObject; sel: Integer);
begin

   Tron.KillConfirm;
   if sel=0 then
    begin
      //they said yes..
      if fSelectedGamer>-1 then
       begin
        if fSelectedGamer<PacketSrv.GameData.GamerCount then
         begin
         PacketSrv.GameData.DelGamer(fSelectedGamer);
         UpdateBoard(nil);
         fSelectedGamer:=-1;
         end;
       end;
    end;
   fDlgUp:=False;
end;








procedure TDlgLeaderBoard.DoTournMenu(sender: TObject);
begin
  //
if fDlgUp then exit;

  if not Assigned(TournMenuDlg) then
    begin
      ShowTournMenu;
      TournMenuDlg.OnMenuSelect:=TournMenuClose;
      TournMenuDlg.Position.Z:=-2;
    end;
    fDlgUp:=True;

end;

procedure TDlgLeaderBoard.TournMenuClose(sender: TObject; menu: Integer);
begin

  if Assigned(TournMenuDlg) then
   Tron.KillTournMenu;

   if menu=0 then
     PromptClearHashes
       else if menu=1 then
          PromptClearGamerz
            else
              fDlgUp:=False;


end;

procedure TDlgLeaderBoard.PromptClearHashes;
begin

  ShowConfirm('Clear hashes from all gamerz?');
  if assigned(ConfirmDlg) then
     begin
       ConfirmDlg.OnButtonClick:=DoClearHashes;
     end;

end;

procedure TDlgLeaderBoard.DoClearHashes(sender: TObject; sel: Integer);
begin

   Tron.KillConfirm;
   if sel=0 then
    begin
      //they said yes..
      PacketSrv.GameData.ClearAllHashes;
      UpdateBoard(nil);
    end;
   fDlgUp:=False;

end;

procedure TDlgLeaderBoard.PromptClearGamerz;
begin

  ShowConfirm('Clear all gamerz?');
  if assigned(ConfirmDlg) then
     begin
       ConfirmDlg.OnButtonClick:=DoClearGamerz;
     end;

end;

procedure TDlgLeaderBoard.DoClearGamerz(sender: TObject; sel: Integer);
begin

   Tron.KillConfirm;
   if sel=0 then
    begin
      //they said yes..
      PacketSrv.GameData.ClearAllGamerz;
      UpdateBoard(nil);
    end;
   fDlgUp:=False;
end;



procedure TDlgLeaderBoard.DoConfig(sender: TObject);
begin
  //
if fDlgUp then exit;

  if not Assigned(ConfigDlg) then
    begin
      ShowConfig;
      ConfigDlg.OnDone:=ConfigDone;
      ConfigDlg.OnCancel:=ConfigCancel;
      ConfigDlg.Position.Z:=-2;

    end;

    fDlgUp:=True;

end;

procedure TDlgLeaderBoard.ConfigCancel(sender: TObject);
begin
  //
  if Assigned(ConfigDlg) then
    begin
     Tron.KillConfig;
    end;
    fDlgUp:=False;
end;


procedure TDlgLeaderBoard.ConfigDone(sender: TObject);
var
aNewPort:integer;
begin
  //
  aNewPort:=PacketSrv.Port;
  if Assigned(ConfigDlg) then
    begin
     aNewPort:=StrToInt(ConfigDlg.Port);
     PacketSrv.GameData.EatGame(ConfigDlg.GameDef);
     Tron.KillConfig;
    end;
    fDlgUp:=False;

  //restart server using new port config
  if aNewPort<>PacketSrv.Port then
    begin
      PacketSrv.Stop;
      PacketSrv.Port:=aNewPort;
      PacketSrv.Start;
    end;

end;

procedure TDlgLeaderBoard.UpdateBoard(sender: TObject);
var
i:integer;
aGamer:tGamer;
begin
//
     PacketSrv.GameData.SortGamerz;

self.BeginUpdate;
try
 for I := Low(fGamerz) to High(fGamerz) do
   begin
   //
   aGamer:=PacketSrv.GameData.Gamer[i];
   if assigned(aGamer) then
     begin
      if aGamer.Nic<>'' then
       begin
       fGamerz[i].Visible:=true;
       fGamerz[i].Text:=aGamer.Nic;
       fGamerz[i].LabelText:=FormatBestScore(aGamer.BestScore);
       end else fGamerz[i].Visible:=false;
      aGamer.Free;
      aGamer:=nil;

     end else
        begin
          fGamerz[i].Visible:=false;

        end;


   end;
finally
  self.EndUpdate;
end;

end;







end.
