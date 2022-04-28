DECLARE
     rw_contrato credito.tbcred_peac_contrato%ROWTYPE;

    CURSOR cr_peaccontrato IS
      SELECT DISTINCT ctr.cdcooper
            ,ctr.nrdconta
            ,ctr.nrcontrato
        FROM credito.tbcred_peac_contrato ctr
       WHERE ctr.cdcooper = 6
       FETCH FIRST 5 ROWS ONLY;
    rw_peaccontrato cr_peaccontrato%ROWTYPE;
BEGIN
  OPEN cr_peaccontrato;
  
   LOOP
    FETCH cr_peaccontrato INTO rw_peaccontrato;
    
    UPDATE credito.tbcred_peac_contrato ctrLopp
         SET ctrLopp.TPSITUACAOHONRA = 3
    WHERE ctrLopp.cdcooper = rw_peaccontrato.cdcooper
            and ctrLopp.nrdconta = rw_peaccontrato.nrdconta
            and ctrLopp.nrcontrato = rw_peaccontrato.nrcontrato;
    commit;
    
       EXIT WHEN cr_peaccontrato%NOTFOUND;
     END LOOP;
  CLOSE cr_peaccontrato;
END;
