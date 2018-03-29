/*.............................................................................

    Programa: xb1wgen0104.p
    Autor   : Guilherme/Gabriel
    Data    : Julho/2011                   Ultima atualizacao: 19/07/2012 

    Objetivo  : BO de Comunicacao XML x BO CMEDEP/CMESAQ (b1wgen0104.p)

    Alteracoes: 22/02/2012 - Alterados parâmetros das procedures para
                            evitar registros duplicados validando a conta. 
                            (Lucas)
                            
                19/07/2012 - Adicionado campo aux_nrdconta em procedure
                             inclui_altera_dados. (Jorge)

				08/03/2018 - Alterado tipo do parametro docmto de INT para DECIMAL
                             Chamado 851313 (Antonio R JR)
   
.............................................................................*/
                                                                            
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdopecxa AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_dtdepesq AS DATE                                           NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DECIMAL                                        NO-UNDO.
DEF VAR aux_tpdocmto AS INTE                                           NO-UNDO.
DEF VAR aux_dsdconta AS CHAR                                           NO-UNDO.
DEF VAR aux_vllanmto LIKE crapcme.vllanmto                             NO-UNDO.                                                          
DEF VAR aux_nrseqaut LIKE crapcme.nrseqaut                             NO-UNDO.                                                          
DEF VAR aux_nrccdrcb LIKE crapcme.nrccdrcb                             NO-UNDO.                                                          
DEF VAR aux_nmpesrcb LIKE crapcme.nmpesrcb                             NO-UNDO.                                                          
DEF VAR aux_nridercb LIKE crapcme.nridercb                             NO-UNDO.                                                          
DEF VAR aux_dtnasrcb LIKE crapcme.dtnasrcb                             NO-UNDO.                                                          
DEF VAR aux_desenrcb LIKE crapcme.desenrcb                             NO-UNDO.                                                          
DEF VAR aux_nmcidrcb LIKE crapcme.nmcidrcb                             NO-UNDO.                                                          
DEF VAR aux_nrceprcb LIKE crapcme.nrceprcb                             NO-UNDO.                                                          
DEF VAR aux_cdufdrcb LIKE crapcme.cdufdrcb                             NO-UNDO.                                                          
DEF VAR aux_flinfdst LIKE crapcme.flinfdst                             NO-UNDO.                                                          
DEF VAR aux_recursos LIKE crapcme.recursos                             NO-UNDO. 
DEF VAR aux_dstrecur LIKE crapcme.dstrecur                             NO-UNDO.
DEF VAR aux_vlretesp LIKE crapcme.vlretesp                             NO-UNDO.
DEF VAR aux_cpfcgrcb AS CHAR                                           NO-UNDO.
DEF VAR aux_flgimpri AS LOGI                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0104tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


PROCEDURE valores_entrada:

    FOR EACH tt-param:
    
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "cdopecxa" THEN aux_cdopecxa = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            
            WHEN "cdbccxlt" THEN aux_cdbccxlt = INTE(tt-param.valorCampo).
            WHEN "nrdolote" THEN aux_nrdolote = INTE(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = DECIMAL(tt-param.valorCampo).
            WHEN "tpdocmto" THEN aux_tpdocmto = INTE(tt-param.valorCampo).
            WHEN "dtdepesq" THEN aux_dtdepesq = DATE(tt-param.valorCampo).

            WHEN "dsdconta" THEN aux_dsdconta = tt-param.valorCampo.
            WHEN "vllanmto" THEN aux_vllanmto = DECI(tt-param.valorCampo).
            WHEN "nrseqaut" THEN aux_nrseqaut = INTE(tt-param.valorCampo).
            WHEN "nrccdrcb" THEN aux_nrccdrcb = INTE(tt-param.valorCampo).
            WHEN "nmpesrcb" THEN aux_nmpesrcb = tt-param.valorCampo.
            WHEN "nridercb" THEN aux_nridercb = tt-param.valorCampo.
            WHEN "dtnasrcb" THEN aux_dtnasrcb = DATE(tt-param.valorCampo).
            WHEN "desenrcb" THEN aux_desenrcb = tt-param.valorCampo.
            WHEN "nmcidrcb" THEN aux_nmcidrcb = tt-param.valorCampo.
            WHEN "nrceprcb" THEN aux_nrceprcb = INTE(tt-param.valorCampo).
            WHEN "cdufdrcb" THEN aux_cdufdrcb = tt-param.valorCampo.
            WHEN "flinfdst" THEN aux_flinfdst = LOGICAL(tt-param.valorCampo).
            WHEN "recursos" THEN aux_recursos = tt-param.valorCampo.
            WHEN "dstrecur" THEN aux_dstrecur = tt-param.valorCampo.
            WHEN "cpfcgrcb" THEN aux_cpfcgrcb = tt-param.valorCampo.
            WHEN "flgimpri" THEN aux_flgimpri = LOGICAL(tt-param.valorCampo).
            WHEN "vlretesp" THEN aux_vlretesp = DECI(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE busca_dados:

    RUN busca_dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_dtdepesq,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT aux_cdagenci,
                            INPUT aux_cdbccxlt,
                            INPUT aux_cdopecxa,
                            INPUT aux_nrdolote,
                            INPUT aux_nrdocmto,
                            INPUT aux_tpdocmto,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdconta,
                           OUTPUT TABLE tt-erro, 
                           OUTPUT TABLE tt-crapcme).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcme:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE busca_dados_assoc:

    RUN busca_dados_assoc IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_dtdepesq,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_idorigem,
                                  INPUT aux_cdagenci,
                                  INPUT aux_cdbccxlt,
                                  INPUT aux_cddopcao,
                                  INPUT aux_nrdconta,
                                  INPUT aux_nrccdrcb,
                                  INPUT aux_tpdocmto,
                                 OUTPUT TABLE tt-erro, 
                                 OUTPUT TABLE tt-crapcme).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcme:HANDLE,
                             INPUT "Dados_Assoc").
            RUN piXmlSave.
        END.

        
END PROCEDURE.

PROCEDURE valida_dados_nao_assoc:

    RUN valida_dados_nao_assoc IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_dtdepesq,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_idorigem,
                                       INPUT aux_cdagenci,
                                       INPUT aux_cdbccxlt,
                                       INPUT aux_cddopcao,             
                                       INPUT aux_cpfcgrcb,
                                       INPUT aux_nridercb,
                                       INPUT aux_dtnasrcb,
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


PROCEDURE inclui_altera_dados:

    RUN inclui_altera_dados IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_dtdepesq,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT aux_cdagenci,
                                    INPUT aux_cdopecxa,
                                    INPUT aux_cdbccxlt,
                                    INPUT aux_nrdolote,
                                    INPUT aux_nrdocmto,
                                    INPUT aux_tpdocmto,
                                    INPUT aux_cddopcao,
                                    INPUT aux_flgimpri,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrccdrcb,
                                    INPUT aux_nmpesrcb,
                                    INPUT aux_nridercb,
                                    INPUT aux_dtnasrcb,
                                    INPUT aux_desenrcb,
                                    INPUT aux_nmcidrcb,
                                    INPUT aux_nrceprcb,
                                    INPUT aux_cdufdrcb,
                                    INPUT aux_flinfdst,
                                    INPUT aux_recursos,
                                    INPUT aux_dstrecur,
                                    INPUT aux_cpfcgrcb, 
                                    INPUT aux_vlretesp,
                                   OUTPUT aux_nmarqimp,
                                   OUTPUT aux_nmarqpdf,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/* ......................................................................... */
