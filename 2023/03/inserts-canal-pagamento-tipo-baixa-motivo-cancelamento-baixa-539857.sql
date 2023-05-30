BEGIN
  INSERT INTO PAGAMENTO.TA_CANAL_PAGAMENTO
    (cdcanal_pagamento
    ,dscanal_pagamento)
  VALUES
    (4
    ,'PIX');
  INSERT INTO PAGAMENTO.TA_BAIXA_OPERACIONAL
    (cdbaixa_operacional
    ,dsbaixa_operacional)
  VALUES
    (11
    ,'Baixa Integral Interbanc�ria � Liquida��o via COMPE');
  INSERT INTO PAGAMENTO.TA_BAIXA_OPERACIONAL
    (cdbaixa_operacional
    ,dsbaixa_operacional)
  VALUES
    (12
    ,'Baixa Parcial Interbanc�ria � Liquida��o via COMPE');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (40
    ,'C�digo de moeda inv�lido');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (51
    ,'Boleto de pagamento liquidado por valor a maior ou menor');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (52
    ,'Boleto de pagamento recebido ap�s o vencimento sem juros e demais encargos');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (53
    ,'Apresenta��o indevida');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (63
    ,'C�digo de barras em desacordo com as especifica��es');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (68
    ,'Repasse em duplicidade pela IF Recebedora de Boleto de pagamentos liquidados');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (69
    ,'Boletos de pagamento liquidados em duplicidade no mesmo dia');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (71
    ,'Boletos de pagamento recebido com desconto ou abatimento n�o previsto no boleto de pagamento');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (72
    ,'Devolu��o de pagamento fraudado');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (73
    ,'Benefici�rio sem contrato de cobran�a com a Institui��o Financeira destinat�ria');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (74
    ,'CPF/CNPJ do Benefici�rio inv�lido ou n�o confere com o registro de boletos na base da IF destinat�ria');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (75
    ,'CPF/CNPJ do pagador inv�lido ou n�o confere com o registro do boleto na base da IF destinat�ria');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (77
    ,'Boleto em cart�rio ou protestado');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (82
    ,'Boleto divergente da base');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (83
    ,'Boleto inexistente na base');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (85
    ,'Recurso financeiro n�o enviado pela IF Recebedora via COMPE BBProcessador');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441-FASE1');
END;
