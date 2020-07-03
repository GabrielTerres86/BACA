

DECLARE
  --Buscar na craprdr
  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS 
         SELECT t.nrseqrdr
         FROM craprdr t
         WHERE t.nmprogra = pr_nmprogra;
  --Vars
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;         
  vr_nmprogra craprdr.nmprogra%TYPE;
BEGIN
  insert into craprdr(nmprogra, dtsolici) values ('ATENDA_LANCAMENTOS_FUTUROS', SYSDATE);
  vr_nmprogra := 'ATENDA_LANCAMENTOS_FUTUROS';
  
  OPEN cr_craprdr(pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr INTO vr_nrseqrdr;
  CLOSE cr_craprdr;
  
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('LAUTOM_DEBITA_CARTAO','','CARTAO.debitarFaturaIndividual','pr_prorecid,pr_valor_pag_fatura,pr_autorizador,pr_representante', vr_nrseqrdr);  
  COMMIT;
END; 
