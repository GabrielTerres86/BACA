BEGIN
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr
                     ) 
               VALUES('LEITURA_RET_B3'
                     ,'TELA_IMOVEL'
                     ,'pc_leitura_arquivo_conciliacao'
                     ,'pr_cdoperad'
                     ,625
                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
