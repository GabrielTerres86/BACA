BEGIN

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PROCESSA_ARQ_DAMP_FGTS'
    ,'EMPR0025'
    ,'pc_processar_arq_damp_fgts'
    ,'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
