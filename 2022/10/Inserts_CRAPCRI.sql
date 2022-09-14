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
    '10610 - Falha rotina contacorrente.incluirArquivoSolicitacaoDevolucao',
    1,
    0);
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10611,
    '10611 - Falha rotina contacorrente.incluirSolicitacaoValorDevolver',
    1,
    0);   
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10612,
    '10612 - Falha rotina contacorrente.incluirSituacaoSolicitacaoDevolucao',
    1,
    0);        

  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10613,
    '10613 - Arquivo XML 9810 invalido',
    1,
    0);    

  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10614,
    '10614 - Dados inválidos do registro no Arquivo 9810',
    1,
    0);  
    
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10615,
    '10615 - Falha rotina contacorrente.buscarContaAdministrativaCooperativa',
    1,
    0);          
           
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10616,
    '10616 - Falha rotina contacorrente.buscarLimiteDevolucaoPix',
    1,
    0);          
       
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10617,
    '10617 - Lancamentos Conta Administrativa nao encontrados',
    1,
    0);          
       
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (10618,
    '10618 - Falha rotina contacorrente.validarSolicitacoesLimitePix',
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
