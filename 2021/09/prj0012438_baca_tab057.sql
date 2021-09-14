Begin 
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('TAB057_REPROCESSA_ARQ_FGTS', 'TELA_TAB057', 'pc_reproc_arq_fgts', 
  pr_cdcooper,pr_idprogre,pr_cdconven,pr_dtmvtolt,pr_nrseqpag, 1184);

  insert into crapaca
  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
  ('GERAR_ARQ_FGTS', 'TELA_TAB057', 'pc_gerar_arq_fgts', 'pr_cdcooper,pr_dtmvtolt,pr_cdconven', '1184');

  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('TAB057_DET_ARRECADA_AILOS', 'TELA_TAB057', 'pc_detalhar_arrecada_ailos', 'pr_cdcooper,pr_cdconven,pr_dtmvtolt,pr_nrsequen,pr_nriniseq,pr_nrregist', 1184);

  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('TAB057_LISTA_ARRECADACOES_CAIXA', 'TELA_TAB057', 'pc_lista_arrecadacoes_caixa', 'pr_cdcooper,pr_cdcoptel,pr_cdempres,pr_dtiniper,pr_dtfimper,pr_nriniseq,pr_nrregist,pr_cdstatus,pr_cdocorre', 1184);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'DIR_CEF_CONNECT_ENVIADOS', 'Diretorio dos arquivos já enviados para CEF', '/usr/connect/CAIXA/enviados/');

  commit; 

end; 