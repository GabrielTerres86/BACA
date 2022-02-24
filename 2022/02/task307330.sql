DECLARE

  cursor c01 is
    SELECT crapttl.nrcpfcgc    AS nrcpfcgc,
       calparm.tpcooperado AS tpcooperado,
       cadpess.tppessoa    AS inpessoa
FROM   cecred.crapass crapass,
       cecred.crapttl,
       cecred.tbcadast_pessoa cadpess,
       cecred.tbcalris_parametros calparm
WHERE  crapttl.nrcpfcgc NOT IN(SELECT tanque.nrcpfcgc
                               FROM   cecred.tbcalris_tanque tanque
                               WHERE  tanque.tpcalculadora IN ( 1, 2 ))
       AND crapass.nrcpfcgc = cadpess.nrcpfcgc
       AND crapass.inpessoa = calparm.inpessoa
       AND crapttl.nrdconta = crapass.nrdconta
       AND crapttl.cdcooper = crapass.cdcooper
       AND calparm.cdsituacao = 2
       AND calparm.tpcooperado = 'N'
       AND crapass.dtdemiss IS NULL
       AND (crapass.dtabtcct IS NOT NULL OR(crapass.dtabtcct IS NULL AND crapass.dtadmiss <= trunc(SYSDATE) - 1)); 

  TYPE tb_cursor IS TABLE OF C01%ROWTYPE index by pls_integer;
  tb_c01    tb_cursor;

BEGIN

  OPEN C01;
  LOOP
    FETCH C01 BULK COLLECT
      INTO tb_c01;
    FORALL I IN tb_c01.FIRST .. tb_c01.LAST
      INSERT INTO tbcalris_tanque (nrcpfcgc, tpcooperado, cdstatus, dhinicio, tpcalculadora)
         VALUES (tb_c01(i).nrcpfcgc, tb_c01(i).tpcooperado, 0, SYSDATE, tb_c01(i).inpessoa);
    COMMIT;
    EXIT;
  END LOOP;
  CLOSE C01;
  
  EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RAISE_application_error(-20500, SQLERRM);

END;