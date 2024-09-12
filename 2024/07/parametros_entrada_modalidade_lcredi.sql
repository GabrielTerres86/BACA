BEGIN
     
  INSERT INTO CRAPACA (NMDEACAO, 
                       NMPACKAG, 
                       NMPROCED, 
                       LSTPARAM, 
                       NRSEQRDR)
              VALUES ('BUSCAMOD_LCREDI', 
                      'TELA_LCREDI', 
                      'pc_busca_desc_modalidade', 
                      'pr_nrregist, pr_nriniseq, pr_cdmodali, pr_dsoperac', 
                      483);
                      
  INSERT INTO CRAPACA (NMDEACAO, 
                       NMPACKAG, 
                       NMPROCED, 
                       LSTPARAM, 
                       NRSEQRDR)
              VALUES ('CONSMOD_LCREDI', 
                      'TELA_LCREDI', 
                      'pc_busca_mod_lcredi_web', 
                      'pr_nrregist, pr_nriniseq, pr_dsoperac', 
                      483);
     
  COMMIT;
     
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
