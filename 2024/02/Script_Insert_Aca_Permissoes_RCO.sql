DECLARE

BEGIN

  INSERT INTO crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('LISTAR_DETALHE_MONITOR'
    ,'TELA_PCRCMP'
    ,'PC_LISTAR_DETALHE_MONITOR_ACMP615_640'
    ,'pr_dtmovimento, pr_idciclo'
    ,2504);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441');
    RAISE;
  
END;
