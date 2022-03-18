{ Tournament Menu for SpaceBallz- also doubles as Gamer Menu

  Simple 3 button menu..
  Allows for Deleting all or one player(s), clearing all or one player hashe(s)

  3.16.22 -q

}
unit uTournMenuDlg;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, System.Math.Vectors, FMX.Ani, FMX.Controls3D,
  FMX.MaterialSources, FMX.Objects3D,FMX.Layers3D, FMX.Effects, FMX.Filter.Effects,
  uDlg3dCtrls,uDlg3dTextures;


type
TDlgTournMenu = class(TDummy)
  private
    fim:tImage3d;
    //array of keys..
    fKeys: array of TDlgButton;
    fMenuMat:TDlgMaterial;
    fCurrentMenu:integer;
    fMenuSelect:tDlgSelect_Event;
    fCleanedUp:boolean;

  protected
    function    GetKey(aKeyNum:integer):TDlgButton;
    procedure   SetKey(aKeyNum:integer;value:TDlgButton);
    function    HandleButton(aBtnNum:integer):Boolean;
    procedure   btnClick(sender:tObject);
  public
    procedure   SetMenu(aMenu:integer);
    constructor Create(aOwner:TComponent;aMenuMat:TDlgMaterial;
                    aWidth,aHeight,aX,aY:single); reintroduce;
    destructor  Destroy;override;
    procedure   CleanUp;
    function    GetKeyText(aMenu,keyNum:integer):string;
    property    Keys[index:integer]:TDlgButton read GetKey write SetKey;
    property    CurrentMenu:integer read fCurrentMenu write SetMenu;
    property    OnMenuSelect:TDlgSelect_Event read fMenuSelect write fMenuSelect;
end;




implementation



constructor TDlgTournMenu.Create(aOwner: TComponent;aMenuMat:TDlgMaterial;
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
  fCleanedUp:=false;
  //set our cam first always!!!
  Projection:=TProjection.Screen;

  fCurrentMenu:=0;//default to 1st menu

  fMenuMat:=aMenuMat;

  //set w,h and pos
  Width:=(aWidth);
  Height:=(aHeight);
  Position.X:=aX;
  Position.Y:=aY;
  Depth:=1;
  Opacity:=0.95;


  tmpBitmap:=MakeDlgBackGrnd(Width+12,Height+12,0,0,10);
  fIm:=TImage3d.Create(self);
  fIm.Projection:=tProjection.Screen;
  fIm.Bitmap.Assign(tmpBitmap);
  tmpBitmap.Free;
  fIm.Width:=aWidth+12;
  fIm.Height:=aHeight+12;
  fIm.HitTest:=false;
  fIm.Position.X:=0;
  fIm.Position.Y:=0;
  fIm.Position.Z:=0;
  fIm.Opacity:=0.95;
  fIm.Parent:=self;






  aColGap:=2;
  aRowGap:=2;
  aButtonWidth:=Width;//divide width by max keys in a row


  fMenuMat.FontSize:=32;

  SetLength(fKeys,3);

  ah:=(Height / (High(fKeys)+1));// devide height by number of rows..
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
     fMenuMat.FontSize:=32;
    end else
    begin
      fMenuMat.FontSize:=24;
    end;

  if SectionHeight>100 then
     begin
     fMenuMat.FontSize:=36;
     end;



  newy:=(((aHeight/2)*-1)+(SectionHeight/2));//top

   //newx:=((aWidth/2)*-1)+(aButtonWidth+(aButtonWidth/2));
   newx:=0;
   numpadStart:=0;
  for I := Low(fKeys) to High(fKeys) do
   begin
    fKeys[i]:=TDlgButton.Create(self,aButtonwidth,SectionHeight,newx,newy);
    fKeys[i].Projection:=TProjection.Screen;
    fKeys[i].Parent:=self;
    fkeys[i].Tag:=i;
    fkeys[i].MaterialSource:=fMenuMat.Large.Rect;
 //   fkeys[i].RectButton.MaterialBackSource:=fMenuMat.tmButtons.mtButton;
 //   fkeys[i].RectButton.MaterialShaftSource:=fMenuMat.tmButtons.mtButton;
     fKeys[i].TextColor:=fMenuMat.Buttons.TextColor.Color;
    fKeys[i].FontSize:=fMenuMat.FontSize;
    //back up the texture, we be drawing our own text for awhile.. :(
    fKeys[i].BtnBitMap.Assign(fMenuMat.Large.Rect.Texture);
    fkeys[i].Text:=GetKeyText(0,i);
    fKeys[i].OnClick:=btnClick;
    fKeys[i].Opacity:=0.85;
    newy:=newy+SectionHeight+aRowGap;
    end;


end;


//clean up..
destructor TDlgTournMenu.Destroy;
var
i:integer;
begin
  try
    if not fCleanedUp then CleanUp;

  finally
   //fafa
   inherited;
  end;
end;

procedure TDlgTournMenu.CleanUp;
var
i:integer;
begin
  if fCleanedUp then Exit;

  try
   //all the buttons
     for I := 0 to High(fKeys) do
       begin
        fKeys[i].CleanUp;
        fKeys[i].Free;
        fKeys[i]:=nil;
       end;

     SetLength(fKeys,0);
     fCleanedUp:=true;

  finally
   //fafa
  end;
end;



procedure TDlgTournMenu.btnClick(sender: TObject);
var
aBtnNum:integer;
begin
aBtnNum:=-1;
  //we got a click event..
  if sender is TRectangle3D then
     aBtnNum:=TRectangle3D(sender).Tag;

    if aBtnNum<0 then exit;


 //if HandleButton(aBtnNum) then exit;//leave



  if assigned(fMenuSelect) then
      fMenuSelect(sender,aBtnNum);
end;

function TDlgTournMenu.HandleButton(aBtnNum: Integer):boolean;
begin
  result:=true;
   case aBtnNum of
   0:SetMenu(1);
   1:SetMenu(2);
   2:Result:=false;
   3:SetMenu(3);
   4:Result:=false;
   10:Result:=false;
   11:Result:=false;
   14:SetMenu(0);
   20:Result:=false;
   21:Result:=false;
   24:SetMenu(0);
   30:Result:=false;
   31:Result:=False;
   33:result:=false;
   34:SetMenu(0);
   end;



end;



//get and sets the menu button
procedure TDlgTournMenu.SetKey(aKeyNum: Integer; value: TDlgButton);
begin
if aKeyNum>High(fKeys) then exit;//outa here
fKeys[aKeyNum]:=value;
end;

function TDlgTournMenu.GetKey(aKeyNum: Integer):TDlgButton;
begin
result:=nil;//nil the result
if aKeyNum>High(fKeys) then exit;//outa here
result:=fKeys[aKeyNum];
end;


procedure TDlgTournMenu.SetMenu(aMenu: Integer);
var
I:integer;
begin
  fCurrentMenu:=aMenu;
  for I := Low(fKeys) to High(fKeys) do
   begin
    fkeys[i].Text:=GetKeyText(aMenu,i);
    fKeys[i].Tag:=(aMenu*10)+i;
   end;


end;

function TDlgTournMenu.GetKeyText(aMenu,keyNum:integer):string;
begin

case aMenu of

0: begin //main menu
  case keyNum of
  0:result:='Clear All Hashes';
  1:result:='Delete All Players';
  2:result:='Close';
  3:result:='-';
  4:result:='-';
  5:result:='-';
  6:result:='-';
  7:result:='-';
  end;
end;

1: begin
  case keyNum of
  0:result:='---';
  1:result:='---';
  2:result:='---';
  3:result:='---';
  4:result:='---';
  5:result:='Y';
  6:result:='U';
  end;
end;
2: begin
  case keyNum of
  0:result:='---';
  1:result:='---';
  2:result:='---';
  3:result:='---';
  4:result:='Back';
  5:result:='Y';
  6:result:='U';
  end;
  end;

3: begin
  case keyNum of
  0:result:='---';
  1:result:='---';
  2:result:='---';
  3:result:='---';
  4:result:='Back';
  5:result:='Y';
  6:result:='U';
  end;

end;
end;



end;





end.
