--#######################################################################################################################################
--
-- Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_prm_aprovacao_canais"
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_prm_aprovacao_canais"';
	-- Buscar registro da RDR
	CURSOR cr_craprdr IS
		SELECT t.nrseqrdr
		  FROM craprdr t
		 WHERE t.NMPROGRA = 'ATENDA_CRD';
	-- Variaveis
	vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	begin
		-- Buscar RDR
		OPEN  cr_craprdr;
		FETCH cr_craprdr INTO vr_nrseqrdr;
		-- Se nao encontrar
		IF cr_craprdr%NOTFOUND THEN
			INSERT INTO craprdr(nmprogra,dtsolici) VALUES('ATENDA_CRD', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		END IF;
		-- Fechar o cursor
		CLOSE cr_craprdr;
		INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('PRM_APROVACAO_CANAIS', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_prm_aprovacao_canais', 'pr_cdcooper,pr_nrdconta,pr_nrctrcrd', vr_nrseqrdr);
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_adm_crd"
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_adm_crd"';
	-- Buscar registro da RDR
	CURSOR cr_craprdr IS
		SELECT t.nrseqrdr
		  FROM craprdr t
		 WHERE t.NMPROGRA = 'ATENDA_CRD';
	-- Variaveis
	vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	begin
		-- Buscar RDR
		OPEN  cr_craprdr;
		FETCH cr_craprdr INTO vr_nrseqrdr;
		-- Se nao encontrar
		IF cr_craprdr%NOTFOUND THEN
			INSERT INTO craprdr(nmprogra,dtsolici) VALUES('ATENDA_CRD', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		END IF;
		-- Fechar o cursor
		CLOSE cr_craprdr;
		INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('BUSCA_ADM_CRD', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_adm_crd', 'pr_cdcooper,pr_nrdconta, pr_tplimcrd', vr_nrseqrdr);
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação do parâmetro CRD_ATIVA_AUTORIZ_CANAIS (tabela crapprm) 
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro CRD_ATIVA_AUTORIZ_CANAIS (tabela crapprm)';
	CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
	begin
		-- Percorrer as cooperativas do cursor
		FOR rw_crapcop IN cr_crapcop LOOP
			INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CRD_ATIVA_AUTORIZ_CANAIS', 'Parametro para informar se a funcionalidade de autorizacao de cartao de credito via canais esta ativa ou nao para a cooperativa', '0');
		END LOOP;
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação do parâmetro CRD_PZ_EXP_NOTI_CANAIS (tabela crapprm) 
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro CRD_PZ_EXP_NOTI_CANAIS (tabela crapprm)';
	CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
	begin
		--Limpa registros
		DELETE FROM crapprm prm WHERE prm.cdacesso = 'CRD_PZ_EXP_NOTI_CANAIS';
		-- Percorrer as cooperativas do cursor
		FOR rw_crapcop IN cr_crapcop LOOP
			INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CRD_PZ_EXP_NOTI_CANAIS', 'Prazo em quantidade de dias para que as notificações (Transaçõies Pendentes) e propostas expirem - Aprovação por Canais', '10');
		END LOOP;
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Cria dominios de cartão - STATUSCRDCANAIS; MOTNAOAUTORIZACAO
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Cria dominios de cartão - STATUSCRDCANAIS; MOTNAOAUTORIZACAO';
	begin
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('STATUSCRDCANAIS', '101', 'Aguardando Autorização', 0);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('STATUSCRDCANAIS', '102', 'Aguardando Aprovação', 0);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('STATUSCRDCANAIS', '103', 'Aguardando Entrega', 0);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '1', 'Limite divergente da solicitação', 1);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '2', 'Modalidade do cartão divergente da solicitação', 1);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '3', 'Desinteresse da solicitação do cartão', 1);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '4', 'Endereço divergente do solicitado', 1);
		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '5', 'Prazo de autorização excedido', 1);
		
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;  
--#######################################################################################################################################
--
-- Criação de referência "CCRD0009.pccracrd_salvar_param_cartao"
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0009.pccracrd_salvar_param_cartao"';
	-- Buscar registro da RDR
	CURSOR cr_craprdr IS
		SELECT t.nrseqrdr
		  FROM craprdr t
		 WHERE t.NMPROGRA = 'CCRD0009';
	-- Variaveis
	vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	begin
		-- Buscar RDR
		OPEN  cr_craprdr;
		FETCH cr_craprdr INTO vr_nrseqrdr;
		-- Se nao encontrar
		IF cr_craprdr%NOTFOUND THEN
			INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0009', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		END IF;
		-- Fechar o cursor
		CLOSE cr_craprdr;
		DELETE FROM crapaca WHERE nmdeacao = 'SALVAR_PARAMETROS_CARTAO';
		INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('SALVAR_PARAMETROS_CARTAO', 'CCRD0009', 'pccracrd_salvar_param_cartao', 'pr_cdcooper,pr_parametros', vr_nrseqrdr);
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação de referência "CCRD0009.pccracrd_obter_param_cartao"
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0009.pccracrd_obter_param_cartao"';
	-- Buscar registro da RDR
	CURSOR cr_craprdr IS
		SELECT t.nrseqrdr
		  FROM craprdr t
		 WHERE t.NMPROGRA = 'CCRD0009';
	-- Variaveis
	vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	begin
		-- Buscar RDR
		OPEN  cr_craprdr;
		FETCH cr_craprdr INTO vr_nrseqrdr;
		-- Se nao encontrar
		IF cr_craprdr%NOTFOUND THEN
			INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0009', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		END IF;
		-- Fechar o cursor
		CLOSE cr_craprdr;
		INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('OBTER_PARAMETROS_CARTAO', 'CCRD0009', 'pccracrd_obter_param_cartao', 'pr_cdcooper', vr_nrseqrdr);
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação de referência para nova tela PRMCRD
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência para nova tela PRMCRD';
	aux_rsprogra  VARCHAR2(50) := 'Parametros do cartao';
	aux_nmdatela  VARCHAR2(50) := 'CARCRD';
	aux_dsprogra  VARCHAR2(50) := 'Parametros do cartao';
	aux_cdopcoes  VARCHAR2(50) := '@,C';
	aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';
	aux_nmrotina  VARCHAR2(90) := 'PRMCRD';
	aux_nrmodulo  NUMBER       := 5;

	aux_nrordprg  NUMBER;

	-- Cursor para as cooperativas
	CURSOR cr_crapcop IS
	SELECT  *
	  FROM crapcop cop
	 WHERE cop.flgativo = 1;
	begin
		-- Percorrer as cooperativas do cursor
		FOR rw_crapcop IN cr_crapcop LOOP
			INSERT INTO craptel(cdcooper,nmdatela,cdopptel,lsopptel,tldatela,tlrestel,nrmodulo,inacesso,nrordrot,nrdnivel,idevento,idambtel,idsistem,nmrotina)
			VALUES (rw_crapcop.cdcooper,aux_nmdatela,aux_cdopcoes,aux_dsopcoes,aux_dsprogra,aux_rsprogra,aux_nrmodulo,0,1,1
			,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
			,2    /* 0 - todos , 1 - ayllos , 2 - web */
			,1    /* 1 - ayllos, 2 - progrid */ 
			,aux_nmrotina);  
		END LOOP;
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação de acessos a tela PRMCRD 
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de acessos a tela PRMCRD';
	CURSOR cr_crapcop IS
	SELECT cop.cdcooper
	  FROM crapcop cop
	 WHERE cop.flgativo = 1;

	CURSOR cr_crapope IS 
	SELECT ope.cdoperad, 
		   ope.cdcooper 
	  FROM crapope ope 
	 WHERE UPPER(ope.cdoperad) LIKE UPPER('f%')
	   AND ope.cdsitope = 1
	   AND ope.cdoperad NOT IN ('f0030519','f0030260','f0031839','f0030947','f0030641','f0032094');

	-- Vari�vel de cr�ticas
	vr_cdcritic      crapcri.cdcritic%TYPE;
	vr_dscritic      VARCHAR2(10000);
	vr_exc_saida     EXCEPTION;
	vr_qtdsuces      INTEGER := 0;
	vr_qtderror      INTEGER := 0;
	begin
		--Limpa registros
		DELETE FROM crapace ace WHERE ace.nmdatela = 'PRMCRD';
		FOR rw_crapcop IN cr_crapcop LOOP
			-- Opção '@'
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0032094', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			-- Opção 'C'
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0032094', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			-- Opção 'A'
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030519', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030260', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0031839', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030947', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030641', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);    
			INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0032094', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);    
		END LOOP;
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação de referência "CADA0011.pc_valida_endereco_ass"
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CADA0011.pc_valida_endereco_ass"';
	-- Buscar registro da RDR
	CURSOR cr_craprdr IS
		SELECT t.nrseqrdr
		  FROM craprdr t
		 WHERE t.NMPROGRA = 'CADA0011';
	-- Variaveis
	vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	begin
		-- Buscar RDR
		OPEN  cr_craprdr;
		FETCH cr_craprdr INTO vr_nrseqrdr;
		-- Se nao encontrar
		IF cr_craprdr%NOTFOUND THEN
			INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CADA0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		END IF;
		-- Fechar o cursor
		CLOSE cr_craprdr;
		INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('VALIDA_ENDERECO_ASS', 'CADA0011', 'pc_valida_endereco_ass', 'pr_cdcooper,pr_nrdconta', vr_nrseqrdr);
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Alteração de parâmetros na CRAPACA inserindo parâmetro pr_tipo_acao
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Alteração de parâmetros na CRAPACA inserindo parâmetro pr_tipo_acao';
	begin
		-- incluir parametro para identificar o coordenador a assinar
		UPDATE CRAPACA SET LSTPARAM = LSTPARAM || ',pr_tipo_acao' WHERE NMDEACAO = 'INSERE_APROVADOR_CRD' AND NMPACKAG = 'TELA_ATENDA_CARTAOCREDITO';
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Alteração de parâmetros na CRAPACA inserindo parâmetro pr_flgestei
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Alteração de parâmetros na CRAPACA inserindo parâmetro pr_flgestei';
	begin
		-- incluir parametro para identificar o coordenador a assinar
		UPDATE CRAPACA SET LSTPARAM = LSTPARAM || ',pr_flgestei' WHERE NMDEACAO = 'INSERE_APROVADOR_CRD' AND NMPACKAG = 'TELA_ATENDA_CARTAOCREDITO';
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
--#######################################################################################################################################
--
-- Criação do parâmetro CRD_APROVACAO_CANAIS (tabela crapprm) 
--
begin
  declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro CRD_APROVACAO_CANAIS (tabela crapprm)';
	CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
	begin
		--Limpa registros
		DELETE FROM crapprm prm WHERE prm.cdacesso = 'CRD_APROVACAO_CANAIS';
		-- Percorrer as cooperativas do cursor
		FOR rw_crapcop IN cr_crapcop LOOP
			INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'Ativar/Desativar a autorização de solicitação de cartão de credito pelo cooperado por meio dos Canais. (o - desativada e 1 - ativada)', '0');
		END LOOP;
		commit;
		dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
		when others then
		dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
    end;
end;
