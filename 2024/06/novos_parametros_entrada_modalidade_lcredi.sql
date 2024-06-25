BEGIN
  UPDATE cecred.crapaca c
     SET c.lstparam = c.lstparam || ', pr_cdmodali, pr_dsoperac'
   WHERE c.nmdeacao = 'BUSCAMOD'
     AND c.nmpackag = 'tela_lrotat'
     AND c.nmproced = 'pc_busca_modalidade';
     
  UPDATE cecred.crapaca c
     SET c.lstparam = c.lstparam || ', pr_dsoperac'
   WHERE c.nmdeacao = 'CONSMOD'
     AND c.nmpackag = 'TELA_LCREDI'
     AND c.nmproced = 'pc_busca_modalidade';
     
  COMMIT;
     
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
