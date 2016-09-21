
/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0116.p
     Autor   : Jorge Issamu Hamaguchi
     Data    : Agosto/2012                       Ultima atualizacao: 14/11/2013

     Objetivo  : BO de Comunicacao XML x BO - Tela CADMSG

     Alteracoes: 14/11/2013 - Retornar qtd de msg nao lidas na procedure 
                              listar-mensagens independente do tipo de 
                              consulta (David).

.............................................................................*/


/*...........................................................................*/

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdassun AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdmensg AS CHAR                                           NO-UNDO.
DEF VAR aux_retrerro AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdremet AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdplchv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

DEF VAR aux_cdcadmsg AS INTE                                           NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_iddmensg AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_cdidpara AS INTE                                           NO-UNDO.
DEF VAR aux_qtdmensg AS INTE                                           NO-UNDO.
DEF VAR aux_nrdmensg AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS INTE                                           NO-UNDO.
DEF VAR aux_inpriori AS INTE                                           NO-UNDO.

DEF VAR aux_flgaplic AS LOGI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0116tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowid AS ROWID       NO-UNDO.

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "dsdassun" THEN aux_dsdassun = tt-param.valorCampo.
             WHEN "dsdmensg" THEN aux_dsdmensg = tt-param.valorCampo.
             WHEN "retrerro" THEN aux_retrerro = tt-param.valorCampo.
             WHEN "dscritic" THEN aux_dscritic = tt-param.valorCampo.
             WHEN "dsdremet" THEN aux_dsdremet = tt-param.valorCampo.
             
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdcadmsg" THEN aux_cdcadmsg = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
             WHEN "iddmensg" THEN aux_iddmensg = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "cdidpara" THEN aux_cdidpara = INTE(tt-param.valorCampo).
             WHEN "qtdmensg" THEN aux_qtdmensg = INTE(tt-param.valorCampo).
             WHEN "nrdmensg" THEN aux_nrdmensg = INTE(tt-param.valorCampo).
             WHEN "cdprogra" THEN aux_cdprogra = INTE(tt-param.valorCampo).
             WHEN "inpriori" THEN aux_inpriori = INTE(tt-param.valorCampo).
             
             WHEN "flgaplic" THEN aux_flgaplic = LOGICAL(tt-param.valorCampo).
                 
         END CASE.

     END. /** Fim do FOR EACH tt-param **/
    
     FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:
         
        CASE tt-param-i.nomeTabela:

            WHEN "Destinatarios" THEN 
            DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-dsidpara.
                       ASSIGN aux_rowid = ROWID(tt-dsidpara).
                    END.

                FIND tt-dsidpara WHERE ROWID(tt-dsidpara) = aux_rowid NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdcooper" THEN
                        tt-dsidpara.cdcooper = INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        tt-dsidpara.nrdconta = INTE(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.

 END PROCEDURE. /* valores_entrada */


/* ------------------------------------------------------------------------ */
/*           EXCLUIR CADASTROS E MENSAGENS ATRAVES DO AYLLOS WEB            */
/* ------------------------------------------------------------------------ */
PROCEDURE excluir-cadmsg:

    RUN excluir-cadmsg IN hBO ( INPUT aux_cdcooper,
                                INPUT aux_cdoperad,
                                INPUT aux_cdcadmsg,
                               OUTPUT aux_retrerro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "erro", INPUT aux_retrerro).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "OK",INPUT "OK").
           RUN piXmlSave. 
        END.

END PROCEDURE. /* excluir-cadmsg */


/* ------------------------------------------------------------------------ */
/*           CARREGAR CADASTROS DE MENSAGEM ATRAVES DO AYLLOS WEB           */
/* ------------------------------------------------------------------------ */
PROCEDURE carregar-cadmsg:

    RUN carregar-cadmsg IN hBO ( INPUT aux_cdcooper,
                                 INPUT aux_cdoperad,
                                 INPUT aux_cdcadmsg,
                                OUTPUT TABLE tt-cadmsg).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           ASSIGN aux_dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "dscritic", INPUT aux_dscritic).
           RUN piXmlSave.           
           
           /*FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "listagem de mensagem.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.*/
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-cadmsg:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* carregar-cadmsg */



/* ------------------------------------------------------------------------ */
/*                   CADASTRAR MENSAGEM ATRAVES DO AYLLOS WEB               */
/* ------------------------------------------------------------------------ */
PROCEDURE cadastrar-cadmsg:

    RUN cadastrar-cadmsg IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdoperad,
                      INPUT aux_dsdassun,
                      INPUT aux_dsdmensg,
                      INPUT aux_cdidpara,
                      INPUT TABLE tt-dsidpara,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir o " +
                                             "cadastro de mensagem.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF AVAIL tt-erro THEN
           DO:
               RUN piXmlNew.
               RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                                INPUT "Erro").
               RUN piXmlSave.
           END.
           ELSE
           DO:
               RUN piXmlNew.
               RUN piXmlAtributo (INPUT "OK",INPUT "OK").
               RUN piXmlSave. 
           END.
        END.

END PROCEDURE. /* cadastrar-mensagem */



/* ------------------------------------------------------------------------ */
/*                              GERAR MENSAGEM                              */
/* ------------------------------------------------------------------------ */
PROCEDURE gerar-mensagem:

    RUN gerar-mensagem IN hBO
                    ( INPUT aux_cdcadmsg,
                      INPUT aux_cdcooper,
                      INPUT aux_nrdconta,
                      INPUT aux_idseqttl,
                      INPUT aux_cdprogra,
                      INPUT aux_inpriori,
                      INPUT aux_dsdmensg,
                      INPUT aux_dsdassun,
                      INPUT aux_dsdremet,
                      INPUT aux_dsdplchv,
                      INPUT aux_cdoperad,
                     OUTPUT aux_retrerro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "retrerro", INPUT aux_retrerro).
           RUN piXmlSave.
        END.

END PROCEDURE. /* gerar-mensagem */


/* ------------------------------------------------------------------------ */
/*                  BUSCA LISTA DE MENSAGENS DO COOPERADO                   */
/* ------------------------------------------------------------------------ */
PROCEDURE listar-mensagens:

    RUN listar-mensagens IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_nrdconta,
                      INPUT aux_idseqttl,
                      INPUT aux_iddmensg,
                      INPUT aux_nrregist,
                      INPUT aux_nriniseq,
                     OUTPUT aux_retrerro,
                     OUTPUT aux_qtdmensg,
                     OUTPUT aux_dsdassun,
                     OUTPUT TABLE tt-mensagens).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           ASSIGN aux_dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "dscritic", INPUT aux_dscritic).
           RUN piXmlSave.           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-mensagens:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* listar-mensagens */


/* ------------------------------------------------------------------------ */
/*               VERIFICAR A QUANTIDADE DE MENSAGENS                        */
/* ------------------------------------------------------------------------ */
PROCEDURE quantidade-mensagens:

    RUN quantidade-mensagens IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_nrdconta,
                      INPUT aux_idseqttl,
                      INPUT aux_iddmensg,
                      INPUT aux_nrregist,
                      INPUT aux_nriniseq,
                     OUTPUT aux_retrerro,
                     OUTPUT aux_dsdassun,
                     OUTPUT aux_qtdmensg).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "retrerro", INPUT aux_retrerro).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "dsassunt", INPUT aux_dsdassun).
           RUN piXmlAtributo (INPUT "qtdmensg", INPUT aux_qtdmensg).
           RUN piXmlSave.
        END.

END PROCEDURE. /* quantidade-mensagens */

/* ------------------------------------------------------------------------ */
/*                            EXCLUIR MENSAGEM                              */
/* ------------------------------------------------------------------------ */
PROCEDURE excluir-mensagem:

    RUN excluir-mensagem IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_nrdconta,
                      INPUT aux_nrdmensg,
                     OUTPUT aux_retrerro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "retrerro", INPUT aux_retrerro).
           RUN piXmlSave.
        END.
    

END PROCEDURE. /* excluir-mensagem */

/* ------------------------------------------------------------------------ */
/*                              LER MENSAGEM                              */
/* ------------------------------------------------------------------------ */
PROCEDURE ler-mensagem:

    RUN ler-mensagem IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_nrdconta,
                      INPUT aux_idseqttl,
                      INPUT aux_nrdmensg,
                     OUTPUT aux_dsdassun,
                     OUTPUT aux_qtdmensg,
                     OUTPUT TABLE tt-mensagens,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "requisicao.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-mensagens:HANDLE,
                            INPUT "mensagens").
           RUN piXmlSave.
        END.

END PROCEDURE. /* ler-mensagem */

