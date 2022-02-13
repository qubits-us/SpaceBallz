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
  uDlg3dCtrls,uSpaceBallz,uDlg3dTextures,uNumSelectDlg;



   //Tron -in charge of memory defense, kills things..
 type
    TTron = Class(tObject)
    procedure KillSpaceBallz;
    procedure KillNumSel;
    End;










var
  SpaceBallz:TSpaceBallz;
  NumSelDlg:TDlgNumSel;
  DlgUp:Boolean;
  Tron:TTron;


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





end.
