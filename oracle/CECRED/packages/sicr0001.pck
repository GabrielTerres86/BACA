create or replace package cecred.SICR0001 is
  /*..............................................................................

     Programa: SICR0001      (Antiga: includes/crps642.i)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lunelli
     Data    : Abril/2013                       Ultima atualizacao: 11/04/2017

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Procedimentos para o debito de agendamentos de
                 convenios SICREDI feitos na Internet.

     Alteracoes: 24/04/2013 - Ajustes Sicredi (Elton).

                 21/05/2013 - Ajustes para verificar se deve realizar o debito
                              (Elton).

                 26/08/2013 - Bloquear execucao do programa no processo anual de
                              2013 da Acredi devido migracao para Viacredi (David)

                 27/09/2013 - Conversão Progress --> Oracle PLSQL (Edison - AMcom)

                 31/01/2014 - Alterar Rowid pelo Progress Recid (Gabriel)

                 22/05/2014 - Incluir procudres pc_efetua_debito_automatico e
                              pc_gera_crapndb (Lucas R.)

                 03/09/2014 - Implementado condicao para agendamentos da Concredi
                              devido a migracao CONCREDI -> VIACREDI /
                              CREDIMILSUL -> SCRCRED, procedure
                              pc_obtem_agendamentos_debito (Jean Michel).

                 24/09/2015 - Incluindo procedimento GPS.
                              (André Santos - SUPERO)

                 01/10/2015 - Adicionar as procedures pc_SICR0001_obtem_agen_deb
                              pc_SICR0001_efetua_debitos para a tela DEBSIC
                              (Douglas - Chamado 285228)

                 28/10/2016 - SD509982 - Atualiza critica LAU - pc_efetua_debito_automatico
                              para DEBCON (Guilherme/SUPERO)

				22/12/2016 - Alterado o tipo do campo dscooper
                             (Adriano - SD 582204).
  
	            11/04/2017 - Busca o nome resumido (Ricarod Linhares #547566)
  
  ..............................................................................*/

  -- Chave = dsorigem||fldebito||fltiptra||fltipdoc||lpad(cdcooper,5,'0')||lpad(cdagenci,3,'0')||lpad(nrdconta,9,'0')||ROWID
  TYPE typ_reg_agendamentos IS
  RECORD ( nrchave VARCHAR2(100) --
          ,cdcooper NUMBER(2)    --  FORMAT "z9"
          ,dscooper crapcop.nmrescop%TYPE
          ,cdagenci NUMBER(3)    --  FORMAT "zz9"
          ,nrdconta NUMBER       --  FORMAT "zzzz,zzz,9"
          ,nmprimtl crapass.nmprimtl%TYPE --  FORMAT "x(40)"
          ,cdtiptra NUMBER(2)    --  FORMAT "99"
          ,fltiptra BOOLEAN
          ,dstiptra VARCHAR2(13) --  FORMAT "x(13)"
          ,fltipdoc VARCHAR2(10) --  CONVENIO ou TITULO
          ,dstransa craplau.dscedent%TYPE --  FORMAT "x(32)"
          ,vllanaut NUMBER       --  FORMAT "zzz,zzz,zz9.99"
          ,dttransa DATE         --  FORMAT "99/99/9999"
          ,hrtransa VARCHAR2(8)  --  FORMAT "x(8)"
          ,nrdocmto NUMBER       --  FORMAT "zzz,zz9"
          ,dslindig VARCHAR2(55) --  FORMAT "x(55)"
          ,dscritic VARCHAR2(100)  --  FORMAT "x(40)"
          ,nrdrecid ROWID
          ,fldebito NUMBER(1)
          ,dsorigem VARCHAR2(100)
          ,idseqttl NUMBER
          ,nrseqagp NUMBER
          ,dtmvtolt craplau.dtmvtolt%TYPE
          ,nrseqdig craplau.nrseqdig%TYPE
          ,dshistor VARCHAR2(100)
          ,dtagenda DATE
          ,dsdebito VARCHAR2(15)
          ,prorecid NUMBER);

  -- Definicao do tipo de tabela temporária
  TYPE typ_tab_agendamentos IS
    TABLE OF typ_reg_agendamentos
    INDEX BY VARCHAR2(100);


  /* Procedimento para buscar os lançamentos automáticos efetuados pela Internet e TAA*/
  PROCEDURE pc_obtem_agendamentos_debito( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da cooperativa
                                         ,pr_nmrescop  IN crapcop.nmrescop%TYPE        --> Nome resumido da cooperativa
                                         ,pr_dtmvtopg IN DATE                          --> Data do pagamento
                                         ,pr_inproces IN crapdat.inproces%TYPE         --> Indicador do processo
                                         ,pr_tab_agendamentos IN OUT typ_tab_agendamentos --> Retorna os agendamentos
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                         ,pr_dscritic OUT VARCHAR2);                   --> descrição do erro se ocorrer

  /* Procedimento para efetivar os pagamentos agendados pela Internet e TAA*/
  PROCEDURE pc_efetua_debitos( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                              ,pr_dtmvtopg  IN DATE                         --> Data da efetivação do débito
                              ,pr_inproces  IN crapdat.inproces%TYPE        --> Indicador do processo
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Código do programa
                              ,pr_flsgproc  IN BOOLEAN                      --> Indicador do segundo processamento - DEBSIC
                              ,pr_tab_agendamentos IN OUT typ_tab_agendamentos --> Tabela temporária com a carga de agendamentos
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2);                   --> descrição do erro se ocorrer

  /* Procedimento para gerar o relatório cxom o resumo das operações efetuadas nos agendamentos*/
  PROCEDURE pc_gera_relatorio (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo do Programa
                              ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador do processo
                              ,pr_dtmvtolt  IN DATE                  --> Data do movimento
                              ,pr_tab_agend IN typ_tab_agendamentos  --> Tabela temporária com a carga de agendamentos
                              ,pr_nmrelato OUT VARCHAR2              --> Nome do relatorio gerado
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2);            --> descrição do erro se ocorrer

  /* Procedimento para gerar o relatório cxom o resumo das operações efetuadas nos agendamentos*/
  PROCEDURE pc_gera_relatorio (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
                              ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador do processo
                              ,pr_dtmvtolt  IN DATE                  --> Data do movimento
                              ,pr_tab_agend IN typ_tab_agendamentos  --> Tabela temporária com a carga de agendamentos
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2);            --> Descrição do erro se ocorrer

  ---> Procedure para notificar critica ao cooperado
  PROCEDURE pc_notif_cooperado_DEBAUT ( pr_cdcritic  IN INTEGER
                                       ,pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_nmrescop  IN crapcop.nmrescop%TYPE
                                       ,pr_cdprogra  IN crapprg.cdprogra%TYPE
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                       ,pr_nrdocmto  IN craplau.nrdocmto%TYPE
                                       ,pr_nmconven  IN crapcon.nmextcon%TYPE
                                       ,pr_dtmvtopg  IN craplau.dtmvtopg%TYPE
                                       ,pr_vllanaut  IN craplau.vllanaut%TYPE
                                       ,pr_vlrmaxdb  IN crapatr.vlrmaxdb%TYPE
                                       ,pr_cdrefere  IN crapatr.cdrefere%TYPE
                                       ,pr_cdhistor  IN crapatr.cdhistor%TYPE
                                       ,pr_tpdnotif  IN INTEGER DEFAULT 0       --> Tipo de notificação a ser enviada (0 - Todas, 1 - Msg IBank, 2 - SMS)
                                       ,pr_flfechar_lote IN INTEGER DEFAULT 1
                                       ,pr_idlote_sms IN OUT NUMBER);

  /* Procedimento para efetivar os pagamentos agendados pela Internet e TAA*/
  PROCEDURE pc_efetua_debito_automatico( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                        ,pr_nmrescop  IN crapcop.nmrescop%TYPE        --> Nome da coopertiva
                                        ,pr_cdagesic  IN crapcop.cdagesic%TYPE        --> Codigo da agencia no Sicredi
                                        ,pr_dtmvtopg  IN DATE                         --> Data da efetivação do débito
                                        ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                                        ,pr_inproces  IN crapdat.inproces%TYPE        --> Indicador do processo
                                        ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Código do programa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        --> Numero da conta
                                        ,pr_nrdocmto  IN craplau.nrdocmto%TYPE        --> Documento
                                        ,pr_flsgproc  IN BOOLEAN                      --> Indicador do segundo processamento - DEBSIC
                                        ,pr_tab_agendamentos IN OUT typ_tab_agendamentos  --> Tabela temporária com a carga de agendamentos
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                        ,pr_dscritic OUT VARCHAR2);

  /* Procedimento para criar registros na crapndb */
  PROCEDURE pc_gera_crapndb( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                            ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE        --> Numero da conta
                            ,pr_cdempres  IN craplau.cdempres%TYPE        --> Código da empresa
                            ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE        --> Documento
                            ,pr_nrctacns  IN crapass.nrctacns%TYPE        --> Conta consórcio
                            ,pr_vllanaut  IN craplau.vllanaut%TYPE        --> Valor do lancemento
                            ,pr_cdagenci  IN crapass.cdagenci%TYPE        --> Agencia do cooperado PA
                ,pr_cdseqtel  IN craplau.cdseqtel%TYPE        --> Sequencial
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                            ,pr_dscritic OUT VARCHAR2);                   --> descrição do erro se ocorrer

  /* Procedure para obter agendamento debitos */
  PROCEDURE pc_SICR0001_obtem_agen_deb (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                       ,pr_nmrescop  IN crapcop.nmrescop%TYPE --> Nome resumido da cooperativa
                                       ,pr_dtmvtopg  IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                       ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador processo
                                       ,pr_clobxmlc OUT CLOB                  --> XML com informações dos agendamentos
                                       ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  /* Procedure para efetuar debitos de agendamentos */
  PROCEDURE pc_SICR0001_efetua_debitos (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                       ,pr_dtmvtopg  IN crapdat.dtmvtolt%TYPE --> Data Pagamento
                                       ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador processo
                                       ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo programa
                                       ,pr_flsgproc  IN INTEGER               --> Flag segundo processamento
                                       ,pr_nmrelato OUT VARCHAR2              --> Nome do relatorio gerado
                                       ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  PROCEDURE pc_identifica_crapatr( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        --> Numero da conta
                                  ,pr_nrdocmto  IN craplau.nrdocmto%TYPE        --> Documento
                                  ,pr_cdhistor  IN craplau.cdhistor%TYPE        --> Codigo de historico
                                  ,pr_nrcrcard  IN craplau.nrcrcard%TYPE        --> Numero do cartao
                                  ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Código do programa
                                  ,pr_flagatr  OUT PLS_INTEGER                  --> Flag se possui atr
                                  ,pr_rowid_atr OUT ROWID                       --> Retorna rowid do registro crapatr localizado
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                  ,pr_dscritic OUT VARCHAR2);                   --> descrição do erro se ocorrer

  /* Procedimento para verificar/controlar a execução da DEBNET e DEBSIC */
  PROCEDURE pc_controle_exec_deb ( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                  ,pr_cdtipope  IN VARCHAR2                     --> Tipo de operacao I-incrementar e C-Consultar
                                  ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                                  ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Codigo do programa
                                  ,pr_flultexe OUT INTEGER                       --> Retorna se é a ultima execução do procedimento
                                  ,pr_qtdexec  OUT INTEGER                       --> Retorna a quantidade
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                  ,pr_dscritic OUT VARCHAR2);                   --> descrição do erro se ocorrer

  /* Procedimento para sumarizar os agendamentos da debnet */
  PROCEDURE pc_sumario_debsic(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa inicial
                             ,pr_cdcopfin IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa final
                             ,pr_clobxmlc OUT CLOB                  --> XML com informações dos agendamentos
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Codigo da critica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Descricao critica                                                        
END SICR0001;
/
create or replace package body cecred.SICR0001 is
  /*..............................................................................

     Programa: SICR0001      (Antiga: includes/crps642.i)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lunelli
     Data    : Abril/2013                       Ultima atualizacao: 17/07/2017

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Procedimentos para o debito de agendamentos de
                 convenios SICREDI feitos na Internet.

     Alteracoes: 24/04/2013 - Ajustes Sicredi (Elton).

                 21/05/2013 - Ajustes para verificar se deve realizar o debito
                              (Elton).

                 26/08/2013 - Bloquear execucao do programa no processo anual de
                              2013 da Acredi devido migracao para Viacredi (David)

                 27/09/2013 - Conversão Progress --> Oracle PLSQL (Edison - AMcom)

                 22/05/2014 - Incluir ajustes rereferentes ao Projeto Debito
                              Automatico Softdesk 145056 (Lucas R.)

                 03/09/2014 - Implementado condicao para agendamentos da Concredi
                              devido a migracao CONCREDI -> VIACREDI /
                              CREDIMILSUL -> SCRCRED, procedure
                              pc_obtem_agendamentos_debito (Jean Michel).

                 24/09/2014 - Incluir ajustes referentes ao debito automatico,
                              incluido IF rw_craplau.cdhistor := 1019 na procedure
                              pc_obtem_agendamentos_debito (Lucas R./Elton)

                 16/01/2015 - Correção no preenchimento do nr. do documento na
                              criação da crapndb e no cursor da craplau na rotina
                              de realização de débito automático (Lunelli)

                 22/01/2015 - Apenas efetuar débitos automáticos do SICREDI fora do processo,
                              correção no número do relatório a ser solicitado, remoção de
                              acentos e correção na alimentação do campo craplau.dtdebito
                              na pc_efetua-debito-automatico (Lunelli)

                 29/01/2015 - Correção no retorno de erros da procedure de processamento
                              de debaut do sicredi e não gerar relatório para lançamentos do
                              sicredi se estiver rodando no processo. (Lunelli)

                 17/03/2015 - Correção no fechamento do cursor de lançamentos na procedure de processamento
                              de débito automático e tratamento para não obter lançamentos de débito
                              automático enquanto processo está rodando. (Lunelli)

                 30/03/2015 - Alterado na leitura da craplau para quando for
                              Debito automatico (1019), buscar as datas de
                              pagamentos tambem menores que a data atual, isto
                              para os casos de pagamentos com data no final de
                              semana. (Ajustes pos-liberacao # PRJ Melhoria) -
                              (Fabricio)

                 04/05/2015 - Atualizada data do último débito na tabela de autorizações (crapatr)
                              (Lucas Lunelli - SD 256257)

                 24/09/2015 - Incluindo procedimento GPS.
                              (André Santos - SUPERO)

                 01/10/2015 - Adicionar as procedures pc_SICR0001_obtem_agen_deb
                              pc_SICR0001_efetua_debitos para a tela DEBSIC
                              (Douglas - Chamado 285228)

                 22/12/2015 - Ajustado rotinas para incluir informações no relatorio crrl642 SD376916 (Odirlei-AMcom)

                 25/02/2016 - Incluir validacao de cooperado demitido critica "64" na
                              procedure pc_efetua_debito_automatico (Lucas Ranghetti #400749)

                 24/08/2016 - Incluir tratamento para autorizações suspensas na procedure
                              pc_efetua_debito_automatico (Lucas Ranghetti #499496)

                 28/10/2016 - SD509982 - Atualiza critica LAU - pc_efetua_debito_automatico
                              para DEBCON (Guilherme/SUPERO)
                              
                 21/11/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 11 
                              posicoes, devemos incluir um hifen para completar 12 posicoes 
                              ex: 40151016407- na procedure pc_gera_crapndb 
                              (Lucas Ranghetti #560620/453337)
                              
                 19/01/2017 - Incluir validacao em casos que a DEBNET chamar a procedure
                              pc_identifica_crapatr (Lucas Ranghetti #533520)

				 04/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
				              (Jonata - RKAM M311).
                      
                 17/07/2017 - Ajustes para permitir o agendamento de lancamentos da mesma
                              conta e referencia no mesmo dia(dtmvtolt) porem com valores
                              diferentes (Lucas Ranghetti #684123)                      
  ..............................................................................*/

  -- Objetos para armazenar as variáveis da notificação
  vr_variaveis_notif NOTI0001.typ_variaveis_notif;
  
  /* CONSTANTES */
  ORIGEM_AGEND_NAO_EFETIVADO CONSTANT tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 3;
  MOTIVO_SALDO_INSUFICIENTE  CONSTANT tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 8;
  MOTIVO_LIMITE_EXCEDIDO     CONSTANT tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 9;

  /* Procedimento para buscar os lançamentos automáticos efetuados pela Internet e TAA*/
  PROCEDURE pc_obtem_agendamentos_debito( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da cooperativa
                                         ,pr_nmrescop  IN crapcop.nmrescop%TYPE        --> Nome resumido da cooperativa
                                         ,pr_dtmvtopg IN DATE                          --> Data do pagamento
                                         ,pr_inproces IN crapdat.inproces%TYPE         --> Indicador do processo
                                         ,pr_tab_agendamentos IN OUT typ_tab_agendamentos --> Retorna os agendamentos
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                         ,pr_dscritic OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_obtem_agendamentos_debito (Antigo: obtem-agendamentos-debito)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Lunelli
  --   Data    : Abril/2013                       Ultima atualizacao: 18/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Buscar os lançamentos de débito automático efetuados pela INTERNET e TAA
  --
  --  Alterações: 27/09/2013 - Conversão Progress --> Oracle PLSQL (Edison - AMcom)
  --
  --              31/01/2014 - Alterar Rowid pelo Progress Recid (Gabriel)
  --
  --              03/09/2014 - Implementado condicao para agendamentos da Concredi
  --                           devido a migracao CONCREDI -> VIACREDI /
  --                           CREDIMILSUL -> SCRCRED (Jean Michel).
  --
  --              24/09/2015 - Incluindo procedimento GPS.
  --                           (André Santos - SUPERO)
  --
  --              03/11/2015 - Alterado cursor cr_craplau para melhoria de performance.
  --                           Adicionado parametros de entrada no cursor cr_craplau.
  --                           (Jorge/Fabricio) - SD 331331
  --
  --               18/11/2015 - Removido tratamento usando inproces, pois deve pegar todos
  --                            os registros independente do inproces SD358499 (Odirlei-AMcom)
  --
  --               22/12/2015 - Incluido informações para exibição no relatorio SD (Odirlei-AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Cursor de lançamentos automáticos
      CURSOR cr_craplau ( pr_cdcooper IN craplau.cdcooper%TYPE,
                          pr_dtmvtopg IN craplau.dtmvtopg%TYPE,
                          pr_dtmovini IN craplau.dtmvtopg%TYPE) IS
        SELECT craplau.cdcooper
               ,craplau.cdagenci
               ,craplau.dtmvtopg
               ,craplau.cdtiptra
               ,craplau.vllanaut
               ,craplau.dttransa
               ,craplau.nrdocmto
               ,craplau.dslindig
               ,craplau.dsorigem
               ,craplau.idseqttl
               ,craplau.nrdconta
               ,craplau.dscedent
               ,craplau.hrtransa
               ,craplau.cdhistor
               ,craphis.cdhistor||'-'||craphis.dshistor dshistor
               ,craplau.nrseqagp
               ,craplau.dtmvtolt
               ,craplau.nrseqdig
               ,craplau.ROWID
               ,craplau.progress_recid
        FROM   craplau,
               craphis
        WHERE craplau.cdcooper = pr_cdcooper
          AND craplau.cdcooper = craphis.cdcooper
          AND craplau.cdhistor = craphis.cdhistor
          AND ((craplau.cdcooper = pr_cdcooper
            AND craplau.dtmvtopg = pr_dtmvtopg
            AND craplau.insitlau = 1
            AND craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
            AND craplau.tpdvalor = 1)
              -- debito automatico sicredi
            OR (craplau.cdcooper  = pr_cdcooper
            AND craplau.dtmvtopg BETWEEN pr_dtmovini AND pr_dtmvtopg
            AND craplau.insitlau  = 1
            AND craplau.cdhistor  = 1019)) ;
        rw_craplau cr_craplau%ROWTYPE;

      -- Transferencias entre cooperativas
      CURSOR cr_craptco (pr_nrdconta IN  craptco.nrctaant%TYPE) IS
        SELECT craptco.cdcopant
        FROM   craptco
        WHERE  craptco.cdcopant = pr_cdcooper
        AND    craptco.nrctaant = pr_nrdconta
        AND    craptco.tpctatrf = 1;
      rw_craptco cr_craptco%ROWTYPE;

      -- Informações dos associados
      CURSOR cr_crapass (pr_nrdconta IN  crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.cdagenci
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      vr_exc_erro  EXCEPTION;
      vr_fltiptra  BOOLEAN;
      vr_dstiptra  VARCHAR2(100);
      vr_fltipdoc  VARCHAR2(10);
      vr_dstransa  craplau.dscedent%TYPE;
      vr_chave     VARCHAR2(100);

      vr_dtmovini  craplau.dtmvtopg%TYPE;

    BEGIN
      -- Limpando a tabela temporária
      pr_tab_agendamentos.delete;

      -- Data anterior util
      vr_dtmovini := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                 (pr_dtmvtopg - 1), -- 1 dia anterior
                                                 'A',    -- Anterior
                                                 TRUE,   -- Feriado
                                                 FALSE); -- Desconsiderar 31/12
      -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
      vr_dtmovini := vr_dtmovini + 1;

      -- Abrindo e navegando no cursor de lançamentos
      FOR rw_craplau IN cr_craplau ( pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtopg => pr_dtmvtopg,
                                     pr_dtmovini => vr_dtmovini) LOOP

    vr_fltipdoc := '';

        -- se é pagamento
        IF  rw_craplau.cdtiptra = 2  THEN /** Pagamento **/
          -- Tipo de transação
          vr_fltiptra := FALSE;
          -- Descrição do tipo de transação
          vr_dstiptra := 'Pagamento';

          -- se o tamanho da linha digitável é de 55 posições é convênio
          IF rw_craplau.nrseqagp <> 0 THEN
            vr_fltipdoc := 'GPS'; /** GPS - Guia Previdencia Social **/
          ELSIF  LENGTH(rw_craplau.dslindig) = 55 THEN
            vr_fltipdoc := 'CONVENIOS'; /** Convenio **/
          ELSE
            vr_fltipdoc := 'TITULO'; /** Titulo   **/
          END IF;
          -- Cedente
          vr_dstransa := rw_craplau.dscedent;
        END IF;

        IF rw_craplau.cdhistor = 1019 THEN
          vr_dstiptra := 'Debito Aut.';
      vr_dstransa := rw_craplau.dscedent;
        END IF;

        -- Verifica se a conta existe
        OPEN cr_crapass( pr_nrdconta => rw_craplau.nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        -- Se a conta não existe aborta a execução e gera crítida
        IF  cr_crapass%NOTFOUND THEN
          -- Fecha o cursor para as próximas iterações
          CLOSE cr_crapass;
          -- Gerando a crítica
          pr_cdcritic := 9;
          pr_dscritic := 'Erro em  sicr0001.pc_obtem_agendamentos_debito. Conta '||rw_craplau.nrdconta||' não existe.';
          -- gerando exceção
          RAISE vr_exc_erro;
        ELSE
          -- fecha o cursor para as próximas iterações
          CLOSE cr_crapass;
        END IF;

        -- Montando a chave para ordenação
        SELECT lpad(pr_cdcooper,5,'0')||
               lpad(rw_craplau.nrdconta,10,'0')||
               to_char(rw_craplau.dttransa,'dd/mm/yyyy')||
               lpad(rw_craplau.nrdocmto,25,'0')||
               rw_craplau.cdhistor ||
               rw_craplau.rowid  INTO vr_chave
        FROM dual;

        -- Carregando os agendamentos
        pr_tab_agendamentos(vr_chave).nrchave  := vr_chave;
        pr_tab_agendamentos(vr_chave).cdcooper := pr_cdcooper;
        pr_tab_agendamentos(vr_chave).dscooper := pr_nmrescop;
        pr_tab_agendamentos(vr_chave).nrdconta := rw_craplau.nrdconta;
        pr_tab_agendamentos(vr_chave).nmprimtl := rw_crapass.nmprimtl;
        pr_tab_agendamentos(vr_chave).cdagenci := rw_crapass.cdagenci;
        pr_tab_agendamentos(vr_chave).cdtiptra := rw_craplau.cdtiptra;
        pr_tab_agendamentos(vr_chave).fltiptra := vr_fltiptra;
        pr_tab_agendamentos(vr_chave).dstiptra := vr_dstiptra;
        pr_tab_agendamentos(vr_chave).fltipdoc := vr_fltipdoc;
        pr_tab_agendamentos(vr_chave).dstransa := vr_dstransa;
        pr_tab_agendamentos(vr_chave).vllanaut := rw_craplau.vllanaut;
        pr_tab_agendamentos(vr_chave).dttransa := rw_craplau.dttransa;
        pr_tab_agendamentos(vr_chave).hrtransa := rw_craplau.hrtransa;
        pr_tab_agendamentos(vr_chave).nrdocmto := rw_craplau.nrdocmto;
        pr_tab_agendamentos(vr_chave).dslindig := rw_craplau.dslindig;
        pr_tab_agendamentos(vr_chave).dscritic := '';
        pr_tab_agendamentos(vr_chave).nrdrecid := rw_craplau.rowid;
        pr_tab_agendamentos(vr_chave).fldebito := 0;
        pr_tab_agendamentos(vr_chave).dsorigem := rw_craplau.dsorigem;
        pr_tab_agendamentos(vr_chave).idseqttl := rw_craplau.idseqttl;
        pr_tab_agendamentos(vr_chave).dtagenda := pr_dtmvtopg;
        pr_tab_agendamentos(vr_chave).dsdebito := 'NAO EFETUADOS';
        pr_tab_agendamentos(vr_chave).prorecid := rw_craplau.progress_recid;
        pr_tab_agendamentos(vr_chave).dtmvtolt := rw_craplau.dtmvtolt;
        pr_tab_agendamentos(vr_chave).nrseqdig := rw_craplau.nrseqdig;
        pr_tab_agendamentos(vr_chave).dshistor := rw_craplau.dshistor;

        IF rw_craplau.cdhistor = 1019 THEN
          pr_tab_agendamentos(vr_chave).dsorigem := 'DEBITO AUTOMATICO';
        ELSE
          pr_tab_agendamentos(vr_chave).dsorigem := rw_craplau.dsorigem;
        END IF;

      END LOOP; --FOR rw_craplau IN cr_craplau

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- retorna erro tratado
        pr_cdcritic := pr_cdcritic;
        pr_dscritic := pr_dscritic;

      WHEN OTHERS THEN
        -- Retorna o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado em sicr0001.pc_obtem_agendamentos_debito --> '||SQLERRM;
    END;
  END pc_obtem_agendamentos_debito;

  /* Procedimento para efetivar os pagamentos agendados pela Internet e TAA*/
  PROCEDURE pc_efetua_debitos( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                              ,pr_dtmvtopg  IN DATE                         --> Data da efetivação do débito
                              ,pr_inproces  IN crapdat.inproces%TYPE        --> Indicador do processo
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Código do programa
                              ,pr_flsgproc  IN BOOLEAN                      --> Indicador do segundo processamento - DEBSIC
                              ,pr_tab_agendamentos IN OUT typ_tab_agendamentos  --> Tabela temporária com a carga de agendamentos
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_efetua_debitos (Antigo: efetua-debitos)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Lunelli
  --   Data    : Abril/2013                       Ultima atualizacao: 24/09/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Efetua os lançamentos de débitos
  --
  --  Alterações: 27/09/2013 - Conversão Progress --> Oracle PLSQL (Edison - AMcom)
  --
  --              31/01/2014 - Alterar Rowid pelo Progress Recid (Gabriel)
  --
  --              04/02/2014 - Alterar parametros da debita agendamento pagamento
  --                           (Gabriel)
  --
  --              22/05/2014 - Incluir ajustes rereferentes ao Projeto Debito
  --                           Automatico Softdesk 145056 (Lucas R.)
  --
  --              12/05/2015 - Realizar commit a cada registro para que as tabelas não fiquem por muito tempo
  --                           lockadas, interferindo as atividades do internetbank SD285156 (Odirlei-AMcom)
  --
  --              24/09/2015 - Incluindo procedimento GPS.
  --                           (André Santos - SUPERO)
  --
  --             18/11/2015 - incluido paramentros na chamad da pc_efetua_debito_automatico SD358499 (Odirlei-AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- VARIAVEIS
      vr_ind      VARCHAR2(100);
      vr_ind_aux  VARCHAR2(100);
      vr_flsgproc PLS_INTEGER;
      vr_tab_aux  typ_tab_agendamentos;
      vr_cdagenci NUMBER;
      vr_idorigem NUMBER;
      vr_dscritic VARCHAR2(4000);

      -- CURSORES
      -- Busca dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.cdagesic,
               cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    BEGIN
      --
      vr_tab_aux.delete;
      -- Se a tabela temporária possuir registros, eles serão processados
      IF pr_tab_agendamentos.count > 0 THEN

        -- Posiciona no primeiro registro
        vr_ind := pr_tab_agendamentos.FIRST;

        -- Segundo processamento
        IF  pr_flsgproc  THEN
          vr_flsgproc := 1;
        ELSE
          vr_flsgproc := 0;
        END IF;

        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop;
        FETCH cr_crapcop INTO rw_crapcop;

        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          pr_cdcritic := 651;
          RETURN;
        ELSE
          CLOSE cr_crapcop;
        END IF;

        -- Inicia o laço do loop
        LOOP
          -- Sai quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;

          BEGIN
            -- Configura os códigos de agência e origem do débito cfme origem do lançamento
            IF pr_tab_agendamentos(vr_ind).dsorigem = 'INTERNET' OR
               pr_tab_agendamentos(vr_ind).dsorigem = 'TAA'      OR
               pr_tab_agendamentos(vr_ind).dsorigem = 'CAIXA'    THEN

            -- verifica se origem é TAA ou INTERNET
              CASE pr_tab_agendamentos(vr_ind).dsorigem
                WHEN 'INTERNET' THEN vr_cdagenci := 90; vr_idorigem := 3; /* INTERNET */
                WHEN 'TAA'      THEN vr_cdagenci := 91; vr_idorigem := 4; /* TAA */
                WHEN 'CAIXA'    THEN vr_cdagenci :=  pr_tab_agendamentos(vr_ind).cdagenci; vr_idorigem := 2; /* CAIXA */
              END CASE;

            -- Executa o débito dos agendamentos
              PAGA0001.pc_debita_agendto_pagto( pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                               ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                               ,pr_nrdcaixa => 900           --Numero Caixa
                                               ,pr_cdoperad => '996'         --Operador
                                               ,pr_nmdatela => pr_cdprogra   --Nome programa
                                               ,pr_idorigem => vr_idorigem   --origem (TAA ou Internet)
                                               ,pr_dtmvtolt => pr_dtmvtopg   --Data pagamento
                                               ,pr_inproces => pr_inproces   --Indicador Processo
                                               ,pr_flsgproc => vr_flsgproc   --Flag segundo processamento
                                               ,pr_craplau_progress_recid  => pr_tab_agendamentos(vr_ind).prorecid --Recid lancamento automatico
                                               ,pr_cdcritic => pr_cdcritic   --Codigo da Critica
                                             ,pr_dscritic => vr_dscritic); -- Descrição do erro ou motivo do não débito

            -- Verifica se deu erro no processamento do débito
              IF vr_dscritic IS NOT NULL THEN
                -- Registra o erro ocorrido no registro
                pr_tab_agendamentos(vr_ind).dscritic := upper(substr(vr_dscritic,1,100));
              ELSE
              -- informa que o débito foi efetuado com sucesso
                pr_tab_agendamentos(vr_ind).fldebito := 1;
                pr_tab_agendamentos(vr_ind).dsdebito := 'EFETUADOS';
              END IF;
            ELSE
        -- Efetuar lançamento de debito automatico sicredi
              SICR0001.pc_efetua_debito_automatico
                                                    ( pr_cdcooper => pr_cdcooper,
                                                      pr_nmrescop => rw_crapcop.nmrescop,
                                                      pr_cdagesic => rw_crapcop.cdagesic,
                                                      pr_dtmvtopg => pr_dtmvtopg,
                                                      pr_dtmvtolt => pr_dtmvtopg,
                                                      pr_inproces => pr_inproces,
                                                      pr_cdprogra => pr_cdprogra,
                                                      pr_nrdconta => pr_tab_agendamentos(vr_ind).nrdconta,
                                                      pr_nrdocmto => pr_tab_agendamentos(vr_ind).nrdocmto,
                                                      pr_flsgproc => pr_flsgproc,
                                                      pr_tab_agendamentos => pr_tab_agendamentos,
                                                      pr_cdcritic => pr_cdcritic,
                                                      pr_dscritic => vr_dscritic);
        -- Verifica se deu erro no processamento do débito
              IF vr_dscritic IS NOT NULL THEN
                -- Registra o erro ocorrido no registro
                pr_tab_agendamentos(vr_ind).dscritic := upper(substr(vr_dscritic,1,100));
              ELSE
                -- informa que o débito foi efetuado com sucesso
                pr_tab_agendamentos(vr_ind).fldebito := 1;
                pr_tab_agendamentos(vr_ind).dsdebito := 'EFETUADOS';
              END IF;
          END IF;

          -- Montando a chave auxiliar baseada nos registros atualizados
          -- e utilizando novo índice para geração do relatório
          SELECT pr_tab_agendamentos(vr_ind).dsorigem||
                 pr_tab_agendamentos(vr_ind).fldebito||
                 nvl(pr_tab_agendamentos(vr_ind).dstiptra,'#########')||
                 nvl(pr_tab_agendamentos(vr_ind).fltipdoc,'########')||
                 lpad(pr_tab_agendamentos(vr_ind).cdcooper,5,'0')||
                 lpad(pr_tab_agendamentos(vr_ind).cdagenci,3,'0')||
                 lpad(pr_tab_agendamentos(vr_ind).nrdconta,10,'0')||
                 pr_tab_agendamentos(vr_ind).nrdrecid INTO vr_ind_aux
          FROM dual;

          -- Recarregando a tabela temporária por causa da mudança do índice
          vr_tab_aux(vr_ind_aux).nrchave  := vr_ind_aux;
          vr_tab_aux(vr_ind_aux).cdcooper := pr_tab_agendamentos(vr_ind).cdcooper;
          vr_tab_aux(vr_ind_aux).dscooper := pr_tab_agendamentos(vr_ind).dscooper;
          vr_tab_aux(vr_ind_aux).nrdconta := pr_tab_agendamentos(vr_ind).nrdconta;
          vr_tab_aux(vr_ind_aux).nmprimtl := pr_tab_agendamentos(vr_ind).nmprimtl;
          vr_tab_aux(vr_ind_aux).cdagenci := pr_tab_agendamentos(vr_ind).cdagenci;
          vr_tab_aux(vr_ind_aux).cdtiptra := pr_tab_agendamentos(vr_ind).cdtiptra;
          vr_tab_aux(vr_ind_aux).fltiptra := pr_tab_agendamentos(vr_ind).fltiptra;
          vr_tab_aux(vr_ind_aux).dstiptra := pr_tab_agendamentos(vr_ind).dstiptra;
          vr_tab_aux(vr_ind_aux).fltipdoc := pr_tab_agendamentos(vr_ind).fltipdoc;
          vr_tab_aux(vr_ind_aux).dstransa := pr_tab_agendamentos(vr_ind).dstransa;
          vr_tab_aux(vr_ind_aux).vllanaut := pr_tab_agendamentos(vr_ind).vllanaut;
          vr_tab_aux(vr_ind_aux).dttransa := pr_tab_agendamentos(vr_ind).dttransa;
          vr_tab_aux(vr_ind_aux).hrtransa := pr_tab_agendamentos(vr_ind).hrtransa;
          vr_tab_aux(vr_ind_aux).nrdocmto := pr_tab_agendamentos(vr_ind).nrdocmto;
          vr_tab_aux(vr_ind_aux).dslindig := pr_tab_agendamentos(vr_ind).dslindig;
          vr_tab_aux(vr_ind_aux).dscritic := pr_tab_agendamentos(vr_ind).dscritic;
          vr_tab_aux(vr_ind_aux).nrdrecid := pr_tab_agendamentos(vr_ind).nrdrecid;
          vr_tab_aux(vr_ind_aux).fldebito := pr_tab_agendamentos(vr_ind).fldebito;
          vr_tab_aux(vr_ind_aux).dsorigem := pr_tab_agendamentos(vr_ind).dsorigem;
          vr_tab_aux(vr_ind_aux).idseqttl := pr_tab_agendamentos(vr_ind).idseqttl;
          vr_tab_aux(vr_ind_aux).dtagenda := pr_tab_agendamentos(vr_ind).dtagenda;
          vr_tab_aux(vr_ind_aux).dsdebito := pr_tab_agendamentos(vr_ind).dsdebito;
          vr_tab_aux(vr_ind_aux).dshistor := pr_tab_agendamentos(vr_ind).dshistor;

          --  Tratamento para evitar que aborte o programa
          EXCEPTION
            WHEN OTHERS THEN
              IF TRIM(pr_tab_agendamentos(vr_ind).dscritic) IS NULL THEN
                pr_tab_agendamentos(vr_ind).dscritic := 'Não foi possivel realizar debito: '||SQLERRM;
              END IF;
          END;

          -- commit a cada registro
          COMMIT;

          -- Buscar o proximo registro da tabela
          vr_ind := pr_tab_agendamentos.NEXT(vr_ind);

        END LOOP;


        -- Retornando a tabela temporaria dos lancamentos atualizada
        pr_tab_agendamentos := vr_tab_aux;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorna o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado em sicr0001.pc_efetua_debitos --> '||SQLERRM;
    END;
  END pc_efetua_debitos;

  /* Procedimento para gerar o relatório com o resumo das operações efetuadas nos agendamentos*/
  PROCEDURE pc_gera_relatorio (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo do Programa
                              ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador do processo
                              ,pr_dtmvtolt  IN DATE                  --> Data do movimento
                              ,pr_tab_agend IN typ_tab_agendamentos  --> Tabela temporária com a carga de agendamentos
                              ,pr_nmrelato OUT VARCHAR2              --> Nome do relatorio gerado
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2) IS          --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gera_relatorio (Antigo: gera-relatorio)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Lunelli
  --   Data    : Abril/2013                       Ultima atualizacao: 26/11/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Gerar relatório com todos os agendamentos exibindo o status
  --
  --  Alterações: 02/10/2013 - Conversão Progress --> Oracle PLSQL (Edison - AMcom)
  --
  --              11/07/2014 - Correção do path para cópia do relatório (Marcos-Supero)
  --
  --              14/07/2014 - Correçlão na lógica da geração do nome do arquivo (Marcos-Supero)
  --              17/07/2014 - Passagem do sebcabrel conforme cada relatório (Marcos-Supero)
  --              26/11/2014 - Retirado Subdir rl parametro pr_dsarqsaid para não ocorrer de gerar rl/rl(Lucas R.)
  --
  --              18/11/2015 - Retirado inprocess pois sistema ira rodar via job com inproces = 1  SD358499 (Odirlei-AMcom)
  --
  --              22/12/2015 - Inluido novos campos no relatorio crrl642. SD376916(Odirlei-AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_ind      VARCHAR2(100);
      vr_exc_erro EXCEPTION;
      -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);
      vr_dspathcop    VARCHAR2(4000);
      vr_nmrelato     VARCHAR2(40);
      vr_cdrelato     NUMBER;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN

      -- Se a tabela temporária possuir registros, eles serão processados
      IF pr_tab_agend.count > 0 THEN

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -------------------------------------------
        -- Iniciando a geração do XML
        -------------------------------------------
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl642>');

        -- Posiciona no primeiro registro
        vr_ind := pr_tab_agend.FIRST;

        -- Inicia o laço do loop
        LOOP
          -- Sai quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;

          -- se é o primeiro registro, guarda o código da cooperativa para geração do arquivo
          IF vr_ind = pr_tab_agend.FIRST THEN
            vr_cdcooper := pr_tab_agend(vr_ind).cdcooper;
          END IF;

          pc_escreve_xml( '<chave nrchave="'||pr_tab_agend(vr_ind).nrchave||'">'||
                                '<cdcooper>'||pr_tab_agend(vr_ind).cdcooper||'</cdcooper>'||
                                '<dscooper>'||pr_tab_agend(vr_ind).dscooper||'</dscooper>'||
                                '<nrdconta>'||GENE0002.fn_mask_conta(pr_tab_agend(vr_ind).nrdconta)||'</nrdconta>'||
                                '<nmprimtl>'||pr_tab_agend(vr_ind).nmprimtl||'</nmprimtl>'||
                                '<cdagenci>'||pr_tab_agend(vr_ind).cdagenci||'</cdagenci>'||
                                '<cdtiptra>'||pr_tab_agend(vr_ind).cdtiptra||'</cdtiptra>'||
                                '<dstiptra>'||pr_tab_agend(vr_ind).dstiptra||'</dstiptra>'||
                                '<fltipdoc>'||pr_tab_agend(vr_ind).fltipdoc||'</fltipdoc>'||
                                '<dstransa>'||pr_tab_agend(vr_ind).dstransa||'</dstransa>'||
                                '<vllanaut>'||pr_tab_agend(vr_ind).vllanaut||'</vllanaut>'||
                                '<dttransa>'||pr_tab_agend(vr_ind).dttransa||'</dttransa>'||
                                '<hrtransa>'||pr_tab_agend(vr_ind).hrtransa||'</hrtransa>'||
                                '<nrdocmto>'||pr_tab_agend(vr_ind).nrdocmto||'</nrdocmto>'||
                                '<dslindig>'||pr_tab_agend(vr_ind).dslindig||'</dslindig>'||
                                '<dscritic>'||pr_tab_agend(vr_ind).dscritic||'</dscritic>'||
                                '<nrdrecid>'||pr_tab_agend(vr_ind).nrdrecid||'</nrdrecid>'||
                                '<fldebito>'||pr_tab_agend(vr_ind).fldebito||'</fldebito>'||
                                '<dsorigem>'||pr_tab_agend(vr_ind).dsorigem||'</dsorigem>'||
                                '<idseqttl>'||pr_tab_agend(vr_ind).idseqttl||'</idseqttl>'||
                                '<dtagenda>'||to_char(pr_tab_agend(vr_ind).dtagenda,'dd/mm/yyyy')||'</dtagenda>'||
                                '<dsdebito>'||pr_tab_agend(vr_ind).dsdebito||'</dsdebito>'||
                                '<dtmvtolt>'||to_char(pr_tab_agend(vr_ind).dtmvtolt,'dd/mm/yyyy') ||'</dtmvtolt>'||
                                '<nrseqdig>'||pr_tab_agend(vr_ind).nrseqdig ||'</nrseqdig>'||
                                '<dshistor>'||pr_tab_agend(vr_ind).dshistor ||'</dshistor>'||
                          '</chave>');

          -- Buscar o próximo registro da tabela
          vr_ind := pr_tab_agend.NEXT(vr_ind);

        END LOOP;
        -- Finalizando o arquivo xml
        pc_escreve_xml('</crrl642>');

        -- Busca do diretório base da cooperativa e a subpasta de relatórios
        vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'rl'); --> Gerado no diretorio /rl


        -- Durante o processo gera o 642
        vr_nmrelato := 'crrl642_' || to_char( gene0002.fn_busca_time ) || '.lst';
        vr_cdrelato := 642;

        -- gerar copia em rlnsv
        vr_dspathcop := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'rlnsv'); --> Gerado no diretorio /rlnsv

        -- Gerando o relatório nas pastas /rl e /rlnsv
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                   ,pr_cdprogra  => pr_cdprogra
                                   ,pr_dtmvtolt  => pr_dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/crrl642'
                                   ,pr_dsjasper  => 'crrl642.jasper'
                                   ,pr_dsparams  => ''
                                   ,pr_dsarqsaid => vr_path_arquivo ||'/'|| vr_nmrelato
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 234
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => vr_cdrelato
                                   ,pr_flg_impri => 'S'
                                   ,pr_nmformul  => '234col'
                                   ,pr_nrcopias  => 1
                                   ,pr_dspathcop => vr_dspathcop
                                   ,pr_dsmailcop => NULL
                                   ,pr_dsassmail => NULL
                                   ,pr_dscormail => NULL
                                   ,pr_des_erro  => pr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
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
        pr_dscritic := 'Erro não tratado em sicr0001.pc_gera_relatorio --> '||SQLERRM;
    END;
  END pc_gera_relatorio;

  /* Procedimento para gerar o relatório cxom o resumo das operações efetuadas nos agendamentos*/
  PROCEDURE pc_gera_relatorio (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
                              ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador do processo
                              ,pr_dtmvtolt  IN DATE                  --> Data do movimento
                              ,pr_tab_agend IN typ_tab_agendamentos  --> Tabela temporária com a carga de agendamentos
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2)IS           --> Descrição do erro se ocorrer
    -- ..........................................................................
    --
    --  Programa : pc_gera_relatorio
    --  Sistema  : Rotinas Internet
    --  Sigla    : AGEN
    --  Autor    : Douglas Quisinski
    --  Data     : Outubro/2015                  Ultima atualizacao:   /  /
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure que não possui o parametro de nome do relatorio gerado que possui a mesma
    --               funcionalidade da procedure acima
    --
    --   Alteracao :
    -- ..........................................................................

    vr_nmrelato VARCHAR2(100);

    BEGIN
      pc_gera_relatorio(pr_cdcooper  => pr_cdcooper
                       ,pr_cdprogra  => pr_cdprogra
                       ,pr_inproces  => pr_inproces
                       ,pr_dtmvtolt  => pr_dtmvtolt
                       ,pr_tab_agend => pr_tab_agend
                       ,pr_nmrelato  => vr_nmrelato
                       ,pr_cdcritic  => pr_cdcritic
                       ,pr_dscritic  => pr_dscritic);
    EXCEPTION
      WHEN OTHERS THEN
        -- Erro
        pr_dscritic:= 'Erro na rotina PAGA0001.pc_gera_relatorio. '||sqlerrm;
  END pc_gera_relatorio;

  ---> Procedure para notificar critica ao cooperado
  PROCEDURE pc_notif_cooperado_DEBAUT ( pr_cdcritic  IN INTEGER                 --> Critica na qual o cooperado deve ser notificado
                                       ,pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo do cooperado
                                       ,pr_nmrescop  IN crapcop.nmrescop%TYPE   --> Nome da cooperativa
                                       ,pr_cdprogra  IN crapprg.cdprogra%TYPE   --> Codigo do programa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE   --> Numero da conta
                                       ,pr_nrdocmto  IN craplau.nrdocmto%TYPE   --> Numero do documento
                                       ,pr_nmconven  IN crapcon.nmextcon%TYPE   --> Nome do convenio
                                       ,pr_dtmvtopg  IN craplau.dtmvtopg%TYPE   --> Data de pagamento
                                       ,pr_vllanaut  IN craplau.vllanaut%TYPE   --> Valor do lançamento
                                       ,pr_vlrmaxdb  IN crapatr.vlrmaxdb%TYPE   --> Limite maximo
                                       ,pr_cdrefere  IN crapatr.cdrefere%TYPE   --> Codigo de referencia da crapaut
                                       ,pr_cdhistor  IN crapatr.cdhistor%TYPE   --> Codigo do histórico
                                       ,pr_tpdnotif  IN INTEGER DEFAULT 0       --> Tipo de notificação a ser enviada (0 - Todas, 1 - Msg IBank, 2 - SMS)
                                       ,pr_flfechar_lote IN INTEGER DEFAULT 1   --> Indica se deve fechar o lote do SMS 1-Fechar lote , 0-Manter aberto
                                       ,pr_idlote_sms IN OUT NUMBER             --> Numero do lote do SMS para caso não for fechado o lote do SMS
                                       ) IS

  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_notif_cooperado_DEBAUT
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Odirlei Busana - AMcom
  --   Data    : Maio/2016                       Ultima atualizacao: 19/05/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Procedimento para notificar as criticas ao cooperado
  --
  --  Alteracoes:
  --
  --------------------------------------------------------------------------------------------------------------------*/
    -------------> CURSOR <--------------
    --Selecionar titulares com senhas ativas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_cdsitsnh IN crapsnh.cdsitsnh%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.cdsitsnh = pr_cdsitsnh
         AND crapsnh.tpdsenha = pr_tpdsenha;
    rw_crapsnh cr_crapsnh%ROWTYPE;

    vr_dscritic               VARCHAR2(4000);
    vr_dsdmensg               VARCHAR2(4000);
    vr_nmconven               crapcon.nmextcon%TYPE;
    vr_cdtipo_mensagem_IB     tbgen_tipo_mensagem.cdtipo_mensagem%TYPE;
    vr_cdtipo_mensagem_SMS    tbgen_tipo_mensagem.cdtipo_mensagem%TYPE;
    vr_dsdassun               crapmsg.dsdassun%TYPE;
    vr_dsdplchv               crapmsg.dsdplchv%TYPE;
    vr_idmotivo               tbconv_motivo_msg.idmotivo%TYPE;
    vr_valores_dinamicos      VARCHAR2(500);

    vr_motivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE;


  BEGIN

    --> Definir variaveis conforme a critica
    CASE pr_cdcritic
      WHEN 717 THEN -- saldo insuficiente
        vr_cdtipo_mensagem_IB  := 3;
        vr_cdtipo_mensagem_SMS := 5;
        vr_dsdassun := 'Transação não efetivada';
        vr_dsdplchv := 'Sem Saldo para Pagamento';
        vr_idmotivo := 30;
        vr_motivo_mensagem := MOTIVO_SALDO_INSUFICIENTE;

      WHEN 967 THEN -- excede limite
        vr_cdtipo_mensagem_IB  := 4;
        vr_cdtipo_mensagem_SMS := 6;
        vr_dsdassun := 'Fatura excede limite débito automático';
        vr_dsdplchv := 'Débito Automático';
        vr_idmotivo := 31;
        vr_motivo_mensagem := MOTIVO_LIMITE_EXCEDIDO;

      ELSE RETURN;
    END CASE;

    --> Remove as palavras -COD.BARRAS no fim da frase
    vr_nmconven := TRIM(regexp_replace(pr_nmconven, '\-[^-]*$')); -- Remove o último hífen e tudo após ele
    vr_nmconven := TRIM(regexp_replace(vr_nmconven, 'COD[. ]*BAR.*$')); -- Esta é caso não possuir hífen, então remove a palavra (COD.BAR ou COD BAR) e tudo após ela

    --> Variavel para SMS
    vr_valores_dinamicos := '#Cooperativa#=' ||pr_nmrescop ||';'||
                            '#Convenio#='|| vr_nmconven    ||';'||
                            '#Data#='    || to_char(pr_dtmvtopg,'DD/MM/RRRR') ||';'||
                            '#Valor#='   || to_char(pr_vllanaut,'fm999G999G990D00') ||';'||
                            '#Limite#='  || to_char(pr_vlrmaxdb,'fm999G999G990D00');

    --> Se for todos ou Msg Ibank
    IF pr_tpdnotif IN (0,1) THEN
      
      vr_variaveis_notif('#datadebito') := to_char(pr_dtmvtopg,'DD/MM/RRRR');
      vr_variaveis_notif('#convenio') := vr_nmconven;
      vr_variaveis_notif('#valor') := to_char(pr_vllanaut,'fm999G999G990D00');
      vr_variaveis_notif('#limite') := to_char(pr_vlrmaxdb,'fm999G999G990D00');  
      
      -- Cria uma notificação
      NOTI0001.pc_cria_notificacao(pr_cdorigem_mensagem => ORIGEM_AGEND_NAO_EFETIVADO
                                  ,pr_cdmotivo_mensagem => vr_motivo_mensagem
                                  --,pr_dhenvio => SYSDATE
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_variaveis => vr_variaveis_notif);
      
      --> Buscar pessoas que possuem acesso a conta
      FOR rw_crapsnh IN cr_crapsnh (pr_cdcooper  => pr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta
                                   ,pr_cdsitsnh  => 1
                                   ,pr_tpdsenha  => 1) LOOP
        --> buscar mensagem
        vr_dsdmensg := GENE0003.fn_buscar_mensagem
                                   (pr_cdcooper        => pr_cdcooper
                                   ,pr_cdproduto       => 10
                                   ,pr_cdtipo_mensagem => vr_cdtipo_mensagem_IB -- Ibank
                                   ,pr_sms             => 0
                                   ,pr_valores_dinamicos => vr_valores_dinamicos);

        --> Insere na tabela de mensagens (CRAPMSG)
        GENE0003.pc_gerar_mensagem
                   (pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idseqttl => rw_crapsnh.idseqttl /* Titular */
                   ,pr_cdprogra => pr_cdprogra  /* Programa */
                   ,pr_inpriori => 0
                   ,pr_dsdmensg => vr_dsdmensg  /* corpo da mensagem */
                   ,pr_dsdassun => vr_dsdassun  /* Assunto */
                   ,pr_dsdremet => pr_nmrescop
                   ,pr_dsdplchv => vr_dsdplchv
                   ,pr_cdoperad => 1
                   ,pr_cdcadmsg => 0
                   ,pr_dscritic => vr_dscritic);
      END LOOP; -- Fim loop CRAPSNH
    END IF;

    -- Se for todos ou SMS
    IF pr_tpdnotif IN (0,2) THEN
      ----> ENVIAR SMS
      --> buscar mensagem
      vr_dsdmensg := GENE0003.fn_buscar_mensagem
                               (pr_cdcooper        => pr_cdcooper
                               ,pr_cdproduto       => 10
                               ,pr_cdtipo_mensagem => vr_cdtipo_mensagem_SMS --SMS
                               ,pr_sms             => 1
                               ,pr_valores_dinamicos => vr_valores_dinamicos);

      -- Garantir que o valor vá nulo na primeira SMS do lote
      pr_idlote_sms := nullif(pr_idlote_sms,0);
      --> Gravar SMS de alerta de limite excedido
      ESMS0001.pc_escreve_sms_debaut ( pr_cdcooper    => pr_cdcooper
                                      ,pr_nrdconta    => pr_nrdconta
                                      ,pr_dsmensagem  => vr_dsdmensg
                                      ,pr_vlfatura    => pr_vllanaut
                                      ,pr_idmotivo    => vr_idmotivo
                                      ,pr_cdrefere    => pr_cdrefere
                                      ,pr_cdhistor    => pr_cdhistor
                                      ,pr_idlote_sms  => pr_idlote_sms
                                      ,pr_dscritic    => vr_dscritic);

      --> Concluir envio dos SMS
      IF pr_flfechar_lote = 1 AND nvl(pr_idlote_sms,0) > 0  THEN
        ESMS0001.pc_conclui_lote_sms(pr_idlote_sms  => pr_idlote_sms
                                    ,pr_dscritic    => vr_dscritic);
        pr_idlote_sms := NULL;
      END IF;
      vr_dscritic := NULL;
    END IF;
  END pc_notif_cooperado_DEBAUT;

  /* Procedimento para efetivar os pagamentos agendados pela Internet e TAA*/
  PROCEDURE pc_efetua_debito_automatico(pr_cdcooper         IN crapcop.cdcooper%TYPE --> Código da coopertiva
                                       ,pr_nmrescop         IN crapcop.nmrescop%TYPE --> Nome da coopertiva
                                       ,pr_cdagesic         IN crapcop.cdagesic%TYPE --> Codigo da agencia no Sicredi
                                       ,pr_dtmvtopg         IN DATE --> Data da efetivação do débito
                                       ,pr_dtmvtolt         IN DATE --> Data do movimento
                                       ,pr_inproces         IN crapdat.inproces%TYPE --> Indicador do processo
                                       ,pr_cdprogra         IN crapprg.cdprogra%TYPE --> Código do programa
                                       ,pr_nrdconta         IN crapass.nrdconta%TYPE --> Numero da conta
                                       ,pr_nrdocmto         IN craplau.nrdocmto%TYPE --> Documento
                                       ,pr_flsgproc         IN BOOLEAN --> Indicador do segundo processamento - DEBSIC
                                       ,pr_tab_agendamentos IN OUT typ_tab_agendamentos --> Tabela temporária com a carga de agendamentos
                                       ,pr_cdcritic         OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                                       ,pr_dscritic         OUT VARCHAR2) IS --> descrição do erro se ocorrer
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_efetua-debito-automatico
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Lucas Ranghetti
    --   Data    : Maio/2014                       Ultima atualizacao: 17/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Efetua os lançamentos de débitos Automaticos
    --
    --  Alterac?es: 12/05/2015 - Tratar pragma autonomos_transaction para gravar craplot
    --                           para não deixar muito tempo a tabela de lote alocada SD 285156(Odirlei-AMcom)
    --
    --              16/09/2015 - Melhoria performace, inclusao do parametro de tipo de busca na chamada do procedimento
    --                           EXTR0001.pc_obtem_saldo_dia, para utilizar a dtmvtoan como base na busca(Odirlei-AMcom)
    --
    --              29/09/2015 - Ajustado rotina para leitura da crapdat utilizada na chamada da  EXTR0001.pc_obtem_saldo_dia
    --                           SD339666 (Odirlei-AMcom)
    --
    --             18/11/2015 - Retirado inprocess pois sistema ira rodar via job com inproces = 1,
    --                          replicado tratamentos da crps123 que nao sera mais rodado para os DBAUT.  SD358499 (Odirlei-AMcom)
    --
    --             18/12/2015 - Inicializar variavel vr_ind_sald SD358499 (odirlei-AMcom)
    --
    --             25/02/2016 - Incluir validacao de cooperado demitido critica "64" na
    --                          procedure pc_efetua_debito_automatico (Lucas Ranghetti #400749)
    --
    --             18/05/2016 - Ajustes para notificar via SMS e IBank quando faturas não forem pagas devido a ultrapassar
    --                          limite definido da crapatr ou por não possuir saldo e inclusao da criação do protocolo..
    --                          PRJ320 - Oferta Debaut (Odirlei-AMcom)
    --
    --             27/07/2016 - Desabilitar temporariamente a criação do protocolo devido existir
    --                          diferença no tamanho do campo de protocolo entre  a tabela crappro e crapaut
    --                          acarretando erro ao atualizar tabela crapaut.
    --                          PRJ320 - Oferta Debaut (Odirlei-AMcom)
    --
    --             24/08/2016 - Incluir tratamento para autorizações suspensas na procedure
    --                          pc_efetua_debito_automatico (Lucas Ranghetti #499496)
    --             08/09/2016 - Remover condicao temporaria de criacao de protocolo. Agora todos os debitos
    --                          podem ter seu comprovante gerado normalmente, devido ao ajuste na estrutura
    --                          da tabela crapaut. (Anderson #511078)
	--
    --             11/04/2017 - Busca o nome resumido (Ricarod Linhares #547566)
	--
	--             04/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
	--			               (Jonata - RKAM M311).
	--
    --             17/07/2017 - Ajustes para permitir o agendamento de lancamentos da mesma
    --                          conta e referencia no mesmo dia(dtmvtolt) porem com valores
    --                          diferentes (Lucas Ranghetti #684123)
    --------------------------------------------------------------------------------------------------------------------
  BEGIN
  
    DECLARE
      -- VARIAVEIS
      vr_ind          VARCHAR2(100);
      vr_cdcooper     crapcop.cdcooper%TYPE;
      vr_cdagenci     crapage.cdagenci%TYPE;
      vr_nrdolote     craplot.nrdolote%TYPE;
      vr_nrdconta     crapass.nrdconta%TYPE;
      vr_cdbccxlt     craplau.cdbccxlt%TYPE;
      vr_nrdocmto     craplau.nrdocmto%TYPE;
      vr_flagatr      PLS_INTEGER;
      vr_rowid_atr    ROWID;
      vr_dsdmensg     VARCHAR2(4000);
      vr_nmconven     crapcon.nmextcon%TYPE;
      vr_flultexe     INTEGER;
      vr_qtdexec      INTEGER;
      vr_cdrefere     NUMBER;
    
      vr_dsinfor1     crappro.dsinform##1%TYPE;
      vr_dsinfor2     crappro.dsinform##1%TYPE;
      vr_dsinfor3     crappro.dsinform##1%TYPE;
      vr_dsprotoc     crappro.dsprotoc%TYPE;
      vr_nrdolote_sms NUMBER;
    
      -- Autenticação
      vr_dslitera crapaut.dslitera%TYPE;
      vr_nrautdoc crapaut.nrsequen%TYPE;
      vr_nrdrecid     ROWID;
    
      -- Tratamento de erros exceptions
      vr_exc_erro     EXCEPTION;
      vr_exc_saida    EXCEPTION;
    
      -- Tratamento de erros vars
      vr_dscritic     VARCHAR2(4000);
      vr_cdcritic     NUMBER;
      vr_aux_cdcritic NUMBER;
      vr_des_erro     VARCHAR2(4000);
      vr_tab_erro     GENE0001.typ_tab_erro;
    
      vr_tab_sald     EXTR0001.typ_tab_saldos; --> Temp-Table com o saldo do dia
      vr_ind_sald     PLS_INTEGER; --> Indice sobre a temp-table vr_tab_sald
    
      -- CURSORES
    
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      -- Cursor para verificar se lote existe
      CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.nrseqdig
              ,lot.qtcompln
              ,lot.qtinfoln
              ,lot.vlcompdb
              ,lot.nrdolote
              ,lot.cdbccxlt
              ,lot.cdagenci
              ,lot.dtmvtolt
              ,lot.ROWID
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;
    
      -- cursor para retornar lançamentos automáticos
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_nrdconta IN craplau.nrdconta%TYPE
                       ,pr_nrdocmto IN craplau.nrdocmto%TYPE) IS
        SELECT lau.cdcooper
              ,lau.dtmvtolt
              ,lau.cdagenci
              ,lau.cdbccxlt
              ,lau.nrdolote
              ,lau.nrdctabb
              ,lau.nrdocmto
              ,lau.vllanaut
              ,lau.dtmvtopg
              ,lau.nrdconta
              ,lau.cdhistor
              ,lau.nrseqdig
              ,lau.dsorigem
              ,lau.nrcrcard
              ,lau.insitlau
              ,lau.nrseqlan
              ,lau.cdempres
              ,lau.cdseqtel
              ,lau.dscodbar
              ,lau.ROWID
              ,ass.vllimcre
              ,ass.nrctacns
              ,ass.cdagenci cdagenci_ass
              ,ass.dtdemiss
              ,lau.flgblqdb
              ,lau.cdcoptfn
              ,lau.cdagetfn
              ,lau.nrterfin
              ,lau.nrcpfope
              ,lau.nrcpfpre
              ,lau.nmprepos
              ,lau.idseqttl
              ,lau.idlancto
          FROM craplau lau
              ,crapass ass
         WHERE lau.cdcooper = pr_cdcooper
           AND lau.dtmvtopg = pr_dtmvtolt
           AND lau.nrdconta = pr_nrdconta
           AND lau.nrdocmto = pr_nrdocmto
           AND lau.cdhistor = 1019
           AND lau.insitlau = 1
           AND ass.cdcooper = lau.cdcooper
           AND ass.nrdconta = lau.nrdconta
         ORDER BY lau.cdagenci
                 ,lau.cdbccxlt
                 ,lau.cdbccxpg
                 ,lau.cdhistor
                 ,lau.nrdocmto;
      rw_craplau cr_craplau%ROWTYPE;
    
      CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplcm.nrdolote%TYPE
                       ,pr_nrdconta IN craplau.nrdconta%TYPE
                       ,pr_nrdocmto IN craplau.nrdocmto%TYPE) IS
        SELECT lcm.nrseqdig
              ,lcm.nrdolote
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdagenci = pr_cdagenci
           AND lcm.cdbccxlt = pr_cdbccxlt
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.nrdctabb = pr_nrdconta
           AND lcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;
    
      CURSOR cr_crapatr(pr_cdcooper IN crapatr.cdcooper%TYPE
                       ,pr_nrdconta IN crapatr.nrdconta%TYPE
                       ,pr_cdhistor IN crapatr.cdhistor%TYPE
                       ,pr_cdrefere IN crapatr.cdrefere%TYPE) IS
        SELECT atr.dtfimatr
              ,atr.cdrefere
              ,atr.cdhistor
              ,atr.dtultdeb
              ,atr.rowid
              ,atr.flgmaxdb
              ,atr.vlrmaxdb
              ,atr.cdempcon
              ,atr.cdsegmto
              ,atr.dshisext
              ,atr.dtfimsus
          FROM crapatr atr
         WHERE atr.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
           AND atr.nrdconta = pr_nrdconta -- NUMERO DA CONTA
           AND atr.cdhistor = pr_cdhistor -- CODIGO DO HISTORICO
           AND atr.cdrefere = pr_cdrefere; -- COD. REFERENCIA
      rw_crapatr cr_crapatr%ROWTYPE;
    
      -- Buscar Cadastro das autorizacoes de debito em conta pelo rowid
      CURSOR cr_crapatr_rowid(pr_rowid IN ROWID) IS
        SELECT atr.dtfimatr
              ,atr.cdrefere
              ,atr.cdhistor
              ,atr.dtultdeb
              ,atr.rowid
              ,atr.flgmaxdb
              ,atr.vlrmaxdb
              ,atr.cdempcon
              ,atr.cdsegmto
              ,atr.dshisext
              ,atr.dtfimsus
          FROM crapatr atr
         WHERE atr.rowid = pr_rowid;
    
      -- BUSCA HISTORICOS
      CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
      
        SELECT his.cdhistor
              ,his.indebcta
              ,his.inautori
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
           AND his.cdhistor = pr_cdhistor; -- CODIGO DO HISTORICO
      rw_craphis cr_craphis%ROWTYPE;
    
      --Selecionar titulares com senhas ativas
      CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_cdsitsnh IN crapsnh.cdsitsnh%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS
        SELECT crapsnh.nrcpfcgc
              ,crapsnh.cdcooper
              ,crapsnh.nrdconta
              ,crapsnh.idseqttl
          FROM crapsnh
         WHERE crapsnh.cdcooper = pr_cdcooper
           AND crapsnh.nrdconta = pr_nrdconta
           AND crapsnh.cdsitsnh = pr_cdsitsnh
           AND crapsnh.tpdsenha = pr_tpdsenha;
      rw_crapsnh cr_crapsnh%ROWTYPE;
    
      --Selecionar informacoes do titular
      CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                       ,pr_nrdconta IN crapttl.nrdconta%TYPE
                       ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
        SELECT crapttl.nmextttl
              ,crapttl.nrcpfcgc
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;
    
      --Selecionar Informacoes Convenios
      CURSOR cr_crapcon(pr_cdcooper IN crapcon.cdcooper%TYPE
                       ,pr_cdempcon IN crapcon.cdempcon%TYPE
                       ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
        SELECT crapcon.nmextcon
              ,crapcon.nmrescon
          FROM crapcon
         WHERE crapcon.cdcooper = pr_cdcooper
           AND crapcon.cdempcon = pr_cdempcon
           AND crapcon.cdsegmto = pr_cdsegmto;
      rw_crapcon cr_crapcon%ROWTYPE;
    
      CURSOR cr_crapscn (pr_cdempres IN crapscn.cdempres%TYPE) IS
       SELECT scn.dsnomres 
         FROM crapscn scn
        WHERE scn.cdempres = pr_cdempres;
        
       rw_crapscn cr_crapscn%ROWTYPE;
    
      -- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote(pr_cdcooper IN craplot.cdcooper%TYPE
                              ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                              ,pr_cdagenci IN craplot.cdagenci%TYPE
                              ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                              ,pr_nrdolote IN craplot.nrdolote%TYPE
                              ,pr_dscritic OUT VARCHAR2) IS
      
        -- Pragma - abre nova sess?o para tratar a atualizac?o
        PRAGMA AUTONOMOUS_TRANSACTION;
      BEGIN
        -- criar registros de lote na tabela
        INSERT INTO craplot
          (dtmvtolt
          ,cdagenci
          ,cdbccxlt
          ,nrdolote
          ,cdbccxpg
          ,tplotmov
          ,cdcooper)
        VALUES
          (pr_dtmvtolt
          ,pr_cdagenci
          ,pr_cdbccxlt
          ,pr_nrdolote
          ,11 --cdbccxpg
          ,1 --tplotmov
          ,pr_cdcooper)
        RETURNING ROWID,
                  craplot.dtmvtolt,
                  craplot.cdagenci,
                  craplot.cdbccxlt,
                  craplot.nrdolote,
                  craplot.nrseqdig
             INTO rw_craplot.rowid,
                  rw_craplot.dtmvtolt,
                  rw_craplot.cdagenci,
                  rw_craplot.cdbccxlt,
                  rw_craplot.nrdolote,
                  rw_craplot.nrseqdig;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao inserir craplot: ' || SQLERRM;
      END pc_insere_lote;
    
    BEGIN
    
      --Selecionar informacoes das datas
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
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
    
      -- definir savepoint
      SAVEPOINT TRANS1;
    
      --> Verificar a execução da DEBNET/DEBSIC
      SICR0001.pc_controle_exec_deb(pr_cdcooper => pr_cdcooper --> Código da coopertiva
                                   ,pr_cdtipope => 'C' --> Tipo de operacao I-incrementar e C-Consultar
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento
                                   ,pr_cdprogra => pr_cdprogra --> Codigo do programa
                                   ,pr_flultexe => vr_flultexe --> Retorna se é a ultima execução do procedimento
                                   ,pr_qtdexec  => vr_qtdexec --> Retorna a quantidade
                                   ,pr_cdcritic => vr_cdcritic --> Codigo da critica de erro
                                   ,pr_dscritic => vr_dscritic); --> descrição do erro se ocorrer

      IF nvl(vr_cdcritic, 0) > 0
      OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- buscar registros da craplau de debito automatico sicredi
      FOR rw_craplau IN cr_craplau(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdocmto => pr_nrdocmto) LOOP
      
        --cooperativa
        vr_cdcooper := pr_cdcooper;
        -- PA
        vr_cdagenci := rw_craplau.cdagenci;
        -- Lote
        vr_nrdolote := 6400;
        -- Conta cooperado
        vr_nrdconta := rw_craplau.nrdconta;
      
        IF rw_craplau.cdbccxlt = 911 THEN
          vr_cdbccxlt := 11;
        ELSE
          vr_cdbccxlt := rw_craplau.cdbccxlt;
        END IF;
      
        -- Obter valores de saldos diários
        extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_craplau.cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci   => vr_cdagenci,
                                    pr_nrdcaixa   => 1,
                                    pr_cdoperad   => '1',
                                    pr_nrdconta   => rw_craplau.nrdconta,
                                    pr_vllimcre   => rw_craplau.vllimcre,
                                    pr_dtrefere   => pr_dtmvtolt,
                                    pr_tipo_busca => 'A', --> tipo de busca(A-dtmvtoan)
                                    pr_flgcrass   => FALSE,
                                    pr_des_reto   => vr_des_erro,
                                    pr_tab_sald   => vr_tab_sald,
                                    pr_tab_erro   => vr_tab_erro);
        vr_ind_sald := vr_tab_sald.last;
      
        -- se encontrar erro
        IF vr_des_erro = 'NOK' THEN
          -- atualiza temp-table com a critica de erro
          pr_dscritic := 'Nao foi possivel consultar saldo para operacao.';
          -- Volta para o inicio do loop
          CONTINUE;
        END IF;
      
        -- Identificar se conta possui autorizacao de debaut
        pc_identifica_crapatr(pr_cdcooper  => rw_craplau.cdcooper --> Código da coopertiva
                             ,pr_nrdconta  => rw_craplau.nrdconta --> Numero da conta
                             ,pr_nrdocmto  => rw_craplau.nrdocmto --> Documento
                             ,pr_cdhistor  => rw_craplau.cdhistor --> Codigo de historico
                             ,pr_nrcrcard  => rw_craplau.nrcrcard --> Numero do cartao
                             ,pr_cdprogra  => 'SICR0001' --> Código do programa
                             ,pr_flagatr   => vr_flagatr --> Flag se possui atr
                             ,pr_rowid_atr => vr_rowid_atr --> Retorna rowid do registro crapatr localizado
                             ,pr_cdcritic  => vr_cdcritic --> Codigo da critica de erro
                             ,pr_dscritic  => vr_dscritic); --> descrição do erro se ocorrer
      
        rw_crapatr := NULL;
        OPEN cr_crapatr_rowid(pr_rowid => vr_rowid_atr);
        FETCH cr_crapatr_rowid INTO rw_crapatr;
        CLOSE cr_crapatr_rowid;
      
        --> Buscar o nome do convenio
        OPEN cr_crapcon(pr_cdcooper => pr_cdcooper
                       ,pr_cdempcon => rw_crapatr.cdempcon
                       ,pr_cdsegmto => rw_crapatr.cdsegmto);
        --Posicionar no proximo registro
        FETCH cr_crapcon INTO rw_crapcon;
        --Se nao encontrar
        IF cr_crapcon%FOUND THEN
          vr_nmconven := rw_crapcon.nmextcon;
        END IF;
        CLOSE cr_crapcon;
      
       -- Busca o nome resumido
        OPEN cr_crapscn(rw_craplau.cdempres);
        FETCH cr_crapscn INTO rw_crapscn;
        IF cr_crapscn%FOUND THEN
          IF (TRIM(rw_crapscn.dsnomres) IS NOT NULL AND rw_crapscn.dsnomres <> '') THEN  
            vr_nmconven := rw_crapscn.dsnomres;
          END IF;
        END IF;
        CLOSE cr_crapscn;
      
        OPEN cr_craphis(pr_cdcooper => vr_cdcooper -- CODIGO DA COOPERATIVA
                       ,pr_cdhistor => rw_craplau.cdhistor); -- CODIGO DO HISTORICO
        FETCH cr_craphis INTO rw_craphis;
      
        IF cr_craphis%NOTFOUND THEN
          CLOSE cr_craphis;
          vr_cdcritic := 83; -- HISTORICO DESCONHECIDO NO LANCAMENTO
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_craphis;
      
        -- Verificar se historico é de debito autoizado
        IF rw_craphis.inautori = 1 THEN
          --> Verifica se existem registro na crapatr
          IF vr_flagatr = 0 THEN
            vr_cdcritic := 453; -- Autorizacao nao encontrada
          
            -- VERIFICA DATA FIM DA AUTORIZACAO
          ELSIF rw_crapatr.dtfimatr IS NOT NULL
             OR rw_crapatr.dtfimsus >= pr_dtmvtolt THEN
            vr_cdcritic := 447; -- AUTORIZACAO CANCELADA
          END IF;
        END IF;
      
        -- Validar cooperado demitido
        IF rw_craplau.dtdemiss IS NOT NULL THEN
          vr_cdcritic := 64; -- Cooperado demitido
        END IF;
      
        IF vr_cdcritic = 453 THEN
          vr_cdrefere:= rw_craplau.nrdocmto;
        ELSE
          vr_cdrefere:= rw_crapatr.cdrefere;
        END IF;
          
        IF vr_cdcritic > 0 THEN
        
          -- Gerar registros na crapndb para devolucao de debitos automaticos
          CONV0001.pc_gerandb(pr_cdcooper => vr_cdcooper -- CÓDIGO DA COOPERATIVA
                             ,pr_cdhistor => rw_craplau.cdhistor -- CÓDIGO DO HISTÓRICO
                             ,pr_nrdconta => rw_craplau.nrdconta -- NUMERO DA CONTA
                             ,pr_cdrefere => rw_craplau.nrdocmto -- CÓDIGO DE REFERÊNCIA
                             ,pr_vllanaut => rw_craplau.vllanaut -- VALOR LANCAMENTO
                             ,pr_cdseqtel => rw_craplau.cdseqtel -- CÓDIGO SEQUENCIAL
                             ,pr_nrdocmto => vr_cdrefere         -- NÚMERO DO DOCUMENTO
                             ,pr_cdagesic => pr_cdagesic -- AGÊNCIA SICREDI
                             ,pr_nrctacns => rw_craplau.nrctacns -- CONTA DO CONSÓRCIO
                             ,pr_cdagenci => rw_craplau.cdagenci_ass -- CODIGO DO PA
                             ,pr_cdempres => rw_craplau.cdempres -- CODIGO EMPRESA SICREDI
                             ,pr_idlancto => rw_craplau.idlancto -- CÓDIGO DO LANCAMENTO
                             ,pr_codcriti => vr_cdcritic -- CÓDIGO DO ERRO
                             ,pr_cdcritic => vr_aux_cdcritic -- CÓDIGO DO ERRO
                             ,pr_dscritic => vr_dscritic); -- DESCRICAO DO ERRO
        
          -- VERIFICA SE HOUVE ERRO NA PROCEDURE PC_GERANDB
          IF nvl(vr_aux_cdcritic, 0) > 0
          OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdcritic := vr_aux_cdcritic;
            RAISE vr_exc_erro;
          END IF;
        
          IF vr_cdcritic IN (64, 447, 453, 964, 967) THEN
            BEGIN
            
              -- Atualiza registros de lancamentos automaticos
              UPDATE craplau
                 SET craplau.insitlau = 3
                    ,craplau.dtdebito = pr_dtmvtolt
                    ,craplau.cdcritic = NVL(vr_cdcritic, 0)
               WHERE craplau.rowid = rw_craplau.rowid;
            
              -- Verifica se houve problema na atualização do registro
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' ||
                               SQLERRM;
                RAISE vr_exc_erro;
            END;
          
            -- Apos colocar registro como cancelado deve retornar ao programa chamador sem dar rollback
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_saida;
          
          END IF;
        END IF;
      
        --> Validações debaut
        BEGIN
        
          -- Verificar se historico é de debito autoizado
          IF rw_craphis.inautori = 1 THEN
            IF rw_crapatr.flgmaxdb = 1 THEN
              IF rw_craplau.vllanaut > rw_crapatr.vlrmaxdb THEN
                vr_cdcritic := 967; -- Limite ultrapassado.
              END IF;
            END IF;
          END IF;
        
          IF rw_craplau.flgblqdb = 1 THEN
            vr_cdcritic := 964; -- Lancamento bloqueado
          END IF;
        
          --> Se identificou critica
          IF vr_cdcritic > 0 THEN
            -- Se for a primeira tentativa de debito
            IF vr_qtdexec < 3 THEN
            
              IF NOT vr_cdcritic = 964 THEN
                ---> Notificar critica ao cooperado
                pc_notif_cooperado_DEBAUT(pr_cdcritic      => vr_cdcritic,
                                          pr_cdcooper      => pr_cdcooper,
                                          pr_nmrescop      => pr_nmrescop,
                                          pr_cdprogra      => pr_cdprogra,
                                          pr_nrdconta      => rw_craplau.nrdconta,
                                          pr_nrdocmto      => rw_craplau.nrdocmto,
                                          pr_nmconven      => vr_nmconven,
                                          pr_dtmvtopg      => rw_craplau.dtmvtopg,
                                          pr_vllanaut      => rw_craplau.vllanaut,
                                          pr_vlrmaxdb      => rw_crapatr.vlrmaxdb,
                                          pr_cdrefere      => rw_crapatr.cdrefere,
                                          pr_cdhistor      => rw_crapatr.cdhistor,
                                          pr_tpdnotif      => 1 --> Apenas MSG IBank
                                         ,pr_flfechar_lote => 1 -- Fechar
                                         ,pr_idlote_sms    => vr_nrdolote_sms);
              END IF;
            
              BEGIN
                -- ATUALIZA CRITICA VALOR LIMITE EXCEDIDO PARA A DEBCON
                UPDATE craplau
                   SET cdcritic = vr_cdcritic
                 WHERE craplau.rowid = rw_craplau.rowid;
              
                -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar registro na tabela CRAPLAU: ' ||
                                 SQLERRM;
                  RAISE vr_exc_erro;
              END;
            
              --> Se for a ultima tentativa
            ELSIF vr_flultexe = 1 THEN
              -- Gerar registros na crapndb para devolucao de debitos automaticos
              CONV0001.pc_gerandb(pr_cdcooper => vr_cdcooper         -- CÓDIGO DA COOPERATIVA
                                 ,pr_cdhistor => rw_craplau.cdhistor -- CÓDIGO DO HISTÓRICO
                                 ,pr_nrdconta => rw_craplau.nrdconta -- NUMERO DA CONTA
                                 ,pr_cdrefere => rw_craplau.nrdocmto -- CÓDIGO DE REFERÊNCIA
                                 ,pr_vllanaut => rw_craplau.vllanaut -- VALOR LANCAMENTO
                                 ,pr_cdseqtel => rw_craplau.cdseqtel -- CÓDIGO SEQUENCIAL
                                 ,pr_nrdocmto => vr_cdrefere         -- NÚMERO DO DOCUMENTO
                                 ,pr_cdagesic => pr_cdagesic         -- AGÊNCIA SICREDI
                                 ,pr_nrctacns => rw_craplau.nrctacns -- CONTA DO CONSÓRCIO
                                 ,pr_cdagenci => rw_craplau.cdagenci_ass -- CODIGO DO PA
                                 ,pr_cdempres => rw_craplau.cdempres -- CODIGO EMPRESA SICREDI
                                 ,pr_idlancto => rw_craplau.idlancto -- CÓDIGO DO LANCAMENTO
                                 ,pr_codcriti => vr_cdcritic         -- CÓDIGO DO ERRO
                                 ,pr_cdcritic => vr_aux_cdcritic     -- CÓDIGO DO ERRO
                                 ,pr_dscritic => vr_dscritic);       -- DESCRICAO DO ERRO
            
              -- VERIFICA SE HOUVE ERRO NA PROCEDURE PC_GERANDB
              IF nvl(vr_aux_cdcritic, 0) > 0
              OR TRIM(vr_dscritic) IS NOT NULL THEN
                vr_cdcritic := vr_aux_cdcritic;
                RAISE vr_exc_erro;
              END IF;
            
              BEGIN
              
                -- Atualiza registros de lancamentos automaticos
                UPDATE craplau
                   SET craplau.insitlau = 3
                      ,craplau.dtdebito = pr_dtmvtolt
                      ,craplau.cdcritic = NVL(vr_cdcritic, 0)
                 WHERE craplau.rowid = rw_craplau.rowid;
              
                -- Verifica se houve problema na atualização do registro
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' ||
                                 SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
          
            -- Apos colocar registro como cancelado deve retornar ao programa chamador sem dar rollback
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_saida;
          
          END IF;
        END;
      
        vr_ind_sald := vr_tab_sald.last;
        -- Se o saldo disponível for menor do que o Débito a ser lançado
        IF rw_craplau.vllanaut >
           (vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vllimcre) THEN
        
          -- Se for a primeira tentativa do dia, apenas incluir a mensagem para o cooperado
		      IF vr_qtdexec < 3 THEN
          
            ---> Notificar critica ao cooperado
            pc_notif_cooperado_DEBAUT( pr_cdcritic  => 717 -- Nao ha saldo suficiente para a operacao
                                      ,pr_cdcooper  => pr_cdcooper 
                                      ,pr_nmrescop  => pr_nmrescop
                                      ,pr_cdprogra  => pr_cdprogra
                                      ,pr_nrdconta  => rw_craplau.nrdconta
                                      ,pr_nrdocmto  => rw_craplau.nrdocmto
                                      ,pr_nmconven  => vr_nmconven
                                      ,pr_dtmvtopg  => rw_craplau.dtmvtopg
                                      ,pr_vllanaut  => rw_craplau.vllanaut
                                      ,pr_vlrmaxdb  => rw_crapatr.vlrmaxdb
                                      ,pr_cdrefere  => rw_crapatr.cdrefere
                                      ,pr_cdhistor  => rw_crapatr.cdhistor
                                      ,pr_flfechar_lote => 1 -- Fechar
                                      ,pr_idlote_sms   => vr_nrdolote_sms);

            BEGIN
              -- Atualiza registros de lancamentos automaticos
              UPDATE craplau
                 SET craplau.cdcritic = 717
               WHERE craplau.rowid = rw_craplau.rowid;
            
              -- Verifica se houve problema na atualização do registro
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' ||
                               SQLERRM;
                RAISE vr_exc_erro;
            END;
          
            /* Se for a ultima tentativa */
          ELSIF vr_flultexe = 1 THEN
            sicr0001.pc_gera_crapndb(pr_cdcooper => rw_craplau.cdcooper,
                                     pr_dtmvtolt => pr_dtmvtolt,
                                     pr_nrdconta => rw_craplau.nrdconta,
                                     pr_cdempres => rw_craplau.cdempres,
                                     pr_nrdocmto => vr_cdrefere,
                                     pr_nrctacns => rw_craplau.nrctacns,
                                     pr_vllanaut => rw_craplau.vllanaut,
                                     pr_cdagenci => vr_cdagenci,
                                     pr_cdseqtel => rw_craplau.cdseqtel,
                                     pr_cdcritic => pr_cdcritic,
                                     pr_dscritic => pr_dscritic);
          
            -- Atualiza registro de Lançamento Automático
            BEGIN
              UPDATE craplau
                 SET insitlau = 3
                    ,dtdebito = pr_dtmvtolt
               WHERE ROWID = rw_craplau.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar craplau: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          
          END IF;
        
          vr_cdcritic := 717; -- Nao ha saldo suficiente para a operacao
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          -- VOLTA PARA O programa chamador sem rollback
          RAISE vr_exc_saida;
        END IF;
      
        -- Buscar lote
        OPEN cr_craplot(pr_cdcooper => rw_craplau.cdcooper,
                        pr_dtmvtolt => pr_dtmvtolt,
                        pr_cdagenci => vr_cdagenci,
                        pr_cdbccxlt => vr_cdbccxlt,
                        pr_nrdolote => vr_nrdolote);
        FETCH cr_craplot INTO rw_craplot;
      
        -- Verificar se lote existe
        IF cr_craplot%NOTFOUND THEN
          -- inserir lote
          pc_insere_lote(pr_cdcooper => rw_craplau.cdcooper,
                         pr_dtmvtolt => pr_dtmvtolt,
                         pr_cdagenci => vr_cdagenci,
                         pr_cdbccxlt => vr_cdbccxlt,
                         pr_nrdolote => vr_nrdolote,
                         pr_dscritic => vr_dscritic);
          -- Verificar se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          rw_craplot.nrseqdig := 0;
        END IF;
        -- Fechar cursor de lote
        CLOSE cr_craplot;

        vr_nrdocmto := rw_craplau.nrdocmto;

        -- alimenta indice da temp-table
        vr_ind_sald := vr_tab_sald.last;

        -- Se o saldo disponível for menor do que o Débito a ser lançado
        IF rw_craplau.vllanaut >
           (vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vllimcre) THEN
        
          /* Se for a ultima tentativa de processamento (ou seja, segundo processamento/DEBSIC) */
          IF vr_flultexe = 2 THEN
            sicr0001.pc_gera_crapndb(pr_cdcooper => rw_craplau.cdcooper,
                                     pr_dtmvtolt => pr_dtmvtolt,
                                     pr_nrdconta => rw_craplau.nrdconta,
                                     pr_cdempres => rw_craplau.cdempres,
                                     pr_nrdocmto => vr_cdrefere,
                                     pr_nrctacns => rw_craplau.nrctacns,
                                     pr_vllanaut => rw_craplau.vllanaut,
                                     pr_cdagenci => vr_cdagenci,
                                     pr_cdseqtel => rw_craplau.cdseqtel,
                                     pr_cdcritic => pr_cdcritic,
                                     pr_dscritic => pr_dscritic);
          
            -- atualiza temp-table com a critica de erro
            pr_dscritic := 'Nao ha saldo suficiente para a operacao.';
          
            -- Atualiza registro de Lançamento Automático
            BEGIN
              UPDATE craplau
                 SET insitlau = 3
                    ,dtdebito = pr_dtmvtolt
               WHERE ROWID = rw_craplau.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar craplau: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          
          END IF;
        
          -- VOLTA PARA O INICIO DO LOOP
          CONTINUE;
        ELSE
          -- verificar existencia de lançamento
          OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_cdbccxlt => vr_cdbccxlt
                          ,pr_nrdolote => vr_nrdolote
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrdocmto => vr_nrdocmto);
          FETCH cr_craplcm INTO rw_craplcm;
        
          IF cr_craplcm%FOUND THEN
            -- Fechar cursor de lançamento
            CLOSE cr_craplcm;
          
            CONTINUE;
          END IF;
        
          -- Fechar cursor de lançamento
          CLOSE cr_craplcm;
        
          ---> Gerar autenticação do pagamento
          CXON0000.pc_grava_autenticacao_internet 
                            (pr_cooper       => rw_craplau.cdcooper
                            ,pr_nrdconta     => rw_craplau.nrdconta
                            ,pr_idseqttl     => rw_craplau.idseqttl  --Sequencial do titular
                            ,pr_cod_agencia  => rw_craplau.cdagenci  --Codigo Agencia
                            ,pr_nro_caixa    => 900                  --Numero do caixa
                            ,pr_cod_operador => 996                  --Codigo Operador

                            ,pr_valor        => rw_craplau.vllanaut  --Valor da transacao
                            ,pr_docto        => vr_nrdocmto          --Numero documento
                            ,pr_operacao     => TRUE                 --Indicador Operacao Debito
                            ,pr_status       => '1'                  --Status da Operacao - Online
                            ,pr_estorno      => FALSE                --Indicador Estorno
                            ,pr_histor       => rw_craplau.cdhistor  --Historico Debito (Sicredi é 1019 pode passar fixo)

                            ,pr_data_off     => NULL            --Data Transacao
                            ,pr_sequen_off   => 0               --Sequencia
                            ,pr_hora_off     => 0               --Hora transacao
                            ,pr_seq_aut_off  => 0               --Sequencia automatica
                            ,pr_cdempres     => NULL            --Descricao Observacao

                            ,pr_literal      => vr_dslitera     --Descricao literal lcm
                            ,pr_sequencia    => vr_nrautdoc     --Sequencia
                            ,pr_registro     => vr_nrdrecid     --ROWID do registro debito
                            ,pr_cdcritic     => vr_cdcritic     --Código do erro
                            ,pr_dscritic     => vr_dscritic);   --Descricao do erro

          --Se ocorreu erro
          IF NVL(vr_cdcritic, 0) <> 0
             OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro na autenticacao do pagamento: ' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        
          -- Atualiza o sequencial da capa do lote
          rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig, 0) + 1;
        
          -- cria registro na tabela de lançamentos
          BEGIN
            INSERT INTO craplcm
              (cdcooper
              ,dtmvtolt
              ,cdagenci
              ,cdbccxlt
              ,nrdolote
              ,nrdctabb
              ,nrdocmto
              ,vllanmto
              ,nrdconta
              ,cdhistor
              ,nrseqdig
              ,nrdctitg
              ,nrautdoc
              ,cdpesqbb)
            VALUES
              (rw_craplau.cdcooper
              ,rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,rw_craplau.nrdctabb
              ,vr_nrdocmto
              ,rw_craplau.vllanaut
              ,vr_nrdconta
              ,rw_craplau.cdhistor
              ,rw_craplot.nrseqdig + 1
              ,rw_craplau.nrdctabb
              ,vr_nrautdoc
              ,'Lote ' || to_char(rw_craplau.dtmvtolt, 'dd')              || '/' ||
                          to_char(rw_craplau.dtmvtolt, 'mm')              || '-' ||
                          GENE0002.fn_mask(vr_cdagenci, '999')            || '-' ||
                          GENE0002.fn_mask(rw_craplau.cdbccxlt, '999')    || '-' ||
                          GENE0002.fn_mask(rw_craplau.nrdolote, '999999') || '-' ||
                          GENE0002.fn_mask(rw_craplau.nrseqdig, '99999')  || '-' ||
                          vr_cdrefere);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir craplcm: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        
          -- Atualiza a capa do lote
          BEGIN
            UPDATE craplot
               SET nrseqdig = rw_craplot.nrseqdig
                  ,qtcompln = qtcompln + 1
                  ,qtinfoln = qtinfoln + 1
                  ,vlcompdb = vlcompdb + rw_craplau.vllanaut
                  ,vlinfodb = vlcompdb + rw_craplau.vllanaut
             WHERE ROWID = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar craplot: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        
          -- Atualiza registro de Lançamento Automático
          BEGIN
            UPDATE craplau
               SET insitlau = 2
                  ,nrseqlan = rw_craplau.nrseqdig
                  ,dtdebito = pr_dtmvtolt
             WHERE ROWID = rw_craplau.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar craplau: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        
          -- GERAR PROTOCOLO
          -->Campos gravados na crappro para visualizacao na internet
          vr_dsinfor1 := 'Pagamento';
          vr_dsinfor2 := ' ';
          vr_dsinfor3 := 'Convênio: ' || rw_crapcon.nmextcon || '#Número Identificador:' ||
                         rw_crapatr.cdrefere || '#' || rw_crapatr.dshisext;
        
          --> Se TAA
          IF rw_craplau.dsorigem = 'TAA' THEN
            vr_dsinfor3 := vr_dsinfor3 || '#TAA: ' ||
                           gene0002.fn_mask(rw_craplau.cdcoptfn, '9999') || '/' ||
                           gene0002.fn_mask(rw_craplau.cdagetfn, '9999') || '/' ||
                           gene0002.fn_mask(rw_craplau.nrterfin, '9999');
          END IF;
          --> Gera um protocolo para o pagamento
          GENE0006.pc_gera_protocolo(pr_cdcooper => rw_craplau.cdcooper  --> Código da cooperativa
                                        ,pr_dtmvtolt => rw_craplot.dtmvtolt  --> Data movimento
                                        ,pr_hrtransa => gene0002.fn_busca_time --> Hora da transação
                                        ,pr_nrdconta => rw_craplau.nrdconta  --> Número da conta
                                        ,pr_nrdocmto => vr_nrdocmto          --> Número do documento
                                        ,pr_nrseqaut => vr_nrautdoc          --> Número da sequencia
                                        ,pr_vllanmto => rw_craplau.vllanaut  --> Valor lançamento
                                        ,pr_nrdcaixa => 900                  --> Número do caixa
                                        ,pr_gravapro => TRUE                 --> Controle de gravação do crappro
                                        ,pr_cdtippro => 15 -- convenio       --> Código do tipo protocolo
                                        ,pr_dsinfor1 => vr_dsinfor1          --> Descrição 1
                                        ,pr_dsinfor2 => vr_dsinfor2          --> Descrição 2
                                        ,pr_dsinfor3 => vr_dsinfor3          --> Descrição 3
                                        ,pr_dscedent => rw_crapcon.nmextcon  --> Descritivo Cedente
                                        ,pr_flgagend => FALSE                --> Controle de agenda
                                        ,pr_nrcpfope => rw_craplau.nrcpfope  --> Número de operação
                                        ,pr_nrcpfpre => rw_craplau.nrcpfpre  --> Número pré operação
                                        ,pr_nmprepos => rw_craplau.nmprepos  --> Nome
                                        ,pr_dsprotoc => vr_dsprotoc          --> Descrição do protocolo
                                        ,pr_dscritic => vr_dscritic          --> Descrição crítica
                                        ,pr_des_erro => vr_des_erro);        --> Descrição dos erros de processo
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL
          OR vr_des_erro IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        
          --> Armazena protocolo na autenticacao
          BEGIN
            UPDATE crapaut
               SET crapaut.dsprotoc = vr_dsprotoc
             WHERE crapaut.ROWID = vr_nrdrecid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro da autenticacao. ' || SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        
          -- Atualiza data do último débito da autorização
          OPEN cr_crapatr(pr_cdcooper => rw_craplau.cdcooper,
                          pr_nrdconta => rw_craplau.nrdconta,
                          pr_cdhistor => rw_craplau.cdhistor,
                          pr_cdrefere => vr_cdrefere);
          FETCH cr_crapatr INTO rw_crapatr;
        
          IF cr_crapatr%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_crapatr;
            -- retorna erro para procedure chamadora
            pr_dscritic := 'Autorizacao de debito nao encontrada.';
            -- Volta para o inicio do loop
            CONTINUE;
          ELSE
            -- FECHAR O CURSOR
            CLOSE cr_crapatr;
          
            -- VERIFICA DATA DO ULTIMO DEBITO
            IF NVL(to_char(rw_crapatr.dtultdeb, 'MMYYYY'), '0') <>
               to_char(pr_dtmvtolt, 'MMYYYY') THEN
              BEGIN
                -- ATUALIZA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
                UPDATE crapatr
                   SET dtultdeb = pr_dtmvtolt -- ATUALIZA DATA DO ULTIMO DEBITO
                 WHERE ROWID = rw_crapatr.rowid;
                -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao atualizar registro na tabela CRAPATR: ' ||
                                 SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF;
        
        END IF;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Exception para sair do programa com a critica mas sem dar rollback
        -- retorna erro tratado
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN vr_exc_erro THEN
      
        ROLLBACK TO TRANS1;
        -- retorna erro tratado
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        ROLLBACK TO TRANS1;
        -- Retorna o erro n?o tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado em sicr0001.pc_efetua_debito_automatico --> ' ||
                       SQLERRM;
    END;
  
  END pc_efetua_debito_automatico;

  /* Procedimento para criar registros na crapndb */
  PROCEDURE pc_gera_crapndb( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                            ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE        --> Numero da conta
                            ,pr_cdempres  IN craplau.cdempres%TYPE        --> Código da empresa
                            ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE        --> Documento
                            ,pr_nrctacns  IN crapass.nrctacns%TYPE        --> Conta consórcio
                            ,pr_vllanaut  IN craplau.vllanaut%TYPE        --> Valor do lancemento
                            ,pr_cdagenci  IN crapass.cdagenci%TYPE        --> Agencia do cooperado PA
              ,pr_cdseqtel  IN craplau.cdseqtel%TYPE        --> Sequencial
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                            ,pr_dscritic OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_pc_gera_crapndb
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Lucas Ranghetti
  --   Data    : Maio/2014                       Ultima atualizacao: 21/11/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Gerar informações na crapndb
  --
  --  Alterações: 21/11/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 11 
  --                           posicoes, devemos incluir um hifen para completar 12 posicoes 
  --                           ex: 40151016407- (Lucas Ranghetti #560620/453337)
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
      vr_dscritic VARCHAR2(4000);

      -- VARIAVEIS DE EXCECAO
      vr_exc_erro EXCEPTION;
      vr_exc_saida EXCEPTION;

    -- CURSORES
    -- Busca dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.cdagesic
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

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
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- gravar agencia do sicredi na cooperativa em variavel
        vr_nrctasic := gene0002.fn_mask(rw_crapcop.cdagesic,'9999');
        CLOSE cr_crapcop;
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

      vr_cdagenci :=  SUBSTR(gene0002.fn_mask(pr_cdagenci,'999'),2,2);

      vr_dstexarq := 'F' || vr_resultado ||
                         gene0002.fn_mask(vr_nrctasic,'9999') ||
                         gene0002.fn_mask(pr_nrctacns,'999999') ||
                         gene0002.fn_mask('','zzzzzzzz') ||
                         TO_CHAR(pr_dtmvtolt,'yyyy') ||
                         TO_CHAR(pr_dtmvtolt,'mm') ||
                         TO_CHAR(pr_dtmvtolt,'dd') ||
                         LPAD((pr_vllanaut*100),15,'0') ||
                         '01' ||
                         LPAD(pr_cdseqtel,60, ' ') ||
                         RPAD(' ',16) ||
                         gene0002.fn_mask(vr_cdagenci,'99') ||
                         RPAD(TRIM(rw_crapscn.cdempres),10,' ') || '0';

        BEGIN
          -- INSERE REGISTRO NA TABELA DE REGISTROS DE DEBITO EM CONTA NAO EFETUADOS
          INSERT INTO
            crapndb(
              dtmvtolt,
              nrdconta,
              cdhistor,
              flgproce,
              cdcooper,
              dstexarq
            )VALUES(
              pr_dtmvtolt,
              pr_nrdconta,
              1019,
              0, -- 0 false
              pr_cdcooper,
              vr_dstexarq
            );
        -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPNDB: ' || sqlerrm;
            RAISE vr_exc_erro;
        END;

    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Retorna o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado em sicr0001.pc_gera_crapndb --> '||SQLERRM;

    END;

  END pc_gera_crapndb;


  /* Procedure para obter agendamento debitos */
  PROCEDURE pc_SICR0001_obtem_agen_deb (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                       ,pr_nmrescop  IN crapcop.nmrescop%TYPE --> Nome resumido da cooperativa
                                       ,pr_dtmvtopg  IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                       ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador processo
                                       ,pr_clobxmlc OUT CLOB                  --> XML com informações dos agendamentos
                                       ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ..........................................................................
    --  Programa : pc_SICR0001_obtem_agen_deb
    --  Sistema  : Rotinas Internet
    --  Sigla    : CRED
    --  Autor    : Douglas Quisinski
    --  Data     : Outubro/2015                  Ultima atualizacao:   /  /
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Chamar a procedure pc_obtem_agendamentos_debito pelo Progress
    --
    --  Alteracoes:
    -----------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Indice dos agendamentos
      vr_index    VARCHAR2(300);

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

      -- Temp table para agendamentos
      vr_tab_agendto typ_tab_agendamentos;
    BEGIN

      -- Carregar as informações dos agendamentos da cooperativa
      SICR0001.pc_obtem_agendamentos_debito(pr_cdcooper => pr_cdcooper
                                           ,pr_nmrescop => pr_nmrescop
                                           ,pr_dtmvtopg => pr_dtmvtopg
                                           ,pr_inproces => pr_inproces
                                           ,pr_tab_agendamentos => vr_tab_agendto
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc,
                              pr_texto_completo => vr_xml_temp,
                              pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

      IF vr_tab_agendto.count() > 0 THEN
        -- Buscar o primeiro indice
        vr_index:= vr_tab_agendto.FIRST;
        -- Percorre todas os agendamento que foram encontrados para a cooperativa
        WHILE vr_index IS NOT NULL LOOP
          -- Montar XML com registros de agendamento
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc,
                                  pr_texto_completo => vr_xml_temp,
                                  pr_texto_novo     => '<agendamento>' ||
                                                       '   <nrchave>'  || NVL(vr_tab_agendto(vr_index).nrchave,' ') || '</nrchave>' ||
                                                       '   <cdcooper>' || NVL(vr_tab_agendto(vr_index).cdcooper,0) || '</cdcooper>' ||
                                                       '   <dscooper>' || NVL(vr_tab_agendto(vr_index).dscooper,' ') || '</dscooper>' ||
                                                       '   <cdagenci>' || NVL(vr_tab_agendto(vr_index).cdagenci,0) || '</cdagenci>' ||
                                                       '   <nrdconta>' || NVL(vr_tab_agendto(vr_index).nrdconta,0) || '</nrdconta>' ||
                                                       '   <nmprimtl>' || NVL(vr_tab_agendto(vr_index).nmprimtl,' ') || '</nmprimtl>' ||
                                                       '   <cdtiptra>' || NVL(vr_tab_agendto(vr_index).cdtiptra,0) ||'</cdtiptra>' ||
                                                       '   <fltiptra>' || CASE WHEN vr_tab_agendto(vr_index).fltiptra THEN '1' ELSE '0' END || '</fltiptra>' ||
                                                       '   <dstiptra>' || NVL(vr_tab_agendto(vr_index).dstiptra,' ') || '</dstiptra>' ||
                                                       '   <fltipdoc>' || NVL(vr_tab_agendto(vr_index).fltipdoc,' ') || '</fltipdoc>' ||
                                                       '   <dstransa>' || NVL(vr_tab_agendto(vr_index).dstransa,' ') || '</dstransa>' ||
                                                       '   <vllanaut>' || NVL(vr_tab_agendto(vr_index).vllanaut,'0,00') || '</vllanaut>' ||
                                                       '   <dttransa>' || NVL(to_char(vr_tab_agendto(vr_index).dttransa,'dd/mm/RRRR'),' ') || '</dttransa>' ||
                                                       '   <hrtransa>' || NVL(vr_tab_agendto(vr_index).hrtransa,' ') || '</hrtransa>' ||
                                                       '   <nrdocmto>' || NVL(vr_tab_agendto(vr_index).nrdocmto,0) || '</nrdocmto>' ||
                                                       '   <dslindig>' || NVL(vr_tab_agendto(vr_index).dslindig,' ') || '</dslindig>' ||
                                                       '   <dscritic>' || NVL(vr_tab_agendto(vr_index).dscritic,' ') || '</dscritic>' ||
                                                       '   <fldebito>' || NVL(vr_tab_agendto(vr_index).fldebito,0) || '</fldebito>' ||
                                                       '   <dsorigem>' || NVL(vr_tab_agendto(vr_index).dsorigem,' ') || '</dsorigem>' ||
                                                       '   <idseqttl>' || NVL(vr_tab_agendto(vr_index).idseqttl,0) || '</idseqttl>' ||
                                                       '   <prorecid>' || NVL(vr_tab_agendto(vr_index).prorecid,0) || '</prorecid>' ||
                                                       '   <nrdrecid>' || NVL(vr_tab_agendto(vr_index).nrdrecid,' ') || '</nrdrecid>' ||
                                                       '   <dtagenda>' || NVL(to_char(vr_tab_agendto(vr_index).dtagenda,'dd/mm/RRRR'),' ') || '</dtagenda>' ||
                                                       '   <dsdebito>' || NVL(vr_tab_agendto(vr_index).dsdebito,' ') || '</dsdebito>' ||
                                                       '</agendamento>');

          --buscar proximo registro
          vr_index:= vr_tab_agendto.next(vr_index);
        END LOOP;
      END IF;
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc,
                              pr_texto_completo => vr_xml_temp,
                              pr_texto_novo     => '</raiz>',
                              pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina SICR0001.pc_SICR0001_obtem_agen_deb. ' || SQLERRM;
    END;

  END pc_SICR0001_obtem_agen_deb;

  /* Procedure para efetuar debitos de agendamentos */
  PROCEDURE pc_SICR0001_efetua_debitos (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                       ,pr_dtmvtopg  IN crapdat.dtmvtolt%TYPE --> Data Pagamento
                                       ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador processo
                                       ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo programa
                                       ,pr_flsgproc  IN INTEGER               --> Flag segundo processamento
                                       ,pr_nmrelato OUT VARCHAR2              --> Nome do relatorio gerado
                                       ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ..........................................................................
    --  Programa : pc_SICR0001_efetua_debitos
    --  Sistema  : Rotinas Internet
    --  Sigla    : CRED
    --  Autor    : Douglas Quisinski
    --  Data     : Outubro/2015                  Ultima atualizacao: 28/12/2015
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Chamar a procedure pc_efetua_debitos pelo Progress
    --
    --  Alteracoes: 28/12/2015 - Incluido controle de execução da DEBSIC para incrementar
    --                           a contagem da tentativa de execução (Odirlei-AMcom)
    --
    -- ..........................................................................
  BEGIN
    DECLARE
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_flsgproc BOOLEAN;
      vr_flultexe INTEGER;
      vr_qtdexec  INTEGER;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp table para agendamentos
      vr_tab_agendto typ_tab_agendamentos;

      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    BEGIN
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Carregar as informações dos agendamentos da cooperativa
      SICR0001.pc_obtem_agendamentos_debito(pr_cdcooper => pr_cdcooper
                                           ,pr_nmrescop => rw_crapcop.nmrescop
                                           ,pr_dtmvtopg => pr_dtmvtopg
                                           ,pr_inproces => pr_inproces
                                           ,pr_tab_agendamentos => vr_tab_agendto
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      --> Verificar/controlar a execução da DEBNET e DEBSIC
      pc_controle_exec_deb ( pr_cdcooper  => pr_cdcooper                 --> Código da coopertiva
                            ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento
                            ,pr_cdprogra  => 'DEBSIC'                    --> Codigo do programa
                            ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                            ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                            ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                            ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_agendto.count() > 0 THEN
        IF pr_flsgproc = 1 THEN
          vr_flsgproc:= TRUE;
        ELSE
          vr_flsgproc:= FALSE;
        END IF;

        -- Chama procedure para efetuar os débitos
        SICR0001.pc_efetua_debitos(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtopg => pr_dtmvtopg
                                  ,pr_inproces => pr_inproces
                                  ,pr_cdprogra => pr_cdprogra
                                  ,pr_flsgproc => vr_flsgproc
                                  ,pr_tab_agendamentos => vr_tab_agendto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        -- Se retornou alguma critica
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Chama procedure para efetuar os débitos
        SICR0001.pc_gera_relatorio(pr_cdcooper  => pr_cdcooper
                                  ,pr_cdprogra  => pr_cdprogra
                                  ,pr_inproces  => pr_inproces
                                  ,pr_dtmvtolt  => pr_dtmvtopg
                                  ,pr_tab_agend => vr_tab_agendto
                                  ,pr_nmrelato  => pr_nmrelato
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);

        -- Se retornou alguma critica
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

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
        pr_dscritic := 'Erro na rotina SICR0001.pc_SICR0001_efetua_debitos. ' || sqlerrm;
    END;
  END pc_SICR0001_efetua_debitos;

  /* Procedimento para identificar se cooperado possui debito autorizado */
  PROCEDURE pc_identifica_crapatr( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        --> Numero da conta
                                  ,pr_nrdocmto  IN craplau.nrdocmto%TYPE        --> Documento
                                  ,pr_cdhistor  IN craplau.cdhistor%TYPE        --> Codigo de historico
                                  ,pr_nrcrcard  IN craplau.nrcrcard%TYPE        --> Numero do cartao
                                  ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Código do programa
                                  ,pr_flagatr  OUT PLS_INTEGER                  --> Flag se possui atr
                                  ,pr_rowid_atr OUT ROWID                       --> Retorna rowid do registro crapatr localizado
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                  ,pr_dscritic OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_identifica_crapatr
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Odirlei Busana - AMcom
  --   Data    : Novembro/2015                       Ultima atualizacao: 17/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Procedimento para identificar se cooperado possui debito autorizado
  --
  --  Alteracoes: 19/01/2017 - Incluir validacao em casos que a DEBNET chamar (Lucas Ranghetti #533520)
  --
  --             17/07/2017 - Ajustes para permitir o agendamento de lancamentos da mesma
  --                          conta e referencia no mesmo dia(dtmvtolt) porem com valores
  --                          diferentes (Lucas Ranghetti #684123)
  --------------------------------------------------------------------------------------------------------------------*/
    -------------> CURSOR <--------------
    -- BUSCA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
    CURSOR cr_crapatr(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE,
                      pr_cdhistor IN craphis.cdhistor%TYPE,
                      pr_nrcrcard IN craplau.nrcrcard%TYPE) IS

      SELECT atr.dtfimatr
            ,atr.cdrefere
            ,atr.dtultdeb
            ,atr.rowid
            ,atr.flgmaxdb
            ,atr.vlrmaxdb
        FROM crapatr atr
       WHERE atr.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND atr.nrdconta = pr_nrdconta  -- NUMERO DA CONTA
         AND atr.cdhistor = pr_cdhistor  -- CODIGO DO HISTORICO
         AND atr.cdrefere = pr_nrcrcard; -- COD. REFERENCIA

    rw_crapatr cr_crapatr%ROWTYPE;


    ------------> VARIAVEIS <---------------
    vr_flagatr   PLS_INTEGER;
    vr_nrdocmto  craplau.nrdocmto%TYPE;

  BEGIN
    -- VERIFICA CODIGO DO HISTORICO
    IF pr_cdhistor IN (31,288,834) THEN

      vr_flagatr := 0;
      OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdhistor => pr_cdhistor,
                      pr_nrcrcard => pr_nrcrcard);

      FETCH cr_crapatr INTO rw_crapatr;
      IF cr_crapatr%NOTFOUND THEN
        CLOSE cr_crapatr;
        -- FLAG PARA REGISTROS DA CRAPATR NAO ENCONTRADO
        vr_flagatr := 0;
      ELSE
        CLOSE cr_crapatr;
        -- FLAG PARA REGISTROS DA CRAPATR ENCONTRADO
        vr_flagatr := 1;
      END IF;

    -- Tratamento Liberty / Unimed para lancamentos duplicados
    ELSIF pr_cdhistor IN (509,993)THEN

      -- NUMERO DO DOCUMENTO
      vr_nrdocmto := pr_nrdocmto;

      LOOP
        -- VERIFICA NUMERO DO DOCUMENTO
        IF vr_nrdocmto < 100000 THEN
          -- SAI DO LOOP
          EXIT;
        END IF;

        -- BUSCA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
        OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,         -- CODIGO DA COOPERATIVA
                        pr_nrdconta => pr_nrdconta,         -- NUMERO DA CONTA
                        pr_cdhistor => pr_cdhistor, -- CODIGO DO HISTORICO
                        pr_nrcrcard => vr_nrdocmto);        -- COD. REFERENCIA

        FETCH cr_crapatr INTO rw_crapatr;

        IF cr_crapatr%NOTFOUND THEN
          CLOSE cr_crapatr;

          -- FLAG DE CONTROLE PARA REGISTROS DA TABELA CRAPATR
          vr_flagatr  := 0;
          -- SE NAO ENCONTROU DOCUMENTO EFETUA DIVISAO E FAZ NOVAMENTE A PESQUISA
          vr_nrdocmto := (vr_nrdocmto / 10);
          -- PROXIMO REGISTRO
          CONTINUE;
        ELSE
          CLOSE cr_crapatr;
          -- FLAG DE CONTROLE PARA REGISTROS DA TABELA CRAPATR
          vr_flagatr := 1;
          -- SAI DO LOOP
          EXIT;
        END IF;

      END LOOP; -- FIM DO LOOP
    ELSIF pr_cdprogra IN( 'PAGA0001', 'SICR0001') THEN
      
      vr_flagatr := 0;
      OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdhistor => pr_cdhistor,
                      pr_nrcrcard => pr_nrcrcard);

      FETCH cr_crapatr INTO rw_crapatr;
      
      IF cr_crapatr%NOTFOUND THEN
        CLOSE cr_crapatr;
        
        OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_cdhistor => pr_cdhistor,
                        pr_nrcrcard => pr_nrdocmto);

        FETCH cr_crapatr INTO rw_crapatr;
          
        IF cr_crapatr%NOTFOUND THEN
          CLOSE cr_crapatr;
          -- FLAG PARA REGISTROS DA CRAPATR NAO ENCONTRADO
          vr_flagatr := 0;
        ELSE
          CLOSE cr_crapatr;
          -- FLAG PARA REGISTROS DA CRAPATR ENCONTRADO
          vr_flagatr := 1;
        END IF;  
      ELSE
        CLOSE cr_crapatr;
        -- FLAG PARA REGISTROS DA CRAPATR ENCONTRADO
        vr_flagatr := 1;
      END IF;   
    ELSE
      -- BUSCA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
      OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdhistor => pr_cdhistor,
                      pr_nrcrcard => pr_nrdocmto);

      FETCH cr_crapatr INTO rw_crapatr;
      IF cr_crapatr%NOTFOUND THEN
        CLOSE cr_crapatr;
        -- FLAG DE CONTROLE PARA REGISTROS DA TABELA CRAPATR
        vr_flagatr := 0;
      ELSE
        -- FECHAR O CURSOR
        CLOSE cr_crapatr;
         -- FLAG DE CONTROLE PARA REGISTROS DA TABELA CRAPATR
        vr_flagatr := 1;
      END IF;
    END IF;

    -- Retornar informacoes
    pr_flagatr := vr_flagatr;
    IF vr_flagatr = 1 THEN
      pr_rowid_atr := rw_crapatr.rowid;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na SICR0001.pc_identifica_atr: '||SQLERRM;
  END pc_identifica_crapatr;

  /* Procedimento para verificar/controlar a execução da DEBNET e DEBSIC */
  PROCEDURE pc_controle_exec_deb ( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                  ,pr_cdtipope  IN VARCHAR2                     --> Tipo de operacao I-incrementar, C-Consultar e V-Validar
                                  ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                                  ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Codigo do programa
                                  ,pr_flultexe OUT INTEGER                      --> Retorna se é a ultima execução do procedimento
                                  ,pr_qtdexec  OUT INTEGER                      --> Retorna a quantidade
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                  ,pr_dscritic OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_controle_exec_deb
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Odirlei Busana - AMcom
  --   Data    : Novembro/2015                       Ultima atualizacao: 17/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Procedimento para verificar/controlar a execução da DEBNET e DEBSIC
  --
  --  Alteracoes:
  --
  --------------------------------------------------------------------------------------------------------------------*/
    -------------> CURSOR <--------------
    CURSOR cr_crapprm (pr_cdcooper crapprm.cdcooper%TYPE,
                       pr_cdacesso crapprm.cdacesso%TYPE) IS
      SELECT prm.dsvlrprm,
             prm.cdacesso,
             prm.rowid
        FROM crapprm prm
       WHERE prm.nmsistem = 'CRED'
         AND prm.cdcooper IN (pr_cdcooper,0)
         AND prm.cdacesso = pr_cdacesso
       ORDER BY prm.cdcooper DESC;
    rw_crapprm_ctrl cr_crapprm%ROWTYPE;
    rw_crapprm_qtd  cr_crapprm%ROWTYPE;

    ------------- Variaveis ---------------
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(1000);

    vr_cdprogra  crapprg.cdprogra%TYPE;
    vr_tbdados   gene0002.typ_split;
    vr_dtctlexc  DATE   := NULL;
    vr_qtctlexc  INTEGER := 0;
    vr_qtdexec   INTEGER := 0;


  BEGIN

    IF upper(pr_cdprogra) = 'CRPS642' THEN
      vr_cdprogra := 'DEBSIC';
    ELSIF upper(pr_cdprogra) = 'CRPS509' THEN
      vr_cdprogra := 'DEBNET';
    ELSE
      vr_cdprogra := pr_cdprogra;
    END IF;


    --> buscar parametro de controle de execução
    OPEN cr_crapprm (pr_cdcooper => pr_cdcooper,
                     pr_cdacesso => 'CTRL_'||upper(vr_cdprogra)||'_EXEC');
    FETCH cr_crapprm INTO rw_crapprm_ctrl;
    IF cr_crapprm%NOTFOUND THEN
      vr_dscritic := 'Parametro de sistema '||'CTRL_'||vr_cdprogra||'_EXEC não encontrado.';
      CLOSE cr_crapprm;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapprm;

    -- tratar dados do parametro
    vr_tbdados := gene0002.fn_quebra_string(pr_string  => rw_crapprm_ctrl.dsvlrprm,
                                            pr_delimit => '#');
    vr_dtctlexc := NULL;
    vr_qtctlexc := 0;
    --> Buscar data
    IF vr_tbdados.exists(1) THEN
      vr_dtctlexc := to_date(vr_tbdados(1),'DD/MM/RRRR');
    END IF;
    --> Buscar qtd
    IF vr_tbdados.exists(2) THEN
      vr_qtctlexc := vr_tbdados(2);
    END IF;

    --> buscar parametro de qtd de execução
    OPEN cr_crapprm (pr_cdcooper => pr_cdcooper,
                     pr_cdacesso => 'QTD_EXEC_'||upper(vr_cdprogra));
    FETCH cr_crapprm INTO rw_crapprm_qtd;
    IF cr_crapprm%NOTFOUND THEN
      vr_dscritic := 'Parametro de sistema '||'CTRL_'||vr_cdprogra||'_EXEC não encontrado.';
      CLOSE cr_crapprm;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapprm;

    --  Se tipo de operação for Incrementar
    IF pr_cdtipope = 'I' THEN
      -- Se mudou a data, deve reiniciar o parametro
      IF nvl(vr_dtctlexc,to_date('01/01/2001','DD/MM/RRRR')) <> pr_dtmvtolt THEN
        vr_qtdexec := 1;
      ELSIF vr_qtctlexc >= rw_crapprm_qtd.dsvlrprm THEN
        vr_dscritic := 'Processo '||vr_cdprogra||' já ultrapassou o limite diario de execução.';
        RAISE vr_exc_erro;
      ELSE
        vr_qtdexec := nvl(vr_qtctlexc,0) + 1;
      END IF;

      BEGIN
        UPDATE crapprm
           SET crapprm.dsvlrprm = to_char(pr_dtmvtolt,'DD/MM/RRRR')||'#'||vr_qtdexec
         WHERE crapprm.rowid = rw_crapprm_ctrl.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar parametro '||rw_crapprm_ctrl.cdacesso||':'||SQLERRM;
          RAISE vr_exc_erro;
      END;
    --> Validar
    ELSIF pr_cdtipope = 'V' THEN
      -- Se mudou a data, deve reiniciar o parametro
      IF nvl(vr_dtctlexc,to_date('01/01/2001','DD/MM/RRRR')) <> nvl(pr_dtmvtolt,to_date('01/01/2001','DD/MM/RRRR')) THEN
        vr_qtdexec := 1;
      ELSIF vr_qtctlexc >= rw_crapprm_qtd.dsvlrprm THEN
        vr_dscritic := 'Processo '||vr_cdprogra||' já ultrapassou o limite diario de execução.';
        RAISE vr_exc_erro;
      ELSE
        vr_qtdexec := nvl(vr_qtctlexc,0) + 1;
      END IF;
    ELSE --> Consulta
      vr_qtdexec := vr_qtctlexc;
    END IF;

    --> Verificar se é a ultima execucao
    IF vr_qtdexec >= rw_crapprm_qtd.dsvlrprm THEN
      pr_flultexe := 1;
    ELSE
      pr_flultexe := 0;
    END IF;

    pr_qtdexec := vr_qtdexec;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;

  END;
  
 /* Procedimento para sumarizar os agendamentos da debnet */
  PROCEDURE pc_sumario_debsic(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa inicial
                             ,pr_cdcopfin IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa final
                             ,pr_clobxmlc OUT CLOB                  --> XML com informações dos agendamentos
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Descricao critica                                      
     
  /* ..........................................................................
    --
    --  Programa : pc_sumario_debsic    
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Tiago Machado Flor
    --  Data     : Outubro/2016.                   Ultima atualizacao: 00/00/0000
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada sumarizar os agendamentos DEBSIC
    --
    --  Alteração : 
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    
    /* Verifica o Lancamento de credito salario */    
    CURSOR cr_craplau(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_insitlau craplau.insitlau%TYPE
                     ,pr_dtmvtopg crapdat.dtmvtolt%TYPE
                     ,pr_dtmovini crapdat.dtmvtolt%TYPE) IS
        SELECT  craplau.*
          FROM  craplau, 
                craphis
          WHERE craplau.cdcooper = craphis.cdcooper
            AND craplau.cdhistor = craphis.cdhistor
            AND craplau.cdcooper = pr_cdcooper             
            AND craplau.insitlau = pr_insitlau
            AND ((craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
            AND craplau.dtmvtopg = pr_dtmvtopg
            AND craplau.tpdvalor = 1)
              -- debito automatico sicredi
            OR (craplau.dtmvtopg BETWEEN pr_dtmovini AND pr_dtmvtopg
            AND craplau.cdhistor  = 1019));
/*                     
                     
        SELECT  craplau.*
          FROM  craplau, 
                craphis
          WHERE craplau.cdcooper = craphis.cdcooper
            AND craplau.cdhistor = craphis.cdhistor
            AND ((craplau.cdcooper >= pr_cdcooper
            AND craplau.cdcooper <= pr_cdcopfin
            AND craplau.dtmvtopg = pr_dtmvtopg
            AND craplau.insitlau = 1
            AND craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
            AND craplau.tpdvalor = 1)
              -- debito automatico sicredi
            OR (craplau.cdcooper  >= pr_cdcooper
            AND craplau.cdcooper  <= pr_cdcopfin
            AND craplau.dtmvtopg BETWEEN pr_dtmovini AND pr_dtmvtopg
            AND craplau.insitlau  = 1
            AND craplau.cdhistor  = 1019)); */
                         
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_crapcop1(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = DECODE(pr_cdcooper, 3, cop.cdcooper, pr_cdcooper)
         AND cop.cdcooper <> 3;
    rw_crapcop1 cr_crapcop1%ROWTYPE;   
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    ---------------> VARIAVEIS <-----------------
    vr_cdcooper     crapcop.cdcooper%TYPE;
    vr_qtefetivados DECIMAL(6);
    vr_qtnaoefetiva DECIMAL(6);
    vr_qtdpendentes DECIMAL(6);
    vr_qtdtotallanc DECIMAL(11);
    vr_insitlau craplau.insitlau%TYPE;
    
    vr_dtmovini  craplau.dtmvtopg%TYPE;
    
    --Variaveis de erro    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_tab_erro gene0001.typ_tab_erro;

    vr_index    VARCHAR2(300);

    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);
    
  BEGIN

      --Inicializar variaveis
      vr_qtefetivados := 0;
      vr_qtnaoefetiva := 0; 
      vr_qtdpendentes := 0; 
      vr_qtdtotallanc := 0;
    
      IF pr_cdcooper = 0 THEN
         vr_cdcooper := 3;
      ELSE
         vr_cdcooper := pr_cdcooper;   
      END IF;
    
      OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      
      IF cr_crapcop%NOTFOUND THEN
         CLOSE cr_crapcop;         
         RAISE vr_exc_erro;
      END IF;
      
      CLOSE cr_crapcop;
      
       -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      END IF;
      
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;

      -- Data anterior util
      vr_dtmovini := gene0005.fn_valida_dia_util(vr_cdcooper, 
                                                 (rw_crapdat.dtmvtolt - 1), -- 1 dia anterior
                                                 'A',    -- Anterior
                                                 TRUE,   -- Feriado
                                                 FALSE); -- Desconsiderar 31/12
      -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
      vr_dtmovini := vr_dtmovini + 1;     

      
      FOR rw_crapcop1 IN cr_crapcop1(pr_cdcooper => vr_cdcooper)  LOOP

          FOR vr_insitlau IN 1..4 LOOP

            --SOMAR OS LANCAMENTOS PARA ESCREVER DEPOIS NO XML
            FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop1.cdcooper
                                        ,pr_insitlau => vr_insitlau
                                        ,pr_dtmvtopg => rw_crapdat.dtmvtolt
                                        ,pr_dtmovini => vr_dtmovini) LOOP

              CASE rw_craplau.insitlau

                 WHEN 1 THEN vr_qtdpendentes := vr_qtdpendentes + 1; 
                 WHEN 2 THEN vr_qtefetivados := vr_qtefetivados + 1;
                 ELSE vr_qtnaoefetiva := vr_qtnaoefetiva + 1; 

              END CASE;
                                        
            END LOOP;

          END LOOP;
          
      END LOOP;
      
      vr_qtdtotallanc := vr_qtefetivados + vr_qtnaoefetiva + vr_qtdpendentes;
      
      --FIM SOMAR OS LANCAMENTOS PARA ESCREVER DEPOIS NO XML                         
      
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc,
                              pr_texto_completo => vr_xml_temp,
                              pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');
  
      
      --DEPOIS DE SOMAR OS AGENDAMENTOS NO CURSOR
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc,
                              pr_texto_completo => vr_xml_temp,
                              pr_texto_novo     => '<qtefetivados>' || NVL(vr_qtefetivados,0) || '</qtefetivados>'||
                                                   '<qtnaoefetiva>' || NVL(vr_qtnaoefetiva,0) || '</qtnaoefetiva>'||
                                                   '<qtdpendentes>' || NVL(vr_qtdpendentes,0) || '</qtdpendentes>'||
                                                   '<qtdtotallanc>' || NVL(vr_qtdtotallanc,0) || '</qtdtotallanc>');

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc,
                              pr_texto_completo => vr_xml_temp,
                              pr_texto_novo     => '</raiz>',
                              pr_fecha_xml      => TRUE);
                                                     
  EXCEPTION
     WHEN vr_exc_erro THEN      
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao buscar convenios aceitos: '||SQLERRM;  
  END pc_sumario_debsic;

END SICR0001;
/
