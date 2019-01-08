/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0145.p
     Autor   : Gabriel Capoia
     Data    : 07/01/2013                    Ultima atualizacao: 19/03/2015

     Objetivo  : BO de Comunicacao XML x BO - Tela MANCCF

     Alteracoes: 
     
     19/03/2015 #255079 Inclusao da procedure Refaz_Regulariza para permitir
                reenviar o cheque para regularizacao. Gravando log para 
                verlog (Carlos)

............................................................................*/



/*..........................................................................*/

DEF VAR aux_cdcooper  AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela  AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem  AS INTE                                        NO-UNDO.
DEF VAR aux_cdprogra  AS CHAR                                        NO-UNDO.
DEF VAR aux_dsiduser  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdconta  AS INTE                                        NO-UNDO.
DEF VAR aux_nrseqdig  AS INTE                                        NO-UNDO.
DEF VAR aux_idseqttl  AS INTE                                        NO-UNDO.
DEF VAR aux_nmoperad  AS CHAR                                        NO-UNDO.
DEF VAR aux_dtfimest  AS DATE                                        NO-UNDO.
DEF VAR aux_flgctitg  AS INTE                                        NO-UNDO.
DEF VAR aux_dsseqdig  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrcheque  AS INTE                                        NO-UNDO.
DEF VAR aux_vlcheque  AS DECI                                        NO-UNDO.

DEF VAR aux_nmprimtl  AS CHAR                                        NO-UNDO.
DEF VAR aux_msgconfi  AS CHAR                                        NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0143tt.i }

/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            
            WHEN "cdcooper"  THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci"  THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa"  THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad"  THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela"  THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "dtmvtolt"  THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dtmvtopr"  THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdprogra"  THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "dsseqdig"  THEN aux_dsseqdig = tt-param.valorCampo.
            WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "nmarqimp"  THEN aux_nmarqimp = tt-param.valorCampo.
            WHEN "nmarqpdf"  THEN aux_nmarqpdf = tt-param.valorCampo.
            WHEN "nrdconta"  THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrseqdig"  THEN aux_nrseqdig = INTE(tt-param.valorCampo).
            WHEN "idseqttl"  THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmoperad"  THEN aux_nmoperad = tt-param.valorCampo.
            WHEN "dtfimest"  THEN aux_dtfimest = DATE(tt-param.valorCampo).
            WHEN "flgctitg"  THEN aux_flgctitg = INTE(tt-param.valorCampo).
            WHEN "nrcheque"  THEN aux_nrcheque = INTE(tt-param.valorCampo).
            WHEN "vlcheque"  THEN aux_vlcheque = DECI(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                         EFETUA A BUSCA MANUTENCAO DO CCF                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_idorigem,
                    INPUT aux_nmdatela,
                    INPUT aux_dtmvtolt,
                    INPUT aux_nrdconta,
                    INPUT TRUE, /* flgerlog */
                   OUTPUT aux_nmprimtl, 
                   OUTPUT TABLE cratneg,
                   OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE cratneg:HANDLE,
                            INPUT "Manutencao").
            RUN piXmlAtributo (INPUT "nmprimtl", INPUT aux_nmprimtl).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*                         EFETUA A BUSCA DOS TITULARES                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Titular:

    RUN Busca_Titular IN hBO
                    ( INPUT aux_cdcooper, 
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_idorigem,
                      INPUT aux_nmdatela,
                      INPUT aux_nrdconta,
                      INPUT TRUE, /* flgerlog */
                     OUTPUT TABLE cratttl,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE cratttl:HANDLE,
                             INPUT "Titular").
            RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Titular */

/* ------------------------------------------------------------------------- */
/*               REALIZA A GRAVACAO DOS DADOS DA OPCAO TITULAR               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Titular:

    RUN Grava_Titular IN hBO
                    ( INPUT aux_cdcooper, 
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_nrdconta,
                      INPUT aux_nrseqdig,
                      INPUT aux_idseqttl,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Titular */

/* ------------------------------------------------------------------------- */
/*             REALIZA A GRAVACAO DOS DADOS DA OPCAO REGULARIZAR             */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Regulariza:

    RUN Grava_Regulariza IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_idorigem,
                         INPUT aux_dtmvtolt,
                         INPUT aux_nrdconta,
                         INPUT aux_nrseqdig,
                         INPUT aux_nmoperad,
                         INPUT aux_dtfimest,
                         INPUT aux_flgctitg,
                        OUTPUT aux_msgconfi, 
                        OUTPUT aux_nmoperad, 
                        OUTPUT aux_dtfimest,
                        OUTPUT aux_flgctitg,
                        OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgconfi", INPUT aux_msgconfi).
            RUN piXmlAtributo (INPUT "nmoperad", INPUT aux_nmoperad).
            RUN piXmlAtributo (INPUT "dtfimest", INPUT STRING(aux_dtfimest,'99/99/9999')).
            RUN piXmlAtributo (INPUT "flgctitg", INPUT aux_flgctitg).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Regulariza */

/* ------------------------------------------------------------------------- */
/*             REALIZA O REENVIO DA REGULARIZACAO                            */
/* ------------------------------------------------------------------------- */
PROCEDURE Refaz_Regulariza:

    RUN Refaz_Regulariza IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_idorigem,
                         INPUT aux_dtmvtolt,
                         INPUT aux_nrdconta,
                         INPUT aux_nrseqdig,
                         INPUT aux_nmoperad,
                         INPUT aux_dtfimest,
                         INPUT aux_flgctitg,
                        OUTPUT aux_msgconfi, 
                        OUTPUT aux_nmoperad, 
                        OUTPUT aux_dtfimest,
                        OUTPUT aux_flgctitg,
                        OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgconfi", INPUT aux_msgconfi).
            RUN piXmlAtributo (INPUT "nmoperad", INPUT aux_nmoperad).
            RUN piXmlAtributo (INPUT "dtfimest", INPUT STRING(aux_dtfimest,'99/99/9999')).
            RUN piXmlAtributo (INPUT "flgctitg", INPUT aux_flgctitg).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Refaz_Regulariza */

PROCEDURE Inclui_CCF:

    RUN Inclui_CCF IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_nrdconta,
                         INPUT aux_nrcheque,
                         INPUT aux_vlcheque,
                         INPUT aux_cdoperad,
                         INPUT aux_dtmvtolt,
                         INPUT aux_nmoperad,
                         INPUT aux_dtfimest,
                         INPUT aux_flgctitg,
                        OUTPUT aux_msgconfi, 
                        OUTPUT aux_nmoperad, 
                        OUTPUT aux_dtfimest,
                        OUTPUT aux_flgctitg,
                        OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel incluir no " +
                                              "CCF o cheque selecionado.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgconfi", INPUT aux_msgconfi).
            RUN piXmlAtributo (INPUT "nmoperad", INPUT aux_nmoperad).
            RUN piXmlAtributo (INPUT "dtfimest", INPUT STRING(aux_dtfimest,'99/99/9999')).
            RUN piXmlAtributo (INPUT "flgctitg", INPUT aux_flgctitg).
            RUN piXmlSave.
        END.

END PROCEDURE. /* inclui_CCF */

/* ------------------------------------------------------------------------- */
/*                           GERA IMPRESSÃO DAS CARTAS                       */
/* ------------------------------------------------------------------------- */
PROCEDURE Imprime_Carta:

    RUN Imprime_Carta IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_dtmvtolt,
                      INPUT aux_idorigem,
                      INPUT aux_nrdconta,
                      INPUT aux_dsseqdig,
                      INPUT aux_dsiduser,
                      INPUT TRUE, /* flgerlog */
                     OUTPUT aux_nmarqimp, 
                     OUTPUT aux_nmarqpdf, 
                     OUTPUT TABLE tt-nmarqimp,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Imprime_Carta */
