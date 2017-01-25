/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0103.p
     Autor   : Gabriel Capoia dos Santos
     Data    : Julho/2011                       Ultima atualizacao: 31/07/2013

     Objetivo  : BO de Comunicacao XML x BO - Telas de extrato

     Alteracoes: 31/07/2013 - Implementada opcao A da tela EXTRAT (Lucas).

	             06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
			                  da descrição do departamento como parametro e 
						  	  passar o código (Renato Darosci)
.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cddepart AS INTE                                           NO-UNDO.

DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmovmto AS DATE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF VAR aux_cdsecext AS INTE                                           NO-UNDO.
DEF VAR aux_tpextcta AS INTE                                           NO-UNDO.
DEF VAR aux_tpavsdeb AS INTE                                           NO-UNDO.

DEF VAR aux_nrctrrpp AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_dtinimov AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimmov AS DATE                                           NO-UNDO.

DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.  

DEF VAR aux_tpemiext AS INTE                                           NO-UNDO.
DEF VAR aux_descapli AS CHAR                                           NO-UNDO.
DEF VAR aux_tpaplica AS INTE                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
DEF VAR aux_vlsldant AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldtot AS DECI                                           NO-UNDO.
DEF VAR aux_dtmovano AS INTE                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
             WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarquiv" THEN aux_nmarquiv = tt-param.valorCampo.
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "dtmovmto" THEN aux_dtmovmto = DATE(tt-param.valorCampo).
             WHEN "cdsecext" THEN aux_cdsecext = INTE(tt-param.valorCampo).
             WHEN "tpextcta" THEN aux_tpextcta = INTE(tt-param.valorCampo).
             WHEN "tpavsdeb" THEN aux_tpavsdeb = INTE(tt-param.valorCampo).
             WHEN "nrctrrpp" THEN aux_nrctrrpp = INTE(tt-param.valorCampo).
             WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
             WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
             WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
             WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
             WHEN "nraplica" THEN aux_nraplica = INTE(tt-param.valorCampo).
             WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.

             WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
             WHEN "msgatcad" THEN aux_msgatcad = tt-param.valorCampo.
             WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
             WHEN "msgrecad" THEN aux_msgrecad = tt-param.valorCampo.

             WHEN "tpemiext" THEN aux_tpemiext = INTE(tt-param.valorCampo).
             WHEN "descapli" THEN aux_descapli = tt-param.valorCampo.
             WHEN "tpaplica" THEN aux_tpaplica = INTE(tt-param.valorCampo).
             WHEN "msgretor" THEN aux_msgretor = tt-param.valorCampo.
             WHEN "vlsldant" THEN aux_vlsldant = DECI(tt-param.valorCampo).
             WHEN "vlsldtot" THEN aux_vlsldtot = DECI(tt-param.valorCampo).
             WHEN "dtmovano" THEN aux_dtmovano = INTE(tt-param.valorCampo).
             WHEN "dtinimov" THEN aux_dtinimov = DATE(tt-param.valorCampo).
             WHEN "dtfimmov" THEN aux_dtfimmov = DATE(tt-param.valorCampo).
             

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DO EXTRATO DA CONTA-CORRENTE               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extrato:

    RUN Busca_Extrato IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_cddopcao,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_cddepart,
                      INPUT aux_nrdconta,
                      INPUT aux_dtinimov,
                      INPUT aux_dtfimmov,
                      INPUT aux_dsiduser,
                      INPUT aux_nrregist,
                      INPUT aux_nriniseq,
                      INPUT aux_nmarquiv,
                      INPUT YES,
                     OUTPUT aux_qtregist,
                     OUTPUT aux_dtinimov,
                     OUTPUT aux_dtfimmov,
                     OUTPUT TABLE tt-extrat,
                     OUTPUT TABLE tt-extrato_conta,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-extrat:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport   (INPUT TEMP-TABLE tt-extrat:HANDLE,
                              INPUT "Dados").
           RUN piXmlExport   (INPUT TEMP-TABLE tt-extrato_conta:HANDLE,
                              INPUT "Extrato").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlAtributo (INPUT "dtinimov",INPUT STRING(aux_dtinimov,
                                                            "99/99/9999")).
           RUN piXmlAtributo (INPUT "dtfimmov",INPUT STRING(aux_dtfimmov,
                                                            "99/99/9999")).
           
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DO DESTINO DO EXTRATO                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Desext:

    RUN Busca_Desext IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_nrdconta,
                      INPUT YES,
                     OUTPUT TABLE tt-desext,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-desext:HANDLE,
                              INPUT "Destino").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                EFETUA A VALIDAÇÃO DO DESTINO DO EXTRATO                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Desext:

    RUN Valida_Desext IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_nrdconta,
                      INPUT aux_cdsecext,
                      INPUT aux_tpextcta,
                      INPUT aux_tpavsdeb,
                      INPUT TRUE, /* flgerlog */
                     OUTPUT aux_nmdcampo,
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                EFETUA A GRAVAÇÃO  DO DESTINO DO EXTRATO                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Desext:

    RUN Grava_Desext IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_nrdconta,
                      INPUT aux_idseqttl,
                      INPUT aux_cdsecext,
                      INPUT aux_tpextcta,
                      INPUT aux_tpavsdeb,
                      INPUT aux_cddopcao,
                      INPUT YES,
                     OUTPUT aux_tpatlcad,
                     OUTPUT aux_msgatcad,
                     OUTPUT aux_chavealt,
                     OUTPUT aux_msgrecad,
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
           RUN piXmlAtributo (INPUT "tpatlcad",INPUT STRING(aux_tpatlcad)).
           RUN piXmlAtributo (INPUT "msgatcad",INPUT STRING(aux_msgatcad)).
           RUN piXmlAtributo (INPUT "chavealt",INPUT STRING(aux_chavealt)).
           RUN piXmlAtributo (INPUT "msgrecad",INPUT STRING(aux_msgrecad)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA ASSOCIADO DA TELA EXTPPR                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extppr:

    RUN Busca_Extppr IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_nrdconta,
                      INPUT YES,
                     OUTPUT aux_nrctrrpp,
                     OUTPUT TABLE tt-infoass,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                            INPUT "Associado").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport   (INPUT TEMP-TABLE tt-infoass:HANDLE,
                              INPUT "Associado").
           RUN piXmlAtributo (INPUT "nrctrrpp",INPUT STRING(aux_nrctrrpp)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                 EFETUA A BUSCA POUPANÇA DA TELA EXTPPR                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Poupanca:

    RUN Busca_Poupanca IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_dtmvtolt,
                         INPUT aux_dtmvtopr,
                         INPUT aux_inproces,
                         INPUT aux_cdprogra,
                         INPUT aux_nrdconta,
                         INPUT aux_idseqttl,
                         INPUT aux_nrctrrpp,
                         INPUT YES,
                        OUTPUT TABLE tt-poupanca,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-poupanca:HANDLE,
                              INPUT "Poupanca").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*         EFETUA A BUSCA LANAÇAMENTOS NA POUPANCA DA TELA EXTPPR           */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Lancamentos:

    RUN Busca_Lancamentos IN hBO
                          ( INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_nrctrrpp,
                            INPUT aux_dtiniper,
                            INPUT aux_dtfimper,
                            INPUT YES,
                           OUTPUT TABLE tt-extr-rpp,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-extr-rpp:HANDLE,
                              INPUT "Extrato").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                        EFETUA A BUSCA DA TELA EXTEMP                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extemp:

    RUN Busca_Extemp IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nrdconta,
                       INPUT YES,
                      OUTPUT aux_nrctremp,
                      OUTPUT TABLE tt-infoass,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                            INPUT "Associado").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport   (INPUT TEMP-TABLE tt-infoass:HANDLE,
                              INPUT "Associado").
           RUN piXmlAtributo (INPUT "nrctremp",INPUT STRING(aux_nrctremp)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                 EFETUA A BUSCA EMPRESTIMO DA TELA EXTEMP                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Emprestimo:

    RUN Busca_Emprestimo IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_cdprogra,
                         INPUT aux_inproces,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_dtmvtolt,
                         INPUT aux_dtmvtopr,
                         INPUT aux_nrdconta,
                         INPUT aux_nrctremp,
                         INPUT aux_idseqttl,
                         INPUT YES,
                        OUTPUT TABLE tt-dados-epr,
                        OUTPUT TABLE tt-extrato_epr,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-dados-epr:HANDLE,
                              INPUT "Dados").
           RUN piXmlExport   (INPUT TEMP-TABLE tt-extrato_epr:HANDLE,
                              INPUT "Emprestimo").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                        EFETUA A BUSCA DA TELA EXTRDA                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extrda:

    RUN Busca_Extrda IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nrdconta,
                       INPUT YES,
                      OUTPUT aux_nraplica,
                      OUTPUT TABLE tt-infoass,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                            INPUT "Associado").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport   (INPUT TEMP-TABLE tt-infoass:HANDLE,
                              INPUT "Associado").
           RUN piXmlAtributo (INPUT "nraplica",INPUT STRING(aux_nraplica)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*            EFETUA A BUSCA DO EXTRATO DAS APLICACOES - EXTRDA             */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Aplicacoes:

    RUN Busca_Aplicacoes IN hBO
                         ( INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_cdprogra,
                           INPUT aux_nmdatela,
                           INPUT aux_idorigem,
                           INPUT aux_dtmvtolt,
                           INPUT aux_nrdconta,
                           INPUT aux_nraplica,
                           INPUT aux_idseqttl,
                           INPUT YES,
                          OUTPUT TABLE tt-saldo-rdca,
                          OUTPUT TABLE tt-extr-rdca,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-saldo-rdca:HANDLE,
                              INPUT "Dados").
           RUN piXmlExport   (INPUT TEMP-TABLE tt-extr-rdca:HANDLE,
                              INPUT "Extrato").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                       EFETUA A BUSCA DA TELA EXTAPL                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extapl:

    RUN Busca_Extapl IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nrdconta,
                       INPUT aux_cddopcao,
                       INPUT YES,
                      OUTPUT TABLE tt-infoass,
                      OUTPUT TABLE tt-extapl,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-infoass:HANDLE,
                              INPUT "Dados").
           RUN piXmlExport   (INPUT TEMP-TABLE tt-extapl:HANDLE,
                              INPUT "Extrato").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                 EFETUA A VALIDAÇÃO DOS DADOS INFORMADOS                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Extapl:

    RUN Valida_Extapl IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cddopcao,
                        INPUT aux_nrdconta,
                        INPUT aux_tpaplica,
                        INPUT aux_nraplica,
                        INPUT aux_tpemiext,
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
/*                REALIZA A GRAVACAO DOS DADOS DA TELA EXTAPL               */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Extapl:

    RUN Grava_Extapl IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_nrdconta,
                       INPUT aux_idseqttl,
                       INPUT aux_cddopcao,
                       INPUT aux_descapli,
                       INPUT aux_tpaplica,
                       INPUT aux_nraplica,
                       INPUT aux_tpemiext,
                       INPUT YES,
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
           RUN piXmlAtributo (INPUT "msgretor",INPUT STRING(aux_msgretor)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DOS DADOS DO ASSOCIADO                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extcap:

    RUN Busca_Extcap IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nrdconta,
                       INPUT TRUE,
                      OUTPUT TABLE tt-infoass,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DO EXTRATO DE CAPITAL                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Extrato_Cotas:

    RUN Busca_Extrato_Cotas IN hBO
                          ( INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nrdconta,
                            INPUT aux_dtmovano,
                            INPUT aux_nrregist,
                            INPUT aux_nriniseq,
                            INPUT TRUE,
                           OUTPUT aux_vlsldant,
                           OUTPUT aux_vlsldtot,
                           OUTPUT aux_qtregist,
                           OUTPUT TABLE tt-ext_cotas,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-ext_cotas:HANDLE,
                            INPUT "Extrato").
           RUN piXmlAtributo (INPUT "vlsldant",INPUT STRING(aux_vlsldant)).
           RUN piXmlAtributo (INPUT "vlsldtot",INPUT STRING(aux_vlsldtot)).
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE.

