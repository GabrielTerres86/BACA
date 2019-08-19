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
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_REAPRE_CHEQUE', 'CADA0003', 'pc_busca_reapre_cheque_xml', 'pr_cdcooper,pr_nrdconta', vr_nrseqrdr); 
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ATUALIZA_REAPRE_CHEQUE', 'CADA0003', 'pc_atualiza_reapre_cheque_xml', 'pr_cdcooper,pr_nrdconta,pr_flgreapre_autom,pr_cdoperad,pr_cdopecor', vr_nrseqrdr);  
  
  COMMIT;
  
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a CONTAS criado com sucesso!');
  
END;
