/*.............................................................................

    Programa: xb1wgen0063.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 15/10/2013

    Objetivo  : BO de Comunicacao XML x BO - IMPRESSOES

    Alteracoes: 24/07/2013 - Inclusao da procedure Imprime_Assinatura
                             (Jean Michel).
                             
                02/10/2013 - Inclusao da procedure busca_titulares_impressao e
                             busca_procuradores_impressao (Jean Michel). 
                             
                15/10/2013 - Incluido a procedure busca_lista_titulares (Jean Michel)                         
   
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
DEF VAR aux_tprelato AS CHAR                                           NO-UNDO.
DEF VAR aux_flgpreen AS LOG                                            NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_tppessoa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctato AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregist AS INT                                            NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0062tt.i }
{ sistema/generico/includes/b1wgen0063tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }

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
            WHEN "tprelato" THEN aux_tprelato = tt-param.valorCampo.
            WHEN "flgpreen" THEN aux_flgpreen = LOGICAL(tt-param.valorCampo).
            WHEN "tppessoa" THEN aux_tppessoa = INTE(tt-param.valorCampo).
            WHEN "nrdctato" THEN aux_nrdctato = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.
            WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

PROCEDURE Busca_Impressao:
    
    RUN Busca_Impressao IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT YES,
                                INPUT aux_dtmvtolt,
                                INPUT aux_tprelato,
                                INPUT aux_flgpreen,
                               OUTPUT aux_msgalert,
                               OUTPUT TABLE tt-abert-ident,
                               OUTPUT TABLE tt-abert-psfis,
                               OUTPUT TABLE tt-abert-compf,
                               OUTPUT TABLE tt-abert-decpf,
                               OUTPUT TABLE tt-abert-psjur,
                               OUTPUT TABLE tt-abert-compj,
                               OUTPUT TABLE tt-abert-decpj,
                               OUTPUT TABLE tt-termo-ident,
                               OUTPUT TABLE tt-termo-assin,
                               OUTPUT TABLE tt-termo-asstl,
                               OUTPUT TABLE tt-finan-cabec,
                               OUTPUT TABLE tt-finan-ficha,
                               OUTPUT TABLE tt-fcad,
                               OUTPUT TABLE tt-fcad-telef,
                               OUTPUT TABLE tt-fcad-email,
                               OUTPUT TABLE tt-fcad-psfis,
                               OUTPUT TABLE tt-fcad-filia,
                               OUTPUT TABLE tt-fcad-comer,
                               OUTPUT TABLE tt-fcad-cbens,
                               OUTPUT TABLE tt-fcad-depen,
                               OUTPUT TABLE tt-fcad-ctato,                      
                               OUTPUT TABLE tt-fcad-respl,
                               OUTPUT TABLE tt-fcad-cjuge,
                               OUTPUT TABLE tt-fcad-psjur,
                               OUTPUT TABLE tt-fcad-regis,
                               OUTPUT TABLE tt-fcad-procu,
                               OUTPUT TABLE tt-fcad-bensp,
                               OUTPUT TABLE tt-fcad-refer,
                               OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad:HANDLE,
                             INPUT "FCad").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-telef:HANDLE,
                             INPUT "FCadTelefone").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-email:HANDLE,
                             INPUT "FCadEmail").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-psfis:HANDLE,
                             INPUT "FCadIdenticacaoPF").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-filia:HANDLE,
                             INPUT "FCadFiliacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-comer:HANDLE,
                             INPUT "FCadComercial").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-cbens:HANDLE,
                             INPUT "FCadBens").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-depen:HANDLE,
                             INPUT "FCadDependentes").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-ctato:HANDLE,
                             INPUT "FCadContatos").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-respl:HANDLE,
                             INPUT "FCadRespLegal").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-cjuge:HANDLE,
                             INPUT "FCadConjuge").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-psjur:HANDLE,
                             INPUT "FCadIdenticacaoPJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-regis:HANDLE,
                             INPUT "FCadRegistro").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-procu:HANDLE,
                             INPUT "FCadProcuradores").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-bensp:HANDLE,
                             INPUT "FCadBensProcurad").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-refer:HANDLE,
                             INPUT "FCadReferencias").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-ident:HANDLE,
                             INPUT "AberIdentificacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-psfis:HANDLE,
                             INPUT "AberPF").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-compf:HANDLE,
                             INPUT "AberComplementoPF").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-decpf:HANDLE,
                             INPUT "AberDeclaracaoPF").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-psjur:HANDLE,
                             INPUT "AberPJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-compj:HANDLE,
                             INPUT "AberComplementoPJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-abert-decpj:HANDLE,
                             INPUT "AberDeclaracaoPJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo-ident:HANDLE,
                             INPUT "TermoIdentificacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo-assin:HANDLE,
                             INPUT "TermoAssinatura").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo-asstl:HANDLE,
                             INPUT "TermoAssinaturaTtl").
            RUN piXmlExport (INPUT TEMP-TABLE tt-finan-cabec:HANDLE,
                             INPUT "FinaceiroAbertura").
            RUN piXmlExport (INPUT TEMP-TABLE tt-finan-ficha:HANDLE,
                             INPUT "FinaceiroFicha").
            RUN piXmlAtributo (INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Busca_TpRelatorio:

    RUN Busca_TpRelatorio IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_flgpreen,
                                 OUTPUT TABLE tt-tprelato,
                                 OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tprelato:HANDLE,
                             INPUT "TpRelatorio").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Imprime_Assinatura:

    RUN Imprime_Assinatura IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_cddopcao,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrdctato,
                                   INPUT aux_idseqttl,
                                   INPUT aux_tppessoa,
                                   INPUT aux_nrcpfcgc,
                                   INPUT aux_nmendter,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Ocorreu erro ao gerar a impressão.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT aux_nmarqimp).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE busca_titulares_impressao:
    
    RUN busca-titulares-impressao IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-crapttl).
    
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapttl:HANDLE,
                               INPUT "Titulares").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.

PROCEDURE busca_procuradores_impressao:
    
    RUN busca-procuradores-impressao IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
          INPUT aux_cdagenci,
          INPUT aux_nrdcaixa,
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-cratavt,
         OUTPUT TABLE tt-cratpod,
         OUTPUT TABLE tt-erro).
    
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-cratavt:HANDLE,
                               INPUT "Procuradores").
            RUN piXmlExport   (INPUT TEMP-TABLE tt-cratpod:HANDLE,
                               INPUT "Poderes").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.

PROCEDURE busca_lista_titulares:
    
    RUN busca-lista-titulares IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_nrdconta,
         OUTPUT aux_qtregist, 
         OUTPUT TABLE tt-crapttl).
    
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapttl:HANDLE,
                               INPUT "Titulares").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
           
        END.
END.
