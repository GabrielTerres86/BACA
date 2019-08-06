DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'CADA0011';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
	INSERT INTO craprdr(nmprogra,dtsolici)
		   VALUES('CADA0011', SYSDATE)
		   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('VALIDA_ENDERECO_ASS', 'CADA0011', 'pc_valida_endereco_ass', 'pr_cdcooper,pr_nrdconta', vr_nrseqrdr);
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a CADA0011 criado com sucesso!');
  
END;
