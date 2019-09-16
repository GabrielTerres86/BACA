/*.............................................................................

   Programa: xb1wgen0039.p
   Autor   : Guilherme
   Data    : Setembro/2009                     Ultima atualizacao: 07/02/2011    

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Relacionamento(b1wgen0039.p)

   Alteracoes:  07/02/2011 - Alteracao nos parametros da BO do historico
                             para trazer a listagem num arquivo PDF
                             (Gabriel).                                                   
                13/08/2019 - Vincular inscricao de pessoa juridica com socio
                             Gabriel Marcos (Mouts) - P484.2 

............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.

DEF VAR aux_dtinique AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimque AS DATE                                           NO-UNDO.
DEF VAR aux_inianoev AS INTE                                           NO-UNDO.
DEF VAR aux_finanoev AS INTE                                           NO-UNDO.
DEF VAR aux_rowidedp AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidadp AS ROWID                                          NO-UNDO.
DEF VAR aux_rowididp AS ROWID                                          NO-UNDO.
DEF VAR aux_opcaosit AS INTE                                           NO-UNDO.
DEF VAR aux_dsobserv AS CHAR                                           NO-UNDO.
DEF VAR aux_tpinseve AS LOGI                                           NO-UNDO.
DEF VAR aux_cdgraupr AS INTE                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_flgdispe AS LOGI                                           NO-UNDO.
DEF VAR aux_nminseve AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdddins AS INTE                                           NO-UNDO.
DEF VAR aux_nrtelefo AS INTE                                           NO-UNDO.
DEF VAR aux_inipesqu AS INTE                                           NO-UNDO.
DEF VAR aux_finpesqu AS INTE                                           NO-UNDO.
DEF VAR aux_idevento AS INTE                                           NO-UNDO.
DEF VAR aux_cdevento AS INTE                                           NO-UNDO.
DEF VAR aux_tpimpres AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.

DEF VAR par_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR par_flgcoope AS LOGI                                           NO-UNDO.
DEF VAR par_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0039tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
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
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            
            WHEN "dtinique" THEN IF  tt-param.valorCampo = "00/00/0000" THEN
                                     aux_dtinique = ?.
                                 ELSE
                                     aux_dtinique = DATE(tt-param.valorCampo).
            WHEN "dtfimque" THEN IF  tt-param.valorCampo = "00/00/0000" THEN
                                    aux_dtfimque = ?.
                                 ELSE
                                     aux_dtfimque = DATE(tt-param.valorCampo).
            WHEN "inianoev" THEN aux_inianoev = INTE(tt-param.valorCampo).
            WHEN "finanoev" THEN aux_finanoev = INTE(tt-param.valorCampo).
            WHEN "rowidedp" THEN aux_rowidedp = TO-ROWID(tt-param.valorCampo).
            WHEN "rowidadp" THEN aux_rowidadp = TO-ROWID(tt-param.valorCampo).
            WHEN "rowididp" THEN aux_rowididp = TO-ROWID(tt-param.valorCampo).
            WHEN "opcaosit" THEN aux_opcaosit = INTE(tt-param.valorCampo).
            WHEN "dsobserv" THEN aux_dsobserv = tt-param.valorCampo.
            WHEN "tpinseve" THEN aux_tpinseve = LOGICAL(tt-param.valorCampo).
            WHEN "cdgraupr" THEN aux_cdgraupr = INTE(tt-param.valorCampo).
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "flgdispe" THEN aux_flgdispe = LOGICAL(tt-param.valorCampo).
            WHEN "nminseve" THEN aux_nminseve = tt-param.valorCampo.
            WHEN "nrdddins" THEN aux_nrdddins = INTE(tt-param.valorCampo).
            WHEN "nrtelefo" THEN aux_nrtelefo = INTE(tt-param.valorCampo).
            WHEN "inipesqu" THEN aux_inipesqu = INTE(tt-param.valorCampo).
            WHEN "finpesqu" THEN aux_finpesqu = INTE(tt-param.valorCampo).
            WHEN "idevento" THEN aux_idevento = INTE(tt-param.valorCampo).
            WHEN "cdevento" THEN aux_cdevento = INTE(tt-param.valorCampo).
            WHEN "tpimpres" THEN aux_tpimpres = tt-param.valorCampo.
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).

        END CASE.
        
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.

/*****************************************************************************
Trazer a quantidade de eventos pendentes e confirmados do cooperado.
Tambem traz a quantidade de eventos em andamento do seu PAC e de quantos
eventos o coop ja participou.(DADOS DA TELA PRINCIPAL, RELACIONAMENTOS - ATENDA)
******************************************************************************/
PROCEDURE obtem-quantidade-eventos:

   RUN obtem-quantidade-eventos IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT YEAR(aux_dtmvtolt),
                                        INPUT aux_idseqttl,
                                        INPUT aux_idorigem,
                                        INPUT aux_nmdatela,
                                        INPUT FALSE, /* Log */
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-qtdade-eventos).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-qtdade-eventos:HANDLE,
                             INPUT "Eventos").
            RUN piXmlSave.
        END.
            
END PROCEDURE.

/*****************************************************************************
Gravar datas de entrega/devolucao do questionario do cooperado na crapass
*****************************************************************************/
PROCEDURE grava-data-questionario:

    RUN grava-data-questionario IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT aux_dtinique,
                                        INPUT aux_dtfimque,
                                        INPUT aux_idseqttl,
                                        INPUT aux_idorigem,
                                        INPUT aux_nmdatela,
                                        INPUT TRUE, /* Log */
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
        
/*****************************************************************************
Trazer todos os eventos de um periodo especifico ou de todos os anos
na qual o cooperado tem uma situacao relacionada a ele.
*****************************************************************************/
PROCEDURE lista-eventos:

    RUN lista-eventos IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrdconta,
                              INPUT aux_inianoev,
                              INPUT aux_finanoev,
                              INPUT aux_idseqttl,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT FALSE, /* Log */
                             OUTPUT TABLE tt-lista-eventos).
    
    RUN piXmlSaida (INPUT TEMP-TABLE tt-lista-eventos:HANDLE,
                    INPUT "Eventos").
END PROCEDURE.    
        
/****************************************************************************
Procedure que traz os detalhes do evento selecionado.
****************************************************************************/
PROCEDURE obtem-detalhe-evento:

    RUN obtem-detalhe-evento IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT YEAR(aux_dtmvtolt),
                                     INPUT aux_rowidedp,
                                     INPUT aux_rowidadp,
                                     INPUT aux_idseqttl,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT FALSE, /* Log */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-detalhe-evento).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-detalhe-evento:HANDLE,
                             INPUT "Evento").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/***************************************************************************** 
Criar arquivo com o termo de compromisso do coooperado com o evento.
******************************************************************************/
PROCEDURE termo-de-compromisso:
    
    RUN termo-de-compromisso IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT aux_rowididp,
                                     INPUT aux_rowidedp,
                                     INPUT aux_idseqttl,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT TRUE, /* Log */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-termo).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo:HANDLE,
                             INPUT "Termo").            
            RUN piXmlSave.
        END.
        
END PROCEDURE.    


/****************************************************************************
Gravar na crapidp a nova situacao da inscricao ao evento selecionado.
****************************************************************************/
PROCEDURE grava-nova-situacao:

    RUN grava-nova-situacao IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_rowididp,
                                    INPUT aux_opcaosit,
                                    INPUT aux_idseqttl,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT TRUE, /* Log */
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

/****************************************************************************
Procedure que traz a lista das inscricoes do evento selecionado. (Do cooperado
ou dos seus familiares, conjuge, etc ...)
*****************************************************************************/
PROCEDURE situacao-inscricao:

    RUN situacao-inscricao IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_rowidedp,
                                   INPUT aux_rowidadp,
                                   INPUT aux_idseqttl,
                                   INPUT aux_idorigem,
                                   INPUT aux_nmdatela,
                                   INPUT FALSE, /* Log */
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-situacao-inscricao).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-situacao-inscricao:HANDLE,
                             INPUT "Situacao_Inscricao").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/*****************************************************************************
Traz a lista de pessoas ja relacionadas com a conta especificada ao evento em
questao , familiares, conjuge , etc....
*****************************************************************************/ 
PROCEDURE inscricoes-da-conta:

    RUN inscricoes-da-conta IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_rowidadp,
                                    INPUT aux_idseqttl,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT FALSE, /* Log */
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-inscricoes-conta).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-inscricoes-conta:HANDLE,
                             INPUT "Incricoes_da_conta").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/***************************************************************************
Procedure que traz os dados do cooperado que esta fazendo a pre-inscricao.
****************************************************************************/
PROCEDURE pre-inscricao:

    RUN pre-inscricao IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrdconta,
                              INPUT aux_rowidadp,
                              INPUT aux_idseqttl,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT FALSE, /* Log */
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-info-cooperado,
                             OUTPUT TABLE tt-grau-parentesco,
                             OUTPUT TABLE tt-inscricoes-conta,
                             OUTPUT par_flgcoope).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-info-cooperado:HANDLE,
                             INPUT "Informacoes_do_cooperado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grau-parentesco:HANDLE,
                             INPUT "Grau_parentesco").
            RUN piXmlExport (INPUT TEMP-TABLE tt-inscricoes-conta:HANDLE,
                             INPUT "Incricoes_da_conta").
            RUN piXmlAtributo(INPUT "flgcoope",INPUT STRING(par_flgcoope,"yes/no")).
            RUN piXmlSave.
        END.    
    
END PROCEDURE.

/**************************************************************************** 
Procedure que traz a lista de todos os eventos em andamento do PAC do associado
*****************************************************************************/
PROCEDURE obtem-eventos-andamento:
    
    RUN obtem-eventos-andamento IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT aux_dsobserv,
                                        INPUT YEAR(aux_dtmvtolt),
                                        INPUT aux_idseqttl,
                                        INPUT aux_idorigem,
                                        INPUT aux_nmdatela,
                                        INPUT FALSE, /* Log */
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-eventos-andamento).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-eventos-andamento:HANDLE,
                             INPUT "Eventos_Andamento").
            RUN piXmlSave.
        END.    
END PROCEDURE.    


/*****************************************************************************
Gravar na crapidp a pre-inscricao ao evento selecionado.
*****************************************************************************/
PROCEDURE grava-pre-inscricao:

    RUN grava-pre-inscricao IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_rowidedp,
                                    INPUT aux_rowidadp,
                                    INPUT aux_tpinseve,
                                    INPUT aux_cdgraupr,
                                    INPUT aux_dsdemail,
                                    INPUT aux_dsobserv,
                                    INPUT aux_flgdispe,
                                    INPUT aux_nminseve, 
                                    INPUT aux_nrdddins,
                                    INPUT aux_nrtelefo,
                                    INPUT aux_idseqttl,
                                    INPUT aux_nrcpfcgc,																		
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT NO, /* Log */
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT par_nrdrowid).

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
            RUN piXmlAtributo (INPUT "nrdrowid",INPUT STRING(par_nrdrowid)).
            RUN piXmlSave.
        END.

END PROCEDURE.    

/****************************************************************************
Procedure que traz a lista do historico da participacao do evento selecionado
do cooperado ou seus familiares, conjuge, etc ...
*****************************************************************************/
PROCEDURE obtem-historico:

    RUN obtem-historico IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nrdconta,
                                INPUT aux_inipesqu,
                                INPUT aux_finpesqu,
                                INPUT aux_idevento,
                                INPUT aux_cdevento,
                                INPUT aux_tpimpres,
                                INPUT aux_idseqttl,
                                INPUT aux_idorigem,
                                INPUT aux_nmdatela,
                                INPUT FALSE, /* Log */
                               OUTPUT TABLE tt-historico-evento,
                               OUTPUT par_nmarquiv,
                               OUTPUT par_nmarqpdf).
    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-historico-evento:HANDLE,
                     INPUT "Eventos_Pesquisados").
    RUN piXmlAtributo (INPUT "nmarqpdf",INPUT par_nmarqpdf).
    RUN piXmlSave.

END PROCEDURE.    
/* .......................................................................... */
