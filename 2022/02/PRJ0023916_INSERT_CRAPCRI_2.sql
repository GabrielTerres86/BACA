BEGIN
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10605,
    '10605 - Relação do Tipo da Solicitação de Bloqueio e Tipo de Pessoa inválido',
    1,
    0);
    
    
    COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir codigo de critica - ' || sqlerrm);
    rollback;
END;    
