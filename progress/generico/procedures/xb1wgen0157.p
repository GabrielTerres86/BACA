/*.............................................................................

   Programa: xb1wgen0157.p
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2013                     Ultima atualizacao: / / 

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela RATBND 

   Alteracoes: 

............................................................................ */

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagenci LIKE crapass.cdagenci                             NO-UNDO.
    
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR par_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR aux_nrdconta LIKE crapass.nrdconta                             NO-UNDO.

DEF VAR aux_qtrequis AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsgcnt AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR ret_dsfinemp AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR ret_dssitfin AS CHAR                                           NO-UNDO.
DEF VAR aux_tpctrato AS INTE                                           NO-UNDO.

DEF VAR aux_tipopesq AS CHAR                                           NO-UNDO.

DEF VAR aux_inpessoa AS INT                                            NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nrctrato AS INT                                            NO-UNDO.
DEF VAR aux_tppesqui AS CHAR                                           NO-UNDO.
                                                                   
DEF VAR aux_vlctrbnd AS DECI                                           NO-UNDO.
DEF VAR aux_qtparbnd AS INT                                            NO-UNDO.
DEF VAR aux_nrinfcad AS INT                                            NO-UNDO.
DEF VAR aux_dsinfcad AS CHAR                                           NO-UNDO.
DEF VAR aux_nrgarope AS INT                                            NO-UNDO.
DEF VAR aux_dsgarope AS CHAR                                           NO-UNDO.
DEF VAR aux_nrliquid AS INT                                            NO-UNDO.
DEF VAR aux_dsliquid AS CHAR                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INT                                            NO-UNDO.
DEF VAR aux_dspatlvr AS CHAR                                           NO-UNDO.
DEF VAR aux_nrperger AS INT                                            NO-UNDO.
DEF VAR aux_dsperger AS CHAR                                           NO-UNDO.
DEF VAR aux_insitrat AS INT                                            NO-UNDO.
DEF VAR aux_dssitcrt AS CHAR                                           NO-UNDO.
DEF VAR aux_vlempbnd AS DECI                                           NO-UNDO.
DEF VAR ret_tpcritic AS INT                                            NO-UNDO.
DEF VAR ret_dscritic AS CHAR                                           NO-UNDO.
DEF VAR ret_dsdrisco AS CHAR                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_tprelato AS CHAR                                           NO-UNDO.
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.
DEF VAR aux_dsdrisco AS CHAR                                           NO-UNDO.
DEF VAR aux_tpcritic AS INTE                                           NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_flgvalid AS LOGICAL                                        NO-UNDO.
DEF VAR aux_flgsuces AS LOGICAL                                        NO-UNDO.

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0157tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen9999tt.i } 

{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/supermetodos.i }

/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = STRING(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = STRING(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "tipopesq" THEN aux_tipopesq = STRING(tt-param.valorCampo).
            WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrctrato" THEN aux_nrctrato = INTE(tt-param.valorCampo).
            WHEN "tppesqui" THEN aux_tppesqui = STRING(tt-param.valorCampo).
            WHEN "vlempbnd" THEN aux_vlempbnd = DECI(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "qtparbnd" THEN aux_qtparbnd = INTE(tt-param.valorCampo).
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo).
            WHEN "nrgarope" THEN aux_nrgarope = INTE(tt-param.valorCampo).
            WHEN "nrliquid" THEN aux_nrliquid = INTE(tt-param.valorCampo).
            WHEN "nrperger" THEN aux_nrperger = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "tpctrato" THEN aux_tpctrato = INTE(tt-param.valorCampo).
            WHEN "tprelato" THEN aux_tprelato = tt-param.valorCampo.
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).
    END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/********************************* PROCEDURES *********************************/

PROCEDURE consulta-conta:

    RUN consulta-conta IN hBO (INPUT aux_cdcooper, 
                               INPUT aux_nrdconta, 
                               INPUT aux_cdoperad, 
                               INPUT aux_nmdatela, 
                               INPUT aux_cdagenci,
                               INPUT aux_tipopesq,
                               OUTPUT aux_qtrequis, 
                               OUTPUT aux_nmprimtl,
                               OUTPUT aux_dsmsgcnt, 
                               OUTPUT TABLE tt-associado,
                               OUTPUT TABLE tt-ctrbndes,
                               OUTPUT TABLE tt-erro).
   
    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.     
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.
    
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    
    END.
    ELSE DO:
        
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-associado:HANDLE,
                         INPUT "Associados").

        RUN piXmlExport (INPUT TEMP-TABLE tt-ctrbndes:HANDLE,
                         INPUT "Contratos").

        RUN piXmlAtributo (INPUT "qtrequis",INPUT STRING(aux_qtrequis)).
        RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
        RUN piXmlAtributo (INPUT "dsmsgcnt",INPUT STRING(aux_dsmsgcnt)).
        RUN piXmlSave.
        
    END.
           
END PROCEDURE.

PROCEDURE consulta-informacao-ratbnd:
 
    RUN consulta-informacao-ratbnd IN hBO (INPUT aux_cdcooper, 
                                           INPUT aux_cdoperad, 
                                           INPUT aux_nmdatela, 
                                           INPUT aux_inproces,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_nrdconta, 
                                           INPUT aux_inpessoa, 
                                           INPUT aux_nrcpfcgc, 
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrctrato,
                                           INPUT aux_tppesqui,
                                           OUTPUT aux_vlctrbnd, 
                                           OUTPUT aux_qtparbnd, 
                                           OUTPUT aux_nrinfcad, 
                                           OUTPUT aux_dsinfcad, 
                                           OUTPUT aux_nrgarope, 
                                           OUTPUT aux_dsgarope,
                                           OUTPUT aux_nrliquid, 
                                           OUTPUT aux_dsliquid, 
                                           OUTPUT aux_nrpatlvr, 
                                           OUTPUT aux_dspatlvr,
                                           OUTPUT aux_nrperger, 
                                           OUTPUT aux_dsperger,
                                           OUTPUT aux_insitrat,
                                           OUTPUT aux_dssitcrt,
                                           OUTPUT ret_tpcritic,
                                           OUTPUT ret_dscritic,
                                           OUTPUT TABLE tt-erro).
   
    IF  RETURN-VALUE <> "OK" THEN DO:

        IF  ret_tpcritic = 1 THEN DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(ret_dscritic)).
            RUN piXmlAtributo (INPUT "cdcritic",INPUT STRING(ret_tpcritic)).
            RUN piXmlSave.
        END.
        ELSE
        IF  ret_tpcritic = 2 THEN DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Rating").
            RUN piXmlAtributo (INPUT "cdcritic",INPUT STRING(ret_tpcritic)).
            RUN piXmlSave.
        END.

    END.
    ELSE DO:
        
        RUN piXmlNew.

        RUN piXmlAtributo (INPUT "vlctrbnd",INPUT STRING(aux_vlctrbnd)).
        RUN piXmlAtributo (INPUT "qtparbnd",INPUT STRING(aux_qtparbnd)).
        RUN piXmlAtributo (INPUT "nrinfcad",INPUT STRING(aux_nrinfcad)).
        RUN piXmlAtributo (INPUT "dsinfcad",INPUT STRING(aux_dsinfcad)).
        RUN piXmlAtributo (INPUT "nrgarope",INPUT STRING(aux_nrgarope)).
        RUN piXmlAtributo (INPUT "dsgarope",INPUT STRING(aux_dsgarope)).
        RUN piXmlAtributo (INPUT "nrliquid",INPUT STRING(aux_nrliquid)).
        RUN piXmlAtributo (INPUT "dsliquid",INPUT STRING(aux_dsliquid)).
        RUN piXmlAtributo (INPUT "nrpatlvr",INPUT STRING(aux_nrpatlvr)).
        RUN piXmlAtributo (INPUT "dspatlvr",INPUT STRING(aux_dspatlvr)).
        RUN piXmlAtributo (INPUT "nrperger",INPUT STRING(aux_nrperger)).
        RUN piXmlAtributo (INPUT "dsperger",INPUT STRING(aux_dsperger)).
        RUN piXmlAtributo (INPUT "insitrat",INPUT STRING(aux_insitrat)).
        RUN piXmlAtributo (INPUT "dssitcrt",INPUT STRING(aux_dssitcrt)).
        RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(ret_dscritic)).
        RUN piXmlAtributo (INPUT "cdcritic",INPUT STRING(ret_tpcritic)).
        
        RUN piXmlSave.
        
    END.

END PROCEDURE.


PROCEDURE efetivacao-rating:

    RUN efetivacao-rating IN hBO
                         (INPUT aux_cdcooper,
                          INPUT aux_cdoperad,
                          INPUT aux_nmdatela,
                          INPUT aux_inproces,
                          INPUT aux_nrdconta,
                          INPUT aux_nrctrato,
                          INPUT aux_dtmvtolt,
                          INPUT aux_dtmvtopr,
                          OUTPUT ret_tpcritic,
                          OUTPUT ret_dscritic,
                          OUTPUT ret_dsdrisco,
                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:

        IF  ret_tpcritic = 1 THEN DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(ret_dscritic)).
            RUN piXmlAtributo (INPUT "cdcritic",INPUT STRING(ret_tpcritic)).
            RUN piXmlSave.
        END.
        ELSE
        IF  ret_tpcritic = 2 THEN DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Rating").
            RUN piXmlAtributo (INPUT "cdcritic",INPUT STRING(ret_tpcritic)).
            RUN piXmlSave.
        END.

    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(ret_dscritic)).
        RUN piXmlAtributo (INPUT "cdcritic",INPUT STRING(ret_tpcritic)).
        RUN piXmlAtributo (INPUT "dsdrisco",INPUT STRING(ret_dsdrisco)).
        RUN piXmlSave.
    END.
    
END PROCEDURE.


PROCEDURE impressao-rating:

    RUN impressao-rating IN hBO
                        (INPUT aux_cdcooper,
                         INPUT aux_nrdconta,
                         INPUT aux_cdagenci,
                         INPUT aux_dtiniper,
                         INPUT aux_dtfimper,
                         INPUT aux_tprelato,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-ctrbndes,
                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE DO:

        IF  aux_tprelato = "S" THEN DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
        ELSE DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-ctrbndes:HANDLE,
                             INPUT "Contrato").
            RUN piXmlSave.
        END.

    END.

END PROCEDURE.


PROCEDURE validacao-campos-ratbnd:

    RUN validacao-campos-ratbnd IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrgarope,
                                        INPUT aux_nrinfcad,
                                        INPUT aux_nrliquid,
                                        INPUT aux_nrpatlvr,
                                        INPUT aux_nrperger,
                                        INPUT aux_nmdatela, 
                                       OUTPUT TABLE tt-erro).
   
    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.     
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.
    
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    
    END.
        
END PROCEDURE.


PROCEDURE validacao-rating-bndes:

    RUN validacao-rating-bndes IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_inproces,
                                       INPUT aux_nrdconta,
                                       INPUT aux_inpessoa,
                                       INPUT aux_nrcpfcgc,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_inconfir,
                                       INPUT aux_vlempbnd,
                                       INPUT aux_qtparbnd,
                                       INPUT aux_nrinfcad,
                                       INPUT aux_nrgarope,
                                       INPUT aux_nrliquid,
                                       INPUT aux_nrpatlvr,
                                       INPUT aux_nrperger,
                                       OUTPUT aux_nrctrato,
                                       OUTPUT aux_dsdrisco,
                                       OUTPUT aux_retorno,
                                       OUTPUT aux_tpcritic,
                                       OUTPUT aux_dscritic,
                                       OUTPUT aux_flgvalid,
                                       OUTPUT aux_flgsuces,
                                       OUTPUT TABLE tt-msg-confirma,
                                       OUTPUT TABLE tt-grupo,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:

        IF  aux_tpcritic = 1 THEN DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                             INPUT "Grupo").
            RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(aux_dscritic)).
            RUN piXmlAtributo (INPUT "tpcritic",INPUT STRING(aux_tpcritic)).
            RUN piXmlAtributo (INPUT "retorno",INPUT STRING(aux_retorno)).
            RUN piXmlSave.
        END.
        ELSE
        IF  aux_tpcritic = 2 THEN DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Rating").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                             INPUT "Grupo").
            RUN piXmlAtributo (INPUT "tpcritic",INPUT STRING(aux_tpcritic)).
            RUN piXmlAtributo (INPUT "retorno",INPUT STRING(aux_retorno)).
            RUN piXmlSave.
        END.

    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                               INPUT "Mensagem").
        RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                         INPUT "Grupo").
        RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(aux_dscritic)).
        RUN piXmlAtributo (INPUT "tpcritic",INPUT STRING(aux_tpcritic)).
        RUN piXmlAtributo (INPUT "retorno",INPUT STRING(aux_retorno)).
        RUN piXmlAtributo (INPUT "nrctrato",INPUT STRING(aux_nrctrato)).
        RUN piXmlSave.
    END.


END PROCEDURE.


PROCEDURE incluir-rating-bndes:

    RUN incluir-rating-bndes IN hBO
                            (INPUT aux_cdcooper,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_inproces,
                             INPUT 5, /* aux_idorigem */
                             INPUT aux_nrdconta,
                             INPUT aux_inpessoa,
                             INPUT aux_nrcpfcgc,
                             INPUT aux_dtmvtolt,
                             INPUT aux_inconfir,
                             INPUT 30, /* aux_inconfi2 */
                             INPUT aux_vlempbnd,
                             INPUT aux_qtparbnd,
                             INPUT aux_nrinfcad,
                             INPUT aux_nrgarope,
                             INPUT aux_nrliquid,
                             INPUT aux_nrpatlvr,
                             INPUT aux_nrperger,
                             INPUT aux_nrctrato,
                             OUTPUT aux_nrctrato,
                             OUTPUT aux_dsdrisco,
                             OUTPUT TABLE tt-erro,          
                             OUTPUT TABLE tt-msg-confirma,
                             OUTPUT TABLE tt-ge-epr).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE DO:

        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nrctrato",INPUT STRING(aux_nrctrato)).
        RUN piXmlAtributo (INPUT "dsdrisco",INPUT STRING(aux_dsdrisco)).
        RUN piXmlSave.
        
    END.

END PROCEDURE.


PROCEDURE alterar-rating-bndes:

    RUN alterar-rating-bndes IN hBO
                            (INPUT aux_cdcooper,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_inproces,
                             INPUT 5, /* aux_idorigem */
                             INPUT aux_nrdconta,
                             INPUT aux_inpessoa,
                             INPUT aux_nrcpfcgc,
                             INPUT aux_dtmvtolt,
                             INPUT aux_inconfir,
                             INPUT 30, /* aux_inconfi2 */
                             INPUT aux_vlempbnd,
                             INPUT aux_qtparbnd,
                             INPUT aux_nrinfcad,
                             INPUT aux_nrgarope,
                             INPUT aux_nrliquid,
                             INPUT aux_nrpatlvr,
                             INPUT aux_nrperger,
                             INPUT aux_nrctrato,
                             OUTPUT aux_dsdrisco,
                             OUTPUT TABLE tt-erro,          
                             OUTPUT TABLE tt-msg-confirma,
                             OUTPUT TABLE tt-ge-epr).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE DO:

        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "dsdrisco",INPUT STRING(aux_dsdrisco)).
        RUN piXmlSave.
        
    END.

END PROCEDURE.


PROCEDURE imprimir-ratbnd-efetivos:

    RUN imprimir-ratbnd-efetivos IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdoperad,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_dtmvtopr,
                                           INPUT aux_inproces,
                                           INPUT aux_nmdatela,
                                           INPUT aux_nrdconta,
                                           INPUT aux_tpctrato,
                                           INPUT aux_nrctrato,
                                           INPUT FALSE,
                                           INPUT 5,
                                           OUTPUT aux_nmarqimp,
                                           OUTPUT aux_nmarqpdf,
                                           OUTPUT TABLE tt-erro).

      IF  RETURN-VALUE <> "OK" THEN DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE tt-erro THEN DO:
              CREATE tt-erro.
              ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
          END.

          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

      END.
      ELSE DO:

          IF  aux_tprelato = "S" THEN DO:
              RUN piXmlNew.
              RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
              RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
              RUN piXmlSave.
          END.
          ELSE DO:
              RUN piXmlNew.
              RUN piXmlExport (INPUT TEMP-TABLE tt-ctrbndes:HANDLE,
                               INPUT "Contrato").
              RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
              RUN piXmlSave.
          END.

      END.

END PROCEDURE.
/******************************************************************************/
