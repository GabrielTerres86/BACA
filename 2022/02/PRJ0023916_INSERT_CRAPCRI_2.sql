BEGIN
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10605,
    '10605 - Rela��o do Tipo da Solicita��o de Bloqueio e Tipo de Pessoa inv�lido',
    1,
    0);
    
    
    COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir codigo de critica - ' || sqlerrm);
    rollback;
END;    
