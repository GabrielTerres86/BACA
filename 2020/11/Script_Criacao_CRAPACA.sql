/*Nova opção D da tela BLQJUD*/
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
  vr_nmprogra := 'BLQJUD';
  
  OPEN cr_craprdr(pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr INTO vr_nrseqrdr;
  CLOSE cr_craprdr;
  
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('EFETUA_BLOQ_DEBITO_OP_CREDITO',NULL,'CREDITO.adicionarBloqueioDebito','pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsobservacao', vr_nrseqrdr);  
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('CONSULTA_BLOQ_DEBITO_OP_CREDITO',NULL,'CREDITO.obterBloqueioDebito','pr_cdcooper,pr_nrdconta,pr_nrctremp', vr_nrseqrdr);  
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('DESBLOQUEIA_BLOQ_DEBITO_OP_CREDITO',NULL,'CREDITO.removerBloqueioDebito','pr_cdcooper,pr_nrdconta,pr_nrctremp', vr_nrseqrdr);  
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('ALTERA_BLOQ_DEBITO_OP_CREDITO',NULL,'CREDITO.alterarBloqueioDebito','pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsobservacao', vr_nrseqrdr);        
  COMMIT;
END;
