DECLARE

  vr_aux_param VARCHAR(1000);

  CURSOR cr_cooperativas IS
    SELECT a.cdcooper
          ,CASE
             WHEN a.cdcooper = 1 THEN
              '850012'
             WHEN a.cdcooper = 16 THEN
              '1017128'
             ELSE
              '0'
           END conta
          ,'3968' historico
      FROM crapcop a
     WHERE a.flgativo = 1;

BEGIN

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1
       FROM crappat)
    ,'HISTORICOS_CRED_BOLETO_IQ'
    ,2
    ,0);

  FOR rw_cooperativas IN cr_cooperativas LOOP
    vr_aux_param := TRIM(vr_aux_param || rw_cooperativas.cdcooper || ',' || rw_cooperativas.conta || ',' ||
                         rw_cooperativas.historico || '/');
  END LOOP;

  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar
       FROM CREDITO.crappat a
      WHERE a.nmpartar = 'HISTORICOS_CRED_BOLETO_IQ')
    ,3
    ,vr_aux_param);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    ROLLBACK;
END;
