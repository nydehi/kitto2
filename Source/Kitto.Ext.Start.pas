{-------------------------------------------------------------------------------
   Copyright 2012 Ethea S.r.l.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-------------------------------------------------------------------------------}

unit Kitto.Ext.Start;

interface

type
  TKExtStart = class
  private
  class var
    FServiceName: string;
    FServiceDisplayName: string;
    class procedure Configure;
  public
    class property ServiceName: string read FServiceName write FServiceName;
    class property ServiceDisplayName: string read FServiceDisplayName write FServiceDisplayName;
    class procedure Start;
  end;

implementation

uses
  SysUtils
  , Classes
  {$IFDEF MSWINDOWS}
  , Vcl.Forms
  , Vcl.SvcMgr
  , ShlObj
  , Vcl.Themes
  , Vcl.Styles
  {$ENDIF}
  , EF.Logger
  , EF.Localization
  , Kitto.Config
  {$IFDEF MSWINDOWS}
  , Kitto.Ext.MainFormUnit
  , Kitto.Ext.Service
  {$ENDIF}
  ;

{ TKExtStart }

class procedure TKExtStart.Configure;
var
  LConfig: TKConfig;
begin
  LConfig := TKConfig.Create;
  try
    TEFLogger.Instance.Configure(LConfig.Config.FindNode('Log'), LConfig.MacroExpansionEngine);
    FServiceName := TKConfig.AppName;
    FServiceDisplayName := _(LConfig.AppTitle);
  finally
    FreeAndNil(LConfig);
  end;
end;

class procedure TKExtStart.Start;
begin
  Configure;

  if not FindCmdLineSwitch('a') then
  begin
    {$IFDEF MSWINDOWS}
    TEFLogger.Instance.Log('Starting as service.');
    if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing then
      Vcl.SvcMgr.Application.Initialize;
    Vcl.SvcMgr.Application.CreateForm(TKExtService, KExtService);
    KExtService.Name := FServiceName;
    KExtService.DisplayName := FServiceDisplayName;
    Vcl.SvcMgr.Application.Run;
    {$ELSE}
    TEFLogger.Instance.Log('Services not yet supported on this platform.');
    {$ENDIF}
  end
  else
  begin
    {$IFDEF MSWINDOWS}
    TEFLogger.Instance.Log('Starting as application.');
    Vcl.Forms.Application.Initialize;
    Vcl.Forms.Application.CreateForm(TKExtMainForm, KExtMainForm);
    Vcl.Forms.Application.Run;
    {$ELSE}
    TEFLogger.Instance.Log('GUI applications not yet supported on this platform.');
    {$ENDIF}
  end;
end;

initialization
  {$IFDEF MSWINDOWS}
  {$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  {$ENDIF}

end.
