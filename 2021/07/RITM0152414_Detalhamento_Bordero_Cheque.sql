DECLARE

BEGIN

  INSERT INTO crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('BUSCA_ACESSO_MOTOR'
    ,'TELA_CONPRO'
    ,'pc_gera_chave_acesso'
    ,'pr_dsprotocolo'
    ,347);

  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'ACCESSKEY_POLITICA_MOTOR'
    ,'Chave AccessKey acesso Motor de Credito'
    ,'AccessKey:5b47fdd0548545e4998336ff4d114607');

  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'SECRETKEY_POLITICA_MOTOR'
    ,'Chave SecretKey acesso Motor de Credito'
    ,'SecretKey:6a2f1bd563014ea1885ecf906c7d8209e1fcc757b2a24876b8d9cff5eae64406bf862e462bbf45418ce9f368ad53a9317fa13e14e4934c26b59575cc2a44c90f');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || SQLERRM);
  
END;
