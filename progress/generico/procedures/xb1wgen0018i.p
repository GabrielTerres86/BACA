/*...................................................................................... 

   Programa: xb1wgen0018i.p                  
   Autor   : Carlos Rafael Tanholi
   Data    : 02/03/2015                      Ultima atualizacao: 11/05/2016

   Dados referentes ao programa:

   Objetivo  : XBO para interacao das rotinas de impressao com o Ayllos WEB

   Alteracoes: 11/05/2016 - Ajustado para utilizar a variavel dtmvtolx na procedure
                            gera-relatorio-lotes, pois a variavel dtmvtolt sempre
							possui a data do sistema (Douglas - Chamado 445477)
   
	           06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
			                da descrição do departamento como parametro e 
							passar o código (Renato Darosci)
......................................................................................*/

/* VARIAVEIS */

DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                        NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_cddepart AS INTE                                        NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                        NO-UNDO.

DEF VAR aux_nrpacori AS INTE                                        NO-UNDO.
DEF VAR aux_nrpacdes AS INTE                                        NO-UNDO.
DEF VAR aux_dtperini AS DATE                                        NO-UNDO.
DEF VAR aux_dtperfim AS DATE                                        NO-UNDO.
DEF VAR aux_cabectra AS CHAR                                        NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                        NO-UNDO.
DEF VAR aux_rowidaux AS ROWID                                       NO-UNDO.

DEF VAR aux_nrcpfcgc AS DECI                                        NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_nrborder AS INTE                                        NO-UNDO.
DEF VAR aux_cdcmpchq AS INTE                                        NO-UNDO.
DEF VAR aux_cdbanchq AS INTE                                        NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                        NO-UNDO.
DEF VAR aux_nrctachq AS DECI                                        NO-UNDO.
DEF VAR aux_nrcheque AS INTE                                        NO-UNDO.
DEF VAR aux_nmcheque AS CHAR                                        NO-UNDO.
DEF VAR aux_auxnmchq AS CHAR                                        NO-UNDO.
DEF VAR aux_auxnrcpf AS DECI                                        NO-UNDO.
DEF VAR aux_dtlibini AS DATE                                        NO-UNDO.
DEF VAR aux_dtlibfim AS DATE                                        NO-UNDO.
DEF VAR aux_vldescto AS DECI                                        NO-UNDO.
DEF VAR aux_dtlibera AS DATE                                        NO-UNDO.
DEF VAR aux_dtcusini AS DATE                                        NO-UNDO.
DEF VAR aux_dtcusfim AS DATE                                        NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                        NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.
DEF VAR aux_vlcheque AS DECI                                        NO-UNDO.
DEF VAR aux_inresgat AS LOGI                                        NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                        NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                        NO-UNDO.
DEF VAR aux_cdctalis AS INTE                                        NO-UNDO.
DEF VAR aux_vlsupinf AS INTE                                        NO-UNDO.
DEF VAR aux_inchqcop AS INTE                                        NO-UNDO.
DEF VAR aux_nrdsenha AS CHAR                                        NO-UNDO.
DEF VAR aux_nvoperad AS INTE                                        NO-UNDO.
DEF VAR aux_tpcheque AS INTE                                        NO-UNDO.
DEF VAR aux_logconta AS LOGI                                        NO-UNDO.
DEF VAR aux_dtmvtini AS DATE                                        NO-UNDO.
DEF VAR aux_dtmvtfim AS DATE                                        NO-UNDO.
DEF VAR aux_nmdopcao AS LOGI                                        NO-UNDO.
DEF VAR aux_flgrelat AS LOGI                                        NO-UNDO.
DEF VAR aux_msgretur AS CHAR                                        NO-UNDO.
DEF VAR aux_tpdsaldo AS INTE                                        NO-UNDO.
DEF VAR aux_cdagelot AS INTE                                        NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                        NO-UNDO.
DEF VAR aux_dsdolote AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdireto AS CHAR                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                        NO-UNDO.
DEF VAR aux_qtregist AS INTE                                        NO-UNDO.
DEF VAR aux_dtmvtolx AS DATE                                        NO-UNDO.

DEF VAR h-b1wgen0018 AS HANDLE                                      NO-UNDO.


/* INCLUDES */
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/* PROCEDURES */


PROCEDURE gera-conferencia-cheques:

    RUN gera-conferencia-cheques IN hBO
                           ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_idorigem,
                             INPUT aux_nmdatela,
                             INPUT aux_cdprogra,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dsiduser,
                             INPUT aux_dtiniper,
                             INPUT aux_dtfimper,
                             INPUT aux_nrdconta,
                             INPUT aux_cdagencx,
                            OUTPUT aux_nmarqimp,
                            OUTPUT aux_nmarqpdf,
                            OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-conferencia-cheques */



PROCEDURE gera-relatorio-lotes:

    RUN gera-relatorio-lotes IN hBO
                           ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_idorigem,
                             INPUT aux_nmdatela,
                             INPUT aux_cdprogra,
                             INPUT aux_dtmvtolx,
                             INPUT aux_cdagencx,
                             INPUT aux_dsiduser,
                            OUTPUT aux_nmarqimp,
                            OUTPUT aux_nmarqpdf,
                            OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-relatorio-lotes */



PROCEDURE gera-cheques-resgatados-geral:

    RUN gera-cheques-resgatados-geral IN hBO
                               ( INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_idorigem,
                                 INPUT aux_nmdatela,
                                 INPUT aux_cdprogra,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_dsiduser,
                                 INPUT aux_dtiniper,
                                 INPUT aux_dtfimper,
                                 INPUT aux_cdctalis,
                                 INPUT aux_vlsupinf,
                                 INPUT aux_inchqcop,
                                OUTPUT aux_nmarqimp,
                                OUTPUT aux_nmarqpdf,
                                OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-cheques-resgatados-geral */


PROCEDURE gera-cheques-resgatados:

    RUN sistema/generico/procedures/b1wgen0018.p
        PERSISTENT SET h-b1wgen0018.

    RUN busca_informacoes_associado IN h-b1wgen0018
                                   (INPUT  aux_cdcooper,
                                    INPUT  0,
                                    INPUT  0,
                                    INPUT  aux_nrdconta,
                                    INPUT  0,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-crapass).
    
    IF  VALID-HANDLE(h-b1wgen0018) THEN
        DELETE PROCEDURE h-b1wgen0018.
    
    IF   RETURN-VALUE = "NOK"   THEN
       DO:
           FIND FIRST tt-erro NO-ERROR.
           IF   AVAIL tt-erro   THEN
                DO:
                    RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
                END.
       END.
    
    FIND tt-crapass NO-ERROR.
    IF   NOT AVAIL tt-crapass   THEN
         DO: 
             HIDE MESSAGE NO-PAUSE.
             RETURN.               
         END.


    RUN gera-cheques-resgatados IN hBO
                              ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_idorigem,
                                INPUT aux_nmdatela,
                                INPUT aux_cdprogra,
                                INPUT aux_dtmvtolt,
                                INPUT aux_dsiduser,
                                INPUT aux_nrdconta,
                                INPUT aux_inresgat,
                                INPUT TABLE tt-crapass,
                               OUTPUT aux_nmarqimp,
                               OUTPUT aux_nmarqpdf,
                               OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-cheques-resgatados */



PROCEDURE gera-relatorio-fechamento:

    RUN gera-relatorio-fechamento IN hBO
                                ( INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT aux_cdprogra,
                                  INPUT aux_dsiduser,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtlibera,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-relatorio-fechamento */


PROCEDURE gera-custodia-cheques:

    RUN sistema/generico/procedures/b1wgen0018.p
        PERSISTENT SET h-b1wgen0018.

    RUN busca_informacoes_associado IN h-b1wgen0018
                                   (INPUT  aux_cdcooper,
                                    INPUT  0,
                                    INPUT  0,
                                    INPUT  aux_nrdconta,
                                    INPUT  0,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-crapass).
    
    IF  VALID-HANDLE(h-b1wgen0018) THEN
        DELETE PROCEDURE h-b1wgen0018.
    
    IF   RETURN-VALUE = "NOK"   THEN
       DO:
           FIND FIRST tt-erro NO-ERROR.
           IF   AVAIL tt-erro   THEN
                DO:
                    RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
                END.
       END.
    
    FIND tt-crapass NO-ERROR.
    IF   NOT AVAIL tt-crapass   THEN
         DO: 
             HIDE MESSAGE NO-PAUSE.
             RETURN.               
         END.

    RUN gera-custodia-cheques IN hBO
                            ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT aux_cdprogra,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrdconta,
                              INPUT aux_dtcusini,
                              INPUT aux_dtcusfim,
                              INPUT aux_inresgat,
                              INPUT aux_dsiduser,
                              INPUT TABLE tt-crapass,
                             OUTPUT aux_nmarqimp,
                             OUTPUT aux_nmarqpdf,
                             OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Custodia_Cheques */


PROCEDURE gera-conferencia-custodia:

    RUN gera-conferencia-custodia IN hBO
                                ( INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT aux_cdprogra,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dsiduser,
                                  INPUT aux_dtiniper,
                                  INPUT aux_dtfimper,
                                  INPUT aux_nrdconta,
                                  INPUT aux_cdagencx,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-conferencia-custodia */


PROCEDURE gera-lotes-custodia:

    RUN gera-lotes-custodia IN hBO
                          ( INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT aux_cdprogra,
                            INPUT aux_dtmvtolt,
                            INPUT aux_dtmvtini,
                            INPUT aux_dtmvtfim,
                            INPUT aux_cdagencx,
                            INPUT aux_nmdopcao,
                            INPUT aux_flgrelat,
                            INPUT aux_dsiduser,
                           OUTPUT aux_nmarqimp,
                           OUTPUT aux_nmarqpdf,
                           OUTPUT aux_msgretur, 
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlAtributo(INPUT "msgretur",INPUT aux_msgretur).
            RUN piXmlSave.
        END.

END PROCEDURE. /* gera-lotes-custodia */


/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        /*MESSAGE "0018i XBO " tt-param.nomeCampo tt-param.valorCampo. */

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "dtmvtolx" THEN aux_dtmvtolx = DATE(tt-param.valorCampo).    

            WHEN "dtperini" THEN aux_dtperini = DATE(tt-param.valorCampo).  
            WHEN "dtperfim" THEN aux_dtperfim = DATE(tt-param.valorCampo).  
            WHEN "nrpacori" THEN aux_nrpacori = INTE(tt-param.valorCampo).
            WHEN "nrpacdes" THEN aux_nrpacdes = INTE(tt-param.valorCampo).
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrborder" THEN aux_nrborder = INTE(tt-param.valorCampo).
            WHEN "cdcmpchq" THEN aux_cdcmpchq = INTE(tt-param.valorCampo).
            WHEN "cdbanchq" THEN aux_cdbanchq = INTE(tt-param.valorCampo).
            WHEN "cdagechq" THEN aux_cdagechq = INTE(tt-param.valorCampo).
            WHEN "nrctachq" THEN aux_nrctachq = DECI(tt-param.valorCampo).
            WHEN "nrcheque" THEN aux_nrcheque = INTE(tt-param.valorCampo).
            WHEN "nmcheque" THEN aux_nmcheque = tt-param.valorCampo.
            WHEN "auxnmchq" THEN aux_auxnmchq = tt-param.valorCampo.
            WHEN "auxnrcpf" THEN aux_auxnrcpf = DECI(tt-param.valorCampo).
            WHEN "dtlibini" THEN aux_dtlibini = DATE(tt-param.valorCampo).
            WHEN "dtlibfim" THEN aux_dtlibfim = DATE(tt-param.valorCampo).
            WHEN "dtlibera" THEN aux_dtlibera = DATE(tt-param.valorCampo).
            WHEN "dtcusini" THEN aux_dtcusini = DATE(tt-param.valorCampo).
            WHEN "dtcusfim" THEN aux_dtcusfim = DATE(tt-param.valorCampo).
            WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "vlcheque" THEN aux_vlcheque = DECI(tt-param.valorCampo).
            WHEN "inresgat" THEN aux_inresgat = LOGICAL(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "cdctalis" THEN aux_cdctalis = INTE(tt-param.valorCampo).
            WHEN "vlsupinf" THEN aux_vlsupinf = INTE(tt-param.valorCampo).
            WHEN "inchqcop" THEN aux_inchqcop = INTE(tt-param.valorCampo).
            WHEN "nrdsenha" THEN aux_nrdsenha = tt-param.valorCampo.
            WHEN "nvoperad" THEN aux_nvoperad = INTE(tt-param.valorCampo).
            WHEN "dtmvtini" THEN aux_dtmvtini = DATE(tt-param.valorCampo).
            WHEN "dtmvtfim" THEN aux_dtmvtfim = DATE(tt-param.valorCampo).
            WHEN "nmdopcao" THEN aux_nmdopcao = LOGICAL(tt-param.valorCampo).
            WHEN "flgrelat" THEN aux_flgrelat = LOGICAL(tt-param.valorCampo).
            WHEN "tpdsaldo" THEN aux_tpdsaldo = INTE(tt-param.valorCampo).
            WHEN "cdagelot" THEN aux_cdagelot = INTE(tt-param.valorCampo).
            WHEN "nrdolote" THEN aux_nrdolote = INTE(tt-param.valorCampo).
            WHEN "dsdolote" THEN aux_dsdolote = tt-param.valorCampo.
            WHEN "tpcheque" THEN aux_tpcheque = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).

                
                
                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/


    FOR EACH tt-param-i 
         BREAK BY tt-param-i.nomeTabela
               BY tt-param-i.sqControle:

         CASE tt-param-i.nomeTabela:

             WHEN "Cheques" THEN DO:

                 IF  FIRST-OF(tt-param-i.sqControle) THEN
                     DO:
                        CREATE crawlot.
                        ASSIGN aux_rowidaux = ROWID(crawlot).
                     END.

                 FIND crawlot WHERE ROWID(crawlot) = aux_rowidaux NO-ERROR.

                 CASE tt-param-i.nomeCampo:
                     WHEN "indrelat" THEN
                          crawlot.indrelat = INTE(tt-param-i.valorCampo).
                     WHEN "dtmvtolt" THEN
                          crawlot.dtmvtolt = DATE(tt-param-i.valorCampo).
                     WHEN "cdagenci" THEN
                          crawlot.cdagenci = INTE(tt-param-i.valorCampo).
                     WHEN "nrdconta" THEN
                          crawlot.nrdconta = INTE(tt-param-i.valorCampo).
                     WHEN "nrborder" THEN
                          crawlot.nrborder = INTE(tt-param-i.valorCampo).
                     WHEN "nrdolote" THEN
                          crawlot.nrdolote = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqcop" THEN
                          crawlot.qtchqcop = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqmen" THEN
                          crawlot.qtchqmen = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqmai" THEN
                          crawlot.qtchqmai = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqtot" THEN
                          crawlot.qtchqtot = INTE(tt-param-i.valorCampo).
                     WHEN "vlchqcop" THEN
                          crawlot.vlchqcop = DECI(tt-param-i.valorCampo).
                     WHEN "vlchqmen" THEN
                          crawlot.vlchqmen = DECI(tt-param-i.valorCampo).
                     WHEN "vlchqmai" THEN
                          crawlot.vlchqmai = DECI(tt-param-i.valorCampo).
                     WHEN "vlchqtot" THEN
                          crawlot.vlchqtot = DECI(tt-param-i.valorCampo).
                     WHEN "nmoperad" THEN
                          crawlot.nmoperad = tt-param-i.valorCampo.
                     WHEN "dtlibera" THEN
                          crawlot.dtlibera = DATE(tt-param-i.valorCampo).
                     WHEN "cdbccxlt" THEN
                          crawlot.cdbccxlt = INTE(tt-param-i.valorCampo).
                     WHEN "qtcompln" THEN
                          crawlot.qtcompln = INTE(tt-param-i.valorCampo).
                     WHEN "vlcompdb" THEN
                          crawlot.vlcompdb = DECI(tt-param-i.valorCampo).
                 END CASE.

                 

                 
             END.

         END CASE.
     END.

END PROCEDURE.
