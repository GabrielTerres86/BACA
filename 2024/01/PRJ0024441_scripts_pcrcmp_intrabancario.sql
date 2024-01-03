DECLARE

  TYPE Colaboradores IS TABLE OF VARCHAR2(100);
  operador Colaboradores := Colaboradores('F0033180'
                                         ,'F0034495'
                                         ,'F0033352'
                                         ,'F0033031'
                                         ,'F0030248'
                                         ,'F0031129'
                                         ,'f0031979'
                                         ,'f0030892'
                                         ,'f0034418');

  vr_operador VARCHAR2(20);

BEGIN

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('LISTAR_MOVIMENTO_INTERINTRA'
    ,'TELA_PCRCMP'
    ,'PC_LISTAR_MOVIMENTO_INTERINTRA'
    ,'pr_dtpagamento, pr_tipo_arrecadacao, pr_codigo_barras, pr_conta_emissor, pr_conta_pagador, pr_nosso_numero, pr_tipo_ciclo, pr_valor_de, pr_valor_ate, pr_nrregist,pr_nriniseq'
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('BUSCAR_FILTROS_INTERINTRA'
    ,'TELA_PCRCMP'
    ,'PC_BUSCAR_FILTROS_INTERINTRA'
    ,''
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));
    
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

  UPDATE cecred.craptel
     SET CDOPPTEL = 'C,M,A,I'
        ,NMROTINA = 'CONCILIACAO,MOVIMENTO ANALITICO,MONITOR ARQUIVO,MOVIMENTO INTRABANCARIO'
   WHERE LSOPPTEL = 'PCRCMP';

  FOR i IN operador.FIRST .. operador.LAST LOOP
    vr_operador := operador(i);
  
    INSERT INTO CECRED.crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
    VALUES
      ('PCRCMP'
      ,'I'
      ,vr_operador
      ,' '
      ,3
      ,1
      ,0
      ,2);
  
  END LOOP;

  UPDATE CECRED.crapprm p
     SET p.dsvlrprm = 'cecred/acmp/relatorios'
   WHERE p.nmsistem = 'CRED'
     AND p.cdacesso = 'ROOT_ACMPS';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441');
    RAISE;
  
END;
