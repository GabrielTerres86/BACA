BEGIN
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr
                     ) 
               VALUES('GERAR_ARQ'
                     ,'TELA_IMOVEL'
                     ,'pc_gera_arquivo'
                     ,'pr_cdcooper, pr_dtinclusao, pr_dt_geracao'
                     ,625
                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
