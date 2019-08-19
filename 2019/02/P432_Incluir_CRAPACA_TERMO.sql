DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'ATENDA_CRD';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
	INSERT INTO craprdr(nmprogra,dtsolici)
		   VALUES('ATENDA_CRD', SYSDATE)
		   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;

  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('VALIDA_DTCORTE_PROTOCOLO', 'TELA_ATENDA_CARTAOCREDITO', 'pc_valida_dtcorte_prot_entrega', 'pr_nrctrcrd', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('IMPRIMIR_PROTOCOLO_CARTAO_CREDITO', 'TELA_ATENDA_CARTAOCREDITO', 'pc_imprimir_protocolo_entrega', 'pr_nrctrcrd', vr_nrseqrdr);
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia ao TERMO criado com sucesso!');
  
END;
