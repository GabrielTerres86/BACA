  CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS730 (pr_dscritic OUT VARCHAR2
                                      ) IS
/* .............................................................................

   Programa: pc_crps730
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Supero
   Data    : Fevereiro/2018                    Ultima atualizacao: 20/11/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo: Integrar as remessas com o IEPTB

   Alteracoes: 
   
   06/09/2018 - INC0023422 Inclusão de logs de exception para capturar possíveis problemas de processamento;
                inclusão de pc_set_modulo (Carlos)

   24/09/2018 - Merge de atualização CS 25888 - Ajuste no controle da varivel vr_tot_outros_cra_tarifa (Nagasava Supero)

   02/10/2018 - Merge de atualização CS 26141 - Ajuste na conversão de datas nos campos 34 e 37 (Nagasava Supero)
   
   01/10/2018 - inc0024348 Passagem do nome do programa para a execução da rotina tela_manprt.pc_gera_conciliacao_auto;
                Validação das conversões das datas dos campos 34 e 37 (Carlos)

   20/11/2018 - Merge CS#27681 - Nao processar arquivos sem conteudo (P352 - Fabio Stein - Supero)
   
  ............................................................................. */
  
  -- Declarações
  -- Tipo de registro linha
  TYPE typ_reg_linha IS RECORD
    (campot01 VARCHAR2(01)
    ,campot02 VARCHAR2(03)
    ,campot03 VARCHAR2(15)
    ,campot04 VARCHAR2(45)
    ,campot05 VARCHAR2(45)
    ,campot06 VARCHAR2(14)
    ,campot07 VARCHAR2(45)
    ,campot08 VARCHAR2(08)
    ,campot09 VARCHAR2(20)
    ,campot10 VARCHAR2(02)
    ,campot11 VARCHAR2(15)
    ,campot12 VARCHAR2(03)
    ,campot13 VARCHAR2(11)
    ,campot14 VARCHAR2(08)
    ,campot15 VARCHAR2(08)
    ,campot16 VARCHAR2(03)
    ,campot17 VARCHAR2(14)
    ,campot18 VARCHAR2(14)
    ,campot19 VARCHAR2(20)
    ,campot20 VARCHAR2(01)
    ,campot21 VARCHAR2(01)
    ,campot22 VARCHAR2(01)
    ,campot23 VARCHAR2(45)
    ,campot24 VARCHAR2(03)
    ,campot25 VARCHAR2(14)
    ,campot26 VARCHAR2(11)
    ,campot27 VARCHAR2(45)
    ,campot28 VARCHAR2(08)
    ,campot29 VARCHAR2(20)
    ,campot30 VARCHAR2(02)
    ,campot31 VARCHAR2(02)
    ,campot32 VARCHAR2(10)
    ,campot33 VARCHAR2(01)
    ,campot34 VARCHAR2(08)
    ,campot35 VARCHAR2(10)
    ,campot36 VARCHAR2(01)
    ,campot37 VARCHAR2(08)
    ,campot38 VARCHAR2(02)
    ,campot39 VARCHAR2(20)
    ,campot40 VARCHAR2(10)
    ,campot41 VARCHAR2(06)
    ,campot42 VARCHAR2(10)
    ,campot43 VARCHAR2(05)
    ,campot44 VARCHAR2(15)
    ,campot45 VARCHAR2(03)
    ,campot46 VARCHAR2(01)
    ,campot47 VARCHAR2(08)
    ,campot48 VARCHAR2(01)
    ,campot49 VARCHAR2(01)
    ,campot50 VARCHAR2(10)
    ,campot51 VARCHAR2(19)
    ,campot52 VARCHAR2(04)
    ,campot53 CLOB
    ,campoh04 VARCHAR2(08)
    ,campoh08 VARCHAR2(06)
    ,campoh15 VARCHAR2(07)
		,nmarquiv VARCHAR2(12)
    );
  -- Tabela para tipo de registro linha
  TYPE typ_tab_arquivo IS TABLE OF typ_reg_linha INDEX BY PLS_INTEGER;
  -- Tabela que contém o arquivo
  vr_tab_arquivo  typ_tab_arquivo;
	
	-- Tipo de registro cooperativa
	TYPE typ_reg_coop IS RECORD
    (cdcooper crapcop.cdcooper%TYPE
    ,vlcustas        NUMBER
		,vltarifa        NUMBER
		,vlcustas_outros NUMBER
		,vlcustas_sp     NUMBER
		,vltarifa_outros NUMBER
		,vltarifa_sp     NUMBER
		);
	-- Tabela de tipo cooperativa
	TYPE typ_tab_coop IS TABLE OF typ_reg_coop INDEX BY PLS_INTEGER;
	-- Tabela que contem as cooperativas
	vr_tab_coop typ_tab_coop;
	
	-- Tipo de registro TED
	TYPE typ_reg_ted IS RECORD
    (vr_cdcooper crapcop.cdcooper%TYPE                             -- Cooperativa
		,vr_cdagenci tbfin_recursos_movimento.cdagenci_debitada%TYPE   -- Agencia Remetente
		,vr_nrdconta tbfin_recursos_movimento.dsconta_debitada%TYPE    -- Conta Remetente
		,vr_tppessoa tbfin_recursos_movimento.inpessoa_debitada%TYPE   -- Tipo de pessoa Remetente
		,vr_origem   INTEGER                                           -- Fixo 7 -- Processo automático
		,vr_nrispbif tbfin_recursos_movimento.nrispbif%TYPE            -- Banco destino
		,vr_cdageban tbfin_recursos_movimento.cdagenci_creditada%TYPE  -- Agencia destino
		,vr_nrctatrf tbfin_recursos_movimento.dsconta_creditada%TYPE   -- Conta destino                          
		,vr_nmtitula tbfin_recursos_movimento.nmtitular_creditada%TYPE -- Nnome do titular destino
		,vr_nrcpfcgc tbfin_recursos_movimento.nrcnpj_creditada%TYPE    -- CPF do titular destino
		,vr_intipcta tbfin_recursos_movimento.tpconta_creditada%TYPE   -- Tipo de conta destino
		,vr_inpessoa tbfin_recursos_movimento.inpessoa_debitada%TYPE   -- Tipo de pessoa destino
		,vr_vllanmto tbfin_recursos_movimento.vllanmto%TYPE            -- Valor do lançamento
		,vr_cdfinali INTEGER                                           -- Finalidade TED
		,vr_operador VARCHAR2(2)                                       -- Fixo 1 -- Processo automático
		,vr_cdhistor tbfin_recursos_movimento.cdhistor%TYPE            -- Código do histórico
		,vr_tpregist VARCHAR2(100)                                     -- Tipo registro
		,vr_tporigem VARCHAR2(100)                                     -- Tabela de origem
		);
	-- Tabela de tipo TED
	TYPE typ_tab_ted IS TABLE OF typ_reg_ted INDEX BY PLS_INTEGER;
	-- Tabela que contem as TEDs
	vr_tab_ted typ_tab_ted;
	-- Registro de TED
	vr_reg_ted typ_reg_ted;
	 
	-- Tipo de registro lançamento
	TYPE typ_reg_lancto IS RECORD
    (vr_tpregist  VARCHAR2(100)                            -- Tipo registro
		,vr_origem    VARCHAR2(100)                            -- Tabela de origem
		,vr_cdcooper  tbcobran_confirmacao_ieptb.cdcooper%TYPE -- Cooperativa
		,vr_dtmvtolt  tbcobran_confirmacao_ieptb.dtmvtolt%TYPE -- Data do movimento
		,vr_cdcomarc  tbcobran_confirmacao_ieptb.cdcomarc%TYPE -- Comarca
		,vr_nrseqrem  tbcobran_confirmacao_ieptb.nrseqrem%TYPE -- Sequencial de remessa
		,vr_nrseqarq  tbcobran_confirmacao_ieptb.nrseqarq%TYPE -- Sequencia do arquivo
    ,vr_idretorno tbcobran_retorno_ieptb.idretorno%TYPE    -- Lançamento retorno
		);
	-- Tabela de registro lançamento
	TYPE typ_tab_lancto IS TABLE OF typ_reg_lancto INDEX BY PLS_INTEGER;
	-- Tabela que contem os lançamentos
	vr_tab_lancto typ_tab_lancto;
	-- Registro do lançamento
	vr_reg_lancto typ_reg_lancto;
	 
  vr_exc_erro     EXCEPTION;
  
  vr_nrretcoo     NUMBER := 0;
  -- Cursor gen¿rico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
	--
	vr_dtmvtolt crapdat.dtmvtolt%TYPE;
	--
	vr_dtauxili DATE;
  --
	texto CLOB;
  
  vr_cdprogra VARCHAR2(32) := 'CRPS730';
  
  vr_idprglog NUMBER := 0;
  
  -- Subrotinas
	-- Remove caracteres especiais
	FUNCTION fun_remove_char_esp(pr_texto IN VARCHAR2
		                          ) RETURN VARCHAR2 IS
	BEGIN
		--
		RETURN translate(pr_texto,'ÑÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇñáéíóúàèìòùâêîôûãõäëïöüç.-!"''`#$%().:[/]{}¨+?;ºª°§&´*<>','NAEIOUAEIOUAEIOUAOAEIOUCnaeiouaeiouaeiouaoaeiouc');
		--
	END fun_remove_char_esp;
	
  -- Controla Controla log
  PROCEDURE pc_controla_log_batch(pr_idtiplog IN NUMBER   -- Tipo de Log
                                 ,pr_dscritic IN VARCHAR2 -- Descrição do Log
                                 ) IS
    --
    vr_dstiplog VARCHAR2(10);
    --
  BEGIN
    -- Descrição do tipo de log
    IF pr_idtiplog = 2 THEN
      --
      vr_dstiplog := 'ERRO: ';
      --
    ELSE
      --
      vr_dstiplog := 'ALERTA: ';
      --
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Fixo?
                              ,pr_ind_tipo_log => pr_idtiplog
                              ,pr_cdprograma   => 'CRPS730'
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED', 3 /*pr_cdcooper*/, 'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - '
                                                          || 'CRPS730' || ' --> ' || vr_dstiplog
                                                          || pr_dscritic );     
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      pc_internal_exception (pr_cdcooper => 3);                                                             
  END pc_controla_log_batch;
   
  -- Rotina que insere um valor numa linha da tabela em memória
  PROCEDURE pc_insere_valor(/*pr_nrrow    IN      NUMBER
                           ,*/pr_nrattrib IN      NUMBER
                           ,pr_dsvalue  IN      CLOB
                           ,pr_reg_linha IN OUT typ_reg_linha
                           ,pr_dscritic OUT     VARCHAR2
                           ) IS
  BEGIN
    --
    CASE
      WHEN pr_nrattrib = 0 THEN
        pr_reg_linha.campot01 := pr_dsvalue;
      WHEN pr_nrattrib = 1 THEN
        pr_reg_linha.campot02 := pr_dsvalue;
      WHEN pr_nrattrib = 2 THEN
        pr_reg_linha.campot03 := pr_dsvalue;
      WHEN pr_nrattrib = 3 THEN
        pr_reg_linha.campot04 := pr_dsvalue;
      WHEN pr_nrattrib = 4 THEN
        pr_reg_linha.campot05 := pr_dsvalue;
      WHEN pr_nrattrib = 5 THEN
        pr_reg_linha.campot06 := pr_dsvalue;
      WHEN pr_nrattrib = 6 THEN
        pr_reg_linha.campot07 := pr_dsvalue;
      WHEN pr_nrattrib = 7 THEN
        pr_reg_linha.campot08 := pr_dsvalue;
      WHEN pr_nrattrib = 8 THEN
        pr_reg_linha.campot09 := pr_dsvalue;
      WHEN pr_nrattrib = 9 THEN
        pr_reg_linha.campot10 := pr_dsvalue;
      WHEN pr_nrattrib = 10 THEN
        pr_reg_linha.campot11 := pr_dsvalue;
      WHEN pr_nrattrib = 11 THEN
        pr_reg_linha.campot12 := pr_dsvalue;
      WHEN pr_nrattrib = 12 THEN
        pr_reg_linha.campot13 := pr_dsvalue;
      WHEN pr_nrattrib = 13 THEN
        pr_reg_linha.campot14 := pr_dsvalue;
      WHEN pr_nrattrib = 14 THEN
        pr_reg_linha.campot15 := pr_dsvalue;
      WHEN pr_nrattrib = 15 THEN
        pr_reg_linha.campot16 := pr_dsvalue;
      WHEN pr_nrattrib = 16 THEN
        pr_reg_linha.campot17 := pr_dsvalue;
      WHEN pr_nrattrib = 17 THEN
        pr_reg_linha.campot18 := pr_dsvalue;
      WHEN pr_nrattrib = 18 THEN
        pr_reg_linha.campot19 := pr_dsvalue;
      WHEN pr_nrattrib = 19 THEN
        pr_reg_linha.campot20 := pr_dsvalue;
      WHEN pr_nrattrib = 20 THEN
        pr_reg_linha.campot21 := pr_dsvalue;
      WHEN pr_nrattrib = 21 THEN
        pr_reg_linha.campot22 := pr_dsvalue;
      WHEN pr_nrattrib = 22 THEN
        pr_reg_linha.campot23 := pr_dsvalue;
      WHEN pr_nrattrib = 23 THEN
        pr_reg_linha.campot24 := pr_dsvalue;
      WHEN pr_nrattrib = 24 THEN
        pr_reg_linha.campot25 := pr_dsvalue;
      WHEN pr_nrattrib = 25 THEN
        pr_reg_linha.campot26 := pr_dsvalue;
      WHEN pr_nrattrib = 26 THEN
        pr_reg_linha.campot27 := pr_dsvalue;
      WHEN pr_nrattrib = 27 THEN
        pr_reg_linha.campot28 := pr_dsvalue;
      WHEN pr_nrattrib = 28 THEN
        pr_reg_linha.campot29 := pr_dsvalue;
      WHEN pr_nrattrib = 29 THEN
        pr_reg_linha.campot30 := pr_dsvalue;
      WHEN pr_nrattrib = 30 THEN
        pr_reg_linha.campot31 := pr_dsvalue;
      WHEN pr_nrattrib = 31 THEN
        pr_reg_linha.campot32 := pr_dsvalue;
      WHEN pr_nrattrib = 32 THEN
        pr_reg_linha.campot33 := pr_dsvalue;
      WHEN pr_nrattrib = 33 THEN
        pr_reg_linha.campot34 := pr_dsvalue;
      WHEN pr_nrattrib = 34 THEN
        pr_reg_linha.campot35 := pr_dsvalue;
      WHEN pr_nrattrib = 35 THEN
        pr_reg_linha.campot36 := pr_dsvalue;
      WHEN pr_nrattrib = 36 THEN
        pr_reg_linha.campot37 := pr_dsvalue;
      WHEN pr_nrattrib = 37 THEN
        pr_reg_linha.campot38 := pr_dsvalue;
      WHEN pr_nrattrib = 38 THEN
        pr_reg_linha.campot39 := pr_dsvalue;
      WHEN pr_nrattrib = 39 THEN
        pr_reg_linha.campot40 := pr_dsvalue;
      WHEN pr_nrattrib = 40 THEN
        pr_reg_linha.campot41 := pr_dsvalue;
      WHEN pr_nrattrib = 41 THEN
        pr_reg_linha.campot42 := pr_dsvalue;
      WHEN pr_nrattrib = 42 THEN
        pr_reg_linha.campot43 := pr_dsvalue;
      WHEN pr_nrattrib = 43 THEN
        pr_reg_linha.campot44 := pr_dsvalue;
      WHEN pr_nrattrib = 44 THEN
        pr_reg_linha.campot45 := pr_dsvalue;
      WHEN pr_nrattrib = 45 THEN
        pr_reg_linha.campot46 := pr_dsvalue;
      WHEN pr_nrattrib = 46 THEN
        pr_reg_linha.campot47 := pr_dsvalue;
      WHEN pr_nrattrib = 47 THEN
        pr_reg_linha.campot48 := pr_dsvalue;
      WHEN pr_nrattrib = 48 THEN
        pr_reg_linha.campot49 := pr_dsvalue;
      WHEN pr_nrattrib = 49 THEN
        pr_reg_linha.campot50 := pr_dsvalue;
      WHEN pr_nrattrib = 50 THEN
        pr_reg_linha.campot51 := pr_dsvalue;
      WHEN pr_nrattrib = 51 THEN
        pr_reg_linha.campot52 := pr_dsvalue;
      WHEN pr_nrattrib = 52 THEN
        pr_reg_linha.campot53 := pr_dsvalue;
      WHEN pr_nrattrib = 64 THEN
        pr_reg_linha.campoh04 := pr_dsvalue;
      WHEN pr_nrattrib = 68 THEN
        pr_reg_linha.campoh08 := pr_dsvalue;
      WHEN pr_nrattrib = 75 THEN
        pr_reg_linha.campoh15 := pr_dsvalue;
			WHEN pr_nrattrib = 100 THEN
				pr_reg_linha.nmarquiv := pr_dsvalue;
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Erro ao tentar atribuir o valor: ' || pr_nrattrib || '/' || pr_dsvalue || ': ' || SQLERRM;
  END pc_insere_valor;
  
  PROCEDURE pc_insere_registro(pr_dsdireto IN  VARCHAR2
                              ,pr_dsarquiv IN  VARCHAR2
                              ,pr_dscritic OUT VARCHAR2
                              ) IS
    --
    p   xmlparser.parser;
    doc xmldom.DOMDocument;
    --
    nl       xmldom.DOMNodeList;
    len1     NUMBER;
    len2     NUMBER;
    n        xmldom.DOMNode;
    n2       xmldom.DOMNode;
    e        xmldom.DOMElement;
    nnm      xmldom.DOMNamedNodeMap;
    attrname VARCHAR2(4000);
    attrval  VARCHAR2(4000);
    --
    campoh04 VARCHAR2(4000);
    campoh08 VARCHAR2(4000);
    campoh15 VARCHAR2(4000);
    --
    vr_reg_linha typ_reg_linha;
    --
    vr_exc_erro EXCEPTION;
    --
  BEGIN
    --
    IF NOT GENE0001.fn_exis_arquivo(pr_dsdireto || '/' || pr_dsarquiv) THEN
      RETURN;
    END IF;
		--
		IF GENE0001.fn_tamanho_arquivo(pr_dsdireto || '/' || pr_dsarquiv) = 0 THEN
      RETURN;
		END IF;	

    -- new parser
    p := xmlparser.newParser;

    -- set some characteristics
    xmlparser.setValidationMode(p, FALSE);
    xmlparser.setBaseDir(p, pr_dsdireto);

    -- parse input file
    xmlparser.parse(p, pr_dsdireto || '/' || pr_dsarquiv);

    -- get document
    doc := xmlparser.getDocument(p);

    -- Get document element attributes
    -- get all elements
    nl := xmldom.getElementsByTagName(doc, '*');
    len1 := xmldom.getLength(nl);
    
    -- loop through elements
    for j in 0..len1-1 LOOP
      --
      vr_reg_linha := NULL;
      --
      n := xmldom.item(nl, j);
      e := xmldom.makeElement(n);
      
      --dbms_output.put_line(xmldom.getNodeName(n) || ' 1');
      
      -- get all attributes of element
      nnm := xmldom.getAttributes(n);
      --
      if (xmldom.isNull(nnm) = FALSE) THEN
        --
        IF xmldom.getNodeName(n) = 'hd' THEN
          --
          n2       := xmldom.item(nnm, 3); -- Campo 04
          campoh04 := xmldom.getNodeValue(n2);
          --
          n2       := xmldom.item(nnm, 7); -- Campo 08
          campoh08 := xmldom.getNodeValue(n2);
          --
          n2       := xmldom.item(nnm, 14); -- Campo 15
          campoh15 := xmldom.getNodeValue(n2);
          --
					dbms_lob.createtemporary(texto, TRUE);
					dbms_lob.OPEN(texto,dbms_lob.lob_readwrite);
					--xmldom.WRITETOBUFFER(n,texto);
					xmldom.writeToClob(n,texto);
					--
					pc_insere_valor(pr_nrattrib  => 52           -- IN
												 ,pr_dsvalue   => texto        -- IN
												 ,pr_reg_linha => vr_reg_linha -- IN OUT
												 ,pr_dscritic  => pr_dscritic  -- OUT
												 );
					--
					dbms_lob.close(texto);
          dbms_lob.freetemporary(texto);
					--
					IF pr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					--
        ELSIF xmldom.getNodeName(n) = 'tr' THEN
          --
          --dbms_output.put_line('reg: ' || vr_tab_arquivo.count());
          --
          len2 := xmldom.getLength(nnm);
          -- loop through attributes
          FOR i IN 0..len2-1 LOOP
            --
            n2 := xmldom.item(nnm, i);
            attrname := xmldom.getNodeName(n2);
            --dbms_output.put_line(xmldom.getNodeName(n2) || ' 2');
            attrval := xmldom.getNodeValue(n2);
            --
            pc_insere_valor(/*pr_nrrow     => j            -- IN
                           ,*/pr_nrattrib  => i            -- IN
                           ,pr_dsvalue   => attrval      -- IN
                           ,pr_reg_linha => vr_reg_linha -- IN OUT
                           ,pr_dscritic  => pr_dscritic  -- OUT
                           );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
            --
						dbms_lob.createtemporary(texto, TRUE);
					  dbms_lob.OPEN(texto,dbms_lob.lob_readwrite);
						--
						--xmldom.WRITETOBUFFER(n2,texto);
						xmldom.writeToClob(n,texto);
						--
						pc_insere_valor(pr_nrattrib  => 52           -- IN
													 ,pr_dsvalue   => texto        -- IN
													 ,pr_reg_linha => vr_reg_linha -- IN OUT
													 ,pr_dscritic  => pr_dscritic  -- OUT
													 );
						--
						dbms_lob.close(texto);
            dbms_lob.freetemporary(texto);
						--
					END LOOP;
          --
          pc_insere_valor(/*pr_nrrow     => j            -- IN
                         ,*/pr_nrattrib  => 64           -- IN
                         ,pr_dsvalue   => campoh04     -- IN
                         ,pr_reg_linha => vr_reg_linha -- IN OUT
                         ,pr_dscritic  => pr_dscritic  -- OUT
                         );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          END IF;
          --
          pc_insere_valor(/*pr_nrrow     => j            -- IN
                         ,*/pr_nrattrib  => 68           -- IN
                         ,pr_dsvalue   => campoh08     -- IN
                         ,pr_reg_linha => vr_reg_linha -- IN OUT
                         ,pr_dscritic  => pr_dscritic  -- OUT
                         );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          END IF;
          --
          pc_insere_valor(/*pr_nrrow     => j            -- IN
                         ,*/pr_nrattrib  => 75           -- IN
                         ,pr_dsvalue   => campoh15     -- IN
                         ,pr_reg_linha => vr_reg_linha -- IN OUT
                         ,pr_dscritic  => pr_dscritic  -- OUT
                         );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          END IF;
					--
					pc_insere_valor(/*pr_nrrow     => j            -- IN
                         ,*/pr_nrattrib  => 100          -- IN
                         ,pr_dsvalue   => pr_dsarquiv  -- IN
                         ,pr_reg_linha => vr_reg_linha -- IN OUT
                         ,pr_dscritic  => pr_dscritic  -- OUT
                         );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          END IF;
          --
          vr_tab_arquivo(vr_tab_arquivo.count()) := vr_reg_linha;
          --
        END IF;
        --
      END IF;
      --
    END LOOP;
    -- deal with exceptions
  EXCEPTION
    WHEN xmldom.INDEX_SIZE_ERR THEN
      pr_dscritic := 'Index Size error';
    WHEN xmldom.DOMSTRING_SIZE_ERR THEN
      pr_dscritic := 'String Size error';
    WHEN xmldom.HIERARCHY_REQUEST_ERR THEN
      pr_dscritic := 'Hierarchy request error';
    WHEN xmldom.WRONG_DOCUMENT_ERR THEN
      pr_dscritic := 'Wrong doc error';
    WHEN xmldom.INVALID_CHARACTER_ERR THEN
      pr_dscritic := 'Invalid Char error';
    WHEN xmldom.NO_DATA_ALLOWED_ERR THEN
      pr_dscritic := 'Nod data allowed error';
    WHEN xmldom.NO_MODIFICATION_ALLOWED_ERR THEN
      pr_dscritic := 'No mod allowed error';
    WHEN xmldom.NOT_FOUND_ERR THEN
      pr_dscritic := 'Not found error';
    WHEN xmldom.NOT_SUPPORTED_ERR THEN
      pr_dscritic := 'Not supported error';
    WHEN xmldom.INUSE_ATTRIBUTE_ERR THEN
      pr_dscritic := 'In use attr error';
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Erro ao processar o registro: ' || SQLERRM;
    --
  END pc_insere_registro;
   
  -- Rotina que carrega os arquivos de confirmação
  PROCEDURE pc_carrega_arquivo_confirmacao(pr_cdcooper IN  crapcop.cdcooper%TYPE
		                                      ,pr_dscritic OUT VARCHAR2
                                          ) IS
    --
    vr_tab_confirmacao TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_pesq            VARCHAR2(500)         := NULL;
    vr_dsdireto        VARCHAR2(500);--         := '/micros/cecred/ieptb/retorno/';
    --vr_nmarquiv        VARCHAR2(500)         := NULL;
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(4000);
    --
  BEGIN
		--
		vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																						,pr_cdcooper => pr_cdcooper
																						,pr_cdacesso => 'DIR_IEPTB_RETORNO'
																						);
    -- Buscar arquivos de confirmação
    vr_pesq := 'C%%%%%%%.%%%';
    -- Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_confirmacao
                              ,pr_path          => vr_dsdireto
                              ,pr_pesq          => vr_pesq
                              );
    --
    IF vr_tab_confirmacao.COUNT() > 0 THEN
      --
      FOR idx IN 1..vr_tab_confirmacao.COUNT() LOOP
        --
        --vr_nmarquiv := vr_dsdireto || vr_tab_confirmacao(idx);
        -- Processar o arquivo
        pc_insere_registro(pr_dsdireto => vr_dsdireto             -- IN
                          ,pr_dsarquiv => vr_tab_confirmacao(idx) -- IN
                          ,pr_dscritic => pr_dscritic             -- OUT
                          );
        -- Se retornou erro
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN     
      -- Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --
      END IF;  
      --  
      pr_dscritic := vr_dscritic;
      --
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Não foi possivel importar o arquivo de confirmação: '||SQLERRM;
    --
  END pc_carrega_arquivo_confirmacao;
	
	-- Atualiza a confirmação
	PROCEDURE pc_atualiza_confirmacao(pr_cdcooper      IN  tbcobran_confirmacao_ieptb.cdcooper%TYPE
		                               ,pr_dtmvtolt      IN  tbcobran_confirmacao_ieptb.dtmvtolt%TYPE
																	 ,pr_cdcomarc      IN  tbcobran_confirmacao_ieptb.cdcomarc%TYPE
																	 ,pr_nrseqrem      IN  tbcobran_confirmacao_ieptb.nrseqrem%TYPE
																	 ,pr_nrseqarq      IN  tbcobran_confirmacao_ieptb.nrseqarq%TYPE
																	 ,pr_dtcustas_proc   IN  tbcobran_confirmacao_ieptb.dtcustas_proc%TYPE DEFAULT NULL
																	 ,pr_idlancto_tarifa IN  tbcobran_confirmacao_ieptb.idlancto_tarifa%TYPE DEFAULT NULL
																	 ,pr_idlancto_custas IN  tbcobran_confirmacao_ieptb.idlancto_custas%TYPE DEFAULT NULL
																	 ,pr_dscritic      OUT VARCHAR2
		                               ) IS
	BEGIN
		--
		UPDATE tbcobran_confirmacao_ieptb
		   SET tbcobran_confirmacao_ieptb.dtcustas_proc   = nvl(pr_dtcustas_proc, tbcobran_confirmacao_ieptb.dtcustas_proc)
			    ,tbcobran_confirmacao_ieptb.flcustas_proc   = decode(pr_dtcustas_proc
					                                                    ,NULL
																															,tbcobran_confirmacao_ieptb.flcustas_proc
																															,1
																															) -- Fixo
					,tbcobran_confirmacao_ieptb.idlancto_tarifa = nvl(pr_idlancto_tarifa, tbcobran_confirmacao_ieptb.idlancto_tarifa)
					,tbcobran_confirmacao_ieptb.idlancto_custas = nvl(pr_idlancto_custas, tbcobran_confirmacao_ieptb.idlancto_custas)
		 WHERE tbcobran_confirmacao_ieptb.cdcooper = pr_cdcooper
		   AND tbcobran_confirmacao_ieptb.dtmvtolt = pr_dtmvtolt
			 AND tbcobran_confirmacao_ieptb.cdcomarc = pr_cdcomarc
			 AND tbcobran_confirmacao_ieptb.nrseqrem = pr_nrseqrem
			 AND tbcobran_confirmacao_ieptb.nrseqarq = pr_nrseqarq;
		--
	EXCEPTION
		WHEN OTHERS THEN
      cecred.pc_internal_exception;
			pr_dscritic := 'Erro ao atualizar a tabela tbcobran_confirmacao_ieptb: ' || SQLERRM;
	END pc_atualiza_confirmacao;
	
	-- Atualiza o retorno
	PROCEDURE pc_atualiza_retorno(pr_cdcooper      IN  tbcobran_retorno_ieptb.cdcooper%TYPE
		                           ,pr_dtmvtolt      IN  tbcobran_retorno_ieptb.dtmvtolt%TYPE
															 ,pr_cdcomarc      IN  tbcobran_retorno_ieptb.cdcomarc%TYPE
															 ,pr_nrseqrem      IN  tbcobran_retorno_ieptb.nrseqrem%TYPE
															 ,pr_nrseqarq      IN  tbcobran_retorno_ieptb.nrseqarq%TYPE
															 ,pr_dtcustas_proc IN  tbcobran_retorno_ieptb.dtcustas_proc%TYPE
															 ,pr_idretorno       IN  tbcobran_retorno_ieptb.idretorno%TYPE DEFAULT NULL
															 ,pr_idlancto_tarifa IN  tbcobran_retorno_ieptb.idlancto_tarifa%TYPE DEFAULT NULL
															 ,pr_idlancto_custas IN  tbcobran_retorno_ieptb.idlancto_custas%TYPE DEFAULT NULL
															 ,pr_dscritic      OUT VARCHAR2
		                           ) IS
	BEGIN
		--
		IF pr_idretorno IS NULL THEN
			--
			BEGIN
				--
		UPDATE tbcobran_retorno_ieptb
					 SET tbcobran_retorno_ieptb.dtcustas_proc = nvl(pr_dtcustas_proc, tbcobran_retorno_ieptb.dtcustas_proc)
							,tbcobran_retorno_ieptb.flcustas_proc = decode(pr_dtcustas_proc
							                                              ,NULL
																														,tbcobran_retorno_ieptb.flcustas_proc
																														,1
																														) -- Fixo
		 WHERE tbcobran_retorno_ieptb.cdcooper = pr_cdcooper
		   AND tbcobran_retorno_ieptb.dtmvtolt = pr_dtmvtolt
			 AND tbcobran_retorno_ieptb.cdcomarc = pr_cdcomarc
			 AND tbcobran_retorno_ieptb.nrseqrem = pr_nrseqrem
			 AND tbcobran_retorno_ieptb.nrseqarq = pr_nrseqarq;
		--
	EXCEPTION
		WHEN OTHERS THEN
          cecred.pc_internal_exception;
					pr_dscritic := '1.Erro ao atualizar a tabela tbcobran_retorno_ieptb: ' || SQLERRM;
		  END;
			--
		ELSE
			--
			BEGIN
				--
				UPDATE tbcobran_retorno_ieptb
					 SET tbcobran_retorno_ieptb.dtcustas_proc   = nvl(pr_dtcustas_proc, tbcobran_retorno_ieptb.dtcustas_proc)
							,tbcobran_retorno_ieptb.flcustas_proc   = decode(pr_dtcustas_proc
																															,NULL
																															,tbcobran_retorno_ieptb.flcustas_proc
																															,1
																															) -- Fixo
				      ,tbcobran_retorno_ieptb.idlancto_tarifa = nvl(pr_idlancto_tarifa, tbcobran_retorno_ieptb.idlancto_tarifa)
							,tbcobran_retorno_ieptb.idlancto_custas = nvl(pr_idlancto_custas, tbcobran_retorno_ieptb.idlancto_custas)
				 WHERE tbcobran_retorno_ieptb.idretorno = pr_idretorno;
				--
			EXCEPTION
				WHEN OTHERS THEN
          cecred.pc_internal_exception;
					pr_dscritic := '2.Erro ao atualizar a tabela tbcobran_retorno_ieptb: ' || SQLERRM;
		  END;
			--
		END IF;
		--
	END pc_atualiza_retorno;
  
  -- Rotina que carrega os arquivos de retorno
  PROCEDURE pc_carrega_arquivo_retorno(pr_cdcooper IN  crapcop.cdcooper%TYPE
		                                  ,pr_dscritic OUT VARCHAR2
                                      ) IS
    --
    vr_tab_retorno TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_pesq            VARCHAR2(500)         := NULL;
    vr_dsdireto        VARCHAR2(500);--         := '/micros/cecred/ieptb/retorno/';
    vr_nmarquiv        VARCHAR2(500)         := NULL;
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(4000);
    --
  BEGIN
		--
		vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																						,pr_cdcooper => pr_cdcooper
																						,pr_cdacesso => 'DIR_IEPTB_RETORNO'
																						);
    -- Buscar arquivos de retorno
    vr_pesq := 'R%%%%%%%.%%%';
    -- Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_retorno
                              ,pr_path          => vr_dsdireto
                              ,pr_pesq          => vr_pesq
                              );
    --
    IF vr_tab_retorno.COUNT() > 0 THEN
      --
      FOR idx IN 1..vr_tab_retorno.COUNT() LOOP
        --
        vr_nmarquiv := vr_dsdireto || vr_tab_retorno(idx);
        -- Processar o arquivo
        pc_insere_registro(pr_dsdireto => vr_dsdireto             -- IN
                          ,pr_dsarquiv => vr_tab_retorno(idx) -- IN
                          ,pr_dscritic => pr_dscritic             -- OUT
                          );
        -- Se retornou erro
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN     
      -- Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				pr_dscritic := vr_dscritic;
        --
      END IF;  
      --
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Não foi possivel importar o arquivo de retorno: '||SQLERRM;
    --
  END pc_carrega_arquivo_retorno;
  
  -- Insere o registro na tabela de confirmação do IEPTB
  PROCEDURE pc_gera_confirmacao_ieptb(pr_cdcooper            IN  tbcobran_confirmacao_ieptb.cdcooper%TYPE
                                     ,pr_dtmvtolt            IN  tbcobran_confirmacao_ieptb.dtmvtolt%TYPE
                                     ,pr_cdcomarc            IN  tbcobran_confirmacao_ieptb.cdcomarc%TYPE
                                     ,pr_nrseqrem            IN  tbcobran_confirmacao_ieptb.nrseqrem%TYPE
                                     ,pr_nrseqarq            IN  tbcobran_confirmacao_ieptb.nrseqarq%TYPE
                                     ,pr_nrdconta            IN  tbcobran_confirmacao_ieptb.nrdconta%TYPE
                                     ,pr_nrcnvcob            IN  tbcobran_confirmacao_ieptb.nrcnvcob%TYPE
                                     ,pr_nrdocmto            IN  tbcobran_confirmacao_ieptb.nrdocmto%TYPE
                                     ,pr_nrremret            IN  tbcobran_confirmacao_ieptb.nrremret%TYPE
                                     ,pr_nrseqreg            IN  tbcobran_confirmacao_ieptb.nrseqreg%TYPE
                                     ,pr_cdcartorio          IN  tbcobran_confirmacao_ieptb.cdcartorio%TYPE
                                     ,pr_nrprotoc_cartorio   IN  tbcobran_confirmacao_ieptb.nrprotoc_cartorio%TYPE
                                     ,pr_tpocorre            IN  tbcobran_confirmacao_ieptb.tpocorre%TYPE
                                     ,pr_dtprotocolo         IN  tbcobran_confirmacao_ieptb.dtprotocolo%TYPE
                                     ,pr_vlcuscar            IN  tbcobran_confirmacao_ieptb.vlcuscar%TYPE
                                     ,pr_dtocorre            IN  tbcobran_confirmacao_ieptb.dtocorre%TYPE
                                     ,pr_cdirregu            IN  tbcobran_confirmacao_ieptb.cdirregu%TYPE
                                     ,pr_vlcustas_cartorio   IN  tbcobran_confirmacao_ieptb.vlcustas_cartorio%TYPE
                                     ,pr_vlgrava_eletronica  IN  tbcobran_confirmacao_ieptb.vlgrava_eletronica%TYPE
                                     ,pr_cdcomplem_irregular IN  tbcobran_confirmacao_ieptb.cdcomplem_irregular%TYPE
                                     ,pr_vldemais_despes     IN  tbcobran_confirmacao_ieptb.vldemais_despes%TYPE
                                     ,pr_vltitulo            IN  tbcobran_confirmacao_ieptb.vltitulo%TYPE
                                     ,pr_vlsaldo_titulo      IN  tbcobran_confirmacao_ieptb.vlsaldo_titulo%TYPE
                                     ,pr_dsregist            IN  tbcobran_confirmacao_ieptb.dsregist%TYPE
                                     ,pr_dscritic          	 OUT VARCHAR2
                                     ) IS
  --

    vr_nrseqarq INTEGER;
  BEGIN
    --

    INSERT INTO tbcobran_confirmacao_ieptb(cdcooper
                                          ,dtmvtolt
                                          ,cdcomarc
                                          ,nrseqrem
                                          ,nrseqarq
                                          ,nrdconta
                                          ,nrcnvcob
                                          ,nrdocmto
                                          ,nrremret
                                          ,nrseqreg
                                          ,cdcartorio
                                          ,nrprotoc_cartorio
                                          ,tpocorre
                                          ,dtprotocolo
                                          ,vlcuscar
                                          ,dtocorre
                                          ,cdirregu
                                          ,vlcustas_cartorio
                                          ,vlgrava_eletronica
                                          ,cdcomplem_irregular
                                          ,vldemais_despes
                                          ,vltitulo
                                          ,vlsaldo_titulo
                                          ,dsregist
                                          ) VALUES(pr_cdcooper
                                                  ,pr_dtmvtolt
                                                  ,pr_cdcomarc
                                                  ,pr_nrseqrem
                                                  ,pr_nrseqarq
                                                  ,pr_nrdconta
                                                  ,pr_nrcnvcob
                                                  ,pr_nrdocmto
                                                  ,pr_nrremret
                                                  ,pr_nrseqreg
                                                  ,pr_cdcartorio
                                                  ,pr_nrprotoc_cartorio
                                                  ,pr_tpocorre
                                                  ,pr_dtprotocolo
                                                  ,pr_vlcuscar
                                                  ,pr_dtocorre
                                                  ,pr_cdirregu
                                                  ,pr_vlcustas_cartorio
                                                  ,pr_vlgrava_eletronica
                                                  ,pr_cdcomplem_irregular
                                                  ,pr_vldemais_despes
                                                  ,pr_vltitulo
                                                  ,pr_vlsaldo_titulo
                                                  ,pr_dsregist
                                                  );
    --
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Erro ao inserir na tbcobran_confirmacao_ieptb: ' || SQLERRM;
  END pc_gera_confirmacao_ieptb;
  
  -- Insere o registro na tabela de confirmação do IEPTB
  PROCEDURE pc_gera_retorno_ieptb(pr_cdcooper            IN  tbcobran_retorno_ieptb.cdcooper%TYPE
                                 ,pr_dtmvtolt            IN  tbcobran_retorno_ieptb.dtmvtolt%TYPE
                                 ,pr_cdcomarc            IN  tbcobran_retorno_ieptb.cdcomarc%TYPE
                                 ,pr_nrseqrem            IN  tbcobran_retorno_ieptb.nrseqrem%TYPE
                                 ,pr_nrseqarq            IN  tbcobran_retorno_ieptb.nrseqarq%TYPE
                                 ,pr_nrdconta            IN  tbcobran_retorno_ieptb.nrdconta%TYPE
                                 ,pr_nrcnvcob            IN  tbcobran_retorno_ieptb.nrcnvcob%TYPE
                                 ,pr_nrdocmto            IN  tbcobran_retorno_ieptb.nrdocmto%TYPE
                                 ,pr_nrremret            IN  tbcobran_retorno_ieptb.nrremret%TYPE
                                 ,pr_nrseqreg            IN  tbcobran_retorno_ieptb.nrseqreg%TYPE
                                 ,pr_cdcartorio          IN  tbcobran_retorno_ieptb.cdcartorio%TYPE
                                 ,pr_nrprotoc_cartorio   IN  tbcobran_retorno_ieptb.nrprotoc_cartorio%TYPE
                                 ,pr_tpocorre            IN  tbcobran_retorno_ieptb.tpocorre%TYPE
                                 ,pr_dtprotocolo         IN  tbcobran_retorno_ieptb.dtprotocolo%TYPE
                                 ,pr_vlcuscar            IN  tbcobran_retorno_ieptb.vlcuscar%TYPE
                                 ,pr_dtocorre            IN  tbcobran_retorno_ieptb.dtocorre%TYPE
                                 ,pr_cdirregu            IN  tbcobran_retorno_ieptb.cdirregu%TYPE
                                 ,pr_vlcustas_cartorio   IN  tbcobran_retorno_ieptb.vlcustas_cartorio%TYPE
                                 ,pr_vlgrava_eletronica  IN  tbcobran_retorno_ieptb.vlgrava_eletronica%TYPE
                                 ,pr_cdcomplem_irregular IN  tbcobran_retorno_ieptb.cdcomplem_irregular%TYPE
                                 ,pr_vldemais_despes     IN  tbcobran_retorno_ieptb.vldemais_despes%TYPE
                                 ,pr_vltitulo            IN  tbcobran_retorno_ieptb.vltitulo%TYPE
                                 ,pr_vlsaldo_titulo      IN  tbcobran_retorno_ieptb.vlsaldo_titulo%TYPE
                                 ,pr_dsregist            IN  tbcobran_retorno_ieptb.dsregist%TYPE
																 ,pr_idretorno           OUT NUMBER
                                 ,pr_dscritic          	 OUT VARCHAR2
                                 ) IS
    --
	  vr_idretorno NUMBER;
    vr_nrseqarq INTEGER;
	  --
	BEGIN
		-- Gerar novo retorno usando a fn_sequence 
		vr_idretorno := fn_sequence(pr_nmtabela => 'TBCOBRAN_RETORNO_IEPTB'
															 ,pr_nmdcampo => 'IDRETORNO'
															 ,pr_dsdchave => 'IDRETORNO'
															 );
                               
		--
    INSERT INTO tbcobran_retorno_ieptb(cdcooper
                                      ,dtmvtolt
                                      ,cdcomarc
                                      ,nrseqrem
                                      ,nrseqarq
                                      ,nrdconta
                                      ,nrcnvcob
                                      ,nrdocmto
                                      ,nrremret
                                      ,nrseqreg
                                      ,cdcartorio
                                      ,nrprotoc_cartorio
                                      ,tpocorre
                                      ,dtprotocolo
                                      ,vlcuscar
                                      ,dtocorre
                                      ,cdirregu
                                      ,vlcustas_cartorio
                                      ,vlgrava_eletronica
                                      ,cdcomplem_irregular
                                      ,vldemais_despes
                                      ,vltitulo
                                      ,vlsaldo_titulo
                                      ,dsregist
																			,idretorno
                                      ) VALUES(pr_cdcooper
                                              ,pr_dtmvtolt
                                              ,pr_cdcomarc
                                              ,pr_nrseqrem
                                              ,pr_nrseqarq
                                              ,pr_nrdconta
                                              ,pr_nrcnvcob
                                              ,pr_nrdocmto
                                              ,pr_nrremret
                                              ,pr_nrseqreg
                                              ,pr_cdcartorio
                                              ,pr_nrprotoc_cartorio
                                              ,pr_tpocorre
                                              ,pr_dtprotocolo
                                              ,pr_vlcuscar
                                              ,pr_dtocorre
                                              ,pr_cdirregu
                                              ,pr_vlcustas_cartorio
                                              ,pr_vlgrava_eletronica
                                              ,pr_cdcomplem_irregular
                                              ,pr_vldemais_despes
                                              ,pr_vltitulo
                                              ,pr_vlsaldo_titulo
                                              ,pr_dsregist
																							,vr_idretorno
                                              );
    --
		pr_idretorno := vr_idretorno;
		--
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Erro ao inserir na tbcobran_retorno_ieptb: ' || SQLERRM;
  END pc_gera_retorno_ieptb;
	
	-- Totaliza por cooperativa
	PROCEDURE pc_totaliza_cooperativa(pr_cdcooper IN  crapcop.cdcooper%TYPE
		                               ,pr_cdfedera IN  VARCHAR2
		                               ,pr_vlcustas IN  NUMBER
																	 ,pr_vltarifa IN  NUMBER
		                               ,pr_dscritic OUT VARCHAR2
		                               ) IS
	  --
		vr_achou      BOOLEAN := FALSE;
		vr_index_coop NUMBER  := 0;
		--
		vr_reg_coop   typ_reg_coop;
		--
	BEGIN
		--
		IF vr_tab_coop.count() > 0 THEN
			--
			WHILE vr_index_coop IS NOT NULL LOOP
				--
				IF vr_tab_coop(vr_index_coop).cdcooper = pr_cdcooper THEN
					--
					vr_achou := TRUE;
					--
					vr_tab_coop(vr_index_coop).vlcustas := nvl(vr_tab_coop(vr_index_coop).vlcustas, 0) + nvl(pr_vlcustas, 0);
					vr_tab_coop(vr_index_coop).vltarifa := nvl(vr_tab_coop(vr_index_coop).vltarifa, 0) + nvl(pr_vltarifa, 0);
					--
					IF pr_cdfedera = 'SP' THEN
						--
						vr_tab_coop(vr_index_coop).vlcustas_sp := nvl(vr_tab_coop(vr_index_coop).vlcustas_sp, 0) + nvl(pr_vlcustas, 0);
					  vr_tab_coop(vr_index_coop).vltarifa_sp := nvl(vr_tab_coop(vr_index_coop).vltarifa_sp, 0) + nvl(pr_vltarifa, 0);
						--
					ELSE
						--
						vr_tab_coop(vr_index_coop).vlcustas_outros := nvl(vr_tab_coop(vr_index_coop).vlcustas_outros, 0) + nvl(pr_vlcustas, 0);
					  vr_tab_coop(vr_index_coop).vltarifa_outros := nvl(vr_tab_coop(vr_index_coop).vltarifa_outros, 0) + nvl(pr_vltarifa, 0);
						--
					END IF;
					--
				END IF;
				-- Próximo registro
				vr_index_coop := vr_tab_coop.next(vr_index_coop);
				--
			END LOOP;
			--
		END IF;
		--
		IF NOT vr_achou THEN
			--
			vr_reg_coop.cdcooper := pr_cdcooper;
			vr_reg_coop.vlcustas := pr_vlcustas;
			vr_reg_coop.vltarifa := pr_vltarifa;
			--
			IF pr_cdfedera = 'SP' THEN
				--
				vr_reg_coop.vlcustas_sp := pr_vlcustas;
				vr_reg_coop.vltarifa_sp := pr_vltarifa;
				--
			ELSE
				--
				vr_reg_coop.vlcustas_outros := pr_vlcustas;
				vr_reg_coop.vltarifa_outros := pr_vltarifa;
				--
			END IF;
			--
			vr_tab_coop(vr_tab_coop.count()) := vr_reg_coop;
			--
		END IF;
		--
	EXCEPTION
		WHEN OTHERS THEN
      cecred.pc_internal_exception;
			pr_dscritic := 'Erro na pc_totaliza_cooperativa: ' || SQLERRM;
	END pc_totaliza_cooperativa;
	
	-- Atualiza os títulos
	PROCEDURE pc_atualiza_titulos(pr_idretorno IN  tbcobran_retorno_ieptb.idretorno%TYPE
		                           ,pr_tpregist  IN  VARCHAR2
															 ,pr_origem    IN  VARCHAR2
		                           ,pr_dscritic  OUT VARCHAR2
		                           ) IS
	  --
		vr_index_lancto NUMBER := 0;
		--
		vr_idlancto_tarifa VARCHAR2(100) := NULL;
		vr_idlancto_custas VARCHAR2(100) := NULL;
		--
	BEGIN
		--
		IF vr_tab_lancto.count() > 0 THEN
			--
			WHILE vr_index_lancto IS NOT NULL LOOP
				--
				IF pr_origem = vr_tab_lancto(vr_index_lancto).vr_origem THEN
					--
					IF pr_tpregist = vr_tab_lancto(vr_index_lancto).vr_tpregist THEN
						--
						IF pr_tpregist IN('vr_tot_outros_cra_tarifa', 'vr_tot_sp_cra_tarifa') THEN
							--
							vr_idlancto_tarifa := pr_idretorno;
							vr_idlancto_custas := NULL;
							--
						ELSIF pr_tpregist IN('vr_tot_outros_cra_custas', 'vr_tot_sp_cra_custas') THEN
							--
							vr_idlancto_custas := pr_idretorno;
							vr_idlancto_tarifa := NULL;
							--
						END IF;
						--
						IF pr_origem = 'CON' THEN
							--
							pc_atualiza_confirmacao(pr_cdcooper        => vr_tab_lancto(vr_index_lancto).vr_cdcooper -- IN
																		 ,pr_dtmvtolt        => vr_tab_lancto(vr_index_lancto).vr_dtmvtolt -- IN
																		 ,pr_cdcomarc        => vr_tab_lancto(vr_index_lancto).vr_cdcomarc -- IN
																		 ,pr_nrseqrem        => vr_tab_lancto(vr_index_lancto).vr_nrseqrem -- IN
																		 ,pr_nrseqarq        => vr_tab_lancto(vr_index_lancto).vr_nrseqarq -- IN
																		 ,pr_dtcustas_proc   => NULL                                       -- IN
																		 ,pr_idlancto_tarifa => vr_idlancto_tarifa                         -- IN
																		 ,pr_idlancto_custas => vr_idlancto_custas                         -- IN
																		 ,pr_dscritic        => pr_dscritic                                -- OUT
																		 );
							--
						ELSE
							--
							pc_atualiza_retorno(pr_cdcooper        => vr_tab_lancto(vr_index_lancto).vr_cdcooper  -- IN
																 ,pr_dtmvtolt        => vr_tab_lancto(vr_index_lancto).vr_dtmvtolt  -- IN
																 ,pr_cdcomarc        => vr_tab_lancto(vr_index_lancto).vr_cdcomarc  -- IN
																 ,pr_nrseqrem        => vr_tab_lancto(vr_index_lancto).vr_nrseqrem  -- IN
																 ,pr_nrseqarq        => vr_tab_lancto(vr_index_lancto).vr_nrseqarq  -- IN
																 ,pr_dtcustas_proc   => NULL                                        -- IN
																 ,pr_idretorno       => vr_tab_lancto(vr_index_lancto).vr_idretorno -- IN
																 ,pr_idlancto_tarifa => vr_idlancto_tarifa                          -- IN
																 ,pr_idlancto_custas => vr_idlancto_custas                          -- IN
																 ,pr_dscritic        => pr_dscritic                                 -- OUT
																 );
							--
						END IF;
						--
					END IF;
					--
				END IF;
				-- Próximo registro
				vr_index_lancto := vr_tab_lancto.next(vr_index_lancto);
				--
			END LOOP;
			--
		END IF;
		--
		COMMIT;
		--
	END pc_atualiza_titulos;
	
	-- Processa as TED geradas em memória e realiza o envio das mesmas
	PROCEDURE pc_envia_teds(pr_dscritic OUT VARCHAR2
		                     ) IS
		--
		vr_index_ted NUMBER  := 0;
		--
		vr_idlancto  tbfin_recursos_movimento.idlancto%TYPE;
		vr_nrdocmto  NUMBER;
		vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(4000);
		--
	BEGIN
		--
		IF vr_tab_ted.count() > 0 THEN
			--
			WHILE vr_index_ted IS NOT NULL LOOP
				--
				cobr0011.pc_enviar_ted_IEPTB(pr_cdcooper => vr_tab_ted(vr_index_ted).vr_cdcooper
				                            ,pr_cdagenci => vr_tab_ted(vr_index_ted).vr_cdagenci
																		,pr_nrdconta => vr_tab_ted(vr_index_ted).vr_nrdconta
																		,pr_tppessoa => vr_tab_ted(vr_index_ted).vr_tppessoa
																		,pr_origem   => vr_tab_ted(vr_index_ted).vr_origem
																		,pr_nrispbif => vr_tab_ted(vr_index_ted).vr_nrispbif
																		,pr_cdageban => vr_tab_ted(vr_index_ted).vr_cdageban
																		,pr_nrctatrf => vr_tab_ted(vr_index_ted).vr_nrctatrf
																		,pr_nmtitula => vr_tab_ted(vr_index_ted).vr_nmtitula
																		,pr_nrcpfcgc => vr_tab_ted(vr_index_ted).vr_nrcpfcgc
																		,pr_intipcta => vr_tab_ted(vr_index_ted).vr_intipcta
																		,pr_inpessoa => vr_tab_ted(vr_index_ted).vr_inpessoa
																		,pr_vllanmto => vr_tab_ted(vr_index_ted).vr_vllanmto
																		,pr_cdfinali => vr_tab_ted(vr_index_ted).vr_cdfinali
																		,pr_operador => vr_tab_ted(vr_index_ted).vr_operador
																		,pr_cdhistor => vr_tab_ted(vr_index_ted).vr_cdhistor
																		,pr_idlancto => vr_idlancto
																		,pr_nrdocmto => vr_nrdocmto
																		,pr_cdcritic => vr_cdcritic
																		,pr_dscritic => vr_dscritic
																		);
				-- Atualiza os títulos
				pc_atualiza_titulos(pr_idretorno => vr_idlancto                          -- IN
													 ,pr_tpregist  => vr_tab_ted(vr_index_ted).vr_tpregist -- IN
													 ,pr_origem    => vr_tab_ted(vr_index_ted).vr_tporigem -- IN
													 ,pr_dscritic  => vr_dscritic                          -- OUT
													 );
				-- Próximo registro
				vr_index_ted := vr_tab_ted.next(vr_index_ted);
				--
			END LOOP;
			--
		END IF;
		--
		pr_dscritic := vr_dscritic;
		--
	END pc_envia_teds;
	
  -- Processa os arquivos de confirmação e retorno
  PROCEDURE pc_processa_arquivos(pr_idtipprc IN  VARCHAR2
		                            ,pr_dscritic OUT VARCHAR2
                                ) IS
    -- Cursor boletos
    CURSOR cr_crapcob(pr_cdagectl IN crapcop.cdagectl%TYPE
                     ,pr_nrdconta IN crapcob.nrdconta%TYPE
                     ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                     ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                     ) IS
      SELECT crapcob.rowid
            ,crapcob.cdcooper
            ,crapcob.nrnosnum
            ,crapcob.nrdconta
            ,crapcob.nrcnvcob
            ,crapcob.nrdocmto
            ,crapcop.cdbcoctl
            ,crapcop.cdagectl
            ,crapcob.vlabatim
            ,crapcob.vldescto
            ,crapcob.vlrmulta
            ,crapcob.vloutdeb
            ,crapcob.vloutcre
            ,crapcob.vltitulo
            ,crapdat.dtmvtolt
						,crapcco.cdagenci
						,crapcco.cdbccxlt
						,crapcco.nrdolote
        FROM crapcob
            ,crapcop
            ,crapdat
						,crapcco
       WHERE crapcob.cdcooper = crapcop.cdcooper
         AND crapcob.cdcooper = crapdat.cdcooper
				 AND crapcob.cdcooper = crapcco.cdcooper
				 AND crapcob.nrcnvcob = crapcco.nrconven 
         AND crapcop.cdagectl = pr_cdagectl
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdocmto = pr_nrdocmto;
    --
    rw_crapcob cr_crapcob%ROWTYPE;
    -- Cursor ocorrências/motivos
    /*CURSOR cr_crapmot(pr_cdocorre crapmot.cdocorre%TYPE
                     ,pr_cdmotivo crapmot.cdmotivo%TYPE
                     ,pr_cdcooper crapmot.cdcooper%TYPE
                     ,pr_cddbanco crapmot.cddbanco%TYPE
                     ) IS
      SELECT crapoco.cdocorre
            ,crapoco.dsocorre
            ,crapmot.cdmotivo
            ,crapmot.dsmotivo
        FROM crapoco
            ,crapmot
       WHERE crapoco.cdcooper = crapmot.cdcooper
         AND crapoco.cddbanco = crapmot.cddbanco
         AND crapoco.cdocorre = crapmot.cdocorre
         AND crapoco.tpocorre = crapmot.tpocorre
         AND crapoco.tpocorre = 2 -- Fixo
         AND crapmot.cdocorre = pr_cdocorre
         AND crapmot.cdmotivo = lpad(TRIM(pr_cdmotivo), 2, '0')
         AND crapmot.cdcooper = pr_cdcooper
         AND crapmot.cddbanco = pr_cddbanco;
    --*/
    --rw_crapmot cr_crapmot%ROWTYPE;
    --
    CURSOR cr_crapret(pr_cdcooper crapret.cdcooper%TYPE
                     ,pr_nrcnvcob crapret.nrcnvcob%TYPE
                     ,pr_nrdconta crapret.nrdconta%TYPE
                     ,pr_nrdocmto crapret.nrdocmto%TYPE
                     ,pr_dtocorre crapret.dtocorre%TYPE
                     ,pr_cdocorre crapret.cdocorre%TYPE
                     ,pr_cdmotivo crapret.cdmotivo%TYPE
                     ) IS
      SELECT crapret.nrremret
            ,crapret.nrseqreg
        FROM crapret
       WHERE crapret.cdcooper = pr_cdcooper
         AND crapret.nrcnvcob = pr_nrcnvcob
         AND crapret.nrdconta = pr_nrdconta
         AND crapret.nrdocmto = pr_nrdocmto
         AND crapret.dtocorre = pr_dtocorre
         AND crapret.cdocorre = pr_cdocorre
         AND nvl(crapret.cdmotivo, 0) = nvl(pr_cdmotivo, 0);
    --
    rw_crapret cr_crapret%ROWTYPE;
    --
		CURSOR cr_conta(pr_nrdconta tbfin_recursos_conta.nrdconta%TYPE
		               ) IS
		  SELECT cdcooper
						,nrdconta
						,cdagenci
						,nmtitular
						,dscnpj_titular
						,tpconta
						,nmrecurso
						,dtabertura
				FROM tbfin_recursos_conta
			 WHERE nrdconta = pr_nrdconta
			   AND flgativo = 1;
		--
		rw_conta cr_conta%ROWTYPE;
		--
    vr_index_reg NUMBER;
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(4000);
		vr_des_erro  VARCHAR2(4000);
    --
    vr_nrretcoo  NUMBER;
    vr_vltitulo  NUMBER;
    vr_vlsaldot  NUMBER;
    vr_vloutcre  NUMBER;
    vr_vlcuscar  NUMBER;
    vr_vlcusdis  NUMBER;
    vr_vldemdes  NUMBER;
		vr_vlgraele  NUMBER;
    vr_cdocorre  NUMBER;
    vr_dsmotivo  VARCHAR2(2);
    --
    vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
    --vr_tab_descontar       PAGA0001.typ_tab_titulos;
    -- Totalizadores por cooperativa
		/*vr_vlcoop01 NUMBER := 0;
		vr_vlcoop02 NUMBER := 0;
		vr_vlcoop03 NUMBER := 0;
		vr_vlcoop05 NUMBER := 0;
		vr_vlcoop06 NUMBER := 0;
		vr_vlcoop07 NUMBER := 0;
		vr_vlcoop08 NUMBER := 0;
		vr_vlcoop09 NUMBER := 0;
		vr_vlcoop10 NUMBER := 0;
		vr_vlcoop11 NUMBER := 0;
		vr_vlcoop12 NUMBER := 0;
		vr_vlcoop13 NUMBER := 0;
		vr_vlcoop14 NUMBER := 0;
		vr_vlcoop16 NUMBER := 0;
		--
		vr_vlcoop01_2 NUMBER := 0;
		vr_vlcoop02_2 NUMBER := 0;
		vr_vlcoop03_2 NUMBER := 0;
		vr_vlcoop05_2 NUMBER := 0;
		vr_vlcoop06_2 NUMBER := 0;
		vr_vlcoop07_2 NUMBER := 0;
		vr_vlcoop08_2 NUMBER := 0;
		vr_vlcoop09_2 NUMBER := 0;
		vr_vlcoop10_2 NUMBER := 0;
		vr_vlcoop11_2 NUMBER := 0;
		vr_vlcoop12_2 NUMBER := 0;
		vr_vlcoop13_2 NUMBER := 0;
		vr_vlcoop14_2 NUMBER := 0;
		vr_vlcoop16_2 NUMBER := 0;*/
		--
		rw_craplot cobr0011.cr_craplot%ROWTYPE;
		--
		vr_nmarquiv VARCHAR2(12);
		vr_idtiparq VARCHAR2(3);
		--
		vr_index_coop  NUMBER;
		vr_total_ieptb NUMBER;
		--
		vr_tot_outros_cra_custas NUMBER;
		vr_tot_outros_cra_tarifa NUMBER;
		vr_tot_sp_cra_custas     NUMBER;
		vr_tot_sp_cra_tarifa     NUMBER;
		--
		vr_idlancto       tbfin_recursos_movimento.idlancto%TYPE;
		vr_nrdocmto       NUMBER;
		--
		vr_idretorno      NUMBER;
		--
  BEGIN
    --
		vr_tab_coop.delete;
		
    vr_index_reg := 0;
    --
		IF vr_tab_arquivo.count() > 0 THEN
			--
			WHILE vr_index_reg IS NOT NULL LOOP
				--
				vr_cdocorre := NULL;
				vr_dsmotivo := NULL;
				rw_crapret  := NULL;
				--
				vr_nmarquiv := vr_tab_arquivo(vr_index_reg).nmarquiv;
				-- Verifica se o tipo do registro é header
				IF vr_tab_arquivo(vr_index_reg).campot01 = '0' THEN
					--
					NULL;
				-- Verifica se o tipo do registro é transação
				ELSIF vr_tab_arquivo(vr_index_reg).campot01 = '1' THEN
					-- Busca o boleto referente ao registro no arquivo
					OPEN cr_crapcob(pr_cdagectl => to_number(regexp_replace(substr(vr_tab_arquivo(vr_index_reg).campot03, 0, 5),'[[:punct:]]','')) -- IN
												 ,pr_nrdconta => to_number(regexp_replace(substr(vr_tab_arquivo(vr_index_reg).campot03, 7, 9),'[[:punct:]]','')) -- IN
												 ,pr_nrcnvcob => to_number(regexp_replace(substr(vr_tab_arquivo(vr_index_reg).campot11, 0, 6),'[[:punct:]]','')) -- IN
												 ,pr_nrdocmto => to_number(regexp_replace(substr(vr_tab_arquivo(vr_index_reg).campot11, 7, 9),'[[:punct:]]','')) -- IN
												 );
					--
					FETCH cr_crapcob INTO rw_crapcob;
					--
					IF cr_crapcob%NOTFOUND THEN
						--
						CLOSE cr_crapcob;
						pr_dscritic := 'Boleto não encontrado!';
						RAISE vr_exc_erro;
						--
					END IF;
					--
					CLOSE cr_crapcob;
					-- Tratamento dos dados recebidos
					IF vr_tab_arquivo(vr_index_reg).campot34 = '00000000' THEN
						--
						vr_tab_arquivo(vr_index_reg).campot34 := NULL;
						--
					END IF;
					--
					IF vr_tab_arquivo(vr_index_reg).campot37 = '00000000' THEN
						--
						vr_tab_arquivo(vr_index_reg).campot37 := NULL;
						--
					END IF;
					-- Converte os valores em number
					vr_vlcuscar := to_number(substr(vr_tab_arquivo(vr_index_reg).campot35, 0, 8) || ',' ||  substr(vr_tab_arquivo(vr_index_reg).campot35, 9, 2));
					vr_vlcusdis := to_number(substr(vr_tab_arquivo(vr_index_reg).campot40, 0, 8) || ',' ||  substr(vr_tab_arquivo(vr_index_reg).campot40, 9, 2));
					vr_vldemdes := to_number(substr(vr_tab_arquivo(vr_index_reg).campot50, 0, 8) || ',' ||  substr(vr_tab_arquivo(vr_index_reg).campot50, 9, 2));
					vr_vlgraele := to_number(substr(vr_tab_arquivo(vr_index_reg).campot42, 0, 8) || ',' ||  substr(vr_tab_arquivo(vr_index_reg).campot42, 9, 2));
					vr_vlsaldot := to_number(substr(vr_tab_arquivo(vr_index_reg).campot18, 0, 12) || ',' ||  substr(vr_tab_arquivo(vr_index_reg).campot18, 13, 2));
					vr_vltitulo := to_number(substr(vr_tab_arquivo(vr_index_reg).campot17, 0, 12) || ',' ||  substr(vr_tab_arquivo(vr_index_reg).campot17, 13, 2));
					-- Verifica a ocorrência
					CASE
						-- 1: Pago (6)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '1' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							/*IF vr_vlsaldot > vr_vltitulo THEN
								--
								vr_vloutcre := vr_vlsaldot - vr_vltitulo;
								--
							ELSE
								--
								vr_vloutcre := 0;
								--
							END IF;
							-- Processar liquidacao
							paga0001.pc_processa_liquidacao(pr_idtabcob            => rw_crapcob.rowid                        -- Rowid da Cobranca
																						 ,pr_nrnosnum            => rw_crapcob.nrnosnum                     -- Nosso Numero
																						 ,pr_cdbanpag            => rw_crapcob.cdbcoctl                     -- Codigo banco pagamento
																						 ,pr_cdagepag            => rw_crapcob.cdagectl                     -- Codigo Agencia pagamento
																						 ,pr_vltitulo            => rw_crapcob.vltitulo                     -- Valor do titulo
																						 ,pr_vlliquid            => vr_vltitulo                             -- Valor liquidacao
																						 ,pr_vlrpagto            => vr_vlsaldot                             -- Valor pagamento
																						 ,pr_vlabatim            => 0                                       -- Valor abatimento
																						 ,pr_vldescto            => 0                                       -- Valor desconto
																						 ,pr_vlrjuros            => 0                                       -- Valor juros
																						 ,pr_vloutdeb            => 0                                       -- Valor saida debito
																						 ,pr_vloutcre            => vr_vloutcre                             -- Valor saida credito
																						 ,pr_dtocorre            => rw_crapcob.dtmvtolt                     -- Data Ocorrencia
																						 ,pr_dtcredit            => rw_crapcob.dtmvtolt                     -- Data Credito
																						 ,pr_cdocorre            => 6                                       -- Codigo Ocorrencia
																						 ,pr_dsmotivo            => '08'                                     -- Descricao Motivo
																						 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                     -- Data movimento
																						 ,pr_cdoperad            => '1'                                     -- Codigo Operador
																						 ,pr_indpagto            => 0                                       -- Indicador pagamento -- 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA
																						 ,pr_ret_nrremret        => vr_nrretcoo                             -- Numero remetente
																						 ,pr_cdcritic            => vr_cdcritic                             -- Codigo Critica
																						 ,pr_dscritic            => vr_dscritic                             -- Descricao Critica
																						 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada                  -- Tabela lancamentos consolidada
																						 ,pr_tab_descontar       => vr_tab_descontar                        -- Tabela de titulos
																						 );
							--
							IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
								-- Buscar a descricao
								vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic
																												,vr_dscritic
																												);
								-- Padronização de logs
								pc_gera_log(pr_cdcooper     => rw_crapcob.cdcooper
													 ,pr_dstiplog     => 'E'
													 ,pr_dscritic     =>  vr_dscritic
													 ,pr_tpocorrencia => 2 -- Erro Tratado
													 );
							END IF;
							--
							
							OPEN cr_crapret(pr_cdcooper => rw_crapcob.cdcooper
														 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
														 ,pr_nrdconta => rw_crapcob.nrdconta
														 ,pr_nrdocmto => rw_crapcob.nrdocmto
														 ,pr_dtocorre => rw_crapcob.dtmvtolt
														 ,pr_cdocorre => 6
														 ,pr_cdmotivo => '08'
														 );
							--
							FETCH cr_crapret INTO rw_crapret;
							--
							IF cr_crapret%NOTFOUND THEN
								--
								vr_dscritic := 'Não encontrado o registro na CRAPRET.';
								RAISE vr_exc_erro;
								--
							END IF;
							--
							CLOSE cr_crapret;
							--
							*/
              
              -- Validar formatação das datas
              BEGIN
                IF vr_tab_arquivo(vr_index_reg).campot34 IS NOT NULL THEN
                  vr_dtauxili := to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy');
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Data invalida - Coop: ' || rw_crapcob.cdcooper || 
                                 ' Conta: ' || rw_crapcob.nrdconta ||
                                 ' Conv cob: ' ||rw_crapcob.nrcnvcob ||
                                 ' Data campo 34: ' || vr_tab_arquivo(vr_index_reg).campot34 || ' - ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;

              BEGIN
                IF vr_tab_arquivo(vr_index_reg).campot37 IS NOT NULL THEN
                  vr_dtauxili := to_date(vr_tab_arquivo(vr_index_reg).campot37,'ddmmyyyy');
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Data invalida - Coop: ' || rw_crapcob.cdcooper || 
                                 ' Conta: ' || rw_crapcob.nrdconta ||
                                 ' Conv cob: ' ||rw_crapcob.nrcnvcob ||
                                 ' Data campo 37: ' || vr_tab_arquivo(vr_index_reg).campot37 || ' - ' || SQLERRM;
                  RAISE vr_exc_erro; 
              END;

							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL -- rw_crapret.nrremret                   -- IN
																	 ,pr_nrseqreg            => NULL -- rw_crapret.nrseqreg                   -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Título liquidado em cartório pendente de conciliação.'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
						-- 2: Protestado (9)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '2' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							vr_tab_lcm_consolidada.delete;
							-- Leitura do calendario da cooperativa
							OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcob.cdcooper);
							FETCH btch0001.cr_crapdat
							 INTO rw_crapdat;
							-- Se nao encontrar
							IF btch0001.cr_crapdat%NOTFOUND THEN
								-- Fechar o cursor pois efetuaremos raise
								CLOSE btch0001.cr_crapdat;
								-- Montar mensagem de critica
								vr_cdcritic := 1;
								RAISE vr_exc_erro;
							ELSE
								-- Apenas fechar o cursor
								CLOSE btch0001.cr_crapdat;
							END IF;
							-- Gerar registro de Retorno = 09 - Baixa
							cobr0011.pc_proc_baixa(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																		,pr_idtabcob            => rw_crapcob.rowid       -- IN
																		,pr_cdbanpag            => rw_crapcob.cdbcoctl    -- IN
																		,pr_cdagepag            => rw_crapcob.cdagectl    -- IN
																		,pr_dtocorre            => rw_crapcob.dtmvtolt    -- IN
																		,pr_cdocorre            => 9                      -- IN
																		,pr_dsmotivo            => '14'                   -- IN
																		,pr_crapdat             => rw_crapdat             -- IN
																		,pr_cdoperad            => '1'                    -- IN
																		,pr_vltarifa            => 0                      -- IN
																		,pr_ret_nrremret        => vr_nrretcoo            -- OUT
																		,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN OUT
																		,pr_cdcritic            => vr_cdcritic            -- OUT
																		,pr_dscritic            => vr_dscritic            -- OUT
																		);
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							IF vr_tab_lcm_consolidada.count() > 0 THEN
								--
								paga0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																										,pr_dtmvtolt            => rw_crapcob.dtmvtolt    -- IN
																										,pr_cdagenci            => rw_crapcob.cdagenci    -- IN
																										,pr_cdbccxlt            => rw_crapcob.cdbccxlt    -- IN
																										,pr_nrdolote            => rw_crapcob.nrdolote    -- IN
																										,pr_cdpesqbb            => rw_crapcob.nrcnvcob    -- IN
																										,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN
																										,pr_cdcritic            => vr_cdcritic            -- OUT
																										,pr_dscritic            => vr_dscritic            -- OUT
																										);
								--
								IF pr_dscritic IS NOT NULL THEN
									--
									RAISE vr_exc_erro;
									--
								END IF;
								--
							END IF;
							--
							OPEN cr_crapret(pr_cdcooper => rw_crapcob.cdcooper
														 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
														 ,pr_nrdconta => rw_crapcob.nrdconta
														 ,pr_nrdocmto => rw_crapcob.nrdocmto
														 ,pr_dtocorre => rw_crapcob.dtmvtolt
														 ,pr_cdocorre => 9
														 ,pr_cdmotivo => '14'
														 );
							--
							FETCH cr_crapret INTO rw_crapret;
							--
							IF cr_crapret%NOTFOUND THEN
								--
								vr_dscritic := 'Não encontrado o registro na CRAPRET.';
								RAISE vr_exc_erro;
								--
							END IF;
							--
							CLOSE cr_crapret;
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							-- Gerar registro de Retorno = 09 - Baixa
							/*
							PAGA0002.pc_proc_baixa( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
																		 ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                           
																		 ,pr_cdbanpag => pr_tab_regimp(vr_index_reg).cdbanpag -- Codigo banco cobran¿a
																		 ,pr_cdagepag => pr_tab_regimp(vr_index_reg).cdagepag -- Codigo Agencia cobranca
																		 ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data Ocorrencia
																		 ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
																		 ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
																		 ,pr_crapdat  => pr_crapdat                           -- Data movimento
																		 ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador    
																		 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Tabela lancamentos consolidada
																		 ,pr_ret_nrremret => vr_nrretcoo                      -- Numero remetente
																		 ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
																		 ,pr_dscritic => vr_dscritic);                        -- Descricao critica
							--
							IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
								-- Buscar a descricao
								vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic
																												,vr_dscritic
																												);
								-- Padronização de logs - Chamado 743443 - 02/10/2017
								pc_gera_log(pr_cdcooper   => pr_cdcooper,
														pr_dstiplog   => 'E',
														pr_dscritic   =>  vr_dscritic,
														pr_tpocorrencia => 2);  --Erro Tratado
							END IF;
							--*/
						-- 3: Retirado (24)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '3' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '09';
							vr_idtiparq := 'RET';
							--
							vr_tab_lcm_consolidada.delete;
							-- Leitura do calendario da cooperativa
							OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcob.cdcooper);
							FETCH btch0001.cr_crapdat
							 INTO rw_crapdat;
							-- Se nao encontrar
							IF btch0001.cr_crapdat%NOTFOUND THEN
								-- Fechar o cursor pois efetuaremos raise
								CLOSE btch0001.cr_crapdat;
								-- Montar mensagem de critica
								vr_cdcritic := 1;
								RAISE vr_exc_erro;
							ELSE
								-- Apenas fechar o cursor
								CLOSE btch0001.cr_crapdat;
							END IF;
							--
							cobr0011.pc_proc_retirada_cartorio(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																								,pr_idtabcob            => rw_crapcob.rowid       -- IN
																								,pr_dtocorre            => rw_crapcob.dtmvtolt    -- IN
																								,pr_vltarifa            => 0                      -- IN
																								,pr_cdhistor            => 2632                   -- IN
																								,pr_cdocorre            => 24                     -- IN
																								,pr_dsmotivo            => NULL                   -- IN
																								,pr_crapdat             => rw_crapdat             -- IN
																								,pr_cdoperad            => '1'                    -- IN
																								,pr_cdbanpag            => rw_crapcob.cdbcoctl    -- IN
																								,pr_cdagepag            => rw_crapcob.cdagectl    -- IN
																								,pr_ret_nrremret        => vr_nrretcoo            -- OUT
																								,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN OUT
																								,pr_cdcritic            => vr_cdcritic            -- OUT
																								,pr_dscritic            => vr_dscritic            -- OUT
																								);
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							IF vr_tab_lcm_consolidada.count() > 0 THEN
								--
								paga0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																										,pr_dtmvtolt            => rw_crapcob.dtmvtolt    -- IN
																										,pr_cdagenci            => rw_crapcob.cdagenci    -- IN
																										,pr_cdbccxlt            => rw_crapcob.cdbccxlt    -- IN
																										,pr_nrdolote            => rw_crapcob.nrdolote    -- IN
																										,pr_cdpesqbb            => rw_crapcob.nrcnvcob    -- IN
																										,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN
																										,pr_cdcritic            => vr_cdcritic            -- OUT
																										,pr_dscritic            => vr_dscritic            -- OUT
																										);
								--
								IF pr_dscritic IS NOT NULL THEN
									--
									RAISE vr_exc_erro;
									--
								END IF;
								--
							END IF;
							--
							OPEN cr_crapret(pr_cdcooper => rw_crapcob.cdcooper
														 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
														 ,pr_nrdconta => rw_crapcob.nrdconta
														 ,pr_nrdocmto => rw_crapcob.nrdocmto
														 ,pr_dtocorre => rw_crapcob.dtmvtolt
														 ,pr_cdocorre => 24
														 ,pr_cdmotivo => NULL
														 );
							--
							FETCH cr_crapret INTO rw_crapret;
							--
							IF cr_crapret%NOTFOUND THEN
								--
								vr_dscritic := 'Não encontrado o registro na CRAPRET.';
								RAISE vr_exc_erro;
								--
							END IF;
							--
							CLOSE cr_crapret;
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => rw_crapret.nrremret                   -- IN
																	 ,pr_nrseqreg            => rw_crapret.nrseqreg                   -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
						-- 4: Sustado (63)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '4' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Sustação Judicial (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
						-- 5: Devolvido pelo cartório por irregularidade - Sem custas (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '5' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'CON';
							-- Leitura do calendario da cooperativa
							OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcob.cdcooper);
							FETCH btch0001.cr_crapdat
							 INTO rw_crapdat;
							-- Se nao encontrar
							IF btch0001.cr_crapdat%NOTFOUND THEN
								-- Fechar o cursor pois efetuaremos raise
								CLOSE btch0001.cr_crapdat;
								-- Montar mensagem de critica
								vr_cdcritic := 1;
								RAISE vr_exc_erro;
							ELSE
								-- Apenas fechar o cursor
								CLOSE btch0001.cr_crapdat;
							END IF;
							--
							cobr0011.pc_proc_devolucao(pr_idtabcob 	   => rw_crapcob.rowid                      -- IN
																				,pr_cdbanpag     => rw_crapcob.cdbcoctl                   -- IN
																				,pr_cdagepag     => rw_crapcob.cdagectl                   -- IN
																				,pr_dtocorre     => rw_crapcob.dtmvtolt                   -- IN
																				,pr_cdocorre     => 89                                    -- IN
																				,pr_dsmotivo     => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																				,pr_crapdat      => rw_crapdat                            -- IN
																				,pr_cdoperad     => '1'                                   -- IN
																				,pr_vltarifa     => 0                                     -- IN
																				,pr_ret_nrremret => vr_nrretcoo                           -- OUT
																				,pr_cdcritic     => vr_cdcritic                           -- OUT
																				,pr_dscritic     => vr_dscritic                           -- OUT
																				);
							--
							IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							OPEN cr_crapret(pr_cdcooper => rw_crapcob.cdcooper
														 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
														 ,pr_nrdconta => rw_crapcob.nrdconta
														 ,pr_nrdocmto => rw_crapcob.nrdocmto
														 ,pr_dtocorre => rw_crapcob.dtmvtolt
														 ,pr_cdocorre => 89
														 ,pr_cdmotivo => vr_tab_arquivo(vr_index_reg).campot38
														 );
							--
							FETCH cr_crapret INTO rw_crapret;
							--
							IF cr_crapret%NOTFOUND THEN
								--
								vr_dscritic := 'Não encontrado o registro na CRAPRET.';
								RAISE vr_exc_erro;
								--
							END IF;
							--
							CLOSE cr_crapret;
							--
							pc_gera_confirmacao_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                                        -- IN
																			 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                                        -- IN
																			 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15                      -- IN
																			 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08                      -- IN
																			 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52                      -- IN
																			 ,pr_nrdconta            => rw_crapcob.nrdconta                                        -- IN
																			 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                                        -- IN
																			 ,pr_nrdocmto            => rw_crapcob.nrdocmto                                        -- IN
																			 ,pr_nrremret            => rw_crapret.nrremret                                        -- IN
																			 ,pr_nrseqreg            => rw_crapret.nrseqreg                                        -- IN
																			 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31                      -- IN
																			 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32                      -- IN
																			 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33                      -- IN
																			 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																			 ,pr_vlcuscar            => vr_vlcuscar                                                -- IN
																			 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																			 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38                      -- IN
																			 ,pr_vlcustas_cartorio   => vr_vlcusdis                                                -- IN
																			 ,pr_vlgrava_eletronica  => vr_vlgraele                                                -- IN
																			 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47                      -- IN
																			 ,pr_vldemais_despes     => vr_vldemdes                                                -- IN
																			 ,pr_vltitulo            => vr_vltitulo                                                -- IN
																			 ,pr_vlsaldo_titulo      => vr_vlsaldot                                                -- IN
																			 ,pr_dsregist            => vr_tab_arquivo(vr_index_reg).campot53                      -- IN
																			 ,pr_dscritic          	 => pr_dscritic                                                -- OUT
																			 );
							--
							IF vr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Devolvido pelo cartório por irregularidade - Sem custas (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
						-- 6: Devolvido pelo cartório por irregularidade - Com custas (28)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '6' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'CON';
							--
							-- Leitura do calendario da cooperativa
							OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcob.cdcooper);
							FETCH btch0001.cr_crapdat
							 INTO rw_crapdat;
							-- Se nao encontrar
							IF btch0001.cr_crapdat%NOTFOUND THEN
								-- Fechar o cursor pois efetuaremos raise
								CLOSE btch0001.cr_crapdat;
								-- Montar mensagem de critica
								vr_cdcritic := 1;
								RAISE vr_exc_erro;
							ELSE
								-- Apenas fechar o cursor
								CLOSE btch0001.cr_crapdat;
							END IF;
							--
							cobr0011.pc_proc_devolucao(pr_idtabcob 	   => rw_crapcob.rowid                      -- IN
																				,pr_cdbanpag     => rw_crapcob.cdbcoctl                   -- IN
																				,pr_cdagepag     => rw_crapcob.cdagectl                   -- IN
																				,pr_dtocorre     => rw_crapcob.dtmvtolt                   -- IN
																				,pr_cdocorre     => 89                                    -- IN
																				,pr_dsmotivo     => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																				,pr_crapdat      => rw_crapdat                            -- IN
																				,pr_cdoperad     => '1'                                   -- IN
																				,pr_vltarifa     => 0                                     -- IN
																				,pr_ret_nrremret => vr_nrretcoo                           -- OUT
																				,pr_cdcritic     => vr_cdcritic                           -- OUT
																				,pr_dscritic     => vr_dscritic                           -- OUT
																				);
							--
							IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							OPEN cr_crapret(pr_cdcooper => rw_crapcob.cdcooper
														 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
														 ,pr_nrdconta => rw_crapcob.nrdconta
														 ,pr_nrdocmto => rw_crapcob.nrdocmto
														 ,pr_dtocorre => rw_crapcob.dtmvtolt
														 ,pr_cdocorre => 89
														 ,pr_cdmotivo => vr_tab_arquivo(vr_index_reg).campot38
														 );
							--
							FETCH cr_crapret INTO rw_crapret;
							--
							IF cr_crapret%NOTFOUND THEN
								--
								vr_dscritic := 'Não encontrado o registro na CRAPRET.';
								RAISE vr_exc_erro;
								--
							END IF;
							--
							CLOSE cr_crapret;
							--
							pc_gera_confirmacao_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                                        -- IN
																			 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                                        -- IN
																			 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campot15                      -- IN
																			 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08                      -- IN
																			 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52                      -- IN
																			 ,pr_nrdconta            => rw_crapcob.nrdconta                                        -- IN
																			 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                                        -- IN
																			 ,pr_nrdocmto            => rw_crapcob.nrdocmto                                        -- IN
																			 ,pr_nrremret            => rw_crapret.nrremret                                        -- IN
																			 ,pr_nrseqreg            => rw_crapret.nrseqreg                                        -- IN
																			 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31                      -- IN
																			 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32                      -- IN
																			 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33                      -- IN
																			 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																			 ,pr_vlcuscar            => vr_vlcuscar                                                -- IN
																			 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																			 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38                      -- IN
																			 ,pr_vlcustas_cartorio   => vr_vlcusdis                                                -- IN
																			 ,pr_vlgrava_eletronica  => vr_vlgraele                                                -- IN
																			 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47                      -- IN
																			 ,pr_vldemais_despes     => vr_vldemdes                                                -- IN
																			 ,pr_vltitulo            => vr_vltitulo                                                -- IN
																			 ,pr_vlsaldo_titulo      => vr_vlsaldot                                                -- IN
																			 ,pr_dsregist            => vr_tab_arquivo(vr_index_reg).campot53                      -- IN
																			 ,pr_dscritic          	 => pr_dscritic                                                -- OUT
																			 );
							--
							IF vr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Devolvido pelo cartório por irregularidade - Com custas (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
						-- 7: Liquidação em condicional (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '7' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Liquidação em condicional (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							
						-- 8: Título aceito (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '8' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcuscar                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Título aceito (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- 9: Edital, apenas estados da Bahia e Rio de Janeiro (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = '9' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar 	                        -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Edital, apenas estados da Bahia e Rio de Janeiro (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- A: Protesto do banco cancelado (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'A' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Protesto do banco cancelado (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- B: Protesto já efetuado (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'B' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Protesto já efetuado (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- C: Protesto por edital (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'C' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele 	                        -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes 	                        -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Protesto por edital (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- D: Retirado por edital (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'D' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '09';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Retirado por edital (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- E: Protesto de terceiro cancelado (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'E' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Protesto de terceiro cancelado (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- F: Desistência do protesto por liquidação bancária (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'F' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Desistência do protesto por liquidação bancária (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- G: Sustado definitivo (63)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'G' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '09';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Sustado definitivo (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- I: Emissão da 2ª via do instrumento de protesto (Apenas log)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'I' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Emissão da 2ª via do instrumento de protesto (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- J: Cancelamento já efetuado anteriormente (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'J' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcusdis                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Cancelamento já efetuado anteriormente (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
						-- X: Cancelamento não efetuado (26)
						WHEN vr_tab_arquivo(vr_index_reg).campot33 = 'X' THEN
							-- Seta o motivo e ocorrência a serem utilizados no débito de custas e tarifas da conta do cooperado
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'RET';
							--
							pc_gera_retorno_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_nrdconta            => rw_crapcob.nrdconta                   -- IN
																	 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                   -- IN
																	 ,pr_nrdocmto            => rw_crapcob.nrdocmto                   -- IN
																	 ,pr_nrremret            => NULL                                  -- IN
																	 ,pr_nrseqreg            => NULL                                  -- IN
																	 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31 -- IN
																	 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32 -- IN
																	 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33 -- IN
																	 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																	 ,pr_vlcuscar            => vr_vlcuscar                           -- IN
																	 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																	 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38 -- IN
																	 ,pr_vlcustas_cartorio   => vr_vlcuscar                           -- IN
																	 ,pr_vlgrava_eletronica  => vr_vlgraele                           -- IN
																	 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47 -- IN
																	 ,pr_vldemais_despes     => vr_vldemdes                           -- IN
																	 ,pr_vltitulo            => vr_vltitulo                           -- IN
																	 ,pr_vlsaldo_titulo      => vr_vlsaldot                           -- IN
																	 ,pr_dsregist            => NULL                                  -- IN
																	 ,pr_idretorno           => vr_idretorno                          -- OUT
																	 ,pr_dscritic          	 => pr_dscritic                           -- OUT
																	 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Cancelamento não efetuado (IEPTB).'
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
	           
							--
							IF vr_des_erro <> 'OK' THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							
					ELSE
						--
						IF vr_tab_arquivo(vr_index_reg).campot32 IS NOT NULL THEN
							--
							vr_cdocorre := 28;
							vr_dsmotivo := '08';
							vr_idtiparq := 'CON';
							--
							pc_gera_confirmacao_ieptb(pr_cdcooper            => rw_crapcob.cdcooper                                        -- IN
																			 ,pr_dtmvtolt            => rw_crapcob.dtmvtolt                                        -- IN
																			 ,pr_cdcomarc            => vr_tab_arquivo(vr_index_reg).campoh15                      -- IN
																			 ,pr_nrseqrem            => vr_tab_arquivo(vr_index_reg).campoh08                      -- IN
																			 ,pr_nrseqarq            => vr_tab_arquivo(vr_index_reg).campot52                      -- IN
																			 ,pr_nrdconta            => rw_crapcob.nrdconta                                        -- IN
																			 ,pr_nrcnvcob            => rw_crapcob.nrcnvcob                                        -- IN
																			 ,pr_nrdocmto            => rw_crapcob.nrdocmto                                        -- IN
																			 ,pr_nrremret            => NULL                                                       -- IN
																			 ,pr_nrseqreg            => NULL                                                       -- IN
																			 ,pr_cdcartorio          => vr_tab_arquivo(vr_index_reg).campot31                      -- IN
																			 ,pr_nrprotoc_cartorio   => vr_tab_arquivo(vr_index_reg).campot32                      -- IN
																			 ,pr_tpocorre            => vr_tab_arquivo(vr_index_reg).campot33                      -- IN
																			 ,pr_dtprotocolo         => to_date(vr_tab_arquivo(vr_index_reg).campot34, 'ddmmyyyy') -- IN
																			 ,pr_vlcuscar            => vr_vlcuscar                                                -- IN
																			 ,pr_dtocorre            => to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- IN
																			 ,pr_cdirregu            => vr_tab_arquivo(vr_index_reg).campot38                      -- IN
																			 ,pr_vlcustas_cartorio   => vr_vlcusdis                                                -- IN
																			 ,pr_vlgrava_eletronica  => vr_vlgraele                                                -- IN
																			 ,pr_cdcomplem_irregular => vr_tab_arquivo(vr_index_reg).campot47                      -- IN
																			 ,pr_vldemais_despes     => vr_vldemdes                                                -- IN
																			 ,pr_vltitulo            => vr_vltitulo                                                -- IN
																			 ,pr_vlsaldo_titulo      => vr_vlsaldot                                                -- IN
																			 ,pr_dsregist            => vr_tab_arquivo(vr_index_reg).campot53                      -- IN
																			 ,pr_dscritic          	 => pr_dscritic                                                -- OUT
																			 );
							--
							IF pr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
							paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
																					 ,pr_cdoperad => '1'
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt
																					 ,pr_dsmensag => 'Título registrado em cartório nr: ' || vr_tab_arquivo(vr_index_reg).campot31
																					 ,pr_des_erro => vr_des_erro
																					 ,pr_dscritic => pr_dscritic
																					 );
							--
							-- Leitura do calendario da cooperativa
							OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcob.cdcooper);
							FETCH btch0001.cr_crapdat
							 INTO rw_crapdat;
							-- Se nao encontrar
							IF btch0001.cr_crapdat%NOTFOUND THEN
								-- Fechar o cursor pois efetuaremos raise
								CLOSE btch0001.cr_crapdat;
								-- Montar mensagem de critica
								vr_cdcritic := 1;
								RAISE vr_exc_erro;
							ELSE
								-- Apenas fechar o cursor
								CLOSE btch0001.cr_crapdat;
							END IF;
							--
							vr_tab_lcm_consolidada.delete;
							--
							cobr0011.pc_proc_remessa_cartorio(pr_cdcooper            => rw_crapcob.cdcooper                                        -- Codigo da cooperativa
																							 ,pr_cdbanpag            => rw_crapcob.cdbcoctl
																							 ,pr_cdagepag            => rw_crapcob.cdagectl
																							 ,pr_idtabcob            => rw_crapcob.rowid                                           -- Rowid da Cobranca                                               
																							 ,pr_dtocorre            => rw_crapcob.dtmvtolt -- to_date(vr_tab_arquivo(vr_index_reg).campot37, 'ddmmyyyy') -- Data de Ocorrencia
																							 ,pr_vltarifa            => 0                                                          -- Valor da tarifa -- REVISAR
																							 ,pr_cdhistor            => 972                                                        -- Codigo do historico -- REVISAR
																							 ,pr_cdocorre            => 23                                                         -- Codigo Ocorrencia -- REVISAR
																							 ,pr_dsmotivo            => '00'                                                       -- Descricao Motivo -- REVISAR
																							 ,pr_crapdat             => rw_crapdat                                                 -- Data movimento
																							 ,pr_cdoperad            => '1'                                                          -- Codigo Operador -- Revisar
																							 ,pr_ret_nrremret        => vr_nrretcoo                                                -- Numero Remessa Retorno Cooperado
																							 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada                                     -- Temptable dos lanamentos
																							 ,pr_cdcritic            => vr_cdcritic                                                -- Codigo da critica
																							 ,pr_dscritic            => vr_dscritic                                                -- Descricao critica
																							 );
							--
							IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
								-- Buscar a descricao
								vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic
																												,vr_dscritic
																												);
								-- Padronização de logs
								cobr0011.pc_gera_log(pr_cdcooper     => rw_crapcob.cdcooper
																		,pr_dstiplog     => 'E'
																		,pr_dscritic     =>  vr_dscritic
																		,pr_tpocorrencia => 2 -- Erro Tratado
																		);
							END IF;
							--
							IF vr_tab_lcm_consolidada.count() > 0 THEN
								--
								paga0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																										,pr_dtmvtolt            => rw_crapcob.dtmvtolt    -- IN
																										,pr_cdagenci            => rw_crapcob.cdagenci    -- IN
																										,pr_cdbccxlt            => rw_crapcob.cdbccxlt    -- IN
																										,pr_nrdolote            => rw_crapcob.nrdolote    -- IN
																										,pr_cdpesqbb            => rw_crapcob.nrcnvcob    -- IN
																										,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN
																										,pr_cdcritic            => vr_cdcritic            -- OUT
																										,pr_dscritic            => vr_dscritic            -- OUT
																										);
								--
								IF pr_dscritic IS NOT NULL THEN
									--
									RAISE vr_exc_erro;
									--
								END IF;
								--
							END IF;
							--
						END IF;
						--
					END CASE;
					--
					IF (vr_vlcuscar + vr_vlcusdis + vr_vldemdes + vr_vlgraele) > 0 THEN
						-- Somatório de Custas por CRA
						IF (vr_vlcuscar + vr_vlcusdis + vr_vldemdes) > 0 THEN
							--
							IF vr_tab_arquivo(vr_index_reg).campot30 = 'SP' THEN
								--
								vr_tot_sp_cra_custas := nvl(vr_tot_sp_cra_custas, 0) + (vr_vlcuscar + vr_vlcusdis + vr_vldemdes);
								--
								IF vr_idtiparq = 'CON' THEN
									--
									vr_reg_lancto.vr_tpregist := 'vr_tot_sp_cra_custas';
									vr_reg_lancto.vr_origem   := vr_idtiparq;
									vr_reg_lancto.vr_cdcooper := rw_crapcob.cdcooper;
									vr_reg_lancto.vr_dtmvtolt := rw_crapcob.dtmvtolt;
									vr_reg_lancto.vr_cdcomarc := vr_tab_arquivo(vr_index_reg).campoh15;
									vr_reg_lancto.vr_nrseqrem := vr_tab_arquivo(vr_index_reg).campoh08;
									vr_reg_lancto.vr_nrseqarq := vr_tab_arquivo(vr_index_reg).campot52;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
								ELSIF vr_idtiparq = 'RET' THEN
									--
									vr_reg_lancto.vr_tpregist  := 'vr_tot_sp_cra_custas';
									vr_reg_lancto.vr_origem    := vr_idtiparq;
									vr_reg_lancto.vr_idretorno := vr_idretorno;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
								END IF;
								--
							ELSE
								--
								vr_tot_outros_cra_custas := nvl(vr_tot_outros_cra_custas, 0) + (vr_vlcuscar + vr_vlcusdis + vr_vldemdes);
								--
								IF vr_idtiparq = 'CON' THEN
									--
									vr_reg_lancto.vr_tpregist := 'vr_tot_outros_cra_custas';
									vr_reg_lancto.vr_origem   := vr_idtiparq;
									vr_reg_lancto.vr_cdcooper := rw_crapcob.cdcooper;
									vr_reg_lancto.vr_dtmvtolt := rw_crapcob.dtmvtolt;
									vr_reg_lancto.vr_cdcomarc := vr_tab_arquivo(vr_index_reg).campoh15;
									vr_reg_lancto.vr_nrseqrem := vr_tab_arquivo(vr_index_reg).campoh08;
									vr_reg_lancto.vr_nrseqarq := vr_tab_arquivo(vr_index_reg).campot52;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
								ELSIF vr_idtiparq = 'RET' THEN
									--
									vr_reg_lancto.vr_tpregist  := 'vr_tot_outros_cra_custas';
									vr_reg_lancto.vr_origem    := vr_idtiparq;
									vr_reg_lancto.vr_idretorno := vr_idretorno;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
							END IF;
								--
							END IF;
							--
						END IF;
						-- Somatório de Tarifas por CRA
						IF (vr_vlgraele) > 0 THEN
							--
							IF vr_tab_arquivo(vr_index_reg).campot30 = 'SP' THEN
								--
								vr_tot_sp_cra_tarifa := nvl(vr_tot_sp_cra_tarifa, 0) + vr_vlgraele;
								--
								IF vr_idtiparq = 'CON' THEN
									--
									vr_reg_lancto.vr_tpregist := 'vr_tot_sp_cra_tarifa';
									vr_reg_lancto.vr_origem   := vr_idtiparq;
									vr_reg_lancto.vr_cdcooper := rw_crapcob.cdcooper;
									vr_reg_lancto.vr_dtmvtolt := rw_crapcob.dtmvtolt;
									vr_reg_lancto.vr_cdcomarc := vr_tab_arquivo(vr_index_reg).campoh15;
									vr_reg_lancto.vr_nrseqrem := vr_tab_arquivo(vr_index_reg).campoh08;
									vr_reg_lancto.vr_nrseqarq := vr_tab_arquivo(vr_index_reg).campot52;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
								ELSIF vr_idtiparq = 'RET' THEN
									--
									vr_reg_lancto.vr_tpregist  := 'vr_tot_sp_cra_tarifa';
									vr_reg_lancto.vr_origem    := vr_idtiparq;
									vr_reg_lancto.vr_idretorno := vr_idretorno;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
								END IF;
								--
							ELSE
								--
								vr_tot_outros_cra_tarifa := nvl(vr_tot_outros_cra_tarifa, 0) + vr_vlgraele;
								--
								IF vr_idtiparq = 'CON' THEN
									--
									vr_reg_lancto.vr_tpregist := 'vr_tot_outros_cra_tarifa';
									vr_reg_lancto.vr_origem   := vr_idtiparq;
									vr_reg_lancto.vr_cdcooper := rw_crapcob.cdcooper;
									vr_reg_lancto.vr_dtmvtolt := rw_crapcob.dtmvtolt;
									vr_reg_lancto.vr_cdcomarc := vr_tab_arquivo(vr_index_reg).campoh15;
									vr_reg_lancto.vr_nrseqrem := vr_tab_arquivo(vr_index_reg).campoh08;
									vr_reg_lancto.vr_nrseqarq := vr_tab_arquivo(vr_index_reg).campot52;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
								ELSIF vr_idtiparq = 'RET' THEN
									--
									vr_reg_lancto.vr_tpregist  := 'vr_tot_outros_cra_tarifa';
									vr_reg_lancto.vr_origem    := vr_idtiparq;
									vr_reg_lancto.vr_idretorno := vr_idretorno;
									--
									vr_tab_lancto(vr_tab_lancto.count()) := vr_reg_lancto;
									--
							END IF;
								--
							END IF;
							--
						END IF;
						--
					END IF;
					--
					IF (vr_vlcuscar + vr_vlcusdis + vr_vldemdes) > 0 THEN
						-- Leitura do calendario da cooperativa
						OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcob.cdcooper);
						FETCH btch0001.cr_crapdat
						 INTO rw_crapdat;
						-- Se nao encontrar
						IF btch0001.cr_crapdat%NOTFOUND THEN
							-- Fechar o cursor pois efetuaremos raise
							CLOSE btch0001.cr_crapdat;
							-- Montar mensagem de critica
							vr_cdcritic := 1;
							RAISE vr_exc_erro;
						ELSE
							-- Apenas fechar o cursor
							CLOSE btch0001.cr_crapdat;
						END IF;
						--
						vr_tab_lcm_consolidada.delete;
						--
						cobr0011.pc_proc_deb_tarifas_custas(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																							 ,pr_idtabcob            => rw_crapcob.rowid       -- IN
																							 ,pr_cdbanpag            => 0                      -- IN -- Fixo
																							 ,pr_cdagepag            => 0                      -- IN -- Fixo
																							 ,pr_vltarifa            => (vr_vlcuscar +
																																					 vr_vlcusdis +
																																					 vr_vldemdes)          -- IN
																							 ,pr_dtocorre            => rw_crapcob.dtmvtolt    -- IN
																							 ,pr_cdocorre            => vr_cdocorre            -- IN
																							 ,pr_dsmotivo            => vr_dsmotivo            -- IN
																							 ,pr_crapdat             => rw_crapdat             -- IN
																							 ,pr_cdoperad            => '1'                      -- IN -- Fixo
																							 ,pr_ret_nrremret        => vr_nrretcoo            -- OUT
																							 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN OUT
																							 ,pr_cdhistor            => 2632                   -- IN -- Fixo
																							 ,pr_cdcritic            => vr_cdcritic            -- OUT
																							 ,pr_dscritic            => vr_dscritic            -- OUT
																							 );
					--
					IF vr_cdcritic IS NOT NULL AND vr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					--
					IF vr_tab_lcm_consolidada.count() > 0 THEN
						--
						paga0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
																								,pr_dtmvtolt            => rw_crapcob.dtmvtolt    -- IN
																								,pr_cdagenci            => rw_crapcob.cdagenci    -- IN
																								,pr_cdbccxlt            => rw_crapcob.cdbccxlt    -- IN
																								,pr_nrdolote            => rw_crapcob.nrdolote    -- IN
																								,pr_cdpesqbb            => rw_crapcob.nrcnvcob    -- IN
																								,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN
																								,pr_cdcritic            => vr_cdcritic            -- OUT
																								,pr_dscritic            => vr_dscritic            -- OUT
																								);
						--
						IF pr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
					END IF;
					-- Atualiza a confirmação/retorno
					IF vr_idtiparq = 'CON' THEN
						--
						pc_atualiza_confirmacao(pr_cdcooper      => rw_crapcob.cdcooper                   -- IN
																	 ,pr_dtmvtolt      => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_cdcomarc      => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
																	 ,pr_nrseqrem      => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
																	 ,pr_nrseqarq      => vr_tab_arquivo(vr_index_reg).campot52 -- IN
																	 ,pr_dtcustas_proc => rw_crapcob.dtmvtolt                   -- IN
																	 ,pr_dscritic      => vr_dscritic                           -- OUT
																	 );
						--
						IF vr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
					ELSIF vr_idtiparq = 'RET' THEN
						--
						pc_atualiza_retorno(pr_cdcooper      => rw_crapcob.cdcooper                   -- IN
															 ,pr_dtmvtolt      => rw_crapcob.dtmvtolt                   -- IN
															 ,pr_cdcomarc      => vr_tab_arquivo(vr_index_reg).campoh15 -- IN
															 ,pr_nrseqrem      => vr_tab_arquivo(vr_index_reg).campoh08 -- IN
															 ,pr_nrseqarq      => vr_tab_arquivo(vr_index_reg).campot52 -- IN
															 ,pr_dtcustas_proc => rw_crapcob.dtmvtolt                   -- IN
															 ,pr_dscritic      => vr_dscritic                           -- OUT
															 );
						--
						IF vr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
					END IF;
					
          --
				END IF;
				--
				IF (vr_vlcuscar + vr_vlcusdis + vr_vldemdes + vr_vlgraele) > 0 THEN
					-- Totaliza por cooperativa
					pc_totaliza_cooperativa(pr_cdcooper => rw_crapcob.cdcooper                       -- IN
					                       ,pr_cdfedera => vr_tab_arquivo(vr_index_reg).campot30     -- IN
																 ,pr_vlcustas => (vr_vlcuscar + vr_vlcusdis + vr_vldemdes) -- IN
																 ,pr_vltarifa => vr_vlgraele                               -- IN
																 ,pr_dscritic => vr_dscritic                               -- OUT
																 );
          --
				END IF;
				-- Verifica se o tipo do registro e trailler
				ELSIF vr_tab_arquivo(vr_index_reg).campot01 = '9' THEN
					--
					NULL;
					--
				END IF;
				-- Próximo registro
				vr_index_reg := vr_tab_arquivo.next(vr_index_reg);
				--
			END LOOP;
			
			-- Gerar os lançamentos por cooperativa e na central
			vr_index_coop := 0;
			vr_total_ieptb := 0;
			--
			IF vr_tab_coop.COUNT() > 0 THEN
				--
				WHILE vr_index_coop IS NOT NULL LOOP
					-- Lançamentos SP
					IF nvl(vr_tab_coop(vr_index_coop).vlcustas_sp, 0) > 0 THEN
						-- Gera lançamento histórico 2635
						cobr0011.pc_processa_lancamento(pr_cdcooper => vr_tab_coop(vr_index_coop).cdcooper    -- IN
						                               ,pr_nrdconta => 20000006                               -- IN
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt                    -- IN
																					 ,pr_cdagenci => 1                                      -- IN
																					 ,pr_cdoperad => '1'                                    -- IN
																					 ,pr_cdhistor => 2635                                   -- IN
																					 ,pr_vllanmto => vr_tab_coop(vr_index_coop).vlcustas_sp -- IN
																					 ,pr_nmarqtxt => vr_nmarquiv                            -- IN
																					 ,pr_craplot  => rw_craplot                             -- OUT
																					 ,pr_dscritic => pr_dscritic                            -- OUT
																					 );
						--
						IF pr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
						vr_total_ieptb := nvl(vr_total_ieptb, 0) + nvl(vr_tab_coop(vr_index_coop).vlcustas_sp, 0);
						--
					END IF;
					--
					IF nvl(vr_tab_coop(vr_index_coop).vltarifa_sp, 0) > 0 THEN
						-- Gera lançamento históico 2643
						cobr0011.pc_processa_lancamento(pr_cdcooper => vr_tab_coop(vr_index_coop).cdcooper    -- IN
						                               ,pr_nrdconta => 20000006                               -- IN
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt                    -- IN
																					 ,pr_cdagenci => 1                                      -- IN
																					 ,pr_cdoperad => '1'                                    -- IN
																					 ,pr_cdhistor => 2643                                   -- IN
																					 ,pr_vllanmto => vr_tab_coop(vr_index_coop).vltarifa_sp -- IN
																					 ,pr_nmarqtxt => vr_nmarquiv                            -- IN
																					 ,pr_craplot  => rw_craplot                             -- OUT
																					 ,pr_dscritic => pr_dscritic                            -- OUT
																					 );
						--
						IF pr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
						vr_total_ieptb := nvl(vr_total_ieptb, 0) + nvl(vr_tab_coop(vr_index_coop).vltarifa_sp, 0);
						--
					END IF;
					-- Lançamentos outros estados
					IF nvl(vr_tab_coop(vr_index_coop).vlcustas_outros, 0) > 0 THEN
						-- Gera lançamento histórico 2635
						cobr0011.pc_processa_lancamento(pr_cdcooper => vr_tab_coop(vr_index_coop).cdcooper        -- IN
						                               ,pr_nrdconta => 10000003                                   -- IN
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt                        -- IN
																					 ,pr_cdagenci => 1                                          -- IN
																					 ,pr_cdoperad => '1'                                        -- IN
																					 ,pr_cdhistor => 2635                                       -- IN
																					 ,pr_vllanmto => vr_tab_coop(vr_index_coop).vlcustas_outros -- IN
																					 ,pr_nmarqtxt => vr_nmarquiv                                -- IN
																					 ,pr_craplot  => rw_craplot                                 -- OUT
																					 ,pr_dscritic => pr_dscritic                                -- OUT
																					 );
						--
						IF pr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
						vr_total_ieptb := nvl(vr_total_ieptb, 0) + nvl(vr_tab_coop(vr_index_coop).vlcustas_outros, 0);
						--
					END IF;
					--
					IF nvl(vr_tab_coop(vr_index_coop).vltarifa_outros, 0) > 0 THEN
						-- Gera lançamento históico 2643
						cobr0011.pc_processa_lancamento(pr_cdcooper => vr_tab_coop(vr_index_coop).cdcooper        -- IN
						                               ,pr_nrdconta => 10000003                                   -- IN
																					 ,pr_dtmvtolt => rw_crapcob.dtmvtolt                        -- IN
																					 ,pr_cdagenci => 1                                          -- IN
																					 ,pr_cdoperad => '1'                                        -- IN
																					 ,pr_cdhistor => 2643                                       -- IN
																					 ,pr_vllanmto => vr_tab_coop(vr_index_coop).vltarifa_outros -- IN
																					 ,pr_nmarqtxt => vr_nmarquiv                                -- IN
																					 ,pr_craplot  => rw_craplot                                 -- OUT
																					 ,pr_dscritic => pr_dscritic                                -- OUT
																					 );
						--
						IF pr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
						vr_total_ieptb := nvl(vr_total_ieptb, 0) + nvl(vr_tab_coop(vr_index_coop).vltarifa_outros, 0);
						--
					END IF;
					-- Próximo registro
					vr_index_coop := vr_tab_coop.next(vr_index_coop);
					--
				END LOOP;
				-- Envia a TED para o CRA SP com o total das custas cobradas
			  IF nvl(vr_tot_sp_cra_custas, 0) > 0 THEN
					--
					OPEN cr_conta(20000006
		                   );
					--
					FETCH cr_conta INTO rw_conta;
					--
					IF cr_conta%NOTFOUND THEN
						--
						pr_dscritic := 'Conta nao cadastrada para o CRA SP!';
						RAISE vr_exc_erro;
						--
					ELSE
						--
						vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
						vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
						vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
						vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
						vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
						vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
						vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
						vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
						vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
						vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
						vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
						vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
						vr_reg_ted.vr_vllanmto := vr_tot_sp_cra_custas;
						vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
						vr_reg_ted.vr_operador := 1;                                                       -- Fixo
						vr_reg_ted.vr_cdhistor := 2642;                                                    -- Fixo
						vr_reg_ted.vr_tpregist := 'vr_tot_sp_cra_custas';                                  -- Fixo
						vr_reg_ted.vr_tporigem := vr_idtiparq;                                             
						--
						vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
						--
					END IF;
					--
					CLOSE cr_conta;
					--
				END IF;
				--
				rw_conta := NULL;
				-- Envia a TED para o Outros CRAs com o total das custas cobradas
				IF nvl(vr_tot_outros_cra_custas, 0) > 0 THEN
					--
					OPEN cr_conta(10000003
		                   );
					--
					FETCH cr_conta INTO rw_conta;
					--
					IF cr_conta%NOTFOUND THEN
						--
						pr_dscritic := 'Conta nao cadastrada para o CRA Nacional!';
						RAISE vr_exc_erro;
						--
					ELSE
						--
						vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
						vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
						vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
						vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
						vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
						vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
						vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
						vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
						vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
						vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
						vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
						vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
						vr_reg_ted.vr_vllanmto := vr_tot_outros_cra_custas;
						vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
						vr_reg_ted.vr_operador := 1;                                                       -- Fixo
						vr_reg_ted.vr_cdhistor := 2642;                                                    -- Fixo
						vr_reg_ted.vr_tpregist := 'vr_tot_outros_cra_custas';                              -- Fixo
						vr_reg_ted.vr_tporigem := vr_idtiparq;                                             
						--
						vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
						--
					END IF;
					--
					CLOSE cr_conta;
					--
				END IF;
				--
				rw_conta := NULL;
				-- Envia a TED para o CRA SP com o total das tarifas cobradas
			  IF nvl(vr_tot_sp_cra_tarifa, 0) > 0 THEN
					--
					OPEN cr_conta(20000006
		                   );
					--
					FETCH cr_conta INTO rw_conta;
					--
					IF cr_conta%NOTFOUND THEN
						--
						pr_dscritic := 'Conta nao cadastrada para o CRA SP!';
						RAISE vr_exc_erro;
						--
					ELSE
						--
						vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
						vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
						vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
						vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
						vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
						vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
						vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
						vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
						vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
						vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
						vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
						vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
						vr_reg_ted.vr_vllanmto := vr_tot_sp_cra_tarifa;
						vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
						vr_reg_ted.vr_operador := 1;                                                       -- Fixo
						vr_reg_ted.vr_cdhistor := 2646;                                                    -- Fixo
						vr_reg_ted.vr_tpregist := 'vr_tot_sp_cra_tarifa';                                  -- Fixo
						vr_reg_ted.vr_tporigem := vr_idtiparq;                                             
						--
						vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
						--
					END IF;
					--
					CLOSE cr_conta;
					--
				END IF;
				--
				rw_conta := NULL;
				-- Envia a TED para o Outros CRAs com o total das tarifas cobradas
				IF nvl(vr_tot_outros_cra_tarifa, 0) > 0 THEN
					--
					OPEN cr_conta(10000003
		                   );
					--
					FETCH cr_conta INTO rw_conta;
					--
					IF cr_conta%NOTFOUND THEN
						--
						pr_dscritic := 'Conta nao cadastrada para o CRA Nacional!';
						RAISE vr_exc_erro;
						--
					ELSE
						--
						vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
						vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
						vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
						vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
						vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
						vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
						vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
						vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
						vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
						vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
						vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
						vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
						vr_reg_ted.vr_vllanmto := vr_tot_outros_cra_tarifa;
						vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
						vr_reg_ted.vr_operador := 1;                                                       -- Fixo
						vr_reg_ted.vr_cdhistor := 2646;                                                    -- Fixo
						vr_reg_ted.vr_tpregist := 'vr_tot_outros_cra_tarifa';                              -- Fixo
						vr_reg_ted.vr_tporigem := vr_idtiparq;                                             
						--
						vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
						--
					END IF;
					--
					CLOSE cr_conta;
					--
				END IF;
				--
			END IF;
			--
		END IF;
    --
		vr_tab_arquivo.delete;
		--
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := nvl(pr_dscritic, vr_dscritic);
      
      cecred.pc_log_programa(PR_DSTIPLOG      => 'O', 
                             PR_CDPROGRAMA    => vr_cdprogra, 
                             pr_tpexecucao    => 2,           --job
                             pr_tpocorrencia  => 2,           --erro
                             pr_cdcriticidade => 0,           --baixa
                             pr_dsmensagem    => pr_dscritic,
                             PR_IDPRGLOG      => vr_idprglog);
      
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic := 'Erro ao processar os arquivos de confirmação/retorno: ' || SQLERRM;
  END pc_processa_arquivos;
	
	-- Rotina para mover os arquivos processados
	PROCEDURE pc_move_arquivos(pr_cdcooper IN  crapcop.cdcooper%TYPE
		                        ,pr_dscritic OUT VARCHAR2
		                        ) IS
		--
		vr_tab_arquivo TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_dsdireto    VARCHAR2(500);--         := '/micros/cecred/ieptb/retorno/';
		vr_drsalvar    VARCHAR2(500);
		vr_pesq        VARCHAR2(500);
		--
		vr_exc_erro    EXCEPTION;
		--
	BEGIN
		--
		vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																						,pr_cdcooper => pr_cdcooper
																						,pr_cdacesso => 'DIR_IEPTB_RETORNO'
																						);
    --
		vr_drsalvar := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/salvar'
																				);
		-- Buscar arquivos de confirmação
    vr_pesq := 'C%%%%%%%.%%%';
    -- Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_arquivo
                              ,pr_path          => vr_dsdireto
                              ,pr_pesq          => vr_pesq
                              );
    --
    IF vr_tab_arquivo.COUNT() > 0 THEN
      --
      FOR idx IN 1..vr_tab_arquivo.COUNT() LOOP
        -- Move o arquivo
        wprt0001.pc_atualiza_arquivo(pr_arquivo   => vr_dsdireto || '/' || vr_tab_arquivo(idx)
																		,pr_nvarquivo => vr_drsalvar || '/' || vr_tab_arquivo(idx)
																		,pr_dscritic  => pr_dscritic
																		);
        -- Se retornou erro
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
		-- Buscar arquivos de retorno
    vr_pesq := 'R%%%%%%%.%%%';
    -- Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_arquivo
                              ,pr_path          => vr_dsdireto
                              ,pr_pesq          => vr_pesq
                              );
    --
    IF vr_tab_arquivo.COUNT() > 0 THEN
      --
      FOR idx IN 1..vr_tab_arquivo.COUNT() LOOP
        -- Move o arquivo
        wprt0001.pc_atualiza_arquivo(pr_arquivo   => vr_dsdireto || '/' || vr_tab_arquivo(idx)
																	  ,pr_nvarquivo => vr_drsalvar || '/' || vr_tab_arquivo(idx)
																	  ,pr_dscritic  => pr_dscritic
																	  );
        -- Se retornou erro
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			NULL;
		WHEN OTHERS THEN
      cecred.pc_internal_exception;
			pr_dscritic := 'Erro ao mover os arquivos: ' || SQLERRM;
	END pc_move_arquivos;
	--
BEGIN

  GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => vr_cdprogra);

  -- Incluido controle de Log inicio programa
  pc_controla_log_batch(1, 'Início crps730');
  --
	BEGIN
		--
		SELECT crapdat.dtmvtolt
		  INTO vr_dtmvtolt
		  FROM crapdat
		 WHERE crapdat.cdcooper = 3;
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao buscar a data de movimento ' || SQLERRM;
			RAISE vr_exc_erro;
	END;
	--
  
	wprt0001.pc_obtem_retorno(pr_cdcooper => 3
							 ,pr_cdbandoc => 85
							 ,pr_dtmvtolt => vr_dtmvtolt
							 ,pr_dscritic => pr_dscritic
							 );
	--
	IF pr_dscritic IS NOT NULL THEN
    --
    RAISE vr_exc_erro;
    --
  END IF;
  
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_carrega_arquivo_confirmacao');
  
	--
  pc_carrega_arquivo_confirmacao(pr_cdcooper => 3           -- IN
	                              ,pr_dscritic => pr_dscritic -- OUT
                                );
  --
  IF pr_dscritic IS NOT NULL THEN
    --
    RAISE vr_exc_erro;
    --
  END IF;
	--

  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_processa_arquivos');  
	pc_processa_arquivos(pr_idtipprc => 'C'         -- IN -- Processamento do arquivo de Confirmação
	                    ,pr_dscritic => pr_dscritic -- OUT
                      );
  --
  IF pr_dscritic IS NOT NULL THEN
    --
    RAISE vr_exc_erro;
    --
  END IF;
  
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_carrega_arquivo_retorno');
  --
  pc_carrega_arquivo_retorno(pr_cdcooper => 3           -- IN
	                          ,pr_dscritic => pr_dscritic -- OUT
                            );
  --
  IF pr_dscritic IS NOT NULL THEN
    --
    RAISE vr_exc_erro;
    --
  END IF;
  
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_processa_arquivos');
  --
  pc_processa_arquivos(pr_idtipprc => 'R'         -- IN -- Processamento do arquivo de Retorno
	                    ,pr_dscritic => pr_dscritic -- OUT
                      );
  --
  IF pr_dscritic IS NOT NULL THEN
    --
    RAISE vr_exc_erro;
    --
  END IF;
	
	-- Executa a conciliação automática
	tela_manprt.pc_gera_conciliacao_auto(pr_cdprograma => vr_cdprogra,
                                       pr_dscritic   => pr_dscritic);
	--
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_gera_movimento_pagamento');
	-- Gera as movimentações
	cobr0011.pc_gera_movimento_pagamento(pr_dscritic => pr_dscritic);
	--
  IF pr_dscritic IS NOT NULL THEN
    --
    RAISE vr_exc_erro;
    --
  END IF;
  
  -- Escrever o log no arquivo
  pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps730 --> Finalizado o processamento dos retornos.'); -- Texto para escrita
  --
--	COMMIT;

  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_envia_teds');
  -- Faz o envio das TEDs
	pc_envia_teds(pr_dscritic => pr_dscritic);
  
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_move_arquivos');
	-- Move os arquivos processados
	pc_move_arquivos(pr_cdcooper => 3           -- IN
									,pr_dscritic => pr_dscritic -- OUT
									);
                  
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
EXCEPTION
  WHEN vr_exc_erro THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps730 --> ' || pr_dscritic);
		ROLLBACK;
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps730 --> ' || SQLERRM);
		ROLLBACK;
  --
end pc_crps730;
/
