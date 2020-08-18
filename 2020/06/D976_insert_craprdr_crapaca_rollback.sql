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
  
  vr_nmprogra := 'ATENDA_LANCAMENTOS_FUTUROS';
  
  OPEN cr_craprdr(pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr INTO vr_nrseqrdr;
  CLOSE cr_craprdr;
  
  DELETE FROM crapaca WHERE nrseqrdr = vr_nrseqrdr;  
  DELETE FROM craprdr WHERE nmprogra = 'ATENDA_LANCAMENTOS_FUTUROS';  
  
  COMMIT;
END; 