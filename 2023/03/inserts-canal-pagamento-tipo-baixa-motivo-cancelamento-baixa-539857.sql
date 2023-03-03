BEGIN
  INSERT INTO PAGAMENTO.TA_CANAL_PAGAMENTO
    (cdcanal_pagamento
    ,dscanal_pagamento)
  VALUES
    (4
    ,'PIX');
  --
  INSERT INTO PAGAMENTO.TA_BAIXA_OPERACIONAL
    (cdbaixa_operacional
    ,dsbaixa_operacional)
  VALUES
    (11
    ,'Baixa Integral Interbancária – Liquidação via COMPE');
  INSERT INTO PAGAMENTO.TA_BAIXA_OPERACIONAL
    (cdbaixa_operacional
    ,dsbaixa_operacional)
  VALUES
    (12
    ,'Baixa Parcial Interbancária – Liquidação via COMPE');
  --
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (40
    ,'Código de moeda inválido');
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
    ,'Boleto de pagamento recebido após o vencimento sem juros e demais encargos');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (53
    ,'Apresentação indevida');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (63
    ,'Código de barras em desacordo com as especificações');
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
    ,'Boletos de pagamento recebido com desconto ou abatimento não previsto no boleto de pagamento');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (72
    ,'Devolução de pagamento fraudado');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (73
    ,'Beneficiário sem contrato de cobrança com a Instituição Financeira destinatária');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (74
    ,'CPF/CNPJ do Beneficiário inválido ou não confere com o registro de boletos na base da IF destinatária');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (75
    ,'CPF/CNPJ do pagador inválido ou não confere com o registro do boleto na base da IF destinatária');
  INSERT INTO PAGAMENTO.TBPAGTO_MOTIVO_CANCELAMENTO_BAIXA
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (77
    ,'Boleto em cartório ou protestado');
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
    ,'Recurso financeiro não enviado pela IF Recebedora via COMPE BBProcessador');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441-FASE1');
END;
