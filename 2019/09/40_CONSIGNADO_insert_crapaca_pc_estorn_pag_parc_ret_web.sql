DELETE FROM CRAPACA WHERE NMDEACAO = 'RETORNO_ESTORN_PGTO_CONSIG';
insert into cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values
  (SEQACA_NRSEQACA.NEXTVAL,
   'RETORNO_ESTORN_PGTO_CONSIG',
   'EMPR0020',
   'pc_estorn_pag_parc_ret_web',
   NULL,
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ESTORN'));
commit;
