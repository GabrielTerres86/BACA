/*.............................................................................

   Programa: xb1wgen0030.p
   Autor   : Guilherme
   Data    : Agosto/2008                     Ultima atualizacao: 28/07/2017

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Desconto de Titulos(b1wgen0030.p)

   Alteracoes: 13/07/2009 - Incluir paramentros de LOG (Guilherme).
   
               07/06/2010 - Adaptacao para RATING no Ayllos Web (David).
               
               27/04/2011 - CEP integrado. Inclusao de parametros adicionais
                            nrender, complen, nrcxaps para avalistas em: 
                            efetua_inclusao_limite, efetua_alteracao_limite.
                            (André - DB1)
                            
               20/08/2012 - Alteraçoes para trabalhar com a procedure 
                            'carrega-impressao-dsctit' e 'lista-linhas-desc-tit'
                          - Eliminada chamada da procedure 'gera-impressao-limite'
                            e 'busca_dados_impressao_dsctit' (Lucas).
                            
               05/11/2012 - Incluido a passagem do inconfir5 e a saida da
                            tabela tt-grupo-economico na procedure
                            valida_proposta_dados (Adriano).  
                            
               23/06/2014 - Alteraçao do uso da temp table tt-grupo da include b1wgen0138tt. 
                           (Chamado 130880) - (Tiago Castro - RKAM)
                           
               21/05/2015 - Adicionado parametros na procedure 
                            busca_dados_limite_incluir. (Reinert)
                            
               18/12/2015 - Criada procedure para edição de número do contrato de limite 
                            (Lunelli - SD 360072 [M175])

               27/06/2016 - Criacao dos parametros inconfi6, cdopcoan e cdopcolb na
                            efetua_liber_anali_bordero. (Jaison/James)

               28/07/2017 - Desenvolvimento da melhoria 364 - Grupo Economico Novo. (Mauro)
               
               11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))

               12/02/2018 -Exposição das procedures 'busca_dados_limite_manutencao' e 'realizar_manutencao_contrato' (Leonardo Oliveira - GFT)

               24/04/2018 - Adicionado a procedure busca_dados_proposta_manuten (Paulo Penteado GFT)
               12/07/2019 - Incluido campos de avalista nas procs de gravaçao e alteraçao do desconto de titulos. PRJ 438 - Sprint 16 (Jefferson - MoutS)
............................................................................ */

{ sistema/generico/includes/b1wgen0138tt.i }
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdopcolb AS CHAR                                           NO-UNDO.
DEF VAR aux_cdopcoan AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_qttotdsc AS INTE                                           NO-UNDO.
DEF VAR aux_vltotdsc AS DECI                                           NO-UNDO.
DEF VAR aux_nrctrlim AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrant AS INTE                                           NO-UNDO.
DEF VAR aux_antnrctr AS INTE                                           NO-UNDO.
DEF VAR aux_nrborder AS INTE                                           NO-UNDO.
DEF VAR aux_flgelote AS LOGI                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.
DEF VAR aux_inconfi2 AS INTE                                           NO-UNDO.
DEF VAR aux_inconfi3 AS INTE                                           NO-UNDO.
DEF VAR aux_inconfi4 AS INTE                                           NO-UNDO.
DEF VAR aux_inconfi5 AS INTE                                           NO-UNDO.
DEF VAR aux_inconfi6 AS INTE                                           NO-UNDO.
DEF VAR aux_indrestr AS INTE                                           NO-UNDO.
DEF VAR aux_indentra AS INTE                                           NO-UNDO.
DEF VAR aux_diaratin AS INTE                                           NO-UNDO.
DEF VAR aux_vllimite AS DECI                                           NO-UNDO.
DEF VAR aux_dtrating AS DATE                                           NO-UNDO.
DEF VAR aux_vlrrisco AS DECI                                           NO-UNDO.
DEF VAR aux_cddlinha AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrmnt AS INTE                                           NO-UNDO.

DEF VAR aux_dsramati AS CHAR                                           NO-UNDO.
DEF VAR aux_vlmedtit AS DECI                                           NO-UNDO.
DEF VAR aux_vlfatura AS DECI                                           NO-UNDO.
DEF VAR aux_vloutras AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalcon AS DECI                                           NO-UNDO.
DEF VAR aux_dsdbens1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdbens2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsobserv AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdiavig AS INTE                                           NO-UNDO.
DEF VAR aux_idimpres AS INTE                                           NO-UNDO.
DEF VAR aux_limorbor AS INTE                                           NO-UNDO.

/** Rating **/
DEF VAR aux_nrgarope AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_nrliquid AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_nrperger AS INTE                                           NO-UNDO.
DEF VAR aux_vltotsfn AS DECI                                           NO-UNDO.
DEF VAR aux_perfatcl AS DECI                                           NO-UNDO.

/* avais */
DEF VAR aux_nrctaav1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfav1 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav1 AS DECI                                           NO-UNDO.
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
DEF VAR aux_nrcepav1 AS INTE                                           NO-UNDO.

DEF VAR aux_nrctaav2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepav2 AS INTE                                           NO-UNDO.
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
DEF VAR aux_nrcpfav2 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav2 AS DECI                                           NO-UNDO.
/* adicionais CEP integrado */
DEF VAR aux_nrender1 AS INTE                                           NO-UNDO.
DEF VAR aux_complen1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrender2 AS INTE                                           NO-UNDO.
DEF VAR aux_complen2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps2 AS INTE                                           NO-UNDO.

/* PRJ 438 Sprint 16 */
DEF VAR aux_vlrecjg1 AS DECI                                           NO-UNDO.
DEF VAR aux_vlrecjg2 AS DECI                                           NO-UNDO.
DEF VAR aux_cdnacio1 AS INTE                                           NO-UNDO.
DEF VAR aux_cdnacio2 AS INTE                                           NO-UNDO.
DEF VAR aux_inpesso1 AS INTE                                           NO-UNDO.
DEF VAR aux_inpesso2 AS INTE                                           NO-UNDO.
DEF VAR aux_dtnasct1 AS DATE                                           NO-UNDO.
DEF VAR aux_dtnasct2 AS DATE                                           NO-UNDO.
DEF VAR aux_vlrenme1 AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenme2 AS DECI                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_flgemail AS LOGI                                           NO-UNDO.
DEF VAR aux_idcobope AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0030tt.i }
    
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
            WHEN "cdopcolb" THEN aux_cdopcolb = tt-param.valorCampo.
            WHEN "cdopcoan" THEN aux_cdopcoan = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrctrlim" THEN aux_nrctrlim = INTE(tt-param.valorCampo).
            WHEN "nrctrant" THEN aux_nrctrant = INTE(tt-param.valorCampo).
            WHEN "antnrctr" THEN aux_antnrctr = INTE(tt-param.valorCampo).
            WHEN "nrborder" THEN aux_nrborder = INTE(tt-param.valorCampo).
            WHEN "flgelote" THEN aux_flgelote = IF tt-param.valorCampo = "1"
                                                THEN TRUE
                                                ELSE FALSE.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).
            WHEN "inconfi2" THEN aux_inconfi2 = INTE(tt-param.valorCampo).
            WHEN "inconfi3" THEN aux_inconfi3 = INTE(tt-param.valorCampo).
            WHEN "inconfi4" THEN aux_inconfi4 = INTE(tt-param.valorCampo).
            WHEN "inconfi5" THEN aux_inconfi5 = INTE(tt-param.valorCampo).
            WHEN "inconfi6" THEN aux_inconfi6 = INTE(tt-param.valorCampo).
            WHEN "indrestr" THEN aux_indrestr = INTE(tt-param.valorCampo).
            WHEN "indentra" THEN aux_indentra = INTE(tt-param.valorCampo).
            WHEN "diaratin" THEN aux_diaratin = INTE(tt-param.valorCampo).
            WHEN "vllimite" THEN aux_vllimite = DECI(tt-param.valorCampo).
            WHEN "dtrating" THEN aux_dtrating = DATE(tt-param.valorCampo).
            WHEN "vlrrisco" THEN aux_vlrrisco = DECI(tt-param.valorCampo).
            WHEN "cddlinha" THEN aux_cddlinha = INTE(tt-param.valorCampo).
            WHEN "qtdiavig" THEN aux_qtdiavig = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "dsramati" THEN aux_dsramati = tt-param.valorCampo.
            WHEN "vlmedtit" THEN aux_vlmedtit = DECI(tt-param.valorCampo).
            WHEN "vlfatura" THEN aux_vlfatura = DECI(tt-param.valorCampo).
            WHEN "vloutras" THEN aux_vloutras = DECI(tt-param.valorCampo).
            WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
            WHEN "vlsalcon" THEN aux_vlsalcon = DECI(tt-param.valorCampo).
            WHEN "dsdbens1" THEN aux_dsdbens1 = tt-param.valorCampo.
            WHEN "dsdbens2" THEN aux_dsdbens2 = tt-param.valorCampo.
            WHEN "dsobserv" THEN aux_dsobserv = tt-param.valorCampo.
            WHEN "idimpres" THEN aux_idimpres = INTE(tt-param.valorCampo).
            WHEN "limorbor" THEN aux_limorbor = INTE(tt-param.valorCampo).

            /* avais */
            WHEN "nrctaav1" THEN aux_nrctaav1 = INTE(tt-param.valorCampo).
            WHEN "nrcepav1" THEN aux_nrcepav1 = INTE(tt-param.valorCampo).
            WHEN "nrcpfav1" THEN aux_nrcpfav1 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav1" THEN aux_cpfcjav1 = DECI(tt-param.valorCampo).
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

            WHEN "nrctaav2" THEN aux_nrctaav2 = INTE(tt-param.valorCampo).
            WHEN "nrcepav2" THEN aux_nrcepav2 = INTE(tt-param.valorCampo).
            WHEN "nrcpfav2" THEN aux_nrcpfav2 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav2" THEN aux_cpfcjav2 = DECI(tt-param.valorCampo).     
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
            /* Adicionais CEP integrado */
            WHEN "nrender1" THEN aux_nrender1 = INTE(tt-param.valorCampo).
            WHEN "complen1" THEN aux_complen1 = tt-param.valorCampo.
            WHEN "nrcxaps1" THEN aux_nrcxaps1 = INTE(tt-param.valorCampo).
            WHEN "nrender2" THEN aux_nrender2 = INTE(tt-param.valorCampo).
            WHEN "complen2" THEN aux_complen2 = tt-param.valorCampo.
            WHEN "nrcxaps2" THEN aux_nrcxaps2 = INTE(tt-param.valorCampo).

            /* PRJ 438 - Sprint 16 */
            WHEN "vlrecjg1" THEN aux_vlrecjg1 = DECI(tt-param.valorCampo).
            WHEN "cdnacio1" THEN aux_cdnacio1 = INTE(tt-param.valorCampo).
            WHEN "inpesso1" THEN aux_inpesso1 = INTE(tt-param.valorCampo).
            WHEN "dtnasct1" THEN aux_dtnasct1 = DATE(tt-param.valorCampo).
            WHEN "vlrenme1" THEN aux_vlrenme1 = DECI(tt-param.valorCampo).
            WHEN "vlrecjg2" THEN aux_vlrecjg2 = DECI(tt-param.valorCampo).
            WHEN "cdnacio2" THEN aux_cdnacio2 = INTE(tt-param.valorCampo).
            WHEN "inpesso2" THEN aux_inpesso2 = INTE(tt-param.valorCampo).
            WHEN "dtnasct2" THEN aux_dtnasct2 = DATE(tt-param.valorCampo).
            WHEN "vlrenme2" THEN aux_vlrenme2 = DECI(tt-param.valorCampo).
            /* Rating */
            WHEN "nrgarope" THEN aux_nrgarope = INTE(tt-param.valorCampo).
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo).
            WHEN "nrliquid" THEN aux_nrliquid = INTE(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "nrperger" THEN aux_nrperger = INTE(tt-param.valorCampo).
            WHEN "vltotsfn" THEN aux_vltotsfn = DECI(tt-param.valorCampo). 
            WHEN "perfatcl" THEN aux_perfatcl = DECI(tt-param.valorCampo). 

            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "flgemail" THEN aux_flgemail = LOGICAL(tt-param.valorCampo).
            WHEN "idcobope" THEN aux_idcobope = INTE(tt-param.valorCampo).

        END CASE.
        
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.

/*****************************************************************************/
/*            Buscar a soma total de descontos (titulos + cheques)           */
/*****************************************************************************/
PROCEDURE busca_total_descontos:

    RUN busca_total_descontos IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT FALSE, /* LOG */
                                     OUTPUT TABLE tt-tot_descontos).


    RUN piXmlSaida (INPUT TEMP-TABLE tt-tot_descontos:HANDLE,
                    INPUT "Dados").
        
END PROCEDURE.

/*****************************************************************************/
/*          Buscar dados do Principal (@) da rotina Desconto de Titulos      */
/*****************************************************************************/
PROCEDURE busca_dados_dsctit:

    RUN busca_dados_dsctit IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_nmdatela,
                                   INPUT TRUE, /* LOG */
                                  OUTPUT TABLE tt-erro, 
                                  OUTPUT TABLE tt-desconto_titulos).


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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-desconto_titulos:HANDLE,
                        INPUT "Dados").
        
END PROCEDURE.


/****************************************************************************/
/*                  Buscar limites de uma conta informada                   */
/****************************************************************************/
PROCEDURE busca_limites:

    RUN busca_limites IN hBO (INPUT aux_cdcooper,
                              INPUT aux_nrdconta,
                              INPUT aux_dtmvtolt,
                             OUTPUT TABLE tt-limite_tit).


    RUN piXmlSaida (INPUT TEMP-TABLE tt-limite_tit:HANDLE,
                    INPUT "Dados").
        
END PROCEDURE.


/****************************************************************************/
/*                  Buscar borderos de uma conta informada                  */
/****************************************************************************/
PROCEDURE busca_borderos:

    RUN busca_borderos IN hBO (INPUT aux_cdcooper,
                               INPUT aux_nrdconta,
                               INPUT aux_dtmvtolt,
                              OUTPUT TABLE tt-bordero_tit).


    RUN piXmlSaida (INPUT TEMP-TABLE tt-bordero_tit:HANDLE,
                    INPUT "Dados").
        
END PROCEDURE.

/******************************************************************************/
/**        Procedure para excluir um limite de desconto de titulos           **/
/******************************************************************************/
PROCEDURE efetua_exclusao_limite:

    RUN efetua_exclusao_limite IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_nmdatela,
                                       INPUT aux_nrctrlim,
                                       INPUT TRUE,
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
/**        Procedure para cancelar um limite de desconto de titulos          **/
/******************************************************************************/
PROCEDURE efetua_cancelamento_limite:

    RUN efetua_cancelamento_limite IN hBO (INPUT aux_cdcooper,
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
                                           INPUT TRUE, /* LOG */
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
/**        Procedure para cancelar um limite de desconto de titulos          **/
/******************************************************************************/
PROCEDURE efetua_exclusao_bordero:

    RUN efetua_exclusao_bordero IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nmdatela,
                                        INPUT aux_nrborder,
                                        INPUT aux_flgelote,
                                        INPUT TRUE,
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


/****************************************************************************/
/*                  Efetuar Analise ou liberacao do bordero                 */
/****************************************************************************/
PROCEDURE efetua_liber_anali_bordero:

    RUN efetua_liber_anali_bordero IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_cdopcoan, /* operador coordenador analise */
                                           INPUT aux_cdopcolb, /* operador coordenador liberacao */
                                           INPUT aux_nmdatela,
                                           INPUT aux_idorigem,
                                           INPUT aux_nrdconta,
                                           INPUT aux_idseqttl,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_dtmvtopr,
                                           INPUT aux_inproces,
                                           INPUT aux_nrborder,
                                           INPUT aux_cddopcao,
                                           INPUT aux_inconfir,
                                           INPUT aux_inconfi2,
                                           INPUT aux_inconfi3,
                                           INPUT aux_inconfi4,
                                           INPUT aux_inconfi5,
                                           INPUT aux_inconfi6,
                                           INPUT-OUTPUT aux_indrestr,
                                           INPUT-OUTPUT aux_indentra,
                                           INPUT TRUE, /* GERAR LOG */
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-risco,
                                          OUTPUT TABLE tt-msg-confirma,
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
                                INPUT "Mensagem").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                             INPUT "GrupoEconomico").
            RUN piXmlSave.

        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-risco:HANDLE,
                                     INPUT "Risco").
            RUN piXmlExport   (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                     INPUT "Mensagem").
            RUN piXmlAtributo (INPUT "indrestr",INPUT STRING(aux_indrestr)).
            RUN piXmlAtributo (INPUT "indentra",INPUT STRING(aux_indentra)).
            RUN piXmlExport   (INPUT TEMP-TABLE tt-grupo:HANDLE,
                                     INPUT "GrupoEconomico").
            RUN piXmlSave.
        END.
        
END PROCEDURE.


/*****************************************************************************/
/*                  Buscar dados de um determinado bordero                   */
/*****************************************************************************/
PROCEDURE busca_dados_bordero:

    RUN busca_dados_bordero IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrborder,
                                    INPUT aux_cddopcao,
                                   OUTPUT TABLE tt-erro, 
                                   OUTPUT TABLE tt-dsctit_dados_bordero).


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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dsctit_dados_bordero:HANDLE,
                        INPUT "Dados").
        
END PROCEDURE.

/*****************************************************************************/
/*        Buscar titulos de um determinado bordero a partir da craptdb       */
/*****************************************************************************/
PROCEDURE busca_titulos_bordero:

    RUN busca_titulos_bordero IN hBO
                             (INPUT aux_cdcooper,
                              INPUT aux_nrborder,
                              INPUT aux_nrdconta,
                             OUTPUT TABLE tt-tits_do_bordero,
                             OUTPUT TABLE tt-dsctit_bordero_restricoes).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-tits_do_bordero:HANDLE,
                     INPUT "Titulos").
    RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_bordero_restricoes:HANDLE,
                     INPUT "Restricoes").
    RUN piXmlSave.
        
END PROCEDURE.


/****************************************************************************/
/*    Buscar dados de um limite de desconto de titulos COMPLETO - opcao "I" */
/****************************************************************************/
PROCEDURE busca_dados_limite_incluir:

    RUN busca_dados_limite_incluir IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_idorigem,
                                           INPUT aux_nrdconta,
                                           INPUT aux_idseqttl,
                                           INPUT aux_nmdatela,
                                           INPUT aux_inconfir,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-risco,
                                          OUTPUT TABLE tt-dados_dsctit,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-risco:HANDLE,
                             INPUT "Risco").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados").
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagem").

            RUN piXmlSave.
        END.
        
END PROCEDURE.

/****************************************************************************/
/*    Validar numero de contrato e valida o numero da conta dos avalistas   */
/****************************************************************************/
PROCEDURE valida_nrctrato_avl:

    RUN valida_nrctrato_avl IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_nrctrlim,
                                    INPUT aux_antnrctr,
                                    INPUT aux_nrctaav1,
                                    INPUT aux_nrctaav2,
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

/*****************************************************************************/
/*       Efetuar a inclusao de uma novo limite de desconto de titulos        */
/*****************************************************************************/
PROCEDURE efetua_inclusao_limite:

    RUN efetua_inclusao_limite IN hBO (INPUT aux_cdcooper,    
                                       INPUT aux_cdagenci,    
                                       INPUT aux_nrdcaixa,     
                                       INPUT aux_nrdconta,       
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cdoperad,
                                       INPUT aux_vllimite,
                                       INPUT aux_dsramati,
                                       INPUT aux_vlmedtit,
                                       INPUT aux_vlfatura,
                                       INPUT aux_vloutras,
                                       INPUT aux_vlsalari,
                                       INPUT aux_vlsalcon,
                                       INPUT aux_dsdbens1,
                                       INPUT aux_dsdbens2,
                                       INPUT aux_cddlinha,
                                       INPUT aux_dsobserv,
                                       INPUT aux_qtdiavig,
                                       INPUT TRUE, /* LOG */
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
                                       INPUT aux_vlrecjg1,
                                       INPUT aux_cdnacio1,
                                       INPUT aux_inpesso1,
                                       INPUT aux_dtnasct1,
                                       INPUT aux_vlrenme1,
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
                                       INPUT aux_vlrecjg2,
                                       INPUT aux_cdnacio2,
                                       INPUT aux_inpesso2,
                                       INPUT aux_dtnasct2,
                                       INPUT aux_vlrenme2,
                                       /* Rating */
                                       INPUT aux_nrgarope,
                                       INPUT aux_nrinfcad,
                                       INPUT aux_nrliquid,
                                       INPUT aux_nrpatlvr,
                                       INPUT aux_nrperger,
                                       INPUT aux_vltotsfn,
                                       INPUT aux_perfatcl,
									   INPUT aux_nrctrmnt,
                                       INPUT aux_idcobope, 
									  OUTPUT aux_nrctrlim,
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
            RUN piXmlAtributo (INPUT "nrctrlim", INPUT STRING(aux_nrctrlim)).            
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagens").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/*****************************************************************************/
/*     Validar dados informados da proposta de limite novo ou alteracao      */
/*****************************************************************************/
PROCEDURE valida_proposta_dados:

    RUN valida_proposta_dados IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nrctrlim,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_inproces,
                                      INPUT aux_diaratin,
                                      INPUT aux_vllimite,
                                      INPUT aux_dtrating,
                                      INPUT aux_vlrrisco,
                                      INPUT aux_cddopcao,
                                      INPUT aux_cddlinha,
                                      INPUT aux_inconfir,
                                      INPUT aux_inconfi2,
                                      INPUT aux_inconfi4,
                                      INPUT aux_inconfi5,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-msg-confirma,
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
                             INPUT "Mensagem").
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                             INPUT "GrupoEconomico").
            RUN piXmlSave.


        END.
    ELSE 
       DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                           INPUT "Mensagem").
          RUN piXmlExport (INPUT TEMP-TABLE tt-grupo:HANDLE,
                           INPUT "Grupo_Economico").
          RUN piXmlSave.
    
       END.

END PROCEDURE.

/****************************************************************************/
/*    Buscar dados de um limite de desconto de titulos COMPLETO - opcao "C" */
/****************************************************************************/
PROCEDURE busca_dados_limite_consulta:

    RUN busca_dados_limite_consulta IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nrctrlim,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dsctit_dados_limite,
                                           OUTPUT TABLE tt-dados-avais,
                                           OUTPUT TABLE tt-dados_dsctit).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_dados_limite:HANDLE,
                             INPUT "Dados_Limite").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avais").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados_Desconto").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/****************************************************************************/
/*    Buscar dados de um limite de desconto de titulos COMPLETO - opcao "C" */
/****************************************************************************/
PROCEDURE busca_dados_limite_altera:

    RUN busca_dados_limite_altera IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nmdatela,
                                          INPUT aux_nrctrlim,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dsctit_dados_limite,
                                         OUTPUT TABLE tt-dados-avais,
                                         OUTPUT TABLE tt-risco,
                                         OUTPUT TABLE tt-dados_dsctit).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_dados_limite:HANDLE,
                             INPUT "Dados_Limite").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avais").
            RUN piXmlExport (INPUT TEMP-TABLE tt-risco:HANDLE,
                             INPUT "Risco").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados_Desconto").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/*****************************************************************************/
/*       Efetuar a alteracao de um limite de desconto de titulos             */
/*****************************************************************************/
PROCEDURE efetua_alteracao_limite:

    RUN efetua_alteracao_limite IN hBO (INPUT aux_cdcooper,    
                                        INPUT aux_cdagenci,    
                                        INPUT aux_nrdcaixa,     
                                        INPUT aux_nrdconta,       
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_cdoperad,
                                        INPUT aux_vllimite,
                                        INPUT aux_dsramati,
                                        INPUT aux_vlmedtit,
                                        INPUT aux_vlfatura,
                                        INPUT aux_vloutras,
                                        INPUT aux_vlsalari,
                                        INPUT aux_vlsalcon,
                                        INPUT aux_dsdbens1,
                                        INPUT aux_dsdbens2,
                                        INPUT aux_nrctrlim,
                                        INPUT aux_cddlinha,
                                        INPUT aux_dsobserv,
                                        INPUT TRUE, /* LOG */
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
                                        INPUT aux_vlrecjg1,
                                        INPUT aux_cdnacio1,
                                        INPUT aux_inpesso1,
                                        INPUT aux_dtnasct1,
                                        INPUT aux_vlrenme1,
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
                                        INPUT aux_vlrecjg2,
                                        INPUT aux_cdnacio2,
                                        INPUT aux_inpesso2,
                                        INPUT aux_dtnasct2,
                                        INPUT aux_vlrenme2,
                                        /* Rating */
                                        INPUT aux_nrgarope,
                                        INPUT aux_nrinfcad,
                                        INPUT aux_nrliquid,
                                        INPUT aux_nrpatlvr,
                                        INPUT aux_nrperger,
                                        INPUT aux_vltotsfn,
                                        INPUT aux_perfatcl,
                                        INPUT aux_idcobope,
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

/*****************************************************************************/
/*             Rotina para listar linhas de desconto de títulos              */
/*****************************************************************************/
PROCEDURE lista-linhas-desc-tit:

    RUN lista-linhas-desc-tit IN hBO(INPUT aux_cdcooper, 
                                     INPUT aux_cdagenci, 
                                     INPUT aux_nrdcaixa, 
                                     INPUT aux_cdoperad, 
                                     INPUT aux_dtmvtolt, 
                                     INPUT aux_nrdconta, 
                                     INPUT aux_cddlinha, 
                                     INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist), 
                                     INPUT aux_nriniseq, 
                                     OUTPUT aux_qtregist, 
                                     OUTPUT TABLE tt-linhas_desc).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-linhas_desc:HANDLE,
                             INPUT "LinhaDesc").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**    Procedure para gerar impressoes relativas ao desconto de titulos     **/
/******************************************************************************/
PROCEDURE carrega-impressao-dsctit:

    RUN carrega-impressao-dsctit IN hBO (INPUT aux_cdcooper,
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
                                         INPUT aux_nrborder,
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

/*****************************************************************************/
/*  Buscar titulos com suas restricoes liberada/analisada pelo coordenador   */
/*****************************************************************************/
PROCEDURE busca_restricoes_coordenador:

    RUN busca_restricoes_coordenador IN hBO
                             (INPUT aux_cdcooper,
                              INPUT aux_nrborder,
                              INPUT aux_nrdconta,
                             OUTPUT TABLE tt-dsctit_bordero_restricoes).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_bordero_restricoes:HANDLE,
                     INPUT "Restricoes").
    RUN piXmlSave.
        
END PROCEDURE.

/***************************************************************************
    Buscar dados de um limite para manutencao 
***************************************************************************/
PROCEDURE busca_dados_limite_manutencao:

    RUN busca_dados_limite_manutencao IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nmdatela,
                                          INPUT aux_nrctrlim,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dsctit_dados_limite,
                                         OUTPUT TABLE tt-dados_dsctit).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_dados_limite:HANDLE,
                             INPUT "Dados_Limite").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados_Desconto").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/*****************************************************************************
       Realizar a manutençao do contrato                                   
****************************************************************************/
PROCEDURE realizar_manutencao_contrato:

    RUN realizar_manutencao_contrato IN hBO (INPUT aux_cdcooper,    
                                        INPUT aux_cdagenci,    
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta, 
                                        INPUT aux_idseqttl,      
                                        INPUT aux_nmdatela,
                                        INPUT aux_nrctrlim,
                                        INPUT aux_vllimite,
                                        INPUT aux_cddlinha,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-msg-confirma,
                                        OUTPUT TABLE tt-dsctit_dados_limite,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-dados_dsctit).

                                    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_dados_limite:HANDLE,
                             INPUT "Dados_Limite").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avais").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados_Desconto").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/********************************************************************/
/*    Buscar dados de uma proposta limite de desconto de titulos    */
/********************************************************************/
PROCEDURE busca_dados_proposta_consulta:

    RUN busca_dados_proposta_consulta IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nrctrlim,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dsctit_dados_limite,
                                           OUTPUT TABLE tt-dados-avais,
                                           OUTPUT TABLE tt-dados_dsctit).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_dados_limite:HANDLE,
                             INPUT "Dados_Limite").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avais").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados_Desconto").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/***************************************************************************
    Buscar dados de uma marjoração para manutenção pelo botão alterar
***************************************************************************/
PROCEDURE busca_dados_proposta_manuten:

    RUN busca_dados_proposta_manuten IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_nmdatela,
                                             INPUT aux_nrctrlim,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-dsctit_dados_limite,
                                            OUTPUT TABLE tt-dados_dsctit).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dsctit_dados_limite:HANDLE,
                             INPUT "Dados_Limite").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_dsctit:HANDLE,
                             INPUT "Dados_Desconto").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/* .......................................................................... */



