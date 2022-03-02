{Simple event logger class..

 revised to use TStreamWriter 3.2.2022 -q


}
unit uEventLogging;

interface

uses SysUtils, SyncObjs,System.Classes,System.IOUtils;


type
  tLogSettings = record
    LogPath      : string; // path to log files
    LoggingLevel : integer; // level of logging
    FlushInterval: integer; // currently hard coded at 1000 lines
  end;


type
  tEventLogger = class
  private
    //leave log file open during writes
    // should speed the logging up a bit
    fFileOpen: Boolean;
    // are we all setup and ready
    fInitialized: boolean;
    // our log mutex
    fLogCritical: TCriticalSection;

    // our path to the log files
    fLogPath: string;
    // our logging level
    fLoggingLevel: integer;
    // our LogFile
    fLogFile: TextFile;
    fLogWriter:tStreamWriter;
    // how many writes have happened
    fLastWriteCount: integer;
    // how many write before flushing log file
    fFlushInterval: integer;
    // the log buffer
    fBuff:tStringList;
    fCurrentLogDay: integer;
    function CloseLog: boolean;
    function OpenLog: boolean;
    function FlushLog: boolean;
    function CheckForDayChange: boolean;
    function GetLogName: string;
    //    function
  public
    // call to log something
    procedure Log(aString: string; LogLevel: integer = 0);
    constructor Create;
    destructor Destroy; override;
    // Must be called before logging can really begin
    procedure Initialize(LogSettings: TLogSettings);
  end;

implementation

constructor tEventLogger.Create;
begin
  inherited Create;

    fLogCritical := tCriticalSection.Create;
    fInitialized := False;
    fFileOpen := False;
    fLogPath := '';
    fLastWriteCount := 0;
    fFlushInterval := 1000;
    fBuff:=tStringList.Create;

end;

destructor tEventLogger.Destroy;
begin

  if fInitialized then
  begin
    flushLog;
    fInitialized := False;
  end;


  fLogCritical.Free;
  fBuff.Free;

  inherited Destroy;
end;

procedure tEventLogger.Initialize(LogSettings: tLogSettings);
var
  WaitForResult: integer;
begin

    fLogCritical.Enter;

    try
      fLogPath := LogSettings.LogPath;
      fLoggingLevel := LogSettings.LoggingLevel;
      fFlushInterval := LogSettings.FlushInterval;
      //no less than 10 write before flushing the log file
      if fFlushInterval < 10 then
        fFlushInterval := 10;
      fInitialized := True;
    finally
      fLogCritical.Leave;
    end;



end;

function tEventLogger.GetLogName: string;
var
  m, d, y: word;
  dateStr: string;
begin
  result := 'log.txt';

  try

    //decode the date
    DecodeDate(NOW, y, m, d);
    //year
    dateStr := IntToStr(y) + '-';
    // month a little formatting needed
    if m < 10 then
      dateStr := (dateStr + '0' + IntToStr(m) + '-')
    else
      dateStr := (dateStr + IntToStr(m) + '-');
    // day also a little formatting needed
    if d < 10 then
      dateStr := (dateStr + '0' + IntToStr(d))
    else
      dateStr := dateStr + IntToStr(d);
    // put it all together
    result := dateStr + '-Log.txt';
    //set our CurrentLogDay
    fCurrentLogDay := d;

  finally;
  end;

end;

//internal function

function tEventLogger.CheckForDayChange: boolean;
var
  m, d, y: word;
begin

  result := false;
  try
    DecodeDate(NOW, y, m, d);

    if d <> fCurrentLogDay then
      result := true;

  finally;
  end;

end;

function tEventLogger.FlushLog;
var
  i: integer;
  tmpStr: string;
begin
  result := False;

  //open it up
  if not fFileOpen then
    OpenLog;
  if fFileOpen then
  begin
    try
      //now write all the lines
      for i := 0 to fBuff.Count-1 do
      begin
        if fBuff.Strings[i] <> '' then
        begin
          tmpStr := fBuff.Strings[i];
          fLogWriter.WriteLine(tmpStr);
         // Writeln(fLogFile, tmpStr);
        end;
      end;
      //zero out the buffer after flush
      fBuff.Clear;
      //flush the file
      fLogWriter.Flush;
      Result := True;
    finally
      closelog;
    end;
  end;
end;

function tEventLogger.OpenLog;
begin
  try
    fLogWriter:=tStreamWriter.Create(TPath.Combine(fLogPath,GetLogName),true);
    Result := True;
    fFileOpen := True;
  except on E: Exception do
    begin
      fFileOpen := False;
      result := false; // sorry we could not open log file
    end;
  end;
end;

function tEventLogger.CloseLog;
begin
  // turn off error handling
  if fFileOpen then
  begin
    fLogWriter.Close;
    fLogWriter.Free;
    fLogWriter:=nil;

    //error handling back on
    result := true; // sorry we could not close log file
    fFileOpen := False;
  end
  else
    Result := True;

end;

procedure tEventLogger.Log(aString: string; LogLevel: integer = 0);
var
  TheLine: string;
  dYear, dMonth, dDay, dHours, dMins, dSecs, dMSecs: Word;
  WaitForResult: integer;
begin

   fLogCritical.Enter;
  try


      if not fInitialized then
      begin
        fLogCritical.Leave; // release
        Exit;
      end;

      // 99 always gets logged. 99 is for critical errors
      if LogLevel < 99 then
      begin
        if (LogLevel > fLoggingLevel) then
        begin
          fLogCritical.Leave; // release
          Exit;
        end;
      end;

      // flush log file every so many writes (fFlushInterval)
     Inc(fLastWriteCount);
      if fLastWriteCount>=fFlushInterval then
        begin
        fLastWriteCount:=0;
        try
        FlushLog;
          finally;
          end;
        end;


      try
        // add a date/time stamp to every enrty!!
        // do not use FormatDateTime it is NOT thread safe
        DecodeDate(NOW, dYear, dMonth, dDay);
        DecodeTime(NOW, dHours, dMins, dSecs, dMsecs);
        TheLine := IntToStr(dYear) + '-' + IntToStr(dMonth) + '-' + IntToStr(dDay) + ' ' + IntToStr(dHours) + ':' + IntToStr(dMins) + ':' + IntToStr(dSecs);
        TheLine := TheLine + ':' + aString;

        //make errors stand out
        if LogLevel > 98 then
        begin
          //hoghest level of logging
          TheLine := '!!!**** ' + TheLine + ' ****!!!';
          // output it also
        //  OutPutDebugString(Pchar(TheLine));
        end;

      except on e: Exception do
          ;
      end;

      try
        fBuff.Add(TheLine);
      finally
        ;
      end;

  finally
    fLogCritical.Leave;
  end;
end;

end.

