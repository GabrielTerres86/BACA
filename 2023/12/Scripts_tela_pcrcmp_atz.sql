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

  INSERT INTO CECRED.craprdr
    (NMPROGRA
    ,DTSOLICI)
  VALUES
    ('TELA_PCRCMP'
    ,SYSDATE);

  INSERT INTO CRAPPRG
    (NMSISTEM
    ,CDPROGRA
    ,DSPROGRA##1
    ,DSPROGRA##2
    ,DSPROGRA##3
    ,DSPROGRA##4
    ,NRSOLICI
    ,NRORDPRG
    ,INCTRPRG
    ,CDRELATO##1
    ,CDRELATO##2
    ,CDRELATO##3
    ,CDRELATO##4
    ,CDRELATO##5
    ,INLIBPRG
    ,CDCOOPER
    ,QTMINMED)
  VALUES
    ('CRED'
    ,'PCRCMP'
    ,'Consulta informacoes ACMPs'
    ,' '
    ,' '
    ,' '
    ,0
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP')
    ,1
    ,0
    ,0
    ,0
    ,0
    ,0
    ,3
    ,3
    ,NULL);

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('LISTAR_MOVIMENTO_ANALITICO_CSV'
    ,'TELA_PCRCMP'
    ,'PC_LISTAR_MOVIMENTO_ANALITICO_CSV'
    ,'pr_dtmovimento, pr_nrispbif_recebedora, pr_nrispbif_favorecida, pr_tipo_documento, pr_codigo_barras, pr_id_baixa, pr_id_titulo, pr_tipo_lancamento, pr_tipo_ciclo, pr_valor_de, pr_valor_ate'
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('LISTA_CONCILIACAO'
    ,'TELA_PCRCMP'
    ,'PC_LISTA_CONCILIACAO'
    ,'pr_dtmovimento'
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('BUSCAR_FILTROS_MOVIMENTO'
    ,'TELA_PCRCMP'
    ,'PC_BUSCAR_FILTROS_MOVIMENTO'
    ,NULL
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));

  INSERT INTO CECRED.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('LISTAR_MOVIMENTO_ANALITICO'
    ,'TELA_PCRCMP'
    ,'PC_LISTAR_MOVIMENTO_ANALITICO'
    ,'pr_dtmovimento, pr_nrispbif_recebedora, pr_nrispbif_favorecida, pr_tipo_documento, pr_codigo_barras, pr_id_baixa, pr_id_titulo, pr_tipo_lancamento, pr_tipo_ciclo, pr_valor_de, pr_valor_ate, pr_nrregist,pr_nriniseq'
    ,(SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_PCRCMP'));

  INSERT INTO CECRED.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PCRCMP_MONITORAR_ARQUIVO'
    ,'TELA_PCRCMP'
    ,'pc_listar_monitor_acmp615_640'
    ,'pr_dtmovimento'
    ,(SELECT NRSEQRDR FROM CECRED.craprdr WHERE NMPROGRA = 'TELA_PCRCMP'));    
    
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
    
  INSERT INTO craptel
    (NMDATELA
    ,NRMODULO
    ,CDOPPTEL
    ,TLDATELA
    ,TLRESTEL
    ,FLGTELDF
    ,FLGTELBL
    ,NMROTINA
    ,LSOPPTEL
    ,INACESSO
    ,CDCOOPER
    ,IDSISTEM
    ,IDEVENTO
    ,NRORDROT
    ,NRDNIVEL
    ,NMROTPAI
    ,IDAMBTEL)
  VALUES
    ('PCRCMP'
    ,5
    ,'C,M,A'
    ,'CONCILIACAO ACMP'
    ,'CONCILIACAO ACMP'
    ,0
    ,1
    ,' '
    ,'CONCILIACAO,MOVIMENTO ANALITICO,MONITOR ARQUIVO'
    ,2
    ,3
    ,1
    ,0
    ,1
    ,1
    ,' '
    ,2);

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
      ,'C'
      ,vr_operador
      ,' '
      ,3
      ,1
      ,0
      ,2);
    INSERT INTO crapace
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
      ,'M'
      ,vr_operador
      ,' '
      ,3
      ,1
      ,0
      ,2);
      
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
      ,'A'
      ,vr_operador
      ,' '
      ,3
      ,1
      ,0
      ,2);
  END LOOP;

  INSERT INTO CECRED.crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'ROOT_ACMPS'
    ,'Diretorio onde ficarao os arquivos de relatorios acmps'
    ,'/progress/t0035420/micros/cecred/acmp');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441');
    RAISE;
  
END;
