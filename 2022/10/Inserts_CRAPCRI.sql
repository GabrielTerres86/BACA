DECLARE
  vr_code NUMBER;
  vr_errm VARCHAR2(64);
BEGIN
  
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10610,
    '10610 - Falha rotina contacorrente.incluirResumoValorDevolver9810',
    1,
    0);
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10611,
    '10611 - Falha rotina contacorrente.incluirDetalheValorDevolver9810',
    1,
    0);    
       
    
  COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao inserir codigo de critica - ' || vr_code || ' / ' || vr_errm);
END;    
