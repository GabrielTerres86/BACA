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
    (10606,
    '10606 - Quantidade de espera/tentativa da cria��o da Solicita��o de Bloqueio Pix atingida',
    1,
    0);
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10607,
    '10607 - Erro ao criar o controle/farol no processo de cria��o da Solicita��o de Bloqueio Pix',
    1,
    0);  
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10608,
    '10608 - Erro ao remover o controle/farol no processo de cria��o da Solicita��o de Bloqueio Pix',
    1,
    0);
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10609,
    '10609 - Par�metros de entrada n�o informados.',
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
