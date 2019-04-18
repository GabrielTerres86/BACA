/*.............................................................................

   Programa: xb1wgen0097.p
   Autor   : GATI - Diego
   Data    : Junho/2011                        Ultima atualizacao: 25/06/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO para a simulacao de Emprestimos 
               (b1wgen0097.p).

   Alteracoes: 17/02/2012 - Criada procedure retornaDiasUteis (Tiago).
   
               30/03/2012 - Incluir campo % CET (Gabriel). 

               10/04/2012 - Criada procedure busca-feriados (Tiago).
               
               05/08/2014 - Ajustado para calcular o cet - Projeto CET
                            (Lucas R./Gielow)
                            
               25/06/2015 - Projeto 215 - DV 3 (Daniel) 

			   06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
			                da descrição do departamento como parametro e 
							passar o código (Renato Darosci)
                            
               20/09/2017 - Projeto 410 - Incluir campo Indicador de 
                            financiamento do IOF (Diogo - Mouts)

               14/12/2018 - P298 - Inclusos campos tpemprst e carencia para simulação (Andre Clemer - Supero)
.............................................................................*/

DEF VAR aux_cdcooper    AS  INTE                                      NO-UNDO.
DEF VAR aux_cdagenci    AS  INTE                                      NO-UNDO.
DEF VAR aux_nrdcaixa    AS  INTE                                      NO-UNDO.
DEF VAR aux_cdoperad    AS  CHAR                                      NO-UNDO.
DEF VAR aux_nmdatela    AS  CHAR                                      NO-UNDO.
DEF VAR aux_idorigem    AS  INTE                                      NO-UNDO.
DEF VAR aux_nrdconta    AS  INTE                                      NO-UNDO.
DEF VAR aux_idseqttl    AS  INTE                                      NO-UNDO.
DEF VAR aux_nrsimula    AS  INTE                                      NO-UNDO.
DEF VAR aux_flgerlog    AS  LOGI                                      NO-UNDO.
DEF VAR aux_vlemprst    AS  DECI                                      NO-UNDO.
DEF VAR aux_qtparepr    AS  INTE                                      NO-UNDO.
DEF VAR aux_cdlcremp    AS  INTE                                      NO-UNDO.
DEF VAR aux_dtdpagto    AS  DATE                                      NO-UNDO.
DEF VAR aux_dtlibera    AS  DATE                                      NO-UNDO.
DEF VAR aux_cddopcao    AS  CHAR                                      NO-UNDO.
DEF VAR aux_dsiduser    AS  CHAR                                      NO-UNDO.
DEF VAR aux_nrgravad    AS  INTE                                      NO-UNDO.
DEF VAR aux_cddepart    AS  INTE                                      NO-UNDO.
DEF VAR aux_dtiniper    AS  DATE                                      NO-UNDO.
DEF VAR aux_dtfinper    AS  DATE                                      NO-UNDO.
DEF VAR aux_percetop    AS  DECI                                      NO-UNDO.
DEF VAR aux_txcetano    AS  CHAR                                      NO-UNDO.
DEF VAR aux_cdfinemp    AS  INTE                                      NO-UNDO.  
DEF VAR aux_idfiniof    AS  INTE                                      NO-UNDO.  
DEF VAR aux_tpemprst    AS  INTE                                      NO-UNDO.  
DEF VAR aux_idcarenc    AS  INTE                                      NO-UNDO.  
DEF VAR aux_dtcarenc    AS  DATE                                      NO-UNDO.  

DEF VAR par_nmarqimp    AS  CHAR                                      NO-UNDO.
DEF VAR par_nmarqpdf    AS  CHAR                                      NO-UNDO.

{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen0097tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ...............................*/

PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cddepart" THEN aux_cddepart =    INTE(tt-param.valorCampo).
            WHEN "cdcooper" THEN aux_cdcooper =    INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci =    INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa =    INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad =         tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela =         tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem =    INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta =    INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl =    INTE(tt-param.valorCampo).
            WHEN "nrsimula" THEN aux_nrsimula =    INTE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao =         tt-param.valorCampo.
            WHEN "vlemprst" THEN aux_vlemprst =    DECI(tt-param.valorCampo).
            WHEN "qtparepr" THEN aux_qtparepr =    INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp =    INTE(tt-param.valorCampo).
            WHEN "cdfinemp" THEN aux_cdfinemp =    INTE(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto =    DATE(tt-param.valorCampo).
            WHEN "dtlibera" THEN aux_dtlibera =    DATE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser =          tt-param.valorCampo.
            WHEN "dtiniper" THEN aux_dtiniper =    DATE(tt-param.valorCampo).
            WHEN "dtfinper" THEN aux_dtfinper =    DATE(tt-param.valorCampo).
            WHEN "percetop" THEN aux_percetop =    DECI(tt-param.valorCampo).
			WHEN "idfiniof" THEN aux_idfiniof =    INTE(tt-param.valorCampo).
            WHEN "tpemprst" THEN aux_tpemprst =    INTE(tt-param.valorCampo).
            WHEN "idcarenc" THEN aux_idcarenc =    INTE(tt-param.valorCampo).
            WHEN "dtcarenc" THEN aux_dtcarenc =    DATE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE. /* valores_entrada */

PROCEDURE RetornaDiasUteis:
    DEF VAR aux_qtdialib AS INTE        NO-UNDO.

    ASSIGN aux_qtdialib = DYNAMIC-FUNCTION("fnRetornaDiasUteis" IN hBO, 
                                                INPUT aux_cdcooper,
                                                INPUT aux_dtiniper,
                                                INPUT aux_dtfinper).

    RUN piXmlNew.                             
    RUN piXmlAtributo (INPUT "qtdialib",
                       INPUT aux_qtdialib).
    RUN piXmlSave.                         
    
END PROCEDURE.

PROCEDURE busca-feriados:

    RUN busca-feriados IN hBO (INPUT aux_cdcooper,
                               INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-crapfer,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
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

            RUN piXmlExport (INPUT TEMP-TABLE tt-crapfer:HANDLE,
                             INPUT "Dados").

            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_feriados */


PROCEDURE busca_dados_simulacao:

    RUN busca_dados_simulacao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_flgerlog,
                                      INPUT aux_nrsimula,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-crapsim,
                                      OUTPUT TABLE tt-parcelas-epr).
    
    IF  RETURN-VALUE = "NOK"  THEN
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

            RUN piXmlExport (INPUT TEMP-TABLE tt-crapsim:HANDLE,
                             INPUT "Dados").

            RUN piXmlExport (INPUT TEMP-TABLE tt-parcelas-epr:HANDLE,
                             INPUT "Parcelas").

            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_dados_simulacao */

PROCEDURE busca_simulacoes:

    RUN busca_simulacoes IN hBO (INPUT aux_cdcooper,  
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_flgerlog,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-crapsim).
                                  
    IF  RETURN-VALUE = "NOK"  THEN
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

            RUN piXmlExport (INPUT TEMP-TABLE tt-crapsim:HANDLE,
                             INPUT "Dados").
            
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_simulacoes */


PROCEDURE exclui_simulacao:

    RUN exclui_simulacao IN hBO (INPUT  aux_cdcooper,
                                 INPUT  aux_cdagenci,
                                 INPUT  aux_nrdcaixa,
                                 INPUT  aux_cdoperad,
                                 INPUT  aux_nmdatela,
                                 INPUT  aux_idorigem,
                                 INPUT  aux_nrdconta,
                                 INPUT  aux_idseqttl,
                                 INPUT  aux_dtmvtolt,
                                 INPUT  aux_flgerlog,
                                 INPUT  aux_nrsimula,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (
                INPUT TEMP-TABLE tt-erro:HANDLE,
                INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE. /* exclui_simulacao */


PROCEDURE grava_simulacao:

    RUN grava_simulacao IN hBO (INPUT  aux_cdcooper,
                                INPUT  aux_cdagenci,
                                INPUT  aux_nrdcaixa,
                                INPUT  aux_cdoperad,
                                INPUT  aux_nmdatela,
                                INPUT  aux_idorigem,
                                INPUT  aux_nrdconta,
                                INPUT  aux_idseqttl,
                                INPUT  aux_dtmvtolt,
                                INPUT  aux_flgerlog,
                                INPUT  aux_cddopcao,
                                INPUT  aux_nrsimula,
                                INPUT  aux_cdlcremp,
                                INPUT  aux_vlemprst,
                                INPUT  aux_qtparepr,
                                INPUT  aux_dtlibera,
                                INPUT  aux_dtdpagto,
                                INPUT  aux_percetop,
                                INPUT  aux_cdfinemp,
								INPUT  aux_idfiniof,
                                INPUT  aux_tpemprst,
                                INPUT  aux_idcarenc,
                                INPUT  aux_dtcarenc,
                                OUTPUT TABLE tt-erro,
                                OUTPUT aux_nrgravad,
                                OUTPUT aux_txcetano).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
            RUN piXmlAtributo (INPUT "nrgravad", INPUT aux_nrgravad).
            RUN piXmlAtributo (INPUT "txcetano", INPUT SUBSTR(aux_txcetano,1,5) ).
            RUN piXmlSave.
        END.

END PROCEDURE. /* grava_simulacao */

PROCEDURE imprime_simulacao:

    RUN imprime_simulacao IN hBO (INPUT aux_cdcooper, 
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_flgerlog,
                                  INPUT aux_nrsimula,
                                  INPUT aux_dsiduser,
                                  INPUT aux_tpemprst,
                                  OUTPUT par_nmarqimp,
                                  OUTPUT par_nmarqpdf,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT par_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT par_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* imprime_simulacao */



PROCEDURE valida_simulacao:

    RUN valida_simulacao IN hBO (INPUT  aux_cdcooper,
                                INPUT  aux_cdagenci,
                                INPUT  aux_nrdcaixa,
                                INPUT  aux_cdoperad,
                                INPUT  aux_nmdatela,
                                INPUT  aux_idorigem,
                                INPUT  aux_nrdconta,
                                INPUT  aux_idseqttl,
                                INPUT  aux_dtmvtolt,
                                INPUT  aux_flgerlog,
                                INPUT  aux_cddepart,
                                OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlSave.
        END.   
END PROCEDURE. /* valida_novo_calculo */
