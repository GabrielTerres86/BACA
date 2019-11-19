BEGIN
  INSERT INTO crapaca(nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
               VALUES('ALTERA_PRODUTO_SLIP','TELA_SLIP','pc_altera_produto','pr_cdproduto_servico,pr_dsproduto_servico',1486);
  
  INSERT INTO crapaca(nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
               VALUES('BUSCA_PRODUTO_OPE_SLIP','TELA_SLIP','pc_busca_produtos',NULL,1486);

  INSERT INTO crapaca(nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
               VALUES('BUSCA_PRODUTO_OPE_LANC_SLIP','TELA_SLIP','pc_busca_produtos_lanc','pr_cdcooper,pr_nrseqlan',1486);
  
  INSERT INTO crapaca(nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
               VALUES('INSERE_PRODUTO_SLIP','TELA_SLIP','pc_insere_produto','pr_cdproduto_servico,pr_dsproduto_servico',1486);

  INSERT INTO crapaca(nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
               VALUES('VALIDA_PRODUTO_SLIP','TELA_SLIP','pc_valida_produto','pr_cdproduto_servico',1486);

  UPDATE crapaca c
     SET c.lstparam = c.lstparam||',pr_lscdproduto_servico'
   WHERE c.nmdeacao = 'INSERE_LANCAMENTO';

  UPDATE crapaca c
     SET c.lstparam = c.lstparam||',pr_lscdproduto_servico'
   WHERE c.nmdeacao = 'ALTERA_LANCAMENTO';

  COMMIT;
END;