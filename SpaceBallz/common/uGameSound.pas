{Unit GameSound -provides basic background mucis and game sounds.
           Compatible with Windows and Android

  created:3/21/22 -q  www.qubits.us

Acknowledgements/Credits - This was a derived work from clos examination of the Audio Manager- Author Jim McKeeth
                           Also Audio Manager released by FMXExpress.com
                           Bit and pieces from StackOverFlow allowed for SoundLoadedListener - Remy Lebuae

                           Would not have been possible without you, THANK YOU!!!


Uses new PoolBuilder for lollipops and higher..


           be it harm none, do as you wish..

           }


unit uGameSound;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Threading, System.Generics.Collections, System.SyncObjs, FMX.Media
  {$IFDEF ANDROID}
    ,Androidapi.jni.media, FMX.Helpers.Android, Androidapi.jni.JavaTypes, Androidapi.JNI.GraphicsContentViewText,Androidapi.JNIBridge,
    Androidapi.helpers, Androidapi.JNI.App, Androidapi.JNI.Os
  {$ENDIF}
  {$IFDEF MSWINDOWS}
    ,MMSystem
  {$ENDIF}
   ;


const
   MAX_STREAMS = 4;
   MAX_VOL     = 1;
   MID_VOL     = 0.5;
   MIN_VOL     = 0.25;
   USAGE_GAME  = 14;
   CT_SONIF    = 4;
   LOLLIPOP    = 21;

type
   tMusicError_Event = procedure (sender:tObject;aErrorMsg:String) of object;

{$IFDEF ANDROID}

type
TSoundLoadedEvent = procedure(Sender: TObject; SampleId: integer; status: Integer) of object;

type
TSoundLoadedListener = class(TJavaLocal, JSoundPool_OnLoadCompleteListener)
  private
    FSoundPool       : JSoundPool;
    FOnJLoadCompleted : TSoundLoadedEvent;
  public
    procedure onLoadComplete(soundPool: JSoundPool; sampleId,status: Integer); cdecl;
    property  OnLoadCompleted: TSoundLoadedEvent read FOnJLoadCompleted write FOnJLoadCompleted;
    property  SoundPool: JSoundPool read FSoundPool;
  end;
{$ENDIF}


type
  TSound=record
    FileName  :string;
    SoundName :string;
    Id        :integer;
    Loaded    :boolean;
  end;

  TGameSound=Class
    Private
      fCrit:tCriticalSection;
      fSounds:TList<TSound>;
      fEffectsVolume:single;
      fPlayEffects:boolean;
      fMusicVolume:single;
      fMusic:tMediaPlayer;
      fMusicFile:string;
      fMusicPlaying:boolean;
      fMusicError:tMusicError_Event;
      {$IFDEF ANDROID}
      fJAudioMgr:JAudioManager;
      fJPool:JSoundPool;
      fSoundLoadedListener:TSoundLoadedListener;
      fOnPlatformLoadComplete:TSoundLoadedEvent;
      procedure DoOnLoadComplete(Sender:TObject;SampleId:integer;status:integer);
      {$ENDIF}
      procedure SetLoaded(aSampleId:integer);
      function  GetCount:integer;
      procedure SetEffectsVol(aVol:single);
      function  GetEffectsVol:single;
      procedure SetPlayEffects(aVal:Boolean);
      function  GetPlayEffects:boolean;

      procedure SetMusicPlaying(aPlaying:boolean);
      function  GetMusicPlaying:boolean;
      procedure SetMusicFile(aFile:string);
      function  GetMusicFile:String;
      procedure DoMusicError(aMsg:String);
      procedure SetMusicVol(aVol:single);
      function  GetMusicVol:single;
    Public
      Constructor Create;
      Destructor  Destroy;override;
      function  Add(aFileName:string;aName:string):integer;
      procedure Delete(aName:string);overload;
      procedure Delete(aIndex:integer);overload;
      procedure Play(aName:string);overload;
      procedure Play(aIndex:integer);overload;

     {$IFDEF ANDROID}
      property  OnLoadCompleted:TSoundLoadedEvent read fOnPlatformLoadComplete write fOnPlatformLoadComplete;
      {$ENDIF}
      property OnMusicError:tMusicError_Event read fMusicError write fMusicError;
      property CountSounds:Integer read GetCount;
      property EffectsVol:single read GetEffectsVol write SetEffectsVol;
      property PlayEffects:boolean read GetPlayEffects write SetPlayEffects;
      property MusicVol:single read GetMusicVol write SetMusicVol;
      property MusicFile:string read GetMusicFile write SetMusicFile;
      property MusicPlaying:boolean read GetMusicPlaying write SetMusicPlaying;
  end;

  var
    GameSound:tGameSound;


implementation


{$IFDEF ANDROID}
procedure TSoundLoadedListener.onLoadComplete(soundPool:JSoundPool; sampleId, status:integer);
begin
  FSoundPool := soundPool;
  if Assigned(FOnJLoadCompleted) then
    FOnJLoadCompleted(Self, sampleID, status);
end;
{$ENDIF}


constructor TGameSound.Create;
  {$IFDEF ANDROID}
var
poolBuilder:JSoundPool_Builder;
attribBuilder:JAudioAttributes_Builder;
attribs:JAudioAttributes;
  {$ENDIF}
begin
  try
    fCrit:=tCriticalSection.Create;
    fMusicVolume:=MAX_VOL;
    fEffectsVolume:=MAX_VOL;
    //background music player
    fMusic:=tMediaPlayer.Create(nil);
    fMusic.Volume:=MAX_VOL;
    fPlayEffects:=true;


    fSounds := TList<TSound>.Create;
  {$IFDEF ANDROID}
  fJAudioMgr:=TJAudioManager.Wrap((TAndroidHelper.Activity.getSystemService(TJContext.JavaClass.AUDIO_SERVICE)as ILocalObject).GetObjectID);
   //create a pool.. check os version..
   if (TJBuild_VERSION.JavaClass.SDK_INT >= LOLLIPOP) then
     begin
      attribBuilder:=tJAudioAttributes_Builder.JavaClass.init;
      attribBuilder.setUsage(USAGE_GAME);
      attribBuilder.setContentType(CT_SONIF);
      attribs:=attribBuilder.build;
      poolBuilder:=tJSoundPool_Builder.JavaClass.init;
      poolBuilder.setMaxStreams(MAX_STREAMS);
      poolBuilder.setAudioAttributes(attribs);
      fJPool := PoolBuilder.build;
      attribBuilder:=nil;
      PoolBuilder:=nil;
     end else
        fJPool := TJSoundPool.JavaClass.init(MAX_STREAMS,TJAudioManager.JavaClass.STREAM_MUSIC, 0);
   //create our listener
    fSoundLoadedListener:=TSoundLoadedListener.Create;
    // set the listener callback
    fSoundLoadedListener.OnLoadCompleted:=DoOnLoadComplete;
    // inform JSoundPool that we have a listener
    fJPool.setOnLoadCompleteListener( fSoundLoadedListener );

  {$ENDIF}

  except
    On E:Exception do
      Raise Exception.create('Game Sound Create : '+E.message);
  end;
end;

destructor TGameSound.Destroy;
var
  i : integer;
begin
  try
    for i := fSounds.Count -1 downto 0 do
    begin
      fSounds.Delete(i);
    end;
    fSounds.Free;
    fMusic.Free;
    fCrit.Free;

    {$IFDEF ANDROID}
      fJPool := nil;
      fJAudioMgr := nil;
    {$ENDIF}
    inherited;
  except
    On E:Exception do
      Raise Exception.create('Game Sound : '+E.message);
  end;
end;

{$IFDEF ANDROID}
procedure TGameSound.DoOnLoadComplete(Sender: TObject; sampleId: Integer; status: Integer);
begin
  if status=0 then //0=success
  begin
    SetLoaded(sampleId);
    if Assigned(Self.fOnPlatformLoadComplete) then
      fOnPlatformLoadComplete( self, sampleID, status );
  end;
end;
{$ENDIF}


procedure tGameSound.SetLoaded(aSampleId:integer);
var
i : integer;
aSound:tSound;
begin
fCrit.Enter;
 try
  try
    for i := 0 to fSounds.Count -1 do
    begin
      if TSound(fSounds[i]).Id=aSampleID then
      begin
        aSound:=fSounds[i];
        aSound.Loaded:=True;
        fSounds[i]:=aSound;
        Break;
      end;
    end;
  except
    On E:Exception do
      Raise Exception.create('Game Sound Loaded : '+E.message);
  end;
 finally
   fCrit.Leave;
 end;
end;


function TGameSound.Add(aFileName: string; aName:String) : integer;
var
  aSound:tSound;
begin
  Result:=-1;
  fCrit.Enter;
 try
  try
    aSound.FileName:=aFileName;
    aSound.SoundName:=aName;
    aSound.ID:=-1;//win don't use it
    aSound.Loaded:=true;

    {$IFDEF ANDROID}
    aSound.Loaded:=False;
    aSound.ID:=fJPool.load(StringToJString(aFileName) ,0);
    {$ENDIF}
    Result:=fSounds.Add(aSound);
  except
    On E:Exception do
      Raise Exception.create('Game Sound Add : '+E.message);
  end;
 finally
   fCrit.Leave;
 end;
end;

procedure TGameSound.Delete(aIndex: integer);
var
aSound:tSound;
begin
fCrit.Enter;
 try
  try
    if aIndex < fSounds.Count then
    begin
      aSound := fSounds[aIndex];
      {$IFDEF ANDROID}
        fJPool.unload(aSound.Id);
      {$ENDIF}
      fSounds.Delete(aIndex);
    end;
  except
    On E:Exception do
      Raise Exception.create('Game Sound Delete : '+E.message);
  end;
 finally
   fCrit.Leave;
 end;
end;

procedure TGameSound.Delete(aName: String);
var
i:integer;
begin
fCrit.Enter;
 try
  try
    for i:=0 to fSounds.Count -1 do
    begin
      if CompareText(TSound(fSounds[i]).SoundName, AName)=0 then
      begin
        Delete(i);
        Break;
      end;
    end;
  except
    On E:Exception do
      Raise Exception.create('Game Sound Delete : '+E.message);
  end;
 finally
   fCrit.Leave;
 end;
end;


procedure TGameSound.Play(aIndex: integer);
var
  aSound:TSound;
  {$IFDEF ANDROID}
    CurrVol,MaxVol,WantVol:Double;
  {$ENDIF}
begin
fCrit.Enter;
 try
    if fPlayEffects then
    begin
      try
        if aIndex < fSounds.Count then
        begin
          aSound := fSounds[aIndex];
{$IFDEF ANDROID}
          if aSound.Loaded then
          begin
            if Assigned(fJAudioMgr) then
            begin
              CurrVol := fJAudioMgr.getStreamVolume(TJAudioManager.JavaClass.STREAM_MUSIC);
              MaxVol := fJAudioMgr.getStreamMaxVolume(TJAudioManager.JavaClass.STREAM_MUSIC);
              MaxVol := MaxVol / fEffectsVolume;
              WantVol := CurrVol / MaxVol;
              fJPool.Play(aSound.Id, WantVol, WantVol, 1, 0, 1);
            end;
          end;
{$ENDIF}
{$IFDEF MSWINDOWS}
          sndPlaySound(Pchar(aSound.FileName), SND_NODEFAULT Or SND_ASYNC);
{$ENDIF}
        end;
      except
        On E: Exception do
          Raise Exception.Create('Game Sound Playback : ' + E.message);
      end;
    end;
  finally
    fCrit.Leave;
 end;
end;


procedure TGameSound.Play(aName: String);
var i : integer;
begin
fCrit.Enter;
  try
    if fPlayEffects then
    begin
      try
        for i := 0 to fSounds.Count - 1 do
        begin
          if CompareText(TSound(fSounds[i]).SoundName, aName) = 0 then
          begin
            Play(i);
            Break;
          end;
        end;
      except
        On E: Exception do
          Raise Exception.Create('Game Sound Playback : ' + E.message);
      end;
    end;
  finally
    fCrit.Leave;
  end;
end;

function TGameSound.GetCount: integer;
begin
fCrit.Enter;
try
  result:=fSounds.Count;
finally
  fCrit.Leave;
end;
end;

procedure TGameSound.SetEffectsVol(aVol: Single);
begin
fCrit.Enter;
 try
  if aVol>MAX_VOL then aVol:=MAX_VOL;
  if aVol<MIN_VOL then aVol:=MIN_VOL;
  fEffectsVolume:=aVol;
 finally
   fCrit.Leave;
 end;
end;

function TGameSound.GetEffectsVol: Single;
begin
  fCrit.Enter;
    try
      result:=fEffectsVolume;
    finally
     fCrit.Leave;
    end;
end;

procedure TGameSound.SetPlayEffects(aVal: Boolean);
begin
  fCrit.Enter;
    try
      fPlayEffects:=aVal;
    finally
     fCrit.Leave;
    end;
end;

function TGameSound.GetPlayEffects: Boolean;
begin
    fCrit.Enter;
      try
        result:=fPlayEffects;
      finally
       fCrit.Leave;
      end;
end;


//Background music

procedure TGameSound.SetMusicPlaying(aPlaying: Boolean);
begin
fCrit.Enter;
try
  if aPlaying=fMusicPlaying then exit;
  fMusicPlaying:=aPlaying;
try
  if fMusic.FileName<>'' then
     if fMusicPlaying then
         fMusic.Play else fMusic.Stop;
  except on e:exception do
    begin
      DoMusicError(e.Message);
    end;
end;
finally
  fCrit.Leave;
end;
end;

function TGameSound.GetMusicPlaying: Boolean;
begin
  fCrit.Enter;
   try
     result:=fMusicPlaying;
   finally
    fCrit.Leave;
   end;
end;

procedure TGameSound.SetMusicVol(aVol: Single);
begin
fCrit.Enter;
 try
  if aVol>MAX_VOL then aVol:=MAX_VOL;
  if aVol<MIN_VOL then aVol:=MIN_VOL;
  fMusicVolume:=aVol;
  fMusic.Volume:=fMusicVolume;
 finally
   fCrit.Leave;
 end;
end;

function TGameSound.GetMusicVol: Single;
begin
  fCrit.Enter;
    try
      result:=fMusicVolume;
    finally
     fCrit.Leave;
    end;
end;

procedure TGameSound.SetMusicFile(aFile: string);
begin
fCrit.Enter;
 Try
  if aFile=fMusicFile then exit;
  fMusicFile:=aFile;
  try
    if fMusic.State =tMediaState.Playing then fMusic.Stop;
     fMusic.Clear;
     fMusic.FileName:=fMusicFile;
     except on e:exception do
      begin
        DoMusicError(e.Message);
      end;
  end;
 Finally
   fCrit.Leave;
 End;
end;

function TGameSound.GetMusicFile: string;
begin
  fCrit.Enter;
   try
    result:=fMusicFile;
   finally
    fCrit.Leave;
   end;
end;

procedure TGameSound.DoMusicError(aMsg:String);
begin
  if Assigned(fMusicError) then fMusicError(self,aMsg);
end;

end.
