create or replace package log is

  -- Author  : TSG
  -- Created : 08.12.2005 16:54:37
  -- Purpose :

  procedure putline(mess in varchar2, code in number := 0);

  procedure saveline(mess in varchar2, code in number := 0);

end log;
/
create or replace package body log is

cursor sess is
       select machine, program from sys.v_$session where audsid = userenv('sessionid');
       rec sess%rowtype;
-----------------------------------------------
procedure putline(mess in varchar2, code in number)
is
begin
     insert into log_table (log_code, log_mess, comp, prog)
--     values(code, mess, '1', '2');
      values(code, mess, rec.machine, rec.program);
end;
----------------------------------------------------
procedure saveline(mess in varchar2, code in number := 0)
is
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  putline(mess, code);
  commit;
  exception when others then rollback;
end;

begin

     open sess;
     fetch sess into rec;
     close sess;

end log;
/
