create or replace package cecred.CNSO0001 is
  /*..............................................................................

   Programa: CNSO0001         (Antiga: includes/crps663.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2013                       Ultima atualizacao: 24/04/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Procedimentos para o debito de agendamentos de consorcios. 

   Alteracoes: 05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               15/01/2014 - Correcoes e melhorias conforme softdesk 121162
                            (Carlos).
                            
               23/06/2014 - Ajustado cria-crapndb para buscar craplau.cdseqtel
                            (Lucas R.) 
                            
               07/11/2014 - Retirado as declaracoes de variaveis da includes 
                            crps663.i e declarado aqui na debcns.p para evitar 
                            problemas de imcompatibilidade na hora de usar a 
                            includes, alteracoes referentes a automatizacao da 
                            DEBCNS (Tiago SD199974).

               19/11/2015 - Ajustado para que a procedure efetua-debito-consorcio
                            utilize a obtem-saldo-dia convertida em Oracle.
                            (Douglas - Chamado 285228)
                            
               25/11/2015 - Incluida procedure gera_log_execucao_663 para gerar
                            log quando debcns for executada manualmente
                            (Tiago SD338533).

               24/10/2016 - Ajustes para que tenha uma terceira execucao
                            da DEBCNS - Melhoria349 (Tiago/Elton).
                            
               23/10/2017 - Ajustes para lançamentos duplicados e tambem para que 
                            tenhamos uma execucao matutina (Lucas Ranghetti #739738)
                            
               29/01/2018 - Ajustar DEBCNS conforme solicitaçao do chamado (Lucas Ranghetti #837834) 
                           
               21/02/2018 - Ajustar relatorio e gravar critica na lau caso 
                            tenha alguma (Lucas Ranghetti #852207)
                            
               24/04/2018 - Migracao do Progress (crps663.i) para Oracle
                            (Teobaldo Jamunda, AMcom - PRJ Debitador Unico)
							 
............................................................................*/

  TYPE typ_reg_consorcio IS
  RECORD ( chave    VARCHAR2(100)
          ,cdcooper crapcop.cdcooper%TYPE
          ,nrdconta crapcns.nrdconta%TYPE
					,dsconsor VARCHAR2(10)
					,nrcotcns crapcns.nrcotcns%TYPE
					,qtparcns crapcns.qtparcns%TYPE
					,vlrcarta crapcns.vlrcarta%TYPE
					,vlparcns crapcns.vlparcns%TYPE
					,dscooper crapcop.nmrescop%TYPE
					,nmprimtl crapass.nmprimtl%TYPE
					,nrctacns crapcns.nrctacns%TYPE
					,cdagenci INTEGER
					,flgdebit NUMBER(1)
					,dscritic VARCHAR2(100)
					,nrdocmto craplau.nrdocmto%TYPE
					,nrdgrupo crapcns.nrdgrupo%TYPE
					,nrctrato NUMBER
					,tpconsor crapcns.tpconsor%TYPE
          ,cdhistor craplau.cdhistor%TYPE);

  -- Definicao do tipo de tabela temporária
  TYPE typ_tab_consorcio IS
    TABLE OF typ_reg_consorcio
    INDEX BY Binary_Integer;

  PROCEDURE pc_gera_debitos (pr_cdcooper  IN crapcop.cdcooper%TYPE                --> Cooperativa
                            ,pr_flgresta  IN PLS_INTEGER                          --> Flag padrao para utilizacao de restart
                            ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE                --> Data movimento atual
                            ,pr_flultexe  IN PLS_INTEGER                          --> Flag para indicar se eh ultima execucao
                            ,pr_cdprogra  IN crapprg.cdprogra%TYPE                --> Codigo programa
                            ,pr_nmrelato OUT VARCHAR2                             --> Nome do relatorio gerado
                            ,pr_cdcritic OUT INTEGER                              --> Codigo da Critica
                            ,pr_dscritic OUT VARCHAR2);                           --> Descricao do erro se ocorrer

	-- Procedure que faz a busca de consorcios nao debitados no processo noturno
  PROCEDURE pc_obtem_consorcio (pr_cdcooper  IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE             --> Data movimento atual
                               ,pr_tab_cnso  IN OUT NOCOPY typ_tab_consorcio      --> Tabela temp com consorcios
                               ,pr_cdcritic     OUT crapcri.cdcritic%TYPE         --> Codigo da critica de erro
                               ,pr_dscritic     OUT VARCHAR2);                    --> Descricao do erro se ocorrer


  /* Procedimento para efetivar os pagamentos de consorcio */
  PROCEDURE pc_efetua_debito_consorcio(pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Código da coopertiva
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE      --> Data movimento atual
                                      ,pr_flmanual  IN INTEGER                    --> Indica se manual 0-False, 1-True
                                      ,pr_flultexe  IN INTEGER                    --> Indicador de sequencia de execucao
                                      ,pr_tab_cnso  IN OUT typ_tab_consorcio      --> Tabela temporária com a carga de consorcios
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE  --> Codigo da critica de erro
                                      ,pr_dscritic     OUT VARCHAR2);             --> Descricao do erro se ocorrer
                                      
  /* Procedimento para gerar o relatório cxom o resumo das operações efetuadas nos agendamentos*/
  PROCEDURE pc_gera_relatorio (pr_cdcooper  IN crapcop.cdcooper%TYPE              --> Cooperativa
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE              --> Codigo do Programa
                              ,pr_dtmvtolt  IN DATE                               --> Data do movimento
                              ,pr_tab_cons  IN typ_tab_consorcio                  --> Tabela temporária com a carga de agendamentos
                              ,pr_nmrelato OUT VARCHAR2                           --> Nome do relatorio gerado
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE              --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2);                         --> descrição do erro se ocorrer


  /* Procedimento para criar registros na crapndb */
  PROCEDURE pc_gera_crapndb (pr_cdcooper  IN crapcop.cdcooper%TYPE                --> Código da coopertiva
                            ,pr_dtmvtolt  IN DATE                                 --> Data do movimento
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE                --> Numero da conta
                            ,pr_cdempres  IN craplau.cdempres%TYPE                --> Código da empresa
                            ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE                --> Documento
                            ,pr_nrctacns  IN crapass.nrctacns%TYPE                --> Conta consórcio
                            ,pr_vllanaut  IN craplau.vllanaut%TYPE                --> Valor do lancemento
                            ,pr_cdagenci  IN crapass.cdagenci%TYPE                --> Agencia do cooperado PA
                            ,pr_cdseqtel  IN craplau.cdseqtel%TYPE                --> Sequencial
                            ,pr_cdhistor  IN craplau.cdhistor%TYPE                --> Codigo do historico
                            ,pr_cdcritic  IN OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                            ,pr_dscritic     OUT VARCHAR2);                       --> descrição do erro se ocorrer

  /* Procedure para gerar log da execucao */
  PROCEDURE pc_gera_log_execucao (pr_nmprgexe IN  VARCHAR2,
                                  pr_indexecu IN  VARCHAR2,
                                  pr_cdcooper IN  INTEGER,
                                  pr_tpexecuc IN  VARCHAR2,
                                  pr_idtiplog IN  VARCHAR2,                --> I - inicio, E - erro ou F - Fim
                                  pr_nmarqlog IN  VARCHAR2 DEFAULT NULL,   --> Nome arquivo log, se NULL assume batch    
                                  pr_dscritic OUT VARCHAR2);
                                  
END CNSO0001;
/
create or replace package body cecred.CNSO0001 is
  /*..............................................................................

   Programa: CNSO0001         (Antiga: includes/crps663.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2013                       Ultima atualizacao: 16/10/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Procedimentos para o debito de agendamentos de consorcios. 

   Alteracoes: 05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               15/01/2014 - Correcoes e melhorias conforme softdesk 121162
                            (Carlos).
                            
               23/06/2014 - Ajustado cria-crapndb para buscar craplau.cdseqtel
                            (Lucas R.) 
                            
               07/11/2014 - Retirado as declaracoes de variaveis da includes 
                            crps663.i e declarado aqui na debcns.p para evitar 
                            problemas de imcompatibilidade na hora de usar a 
                            includes, alteracoes referentes a automatizacao da 
                            DEBCNS (Tiago SD199974).

               19/11/2015 - Ajustado para que a procedure efetua-debito-consorcio
                            utilize a obtem-saldo-dia convertida em Oracle.
                            (Douglas - Chamado 285228)
                            
               25/11/2015 - Incluida procedure gera_log_execucao_663 para gerar
                            log quando debcns for executada manualmente
                            (Tiago SD338533).

               24/10/2016 - Ajustes para que tenha uma terceira execucao
                            da DEBCNS - Melhoria349 (Tiago/Elton).
                            
               23/10/2017 - Ajustes para lançamentos duplicados e tambem para que 
                            tenhamos uma execucao matutina (Lucas Ranghetti #739738)
                            
               29/01/2018 - Ajustar DEBCNS conforme solicitaçao do chamado (Lucas Ranghetti #837834) 
                           
               21/02/2018 - Ajustar relatorio e gravar critica na lau caso 
                            tenha alguma (Lucas Ranghetti #852207)
							 
               03/05/2018 - Alteracao nos codigos da situacao de conta (cdsitdct).
                            PRJ366 (Lombardi).
                            							
	             24/04/2018 - Migracao do Progress (crps663.i) para Oracle
			                     (Teobaldo Jamunda, AMcom - PRJ Debitador Unico)
                           
               20/09/2018 - inc0024147 correção no usao das vars de crítica, o programa estava 
                            atribuindo cdcritic e dscritic para os parâmetros de saída diretamente (Carlos)
                            
               16/10/2018 - inc0025316 Na rotina pc_gera_relatorio, envio do relatório crrl663 para a intranet 
                            quando for chamado pelo programa CRPS663 (Carlos)
.............................................................................*/

  -- Cursores genericos
	-- Obter dados da cooperativa 
	CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
		SELECT cop.nmrescop,
					 cop.cdcooper
		FROM crapcop cop
		WHERE cop.cdcooper = pr_cdcooper;
	rw_crapcop cr_crapcop%ROWTYPE;

  -- Obter datas e dados genericos
	rw_crapdat btch0001.cr_crapdat%ROWTYPE;

	rw_craptab btch0001.cr_craptab%ROWTYPE;

  -- CONSTANTES
  
  /* Procedure para atualizar dados de tabelas em transacao autonoma */
  PROCEDURE pc_atualiza_autonomous (pr_tabela   IN VARCHAR2         --> Nome da tabela a ser atualizada
                                   ,pr_rowid    IN ROWID            --> ROW ID da tabela
                                   ,pr_stmt     IN VARCHAR2         --> Coluna(s) e valor(es) a ser atribuidos 
                                   ,pr_dscritic OUT VARCHAR2) IS    --> Descricao da critica
  /*..............................................................................
  
   Programa: pc_atualiza_autonomous
   Autor   : Teobaldo Jamunda (AMcom)
   Data    : 08/05/2018                        Ultima atualizacao: 
  
   Dados referentes ao programa: 
  
   Objetivo  : Procedure para atualizar dados de uma tabela usando transacao autonoma,
               evitando, na pc_efetua_debito_consorcio, deixar em lock a CRAPLOT
  
   Alteracoes: 
  ..............................................................................*/
  
    -- Pragma - abre nova sessao para tratar a atualizacao
    PRAGMA AUTONOMOUS_TRANSACTION;
                              
    vr_stmt VARCHAR2(2000);
    
  BEGIN
    vr_stmt := 'UPDATE '|| UPPER(pr_tabela) || ' SET '|| pr_stmt ||
               ' WHERE ROWID = ' || chr(39) || pr_rowid || chr(39);
    Execute Immediate vr_stmt;
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
         ROLLBACK;
         pr_dscritic := 'Erro ao tentar atualizar dados na tabela '||
                        Upper(pr_tabela)||'(CNSO0001). '||SQLERRM; 
  END pc_atualiza_autonomous;  
                             
                                  
  /* Procedure que controla fluxo de debito de consorcios */
  PROCEDURE pc_gera_debitos (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                            ,pr_flgresta  IN PLS_INTEGER           --> Flag padrao para utilizacao de restart
                            ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Indicador processo
                            ,pr_flultexe  IN PLS_INTEGER           --> Flag para indicar se eh ultima execucao
                            ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo programa
                            ,pr_nmrelato OUT VARCHAR2              --> Nome do relatorio gerado
                            ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                            ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ..........................................................................
    --  Programa : pc_gera_debitos  (antigo gera_arq_debcns [crps662.p])
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Tiago
    --  Data     : Fevereiro/2014                  Ultima atualizacao: 03/05/2018
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Chamar procedures para efetuar debito de consorcios e gerar relatorio
    --
    --  Alteracoes: 03/05/2018 - Conversao Progress --> Oracle PLSQL (Teobaldo J., AMcom)
    --
    --              10/07/2018 - Ajuste para nao gerar critica caso nao encontre
    --                           consorcios para processar, evitando parada do 
    --                           Debitador Unico. (Teobaldo J, AMcom)
    --                           
    -- ..........................................................................
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_dscrilog  VARCHAR2(4000); 
    vr_dtrefere  crapdat.dtmvtolt%TYPE;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Temp table para consorcio
    vr_tab_cnso  cnso0001.typ_tab_consorcio;

  BEGIN
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Gera critica em log
      pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS'
                           ,pr_indexecu => rw_crapcop.nmrescop ||' - Registro crapdat nao encontrado.'
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_tpexecuc => NULL
                           ,pr_idtiplog => 'E'
                           ,pr_nmarqlog => NULL  -- batch log
                           ,pr_dscritic => vr_dscrilog);           
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    OPEN BTCH0001.cr_craptab(pr_cdcooper => pr_cdcooper    --> Cooperativa
                            ,pr_nmsistem => 'CRED'         --> Nome sistema
                            ,pr_tptabela => 'GENERI'       --> Tipo de tabela
                            ,pr_cdempres => 00             --> Código empresa
                            ,pr_cdacesso => 'HRPGSICRED'   --> Código de acesso
                            ,pr_tpregist => 90             --> Tipo de registro
                            ,pr_dstextab => NULL);
    FETCH BTCH0001.cr_craptab INTO rw_craptab;
    -- Se não encontrar
    IF BTCH0001.cr_craptab%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_craptab;
      -- Montar mensagem de critica
      vr_cdcritic := 210;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Gera critica em log
      pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS'
                           ,pr_indexecu => rw_crapcop.nmrescop ||' - Tabela HRPGSICRED nao cadastrada.'
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_tpexecuc => NULL
                           ,pr_idtiplog => 'E'
                           ,pr_nmarqlog => NULL  -- batch log
                           ,pr_dscritic => vr_dscrilog);           
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_craptab;
      IF SUBSTR(rw_craptab.dstextab, 19, 3) <> 'SIM' THEN
        -- Gera critica em log
        pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS'
                             ,pr_indexecu => rw_crapcop.nmrescop ||' - Opcao para processo manual desabilitada.'
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_tpexecuc => NULL
                             ,pr_idtiplog => 'E'
                             ,pr_nmarqlog => 'proc_message.log'  --se NULL batch log
                             ,pr_dscritic => vr_dscrilog);           
      END IF;
    END IF;

    -- Define data a ser utilizada.
    -- No Debitador Unico somente executarah quando crapdat.inprocess = 1,
    -- entao assume crapdat.dtmvtolt, recebida no parametro pr_dtmvtolt (origem: pc_crps663)
    --IF pr_inproces = 1 THEN
		--	vr_dtrefere := rw_crapdat.dtmvtolt;
		--ELSE
		--	vr_dtrefere := rw_crapdat.dtmvtopr;
		--END IF;
    vr_dtrefere := pr_dtmvtolt;
    

    -- Carregar as informacoes de consorcios em tabela de memoria
    pc_obtem_consorcio(pr_cdcooper => pr_cdcooper              --> Codigo da cooperativa
                      ,pr_dtmvtolt => vr_dtrefere              --> Data movimento atual
                      ,pr_tab_cnso => vr_tab_cnso              --> Tabela temp com consorcios
                      ,pr_cdcritic => vr_cdcritic              --> Codigo da critica de erro
                      ,pr_dscritic => vr_dscritic);            --> Descricao do erro se ocorrer
                                                            
    -- Se retornou alguma critica
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gera critica em log
      pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS'
                           ,pr_indexecu => rw_crapcop.nmrescop ||' - '||vr_dscritic
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_tpexecuc => NULL
                           ,pr_idtiplog => 'E'
                           ,pr_nmarqlog => 'proc_message.log'  -- se NULL batch log
                           ,pr_dscritic => vr_dscrilog);           
      RAISE vr_exc_saida;
    END IF;
    
    -- Verifica se ha debitos de consorcio para processar
    IF vr_tab_cnso.COUNT = 0 THEN
      vr_dscritic := 'Nao ha consorcios para processar neste momento para cooperativa ' || rw_crapcop.nmrescop; 

      -- Gera critica em log
      pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS'
                           ,pr_indexecu => rw_crapcop.nmrescop ||' - '||vr_dscritic
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_tpexecuc => NULL
                           ,pr_idtiplog => 'E'
                           ,pr_nmarqlog => NULL  -- se NULL batch log
                           ,pr_dscritic => vr_dscrilog); 

      -- Evitar que pare o Debitador Unico se nao houver consorcio para processar
      vr_cdcritic := 0;
      vr_dscritic := NULL; 
      
    ELSE  -- se houver debito de consorcio para processar                                   
      --> Efetua debito consorcios
      pc_efetua_debito_consorcio(pr_cdcooper => pr_cdcooper      --> Código da coopertiva
                                ,pr_dtmvtolt => vr_dtrefere      --> Indicador do processo
                                ,pr_flmanual => 0                --> Indica se manual 0-False, 1-True
                                ,pr_flultexe => pr_flultexe      --> Flag de ultima execucao
                                ,pr_tab_cnso => vr_tab_cnso      --> Tabela temporária com a carga de consorcios
                                ,pr_cdcritic => vr_cdcritic      --> Codigo da critica de erro
                                ,pr_dscritic => vr_dscritic);    --> Descricao do erro se ocorrer
      
      -- Se retornou alguma critica
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pc_gera_relatorio(pr_cdcooper => pr_cdcooper,
                        pr_cdprogra => pr_cdprogra,
                        pr_dtmvtolt => vr_dtrefere,
                        pr_tab_cons => vr_tab_cnso,
                        pr_nmrelato => pr_nmrelato,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF; --fim processar consorcio

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na rotina CNSO0001.pc_efetua_debitos. ' || sqlerrm;
  END pc_gera_debitos;


	-- Procedure que faz a busca de consorcios nao debitados no processo noturno
  PROCEDURE pc_obtem_consorcio (pr_cdcooper  IN crapcop.cdcooper%TYPE          --> Código da cooperativa
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE          --> Data movimento atual
                               ,pr_tab_cnso  IN OUT NOCOPY typ_tab_consorcio   --> Retorna os consorcios
                               ,pr_cdcritic     OUT crapcri.cdcritic%TYPE      --> Codigo da critica de erro
                               ,pr_dscritic     OUT VARCHAR2) IS               --> descrição do erro se ocorrer
															 
  ---------------------------------------------------------------------------------------------
  --  Programa : pc_obtem_consorcio (Antigo: obtem-consorcio)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Lunelli
  --   Data    : Abril/2013                       Ultima atualizacao: 25/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Buscar consorcio nao debitado no processo noturno
  --
  --  Alterações: 03/05/2018 - Alteracao nos codigos da situacao de conta (cdsitdct).
  --                          PRJ366 (Lombardi).
  --
  --              25/04/2018 - Conversão Progress --> Oracle PLSQL (Teobaldo J., AMcom)
  --
  ---------------------------------------------------------------------------------------------
		-- Cursor de lancamentos automaticos
		CURSOR cr_craplau ( pr_cdcooper IN craplau.cdcooper%TYPE,
												pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
			SELECT  craplau.cdcooper
						 ,craplau.cdagenci
						 ,craplau.nrdconta
						 ,craplau.dtmvtopg
						 ,craplau.vllanaut
						 ,craplau.nrdocmto
						 ,craplau.nrcrcard
						 ,craplau.cdhistor
						 ,craplau.ROWID craplau_rowid
						 ,(CASE  
								WHEN craplau.cdhistor = 1230 THEN 1
								WHEN craplau.cdhistor = 1231 THEN 2
								WHEN craplau.cdhistor = 1232 THEN 3
								WHEN craplau.cdhistor = 1233 THEN 4
								WHEN craplau.cdhistor = 1234 THEN 5
								ELSE NULL
							 END) tpconsor
			  FROM craplau,
						 craphis
			 WHERE craplau.cdcooper = craphis.cdcooper
				 AND craplau.cdhistor = craphis.cdhistor
         AND craplau.cdcooper = pr_cdcooper
         AND craplau.dtmvtopg = pr_dtmvtopg
				 AND craplau.insitlau = 1
				 AND craplau.cdhistor in (1230, 1231, 1232, 1233, 1234)
       ORDER BY craplau.cdcooper, 
               (CASE  
                    WHEN craplau.cdhistor = 1230 THEN 3
                    WHEN craplau.cdhistor = 1231 THEN 1
                    WHEN craplau.cdhistor = 1232 THEN 4
                    WHEN craplau.cdhistor = 1233 THEN 2
                    WHEN craplau.cdhistor = 1234 THEN 5
                    ELSE NULL
                END),
                craplau.nrdocmto, 
                craplau.cdagenci,
                craplau.nrdconta;
                
		-- Obter dados consorcio
		CURSOR cr_crapcns (pr_cdcooper IN crapcns.cdcooper%TYPE,
											 pr_tpconsor IN crapcns.tpconsor%TYPE,
                       pr_nrdconta IN crapcns.nrdconta%TYPE,
                       pr_nrctrato IN crapcns.nrctrato%TYPE) IS
      SELECT crapcns.nrdconta
            ,crapcns.nrcotcns
            ,crapcns.qtparcns
            ,crapcns.vlrcarta
            ,crapcns.vlparcns
            ,crapcns.nrctacns
            ,crapcns.cdcooper
            ,1 flgdebit
            ,crapcns.nrdgrupo
            ,crapcns.nrctrato
            ,crapcns.tpconsor
						,(CASE
							  WHEN crapcns.tpconsor = 1 THEN 'MOTO'
							  WHEN crapcns.tpconsor = 2 THEN 'AUTO'
							  WHEN crapcns.tpconsor = 3 THEN 'PESADOS'
							  WHEN crapcns.tpconsor = 4 THEN 'IMOVEIS'
							  WHEN crapcns.tpconsor = 5 THEN 'SERVICOS'
              END) dsconsor
            ,lpad(crapcns.cdcooper,5,'0')||'-'||lpad(crapcns.nrdconta,10,'0')||'-'||
             crapcns.tpconsor||'-'||lpad(pr_nrctrato,8,'0')||'-'||crapcns.rowid as chave                
	      FROM crapcns
			 WHERE crapcns.cdcooper = pr_cdcooper
         AND crapcns.tpconsor = pr_tpconsor
         AND crapcns.nrdconta = pr_nrdconta
         AND crapcns.nrctrato = pr_nrctrato
       ORDER BY crapcns.cdcooper, 
                crapcns.nrdconta, 
                crapcns.nrcotcns, 
                crapcns.qtparcns,
                crapcns.vlrcarta,
                crapcns.vlparcns;

		-- Informacoes de associados
		CURSOR cr_crapass (pr_cdcooper IN  crapass.cdcooper%TYPE,
		                   pr_nrdconta IN  crapass.nrdconta%TYPE) IS
			SELECT crapass.nmprimtl
						,crapass.cdagenci
			  FROM crapass
			 WHERE crapass.cdcooper = pr_cdcooper
			   AND crapass.nrdconta = pr_nrdconta;
		rw_crapass cr_crapass%ROWTYPE;

		vr_exc_erro  EXCEPTION;
		vr_cdcritic   crapcri.cdcritic%TYPE; --> Código da crítica
		vr_dscritic   VARCHAR2(2000);        --> Descrição da crítica		
		vr_dtrefere   crapdat.dtmvtolt%TYPE; --> Data de referencia 
    vr_nrdocmto   VARCHAR2(25); 
    vr_indice     INTEGER;

  BEGIN
    -- Limpando dados da tabela temporaria, se houver
    pr_tab_cnso.delete;

    -- Verifica se a cooperativa está cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper); 
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de crítica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

   	-- Data de movimento (pode ser dtmvtolt ou dtmvtopr, definido pela origem)
    vr_dtrefere := pr_dtmvtolt;

    -- Abrindo e navegando no cursor de lancamentos
    vr_indice := 0;
    FOR rw_craplau IN cr_craplau (pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtopg => vr_dtrefere) LOOP

      /* nrdocmto com 22 posicoes - joga como string para poder dar o
        substr corretamente logo abaixo */
      IF NVL(rw_craplau.nrcrcard,0) <> 0 THEN
        vr_nrdocmto := to_char(rw_craplau.nrcrcard,'fm0000000000000000000000');
      ELSE
        vr_nrdocmto := to_char(rw_craplau.nrdocmto,'fm0000000000000000000000');
      END IF;
      
      FOR rw_crapcns IN cr_crapcns (rw_craplau.cdcooper,
                                    rw_craplau.tpconsor,
                                    rw_craplau.nrdconta,
                                    TO_NUMBER(SUBSTR(vr_nrdocmto,1,8))) LOOP

          -- Verifica se a conta existe
          OPEN cr_crapass(pr_cdcooper => rw_craplau.cdcooper, 
                          pr_nrdconta => rw_craplau.nrdconta);
          FETCH cr_crapass INTO rw_crapass;

          -- Se a conta não existe aborta a execução e gera crítida
          IF  cr_crapass%NOTFOUND THEN
            -- Fecha o cursor para as próximas iterações
            CLOSE cr_crapass;
            -- Gerando a crítica
            vr_cdcritic := 9;
            vr_dscritic := 'Erro em  CNSO0001.pc_obtem_consorcio. Coop./Conta: ' ||
                           rw_craplau.cdcooper || '/' || rw_craplau.nrdconta || ' não existe.';
            -- gerando exceção
            RAISE vr_exc_erro;
          ELSE
            -- fecha o cursor para as próximas iterações
            CLOSE cr_crapass;
          END IF;
                                      
          -- Carregando consorcios
          vr_indice := vr_indice + 1;   
          pr_tab_cnso(vr_indice).chave    := rw_crapcns.chave;   -- para relatorio
          pr_tab_cnso(vr_indice).nrdconta := rw_crapcns.nrdconta;
          pr_tab_cnso(vr_indice).dsconsor := rw_crapcns.dsconsor;
          pr_tab_cnso(vr_indice).nrcotcns := rw_crapcns.nrcotcns;
          pr_tab_cnso(vr_indice).qtparcns := rw_crapcns.qtparcns;
          pr_tab_cnso(vr_indice).vlrcarta := rw_crapcns.vlrcarta;
          pr_tab_cnso(vr_indice).vlparcns := rw_craplau.vllanaut;
          pr_tab_cnso(vr_indice).dscooper := UPPER(rw_crapcop.nmrescop);
          pr_tab_cnso(vr_indice).cdcooper := rw_crapcns.cdcooper;
          pr_tab_cnso(vr_indice).nmprimtl := rw_crapass.nmprimtl;
          pr_tab_cnso(vr_indice).nrctacns := rw_crapcns.nrctacns;
          pr_tab_cnso(vr_indice).cdagenci := rw_crapass.cdagenci;
          pr_tab_cnso(vr_indice).flgdebit := rw_crapcns.flgdebit;
          pr_tab_cnso(vr_indice).nrdocmto := rw_craplau.nrdocmto;
          pr_tab_cnso(vr_indice).nrdgrupo := rw_crapcns.nrdgrupo;
          pr_tab_cnso(vr_indice).nrctrato := rw_crapcns.nrctrato;
          pr_tab_cnso(vr_indice).tpconsor := rw_crapcns.tpconsor;
          pr_tab_cnso(vr_indice).cdhistor := rw_craplau.cdhistor;
          pr_tab_cnso(vr_indice).dscritic := NULL;
                                      
      END LOOP; -- FOR rw_crapcns
    END LOOP; -- FOR rw_craplau IN cr_craplau

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado em CNSO0001.pc_obtem_consorcio --> '||SQLERRM;
  END pc_obtem_consorcio;


  /* Procedimento para efetuar os debitos de consorcios*/
  PROCEDURE pc_efetua_debito_consorcio(pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE        --> Data de movimento 
                                      ,pr_flmanual  IN INTEGER                      --> Indica se manual 0-False, 1-True
                                      ,pr_flultexe  IN INTEGER                      --> Indicador de sequencia de execucao
                                      ,pr_tab_cnso  IN OUT typ_tab_consorcio        --> Tabela temporária com a carga de consorcios
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE    --> Codigo da critica de erro
                                      ,pr_dscritic     OUT VARCHAR2) IS             --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_efetua_debito_consorcio (Antigo: efetua-debito-consorcio)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas R. 
  --   Data    : Julho/2013                       Ultima atualizacao: 19/11/2015
  --
  --  Dados referentes ao programa:
  --
  --  Frequencia: Sempre que chamado
  --  Objetivo  : Efetua os lançamentos de débitos de consorcio
  --
  --  Alterações: 26/04/2018 - Conversão Progress --> Oracle PLSQL (Teobaldo J. - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- CURSORES
  
  -- Obter ultimo lote existente
  CURSOR cr_craplot_last(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
   SELECT /*+ index_desc (craplot CRAPLOT##CRAPLOT1 ) */
          craplot.nrdolote
     FROM craplot
    WHERE craplot.cdcooper = pr_cdcooper
      AND craplot.dtmvtolt = pr_dtmvtolt
      AND craplot.nrdolote > 6500
      AND craplot.nrdolote < 6600
      AND craplot.tplotmov = 1;
  rw_craplot_last cr_craplot_last%ROWTYPE;
  
  -- Cursor de lancamentos automaticos
  CURSOR cr_craplau (pr_cdcooper IN craplau.cdcooper%TYPE,
                     pr_dtmvtopg IN craplau.dtmvtopg%TYPE,
                     pr_nrdconta IN craplau.nrdconta%TYPE,
                     pr_nrdocmto IN craplau.nrdocmto%TYPE,
                     pr_cdhistor IN craplau.cdhistor%TYPE) IS
    SELECT  craplau.cdcooper
           ,craplau.cdagenci
           ,craplau.nrdconta
           ,craplau.dtmvtopg
           ,craplau.vllanaut
           ,craplau.nrdocmto
           ,craplau.nrcrcard
           ,craplau.nrdctabb
           ,craplau.cdhistor
           ,craplau.ROWID
           ,craplau.progress_recid
           ,craplau.cdbccxlt
           ,craplau.cdseqtel
           ,craplau.nrseqdig
           ,craplau.nrdolote
           ,craplau.dtmvtolt
           ,craplau.dscedent
           ,(CASE  
              WHEN craplau.cdhistor = 1230 THEN 1
              WHEN craplau.cdhistor = 1231 THEN 2
              WHEN craplau.cdhistor = 1232 THEN 3
              WHEN craplau.cdhistor = 1233 THEN 4
              WHEN craplau.cdhistor = 1234 THEN 5
              ELSE NULL
             END) tpconsor
      FROM craplau
     WHERE craplau.cdcooper = pr_cdcooper
       AND craplau.dtmvtopg = pr_dtmvtopg
       AND craplau.nrdconta = pr_nrdconta  
       AND craplau.nrdocmto = pr_nrdocmto  
       AND craplau.cdhistor = pr_cdhistor
       AND craplau.insitlau = 1
       AND craplau.cdhistor IN (1230, 1231, 1232, 1233, 1234)
     ORDER BY craplau.cdagenci,
              craplau.cdbccxlt,
              craplau.cdbccxpg,
              craplau.cdhistor,
              craplau.nrdocmto;
  
  -- Informacoes de associados
  CURSOR cr_crapass (pr_cdcooper IN  crapass.cdcooper%TYPE,
                     pr_nrdconta IN  crapass.nrdconta%TYPE) IS
    SELECT crapass.nmprimtl
          ,crapass.cdagenci
          ,crapass.dtdemiss
          ,crapass.cdsitdct
          ,crapass.dtelimin 
          ,crapass.vllimcre
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;  
  
  CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE,                
                     pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                     pr_cdagenci IN craplcm.cdagenci%TYPE,
                     pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                     pr_nrdolote IN craplcm.nrdolote%TYPE,
                     pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                     pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
    SELECT craplcm.nrdocmto
      FROM craplcm
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = pr_dtmvtolt
       AND craplcm.cdagenci = pr_cdagenci
       AND craplcm.cdbccxlt = pr_cdbccxlt
       AND craplcm.nrdolote = pr_nrdolote
       AND craplcm.nrdctabb = pr_nrdctabb
       AND craplcm.nrdocmto = pr_nrdocmto;                            
  rw_craplcm cr_craplcm%ROWTYPE;                              
  
  rw_craplot      LOTE0001.cr_craplot%ROWTYPE;

  -- VARIAVEIS
  vr_exc_erro     EXCEPTION;
  vr_flggrava     INTEGER;
  vr_indice       INTEGER;
  vr_flgentra     INTEGER;
  vr_flgmigra     INTEGER;
  vr_cdbccxlt     craplau.cdbccxlt%TYPE;
  vr_nrdconta     craplau.nrdconta%TYPE;
  vr_cdcooper     craplau.cdcooper%TYPE;
  vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;
  vr_cdcooper_seg craplau.cdcooper%TYPE;
  
  vr_cdagenci     NUMBER;
  vr_nrdolote     craplot.nrdolote%type;
  vr_nrdolot1     craplot.nrdolote%type;
  vr_nrdolot2     craplot.nrdolote%type;
  vr_nrdocmto     craplau.nrdocmto%TYPE;
  vr_nrcrcard     craplau.nrcrcard%TYPE;
  vr_mudalote     INTEGER;
  
  vr_dtrefere     DATE;
  vr_coopeatu     INTEGER;
  vr_tpconatu     INTEGER;

  -- Objetos para armazenar as variáveis da notificação
  vr_variaveis_notif NOTI0001.typ_variaveis_notif;

  -- Tratamento de erros vars
  vr_dscritic     VARCHAR2(4000);
  vr_cdcritic     NUMBER;
  vr_stmtaux      VARCHAR2(4000);
  vr_des_erro     VARCHAR2(4000);
  vr_tab_erro     GENE0001.typ_tab_erro;

  vr_tab_sald     EXTR0001.typ_tab_saldos; --> Temp-Table com o saldo do dia
  vr_ind_sald     PLS_INTEGER;             --> Indice sobre a temp-table vr_tab_sald


  BEGIN

   	-- Data de movimento (pode ser dtmvtolt ou dtmvtopr, definido pela origem)
    vr_dtrefere := pr_dtmvtolt;

    -- Se a tabela de memoria possuir registros, serao processados
    IF pr_tab_cnso.COUNT > 0 THEN

      -- Inicia percorrer dados tabela memoria
      vr_coopeatu := -1;
      vr_tpconatu := -1;

      FOR vr_indice in pr_tab_cnso.FIRST .. pr_tab_cnso.LAST LOOP
        
        -- Primeira ocorrencia da cooperativa e pr_flmanual
        IF vr_coopeatu <> pr_tab_cnso(vr_indice).cdcooper AND pr_flmanual = 1 THEN
          pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS'
                               ,pr_indexecu => 'Inicio execucao'
                               ,pr_cdcooper => pr_tab_cnso(vr_indice).cdcooper
                               ,pr_tpexecuc => NULL
                               ,pr_idtiplog => 'I'
                               ,pr_nmarqlog => ('prcctl_'||to_char(vr_dtrefere,'RRRRMMDD')||'.log')
                               ,pr_dscritic => vr_dscritic);           
        END IF;
        
        -- Primeira ocorrencia da cooperativa  
        IF vr_coopeatu <> pr_tab_cnso(vr_indice).cdcooper THEN
        
          -- Obtem ultimo lote
          OPEN  cr_craplot_last(pr_cdcooper => pr_tab_cnso(vr_indice).cdcooper,
                                pr_dtmvtolt => vr_dtrefere); 
          FETCH cr_craplot_last
           INTO rw_craplot_last;
          -- Se não encontrar
          IF cr_craplot_last%NOTFOUND THEN
            vr_nrdolot1 := 6500;
          ELSE
            vr_nrdolot1 := rw_craplot_last.nrdolote;
          END IF;
          -- Fechar o cursor e atribuir valor
          CLOSE cr_craplot_last;
        END IF;  -- primeira ocorrencia cooperativa

        /* Somar o lote somente quando mudar o historico */
        IF vr_tpconatu <> pr_tab_cnso(vr_indice).tpconsor THEN
          vr_mudalote := 1;
        ELSE
          vr_mudalote := 0;
        END IF;

        -- Atualizar controle de cooperativa e tipo de consorcio corrente
        -- Nao eh possivel colocar no final do loop porque pode ocorrer CONTINUE 
        vr_coopeatu := pr_tab_cnso(vr_indice).cdcooper;
        vr_tpconatu := pr_tab_cnso(vr_indice).tpconsor;

        FOR rw_craplau in cr_craplau (pr_cdcooper => pr_tab_cnso(vr_indice).cdcooper,
                                      pr_dtmvtopg => vr_dtrefere,
                                      pr_nrdconta => pr_tab_cnso(vr_indice).nrdconta,
                                      pr_nrdocmto => pr_tab_cnso(vr_indice).nrdocmto,
                                      pr_cdhistor => pr_tab_cnso(vr_indice).cdhistor) LOOP
          vr_flgmigra := 0;
          vr_flgentra := 0;
          vr_cdcooper := pr_cdcooper;
          vr_cdagenci := rw_craplau.cdagenci;
          vr_nrdolote := vr_nrdolot1;
          IF rw_craplau.cdbccxlt = 911 Then
            vr_cdbccxlt := 11;
          ELSE
            vr_cdbccxlt := rw_craplau.cdbccxlt;
          END IF;
          vr_nrdconta := rw_craplau.nrdconta;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
            
          IF vr_mudalote = 1 THEN
             vr_nrdolote := vr_nrdolot1 + 1;
          END IF;
            
          LOTE0001.pc_insere_lote(pr_cdcooper => rw_craplau.cdcooper,
                                  pr_dtmvtolt => vr_dtrefere,
                                  pr_cdagenci => vr_cdagenci,
                                  pr_cdbccxlt => vr_cdbccxlt,
                                  pr_nrdolote => vr_nrdolote,
                                  pr_cdoperad => NULL,
                                  pr_nrdcaixa => NULL,
                                  pr_tplotmov => 1,
                                  pr_cdhistor => NULL,
                                  pr_craplot  => rw_craplot,
                                  pr_dscritic => vr_dscritic);
                                    
          IF vr_flgmigra = 1 THEN
            vr_nrdolot2 := vr_nrdolote;
          ELSE
            vr_nrdolot1 := vr_nrdolote;
          END IF;
         
          /* Apos 22/08/2017 buscaremos do nrcrcard que esta armazenando a referencia 
            original no crps647 */
          IF rw_craplau.nrcrcard <> 0 THEN
            vr_nrcrcard := rw_craplau.nrcrcard;
          ELSE
            vr_nrcrcard := rw_craplau.nrdocmto;
          END IF;
         
         -- Indica se deve gravar lancamento 
          vr_flggrava := 0;
          
          -- Verifica se associado estah cadastrado
          OPEN cr_crapass(pr_cdcooper => rw_craplau.cdcooper,
                          pr_nrdconta => rw_craplau.nrdconta); 
          FETCH cr_crapass
          INTO  rw_crapass;
          -- Se nao encontrar
          IF cr_crapass%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            vr_cdcritic := 9;
            vr_dscritic := 'Associado nao cadastrado.';
            CLOSE cr_crapass;
          ELSE
            -- Fechar o cursor e testar dados
            CLOSE cr_crapass;
            
            IF rw_crapass.dtdemiss IS NOT NULL THEN
               vr_cdcritic := 454;
               vr_dscritic := 'Cooperado foi demitido.';
            ELSIF rw_crapass.cdsitdct IN (2, 3, 4) THEN
               vr_cdcritic := 64;
               vr_dscritic := 'Conta encerrada.';
            ELSIF rw_crapass.dtelimin IS NOT NULL THEN
               vr_cdcritic := 410;
               vr_dscritic := 'Associado excluido.';
            ELSE
               vr_flggrava := 1;
            END IF;
          END IF;        
        
          IF vr_flggrava = 1 THEN

            /* Utilizar o tipo de busca A, para carregar do dia anterior
              (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
            -- Obter valores de saldos diarios
            extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_craplau.cdcooper,
                                        pr_rw_crapdat => rw_crapdat,
                                        pr_cdagenci   => vr_cdagenci,
                                        pr_nrdcaixa   => 1,
                                        pr_cdoperad   => '1',
                                        pr_nrdconta   => rw_craplau.nrdconta,
                                        pr_vllimcre   => rw_crapass.vllimcre,
                                        pr_dtrefere   => vr_dtrefere,
                                        pr_tipo_busca => 'A',   --> tipo de busca (A-dtmvtoan) 
                                        pr_flgcrass   => FALSE, --> Nao deve carregar todas as contas em memoria, apenas a conta em questao
                                        pr_des_reto   => vr_des_erro,
                                        pr_tab_sald   => vr_tab_sald,
                                        pr_tab_erro   => vr_tab_erro);
                                        
            vr_ind_sald := vr_tab_sald.last;
            
            -- se encontrar erro
            IF (vr_des_erro = 'NOK' OR vr_tab_sald.Count = 0) THEN
              vr_dscritic := 'Nao foi possivel consultar saldo para operacao.';
              vr_flggrava := 0;
            ELSE
              
              IF rw_craplau.vllanaut > 
                 (vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vllimcre) THEN
                 vr_cdcritic := 717;
                 vr_dscritic := 'Nao ha saldo suficiente para a operacao.';
                 vr_flggrava := 0;
              END IF;
              
            END IF; -- fim erro
          END IF; -- fim realiza consulta saldo

          /* Para aparecer na debcon devemos gravar a critica (ex.: 717) */
          IF vr_cdcritic <> 0 THEN
              UPDATE craplau
                 SET craplau.cdcritic = vr_cdcritic
               WHERE craplau.rowid = rw_craplau.rowid;
          END IF;

          /*** Se ocorreu alguma critica ao tentar realizar operacoes acima ***/
          IF vr_dscritic IS NOT NULL THEN 
          
            -- atualiza temp table com a critica na ultima execucao 
            -- obs.: na original tambem atualizava dados na cria-crapndb (crps663.i)
            pr_tab_cnso(vr_indice).flgdebit := 0;
            pr_tab_cnso(vr_indice).dscritic := vr_dscritic;

            /* Ultima execucao do dia */ 
            IF pr_flultexe = 1 THEN

              -- Registrar debito nao efetuado
              pc_gera_crapndb (pr_cdcooper => rw_craplau.cdcooper,
                               pr_dtmvtolt => vr_dtrefere,
                               pr_nrdconta => rw_craplau.nrdconta,
                               pr_cdempres => 'J5',
                               pr_nrdocmto => vr_nrcrcard,
                               pr_nrctacns => pr_tab_cnso(vr_indice).nrctacns,
                               pr_vllanaut => rw_craplau.vllanaut,
                               pr_cdagenci => vr_cdagenci,
                               pr_cdseqtel => rw_craplau.cdseqtel,
                               pr_cdhistor => rw_craplau.cdhistor,
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);
                               
              -- Atualiza registro de Lancamento Automatico
              BEGIN
                UPDATE craplau
                   SET insitlau = 3
                      ,dtdebito = vr_dtrefere
                 WHERE ROWID = rw_craplau.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar craplau (CSNO0001): ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF; -- ultima do dia                   
            
            -- Volta para o inicio do loop ===>>> DESVIO
            CONTINUE;
            
          END IF;  --fim ocorreu critica
          
          -- Gerar lancamento de debito do Consorcio
          IF vr_flggrava = 1 THEN
 
            vr_nrdocmto := rw_craplau.nrdocmto;
            
            -- obter nrdocmto para lancamento
            OPEN cr_craplcm(rw_craplau.cdcooper,
                            vr_dtrefere,    
                            rw_craplot.cdagenci,
                            rw_craplot.cdbccxlt,
                            rw_craplot.nrdolote,
                            vr_nrdconta,    
                            vr_nrdocmto);
            LOOP
              FETCH cr_craplcm INTO rw_craplcm;
              EXIT WHEN cr_craplcm%NOTFOUND;
              
              -- se encontrou incrementa
              vr_nrdocmto := vr_nrdocmto + 100000000;
            END LOOP;
            CLOSE cr_craplcm;
          
            -- cria registro na tabela de lançamentos
            BEGIN
              INSERT INTO craplcm
                (cdcooper
                ,dtmvtolt
                ,cdagenci
                ,cdbccxlt
                ,nrdolote
                ,nrdconta
                ,nrdctabb
                ,nrdctitg
                ,nrdocmto
                ,cdhistor
                ,vllanmto
                ,nrseqdig
                ,hrtransa
                ,cdpesqbb)
              VALUES
                (rw_craplau.cdcooper
                ,rw_craplot.dtmvtolt
                ,rw_craplot.cdagenci
                ,rw_craplot.cdbccxlt
                ,rw_craplot.nrdolote
                ,vr_nrdconta
                ,rw_craplau.nrdctabb
                ,to_char(rw_craplau.nrdctabb,'fm00000000')
                ,vr_nrdocmto
                ,rw_craplau.cdhistor
                ,rw_craplau.vllanaut
                ,rw_craplot.nrseqdig
                ,gene0002.fn_busca_time
                ,'Lote ' || to_char(rw_craplau.dtmvtolt, 'dd')              || '/' ||
                            to_char(rw_craplau.dtmvtolt, 'mm')              || '-' ||
                            GENE0002.fn_mask(vr_cdagenci, '999')            || '-' ||
                            GENE0002.fn_mask(rw_craplau.cdbccxlt, '999')    || '-' ||
                            GENE0002.fn_mask(rw_craplau.nrdolote, '999999') || '-' ||
                            GENE0002.fn_mask(rw_craplau.nrseqdig, '99999')  || '-' ||
                            vr_nrcrcard)
                 RETURNING craplcm.nrseqdig
                      INTO vr_nrseqdig_lcm;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir craplcm(CNSO0001): ' || SQLERRM;
                RAISE vr_exc_erro;
            END;

            -- Atualiza a capa do lote
            BEGIN
              vr_stmtaux := 'qtcompln = nvl(qtcompln,0) + 1 ';
              vr_stmtaux := vr_stmtaux ||',vlcompdb = nvl(vlcompdb,0) + ' || replace(rw_craplau.vllanaut,',','.');
              vr_stmtaux := vr_stmtaux ||',qtinfoln = nvl(qtinfoln,0) + 1';
              vr_stmtaux := vr_stmtaux ||',vlinfodb = nvl(vlinfodb,0) + ' || replace(rw_craplau.vllanaut,',','.');
              vr_stmtaux := vr_stmtaux ||',nrseqdig = ' || vr_nrseqdig_lcm;
              vr_stmtaux := vr_stmtaux ||',craplot.cdbccxpg = 11';    --> atribuido na crps663.i na criacao lote
               
              cnso0001.pc_atualiza_autonomous(pr_tabela  => 'craplot'          --> Nome da tabela a ser atualizada
                                             ,pr_rowid   => rw_craplot.rowid   --> ROW ID da tabela
                                             ,pr_stmt    => vr_stmtaux         --> Coluna(s) e valor(es) a ser atribuidos 
                                             ,pr_dscritic=> vr_dscritic);      --> Descricao da Critica
                                            
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Erro ao atualizar valores craplot(CNSO0001), lote: '||vr_nrdolote||' -> '|| SQLERRM;
                RAISE vr_exc_erro;
              END IF;   
              
            EXCEPTION                                                    
              WHEN OTHERS THEN 
                 vr_dscritic := 'Erro ao atualizar craplot(CNSO0001). '|| SQLERRM;
                 RAISE vr_exc_erro;
            END;

            -- Atualiza registro de lancamento automatico
            BEGIN
              UPDATE craplau
                 SET craplau.insitlau = 2
                    ,craplau.nrseqlan = vr_nrseqdig_lcm
                    ,craplau.dtdebito = vr_dtrefere
                    ,craplau.dsorigem = 'DEBCNS'
               WHERE craplau.rowid = rw_craplau.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar craplau(CNSO0001): ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            --> inicio NOTIF 
            vr_variaveis_notif('#valordebito')  := to_char(rw_craplau.vllanaut,'FM999G990D00') ;
            vr_variaveis_notif('#datadebito')   := to_char(vr_dtrefere,'DD/MM/RRRR'); 
            vr_variaveis_notif('#tipodebito')   := rw_craplau.dscedent;            
            
            noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => 10
                                        ,pr_cdmotivo_mensagem => 1
                                        ,pr_cdcooper          => pr_cdcooper
                                        ,pr_nrdconta          => vr_nrdconta
                                        ,pr_idseqttl          => 0
                                        ,pr_variaveis         => vr_variaveis_notif);
            --> fim NOTIF
              
          END IF; -- fim flggrava (debito consorcio)

        END LOOP; -- fim rw_craplau
        
        IF pr_tab_cnso.EXISTS(vr_indice + 1) THEN
            vr_cdcooper_seg := pr_tab_cnso(vr_indice + 1).cdcooper;
        ELSE
            vr_cdcooper_seg := -1;
        END IF;
        
        -- verifica se eh ultimo registro da cooperativa (Atual <> Proxima)
        IF (pr_tab_cnso(vr_indice).cdcooper <> vr_cdcooper_seg AND pr_flmanual = 1) THEN
            
            pc_gera_log_execucao (pr_nmprgexe => 'DEBCNS',
                                  pr_indexecu => 'Fim execucao',
                                  pr_cdcooper => pr_tab_cnso(vr_indice).cdcooper,
                                  pr_tpexecuc => NULL,
                                  pr_idtiplog => 'F',
                                  pr_nmarqlog => ('prcctl_'||to_char(vr_dtrefere,'RRRRMMDD')||'.log'),
                                  pr_dscritic => vr_dscritic);
        END IF;
        
        -- Commit a cada registro devido estar gravando dados de lote (autonomous)
        COMMIT;
        
      END LOOP; -- fim tabela memoria
    END IF; -- fim existem dados

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- retorna erro tratado
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado em CNSO0001.pc_efetua_debito_consorcio --> '||SQLERRM;
  END pc_efetua_debito_consorcio;


  /* Procedimento para gerar o relatório com o resumo das operações efetuadas nos agendamentos*/
  PROCEDURE pc_gera_relatorio (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo do Programa
                              ,pr_dtmvtolt  IN DATE                  --> Data do movimento
                              ,pr_tab_cons  IN typ_tab_consorcio     --> Tabela temporária com a carga de agendamentos
                              ,pr_nmrelato OUT VARCHAR2              --> Nome do relatorio gerado
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2) IS          --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gera_relatorio    (Antigo: imprime-consorcios)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Lunelli
  --   Data    : Julho/2013                       Ultima atualizacao: 30/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Gerar relatório com todos os consorcios exibindo o status
  --
  --  Alterações: 30/04/2018 - Conversão Progress --> Oracle PLSQL (Teobaldo Jamunda - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  
    vr_cdcooper     crapcop.cdcooper%TYPE;
    vr_idx          INTEGER;
    vr_exc_erro     EXCEPTION;
      
    -- Variavel de Controle de XML
    vr_cns_xml      CLOB := EMPTY_CLOB;
    vr_sim_xml      CLOB := EMPTY_CLOB;
    vr_nao_xml      CLOB := EMPTY_CLOB;
    vr_path_arquivo VARCHAR2(1000);
    vr_dspathcop    VARCHAR2(4000);
    vr_conteudo     VARCHAR2(4000);
    vr_efetuado     VARCHAR2(20);
    vr_nmrelato     VARCHAR2(40);
    vr_cdrelato     NUMBER;

    -- Procedure que escreve linha no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_clob_xml  IN OUT NOCOPY CLOB,
                             pr_cns_dados IN VARCHAR2) IS
    BEGIN
      -- Escrever no arquivo CLOB
      dbms_lob.writeappend(pr_clob_xml, length(pr_cns_dados), pr_cns_dados);
    END;

  BEGIN

    -- Se a tabela temporaria possuir registros, eles serao processados
    IF pr_tab_cons.count > 0 THEN

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_cns_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_cns_xml, dbms_lob.lob_readwrite);

      -- Inicializar o CLOB Auxiliar - Nao Efetuado
      dbms_lob.createtemporary(vr_nao_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_nao_xml, dbms_lob.lob_readwrite);

      -- Inicializar o CLOB Auxiliar - Efetuado
      dbms_lob.createtemporary(vr_sim_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_sim_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geracao do XML
      -------------------------------------------
      pc_escreve_xml(vr_cns_xml, '<?xml version="1.0" encoding="utf-8"?><crrl663>');

      -- Posiciona no primeiro registro
      vr_idx := pr_tab_cons.FIRST;

      -- Inicia loop
      LOOP
        -- Sai quando a chave atual for null (chegou no final)
        EXIT WHEN vr_idx IS NULL;

        -- se é o primeiro registro, guarda o codigo da cooperativa para geracao do arquivo
        IF vr_idx = pr_tab_cons.FIRST THEN
          vr_cdcooper := pr_tab_cons(vr_idx).cdcooper;
        END IF;
        
        IF pr_tab_cons(vr_idx).flgdebit = 0 THEN 
          vr_efetuado := 'NAO EFETUADOS';
        ELSE
          vr_efetuado := 'EFETUADOS';
        END IF;
        
        vr_conteudo := '<chave nrchave="'||pr_tab_cons(vr_idx).chave || '">' ||
                         '<cdcooper>'|| pr_tab_cons(vr_idx).cdcooper || '</cdcooper>' ||
                         '<nrdconta>'|| trim(GENE0002.fn_mask_conta(pr_tab_cons(vr_idx).nrdconta)) || '</nrdconta>' ||
                         '<dsconsor>'|| pr_tab_cons(vr_idx).dsconsor || '</dsconsor>' ||
                         '<nrcotcns>'|| trim(GENE0002.fn_mask_conta(pr_tab_cons(vr_idx).nrcotcns)) || '</nrcotcns>' ||
                         '<qtparcns>'|| pr_tab_cons(vr_idx).qtparcns || '</qtparcns>' ||
                         '<vlrcarta>'|| pr_tab_cons(vr_idx).vlrcarta || '</vlrcarta>' ||
                         '<vlparcns>'|| pr_tab_cons(vr_idx).vlparcns || '</vlparcns>' ||
                         '<dscooper>'|| pr_tab_cons(vr_idx).dscooper || '</dscooper>' ||
                         '<nmprimtl>'|| pr_tab_cons(vr_idx).nmprimtl || '</nmprimtl>' ||
                         '<nrctacns>'|| trim(GENE0002.fn_mask_conta(pr_tab_cons(vr_idx).nrctacns)) || '</nrctacns>' ||
                         '<cdagenci>'|| pr_tab_cons(vr_idx).cdagenci || '</cdagenci>' ||
                         '<flgdebit>'|| pr_tab_cons(vr_idx).flgdebit || '</flgdebit>' ||
                         '<efetuado>'|| vr_efetuado || '</efetuado>' ||
                         '<dscritic>'|| nvl(pr_tab_cons(vr_idx).dscritic,' ') || '</dscritic>' ||
                         '<nrdocmto>'|| lpad(pr_tab_cons(vr_idx).nrdocmto,22,'0') || '</nrdocmto>' ||
                         '<nrdgrupo>'|| lpad(pr_tab_cons(vr_idx).nrdgrupo,6, '0') || '</nrdgrupo>' ||
                         '<nrctrato>'|| pr_tab_cons(vr_idx).nrctrato || '</nrctrato>' ||
                         '<tpconsor>'|| pr_tab_cons(vr_idx).tpconsor || '</tpconsor>' ||
                       '</chave>';
        
        -- Armazena em CLOB distintos, devido ordenacao do relatorio
        IF pr_tab_cons(vr_idx).flgdebit = 0 THEN
          pc_escreve_xml(vr_nao_xml, vr_conteudo);
        ELSE
          pc_escreve_xml(vr_sim_xml, vr_conteudo);
        END IF;
        
        -- Buscar o próximo registro da tabela
        vr_idx := pr_tab_cons.NEXT(vr_idx);

      END LOOP;

      -- Juncao dos dados em CLOB de Consorcio com debito 
      -- NAO Efetuados (vr_nao_xml) e Efetuados (vr_sim_xml)
      dbms_lob.append(vr_cns_xml, vr_nao_xml);
      dbms_lob.append(vr_cns_xml, vr_sim_xml);
      
      -- Liberando a memoria alocada para CLOB auxiliares
      dbms_lob.close(vr_nao_xml);
      dbms_lob.freetemporary(vr_sim_xml);

      -- Finalizando o arquivo xml
      pc_escreve_xml(vr_cns_xml,'</crrl663>');
      
      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'rl'); --> Gerado no diretorio /rl

      -- Durante o processo gera o 663
      vr_nmrelato := 'crrl663_' || to_char( gene0002.fn_busca_time ) || '.lst';
      vr_cdrelato := 663;

      -- gerar copia em rlnsv
      vr_dspathcop := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rlnsv'); --> Gerado no diretorio /rlnsv

      -- Gerando o relatório nas pastas /rl e /rlnsv
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                 ,pr_cdprogra  => pr_cdprogra
                                 ,pr_dtmvtolt  => pr_dtmvtolt
                                 ,pr_dsxml     => vr_cns_xml
                                 ,pr_dsxmlnode => '/crrl663/chave'
                                 ,pr_dsjasper  => 'crrl663.jasper'
                                 ,pr_dsparams  => 'PR_NMDESTIN##ADMINISTRATIVO@@'
                                 ,pr_dsarqsaid => vr_path_arquivo ||'/'|| vr_nmrelato
                                 ,pr_flg_gerar => 'N'             --> job ira gerar relatorio
                                 ,pr_qtcoluna  => 234
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => vr_cdrelato
                                 ,pr_flg_impri => CASE upper(pr_cdprogra) 
                                                    WHEN 'CRPS663' THEN 'S' 
                                                    ELSE 'N'
                                                  END
                                 ,pr_nmformul  => '234col'
                                 ,pr_nrcopias  => 1
                                 ,pr_dspathcop => vr_dspathcop
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_nrvergrl  => 1               --> Nr versao da funcao de geracao relatorio
                                 ,pr_des_erro  => pr_dscritic);

      -- Liberando a memória alocada para CLOB principal
      dbms_lob.close(vr_cns_xml);
      dbms_lob.freetemporary(vr_cns_xml);
    END IF;

    pr_nmrelato:= vr_nmrelato;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- retorna erro tratado
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := pr_dscritic;

    WHEN OTHERS THEN
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado em CNSO0001.pc_gera_relatorio --> '||SQLERRM;
  END pc_gera_relatorio;


  /* Procedimento para criar registros na crapndb */
  PROCEDURE pc_gera_crapndb (pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                            ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE        --> Numero da conta
                            ,pr_cdempres  IN craplau.cdempres%TYPE        --> Código da empresa
                            ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE        --> Documento
                            ,pr_nrctacns  IN crapass.nrctacns%TYPE        --> Conta consórcio
                            ,pr_vllanaut  IN craplau.vllanaut%TYPE        --> Valor do lancemento
                            ,pr_cdagenci  IN crapass.cdagenci%TYPE        --> Agencia do cooperado PA
                            ,pr_cdseqtel  IN craplau.cdseqtel%TYPE        --> Sequencial
                            ,pr_cdhistor  IN craplau.cdhistor%TYPE        --> Codigo do historico
                            ,pr_cdcritic  IN OUT crapcri.cdcritic%TYPE    --> Codigo da critica de erro
                            ,pr_dscritic     OUT VARCHAR2) IS             --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gera_crapndb   (origem: cria-crapndb - crps663.i)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Ranghetti
  --   Data    : Maio/2014                       Ultima atualizacao: 26/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Gerar informacoes na crapndb
  --
  --  Alterações: 26/04/2018 - Incluido parametro pr_cdhistor (Debitador Unico - Teobaldo J, AMcom)
  --
  --------------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      -- VARIAVEIS
      vr_nrctasic crapcop.nrctasic%TYPE;
      vr_cdagenci crapage.cdagenci%TYPE;
      vr_dstexarq VARCHAR2(200) := '';
      
      -- VARIAVEIS PARA CAULCULO DE DIGITOS A COMPLETAR COM ZEROS OU ESPAÇOS
      vr_resultado VARCHAR2(25);

    -- VARIAVEIS DE ERRO
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_critica  crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);

      -- VARIAVEIS DE EXCECAO
      vr_exc_erro EXCEPTION;
      vr_exc_saida EXCEPTION;

    -- CURSORES
    -- Busca dados da cooperativa
    CURSOR cr_crapcop2 IS
      SELECT cop.cdagesic
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop2 cr_crapcop2%ROWTYPE;

    -- Buscar dados da empresa conveniada
    CURSOR cr_crapscn (pr_cdempres crapscn.cdempres%TYPE) IS
      SELECT scn.qtdigito
            ,scn.cdempres
            ,scn.tppreenc
        FROM crapscn scn
       WHERE scn.cdempres = pr_cdempres;
     rw_crapscn cr_crapscn%ROWTYPE;

   BEGIN

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop2;
      FETCH cr_crapcop2 INTO rw_crapcop2;

      -- Se nao encontrar
      IF cr_crapcop2%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop2;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
       -- gravar agencia do sicredi na cooperativa em variavel
        vr_nrctasic := gene0002.fn_mask(rw_crapcop2.cdagesic,'9999');
       CLOSE cr_crapcop2;
      END IF;

      -- tributos do convenio SICREDI
      OPEN cr_crapscn (pr_cdempres => pr_cdempres);
      FETCH cr_crapscn INTO rw_crapscn;
      -- SE NAO ENCONTRAR REGISTRO
      IF cr_crapscn%NOTFOUND THEN
        --apenas fecha cursor
        CLOSE cr_crapscn;
      END IF;

      -- fazer o calculo de quantos digitos devera completar com espacos ou zeros
      -- Atribuir resultado com a quantidade de digitos da base
      IF rw_crapscn.tppreenc = 1 THEN
        IF rw_crapscn.qtdigito <> 0 THEN
          vr_resultado := LPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0') ;
        ELSE
          vr_resultado := LPAD(pr_nrdocmto,25,'0') ;
        END IF;
      ELSIF rw_crapscn.tppreenc = 2 THEN
        IF rw_crapscn.qtdigito <> 0 THEN
          vr_resultado := RPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0') ;
        ELSE
          vr_resultado := RPAD(pr_nrdocmto,25,'0') ;
        END IF;
      ELSE
        IF rw_crapscn.qtdigito <> 0 THEN
          vr_resultado :=  RPAD(pr_nrdocmto,rw_crapscn.qtdigito,' ');
        ELSE
          vr_resultado := RPAD(pr_nrdocmto,25,' ') ;
        END IF;
      END IF;

      IF LENGTH(vr_resultado) < 25 THEN
        -- completar com 25 espaços se resultado for inferior a 25 poscoes
        vr_resultado := RPAD(vr_resultado,25,' ');
      END IF;

      /* Se for o convenio 045 - 14 BRT CELULAR - FEBRABAN e tiver 11 posicoes, devemos
         adicionar um hifen para completar 12 posicoes ex:(40151016407-) chamado 453337 */
      IF pr_cdempres = '045' AND LENGTH(pr_nrdocmto) = 11 THEN
        vr_resultado := RPAD(pr_nrdocmto,12,'-') || RPAD(' ',13,' ');
      END IF;

      /* regra tipo de critica */
      IF NVL(pr_cdcritic,0) IN (64, 9, 454) THEN
         vr_critica := 15;    /** Conta corrente invalida  **/
      ELSE
         vr_critica := 1;     /** Insuficiencias de fundos **/
      END IF;

      vr_cdagenci :=  SUBSTR(gene0002.fn_mask(pr_cdagenci,'999'),2,2);

      vr_dstexarq := 'F' || vr_resultado ||
                     gene0002.fn_mask(vr_nrctasic,'9999') ||
                     gene0002.fn_mask(pr_nrctacns,'999999') ||
                     gene0002.fn_mask('','zzzzzzzz') ||
                     TO_CHAR(pr_dtmvtolt,'yyyy') ||
                     TO_CHAR(pr_dtmvtolt,'mm') ||
                     TO_CHAR(pr_dtmvtolt,'dd') ||
                     LPAD((pr_vllanaut*100),15,'0') ||
                     LPAD(vr_critica,2,'0') ||
                     LPAD(pr_cdseqtel,60, ' ') ||
                     RPAD(' ',16) ||
                     gene0002.fn_mask(vr_cdagenci,'99') ||
                     RPAD(TRIM(rw_crapscn.cdempres),10,' ') || '0';

        BEGIN
          -- INSERE REGISTRO NA TABELA DE REGISTROS DE DEBITO EM CONTA NAO EFETUADOS
          INSERT INTO crapndb(dtmvtolt,
                              nrdconta,
                              cdhistor,
                              flgproce,
                              cdcooper,
                              dstexarq)
                       VALUES(pr_dtmvtolt,
                              pr_nrdconta,
                              Nvl(pr_cdhistor, 1019),
                              0,           -- 0 false
                              pr_cdcooper,
                              vr_dstexarq);
            
        -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPNDB: ' || sqlerrm;
            RAISE vr_exc_erro;
        END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= NVL(vr_dscritic, gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic));
      WHEN OTHERS THEN
        -- Retorna o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado em CNSO0001.pc_gera_crapndb --> '||SQLERRM;
    END;

  END pc_gera_crapndb;  


  /* Procedure para gerar log da execucao */
  PROCEDURE pc_gera_log_execucao (pr_nmprgexe IN  VARCHAR2,
                                  pr_indexecu IN  VARCHAR2,
                                  pr_cdcooper IN  INTEGER,
                                  pr_tpexecuc IN  VARCHAR2,
                                  pr_idtiplog IN  VARCHAR2,              -->  I-Inicio, E-Erro ou F-Fim
                                  pr_nmarqlog IN  VARCHAR2 DEFAULT NULL, --> Nome arquivo log, se NULL assume batch
                                  pr_dscritic OUT VARCHAR2) IS
    vr_nmarqlog VARCHAR2(500);
    vr_desdolog VARCHAR2(2000);
    vr_idtiplog INTEGER;
      
  BEGIN
    --> Definir nome do log
    IF pr_nmarqlog IS NOT NULL THEN
      vr_nmarqlog := pr_nmarqlog;
    ELSE
      vr_nmarqlog := 'prcctl_'||to_char(rw_crapdat.dtmvtolt,'RRRRMMDD')||'.log';
    END IF;
      
    --> Tipo de log
    IF pr_idtiplog in ('I','F') THEN
      vr_idtiplog := 1;  -- Processo Normal
    ELSE
      vr_idtiplog := 2;  -- Erro tratado
    END IF;
      
    --> Definir descrição do log
    vr_desdolog := 'Automatizado - '||to_char(SYSDATE,'HH24:MI:SS')||
                   ' --> Coop.:'|| pr_cdcooper ||' '|| 
                    pr_tpexecuc ||' - '||pr_nmprgexe|| ': '|| pr_indexecu;
                     
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3, 
                               pr_ind_tipo_log => vr_idtiplog, 
                               pr_des_log      => vr_desdolog, 
                               pr_nmarqlog     => vr_nmarqlog,
                               pr_cdprograma   => pr_nmprgexe);
  
  EXCEPTION
    WHEN OTHERS THEN
         pr_dscritic := 'Erro ao gerar log execucao 663 (CNS0001): '||SQLERRM;
  END pc_gera_log_execucao;                                      


END CNSO0001;
/
