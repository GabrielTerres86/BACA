/*.............................................................................

    Programa: xb1wgen0072.p
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 27/04/2017

    Objetivo  : BO de Comunicacao XML x BO - CONTAS, RESPONSAVEL LEGAL

    Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
                              
                16/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                             (Adriano). 
                             
                17/05/2015 - Reformulacao cadastral (Gabriel-RKAM).                          
   
                27/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

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
DEF VAR aux_nrdctato AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcto AS DECI                                           NO-UNDO.
DEF VAR aux_menorida AS LOG                                            NO-UNDO.

DEF VAR aux_nmdavali AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocava AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocava AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoeddoc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufddoc AS CHAR                                           NO-UNDO.
DEF VAR aux_dtemddoc AS DATE                                           NO-UNDO.
DEF VAR aux_dtnascto AS DATE                                           NO-UNDO.
DEF VAR aux_cdsexcto AS INTE                                           NO-UNDO.
DEF VAR aux_cdestcvl AS INTE                                           NO-UNDO.
DEF VAR aux_cdnacion AS INTE                                           NO-UNDO.
DEF VAR aux_dsnatura AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_nrendere AS INTE                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_complend AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                           NO-UNDO.
DEF VAR aux_nmmaecto AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpaicto AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_cpfprocu AS DEC                                            NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_dtdenasc AS DATE                                           NO-UNDO.
DEF VAR aux_cdhabmen AS INT                                            NO-UNDO.
DEF VAR aux_permalte AS LOG                                            NO-UNDO.
DEF VAR aux_cdrlcrsp AS INTE                                           NO-UNDO.
DEF VAR aux_rowidrsp AS ROWID                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0072tt.i } 
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
            WHEN "nrdctato" THEN aux_nrdctato = INTE(tt-param.valorCampo).
            WHEN "nrcpfcto" THEN aux_nrcpfcto = DECI(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nmdavali" THEN aux_nmdavali = tt-param.valorCampo.
            WHEN "tpdocava" THEN aux_tpdocava = tt-param.valorCampo.
            WHEN "nrdocava" THEN aux_nrdocava = tt-param.valorCampo.
            WHEN "cdoeddoc" THEN aux_cdoeddoc = tt-param.valorCampo.
            WHEN "cdufddoc" THEN aux_cdufddoc = tt-param.valorCampo.
            WHEN "dtemddoc" THEN aux_dtemddoc = DATE(tt-param.valorCampo).
            WHEN "dtnascto" THEN aux_dtnascto = DATE(tt-param.valorCampo).
            WHEN "cdsexcto" THEN aux_cdsexcto = INTE(tt-param.valorCampo).
            WHEN "cdestcvl" THEN aux_cdestcvl = INTE(tt-param.valorCampo).
            WHEN "cdnacion" THEN aux_cdnacion = INTE(tt-param.valorCampo).
            WHEN "dsnatura" THEN aux_dsnatura = tt-param.valorCampo.        
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
            WHEN "dsendere" THEN aux_dsendere = tt-param.valorCampo.
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "nrendere" THEN aux_nrendere = INTE(tt-param.valorCampo).
            WHEN "cdufende" THEN aux_cdufende = tt-param.valorCampo.
            WHEN "complend" THEN aux_complend = tt-param.valorCampo.
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "nmmaecto" THEN aux_nmmaecto = tt-param.valorCampo.
            WHEN "nmpaicto" THEN aux_nmpaicto = tt-param.valorCampo.
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "cpfprocu" THEN aux_cpfprocu = DEC(tt-param.valorCampo).
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "dtdenasc" THEN aux_dtdenasc = DATE(tt-param.valorCampo).
            WHEN "cdhabmen" THEN aux_cdhabmen = INTE(tt-param.valorCampo).
            WHEN "permalte" THEN aux_permalte = LOGICAL(tt-param.valorCampo).
            WHEN "cdrlcrsp" THEN aux_cdrlcrsp = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i BREAK BY tt-param-i.nomeTabela
                               BY tt-param-i.sqControle:
        
      CASE tt-param-i.nomeTabela:

            WHEN "RespLegal" THEN DO:
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-resp.
                       ASSIGN aux_rowidrsp = ROWID(tt-resp).
                    END.

                FIND tt-resp WHERE 
                     ROWID(tt-resp) = aux_rowidrsp NO-ERROR.


                CASE tt-param-i.nomeCampo:
                                                     
                    WHEN "cddctato" THEN
                        ASSIGN tt-resp.cddctato = 
                            INTE(REPLACE(tt-param-i.valorCampo,"-","")).
                    WHEN "nrdrowid" THEN
                        ASSIGN tt-resp.nrdrowid = 
                          TO-ROWID(tt-param-i.valorCampo).
                    WHEN "cdcooper" THEN
                        ASSIGN tt-resp.cdcooper = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrctamen" THEN 
                        ASSIGN tt-resp.nrctamen = 
                            INTE(tt-param-i.valorCampo).                   
                     WHEN "nrcpfmen" THEN
                        ASSIGN tt-resp.nrcpfmen = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "idseqmen" THEN
                        ASSIGN tt-resp.idseqmen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        ASSIGN tt-resp.nrdconta = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfcgc" THEN
                        ASSIGN tt-resp.nrcpfcgc = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "nmrespon" THEN
                        ASSIGN tt-resp.nmrespon = 
                            tt-param-i.valorCampo.
                    WHEN "nridenti" THEN
                        ASSIGN tt-resp.nridenti = 
                            tt-param-i.valorCampo.
                    WHEN "tpdeiden" THEN
                        ASSIGN tt-resp.tpdeiden = 
                            tt-param-i.valorCampo.
                    WHEN "dsorgemi" THEN
                        ASSIGN tt-resp.dsorgemi = 
                            tt-param-i.valorCampo.
                    WHEN "cdufiden" THEN
                        ASSIGN tt-resp.cdufiden = 
                            tt-param-i.valorCampo.
                    WHEN "dtemiden" THEN
                        ASSIGN tt-resp.dtemiden = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "dtnascin" THEN
                        ASSIGN tt-resp.dtnascin = 
                            DATE(tt-param-i.valorCampo).       
                    WHEN "cddosexo" THEN
                        ASSIGN tt-resp.cddosexo = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdestciv" THEN
                        ASSIGN tt-resp.cdestciv = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdnacion" THEN
                        ASSIGN tt-resp.cdnacion = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dsnatura" THEN
                        ASSIGN tt-resp.dsnatura = 
                            tt-param-i.valorCampo.
                    WHEN "cdcepres" THEN
                        ASSIGN tt-resp.cdcepres = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "dsendres" THEN
                        ASSIGN tt-resp.dsendres = 
                            tt-param-i.valorCampo.
                    WHEN "nrendres" THEN
                        ASSIGN tt-resp.nrendres = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscomres" THEN
                        ASSIGN tt-resp.dscomres = 
                            tt-param-i.valorCampo.
                    WHEN "dsbaires" THEN
                        ASSIGN tt-resp.dsbaires = 
                            tt-param-i.valorCampo.
                    WHEN "nrcxpost" THEN
                        ASSIGN tt-resp.nrcxpost = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscidres" THEN
                        ASSIGN tt-resp.dscidres = 
                            tt-param-i.valorCampo.
                    WHEN "dsdufres" THEN
                        ASSIGN tt-resp.dsdufres = 
                            tt-param-i.valorCampo.
                    WHEN "nmpairsp" THEN
                        ASSIGN tt-resp.nmpairsp = 
                            tt-param-i.valorCampo.
                    WHEN "nmmaersp" THEN
                        ASSIGN tt-resp.nmmaersp = 
                            tt-param-i.valorCampo.
                    WHEN "cdrlcrsp" THEN
                        ASSIGN tt-resp.cdrlcrsp =
                            INTE(tt-param-i.valorCampo).
                    WHEN "cddopcao" THEN 
                        ASSIGN tt-resp.cddopcao = 
                            tt-param-i.valorCampo.
                    WHEN "deletado" THEN
                        ASSIGN tt-resp.deletado = 
                            LOGICAL(tt-param-i.valorCampo). 
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END. /* "resp Legal"  */

        END CASE. /* CASE tt-param-i.nomeTabela: */
                         
    END.

END PROCEDURE.    

PROCEDURE Busca_Dados:

    /*Alteração: Recebe parametro aux_msgconta*/
    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdctato,
                            INPUT aux_nrcpfcto,
                            INPUT aux_nrdrowid,
                            INPUT aux_cpfprocu,
                            INPUT aux_nmrotina,
                            INPUT aux_dtdenasc,
                            INPUT aux_cdhabmen,
                            INPUT aux_permalte,
                           OUTPUT aux_menorida,
                           OUTPUT aux_msgconta,
                           OUTPUT TABLE tt-crapcrl,
                           OUTPUT TABLE tt-erro) NO-ERROR.

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcrl:HANDLE,
                             INPUT "RespLegal").
            RUN piXmlAtributo (INPUT "menorida", INPUT STRING(aux_menorida)).
            /*Alterção: Passo atributo para web*/
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
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
                             INPUT aux_nrdrowid,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_nrdctato,
                             INPUT STRING(aux_nrcpfcto),
                             INPUT aux_nmdavali,
                             INPUT aux_tpdocava,
                             INPUT aux_nrdocava,
                             INPUT aux_cdoeddoc,
                             INPUT aux_cdufddoc,
                             INPUT aux_dtemddoc,
                             INPUT aux_dtnascto,
                             INPUT aux_cdsexcto,
                             INPUT aux_cdestcvl,
                             INPUT aux_cdnacion,
                             INPUT aux_dsnatura,
                             INPUT aux_nrcepend,
                             INPUT aux_dsendere,
                             INPUT aux_nmbairro,
                             INPUT aux_nmcidade,
                             INPUT aux_cdufende,
                             INPUT aux_nmmaecto,
                             INPUT NO, /*Flag replica*/
                             INPUT aux_cpfprocu,
                             INPUT aux_nmrotina,
                             INPUT aux_dtdenasc,
                             INPUT aux_cdhabmen,
                             INPUT aux_permalte,
                             INPUT TABLE tt-resp,
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

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
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
                            INPUT aux_nrdctato,
                            INPUT STRING(aux_nrcpfcto),
                            INPUT aux_nmdavali,
                            INPUT aux_tpdocava,
                            INPUT aux_nrdocava,
                            INPUT aux_cdoeddoc,
                            INPUT aux_cdufddoc,
                            INPUT aux_dtemddoc,
                            INPUT aux_dtnascto,
                            INPUT aux_cdsexcto,
                            INPUT aux_cdestcvl,
                            INPUT aux_cdnacion,
                            INPUT aux_dsnatura,
                            INPUT aux_nrcepend,
                            INPUT aux_dsendere,
                            INPUT aux_nmbairro,
                            INPUT aux_nmcidade,
                            INPUT aux_nrendere,
                            INPUT aux_cdufende,
                            INPUT aux_complend,
                            INPUT aux_nrcxapst,
                            INPUT aux_nmmaecto,
                            INPUT aux_nmpaicto,
                            INPUT aux_cpfprocu,
                            INPUT aux_cdrlcrsp,
                            INPUT aux_nmrotina,
                           OUTPUT aux_msgalert,
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
                                             "validacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlAtributo (INPUT "cdufende", INPUT aux_cdufende).
            RUN piXmlSave.
        END.

END PROCEDURE.

