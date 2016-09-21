/*.............................................................................

    Programa: xb1wgen0051.p
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 07/12/2010

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Contas (b1wgen0051.p)

   Alteracoes: 13/10/2010 - Adicionado verificação de vigencia
                            dos procuradores.(Gabriel - DB1).
                             
               07/12/2010 - Retirado verificação de vigencia dos procuradores
                            que agora é feito dentro da BO 31 .(Gabriel - DB1).
   
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0031 AS HANDLE                                         NO-UNDO.

{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0051tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/*...........................................................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
    
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.    

/*****************************************************************************/
/**      Procedure para carregar dados para montar o cabeçalho da tela      **/
/*****************************************************************************/
PROCEDURE carrega_dados_conta:

    /* buscar os dados para preencher o combo dos titulares */
    RUN busca_dados_associado IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados-ass,
                                     OUTPUT TABLE tt-titular) .

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a "+
                                              "operacao. Procedure: Busca " +
                                              "Dados do Associado.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.

    RUN obtem-cabecalho IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-mensagens-contas,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-cabec).

    IF  RETURN-VALUE = "NOK" THEN
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-cabec:HANDLE,
                               INPUT "Cabecalho").
            RUN piXmlExport   (INPUT TEMP-TABLE tt-dados-ass:HANDLE,
                               INPUT "Associado").
            RUN piXmlExport   (INPUT TEMP-TABLE tt-titular:HANDLE,
                               INPUT "Titulares").
            RUN piXmlExport   (INPUT TEMP-TABLE tt-mensagens-contas:HANDLE,
                               INPUT "Mensagens").
            RUN piXmlSave.         
        END.
        
END PROCEDURE.

/*****************************************************************************/
/**      Procedure para buscar os dados dos titulares da conta              **/
/*****************************************************************************/
PROCEDURE busca_dados_associado:

    RUN busca_dados_associado IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados-ass,
                                     OUTPUT TABLE tt-titular).

    IF  RETURN-VALUE = "NOK" THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-ass:HANDLE,
                             INPUT "Associado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-titular:HANDLE,
                             INPUT "Titulares").
            RUN piXmlSave.
        END.
        
END PROCEDURE.
