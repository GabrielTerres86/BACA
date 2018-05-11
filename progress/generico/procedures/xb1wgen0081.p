/*..............................................................................

   Programa: xb1wgen0081.p
   Autor   : Adriano
   Data    : 01/12/2010                       Ultima atualizacao: 03/03/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Consulta de Saldo e Extrato de
               Aplicacoes (b1wgen0081.p)

   Alteracoes:  11/08/2011 - Adicionado Proc. obtem-resgates-conta (Jorge)  

                12/08/2011 - Adicionado procedure calcula-saldo-resgate-varias.
                             (Fabricio)
                           - Adicionado procedure 
                             cancelar-varias-resgates-aplicacao (Jorge)

                16/08/2011 - Criado procedure 
                             retorna-aplicacoes-resgate-automatico. (Fabricio)

                08/09/2011 - Receber flgerlog quando passado. ( Gabriel - DB1 )

                18/09/2012 - Novos parametros DATA na chamada da procedure
                             obtem-dados-aplicacoes (Guilherme/Supero).
                             
                23/08/2013 - Implementação novos produtos Aplicação (Lucas).
                
                10/06/2014 - Ajustes referente ao projeto de captacao
                             (Adriano)
                
                17/09/2014 - Adicionado as procedures 
                                - consulta-agendamento 
                                - excluir-agendamento 
                                - validar-novo-agendamento 
                                - incluir-novo-agendamento 
                                - soma-data-vencto
                                - busca-intervalo-dias
                                - cons-qtd-mes-age
                                - excluir-agendamento-det
                                - consulta-agendamento-det
                                - atualiza-status-agendmto
                             (Douglas - Projeto Captação Internet 2014/2)
                             
                13/10/2014 - Adicionado as procedures 
                                - busca-proxima-data-movimento 
                             (Douglas - Projeto Captação Internet 2014/2)
                             
                28/10/2014 - Adicionado parametro na incluir-novo-agendamento
                             (Douglas - Projeto Captação Internet 2014/2)
                 
                05/12/2014 - Retirada da procedure calcula-saldo-resgate-varias,
                             somente chamada via OCI (Jean Michel).
                             
                08/12/2014 - Retirada da procedure retorna-aplicacoes-resgate-automatico,
                             somente chamada via OCI (Jean Michel).
                             
                09/01/2015 - Implementado novo parametro na procedure 
                             consultar-saldo-acumulado (Jean Michel).
                 
                03/03/2015 - Retirado procedure obtem-resgates-conta (Jean Michel).             
..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DECI                                           NO-UNDO.
DEF VAR aux_tpaplica AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiaapl AS INTE                                           NO-UNDO.
DEF VAR aux_cdperapl AS INTE                                           NO-UNDO.
DEF VAR aux_tpaplrdc AS INTE                                           NO-UNDO.
DEF VAR aux_cdageapl AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiacar AS INTE                                           NO-UNDO.
DEF VAR aux_tpmodelo AS INTE                                           NO-UNDO.
DEF VAR aux_tprelato AS INTE                                           NO-UNDO.
DEF VAR aux_tpaplic2 AS INTE                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_tpresgat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dsaplica AS CHAR                                           NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                                           NO-UNDO.

/* Numero dos documento de resgate separados por ";" */
DEF VAR aux_dsdocmto AS CHAR                                           NO-UNDO.

DEF VAR aux_dtresgat AS DATE                                           NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.
DEF VAR aux_dtvctini AS DATE                                           NO-UNDO.
DEF VAR aux_dtvctfim AS DATE                                           NO-UNDO.


DEF VAR aux_vlsldapl AS DECI                                           NO-UNDO.
DEF VAR aux_vlresgat AS DECI                                           NO-UNDO.
DEF VAR aux_vlaplica AS DECI                                           NO-UNDO.
DEF VAR aux_vllanmto AS DECI                                           NO-UNDO.

DEF VAR aux_flgcance AS LOGI                                           NO-UNDO.
DEF VAR aux_flcadrgt AS LOGI                                           NO-UNDO.
DEF VAR aux_flgctain AS LOGI                                           NO-UNDO.
DEF VAR aux_flmensag AS LOGI                                           NO-UNDO.
DEF VAR aux_flgvalid AS LOGI                                           NO-UNDO.
DEF VAR aux_flgdebci AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI INIT TRUE                                 NO-UNDO.

DEF VAR aux_txaplica LIKE craplap.txaplica                             NO-UNDO.
DEF VAR aux_txaplmes LIKE craplap.txaplmes                             NO-UNDO.

DEF VAR aux_flagauto AS LOGI                                           NO-UNDO.
DEF VAR aux_vlsldtot AS DECI                                           NO-UNDO.
DEF VAR aux_vltotrgt AS DECI                                           NO-UNDO.

DEF VAR aux_rowidapp AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidres AS ROWID                                          NO-UNDO.
DEF VAR aux_rowiddad AS ROWID                                          NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.

/* Tipo de Agendamento => 0 - Aplicacao / 1 - Resgate / 2 - Todos */
DEF VAR aux_flgtipar AS INTE                                           NO-UNDO.
DEF VAR aux_nrctraar AS INTE                                           NO-UNDO.
DEF VAR aux_vlparaar LIKE crapaar.vlparaar                             NO-UNDO.
DEF VAR aux_flgtipin AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniaar LIKE crapaar.dtiniaar                             NO-UNDO.
DEF VAR aux_dtdiaaar LIKE crapaar.dtdiaaar                             NO-UNDO.
DEF VAR aux_qtmesaar LIKE crapaar.qtmesaar                             NO-UNDO.
DEF VAR aux_dtiniitr AS DATE                                           NO-UNDO.
DEF VAR aux_dtfinitr AS DATE                                           NO-UNDO.
DEF VAR aux_numrdias AS INTE                                           NO-UNDO.
DEF VAR aux_qtmesage AS INTE                                           NO-UNDO.
DEF VAR aux_detagend AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdiaven AS INTE                                           NO-UNDO.

DEF VAR aux_cdopera2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cddsenha AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:
    
    DEFINE VARIABLE aux_rowidapp AS ROWID       NO-UNDO.        

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nraplica" THEN aux_nraplica = INTE(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = DECI(tt-param.valorCampo).
            WHEN "tpaplica" THEN aux_tpaplica = INTE(tt-param.valorCampo).
            WHEN "qtdiaapl" THEN aux_qtdiaapl = INTE(tt-param.valorCampo).
            WHEN "cdperapl" THEN aux_cdperapl = INTE(tt-param.valorCampo).
            WHEN "dtresgat" THEN aux_dtresgat = DATE(tt-param.valorCampo).
            WHEN "dtvencto" THEN aux_dtvencto = DATE(tt-param.valorCampo).
            WHEN "vlsldapl" THEN aux_vlsldapl = DECI(tt-param.valorCampo).
            WHEN "vlresgat" THEN aux_vlresgat = DECI(tt-param.valorCampo).
            WHEN "vlaplica" THEN aux_vlaplica = DECI(tt-param.valorCampo).
            WHEN "flgcance" THEN aux_flgcance = LOGICAL(tt-param.valorCampo).
            WHEN "flcadrgt" THEN aux_flcadrgt = LOGICAL(tt-param.valorCampo).
            WHEN "flgctain" THEN aux_flgctain = LOGICAL(tt-param.valorCampo).
            WHEN "flmensag" THEN aux_flmensag = LOGICAL(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "tpresgat" THEN aux_tpresgat = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdageapl" THEN aux_cdageapl = INTE(tt-param.valorCampo).
            WHEN "qtdiacar" THEN aux_qtdiacar = INTE(tt-param.valorCampo).
            WHEN "flgdebci" THEN aux_flgdebci = LOGICAL(tt-param.valorCampo).
            WHEN "vllanmto" THEN aux_vllanmto = DECI(tt-param.valorCampo).
            WHEN "flagauto" THEN aux_flagauto = LOGICAL(tt-param.valorCampo).
            WHEN "vltotrgt" THEN aux_vltotrgt = DECI(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "idtipapl" THEN aux_idtipapl = tt-param.valorCampo.

            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).
            WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "tpmodelo" THEN aux_tpmodelo = INTE(tt-param.valorCampo).
            WHEN "dtvctini" THEN aux_dtvctini = DATE(tt-param.valorCampo).
            WHEN "dtvctfim" THEN aux_dtvctfim = DATE(tt-param.valorCampo).
            WHEN "tprelato" THEN aux_tprelato = INTE(tt-param.valorCampo).
            WHEN "tpaplic2" THEN aux_tpaplic2 = INTE(tt-param.valorCampo).
            WHEN "dsaplica" THEN aux_dsaplica = tt-param.valorCampo.
            WHEN "flgtipar" THEN aux_flgtipar = INTE(tt-param.valorCampo).
            WHEN "nrctraar" THEN aux_nrctraar = INTE(tt-param.valorCampo).
            WHEN "vlparaar" THEN aux_vlparaar = DECI(tt-param.valorCampo).
            WHEN "flgtipin" THEN aux_flgtipin = INTE(tt-param.valorCampo).
            WHEN "dtiniaar" THEN aux_dtiniaar = DATE(tt-param.valorCampo).
            WHEN "dtdiaaar" THEN aux_dtdiaaar = INTE(tt-param.valorCampo).
            WHEN "qtmesaar" THEN aux_qtmesaar = INTE(tt-param.valorCampo).
            WHEN "dtiniitr" THEN aux_dtiniitr = DATE(tt-param.valorCampo).
            WHEN "dtfinitr" THEN aux_dtfinitr = DATE(tt-param.valorCampo).
            WHEN "detagend" THEN aux_detagend = tt-param.valorCampo.
            WHEN "qtdiaven" THEN aux_qtdiaven = INTE(tt-param.valorCampo).
                
            WHEN "cdopera2" THEN aux_cdopera2 = tt-param.valorCampo.
            WHEN "cddsenha" THEN aux_cddsenha = tt-param.valorCampo.

/*             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo. */
/*             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo. */

        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/


    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Resgates" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-resg-aplica.
                       ASSIGN aux_rowidapp = ROWID(tt-resg-aplica).
                    END.

                FIND tt-resg-aplica WHERE ROWID(tt-resg-aplica) = aux_rowidapp
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "dtresgat" THEN
                        tt-resg-aplica.dtresgat = DATE(tt-param-i.valorCampo).
                    WHEN "nrdocmto" THEN
                        tt-resg-aplica.nrdocmto = INTE(tt-param-i.valorCampo).
                    WHEN "nraplica" THEN
                        tt-resg-aplica.nraplica = INTE(tt-param-i.valorCampo).
                    WHEN "idtipapl" THEN
                        tt-resg-aplica.idtipapl = tt-param-i.valorCampo.
                END CASE.
            END.

            WHEN "Resposta" THEN DO:
                
                IF FIRST-OF(tt-param-i.sqControle) THEN
                DO:
                    CREATE tt-resposta-cliente.
                    ASSIGN aux_rowidres = ROWID(tt-resposta-cliente).
                END.

                FIND tt-resposta-cliente WHERE ROWID(tt-resposta-cliente) =
                                                        aux_rowidres NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nraplica" THEN
                        tt-resposta-cliente.nraplica = 
                                                INTE(tt-param-i.valorCampo).
                    WHEN "dtvencto" THEN
                        tt-resposta-cliente.dtvencto =
                                                DATE(tt-param-i.valorCampo).
                    WHEN "resposta" THEN
                        tt-resposta-cliente.resposta = tt-param-i.valorCampo.
                END CASE.
            END.

            WHEN "Dados_Resgate" THEN DO:
                
                IF FIRST-OF(tt-param-i.sqControle) THEN
                DO:
                    CREATE tt-dados-resgate.
                    ASSIGN aux_rowiddad = ROWID(tt-dados-resgate).
                END.

                FIND tt-dados-resgate WHERE ROWID(tt-dados-resgate) = 
                                                    aux_rowiddad NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nraplica" THEN
                        tt-dados-resgate.nraplica =
                                                INTE(tt-param-i.valorCampo).

                    WHEN "dtmvtolt" THEN
                        tt-dados-resgate.dtmvtolt =
                                                DATE(tt-param-i.valorCampo).
                    WHEN "dshistor" THEN
                        tt-dados-resgate.dshistor = tt-param-i.valorCampo.

                    WHEN "nrdocmto" THEN
                        tt-dados-resgate.nrdocmto = tt-param-i.valorCampo.

                    WHEN "dtvencto" THEN
                        tt-dados-resgate.dtvencto =
                                                DATE(tt-param-i.valorCampo).

                    WHEN "sldresga" THEN
                        tt-dados-resgate.sldresga =
                                                DECI(tt-param-i.valorCampo).

                    WHEN "vlresgat" THEN
                        tt-dados-resgate.vlresgat =
                                                DECI(tt-param-i.valorCampo).
                    
                    WHEN "tpresgat" THEN
                        tt-dados-resgate.tpresgat = tt-param-i.valorCampo.

                    WHEN "idtipapl" THEN
                        tt-dados-resgate.idtipapl = tt-param-i.valorCampo.

                END CASE.
            END.
        END CASE.
    END.
END PROCEDURE.


/******************************************************************************/
/**             Procedure para consultar aplicacoes do associado             **/
/******************************************************************************/
PROCEDURE obtem-dados-aplicacoes:
    
    RUN obtem-dados-aplicacoes IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_nraplica,
                                       INPUT aux_cdprogra,
                                       INPUT aux_flgerlog,
                                       INPUT ?,
                                       INPUT ?,
                                      OUTPUT aux_vlsldapl,
                                      OUTPUT TABLE tt-saldo-rdca,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-saldo-rdca:HANDLE,
                        INPUT "Dados").
 
END PROCEDURE.

PROCEDURE retorna-aplicacoes-resgate-manual:

    RUN retorna-aplicacoes-resgate-manual IN hBO (INPUT aux_cdcooper,
                                                  INPUT aux_cdagenci,
                                                  INPUT aux_nrdcaixa,
                                                  INPUT aux_cdoperad,
                                                  INPUT aux_nmdatela,
                                                  INPUT aux_idorigem,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nraplica,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_cdprogra,
                                                  INPUT TRUE,
                                                  OUTPUT TABLE tt-dados-resgate,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-resgate:HANDLE,
                        INPUT "Dados_Resgate").

END PROCEDURE.

/******************************************************************************/
/**       Procedure para verificar permissao de acesso a opcao resgate       **/
/******************************************************************************/
PROCEDURE valida-acesso-opcao-resgate:

    RUN valida-acesso-opcao-resgate IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nraplica,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_cdprogra,
                                            INPUT aux_flcadrgt,
                                            INPUT TRUE,
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
/**        Procedure para obter resgates programados para a aplicacao        **/
/******************************************************************************/
PROCEDURE obtem-resgates-aplicacao:

    RUN obtem-resgates-aplicacao IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_nraplica,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_flgcance,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-resg-aplica).
    
    RUN piXmlSaida (INPUT TEMP-TABLE tt-resg-aplica:HANDLE,
                    INPUT "Dados").

END PROCEDURE.



/******************************************************************************/
/**               Procedure para cancelar varios resgates de aplicacao               **/
/******************************************************************************/
PROCEDURE cancelar-varias-resgates-aplicacao:

    RUN cancelar-varias-resgates-aplicacao IN hBO (INPUT aux_cdcooper,
                                                   INPUT aux_cdagenci,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT aux_cdoperad,
                                                   INPUT aux_nmdatela,
                                                   INPUT aux_idorigem,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT TRUE,
                                                   INPUT TABLE tt-resg-aplica,
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
/**               Procedure para cancelar resgate de aplicacao               **/
/******************************************************************************/
PROCEDURE cancelar-resgates-aplicacao:

    RUN cancelar-resgates-aplicacao IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nraplica,
                                            INPUT aux_nrdocmto,
                                            INPUT aux_dtresgat,
                                            INPUT aux_dtmvtolt,
                                            INPUT TRUE,
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
/**              Procedure para cadastrar resgate de aplicacao               **/
/******************************************************************************/
PROCEDURE cadastrar-resgate-aplicacao:

    RUN cadastrar-resgate-aplicacao IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nraplica,
                                            INPUT aux_tpresgat,
                                            INPUT aux_vlresgat,
                                            INPUT aux_dtresgat,
                                            INPUT aux_flgctain,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_dtmvtopr,
                                            INPUT aux_cdprogra,
                                            INPUT aux_flmensag,
                                            INPUT TRUE,
                                            INPUT aux_cdopera2,
                                            INPUT aux_cddsenha,
                                           OUTPUT aux_nrdocmto,
                                           OUTPUT TABLE tt-msg-confirma,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Confirmacao").
        
END PROCEDURE.        

/******************************************************************************/
/**              Procedure para cadastrar varios resgates de aplicacao       **/
/******************************************************************************/
PROCEDURE cadastrar-varios-resgates-aplicacao:
    
    RUN cadastrar-varios-resgates-aplicacao IN hBO 
                                        (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtresgat,
                                         INPUT aux_flgctain,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_dtmvtopr,
                                         INPUT aux_cdprogra,
                                         INPUT aux_flmensag,
                                         INPUT TRUE,
                                         INPUT TABLE tt-dados-resgate,
                                         OUTPUT aux_dsdocmto,
                                         OUTPUT TABLE tt-msg-confirma,
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
           RUN piXmlAtributo (INPUT "nrdocmto", INPUT STRING(aux_dsdocmto)).
           RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                            INPUT "Confirmacao").
           RUN piXmlSave.
          
       END.
        
END PROCEDURE.

/******************************************************************************/
/**         Procedure para consultar saldos acumulados da aplicacao          **/
/******************************************************************************/
PROCEDURE consultar-saldo-acumulado:

    RUN consultar-saldo-acumulado IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nraplica,
                                          INPUT aux_dtmvtolt,
                                          INPUT TRUE,
                                          INPUT aux_idtipapl,
                                         OUTPUT TABLE tt-dados-acumulo,
                                         OUTPUT TABLE tt-acumula,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-acumulo:HANDLE,
                             INPUT "Dados").
            RUN piXmlExport (INPUT TEMP-TABLE tt-acumula:HANDLE,
                             INPUT "Acumula").
            RUN piXmlSave.
        END.
                        
END PROCEDURE.                        


/******************************************************************************/
/**                Procedure para carregar tipos de aplicacao                **/
/******************************************************************************/
PROCEDURE obtem-tipos-aplicacao:

    RUN obtem-tipos-aplicacao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT TRUE,
                                     OUTPUT TABLE tt-tipo-aplicacao,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-tipo-aplicacao:HANDLE,
                        INPUT "Dados").
        
END PROCEDURE.        


/******************************************************************************/
/**    Procedure para obter carencias de determinada faixa de dias (taxas)   **/
/******************************************************************************/
PROCEDURE obtem-dias-carencia:

    RUN obtem-dias-carencia IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_tpaplica,
                                    INPUT aux_qtdiaapl,
                                    INPUT aux_qtdiacar,
                                    INPUT aux_flgvalid,
                                    INPUT TRUE,
                                   OUTPUT TABLE tt-carencia-aplicacao,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-carencia-aplicacao:HANDLE,
                        INPUT "Dados").

END PROCEDURE. 


/******************************************************************************/
/** Calcular qtde de dias para permanencia da aplicacao e/ou data do resgate **/
/******************************************************************************/
PROCEDURE calcula-permanencia-resgate:

    RUN calcula-permanencia-resgate IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_tpaplica,
                                            INPUT aux_dtmvtolt,
                                            INPUT TRUE,
                                            INPUT aux_qtdiacar,
                                            INPUT-OUTPUT aux_qtdiaapl,
                                            INPUT-OUTPUT aux_dtvencto,
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
            RUN piXmlAtributo (INPUT "qtdiaapl",
                               INPUT STRING(aux_qtdiaapl)).
            RUN piXmlAtributo (INPUT "dtvencto",
                               INPUT STRING(aux_dtvencto,"99/99/9999")).
            RUN piXmlSave.
        END.
        
END PROCEDURE.


/******************************************************************************/
/**   Procedure para calcular saldo acumulado para resgate (Aplicacoes RDC)  **/
/******************************************************************************/
PROCEDURE simular-saldo-acumulado:

    RUN simular-saldo-acumulado IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_tpaplica,
                                        INPUT aux_dtvencto,
                                        INPUT aux_vlaplica,
                                        INPUT aux_cdperapl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_cdprogra,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-dados-acumulo,
                                       OUTPUT TABLE tt-acumula,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-acumulo:HANDLE,
                             INPUT "Dados").
            RUN piXmlExport (INPUT TEMP-TABLE tt-acumula:HANDLE,
                             INPUT "Acumula").
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**                Procedure para validar o tipo de aplicacao                **/
/******************************************************************************/
PROCEDURE validar-tipo-aplicacao:
    
    RUN validar-tipo-aplicacao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_tpaplica,
                                       INPUT TRUE,
                                      OUTPUT aux_tpaplrdc,
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
            RUN piXmlAtributo (INPUT "tpaplrdc", INPUT STRING(aux_tpaplrdc)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**                 Procedure para carregar taxa da aplicacao                **/
/******************************************************************************/
PROCEDURE obtem-taxa-aplicacao:

    RUN obtem-taxa-aplicacao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_tpaplica,
                                     INPUT aux_cdperapl,
                                     INPUT aux_vllanmto,
                                     INPUT TRUE,
                                    OUTPUT aux_txaplica,
                                    OUTPUT aux_txaplmes,
                                    OUTPUT aux_dsaplica,
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
            RUN piXmlAtributo (INPUT "txaplica", 
                               INPUT STRING(aux_txaplica,"zz9.999999")).
            RUN piXmlAtributo (INPUT "txaplmes", 
                               INPUT STRING(aux_txaplmes,"zz9.999999")).
            RUN piXmlAtributo (INPUT "dsaplica", 
                               INPUT STRING(aux_dsaplica, "X(12)")).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/** Procedure que busca dados da aplicacao p/ alteracao, exclusao e inclusao **/
/******************************************************************************/
PROCEDURE buscar-dados-aplicacao:

    RUN buscar-dados-aplicacao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_cddopcao,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_nraplica,
                                       INPUT TRUE,
                                      OUTPUT TABLE tt-tipo-aplicacao,
                                      OUTPUT TABLE tt-dados-aplicacao,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-tipo-aplicacao:HANDLE,
                             INPUT "Tipo").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-aplicacao:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

END PROCEDURE.
                                           

/******************************************************************************/
/**            Procedure para validar operacoes de nova aplicacao            **/
/******************************************************************************/
PROCEDURE validar-nova-aplicacao:  
    
    RUN validar-nova-aplicacao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_inproces,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_dtmvtopr,
                                       INPUT aux_cddopcao,
                                       INPUT aux_tpaplica,
                                       INPUT aux_nraplica,
                                       INPUT aux_qtdiaapl,
                                       INPUT aux_dtresgat,
                                       INPUT aux_qtdiacar,
                                       INPUT aux_cdperapl,
                                       INPUT aux_flgdebci,
                                       INPUT aux_vllanmto,
                                       INPUT TRUE,
                                      OUTPUT aux_nmdcampo,
                                      OUTPUT TABLE tt-msg-confirma,
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
                
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Confirmacao").
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para incluir nova aplicacao                   **/
/******************************************************************************/
PROCEDURE incluir-nova-aplicacao:

    RUN incluir-nova-aplicacao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_inproces,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_dtmvtopr,
                                       INPUT aux_tpaplica,
                                       INPUT aux_qtdiaapl,
                                       INPUT aux_dtresgat,
                                       INPUT aux_qtdiacar,
                                       INPUT aux_cdperapl,
                                       INPUT aux_flgdebci,
                                       INPUT aux_vllanmto,
                                       INPUT TRUE,
                                       OUTPUT aux_nrdocmto,
                                       OUTPUT TABLE tt-msg-confirma,
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
          RUN piXmlAtributo(INPUT "nrdocmto", INPUT STRING(aux_nrdocmto)).
          RUN piXmlExport(INPUT TEMP-TABLE tt-msg-confirma:HANDLE, 
                          INPUT "Notificacao").
          RUN piXmlSave.
       END.

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para excluir nova aplicacao                   **/
/******************************************************************************/
PROCEDURE excluir-nova-aplicacao:
    
    RUN excluir-nova-aplicacao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_inproces,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_dtmvtopr,
                                       INPUT aux_nraplica,
                                       INPUT TRUE,
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
/**                  Procedure para consulta dos agendamentos                **/
/******************************************************************************/
PROCEDURE consulta-agendamento:

    RUN consulta-agendamento IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_nraplica,
                                     INPUT aux_flgtipar,
                                     INPUT 6,
                                     INPUT aux_cdprogra,
                                     INPUT aux_idorigem,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-agendamento).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-agendamento:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**                  Procedure para exclusão dos agendamentos                **/
/******************************************************************************/
PROCEDURE excluir-agendamento:

    RUN excluir-agendamento IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_nrctraar,
                                    INPUT aux_cdoperad,
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
/**                  Procedure para validar os novos agendamentos            **/
/******************************************************************************/
PROCEDURE validar-novo-agendamento:

    RUN validar-novo-agendamento IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_flgtipar,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_vlparaar,
                                         INPUT aux_flgtipin,
                                         INPUT aux_qtdiacar,
                                         INPUT aux_qtmesaar,
                                         INPUT aux_dtiniaar,
                                         INPUT aux_dtdiaaar,
                                         INPUT aux_dtvencto,
                                         INPUT aux_cdoperad,
                                         INPUT aux_cdprogra,
                                         INPUT aux_idorigem,
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
/**                  Procedure para validar os novos agendamentos            **/
/******************************************************************************/
PROCEDURE incluir-novo-agendamento:

    RUN incluir-novo-agendamento IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_flgtipar,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_vlparaar,
                                         INPUT aux_flgtipin,
                                         INPUT aux_qtdiacar,
                                         INPUT aux_qtmesaar,
                                         INPUT aux_dtiniaar,
                                         INPUT aux_dtdiaaar,
                                         INPUT aux_dtvencto,
                                         INPUT aux_qtdiaven,
                                         INPUT aux_cdoperad,
                                         INPUT aux_cdprogra,
                                         INPUT aux_idorigem,
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
/**             Procedure para calcular o vencimento do agendamento          **/
/******************************************************************************/
PROCEDURE soma-data-vencto:

    RUN soma-data-vencto IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_qtdiacar,
                                 INPUT aux_dtiniaar,
                                 INPUT aux_cdoperad,
                                 INPUT aux_cdprogra,
                                 INPUT aux_idorigem,
                                OUTPUT aux_dtvencto,
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
            RUN piXmlAtributo (INPUT "dtvencto",
                               INPUT STRING(aux_dtvencto,"99/99/9999")).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**             Procedure para calcular o vencimento do agendamento          **/
/******************************************************************************/
PROCEDURE busca-intervalo-dias:

    RUN busca-intervalo-dias IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_cdoperad,
                                     INPUT aux_cdprogra,
                                     INPUT aux_idorigem,
                                     INPUT aux_dtiniitr,
                                     INPUT aux_dtfinitr,
                                    OUTPUT aux_numrdias).

    RUN piXmlNew. 
    RUN piXmlAtributo (INPUT "dtvendia",
                       INPUT STRING(aux_numrdias)).
    RUN piXmlSave.

END PROCEDURE.


/******************************************************************************/
/**       Procedure para buscar a quantidade de meses do agendamento         **/
/******************************************************************************/
PROCEDURE cons-qtd-mes-age:

    RUN cons-qtd-mes-age IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdconta,
                                 INPUT aux_cdoperad,
                                 INPUT aux_cdprogra,
                                 INPUT aux_idorigem,
                                OUTPUT aux_qtmesage,
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
             RUN piXmlAtributo (INPUT "qtmesage",
                                INPUT STRING(aux_qtmesage)).
             RUN piXmlSave.
         END.

END PROCEDURE.

/******************************************************************************/
/**            Procedure para exclusão dos detalhes do agendamento           **/
/******************************************************************************/
PROCEDURE excluir-agendamento-det:

    RUN excluir-agendamento-det IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_flgtipar,
                                        INPUT aux_nrdocmto,
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
/**           Procedure para consulta dos detalhes do agendamento            **/
/******************************************************************************/
PROCEDURE consulta-agendamento-det:

    RUN consulta-agendamento-det IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_flgtipar,
                                         INPUT aux_nrdocmto,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-agen-det).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-agen-det:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**           Procedure para consulta dos detalhes do agendamento            **/
/******************************************************************************/
PROCEDURE atualiza-status-agendmto:

    RUN atualiza-status-agendmto IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_detagend,
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
/**           Procedure para consulta dos detalhes do agendamento            **/
/******************************************************************************/
PROCEDURE busca-proxima-data-movimento:

    RUN busca-proxima-data-movimento IN hBO (INPUT aux_cdcooper,
                                            OUTPUT aux_dtmvtopr).

    RUN piXmlNew. 
    RUN piXmlAtributo (INPUT "dtmvtopr",
                       INPUT STRING(aux_dtmvtopr,"99/99/9999")).
    RUN piXmlSave.

END PROCEDURE.
