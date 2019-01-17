/*.............................................................................

   Programa: siscaixa/web/dbo/b1crap88.p
   Sistema : Caixa On-Line
   Autor   : Andre Santos - Supero
   Data    : Junho/2014                      Ultima atualizacao:08/06/2018

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Rotina de Estorno de cheques entre cooperativas

   Alteracoes: 16/07/2014 - Conversao de procedure valida-cheque-com-captura,
                                                   verifica-crapchd,
                                                   verifica-crapchd-coop,
                                                   estorna-dep-cheque-com-captura
                            do fonte b1crap88 para pc_valida_chq_captura_wt,
                                                   pc_estorna_dep_chq_captura,
                                                   pc_verifica_crapchd,
                                                   pc_verifica_crapchd_coop
                            do pacote CXON0088. (Andre Santos - SUPERO)

               08/06/2018 - Alteracao do campo crapdat.dtmvtolt para 
                            crapdat.dtmvtocd - Everton Deserto(AMCOM).

               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

----------------------------------------------------------------------------- **/

{dbo/bo-erro1.i}

DEF  VAR glb_nrcalcul        AS DECIMAL                             NO-UNDO.
DEF  VAR glb_dsdctitg        AS CHAR                                NO-UNDO.
DEF  VAR glb_stsnrcal        AS LOGICAL                             NO-UNDO.



DEF VAR i-cod-erro           AS INTEGER                             NO-UNDO.
DEF VAR c-desc-erro          AS CHAR                                NO-UNDO.

DEF VAR i-nro-lote           AS INTE                                NO-UNDO.

DEF VAR p-literal            AS CHAR                                NO-UNDO.
DEF VAR p-ult-sequencia      AS INTE                                NO-UNDO.
DEF VAR p-registro           AS RECID                               NO-UNDO.

DEF VAR h_b1crap00           AS HANDLE                              NO-UNDO.
DEF VAR h_b1crap71           AS HANDLE                              NO-UNDO.
DEF VAR h-b1wgen0118         AS HANDLE                              NO-UNDO.

DEF VAR c-texto-2-via        AS CHAR                                NO-UNDO.
DEF VAR in99                 AS INTE                                NO-UNDO.
DEF VAR c-literal            AS CHAR    FORMAT "x(48)" EXTENT 100.

DEF VAR c-cgc-para-1         AS CHAR    FORMAT "x(19)"              NO-UNDO.
DEF VAR c-cgc-para-2         AS CHAR    FORMAT "x(19)"              NO-UNDO.

DEF VAR p-literal-lcm        AS CHAR                                NO-UNDO.
DEF VAR p-ult-sequencia-lcm  AS INTE                                NO-UNDO.


DEF VAR p-literal-lcx        AS CHAR                                NO-UNDO.
DEF VAR p-registro-lcx       AS RECID                               NO-UNDO.
DEF VAR p-ult-sequencia-lcx  AS INTE                                NO-UNDO.


DEF VAR c-nome-titular1      AS CHAR                                NO-UNDO.
DEF VAR c-nome-titular2      AS CHAR                                NO-UNDO.
DEF VAR c-pa-titular         AS CHAR                                NO-UNDO.

/** Variaveis para realiza-deposito-cheque */
DEF VAR aux_nrtrfcta         LIKE craptrf.nrsconta                  NO-UNDO.
DEF VAR aux_nrdctitg         LIKE crapass.nrdctitg                  NO-UNDO.
DEF VAR aux_nrctaass         LIKE crapass.nrdconta                  NO-UNDO.
DEF VAR aux_ctpsqitg         AS DEC                                 NO-UNDO.
DEF VAR aux_nrdconta         AS INTE                                NO-UNDO.
DEF VAR dt-liberacao         AS DATE                                NO-UNDO.
DEF VAR aux_contador         AS INTE                                NO-UNDO.
DEF VAR de-valor-total       AS DEC                                 NO-UNDO.
DEF VAR de-dinheiro          AS DEC                                 NO-UNDO.
DEF VAR de-cooperativa       AS DEC                                 NO-UNDO.
DEF VAR de-maior-praca       AS DEC                                 NO-UNDO.
DEF VAR de-menor-praca       AS DEC                                 NO-UNDO.
DEF VAR de-maior-fpraca      AS DEC                                 NO-UNDO.
DEF VAR de-menor-fpraca      AS DEC                                 NO-UNDO.
DEF VAR de-chq-intercoop     AS DEC                                 NO-UNDO.
DEF VAR c-docto-salvo        AS CHAR                                NO-UNDO.
DEF VAR c-docto              AS CHAR                                NO-UNDO.
DEF VAR l-achou-horario-corte AS LOG                                NO-UNDO.
DEF VAR aux_tpdmovto         AS INTE                                NO-UNDO.
DEF VAR i-nro-docto          AS INTE                                NO-UNDO.
DEF VAR i-seq-386            AS INTE                                NO-UNDO.
DEF VAR aux_nrsequen         AS INTE                                NO-UNDO.
DEF VAR i-nrdocmto           AS INTE                                NO-UNDO.
DEF VAR aux-p-literal        AS CHAR                                NO-UNDO.
DEF VAR aux-p-ult-sequencia  AS INTE                                NO-UNDO.
DEF VAR c-cdagerem           AS INTE                                NO-UNDO.
DEF VAR glb_cdcooper         AS INT                                 NO-UNDO.

DEF VAR i_nro-docto          AS INTE                                NO-UNDO.
DEF VAR i_nro-talao          AS INTE                                NO-UNDO.
DEF VAR i_posicao            AS INTE                                NO-UNDO.
DEF VAR i_nro-folhas         AS INTE                                NO-UNDO.
DEF VAR aux_lsconta1         AS CHAR                                NO-UNDO.
DEF VAR aux_lsconta2         AS CHAR                                NO-UNDO.
DEF VAR aux_lsconta3         AS CHAR                                NO-UNDO.
DEF VAR aux_lscontas         AS CHAR                                NO-UNDO.
DEF VAR aux_cdcooper         AS INTE                                NO-UNDO.
DEF VAR aux_cdbccxlt         AS INTE                                NO-UNDO.
DEF VAR aux_cdagenci         AS INTE                                NO-UNDO.

DEF VAR i_conta              AS DEC                                 NO-UNDO.
DEF VAR l-achou              AS LOG                                 NO-UNDO.
DEF VAR l-achou-migrado      AS LOG                                 NO-UNDO.
DEF VAR flg_exetrunc         AS LOG                                 NO-UNDO.

/**   Conta Integracao **/
DEF  BUFFER crabass5 FOR crapass.
DEF  VAR aux_nrdigitg         AS CHAR                              NO-UNDO.
{includes/proc_conta_integracao.i}


DEF VAR aux-p-registro       AS RECID                              NO-UNDO.

DEF BUFFER crablcm   FOR craplcm.
DEF BUFFER crabfdc   FOR crapfdc.
DEF BUFFER crabcop   FOR crapcop.
DEF BUFFER crabass   FOR crapass.
DEF BUFFER crabbcx   FOR crapbcx.


DEFINE TEMP-TABLE tt-cheques NO-UNDO
       FIELD dtlibera AS DATE
       FIELD nrdocmto AS INTE
       FIELD vlcompel AS DECI
       FIELD nrsequen AS INTE
       FIELD nrseqlcm AS INTE
       INDEX tt-cheques1 nrdocmto dtlibera.

DEFINE TEMP-TABLE tt-lancamentos NO-UNDO
    FIELD tpdocmto AS INTE
    FIELD dtmvtolt AS DATE
    FIELD vllanmto AS DECI
    INDEX tt-lancamentos1 tpdocmto dtmvtolt.


DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.


/*****************************************************************************/

PROCEDURE valida-cheque-com-captura:

    DEF INPUT  PARAM p-cooper            AS CHAR /* Coop. Origem  */  NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INTE /* Cod. Agencia  */  NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa         AS INTE /* Nro Caixa     */  NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest       AS CHAR /* Coop. Destino */  NO-UNDO.
    DEF INPUT  PARAM p-nro-conta         AS INTE /* Nro Conta     */  NO-UNDO.
    DEF INPUT  PARAM p-nrdocto           AS INTE                      NO-UNDO.
    DEF OUTPUT PARAM p-dsidenti          AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM p-nome-titular      AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM p-poupanca          AS LOG                       NO-UNDO.
    DEF OUTPUT PARAM p-valor-cooperativa AS DEC                       NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_vretorno AS CHAR                                      NO-UNDO.
    DEF VAR aux_poupanca AS INTE                                      NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_valida_chq_captura_wt aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT p-cooper-dest,
                          INPUT p-nro-conta,
                          INPUT p-nrdocto,
                          OUTPUT "",
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    
    CLOSE STORED-PROC pc_valida_chq_captura_wt aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN p-dsidenti          = ""
           p-nome-titular      = ""
           aux_vretorno        = ""
           p-valor-cooperativa = 0
           aux_cdcritic        = 0
           aux_dscritic        = ""
           aux_poupanca        = 0
           p-poupanca          = FALSE
           p-dsidenti          = pc_valida_chq_captura_wt.pr_dsidenti
                               WHEN pc_valida_chq_captura_wt.pr_dsidenti <> ?
           p-nome-titular      = pc_valida_chq_captura_wt.pr_nom_titular
                               WHEN pc_valida_chq_captura_wt.pr_nom_titular <> ?
           aux_poupanca        = pc_valida_chq_captura_wt.pr_poupanca
                               WHEN pc_valida_chq_captura_wt.pr_poupanca <> ?
           p-valor-cooperativa = pc_valida_chq_captura_wt.pr_valor_coop
                               WHEN pc_valida_chq_captura_wt.pr_valor_coop <> ?
           aux_vretorno        = pc_valida_chq_captura_wt.pr_retorno
                               WHEN pc_valida_chq_captura_wt.pr_retorno <> ?
           aux_cdcritic        = pc_valida_chq_captura_wt.pr_cdcritic
                               WHEN pc_valida_chq_captura_wt.pr_cdcritic <> ?
           aux_dscritic        = pc_valida_chq_captura_wt.pr_dscritic
                               WHEN pc_valida_chq_captura_wt.pr_dscritic <> ?.
           
           IF aux_poupanca = 0 THEN
              ASSIGN p-poupanca = FALSE.
           ELSE
              ASSIGN p-poupanca = TRUE.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    FOR EACH wt_lancamento_proces NO-LOCK:
        CREATE tt-lancamentos.
        ASSIGN tt-lancamentos.tpdocmto = wt_lancamento_proces.tpdocmto
               tt-lancamentos.dtmvtolt = wt_lancamento_proces.dtmvtolt
               tt-lancamentos.vllanmto = wt_lancamento_proces.vllanmto.
    END.
    
    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" OR
       aux_vretorno <> "OK" THEN DO:
       RETURN aux_vretorno. /* NOK */
    END.

    RETURN aux_vretorno. /* OK */

END PROCEDURE.

/*****************************************************************************/

PROCEDURE verifica-crapchd:

    DEF INPUT PARAM p-cod-agencia  AS INTE.
    DEF INPUT PARAM p-nro-caixa    AS INTE.
    DEF INPUT PARAM p-cod-operador AS CHAR.

    DEF BUFFER crablot FOR craplot.

    ASSIGN i-cod-erro = 0.


    /** Dados ORIGEM **/
    ASSIGN aux_cdcooper = crapcop.cdcooper
           aux_cdagenci = p-cod-agencia
           aux_cdbccxlt = 11
           i-nro-lote   = 11000 + p-nro-caixa.
    
    /** Posicionar no LOTE de ORIGEM */
    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.
    
        FIND crablot WHERE crablot.cdcooper = aux_cdcooper /* crapcop.cdcooper */
                       AND crablot.dtmvtolt = crapdat.dtmvtocd  /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                       AND crablot.cdagenci = aux_cdagenci /* p-cod-agencia    */
                       AND crablot.cdbccxlt = aux_cdbccxlt /* 11               */
                       AND crablot.nrdolote = i-nro-lote
                       NO-ERROR NO-WAIT.
        IF  NOT AVAIL   crablot   THEN  DO:
            IF  LOCKED crablot     THEN DO:
                IF  in99 < 100     THEN DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Tabela CRAPLOT em uso ".
                    RUN cria-erro (INPUT aux_cdcooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            END.
            ELSE DO:
                ASSIGN i-cod-erro  = 60
                       c-desc-erro = " ".
    
                RUN cria-erro (INPUT aux_cdcooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
        END.
    
        LEAVE.
    
    END.  /*  DO WHILE */
    
    
    FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper
                       AND crapchd.dtmvtolt = craplcm.dtmvtolt
                       AND crapchd.cdagenci = p-cod-agencia
                       AND crapchd.cdbccxlt = 11
                       AND crapchd.nrdolote = i-nro-lote
                       AND crapchd.nrseqdig = craplcm.nrseqdig
                       USE-INDEX crapchd3 EXCLUSIVE-LOCK:

        /*  Formata conta integracao  */
        RUN fontes/digbbx.p (INPUT  crapchd.nrctachq,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).
        ASSIGN aux_nrdctitg = "".
        /**  Conta Integracao **/
        IF  LENGTH(STRING(crapchd.nrctachq)) <= 8   THEN DO:
            ASSIGN aux_ctpsqitg = crapchd.nrctachq
                   glb_cdcooper = crapcop.cdcooper.
            RUN existe_conta_integracao.  
        END.

        IF  craplcm.cdhistor = 386   THEN DO:
            ASSIGN i_nro-docto =  INT(STRING(crapchd.nrcheque,"999999") +
                                       STRING(crapchd.nrddigc3,"9")).
            IF  (crapchd.cdbanchq = 1 AND 
                 crapchd.cdagechq = 3420)
            OR  (aux_nrdctitg <> "" AND   
                  CAN-DO("3420", STRING(crapchd.cdagechq))) THEN DO:

                IF  CAN-DO(aux_lsconta1,STRING(crapchd.nrctachq)) OR
                     aux_nrdctitg <> " "   THEN DO:

                     RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto,
                                       INPUT-OUTPUT i_nro-talao,                                                       
                                       INPUT-OUTPUT i_posicao,
                                      INPUT-OUTPUT i_nro-folhas).

                     FIND FIRST crabfdc
                          WHERE crabfdc.cdcooper = crapchd.cdcooper
                            AND crabfdc.cdbanchq = crapchd.cdbanchq
                            AND crabfdc.cdagechq = crapchd.cdagechq
                            AND crabfdc.nrctachq = crapchd.nrctachq
                            AND crabfdc.nrcheque = crapchd.nrcheque
                            USE-INDEX crapfdc1
                            EXCLUSIVE-LOCK NO-ERROR.

                     IF  NOT AVAIL crabfdc   THEN DO:
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
                    IF  CAN-DO(aux_lsconta3,            
                               STRING(crapchd.nrctachq)) THEN DO: 
                        FIND FIRST crabfdc
                             WHERE crabfdc.cdcooper = crapchd.cdcooper
                               AND crabfdc.cdbanchq = crapchd.cdbanchq
                               AND crabfdc.cdagechq = crapchd.cdagechq
                               AND crabfdc.nrctachq = crapchd.nrctachq
                               AND crabfdc.nrcheque = crapchd.nrcheque
                               USE-INDEX crapfdc1
                               EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL crabfdc THEN DO:
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
                      OR /* IF CECRED */
                      (crapchd.cdbanchq = crapcop.cdbcoctl AND
                       crapchd.cdagechq = crapcop.cdagectl)) THEN DO:
                    IF  CAN-DO(aux_lsconta3,
                               STRING(crapchd.nrctachq)) THEN DO:
                        FIND FIRST crabfdc
                             WHERE crabfdc.cdcooper = crapchd.cdcooper
                               AND crabfdc.cdbanchq = crapchd.cdbanchq
                               AND crabfdc.cdagechq = crapchd.cdagechq
                               AND crabfdc.nrctachq = crapchd.nrctachq
                               AND crabfdc.nrcheque = crapchd.nrcheque
                               USE-INDEX crapfdc1
                               EXCLUSIVE-LOCK NO-ERROR.
                         
                         IF  NOT AVAIL crabfdc THEN DO:
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
                    ELSE DO:
                        RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto,
                                          INPUT-OUTPUT i_nro-talao,
                                          INPUT-OUTPUT i_posicao,
                                          INPUT-OUTPUT i_nro-folhas).

                        FIND FIRST crabfdc 
                             WHERE crabfdc.cdcooper = crapchd.cdcooper
                               AND crabfdc.cdbanchq = crapchd.cdbanchq
                               AND crabfdc.cdagechq = crapchd.cdagechq
                               AND crabfdc.nrctachq = crapchd.nrctachq
                               AND crabfdc.nrcheque = crapchd.nrcheque
                               USE-INDEX crapfdc1
                               EXCLUSIVE-LOCK NO-ERROR.
                        
                        IF  NOT AVAIL crabfdc THEN DO:
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
                  
            FIND FIRST crablcm
                 WHERE crablcm.cdcooper = crapcop.cdcooper
                   AND crablcm.dtmvtolt = craplcm.dtmvtolt
                   AND crablcm.cdagenci = craplcm.cdagenci
                   AND crablcm.cdbccxlt = craplcm.cdbccxlt
                   AND crablcm.nrdolote = craplcm.nrdolote
                   AND crablcm.nrdctabb = INTE(crapchd.nrctachq) 
                   AND crablcm.nrdocmto = i_nro-docto USE-INDEX craplcm1
                   EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crablcm   THEN DO:
                ASSIGN i-cod-erro = 90.
                RETURN.
            END.
            ELSE DO:
                ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                       craplot.qtinfoln = craplot.qtinfoln - 1
                       craplot.vlcompdb = craplot.vlcompdb - 
                                          crablcm.vllanmto
                       craplot.vlinfodb = craplot.vlinfodb - 
                                          crablcm.vllanmto.
                DELETE crablcm.
            END.
        END.
        ELSE DO:      /** Cheque fora  **/
            RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
            RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT crapcop.nmrescop,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT p-cod-operador,
                                                       INPUT crapdat.dtmvtocd,  /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                                                       INPUT 2).  /*Estorno*/
            DELETE PROCEDURE h_b1crap00.
        END.
        
        DELETE crapchd.
     
    END. /* for each crapchd */
    
    RETURN "OK".
END PROCEDURE.

/*****************************************************************************/

PROCEDURE verifica-crapchd-coop:

    DEF INPUT PARAM p-cod-agencia  AS INTE NO-UNDO.
    DEF INPUT PARAM p-nro-caixa    AS INTE NO-UNDO.
    DEF INPUT PARAM p-cod-operador AS CHAR NO-UNDO.
    DEF INPUT PARAM p-nro-lote     AS INTE NO-UNDO.

    DEF BUFFER crablot FOR craplot.

    ASSIGN i-cod-erro = 0.


    /** Dados ORIGEM **/
    ASSIGN aux_cdcooper = crapcop.cdcooper
           aux_cdagenci = p-cod-agencia
           aux_cdbccxlt = 11
           i-nro-lote   = p-nro-lote.

    /** Posicionar no LOTE de ORIGEM */
    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.

        FIND crablot WHERE crablot.cdcooper = aux_cdcooper /* crapcop.cdcooper */
                       AND crablot.dtmvtolt = crapdat.dtmvtocd /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                       AND crablot.cdagenci = aux_cdagenci /* p-cod-agencia    */
                       AND crablot.cdbccxlt = aux_cdbccxlt /* 11               */
                       AND crablot.nrdolote = i-nro-lote
                       NO-ERROR NO-WAIT.
        IF  NOT AVAIL   crablot   THEN  DO:
            IF  LOCKED crablot     THEN DO:
                IF  in99 < 100     THEN DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Tabela CRAPLOT em uso ".
                    RUN cria-erro (INPUT aux_cdcooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            END.
            ELSE DO:
                ASSIGN i-cod-erro  = 60
                       c-desc-erro = " ".

                RUN cria-erro (INPUT aux_cdcooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
        END.

        LEAVE.

    END.  /*  DO WHILE */


    FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper
                       AND crapchd.dtmvtolt = craplcm.dtmvtolt
                       AND crapchd.cdagenci = p-cod-agencia
                       AND crapchd.cdbccxlt = 11
                       AND crapchd.nrdolote = p-nro-lote
                       AND crapchd.nrseqdig = craplcm.nrseqdig
                       USE-INDEX crapchd3 EXCLUSIVE-LOCK:

        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapchd.nrctachq,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).
        ASSIGN aux_nrdctitg = "".

        /**  Conta Integracao **/
        IF  LENGTH(STRING(crapchd.nrctachq)) <= 8 THEN DO:
            ASSIGN aux_ctpsqitg = crapchd.nrctachq
                   glb_cdcooper = crapcop.cdcooper.
            RUN existe_conta_integracao.
        END.

        IF  craplcm.cdhistor = 386 THEN DO:

            ASSIGN i_nro-docto =  INT(STRING(crapchd.nrcheque,"999999") +
                                      STRING(crapchd.nrddigc3,"9")).
            IF  (crapchd.cdbanchq = 1 AND
                 crapchd.cdagechq = 3420)
            OR  (aux_nrdctitg <> "" AND
                 CAN-DO("3420", STRING(crapchd.cdagechq))) THEN DO:

                IF  CAN-DO(aux_lsconta1,STRING(crapchd.nrctachq))
                OR  aux_nrdctitg <> " " THEN DO:

                    RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto,
                                      INPUT-OUTPUT i_nro-talao,
                                      INPUT-OUTPUT i_posicao,
                                      INPUT-OUTPUT i_nro-folhas).

                    FIND FIRST crabfdc
                         WHERE crabfdc.cdcooper = crapchd.cdcooper
                           AND crabfdc.cdbanchq = crapchd.cdbanchq
                           AND crabfdc.cdagechq = crapchd.cdagechq
                           AND crabfdc.nrctachq = crapchd.nrctachq
                           AND crabfdc.nrcheque = crapchd.nrcheque
                     USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAIL crabfdc THEN DO:
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
                        FIND FIRST craptco
                             WHERE craptco.cdcooper = crapcop.cdcooper /* coop nova */
                               AND craptco.nrdctitg = glb_dsdctitg     /* conta ITG */
                               AND craptco.tpctatrf = 1
                               AND craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

                        IF  AVAIL craptco THEN DO:
                            /* verifica se o cheque pertence a conta migrada */
                            FIND FIRST crabfdc
                                 WHERE crabfdc.cdcooper = craptco.cdcopant
                                   AND crabfdc.cdbanchq = crapchd.cdbanchq
                                   AND crabfdc.cdagechq = crapchd.cdagechq
                                   AND crabfdc.nrctachq = crapchd.nrctachq
                                   AND crabfdc.nrcheque = crapchd.nrcheque
                                   EXCLUSIVE-LOCK NO-ERROR.
                            IF  NOT AVAIL crabfdc  THEN DO:
                                ASSIGN i-cod-erro  = 108.
                                RETURN.
                            END.
                        END.
                        ELSE DO:
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
                    IF  CAN-DO(aux_lsconta3,
                               STRING(crapchd.nrctachq)) THEN DO:
                        FIND FIRST crabfdc
                             WHERE crabfdc.cdcooper = crapchd.cdcooper
                               AND crabfdc.cdbanchq = crapchd.cdbanchq
                               AND crabfdc.cdagechq = crapchd.cdagechq
                               AND crabfdc.nrctachq = crapchd.nrctachq
                               AND crabfdc.nrcheque = crapchd.nrcheque
                               USE-INDEX crapfdc1
                               EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL crabfdc THEN DO:
                            /* Formata conta integracao */
                            RUN fontes/digbbx.p (INPUT  INTE(crapchd.nrctachq),
                                                 OUTPUT glb_dsdctitg,
                                                 OUTPUT glb_stsnrcal).
                            IF  NOT glb_stsnrcal THEN DO:
                                ASSIGN i-cod-erro  = 8.
                                RETURN.
                            END.

                            /* Localiza se o cheque é de uma conta migrada */
                            FIND FIRST craptco
                                 WHERE craptco.cdcooper = crapcop.cdcooper /* coop nova */
                                   AND craptco.nrdctitg = glb_dsdctitg     /* conta ITG */
                                   AND craptco.tpctatrf = 1
                                   AND craptco.flgativo = TRUE
                                       NO-LOCK NO-ERROR.

                            IF  AVAIL craptco  THEN DO:
                                /* verifica se o cheque pertence a conta migrada */
                                FIND FIRST crabfdc WHERE crabfdc.cdcooper = craptco.cdcopant AND
                                                         crabfdc.cdbanchq = crapchd.cdbanchq AND
                                                         crabfdc.cdagechq = crapchd.cdagechq AND
                                                         crabfdc.nrctachq = crapchd.nrctachq AND
                                                         crabfdc.nrcheque = crapchd.nrcheque
                                                         EXCLUSIVE-LOCK NO-ERROR.
                                IF  NOT AVAIL crabfdc THEN DO:
                                    ASSIGN i-cod-erro  = 286.
                                    RETURN.
                                END.
                            END.
                            ELSE DO:
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
                 IF  crapchd.cdbanchq = 756
                 OR  crapchd.cdbanchq = crapcop.cdbcoctl THEN DO:

                     IF  CAN-DO(aux_lsconta3,
                                STRING(crapchd.nrctachq)) THEN DO:
                         FIND crabfdc WHERE
                              crabfdc.cdcooper = crapchd.cdcooper   AND
                              crabfdc.cdbanchq = crapchd.cdbanchq   AND
                              crabfdc.cdagechq = crapchd.cdagechq   AND
                              crabfdc.nrctachq = crapchd.nrctachq   AND
                              crabfdc.nrcheque = crapchd.nrcheque
                              USE-INDEX crapfdc1
                              EXCLUSIVE-LOCK NO-ERROR.

                          IF  NOT AVAIL crabfdc   THEN DO:
                              /* Localiza se o cheque é de uma conta migrada */
                              FIND FIRST craptco WHERE
                                         craptco.cdcooper = crapcop.cdcooper      AND /* coop nova    */
                                         craptco.nrctaant = INT(crapchd.nrctachq) AND /* conta antiga */
                                         craptco.tpctatrf = 1                     AND
                                         craptco.flgativo = TRUE
                                         NO-LOCK NO-ERROR.

                              IF  AVAIL craptco  THEN DO:
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
                              ELSE DO:
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
                     ELSE DO:
                          RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto,
                                            INPUT-OUTPUT i_nro-talao,
                                            INPUT-OUTPUT i_posicao,
                                            INPUT-OUTPUT i_nro-folhas).

                          FIND crabfdc WHERE
                               crabfdc.cdcooper = crapchd.cdcooper   AND
                               crabfdc.cdbanchq = crapchd.cdbanchq   AND
                               crabfdc.cdagechq = crapchd.cdagechq   AND
                               crabfdc.nrctachq = crapchd.nrctachq   AND
                               crabfdc.nrcheque = crapchd.nrcheque
                               USE-INDEX crapfdc1
                               EXCLUSIVE-LOCK NO-ERROR.

                          IF  NOT AVAIL crabfdc THEN DO:

                              /* Localiza se o cheque é de uma conta migrada */
                              FIND FIRST craptco WHERE
                                         craptco.cdcooper = crapcop.cdcooper      AND /* coop nova    */
                                         craptco.nrctaant = INT(crapchd.nrctachq) AND /* conta antiga */
                                         craptco.tpctatrf = 1                     AND
                                         craptco.flgativo = TRUE
                                         NO-LOCK NO-ERROR.

                              IF  AVAIL craptco THEN DO:

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

            /* Lancamento de pagamento do cheque - DEBITO */
            FIND FIRST crablcm
                 WHERE crablcm.cdcooper = crapcop.cdcooper      
                   AND crablcm.dtmvtolt = crapchd.dtmvtolt  /* craplcm.dtmvtolt  */
                   AND crablcm.cdagenci = crapchd.cdagenci  /* craplcm.cdagenci  */
                   AND crablcm.cdbccxlt = crapchd.cdbccxlt  /* craplcm.cdbccxlt  */
                   AND crablcm.nrdolote = crapchd.nrdolote  /* craplcm.nrdolote  */
                   AND crablcm.nrdctabb = INTE(crapchd.nrctachq)
                   AND crablcm.nrdocmto = i_nro-docto USE-INDEX craplcm1
                 EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crablcm  THEN DO:
                /* Caso nao encontrar, validar se eh de uma conta migrada */
                /* Se for Bco Cecred ou Bancoob usa o nrctaant = crapchd.nrctachq na busca da conta */
                IF  crapchd.cdbanchq = crapcop.cdbcoctl
                OR  crapchd.cdbanchq = 756 THEN DO:

                    /* Localiza se o cheque é de uma conta migrada */
                    FIND FIRST craptco WHERE
                               craptco.cdcopant = crapcop.cdcooper       AND /* coop antiga  */
                               craptco.nrctaant = INTE(crapchd.nrctachq) AND /* conta antiga */
                               craptco.tpctatrf = 1                      AND
                               craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.

                    IF  AVAIL craptco  THEN DO:

                        FIND crablcm WHERE crablcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                           crablcm.dtmvtolt = crapdat.dtmvtocd          AND /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                                           crablcm.cdagenci = craptco.cdagenci          AND
                                           crablcm.cdbccxlt = 100                       AND /* Fixo */
                                           crablcm.nrdolote = 205000 + craptco.cdagenci AND
                                           crablcm.nrdctabb = INTE(crapchd.nrctachq)    AND
                                           crablcm.nrdocmto = i_nro-docto
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAIL crablcm   THEN DO:
                            ASSIGN i-cod-erro = 90.
                            RETURN.
                        END.
                        ELSE DO:
                            /* Este lancamento soh existe quando o deposito eh feito na coop origem da migracao */
                            /* Remover lancamento extra caixa de conta sobreposta */
                            FIND LAST crabbcx WHERE crabbcx.cdcooper = crapcop.cdcooper  AND
                                                    crabbcx.dtmvtolt = crapdat.dtmvtocd  AND /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
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
                                               craplcx.dtmvtolt = crapdat.dtmvtocd AND /*08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                                               craplcx.cdagenci = p-cod-agencia    AND
                                               craplcx.nrdcaixa = p-nro-caixa      AND
                                               craplcx.cdopecxa = p-cod-operador   AND
                                               craplcx.nrdocmto = INT(STRING(crabfdc.nrcheque,"999999") +
                                                                      STRING(crabfdc.nrdigchq,"9")) AND
                                               craplcx.cdhistor = 704
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF   NOT AVAILABLE craplcx   THEN
                                 DO:
                                     ASSIGN i-cod-erro  = 90.
                                     RETURN.
                                 END.

                            DELETE craplcx.

                            ASSIGN crabbcx.qtcompln = crabbcx.qtcompln - 1
                                   crablot.qtcompln = crablot.qtcompln - 1
                                   crablot.qtinfoln = crablot.qtinfoln - 1
                                   crablot.vlcompdb = crablot.vlcompdb -
                                                      crablcm.vllanmto
                                   crablot.vlinfodb = crablot.vlinfodb -
                                                      crablcm.vllanmto.
                            DELETE crablcm.

                        END.
                    END.
                END.
                ELSE
                /* Se for BB usa a conta ITG para buscar conta migrada */
                /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                IF  crapchd.cdbanchq = 1
                AND crapchd.cdagechq = 3420  THEN DO:
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

                    IF  AVAIL craptco  THEN DO:
                        FIND crablcm WHERE crablcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                           crablcm.dtmvtolt = crapdat.dtmvtocd          AND /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                                           crablcm.cdagenci = craptco.cdagenci          AND
                                           crablcm.cdbccxlt = 100                       AND /* Fixo */
                                           crablcm.nrdolote = 205000 + craptco.cdagenci AND
                                           crablcm.nrdctabb = INTE(crapchd.nrctachq)    AND
                                           crablcm.nrdocmto = i_nro-docto
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAIL crablcm  THEN DO:
                            ASSIGN i-cod-erro = 90.
                            RETURN.
                        END.
                        ELSE DO:
                            /* Este lancamento soh existe quando o deposito eh feito na coop origem da migracao */
                            /* Remover lancamento extra caixa de conta sobreposta */
                            FIND LAST crabbcx WHERE crabbcx.cdcooper = crapcop.cdcooper  AND
                                                    crabbcx.dtmvtolt = crapdat.dtmvtocd  AND /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
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
                                               craplcx.dtmvtolt = crapdat.dtmvtocd AND /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                                               craplcx.cdagenci = p-cod-agencia    AND
                                               craplcx.nrdcaixa = p-nro-caixa      AND
                                               craplcx.cdopecxa = p-cod-operador   AND
                                               craplcx.nrdocmto = INT(STRING(crabfdc.nrcheque,"999999") +
                                                                      STRING(crabfdc.nrdigchq,"9")) AND
                                               craplcx.cdhistor = 704
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF   NOT AVAILABLE craplcx   THEN
                                 DO:
                                     ASSIGN i-cod-erro  = 90.
                                     RETURN.
                                 END.

                            DELETE craplcx.

                            ASSIGN crabbcx.qtcompln = crabbcx.qtcompln - 1
                                   crablot.qtcompln = crablot.qtcompln - 1
                                   crablot.qtinfoln = crablot.qtinfoln - 1
                                   crablot.vlcompdb = crablot.vlcompdb -
                                                      crablcm.vllanmto
                                   crablot.vlinfodb = crablot.vlinfodb -
                                                      crablcm.vllanmto.
                            DELETE crablcm.

                        END.
                    END.
                END.
                ELSE DO:
                    ASSIGN i-cod-erro = 90.
                    RETURN.
                END.
            END.
            ELSE DO:

                ASSIGN crablot.qtcompln = crablot.qtcompln - 1
                       crablot.qtinfoln = crablot.qtinfoln - 1
                       crablot.vlcompdb = crablot.vlcompdb -
                                          crablcm.vllanmto
                       crablot.vlinfodb = crablot.vlinfodb -
                                          crablcm.vllanmto.
                DELETE crablcm.
            END.
        END. /** END  do IF cdhistor = 386 */
        ELSE DO:  /**** Cheque de fora ****/

            RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
            RUN atualiza-previa-caixa  IN h_b1crap00 (INPUT crapcop.nmrescop,
                                                      INPUT p-cod-agencia,
                                                      INPUT p-nro-caixa,
                                                      INPUT p-cod-operador,
                                                      INPUT crapdat.dtmvtocd, /* 08/06/2018 - Alterado para considerar o dtmvtocd - Everton Deserto(AMCOM)*/
                                                      INPUT 2).  /*Estorno*/
            DELETE PROCEDURE h_b1crap00.
        END.

        DELETE crapchd.

    END. /* for each crapchd */

    RETURN "OK".
END PROCEDURE.

/*****************************************************************************/

PROCEDURE estorna-dep-cheque-com-captura:

    DEF INPUT  PARAM p-cooper                AS CHAR NO-UNDO.  /* Coop Origem   */
    DEF INPUT  PARAM p-cod-agencia           AS INT NO-UNDO.   /* Cod. Agencia  */
    DEF INPUT  PARAM p-nro-caixa             AS INT NO-UNDO.   /* Numero Caixa  */
    DEF INPUT  PARAM p-cod-operador          AS CHAR NO-UNDO.  /* Operador Cxa  */
    DEF INPUT  PARAM p-cooper-dest           AS CHAR NO-UNDO.  /* Coop Dest     */
    DEF INPUT  PARAM p-nro-conta             AS INT NO-UNDO.   /* Nro Conta     */
    DEF INPUT  PARAM p-nrdocto               AS INT NO-UNDO.   /* Nro Docmto    */
    DEF INPUT  PARAM p-valor-cooperativa     AS DEC NO-UNDO.   /* Valor Doc     */
    DEF INPUT  PARAM p-vestorno              AS LOG NO-UNDO.   /* YES           */
    DEF INPUT  PARAM p-nrdrowid              AS ROWID NO-UNDO. /* ?             */
    DEF OUTPUT PARAM p-valor                 AS DEC NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_vretorno AS CHAR                                      NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_estorna_dep_chq_captura aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT p-cod-operador,
                          INPUT p-cooper-dest,
                          INPUT p-nro-conta,
                          INPUT p-nrdocto,
                          INPUT p-valor-cooperativa,
                          INPUT INT(STRING(p-vestorno,"1/0")),
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    
    CLOSE STORED-PROC pc_estorna_dep_chq_captura aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN p-valor = 0
           aux_cdcritic        = 0
           aux_dscritic        = ""
           aux_vretorno        = ""
           
           p-valor             = pc_estorna_dep_chq_captura.pr_valor
                               WHEN pc_estorna_dep_chq_captura.pr_valor <> ?
           aux_vretorno        = pc_estorna_dep_chq_captura.pr_retorno
                               WHEN pc_estorna_dep_chq_captura.pr_retorno <> ?
           aux_cdcritic        = pc_estorna_dep_chq_captura.pr_cdcritic
                               WHEN pc_estorna_dep_chq_captura.pr_cdcritic <> ?
           aux_dscritic        = pc_estorna_dep_chq_captura.pr_dscritic
                               WHEN pc_estorna_dep_chq_captura.pr_dscritic <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" OR
       aux_vretorno <> "OK" THEN DO:

       RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT aux_cdcritic,
                       INPUT aux_dscritic,
                       INPUT YES).

       RETURN aux_vretorno. /* NOK */
    END.

    RETURN aux_vretorno. /* OK */

END PROCEDURE.

/*****************************************************************************/



