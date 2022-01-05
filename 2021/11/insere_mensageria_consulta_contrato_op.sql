BEGIN
  INSERT 
    INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
   VALUES ('CONSULTA_CONTRATOS_OP', 'TELA_PRONAM', 'pc_consultar_contratos_op_web', 'pr_cdcooper,pr_nrdconta,pr_nriniseq,pr_nrregist,pr_dtini,pr_dtfim,pr_stop', 2304);
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;    

