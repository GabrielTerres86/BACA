/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank1.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 18/09/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar saldos para resumo da conta corrente.

   Alteracoes: 01/04/2008 - Incluir parametro de retorno na procedure
                            saldo-devedor-epr
                          - Obter saldo ate a data do dia (TODAY) (David).

               29/09/2008 - Retornar valores de desconto de titulos (David).

               04/11/2008 - Inclusao do widget-pool (Martin).

               12/11/2008 - Adaptacao para novo acesso a conta para pessoas
                            juridicas (David).

               14/09/2009 - Retornar data corrente do sistema (David).

               04/03/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David).

               22/04/2010 - Retornar flag indicando se cooperado possui cartao
                            de credito do Bradesco (David).

               13/12/2010 - Tratamento para sobreposicao de PAC's (David).

               13/04/2011 - Verificacao se o cooperado possui debito automatico
                            conveniado a SAMAE (Jorge).

               28/09/2011 - Adicionar retorno de nome "aux_nmprepos" e
                            CPF "aux_nrcpfpre" do preposto (Jorge).

               25/11/2011 - Incluir parametros na operacao com dados da origem
                            da solicitacao (IP usuario) (David).

               09/03/2012 - Adicionado parametro par_dtmvtoan. (Jorge)

               24/04/2012 - Retornar dados para informacoes sobre TED (David).

               14/05/2012 - Retornar se cooperado ja cadastrou as letras de
                            seguranca para o TAA (David).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               07/11/2012 - Ajuste na leitura de letras de seguranca (David).

               21/12/2012 - Ajuste Alto Vale (David).

               07/02/2013 - Adicionado verificacao de Prova de Vida. (Jorge)

               22/07/2013 - Ajustes para implementacao de bloqueio de senha
                            (Jorge).

               07/10/2013 - Retornar PAC do cooperado migrado (David).

               13/11/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (Guilherme Gielow)

               18/11/2013 - Ajuste para retornar no XML a Conta Anterior
                            (James).

               21/11/2013 - Ajuste para retornar no XML a Cooperativa Anterior
                            (Aline).

               16/12/2013 - Verificar flgativo na tabela craptco (Rafael).

               24/06/2014 - Ajuste para retornar no XML os Recursos Captados por
                            Cooperado, Rendimento e o Limite de Credito tomado
                            (Aline).

               05/09/2014 - Ajuste para carregar o saldo disponivel do
                            pre-aprovado. (James)

               09/09/2014 - Ajuste para retornar no XML um indicador de valor de
                            crédito dentro dos limites (Dionathan).

               11/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                            procedure "busca_dados" da "b1wgen0188". (Jaison)

               08/12/2014 - Incluso comentario (Daniel)

               04/02/2015 - Incluido chamada a procedure pc_verifica_conta_capital
                            referente ao retorno de sobras e juros sobre capital.
                            (Reinert)

               05/02/2015 - Retirado as 2 execucoes da procedure consulta-aplicacoes
                            da BO b1wgen0004.p e inserido a execucao da procedure
                            pc_lista_aplicacoes_car da APLI0005 para consulta
                            de saldos de aplicacoes novas e antigas (Jean Michel).

               19/05/2015 - Retirado nome do programa de APLICACOES e inserido como
                            INTERNETBANK (Jean Michel).

               22/06/2015 - Ajustado a pesquisa do saldo da conta para utilizar a
                            procedure pc_obtem_saldo_dia_prog
                            (Douglas - Chamado 285228 - obtem-saldo-dia)

               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)

               24/11/2015 - Adicionado condicao para a leitura de dados de preposto
                                                        ser executada somente para conta PJ que não exige
                                                        assinatura conjunta. (Jorge/David) Projeto 131.

               21/12/2015 - Passar parâmetro flmobile para b1wnet0002.verifica-acesso
                            (Dionathan)

               23/12/2015 - Retornar nome do representante legal se for conta
                            com assinatura conjunta - Projeto 131 (David).

               04/01/2016 - Retornar parametro indicando se houve credito de
                            juros sobre o capital (David).

               28/01/2016 - Efetuado ajustes para o Projeto 255. (Reinert)

               04/07/2016 - Incluida TAG nmtitula, SD 472160 (Jean Michel).

               16/11/2016 - M172 - Atualizacao Telefone Auto Atendimento
                            (Guilherme/SUPERO)

			   18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               18/09/2017 - Alteracao na mascara da Agencia do Banco do Brasil.
                            (Jaison/Elton - M459)

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0020tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0003 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0020 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0023 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0032 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0091 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dtaltsnh AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_dtultace AS CHAR                                           NO-UNDO.
DEF VAR aux_hrultace AS CHAR                                           NO-UNDO.
DEF VAR aux_dsurlace AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagedbb AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbcoctl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagectl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmmesant AS CHAR                                           NO-UNDO.
DEF VAR aux_nmmesatu AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprepos AS CHAR                                           NO-UNDO.
DEF VAR aux_flglimcr AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitula AS CHAR										   NO-UNDO.
DEF VAR aux_nmmesano AS CHAR EXTENT 12
    INIT ["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO",
          "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"] NO-UNDO.

DEF VAR aux_vlsddisp AS DECI                                           NO-UNDO.
DEF VAR aux_vlsdbloq AS DECI                                           NO-UNDO.
DEF VAR aux_vlstotal AS DECI                                           NO-UNDO.
DEF VAR aux_vlsdeved AS DECI                                           NO-UNDO.
DEF VAR aux_vldiscrd AS DECI                                           NO-UNDO.
DEF VAR aux_vllautom AS DECI                                           NO-UNDO.
DEF VAR aux_vllaudeb AS DECI                                           NO-UNDO.
DEF VAR aux_vllaucre AS DECI                                           NO-UNDO.
DEF VAR aux_vlsdrdca AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldrdc AS DECI                                           NO-UNDO.
DEF VAR aux_vltotrpp AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_sdctainv AS DECI                                           NO-UNDO.
DEF VAR aux_vldcotas AS DECI                                           NO-UNDO.
DEF VAR aux_vllimchq AS DECI                                           NO-UNDO.
DEF VAR aux_vldscchq AS DECI                                           NO-UNDO.
DEF VAR aux_vllimtit AS DECI                                           NO-UNDO.
DEF VAR aux_vldsctit AS DECI                                           NO-UNDO.
DEF VAR aux_vltotpre AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfpre AS DECI                                           NO-UNDO.
DEF VAR tmp_cdagectl AS DECI                                           NO-UNDO.
DEF VAR aux_vlreccap AS DECI                                           NO-UNDO.
DEF VAR aux_vllicret AS DECI                                           NO-UNDO.
DEF VAR aux_vltotren AS DECI                                           NO-UNDO.
DEF VAR aux_vljurcap AS DECI                                           NO-UNDO.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_indconve AS INTE                                           NO-UNDO.
DEF VAR aux_indpagto AS INTE                                           NO-UNDO.
DEF VAR aux_indholer AS INTE                                           NO-UNDO.
DEF VAR aux_indinfor AS INTE                                           NO-UNDO.
DEF VAR aux_cditemmn AS INTE                                           NO-UNDO.
DEF VAR aux_nrctanov AS INTE                                           NO-UNDO.
DEF VAR aux_cdagemig AS INTE                                           NO-UNDO.
DEF VAR aux_cdblqsnh AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiams1 AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiams2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaant AS INTE                                           NO-UNDO.
DEF VAR aux_cdcopant AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_flgconve AS LOGI                                           NO-UNDO.
DEF VAR aux_flgtitul AS LOGI                                           NO-UNDO.
DEF VAR aux_flgcrbrd AS LOGI                                           NO-UNDO.
DEF VAR aux_flgsamae AS LOGI                                           NO-UNDO.
DEF VAR aux_flsenlet AS LOGI                                           NO-UNDO.

DEF VAR aux_flgconsu AS INTE                                           NO-UNDO.
DEF VAR aux_vltotsob AS DECI                                           NO-UNDO.
DEF VAR aux_vlliqjur AS DECI                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_qtprecal LIKE crapepr.qtprecal                             NO-UNDO.

DEF VAR aux_ponteiro AS INTE                                           NO-UNDO.
DEF VAR aux_flgpvida AS INTE                                           NO-UNDO.
DEF VAR aux_flgbinss AS INTE                                           NO-UNDO.

DEF BUFFER crabass FOR crapass.

/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE   NO-UNDO.
DEF VAR xRoot         AS HANDLE   NO-UNDO.
DEF VAR xRoot2        AS HANDLE   NO-UNDO.
DEF VAR xField        AS HANDLE   NO-UNDO.
DEF VAR xText         AS HANDLE   NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
DEF VAR aux_cont      AS INTEGER  NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO.
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

/* SE FOR INCLUSO NOVO PARAMETRO,
O PROGRAMA programa tempo_execucao_ibank.p DEVE SER AJUSTADO! (DANIEL) */
DEF INPUT  PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtopr LIKE crapdat.dtmvtopr                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtocd LIKE crapdat.dtmvtocd                    NO-UNDO.
DEF INPUT  PARAM par_inproces LIKE crapdat.inproces                    NO-UNDO.
DEF INPUT  PARAM par_indlogin AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_nripuser AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_dsorigip AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_dtmvtoan LIKE crapdat.dtmvtoan                    NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Resumo de conta corrente".

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN aux_dscritic = "Registro de cooperativa nao encontrado."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".
    END.

ASSIGN tmp_cdagectl = crapcop.cdagectl.

IF  tmp_cdagectl <> 0  THEN
    DO:
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

        IF  VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN tmp_cdagectl = DECI(STRING(tmp_cdagectl) + "0").

                RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                             INPUT 90,
                                             INPUT 900,
                                             INPUT-OUTPUT tmp_cdagectl,
                                            OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen9999.
            END.
    END.

ASSIGN aux_cdagedbb = IF  crapcop.cdagedbb = 0  THEN
                          ""
                      ELSE
                          STRING(STRING(crapcop.cdagedbb,"zzzzzzz9"),"xxxxxxx-x")
       aux_cdbcoctl = IF  crapcop.cdbcoctl = 0  THEN
                          ""
                      ELSE
                          STRING(crapcop.cdbcoctl,"999")
       aux_cdagectl = IF  tmp_cdagectl = 0  THEN
                          ""
                      ELSE
                          STRING(STRING(tmp_cdagectl,"99999"),"xxxx-x").

FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapass  THEN
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 9 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN
            ASSIGN aux_dscritic = crapcri.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Nao foi possivel carregar os saldos.".

        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".
    END.

IF  crapass.inpessoa = 1  THEN
    DO:
        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                           crapttl.nrdconta = par_nrdconta AND
                           crapttl.idseqttl = par_idseqttl 
						   NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapttl  THEN
            DO:
                ASSIGN aux_dscritic = "Titular da conta invalido."
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.

        ASSIGN aux_nmextttl = crapttl.nmextttl
               aux_nmoperad = crapttl.nmextttl
               aux_inpessoa = crapttl.inpessoa.
    END.
ELSE
    DO:
        ASSIGN aux_inpessoa = crapass.inpessoa
               aux_nmextttl = crapass.nmprimtl
               aux_nmoperad = crapass.nmprimtl
                           aux_nmtitula = crapass.nmprimtl.

        IF  par_nrcpfope > 0  THEN
            DO:
                FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                   crapopi.nrdconta = par_nrdconta AND
                                   crapopi.nrcpfope = par_nrcpfope
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapopi  THEN
                    DO:
                        ASSIGN aux_dscritic = "Operador nao cadastrado."
                               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                              "</dsmsgerr>".

                        RUN proc_geracao_log (INPUT FALSE).

                        RETURN "NOK".
                    END.

                ASSIGN aux_nmoperad = crapopi.nmoperad.
            END.

        /* Obter Dados do Preposto */
        IF crapass.idastcjt = 0  THEN DO:
            /* buscar cpf do preposto */
            FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper
                                AND crapsnh.nrdconta = par_nrdconta
                                AND crapsnh.idseqttl = 1
                                AND crapsnh.tpdsenha = 1
                                NO-LOCK. END.

            IF AVAIL crapsnh THEN
               DO:
                  ASSIGN aux_nrcpfpre = crapsnh.nrcpfcgc.
                  /* buscar nome do preposto */
                  FOR FIRST crapavt WHERE crapavt.cdcooper = crapsnh.cdcooper
                                      AND crapavt.nrdconta = crapsnh.nrdconta
                                      AND crapavt.nrcpfcgc = crapsnh.nrcpfcgc
                                      AND crapavt.tpctrato = 6 /* Jur */
                                      NO-LOCK. END.
                  IF AVAIL crapavt THEN
                     DO:
                        IF crapavt.nrdctato <> 0 then
                           DO:
                              FOR FIRST crabass
                                  WHERE crabass.cdcooper = par_cdcooper
                                    AND crabass.nrdconta = crapavt.nrdctato
                                        NO-LOCK. END.

                              IF AVAIL crabass THEN
                                 ASSIGN aux_nmprepos = crabass.nmprimtl.
                              ELSE
                                 ASSIGN aux_nmprepos = crapavt.nmdavali.
                           END.
                        ELSE
                           ASSIGN aux_nmprepos = crapavt.nmdavali.
                     END.
               END.
        END.
        ELSE DO: /* Obter Dados do Representante Legal */
            /* buscar cpf do preposto */
            FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper
                                AND crapsnh.nrdconta = par_nrdconta
                                AND crapsnh.idseqttl = par_idseqttl
                                AND crapsnh.tpdsenha = 1
                                    NO-LOCK. END.

            IF AVAIL crapsnh THEN
               DO:
                  /* buscar nome do representante */
                  FOR FIRST crapavt WHERE crapavt.cdcooper = crapsnh.cdcooper
                                      AND crapavt.nrdconta = crapsnh.nrdconta
                                      AND crapavt.nrcpfcgc = crapsnh.nrcpfcgc
                                      AND crapavt.tpctrato = 6 /* Jur */
                                          NO-LOCK. END.
                  IF AVAIL crapavt THEN
                     DO:
                        IF crapavt.nrdctato <> 0 then
                           DO:
                              FOR FIRST crabass
                                  WHERE crabass.cdcooper = par_cdcooper
                                    AND crabass.nrdconta = crapavt.nrdctato
                                        NO-LOCK. END.

                              IF AVAIL crabass THEN
                                 ASSIGN aux_nmextttl = crabass.nmprimtl
                                        aux_nmoperad = crabass.nmprimtl.
                              ELSE
                                 ASSIGN aux_nmextttl = crapavt.nmdavali
                                        aux_nmoperad = crapavt.nmdavali.
                           END.
                        ELSE
                           ASSIGN aux_nmextttl = crapavt.nmdavali
                                  aux_nmoperad = crapavt.nmdavali.
                    END.
                END.
        END.
    END.

ASSIGN aux_nmmesatu = aux_nmmesano[MONTH(par_dtmvtolt)]
       aux_nmmesant = IF  (MONTH(par_dtmvtolt) - 1) = 0  THEN
                          aux_nmmesano[12]
                      ELSE
                          aux_nmmesano[MONTH(par_dtmvtolt) - 1].

/* Verifica se o cooperado possui cartao Cecred Visa Bradesco em uso */
FIND FIRST crawcrd WHERE crawcrd.cdcooper = par_cdcooper AND
                         crawcrd.nrdconta = par_nrdconta AND
                         crawcrd.cdadmcrd = 3            AND /** Bradesco **/
                         crawcrd.insitcrd = 4                /** Em Uso   **/
                         NO-LOCK NO-ERROR.

ASSIGN aux_flgcrbrd = AVAILABLE crawcrd.

/* Verificar se a conta pertence a um PAC sobreposto */
FIND craptco WHERE craptco.cdcopant = par_cdcooper AND
                   craptco.nrctaant = par_nrdconta AND
                   craptco.tpctatrf = 1            AND
                   craptco.flgativo = TRUE
                   NO-LOCK NO-ERROR.

IF  NOT AVAIL craptco  THEN
    FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                       craptco.nrdconta = par_nrdconta AND
                       craptco.tpctatrf = 1            AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

ASSIGN aux_nrctanov = IF AVAILABLE craptco THEN craptco.nrdconta ELSE 0
       aux_cdagemig = IF AVAILABLE craptco THEN craptco.cdageant ELSE 0
       aux_nrctaant = IF AVAILABLE craptco THEN craptco.nrctaant ELSE 0
       aux_cdcopant = IF AVAILABLE craptco THEN craptco.cdcopant ELSE 0.


/* Verifica se a conta possui debito automatico conveniado ao SAMAE */
FIND FIRST crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                         crapatr.nrdconta = par_nrdconta AND
                         crapatr.dtfimatr = ?            AND
                         crapatr.cdhistor = 643          NO-LOCK NO-ERROR.
ASSIGN aux_flgsamae = AVAIL crapatr.

/* Busca saldo da Conta Corrente */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

/* Utilizar o tipo de busca A, para carregar do dia anterior
 (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */
RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                         INPUT 90, /* cdagenci */
                                         INPUT 900, /* nrdcaixa */
                                         INPUT "996",
                                         INPUT par_nrdconta,
                                         INPUT aux_datdodia,
                                         INPUT "A", /* Tipo Busca */
                                         OUTPUT 0,
                                         OUTPUT "").

CLOSE STORED-PROC pc_obtem_saldo_dia_prog
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic
                          WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
       aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                          WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?.

IF aux_cdcritic <> 0  OR
   aux_dscritic <> "" THEN
   DO:
       IF aux_dscritic = "" THEN
          ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                             "</dsmsgerr>".

       RETURN "NOK".
   END.

FIND FIRST wt_saldos NO-LOCK NO-ERROR.
IF AVAIL wt_saldos THEN
DO:
    ASSIGN aux_vlsddisp = wt_saldos.vlsddisp + wt_saldos.vlsdchsl
           aux_vlsdbloq = wt_saldos.vlsdbloq + wt_saldos.vlsdblpr +
                          wt_saldos.vlsdblfp
           aux_vlstotal = wt_saldos.vlsddisp + wt_saldos.vlsdchsl +
                          wt_saldos.vlsdbloq + wt_saldos.vlsdblpr +
                          wt_saldos.vlsdblfp
           aux_vlreccap = wt_saldos.vlsddisp + wt_saldos.vlsdrdca +
                          wt_saldos.vlsdcota
           aux_vllicret = wt_saldos.vlopcdia + wt_saldos.vllimutl
           aux_vltotren = wt_saldos.vltotren.
END.


RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT
    SET h-b1wgen0002.

IF  VALID-HANDLE(h-b1wgen0002)  THEN
    DO:
        /* Busca saldo devedor do emprestimos */
        RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT par_cdcooper,
                                               INPUT 90,
                                               INPUT 900,
                                               INPUT "996",
                                               INPUT "InternetBank",
                                               INPUT 3,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT 0,
                                               INPUT "InternetBank",
                                               INPUT par_inproces,
                                               INPUT FALSE,
                                              OUTPUT aux_vlsdeved,
                                              OUTPUT aux_vltotpre,
                                              OUTPUT aux_qtprecal,
                                              OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0002.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os saldos.".

                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.
    END.

RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

IF VALID-HANDLE(h-b1wgen0188)  THEN
   DO:
       /* Busca saldo disponivel para o credito pre-aprovado  */
       RUN busca_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                        INPUT 90,
                                        INPUT 900,
                                        INPUT "996",
                                        INPUT "InternetBank",
                                        INPUT 3,
                                        INPUT par_nrdconta,
                                        INPUT IF crapass.idastcjt = 0 THEN par_idseqttl ELSE 1,
                                        INPUT par_nrcpfope,
                                        OUTPUT TABLE tt-dados-cpa,
                                        OUTPUT TABLE tt-erro).

       DELETE PROCEDURE h-b1wgen0188.
       /* Caso ocorrer erro, nao precisamos disparar a mensagem de erro.
          Pois nao mostrara o saldo em tela nessas situacoes */
       IF RETURN-VALUE <> "OK" THEN
          EMPTY TEMP-TABLE tt-erro.
       ELSE
          DO:
              FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
              IF AVAIL tt-dados-cpa THEN
                 ASSIGN aux_vldiscrd = tt-dados-cpa.vldiscrd.
          END.
   END.


RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT
    SET h-b1wgen0003.

IF  VALID-HANDLE(h-b1wgen0003)  THEN
    DO:
        /* Busca saldo de lancamentos futuros */
        RUN consulta-lancamento IN h-b1wgen0003 (INPUT par_cdcooper,
                                             INPUT 90,
                                             INPUT 900,
                                             INPUT "996",
                                             INPUT par_nrdconta,
                                             INPUT 3,
                                             INPUT par_idseqttl,
                                             INPUT "InternetBank",
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-totais-futuros,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-lancamento_futuro).

        DELETE PROCEDURE h-b1wgen0003.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os saldos.".

                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.

        FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-totais-futuros  THEN
            ASSIGN aux_vllautom = tt-totais-futuros.vllautom
                   aux_vllaudeb = tt-totais-futuros.vllaudeb
                   aux_vllaucre = tt-totais-futuros.vllaucre.
    END.

/* Inicializando objetos para leitura do XML */
CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */
CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */
CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */
CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

ASSIGN aux_vlsdrdca = 0.

EMPTY TEMP-TABLE tt-saldo-rdca.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

/* Efetuar a chamada a rotina Oracle */
RUN STORED-PROCEDURE pc_lista_aplicacoes_car
   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,   /* Código da Cooperativa */
                                        INPUT "1",            /* Código do Operador */
                                        INPUT "InternetBank", /* Nome da Tela */
                                        INPUT 3,              /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                        INPUT 900,            /* Numero do Caixa */
                                        INPUT par_nrdconta,   /* Número da Conta */
                                        INPUT par_idseqttl,   /* Titular da Conta */
                                        INPUT 90,             /* Codigo da Agencia */
                                        INPUT "InternetBank", /* Codigo do Programa */
                                        INPUT 0,              /* Número da Aplicação - Parâmetro Opcional */
                                        INPUT 0,              /* Código do Produto – Parâmetro Opcional */
                                        INPUT par_dtmvtolt,   /* Data de Movimento */
                                        INPUT 6,              /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                        INPUT 0,              /* Identificador de Log (0 – Não / 1 – Sim) */
                                       OUTPUT ?,              /* XML com informações de LOG */
                                       OUTPUT 0,              /* Código da crítica */
                                       OUTPUT "").            /* Descrição da crítica */

/* Fechar o procedimento para buscarmos o resultado */
CLOSE STORED-PROC pc_lista_aplicacoes_car
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

/* Busca possíveis erros */
ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic
                      WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
       aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic
                      WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.

IF aux_cdcritic <> 0 OR
   aux_dscritic <> "" THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".

    END.

/*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
para visualizacao dos registros na tela */

/* Buscar o XML na tabela de retorno da procedure Progress */
ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc.

/* Efetuar a leitura do XML*/
SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
PUT-STRING(ponteiro_xml,1) = xml_req.

IF ponteiro_xml <> ? THEN
    DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).

        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:

            xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

            IF xRoot2:SUBTYPE <> "ELEMENT" THEN
             NEXT.

            IF xRoot2:NUM-CHILDREN > 0 THEN
              CREATE tt-saldo-rdca.

            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                xRoot2:GET-CHILD(xField,aux_cont).

                IF xField:SUBTYPE <> "ELEMENT" THEN
                    NEXT.

                xField:GET-CHILD(xText,1).
                ASSIGN tt-saldo-rdca.nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
                ASSIGN tt-saldo-rdca.qtdiauti = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".
                ASSIGN tt-saldo-rdca.vlaplica = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
                ASSIGN tt-saldo-rdca.nrdocmto =      xText:NODE-VALUE  WHEN xField:NAME = "nrdocmto".
                ASSIGN tt-saldo-rdca.indebcre =      xText:NODE-VALUE  WHEN xField:NAME = "indebcre".
                ASSIGN tt-saldo-rdca.vllanmto = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
                ASSIGN tt-saldo-rdca.sldresga = DEC (xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                ASSIGN tt-saldo-rdca.cddresga =      xText:NODE-VALUE  WHEN xField:NAME = "cddresga".
                ASSIGN tt-saldo-rdca.txaplmax =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmax".
                ASSIGN tt-saldo-rdca.txaplmin =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmin".
                ASSIGN tt-saldo-rdca.dshistor =      xText:NODE-VALUE  WHEN xField:NAME = "dshistor".
                ASSIGN tt-saldo-rdca.dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
                ASSIGN tt-saldo-rdca.idtipapl =      xText:NODE-VALUE  WHEN xField:NAME = "idtipapl".
                ASSIGN tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                ASSIGN tt-saldo-rdca.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto" AND xText:NODE-VALUE <> "01/01/1900".
                ASSIGN tt-saldo-rdca.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
                ASSIGN tt-saldo-rdca.cdprodut = INT (xText:NODE-VALUE) WHEN xField:NAME = "cdprodut".

            END.
        END.
        SET-SIZE(ponteiro_xml) = 0.
    END.

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xRoot2.
DELETE OBJECT xField.
DELETE OBJECT xText.

FOR EACH tt-saldo-rdca NO-LOCK:
  ASSIGN aux_vlsdrdca = aux_vlsdrdca + tt-saldo-rdca.sldresga.
END.

RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT
    SET h-b1wgen0006.

IF  VALID-HANDLE(h-b1wgen0006)  THEN
    DO:
        /* Busca saldo da poupanca programada */
        RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                               INPUT 90,
                                               INPUT 900,
                                               INPUT "996",
                                               INPUT "InternetBank",
                                               INPUT 3,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT 0,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT par_inproces,
                                               INPUT "InternetBank",
                                               INPUT FALSE,
                                              OUTPUT aux_vltotrpp,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-dados-rpp).

        DELETE PROCEDURE h-b1wgen0006.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os saldos.".

                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.
    END.

RUN sistema/generico/procedures/b1wgen0020.p PERSISTENT SET h-b1wgen0020.

IF  VALID-HANDLE(h-b1wgen0020)  THEN
    DO:
        /* Saldo Conta Investimento */
        RUN obtem-saldo-investimento IN h-b1wgen0020
                                           (INPUT par_cdcooper,
                                            INPUT 90,
                                            INPUT 900,
                                            INPUT "996",
                                            INPUT "InternetBank",
                                            INPUT 3,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_dtmvtolt,
                                           OUTPUT TABLE tt-saldo-investimento).

        DELETE PROCEDURE h-b1wgen0020.

        FIND tt-saldo-investimento NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-saldo-investimento  THEN
            ASSIGN aux_sdctainv = tt-saldo-investimento.vlsldinv.
    END.

RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
    SET h-b1wgen0021.

IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DO:
        /* Saldo de Cotas/Capital */
        RUN obtem-saldo-cotas IN h-b1wgen0021 (INPUT par_cdcooper,
                                               INPUT 90,
                                               INPUT 900,
                                               INPUT "996",
                                               INPUT "InternetBank",
                                               INPUT 3,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                              OUTPUT TABLE tt-saldo-cotas,
                                              OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0021.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os saldos.".

                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.

        FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-saldo-cotas THEN
            ASSIGN aux_vldcotas = tt-saldo-cotas.vlsldcap.
    END.

RUN sistema/generico/procedures/b1wgen0023.p PERSISTENT
    SET h-b1wgen0023.

IF  VALID-HANDLE(h-b1wgen0023)  THEN
    DO:
        /* Valida se limites de crédito*/
        RUN valida_limites_credito IN h-b1wgen0023 (INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_flglimcr).

        DELETE PROCEDURE h-b1wgen0023.
    END.

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        RUN busca_total_descontos IN h-b1wgen0030
                                    (INPUT par_cdcooper,
                                     INPUT 90,
                                     INPUT 900,
                                     INPUT "996",
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT 3,
                                     INPUT "InternetBank",
                                     INPUT FALSE, /** LOG **/
                                    OUTPUT TABLE tt-tot_descontos).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0030.

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os saldos.".

                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.

        FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

        IF  AVAIL tt-tot_descontos  THEN
            ASSIGN aux_vllimchq = tt-tot_descontos.vllimchq
                   aux_vldscchq = tt-tot_descontos.vldscchq
                   aux_vllimtit = tt-tot_descontos.vllimtit
                   aux_vldsctit = tt-tot_descontos.vldsctit.

        DELETE PROCEDURE h-b1wgen0030.
    END.

ASSIGN aux_flsenlet = FALSE.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.

IF  VALID-HANDLE(h-b1wgen0032)  THEN
    DO:
        RUN verifica-letras-seguranca IN h-b1wgen0032 (INPUT par_cdcooper,
                                                       INPUT par_nrdconta,
                                                       INPUT par_idseqttl,
                                                      OUTPUT aux_flsenlet).

        DELETE PROCEDURE h-b1wgen0032.
    END.

IF  par_indlogin <> 0  THEN
    DO:
        RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT
            SET h-b1wnet0002.

        IF  VALID-HANDLE(h-b1wnet0002)  THEN
            DO:

                RUN permissoes-menu IN h-b1wnet0002
                                    (INPUT par_cdcooper,
                                     INPUT 90,
                                     INPUT 900,
                                     INPUT "996",
                                     INPUT "InternetBank",
                                     INPUT 3,
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT par_nrcpfope,
                                     INPUT "",
                                     INPUT FALSE,
                                     INPUT TRUE,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-itens-menu).

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        DELETE PROCEDURE h-b1wnet0002.

                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAILABLE tt-erro  THEN
                            aux_dscritic = tt-erro.dscritic.
                        ELSE
                            aux_dscritic = "Nao foi possivel carregar os " +
                                           "saldos.".

                        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                       "</dsmsgerr>".

                        RETURN "NOK".
                    END.

                RUN verifica-acesso IN h-b1wnet0002
                                               (INPUT par_cdcooper,
                                                INPUT 90,
                                                INPUT 900,
                                                INPUT "996",
                                                INPUT "InternetBank",
                                                INPUT 3,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT par_nrcpfope,
                                                INPUT par_nripuser,
                                                INPUT par_dsorigip,
                                                INPUT IF  par_indlogin = 1  THEN
                                                          TRUE
                                                      ELSE
                                                          FALSE,
                                                INPUT par_flmobile,
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT TABLE tt-acesso).

                DELETE PROCEDURE h-b1wnet0002.

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAILABLE tt-erro  THEN
                            aux_dscritic = tt-erro.dscritic.
                        ELSE
                            aux_dscritic = "Nao foi possivel carregar os " +
                                           "saldos.".

                        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                       "</dsmsgerr>".

                        IF  par_indlogin = 2  THEN
                            RUN proc_geracao_log (INPUT FALSE).

                        RETURN "NOK".
                    END.

                FIND FIRST tt-itens-menu WHERE tt-itens-menu.cdsubitm = 0
                                               NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-itens-menu  THEN
                    DO:
                        ASSIGN aux_cditemmn = tt-itens-menu.cditemmn
                               aux_dsurlace = tt-itens-menu.dsurlace.

                        FIND FIRST tt-itens-menu WHERE
                                   tt-itens-menu.cditemmn = aux_cditemmn AND
                                   tt-itens-menu.cdsubitm > 0
                                   NO-LOCK NO-ERROR.

                        IF  AVAILABLE tt-itens-menu  THEN
                            ASSIGN aux_dsurlace = tt-itens-menu.dsurlace.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Operador sem permissoes de " +
                                              "acesso."
                               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                              "</dsmsgerr>".

                        RUN proc_geracao_log (INPUT FALSE).

                        RETURN "NOK".
                    END.

                FIND FIRST tt-acesso NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-acesso  THEN
                    ASSIGN aux_dtaltsnh = IF  tt-acesso.dtaltsnh <> ?  THEN
                                              STRING(tt-acesso.dtaltsnh,
                                                     "99/99/9999")
                                          ELSE
                                              ""
                           aux_flgsenha = STRING(tt-acesso.flgsenha)
                           aux_dtultace = IF  tt-acesso.dtultace <> ?  THEN
                                              STRING(tt-acesso.dtultace,
                                                     "99/99/9999")
                                          ELSE
                                              ""
                           aux_hrultace = STRING(tt-acesso.hrultace,"HH:MM:SS")
                           aux_cdblqsnh = tt-acesso.cdblqsnh
                           aux_qtdiams1 = tt-acesso.qtdiams1
                           aux_qtdiams2 = tt-acesso.qtdiams2.
            END.
    END.

/* Verifica se cooperado eh beneficiario do INSS */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE {&sc2_dboraayl}.send-sql-statement
                   aux_ponteiro = PROC-HANDLE
                   ("SELECT DISTINCT 1 FROM tbinss_dcb dcb " +
                                      "WHERE dcb.cdcooper = " + STRING(par_cdcooper) +
                                      "  AND dcb.nrdconta = " + STRING(par_nrdconta)).

FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
   ASSIGN aux_flgbinss = INT(proc-text).
END.

CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
   WHERE PROC-HANDLE = aux_ponteiro.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


/* verificacao para banner prova de vida
   Cooperativas:
   Viacredi; Concredi; Credcrea e Viacredi Alto Vale,
   Acredicoop; Credicomin; Credifiesc; Credifoz e Transpocred. */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE {&sc2_dboraayl}.send-sql-statement
                   aux_ponteiro = PROC-HANDLE
                   ("SELECT inss0001.fn_verifica_renovacao_vida(" + STRING(par_cdcooper) + /* Cooperativa */
                                                                      ",to_date('" + STRING(par_dtmvtolt) + "', 'DD/MM/RRRR')" + /* Data de movimento */
                                                                      "," + STRING(par_nrdconta) + /* Nr. da Conta */
                                                                      ",0" +                        /* Nr. Rec. Ben */
                                                                      ") FROM dual").

FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
   ASSIGN aux_flgpvida = INT(proc-text).
END.

CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
   WHERE PROC-HANDLE = aux_ponteiro.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_verifica_conta_capital
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_verifica_conta_capital
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

ASSIGN aux_flgconsu = 0
       aux_vltotsob = 0
       aux_vlliqjur = 0
       /*aux_cdcritic = 0
       aux_dscritic = ""*/
       aux_flgconsu = pc_verifica_conta_capital.pr_flgconsu
                      WHEN pc_verifica_conta_capital.pr_flgconsu <> ?
       aux_vltotsob = pc_verifica_conta_capital.pr_vltotsob
                      WHEN pc_verifica_conta_capital.pr_vltotsob <> ?
       aux_vlliqjur = pc_verifica_conta_capital.pr_vlliqjur
                      WHEN pc_verifica_conta_capital.pr_vlliqjur <> ?
       /*aux_cdcritic = pc_verifica_conta_capital.pr_cdcritic
                      WHEN pc_verifica_conta_capital.pr_cdcritic <> ?
       aux_dscritic = pc_verifica_conta_capital.pr_dscritic
                      WHEN pc_verifica_conta_capital.pr_dscritic <> ?*/ .

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

/* Retornar valor de crédito de juros sobre o capital */
ASSIGN aux_vljurcap = 0.
IF  CAN-DO("1,2,6,7,8,9,10,11,12,16",STRING(par_cdcooper))  AND
    par_dtmvtolt >= 01/05/2016                              AND
    par_dtmvtolt <= 02/05/2016                              THEN DO:
    FOR FIRST craplct WHERE craplct.cdcooper = par_cdcooper AND
                            craplct.nrdconta = par_nrdconta AND
                            craplct.cdhistor = 926          AND
                            craplct.dtmvtolt >= DATE(01,01,YEAR(par_dtmvtolt))
                            NO-LOCK. END.
    IF  AVAIL craplct  THEN
        ASSIGN aux_vljurcap = craplct.vllanmto.
END.


/* M172 - Atualizacao Tefefone - SO FAZ SE FOR Pessoa Fisica */
IF  aux_inpessoa = 1 THEN DO:

    /** VERIFICACAO DA ATUALIZACAO TELEFONE **/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }


    RUN STORED-PROCEDURE pc_ib_verif_atualiz_fone
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT aux_inpessoa,
                          INPUT par_idseqttl,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_ib_verif_atualiz_fone
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_ib_verif_atualiz_fone.pr_cdcritic
                          WHEN pc_ib_verif_atualiz_fone.pr_cdcritic <> ?
           aux_dscritic = pc_ib_verif_atualiz_fone.pr_dscritic
                          WHEN pc_ib_verif_atualiz_fone.pr_dscritic <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    /** VERIFICACAO DA ATUALIZACAO TELEFONE **/
END.


CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<CORRENTISTA><nmextttl>" +
                               aux_nmextttl +
                               "</nmextttl><nrdconta>" +
                               TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) +
                               "</nrdconta><dtmvtocd>" +
                               STRING(par_dtmvtocd,"99/99/9999") +
                               "</dtmvtocd><nmmesant>" +
                               aux_nmmesant +
                               "</nmmesant><nmmesatu>" +
                               aux_nmmesatu +
                               "</nmmesatu><vllimcre>" +
                          TRIM(STRING(crapass.vllimcre,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllimcre><vldcotas>" +
                              TRIM(STRING(aux_vldcotas,"zzz,zzz,zzz,zz9.99-")) +
                               "</vldcotas><vlsddisp>" +
                              TRIM(STRING(aux_vlsddisp,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlsddisp><vlsdbloq>" +
                              TRIM(STRING(aux_vlsdbloq,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlsdbloq><vlsdtotl>" +
                              TRIM(STRING(aux_vlstotal,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlsdtotl><nrctainv>" +
                              TRIM(STRING(crapass.nrctainv,"zz,zzz,zzz,9")) +
                               "</nrctainv><sdctainv>" +
                              TRIM(STRING(aux_sdctainv,"zzz,zzz,zzz,zz9.99-")) +
                               "</sdctainv><vllimchq>" +
                              TRIM(STRING(aux_vllimchq,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllimchq><vldscchq>" +
                              TRIM(STRING(aux_vldscchq,"zzz,zzz,zzz,zz9.99-")) +
                               "</vldscchq><nrdctitg>" +
                               TRIM(STRING(crapass.nrdctitg,"9.999.999-X")) +
                               "</nrdctitg><vlsdeved>" +
                              TRIM(STRING(aux_vlsdeved,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlsdeved><vllautom>" +
                              TRIM(STRING(aux_vllautom,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllautom><vlsdrdca>" +
                              TRIM(STRING(aux_vlsdrdca,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlsdrdca><vltotrpp>" +
                              TRIM(STRING(aux_vltotrpp,"zzz,zzz,zzz,zz9.99-")) +
                               "</vltotrpp><cdagenci>" +
                               STRING(crapass.cdagenci,"999") +
                               "</cdagenci><dtaltsnh>" +
                               aux_dtaltsnh +
                               "</dtaltsnh><dtultace>" +
                               aux_dtultace +
                               "</dtultace><hrultace>" +
                               aux_hrultace +
                               "</hrultace><inpessoa>" +
                               STRING(aux_inpessoa,"9") +
                               "</inpessoa><flgctitg>" +
                               STRING(crapass.flgctitg,"9") +
                               "</flgctitg><indholer>" +
                               STRING(aux_indholer) +
                               "</indholer><indinfor>" +
                               STRING(aux_indinfor) +
                               "</indinfor><vlsldrdc>" +
                              TRIM(STRING(aux_vlsldrdc,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlsldrdc><indpagto>" +
                               STRING(aux_indpagto) +
                               "</indpagto><indconve>" +
                               STRING(aux_indconve) +
                               "</indconve><vllaudeb>" +
                              TRIM(STRING(aux_vllaudeb,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllaudeb><vllaucre>" +
                              TRIM(STRING(aux_vllaucre,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllaucre><vllimtit>" +
                              TRIM(STRING(aux_vllimtit,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllimtit><vldsctit>" +
                              TRIM(STRING(aux_vldsctit,"zzz,zzz,zzz,zz9.99-")) +
                               "</vldsctit><nmoperad>" +
                               aux_nmoperad +
                               "</nmoperad><dsurlace>" +
                               aux_dsurlace +
                               "</dsurlace><flgsenha>" +
                               aux_flgsenha +
                               "</flgsenha><datdodia>" +
                               STRING(aux_datdodia,"99/99/9999") +
                               "</datdodia><flgcrbrd>" +
                               STRING(aux_flgcrbrd) +
                               "</flgcrbrd><nrctanov>" +
                               STRING(aux_nrctanov) +
                               "</nrctanov><flgsamae>" +
                               STRING(aux_flgsamae) +
                               "</flgsamae><nmprepos>" +
                               aux_nmprepos +
                               "</nmprepos><nrcpfpre>" +
                               STRING(aux_nrcpfpre) +
                               "</nrcpfpre><dtmvtoan>" +
                               STRING(par_dtmvtoan,"99/99/9999") +
                               "</dtmvtoan><cdagedbb>" +
                               aux_cdagedbb +
                               "</cdagedbb><cdbcoctl>" +
                               aux_cdbcoctl +
                               "</cdbcoctl><cdagectl>" +
                               aux_cdagectl +
                               "</cdagectl><flsenlet>" +
                               STRING(aux_flsenlet,"SIM/NAO") +
                               "</flsenlet><flgpvida>" +
                               STRING(aux_flgpvida) +
                               "</flgpvida><dtdemiss>" +
                               (IF crapass.dtdemiss = ?
                                THEN " "
                                ELSE STRING(crapass.dtdemiss,"99/99/9999")) +
                               "</dtdemiss><cdblqsnh>" +
                               STRING(aux_cdblqsnh) +
                               "</cdblqsnh><qtdiams1>" +
                               STRING(aux_qtdiams1) +
                               "</qtdiams1><qtdiams2>" +
                               STRING(aux_qtdiams2) +
                               "</qtdiams2><cdagemig>" +
                               STRING(aux_cdagemig) +
                               "</cdagemig><nrctaant>" +
                               STRING(aux_nrctaant) +
                               "</nrctaant><cdcopant>" +
                               STRING(aux_cdcopant) +
                               "</cdcopant><vlreccap>" +
                              TRIM(STRING(aux_vlreccap,"zzz,zzz,zzz,zz9.99-")) +
                               "</vlreccap><vllicret>" +
                              TRIM(STRING(aux_vllicret,"zzz,zzz,zzz,zz9.99-")) +
                               "</vllicret><vltotren>" +
                              TRIM(STRING(aux_vltotren,"zzz,zzz,zzz,zz9.99-")) +
                                "</vltotren><vldiscrd>" +
                              TRIM(STRING(aux_vldiscrd,"zzz,zzz,zzz,zz9.99-")) +
                                "</vldiscrd><flglimcr>" + STRING(aux_flglimcr) +
                               "</flglimcr><flgconsu>" +
                               STRING(aux_flgconsu) +
                               "</flgconsu><vltotsob>" +
                               STRING(aux_vltotsob, "zzz,zzz,zzz,zz9.99") +
                               "</vltotsob><vlliqjur>" +
                               STRING(aux_vlliqjur, "zzz,zzz,zzz,zz9.99") +
                               "</vlliqjur><vljurcap>" +
                               TRIM(STRING(aux_vljurcap,"zzz,zzz,zzz,zz9.99-")) +
                               "</vljurcap><flgbinss>" +
                               STRING(aux_flgbinss) +
                               "</flgbinss><nmtitula>" + aux_nmtitula + "</nmtitula></CORRENTISTA>".

RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT
        SET h-b1wgen0014.

    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "InternetBank",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).

            RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Origem",
                           INPUT "",
                           INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).

            DELETE PROCEDURE h-b1wgen0014.
        END.

END PROCEDURE.

/*............................................................................*/


