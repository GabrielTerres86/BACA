declare
  vr_nrseqrdr cecred.crapaca.nrseqrdr%type;
  vr_nrseqaca cecred.crapaca.nrseqaca%TYPE;
begin
  select max(cecred.craprdr.nrseqrdr) + 1
    into vr_nrseqrdr 
    from cecred.craprdr;

  insert into cecred.craprdr
    (nrseqrdr, nmprogra, dtsolici)
  values
    (vr_nrseqrdr, 'VAN', sysdate);

  select max(cecred.crapaca.nrseqaca) + 1
    into vr_nrseqaca 
    from cecred.crapaca;

  insert into cecred.crapaca
    ( nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr, nrseqaca)
  values
    ('INSERIRADESAOVANXML',
     null,
     'pagamento.inserirAdesaoVanXml',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr,
     vr_nrseqaca);

  select max(cecred.crapaca.nrseqaca) + 1
    into vr_nrseqaca 
    from cecred.crapaca;

  insert into cecred.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr, nrseqaca)
  values
    ('CANCELARADESAOVANXML',
     null,
     'pagamento.cancelarAdesaoVanXml',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr,
     vr_nrseqaca);

  select max(cecred.crapaca.nrseqaca) + 1
    into vr_nrseqaca 
    from cecred.crapaca;
     
  insert into cecred.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr, nrseqaca)
  values
    ('VALIDARADESAOVANXML',
     null,
     'pagamento.validarAdesaoVanXml',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr,
     vr_nrseqaca);

  commit;
exception
  when others then
    rollback;
    sistema.excecaoInterna(pr_compleme => 'PRJ0025080-VAN');
end;