PL/SQL Developer Test script 3.0
34
-- Created on 09/05/2019 by T0031670 
declare 
  CURSOR cr_epr IS
    SELECT t.cdcooper, t.nrdconta, t.nrctremp, t.idquaprc
      FROM crapepr t
     WHERE (t.cdlcremp = 6901 OR t.cdfinemp = 69)
       AND t.idquaprc <> 5
       AND t.dtmvtolt > '07/05/2018'
       AND (t.inliquid = 0 OR (t.vlsdprej > 0))
       ;
  rw_epr cr_epr%ROWTYPE;

  i integer;
begin
  --
  FOR rw_epr IN cr_epr LOOP

    UPDATE crawepr t
       SET t.idquapro = 5
     WHERE t.cdcooper = rw_epr.cdcooper
       AND t.nrdconta = rw_epr.nrdconta
       AND t.nrctremp = rw_epr.nrctremp;

  END LOOP; 

  UPDATE crapepr t
     SET t.idquaprc = 5
   WHERE t.cdlcremp = 6901
     AND t.idquaprc <> 5
     AND t.dtmvtolt > '07/05/2018'
     AND (t.inliquid = 0 OR (t.vlsdprej > 0)) ;

  COMMIT;  
end;
0
0
