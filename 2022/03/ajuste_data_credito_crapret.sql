DECLARE
  CURSOR cr_crapret IS
    SELECT ret.rowid, ret.dtcredit
      FROM crapret ret
          ,(SELECT (SELECT ceb.cdcooper
                      FROM crapceb ceb
                     WHERE ceb.nrconven = to_number(substr(tit.dscodbar, 20, 6))
                       AND ceb.nrdconta = to_number(substr(tit.dscodbar, 26, 8))) cdcooper
                  ,to_number(substr(tit.dscodbar, 20, 6)) nrcnvcob
                  ,to_number(substr(tit.dscodbar, 26, 8)) nrdconta
                  ,to_number(substr(tit.dscodbar, 34, 9)) nrdocmto
              FROM gncptit tit
             WHERE tit.cdcooper BETWEEN 1 AND 16
               AND tit.dtmvtolt = to_date('25032022', 'ddmmyyyy')
               AND tit.cdbandst = 85
               AND tit.nmarquiv = '29999525_REP.RET') a
     WHERE ret.nrdocmto = a.nrdocmto
       AND ret.nrdconta = a.nrdconta
       AND ret.nrcnvcob = a.nrcnvcob
       AND ret.cdcooper = a.cdcooper
          
       AND ret.dtcredit IN ('25/03/2022', '28/03/2022')
       AND ret.flcredit = 0
          
       AND ret.cdocorre IN (6, 17, 76, 77);
BEGIN
  FOR rw_crapret IN cr_crapret LOOP
    UPDATE crapret SET crapret.dtcredit = TO_DATE('30/03/2022','DD/MM/YYYY') WHERE crapret.rowid = rw_crapret.rowid;
    COMMIT;
  END LOOP;
END;
