

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
  vr_nmprogra := 'TELA_PRVSAQ';
  
  OPEN cr_craprdr(pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr INTO vr_nrseqrdr;
  CLOSE cr_craprdr;
  
  insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ('PRVSAQ_SACADORES','TELA_PRVSAQ','obterSacadoresTitular','pr_cdcooper,pr_nrconta,pr_idseqttl', vr_nrseqrdr);  
  COMMIT;
END;  
         
		 
		 
		 

     
