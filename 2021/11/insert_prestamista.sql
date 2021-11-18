BEGIN
  
  delete crapaca where NMPROCED = 'pc_atualiza_dados_prest' and NMDEACAO = 'ATUALIZA_PROPOSTA_PREST' and NMPACKAG = 'TELA_ATENDA_SEGURO';

  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values (4775, 'ATUALIZA_PROPOSTA_PREST', 'TELA_ATENDA_SEGURO', 'pc_atualiza_dados_prest', 'pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum', 504);

  COMMIT;   



EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
