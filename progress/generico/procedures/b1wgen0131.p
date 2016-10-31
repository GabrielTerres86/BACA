/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+-----------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL               |
  +------------------------------------------+-----------------------------------+
  | sistema/generico/procedures/b1wgen0131.p | FLXF0001                          |
  | grava-fluxo-financeiro                   | pc_grava_fluxo_financeiro         |                    
  | grava-fluxo-entrada                      | pc_grava_fluxo_entrada            |
  | pi_sr_ted_f                              | pc_grava_mvt_ted_sr               |
  | pi_cheques_f_nr                          | pc_grava_mvt_cheque_nr            |
  | pi_dev_cheques_rem_f                     | pc_grava_mvt_dev_cheque_rem       |
  | pi_inss_f                                | pc_grava_mvt_inss                 |
  | pi_rec_transf_dep_intercoop_f            | pc_mvt_transf_dep_intercoop       |
  | pi_sr_titulos_f                          | pc_grava_mvt_titulo_sr            |
  | pi_rec_saq_taa_intercoop_f               | pc_grava_mvt_saq_taa_intercoop    |
  | grava-fluxo-saida                        | pc_grava_fluxo_saida              |
  | pi_convenios_f                           | pc_grava_mvt_convenios            |
  | pi_doc_f_nr                              | pc_grava_mvt_doc_nr               |
  | pi_tedtec_nr_f                           | pc_grava_mvt_tedtec_nr            | 
  | pi_titulos_f_nr                          | pc_grava_mvt_titulos_nr           |
  | pi_dev_cheques_rec_f                     | pc_grava_mvt_dev_cheque_rec       | 
  | pi_gps_f                                 | pc_grava_mvt_grps                 |
  | pi_rem_transf_dep_intercoop_f            | pc_mvt_transf_dep_intercoop       |
  | pi_rem_saq_taa_intercoop_f               | pc_gr_mvt_saq_taa_intercoop       |
  | pi_rem_fatura_bradesco_f                 | pc_grava_mvt_fatura_bradesco      |
  | pi_grava_consolidado_singular_entrada_f  | pc_gera_consolidado_singular      |
  | pi_grava_consolidado_singular_saida_f    | pc_gera_consolidado_singular      |
  | busca_dados_fluxo_singular               | busca_dados_fluxo_singular        |
  | pi_grava_consolidado_sld_dia_ant_f       | pc_grav_consolida_sld_dia_ant     |
  | atualiza_tabela_erros                    | Não convertida                    |
  | grava_consolidado_singular               | pc_grava_consolidado_singular     |
  | pi_sr_doc_f                              | pc_grava_mvt_doc                  |
  | RegraMediaDiasUteisDaSemanaChqDoc        | pc_med_dia_util_semana            |
  | RegraMediaSegundaFeiraChqDoc             | pc_regra_media_segfeira           |
  | RegraMediaDiaUtilSegundaFeira            | pc_media_dutil_segfeira           | 
  | gera-periodos-projecao-titulo            | pc_gera_periodo_projecao_tit      |
  | fnDiaAnteriorEhFeriado                   | fn_feriado_dia_anterior           |
  | RegraMediaDiasUteisDaSemanaTitulo        | pc_med_dia_util_semana            |
  | RegraMediaPrimeiroDiaUtilSegundaFeiraTit | pc_media_pri_dutil_segfeira       |
  | RegraMediaSegundaFeiraTitulo             | pc_regra_media_segfeira           |
  | pi_sr_cheques_f                          | pc_grava_mvt_cheques_sr           |
  | gera-periodos-projecao-chqdoc            | pc_gr_periodo_projecao_chqdoc     |
  | fnRetornaUltimoDiaUtilAno                | gene0005.fn_valida_dia_util       |
  | fnRetornaProximaSequencia                | fn_retorna_prox_sequencia         |
  | RegraMediaDiasUteisDaSemanaChqDoc        | pc_media_dutil_semana_chqdoc      |
  | fnBuscaDataDoUltimoDiaMes                | Não necessário                    |
  | pi_rec_mov_conta_itg_f                   | pc_grava_mvt_conta_itg            | 
  | gera-periodos-projecao-itg               | pc_gera_periodo_projecao_itg      |
  | pi_rem_mov_conta_itg_f                   | pc_grava_mvt_conta_itg            |
  | grava-movimentacao                       | pc_grava_movimentacao             |   
  | RegraMediaDiasUteisDaSemanaItg           | pc_med_dia_util_semana            |   
  | fnRetornaProximaDataUtil                 | gene0005.fn_valida_dia_util       |
  | fnValidaRegraMediaDiasUteisDaSemanaItg   | fn_valid_Media_Dia_Util_Semana    |  
  | fnValidaRegraMediaDiasUteisDaSemanaTitulo| fn_valid_Media_Dia_Util_Semana    |
  | fnValidaRegraMediaDiasUteisDaSemanaChqDoc| fn_valid_Media_Dia_Util_Semana    |
  | fnBuscaLimiteMinimo                      | fn_busca_limite_Dia               |
  | fnBuscaLimiteMaximo                      | fn_busca_limite_Dia               |
  | fnRetornaNumeroDiaUtilChqDoc             | Fn_retorna_numero_dia_util        |  
  | fnRetornaNumeroDiaUtilTitulo             | Fn_retorna_numero_dia_util        |
  | fnRetornaNumeroDiaUtilItg                | Fn_retorna_numero_dia_util        |
  | fnEhFeriado                              | fn_verifica_feriado               |
  | fnBuscaDataAnteriorFeriado               | fn_Busca_Data_anterio_feriado     |
  | RegraMediaSegundaFeiraItg                | pc_regra_media_segfeira           |
  | fnBuscaListaDias                         | fn_Busca_Lista_Dias               |
  | pi_identifica_bcoctl                     | fn_identifica_bcoctl              |
  | fnCalculaDiaUtil                         | fn_Calcula_Dia_Util               |
  | RegraMediaPrimeiroDiaUtilSegundaFeiraItg | pc_media_pri_dutil_segfeira       |                          
  +------------------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/










/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0131.p
    Autor   : Gabriel Capoia (DB1)
    Data    : Dezembro/2011                     Ultima atualizacao: 03/10/2016

    Objetivo  : Tranformacao BO tela PREVIS

    Alteracoes: 13/08/2012 - Ajustes referente ao projeto Fluxo Financeiro
                             (Adriano).
                
                21/11/2012 - Ajustes comentar a critica na opção "L" referente
                             a datas futuras não existia antes está critica e
                             o financeiro usa data futuras (Oscar).
                             
                12/12/2012 - Tornar o campo do Mvto.Cta.ITG habilitado para
                             edição (Lucas).
                             
                14/03/2013 - O campo Mvto.Cta.ITG passa a ser calculado 
                             atraves de projecao (Adriano).
   
                28/03/2013 - Adicionado parametro para a procedure
                             'consulta_faturas' (Lucas).
                             
                28/03/2013 - Ajuste na leitura da craplcm na procedure
                             pi rec transf dep intercoop_f (Gabriel).
                             
                22/10/2013 - Ajuste calculo movitação da conta itg (Oscar).
                                         
                14/11/2013 - Ajuste na procedure "pi_sr_cheques_f" para enviar
                             a cooperativa que veio como parametro na chamada
                             da funcao "fnRetornaProximaDataUtil". (James)
                             
                30/12/2013 - Correcao da procedure pi_rec_mov_conta_itg_f a qual
                             nao estava zerando a variavel aux_maiorvlr (Daniel).
                             
                24/01/2014 - Alteracao no FIND LAST tt-per-datas (Oscar).
                
                29/09/2014 - Chamado 161988 (Jonathan-RKAM). 
                         
                19/08/2015 - Na chamada da procedure obtem-log-cecred, incluir
                             novo parametro - Melhoria Gestao de TEDs/TECs - 85
                             (Lucas Ranghetti)
                             
                12/11/2015 - Na chamada da procedure obtem-log-cecred, incluir
                             novo parametro inestcri projeto Estado de Crise
                             (Jorge/Andrino)             

                03/10/2016 - Remocao das opcoes "F" e "L" para o PRJ313.
                             (Jaison/Marcos SUPERO)

............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0131tt.i }
{ sistema/generico/includes/b1wgen0050tt.i }
{ sistema/generico/includes/b1wgen0101tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0025tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_nrsequen AS INT                                         NO-UNDO.
DEF VAR aux_sequenci AS INT                                         NO-UNDO.

FUNCTION valida_horario RETURNS LOGICAL
  ( INPUT par_cdcooper AS INT,                            
    INPUT par_hrmvtolt AS INT,
    OUTPUT par_hrpermit AS LOG,
    OUTPUT par_dscritic AS CHAR) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA DOS DADOS PARA EXIBIÇÃO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdepart AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdmovto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-previs.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdepart AS CHAR                                    NO-UNDO.
    DEF VAR aux_flferiad AS LOGI                                    NO-UNDO.
    DEF VAR aux_dtliquid AS DATE                                    NO-UNDO.
    DEF VAR aux_dtliqui2 AS DATE                                    NO-UNDO.
    DEF VAR aux_valorvlb AS DECI                                    NO-UNDO.
    DEF VAR aux_valorchq AS DECI                                    NO-UNDO.
    DEF VAR aux_tpdmovto AS INTE                                    NO-UNDO.
    DEF VAR aux_hrpermit AS LOG                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Previsoes Financeiras".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-previs.

        CASE par_tpdmovto:

            WHEN "E"   THEN   ASSIGN aux_tpdmovto = 1.
            WHEN "S"   THEN   ASSIGN aux_tpdmovto = 2.
            WHEN "R"   THEN   ASSIGN aux_tpdmovto = 3.

        END CASE.
            
        
        CASE par_cddopcao:

            WHEN "C" THEN DO:

                IF  (par_dtmvtolx = ? OR
                     par_dtmvtolx > par_dtmvtolt) THEN
                    DO:
                        ASSIGN aux_cdcritic = 13.
                        LEAVE Busca.
                    END.

                IF  par_cdagencx <> 0 AND 
                    NOT CAN-FIND(FIRST crapage WHERE
                                       crapage.cdcooper = par_cdcooper AND 
                                       crapage.cdagenci = par_cdagencx) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
                        LEAVE Busca.
                    END.


                CREATE tt-previs.

                RUN pi_buscavls
                    (INPUT par_cdcooper,
                     INPUT par_cddopcao,
                     INPUT par_dtmvtolx).

                RUN pi_titulos
                    (INPUT par_cdcooper,
                     INPUT par_cdagencx,
                     INPUT par_dtmvtolx).

                RUN pi_compel
                    (INPUT par_cdcooper,
                     INPUT par_cdagencx,
                     INPUT par_dtmvtolx).

                IF  par_cdagencx > 0 THEN  /* Consulta de um unico PAC */
                    DO:
                        FOR FIRST crapprv WHERE 
                                  crapprv.cdcooper = par_cdcooper AND
                                  crapprv.dtmvtolt = par_dtmvtolx AND
                                  crapprv.cdagenci = par_cdagencx
                                  NO-LOCK: END.

                        IF  NOT AVAIL crapprv THEN
                            DO:
                                ASSIGN aux_cdcritic = 694.
                                LEAVE Busca.
                            END.

                        ASSIGN tt-previs.vldepesp = crapprv.vldepesp
                               tt-previs.vldvlnum = crapprv.vldvlnum
                               tt-previs.vlremdoc = crapprv.vlremdoc
                               tt-previs.qtremdoc = crapprv.qtremdoc
                               tt-previs.hrtransa = 
                                            STRING(crapprv.hrtransa,"HH:MM:SS")
                               tt-previs.totmoeda = 0
                               tt-previs.totnotas = 0.

                        /*  Nome do Operador  */
                        FOR FIRST crapope FIELDS(nmoperad)
                            WHERE crapope.cdcooper = par_cdcooper     AND
                                  crapope.cdoperad = crapprv.cdoperad 
                            NO-LOCK:

                        END.

                        IF NOT AVAIL crapope THEN
                           ASSIGN tt-previs.nmoperad = " - NAO CADASTRADO.".
                        ELSE
                           ASSIGN tt-previs.nmoperad = crapope.nmoperad.

                        
                        DO aux_contador = 1 TO 6:
                       
                            ASSIGN tt-previs.qtmoedas[aux_contador] =
                                              crapprv.qtmoedas[aux_contador]
                                   tt-previs.submoeda[aux_contador] =
                                             tt-previs.vlmoedas[aux_contador] *
                                             tt-previs.qtmoedas[aux_contador] *
                                             tt-previs.qtmoepct[aux_contador]
                                   tt-previs.totmoeda = tt-previs.totmoeda +
                                             tt-previs.submoeda[aux_contador]
                                   tt-previs.qtdnotas[aux_contador] =
                                              crapprv.qtdnotas[aux_contador]
                                   tt-previs.subnotas[aux_contador] = 
                                             tt-previs.vldnotas[aux_contador] *
                                             tt-previs.qtdnotas[aux_contador]
                                   tt-previs.totnotas = tt-previs.totnotas + 
                                             tt-previs.subnotas[aux_contador].

                         END.  /*   fim do DO TO  */

                    END. /* par_cdagencx > 0 */
                ELSE
                    DO:   /*  Consulta todos os PAC  */

                        ASSIGN tt-previs.vldepesp = 0
                               tt-previs.vldvlnum = 0 
                               tt-previs.qtmoedas = 0                
                               tt-previs.submoeda = 0 
                               tt-previs.totmoeda = 0 
                               tt-previs.qtdnotas = 0 
                               tt-previs.subnotas = 0 
                               tt-previs.totnotas = 0.

                        FOR EACH crapprv WHERE 
                                 crapprv.cdcooper = par_cdcooper AND
                                 crapprv.dtmvtolt = par_dtmvtolx 
                                 NO-LOCK:

                            ASSIGN tt-previs.vldepesp = tt-previs.vldepesp +
                                                        crapprv.vldepesp
                                   tt-previs.vldvlnum = tt-previs.vldvlnum + 
                                                        crapprv.vldvlnum
                                   tt-previs.vlremdoc = tt-previs.vlremdoc +
                                                        crapprv.vlremdoc
                                   tt-previs.qtremdoc = tt-previs.qtremdoc +
                                                        crapprv.qtremdoc.

                            DO aux_contador =  1 TO 6:

                                ASSIGN tt-previs.qtmoedas[aux_contador] =
                                             tt-previs.qtmoedas[aux_contador] +
                                               crapprv.qtmoedas[aux_contador]
                                       tt-previs.submoeda[aux_contador] =
                                             tt-previs.vlmoedas[aux_contador] *
                                             tt-previs.qtmoedas[aux_contador] *
                                             tt-previs.qtmoepct[aux_contador]
                                       tt-previs.qtdnotas[aux_contador] =
                                             tt-previs.qtdnotas[aux_contador] +
                                               crapprv.qtdnotas[aux_contador]
                                       tt-previs.subnotas[aux_contador] = 
                                             tt-previs.subnotas[aux_contador] +
                                            (tt-previs.vldnotas[aux_contador] *
                                               crapprv.qtdnotas[aux_contador]).

                             END. /*   fim  do DO TO   */

                        END. /*   fim  do  FOR EACH   */

                        DO aux_contador = 1 TO 6:

                            ASSIGN tt-previs.totmoeda = tt-previs.totmoeda +
                                               tt-previs.submoeda[aux_contador]
                                   tt-previs.totnotas = tt-previs.totnotas + 
                                              tt-previs.subnotas[aux_contador].

                        END. /*   fim  do DO TO   */

                    END. /*  fim do Else  */
                
            END. /* par_cddopcao = "C" */

            WHEN "A" THEN DO:

                IF  par_cdagencx = 0 OR
                    NOT CAN-FIND(FIRST crapage WHERE
                                       crapage.cdcooper = par_cdcooper AND 
                                       crapage.cdagenci = par_cdagencx) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
                        LEAVE Busca.
                    END.

                CREATE tt-previs.

                RUN pi_buscavls
                    (INPUT par_cdcooper,
                     INPUT par_cddopcao,
                     INPUT par_dtmvtolx).

                FOR FIRST crapprv WHERE 
                          crapprv.cdcooper = par_cdcooper AND
                          crapprv.dtmvtolt = par_dtmvtolx AND
                          crapprv.cdagenci = par_cdagencx
                          NO-LOCK: END.

                IF  NOT AVAIL crapprv THEN
                    DO:
                        ASSIGN aux_cdcritic = 694.
                        LEAVE Busca.
                    END.

                ASSIGN tt-previs.vldepesp = crapprv.vldepesp
                       tt-previs.vldvlnum = crapprv.vldvlnum
                       tt-previs.vldvlbcb = crapprv.vldvlbcb
                       tt-previs.vlremdoc = crapprv.vlremdoc
                       tt-previs.qtremdoc = crapprv.qtremdoc
                       tt-previs.hrtransa = STRING(crapprv.hrtransa,"HH:MM:SS")
                       tt-previs.totmoeda = 0
                       tt-previs.totnotas = 0.

                /*  Nome do Operador  */
                FOR FIRST crapope FIELDS(nmoperad)
                    WHERE crapope.cdcooper = par_cdcooper     AND
                          crapope.cdoperad = crapprv.cdoperad 
                          NO-LOCK:
                END.

                IF  NOT AVAIL crapope THEN
                    ASSIGN tt-previs.nmoperad = " - NAO CADASTRADO.".
                ELSE
                    ASSIGN tt-previs.nmoperad = crapope.nmoperad.

                DO aux_contador = 1 TO 6:
               
                    ASSIGN tt-previs.qtmoedas[aux_contador] =
                                               crapprv.qtmoedas[aux_contador]

                           tt-previs.submoeda[aux_contador] =
                                             tt-previs.vlmoedas[aux_contador] *
                                             tt-previs.qtmoedas[aux_contador] *
                                             tt-previs.qtmoepct[aux_contador]

                           tt-previs.totmoeda = tt-previs.totmoeda +
                                             tt-previs.submoeda[aux_contador]

                           tt-previs.qtdnotas[aux_contador] =
                                               crapprv.qtdnotas[aux_contador]

                           tt-previs.subnotas[aux_contador] = 
                                             tt-previs.vldnotas[aux_contador] *
                                             tt-previs.qtdnotas[aux_contador]

                           tt-previs.totnotas = tt-previs.totnotas + 
                                             tt-previs.subnotas[aux_contador].

                 END.  /*   fim do DO TO  */

            END. /* par_cddopcao = "A" */

            WHEN "I" THEN DO:

                IF  par_cdagencx = 0 OR
                    NOT CAN-FIND(FIRST crapage WHERE
                                       crapage.cdcooper = par_cdcooper AND 
                                       crapage.cdagenci = par_cdagencx) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
                        LEAVE Busca.
                    END.

                IF  CAN-FIND(FIRST crapprv WHERE 
                                   crapprv.cdcooper = par_cdcooper  AND 
                                   crapprv.dtmvtolt = par_dtmvtolx  AND
                                   crapprv.cdagenci = par_cdagencx) THEN
                    DO:
                        ASSIGN aux_cdcritic = 693.
                        LEAVE Busca.
                    END.

                CREATE tt-previs.

                RUN pi_buscavls
                    (INPUT par_cdcooper,
                     INPUT par_cddopcao,
                     INPUT par_dtmvtolx).

            END. /* par_cddopcao = "I" */

            OTHERWISE DO: 
                ASSIGN aux_cdcritic = 14.
                LEAVE Busca.
            END.
                
        END CASE.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            FIND LAST tt-erro NO-LOCK NO-ERROR.

            IF AVAIL tt-erro THEN
               ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
            ELSE
               ASSIGN aux_nrsequen = aux_nrsequen + 1.
               
            ASSIGN aux_returnvl = "NOK".
                                        
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT aux_nrsequen,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA PREVIS               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldepesp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldvlnum AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldvlbcb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtmoedas AS INTE EXTENT 6                  NO-UNDO.
    DEF  INPUT PARAM par_qtdnotas AS INTE EXTENT 6                  NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Dados Previsoes Financeiras"
           aux_cdcritic = 0
           aux_returnvl = "NOK".
           
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        CASE par_cddopcao:

            WHEN "A" THEN DO:

                Contador: DO aux_contador = 1 TO 10:

                    FIND crapprv WHERE crapprv.cdcooper = par_cdcooper AND 
                                       crapprv.dtmvtolt = par_dtmvtolt AND
                                       crapprv.cdagenci = par_cdagencx
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAIL crapprv THEN
                        DO:
                            IF  LOCKED(crapprv) THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            LEAVE Contador.
                                        END.
                                    ELSE 
                                        DO:
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT Contador.
                                        END.
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 694.
                                    LEAVE Contador.
                                END.
                        END.
                    ELSE
                        LEAVE Contador.
        
                END. /* Contador */
    
                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                    UNDO Grava, LEAVE Grava.

                ASSIGN crapprv.vldepesp = par_vldepesp
                       crapprv.vldvlnum = par_vldvlnum
                       crapprv.vldvlbcb = par_vldvlbcb
                       crapprv.cdoperad = par_cdoperad
                       crapprv.hrtransa = TIME.
                       
                DO aux_contador = 1 TO 6:
                    ASSIGN crapprv.qtmoedas[aux_contador] = 
                                                    par_qtmoedas[aux_contador]
                           crapprv.qtdnotas[aux_contador] = 
                                                    par_qtdnotas[aux_contador].
                END.

                RELEASE crapprv.

            END. /* par_cddopcao = "A" */

            WHEN "I" THEN DO:

                CREATE crapprv.
                ASSIGN crapprv.cdagenci = par_cdagencx
                       crapprv.dtmvtolt = par_dtmvtolt 
                       crapprv.vldepesp = par_vldepesp
                       crapprv.vldvlnum = par_vldvlnum
                       crapprv.vldvlbcb = par_vldvlbcb
                       crapprv.vlremdoc = 0
                       crapprv.qtremdoc = 0
                       crapprv.cdoperad = par_cdoperad
                       crapprv.hrtransa = TIME
                       crapprv.cdcooper = par_cdcooper.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                        ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                        UNDO Grava, LEAVE Grava.
                    END.
            
                DO aux_contador = 1 TO 6:
                    ASSIGN crapprv.qtmoedas[aux_contador] =
                                                    par_qtmoedas[aux_contador]
                           crapprv.qtdnotas[aux_contador] =
                                                    par_qtdnotas[aux_contador].
                END.

                RELEASE crapprv.

            END. /* par_cddopcao = "I" */
            
        END CASE.

        LEAVE Grava.

    END. /* Grava */

    IF  aux_dscritic <> ""             OR 
        aux_cdcritic <> 0              OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */


/* ------------------------------------------------------------------------- */
/*    RETORNA AS VARIAVEIS PARA PREENCHIMENTO DO COMBO DE COOPERATIVAS       */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Cooperativas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmcooper AS CHAR                           NO-UNDO.
    
    ASSIGN aux_contador = 0.

    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 
                           NO-LOCK BY crapcop.dsdircop:

        IF  aux_contador = 0 THEN
            ASSIGN aux_nmcooper = "TODAS,0," + CAPS(crapcop.dsdircop) + "," +
                                  STRING(crapcop.cdcooper)
                   aux_contador = 1.
        ELSE
            ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                                              + "," + STRING(crapcop.cdcooper).

    END. /* FIM FOR EACH crapcop  */

    RETURN "OK".
    
END PROCEDURE. /* Busca_Cooperativas */

/*............................. PROCEDURES INTERNAS .........................*/

/* ------------------------------------------------------------------------ */
/*       Atribui as var. auxiliares os valores das moedas e das notas       */
/* ------------------------------------------------------------------------ */
PROCEDURE pi_buscavls:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
                     
    IF  NOT AVAIL tt-previs THEN
        CREATE tt-previs.

    DO aux_contador =  1 TO 6:

        /*   M O E D A S  */  
        FOR FIRST craptab FIELDS(dstextab)
            WHERE craptab.cdcooper = par_cdcooper AND
                  craptab.nmsistem = "CRED"       AND
                  craptab.tptabela = "GENERI"     AND
                  craptab.cdempres = 00           AND
                  craptab.cdacesso = "VLORMOEDAS" AND
                  craptab.tpregist = aux_contador 
                  NO-LOCK: 
        END.

        IF  NOT AVAIL craptab THEN
            ASSIGN tt-previs.vlmoedas[aux_contador] = 0
                   tt-previs.qtmoepct[aux_contador] = 0.
        ELSE
            ASSIGN tt-previs.vlmoedas[aux_contador] =
                                     DECIMAL(SUBSTRING(craptab.dstextab,1,12))
                   tt-previs.qtmoepct[aux_contador] = 
                                     INTEGER(SUBSTRING(craptab.dstextab,14,6)).
       
        /*   C E D U L A S   */
        FOR FIRST craptab FIELDS(dstextab)
            WHERE craptab.cdcooper = par_cdcooper AND
                  craptab.nmsistem = "CRED"       AND
                  craptab.tptabela = "GENERI"     AND
                  craptab.cdempres = 00           AND
                  craptab.cdacesso = "VLRCEDULAS" AND
                  craptab.tpregist = aux_contador 
                  NO-LOCK: 
        END.
               
        IF  NOT AVAIL craptab THEN
            ASSIGN tt-previs.vldnotas[aux_contador] = 0.
        ELSE
            DO:
                /*  Tratamento para substituir Nota de 1,00 para 2,00  */
                IF  aux_contador =  1          AND
                    par_cddopcao =  "C"        AND
                    par_dtmvtolt <= 12/13/2011 THEN
                    ASSIGN tt-previs.vldnotas[aux_contador] = 1.
                ELSE
                    ASSIGN tt-previs.vldnotas[aux_contador] = 
                                     DECIMAL(SUBSTRING(craptab.dstextab,1,12)).
            END.
            
    END. /*   Fim do DO TO   */

    RETURN "OK".

END PROCEDURE. /* pi_buscavls */

PROCEDURE pi_titulos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
                                                                   

    IF  NOT AVAIL tt-previs THEN
        CREATE tt-previs.

    ASSIGN tt-previs.qtremtit = 0
           tt-previs.vlremtit = 0.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper AND 
                           craplot.dtmvtolt = par_dtmvtolt AND
                           craplot.tplotmov = 20           NO-LOCK:

        IF  par_cdagenci > 0 THEN
            IF  craplot.cdagenci <> par_cdagenci THEN
                NEXT.
                  
        FOR EACH craptit WHERE craptit.cdcooper = par_cdcooper     AND 
                               craptit.dtmvtolt = craplot.dtmvtolt AND
                               craptit.cdagenci = craplot.cdagenci AND
                               craptit.cdbccxlt = craplot.cdbccxlt AND
                               craptit.nrdolote = craplot.nrdolote 
                               NO-LOCK:
            
            ASSIGN tt-previs.qtremtit = tt-previs.qtremtit + 1
                   tt-previs.vlremtit = tt-previs.vlremtit + craptit.vldpagto.
                               
        END.  /*  Fim do FOR EACH  --  Leitura dos titulos  */
                           
    END.  /*  Fim do FOR EACH  --  Leitura dos titulos  */

    /*  Titulos enviados para ASBACE de forma convencional  */
    FOR EACH craplcx WHERE craplcx.cdcooper = par_cdcooper AND 
                           craplcx.dtmvtolt = par_dtmvtolt AND
                           craplcx.cdhistor = 707          
                           NO-LOCK:

        IF  par_cdagenci > 0 THEN
            IF  craplcx.cdagenci <> par_cdagenci THEN
                NEXT.

        ASSIGN tt-previs.vlremtit = tt-previs.vlremtit + craplcx.vldocmto
               tt-previs.qtremtit = tt-previs.qtremtit + 1.

    END.  /*  Fim do FOR EACH -- Leitura do craplcx  */


    RETURN "OK".

END PROCEDURE. /* pi_titulos */

PROCEDURE pi_compel:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    IF  NOT AVAIL tt-previs THEN
        CREATE tt-previs.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper AND
                           craplot.dtmvtolt = par_dtmvtolt AND
                          (craplot.cdbccxlt = 11           OR
                           craplot.cdbccxlt = 500)         AND
                          (craplot.tplotmov = 1            OR
                           craplot.tplotmov = 23           OR
                           craplot.tplotmov = 29)          
                           NO-LOCK:

        IF  par_cdagenci > 0 THEN
            IF  craplot.cdagenci <> par_cdagenci THEN
                NEXT.

        FOR EACH crapchd WHERE crapchd.cdcooper = par_cdcooper     AND 
                               crapchd.dtmvtolt = craplot.dtmvtolt AND
                               crapchd.cdagenci = craplot.cdagenci AND
                               crapchd.cdbccxlt = craplot.cdbccxlt AND
                               crapchd.nrdolote = craplot.nrdolote AND
                               crapchd.inchqcop = 0 USE-INDEX crapchd3 
                               NO-LOCK:

            ASSIGN tt-previs.vldvlbcb = tt-previs.vldvlbcb + crapchd.vlcheque
                   tt-previs.qtdvlbcb = tt-previs.qtdvlbcb + 1.
            
        END.  /*  Fim do FOR EACH  --  Leitura dos cheques acolhidos  */
    
    END.  /*  Fim do FOR EACH  --  Leitura dos lotes  */

    /*  Cheques enviados para ASBACE de forma convencional  */
    FOR EACH craplcx WHERE craplcx.cdcooper = par_cdcooper AND
                           craplcx.dtmvtolt = par_dtmvtolt AND
                           craplcx.cdhistor = 712          
                           NO-LOCK:

        IF  par_cdagenci > 0   THEN
            IF  craplcx.cdagenci <> par_cdagenci THEN
                NEXT.

        ASSIGN tt-previs.vldvlbcb = tt-previs.vldvlbcb + craplcx.vldocmto
               tt-previs.qtdvlbcb = tt-previs.qtdvlbcb + 1.
        
    END.  /*  Fim do FOR EACH -- Leitura do craplcx  */
    
    /*  Cheques de custodia/desconto  */
    FOR EACH crapchd WHERE crapchd.cdcooper = par_cdcooper AND 
                           crapchd.dtmvtolt = par_dtmvtolt AND
                          (crapchd.cdbccxlt = 600          OR
                           crapchd.cdbccxlt = 700)         AND
                           crapchd.insitchq = 2            AND
                           crapchd.inchqcop = 0 USE-INDEX crapchd3 
                           NO-LOCK:

        IF  par_cdagenci > 0 THEN
            IF  crapchd.cdagenci <> par_cdagenci THEN
                NEXT.

        ASSIGN tt-previs.vldvlbcb = tt-previs.vldvlbcb + crapchd.vlcheque
               tt-previs.qtdvlbcb = tt-previs.qtdvlbcb + 1.

    END.  /*  Fim do FOR EACH -- Leitura dos cheques em custodia/desconto  */

    RETURN "OK".

END PROCEDURE. /* pi_compel */


PROCEDURE libera_acesso:

   DEF INPUT PARAM par_cdcooper AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                              NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_cdcoopex AS INT                              NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_contador AS INT                                      NO-UNDO.
   DEF VAR aux_cdcritic AS INT                                      NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

   ASSIGN aux_contador = 0
          aux_cdcritic = 0
          aux_dscritic = "".
          
   EMPTY TEMP-TABLE tt-erro.

   FOR EACH crapcop WHERE (IF par_cdcoopex = 0 OR 
                              par_cdcoopex = 3 THEN
                              TRUE
                           ELSE
                              crapcop.cdcooper = par_cdcoopex)
                           NO-LOCK:
   
       DO aux_contador = 1 TO 10:
       
          FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                             craptab.nmsistem = "CRED"           AND
                             craptab.tptabela = "GENERI"         AND
                             craptab.cdempres = 00               AND
                             craptab.cdacesso = "PREVISOPCAOF"      
                             EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
       
          IF NOT AVAILABLE craptab THEN
             DO:
                IF LOCKED craptab THEN
                   DO:
                      ASSIGN aux_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
       
                   END.
                ELSE
                  DO:
                     ASSIGN aux_cdcritic = 55.
                     LEAVE.
       
                  END.
             END.
          ELSE
             DO:
                ASSIGN aux_cdcritic = 0 
                       craptab.dstextab = "".
                             
                LEAVE.
       
             END.
       
       END.  /*  Fim do DO .. TO  */
       
       RELEASE craptab.

   END.

   IF aux_cdcritic <> 0 THEN
      DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
                       
         RETURN "NOK".
   
      END.

   RETURN "OK".


END PROCEDURE.


END FUNCTION.
