unit libxml2_experimental;
//$Id: libxml2_experimental.pas,v 1.3 2002-02-18 20:32:32 pkozelka Exp $
(**
 * Title:        libxml2 experimental unit
 * Description:  Contains experimental code for support or development of libxml2
 * Copyright:    Copyright (c) 2002
 * Company:
 * @author       Petr Kozelka <pkozelka@email.cz>
 * @version 0.1
 *)
interface

uses
{$IFDEF WIN32}
  windows,
{$ENDIF}
  libxml2;

type
  TMessageHandler = procedure(aMsg: string) of object;

procedure RegisterErrorHandler(aHandler: TMessageHandler);

implementation

uses
  SysUtils;

var
  myErrH: TMessageHandler;

// error output redirected to OutputDebugString

procedure myGenericErrorFunc(ctx: Pointer; msg: PChar); cdecl;
begin
  if Assigned(myErrH) then begin
    myErrH(msg);
  end;
  Writeln(StrPas(msg));
{$IFDEF WIN32}
  OutputDebugString(msg);
{$ENDIF}
{$IFDEF LINUX}
  Writeln(StrToPas(s));
{$ENDIF}
end;

procedure RegisterErrorHandler(aHandler: TMessageHandler);
begin
  myErrH := aHandler;
end;

initialization
  // redirect error output
  xmlSetGenericErrorFunc(nil, @myGenericErrorFunc);

end.

