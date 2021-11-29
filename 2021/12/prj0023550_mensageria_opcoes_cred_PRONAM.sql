BEGIN
  INSERT 
  INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('CONSULTA_CONTRATOS_OP', 'TELA_PRONAM', 'pc_consultar_contratos_op_web', 'pr_cdcooper,pr_nrdconta,pr_nriniseq,pr_nrregist,pr_dtini,pr_dtfim,pr_stop', 2304);
   
  INSERT 
  INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('CONSULTA_CONTRATOS_LI', 'TELA_PRONAM', 'pc_consultar_contratos_li_web', 'pr_cdcooper,pr_nrdconta,pr_nrdocumento,pr_nriniseq,pr_nrregist,pr_dtini,pr_dtfim,pr_stop', 2304);
   
  INSERT 
  INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('CANCELA_CONTRATOS', 'TELA_PRONAM', 'pc_cancela_contratos_web', 'pr_cdcooper,pr_nrdconta,pr_nrcontrato', 2304);
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;    

