/* .........................................................................

   Programa: xb1wgen0024.p
   Autor   : Gabriel
   Data    : Novembro/2010                    Ultima Atualizacao: 16/09/2013
   
   Dados referentes ao programa:
   
   Objetivo  : BO de Comunicacao XML vs BO de Funcoes em comum das operacoes
               de credito (b1wgen0024.p).
              
   Alteracoes: 08/08/2011 - Incluir novo campo dsiduser na procedure monta-
                            contratos (David).
                            
               22/07/2013 - Incluir paginação na tela IMPROP (Gabriel) 
               
               16/09/2014 - Projeto consultas automatizadas (Jonata-RKAM).            

..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_nmrelato AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_cdtipcon AS INTE                                           NO-UNDO.
DEF VAR aux_tpctrato AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrato AS INTE                                           NO-UNDO.
DEF VAR aux_nrctabus AS INTE                                           NO-UNDO.
DEF VAR aux_dscpfbus AS CHAR                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/* .........................PROCEDURES................................... */


/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/

PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo). 
            WHEN "nmrelato" THEN aux_nmrelato = tt-param.valorCampo.
            WHEN "nomedarq" THEN aux_nomedarq = tt-param.valorCampo.
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cdtipcon" THEN aux_cdtipcon = INTE(tt-param.valorCampo).
            WHEN "tpctrato" THEN aux_tpctrato = INTE(tt-param.valorCampo).
            WHEN "nrctrato" THEN aux_nrctrato = INTE(tt-param.valorCampo).
            WHEN "nrctabus" THEN aux_nrctabus = INTE(tt-param.valorCampo).
            WHEN "nrcpfbus" THEN aux_dscpfbus = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************
  Validar dados antes de listar os contratos que foram enviados para a sede. 
 (Tela IMPROP)
******************************************************************************/

PROCEDURE valida-dados-contratos:
                                            
    RUN valida-dados-contratos IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_nrdconta,
                                       INPUT aux_dtiniper,
                                       INPUT aux_dtfimper,
                                      OUTPUT TABLE tt-erro).
     
    IF   RETURN-VALUE = "NOK"  THEN
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


/******************************************************************************
 Obter os contratos que foram enviados para a sede. (Tela IMPROP)
******************************************************************************/

PROCEDURE lista-contratos-sede:

    RUN lista-contratos-sede IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nmrelato,
                                     INPUT aux_nrdconta,
                                     INPUT aux_dtiniper,
                                     INPUT aux_dtfimper,
                                     INPUT aux_nrregist,
                                     INPUT aux_nriniseq,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-contratos).

    IF   RETURN-VALUE = "NOK"  THEN
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
             RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
             RUN piXmlExport (INPUT TEMP-TABLE tt-contratos:HANDLE,
                              INPUT "Contratos").
             RUN piXmlSave.
         END.

END PROCEDURE.

/******************************************************************************
 Opcao 'I' da tela IMPROP.
******************************************************************************/

PROCEDURE monta-contratos:

    RUN monta-contratos IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nomedarq,
                                INPUT aux_dsiduser,
                               OUTPUT TABLE tt-erro,
                               OUTPUT aux_nmarquiv,
                               OUTPUT aux_nmarqpdf).

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
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
             /* Salvar soh o parametro que traz o PDF */                      
             RUN piXmlNew.
             RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
             RUN piXmlSave.
         END.
          
END PROCEDURE.


/******************************************************************************
 Opcao 'E' da tela IMPROP.
******************************************************************************/

PROCEDURE deleta-contratos:

    RUN deleta-contratos IN hBo (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nomedarq,
                                OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  NOT AVAIL tt-erro  THEN
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

PROCEDURE obtem-valores-central-risco:

    ASSIGN aux_dscpfbus = REPLACE(aux_dscpfbus,".","")
           aux_dscpfbus = REPLACE(aux_dscpfbus,"/","")
           aux_dscpfbus = REPLACE(aux_dscpfbus,"-",""). 

    RUN obtem-valores-central-risco IN hBo (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_cdtipcon,
                                            INPUT aux_nrdconta,
                                            INPUT aux_tpctrato,
                                            INPUT aux_nrctrato,
                                            INPUT aux_nrctabus,
                                            INPUT DECI(aux_dscpfbus),
                                            INPUT FALSE,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-central-risco).

    IF   RETURN-VALUE = "NOK"  THEN
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
             RUN piXmlExport (INPUT TEMP-TABLE tt-central-risco:HANDLE,
                              INPUT "central").
             RUN piXmlSave.         
         END.

END PROCEDURE.


/* ......................................................................*/
