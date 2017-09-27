/*..............................................................................

    Programa: sistema/generico/procedures/xb1wgen0038.p
    Autor   : David
    Data    : Maio/2010                      Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Objetivo  : BO de Comunicacao XML Vs BO da rotina ENDERECO (b1wgen0038.p).

    Alteracoes: 22/09/2010 -  Recebe parametro no busca_dados e passa
                              no XML. (Gabriel - DB1).
                              
                14/04/2011 - Procedimento de busca de endereços.
                             (André - DB1) 
                             
                28/04/2011 - Procedimento trata-inicio-resid.
                             (André - DB1)
                
                15/06/2011 - Adicionado tt de retorno c/ msg em
                             obtem-atualizacao-endereco (Jorge).
                             
                01/07/2011 - Includos parametros nas procedures validar-endereco
                             e alterar-endereco (Henrique).
                             
                01/08/2011 - Adicionado atributo de nmdcampo da tag de erro em
                             procedure valida-endereco-cep. (Jorge)  
                             
                12/12/2011 - Criado procedures referente a tela caddne, alteracao
                             exlusao e importacao de enderecos (Jorge)
                      
                04/04/2012 - Adicionado idorigem na chamada da proc. busca-endereco
                             da BO 38. (Jorge)
                             
                13/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
				 
				01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de 
				              Transferencia entre PAs (Heitor - RKAM)
							  
				27/09/2017 - Removido campos nrdoapto, cddbloco e nrcxapst (PRJ339 - Kelvin).

.............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrendere AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_nrceplog AS INTE                                           NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                           NO-UNDO.
DEF VAR aux_cdseqinc AS INTE                                           NO-UNDO.
DEF VAR aux_tpendass AS INTE                                           NO-UNDO.
DEF VAR aux_incasprp AS INTE                                           NO-UNDO.
DEF VAR aux_nranores AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_vlalugue AS DECI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_complend AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdoapto AS INTE                                           NO-UNDO.
DEF VAR aux_cddbloco AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR aux_dstiplog  AS CHAR                                          NO-UNDO.
DEF VAR aux_nmextlog  AS CHAR                                          NO-UNDO.
DEF VAR aux_nmreslog  AS CHAR                                          NO-UNDO.
DEF VAR aux_nmextbai  AS CHAR                                          NO-UNDO.
DEF VAR aux_nmresbai  AS CHAR                                          NO-UNDO.
DEF VAR aux_nmextcid  AS CHAR                                          NO-UNDO.
DEF VAR aux_nmrescid  AS CHAR                                          NO-UNDO.
DEF VAR aux_dscmplog  AS CHAR                                          NO-UNDO.
DEF VAR aux_dtinires  AS CHAR                                          NO-UNDO.
DEF VAR aux_qtprebem  AS INTE                                          NO-UNDO.
DEF VAR aux_vlprebem  AS DECI                                          NO-UNDO.

DEF VAR aux_flgtpenc AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_flgalter AS LOGI                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_qtdedend AS INTE                                           NO-UNDO.
DEF VAR aux_idorigee AS INTE                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

                                             
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrendere" THEN aux_nrendere = INTE(tt-param.valorCampo).
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "cdseqinc" THEN aux_cdseqinc = INTE(tt-param.valorCampo).
            WHEN "tpendass" THEN aux_tpendass = INTE(tt-param.valorCampo).
            WHEN "dsendere" THEN aux_dsendere = tt-param.valorCampo.
            WHEN "complend" THEN aux_complend = tt-param.valorCampo.
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "cdufende" THEN aux_cdufende = tt-param.valorCampo.
            WHEN "flgtpenc" THEN aux_flgtpenc = LOGICAL(tt-param.valorCampo).
            WHEN "incasprp" THEN aux_incasprp = INTE(tt-param.valorCampo).
            WHEN "nranores" THEN aux_nranores = INTE(tt-param.valorCampo).
            WHEN "vlalugue" THEN aux_vlalugue = DECI(tt-param.valorCampo).
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "dstiplog" THEN aux_dstiplog = tt-param.valorCampo.
            WHEN "nmextlog" THEN aux_nmextlog = tt-param.valorCampo.
            WHEN "nmreslog" THEN aux_nmreslog = tt-param.valorCampo.
            WHEN "nmextbai" THEN aux_nmextbai = tt-param.valorCampo.
            WHEN "nmresbai" THEN aux_nmresbai = tt-param.valorCampo.
            WHEN "nmextcid" THEN aux_nmextcid = tt-param.valorCampo.
            WHEN "nmrescid" THEN aux_nmrescid = tt-param.valorCampo.
            WHEN "dscmplog" THEN aux_dscmplog = tt-param.valorCampo.
            WHEN "dtinires" THEN aux_dtinires = tt-param.valorCampo.
            WHEN "nrdoapto" THEN aux_nrdoapto = INTE(tt-param.valorCampo).
            WHEN "cddbloco" THEN aux_cddbloco = tt-param.valorCampo.
            WHEN "nrceplog" THEN aux_nrceplog = INTE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "flgalter" THEN aux_flgalter = LOGICAL(tt-param.valorCampo).
            WHEN "qtprebem" THEN aux_qtprebem = INTE(tt-param.valorCampo).
            WHEN "vlprebem" THEN aux_vlprebem = DECI(tt-param.valorCampo).
            WHEN "idorigee" THEN aux_idorigee = INTE(tt-param.valorCampo).
            
        END CASE.
    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    


/******************************************************************************/
/**       Procedure para obter enderecos para alteração no InternetBank      **/
/******************************************************************************/
PROCEDURE obtem-enderecos-viainternetbank: 

    RUN obtem-enderecos-viainternetbank IN hBO 
                                       (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-endereco-cooperado).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-endereco-cooperado:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**   Procedure para alteracao dos enderecos do cooperado via InternetBank   **/
/******************************************************************************/
PROCEDURE alterar-endereco-viainternetbank: 

    RUN alterar-endereco-viainternetbank IN hBO (INPUT aux_cdcooper,
                                                 INPUT aux_cdagenci,
                                                 INPUT aux_nrdcaixa,
                                                 INPUT aux_cdoperad,
                                                 INPUT aux_nmdatela,
                                                 INPUT aux_idorigem,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_flgtpenc,
                                                 INPUT aux_dsendere,
                                                 INPUT aux_nrendere,
                                                 INPUT aux_nrcepend,
                                                 INPUT aux_complend,
                                                 INPUT aux_nrdoapto,
                                                 INPUT aux_cddbloco,
                                                 INPUT aux_nmbairro,
                                                 INPUT aux_nmcidade,
                                                 INPUT aux_cdufende,
                                                 INPUT aux_nrcxapst,
                                                 INPUT aux_cdseqinc,
                                                 INPUT aux_tpendass,
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
/**               Procedure para obter enderecos do cooperado                **/
/******************************************************************************/
PROCEDURE obtem-endereco: 

    RUN obtem-endereco IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT TRUE,
                              OUTPUT aux_msgconta,
                              OUTPUT aux_inpessoa,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-endereco-cooperado).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-endereco-cooperado:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "inpessoa", INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**     Procedure para obter endereco que foi atualizado no InternetBank     **/
/******************************************************************************/
PROCEDURE obtem-atualizacao-endereco:

    RUN obtem-atualizacao-endereco IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_nmdatela,
                                           INPUT aux_idorigem,
                                           INPUT aux_nrdconta,
                                           INPUT aux_idseqttl,
                                           INPUT TRUE,
                                          OUTPUT TABLE tt-endereco-cooperado,
                                          OUTPUT TABLE tt-msg-endereco).    

    
    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-endereco-cooperado:HANDLE,
                     INPUT "Dados").
    RUN piXmlExport (INPUT TEMP-TABLE tt-msg-endereco:HANDLE,
                     INPUT "Alertas").
    RUN piXmlSave.

END PROCEDURE.


/******************************************************************************/
/**   Procedure para excluir/confirmar endereco atualizado no InternetBank   **/
/******************************************************************************/
PROCEDURE gerenciar-atualizacao-endereco:

    RUN gerenciar-atualizacao-endereco IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_idorigem,
                                               INPUT aux_nrdconta,
                                               INPUT aux_idseqttl,
                                               INPUT aux_cddopcao,
                                               INPUT aux_dtmvtolt,
                                               INPUT TRUE,
                                              OUTPUT aux_tpatlcad,
                                              OUTPUT aux_msgatcad,
                                              OUTPUT aux_chavealt,
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
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT STRING(aux_tpatlcad)).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**                Procedure para validar endereco do cooperado              **/
/******************************************************************************/
PROCEDURE validar-endereco: 

    RUN validar-endereco IN hBO (INPUT aux_cdcooper, 
                                 INPUT aux_cdagenci, 
                                 INPUT aux_nrdcaixa, 
                                 INPUT aux_cdoperad, 
                                 INPUT aux_nmdatela, 
                                 INPUT aux_idorigem, 
                                 INPUT aux_nrdconta, 
                                 INPUT aux_idseqttl, 
                                 INPUT aux_incasprp, 
                                 INPUT aux_dtinires, 
                                 INPUT aux_vlalugue, 
                                 INPUT aux_dsendere, 
                                 INPUT aux_nrendere, 
                                 INPUT aux_nrcepend, 
                                 INPUT aux_complend,                                  
                                 INPUT aux_nmbairro, 
                                 INPUT aux_nmcidade, 
                                 INPUT aux_cdufende,                                  
                                 INPUT aux_tpendass,
                                 INPUT FALSE,
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
/**                Procedure para alterar endereco do cooperado              **/
/******************************************************************************/
PROCEDURE alterar-endereco: 

    RUN alterar-endereco IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_cddopcao,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_incasprp,
                                 INPUT aux_dtinires,
                                 INPUT aux_vlalugue,
                                 INPUT aux_dsendere,
                                 INPUT aux_nrendere,
                                 INPUT aux_nrcepend,
                                 INPUT aux_complend,                                 
                                 INPUT aux_nmbairro,
                                 INPUT aux_nmcidade,
                                 INPUT aux_cdufende,                                 
                                 INPUT aux_qtprebem,
                                 INPUT aux_vlprebem,
                                 INPUT aux_tpendass,
                                 INPUT TRUE,
                                 INPUT aux_idorigee,
                                OUTPUT aux_msgalert,
                                OUTPUT aux_tpatlcad,
                                OUTPUT aux_msgatcad,
                                OUTPUT aux_chavealt,
                                OUTPUT aux_msgrvcad,
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
            RUN piXmlAtributo (INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT STRING(aux_tpatlcad)).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.



/******************************************************************************/
/**                   Procedure para busca de endereco                       **/
/******************************************************************************/
PROCEDURE busca-endereco: 

    RUN busca-endereco IN hBO (INPUT aux_nrcepend,
                               INPUT aux_dsendere,
                               INPUT aux_nmcidade,
                               INPUT aux_cdufende,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                               INPUT aux_idorigem,
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-endereco).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-endereco:HANDLE,
                             INPUT "Enderecos").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**                   Procedure para validar endereco CEP                    **/
/******************************************************************************/
PROCEDURE valida-endereco-cep: 

    DEF VAR aux_nmdcampo AS CHAR                                     NO-UNDO.

    RUN valida-endereco-cep IN hBO (INPUT aux_cdcooper, 
                                    INPUT aux_cdagenci, 
                                    INPUT aux_nrdcaixa, 
                                    INPUT aux_cdoperad,
                                    INPUT aux_nrcepend,
                                    INPUT aux_cdufende,
                                    INPUT aux_dstiplog,
                                    INPUT aux_nmextlog,
                                    INPUT aux_nmreslog,
                                    INPUT aux_nmextbai,
                                    INPUT aux_nmresbai,
                                    INPUT aux_nmextcid,
                                    INPUT aux_nmrescid,
                                    INPUT aux_dscmplog,
                                    INPUT aux_nrdrowid,
                                   OUTPUT aux_nmdcampo,
                                   OUTPUT TABLE tt-erro) NO-ERROR.
    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

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
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**                   Procedure para gravar endereco CEP                     **/
/******************************************************************************/
PROCEDURE gravar-endereco-cep: 

    RUN gravar-endereco-cep IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_idorigem,
                                    INPUT aux_dtmvtolt,
                                    INPUT TRUE,
                                    INPUT aux_nrcepend,
                                    INPUT aux_cdufende,
                                    INPUT aux_dstiplog,
                                    INPUT aux_nmextlog,
                                    INPUT aux_nmreslog,
                                    INPUT aux_nmextbai,
                                    INPUT aux_nmresbai,
                                    INPUT aux_nmextcid,
                                    INPUT aux_nmrescid,
                                    INPUT aux_dscmplog,
                                    INPUT aux_nrdrowid,
                                    INPUT aux_flgalter,
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
/**              Procedure para tratar campo inicio residencia               **/
/******************************************************************************/
PROCEDURE trata-inicio-resid: 

    DEF VAR aux_nranores AS CHAR                                     NO-UNDO.

    RUN trata-inicio-resid IN hBO ( INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_dtinires,
                                   OUTPUT aux_nranores,
                                   OUTPUT TABLE tt-erro ).

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
            RUN piXmlAtributo (INPUT "nranores",INPUT aux_nranores).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**         Procedure para excluir enderecos cadasrados pelo Ayllos          **/
/******************************************************************************/
PROCEDURE exclui-endereco-ayllos: 

    RUN exclui-endereco-ayllos IN hBO ( INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_flgerlog,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdrowid,
                                       OUTPUT TABLE tt-erro ).

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
/**             Procedure para copiar os arquivos dos correios               **/
/******************************************************************************/
PROCEDURE copia_arquivos_correios: 

    RUN copia_arquivos_correios IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                       OUTPUT TABLE tt-arquivos,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-arquivos:HANDLE,
                             INPUT "Arquivos").

            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**               Procedure para gravar enderecos dos correios               **/
/******************************************************************************/
PROCEDURE grava-importacao: 

    RUN grava-importacao IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdufende,
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

/*............................................................................*/

