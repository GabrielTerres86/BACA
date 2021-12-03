BEGIN
  
  
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('RETORNA_DADOS_PREST', 'SEGU0003', 'pc_retorna_dados_prest', 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nrctrseg,pr_flggarad', 1804);

  COMMIT;   

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
