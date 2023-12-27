rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
DECLARE
  vr_progress_recid crapobs.progress_recid%type;
  
BEGIN
  
  select max(cecred.crapobs.progress_recid) into vr_progress_recid from crapobs;
  
  EXECUTE IMMEDIATE 'ALTER SEQUENCE CECRED.CRAPOBS_SEQ RESTART START WITH ' || vr_progress_recid;
  commit;
exception
  when others then
    dbms_output.put_line('erro:' || sqlerrm);
END;
/
