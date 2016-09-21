/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0114.p
     Autor   : Rogerius Militão
     Data    : Setembro/2011                     Ultima atualizacao: 06/08/2013
     
     Objetivo  : BO de Comunicacao XML x BO - Telas cmaprv

     Alteracoes:
                    06/08/2013 - Incluido parametro nrctremp para procedure
                                 Valida_Dados (Tiago).

.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagenc1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_dtpropos AS DATE                                           NO-UNDO.
DEF VAR aux_dtaprova AS DATE                                           NO-UNDO.
DEF VAR aux_dtaprfim AS DATE                                           NO-UNDO.
DEF VAR aux_aprovad1 AS INTE                                           NO-UNDO.
DEF VAR aux_aprovad2 AS INTE                                           NO-UNDO.
DEF VAR aux_cdopeapv AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdcont1 AS INTE                                           NO-UNDO. /* conta do emprestimo */
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrliq AS CHAR                                           NO-UNDO.
DEF VAR aux_vlemprst AS DECI                                           NO-UNDO.

DEF VAR aux_cdcomite AS INTE                                           NO-UNDO.
DEF VAR aux_dscomite AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdircop AS CHAR                                           NO-UNDO.
DEF VAR aux_dsobscmt AS CHAR                                           NO-UNDO.
DEF VAR aux_flgcmtlc AS LOGICAL                                        NO-UNDO.

DEF VAR aux_insitapv AS INTE                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsaprova AS CHAR                                           NO-UNDO.
DEF VAR aux_hrtransa AS INTE                                           NO-UNDO.
DEF VAR aux_dsobstel AS CHAR                                           NO-UNDO.
DEF VAR aux_dscmaprv AS CHAR                                           NO-UNDO.
DEF VAR aux_flgalter AS LOGICAL                                        NO-UNDO.
DEF VAR aux_insitaux AS INTE                                           NO-UNDO.

DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_confcmpl AS CHAR                                           NO-UNDO.
DEF VAR aux_confimpr AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO. 

DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.

DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0114tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

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
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).

             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "cdagenc1" THEN aux_cdagenc1 = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "dtpropos" THEN aux_dtpropos = DATE(tt-param.valorCampo).
             WHEN "dtaprova" THEN aux_dtaprova = DATE(tt-param.valorCampo).
             WHEN "dtaprfim" THEN aux_dtaprfim = DATE(tt-param.valorCampo).
             WHEN "aprovad1" THEN aux_aprovad1 = INTE(tt-param.valorCampo).
             WHEN "aprovad2" THEN aux_aprovad2 = INTE(tt-param.valorCampo).
             WHEN "cdopeapv" THEN aux_cdopeapv = tt-param.valorCampo.

             WHEN "nrdcont1" THEN aux_nrdcont1 = INTE(tt-param.valorCampo).
             WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
             WHEN "nrctrliq" THEN aux_nrctrliq = tt-param.valorCampo.
             WHEN "vlemprst" THEN aux_vlemprst = DECI(tt-param.valorCampo).

             WHEN "cdcomite" THEN aux_cdcomite = INTE(tt-param.valorCampo).
             WHEN "dscomite" THEN aux_dscomite = tt-param.valorCampo.
             WHEN "dsdircop" THEN aux_dsdircop = tt-param.valorCampo.
             WHEN "dsobscmt" THEN aux_dscomite = tt-param.valorCampo.
             WHEN "flgcmtlc" THEN aux_flgcmtlc = LOGICAL(tt-param.valorCampo).

             WHEN "insitapv" THEN aux_insitapv = INTE(tt-param.valorCampo).
             WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
             WHEN "dsaprova" THEN aux_dsaprova = tt-param.valorCampo.
             WHEN "hrtransa" THEN aux_hrtransa = INTE(tt-param.valorCampo).
             WHEN "dsobstel" THEN aux_dsobstel = tt-param.valorCampo.
             WHEN "dscmaprv" THEN aux_dscmaprv = tt-param.valorCampo.
             WHEN "flgalter" THEN aux_flgalter = LOGICAL(tt-param.valorCampo).
             WHEN "insitaux" THEN aux_insitaux = INTE(tt-param.valorCampo).

             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "confcmpl" THEN aux_confcmpl = tt-param.valorCampo.
             WHEN "confimpr" THEN aux_confimpr = tt-param.valorCampo.
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.

             WHEN "msgalert" THEN aux_msgalert = tt-param.valorCampo.
             WHEN "msgretor" THEN aux_msgretor = tt-param.valorCampo.

             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */


/* ------------------------------------------------------------------------ */
/*                         BUSCA O TITULO DA TELA                           */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Titulo:

    RUN Busca_Titulo IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_idorigem,
                     OUTPUT aux_dscomite,
                     OUTPUT aux_dsdircop,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca do titulo.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "dscomite", INPUT aux_dscomite).
           RUN piXmlAtributo (INPUT "dsdircop", INPUT aux_dsdircop).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                     BUSCA OS EMPRESTIMOS CMAPRV                          */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_dtmvtopr,
                      INPUT aux_inproces,
                      INPUT aux_cddopcao,
                      INPUT aux_cdagenc1,
                      INPUT aux_nrdconta,
                      INPUT aux_dtpropos,
                      INPUT aux_dtaprova,
                      INPUT aux_dtaprfim,
                      INPUT aux_aprovad1,
                      INPUT aux_aprovad2,
                      INPUT aux_cdopeapv,
                      INPUT aux_nriniseq,
                      INPUT aux_nrregist,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-cmaprv,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-cmaprv:HANDLE,
                            INPUT "Emprestimo").
           RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                EFETUA A VALIDAÇÃO DOS DADOS DO EMPRESTIMO                */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_dtmvtopr,
                       INPUT aux_inproces,
                       INPUT aux_cddopcao,
                       INPUT aux_nrdconta,
                       INPUT aux_dtpropos,
                       INPUT aux_dtaprova,
                       INPUT aux_dtaprfim,
                       INPUT aux_aprovad1,
                       INPUT aux_aprovad2,
                       INPUT aux_nrdcont1,
                       INPUT aux_nrctrliq,
                       INPUT aux_vlemprst,
                       INPUT YES,
                       INPUT aux_nrctremp,
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

END PROCEDURE.


/* ------------------------------------------------------------------------ */
/*              EFETUA A VERIFiCACAO DO RATING PARA EMPRESTIMO              */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Rating:

    RUN Verifica_Rating IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_cdoperad,
                          INPUT aux_idorigem,
                          INPUT aux_nmdatela,
                          INPUT aux_dtmvtolt,
                          INPUT aux_dtmvtopr,
                          INPUT aux_inproces,
                          INPUT aux_nrdcont1,
                          INPUT aux_nrctremp,
                         OUTPUT aux_msgalert,
                         OUTPUT aux_msgretor,
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
           RUN piXmlAtributo (INPUT "msgalert", INPUT aux_msgalert).
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*           EFETUA VERIFICAÇÃO MOTIVO NAO APROVACAO DO EMPRESTIMO          */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Motivo:

    RUN Verifica_Motivo IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdoperad,
                          INPUT aux_nmdatela,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_idorigem,
                          INPUT aux_nrdcont1,
                          INPUT aux_nrctremp, 
                          INPUT TRUE,
                         OUTPUT aux_cdcomite,
                         OUTPUT aux_dsobscmt,
                         OUTPUT aux_flgcmtlc,
                         OUTPUT aux_msgretor,
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
           RUN piXmlAtributo (INPUT "cdcomite", INPUT aux_cdcomite).
           RUN piXmlAtributo (INPUT "dsobscmt", INPUT aux_dsobscmt).
           RUN piXmlAtributo (INPUT "flgcmtlc", INPUT aux_flgcmtlc).
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                  EFETUA GRAVACAO DA SITUACAO DO EMPRESTIMO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_cdoperad,
                      INPUT aux_nrdcont1, 
                      INPUT aux_nrctremp,
                      INPUT aux_insitapv,
                      INPUT aux_dsobscmt,
                      INPUT aux_dsobstel,
                      INPUT aux_dscmaprv,
                      INPUT aux_flgalter,
                      INPUT aux_insitaux,
                      INPUT TRUE,
                     OUTPUT TABLE tt-emprestimo,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-emprestimo:HANDLE,
                            INPUT "Emprestimo").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                     BUSCA OS EMPRESTIMOS CMAPRV                          */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_dtmvtolt,
                         INPUT aux_dtmvtopr,
                         INPUT aux_inproces,
                         INPUT aux_dsiduser,
                         INPUT aux_cddopcao,
                         INPUT aux_cdagenc1,
                         INPUT aux_nrdconta,
                         INPUT aux_dtpropos,
                         INPUT aux_dtaprova,
                         INPUT aux_dtaprfim,
                         INPUT aux_aprovad1,
                         INPUT aux_aprovad2,
                         INPUT aux_cdopeapv,
                         INPUT aux_confcmpl,
                         INPUT aux_confimpr,
                        INPUT-OUTPUT aux_nmarqimp,  
                        OUTPUT aux_nmarqpdf,        
                        OUTPUT TABLE tt-cmaprv,
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
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE.
