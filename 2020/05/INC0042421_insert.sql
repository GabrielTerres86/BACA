begin
  insert into crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
    ('BUSCAR_TODAS_CONTAS_POR_CPF_CNPJ',
     'CADA0003',
     'pc_lista_todas_contas',
     'pr_nrcpfcgc',
     (select cr.nrseqrdr from craprdr cr where cr.nmprogra = 'CADA0003'));
   commit;
end;