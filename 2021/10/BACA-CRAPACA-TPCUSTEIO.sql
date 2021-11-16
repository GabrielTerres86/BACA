BEGIN
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr
                     ) 
               VALUES('CONSULTA_CRAPLCR_TPCUSPR'
                     ,'TELA_ATENDA_SEGURO'
                     ,'fn_retorna_tpcuspr'
                     ,'pr_cdcooper,pr_cdlcremp'
                     ,504
                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
