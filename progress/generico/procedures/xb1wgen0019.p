/*..............................................................................

   Programa: xb1wgen0019.p
   Autor   : Murilo/David
   Data    : Maio/2007                         Ultima atualizacao: 22/12/2015 

   Dados referentes ao programa:

   Objetivo  : BO de comunicacao XML VS BO de Limite de Credito (b1wgen0019.p)

   Alteracoes: 15/04/2010 - Adaptar para novo Rating (David).
   
               16/09/2010 - Incluir procedure para gerar impressoes do 
                            limite de credito (David).
                            
               28/10/2010 - Alterações para tratamento de Taxas Diferenciadas
                            campo cddlinha. (Éder - GATI).
                            
               11/04/2011 - Inclusao do parametro tt-impressao-risco-tl em
                            confirmar-novo-limite. (Fabricio)
                            
               19/04/2011 - Inclusão de parametros para CEP integrado no
                            procedimento valida-dados-avalistas e 
                            cadastrar-novo-limite. (André - DB1)
                                                 
               12/11/2012 - Incluir tt-ge-limite como parametro na procedure
                            validar-novo-limite (Lucas R.).
                            
               02/07/2014 - Permitir alterar a observacao da proposta
                            (Chamado 169007) (Jonata - RKAM).
                            
               04/08/2014 - Inclusao do uso da temp-table tt-grupo na b1wgen0138tt.
                            (Chamado 130880) - (Tiago Castro - RKAM)             
                            
               30/12/2014 - Incluir a procedure "renovar_limite_credito_manual"
                            (James)
							
			   19/01/2015 - Incluido novas procedures devido a alteracao de 
                            proposta de limite de credito SD237152
                            (Tiago/Gielow).							
                            
               29/04/2015 - Consultas automatizadas (Gabriel-RKAM).   
               
               22/12/2015 - Criada procedure para edição de número do contrato de limite 
                            (Lucas Lunelli - SD 360072 [M175])
                            
               05/12/2017 - Adicionado campo aux_idcobope nas procedures cadastrar-novo-limite e 
                            alterar-novo-limite. Projeto 404 (Lombardi)
                            
			   09/07/2019 - Adicionado outras rendas do conjuge.
			                Rubens Lima - Mouts
                            
..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrlim AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrant AS INTE                                           NO-UNDO.
DEF VAR aux_cddlinha AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO. 
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaav1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepav1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaav2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepav2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaava AS INTE                                           NO-UNDO.
DEF VAR aux_idimpres AS INTE                                           NO-UNDO.
DEF VAR aux_nrgarope AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_nrliquid AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_nrperger AS INTE                                           NO-UNDO.
    
DEF VAR aux_vllimite AS DECI                                           NO-UNDO.
DEF VAR aux_vlalugue AS DECI                                           NO-UNDO.
DEF VAR aux_vloutras AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalcon AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfav1 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav1 AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfav2 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav2 AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_vltotsfn AS DECI                                           NO-UNDO.
DEF VAR aux_perfatcl AS DECI                                           NO-UNDO.

DEF VAR aux_flgimpnp AS LOGI                                           NO-UNDO.
DEF VAR aux_flgemail AS LOGI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_dsobserv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdaval1 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcjav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_tdccjav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_doccjav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende1av1 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende2av1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_emailav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufava1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrender1 AS INTE                                           NO-UNDO.
DEF VAR aux_complen1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps1 AS INTE                                           NO-UNDO.
DEF VAR aux_vlrenme1 AS DECI                                           NO-UNDO.
DEF VAR aux_nmdaval2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tdccjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_doccjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende1av2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende2av2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_emailav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufava2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrender2 AS INTE                                           NO-UNDO.
DEF VAR aux_complen2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps2 AS INTE                                           NO-UNDO.
DEF VAR aux_vlrenme2 AS DECI                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_inconfi2 AS INTE                                           NO-UNDO.
DEF VAR aux_flpropos AS LOGI                                           NO-UNDO.
DEF VAR aux_inconcje AS INTE                                           NO-UNDO.
DEF VAR aux_dtconbir AS DATE                                           NO-UNDO.
DEF VAR aux_idcobope AS INTE                                           NO-UNDO.
DEF VAR aux_flmudfai AS CHAR                                           NO-UNDO.
/* PRJ 438 Sprint 7 */
DEF VAR aux_vlrecjg1 AS DECI                                           NO-UNDO.
DEF VAR aux_vlrecjg2 AS DECI                                           NO-UNDO.
DEF VAR aux_cdnacio1 AS INTE                                           NO-UNDO.
DEF VAR aux_cdnacio2 AS INTE                                           NO-UNDO.
DEF VAR aux_inpesso1 AS INTE                                           NO-UNDO.
DEF VAR aux_inpesso2 AS INTE                                           NO-UNDO.
DEF VAR aux_dtnasct1 AS DATE                                           NO-UNDO.
DEF VAR aux_dtnasct2 AS DATE                                           NO-UNDO.

DEF VAR aux_rowidsin AS ROWID                                          NO-UNDO.
/* PRJ 438 - Sprint 13*/
DEF VAR aux_vlrencjg AS DECI                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
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
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).
            WHEN "nrctrlim" THEN aux_nrctrlim = INTE(tt-param.valorCampo).
            WHEN "nrctrant" THEN aux_nrctrant = INTE(tt-param.valorCampo).
            WHEN "cddlinha" THEN aux_cddlinha = INTE(tt-param.valorCampo).
            WHEN "vllimite" THEN aux_vllimite = DECI(tt-param.valorCampo).
            WHEN "flgimpnp" THEN aux_flgimpnp = LOGICAL(tt-param.valorCampo).
            WHEN "vlalugue" THEN aux_vlalugue = DECI(tt-param.valorCampo).
            WHEN "vloutras" THEN aux_vloutras = DECI(tt-param.valorCampo).
            WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
            WHEN "vlsalcon" THEN aux_vlsalcon = DECI(tt-param.valorCampo).
            WHEN "vlrencjg" THEN aux_vlrencjg = DECI(tt-param.valorCampo).
            WHEN "dsobserv" THEN aux_dsobserv = tt-param.valorCampo.
            WHEN "nrctaav1" THEN aux_nrctaav1 = INTE(tt-param.valorCampo).
            WHEN "nrcepav1" THEN aux_nrcepav1 = INTE(tt-param.valorCampo).
            WHEN "vlrenme1" THEN aux_vlrenme1 = DECI(tt-param.valorCampo).
            WHEN "nrctaav2" THEN aux_nrctaav2 = INTE(tt-param.valorCampo).
            WHEN "nrcepav2" THEN aux_nrcepav2 = INTE(tt-param.valorCampo).
            WHEN "nrcpfav1" THEN aux_nrcpfav1 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav1" THEN aux_cpfcjav1 = DECI(tt-param.valorCampo).
            WHEN "nrcpfav2" THEN aux_nrcpfav2 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav2" THEN aux_cpfcjav2 = DECI(tt-param.valorCampo).
            WHEN "nmdaval1" THEN aux_nmdaval1 = tt-param.valorCampo.
            WHEN "tpdocav1" THEN aux_tpdocav1 = tt-param.valorCampo.
            WHEN "dsdocav1" THEN aux_dsdocav1 = tt-param.valorCampo.
            WHEN "nmdcjav1" THEN aux_nmdcjav1 = tt-param.valorCampo.
            WHEN "tdccjav1" THEN aux_tdccjav1 = tt-param.valorCampo.
            WHEN "doccjav1" THEN aux_doccjav1 = tt-param.valorCampo.
            WHEN "ende1av1" THEN aux_ende1av1 = tt-param.valorCampo.
            WHEN "ende2av1" THEN aux_ende2av1 = tt-param.valorCampo.
            WHEN "nrfonav1" THEN aux_nrfonav1 = tt-param.valorCampo.
            WHEN "emailav1" THEN aux_emailav1 = tt-param.valorCampo.
            WHEN "nmcidav1" THEN aux_nmcidav1 = tt-param.valorCampo.
            WHEN "cdufava1" THEN aux_cdufava1 = tt-param.valorCampo.
            WHEN "nmdaval2" THEN aux_nmdaval2 = tt-param.valorCampo.
            WHEN "tpdocav2" THEN aux_tpdocav2 = tt-param.valorCampo.
            WHEN "dsdocav2" THEN aux_dsdocav2 = tt-param.valorCampo.
            WHEN "nmdcjav2" THEN aux_nmdcjav2 = tt-param.valorCampo.
            WHEN "tdccjav2" THEN aux_tdccjav2 = tt-param.valorCampo.
            WHEN "doccjav2" THEN aux_doccjav2 = tt-param.valorCampo.
            WHEN "ende1av2" THEN aux_ende1av2 = tt-param.valorCampo.
            WHEN "ende2av2" THEN aux_ende2av2 = tt-param.valorCampo.
            WHEN "nrfonav2" THEN aux_nrfonav2 = tt-param.valorCampo.
            WHEN "emailav2" THEN aux_emailav2 = tt-param.valorCampo.
            WHEN "nmcidav2" THEN aux_nmcidav2 = tt-param.valorCampo.
            WHEN "cdufava2" THEN aux_cdufava2 = tt-param.valorCampo.
            WHEN "vlrenme2" THEN aux_vlrenme2 = DECI(tt-param.valorCampo).
            WHEN "idimpres" THEN aux_idimpres = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrctaava" THEN aux_nrctaava = INTE(tt-param.valorCampo).
            WHEN "nrgarope" THEN aux_nrgarope = INTE(tt-param.valorCampo).
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo).
            WHEN "nrliquid" THEN aux_nrliquid = INTE(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "nrperger" THEN aux_nrperger = INTE(tt-param.valorCampo).
            WHEN "vltotsfn" THEN aux_vltotsfn = DECI(tt-param.valorCampo). 
            WHEN "perfatcl" THEN aux_perfatcl = DECI(tt-param.valorCampo). 
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "flgemail" THEN aux_flgemail = LOGICAL(tt-param.valorCampo).
            WHEN "nrender1" THEN aux_nrender1 = INTE(tt-param.valorCampo).
            WHEN "complen1" THEN aux_complen1 = tt-param.valorCampo.
            WHEN "nrcxaps1" THEN aux_nrcxaps1 = INTE(tt-param.valorCampo).
            WHEN "nrender2" THEN aux_nrender2 = INTE(tt-param.valorCampo).
            WHEN "complen2" THEN aux_complen2 = tt-param.valorCampo.
            WHEN "nrcxaps2" THEN aux_nrcxaps2 = INTE(tt-param.valorCampo).
            WHEN "inconfi2" THEN aux_inconfi2 = INTE(tt-param.valorCampo).
            WHEN "flpropos" THEN aux_flpropos = LOGICAL(tt-param.valorCampo). 
            WHEN "inconcje" THEN aux_inconcje = INTE(tt-param.valorCampo).
            WHEN "dtconbir" THEN aux_dtconbir = DATE(tt-param.valorCampo).
            WHEN "idcobope" THEN aux_idcobope = INTE(tt-param.valorCampo).
            /* PRJ 438 Sprint 7*/
            WHEN "vlrecjg1" THEN aux_vlrecjg1 = DECI(tt-param.valorCampo).
            WHEN "vlrecjg2" THEN aux_vlrecjg2 = DECI(tt-param.valorCampo).            
            WHEN "cdnacio1" THEN aux_cdnacio1 = INTE(tt-param.valorCampo).
            WHEN "cdnacio2" THEN aux_cdnacio2 = INTE(tt-param.valorCampo).
            WHEN "inpesso1" THEN aux_inpesso1 = INTE(tt-param.valorCampo).
            WHEN "inpesso2" THEN aux_inpesso2 = INTE(tt-param.valorCampo).
            WHEN "dtnasct1" THEN aux_dtnasct1 = DATE(tt-param.valorCampo).
            WHEN "dtnasct2" THEN aux_dtnasct2 = DATE(tt-param.valorCampo).

        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Classificacao_Risco" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-singulares.
                       ASSIGN aux_rowidsin = ROWID(tt-singulares).
                    END.

                FIND tt-singulares WHERE ROWID(tt-singulares) = aux_rowidsin
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nrtopico" THEN
                        tt-singulares.nrtopico = INTE(tt-param-i.valorCampo).
                    WHEN "nritetop" THEN
                        tt-singulares.nritetop = INTE(tt-param-i.valorCampo).
                    WHEN "nrseqite" THEN
                        tt-singulares.nrseqite = INTE(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.
    
END PROCEDURE.


/******************************************************************************/
/**              Procedure para obter valor do limite de credito             **/
/******************************************************************************/
PROCEDURE obtem-valor-limite: 

    RUN obtem-valor-limite IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT TRUE, /** LOG **/
                                  OUTPUT TABLE tt-limite-credito,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-limite-credito:HANDLE,
                        INPUT "Dados").
     
END PROCEDURE.
 
 
/******************************************************************************/
/**              Procedure para obter dados do limite de credito             **/
/******************************************************************************/
PROCEDURE obtem-cabecalho-limite: 

    RUN obtem-cabecalho-limite IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT TRUE, /** LOG **/
                                      OUTPUT TABLE tt-cabec-limcredito,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-cabec-limcredito:HANDLE,
                        INPUT "Dados").
                                            
END PROCEDURE.


/******************************************************************************/
/**       Procedure para listar ultimas alteracos de limite de credito       **/
/******************************************************************************/
PROCEDURE obtem-ultimas-alteracoes:

    RUN obtem-ultimas-alteracoes IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrctrlim,
                                         INPUT TRUE, /** LOG **/
                                        OUTPUT TABLE tt-ultimas-alteracoes,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-ultimas-alteracoes:HANDLE,
                        INPUT "Dados").
 
END PROCEDURE.


/******************************************************************************/
/**               Procedure para ativar novo limite de credito               **/
/******************************************************************************/
PROCEDURE confirmar-novo-limite: 

    RUN confirmar-novo-limite IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_inproces,
                                      INPUT aux_inconfir,
                                      INPUT TRUE, /** LOG **/
                                      INPUT TABLE tt-singulares,
                                     OUTPUT TABLE tt-msg-confirma,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-cabrel,
                                     OUTPUT TABLE tt-impressao-coop,
                                     OUTPUT TABLE tt-impressao-rating,
                                     OUTPUT TABLE tt-impressao-risco,
                                     OUTPUT TABLE tt-impressao-risco-tl,
                                     OUTPUT TABLE tt-impressao-assina,
                                     OUTPUT TABLE tt-efetivacao,
                                     OUTPUT TABLE tt-ratings).        

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
            FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-msg-confirma  THEN
                RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                INPUT "Confirmacao").
            ELSE
                DO:
                    RUN piXmlNew.
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-cabrel:HANDLE,
                        INPUT "Relatorio").
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-impressao-coop:HANDLE,
                        INPUT "Cooperado").
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-impressao-rating:HANDLE,
                        INPUT "Rating").
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-impressao-risco:HANDLE,
                        INPUT "Risco").
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-impressao-assina:HANDLE,
                        INPUT "Assinatura").
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-efetivacao:HANDLE,
                        INPUT "Efetivacao").
                    RUN piXmlExport 
                       (INPUT TEMP-TABLE tt-ratings:HANDLE,
                        INPUT "Rating_Cooperado").
                    RUN piXmlSave.
                END.
        END.
              
END PROCEDURE.



/******************************************************************************/
/**            Procedure para obter proposta de limite de credito            **/
/******************************************************************************/
PROCEDURE obtem-limite:

    RUN obtem-limite IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT aux_flpropos,
                             INPUT aux_dtmvtolt,
                             INPUT aux_inconfir,
                             INPUT TRUE, /** LOG **/
                            OUTPUT TABLE tt-proposta-limcredito,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-msg-confirma).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-proposta-limcredito:HANDLE,
                            INPUT "Dados").
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                            INPUT "Mensagens").
            RUN piXmlSave.
        END.
         
END PROCEDURE.         


/******************************************************************************/
/**           Procedure para excluir proposta de limite de credito           **/
/******************************************************************************/
PROCEDURE excluir-novo-limite:

    RUN excluir-novo-limite IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_dtmvtolt,
                                    INPUT TRUE, /** LOG **/
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


/******************************************************************************/
/**              Procedure para excluir limite de credito atual              **/
/******************************************************************************/
PROCEDURE cancelar-limite-atual:

    RUN cancelar-limite-atual IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_dtmvtolt,
                                      INPUT TRUE, /** LOG **/
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


/******************************************************************************/
/**           Procedure para validar proposta de limite de credito           **/
/******************************************************************************/
PROCEDURE validar-novo-limite:
    

    RUN validar-novo-limite IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_dtmvtopr,
                                    INPUT aux_inproces,
                                    INPUT aux_inconfir,
                                    INPUT aux_vllimite,
                                    INPUT aux_nrctrlim,
                                    INPUT aux_flgimpnp,
                                    INPUT aux_cddlinha,
                                    INPUT TRUE, /** LOG **/
                                    INPUT aux_inconfi2,
                                   OUTPUT TABLE tt-msg-confirma,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-grupo).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                  INPUT "Confirmacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                                   INPUT "GrupoEconomico").
            RUN piXmlSave.

        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                  INPUT "Confirmacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                                   INPUT "GrupoEconomico").
            RUN piXmlSave.

        END.                    
        
END PROCEDURE.


/******************************************************************************/
/**        Procedure para carregar dados do avalista para novo limite        **/
/******************************************************************************/
PROCEDURE obtem-dados-avalista:

    RUN obtem-dados-avalista IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrctaava,
                                     INPUT aux_nrcpfcgc,
                                     INPUT TRUE, /** LOG **/
                                    OUTPUT TABLE tt-dados-avais,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                        INPUT "Avalista").
       
END PROCEDURE.


/******************************************************************************/
/**       Procedure para validar dados dos avalistas para novo limite        **/
/******************************************************************************/
PROCEDURE valida-dados-avalistas:

    RUN valida-dados-avalistas IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT TRUE, /** LOG **/
                                       /** 1o avalista **/
                                       INPUT aux_nrctaav1,
                                       INPUT aux_nmdaval1,
                                       INPUT aux_nrcpfav1,
                                       INPUT aux_cpfcjav1,
                                       INPUT aux_ende1av1,
                                       INPUT aux_nrcepav1,
                                       /** 2 avalista **/
                                       INPUT aux_nrctaav2,
                                       INPUT aux_nmdaval2,
                                       INPUT aux_nrcpfav2,
                                       INPUT aux_cpfcjav2,
                                       INPUT aux_ende1av2, 
                                       INPUT aux_nrcepav2,
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


/******************************************************************************/
/**          Procedure para cadastrar proposta de limite de credito          **/
/******************************************************************************/
PROCEDURE cadastrar-novo-limite:
     
    RUN cadastrar-novo-limite IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT TRUE, /** LOG **/
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_inproces,
                                      INPUT aux_inconfir,
                                      INPUT aux_vllimite,
                                      INPUT aux_nrctrlim,
                                      INPUT aux_flgimpnp,
                                      INPUT aux_cddlinha,
                                      INPUT aux_vlsalari,
                                      INPUT aux_vlsalcon,
                                      INPUT aux_vloutras,
                                      /** RATING **/
                                      INPUT aux_nrgarope,
                                      INPUT aux_nrinfcad,
                                      INPUT aux_nrliquid,
                                      INPUT aux_nrpatlvr,
                                      INPUT aux_nrperger,
                                      INPUT aux_vltotsfn,
                                      INPUT aux_perfatcl,
                                      /** RATING **/
                                      INPUT aux_vlalugue,
                                      INPUT aux_dsobserv,
                                      /** 1o avalista **/
                                      INPUT aux_nrctaav1,
                                      INPUT aux_nmdaval1,
                                      INPUT aux_nrcpfav1,
                                      INPUT aux_tpdocav1,
                                      INPUT aux_dsdocav1,
                                      INPUT aux_nmdcjav1,
                                      INPUT aux_cpfcjav1, 
                                      INPUT aux_tdccjav1,
                                      INPUT aux_doccjav1,
                                      INPUT aux_ende1av1,
                                      INPUT aux_ende2av1,
                                      INPUT aux_nrfonav1,
                                      INPUT aux_emailav1,
                                      INPUT aux_nmcidav1,
                                      INPUT aux_cdufava1,
                                      INPUT aux_nrcepav1,
                                      INPUT aux_nrender1,
                                      INPUT aux_complen1,
                                      INPUT aux_nrcxaps1,
                                      INPUT aux_vlrenme1,
                                      INPUT aux_vlrecjg1,
                                      INPUT aux_cdnacio1,
                                      INPUT aux_inpesso1,
                                      INPUT aux_dtnasct1,
                                      /** 2o avalista **/
                                      INPUT aux_nrctaav2,
                                      INPUT aux_nmdaval2, 
                                      INPUT aux_nrcpfav2,
                                      INPUT aux_tpdocav2,
                                      INPUT aux_dsdocav2, 
                                      INPUT aux_nmdcjav2, 
                                      INPUT aux_cpfcjav2,
                                      INPUT aux_tdccjav2,
                                      INPUT aux_doccjav2,
                                      INPUT aux_ende1av2,
                                      INPUT aux_ende2av2,
                                      INPUT aux_nrfonav2,
                                      INPUT aux_emailav2, 
                                      INPUT aux_nmcidav2, 
                                      INPUT aux_cdufava2,
                                      INPUT aux_nrcepav2,
                                      INPUT aux_nrender2,
                                      INPUT aux_complen2,
                                      INPUT aux_nrcxaps2,
                                      INPUT aux_vlrenme2,
                                      INPUT aux_vlrecjg2,
                                      INPUT aux_cdnacio2,
                                      INPUT aux_inpesso2,
                                      INPUT aux_dtnasct2,
                                      INPUT aux_inconcje,
                                      INPUT aux_dtconbir,
                                      INPUT aux_idcobope,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-msg-confirma).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagens").
            RUN piXmlSave.
        END.
        
END PROCEDURE.
        

/******************************************************************************/
/**     Procedure para carregar dados dos avalistas do limite de credito     **/
/******************************************************************************/
PROCEDURE obtem-dados-avais:

    RUN obtem-dados-avais IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_flpropos,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT TRUE, /** LOG **/
                                 OUTPUT TABLE tt-dados-avais,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                        INPUT "Dados").
         
END PROCEDURE.


/******************************************************************************/
/**     Procedure para carregar dados para impressos do limite de credito    **/
/******************************************************************************/
PROCEDURE impressoes-limite:

    RUN impressoes-limite IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_inproces,
                                  INPUT aux_idimpres,
                                  INPUT aux_nrctrlim,
                                  INPUT TRUE, /** LOG **/
                                 OUTPUT TABLE tt-dados-prp,
                                 OUTPUT TABLE tt-dados-ctr,
                                 OUTPUT TABLE tt-repres-ctr,
                                 OUTPUT TABLE tt-avais-ctr,
                                 OUTPUT TABLE tt-dados-rescisao,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-prp:HANDLE,
                             INPUT "Proposta").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-ctr:HANDLE,
                             INPUT "Contrato").
            RUN piXmlExport (INPUT TEMP-TABLE tt-repres-ctr:HANDLE,
                             INPUT "Representantes").        
            RUN piXmlExport (INPUT TEMP-TABLE tt-avais-ctr:HANDLE,
                             INPUT "Avalistas").          
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-rescisao:HANDLE,
                             INPUT "Rescisao").
            RUN piXmlSave.
        END.                    
  
END PROCEDURE.


/******************************************************************************/
/**           Procedure para gerar impressoes do limite de credito           **/
/******************************************************************************/
PROCEDURE gera-impressao-limite:
    
    RUN gera-impressao-limite IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_inproces,
                                      INPUT aux_idimpres,
                                      INPUT aux_nrctrlim,
                                      INPUT aux_flgimpnp,
                                      INPUT aux_dsiduser,
                                      INPUT aux_flgemail,
                                      INPUT TRUE,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT aux_nmarqpdf,
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
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**           Procedure para alterar a observacao da proposta                **/
/******************************************************************************/
PROCEDURE altera-observacao:
    
    RUN altera-observacao IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrctrlim,
                                  INPUT aux_dsobserv,
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

PROCEDURE renovar_limite_credito_manual:
    
    RUN renovar_limite_credito_manual IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nmdatela,
                                              INPUT aux_idorigem,
                                              INPUT aux_nrdconta,
                                              INPUT aux_idseqttl,
                                              INPUT YES,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_nrctrlim,
                                             OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK"  THEN
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

/******************************TIAGO*******************************************/
/******************************************************************************/
/**           Procedure para validar proposta de limite de credito           **/
/******************************************************************************/
PROCEDURE validar-alteracao-limite:
    

    RUN validar-alteracao-limite IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_dtmvtopr,
                                         INPUT aux_inproces,
                                         INPUT aux_inconfir,
                                         INPUT aux_vllimite,
                                         INPUT aux_nrctrlim,
                                         INPUT aux_flgimpnp,
                                         INPUT aux_cddlinha,
                                         INPUT TRUE, /** LOG **/
                                         INPUT aux_inconfi2,
                                        OUTPUT TABLE tt-msg-confirma,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-grupo).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                  INPUT "Confirmacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                                   INPUT "GrupoEconomico").
            RUN piXmlSave.

        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                  INPUT "Confirmacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                                   INPUT "GrupoEconomico").
            RUN piXmlSave.

        END.                    
        
END PROCEDURE.

PROCEDURE obtem-dados-proposta:

    RUN obtem-dados-proposta IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_dtmvtopr,
                                     INPUT aux_inproces,
                                     INPUT aux_nrctrlim,
                                    OUTPUT TABLE tt-dados-prp,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-prp:HANDLE,
                             INPUT "Proposta").
            RUN piXmlSave.
        END.                    

END PROCEDURE.


PROCEDURE busca-dados-avalistas:

    RUN busca-dados-avalistas IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_nrdconta,
                                      INPUT aux_nrctrlim,
                                     OUTPUT TABLE tt-dados-avais,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avalista").
            RUN piXmlSave.
        END.                    

END PROCEDURE.

PROCEDURE alterar-novo-limite:
     
    RUN alterar-novo-limite IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT TRUE, /** LOG **/
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_dtmvtopr,
                                    INPUT aux_inproces,
                                    INPUT aux_inconfir,
                                    INPUT aux_vllimite,
                                    INPUT aux_nrctrlim,
                                    INPUT aux_flgimpnp,
                                    INPUT aux_cddlinha,
                                    INPUT aux_vlsalari,
                                    INPUT aux_vlsalcon,
                                    INPUT aux_vloutras,
                                    /** RATING **/
                                    INPUT aux_nrgarope,
                                    INPUT aux_nrinfcad,
                                    INPUT aux_nrliquid,
                                    INPUT aux_nrpatlvr,
                                    INPUT aux_nrperger,
                                    INPUT aux_vltotsfn,
                                    INPUT aux_perfatcl,
                                    /** RATING **/
                                    INPUT aux_vlalugue,
                                    INPUT aux_dsobserv,
                                    /** 1o avalista **/
                                    INPUT aux_nrctaav1,
                                    INPUT aux_nmdaval1,
                                    INPUT aux_nrcpfav1,
                                    INPUT aux_tpdocav1,
                                    INPUT aux_dsdocav1,
                                    INPUT aux_nmdcjav1,
                                    INPUT aux_cpfcjav1, 
                                    INPUT aux_tdccjav1,
                                    INPUT aux_doccjav1,
                                    INPUT aux_ende1av1,
                                    INPUT aux_ende2av1,
                                    INPUT aux_nrfonav1,
                                    INPUT aux_emailav1,
                                    INPUT aux_nmcidav1,
                                    INPUT aux_cdufava1,
                                    INPUT aux_nrcepav1,
                                    INPUT aux_nrender1,
                                    INPUT aux_complen1,
                                    INPUT aux_nrcxaps1,
                                    INPUT aux_vlrenme1,
                                    INPUT aux_vlrecjg1,
                                    INPUT aux_cdnacio1,
                                    INPUT aux_inpesso1,
                                    INPUT aux_dtnasct1,
                                    /** 2o avalista **/
                                    INPUT aux_nrctaav2,
                                    INPUT aux_nmdaval2, 
                                    INPUT aux_nrcpfav2,
                                    INPUT aux_tpdocav2,
                                    INPUT aux_dsdocav2, 
                                    INPUT aux_nmdcjav2, 
                                    INPUT aux_cpfcjav2,
                                    INPUT aux_tdccjav2,
                                    INPUT aux_doccjav2,
                                    INPUT aux_ende1av2,
                                    INPUT aux_ende2av2,
                                    INPUT aux_nrfonav2,
                                    INPUT aux_emailav2, 
                                    INPUT aux_nmcidav2, 
                                    INPUT aux_cdufava2,
                                    INPUT aux_nrcepav2,
                                    INPUT aux_nrender2,
                                    INPUT aux_complen2,
                                    INPUT aux_nrcxaps2,
                                    INPUT aux_vlrenme2,
                                    INPUT aux_vlrecjg2,
                                    INPUT aux_cdnacio2,
                                    INPUT aux_inpesso2,
                                    INPUT aux_dtnasct2,
                                    INPUT aux_inconcje,
                                    INPUT aux_dtconbir,
                                    /** Garantia **/
                                    INPUT aux_idcobope,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-msg-confirma,
                                   OUTPUT aux_flmudfai).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagens").
            RUN piXmlAtributo (INPUT "flmudfai", INPUT aux_flmudfai).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

PROCEDURE altera-numero-proposta-limite:

    RUN altera-numero-proposta-limite IN hBO(INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nmdatela,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_nrctrant,
                                             INPUT aux_nrctrlim,
                                             INPUT YES,
                                             OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK"  THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
     
          IF NOT AVAILABLE tt-erro  THEN
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
/*............................................................................*/







