declare
  vr_nrseqrdr cecred.CRAPACA.nrseqrdr%type;
begin
  INSERT INTO CECRED.CRAPRDR
    (NMPROGRA, DTSOLICI)
  VALUES
    ('VAN', SYSDATE)
  returning nrseqrdr into vr_nrseqrdr;

  INSERT INTO CECRED.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ('INSERIRADESAOVAN',
     null,
     'PAGAMENTO.inserirAdesaoVan',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr);

  INSERT INTO CECRED.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values
    ('CANCELARADESAOVAN',
     null,
     'PAGAMENTO.cancelarAdesaoVan',
     'pr_cdcooperativa,pr_nrconta_corrente,pr_cdproduto',
     vr_nrseqrdr);

  commit;
exception
  when others then
    rollback;
    sistema.excecaoInterna(pr_compleme => 'us732671-VAN');
end;
