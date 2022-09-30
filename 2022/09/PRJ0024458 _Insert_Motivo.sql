DECLARE
BEGIN

  FOR rw_coop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP
  
    FOR rw_ocorr IN (SELECT DISTINCT m.cdocorre
                       FROM crapmot m
                      WHERE m.cdcooper = rw_coop.cdcooper
                        AND m.cdocorre IN (6, 17, 76, 77)) LOOP
      INSERT INTO CRAPMOT
        (CDCOOPER
        ,CDDBANCO
        ,CDOCORRE
        ,TPOCORRE
        ,CDMOTIVO
        ,DSMOTIVO
        ,DSABREVI
        ,CDOPERAD
        ,DTALTERA
        ,HRTRANSA)
      VALUES
        (rw_coop.cdcooper
        ,85
        ,rw_ocorr.cdocorre
        ,2
        ,'38'
        ,'Liq Corresp Digital'
        ,''
        ,1
        ,SYSDATE
        ,to_char(SYSDATE, 'sssss'));
    END LOOP;
  END LOOP;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024458');
    DBMS_OUTPUT.put_line(SQLERRM);
    ROLLBACK;
END;
