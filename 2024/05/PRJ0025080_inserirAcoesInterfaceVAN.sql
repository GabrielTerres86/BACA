declare
  vr_nrseqrdr cecred.crapaca.nrseqrdr%type;
begin
  select max(cecred.craprdr.nrseqrdr) + 1
    into vr_nrseqrdr 
    from cecred.craprdr;

  insert into cecred.craprdr
    (nrseqrdr, nmprogra, dtsolici)
  values
    (vr_nrseqrdr, 'VAN', sysdate);

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