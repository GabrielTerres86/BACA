create or replace package cecred.PAGA0002 is

  /*..............................................................................

   Programa: PAGA0002                          Antiga: b1wgen0089.p
   Autor   : Guilherme/Supero
   Data    : 13/04/2011                        Ultima atualizacao: 22/02/2017

   Dados referentes ao programa:

   Objetivo  : BO para Retorno Instruções bancárias - Cob. Registrada

   Alteracoes: 02/05/2011 - Incluso procedure prepara-retorno (Guilherme).

               16/05/2011 - Acerto na procedure proc-motivos-retorno(Guilherme).

               28/06/2011 - Acerto na proc-liquidacao - gerar sempre retorno ao
                            cooperado mesmo que nao ha tarifa de liquidacao
                            (Rafael).

               08/07/2011 - Incluido horario de lancamento na conta do
                            cooperado - hrtransa = TIME (Rafael).
                          - Retirada chamada para procedure procedimentos-dda-jd_bo89
                            dentro da procedure proc-liquidacao (Elton).

               18/07/2011 - Gravado na temp-table de lancamentos, os registros
                            referentes a debitos e creditos, na procedure
                            proc-debito-tarifas-custas. (Fabricio)

               21/07/2011 - Alterado rotina proc-liquidacao:
                            Ajuste na preparacao do retorno ao cooperado
                            Ajuste no lanctos da cob. registrada 085 (Rafael)

               26/07/2011 - Feito tratamento para o campo crapret.cdhistbb,
                            na procedure grava-retorno. (Fabricio)

               27/07/2011 - Removido valor ? dos campos dtdpagto e vldpagto
                            na procedure proc-baixa (Rafael).
                          - Nao cobrar tarifa do cooperado (Rafael).

               29/07/2011 - Implementado rotina de inst autom de baixa
                            na procedure proc-conf-instrucao (Rafael).

               30/08/2011 - Incluido cdhistbb = 973 quando cdocorre = 23
                            (973-Custas Cart, 23 = Remessa Cart) (Rafael).

               10/10/2011 - Incluida a procedure prep-tt-lcm-mot-consolidada
                            (Henrique).

               18/10/2011 - Ajustes na rotina autom de baixa. (Rafael).

               20/10/2011 - Nao gravar log do titulo quando os motivos da
                            ent rejeitada forem (00,39,60) (Rafael).
                          - Qdo ent confirmada no convenio protesto, comandar
                            inst de protesto automaticamente (Rafael).
                          - Qdo ocorrer: remessa cartorio e sustacao, e já
                            houver uma inst de baixa em um dia anterior,
                            comandar inst autom de baixa (Rafael).
                          - Nao mostrar "Deb Tarifas Custas - motivo" nas
                            ocorrencias com código 28. (Rafael).

               08/11/2011 - Ajuste prep-retorno-cooperado nas procedures:
                            proc-liquidacao e proc-retorno-qualquer (Rafael).

               18/11/2011 - Confirmar sustacao de titulo quando ocorrer
                            custas de sustacao enviada pelo BB. (Rafael)

               06/01/2012 - Adequar historicos BB 966 e 939 somente qdo o
                            valor das tarifas > 0. (Rafael)

               27/02/2012 - Melhoria na rotina de inst autom de baixa. (Rafael)

               20/04/2012 - Omitir msg log do titulo qdo entrada rejeitada
                            motivo 38 - Prazo p/ protesto invalido. (Rafael)

               11/05/2012 - Rejeitar titulo quando ocorrer ent-rejeitada de
                            alguns motivos retornados pelo banco. (Rafel)
                          - Tratamento para liquidacao apos baixa. (Rafael)
                          - nao logar no titulo qdo conf de receb de inst
                            de protesto/sustacao. Tarefa 44895 (Rafael)

               17/05/2012 - alterado dtaltera na procedure grava-retorno pois
                            o BB esta utilizando data retroativa no arquivo
                            de retorno. (Rafael)

               23/05/2012 - Ajuste na rotina de ent-confirmada referente a
                            instrucao autom de protesto. (Rafael)

               20/08/2012 - Ajuste da rotina de pagto de títulos quando
                            descontados. (Rafael)

               14/12/2012 - Tratar postergacao de data em caso de titulos
                            descontados na liquidacao. (Rafael)

               16/01/2013 - Ajuste nas rotinas de lancto consolidado. (Rafael)

               03/04/2013 - Ajuste na gravacao do vlr pago nos registros de
                            retorno ao cooperado (Softdesk 51391). (Rafael)

               07/05/2013 - Projeto Melhorias da Cobranca. (Rafael)

               03/07/2013 - Ajuste na rotina que realiza-lancto-cooperado ref.
                            ao numero do documento na craplcm. (Rafael)

               05/07/2013 - Incluso var_internet.i , alterado processo de busca
                            valor tarifa para utilizar a rotina carrega_dados_tarifa_cobranca
                            da b1wgen0153, alterado realiza-lancto-cooperado para
                            efetuar lancamentos utilzando a procedure
                            cria_lan_auto_tarifa da b1wgen0153. (Daniel)

               26/09/2013 - Alterado o parametro par_dtmvtolt para crapdat.dtmvtolt
                            na procedure cria_lan_auto_tarifa (Daniel).

               10/10/2013 - Incluido parametro cdprogra nas procedures da
                            b1wgen0153 que carregam dados de tarifas (Tiago).

               24/10/2013 - Retirado a procedure cria-movto-cartorario e chamadas a
                            mesma (Daniel).

               27/11/2013 - Alterado processo de criacao crapcre para inicar
                            nrremret com 999999 e nao mais 1 (Daniel).

               28/11/2013 - Retirado rotina de replicacao do retorno dos titulos
                            BB do convenio "PROTESTO" para o convenio dos
                            titulos 085. (Rafael).

               03/12/2013 - Tratamento especial no controle da numeracao da
                            tabela crapcre dos titulos da cobranca com
                            registro BB. (Rafael).

               17/12/2013 - Adicionado "VALIDATE <tabela>" apos o CREATE de
                            registros nas tabelas. (Rafael e Jorge).

               04/03/2014 - Conversao Progress para oracle (Odirlei - AMcom)

               21/12/2015 - Incluido parametro pr_cdtrapen na procedure pc_cadastrar_agendamento,
                            Proj. 131 Assinatura Multipla (Jean Michel).

               08/01/2016 - Adicionado proc. pc_convenios_aceitos, convertido da BO16.
                            Proj. 131 Assinatura Multipla (Jorge/David).

               24/03/2016 - Adicionados parâmetros para geraçao de LOG
                           (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)

               10/05/2016 - Ajustes devido ao projeto M118 para cadastrar o favorecido de forma automatica
                              (Adriano - M117).

               12/05/2016 - Ajustes realizados:
                          - Alimentar corretamente variaveis de retorno de critica na rotina pc_cadastrar_agendamento;
                          (Adriano - M117).

        19/05/2016 - Ajuste na mensagem de retorno para agendamentos
              (Adriano - M117.)

               30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

                     05/08/2016 - Incluido tratamento para verificacao de transacoes duplicadas na procedure
                           pc_cadastrar_agendamento, SD 494025 (Jean Michel).

       06/09/2016 - Ajuste para apresentar o horario limite para debito de ted's agendadas
                          (Adriano - SD509480).

             29/12/2016 - Tratamento Nova Plataforma de cobrança PRJ340 - NPC (Odirlei-AMcom)  	  

							 22/02/2017 - Ajustes para correçao de crítica de pagamento DARF/DAS (Lucas Lunelli - P.349.2)

			 17/04/2017 - Alterações referentes à Nova Plataforma de Cobrança - NPC (Renato-Amcom)
                           
..............................................................................*/
  -- Antigo tt-agenda-recorrente
  TYPE typ_rec_agenda_recorrente IS RECORD
      (dtmvtopg craplau.dtmvtopg%TYPE,
       dtpagext VARCHAR2(60),
       flgtrans BOOLEAN,
       dscritic crapcri.dscritic%TYPE,
       vltarifa NUMBER(25,2));
  TYPE typ_tab_agenda_recorrente IS TABLE OF typ_rec_agenda_recorrente
    INDEX BY PLS_INTEGER;

  -- Antigo tt-vlapagar
  TYPE typ_rec_vlapagar IS RECORD
       (dtmvtopg DATE,
        vlapagar NUMBER);
  TYPE typ_tab_vlapagar IS TABLE OF typ_rec_vlapagar
    INDEX BY VARCHAR2(8);

  --Antigo tt-convenios_aceitos da BO16
  TYPE typ_reg_convenios IS
    RECORD (nmextcon VARCHAR2(100)
           ,nmrescon VARCHAR2(100)
           ,cdempcon NUMBER
           ,cdsegmto NUMBER
           ,hhoraini VARCHAR2(100)
           ,hhorafim VARCHAR2(100)
           ,hhoracan VARCHAR2(100));

  --Tipo de tabela de memoria para convenios aceitos
  TYPE typ_tab_convenios IS TABLE OF typ_reg_convenios INDEX BY PLS_INTEGER;

  --Antigo tt-dados-agendamento da BO16
  TYPE typ_reg_dados_agendamento IS
    RECORD (dtmvtage DATE
           ,dtmvtopg DATE
           ,dtvencto DATE
           ,vllanaut NUMBER
           ,dttransa DATE
           ,hrtransa INTEGER
           ,nrdocmto INTEGER
					 ,insitlau INTEGER
           ,dssitlau VARCHAR2(100)
           ,dslindig VARCHAR2(300)
           ,dscedent VARCHAR2(300)
           ,dtvendrf DATE
           ,dsageban VARCHAR2(100)
           ,nrctadst VARCHAR2(100)
           ,incancel INTEGER
           ,nmprimtl VARCHAR2(100)
           ,nmprepos VARCHAR2(100)
           ,nrcpfpre NUMBER
           ,nmoperad VARCHAR2(100)
           ,nrcpfope NUMBER
           ,nrcpfcgc VARCHAR2(200)
           ,idtitdda NUMBER
           ,cdageban VARCHAR2(100)
           ,cdtiptra INTEGER
           ,dstiptra VARCHAR2(100)
           ,dtagenda DATE
           ,tpcaptur INTEGER
           ,dstipcat VARCHAR2(100)
           ,dsidpgto VARCHAR2(100)
           ,dsnomfon VARCHAR2(100)
           ,dtperiod DATE
           ,cdreceit VARCHAR2(10)
           ,nrrefere INTEGER
           ,vlprinci NUMBER
           ,vlrmulta NUMBER
           ,vlrjuros NUMBER
           ,vlrtotal NUMBER
           ,vlrrecbr NUMBER
           ,vlrperce NUMBER
           ,idlancto NUMBER(15)
					 ,dscritic craplau.dscritic%TYPE
           ,gps_cddpagto NUMBER
           ,gps_dscompet VARCHAR2(7)
           ,gps_cdidenti NUMBER
           ,gps_vlrdinss NUMBER
           ,gps_vlrouent NUMBER
           ,gps_vlrjuros NUMBER
           ,idlstdom NUMBER);
           
  --Tipo de tabela de memoria para dados de agendamentos
  TYPE typ_tab_dados_agendamento IS TABLE OF typ_reg_dados_agendamento INDEX BY PLS_INTEGER;

  /* Procedimento do internetbank operação 22 - Transferencia */
  PROCEDURE pc_InternetBank22 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nmrescop IN crapcop.nmrescop%TYPE   --> Nome da cooperativa
                               ,pr_nrdconta IN crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_nrcpfope IN crapopi.nrcpfope%TYPE   --> CPF do operador juridico
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_tpoperac IN INTEGER                 --> Tipo de opracao
                               ,pr_cdtiptra IN INTEGER                 --> Tipo de transacao
                               ,pr_cddbanco IN crapcti.cddbanco%TYPE   --> Codigo do banco
                               ,pr_cdispbif IN crapcti.nrispbif%TYPE   --> Numero inscrição SPB
                               ,pr_cdageban IN crapcti.cdageban%TYPE   --> codigo da agencia bancaria.
                               ,pr_nrctatrf IN VARCHAR2                --> conta que recebe a transferencia. 
                               ,pr_nmtitula IN crapcti.nmtitula%TYPE   --> nome do titular da conta.
                               ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE   --> cpf/cnpj do titular da conta.
                               ,pr_inpessoa IN crapcti.inpessoa%TYPE   --> tipo de pessoa da conta.
                               ,pr_intipcta IN crapcti.intipcta%TYPE   --> tipo da conta.
                               ,pr_idagenda IN INTEGER                 --> Identificador de agendamento
                               ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE   --> Data do pagamento
                               ,pr_vllanmto IN craplcm.vllanmto%TYPE   --> Valor do lançamento
                               ,pr_cdfinali IN INTEGER                 --> Codigo de finalidade
                               ,pr_dstransf IN VARCHAR2                --> Descricao da transferencia
                               ,pr_ddagenda IN INTEGER                 --> Dia do agendamento
                               ,pr_qtmesagd IN INTEGER                 --> Qtd de mes agendamento
                               ,pr_dtinicio IN VARCHAR2                --> data inicio
                               ,pr_lsdatagd IN VARCHAR2                --> lista de datas agendamento
                               ,pr_flgexecu IN INTEGER                 --> 1-TRUE 0-FALSE
                               ,pr_gravafav IN INTEGER                 --> Grava favorecido 1-TRUE 0-FALSE
                               ,pr_dshistor IN VARCHAR2                --> codifo do historico
                               ,pr_flmobile IN INTEGER                 --> Indicador se origem é do Mobile
                               ,pr_iptransa IN VARCHAR2                --> IP da transacao no IBank/mobile
                               ,pr_xml_dsmsgerr   OUT VARCHAR2         --> Retorno XML de critica
                               ,pr_xml_operacao22 OUT CLOB             --> Retorno XML da operação 26
                               ,pr_dsretorn       OUT VARCHAR2);       --> Retorno de critica (OK ou NOK)


  /* Procedimento do internetbank operação 26 - Validar pagamento */
  PROCEDURE pc_InternetBank26 ( pr_cdcooper IN  crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nrdconta IN  crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl IN  crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_idtitdda IN  VARCHAR2                 --> Indicador DDA
                               ,pr_idtpdpag IN  INTEGER                 --> Indicador de tipo de pagamento
                               ,pr_lindigi1 IN  NUMBER                  --> Linha digitavel 1
                               ,pr_lindigi2 IN  NUMBER                  --> Linha digitavel 2
                               ,pr_lindigi3 IN  NUMBER                  --> Linha digitavel 3
                               ,pr_lindigi4 IN  NUMBER                  --> Linha digitavel 4
                               ,pr_lindigi5 IN  NUMBER                  --> Linha digitavel 4
                               ,pr_cdbarras IN  VARCHAR2                --> Codigo de barras
                               ,pr_vllanmto IN  NUMBER                  --> Valor Lancamento
                               ,pr_idagenda IN  INTEGER                 --> Indicador agendamento
                               ,pr_dtmvtopg IN DATE                     --> Data de pagamento
                               ,pr_dscedent IN VARCHAR2                 --> Descrição do cedente
                               ,pr_nrcpfope IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_flmobile IN  INTEGER                 --> Indicador se origem é do Mobile
                               ,pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                               ,pr_vlapagar IN  NUMBER                  --> Valor a pagar
                               ,pr_xml_dsmsgerr   OUT VARCHAR2          --> Retorno XML de critica
                               ,pr_xml_operacao26 OUT CLOB              --> Retorno XML da operação 26
                               ,pr_dsretorn       OUT VARCHAR2);        --> Retorno de critica (OK ou NOK)

  /* Procedimento do internetbank operação 27 - Efetuar pagamento */
  PROCEDURE pc_InternetBank27 ( pr_cdcooper IN  crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nrdconta IN  crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl IN  crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_idtitdda IN  VARCHAR2                --> Indicador DDA
                               ,pr_idagenda IN  INTEGER                 --> Indicador de agendamento
                               ,pr_idtpdpag IN  INTEGER                 --> Indicador de tipo de pagamento
                               ,pr_lindigi1 IN  NUMBER                  --> Linha digitavel 1
                               ,pr_lindigi2 IN  NUMBER                  --> Linha digitavel 2
                               ,pr_lindigi3 IN  NUMBER                  --> Linha digitavel 3
                               ,pr_lindigi4 IN  NUMBER                  --> Linha digitavel 4
                               ,pr_lindigi5 IN  NUMBER                  --> Linha digitavel 5
                               ,pr_cdbarras IN  VARCHAR2                --> Codigo de barras
                               ,pr_dscedent IN  VARCHAR2                --> Descrição do cedente
                               ,pr_dtmvtopg IN  DATE                    --> Data para pagamento
                               ,pr_dtvencto IN DATE                     --> Data do vencimento
                               ,pr_vllanmto IN crapopi.nrcpfope%TYPE    --> Valor Lancamento
                               ,pr_vlpagame IN  NUMBER                  --> valor fatura
                               ,pr_cdseqfat IN  VARCHAR2                --> Codigo sequncial da fatura
                               ,pr_nrdigfat IN  NUMBER                  --> Digito da fatura
                               ,pr_nrcnvcob IN  NUMBER                  --> Numero do convenio de cobrança
                               ,pr_nrboleto IN  NUMBER                  --> Numero do boleto
                               ,pr_nrctacob IN  NUMBER                  --> Numero da conta de cobrança
                               ,pr_insittit IN  INTEGER                 --> Situação do titulo
                               ,pr_intitcop IN  INTEGER                 --> Titulo da coopeariva
                               ,pr_nrdctabb IN  NUMBER                  --> Numero da conta BB
                               ,pr_nrcpfope IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_vlapagar IN  NUMBER                  --> Valor a pagar
                               ,pr_versaldo IN  INTEGER                 --> Indicador de ver saldo
                               ,pr_flmobile IN  INTEGER                 --> Indicador se origem é do Mobile
                               ,pr_tpcptdoc IN craptit.tpcptdoc%TYPE DEFAULT 1 --> Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                               ,pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                               ,pr_xml_dsmsgerr OUT VARCHAR2            --> Retorno XML de critica
                               ,pr_xml_msgofatr OUT VARCHAR2            --> Retorno XML com mensagem para fatura
                               ,pr_xml_cdempcon OUT VARCHAR2            --> Retorno XML com cod empresa convenio
                               ,pr_xml_cdsegmto OUT VARCHAR2            --> Retorno XML com segmto convenio
							   ,pr_xml_dsprotoc OUT VARCHAR2            --> Retorno XML com protocolo do comprovante gerado
                               ,pr_dsretorn     OUT VARCHAR2);          --> Retorno de critica (OK ou NOK)

  /* Gerar registro de Retorno = 02 - Entrada Confirmada */
  PROCEDURE pc_ent_confirmada ( pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                               ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                               ,pr_nrnosnum IN VARCHAR2                 -- Nosso Numero
                               ,pr_cdbcocob IN INTEGER                  -- Codigo banco cobrança
                               ,pr_cdagecob IN INTEGER                  -- Codigo Agencia cobranca
                               ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                               ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                               ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                               ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                               ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                               ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                /* parametros de erro */
                               ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2);              -- Descricao critica


  /* Gerar registro de Retorno = 03 - Entrada Rejeitada */
  PROCEDURE pc_ent_rejeitada  ( pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                               ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                               ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                               ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                               ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                               ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                               ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                                /* parametros de erro */
                               ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = 09 - Baixa */
  PROCEDURE pc_proc_baixa  (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                           ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                           ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamentp
                           ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamentp
                           ,pr_dtocorre IN DATE                     -- data da ocorrencia
                           ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                           ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                           ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                           ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                           ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                           ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                            /* parametros de erro */
                           ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                           ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = 12, 13, 14, 19, 20 */
  PROCEDURE pc_proc_conf_instrucao (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                   ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                   ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                   ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                   ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                   ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                   ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                   ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                   ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                    /* parametros de erro */
                                   ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = 23 - Remessa a cartório */
  PROCEDURE pc_proc_remessa_cartorio (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = 24 - Retirada de cartório e manutenção em carteira */
  PROCEDURE pc_proc_retirada_cartorio(pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = 25 - Protestado e Baixado */
  PROCEDURE pc_proc_protestado (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                               ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                               ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
                               ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                               ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                               ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                               ,pr_dtocorre IN DATE                     -- data da ocorrencia
                               ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                               ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                               ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                               ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                               ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                               ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                /* parametros de erro */
                               ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = 28 - Debito de tarifas/custas */
  PROCEDURE pc_proc_deb_tarifas_custas (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                       ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                       ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
                                       ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                                       ,pr_vloutcre IN NUMBER                   -- Valor credito
                                       ,pr_vloutdeb IN NUMBER                   -- Valor debito
                                       ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                       ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                       ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                       ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                       ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                       ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                       ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                       ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                        /* parametros de erro */
                                       ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Gerar registro de Retorno = Retorno Qualquer */
  PROCEDURE pc_proc_retorno_qualquer (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2);              -- Descricao critica

  /* Procedimento para gerar os agendamentos de pagamento/transferencia/Credito salario */
  PROCEDURE pc_cadastrar_agendamento ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_idtpdpag IN INTEGER                --> Indicador de tipo de agendamento
                                      ,pr_dscedent IN craplau.dscedent%TYPE  --> Descrição do cedente
                                      ,pr_dscodbar IN craplau.dscodbar%TYPE  --> Descrição codbarras
                                      ,pr_lindigi1 IN NUMBER                 --> 1° parte da linha digitavel
                                      ,pr_lindigi2 IN NUMBER                 --> 2° parte da linha digitavel
                                      ,pr_lindigi3 IN NUMBER                 --> 3° parte da linha digitavel
                                      ,pr_lindigi4 IN NUMBER                 --> 4° parte da linha digitavel
                                      ,pr_lindigi5 IN NUMBER                 --> 5° parte da linha digitavel
                                      ,pr_cdhistor IN craplau.cdhistor%TYPE  --> Codigo do historico
                                      ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE  --> Data de pagamento
                                      ,pr_vllanaut IN craplau.vllanaut%TYPE  --> Valor do lancamento automatico
                                      ,pr_dtvencto IN craplau.dtvencto%TYPE  --> Data de vencimento
                                      ,pr_cddbanco IN craplau.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN craplau.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctadst IN craplau.nrctadst%TYPE  --> Numero da conta destino
                                      ,pr_cdcoptfn IN craplau.cdcoptfn%TYPE  --> Codigo que identifica a cooperativa do cash.
                                      ,pr_cdagetfn IN craplau.cdagetfn%TYPE  --> Numero do pac do cash.
                                      ,pr_nrterfin IN craplau.nrterfin%TYPE  --> Numero do terminal financeiro.
                                      ,pr_nrcpfope IN craplau.nrcpfope%TYPE  --> Numero do cpf do operador juridico
                                      ,pr_idtitdda IN VARCHAR2               --> Contem o identificador do titulo dda.
                                      ,pr_cdtrapen IN INTEGER                --> Codigo da transacao Pendente
                    ,pr_flmobile IN INTEGER                --> Indicador Mobile
                    ,pr_idtipcar IN INTEGER                --> Indicador Tipo Cartão Utilizado
                    ,pr_nrcartao IN NUMBER                 --> Numero Cartao
                                      ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                      ,pr_dstransf IN VARCHAR2               --> Descricao da transferencia
                                      ,pr_dshistor IN VARCHAR2               --> Descricao da finalidade
                                      ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                                      ,pr_cdctrlcs IN craplau.cdctrlcs%TYPE  --> Código de controle de consulta
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                    ,pr_msgofatr OUT VARCHAR2
                                      ,pr_cdempcon OUT NUMBER
                    ,pr_cdsegmto OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2);            --> Descricao critica

  /* Procedure para validar agendamento recorrente */
  PROCEDURE pc_verif_agend_recorrente (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_ddagenda IN craplau.idtitdda%TYPE  --> Dia de agendamento
                                      ,pr_qtmesagd IN INTEGER                --> Quantidade de meses
                                      ,pr_dtinicio IN VARCHAR2               --> Data inicial
                                      ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lancamento automatico
                                      ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Numero da conta destino
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_lsdatagd IN VARCHAR2               --> lista de datas agendamento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_tpoperac IN INTEGER                --> tipo de operação
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_nrcpfope IN craplau.nrcpfope%TYPE  --> Numero do cpf do operador juridico
                                      ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_tab_agenda_recorrente OUT typ_tab_agenda_recorrente  --> Registros de agendamento recorrentes
                                      ,pr_cdcritic OUT NUMBER                --> codigo de criticas
                                      ,pr_dscritic OUT VARCHAR2);            --> Descricao critica

  PROCEDURE pc_verif_agend_recor_prog( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_ddagenda IN craplau.idtitdda%TYPE  --> Dia de agendamento
                                      ,pr_qtmesagd IN INTEGER                --> Quantidade de meses
                                      ,pr_dtinicio IN VARCHAR2               --> Data inicial
                                      ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lancamento automatico
                                      ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Numero da conta destino
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_lsdatagd IN VARCHAR2               --> lista de datas agendamento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_tpoperac IN INTEGER                --> tipo de operação
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_nrcpfope IN craplau.nrcpfope%TYPE  --> Numero do cpf do operador juridico
                                      ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_tab_agenda_recorrente OUT CLOB      --> Registros de agendamento recorrentes
                                      ,pr_cdcritic OUT NUMBER                --> codigo de criticas
                                      ,pr_dscritic OUT VARCHAR2);            --> Descricao critica

  /* Procedimento para gerar os agendamentos recorrente */
  PROCEDURE pc_agendamento_recorrente( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_lsdatagd IN VARCHAR2               --> Lista de datas de agendamento
                                      ,pr_cdhistor IN craplau.cdhistor%TYPE  --> Codigo do historico
                                      ,pr_vllanmto IN craplau.vllanaut%TYPE  --> Valor do lancamento automatico
                                      ,pr_cddbanco IN craplau.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN craplau.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctatrf IN craplau.nrctadst%TYPE  --> Numero da conta destino
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_cdcoptfn IN craplau.cdcoptfn%TYPE  --> Codigo que identifica a cooperativa do cash.
                                      ,pr_cdagetfn IN craplau.cdagetfn%TYPE  --> Numero do pac do cash.
                                      ,pr_nrterfin IN craplau.nrterfin%TYPE  --> Numero do terminal financeiro.
                                      ,pr_flmobile IN INTEGER                --> Indicador Mobile
                                      ,pr_idtipcar IN INTEGER                --> Indicador Tipo Cartão Utilizado
                                      ,pr_nrcartao IN NUMBER                 --> Numero Cartao
                                      ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                      ,pr_dstransf IN VARCHAR2               --> Descricao da transferencia
                                      ,pr_dshistor IN VARCHAR2               --> Descricao da finalidade
                                      ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_cdcritic OUT VARCHAR2              --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2);            --> Descricao critica

PROCEDURE pc_tranf_sal_intercooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                            ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                            ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                            ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                            ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                            ,pr_idorigem IN INTEGER                --> Id da origem da transação
                                            ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                            ,pr_rowidlcs IN craplcs.progress_recid%TYPE
                                            ,pr_cdagetrf IN crapccs.cdagetrf%TYPE -- Numero do PA.
                                            ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                            ,pr_flgerlog IN BOOLEAN
                                         ,pr_rw_craplot OUT lote0001.cr_craplot%ROWTYPE  --> rowtype saida lote
                                            /* parametros de saida */
                                            ,pr_cdcritic OUT VARCHAR2              --> Codigo da critica
                                            ,pr_dscritic OUT VARCHAR2);            --> Descricao critica

  /* Procedimento para listar convenios aceitos */
  PROCEDURE pc_convenios_aceitos(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 /* parametros de saida */
                                ,pr_tab_convenios OUT PAGA0002.typ_tab_convenios --Tabelas de retorno de convenios aceitos
                                ,pr_cdcritic OUT VARCHAR2              --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2);            --> Descricao critica

  /* Auditoria das informações de Auto Atendimento para retorno de sobras posterior */
  PROCEDURE pc_auditoria_auto_atend(pr_dtmvtoan IN crapdat.dtmvtoan%TYPE DEFAULT NULL);

  /* Procedimento para sumarizar os agendamentos da debnet */
  PROCEDURE pc_sumario_debnet(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa inicial
                             ,pr_cdcopfin IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa final
                             ,pr_clobxmlc OUT CLOB                  --> XML com informações dos agendamentos
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE);    --> Descricao critica

  /* Procedimento para obter dados de agendamentos via PROGRESS */
  PROCEDURE pc_obtem_agendamentos_car(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Código do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Numero do Caixa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                     ,pr_dsorigem  IN VARCHAR2              --> Descricao da Origem
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao Atual
                                     ,pr_dtageini  IN crapdat.dtmvtolt%TYPE --> Data de Agendamento Inicial
                                     ,pr_dtagefim  IN crapdat.dtmvtolt%TYPE --> Data de Agendamento Final
                                     ,pr_insitlau  IN craplau.insitlau%TYPE --> Situacao do Lancamento
                                     ,pr_iniconta  IN INTEGER               --> Numero de Registros da Tela
                                     ,pr_nrregist  IN INTEGER               --> Numero da Registros
                                     ,pr_dstransa OUT VARCHAR2              --> Descricao da Transacao
                                     ,pr_qttotage OUT INTEGER               --> Quantidade Total de Agendamentos
                                     ,pr_clobxmlc OUT CLOB                  --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  /* Procedimento para cancelar agendamento */
  PROCEDURE pc_cancelar_agendamento (  pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_dtmvtage IN crapdat.dtmvtolt%TYPE  --> Data do agendamento
                                      ,pr_nrdocmto IN craplau.nrdocmto%TYPE  --> Numero do documento
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela

                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_dscritic OUT VARCHAR2);           --> Descricao critica
  
  /* Realizar a apuração diária dos lançamentos dos históricos de pagamento de empréstimos */
  PROCEDURE pc_apura_lcm_his_emprestimo(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                       ,pr_dtrefere IN DATE   );             -- Data de referencia para processamento
                                      
  PROCEDURE pc_obtem_agendamentos(pr_cdcooper               IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                                 ,pr_cdagenci               IN crapage.cdagenci%TYPE              --> Código do PA
                                 ,pr_nrdcaixa               IN craplot.nrdcaixa%TYPE              --> Numero do Caixa
                                 ,pr_nrdconta               IN crapass.nrdconta%TYPE              --> Numero da Conta
                                 ,pr_dsorigem               IN VARCHAR2                           --> Descricao da Origem
                                 ,pr_dtmvtolt               IN crapdat.dtmvtolt%TYPE              --> Data de Movimentacao Atual
                                 ,pr_dtageini               IN crapdat.dtmvtolt%TYPE              --> Data de Agendamento Inicial
                                 ,pr_dtagefim               IN crapdat.dtmvtolt%TYPE              --> Data de Agendamento Final
                                 ,pr_insitlau               IN craplau.insitlau%TYPE              --> Situacao do Lancamento
                                 ,pr_iniconta               IN INTEGER                            --> Numero de Registros da Tela
                                 ,pr_nrregist               IN INTEGER                            --> Numero da Registros
                                 ,pr_cdtiptra               IN VARCHAR2 DEFAULT NULL              --> Tipo de transação
                                 ,pr_dstransa              OUT VARCHAR2                           --> Descricao da Transacao
                                 ,pr_qttotage              OUT INTEGER                            --> Quantidade Total de Agendamentos
                                 ,pr_tab_dados_agendamento OUT PAGA0002.typ_tab_dados_agendamento --> Tabela com Informacoes de Agendamentos
                                 ,pr_cdcritic              OUT PLS_INTEGER                        --> Código da crítica
                                 ,pr_dscritic              OUT VARCHAR2);                       --> Descrição da crítica
                                                                       
end PAGA0002;
/
create or replace package body cecred.PAGA0002 is

  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : PAGA0002
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - Amcom
  --  Data     : Março/2014.                   Ultima atualizacao: 03/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para Retorno Instruções bancárias - Cob. Registrada
  --
  -- Alteracoes: 04/03/2014 - Conversao Progress para oracle (Odirlei - AMcom)
  --
  --             15/07/2015 - Ajustado pr_InternetBank26 e pc_InternetBank27 para as variaveis de erro que
  --                          retornam da INET0001.pc_verifica_operacao (Douglas)
  --
  --             24/07/2015 - #308980 Tratamento nos procedures pc_InternetBank26 e pc_InternetBank27 para não
  --                          concatenar o pr_dscedent a crítica quando o campo Cedente não for preenchido (Carlos)

                 10/08/2015 - Adição de parâmetro flmobile para indicar que a origem
                              da chamada é do mobile (Dionathan)
  --
  --             14/08/2015 - pc_internetbank27 -> inclusão do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
  --
  --             08/12/2015 - Adicionado chamda da proc. pc_verifica_rep_assinatura, retornando informacoes
  --                          quanto a conta exigir Assinatura Conjunta entre outras informacoes.
  --                          (Jorge/David) Proj. 131 Assinatura Multipla
  --
  --             21/12/2015 - Incluido parametro pr_cdtrapen na procedure pc_cadastrar_agendamento,
  --                          Proj. 131 Assinatura Multipla (Jean Michel).
  --
  --             08/01/2016 - Adicionado proc. pc_convenios_aceitos, convertido da BO16.
  --                          Proj. 131 Assinatura Multipla (Jorge/David).
  --
  --             28/01/2016 - aumentado o tamanho da variavel vr_cdbarras para 100 nas procedures
  --                          pc_InternetBank26 e pc_InternetBank27 pois qdo era pagamento de um
  --                          VRBoleto DDA ocasionava estouro dessa variavel por concatenar mais informacoes
  --                          (Tiago/Elton).
  --
  --             24/03/2016 - Adicionados parâmetros para geraçao de LOG
  --                          (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)
  --
  --             22/04/2016 - Alterando a mensagem de log na rotina pc_InternetBank27 conforme
  --                          solicitado no chamado 417943. (Kelvin)
  --
  --             10/05/2016 - Ajustes devido ao projeto M118 para cadastrar o favorecido de forma automatica
  --                          (Adriano - M117).
  --
  --             19/05/2016 - Ajuste na mensagem de retorno para agendamentos
  --                           (Adriano - M117.)
  --
  --             24/05/2016 - Ajustes para monitoramento de TEDs agendadas em pc_monitora_ted (Carlos)
  --
  --             01/06/2016 - Ajuste do caracter '-' na pc_monitora_ted, lista de contatos telefonicos (Carlos)
  --
  --             03/06/2016 - Ajuste para chamar a rotina de monitoramento somente quando operação de TED
  --                          (Adriano).
  --
  --             30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
  --
  --             18/07/2016 - Ajuste da mensagem de confirmacao do agendamento de ted para 7h30min ao inves de 9h
  --                          (Carlos)
  --
    --             20/07/2016 - Inclusão dos parametros pr_cdfinali, pr_dstransf e pr_dshistor para criação do
    --                          registro tbted_det_agendamento ao cadastrar um agendamento de ted
    --                          (insert craplau) (Carlos)
  --
  --             22/07/2016 - Correção de xml sendo limpo e de format da data na rotina pc_verif_agend_recor_prog
  --                          (Carlos)
  --
  --             05/08/2016 - Incluido tratamento para verificacao de transacoes duplicadas na procedure
  --                          pc_cadastrar_agendamento, SD 494025 (Jean Michel).
  --
  --             19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo
  --                          InternetBanking (Projeto 338 - Lucas Lunelli)
  --
  --             30/11/2016 - Alterado query do sumario da tela debnet pra trazer corretamente
  --                          os resultados (Tiago/Elton SD566237)
  --
  --             21/11/2016 - Rotina pc_internetbank22 - Inclusao de parametros na chamada da rotina pc_executa_envio_ted.
  --                        - Removido pc_monitora_ted, rotina será utilizada na AFRA0001
  --                          PRJ335 - Analise de fraudes (Odirlei-AMcom)
  --
  --              29/12/2016 - Tratamento Nova Plataforma de cobrança PRJ340 - NPC (Odirlei-AMcom)  
  --
  --             07/02/2017 - #604294 Log de exception others na rotina pc_proc_agendamento_recorrente e
  --                          aumento do tamanho das variáveis vr_dslinxml_desaprov e vr_dslinxml_aprov
  --                          para evitar possível repetição do problema relatado no chamado (Carlos)
  --
  --             22/02/2017 - Ajustes para correçao de crítica de pagamento DARF/DAS (Lucas Lunelli - P.349.2)
  
                 03/10/2017 - Ajuste da mensagem de erro. (Ricardo Linhares - prj 356.2)
  --
  --             12/06/2017 - Alterar tipo do parametro pr_nrctatrf para varchar2 
  --                          referentes ao Novo Catalogo do SPB (Lucas Ranghetti #668207)
  --
  --             10/07/2017 - Buscar ultimo horario da DEBNET para exibir o horario quando efetuado 
  --                          um agendamento de Transferencia (Lucas Ranghetti #676219)
  --
  --             03/10/2017 - #765090 Nas transferências, na mensagem de horário para saldo em conta, 
  --                          mostrar os minutos em múltiplos de 5 arredondando para baixo. 
  --                          Ex.: Cadastrado: 21:04 -> Mostrar: 21:00 (Carlos)
  ---------------------------------------------------------------------------------------------------------------*/

  ----------------------> CURSORES <----------------------

  --Selecionar registro cobranca
  CURSOR cr_crapcob (pr_rowid IN ROWID) IS
    SELECT  crapcob.cdcooper
           ,crapcob.nrdconta
           ,crapcob.cdbandoc
           ,crapcob.nrdctabb
           ,crapcob.nrcnvcob
           ,crapcob.nrdocmto
           ,crapcob.flgregis
           ,crapcob.flgcbdda
           ,crapcob.insitpro
           ,crapcob.nrnosnum
           ,crapcob.vltitulo
           ,crapcob.incobran
           ,crapcob.dtvencto
           ,crapcob.dsdoccop
           ,crapcob.vlabatim
           ,crapcob.vldescto
           ,crapcob.flgdprot
           ,crapcob.idopeleg
           ,crapcob.insitcrt
           ,crapcob.cdagepag
           ,crapcob.cdbanpag
           ,crapcob.cdtitprt
           ,crapcob.dtdbaixa
           ,crapcob.dtsitcrt
           ,crapcob.rowid
     FROM crapcob
    WHERE crapcob.ROWID = pr_rowid;
  rw_crapcob cr_crapcob%ROWTYPE;

  CURSOR cr_craphec(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_cdprogra IN VARCHAR2) IS
 SELECT MAX(c.hriniexe) hriniexe
   FROM craphec c
  WHERE c.cdcooper = pr_cdcooper
    AND upper(c.cdprogra) = upper(pr_cdprogra);
  rw_craphec cr_craphec%ROWTYPE;

  /* Procedimento do internetbank operação 22 - Transferencia */
  PROCEDURE pc_InternetBank22 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nmrescop IN crapcop.nmrescop%TYPE   --> Nome da cooperativa
                               ,pr_nrdconta IN crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_nrcpfope IN crapopi.nrcpfope%TYPE   --> CPF do operador juridico
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_tpoperac IN INTEGER                 --> Tipo de opracao
                               ,pr_cdtiptra IN INTEGER                 --> Tipo de transacao
                               ,pr_cddbanco IN crapcti.cddbanco%TYPE   --> Codigo do banco
                               ,pr_cdispbif IN crapcti.nrispbif%TYPE   --> Numero inscrição SPB
                               ,pr_cdageban IN crapcti.cdageban%TYPE   --> codigo da agencia bancaria.
                               ,pr_nrctatrf IN VARCHAR2                --> conta que recebe a transferencia.
                               ,pr_nmtitula IN crapcti.nmtitula%TYPE   --> nome do titular da conta.
                               ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE   --> cpf/cnpj do titular da conta.
                               ,pr_inpessoa IN crapcti.inpessoa%TYPE   --> tipo de pessoa da conta.
                               ,pr_intipcta IN crapcti.intipcta%TYPE   --> tipo da conta.
                               ,pr_idagenda IN INTEGER                 --> Identificador de agendamento
                               ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE   --> Data do pagamento
                               ,pr_vllanmto IN craplcm.vllanmto%TYPE   --> Valor do lançamento
                               ,pr_cdfinali IN INTEGER                 --> Codigo de finalidade
                               ,pr_dstransf IN VARCHAR2                --> Descricao da transferencia
                               ,pr_ddagenda IN INTEGER                 --> Dia do agendamento
                               ,pr_qtmesagd IN INTEGER                 --> Qtd de mes agendamento
                               ,pr_dtinicio IN VARCHAR2                --> data inicio
                               ,pr_lsdatagd IN VARCHAR2                --> lista de datas agendamento
                               ,pr_flgexecu IN INTEGER                 --> 1-TRUE 0-FALSE
                               ,pr_gravafav IN INTEGER                 --> Grava favorecido 1-TRUE 0-FALSE
                               ,pr_dshistor IN VARCHAR2                --> codifo do historico
                               ,pr_flmobile IN INTEGER                 --> Indicador se origem é do Mobile
                               ,pr_iptransa IN VARCHAR2                --> IP da transacao no IBank/mobile
                               ,pr_xml_dsmsgerr   OUT VARCHAR2         --> Retorno XML de critica
                               ,pr_xml_operacao22 OUT CLOB             --> Retorno XML da operação 26
                               ,pr_dsretorn       OUT VARCHAR2) IS     --> Retorno de critica (OK ou NOK)

    /* ..........................................................................

      Programa : pc_InternetBank22        Antiga: sistema/internet/fontes/InternetBank22.p
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : David
      Data    : Abril/2007.                       Ultima atualizacao: 12/06/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Verificar e executar transferencia via Internet.

      Alteracoes: 08/08/2007 - Trocadas procedures da BO b1wgen00015.p e retornar
                               a mensagem de pagamento com sucesso (Evandro).

                  09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).

                  27/11/2007 - Incluir parametros no metodo (David).

                  06/02/2008 - Incluir parametro no metodo executa transferencia
                               (David).

                  23/04/2008 - Adaptacao para agendamentos (David).

                  03/11/2008 - Inclusao widget-pool (martin)

                  28/07/2009 - Alteracoes do Projeto de Transferencia para
                               Credito de Salario (David).

                  31/03/2011 - Ajustes devido agendamento no TAA (Henrique).

                  13/04/2011 - Inclusao de parametros na procedure
                               executa transferencia (Henrique)

                  05/08/2011 - Inclusao de parametro na executa transferencia
                               (Gabriel).

                  05/10/2011 - Adaptacao operadores internet (Guilherme).

                  09/01/2012 - Adicionado parametro idtitdda de entrada na
                               chamada da proc. cadastrar agendamento. (Jorge)

                  11/05/2012 - Projeto TED Internet (David).

                  04/03/2013 - Projeto transferencia intercooperativa (Gabriel).

                  22/07/2013 - Ajustes transferencia intercooperativa (Lucas).

                  18/08/2014 - Inlusao do Parametro par_dshistor (Vanessa)

                  04/11/2014 - (Chamado 161844)- Liberacao de agendamentos
                               para dia nao util. (Tiago Castro - RKAM)

                  17/12/2014 - Melhorias Cadastro de Favorecidos TED
                              (André Santos - SUPERO)

                  20/04/2015 - Inclusao do campo ISPB SD271603 FDR041 (Vanessa)

                  10/06/2015 - Conversão Progress -> Oracle SD285179 (Odirlei-AMcom)

                  17/07/2015 - Inclusão regra para mudar a data de agendamento
                               para o primeiro dia útil após a data programada.
                               Projeto Mobile (Dionathan)

                  28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                               da chamada é do mobile (Dionathan)

                  05/08/2015 - Adicionar parametro idtitdda na chamada da procedure
                               cria_transacao_operador da b1wgen0016.
                               (Douglas - Chamado 291387)

                  24/09/2015 - Realizado a inclusão do pr_nmdatela (Adriano - SD 328034).

                  17/11/2015 - Ajuste temporário para evitar agendamento de transferencia
                               quando for final de semana no app mobile. Chamado 356737.
                               (David).

                  09/12/2015 - Adicionado chamda da proc. pc_verifica_rep_assinatura, retornando informacoes
                              quanto a conta exigir Assinatura Conjunta entre outras informacoes.
                              (Jorge/David) Proj. 131 Assinatura Multipla

                  22/02/2016 - Tratamento para gravação de favorecido outras IFs na ted (Marcos-Supero)
                       Passagem dos novos campos na solicitacao da TED          (Marcos-Supero)

                  28/03/2016 - Tratamento para monitoração das TEDs PRJ118 (Odirlei-AMcom)

                  12/04/2016 - Remocao Aprovacao Favorecido. (Jaison/Marcos - SUPERO)

          19/05/2016 - Ajuste na mensagem de retorno para agendamentos
                   (Adriano - M117.)

                  03/06/2016 - Ajuste para chamar a rotina de monitoramento somente quando
                               operação de TED
                               (Adriano).

          06/09/2016 - Ajuste para apresentar o horario limite para debito de ted's agendadas
                               (Adriano - SD509480).

                  21/11/2016 - Inclusao de parametros na chamada da rotina pc_executa_envio_ted.
                               PRJ335 - Analise de fraudes (Odirlei-AMcom)

                  18/01/2016 - Ajustes mensagens de sucesso para TED.
                               PRJ335 - Analise de fraude (Odirlei-AMcom)

                  12/06/2017 - Alterar tipo do parametro pr_nrctatrf para varchar2 
                               referentes ao Novo Catalogo do SPB (Lucas Ranghetti #668207)
                               
                  10/07/2017 - Buscar ultimo horario da DEBNET para exibir o horario quando efetuado 
                               um agendamento de Transferencia (Lucas Ranghetti #676219)
    .................................................................................*/
    ----------------> TEMPTABLE  <---------------

    vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;
    vr_tab_erro       GENE0001.typ_tab_erro;  --> Tabela com erros
    vr_tab_agenda_recorrente      PAGA0002.typ_tab_agenda_recorrente;
    vr_tab_protocolo_ted          CXON0020.typ_tab_protocolo_ted;

    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_des_erro  VARCHAR2(10);
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

    vr_dstransa   VARCHAR2(500) := NULL;
    vr_dstrans1   VARCHAR2(500) := NULL;
    vr_dsprotoc   crappro.dsprotoc%TYPE := NULL;
    vr_vllanmto   NUMBER := 0;
    vr_lsdatagd   VARCHAR2(1000) := NULL;
    vr_dslinxml   VARCHAR2(4000);
    vr_msgaviso   VARCHAR2(1000) := NULL;
    vr_cdhiscre   craphis.cdhistor%TYPE;
    vr_cdhisdeb   craphis.cdhistor%TYPE;
    vr_nrdocdeb   craplcm.nrdocmto%TYPE;
    vr_nrdoccre   craplcm.nrdocmto%TYPE;
    vr_nrdocmto   craplcm.nrdocmto%TYPE;
    vr_cdlantar   craplcm.nrdocmto%TYPE;
    vr_dtmvtopg   DATE;
    vr_dtmvtmob   DATE;
    vr_flgctafa   BOOLEAN;
    vr_nmtitula   VARCHAR2(500);
    vr_nmtitul2   VARCHAR2(500);
    vr_intipcta   crapcti.intipcta%TYPE;
    vr_insitcta   crapcti.insitcta%TYPE;
    vr_inpessoa   crapcti.inpessoa%TYPE;
    vr_nrcpffav   crapcti.nrcpfcgc%TYPE;
    vr_cddbanco   INTEGER;
    vr_idastcjt   INTEGER(1);
    vr_nrcpfcgc   INTEGER;
    vr_nmprimtl   VARCHAR2(500);
    vr_flcartma   INTEGER(1);
  vr_msgofatr   VARCHAR2(500);
  vr_cdempcon   NUMBER;
  vr_cdsegmto   VARCHAR2(500);

    vr_cdcoptfn   NUMBER := 0;
    vr_cdagetfn   NUMBER := 0;
    vr_nrterfin   NUMBER := 0;

    vr_dscpfcgc   VARCHAR2(500);
    vr_nmdcampo   VARCHAR2(500);

    vr_vltarifa   NUMBER := 0;
    vr_hrfimpag   VARCHAR2(50);

    vr_assin_conjunta NUMBER(1);
    -----------> SubPrograma <------------
    -- Gerar log
    PROCEDURE pc_proc_geracao_log(pr_flgtrans IN INTEGER) IS

      vr_nrdrowid  ROWID;
      vr_nrctatrf  VARCHAR2(50);

    BEGIN

      IF pr_nrcpfope > 0  THEN
        vr_dstransa := vr_dstransa ||' - operador';
      END IF;

      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => pr_flgtrans
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Origem',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => CASE pr_flmobile
                                               WHEN 1 THEN 'MOBILE'
                                               ELSE 'INTERNETBANK'
                                                END);

      IF pr_nrcpfope > 0  THEN
        GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Operador'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
      END IF;

      -- se é log de sucesso
      IF pr_flgtrans = 1 THEN

        GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Tipo de transferencia'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => (CASE
                                          WHEN pr_tpoperac = 4 THEN 'TED'
                                          WHEN pr_cdtiptra IN (1,5) THEN 'Normal'
                                          ELSE 'Cred. Salario'
                                        END));

        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Banco Destino'
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(pr_cddbanco,'fm000'));

        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Agencia Destino'
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(pr_cdageban,'fm0000'));

        IF pr_tpoperac = 4 THEN
          vr_nrctatrf := TRIM(gene0002.fn_mask(pr_nrctatrf,'zzzzzzzzzzzzzzzzzzz.9'));
        ELSE
          vr_nrctatrf := TRIM(gene0002.fn_mask(pr_nrctatrf,'zzzz.zzz.9'));
        END IF;

        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Conta/dv Destino'
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => vr_nrctatrf);

        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Valor da Transferencia'
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(pr_vllanmto,'fm999G999G990D00'));

        -- se for agendamento
        IF pr_idagenda = 2 THEN
          GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Data do Agendamento'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => to_char(vr_dtmvtopg,'DD/MM/RRRR'));
        END IF;

        IF pr_idagenda = 3 THEN
          GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Agendamento recorrente'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => 'Dia '|| lpad(pr_ddagenda,2,'0')||
                                          ', '|| pr_qtmesagd ||' mes(es), inicio em '
                                              || pr_dtinicio);
        END IF;

        IF vr_dsprotoc IS NOT NULL THEN
          GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Protocolo'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => vr_dsprotoc);
        END IF;

        --Se conta exigir Assinatura Multipla
        IF vr_idastcjt = 1 THEN
           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'Nome do Representante/Procurador',
                                     pr_dsdadant => '',
                                     pr_dsdadatu => vr_nmprimtl);

           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CPF do Representante/Procurador',
                                     pr_dsdadant => '',
                                     pr_dsdadatu => TO_CHAR(gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1)));
        END IF;

      END IF;

    END pc_proc_geracao_log;

    -- Monta xml de agendamento recorresntes
    PROCEDURE pc_proc_agendamento_recorrente(pr_dslinxml OUT VARCHAR2,
                                             pr_dscritic OUT VARCHAR2 ) IS
      -- TempTable para armazenar as criticas sem repeti-las
      TYPE typ_tab_critica IS TABLE OF VARCHAR2(4000)
          INDEX BY VARCHAR2(4000);
      vr_tab_dscritic typ_tab_critica;

      vr_dslinxml_desaprov VARCHAR2(32000) := NULL;
      vr_dslinxml_aprov    VARCHAR2(32000) := NULL;
      vr_exiscrit          VARCHAR2(50)   := 'no';
      vr_idxcriti          VARCHAR2(4000) := NULL;

    BEGIN
      -- varrer temptable apenas se encontrar algum registro
      IF vr_tab_agenda_recorrente.count > 0 THEN
        FOR vr_idx IN vr_tab_agenda_recorrente.first..vr_tab_agenda_recorrente.last LOOP

          -- se for erro, guardar as criticas e montar o xml dos desaprovados
          IF vr_tab_agenda_recorrente(vr_idx).flgtrans = FALSE THEN

            IF vr_tab_agenda_recorrente(vr_idx).dscritic IS NOT NULL THEN
              -- guardar criticas na temp table como index para não repetir a critica
              vr_tab_dscritic(vr_tab_agenda_recorrente(vr_idx).dscritic) := vr_tab_agenda_recorrente(vr_idx).dscritic;
            END IF;
            -- montar desaprovados
            vr_dslinxml_desaprov := vr_dslinxml_desaprov||
                                   '<AGENDAMENTO>'||
                                     '<dtmvtopg>' ||to_char(vr_tab_agenda_recorrente(vr_idx).dtmvtopg,'DD/MM/RRRR') ||'</dtmvtopg>'||
                                     '<dtpagext>' || vr_tab_agenda_recorrente(vr_idx).dtpagext ||'</dtpagext>'||
                                     '<dscritic>' || vr_tab_agenda_recorrente(vr_idx).dscritic ||'</dscritic>'||
                                   '</AGENDAMENTO>';
          END IF;

          -- inicializar variavel
          vr_exiscrit := 'no';

          -- Montar xml dos aprovados
          IF vr_tab_agenda_recorrente(vr_idx).flgtrans = TRUE THEN
            -- Verificar se existe um aprovado que contenha critica
            IF vr_tab_agenda_recorrente(vr_idx).dscritic IS NOT NULL THEN
              vr_exiscrit := 'yes';
            END IF;

            -- montar aprovados
            vr_dslinxml_aprov := vr_dslinxml_aprov||
                                 '<AGENDAMENTO>' ||
                                   '<dtmvtopg>' ||to_char(vr_tab_agenda_recorrente(vr_idx).dtmvtopg,'DD/MM/RRRR') ||'</dtmvtopg>'||
                                   '<dtpagext>' || vr_tab_agenda_recorrente(vr_idx).dtpagext ||'</dtpagext>'||
                                   '<dscritic>' || vr_tab_agenda_recorrente(vr_idx).dscritic ||'</dscritic>'||
                                 '</AGENDAMENTO>';

            -- Guardar lista de datas
            IF vr_lsdatagd IS NULL THEN
              vr_lsdatagd := to_char(vr_tab_agenda_recorrente(vr_idx).dtmvtopg,'DD/MM/RRRR');
            ELSE
              vr_lsdatagd := vr_lsdatagd ||','||
                             to_char(vr_tab_agenda_recorrente(vr_idx).dtmvtopg,'DD/MM/RRRR');
            END IF;
          END IF;
        END LOOP;

        -- Se nao encontrou nenum aprovado
        IF vr_dslinxml_aprov IS NULL THEN
          vr_dscritic := NULL;
          -- retornar apenas as criticas
          vr_idxcriti := vr_tab_dscritic.first;
          WHILE vr_idxcriti IS NOT NULL LOOP
            -- inluir caracter de quebra de linha
            IF vr_dscritic IS NULL THEN
              pr_dscritic := vr_idxcriti;
            ELSE
              pr_dscritic := vr_dscritic||'\n'||vr_idxcriti;
            END IF;
            -- buscar proxima critica
            vr_idxcriti := vr_tab_dscritic.next(vr_idxcriti);
          END LOOP;

          -- apos montar a lista de criticas, abortar programa
          RAISE vr_exc_erro;

        END IF;

      END IF;

      -- Montar xml completo
      pr_dslinxml := pr_dslinxml ||'<AGENDAMENTOS flginfor="'||vr_exiscrit||'"><APROVADOS>'||
                     vr_dslinxml_aprov ||
                     '</APROVADOS><DESAPROVADOS>' ||
                     vr_dslinxml_desaprov ||
                     '</DESAPROVADOS></AGENDAMENTOS>';

    EXCEPTION
      WHEN vr_exc_erro THEN
        NULL; -- apenas repassar a critica
      WHEN OTHERS THEN

        pc_internal_exception(pr_cdcooper);

        pr_dscritic := 'Nao foi possivel montar xml de agendamentos recorrentes: '||SQLERRM;
    END pc_proc_agendamento_recorrente;

    -- incluir favorecido
    PROCEDURE pc_grava_favorito(pr_dscritic OUT VARCHAR2) IS
    BEGIN

      IF pr_tpoperac = 4  THEN /** TED **/

        vr_nmtitula := pr_nmtitula;
        vr_intipcta := pr_intipcta;
        vr_inpessoa := pr_inpessoa;
        vr_nrcpffav := pr_nrcpfcgc;

        -- Chamar a rotina valida-inclusao-conta-transferencia convertida da Bo15
        CADA0002.pc_val_inclui_conta_transf(pr_cdcooper => pr_cdcooper
                                           ,pr_cdagenci => 90
                                           ,pr_nrdcaixa => 900
                                           ,pr_cdoperad => '996'
                                           ,pr_nmdatela => 'INTERNETBANK'
                                           ,pr_idorigem => 3
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_flgerlog => 1 /*TRUE*/
                                           ,pr_cddbanco => pr_cddbanco
                                           ,pr_cdispbif => pr_cdispbif
                                           ,pr_cdageban => pr_cdageban
                                           ,pr_nrctatrf => pr_nrctatrf
                                           ,pr_intipdif => 2
                                           ,pr_intipcta => vr_intipcta
                                           ,pr_insitcta => 2
                                           ,pr_inpessoa => vr_inpessoa
                                           ,pr_nrcpfcgc => vr_nrcpffav
                                           ,pr_flvldinc => 1
                                           ,pr_rowidcti => NULL
                                           ,pr_nmtitula => vr_nmtitula
                                           ,pr_dscpfcgc => vr_dscpfcgc
                                           ,pr_nmdcampo => vr_nmdcampo
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);


        /* Desconsiderar critica de Favorecido ja cadastrado */
        IF (NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL) AND NVL(vr_cdcritic,0) <> 979 THEN
           IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
              pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           ELSE
             pr_dscritic := vr_dscritic;
           END IF;
        END IF;

        /* Não chamar a inclusao se favorecido jah cadastrado */
        IF NVL(vr_cdcritic,0) <> 979 THEN
          -- Se tudo corer bem com a validação:
          -- Chamar a rotina para inclusão do favorecido
          CADA0002.pc_inclui_conta_transf
                              (pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                              ,pr_cdagenci => 90             --> Codigo da agencia
                              ,pr_nrdcaixa => 900            --> Numero do caixa
                              ,pr_cdoperad => '996'          --> Cod. do operador
                              ,pr_nmdatela => 'INTERNETBANK' --> Nome da tela
                              ,pr_idorigem => 3              --> Identificador de origem
                              ,pr_nrdconta => pr_nrdconta    --> Numero da conta
                              ,pr_idseqttl => pr_idseqttl    --> Seq. do titular
                              ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                              ,pr_nrcpfope => pr_nrcpfope    --> CPF operador juridico
                              ,pr_flgerlog => 1 /*TRUE*/     --> flg geracao log
                              ,pr_cddbanco => pr_cddbanco    --> Codigo do banco destino
                              ,pr_cdageban => pr_cdageban    --> Agencia destino
                              ,pr_nrctatrf => pr_nrctatrf    --> Nr. conta transf
                              ,pr_nmtitula => pr_nmtitula    --> Nome titular
                              ,pr_nrcpfcgc => pr_nrcpfcgc    --> CPF titulat
                              ,pr_inpessoa => pr_inpessoa    --> Tipo pessoa
                              ,pr_intipcta => pr_intipcta    --> Tipo de conta
                              ,pr_intipdif => 2              --> tipo de inst. financeira da conta (Outras)
                              ,pr_rowidcti => NULL           --> Recid da cta transf
                              ,pr_cdispbif => pr_cdispbif    --> Oito primeiras posicoes do cnpj.
                              -- OUT
                              ,pr_msgaviso => vr_msgaviso    --> Mensagem de aviso
                              ,pr_des_erro => vr_des_erro    --> Indicador se retornou com erro (OK ou NOK)
                              ,pr_cdcritic => vr_cdcritic    --> Codigo da critica
                              ,pr_dscritic => pr_dscritic);  --> Descricao da critica

          IF vr_des_erro <> 'OK' THEN
            IF TRIM(pr_dscritic) IS NULL  THEN
              pr_dscritic := 'Erro na inclusao da conta favorita.';
            END IF;
          END IF;

          IF vr_des_erro <> 'OK' THEN
            IF TRIM(pr_dscritic) IS NULL  THEN
              pr_dscritic := 'Erro na inclusao da conta favorita.';
        END IF;
          END IF;

        END IF;

      ELSE

      /* Validar a conta de destino da transferencia */
      INET0001.pc_valida_conta_destino ( pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                        ,pr_cdagenci => 90          --Agencia do Associado
                                        ,pr_nrdcaixa => 900         --Numero caixa
                                        ,pr_cdoperad => '996'       --Codigo Operador
                                        ,pr_nrdconta => pr_nrdconta --Numero da conta
                                        ,pr_idseqttl => pr_idseqttl --Identificador Sequencial titulo
                                        ,pr_cdagectl => pr_cdageban --Codigo Agencia
                                        ,pr_nrctatrf => pr_nrctatrf --Numero Conta Transferencia
                                        ,pr_dtmvtolt => pr_dtmvtolt --Data Movimento
                                        ,pr_cdtiptra => pr_cdtiptra --Tipo de Transferencia
                                        ,pr_flgctafa => vr_flgctafa --Indicador conta cadastrada
                                        ,pr_nmtitula => vr_nmtitula --Nome titular
                                        ,pr_nmtitul2 => vr_nmtitul2 --Nome segundo titular
                                        ,pr_cddbanco => vr_cddbanco --Codigo banco
                                        ,pr_dscritic => vr_des_erro --Retorno OK/NOK
                                        ,pr_tab_erro => vr_tab_erro); --Tabela de retorno de erro

      IF vr_des_erro <> 'OK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          pr_dscritic := 'Erro na validacao da conta destino.';
        END IF;
        -- se retornou critica deve abortar processo
        RETURN;
      END IF;

      IF  NOT vr_flgctafa  THEN
        CADA0002.pc_inclui_conta_transf
                         (pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                         ,pr_cdagenci => 90             --> Codigo da agencia
                         ,pr_nrdcaixa => 900            --> Numero do caixa
                         ,pr_cdoperad => '996'          --> Cod. do operador
                         ,pr_nmdatela => 'INTERNETBANK' --> Nome da tela
                         ,pr_idorigem => 3              --> Identificador de origem
                         ,pr_nrdconta => pr_nrdconta    --> Numero da conta
                         ,pr_idseqttl => pr_idseqttl    --> Seq. do titular
                         ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                         ,pr_nrcpfope => 0              --> CPF operador juridico
                         ,pr_flgerlog => 1 /*TRUE*/     --> flg geracao log
                         ,pr_cddbanco => pr_cddbanco    --> Codigo do banco destino
                         ,pr_cdageban => pr_cdageban    --> Agencia destino
                         ,pr_nrctatrf => pr_nrctatrf    --> Nr. conta transf
                         ,pr_nmtitula => NULL           --> Nome titular
                         ,pr_nrcpfcgc => 0              --> CPF titulat
                         ,pr_inpessoa => 0              --> Tipo pessoa
                         ,pr_intipcta => 1              --> Tipo de conta
                         ,pr_intipdif => 1              --> tipo de inst. financeira da conta
                         ,pr_rowidcti => NULL           --> Recid da cta transf
                         ,pr_cdispbif => pr_cdispbif    --> Oito primeiras posicoes do cnpj.
                         -- OUT
                         ,pr_msgaviso => vr_msgaviso    --> Mensagem de aviso
                         ,pr_des_erro => vr_des_erro    --> Indicador se retornou com erro (OK ou NOK)
                           ,pr_cdcritic => vr_cdcritic    --> Codigo da critica
                           ,pr_dscritic => pr_dscritic);  --> Descricao da critica

        IF vr_des_erro <> 'OK' THEN
            IF TRIM(pr_dscritic) IS NULL  THEN
            pr_dscritic := 'Erro na inclusao da conta favorita.';
          END IF;
        END IF;
      END IF;
      END IF;
    END pc_grava_favorito;



  BEGIN
    -- Definir descrição da transação
    SELECT DECODE(pr_flgexecu,1,NULL,'Valida ')||
           DECODE(pr_idagenda,1,NULL,'Agendamento para ')||
           DECODE(pr_tpoperac,4,'Transferencia de TED','Transferencia de Valores')
    INTO vr_dstransa
    FROM dual;

    vr_cdcritic := 0;
    vr_dscritic := NULL;
    vr_dtmvtopg := pr_dtmvtopg;

    INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --Verifica se conta for conta PJ e se exige asinatura multipla
    INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdorigem => 3
                                       ,pr_idastcjt => vr_idastcjt
                                       ,pr_nrcpfcgc => vr_nrcpfcgc
                                       ,pr_nmprimtl => vr_nmprimtl
                                       ,pr_flcartma => vr_flcartma
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;

    /** Agendamento recorrente **/
    IF pr_idagenda = 3 THEN

      /* Procedure para validar agendamento recorrente */
      PAGA0002.pc_verif_agend_recorrente
                                (pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                ,pr_cdagenci => 90          --> Codigo da agencia
                                ,pr_nrdcaixa => 900         --> Numero do caixa
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do cooperado
                                ,pr_idseqttl => pr_idseqttl --> Sequencial do titular
                                ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento
                                ,pr_ddagenda => pr_ddagenda --> Dia de agendamento
                                ,pr_qtmesagd => pr_qtmesagd --> Quantidade de meses
                                ,pr_dtinicio => pr_dtinicio --> Data inicial
                                ,pr_vllanmto => pr_vllanmto --> Valor do lancamento automatico
                                ,pr_cddbanco => pr_cddbanco --> Codigo do banco
                                ,pr_cdageban => pr_cdageban --> Codigo de agencia bancaria
                                ,pr_nrctatrf => pr_nrctatrf --> Numero da conta destino
                                ,pr_cdtiptra => pr_cdtiptra --> Tipo de transação
                                ,pr_lsdatagd => pr_lsdatagd --> lista de datas agendamento
                                ,pr_cdoperad => '996'       --> Codigo do operador
                                ,pr_tpoperac => pr_tpoperac --> tipo de operação
                                ,pr_dsorigem => 'INTERNET'  --> Descrição de origem do registro
                                ,pr_nrcpfope => (CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN nvl(vr_nrcpfcgc,pr_nrcpfope) ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do representante legal quando conta exigir assinatura multipla
                                ,pr_nmdatela => 'INTERNETBANK' --> Nome da tela
                                /* parametros de saida */
                                ,pr_dstransa => vr_dstrans1 --> descrição de transação
                                ,pr_tab_agenda_recorrente => vr_tab_agenda_recorrente  --> Registros de agendamento recorrentes
                                ,pr_cdcritic => vr_cdcritic --> codigo de criticas
                                ,pr_dscritic => vr_dscritic);--> Descricao critica


      IF (nvl(vr_cdcritic,0) <> 0 OR
        TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

      IF pr_flgexecu = 0 THEN
        FOR vr_idxp IN vr_tab_agenda_recorrente.first..vr_tab_agenda_recorrente.last LOOP
          vr_vltarifa := vr_vltarifa + vr_tab_agenda_recorrente(vr_idxp).vltarifa;
          EXIT;
        END LOOP;
      END IF;

    ELSE
      vr_vllanmto := pr_vllanmto;

      -- Procedure para validar limites para transacoes (Transf./Pag./Cob.)
      INET0001.pc_verifica_operacao
                           (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                           ,pr_cdagenci     => 90                  --> Agencia do Associado
                           ,pr_nrdcaixa     => 900                 --> Numero caixa
                           ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                           ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                           ,pr_dtmvtolt     => pr_dtmvtolt         --> Data Movimento
                           ,pr_idagenda     => pr_idagenda         --> Indicador agenda
                           ,pr_dtmvtopg     => pr_dtmvtopg         --> Data Pagamento
                           ,pr_vllanmto     => vr_vllanmto         --> Valor Lancamento
                           ,pr_cddbanco     => pr_cddbanco        --> Codigo banco
                           ,pr_cdageban     => pr_cdageban        --> Codigo Agencia
                           ,pr_nrctatrf     => pr_nrctatrf        --> Numero Conta Transferencia
                           ,pr_cdtiptra     => pr_cdtiptra        --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                           ,pr_cdoperad     => 996                --> Codigo Operador
                           ,pr_tpoperac     => pr_tpoperac        --> 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                           ,pr_flgvalid     => TRUE               --> Indicador validacoes
                           ,pr_dsorigem     => 'INTERNET'         --> Descricao Origem
                           ,pr_nrcpfope     => nvl(pr_nrcpfope,0)--(CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN nvl(vr_nrcpfcgc,0) ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do representante legal quando conta exigir assinatura multipla
                           ,pr_flgctrag     => TRUE               --> controla validacoes na efetivacao de agendamentos */
                           ,pr_nmdatela     => 'INTERNETBANK'     --> Nome da tela/programa que esta chamando a rotina
                           ,pr_dstransa     => vr_dstrans1        --> Descricao da transacao
                           ,pr_tab_limite   => vr_tab_limite      --> Tabelas de retorno de horarios limite
                           ,pr_tab_internet => vr_tab_internet    --> Tabelas de retorno de horarios limite
                           ,pr_cdcritic     => vr_cdcritic        --> Codigo do erro
                           ,pr_dscritic     => vr_dscritic        --> Descricao do erro
                           ,pr_assin_conjunta => vr_assin_conjunta); --> Varia      

      IF (nvl(vr_cdcritic,0) <> 0 OR
        TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

      vr_vltarifa := vr_vllanmto - pr_vllanmto;

    END IF; -- FIM IF pr_idagenda = 3

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

      -- Se nao retornou erro, validar dados TED
    IF pr_tpoperac = 4 AND /** TED **/
       pr_flgexecu = 0 THEN

        CXON0020.pc_verifica_dados_ted
                          (pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                          ,pr_cdagenci => 90           --> Codigo Agencia
                          ,pr_nrdcaixa => 900          --> Numero do caixa
                          ,pr_idorigem => 3            --> Identificador de origem
                          ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                          ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                          ,pr_cddbanco => pr_cddbanco  --> Codigo do banco
                          ,pr_cdageban => pr_cdageban  --> Codigo da agencia bancaria
                          ,pr_nrctatrf => pr_nrctatrf  --> numero da conta transferencia destino
                          ,pr_nmtitula => pr_nmtitula  --> Nome do titular
                          ,pr_nrcpfcgc => pr_nrcpfcgc  --> Numero do cpf/cnpj do titular destino
                          ,pr_inpessoa => pr_inpessoa  --> Identificador de tipo de pessoa
                          ,pr_intipcta => pr_intipcta  --> identificador de tipo de conta
                          ,pr_vllanmto => pr_vllanmto  --> Valor do lançamento
                          ,pr_cdfinali => pr_cdfinali  --> Codigo de finalidade
                          ,pr_dshistor => pr_dshistor  --> Descriçao de historico
                          ,pr_cdispbif => pr_cdispbif  --> Oito primeiras posicoes do cnpj.
                            ,pr_idagenda => pr_idagenda  --> Indicador de agenda
                          /* parametros de saida */
                          ,pr_dstransa => vr_dstrans1  --> Descrição de transação
                          ,pr_cdcritic => vr_cdcritic  --> Codigo do erro
                          ,pr_dscritic => vr_dscritic);--> Descricao do erro

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    END IF;

    --> Montar xml de retorno dos dados <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_operacao22, TRUE);
    dbms_lob.open(pr_xml_operacao22, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao22
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => ' ');


    /** Indica se deve efetuar somente a validacao dos dados **/
    IF pr_flgexecu = 0 /* false */  THEN

      -- Verificar se a data é um dia util, caso não ser, retorna o proximo dia
      vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                 pr_dtmvtolt  => vr_dtmvtopg,
                                                 pr_tipo      => 'P',
                                                 pr_feriado   => TRUE);

      IF pr_idagenda = 3 THEN
        -- Montar xml com os agendamentos
        pc_proc_agendamento_recorrente(pr_dslinxml => vr_dslinxml,
                                       pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Solução temporária para item 1. do chamado 356737
      -- Se a data retornada no XML é maior que a data do dispostivo, a operação é convertida para agendamento
      -- Retornar data selecinada no app para a operação não seja agendada
      IF pr_flmobile = 1  AND  -- App Mobile
         pr_idagenda = 1  AND  -- Débito Nesta Data
         pr_tpoperac <> 4 AND  -- Somente Transferência
         pr_dshistor IS NOT NULL THEN
         BEGIN
           vr_dtmvtmob := TO_DATE(pr_dshistor,'dd/mm/RRRR');
         EXCEPTION
           WHEN OTHERS THEN
             vr_dtmvtmob := vr_dtmvtopg;
         END;

         --> Montar xml de retorno dos dados <---
         gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao22
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_fecha_xml      => TRUE
                                ,pr_texto_novo     => '<DADOS_TRANSF>'||
                                                         '<dttransa>'||to_char(trunc(SYSDATE),'DD/MM/RRRR')||'</dttransa>'||
                                                         '<dtmvtopg>'||to_char(vr_dtmvtmob,'DD/MM/RRRR') ||'</dtmvtopg>'||
                                                         '<dsmsginf>'||vr_dscritic ||'</dsmsginf>'||
                                                         '<lsdatagd>'||vr_lsdatagd ||'</lsdatagd>'||
                                                         '<vltarifa>'|| to_char(vr_vltarifa,'fm999G999G990D00') ||'</vltarifa>'||
                                                       '</DADOS_TRANSF>'|| vr_dslinxml);
      ELSE
         --> Montar xml de retorno dos dados <---
         gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao22
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_fecha_xml      => TRUE
                                ,pr_texto_novo     => '<DADOS_TRANSF>'||
                                                         '<dttransa>'||to_char(trunc(SYSDATE),'DD/MM/RRRR')||'</dttransa>'||
                                                         '<dtmvtopg>'||to_char(vr_dtmvtopg,'DD/MM/RRRR') ||'</dtmvtopg>'||
                                                         '<dsmsginf>'||vr_dscritic ||'</dsmsginf>'||
                                                         '<lsdatagd>'||vr_lsdatagd ||'</lsdatagd>'||
                                                         '<vltarifa>'|| to_char(vr_vltarifa,'fm999G999G990D00') ||'</vltarifa>'||
                                                       '</DADOS_TRANSF>'|| vr_dslinxml);
      END IF;

      -- Se for Validação de TED/Transferência, cria um registro na CRAPMVI com os valores zerados
      -- Isto foi implementado pois o Cecred Mobile executa as transferências em lote em threads assíncronas
      -- e, as  vezes, duas threads tentavam criar o registro ao mesmo tempo em conflito, ocorrendo erro de UK
      BEGIN
        INSERT INTO crapmvi
            (cdcooper
            ,nrdconta
            ,dtmvtolt
            ,cdoperad
            ,dttransa
            ,hrtransa
            ,vlmovweb
            ,idseqttl
            ,vlmovtrf
            ,vlmovpgo
            ,vlmovted)
          VALUES
            (pr_cdcooper
            ,pr_nrdconta
            ,pr_dtmvtolt
            ,'996'
            ,TRUNC(SYSDATE)
            ,gene0002.fn_busca_time
            ,0
            ,pr_idseqttl
            ,0
            ,0
            ,0);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

      -- sair do programa com OK
      pr_dsretorn := 'OK';
      RETURN;
    END IF;
     -- 397
     --    IF pr_nrcpfope > 0 OR vr_idastcjt = 1 THEN
    /* Efetuada por operador ou responsável de assinatura conjunta de conta PJ */

      IF vr_assin_conjunta = 1 THEN
      /* Se deseja gravar favorito */
      IF pr_gravafav = 1 THEN
        pc_grava_favorito(pr_dscritic => vr_dscritic);
        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- TED
      IF pr_cdtiptra = 4 THEN
         --Cria transacao pendente de TED

         INET0002.pc_cria_trans_pend_ted( pr_cdagenci => 90             --> Codigo do PA
                                         ,pr_nrdcaixa => 900            --> Numero do Caixa
                                         ,pr_cdoperad => '996'          --> Codigo do Operados
                                         ,pr_nmdatela => 'INTERNETBANK' --> Nome da Tela
                                         ,pr_idorigem => 3              --> Origem da solicitacao
                                         ,pr_idseqttl => pr_idseqttl    --> Sequencial de Titular
                                         ,pr_nrcpfope => pr_nrcpfope    --> Numero do cpf do operador juridico
                                         ,pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
                                         ,pr_cdcoptfn => vr_cdcoptfn    --> Cooperativa do Terminal
                                         ,pr_cdagetfn => vr_cdagetfn    --> Agencia do Terminal
                                         ,pr_nrterfin => vr_nrterfin    --> Numero do Terminal Financeiro
                                         ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                                         ,pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                                         ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                                         ,pr_vllanmto => pr_vllanmto    --> Valor do pagamento
                                         ,pr_nrcpfcnpj=> pr_nrcpfcgc    --> CPF/CNPJ do Favorecido
                                         ,pr_nmtitula => pr_nmtitula    --> Nome to Titular Favorecido
                                         ,pr_tppessoa => pr_inpessoa    --> Tipo de pessoa do Favorecido
                                         ,pr_tpconta  => pr_intipcta    --> Tipo da conta do Favorecido
                                         ,pr_dtmvtopg => pr_dtmvtopg    --> Data do debito
                                         ,pr_idagenda => pr_idagenda    --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                         ,pr_cddbanco => pr_cddbanco    --> Codigo do banco
                                         ,pr_cdageban => pr_cdageban    --> Codigo da agencia bancaria
                                         ,pr_nrctadst => pr_nrctatrf    --> Conta de destino
                                         ,pr_cdfinali => pr_cdfinali    --> Codigo da finalidade
                                         ,pr_dstransf => pr_dstransf    --> Descricao da transferencia
                                         ,pr_dshistor => pr_dshistor    --> Descricao do historico
                                         ,pr_nrispbif => pr_cdispbif    --> Codigo unico do banco
                                         ,pr_idastcjt => vr_idastcjt    --> Indicador que exige Assinatura Multipla
                                         ,pr_lsdatagd => pr_lsdatagd    --> Lista de datas para agen
                                         ,pr_cdcritic => vr_cdcritic    --> Codigo de Critica
                                         ,pr_dscritic => vr_dscritic);  --> Descricao de Critica

         -- Verificar se retornou critica
         IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           -- se possui codigo, porém não possui descrição
           IF nvl(vr_cdcritic,0) > 0 AND
              TRIM(vr_dscritic) IS NULL THEN
             -- buscar descrição
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           END IF;
           vr_dscritic := vr_dscritic||' - '||pr_nrctatrf;

           -- Se retornou critica , deve abortar
           RAISE vr_exc_erro;
         END IF;


      ELSE--Transferencia
         --Cria transacao pendente de Transferencia
         INET0002.pc_cria_trans_pend_transf(pr_cdtiptra => pr_cdtiptra     --> Tipo da Transacao
                                           ,pr_cdagenci => 90              --> Codigo do PA
                                           ,pr_nrdcaixa => 900             --> Numero do Caixa
                                           ,pr_cdoperad => '996'           --> Codigo do Operados
                                           ,pr_nmdatela => 'INTERNETBANK'  --> Nome da Tela
                                           ,pr_idorigem => 3               --> Origem da solicitacao
                                           ,pr_idseqttl => pr_idseqttl     --> Sequencial de Titular
                                           ,pr_nrcpfope => pr_nrcpfope     --> Numero do cpf do operador juridico
                                           ,pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
                                           ,pr_cdcoptfn => vr_cdcoptfn     --> Cooperativa do Terminal
                                           ,pr_cdagetfn => vr_cdagetfn     --> Agencia do Terminal
                                           ,pr_nrterfin => vr_nrterfin     --> Numero do Terminal Financeiro
                                           ,pr_dtmvtolt => pr_dtmvtolt     --> Data do movimento
                                           ,pr_cdcooper => pr_cdcooper     --> Codigo da cooperativa
                                           ,pr_nrdconta => pr_nrdconta     --> Numero da Conta
                                           ,pr_vllanmto => pr_vllanmto     --> Valor de Lancamento
                                           ,pr_dtmvtopg => pr_dtmvtopg     --> Data do Pagamento
                                           ,pr_idagenda => pr_idagenda     --> Indicador de agendamento
                                           ,pr_cdageban => pr_cdageban     --> Codigo da agencia bancaria
                                           ,pr_nrctadst => pr_nrctatrf     --> Conta de destino
                                           ,pr_lsdatagd => pr_lsdatagd     --> Lista de datas para agendamento
                                           ,pr_idastcjt => vr_idastcjt     --> Indicador de Assinatura Conjunta
                                           ,pr_flmobile => pr_flmobile     --> Indicador Mobile
                                           ,pr_idtipcar => 0               --> Indicador Tipo Cartão Utilizado
                                           ,pr_nrcartao => 0               --> Numero Cartao
                                           ,pr_cdcritic => vr_cdcritic     --> Codigo de Critica
                                           ,pr_dscritic => vr_dscritic);   --> Descricao de Critica

         -- Verificar se retornou critica
         IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           -- se possui codigo, porém não possui descrição
           IF nvl(vr_cdcritic,0) > 0 AND
              TRIM(vr_dscritic) IS NULL THEN
             -- buscar descrição
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           END IF;
           vr_dscritic := vr_dscritic||' - '||pr_nrctatrf;

           -- Se retornou critica , deve abortar
           RAISE vr_exc_erro;
         END IF;
      END IF;

      -- Se for TED
      IF pr_cdtiptra = 4 THEN
        vr_dscritic := 'Transação(ões) registrada(s) com sucesso. Aguardando aprovação do(s) preposto(s).';
      ELSE
        IF vr_idastcjt = 1 THEN
            vr_dscritic := (CASE WHEN pr_cdtiptra = 3 THEN 'Credito de salario registrado'
                                 ELSE 'Transferencia registrada' END) ||
                       ' com sucesso. ' ||
                       'Aguardando aprovacao do registro pelos demais responsaveis.';
        ELSE
            vr_dscritic := (CASE WHEN pr_cdtiptra = 3 THEN 'Credito de salario registrado'
                                 ELSE 'Transferencia registrada' END) ||
                       ' com sucesso. ' ||
                       'Aguardando efetivacao do registro pelo preposto.';
        END IF;

        IF pr_idagenda > 1 THEN
          vr_dscritic := 'Agendamento de ' || vr_dscritic;
        END IF;

      END IF;

    ELSIF pr_idagenda = 1 THEN /** Transferencia no dia corrente **/

      /* Se deseja gravar favorito */
      IF pr_gravafav = 1 THEN
        pc_grava_favorito(pr_dscritic => vr_dscritic);
        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;


      IF pr_tpoperac = 4 THEN /** TED **/
        --> Procedure para executar o envio da TED
        CXON0020.pc_executa_envio_ted
                          (pr_cdcooper => pr_cdcooper  --> Cooperativa
                          ,pr_cdagenci => 90           --> Agencia
                          ,pr_nrdcaixa => 900          --> Caixa Operador
                          ,pr_cdoperad => 996          --> Operador Autorizacao
                          ,pr_idorigem => 3            --> Origem
                          ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                          ,pr_nrdconta => pr_nrdconta  --> Conta Remetente
                          ,pr_idseqttl => pr_idseqttl  --> Titular
                          ,pr_nrcpfope => pr_nrcpfope  --> CPF operador juridico
                          ,pr_cddbanco => pr_cddbanco  --> Banco destino
                          ,pr_cdageban => pr_cdageban  --> Agencia destino
                          ,pr_nrctatrf => pr_nrctatrf  --> Conta transferencia
                          ,pr_nmtitula => pr_nmtitula  --> nome do titular destino
                          ,pr_nrcpfcgc => pr_nrcpfcgc  --> CPF do titular destino
                          ,pr_inpessoa => pr_inpessoa  --> Tipo de pessoa
                          ,pr_intipcta => pr_intipcta  --> Tipo de conta
                          ,pr_vllanmto => pr_vllanmto  --> Valor do lançamento
                          ,pr_dstransf => pr_dstransf  --> Identificacao Transf.
                          ,pr_cdfinali => pr_cdfinali  --> Finalidade TED
                          ,pr_dshistor => pr_dshistor  --> Descriçao do Histórico
                          ,pr_cdispbif => pr_cdispbif  --> ISPB Banco Favorecido=
                          ,pr_flmobile => pr_flmobile  --> Indicador se origem é do mobile
                          ,pr_idagenda => pr_idagenda  --> Tipo de agendamento
                          ,pr_iptransa => pr_iptransa  --> IP da transacao no IBank/mobile
                          ,pr_dstransa => vr_dstransa  --> Descrição da transacao no IBank/mobile
                          -- saida
                          ,pr_dsprotoc => vr_dsprotoc  --> Retorna protocolo
                          ,pr_tab_protocolo_ted => vr_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic => vr_cdcritic  --> Codigo do erro
                          ,pr_dscritic => vr_dscritic);--> Descricao do erro

      ELSE

        /* Intracooperativa */
        IF pr_tpoperac = 1 THEN
          --Executar rotina verifica-historico-transferencia
          PAGA0001.pc_verifica_historico_transf
                                       (pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --> Conta associado
                                       ,pr_nrctatrf => pr_nrctatrf   --> Conta destino
                                       ,pr_cdorigem => 3             --> Identificador Origem
                                       ,pr_cdtiptra => pr_cdtiptra   --> Tipo transacao
                                       ,pr_cdhiscre => vr_cdhiscre   --> Historico Credito
                                       ,pr_cdhisdeb => vr_cdhisdeb   --> Historico Debito
                                       ,pr_cdcritic => vr_cdcritic   --> Código do erro
                                       ,pr_dscritic => vr_dscritic); --> Descricao do erro

           --Executar rotina verifica-historico-transferencia
           PAGA0001.pc_executa_transferencia
                                    (pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                                    ,pr_dtmvtolt => TRUNC(SYSDATE) --> Data Movimento
                                    ,pr_dtmvtocd => pr_dtmvtolt    --> Data Credito
                                    ,pr_cdagenci => 90             --> Codigo Agencia
                                    ,pr_cdbccxlt => 11             --> Codigo Banco/Caixa
                                    ,pr_nrdolote => 11900          --> Numero Lote
                                    ,pr_nrdcaixa => 900            --> Numero da Caixa
                                    ,pr_nrdconta => pr_nrdconta    --> Numero da conta
                                    ,pr_idseqttl => pr_idseqttl    --> Sequencial titulo
                                    ,pr_nrdocmto => 0              --> Numero documento
                                    ,pr_cdhiscre => vr_cdhiscre    --> Historico Credito
                                    ,pr_cdhisdeb => vr_cdhisdeb    --> Historico Debito
                                    ,pr_vllanmto => pr_vllanmto    --> Valor Lancamento
                                    ,pr_cdoperad => '996'          --> Codigo Operador
                                    ,pr_nrctatrf => pr_nrctatrf    --> Numero conta transferencia
                                    ,pr_flagenda => FALSE          --> Flag agendado
                                    ,pr_cdcoptfn => 0              --> Codigo cooperativa transf
                                    ,pr_cdagetfn => 0              --> Codigo agencia transf
                                    ,pr_nrterfin => 0              --> Numero terminal
                                    ,pr_dscartao => NULL           --> Descricao do cartao
                                    ,pr_cdorigem => 3              --> Codigo da Origem
                                    ,pr_nrcpfope => pr_nrcpfope    --> CPF operador
                                    ,pr_flmobile => pr_flmobile    --> Indicador Mobile
                                    ,pr_idtipcar => 0              --> Indicador Tipo Cartão Utilizado
                                    ,pr_nrcartao => 0              --> Numero Cartao
                                    ,pr_dstransa => vr_dstrans1    --> Descricao transacao
                                    ,pr_nrdocdeb => vr_nrdocdeb    --> Numero documento debito
                                    ,pr_nrdoccre => vr_nrdoccre    --> Numero documento credito
                                    ,pr_dsprotoc => vr_dsprotoc    --> Descricao protocolo
                                    ,pr_cdcritic => vr_cdcritic    --> Codigo do erro
                                    ,pr_dscritic => vr_dscritic);  --> Descricao do erro
         ELSE
           /* Executar transferencia intercooperativa */
           PAGA0001.pc_executa_transf_intercoop
                                       (pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                                       ,pr_cdagenci => 90           --> Codigo Agencia
                                       ,pr_nrdcaixa => 900          --> Numero da Caixa
                                       ,pr_cdoperad => '996'        --> Codigo Operador
                                       ,pr_idorigem => 3            --> Codigo da Origem
                                       ,pr_dtmvtolt => pr_dtmvtolt  --> Data Movimento
                                       ,pr_idagenda => pr_idagenda
                                       ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                                       ,pr_idseqttl => pr_idseqttl  --> Sequencial titulo
                                       ,pr_nrcpfope => pr_nrcpfope  --> CPF operador
                                       ,pr_cddbanco => pr_cddbanco  --> Codigo Banco/Caixa
                                       ,pr_cdagectl => pr_cdageban  --> Codigo agencia centralizadora
                                       ,pr_nrctatrf => pr_nrctatrf  --> Conta destino
                                       ,pr_vllanmto => pr_vllanmto  --> Valor Lancamento
                                       ,pr_nrsequni => 0            --> Numero Sequencia
                                       ,pr_cdcoptfn => 0            --> Cooperativa transf.
                                       ,pr_nrterfin => 0            --> Numero terminal
                                       ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                                       ,pr_idtipcar => 0            --> Indicador Tipo Cartão Utilizado
                                       ,pr_nrcartao => 0            --> Numero Cartao
                                       ,pr_dsprotoc => vr_dsprotoc  --> Descricao protocolo
                                       ,pr_nrdocmto => vr_nrdocmto  --> Numero documento Debito
                                       ,pr_nrdoccre => vr_nrdoccre  --> Numero documento Credito
                                       ,pr_nrdoctar => vr_cdlantar  --> Numero documento tarifa
                                       ,pr_cdcritic => vr_cdcritic  --> Código do erro
                                       ,pr_dscritic => vr_dscritic);--> Descricao do erro
        END IF; -- FIM IF pr_tpoperac = 1 THEN
      END IF; -- FIM IF pr_tpoperac = 4 THEN /** TED **/

      -- se não apresentou critica nos processos acima
      IF nvl(vr_cdcritic,0) = 0 AND
         TRIM(vr_dscritic) IS NULL THEN

        IF pr_tpoperac = 4  THEN /** TED **/
          IF vr_tab_protocolo_ted.count > 0 THEN

            -- montar retorno em xml com as informações dos protocolos
            FOR vr_idxp IN vr_tab_protocolo_ted.first..vr_tab_protocolo_ted.last LOOP
              -- monta dados
              gene0002.pc_escreve_xml
                           (pr_xml            => pr_xml_operacao22
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     =>
                                   '<PROTOCOLO>'||
                                     '<dtmvtolt>'||to_char(vr_tab_protocolo_ted(vr_idxp).dtmvtolt,'DD/MM/RRRR')||'</dtmvtolt>'||
                                     '<dttransa>'||to_char(vr_tab_protocolo_ted(vr_idxp).dttransa,'DD/MM/RRRR')||'</dttransa>'||
                                     '<hrautent>'||to_char(to_date(vr_tab_protocolo_ted(vr_idxp).hrautent,'SSSSS'),'HH24:MI:SS')||'</hrautent>'||
                                     '<vldocmto>'||to_char(vr_tab_protocolo_ted(vr_idxp).vldocmto,'fm999G999G990D00')||'</vldocmto>'||
                                     '<nrdocmto>'||to_char(vr_tab_protocolo_ted(vr_idxp).nrdocmto,'fm99999990')||'</nrdocmto>'||
                                     '<nrseqaut>'||to_char(vr_tab_protocolo_ted(vr_idxp).nrseqaut,'fm99999990')||'</nrseqaut>'||
                                     '<dsinfor1>'||TRIM(vr_tab_protocolo_ted(vr_idxp).dsinform##1)||'</dsinfor1>'||
                                     '<dsinfor2>'||TRIM(vr_tab_protocolo_ted(vr_idxp).dsinform##2)||'</dsinfor2>'||
                                     '<dsinfor3>'||TRIM(vr_tab_protocolo_ted(vr_idxp).dsinform##3)||'</dsinfor3>'||
                                     '<dsprotoc>'||TRIM(vr_tab_protocolo_ted(vr_idxp).dsprotoc)||'</dsprotoc>'||
                                     '<nmprepos>'||TRIM(vr_tab_protocolo_ted(vr_idxp).nmprepos)||'</nmprepos>'||
                                     '<nrcpfpre>'||     vr_tab_protocolo_ted(vr_idxp).nrcpfpre ||'</nrcpfpre>'||
                                     '<nmoperad>'||TRIM(vr_tab_protocolo_ted(vr_idxp).nmoperad)||'</nmoperad>'||
                                     '<nrcpfope>'||     vr_tab_protocolo_ted(vr_idxp).nrcpfope ||'</nrcpfope>'||
                                     '<cdbcoctl>'||to_char(vr_tab_protocolo_ted(vr_idxp).cdbcoctl,'fm000')||'</cdbcoctl>'||
                                     '<cdagectl>'||to_char(vr_tab_protocolo_ted(vr_idxp).cdagectl,'fm0000')||'</cdagectl>'||
                                     '<cdtippro>'||     vr_tab_protocolo_ted(vr_idxp).cdtippro ||'</cdtippro>'||
                                   '</PROTOCOLO>');
            END LOOP;
            -- descarregar buffer
            gene0002.pc_escreve_xml
                           (pr_xml            => pr_xml_operacao22
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_fecha_xml      => TRUE
                           ,pr_texto_novo     => ' ');

          END IF;

          pr_xml_operacao22 := pr_xml_operacao22 ||
                               '<dsmsgsuc>Transação(ões) registrada(s) com sucesso.</dsmsgsuc>';

        -- se for transferencia sistema cecred
        ELSIF pr_cdtiptra IN (1,5) THEN
          vr_dscritic := 'Transferencia efetuada com sucesso.';
        ELSIF pr_cdtiptra = 3  THEN
          vr_dscritic := 'Credito de salario efetuado com sucesso.';
        END IF;

      ELSE -- se retornou critica deve abortar programa
        RAISE vr_exc_erro;
      END IF;

    ELSIF pr_idagenda = 2  THEN /** Agendamento **/
      IF pr_tpoperac = 5   THEN /* Transf. intercoop. */

        vr_cdhisdeb := 1009;

      ELSIF pr_tpoperac = 4 THEN -- TED

        vr_cdhisdeb := 555;

      ELSE
        --Executar rotina verifica-historico-transferencia
        PAGA0001.pc_verifica_historico_transf
                                     (pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                     ,pr_nrdconta => pr_nrdconta   --> Conta associado
                                     ,pr_nrctatrf => pr_nrctatrf   --> Conta destino
                                     ,pr_cdorigem => 3             --> Identificador Origem
                                     ,pr_cdtiptra => pr_cdtiptra   --> Tipo transacao
                                     ,pr_cdhiscre => vr_cdhiscre   --> Historico Credito
                                     ,pr_cdhisdeb => vr_cdhisdeb   --> Historico Debito
                                     ,pr_cdcritic => vr_cdcritic   --> Código do erro
                                     ,pr_dscritic => vr_dscritic); --> Descricao do erro
      END IF;

      /* Se deseja gravar favorito */
      IF pr_gravafav = 1 THEN
        pc_grava_favorito(pr_dscritic => vr_dscritic);
        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Buscar ultimo horario da DEBNET
      OPEN cr_craphec(pr_cdcooper => pr_cdcooper, 
                      pr_cdprogra => 'DEBNET');
      FETCH cr_craphec INTO rw_craphec;
      
      IF cr_craphec%FOUND THEN 
        -- Fechar cursor
        CLOSE cr_craphec;    
        IF pr_cdtiptra IN(1,5) THEN          
          -- Pegar os minutos em múltiplos de 5, arredondando para baixo (ex.: 21:04 -> 21:00)
          vr_hrfimpag:= to_char(to_date(rw_craphec.hriniexe,'SSSSS'),'hh24') || ':' ||
                        to_char(trunc(to_char(to_date(rw_craphec.hriniexe,'SSSSS'),'mi') / 5) * 5, 'fm00');
        ELSE
          vr_hrfimpag:= vr_tab_limite(vr_tab_limite.first).hrfimpag;
        END IF;
      ELSE
        -- Fechar cursor
        CLOSE cr_craphec;
        vr_hrfimpag:= vr_tab_limite(vr_tab_limite.first).hrfimpag;
      END IF;

      /* Procedimento para gerar os agendamentos de pagamento/transferencia/Credito salario */
      PAGA0002.pc_cadastrar_agendamento
                               ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                ,pr_cdagenci => 90           --> Codigo da agencia
                                ,pr_nrdcaixa => 900          --> Numero do caixa
                                ,pr_cdoperad => '996'        --> Codigo do operador
                                ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                                ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                ,pr_dsorigem => 'INTERNET'   --> Descrição de origem do registro
                                ,pr_cdtiptra => pr_cdtiptra  --> Tipo de transação
                                ,pr_idtpdpag => 0            --> Indicador de tipo de agendamento
                                ,pr_dscedent => ' '         --> Descrição do cedente
                                ,pr_dscodbar => ' '         --> Descrição codbarras
                                ,pr_lindigi1 => 0            --> 1° parte da linha digitavel
                                ,pr_lindigi2 => 0            --> 2° parte da linha digitavel
                                ,pr_lindigi3 => 0            --> 3° parte da linha digitavel
                                ,pr_lindigi4 => 0            --> 4° parte da linha digitavel
                                ,pr_lindigi5 => 0            --> 5° parte da linha digitavel
                                ,pr_cdhistor => vr_cdhisdeb  --> Codigo do historico
                                ,pr_dtmvtopg => vr_dtmvtopg  --> Data de pagamento
                                ,pr_vllanaut => pr_vllanmto  --> Valor do lancamento automatico
                                ,pr_dtvencto => NULL         --> Data de vencimento

                                ,pr_cddbanco => pr_cddbanco  --> Codigo do banco
                                ,pr_cdageban => pr_cdageban  --> Codigo de agencia bancaria
                                ,pr_nrctadst => pr_nrctatrf  --> Numero da conta destino

                                ,pr_cdcoptfn => 0            --> Codigo que identifica a cooperativa do cash.
                                ,pr_cdagetfn => 0            --> Numero do pac do cash.
                                ,pr_nrterfin => 0            --> Numero do terminal financeiro.

                                ,pr_nrcpfope => pr_nrcpfope  --> Numero do cpf do operador juridico
                                ,pr_idtitdda => 0            --> Contem o identificador do titulo dda.
                                ,pr_cdtrapen => 0            --> Codigo da Transacao Pendente
                                ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                                ,pr_idtipcar => 0            --> Indicador Tipo Cartão Utilizado
                                ,pr_nrcartao => 0            --> Nr Cartao

                                ,pr_cdfinali => pr_cdfinali  --> Codigo de finalidade
                                ,pr_dstransf => pr_dstransf  --> Descricao da transferencia
                                ,pr_dshistor => pr_dshistor  --> Descricao da finalidade
                                ,pr_iptransa => pr_iptransa  --> IP da transacao no IBank/mobile
                                ,pr_cdctrlcs => NULL         
                                /* parametros de saida */
                                ,pr_dstransa => vr_dstrans1  --> Descrição de transação
                ,pr_msgofatr => vr_msgofatr
                                ,pr_cdempcon => vr_cdempcon
                ,pr_cdsegmto => vr_cdsegmto
                                ,pr_dscritic => vr_dscritic);--> Descricao critica

      -- Se não localizar critica
      IF TRIM(vr_dscritic) IS NULL THEN
        IF pr_cdtiptra = 4 THEN
          vr_dscritic := 'Transação(ões) registrada(s) com sucesso.';
        ELSE
          -- Verificar se a data é um dia util, caso não ser, retorna o proximo dia
          vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                     pr_dtmvtolt  => pr_dtmvtopg,
                                                     pr_tipo      => 'P',
                                                     pr_feriado   => TRUE);

          vr_dscritic := (CASE
                           WHEN pr_cdtiptra IN (1,5) THEN 'Transferencia agendada'
                           ELSE 'Credito de salario agendado'
                          END)
                          ||
                          ' com sucesso para o dia '|| to_char(vr_dtmvtopg,'DD/MM/RRRR') ||
                          ', mediante saldo disponivel em conta corrente ate as '        ||
                          vr_hrfimpag || '.';
        END IF;

      -- Se retornou critica
      ELSE
        -- Se retornou critica , deve abortar
        RAISE vr_exc_erro;
      END IF;

    ELSIF pr_idagenda = 3  THEN /** Agendamento recorrente **/

      IF pr_tpoperac = 5   THEN /* Transf. intercoop. */

        vr_cdhisdeb := 1009;

      ELSIF pr_tpoperac = 4 THEN -- TED

        vr_cdhisdeb := 555;

      ELSE
        --Executar rotina verifica-historico-transferencia
        PAGA0001.pc_verifica_historico_transf
                                     (pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                     ,pr_nrdconta => pr_nrdconta   --> Conta associado
                                     ,pr_nrctatrf => pr_nrctatrf   --> Conta destino
                                     ,pr_cdorigem => 3             --> Identificador Origem
                                     ,pr_cdtiptra => pr_cdtiptra   --> Tipo transacao
                                     ,pr_cdhiscre => vr_cdhiscre   --> Historico Credito
                                     ,pr_cdhisdeb => vr_cdhisdeb   --> Historico Debito
                                     ,pr_cdcritic => vr_cdcritic   --> Código do erro
                                     ,pr_dscritic => vr_dscritic); --> Descricao do erro
      END IF;

      /* Se deseja gravar favorito */
      IF pr_gravafav = 1 THEN
        pc_grava_favorito(pr_dscritic => vr_dscritic);
        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      /* Procedimento para gerar os agendamentos recorrente */
      PAGA0002.pc_agendamento_recorrente(pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                        ,pr_cdagenci => 90           --> Codigo da agencia
                                        ,pr_nrdcaixa => 900          --> Numero do caixa
                                        ,pr_cdoperad => '996'        --> Codigo do operador
                                        ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                        ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                                        ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                        ,pr_dsorigem => 'INTERNET'   --> Descrição de origem do registro
                                        ,pr_lsdatagd => pr_lsdatagd  --> Lista de datas de agendamento
                                        ,pr_cdhistor => vr_cdhisdeb  --> Codigo do historico
                                        ,pr_vllanmto => pr_vllanmto  --> Valor do lancamento automatico
                                        ,pr_cddbanco => pr_cddbanco  --> Codigo do banco
                                        ,pr_cdageban => pr_cdageban  --> Codigo de agencia bancaria
                                        ,pr_nrctatrf => pr_nrctatrf  --> Numero da conta destino
                                        ,pr_cdtiptra => pr_cdtiptra  --> Tipo de transação
                                        ,pr_cdcoptfn => 0            --> Codigo que identifica a cooperativa do cash.
                                        ,pr_cdagetfn => 0            --> Numero do pac do cash.
                                        ,pr_nrterfin => 0            --> Numero do terminal financeiro.
                                        ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                                        ,pr_idtipcar => 0            --> Indicador Tipo Cartão Utilizado
                                        ,pr_nrcartao => 0            --> Numero Cartao
                                        ,pr_cdfinali => pr_cdfinali  --> Codigo de finalidade
                                        ,pr_dstransf => pr_dstransf  --> Descricao da transferencia
                                        ,pr_dshistor => pr_dshistor  --> Descricao da finalidade
                                        ,pr_iptransa => pr_iptransa  --> IP da transacao no IBank/mobile
                                        /* parametros de saida */
                                        ,pr_dstransa => vr_dstrans1  --> descrição de transação
                                        ,pr_cdcritic => vr_cdcritic  --> Codigo da critica
                                        ,pr_dscritic => vr_dscritic);--> Descricao critica

      -- Se não localizar critica
      IF TRIM(vr_dscritic) IS NULL THEN

        IF pr_cdtiptra = 4 THEN
          vr_dscritic := 'Transação(ões) registrada(s) com sucesso.';
        ELSE
          vr_dscritic := (CASE
                           WHEN pr_cdtiptra IN (1,5) THEN 'Transferencia agendada'
                           ELSE ' Credito de salario agendado'
                          END)||
                         ' com sucesso.';
        END IF;

      -- Se retornou critica
      ELSE
        -- Se retornou critica , deve abortar
        RAISE vr_exc_erro;
      END IF;

    END IF;

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      pr_xml_dsmsgerr := '<dsmsgsuc>'|| vr_dscritic ||'</dsmsgsuc>'||
                         '<idastcjt>'|| vr_idastcjt ||'</idastcjt>'||
						'<dsprotoc>'|| NVL(TRIM(vr_dsprotoc),'') ||'</dsprotoc>';
    END IF;

    pc_proc_geracao_log(pr_flgtrans => 1 /*TRUE*/);
    pr_dsretorn := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;

      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro inesperado. Nao foi possivel efetuar a transferencia. Tente novamente ou contacte seu PA';
      END IF;

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';

      pc_proc_geracao_log(pr_flgtrans => 0 /*false*/);

    WHEN OTHERS THEN
      ROLLBACK;

      btch0001.pc_log_internal_exception(pr_cdcooper);

      vr_dscritic := 'Erro inesperado. Nao foi possivel efetuar a transferencia.: '||SQLERRM;

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>Erro inesperado. Nao foi possivel efetuar a transferencia. Tente novamente ou contacte seu PA</dsmsgerr>';
      pr_dsretorn := 'NOK';

      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      pc_proc_geracao_log(pr_flgtrans => 0 /*false*/);

  END pc_InternetBank22;


  /* Procedimento do internetbank operação 26 - Validar pagamento */
  PROCEDURE pc_InternetBank26 ( pr_cdcooper IN  crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nrdconta IN  crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl IN  crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_idtitdda IN  VARCHAR2                --> Indicador DDA
                               ,pr_idtpdpag IN  INTEGER                 --> Indicador de tipo de pagamento
                               ,pr_lindigi1 IN  NUMBER                  --> Linha digitavel 1
                               ,pr_lindigi2 IN  NUMBER                  --> Linha digitavel 2
                               ,pr_lindigi3 IN  NUMBER                  --> Linha digitavel 3
                               ,pr_lindigi4 IN  NUMBER                  --> Linha digitavel 4
                               ,pr_lindigi5 IN  NUMBER                  --> Linha digitavel 4
                               ,pr_cdbarras IN  VARCHAR2                --> Codigo de barras
                               ,pr_vllanmto IN  NUMBER                  --> Valor Lancamento
                               ,pr_idagenda IN  INTEGER                 --> Indicador agendamento
                               ,pr_dtmvtopg IN DATE                     --> Data de pagamento
                               ,pr_dscedent IN VARCHAR2                 --> Descrição do cedente
                               ,pr_nrcpfope IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_flmobile IN  INTEGER                 --> Indicador se origem é do Mobile
                               ,pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                               ,pr_vlapagar IN  NUMBER                  --> Valor a pagar
                               ,pr_xml_dsmsgerr   OUT VARCHAR2          --> Retorno XML de critica
                               ,pr_xml_operacao26 OUT CLOB              --> Retorno XML da operação 26
                               ,pr_dsretorn       OUT VARCHAR2) IS      --> Retorno de critica (OK ou NOK)

    /* ..........................................................................

      Programa : pc_InternetBank26        Antiga: sistema/internet/fontes/InternetBank26.p
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : David
      Data    : Junho/2007                        Ultima atualizacao: 16/01/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Verifica dados para efetuar pagamentos pela Internet.

      Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).

                  10/03/2008 - Utilizar include var_ibank.i (David).

                  09/04/2008 - Adaptacao para agendamento de pagamentos (David).

                  03/11/2008 - Inclusao widget-pool (martin)

                  25/08/2009 - Alteracoes do Projeto de Transferencia para
                               Credito de Salario (David).

                  04/06/2010 - Incluido parametro Origem nas procedures
                               verifica_titulo e verifica_convenio (Diego).

                  10/05/2011 - Incluso parametros cobranca registrada na
                               verifica_titutlo (Guilherme).

                  05/10/2011 - Parametro cpf operador na verifica_operacao
                             - Validacao pagamento por operador
                               (Guilherme).

                  14/05/2012 - Projeto TED Internet (David).

                  13/11/2012 - Melhoria Multi Pagamentos (David).

                  10/04/2013 - Projeto VR Boletos (Rafael).

                  06/11/2014 - (Chamado 161844) Permitir agendamento de pagamentos
                               para dia nao util (Tiago Castro - RKAM).

                  14/05/2015 - Conversão Progress -> Oracle SD280901 (Odirlei-AMcom)

                  24/09/2015 - Realizado a inclusão do pr_nmdatela (Adriano - SD 328034).

                  03/10/2017 - Ajuste da mensagem de erro. (Ricardo Linhares - prj 356.2).                  

				  01/11/2017 - Adicionada validação de pagamento em lote.
							   PRJ356.4 - DDA (Ricardo Linhares)


                  16/01/2018 - Adicionado validação para que não seja permitido realizar agendamento
                               para uma data anterior a data atual do sistema
                               (Douglas - Chamado 829446)
    .................................................................................*/
    ----------------> TEMPTABLE  <---------------
    vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;

    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

    vr_dstransa  VARCHAR2(500) := NULL;
    vr_dstrans1  VARCHAR2(500) := NULL;
    vr_nrdrowid  ROWID;
    vr_dtvencto  DATE;
    vr_nmconban  VARCHAR2(100);
    vr_cdseqfat  NUMBER;
    vr_vlrdocum  NUMBER;
    vr_nrdigfat  NUMBER;
    vr_lindigi1  NUMBER;
    vr_lindigi2  NUMBER;
    vr_lindigi3  NUMBER;
    vr_lindigi4  NUMBER;
    vr_lindigi5  NUMBER;
    vr_cdbarras  VARCHAR2(100);
    vr_dtmvtopg  DATE;
    vr_dtdifere  BOOLEAN;
    vr_vldifere  BOOLEAN;
    vr_nrctacob  NUMBER;
    vr_insittit  NUMBER;
    vr_intitcop  NUMBER;
    vr_nrcnvcob  NUMBER;
    vr_nrboleto  NUMBER;
    vr_nrdctabb  NUMBER;
    vr_cobregis  BOOLEAN;
    vr_msgalert  VARCHAR2(300);
    vr_vlrjuros  NUMBER;
    vr_vlrmulta  NUMBER;
    vr_vldescto  NUMBER;
    vr_vlabatim  NUMBER;
    vr_vloutdeb  NUMBER;
    vr_vloutcre  NUMBER;
    vr_vlapagar  NUMBER;

    vr_assin_conjunta NUMBER(1);
    vr_idastcjt  crapass.idastcjt%TYPE;
    vr_inpessoa  crapass.inpessoa%TYPE;
    vr_nrcpfcgc  INTEGER := 0;
    vr_nmprimtl  VARCHAR2(500);
    vr_flcartma  INTEGER(1) := 0;

    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT a.inpessoa
      FROM crapass a
     WHERE a.cdcooper = pr_cdcooper     
       AND a.nrdconta = pr_nrdconta;

  BEGIN

    -- Verificar se é agendamento
    IF NVL(pr_idagenda,0) = 2 THEN
      -- Verificar se a data do agendamento é anterior a data atual 
      IF pr_dtmvtopg < pr_dtmvtolt THEN
        -- Gerar mensagem de erro para não permitir o pagamento
        vr_dscritic := 'Não é permitido realizar agendamento para data retroativa.';
        RAISE vr_exc_erro;
      END IF;
    END IF;  
    
    -- Definir descrição da transação
    SELECT 'Valida '||DECODE(NVL(pr_idtpdpag,0),1,'convenio (fatura)','titulo')||
           ' para '||DECODE(NVL(pr_idagenda,0),1,NULL,'agendamento de ')||'pagamento'
    INTO vr_dstransa
    FROM dual;

    -- Buscar tipo de pessoa da conta
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO vr_inpessoa;
    IF cr_crapass%NOTFOUND THEN
      vr_inpessoa := 0;
    END IF;    
    CLOSE cr_crapass;

    -- inicializar variaveis
    vr_lindigi1 := pr_lindigi1;
    vr_lindigi2 := pr_lindigi2;
    vr_lindigi3 := pr_lindigi3;
    vr_lindigi4 := pr_lindigi4;
    vr_lindigi5 := pr_lindigi5;
    vr_cdbarras := pr_cdbarras;
    vr_dtmvtopg := pr_dtmvtopg;

    IF NVL(pr_vlapagar,0) > 0 THEN
		   vr_vlapagar := pr_vlapagar;
  	ELSE
	 	   vr_vlapagar := pr_vllanmto;
    END IF;

    INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --Verifica se conta for conta PJ e se exige asinatura multipla
    INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdorigem => 3
                                       ,pr_idastcjt => vr_idastcjt
                                       ,pr_nrcpfcgc => vr_nrcpfcgc
                                       ,pr_nmprimtl => vr_nmprimtl
                                       ,pr_flcartma => vr_flcartma
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;

    
    /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
    INET0001.pc_verifica_operacao
                         (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                         ,pr_cdagenci     => 90                  --> Agencia do Associado
                         ,pr_nrdcaixa     => 900                 --> Numero caixa
                         ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                         ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                         ,pr_dtmvtolt     => pr_dtmvtolt         --> Data Movimento
                         ,pr_idagenda     => pr_idagenda         --> Indicador agenda
                         ,pr_dtmvtopg     => pr_dtmvtopg         --> Data Pagamento
                         ,pr_vllanmto     => vr_vlapagar         --> Valor Lancamento
                         ,pr_cddbanco     => 0                   --> Codigo banco
                         ,pr_cdageban     => 0                   --> Codigo Agencia
                         ,pr_nrctatrf     => 0                   --> Numero Conta Transferencia
                         ,pr_cdtiptra     => 0                   --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                         ,pr_cdoperad     => 996                 --> Codigo Operador
                         ,pr_tpoperac     => (CASE               --> 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                                               WHEN pr_vllanmto >= 250000 THEN
                                                 6    /** VR-BOLETO **/
                                               ELSE 2 /** PAGAMENTO **/
                                              END)
                         ,pr_flgvalid     => TRUE                --> Indicador validacoes
                         ,pr_dsorigem     => 'INTERNET'          --> Descricao Origem
                         ,pr_nrcpfope     => (CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN vr_nrcpfcgc ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do responsavel legal quando conta exigir assinatura multipla         --> CPF operador
                         ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos */
                         ,pr_nmdatela     => 'INTERNETBANK'      --> Nome da tela/programa que esta chamando a rotina
                         ,pr_dstransa     => vr_dstrans1         --> Descricao da transacao
                         ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                         ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                         ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                         ,pr_dscritic     => vr_dscritic
                         ,pr_assin_conjunta => vr_assin_conjunta);       --> Descricao do erro

    -- verificar se retornou critica
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      -- abortar programa
      RAISE vr_exc_erro;
    END IF;

    IF pr_idtpdpag = 1 THEN /** Convenio **/
      -- verifica convenio
      PAGA0001.pc_verifica_convenio
                         (pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                         ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                         ,pr_idseqttl => pr_idseqttl  --> Sequencial titular
                         ,pr_idagenda => pr_idagenda  --> Indicador agendamento
                         ,pr_lindigi1 => vr_lindigi1  --> Linha digitavel 1
                         ,pr_lindigi2 => vr_lindigi2  --> Linha digitavel 2
                         ,pr_lindigi3 => vr_lindigi3  --> Linha digitavel 3
                         ,pr_lindigi4 => vr_lindigi4  --> Linha digitavel 4
                         ,pr_cdbarras => vr_cdbarras  --> Codigo de Barras
                         ,pr_dtvencto => vr_dtvencto  --> Data Vencimento
                         ,pr_vllanmto => pr_vllanmto  --> Valor Lancamento
                         ,pr_dtagenda => vr_dtmvtopg  --> Data agendamento
                         ,pr_idorigem => 3 /*INTERNET*/ --> Indicador de origem
                         ,pr_indvalid => 0            --> Nao validar horario limite
						 	           ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                         ,pr_nmextcon => vr_nmconban  --> Nome do banco
                         ,pr_cdseqfat => vr_cdseqfat  --> Codigo Sequencial fatura
                         ,pr_vlfatura => vr_vlrdocum  --> Valor fatura
                         ,pr_nrdigfat => vr_nrdigfat  --> Numero Digito Fatura
                         ,pr_dstransa => vr_dstrans1  --> Descricao transacao
                         ,pr_cdcritic => vr_cdcritic  --> Codigo da critica
                         ,pr_dscritic => vr_dscritic);--> Descricao critica

      -- Verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN

        -- se possui codigo, porém não possui descrição
        IF nvl(vr_cdcritic,0) > 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- buscar descrição
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        END IF;

        -- Se retornou critica , deve abortar
        RAISE vr_exc_erro;
      END IF;

    ELSIF pr_idtpdpag = 2  THEN /** Titulo **/

      /* Se valor for acima de VR Boleto, passar
         idtitdda juntamente com o código de barras.
         Tratamento na retorna-valores-titulos-iptu (b2crap14) */
      IF pr_vllanmto >= 250000 AND
         pr_idtitdda > 0 THEN
        vr_cdbarras := pr_cdbarras ||';'||pr_idtitdda;
      END IF;

      --Verificar titulo
      PAGA0001.pc_verifica_titulo(pr_cdcooper => pr_cdcooper           --> Codigo da cooperativa
                                 ,pr_nrdconta => pr_nrdconta           --> Numero da conta
                                 ,pr_idseqttl => pr_idseqttl           --> Sequencial titular
                                 ,pr_idagenda => (CASE                 --> Indicador agendamento
                                                    WHEN pr_idagenda = 1 AND
                                                         pr_idtitdda <> 0 THEN 3
                                                    ELSE pr_idagenda
                                                  END)
                                 ,pr_lindigi1 => vr_lindigi1           --> Linha digitavel 1
                                 ,pr_lindigi2 => vr_lindigi2           --> Linha digitavel 2
                                 ,pr_lindigi3 => vr_lindigi3           --> Linha digitavel 3
                                 ,pr_lindigi4 => vr_lindigi4           --> Linha digitavel 4
                                 ,pr_lindigi5 => vr_lindigi5           --> Linha digitavel 5
                                 ,pr_cdbarras => vr_cdbarras           --> Codigo de Barras
                                 ,pr_vllanmto => pr_vllanmto           --> Valor Lancamento
                                 ,pr_dtagenda => vr_dtmvtopg           --> Data agendamento
                                 ,pr_idorigem => 3 /* INTERNET */      --> Indicador de origem
                                 ,pr_indvalid => 0                     --> Validar
								                 ,pr_flmobile => pr_flmobile           --> Indicador Mobile
                                 ,pr_cdctrlcs => pr_cdctrlcs           --> Numero de controle da consulta no NPC
                                 ,pr_nmextbcc => vr_nmconban           --> Nome do banco
                                 ,pr_vlfatura => vr_vlrdocum           --> Valor fatura
                                 ,pr_dtdifere => vr_dtdifere           --> Indicador data diferente
                                 ,pr_vldifere => vr_vldifere           --> Indicador valor diferente
                                 ,pr_nrctacob => vr_nrctacob           --> Numero Conta Cobranca
                                 ,pr_insittit => vr_insittit           --> Indicador Situacao Titulo
                                 ,pr_intitcop => vr_intitcop           --> Indicador Titulo Cooperativa
                                 ,pr_nrcnvcob => vr_nrcnvcob           --> Numero Convenio Cobranca
                                 ,pr_nrboleto => vr_nrboleto           --> Numero Boleto
                                 ,pr_nrdctabb => vr_nrdctabb           --> Numero conta
                                 ,pr_dstransa => vr_dstrans1           --> Descricao transacao
                                 /* cob reg */
                                 ,pr_cobregis => vr_cobregis           --> Cobranca Registrada
                                 ,pr_msgalert => vr_msgalert           --> mensagem alerta
                                 ,pr_vlrjuros => vr_vlrjuros           --> Valor Juros
                                 ,pr_vlrmulta => vr_vlrmulta           --> Valor Multa
                                 ,pr_vldescto => vr_vldescto           --> Valor desconto
                                 ,pr_vlabatim => vr_vlabatim           --> Valor Abatimento
                                 ,pr_vloutdeb => vr_vloutdeb           --> Valor saida debito
                                 ,pr_vloutcre => vr_vloutcre           --> Valor saida credito
                                 ,pr_cdcritic => vr_cdcritic           --> Codigo da critica
                                 ,pr_dscritic => vr_dscritic);         --> Descricao critica
      -- Verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN

        -- se possui codigo, porém não possui descrição
        IF nvl(vr_cdcritic,0) > 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- buscar descrição
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        END IF;
        vr_dscritic := vr_dscritic||' - '||pr_dscedent;

        -- Se retornou critica , deve abortar
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- Verificar se a data é um dia util, caso não ser, retorna o proximo dia
    vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                               pr_dtmvtolt  => pr_dtmvtopg,
                                               pr_tipo      => 'P',
                                               pr_feriado   => TRUE);
    --> Montar xml de retorno dos dados <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_operacao26, TRUE);
    dbms_lob.open(pr_xml_operacao26, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao26
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

    -- Insere dados
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao26
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<DADOS_PAGAMENTO>
                                                      <lindigi1>'|| vr_lindigi1           ||'</lindigi1>
                                                      <lindigi2>'|| vr_lindigi2           ||'</lindigi2>
                                                      <lindigi3>'|| vr_lindigi3           ||'</lindigi3>
                                                      <lindigi4>'|| vr_lindigi4           ||'</lindigi4>
                                                      <lindigi5>'|| vr_lindigi5           ||'</lindigi5>
                                                      <cdbarras>'|| vr_cdbarras           ||'</cdbarras>
                                                      <nmconban>'|| vr_nmconban           ||'</nmconban>
                                                      <dtmvtopg>'|| to_char(vr_dtmvtopg,'DD/MM/RRRR')||'</dtmvtopg>
                                                      <vlrdocum>'|| vr_vlrdocum            ||'</vlrdocum>
                                                      <cdseqfat>'|| to_char(vr_cdseqfat)   ||'</cdseqfat>
                                                      <nrdigfat>'|| vr_nrdigfat            ||'</nrdigfat>
                                                      <nrcnvcob>'|| vr_nrcnvcob            ||'</nrcnvcob>
                                                      <nrboleto>'|| vr_nrboleto            ||'</nrboleto>
                                                      <nrctacob>'|| vr_nrctacob            ||'</nrctacob>
                                                      <insittit>'|| vr_insittit            ||'</insittit>
                                                      <intitcop>'|| vr_intitcop            ||'</intitcop>
                                                      <nrdctabb>'|| vr_nrdctabb            ||'</nrdctabb>
                                                      <dttransa>'|| to_char(SYSDATE,'DD/MM/RRRR') ||'</dttransa>
                                                      <inpessoa>'|| to_char(vr_inpessoa)   ||'</inpessoa>
                                                    </DADOS_PAGAMENTO>');
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao26
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</raiz>'
                           ,pr_fecha_xml      => TRUE);

    -- Cria um registro na CRAPMVI com os valores zerados
    -- Isto foi implementado pois o Cecred Mobile executa os pagamentos em lote em threads assíncronas
    -- e, as  vezes, duas threads tentavam criar o registro ao mesmo tempo em conflito, ocorrendo erro de UK
    BEGIN
      INSERT INTO crapmvi
          (cdcooper
          ,nrdconta
          ,dtmvtolt
          ,cdoperad
          ,dttransa
          ,hrtransa
          ,vlmovweb
          ,idseqttl
          ,vlmovtrf
          ,vlmovpgo
          ,vlmovted)
        VALUES
          (pr_cdcooper
          ,pr_nrdconta
          ,pr_dtmvtolt
          ,'996'
          ,TRUNC(SYSDATE)
          ,gene0002.fn_busca_time
          ,0
          ,pr_idseqttl
          ,0
          ,0
          ,0);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

    pr_dsretorn := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';

      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 /*FALSE - Operacao sem sucesso */
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Origem',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => CASE pr_flmobile
                                               WHEN 1 THEN 'MOBILE'
                                               ELSE 'INTERNETBANK'
                                                END);

    WHEN OTHERS THEN

      vr_dscritic := 'Não foi possivel validar pagamento: '||SQLERRM;

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';

      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 /*FALSE - Operacao sem sucesso */
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Origem',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => CASE pr_flmobile
                                               WHEN 1 THEN 'MOBILE'
                                               ELSE 'INTERNETBANK'
                                                END);
  END pc_InternetBank26;

  /* Procedimento do internetbank operação 27 - Efetuar pagamento */
  PROCEDURE pc_InternetBank27 ( pr_cdcooper IN  crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_nrdconta IN  crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl IN  crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_idtitdda IN  VARCHAR2                --> Indicador DDA
                               ,pr_idagenda IN  INTEGER                 --> Indicador de agendamento
                               ,pr_idtpdpag IN  INTEGER                 --> Indicador de tipo de pagamento
                               ,pr_lindigi1 IN  NUMBER                  --> Linha digitavel 1
                               ,pr_lindigi2 IN  NUMBER                  --> Linha digitavel 2
                               ,pr_lindigi3 IN  NUMBER                  --> Linha digitavel 3
                               ,pr_lindigi4 IN  NUMBER                  --> Linha digitavel 4
                               ,pr_lindigi5 IN  NUMBER                  --> Linha digitavel 5
                               ,pr_cdbarras IN  VARCHAR2                --> Codigo de barras
                               ,pr_dscedent IN  VARCHAR2                --> Descrição do cedente
                               ,pr_dtmvtopg IN  DATE                    --> Data para pagamento
                               ,pr_dtvencto IN DATE                     --> Data do vencimento
                               ,pr_vllanmto IN crapopi.nrcpfope%TYPE    --> Valor Lancamento
                               ,pr_vlpagame IN  NUMBER                  --> valor fatura
                               ,pr_cdseqfat IN  VARCHAR2                --> Codigo sequncial da fatura
                               ,pr_nrdigfat IN  NUMBER                  --> Digito da fatura
                               ,pr_nrcnvcob IN  NUMBER                  --> Numero do convenio de cobrança
                               ,pr_nrboleto IN  NUMBER                  --> Numero do boleto
                               ,pr_nrctacob IN  NUMBER                  --> Numero da conta de cobrança
                               ,pr_insittit IN  INTEGER                 --> Situação do titulo
                               ,pr_intitcop IN  INTEGER                 --> Titulo da coopeariva
                               ,pr_nrdctabb IN  NUMBER                  --> Numero da conta BB
                               ,pr_nrcpfope IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_vlapagar IN  NUMBER                  --> Valor a pagar
                               ,pr_versaldo IN  INTEGER                 --> Indicador de ver saldo
                               ,pr_flmobile IN  INTEGER                 --> Indicador se origem é do Mobile
                               ,pr_tpcptdoc IN craptit.tpcptdoc%TYPE DEFAULT 1 --> Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                               ,pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                               ,pr_xml_dsmsgerr OUT VARCHAR2            --> Retorno XML de critica
                               ,pr_xml_msgofatr OUT VARCHAR2            --> Retorno XML com mensagem para fatura
                               ,pr_xml_cdempcon OUT VARCHAR2            --> Retorno XML com cod empresa convenio
                               ,pr_xml_cdsegmto OUT VARCHAR2            --> Retorno XML com segmto convenio
							   ,pr_xml_dsprotoc OUT VARCHAR2            --> Retorno XML com protocolo do comprovante gerado
                               ,pr_dsretorn     OUT VARCHAR2) IS        --> Retorno de critica (OK ou NOK)

    /* ..........................................................................

      Programa : pc_InternetBank27        Antiga: sistema/internet/fontes/InternetBank27.p
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : David
      Data    : Junho/2007                        Ultima atualizacao: 23/03/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
     Objetivo  : Efetuar pagamentos pela Internet.

     Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).

                 10/04/2008 - Adaptacao para agendamento de pagamentos (David).

                 03/11/2008 - Inclusao widget-pool (martin)

                 06/08/2009 - Alteracoes do Projeto de Transferencia para
                              Credito de Salario (David).

                 04/06/2010 - Incluido paramentro Origem nas procedures
                              verifica_convenio, verifica_titulo, paga_convenio e
                              paga_titulo (Diego).

                 14/10/2010 - Inclusao dos parametros para cooperativa/pac/taa
                              nas procedures paga_convenio e paga_titulo (Vitor).

                 27/04/2011 - Incluidos parametros do TAA na b1wgen0016 (Evandro).

                 10/05/2011 - Incluso parametros cobranca registrada na
                              verifica_titutlo e paga_titulo (Guilherme).

                 05/10/2011 - Parametro cpf operador na verifica_operacao
                              Parametros operador na paga_convenio
                              (Guilherme).

                 29/12/2011 - Adiicionar parametros de par_versaldo e par_vlapagar
                              para verificar saldo do dia, para efetuar pagamento
                              do(s) boleto(s) (Jorge).

                 09/03/2012 - Adicionado os campos cdbcoctl e cdagectl.(Fabricio)

                 14/05/2012 - Projeto TED Internet (David).

                 13/11/2012 - Melhoria Multi Pagamentos (David).

                 15/01/2013 - Nao validar saldo se for operador PJ (David).

                 10/04/2013 - Projeto VR Boletos (Rafael).

                 07/08/2013 - Ajuste de pagto de VR Boletos pelo DDA (Rafael).

                 19/09/2014 - Adicionado parametros de saida xml_msgofatr e
                              xml_cdempcon. (Debito Facil - Fabricio).

                 04/11/2014 - (Chamado 161844)- Liberacao de agendamentos
                              para dia nao util. (Tiago Castro - RKAM)

                 19/01/2015 - Permitir informar o cedente nos convenios
                              (Chamado 235532). (Jonata - RKAM)

                 14/05/2015 - Conversão Progress -> Oracle SD280901 (Odirlei-AMcom)

                 05/08/2015 - Passar o pr_idtitdda para a procedure INET0002.pc_cria_transacao_operador
                              gravar a informação no campo craptoj.idtitdda (Douglas - Chamado 291387)

                 14/08/2015 - inclusão do parametro pr_tpcptdoc, para identificacao do tipo de captura
                              (leitora ou manual(linha digitavel)) (Odirlei-AMcom)

                 24/09/2015 - Realizado a inclusão do pr_nmdatela (Adriano - SD 328034).

                 08/12/2015 - Adicionado chamda da proc. pc_verifica_rep_assinatura, retornando informacoes
                              quanto a conta exigir Assinatura Conjunta entre outras informacoes.
                              (Jorge/David) Proj. 131 Assinatura Multipla

                 24/05/2016 - Removendo mensagem de log especifica para DDA pois já estava sendo
                              montada anteriormente para soluncionar o problema do chamado
                              417943. (Kelvin)
                              
                 16/01/2018 - Adicionado validação para que não seja permitido realizar agendamento
                              para uma data anterior a data atual do sistema
                              (Douglas - Chamado 829446)

                 23/03/2018 - Incluido validações de valor de pagamento negativo ou zerado (Tiago/Jean #INC0010838)
    .................................................................................*/
    ----------------> CURSORES  <---------------
    -- Cursor para encontrar a conta/corrente
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrdconta
            ,ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

    ----------------> TEMPTABLE <---------------
    vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;
    vr_tab_erro       GENE0001.typ_tab_erro;  --> Tabela com erros
    vr_tab_saldos     EXTR0001.typ_tab_saldos;         --> Tabela de retorno da rotina

    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_des_reto    VARCHAR2(03);           --> OK ou NOK
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;

    rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
    vr_dstransa  VARCHAR2(500) := NULL;
    vr_dstrans1  VARCHAR2(500) := NULL;
    vr_vllanmto  NUMBER;
    vr_nrdrowid  ROWID;
    vr_dtvencto  DATE;
    vr_nmconban  VARCHAR2(100);
    vr_cdseqfat  NUMBER;
    vr_vlrdocum  NUMBER;
    vr_nrdigfat  NUMBER;
    vr_lindigi1  NUMBER;
    vr_lindigi2  NUMBER;
    vr_lindigi3  NUMBER;
    vr_lindigi4  NUMBER;
    vr_lindigi5  NUMBER;
    vr_lindigit  VARCHAR2(100);
    vr_cdbarras  VARCHAR2(100);
    vr_dtmvtopg  DATE;
    vr_dtdifere  BOOLEAN;
    vr_vldifere  BOOLEAN;
    vr_nrctacob  NUMBER;
    vr_insittit  NUMBER;
    vr_intitcop  NUMBER;
    vr_nrcnvcob  NUMBER;
    vr_nrboleto  NUMBER;
    vr_nrdctabb  NUMBER;
    vr_cobregis  BOOLEAN;
    vr_msgalert  VARCHAR2(300);
    vr_vlrjuros  NUMBER;
    vr_vlrmulta  NUMBER;
    vr_vldescto  NUMBER;
    vr_vlabatim  NUMBER;
    vr_vloutdeb  NUMBER;
    vr_vloutcre  NUMBER;
    vr_cdcoptfn  NUMBER := 0;
    vr_cdagetfn  NUMBER := 0;
    vr_nrterfin  NUMBER := 0;
    vr_cdbcoctl  NUMBER := 0;
    vr_cdagectl  NUMBER := 0;
    vr_msgofatr  VARCHAR2(500);
    vr_cdempcon  NUMBER;
    vr_cdsegmto  VARCHAR2(500);
    vr_dsprotoc  crappro.dsprotoc%TYPE;
    vr_idastcjt  crapass.idastcjt%TYPE;
    vr_nrcpfcgc  INTEGER := 0;
    vr_nmprimtl  VARCHAR2(500);
    vr_flcartma  INTEGER(1) := 0;
    vr_assin_conjunta NUMBER(1);
    -- Gerar log
    PROCEDURE pc_proc_geracao_log(pr_flgtrans IN INTEGER) IS
    BEGIN

      IF pr_nrcpfope > 0  THEN
        vr_dstransa := vr_dstransa ||' - operador';
      END IF;

      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => pr_flgtrans
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Origem',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => CASE pr_flmobile
                                               WHEN 1 THEN 'MOBILE'
                                               ELSE 'INTERNETBANK'
                                                END);

      -- se é log de sucesso
      IF pr_flgtrans = 1 THEN
        IF pr_nrcpfope > 0  THEN
          GENE0001.pc_gera_log_item
                          (pr_nrdrowid => vr_nrdrowid
                          ,pr_nmdcampo => 'Operador'
                          ,pr_dsdadant => ' '
                          ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
        END IF;
        GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Representacao Numerica'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => vr_cdbarras);

        GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => (CASE
                                           WHEN pr_idagenda = 1 AND pr_nrcpfope = 0 THEN
                                             'Valor Pago'
                                           ELSE 'Valor a Pagar'
                                         END)
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => to_char(pr_vllanmto,'9G999G990D00'));

        -- se não é agendamento
        IF pr_idagenda = 1 AND pr_nrcpfope = 0 THEN
          GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Protocolo'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => vr_dsprotoc);
        ELSE
          GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Data do Agendamento'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => to_char(nvl(vr_dtmvtopg,pr_dtmvtopg),'DD/MM/RRRR'));
        END IF;

        -- se for DDDA
        IF pr_idtitdda > 0 THEN
          GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Identificacao Titulo DDA'
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => pr_idtitdda);
        END IF;

        --Se conta exigir Assinatura Multipla
        IF vr_idastcjt = 1 THEN
           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'Nome do Representante/Procurador',
                                     pr_dsdadant => '',
                                     pr_dsdadatu => vr_nmprimtl);

           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CPF do Representante/Procurador',
                                     pr_dsdadant => '',
                                     pr_dsdadatu => TO_CHAR( vr_nrcpfcgc));
        END IF;

      END IF;

    END pc_proc_geracao_log;

  BEGIN
    -- DATAS DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR CR_CRAPDAT CURSOR POIS HAVERA RAISE
      CLOSE btch0001.cr_crapdat;

      -- Definir Critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Verificar se é agendamento
    IF NVL(pr_idagenda,0) = 2 THEN
      -- Verificar se a data do agendamento é anterior a data atual 
      IF pr_dtmvtopg < rw_crapdat.dtmvtolt THEN
        -- Gerar mensagem de erro para não permitir o pagamento
        vr_dscritic := 'Não é permitido realizar agendamento para data retroativa.';
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    IF NVL(pr_vllanmto,0) <= 0 THEN
      -- Gerar mensagem de erro para não permitir o pagamento
      vr_dscritic := 'Valor não permitido para pagamento.';
      RAISE vr_exc_erro;
    END IF;      

    -- Definir descrição da transação
    SELECT DECODE(NVL(pr_idagenda,0),1,'Pagamento','Agendamento para pagamento')||
           ' de '||DECODE(NVL(pr_idtpdpag,0),1,'convenio (fatura)','titulo')||
           DECODE(NVL(pr_idtitdda,0),0,NULL,' DDA')
    INTO vr_dstransa
    FROM dual;

    INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --Verifica se conta for conta PJ e se exige asinatura multipla
    INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdorigem => 3
                                       ,pr_idastcjt => vr_idastcjt
                                       ,pr_nrcpfcgc => vr_nrcpfcgc
                                       ,pr_nmprimtl => vr_nmprimtl
                                       ,pr_flcartma => vr_flcartma
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;

    -- se for para verificar o saldo
    IF pr_versaldo = 1 AND pr_nrcpfope = 0 AND vr_idastcjt = 0 THEN
      -- Definir descrição da transação

      -- Buscar limite de credito
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;

        -- Monta critica
        vr_cdcritic := 9;
        -- Gera excecao
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapass;
      END IF;

      -- obter do saldo da conta
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                  pr_rw_crapdat => rw_crapdat,
                                  pr_cdagenci   => 90,
                                  pr_nrdcaixa   => 900,
                                  pr_cdoperad   => '996',
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_vllimcre   => rw_crapass.vllimcre,
                                  pr_tipo_busca => 'A',  --> Usar data anterior
                                  pr_dtrefere   => pr_dtmvtolt,
                                  pr_des_reto   => vr_des_reto,
                                  pr_tab_sald   => vr_tab_saldos,
                                  pr_tab_erro   => vr_tab_erro);

       -- Verifica se deu erro
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Não foi possivel verificar Saldo.';
        END IF;

        RAISE vr_exc_erro;
      END IF;

      -- se não encontrar nenhum registrp
      IF vr_tab_saldos.exists(vr_tab_saldos.first) = FALSE THEN
        vr_dscritic := 'Nao foi possivel consultar o saldo para a operacao.';
        RAISE vr_exc_erro;
      END IF;

      -- Verificar se possui saldo disponivel para realizar o pagamento
      IF nvl(pr_vlapagar,0) > (  vr_tab_saldos(vr_tab_saldos.first).vlsddisp
                               + vr_tab_saldos(vr_tab_saldos.first).vllimcre) THEN
        vr_dscritic := 'Nao ha saldo suficiente para a operacao.';
        RAISE vr_exc_erro;
      END IF;

    END IF; -- Fim IF verificar saldo

    -- inicializar variaveis
    vr_vllanmto := pr_vllanmto;
    vr_lindigi1 := pr_lindigi1;
    vr_lindigi2 := pr_lindigi2;
    vr_lindigi3 := pr_lindigi3;
    vr_lindigi4 := pr_lindigi4;
    vr_lindigi5 := pr_lindigi5;
    vr_cdbarras := pr_cdbarras;
    vr_dtmvtopg := pr_dtmvtopg;
    ------

    vr_nrctacob := pr_nrctacob;
    vr_insittit := pr_insittit;
    vr_intitcop := pr_intitcop;
    vr_nrcnvcob := pr_nrcnvcob;
    vr_nrboleto := pr_nrboleto;
    vr_nrdctabb := pr_nrdctabb;

    /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
    INET0001.pc_verifica_operacao
                         (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                         ,pr_cdagenci     => 90                  --> Agencia do Associado
                         ,pr_nrdcaixa     => 900                 --> Numero caixa
                         ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                         ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                         ,pr_dtmvtolt     => pr_dtmvtolt         --> Data Movimento
                         ,pr_idagenda     => pr_idagenda         --> Indicador agenda
                         ,pr_dtmvtopg     => vr_dtmvtopg         --> Data Pagamento
                         ,pr_vllanmto     => vr_vllanmto         --> Valor Lancamento
                         ,pr_cddbanco     => 0                   --> Codigo banco
                         ,pr_cdageban     => 0                   --> Codigo Agencia
                         ,pr_nrctatrf     => 0                   --> Numero Conta Transferencia
                         ,pr_cdtiptra     => 0                   --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                         ,pr_cdoperad     => 996                 --> Codigo Operador
                         ,pr_tpoperac     => (CASE               --> 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                                               WHEN pr_vllanmto >= 250000 THEN
                                                 6    /** VR-BOLETO **/
                                               ELSE 2 /** PAGAMENTO **/
                                              END)
                         ,pr_flgvalid     => TRUE                --> Indicador validacoes
                         ,pr_dsorigem     => 'INTERNET'          --> Descricao Origem
                         ,pr_nrcpfope     => (CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN nvl(vr_nrcpfcgc,0) ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do responsavel legal quando conta exigir assinatura multipla
                         ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos */
                         ,pr_nmdatela     => 'INTERNETBANK'      --> Nome da tela/programa que esta chamando a rotina
                         ,pr_dstransa     => vr_dstrans1         --> Descricao da transacao
                         ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                         ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                         ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                         ,pr_dscritic     => vr_dscritic
                         ,pr_assin_conjunta => vr_assin_conjunta);       --> Descricao do erro

    -- verificar se retornou critica
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      -- abortar programa
      RAISE vr_exc_erro;
    END IF;


    IF pr_idtpdpag = 1 THEN /** Convenio **/
      -- verifica convenio
      PAGA0001.pc_verifica_convenio
                         (pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                         ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                         ,pr_idseqttl => pr_idseqttl  --> Sequencial titular
                         ,pr_idagenda => pr_idagenda  --> Indicador agendamento
                         ,pr_lindigi1 => vr_lindigi1  --> Linha digitavel 1
                         ,pr_lindigi2 => vr_lindigi2  --> Linha digitavel 2
                         ,pr_lindigi3 => vr_lindigi3  --> Linha digitavel 3
                         ,pr_lindigi4 => vr_lindigi4  --> Linha digitavel 4
                         ,pr_cdbarras => vr_cdbarras  --> Codigo de Barras
                         ,pr_dtvencto => vr_dtvencto  --> Data Vencimento
                         ,pr_vllanmto => pr_vllanmto  --> Valor Lancamento
                         ,pr_dtagenda => vr_dtmvtopg  --> Data agendamento
                         ,pr_idorigem => 3 /*INTERNET*/ --> Indicador de origem
                         ,pr_indvalid => 0            --> Nao validar horario limite
						             ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                         ,pr_nmextcon => vr_nmconban  --> Nome do banco
                         ,pr_cdseqfat => vr_cdseqfat  --> Codigo Sequencial fatura
                         ,pr_vlfatura => vr_vlrdocum  --> Valor fatura
                         ,pr_nrdigfat => vr_nrdigfat  --> Numero Digito Fatura
                         ,pr_dstransa => vr_dstrans1  --> Descricao transacao
                         ,pr_cdcritic => vr_cdcritic  --> Codigo da critica
                         ,pr_dscritic => vr_dscritic);--> Descricao critica

      -- Verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN

        -- se possui codigo, porém não possui descrição
        IF nvl(vr_cdcritic,0) > 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- buscar descrição
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        END IF;

        IF TRIM(pr_dscedent) IS NOT NULL THEN
          vr_dscritic := vr_dscritic||' - '||pr_dscedent;
        END IF;

        -- Se retornou critica , deve abortar
        RAISE vr_exc_erro;
      END IF;

      /* Efetuada por operador ou responsável de assinatura conjunta de conta PJ */
      -- IF pr_nrcpfope > 0 OR vr_idastcjt = 1 THEN
      IF vr_assin_conjunta = 1 THEN
        vr_lindigit := SUBSTR(TO_CHAR(vr_lindigi1,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(TO_CHAR(vr_lindigi1,'fm000000000000'),12,1) ||' '||
                       SUBSTR(TO_CHAR(vr_lindigi2,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(TO_CHAR(vr_lindigi2,'fm000000000000'),12,1) ||' '||
                       SUBSTR(TO_CHAR(vr_lindigi3,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(TO_CHAR(vr_lindigi3,'fm000000000000'),12,1) ||' '||
                       SUBSTR(TO_CHAR(vr_lindigi4,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(TO_CHAR(vr_lindigi4,'fm000000000000'),12,1);

        --Cria transacao pendente de pagamento
        INET0002.pc_cria_trans_pend_pagto( pr_cdagenci => 90             --> Codigo do PA
                                          ,pr_nrdcaixa => 900            --> Numero do Caixa
                                          ,pr_cdoperad => '996'          --> Codigo do Operados
                                          ,pr_nmdatela => 'INTERNETBANK' --> Nome da Tela
                                          ,pr_idorigem => 3              --> Origem da solicitacao
                                          ,pr_idseqttl => pr_idseqttl    --> Sequencial de Titular
                                          ,pr_nrcpfope => pr_nrcpfope    --> Numero do cpf do operador juridico
                                          ,pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
                                          ,pr_cdcoptfn => vr_cdcoptfn    --> Cooperativa do Terminal
                                          ,pr_cdagetfn => vr_cdagetfn    --> Agencia do Terminal
                                          ,pr_nrterfin => vr_nrterfin    --> Numero do Terminal Financeiro
                                          ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                                          ,pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                                          ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                                          ,pr_idtippag => pr_idtpdpag    --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                          ,pr_vllanmto => pr_vllanmto    --> Valor do pagamento
                                          ,pr_dtmvtopg => pr_dtmvtopg    --> Data do debito
                                          ,pr_idagenda => pr_idagenda    --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                          ,pr_dscedent => pr_dscedent    --> Descricao do cedente do documento
                                          ,pr_dscodbar => pr_cdbarras    --> Descricao do codigo de barras
                                          ,pr_dslindig => vr_lindigit    --> Descricao da linha digitavel
                                          ,pr_vlrdocto => vr_vlrdocum    --> Valor do documento
                                          ,pr_dtvencto => pr_dtvencto    --> Data de vencimento do documento
                                          ,pr_tpcptdoc => pr_tpcptdoc    --> Tipo de captura do documento
                                          ,pr_idtitdda => pr_idtitdda    --> Identificador do titulo no DDA
                                          ,pr_idastcjt => vr_idastcjt    --> Indicador de Assinatura Conjunta
                                          ,pr_cdctrlcs => pr_cdctrlcs    --> Código de controle de consulta
                                          ,pr_cdcritic => vr_cdcritic    --> Codigo de Critica
                                          ,pr_dscritic => vr_dscritic);  --> Descricao de Critica

        -- Verificar se retornou critica
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- se possui codigo, porém não possui descrição
          IF nvl(vr_cdcritic,0) > 0 AND
             TRIM(vr_dscritic) IS NULL THEN
            -- buscar descrição
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          END IF;
          vr_dscritic := vr_dscritic||' - '||pr_dscedent;

          -- Se retornou critica , deve abortar
          RAISE vr_exc_erro;
        END IF;

      -- se nao for agendamento
      ELSIF pr_idagenda = 1 THEN

        --Executar rotina paga_convenio
        PAGA0001.pc_paga_convenio
                         (pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                         ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                         ,pr_idseqttl => pr_idseqttl  --> Sequencial titular
                         ,pr_cdbarras => vr_cdbarras  --> Codigo de Barras
                         ,pr_dscedent => pr_dscedent  --> Descrição do cedente
                         ,pr_cdseqfat => pr_cdseqfat  --> Codigo Sequencial fatura
                         ,pr_vlfatura => pr_vllanmto  --> Valor fatura
                         ,pr_nrdigfat => pr_nrdigfat  --> Numero Digito Fatura
                         ,pr_flgagend => 0 /*FALSE*/  --> Flag agendado
                         ,pr_idorigem => 3 /* INTERNET */ --> Indicador de origem
                         ,pr_cdcoptfn => vr_cdcoptfn  --> Codigo cooperativa transacao
                         ,pr_cdagetfn => vr_cdagetfn  --> Codigo Agencia transacao
                         ,pr_nrterfin => vr_nrterfin  --> Numero terminal financeiro
                         ,pr_nrcpfope => pr_nrcpfope  --> Numero cpf operador
                         ,pr_tpcptdoc => pr_tpcptdoc  --> Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                         ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                         ,pr_dstransa => vr_dstrans1  --> Descricao transacao
                         ,pr_dsprotoc => vr_dsprotoc  --> Descricao Protocolo
                         ,pr_cdbcoctl => vr_cdbcoctl  --> Codigo Banco Centralizador
                         ,pr_cdagectl => vr_cdagectl  --> Codigo Agencia Centralizadora
                         ,pr_cdcritic => vr_cdcritic  --> Codigo da critica
                         ,pr_dscritic => vr_dscritic  --> Descricao critica
                         ,pr_msgofatr => vr_msgofatr  --> Mensagem fatura
                         ,pr_cdempcon => vr_cdempcon
                         ,pr_cdsegmto => vr_cdsegmto);

        -- Verificar se retornou critica
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN

          -- se possui codigo, porém não possui descrição
          IF nvl(vr_cdcritic,0) > 0 AND
             TRIM(vr_dscritic) IS NULL THEN
            -- buscar descrição
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          END IF;
          vr_dscritic := vr_dscritic||' - '||pr_dscedent;

          -- Se retornou critica , deve abortar
          RAISE vr_exc_erro;
        END IF;
      END IF;

    ELSIF pr_idtpdpag = 2  THEN /** Titulo **/
      /* Se valor for acima de VR Boleto, passar
         idtitdda juntamente com o código de barras.
         Tratamento na retorna-valores-titulos-iptu (b2crap14) */
      IF pr_vllanmto >= 250000 AND
         pr_idtitdda > 0 THEN
        vr_cdbarras := pr_cdbarras ||';'||pr_idtitdda;
      END IF;

      --Verificar titulo
      PAGA0001.pc_verifica_titulo(pr_cdcooper => pr_cdcooper           --> Codigo da cooperativa
                                 ,pr_nrdconta => pr_nrdconta           --> Numero da conta
                                 ,pr_idseqttl => pr_idseqttl           --> Sequencial titular
                                 ,pr_idagenda => (CASE                 --> Indicador agendamento
                                                    WHEN pr_idagenda = 1 AND
                                                         nvl(pr_idtitdda,0) <> 0 THEN 3
                                                    ELSE pr_idagenda
                                                  END)
                                 ,pr_lindigi1 => vr_lindigi1           --> Linha digitavel 1
                                 ,pr_lindigi2 => vr_lindigi2           --> Linha digitavel 2
                                 ,pr_lindigi3 => vr_lindigi3           --> Linha digitavel 3
                                 ,pr_lindigi4 => vr_lindigi4           --> Linha digitavel 4
                                 ,pr_lindigi5 => vr_lindigi5           --> Linha digitavel 5
                                 ,pr_cdbarras => vr_cdbarras           --> Codigo de Barras
                                 ,pr_vllanmto => pr_vllanmto           --> Valor Lancamento
                                 ,pr_dtagenda => vr_dtmvtopg           --> Data agendamento
                                 ,pr_idorigem => 3 /* INTERNET */      --> Indicador de origem
                                 ,pr_indvalid => 0                     --> Validar
								                 ,pr_flmobile => pr_flmobile           --> Indicador Mobile
                                 ,pr_cdctrlcs => pr_cdctrlcs           --> Numero de controle da consulta no NPC
                                 ,pr_nmextbcc => vr_nmconban           --> Nome do banco
                                 ,pr_vlfatura => vr_vlrdocum           --> Valor fatura
                                 ,pr_dtdifere => vr_dtdifere           --> Indicador data diferente
                                 ,pr_vldifere => vr_vldifere           --> Indicador valor diferente
                                 ,pr_nrctacob => vr_nrctacob           --> Numero Conta Cobranca
                                 ,pr_insittit => vr_insittit           --> Indicador Situacao Titulo
                                 ,pr_intitcop => vr_intitcop           --> Indicador Titulo Cooperativa
                                 ,pr_nrcnvcob => vr_nrcnvcob           --> Numero Convenio Cobranca
                                 ,pr_nrboleto => vr_nrboleto           --> Numero Boleto
                                 ,pr_nrdctabb => vr_nrdctabb           --> Numero conta
                                 ,pr_dstransa => vr_dstrans1           --> Descricao transacao
                                 /* cob reg */
                                 ,pr_cobregis => vr_cobregis           --> Cobranca Registrada
                                 ,pr_msgalert => vr_msgalert           --> mensagem alerta
                                 ,pr_vlrjuros => vr_vlrjuros           --> Valor Juros
                                 ,pr_vlrmulta => vr_vlrmulta           --> Valor Multa
                                 ,pr_vldescto => vr_vldescto           --> Valor desconto
                                 ,pr_vlabatim => vr_vlabatim           --> Valor Abatimento
                                 ,pr_vloutdeb => vr_vloutdeb           --> Valor saida debito
                                 ,pr_vloutcre => vr_vloutcre           --> Valor saida credito
                                 ,pr_cdcritic => vr_cdcritic           --> Codigo da critica
                                 ,pr_dscritic => vr_dscritic);         --> Descricao critica
      -- Verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN

        -- se possui codigo, porém não possui descrição
        IF nvl(vr_cdcritic,0) > 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- buscar descrição
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        END IF;
        vr_dscritic := vr_dscritic||' - '||pr_dscedent;

        -- Se retornou critica , deve abortar
        RAISE vr_exc_erro;
      END IF;

      -- Se for executado por um operador juridico
      IF vr_assin_conjunta = 1 THEN
        vr_lindigit :=  SUBSTR(to_char(vr_lindigi1,'fm0000000000'),1,5) ||'.'||
                        SUBSTR(to_char(vr_lindigi1,'fm0000000000'),6,5) ||' '||
                        SUBSTR(to_char(vr_lindigi2,'fm00000000000'),1,5) ||'.'||
                        SUBSTR(to_char(vr_lindigi2,'fm00000000000'),6,6) ||' '||
                        SUBSTR(to_char(vr_lindigi3,'fm00000000000'),1,5) ||'.'||
                        SUBSTR(to_char(vr_lindigi3,'fm00000000000'),6,6) ||' '||
                        to_char(vr_lindigi4,'fm0') ||' '||
                        to_char(vr_lindigi5,'fm00000000000000');

        --Rotina para criacao de transacao pendente
        INET0002.pc_cria_trans_pend_pagto( pr_cdagenci => 90             --> Codigo do PA
                                          ,pr_nrdcaixa => 900            --> Numero do Caixa
                                          ,pr_cdoperad => '996'          --> Codigo do Operados
                                          ,pr_nmdatela => 'INTERNETBANK' --> Nome da Tela
                                          ,pr_idorigem => 3              --> Origem da solicitacao
                                          ,pr_idseqttl => pr_idseqttl    --> Sequencial de Titular
                                          ,pr_nrcpfope => pr_nrcpfope    --> Numero do cpf do operador juridico
                                          ,pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
                                          ,pr_cdcoptfn => vr_cdcoptfn    --> Cooperativa do Terminal
                                          ,pr_cdagetfn => vr_cdagetfn    --> Agencia do Terminal
                                          ,pr_nrterfin => vr_nrterfin    --> Numero do Terminal Financeiro
                                          ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                                          ,pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                                          ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                                          ,pr_idtippag => pr_idtpdpag    --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                          ,pr_vllanmto => pr_vllanmto    --> Valor do pagamento
                                          ,pr_dtmvtopg => pr_dtmvtopg    --> Data do debito
                                          ,pr_idagenda => pr_idagenda    --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                          ,pr_dscedent => pr_dscedent    --> Descricao do cedente do documento
                                          ,pr_dscodbar => pr_cdbarras    --> Descricao do codigo de barras
                                          ,pr_dslindig => vr_lindigit    --> Descricao da linha digitavel
                                          ,pr_vlrdocto => vr_vlrdocum    --> Valor do documento
                                          ,pr_dtvencto => pr_dtvencto    --> Data de vencimento do documento
                                          ,pr_tpcptdoc => pr_tpcptdoc    --> Tipo de captura do documento
                                          ,pr_idtitdda => pr_idtitdda    --> Identificador do titulo no DDA
                                          ,pr_idastcjt => vr_idastcjt    --> Indicador de Assinatura Conjunta
                                          ,pr_cdctrlcs => pr_cdctrlcs    --> Código de controle de consulta
                                          ,pr_cdcritic => vr_cdcritic    --> Codigo de Critica
                                          ,pr_dscritic => vr_dscritic);  --> Descricao de Critica

        -- Verificar se retornou critica
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- se possui codigo, porém não possui descrição
          IF nvl(vr_cdcritic,0) > 0 AND
             TRIM(vr_dscritic) IS NULL THEN
            -- buscar descrição
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          END IF;
          vr_dscritic := vr_dscritic||' - '||pr_dscedent;

          -- Se retornou critica , deve abortar
          RAISE vr_exc_erro;
        END IF;

      -- se nao for agendamento
      ELSIF pr_idagenda = 1 THEN
        --Executar Rotina Pagamento titulo
        PAGA0001.pc_paga_titulo
                           (pr_cdcooper => pr_cdcooper          --Codigo da cooperativa
                           ,pr_nrdconta => pr_nrdconta          --Numero da conta
                           ,pr_idseqttl => pr_idseqttl          --Sequencial titular
                           ,pr_lindigi1 => vr_lindigi1          --Linha digitavel 1
                           ,pr_lindigi2 => vr_lindigi2          --Linha digitavel 2
                           ,pr_lindigi3 => vr_lindigi3          --Linha digitavel 3
                           ,pr_lindigi4 => vr_lindigi4          --Linha digitavel 4
                           ,pr_lindigi5 => vr_lindigi5          --Linha digitavel 5
                           ,pr_cdbarras => vr_cdbarras          --Codigo de Barras
                           ,pr_dscedent => pr_dscedent          --Descricao do Cedente
                           ,pr_vllanmto => pr_vllanmto          --Valor Lancamento
                           ,pr_vlfatura => pr_vlpagame          --Valor fatura
                           ,pr_nrctacob => vr_nrctacob          --Numero Conta Cobranca
                           ,pr_insittit => vr_insittit          --Indicador Situacao Titulo
                           ,pr_intitcop => vr_intitcop          --Indicador Titulo Cooperativa
                           ,pr_nrcnvcob => vr_nrcnvcob          --Numero Convenio Cobranca
                           ,pr_nrboleto => vr_nrboleto          --Numero Boleto
                           ,pr_nrdctabb => vr_nrdctabb          --Numero conta
                           ,pr_idtitdda => pr_idtitdda          --Indicador titulo DDA
                           ,pr_flgagend => 0 /*FALSE*/          --Flag agendado
                           ,pr_idorigem => 3 /* INTERNET */     --Indicador de origem
                           ,pr_cdcoptfn => vr_cdcoptfn          --Codigo cooperativa transacao
                           ,pr_cdagetfn => vr_cdagetfn          --Codigo Agencia transacao
                           ,pr_nrterfin => vr_nrterfin          --Numero terminal financeiro
                           ,pr_vlrjuros => vr_vlrjuros          --Valor Juros
                           ,pr_vlrmulta => vr_vlrmulta          --Valor Multa
                           ,pr_vldescto => vr_vldescto          --Valor desconto
                           ,pr_vlabatim => vr_vlabatim          --Valor Abatimento
                           ,pr_vloutdeb => vr_vloutdeb          --Valor saida debito
                           ,pr_vloutcre => vr_vloutcre          --Valor saida credito
                           ,pr_nrcpfope => pr_nrcpfope          --Numero cpf operador
                           ,pr_tpcptdoc => pr_tpcptdoc          --Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                           ,pr_cdctrlcs => pr_cdctrlcs          --> Numero de controle da consulta no NPC
                           ,pr_dstransa => vr_dstrans1          --Descricao transacao
                           ,pr_dsprotoc => vr_dsprotoc          --Descricao Protocolo
                           ,pr_cdbcoctl => vr_cdbcoctl          --Codigo Banco Centralizador
                           ,pr_cdagectl => vr_cdagectl          --Codigo Agencia Centralizadora
                           ,pr_cdcritic => vr_cdcritic          --C-odigo da critica
                           ,pr_dscritic => vr_dscritic);        --Descricao da critica

        -- Verificar se retornou critica
        IF TRIM(vr_dscritic) IS NOT NULL THEN

          -- se possui codigo, porém não possui descrição
          IF nvl(vr_cdcritic,0) > 0 AND
             TRIM(vr_dscritic) IS NULL THEN
            -- buscar descrição
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          END IF;
          vr_dscritic := vr_dscritic||' - '||pr_dscedent;

          -- Se retornou critica , deve abortar
          RAISE vr_exc_erro;
        END IF;
      END IF;

    END IF;

    /** Pagamento na data corrente **/
    IF pr_idagenda = 1  THEN
      --IF vr_idastcjt = 1 OR vr_assin_conjunta = 1 THEN
      IF vr_assin_conjunta = 1 THEN
        vr_dscritic := 'Pagamento registrado com sucesso. ' ||
                       'Aguardando aprovacao do registro pelos ' ||
                       'demais responsaveis.';
      ELSIF pr_nrcpfope > 0 AND vr_assin_conjunta = 1 THEN
        vr_dscritic := 'Pagamento registrado com sucesso. '||
                       'Aguardando efetivacao do registro pelo preposto.';
      ELSE
        vr_dscritic := 'Pagamento efetuado com sucesso.';

        /** Verifica se eh dia util **/
        IF pr_dtmvtopg <> trunc(SYSDATE)  THEN 
            vr_dscritic := vr_dscritic||' O debito sera efetuado no proximo dia util.';
        END IF;
      END IF;

      pr_xml_dsmsgerr := '<dsmsgsuc>'|| vr_dscritic ||'</dsmsgsuc>'||
                         '<idastcjt>'|| vr_idastcjt ||'</idastcjt>';

    ELSIF pr_idagenda = 2 THEN /** Agendamento de pagamento **/

      --IF vr_idastcjt = 1 OR vr_assin_conjunta = 1 THEN
      IF vr_assin_conjunta = 1 THEN
        vr_dscritic := 'Agendamento de pagamento registrado com sucesso. '||
                       'Aguardando aprovacao do registro pelos demais responsaveis.';
      ELSIF pr_nrcpfope > 0 AND vr_assin_conjunta = 1 THEN /* se nao for executado por um operador */
        vr_dscritic := 'Agendamento de pagamento registrado com sucesso. '||
                       'Aguardando efetivacao do registro pelo preposto.';
      ELSE
        /* Procedimento para gerar os agendamentos de pagamento/transferencia/Credito salario */
        PAGA0002.pc_cadastrar_agendamento
                                 ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                  ,pr_cdagenci => 90           --> Codigo da agencia
                                  ,pr_nrdcaixa => 900          --> Numero do caixa
                                  ,pr_cdoperad => '996'        --> Codigo do operador
                                  ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                  ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                                  ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                  ,pr_dsorigem => 'INTERNET'   --> Descrição de origem do registro
                                  ,pr_cdtiptra => 2            --> Tipo de transação
                                  ,pr_idtpdpag => pr_idtpdpag  --> Indicador de tipo de agendamento
                                  ,pr_dscedent => pr_dscedent  --> Descrição do cedente
                                  ,pr_dscodbar => vr_cdbarras  --> Descrição codbarras
                                  ,pr_lindigi1 => vr_lindigi1  --> 1° parte da linha digitavel
                                  ,pr_lindigi2 => vr_lindigi2  --> 2° parte da linha digitavel
                                  ,pr_lindigi3 => vr_lindigi3  --> 3° parte da linha digitavel
                                  ,pr_lindigi4 => vr_lindigi4  --> 4° parte da linha digitavel
                                  ,pr_lindigi5 => vr_lindigi5  --> 5° parte da linha digitavel
                                  ,pr_cdhistor => 508          --> Codigo do historico
                                  ,pr_dtmvtopg => vr_dtmvtopg  --> Data de pagamento
                                  ,pr_vllanaut => pr_vllanmto  --> Valor do lancamento automatico
                                  ,pr_dtvencto => pr_dtvencto  --> Data de vencimento

                                  ,pr_cddbanco => 0            --> Codigo do banco
                                  ,pr_cdageban => 0            --> Codigo de agencia bancaria

                                  ,pr_nrctadst => 0            --> Numero da conta destino
                                  ,pr_cdcoptfn => 0            --> Codigo que identifica a cooperativa do cash.
                                  ,pr_cdagetfn => 0            --> Numero do pac do cash.
                                  ,pr_nrterfin => 0            --> Numero do terminal financeiro.

                                  ,pr_nrcpfope => pr_nrcpfope  --> Numero do cpf do operador juridico
                                  ,pr_idtitdda => pr_idtitdda  --> Contem o identificador do titulo dda.
                                  ,pr_cdtrapen => 0            --> Codigo da Transacao Pendente
                                  ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                                  ,pr_idtipcar => 0            --> Indicador Tipo Cartão Utilizado
                                  ,pr_nrcartao => 0            --> Nr Cartao

                                  ,pr_cdfinali => 0            --> Codigo de finalidade
                                  ,pr_dstransf => ' '          --> Descricao da transferencia
                                  ,pr_dshistor => ' '          --> Descricao da finalidade
                                  ,pr_cdctrlcs => pr_cdctrlcs  --> Código de controle de consulta
                                  /* parametros de saida */
                                  ,pr_dstransa => vr_dstrans1  --> Descrição de transação
                                  ,pr_msgofatr => vr_msgofatr
                                  ,pr_cdempcon => vr_cdempcon
                                  ,pr_cdsegmto => vr_cdsegmto
                                  ,pr_dscritic => vr_dscritic);--> Descricao critica

        -- Se não localizar critica
        IF TRIM(vr_dscritic) IS NULL THEN
          
          -- Se for Mobile
          IF pr_flmobile = 1 THEN
             vr_dscritic := 'Agendamento realizado com sucesso!'||chr(13)||chr(10)||'O pagamento será efetivado no dia programado, mediante saldo disponível em conta.';
          
          ELSE
          -- Verificar se a data é um dia util, caso não ser, retorna o proximo dia
          vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                     pr_dtmvtolt  => vr_dtmvtopg,
                                                     pr_tipo      => 'P',
                                                     pr_feriado   => TRUE);
          
            vr_dscritic := 'Pagamento agendado com sucesso '||
                         'para o dia '|| to_char(vr_dtmvtopg,'DD/MM/RRRR') ||'.';
          END IF;
          
        -- Se retornou criticapc_cadastrar_agendamento
        ELSE

          vr_dscritic := vr_dscritic||' - '||pr_dscedent;
          -- Se retornou critica , deve abortar
          RAISE vr_exc_erro;

        END IF;

      END IF;

      pr_xml_dsmsgerr := '<dsmsgsuc>'|| vr_dscritic ||'</dsmsgsuc>'||
                         '<idastcjt>'|| vr_idastcjt ||'</idastcjt>';

    END IF;

    pr_xml_msgofatr := '<msgofatr>'|| vr_msgofatr ||'</msgofatr>';
    pr_xml_cdempcon := '<cdempcon>'|| to_char(vr_cdempcon,'fm0000')||'</cdempcon>';
    pr_xml_cdsegmto := '<cdsegmto>'|| to_char(vr_cdsegmto)||'</cdsegmto>';
	pr_xml_dsprotoc := '<dsprotoc>'|| NVL(TRIM(vr_dsprotoc),'') ||'</dsprotoc>';

    pc_proc_geracao_log(pr_flgtrans => 1 /* TRUE*/);
    pr_dsretorn := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';

      pc_proc_geracao_log(pr_flgtrans => 0 /*false*/);

    WHEN OTHERS THEN
      ROLLBACK;

      vr_dscritic := 'Não foi possivel validar pagamento: '||SQLERRM;

      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';

      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      pc_proc_geracao_log(pr_flgtrans => 0 /*false*/);

  END pc_InternetBank27;


  /* Gerar registro de Retorno = 02 - Entrada Confirmada */
  PROCEDURE pc_ent_confirmada ( pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                               ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                               ,pr_nrnosnum IN VARCHAR2                 -- Nosso Numero
                               ,pr_cdbcocob IN INTEGER                  -- Codigo banco cobrança
                               ,pr_cdagecob IN INTEGER                  -- Codigo Agencia cobranca
                               ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                               ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                               ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                               ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                               ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                               ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                               /* parametros de erro */
                               ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_ent_confirmada        Antiga: b1wgen0089.p/ent-confirmada
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 17/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 02 - Entrada Confirmada
    --
    --   Alteração: 17/10/2014 - Realizar baixa caso o boleto 85 já foi
    --                           liquidado antes de receber a confirmação de entrada no BB (Odirlei/AMcom)
    --
    --              31/10/2014 - Ajuste para antes de enviar instruçao de protesto
    --                           verificar se o boleto já foi liquidado (SD 197217 Odirlei-Amcom)
    --
    --              26/02/2015 - Verificar cdtitprt antes abrir o cursor cr_crapcob_85, pois
    --                           estava gerando erro ao confirmar entrada do título. (Rafael)
    --
    --              17/05/2016 - Inclusao de parametro para apuracao (P213 - Marcos/Supero)
    -- ..........................................................................*/

    -------------------> CURSORES <-------------------
    --Selecionar Cadastro Cobranca
    CURSOR cr_crapcco (pr_cdcooper IN crapcco.cdcooper%type
                      ,pr_cddbanco IN crapcco.cddbanco%type
                      ,pr_flgregis IN crapcco.flgregis%type
                      ,pr_nrconven IN crapcco.nrconven%type
                      ,pr_dsorgarq IN crapcco.dsorgarq%type) IS
      SELECT crapcco.nrconven
            ,crapcco.nrdctabb
            ,crapcco.cddbanco
            ,crapcco.cdcartei
      FROM crapcco
      WHERE crapcco.cdcooper = pr_cdcooper
      AND   crapcco.nrconven = pr_nrconven
      AND   crapcco.dsorgarq = pr_dsorgarq
      AND   crapcco.cddbanco = pr_cddbanco
      AND   crapcco.flgregis = pr_flgregis
      ORDER BY crapcco.progress_recid ASC;
    rw_crapcco cr_crapcco%ROWTYPE;

    -- Selecionar controle retorno titulos bancarios
    CURSOR cr_crapcre (pr_cdcooper IN crapcre.cdcooper%type
                      ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                      ,pr_intipmvt IN crapcre.intipmvt%type
                      ,pr_flgproce IN crapcre.flgproce%type) IS
      SELECT crapcre.nrremret,
             crapcre.nrcnvcob,
             crapcre.cdcooper
        FROM crapcre
       WHERE crapcre.cdcooper = pr_cdcooper
         AND crapcre.nrcnvcob = pr_nrcnvcob
         AND crapcre.intipmvt = pr_intipmvt
         AND crapcre.flgproce = pr_flgproce
       ORDER BY crapcre.progress_recid DESC; --FIND LAST
    rw_crapcre cr_crapcre%ROWTYPE;

    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrremret IN craprem.nrremret%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrremret = pr_nrremret
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre = 2
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    -- Cursor para retornar os dados dos bloquetos de cobranca
    CURSOR cr_crapcob_85 (pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE) IS
      SELECT crapcob.rowid
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.cdbandoc = pr_cdbandoc
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdocmto = pr_nrdocmto
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.incobran = 5
       ORDER BY crapcob.progress_recid;
      rw_crapcob_85  cr_crapcob_85%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);

    --variavel de descrição para log
    vr_dsmotivo  VARCHAR2(100);
    vr_craprem   BOOLEAN := FALSE; --Controlar avail da tabela
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;

  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.nrnosnum = pr_nrnosnum,
             crapcob.cdbanpag = pr_cdbcocob,
             crapcob.cdagepag = pr_cdagecob
       WHERE crapcob.rowid  = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;
    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob  --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre  --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo  --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic  --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

     /* se titulo baixado ou pago, entao solicitar baixa */
    IF rw_crapcob.incobran IN (3,5) THEN

      /* gerar pedido de remessa */
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtopr --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       -- Rowid da Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --Criar tabela Remessa
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 2 /* baixar */       --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Criar Log Cobranca */
      vr_dsmotivo:= 'Ent confirmada indevida. Bx solicitada';
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad        --Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                   ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro        --Indicador erro
                                   ,pr_dscritic => vr_dscritic);      --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* ent confirmada indevida */
      vr_cdcritic := 955;
      RAISE vr_exc_erro;

    END IF;  --Fim rw_crapcob.incobran IN (3,5)

    /* Gerar dados para tt-lcm-consolidada */
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 2.Entr. Confirm.*/
                                        ,pr_tplancto => 'T'              --Tipo Lancamento   /* tplancto = "T" Tarifa */
                                        ,pr_vltarifa => 0                --Valor Tarifa
                                        ,pr_cdhistor => 0                --Codigo Historico
                                        ,pr_cdmotivo => NULL             --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);    --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa Cooperado
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /*verificar se cobrança 85 ja foi liquidado*/
    IF TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
       OPEN cr_crapcob_85( pr_cdcooper => gene0002.fn_busca_entrada(1,rw_crapcob.cdtitprt,';')
                          ,pr_nrdconta => gene0002.fn_busca_entrada(2,rw_crapcob.cdtitprt,';')
                          ,pr_nrcnvcob => gene0002.fn_busca_entrada(3,rw_crapcob.cdtitprt,';')
                          ,pr_nrdocmto => gene0002.fn_busca_entrada(4,rw_crapcob.cdtitprt,';')
                          ,pr_cdbandoc => 85);
       FETCH cr_crapcob_85 INTO rw_crapcob_85;
       CLOSE cr_crapcob_85;
    END IF;

    /* Buscar banco correspondente */
    OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_cddbanco => 001
                    ,pr_flgregis => 1 --true
                    ,pr_nrconven => rw_crapcob.nrcnvcob
                    ,pr_dsorgarq => 'PROTESTO');
    --Proximo registro
    FETCH cr_crapcco INTO rw_crapcco;

    /* se convenio do BB for "PROTESTO", entao gerar
       inst automatica de protesto */
    IF cr_crapcco%FOUND AND
       /* somente gerar protesto se ainda nao foi liquidado o boleto 85*/
       rw_crapcob_85.rowid IS NULL THEN

      --Fechar Cursor
      CLOSE cr_crapcco;

      /* verificar movimento de remessa do dia */
      OPEN cr_crapcre (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_intipmvt => 1
                      ,pr_flgproce => 0/*FALSE*/);
      --Posicionar no proximo registro
      FETCH cr_crapcre INTO rw_crapcre;
      --Se nao encontrar
      IF cr_crapcre%NOTFOUND THEN
        --Somente Fechar Cursor
        CLOSE cr_crapcre;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapcre;

        /* verificar se existe alguma instrucao de baixa */
        OPEN cr_craprem (pr_cdcooper => rw_crapcre.cdcooper
                        ,pr_nrcnvcob => rw_crapcre.nrcnvcob
                        ,pr_nrremret => rw_crapcre.nrremret
                        ,pr_nrdconta => rw_crapcob.nrdconta
                        ,pr_nrdocmto => rw_crapcob.nrdocmto);
        FETCH cr_craprem INTO rw_craprem;
        --Se encontrou
        vr_craprem:= cr_craprem%FOUND;
        --Fechar Cursor
        CLOSE cr_craprem;
      END IF;

      /* se nao houver instrucao de baixa, entao comandar protesto */
      IF NOT vr_craprem THEN

        /* prepara remessa para o banco */
        PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                       ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtopr --Data movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                       ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                       ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

        /* cria registro de pedido de baixa ao banco */
        PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                     ,pr_nrremret => vr_nrremret          --Numero Remessa
                                     ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                     ,pr_cdocorre => 9 /* protestar */    --Codigo Ocorrencia
                                     ,pr_cdmotivo => NULL                 --Codigo Motivo
                                     ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                     ,pr_vlabatim => 0                    --Valor Abatimento
                                     ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                     ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        /* Criar Log Cobranca */
        vr_dsmotivo:= 'Inst Autom de Protesto';
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad        --Operador
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                     ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro        --Indicador erro
                                     ,pr_dscritic => vr_dscritic);      --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      END IF; /* IF NOT AVAIL craprem */
    ELSE
      --Somente Fecha Cursor
      CLOSE cr_crapcco;
    END IF; /*Fim cr_crapcco%NOTFOUND*/

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_ent_confirmada. '||sqlerrm;
  END pc_ent_confirmada;

  /* Gerar registro de Retorno = 03 - Entrada Rejeitada */
  PROCEDURE pc_ent_rejeitada  ( pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                               ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                               ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                               ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                               ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                               ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                               ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                                /* parametros de erro */
                               ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_ent_rejeitada        Antiga: b1wgen0089.p/ent-rejeitada
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 16/11/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 03 - Entrada Rejeitada
    --
    --   Alteracoes: 16/11/2017 - Ajustado para que a situação do boleto seja alterada para
    --                            BAIXADO, ao invés de REJEITADO. Também foi afdicionado a lista
    --                            de motivos o código '46' Tipo/Numero de Inscricao do Sacado Invalidos
    --                            (Douglas - Chamado 760923)
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    vr_cdposini INTEGER := 1;
    vr_cdmotivo VARCHAR2(10);
    vr_baixar   BOOLEAN := FALSE;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;

    /* nao gravar log no título para os motivos abaixo */
    IF gene0002.fn_existe_valor('39,00,60',TRIM(pr_dsmotivo),',') = 'S'  OR
       TRIM(pr_dsmotivo) is null THEN
        /* 39 = pedido de protesto nao permitido p/ o titulo
         * 60 = Movto para titulo nao cadastrado
         * 00 = nao cadastrado
         * "" = sem motivo */
        RETURN;
    END IF;

    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /*  Baixar título quando motivo for
        '48' = CEP Inválido
        '52' = Unidade da Federação Inválida
        '16' = Data de Vencimento Inválida
        '17' = Data de Vencimento Anterior a  Data de Emissão
        '24' = Data da Emissão Inválida
        '25' = Data da Emissão Posterior a Data de Entrada
        '51' = CEP incompatível com a Unidade da Federação
        '46' = Tipo/Numero de Inscricao do Sacado Invalidos
    */
    FOR vr_contador in 1..5 LOOP
      vr_cdmotivo := TRIM(SUBSTR(pr_dsmotivo,vr_cdposini, 2));
      vr_cdposini := nvl(vr_cdposini,1) + 2;

      IF trim(vr_cdmotivo) is null THEN
        continue;
      END IF;

      IF vr_cdmotivo in ('48','52','16','17','24','25','51','46') THEN
        vr_baixar := TRUE;
      END IF;
    END LOOP;

    IF vr_baixar THEN
      /** Atualiza crapcob */
      BEGIN
        UPDATE CRAPCOB
           SET crapcob.incobran = 3 /* Baixado */
              ,crapcob.dtdbaixa = pr_crapdat.dtmvtolt
         WHERE crapcob.rowid  = pr_idtabcob
        RETURNING crapcob.incobran
             INTO rw_crapcob.incobran;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    END IF;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob  --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre  --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo  --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic  --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_ent_rejeitada. '||sqlerrm;
  END pc_ent_rejeitada;

  /* Gerar registro de Retorno = 09 - Baixa */
  PROCEDURE pc_proc_baixa  (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                           ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                           ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamentp
                           ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamentp
                           ,pr_dtocorre IN DATE                     -- data da ocorrencia
                           ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                           ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                           ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                           ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                           ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                           ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                            /* parametros de erro */
                           ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                           ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_baixa        Antiga: b1wgen0089.p/proc-baixa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 09 - Baixa
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    IF TRIM(pr_dsmotivo) = '14' THEN
      rw_crapcob.insitcrt := 5;
      rw_crapcob.dtsitcrt := pr_crapdat.dtmvtolt;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.incobran = 3, /* Baixado */
             crapcob.cdbanpag = pr_cdbanpag,
             crapcob.cdagepag = pr_cdagepag,
             crapcob.dtdbaixa = pr_crapdat.dtmvtolt,
             crapcob.indpagto = 0, /* compensação - COMPE */
             crapcob.insitcrt = rw_crapcob.insitcrt,
             crapcob.dtsitcrt = rw_crapcob.dtsitcrt
       WHERE crapcob.rowid  = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    /* Gerar dados para tt-lcm-consolidada */
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 9.Baixa */
                                        ,pr_tplancto => 'T'              --Tipo Lancamento   /* tplancto = "T" Tarifa */
                                        ,pr_vltarifa => 0                --Valor Tarifa
                                        ,pr_cdhistor => 0                --Codigo Historico
                                        ,pr_cdmotivo => NULL             --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);    --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_baixa. '||sqlerrm;
  END pc_proc_baixa;

  /* Gerar registro de Retorno = 12, 13, 14, 19, 20 */
  PROCEDURE pc_proc_conf_instrucao (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                   ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                   ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                   ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                   ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                   ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                   ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                   ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                   ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                    /* parametros de erro */
                                   ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_conf_instrucao        Antiga: b1wgen0089.p/proc-conf-instrucao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 12, 13, 14, 19, 20
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN ( 2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);

    --variavel de descrição para log
    vr_dsmotivo  VARCHAR2(100);
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;
    vr_nrremret  crapret.nrremret%type;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    /* nao logar no titulo qdo conf de receb de inst de protesto/sustacao */
    IF TO_CHAR(pr_cdocorre) NOT IN ('19','20') THEN
      /* Gerar motivos de ocorrencia  */
      PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                       ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                       ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                       ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                       ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                       ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF; -- fim pr_cdocorre NOT IN ('19','20')

    /* Gerar dados para tt-lcm-consolidada */
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 12,13,14,19,20 */
                                        ,pr_tplancto => 'T'              --Tipo Lancamento   /* tplancto = "T" Tarifa */
                                        ,pr_vltarifa => 0                --Valor Tarifa
                                        ,pr_cdhistor => 0                --Codigo Historico
                                        ,pr_cdmotivo => NULL             --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);    --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    CASE pr_cdocorre
      WHEN 19 THEN
        /** Atualiza crapcob */
        BEGIN
          UPDATE CRAPCOB
             SET crapcob.insitcrt = 1, /* com instrução de protesto */
                 crapcob.dtsitcrt = pr_dtocorre
           WHERE crapcob.rowid    = pr_idtabcob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        /* Criar Log Cobranca */
        vr_dsmotivo:= 'Aguardando entrada em cartorio pelo BB';
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad        --Operador
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                     ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro        --Indicador erro
                                     ,pr_dscritic => vr_dscritic);      --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      WHEN 20 THEN
        /** Atualiza crapcob */
        BEGIN
          UPDATE CRAPCOB
             SET crapcob.insitcrt = 2, /* conf inst sustacao */
                 crapcob.dtsitcrt = pr_dtocorre
           WHERE crapcob.rowid    = pr_idtabcob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        /* Criar Log Cobranca */
        vr_dsmotivo:= 'Aguardando sustacao pelo BB';
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad        --Operador
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                     ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro        --Indicador erro
                                     ,pr_dscritic => vr_dscritic);      --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        /* verificar se existe alguma instrucao de baixa */
        OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                        ,pr_nrdconta => rw_crapcob.nrdconta
                        ,pr_nrdocmto => rw_crapcob.nrdocmto
                        ,pr_dtmvtolt => pr_crapdat.dtmvtolt);
        FETCH cr_craprem INTO rw_craprem;

        -- Se encontrou
        IF cr_craprem%NOTFOUND THEN
          CLOSE cr_craprem;
        /* se existir, comandar automaticamente a baixa do banco */
        ELSE
          CLOSE cr_craprem;

          /* gerar pedido de remessa */
          PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                         ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                         ,pr_dtmvtolt => pr_crapdat.dtmvtopr --Data movimento
                                         ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                         ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                         ,pr_rowid_ret => vr_rowid_ret       --Rowid da Remessa Retorno
                                         ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                         ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);       --Descricao Critica
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;

          --cria registro de pedido de baixa ao banco
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => 2                    --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

          --cria registro de sustacao do banco
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => 11                   --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          /* Criar Log Cobranca */
          vr_dsmotivo:= 'Inst Autom de Baixa';
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad        --Operador
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                       ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro        --Indicador erro
                                       ,pr_dscritic => vr_dscritic);      --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF; --Fim cr_craprem%NOTFOUND
      ELSE
        NULL;
    END CASE;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_conf_instrucao. '||sqlerrm;
  END pc_proc_conf_instrucao;

  /* Gerar registro de Retorno = 23 - Remessa a cartório */
  PROCEDURE pc_proc_remessa_cartorio (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_remessa_cartorio        Antiga: b1wgen0089.p/proc-remessa-cartorio
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 23 - Remessa a cartório
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN ( 2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);

    --variavel de descrição para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;


  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Gerar dados para tt-lcm-consolidada */
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 23. Remes. Cart. */
                                        ,pr_tplancto => 'T'              --Tipo Lancamento   /* tplancto = "T" Tarifa */
                                        ,pr_vltarifa => 0                --Valor Tarifa
                                        ,pr_cdhistor => 0                --Codigo Historico
                                        ,pr_cdmotivo => NULL             --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);    --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.insitcrt = 3, /* com remessa a cartório */
             crapcob.dtsitcrt = pr_dtocorre
       WHERE crapcob.rowid    = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* verificar se existe alguma instrucao de baixa */
    OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                    ,pr_dtmvtolt => pr_crapdat.dtmvtolt);
    FETCH cr_craprem INTO rw_craprem;

    -- Se encontrou
    IF cr_craprem%NOTFOUND THEN
      CLOSE cr_craprem;
    /* se existir, comandar automaticamente a baixa do banco */
    ELSE
      CLOSE cr_craprem;

      /* gerar pedido de remessa */
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtopr --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --Rowid da Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --cria registro de pedido de baixa ao banco
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 2                    --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --cria registro de sustacao do banco
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 11                   --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Criar Log Cobranca */
      vr_dsmotivo:= 'Inst Autom de Baixa';
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad        --Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                   ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro        --Indicador erro
                                   ,pr_dscritic => vr_dscritic);      --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF; --Fim cr_craprem%NOTFOUND


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_remessa_cartorio '||sqlerrm;
  END pc_proc_remessa_cartorio;

  /* Gerar registro de Retorno = 24 - Retirada de cartório e manutenção em carteira */
  PROCEDURE pc_proc_retirada_cartorio(pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_retirada_cartorio       Antiga: b1wgen0089.p/proc-retirada-cartorio
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 24 - Retirada de cartório e manutenção em carteira
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN ( 2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    --variavel de descrição para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Gerar dados para tt-lcm-consolidada */
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 24. Retir. Cartor. */
                                        ,pr_tplancto => 'T'              --Tipo Lancamento   /* tplancto = "T" Tarifa */
                                        ,pr_vltarifa => 0                --Valor Tarifa
                                        ,pr_cdhistor => 0                --Codigo Historico
                                        ,pr_cdmotivo => NULL             --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);    --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.insitcrt = 4, /* sustado */
             crapcob.dtsitcrt = pr_dtocorre
       WHERE crapcob.rowid    = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    IF nvl(pr_vltarifa,0) > 0 THEN
      /* Gerar dados para tt-lcm-consolidada */
      PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                          ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 24. Retir. Cartor. */
                                          ,pr_tplancto => 'C'              --Tipo Lancamento  /* tplancto = "C" Cartorio */
                                          ,pr_vltarifa => pr_vltarifa      --Valor Tarifa
                                          ,pr_cdhistor => pr_cdhistor      --Codigo Historico
                                          ,pr_cdmotivo => NULL             --Codigo motivo
                                          ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                          ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);    --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* verificar se existe alguma instrucao de baixa */
    OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                    ,pr_dtmvtolt => pr_crapdat.dtmvtolt);
    FETCH cr_craprem INTO rw_craprem;

    -- Se encontrou
    IF cr_craprem%NOTFOUND THEN
      CLOSE cr_craprem;
    /* se existir, comandar automaticamente a baixa do banco */
    ELSE
      CLOSE cr_craprem;

      /* gerar pedido de remessa */
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtopr --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --Rowid da Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --cria registro de pedido de baixa ao banco
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 2                    --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --cria registro de sustacao do banco
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 11                   --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Criar Log Cobranca */
      vr_dsmotivo:= 'Inst Autom de Baixa';
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad        --Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                   ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro        --Indicador erro
                                   ,pr_dscritic => vr_dscritic);      --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF; --Fim cr_craprem%NOTFOUND

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_retirada_cartorio '||sqlerrm;
  END pc_proc_retirada_cartorio;

  /* Gerar registro de Retorno = 25 - Protestado e Baixado */
  PROCEDURE pc_proc_protestado (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                               ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                               ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
                               ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                               ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                               ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                               ,pr_dtocorre IN DATE                     -- data da ocorrencia
                               ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                               ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                               ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                               ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                               ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                               ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                /* parametros de erro */
                               ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_proc_protestado       Antiga: b1wgen0089.p/proc-protestado
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 25 - Protestado e Baixado
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Gerar dados para tt-lcm-consolidada */
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 25. Protesto */
                                        ,pr_tplancto => 'T'              --Tipo Lancamento   /* tplancto = "T" Tarifa */
                                        ,pr_vltarifa => 0                --Valor Tarifa
                                        ,pr_cdhistor => 0                --Codigo Historico
                                        ,pr_cdmotivo => NULL             --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);    --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    IF nvl(pr_vltarifa,0) > 0 THEN
      /* Gerar dados para tt-lcm-consolidada */
      PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                          ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 24. Retir. Cartor. */
                                          ,pr_tplancto => 'C'              --Tipo Lancamento  /* tplancto = "C" Cartorio */
                                          ,pr_vltarifa => pr_vltarifa      --Valor Tarifa
                                          ,pr_cdhistor => pr_cdhistor      --Codigo Historico
                                          ,pr_cdmotivo => NULL             --Codigo motivo
                                          ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                          ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);    --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.insitcrt = 5,  /* protestado */
             crapcob.incobran = 3,  /* Baixado */
             crapcob.dtsitcrt = pr_dtocorre,
             crapcob.dtdbaixa = pr_dtocorre,
             crapcob.indpagto = 0, /* compensação - COMPE */
             crapcob.cdagepag = pr_cdagepag,
             crapcob.cdbanpag = pr_cdbanpag
       WHERE crapcob.rowid    = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_protestado '||sqlerrm;
  END pc_proc_protestado;

  /* Procedure que gera dados para tt-lcm-consolidada  */
  PROCEDURE pc_prep_lcm_mot_consolidada ( pr_idtabcob IN ROWID         -- ROWID da cobranca
                                         ,pr_cdocorre IN INTEGER       -- Codigo Ocorrencia
                                         ,pr_dsmotivo IN VARCHAR2      -- Descrição do motivo
                                         ,pr_tplancto IN VARCHAR       -- Tipo Lancamento
                                         ,pr_vltarifa IN NUMBER        -- Valor Tarifa
                                         ,pr_cdhistor IN INTEGER       -- Codigo Historico
                                         ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada
                                         ,pr_cdcritic OUT INTEGER      -- Codigo Critica
                                         ,pr_dscritic OUT VARCHAR2) IS -- Descricao Critica
    /* .........................................................................
    --
    --  Programa : pc_prep_lcm_mot_consolidada           Antigo: b1wgen0089.p/prep-tt-lcm-mot-consolidada
    --  Sistema  : Cred
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 09/06/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure que gera dados para tt-lcm-consolidada
  --   Alterações:
  --               09/06/2016 - Inclusão da flag de apuração para as tarifas - Marcos(Supero) */

    --Variaveis Locais
    vr_vltarifa NUMBER;
    vr_cdhistor INTEGER;
    --Variaveis rotina tarifa
    vr_tar_cdhistor INTEGER;
    vr_tar_cdhisest INTEGER;
    vr_tar_vltarifa NUMBER;
    vr_tar_dtdivulg DATE;
    vr_tar_dtvigenc DATE;
    vr_tar_cdfvlcop INTEGER;

    --Variavel Indice tabela
    vr_index VARCHAR2(40);
    --Tabela de memoria de erros
    vr_tab_erro GENE0001.typ_tab_erro;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Mensagem Erro
      vr_dscritic:= 'Registro de Cobranca nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    --Se for lancamento tarifa
    IF  pr_tplancto = 'T' THEN

      --Buscar dados tarifa
      TARI0001.pc_busca_dados_tarifa (pr_cdcooper  => rw_crapcob.cdcooper    --Codigo Cooperativa
                                     ,pr_nrdconta  => rw_crapcob.nrdconta    --Codigo da Conta
                                     ,pr_nrconven  => rw_crapcob.nrcnvcob    --Numero Convenio
                                     ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                     ,pr_cdocorre  => pr_cdocorre            --Codigo Ocorrencia
                                     ,pr_cdmotivo  => pr_dsmotivo            --Codigo Motivo
                                     ,pr_idtabcob  => pr_idtabcob            --Tipo Pessoa
                                     ,pr_flaputar  => 1                      --Deve apurar tarifa
                                     ,pr_cdhistor  => vr_tar_cdhistor        --Codigo Historico
                                     ,pr_cdhisest  => vr_tar_cdhisest        --Historico Estorno
                                     ,pr_vltarifa  => vr_tar_vltarifa        --Valor Tarifa
                                     ,pr_dtdivulg  => vr_tar_dtdivulg        --Data Divulgacao
                                     ,pr_dtvigenc  => vr_tar_dtvigenc        --Data Vigencia
                                     ,pr_cdfvlcop  => vr_tar_cdfvlcop        --Codigo Cooperativa
                                     ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                     ,pr_dscritic  => vr_dscritic            --Descricao Critica
                                     ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Zerar tarifa e historico
        vr_vltarifa:= 0;
        vr_cdhistor:= 0;
      ELSE
        vr_vltarifa:= vr_tar_vltarifa;
        vr_cdhistor:= vr_tar_cdhistor;
      END IF;
    END IF;

    --Se Encontrou tarifa
    IF vr_vltarifa > 0 THEN
      --Montar indice para acessar tabela
      vr_index:= LPad(rw_crapcob.cdcooper,10,'0')||
                 LPad(rw_crapcob.nrdconta,10,'0')||
                 LPad(rw_crapcob.nrcnvcob,10,'0')||
                 LPad(pr_cdocorre,5,'0')||
                 LPad(vr_cdhistor,5,'0');
      --Verificar se a chave existe na tabela
      IF NOT pr_tab_lcm_consolidada.EXISTS(vr_index) THEN
        --Criar registro tabela lancamentos consolidada
        pr_tab_lcm_consolidada(vr_index).cdcooper:= rw_crapcob.cdcooper;
        pr_tab_lcm_consolidada(vr_index).nrdconta:= rw_crapcob.nrdconta;
        pr_tab_lcm_consolidada(vr_index).nrconven:= rw_crapcob.nrcnvcob;
        pr_tab_lcm_consolidada(vr_index).cdocorre:= pr_cdocorre;
        pr_tab_lcm_consolidada(vr_index).cdhistor:= vr_cdhistor;
        pr_tab_lcm_consolidada(vr_index).vllancto:= vr_vltarifa;
        pr_tab_lcm_consolidada(vr_index).tplancto:= pr_tplancto;
        pr_tab_lcm_consolidada(vr_index).qtdregis:= 1;
        pr_tab_lcm_consolidada(vr_index).cdfvlcop:= vr_tar_cdfvlcop;
      ELSE
        --Incrementar valor tarifa
        pr_tab_lcm_consolidada(vr_index).vllancto:= Nvl(pr_tab_lcm_consolidada(vr_index).vllancto,0) + vr_vltarifa;
        --Incrementar quantidade registros
        pr_tab_lcm_consolidada(vr_index).qtdregis:= Nvl(pr_tab_lcm_consolidada(vr_index).qtdregis,0) + 1;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_prep_lcm_mot_consolidada. '||sqlerrm;
  END pc_prep_lcm_mot_consolidada;

  /* Gerar registro de Retorno = 28 - Debito de tarifas/custas */
  PROCEDURE pc_proc_deb_tarifas_custas (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                       ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                       ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
                                       ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                                       ,pr_vloutcre IN NUMBER                   -- Valor credito
                                       ,pr_vloutdeb IN NUMBER                   -- Valor debito
                                       ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                       ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                       ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                       ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                       ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                       ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                       ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                       ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                        /* parametros de erro */
                                       ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_proc_deb_tarifas_custas       Antiga: b1wgen0089.p/proc-debito-tarifas-custas
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 28 - Debito de tarifas/custas
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN ( 2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    --variavel de descrição para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;
    vr_cdhistor craphis.cdhistor%type :=0;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    IF nvl(pr_vloutcre,0) > 0 THEN
      /* Gerar dados para tt-lcm-consolidada */
      PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                          ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 28. Deb Tarif Cust */
                                          ,pr_tplancto => 'L'              --Tipo Lancamento
                                          ,pr_vltarifa => pr_vloutcre      --Valor Tarifa
                                          ,pr_cdhistor => 0                --Codigo Historico
                                          ,pr_cdmotivo => NULL             --Codigo motivo
                                          ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                          ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);    --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;

    IF nvl(pr_vloutdeb,0) > 0 THEN
      IF TRIM(pr_dsmotivo) = '02' THEN /* 02 - Manutencao de Titulo Vencido */
        /* Gerar dados para tt-lcm-consolidada */
        PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid  --ROWID da cobranca
                                            ,pr_cdocorre => pr_cdocorre       --Codigo Ocorrencia /* 28. Deb Tarif Cust */
                                            ,pr_tplancto => 'T'               --Tipo Lancamento
                                            ,pr_vltarifa => nvl(pr_vloutdeb,0)--Valor Tarifa
                                            ,pr_cdhistor => vr_cdhistor       --Codigo Historico
                                            ,pr_cdmotivo => NULL              --Codigo motivo
                                            ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                            ,pr_cdcritic => vr_cdcritic       --Codigo Critica
                                            ,pr_dscritic => vr_dscritic);     --Descricao Critica
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      ELSE
        /* Gerar dados para tt-lcm-consolidada */
        PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid  --ROWID da cobranca
                                            ,pr_cdocorre => pr_cdocorre       --Codigo Ocorrencia /* 28. Deb Tarif Cust */
                                            ,pr_tplancto => 'C'               --Tipo Lancamento   C=Cartorio
                                            ,pr_vltarifa => nvl(pr_vloutdeb,0)--Valor Tarifa
                                            ,pr_cdhistor => 972               --Codigo Historico 972=DESP.CARTORIO
                                            ,pr_cdmotivo => NULL              --Codigo motivo
                                            ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                            ,pr_cdcritic => vr_cdcritic       --Codigo Critica
                                            ,pr_dscritic => vr_dscritic);     --Descricao Critica
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      END IF; -- Fim TRIM(pr_dsmotivo) = '02'

      /* confirmar sustacao de titulo quando houver
         custas de sustacao enviada pelo BB */
      IF TRIM(pr_dsmotivo) = '09' THEN
        /** Atualiza crapcob */
        BEGIN
          UPDATE CRAPCOB
             SET crapcob.insitcrt = 4, /* sustado */
                 crapcob.dtsitcrt = pr_dtocorre
           WHERE crapcob.rowid    = pr_idtabcob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível atualizar crapcob: '||SQLErrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        /* Criar Log Cobranca */
        vr_dsmotivo := 'Sustacao confirmada em '|| to_char(pr_dtocorre, 'DD/MM/RRRR');
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad        --Operador
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                     ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro        --Indicador erro
                                     ,pr_dscritic => vr_dscritic);      --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF; -- Fim TRIM(pr_dsmotivo) = '09'
    END IF;

    IF nvl(pr_vltarifa,0) > 0 THEN
      /* Gerar dados para tt-lcm-consolidada */
      PAGA0002.pc_prep_lcm_mot_consolidada ( pr_idtabcob => rw_crapcob.rowid  --ROWID da cobranca
                                            ,pr_cdocorre => pr_cdocorre       --Codigo Ocorrencia /* 28. Deb Tarif Cust */
                                            ,pr_dsmotivo => pr_dsmotivo       -- Descrição do motivo
                                            ,pr_tplancto => 'T'               --Tipo Lancamento T=tarifa
                                            ,pr_vltarifa => nvl(pr_vltarifa,0)--Valor Tarifa
                                            ,pr_cdhistor => 0                 --Codigo Historico 972=DESP.CARTORIO
                                            ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                            ,pr_cdcritic => vr_cdcritic       --Codigo Critica
                                            ,pr_dscritic => vr_dscritic);     --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF; --Fim nvl(pr_vltarifa,0) > 0

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* verificar se existe alguma instrucao de baixa */
    OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                    ,pr_dtmvtolt => pr_crapdat.dtmvtolt);
    FETCH cr_craprem INTO rw_craprem;

    -- Se encontrou
    IF cr_craprem%NOTFOUND THEN
      CLOSE cr_craprem;
    /* se existir, comandar automaticamente a baixa do banco */
    ELSE
      CLOSE cr_craprem;
      /* gerar pedido de remessa */
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtopr --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --Rowid da Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --cria registro de pedido de baixa ao banco
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 2                    --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_nrseqreg := nvl(vr_nrseqreg,0) + 1;

      --cria registro de sustacao do banco
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 11                   --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Criar Log Cobranca */
      vr_dsmotivo:= 'Inst Autom de Baixa';
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad        --Operador
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                   ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro        --Indicador erro
                                   ,pr_dscritic => vr_dscritic);      --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF; --Fim cr_craprem%NOTFOUND

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_deb_tarifas_custas: '||sqlerrm;
  END pc_proc_deb_tarifas_custas;

  /* Gerar registro de Retorno = Retorno Qualquer */
  PROCEDURE pc_proc_retorno_qualquer (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_proc_retorno_qualquer        Antiga: b1wgen0089.p/proc-retorno-qualquer
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2014.                   Ultima atualizacao: 05/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = Retorno Qualquer
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_retorno_qualquer: '||sqlerrm;
  END pc_proc_retorno_qualquer;

  /* Procedimento para gerar os agendamentos de pagamento/transferencia/Credito salario */
  PROCEDURE pc_cadastrar_agendamento ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_idtpdpag IN INTEGER                --> Indicador de tipo de agendamento
                                      ,pr_dscedent IN craplau.dscedent%TYPE  --> Descrição do cedente
                                      ,pr_dscodbar IN craplau.dscodbar%TYPE  --> Descrição codbarras
                                      ,pr_lindigi1 IN NUMBER                 --> 1° parte da linha digitavel
                                      ,pr_lindigi2 IN NUMBER                 --> 2° parte da linha digitavel
                                      ,pr_lindigi3 IN NUMBER                 --> 3° parte da linha digitavel
                                      ,pr_lindigi4 IN NUMBER                 --> 4° parte da linha digitavel
                                      ,pr_lindigi5 IN NUMBER                 --> 5° parte da linha digitavel
                                      ,pr_cdhistor IN craplau.cdhistor%TYPE  --> Codigo do historico
                                      ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE  --> Data de pagamento
                                      ,pr_vllanaut IN craplau.vllanaut%TYPE  --> Valor do lancamento automatico
                                      ,pr_dtvencto IN craplau.dtvencto%TYPE  --> Data de vencimento
                                      ,pr_cddbanco IN craplau.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN craplau.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctadst IN craplau.nrctadst%TYPE  --> Numero da conta destino
                                      ,pr_cdcoptfn IN craplau.cdcoptfn%TYPE  --> Codigo que identifica a cooperativa do cash.
                                      ,pr_cdagetfn IN craplau.cdagetfn%TYPE  --> Numero do pac do cash.
                                      ,pr_nrterfin IN craplau.nrterfin%TYPE  --> Numero do terminal financeiro.
                                      ,pr_nrcpfope IN craplau.nrcpfope%TYPE  --> Numero do cpf do operador juridico
                                      ,pr_idtitdda IN VARCHAR2               --> Contem o identificador do titulo dda.
                                      ,pr_cdtrapen IN INTEGER                --> Codigo da transacao Pendente
                                      ,pr_flmobile IN INTEGER                --> Indicador Mobile
                                      ,pr_idtipcar IN INTEGER                --> Indicador Tipo Cartão Utilizado
                                      ,pr_nrcartao IN NUMBER                 --> Numero Cartao
                                      ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                      ,pr_dstransf IN VARCHAR2               --> Descricao da transferencia
                                      ,pr_dshistor IN VARCHAR2               --> Descricao da finalidade
                                      ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                                      ,pr_cdctrlcs IN craplau.cdctrlcs%TYPE  --> Código de controle de consulta
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_msgofatr OUT VARCHAR2
                                      ,pr_cdempcon OUT NUMBER
                                      ,pr_cdsegmto OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_cadastrar_agendamento        Antiga: b1wgen0016.p/cadastrar-agendamento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Maio/2015.                   Ultima atualizacao: 05/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedimento para gerar os agendamentos de
    --               pagamento/transferencia/Credito salario
    --
    --  Alteração : 07/05/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)
    --
    --              21/12/2015 - Incluido parametro pr_cdtrapen na procedure pc_cadastrar_agendamento,
    --                           Proj. 131 Assinatura Multipla (Jean Michel).
    --
    --              04/07/2016 - Alterado o tipo do parametro pr_idtitdda de NUMBER(25,0)
    --                           para VARCHAR2 (Douglas - Chamado 462368)
    --
    --              05/08/2016 - Incluido tratamento para verificacao de transacoes duplicadas,
    --                           SD 494025 (Jean Michel).
    --
    ...........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.idastcjt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;

    --> Verificar qual cooperativa de destino
    CURSOR cr_crapcop2 (pr_cdcooper  crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper,
             crapcop.flgofatr
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop2 cr_crapcop2%ROWTYPE;


    --> Verificar qual cooperativa de destino
    CURSOR cr_crapcop (pr_cdageban  crapcop.cdagectl%TYPE) IS
      SELECT crapcop.cdcooper
        FROM crapcop
       WHERE crapcop.cdagectl = pr_cdageban;
    rw_crapcop cr_crapcop%ROWTYPE;

    --> Verificar se eh convenio SICREDI
    CURSOR cr_crapcon (pr_cdcooper  crapcon.cdcooper%TYPE,
                       pr_cdempcon  crapcon.cdempcon%TYPE,
                       pr_cdsegmto  crapcon.cdsegmto%TYPE ) IS
      SELECT crapcon.cdcooper
            ,crapcon.flginter
            ,crapcon.nmextcon
            ,crapcon.flgcnvsi
            ,crapcon.cdhistor
            ,crapcon.nmrescon
            ,crapcon.cdsegmto
            ,crapcon.cdempcon
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;

    /* Validar se o convenio pode ser ofertado comoo debito automatico */
    CURSOR cr_gnconve (pr_cdhistor gnconve.cdhiscxa%TYPE) IS
      SELECT 1
        FROM gnconve
       WHERE gnconve.cdhiscxa = pr_cdhistor
         AND gnconve.flgativo = 1 --TRUE
         AND gnconve.nmarqatu IS NOT NULL
         AND nvl(gnconve.cdhisdeb,0) <> 0;
    rw_gnconve cr_gnconve%ROWTYPE;

    CURSOR cr_crapscn (pr_cdempcon IN crapscn.cdempcon%TYPE
                      ,pr_cdsegmto IN crapscn.cdsegmto%TYPE) IS
       SELECT crapscn.cdsegmto
             ,crapscn.cdempcon
             ,crapscn.dsoparre
             ,crapscn.cddmoden
         FROM crapscn
       WHERE crapscn.cdempcon = pr_cdempcon AND
             crapscn.cdsegmto = pr_cdsegmto AND
             crapscn.dsoparre = 'E'         AND
            (crapscn.cddmoden = 'A'         OR
             crapscn.cddmoden = 'C');
     rw_crapscn cr_crapscn%ROWTYPE;

    --> buscar lote
    CURSOR cr_craplot (pr_cdcooper  craplot.cdcooper%TYPE,
                       pr_dtmvtolt  craplot.dtmvtolt%TYPE,
                       pr_cdagenci  craplot.cdagenci%TYPE,
                       pr_cdbccxlt  craplot.cdbccxlt%TYPE,
                       pr_nrdolote  craplot.nrdolote%TYPE ) IS

      SELECT craplot.cdcooper,
             craplot.nrseqdig,
             craplot.cdbccxlt,
             craplot.nrdolote,
             craplot.rowid
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote
         FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;

    /* busca dados do preposto */
    CURSOR cr_crapsnh (pr_cdcooper  crapsnh.cdcooper%TYPE,
                       pr_nrdconta  crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.cdcooper,
             crapsnh.nrcpfcgc,
             crapsnh.nrdconta
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = 1
         AND crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;

    --> buscar dados avalista terceiro
    CURSOR cr_crapavt (pr_cdcooper  crapsnh.cdcooper%TYPE,
                       pr_nrdconta  crapsnh.nrdconta%TYPE,
                       pr_nrcpfcgc  crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper,
             crapavt.nrdctato,
             crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapavt cr_crapavt%ROWTYPE;


    -- Consultar transferencias intracooperativas duplicadas
    CURSOR cr_craplau_intra(pr_cdcooper IN craplau.cdcooper%TYPE
                           ,pr_nrdconta IN craplau.nrdconta%TYPE
                           ,pr_dtmvtolt IN craplau.dtmvtolt%TYPE
                           ,pr_cdhisdeb IN craplau.cdhistor%TYPE
                           ,pr_vllanmto IN craplau.vllanaut%TYPE
                           ,pr_nrctatrf IN craplau.nrctadst%TYPE
                           ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS

      SELECT MAX(lau.hrtransa)
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta
         AND lau.dtmvtolt = pr_dtmvtolt
         AND lau.cdhistor = pr_cdhisdeb
         AND lau.vllanaut = pr_vllanmto
         AND lau.nrctadst = pr_nrctatrf
         AND lau.insitlau = 1
         AND lau.dtmvtopg = pr_dtmvtopg;

    -- Consultar transferencias intercooperativas duplicadas
    CURSOR cr_craplau_inter(pr_cdcooper IN craplau.cdcooper%TYPE
                           ,pr_nrdconta IN craplau.nrdconta%TYPE
                           ,pr_dtmvtolt IN craplau.dtmvtolt%TYPE
                           ,pr_vllanmto IN craplau.vllanaut%TYPE
                           ,pr_cdagectl IN craplau.cdageban%TYPE
                           ,pr_nrctadst IN craplau.nrdctabb%TYPE
                           ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS

      SELECT MAX(lau.hrtransa)
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta
         AND lau.dtmvtolt = pr_dtmvtolt
         AND lau.cdhistor = 1009
         AND lau.vllanaut = pr_vllanmto
         AND lau.cdageban = pr_cdagectl
         AND lau.nrctadst = pr_nrctadst
         AND lau.insitlau = 1
         AND lau.dtmvtopg = pr_dtmvtopg;

    -- Consultar transferencias TED
    CURSOR cr_craplau_ted(pr_cdcooper IN craptvl.cdcooper%TYPE
                         ,pr_dtmvtolt IN craptvl.dtmvtolt%TYPE
                         ,pr_cdageope IN craptvl.cdagenci%TYPE
                         ,pr_nrdolote IN craptvl.nrdolote%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdconta IN craptvl.nrdconta%TYPE
                         ,pr_cdbanfav IN craptvl.cdbccrcb%TYPE
                         ,pr_cdagefav IN craptvl.cdagercb%TYPE
                         ,pr_nrctafav IN craptvl.nrcctrcb%TYPE
                         ,pr_vldocmto IN craptvl.vldocrcb%TYPE
                         ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS

       SELECT MAX(hrtransa) hrtransa
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.dtmvtolt = pr_dtmvtolt
         AND lau.cdagenci = pr_cdageope
         AND lau.nrdolote = pr_nrdolote
         AND lau.cdbccxlt = pr_cdbccxlt
         AND lau.nrdconta = pr_nrdconta
         AND lau.cddbanco = pr_cdbanfav
         AND lau.cdageban = pr_cdagefav
         AND lau.nrctadst = pr_nrctafav
         AND lau.vllanaut = pr_vldocmto
         AND lau.insitlau = 1
         AND lau.dtmvtopg = pr_dtmvtopg;

    vr_hrtransa_ted craplau.hrtransa%TYPE;
    vr_hrtransa_inter craplcm.hrtransa%TYPE;
    vr_hrtransa_intra craplau.hrtransa%TYPE;

    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic INTEGER;
    --Tabela de memoria de erros
    vr_tab_erro GENE0001.typ_tab_erro;

    vr_idlancto craplau.idlancto%type;

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    vr_dtmvtopg DATE;
    vr_nrdolote NUMBER;
    vr_dslindig VARCHAR2(200);
    vr_tpdvalor INTEGER;
    vr_nmprepos VARCHAR2(200);
    vr_nrcpfpre NUMBER;
    vr_flgachou BOOLEAN;
    vr_dscritic_aux VARCHAR2(200);

    vr_idorigem INTEGER;
    vr_idanalise_fraude tbgen_analise_fraude.idanalise_fraude%TYPE;

  BEGIN

    vr_dtmvtopg := pr_dtmvtopg;

    -- Definir descrição da transação
    IF pr_cdtiptra IN (1,5) THEN
       pr_dstransa := 'Agendamento para Transferencia';
    ELSIF pr_cdtiptra = 2 THEN
      IF pr_idtpdpag = 1 THEN
        pr_dstransa := 'Agendamento para Pagamento de Convenio (fatura)';
      ELSE
        pr_dstransa := 'Agendamento para Pagamento de Titulo';
      END IF;
    ELSIF pr_cdtiptra = 3 THEN
      pr_dstransa := 'Agendamento para Credito de Salario';
    ELSIF pr_cdtiptra = 4 THEN
      pr_dstransa := 'Agendamento para TED';
    END IF;

    -- mensagem critica auxiliar
    vr_dscritic_aux := 'Nao foi possivel agendar ';
    IF pr_cdtiptra IN (1,5) THEN
      vr_dscritic_aux := vr_dscritic_aux||'a transferencia.';
    ELSIF pr_cdtiptra = 2  THEN
      vr_dscritic_aux := vr_dscritic_aux||'o pagamento.';
    ELSIF pr_cdtiptra = 4 THEN
      vr_dscritic_aux := vr_dscritic_aux || 'a TED';
    ELSE
      vr_dscritic_aux := vr_dscritic_aux||'o credito de salario.';
    END IF;

    vr_dscritic_aux := vr_dscritic_aux || ': ';

    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- validar se o dia é um dia util,
    -- do contrario buscar o proximo
    vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => vr_dtmvtopg,
                                               pr_tipo     => 'P',
                                               pr_feriado  => TRUE);

    IF pr_cdtiptra = 1  OR   /** TRANSFERENCIA   **/
       pr_cdtiptra = 3  OR   /** TRANSF. INTER.  **/
       pr_cdtiptra = 5  THEN /** CREDITO SALARIO **/

      --> Verificar qual cooperativa de destino
      OPEN cr_crapcop (pr_cdageban => pr_cdageban);
      FETCH cr_crapcop INTO rw_crapcop;

      --> verificar se encontra registro
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_dscritic := 'Cooperativa de destino nao cadastrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Buscar dados do associado destinatario
      OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper,
                       pr_nrdconta => pr_nrctadst);
      FETCH cr_crapass INTO rw_crabass;
      -- verificar se localizou
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Conta destino nao cadastrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Definir numero de lote
      vr_nrdolote := 11000 + pr_nrdcaixa;
    ELSIF pr_cdtiptra = 2  THEN /** PAGAMENTO **/
      -- Definir numero de lote
      vr_nrdolote := 11000 + pr_nrdcaixa;

      IF pr_idtpdpag = 1 THEN /* Convenio */
        vr_dslindig := SUBSTR(to_char(pr_lindigi1,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(to_char(pr_lindigi1,'fm000000000000'),12,1) ||' '||

                       SUBSTR(to_char(pr_lindigi2,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(to_char(pr_lindigi2,'fm000000000000'),12,1) ||' '||

                       SUBSTR(to_char(pr_lindigi3,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(to_char(pr_lindigi3,'fm000000000000'),12,1) ||' '||

                       SUBSTR(to_char(pr_lindigi4,'fm000000000000'),1,11) ||'-'||
                       SUBSTR(to_char(pr_lindigi4,'fm000000000000'),12,1);

        --> Verificar se eh convenio SICREDI
        OPEN cr_crapcon (pr_cdcooper => pr_cdcooper,
                         pr_cdempcon => SUBSTR(to_char(pr_lindigi2,'fm000000000000'),5,4),
                         pr_cdsegmto => SUBSTR(to_char(pr_lindigi1,'fm000000000000'),2,1));
        FETCH cr_crapcon INTO rw_crapcon;
        -- Verificar se localizou
        IF cr_crapcon%FOUND THEN

          IF rw_crapcon.flgcnvsi = 1 THEN
          vr_tpdvalor := 1;
        END IF;

          OPEN cr_crapcop2 (pr_cdcooper => pr_cdcooper);
          FETCH cr_crapcop2 INTO rw_crapcop2;

          IF rw_crapcop2.flgofatr = 1 THEN

            IF  rw_crapcon.flgcnvsi = 0 THEN
              OPEN cr_gnconve(pr_cdhistor => rw_crapcon.cdhistor);
              FETCH cr_gnconve INTO rw_gnconve;
              vr_flgachou := cr_gnconve%FOUND;
            ELSE
              OPEN cr_crapscn (pr_cdempcon  => rw_crapcon.cdempcon
                              ,pr_cdsegmto  => rw_crapcon.cdsegmto);
              FETCH cr_crapscn INTO rw_crapscn;
              vr_flgachou := cr_crapscn%FOUND;
            END IF;

            IF vr_flgachou THEN
              IF pr_flmobile = 1 THEN
                 pr_msgofatr := 'Deseja incluir sua fatura em Débito Automático?';
              ELSE
                 pr_msgofatr := 'Deseja efetuar o cadastro do Debito Automático?';
              END IF;
              pr_cdempcon := rw_crapcon.cdempcon;
              pr_cdsegmto := rw_crapcon.cdsegmto;
            END IF;

            IF cr_gnconve%ISOPEN THEN
              CLOSE cr_gnconve;
            END IF;

            IF cr_crapscn%ISOPEN THEN
              CLOSE cr_crapscn;
            END IF;

          ELSE
            pr_msgofatr := '';
            pr_cdempcon := 0;
          END IF;

        END IF;

        CLOSE cr_crapcon;
        CLOSE cr_crapcop2;

      ELSIF pr_idtpdpag = 2 THEN /* Titulo */
        vr_dslindig := to_char(pr_lindigi1,'fm00000G00000')||' '||
                       to_char(pr_lindigi2,'fm00000G000000')||' '||
                       to_char(pr_lindigi3,'fm00000G000000')||' '||
                       to_char(pr_lindigi4,'fm0')          ||' '||
                       to_char(pr_lindigi5,'fm00000000000000');

      END IF;
    ELSIF pr_cdtiptra = 4 THEN -- TED

      -- Definir numero do lote
      vr_nrdolote := 11000 + pr_nrdcaixa;

    END IF;

    -- criar savepoint
    SAVEPOINT TRANSACAO;

    BEGIN
      -- Tentar criar registro de lote ate 10 vezes
      -- senao abortar
      FOR i IN 1..10 LOOP
        vr_dscritic := NULL;

        BEGIN
          --> buscar lote
          OPEN cr_craplot (pr_cdcooper  => pr_cdcooper ,
                           pr_dtmvtolt  => pr_dtmvtolt ,
                           pr_cdagenci  => pr_cdagenci ,
                           pr_cdbccxlt  => 100 ,
                           pr_nrdolote  => vr_nrdolote );
          FETCH cr_craplot INTO rw_craplot;
          IF cr_craplot%NOTFOUND THEN
            CLOSE cr_craplot;
            -- se não localizou, deve criar o registro de lote
            BEGIN
              INSERT INTO craplot
                         ( craplot.cdcooper
                          ,craplot.dtmvtolt
                          ,craplot.cdagenci
                          ,craplot.cdbccxlt
                          ,craplot.nrdolote
                          ,craplot.nrdcaixa
                          ,craplot.cdoperad
                          ,craplot.cdopecxa
                          ,craplot.tplotmov)
                  VALUES ( pr_cdcooper   -- craplot.cdcooper
                          ,pr_dtmvtolt   -- craplot.dtmvtolt
                          ,pr_cdagenci   -- craplot.cdagenci
                          ,100            -- craplot.cdbccxlt
                          ,vr_nrdolote   -- craplot.nrdolote
                          ,pr_nrdcaixa   -- craplot.nrdcaixa
                          ,pr_cdoperad   -- craplot.cdoperad
                          ,pr_cdoperad   -- craplot.cdopecxa
                          ,12)            -- craplot.tplotmov
                  RETURNING craplot.rowid,
                            craplot.cdbccxlt,
                            craplot.nrdolote
                  INTO rw_craplot.rowid,
                       rw_craplot.cdbccxlt,
                       rw_craplot.nrdolote;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                RAISE vr_exc_erro;
            END;

          ELSE
            CLOSE cr_craplot;
          END IF;
          -- se não deu erro, sair do loop
          EXIT;

        EXCEPTION
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN

            vr_dscritic := 'Tabela de lotes esta '||
                           'sendo alterada. Tente novamente.';
            -- aguardar um segundo e tentar novamente
            sys.dbms_lock.sleep(1);
            continue;
        END;

      END LOOP;

      -- Atualizar informações no lote
      BEGIN
        UPDATE craplot
           SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
               craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
               craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1,
               /* DEBITO */
               craplot.vlinfodb = nvl(craplot.vlinfodb,0) + pr_vllanaut,
               craplot.vlcompdb = nvl(craplot.vlcompdb,0) + pr_vllanaut
         WHERE craplot.rowid = rw_craplot.rowid
         RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o craplot: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      vr_nmprepos := NULL;
      vr_nrcpfpre := 0;

      IF pr_dsorigem = 'INTERNET' THEN

        -- Buscar dados do preposto apenas quando nao possuir
        -- assinatura multipla
        IF rw_crapass.idastcjt = 0 THEN

          /* busca dados do preposto */
          OPEN cr_crapsnh (pr_cdcooper  => pr_cdcooper,
                           pr_nrdconta  => pr_nrdconta);
          FETCH cr_crapsnh INTO rw_crapsnh;
          -- se localizou
          IF cr_crapsnh%FOUND THEN
            CLOSE cr_crapsnh;
            vr_nrcpfpre := rw_crapsnh.nrcpfcgc;

            --> buscar dados avalista terceiro
            OPEN cr_crapavt (pr_cdcooper => rw_crapsnh.cdcooper,
                             pr_nrdconta => rw_crapsnh.nrdconta,
                             pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);
            FETCH cr_crapavt INTO rw_crapavt;
            -- se localizou
            IF cr_crapavt%FOUND THEN
              CLOSE cr_crapavt;

              -- Buscar da conta do avalista
              OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => rw_crapavt.nrdctato);
              FETCH cr_crapass INTO rw_crabass;
              -- verificar se localizou
              IF cr_crapass%FOUND THEN
                vr_nmprepos := rw_crabass.nmprimtl;
              ELSE
                vr_nmprepos := rw_crapavt.nmdavali;
              END IF;
              CLOSE cr_crapass;
            ELSE
              CLOSE cr_crapavt;
            END IF;

          ELSE
            CLOSE cr_crapsnh;
          END IF;
          /* fim - busca dados do preposto */

        END IF;

      END IF;

      IF pr_cdtiptra IN (1,3) THEN -- Transferencia Intracooperativa / Salario
        OPEN cr_craplau_intra(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_cdhisdeb => pr_cdhistor
                             ,pr_vllanmto => pr_vllanaut
                             ,pr_nrctatrf => pr_nrctadst
                             ,pr_dtmvtopg => vr_dtmvtopg);

        --Posicionar no proximo registro
        FETCH cr_craplau_intra INTO vr_hrtransa_intra;
          --Se encontrar
          IF cr_craplau_intra%FOUND THEN
            --Compara os segundos do último lançamento para não haver duplicidade
            IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrtransa_intra) <= 600 THEN
              vr_dscritic := NULL;
              vr_dscritic_aux := NULL;
              vr_dscritic := 'Ja existe transferencia de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.';
              --Levantar Excecao
              RAISE vr_exc_erro;
      END IF;
          END IF;
        --Fechar Cursor
        CLOSE cr_craplau_intra;

      ELSIF pr_cdtiptra IN (5) THEN -- Transferencia Intercooperativa

        OPEN cr_craplau_inter(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_vllanmto => pr_vllanaut
                             ,pr_cdagectl => pr_cdageban
                             ,pr_nrctadst => pr_nrctadst
                             ,pr_dtmvtopg => vr_dtmvtopg);

        --Posicionar no proximo registro
        FETCH cr_craplau_inter INTO vr_hrtransa_inter;
          --Se encontrar
          IF cr_craplau_inter%FOUND THEN
            --Compara os segundos do último lançamento para não haver duplicidade
            IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrtransa_inter) <= 600 THEN
              vr_dscritic := NULL;
              vr_dscritic_aux := NULL;
              vr_dscritic := 'Ja existe transferencia de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.';
              --Levantar Excecao
              RAISE vr_exc_erro;

            END IF;
          END IF;

        --Fechar Cursor
        CLOSE cr_craplau_inter;

      ELSIF pr_cdtiptra IN (4) THEN -- Transferencia TED

        /* Controle para envio de 2 TEDs iguais pelo ambiente Mobile */
        OPEN cr_craplau_ted(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdageope => pr_cdagenci
                           ,pr_nrdolote => rw_craplot.nrdolote
                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_cdbanfav => pr_cddbanco
                           ,pr_cdagefav => pr_cdageban
                           ,pr_nrctafav => pr_nrctadst
                           ,pr_vldocmto => pr_vllanaut
                           ,pr_dtmvtopg => vr_dtmvtopg);

        --Posicionar no proximo registro
        FETCH cr_craplau_ted INTO vr_hrtransa_ted;

        -- se ja existe um lançamento com os mesmos dados em menos de 10 minutos (600 seg) apresentar alerta
        IF cr_craplau_ted%FOUND AND
          (to_char(SYSDATE,'SSSSS') - NVL(vr_hrtransa_ted,0)) <= 600 THEN
          vr_dscritic := NULL;
          vr_dscritic_aux := NULL;
          vr_dscritic := 'Ja existe TED de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.';
          RAISE vr_exc_erro;
      END IF;
        CLOSE cr_craplau_ted;
      END IF;

      IF pr_cdtiptra IN (1,3) THEN -- Transferencia Intracooperativa / Salario
        OPEN cr_craplau_intra(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_cdhisdeb => pr_cdhistor
                             ,pr_vllanmto => pr_vllanaut
                             ,pr_nrctatrf => pr_nrctadst
                             ,pr_dtmvtopg => vr_dtmvtopg);

        --Posicionar no proximo registro
        FETCH cr_craplau_intra INTO vr_hrtransa_intra;
          --Se encontrar
          IF cr_craplau_intra%FOUND THEN
            --Compara os segundos do último lançamento para não haver duplicidade
            IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrtransa_intra) <= 600 THEN
              vr_dscritic := NULL;
              vr_dscritic_aux := NULL;
              vr_dscritic := 'Ja existe transferencia de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.';
              --Levantar Excecao
              RAISE vr_exc_erro;
      END IF;
          END IF;
        --Fechar Cursor
        CLOSE cr_craplau_intra;

      ELSIF pr_cdtiptra IN (5) THEN -- Transferencia Intercooperativa

        OPEN cr_craplau_inter(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_vllanmto => pr_vllanaut
                             ,pr_cdagectl => pr_cdageban
                             ,pr_nrctadst => pr_nrctadst
                             ,pr_dtmvtopg => vr_dtmvtopg);

        --Posicionar no proximo registro
        FETCH cr_craplau_inter INTO vr_hrtransa_inter;
          --Se encontrar
          IF cr_craplau_inter%FOUND THEN
            --Compara os segundos do último lançamento para não haver duplicidade
            IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrtransa_inter) <= 600 THEN
              vr_dscritic := NULL;
              vr_dscritic_aux := NULL;
              vr_dscritic := 'Ja existe transferencia de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.';
              --Levantar Excecao
              RAISE vr_exc_erro;

            END IF;
          END IF;

        --Fechar Cursor
        CLOSE cr_craplau_inter;

      ELSIF pr_cdtiptra IN (4) THEN -- Transferencia TED

        /* Controle para envio de 2 TEDs iguais pelo ambiente Mobile */
        OPEN cr_craplau_ted(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdageope => pr_cdagenci
                           ,pr_nrdolote => rw_craplot.nrdolote
                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_cdbanfav => pr_cddbanco
                           ,pr_cdagefav => pr_cdageban
                           ,pr_nrctafav => pr_nrctadst
                           ,pr_vldocmto => pr_vllanaut
                           ,pr_dtmvtopg => vr_dtmvtopg);

        --Posicionar no proximo registro
        FETCH cr_craplau_ted INTO vr_hrtransa_ted;

        -- se ja existe um lançamento com os mesmos dados em menos de 10 minutos (600 seg) apresentar alerta
        IF cr_craplau_ted%FOUND AND
          (to_char(SYSDATE,'SSSSS') - NVL(vr_hrtransa_ted,0)) <= 600 THEN
          vr_dscritic := NULL;
          vr_dscritic_aux := NULL;
          vr_dscritic := 'Ja existe TED de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_craplau_ted;
      END IF;

      --> Para TEDs de origens InternetBank e Mobile,
      --> Deve ser gerado o registro de analise de fraude antes de
      --> realizar a operação
      IF pr_cdtiptra IN (4) AND pr_dsorigem = 'INTERNET' THEN

        IF pr_flmobile = 1 THEN
          vr_idorigem := 10; --> MOBILE
        ELSE
          vr_idorigem := 3; --> InternetBank
        END IF;

        vr_idanalise_fraude := NULL;
        --> Rotina para Inclusao do registro de analise de fraude
        AFRA0001.pc_Criar_Analise_Antifraude(pr_cdcooper    => pr_cdcooper
                                            ,pr_cdagenci    => pr_cdagenci
                                            ,pr_nrdconta    => pr_nrdconta
                                            ,pr_cdcanal     => vr_idorigem
                                            ,pr_iptransacao => pr_iptransa
                                            ,pr_dtmvtolt    => pr_dtmvtolt
                                            ,pr_cdproduto   => 30 --> TED
											,pr_cdoperacao  => 12 --> TED Eletronica
                                            ,pr_dstransacao => pr_dstransa
                                            ,pr_tptransacao => 2 --> Agendamento
                                            ,pr_idanalise_fraude => vr_idanalise_fraude
                                            ,pr_dscritic   => vr_dscritic);
        vr_dscritic := NULL;
      END IF;

      BEGIN
        INSERT INTO craplau
                    (craplau.cdcooper
                    ,craplau.nrdconta
                    ,craplau.idseqttl
                    ,craplau.dttransa
                    ,craplau.hrtransa
                    ,craplau.dtmvtolt
                    ,craplau.cdagenci
                    ,craplau.cdbccxlt
                    ,craplau.nrdolote
                    ,craplau.nrseqdig
                    ,craplau.nrdocmto
                    ,craplau.cdhistor
                    ,craplau.dsorigem
                    ,craplau.insitlau
                    ,craplau.cdtiptra
                    ,craplau.dscedent
                    ,craplau.dscodbar
                    ,craplau.dslindig
                    ,craplau.dtmvtopg
                    ,craplau.vllanaut
                    ,craplau.dtvencto
                    ,craplau.cddbanco
                    ,craplau.cdageban
                    ,craplau.nrctadst
                    ,craplau.cdcoptfn
                    ,craplau.cdagetfn
                    ,craplau.nrterfin
                    ,craplau.nrcpfope
                    ,craplau.nrcpfpre
                    ,craplau.nmprepos
                    ,craplau.idtitdda
                    ,craplau.tpdvalor
                    ,craplau.flmobile
                    ,craplau.idtipcar
					          ,craplau.nrcartao
                    ,craplau.idanafrd
                    ,craplau.cdctrlcs 
                    )
             VALUES ( pr_cdcooper               -- craplau.cdcooper
                     ,pr_nrdconta               -- craplau.nrdconta
                     ,pr_idseqttl               -- craplau.idseqttl
                     ,SYSDATE                   -- craplau.dttransa
                     ,gene0002.fn_busca_time    -- craplau.hrtransa
                     ,pr_dtmvtolt               -- craplau.dtmvtolt
                     ,pr_cdagenci               -- craplau.cdagenci
                     ,rw_craplot.cdbccxlt       -- craplau.cdbccxlt
                     ,rw_craplot.nrdolote       -- craplau.nrdolote
                     ,rw_craplot.nrseqdig       -- craplau.nrseqdig
                     ,rw_craplot.nrseqdig       -- craplau.nrdocmto
                     ,pr_cdhistor               -- craplau.cdhistor
                     ,pr_dsorigem               -- craplau.dsorigem
                     ,1  /** PENDENTE  **/      -- craplau.insitlau
                     ,pr_cdtiptra               -- craplau.cdtiptra
                     ,upper(pr_dscedent)        -- craplau.dscedent
                     ,pr_dscodbar               -- craplau.dscodbar
                     ,nvl(vr_dslindig,' ')      -- craplau.dslindig
                     ,vr_dtmvtopg               -- craplau.dtmvtopg
                     ,pr_vllanaut               -- craplau.vllanaut
                     ,pr_dtvencto               -- craplau.dtvencto
                     ,pr_cddbanco               -- craplau.cddbanco
                     ,pr_cdageban               -- craplau.cdageban
                     ,pr_nrctadst               -- craplau.nrctadst
                     ,pr_cdcoptfn               -- craplau.cdcoptfn
                     ,pr_cdagetfn               -- craplau.cdagetfn
                     ,pr_nrterfin               -- craplau.nrterfin
                     ,pr_nrcpfope               -- craplau.nrcpfope
                     ,vr_nrcpfpre               -- craplau.nrcpfpre
                     ,nvl(vr_nmprepos,' ')      -- craplau.nmprepos
                     ,pr_idtitdda               -- craplau.idtitdda
                     ,nvl(vr_tpdvalor,0)        -- craplau.tpdvalor
                     ,pr_flmobile               -- craplau.flmobile
                     ,pr_idtipcar               -- craplau.idtipcar
                     ,pr_nrcartao               -- craplau.nrcartao
                     ,vr_idanalise_fraude       -- craplau.idanafrd
                     ,nvl(pr_cdctrlcs,' ')      -- craplau.cdctrlcs
                     )
                     returning idlancto
                        into vr_idlancto;

        -- Se for TED, criar informações do agendamento
        IF pr_cdtiptra = 4 THEN
          INSERT INTO tbted_det_agendamento
            (idlancto
            ,cdfinalidade
            ,dshistorico
            ,dsidentific)
          VALUES
            (vr_idlancto
            ,pr_cdfinali
            ,pr_dshistor
            ,pr_dstransf);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lançamento automatico: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- rollback das alterações e avortar programa
        ROLLBACK TO TRANSACAO;
        RAISE vr_exc_erro;
      WHEN OTHERS THEN

        btch0001.pc_log_internal_exception(pr_cdcooper);

        vr_dscritic := 'Erro ao criar agendatemto(PAGA0002.pc_cadastrar_agendamento):'||SQLERRM;
        -- rollback das alterações e avortar programa
        ROLLBACK TO TRANSACAO;
        RAISE vr_exc_erro;
    END; -- fim tratamento de rollback to save point

    -- Se for um boleto DDA ou
    -- Nova plataforma de cobrança
    IF pr_idtitdda > 0 OR 
       TRIM(pr_cdctrlcs) IS NOT NULL THEN
       
      --Atualizar situacao titulo
      DDDA0001.pc_atualz_situac_titulo_sacado (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                              ,pr_cdagecxa => pr_cdagenci      -- Codigo da Agencia
                                              ,pr_nrdcaixa => 900              -- Numero do Caixa
                                              ,pr_cdopecxa => '996'            -- Codigo Operador Caixa
                                              ,pr_nmdatela => 'INTERNETBANK'   -- Nome da tela
                                              ,pr_idorigem => 3 /* Internet */ -- Indicador Origem
                                              ,pr_nrdconta => pr_nrdconta      -- Numero da Conta
                                              ,pr_idseqttl => pr_idseqttl      -- Sequencial do titular
                                              ,pr_idtitdda => pr_idtitdda      -- Indicador Titulo DDA
                                              ,pr_cdsittit => 2 /* agendado */ -- Situacao Titulo
                                              ,pr_cdctrlcs => pr_cdctrlcs      -- Identificador da consulta
                                              ,pr_flgerlog => 0                -- Gerar Log
                                              ,pr_cdcritic => vr_cdcritic      -- Codigo de critica
                                              ,pr_dscritic => vr_dscritic);    -- Descrição de critica
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN  
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      END IF;   
    
      pr_dscritic := vr_dscritic_aux || vr_dscritic;
    WHEN OTHERS THEN

      btch0001.pc_log_internal_exception(pr_cdcooper);

      pr_dscritic := vr_dscritic_aux||': '||'Erro ao criar agendamento(PAGA0002.pc_cadastrar_agendamento):'||SQLERRM;
  END pc_cadastrar_agendamento;


  PROCEDURE pc_verif_agend_recor_prog(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_ddagenda IN craplau.idtitdda%TYPE  --> Dia de agendamento
                                      ,pr_qtmesagd IN INTEGER                --> Quantidade de meses
                                      ,pr_dtinicio IN VARCHAR2               --> Data inicial
                                      ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lancamento automatico
                                      ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Numero da conta destino
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_lsdatagd IN VARCHAR2               --> lista de datas agendamento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_tpoperac IN INTEGER                --> tipo de operação
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_nrcpfope IN craplau.nrcpfope%TYPE  --> Numero do cpf do operador juridico
                                      ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_tab_agenda_recorrente OUT CLOB      --> Registros de agendamento recorrentes
                                      ,pr_cdcritic OUT NUMBER                --> codigo de criticas
                                      ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    DECLARE
    -------------------------> VARIAVEIS <-------------------------
    vr_tab_agenda_recorrente     PAGA0002.typ_tab_agenda_recorrente;
    vr_flgtrans       PLS_INTEGER;
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

    BEGIN

      PAGA0002.pc_verif_agend_recorrente(
                pr_cdcooper => pr_cdcooper,
                pr_cdagenci => pr_cdagenci,
                pr_nrdcaixa => pr_nrdcaixa,
                pr_nrdconta => pr_nrdconta,
                pr_idseqttl => pr_idseqttl,
                pr_dtmvtolt => pr_dtmvtolt,
                pr_ddagenda => pr_ddagenda,
                pr_qtmesagd => pr_qtmesagd,
                pr_dtinicio => pr_dtinicio,
                pr_vllanmto => pr_vllanmto,
                pr_cddbanco => pr_cddbanco,
                pr_cdageban => pr_cdageban,
                pr_nrctatrf => pr_nrctatrf,
                pr_cdtiptra => pr_cdtiptra,
                pr_lsdatagd => pr_lsdatagd,
                pr_cdoperad => pr_cdoperad,
                pr_tpoperac => pr_tpoperac,
                pr_dsorigem => pr_dsorigem,
                pr_nrcpfope => pr_nrcpfope,
                pr_nmdatela => pr_nmdatela,
                pr_dstransa => pr_dstransa,
                pr_tab_agenda_recorrente => vr_tab_agenda_recorrente,
                pr_cdcritic => pr_cdcritic,
                pr_dscritic => pr_dscritic);

    -- se possui codigo, porém não possui descrição
    IF nvl(pr_cdcritic,0) > 0 AND
       TRIM(pr_dscritic) IS NULL THEN
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END IF;

    --> DESCARREGAR TEMPTABLE DE LIMITES PARA O CLOB <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_tab_agenda_recorrente, TRUE);
    dbms_lob.open(pr_tab_agenda_recorrente, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_agenda_recorrente
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

    FOR vr_contador IN nvl(vr_tab_agenda_recorrente.FIRST,0)..nvl(vr_tab_agenda_recorrente.LAST,-1) LOOP
      -- tratar boolean
      IF vr_tab_agenda_recorrente(vr_contador).flgtrans THEN
        vr_flgtrans := 1;
      ELSE
        vr_flgtrans := 0;
      END IF;

      -- Montar XML com registros de carencia
      gene0002.pc_escreve_xml(pr_xml            => pr_tab_agenda_recorrente
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     =>
                             '<agenda>'
                          ||   '<dtmvtopg>'||NVL(TO_CHAR(vr_tab_agenda_recorrente(vr_contador).dtmvtopg,'dd/mm/RRRR'),' ')    ||'</dtmvtopg>'
                          ||   '<dtpagext>'||vr_tab_agenda_recorrente(vr_contador).dtpagext    ||'</dtpagext>'
                          ||   '<flgtrans>'||vr_flgtrans                            ||'</flgtrans>'
                          ||   '<dscritic>'||vr_tab_agenda_recorrente(vr_contador).dscritic    ||'</dscritic>'
                          ||   '<vltarifa>'||vr_tab_agenda_recorrente(vr_contador).vltarifa    ||'</vltarifa>'
                          || '</agenda>');
    END LOOP;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_agenda_recorrente
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</raiz>'
                           ,pr_fecha_xml      => TRUE);

    vr_xml_temp := NULL;

    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar operacao:'|| SQLERRM;
    END;
  END pc_verif_agend_recor_prog;

  /* Procedure para validar agendamento recorrente */
  PROCEDURE pc_verif_agend_recorrente (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_ddagenda IN craplau.idtitdda%TYPE  --> Dia de agendamento
                                      ,pr_qtmesagd IN INTEGER                --> Quantidade de meses
                                      ,pr_dtinicio IN VARCHAR2               --> Data inicial
                                      ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lancamento automatico
                                      ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Numero da conta destino
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_lsdatagd IN VARCHAR2               --> lista de datas agendamento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_tpoperac IN INTEGER                --> tipo de operação
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_nrcpfope IN craplau.nrcpfope%TYPE  --> Numero do cpf do operador juridico
                                      ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_tab_agenda_recorrente OUT typ_tab_agenda_recorrente  --> Registros de agendamento recorrentes
                                      ,pr_cdcritic OUT NUMBER                --> codigo de criticas
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_verif_agend_recorrente        Antiga: b1wgen0015.p/verifica_agendamento_recorrente
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Junho/2015.                   Ultima atualizacao: 05/06/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para validar agendamento recorrente
    --
    --
    --  Alteração : 05/06/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    --> Verificar se a conta pertence a um PAC migrado
    CURSOR cr_craptco (pr_cdcooper  craptco.cdcooper%TYPE,
                       pr_nrdconta  craptco.nrdconta%TYPE) IS
      SELECT craptco.cdcopant
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf = 1;
    rw_craptco cr_craptco%ROWTYPE;


    ------------> ESTRUTURAS DE REGISTRO <-----------
    vr_tab_vlapagar   typ_tab_vlapagar;
    vr_split          gene0002.typ_split := gene0002.typ_split();
    vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;


    ----------------> VARIAVEIS <-----------------
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(500);

    vr_dtmvtopg     DATE;
    vr_bkp_dtmvtopg DATE;
    vr_vlapagar     NUMBER;
    vr_vllanmto     NUMBER;
    vr_mmagenda     INTEGER;
    vr_yyagenda     INTEGER;
    vr_ddagenda     INTEGER;
    vr_dtpagext     VARCHAR2(100);
    vr_idxagend     PLS_INTEGER;
    vr_assin_conjunta NUMBER(1);

  BEGIN
    pr_tab_agenda_recorrente.delete;

    IF upper(pr_dsorigem) <> 'TAA' THEN

      vr_vllanmto := 0;
      /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
      INET0001.pc_verifica_operacao
                           (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                           ,pr_cdagenci     => pr_cdagenci         --> Agencia do Associado
                           ,pr_nrdcaixa     => pr_nrdcaixa         --> Numero caixa
                           ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                           ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                           ,pr_dtmvtolt     => pr_dtmvtolt         --> Data Movimento
                           ,pr_idagenda     => 3/* AG.RECORRENTE*/ --> Indicador agenda
                           ,pr_dtmvtopg     => NULL                --> Data Pagamento
                           ,pr_vllanmto     => vr_vllanmto         --> Valor Lancamento
                           ,pr_cddbanco     => pr_cddbanco         --> Codigo banco
                           ,pr_cdageban     => pr_cdageban         --> Codigo Agencia
                           ,pr_nrctatrf     => 0                   --> Numero Conta Transferencia
                           ,pr_cdtiptra     => 0                   --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                           ,pr_cdoperad     => pr_cdoperad         --> Codigo Operador
                           ,pr_tpoperac     => pr_tpoperac         --> 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                           ,pr_flgvalid     => FALSE               --> Indicador validacoes
                           ,pr_dsorigem     => pr_dsorigem         --> Descricao Origem
                           ,pr_nrcpfope     => pr_nrcpfope         --> CPF operador
                           ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos */
                           ,pr_nmdatela     => pr_nmdatela         --> Nome da tela
                           ,pr_dstransa     => pr_dstransa         --> Descricao da transacao
                           ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                           ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                           ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                           ,pr_dscritic     => vr_dscritic
                           ,pr_assin_conjunta => vr_assin_conjunta);       --> Descricao do erro

      -- verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- abortar programa
        RAISE vr_exc_erro;
      END IF;

      IF vr_tab_limite.count = 0 THEN
        vr_dscritic := 'Tabela de limites nao encontrada.';
        -- Abortar programa
        RAISE vr_exc_erro;

      -- TED
      ELSIF pr_tpoperac = 4 THEN
        IF pr_qtmesagd > vr_tab_limite(vr_tab_limite.first).qtmesrec THEN
          vr_dscritic := 'Quantidade de meses invalida.\n Quantidade maxima permitida de '||
                         vr_tab_limite(vr_tab_limite.first).qtmesrec || ' meses.';
          RAISE vr_exc_erro;
        END IF;

      ELSIF pr_qtmesagd > vr_tab_limite(vr_tab_limite.first).qtmesagd  THEN
        vr_dscritic := 'Quantidade de meses invalida.\n Quantidade maxima permitida de '||
                       vr_tab_limite(vr_tab_limite.first).qtmesagd||' meses.';
        -- Abortar programa
        RAISE vr_exc_erro;
      END IF;


    ELSE  -- Se for TAA
      --> para o TAA - Verificar se a conta pertence a um PAC migrado
      OPEN cr_craptco (pr_cdcooper  => pr_cdcooper ,
                       pr_nrdconta  => pr_nrdconta );
      FETCH cr_craptco INTO rw_craptco;

      /** Bloquear agendamentos para conta migrada **/
      IF cr_craptco%FOUND                AND
         trunc(SYSDATE) >= to_date('25/12/2013','DD/MM/RRRR') AND
         rw_craptco.cdcopant <> 4       AND  /* Exceto Concredi    */
         rw_craptco.cdcopant <> 15      THEN /* Exceto Credimilsul */
        vr_dscritic := 'Operacao de agendamento bloqueada.'||
                       ' Entre em contato com seu PA.';

        -- Abortar programa
        RAISE vr_exc_erro;
      END IF;
    END IF;

    vr_mmagenda := SUBSTR(pr_dtinicio,1,2);
    vr_yyagenda := SUBSTR(pr_dtinicio,4,4);

    FOR vr_contador IN 1..pr_qtmesagd LOOP
      vr_ddagenda := pr_ddagenda;
      -- definir data do mes de agendamento
      LOOP
        BEGIN
          vr_dtmvtopg := TO_DATE(lpad(vr_mmagenda,2,'0')||lpad(vr_ddagenda,2,'0')||
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
      vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                 pr_dtmvtolt => vr_dtmvtopg,
                                                 pr_tipo => 'P',
                                                 pr_feriado => TRUE);

      -- Se ao buscar a nova data mudar o mês, buscar a data anteiror
      IF to_char(vr_dtmvtopg,'MM') <>to_char(vr_bkp_dtmvtopg,'MM') THEN
        -- Buscar proximo dia util, caso este não seja
        vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_dtmvtopg,
                                                   pr_tipo => 'A',
                                                   pr_feriado => TRUE);
      END IF;

      IF pr_dsorigem <> 'TAA' THEN
        vr_vllanmto := pr_vllanmto;

        /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
        INET0001.pc_verifica_operacao
                             (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                             ,pr_cdagenci     => pr_cdagenci         --> Agencia do Associado
                             ,pr_nrdcaixa     => pr_nrdcaixa         --> Numero caixa
                             ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                             ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                             ,pr_dtmvtolt     => pr_dtmvtolt         --> Data Movimento
                             ,pr_idagenda     => 3/* AG.RECORRENTE*/ --> Indicador agenda
                             ,pr_dtmvtopg     => vr_dtmvtopg         --> Data Pagamento
                             ,pr_vllanmto     => vr_vllanmto         --> Valor Lancamento
                             ,pr_cddbanco     => pr_cddbanco         --> Codigo banco
                             ,pr_cdageban     => pr_cdageban         --> Codigo Agencia
                             ,pr_nrctatrf     => pr_nrctatrf         --> Numero Conta Transferencia
                             ,pr_cdtiptra     => pr_cdtiptra         --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                             ,pr_cdoperad     => pr_cdoperad         --> Codigo Operador
                             ,pr_tpoperac     => pr_tpoperac         --> 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                             ,pr_flgvalid     => TRUE                --> Indicador validacoes
                             ,pr_dsorigem     => pr_dsorigem         --> Descricao Origem
                             ,pr_nrcpfope     => pr_nrcpfope         --> CPF operador
                             ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos */
                             ,pr_nmdatela     => pr_nmdatela         --> Nome da tela
                             ,pr_dstransa     => pr_dstransa         --> Descricao da transacao
                             ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                             ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                             ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                             ,pr_dscritic     => vr_dscritic
                             ,pr_assin_conjunta => vr_assin_conjunta);       --> Descricao do erro

      END IF;

      /** Se eh a primeira validacao de agendamento recorrente **/
      IF TRIM(pr_lsdatagd) IS NULL THEN
        vr_dtpagext := to_char(vr_dtmvtopg,'DD')|| ' de '|| INITCAP(gene0001.vr_vet_nmmesano(to_char(vr_dtmvtopg,'MM')))
                       || ' de '||to_char(vr_dtmvtopg,'RRRR');

        -- retornar os agendamentos recorrentes na temptable
        vr_idxagend := pr_tab_agenda_recorrente.count();
        pr_tab_agenda_recorrente(vr_idxagend).dtmvtopg := vr_dtmvtopg;
        pr_tab_agenda_recorrente(vr_idxagend).dtpagext := vr_dtpagext;
        pr_tab_agenda_recorrente(vr_idxagend).vltarifa := vr_vllanmto - pr_vllanmto;
        -- armazenar junto a critica
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          pr_tab_agenda_recorrente(vr_idxagend).flgtrans := FALSE;
          pr_tab_agenda_recorrente(vr_idxagend).dscritic := vr_dscritic;
        ELSE
          pr_tab_agenda_recorrente(vr_idxagend).flgtrans := TRUE;
        END IF;
      ELSE
        /** Validacao final para os agendamentos aprovados **/
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL AND
           gene0002.fn_existe_valor(pr_base  => pr_lsdatagd,
                                    pr_busca => to_char(vr_dtmvtopg,'DD/MM/RRRR'),
                                    pr_delimite =>',' ) = 'S' THEN

          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- defini proximo mês
      IF vr_mmagenda = 12 THEN
        vr_mmagenda := 1;
        vr_yyagenda := vr_yyagenda + 1;
      ELSE
        vr_mmagenda := vr_mmagenda + 1;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic = 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := 'Não foi possivel verificar agendamentos recorrentes';
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar agendamentos recorrentes: '||SQLERRM;

      btch0001.pc_log_internal_exception(pr_cdcooper => pr_cdcooper);

  END pc_verif_agend_recorrente;

  /* Procedimento para gerar os agendamentos recorrente */
  PROCEDURE pc_agendamento_recorrente( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_lsdatagd IN VARCHAR2               --> Lista de datas de agendamento
                                      ,pr_cdhistor IN craplau.cdhistor%TYPE  --> Codigo do historico
                                      ,pr_vllanmto IN craplau.vllanaut%TYPE  --> Valor do lancamento automatico
                                      ,pr_cddbanco IN craplau.cddbanco%TYPE  --> Codigo do banco
                                      ,pr_cdageban IN craplau.cdageban%TYPE  --> Codigo de agencia bancaria
                                      ,pr_nrctatrf IN craplau.nrctadst%TYPE  --> Numero da conta destino
                                      ,pr_cdtiptra IN craplau.cdtiptra%TYPE  --> Tipo de transação
                                      ,pr_cdcoptfn IN craplau.cdcoptfn%TYPE  --> Codigo que identifica a cooperativa do cash.
                                      ,pr_cdagetfn IN craplau.cdagetfn%TYPE  --> Numero do pac do cash.
                                      ,pr_nrterfin IN craplau.nrterfin%TYPE  --> Numero do terminal financeiro.
                                      ,pr_flmobile IN INTEGER                --> Indicador Mobile
                                      ,pr_idtipcar IN INTEGER                --> Indicador Tipo Cartão Utilizado
                                      ,pr_nrcartao IN NUMBER                 --> Numero Cartao
                                      ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                      ,pr_dstransf IN VARCHAR2               --> Descricao da transferencia
                                      ,pr_dshistor IN VARCHAR2               --> Descricao da finalidade
                                      ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_cdcritic OUT VARCHAR2              --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_agendamento_recorrente        Antiga: b1wgen0016.p/agendamento-recorrente
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Maio/2015.                   Ultima atualizacao: 08/06/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedimento Procedimento para gerar os agendamentos recorrente
    --
    --  Alteração : 08/06/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.idastcjt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;

    rw_crabass cr_crapass%ROWTYPE;
    rw_crapass2 cr_crapass%ROWTYPE;

    /* busca dados do preposto */
    CURSOR cr_crapsnh (pr_cdcooper  crapsnh.cdcooper%TYPE,
                       pr_nrdconta  crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.cdcooper,
             crapsnh.nrcpfcgc,
             crapsnh.nrdconta
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = 1
         AND crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;

    --> buscar dados avalista terceiro
    CURSOR cr_crapavt (pr_cdcooper  crapsnh.cdcooper%TYPE,
                       pr_nrdconta  crapsnh.nrdconta%TYPE,
                       pr_nrcpfcgc  crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper,
             crapavt.nrdctato,
             crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapavt cr_crapavt%ROWTYPE;

    ------------> ESTRUTURAS DE REGISTRO <-----------
    vr_split          gene0002.typ_split := gene0002.typ_split();

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    vr_dtmvtopg  DATE;
    vr_msgofatr  VARCHAR2(500);
    vr_cdempcon  NUMBER;
    vr_cdsegmto  VARCHAR2(500);

  BEGIN

    -- Buscar da conta do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass2;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Buscar dados do preposto apenas quando nao possuir
    -- assinatura multipla
    IF rw_crapass2.idastcjt = 0 THEN

      /* busca dados do preposto */
      OPEN cr_crapsnh (pr_cdcooper  => pr_cdcooper,
                       pr_nrdconta  => pr_nrdconta);
      FETCH cr_crapsnh INTO rw_crapsnh;
      -- se localizou
      IF cr_crapsnh%FOUND THEN

        --> buscar dados avalista terceiro
        OPEN cr_crapavt (pr_cdcooper => rw_crapsnh.cdcooper,
                         pr_nrdconta => rw_crapsnh.nrdconta,
                         pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);
        FETCH cr_crapavt INTO rw_crapavt;
        -- se localizou
        IF cr_crapavt%FOUND THEN

          -- Buscar da conta do avalista
          OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass INTO rw_crabass;
          CLOSE cr_crapass;
        END IF;
        CLOSE cr_crapavt;

      END IF;
      CLOSE cr_crapsnh;
      /* fim - busca dados do preposto */

    END IF;

    SAVEPOINT TRANSACAO_AGD;
    -- Quebrar lista
    vr_split := gene0002.fn_quebra_string(pr_string  => pr_lsdatagd
                                         ,pr_delimit => ',');
    -- Ler datas
    FOR vr_contador IN vr_split.first..vr_split.last LOOP
      vr_dtmvtopg :=  to_date(vr_split(vr_contador),'DD/MM/RRRR');

      /* Procedimento para gerar os agendamentos de pagamento/transferencia/Credito salario */
      PAGA0002.pc_cadastrar_agendamento
                               ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                ,pr_cdagenci => pr_cdagenci  --> Codigo da agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                                ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                                ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                                ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                ,pr_dsorigem => pr_dsorigem  --> Descrição de origem do registro
                                ,pr_cdtiptra => pr_cdtiptra  --> Tipo de transação
                                ,pr_idtpdpag => 0            --> Indicador de tipo de agendamento
                                ,pr_dscedent => ' '          --> Descrição do cedente
                                ,pr_dscodbar => ' '          --> Descrição codbarras
                                ,pr_lindigi1 => 0            --> 1° parte da linha digitavel
                                ,pr_lindigi2 => 0            --> 2° parte da linha digitavel
                                ,pr_lindigi3 => 0            --> 3° parte da linha digitavel
                                ,pr_lindigi4 => 0            --> 4° parte da linha digitavel
                                ,pr_lindigi5 => 0            --> 5° parte da linha digitavel
                                ,pr_cdhistor => pr_cdhistor  --> Codigo do historico
                                ,pr_dtmvtopg => vr_dtmvtopg  --> Data de pagamento
                                ,pr_vllanaut => pr_vllanmto  --> Valor do lancamento automatico
                                ,pr_dtvencto => NULL         --> Data de vencimento

                                ,pr_cddbanco => pr_cddbanco  --> Codigo do banco
                                ,pr_cdageban => pr_cdageban  --> Codigo de agencia bancaria

                                ,pr_nrctadst => pr_nrctatrf  --> Numero da conta destino
                                ,pr_cdcoptfn => pr_cdcoptfn  --> Codigo que identifica a cooperativa do cash.
                                ,pr_cdagetfn => pr_cdagetfn  --> Numero do pac do cash.
                                ,pr_nrterfin => pr_nrterfin  --> Numero do terminal financeiro.

                                ,pr_nrcpfope => 0            --> Numero do cpf do operador juridico
                                ,pr_idtitdda => 0            --> Contem o identificador do titulo dda.
                                ,pr_cdtrapen => 0            --> Codigo da Transacao Pendente
                                ,pr_flmobile => pr_flmobile  --> Indicador Mobile
                                ,pr_idtipcar => pr_idtipcar  --> Indicador Tipo Cartão Utilizado
                                ,pr_nrcartao => pr_nrcartao  --> Nr Cartao

                                ,pr_cdfinali => pr_cdfinali  --> Codigo de finalidade
                                ,pr_dstransf => pr_dstransf  --> Descricao da transferencia
                                ,pr_dshistor => pr_dshistor  --> Descricao da finalidade
                                ,pr_iptransa => pr_iptransa  --> IP da transacao no IBank/mobile
                                ,pr_cdctrlcs => NULL         --> Código de controle de consulta
                                /* parametros de saida */
                                ,pr_dstransa => pr_dstransa  --> Descrição de transação
                                ,pr_msgofatr => vr_msgofatr
                                ,pr_cdempcon => vr_cdempcon
                                ,pr_cdsegmto => vr_cdsegmto
                                ,pr_dscritic => vr_dscritic);--> Descricao critica

      IF TRIM (vr_dscritic) IS NOT NULL THEN
        ROLLBACK TO TRANSACAO_AGD;
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Nao foi possivel agendar a transferencia.';

    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel agendar a transferencia: '||SQLERRM;
  END pc_agendamento_recorrente;

  /* Procedimento utilizada na TRFSAL para transferencia de salario */
  PROCEDURE pc_tranf_sal_intercooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                          ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                          ,pr_idorigem IN INTEGER                --> Id da origem da transação
                                          ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                          ,pr_rowidlcs IN craplcs.progress_recid%TYPE
                                          ,pr_cdagetrf IN crapccs.cdagetrf%TYPE  --> Numero do PA.
                                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                          ,pr_flgerlog IN BOOLEAN
                                          ,pr_rw_craplot OUT lote0001.cr_craplot%ROWTYPE  --> rowtype saida lote
                                          /* parametros de saida */
                                          ,pr_cdcritic OUT VARCHAR2              --> Codigo da critica
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao critica

  /* ..........................................................................
    --
    --  Programa : pc_tranf_sal_intercooperativa        Antiga: b1wgen0118.p/tranf-salario-intercooperativa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Vanessa Klein
    --  Data     : Agosto/2015.                   Ultima atualizacao: 07/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada na TRFSAL para transferencia de salario
    --
    --  Alteração : 03/08/2015 - Conversão Progress -> Oracle (Vanessa)
    --
    --              27/01/2016 - Ajuste no problema que gerava chave duplicada ao inserir
    --                           na craplcm. Problema do chamado 518911 resolvido na melhoria
    --                           342. (Kelvin)
    --
    --              07/12/2017 - Gravar lote com autonomous transaction para evitar
    --                           conflito com as TEDs (Tiago/Adriano #745339)
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
     /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper  IN crapcop.cdcooper%TYPE,
                      par_cdagetrf IN crapcop.cdagectl%TYPE) IS
       SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.nrtelura
              ,crapcop.dsdircop
              ,crapcop.cdbcoctl
              ,crapcop.cdagectl
              ,crapcop.flgoppag
              ,crapcop.flgopstr
              ,crapcop.inioppag
              ,crapcop.fimoppag
              ,crapcop.iniopstr
              ,crapcop.fimopstr
              ,crapcop.cdagebcb
              ,crapcop.dssigaut
              ,crapcop.cdagesic
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper OR crapcop.cdagectl = par_cdagetrf;
      rw_crapcop cr_crapcop%ROWTYPE;

    /* Verifica o Lancamento de credito salario */
    CURSOR cr_craplcs(pr_rowidlcs craplcs.progress_recid%TYPE) IS

       SELECT lcs.progress_recid rowidlcs
              ,lcs.nrdconta
              ,lcs.nrdocmto
              ,lcs.vllanmto
        FROM craplcs lcs
       WHERE lcs.progress_recid = pr_rowidlcs ;
    rw_craplcs cr_craplcs%ROWTYPE;

    /* Seleciona os registros para enviar o arquivo */
    CURSOR cr_crapccs(pr_cdcooper crapccs.cdcooper%TYPE,
                      pr_nrdconta craplcs.nrdconta%TYPE) IS

       SELECT ccs.cdagenci
             ,ccs.nrdconta
             ,ccs.cdbantrf
             ,ccs.cdagetrf
             ,ccs.nrctatrf
             ,ccs.nrdigtrf
             ,ccs.nmfuncio
             ,ccs.nrcpfcgc
        FROM crapccs ccs
       WHERE ccs.cdcooper = pr_cdcooper AND
             ccs.nrdconta = pr_nrdconta;
    rw_crapccs cr_crapccs%ROWTYPE;

    -- Verifica se ja existe Lancamento
    CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                      pr_cdagenci IN craplot.cdagenci%TYPE,
                      pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                      pr_nrdolote IN craplot.nrdolote%TYPE,
                      pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                      pr_nrdocmto IN craplcs.nrdocmto%TYPE) IS

         SELECT lcm.nrdconta,
                lcm.vllanmto,
                lcm.nrdocmto
           FROM craplcm lcm
          WHERE lcm.cdcooper = pr_cdcooper AND
                lcm.dtmvtolt = pr_dtmvtolt AND
                lcm.cdagenci = pr_cdagenci AND
                lcm.cdbccxlt = pr_cdbccxlt AND
                lcm.nrdolote = pr_nrdolote AND
                lcm.nrdctabb = pr_nrdctabb AND
                lcm.nrdocmto = pr_nrdocmto;
     rw_craplcm cr_craplcm%ROWTYPE;

     rw_craplot lote0001.cr_craplot%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_flgerror INTEGER;

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_tab_erro gene0001.typ_tab_erro;

    vr_dadosdeb VARCHAR2(100);

     BEGIN
        /* Busca Lancamento de credito salario */
        OPEN cr_craplcs(pr_rowidlcs => pr_rowidlcs);
        FETCH cr_craplcs INTO rw_craplcs;

        IF cr_craplcs%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcs;
          vr_cdcritic:= 90;
          vr_dscritic:= gene0001.fn_busca_critica(90);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcs;

        /* Busca Conta transferencia */
        OPEN cr_crapccs(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_craplcs.nrdconta);
        FETCH cr_crapccs INTO rw_crapccs;

        IF cr_crapccs%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapccs;
          vr_cdcritic:= 127;
          vr_dscritic:= gene0001.fn_busca_critica(127);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapccs;

        /* Busca dados da cooperativa remetente*/
        OPEN cr_crapcop(pr_cdcooper  => pr_cdcooper
                       ,par_cdagetrf => 0 );
        FETCH cr_crapcop INTO rw_crapcop;
        --Se nao encontrou
        IF cr_crapcop%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_cdcritic:= 651;
          vr_dscritic:= gene0001.fn_busca_critica(651);

          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcop;

        /* Dados do Remetente */
        vr_dadosdeb := gene0002.fn_mask(rw_crapcop.cdagectl,'z.zz9') || '/' ||
                       gene0002.fn_mask(rw_crapccs.nrdconta,'zz.zzz.zzz.zzz.9') || '/' ||
                       gene0002.fn_mask(rw_crapccs.nrcpfcgc,'zzzzzzzzzzzzz9');


        /* Busca dados da cooperativa Destino*/
        OPEN cr_crapcop(pr_cdcooper  => 0
                       ,par_cdagetrf => pr_cdagetrf);
        FETCH cr_crapcop INTO rw_crapcop;
        --Se nao encontrou
        IF cr_crapcop%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Cooperativa de destino nao encontrada';

          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcop;

        BEGIN
           INSERT INTO craplcs
                      (cdcooper,
                       dtmvtolt,
                       nrdconta,
                       vllanmto,
                       dttransf,
                       cdopetrf,
                       hrtransf,
                       cdopecrd,
                       nrdocmto,
                       cdsitlcs,
                       nmarqenv,
                       cdhistor,
                       nrdolote,
                       nrautdoc,
                       cdagenci,
                       cdbccxlt,
                       flgenvio,
                       idopetrf,
                       flgopfin,
                       nrridlfp)
                SELECT cdcooper,
                       dtmvtolt,
                       nrdconta,
                       vllanmto,
                       dttransf,
                       cdopetrf,
                       hrtransf,
                       cdopecrd,
                       nrdocmto,
                       cdsitlcs,
                       nmarqenv,
                       gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIST_DEB_TEC_B85'),
                       nrdolote,
                       nrautdoc,
                       cdagenci,
                       cdbccxlt,
                       flgenvio,
                       idopetrf,
                       flgopfin,
                       nrridlfp
                  FROM craplcs lcs
                 WHERE lcs.progress_recid =  pr_rowidlcs;

        EXCEPTION
          WHEN OTHERS THEN
             vr_cdcritic := 9999;
             vr_dscritic := 'Erro ao inserir craplcs: ' || pr_rowidlcs || SQLERRM;
             -- Executa a exceção
             RAISE vr_exc_erro;
          END;


        LOTE0001.pc_insere_lote(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 85
                               ,pr_nrdolote => gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_NRLOT_CTASAL_B85')
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_tplotmov => 1
                               ,pr_cdhistor => gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIST_CRE_TEC_B85')
                               ,pr_craplot  => rw_craplot
                               ,pr_dscritic => vr_dscritic);

        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
        END IF;

        OPEN cr_craplcm(pr_cdcooper => rw_craplot.cdcooper,
                        pr_dtmvtolt => rw_craplot.dtmvtolt,
                        pr_cdagenci => rw_craplot.cdagenci,
                        pr_cdbccxlt => rw_craplot.cdbccxlt,
                        pr_nrdolote => rw_craplot.nrdolote,
                        pr_nrdctabb => rw_crapccs.nrctatrf,
                        pr_nrdocmto => rw_craplcs.nrdocmto);
        FETCH cr_craplcm INTO rw_craplcm;

        IF cr_craplcm%FOUND THEN
           vr_cdcritic := 92;
           vr_dscritic := gene0001.fn_busca_critica(92);
           -- fecha cursor
           CLOSE cr_craplcm;
           -- Executa a exceção
           RAISE vr_exc_erro;
       END IF;

       CLOSE cr_craplcm;

         vr_flgerror := 0;

       BEGIN
          INSERT INTO craplcm
                     (cdcooper,
                      dtmvtolt,
                      cdagenci,
                      cdbccxlt,
                      nrdolote,
                      nrdconta,
                      nrdctabb,
                      nrdocmto,
                      cdhistor,
                      vllanmto,
                      nrseqdig,
                      cdpesqbb,
                      cdoperad,
                      hrtransa,
                      cdcoptfn)
                VALUES
                      (rw_craplot.cdcooper,
                       rw_craplot.dtmvtolt,
                       rw_craplot.cdagenci,
                       rw_craplot.cdbccxlt,
                       rw_craplot.nrdolote,
                       rw_crapccs.nrctatrf,
                       rw_crapccs.nrdconta,
                       rw_craplcs.nrdocmto,
                       gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIST_CRE_TEC_B85'),
                       rw_craplcs.vllanmto,
                         rw_craplot.nrseqdig,
                       vr_dadosdeb, /* Remetente */
                       pr_cdoperad,
                       TO_CHAR(SYSDATE, 'SSSSS'),
                       pr_cdcooper)
             RETURNING craplcm.nrdconta,
                       craplcm.vllanmto,
                       craplcm.nrdocmto
                  INTO rw_craplcm.nrdconta,
                       rw_craplcm.vllanmto,
                       rw_craplcm.nrdocmto;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir craplcm: ' || rw_crapccs.nrdconta || SQLERRM;
            RAISE vr_exc_erro;
        END;

        --Atualizar dados do lote no rowtype
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
        rw_craplot.vlcompdb := rw_craplot.vlcompdb + rw_craplcm.vllanmto;
        rw_craplot.vlinfodb := rw_craplot.vlinfodb + rw_craplcm.vllanmto;

        pr_rw_craplot := rw_craplot;

        CXON0022.pc_gera_log (pr_cdcooper          --Codigo Cooperativa
                             ,rw_crapccs.cdagenci  --Codigo Agencia
                             ,pr_nrdcaixa          --Numero do caixa
                             ,pr_cdoperad          --Codigo Operador
                             ,rw_crapcop.cdcooper  --Codigo Cooperativa
                             ,rw_crapccs.nrdconta  --Numero Conta destino
                             ,rw_crapccs.nrctatrf  --Conta de Destino
                             ,3                    --Tipo de Operacao
                             ,rw_craplcm.vllanmto  --Valor da transacao
                             ,rw_craplcm.nrdocmto  --Numero Documento
                             ,0                    --Cod Agencia
                             ,vr_cdcritic          --Codigo do erro
                             ,vr_dscritic);        --Descricao do erro

     EXCEPTION
       WHEN vr_exc_erro THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;

            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);


       WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Nao foi possivel efetuar a transferencia: '||SQLERRM;

 END pc_tranf_sal_intercooperativa;

 /* Procedimento para listar convenios aceitos */
  PROCEDURE pc_convenios_aceitos(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 /* parametros de saida */
                                ,pr_tab_convenios OUT PAGA0002.typ_tab_convenios --Tabelas de retorno de convenios aceitos
                                ,pr_cdcritic OUT VARCHAR2              --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2) IS          --> Descricao critica

  /* ..........................................................................
    --
    --  Programa : pc_convenios_aceitos    Antiga: b1wgen0016.p/convenios_aceitos
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jorge Hamaguchi
    --  Data     : Janeiro/2016.                   Ultima atualizacao: 00/00/0000
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada para listar convenios aceitos
    --
    --  Alteração :
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    /* Verifica o Lancamento de credito salario */
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE) IS
    SELECT crapage.hrcancel
    FROM   crapage
    WHERE  crapage.cdcooper = pr_cdcooper
    AND    crapage.cdagenci = 90; /* internet */
    rw_crapage cr_crapage%ROWTYPE;

    CURSOR cr_crapcon(pr_cdcooper IN crapcon.cdcooper%TYPE) IS
    SELECT crapcon.nmextcon
          ,crapcon.nmrescon
          ,crapcon.cdempcon
          ,crapcon.cdsegmto
          ,crapcon.flgcnvsi
    FROM   crapcon
    WHERE  crapcon.cdcooper = pr_cdcooper
    AND    crapcon.flginter = 1
    ORDER BY crapcon.nmextcon;
    rw_crapcon cr_crapcon%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_tab_erro gene0001.typ_tab_erro;

    --variavel de index
    vr_nroindex NUMBER := 0;

    vr_dstextab  craptab.dstextab%TYPE;
    vr_dstextab2 craptab.dstextab%TYPE;
    vr_hhsicini  VARCHAR2(5); --HH:MM
    vr_hhsicfim  VARCHAR2(5); --HH:MM
    vr_hhsiccan  VARCHAR2(5); --HH:MM
    vr_hrtitini  VARCHAR2(5); --HH:MM
    vr_hrtitfim  VARCHAR2(5); --HH:MM
    vr_hrcancel  VARCHAR2(5); --HH:MM

    BEGIN
       vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRPGSICRED'
                                                 ,pr_tpregist => 90); --Internet

       vr_hhsicini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(1,vr_dstextab,' '));
       vr_hhsicfim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab,' '));
       vr_hhsiccan := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(3,vr_dstextab,' '));

       vr_dstextab2 := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'GENERI'
                                                  ,pr_cdempres => 0
                                                  ,pr_cdacesso => 'HRTRTITULO'
                                                  ,pr_tpregist => 90); --Internet

       vr_hrtitini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(3,vr_dstextab2,' '));
       vr_hrtitfim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab2,' '));

       OPEN cr_crapage (pr_cdcooper => pr_cdcooper);
       FETCH cr_crapage INTO rw_crapage;
       IF cr_crapage%NOTFOUND THEN
          CLOSE cr_crapage;
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi encontrado informacao do PA';
          -- Executa a exceção
          RAISE vr_exc_erro;
       ELSE
          CLOSE cr_crapage;
          vr_hrcancel := GENE0002.fn_converte_time_data(rw_crapage.hrcancel);
       END IF;

       FOR rw_crapcon IN cr_crapcon(pr_cdcooper => pr_cdcooper) LOOP
          vr_nroindex := vr_nroindex + 1;
          pr_tab_convenios(vr_nroindex).nmextcon := rw_crapcon.nmextcon;
          pr_tab_convenios(vr_nroindex).nmrescon := rw_crapcon.nmrescon;
          pr_tab_convenios(vr_nroindex).cdempcon := rw_crapcon.cdempcon;
          pr_tab_convenios(vr_nroindex).cdsegmto := rw_crapcon.cdsegmto;
          pr_tab_convenios(vr_nroindex).hhoraini := CASE WHEN rw_crapcon.flgcnvsi = 1 THEN vr_hhsicini ELSE vr_hrtitini END;
          pr_tab_convenios(vr_nroindex).hhorafim := CASE WHEN rw_crapcon.flgcnvsi = 1 THEN vr_hhsicfim ELSE vr_hrtitfim END;

          IF (((rw_crapcon.cdempcon = 24 OR rw_crapcon.cdempcon = 98) AND rw_crapcon.cdsegmto = 5) OR
              (rw_crapcon.cdempcon = 119 AND rw_crapcon.cdsegmto = 2)) THEN
             pr_tab_convenios(vr_nroindex).hhoracan := 'Estorno não permitido para este convênio';
          ELSE
             pr_tab_convenios(vr_nroindex).hhoracan := CASE WHEN rw_crapcon.flgcnvsi = 1 THEN vr_hhsiccan ELSE vr_hrcancel END;
          END IF;
       END LOOP;

    EXCEPTION
       WHEN vr_exc_erro THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;

            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 90
                                 ,pr_nrdcaixa => 900
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);
       WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao buscar convenios aceitos: '||SQLERRM;

 END pc_convenios_aceitos;


  /* Auditoria das informações de Auto Atendimento para retorno de sobras posterior */
  PROCEDURE pc_auditoria_auto_atend(pr_dtmvtoan IN crapdat.dtmvtoan%TYPE DEFAULT NULL) IS
  BEGIN
    /* ..........................................................................

       Procedure : pc_auditoria_auto_atend
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Martini
       Data    : Julho/2016                      Ultima atualizacao: 28/08/2016

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado

       Objetivo  : Procedure para efetuar auditoria das informações de auto
                   atendimento para calculo e retorno de Sobras posterior

       Alterações:  28/08/2016 - M360 - Ajustes no continue para verificação do dia util
                               (Marcos-Supero)

                    27/09/2017 - Ajuste no SQL para contagem dos registros de debito automatico
                                 para nao repetir registros. Inclusao dos historicos de
                                 pagamento de fatura de cartao de credito (Anderson SD 644304 e 764559).
  ............................................................................. */
    DECLARE
      -- Códigos de operação
      vr_cdoperac_taa    NUMBER;
      vr_cdoperac_deb    NUMBER;
      vr_cdoperac_mobibk NUMBER;
      -- Tratamento de erros
      vr_dscritic VARCHAR2(1000);
      vr_excsaida EXCEPTION;
      -- Retorno das Cooperativas para processamento
      CURSOR cr_coop IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper <> 3
           AND flgativo = 1;
      rw_coop cr_coop%ROWTYPE;
      -- Calendário
      rw_data btch0001.cr_crapdat%ROWTYPE;
      vr_dtmvtoan crapdat.dtmvtoan%TYPE;
      -- Busca de apuração
      CURSOR cr_apuracao(pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT 1
          FROM tbcc_operacoes_diarias
         WHERE cdcooper = pr_cdcooper
           AND dtoperacao = pr_dtmvtolt
           AND cdoperacao in(vr_cdoperac_taa,vr_cdoperac_deb,vr_cdoperac_mobibk);
      vr_existe NUMBER;
      -- Pagamentos Mobile, iBank e TAA
      CURSOR cr_pagtos(pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT lcm.nrdconta
              ,lcm.cdhistor
              ,COUNT(1) qtdregis
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper /* Cooperativa do Laço */
           AND lcm.cdagenci IN(90,91)
           AND lcm.dtmvtolt = pr_dtmvtolt /* Dia anterior*/
           AND lcm.cdhistor in(508,856) /* Históricos de Pagto IBank e Mobile */
         -- Desconsiderar Estornos
         AND NOT EXISTS(SELECT 1
                            FROM craplcm lcm_est
                           WHERE lcm_est.cdcooper = lcm.cdcooper
                             AND lcm_est.dtmvtolt = lcm.dtmvtolt
                             AND lcm_est.nrdconta = lcm.nrdconta
                             AND lcm_est.cdagenci = lcm.cdagenci
                             AND lcm_est.cdbccxlt = lcm.cdbccxlt
                             AND lcm_est.nrdolote = lcm.nrdolote
                             AND lcm_est.vllanmto = lcm.vllanmto
                             AND lcm_est.nrdctabb = lcm.nrdctabb
                             AND lcm_est.cdhistor = DECODE(lcm.cdhistor,508,570,857)
                           )
         GROUP BY lcm.nrdconta
                 ,lcm.cdhistor;
      -- Pagamentos via DEBAUT
      CURSOR cr_debaut(pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT nrdconta
          ,sum(qtdregis) qtdregis
     FROM (
        SELECT lcm.nrdconta
              ,COUNT(1) qtdregis
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper /* Cooperativa do Laço */
           AND lcm.cdagenci = 1           /* Debitos Automáticos geram cdagenci = 1 */
           AND lcm.dtmvtolt = pr_dtmvtolt /* Dia anterior*/
           /* Caso for necessario recalcular os registros dessa tabela para periodos passados,
              utilizar os historicos do craphis (inautori = 1), pois a tabela crapatr eh apagada
              depois de um tempo que a autorizacao for cancelada. */
           AND lcm.cdhistor IN (SELECT atr.cdhistor
                                  FROM crapatr atr
                                 WHERE atr.cdcooper = lcm.cdcooper
                                   AND atr.nrdconta = lcm.nrdconta)
      GROUP BY lcm.nrdconta
     UNION ALL
        SELECT lcm.nrdconta
              ,COUNT(1) qtdregis
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdhistor = 1545          -- PG.FAT.CARTAO
      GROUP BY lcm.nrdconta
     UNION ALL
        SELECT lcm.nrdconta
              ,COUNT(1) qtdregis
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdhistor = 658          -- PGT.CARTAO BB
      GROUP BY lcm.nrdconta
    ) ORIGEM
    GROUP BY nrdconta;
    
    BEGIN
      -- A rotina só pode ser executada em dias uteis
      IF gene0005.fn_valida_dia_util(3,trunc(SYSDATE)) <> trunc(SYSDATE) OR to_char(SYSDATE,'d') IN(1,7) THEN
        RETURN;
      END IF;
      -- Passada a validação das datas, iremos buscar os códigos de operação para PAgamento TAA, Mobile e iBank
      vr_cdoperac_taa    := gene0001.fn_param_sistema('CRED',0,'CDOPERAC_PAGTO_TAA');
      vr_cdoperac_deb    := gene0001.fn_param_sistema('CRED',0,'CDOPERAC_PAGTO_DEBAUT');
      vr_cdoperac_mobibk := gene0001.fn_param_sistema('CRED',0,'CDOPERAC_PAGTO_MOBIBK');
      -- Buscar todas as cooperativas ativas
      FOR rw_coop IN cr_coop LOOP
        -- Criar bloco para que a execução de uma coop não atrapalhe a outra
        BEGIN
          -- Se não for passado a data
          IF pr_dtmvtoan IS NULL THEN
            -- Estamos na execução via JOB, então buscar o calendário da mesma
            rw_data := NULL;
            OPEN btch0001.cr_crapdat(rw_coop.cdcooper);
            FETCH btch0001.cr_crapdat
             INTO rw_data;
            CLOSE btch0001.cr_crapdat;
            -- Na execução via JOB sonente continuar se estivermos em dia util e fora do processo
            IF trunc(SYSDATE) != rw_data.dtmvtolt THEN
              -- Pular para a próxima cooperativa pois é feriado na mesma
              continue;
            END IF;
            -- Utilizar a data do calendário
            vr_dtmvtoan := rw_data.dtmvtoan;
    ELSE
            -- Utilizar a data do parâmetro
            vr_dtmvtoan := pr_dtmvtoan;
    END IF;
          
          -- Chamar rotina para realizar o processamento dos lançamentos
          -- referentes a Tributacao de Juros ao Capital (22/08/2017 - Renato Darosci)
          -- A rotina é autonoma e em caso de erro não irá para o processo, irá apenas
          -- enviar o e-mail de erro.
          pc_apura_lcm_his_emprestimo(pr_cdcooper => rw_coop.cdcooper
                                     ,pr_dtrefere => vr_dtmvtoan);
          
          -- Também devemos garantir que não tenha havido apuração no dia
          OPEN cr_apuracao(rw_coop.cdcooper,vr_dtmvtoan);
          FETCH cr_apuracao
           INTO vr_existe;
          -- Se encontrou
          IF cr_apuracao%FOUND THEN
            CLOSE cr_apuracao;
            -- Ir para a próxima COOP pois esta já rodou
            continue;
          ELSE
            CLOSE cr_apuracao;
        END IF;
          -- PAssadas as validações, então buscar os pagamentos via iBank e Mobile
          FOR rw_pgto IN cr_pagtos(rw_coop.cdcooper,vr_dtmvtoan) LOOP
            -- Para cada registro, devemos inserir registros de apuração:
            BEGIN
              INSERT
                INTO tbcc_operacoes_diarias(
                     cdcooper
                    ,nrdconta
                    ,cdoperacao
                    ,dtoperacao
                    ,nrsequen
                    ,flgisencao_tarifa)
              VALUES(rw_coop.cdcooper /* Laço da Cooperativa */
                    ,rw_pgto.nrdconta /* Loop acima */
                    ,DECODE(rw_pgto.cdhistor,508,vr_cdoperac_mobibk,vr_cdoperac_taa) /* Tipo conforme histórico */
                    ,vr_dtmvtoan      /* Dia anterior */
                    ,rw_pgto.qtdregis /* Loop acima */
                    ,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir registro de lancamento de TAA e Mobile. Erro: ' || SQLERRM;
                RAISE vr_excsaida;
            END;
          END LOOP;
          -- Por fim, iremos buscar os pagamentos via Débito Automático:
          FOR rw_debaut IN cr_debaut(rw_coop.cdcooper,vr_dtmvtoan) LOOP
            -- Para cada registro, devemos inserir registros de apuração:
            BEGIN
              INSERT
                INTO tbcc_operacoes_diarias(
                     cdcooper
                    ,nrdconta
                    ,cdoperacao
                    ,dtoperacao
                    ,nrsequen
                    ,flgisencao_tarifa)
              VALUES(rw_coop.cdcooper /* Laço da Cooperativa */
                    ,rw_debaut.nrdconta /* Loop acima */
                    ,vr_cdoperac_deb /* Tipo conforme histórico */
                    ,vr_dtmvtoan      /* Dia anterior */
                    ,rw_debaut.qtdregis /* Loop acima */
                    ,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir registro de lancamento de DebAut. Erro: ' || SQLERRM;
                RAISE vr_excsaida;
            END;
          END LOOP;
        EXCEPTION
          WHEN vr_excsaida THEN
            -- Desfazer alterações pendentes
        ROLLBACK;
            -- Efetuar montagem de e-mail
            gene0003.pc_solicita_email(pr_cdcooper    => nvl(rw_coop.cdcooper,3)
                                      ,pr_cdprogra    => 'SOBR0001.AUDIT'
                                      ,pr_des_destino => gene0001.fn_param_sistema('CRED',nvl(rw_coop.cdcooper,3), 'ERRO_EMAIL_JOB')
                                      ,pr_des_assunto => 'Apuração Auto Atendimento – Coop '||NVL(rw_coop.cdcooper,3)
                                      ,pr_des_corpo   => 'Olá, <br><br>'
                                                      || 'Foram encontrados problemas durante o processo de apuração '
                                                      || 'do Auto Atendimento dos Cooperados. <br> '
                                                      || 'Erro encontrado:<br>'||SQLERRM
                                      ,pr_des_anexo   => ''
                                      ,pr_flg_enviar  => 'N'
                                      ,pr_des_erro    => vr_dscritic);
            -- Gravar a solictação do e-mail para envio posterior
            COMMIT;
      WHEN OTHERS THEN
            -- Desfazer alterações pendentes
        ROLLBACK;
            -- Efetuar montagem de e-mail
            gene0003.pc_solicita_email(pr_cdcooper    => nvl(rw_coop.cdcooper,3)
                                      ,pr_cdprogra    => 'SOBR0001.AUDIT'
                                      ,pr_des_destino => gene0001.fn_param_sistema('CRED',nvl(rw_coop.cdcooper,3), 'ERRO_EMAIL_JOB')
                                      ,pr_des_assunto => 'Apuração Auto Atendimento – Coop '||NVL(rw_coop.cdcooper,3)
                                      ,pr_des_corpo   => 'Olá, <br><br>'
                                                      || 'Foram encontrados problemas durante o processo de apuração '
                                                      || 'do Auto Atendimento dos Cooperados. <br> '
                                                      || 'Erro encontrado:<br>'||SQLERRM
                                      ,pr_des_anexo   => ''
                                      ,pr_flg_enviar  => 'N'
                                      ,pr_des_erro    => vr_dscritic);
            -- Gravar a solictação do e-mail para envio posterior
            COMMIT;
        END;
        -- Após processar todos os registros da COop, commitamos
        COMMIT;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- Desfazer alterações pendentes
        ROLLBACK;
        -- Efetuar montagem de e-mail
        gene0003.pc_solicita_email(pr_cdcooper    => nvl(rw_coop.cdcooper,3)
                                  ,pr_cdprogra    => 'RCIP0001'
                                  ,pr_des_destino => gene0001.fn_param_sistema('CRED',nvl(rw_coop.cdcooper,3), 'ERRO_EMAIL_JOB')
                                  ,pr_des_assunto => 'Apuração Auto Atendimento – Coop '||NVL(rw_coop.cdcooper,3)
                                  ,pr_des_corpo   => 'Olá, <br><br>'
                                                  || 'Foram encontrados problemas durante o processo de apuração '
                                                  || 'do Auto Atendimento dos Cooperados. <br> '
                                                  || 'Erro encontrado:<br>'||SQLERRM
                                  ,pr_des_anexo   => ''
                                  ,pr_flg_enviar  => 'N'
                                  ,pr_des_erro    => vr_dscritic);
        -- Gravar a solictação do e-mail para envio posterior
        COMMIT;
    END;


  END pc_auditoria_auto_atend;

 /* Procedimento para sumarizar os agendamentos da debnet */
  PROCEDURE pc_sumario_debnet(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa inicial
                             ,pr_cdcopfin IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa final
                             ,pr_clobxmlc OUT CLOB                  --> XML com informações dos agendamentos
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Descricao critica

    /* ..........................................................................
    --
    --  Programa : pc_sumario_debnet
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Tiago Machado Flor
    --  Data     : Outubro/2016.                   Ultima atualizacao: 00/00/0000
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada sumarizar os agendamentos DEBNET
    --
    --  Alteração : 30/11/2016 Alterado query do sumario da tela debnet pra trazer
    --                         corretamente os resultados (Tiago/Elton SD566237)
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    /* Verifica o Lancamento de credito salario */
    CURSOR cr_craplau(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_insitlau craplau.insitlau%TYPE
                     ,pr_dtmvtopg crapdat.dtmvtolt%TYPE) IS
      SELECT lau.*
        FROM craplau lau, crapass ass
       WHERE lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta
         AND lau.cdcooper = pr_cdcooper
         AND lau.dtmvtopg = pr_dtmvtopg
         AND lau.insitlau = pr_insitlau
         AND UPPER(lau.dsorigem) IN (UPPER('INTERNET'),UPPER('TAA'),UPPER('DEBAUT'))
         AND lau.tpdvalor = DECODE(lau.dsorigem, 'DEBAUT', lau.tpdvalor, 0)
         AND lau.cdtiptra <> 4;

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
    vr_qtefetivados DECIMAL(6);
    vr_qtnaoefetiva DECIMAL(6);
    vr_qtdpendentes DECIMAL(6);
    vr_qtdtotallanc DECIMAL(11);
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_insitlau craplau.insitlau%TYPE;

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


      FOR rw_crapcop1 IN cr_crapcop1(pr_cdcooper => vr_cdcooper)  LOOP

          FOR vr_insitlau IN 1..4 LOOP

              --SOMAR OS LANCAMENTOS PARA ESCREVER DEPOIS NO XML
              FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop1.cdcooper
                                          ,pr_insitlau => vr_insitlau
                                          ,pr_dtmvtopg => rw_crapdat.dtmvtolt) LOOP

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
  END pc_sumario_debnet;

  /* Procedimento para consultar parametros de cancelamento */
  PROCEDURE pc_param_cancelamento(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo do PA
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data Atual de Movimentacao
                                 ,pr_hrfimcan OUT INTEGER                   --> Hora de Fim do Cancelamento
                                 ,pr_dssgproc OUT VARCHAR2
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica

    /* ..........................................................................
    --
    --  Programa : pc_param_cancelamento Antigo: b1wgen0016.p/parametros-cancelamento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Julho/2016.                   Ultima atualizacao: 28/07/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada para consultar parametros de cancelamento
    --
    --  Alteração  :
    --
    -- ..........................................................................*/

    ---------------> VARIAVEIS DE ERROS <-----------------
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     crapcri.dscritic%TYPE;

    -- Variaveis Locais
    vr_dstextab craptab.dstextab%TYPE := '';
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;

  BEGIN

    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'HRTRTITULO'
                                             ,pr_tpregist => pr_cdagenci);

    -- Indica se deve rodar segundo processo para debitos de agendamentos
    pr_dssgproc := SUBSTR(vr_dstextab,15,3);

    -- Consulta data atual e verifica se e dia util ou nao
    vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_excultdia => FALSE);

    -- Horario limite para cancelamento no dia do agendamento
    IF TO_NUMBER(TO_CHAR(pr_dtmvtolt,'d')) IN(1,7) OR
       TRUNC(vr_dtmvtolt) <> TRUNC(pr_dtmvtolt) THEN
      pr_hrfimcan := 86400; --00:00 horas
    ELSE
      pr_hrfimcan := TO_NUMBER(SUBSTR(vr_dstextab,3,5));
    END IF;

  EXCEPTION
      WHEN vr_exc_erro THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PAGA0002.pc_param_cancelamento: ' || SQLERRM;
        ROLLBACK;

  END pc_param_cancelamento;

  /* Procedimento para obter dados de agendamentos */
  PROCEDURE pc_obtem_agendamentos(pr_cdcooper               IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                                 ,pr_cdagenci               IN crapage.cdagenci%TYPE              --> Código do PA
                                 ,pr_nrdcaixa               IN craplot.nrdcaixa%TYPE              --> Numero do Caixa
                                 ,pr_nrdconta               IN crapass.nrdconta%TYPE              --> Numero da Conta
                                 ,pr_dsorigem               IN VARCHAR2                           --> Descricao da Origem
                                 ,pr_dtmvtolt               IN crapdat.dtmvtolt%TYPE              --> Data de Movimentacao Atual
                                 ,pr_dtageini               IN crapdat.dtmvtolt%TYPE              --> Data de Agendamento Inicial
                                 ,pr_dtagefim               IN crapdat.dtmvtolt%TYPE              --> Data de Agendamento Final
                                 ,pr_insitlau               IN craplau.insitlau%TYPE              --> Situacao do Lancamento
                                 ,pr_iniconta               IN INTEGER                            --> Numero de Registros da Tela
                                 ,pr_nrregist               IN INTEGER                            --> Numero da Registros
                                 ,pr_cdtiptra               IN VARCHAR2 DEFAULT NULL              --> Tipo de transação                                 
                                 ,pr_dstransa              OUT VARCHAR2                           --> Descricao da Transacao
                                 ,pr_qttotage              OUT INTEGER                            --> Quantidade Total de Agendamentos
                                 ,pr_tab_dados_agendamento OUT PAGA0002.typ_tab_dados_agendamento --> Tabela com Informacoes de Agendamentos
                                 ,pr_cdcritic              OUT PLS_INTEGER                        --> Código da crítica
                                 ,pr_dscritic              OUT VARCHAR2) IS                       --> Descrição da crítica

    /* ..........................................................................
    --
    --  Programa : pc_obtem_agendamentos Antigo: b1wgen0016.p/obtem-agendamentos
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Julho/2016.                   Ultima atualizacao: 15/02/2018
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Procedure utilizada para consultar dados de agendamentos
    --
    --  Alteração : 06/12/2017 Adicionado filtro por tipo de transação
    --                         (p285 - Ricardo Linhares)
    --
    --              23/01/2018 - Incluido log no "WHEN OTHERS THEN" para tentar solucionar
    --                           um erro que não foi possível simular em desenvolvimento. 
    --                           (SD 830373 - Kelvin)
    --                           
    --              15/02/2018 - Ajuste realizado para corrigir o problema do chamado 
    --                           830373. (Kelvin)
    --  
    --              06/03/2018 - Ajuste de filtros para não buscar GPS se não for epecificado 
    --                           P285. (Ricardo Linhares)
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    --Selecionar os dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.dsestted
            ,crapcop.vlinited
            ,crapcop.vlmnlmtd
            ,crapcop.flmobted
            ,crapcop.flmstted
            ,crapcop.flnvfted
            ,crapcop.flmntage
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;

    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor para encontrar a conta/corrente
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrdconta
            ,ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;

    -- Consulta de Lancamentos Automaticos
    CURSOR cr_craplau(pr_cdcooper IN craplau.cdcooper%TYPE
                     ,pr_nrdconta IN craplau.nrdconta%TYPE
                     ,pr_dsorigem IN craplau.dsorigem%TYPE
                     ,pr_cdagenci IN craplau.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplau.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplau.nrdolote%TYPE
                     ,pr_dtageini IN craplau.dtmvtopg%TYPE
                     ,pr_dtagefim IN craplau.dtmvtopg%TYPE) IS
    SELECT /*+ INDEX (LAU CRAPLAU##CRAPLAU4) */
           lau.dtmvtolt
          ,lau.cdcooper
          ,lau.insitlau
          ,lau.dtmvtopg
          ,lau.idseqttl
          ,lau.cdtiptra
          ,lau.dscedent
          ,lau.cdageban
          ,lau.nrctadst
          ,lau.cddbanco
          ,lau.nrdconta
          ,lau.nrcpfope
          ,lau.vllanaut
          ,lau.dttransa
          ,lau.hrtransa
          ,lau.nrdocmto
          ,lau.dtvencto
          ,lau.nrcpfpre
          ,lau.idtitdda
          ,lau.nmprepos
          ,lau.dslindig
          ,lau.idlancto
          ,lau.nrseqagp
          ,lau.cdcritic
          ,lau.dscritic
          ,lau.progress_recid
      FROM craplau lau
    WHERE (pr_cdtiptra IS NULL OR lau.cdtiptra IN(SELECT regexp_substr(pr_cdtiptra, '[^;]+', 1, LEVEL)
                                                    FROM dual
                                        CONNECT BY LEVEL <= regexp_count(pr_cdtiptra, '[^;]+')))
      AND (lau.cdcooper = pr_cdcooper
      AND  lau.nrdconta = pr_nrdconta
      AND  lau.dsorigem = pr_dsorigem
      AND  lau.cdagenci = pr_cdagenci
      AND  lau.cdbccxlt = pr_cdbccxlt
      AND  lau.nrdolote = pr_nrdolote
      AND  (pr_dtageini IS NULL
       OR   (pr_dtageini IS NOT NULL
      AND    lau.dtmvtopg >= pr_dtageini))
      AND   (pr_dtagefim IS NULL
       OR    (pr_dtagefim IS NOT NULL
      AND   lau.dtmvtopg <= pr_dtagefim)))
       OR (lau.cdcooper  = pr_cdcooper -- Agendamentos GPS no CAIXA
      AND  lau.nrdconta  = pr_nrdconta
      AND  lau.nrseqagp <> 0
	  AND (pr_cdtiptra IS NULL OR 2 IN (SELECT regexp_substr(pr_cdtiptra, '[^;]+', 1, LEVEL) --Pagamento; DARF/DAS/GPS
                                              FROM dual
                                CONNECT BY LEVEL <= regexp_count(pr_cdtiptra, '[^;]+')))
      AND  (pr_dtageini IS NULL
       OR  (pr_dtageini IS NOT NULL
      AND  lau.dtmvtopg >= pr_dtageini))
      AND  (pr_dtagefim IS NULL
       OR  (pr_dtagefim IS NOT NULL
      AND lau.dtmvtopg <= pr_dtagefim)))
 ORDER BY lau.dtmvtopg
         ,lau.dttransa
         ,lau.hrtransa;

    rw_craplau cr_craplau%ROWTYPE;

    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE
                     ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
    SELECT ttl.cdcooper
          ,ttl.nmextttl
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl;

    rw_crapttl cr_crapttl%ROWTYPE;

    CURSOR cr_crabcop(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdagectl = pr_cdagectl;

    rw_crabcop cr_crabcop%ROWTYPE;

    CURSOR cr_crabass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT ass.cdcooper
            ,ass.nrdconta
			,ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

    rw_crabass cr_crabass%ROWTYPE;

    CURSOR cr_crapban(pr_cddbanco IN crapban.cdbccxlt%TYPE) IS

      SELECT ban.cdbccxlt
            ,ban.nmextbcc
      FROM crapban ban
     WHERE ban.cdbccxlt = pr_cddbanco;

    rw_crapban cr_crapban%ROWTYPE;

    CURSOR cr_crapagb(pr_cddbanco IN crapagb.cddbanco%TYPE
                     ,pr_cdageban IN crapagb.cdageban%TYPE) IS

      SELECT agb.cddbanco
            ,agb.cdageban
            ,agb.nmageban
        FROM crapagb agb
       WHERE agb.cddbanco = pr_cddbanco
         AND agb.cdageban = pr_cdageban;

    rw_crapagb cr_crapagb%ROWTYPE;

    CURSOR cr_crabagb(pr_cdbccxlt IN crapagb.cddbanco%TYPE
                     ,pr_cdageban IN crapagb.cdageban%TYPE) IS
    SELECT agb.*
      FROM crapagb agb
     WHERE agb.cddbanco = pr_cdbccxlt
       AND agb.cdageban = pr_cdageban;

    rw_crabagb cr_crabagb%ROWTYPE;

    CURSOR cr_crapcti(pr_cdcooper IN crapcti.cdcooper%TYPE
                     ,pr_nrdconta IN crapcti.nrdconta%TYPE
                     ,pr_cddbanco IN crapcti.cddbanco%TYPE
                     ,pr_cdageban IN crapcti.cdageban%TYPE
                     ,pr_nrctadst IN crapcti.nrctatrf%TYPE) IS

    SELECT cti.cdcooper
          ,cti.nrctatrf
          ,cti.nmtitula
    FROM crapcti cti
   WHERE cti.cdcooper = pr_cdcooper
     AND cti.nrdconta = pr_nrdconta
     AND cti.cddbanco = pr_cddbanco
     AND cti.cdageban = pr_cdageban
     AND cti.nrctatrf = pr_nrctadst;

    rw_crapcti cr_crapcti%ROWTYPE;

    CURSOR cr_crapopi(pr_cdcooper IN crapopi.cdcooper%TYPE
                     ,pr_nrdconta IN crapopi.nrdconta%TYPE
                     ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS

    SELECT opi.nmoperad
      FROM crapopi opi
     WHERE opi.cdcooper = pr_cdcooper
       AND opi.nrdconta = pr_nrdconta
       AND opi.nrcpfope = pr_nrcpfope;

    rw_crapopi cr_crapopi%ROWTYPE;

    CURSOR cr_darf_das(pr_idlancto IN craplau.idlancto%TYPE) IS
      SELECT darf.idlancto
            ,darf.cdcooper
            ,darf.nrdconta
            ,darf.tppagamento
            ,darf.tpcaptura
            ,darf.dsidentif_pagto
            ,darf.dsnome_fone
            ,darf.dscod_barras
            ,darf.dslinha_digitavel
            ,darf.dtapuracao
            ,darf.nrcpfcgc
            ,darf.cdtributo
            ,darf.nrrefere
            ,darf.vlprincipal
            ,darf.vlmulta
            ,darf.vljuros
            ,darf.vlreceita_bruta
            ,darf.vlpercentual
            ,darf.dtvencto
            ,darf.tpleitura_docto
        FROM tbpagto_agend_darf_das darf
       WHERE darf.idlancto = pr_idlancto;

    rw_darf_das cr_darf_das%ROWTYPE;
    
    VC_TIPO_PROTOCOLO_GPS CONSTANT number(5) := 13;
    
     CURSOR cr_gps(pr_cdcooper IN crappro.cdcooper%TYPE
                  ,pr_nrdconta IN crappro.nrdconta%TYPE
                  ,pr_nrseqaut IN crappro.nrseqaut%TYPE
                  ,pr_dtmvtolt IN crappro.dtmvtolt%TYPE) IS
         SELECT TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, pro.dsinform##3, '#')), ':')) cddpagto
              , TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, pro.dsinform##3, '#')), ':')) dscompet
              , TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, pro.dsinform##3, '#')), ':')) cdidenti              
              , TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, pro.dsinform##3, '#')), ':')) vlrdinss
              , TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, pro.dsinform##3, '#')), ':')) vlrouent
              , TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, pro.dsinform##3, '#')), ':')) vlrjuros              
           FROM crappro pro
          WHERE pro.cdcooper = pr_cdcooper
            AND pro.nrdconta = pr_nrdconta
            AND pro.nrseqaut = pr_nrseqaut
            AND pro.dtmvtolt = pr_dtmvtolt
            AND pro.cdtippro = VC_TIPO_PROTOCOLO_GPS;
                     
    rw_gps cr_gps%ROWTYPE;

    ---------------> VARIAVEIS DE ERROS <-----------------
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     crapcri.dscritic%TYPE;

    ---------------> VARIAVEIS LOCAIS <-----------------
    vr_nrdolote craplot.nrdolote%TYPE;
    vr_incancel INTEGER := 0;
    vr_hrfimcan INTEGER := 0;
    vr_cdindice INTEGER := 0;
    vr_tpcaptur INTEGER := 0;
  vr_nrcpfcgc VARCHAR2(200) := '';
    vr_dtvencto DATE;
    vr_datdodia DATE := SYSDATE;
    vr_dssgproc VARCHAR2(500) := '';
    vr_dssitlau VARCHAR2(500) := '';
    vr_dstiptra VARCHAR2(500) := '';
    vr_nrctadst VARCHAR2(500) := '';
    vr_nmoperad VARCHAR2(500) := '';
    vr_dsageban VARCHAR2(500) := '';
    vr_cdageban VARCHAR2(500) := '';
    vr_dtagenda tbpagto_agend_darf_das.dtapuracao%TYPE := '';
    vr_dstipcat VARCHAR2(100) := '';
    vr_dsidpgto VARCHAR2(100) := '';
    vr_dsnomfon VARCHAR2(100) := '';
    vr_dtperiod tbpagto_agend_darf_das.dtapuracao%TYPE := '';
    vr_cdreceit tbpagto_agend_darf_das.cdtributo%TYPE := 0;
    vr_nrrefere tbpagto_agend_darf_das.nrrefere%TYPE := 0;
    vr_vlprinci tbpagto_agend_darf_das.vlprincipal%TYPE := 0;
    vr_vlrmulta tbpagto_agend_darf_das.vlmulta%TYPE := 0;
    vr_vlrjuros tbpagto_agend_darf_das.vljuros%TYPE := 0;
    vr_vlrtotal tbpagto_agend_darf_das.vlprincipal%TYPE := 0;
    vr_vlrrecbr tbpagto_agend_darf_das.vlreceita_bruta%TYPE := 0;
    vr_vlrperce tbpagto_agend_darf_das.vlpercentual%TYPE := 0;
    vr_idlstdom NUMBER := 0;
    vr_prorowid craplau.progress_recid%TYPE := NULL;
    vr_dscrilau craplau.dscritic%TYPE;

    -- GPS
    vr_gps_cddpagto craplgp.cddpagto%TYPE; -- 03 - Código de pagamento
    vr_gps_dscompet VARCHAR2(10);            -- 04 - Competência
    vr_gps_cdidenti craplgp.cdidenti%TYPE; -- 05 - Identificador
    vr_gps_vlrdinss craplgp.vlrdinss%TYPE; -- 06 - Valor INSS (R$)
    vr_gps_vlrouent craplgp.vlrouent%TYPE; -- 09 - Valor Outras Entidades (R$)
    vr_gps_vlrjuros craplgp.vlrjuros%TYPE; -- 10 - ATM / Multa e Juros (R$)

    vr_nmprimtl crapass.nmprimtl%TYPE := '';
    vr_tab_dados_agendamento PAGA0002.typ_tab_dados_agendamento;
  BEGIN

    pr_dstransa := 'Consulta agendamentos de pagamentos e transferencias';
    vr_nrdolote := 11000 + pr_nrdcaixa;
    pr_qttotage := 0;

    pr_tab_dados_agendamento.DELETE;

    -- Buscar limite de credito
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Se nao encontrar
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;

      -- Monta critica
      vr_cdcritic := 9;
      -- Gera excecao
      RAISE vr_exc_erro;

    ELSE
      -- Fecha o cursor
      CLOSE cr_crapass;
    END IF;

    -- Obtem parametros para condicoes de cancelamento **/
    PAGA0002.pc_param_cancelamento(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                                  ,pr_cdagenci => pr_cdagenci   --> Codigo do PA
                                  ,pr_dtmvtolt => vr_datdodia   --> Data Atual de Movimentacao
                                  ,pr_hrfimcan => vr_hrfimcan   --> Hora de Fim do Cancelamento
                                  ,pr_dssgproc => vr_dssgproc
                                  ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                  ,pr_dscritic => vr_dscritic); --> Descricao da Critica

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF rw_crapass.inpessoa > 1 THEN
      vr_nmprimtl := rw_crapass.nmprimtl;
    END IF;

    FOR rw_craplau IN cr_craplau(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdbccxlt => 100
                                ,pr_nrdolote => vr_nrdolote
                                ,pr_dtageini => pr_dtageini
                                ,pr_dtagefim => pr_dtagefim) LOOP

      
      vr_prorowid := rw_craplau.progress_recid;
      
      vr_tpcaptur := 0;

      IF rw_craplau.insitlau = 2 AND -- EFETIVADO
         pr_insitlau IN (0,1) THEN

          -- Se for um agendamento efetivado no processo de sabado
          -- deve permitir o cancelamento e deve ser mostrado como
          -- pendente na tela, pois a data de debito eh referente
          -- a segunda-feira. Condicao vale para feriados tambem.
        IF rw_craplau.dtmvtopg <= vr_datdodia THEN
          CONTINUE;
        END IF;

      ELSIF rw_craplau.insitlau <> pr_insitlau
        AND pr_insitlau <> 0 THEN
        CONTINUE;
      END IF;

      -- Quantidade total de agendamentos encontrados no FOR EACH
      pr_qttotage := pr_qttotage + 1;

      -- Retornar somente limite de registros selecionados na tela
      IF pr_qttotage > pr_iniconta AND
         pr_nrregist >= (pr_qttotage - pr_iniconta) THEN

        IF rw_crapass.inpessoa = 1 THEN

          OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_idseqttl => rw_craplau.idseqttl);

          FETCH cr_crapttl INTO rw_crapttl;

          IF cr_crapttl%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapttl;
            vr_nmprimtl := rw_crapttl.nmextttl;
          ELSE
            -- Fecha cursor
            CLOSE cr_crapttl;
            vr_nmprimtl := rw_crapass.nmprimtl;
          END IF;

        END IF;

        -- Verifica se eh permitido cancelar o agendamento
        -- vr_incancel = 1 - Permitir o cancelamento
        -- vr_incancel = 2 - Nao permitir o cancelamento

        IF rw_craplau.insitlau = 1 OR -- PENDENTE
           rw_craplau.insitlau = 2 THEN -- EFETIVADO

          IF rw_craplau.cdtiptra = 4 THEN -- TED
            -- Se jah foi efetivado nao pode ser permitido o cancelamento.
            IF rw_craplau.insitlau = 2 THEN
              vr_incancel := 2;
            ELSE
              IF TRUNC(rw_craplau.dtmvtopg) > TRUNC(vr_datdodia)  THEN
                vr_incancel := 1;
              ELSE

                -- O cancelamento de TED dever ser permitido somente ate as 8:30 (Horario
                -- parametrizado atraves da tabela crapprm) pois o programa pr_crps705
                -- (Responsavel pelo debito de agendamentos de TED) sera iniciado as 8:40.
                -- Qualquer mudanca na condicao abaixo devera ser previamente discutida com
                -- a equipe do financeiro (Juliana), do canais de atendimento (Jefferson),
                -- Seguranca Corporativa (Maicon) e de sistemas (Adriano, Rosangela).

                IF TRUNC(rw_craplau.dtmvtopg) = TRUNC(vr_datdodia) AND
                   gene0002.fn_busca_time < TO_NUMBER(GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'HORARIO_CANCELAMENTO_TED'))  THEN
                  vr_incancel := 1;
                ELSE
                  vr_incancel := 2;
                END IF; -- FIM rw_craplau.dtmvtopg = aux_datdodia
              END IF;
            END IF;
          ELSE
            -- Se agendamento for data futura ou a cooperativa
            -- possui segundo processo para debito e estiver
            -- dentro do horario limite permite o cancelamento
            -- Se for data menor que hoje nao permitir

            IF TRUNC(rw_craplau.dtmvtopg) > TRUNC(vr_datdodia)  THEN
              vr_incancel := 1;
            ELSIF TRUNC(rw_craplau.dtmvtopg) = TRUNC(vr_datdodia)
              AND gene0002.fn_busca_time <= vr_hrfimcan
              AND vr_dssgproc = 'SIM' THEN
              vr_incancel := 1;
            ELSE
              vr_incancel := 2;
            END IF;

            -- Se for GPS, nao permite cancelar na tela de Agendamentos            
            /*
            IF rw_craplau.nrseqagp > 0 THEN
              vr_incancel := 3;
            END IF;   */         

            -- Se for DARF/DAS e jah foi efetivado nao pode ser permitido o cancelamento.
            IF (rw_craplau.cdtiptra = 10 OR (rw_craplau.cdtiptra = 2 AND rw_craplau.nrseqagp > 0)) AND rw_craplau.insitlau = 2 THEN
              vr_incancel := 2;
            END IF;

          END IF; -- ELSE cdtiptra
        ELSE
          vr_incancel := 2;
        END IF;

        IF rw_craplau.insitlau = 1 OR
           rw_craplau.insitlau = 2 THEN
          vr_dssitlau := 'Pendente';
        ELSIF rw_craplau.insitlau = 3 THEN
          vr_dssitlau := 'Cancelado';
        ELSIF rw_craplau.insitlau = 4 THEN
          vr_dssitlau := 'Nao Efetivado';
        ELSE
          vr_dssitlau := '';
        END IF;

        IF rw_craplau.cdtiptra = 1 OR
           rw_craplau.cdtiptra = 5 THEN
          vr_dstiptra := 'Transferencia';
          
          IF rw_craplau.cdtiptra = 1 THEN 
            vr_idlstdom := 5; -- Transf. Intracooperativa
          ELSE
            vr_idlstdom := 6; -- Transf. Intercooperativa
          END IF;
        ELSIF rw_craplau.cdtiptra = 2 THEN
          vr_dstiptra := 'Pagamento';
          
          IF NVL(rw_craplau.nrseqagp,0) <> 0 THEN 
            vr_idlstdom := 9; -- GPS
          ELSIF LENGTH(NVL(rw_craplau.dslindig,'')) = 55 THEN
            vr_idlstdom := 2; -- Convênio
          ELSE
            vr_idlstdom := 1; -- Título
          END IF;
        ELSIF rw_craplau.cdtiptra = 3 THEN
          vr_dstiptra := 'Credito de Salario';
          vr_idlstdom := 3; -- Crédito Salário
        ELSIF rw_craplau.cdtiptra = 4 THEN
          vr_dstiptra := 'TED';
          vr_idlstdom := 4; -- TED         
        ELSE
          vr_dstiptra := '';
        END IF;

        vr_nrctadst := '';

        IF rw_craplau.cdtiptra = 1  OR -- AGENDAMENTO
           rw_craplau.cdtiptra = 3  OR -- CREDITO SALARIO
           rw_craplau.cdtiptra = 5  THEN -- AGENDAMENTO

          OPEN cr_crabcop(pr_cdagectl => rw_craplau.cdageban);
          FETCH cr_crabcop INTO rw_crabcop;

          IF cr_crabcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crabcop;
            CONTINUE;
          ELSE
            -- Fecha cursor
            CLOSE cr_crabcop;
          END IF;

          OPEN cr_crabass(pr_cdcooper => rw_crabcop.cdcooper
                         ,pr_nrdconta => rw_craplau.nrctadst);

          IF cr_crabass%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crabass;
            CONTINUE;
          ELSE
		    FETCH cr_crabass INTO rw_crabass;
            -- Fecha cursor
            CLOSE cr_crabass;
          END IF;

          vr_dsageban := LPAD(rw_crabcop.cdagectl,4,'0') || ' - ' || rw_crabcop.nmrescop;
          vr_nrctadst := TRIM(GENE0002.fn_mask_conta(rw_craplau.nrctadst));
          vr_nrctadst := vr_nrctadst ||  ' - ' || rw_crabass.nmprimtl;

        ELSIF rw_craplau.cdtiptra = 4 THEN -- TED

          OPEN cr_crapban(pr_cddbanco => rw_craplau.cddbanco);

          FETCH cr_crapban INTO rw_crapban;

          IF cr_crapban%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapban;
            vr_dsageban :=  LPAD(rw_crapban.cdbccxlt,4,'0') || ' - ' || REPLACE(UPPER(TRIM(rw_crapban.nmextbcc)),'&','e');

            OPEN cr_crapagb(pr_cddbanco => rw_crapban.cdbccxlt
                           ,pr_cdageban => rw_craplau.cdageban);

            FETCH cr_crapagb INTO rw_crapagb;

            IF cr_crapagb%FOUND THEN
              -- Fecha cursor
              CLOSE cr_crapagb;
              vr_cdageban := LPAD(rw_crapagb.cdageban,4,'0') || ' - ' || REPLACE(UPPER(TRIM(rw_crapagb.nmageban)),'&','e');
            ELSE
              -- Fecha cursor
              CLOSE cr_crapagb;
              vr_cdageban := 'NAO CADASTRADO';
            END IF;
          ELSE
            -- Fecha cursor
            CLOSE cr_crapban;
            vr_dsageban := 'NAO CADASTRADO';
          END IF; -- AVAILABLE crapban

          -- Consultar crapcti para pegar conta e nome dst
          OPEN cr_crapcti(pr_cdcooper => rw_craplau.cdcooper
                         ,pr_nrdconta => rw_craplau.nrdconta
                         ,pr_cddbanco => rw_craplau.cddbanco
                         ,pr_cdageban => rw_craplau.cdageban
                         ,pr_nrctadst => rw_craplau.nrctadst);

          FETCH cr_crapcti INTO rw_crapcti;

          IF cr_crapcti%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcti;
            vr_nrctadst := TRIM(GENE0002.fn_mask_conta(rw_crapcti.nrctatrf));
            vr_nrctadst := vr_nrctadst || ' - ' || rw_crapcti.nmtitula;
          ELSE
            -- Fecha cursor
            CLOSE cr_crapcti;
            vr_nrctadst := TRIM(GENE0002.fn_mask_conta(rw_craplau.nrctadst)) || ' - FAVORECIDO NAO CADASTRADO';
          END IF;
        ELSIF rw_craplau.cdtiptra = 10 THEN

          OPEN cr_darf_das(pr_idlancto => rw_craplau.idlancto);

          FETCH cr_darf_das INTO rw_darf_das;

          IF cr_darf_das%NOTFOUND THEN
            CLOSE cr_darf_das;
            vr_dscritic := 'Registro de pagamento de DARF/DAS inexistente.';
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_darf_das;
          END IF;

          vr_dtagenda := rw_craplau.dtmvtopg;
          vr_tpcaptur := rw_darf_das.tpcaptura;
          vr_dtvencto := rw_darf_das.dtvencto;
          vr_nrcpfcgc := rw_darf_das.nrcpfcgc;
          vr_dstipcat := (CASE WHEN rw_darf_das.tpcaptura = 1 THEN 'Com Código de Barras' ELSE 'Sem Código de Barras' END);
          vr_dsidpgto := rw_darf_das.dsidentif_pagto;
          vr_dsnomfon := rw_darf_das.dsnome_fone;
          vr_dtperiod := rw_darf_das.dtapuracao;
          vr_cdreceit := rw_darf_das.cdtributo;
          vr_nrrefere := rw_darf_das.nrrefere;
          vr_vlprinci := rw_darf_das.vlprincipal;
          vr_vlrmulta := rw_darf_das.vlmulta;
          vr_vlrjuros := rw_darf_das.vljuros;
          vr_vlrtotal := NVL(vr_vlprinci,0) + NVL(vr_vlrmulta,0) + NVL(vr_vlrjuros,0);
          vr_vlrrecbr := rw_darf_das.vlreceita_bruta;
          vr_vlrperce := rw_darf_das.vlpercentual;
          vr_dstiptra := (CASE WHEN rw_darf_das.tppagamento = 1 THEN 'DARF' ELSE 'DAS' END);
          vr_idlstdom := (CASE WHEN rw_darf_das.tppagamento = 1 THEN 7 ELSE '8' END);

        END IF;

        vr_nmoperad := '';

        OPEN cr_crapopi(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrcpfope => rw_craplau.nrcpfope);

        FETCH cr_crapopi INTO rw_crapopi;

        IF cr_crapopi%FOUND THEN
          -- Fecha cursor
            CLOSE cr_crapopi;
          vr_nmoperad := rw_crapopi.nmoperad;
        ELSE
          -- Fecha cursor
          CLOSE cr_crapopi;
        END IF;
        
        -- Se for GPS
        IF rw_craplau.nrseqagp > 0 THEN

		  vr_dstiptra := 'GPS';
                  
          OPEN cr_gps(pr_cdcooper => rw_craplau.cdcooper
                     ,pr_nrdconta => rw_craplau.nrdconta
                     ,pr_nrseqaut => rw_craplau.nrseqagp
                     ,pr_dtmvtolt => rw_craplau.dtmvtolt);

          FETCH cr_gps INTO rw_gps;

          IF cr_gps%NOTFOUND THEN
            CLOSE cr_gps;
--            vr_dscritic := 'Lançamento não encontrado';
--            RAISE vr_exc_erro;
          ELSE

            CLOSE cr_gps;
            vr_gps_cddpagto := rw_gps.cddpagto;
            vr_gps_dscompet := rw_gps.dscompet;
            vr_gps_cdidenti := rw_gps.cdidenti;
            vr_gps_vlrdinss := to_number(rw_gps.vlrdinss,'999G999D99');
            vr_gps_vlrouent := to_number(rw_gps.vlrouent,'999G999D99');
            vr_gps_vlrjuros := to_number(rw_gps.vlrjuros,'999G999D99');
          END IF;

        ELSE
          vr_gps_cddpagto := 0;
          vr_gps_dscompet := '';
          vr_gps_cdidenti := 0;
          vr_gps_vlrdinss := 0;
          vr_gps_vlrouent := 0;
          vr_gps_vlrjuros := 0;
          
        END IF;
        
        vr_dscrilau := '';
        IF rw_craplau.insitlau = 4 THEN 
           IF NVL(rw_craplau.cdcritic,0) <> 0 THEN
             vr_dscrilau := GENE0001.fn_busca_critica(pr_cdcritic => rw_craplau.cdcritic);
           ELSE
             vr_dscrilau := NVL(rw_craplau.dscritic,'');
           END IF;
        END IF;

        vr_cdindice := vr_tab_dados_agendamento.COUNT() + 1;

        vr_tab_dados_agendamento(vr_cdindice).dtmvtopg := rw_craplau.dtmvtopg;
        vr_tab_dados_agendamento(vr_cdindice).vllanaut := rw_craplau.vllanaut;
        vr_tab_dados_agendamento(vr_cdindice).dttransa := rw_craplau.dttransa;
        vr_tab_dados_agendamento(vr_cdindice).hrtransa := rw_craplau.hrtransa;
        vr_tab_dados_agendamento(vr_cdindice).nrdocmto := rw_craplau.nrdocmto;
				vr_tab_dados_agendamento(vr_cdindice).insitlau := rw_craplau.insitlau;
        vr_tab_dados_agendamento(vr_cdindice).dssitlau := vr_dssitlau;
        vr_tab_dados_agendamento(vr_cdindice).dscedent := rw_craplau.dscedent;
        vr_tab_dados_agendamento(vr_cdindice).dtvencto := rw_craplau.dtvencto;
        vr_tab_dados_agendamento(vr_cdindice).dslindig := (CASE WHEN rw_craplau.dslindig IS NOT NULL THEN rw_craplau.dslindig ELSE '' END);
        vr_tab_dados_agendamento(vr_cdindice).dsageban := vr_dsageban;
        vr_tab_dados_agendamento(vr_cdindice).nrctadst := vr_nrctadst;
        vr_tab_dados_agendamento(vr_cdindice).cdtiptra := rw_craplau.cdtiptra;
        vr_tab_dados_agendamento(vr_cdindice).dstiptra := vr_dstiptra;
        vr_tab_dados_agendamento(vr_cdindice).idlstdom := vr_idlstdom;
        vr_tab_dados_agendamento(vr_cdindice).dtmvtage := rw_craplau.dtmvtolt;
        vr_tab_dados_agendamento(vr_cdindice).incancel := NVL(vr_incancel,0);
        vr_tab_dados_agendamento(vr_cdindice).nmprimtl := vr_nmprimtl;
        vr_tab_dados_agendamento(vr_cdindice).nmprepos := (CASE WHEN rw_craplau.nmprepos IS NOT NULL THEN rw_craplau.nmprepos ELSE '' END);
        vr_tab_dados_agendamento(vr_cdindice).nrcpfpre := rw_craplau.nrcpfpre;
        vr_tab_dados_agendamento(vr_cdindice).nmoperad := vr_nmoperad;
        vr_tab_dados_agendamento(vr_cdindice).nrcpfope := rw_craplau.nrcpfope;
        vr_tab_dados_agendamento(vr_cdindice).idtitdda := rw_craplau.idtitdda;
        vr_tab_dados_agendamento(vr_cdindice).nrcpfcgc := vr_nrcpfcgc;
        vr_tab_dados_agendamento(vr_cdindice).dtvendrf := vr_dtvencto;
        vr_tab_dados_agendamento(vr_cdindice).cdageban := vr_cdageban;
        vr_tab_dados_agendamento(vr_cdindice).dtagenda := vr_dtagenda;
        vr_tab_dados_agendamento(vr_cdindice).tpcaptur := vr_tpcaptur;
        vr_tab_dados_agendamento(vr_cdindice).dstipcat := vr_dstipcat;
        vr_tab_dados_agendamento(vr_cdindice).dsidpgto := vr_dsidpgto;
        vr_tab_dados_agendamento(vr_cdindice).dsnomfon := vr_dsnomfon;
        vr_tab_dados_agendamento(vr_cdindice).dtperiod := vr_dtperiod;
        vr_tab_dados_agendamento(vr_cdindice).cdreceit := vr_cdreceit;
        vr_tab_dados_agendamento(vr_cdindice).nrrefere := vr_nrrefere;
        vr_tab_dados_agendamento(vr_cdindice).vlprinci := vr_vlprinci;
        vr_tab_dados_agendamento(vr_cdindice).vlrmulta := vr_vlrmulta;
        vr_tab_dados_agendamento(vr_cdindice).vlrjuros := vr_vlrjuros;
        vr_tab_dados_agendamento(vr_cdindice).vlrtotal := vr_vlrtotal;
        vr_tab_dados_agendamento(vr_cdindice).vlrrecbr := vr_vlrrecbr;
        vr_tab_dados_agendamento(vr_cdindice).vlrperce := vr_vlrperce;
        vr_tab_dados_agendamento(vr_cdindice).idlancto := rw_craplau.idlancto;
		    vr_tab_dados_agendamento(vr_cdindice).dscritic := vr_dscrilau;
        -- GPS
        vr_tab_dados_agendamento(vr_cdindice).gps_cddpagto := vr_gps_cddpagto;
        vr_tab_dados_agendamento(vr_cdindice).gps_dscompet := vr_gps_dscompet;
        vr_tab_dados_agendamento(vr_cdindice).gps_cdidenti := vr_gps_cdidenti;
        vr_tab_dados_agendamento(vr_cdindice).gps_vlrdinss := vr_gps_vlrdinss;
        vr_tab_dados_agendamento(vr_cdindice).gps_vlrouent := vr_gps_vlrouent;
        vr_tab_dados_agendamento(vr_cdindice).gps_vlrjuros := vr_gps_vlrjuros;

      END IF;

    END LOOP;

    pr_tab_dados_agendamento := vr_tab_dados_agendamento;

  EXCEPTION
      WHEN vr_exc_erro THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PAGA0002.pc_obtem_agendamentos: ' || SQLERRM;
        cecred.pc_internal_exception(pr_compleme => 'PAGA0002.PC_OBTEM_AGENDAMENTOS progress_recid: '|| vr_prorowid);
        ROLLBACK;

  END pc_obtem_agendamentos;

  /* Procedimento para obter dados de agendamentos via PROGRESS */
  PROCEDURE pc_obtem_agendamentos_car(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Código do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Numero do Caixa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                     ,pr_dsorigem  IN VARCHAR2              --> Descricao da Origem
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao Atual
                                     ,pr_dtageini  IN crapdat.dtmvtolt%TYPE --> Data de Agendamento Inicial
                                     ,pr_dtagefim  IN crapdat.dtmvtolt%TYPE --> Data de Agendamento Final
                                     ,pr_insitlau  IN craplau.insitlau%TYPE --> Situacao do Lancamento
                                     ,pr_iniconta  IN INTEGER               --> Numero de Registros da Tela
                                     ,pr_nrregist  IN INTEGER               --> Numero da Registros
                                     ,pr_dstransa OUT VARCHAR2              --> Descricao da Transacao
                                     ,pr_qttotage OUT INTEGER               --> Quantidade Total de Agendamentos
                                     ,pr_clobxmlc OUT CLOB                  --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* ..........................................................................
    --
    --  Programa : pc_obtem_agendamentos_car
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Julho/2016.                   Ultima atualizacao: 28/07/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada para consultar dados de agendamentos via PROGRESS
    --
    --  Alteração  :
    --
    -- ..........................................................................*/

    ---------------> VARIAVEIS DE ERROS <-----------------
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     crapcri.dscritic%TYPE;

    vr_tab_dados_agendamento PAGA0002.typ_tab_dados_agendamento;
    vr_dstransa VARCHAR2(100) := ''; -- Descricao de Transacoes
    vr_qttotage INTEGER       := 0;  -- Quantidade de registros de agendamentos
    vr_contador INTEGER       := 0;
  vr_stsnrcal BOOLEAN;
  vr_inpessoa INTEGER;
  vr_dscpfcgc VARCHAR(20);

    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

  BEGIN

   PAGA0002.pc_obtem_agendamentos(pr_cdcooper               => pr_cdcooper              --> Código da Cooperativa
                                  ,pr_cdagenci              => pr_cdagenci              --> Código do PA
                                  ,pr_nrdcaixa              => pr_nrdcaixa              --> Numero do Caixa
                                  ,pr_nrdconta              => pr_nrdconta              --> Numero da Conta
                                  ,pr_dsorigem              => pr_dsorigem              --> Descricao da Origem
                                  ,pr_dtmvtolt              => pr_dtmvtolt              --> Data de Movimentacao Atual
                                  ,pr_dtageini              => pr_dtageini              --> Data de Agendamento Inicial
                                  ,pr_dtagefim              => pr_dtagefim              --> Data de Agendamento Final
                                  ,pr_insitlau              => pr_insitlau              --> Situacao do Lancamento
                                  ,pr_iniconta              => pr_iniconta              --> Numero de Registros da Tela
                                  ,pr_nrregist              => pr_nrregist              --> Numero da Registros
                                  ,pr_dstransa              => vr_dstransa              --> Descricao da Transacao
                                  ,pr_qttotage              => vr_qttotage              --> Quantidade Total de Agendamentos
                                  ,pr_tab_dados_agendamento => vr_tab_dados_agendamento --> Tabela com Informacoes de Agendamentos
                                  ,pr_cdcritic              => vr_cdcritic              --> Código da crítica
                                  ,pr_dscritic              => vr_dscritic);            --> Descrição da crítica

    -- Verifica se houver erro na consulta de dados de agendamento
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_tab_dados_agendamento.count() > 0 THEN

      pr_qttotage := vr_qttotage;

      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);

      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');


      -- Percorre todas as aplicações de captação da conta
      FOR vr_contador IN vr_tab_dados_agendamento.FIRST..vr_tab_dados_agendamento.LAST LOOP

        IF NOT vr_tab_dados_agendamento.exists(vr_contador) THEN
          CONTINUE;
        END IF;

        vr_inpessoa := 0;
        vr_dscpfcgc := '';
        IF LENGTH(vr_tab_dados_agendamento(vr_contador).nrcpfcgc) = 11 THEN -- CPF
           vr_inpessoa := 1;
        ELSIF LENGTH(vr_tab_dados_agendamento(vr_contador).nrcpfcgc) = 14 THEN -- CNPJ
           vr_inpessoa := 2;
        END IF;
        IF vr_inpessoa > 0 THEN
          vr_dscpfcgc := TO_CHAR(gene0002.fn_mask_cpf_cnpj(vr_tab_dados_agendamento(vr_contador).nrcpfcgc,vr_inpessoa));
        END IF;

        -- Montar XML com registros de aplicação
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<dados>'
                                                  ||  '<dtmvtage>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dtmvtage,'DD/MM/RRRR') || '</dtmvtage>'
                                                  ||  '<dtmvtopg>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dtmvtopg,'DD/MM/RRRR') || '</dtmvtopg>'
                                                  ||  '<vllanaut>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vllanaut) || '</vllanaut>'
                                                  ||  '<dttransa>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dttransa,'DD/MM/RRRR') || '</dttransa>'
                                                  ||  '<hrtransa>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).hrtransa) || '</hrtransa>'
                                                  ||  '<nrdocmto>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nrdocmto) || '</nrdocmto>'
                                                  ||  '<dssitlau>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dssitlau) || '</dssitlau>'
                                                  ||  '<dslindig>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dslindig) || '</dslindig>'
                                                  ||  '<dscedent>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dscedent) || '</dscedent>'
                                                  ||  '<dtvencto>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dtvencto,'DD/MM/RRRR') || '</dtvencto>'
                                                  ||  '<dsageban>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dsageban) || '</dsageban>'
                                                  ||  '<nrctadst>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nrctadst) || '</nrctadst>'
                                                  ||  '<incancel>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).incancel) || '</incancel>'
                                                  ||  '<nmprimtl>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nmprimtl) || '</nmprimtl>'
                                                  ||  '<nmprepos>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nmprepos) || '</nmprepos>'
                                                  ||  '<nrcpfpre>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nrcpfpre)              || '</nrcpfpre>'
                                                  ||  '<nmoperad>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nmoperad)              || '</nmoperad>'
                                                  ||  '<nrcpfope>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nrcpfope)              || '</nrcpfope>'
                                                  ||  '<idtitdda>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).idtitdda)              || '</idtitdda>'
                                                  ||  '<cdageban>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).cdageban)              || '</cdageban>'
                                                  ||  '<cdtiptra>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).cdtiptra)              || '</cdtiptra>'
                                                  ||  '<dstiptra>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dstiptra) || '</dstiptra>'
                                                  ||  '<dtagenda>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dtagenda,'DD/MM/RRRR') || '</dtagenda>'
                          ||  '<tpcaptur>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).tpcaptur)              || '</tpcaptur>'
                                                  ||  '<dtvendrf>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dtvendrf,'DD/MM/RRRR') || '</dtvendrf>'
                          ||  '<nrcpfcgc>' || vr_dscpfcgc || '</nrcpfcgc>'
                                                  ||  '<dstipcat>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dstipcat) || '</dstipcat>'
                                                  ||  '<dsidpgto>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dsidpgto) || '</dsidpgto>'
                                                  ||  '<dsnomfon>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dsnomfon) || '</dsnomfon>'
                                                  ||  '<dtperiod>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).dtperiod,'DD/MM/RRRR') || '</dtperiod>'
                                                  ||  '<cdreceit>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).cdreceit) || '</cdreceit>'
                                                  ||  '<nrrefere>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).nrrefere) || '</nrrefere>'
                                                  ||  '<vlprinci>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vlprinci) || '</vlprinci>'
                                                  ||  '<vlrmulta>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vlrmulta) || '</vlrmulta>'
                                                  ||  '<vlrjuros>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vlrjuros) || '</vlrjuros>'
                                                  ||  '<vlrtotal>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vlrtotal) || '</vlrtotal>'
                                                  ||  '<vlrrecbr>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vlrrecbr) || '</vlrrecbr>'
                                                  ||  '<vlrperce>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).vlrperce) || '</vlrperce>'
                                                  ||  '<incancel>' || NVL(TO_CHAR(vr_tab_dados_agendamento(vr_contador).incancel),0) || '</incancel>'
                                                  ||  '<gps_cddpagto>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).gps_cddpagto) || '</gps_cddpagto>'
                                                  ||  '<gps_dscompet>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).gps_dscompet) || '</gps_dscompet>'
                                                  ||  '<gps_cdidenti>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).gps_cdidenti) || '</gps_cdidenti>'
                                                  ||  '<gps_vlrdinss>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).gps_vlrdinss) || '</gps_vlrdinss>'
                                                  ||  '<gps_vlrouent>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).gps_vlrouent) || '</gps_vlrouent>'
                                                  ||  '<gps_vlrjuros>' || TO_CHAR(vr_tab_dados_agendamento(vr_contador).gps_vlrjuros) || '</gps_vlrjuros>'                                                                                                                                                                                                                                                          
                                                || '</dados>');
      END LOOP;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</root>'
                             ,pr_fecha_xml      => TRUE);
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em PAGA0002.pc_obtem_agendamentos_car: ' || SQLERRM;
      ROLLBACK;

  END pc_obtem_agendamentos_car;

  /* Procedimento para cancelar agendamento */
  PROCEDURE pc_cancelar_agendamento (  pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da conta do cooperado
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_dsorigem IN craplau.dsorigem%TYPE  --> Descrição de origem do registro
                                      ,pr_dtmvtage IN crapdat.dtmvtolt%TYPE  --> Data do agendamento
                                      ,pr_nrdocmto IN craplau.nrdocmto%TYPE  --> Numero do documento
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela

                                      /* parametros de saida */
                                      ,pr_dstransa OUT VARCHAR2              --> descrição de transação
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descricao critica
  /* ..........................................................................
    --
    --  Programa : pc_cancelar_agendamento       Antiga: b1wgen0016.p/cancelar-agendamento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2016.                   Ultima atualizacao: 11/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedimento para cancelar agendamento
    --
    --  Alteração : 11/01/2016 - Conversão Progress -> Oracle (Odirlei-Amcom)
    --
    --
    --
    ...........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.idastcjt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;

		--> Buscar dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper  crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper,
             crapcop.nmrescop
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --> Buscar dados do operado
    CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                      pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad,
             ope.nvoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;

    --> Verificar se eh convenio SICREDI
    CURSOR cr_crapcon (pr_cdcooper  crapcon.cdcooper%TYPE,
                       pr_cdempcon  crapcon.cdempcon%TYPE,
                       pr_cdsegmto  crapcon.cdsegmto%TYPE ) IS
      SELECT crapcon.cdcooper
			      ,crapcon.flginter
						,crapcon.nmextcon
						,crapcon.flgcnvsi
						,crapcon.cdhistor
						,crapcon.nmrescon
						,crapcon.cdsegmto
						,crapcon.cdempcon
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;

    -- Buscar dados agendamento
    CURSOR cr_craplau ( pr_cdcooper craplau.cdcooper%TYPE,
                        pr_nrdconta craplau.nrdconta%TYPE,
                        pr_dtmvtage craplau.dtmvtolt%TYPE,
                        pr_cdagenci craplau.cdagenci%TYPE,
                        pr_nrdolote craplau.nrdolote%TYPE,
                        pr_nrdocmto craplau.nrdocmto%TYPE,
                        pr_dsorigem craplau.dsorigem%TYPE)IS
      SELECT lau.rowid,
             lau.nrdconta,
             lau.insitlau,
             lau.cdtiptra,
             lau.dtmvtopg,
             lau.cdtrapen,
             lau.dscedent,
             lau.nrctadst,
             lau.dslindig,
             lau.idtitdda,
             lau.dscodbar,
             lau.cdctrlcs

        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta
         AND lau.dtmvtolt = pr_dtmvtage
         AND lau.cdagenci = pr_cdagenci
         AND lau.cdbccxlt = 100
         AND lau.nrdolote = pr_nrdolote
         AND lau.nrdocmto = pr_nrdocmto
         AND lau.dsorigem = pr_dsorigem
         FOR UPDATE;
    rw_craplau cr_craplau%ROWTYPE;

    vr_hrtransa_ted craplau.hrtransa%TYPE;
    vr_hrtransa_inter craplcm.hrtransa%TYPE;
    vr_hrtransa_intra craplau.hrtransa%TYPE;

    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic INTEGER;
    --Tabela de memoria de erros
    vr_tab_erro GENE0001.typ_tab_erro;

		vr_idlancto craplau.idlancto%type;

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    vr_dtmvtopg DATE;
    vr_nrdolote NUMBER;
    vr_dslindig VARCHAR2(200);
    vr_tpdvalor INTEGER;
    vr_nmprepos VARCHAR2(200);
    vr_nrcpfpre NUMBER;
    vr_flgachou BOOLEAN;
    vr_datdodia DATE := SYSDATE;
    vr_hrfimcan INTEGER := 0;
    vr_dssgproc VARCHAR2(500) := '';
    vr_flgtrans BOOLEAN;
    vr_idorigem INTEGER;

    vr_dsvlrprm crapprm.dsvlrprm%TYPE;
    vr_nrdocdeb NUMBER;
    vr_nrdoccre NUMBER;
    vr_cdhiscre craphis.cdhistor%TYPE;
    vr_cdhisdeb craphis.cdhistor%TYPE;
    vr_dscodbar craplau.dscodbar%TYPE;
    vr_cdlantar craplat.cdlantar%TYPE;
    vr_insitlau craplau.insitlau%TYPE;
    vr_cdseqfat craplft.cdseqfat%TYPE;
    vr_vlfatura craplft.vllanmto%TYPE;
    vr_nrdigfat craplft.nrdigfat%TYPE;
    vr_flagiptu BOOLEAN;
    vr_nrdrowid ROWID;



  BEGIN

    pr_dstransa := 'Cancelar agendamento de pagamentos, transferencias e TED';
    vr_flgtrans := FALSE;
    vr_nrdolote := 11000 + pr_nrdcaixa;

    IF pr_dsorigem = 'INTERNET' THEN
      vr_idorigem := 3;
    ELSIF pr_dsorigem = 'TAA' THEN
      vr_idorigem := 4;
    END IF;

    --> Buscar dados da cooperativa
    OPEN cr_crapcop (pr_cdcooper  => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Cooperativa nao cadastrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Obtem parametros para condicoes de cancelamento
    PAGA0002.pc_param_cancelamento(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                                  ,pr_cdagenci => pr_cdagenci   --> Codigo do PA
                                  ,pr_dtmvtolt => vr_datdodia   --> Data Atual de Movimentacao
                                  ,pr_hrfimcan => vr_hrfimcan   --> Hora de Fim do Cancelamento
                                  ,pr_dssgproc => vr_dssgproc
                                  ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                  ,pr_dscritic => vr_dscritic); --> Descricao da Critica

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF UPPER(pr_nmdatela) = 'AGENET' THEN


      --> Buscar dados do operado
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        vr_dscritic := 'Nao foi possivel encontrar o operador.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapope;
      END IF;

      IF rw_crapope.nvoperad NOT IN (2,3) THEN
			  vr_dscritic := 'Cancelamento somente permitido por coordenadores/gerentes.';
        RAISE vr_exc_erro;
		  END IF;

    END IF;

    -- Buscar dados agendamento
    OPEN cr_craplau ( pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtmvtage => pr_dtmvtage,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdolote => vr_nrdolote,
                      pr_nrdocmto => pr_nrdocmto,
                      pr_dsorigem => pr_dsorigem);
    FETCH cr_craplau INTO rw_craplau;
    IF cr_craplau%NOTFOUND THEN
      CLOSE cr_craplau;
      vr_dscritic := 'Agendamento nao cadastrado.';
    ELSE
      CLOSE cr_craplau;
    END IF;

    --> Verifica se agendamento esta pendente
    IF rw_craplau.insitlau <> 1                                           AND
       NOT (rw_craplau.insitlau = 2 AND rw_craplau.dtmvtopg > vr_datdodia)  THEN
      vr_dscritic := 'Para cancelar, o agendamento deve estar PENDENTE.';
      RAISE vr_exc_erro;
    END IF;

    --> Se for agendamento de TED
    IF rw_craplau.cdtiptra = 4 THEN
      --> Somente pode ser permitido cancela-lo se o mesmo AINDA ESTA COM O STATUS DE "EFETIVADO".
      IF rw_craplau.insitlau <> 1 THEN
        vr_dscritic := 'Para cancelar, o agendamento deve estar PENDETE.';
        RAISE vr_exc_erro;
      END IF;
    END IF;


    vr_dsvlrprm := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                              pr_cdcooper => pr_cdcooper,
                                              pr_cdacesso => 'HORARIO_CANCELAMENTO_TED');

    IF TRIM(vr_dsvlrprm) IS NULL THEN
      vr_dscritic := 'Nao foi encontrado horario limite para cancelamento de TED.';
      RAISE vr_exc_erro;
    END IF;

    --> O cancelamento de TED dever ser permitido somente ate as 8:30 (Horario parametrizado atraves da tabela crapprm)
    --  pois o programa pr_crps705 (Responsavel pelo debito de agendamentos de TED) sera iniciado as 8:40.
    --  Qualquer mudanca na condicao abaixo devera ser previamente discutida com
    --  a equipe do financeiro (Juliana), do canais de atendimento (Jefferson),
		--	Seguranca Corporativa (Maicon) e de sistemas (Adriano, Rosangela).

    IF (rw_craplau.dtmvtopg = vr_datdodia AND
        gene0002.fn_busca_time > to_number(vr_dsvlrprm))        THEN
			 vr_dscritic := 'Cancelamento permitido apenas ate '|| gene0002.fn_calc_hora(vr_dsvlrprm)||'hrs.';
       RAISE vr_exc_erro;
    END IF;

    --> Alterar status de transacao para reprovada
    IF rw_craplau.cdtrapen > 0 THEN
      BEGIN
        UPDATE tbgen_trans_pend tr
           SET tr.idsituacao_transacao = 6, --> Reprovada
               tr.dtalteracao_situacao = SYSDATE
         WHERE tr.cdtransacao_pendente = rw_craplau.cdtrapen;

         IF SQL%ROWCOUNT = 0 THEN
           vr_dscritic := 'Registro de transacao nao cadastrado.';
           RAISE vr_exc_erro;
         END IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar transacao pendente: '||SQLERRM;
      END;
    END IF;

    --> Verifica horario para cancelar e parametro do segundo processo
    IF rw_craplau.dtmvtopg = vr_datdodia  AND
       (gene0002.fn_busca_time > vr_hrfimcan OR vr_dssgproc = 'NAO') THEN
      vr_dscritic := 'Sem permissao para excluir o agendamento no momento.';
      RAISE vr_exc_erro;
    END IF;

    --> Estornar registros ja criados referente ao debito
    IF rw_craplau.insitlau = 2  THEN
      --> Transf. Intracoop.
      IF rw_craplau.cdtiptra IN (1,3) THEN --> 1-Normal, 3-Credito Salario
        vr_nrdocdeb := SUBSTR(rw_craplau.dscedent,15,11);
        vr_nrdoccre := SUBSTR(rw_craplau.dscedent,44,11);

        -- Executar rotina verifica-historico-transferencia
        PAGA0001.pc_verifica_historico_transf
                                     (pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                     ,pr_nrdconta => rw_craplau.nrdconta   --> Conta associado
                                     ,pr_nrctatrf => rw_craplau.nrctadst   --> Conta destino
                                     ,pr_cdorigem => vr_idorigem           --> Identificador Origem
                                     ,pr_cdtiptra => rw_craplau.cdtiptra   --> Tipo transacao
                                     ,pr_cdhiscre => vr_cdhiscre   --> Historico Credito
                                     ,pr_cdhisdeb => vr_cdhisdeb   --> Historico Debito
                                     ,pr_cdcritic => vr_cdcritic   --> Código do erro
                                     ,pr_dscritic => vr_dscritic); --> Descricao do erro

      /*  RUN estorna-transferencia IN h-b1wgen0015
                                                       (INPUT par_cdcooper,
                                                        INPUT craplau.nrdconta,
                                                        INPUT craplau.idseqttl,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT craplau.nrctadst,
                                                        INPUT aux_cdhisdeb,
                                                        INPUT aux_cdhiscre,
                                                        INPUT aux_nrdocdeb,
                                                        INPUT aux_nrdoccre,
                                                        INPUT par_cdoperad,
                                                       OUTPUT aux_dstransa,
                                                       OUTPUT par_dscritic,
                                                       OUTPUT aux_dsprotoc).*/

        IF nvl(vr_cdcritic,0) > 0 OR
           vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      --> PAGAMENTO
      ELSIF rw_craplau.cdtiptra = 2  THEN
        --> Titulo
        IF LENGTH(rw_craplau.dslindig) = 54  THEN
          /*RUN estorna_titulo (INPUT par_cdcooper,
                                                    INPUT craplau.nrdconta,
                                                    INPUT craplau.idseqttl,
                                                    INPUT craplau.dscodbar,
                                                    INPUT craplau.dscedent,
                                                    INPUT craplau.vllanaut,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_idorigem,
                                                   OUTPUT aux_dstransa,
                                                   OUTPUT par_dscritic,
                                                   OUTPUT aux_dsprotoc).*/
          IF nvl(vr_cdcritic,0) > 0 OR
             vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        --> CONVENIO
        ELSIF LENGTH(rw_craplau.dslindig) = 55 THEN

          vr_dscodbar := rw_craplau.dscodbar;

          --> Retornar valores fatura
          CXON0014.pc_retorna_valores_fatura (pr_cdcooper      => pr_cdcooper  --Codigo Cooperativa
                                             ,pr_nrdconta      => pr_nrdconta  --Numero da Conta
                                             ,pr_idseqttl      => pr_idseqttl  --Sequencial Titular
                                             ,pr_cod_operador  => pr_cdoperad  --Codigo Operador
                                             ,pr_cod_agencia   => pr_cdagenci  --Codigo Agencia
                                             ,pr_nro_caixa     => 0            --Numero Caixa
                                             ,pr_fatura1       => 0            --Parte 1 fatura
                                             ,pr_fatura2       => 0            --Parte 2 fatura
                                             ,pr_fatura3       => 0            --Parte 3 fatura
                                             ,pr_fatura4       => 0            --Parte 4 fatura
                                             ,pr_codigo_barras => vr_dscodbar  --Codigo barras
                                             ,pr_cdseqfat      => vr_cdseqfat  --Sequencial faturamento
                                             ,pr_vlfatura      => vr_vlfatura  --Valor Fatura
                                             ,pr_nrdigfat      => vr_nrdigfat  --Digito Faturamento
                                             ,pr_iptu          => vr_flagiptu  --Indicador IPTU
                                             ,pr_cdcritic      => vr_cdcritic  --Codigo do erro
                                             ,pr_dscritic      => vr_dscritic);   --Descricao do erro
          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          /*RUN estorna_convenio (INPUT par_cdcooper,
                                                      INPUT craplau.nrdconta,
                                                      INPUT craplau.idseqttl,
                                                      INPUT aux_dscodbar,
                                                      INPUT craplau.dscedent,
                                                      INPUT aux_cdseqfat,
                                                      INPUT aux_vldpagto,
                                                      INPUT par_cdoperad,
                                                      INPUT aux_idorigem,
                                                     OUTPUT aux_dstransa,
                                                     OUTPUT par_dscritic,
                                                     OUTPUT aux_dsprotoc).*/


          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;

      --> TRANSF. INTERCOOP.
      ELSIF rw_craplau.cdtiptra = 5 THEN

        vr_nrdocdeb := SUBSTR(rw_craplau.dscedent,15,11);
        vr_nrdoccre := SUBSTR(rw_craplau.dscedent,44,11);
        vr_cdlantar := SUBSTR(rw_craplau.dscedent,71,11);

        /*
        RUN estorna-transferencia-intercooperativa
                            IN h-b1wgen0015 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT craplau.nrdconta,
                                             INPUT craplau.idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT aux_idorigem,
                                             INPUT craplau.cdageban,
                                             INPUT craplau.nrctadst,
                                             INPUT craplau.vllanaut,
                                             INPUT aux_nrdocdeb,
                                             INPUT aux_nrdoccre,
                                             INPUT aux_cdlantar,
                                             INPUT par_cdoperad,
                                            OUTPUT aux_dstransa,
                                            OUTPUT par_dscritic,
                                            OUTPUT aux_dsprotoc).*/

        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

    END IF; -- insitlau

    vr_insitlau := rw_craplau.insitlau;

    --> Atualiza situacao do agendamento para cancelado
    BEGIN

      UPDATE craplau lau
         SET lau.insitlau = 3,
             lau.dtdebito = lau.dtmvtopg
       WHERE lau.rowid = rw_craplau.rowid
       RETURNING insitlau INTO rw_craplau.insitlau;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar agendamento: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    IF rw_craplau.idtitdda > 0  THEN

      --Atualizar situacao titulo
      DDDA0001.pc_atualz_situac_titulo_sacado (pr_cdcooper => pr_cdcooper   --Codigo da Cooperativa
                                              ,pr_cdagecxa => pr_cdagenci   --Codigo da Agencia
                                              ,pr_nrdcaixa => 900           --Numero do Caixa
                                              ,pr_cdopecxa => '996'         --Codigo Operador Caixa
                                              ,pr_nmdatela => 'INTERNETBANK'--Nome da tela
                                              ,pr_idorigem => 3             --Indicador Origem
                                              ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                              ,pr_idseqttl => pr_idseqttl   --Sequencial do titular
                                              ,pr_idtitdda => rw_craplau.idtitdda   --Indicador Titulo DDA
                                              ,pr_cdctrlcs => rw_craplau.cdctrlcs   --Identificador da consulta
                                              ,pr_cdsittit => 1             --Situacao Titulo
                                              ,pr_flgerlog => 0                -- Gerar Log
                                              ,pr_cdcritic => vr_cdcritic      -- Codigo de critica
                                              ,pr_dscritic => vr_dscritic);    -- Descrição de critica
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

    END IF;

    --> Se for agendamento de TED
    IF rw_craplau.cdtiptra = 4 THEN
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Agendamento de TED cancelado com sucesso.'
                          ,pr_dsorigem => pr_dsorigem
                          ,pr_dstransa => pr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'insitlau',
                                pr_dsdadant => vr_insitlau,
                                pr_dsdadatu => rw_craplau.insitlau);
    END IF;


  EXCEPTION
    WHEN vr_exc_erro THEN


      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;


      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN


      pr_dscritic := 'Erro na rotina estorno/baixa tarifa: '||SQLERRM;


  END pc_cancelar_agendamento;

  -- Realizar a apuração diária dos lançamentos dos históricos de pagamento de empréstimos
  PROCEDURE pc_apura_lcm_his_emprestimo(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                       ,pr_dtrefere IN DATE   ) IS           -- Data de referencia
    /* ..........................................................................
    --
    --  Programa : pc_apura_juros_capital        
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci - Supero
    --  Data     : Agosto/2017.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Realizar a apuração diária dos lançamentos dos históricos de 
    --               pagamento de empréstimos e gravar os valores em uma tabela auxiliar
    -- ..........................................................................*/
    
    -- ROTINA CRIADA COM PRAGMA AUTONOMO PARA QUE O COMMIT DA MESMA NÃO AFETE ROTINAS CHAMADORAS.
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    ---------------> VARIAVEIS <-----------------
    -- Variaveis de erro    
    vr_cdcritic        crapcri.cdcritic%TYPE;
    vr_dscritic        VARCHAR2(4000);
    -- Variáveis de Excecao
    vr_exc_erro        EXCEPTION;
    -- Variáveis
    vr_cdoperac_pagepr   NUMBER;
    
  BEGIN
    
    -- Buscar o código de operação para os registros
    vr_cdoperac_pagepr := to_number(gene0001.fn_param_sistema('CRED',0,'CDOPERAC_HIS_PAGTO_EPR'));
    
    -- Garantir que em caso de reprocessamento os registros sejam recalculados
    DELETE TBCC_OPERACOES_DIARIAS  tab
     WHERE tab.cdcooper   = pr_cdcooper
       AND tab.cdoperacao = vr_cdoperac_pagepr
       AND tab.dtoperacao = pr_dtrefere;
    
    -- Inserir os regitros referente aos lançamentos do dia
    INSERT INTO TBCC_OPERACOES_DIARIAS(cdcooper, nrdconta, cdoperacao, dtoperacao, vloperacao)
       (SELECT pr_cdcooper
             , lcm.nrdconta
             , vr_cdoperac_pagepr
             , pr_dtrefere
             , SUM(decode(lcm.cdhistor,
                          108, lcm.vllanmto,
                          275, lcm.vllanmto,
                         1539, lcm.vllanmto,
                          393, lcm.vllanmto,
                         1706, lcm.vllanmto * -1,
                           99, lcm.vllanmto * -1,
                            0)) vllanmto
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.cdhistor IN (108, 275, 1539, 393, 1706, 99)
           AND lcm.dtmvtolt = pr_dtrefere
         GROUP BY pr_cdcooper
               , lcm.nrdconta
               , vr_cdoperac_pagepr
               , pr_dtrefere);
    
    -- Efetivar os dados gerados
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Desfazer alterações pendentes
      ROLLBACK;
      -- Efetuar montagem de e-mail
      gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                                ,pr_cdprogra    => 'SOBR0001.pc_apura_juros_capital'
                                ,pr_des_destino => gene0001.fn_param_sistema('CRED',pr_cdcooper, 'ERRO_EMAIL_JOB')
                                ,pr_des_assunto => 'Apuração Auto Atendimento – Coop '||pr_cdcooper
                                ,pr_des_corpo   => 'Olá, <br><br>'
                                                || 'Foram encontrados problemas durante o processo de apuração '
                                                || 'dos valores de Históricos dos Lançamentos de Empréstimos. <br> '
                                                || 'Erro encontrado:<br>'||SQLERRM
                                ,pr_des_anexo   => ''
                                ,pr_flg_enviar  => 'N'
                                ,pr_des_erro    => vr_dscritic);
      -- Gravar a solictação do e-mail para envio posterior
      COMMIT;
  END pc_apura_lcm_his_emprestimo;
  

END PAGA0002;
/
