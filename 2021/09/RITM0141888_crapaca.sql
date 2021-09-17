begin
  --
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('CONSULTAR_CADPAR', 'ESTE0001', 'pc_consultar_cadpar', 'pr_dsparam', (select nrseqrdr from craprdr where nmprogra = 'ATENDA'));
  --
  commit;
  --
end;
/