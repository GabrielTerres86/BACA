/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0177.p
     Autor   : Gabriel Capoia
     Data    : 23/09/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela GT0003

     Alteracoes: 

............................................................................*/


/*..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                         NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                         NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                         NO-UNDO.
DEF VAR aux_idorigem AS INTE                                         NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                         NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_cdconven AS INTE                                         NO-UNDO.
DEF VAR aux_cdcooped AS INTE                                         NO-UNDO.
DEF VAR aux_nrregist AS INTE                                         NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.
DEF VAR aux_dtmvtola AS DATE                                         NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                         NO-UNDO.
DEF VAR aux_tiporel  AS LOGI                                         NO-UNDO.
DEF VAR aux_dtinici  AS DATE                                         NO-UNDO.
DEF VAR aux_dtfinal  AS DATE                                         NO-UNDO.

DEF VAR aux_qtregist AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
DEF VAR aux_totqtdoc AS DECI                                         NO-UNDO.
DEF VAR aux_totvldoc AS DECI                                         NO-UNDO.
DEF VAR aux_tottarif AS DECI                                         NO-UNDO.
DEF VAR aux_totpagar AS DECI                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0177tt.i }

/*............................... PROCEDURES ................................*/

PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:

             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.
             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "cdconven" THEN aux_cdconven = INTE(tt-param.valorCampo).
             WHEN "cdcooped" THEN aux_cdcooped = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "dtmvtola" THEN aux_dtmvtola = DATE(tt-param.valorCampo).
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "tiporel"  THEN aux_tiporel  = LOGICAL(tt-param.valorCampo).
             WHEN "dtinici"  THEN aux_dtinici  = DATE(tt-param.valorCampo).
             WHEN "dtfinal"  THEN aux_dtfinal  = DATE(tt-param.valorCampo).                  
                  

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */


/* -------------------------------------------------------------------------- */
/*       EFETUA A PESQUISA MANUTENCAO DE CONVENIOS POR COOPERATIVA            */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:
    
    RUN Busca_Dados IN hBO
                  (  INPUT aux_cdcooper, 
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_nmdatela,
                     INPUT aux_idorigem,
                     INPUT aux_dsdepart,
                     INPUT aux_cddopcao,
                     INPUT aux_dtmvtola,
                     INPUT aux_cdconven,
                     INPUT aux_cdcooped,
                     INPUT aux_nrregist,
                     INPUT aux_nriniseq,
                     INPUT TRUE,
                    OUTPUT aux_qtregist,
                    OUTPUT aux_nmdcampo,
                    OUTPUT aux_totqtdoc,
                    OUTPUT aux_totvldoc,
                    OUTPUT aux_tottarif,
                    OUTPUT aux_totpagar,
                    OUTPUT TABLE tt-gt0003,
                    OUTPUT TABLE tt-gt0003-aux,
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
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.           

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gt0003-aux:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlAtributo (INPUT "totqtdoc",INPUT STRING(aux_totqtdoc)).
            RUN piXmlAtributo (INPUT "totvldoc",INPUT STRING(aux_totvldoc)).
            RUN piXmlAtributo (INPUT "tottarif",INPUT STRING(aux_tottarif)).
            RUN piXmlAtributo (INPUT "totpagar",INPUT STRING(aux_totpagar)).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* -------------------------------------------------------------------------- */
/*       EFETUA A IMPRESS„O MANUTENCAO DE CONVENIOS POR COOPERATIVA           */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:
    
    RUN Gera_Impressao IN hBO
                    (  INPUT aux_cdcooper, 
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_dtmvtolt,
                       INPUT aux_idorigem,
                       INPUT aux_dsiduser,
                       INPUT aux_tiporel,
                       INPUT aux_cdcooped,
                       INPUT aux_dtinici ,
                       INPUT aux_dtfinal ,
                       INPUT TRUE,
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
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
           
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Impressao */