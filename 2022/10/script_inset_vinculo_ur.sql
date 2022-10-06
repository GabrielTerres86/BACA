BEGIN
  INSERT INTO cecred.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('OBTER_FINALIDADE_CERC'
    ,null
    ,'credito.obterfinalidadecercweb'
    ,'pr_cdfinemp'
    ,1045);
    
  INSERT INTO cecred.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('BUSCA_UNIDADE_RECEBIVEL'
    ,null
    ,'credito.obterUnidadeRecebivelWeb'
    ,'pr_cdcooper,pr_nrdconta,pr_nrcontrato'
    ,1045);  
    
  INSERT INTO cecred.crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('VINCULA_UNIDADE_RECEBIVEL'
    ,null
    ,'credito.incluirUnidadeRecebivelWeb'
    ,'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_unidrec'
    ,1045);  
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
