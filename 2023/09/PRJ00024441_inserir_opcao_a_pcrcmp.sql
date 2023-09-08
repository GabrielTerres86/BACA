BEGIN
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
    ,(SELECT NRSEQRDR
       FROM CECRED.craprdr
      WHERE NMPROGRA = 'TELA_PCRCMP'));
  COMMIT;
END;
