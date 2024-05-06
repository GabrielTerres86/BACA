DECLARE

BEGIN

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('LISTAR_MOVIMENTO_INTERINTRA_CSV'
    ,'TELA_PCRCMP'
    ,'PC_LISTAR_MOVIMENTO_INTERINTRA_CSV'
    ,'pr_dtpagamento, pr_tipo_arrecadacao, pr_codigo_barras, pr_conta_emissor, pr_conta_pagador, pr_nosso_numero, pr_tipo_ciclo, pr_valor_de, pr_valor_ate'
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441');
    RAISE;
  
END;
