DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'CADA0018';
  
  CURSOR cr_crapaca IS
    SELECT a.nmdeacao
      FROM crapaca a
		 WHERE a.nmdeacao = 'IMPRIMIR_ASSINATURAS'
		   AND a.nmpackag = 'CADA0018';
  rw_crapaca cr_crapaca%ROWTYPE;
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
 
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('CADA0018', SYSDATE)
       RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
	OPEN  cr_crapaca;
	FETCH cr_crapaca INTO rw_crapaca;
	      IF cr_crapaca%NOTFOUND THEN 
					 INSERT INTO crapaca (
									 nmdeacao
									 , nmpackag
									 , nmproced
									 , lstparam
									 , nrseqrdr
					  ) VALUES (
									'IMPRIMIR_ASSINATURAS'
									, 'CADA0018'
									, 'pccc_imprimir_assinaturas_web'
									, 'pr_nrdconta, pr_nrdctato, pr_idseqttl, pr_tppessoa, pr_nrcpfcgc'
									, vr_nrseqrdr);					
				ELSE 
					UPDATE crapaca SET lstparam = 'pr_nrdconta, pr_nrdctato, pr_idseqttl, pr_tppessoa, pr_nrcpfcgc'
					       WHERE nmdeacao = 'IMPRIMIR_ASSINATURAS' AND nmpackag = 'CADA0018';
				END IF;
	CLOSE cr_crapaca;

  
  COMMIT;
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a CONTAS criado com sucesso!');
  
END;

