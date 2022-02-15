BEGIN
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10604,
    '10604 - Tipo da Solicitação de Bloqueio incorreto',
    1,
    0);
    
    
    COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir codigo de critica - ' || sqlerrm);
    rollback;
END;    
