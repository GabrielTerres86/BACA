BEGIN
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10603,
    '10603 - Bloqueio já finalizado',
    2,
    0);
    
    
    COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir codigo de critica - ' || sqlerrm);
    rollback;
END;    
