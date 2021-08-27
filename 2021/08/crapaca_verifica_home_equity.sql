BEGIN
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr
                     ) 
               VALUES('VERIFICA_HOME_EQUITY'
                     ,NULL
                     ,'credito.verificarHomeEquity'
                     ,'pr_cdlcremp,pr_flgtpimovel,pr_dsclassi,pr_dscatbem'
                     ,1045
                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
