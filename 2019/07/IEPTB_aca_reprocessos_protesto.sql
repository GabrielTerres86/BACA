BEGIN 
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
  VALUES ('REPROCESSA_PROTESTO', 'TELA_MANPRT', 'pc_reprocessa_protesto', 'pr_tpreproc,pr_cdoperad', 1284);
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
  VALUES ('BUSCA_LOG_REENVIO_REMESSA', 'TELA_MANPRT', 'pc_buscar_log_reenvio_remessa', '', 1284);
  
  commit;
END;
