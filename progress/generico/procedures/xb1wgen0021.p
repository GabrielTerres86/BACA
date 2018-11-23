/*.............................................................................

   Programa: xb1wgen0021.p
   Autor   : Murilo/David
   Data    : Setembro/2007                     Ultima atualizacao: 13/11/2018

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Plano de Capital (b1wgen0021.p)

   Alteracoes: 
               04/10/2011 - Adicionado o parametro par_flgerlog na chamada da 
                            procedure extrato_cotas (Rogerius Militão - DB1)
                            
               14/10/2013 - Adicionado procedures integraliza_cotas e
                            estorna_integralizacao. (Fabricio)
                            
               25/02/2014 - Criado procedures valida-dados-alteracao-plano e
                            altera-plano. (Fabricio)

               27/09/2016 - Ajustado rotina de Estorno para que utilize
                            a rotina de cancelamento de integralização.
                            M169 (Ricardo Linhares).
							
			   13/11/2017 - Ajuste para gravar o tipo de Autorizacao (Andrey Formigari - Mouts).

............................................................................ */


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_qtpremax AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_tpautori AS INTE                                           NO-UNDO.
        
DEF VAR aux_vlprepla AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldant AS DECI                                           NO-UNDO.

DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                           NO-UNDO.

DEF VAR aux_flgpagto AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.

DEF VAR aux_vintegra AS DECI                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DECI                                           NO-UNDO.
DEF VAR aux_flgsaldo AS LOGI                                           NO-UNDO.

DEF VAR aux_cdtipcor AS INTE                                           NO-UNDO.
DEF VAR aux_vlcorfix AS DECI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEF VAR aux_rowidapp AS ROWID NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "vlprepla" THEN aux_vlprepla = DECI(tt-param.valorCampo).
            WHEN "flgpagto" THEN aux_flgpagto = LOGICAL(tt-param.valorCampo).
            WHEN "qtpremax" THEN aux_qtpremax = INTE(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "vintegra" THEN aux_vintegra = DECI(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = DECI(tt-param.valorCampo).
            WHEN "flgsaldo" THEN aux_flgsaldo = LOGICAL(tt-param.valorCampo).
            WHEN "cdtipcor" THEN aux_cdtipcor = INTE(tt-param.valorCampo).
            WHEN "vlcorfix" THEN aux_vlcorfix = DECI(tt-param.valorCampo).
            WHEN "tpautori" THEN aux_tpautori = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Estorno" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-lancamentos.
                       ASSIGN aux_rowidapp = ROWID(tt-lancamentos).
                    END.

                FIND tt-lancamentos WHERE ROWID(tt-lancamentos) = aux_rowidapp
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nrdocmto" THEN
                        tt-lancamentos.nrdocmto = DECI(tt-param-i.valorCampo).
                    WHEN "vllanmto" THEN
                        tt-lancamentos.vllanmto = DECI(tt-param-i.valorCampo).
                    WHEN "lctrowid" THEN 
                        tt-lancamentos.lctrowid = INTE(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para obter saldo do capital                   **/
/******************************************************************************/
PROCEDURE obtem-saldo-cotas:

    RUN obtem-saldo-cotas IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                 OUTPUT TABLE tt-saldo-cotas,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-saldo-cotas:HANDLE,
                        INPUT "Dados").
     
END PROCEDURE.


/******************************************************************************/
/**               Procedure para consultar extrato do capital                **/
/******************************************************************************/
PROCEDURE extrato_cotas:

    RUN extrato_cotas IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_dtmvtolt,
                              INPUT aux_dtiniper,
                              INPUT aux_dtfimper,
                              INPUT TRUE,
                             OUTPUT aux_vlsldant,
                             OUTPUT TABLE tt-extrato_cotas).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-extrato_cotas:HANDLE,
                     INPUT "Dados").
    RUN piXmlAtributo (INPUT "vlsldant", INPUT STRING(aux_vlsldant)).
    RUN piXmlSave.         
        
END PROCEDURE.


/******************************************************************************/
/**           Procedure para obter dados do plano de capital atual           **/
/******************************************************************************/
PROCEDURE obtem_dados_capital:

    RUN obtem_dados_capital IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_dtmvtolt,
                                    INPUT TRUE, /** GERAR LOG **/
                                   OUTPUT TABLE tt-dados-capital,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-capital:HANDLE,
                        INPUT "Dados").
     
END PROCEDURE.


/******************************************************************************/
/**         Procedure para consultar subscricoes iniciais no capital         **/
/******************************************************************************/
PROCEDURE proc-subscricao:

    RUN proc-subscricao IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                               OUTPUT TABLE tt-subscricao).

    RUN piXmlSaida (INPUT TEMP-TABLE tt-subscricao:HANDLE,
                    INPUT "Dados").
                                            
END PROCEDURE.


/******************************************************************************/
/** Procedure para gerar novo plano de capital ou obter dados se ja existir  **/
/** um novo plano cadastrado                                                 **/
/******************************************************************************/
PROCEDURE obtem-novo-plano:

    RUN obtem-novo-plano IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_dtmvtolt,
                                OUTPUT TABLE tt-horario,
                                OUTPUT TABLE tt-novo-plano,
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
            RUN piXmlSaida (INPUT TEMP-TABLE tt-novo-plano:HANDLE,
                            INPUT "Dados").
        END.
                        
END PROCEDURE.


/******************************************************************************/
/**         Procedure para validar dados para novo plano de capital          **/
/******************************************************************************/
PROCEDURE valida-dados-plano:

    RUN valida-dados-plano IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_vlprepla,
                                   INPUT aux_cdtipcor,
                                   INPUT aux_vlcorfix,
                                   INPUT aux_flgpagto,
                                   INPUT aux_qtpremax,
                                   INPUT aux_dtdpagto,
                                   INPUT aux_flgerlog,
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
        
END PROCEDURE.

/******************************************************************************/
/**     Procedure para validar os dados do plano que podem ser alterados     **/
/******************************************************************************/
PROCEDURE valida-dados-alteracao-plano:

    RUN valida-dados-alteracao-plano IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nmdatela,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_vlprepla,
                                             INPUT aux_cdtipcor,
                                             INPUT aux_vlcorfix,
                                             INPUT aux_flgerlog,
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
        
END PROCEDURE.

/******************************************************************************/
/**              Procedure para cadastrar novo plano de capital              **/
/******************************************************************************/
PROCEDURE cria-plano:

    RUN cria-plano IN hBO (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_nmdatela,
                           INPUT aux_idorigem,
                           INPUT aux_nrdconta,
                           INPUT aux_idseqttl,
                           INPUT aux_dtmvtolt,
                           INPUT aux_vlprepla,
                           INPUT aux_cdtipcor,
                           INPUT aux_vlcorfix,
                           INPUT aux_flgpagto,
                           INPUT aux_qtpremax,
                           INPUT aux_dtdpagto,
                           INPUT aux_tpautori,
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

END PROCEDURE.

/******************************************************************************/
/**              Procedure para alterar o plano de capital                   **/
/******************************************************************************/
PROCEDURE altera-plano:

    RUN altera-plano IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT aux_dtmvtolt,
                             INPUT aux_vlprepla,
                             INPUT aux_cdtipcor,
                             INPUT aux_vlcorfix,
                             INPUT aux_flgpagto,
                             INPUT aux_qtpremax,
                             INPUT aux_dtdpagto,
                             INPUT aux_tpautori,
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

END PROCEDURE.

/******************************************************************************/
/**               Procedure para excluir novo plano cadastrado               **/
/******************************************************************************/
PROCEDURE cancelar-plano-atual:

    RUN cancelar-plano-atual IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_tpautori,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-cancelamento).
    
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
            RUN piXmlSaida (INPUT TEMP-TABLE tt-cancelamento:HANDLE,
                            INPUT "Dados").
        END.

END PROCEDURE.


/******************************************************************************/
/**        Procedure para emitir autorizacao do novo plano de capital        **/
/******************************************************************************/
PROCEDURE autorizar-novo-plano:

    RUN autorizar-novo-plano IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-autorizacao).

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
            RUN piXmlSaida (INPUT TEMP-TABLE tt-autorizacao:HANDLE,
                            INPUT "Dados").
        END.

END PROCEDURE.


/******************************************************************************/
/**        Procedure para imprimir protocolo do novo plano de capital        **/
/******************************************************************************/
PROCEDURE imprimir_protocolo:

    RUN autorizar-novo-plano IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-protocolo).

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
            RUN piXmlSaida (INPUT TEMP-TABLE tt-protocolo:HANDLE,
                            INPUT "Dados").
        END.
        
END PROCEDURE.

PROCEDURE integraliza_cotas:

    RUN integraliza_cotas IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_vintegra,
                                  INPUT aux_flgsaldo,
                                 OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " + 
                                       "operacao.".
        END.
                
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "flgsaldo", INPUT aux_flgsaldo).
        RUN piXmlSave.
    END.


END PROCEDURE.

PROCEDURE busca_integralizacoes:

    RUN busca_integralizacoes IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtmvtolt,
                                     OUTPUT TABLE tt-lancamentos,
                                     OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " + 
                                       "operacao.".
        END.
                
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
    END.
    ELSE
        RUN piXmlSaida (INPUT TEMP-TABLE tt-lancamentos:HANDLE, INPUT "Dados").

END PROCEDURE.

PROCEDURE estorna_integralizacao:

    RUN estorna_integralizacao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_dtmvtolt,
                                       INPUT TABLE tt-lancamentos,
                                      OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " + 
                                       "operacao.".
        END.
                
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlSave.
    END.

END PROCEDURE.
