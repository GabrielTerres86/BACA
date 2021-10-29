BEGIN
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    PROGRESS_RECID,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10600,
    '10600 - ID de bloqueio vazio ou inv�lido',
    10600,
    2,
    0);
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    PROGRESS_RECID,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10601,
    '10601 - Bloqueio n�o encontrado',
    10601,
    2,
    0);

  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    PROGRESS_RECID,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10602,
    '10602 - Relacao Status e Tipo pessoa inv�lido',
    10602,
    2,
    0);
    
    
    COMMIT;     
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir codigo de critica - ' || sqlerrm);
    rollback;
END;    
