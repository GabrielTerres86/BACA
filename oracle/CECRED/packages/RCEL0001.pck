CREATE OR REPLACE PACKAGE CECRED.RCEL0001 AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: RCEL0001
  --    Autor   : Lucas Reinert
  --    Data    : Janeiro/2017                   Ultima Atualizacao: 16/07/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package para centralizar as rotinas de recarga de celular
  --
  --    Alteracoes: 06/06/2017 - Inclusão da função de calculo de repasse
  --                           - Alteração para corrigir reagendamento de job  (Renato Darosci)
  --    
  --                02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --                             crapass, crapttl, crapjur 
  --                              (Adriano - P339).
  --
  --                17/08/2017 - Alteração para ajustar relatório de agendamentos e mensagem do InternetBank 
  --                             para recargas agendadas. (Reinert)
  --
  --                28/09/2017 - Alteração para tratar múltiplas requisições de recargas pelo Android.
  --                             (Reinert)
  --
  --                24/10/2017 - Ajustado data de débito da procedure pc_efetua_recarga. (Reinert)
  -- 
  --                03/11/2017 - Ajuste para tratar agendamentos duplicados. (Reinert)
  --
  --                08/11/2017 - Ajustado tempo para nova solicitação de recarga para 5 minutos na procedure
  --                             pc_confirma_recarga_ib. (Reinert)
  --
  --                09/02/2018 - Alterado para verificar operação de recarga duplicada;
  --                           - Alterada crítica para solicitações de recargas repetidas no TAA. (Reinert)
  --
  --                16/07/2018 - Inclusão do campo dsorigem no retorno da procedure pc_carrega_agend_recarga, Prj. 363 (Jean Michel)
  --
  --                11/02/2019 - Gerar data de movimento da crapltr com sysdate (PRB0040602 - Jose Dill - Mouts)
  --
  --                19/08/2019 - Bloqueio adicional para evitar agendamentos de recarga na data atual (Diógenes - INC0022696)
  --
  ---------------------------------------------------------------------------------------------------------------

  TYPE typ_reg_critic IS
    RECORD (idoperacao INTEGER
           ,situacao   INTEGER -- 1 - Efetuado / 2 - Não efetuado
           ,idorigem   INTEGER
           ,cdagenci   INTEGER
           ,nrdconta   INTEGER
           ,nmprimtl   VARCHAR2(100)
           ,nrcelular  VARCHAR2(20)
           ,operadora  VARCHAR2(100)
           ,vlrecarga  VARCHAR2(100)
           ,cdcritic   INTEGER
           ,dscritic   VARCHAR2(500));

  TYPE typ_tab_critic IS
    TABLE OF typ_reg_critic
    INDEX BY VARCHAR2(100);
  
  TYPE typ_reg_repasse IS
    RECORD (cdcooper  INTEGER
           ,nmrescop  VARCHAR2(100)
           ,operadora VARCHAR2(100)
           ,qtrecarga INTEGER
           ,vlregarga NUMBER
           ,vlreceita NUMBER
           ,vlapagar  NUMBER);
  
  TYPE typ_tab_repasse IS
    TABLE OF typ_reg_repasse
    INDEX BY VARCHAR2(100);
 
	TYPE typ_reg_age_recarga IS
    RECORD(dtrecarga      tbrecarga_operacao.dtrecarga%TYPE
          ,idoperacao     tbrecarga_operacao.idoperacao%TYPE
          ,dttransa       tbrecarga_operacao.dttransa%TYPE
          ,vlrecarga      tbrecarga_operacao.vlrecarga%TYPE
          ,insit_operacao tbrecarga_operacao.insit_operacao%TYPE
					,dssit_operacao VARCHAR2(100)
          ,nrddd          tbrecarga_operacao.nrddd%TYPE
          ,nrcelular      tbrecarga_operacao.nrcelular%TYPE
          ,nmoperadora    tbrecarga_operadora.nmoperadora%TYPE
					,incancel       NUMBER
          ,dscritic VARCHAR2(100)
          ,dsorigem       craplau.dsorigem%TYPE);
		
	TYPE typ_tab_age_recarga IS TABLE OF typ_reg_age_recarga INDEX BY PLS_INTEGER;
 
  -- Busca operadora
  PROCEDURE pc_busca_operadora(pr_cdoperadora    IN  tbrecarga_operadora.cdoperadora%TYPE --> Código da Operadora
                              ,pr_tab_operadoras OUT tbrecarga_operadora%ROWTYPE          --> Record com as informações da operadora
                              ,pr_cdcritic       OUT PLS_INTEGER                          --> Codigo da critica
                              ,pr_dscritic       OUT VARCHAR2);                           --> Descricao da critica
    
	-- Buscar parametros de recarga
	PROCEDURE pc_busca_param_coop(pr_cdcooper   IN  tbrecarga_param.cdcooper%TYPE --> Código da Operadora
		                           ,pr_param_coop OUT tbrecarga_param%ROWTYPE       --> Record com as informações de paramatro da cooperativa
                               ,pr_cdcritic   OUT PLS_INTEGER                   --> Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2);                    --> Descricao da critica

  -- Retorna situação do canal para recarga
	PROCEDURE pc_situacao_canal_recarga(pr_cdcooper IN crapcop.cdcooper%TYPE                 --> Cooperativa
		                                 ,pr_idorigem IN INTEGER                               --> Origem
																		 ,pr_flgsitrc OUT tbrecarga_param.flgsituacao_sac%TYPE --> Situação Canal (0-INATIVO/1-ATIVO)
																		 ,pr_cdcritic OUT PLS_INTEGER                          --> Cód. crítica
																		 ,pr_dscritic OUT VARCHAR2);												   --> Desc. crítica
																		 
	-- Obtem os telefones favoritos do cooperado						 
	PROCEDURE pc_obtem_favoritos_recarga(pr_cdcooper IN crapcop.cdcooper%TYPE
		                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
																			,pr_telfavor OUT CLOB
																			,pr_cdcritic OUT PLS_INTEGER
																			,pr_dscritic OUT VARCHAR2);																		 
	
	-- Obtem operadoras/produtos pare recarga
	PROCEDURE pc_obtem_operadoras_recarga(pr_clobxml OUT CLOB
																			 ,pr_cdcritic OUT PLS_INTEGER
																			 ,pr_dscritic OUT VARCHAR2);
	
	-- Obtem valores de recarga pré-fixados
	PROCEDURE pc_obtem_valores_recarga(pr_cdoperadora IN tbrecarga_valor.cdoperadora%TYPE
		                                ,pr_cdproduto   IN tbrecarga_valor.cdproduto%TYPE
		                                ,pr_clobxml  OUT CLOB
		                                ,pr_cdcritic OUT PLS_INTEGER
																		,pr_dscritic OUT VARCHAR2);
		
	-- Validar recarga de celular
	PROCEDURE pc_valida_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE              -- Cód. cooperativa
		                         ,pr_nrdconta  IN crapass.nrdconta%TYPE              -- Nr. da conta
														 ,pr_idseqttl  IN crapsnh.idseqttl%TYPE              -- Id do titular
														 ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE              -- CPF do operador juridico
														 ,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE      -- DDD
														 ,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE  -- Telefone
                             ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE     -- Valor de recarga
														 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE  -- Data para recarga
														 ,pr_qtmesagd  IN INTEGER                            -- Qtd. meses agendamento
														 ,pr_cddopcao  IN INTEGER                            -- Opção: 1 - Data atual / 2 - Data futura / 3 - Agendamento
														 ,pr_idorigem  IN INTEGER                            -- Indicador de Origem
                               ,pr_cdagenci IN INTEGER                             -- Agencia de Origem
                               ,pr_nrdcaixa IN INTEGER                             -- Caixa de Origem
                               ,pr_nmprogra IN VARCHAR2                            -- Programa que chamou
														 ,pr_lsdatagd OUT VARCHAR2                           -- Lista de datas agendadas
														 ,pr_cdcritic OUT PLS_INTEGER                        -- Cód. da crítica
														 ,pr_dscritic OUT VARCHAR2);                         -- Desc. da crítica
	
  -- Procedure para manter recarga de celular (Efetivação/Transação Pendente)
	PROCEDURE pc_manter_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cód. cooperativa
		                         ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Nr. da conta
														 ,pr_idseqttl  IN crapttl.idseqttl%TYPE -- Id. do titular
														 ,pr_nrcpfope  IN crapsnh.nrcpfcgc%TYPE -- Nr. CPF operador
														 ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
														 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE -- Data de recarga
														 ,pr_lsdatagd  IN VARCHAR2 -- Lista de datas para agendamento
														 ,pr_cddopcao  IN INTEGER  -- Cód. da opção (1-Data atual / 2-Data futura / 3-Agendamento mensal)
														 ,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE -- Nr. DDD
														 ,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE -- Nr. Telefone
														 ,pr_cdopetel  IN tbrecarga_operadora.cdoperadora%TYPE -- Cód. operadora
														 ,pr_cdprodut  IN tbrecarga_produto.cdproduto%TYPE     -- Cód. produto														 
														 ,pr_cdcoptfn  IN crapcop.cdcooper%TYPE -- Cód. da cooperativa do terminal financeiro (Apenas TAA)
														 ,pr_cdagetfn  IN crapage.cdagenci%TYPE -- Cód. da agencia do terminal financeiro (Apenas TAA)
														 ,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro (Apenas TAA)
                             ,pr_nrcartao  IN NUMBER                -- Nr. do cartao (Apenas TAA)
														 ,pr_nrsequni  IN INTEGER               -- Nr. sequencial único (Apenas TAA)														 
														 ,pr_idorigem  IN INTEGER               -- Id. origem (3-IB / 4-TAA)
                             ,pr_cdagenci  IN INTEGER               -- Agencia da Transação
                             ,pr_nrdcaixa  IN INTEGER               -- Caixa da Transação
                             ,pr_nmprogra  IN VARCHAR2              -- Nome do Programa que chamou
														 ,pr_inaprpen  IN NUMBER                -- Indicador de aprovação de transacao pendente
														 ,pr_idoperac  IN tbrecarga_operacao.idoperacao%TYPE -- Id. operação (Somente na efetivação do agendamento e aprovação de transação pendente)
                             ,pr_flmobile  IN NUMBER                -- Indicador se origem é mobile
                             ,pr_dslancto OUT VARCHAR2              -- Lista com todos os ID operação dos agendamentos criados
                             ,pr_idastcjt OUT INTEGER               -- Se possui assinatura														 
														 ,pr_dsprotoc OUT VARCHAR2              -- Protocolo
														 ,pr_dsnsuope OUT tbrecarga_operacao.dsnsu_operadora%TYPE -- NSU Operadora														 
														 ,pr_cdcritic OUT PLS_INTEGER           -- Cód. da crítica
														 ,pr_dscritic OUT VARCHAR2);            -- Desc. da crítica	
														 
  -- Procedure para efetuar recarga de celular
	PROCEDURE pc_efetua_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cód. operadora
		                         ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Nr. da conta
														 ,pr_idseqttl  IN INTEGER -- Id. titular
														 ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
														 ,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE -- DDD
														 ,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE -- Telefone
														 ,pr_cdproduto IN tbrecarga_produto.cdproduto%TYPE -- Cód. produto
														 ,pr_cdopetel  IN tbrecarga_operadora.cdoperadora%TYPE -- Cód. operadora
														 ,pr_idoperac  IN tbrecarga_operacao.idoperacao%TYPE -- Id. operação (Somente na efetivação do agendamento e aprovação de transação pendente)
														 ,pr_nrcpfope  IN crapsnh.nrcpfcgc%TYPE -- Nr. CPF operador
														 ,pr_cdcoptfn  IN craptfn.cdcooper%TYPE -- Coopertaiva do terminal financeiro
														 ,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro
														 ,pr_nrcartao  IN DECIMAL               -- Nr. do cartão
                               ,pr_nrsequni  IN INTEGER               -- Nr. sequencial único (Apenas TAA)
														 ,pr_idorigem  IN INTEGER -- Id. origem
                               ,pr_cdagenci  IN INTEGER -- Agencia da transação
                               ,pr_nrdcaixa  IN INTEGER -- Caixa da transação
                               ,pr_nmprogra  IN VARCHAR2 -- Programa que chamou
                             ,pr_flmobile  IN NUMBER                -- Indicador se origem é mobile
														 ,pr_nsuopera  OUT tbrecarga_operacao.dsnsu_operadora%TYPE -- NSU operadora
														 ,pr_dsprotoc  OUT VARCHAR2                                -- Protocolo
														 ,pr_cdcritic  OUT PLS_INTEGER -- Cód. crítica
														 ,pr_dscritic  OUT VARCHAR2);  -- Desc. crítica
	
	-- Cadastrar agendamento de recarga
	PROCEDURE pc_cadastra_agendamento(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
		                               ,pr_nrdconta IN crapass.nrdconta%TYPE   -- Nr. da conta
																	 ,pr_cdoperad IN crapope.cdoperad%TYPE   -- Operador
																	 ,pr_nrcpfope IN crapsnh.nrcpfcgc%TYPE   -- Nr. do cpf do operador da conta
																	 ,pr_idseqttl IN INTEGER                 -- Titular
																	 ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
																	 ,pr_nrdddtel IN tbrecarga_favorito.nrddd%TYPE   -- DDD
																	 ,pr_nrtelefo IN tbrecarga_favorito.nrcelular%TYPE -- Telefone
																	 ,pr_cdproduto IN tbrecarga_produto.cdproduto%TYPE -- Cód. do produto
																	 ,pr_cdoperadora IN tbrecarga_operacao.cdoperadora%TYPE -- Cód. operadora
																	 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE -- Data de recarga
																	 ,pr_lsdatagd IN VARCHAR2 DEFAULT NULL             -- Lista de datas para agendamento
																	 ,pr_idorigem IN INTEGER                            -- Id. de origem
                                     ,pr_nmprogra IN VARCHAR2                           -- Nome do Programa
																	 ,pr_idoperac IN tbrecarga_operacao.idoperacao%TYPE -- Id. operação (Somente na aprovação de transação pendente)																	 
                                     ,pr_dslancto OUT VARCHAR2                          -- Lista de ID Operação
																	 ,pr_cdcritic OUT PLS_INTEGER                       -- Cód. da crítica
																	 ,pr_dscritic OUT VARCHAR2);                        -- Desc. da crítica	
																	 
	-- Solicitar produtos para o Aymaru
  PROCEDURE pc_job_solicita_produtos;

	-- Carrega os agendamentos de recarga de celular
  PROCEDURE pc_carrega_agend_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                    ,pr_situacao  IN INTEGER 
                                    ,pr_dtinicial IN DATE
                                    ,pr_dtfinal   IN DATE																		
                                    ,pr_tab_age_recarga  OUT typ_tab_age_recarga
																		,pr_qttotage OUT NUMBER
                                    ,pr_cdcritic OUT PLS_INTEGER
                                    ,pr_dscritic OUT VARCHAR2);

  -- Atualizar os produtos de recarga através do Aymaru	
	PROCEDURE pc_atualiza_produtos_recarga(pr_xmlrequi IN xmltype
																				,pr_cdcritic IN OUT NUMBER
																				,pr_dscritic IN OUT VARCHAR2
																				,pr_dsdetcri IN OUT VARCHAR2);
																				
	-- Obtem os agendamentos de recarga de celular
  PROCEDURE pc_obtem_agendamentos_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                         ,pr_origem    IN INTEGER
                                         ,pr_situacao  IN INTEGER 
                                         ,pr_dtinicial IN DATE
                                         ,pr_dtfinal   IN DATE
                                         ,pr_clobxml  OUT CLOB
                                         ,pr_cdcritic OUT PLS_INTEGER
                                         ,pr_dscritic OUT VARCHAR2);
						
	-- Cancelar agendamentos de recarga de celular
  PROCEDURE pc_cancela_agendamento_recarga(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                          ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                          ,pr_idseqttl   IN crapttl.idseqttl%TYPE
                                          ,pr_idorigem   IN INTEGER
                                          ,pr_idoperacao IN INTEGER 
                                          ,pr_nmprogra   IN VARCHAR2
                                          ,pr_cdcritic  OUT PLS_INTEGER
                                          ,pr_dscritic  OUT VARCHAR2);	
	
  -- Exclui favorito do cooperado
	PROCEDURE pc_excluir_favorito(pr_cdcooper IN crapcop.cdcooper%TYPE
		                           ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_nrddd     IN tbrecarga_favorito.nrddd%TYPE
                               ,pr_nrcelular IN tbrecarga_favorito.nrcelular%TYPE
															 ,pr_cdcritic OUT PLS_INTEGER
														 	 ,pr_dscritic OUT VARCHAR2);
                               
  -- Cadastra favorito do cooperado
  PROCEDURE pc_cadastra_favorito(pr_cdcooper  IN crapcop.cdcooper%TYPE
		                            ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                ,pr_nrddd     IN tbrecarga_favorito.nrddd%TYPE
                                ,pr_nrcelular IN tbrecarga_favorito.nrcelular%TYPE
                                ,pr_nmcontato IN tbrecarga_favorito.nmcontato%TYPE
                                ,pr_cdcritic OUT PLS_INTEGER
                                ,pr_dscritic OUT VARCHAR2);
  
  -- Confirma recarga de celular
  PROCEDURE pc_confirma_recarga_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                  ,pr_idseqttl   IN crapttl.idseqttl%TYPE
                                  ,pr_nrcpfope   IN crapsnh.nrcpfcgc%TYPE
                                  ,pr_nrddd      IN tbrecarga_favorito.nrddd%TYPE
                                  ,pr_nrcelular  IN tbrecarga_favorito.nrcelular%TYPE
                                  ,pr_nmcontato  IN tbrecarga_favorito.nmcontato%TYPE
                                  ,pr_flgfavori  IN INTEGER
                                  ,pr_vlrecarga  IN tbrecarga_valor.vlrecarga%TYPE
                                  ,pr_operadora  IN tbrecarga_operadora.cdoperadora%TYPE
                                  ,pr_produto    IN tbrecarga_produto.cdproduto%TYPE
                                  ,pr_cddopcao   IN INTEGER
                                  ,pr_dtrecarga  IN tbrecarga_operacao.dtrecarga%TYPE
                                  ,pr_qtmesagd   IN INTEGER    
                                  ,pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE
                                  ,pr_inaprpen   IN NUMBER
                                  ,pr_flmobile   IN NUMBER
                                  ,pr_idorigem IN INTEGER -- Indicador de Origem
                                  ,pr_cdagenci IN INTEGER -- Agencia de Origem
                                  ,pr_nrdcaixa IN INTEGER -- Caixa de Origem
                                  ,pr_nmprogra IN VARCHAR2 -- Programa que chamou
                                  ,pr_cdcoptfn  IN crapcop.cdcooper%TYPE -- Cód. da cooperativa do terminal financeiro (Apenas TAA)
                                  ,pr_cdagetfn  IN crapage.cdagenci%TYPE -- Cód. da agencia do terminal financeiro (Apenas TAA)
                                  ,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro (Apenas TAA)
                                  ,pr_nrcartao  IN NUMBER                -- Nr. do cartao (Apenas TAA)
                                  ,pr_xml_idlancto OUT VARCHAR2 -- Lista com todos os agendamentos
                                  ,pr_msg_retor OUT VARCHAR2
                                  ,pr_cdcritic  OUT PLS_INTEGER
                                  ,pr_dscritic  OUT VARCHAR2);
  
  -- Buscar dados da recarga no Progress 
  PROCEDURE pc_busca_recarga_prog(pr_idoperacao IN INTEGER
                                 ,pr_resposta  OUT CHAR
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2);
  
  -- Gera relatorio de criticas
  PROCEDURE pc_gera_rel_criticas(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                ,pr_tab_critic IN typ_tab_critic
                                ,pr_crapdat    IN BTCH0001.cr_crapdat%ROWTYPE
                                ,pr_nmdatela   IN VARCHAR2
                                ,pr_cdcritic  OUT PLS_INTEGER
                                ,pr_dscritic  OUT VARCHAR2);
  
  -- Processar agendamentos de recarga de celular
  PROCEDURE pc_proces_agendamentos_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                          ,pr_nmdatela  IN VARCHAR2
                                          ,pr_cdcritic OUT PLS_INTEGER
                                          ,pr_dscritic OUT VARCHAR2);
  
  -- Efetuar o repasse para a rede Tendência
  PROCEDURE pc_job_efetua_repasse;
  
END RCEL0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RCEL0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: RCEL0001
  --    Autor   : Lucas Reinert
  --    Data    : Janeiro/2017                   Ultima Atualizacao: 16/07/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package para centralizar as rotinas de recarga de celular
  --
  --    Alteracoes: 06/06/2017 - Inclusão da função de calculo de repasse
  --                           - Alteração para corrigir reagendamento de job  (Renato Darosci)
  --    
  --                02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --                             crapass, crapttl, crapjur 
  --           		  				     (Adriano - P339).
	--
  --                17/08/2017 - Alteração para ajustar relatório de agendamentos e mensagem do InternetBank 
  --                             para recargas agendadas. (Reinert)
  --
  --				        28/09/2017 - Alteração para tratar múltiplas requisições de recargas pelo Android.
  --							               (Reinert)
  --
  --                24/10/2017 - Ajustado data de débito da procedure pc_efetua_recarga. (Reinert)
	-- 
	--                03/11/2017 - Ajuste para tratar agendamentos duplicados. (Reinert)
	--
	--                08/11/2017 - Ajustado tempo para nova solicitação de recarga para 5 minutos na procedure
  --                             pc_confirma_recarga_ib. (Reinert)
  --
	--                09/02/2018 - Alterado para verificar operação de recarga duplicada;
	--                           - Alterada crítica para solicitações de recargas repetidas no TAA. (Reinert)
  --                16/04/2018 - Incluido a chamada do programa gen_debitador_unico.pc_qt_hora_prg_debitador
  --                             para  atualizar a quantidade de execução que esta agendada no Debitador
  --                             Projeto Debitador Unico - Josiane Stiehler (AMcom)

  --
  --                16/07/2018 - Inclusão do campo dsorigem no retorno da procedure pc_carrega_agend_recarga, Prj. 363 (Jean Michel)
  --
  --                15/02/2019 - Gerar data de movimento da crapltr com o dia útil correto (PRB0040602 - Jose Dill - Mouts)
  --
  --                19/08/2019 - Bloqueio adicional para evitar agendamentos de recarga na data atual (Diógenes - INC0022696)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Objetos para armazenar as variáveis da notificação
  vr_variaveis_notif NOTI0001.typ_variaveis_notif;
  
  /* CONSTANTES */
  ORIGEM_AGEND_NAO_EFETIVADO CONSTANT tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 5;
  MOTIVO_RECARGA_CELULAR     CONSTANT tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 3;
  
  FUNCTION fn_calcula_proximo_repasse(pr_cdcooper IN NUMBER
                                     ,pr_dtrefere IN DATE) RETURN DATE IS
    /* .............................................................................
    Programa: fn_calcula_proximo_repasse
    Sistema : Ayllos Web
    Autor   : Renato Darosci
    Data    : Junho/2017                 Ultima atualizacao:

    Objetivo  : Função para calcular a data do próximo repasse

    Alteracoes: -----
    ..............................................................................*/
  
    -- Variáveis
    vr_nrdiasmn  NUMBER;
    vr_dtdebase  DATE;

  BEGIN
    -- Extrai o dia da semana do parametro recebidos
    vr_nrdiasmn := TO_CHAR(pr_dtrefere,'D','NLS_DATE_LANGUAGE=AMERICAN'); -- Fixado NLS para evitar erros
    
    -- Se o dia estiver entre segunda-feira e sábado
    IF vr_nrdiasmn BETWEEN 2 AND 7 THEN
      -- Utilizar o primeiro dia da proxima semana como data de base para buscar a data específica
      vr_dtdebase := TRUNC(pr_dtrefere,'D') + 7; 
    ELSE 
      -- Utilizar como data base o primeiro dia da semana
      vr_dtdebase := TRUNC(pr_dtrefere,'D'); 
    END IF;

    -- Percorre os dias da semana, até e
    LOOP
      -- Se o dia se refere à quinta-feira (utilizando NLS para evitar divergencia de calendários)
      IF TO_CHAR(vr_dtdebase,'FMDAY','NLS_DATE_LANGUAGE=AMERICAN') = 'THURSDAY' THEN
        -- Encerra o LOOP pois encontrou a data a ser retornada
        EXIT; 
      END IF;
      
      -- Utiliza o próximo dia para verificação
      vr_dtdebase := vr_dtdebase + 1;
    END LOOP;
    
    -- Depois de encontrar a data... verifica se é dia útil
    vr_dtdebase := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtdebase);
    
    -- Retorna a data encontrada
    RETURN vr_dtdebase;
  
  END fn_calcula_proximo_repasse;
  
  
  PROCEDURE pc_busca_operadora(pr_cdoperadora    IN  tbrecarga_operadora.cdoperadora%TYPE --> Código da Operadora
		                          ,pr_tab_operadoras OUT tbrecarga_operadora%ROWTYPE          --> Record com as informações da operadora
                              ,pr_cdcritic       OUT PLS_INTEGER                          --> Codigo da critica
                              ,pr_dscritic       OUT VARCHAR2) IS                         --> Descricao da critica
  BEGIN
    /* .............................................................................
    Programa: pc_busca_operadora
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados da operadora

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Busca informações da operadora
      CURSOR cr_operadoras(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE) IS
			  SELECT opr.*
				  FROM tbrecarga_operadora opr
				 WHERE opr.cdoperadora = pr_cdoperadora;

    BEGIN
      -- Busca operadora
      OPEN cr_operadoras(pr_cdoperadora);
			FETCH cr_operadoras INTO pr_tab_operadoras;
			
			-- Se não encontrou
			IF cr_operadoras%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_operadoras;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Operadora não encontrada';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
      -- Fecha cursor
			CLOSE cr_operadoras;
			
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;


      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;

  END pc_busca_operadora;
  
	PROCEDURE pc_busca_param_coop(pr_cdcooper   IN  tbrecarga_param.cdcooper%TYPE --> Código da Operadora
		                           ,pr_param_coop OUT tbrecarga_param%ROWTYPE   --> Record com as informações de paramatro da cooperativa
                               ,pr_cdcritic   OUT PLS_INTEGER                   --> Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2) IS                  --> Descricao da critica
  BEGIN
    /* .............................................................................
    Programa: pc_busca_param_coop
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os parametros de recarga de celulares das
		            cooperativas singulares

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Busca informações da operadora
      CURSOR cr_param_coop(pr_cdcooper IN tbrecarga_param.cdcooper%TYPE) IS
			  SELECT tpar.cdcooper
				      ,tpar.flgsituacao_taa
				      ,tpar.flgsituacao_sac
							,tpar.flgsituacao_ib
							,tpar.vlmaximo_pf
							,tpar.vlmaximo_pj
				  FROM tbrecarga_param tpar
				 WHERE tpar.cdcooper = pr_cdcooper;

    BEGIN
      -- Busca operadora
      OPEN cr_param_coop(pr_cdcooper);
			FETCH cr_param_coop INTO pr_param_coop;
			
			-- Se não encontrou
			IF cr_param_coop%NOTFOUND THEN
        -- Devemos enviar informações "zeradas"
				pr_param_coop.flgsituacao_taa := 0;
				pr_param_coop.flgsituacao_sac := 0;
				pr_param_coop.flgsituacao_ib  := 0;
				pr_param_coop.vlmaximo_pf     := 0;
				pr_param_coop.vlmaximo_pj     := 0;				
			END IF;
      -- Fecha cursor
			CLOSE cr_param_coop;
			
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;

  END pc_busca_param_coop;
  	
	PROCEDURE pc_situacao_canal_recarga(pr_cdcooper IN crapcop.cdcooper%TYPE                 --> Cooperativa
		                                 ,pr_idorigem IN INTEGER                               --> Origem
																		 ,pr_flgsitrc OUT tbrecarga_param.flgsituacao_sac%TYPE --> Situação Canal (0-INATIVO/1-ATIVO)
																		 ,pr_cdcritic OUT PLS_INTEGER                          --> Cód. crítica
																		 ,pr_dscritic OUT VARCHAR2) IS												 --> Desc. crítica
  BEGIN
    /* .............................................................................
    Programa: pc_situacao_canal_recarga
    Sistema : CERED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar situação da recarga de celular no canal

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
			-- Verificar situação da recarga do canal 
			CURSOR cr_recparam(pr_cdcooper IN tbrecarga_param.cdcooper%TYPE)IS
			  SELECT tpar.flgsituacao_sac
				      ,tpar.flgsituacao_taa
				      ,tpar.flgsituacao_ib
				  FROM tbrecarga_param tpar
				 WHERE tpar.cdcooper = pr_cdcooper;
			rw_recparam cr_recparam%ROWTYPE;
			
		BEGIN
			-- Verificar situação da recarga do canal 
			OPEN cr_recparam(pr_cdcooper => pr_cdcooper);
			FETCH cr_recparam INTO rw_recparam;
			CLOSE cr_recparam;
			
			IF pr_idorigem = 3 THEN --> IBANK / MOBILE
				pr_flgsitrc := nvl(rw_recparam.flgsituacao_ib,0);
			ELSIF pr_idorigem = 4 THEN --> TAA
				pr_flgsitrc := nvl(rw_recparam.flgsituacao_taa,0);
			ELSIF pr_idorigem = 5 THEN --> AYLLOS WEB
				pr_flgsitrc := nvl(rw_recparam.flgsituacao_sac,0);
			ELSE 
				pr_flgsitrc := 0;
			END IF;
		  
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;
  END pc_situacao_canal_recarga;
	
	PROCEDURE pc_obtem_favoritos_recarga(pr_cdcooper IN crapcop.cdcooper%TYPE
		                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
																			,pr_telfavor OUT CLOB
																			,pr_cdcritic OUT PLS_INTEGER
																			,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_obtem_favoritos_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os telefones favoritos do cooperado

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
			
			-- Verificar situação da recarga do canal 
			CURSOR cr_telfavor(pr_cdcooper IN tbrecarga_favorito.cdcooper%TYPE
			                  ,pr_nrdconta IN tbrecarga_favorito.nrdconta%TYPE)IS
        SELECT tfav.nrddd
				      ,tfav.nrcelular
							,tfav.cdseq_favorito
							,tfav.nmcontato
				  FROM tbrecarga_favorito tfav
				 WHERE tfav.cdcooper = pr_cdcooper
				   AND tfav.nrdconta = pr_nrdconta
				 ORDER BY tfav.cdseq_favorito;
			
		BEGIN
      -- Criar documento XML
      dbms_lob.createtemporary(pr_telfavor, TRUE); 
      dbms_lob.open(pr_telfavor, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_telfavor 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<Raiz>'); 
														 
			-- Buscar telefones favoritos
			FOR rw_telfavor IN cr_telfavor(pr_cdcooper => pr_cdcooper
			                              ,pr_nrdconta => pr_nrdconta) LOOP
        -- Montar clob de retorno
            -- Montar XML com registros de carencia
        gene0002.pc_escreve_xml(pr_xml            => pr_telfavor 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<FAVORITO>' 
                                                  ||   '<nrddd>'    ||rw_telfavor.nrddd    ||'</nrddd>'
                                                  ||   '<nrcelular>'||rw_telfavor.nrcelular||'</nrcelular>'
                                                  ||   '<nmcontato>'||nvl(rw_telfavor.nmcontato, ' ')||'</nmcontato>'
                                                  ||   '<cdseq_favorito>'||rw_telfavor.cdseq_favorito||'</cdseq_favorito>'
                                                  || '</FAVORITO>');
      END LOOP;
       
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_telfavor 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Raiz>' 
                             ,pr_fecha_xml      => TRUE);
			
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_obtem_favoritos_recarga;
	
	PROCEDURE pc_obtem_operadoras_recarga(pr_clobxml OUT CLOB
																			 ,pr_cdcritic OUT PLS_INTEGER
																			 ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_obtem_operadoras_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as operadoras de recarga de celular

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
		  
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
							 
	    -- Cursor para listar os produtos de recarga
		  CURSOR cr_produtos IS
 			  SELECT tprd.cdoperadora
							,tprd.cdproduto				
				      ,tprd.nmproduto
							,tope.nmoperadora
				  FROM tbrecarga_produto tprd
					    ,tbrecarga_operadora tope
				 WHERE tprd.tpproduto = 1 -- Pré fixado
			     AND tope.cdoperadora = tprd.cdoperadora
					 AND tope.flgsituacao = 1;
					 		
		BEGIN
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxml, TRUE); 
      dbms_lob.open(pr_clobxml, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<Raiz>'); 
														 
			-- Buscar telefones favoritos
			FOR rw_produtos IN cr_produtos LOOP
        -- Montar clob de retorno
        -- Montar XML com registros de carencia
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<PRODUTO>' 
                                                  ||   '<cdoperadora>'||rw_produtos.cdoperadora ||'</cdoperadora>'
																									||   '<nmoperadora>'||rw_produtos.nmoperadora ||'</nmoperadora>'
                                                  ||   '<cdproduto>'||rw_produtos.cdproduto||'</cdproduto>'
                                                  ||   '<nmproduto>'||rw_produtos.nmproduto||'</nmproduto>'
                                                  || '</PRODUTO>');
      END LOOP;
       
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Raiz>' 
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																							
	END pc_obtem_operadoras_recarga;
	
	PROCEDURE pc_obtem_valores_recarga(pr_cdoperadora IN tbrecarga_valor.cdoperadora%TYPE
		                                ,pr_cdproduto   IN tbrecarga_valor.cdproduto%TYPE
		                                ,pr_clobxml  OUT CLOB
		                                ,pr_cdcritic OUT PLS_INTEGER
																		,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_obtem_valores_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os valores pré-fixados de recarga

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
		  
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
			
			-- Variáveis auxiliares
      vr_dtmvtolt  DATE;
			
			-- Buscar último valor atualizado do produto
			CURSOR cr_valores_dat(pr_cdoperadora IN tbrecarga_valor.cdoperadora%TYPE
			                     ,pr_cdproduto   IN tbrecarga_valor.cdproduto%TYPE) IS
			  SELECT MAX(tval.dtmvtolt)
				  FROM tbrecarga_valor tval
				 WHERE tval.cdoperadora = pr_cdoperadora
				   AND tval.cdproduto   = pr_cdproduto;
							 
	    -- Cursor para listar os produtos de recarga
		  CURSOR cr_valores(pr_cdoperadora IN tbrecarga_valor.cdoperadora%TYPE
			                 ,pr_cdproduto   IN tbrecarga_valor.cdproduto%TYPE
											 ,pr_dtmvtolt    IN tbrecarga_valor.dtmvtolt%TYPE) IS
 			  SELECT tval.vlrecarga
				  FROM tbrecarga_valor tval
				 WHERE tval.cdoperadora = pr_cdoperadora
				   AND tval.cdproduto   = pr_cdproduto
					 AND tval.dtmvtolt    = pr_dtmvtolt;
					 		
		BEGIN
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxml, TRUE); 
      dbms_lob.open(pr_clobxml, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<Raiz><VALORES>'); 
														 			
			-- Buscar data atualizada do produto
			OPEN cr_valores_dat(pr_cdoperadora => pr_cdoperadora
                         ,pr_cdproduto => pr_cdproduto);
			FETCH cr_valores_dat INTO vr_dtmvtolt;
			-- Fechar cursor
			CLOSE cr_valores_dat;									
					 											 
			-- Buscar telefones favoritos
			FOR rw_valores IN cr_valores(pr_cdoperadora => pr_cdoperadora
				                          ,pr_cdproduto => pr_cdproduto
																	,pr_dtmvtolt => vr_dtmvtolt) LOOP			
        -- Montar clob de retorno
        -- Montar XML com registros de carencia
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<valor>' || to_char(rw_valores.vlrecarga, 'fm999g990d00') || '</valor>');
      END LOOP;

      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</VALORES></Raiz>' 
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																							
	END pc_obtem_valores_recarga;
	
	-- Listar datas de agendamento recorrente
	PROCEDURE pc_verifica_agendamento_recorr(pr_cdcooper IN crapcop.cdcooper%TYPE
																					,pr_ddagenda IN INTEGER
																					,pr_qtmesagd IN INTEGER
																					,pr_dtinicio IN DATE
																					,pr_lsdatagd OUT VARCHAR2
																					,pr_cdcritic OUT PLS_INTEGER
																					,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_verifica_agendamento_recorrente
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar datas de agendamento recorrente

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
		
		  -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
			-- Variáveis auxiliares
			vr_mmagenda VARCHAR2(10);
			vr_yyagenda VARCHAR2(10);
			vr_ddagenda INTEGER;
			vr_dtmvtopg DATE;
			vr_bkp_dtmvtopg DATE;
			
		BEGIN 		
			-- Separar mês/ano
			vr_mmagenda := SUBSTR(to_char(pr_dtinicio, 'DD/MM/RRRR'),4,2);
			vr_yyagenda := SUBSTR(to_char(pr_dtinicio, 'DD/MM/RRRR'),7,4);	
			
			FOR vr_contador IN 1..pr_qtmesagd LOOP
				vr_ddagenda := pr_ddagenda;
				-- Definir data do mes de agendamento
				LOOP
				  BEGIN
						vr_dtmvtopg := TO_DATE(lpad(vr_mmagenda,2,'0')||
													 lpad(vr_ddagenda,2,'0')||
													 lpad(vr_yyagenda,4,'0'),'MMDDRRRR');
						-- se nao deu critica ao definir data sair do loop
						EXIT;
					EXCEPTION
						WHEN OTHERS THEN
							-- se apresentar critica, devido a data invalida
							-- diminuir 1 dia e tentar novamente
							vr_ddagenda := vr_ddagenda -1;							
				  END; 
				END LOOP;
				
				vr_bkp_dtmvtopg := vr_dtmvtopg;
				-- Buscar proximo dia util, caso este não seja
				vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
																									,pr_dtmvtolt => vr_dtmvtopg
																									,pr_tipo => 'P'
																									,pr_feriado => TRUE);
																									
				-- Se ao buscar a nova data mudar o mês, buscar a data anterior
				IF to_char(vr_dtmvtopg,'MM') <> to_char(vr_bkp_dtmvtopg,'MM') THEN
					-- Buscar proximo dia util, caso este não seja
					vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, 
																										 pr_dtmvtolt => vr_bkp_dtmvtopg, 
																										 pr_tipo => 'A', 
																										 pr_feriado => TRUE); 
				END IF;
				-- Incrementar os agendamentos recorrentes 
        pr_lsdatagd := nvl(pr_lsdatagd,' ') || to_char(vr_dtmvtopg, 'DD/MM/RRRR') || ',';
				-- Defini proximo mês 
				IF vr_mmagenda = 12 THEN
					vr_mmagenda := 1;
					vr_yyagenda := vr_yyagenda + 1; 
				ELSE
				  vr_mmagenda := vr_mmagenda + 1; 
				END IF;
				
			END LOOP;
			
			-- Remover espaço
			pr_lsdatagd := TRIM(pr_lsdatagd);
			-- Remover última vírgula
			pr_lsdatagd := substr(pr_lsdatagd, 1, LENGTH(pr_lsdatagd) - 1);
																				
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																																														
  END pc_verifica_agendamento_recorr;
	
	-- Validar recarga de celular
	PROCEDURE pc_valida_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE              -- Cód. cooperativa
		                         ,pr_nrdconta  IN crapass.nrdconta%TYPE              -- Nr. da conta
														 ,pr_idseqttl  IN crapsnh.idseqttl%TYPE              -- Id do titular
														 ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE              -- CPF do operador juridico
														 ,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE      -- DDD
														 ,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE  -- Telefone
                             ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE     -- Valor de recarga
														 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE  -- Data para recarga
														 ,pr_qtmesagd  IN INTEGER                            -- Qtd. meses agendamento
														 ,pr_cddopcao  IN INTEGER                            -- Opção: 1 - Data atual / 2 - Data futura / 3 - Agendamento
														 ,pr_idorigem  IN INTEGER                            -- Indicador de Origem
                             ,pr_cdagenci IN INTEGER -- Agencia de Origem
                             ,pr_nrdcaixa IN INTEGER -- Caixa de Origem
                             ,pr_nmprogra IN VARCHAR2 -- Programa que chamou
														 ,pr_lsdatagd OUT VARCHAR2                           -- Lista de datas agendadas
														 ,pr_cdcritic OUT PLS_INTEGER                        -- Cód. da crítica
														 ,pr_dscritic OUT VARCHAR2) IS                       -- Desc. da crítica
  BEGIN
    /* .............................................................................
    Programa: pc_valida_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar recarga de celular

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
		
		  -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_nrdrowid ROWID;
      vr_dserrlog VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
			-- Descrição do email
		  vr_des_corpo   VARCHAR2(1000);
			
			-- Variáveis auxiliares
			vr_tab_saldo EXTR0001.typ_tab_saldos;
			vr_tab_erro GENE0001.typ_tab_erro;
			vr_dtrecarga DATE;
			
      -- Buscar dados da conta
			CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
				SELECT ass.inpessoa
              ,ass.idastcjt
				      ,ass.vllimcre
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
      
		  -- Verificar se número do celular é fraudulento
		  CURSOR cr_crapcbf(pr_dsfraude IN crapcbf.dsfraude%TYPE) IS
			  SELECT 1
				  FROM crapcbf cbf
				 WHERE cbf.cdcooper = 3
				   AND cbf.tpfraude = 4
					 AND cbf.dsfraude = pr_dsfraude;
			rw_crapcbf cr_crapcbf%ROWTYPE;
			
			-- Operação agendada duplicada
			CURSOR cr_operacao_duplicada(pr_cdcooper IN tbrecarga_operacao.cdcooper%TYPE
			                            ,pr_nrdconta IN tbrecarga_operacao.nrdconta%TYPE
																	,pr_dtrecarg IN tbrecarga_operacao.dtrecarga%TYPE
																	,pr_nrdddtel IN tbrecarga_operacao.nrddd%TYPE
																	,pr_nrtelefo IN tbrecarga_operacao.nrcelular%TYPE
																	,pr_vlrecarg IN tbrecarga_operacao.vlrecarga%TYPE) IS
				SELECT 1
				  FROM tbrecarga_operacao ope
				 WHERE ope.cdcooper  = pr_cdcooper
				   AND ope.nrdconta  = pr_nrdconta
					 AND ope.dtrecarga = pr_dtrecarg
					 AND ope.nrddd     = pr_nrdddtel
					 AND ope.nrcelular = pr_nrtelefo
					 AND ope.vlrecarga = pr_vlrecarg
					 AND ope.insit_operacao = 1; -- Agendada
			rw_operacao_duplicada cr_operacao_duplicada%ROWTYPE;				 			
			
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
    BEGIN	
			-- Buscar data do sistema
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
			-- Se não encontrar
			IF btch0001.cr_crapdat%NOTFOUND THEN
				-- Fechar o cursor pois efetuaremos raise
				CLOSE btch0001.cr_crapdat;
				-- Montar mensagem de critica
				vr_cdcritic := 1;
				vr_dscritic := '';
				RAISE vr_exc_erro;
			ELSE
				-- Apenas fechar o cursor
				CLOSE btch0001.cr_crapdat;
			END IF;
		
			-- Verificar se número de celular é fraudulento
			OPEN cr_crapcbf(pr_dsfraude => to_char(pr_nrdddtel) || TO_CHAR(pr_nrtelefo, '00000g0000','nls_numeric_characters=.-'));
			FETCH cr_crapcbf INTO rw_crapcbf;
		
		  -- Se encontrou
		  IF cr_crapcbf%FOUND THEN
				-- Telefone é fraudulento
				vr_des_corpo := '<b>Atencao! Houve tentativa de Recarga de Celular fraudulenta.<br>'||
                        'Conta: </b>'||gene0002.fn_mask_conta(pr_nrdconta)||'<br>'||
                        '<b>Numero do celular: </b>'|| to_char(pr_nrdddtel, 'fm99') 
												|| TO_CHAR(pr_nrtelefo, '00000g0000','nls_numeric_characters=.-');
												
				-- Envio de e-mail informando que houve a tentativa
				gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper,
																	 pr_cdprogra => 'RCEL0001',
																	 pr_des_destino => 'monitoracaodefraudes@ailos.coop.br',
																	 pr_des_assunto => 'Atencao - Tentativa de Recarga de Celular para numero em restritivo',
																	 pr_des_corpo => vr_des_corpo,
																	 pr_des_anexo => NULL,
																	 pr_flg_enviar => 'S', /* Na hora */ 
																	 pr_des_erro => vr_dscritic);
				-- Fechar cursor
				CLOSE cr_crapcbf;
				-- Gerar crítica													 
				vr_cdcritic := 0;
				vr_dscritic := 'Número de telefone inválido.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapcbf;
			
			-- Se origem é IB
			IF pr_idorigem = 3 THEN
				-- Verificar se conta é representante legal
				INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
																					 ,pr_nrdconta => pr_nrdconta
																					 ,pr_idseqttl => pr_idseqttl
																					 ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
																					 ,pr_cdcritic => vr_cdcritic
																					 ,pr_dscritic => vr_dscritic);
				-- Se retornou alguma crítica														 
				IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					-- Levanta exceção
					RAISE vr_exc_erro;
				END IF;
      END IF;		
			
      -- Valida se possui saldo em conta
      OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
      FETCH cr_crapass
      INTO rw_crapass;
      CLOSE cr_crapass;
      
      IF   pr_cddopcao < 2   AND  	/* Recarga DATA ATUAL */
           pr_nrcpfope = 0   AND  	/* NÃO É OPERADOR */
           rw_crapass.idastcjt = 0   THEN 	/* NÃO É CONTA ASSIN. CONJUNTA */ 
        
        -- Obtem saldo do cooperado
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper
			                             ,pr_rw_crapdat => rw_crapdat
				 		                       ,pr_cdagenci => CASE 
                                                   WHEN pr_idorigem = 5 THEN 1
                                                       ELSE pr_cdagenci END  /* Projeto 363 - Novo ATM */
					                         ,pr_nrdcaixa => CASE 
						                                       WHEN pr_idorigem = 5 THEN 0
                                                       ELSE pr_nrdcaixa END /* Projeto 363 - Novo ATM */
					                         ,pr_cdoperad => CASE 
						                                       WHEN pr_idorigem = 5 THEN 1
						 	                                     ELSE 996 END
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_vllimcre => rw_crapass.vllimcre
                                   ,pr_dtrefere => rw_crapdat.dtmvtolt
                                   ,pr_flgcrass => FALSE
                                   ,pr_tipo_busca => 'A'
                                   ,pr_des_reto => vr_dscritic
                                   ,pr_tab_sald => vr_tab_saldo
                                   ,pr_tab_erro => vr_tab_erro);

        -- Se o valor do saldo disponível + valor limite cheque especial for menor que o valor de recarga
        IF (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + 
            nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) < pr_vlrecarga THEN
           -- Gerar crítica
           vr_cdcritic := 0;
           vr_dscritic := 'Não há saldo suficiente para a operação.';
            -- Levantar exceção
            RAISE vr_exc_erro;
        END IF;
      END IF;
       
			-- Se for agendamento para data futura (2) ou recorrente (3)
			IF pr_cddopcao IN (2,3) THEN
				 -- Verificar se a quantidade de meses é maior que 24
		     IF pr_qtmesagd > 24 THEN
					 -- Gerar crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Quantidade máxima de 24 meses permitida.';
					 -- Levantar exceção
					 RAISE vr_exc_erro;
				 END IF;
				 
				 -- Verificar se a data de agendamento é dia útil
				 vr_dtrecarga := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
				                                            ,pr_dtmvtolt => pr_dtrecarga);
				 -- Se a data de recarga não for em dia útil																		
				 IF pr_dtrecarga <> vr_dtrecarga THEN
					 -- Gerar crítica
           vr_cdcritic := 0;
					 vr_dscritic := CASE WHEN pr_cddopcao = 2 THEN
					                  'Data do agendamento deve ser um dia útil.'
													ELSE
														'Data de início do agendamento deve ser um dia útil.'
												  END;
					-- Levantar exceção
					RAISE vr_exc_erro;
				 END IF;
				 
				 -- Verificar se a data futura ou data de início do agendamento
				 -- mensal é superior a 24 meses
				 IF pr_dtrecarga > ADD_MONTHS(rw_crapdat.dtmvtolt, 24) THEN
					 -- Gerar crítica
           vr_cdcritic := 0;
					 vr_dscritic := CASE WHEN pr_cddopcao = 2 THEN
					                  'O prazo máximo para a data do agendamento é de 24 meses.'
													ELSE
														'O prazo máximo para início do agendamento é de 24 meses.'
												  END;
					-- Levantar exceção
					RAISE vr_exc_erro;					 
				 END IF;

         -- Se for agendamento mensal
         IF pr_cddopcao = 3 THEN
					 -- Chamar procedure para validar todas as datas de agendamento
					 pc_verifica_agendamento_recorr(pr_cdcooper => pr_cdcooper
																				 ,pr_ddagenda => to_number(to_char(pr_dtrecarga, 'DD'))
																				 ,pr_qtmesagd => pr_qtmesagd
																				 ,pr_dtinicio => pr_dtrecarga
																				 ,pr_lsdatagd => pr_lsdatagd
																				 ,pr_cdcritic => vr_cdcritic
																				 ,pr_dscritic => vr_dscritic);					 
				 END IF;
				 
				 -- Verificar agendamento duplicado
         OPEN cr_operacao_duplicada(pr_cdcooper => pr_cdcooper
			                             ,pr_nrdconta => pr_nrdconta
																	 ,pr_dtrecarg => pr_dtrecarga
																	 ,pr_nrdddtel => pr_nrdddtel
																	 ,pr_nrtelefo => pr_nrtelefo
																	 ,pr_vlrecarg => pr_vlrecarga);
				 FETCH cr_operacao_duplicada INTO rw_operacao_duplicada;
				 
				 -- Se encontrou agendamento já existe
				 IF cr_operacao_duplicada%FOUND THEN
					 -- Fechar cursor
					 CLOSE cr_operacao_duplicada;
					 -- Gerar crítica
           vr_cdcritic := 0;
					 vr_dscritic := '<![CDATA[Você já possui um agendamento cadastrado com os mesmos dados informados. </br>'
					             || ' O agendamento de recarga para o mesmo telefone e valor devem ser feitos em datas diferentes. </br>'
											 || '<center>Consulte suas recargas agendadas.</center>]]>';
					 -- Gravar erro para o log
           vr_dserrlog := 'Você já possui um agendamento cadastrado com os mesmos dados informados.'
					             || ' O agendamento de recarga para o mesmo telefone e valor devem ser feitos em datas diferentes.'
											 || ' Consulte suas recargas agendadas.';
					
				  -- Se for pelo TAA
					IF pr_idorigem = 4 THEN
						-- Utilizaremos a crítica sem o CDATA/tagas
						vr_dscritic := 'Você já possui um agendamento cadastrado para a mesma Data, Telefone e Valor.'
   											 || ' Consulte suas recargas agendadas.';
					END IF;											 
					-- Levantar exceção
					RAISE vr_exc_erro;					 
			END IF;
				 -- Fechar cursor
				 CLOSE cr_operacao_duplicada;
				 
			END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
				-- Se retornou erro para o log
				IF trim(vr_dserrlog) IS NOT NULL THEN
					-- Utilizar erro do log
					vr_dscritic := vr_dserrlog;
				END IF;  
				      
        -- Gerar log
				GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
														,pr_cdoperad => '996' 
														,pr_dscritic => vr_dscritic
														,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
														,pr_dstransa => 'Recarga de celular'
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 0
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => pr_idseqttl
														,pr_nmdatela => pr_nmprogra /* Projeto 363 - Novo ATM */
														,pr_nrdconta => pr_nrdconta
														,pr_nrdrowid => vr_nrdrowid);
						
				-- Se crítica for número de telefone inválido devemos logar como Número de telefone fraudulento								
			  IF vr_dscritic = 'Número de telefone inválido.' THEN
					-- Telefone												 
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Telefone'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => '('||to_char(pr_nrdddtel, 'fm00')||')' ||
																									 to_char(pr_nrtelefo,'fm00000g0000','nls_numeric_characters=.-'));
					-- Erro
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Erro'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => 'Número de telefone fraudulento');
			END IF;														

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
        
        -- Gerar log
				GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
														,pr_cdoperad => '996' 
														,pr_dscritic => vr_dscritic
														,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
														,pr_dstransa => 'Recarga de celular'
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 0
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => pr_idseqttl
														,pr_nmdatela => pr_nmprogra /* Projeto 363 - Novo ATM */
														,pr_nrdconta => pr_nrdconta
														,pr_nrdrowid => vr_nrdrowid);
    END;																							
	END pc_valida_recarga;

  -- Procedure para manter recarga de celular (Efetivação/Transação Pendente)
	PROCEDURE pc_manter_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cód. cooperativa
		                         ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Nr. da conta
														 ,pr_idseqttl  IN crapttl.idseqttl%TYPE -- Id. do titular
														 ,pr_nrcpfope  IN crapsnh.nrcpfcgc%TYPE -- Nr. CPF operador
														 ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
														 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE -- Data de recarga
														 ,pr_lsdatagd  IN VARCHAR2 -- Lista de datas para agendamento
														 ,pr_cddopcao  IN INTEGER  -- Cód. da opção (1-Data atual / 2-Data futura / 3-Agendamento mensal)
														 ,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE -- Nr. DDD
														 ,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE -- Nr. Telefone
														 ,pr_cdopetel  IN tbrecarga_operadora.cdoperadora%TYPE -- Cód. operadora
														 ,pr_cdprodut  IN tbrecarga_produto.cdproduto%TYPE     -- Cód. produto
														 ,pr_cdcoptfn  IN crapcop.cdcooper%TYPE -- Cód. da cooperativa do terminal financeiro (Apenas TAA)
														 ,pr_cdagetfn  IN crapage.cdagenci%TYPE -- Cód. da agencia do terminal financeiro (Apenas TAA)
														 ,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro (Apenas TAA)
														 ,pr_nrcartao  IN NUMBER                -- Nr. do cartao (Apenas TAA)
														 ,pr_nrsequni  IN INTEGER               -- Nr. sequencial único (Apenas TAA)
														 ,pr_idorigem  IN INTEGER               -- Id. origem (3-IB / 4-TAA)
                             ,pr_cdagenci  IN INTEGER               -- Agencia da Transação
                             ,pr_nrdcaixa  IN INTEGER               -- Caixa da Transação
                             ,pr_nmprogra  IN VARCHAR2              -- Nome do Programa que chamou
														 ,pr_inaprpen  IN NUMBER                -- Indicador de aprovação de transacao pendente
														 ,pr_idoperac  IN tbrecarga_operacao.idoperacao%TYPE -- Id. operação (Somente na efetivação do agendamento e aprovação de transação pendente)
                             ,pr_flmobile  IN NUMBER                -- Indicador se origem é mobile
                             ,pr_dslancto OUT VARCHAR2              -- Lista com todos os ID operação dos agendamentos criados
                             ,pr_idastcjt OUT INTEGER               -- Se possui assinatura
														 ,pr_dsprotoc OUT VARCHAR2              -- Protocolo
														 ,pr_dsnsuope OUT tbrecarga_operacao.dsnsu_operadora%TYPE -- NSU Operadora
														 ,pr_cdcritic OUT PLS_INTEGER           -- Cód. da crítica
														 ,pr_dscritic OUT VARCHAR2) IS          -- Desc. da crítica
  BEGIN
  /* .............................................................................
    Programa: pc_manter_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para manter a recarga de celular (efetivar/transação pendente)

    Alteracoes: -----
    ..............................................................................*/						
	  DECLARE
			-- Cursor genérico de calendário
			rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

		  -- Variavel de criticas
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
			-- Variáveis auxiliares
			vr_idastcjt   INTEGER(1);
			vr_nrcpfcgc   crapsnh.nrcpfcgc%TYPE;
			vr_nmprimtl   VARCHAR2(500);
			vr_flcartma   INTEGER(1);
			vr_dstransa   VARCHAR2(1000);
			vr_nrdrowid   ROWID;
      vr_nmopetel   tbrecarga_operadora.nmoperadora%TYPE;
			vr_qtmesagd   gene0002.typ_split;

      -- Buscar informações da operadora
			CURSOR cr_operadora IS
			  SELECT opr.nmoperadora
				  FROM tbrecarga_operadora opr
				 WHERE opr.cdoperadora = pr_cdopetel;

	  BEGIN								 
			
			-- Leitura do calendário da cooperativa
			OPEN btch0001.cr_crapdat(pr_cdcooper);
			FETCH btch0001.cr_crapdat INTO rw_crapdat;
			-- Se não encontrar
			IF btch0001.cr_crapdat%NOTFOUND THEN
				-- Fechar o cursor pois efetuaremos raise
				CLOSE btch0001.cr_crapdat;
				-- Montar mensagem de critica
				vr_cdcritic := 1;
				vr_dscritic := '';
				RAISE vr_exc_erro;
			ELSE
				-- Apenas fechar o cursor
				CLOSE btch0001.cr_crapdat;
			END IF;

      -- Internet bank
      IF pr_idorigem = 3 THEN
				-- Valida transação de representante legal
				INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
																					 ,pr_nrdconta => pr_nrdconta
																					 ,pr_idseqttl => pr_idseqttl
																					 ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
																					 ,pr_cdcritic => vr_cdcritic
																					 ,pr_dscritic => vr_dscritic);

				-- Se houve crítica, gerar exceção
				IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF; 
      END IF;
			--Verifica se conta for conta PJ e se exige asinatura multipla
			INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
																				 ,pr_nrdconta => pr_nrdconta
																				 ,pr_idseqttl => pr_idseqttl
																				 ,pr_cdorigem => pr_idorigem
																				 ,pr_idastcjt => vr_idastcjt
																				 ,pr_nrcpfcgc => vr_nrcpfcgc
																				 ,pr_nmprimtl => vr_nmprimtl
																				 ,pr_flcartma => vr_flcartma
																				 ,pr_cdcritic => vr_cdcritic
																				 ,pr_dscritic => vr_dscritic);

			-- Se retornou crítica
			IF nvl(vr_cdcritic,0) <> 0 OR
				 TRIM(vr_dscritic) IS NOT NULL THEN
				 RAISE vr_exc_erro; 
			END IF;
			
			-- Se recarga foi feita por operador ou conta possui assinatura conjunta
			IF (pr_nrcpfope > 0 OR vr_idastcjt = 1) AND pr_inaprpen = 0 THEN
              INET0002.pc_cria_trans_pend_recarga(pr_cdagenci => pr_cdagenci
                                                 ,pr_nrdcaixa => pr_nrdcaixa
																					 ,pr_cdoperad => '996'
                                                 ,pr_nmdatela => pr_nmprogra
																					 ,pr_idorigem => pr_idorigem
																					 ,pr_idseqttl => pr_idseqttl
																					 ,pr_nrcpfope => pr_nrcpfope -- Quando idorigem <> 3-Internet virá zerado 
																					 ,pr_nrcpfrep => CASE WHEN pr_nrcpfope > 0 THEN 0
																					                      ELSE NVL(vr_nrcpfcgc,0) END
																					 ,pr_cdcoptfn => pr_cdcoptfn
																					 ,pr_cdagetfn => pr_cdagetfn
																					 ,pr_nrterfin => pr_nrterfin
																					 ,pr_dtmvtolt => rw_crapdat.dtmvtocd
																					 ,pr_cdcooper => pr_cdcooper
																					 ,pr_nrdconta => pr_nrdconta
																					 ,pr_vlrecarga => pr_vlrecarga
																					 ,pr_dtrecarga => pr_dtrecarga
																					 ,pr_lsdatagd => pr_lsdatagd 
																					 -- Indicador de agendamento 
																					 ,pr_tprecarga => CASE WHEN pr_cddopcao > 1 THEN 2 
																					                       ELSE 1 END
																					 ,pr_nrdddtel => pr_nrdddtel
																					 ,pr_nrtelefo => pr_nrtelefo
																					 ,pr_cdopetel => pr_cdopetel
																					 ,pr_cdprodut => pr_cdprodut
																					 ,pr_idastcjt => vr_idastcjt
																					 ,pr_cdcritic => vr_cdcritic
																					 ,pr_dscritic => vr_dscritic);
				-- Se retornou alguma crítica									 
				IF nvl(vr_cdcritic,0) <> 0 OR
					 TRIM(vr_dscritic) IS NOT NULL THEN
					 -- Levantar exceção
					 RAISE vr_exc_erro; 
				END IF;																					 
				
				-- Descrição da transação
				vr_dstransa := CASE WHEN pr_nrcpfope > 0 THEN 
				                        'Recarga de celular - operador'
				                    ELSE
														    'Recarga de celular'
											 END;
				
				-- Monta mensagem de retorno
				IF vr_idastcjt = 1 THEN
					vr_dscritic := 'Recarga de celular registrada com sucesso. ' ||
												 'Aguardando aprovação do registro pelos demais responsáveis.';
				ELSE
					vr_dscritic := 'Recarga de celular registrada com sucesso. ' ||
												 'Aguardando efetivação do registro pelo preposto.';
				END IF;
				-- Se for agendamento
				IF pr_cddopcao IN (2,3) THEN
					 vr_dscritic := 'Agendamento de ' || vr_dscritic;
				END IF;
				-- Gerar log
				GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
														,pr_cdoperad => '996' 
														,pr_dscritic => vr_dscritic
														,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
														,pr_dstransa => vr_dstransa
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 1
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => pr_idseqttl
														,pr_nmdatela => pr_nmprogra
														,pr_nrdconta => pr_nrdconta
														,pr_nrdrowid => vr_nrdrowid);
        
				-- Operador
				IF pr_nrcpfope > 0  THEN
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Operador'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu =>gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
			  END IF;
				
				-- Busca nome da operadora
				OPEN cr_operadora;
				FETCH cr_operadora INTO vr_nmopetel;
				CLOSE cr_operadora;
				
				-- Operadora
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Operadora'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => vr_nmopetel);
				-- Telefone												 
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Telefone'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => '('||to_char(pr_nrdddtel, 'fm00')||')' ||
																                 to_char(pr_nrtelefo,'fm00000g0000','nls_numeric_characters=.-'));
				-- Valor
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Valor'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => to_char(pr_vlrecarga, 'fm9g999g990d00'));
																 
				IF pr_cddopcao = 2 THEN
				  -- Agendamento data futura					
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Data do Agendamento'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => to_char(pr_dtrecarga, 'DD/MM/RRRR'));
				ELSIF pr_cddopcao = 3 THEN
					-- Quebra a quantidade de meses para buscar a quantidade
					vr_qtmesagd := GENE0002.fn_quebra_string(pr_string  => pr_lsdatagd, 
                                                   pr_delimit => ',');
					-- Agendamento recorrente
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Agendamento recorrente'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => 'Dia '|| to_char(pr_dtrecarga, 'DD')||
																	                 ', ' || to_char(vr_qtmesagd.count) || ' mes(es), inicio em ' ||
																									 to_char(pr_dtrecarga, 'DD/MM/RRRR'));
				END IF;
				--Se conta exigir Assinatura Multipla
				IF vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN
					-- Nome do representante/procurador
					gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid 
																	 ,pr_nmdcampo => 'Nome do Representante/Procurador'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => vr_nmprimtl);
																	 
					-- CPF do representante/procurador
					gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'CPF do Representante/Procurador'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu =>TO_CHAR(gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1)));
			  END IF;
        
        IF pr_idorigem = 3 THEN -- Ser for ibank/mobile
        --Origem
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Origem',
                                  pr_dsdadant => NULL,
                                  pr_dsdadatu => CASE pr_flmobile
                                                 WHEN 1 THEN 'MOBILE'
                                                 ELSE pr_nmprogra
                                                  END);
        END IF;
        
			ELSE
        CASE					
					WHEN pr_cddopcao = 1 THEN -- Data atual
						-- Devemos chamar procedure para efetuar recarga
						RCEL0001.pc_efetua_recarga(pr_cdcooper  => pr_cdcooper
						                          ,pr_nrdconta  => pr_nrdconta
																			,pr_idseqttl  => pr_idseqttl
																			,pr_vlrecarga => pr_vlrecarga
																			,pr_nrdddtel  => pr_nrdddtel
																			,pr_nrtelefo  => pr_nrtelefo
																			,pr_cdproduto => pr_cdprodut
																			,pr_cdopetel  => pr_cdopetel
																			,pr_idoperac  => pr_idoperac
																			,pr_nrcpfope  => pr_nrcpfope
																			,pr_cdcoptfn  => pr_cdcoptfn
																			,pr_nrterfin  => pr_nrterfin
																			,pr_nrcartao  => pr_nrcartao
																			,pr_nrsequni  => pr_nrsequni
																			,pr_idorigem  => pr_idorigem
                                                                            ,pr_cdagenci  => pr_cdagenci
                                                                            ,pr_nrdcaixa  => pr_nrdcaixa
                                                                            ,pr_nmprogra  => pr_nmprogra
																			,pr_flmobile  => pr_flmobile
																			,pr_nsuopera  => pr_dsnsuope
																			,pr_dsprotoc  => pr_dsprotoc
																			,pr_cdcritic  => vr_cdcritic
																			,pr_dscritic  => vr_dscritic);
						-- Se retornou alguma crítica										
						IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
							-- Levanta exceção
							RAISE vr_exc_erro;
						END IF;
					WHEN pr_cddopcao IN (2,3) THEN -- Agendamento data futura ou recorrente
						-- Devemos chamar procedure para agendar data futura para recarga
						RCEL0001.pc_cadastra_agendamento(pr_cdcooper => pr_cdcooper
						                                ,pr_nrdconta => pr_nrdconta
																						,pr_cdoperad => '996'
																						,pr_nrcpfope => pr_nrcpfope
																						,pr_idseqttl => pr_idseqttl
																						,pr_vlrecarga => pr_vlrecarga
																						,pr_nrdddtel => pr_nrdddtel
																						,pr_nrtelefo => pr_nrtelefo
																						,pr_cdproduto => pr_cdprodut
																						,pr_cdoperadora => pr_cdopetel
																						,pr_dtrecarga => pr_dtrecarga
																						,pr_lsdatagd => pr_lsdatagd
																						,pr_idorigem => pr_idorigem
                                                        ,pr_nmprogra => pr_nmprogra
																						,pr_idoperac => pr_idoperac
                                                        ,pr_dslancto => pr_dslancto
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
																						
            -- Se retornou alguma crítica										
						IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
							-- Levanta exceção
							RAISE vr_exc_erro;
						END IF;																						
					ELSE
						-- Gerar crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Opção inválida';
						-- Levantar exceção
						RAISE vr_exc_erro;
				END CASE;
			END IF;

      -- Retornar se é assinatura conjunta
      pr_idastcjt := vr_idastcjt;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
				pr_idastcjt := 0;				
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
				pr_idastcjt := 0;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																							
	END pc_manter_recarga;
	
	-- Procedure para efetuar recarga de celular
	PROCEDURE pc_efetua_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cód. operadora
		                         ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Nr. da conta
														 ,pr_idseqttl  IN INTEGER -- Id. titular
														 ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
														 ,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE -- DDD
														 ,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE -- Telefone
														 ,pr_cdproduto IN tbrecarga_produto.cdproduto%TYPE -- Cód. produto
														 ,pr_cdopetel  IN tbrecarga_operadora.cdoperadora%TYPE -- Cód. operadora
														 ,pr_idoperac  IN tbrecarga_operacao.idoperacao%TYPE -- Id. operação (Somente na efetivação do agendamento e aprovação de transação pendente)
														 ,pr_nrcpfope  IN crapsnh.nrcpfcgc%TYPE -- Nr. CPF operador
														 ,pr_cdcoptfn  IN craptfn.cdcooper%TYPE -- Coopertaiva do terminal financeiro
														 ,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro
														 ,pr_nrcartao  IN DECIMAL               -- Nr. do cartão
														 ,pr_nrsequni  IN INTEGER               -- Nr. sequencial único (Apenas TAA)
														 ,pr_idorigem  IN INTEGER -- Id. origem
                               ,pr_cdagenci  IN INTEGER -- Agencia da transação
                               ,pr_nrdcaixa  IN INTEGER -- Caixa da transação
                               ,pr_nmprogra  IN VARCHAR2 -- Programa que chamou
                             ,pr_flmobile  IN NUMBER                -- Indicador se origem é mobile
														 ,pr_nsuopera  OUT tbrecarga_operacao.dsnsu_operadora%TYPE -- NSU operadora
														 ,pr_dsprotoc  OUT VARCHAR2                                -- Protocolo
														 ,pr_cdcritic  OUT PLS_INTEGER -- Cód. crítica
														 ,pr_dscritic  OUT VARCHAR2) IS -- Desc. crítica
  
  PRAGMA AUTONOMOUS_TRANSACTION;
  
  BEGIN
  /* .............................................................................
    Programa: pc_efetua_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao: 31/08/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para efetuar a recarga de celular

    Alteracoes: 31/05/2017 - Adicionados parametros Cooperativa e CNPJ na requisição
                             RealizarVenda do Aymaru. PRJ 321 - Recarga de Celular (Lombardi)

                06/06/2017 - Incluir a gravação da data de repasse do valor para 
                             a Rede Tendencia(dtrepasse) (Renato Darosci)

		        12/07/2017 - Corrigida ordem dos parâmetros vr_cdcritic e vr_dscritic na
				             chamada do Aymaru (Diego).

                13/07/2017 - Efetuado tratamento para critica de Timeout na requisicao
				             de recarga de celular (Diego). 
							 
                03/08/2017 - Efetuado ajuste para calcular e gravar o valor do repasse 
                             na tabela tbrecarga_operacao (Lombardi). 

				31/08/2017 - Solicitar geracao do relatorio utilizando a data
				             vr_dtmvtolt (Diego).
							 
    ..............................................................................*/		
	  DECLARE
		  -- Variavel de criticas
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(10000);
			vr_des_erro VARCHAR2(3);
      vr_dserrlog VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
      -- Variáveis auxiláres
			vr_totrecar NUMBER;
			vr_tab_saldo EXTR0001.typ_tab_saldos;
			vr_tab_erro GENE0001.typ_tab_erro;
			vr_nrdrowid ROWID;
			vr_nsuoperadora tbrecarga_operacao.dsnsu_operadora%TYPE;
			vr_nsutendencia tbrecarga_operacao.dsnsu_tendencia%TYPE;			
			vr_dsinfor1 crappro.dsinform##1%TYPE;
			vr_dsinfor2 crappro.dsinform##2%TYPE;			
			vr_dsinfor3 crappro.dsinform##3%TYPE;						
			vr_idastcjt INTEGER(1);
			vr_nrcpfcgc crapsnh.nrcpfcgc%TYPE;
			vr_nmprimtl VARCHAR2(500);
			vr_flcartma INTEGER(1);
			vr_dsprotoc crappro.dsprotoc%TYPE;
      vr_cdopetfn craptfn.cdoperad%TYPE;
			vr_dstransa VARCHAR2(500);
			vr_nrseqdig craplcm.nrseqdig%TYPE;
      vr_dtrepasse tbrecarga_operacao.dtrepasse%TYPE;
      vr_vrreceita   NUMBER; --> Valor da receita
      vr_vlrepasse   NUMBER; --> Valor do repasse
			vr_flgoperac BOOLEAN;
			vr_dtdebito DATE;
			
			-- Variáveis para utilizar o Aymaru
			vr_resposta AYMA0001.typ_http_response_aymaru;
			vr_parametros WRES0001.typ_tab_http_parametros;
			vr_recarga json := json();

      -- Somar os valores de recarga efetuadas no dia
      CURSOR cr_totrecarga(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
			  SELECT SUM(opr.vlrecarga)
				  FROM tbrecarga_operacao opr
				 WHERE opr.cdcooper = pr_cdcooper
				   AND opr.nrdconta = pr_nrdconta
				   AND opr.dtrecarga = trunc(SYSDATE)
				   AND opr.insit_operacao = 2;
					 
			-- Buscar limites diário de recarga
			CURSOR cr_recparam(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
			  SELECT tparam.vlmaximo_pf
				      ,tparam.vlmaximo_pj
				  FROM tbrecarga_param tparam
				 WHERE tparam.cdcooper = pr_cdcooper;
			rw_recparam cr_recparam%ROWTYPE;
			
			-- Buscar indicador de pessoa
			CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
				SELECT ass.inpessoa
				      ,ass.vllimcre
              ,(SELECT ttl.nmextttl
                  FROM crapttl ttl
                 WHERE ttl.cdcooper = pr_cdcooper
                   AND ttl.nrdconta = pr_nrdconta
                   AND ttl.idseqttl = pr_idseqttl) nmextttl
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
			
			-- Buscar informações da operadora/produto
			CURSOR cr_inf_rec(pr_cdopetel IN tbrecarga_operadora.cdoperadora%TYPE
			                 ,pr_cdprodut IN tbrecarga_produto.cdproduto%TYPE) IS
				SELECT tope.nmoperadora
				      ,tope.cdhisdeb_cooperado
							,tpdt.tpoperacao
				      ,tpdt.nmproduto
				  FROM tbrecarga_operadora tope
					    ,tbrecarga_produto   tpdt
				 WHERE tope.cdoperadora = pr_cdopetel
				   AND tpdt.cdoperadora = tope.cdoperadora
					 AND tpdt.cdproduto   = pr_cdprodut;
			rw_inf_rec cr_inf_rec%ROWTYPE;
			
			-- Buscar operação
			CURSOR cr_operacao(pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE) IS
			  SELECT tope.idoperacao
				      ,tope.insit_operacao
				  FROM tbrecarga_operacao tope
				 WHERE tope.idoperacao = pr_idoperacao;
			rw_operacao cr_operacao%ROWTYPE;
						
			-- Buscar informações do terminal financeiro
			CURSOR cr_craptfn(pr_cdcoptfn IN craptfn.cdcooper%TYPE
											 ,pr_nrterfin IN craptfn.nrterfin%TYPE) IS
				SELECT tfn.cdoperad
				  FROM craptfn tfn
				 WHERE tfn.cdcooper = pr_cdcoptfn
					 AND tfn.nrterfin = pr_nrterfin;
			
      -- Busca operadora
      CURSOR cr_operadora (pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE) IS
        SELECT opr.perreceita
              ,opr.cdhisdeb_centralizacao
              ,opr.nmoperadora
          FROM tbrecarga_operadora opr
         WHERE opr.cdoperadora = pr_cdoperadora;
      rw_operadora cr_operadora%ROWTYPE;
      
			-- Buscar outras operações de recarga com os mesmos dados
			CURSOR cr_operacao_repetida(pr_cdcooper  IN tbrecarga_operacao.cdcooper%TYPE
			                           ,pr_nrdconta  IN tbrecarga_operacao.nrdconta%TYPE
																 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE
																 ,pr_nrdddtel  IN tbrecarga_operacao.nrddd%TYPE
																 ,pr_nrcelular IN tbrecarga_operacao.nrcelular%TYPE
																 ,pr_vlrecarga IN tbrecarga_operacao.vlrecarga%TYPE
																 ,pr_nsuopera  IN tbrecarga_operacao.dsnsu_operadora%TYPE) IS
			  SELECT 1
				  FROM tbrecarga_operacao tope
				 WHERE tope.cdcooper = pr_cdcooper
					 AND tope.nrdconta = pr_nrdconta
					 AND tope.dtrecarga = pr_dtrecarga
					 AND tope.nrddd = pr_nrdddtel
					 AND tope.nrcelular = pr_nrcelular
					 AND tope.vlrecarga = pr_vlrecarga
					 AND tope.dsnsu_operadora = pr_nsuopera;  /* retornado da operadora */
			rw_operacao_repetida cr_operacao_repetida%ROWTYPE;
			
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			rw_craplcm craplcm%ROWTYPE;
			
			PROCEDURE pc_gera_log_erro(pr_cdcooper    IN crapcop.cdcooper%TYPE
				                        ,pr_nrdconta    IN crapass.nrdconta%TYPE
				                        ,pr_idorigem    IN INTEGER
																,pr_idseqttl    IN INTEGER
																,pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE
																,pr_nrdddtel    IN tbrecarga_favorito.nrddd%TYPE
																,pr_nrtelefo    IN tbrecarga_favorito.nrcelular%TYPE
																,pr_vlrecarga   IN tbrecarga_valor.vlrecarga%TYPE
																,pr_idoperacao  IN tbrecarga_operacao.idoperacao%TYPE
																,pr_dserrlog    IN VARCHAR2) IS
			PRAGMA AUTONOMOUS_TRANSACTION;
			BEGIN																
				DECLARE
				   vr_nrdrowid ROWID;
					 vr_dstransa VARCHAR2(100);
					 
					 -- Buscar situação da operação para verificar se é agendamento
					 CURSOR cr_operacao(pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE) IS
					   SELECT tope.insit_operacao
						   FROM tbrecarga_operacao tope
							WHERE tope.idoperacao = pr_idoperacao;
					 vr_sitoperac INTEGER;
					 
					 -- Buscar nome da operadora
					 CURSOR cr_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE) IS
					   SELECT topr.nmoperadora
						   FROM tbrecarga_operadora topr
							WHERE topr.cdoperadora = pr_cdoperadora;
					 vr_nmoperadora tbrecarga_operadora.nmoperadora%TYPE;
				BEGIN
				  OPEN cr_operacao(pr_idoperacao => pr_idoperacao);
				  FETCH cr_operacao INTO vr_sitoperac;
					-- Fechar cursor
					CLOSE cr_operacao;
					-- Verificar se é agendemanto
					IF vr_sitoperac = 1 THEN
					   vr_dstransa := 'Processa agendamento de recarga de celular';
					ELSE
					   vr_dstransa := 'Recarga de celular';
					END IF;						
					
					-- Buscar nome da operadora
					OPEN cr_operadora(pr_cdoperadora => pr_cdoperadora);
					FETCH cr_operadora INTO vr_nmoperadora;
					-- Fechar cursor
					CLOSE cr_operadora;
					
					-- Gerar log
					gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
															,pr_cdoperad => CASE 
																							WHEN pr_idorigem = 5 THEN 1
																							ELSE 996 END
															,pr_dscritic => 'Nao foi possivel efetuar a recarga'
															,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
															,pr_dstransa => vr_dstransa
															,pr_dttransa => TRUNC(SYSDATE)
															,pr_flgtrans => 0
															,pr_hrtransa => gene0002.fn_busca_time
															,pr_idseqttl => pr_idseqttl
															,pr_nmdatela => pr_nmprogra
															,pr_nrdconta => pr_nrdconta
															,pr_nrdrowid => vr_nrdrowid);
															
					-- Operadora
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Operadora'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => vr_nmoperadora);
					-- Telefone												 
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Telefone'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => '('||to_char(pr_nrdddtel, 'fm00')||')' ||
																									 to_char(pr_nrtelefo,'fm00000g0000','nls_numeric_characters=.-'));
					-- Valor
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Valor'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => to_char(pr_vlrecarga, 'fm9g999g990d00'));														
																	 
					-- Erro
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Erro'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => pr_dserrlog);																 
          
          IF pr_idorigem = 3 THEN -- Ser for ibank/mobile
          --Origem
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Origem',
                                  pr_dsdadant => NULL,
                                  pr_dsdadatu => CASE pr_flmobile
                                                 WHEN 1 THEN 'MOBILE'
                                                 ELSE pr_nmprogra
                                                  END);															 
          END IF;
          
					-- Efetuar commit;
					COMMIT;
				EXCEPTION
					WHEN OTHERS THEN
						-- Efetua commit
						COMMIT;
			  END;
			END pc_gera_log_erro;
			
		BEGIN
		  -- Buscar data do sistema
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
			-- Se não encontrar
			IF btch0001.cr_crapdat%NOTFOUND THEN
				-- Fechar o cursor pois efetuaremos raise
				CLOSE btch0001.cr_crapdat;
				-- Montar mensagem de critica
				vr_cdcritic := 1;
				vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				
				-- Gerar log
				pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_idorigem => pr_idorigem
												,pr_idseqttl => pr_idseqttl
												,pr_cdoperadora => pr_cdopetel
												,pr_nrdddtel => pr_nrdddtel
												,pr_nrtelefo => pr_nrtelefo
												,pr_vlrecarga => pr_vlrecarga
												,pr_idoperacao => pr_idoperac
												,pr_dserrlog => vr_dscritic);

				RAISE vr_exc_erro;
			ELSE
				-- Apenas fechar o cursor
				CLOSE btch0001.cr_crapdat;
			END IF;

      -- Somar os valores de recarga efetuadas no dia
			OPEN cr_totrecarga(pr_cdcooper => pr_cdcooper);
			FETCH cr_totrecarga INTO vr_totrecar;
			-- Fechar cursos
			CLOSE cr_totrecarga;
			-- Somar total com o valor da recarga
			vr_totrecar := nvl(vr_totrecar,0) + pr_vlrecarga;
			
			-- Buscar limites diário de recarga
			OPEN cr_recparam(pr_cdcooper => pr_cdcooper);
			FETCH cr_recparam INTO rw_recparam;
			-- Fechar cursor
			CLOSE cr_recparam;
			
			-- Buscar tipo de pessoa
			OPEN cr_crapass(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;
			
			-- Se não encontrou associado
			IF cr_crapass%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapass;
				-- Gerar crítica
			  vr_cdcritic := 9;
				vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				
				-- Gerar log
				pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_idorigem => pr_idorigem
												,pr_idseqttl => pr_idseqttl
												,pr_cdoperadora => pr_cdopetel
												,pr_nrdddtel => pr_nrdddtel
												,pr_nrtelefo => pr_nrtelefo
												,pr_vlrecarga => pr_vlrecarga
												,pr_idoperacao => pr_idoperac												
												,pr_dserrlog => vr_dscritic);
																								
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapass;
						
			-- Buscar data de débito
			vr_dtdebito := gene0005.fn_valida_dia_util(pr_cdcooper => 1
													  ,pr_dtmvtolt => SYSDATE
													  ,pr_tipo => 'P'   
													  ,pr_feriado => TRUE
                            ,pr_excultdia => TRUE); --PRB0040602 
			
			-- PF
			IF rw_crapass.inpessoa = 1 THEN
				-- Se o valor total de recarga ultrapassar parametro
				IF vr_totrecar > NVL(rw_recparam.vlmaximo_pf, 0) THEN
					-- Gerar crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Limite diário de recarga excedido. Limite máximo de R$' ||
					               to_char(rw_recparam.vlmaximo_pf, 'fm99g999g990d00');
				  -- Gerar log
				  pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												  ,pr_nrdconta => pr_nrdconta
												  ,pr_idorigem => pr_idorigem
												  ,pr_idseqttl => pr_idseqttl
												  ,pr_cdoperadora => pr_cdopetel
												  ,pr_nrdddtel => pr_nrdddtel
												  ,pr_nrtelefo => pr_nrtelefo
												  ,pr_vlrecarga => pr_vlrecarga
												  ,pr_idoperacao => pr_idoperac													
												  ,pr_dserrlog => vr_dscritic);
																	 					
					-- Levantar exceção
					RAISE vr_exc_erro;
				END IF;
			-- PJ
			ELSE
				-- Se o valor total de recarga ultrapassar parametro				
				IF vr_totrecar > NVL(rw_recparam.vlmaximo_pj, 0) THEN
					-- Gerar crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Limite diário de recarga excedido. Limite máximo de R$' ||
					               to_char(rw_recparam.vlmaximo_pj, 'fm99g999g990d00');												 
				  -- Gerar log
				  pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												  ,pr_nrdconta => pr_nrdconta
												  ,pr_idorigem => pr_idorigem
												  ,pr_idseqttl => pr_idseqttl
												  ,pr_cdoperadora => pr_cdopetel
												  ,pr_nrdddtel => pr_nrdddtel
												  ,pr_nrtelefo => pr_nrtelefo
												  ,pr_vlrecarga => pr_vlrecarga
												  ,pr_idoperacao => pr_idoperac													
												  ,pr_dserrlog => vr_dscritic);
												 
					-- Levantar exceção
					RAISE vr_exc_erro;
				END IF;				
			END IF;
      -- Obtem saldo do cooperado
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper
			                           ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
																 ,pr_cdoperad => CASE 
																                 WHEN pr_idorigem = 5 THEN 1
																								 ELSE 996 END
																 ,pr_nrdconta => pr_nrdconta
																 ,pr_vllimcre => rw_crapass.vllimcre
																 ,pr_dtrefere => rw_crapdat.dtmvtolt
																 ,pr_flgcrass => FALSE
																 ,pr_tipo_busca => 'A'
																 ,pr_des_reto => vr_dscritic
																 ,pr_tab_sald => vr_tab_saldo
																 ,pr_tab_erro => vr_tab_erro);

      -- Se o valor do saldo disponível + valor limite cheque especial for menor que o valor de recarga
			IF (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + 
          nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) < pr_vlrecarga THEN
				 -- Gerar crítica
				 vr_cdcritic := 0;
				 vr_dscritic := 'Não há saldo suficiente para a operação.';
				 -- Gerar log
				 pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												 ,pr_nrdconta => pr_nrdconta
												 ,pr_idorigem => pr_idorigem
												 ,pr_idseqttl => pr_idseqttl
												 ,pr_cdoperadora => pr_cdopetel
												 ,pr_nrdddtel => pr_nrdddtel
												 ,pr_nrtelefo => pr_nrtelefo
												 ,pr_vlrecarga => pr_vlrecarga
												 ,pr_idoperacao => pr_idoperac												 
												 ,pr_dserrlog => vr_dscritic);

				 -- Levantar exceção
				 RAISE vr_exc_erro;
			END IF;
			-- Buscar informações da operadora/produto
			OPEN cr_inf_rec(pr_cdopetel => pr_cdopetel
			               ,pr_cdprodut => pr_cdproduto);
			FETCH cr_inf_rec INTO rw_inf_rec;
      
			-- Se não encontrou 
			IF cr_inf_rec%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_inf_rec;
				-- Gerar crítica
				vr_dserrlog := 'Cadastro de operadora/produto não encontrado.';				
				vr_cdcritic := 0;
				vr_dscritic := 'Não foi possível efetuar a recarga.';
				-- Gerar log
				pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_idorigem => pr_idorigem
												,pr_idseqttl => pr_idseqttl
												,pr_cdoperadora => pr_cdopetel
												,pr_nrdddtel => pr_nrdddtel
												,pr_nrtelefo => pr_nrtelefo
												,pr_vlrecarga => pr_vlrecarga
												,pr_idoperacao => pr_idoperac												
												,pr_dserrlog => vr_dserrlog);
																
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_inf_rec;
			
			-- Buscar operacao
			OPEN cr_operacao(pr_idoperacao => pr_idoperac);
			FETCH cr_operacao INTO rw_operacao;
			-- Flag para verificar se encontrou cursor
			vr_flgoperac := cr_operacao%FOUND;
      -- Fechar cursor
			CLOSE cr_operacao;
			
			-- Se não encontrou operação
			IF NOT vr_flgoperac THEN
				-- Cria operação de recarga
				INSERT INTO tbrecarga_operacao(cdcooper
																			,nrdconta
																			,nrddd
																			,nrcelular
																			,cdoperadora
																			,dttransa
																			,dtrecarga
																			,cdcanal
																			,vlrecarga
																			,cdproduto
																			,insit_operacao)
															 VALUES(pr_cdcooper
																		 ,pr_nrdconta
																		 ,pr_nrdddtel
																		 ,pr_nrtelefo
																		 ,pr_cdopetel
																		 ,SYSDATE
																		 ,trunc(SYSDATE)
																		 ,CASE pr_flmobile WHEN 1 THEN 10 ELSE pr_idorigem END
																		 ,pr_vlrecarga
																		 ,pr_cdproduto
																		 ,0)
														RETURNING idoperacao
																		 ,insit_operacao
																 INTO rw_operacao.idoperacao
																		 ,rw_operacao.insit_operacao;
				-- Efetuar commit para garantir o registro em processamento
				COMMIT;
			END IF;
			
      vr_recarga.put('Cooperativa', pr_cdcooper ); -- Codigo da Cooperativa
			vr_recarga.put('Fornecedor', rw_inf_rec.nmoperadora); -- Nome da operadora
			vr_recarga.put('TipoProduto', rw_inf_rec.tpoperacao); -- Tipo produto FIXO
			vr_recarga.put('Produto', rw_inf_rec.nmproduto);      -- Nome do produto
			vr_recarga.put('Telefone', to_char(pr_nrdddtel) || to_char(pr_nrtelefo)); -- Telefone
			vr_recarga.put('ValorRecarga', pr_vlrecarga ); -- Valor da recarga
			-- Consumir rest do AYMARU
			AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Comercial/Recarga/RealizarVenda'
																				 ,pr_verbo => WRES0001.POST
																				 ,pr_servico => 'RECARGA.CELULAR'
																				 ,pr_parametros => vr_parametros
																				 ,pr_conteudo => vr_recarga
																				 ,pr_resposta => vr_resposta
																				 ,pr_dscritic => vr_dscritic
																				 ,pr_cdcritic => vr_cdcritic);
			-- Se retornou alguma crítica														 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Não foi possível efetuar a recarga.';
				
				     -- saida por TIMEOUT  
				IF   vr_resposta.status_code = 408  THEN
				     vr_dserrlog := 'Timeout-Limite de tempo da requisicao excedido.';
						 
	           -- Se encontrou operação
             IF vr_flgoperac THEN
							 -- Se for agendamento retornar crítica do log para o relatório de agendamentos
							 IF rw_operacao.insit_operacao = 1 THEN
								 vr_cdcritic := 888; --> Alimentar cód da crítica como 888 para identificar que erro provém da rede tendencia
								 vr_dscritic := vr_dserrlog;
							 END IF;
						 END IF;
			    ELSE
				     vr_dserrlog := vr_dscritic;
			    END IF;
				
				-- Se for registro em processamento
				IF rw_operacao.insit_operacao = 0 THEN
					-- Devemos atualizar o registro de operação de recarga
					UPDATE tbrecarga_operacao 
					   SET insit_operacao = 8 -- Transação abortada
					 WHERE idoperacao = rw_operacao.idoperacao;
					-- Efetuar commit
					COMMIT;
				END IF;
				
				-- Gerar log
				pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_idorigem => pr_idorigem
												,pr_idseqttl => pr_idseqttl
												,pr_cdoperadora => pr_cdopetel
												,pr_nrdddtel => pr_nrdddtel
												,pr_nrtelefo => pr_nrtelefo
												,pr_vlrecarga => pr_vlrecarga
												,pr_idoperacao => pr_idoperac												
												,pr_dserrlog => vr_dserrlog);

				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
				
			-- Retornou algum código de erro da RedeTendencia
			IF vr_resposta.status_code <> 200 THEN
				IF vr_resposta.conteudo.get('Message').to_char() = '"CODIGO DE TELEFONE INVALIDO"' THEN
					-- Reatribuir crítica
					vr_dscritic := 'Não foi possível efetuar a recarga: número de telefone inválido!';						
				ELSE
					vr_dscritic := 'Não foi possível efetuar a recarga.';
				END IF;

				-- Descrição do erro da Rede Tendencia
				vr_dserrlog := replace(vr_resposta.conteudo.get('Message').to_char(), '"', '');

        -- Se encontrou operação
        IF vr_flgoperac THEN
					-- Se for agendamento retornar crítica do log para o relatório de agendamentos
					IF rw_operacao.insit_operacao = 1 THEN
					  vr_cdcritic := 888; --> Alimentar cód da crítica como 888 para identificar que erro provém da rede tendencia						
						vr_dscritic := vr_dserrlog;
					END IF;
        END IF;
				
				-- Se for registro em processamento
				IF rw_operacao.insit_operacao = 0 THEN
					-- Devemos atualizar o registro de operação de recarga
					UPDATE tbrecarga_operacao 
					   SET insit_operacao = 8 -- Transação abortada
					 WHERE idoperacao = rw_operacao.idoperacao;
					-- Efetuar commit
					COMMIT;
				END IF;
				-- Gerar log
				pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_idorigem => pr_idorigem
												,pr_idseqttl => pr_idseqttl
												,pr_cdoperadora => pr_cdopetel
												,pr_nrdddtel => pr_nrdddtel
												,pr_nrtelefo => pr_nrtelefo
												,pr_vlrecarga => pr_vlrecarga
												,pr_idoperacao => pr_idoperac												
												,pr_dserrlog => vr_dserrlog);
								
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Se não retornar recarga efetivada
			IF replace(vr_resposta.conteudo.get('Status').to_char(), '"', '') <> 'EFETIVADA' THEN
				-- Gerar crítica
				vr_dserrlog := replace(vr_resposta.conteudo.get('Mensagem').to_char(), '"', '');
				vr_cdcritic := 0;
				vr_dscritic := 'Não foi possível efetuar a recarga.';
				
        -- Se encontrou operação
				IF vr_flgoperac THEN
					-- Se for agendamento retornar crítica do log para o relatório de agendamentos
					IF rw_operacao.insit_operacao = 1 THEN
					  vr_cdcritic := 888; --> Alimentar cód da crítica como 888 para identificar que erro provém da rede tendencia												
					  vr_dscritic := vr_dserrlog;
					END IF;
				END IF;
				
				-- Se for registro em processamento
				IF rw_operacao.insit_operacao = 0 THEN
					-- Devemos atualizar o registro de operação de recarga
					UPDATE tbrecarga_operacao 
					   SET insit_operacao = 8 -- Transação abortada
					 WHERE idoperacao = rw_operacao.idoperacao;
					-- Efetuar commit
					COMMIT;
				END IF;
				
				-- Gerar log
				pc_gera_log_erro(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_idorigem => pr_idorigem
												,pr_idseqttl => pr_idseqttl
												,pr_cdoperadora => pr_cdopetel
												,pr_nrdddtel => pr_nrdddtel
												,pr_nrtelefo => pr_nrtelefo
												,pr_vlrecarga => pr_vlrecarga
												,pr_idoperacao => pr_idoperac												
												,pr_dserrlog => vr_dserrlog);
								
				-- Levantar exceção
				RAISE vr_exc_erro;
			ELSE
				-- Atribuir Nsu da operadora e RedeTendencia
				vr_nsuoperadora := replace(vr_resposta.conteudo.get('IdFornecedor').to_char(), '"', '');
				vr_nsutendencia  := replace(vr_resposta.conteudo.get('IdMidlware').to_char(), '"', '');
				
				-- Verificar se existe alguma operação de recarga com os mesmos dados
				OPEN cr_operacao_repetida(pr_cdcooper  => pr_cdcooper
			                           ,pr_nrdconta  => pr_nrdconta
																 ,pr_dtrecarga => TRUNC(SYSDATE)
																 ,pr_nrdddtel  => pr_nrdddtel
																 ,pr_nrcelular => pr_nrtelefo
																 ,pr_vlrecarga => pr_vlrecarga
																 ,pr_nsuopera  => vr_nsuoperadora);
				FETCH cr_operacao_repetida INTO rw_operacao_repetida;
				
				-- Se encontrou, operação já existe
				IF cr_operacao_repetida%FOUND THEN
					-- Fechar cursor
					CLOSE cr_operacao_repetida;
					-- Gerar crítica
					vr_cdcritic := 0;
					vr_dscritic := ''; -- Limpar a crítica
					vr_dserrlog := 'NSU já processado.';
					pr_nsuopera := vr_nsuoperadora;
					
					-- Se for registro em processamento
					IF rw_operacao.insit_operacao = 0 THEN
						-- Devemos atualizar o registro de operação de recarga
						UPDATE tbrecarga_operacao 
							 SET insit_operacao = 8 -- Transação abortada
						 WHERE idoperacao = rw_operacao.idoperacao;
						-- Efetuar commit
						COMMIT;
					END IF;
					
					-- Gerar log
					pc_gera_log_erro(pr_cdcooper => pr_cdcooper
													,pr_nrdconta => pr_nrdconta
													,pr_idorigem => pr_idorigem
													,pr_idseqttl => pr_idseqttl
													,pr_cdoperadora => pr_cdopetel
													,pr_nrdddtel => pr_nrdddtel
													,pr_nrtelefo => pr_nrtelefo
													,pr_vlrecarga => pr_vlrecarga
													,pr_idoperacao => pr_idoperac												
													,pr_dserrlog => vr_dserrlog);
									
					-- Levantar exceção
					RAISE vr_exc_erro;
						
				END IF;
				-- Fechar cursor
				CLOSE cr_operacao_repetida;				
				
        -- Buscar a próxima data de repasse de valores para o fornecedor
        vr_dtrepasse := fn_calcula_proximo_repasse(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtrefere => SYSDATE);
        
        OPEN cr_operadora (pr_cdopetel);
        FETCH cr_operadora INTO rw_operadora;
        -- Busca operadora
        IF cr_operadora%NOTFOUND THEN
          CLOSE cr_operadora;
          vr_dscritic := 'Operadora não encontrada.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_operadora;
        END IF;
       
        -- multiplicar o valor da recarga pelo percentual de receita da operadora
        vr_vrreceita := pr_vlrecarga * (rw_operadora.perreceita / 100);
              
        -- Valor do repasse
        vr_vlrepasse := pr_vlrecarga - vr_vrreceita;
      
					-- Apenas atualiza operação de recarga
					UPDATE tbrecarga_operacao
						 SET dsnsu_operadora = vr_nsuoperadora
								,dsnsu_tendencia = vr_nsutendencia
								,insit_operacao  = 2
								,dtdebito        = vr_dtdebito
                ,dtrepasse       = vr_dtrepasse 
                ,vlrepasse       = vr_vlrepasse
					 WHERE idoperacao = rw_operacao.idoperacao;
				
				-- Buscar sequence
				vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
				                          ,pr_nmdcampo => 'NRSEQDIG'
																	,pr_dsdchave => to_char(pr_cdcooper)||';'||
																	                to_char(vr_dtdebito, 'DD/MM/RRRR')||';'||
																									'1;85;600035');
				
        --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
				INSERT INTO craplcm (cdcooper
														,dtmvtolt
														,cdagenci
														,cdbccxlt
														,nrdolote
														,nrdconta
														,nrdctabb
														,nrdctitg
														,nrdocmto
														,cdhistor
														,nrseqdig
														,nrsequni
														,vllanmto
														,hrtransa
														,cdpesqbb)
										 VALUES (pr_cdcooper
														,vr_dtdebito
														,1
														,85
														,600035
														,pr_nrdconta
														,pr_nrdconta
														,to_char(pr_nrdconta,'fm00000000')
														,vr_nrseqdig
														,rw_inf_rec.cdhisdeb_cooperado
														,vr_nrseqdig
														,vr_nrseqdig
														,pr_vlrecarga
														,to_char(SYSDATE, 'SSSSS')
														,(rw_inf_rec.nmoperadora || ';' ||
														  to_char(pr_nrdddtel) || 
														  to_char(pr_nrtelefo)))
										RETURNING vllanmto
										         ,nrautdoc
														 ,nrdconta
														 ,nrdocmto
														 ,nrsequni
														 ,cdhistor
														 ,hrtransa
												 INTO rw_craplcm.vllanmto
												     ,rw_craplcm.nrautdoc
														 ,rw_craplcm.nrdconta
														 ,rw_craplcm.nrdocmto
                             ,rw_craplcm.nrsequni
														 ,rw_craplcm.cdhistor
														 ,rw_craplcm.hrtransa;
					
			  -- Se for IB ou TAA
				IF pr_idorigem IN (3,4)	THEN
				  -- Atribuir informações do protocolo
					vr_dsinfor1 := 'Recarga de celular';
					vr_dsinfor2 := rw_crapass.nmextttl || '#' ||
                         rw_inf_rec.nmoperadora || '#' ||
					               '('||to_char(pr_nrdddtel, 'fm00')||') ' ||
                         to_char(pr_nrtelefo,'fm00000g0000','nls_numeric_characters=.-') || '#' ||
												 to_char(pr_vlrecarga, 'fm9g999g990d00') || '#' ||
												 vr_nsuoperadora;
					vr_dsinfor3 := CASE WHEN pr_idorigem = 4 THEN 'TAA' ELSE ' ' END;
					
					--Verifica se conta for conta PJ e se exige asinatura multipla
					INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
																						 ,pr_nrdconta => pr_nrdconta
																						 ,pr_idseqttl => pr_idseqttl
																						 ,pr_cdorigem => pr_idorigem
																						 ,pr_idastcjt => vr_idastcjt
																						 ,pr_nrcpfcgc => vr_nrcpfcgc
																						 ,pr_nmprimtl => vr_nmprimtl
																						 ,pr_flcartma => vr_flcartma
																						 ,pr_cdcritic => vr_cdcritic
																						 ,pr_dscritic => vr_dscritic);
					-- Se retornou crítica
					IF nvl(vr_cdcritic,0) <> 0 OR
						 TRIM(vr_dscritic) IS NOT NULL THEN
						 vr_dserrlog := vr_dscritic;
						 vr_dscritic := 'Não foi possível efetuar a recarga.';
		 				 -- Gerar log
						 pc_gera_log_erro(pr_cdcooper => pr_cdcooper
														 ,pr_nrdconta => pr_nrdconta
														 ,pr_idorigem => pr_idorigem
														 ,pr_idseqttl => pr_idseqttl
												     ,pr_cdoperadora => pr_cdopetel
														 ,pr_nrdddtel => pr_nrdddtel
														 ,pr_nrtelefo => pr_nrtelefo
														 ,pr_vlrecarga => pr_vlrecarga
												     ,pr_idoperacao => pr_idoperac														 
														 ,pr_dserrlog => vr_dserrlog);
														 														 
             -- Levantar exceção
						 RAISE vr_exc_erro; 
					END IF;                              								
          -- Gerar protocolo
					GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper
																		,pr_dtmvtolt => vr_dtdebito
																		,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
																		,pr_nrdconta => pr_nrdconta
																		,pr_nrdocmto => rw_craplcm.nrdocmto
																		,pr_nrseqaut => 0
																		,pr_vllanmto => pr_vlrecarga
																		,pr_nrdcaixa => pr_nrdcaixa
																		,pr_gravapro => TRUE
																		,pr_cdtippro => 20 /* recarga de celular */ 
																		,pr_dsinfor1 => vr_dsinfor1
																		,pr_dsinfor2 => vr_dsinfor2
																		,pr_dsinfor3 => vr_dsinfor3
																		,pr_dscedent => NULL
																		,pr_flgagend => FALSE
																		,pr_nrcpfope => pr_nrcpfope
																		,pr_nrcpfpre => vr_nrcpfcgc
																		,pr_nmprepos => vr_nmprimtl
																		,pr_dsprotoc => vr_dsprotoc
																		,pr_dscritic => vr_dscritic
																		,pr_des_erro => vr_des_erro);
					-- Se retornou crítica
			    IF vr_des_erro <> 'OK' OR
				     TRIM(vr_dscritic) IS NOT NULL THEN
						 vr_dserrlog := vr_dscritic;
						 vr_dscritic := 'Não foi possível efetuar a recarga.';
		 				 -- Gerar log
						 pc_gera_log_erro(pr_cdcooper => pr_cdcooper
														 ,pr_nrdconta => pr_nrdconta
														 ,pr_idorigem => pr_idorigem
														 ,pr_idseqttl => pr_idseqttl
												     ,pr_cdoperadora => pr_cdopetel
														 ,pr_nrdddtel => pr_nrdddtel
														 ,pr_nrtelefo => pr_nrtelefo
														 ,pr_vlrecarga => pr_vlrecarga
												     ,pr_idoperacao => pr_idoperac														 
														 ,pr_dserrlog => vr_dserrlog);

						 -- Levantar exceção
						 RAISE vr_exc_erro; 
					END IF;                        
					      								
					-- Se operação foi feita no TAA
					IF pr_idorigem = 4  AND 
						 -- Garantir que o processamento dos agendamentos de recarga não crie ltr
						 pr_nrsequni <> 0 AND
						 pr_nrterfin <> 0 AND
						 pr_cdcoptfn <> 0 AND
						 pr_nrcartao <> 0 THEN
						-- Busca operador do TAA
						OPEN cr_craptfn(pr_cdcoptfn => pr_cdcoptfn
						               ,pr_nrterfin => pr_nrterfin);
						FETCH cr_craptfn INTO vr_cdopetfn;
						-- Fechar cursor
						CLOSE cr_craptfn;
						
						-- Inserir log de transação no TAA
						INSERT INTO crapltr(cdcooper
															 ,cdoperad
															 ,nrterfin
															 ,dtmvtolt
															 ,nrautdoc
															 ,nrdconta
															 ,nrdocmto
															 ,nrsequni
															 ,cdhistor
															 ,vllanmto
															 ,dttransa
															 ,hrtransa
															 ,nrcartao
															 ,tpautdoc
															 ,nrestdoc
															 ,cdsuperv)
												 VALUES(pr_cdcooper
												       ,vr_cdopetfn
															 ,pr_nrterfin
															 ,vr_dtdebito
															 ,rw_craplcm.nrautdoc
															 ,rw_craplcm.nrdconta
															 ,rw_craplcm.nrdocmto
															 ,pr_nrsequni
															 ,rw_craplcm.cdhistor
															 ,rw_craplcm.vllanmto
															 ,trunc(SYSDATE)
															 ,rw_craplcm.hrtransa
															 ,pr_nrcartao
															 ,1
															 ,0
															 ,' ');
						
					END IF;
				END IF;				
				-- Tratamento de log
				IF rw_operacao.insit_operacao = 1 THEN
           vr_dstransa := 'Processa agendamento de recarga de celular';					
				ELSE
           vr_dstransa := 'Recarga de celular';
				END IF;
				vr_dscritic := 'Recarga de celular efetuada com sucesso.';
				-- Gerar log
				gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
				                    ,pr_cdoperad => CASE 
																						WHEN pr_idorigem = 5 THEN '1'
																						ELSE '996' END
														,pr_dscritic => vr_dscritic
														,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
														,pr_dstransa => vr_dstransa
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 1
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => pr_idseqttl
														,pr_nmdatela => pr_nmprogra
														,pr_nrdconta => pr_nrdconta
														,pr_nrdrowid => vr_nrdrowid);
														
				-- Operadora
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Operadora'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => rw_inf_rec.nmoperadora);
				-- Telefone												 
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Telefone'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => '('||to_char(pr_nrdddtel, 'fm00')||')' ||
																                 to_char(pr_nrtelefo,'fm00000g0000','nls_numeric_characters=.-'));
				-- Valor
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Valor'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => to_char(pr_vlrecarga, 'fm9g999g990d00'));														
																 
				-- NSU Operadora
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'NSU Operadora'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => vr_nsuoperadora);
																 
        -- Protocolo
				IF vr_dsprotoc IS NOT NULL THEN
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																	 ,pr_nmdcampo => 'Protocolo'
																	 ,pr_dsdadant => ' '
																	 ,pr_dsdadatu => vr_dsprotoc);
				END IF;
				
				--Se conta exigir Assinatura Multipla
				IF vr_idastcjt = 1 THEN
					-- Nome do representante legal
					gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
																		pr_nmdcampo => 'Nome do Representante/Procurador',
																		pr_dsdadant => ' ', 
																		pr_dsdadatu => vr_nmprimtl);
																		
					-- CPF do representante legal
					gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
																		pr_nmdcampo => 'CPF do Representante/Procurador', 
																		pr_dsdadant => ' ', 
																		pr_dsdadatu =>TO_CHAR(gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1)));
        END IF;
				
        IF pr_idorigem = 3 THEN -- Ser for ibank/mobile
        --Origem
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Origem',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => CASE pr_flmobile
                                               WHEN 1 THEN 'MOBILE'
                                               ELSE pr_nmprogra
                                                END);
        END IF;
				
				-- Retornar o nsu da operadora
				pr_nsuopera := vr_nsuoperadora;
				pr_dsprotoc := vr_dsprotoc;
			END IF;
				
			-- Efetuar commit
			COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_cdcritic <> 888 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
		    -- Retornar erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
				
				-- Efetuar rollback
				ROLLBACK;
      WHEN OTHERS THEN
		    -- Retornar erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
				-- Efetuar
				ROLLBACK;
    END;
	END pc_efetua_recarga;
	
	-- Cadastrar agendamento de recarga
	PROCEDURE pc_cadastra_agendamento(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
		                               ,pr_nrdconta IN crapass.nrdconta%TYPE   -- Nr. da conta
																	 ,pr_cdoperad IN crapope.cdoperad%TYPE   -- Operador
																	 ,pr_nrcpfope IN crapsnh.nrcpfcgc%TYPE   -- Nr. do cpf do operador da conta
																	 ,pr_idseqttl IN INTEGER                 -- Titular
																	 ,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
																	 ,pr_nrdddtel IN tbrecarga_favorito.nrddd%TYPE   -- DDD
																	 ,pr_nrtelefo IN tbrecarga_favorito.nrcelular%TYPE -- Telefone
																	 ,pr_cdproduto IN tbrecarga_produto.cdproduto%TYPE -- Cód. do produto
																	 ,pr_cdoperadora IN tbrecarga_operacao.cdoperadora%TYPE -- Cód. operadora
																	 ,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE -- Data de recarga
																	 ,pr_lsdatagd IN VARCHAR2 DEFAULT NULL             -- Lista de datas para agendamento
																	 ,pr_idorigem IN INTEGER                            -- Id. de origem
                                     ,pr_nmprogra IN VARCHAR2                           -- Nome do Programa
																	 ,pr_idoperac IN tbrecarga_operacao.idoperacao%TYPE -- Id. operação (Somente na aprovação de transação pendente)
                                     ,pr_dslancto OUT VARCHAR2                          -- Lista de ID Operação
																	 ,pr_cdcritic OUT PLS_INTEGER                       -- Cód. da crítica
																	 ,pr_dscritic OUT VARCHAR2) IS                      -- Desc. da crítica
  BEGIN																	 
  /* .............................................................................
    Programa: pc_cadastra_agendamento
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cadastrar agendamento de recarga de celular para data 
		            futura ou recorrente

    Alteracoes: 
	
				19/08/2019 - Bloqueio adicional para evitar agendamentos de recarga na data atual (Diógenes - INC0022696)
				
    ..............................................................................*/
	  DECLARE
	  -- Variavel de criticas
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
			-- Variáveis auxiliares
			vr_lsdatagd gene0002.typ_split;
			vr_dstransa   VARCHAR2(1000);
			vr_nrdrowid   ROWID;
      vr_nmopetel   tbrecarga_operadora.nmoperadora%TYPE;
      vr_idlancto   INTEGER;
      vr_dslancto   VARCHAR2(30000) := '';
					
      -- Buscar informações da operadora
			CURSOR cr_operadora IS
			  SELECT opr.nmoperadora
				  FROM tbrecarga_operadora opr
				 WHERE opr.cdoperadora = pr_cdoperadora;
			
		BEGIN
			-- Verificar se agendamento para data futura
			IF TRIM(pr_lsdatagd) IS NULL THEN
				-- Se possui idoperação é transação pendente
				IF nvl(pr_idoperac,0) > 0 THEN
				  -- Atualizar registro de agendamento de recarga
					UPDATE tbrecarga_operacao
					   SET insit_operacao = 1
					 WHERE idoperacao = pr_idoperac
					   AND insit_operacao = 3; -- Transação pendente
				ELSE
				
			        IF (pr_dtrecarga <= TRUNC(SYSDATE)) THEN
						vr_cdcritic := 1500; 
						RAISE vr_exc_erro; 
					END IF; 
				
					-- Insere registro de agendamento para data futura
					INSERT INTO tbrecarga_operacao(cdcooper
																				,nrdconta
																				,nrddd
																				,nrcelular
																				,cdoperadora
																				,dttransa
																				,dtrecarga
																				,cdcanal
																				,vlrecarga
																				,insit_operacao
																				,cdproduto)
																	VALUES(pr_cdcooper
																				,pr_nrdconta
																				,pr_nrdddtel
																				,pr_nrtelefo
																				,pr_cdoperadora
																				,SYSDATE
																				,pr_dtrecarga
																				,pr_idorigem
																				,pr_vlrecarga
																				,1 -- Agendado
                                                  ,pr_cdproduto)
                                           RETURNING idoperacao INTO vr_idlancto;
                  IF TRIM(vr_dslancto) IS NOT NULL THEN
                    vr_dslancto := vr_dslancto || ',';
                  END IF;
                  vr_dslancto := vr_dslancto || to_char(vr_idlancto);
				END IF;
			ELSE -- Agendamento recorrente
			  -- Quebrar as datas de agendamento
				vr_lsdatagd := GENE0002.fn_quebra_string(pr_string  => pr_lsdatagd, 
                                                 pr_delimit => ',');
				-- Devemos gerar uma operação de recarga para cada data de agendamento
        FOR i IN vr_lsdatagd.FIRST..vr_lsdatagd.LAST LOOP
		
					IF (TO_DATE(vr_lsdatagd(i), 'DD/MM/RRRR') <= TRUNC(SYSDATE)) THEN
						vr_cdcritic := 1500; 
						RAISE vr_exc_erro; 
					END IF; 
		
					-- Insere registro de agendamento recorrente
					INSERT INTO tbrecarga_operacao(cdcooper
																				,nrdconta
																				,nrddd
																				,nrcelular
																				,cdoperadora
																				,dttransa
																				,dtrecarga
																				,cdcanal
																				,vlrecarga
																				,insit_operacao
																				,cdproduto)
																	VALUES(pr_cdcooper
																				,pr_nrdconta
																				,pr_nrdddtel
																				,pr_nrtelefo
																				,pr_cdoperadora
																				,SYSDATE
																				,to_date(vr_lsdatagd(i), 'DD/MM/RRRR')
																				,pr_idorigem
																				,pr_vlrecarga
																				,1 -- Agendado
                                                  ,pr_cdproduto)
                                           RETURNING idoperacao INTO vr_idlancto;
                    IF TRIM(vr_dslancto) IS NOT NULL THEN
                      vr_dslancto := vr_dslancto || ',';
                    END IF;
                    vr_dslancto := vr_dslancto || to_char(vr_idlancto);
        END LOOP;
			END IF;
			
			-- Tratar mensagens de log
			vr_dstransa := 'Agendamento para recarga de celular.';
			vr_dscritic := 'Recarga de celular agendada com sucesso.';
			
			-- Gerar log
			GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
													,pr_cdoperad => pr_cdoperad
													,pr_dscritic => vr_dscritic
													,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
													,pr_dstransa => vr_dstransa
													,pr_dttransa => TRUNC(SYSDATE)
													,pr_flgtrans => 1
													,pr_hrtransa => gene0002.fn_busca_time
													,pr_idseqttl => pr_idseqttl
													,pr_nmdatela => pr_nmprogra
													,pr_nrdconta => pr_nrdconta
													,pr_nrdrowid => vr_nrdrowid);
			-- Operador
			IF pr_nrcpfope > 0  THEN
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Operador'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu =>gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
			END IF;
				
			-- Busca nome da operadora
			OPEN cr_operadora;
			FETCH cr_operadora INTO vr_nmopetel;
			CLOSE cr_operadora;
				
			-- Operadora
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Operadora'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => vr_nmopetel);
			-- Telefone												 
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Telefone'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => '('||to_char(pr_nrdddtel, 'fm00')||')' ||
																							 to_char(pr_nrtelefo,'fm00000g0000','nls_numeric_characters=.-'));
			-- Valor
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Valor'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => to_char(pr_vlrecarga, 'fm9g999g990d00'));
																 
			IF TRIM(pr_lsdatagd) IS NULL THEN
				-- Agendamento data futura					
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Data do Agendamento'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => to_char(pr_dtrecarga, 'DD/MM/RRRR'));
			ELSE
				-- Agendamento recorrente
				GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 ,pr_nmdcampo => 'Agendamento recorrente'
																 ,pr_dsdadant => ' '
																 ,pr_dsdadatu => 'Dia '|| to_char(pr_dtrecarga, 'DD')||
																								 ', ' || to_char(vr_lsdatagd.count) || ' mes(es), inicio em ' ||
																								 to_char(pr_dtrecarga, 'DD/MM/RRRR'));
			END IF;
				
			-- Efetuar commit
			COMMIT;
            -- Devolver a lista de agendamento 
            pr_dslancto := vr_dslancto;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
		    -- Retornar erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
				
				-- Efetuar rollback
				ROLLBACK;
      WHEN OTHERS THEN
		    -- Retornar erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
				-- Efetuar
				ROLLBACK;
    END;																 
	END pc_cadastra_agendamento;
	
  PROCEDURE pc_job_solicita_produtos IS
	 /* ..........................................................................

   Programa: pc_job_solicita_produtos
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Lucas Reinert
   Data    : Março/2017.                     Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Enviar requisição para receber e atualizar os produtos e valores 
	             disponíveis para Recarga de Celular

   Alteracoes: 31/05/2017 - Adicionados parametros Cooperativa e CNPJ na requisição
                            ListarProdutos do Aymaru. PRJ 321 - Recarga de Celular (Lombardi)
  ..........................................................................*/
	  -- Variáveis auxiliares
	  vr_cdprogra  VARCHAR2(40) := 'RCEL0001.PC_SOLICITA_PRODUTOS_RECARGA';
		vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);

		-- Variáveis para utilizar o Aymaru
		vr_resposta AYMA0001.typ_http_response_aymaru;
		vr_parametros WRES0001.typ_tab_http_parametros;
		vr_recarga json := json();
		
		-- Variavel de criticas
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(10000);
		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		
  BEGIN
		-- Gera log no início da execução
    pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)
									 
    vr_parametros(1).chave := 'Cooperativa';
    vr_parametros(1).valor := 3;
    
		-- Consumir rest do AYMARU
		AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Comercial/Recarga/ListarProdutos'
																			 ,pr_verbo => WRES0001.GET
																			 ,pr_servico => 'RECARGA.CELULAR'
																			 ,pr_parametros => vr_parametros
																			 ,pr_conteudo => vr_recarga
																			 ,pr_resposta => vr_resposta
																			 ,pr_dscritic => vr_cdcritic
																			 ,pr_cdcritic => vr_dscritic);
		-- Se retornou alguma crítica														 
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;	
		
		-- Retornou algum código de erro da RedeTendencia
		IF vr_resposta.status_code <> 200 THEN
			-- Descrição do erro da Rede Tendencia
			vr_dscritic := replace(vr_resposta.conteudo.get('Message').to_char(), '"', '');				
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
		pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
									 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
									 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
										-- Parametros para Ocorrencia
									 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
								 
		-- Efetuar commit
		COMMIT;									 
	EXCEPTION
    WHEN vr_exc_erro THEN
			ROLLBACK;        
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar código da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			
			pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
										 ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,pr_tpocorrencia  => 3             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
										 ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
										 ,pr_dsmensagem    => vr_dscritic   --> Crítica
										 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
										 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

			pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
										 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
			COMMIT;                              		
    WHEN OTHERS THEN
			ROLLBACK;       
			
			vr_dscritic := 'Erro não tratado na execução da procedure pc_solicita_produtos_recarga -> '||SQLERRM;   --> dscritic       
			pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
										 ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
										 ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
										 ,pr_dsmensagem    => vr_dscritic
										 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
										 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

			pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
										 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
										 
			-- buscar destinatarios do email                           
			vr_email_dest := gene0001.fn_param_sistema('CRED',3 ,'ERRO_EMAIL_JOB');
        
			-- Gravar conteudo do email, controle com substr para não estourar campo texto
			vr_conteudo := substr('ERRO NA EXECUCAO JOB: JBRCEL_atualiza_produtos_recarga' ||
										 '<br>Cooperativa: '     || to_char(3, '990')||                      
										 '<br>Critica: '         || vr_dscritic,1,4000);
                        
			vr_dscritic := NULL;
			--/* Envia e-mail para o Operador */
			gene0003.pc_solicita_email(pr_cdcooper        => 3
																,pr_cdprogra        => vr_cdprogra
																,pr_des_destino     => vr_email_dest
																,pr_des_assunto     => 'ERRO NA EXECUCAO JOB: JBRCEL_atualiza_produtos_recarga'
																,pr_des_corpo       => vr_conteudo
																,pr_des_anexo       => NULL
																,pr_flg_remove_anex => 'N' --> Remover os anexos passados
																,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
																,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
																,pr_des_erro        => vr_dscritic);
										 
			COMMIT;                              		
	END pc_job_solicita_produtos;
	
	PROCEDURE pc_atualiza_produtos_recarga(pr_xmlrequi IN xmltype
																				,pr_cdcritic IN OUT NUMBER
																				,pr_dscritic IN OUT VARCHAR2
																				,pr_dsdetcri IN OUT VARCHAR2) IS
	/* .............................................................................

	Programa: pc_atualiza_produtos_recarga
  Sistema : Conta-Corrente - Cooperativa de Credito
	Autor   : Lucas Reinert
	Data    : Março/2017                 Ultima atualizacao:

	Dados referentes ao programa:

	Frequencia: Sempre que for chamado

	Objetivo  : Rotina para receber a requisição do Aymaru efetuada pela 
              pc_solicita_produtos_recarga e atualizar os produtos e valores de 
							recarga de celular
	Alteracoes: 30/05/2017 - Ajuste para desprezar o produto "SERCOMTEL FIXO".
                           Projeto 321 - Recarga de Celular (Lombardi)
                           
              05/07/2017 - Ajuste para desprezar qualquer produto com "FIXO"
                           no nome. Projeto 321 - Recarga de Celular (Lombardi)
	..............................................................................*/
	
	-- Variavel de criticas
	vr_cdcritic crapcri.cdcritic%TYPE;
	vr_dscritic VARCHAR2(10000);

	-- Tratamento de erros
	vr_exc_erro EXCEPTION;

	-- Variáveis auxiliares
	vr_cdprogra  VARCHAR2(40) := 'RCEL0001.PC_ATUALIZA_PRODUTOS_RECARGA';
	vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
	vr_cdoperadora tbrecarga_operadora.cdoperadora%TYPE;	
	vr_cdproduto tbrecarga_produto.cdproduto%TYPE;
	vr_vlminimo NUMBER := 0;
	vr_vlmaximo NUMBER := 0;
	
	-- Verificar se operadora existe
	CURSOR cr_operadora(pr_nmoperadora IN tbrecarga_operadora.nmoperadora%TYPE) IS
	  SELECT tope.cdoperadora
		  FROM tbrecarga_operadora tope
		 WHERE upper(tope.nmoperadora) = pr_nmoperadora;
	rw_operadora cr_operadora%ROWTYPE;	 
	
	-- Verificar se produto existe
	CURSOR cr_produto(pr_cdoperadora IN tbrecarga_produto.cdoperadora%TYPE
	                 ,pr_nmproduto IN tbrecarga_produto.nmproduto%TYPE) IS
	  SELECT tprd.cdproduto
		      ,tprd.tpproduto
					,tprd.tpoperacao
					,tprd.vlminimo
					,tprd.vlmaximo
					,rowid
		  FROM tbrecarga_produto tprd
		 WHERE tprd.cdoperadora = pr_cdoperadora
		   AND upper(tprd.nmproduto) = pr_nmproduto;		
	rw_produto cr_produto%ROWTYPE;	 
				 
	-- Itera sobre as operadoras do xml
	CURSOR cr_xmlOperadoras IS
		WITH DATA AS (SELECT pr_xmlrequi xml FROM dual)
	SELECT ROWNUM   idregist
				,nmoperadora
		FROM DATA
			 , XMLTABLE(XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' AS "XML-SCHEMA"
															 ,'Fornecedores' AS "NS1")
															 ,'/ListaOpcoesRecargas/Fornecedores/Fornecedor'
									PASSING xml
									COLUMNS nmoperadora   VARCHAR2(100) PATH 'Nome');

  -- Itera sobre os produtos da operadora				
	CURSOR cr_xmlProdutos(pr_idregist IN INTEGER) IS
		WITH DATA AS (SELECT pr_xmlrequi xml FROM dual)
	SELECT ROWNUM   idregist
				,nmproduto
				,tpoperacao
				,decode(upper(tpproduto),'TRUE',2,1) tpproduto
		FROM DATA
			 , XMLTABLE(XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' AS "XML-SCHEMA"
															 ,'Fornecedores' AS "NS1")
															 ,to_char('/ListaOpcoesRecargas/Fornecedores/Fornecedor['||pr_idregist||']/Produtos/Produto')
									PASSING xml
									COLUMNS nmproduto     VARCHAR2(100) PATH 'Nome'
									       ,tpoperacao    VARCHAR2(15)  PATH 'TipoProduto'
												 ,tpproduto     VARCHAR2(10)  PATH 'ValorPorFaixa');
	
	-- Itera sobre os valores dos produtos
  CURSOR cr_xmlValores(pr_idregist_ope IN INTEGER
	                    ,pr_idregist_prd IN INTEGER) IS
	WITH DATA AS (SELECT pr_xmlrequi xml FROM dual)
	SELECT ROWNUM   idregist
				,to_number(vlrecarga, 'fm999g990d00', 'nls_numeric_characters=.-') vlrecarga
		FROM DATA
			 , XMLTABLE(XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' AS "XML-SCHEMA"
															 ,'Fornecedores' AS "NS1")
															 ,to_char('/ListaOpcoesRecargas/Fornecedores/Fornecedor['||pr_idregist_ope||']/Produtos/Produto['||pr_idregist_prd||']/ValoresDisponiveis/Valor')
									PASSING xml
									COLUMNS vlrecarga     VARCHAR2(100) PATH 'text()');											
			 
	BEGIN
		-- Gera log no início da execução
    pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)

    -- Se Aymaru enviou alguma crítica
    IF nvl(pr_cdcritic,0) > 0 OR TRIM(pr_dscritic) IS NOT NULL THEN
			-- Atribuir crítica
			vr_dscritic := pr_dscritic;
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
    -- Iterar as operadoras do XML
    FOR rw_xmlOperadora IN cr_xmlOperadoras LOOP
			
		  -- Verificar se operadora existe
			OPEN cr_operadora(pr_nmoperadora => upper(rw_xmlOperadora.nmoperadora));
			FETCH cr_operadora INTO rw_operadora;
			
			-- Se não encontrou operadora
			IF cr_operadora%NOTFOUND THEN
				-- Criar nova operadora
				INSERT INTO tbrecarga_operadora(nmoperadora
																			 ,flgsituacao)
															   VALUES(rw_xmlOperadora.nmoperadora
																       ,0) -- Inativa
																RETURNING cdoperadora
																     INTO vr_cdoperadora; 
      ELSE
				-- Apenas pega o código da operadora																		 
				vr_cdoperadora := rw_operadora.cdoperadora;
			END IF;
			-- Fechar cursor
			CLOSE cr_operadora;
			
			-- Iterar os produtos da respectiva operadora
      FOR rw_xmlProduto IN cr_xmlProdutos(pr_idregist => rw_xmlOperadora.idregist) LOOP
				
			  -- Verificar se produto existe
				OPEN cr_produto(pr_cdoperadora => vr_cdoperadora
				               ,pr_nmproduto   => upper(rw_xmlProduto.nmproduto));
				FETCH cr_produto INTO rw_produto;
				
				-- Se não encontrar produto
				IF cr_produto%NOTFOUND THEN
					-- Valor por faixa
					IF rw_xmlProduto.tpproduto = 2 THEN
						-- Zerar valor mínimo e máximo
						vr_vlminimo := 0;
						vr_vlmaximo := 0;
						-- Iterar sobre os valores do respectivo produto
					  FOR rw_xmlValor IN cr_xmlValores(pr_idregist_ope => rw_xmlOperadora.idregist
							                              ,pr_idregist_prd => rw_xmlProduto.idregist) LOOP
						  -- Valor mínimo
							IF rw_xmlValor.idregist = 1 THEN
								vr_vlminimo := rw_xmlValor.vlrecarga;
							ELSE -- Valor máximo
								vr_vlmaximo := rw_xmlValor.vlrecarga;																
							END IF;
						END LOOP;
						-- Criar novo produto
						INSERT INTO tbrecarga_produto(cdoperadora
																				 ,nmproduto
																				 ,tpproduto
																				 ,vlminimo
																				 ,vlmaximo
																				 ,tpoperacao)
																   VALUES(vr_cdoperadora
																	       ,rw_xmlProduto.nmproduto
																				 ,2 -- Valor por faixa
																				 ,vr_vlminimo
																				 ,vr_vlmaximo
																				 ,rw_xmlProduto.tpoperacao);
					ELSE -- Valor pré-fixado
            
            IF rw_xmlProduto.nmproduto NOT LIKE '%FIXO%' THEN
              
						-- Criar novo produto
						INSERT INTO tbrecarga_produto(cdoperadora
																				 ,nmproduto
																				 ,tpproduto
																				 ,tpoperacao)
																   VALUES(vr_cdoperadora
																	       ,rw_xmlProduto.nmproduto
																				 ,1 -- Valor pré-fixado
																				 ,rw_xmlProduto.tpoperacao)
																RETURNING cdproduto
																     INTO vr_cdproduto;
																				 
						-- Iterar sobre os valores do respectivo produto
					  FOR rw_xmlValor IN cr_xmlValores(pr_idregist_ope => rw_xmlOperadora.idregist
							                              ,pr_idregist_prd => rw_xmlProduto.idregist) LOOP
							-- Inserir valor de recarga
              INSERT INTO tbrecarga_valor(cdoperadora
							                           ,cdproduto
																				 ,vlrecarga
																				 ,dtmvtolt)
							                     VALUES(vr_cdoperadora
																	       ,vr_cdproduto
																				 ,rw_xmlValor.vlrecarga
																				 ,trunc(SYSDATE));
						END LOOP;																				 
					END IF;
					END IF;
				ELSE
					-- Se produto mudou o tipo ou operação
					IF (rw_xmlProduto.tpproduto  <> rw_produto.tpproduto)  OR
						 (rw_xmlProduto.tpoperacao <> nvl(rw_produto.tpoperacao, ' ')) THEN
						-- Devemos atualizar o produto
						UPDATE tbrecarga_produto
						   SET tpproduto  = rw_xmlProduto.tpproduto
							    ,tpoperacao = rw_xmlProduto.tpoperacao
									,vlminimo   = 0
									,vlmaximo   = 0
						 WHERE tbrecarga_produto.rowid = rw_produto.rowid;
					END IF;
					-- Se produto é por faixa
					IF rw_produto.tpproduto = 2 THEN
						-- Zerar valor mínimo e máximo
						vr_vlminimo := rw_produto.vlminimo;
						vr_vlmaximo := rw_produto.vlmaximo;
						-- Iterar sobre os valores do respectivo produto
						FOR rw_xmlValor IN cr_xmlValores(pr_idregist_ope => rw_xmlOperadora.idregist
																						,pr_idregist_prd => rw_xmlProduto.idregist) LOOP
							-- Valor mínimo
							IF rw_xmlValor.idregist = 1 THEN
								vr_vlminimo := rw_xmlValor.vlrecarga;
							ELSE -- Valor máximo
								vr_vlmaximo := rw_xmlValor.vlrecarga;																
							END IF;

						END LOOP;

						-- Devemos atualizar valor mínimo e máximo de recarga
						UPDATE tbrecarga_produto
							 SET vlminimo = vr_vlminimo
									,vlmaximo = vr_vlmaximo
						 WHERE tbrecarga_produto.rowid = rw_produto.rowid;

          ELSE -- Valores pré-fixados
						-- Iterar sobre os valores do respectivo produto
					  FOR rw_xmlValor IN cr_xmlValores(pr_idregist_ope => rw_xmlOperadora.idregist
							                              ,pr_idregist_prd => rw_xmlProduto.idregist) LOOP
							-- Inserir valor de recarga
              INSERT INTO tbrecarga_valor(cdoperadora
							                           ,cdproduto
																				 ,vlrecarga
																				 ,dtmvtolt)
							                     VALUES(vr_cdoperadora
																	       ,rw_produto.cdproduto
																				 ,rw_xmlValor.vlrecarga
																				 ,trunc(SYSDATE));

						END LOOP;																				 
					END IF;												 
				END IF;
				-- Fechar cursor
				CLOSE cr_produto;
			END LOOP;
		END LOOP;

    -- Gera log no fim da execução
		pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
									 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
									 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
										-- Parametros para Ocorrencia
									 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          

		-- Efetuar commit
		COMMIT;									 
	EXCEPTION
    WHEN vr_exc_erro THEN
			ROLLBACK;        
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar código da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
			pr_dsdetcri := pr_dscritic;
			
			-- Gerar log de erro
			pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
										 ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,pr_tpocorrencia  => 3             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
										 ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
										 ,pr_dsmensagem    => vr_dscritic   --> Crítica
										 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
										 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

			pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
										 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
			COMMIT;                              		
    WHEN OTHERS THEN
			ROLLBACK;        
			-- Repassar crítica
			pr_cdcritic := 0;
			pr_dscritic := 'Erro não tratado na execução da procedure pc_atualiza_produtos_recarga -> '||SQLERRM;
			pr_dsdetcri := pr_dscritic;
			-- Gerar log de erro
			pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
										 ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
										 ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
										 ,pr_dsmensagem    => pr_dscritic   --> dscritic       
										 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
										 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

			pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
										 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
										 										 
			COMMIT;                              																	
  END pc_atualiza_produtos_recarga;
	
	-- Carrega os agendamentos de recarga de celular
  PROCEDURE pc_carrega_agend_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                         ,pr_situacao  IN INTEGER 
                                         ,pr_dtinicial IN DATE
                                         ,pr_dtfinal   IN DATE
                                    ,pr_tab_age_recarga  OUT typ_tab_age_recarga
																		,pr_qttotage OUT NUMBER
                                         ,pr_cdcritic OUT PLS_INTEGER
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_carrega_agend_recarga
    Sistema : Ayllos Web
    Autor   : Lucas Lunelli
    Data    : Set/2017                 Ultima atualizacao: 16/07/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :  Rotina para carregar os agendamentos de recarga de celular

    Alteracoes: 16/07/2018 - Inclusão do campo dsorigem no retorno da procedure, Prj. 363 (Jean Michel)

    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
			vr_index      NUMBER;                --> Indexador para PL Table			
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			vr_exc_iter EXCEPTION;             --> Controle de iteração
			
	    -- Cursor para listar os agendamentos de recarga
		  CURSOR cr_agendamentos (pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE
                             ,pr_situacao  IN INTEGER 
                             ,pr_dtinicial IN DATE
                             ,pr_dtfinal   IN DATE) IS
 			  SELECT opc.idoperacao
              ,opc.dtrecarga
              ,opc.dttransa
              ,opc.vlrecarga
							,opc.insit_operacao
              ,(CASE WHEN opc.insit_operacao = 1 THEN 'Pendente'
					           WHEN opc.insit_operacao = 4 THEN 'Cancelado'
										 ELSE 'Nao efetivado'
               END) dssit_operacao
              ,(CASE WHEN opc.insit_operacao = 1 THEN 1
					           ELSE 2
               END) incancel
              ,opc.nrddd 
              ,opc.nrcelular
              ,opa.nmoperadora
              ,ent.nmcanal
          FROM tbrecarga_operacao opc
              ,tbrecarga_operadora opa
              ,tbgen_canal_entrada ent
         WHERE opc.cdcooper = pr_cdcooper
           AND (pr_nrdconta = 0 OR opc.nrdconta = pr_nrdconta)
           AND ((pr_situacao = 0
           AND opc.insit_operacao IN (1,4,5))
            OR opc.insit_operacao = pr_situacao)
           AND ((pr_dtinicial IS NULL AND pr_dtfinal IS null) 
					  OR opc.dtrecarga BETWEEN pr_dtinicial AND pr_dtfinal)
           AND opa.cdoperadora = opc.cdoperadora
           AND opc.cdcanal = ent.cdcanal;

		BEGIN				
			
		  pr_qttotage := 0;									 

			FOR rw_agendamentos IN cr_agendamentos (pr_cdcooper  => pr_cdcooper
                                             ,pr_nrdconta  => pr_nrdconta
                                             ,pr_situacao  => pr_situacao
                                             ,pr_dtinicial => pr_dtinicial
                                             ,pr_dtfinal   => pr_dtfinal) LOOP
				BEGIN
					
					vr_index := pr_tab_age_recarga.count + 1;
					pr_qttotage := pr_qttotage + 1;				
				
				  pr_tab_age_recarga(vr_index).dtrecarga      := rw_agendamentos.dtrecarga;
					pr_tab_age_recarga(vr_index).idoperacao     := rw_agendamentos.idoperacao;
					pr_tab_age_recarga(vr_index).dttransa       := rw_agendamentos.dttransa;
					pr_tab_age_recarga(vr_index).vlrecarga      := rw_agendamentos.vlrecarga;
					pr_tab_age_recarga(vr_index).insit_operacao := rw_agendamentos.insit_operacao;
					pr_tab_age_recarga(vr_index).dssit_operacao := rw_agendamentos.dssit_operacao;
					pr_tab_age_recarga(vr_index).nrddd          := rw_agendamentos.nrddd;
					pr_tab_age_recarga(vr_index).nrcelular      := rw_agendamentos.nrcelular;
					pr_tab_age_recarga(vr_index).nmoperadora    := rw_agendamentos.nmoperadora;
					pr_tab_age_recarga(vr_index).incancel       := rw_agendamentos.incancel;
					pr_tab_age_recarga(vr_index).dscritic      := ''; -- Alimentar DSCRITIC - P.285 Novo InternetBanking
          pr_tab_age_recarga(vr_index).dsorigem       := rw_agendamentos.nmcanal;
				EXCEPTION
						WHEN vr_exc_iter THEN
							-- Somente passa para a próxima iteração do LOOP
							NULL;
					END;
      END LOOP;														 

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
  END pc_carrega_agend_recarga;
           
	-- Obtem os agendamentos de recarga de celular
  PROCEDURE pc_obtem_agendamentos_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                         ,pr_origem    IN INTEGER
                                         ,pr_situacao  IN INTEGER 
                                         ,pr_dtinicial IN DATE
                                         ,pr_dtfinal   IN DATE
                                         ,pr_clobxml  OUT CLOB
                                         ,pr_cdcritic OUT PLS_INTEGER
                                         ,pr_dscritic OUT VARCHAR2) IS
		BEGIN
    /* .............................................................................
    Programa: pc_obtem_agendamentos_recarga
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :  Rotina para buscar os agendamentos de recarga de celular

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
			vr_tab_age_recarga   rcel0001.typ_tab_age_recarga;    --> PL Table para filtrar registros (retorno)
			vr_qttotage   NUMBER;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
			
			-- Variáveis auxiliares
			vr_dstransa VARCHAR2(1000);
			vr_nrdrowid ROWID;
							 
		BEGIN
			
		  pc_carrega_agend_recarga(pr_cdcooper        => pr_cdcooper
															,pr_nrdconta        => pr_nrdconta
															,pr_situacao        => pr_situacao
															,pr_dtinicial       => pr_dtinicial
															,pr_dtfinal         => pr_dtfinal
															,pr_tab_age_recarga => vr_tab_age_recarga
															,pr_qttotage        => vr_qttotage
															,pr_cdcritic        => vr_cdcritic
															,pr_dscritic        => vr_dscritic);		

			-- Verifica se retornou erro
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				 RAISE vr_exc_erro;
			END IF;
           
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxml, TRUE); 
      dbms_lob.open(pr_clobxml, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<Raiz>'); 
														 
			FOR vr_ind IN 1..vr_tab_age_recarga.count LOOP											 

        -- Montar clob de retorno
        -- Montar XML com registros de carencia
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<AGENDAMENTO>'
                                                  ||   '<dtrecarga>'     || to_char(vr_tab_age_recarga(vr_ind).dtrecarga, 'DD/MM/RRRR')         ||'</dtrecarga>'
                                                  ||   '<idoperacao>'    || vr_tab_age_recarga(vr_ind).idoperacao                               ||'</idoperacao>'
                                                  ||   '<dttransa>'      || to_char(vr_tab_age_recarga(vr_ind).dttransa, 'DD/MM/RRRR')          ||'</dttransa>'
                                                  ||   '<hrtransa>'      || to_char(vr_tab_age_recarga(vr_ind).dttransa,'sssss')                ||'</hrtransa>'
                                                  ||   '<vlrecarga>'     || vr_tab_age_recarga(vr_ind).vlrecarga                                ||'</vlrecarga>'
                                                  ||   '<dssit_operacao>'|| vr_tab_age_recarga(vr_ind).dssit_operacao                           ||'</dssit_operacao>'
                                                  ||   '<nrddd>'         || vr_tab_age_recarga(vr_ind).nrddd                                    ||'</nrddd>'
                                                  ||   '<nrcelular>'     || gene0002.fn_mask(vr_tab_age_recarga(vr_ind).nrcelular,'99999-9999') ||'</nrcelular>'
                                                  ||   '<nmoperadora>'   || vr_tab_age_recarga(vr_ind).nmoperadora                              ||'</nmoperadora>'
                                                  ||   '<incancel>'      || vr_tab_age_recarga(vr_ind).incancel                                 ||'</incancel>'       
                                                  || '</AGENDAMENTO>');
      END LOOP;
       
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Raiz>' 
                             ,pr_fecha_xml      => TRUE);
											
		  -- Descrição da transação			 
			vr_dstransa := 'Busca agendamentos de recarga de celular';
			
			-- Gerar log
			GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
													,pr_cdoperad => '996'
													,pr_dscritic => ' '
													,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_origem)
													,pr_dstransa => vr_dstransa
													,pr_dttransa => TRUNC(SYSDATE)
													,pr_flgtrans => 1
													,pr_hrtransa => gene0002.fn_busca_time
													,pr_idseqttl => 1
													,pr_nmdatela => CASE WHEN pr_origem = 3 THEN 'INTERNETBANK' ELSE 'TAA' END
													,pr_nrdconta => pr_nrdconta
													,pr_nrdrowid => vr_nrdrowid);														 

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_obtem_agendamentos_recarga;
		
	-- Cancelar agendamentos de recarga de celular
  PROCEDURE pc_cancela_agendamento_recarga(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                          ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                          ,pr_idseqttl   IN crapttl.idseqttl%TYPE
                                          ,pr_idorigem   IN INTEGER
                                          ,pr_idoperacao IN INTEGER 
                                          ,pr_nmprogra   IN VARCHAR2
                                          ,pr_cdcritic  OUT PLS_INTEGER
                                          ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_cancela_agendamento_recarga
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :  Rotina para buscar os agendamentos de recarga de celular

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      vr_nrdrowid ROWID;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      				 
	    -- Cursor para listar os agendamentos de recarga
		  CURSOR cr_agendamentos (pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE
                             ,pr_operacao  IN INTEGER) IS
 			  SELECT ope.dtrecarga
              ,(CASE WHEN ope.insit_operacao = 1 THEN 'Pendente'
                     WHEN ope.insit_operacao = 4 THEN 'Cancelado'
                     ELSE 'Nao efetivado'
               END) situacao
          FROM tbrecarga_operacao ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.nrdconta = pr_nrdconta
           AND ope.idoperacao = pr_operacao;
      rw_agendamentos cr_agendamentos%ROWTYPE;
      
		BEGIN
														 
			-- Buscar telefones favoritos
      OPEN cr_agendamentos (pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_operacao  => pr_idoperacao);
      FETCH cr_agendamentos INTO rw_agendamentos;
      -- Se não encontrar agendamento
      IF cr_agendamentos%NOTFOUND THEN
        CLOSE cr_agendamentos;
        vr_dscritic := 'Agendamento não cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_agendamentos;
      
      -- Se a data do agendamento for o dia de hoje
      IF rw_agendamentos.dtrecarga = SYSDATE THEN
        vr_dscritic := 'Operação não permitida na data do agendamento.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Cancela Operação
      BEGIN 
        UPDATE tbrecarga_operacao
           SET insit_operacao = 4
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idoperacao = pr_idoperacao;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar agendamento.';
          RAISE vr_exc_erro;
      END;
      
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => 'Cancelamento efetuado com sucesso.'
                          ,pr_dsorigem =>  gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => 'Cancelar agendamento de recarga de celular'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmprogra
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                          
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'insit_operacao'
                               ,pr_dsdadant => rw_agendamentos.situacao
                               ,pr_dsdadatu => 'Cancelado');
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => 996
                            ,pr_dscritic => 'Operação não efetuada.'
                            ,pr_dsorigem =>  gene0001.vr_vet_des_origens(pr_idorigem)
                            ,pr_dstransa => 'Cancelar agendamento de recarga de celular'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmprogra
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
                            
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
        
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => 996
                            ,pr_dscritic => 'Operação não efetuada.'
                            ,pr_dsorigem =>  gene0001.vr_vet_des_origens(pr_idorigem)
                            ,pr_dstransa => 'Cancelar agendamento de recarga de celular'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmprogra
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
                            
    END;																			
	END pc_cancela_agendamento_recarga;
	
	-- Exclui favorito do cooperado
  PROCEDURE pc_excluir_favorito(pr_cdcooper  IN crapcop.cdcooper%TYPE
		                           ,pr_nrdconta  IN crapass.nrdconta%TYPE
                               ,pr_nrddd     IN tbrecarga_favorito.nrddd%TYPE
                               ,pr_nrcelular IN tbrecarga_favorito.nrcelular%TYPE
															 ,pr_cdcritic OUT PLS_INTEGER
	  											     ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_excluir_favorito
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir um telefones favorito do cooperado

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      CURSOR cr_favorito (pr_cdcooper  IN tbrecarga_favorito.cdcooper%TYPE
                         ,pr_nrdconta  IN tbrecarga_favorito.nrdconta%TYPE
                         ,pr_nrddd     IN tbrecarga_favorito.nrddd%TYPE
                         ,pr_nrcelular IN tbrecarga_favorito.nrcelular%TYPE) IS
        SELECT 1
          FROM tbrecarga_favorito fav
         WHERE fav.cdcooper = pr_cdcooper
           AND fav.nrdconta = pr_nrdconta
           AND fav.nrddd = pr_nrddd
           AND fav.nrcelular = pr_nrcelular;
      rw_favorito cr_favorito%ROWTYPE;
      
		BEGIN
      
    -- Verifica se o favorito existe
      OPEN cr_favorito(pr_cdcooper  => pr_cdcooper 
                      ,pr_nrdconta  => pr_nrdconta 
                      ,pr_nrddd     => pr_nrddd    
                      ,pr_nrcelular => pr_nrcelular);
			
      FETCH cr_favorito INTO rw_favorito;
      IF cr_favorito%NOTFOUND THEN
        vr_dscritic := 'Favorito náo encontrado.';
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_favorito;
      
      -- Excluir Favorito
      BEGIN
        DELETE
          FROM tbrecarga_favorito fav
         WHERE fav.cdcooper  = pr_cdcooper
           AND fav.nrdconta  = pr_nrdconta
           AND fav.nrddd     = pr_nrddd
           AND fav.nrcelular = pr_nrcelular;
      EXCEPTION
        WHEN OTHERS THEN 
          vr_dscritic := 'Erro ao excluir favorito' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_excluir_favorito;
	
  -- Cadastra favorito do cooperado
  PROCEDURE pc_cadastra_favorito(pr_cdcooper  IN crapcop.cdcooper%TYPE
		                            ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                ,pr_nrddd     IN tbrecarga_favorito.nrddd%TYPE
                                ,pr_nrcelular IN tbrecarga_favorito.nrcelular%TYPE
                                ,pr_nmcontato IN tbrecarga_favorito.nmcontato%TYPE
                                ,pr_cdcritic OUT PLS_INTEGER
                                ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_cadastra_favorito
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir um telefones favorito do cooperado

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      vr_sequencial INTEGER;
      vr_flgfound   BOOLEAN;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      CURSOR cr_favorito (pr_cdcooper  IN tbrecarga_favorito.cdcooper%TYPE
                         ,pr_nrdconta  IN tbrecarga_favorito.nrdconta%TYPE
                         ,pr_nrddd     IN tbrecarga_favorito.nrddd%TYPE
                         ,pr_nrcelular IN tbrecarga_favorito.nrcelular%TYPE) IS
        SELECT 1
          FROM tbrecarga_favorito fav
         WHERE fav.cdcooper = pr_cdcooper
           AND fav.nrdconta = pr_nrdconta
           AND fav.nrddd = pr_nrddd
           AND fav.nrcelular = pr_nrcelular;
      rw_favorito cr_favorito%ROWTYPE;
      
      CURSOR cr_sequenci (pr_cdcooper  IN tbrecarga_favorito.cdcooper%TYPE
                         ,pr_nrdconta  IN tbrecarga_favorito.nrdconta%TYPE) IS
        SELECT (nvl(MAX(fav.cdseq_favorito),0) + 1) sequencial
          FROM tbrecarga_favorito fav
         WHERE fav.cdcooper = pr_cdcooper
           AND fav.nrdconta = pr_nrdconta;
      
      -- Verificar se número do celular é fraudulento
		  CURSOR cr_crapcbf(pr_dsfraude IN crapcbf.dsfraude%TYPE) IS
			  SELECT 1
				  FROM crapcbf cbf
				 WHERE cbf.cdcooper = 3
				   AND cbf.tpfraude = 4
					 AND cbf.dsfraude = pr_dsfraude;
			rw_crapcbf cr_crapcbf%ROWTYPE;
			cr_crapcbf_found BOOLEAN := FALSE;
      
		BEGIN
      
      -- Verifica se o favorito existe
      OPEN cr_favorito(pr_cdcooper  => pr_cdcooper 
                      ,pr_nrdconta  => pr_nrdconta 
                      ,pr_nrddd     => pr_nrddd    
                      ,pr_nrcelular => pr_nrcelular);
			
      FETCH cr_favorito INTO rw_favorito;
      vr_flgfound := cr_favorito%FOUND;
      -- Fecha cursor
      CLOSE cr_favorito;
      
      IF NOT vr_flgfound THEN
        
        -- Verificar se número de celular é fraudulento
			  OPEN cr_crapcbf(pr_dsfraude => to_char(pr_nrddd) || TO_CHAR(pr_nrcelular, '00000g0000','nls_numeric_characters=.-'));
			  FETCH cr_crapcbf INTO rw_crapcbf;
        cr_crapcbf_found := cr_crapcbf%FOUND;
				CLOSE cr_crapcbf;
        
        --Se encontrou o número como fraudulento, então retorna exception
        IF cr_crapcbf_found THEN
          vr_dscritic := 'Número de telefone inválido.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se o favorito existe
        OPEN cr_sequenci(pr_cdcooper  => pr_cdcooper 
                        ,pr_nrdconta  => pr_nrdconta);
  			
        FETCH cr_sequenci INTO vr_sequencial;
        -- Fecha cursor
        CLOSE cr_sequenci;
        
        -- Cadastrar Favorito
        BEGIN
          INSERT INTO tbrecarga_favorito(cdcooper
                                        ,nrdconta
                                        ,nrddd
                                        ,nrcelular
                                        ,nmcontato
                                        ,cdseq_favorito)
                                 VALUES (pr_cdcooper
                                        ,pr_nrdconta
                                        ,pr_nrddd
                                        ,pr_nrcelular
                                        ,upper(pr_nmcontato)
                                        ,vr_sequencial);
        EXCEPTION
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro ao cadastrar favorito' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
      
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_cadastra_favorito;
  
  -- Confirma recarga de celular
  PROCEDURE pc_confirma_recarga_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                  ,pr_idseqttl   IN crapttl.idseqttl%TYPE
                                  ,pr_nrcpfope   IN crapsnh.nrcpfcgc%TYPE
                                  ,pr_nrddd      IN tbrecarga_favorito.nrddd%TYPE
                                  ,pr_nrcelular  IN tbrecarga_favorito.nrcelular%TYPE
                                  ,pr_nmcontato  IN tbrecarga_favorito.nmcontato%TYPE
                                  ,pr_flgfavori  IN INTEGER
                                  ,pr_vlrecarga  IN tbrecarga_valor.vlrecarga%TYPE
                                  ,pr_operadora  IN tbrecarga_operadora.cdoperadora%TYPE
                                  ,pr_produto    IN tbrecarga_produto.cdproduto%TYPE
                                  ,pr_cddopcao   IN INTEGER
                                  ,pr_dtrecarga  IN tbrecarga_operacao.dtrecarga%TYPE
                                  ,pr_qtmesagd   IN INTEGER    
                                  ,pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE
                                  ,pr_inaprpen   IN NUMBER
                                  ,pr_flmobile   IN NUMBER
                                  ,pr_idorigem   IN INTEGER -- Indicador de Origem
                                  ,pr_cdagenci   IN INTEGER -- Agencia de Origem
                                  ,pr_nrdcaixa   IN INTEGER -- Caixa de Origem
                                  ,pr_nmprogra   IN VARCHAR2 -- Programa que chamou
                                  ,pr_cdcoptfn   IN crapcop.cdcooper%TYPE -- Cód. da cooperativa do terminal financeiro (Apenas TAA)
                                  ,pr_cdagetfn   IN crapage.cdagenci%TYPE -- Cód. da agencia do terminal financeiro (Apenas TAA)
                                  ,pr_nrterfin   IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro (Apenas TAA)
                                  ,pr_nrcartao   IN NUMBER                -- Nr. do cartao (Apenas TAA)
                                  ,pr_xml_idlancto OUT VARCHAR2 -- Lista com todos os agendamentos
                                  ,pr_msg_retor OUT VARCHAR2
                                  ,pr_cdcritic  OUT PLS_INTEGER
                                  ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_confirma_regarca_ib
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para manter a recarga de celular pelo InternetBank 
                (efetivar/transação pendente)

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      vr_lsdatagd  VARCHAR2(10000);
      vr_dsprotoc  VARCHAR2(10000);
      vr_dsnsuope  tbrecarga_operacao.dsnsu_operadora%TYPE;
      vr_idastcjt  INTEGER;
      
      vr_nrddd     tbrecarga_favorito.nrddd%TYPE;
      vr_nrcelular tbrecarga_favorito.nrcelular%TYPE;
      vr_vlrecarga tbrecarga_valor.vlrecarga%TYPE;
      vr_operadora tbrecarga_operadora.cdoperadora%TYPE;
      vr_produto   tbrecarga_produto.cdproduto%TYPE;
      vr_dtrecarga tbrecarga_operacao.dtrecarga%TYPE;
      vr_qtmesagd  INTEGER;
      vr_dslancto  VARCHAR2(30000);
      vr_agendamentos   gene0002.typ_split;
      
      vr_nrsequni INTEGER;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      CURSOR cr_tbrecarga_operacao (pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE) IS
        SELECT ope.nrddd
              ,ope.nrcelular
              ,ope.vlrecarga
              ,ope.cdoperadora
              ,ope.cdproduto
              ,ope.dtrecarga
          FROM tbrecarga_operacao ope
         WHERE ope.idoperacao = pr_idoperacao;
      rw_tbrecarga_operacao cr_tbrecarga_operacao%ROWTYPE;
      
      CURSOR cr_operacao_repetida(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                 ,pr_dtrecarga  IN tbrecarga_operacao.dtrecarga%TYPE
                                 ,pr_nrddd      IN tbrecarga_favorito.nrddd%TYPE
                                 ,pr_nrcelular  IN tbrecarga_favorito.nrcelular%TYPE
                                 ,pr_vlrecarga  IN tbrecarga_valor.vlrecarga%TYPE) IS
      SELECT 1
        FROM tbrecarga_operacao req
       WHERE req.cdcooper = pr_cdcooper
         AND req.nrdconta = pr_nrdconta
         AND req.dtrecarga = pr_dtrecarga
         AND req.nrddd = pr_nrddd
         AND req.nrcelular = pr_nrcelular
         AND req.vlrecarga = pr_vlrecarga
         AND ((SYSDATE - dttransa) * 24 * 60) < 5; -- Menos de 5 minutos atrás
      vr_operacao_repetida NUMBER := 0;
      
		BEGIN
      
      vr_idastcjt := 0;
      
      IF pr_inaprpen > 0 THEN
        -- Busca registro de recarga pendente
        OPEN cr_tbrecarga_operacao(pr_idoperacao);
        FETCH cr_tbrecarga_operacao INTO rw_tbrecarga_operacao;
        -- Se encontrar
        IF cr_tbrecarga_operacao%FOUND THEN
          
          -- Fecha cursor;
          CLOSE cr_tbrecarga_operacao;
          -- Popula campos com os campos do registro encontrado
          vr_nrddd     := rw_tbrecarga_operacao.nrddd;
          vr_nrcelular := rw_tbrecarga_operacao.nrcelular;
          vr_vlrecarga := rw_tbrecarga_operacao.vlrecarga;
          vr_operadora := rw_tbrecarga_operacao.cdoperadora;
          vr_produto   := rw_tbrecarga_operacao.cdproduto;
          vr_dtrecarga := rw_tbrecarga_operacao.dtrecarga;
          vr_qtmesagd  := 0;
          
        ELSE -- Se não encontrar
          
          -- Fecha cursor;
          CLOSE cr_tbrecarga_operacao;
          
          vr_dscritic := 'Registro de Recarga de celular Inexistente.';
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Popula campos com os parametros passados
        vr_nrddd     := pr_nrddd;
        vr_nrcelular := pr_nrcelular;
        vr_vlrecarga := pr_vlrecarga;
        vr_operadora := pr_operadora;
        vr_produto   := pr_produto;
        vr_dtrecarga := nvl(pr_dtrecarga,trunc(SYSDATE));
        vr_qtmesagd  := pr_qtmesagd;
        
				-- Apenas para recargas efetuadas no mesmo dia
				IF pr_cddopcao = 1 THEN
        -- Valida requisição duplicada (Mobile)
        OPEN cr_operacao_repetida(pr_cdcooper  => pr_cdcooper
                                 ,pr_nrdconta  => pr_nrdconta
                                 ,pr_dtrecarga => vr_dtrecarga
                                 ,pr_nrddd     => vr_nrddd
                                 ,pr_nrcelular => vr_nrcelular
                                 ,pr_vlrecarga => vr_vlrecarga);
        FETCH cr_operacao_repetida
        INTO vr_operacao_repetida;
        CLOSE cr_operacao_repetida;
        
        IF vr_operacao_repetida > 0 THEN
           vr_cdcritic := 0;
						 vr_dscritic := 'Recarga de mesmo valor já solicitada. Consulte extrato ou tente novamente em 5 min.';
           RAISE vr_exc_erro;    
        END IF;
      END IF;
      END IF;

      -- Validar recarga
      RCEL0001.pc_valida_recarga(pr_cdcooper  => pr_cdcooper
                                ,pr_nrdconta  => pr_nrdconta
                                ,pr_idseqttl  => pr_idseqttl
                                ,pr_nrcpfope  => pr_nrcpfope
                                ,pr_vlrecarga => pr_vlrecarga
                                ,pr_nrdddtel  => pr_nrddd 
                                ,pr_nrtelefo  => pr_nrcelular
                                ,pr_dtrecarga => vr_dtrecarga
                                ,pr_qtmesagd  => vr_qtmesagd
                                ,pr_cddopcao  => pr_cddopcao
                                ,pr_idorigem  => pr_idorigem
                                ,pr_cdagenci  => pr_cdagenci
                                ,pr_nrdcaixa  => pr_nrdcaixa
                                ,pr_nmprogra  => pr_nmprogra
                                ,pr_lsdatagd  => vr_lsdatagd
                                ,pr_cdcritic  => vr_cdcritic
                                ,pr_dscritic  => vr_dscritic);
      -- Se ocorreu erro
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      IF pr_inaprpen <> 3 THEN
        -- Sequencial Unico sempre será ZERO
        vr_nrsequni := 0;
        IF pr_idorigem = 4 THEN
          -- Apenas quando origem for TAA, é que deve ser gerado o sequencial
          -- Parametros foram identificados em TAA_autorizador > operacao 13 > obtem_nsu > bo25.obtem_nsu
          pc_sequence_progress(pr_nmtabela => 'CRAPNSU'
                              ,pr_nmdcampo => 'NRSEQUNI'
                              ,pr_dsdchave => pr_cdcooper
                              ,pr_flgdecre => 'N'
                              ,pr_sequence => vr_nrsequni);
        END IF;
        
        -- Criar recarga ou agendamento de recarga
        RCEL0001.pc_manter_recarga(pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_idseqttl  => pr_idseqttl
                                  ,pr_nrcpfope  => pr_nrcpfope
                                  ,pr_vlrecarga => vr_vlrecarga
                                  ,pr_dtrecarga => vr_dtrecarga
                                  ,pr_lsdatagd  => vr_lsdatagd
                                  ,pr_cddopcao  => pr_cddopcao
                                  ,pr_nrdddtel  => vr_nrddd
                                  ,pr_nrtelefo  => vr_nrcelular
                                  ,pr_cdopetel  => vr_operadora
                                  ,pr_cdprodut  => vr_produto
                                  ,pr_cdcoptfn  => pr_cdcoptfn
                                  ,pr_cdagetfn  => pr_cdagetfn
                                  ,pr_nrterfin  => pr_nrterfin
                                  ,pr_nrcartao  => pr_nrcartao
                                  ,pr_nrsequni  => vr_nrsequni
                                  ,pr_idorigem  => pr_idorigem
                                  ,pr_cdagenci  => pr_cdagenci
                                  ,pr_nrdcaixa  => pr_nrdcaixa
                                  ,pr_nmprogra  => pr_nmprogra
                                  ,pr_inaprpen  => pr_inaprpen
                                  ,pr_flmobile  => pr_flmobile
                                  ,pr_idastcjt  => vr_idastcjt
                                  ,pr_idoperac  => pr_idoperacao
                                  ,pr_dslancto  => vr_dslancto
                                  ,pr_dsprotoc  => vr_dsprotoc
                                  ,pr_dsnsuope  => vr_dsnsuope
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);
        -- Se ocorreu erro                                             
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN            
          RAISE vr_exc_erro;                                            
        END IF;
      END IF;
      -- Commit para garantir que o cadastro de favorito não 
      -- interfira no cadastro de recarga
      COMMIT;
      
      IF pr_inaprpen = 0 AND pr_flgfavori = 1 THEN
        pc_cadastra_favorito(pr_cdcooper  => pr_cdcooper
                            ,pr_nrdconta  => pr_nrdconta
                            ,pr_nrddd     => vr_nrddd
                            ,pr_nrcelular => vr_nrcelular
                            ,pr_nmcontato => pr_nmcontato
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);
        -- Se ocorreu erro                                             
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN            
          RAISE vr_exc_erro;                                            
        END IF;
      END IF;
      
      IF vr_idastcjt = 0  AND pr_nrcpfope = 0 THEN
        IF pr_cddopcao = 1 THEN
          pr_msg_retor := 'Recarga de celular efetuada com sucesso.';
        ELSE
          pr_msg_retor := 'Recarga de celular agendada com sucesso.';
        END IF;
      ELSE
        IF pr_cddopcao = 1 THEN
          pr_msg_retor := 'Recarga de celular registrada com sucesso. Aguardando aprovação dos demais responsáveis.';
        ELSE
          pr_msg_retor := 'Agendamento de recarga de celular registrada com sucesso. Aguardando aprovação dos demais responsáveis.';
        END IF;
      END IF;
      
      --Gera o XML de RETORNO
      pr_msg_retor := '<msgretor>' || pr_msg_retor || '</msgretor>';
      IF (vr_dsprotoc IS NOT NULL) THEN -- Verifica se possui protocolo
        pr_msg_retor := pr_msg_retor || '<dsprotoc>' || vr_dsprotoc || '</dsprotoc>';
      ELSE
        pr_msg_retor := pr_msg_retor || '<dsprotoc></dsprotoc>';
      END IF;
      
      pr_xml_idlancto := '<agendamentos>';
      
      vr_agendamentos := GENE0002.fn_quebra_string(pr_string  => vr_dslancto, 
                                                   pr_delimit => ',');
      IF vr_agendamentos.count > 0 THEN
				-- Devemos gerar uma operação de recarga para cada data de agendamento
        FOR i IN vr_agendamentos.FIRST..vr_agendamentos.LAST LOOP
            pr_xml_idlancto := pr_xml_idlancto || '<idlancto>' || vr_agendamentos(i) || '</idlancto>';
        END LOOP;
      END IF;
      
      pr_xml_idlancto := pr_xml_idlancto || '</agendamentos>';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_confirma_recarga_ib;
  
  -- Buscar dados da recarga no Progress 
  PROCEDURE pc_busca_recarga_prog(pr_idoperacao IN INTEGER
                                 ,pr_resposta  OUT CHAR
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_busca_recarga_prog
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :  Rotina para buscar dados da recarga no Progress 
                 atravez do idoperacao

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      				 
	    CURSOR cr_tbrecarga (pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE) IS
        SELECT ('(' || ope.nrddd || ') ' ||
               gene0002.fn_mask(ope.nrcelular,'99999-9999') || ' - ' || 
               opr.nmoperadora) dstptran
          FROM tbrecarga_operacao ope
              ,tbrecarga_operadora opr
         WHERE ope.idoperacao = pr_idoperacao
           AND ope.cdoperadora = opr.cdoperadora;
      rw_tbrecarga cr_tbrecarga%ROWTYPE;
           
		BEGIN
      
      -- Busca dados
      OPEN cr_tbrecarga (pr_idoperacao);
      FETCH cr_tbrecarga INTO rw_tbrecarga;
      IF cr_tbrecarga%NOTFOUND THEN
        CLOSE cr_tbrecarga;
        vr_dscritic := 'Registro de Recarga de celular Inexistente.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Popula Resposta
      pr_resposta := rw_tbrecarga.dstptran;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_busca_recarga_prog;
  
  -- Gera relatorio de criticas
  PROCEDURE pc_gera_rel_criticas(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                ,pr_tab_critic IN typ_tab_critic
                                ,pr_crapdat    IN BTCH0001.cr_crapdat%ROWTYPE
                                ,pr_nmdatela   IN VARCHAR2
                                ,pr_cdcritic  OUT PLS_INTEGER
                                ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_gera_rel_criticas
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :  Rotina para gerar relatorio de criticas
                 atravez do idoperacao

    Alteracoes: 30/05/2017 - alterado flag pr_flg_impri para 'S' na chamada da 
                             pc_solicita_relato. PRJ321 - Recarga de Celular (Lombardi)
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      vr_nom_arquivo VARCHAR2(100);
      vr_nom_direto  VARCHAR2(100);
      vr_dircopia    VARCHAR2(100);
      vr_dtrefere    DATE;
      vr_index       VARCHAR2(100);
      vr_index_rel   VARCHAR2(100);
      vr_titulo      VARCHAR2(100);
      vr_tab_critic  typ_tab_critic;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variável para armazenar as informações em XML
      vr_des_xml CLOB;
      
      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
      
		BEGIN
      
      vr_nom_arquivo := 'crrl482_r' || to_char( gene0002.fn_busca_time );
      vr_dtrefere:= pr_crapdat.dtmvtolt;

      IF pr_tab_critic.Count > 0 THEN
        
        vr_index := pr_tab_critic.FIRST;
        
        -- Ordenar os registros
        WHILE vr_index IS NOT NULL LOOP
          
          vr_index_rel := rpad(pr_tab_critic(vr_index).idorigem,2,'#')||  --dsorigem
                          pr_tab_critic(vr_index).situacao||
                          lpad(pr_tab_critic(vr_index).cdagenci,10,'0')||  --cdagenci
                          lpad(pr_tab_critic(vr_index).nrdconta,10,'0')||  --nrdconta
                          pr_tab_critic(vr_index).idoperacao;
          
          vr_tab_critic(vr_index_rel).idoperacao := pr_tab_critic(vr_index).idoperacao;
          vr_tab_critic(vr_index_rel).situacao   := pr_tab_critic(vr_index).situacao;
          vr_tab_critic(vr_index_rel).idorigem   := pr_tab_critic(vr_index).idorigem;
          vr_tab_critic(vr_index_rel).cdagenci   := pr_tab_critic(vr_index).cdagenci;
          vr_tab_critic(vr_index_rel).nrdconta   := pr_tab_critic(vr_index).nrdconta;
          vr_tab_critic(vr_index_rel).nmprimtl   := pr_tab_critic(vr_index).nmprimtl;
          vr_tab_critic(vr_index_rel).nrcelular  := pr_tab_critic(vr_index).nrcelular;
          vr_tab_critic(vr_index_rel).operadora  := pr_tab_critic(vr_index).operadora;
          vr_tab_critic(vr_index_rel).vlrecarga  := pr_tab_critic(vr_index).vlrecarga;
          vr_tab_critic(vr_index_rel).cdcritic   := pr_tab_critic(vr_index).cdcritic;
          vr_tab_critic(vr_index_rel).dscritic   := pr_tab_critic(vr_index).dscritic;
          
          vr_index:= pr_tab_critic.NEXT(vr_index);
          
        END LOOP;
        
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informacoes do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl482><contas>');
        
        
        vr_index := vr_tab_critic.FIRST;
        -- Percorre registros
        WHILE vr_index IS NOT NULL LOOP
          
          IF vr_index = vr_tab_critic.FIRST OR
             vr_tab_critic(vr_index).idorigem <> vr_tab_critic(vr_tab_critic.PRIOR(vr_index)).idorigem THEN
            -- Adicionar o no de origem
            pc_escreve_xml('<origem dsorigem="'|| (CASE 
                                                     WHEN vr_tab_critic(vr_index).idorigem = 3 
                                                       THEN 'INTERNET'
                                                     ELSE 'TAA' END) ||'">');
          END IF;
          
          -- Se estivermos processando o primeiro registro do vetor ou mudou o titulo
          IF vr_index = vr_tab_critic.FIRST OR
             vr_tab_critic(vr_index).idorigem <> vr_tab_critic(vr_tab_critic.PRIOR(vr_index)).idorigem OR
             vr_tab_critic(vr_index).situacao <> vr_tab_critic(vr_tab_critic.PRIOR(vr_index)).situacao THEN
            --Determinar o titulo
            IF vr_tab_critic(vr_index).situacao = 1 THEN
              vr_titulo:= 'EFETUADOS';
            ELSE
              vr_titulo:= 'NAO EFETUADOS';
            END IF;
            -- Adicionar o no de titulo
            pc_escreve_xml('<titulo dstitulo="'||vr_titulo||'"
                                    dtrefere="'||To_Char(vr_dtrefere,'DD/MM/YYYY')||'">');
          END IF;

          pc_escreve_xml('<conta>' ||
                           '<cdagenci>'  || vr_tab_critic(vr_index).cdagenci  || '</cdagenci>' ||
                           '<nrdconta>'  || gene0002.fn_mask_conta(vr_tab_critic(vr_index).nrdconta)  || '</nrdconta>' ||
                           '<nmprimtl>'  || vr_tab_critic(vr_index).nmprimtl  || '</nmprimtl>' ||
                           '<nrcelular>' || vr_tab_critic(vr_index).nrcelular || '</nrcelular>' ||
                           '<operadora>' || vr_tab_critic(vr_index).operadora || '</operadora>' ||
                           '<vlrecarga>' || vr_tab_critic(vr_index).vlrecarga || '</vlrecarga>' ||
                           '<dscritic>'  || UPPER(vr_tab_critic(vr_index).dscritic) || '</dscritic>' ||
                         '</conta>');
          
          --Se mudou o titulo ou chegou ao final do vetor
          IF vr_index = vr_tab_critic.LAST OR
             vr_tab_critic(vr_index).idorigem <> vr_tab_critic(vr_tab_critic.NEXT(vr_index)).idorigem OR
             vr_tab_critic(vr_index).situacao <> vr_tab_critic(vr_tab_critic.NEXT(vr_index)).situacao THEN
            -- Finalizar o agrupador do titulo
            pc_escreve_xml('</titulo>');
          END IF;

          --Se mudou a origem ou chegou ao final do vetor
          IF vr_index = vr_tab_critic.LAST OR
             vr_tab_critic(vr_index).idorigem <> vr_tab_critic(vr_tab_critic.NEXT(vr_index)).idorigem THEN
            -- Finalizar o agrupador da origem
            pc_escreve_xml('</origem>');
          END IF;
          --Proximo registro do vetor
          vr_index:= vr_tab_critic.NEXT(vr_index);
        END LOOP;
        
        --Finalizar tag detalhe
        pc_escreve_xml('</contas></crrl482>');
        
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
        
        -- Busca do diretorio base da cooperativa para copiar arquivo para pasta rlnsv
        vr_dircopia := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rlnsv'); --> Utilizaremos o rlnsv
        
        -- Efetuar solicitacao de geracao de relatorio --
        gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => 'CRPS509'           --> Programa chamador
                                    ,pr_dtmvtolt  => pr_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl482/contas/origem/titulo/conta'       --> No base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl482r.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Titulo do relatório
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                    ,pr_qtcoluna  => 234                 --> 234 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '234col'            --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'S'                 --> gerar PDF
                                    ,pr_nrvergrl  => 1                   --> JasperSoft Studio
                                    ,pr_dspathcop => vr_dircopia         --> Copiar arquivo para diretorio
                                    ,pr_flgremarq => 'N'                 --> Remover arquivo apos copia
                                    ,pr_des_erro  => vr_dscritic);       --> Saída com erro
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar excecao
          RAISE vr_exc_erro;
        END IF;
        
        -- Liberando a memoria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      END IF;
            
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RCEL0001: ' || SQLERRM;
    END;																			
	END pc_gera_rel_criticas;
  
  -- Processar agendamentos de recarga de celular
  PROCEDURE pc_proces_agendamentos_recarga(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                          ,pr_nmdatela  IN VARCHAR2
                                          ,pr_cdcritic OUT PLS_INTEGER
                                          ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    Programa: pc_proces_agendamentos_recarga
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Março/2017                 Ultima atualizacao: 02/08/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :  Rotina para processar agendamentos de recarga de celular

    Alteracoes: 30/05/2017 - Retirado acentuação das criticas na efetuação da recarga.
                             PRJ321 - Recarga de Celular (Lombardi)
                             
                02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
                             crapass, crapttl, crapjur 
             		  				   (Adriano - P339).
                16/04/2018 - Incluido a chamada do programa gen_debitador_unico.pc_qt_hora_prg_debitador
                             para  atualizar a quantidade de execução que esta agendada no Debitador
                             Projeto Debitador Unico - Josiane Stiehler (AMcom)
  
    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      vr_flultexe INTEGER;
      vr_qtdexec  INTEGER;
      vr_nsuopera tbrecarga_operacao.dsnsu_operadora%TYPE;
      vr_dsprotoc VARCHAR2(500);
      vr_index    VARCHAR2(100);
      vr_vldinami VARCHAR2(1000);
      vr_dsdmensg VARCHAR2(1000);
      vr_cdagenci INTEGER;
      vr_nrdcaixa INTEGER;
      vr_nmprogra VARCHAR2(100);
      
      -- Variaveis de critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      vr_tab_critic typ_tab_critic;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      CURSOR cr_tbrecarga (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT ope.idoperacao
              ,ope.nrdconta
              ,ope.nrddd
              ,ope.nrcelular
              ,ope.cdproduto
              ,ope.cdoperadora
              ,to_char(ope.dtrecarga,'DD/MM/RRRR') dtrecarga
              ,ope.vlrecarga
              ,ope.cdcanal
              ,opr.nmoperadora
          FROM tbrecarga_operacao ope
              ,tbrecarga_operadora opr
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.insit_operacao = 1
           AND ope.dtrecarga = pr_dtmvtolt
           AND opr.cdoperadora = ope.cdoperadora;
      
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.vllimcre
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
              ,crapass.cdcooper
              ,crapass.cdagenci
              ,crapass.nrctacns
              ,crapass.dtdemiss
              ,crapass.idastcjt
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Variáveis de controle de calendário
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
		BEGIN
      
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      END IF;
      
      -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
          
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        RAISE vr_exc_saida;
          
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Verifica se o programa que chamou é o Debitador
      IF pr_nmdatela = 'JOBAGERCEL' AND
         pr_cdcooper <> 3 THEN
         -- Atualiza a quantidade de execução que estão agendadas no Debitador
         -- Projeto Debitador Único
         gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper    => pr_cdcooper   --Cooperativa
                                                     ,pr_cdprocesso => 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)
                                                     ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica
         IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
         END IF;

         -- registrar a quantidade de execução
         -- Projeto debitador unico
         SICR0001.pc_controle_exec_deb (pr_cdcooper   => pr_cdcooper         --> Código da coopertiva
                                       ,pr_cdtipope  => 'I'                 --> Tipo de operacao I-incrementar e C-Consultar
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento
                                       ,pr_cdprogra  => pr_nmdatela         --> Codigo do programa
                                       ,pr_flultexe  => vr_flultexe         --> Retorna se é a ultima execução do procedimento
                                       ,pr_qtdexec   => vr_qtdexec          --> Retorna a quantidade
                                       ,pr_cdcritic  => vr_cdcritic         --> Codigo da critica de erro
                                       ,pr_dscritic  => vr_dscritic);       --> descrição do erro se ocorrer

           IF nvl(vr_cdcritic,0) > 0 OR
              TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
           --Commit para garantir o
           --controle de execucao do programa
           COMMIT;
      END IF;
      
      --> Verificar a execução da DEBNET/DEBSIC 
      SICR0001.pc_controle_exec_deb(pr_cdcooper => pr_cdcooper         --> Código da coopertiva
                                   ,pr_cdtipope => 'C'                 --> Tipo de operacao I-incrementar e C-Consultar
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento 
                                   ,pr_cdprogra => pr_nmdatela         --> Codigo do programa 
                                   ,pr_flultexe => vr_flultexe         --> Retorna se é a ultima execução do procedimento
                                   ,pr_qtdexec  => vr_qtdexec          --> Retorna a quantidade
                                   ,pr_cdcritic => vr_cdcritic         --> Codigo da critica de erro
                                   ,pr_dscritic => vr_dscritic);       --> Descrição do erro se ocorrer
      IF nvl(vr_cdcritic,0) > 0 OR
        TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_tab_critic.DELETE;
      
      vr_index := '';
      
      FOR rw_tbrecarga IN cr_tbrecarga (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        
        --Verificar conta
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_tbrecarga.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 9;
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
        
        IF rw_tbrecarga.cdcanal = 3 THEN
          vr_cdagenci := 90;
          vr_nrdcaixa := 900;
          vr_nmprogra := 'INTERNETBANK';
        ELSIF rw_tbrecarga.cdcanal = 4 THEN
          vr_cdagenci := 91;
          vr_nrdcaixa := 900;
          vr_nmprogra := 'TAA';
        ELSE
          vr_cdagenci := 1;
          vr_nrdcaixa := 0;
          vr_nmprogra := '';
        END IF;
        
        -- Efetua Recarga agendada
        rcel0001.pc_efetua_recarga(pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => rw_tbrecarga.nrdconta
                                  ,pr_idseqttl  => 1 --teste
                                  ,pr_vlrecarga => rw_tbrecarga.vlrecarga
                                  ,pr_nrdddtel  => rw_tbrecarga.nrddd
                                  ,pr_nrtelefo  => rw_tbrecarga.nrcelular
                                  ,pr_cdproduto => rw_tbrecarga.cdproduto
                                  ,pr_cdopetel  => rw_tbrecarga.cdoperadora
                                  ,pr_idoperac  => rw_tbrecarga.idoperacao
                                  ,pr_nrcpfope  => 0
                                  ,pr_cdcoptfn  => 0
                                  ,pr_nrterfin  => 0
                                  ,pr_nrcartao  => 0
                                  ,pr_nrsequni  => 0
                                  ,pr_idorigem  => rw_tbrecarga.cdcanal
                                  ,pr_cdagenci  => vr_cdagenci
                                  ,pr_nrdcaixa  => vr_nrdcaixa
                                  ,pr_nmprogra  => vr_nmprogra
                                  ,pr_flmobile  => 0
                                  ,pr_nsuopera  => vr_nsuopera
                                  ,pr_dsprotoc  => vr_dsprotoc
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);
        
        vr_index := rpad(rw_tbrecarga.cdcanal,2,'#')||  --dsorigem
                    lpad(rw_crapass.cdagenci,10,'0')||  --cdagenci
                    lpad(rw_crapass.nrdconta,10,'0')||  --nrdconta
                    rw_tbrecarga.idoperacao;
        
        -- popula tabela de criticas
        vr_tab_critic(vr_index).idoperacao := rw_tbrecarga.idoperacao;
        vr_tab_critic(vr_index).cdagenci   := rw_crapass.cdagenci;
        vr_tab_critic(vr_index).nrdconta   := rw_crapass.nrdconta;
        vr_tab_critic(vr_index).nmprimtl   := rw_crapass.nmprimtl;
        vr_tab_critic(vr_index).nrcelular  := '('||rw_tbrecarga.nrddd||') '|| gene0002.fn_mask(rw_tbrecarga.nrcelular,'99999-9999');
        vr_tab_critic(vr_index).operadora  := rw_tbrecarga.nmoperadora;
        vr_tab_critic(vr_index).vlrecarga  := to_char(rw_tbrecarga.vlrecarga,'fm999g999d00');
        vr_tab_critic(vr_index).idorigem   := rw_tbrecarga.cdcanal;
        
        --Se houve criticas
        IF nvl(vr_cdcritic,0) > 0 OR
           vr_dscritic IS NOT NULL THEN
          
          -- Verifica se tem codigo da critica e se a mesma não provém da rede tendencia
          IF vr_cdcritic <> 0 AND vr_cdcritic <> 888 THEN
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          
          vr_tab_critic(vr_index).situacao   := 0;
          vr_tab_critic(vr_index).cdcritic   := nvl(vr_cdcritic,0);
          vr_tab_critic(vr_index).dscritic   := gene0007.fn_caract_acento(nvl(vr_dscritic,''));
        
          -- Variáveis para envio de notificações no Mobile/Novo IB
          vr_variaveis_notif('#dataagendamento') := to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY');
          vr_variaveis_notif('#valor') := to_char(rw_tbrecarga.vlrecarga,'fm999g999d00');
          vr_variaveis_notif('#operadora') := rw_tbrecarga.nmoperadora;
          vr_variaveis_notif('#ddd') := '('||lpad(rw_tbrecarga.nrddd,2,'0')||') ';
          vr_variaveis_notif('#numerocelular') := gene0002.fn_mask(rw_tbrecarga.nrcelular,'99999-9999');
          vr_variaveis_notif('#motivo') := '';
          vr_variaveis_notif('#datadebito') := to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY');
          -- Se for critica de saldo insuficiente
          IF vr_dscritic = 'Não há saldo suficiente para a operação.' THEN

            -- Verifica se é a ultima execução do JOB
            IF vr_flultexe = 1 THEN
              BEGIN
                -- Atualiza registro de recarga
                UPDATE tbrecarga_operacao
                   SET insit_operacao = 5 -- Não efetivada.
                 WHERE idoperacao = rw_tbrecarga.idoperacao;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar registro de recarga. ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
            ELSE
              vr_vldinami := '#Operadora#='||rw_tbrecarga.nmoperadora||';'||
                             '#DDD#='      ||rw_tbrecarga.nrddd||';'||
                             '#Celular#='  ||gene0002.fn_mask(rw_tbrecarga.nrcelular,'99999-9999')||';'||
                             '#Data#='     ||rw_tbrecarga.dtrecarga||';'||
                             '#Valor#='    ||to_char(rw_tbrecarga.vlrecarga,'fm999g999d00');
              vr_variaveis_notif('#motivo') := 'insuficiência de saldo';
              --> buscar mensagem 
              vr_dsdmensg := gene0003.fn_buscar_mensagem(pr_cdcooper          => 3
                                                        ,pr_cdproduto         => 32
                                                        ,pr_cdtipo_mensagem   => 3
                                                        ,pr_sms               => 0             -- Indicador se mensagem é SMS (pois deve cortar em 160 caracteres)
                                                        ,pr_valores_dinamicos => vr_vldinami); -- Máscara #Cooperativa#=1;#Convenio#=123
            END IF;
          ELSE
            BEGIN
              -- Atualiza registro de recarga
              UPDATE tbrecarga_operacao
                 SET insit_operacao = 5 -- Não efetivada.
               WHERE idoperacao = rw_tbrecarga.idoperacao;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de recarga. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
						-- Crítica 888 é erro retornado da rede tendencia
						IF vr_cdcritic = 888 THEN
							-- Se erro retornado é 'CODIGO DE TELEFONE INVALIDO'
							IF UPPER(trim(vr_dscritic)) = 'CODIGO DE TELEFONE INVALIDO' THEN
								-- Erros validados pelo sistema da CECRED
								vr_vldinami := '#Operadora#='||rw_tbrecarga.nmoperadora||';'||
															 '#DDD#='      ||rw_tbrecarga.nrddd||';'||
															 '#Celular#='  ||gene0002.fn_mask(rw_tbrecarga.nrcelular,'99999-9999')||';'||
															 '#Data#='     ||rw_tbrecarga.dtrecarga||';'||
															 '#Valor#='    ||to_char(rw_tbrecarga.vlrecarga,'fm999g999d00')||';'||
															 '#Motivo#=Número de telefone inválido.';

                vr_variaveis_notif('#motivo') := 'número de telefone inválido';
							ELSE -- Senão tratar erro genérico
								-- Erros validados pelo sistema da CECRED
								vr_vldinami := '#Operadora#='||rw_tbrecarga.nmoperadora||';'||
															 '#DDD#='      ||rw_tbrecarga.nrddd||';'||
															 '#Celular#='  ||gene0002.fn_mask(rw_tbrecarga.nrcelular,'99999-9999')||';'||
															 '#Data#='     ||rw_tbrecarga.dtrecarga||';'||
															 '#Valor#='    ||to_char(rw_tbrecarga.vlrecarga,'fm999g999d00')||';'||
															 '#Motivo#=Não foi possível efetuar a recarga.';
               
                vr_variaveis_notif('#motivo') := 'Não foi possível efetuar a recarga.';
							END IF;
						ELSE
							-- Erros validados pelo sistema da CECRED
            vr_vldinami := '#Operadora#='||rw_tbrecarga.nmoperadora||';'||
                           '#DDD#='      ||rw_tbrecarga.nrddd||';'||
                           '#Celular#='  ||gene0002.fn_mask(rw_tbrecarga.nrcelular,'99999-9999')||';'||
                           '#Data#='     ||rw_tbrecarga.dtrecarga||';'||
                           '#Valor#='    ||to_char(rw_tbrecarga.vlrecarga,'fm999g999d00')||';'||
                           '#Motivo#='   ||vr_dscritic;
               
                vr_variaveis_notif('#motivo') := vr_dscritic;
            END IF;          
              
            --> buscar mensagem 
            vr_dsdmensg := gene0003.fn_buscar_mensagem(pr_cdcooper          => 3
                                                      ,pr_cdproduto         => 32
                                                      ,pr_cdtipo_mensagem   => 17
                                                      ,pr_sms               => 0             -- Indicador se mensagem é SMS (pois deve cortar em 160 caracteres)
                                                      ,pr_valores_dinamicos => vr_vldinami); -- Máscara #Cooperativa#=1;#Convenio#=123    
             
          END IF;
          
          IF vr_dscritic <> 'Não há saldo suficiente para a operação.' OR
             vr_flultexe <> 1 THEN
            -- Busca todos os usuarios ativos com senha no IB

                   -- Manda mensagem na conta do cooperado
                   GENE0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_tbrecarga.nrdconta
                                      --,pr_idseqttl   => GERA PARA TODOS OS USUÁRIOS
                                             ,pr_cdprogra => pr_nmdatela
                                             ,pr_inpriori => 0
                                             ,pr_dsdmensg => vr_dsdmensg
                                             ,pr_dsdassun => 'Transação não efetivada'
                                             ,pr_dsdremet => rw_crapcop.nmrescop
                                             ,pr_dsdplchv => 'Sem Saldo'
                                             ,pr_cdoperad => 0
                                             ,pr_cdcadmsg => 0
                                             ,pr_dscritic => vr_dscritic);
                        
            -- Cria uma notificação
            NOTI0001.pc_cria_notificacao(pr_cdorigem_mensagem => ORIGEM_AGEND_NAO_EFETIVADO
                                        ,pr_cdmotivo_mensagem => MOTIVO_RECARGA_CELULAR
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_tbrecarga.nrdconta
                                        ,pr_variaveis => vr_variaveis_notif);
           END IF;   
          
           -- Limpa variaveis de critica
           vr_cdcritic := 0;
           vr_dscritic := '';
         ELSE 
           vr_tab_critic(vr_index).situacao   := 1; -- Efetuado 
         END IF;
       END LOOP;
      
       pc_gera_rel_criticas(pr_cdcooper   => pr_cdcooper
                           ,pr_tab_critic => vr_tab_critic
                           ,pr_crapdat    => rw_crapdat
                           ,pr_nmdatela   => pr_nmdatela
                           ,pr_cdcritic   => vr_cdcritic
                           ,pr_dscritic   => vr_dscritic);
      
       IF vr_cdcritic <> 0 OR
          vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;
      
       --Zerar tabela de memoria auxiliar
       vr_tab_critic.DELETE;
       
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
       -- Se foi retornado apenas código
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       
       -- Devolvemos código e critica encontradas
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
       
       -- Efetuar rollback
       ROLLBACK;
       
       --Zerar tabela de memoria auxiliar
       vr_tab_critic.DELETE;
       
     WHEN OTHERS THEN
       -- Efetuar retorno do erro não tratado
       pr_cdcritic := 0;
       pr_dscritic := 'Erro na procedure pc_proces_agendamentos_recarga. '||sqlerrm;
       
       -- Efetuar rollback
       ROLLBACK;
       
       --Zerar tabela de memoria auxiliar
       vr_tab_critic.DELETE;
       
    END;																			
	END pc_proces_agendamentos_recarga;
  
  -- Efetuar o repasse para a rede Tendência
  PROCEDURE pc_job_efetua_repasse IS
  BEGIN
    /* .............................................................................
    Programa: pc_job_efetua_repasse
    Sistema : Ayllos Web
    Autor   : Lucas Lombardi
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Toda quinta-feira (somente dia útil), às 09:00, com início em 01/06/2017

    Objetivo  :  Efetuar o repasse do valor líquido das recargas de celular de
                 todas as cooperativas para a rede Tendência, correspondente ao
                 período de apuração, e gerar relatório com a apuração dos valores.

    Alteracoes: 05/06/2017 - Alteração para verificar se a data da próxima execução é 
                             maior que a data atual e neste caso calciular o próximo
                             dia útil, com base na data atual. (Renato Darosci - 05/06/2017)

				09/06/2017 - Retirado acentuacao do relatorio. (Lombardi)

                03/08/2017 - Efetuado ajuste para usar o valor do repasse salvo na 
                             tabela tbrecarga_operacao sem precisar calcular o valor
                             da receita.(Lombardi). 		 

    ..............................................................................*/
    DECLARE
      
      -- Variaveis auxiliares
      vr_vrreceita   NUMBER; --> Valor da receita
      vr_vlrepass    NUMBER; --> Valor do repasse
      vr_nrdocmto    VARCHAR2(100);
      vr_nrctrlif    VARCHAR2(100);
      vr_nrispbif    VARCHAR2(100);
      vr_cdageban    VARCHAR2(100);
      vr_nrdocnpj    VARCHAR2(100);
      vr_dsdonome    VARCHAR2(100);
      vr_nrdconta    VARCHAR2(100);
      rw_flgtitul    craptvl.flgtitul%TYPE;
      rw_vldocrcb    craptvl.vldocrcb%TYPE;
      rw_idopetrf    craptvl.idopetrf%TYPE;
      rw_cdbccrcb    craptvl.cdbccrcb%TYPE;
      rw_cdagercb    craptvl.cdagercb%TYPE;
      rw_nrcctrcb    craptvl.nrcctrcb%TYPE;
      rw_cdfinrcb    craptvl.cdfinrcb%TYPE;
      rw_tpdctadb    craptvl.tpdctadb%TYPE;
      rw_tpdctacr    craptvl.tpdctacr%TYPE;
      rw_cpfcgemi    craptvl.cpfcgemi%TYPE;
      rw_nmpesrcb    craptvl.nmpesrcb%TYPE;
      rw_cpfcgrcb    craptvl.cpfcgrcb%TYPE;
      rw_dshistor    craptvl.dshistor%TYPE; 
      vr_tab_repasse typ_tab_repasse;
      vr_index       VARCHAR2(100);
      vr_nom_arquivo VARCHAR2(200);
      vr_nom_direto  VARCHAR2(200);
      vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;
      vr_cdprogra    VARCHAR2(100) := 'JBRCEL_REPASSE';
      vr_jobname     VARCHAR2(100) := 'JBRCEL_REPASSE_$ ';
      vr_email_dest  VARCHAR2(1000); 
      vr_conteudo    VARCHAR2(4000);
      vr_cdbccxlt    INTEGER;
      vr_inperiod    DATE;
      vr_fiperiod    DATE;
      vr_dtmvtolt    DATE;
      vr_dtmvtopr    DATE;
      
      -- Variaveis de critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis Projeto 475
      vr_nrseq_mensagem10    tbspb_msg_enviada_fase.nrseq_mensagem%type;
      vr_nrseq_mensagem20    tbspb_msg_enviada_fase.nrseq_mensagem%type;
      vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type := null;
      vr_des_erro            VARCHAR2(10000);

      -- Busca dos dados da cooperativa
      CURSOR cr_lista_cop IS
        SELECT cop.cdcooper
              ,cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper <> 3
         ORDER BY cop.cdcooper;
      
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
              ,cop.nrctactl
              ,cop.cdcooper
              ,cop.cdagectl
              ,cop.cdbcoctl
          FROM crapcop cop
         WHERE cop.cdcooper = 3
         ORDER BY cop.cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Totalizar o valor das recargas de celular por operadora
      CURSOR cr_tbrecarga(pr_cdcooper IN crapcyb.cdcooper%TYPE
                         ,pr_inperiod IN crapdat.dtmvtolt%TYPE
                         ,pr_fiperiod IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(ope.vlrecarga) total_vlrecarga
              ,SUM(ope.vlrepasse) total_vlrepasse
              ,ope.cdoperadora
              ,COUNT(1) qtrecarga
          FROM tbrecarga_operacao ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.dtrecarga >= pr_inperiod
           AND ope.dtrecarga <= pr_fiperiod
           AND ope.insit_operacao = 2
           GROUP BY ope.cdoperadora;
      
      -- Busca operadora
      CURSOR cr_operadora (pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE) IS
        SELECT opr.nmoperadora
          FROM tbrecarga_operadora opr
         WHERE opr.cdoperadora = pr_cdoperadora;
      rw_operadora cr_operadora%ROWTYPE;
      
      CURSOR cr_craptvl (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                        ,pr_nrdocmto IN craptvl.nrdocmto%TYPE) IS
        SELECT tvl.idopetrf
              ,tvl.cpfcgrcb
          FROM craptvl tvl
         WHERE tvl.cdcooper = pr_cdcooper
           AND tvl.dtmvtolt = pr_dtmvtolt
           AND tvl.cdagenci = 1
           AND tvl.cdbccxlt = 85
           AND tvl.nrdolote = 600037
           AND tvl.tpdoctrf = 3 /* TED SPB */
           AND tvl.nrdocmto = pr_nrdocmto;
      rw_craptvl cr_craptvl%ROWTYPE;
      
      CURSOR cr_crapban (pr_nrispbif IN crapban.nrispbif%TYPE) IS
        SELECT nvl(ban.cdbccxlt,0)
          FROM crapban ban
         WHERE ban.nrispbif = pr_nrispbif;
      
      -- Variáveis de controle de calendário
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Variável para armazenar as informações em XML
      vr_des_xml CLOB;
      
      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
      
    BEGIN -- inicio pc_job_efetua_repasse
      
      -- Gera log no início da execução
      pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                     ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_cdcooper   => 3             --> Codigo da Cooperativa
                     ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      -- Parametros para Ocorrencia
                     ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)
  		
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      --> Se a coop ainda estiver no processo batch, usar proxima data util
      IF rw_crapdat.inproces > 1 THEN
        vr_dtmvtolt := rw_crapdat.dtmvtopr;
      ELSE
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
      END IF;
      
      -- Verifica se a data da próxima execução é maior que a data atual. Isso acontece nas bases
      -- de desenvolvimento e homologação onde se trabalha com datas retroativas. Este ajuste evita
      -- problema de geração demasiada de Jobs.  ( Renato Darosci - 05/06/2017 )
      IF rw_crapdat.dtmvtopr <= TRUNC(SYSDATE) THEN
        -- Calcula o próximo dia útil, com base na data atual
        vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper => 3
																									,pr_dtmvtolt => (TRUNC(SYSDATE) + 1)
																									,pr_tipo     => 'P'
																									,pr_feriado  => TRUE);
        
      ELSE
        -- Usa a próxima data de execução do sistema
        vr_dtmvtopr := rw_crapdat.dtmvtopr;
      END IF;
      
      --> Verificar se a data do sistema eh o dia de hoje
      IF TRUNC(SYSDATE) <> vr_dtmvtolt THEN
        --> O JOB esta confirgurado para toda quinta-feira
        --> Nao pode executar em feriado, por isso que validamos se o dia de
        --> hoje eh o dia do sistema 
        
        /***** Reagendamento *****/
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => 3                                           --> Código da cooperativa
                              ,pr_cdprogra => vr_cdprogra                                 --> Código do programa
                              ,pr_dsplsql  => 'begin RCEL0001.pc_job_efetua_repasse; end;'--> Bloco PLSQL a executar
                              ,pr_dthrexe  => TO_TIMESTAMP_TZ(to_char(vr_dtmvtopr, 'DD/MM/RRRR') || 
                                              ' 09:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora
                              ,pr_interva  => NULL                                        --> apenas uma vez
                              ,pr_jobname  => vr_jobname                                  --> Nome randomico criado
                              ,pr_des_erro => vr_dscritic);
        /***** Reagendamento *****/
        
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      ELSE
      
        vr_tab_repasse.DELETE;
        vr_vlrepass := 0;
        vr_index := '';
        
        FOR rw_lista_cop IN cr_lista_cop LOOP
          
          -- busca periodo da ultima semana
          -- data atual - (dia da semana atual + (5 ou 12))     --> Segunda Feira
          -- data atual - (dia da semana atual + (5 ou 12)) + 4 --> Sexta Feira
          IF to_char((SYSDATE), 'd') > 4 THEN -- Se for Quinta ou Sexta
            vr_inperiod := TRUNC((SYSDATE) - (to_char((SYSDATE), 'd') + 5));
            vr_fiperiod := TRUNC((SYSDATE) - (to_char((SYSDATE), 'd') + 5)) + 6;
          ELSE -- Se for na Segunda da outra semana
            vr_inperiod := TRUNC((SYSDATE) - (to_char((SYSDATE), 'd') + 12));
            vr_fiperiod := TRUNC((SYSDATE) - (to_char((SYSDATE), 'd') + 12)) + 6;
          END IF;
          
          FOR rw_tbrecarga IN cr_tbrecarga (pr_cdcooper => rw_lista_cop.cdcooper
                                           ,pr_inperiod => vr_inperiod
                                           ,pr_fiperiod => vr_fiperiod) LOOP
            
            OPEN cr_operadora (rw_tbrecarga.cdoperadora);
            FETCH cr_operadora INTO rw_operadora;
            -- Busca operadora
            IF cr_operadora%NOTFOUND THEN
              CLOSE cr_operadora;
              vr_dscritic := 'Operadora não encontrada.';
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_operadora;
            END IF;
            
            vr_vrreceita := rw_tbrecarga.total_vlrecarga - rw_tbrecarga.total_vlrepasse;
            
            -- Soma no valor do repasse
            vr_vlrepass := vr_vlrepass + rw_tbrecarga.total_vlrepasse;
            
            vr_index := rpad(rw_lista_cop.cdcooper,2,'#')||  --dsorigem
                        rw_operadora.nmoperadora;
            
            vr_tab_repasse(vr_index).cdcooper  := rw_lista_cop.cdcooper;
            vr_tab_repasse(vr_index).nmrescop  := rw_lista_cop.nmrescop;
            vr_tab_repasse(vr_index).operadora := rw_operadora.nmoperadora;
            vr_tab_repasse(vr_index).qtrecarga := rw_tbrecarga.qtrecarga;
            vr_tab_repasse(vr_index).vlregarga := rw_tbrecarga.total_vlrecarga;
            vr_tab_repasse(vr_index).vlreceita := vr_vrreceita;
            vr_tab_repasse(vr_index).vlapagar  := (rw_tbrecarga.total_vlrecarga - vr_vrreceita);
            
          END LOOP;
        END LOOP;
        
        -- Se tiver valor do repasse
        IF vr_vlrepass > 0 THEN
          
          OPEN cr_crapcop;
          FETCH cr_crapcop INTO rw_crapcop;
          IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_cdcritic := 651;
            RAISE vr_exc_saida;
          END IF;
          
          -- Busca a proxima sequencia do campo CRAPMAT.NRSEQTED
          vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPMAT'
                                    ,pr_nmdcampo => 'NRSEQTED'
                                    ,pr_dsdchave => 3
                                    ,pr_flgdecre => 'N');
          
          -- Número ISPB
          vr_nrispbif := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 3
                                                  ,pr_cdacesso => 'RECCEL_ISPB_REPASSE'); 
          -- Agência
          vr_cdageban := nvl(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => 3
                                                      ,pr_cdacesso => 'RECCEL_AGENCIA_REPASSE'),0);
          -- Número do CNPJ
          vr_nrdocnpj := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 3
                                                  ,pr_cdacesso => 'RECCEL_CNPJ_REPASSE');
          -- Nome
          vr_dsdonome := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 3
                                                  ,pr_cdacesso => 'RECCEL_NOME_REPASSE');
          -- Número da conta
          vr_nrdconta := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 3
                                                  ,pr_cdacesso => 'RECCEL_CONTA_REPASSE');
    			
          -- retornar numero do documento
          vr_nrctrlif := '1'||to_char(rw_crapdat.dtmvtocd,'RRMMDD')
                            ||to_char(rw_crapcop.cdagectl,'fm0000')
                            ||to_char(vr_nrdocmto,'fm00000000')
                            || 'A';
          
          -- Verifica se lançamento ja existe
          OPEN cr_crapban (pr_nrispbif => vr_nrispbif);
          FETCH cr_crapban INTO vr_cdbccxlt;
          
          -- Verifica se lançamento ja existe
          OPEN cr_craptvl (pr_cdcooper => rw_crapcop.cdcooper 
                          ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                          ,pr_nrdocmto => vr_nrdocmto);
          FETCH cr_craptvl into rw_craptvl;
          IF cr_craptvl%FOUND THEN
            vr_dscritic := 'Lançamento CRAPTVL já existe. IDOPETRF =' || rw_craptvl.idopetrf;
            RAISE vr_exc_saida;
          END IF;
              
          BEGIN
            INSERT INTO craptvl (cdcooper
                                ,tpdoctrf
                                ,idopetrf
                                ,nrdconta
                                ,cpfcgemi
                                ,nmpesemi
                                ,nrdctitg
                                ,cdbccrcb
                                ,cdagercb
                                ,cpfcgrcb
                                ,nmpesrcb
                                ,nrcctrcb
                                ,cdbcoenv
                                ,vldocrcb
                                ,dtmvtolt
                                ,hrtransa
                                ,nrdolote
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdocmto
                                ,nrseqdig
                                ,cdfinrcb
                                ,tpdctacr
                                ,tpdctadb
                                ,dshistor
                                ,cdoperad
                                ,cdopeaut
                                ,flgespec
                                ,flgtitul
                                ,flgenvio
                                ,flgpesdb
                                ,flgpescr)
                         VALUES (rw_crapcop.cdcooper
                                ,3
                                ,vr_nrctrlif
                                ,0 -- Não ocorrerá débito em conta corrente
                                ,rw_crapcop.nrdocnpj/*CECRED*/ 
                                ,rw_crapcop.nmrescop/*CECRED*/ 
                                ,0
                                ,vr_cdbccxlt
                                ,vr_cdageban
                                ,to_number(REGEXP_REPLACE(vr_nrdocnpj, '[^[:digit:]]'))
                                ,vr_dsdonome
                                ,vr_nrdconta
                                ,rw_crapcop.cdbcoctl --CECRED
                                ,vr_vlrepass
                                ,rw_crapdat.dtmvtocd
                                ,to_char(SYSDATE,'SSSSS')
                                ,600037
                                ,1
                                ,85
                                ,vr_nrdocmto
                                ,vr_nrdocmto
                                ,5
                                ,1 -- CC - Conta Corrente
                                ,0 -- Não ocorrerá débito em conta corrente
                                ,'pc_job_efetua_repasse'
                                ,''
                                ,''
                                ,0 -- Movimentacao Especie
                                ,0 -- Conta de mesma titularidade
                                ,1
                                ,0 --Não ocorrerá débito em conta corrente
                                ,0)
                      RETURNING flgtitul
                               ,vldocrcb
                               ,idopetrf
                               ,cdbccrcb
                               ,cdagercb
                               ,nrcctrcb
                               ,cdfinrcb
                               ,tpdctadb
                               ,tpdctacr
                               ,cpfcgemi
                               ,nmpesrcb
                               ,cpfcgrcb
                           INTO rw_flgtitul
                               ,rw_vldocrcb
                               ,rw_idopetrf
                               ,rw_cdbccrcb
                               ,rw_cdagercb
                               ,rw_nrcctrcb
                               ,rw_cdfinrcb
                               ,rw_tpdctadb
                               ,rw_tpdctacr
                               ,rw_cpfcgemi
                               ,rw_nmpesrcb
                               ,rw_cpfcgrcb;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar registro na tabela craptvl: ' || SQLERRM;
          END;
             
          -- Marcelo Telles Coelho - Projeto 475
          -- Fase 10 - controle mensagem SPB
          sspb0003.pc_grava_trace_spb(pr_cdfase                 => 10
                                     ,pr_idorigem               => 'E'
                                     ,pr_nmmensagem             => 'MSG_TEMPORARIA'
                                     ,pr_nrcontrole             => rw_idopetrf
                                     ,pr_nrcontrole_str_pag     => NULL
                                     ,pr_nrcontrole_dev_or      => NULL
                                     ,pr_dhmensagem             => sysdate
                                     ,pr_insituacao             => 'OK'
                                     ,pr_dsxml_mensagem         => null
                                     ,pr_dsxml_completo         => null
                                     ,pr_nrseq_mensagem_xml     => null
                                     ,pr_nrdconta               => 05463212
                                     ,pr_cdcooper               => rw_crapcop.cdcooper
                                     ,pr_cdproduto              => 30 -- TED
                                     ,pr_nrseq_mensagem         => vr_nrseq_mensagem10
                                     ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                     ,pr_dscritic               => vr_dscritic
                                     ,pr_des_erro               => vr_des_erro);
          -- Se ocorreu erro
          IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levantar Excecao
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;
          -- Fase 20 - controle mensagem SPB
          sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                     ,pr_nmmensagem             => 'Não utiliza OFSAA'
                                     ,pr_nrcontrole             => rw_idopetrf
                                     ,pr_nrcontrole_str_pag     => NULL
                                     ,pr_nrcontrole_dev_or      => NULL
                                     ,pr_dhmensagem             => sysdate
                                     ,pr_insituacao             => 'OK'
                                     ,pr_dsxml_mensagem         => null
                                     ,pr_dsxml_completo         => null
                                     ,pr_nrseq_mensagem_xml     => null
                                     ,pr_nrdconta               => 05463212
                                     ,pr_cdcooper               => rw_crapcop.cdcooper
                                     ,pr_cdproduto              => 30 -- TED
                                     ,pr_nrseq_mensagem         => vr_nrseq_mensagem20
                                     ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                     ,pr_dscritic               => vr_dscritic
                                     ,pr_des_erro               => vr_des_erro);
          -- Se ocorreu erro
          IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levantar Excecao
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;
             
          SSPB0001.pc_proc_envia_tec_ted (pr_cdcooper => rw_crapcop.cdcooper --> Cooperativa                            
                                         ,pr_cdagenci => '1'                 --> Cod. Agencia 
                                         ,pr_nrdcaixa => 0                   --> Numero Caixa 
                                         ,pr_cdoperad => '1'                 --> Operador 
                                         ,pr_titulari => (rw_flgtitul = 1)   --> Mesmo Titular
                                         ,pr_vldocmto => rw_vldocrcb         --> Vlr. DOCMTO 
                                         ,pr_nrctrlif => rw_idopetrf         --> NumCtrlIF 
                                         -- Informar apenas para nao cair na condicao        
                                         -- ELSIF nvl(pr_nrdconta,0) = 0
                                         ,pr_nrdconta => 05463212            --> Nro Conta
                                         ,pr_cdbccxlt => rw_cdbccrcb         --> Codigo Banco 
                                         ,pr_cdagenbc => rw_cdagercb         --> Cod Agencia 
                                         ,pr_nrcctrcb => rw_nrcctrcb         --> Nr.Ct.destino 
                                         ,pr_cdfinrcb => rw_cdfinrcb         --> Finalidade 
                                         ,pr_tpdctadb => rw_tpdctadb         --> Tp. conta deb 
                                         ,pr_tpdctacr => rw_tpdctacr         --> Tp conta cred 
                                         ,pr_nmpesemi => 'AILOS-RECARGA'    --> Nome Do titular 
                                         ,pr_nmpesde1 =>  NULL               --> Nome De 2TTT 
                                         ,pr_cpfcgemi => rw_cpfcgemi         --> CPF/CNPJ Do titular 
                                         ,pr_cpfcgdel =>  0                  --> CPF sec TTL
                                         ,pr_nmpesrcb => rw_nmpesrcb         --> Nome Para 
                                         ,pr_nmstlrcb =>  NULL               --> Nome Para 2TTL
                                         ,pr_cpfcgrcb => rw_cpfcgrcb         --> CPF/CNPJ Para
                                         ,pr_cpstlrcb => 0                   --> CPF Para 2TTL
                                         ,pr_tppesemi => 2                   --> Tp. pessoa De 
                                         ,pr_tppesrec => 2                   --> Tp. pessoa Para 
                                         ,pr_flgctsal =>  FALSE              --> CC Sal
                                         ,pr_cdidtran => rw_crapcop.nrdocnpj --> tipo de transferencia
                                         ,pr_cdorigem => 1                   --> Cod. Origem 
                                         ,pr_dtagendt =>  NULL               --> data egendamento
                                         ,pr_nrseqarq =>  0                  --> nr. seq arq.
                                         -- Mesmo não se tratando de operação com convênio, deverá
                                         -- informar algum valor neste parâmetro, pois a mensagem a ser
                                         -- gerada será a mesma: STR0007
                                         ,pr_cdconven =>  99999              --> Cod. Convenio
                                         ,pr_dshistor => rw_dshistor         --> Dsc do Hist. 
                                         ,pr_hrtransa => to_char(SYSDATE,'SSSSS') --> Hora transacao 
                                         ,pr_cdispbif => vr_nrispbif            --> ISPB Banco
                                         --------- SAIDA --------
                                         ,pr_cdcritic => vr_cdcritic         --> Codigo do erro
                                         ,pr_dscritic => vr_dscritic );      --> Descricao do erro
          
          -- Se houver erros
          IF vr_cdcritic > 0 OR
             vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          --***** Relatorio *****
          vr_nom_arquivo := 'crrl732';
            
          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          -- Inicilizar as informacoes do XML
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl732><contas' ||
                                                    ' dtpagmto="' || to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR') || '"' ||
                                                    ' nrispbif="' || vr_nrispbif || '"' ||
                                                    ' cdbccxlt="' || vr_cdbccxlt || '"' ||
                                                    ' nrdocnpj="' || vr_nrdocnpj || '"' ||
													' dsdonome="' || gene0007.fn_caract_acento(nvl(vr_dsdonome,'')) || '"' ||
                                                    ' cdageban="' || vr_cdageban || '"' ||
                                                    ' nrdconta="' || vr_nrdconta || '"' ||
                                                    ' vlrepass="' || to_char(vr_vlrepass,'fm999g999g999g990d00') || '"' ||
                                                    ' inperiod="' || vr_inperiod || '"' ||
                                                    ' fiperiod="' || vr_fiperiod || '"' ||
                                                    ' >');
          
          IF vr_tab_repasse.Count > 0 THEN
            
            vr_index := vr_tab_repasse.FIRST;
            -- Percorre registros
            WHILE vr_index IS NOT NULL LOOP
              
              IF vr_index = vr_tab_repasse.FIRST OR
                 vr_tab_repasse(vr_index).cdcooper <> vr_tab_repasse(vr_tab_repasse.PRIOR(vr_index)).cdcooper THEN
                -- Adicionar o no de origem
                pc_escreve_xml('<coop nmrescop="'|| vr_tab_repasse(vr_index).nmrescop  ||'">');
              END IF;
              
              pc_escreve_xml('<conta>' ||
                               '<cdcooper>'  || vr_tab_repasse(vr_index).cdcooper  || '</cdcooper>' ||
                               '<nmrescop>'  || vr_tab_repasse(vr_index).nmrescop  || '</nmrescop>' ||
                               '<operadora>' || vr_tab_repasse(vr_index).operadora || '</operadora>' ||
                               '<qtrecarga>' || vr_tab_repasse(vr_index).qtrecarga || '</qtrecarga>' ||
                               '<vlrecarga>' || to_char(vr_tab_repasse(vr_index).vlregarga,'fm99g999g999g990d00') || '</vlrecarga>' ||
                               '<vlreceita>' || to_char(vr_tab_repasse(vr_index).vlreceita,'fm99g999g999g990d00') || '</vlreceita>' ||
                               '<vlapagar>'  || to_char(vr_tab_repasse(vr_index).vlapagar,'fm99g999g999g990d00')  || '</vlapagar>' ||
                             '</conta>');
              
              --Se mudou a origem ou chegou ao final do vetor
              IF vr_index = vr_tab_repasse.LAST OR
                 vr_tab_repasse(vr_index).cdcooper <> vr_tab_repasse(vr_tab_repasse.NEXT(vr_index)).cdcooper THEN
                -- Finalizar o agrupador da origem
                pc_escreve_xml('</coop>');
              END IF;
              --Proximo registro do vetor
              vr_index:= vr_tab_repasse.NEXT(vr_index);
            END LOOP;
          
          END IF; -- vr_tab_repasse.Count > 0
            
          --Finalizar tag detalhe
          pc_escreve_xml('</contas></crrl732>');
            
          -- Busca do diretório base da cooperativa
          vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => 3 -- CECRED
                                                ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
            
          -- Efetuar solicitacao de geracao de relatorio --
          gene0002.pc_solicita_relato (pr_cdcooper  => 3                   --> Cooperativa conectada
                                      ,pr_cdprogra  => 'JBRCEL_REP'          --> Programa chamador
                                      ,pr_dtmvtolt  => vr_dtmvtolt			 --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl732/contas/coop/conta'       --> No base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl732.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Titulo do relatório
                                      ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'S'                 --> gerar PDF
                                      ,pr_nrvergrl  => 1                   --> JasperSoft Studio
                                      ,pr_dspathcop => ''                  --> Copiar arquivo para diretorio
                                      ,pr_flgremarq => 'N'                 --> Remover arquivo apos copia
                                      ,pr_des_erro  => vr_dscritic);       --> Saída com erro
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            RAISE vr_exc_saida;
          END IF;
            
          -- Liberando a memoria alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
            
        END IF;
        
      END IF;

      pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                     ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      -- Parametros para Ocorrencia
                     ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
  								 
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
                       ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_cdcooper      => 3             --> Codigo da Cooperativa
                       ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,pr_tpocorrencia  => 3             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                       ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                       ,pr_dsmensagem    => vr_dscritic   --> Crítica
                       ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                       ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

        pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                       ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_cdcooper   => 3             --> Codigo da Cooperativa
                       ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
        COMMIT;                              		
      WHEN OTHERS THEN
        ROLLBACK;        
  			
        vr_dscritic := 'Erro não tratado na execução da procedure pc_solicita_produtos_recarga -> '||SQLERRM;
        
        pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
                       ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                       ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                       ,pr_dsmensagem    => vr_dscritic   --> dscritic       
                       ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                       ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

        pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                       ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
  										 
        -- buscar destinatarios do email                           
        vr_email_dest := gene0001.fn_param_sistema('CRED',3 ,'ERRO_EMAIL_JOB');
          
        -- Gravar conteudo do email, controle com substr para não estourar campo texto
        vr_conteudo := substr('ERRO NA EXECUCAO JOB: ' || vr_cdprogra ||
                       '<br>Cooperativa: '     || to_char(3, '990')||                      
                       '<br>Critica: '         || vr_dscritic,1,4000);
                          
        vr_dscritic := NULL;
        --/* Envia e-mail para o Operador */
        gene0003.pc_solicita_email(pr_cdcooper        => 3
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB: ' || vr_cdprogra
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
  			
        COMMIT;
    END;
	END pc_job_efetua_repasse;
  
END RCEL0001;
/
