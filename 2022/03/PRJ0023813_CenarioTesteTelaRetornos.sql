BEGIN
  INSERT INTO credito.tbcred_peac_operacao
    (IDPEAC_OPERACAO
    ,IDPEAC_CONTRATO
    ,IDSOLICITACAO
    ,DHOPERACAO
    ,TPOPERACAO
    ,CDSTATUS
    ,VLRECUPERACAO
    ,VLAMORTIZACAO)
  VALUES
    (1
    ,336
    ,1
    ,to_date('04-03-2022', 'dd-mm-yyyy')
    ,0
    ,'APROVADA'
    ,1000.00
    ,500.00);

  INSERT INTO credito.tbcred_peac_operacao
    (IDPEAC_OPERACAO
    ,IDPEAC_CONTRATO
    ,IDSOLICITACAO
    ,DHOPERACAO
    ,TPOPERACAO
    ,CDSTATUS
    ,VLRECUPERACAO
    ,VLAMORTIZACAO)
  VALUES
    (2
    ,1
    ,1
    ,to_date('04-03-2022', 'dd-mm-yyyy')
    ,0
    ,'PENDENTE'
    ,350.00
    ,0.00);

  INSERT INTO credito.tbcred_peac_operacao
    (IDPEAC_OPERACAO
    ,IDPEAC_CONTRATO
    ,IDSOLICITACAO
    ,DHOPERACAO
    ,TPOPERACAO
    ,CDSTATUS
    ,VLRECUPERACAO
    ,VLAMORTIZACAO)
  VALUES
    (3
    ,5
    ,1
    ,to_date('04-03-2022', 'dd-mm-yyyy')
    ,0
    ,'REJEITADA'
    ,0.00
    ,150.00);

  INSERT INTO credito.tbcred_peac_operacao_retorno
    (IDPEAC_OPERACAO_RETORNO
    ,IDPEAC_OPERACAO
    ,DSMENSAGEM
    ,DHRETORNO)
  VALUES
    (1
    ,1
    ,'Parcela maior do que o permitido'
    ,to_date('04-03-2022', 'dd-mm-yyyy'));

  INSERT INTO credito.tbcred_peac_operacao_retorno
    (IDPEAC_OPERACAO_RETORNO
    ,IDPEAC_OPERACAO
    ,DSMENSAGEM
    ,DHRETORNO)
  VALUES
    (2
    ,3
    ,'Operação não permitida'
    ,to_date('08-03-2022', 'dd-mm-yyyy'));

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
