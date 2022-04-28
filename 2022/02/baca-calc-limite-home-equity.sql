BEGIN

  INSERT INTO crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('VALIDA_HOME_EQUITY_LIMITE'
    ,NULL
    ,'CREDITO.validarHomeEquityLimite'
    ,'pr_vlsomabem,pr_vlemprst,pr_cdlcremp,pr_cdzonaimovel,pr_dsclassi,pr_dscatbem'
    ,1045);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
