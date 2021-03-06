unit uExtProcess;

interface

uses
	uTypes, Windows;

(**
	@return process exit code if success or High(DWORD)
*)
function RunAndWaitForApplication(CommandLine: string; const CurrentDir: string; const FWindowState: SG): DWORD;


var
	ProcessInfo: TProcessInformation;

implementation

uses
	uMsg, uLog,
	SysUtils;

function WaitForApplication(hProcess: UG): UG;
begin
	repeat
		Sleep(LoopSleepTime);
		Result := WaitForSingleObject(hProcess, LoopSleepTime);
	until not (Result = WAIT_TIMEOUT);
end;

function RunAndWaitForApplication(CommandLine: string; const CurrentDir: string; const FWindowState: SG): DWORD;
var
	StartupInfo: TStartupInfo;
begin
	Result := High(Result);

	FillChar(StartupInfo, SizeOf(StartupInfo), 0);
	StartupInfo.cb := SizeOf(StartupInfo);
	StartupInfo.dwFlags := STARTF_USESHOWWINDOW or // STARTF_USEPOSITION or
		STARTF_USESIZE or STARTF_USECOUNTCHARS or STARTF_USEFILLATTRIBUTE;
//			StartupInfo.dwX := R.Left;
//			StartupInfo.dwY := R.Top;
			StartupInfo.dwXCountChars := 128;
			StartupInfo.dwYCountChars := 1024;
			StartupInfo.dwXSize := StartupInfo.dwXCountChars * 8;
			StartupInfo.dwYSize := 400; // StartupInfo.dwYCountChars * 8;
			StartupInfo.dwFillAttribute := FOREGROUND_INTENSITY or BACKGROUND_BLUE;

	StartupInfo.wShowWindow := FWindowState;

	if LogDebug then
    MainLogAdd('CreateProcess: ' + CommandLine, mlDebug);
	if CreateProcess(
		nil,
		PChar(CommandLine),
		nil,
		nil,
		False,
		CREATE_NEW_CONSOLE or
		NORMAL_PRIORITY_CLASS,
		nil,
		PChar(CurrentDir),
		StartupInfo,
		ProcessInfo) then
	begin
		if WaitForApplication(ProcessInfo.hProcess) = WAIT_FAILED then
			IOError(CommandLine, GetLastError);
		if not GetExitCodeProcess(ProcessInfo.hProcess, Result) then
			IOError(CommandLine, GetLastError);
		if LogDebug then
      MainLogAdd('ExitCode: ' + IntToStr(Result), mlDebug);
	end
	else
	begin
		IOError(CommandLine, GetLastError);
	end;
end;

end.
