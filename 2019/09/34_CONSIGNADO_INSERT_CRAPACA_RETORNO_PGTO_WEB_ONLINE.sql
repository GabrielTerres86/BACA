DELETE FROM CRAPACA WHERE NMDEACAO = 'PAG_PARC_RETORNO';
insert into cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values
  (SEQACA_NRSEQACA.NEXTVAL,
   'PAG_PARC_RETORNO',
   'EMPR0020',
   'pc_pag_parcela_ret_web',
   NULL,
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
commit;