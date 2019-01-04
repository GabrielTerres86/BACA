CREATE OR REPLACE PACKAGE CECRED.PCPS0003 IS
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SAL�RIO
      Sigla    : PCPS
      Autor    : Renato - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de sal�rio
      
  ---------------------------------------------------------------------------------------------------------------*/
													 
	--  Compactar o arquivo PCPS
  PROCEDURE PC_ESCRITA_ARQ_PCPS(pr_dsconteu  IN CLOB
                               ,pr_dsarqcmp OUT BLOB
                               ,pr_dscritic OUT VARCHAR2);
  
  -- Descompactar o arquivo da CIP
  PROCEDURE PC_LEITURA_ARQ_PCPS(pr_dsconteu  IN BLOB
                               ,pr_dsarqcmp OUT CLOB
                               ,pr_dscritic OUT VARCHAR2);
                     
  -- Rotina para realiza��o de testes dos arquivos - CRIPTOGRAFAR E DESCRIPTOGRAFAR
  PROCEDURE pc_testar_arquivo(pr_nmarquiv  IN VARCHAR2
                             ,pr_dsdirarq  IN VARCHAR2
                             ,pr_idfuncao  IN NUMBER );
  
  
END PCPS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0003 IS
  
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SAL�RIO
      Sigla    : PCPS
      Autor    : Renato - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas para criptografia utilizadas na plataforma de portabilidade de sal�rio
  
      Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Tipo gen�rico
  TYPE typ_tabhexa IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER;
  
  -- Converter string para bin�rio
  FUNCTION fn_string_to_raw(pr_dsstring   IN VARCHAR2) RETURN RAW IS
  BEGIN
    RETURN UTL_I18N.string_to_raw(pr_dsstring , 'AL32UTF8');
  END;
  
  -- Converte hexadecimal para char
  FUNCTION fn_hex_to_string(pr_dsdohexa IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN utl_raw.cast_to_varchar2(hextoraw(pr_dsdohexa));
  END;
  
  -- Fun��o para realizar a quebra do hexadecimal do Head e retornar em uma collection
  FUNCTION fn_quebra_head(pr_dsheadfl IN VARCHAR2) RETURN typ_tabhexa IS
    
    -- Vari�veis
    vr_tbheadfl   typ_tabhexa;
    vr_dsheadfl   VARCHAR2(2000);
  
  BEGIN
    
    -- Se n�o h� conte�do no parametro
    IF pr_dsheadfl IS NULL THEN
      RETURN vr_tbheadfl;
    END IF;
    
    -- Inicializar
    vr_dsheadfl := pr_dsheadfl;
    
    -- 
    LOOP
      -- Guardar duas posi��es
      vr_tbheadfl(vr_tbheadfl.count()+1) := SUBSTR(vr_dsheadfl,1,2);
      -- Atualizar vari�vel
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
                   
    -- Vari�veis 
    vr_dsretorn    VARCHAR2(4000);
    
  BEGIN
    
    -- Percorrer a posi��o inicio ao fim
    FOR ind IN pr_nrposini..pr_nrposfim LOOP
      -- Monta a chave 
      vr_dsretorn := vr_dsretorn||pr_tbdehexa(ind);
    END LOOP;
    
    -- Retornar o valor final
    RETURN vr_dsretorn;
    
  END fn_concat_hexa;
  
  -- Fun��o para converter BLOB para CLOB
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
	
  -- Fun��o para converter CLOB em BLOB
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
	--  Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SAL�RIO
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
			vr_dscritic := 'Chave ' || pr_cdacesso || ' n�o localizada.';
			RAISE vr_exc_saida;
		END IF;
		CLOSE cr_chave;
		
    -- Processar chave
    vr_dschave := rw_chave.dschave_crypto;
    
    -- Remover cabe�alho/rodap�
    vr_dschave := REPLACE(vr_dschave, '-----BEGIN RSA PRIVATE KEY-----',NULL);
    vr_dschave := REPLACE(vr_dschave, '-----END RSA PRIVATE KEY-----',NULL);
    vr_dschave := REPLACE(vr_dschave, '-----BEGIN PUBLIC KEY-----',NULL);
    vr_dschave := REPLACE(vr_dschave, '-----END PUBLIC KEY-----',NULL);
    
    
    -- Remover quebras de linhas
    LOOP
      vr_dschave := REPLACE(vr_dschave,chr(10),NULL);
      vr_dschave := REPLACE(vr_dschave,chr(13),NULL);
      -- Sair ap�s retirar todas as quebras de linha
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
  
  -- Rotina para validar o n�mero de s�rie das chaves
  PROCEDURE pc_valida_serie_chave(pr_cdacesso  IN tbgen_chaves_crypto.cdacesso%TYPE
        		                     ,pr_dsdserie  IN tbgen_chaves_crypto.dsserie_chave%TYPE
                                 ,pr_dsdchave OUT VARCHAR2
                                 ,pr_flgvalid OUT BOOLEAN
       		                       ,pr_dscritic OUT VARCHAR2) IS
  
    -- Vari�veis
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
    
    -- Se n�o encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Verifica se o c�digo de s�rie � igual
    IF SUBSTR( UPPER(pr_dsdserie), (LENGTH(vr_dsdserie) * (-1)) ) = UPPER(vr_dsdserie) THEN
      pr_dsdchave := vr_dsdchave;
      pr_flgvalid := TRUE;
    END IF;
    
  END pc_valida_serie_chave;  
  
  -- SOBRECARGA: Rotina para validar o n�mero de s�rie das chaves
  PROCEDURE pc_valida_serie_chave(pr_cdacesso  IN tbgen_chaves_crypto.cdacesso%TYPE
        		                     ,pr_dsdserie  IN tbgen_chaves_crypto.dsserie_chave%TYPE
                                 ,pr_flgvalid OUT BOOLEAN
       		                       ,pr_dscritic OUT VARCHAR2) IS
    -- Vari�veis
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
  PROCEDURE PC_ESCRITA_ARQ_PCPS(pr_dsconteu  IN CLOB
                               ,pr_dsarqcmp OUT BLOB
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
    -- Objetivo  : Realizar a compacta��o gzip com head dos arquivos do m�dulo PCPS
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    vr_dstmplob   BLOB;
    vr_dscprlob   BLOB;
    vr_dslobarq   CLOB;

    vr_dsserori   VARCHAR2(100);
    vr_dsserdes   VARCHAR2(100);

    vr_bfchvsim   VARCHAR2(2000);
    vr_bfautmsg   VARCHAR2(1000);
    vr_dsstrarq   VARCHAR2(32500);
    
    --vr_dsflhash   VARCHAR2(100);
    vr_dschapvd   VARCHAR2(10000);
    vr_dsserpvd   VARCHAR2(1000);
    vr_dschapub   VARCHAR2(10000);
    vr_dsserpub   VARCHAR2(1000);
    vr_dsdeskey   VARCHAR2(1000);
    vr_qtbytpad   NUMBER;
    
  BEGIN
   
    -- CONTE�DO DO ARQUIVO
    --vr_dstmplob := c2b(pr_dsconteu); 
    
    -- Ap�s fazer o PADDING, utilizar como CLOB
    vr_dslobarq := pr_dsconteu; -- b2c(vr_dstmplob);
    
    -- Chamar rotina de compacta��o - GZIP
    vr_dslobarq := CRYP0003.gzipCompress(pr_dsmensag => vr_dslobarq ) ;
    
    -- CONTE�DO 
    vr_dstmplob := HEXTORAW(vr_dslobarq); 
    
    /******************* VERIFICAR E AJUSTAR PADDING DO ARQUIVO ******************************/
    -- Calcula a quantidade que falta de zeros para o padding - A mensagem deve ser m�ltipla de 8
    vr_qtbytpad := MOD( dbms_lob.getlength(vr_dstmplob) , 8);
    
    -- Se faltam posi��es
    IF vr_qtbytpad > 0 THEN
      -- Verifica quantas faltam
      vr_qtbytpad := 8 - vr_qtbytpad;
      
      -- ADICIONAR O PADDING DOS ZEROS BIN�RIOS FALTANTES
      dbms_lob.append(vr_dstmplob, HEXTORAW( RPAD('00', (vr_qtbytpad * 2) ,'0') )); -- zlib trailer
    
    END IF;
    
    -- Converter o conte�do ajustado pelo padding
    vr_dsstrarq := RAWTOHEX(vr_dstmplob);
    vr_dslobarq := RAWTOHEX(vr_dstmplob);
    /***************** FIM VERIFICAR E AJUSTAR PADDING DO ARQUIVO ****************************/
    
    /******************* GERAR O HASH DO ARQUIVO CRIPTOGRAFADO *******************************/
    -- Montar o Hash com base no arquivo gerado
    --vr_dsflhash := CRYP0003.getXmlHash(pr_dsxmlarq => vr_dsstrarq);
    
    -- Obtem a chave privada para criptografia
    pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PRIVADA_AILOS'
                  ,pr_dschave  => vr_dschapvd
                  ,pr_dsserie  => vr_dsserpvd
                  ,pr_dscritic => pr_dscritic);
  
    -- Se n�o encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
      
    -- Buffer criptografado com a chave privada do emissor
    vr_bfautmsg := CRYP0003.signHashSHA256(hash_message => vr_dsstrarq -- vr_dsflhash
                                          ,public_key   => vr_dschapvd);
    /******************* FIM DO HASH DO ARQUIVO CRIPTOGRAFADO *******************************/
    
    -- Buscar chave publica para head
    pc_obtem_chave(pr_cdacesso => 'PCPS_CHAVE_PUBLICA_CIP' 
                  ,pr_dschave  => vr_dschapub
                  ,pr_dsserie  => vr_dsserpub
                  ,pr_dscritic => pr_dscritic);
  
    -- Se n�o encontrar a chave ou ocorrer erro
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Converter os n�meros de s�rie da institui��o origem
    vr_dsserori := RAWTOHEX( fn_string_to_raw( LPAD(vr_dsserpvd,32,'0')));
    
    -- Converter os n�meros de s�rie da institui��o destino
    vr_dsserdes := RAWTOHEX( fn_string_to_raw( LPAD(vr_dsserpub,32,'0')));
    
    /***************** CRIPTOGRAFAR A MENSAGEM QUE FOI OBJETO DA ASSINATURA *****************/
    -- Sortear a chave 3DES que ser� utilizada na criptografia
    vr_dsdeskey := CRYP0003.get3DESKey();
    
    -- Encriptografar
    vr_dslobarq := CRYP0003.encrypt3Des(pr_dsxmlarq => vr_dslobarq
                                       ,pr_dschvdes => vr_dsdeskey);
    
    -- Buffer criptografado com a chave privada do emissor
    vr_bfchvsim := CRYP0003.encrypt3DesKey(pr_dschvdes => vr_dsdeskey
                                          ,pr_dschvpub => vr_dschapub);
    
    /*************** FIM CRIPTOGRAFIA DA MENSAGEM QUE FOI OBJETO DA ASSINATURA **************/
    
    -- Lob tempor�rio
    dbms_lob.createtemporary(vr_dscprlob, FALSE);
    
    /****** CRIAR O HEAD DE SEGURAN�A PARA O ARQUIVO ******/
    vr_dscprlob := HEXTORAW(
                       UPPER( -- GARANTIR QUE OS VALORES HEXA ESTEJAM EM MAI�SCULO
                            '024C' -- Tamanho total do Cabe�alho [C1 - 1..2]
                          ||'02' -- Vers�o do protocolo - Segunda vers�o - version 2.0 [C2 - 3]
                          ||'00' -- C�digo de erro [C3 - 4]
                          ||'08' -- Indica��o de tratamento especial [C4 - 5]
                          ||'00' -- Reservado para o futuro [C5 - 6]
                          ||'02' -- Algoritmo da chave assim�trica do destino - RSA com 2048 bits [C6 - 7]
                          ||'01' -- Algoritmo da chave sim�trica - Triple-DES com 168 bits (3 x 56 bits)  [C7 - 8]
                          ||'02' -- Algoritmo da chave assim�trica local - RSA com 2048 bits [C8 - 9]
                          ||'03' -- Algoritmo de �hash� - SHA-256  [C9 - 10]
                          ||'04' -- PC do certificado digital do destino - SPB-Serasa [C10 - 11]
                          ||vr_dsserdes -- S�rie do certificado digital do destino [C11 - 12..43]
                          ||'04' -- PC do certificado di gital da Institui��o [C12 - 44]
                          ||vr_dsserori -- S�rie do certificado digital da Institui��o [C13 - 45..76]
                          ||vr_bfchvsim -- Buffer de criptografia da chave sim�trica  [C14 - 77..332]
                          ||vr_bfautmsg -- Buffer do criptograma de autentica��o da mensagem  [C15 - 333..588]
                      )
                   );
    
    -- CONVERTER PARA BLOB NOVAMENTE
    vr_dstmplob := HEXTORAW(vr_dslobarq);
    
    -- Unir o head � mensagem
    dbms_lob.copy(vr_dscprlob, vr_dstmplob, dbms_lob.getlength(vr_dstmplob), dbms_lob.getlength(vr_dscprlob) + 1, 1);

    /****************************************/
    -- Retornar o lob com os dados 
    pr_dsarqcmp := vr_dscprlob;
    /****************************************/
        
    -- Limpar buffer
    dbms_lob.freetemporary(vr_dstmplob);
    dbms_lob.freetemporary(vr_dscprlob);
    dbms_lob.freetemporary(vr_dslobarq);
        
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro rotina pc_escrita_arq_pcps: '||SQLERRM;
  END pc_escrita_arq_pcps;
  
  
  -- Descompactar o arquivo da CIP
  PROCEDURE PC_LEITURA_ARQ_PCPS(pr_dsconteu  IN BLOB
                               ,pr_dsarqcmp OUT CLOB
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
    -- Objetivo  : Realizar a descriptografia e a descompacta��o dos arquivos PCPS
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    vr_dsheadfl  BLOB;
    vr_dsxmlarq  BLOB;
    
    vr_dsxmldcp  VARCHAR2(2000);
    
    vr_dsbuffer  CLOB; 
    vr_dsbfhead  VARCHAR2(32000);
    
   -- vr_dsflhash   VARCHAR2(100);
    vr_bfchvsim  VARCHAR2(2000);
    vr_bfautmsg  VARCHAR2(2000);
    vr_flgvalid  BOOLEAN := FALSE;
    
    vr_dschvdst  VARCHAR2(2000); -- Chave destinat�rio
    vr_dsserdst  VARCHAR2(100); -- Chave destinat�rio
    vr_dschvemt  VARCHAR2(2000); -- Chave emitente
    vr_dsseremt  VARCHAR2(100); -- Chave emitente
    
    vr_tbheadfl  typ_tabhexa;
    
  BEGIN
    -- Criar os lobs tempor�rios
    dbms_lob.createtemporary(vr_dsheadfl, FALSE);
    dbms_lob.createtemporary(vr_dsxmlarq, FALSE);
    
    /**************** LEITURA DO HEAD DE SEGURAN�A ****************/
    -- Ler o HEAD do zip
    dbms_lob.copy(vr_dsheadfl, pr_dsconteu, 588 , 1, 1);
    
    -- Converter o buffer do arquivo em hexacimal
    vr_dsbfhead := rawtohex(vr_dsheadfl);

    -- Quebrar o head em um array de hexadecimais
    vr_tbheadfl := fn_quebra_head(vr_dsbfhead);
    
    /*************** VALIDA��O DOS N�MEROS DE S�RIE ***************/
    -- Ler o n�mero de s�rie das chaves e converter para char
    vr_dsserdst := fn_concat_hexa(vr_tbheadfl,12,43);
    vr_dsserdst := fn_hex_to_string(vr_dsserdst);
    vr_dsseremt := fn_concat_hexa(vr_tbheadfl,45,76);
    vr_dsseremt := fn_hex_to_string(vr_dsseremt);

    -- Rotina para validar a s�rie da chave da destinat�ria
    pc_valida_serie_chave(pr_cdacesso => 'PCPS_CHAVE_PRIVADA_AILOS'
                         ,pr_dsdserie => vr_dsserdst -- S�RIE DA DESTINAT�RIA
                         ,pr_dsdchave => vr_dschvdst
                         ,pr_flgvalid => vr_flgvalid
                         ,pr_dscritic => pr_dscritic);
    
    -- Verificar retorno de erros
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Verifica se a chave � valida
    IF NOT vr_flgvalid THEN
      pr_dscritic := 'S�rie do certificado digital do destino, inv�lida.';
      RETURN;
    END IF;
    
    -- reset
    vr_flgvalid := FALSE;
    
    -- Rotina para validar a s�rie da chave da emitente
    pc_valida_serie_chave(pr_cdacesso => 'PCPS_CHAVE_PUBLICA_CIP'
                         ,pr_dsdserie => vr_dsseremt -- S�RIE DA EMITENTE
                         ,pr_dsdchave => vr_dschvemt
                         ,pr_flgvalid => vr_flgvalid
                         ,pr_dscritic => pr_dscritic);
    
    -- Verificar retorno de erros
    IF pr_dscritic IS NOT NULL THEN
      RETURN;
    END IF;
    
    -- Verifica se a chave � valida
    IF NOT vr_flgvalid THEN
      pr_dscritic := 'S�rie do certificado digital da emitente, inv�lida.';
      RETURN;
    END IF;

    /***************** LEITURA DA CHAVE SIM�TRICA *****************/
    -- Ler o hexa da chave sim�trica - CRIPTOGRAFADA
    vr_bfchvsim := fn_concat_hexa(vr_tbheadfl,77,332);
    
    -- Realizar a descriptografia da chave com base na chave PRIVADA da Ailos
    vr_dsxmldcp := CRYP0003.decrypt3DesKey(encrypted_text => vr_bfchvsim
                                          ,public_key     => vr_dschvdst);
    
    /**************** LEITURA DO CORPO DO ARQUIVO  ****************/
    
    -- Ler o conte�do do zip
    dbms_lob.copy(vr_dsxmlarq, pr_dsconteu, dbms_lob.getlength(pr_dsconteu) - 588 , 1, 589);
    
    vr_dsbuffer := rawtohex(vr_dsxmlarq);
    
    -- Realizar a descriptografia da chave com base na chave PRIVADA da Ailos
    vr_dsbuffer := CRYP0003.decrypt3DesCLOB(encrypted_text => vr_dsbuffer
                                           ,hash_key       => vr_dsxmldcp );
        
    /***************** LEITURA DO HASH DO ARQUIVO *****************/
    -- Ler o hexa do hash do arquivo - Campo C15 - ASSINADO
    vr_bfautmsg := fn_concat_hexa(vr_tbheadfl,333,588);
    
    -- Montar o Hash com base no arquivo gerado
    --vr_dsflhash := CRYP0003.getXmlHash(pr_dsxmlarq => vr_dsbuffer);
    
    -- Realizar a verifica��o da assinatura
    IF NOT CRYP0003.verifyHashSHA256CLOB(hash_message => vr_dsbuffer -- vr_dsflhash
                                        ,signned_hash => vr_bfautmsg
                                        ,public_key   => vr_dschvemt) THEN
      -- Retornar mensagem de err o
      pr_dscritic := 'Assinatura da Mensagem inv�lida ou com Erro';
      RETURN;
    END IF;
    
    -- Chamar a rotina para descompactar o corpo da mensagem
    vr_dsbuffer := CRYP0003.gzipDecompressCLOB(pr_dsmsgzip => vr_dsbuffer);
    
    -- Retornar o BLOB com os dados do arquivo
    pr_dsarqcmp := vr_dsbuffer;
    
    -- Limpar Buffers
    dbms_lob.freetemporary(vr_dsheadfl);
    dbms_lob.freetemporary(vr_dsxmlarq);
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro rotina PC_LEITURA_ARQ_PCPS: '||SQLERRM; 
  END pc_leitura_arq_pcps;
    
  -- Rotina para realiza��o de testes dos arquivos
  PROCEDURE pc_testar_arquivo(pr_nmarquiv  IN VARCHAR2
                             ,pr_dsdirarq  IN VARCHAR2
                             ,pr_idfuncao  IN NUMBER ) IS
    
    vr_blobarq   BLOB;
    vr_blobzip   BLOB;
    vr_clobzip   CLOB;
    vr_dscritc   VARCHAR2(2000);
    vr_exc_erro  EXCEPTION;
  
  BEGIN
    
    
    -- verifica a fun��o
    IF pr_idfuncao = 1 THEN
      -- Carrega o arquivo para CLOB
      vr_clobzip := GENE0002.fn_arq_para_clob(pr_caminho => pr_dsdirarq
                                             ,pr_arquivo => pr_nmarquiv);
    
      pc_escrita_arq_pcps(pr_dsconteu => vr_clobzip
                         ,pr_dsarqcmp => vr_blobzip
                         ,pr_dscritic => vr_dscritc );
    ELSE
      -- Carrega o arquivo para BLOB
      vr_blobarq := GENE0002.fn_arq_para_blob(pr_caminho => pr_dsdirarq
                                             ,pr_arquivo => pr_nmarquiv);
      
      pc_leitura_arq_pcps(pr_dsconteu => vr_blobarq
                         ,pr_dsarqcmp => vr_clobzip
                         ,pr_dscritic => vr_dscritc );
    END IF;
    
    -- Em caso de erro
    IF vr_dscritc IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF pr_idfuncao = 1 THEN
      -- Criar um novo arquivo
      GENE0002.pc_blob_para_arquivo(pr_blob     => vr_blobzip
                                   ,pr_caminho  => pr_dsdirarq
                                   ,pr_arquivo  => substr(pr_nmarquiv,1,INSTR(pr_nmarquiv,'.')-1)
                                   ,pr_des_erro => vr_dscritc);
    
      -- Em caso de erro
      IF vr_dscritc IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    ELSE
      --dbms_output.put_line(vr_clobzip);
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_clobzip
                                   ,pr_caminho  => pr_dsdirarq
                                   ,pr_arquivo  => pr_nmarquiv||'.xml'
                                   ,pr_des_erro => vr_dscritc);

      -- Em caso de erro
      IF vr_dscritc IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20001,vr_dscritc);
    WHEN OTHERS THEN
      raise_application_error(-20000,'Erro ao processar arquivo: '||SQLERRM);
  END pc_testar_arquivo;
  
--
  /*PROCEDURE finish_zip( p_zipped_blob IN OUT blob )
  IS
    t_cnt PLS_INTEGER := 0;
    t_offs INTEGER;
    t_offs_dir_header INTEGER;
    t_offs_end_header INTEGER;
    t_comment RAW(32767) := fn_string_to_raw( 'Implementation by Anton Scheffer' );
  BEGIN
    t_offs_dir_header := dbms_lob.getlength( p_zipped_blob );
    t_offs := dbms_lob.INSTR( p_zipped_blob, HEXTORAW( '504B0304' ), 1 );
    WHILE t_offs > 0
    LOOP
      t_cnt := t_cnt + 1;
      dbms_lob.append( p_zipped_blob
                     , utl_raw.CONCAT( HEXTORAW( '504B0102' )      -- Central directory file header signature
                                     , HEXTORAW( '1400' )          -- version 2.0
                                     , dbms_lob.SUBSTR( p_zipped_blob, 26, t_offs + 4 )
                                     , HEXTORAW( '0000' )          -- File comment length
                                     , HEXTORAW( '0000' )          -- Disk number where file starts
                                     , HEXTORAW( '0100' )          -- Internal file attributes
                                     , HEXTORAW( '2000B681' )      -- External file attributes
                                     , little_endian( t_offs - 1 ) -- Relative offset of local file header
                                     , dbms_lob.SUBSTR( p_zipped_blob
                                                      , utl_raw.cast_to_binary_integer( dbms_lob.SUBSTR( p_zipped_blob, 2, t_offs + 26 ), utl_raw.little_endian )
                                                      , t_offs + 30
                                                      )            -- File name
                                     )
                     );
      t_offs := dbms_lob.INSTR( p_zipped_blob, HEXTORAW( '504B0304' ), t_offs + 32 );
    END LOOP;
    t_offs_end_header := dbms_lob.getlength( p_zipped_blob );
    dbms_lob.append( p_zipped_blob
                   , utl_raw.CONCAT( HEXTORAW( '504B0506' )                                    -- End of central directory signature
                                   , HEXTORAW( '0000' )                                        -- Number of this disk
                                   , HEXTORAW( '0000' )                                        -- Disk where central directory starts
                                   , little_endian( t_cnt, 2 )                                 -- Number of central directory records on this disk
                                   , little_endian( t_cnt, 2 )                                 -- Total number of central directory records
                                   , little_endian( t_offs_end_header - t_offs_dir_header )    -- Size of central directory
                                   , little_endian( t_offs_dir_header )                        -- Relative offset of local file header
                                   , little_endian( NVL( utl_raw.LENGTH( t_comment ), 0 ), 2 ) -- ZIP file comment length
                                   , t_comment
                                   )
                   );
  END;*/

/*
function fnc_md5 (p_valor varchar) return varchar2 is
     v_entrada varchar2(2000) := p_valor;
     hexkey varchar2(32) := null;
begin
   hexkey := rawtohex(dbms_obfuscation_toolkit.md5(input => fn_string_to_raw(v_entrada)));
   
   
   
   return nvl(hexkey,'');
end;
*/
  
END PCPS0003;
/
