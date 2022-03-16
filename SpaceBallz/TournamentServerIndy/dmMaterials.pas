unit dmMaterials;

interface

uses
  System.SysUtils, System.Classes,System.Types, FMX.MaterialSources,System.UIConsts,System.UITypes, FMX.Types,FMX.Graphics ,
  uInertiaTimer,uDlg3dCtrls,uDlg3dTextures;

type
  TMaterialsDm = class(TDataModule)
    tmStarsImg: TTextureMaterialSource;
    tmGamerImg: TTextureMaterialSource;
    tmDarkMatter: TTextureMaterialSource;
    tmClouds: TTextureMaterialSource;
    tmBlueFalls: TTextureMaterialSource;
    tmArora: TTextureMaterialSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure FireUp(sender:tObject);
    procedure LoadTheme;
    procedure LoadDlgMat( aColor: Byte);

  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  MaterialsDm: TMaterialsDm;
  StartupTmr: tInertiaTimer;
  GoFullScreen:boolean;
  CurrentTheme:integer;


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
 uGlobs,frmMain;

procedure TMaterialsDm.DataModuleCreate(Sender: TObject);
begin
//
StartUpTmr:=tInertiaTimer.Create;
StartUpTmr.Enabled:=false;
StartUpTmr.Interval:=5000;
StartUpTmr.OnTimer:=FireUp;
CurrentTheme:=0;
CurrentScale:=1;


end;

procedure TMaterialsDm.DataModuleDestroy(Sender: TObject);
begin
//

StartUpTmr.free;
end;


procedure TMaterialsDm.FireUp(sender:tObject);
begin
  //
    StartUpTmr.Enabled:=false;
    MainFrm.InitLeaderBoard;
end;



procedure TMaterialsDm.LoadTheme;
begin

      case CurrentTheme of
      0:begin
               //Dialogs
              DlgMaterial.BackImage.Assign(tmClouds.Texture);
             // DialogMaterial.Border:=0;
              LoadDlgMat(0);
              DlgMaterial.TextColor.Color:=claBlack;
              DlgMaterial.Buttons.TextColor.Color:=claBlack;
              //load other mats for complex screens..
        end;
      1:begin
               //Dialogs
              DlgMaterial.BackImage.Assign(tmDarkMatter.Texture);
             // DialogMaterial.Border:=0;
              LoadDlgMat(1);
              DlgMaterial.TextColor.Color:=claWhite;
              DlgMaterial.Buttons.TextColor.Color:=claWhite;
              //load other mats for complex screens..
        end;
      2:begin
               //Dialogs
              DlgMaterial.BackImage.Assign(tmBlueFalls.Texture);
             // DialogMaterial.Border:=0;
              LoadDlgMat(3);
              DlgMaterial.TextColor.Color:=claBlack;
              DlgMaterial.Buttons.TextColor.Color:=claBlack;
              //load other mats for complex screens..
        end;
      3:begin
               //Dialogs
              DlgMaterial.BackImage.Assign(tmArora.Texture);
             // DialogMaterial.Border:=0;
              LoadDlgMat(1);
              DlgMaterial.TextColor.Color:=claWhite;
              DlgMaterial.Buttons.TextColor.Color:=claWhite;
              //load other mats for complex screens..
        end;


      end;







end;


procedure TMaterialsDm.LoadDlgMat( aColor: Byte);
var
//aBtnH,aBtnW:single;
tmpBitmap:tBitmap;
aCorner,lCorner:integer;
aBorder:byte;
aBorderColor:byte;
bColor:byte;
aBtnH,aBtnW:single;
aFrmW,aFrmH:single;
aRecW,aRecH:single;
aVrecW,aVrecH:single;
aWidth,aHeight:single;

begin
  if aColor<>6 then bColor:=6 else bColor:=3;


    aWidth:=MainFrm.ClientWidth;
    aHeight:=MainFrm.ClientHeight;


         //buttons
        aBtnW:=(aWidth/3);
        aBtnH:=(aHeight/6);
         //recs
        aRecW:=aBtnW;//frame total
        aRecH:=(aBtnH/2);

        //vertical rect
        aVrecW:=(aBtnW/2);
        aVrecH:=(aBtnH*2.5);





  aCorner:=10;
  lCorner:=10;
  aBorder:=DlgMaterial.Border;
  aBorderColor:=DlgMaterial.BorderColor;

  //make custom texture for our gamerz
  tmpBitmap := MakeTexture(aBtnW, aBtnH, 21, 4,11, aCorner);
  tmGamerImg.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;


  //small
  tmpBitmap := MakeTexture(aBtnW, aBtnH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Small.Button.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aRecW, aRecH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Small.Rect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aVrecW, aVRecH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Small.VRect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;


         //buttons
        aBtnW:=(aWidth/6);
        aBtnH:=(aHeight/6);
         //recs
        aRecW:=aBtnW;//frame total
        aRecH:=(aBtnH/2);

        //vertical rect
        aVrecW:=(aBtnW/2);
        aVrecH:=(aBtnH*2.5);





  //med
  tmpBitmap := MakeTexture(aBtnH, aBtnH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Buttons.Button.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aBtnW, aBtnH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Buttons.Rect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aVrecW, aVRecH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Buttons.VRect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;

  //these are different color than normal
  tmpBitmap := MakeTexture(aBtnW, aBtnH, bColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Down.Rect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aBtnH, aBtnH, bColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Down.Button.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aVrecW, aVRecH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Down.VRect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;




         //buttons
        aBtnW:=(aWidth/2);
        aBtnH:=(aHeight/4);
         //recs
        aRecW:=aBtnW;//frame total
        aRecH:=(aBtnH/2);

        //vertical rect
        aVrecW:=(aBtnW/2);
        aVrecH:=(aBtnH*2.5);



  //Large
  tmpBitmap := MakeTexture(aBtnH, aBtnH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Large.Button.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aBtnW, aBtnH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Large.Rect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;
  tmpBitmap := MakeTexture(aVrecW, aVRecH, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.Large.VRect.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;



  //Really Long Rects
  tmpBitmap := MakeTexture(aWidth, aHeight/7, aColor, aBorder,aBorderColor, aCorner);
  DlgMaterial.LongRects.Texture.Assign(tmpBitmap);
  tmpBitmap.Free;



  DlgMaterial.TextColor.Color := claWhite;
end;





end.
