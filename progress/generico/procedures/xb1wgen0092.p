/*.............................................................................

   Programa: xb1wgen0092.p
   Autor   : André (DB1)
   Data    : Maio/2011                     Ultima atualizacao: 03/02/2015

   Dados referentes ao programa:

   Objetivo  : BO - AUTORIZACOES DE DEBITO EM CONTA (b1wgen0092.p)

   Alteracoes: 05/08/2013 - Remover procedure verifica-tabela-exec pois nao
                            ser mais utilizada (Lucas R.).

               19/05/2014 - Ajustes referentes ao Projeto Debito Automatico
                            Softdesk 148330 (Lucas R.)

               19/05/2014 - Alteração de parametros na chamada da procedure
                            grava-dados para Projeto de Debito Facil
                            (Lucas R. - Out/2014).
                            
               03/02/2015 - Incluir aux_nomcampo na retorna-calculo-barras
                            (Lucas R. #242146)
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
DEF VAR aux_cdhistor AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrefere AS DECI                                           NO-UNDO.
DEF VAR aux_nmprintl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtdiatab AS INTE                                           NO-UNDO.
DEF VAR aux_dtlimite AS DATE                                           NO-UNDO.
DEF VAR aux_cdsitdtl AS INTE                                           NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                           NO-UNDO.
DEF VAR aux_cddddtel AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniatr AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimatr AS DATE                                           NO-UNDO.
DEF VAR aux_dtultdeb AS DATE                                           NO-UNDO.
DEF VAR aux_dtvencto AS INTE                                           NO-UNDO.
DEF VAR aux_nmfatura AS CHAR                                           NO-UNDO.
DEF VAR aux_nmfatret AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_cdempcon AS INTE                                           NO-UNDO.
DEF VAR aux_cdsegmto AS CHAR                                           NO-UNDO.
DEF VAR aux_cdempres AS CHAR                                           NO-UNDO.
DEF VAR aux_rthistor AS CHAR                                           NO-UNDO.
DEF VAR aux_codbarra AS CHAR                                           NO-UNDO.
DEF VAR aux_fatura01 AS CHAR                                           NO-UNDO.
DEF VAR aux_fatura02 AS CHAR                                           NO-UNDO.
DEF VAR aux_fatura03 AS CHAR                                           NO-UNDO.
DEF VAR aux_fatura04 AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsicre AS CHAR                                           NO-UNDO.
DEF VAR aux_flgmanua AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnomcnv AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsegmen AS INTE                                           NO-UNDO.
DEF VAR aux_vlrmaxdb AS DECI                                           NO-UNDO.
DEF VAR aux_nomcampo AS CHAR                                           NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_flglanca AS LOGI                                           NO-UNDO.
DEF VAR aux_inautori AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0092tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/*................................ PROCEDURES ...............................*/


/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
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
            WHEN "cdhistor" THEN aux_cdhistor = tt-param.valorCampo.
            WHEN "cdrefere" THEN aux_cdrefere = DECI(tt-param.valorCampo).
            WHEN "cdsitdtl" THEN aux_cdsitdtl = INTE(tt-param.valorCampo).  
            WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.        
            WHEN "cddddtel" THEN aux_cddddtel = INTE(tt-param.valorCampo).  
            WHEN "dtiniatr" THEN aux_dtiniatr = DATE(tt-param.valorCampo).  
            WHEN "dtfimatr" THEN aux_dtfimatr = DATE(tt-param.valorCampo).  
            WHEN "dtultdeb" THEN aux_dtultdeb = DATE(tt-param.valorCampo).  
            WHEN "dtvencto" THEN aux_dtvencto = INTE(tt-param.valorCampo).
            WHEN "dtlimite" THEN aux_dtlimite = DATE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "inautori" THEN aux_inautori = INTE(tt-param.valorCampo).
            WHEN "flglanca" THEN aux_flglanca = LOGICAL(tt-param.valorCampo).

            WHEN "nmfatura" THEN aux_nmfatura = tt-param.valorCampo.     
            WHEN "dshistor" THEN aux_dshistor = tt-param.valorCampo.

            WHEN "codbarra" THEN aux_codbarra = tt-param.valorCampo.
            WHEN "fatura01" THEN aux_fatura01 = tt-param.valorCampo.
            WHEN "fatura02" THEN aux_fatura02 = tt-param.valorCampo.
            WHEN "fatura03" THEN aux_fatura03 = tt-param.valorCampo.
            WHEN "fatura04" THEN aux_fatura04 = tt-param.valorCampo.
            WHEN "flgsicre" THEN aux_flgsicre = tt-param.valorCampo.
            WHEN "flgmanua" THEN aux_flgmanua = tt-param.valorCampo.
            WHEN "nomcampo" THEN aux_nomcampo = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.

/*****************************************************************************/
/*                            Buscar dados dos cheques                       */
/*****************************************************************************/
PROCEDURE busca-autori:

    RUN busca-autori IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT TRUE, /* LOG */
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_cdhistor,
                             INPUT aux_cdrefere,
                             INPUT aux_flgsicre,
                            OUTPUT TABLE tt-erro, 
                            OUTPUT TABLE tt-autori).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-autori:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                         Verifica Conta para buscar cheques                */
/*****************************************************************************/
PROCEDURE valida-conta:

    RUN valida-conta IN hBO ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_nrdconta,
                             OUTPUT aux_nmprintl,
                             OUTPUT aux_cdsitdtl,
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
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprintl)).
            RUN piXmlAtributo (INPUT "cdsitdtl",INPUT STRING(aux_cdsitdtl)).
            RUN piXmlSave.
        END.


END PROCEDURE.


PROCEDURE valida_conta_sicredi:

    RUN valida_conta_sicredi IN hBO ( INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
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

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.


END PROCEDURE.


/*****************************************************************************/
/*                                 Valida historico                          */
/*****************************************************************************/
PROCEDURE valida-historico:

    RUN valida-historico IN hBO ( INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT TRUE, /* LOG */
                                  INPUT aux_cdhistor,
                                  INPUT aux_cddopcao,
                                  INPUT aux_dshistor,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT aux_rthistor,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dshistor",INPUT STRING(aux_rthistor)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                             Valida operador                               */
/*****************************************************************************/
 PROCEDURE valida-oper:

     RUN valida-oper IN hBO ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT TRUE, /* LOG */
                              INPUT aux_dsdepart,
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

/*****************************************************************************/
/*                        Valida dados da autorizacao                        */
/*****************************************************************************/
PROCEDURE valida-prej-tit:

    RUN valida-prej-tit IN hBO ( INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT TRUE, /* LOG */
                                 INPUT aux_cdsitdtl,
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

            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                         Valida dados para gravacao                        */
/*****************************************************************************/
PROCEDURE valida-dados:

    RUN valida-dados IN hBO ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT TRUE, /* LOG */
                              INPUT aux_cddopcao,
                              INPUT aux_cdhistor,
                              INPUT aux_cdrefere,

                              INPUT aux_dtiniatr,
                              INPUT aux_dtfimatr,
                              INPUT aux_dtlimite,
                              INPUT aux_dtmvtolt,
                              INPUT aux_dtvencto,
                             OUTPUT aux_nmdcampo,
                             OUTPUT aux_nmprintl,
                             OUTPUT TABLE tt-erro ).

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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprintl)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                     Verifica se autorizacao foi baixada                   */
/*****************************************************************************/
PROCEDURE verifica-aut-baixada:

    RUN verifica-aut-baixada IN hBO ( INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_nrdconta,
                                      INPUT aux_cdhistor,
                                      INPUT aux_cdrefere,
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

/*****************************************************************************/
/*                              Gravacao dos dados                           */
/*****************************************************************************/
PROCEDURE grava-dados:

    RUN grava-dados IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT TRUE, /* LOG */
                             INPUT aux_dtmvtolt,

                             INPUT aux_cddopcao,
                             INPUT aux_cdhistor,
                             INPUT aux_cdrefere,
                             INPUT aux_cddddtel,
                             INPUT aux_dtiniatr,
                             INPUT aux_dtfimatr,
                             INPUT aux_dtultdeb,
                             INPUT aux_dtvencto,
                             INPUT aux_nmfatura,
                             INPUT aux_vlrmaxdb, /* Lunelli */

                             INPUT aux_flgsicre,
                             INPUT aux_cdempcon, /* Lunelli */
                             INPUT aux_cdsegmen, /* Lunelli */
                             INPUT aux_flgmanua,
                             INPUT aux_fatura01, 
                             INPUT aux_fatura02, 
                             INPUT aux_fatura03, 
                             INPUT aux_fatura04, 
                             INPUT aux_codbarra, 
                            OUTPUT aux_nmfatret,
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

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmfatret",INPUT STRING(aux_nmfatret)).
            RUN piXmlSave.
        END.


END PROCEDURE.

PROCEDURE retorna-calculo-referencia:

    RUN retorna-calculo-referencia IN hBO(INPUT aux_cdcooper,
                                          INPUT aux_codbarra,
                                          INPUT aux_cdrefere,
                                         OUTPUT aux_nmdcampo,
                                         OUTPUT aux_dsnomcnv,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsnomcnv",INPUT aux_dsnomcnv).
            RUN piXmlSave.
        END.
END.

PROCEDURE retorna-calculo-barras:

    RUN retorna-calculo-barras IN hBO(INPUT aux_cdcooper,
                                      INPUT aux_fatura01,
                                      INPUT aux_fatura02,
                                      INPUT aux_fatura03,
                                      INPUT aux_fatura04,
                                      INPUT aux_codbarra,
                                      INPUT aux_flgmanua,
                                      INPUT aux_nomcampo,
                                     OUTPUT aux_nmdcampo,
                                     OUTPUT aux_dsnomcnv,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsnomcnv",INPUT aux_dsnomcnv).
            RUN piXmlSave.
        END.
END.

PROCEDURE busca-convenios:

    RUN busca-convenios IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_cdhistor,
          INPUT aux_dshistor,
          INPUT aux_flglanca,
          INPUT aux_inautori,
          INPUT aux_nrregist, 
          INPUT aux_nriniseq, 
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-crapscn).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapscn:HANDLE,
                               INPUT "Convenios").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.
