/* PRB0043715 - Inserir nova acão de tela */

BEGIN

  insert into crapaca(nmdeacao, nmpackag, nmProced, lstParam, nrseqrdr)
  values('JOB_CUSAPL_LISTA_CONT_ARQ', 'TELA_CUSAPL', 'pc_executa_carga_job',
         'pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3,pr_inacao,pr_nrregist,pr_nriniseq, pr_idarquivo', 1249);
  Commit;
END;