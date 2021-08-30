begin
  --
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'CONSULTAR_CADPAR', 'ESTE0001', 'pc_consultar_cadpar', 'pr_dsparam', (select nrseqrdr from craprdr where nmprogra = 'ATENDA'));
  --
  commit;
  --
end;
