/* ............................................................................

   Programa: Fontes/crps589.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Abril/2013                        Ultima atualizacao: 19/01/2017
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Importar arquivo de débito das parcelas de empréstimos do BNDES.
               Gera arquivo de retorno para o sistema TOTVS.

   Alteracao : 16/04/2014 - Incluida descricao "CRE" no final da linha de 
                            detalhe do arquivo de retorno, devido alteracao de 
                            layout da TOTVS (Diego).
                            
               18/06/2014 - Removida validacao da data do header do arquivo
                            'TEIMOSINHA*'. (Fabricio)
                            
               06/04/2015 - Informar sempre '2'(nao complementar) no arquivo de
                            retorno (Diego).
                            
               13/05/2015 - Incluido "2> /dev/null" no comando "mv" (Diego).                         

               18/11/2015 - Ajustes para que o crps utilize a rotina de
                            obtem-saldo-dia do Oracle (Douglas - Chamado 285228)

			   19/01/2017 - Ajuste no formato do campo Nosso Numero (Diego).

               24/04/2017 - Nao considerar valores bloqueados na composicao do saldo disponivel
                            Heitor (Mouts) - Melhoria 440

               11/06/2018 - Ajuste para usar procedure que centraliza lancamentos na CRAPLCM 
                            [gerar_lancamento_conta_comple]. (PRJ450 - Teobaldo J - AMcom)

............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF STREAM str_1.

DEF TEMP-TABLE tt-saldos NO-UNDO LIKE crapsda
    FIELD vlblqtaa AS DECI
    FIELD vlstotal AS DECI 
    FIELD vlsaqmax AS DECI 
    FIELD vlacerto AS DECI 
    FIELD dslimcre AS CHAR 
    FIELD vlipmfpg AS DECI 
    FIELD dtultlcr LIKE crapass.dtultlcr.

DEF TEMP-TABLE tt-dados-retorno NO-UNDO
    FIELD cdunidad AS INTE
    FIELD nrdconta AS INTE
    FIELD cdhistor AS INTE
    FIELD cdcomple AS CHAR
    FIELD nrdocmto AS INTE
    FIELD vllanmto AS DECI
    FIELD chavcred AS DECI.

DEF VAR aux_nmarquiv AS CHAR                NO-UNDO.
DEF VAR aux_nmarqdeb AS CHAR FORMAT "X(97)" NO-UNDO.

DEF VAR aux_tpregist AS CHAR                NO-UNDO.
DEF VAR aux_cdunidad AS INTE                NO-UNDO.
DEF VAR aux_nrdconta AS INTE                NO-UNDO.
DEF VAR aux_compleme AS CHAR                NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                NO-UNDO.
DEF VAR aux_cdhistor AS INTE                NO-UNDO.
DEF VAR aux_vldebito AS DECI                NO-UNDO.
DEF VAR aux_vlrjuros AS DECI                NO-UNDO.
DEF VAR aux_nossonum AS DECI                NO-UNDO.
DEF VAR aux_nrsequen AS INTE                NO-UNDO.

DEF VAR aux_vlsddisp AS DECI                NO-UNDO.
DEF VAR aux_vldebtot AS DECI                NO-UNDO.
DEF VAR aux_valorpag AS DECI                NO-UNDO.

ASSIGN glb_cdprogra = "crps589".

RUN fontes/iniprg.p.

IF glb_cdcritic <> 0 THEN
    RETURN.

 /*-------------------------  Busca dados da cooperativa --------------------*/
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN "NOK".
     END.
                                  
glb_nrctares = 0.

ASSIGN aux_nmarquiv = "/micros/cecred/bndes/recepcao/" +
                      "TEIMOSINHA" + STRING(DAY(glb_dtmvtolt), "99") +
                      STRING(MONTH(glb_dtmvtolt), "99") + "." +
                      STRING(crapcop.cdcooper, "999").

IF SEARCH(aux_nmarquiv) = ? THEN
DO:
    RUN fontes/fimprg.p.
    RETURN.
END.

RUN importa-arquivo-debito (INPUT aux_nmarquiv).

INPUT STREAM str_1 CLOSE.

FIND FIRST tt-dados-retorno NO-LOCK NO-ERROR.

IF AVAIL tt-dados-retorno THEN
    RUN gera-arquivo-retorno-totvs (INPUT TABLE tt-dados-retorno).

RUN fontes/fimprg.p.

/*****************************************************************************/

PROCEDURE importa-arquivo-debito:

    DEF INPUT PARAM par_nmarqdeb AS CHAR NO-UNDO.

    DEF VAR aux_dtmvtolt AS DATE NO-UNDO.
    DEF VAR aux_setlinha AS CHAR NO-UNDO.

    DEF VAR aux_cdcritic LIKE crapcri.cdcritic NO-UNDO.
    DEF VAR aux_dscritic LIKE crapcri.dscritic NO-UNDO.

    INPUT STREAM str_1 FROM VALUE(par_nmarqdeb) NO-ECHO.

    /* Leitura do header do arquivo. */
    IMPORT STREAM str_1 UNFORMATTED aux_setlinha .

    IF SUBSTR(aux_setlinha, 1, 1) <> "H" THEN
    DO:
        ASSIGN glb_cdcritic = 21.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").

        RETURN "NOK".
    END.
    /*
    ASSIGN aux_dtmvtolt = DATE(INTE(SUBSTR(aux_setlinha, 6, 2)),
                               INTE(SUBSTR(aux_setlinha, 8, 2)),
                               INTE(SUBSTR(aux_setlinha, 2, 4)))
           aux_nrsequen = INTE(SUBSTR(aux_setlinha, 92, 06)).

    IF aux_dtmvtolt <> glb_dtmvtolt THEN
    DO:
        ASSIGN glb_cdcritic = 789.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").

        RETURN "NOK".
    END.
    */
    /* Le linha a linha do arquivo. */
    DO TRANSACTION WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

        IF SUBSTR(aux_setlinha, 1, 1) <> "D" THEN
            LEAVE.

        ASSIGN aux_tpregist =      SUBSTR(aux_setlinha, 01, 01)
               aux_cdunidad = INTE(SUBSTR(aux_setlinha, 02, 04))
               aux_nrdconta = INTE(SUBSTR(aux_setlinha, 10, 10))
               aux_compleme =      SUBSTR(aux_setlinha, 20, 01)
               aux_nrdocmto = INTE(SUBSTR(aux_setlinha, 21, 06))
               aux_cdhistor = INTE(SUBSTR(aux_setlinha, 27, 04))
               aux_vldebito = DECI(SUBSTR(aux_setlinha, 31, 18)) / 100
               aux_vlrjuros = DECI(SUBSTR(aux_setlinha, 49, 18)) / 100
               aux_nossonum = DECI(SUBSTR(aux_setlinha, 67, 12))

               aux_vldebtot = aux_vldebito + aux_vlrjuros.

        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                           crapass.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapass THEN
        DO:
            ASSIGN glb_cdcritic = 9.
            RUN fontes/critic.p.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")  +
                              " - " + glb_cdprogra + "' --> '"   +
                              glb_dscritic + "' - Conta/dv: '"   +
                              STRING(aux_nrdconta, "zzzz,zzz,9") + 
                              " >> log/proc_batch.log").

            NEXT.
        END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

        /* Utilizar o tipo de busca A, para carregar do dia anterior
          (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
        RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT glb_cdcooper,
                                     INPUT glb_cdagenci,
                                     INPUT 1, /* nrdcaixa */
                                     INPUT glb_cdoperad, 
                                     INPUT aux_nrdconta,
                                     INPUT glb_dtmvtolt,
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
               IF  aux_dscritic = "" THEN
                   ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".
                
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '"  +
                                 aux_dscritic + " >> log/proc_batch.log").
               RETURN "NOK".
           END.
    
        FIND FIRST wt_saldos NO-LOCK NO-ERROR.
        IF AVAIL wt_saldos THEN
        DO:
            ASSIGN aux_vlsddisp = wt_saldos.vlsddisp + wt_saldos.vlsdchsl + 
                                  wt_saldos.vllimcre.
        END.

        /* Quando existir juros na parcela, o cooperado devera ter saldo para 
           debitar no minimo o valor do juros + algum valor da parcela */ 
        
        IF aux_vlsddisp > aux_vlrjuros THEN
        DO:
            IF (aux_vldebtot) > aux_vlsddisp THEN
                ASSIGN aux_valorpag = aux_vlsddisp.
            ELSE
                ASSIGN aux_valorpag = aux_vldebtot.

            /* Se possui saldo, entao cria lancamento de debito */
            RUN cria-lancamento-debito(INPUT glb_cdcooper,
                                       INPUT 1, /*cdagenci */
                                       INPUT 10124, /* nrdolote */
                                       INPUT 100, /* cdbccxlt */
                                       INPUT 1, /* tplotmov */
                                       INPUT glb_dtmvtolt,
                                       INPUT 1225, /* cdhistor */
                                       INPUT glb_cdoperad,
                                       INPUT aux_nrdconta,
                                       INPUT aux_valorpag).

            IF RETURN-VALUE = "OK" THEN
            DO:
                RUN grava-dados-retorno (INPUT aux_cdunidad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_cdhistor,
                                         INPUT aux_compleme,
                                         INPUT aux_nrdocmto,
                                         INPUT aux_valorpag,
                                         INPUT aux_nossonum).

            END.

        END.
    END.

    UNIX SILENT VALUE("mv " + par_nmarqdeb + 
                      " /usr/coop/" + crapcop.dsdircop + "/salvar/" + 
                      "TEIMOSINHA" + STRING(DAY(glb_dtmvtolt), "99") +
                      STRING(MONTH(glb_dtmvtolt), "99") + "." +
                      STRING(crapcop.cdcooper, "999") + " 2> /dev/null").
  
END PROCEDURE.

PROCEDURE cria-lancamento-debito:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE NO-UNDO.
    DEF INPUT PARAM par_tplotmov AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.

    /* Variaveis para rotina de lancamento craplcm */
    DEF VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
    DEF VAR aux_incrineg AS INT     NO-UNDO.
    DEF VAR aux_cdcritic AS INT     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR    NO-UNDO.

    
    /* 11/06/20108 - TJ - Incluida condicao que verifica se pode realizar o debito */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
        /* Responsavel por alimentar registro de lote do lancamento */
        FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                           craplot.dtmvtolt = par_dtmvtolt AND
                           craplot.cdagenci = par_cdagenci AND
                           craplot.cdbccxlt = par_cdbccxlt AND
                           craplot.nrdolote = par_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF  NOT AVAIL craplot THEN
            DO:
                IF  LOCKED craplot THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                         CREATE craplot.
                         ASSIGN craplot.cdcooper = par_cdcooper
                                craplot.dtmvtolt = par_dtmvtolt
                                craplot.cdagenci = par_cdagenci
                                craplot.cdbccxlt = par_cdbccxlt
                                craplot.nrdolote = par_nrdolote
                                craplot.tplotmov = par_tplotmov
                                craplot.cdoperad = par_cdoperad.
                    END.
            END.
               
        ASSIGN craplot.vlinfodb = craplot.vlinfodb + par_vllanmto
               craplot.vlcompdb = craplot.vlcompdb + par_vllanmto
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1.

        /* Responsavel por criar lancamento em conta corrente */
        FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                                 craplcm.nrdconta = par_nrdconta AND
                                 craplcm.dtmvtolt = par_dtmvtolt AND
                                 craplcm.cdhistor = par_cdhistor AND
                                 craplcm.nrdocmto = craplot.nrseqdig
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craplcm THEN
            DO:
                IF  LOCKED craplcm THEN
                    DO: 
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                            
                        /* 11/06/2018 - TJ - BLOCO DA INSERÇAO DA CRAPLCM */
                        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                            (INPUT craplot.dtmvtolt                     /* par_dtmvtolt */
                            ,INPUT par_cdagenci                         /* par_cdagenci */
                            ,INPUT par_cdbccxlt                         /* par_cdbccxlt */
                            ,INPUT par_nrdolote                         /* par_nrdolote */
                            ,INPUT par_nrdconta                         /* par_nrdconta */
                            ,INPUT craplot.nrseqdig                     /* par_nrdocmto */
                            ,INPUT par_cdhistor                         /* par_cdhistor */
                            ,INPUT craplot.nrseqdig                     /* par_nrseqdig */
                            ,INPUT par_vllanmto                         /* par_vllanmto */
                            ,INPUT par_nrdconta                         /* par_nrdctabb */
                            ,INPUT ""                                   /* par_cdpesqbb */
                            ,INPUT 0                                    /* par_vldoipmf */
                            ,INPUT 0                                    /* par_nrautdoc */
                            ,INPUT craplot.nrseqdig                     /* par_nrsequni */
                            ,INPUT 0                                    /* par_cdbanchq */
                            ,INPUT 0                                    /* par_cdcmpchq */
                            ,INPUT 0                                    /* par_cdagechq */
                            ,INPUT 0                                    /* par_nrctachq */
                            ,INPUT 0                                    /* par_nrlotchq */
                            ,INPUT 0                                    /* par_sqlotchq */
                            ,INPUT craplot.dtmvtolt                     /* par_dtrefere */
                            ,INPUT TIME                                 /* par_hrtransa */
                            ,INPUT par_cdoperad                         /* par_cdoperad */
                            ,INPUT 0                                    /* par_dsidenti */
                            ,INPUT par_cdcooper                         /* par_cdcooper */
                            ,INPUT ""                                   /* par_nrdctitg */
                            ,INPUT ""                                   /* par_dscedent */
                            ,INPUT 0                                    /* par_cdcoptfn */
                            ,INPUT 0                                    /* par_cdagetfn */
                            ,INPUT 0                                    /* par_nrterfin */
                            ,INPUT 0                                    /* par_nrparepr */
                            ,INPUT 0                                    /* par_nrseqava */
                            ,INPUT 0                                    /* par_nraplica */
                            ,INPUT 0                                    /* par_cdorigem */
                            ,INPUT 0                                    /* par_idlautom */
                            /* CAMPOS OPCIONAIS DO LOTE                                                                  */ 
                            ,INPUT 0                                    /* Processa lote                                 */
                            ,INPUT 0                                    /* Tipo de lote a movimentar                     */
                            /* CAMPOS DE SAIDA                                                                           */                                            
                            ,OUTPUT TABLE tt-ret-lancto                 /* Collection que contém o retorno do lançamento */
                            ,OUTPUT aux_incrineg                        /* Indicador de crítica de negócio               */
                            ,OUTPUT aux_cdcritic                        /* Código da crítica                             */
                            ,OUTPUT aux_dscritic).                      /* Descriçao da crítica                          */
                            
                        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                            DO:   
                                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                        " - " + glb_cdprogra + "' --> '"  +
                                                aux_dscritic + "' - Conta/dv: '"          +
                                                STRING(par_nrdconta, "zzzz,zzz,9")        + 
                                                " >> log/proc_batch.log").

                                    /* 11/06/2018 - TJ -Apagar handle associado */
                                    IF  VALID-HANDLE(h-b1wgen0200) THEN
                                        DELETE PROCEDURE h-b1wgen0200.

                                    RETURN "NOK".
                            END.
                        ELSE 
                            /* 11/06/2018 - TJ - Apagar handle associado se nao houve erro */
                            IF VALID-HANDLE(h-b1wgen0200) THEN
                                DELETE PROCEDURE h-b1wgen0200.
                                      
                    END.   /* fim nao LOCKED */
            END.
        ELSE
            DO:
                ASSIGN glb_cdcritic = 92.
                RUN fontes/critic.p.

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + "' - Conta/dv: '"          +
                          STRING(par_nrdconta, "zzzz,zzz,9")        + 
                          " >> log/proc_batch.log").

                /* 11/06/2018 - TJ - Apagar handle associado antes do While */
                IF  VALID-HANDLE(h-b1wgen0200) THEN
                    DELETE PROCEDURE h-b1wgen0200.

                RETURN "NOK".
            END.

        LEAVE.

    END. /* fim do while true */

    /* 11/06/2018 - TJ - Apagar handle associado antes do While */
    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.

    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-dados-retorno:

    DEF INPUT PARAM par_cdunidad AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdcomple AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.
    DEF INPUT PARAM par_chavcred AS DECI NO-UNDO.

    CREATE tt-dados-retorno.
    ASSIGN tt-dados-retorno.cdunidad = par_cdunidad
           tt-dados-retorno.nrdconta = par_nrdconta
           tt-dados-retorno.cdhistor = par_cdhistor
           tt-dados-retorno.cdcomple = par_cdcomple
           tt-dados-retorno.nrdocmto = par_nrdocmto
           tt-dados-retorno.vllanmto = par_vllanmto
           tt-dados-retorno.chavcred = par_chavcred.

END PROCEDURE.

PROCEDURE gera-arquivo-retorno-totvs:
    
    DEF INPUT PARAM TABLE FOR tt-dados-retorno.

    DEF VAR aux_nmarqret AS CHAR NO-UNDO.
    DEF VAR aux_qtdregis AS INTE NO-UNDO.

    ASSIGN aux_nmarqret = "/usr/coop/" + crapcop.dsdircop + "/salvar/" +
                          "VOLTA_TEIMO" +
                          STRING(DAY(glb_dtmvtolt), "99") +
                          STRING(MONTH(glb_dtmvtolt), "99") + "." +
                          STRING(crapcop.cdcooper, "999")
           aux_qtdregis = 0.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqret).

    /* imprime header do arquivo */
    PUT STREAM str_1 UNFORMATTED "1"   +
                                 STRING(YEAR(glb_dtmvtolt),"9999") + 
                                 STRING(MONTH(glb_dtmvtolt),"99") +
                                 STRING(DAY(glb_dtmvtolt),"99")
                                 FILL(" ",79) + 
                                 STRING(aux_nrsequen,"999999") 
                                 SKIP.

    /* imprime detalhe do arquivo */
    FOR EACH tt-dados-retorno NO-LOCK:

        PUT STREAM str_1 UNFORMATTED "01"                                      +
                                     STRING(tt-dados-retorno.cdunidad, "9999") +
                                     "    "                                    +
                                     STRING(tt-dados-retorno.nrdconta, 
                                                                 "9999999999") +
                                     "2" +  /** Por solicitacao da TOTVS **/
                                     /*****
                                     STRING(tt-dados-retorno.cdcomple, "9")    +
                                     *****/
                                     STRING(tt-dados-retorno.cdhistor, "9999") +
                                     "  "                                      +
                                     STRING(tt-dados-retorno.nrdocmto, 
                                                                     "999999") +
                                     STRING(tt-dados-retorno.vllanmto * 100, 
                                                            "999999999999999") +
                                     "   "                                     +
                                     STRING(tt-dados-retorno.chavcred, 
                                                            "999999999999")    +
                                     "000000000000000" + 
                                     "CRE" SKIP.

        ASSIGN aux_qtdregis = aux_qtdregis + 1.
                         
    END.

    /* imprime trailler do arquivo */
    PUT STREAM str_1 UNFORMATTED "99" +
                                 STRING(aux_qtdregis, "99999") SKIP.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("ux2dos " + aux_nmarqret + " >" +
                      " /micros/cecred/bndes/retorno/VOLTA_TEIMOSINHA" +
                      STRING(DAY(glb_dtmvtolt), "99") +
                      STRING(MONTH(glb_dtmvtolt), "99") + "." +
                      STRING(crapcop.cdcooper, "999")).


END PROCEDURE.

