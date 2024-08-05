declare
  vr_nrseqrdr cecred.crapaca.nrseqrdr%type;
begin
  insert into cecred.craprdr
    (nmprogra, dtsolici)
  values
    ('VAN', sysdate)
  returning nrseqrdr into vr_nrseqrdr;

  insert into cecred.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
    ('INSERIRADESAOVANXML',
     null,
     'pagamento.inserirAdesaoVanXml',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr);

  insert into cecred.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
    ('CANCELARADESAOVANXML',
     null,
     'pagamento.cancelarAdesaoVanXml',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr);
     
  insert into cecred.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
    ('VALIDARADESAOVANXML',
     null,
     'pagamento.validarAdesaoVanXml',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr);     

  commit;
exception
  when others then
    rollback;
    sistema.excecaoInterna(pr_compleme => 'PRJ0025080-VAN');
end;
