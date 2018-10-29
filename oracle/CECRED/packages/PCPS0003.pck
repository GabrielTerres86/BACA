CREATE OR REPLACE PACKAGE CECRED.PCPS0003 IS
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Augusto - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_encrypt_3DES(pr_data             IN CLOB
													 ,pr_encrypted_data   OUT CLOB
													 ,pr_dscritic         OUT VARCHAR2);
									 
  PROCEDURE pc_decrypt_3DES(pr_data            IN CLOB
                           ,pr_decrypted_data  OUT CLOB
									         ,pr_dscritic        OUT VARCHAR2);
													 
	PROCEDURE pc_obtem_chave(pr_cdacesso IN tbgen_chaves_crypto.cdacesso%TYPE
		                      ,pr_dschave  OUT tbgen_chaves_crypto.dschave_crypto%TYPE
		                      ,pr_dscritic OUT VARCHAR2);
END PCPS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0003 IS
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Augusto - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas para criptografia utilizadas na plataforma de portabilidade de salário
  
      Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/

  encryption_type CONSTANT PLS_INTEGER := dbms_crypto.encrypt_des + dbms_crypto.chain_cbc + dbms_crypto.pad_zero;

  FUNCTION b2c(b IN BLOB) RETURN CLOB IS
		v_clob CLOB;
		v_varchar VARCHAR2(32767);
		v_start PLS_INTEGER := 1;
		v_buffer PLS_INTEGER := 32767;
  BEGIN
    DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

		FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(b) / v_buffer)
		LOOP
			v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(b, v_buffer, v_start));
			DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
			v_start := v_start + v_buffer;
		END LOOP;

		RETURN v_clob;
  END b2c;	
	
  FUNCTION c2b(c IN CLOB) RETURN BLOB IS
    pos     PLS_INTEGER := 1;
    buffer  RAW(32767);
    res     BLOB;
    lob_len PLS_INTEGER := DBMS_LOB.getLength(c);
  BEGIN
    DBMS_LOB.createTemporary(res, TRUE);
    DBMS_LOB.OPEN(res, DBMS_LOB.LOB_ReadWrite);

    LOOP
      buffer := UTL_RAW.cast_to_raw(DBMS_LOB.SUBSTR(c, 16000, pos));
    
      IF UTL_RAW.LENGTH(buffer) > 0 THEN
        DBMS_LOB.writeAppend(res, UTL_RAW.LENGTH(buffer), buffer);
      END IF;
    
      pos := pos + 16000;
      EXIT WHEN pos > lob_len;
    END LOOP;

    RETURN res;
  END c2b;

	PROCEDURE pc_obtem_chave(pr_cdacesso IN tbgen_chaves_crypto.cdacesso%TYPE
		                      ,pr_dschave  OUT tbgen_chaves_crypto.dschave_crypto%TYPE
		                      ,pr_dscritic OUT VARCHAR2) IS
													
	---------------------------------------------------------------------------------------------------------------
	--
	--  Programa : pc_obtem_chave
	--  Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
	--  Sigla    : PCPS
	--  Autor    : Augusto - Supero
	--  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
	--
	-- Dados referentes ao programa:
	--
	-- Frequencia: -----
	-- Objetivo: Retornar as chaves (privadas/publicas) previamente configuradas por vigencia
	--
	-- Alteracoes: 
	--             
	---------------------------------------------------------------------------------------------------------------

		CURSOR cr_chave(pr_cdacesso IN tbgen_chaves_crypto.cdacesso%TYPE) IS
			SELECT tcc.dschave_crypto 
				FROM tbgen_chaves_crypto tcc 
			 WHERE tcc.cdacesso = pr_cdacesso
				 AND tcc.dtinicio_vigencia <= trunc(SYSDATE)
		ORDER BY tcc.dtinicio_vigencia DESC;
	  rw_chave cr_chave%ROWTYPE;
		
		vr_exc_saida EXCEPTION;
		vr_dscritic VARCHAR2(2000);
		
	BEGIN
		OPEN cr_chave(pr_cdacesso);
		FETCH cr_chave INTO rw_chave;
		
		IF cr_chave%NOTFOUND THEN
			CLOSE cr_chave;			
			vr_dscritic := 'Chave ' || pr_cdacesso || ' não localizada.';
			RAISE vr_exc_saida;
		END IF;
		CLOSE cr_chave;
		
		pr_dschave := rw_chave.dschave_crypto;
		
		EXCEPTION
			WHEN vr_exc_saida THEN
				pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_obtem_chave: ' || SQLERRM;
        ROLLBACK;
		
  END pc_obtem_chave;

  PROCEDURE pc_encrypt_3DES(pr_data             IN CLOB
													 ,pr_encrypted_data   OUT CLOB
													 ,pr_dscritic         OUT VARCHAR2)  IS
	---------------------------------------------------------------------------------------------------------------
	--
	--  Programa : pc_encrypt_3DES
	--  Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
	--  Sigla    : PCPS
	--  Autor    : Augusto - Supero
	--  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
	--
	-- Dados referentes ao programa:
	--
	-- Frequencia: -----
	-- Objetivo  : Realizar encriptografia 3DES de um CLOB utilizando as chaves de integração com a CIP.
	--
	-- Alteracoes: 
	--             
	---------------------------------------------------------------------------------------------------------------
	vr_dschave_privada VARCHAR2(3000);
	vr_chave_privada BLOB;
	vr_data BLOB;
	vr_encrypted_data BLOB;
	vr_dscritic VARCHAR2(2000);
	vr_exc_saida EXCEPTION;

	BEGIN
		--
		pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PRIVADA'
		              ,pr_dschave => vr_dschave_privada
 								  ,pr_dscritic => vr_dscritic);
    --
    IF vr_dscritic IS NOT NULL THEN
			RAISE vr_exc_saida;
		END IF;
    --
		vr_chave_privada := utl_raw.cast_to_raw(vr_dschave_privada);
		vr_data := c2b(pr_data);
		--
		vr_encrypted_data := dbms_crypto.encrypt(src => vr_data
																				,typ => encryption_type
																				,key => vr_chave_privada);
    --
		pr_encrypted_data := b2c(vr_encrypted_data);

  EXCEPTION
		WHEN vr_exc_saida THEN
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina encrypt: '||SQLERRM;
  END pc_encrypt_3DES;

  PROCEDURE pc_decrypt_3DES(pr_data            IN CLOB
                           ,pr_decrypted_data  OUT CLOB
									         ,pr_dscritic        OUT VARCHAR2)  IS
	---------------------------------------------------------------------------------------------------------------
	--
	--  Programa : pc_decrypt_3DES
	--  Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
	--  Sigla    : PCPS
	--  Autor    : Augusto - Supero
	--  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
	--
	-- Dados referentes ao programa:
	--
	-- Frequencia: -----
	-- Objetivo  : Realizar decriptografia 3DES de um CLOB utilizando as chaves de integração com a CIP.
	--
	-- Alteracoes: 
	--             
	---------------------------------------------------------------------------------------------------------------
	vr_dschave_publica VARCHAR2(3000);
	vr_chave_publica BLOB;
	vr_data BLOB;
	vr_decrypted_data BLOB;
  vr_dscritic VARCHAR2(2000);
	vr_exc_saida EXCEPTION;

  BEGIN
    --
		pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PUBLICA'
		              ,pr_dschave => vr_dschave_publica
 								  ,pr_dscritic => vr_dscritic);
    --
    IF vr_dscritic IS NOT NULL THEN
			RAISE vr_exc_saida;
		END IF;
    --
		vr_chave_publica := utl_raw.cast_to_raw(vr_dschave_publica);
	  --
		vr_data := c2b(pr_data); 
		--
    vr_decrypted_data := dbms_crypto.decrypt(src => vr_data
																					  ,typ => encryption_type
																					  ,key => vr_chave_publica);
    --
		pr_decrypted_data := b2c(vr_decrypted_data);

  EXCEPTION
    WHEN vr_exc_saida THEN
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina pc_encrypt_3DES: '||SQLERRM;
  END pc_decrypt_3DES;

END PCPS0003;
/
