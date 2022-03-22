{ the Globs for SpaceBallz!!
  Created:2.13.2022 -q

  be it harm none, do as ye wish..


     }
unit uGlobs;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Types3D, FMX.Forms, FMX.Graphics,
  FMX.MaterialSources,FMX.Objects, FMX.Dialogs,FMX.Layers3D,FMX.Objects3D,
  System.UIConsts,dmMaterials,System.SyncObjs, System.Math.Vectors,
  FMX.Controls3D,FMX.Platform{$IFDEF ANDROID},FMX.Platform.Android{$ENDIF},
  uDlg3dCtrls,uSpaceBallz,uDlg3dTextures,uNumSelectDlg,uConnectDlg,uKeyboardDlg,uCommon3dDlgs;



   //Tron -in charge of memory defense, kills things..
 type
    TTron = Class(tObject)
    procedure KillSpaceBallz;
    procedure KillConnect;
    procedure KillNumSel;
    procedure KillKeyboard;
    procedure KillInfo(sender:tObject);
    End;




 procedure MsgOK(aMsg:String);





var
  SpaceBallz:TSpaceBallz;
  ConnectDlg:tConnectDlg;
  NumSelDlg:TDlgNumSel;
  KeyboardDlg:tDlgKeyboard;
  InfoDlg:tDlgInformation;
  SrvIp:String;
  SrvPort:String;
  GamerNic:string;
  GamerHash:String;
  DataPath:string;
  SoundPath:string;

  DlgUp:Boolean;
  Tron:TTron;


implementation

uses frmMain;

procedure TTron.KillInfo(sender:tObject);
begin
     if Assigned(InfoDlg) then
      begin
        InfoDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              InfoDlg.CleanUp;
              InfoDlg.Free;
              InfoDlg:=nil;
             end);
         end).Start;
      end;

end;




procedure TTron.KillNumSel;
begin
     if Assigned(NumSelDlg) then
      begin
        NumSelDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              NumSelDlg.CleanUp;
              NumSelDlg.Free;
              NumSelDlg:=nil;
             end);
         end).Start;
      end;

end;

procedure TTron.KillKeyboard;
begin
     if Assigned(KeyboardDlg) then
      begin
        KeyboardDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              KeyboardDlg.CleanUp;
              KeyboardDlg.Free;
              KeyboardDlg:=nil;
             end);
         end).Start;
      end;

end;

procedure TTron.KillConnect;
begin
     if Assigned(ConnectDlg) then
      begin
        ConnectDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              ConnectDlg.CleanUp;
              ConnectDlg.Free;
              ConnectDlg:=nil;
             end);
         end).Start;
      end;

end;



 procedure TTron.KillSpaceBallz;
 begin
     if Assigned(SpaceBallz) then
      begin
        SpaceBallz.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              SpaceBallz.CleanUp;
              SpaceBallz.Free;
              SpaceBallz:=nil;
             end);
         end).Start;
      end;
 end;



 procedure MsgOK(aMsg:String);
 begin
   //
   if not Assigned(InfoDlg) then
     begin
     InfoDlg:=TDlgInformation.Create(MainFrm,DlgMaterial,MainFrm.Width/1.25,MainFrm.Height/1.5,MainFrm.Width/2,MainFrm.Height/2);
     InfoDlg.DlgText.Msg:=aMsg;
     InfoDlg.OnClick:=Tron.KillInfo;
     InfoDlg.Parent:=MainFrm;
     InfoDlg.Position.Z:=-10;
     end;
 end;



end.
