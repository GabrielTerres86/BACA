BEGIN
  /* Inclusao da acao CONSULTA_REMESSAS para consulta de Remessas na interface web.
  */

  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('CONSULTA_REMESSAS','TELA_PRONAM','pc_consultar_remessas_web','pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_PRONAM' AND ROWNUM = 1));

  COMMIT;
END;
