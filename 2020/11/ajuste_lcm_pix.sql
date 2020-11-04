rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
-- Created on 04/11/2020 by F0032990 
declare 
  CURSOR cr_craplcm IS
      select t.cdcooper, t.nrdconta, t.dtmvtolt, t.cdhistor, h.dshistor, t.vllanmto, h.indebcre, t.progress_recid
      from craplcm t, craphis h
      where t.cdcooper=h.cdcooper and t.cdhistor=h.cdhistor
      and (t.cdcooper, t.nrdconta) IN (
                SELECT DISTINCT t.cdcooper, t.nrdconta
                from craplem t, craphis h
                where t.cdcooper=h.cdcooper and t.cdhistor=h.cdhistor
                and t.cdcooper IN (1, 16, 3) and t.cdhistor IN (1077, 1047,1044,1039)
                and t.dtmvtolt='03/11/2020' AND t.dthrtran > to_date('04/11/2020 06:00','DD/MM/RRRR Hh24:MI'))
      AND t.cdpesqbb LIKE '%.%'
      AND t.dtmvtolt = '03/11/2020' AND t.dttrans > to_date('04/11/2020 06:00','DD/MM/RRRR Hh24:MI')
      AND h.indebcre = 'D';
      
begin

  FOR rw_craplcm IN cr_craplcm LOOP
    UPDATE craplcm l
       SET l.dtmvtolt = '04/11/2020'
     WHERE l.progress_recid = rw_craplcm.progress_recid;
  END LOOP;

  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
