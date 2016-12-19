/*..............................................................................

   Programa: xb1wgen0149.p
   Autor   : David Kruger
   Data    : Fevereiro/2013                      Ultima atualizacao: 30/11/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO para tela AGENCI (b1wgen0149.p)
   

   Alteracoes: 08/01/2014 - Ajuste homologacao (Adriano)
			   
			         06/09/2016 - Adicionado filtro pelo nome da agencia e do banco, conforme solicitado
							              no chamado 504477 (Kelvin).
                            
               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)             

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_cddbanco AS CHAR                                        NO-UNDO.
DEF VAR aux_cdageban AS INTE                                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_nmageban AS CHAR                                        NO-UNDO.
DEF VAR aux_dgagenci AS CHAR                                        NO-UNDO.
DEF VAR aux_cdsitagb AS CHAR                                        NO-UNDO.
DEF VAR aux_nmextbcc AS CHAR                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                        NO-UNDO.
DEF VAR aux_qtregist AS INTE                                        NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_cddepart AS INTE                                        NO-UNDO.



{ sistema/generico/includes/b1wgen0149tt.i }
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
            WHEN "cdageban" THEN aux_cdageban = INTE(tt-param.valorCampo).
            WHEN "cddbanco" THEN aux_cddbanco = tt-param.valorCampo.
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dgagenci" THEN aux_dgagenci = tt-param.valorCampo.
            WHEN "nmageban" THEN aux_nmageban = tt-param.valorCampo.
            WHEN "cdsitagb" THEN aux_cdsitagb = tt-param.valorCampo.
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).			
			WHEN "nmextbcc" THEN aux_nmextbcc = tt-param.valorCampo.
			


            
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


PROCEDURE busca-banco:

    RUN busca-banco IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_cddepart,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_cddopcao,
                            INPUT aux_cddbanco,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nrregist,
                            INPUT aux_nriniseq,
							INPUT aux_nmextbcc,
                            OUTPUT aux_nmdcampo,
                            OUTPUT aux_qtregist,
                            OUTPUT TABLE tt-banco,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport(INPUT TEMP-TABLE tt-banco:HANDLE, INPUT "Banco").
            RUN piXmlAtributo(INPUT "nmextbcc", INPUT aux_nmextbcc).
            RUN piXmlAtributo(INPUT "qtregist", INPUT STRING(aux_qtregist)). 
            RUN piXmlSave.
        END.


END PROCEDURE.


PROCEDURE busca-agencia:

    RUN busca-agencia IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_cddepart,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdageban,
                              INPUT aux_cddbanco,
                              INPUT aux_dtmvtolt,
                              INPUT aux_cddopcao,
                              INPUT aux_nrregist,
                              INPUT aux_nriniseq,
							  INPUT aux_nmageban,
                              OUTPUT aux_nmdcampo,
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-agencia, 
                              OUTPUT TABLE tt-feriados,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport(INPUT TEMP-TABLE tt-agencia:HANDLE, INPUT "Agencia").
            RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)). 
            RUN piXmlExport(INPUT TEMP-TABLE tt-feriados:HANDLE, INPUT "Feriado").
            RUN piXmlSave.
        END.

END PROCEDURE.


PROCEDURE altera-agencia:

    RUN altera-agencia IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_cddepart,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cddopcao,
                               INPUT aux_cdageban,
                               INPUT aux_cddbanco,
                               INPUT aux_dtmvtolt,
                               INPUT aux_dgagenci,
                               INPUT aux_nmageban,
                               INPUT aux_cdsitagb,
                               OUTPUT aux_nmdcampo,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


PROCEDURE nova-agencia:

    RUN nova-agencia IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_cddepart,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_cddopcao,
                             INPUT aux_cdageban,
                             INPUT aux_cddbanco,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dgagenci,
                             INPUT aux_nmageban,
                             INPUT aux_cdsitagb,
                             OUTPUT aux_nmdcampo,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


PROCEDURE deleta-agencia:

    RUN deleta-agencia IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_cddepart,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cddopcao,
                               INPUT aux_cdageban,
                               INPUT aux_cddbanco,
                               INPUT aux_dtmvtolt,
                               INPUT aux_dgagenci,
                               INPUT aux_nmageban,
                               INPUT aux_cdsitagb,
                               OUTPUT aux_nmdcampo,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.



