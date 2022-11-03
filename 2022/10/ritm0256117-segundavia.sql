BEGIN                      
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONV_URL_BCB',
     'Processo busca comprovantes - Local URL das APIs com Bancoob',
     'apibancoob.ailos.coop.br');

  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONV_URN_BCB_PGTOS',
     'Processo busca comprovantes - Nome URN da API Bancoob para consultar dados de pagamentos',
     '/sicoob/interno/convenios/v1/pagamentos/');

  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONV_BCB_SCOPE_PGTOS',
     'Processo busca comprovantes - Nome do escopo para consultar dados de pagamentos do Bancoob',
     'convenios_consulta_pagamentos');

  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONV_BCB_BASIC',
     'Processo busca comprovantes - Nome BASIC Authorization para as APIs de Pagamentos Bancoob',
     'dl9KV3A2UUNsYXVtelhTU0JPeFJ3cnR4Z1I0YTpvSFlrTHRpZm5hU0E1cTczak1Yal9NaGRQWVlh');

  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONV_BCB_SCOPE_SEGVIA',
     'Processo busca comprovantes - Nome do escopo para consultar dados de segunda via de pagamentos do Bancoob',
     'convenios_pagamento_segunda_via');

  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONVENIO_PROC_REPROC',
     'Processo busca comprovantes - Codigos de resposta de pagamentos SICOOB que necessitam passar por validacao de comprovante, efetivando pagamento ou solicitar reprocessamento',
     '503;504;');

  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONVENIO_REPROC_ATIVO',
     'Processo busca comprovantes - Indica se o serviço de busca de segunda via para integração está ativo 0:Não 1:Sim 3:Contingencia (apenas reenvia para tentar na prox. remessa',
     '1');

  COMMIT;
END;
