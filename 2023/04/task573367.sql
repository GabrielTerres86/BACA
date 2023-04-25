DECLARE

  CURSOR cr_contratos IS
    SELECT contratos.cdcooper
          ,contratos.nrdconta
          ,contratos.nrctremp
          ,contratos.qtdmesesadd
      FROM (SELECT 13     AS cdcooper
                  ,493376 AS nrdconta
                  ,269616 AS nrctremp
                  ,2      AS qtdmesesadd
              FROM dual
            UNION ALL
            SELECT 16     AS cdcooper
                  ,532169 AS nrdconta
                  ,632666 AS nrctremp
                  ,2      AS qtdmesesadd
              FROM dual
            UNION ALL
            SELECT 13     AS cdcooper
                  ,669555 AS nrdconta
                  ,273761 AS nrctremp
                  ,1      AS qtdmesesadd
              FROM dual
            
            UNION ALL
            SELECT 13     AS cdcooper
                  ,669555 AS nrdconta
                  ,273760 AS nrctremp
                  ,1      AS qtdmesesadd
              FROM dual
            UNION ALL
            SELECT 13     AS cdcooper
                  ,669555 AS nrdconta
                  ,273764 AS nrctremp
                  ,1      AS qtdmesesadd
              FROM dual
            UNION ALL
            SELECT 13     AS cdcooper
                  ,669555 AS nrdconta
                  ,273769 AS nrctremp
                  ,1      AS qtdmesesadd
              FROM dual
            UNION ALL
            SELECT 13     AS cdcooper
                  ,669555 AS nrdconta
                  ,273756 AS nrctremp
                  ,1      AS qtdmesesadd
              FROM dual
            UNION ALL
            SELECT 13     AS cdcooper
                  ,190098 AS nrdconta
                  ,276169 AS nrctremp
                  ,1      AS qtdmesesadd
              FROM dual) contratos;

  rw_contratos cr_contratos%ROWTYPE;

BEGIN

  OPEN cr_contratos;
  LOOP
    FETCH cr_contratos
      INTO rw_contratos;
    EXIT WHEN cr_contratos%NOTFOUND;
  
    UPDATE cecred.crappep pep
       SET pep.dtvencto = add_months(pep.dtvencto, rw_contratos.qtdmesesadd)
     WHERE pep.cdcooper = rw_contratos.cdcooper
       AND pep.nrdconta = rw_contratos.nrdconta
       AND pep.nrctremp = rw_contratos.nrctremp;
  
  END LOOP;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
