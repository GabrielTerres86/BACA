BEGIN
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr
                     ) 
               VALUES('VALIDA_HOME_EQUITY'
                     ,NULL
                     ,'CREDITO.validarHomeEquity'
                     ,'pr_cdlcremp,pr_cdzonaimovel,pr_dsclassi,pr_dscatbem'
                     ,1045
                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
