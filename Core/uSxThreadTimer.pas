unit uSxThreadTimer;

interface

uses
  uTypes,
  Classes,
  uTimeSpan,
  uSxThread;

type
  TSxThreadTimer = class(TSxThread)
  private
    FRun: BG;
    FEnabled: BG;
    FInterval: TTimeSpan;
    FOnTimer: TNotifyEvent;
    FWorkingTime: U8;
    FIdleTime: U8;
    procedure SetOnTimer(const Value: TNotifyEvent);
    procedure SetEnabled(const Value: BG);

    procedure InternalExecute;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure StopAndDestroy;

    property Enabled: BG read FEnabled write SetEnabled;
    property Interval: TTimeSpan read FInterval;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;

    property WorkingTime: U8 read FWorkingTime;
    property IdleTime: U8 read FIdleTime;
  end;

implementation

uses
  uMsg, uStopwatch, uMath,
  Windows, Forms, SysUtils, Math;

{ TSxThreadTimer }

constructor TSxThreadTimer.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);

  FEnabled := not CreateSuspended;
  FInterval := TTimeSpan.Create;
end;

destructor TSxThreadTimer.Destroy;
begin
  FreeAndNil(FInterval);

  inherited;
end;

procedure TSxThreadTimer.Execute;
begin
  FRun := True;
  inherited;
  try
    InternalExecute;
  except
    on E: Exception do
      ErrorMsg(E.Message);
  end;
end;

procedure TSxThreadTimer.InternalExecute;
var
  Stopwatch: TStopwatch;
  StartTime: U8;
  SleepTime: TTimeSpan;
begin
  Stopwatch := TStopwatch.Create;
  SleepTime := TTimeSpan.Create;
  try
    StartTime := PerformanceCounter;
    while FRun and (not Application.Terminated) do
    begin
      Stopwatch.Start;
      FOnTimer(Self);
      Stopwatch.Stop;
      Inc(FWorkingTime, Stopwatch.Elapsed.Ticks);

      SleepTime.Ticks := FInterval.Ticks - (PerformanceCounter - StartTime) mod FInterval.Ticks;
      Stopwatch.Start;
      PreciseSleep(SleepTime);
      Stopwatch.Stop;
      Inc(FIdleTime, Stopwatch.Elapsed.Ticks);
    end;
  finally
    SleepTime.Free;
    Stopwatch.Free;
  end;
end;

procedure TSxThreadTimer.SetEnabled(const Value: BG);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if FEnabled then
      Resume
    else
      Suspend;
  end;
end;

procedure TSxThreadTimer.SetOnTimer(const Value: TNotifyEvent);
begin
  FOnTimer := Value;
end;

procedure TSxThreadTimer.StopAndDestroy;
begin
  FRun := False;
end;

end.
