DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'CONTAS';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
	INSERT INTO craprdr(nmprogra,dtsolici)
		   VALUES('CONTAS', SYSDATE)
		   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('IMP_FICHA_MATRI_PF', 'CADA0002', 'pc_imp_ficha_matri_pf', 'pr_nrdconta, pr_tprelato', vr_nrseqrdr);

  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('IMP_FICHA_MATRI_PJ', 'CADA0002', 'pc_imp_ficha_matri_pj', 'pr_nrdconta, pr_tprelato', vr_nrseqrdr);
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a TELA_ATENDA_CARTAOCREDITO criado com sucesso!');
  
END;
