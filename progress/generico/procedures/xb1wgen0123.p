/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0123.p
     Autor   : Rogerius Militão
     Data    : Novembro/2011                      Ultima atualizacao: 27/05/2014

     Objetivo  : BO de Comunicacao XML x BO - Tela CASH

     Alteracoes: 16/07/2013 - Incluido a procedure 
                             "busca_dados_cartoes_magneticos". (James)
                             
                 18/11/2013 - Adicionado campo flgblsaq em OUTPUT de
                              proc. Opcao_Transacao. (Jorge)
                              
                 27/05/2014 - Incluido a informação de espécie de deposito e
                            relatório do mesmo. (Andre Santos - SUPERO)             
                 
				 06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
				              da descrição do departamento como parametro e 
							  passar o código (Renato Darosci)
.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper  AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra  AS CHAR                                           NO-UNDO.                      
DEF VAR aux_idorigem  AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela  AS CHAR                                           NO-UNDO.
DEF VAR aux_cddepart  AS INTE                                           NO-UNDO.  

DEF VAR aux_cddopcao  AS CHAR                                           NO-UNDO.  
DEF VAR aux_nrterfin  AS INTE                                           NO-UNDO.   
DEF VAR aux_flsistaa  AS LOGICAL                                        NO-UNDO. 
DEF VAR aux_mmtramax  AS INTE                                           NO-UNDO. 
DEF VAR aux_dtmvtini  AS DATE                                           NO-UNDO. 
DEF VAR aux_dtmvtfim  AS DATE                                           NO-UNDO. 
DEF VAR aux_cddoptel  AS CHAR                                           NO-UNDO. 
DEF VAR aux_lgagetfn  AS LOGICAL                                        NO-UNDO. 
DEF VAR aux_tiprelat  AS LOGICAL                                        NO-UNDO. 
DEF VAR aux_cdagetfn  AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                           NO-UNDO. 
DEF VAR aux_dsiduser  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrterfin1 AS INTE                                           NO-UNDO.

DEF VAR aux_nmdireto  AS CHAR                                           NO-UNDO. 
DEF VAR aux_dsagetfn  AS CHAR                                           NO-UNDO. 

DEF VAR aux_cddoptrs  AS CHAR                                           NO-UNDO.
DEF VAR aux_dtlimite  AS DATE                                           NO-UNDO.
DEF VAR aux_cdsitfin  AS INTE                                           NO-UNDO.
DEF VAR aux_dtinicio  AS DATE                                           NO-UNDO.
DEF VAR aux_dtdfinal  AS DATE                                           NO-UNDO.
DEF VAR aux_cdsitenv  AS INTE                                           NO-UNDO.

DEF VAR aux_qtsaques  AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlsaques  AS DECIMAL                                        NO-UNDO.
DEF VAR aux_qtestorn  AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlestorn  AS DECIMAL                                        NO-UNDO.

DEF VAR aux_cdagencx  AS INTE                                           NO-UNDO.
DEF VAR aux_qtcasset  AS INTE                                           NO-UNDO.

DEF VAR aux_dsfabtfn  AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmodelo  AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdserie  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmnarede  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdendip  AS CHAR                                           NO-UNDO.
DEF VAR aux_dsterfin  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad  AS CHAR                                           NO-UNDO.
DEF VAR aux_tprecolh  AS LOGICAL                                        NO-UNDO.
DEF VAR aux_qttotalp  AS INTE                                           NO-UNDO.
DEF VAR aux_flgblsaq  AS LOGICAL                                        NO-UNDO.
DEF VAR aux_opreldep  AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0123tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper"  THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci"  THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa"  THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad"  THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "cdprogra"  THEN aux_cdprogra = tt-param.valorCampo.
             WHEN "dtmvtolt"  THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr"  THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "nmdatela"  THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "cddepart"  THEN aux_cddepart = INTE(tt-param.valorCampo).
                              
             WHEN "cddopcao"  THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nrterfin"  THEN aux_nrterfin = INTE(tt-param.valorCampo).
             WHEN "flsistaa"  THEN aux_flsistaa = LOGICAL(tt-param.valorCampo).
             WHEN "mmtramax"  THEN aux_mmtramax = INTE(tt-param.valorCampo).
             WHEN "dtmvtini"  THEN aux_dtmvtini = DATE(tt-param.valorCampo).
             WHEN "dtmvtfim"  THEN aux_dtmvtfim = DATE(tt-param.valorCampo).
             WHEN "cddoptel"  THEN aux_cddoptel = tt-param.valorCampo.
             WHEN "lgagetfn"  THEN aux_lgagetfn = LOGICAL(tt-param.valorCampo).
             WHEN "tiprelat"  THEN aux_tiprelat = LOGICAL(tt-param.valorCampo).
             WHEN "cdagetfn"  THEN aux_cdagetfn = INTE(tt-param.valorCampo).
             WHEN "nmarqimp"  THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf"  THEN aux_nmarqpdf = tt-param.valorCampo.
             WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.

             WHEN "nmdireto"  THEN aux_nmdireto = tt-param.valorCampo.
             WHEN "dsagetfn"  THEN aux_dsagetfn = tt-param.valorCampo.

             WHEN "cddoptrs"  THEN aux_cddoptrs = tt-param.valorCampo.
             WHEN "dtlimite"  THEN aux_dtlimite = DATE(tt-param.valorCampo).
             WHEN "cdsitfin"  THEN aux_cdsitfin = INTE(tt-param.valorCampo).
             WHEN "dtinicio"  THEN aux_dtinicio = DATE(tt-param.valorCampo).
             WHEN "dtdfinal"  THEN aux_dtdfinal = DATE(tt-param.valorCampo).
             WHEN "cdsitenv"  THEN aux_cdsitenv = INTE(tt-param.valorCampo).

             WHEN "qtsaques"  THEN aux_qtsaques = DECIMAL(tt-param.valorCampo).
             WHEN "vlsaques"  THEN aux_vlsaques = DECIMAL(tt-param.valorCampo).
             WHEN "qtestorn"  THEN aux_qtestorn = DECIMAL(tt-param.valorCampo).
             WHEN "vlestorn"  THEN aux_vlestorn = DECIMAL(tt-param.valorCampo).
            
             WHEN "cdagencx"  THEN aux_cdagencx = INTE(tt-param.valorCampo).
             WHEN "qtcasset"  THEN aux_qtcasset = INTE(tt-param.valorCampo).

             WHEN "opreldep"  THEN aux_opreldep = tt-param.valorCampo.
             WHEN "nrterfin1" THEN aux_nrterfin = INTE(tt-param.valorCampo).

             WHEN "dsfabtfn"  THEN aux_dsfabtfn = tt-param.valorCampo.
             WHEN "dsmodelo"  THEN aux_dsmodelo = tt-param.valorCampo.
             WHEN "dsdserie"  THEN aux_dsdserie = tt-param.valorCampo.
             WHEN "nmnarede"  THEN aux_nmnarede = tt-param.valorCampo.
             WHEN "nrdendip"  THEN aux_nrdendip = tt-param.valorCampo.
             WHEN "dsterfin"  THEN aux_dsterfin = tt-param.valorCampo.
             WHEN "dtmvtoan"  THEN aux_dtmvtoan = DATE(tt-param.valorCampo).
             WHEN "nmoperad"  THEN aux_nmoperad = tt-param.valorCampo.
             WHEN "tprecolh"  THEN aux_tprecolh = LOGICAL(tt-param.valorCampo).
             WHEN "qttotalp"  THEN aux_qttotalp = INTE(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA DA TELA CASH                          */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_cdprogra,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_dtmvtopr,
                    INPUT aux_nmdatela,
                    INPUT aux_cddepart,
                    INPUT aux_cddopcao,
                    INPUT aux_nrterfin,
                    INPUT aux_flsistaa,
                    INPUT aux_mmtramax,
                    INPUT aux_dtmvtini, 
                    INPUT aux_dtmvtfim, 
                    INPUT aux_cddoptel,
                    INPUT aux_lgagetfn,
                    INPUT aux_tiprelat,
                    INPUT aux_cdagetfn,
                    INPUT aux_nmarqimp,
                    INPUT aux_cdsitenv,
                    INPUT aux_opreldep,
                    INPUT YES, /* flglog */
                   OUTPUT aux_nmarqimp,
                   OUTPUT aux_nmarqpdf,
                   OUTPUT TABLE tt-terminal,
                   OUTPUT TABLE crattfn,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-terminal:HANDLE,
                            INPUT "terminal").
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlExport (INPUT TEMP-TABLE crattfn:HANDLE,
                            INPUT "crattfn").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

PROCEDURE busca_dados_cartoes_magneticos:

    RUN busca_dados_cartoes_magneticos IN hBO ( INPUT aux_cdcooper,
                                                INPUT aux_cdagenci,
                                                INPUT aux_nrdcaixa,
                                                INPUT aux_cdoperad,
                                                INPUT aux_cdprogra,
                                                INPUT aux_idorigem,
                                                INPUT aux_nmdatela,
                                                INPUT aux_dtmvtolt,
                                                INPUT aux_lgagetfn,
                                                INPUT aux_cdagetfn,
                                                INPUT aux_nmarqimp,
                                                INPUT aux_cddoptel,

                                               OUTPUT aux_nmarqimp,
                                               OUTPUT aux_nmarqpdf,
                                               OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN
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
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE.
/* ------------------------------------------------------------------------ */
/*                 EFETUA A VALIDAÇÃO DOS DADOS INFORMADOS                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Pac:

    RUN Valida_Pac IN hBO
                 ( INPUT aux_cdcooper,
                   INPUT aux_cdagenci,
                   INPUT aux_nrdcaixa,
                   INPUT aux_cdoperad,
                   INPUT aux_idorigem,
                   INPUT aux_cdagetfn,
                   INPUT aux_lgagetfn,
                  OUTPUT aux_nmdireto,
                  OUTPUT aux_dsagetfn,
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
           RUN piXmlAtributo (INPUT "nmdireto", INPUT aux_nmdireto).
           RUN piXmlAtributo (INPUT "dsagetfn", INPUT aux_dsagetfn).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Pac */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A TRANSAÇÃO TELA CASH                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Transacao:

    RUN Opcao_Transacao IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_cdprogra,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_dtmvtopr,
                        INPUT aux_cddoptrs,
                        INPUT aux_nrterfin,
                        INPUT aux_dtlimite,
                        INPUT aux_cdsitfin,
                        INPUT aux_dtinicio,
                        INPUT aux_dtdfinal, 
                        INPUT aux_cdsitenv, 
                        INPUT YES, /* flglog */
                       OUTPUT aux_dtlimite,
                       OUTPUT aux_qtsaques,
                       OUTPUT aux_vlsaques,
                       OUTPUT aux_qtestorn,
                       OUTPUT aux_vlestorn,
                       OUTPUT aux_cdsitfin,
                       OUTPUT aux_flgblsaq,
                       OUTPUT TABLE tt-transacao,
                       OUTPUT TABLE tt-envelopes,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-transacao:HANDLE,
                            INPUT "transacao").
           RUN piXmlAtributo (INPUT "dtlimite", INPUT STRING(aux_dtlimite,"99/99/9999")).
           RUN piXmlAtributo (INPUT "qtsaques", INPUT aux_qtsaques).
           RUN piXmlAtributo (INPUT "vlsaques", INPUT aux_vlsaques).
           RUN piXmlAtributo (INPUT "qtestorn", INPUT aux_qtestorn).
           RUN piXmlAtributo (INPUT "vlestorn", INPUT aux_vlestorn).
           RUN piXmlAtributo (INPUT "cdsitfin", INPUT aux_cdsitfin).
           RUN piXmlAtributo (INPUT "flgblsaq", INPUT aux_flgblsaq).
           RUN piXmlExport (INPUT TEMP-TABLE tt-envelopes:HANDLE,
                            INPUT "tt-envelopes").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Opcao_Transacao */

/* ------------------------------------------------------------------------ */
/*                     EFETUA DA TRANSACAO NA TELA CASH                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Operacao:

    RUN Opcao_Operacao IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_cdprogra,
                       INPUT aux_nmdatela,
                       INPUT aux_dtmvtopr,
                       INPUT aux_dtmvtolt,
                       INPUT aux_idorigem,
                       INPUT aux_dtlimite,
                       INPUT aux_nrterfin,
                       INPUT YES, /* flglog */
                      OUTPUT aux_dtlimite,
                      OUTPUT TABLE tt-transacao,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-transacao:HANDLE,
                            INPUT "transacao").
           RUN piXmlAtributo (INPUT "dtlimite", INPUT STRING(aux_dtlimite,"99/99/9999")).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Opcao_Operacao */

/* ------------------------------------------------------------------------ */
/*                     EFETUA BUSCA SENSORES NA TELA CASH                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Sensores:

    RUN Opcao_Sensores IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_cdprogra,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nrterfin,
                       INPUT YES, /* flglog */
                      OUTPUT TABLE tt-sensores,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-sensores:HANDLE,
                            INPUT "sensores").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Opcao_Sensores */

/* ------------------------------------------------------------------------ */
/*                      EFETUA BUSCA SALDOS NA TELA CASH                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Saldos:

    RUN Opcao_Saldos IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_cdprogra,
                     INPUT aux_nmdatela,
                     INPUT aux_dtmvtopr,
                     INPUT aux_dtmvtolt,
                     INPUT aux_idorigem,
                     INPUT aux_dtlimite,
                     INPUT aux_nrterfin,
                     INPUT YES, /* flglog */
                    OUTPUT aux_dtlimite,
                    OUTPUT TABLE tt-saldos,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-saldos:HANDLE,
                            INPUT "saldos").
           RUN piXmlAtributo (INPUT "dtlimite", INPUT STRING(aux_dtlimite,"99/99/9999")).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Opcao_Saldos */

/* ------------------------------------------------------------------------ */
/*                       EFETUA BUSCA LOG NA TELA CASH                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Log:

    RUN Opcao_Log IN hBO
                ( INPUT aux_cdcooper,
                  INPUT aux_cdagenci,
                  INPUT aux_nrdcaixa,
                  INPUT aux_cdoperad,
                  INPUT aux_cdprogra,
                  INPUT aux_nmdatela,
                  INPUT aux_idorigem,
                  INPUT aux_dtmvtolt,
                  INPUT aux_dtmvtopr,
                  INPUT aux_dsiduser,
                  INPUT aux_dtlimite,
                  INPUT aux_nrterfin,
                  INPUT YES, /* flglog */
                 OUTPUT aux_nmarqimp,
                 OUTPUT aux_nmarqpdf,
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
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Opcao_Log */

/* ------------------------------------------------------------------------ */
/*                        EFETUA A VALIDAÇÃO DOS DADOS                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO
                ( INPUT aux_cdcooper,
                  INPUT aux_cdagenci,
                  INPUT aux_nrdcaixa,
                  INPUT aux_cdoperad,
                  INPUT aux_idorigem,
                  INPUT aux_dtmvtolt,
                  INPUT aux_dtmvtopr,
                  INPUT aux_nmdatela,
                  INPUT aux_cddopcao,
                  INPUT aux_nrterfin,
                  INPUT aux_cdagencx,
                  INPUT aux_cdsitfin,
                  INPUT aux_qtcasset,
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

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------ */
/*                        EFETUA A VALIDAÇÃO DOS DADOS                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_cdprogra,
                    INPUT aux_nmdatela,
                    INPUT aux_cddepart,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_dtmvtopr,
                    INPUT aux_cddopcao,
                    INPUT aux_nrterfin,
                    INPUT aux_dsfabtfn,
                    INPUT aux_dsmodelo,
                    INPUT aux_dsdserie,
                    INPUT aux_nmnarede,
                    INPUT aux_nrdendip,
                    INPUT aux_cdsitfin,
                    INPUT aux_flsistaa,
                    INPUT aux_cdagencx,
                    INPUT aux_dsterfin,
                    INPUT aux_qtcasset,
                    INPUT aux_dtmvtoan,
                    INPUT aux_nmoperad,
                    INPUT aux_tprecolh,
                    INPUT aux_qttotalp,
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

END PROCEDURE. /* Grava_Dados */

