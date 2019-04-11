/*--------------------------------------------------------------------------*/
/*  b1crap71.p - Estornos - Depositos com Captura                           */
/*--------------------------------------------------------------------------*/

/* Alteracoes: 07/11/2005 - Alteracao dos buffers crabchq e crabchs p/ crapfdc
                            (SQLWorks - Eder).

               20/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)

               02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).

               26/02/2007 - Alteracao dos FINDs da crapfdc (Evandro).
                          - Limpeza dos campos "crapfdc.cdbandep",
                            "crapfdc.cdagedep" e "crapfdc.nrctadep"

               09/10/2009 - Adaptacoes projeto IF CECRED
                          - Adaptacoes projeto CAF (Guilherme).

               25/03/2010 - Verificacao horario corte apenas para cheques
                            fora cooperativa (Guilherme).

               17/06/2010 - Remoção da conferência da agência 95 (Vitor).

               01/11/2010 - Chama rotina atualiza-previa-caixa e verifica se
                            PAC faz previa dos cheques (Elton).

               27/05/2011 - Enviar email para controle de movimentacao
                           (Gabriel)

               04/01/2012 - Tratamento para cheques de contas migradas
                            (Guilherme).
                          - Chama rotina atualiza-previa-caixa somente para
                            cheques de fora (Elton).

               09/05/2012 - Inclusão da chamada da procedure autentica_cheques
                            da b1crap51. (David Kruger).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               20/06/2012 - substituição do FIND craptab para os registros
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.).

               17/10/2012 - Alteracao da logica para migracao de PAC
                            devido a migracao da AltoVale (Guilherme).

               03/01/2014 - Incluido validate para tabela crapmdw (Tiago).

               19/02/2014 - Ajuste leitura craptco (Daniel).

               09/09/2014 - #198254 Incorporacao concredi e credimilsul
                            (Carlos)

               19/05/2015 - Aumento do campo de Nr.Docmto (Lunelli SD 285059)

               18/11/2016 - Ajuste realizado para corrigir problema que nao
                            permitia estornar lancamentos de cheques, conforme
                            solicitado no chamado 525940. (Kelvin)

               06/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

               16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                            modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).

               15/06/2018 - Alterado para considerar o campo crapdat.dtmvtocd 
                           como data de referencia - Everton Deserto(AMCOM).                 

               15/10/2018 - Troca DELETE CRAPLCM pela chamada da rotina estorna_lancamento_conta 
                            de dentro da b1wgen0200 
                            (Renato AMcom)
                            
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
                              
........................................................................... **/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF  VAR glb_nrcalcul         AS DECIMAL                           NO-UNDO.
DEF  VAR glb_dsdctitg         AS CHAR                              NO-UNDO.
DEF  VAR glb_stsnrcal         AS LOGICAL                           NO-UNDO.

DEFINE VARIABLE i-cod-erro    AS INT                               NO-UNDO.
DEFINE VARIABLE c-desc-erro   AS CHAR                              NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                       NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.

DEF VAR i-nro-lote            AS INTE                              NO-UNDO.
DEF VAR aux_nrdconta          AS INTE                              NO-UNDO.
DEF VAR i_conta               AS DEC                               NO-UNDO.
DEF VAR aux_nrtrfcta LIKE  craptrf.nrsconta                        NO-UNDO.
DEF VAR l-achou               AS LOG                               NO-UNDO.
DEF VAR l-achou-migrado       AS LOG                               NO-UNDO.
DEF VAR l-achou-horario-corte AS LOG                               NO-UNDO.

DEF VAR h_b1crap00            AS HANDLE                            NO-UNDO.
DEF VAR h_b2crap00            AS HANDLE                            NO-UNDO.

DEF VAR aux_contador          AS INTE                              NO-UNDO.
DEF VAR dt-menor-fpraca       AS DATE                              NO-UNDO.
DEF VAR dt-maior-praca        AS DATE                              NO-UNDO.
DEF VAR dt-menor-praca        AS DATE                              NO-UNDO.
DEF VAR dt-maior-fpraca       AS DATE                              NO-UNDO.
DEF VAR c-docto               AS CHAR                              NO-UNDO.
DEF VAR c-docto-salvo         AS CHAR                              NO-UNDO.
DEF VAR i-docto               AS INTE                              NO-UNDO.

DEF VAR aux_lsconta1          AS CHAR                              NO-UNDO.
DEF VAR aux_lsconta2          AS CHAR                              NO-UNDO.
DEF VAR aux_lsconta3          AS CHAR                              NO-UNDO.
DEF VAR aux_lscontas          AS CHAR                              NO-UNDO.

DEF VAR i_nro-docto           AS INTE                              NO-UNDO.
DEF VAR i_nro-talao           AS INTE                              NO-UNDO.
DEF VAR i_posicao             AS INTE                              NO-UNDO.
DEF VAR i_nro-folhas          AS INTE                              NO-UNDO.

DEF BUFFER crabfdc FOR crapfdc.
DEF BUFFER crablcm FOR craplcm.
DEF BUFFER crabbcx FOR crapbcx.

DEF VAR in99                  AS INTE NO-UNDO.

DEF  VAR aux_ctpsqitg         AS DEC                               NO-UNDO.
DEF  VAR aux_nrdctitg LIKE crapass.nrdctitg                        NO-UNDO.
DEF  VAR aux_nrctaass LIKE crapass.nrdconta                        NO-UNDO.

DEF  VAR flg_exetrunc         AS LOG                               NO-UNDO.

DEF VAR h-b1wgen0200 AS HANDLE                                     NO-UNDO.

/**   Conta Integracao **/
DEF  BUFFER crabass5 FOR crapass.
DEF  VAR aux_nrdigitg         AS CHAR                              NO-UNDO.
DEF  VAR glb_cdcooper         AS INT                               NO-UNDO.
{includes/proc_conta_integracao.i}

DEFINE TEMP-TABLE tt-lancamentos NO-UNDO
    FIELD tpdocmto AS INTE
    FIELD dtmvtolt AS DATE
    FIELD vllanmto AS DECI
    INDEX tt-lancamentos1 tpdocmto dtmvtolt.

PROCEDURE valida-cheque-com-captura:

    DEF INPUT  PARAM p-cooper            AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INT NO-UNDO. /* Cod. Agencia     */
    DEF INPUT  PARAM p-nro-caixa         AS INT NO-UNDO. /* Nro Caixa     */
    DEF INPUT  PARAM p-nro-conta         AS INT NO-UNDO. /* Nro Conta        */
    DEF INPUT  PARAM p-nrdocto           AS DEC NO-UNDO.
    DEF OUTPUT PARAM p-dsidenti          AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-nome-titular      AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-poupanca          AS LOG NO-UNDO.
    DEF OUTPUT PARAM p-valor-dinheiro    AS DEC NO-UNDO.
    DEF OUTPUT PARAM p-valor-cooperativa AS DEC NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    DEF VAR aux_cdmodali AS INTE                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                    NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    DEF VAR aux_dtlibera AS DATE NO-UNDO.

    EMPTY TEMP-TABLE tt-lancamentos.

    ASSIGN p-poupanca           = NO
           p-nome-titular       = " "
           p-valor-dinheiro     = 0
           p-valor-cooperativa  = 0.

    ASSIGN l-achou-horario-corte = NO.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nrdocto = 0   THEN
         DO:
             ASSIGN i-cod-erro  = 22
                    c-desc-erro = " ".  /* Documento deve ser Informado */
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    IF   p-nro-conta = 0   THEN
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Conta deve ser Informada".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */

    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 0,
                           OUTPUT aux_lscontas).

    IF   NOT CAN-DO(aux_lscontas,STRING(p-nro-conta))  THEN
         DO:

              FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                 crapass.nrdconta = p-nro-conta
                                 NO-LOCK NO-ERROR.

              IF   NOT AVAIL crapass   THEN
                   DO:
                       ASSIGN i-cod-erro  = 9
                              c-desc-erro = " ".
                       RUN cria-erro (INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT i-cod-erro,
                                      INPUT c-desc-erro,
                                      INPUT YES).
                      RETURN "NOK".
                  END.

              ASSIGN p-nome-titular = crapass.nmprimtl.

              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              RUN STORED-PROCEDURE pc_busca_modalidade_tipo
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                   INPUT crapass.cdtipcta, /* Tipo de conta */
                                                  OUTPUT 0,                /* Modalidade */
                                                  OUTPUT "",               /* Flag Erro */
                                                  OUTPUT "").              /* Descriçao da crítica */

              CLOSE STORED-PROC pc_busca_modalidade_tipo
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_cdmodali = 0
                     aux_des_erro = ""
                     aux_dscritic = ""
                     aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                    WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                     aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                    WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                     aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                    WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
              
              IF aux_des_erro = "NOK"  THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = aux_dscritic.
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
              
              IF   aux_cdmodali = 3 THEN /* Conta tipo Poupan‡a */
                   ASSIGN p-poupanca = YES.
         END.

    ASSIGN l-achou = NO.

    ASSIGN c-docto = STRING(p-nrdocto) + "011".

    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                             craplcm.cdagenci = p-cod-agencia     AND
                             craplcm.cdbccxlt = 11                AND /* Fixo */
                             craplcm.nrdolote = i-nro-lote        AND
                             craplcm.nrdctabb = p-nro-conta       AND
                             craplcm.nrdocmto = DECI(c-docto)
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.

    IF   AVAIL craplcm  AND
         ENTRY(1, craplcm.cdpesqbb) = "CRAP51"   THEN
         ASSIGN p-dsidenti = craplcm.dsidenti
                l-achou = YES
                p-valor-dinheiro = craplcm.vllanmto.

    ASSIGN c-docto = STRING(p-nrdocto) + "012".

    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd  AND /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                             craplcm.cdagenci = p-cod-agencia     AND
                             craplcm.cdbccxlt = 11                AND /* Fixo */
                             craplcm.nrdolote = i-nro-lote        AND
                             craplcm.nrdctabb = p-nro-conta       AND
                             craplcm.nrdocmto = DECI(c-docto)
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.

    IF   AVAIL craplcm  AND
         ENTRY(1, craplcm.cdpesqbb) = "CRAP51"   THEN
         ASSIGN p-dsidenti = craplcm.dsidenti
                l-achou = YES
                p-valor-cooperativa = craplcm.vllanmto.

    ASSIGN c-docto = STRING(p-nrdocto).

    FOR EACH craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                           craplcm.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                           craplcm.cdagenci = p-cod-agencia     AND
                           craplcm.cdbccxlt = 11                AND /* Fixo */
                           craplcm.nrdolote = i-nro-lote        AND
                           craplcm.nrdctabb = p-nro-conta
                           USE-INDEX craplcm1 NO-LOCK:

        /* Garantir que somente serao pegos os lancamentos corretos */
        IF  STRING(craplcm.nrdocmto) BEGINS c-docto   AND
            /* Chq Cooperativa = 2 */
            CAN-DO("2,3,4,5,6",SUBSTR(STRING(craplcm.nrdocmto),
                                  LENGTH(STRING(craplcm.nrdocmto)),1)) AND
            ENTRY(1, craplcm.cdpesqbb) = "CRAP51"     THEN
            DO:
                /* Chq prc. chq maior prc, chq fora prc, chq maior fora prc */
                IF CAN-DO("3,4,5,6",SUBSTR(STRING(craplcm.nrdocmto),
                                      LENGTH(STRING(craplcm.nrdocmto)),1)) THEN
                DO:
                    ASSIGN p-dsidenti = craplcm.dsidenti
                           l-achou-horario-corte  = YES
                           l-achou = YES.

                    FIND FIRST crapdpb WHERE crapdpb.cdcooper = crapcop.cdcooper  AND
                                             crapdpb.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                             crapdpb.cdagenci = p-cod-agencia     AND
                                             crapdpb.cdbccxlt = 11    /* Fixo */  AND
                                             crapdpb.nrdolote = i-nro-lote        AND
                                             crapdpb.nrdconta = p-nro-conta       AND
                                             crapdpb.nrdocmto = craplcm.nrdocmto
                                             NO-LOCK NO-ERROR.
                    IF   NOT AVAIL crapdpb   THEN
                         DO:
                             ASSIGN i-cod-erro  = 82
                                    c-desc-erro = " ".
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                         END.

                    IF   crapdpb.inlibera = 2   THEN
                         DO:
                             ASSIGN i-cod-erro  = 220
                                    c-desc-erro = " ".
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                         END.

                    CREATE tt-lancamentos.
                    ASSIGN tt-lancamentos.tpdocmto =
                           INT(SUBSTR(STRING(craplcm.nrdocmto),
                                      LENGTH(STRING(craplcm.nrdocmto)),1))
                           tt-lancamentos.dtmvtolt = crapdpb.dtliblan
                           tt-lancamentos.vllanmto = craplcm.vllanmto.

                END.
                /*** Verifica se PAC faz previa dos cheques ***/
                ASSIGN  flg_exetrunc = FALSE.
                FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                                    craptab.nmsistem = "CRED"             AND
                                    craptab.tptabela = "GENERI"           AND
                                    craptab.cdempres = 0                  AND
                                    craptab.cdacesso = "EXETRUNCAGEM"     AND
                                    craptab.tpregist = p-cod-agencia
                                    NO-LOCK NO-ERROR.

                IF   craptab.dstextab = "SIM" THEN
                DO:
                   ASSIGN i-cod-erro   = 0
                          flg_exetrunc = TRUE.

                   FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper   AND
                                          crapchd.dtmvtolt = craplcm.dtmvtolt   AND
                                          crapchd.cdagenci = craplcm.cdagenci   AND
                                          crapchd.cdbccxlt = craplcm.cdbccxlt   AND
                                          crapchd.nrdolote = craplcm.nrdolote   AND
                                          crapchd.nrseqdig = craplcm.nrseqdig   AND
                                          crapchd.nrdconta = craplcm.nrdconta
                                          USE-INDEX crapchd3 NO-LOCK:
                       IF  crapchd.insitprv > 0 THEN DO:
                           ASSIGN i-cod-erro =  9999.
                       END.
                   END.

                   IF   i-cod-erro > 0 THEN
                        DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "Estorno nao pode ser efetuado. " +
                                                "Cheque ja enviado para previa.".
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                        END.
                END.
         END.
        /****************/
    END.

    IF   l-achou = NO   THEN
         DO:
             ASSIGN i-cod-erro  = 90
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    /* Revitalizacao - Remocao de lotes
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper      AND
                       craplot.dtmvtolt = crapdat.dtmvtocd      AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                       craplot.cdagenci = p-cod-agencia         AND
                       craplot.cdbccxlt = 11                    AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL   craplot   THEN
         DO:
             ASSIGN i-cod-erro  = 60
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    */

    IF   l-achou-horario-corte  = YES   THEN
         DO:
             /* Verifica horario de Corte */
             FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                                craptab.nmsistem = "CRED"             AND
                                craptab.tptabela = "GENERI"           AND
                                craptab.cdempres = 0                  AND
                                craptab.cdacesso = "HRTRCOMPEL"       AND
                                craptab.tpregist = p-cod-agencia
                                NO-LOCK NO-ERROR.

             IF   NOT AVAIL craptab   THEN
                  DO:
                      ASSIGN i-cod-erro  = 676
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             IF   flg_exetrunc = FALSE THEN
                  IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                       DO:
                           ASSIGN i-cod-erro  = 677
                                  c-desc-erro = " ".
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.

             IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                  DO:
                      ASSIGN i-cod-erro  = 676
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.    /* Verifica Horario de Corte */

    RETURN "OK".
END PROCEDURE.

PROCEDURE grava-cheque-cooperativa:

    DEF INPUT  PARAM p-cooper        AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INT NO-UNDO. /* Cod. Agencia       */
    DEF INPUT  PARAM p-nro-caixa     AS INT NO-UNDO. /* Numero Caixa       */
    DEF INPUT  PARAM p-nro-docto     AS DECI NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND FIRST crapmdw WHERE crapmdw.cdcooper  = crapcop.cdcooper  AND
                             crapmdw.cdagenci  = p-cod-agencia     AND
                             crapmdw.nrdcaixa  = p-nro-caixa       AND
                             DECI(SUBSTR(STRING(crapmdw.nrdocmto), 1,
                             LENGTH(STRING(crapmdw.nrdocmto)) - 3)) =
                                                p-nro-docto NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapmdw  THEN
        DO:
            FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                                   crapmdw.cdagenci = p-cod-agencia    AND
                                   crapmdw.nrdcaixa = p-nro-caixa
                                   EXCLUSIVE-LOCK:
                DELETE crapmdw.
            END.

            FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                                     NO-LOCK NO-ERROR.

            ASSIGN i-nro-lote = 11000 + p-nro-caixa.
            FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper   AND
                                   crapchd.dtmvtolt = crapdat.dtmvtocd   AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                   crapchd.cdagenci = p-cod-agencia      AND
                                   crapchd.cdbccxlt = 11                 AND
                                   crapchd.nrdolote = i-nro-lote         AND
                                   crapchd.inchqcop = 1
                                   USE-INDEX crapchd3 NO-LOCK:

                IF  DECI(SUBSTR(STRING(crapchd.nrdocmto), 1,
                               LENGTH(STRING(crapchd.nrdocmto)) - 3)) = p-nro-docto THEN
                    DO:

                        CREATE crapmdw.
                        ASSIGN crapmdw.cdagenci  = p-cod-agencia
                               crapmdw.nrdcaixa  = p-nro-caixa
                               crapmdw.nrctabdb  = crapchd.nrctachq
                               crapmdw.nrcheque  = crapchd.nrcheque
                               crapmdw.cdagechq  = crapchd.cdagechq
                               crapmdw.nrdocmto  = crapchd.nrdocmto
                               crapmdw.vlcompel  = crapchd.vlcheque
                               crapmdw.cdhistor  = 386
                               crapmdw.cdcooper  = crapcop.cdcooper
                               crapmdw.nrddigc3  = crapchd.nrddigc3.
                        VALIDATE crapmdw.
                    END.
            END.
        END.
    RETURN "OK".
END PROCEDURE.

PROCEDURE estorna-cheque-com-captura:

    DEF INPUT  PARAM p-cooper                AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia           AS INT NO-UNDO. /* Cod. Agencia  */
    DEF INPUT  PARAM p-nro-caixa             AS INT NO-UNDO. /* Numero Caixa  */
    DEF INPUT  PARAM p-cod-operador          AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-nro-conta             AS INT NO-UNDO. /* Nro Conta     */
    DEF INPUT  PARAM p-nrdocto               AS DEC NO-UNDO.
    DEF INPUT  PARAM p-valor-dinheiro        AS DEC NO-UNDO.
    DEF INPUT  PARAM p-valor-cooperativa     AS DEC NO-UNDO.
    DEF INPUT  PARAM p-vestorno              AS LOG NO-UNDO.
    DEF INPUT  PARAM p-nrdrowid              AS ROWID NO-UNDO.
    DEF OUTPUT PARAM p-valor                 AS DEC NO-UNDO.

    DEF BUFFER b-craplcm FOR craplcm.
    DEF VAR flg_vhrcorte AS LOGICAL NO-UNDO.
    DEF BUFFER crablot   FOR craplot.

    DEF VAR h-b1wgen9998 AS HANDLE NO-UNDO.
    DEF VAR h-b1crap51   AS HANDLE NO-UNDO.



    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */

    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 0,
                           OUTPUT aux_lscontas).

    /*  Le tabela com as contas convenio do Banco do Brasil - talao normal */

    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 1,
                           OUTPUT aux_lsconta1).

    /*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/

    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 2,
                           OUTPUT aux_lsconta2).

   /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */

    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 3,
                           OUTPUT aux_lsconta3).

    ASSIGN flg_vhrcorte = FALSE.

    /* Verifica se ha lancamento de cheques fora coop,
       se sim faz a validacao do horario de corte */
    FOR EACH craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                           craplcm.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                           craplcm.cdagenci = p-cod-agencia     AND
                           craplcm.cdbccxlt = 11                AND /* Fixo */
                           craplcm.nrdolote = i-nro-lote        AND
                           craplcm.nrdctabb = p-nro-conta
                           USE-INDEX craplcm1 NO-LOCK:

        /* Garantir que somente serao pegos os lancamentos corretos */
        IF  STRING(craplcm.nrdocmto) BEGINS c-docto   AND

            CAN-DO("2,3,4,5,6",SUBSTR(STRING(craplcm.nrdocmto),
                                    LENGTH(STRING(craplcm.nrdocmto)),1)) AND
            ENTRY(1, craplcm.cdpesqbb) = "CRAP51"     THEN
            DO:
                /* Chq prc. chq maior prc, chq fora prc, chq maior fora prc */
                IF  CAN-DO("3,4,5,6",SUBSTR(STRING(craplcm.nrdocmto),
                                       LENGTH(STRING(craplcm.nrdocmto)),1))  THEN
                    ASSIGN flg_vhrcorte = TRUE.

                /*** Verifica se faz PAC faz previa dos cheques ***/
                ASSIGN flg_exetrunc = FALSE.
                FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                                    craptab.nmsistem = "CRED"             AND
                                    craptab.tptabela = "GENERI"           AND
                                    craptab.cdempres = 0                  AND
                                    craptab.cdacesso = "EXETRUNCAGEM"     AND
                                    craptab.tpregist = p-cod-agencia
                                    NO-LOCK NO-ERROR.

                IF   craptab.dstextab = "SIM" THEN
                     DO:
                        ASSIGN i-cod-erro   = 0
                               flg_exetrunc = TRUE.

                        FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper   AND
                                               crapchd.dtmvtolt = craplcm.dtmvtolt   AND
                                               crapchd.cdagenci = craplcm.cdagenci   AND
                                               crapchd.cdbccxlt = craplcm.cdbccxlt   AND
                                               crapchd.nrdolote = craplcm.nrdolote   AND
                                               crapchd.nrseqdig = craplcm.nrseqdig   AND
                                               crapchd.nrdconta = craplcm.nrdconta
                                               USE-INDEX crapchd3 NO-LOCK:

                            IF  crapchd.insitprv > 0 THEN DO:
                                ASSIGN i-cod-erro =  9999.
                            END.

                        END.

                        IF   i-cod-erro > 0 THEN
                             DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Estorno nao pode ser efetuado. " +
                                                     "Cheque ja enviado para previa.".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                             END.
                     END.
            END.

        /****************/
    END.

    IF  flg_vhrcorte  THEN
        DO: /* Verifica horario de Corte */

            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = 0                 AND
                               craptab.cdacesso = "HRTRCOMPEL"      AND
                               craptab.tpregist = p-cod-agencia
                               NO-LOCK NO-ERROR.

            IF   NOT AVAIL craptab   THEN
                 DO:
                     ASSIGN i-cod-erro  = 676
                            c-desc-erro = " ".
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.

            IF  flg_exetrunc = FALSE THEN
                IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                     DO:
                         ASSIGN i-cod-erro  = 677
                                c-desc-erro = " ".
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.

            IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                 DO:
                     ASSIGN i-cod-erro  = 676
                            c-desc-erro = " ".
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
        END. /* FIM Verifica Horario de Corte */

    ASSIGN in99 = 0.
    /* Revitalizacao - Remocao de lotes
    DO   WHILE TRUE:
         ASSIGN in99 = in99 + 1.

         FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                            craplot.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                            craplot.cdagenci = p-cod-agencia     AND
                            craplot.cdbccxlt = 11                AND  /* Fixo */
                            craplot.nrdolote = i-nro-lote
                            NO-ERROR NO-WAIT.

         IF   NOT AVAIL   craplot   THEN
              DO:
                  IF   LOCKED craplot   THEN
                       DO:
                           IF   in99 < 100   THEN
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                         c-desc-erro = "Tabela CRAPLOT em uso ".
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                       END.
                  ELSE
                       DO:
                           ASSIGN i-cod-erro  = 60
                                  c-desc-erro = " ".
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.
              END.
         LEAVE.
    END.*/
    /*  DO WHILE */

    IF   p-valor-dinheiro > 0   THEN
         DO:
             ASSIGN c-docto = STRING(p-nrdocto) + "011"
                    in99 = 0.
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.

                  FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                                     craplcm.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                     craplcm.cdagenci = p-cod-agencia     AND
                                     craplcm.cdbccxlt = 11    /*Fixo*/    AND
                                     craplcm.nrdolote = i-nro-lote        AND
                                     craplcm.nrdctabb = p-nro-conta       AND
                                     craplcm.nrdocmto = DECI(c-docto)
                                     USE-INDEX craplcm1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAIL craplcm   THEN
                       DO:
                           IF   LOCKED craplcm   THEN
                                DO:
                                    IF   in99 < 100   THEN
                                         DO:
                                             PAUSE 1 NO-MESSAGE.
                                             NEXT.
                                         END.
                                    ELSE
                                         DO:
                                             ASSIGN i-cod-erro  = 0
                                                    c-desc-erro =
                                                     "Tabela CRAPLCM em uso ".
                                             RUN cria-erro (INPUT p-cooper,
                                                            INPUT p-cod-agencia,
                                                            INPUT p-nro-caixa,
                                                            INPUT i-cod-erro,
                                                            INPUT c-desc-erro,
                                                            INPUT YES).
                                             RETURN "NOK".
                                         END.
                                END.
                           ELSE
                                DO:
                                    ASSIGN i-cod-erro  = 90
                                           c-desc-erro = " ".
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                     RETURN "NOK".
                                 END.
                       END.

                  /*** Controle de movimentacao em especie ***/

                  FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper   AND
                                     crapcme.dtmvtolt = craplcm.dtmvtolt   AND
                                     crapcme.cdagenci = craplcm.cdagenci   AND
                                     crapcme.cdbccxlt = craplcm.cdbccxlt   AND
                                     crapcme.nrdolote = craplcm.nrdolote   AND
                                     crapcme.nrdctabb = craplcm.nrdctabb   AND
                                     crapcme.nrdocmto = craplcm.nrdocmto
                                     EXCLUSIVE-LOCK NO-ERROR.

                  IF   AVAILABLE crapcme   THEN
                       DO:
                           RUN sistema/generico/procedures/b1wgen9998.p
                               PERSISTENT SET h-b1wgen9998.

                           RUN email-controle-movimentacao IN h-b1wgen9998
                                     (INPUT crapcop.cdcooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT p-cod-operador,
                                      INPUT "b1crap71",
                                      INPUT 2, /* Caixa online */
                                      INPUT crapcme.nrdconta,
                                      INPUT 1, /* Tit*/
                                      INPUT 3, /* Exclusao */
                                      INPUT ROWID(crapcme),
                                      INPUT TRUE, /* Envia */
                                      INPUT crapdat.dtmvtocd, /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                      INPUT TRUE,
                                     OUTPUT TABLE tt-erro).

                           DELETE PROCEDURE h-b1wgen9998.

                           IF   RETURN-VALUE <> "OK"   THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                    IF   AVAIL tt-erro   THEN
                                         IF   tt-erro.cdcritic <> 0   THEN
                                              ASSIGN i-cod-erro  = tt-erro.cdcritic.
                                         ELSE
                                              ASSIGN c-desc-erro = tt-erro.dscritic.
                                    ELSE
                                         ASSIGN c-desc-erro = "Erro no envio do email.".

                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.

                           DELETE crapcme.
                       END.

                  IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                     RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                          
                  RUN estorna_lancamento_conta IN h-b1wgen0200 
                    (INPUT craplcm.cdcooper               /* par_cdcooper */
                    ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
                    ,INPUT craplcm.cdagenci               /* par_cdagenci*/
                    ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
                    ,INPUT craplcm.nrdolote               /* par_nrdolote */
                    ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
                    ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
                    ,INPUT craplcm.cdhistor               /* par_cdhistor */
                    ,INPUT craplcm.nrctachq               /* PAR_nrctachq */
                    ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
                    ,INPUT craplcm.cdpesqbb               /* PAR_cdpesqbb */
                    ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                    ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                  IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                     DO: 
                         /* Tratamento de erros conforme anteriores */
                         ASSIGN i-cod-erro  = aux_cdcritic
                                c-desc-erro = aux_dscritic.
                                
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.   
                  
                  IF  VALID-HANDLE(h-b1wgen0200) THEN
                    DELETE PROCEDURE h-b1wgen0200.

                  LEAVE.
             END.  /*  DO WHILE */
             
             /* Revitalizacao - Remocao de lotes
             ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
                    craplot.qtinfoln  = craplot.qtinfoln - 1
                    craplot.vlcompcr  = craplot.vlcompcr - p-valor-dinheiro
                    craplot.vlinfocr  = craplot.vlinfocr - p-valor-dinheiro.
             */
         END.

    IF  p-valor-cooperativa > 0  THEN
        DO:
            ASSIGN c-docto = STRING(p-nrdocto) + "012"
                   in99 = 0.

            DO  WHILE TRUE:
                ASSIGN in99 = in99 + 1.

                FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                                   craplcm.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                   craplcm.cdagenci = p-cod-agencia     AND
                                   craplcm.cdbccxlt = 11   /*FIXO*/     AND
                                   craplcm.nrdolote = i-nro-lote        AND
                                   craplcm.nrdctabb = p-nro-conta       AND
                                   craplcm.nrdocmto = DECI(c-docto)
                                   USE-INDEX craplcm1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL craplcm   THEN
                DO:
                    IF   LOCKED craplcm   THEN
                    DO:
                        IF   in99 < 100  THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                        ELSE
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Tabela CRAPLCM em uso ".
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".

                        END.
                    END.
                    ELSE
                    DO:
                        ASSIGN i-cod-erro  = 90
                               c-desc-erro = " ".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
                END.

                ASSIGN i-cod-erro = 0.

                IF NOT VALID-HANDLE(h-b1crap51) THEN
                RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.

                RUN autentica_cheques IN h-b1crap51 (INPUT p-cooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-conta,
                                                     INPUT p-vestorno,
                                                     INPUT p-nro-caixa,
                                                     INPUT p-cod-operador,
                                                     INPUT ?,
                                                     INPUT crapdat.dtmvtocd, /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                     INPUT DECI(p-nrdocto)).
                IF VALID-HANDLE(h-b1crap51) THEN
                   DELETE OBJECT h-b1crap51.

                /* Nesta procedure está o tratamento de contas migradas */
                RUN verifica-crapchd-coop (INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT i-nro-lote).

                IF   i-cod-erro <> 0   THEN
                     DO:
                         ASSIGN c-desc-erro = "".
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.

                /* Revitalizacao - Remocao de lotes
                ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
                       craplot.qtinfoln  = craplot.qtinfoln - 1
                       craplot.vlcompcr  = craplot.vlcompcr - craplcm.vllanmto
                       craplot.vlinfocr  = craplot.vlinfocr - craplcm.vllanmto.
                */

                IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                   RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.

                RUN estorna_lancamento_conta IN h-b1wgen0200 
                  (INPUT craplcm.cdcooper               /* par_cdcooper */
                  ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
                  ,INPUT craplcm.cdagenci               /* par_cdagenci*/
                  ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
                  ,INPUT craplcm.nrdolote               /* par_nrdolote */
                  ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
                  ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
                  ,INPUT craplcm.cdhistor               /* par_cdhistor */
                  ,INPUT craplcm.nrctachq               /* PAR_nrctachq */
                  ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
                  ,INPUT craplcm.cdpesqbb               /* PAR_cdpesqbb */
                  ,OUTPUT aux_cdcritic                  /* Codigo da critica  */
                  ,OUTPUT aux_dscritic).                /* Descricao da critica */
                        
                IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                   DO: 
                       /* Tratamento de erros conforme anteriores */
                       ASSIGN i-cod-erro  = aux_cdcritic
                              c-desc-erro = aux_dscritic.
                                
                       RUN cria-erro (INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT i-cod-erro,
                                      INPUT c-desc-erro,
                                      INPUT YES).
                       RETURN "NOK".
                   END.   
                  
                IF  VALID-HANDLE(h-b1wgen0200) THEN
                  DELETE PROCEDURE h-b1wgen0200.

                LEAVE.
            END.  /*  DO WHILE */

        END.

    ASSIGN  p-valor    = p-valor-dinheiro +
                         p-valor-cooperativa.

    ASSIGN c-docto = STRING(p-nrdocto).

    FOR EACH craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                           craplcm.dtmvtolt = crapdat.dtmvtocd  AND /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                           craplcm.cdagenci = p-cod-agencia     AND
                           craplcm.cdbccxlt = 11                AND /* Fixo */
                           craplcm.nrdolote = i-nro-lote        AND
                           craplcm.nrdctabb = p-nro-conta
                           USE-INDEX craplcm1 NO-LOCK:

        /* Garantir que somente serao pegos os lancamentos corretos */
        IF  STRING(craplcm.nrdocmto) BEGINS c-docto   AND
            /* Chq prc. chq maior prc, chq fora prc, chq maior fora prc */
            CAN-DO("3,4,5,6",SUBSTR(STRING(craplcm.nrdocmto),
                                    LENGTH(STRING(craplcm.nrdocmto)),1)) AND
            ENTRY(1, craplcm.cdpesqbb) = "CRAP51"     THEN
            DO:
                /* Eliminar registro craplcm */
                DO  aux_contador = 1 TO 10:
                    FIND b-craplcm WHERE ROWID(b-craplcm) = ROWID(craplcm)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE b-craplcm  THEN
                        DO:
                            IF  LOCKED b-craplcm   THEN
                                DO:
                                    ASSIGN i-cod-erro = 341.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN i-cod-erro = 90.
                                    LEAVE.
                                END.
                        END.

                    ASSIGN  i-cod-erro = 0.

                    LEAVE.

                END. /* Fim do DO ... TO */

                IF  i-cod-erro > 0  THEN
                    DO:
                        ASSIGN c-desc-erro = "".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.

                ASSIGN i-cod-erro = 0.

                RUN verifica-crapchd (INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT p-cod-operador).

                IF  i-cod-erro <> 0  THEN
                    DO:
                        ASSIGN  c-desc-erro = " ".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
                                /* Eliminar registro deposito bloqueado - crapdpb */
                DO  aux_contador = 1 TO 10:
                    FIND FIRST crapdpb WHERE
                               crapdpb.cdcooper = crapcop.cdcooper  AND
                               crapdpb.dtmvtolt = crapdat.dtmvtocd  AND /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                               crapdpb.cdagenci = p-cod-agencia     AND
                               crapdpb.cdbccxlt = 11                AND
                               crapdpb.nrdolote = i-nro-lote        AND
                               crapdpb.nrdconta = p-nro-conta       AND
                               crapdpb.nrdocmto = craplcm.nrdocmto
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapdpb  THEN
                        DO:
                            IF  LOCKED crapdpb  THEN
                                DO:
                                    ASSIGN i-cod-erro = 341.
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN i-cod-erro = 82.
                                    LEAVE.
                                END.
                        END.

                    ASSIGN  i-cod-erro = 0.

                    LEAVE.

                END. /* Fim do DO ... TO */

                IF  i-cod-erro > 0  THEN
                    DO:
                        ASSIGN c-desc-erro = "".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.

                /* Revitalizacao - Remocao de lotes
                ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
                       craplot.qtinfoln  = craplot.qtinfoln - 1
                       craplot.vlcompcr  = craplot.vlcompcr - craplcm.vllanmto
                       craplot.vlinfocr  = craplot.vlinfocr - craplcm.vllanmto
                */

                ASSIGN p-valor = p-valor + craplcm.vllanmto.

                DELETE b-craplcm.
                DELETE crapdpb.

            END.
    END.

    /* Revitalizacao - Remocao de lotes
    IF  craplot.vlcompdb = 0  AND
        craplot.vlinfodb = 0  AND
        craplot.vlcompcr = 0  AND
        craplot.vlinfocr = 0  THEN
        DELETE craplot.
    ELSE
        RELEASE craplot.
    */

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-crapchd:

     DEF INPUT PARAM p-cod-agencia  AS INTE.
     DEF INPUT PARAM p-nro-caixa    AS INTE.
     DEF INPUT PARAM p-cod-operador AS CHAR.

     ASSIGN i-cod-erro = 0.

     FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper AND
                            crapchd.dtmvtolt = craplcm.dtmvtolt AND
                            crapchd.cdagenci = craplcm.cdagenci AND
                            crapchd.cdbccxlt = craplcm.cdbccxlt AND
                            crapchd.nrdolote = craplcm.nrdolote AND
                            crapchd.nrseqdig = craplcm.nrseqdig
                            USE-INDEX crapchd3 EXCLUSIVE-LOCK:

         /*  Formata conta integracao  */
         RUN fontes/digbbx.p (INPUT  crapchd.nrctachq,
                              OUTPUT glb_dsdctitg,
                              OUTPUT glb_stsnrcal).
         ASSIGN aux_nrdctitg = "".
         /**  Conta Integracao **/
         IF  LENGTH(STRING(crapchd.nrctachq)) <= 8   THEN
             DO:
                 ASSIGN aux_ctpsqitg = crapchd.nrctachq
                        glb_cdcooper = crapcop.cdcooper.
                 RUN existe_conta_integracao.
             END.

         IF   craplcm.cdhistor = 386   THEN
              DO:
                  ASSIGN i_nro-docto =  DECI(STRING(crapchd.nrcheque,"999999") +
                                            STRING(crapchd.nrddigc3,"9")).
                  IF   (crapchd.cdbanchq = 1 AND
                        crapchd.cdagechq = 3420) OR
                       (aux_nrdctitg <> "" AND
                        CAN-DO("3420", STRING(crapchd.cdagechq)))   THEN
                       DO:

                           IF   CAN-DO(aux_lsconta1,STRING(crapchd.nrctachq)) OR
                                aux_nrdctitg <> " "   THEN
                                DO:
                                    RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto,
                                                      INPUT-OUTPUT i_nro-talao,
                                                      INPUT-OUTPUT i_posicao,
                                                     INPUT-OUTPUT i_nro-folhas).

                                    FIND crabfdc WHERE
                                         crabfdc.cdcooper = crapchd.cdcooper AND
                                         crabfdc.cdbanchq = crapchd.cdbanchq AND
                                         crabfdc.cdagechq = crapchd.cdagechq AND
                                         crabfdc.nrctachq = crapchd.nrctachq AND
                                         crabfdc.nrcheque = crapchd.nrcheque
                                         USE-INDEX crapfdc1
                                         EXCLUSIVE-LOCK NO-ERROR.

                                    IF   NOT AVAIL crabfdc   THEN
                                         DO:
                                             ASSIGN i-cod-erro = 108.
                                             RETURN.
                                         END.
                                    ASSIGN crabfdc.incheque = 0
                                           crabfdc.vlcheque = 0
                                           crabfdc.cdoperad = ""
                                           crabfdc.dtliqchq = ?
                                           crabfdc.cdbandep = 0
                                           crabfdc.cdagedep = 0
                                           crabfdc.nrctadep = 0.
                                END.
                           ELSE
                                IF   CAN-DO(aux_lsconta3,
                                            STRING(crapchd.nrctachq))    THEN
                                     DO:
                                         FIND crabfdc WHERE
                                              crabfdc.cdcooper =
                                                      crapchd.cdcooper   AND
                                              crabfdc.cdbanchq =
                                                      crapchd.cdbanchq   AND
                                              crabfdc.cdagechq =
                                                      crapchd.cdagechq   AND
                                              crabfdc.nrctachq =
                                                      crapchd.nrctachq   AND
                                              crabfdc.nrcheque =
                                                      crapchd.nrcheque
                                                      USE-INDEX crapfdc1
                                                      EXCLUSIVE-LOCK NO-ERROR.

                                         IF   NOT AVAIL crabfdc   THEN
                                              DO:
                                                  ASSIGN i-cod-erro = 286.
                                                  RETURN.
                                              END.

                                         ASSIGN crabfdc.incheque = 0
                                                crabfdc.vlcheque = 0
                                                crabfdc.cdoperad = ""
                                                crabfdc.dtliqchq = ?
                                                crabfdc.cdbandep = 0
                                                crabfdc.cdagedep = 0
                                                crabfdc.nrctadep = 0.
                                     END.
                       END.
                  ELSE
                       IF  ((crapchd.cdbanchq = 756 AND /* BANCOOB */
                             crapchd.cdagechq = crapcop.cdagebcb)
                            OR
                            (crapchd.cdcooper = 1              AND
                             crapchd.cdbanchq = 756            AND
                             crapchd.cdagechq = 4415) /* Cheques incorporados Concredi */
                            OR
                            (crapchd.cdcooper = 13             AND
                             crapchd.cdbanchq = 756            AND
                             crapchd.cdagechq = 114) /* Cheques incorporados Credimilsul */
                            OR /* IF CECRED */
                            (crapchd.cdbanchq = crapcop.cdbcoctl AND
                             crapchd.cdagechq = crapcop.cdagectl))
                            OR
                            (crapchd.cdcooper = 1                AND
                             crapchd.cdbanchq = crapcop.cdbcoctl AND
                             crapchd.cdagechq = 0103)   /* Incorporação Concredi */
                            OR
                            (crapchd.cdcooper = 13               AND
                             crapchd.cdbanchq = crapcop.cdbcoctl AND
                             crapchd.cdagechq = 0114)  /* Incorporação Credimilsul */
                            OR
                            (crapchd.cdcooper = 9                AND
                             crapchd.cdbanchq = crapcop.cdbcoctl AND
                             crapchd.cdagechq = 0116             AND
							 TODAY > 12/30/2016)  /* Incorporação Transulcred */
                           THEN DO:

                           IF   CAN-DO(aux_lsconta3,
                                             STRING(crapchd.nrctachq)) THEN
                                      DO:
                                         FIND crabfdc WHERE
                                              crabfdc.cdcooper =
                                                      crapchd.cdcooper   AND
                                              crabfdc.cdbanchq = 
                                                      crapchd.cdbanchq   AND
                                              crabfdc.cdagechq =
                                                      crapchd.cdagechq   AND
                                              crabfdc.nrctachq =
                                                      crapchd.nrctachq   AND
                                              crabfdc.nrcheque =
                                                      crapchd.nrcheque
                                                      USE-INDEX crapfdc1
                                                      EXCLUSIVE-LOCK NO-ERROR.

                                          IF   NOT AVAIL crabfdc   THEN 
                                               DO:
                                   ASSIGN i-cod-erro = 286.
                                   RETURN.
                                END.

                                ASSIGN crabfdc.incheque = 0
                                       crabfdc.cdoperad = ""
                                       crabfdc.vlcheque = 0
                                       crabfdc.dtliqchq = ?
                                       crabfdc.cdbandep = 0
                                       crabfdc.cdagedep = 0
                                       crabfdc.nrctadep = 0.
                           END.
                                 ELSE 
                                      DO:
                                          RUN dbo/pcrap01.p(INPUT-OUTPUT 
                                                              i_nro-docto,
                                                            INPUT-OUTPUT 
                                                              i_nro-talao,
                                                            INPUT-OUTPUT 
                                                              i_posicao,
                                                            INPUT-OUTPUT 
                                                              i_nro-folhas).

                                          FIND crabfdc WHERE
                                               crabfdc.cdcooper =
                                                       crapchd.cdcooper   AND
                                               crabfdc.cdbanchq =
                                                       crapchd.cdbanchq   AND
                                               crabfdc.cdagechq =
                                                       crapchd.cdagechq   AND
                                               crabfdc.nrctachq =
                                                       crapchd.nrctachq   AND
                                               crabfdc.nrcheque =
                                                       crapchd.nrcheque
                                                       USE-INDEX crapfdc1
                                                       EXCLUSIVE-LOCK NO-ERROR.

                                          IF   NOT AVAIL crabfdc   THEN 
                                               DO:
                                    ASSIGN i-cod-erro = 108.
                                    RETURN.
                                END.

                               ASSIGN crabfdc.incheque = 0
                                      crabfdc.cdoperad = ""
                                      crabfdc.vlcheque = 0
                                      crabfdc.dtliqchq = ?
                                      crabfdc.cdbandep = 0
                                      crabfdc.cdagedep = 0
                                      crabfdc.nrctadep = 0.
                           END.
                       END.

                  FIND crablcm WHERE
                       crablcm.cdcooper = crapcop.cdcooper       AND
                       crablcm.dtmvtolt = craplcm.dtmvtolt       AND
                       crablcm.cdagenci = craplcm.cdagenci       AND
                       crablcm.cdbccxlt = craplcm.cdbccxlt       AND
                       crablcm.nrdolote = craplcm.nrdolote       AND
                       crablcm.nrdctabb = INTE(crapchd.nrctachq) AND
                       crablcm.nrdocmto = i_nro-docto USE-INDEX craplcm1
                       EXCLUSIVE-LOCK NO-ERROR.

                  IF   NOT AVAIL crablcm   THEN
                       DO:
                           ASSIGN i-cod-erro = 90.
                           RETURN.
                       END.
                  ELSE
                       DO:
                           /*
                           ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                                  craplot.qtinfoln = craplot.qtinfoln - 1
                                  craplot.vlcompdb = craplot.vlcompdb -
                                                     crablcm.vllanmto
                                  craplot.vlinfodb = craplot.vlinfodb -
                                                     crablcm.vllanmto.
                           */
                           DELETE crablcm.
                       END.
              END.
         ELSE
              DO:      /** Cheque fora  **/
                 RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                 RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT crapcop.nmrescop,
                                                            INPUT p-cod-agencia,
                                                            INPUT p-nro-caixa,
                                                            INPUT p-cod-operador,
                                                            INPUT crapdat.dtmvtocd, /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                            INPUT 2).  /*Estorno*/
                 DELETE PROCEDURE h_b1crap00.
              END.

         DELETE crapchd.

     END. /* for each crapchd */

     RETURN "OK".
END PROCEDURE.

PROCEDURE verifica-crapchd-coop:

     DEF INPUT PARAM p-cod-agencia  AS INTE NO-UNDO.
     DEF INPUT PARAM p-nro-caixa    AS INTE NO-UNDO.
     DEF INPUT PARAM p-cod-operador AS CHAR NO-UNDO.
     DEF INPUT PARAM p-nro-lote     AS INTE NO-UNDO.

     ASSIGN i-cod-erro = 0.

     FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper AND
                            crapchd.dtmvtolt = craplcm.dtmvtolt AND
                            crapchd.cdagenci = p-cod-agencia    AND
                            crapchd.cdbccxlt = 11               AND
                            crapchd.nrdolote = p-nro-lote       AND
                            crapchd.nrseqdig = craplcm.nrseqdig
                            USE-INDEX crapchd3 EXCLUSIVE-LOCK:

         /*  Formata conta integracao  */
         RUN fontes/digbbx.p (INPUT  crapchd.nrctachq,
                              OUTPUT glb_dsdctitg,
                              OUTPUT glb_stsnrcal).
         ASSIGN aux_nrdctitg = "".

         /**  Conta Integracao **/
         IF  LENGTH(STRING(crapchd.nrctachq)) <= 8   THEN
             DO:
                 ASSIGN aux_ctpsqitg = crapchd.nrctachq
                        glb_cdcooper = crapcop.cdcooper.
                 RUN existe_conta_integracao.
             END.

         IF   craplcm.cdhistor = 386   THEN
              DO:
                  ASSIGN i_nro-docto =  DECI(STRING(crapchd.nrcheque,"999999") +
                                            STRING(crapchd.nrddigc3,"9")).
                  IF   (crapchd.cdbanchq = 1 AND
                        crapchd.cdagechq = 3420) OR
                       (aux_nrdctitg <> "" AND
                        CAN-DO("3420", STRING(crapchd.cdagechq)))   THEN
                       DO:

                           IF   CAN-DO(aux_lsconta1,STRING(crapchd.nrctachq)) OR
                                aux_nrdctitg <> " "   THEN
                                DO:
                                    RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto,
                                                      INPUT-OUTPUT i_nro-talao,
                                                      INPUT-OUTPUT i_posicao,
                                                     INPUT-OUTPUT i_nro-folhas).

                                    FIND crabfdc WHERE
                                         crabfdc.cdcooper = crapchd.cdcooper AND
                                         crabfdc.cdbanchq = crapchd.cdbanchq AND
                                         crabfdc.cdagechq = crapchd.cdagechq AND
                                         crabfdc.nrctachq = crapchd.nrctachq AND
                                         crabfdc.nrcheque = crapchd.nrcheque
                                         USE-INDEX crapfdc1
                                         EXCLUSIVE-LOCK NO-ERROR.

                                    IF   NOT AVAIL crabfdc   THEN
                                    DO:
                                        /* Formata conta integracao */
                                        RUN fontes/digbbx.p (INPUT  INTE(crapchd.nrctachq),
                                                             OUTPUT glb_dsdctitg,
                                                             OUTPUT glb_stsnrcal).
                                        IF   NOT glb_stsnrcal   THEN
                                             DO:
                                                 ASSIGN i-cod-erro  = 8.
                                                 RETURN.
                                             END.

                                        /* Localiza se o cheque é de uma conta migrada */
                                        FIND FIRST craptco WHERE
                                                   craptco.cdcooper = crapcop.cdcooper AND /* coop nova */
                                                   craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG */
                                                   craptco.tpctatrf = 1                AND
                                                   craptco.flgativo = TRUE
                                                   NO-LOCK NO-ERROR.

                                        IF  AVAIL craptco  THEN
                                        DO:
                                            /* verifica se o cheque pertence a conta migrada */
                                            FIND FIRST crabfdc WHERE crabfdc.cdcooper = craptco.cdcopant AND
                                                                     crabfdc.cdbanchq = crapchd.cdbanchq AND
                                                                     crabfdc.cdagechq = crapchd.cdagechq AND
                                                                     crabfdc.nrctachq = crapchd.nrctachq AND
                                                                     crabfdc.nrcheque = crapchd.nrcheque
                                                                     EXCLUSIVE-LOCK NO-ERROR.
                                            IF  NOT AVAIL crabfdc  THEN
                                            DO:
                                                ASSIGN i-cod-erro  = 108.
                                                RETURN.
                                            END.
                                        END.
                                        ELSE
                                        DO:
                                            ASSIGN i-cod-erro = 108.
                                            RETURN.
                                        END.
                                    END.
                                    ASSIGN crabfdc.incheque = 0
                                           crabfdc.vlcheque = 0
                                           crabfdc.cdoperad = ""
                                           crabfdc.dtliqchq = ?
                                           crabfdc.cdbandep = 0
                                           crabfdc.cdagedep = 0
                                           crabfdc.nrctadep = 0.
                                END.
                           ELSE
                                IF   CAN-DO(aux_lsconta3,
                                            STRING(crapchd.nrctachq))    THEN
                                     DO:
                                         FIND crabfdc WHERE
                                              crabfdc.cdcooper =
                                                      crapchd.cdcooper   AND
                                              crabfdc.cdbanchq =
                                                      crapchd.cdbanchq   AND
                                              crabfdc.cdagechq =
                                                      crapchd.cdagechq   AND
                                              crabfdc.nrctachq =
                                                      crapchd.nrctachq   AND
                                              crabfdc.nrcheque =
                                                      crapchd.nrcheque
                                                      USE-INDEX crapfdc1
                                                      EXCLUSIVE-LOCK NO-ERROR.

                                         IF   NOT AVAIL crabfdc   THEN
                                         DO:
                                             /* Formata conta integracao */
                                             RUN fontes/digbbx.p (INPUT  INTE(crapchd.nrctachq),
                                                                  OUTPUT glb_dsdctitg,
                                                                  OUTPUT glb_stsnrcal).
                                             IF   NOT glb_stsnrcal   THEN
                                                  DO:
                                                      ASSIGN i-cod-erro  = 8.
                                                      RETURN.
                                                  END.

                                             /* Localiza se o cheque é de uma conta migrada */
                                             FIND FIRST craptco WHERE
                                                        craptco.cdcooper = crapcop.cdcooper AND /* coop nova */
                                                        craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG */
                                                        craptco.tpctatrf = 1                AND
                                                        craptco.flgativo = TRUE
                                                        NO-LOCK NO-ERROR.

                                             IF  AVAIL craptco  THEN
                                             DO:
                                                 /* verifica se o cheque pertence a conta migrada */
                                                 FIND FIRST crabfdc WHERE crabfdc.cdcooper = craptco.cdcopant AND
                                                                          crabfdc.cdbanchq = crapchd.cdbanchq AND
                                                                          crabfdc.cdagechq = crapchd.cdagechq AND
                                                                          crabfdc.nrctachq = crapchd.nrctachq AND
                                                                          crabfdc.nrcheque = crapchd.nrcheque
                                                                          EXCLUSIVE-LOCK NO-ERROR.
                                                 IF  NOT AVAIL crabfdc  THEN
                                                 DO:
                                                     ASSIGN i-cod-erro  = 286.
                                                     RETURN.
                                                 END.
                                             END.
                                             ELSE
                                             DO:
                                                 ASSIGN i-cod-erro = 286.
                                                 RETURN.
                                             END.
                                         END.

                                         ASSIGN crabfdc.incheque = 0
                                                crabfdc.vlcheque = 0
                                                crabfdc.cdoperad = ""
                                                crabfdc.dtliqchq = ?
                                                crabfdc.cdbandep = 0
                                                crabfdc.cdagedep = 0
                                                crabfdc.nrctadep = 0.
                                     END.
                       END.
                  ELSE
                       IF  crapchd.cdbanchq = 756 OR
                           crapchd.cdbanchq = crapcop.cdbcoctl THEN
                             DO:

                                 IF   CAN-DO(aux_lsconta3,
                                             STRING(crapchd.nrctachq)) THEN
                                      DO:
                                         FIND crabfdc WHERE
                                              crabfdc.cdcooper =
                                                      crapchd.cdcooper   AND
                                              crabfdc.cdbanchq =
                                                      crapchd.cdbanchq   AND
                                              crabfdc.cdagechq =
                                                      crapchd.cdagechq   AND
                                              crabfdc.nrctachq =
                                                      crapchd.nrctachq   AND
                                              crabfdc.nrcheque =
                                                      crapchd.nrcheque
                                                      USE-INDEX crapfdc1
                                                      EXCLUSIVE-LOCK NO-ERROR.

                                          IF   NOT AVAIL crabfdc   THEN
                                          DO:
                                              /* Localiza se o cheque é de uma conta migrada */
                                              FIND FIRST craptco WHERE
                                                         craptco.cdcooper = crapcop.cdcooper      AND /* coop nova    */
                                                         craptco.nrctaant = INT(crapchd.nrctachq) AND /* conta antiga */
                                                         craptco.tpctatrf = 1                     AND
                                                         craptco.flgativo = TRUE
                                                         NO-LOCK NO-ERROR.

                                              IF  AVAIL craptco  THEN
                                              DO:
                                                  /* verifica se o cheque pertence a conta migrada */
                                                  FIND FIRST crabfdc WHERE crabfdc.cdcooper = craptco.cdcopant AND
                                                                           crabfdc.cdbanchq = crapchd.cdbanchq AND
                                                                           crabfdc.cdagechq = crapchd.cdagechq AND
                                                                           crabfdc.nrctachq = crapchd.nrctachq AND
                                                                           crabfdc.nrcheque = crapchd.nrcheque
                                                                           EXCLUSIVE-LOCK NO-ERROR.
                                                  IF  NOT AVAIL crabfdc  THEN
                                                  DO:
                                                      ASSIGN i-cod-erro  = 286.
                                                      RETURN.
                                                  END.
                                              END.
                                              ELSE
                                              DO:
                                                  ASSIGN i-cod-erro = 286.
                                                  RETURN.
                                              END.
                                          END.

                                          ASSIGN crabfdc.incheque = 0
                                                 crabfdc.cdoperad = ""
                                                 crabfdc.vlcheque = 0
                                                 crabfdc.dtliqchq = ?
                                                 crabfdc.cdbandep = 0
                                                 crabfdc.cdagedep = 0
                                                 crabfdc.nrctadep = 0.
                                      END.
                                 ELSE
                                      DO:
                                          RUN dbo/pcrap01.p(INPUT-OUTPUT
                                                              i_nro-docto,
                                                            INPUT-OUTPUT
                                                              i_nro-talao,
                                                            INPUT-OUTPUT
                                                              i_posicao,
                                                            INPUT-OUTPUT
                                                              i_nro-folhas).

                                          FIND crabfdc WHERE
                                               crabfdc.cdcooper =
                                                       crapchd.cdcooper   AND
                                               crabfdc.cdbanchq =
                                                       crapchd.cdbanchq   AND
                                               crabfdc.cdagechq =
                                                       crapchd.cdagechq   AND
                                               crabfdc.nrctachq =
                                                       crapchd.nrctachq   AND
                                               crabfdc.nrcheque =
                                                       crapchd.nrcheque
                                                       USE-INDEX crapfdc1
                                                       EXCLUSIVE-LOCK NO-ERROR.

                                          IF   NOT AVAIL crabfdc   THEN
                                          DO:

                                              /* Localiza se o cheque é de uma conta migrada */
                                              FIND FIRST craptco WHERE
                                                         craptco.cdcooper = crapcop.cdcooper      AND /* coop nova    */
                                                         craptco.nrctaant = INT(crapchd.nrctachq) AND /* conta antiga */
                                                         craptco.tpctatrf = 1                     AND
                                                         craptco.flgativo = TRUE
                                                         NO-LOCK NO-ERROR.

                                              IF  AVAIL craptco  THEN
                                              DO:

                                                  /* verifica se o cheque pertence a conta migrada */
                                                  FIND FIRST crabfdc WHERE crabfdc.cdcooper = craptco.cdcopant AND
                                                                           crabfdc.cdbanchq = crapchd.cdbanchq AND
                                                                           crabfdc.cdagechq = crapchd.cdagechq AND
                                                                           crabfdc.nrctachq = crapchd.nrctachq AND
                                                                           crabfdc.nrcheque = crapchd.nrcheque
                                                                           EXCLUSIVE-LOCK NO-ERROR.
                                                  IF  NOT AVAIL crabfdc  THEN
                                                  DO:
                                                      ASSIGN i-cod-erro  = 108.
                                                      RETURN.
                                                  END.
                                              END.
                                              ELSE
                                              DO:
                                                  ASSIGN i-cod-erro = 108.
                                                  RETURN.
                                              END.
                                          END.

                                          ASSIGN crabfdc.incheque = 0
                                                 crabfdc.cdoperad = ""
                                                 crabfdc.vlcheque = 0
                                                 crabfdc.dtliqchq = ?
                                                 crabfdc.cdbandep = 0
                                                 crabfdc.cdagedep = 0
                                                 crabfdc.nrctadep = 0.
                                      END.
                             END.

                  /* Lancamento de pagamento do cheque */
                  FIND crablcm WHERE
                       crablcm.cdcooper = crapcop.cdcooper       AND
                       crablcm.dtmvtolt = craplcm.dtmvtolt       AND
                       crablcm.cdagenci = craplcm.cdagenci       AND
                       crablcm.cdbccxlt = craplcm.cdbccxlt       AND
                       crablcm.nrdolote = craplcm.nrdolote       AND
                       crablcm.nrdctabb = INTE(crapchd.nrctachq) AND
                       crablcm.nrdocmto = i_nro-docto USE-INDEX craplcm1
                       EXCLUSIVE-LOCK NO-ERROR.

                  IF  NOT AVAIL crablcm  THEN
                  DO:
                      /* Caso nao encontrar, validar se eh de uma conta migrada */
                      /* Se for Bco Cecred ou Bancoob usa o nrctaant = crapchd.nrctachq na busca da conta */
                      IF  crapchd.cdbanchq = crapcop.cdbcoctl  OR
                          crapchd.cdbanchq = 756               THEN
                      DO:

                          /* Localiza se o cheque é de uma conta migrada */
                          FIND FIRST craptco WHERE
                                     craptco.cdcopant = crapcop.cdcooper       AND /* coop antiga  */
                                     craptco.nrctaant = INTE(crapchd.nrctachq) AND /* conta antiga */
                                     craptco.tpctatrf = 1                      AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                          IF  AVAIL craptco  THEN
                          DO:

                              FIND crablcm WHERE crablcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                                 crablcm.dtmvtolt = crapdat.dtmvtocd          AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                 crablcm.cdagenci = craptco.cdagenci          AND
                                                 crablcm.cdbccxlt = 100                       AND /* Fixo */
                                                 crablcm.nrdolote = 205000 + craptco.cdagenci AND
                                                 crablcm.nrdctabb = INTE(crapchd.nrctachq)    AND
                                                 crablcm.nrdocmto = i_nro-docto
                                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF   NOT AVAIL crablcm   THEN
                              DO:
                                  ASSIGN i-cod-erro = 90.
                                  RETURN.
                              END.
                              ELSE
                              DO:
                                  /* Este lancamento soh existe quando o deposito eh feito na coop origem da migracao */
                                  /* Remover lancamento extra caixa de conta sobreposta */
                                  FIND LAST crabbcx WHERE crabbcx.cdcooper = crapcop.cdcooper  AND
                                                          crabbcx.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                          crabbcx.cdagenci = p-cod-agencia     AND
                                                          crabbcx.nrdcaixa = p-nro-caixa       AND
                                                          crabbcx.cdopecxa = p-cod-operador    AND
                                                          crabbcx.cdsitbcx = 1
                                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                  IF   NOT AVAILABLE crabbcx   THEN
                                       DO:
                                           ASSIGN i-cod-erro  = 698.
                                           RETURN.
                                       END.

                                  FIND craplcx WHERE craplcx.cdcooper = crapcop.cdcooper AND
                                                     craplcx.dtmvtolt = crapdat.dtmvtocd AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                     craplcx.cdagenci = p-cod-agencia    AND
                                                     craplcx.nrdcaixa = p-nro-caixa      AND
                                                     craplcx.cdopecxa = p-cod-operador   AND
                                                     craplcx.nrdocmto = DECI(STRING(crabfdc.nrcheque,"999999") +
                                                                            STRING(crabfdc.nrdigchq,"9")) AND
                                                     craplcx.cdhistor = 704
                                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                  IF   NOT AVAILABLE craplcx   THEN
                                       DO:
                                           ASSIGN i-cod-erro  = 90.
                                           RETURN.
                                       END.

                                  DELETE craplcx.

                                  ASSIGN crabbcx.qtcompln = crabbcx.qtcompln - 1.
                                         /*
                                         craplot.qtcompln = craplot.qtcompln - 1
                                         craplot.qtinfoln = craplot.qtinfoln - 1
                                         craplot.vlcompdb = craplot.vlcompdb -
                                                            crablcm.vllanmto
                                         craplot.vlinfodb = craplot.vlinfodb -
                                                            crablcm.vllanmto.
										 */
                                  DELETE crablcm.

                              END.
                          END.
                      END.
                      ELSE
                      /* Se for BB usa a conta ITG para buscar conta migrada */
                      /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                      IF  crapchd.cdbanchq = 1 AND crapchd.cdagechq = 3420  THEN
                      DO:
                          /* Formata conta integracao */
                          RUN fontes/digbbx.p (INPUT  INTE(crapchd.nrctachq),
                                               OUTPUT glb_dsdctitg,
                                               OUTPUT glb_stsnrcal).
                          IF   NOT glb_stsnrcal   THEN
                               DO:
                                   ASSIGN i-cod-erro  = 8.
                                   RETURN.
                               END.

                          /* Localiza se o cheque é de uma conta migrada */
                          FIND FIRST craptco WHERE
                                     craptco.cdcopant = crapcop.cdcooper AND /* coop antiga               */
                                     craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                     craptco.tpctatrf = 1                AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                          IF  AVAIL craptco  THEN
                          DO:
                              FIND crablcm WHERE crablcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                                 crablcm.dtmvtolt = crapdat.dtmvtocd          AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                 crablcm.cdagenci = craptco.cdagenci          AND
                                                 crablcm.cdbccxlt = 100                       AND /* Fixo */
                                                 crablcm.nrdolote = 205000 + craptco.cdagenci AND
                                                 crablcm.nrdctabb = INTE(crapchd.nrctachq)    AND
                                                 crablcm.nrdocmto = i_nro-docto
                                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF  NOT AVAIL crablcm  THEN
                              DO:
                                  ASSIGN i-cod-erro = 90.
                                  RETURN.
                              END.
                              ELSE
                              DO:
                                  /* Este lancamento soh existe quando o deposito eh feito na coop origem da migracao */
                                  /* Remover lancamento extra caixa de conta sobreposta */
                                  FIND LAST crabbcx WHERE crabbcx.cdcooper = crapcop.cdcooper  AND
                                                          crabbcx.dtmvtolt = crapdat.dtmvtocd  AND /*15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                          crabbcx.cdagenci = p-cod-agencia     AND
                                                          crabbcx.nrdcaixa = p-nro-caixa       AND
                                                          crabbcx.cdopecxa = p-cod-operador    AND
                                                          crabbcx.cdsitbcx = 1
                                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                  IF   NOT AVAILABLE crabbcx   THEN
                                       DO:
                                           ASSIGN i-cod-erro  = 698.
                                           RETURN.
                                       END.

                                  FIND craplcx WHERE craplcx.cdcooper = crapcop.cdcooper AND
                                                     craplcx.dtmvtolt = crapdat.dtmvtocd AND /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                     craplcx.cdagenci = p-cod-agencia    AND
                                                     craplcx.nrdcaixa = p-nro-caixa      AND
                                                     craplcx.cdopecxa = p-cod-operador   AND
                                                     craplcx.nrdocmto = DECI(STRING(crabfdc.nrcheque,"999999") +
                                                                            STRING(crabfdc.nrdigchq,"9")) AND
                                                     craplcx.cdhistor = 704
                                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                  IF   NOT AVAILABLE craplcx   THEN
                                       DO:
                                           ASSIGN i-cod-erro  = 90.
                                           RETURN.
                                       END.

                                  DELETE craplcx.

                                  ASSIGN crabbcx.qtcompln = crabbcx.qtcompln - 1.
                                         /*
                                         craplot.qtcompln = craplot.qtcompln - 1
                                         craplot.qtinfoln = craplot.qtinfoln - 1
                                         craplot.vlcompdb = craplot.vlcompdb -
                                                            crablcm.vllanmto
                                         craplot.vlinfodb = craplot.vlinfodb -
                                                            crablcm.vllanmto.
										 */
                                  DELETE crablcm.

                              END.
                          END.
                      END.
                      ELSE
                      DO:
                          ASSIGN i-cod-erro = 90.
                          RETURN.
                      END.
                  END.
                  ELSE
                  DO:

                      /*
                      ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                             craplot.qtinfoln = craplot.qtinfoln - 1
                             craplot.vlcompdb = craplot.vlcompdb -
                                                crablcm.vllanmto
                             craplot.vlinfodb = craplot.vlinfodb -
                                                crablcm.vllanmto.
                      */
                      DELETE crablcm.
                  END.
              END.
         ELSE
             DO:  /**** Cheque de fora ****/
                  RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                  RUN atualiza-previa-caixa  IN h_b1crap00 (INPUT crapcop.nmrescop,
                                                            INPUT p-cod-agencia,
                                                            INPUT p-nro-caixa,
                                                            INPUT p-cod-operador,
                                                            INPUT crapdat.dtmvtocd,  /* 15/06/2018 - Alterado para o campo dtmvctocd - Everton Deserto(AMCOM)*/
                                                            INPUT 2).  /*Estorno*/
                  DELETE PROCEDURE h_b1crap00.
             END.

         DELETE crapchd.


     END. /* for each crapchd */

     RETURN "OK".
END PROCEDURE.
/* b1crap71.p */


