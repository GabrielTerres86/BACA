BEGIN
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    PROGRESS_RECID,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10603,
    '10603 - Bloqueio j� finalizado',
    10603,
    2,
    0);
    
    
    COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir codigo de critica - ' || sqlerrm);
    rollback;
END;    
