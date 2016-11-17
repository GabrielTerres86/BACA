/*.............................................................................

   Programa: xb1wgen0170.p
   Autor   : Lucas R.
   Data    : Agosto/2013                        Ultima atualizacao: 01/09/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO (b1wgen0170.p)

   Alteracoes: 09/06/2014 - Adicionado procedure importa-dados-crapcyc (Daniel).
   
               01/09/2015 - Adicionado os campos de assessoria e motivo CIN
                            (Douglas - Melhoria 12)
   
.............................................................................*/

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_cdorigem AS INTE                                           NO-UNDO.
DEF VAR aux_flgjudic AS LOG                                            NO-UNDO.
DEF VAR aux_flextjud AS LOG                                            NO-UNDO.
DEF VAR aux_flgehvip AS LOG                                            NO-UNDO.
DEF VAR aux_flgmsger AS LOG                                            NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_iniregis AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF VAR aux_lsdconta AS CHAR                                           NO-UNDO.
DEF VAR aux_lscontra AS CHAR                                           NO-UNDO.
DEF VAR aux_lsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_lsjudici AS CHAR                                           NO-UNDO.
DEF VAR aux_lsextjud AS CHAR                                           NO-UNDO.
DEF VAR aux_lsgehvip AS CHAR                                           NO-UNDO.
DEF VAR aux_lsdtenvc AS CHAR                                           NO-UNDO.
DEF VAR aux_lsmotcin AS CHAR                                           NO-UNDO.
DEF VAR aux_lsassess AS CHAR                                           NO-UNDO.

DEF VAR aux_nmdarqui AS CHAR                                           NO-UNDO. 
DEF VAR aux_dsdircop AS CHAR                                           NO-UNDO. 

DEF VAR aux_dtenvcbr AS DATE                                           NO-UNDO. 
DEF VAR aux_cdassess AS INTE                                           NO-UNDO. 
DEF VAR aux_cdmotcin AS INTE                                           NO-UNDO. 

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0170tt.i }

/*................................ PROCEDURES ...............................*/


/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     */
/*****************************************************************************/
PROCEDURE valores_entrada:
FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "cdorigem" THEN aux_cdorigem = INTE(tt-param.valorCampo).
            WHEN "flgjudic" THEN aux_flgjudic = LOGICAL(tt-param.valorCampo).
            WHEN "flextjud" THEN aux_flextjud = LOGICAL(tt-param.valorCampo).
            WHEN "flgehvip" THEN aux_flgehvip = LOGICAL(tt-param.valorCampo).
            WHEN "flgmsger" THEN aux_flgmsger = LOGICAL(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "iniregis" THEN aux_iniregis = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).

            WHEN "lsdconta" THEN aux_lsdconta = tt-param.valorCampo.
            WHEN "lscontra" THEN aux_lscontra = tt-param.valorCampo.
            WHEN "lsorigem" THEN aux_lsorigem = tt-param.valorCampo.
            WHEN "lsjudici" THEN aux_lsjudici = tt-param.valorCampo.
            WHEN "lsextjud" THEN aux_lsextjud = tt-param.valorCampo.
            WHEN "lsgehvip" THEN aux_lsgehvip = tt-param.valorCampo.
            WHEN "lsdtenvc" THEN aux_lsdtenvc = tt-param.valorCampo.
            WHEN "lsmotcin" THEN aux_lsmotcin = tt-param.valorCampo.
            WHEN "lsassess" THEN aux_lsassess = tt-param.valorCampo.

            WHEN "nmdarqui" THEN aux_nmdarqui = tt-param.valorCampo.
            WHEN "dsdircop" THEN aux_dsdircop = tt-param.valorCampo.

            WHEN "dtenvcbr" THEN aux_dtenvcbr = DATE(tt-param.valorCampo).
            WHEN "cdassess" THEN aux_cdassess = INTE(tt-param.valorCampo).
            WHEN "cdmotcin" THEN aux_cdmotcin = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


PROCEDURE valida-cadcyb:

    RUN valida-cadcyb IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_idseqttl,
                             INPUT aux_nrdconta,
                             INPUT aux_nrctremp,
                             INPUT aux_cdorigem,
                             INPUT aux_cddopcao,
                            OUTPUT aux_flgmsger,
                            OUTPUT TABLE tt-crapcyc,
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
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE
        DO:
            FIND FIRST tt-crapcyc NO-LOCK NO-ERROR.
            IF AVAIL tt-crapcyc THEN
            DO:
                RUN piXmlNew.
                RUN piXmlAtributo (INPUT "flgjudic", INPUT STRING(tt-crapcyc.flgjudic) ).
                RUN piXmlAtributo (INPUT "flextjud", INPUT STRING(tt-crapcyc.flextjud) ).
                RUN piXmlAtributo (INPUT "flgehvip", INPUT STRING(tt-crapcyc.flgehvip) ).
                RUN piXmlAtributo (INPUT "flgmsger", INPUT STRING(aux_flgmsger) ).
                RUN piXmlAtributo (INPUT "dtenvcbr", INPUT STRING(tt-crapcyc.dtenvcbr) ).
                RUN piXmlAtributo (INPUT "cdassess", INPUT STRING(tt-crapcyc.cdassess) ).
                RUN piXmlAtributo (INPUT "nmassess", INPUT tt-crapcyc.nmassess).
                RUN piXmlAtributo (INPUT "cdmotcin", INPUT STRING(tt-crapcyc.cdmotcin) ).
                RUN piXmlAtributo (INPUT "dsmotcin", INPUT tt-crapcyc.dsmotcin) .
                RUN piXmlSave.           
            END.
        END.                   

END PROCEDURE.

PROCEDURE grava-dados-crapcyc:

    RUN grava-dados-crapcyc IN hBO( INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_inproces,
                                    INPUT aux_idseqttl,
                                    INPUT aux_lsdconta,
                                    INPUT aux_lscontra,
                                    INPUT aux_lsorigem,
                                    INPUT aux_lsjudici,
                                    INPUT aux_lsextjud,
                                    INPUT aux_lsgehvip,
                                    INPUT aux_lsdtenvc,
                                    INPUT aux_lsassess,
                                    INPUT aux_lsmotcin,
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
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.           
        END.                   

END PROCEDURE.

PROCEDURE altera-dados-crapcyc:

    RUN altera-dados-crapcyc IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctremp,
                                     INPUT aux_cdorigem,
                                     INPUT aux_flgjudic,
                                     INPUT aux_flextjud,
                                     INPUT aux_flgehvip,
                                     INPUT aux_dtenvcbr,
                                     INPUT aux_cdassess,
                                     INPUT aux_cdmotcin,
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
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.           
        END.                   


END PROCEDURE.

PROCEDURE excluir-dados-crapcyc:

    RUN excluir-dados-crapcyc IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_nrctremp,
                                      INPUT aux_cdorigem,
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
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.           
        END.                   

END PROCEDURE.

PROCEDURE consulta-dados-crapcyc:

    RUN consulta-dados-crapcyc IN hBO (INPUT aux_cdcooper,    
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nrctremp,
                                       INPUT aux_cdorigem,
                                       INPUT aux_nrregist,
                                       INPUT aux_nriniseq,
                                       INPUT aux_cdassess,
                                       INPUT aux_cdmotcin,
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-crapcyc,
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
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapcyc:HANDLE, INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)). 
           RUN piXmlSave.           
        END.                   

END PROCEDURE.


PROCEDURE importa-dados-crapcyc:

    RUN importa-dados-crapcyc IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdarqui,
                                      INPUT aux_dsdircop,
                                      INPUT aux_dtmvtolt,
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
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.           
        END.                   


END PROCEDURE.
