/*............................................................................

   Programa: b1wgen0093.p                  
   Autora  : André - DB1
   Data    : 27/05/2011                        Ultima atualizacao: 00/00/0000 
    
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : BO - Cadastramento Guias Previdencia (b1wgen0093.p)

   Alteracoes:              
............................................................................*/ 
DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                          NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                          NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                          NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                          NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_cdidenti AS DECI                                          NO-UNDO.
DEF VAR aux_cddpagto AS INTE                                          NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                          NO-UNDO.
DEF VAR aux_vlrdinss AS DECI                                          NO-UNDO.
DEF VAR aux_flgdbaut AS LOGI                                          NO-UNDO.
DEF VAR aux_nrctadeb AS INTE                                          NO-UNDO.
DEF VAR aux_vloutent AS DECI                                          NO-UNDO.
DEF VAR aux_vlrjuros AS DECI                                          NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                          NO-UNDO.
DEF VAR aux_tpcontri AS INTE                                          NO-UNDO.
DEF VAR aux_flgrgatv AS LOGI                                          NO-UNDO.
DEF VAR aux_dsendres AS CHAR                                          NO-UNDO.  
DEF VAR aux_nmbairro AS CHAR                                          NO-UNDO.  
DEF VAR aux_nmcidade AS CHAR                                          NO-UNDO.  
DEF VAR aux_nrcepend AS INTE                                          NO-UNDO.  
DEF VAR aux_cdufresd AS CHAR                                          NO-UNDO.
DEF VAR aux_nrendres AS INTE                                          NO-UNDO.
DEF VAR aux_complend AS CHAR                                          NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                          NO-UNDO.
DEF VAR aux_nrfonres AS CHAR                                          NO-UNDO.  
DEF VAR aux_nmextttl AS CHAR                                          NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                          NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                          NO-UNDO.
DEF VAR aux_posvalid AS INTE                                          NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                          NO-UNDO.
DEF VAR aux_flgexass AS LOGI                                          NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                          NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                          NO-UNDO.
DEF VAR aux_chrvalid AS CHAR                                          NO-UNDO.
DEF VAR aux_flgconti AS LOGI                                          NO-UNDO.
DEF VAR aux_flgcontr AS LOGI                                          NO-UNDO.

{ sistema/generico/includes/b1wgen0093tt.i }
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdidenti" THEN aux_cdidenti = DECI(tt-param.valorCampo).
            WHEN "nrctadeb" THEN aux_nrctadeb = INTE(tt-param.valorCampo).
            WHEN "posvalid" THEN aux_posvalid = INTE(tt-param.valorCampo).
            WHEN "cddpagto" THEN aux_cddpagto = INTE(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "vlrdinss" THEN aux_vlrdinss = DECI(tt-param.valorCampo).
            WHEN "flgdbaut" THEN aux_flgdbaut = LOGICAL(tt-param.valorCampo).
            WHEN "nrctadeb" THEN aux_nrctadeb = INTE(tt-param.valorCampo).
            WHEN "vloutent" THEN aux_vloutent = DECI(tt-param.valorCampo).
            WHEN "vlrjuros" THEN aux_vlrjuros = DECI(tt-param.valorCampo).
            WHEN "vlrtotal" THEN aux_vlrtotal = DECI(tt-param.valorCampo).
            WHEN "tpcontri" THEN aux_tpcontri = INTE(tt-param.valorCampo).
            WHEN "flgrgatv" THEN aux_flgrgatv = LOGICAL(tt-param.valorCampo).
            WHEN "dsendres" THEN aux_dsendres = tt-param.valorCampo.
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
            WHEN "cdufresd" THEN aux_cdufresd = tt-param.valorCampo.
            WHEN "nrendres" THEN aux_nrendres = INTE(tt-param.valorCampo).
            WHEN "complend" THEN aux_complend = tt-param.valorCampo.
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "nrfonres" THEN aux_nrfonres = tt-param.valorCampo.
            WHEN "nmextttl" THEN aux_nmextttl = tt-param.valorCampo.
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nmrescop" THEN aux_nmrescop = tt-param.valorCampo.
            WHEN "posvalid" THEN aux_posvalid = INTE(tt-param.valorCampo).
            WHEN "chrvalid" THEN aux_chrvalid = tt-param.valorCampo.
            WHEN "flgcontr" THEN aux_flgcontr = LOGICAL(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/* ************************************************************************* */
/**                       Procedure para buscar pagto ou nome               **/
/* ************************************************************************  */
PROCEDURE busca-pagto-nome:

    RUN busca-pagto-nome IN hBO ( INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrctadeb,
                                 OUTPUT aux_nmprimtl ).

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
            RUN piXmlAtributo (INPUT "cddpagto",INPUT STRING(aux_cddpagto)).
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************* */
/**                       Procedure para buscar associado                   **/
/* ************************************************************************  */
PROCEDURE busca-assoc:

    RUN busca-assoc IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT aux_cdidenti,
                             INPUT aux_cddpagto,
                             INPUT aux_cddopcao,
                             INPUT aux_flgcontr,
                            OUTPUT aux_flgexass,
                            OUTPUT aux_msgretor,
                            OUTPUT TABLE tt-erro, 
                            OUTPUT TABLE tt-cadgps ).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-cadgps:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "flgexass",INPUT STRING(aux_flgexass)).
            RUN piXmlAtributo (INPUT "msgretor",INPUT STRING(aux_msgretor)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/* ************************************************************************* */
/**                       Procedure para carregar debito                    **/
/* ************************************************************************  */
PROCEDURE busca-deb:

    RUN busca-deb IN hBO ( INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_nrdconta,
                           INPUT aux_cdidenti,
                           INPUT aux_cddpagto,
                          OUTPUT aux_msgretor,
                          OUTPUT TABLE tt-erro, 
                          OUTPUT TABLE tt-cadgps ).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-cadgps:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "msgretor",INPUT STRING(aux_msgretor)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/* ************************************************************************* */
/**                         Gravacao dos dados                              **/
/* ************************************************************************  */
PROCEDURE grava-dados:

    RUN grava-dados IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT TRUE,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_cdidenti,
                             INPUT aux_cddpagto,
                             INPUT aux_inpessoa,
                             INPUT aux_vlrdinss,
                             INPUT aux_flgdbaut,
                             INPUT aux_nrctadeb,
                             INPUT aux_vloutent,
                             INPUT aux_vlrjuros,
                             INPUT aux_vlrtotal,
                             INPUT aux_tpcontri,
                             INPUT aux_flgrgatv,
                             INPUT aux_dsendres,
                             INPUT aux_nmbairro,
                             INPUT aux_nmcidade,
                             INPUT aux_nrcepend,
                             INPUT aux_cdufresd,
                             INPUT aux_nrendres,
                             INPUT aux_complend,
                             INPUT aux_nrcxapst,
                             INPUT aux_nrfonres,
                             INPUT aux_nmextttl,
                             INPUT aux_nrcpfcgc,
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

/* ************************************************************************* */
/**                           Validar autorizacao                           **/
/* ************************************************************************  */
PROCEDURE valida-autori-deb:

    RUN valida-autori-deb IN hBO ( INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_nrctadeb,
                                   INPUT aux_cdidenti,
                                   INPUT aux_inpessoa,
                                   INPUT aux_cddopcao,
                                   INPUT aux_chrvalid,
                                  OUTPUT aux_nmdcampo,
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

/* ************************************************************************* */
/**               Validar valores para os codigos de pagamento              **/
/* ************************************************************************  */ 
PROCEDURE valida-valores:

    RUN valida-valores IN hBO ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cddpagto,
                                INPUT aux_vlrdinss,
                                INPUT aux_vlrjuros,
                                INPUT aux_vloutent,
                                INPUT aux_nmrescop,
                               OUTPUT aux_nmdcampo,
                               OUTPUT aux_vlrtotal,
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
            RUN piXmlAtributo (INPUT "vlrtotal",INPUT STRING(aux_vlrtotal)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/* ************************************************************************* */
/**                 Validacoes no processo de alteracao/inserção            **/
/* ************************************************************************  */
PROCEDURE valida-ins:

    RUN valida-ins IN hBO ( INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_nrdconta,
                            INPUT aux_cdidenti,
                            INPUT aux_cddpagto,
                            INPUT aux_posvalid,
                           OUTPUT aux_inpessoa,
                           OUTPUT aux_flgconti,
                           OUTPUT aux_nmdcampo,
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
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "flgconti",INPUT STRING(aux_flgconti)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/* ************************************************************************* */
/**                          Valida identificador                           **/
/* ************************************************************************  */
PROCEDURE valida-identificador:

    RUN valida-identificador IN hBO ( INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdidenti,
                                      INPUT aux_cddpagto,
                                     OUTPUT aux_nmdcampo,
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

/* ************************************************************************* */
/**                                 Valida dados                            **/
/* ************************************************************************  */
PROCEDURE valida-dados:

    RUN valida-dados IN hBO ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_nrdconta,
                              INPUT aux_nrcpfcgc,
                              INPUT aux_nrcepend,
                              INPUT aux_dsendres,
                              INPUT aux_nmbairro,
                              INPUT aux_nmcidade,
                              INPUT aux_cdufresd,
                             OUTPUT aux_nmdcampo,
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


