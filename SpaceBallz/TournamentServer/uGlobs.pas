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
  uDlg3dCtrls,uDlg3dTextures,uNumSelectDlg,uSceneLeaderBoard,uConfigDlg;



   //Tron -in charge of memory defense, kills things..
 type
    TTron = Class(tObject)
    procedure KillLeaderBoard;
    procedure KillConfig;
    procedure KillNumSel;
    End;



  procedure ShowConfig;






var
  LeaderBoard:TDlgLeaderBoard;
  ConfigDlg:TDlgConfig;
  NumSelDlg:TDlgNumSel;
  DlgUp:Boolean;
  Tron:TTron;
  ServerIP:String;
  ServerPort:String;
  ServerMAC:String;
  DataPath:String;


implementation

uses frmMain;


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




end.
