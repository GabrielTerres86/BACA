BEGIN

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (0
    ,'Baixa Operacional Integral Interbancaria');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (1
    ,'Baixa Operacional Integral Intrabancaria');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (2
    ,'Baixa Operacional Parcial Intrabancaria');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (3
    ,'Baixa Operacional Parcial Interbancaria');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (4
    ,'Baixa Operacional Integral PIX');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (5
    ,'Baixa Operacional Integral por Solicitacao do Cedente');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (6
    ,'Baixa Operacional Integral por envio para Protesto');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (7
    ,'Baixa Operacional Integral por Decurso de Prazo');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (8
    ,'Baixa Operacional Integral por solicitacao da Instituicao Destinataria');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (9
    ,'Baixa Operacional Integral Interbancaria – Liquidacao via STR');

  INSERT INTO pagamento.ta_baixa_operacional
    (CDBAIXA_OPERACIONAL
    ,DSBAIXA_OPERACIONAL)
  VALUES
    (10
    ,'Baixa Operacional Parcial Interbancaria – Liquidacao via STR');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (1
    ,'Agencias – Postos tradicionais');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (2
    ,'Terminal de Autoatendimento');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (3
    ,'Internet (home / office banking)');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (5
    ,'Correspondente bancario');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (6
    ,'Central de atendimento (Call Center)');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (7
    ,'Arquivo Eletronico');

  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (8
    ,'DDA');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0023522');
    ROLLBACK;
END;
