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
  uDlg3dCtrls,uDlg3dTextures,uNumSelectDlg,uSceneLeaderBoard,uConfigDlg,
  uCommon3dDlgs,uTournMenuDlg,uEventLogging;



   //Tron -in charge of memory defense, kills things..
 type
    TTron = Class(tObject)
    procedure KillLeaderBoard;
    procedure KillConfig;
    procedure KillNumSel;
    procedure KillGamerMenu;
    procedure KillTournMenu;
    procedure KillConfirm;
    End;



  procedure ShowConfig;
  procedure ShowTournMenu;
  procedure ShowGamerMenu;
  procedure ShowConfirm(aMsg:String);






var
  Logger:TEventLogger;
  LeaderBoard:TDlgLeaderBoard;
  ConfigDlg:TDlgConfig;
  NumSelDlg:TDlgNumSel;
  TournMenuDlg:tDlgTournMenu;
  ConfirmDlg:tDlgConfirmation;
  DlgUp:Boolean;
  Tron:TTron;
  ServerIP:String;
  ServerPort:String;
  ServerMAC:String;
  DataPath:String;


implementation

uses frmMain;

procedure TTron.KillConfirm;
begin
     if Assigned(ConfirmDlg) then
      begin
        ConfirmDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              ConfirmDlg.CleanUp;
              ConfirmDlg.Free;
              ConfirmDlg:=nil;
             end);
         end).Start;
      end;

end;

procedure TTron.KillTournMenu;
begin
     if Assigned(TournMenuDlg) then
      begin
        TournMenuDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              TournMenuDlg.CleanUp;
              TournMenuDlg.Free;
              TournMenuDlg:=nil;
             end);
         end).Start;
      end;

end;



procedure TTron.KillGamerMenu;
begin
     if Assigned(TournMenuDlg) then
      begin
        TournMenuDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              TournMenuDlg.CleanUp;
              TournMenuDlg.Free;
              TournMenuDlg:=nil;
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

procedure TTron.KillConfig;
begin
     if Assigned(ConfigDlg) then
      begin
        ConfigDlg.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              ConfigDlg.CleanUp;
              ConfigDlg.Free;
              ConfigDlg:=nil;
             end);
         end).Start;
      end;

end;

 procedure TTron.KillLeaderBoard;
 begin
     if Assigned(LeaderBoard) then
      begin
        LeaderBoard.Visible:=false;
       TThread.CreateAnonymousThread(
        procedure
         begin
          TThread.Queue(nil,
           procedure
            begin
              LeaderBoard.CleanUp;
              LeaderBoard.Free;
              LeaderBoard:=nil;
             end);
         end).Start;
      end;
 end;




procedure ShowConfig;
var
newx,newy:single;
begin
  //
  if not assigned(ConfigDlg) then
   begin
   newx:=(MainFrm.ClientWidth/2);
   newy:=(MainFrm.ClientHeight/2);

   ConfigDlg:=TDlgConfig.Create(MainFrm,DlgMaterial,MainFrm.ClientWidth,MainFrm.ClientHeight,newx,newy);
   ConfigDlg.Parent:=MainFrm;
   end;


end;

procedure ShowTournMenu;
var
newx,newy:single;
begin
  //
  if not assigned(TournMenuDlg) then
   begin
   newx:=(MainFrm.ClientWidth/2);
   newy:=(MainFrm.ClientHeight/2);

   TournMenuDlg:=TDlgTournMenu.Create(MainFrm,DlgMaterial,MainFrm.ClientHeight/1.25,MainFrm.ClientHeight/1.25,newx,newy);
   TournMenuDlg.Parent:=MainFrm;
   end;


end;

procedure ShowGamerMenu;
var
newx,newy:single;
begin
  //
  if not assigned(TournMenuDlg) then
   begin
   newx:=(MainFrm.ClientWidth/2);
   newy:=(MainFrm.ClientHeight/2);

   TournMenuDlg:=TDlgTournMenu.Create(MainFrm,DlgMaterial,MainFrm.ClientHeight/1.25,MainFrm.ClientHeight/1.25,newx,newy);
   TournMenuDlg.Parent:=MainFrm;
   TournMenuDlg.Keys[0].Text:='Clear Hash';
   TournMenuDlg.Keys[1].Text:='Delete Gamer';
   end;


end;




procedure ShowConfirm(aMsg:String);
var
newx,newy:single;
begin
  //
  if not assigned(ConfirmDlg) then
   begin
   newx:=(MainFrm.ClientWidth/2);
   newy:=(MainFrm.ClientHeight/2);

   ConfirmDlg:=TDlgConfirmation.Create(MainFrm,DlgMaterial,MainFrm.ClientWidth/1.25,MainFrm.ClientHeight/1.50,newx,newy);
   ConfirmDlg.Parent:=MainFrm;
   ConfirmDlg.DlgText.Msg:=aMsg;
   ConfirmDlg.Position.Z:=-2;
   end;


end;


end.
