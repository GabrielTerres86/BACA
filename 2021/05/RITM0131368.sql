update cecred.crapaca
   set lstparam = 'pr_nrseq_quebra_sigilo,pr_protocolo,pr_idsitqbr,pr_iniregis,pr_qtregpag'
 where nrseqaca = 3501
   and nmdeacao = 'QBRSIG_CON_QUEBRA';

commit;