DECLARE
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'CONTAS';
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
BEGIN
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  IF cr_craprdr%NOTFOUND THEN
  
	INSERT INTO craprdr(nmprogra,dtsolici)
		   VALUES('CONTAS', SYSDATE)
		   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  CLOSE cr_craprdr;

  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('PERMITE_ATUALIZACAO_CADASTRAL', NULL, 'validarAtlzCadastralAimaro', 'pr_inpessoa,pr_nrdconta', vr_nrseqrdr);
  
  COMMIT;
END;