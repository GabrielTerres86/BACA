begin
insert into crapaca

  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)

values

  ((select max(NRSEQACA) + 1 from crapaca),

   'ATUALIZA_PROPOSTA_PREST',

   'TELA_ATENDA_SEGURO',

   'pc_atualiza_dados_prest',

   'pr_cdcoper,   pr_nrdconta,   pr_nrctrseg, pr_garadici',

   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'TELA_ATENDA_SEGURO'));
   
   commit;
end;
