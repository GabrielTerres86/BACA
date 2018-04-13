/*.............................................................................

    Programa: xb1wgen0074.p
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 12/01/2016

    Objetivo  : BO de Comunicacao XML x BO - CONTAS, CONTA CORRENTE

    Alteracoes: 29/07/2010 - Ajuste para exclusao de titulares (David).
                           - Incluir dtmvtolt na Busca_Dados (Guilherme).
                           
                08/02/2013 - Incluir campo flgrestr em procedure grava_dados
                             (Lucas R.)
                             
                12/06/2013 - Consorcio (Gabriel).
               
                28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 
                             'flgcrdpa' (Jaison)
                             
                10/07/2014 - Alterações para criticar propostas de cart. cred. 
                             em aberto durante exclusão de titulares
                            (Lucas Lunelli - Projeto Bancoob).
   
                11/08/2015 - Gravacao do novo campo indserma na tabela crapass
                             correspondente a tela CONTAS, OPCAO Conta Corrente                             
                             (Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi)   
   
                27/10/2015 - Inclusao de novo campo para a tela CONTAS,
                             crapass.idastcjt (Jean Michel)  

                12/01/2016 - Remoção do campo flgcrdpa (Anderson).

                06/02/2018 - Adicionado parametro cdcatego. PRJ366 (Lombardi).
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_tpevento AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagepac AS INTE                                           NO-UNDO.
DEF VAR aux_cdtipcta AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitdct AS INTE                                           NO-UNDO.
DEF VAR aux_tpextcta AS INTE                                           NO-UNDO.
DEF VAR aux_cdbcochq AS INTE                                           NO-UNDO.
DEF VAR aux_msgconfi AS CHAR                                           NO-UNDO.
DEF VAR aux_tipconfi AS INTE                                           NO-UNDO.
DEF VAR aux_flgcreca AS LOG                                            NO-UNDO.
DEF VAR aux_flgexclu AS LOG                                            NO-UNDO.
DEF VAR aux_cdsecext AS INTE                                           NO-UNDO.
DEF VAR aux_flgiddep AS LOG                                            NO-UNDO.
DEF VAR aux_tpavsdeb AS INTE                                           NO-UNDO.
DEF VAR aux_dtcnsscr AS DATE                                           NO-UNDO.
DEF VAR aux_dtcnsspc AS DATE                                           NO-UNDO.
DEF VAR aux_dtdsdspc AS DATE                                           NO-UNDO.
DEF VAR aux_inadimpl AS INTE                                           NO-UNDO.
DEF VAR aux_inlbacen AS INTE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_flgrestr AS LOG                                            NO-UNDO.
DEF VAR aux_indserma AS LOG                                            NO-UNDO.
DEF VAR aux_nrctacns AS DECI                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_cdcatego AS INTE                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0074tt.i } 
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }
                                             
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "tpevento" THEN aux_tpevento = tt-param.valorCampo.
            WHEN "cdagepac" THEN aux_cdagepac = INTE(tt-param.valorCampo).
            WHEN "cdtipcta" THEN aux_cdtipcta = INTE(tt-param.valorCampo).
            WHEN "cdsitdct" THEN aux_cdsitdct = INTE(tt-param.valorCampo).
            WHEN "tpextcta" THEN aux_tpextcta = INTE(tt-param.valorCampo).
            WHEN "flgcreca" THEN aux_flgcreca = LOGICAL(tt-param.valorCampo).
            WHEN "cdbcochq" THEN aux_cdbcochq = INTE(tt-param.valorCampo).
            WHEN "cdsecext" THEN aux_cdsecext = INTE(tt-param.valorCampo).
            WHEN "flgiddep" THEN aux_flgiddep = LOGICAL(tt-param.valorCampo).
            WHEN "tpavsdeb" THEN aux_tpavsdeb = INTE(tt-param.valorCampo).
            WHEN "dtcnsscr" THEN aux_dtcnsscr = DATE(tt-param.valorCampo).    
            WHEN "dtcnsspc" THEN aux_dtcnsspc = DATE(tt-param.valorCampo).    
            WHEN "dtdsdspc" THEN aux_dtdsdspc = DATE(tt-param.valorCampo).    
            WHEN "inadimpl" THEN aux_inadimpl = INTE(tt-param.valorCampo).
            WHEN "inlbacen" THEN aux_inlbacen = INTE(tt-param.valorCampo).
            WHEN "flgexclu" THEN aux_flgexclu = LOGICAL(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "flgrestr" THEN aux_flgrestr = LOGICAL(tt-param.valorCampo).
            WHEN "indserma" THEN aux_indserma = LOGICAL(tt-param.valorCampo).
            WHEN "idastcjt" THEN aux_idastcjt = INTE(tt-param.valorCampo).
            WHEN "cdcatego" THEN aux_cdcatego = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_dtmvtolt,
                            INPUT aux_idseqttl,
                            INPUT TRUE,
                            INPUT aux_cddopcao,
                           OUTPUT TABLE tt-conta-corr,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            IF  RETURN-VALUE <> "NOK" THEN
                ASSIGN tt-erro.dscritic = tt-erro.dscritic + RETURN-VALUE.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-conta-corr:HANDLE,
                             INPUT "ContaCorrente").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Busca_Titulares:

    RUN Busca_Titulares IN hBO (INPUT aux_cdcooper,
                                INPUT aux_nrdconta,
                               OUTPUT TABLE tt-titulares ) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            IF  RETURN-VALUE <> "NOK" THEN
                ASSIGN tt-erro.dscritic = tt-erro.dscritic + RETURN-VALUE.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        RUN piXmlSaida (INPUT TEMP-TABLE tt-titulares:HANDLE,
                        INPUT "Titulares").
        
END PROCEDURE.

PROCEDURE Verifica_Exclusao_Titulares:

    RUN Verifica_Exclusao_Titulares IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_cdtipcta,
                                            INPUT aux_cdcatego,
                                            INPUT TRUE,
                                           OUTPUT aux_tipconfi,
                                           OUTPUT aux_msgconfi,
                                           OUTPUT TABLE tt-critica-excl-titulares,
                                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "verificacao de exclusao.".
                END.
          
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-excl-titulares:HANDLE,
                             INPUT "CriticTitulares").
            RUN piXmlAtributo (INPUT "tipconfi", INPUT aux_tipconfi).
            RUN piXmlAtributo (INPUT "msgconfi", 
                               INPUT aux_msgconfi + " Confirma a operacao?").            
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_dtmvtolt,
                             INPUT aux_tpevento,
                             INPUT aux_cdtipcta,
                             INPUT aux_cdbcochq,
                             INPUT aux_tpextcta,
                             INPUT aux_cdagepac,
                             INPUT aux_cdsitdct,
                             INPUT aux_cdsecext,
                             INPUT aux_tpavsdeb,
                             INPUT aux_inadimpl,
                             INPUT aux_inlbacen,
                             INPUT aux_dtdsdspc,
                             INPUT aux_flgexclu,
                             INPUT aux_cdcatego,
                            OUTPUT aux_flgcreca,
                            OUTPUT aux_tipconfi,
                            OUTPUT aux_msgconfi,
                            OUTPUT aux_nmdcampo,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "validacao de dados.".
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
           RUN piXmlAtributo (INPUT "tipconfi", INPUT aux_tipconfi).
           RUN piXmlAtributo (INPUT "msgconfi", 
                              INPUT aux_msgconfi + 
                                    " Deseja continuar?").
           RUN piXmlAtributo (INPUT "flgcreca", 
                              INPUT STRING(aux_flgcreca)).
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT TRUE,        
                            INPUT aux_nrdrowid,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddopcao,
                            INPUT aux_tpevento,
                            INPUT aux_flgcreca,
                            INPUT aux_cdtipcta,
                            INPUT aux_cdsitdct,
                            INPUT aux_cdsecext,
                            INPUT aux_tpextcta,
                            INPUT aux_cdagepac,
                            INPUT aux_cdbcochq,
                            INPUT aux_flgiddep,
                            INPUT aux_tpavsdeb,
                            INPUT aux_dtcnsscr,
                            INPUT aux_dtcnsspc,
                            INPUT aux_dtdsdspc,
                            INPUT aux_inadimpl,
                            INPUT aux_inlbacen,
                            INPUT aux_flgexclu,
                            INPUT aux_flgrestr,
                            INPUT aux_indserma,
                            INPUT aux_idastcjt,
                            INPUT aux_cdcatego,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "gravacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Critica_Cadastro:

    RUN Critica_Cadastro IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdagenci,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                OUTPUT TABLE tt-critica-cabec,
                                OUTPUT TABLE tt-critica-cadas,
                                OUTPUT TABLE tt-critica-ident,
                                OUTPUT TABLE tt-critica-filia,
                                OUTPUT TABLE tt-critica-ender,
                                OUTPUT TABLE tt-critica-comer,
                                OUTPUT TABLE tt-critica-telef,
                                OUTPUT TABLE tt-critica-conju,
                                OUTPUT TABLE tt-critica-ctato,
                                OUTPUT TABLE tt-critica-respo,
                                OUTPUT TABLE tt-critica-ctcor,
                                OUTPUT TABLE tt-critica-regis,
                                OUTPUT TABLE tt-critica-procu,
                                OUTPUT TABLE tt-erro ) NO-ERROR .

    IF  ERROR-STATUS:ERROR THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            IF  RETURN-VALUE <> "NOK" THEN
                ASSIGN tt-erro.dscritic = tt-erro.dscritic + RETURN-VALUE.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-cabec:HANDLE,
                             INPUT "Cabecalho").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-cadas:HANDLE,
                             INPUT "Criticas").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-ident:HANDLE,
                             INPUT "Identificacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-filia:HANDLE,
                             INPUT "Filiacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-ender:HANDLE,
                             INPUT "Endereco").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-comer:HANDLE,
                             INPUT "Comercial").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-telef:HANDLE,
                             INPUT "Telefone").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-conju:HANDLE,
                             INPUT "Conjuge").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-ctato:HANDLE,
                             INPUT "Contato").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-respo:HANDLE,
                             INPUT "ResponsLegal").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-ctcor:HANDLE,
                             INPUT "ContaCorrente").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-regis:HANDLE,
                             INPUT "RegistroAssociado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-critica-procu:HANDLE,
                             INPUT "RepresProcurador").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Gera_Conta_Consorcio:

    RUN Gera_Conta_Consorcio IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_nrdconta,
                                     INPUT aux_cdoperad,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT aux_nrctacns).

    IF   RETURN-VALUE <> "OK" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  NOT AVAILABLE tt-erro  THEN
                 DO:
                     CREATE tt-erro.
                     ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                               "busca de dados.".
                 END.
            
             IF  RETURN-VALUE <> "NOK" THEN
                 ASSIGN tt-erro.dscritic = tt-erro.dscritic + RETURN-VALUE.
            
             RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
         END.
    ELSE
         DO:
             RUN piXmlNew.
             RUN piXmlAtributo (INPUT "nrctacns", INPUT aux_nrctacns).
             RUN piXmlSave.
         END.
         
END PROCEDURE.


