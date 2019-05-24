CREATE OR REPLACE PACKAGE CECRED.TELA_BLQRGT IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CONPRO
  --  Sistema  : Rotinas utilizadas pela Tela COMPRO
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONPRO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_bloq_apli_cobe(pr_cddopcao IN VARCHAR2
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_desbloq_cobertura(pr_idcobertura IN NUMBER
                                ,pr_vldesblo    IN NUMBER
                                ,pr_cdopelib    IN VARCHAR2 --> Codigo do operador que liberou o desbloqueio
                                ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2); --> Erros do processo
END TELA_BLQRGT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_BLQRGT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LDESCO
  --  Sistema  : Rotinas utilizadas pela Tela BLQRGT
  --  Sigla    : EMPR
  --  Autor    : Lombardi
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela LDESCO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_bloq_apli_cobe(pr_cddopcao IN VARCHAR2
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_busca_bloq_apli_cobe
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Novembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os bloqueios antigos (CRAPTAB) e os novos criados
                    para a cobertura das operações de crédito.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_des_reto VARCHAR2(3) := '';
      vr_tab_erro GENE0001.typ_tab_erro;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
      CURSOR cr_craprpp(pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 'APLI.PROG' dstipapl
              ,rpp.nrctrrpp
              ,rpp.vlsdrdpp
          FROM craprpp rpp
              ,craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.cdacesso) = to_char(pr_nrdconta,'fm0000000000')
           AND upper(tab.nmsistem) = 'CRED'
           AND upper(tab.tptabela) = 'BLQRGT'
           AND tab.cdempres = 0
           AND to_number(SUBSTR(tab.dstextab,1,7)) = rpp.nrctrrpp
           AND rpp.cdcooper = pr_cdcooper
           AND rpp.nrdconta = pr_nrdconta;
           
      CURSOR cr_cobertura(pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ope.idcobertura
              ,ope.nrdconta
              ,ope.tpcontrato
              ,ope.nrcontrato
              ,ope.perminimo
			  ,ope.inaplicacao_propria
			  ,ope.inaplicacao_terceiro
			  ,ope.inpoupanca_propria
			  ,ope.inpoupanca_terceiro
          FROM tbgar_cobertura_operacao ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.insituacao = 1 /* Bloqueadas */
           AND ((ope.inaplicacao_propria + ope.inpoupanca_propria > 0 AND ope.nrdconta = pr_nrdconta)
            OR  (ope.inaplicacao_terceiro + ope.inpoupanca_terceiro > 0 AND ope.nrconta_terceiro = pr_nrdconta));
      
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.vlsdeved
            FROM crapepr epr
           WHERE epr.cdcooper = pr_cdcooper
             AND epr.nrdconta = pr_nrdconta
             AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrctrlim
           AND lim.tpctrlim = pr_tpctrlim;
      rw_craplim cr_craplim%ROWTYPE;
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variaveis locais
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;
      vr_tab_dados_rpp  APLI0001.typ_tab_dados_rpp;
      
      -- Variaveis auxiliares
      vr_valopera   NUMBER       := 0;
      vr_vlroriginal         NUMBER       := 0;
      vr_valbloque  NUMBER       := 0;
      vr_nrcpfcnpj_cobertura NUMBER       := 0;
      vr_tpcontrato VARCHAR2(10) := '';
      vr_dstextab            craptab.dstextab%TYPE;
      vr_inusatab            BOOLEAN;
      vr_valopera_atualizada NUMBER := 0;
      vr_vltotpre            NUMBER(25,2) := 0;
      vr_qtprecal            NUMBER(10) := 0;
      vr_dstipapl            VARCHAR2(50);
      vr_percenir            NUMBER       := 0;
      vr_vlsaldo_poup        NUMBER       := 0;     
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'TELA_BLQRGT' 
                                ,pr_action => null);  
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><bloq_apli></bloq_apli><bloq_cobert></bloq_cobert></Root>');
      
      FOR rw_craprpp IN cr_craprpp(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP
                                  
         -- Carregar tabela de memoria de contas bloqueadas
         TABE0001.pc_carrega_ctablq(pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_tab_cta_bloq => vr_tab_conta_bloq);
      
         -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
         vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                                              ,pr_nmsistem => 'CRED'
                                                                              ,pr_tptabela => 'CONFIG'
                                                                              ,pr_cdempres => 0
                                                                              ,pr_cdacesso => 'PERCIRAPLI'
                                                                              ,pr_tpregist => 0));
      
         -- Buscar informações e Saldos das Poupanças Programadas:
         apli0001.pc_consulta_poupanca(pr_cdcooper => vr_cdcooper --> Cooperativa
                                      ,pr_cdagenci => 1 --> Codigo da Agencia
                                      ,pr_nrdcaixa => 1 --> Numero do caixa
                                      ,pr_cdoperad => 1 --> Codigo do Operador
                                      ,pr_idorigem => 5 --> Identificador da Origem
                                      ,pr_nrdconta => pr_nrdconta --> Nro da conta associado
                                      ,pr_idseqttl => 1 --> Identificador Sequencial
                                      ,pr_nrctrrpp => 0 --> Contrato Poupanca Programada
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Data do proximo movimento
                                      ,pr_inproces => rw_crapdat.inproces --> Indicador de processo
                                      ,pr_cdprogra => 'BLQRGT' --> Nome do programa chamador
                                      ,pr_flgerlog => FALSE --> Flag erro log
                                      ,pr_percenir => vr_percenir --> % IR para Calculo Poupanca
                                      ,pr_tab_craptab => vr_tab_conta_bloq --> Tipo de tabela de Conta Bloqu
                                      ,pr_tab_craplpp => vr_tab_craplpp --> Tipo de tabela com lcto poup
                                      ,pr_tab_craplrg => vr_tab_craplrg --> Tipo de tabela com resgates
                                      ,pr_tab_resgate => vr_tab_resgate --> Tabela com valores dos resgates
                                      ,pr_vlsldrpp => vr_vlsaldo_poup --> Valor saldo poup progr
                                      ,pr_retorno => vr_des_reto --> Descricao erro/sucesso OK/NOK
                                      ,pr_tab_dados_rpp => vr_tab_dados_rpp --> Poupancas Programadas
                                      ,pr_tab_erro => vr_tab_erro); --> Saida com erros;                                   
      
        -- Registros
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/bloq_apli'
                                            ,XMLTYPE('<bloq>'
                                                   ||'  <dstipapl>'||rw_craprpp.dstipapl||'</dstipapl>'
                                                   ||'  <nrctrrpp>'||rw_craprpp.nrctrrpp||'</nrctrrpp>'
                                                   ||'  <vlsdrdpp>'||nvl(vr_vlsaldo_poup,0)||'</vlsdrdpp>'
                                                   ||'  <tpaplica>1</tpaplica>'
                                                   ||'  <idtipapl>A</idtipapl>'
                                                   ||'  <nmprodut> </nmprodut>'
                                                   ||'</bloq>'));
      END LOOP;
      
      -- Buscar configurações necessárias para busca de saldo de empréstimo
      -- Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posição do campo dstextab for diferente de zero
      vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';
      
      FOR rw_cobertura IN cr_cobertura(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta) LOOP
        IF rw_cobertura.tpcontrato = 90 THEN
					-- Zerar valor do saldo devedor para próxima proposta
          vr_valopera_atualizada := 0;
          -- Buscar o saldo devedor atualizado do contrato
          EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => vr_cdcooper             --> Cooperativa conectada
                                        ,pr_cdagenci => 1                       --> Codigo da agencia
                                        ,pr_nrdcaixa => 0                       --> Numero do caixa
                                        ,pr_cdoperad => '1'                     --> Codigo do operador
                                        ,pr_nmdatela => 'ATENDA'                --> Nome datela conectada
                                        ,pr_idorigem => 1 /*Ayllos*/            --> Indicador da origem da chamada
                                        ,pr_nrdconta => rw_cobertura.nrdconta             --> Conta do associado
                                        ,pr_idseqttl => 1                       --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat            --> Vetor com dados de parametro (CRAPDAT)
                                        ,pr_nrctremp => rw_cobertura.nrcontrato --> Numero contrato emprestimo
                                        ,pr_cdprogra => 'B1WGEN0001'            --> Programa conectado
                                        ,pr_inusatab => vr_inusatab             --> Indicador de utilizacão da tabela
                                        ,pr_flgerlog => 'N'                     --> Gerar log S/N
                                        ,pr_vlsdeved => vr_valopera_atualizada  --> Saldo devedor calculado
                                        ,pr_vltotpre => vr_vltotpre             --> Valor total das prestacães
                                        ,pr_qtprecal => vr_qtprecal             --> Parcelas calculadas
                                        ,pr_des_reto => vr_des_reto             --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);           --> Tabela com possives erros
          -- Se houve retorno de erro
          IF vr_des_reto = 'NOK' THEN
            -- Extrair o codigo e critica de erro da tabela de erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            -- Limpar tabela de erros
            vr_tab_erro.DELETE;
            RAISE vr_exc_saida;
          END IF;
          
          vr_valopera := vr_valopera_atualizada;
          
        ELSE
          -- Buscar limite
          OPEN cr_craplim(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => rw_cobertura.nrdconta
                         ,pr_nrctrlim => rw_cobertura.nrcontrato
                         ,pr_tpctrlim => rw_cobertura.tpcontrato);
          FETCH cr_craplim INTO rw_craplim;
          CLOSE cr_craplim;
          vr_valopera := rw_craplim.vllimite;
        END IF;
        
        -- Calcular o valor a bloquear
        BLOQ0001.pc_bloqueio_garantia_atualizad(pr_idcobert =>            rw_cobertura.idcobertura
                                               ,pr_vlroriginal =>         vr_vlroriginal
                                               ,pr_vlratualizado =>       vr_valbloque
                                               ,pr_nrcpfcnpj_cobertura => vr_nrcpfcnpj_cobertura
                                               ,pr_dscritic =>            vr_dscritic);
        
        IF vr_valbloque > 0 THEN
          
          IF rw_cobertura.tpcontrato = 1 THEN
            vr_tpcontrato := 'Lim.Créd.';
          ELSIF rw_cobertura.tpcontrato = 2 THEN
            vr_tpcontrato := 'Dsc.Cheque';
          ELSIF rw_cobertura.tpcontrato = 3 THEN
            vr_tpcontrato := 'Dsc.Título';
          ELSE
            vr_tpcontrato := 'Emp.Fin.';
          END IF;
          
		  IF (rw_cobertura.inaplicacao_propria = 1 OR rw_cobertura.inaplicacao_terceiro = 1) AND
			 (rw_cobertura.inpoupanca_propria  = 1 OR rw_cobertura.inpoupanca_terceiro  = 1) THEN
			 vr_dstipapl := 'Aplicação/Poupança';
		  ELSIF (rw_cobertura.inaplicacao_propria = 1 OR rw_cobertura.inaplicacao_terceiro = 1) THEN
			 vr_dstipapl := 'Aplicação';
		  ELSIF (rw_cobertura.inpoupanca_propria  = 1 OR rw_cobertura.inpoupanca_terceiro  = 1) THEN
			 vr_dstipapl := 'Poupança';
		  ELSE
		   	 vr_dstipapl := 'Não encontrado';
		  END IF;
					
          -- Registros
          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                              ,'/Root/bloq_cobert'
                                              ,XMLTYPE('<bloq>'
                                                     ||'  <tpcontrato>'  || vr_tpcontrato            || '</tpcontrato>'
                                                     ||'  <nrdconta>'    || rw_cobertura.nrdconta    || '</nrdconta>'
                                                     ||'  <nrcontrato>'  || rw_cobertura.nrcontrato  || '</nrcontrato>'
													 ||'  <dstipapl>'    || vr_dstipapl  || '</dstipapl>'
                                                     ||'  <vlopera>'     || to_char(vr_valopera,'fm999g999g990d00') || '</vlopera>'
                                                     ||'  <valbloque>'   || to_char(vr_valbloque,'fm999g999g990d00') || '</valbloque>'
                                                     ||'  <idcobertura>' || rw_cobertura.idcobertura || '</idcobertura>'
                                                     ||'</bloq>'));
        END IF;
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_busca_bloq_apli_cobe;

  PROCEDURE pc_desbloq_cobertura(pr_idcobertura IN NUMBER
                                ,pr_vldesblo    IN NUMBER
                                ,pr_cdopelib    IN VARCHAR2 --> Codigo do operador que liberou o desbloqueio
                                ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_desbloq_cobertura
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Novembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para desbloquear Bloqueios por Cobertura de Operação de Crédito
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
	  -- Variáveis para tratamento de log
	  vr_nrdrowid ROWID;
			
      --Variáveis auxiliares para valores de cobertura
      vr_vlroriginal NUMBER := 0;
      vr_vlratualizado NUMBER := 0;
      vr_nrcpfcnpj_cobertura VARCHAR(20);
			
	  -- Buscar dados da cobertura
	  CURSOR cr_tbgar_cobertura_operacao(pr_idcobertura IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT gar.nrdconta
			  ,decode(gar.tpcontrato, 1, 'Limite Crédito', 
							          2, 'Desconto Cheques', 
									  3, 'Desconto Titulos', 
							         90, 'Emprestimos/Financiamentos', 
									     'Nao encontrado') tpcontrato
			  ,gar.nrcontrato
		 FROM tbgar_cobertura_operacao gar
		WHERE gar.idcobertura = pr_idcobertura;
	  rw_tbgar_cobertura_operacao cr_tbgar_cobertura_operacao%ROWTYPE;
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'TELA_BLQRGT' 
                                ,pr_action => null);  
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      -- Consulta o saldo atualizado para desbloqueio da cobertura parcial ou completa
      BLOQ0001.pc_bloqueio_garantia_atualizad(pr_idcobert => pr_idcobertura
                                             ,pr_vlroriginal => vr_vlroriginal
                                             ,pr_vlratualizado => vr_vlratualizado
                                             ,pr_nrcpfcnpj_cobertura => vr_nrcpfcnpj_cobertura
                                             ,pr_dscritic => vr_dscritic);
      
      -- Se o valor de desbloqueio for maior ou igual ao valor atualizado, efetua o desblqueio total
      IF pr_vldesblo >= vr_vlratualizado THEN                                
      BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_idcobertura => pr_idcobertura
                                              ,pr_inbloq_desbloq => 'D'
                                              ,pr_cdoperador     => vr_cdoperad
                                              ,pr_cdcoordenador_desbloq => pr_cdopelib
                                              ,pr_vldesbloq      => pr_vldesblo
                                              ,pr_flgerar_log    => 'S'
                                              ,pr_dscritic       => vr_dscritic);
         
      ELSE -- Libera o desbloqueio parcial do saldo
         BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_idcobertura => pr_idcobertura
                                           ,pr_inbloq_desbloq => 'L'
                                           ,pr_cdoperador => vr_cdoperad
                                           ,pr_cdcoordenador_desbloq => pr_cdopelib
                                           ,pr_vldesbloq => pr_vldesblo
                                           ,pr_flgerar_log => 'S'
                                           ,pr_dscritic => vr_dscritic);
      END IF;                                              
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
			
		-- Buscar conta da cobertura
		OPEN cr_tbgar_cobertura_operacao(pr_idcobertura);
		FETCH cr_tbgar_cobertura_operacao INTO rw_tbgar_cobertura_operacao;
  
		IF cr_tbgar_cobertura_operacao%FOUND THEN
			-- Gerar log
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
													,pr_cdoperad => vr_cdoperad
													,pr_dscritic => ' '
													,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
													,pr_dstransa => 'Desbloqueio do valor de cobertura de garantia.'
													,pr_dttransa => TRUNC(SYSDATE)
													,pr_flgtrans => 1
													,pr_hrtransa => gene0002.fn_busca_time
													,pr_idseqttl => 1
													,pr_nmdatela => vr_nmdatela
													,pr_nrdconta => rw_tbgar_cobertura_operacao.nrdconta
													,pr_nrdrowid => vr_nrdrowid);
															
			-- Tipo do contrato
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Tipo do contrato'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => rw_tbgar_cobertura_operacao.tpcontrato);
													
			-- Nr. do contrato
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Nr. do contrato'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => trim(gene0002.fn_mask_contrato(rw_tbgar_cobertura_operacao.nrcontrato)));
			
			-- Operador que efetuou a liberação
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Operador liberacao'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => pr_cdopelib);
															 
			-- Valor do desbloqueio
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Valor desbloqueio'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => to_char(pr_vldesblo, 'fm999g999g999g990d00'));
		
        END IF;			
		-- Fechar cursor
		CLOSE cr_tbgar_cobertura_operacao;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
       
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_desbloq_cobertura;

END TELA_BLQRGT;
/
