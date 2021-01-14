 begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script da RITM0045522';
    begin
		---
		--- Criação de acessos a tela CONCIP
		---
		BEGIN
		  DECLARE 
		  -- nome da rotina
		  wk_rotina varchar2(200) := 'Criação de acessos a tela CONCIP';
		  CURSOR cr_crapcop IS
			SELECT cop.cdcooper
			  FROM crapcop cop;
		  BEGIN
			  
			FOR rw_crapcop IN cr_crapcop LOOP
			  -- Opção 'G' - Grade Horaria
				 INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) VALUES ('CONCIP', 'G', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 0, 1);         
				 INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) VALUES ('CONCIP', 'G', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 0, 2);   
			END LOOP;  
			
			UPDATE craptel t
			   SET t.cdopptel = t.cdopptel || ',G', t.lsopptel = t.lsopptel || ',GRADE' 
			 WHERE t.nmdatela = 'CONCIP';
			 
			--COMMIT;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		  EXCEPTION
			WHEN OTHERS THEN 
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		  END;
		END;
		
		---
		--- Criação da referencia BUSCA_GRADE_HORARIO_CIP
		---
		BEGIN
	DECLARE
	  
	  -- Buscar registro da RDR
	  CURSOR cr_craprdr IS
		SELECT t.nrseqrdr
		  FROM craprdr t
		 WHERE t.NMPROGRA = 'CONCIP';
	  
	  -- Variaveis
	  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	  
	  -- nome da rotina
		  wk_rotina varchar2(200) := 'Criação da referencia BUSCA_GRADE_HORARIO_CIP';
	  
	BEGIN
	  
	  -- Buscar RDR
	  OPEN  cr_craprdr;
	  FETCH cr_craprdr INTO vr_nrseqrdr;
	  
	  -- Se nao encontrar
	  IF cr_craprdr%NOTFOUND THEN
	  
	  INSERT INTO craprdr(nmprogra,dtsolici)
		   VALUES('CONCIP', SYSDATE)
		   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
	  
	  END IF;
	  
	  -- Fechar o cursor
	  CLOSE cr_craprdr;
	  
	  INSERT INTO crapaca (
			 nmdeacao
			 , nmpackag
			 , nmproced
			 , lstparam
			 , nrseqrdr
	  ) VALUES (
			'BUSCA_GRADE_HORARIO_CIP'
			, 'CCRD0006'
			, 'pc_busca_prm_gradehoraria'
			, ''
			, vr_nrseqrdr);
	  
	  	--COMMIT;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		  EXCEPTION
			WHEN OTHERS THEN 
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		  END;
		END;
		
		
		
		--***************
		---
		--- Criação da referencia MANTER_GRADE_HORARIO_CIP
		---
		BEGIN
	DECLARE
	  
	 -- Buscar registro da RDR
		  CURSOR cr_craprdr IS
			SELECT t.nrseqrdr
			  FROM craprdr t
			 WHERE t.NMPROGRA = 'CONCIP';
		  
		  -- Variaveis
		  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	  
	  -- nome da rotina
		  wk_rotina varchar2(200) := 'Criação da referencia MANTER_GRADE_HORARIO_CIP';
	  
	BEGIN
	  
	  -- Buscar RDR
		  OPEN  cr_craprdr;
		  FETCH cr_craprdr INTO vr_nrseqrdr;
		  
		  -- Se nao encontrar
		  IF cr_craprdr%NOTFOUND THEN
		  
		  INSERT INTO craprdr(nmprogra,dtsolici)
			   VALUES('CONCIP', SYSDATE)
			   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		  
		  END IF;
		  
		  -- Fechar o cursor
		  CLOSE cr_craprdr;
		  
		  INSERT INTO crapaca (
				 nmdeacao
				 , nmpackag
				 , nmproced
				 , lstparam
				 , nrseqrdr
		  ) VALUES (
				'MANTER_GRADE_HORARIO_CIP'
				, 'CCRD0006'
				, 'pc_manter_prm_gradehoraria'
				, 'pr_pagd,pr_pagd2,pr_page,pr_page2,pr_pagg,pr_paggr,pr_efeta,pr_rec1,pr_rec2'
				, vr_nrseqrdr);
	  
	  	--COMMIT;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		  EXCEPTION
			WHEN OTHERS THEN 
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		  END;
		END;
	  commit;
      
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;