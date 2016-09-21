/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0144.p
     Autor   : Gabriel Capoia
     Data    : 07/01/2013                    Ultima atualizacao: 27/06/2014

     Objetivo  : BO de Comunicacao XML x BO - Tela PESQDP

     Alteracoes: 27/06/2014 - Adicionada procedure Gera_Relatorio_Devolvidos.
                              (Reinert)
                              
                 14/08/2015 - Removidos todos os campos da tela menos os campos
 				     		  Data do Deposito e Valor do cheque. Adicionado novos 
                              campos para filtro, numero de conta e numero de 
                              cheque, conforme solicitado na melhoria 300189 (Kelvin)                            

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
DEF VAR aux_nrregist  AS INTE                                        NO-UNDO.
DEF VAR aux_nriniseq  AS INTE                                        NO-UNDO.
DEF VAR aux_qtregist  AS INTE                                        NO-UNDO.
DEF VAR aux_nrcampo1  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrcampo2  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrcampo3  AS CHAR                                        NO-UNDO.
DEF VAR aux_dtmvtola  AS DATE                                        NO-UNDO.
DEF VAR aux_tipocons  AS LOGI                                        NO-UNDO.
DEF VAR aux_vlcheque  AS DECI                                        NO-UNDO.
DEF VAR aux_nrcheque  AS DECI FORMAT "zzzzzzzzzz"                    NO-UNDO.
DEF VAR aux_nrdconta  AS INTE                                        NO-UNDO.
DEF VAR aux_dsdocmc7  AS CHAR                                        NO-UNDO.
DEF VAR aux_cdbccxlt  AS CHAR                                        NO-UNDO.
DEF VAR aux_dtmvtini  AS DATE                                        NO-UNDO.
DEF VAR aux_dtmvtfim  AS DATE                                        NO-UNDO.
DEF VAR aux_nmdcampo  AS CHAR                                        NO-UNDO.
DEF VAR aux_tpdsaida  AS CHAR                                        NO-UNDO.
DEF VAR aux_dtdevolu  AS DATE                                        NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0144tt.i }

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
             
             WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarqimp"  THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf"  THEN aux_nmarqpdf = tt-param.valorCampo.
             WHEN "dtmvtola"  THEN aux_dtmvtola = DATE(tt-param.valorCampo).
             WHEN "tipocons"  THEN aux_tipocons = (IF  tt-param.valorCampo = "V" THEN
                                                       TRUE  
                                                  ELSE FALSE).
             WHEN "vlcheque"  THEN aux_vlcheque = DECI(tt-param.valorCampo).
             WHEN "nrcheque"  THEN aux_nrcheque = DECI(tt-param.valorCampo).
             WHEN "nrdconta"  THEN aux_nrdconta = INTE(tt-param.valorCampo).
             
             WHEN "cdbccxlt"  THEN aux_cdbccxlt = tt-param.valorCampo.
             WHEN "dtmvtini"  THEN aux_dtmvtini = DATE(tt-param.valorCampo).
             WHEN "dtmvtfim"  THEN aux_dtmvtfim = DATE(tt-param.valorCampo).
             WHEN "nrregist"  THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq"  THEN aux_nriniseq = INTE(tt-param.valorCampo).




             WHEN "nrcampo1"  THEN aux_nrcampo1 = tt-param.valorCampo.
             WHEN "nrcampo2"  THEN aux_nrcampo2 = tt-param.valorCampo.
             WHEN "nrcampo3"  THEN aux_nrcampo3 = tt-param.valorCampo.

             WHEN "tpdsaida"  THEN aux_tpdsaida = tt-param.valorCampo.
                 
             WHEN "dtdevolu"  THEN aux_dtdevolu = DATE(tt-param.valorCampo).
                 
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */


/* ------------------------------------------------------------------------ */
/*                EFETUA A CONSULTA DOS CONTRATOS AVALIZADOS                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    ASSIGN aux_dsdocmc7 = "<" + aux_nrcampo1 +
                          "<" + aux_nrcampo2 +
                          ">" + aux_nrcampo3 + ":".

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper, 
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_nmdatela,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtola,
                    INPUT aux_tipocons,
                    INPUT aux_vlcheque,
                    INPUT aux_nrcheque,
                    INPUT aux_nrdconta,
                    INPUT aux_dsdocmc7,
                    INPUT aux_nrregist,
                    INPUT aux_nriniseq,
                    INPUT TRUE, /* flgerlog */
                    INPUT aux_dtmvtolt,
                   OUTPUT aux_qtregist,
                   OUTPUT aux_nmdcampo,
                   OUTPUT TABLE tt-crapchd,
                   OUTPUT TABLE tt-crapchd-aux,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapchd-aux:HANDLE,
                            INPUT "Cheque").
           RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*                EFETUA A CONSULTA DOS CONTRATOS AVALIZADOS                */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Relatorio:

    RUN Gera_Relatorio IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_dsiduser,
                       INPUT aux_cdbccxlt,
                       INPUT aux_dtmvtini,
                       INPUT aux_dtmvtfim,
                       INPUT aux_tpdsaida,
                       INPUT TRUE, /* flgerlog */
                      OUTPUT aux_nmdcampo,
                      OUTPUT aux_nmarqimp,
                      OUTPUT aux_nmarqpdf,
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
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

PROCEDURE Gera_Relatorio_Devolvidos:

    RUN Gera_Relatorio_Devolvidos IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_dsiduser,
                       INPUT aux_dtdevolu,
                       INPUT TRUE, /* flgerlog */
                      OUTPUT aux_nmarqimp,
                      OUTPUT aux_nmarqpdf,
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

END PROCEDURE. /* Busca_Dados */
