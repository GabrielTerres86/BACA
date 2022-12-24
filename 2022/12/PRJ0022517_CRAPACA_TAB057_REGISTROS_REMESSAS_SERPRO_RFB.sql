BEGIN

  INSERT INTO cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
      VALUES ('TAB057_REGISTROS_REMESSAS_SERPRO_RFB', 'TELA_TAB057', 'pc_busca_registros_remessas_serpro_receita_federal', 'pr_idremessaserpro,pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoReproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_ocorrenc,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TAB057'));
    
  COMMIT;
END;
