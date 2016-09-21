/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0142.p
     Autor   : Gabriel Capoia
     Data    : Novembro/2012                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela CONINF

     Alteracoes: 

............................................................................*/



/*..........................................................................*/

DEF VAR aux_cdcooper  AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela  AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem  AS INTE                                        NO-UNDO.
DEF VAR aux_cdprogra  AS CHAR                                        NO-UNDO.

DEF VAR aux_nmcooper  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmtpdcto  AS CHAR                                        NO-UNDO.
DEF VAR aux_dsdircop  AS CHAR                                        NO-UNDO.

DEF VAR aux_dsiduser  AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcoopea  AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenca  AS INTE                                        NO-UNDO.
DEF VAR aux_tpdocmto  AS INTE                                        NO-UNDO.
DEF VAR aux_indespac  AS INTE                                        NO-UNDO.
DEF VAR aux_cdfornec  AS INTE                                        NO-UNDO.
DEF VAR aux_dtmvtola  AS DATE                                        NO-UNDO.
DEF VAR aux_dtmvtol2  AS DATE                                        NO-UNDO.
DEF VAR aux_tpdsaida  AS LOGI                                        NO-UNDO.
DEF VAR aux_nrregist  AS INTE                                        NO-UNDO.
DEF VAR aux_nriniseq  AS INTE                                        NO-UNDO.
DEF VAR aux_nmdcampo  AS CHAR                                        NO-UNDO.

DEF VAR aux_qtregist  AS INTE                                        NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0142tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper"  THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci"  THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa"  THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad"  THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela"  THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "cdprogra"  THEN aux_cdprogra = tt-param.valorCampo.
             WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "cdcoopea"  THEN aux_cdcoopea = INTE(tt-param.valorCampo).
             WHEN "cdagenca"  THEN aux_cdagenca = INTE(tt-param.valorCampo).
             WHEN "tpdocmto"  THEN aux_tpdocmto = INTE(tt-param.valorCampo).
             WHEN "indespac"  THEN aux_indespac = INTE(tt-param.valorCampo).
             WHEN "cdfornec"  THEN aux_cdfornec = INTE(tt-param.valorCampo).
             WHEN "dtmvtola"  THEN aux_dtmvtola = DATE(tt-param.valorCampo).
             WHEN "dtmvtol2"  THEN aux_dtmvtol2 = DATE(tt-param.valorCampo).

             WHEN "tpdsaida"  THEN aux_tpdsaida = (IF   tt-param.valorCampo = "A" THEN
                                                       TRUE
                                                  ELSE FALSE).

             WHEN "nrregist"  THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq"  THEN aux_nriniseq = INTE(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

 /* ------------------------------------------------------------------------ */
 /*                    EFETUA A BUSCA DA TELA SAISPC                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Carrega_Tela:

    RUN Carrega_Tela IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                   OUTPUT aux_nmcooper, 
                   OUTPUT aux_nmtpdcto, 
                   OUTPUT aux_dsdircop,
                   OUTPUT TABLE tt-crapcop,
                   OUTPUT TABLE tt-tpodcto,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapcop:HANDLE,
                            INPUT "Cooperativas").
           RUN piXmlAtributo (INPUT "dsdircop", INPUT aux_dsdircop).
           RUN piXmlExport (INPUT TEMP-TABLE tt-tpodcto:HANDLE,
                            INPUT "Documentos").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Carrega_Tela */

/* ------------------------------------------------------------------------ */
 /*                    EFETUA A BUSCA DA TELA SAISPC                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_idorigem,
                    INPUT aux_nmdatela,
                    INPUT aux_dsiduser,
                    INPUT aux_cdcoopea,
                    INPUT aux_cdagenca,
                    INPUT aux_tpdocmto,
                    INPUT aux_indespac,
                    INPUT aux_cdfornec,
                    INPUT aux_dtmvtola,
                    INPUT aux_dtmvtol2,
                    INPUT aux_tpdsaida,
                    INPUT aux_nrregist,
                    INPUT aux_nriniseq,
                    INPUT TRUE, /* flgerlog */
                   OUTPUT aux_qtregist,
                   OUTPUT aux_nmdcampo,
                   OUTPUT TABLE tt-crapinf,
                   OUTPUT TABLE tt-crapinf-aux,
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
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
            
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapinf-aux:HANDLE,
                            INPUT "Informacao").
           RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */
