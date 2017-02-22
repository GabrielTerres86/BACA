/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0010.p
    Autor   : Gabriel Capoia
    Data    : 26/01/2012                       Ultima atualizacao: 04/08/2016

    Objetivo  : BO de Comunicacao XML x BO - BO CONSULTA BLOQUETOS DE COBRANCA

    Alteracoes: 28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                            (Daniel/Rafael/Reinert)
                            
                16/11/2015 - Adicioando parametro de entrada par_inestcri. em 
                             proc. consulta-bloqueto. (Jorge/Andrino)
   
                09/12/2015 - Adicionado parametro inserasa (Daniel) 
   
				04/08/2016 - Adicionado parametro cddemail (Reinert).
.............................................................................*/

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_rowidaux AS ROWID                                          NO-UNDO.

DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrcnvcob AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqim2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpd2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ininrdoc AS DECI                                           NO-UNDO.
DEF VAR aux_fimnrdoc AS DECI                                           NO-UNDO.
DEF VAR aux_nrinssac AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_indsitua AS INTE                                           NO-UNDO.
DEF VAR aux_numregis AS INTE                                           NO-UNDO.
DEF VAR aux_iniseque AS INTE                                           NO-UNDO.
DEF VAR aux_inidtven AS DATE                                           NO-UNDO.
DEF VAR aux_fimdtven AS DATE                                           NO-UNDO.
DEF VAR aux_inidtdpa AS DATE                                           NO-UNDO.
DEF VAR aux_fimdtdpa AS DATE                                           NO-UNDO.
DEF VAR aux_inidtmvt AS DATE                                           NO-UNDO.
DEF VAR aux_fimdtmvt AS DATE                                           NO-UNDO.
DEF VAR aux_consulta AS INTE                                           NO-UNDO.
DEF VAR aux_tpconsul AS INTE                                           NO-UNDO.
DEF VAR aux_dsdoccop AS CHAR                                           NO-UNDO.
DEF VAR aux_flgregis AS LOGI                                           NO-UNDO.
DEF VAR aux_cdcoopex AS INTE                                           NO-UNDO.
DEF VAR aux_cdbandoc AS INTE                                           NO-UNDO.
DEF VAR aux_cdinstru AS INTE                                           NO-UNDO.
DEF VAR aux_vlabatim AS DECI                                           NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.
DEF VAR aux_cdtpinsc AS INTE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_tprelato AS INTE                                           NO-UNDO.
DEF VAR aux_inidtper AS DATE                                           NO-UNDO.
DEF VAR aux_fimdtper AS DATE                                           NO-UNDO.
DEF VAR aux_cdstatus AS INTE                                           NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqint AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnmarqv AS CHAR                                           NO-UNDO.
DEF VAR aux_vrsarqvs AS LOGI                                           NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

DEF VAR aux_diasvcto AS INTE                                           NO-UNDO.
DEF VAR aux_hrtransf AS CHAR                                           NO-UNDO.
DEF VAR aux_hrrecebi AS CHAR                                           NO-UNDO.

DEF VAR aux_inestcri AS INTE                                           NO-UNDO.
DEF VAR aux_inserasa AS CHAR                                           NO-UNDO.
DEF VAR aux_cddemail AS INTE                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0010tt.i } 

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

    FOR EACH tt-param:

/*        MESSAGE tt-param.nomeCampo tt-param.valorCampo VIEW-AS ALERT-BOX. */

        CASE tt-param.nomeCampo:
              
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrcnvcob" THEN aux_nrcnvcob = INTE(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = INTE(tt-param.valorCampo).
            WHEN "ininrdoc" THEN aux_ininrdoc = DECI(tt-param.valorCampo).
            WHEN "fimnrdoc" THEN aux_fimnrdoc = DECI(tt-param.valorCampo).
            WHEN "nrinssac" THEN aux_nrinssac = DECI(tt-param.valorCampo).
            WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
            WHEN "indsitua" THEN aux_indsitua = INTE(tt-param.valorCampo).
            WHEN "numregis" THEN aux_numregis = INTE(tt-param.valorCampo).
            WHEN "iniseque" THEN aux_iniseque = INTE(tt-param.valorCampo).
            WHEN "inidtven" THEN aux_inidtven = DATE(tt-param.valorCampo).
            WHEN "fimdtven" THEN aux_fimdtven = DATE(tt-param.valorCampo).
            WHEN "inidtdpa" THEN aux_inidtdpa = DATE(tt-param.valorCampo).
            WHEN "fimdtdpa" THEN aux_fimdtdpa = DATE(tt-param.valorCampo).
            WHEN "inidtmvt" THEN aux_inidtmvt = DATE(tt-param.valorCampo).
            WHEN "fimdtmvt" THEN aux_fimdtmvt = DATE(tt-param.valorCampo).
            WHEN "consulta" THEN aux_consulta = INTE(tt-param.valorCampo).
            WHEN "tpconsul" THEN aux_tpconsul = INTE(tt-param.valorCampo).
            WHEN "dsdoccop" THEN aux_dsdoccop = tt-param.valorCampo.
            WHEN "flgregis" THEN aux_flgregis = LOGICAL(tt-param.valorCampo).
            WHEN "cdcoopex" THEN aux_cdcoopex = INTE(tt-param.valorCampo).
            WHEN "cdbandoc" THEN aux_cdbandoc = INTE(tt-param.valorCampo).
            WHEN "cdinstru" THEN aux_cdinstru = INTE(tt-param.valorCampo).
            WHEN "vlabatim" THEN aux_vlabatim = DECI(tt-param.valorCampo).
            WHEN "dtvencto" THEN aux_dtvencto = DATE(tt-param.valorCampo).
            WHEN "cdtpinsc" THEN aux_cdtpinsc = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "tprelato" THEN aux_tprelato = INTE(tt-param.valorCampo).
            WHEN "inidtper" THEN aux_inidtper = DATE(tt-param.valorCampo).
            WHEN "fimdtper" THEN aux_fimdtper = DATE(tt-param.valorCampo).
            WHEN "cdstatus" THEN aux_cdstatus = INTE(tt-param.valorCampo).
            WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
            WHEN "nmarqint" THEN aux_nmarqint = tt-param.valorCampo.
            WHEN "dsnmarqv" THEN aux_dsnmarqv = tt-param.valorCampo.
            WHEN "vrsarqvs" THEN aux_vrsarqvs = LOGICAL(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.

            WHEN "diasvcto" THEN aux_diasvcto = INTE(tt-param.valorCampo).
            WHEN "hrtransf" THEN aux_hrtransf = tt-param.valorCampo.
            WHEN "hrrecebi" THEN aux_hrrecebi = tt-param.valorCampo.

            WHEN "inestcri" THEN aux_inestcri = INTE(tt-param.valorCampo).
            WHEN "inserasa" THEN aux_inserasa = tt-param.valorCampo.   
            WHEN "cddemail" THEN aux_cddemail = INTE(tt-param.valorCampo).
                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
         BREAK BY tt-param-i.nomeTabela
               BY tt-param-i.sqControle:

         CASE tt-param-i.nomeTabela:

             WHEN "Arquivos" THEN DO:

                 IF  FIRST-OF(tt-param-i.sqControle) THEN
                     DO:
                        CREATE w-arquivos.
                        ASSIGN aux_rowidaux = ROWID(w-arquivos).
                     END.

                 FIND w-arquivos WHERE 
                     ROWID(w-arquivos) = aux_rowidaux NO-ERROR.

                 CASE tt-param-i.nomeCampo:
                     WHEN "tparquiv" THEN
                          w-arquivos.tparquiv = tt-param-i.valorCampo.
                     WHEN "dsarquiv" THEN
                          w-arquivos.dsarquiv = tt-param-i.valorCampo.
                     WHEN "flginteg" THEN
                          w-arquivos.flginteg = LOGICAL(tt-param-i.valorCampo).
                 END CASE.
                 
             END.

         END CASE.
     END. /* Fim FOR EACH tt-param-i */

END PROCEDURE. /* valores_entrada */

PROCEDURE buca_log:

    RUN buca_log IN hBO
               ( INPUT aux_cdcooper,
                 INPUT aux_cdagenci,
                 INPUT aux_nrdcaixa,
                 INPUT aux_nrdconta,
                 INPUT aux_nrcnvcob,
                 INPUT aux_nrdocmto,
                OUTPUT TABLE tt-logcob,
                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-logcob:HANDLE,
                            INPUT "Log").
           RUN piXmlSave.
        END.

END PROCEDURE. /* buca_log */

PROCEDURE consulta-bloqueto:

    RUN consulta-bloqueto IN hBO 
                        ( INPUT aux_cdcooper,
                          INPUT aux_nrdconta,
                          INPUT aux_ininrdoc,
                          INPUT aux_fimnrdoc,
                          INPUT aux_nrinssac,
                          INPUT aux_nmprimtl,
                          INPUT aux_indsitua,
                          INPUT aux_nrregist,
                          INPUT aux_iniseque,
                          INPUT aux_inidtven,
                          INPUT aux_fimdtven,
                          INPUT aux_inidtdpa,
                          INPUT aux_fimdtdpa,
                          INPUT aux_inidtmvt,
                          INPUT aux_fimdtmvt,
                          INPUT aux_consulta, 
                          INPUT aux_tpconsul,
                          INPUT aux_idorigem,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_dsdoccop,
                          INPUT aux_flgregis,
                          INPUT aux_inestcri,
					      INPUT aux_inserasa,
                         OUTPUT aux_qtregist,
                         OUTPUT aux_nmdcampo,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-consulta-blt).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-consulta-blt:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
           RUN piXmlSave.
        END.

END PROCEDURE. /* consulta-bloqueto */

PROCEDURE busca_instrucoes:

    RUN busca_instrucoes IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdcoopex,
                         INPUT aux_cdbandoc,
                        OUTPUT TABLE tt-crapoco,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapoco:HANDLE,
                            INPUT "Instrucoes").
           RUN piXmlSave.
        END.

END PROCEDURE. /* busca_instrucoes */

PROCEDURE valida_instrucoes:

    RUN valida_instrucoes IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_cdinstru,
                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE. /* valida_instrucoes */

PROCEDURE grava_instrucoes:

    RUN grava_instrucoes IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cdoperad,
                         INPUT aux_cdinstru,
                         INPUT aux_nrdconta,
                         INPUT aux_nrcnvcob,
                         INPUT aux_nrdocmto,
                         INPUT aux_vlabatim,
                         INPUT aux_dtvencto,
                         INPUT aux_cdtpinsc,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE. /* grava_instrucoes */

PROCEDURE exporta_boleto:

    RUN exporta_boleto IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_idorigem,
                       INPUT aux_nmdatela,
                       INPUT aux_cdprogra,
                       INPUT aux_dtmvtolt,
                       INPUT aux_nrdconta,
                       INPUT aux_ininrdoc,
                       INPUT aux_fimnrdoc,
                       INPUT aux_nmprimtl,
                       INPUT aux_inidtven,
                       INPUT aux_fimdtven,
                       INPUT aux_inidtdpa,
                       INPUT aux_fimdtdpa,
                       INPUT aux_inidtmvt,
                       INPUT aux_fimdtmvt,
                       INPUT aux_consulta,
                       INPUT aux_tpconsul,
                       INPUT aux_dsdoccop,
                       INPUT aux_flgregis,
                       INPUT aux_dsiduser,
                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE. /* exporta_boleto */

PROCEDURE busca_associado:

    RUN busca_associado IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_nrdconta,
                       OUTPUT TABLE tt-crapass,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapass:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* busca_associado */

PROCEDURE gera_relatorio:

    RUN gera_relatorio IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_idorigem,
                       INPUT aux_nmdatela,
                       INPUT aux_cdprogra,
                       INPUT aux_dtmvtolt,
                       INPUT aux_nrdconta,
                       INPUT aux_nmprimtl,
                       INPUT aux_tprelato,
                       INPUT aux_inidtper,
                       INPUT aux_fimdtper,
                       INPUT aux_cdstatus,
                       INPUT aux_cdagencx,
                       INPUT aux_dsiduser,
                       INPUT aux_inserasa,
                       INPUT aux_cddemail,
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
                                            "validacao de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* gera_relatorio */

PROCEDURE integra_arquivo:

    RUN integra_arquivo IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_nmdatela,
                        INPUT aux_cdprogra,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cdoperad,
                        INPUT aux_dsiduser,
                        INPUT aux_nmarqint,
                        INPUT aux_dsnmarqv,
                        INPUT aux_vrsarqvs,
                        INPUT TABLE w-arquivos,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT aux_nmarqim2,
                       OUTPUT aux_nmarqpd2,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlAtributo (INPUT "nmarqpd2", INPUT aux_nmarqpd2).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlAtributo (INPUT "nmarqpd2", INPUT aux_nmarqpd2).
           RUN piXmlSave.
        END.

END PROCEDURE. /* integra_arquivo */

PROCEDURE carrega_arquivos:

    RUN carrega_arquivos IN hBO
                       ( INPUT aux_nmarqint,
                        OUTPUT TABLE w-arquivos).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE w-arquivos:HANDLE,
                            INPUT "Arquivos").
           RUN piXmlSave.
        END.

END PROCEDURE. /* carrega_arquivos */

PROCEDURE busca_par_emissao_cce:

        RUN busca_par_emissao_cce IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                         OUTPUT aux_diasvcto,
                                         OUTPUT aux_hrtransf,
                                         OUTPUT aux_hrrecebi,
                                         OUTPUT TABLE tt-erro).
                                 

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE tt-erro THEN
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
               RUN piXmlAtributo (INPUT "diasvcto", INPUT STRING(aux_diasvcto,"99")).
               RUN piXmlAtributo (INPUT "hrtransf", INPUT aux_hrtransf).
               RUN piXmlAtributo (INPUT "hrrecebi", INPUT aux_hrrecebi).
               RUN piXmlSave.
            END.

END PROCEDURE.

PROCEDURE altera_par_emissao_cce:

    RUN altera_par_emissao_cce IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_diasvcto,
                              INPUT aux_hrtransf,
                              INPUT aux_hrrecebi,
                              OUTPUT TABLE tt-erro).
                              

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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


