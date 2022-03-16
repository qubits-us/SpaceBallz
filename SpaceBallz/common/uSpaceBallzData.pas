{ Unit SpaceBallzData -contains data for the spaceballz game tournament server..

created 2.19.2022 -q

this code is rated PG-13   -Language, Drug use.


}
unit uSpaceBallzData;

interface
uses
  System.SysUtils, System.Classes, System.SyncObjs,System.Generics.Collections,System.Generics.Defaults,System.Hash;

const
   //used in game definition
   MAX_BALLS=12;
   MAX_SPEED=12;
   MAX_LEVELS=12;
   GM_PRACT=0;
   GM_LEVELS=1;
   GM_TOURNI=2;
   SMALL_SIZE=0;
   MED_SIZE=1;
   LRG_SIZE=2;

type
   TShit = tBytes;
type
   TEverything = TShit;



type
    TGameLevelRec = packed record
        Seconds:integer;
        Balls:byte;
    end;

type
    TGameDefinitionRec = packed record
       Levels: array [0..MAX_LEVELS-1] of tGameLevelRec;
       BallSize:byte;
       PaddleSize:byte;
       BallSpeed:byte;
       MaxEntries:byte;
    end;

type
    TGameDefinition = class
      private
       fDefRec:TGameDefinitionRec;
      protected
        function GetLevel(index:integer):tGameLevelRec;
        procedure SetLevel(index:integer;aLevel:tGameLevelRec);
        function CountBalls:byte;
      public
        constructor Create;
        destructor  Destroy;override;
        procedure Consume(aRec:TGameDefinitionRec);
        procedure AdjSecs;
      property Levels[index:integer]:TGameLevelRec read GetLevel write SetLevel;
      property Balls:byte read CountBalls;
      property BallSize:byte read fDefRec.BallSize write fDefRec.BallSize;
      property PaddleSize:byte read fDefRec.PaddleSize write fDefRec.PaddleSize;
      property BallSpeed:byte read fDefRec.BallSpeed write fDefRec.BallSpeed;
    end;




type
  tGamerRec = packed record
    nic:array[0..39] of byte;
    hash:array[0..39] of byte;
    entries:byte;
    bestscore:word;
  end;

type
  tGamer = class
  private
    fnic:string;
    fhash:string;
    fentries:byte;
    fbestscore:word;
  public
   constructor Create;
   destructor  Destroy;override;
   function    Shit:tGamerRec;
   procedure   Take(const shit:tGamerRec);
   procedure   SmokeHash(const aPuff:String);
   property Nic:String read fnic write fnic;
   property Hash:string read fhash write fhash;
   property Entries:byte read fentries write fentries;
   property BestScore:word read fbestscore write fbestscore;
  end;



type
    tGameState = packed record
      GamerCount:word;
    end;

type
   tGameData = class
     private
      fCrit:tCriticalSection;
      fGameDef:tGameDefinitionRec;
      fGameState:tGameState;
      fGamerz:TList<tGamer>;
      function    CountGamerz:integer;
      function    GetGamer(aIndex:integer):tGamer;
      function    GiveGame:tGameDefinitionRec;
     public
      constructor Create;
      destructor  Destroy;override;
      function    Give:tEverything;
      procedure   Take(const shit:tShit);
      procedure   EatGame(const gamedef:tGameDefinitionRec);
      procedure   SortGamerz;
      function    FindGamer(anic:string):integer;
      function    CheckHash(aIndex:integer;const aHash:string):boolean;
      function    ClearHash(anic:string):boolean;
      procedure   AddGamer(aGamer:tGamer);
      procedure   DelGamer(aIndex:integer);
      procedure   UpdateGamer(aScore:word;aIndex:integer);
      property GamerCount:integer read CountGamerz;
      property Gamer[index:integer]:tGamer read GetGamer;
      property GameDef:tGameDefinitionRec read GiveGame write EatGame;
   end;

    function FormatBestScore(aScore:word):string;


implementation


//pretty string
function FormatBestScore(aScore:word):String;
var
aMin,aSec:byte;
m,s:string;
begin
if aScore>0 then
 begin
 if aScore>59 then
  begin
   aMin:=aScore div 60;
   aSec:=aScore-(aMin*60);
  end else
    begin
     aMin:=0;
     aSec:=aScore;
    end;
 if aMin<10 then m:='0'+IntToStr(aMin) else m:=IntToStr(aMin);
 if aSec<10 then s:='0'+IntToStr(aSec) else s:=IntToStr(aSec);
 result:=m+':'+s;
 end else result:='00:00';
end;


Constructor TGameDefinition.Create;
var
i:integer;
begin
 //setup levels
 for I := Low(fDefRec.Levels) to High(fDefRec.Levels) do
   begin

     if i=0 then
     fDefRec.Levels[i].Seconds:=1
     else
     fDefRec.Levels[i].Seconds:=303*I;//every 10 seconds
     fDefRec.Levels[i].Balls:=1;//add one more ball
   end;
end;

Destructor TGameDefinition.Destroy;
begin
//

Inherited;
end;

procedure TGameDefinition.Consume(aRec: TGameDefinitionRec);
begin
  Move(aRec,fDefRec,SizeOf(TGameDefinitionRec));
end;

procedure TGameDefinition.AdjSecs;
var
i:integer;
begin
  for I := 1 to High(fDefRec.Levels) do
      fDefRec.Levels[i].Seconds:=fDefRec.Levels[i].Seconds*30;
end;

function TGameDefinition.GetLevel(index: integer): TGameLevelRec;
begin
  result.Seconds:=0;
  result.Balls:=0;
  if (index>-1) and (index<=(high(fDefRec.Levels))) then
     result:=fDefRec.Levels[index];
end;

procedure TGameDefinition.SetLevel(index: integer; aLevel: TGameLevelRec);
begin
  //
  if (index>-1) and (index<=(high(fDefRec.Levels))) then
      fDefRec.Levels[index]:=aLevel;
end;

function TGameDefinition.CountBalls: Byte;
var
I: Integer;
begin
  result:=0;
   for I := Low(fDefRec.Levels) to High(fDefRec.Levels) do
    begin
     result:=result+fDefRec.Levels[i].Balls;
    end;

end;






constructor tGamer.Create;
begin
  inherited;
   //
end;
destructor tGamer.Destroy;
begin
  //
  inherited;
end;

//eat..
procedure tGamer.Take(const shit: tGamerRec);
begin
fEntries:=shit.entries;
fBestScore:=shit.bestscore;
fNic:=Trim(TEncoding.ANSI.GetString(shit.nic));
fHash:=Trim(TEncoding.ANSI.GetString(shit.hash));
end;

//shit..
function tGamer.Shit: tGamerRec;
var
aBytes:tBytes;
begin

aBytes:=TEncoding.ANSI.GetBytes(fNic);
FillChar(result.nic,SizeOf(result.nic),#32);
move(aBytes[0],result.nic[0],length(aBytes));
SetLength(aBytes,0);
aBytes:=TEncoding.ANSI.GetBytes(fHash);
FillChar(result.hash,SizeOf(result.hash),#32);
move(aBytes[0],result.hash[0],length(aBytes));
SetLength(aBytes,0);

result.entries:=fEntries;
result.bestscore:=fBestScore;

end;

//hash is good..
procedure tGamer.SmokeHash(const aPuff: string);
begin
  if aPuff<>'' then
  fHash:=THashMD5.GetHashString(aPuff) else
  fHash:=THashMD5.GetHashString('SpaceBallz');
end;


constructor tGameData.Create;
var
i:integer;
begin
  inherited;
  //
  fCrit:=tCriticalSection.Create;
  fGamerz:=tList<tGamer>.Create;
  fGamerz.Clear;
     //init fGameDef
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


end;

destructor tGameData.Destroy;
var
i:integer;
begin
//
   for I := 0 to fGamerz.Count-1 do
     fGamerz.Items[i].Free;

    fGamerz.Clear;
    fGamerz.Free;
    fCrit.Free;


  inherited;
end;


//give up the game
function tGameData.GiveGame: TGameDefinitionRec;
begin
 fCrit.Enter;
 try
  move(fgamedef,result,SizeOf(TGameDefinitionRec));
 finally
   fCrit.Leave;
 end;

end;

//eat a game
procedure tGameData.EatGame(const gamedef: TGameDefinitionRec);
begin
 fCrit.Enter;
 try
  move(gamedef,fGameDef,SizeOf(TGameDefinitionRec));
 finally
   fCrit.Leave;
 end;
end;

procedure tGameData.Take(const shit: tShit);
var
aSize,pile,i:integer;
aPeaceOf:tGamerRec;
aGamer:tGamer;
begin
aSize:=SizeOf(tGameDefinitionRec);
aSize:=aSize+SizeOf(tGameState);
if Length(shit)>=aSize then
  begin
    //may be some good shit
   fCrit.Enter;
   try
    pile:=0;
    Move(shit[pile],fGameDef,SizeOf(tGameDefinitionRec));
    pile:=pile+SizeOf(tGameDefinitionRec);
    Move(shit[pile],fGameState,SizeOf(tGameState));
    pile:=pile+SizeOf(tGameState);
    if fGameState.GamerCount<99 then //really shouldn't be more than this??
      begin
       for I := 0 to fGameState.GamerCount-1 do
         begin
           Move(shit[pile],aPeaceOf,SizeOf(tGamerRec));
           pile:=pile+SizeOf(tGamerRec);
           aGamer:=tGamer.Create;
           aGamer.Take(aPeaceOf);
           fGamerz.Add(aGamer);
         end;
      end;
   finally
     fCrit.Leave;
   end;
  end;
end;

function tGameData.Give: tEverything;
var
aSize,pile,i:integer;
aPeaceOf:tGamerRec;
begin
//sum it all up
fCrit.Enter;
try
fGameState.GamerCount:=fGamerz.Count;
aSize:=SizeOf(tGameDefinitionRec);
aSize:=aSize+SizeOf(tGameState);
if fGamerz.Count>0 then
aSize:=aSize+(SizeOf(tGamerRec)*fGamerz.Count);
SetLength(result,aSize);
pile:=0;
Move(fGameDef,result[pile],SizeOf(tGameDefinitionRec));
pile:=pile+SizeOf(tGameDefinitionRec);
Move(fGameState,result[pile],SizeOf(tGameState));
pile:=pile+SizeOf(tGameState);
if fGamerz.Count>0 then
  begin
    for I := 0 to fGamerz.Count-1 do
        begin
         aPeaceOf:=fGamerz.Items[i].shit;
         move(aPeaceOf,result[pile],SizeOf(tGamerRec));
         pile:=pile+SizeOf(tGamerRec);
        end;
  end;
finally
  fCrit.Leave;
end;
end;


procedure tGameData.SortGamerz;
begin
// sort gamerz by bestscore
fCrit.Enter;
try
fGamerz.Sort(
 TComparer<TGamer>.Construct(
    function(const Left, Right: TGamer): Integer
    begin
      Result := Left.bestscore - Right.bestscore;
    end
  )
);

fGamerz.Reverse;
finally
  fCrit.Leave;
end;
end;

function tGameData.CountGamerz: Integer;
begin
fCrit.Enter;
try
    result:=fGamerz.Count;
finally
  fCrit.Leave;
end;
end;

function tGameData.FindGamer(anic: string): Integer;
var
i:integer;
begin
  result:=-1;

 fCrit.Enter;
 try
  for I :=0 to fGamerz.Count-1 do
    if UpperCase(fGamerz.Items[i].nic)=UpperCase(anic) then
      begin
        result:=i;
        break;
      end;
 finally
   fCrit.Leave;
 end;

end;

function tGameData.CheckHash(aIndex: Integer; const aHash: string): Boolean;
begin
  result:=false;
  fCrit.Enter;
try
 if (aIndex>-1) and (aIndex<fGamerz.Count) then
   begin
     if fGamerz[aIndex].fhash='' then
     begin
      fGamerz[aIndex].fhash:=aHash;
      Result:=true;
     end else
     if aHash=fGamerz[aIndex].fhash then result:=true;
   end;
finally
  fCrit.Leave;
end;

end;

function tGameData.ClearHash(anic: string): Boolean;
  var
i:integer;
begin
  result:=false;
  fCrit.Enter;
 try
  for I :=0 to fGamerz.Count-1 do
    if UpperCase(fGamerz.Items[i].nic)=UpperCase(anic) then
      begin
        fGamerz.Items[i].fhash:='';
        result:=true;
        break;
      end;
 finally
   fCRit.Leave;
 end;

end;

procedure tGameData.AddGamer(aGamer: tGamer);
begin
 fCrit.Enter;
 try
  fGamerz.Add(aGamer);
 finally
   fCrit.Leave;
 end;
end;

procedure tGameData.DelGamer(aIndex: Integer);
begin
fCrit.Enter;
try
 if (aIndex>-1) and (aIndex<fGamerz.Count) then
   begin
    fGamerz.Items[aIndex].Free;
    fGamerz.Delete(aIndex);
   end;
finally
  fCRit.Leave;
end;

end;

procedure tGameData.UpdateGamer(aScore: Word; aIndex: Integer);
begin
fCrit.Enter;
try
 if (aIndex>-1) and (aIndex<fGamerz.Count) then
  if fGamerz.Items[aIndex].BestScore<aScore then
     fGamerz.Items[aIndex].BestScore:=aScore;
finally
  fCrit.Leave;
end;
end;

function tGameData.GetGamer(aIndex: Integer): tGamer;
begin
fCrit.Enter;
try
result:=TGamer.Create;
result.fnic:='';
result.fhash:='';
result.fentries:=0;
result.fbestscore:=0;
 if (aIndex>-1) and (aIndex<fGamerz.Count) then
   begin
   result.fnic:=fGamerz.Items[aIndex].fnic;
   result.fhash:=fGamerz.Items[aIndex].fhash;
   result.fentries:=fGamerz.Items[aIndex].fentries;
   result.fbestscore:=fGamerz.Items[aIndex].fbestscore;
   end;
finally
  fCrit.Leave;
end;
end;






end.
