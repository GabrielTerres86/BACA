/*............................................................................

   Programa: xb1wgen0045.p
   Autor   : David Kruger
   Data    : Fevereiro/2013                      Ultima atualizacao: 18/02/2014

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO para tela RELSEG (b1wgen0045.p)
   

   Alteracoes: 18/02/2014 - Impressão em .txt para Tp.Relat 5 (Lucas).

.............................................................................*/


DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_telcdage AS INTE                                        NO-UNDO.
DEF VAR aux_inexprel AS INTE                                        NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                        NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                        NO-UNDO.
DEF VAR aux_vlrdecom1 AS DECI                                       NO-UNDO.
DEF VAR aux_vlrdecom2 AS DECI                                       NO-UNDO.
DEF VAR aux_vlrdecom3 AS DECI                                       NO-UNDO.
DEF VAR aux_vlrdeiof1 AS DECI                                       NO-UNDO.
DEF VAR aux_vlrdeiof2 AS DECI                                       NO-UNDO.
DEF VAR aux_vlrdeiof3 AS DECI                                       NO-UNDO.
DEF VAR aux_recid1    AS ROWID                                      NO-UNDO.
DEF VAR aux_recid2    AS ROWID                                      NO-UNDO.
DEF VAR aux_recid3    AS ROWID                                      NO-UNDO.
DEF VAR aux_vlrapoli  AS DECI                                       NO-UNDO.
DEF VAR aux_tprelato  AS INTE                                       NO-UNDO.
DEF VAR aux_nmdcampo  AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                       NO-UNDO.

{ sistema/generico/includes/b1wgen0045tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/


PROCEDURE valores_entrada:


    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "telcdage" THEN aux_telcdage = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "vlrdecom1" THEN aux_vlrdecom1 = DECI(tt-param.valorCampo).
            WHEN "vlrdecom2" THEN aux_vlrdecom2 = DECI(tt-param.valorCampo).
            WHEN "vlrdecom3" THEN aux_vlrdecom3 = DECI(tt-param.valorCampo).
            WHEN "vlrdeiof1" THEN aux_vlrdeiof1 = DECI(tt-param.valorCampo).
            WHEN "vlrdeiof2" THEN aux_vlrdeiof2 = DECI(tt-param.valorCampo).
            WHEN "vlrdeiof3" THEN aux_vlrdeiof3 = DECI(tt-param.valorCampo).
            WHEN "recid1" THEN aux_recid1 = TO-ROWID(tt-param.valorCampo). 
            WHEN "recid2" THEN aux_recid2 = TO-ROWID(tt-param.valorCampo).
            WHEN "recid3" THEN aux_recid3 = TO-ROWID(tt-param.valorCampo).  
            WHEN "vlrapoli" THEN aux_vlrapoli = DEC(tt-param.valorCampo).
            WHEN "tprelato" THEN aux_tprelato = INTE(tt-param.valorCampo).
            WHEN "inexprel" THEN aux_inexprel = INTE(tt-param.valorCampo).
            WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
            WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
            WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
            
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


PROCEDURE busca_dados_seg:

    RUN busca_dados_seg IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtolt,
                                OUTPUT aux_vlrdecom1,
                                OUTPUT aux_vlrdecom2,
                                OUTPUT aux_vlrdecom3,
                                OUTPUT aux_vlrdeiof1,
                                OUTPUT aux_vlrdeiof2,
                                OUTPUT aux_vlrdeiof3,
                                OUTPUT aux_recid1,
                                OUTPUT aux_recid2,
                                OUTPUT aux_recid3,
                                OUTPUT aux_vlrapoli,
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
            RUN piXmlAtributo(INPUT "vlrdecom1", INPUT STRING(aux_vlrdecom1)). 
            RUN piXmlAtributo(INPUT "vlrdecom2", INPUT STRING(aux_vlrdecom2)). 
            RUN piXmlAtributo(INPUT "vlrdecom3", INPUT STRING(aux_vlrdecom3)). 
            RUN piXmlAtributo(INPUT "vlrdeiof1", INPUT STRING(aux_vlrdeiof1)). 
            RUN piXmlAtributo(INPUT "vlrdeiof2", INPUT STRING(aux_vlrdeiof2)). 
            RUN piXmlAtributo(INPUT "vlrdeiof3", INPUT STRING(aux_vlrdeiof3)). 
            RUN piXmlAtributo(INPUT "recid1", INPUT STRING(aux_recid1)). 
            RUN piXmlAtributo(INPUT "recid2", INPUT STRING(aux_recid2)). 
            RUN piXmlAtributo(INPUT "recid3", INPUT STRING(aux_recid3)). 
            RUN piXmlAtributo(INPUT "vlrapoli", INPUT STRING(aux_vlrapoli)).  
            RUN piXmlSave.
        END.


END PROCEDURE.


PROCEDURE proc_grava_dados:

    RUN proc_grava_dados IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtolt,
                                INPUT aux_vlrdecom1,
                                INPUT aux_vlrdecom2,
                                INPUT aux_vlrdecom3,
                                INPUT aux_vlrdeiof1,
                                INPUT aux_vlrdeiof2,
                                INPUT aux_vlrdeiof3,
                                INPUT aux_recid1,
                                INPUT aux_recid2,
                                INPUT aux_recid3,
                                INPUT aux_vlrapoli,
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
            RUN piXmlSave.
        END.


END PROCEDURE.


PROCEDURE inicia-relatorio:
    
    RUN inicia-relatorio IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_tprelato,
                                 INPUT aux_telcdage,
                                 INPUT aux_dtiniper,
                                 INPUT aux_dtfimper,
                                 INPUT aux_inexprel,
                                OUTPUT aux_nmdcampo,
                                OUTPUT aux_nmarqpdf,
                                OUTPUT aux_nmarqimp,
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
            RUN piXmlNew.    
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).  
            RUN piXmlSave.
        END.

END PROCEDURE.
