CREATE OR REPLACE PACKAGE CECRED.PCPS0003 IS
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário
      
  ---------------------------------------------------------------------------------------------------------------*/
													 
	--  Compactar o arquivo PCPS
  PROCEDURE PC_ESCRITA_ARQ_PCPS(pr_nmarqori  IN VARCHAR2
                               ,pr_nmarqout  IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2);
  
  -- Descompactar o arquivo da CIP
  PROCEDURE PC_LEITURA_ARQ_PCPS(pr_nmarqori  IN VARCHAR2
                               ,pr_nmarqout  IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2);
                     
  -- Rotina para realização de testes dos arquivos - CRIPTOGRAFAR E DESCRIPTOGRAFAR
  PROCEDURE pc_testar_arquivo(pr_nmarquiv  IN VARCHAR2
                             ,pr_dsdirarq  IN VARCHAR2
                             ,pr_idfuncao  IN NUMBER );
  
  
END PCPS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0003 IS
  
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas para criptografia utilizadas na plataforma de portabilidade de salário
  
      Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Tipo genérico
  TYPE typ_tabhexa IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER;
  
  -- Converter string para binário
  FUNCTION fn_string_to_raw(pr_dsstring   IN VARCHAR2) RETURN RAW IS
  BEGIN
    RETURN UTL_I18N.string_to_raw(pr_dsstring , 'AL32UTF8');
  END;
  
  -- Converte hexadecimal para char
  FUNCTION fn_hex_to_string(pr_dsdohexa IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN utl_raw.cast_to_varchar2(hextoraw(pr_dsdohexa));
  END;
  
  -- Função para realizar a quebra do hexadecimal do Head e retornar em uma collection
  FUNCTION fn_quebra_head(pr_dsheadfl IN VARCHAR2) RETURN typ_tabhexa IS
    
    -- Variáveis
    vr_tbheadfl   typ_tabhexa;
    vr_dsheadfl   VARCHAR2(2000);
  
  BEGIN
    
    -- Se não há conteúdo no parametro
    IF pr_dsheadfl IS NULL THEN
      RETURN vr_tbheadfl;
    END IF;
    
    -- Inicializar
    vr_dsheadfl := pr_dsheadfl;
    
    -- 
    LOOP
      -- Guardar duas posições
      vr_tbheadfl(vr_tbheadfl.count()+1) := SUBSTR(vr_dsheadfl,1,2);
      -- Atualizar variável
      vr_dsheadfl := SUBSTR(vr_dsheadfl,3);
      
      -- Sai quando ler todos os caracteres
      EXIT WHEN vr_dsheadfl IS NULL;
    END LOOP;
    
    -- Retornar a collection
    RETURN vr_tbheadfl;
  END fn_quebra_head;
 
  -- Concatenar uma faixa de valores do head
  FUNCTION  fn_concat_hexa(pr_tbdehexa  typ_tabhexa
                          ,pr_nrposini  NUMBER
                          ,pr_nrposfim  NUMBER) RETURN VARCHAR2 IS
                   
    -- Variáveis 
    vr_dsretorn    VARCHAR2(4000);
    
  BEGIN
    
    -- Percorrer a posição inicio ao fim
    FOR ind IN pr_nrposini..pr_nrposfim LOOP
      -- Monta a chave 
      vr_dsretorn := vr_dsretorn||pr_tbdehexa(ind);
    END LOOP;
    
    -- Retornar o valor final
    RETURN vr_dsretorn;
    
  END fn_concat_hexa;
  
  -- Função para converter BLOB para CLOB
  FUNCTION b2c(b IN BLOB) RETURN CLOB IS
		v_clob     CLOB;
		v_varchar  VARCHAR2(32767);
		v_start    PLS_INTEGER := 1;
		v_buffer   PLS_INTEGER := 32767;
  BEGIN
    DBMS_LOB.createtemporary(v_clob, TRUE);

		FOR i IN 1..ceil(DBMS_LOB.getlength(b) / v_buffer) LOOP
			v_varchar := UTL_RAW.cast_to_varchar2(DBMS_LOB.substr(b, v_buffer, v_start));
			DBMS_LOB.writeappend(v_clob, length(v_varchar), v_varchar);
			v_start := v_start + v_buffer;
		END LOOP;

		RETURN v_clob;
  END b2c;	
	
  -- Função para converter CLOB em BLOB
  FUNCTION c2b(c IN CLOB) RETURN BLOB IS
    pos      PLS_INTEGER := 1;
    buffer   RAW(32767);
    res      BLOB;
    lob_len  PLS_INTEGER := DBMS_LOB.getLength(c);
  BEGIN
    DBMS_LOB.createTemporary(res, TRUE);
    DBMS_LOB.open(res, DBMS_LOB.lob_readwrite);

    LOOP
      buffer := fn_string_to_raw(DBMS_LOB.substr(c, 16000, pos));
    
      IF UTL_RAW.length(buffer) > 0 THEN
        DBMS_LOB.writeAppend(res, UTL_RAW.length(buffer), buffer);
      END IF;
    
      pos := pos + 16000;
      EXIT WHEN pos > lob_len;
    END LOOP;

    RETURN res;
  END c2b;
  
  -- Obter a chave privada/publica conforme parametro de acesso
	PROCEDURE pc_obtem_chave(pr_cdacesso IN tbgen_chaves_crypto.cdacesso%TYPE
		                      ,pr_dschave  OUT tbgen_chaves_crypto.dschave_crypto%TYPE
                          ,pr_dsserie  OUT tbgen_chaves_crypto.dsserie_chave%TYPE
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
           , UPPER(tcc.dsserie_chave) dsserie_chave
				FROM tbgen_chaves_crypto tcc 
			 WHERE tcc.cdacesso           = pr_cdacesso
				 AND tcc.dtinicio_vigencia <= trunc(SYSDATE)
		ORDER BY tcc.dtinicio_vigencia DESC;
	  rw_chave cr_chave%ROWTYPE;
		
		vr_exc_saida EXCEPTION;
		vr_dscritic  VARCHAR2(2000);
    vr_dschave   VARCHAR2(10000);
		
	BEGIN
		OPEN cr_chave(pr_cdacesso);
		FETCH cr_chave INTO rw_chave;
		
		IF cr_chave%NOTFOUND THEN
			CLOSE cr_chave;			
			vr_dscritic := 'Chave ' || pr_cdacesso || ' não localizada.';
			RAISE vr_exc_saida;
		END IF;
		CLOSE cr_chave;
		
    -- Processar chave
    vr_dschave := rw_chave.dschave_crypto;
    
    -- Remover cabeçalho/rodapé
    vr_dschave := REPLACE(vr_dschave, '-----BEGIN RSA PRIVATE KEY-----',NULL);
    vr_dschave := REPLACE(vr_dschave, '-----END RSA PRIVATE KEY-----',NULL);
    vr_dschave := REPLACE(vr_dschave, '-----BEGIN PUBLIC KEY-----',NULL);
    vr_dschave := REPLACE(vr_dschave, '-----END PUBLIC KEY-----',NULL);
    
    
    -- Remover quebras de linhas
    LOOP
      vr_dschave := REPLACE(vr_dschave,chr(10),NULL);
      vr_dschave := REPLACE(vr_dschave,chr(13),NULL);
      -- Sair após retirar todas as quebras de linha
      EXIT WHEN INSTR(vr_dschave,chr(10)) = 0 AND INSTR(vr_dschave,chr(13)) = 0;
    END LOOP;
    
		pr_dschave := vr_dschave;
    pr_dsserie := rw_chave.dsserie_chave;
		
		EXCEPTION
			WHEN vr_exc_saida THEN
				pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_obtem_chave: ' || SQLERRM;
        ROLLBACK;
  END pc_obtem_chave;
  
  -- Rotina para validar o número de série das chaves
  PROCEDURE pc_valida_serie_chave(pr_cdacesso  IN tbgen_chaves_crypto.cdacesso%TYPE
        		                     ,pr_dsdserie  IN tbgen_chaves_crypto.dsserie_chave%TYPE
                                 ,pr_dsdchave OUT VARCHAR2
                                 ,pr_flgvalid OUT BOOLEAN
       		                       ,pr_dscritic OUT VARCHAR2) IS
  
    -- Variáveis
    vr_dsdchave    tbgen_chaves_crypto.dschave_crypto%TYPE;
    vr_dsdserie    tbgen_chaves_crypto.dsserie_chave%TYPE;
    
  BEGIN
    
    -- Retornar False
    pr_flgvalid := FALSE;
  
    -- Obtem a chave publica para descriptografia
    pc_obtem_chave(pr_cdacesso => pr_cdacesso
                  ,pr_dschave  => vr_dsdchave
                  ,pr_dsserie  => vr_dsdserie
                  ,pr_dscritic => pr_dscritic);
    
    -- Se não encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Verifica se o código de série é igual
    IF SUBSTR( UPPER(pr_dsdserie), (LENGTH(vr_dsdserie) * (-1)) ) = UPPER(vr_dsdserie) THEN
      pr_dsdchave := vr_dsdchave;
      pr_flgvalid := TRUE;
    END IF;
    
  END pc_valida_serie_chave;  
  
  -- SOBRECARGA: Rotina para validar o número de série das chaves
  PROCEDURE pc_valida_serie_chave(pr_cdacesso  IN tbgen_chaves_crypto.cdacesso%TYPE
        		                     ,pr_dsdserie  IN tbgen_chaves_crypto.dsserie_chave%TYPE
                                 ,pr_flgvalid OUT BOOLEAN
       		                       ,pr_dscritic OUT VARCHAR2) IS
    -- Variáveis
    vr_dsdchave    tbgen_chaves_crypto.dschave_crypto%TYPE;
  BEGIN
    
    -- Chamar rotina principal
    pc_valida_serie_chave(pr_cdacesso => pr_cdacesso
                         ,pr_dsdserie => pr_dsdserie
                         ,pr_dsdchave => vr_dsdchave
                         ,pr_flgvalid => pr_flgvalid
                         ,pr_dscritic => pr_dscritic);
                         
  END pc_valida_serie_chave;
  
  
  --  Compactar o arquivo PCPS
  PROCEDURE PC_ESCRITA_ARQ_PCPS(pr_nmarqori  IN VARCHAR2
                               ,pr_nmarqout  IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2) IS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_escrita_arq_pcps
    --  Sistema  : Rotinas para compactar e atribuir o head ao arquivo zip
    --  Sigla    : PCPS
    --  Autor    : Renato - Supero
    --  Data     : Novembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a compactação gzip com head dos arquivos do módulo PCPS
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- Variáveis
    vr_dschapvd   VARCHAR2(10000);
    vr_dsserpvd   VARCHAR2(1000);
    vr_dschapub   VARCHAR2(10000);
    vr_dsserpub   VARCHAR2(1000);
    vr_dscritic   VARCHAR2(1000);

    
  BEGIN
   
    -- Obtem a chave privada para criptografia
    pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PRIVADA_AILOS'
                  ,pr_dschave  => vr_dschapvd
                  ,pr_dsserie  => vr_dsserpvd
                  ,pr_dscritic => pr_dscritic);
  
    -- Se não encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
      
    -- Buscar chave publica para head
    pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PUBLICA_CIP' 
                  ,pr_dschave  => vr_dschapub
                  ,pr_dsserie  => vr_dsserpub
                  ,pr_dscritic => pr_dscritic);
  
    -- Se não encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Realiza a conversão do arquivo, criptografando e compactando
    vr_dscritic := CRYP0003.escritaArquivoPCPS(pr_nrserieCIP   => vr_dsserpub
                                              ,pr_nrserieAilos => vr_dsserpvd
                                              ,pr_dschaveprv   => vr_dschapvd
                                              ,pr_dschavepub   => vr_dschapub
                                              ,pr_dsarquivoXML => pr_nmarqori
                                              ,pr_dsarquivoCIP => pr_nmarqout);
    
    -- Se  ocorrer erro
    IF vr_dscritic IS NOT NULL THEN
      pr_dscritic := vr_dscritic;
      RETURN;
    END IF;
    
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro rotina pc_escrita_arq_pcps: '||SQLERRM;
  END pc_escrita_arq_pcps;
  
  
  -- Descompactar o arquivo da CIP
  PROCEDURE PC_LEITURA_ARQ_PCPS(pr_nmarqori  IN VARCHAR2
                               ,pr_nmarqout  IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_leitura_arq_pcps
    --  Sistema  : Rotinas para descompactar o arquivo PCPS
    --  Sigla    : PCPS
    --  Autor    : Renato - Supero
    --  Data     : Novembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a descriptografia e a descompactação dos arquivos PCPS
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_dscritic  VARCHAR2(32000);
    
    vr_dschvdst  VARCHAR2(10000); -- Chave destinatário
    vr_dsserdst  VARCHAR2(100);  -- Chave destinatário
    vr_dschvemt  VARCHAR2(10000); -- Chave emitente
    vr_dsseremt  VARCHAR2(100);  -- Chave emitente
    
  BEGIN
    
    /*************** BUSCAR OS NÚMEROS DE SÉRIE ***************/
    -- Obter a chave privada da AILOS
    pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PRIVADA_AILOS'
                  ,pr_dschave  => vr_dschvdst
                  ,pr_dsserie  => vr_dsserdst  -- SÉRIE DA DESTINATÁRIA
                  ,pr_dscritic => pr_dscritic);
    
    -- Se não encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Obter a chave publica da CIP
    pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PUBLICA_CIP'
                  ,pr_dschave  => vr_dschvemt
                  ,pr_dsserie  => vr_dsseremt  -- SÉRIE DA EMITENTE
                  ,pr_dscritic => pr_dscritic);
    
    -- Se não encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Realiza as validações, descriptografia e descompactação do arquivo CIP
    vr_dscritic := CRYP0003.leituraArquivoPCPS(pr_nrserieCIP   => vr_dsseremt
                                              ,pr_nrserieAilos => vr_dsserdst
                                              ,pr_dschaveprv   => vr_dschvdst
                                              ,pr_dschavepub   => vr_dschvemt
                                              ,pr_dsarquivoCip => pr_nmarqori
                                              ,pr_dsarquivoXML => pr_nmarqout);
    
    -- Se  ocorrer erro
    IF vr_dscritic IS NOT NULL THEN
      pr_dscritic := vr_dscritic;
      RETURN;
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro rotina PC_LEITURA_ARQ_PCPS: '||SQLERRM; 
  END pc_leitura_arq_pcps;
  
    
  -- Rotina para realização de testes dos arquivos
  PROCEDURE pc_testar_arquivo(pr_nmarquiv  IN VARCHAR2
                             ,pr_dsdirarq  IN VARCHAR2
                             ,pr_idfuncao  IN NUMBER ) IS
    
    vr_dscritc   VARCHAR2(2000);
    vr_exc_erro  EXCEPTION;
  
  BEGIN
    
    
    -- verifica a função
    IF pr_idfuncao = 1 THEN
      pc_escrita_arq_pcps(pr_nmarqori => pr_dsdirarq||'/'||pr_nmarquiv||'.xml'
                         ,pr_nmarqout => pr_dsdirarq||'/'||pr_nmarquiv
                         ,pr_dscritic => vr_dscritc );
    ELSE
      pc_leitura_arq_pcps(pr_nmarqori => pr_dsdirarq||'/'||pr_nmarquiv
                         ,pr_nmarqout => pr_dsdirarq||'/'||pr_nmarquiv||'.xml'
                         ,pr_dscritic => vr_dscritc );
    END IF;
    
    -- Em caso de erro
    IF vr_dscritc IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20001,vr_dscritc);
    WHEN OTHERS THEN
      raise_application_error(-20000,'Erro ao processar arquivo: '||SQLERRM);
  END pc_testar_arquivo;
  
  
END PCPS0003;
/
