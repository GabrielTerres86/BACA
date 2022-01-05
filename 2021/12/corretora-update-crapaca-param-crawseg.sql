begin

 update crapaca a 
    set a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum,pr_tpcustei'
  where a.nmdeacao = 'ATUALIZA_PROPOSTA_PREST'
    and a.nmpackag = 'TELA_ATENDA_SEGURO'
    and a.nmproced = 'pc_atualiza_dados_prest';
  
commit;

end;