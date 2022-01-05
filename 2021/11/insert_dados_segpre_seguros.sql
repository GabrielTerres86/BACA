BEGIN
  
  
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('RETORNA_DADOS_SEGPRE', 'TELA_ATENDA_SEGURO', 'pc_retorna_dados_segpre', 'pr_cdcooper,pr_nrdconta,pr_nrctrseg,pr_nrctremp', 504);

  COMMIT;   



EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
