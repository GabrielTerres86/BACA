BEGIN
  
  INSERT INTO CECRED.crapaca (
    nmdeacao
    , nmpackag
    , nmproced
    , lstparam
    , nrseqrdr
  ) VALUES (
    'GERA_LOG_CONSULTA_SERPRO'
    , NULL
    , 'geraLogConsultaSerproWeb'
    , 'pr_nrdconta,pr_nrcpfcgc,pr_inpessoa,pr_tipolog,pr_response,pr_nmttlrfb_new,pr_nmttlrfb_old,pr_cdsitcpf_new,pr_cdsitcpf_old,pr_dtcnscpf_new,pr_dtcnscpf_old,pr_cdnatjur_new,pr_cdnatjur_old'
    , 211
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
