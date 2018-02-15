/*..............................................................................

   Programa: xb1wgen0016.p
   Autor   : Jorge I. Hamaguchi
   Data    : 15/08/2013                        Ultima atualizacao: 24/05/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO (b1wgen0016.p)

   Alteracoes: 20/10/2014 - Novos campos. Chamado 198702 (Jonata-RKAM).

               06/04/2016 - Adicionado campos de TED. (Jaison/Marcos - SUPERO)

		       25/04/2016 - Incluido a chamada para a rotina cancelar-agendamento
							(Adriano - M117).
              
           24/05/2016 - Ajuste da rotina b1wgen0016.consultar_parmon alterar_parmon
                        com flag de monitoracao de agendamento de TED (Carlos)
..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR										   NO-UNDO.
DEF VAR aux_dscritic AS CHAR										   NO-UNDO.
DEF VAR aux_nrdconta LIKE crapass.nrdconta							   NO-UNDO.
DEF VAR aux_idseqttl AS INT           							       NO-UNDO.
DEF VAR aux_dtmvtage AS DATE										   NO-UNDO.
DEF VAR aux_nrdocmto LIKE craplau.nrdocmto                             NO-UNDO.

DEF VAR aux_vlinimon AS DECI                                           NO-UNDO.
DEF VAR aux_vllmonip AS DECI                                           NO-UNDO.
DEF VAR aux_vlinisaq AS DECI                                           NO-UNDO.
DEF VAR aux_vlinitrf AS DECI                                           NO-UNDO.
DEF VAR aux_vlsaqind AS DECI                                           NO-UNDO.
DEF VAR aux_insaqlim AS INTE                                           NO-UNDO.
DEF VAR aux_inaleblq AS INTE                                           NO-UNDO.
DEF VAR aux_vlmnlmtd AS DECI                                           NO-UNDO.
DEF VAR aux_vlinited AS DECI                                           NO-UNDO.
DEF VAR aux_flmstted AS LOGI                                           NO-UNDO.
DEF VAR aux_flnvfted AS LOGI                                           NO-UNDO.
DEF VAR aux_flmobted AS LOGI                                           NO-UNDO.
DEF VAR aux_dsestted AS CHAR                                           NO-UNDO.
DEF VAR aux_flmntage AS LOGI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcoptel AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfope AS DECI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0016tt.i }
{ sistema/generico/includes/b1wgen0119tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }



    
/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowid AS ROWID       NO-UNDO.

    FOR EACH tt-param:
            
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "vlinimon" THEN aux_vlinimon = DECI(tt-param.valorCampo).
            WHEN "vllmonip" THEN aux_vllmonip = DECI(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdcoptel" THEN aux_cdcoptel = tt-param.valorCampo.
            WHEN "vlinisaq" THEN aux_vlinisaq = DECI(tt-param.valorCampo).
            WHEN "vlinitrf" THEN aux_vlinitrf = DECI(tt-param.valorCampo).
            WHEN "vlsaqind" THEN aux_vlsaqind = DECI(tt-param.valorCampo). 
            WHEN "insaqlim" THEN aux_insaqlim = INTE(tt-param.valorCampo). 
            WHEN "inaleblq" THEN aux_inaleblq = INTE(tt-param.valorCampo). 
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo). 
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo). 			
            WHEN "dtmvtage" THEN aux_dtmvtage = DATE(tt-param.valorCampo). 
            WHEN "nrdocmto" THEN aux_nrdocmto = INTE(tt-param.valorCampo). 
            WHEN "vlmnlmtd" THEN aux_vlmnlmtd = DECI(tt-param.valorCampo).
            WHEN "vlinited" THEN aux_vlinited = DECI(tt-param.valorCampo).
            WHEN "flmstted" THEN aux_flmstted = LOGICAL(tt-param.valorCampo).
            WHEN "flnvfted" THEN aux_flnvfted = LOGICAL(tt-param.valorCampo).
            WHEN "flmobted" THEN aux_flmobted = LOGICAL(tt-param.valorCampo).
            WHEN "dsestted" THEN aux_dsestted = tt-param.valorCampo.
            WHEN "flmntage" THEN aux_flmntage = LOGICAL(tt-param.valorCampo).
            WHEN "nrcpfope" THEN aux_nrcpfope = DECI(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**        Procedure para consultar parametros de monitoracao                **/
/******************************************************************************/
PROCEDURE consultar_parmon:
    
    RUN consultar_parmon IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdcoptel,
                                OUTPUT TABLE tt-parmon,
                                OUTPUT TABLE tt-crapcop,
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
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-parmon:HANDLE,  INPUT "PARMON").
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcop:HANDLE, INPUT "CRAPCOP").
            RUN piXmlSave.
        END.
     
END PROCEDURE.


/******************************************************************************/
/**        Procedure para alterar parametros de monitoracao                  **/
/******************************************************************************/
PROCEDURE alterar_parmon:
    
    RUN alterar_parmon IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_dtmvtolt,
                               INPUT aux_vlinimon,
                               INPUT aux_vllmonip,
                               INPUT aux_vlinisaq,
                               INPUT aux_vlinitrf,
                               INPUT aux_vlsaqind,
                               INPUT aux_insaqlim,
                               INPUT aux_inaleblq,
                               INPUT aux_cdcoptel,
                               INPUT aux_vlmnlmtd,
                               INPUT aux_vlinited,
                               INPUT aux_flmstted,
                               INPUT aux_flnvfted,
                               INPUT aux_flmobted,
                               INPUT aux_dsestted,
                               INPUT aux_flmntage,
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
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
     
END PROCEDURE.


/******************************************************************************
        Procedure para cancelar agenamentos de TED que ainda estao 
        pendentes.
******************************************************************************/
PROCEDURE cancelar_agendamento:
    
    RUN cancelar-agendamento IN hBO (INPUT aux_cdcooper,
                                     INPUT 90,          /** PAC      **/
                                     INPUT 900,         /** CAIXA    **/                                     
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT "INTERNET",  /** ORIGEM   **/
                                     INPUT aux_dtmvtage,
                                     INPUT aux_nrdocmto,
                                     INPUT 0,
                                     INPUT aux_nmdatela,
                                     INPUT aux_nrcpfope,
                                     OUTPUT aux_dstransa,
                                     OUTPUT aux_dscritic).
         message RETURN-VALUE   aux_dscritic.                 
    IF  RETURN-VALUE <> "OK" OR
	    aux_dscritic <> ""    THEN
        DO:
            IF aux_dscritic = "" THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
			ELSE
			  DO:
			     CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = aux_dscritic.
			    
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

/*............................................................................*/

