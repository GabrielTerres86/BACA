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
    Data    : Dezembro/2011                     Ultima atualizacao: 27/09/2016

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
                             
                27/09/2016 - M211 - Envio do parado cdifconv na chamada da 
                            obtem-log-cecred pela pi_sr_ted_f (Evandro-RKAM)        
                        
                        
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

FUNCTION fnBuscaDataAnteriorFeriado RETURN DATE
    (INPUT par_cdcooper AS INT,
     INPUT par_dtrefmes AS DATE) FORWARD.

FUNCTION valida_horario RETURNS LOGICAL
  ( INPUT par_cdcooper AS INT,                            
    INPUT par_hrmvtolt AS INT,
    OUTPUT par_hrpermit AS LOG,
    OUTPUT par_dscritic AS CHAR) FORWARD.


FUNCTION fnEhDataUtil RETURN LOG PRIVATE
  ( INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE) FORWARD.


FUNCTION fnRetornaNumeroDiaUtilTitulo INTEGER PRIVATE 
  ( INPUT par_cdcooper AS INT,
    INPUT par_numdiaut AS INT,
    INPUT par_dtdatmes AS DATE) FORWARD.


FUNCTION fnEhFeriado RETURN LOG PRIVATE
  ( INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE) FORWARD.


FUNCTION fnRetornaProximaSequencia RETURN INT PRIVATE FORWARD.


FUNCTION fnDiaAnteriorEhFeriado RETURN LOG PRIVATE 
  ( INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE) FORWARD.


FUNCTION fnValidaRegraMediaDiasUteisDaSemanaTitulo RETURN LOG PRIVATE 
  ( INPUT par_nrdiasme AS CHAR,
    INPUT par_nrdiasse AS CHAR,
    INPUT par_dtperiod AS DATE,
    INPUT par_cdcooper AS INTE) FORWARD.
   

FUNCTION fnDataExiste RETURN LOG PRIVATE
  ( INPUT par_mes AS INT,
    INPUT par_dia AS INT,
    INPUT par_ano AS INT) FORWARD.


FUNCTION fnCalculaDiaUtil INTEGER PRIVATE
  ( INPUT par_dtdiames AS INT) FORWARD.


FUNCTION fnBuscaLimiteMinimo RETURN INT PRIVATE
  ( INPUT par_dtdiames AS INT) FORWARD.


FUNCTION fnBuscaLimiteMaximo RETURN INT PRIVATE
  ( INPUT par_dtdiames AS INT) FORWARD.


FUNCTION fnBuscaListaDias RETURN CHAR PRIVATE
  ( INPUT par_dtdiames AS INT) FORWARD.


FUNCTION fnBuscaDataDoUltimoDiaMes RETURN DATE PRIVATE
  ( INPUT par_dtrefmes AS DATE) FORWARD.


FUNCTION fnRetornaNumeroDiaUtilChqDoc INTEGER PRIVATE
  ( INPUT par_cdcooper AS INT,
    INPUT par_numdiaut AS INT,
    INPUT par_dtdatmes AS DATE) FORWARD.


FUNCTION fnValidaDiasUteisMes RETURN LOGICAL PRIVATE
  ( INPUT par_cdcooper AS INT,
    INPUT par_dtdatmes AS DATE) FORWARD.


FUNCTION fnValidaRegraMediaDiasUteisDaSemanaChqDoc RETURN LOG PRIVATE 
  ( INPUT par_nrdiasme AS CHAR,
    INPUT par_nrdiasse AS CHAR,
    INPUT par_dtperiod AS DATE,
    INPUT par_cdcooper AS INTE) FORWARD.


FUNCTION fnRetornaDiaUtilAnterior RETURN DATE PRIVATE
  ( INPUT par_dtmvtolt AS DATE) FORWARD.


FUNCTION fnRetornaProximaDataUtil RETURN DATE PRIVATE 
  (INPUT par_cdcooper AS INT,
   INPUT par_dtrefmes AS DATE) FORWARD.

FUNCTION fnRetornaNumeroDiaUtilItg RETURN INTEGER 
  (INPUT par_cdcooper AS INT,
   INPUT par_numdiaut AS INT,
   INPUT par_dtdatmes AS DATE) FORWARD.

FUNCTION fnValidaRegraMediaDiasUteisDaSemanaItg RETURN LOG
         (INPUT par_nrdiasme AS CHAR,
          INPUT par_nrdiasse AS CHAR,
          INPUT par_dtperiod AS DATE,
          INPUT par_cdcooper AS INTE) FORWARD.


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
    DEF OUTPUT PARAM TABLE FOR tt-fluxo.
    DEF OUTPUT PARAM TABLE FOR tt-ffin-mvto-cent.
    DEF OUTPUT PARAM TABLE FOR tt-ffin-mvto-sing.
    DEF OUTPUT PARAM TABLE FOR tt-ffin-cons-cent.
    DEF OUTPUT PARAM TABLE FOR tt-ffin-cons-sing.
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
        EMPTY TEMP-TABLE tt-fluxo.
        EMPTY TEMP-TABLE tt-ffin-mvto-cent.
        EMPTY TEMP-TABLE tt-ffin-mvto-sing.

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

            WHEN "F" THEN DO:

                /* Oscar - Será controlada pela PERMISS segundo Fernanda Pera
                
                ASSIGN aux_dsdepart = "TI,SUPORTE,COORD.ADM/FINANCEIRO," +
                                      "COORD.PRODUTOS,COMPE,FINANCEIRO".

                IF  NOT CAN-DO(aux_dsdepart,par_dsdepart) THEN
                    DO:
                        ASSIGN aux_cdcritic = 36.
                        LEAVE Busca.
                    END.
                    
                */

                IF NOT fnEhDataUtil(par_cdcooper, par_dtmvtolx) THEN
                   DO:
                       ASSIGN aux_dscritic = "Data de referencia deve " + 
                                             "ser um dia util.".
                       
                       LEAVE Busca.

                   END.
                                                      
                IF par_dtmvtolx = par_dtmvtolt AND 
                   par_tpdmovto <> "A"         THEN
                   DO:            
                      RUN grava-fluxo-financeiro (INPUT par_cdcooper,
                                                  INPUT par_cdagenci, 
                                                  INPUT par_nrdcaixa, 
                                                  INPUT par_cdoperad, 
                                                  INPUT par_dtmvtolt, 
                                                  INPUT par_nmdatela,
                                                  INPUT par_cdcoopex,
                                                  INPUT par_dtmvtoan, 
                                                  INPUT par_cdagefim, 
                                                  OUTPUT TABLE tt-erro).
                      
                      IF RETURN-VALUE <> "OK" THEN
                         DO:
                            FIND LAST tt-erro NO-LOCK NO-ERROR.

                            IF AVAIL tt-erro THEN
                               ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
                            ELSE
                               ASSIGN aux_nrsequen = aux_nrsequen + 1.
                          
                             ASSIGN aux_cdcritic = 0
                                    aux_dscritic = "Nao foi possivel "   +
                                                   "realizar o calculo " +
                                                   "do fluxo financeiro.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT aux_nrsequen,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                                  
                         END.
                   
                   END.
                   
                IF (par_dtmvtolx = ?             OR
                    par_dtmvtolx > par_dtmvtolt) THEN
                    DO:
                        ASSIGN aux_cdcritic = 13.
                        LEAVE Busca.

                    END.

                IF  par_cdagencx <> 0                                   AND 
                    NOT CAN-FIND(FIRST crapage WHERE
                                       crapage.cdcooper = par_cdcooper  AND 
                                       crapage.cdagenci = par_cdagencx) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
                        LEAVE Busca.
                    END.

                ASSIGN aux_cdagefim = IF par_cdagencx = 0 THEN 
                                         9999
                                      ELSE 
                                         par_cdagencx.
                      
                IF par_tpdmovto = "R"   THEN  /* Resultado */
                   DO:
                      IF par_cdcooper = 3 THEN
                         DO: 
                             RUN busca_dados_consolidado_central 
                                           (INPUT par_cdcooper,
                                            INPUT par_dtmvtolx,
                                            INPUT par_cdcoopex,
                                           OUTPUT TABLE tt-ffin-cons-cent).
                         END.       
                      ELSE
                         DO:
                             RUN busca_dados_consolidado_singular 
                                           (INPUT par_cdcooper,
                                            INPUT par_dtmvtolx,
                                            INPUT 0,
                                           OUTPUT TABLE tt-ffin-cons-sing).

                         END.                           

                   END.
                ELSE
                  IF par_tpdmovto = "A" AND par_cdcooper = 3 THEN /*Resultado*/
                     DO: 
                        RUN busca_dados_consolidado_singular
                                         (INPUT par_cdcooper,
                                          INPUT par_dtmvtolx,
                                          INPUT par_cdcoopex,
                                          OUTPUT TABLE tt-ffin-cons-sing).
                    END.
                ELSE
                   DO:
                      IF par_cdcooper = 3   THEN
                         DO: 
                             RUN busca_dados_fluxo_central 
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolx,
                                         INPUT aux_tpdmovto,
                                         INPUT par_cdcoopex,
                                        OUTPUT TABLE tt-ffin-mvto-cent).
                         END.
                      ELSE
                         DO:
                             RUN busca_dados_fluxo_singular 
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolx,
                                         INPUT aux_tpdmovto,
                                        OUTPUT TABLE tt-ffin-mvto-sing).

                         END.         

                   END.
                                     
            END. /* par_cddopcao = "F" */   

            WHEN "L" THEN DO:

                ASSIGN aux_dsdepart = "TI,SUPORTE,COORD.ADM/FINANCEIRO," +
                                      "COORD.PRODUTOS,COMPE,FINANCEIRO".

                IF  NOT CAN-DO(aux_dsdepart,par_dsdepart) THEN
                    DO:
                        ASSIGN aux_cdcritic = 36.
                        LEAVE Busca.
                    END.

                /*IF  (par_dtmvtolx = ? OR
                     par_dtmvtolx > par_dtmvtolt) THEN
                    DO:
                        ASSIGN aux_cdcritic = 13.
                        LEAVE Busca.
                    END. Oscar */

                RUN pi_calcula_datas
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolx,
                     OUTPUT aux_flferiad,
                     OUTPUT aux_dtliquid,
                     OUTPUT aux_dtliqui2).

                CREATE tt-fluxo.

                IF  NOT aux_flferiad THEN
                    DO:          
                        ASSIGN aux_cdagefim = IF   par_cdagencx = 0 THEN 9999
                                              ELSE par_cdagencx.
                        
                        ASSIGN tt-fluxo.vlcobbil = 0
                               tt-fluxo.vlcobmlt = 0
                               tt-fluxo.vlchqnot = 0
                               tt-fluxo.vlchqdia = 0.

                        /********** BUSCA PARAMETROS **********/
                        FOR FIRST craptab FIELDS(dstextab)
                            WHERE craptab.cdcooper = par_cdcooper AND
                                  craptab.nmsistem = "CRED"       AND
                                  craptab.tptabela = "GENERI"     AND
                                  craptab.cdempres = 0            AND
                                  craptab.cdacesso = "VALORESVLB" AND
                                  craptab.tpregist = 0
                                  USE-INDEX craptab1 NO-LOCK: END.

                        IF  AVAIL craptab THEN
                            ASSIGN aux_valorvlb =
                                        DECIMAL(ENTRY(1,craptab.dstextab,";")).
                        ELSE
                            ASSIGN aux_valorvlb = 5000.

                        FOR FIRST craptab FIELDS(dstextab)
                            WHERE craptab.cdcooper = par_cdcooper AND
                                  craptab.nmsistem = "CRED"       AND
                                  craptab.tptabela = "USUARI"     AND
                                  craptab.cdempres = 11           AND
                                  craptab.cdacesso = "MAIORESCHQ" AND
                                  craptab.tpregist = 001
                                  USE-INDEX craptab1 NO-LOCK: END.

                        IF  AVAIL craptab THEN
                            ASSIGN aux_valorchq = 
                                    DECIMAL(SUBSTRING(craptab.dstextab,01,15)).
                        ELSE
                            ASSIGN aux_valorchq = 300.

                        Cooperativas:
                        FOR EACH crapcop WHERE (par_cdcoopex = 0       AND
                                                crapcop.cdcooper <> 3) OR
                                                crapcop.cdcooper = par_cdcoopex
                                                NO-LOCK:

                            RUN pi_devolu_l_nr
                                (INPUT crapcop.cdcooper,
                                 INPUT par_cdagencx,
                                 INPUT par_dtmvtolx,
                                 INPUT aux_dtliquid).

                            RUN pi_cheques_l_nr
                                (INPUT crapcop.cdcooper,
                                 INPUT par_cdagencx,
                                 INPUT aux_cdagefim,
                                 INPUT par_dtmvtolx,
                                 INPUT aux_dtliquid,
                                 INPUT aux_dtliqui2,
                                 INPUT aux_valorchq).
    
                            RUN pi_doc_l_nr
                                (INPUT crapcop.cdcooper,
                                 INPUT par_cdagencx,
                                 INPUT aux_cdagefim,
                                 INPUT par_dtmvtolx,
                                 INPUT aux_dtliquid,
                                 INPUT aux_valorvlb).
    
                            RUN pi_titulos_l_nr
                                (INPUT crapcop.cdcooper,
                                 INPUT par_cdagencx,
                                 INPUT aux_cdagefim,
                                 INPUT par_dtmvtolx,
                                 INPUT aux_dtliquid,
                                 INPUT aux_valorvlb).

                        END. /* Cooperativas */

                    END. /* IF  NOT aux_flferiad */
                ELSE
                    ASSIGN tt-fluxo.vlcobbil = 0
                           tt-fluxo.vlcobmlt = 0
                           tt-fluxo.vlchqnot = 0
                           tt-fluxo.vlchqdia = 0.
                
            END. /* par_cddopcao = "L" */

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


PROCEDURE grava-movimentacao:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_tpdmovto AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_tpdcampo AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_vldcampo AS DECI                            NO-UNDO.

    DEF BUFFER b-crapcop1 FOR crapcop.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        FIND crapffm WHERE crapffm.cdcooper = par_cdcooper AND
                           crapffm.dtmvtolt = par_dtmvtolt AND
                           crapffm.tpdmovto = par_tpdmovto AND
                           crapffm.cdbccxlt = par_cdbccxlt 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL crapffm   THEN
           DO:
               CREATE crapffm.

               ASSIGN crapffm.cdcooper = par_cdcooper
                      crapffm.dtmvtolt = par_dtmvtolt
                      crapffm.tpdmovto = par_tpdmovto
                      crapffm.cdbccxlt = par_cdbccxlt. 

           END.
        
        CASE par_tpdcampo:

            WHEN  0   THEN LEAVE.
            WHEN  1   THEN ASSIGN crapffm.vlcheque = par_vldcampo.
            WHEN  2   THEN ASSIGN crapffm.vltotdoc = par_vldcampo.
            WHEN  3   THEN ASSIGN crapffm.vltotted = par_vldcampo.
            WHEN  4   THEN ASSIGN crapffm.vltottit = par_vldcampo.
            WHEN  5   THEN ASSIGN crapffm.vldevolu = par_vldcampo.
            WHEN  6   THEN ASSIGN crapffm.vlmvtitg = par_vldcampo.
            WHEN  7   THEN ASSIGN crapffm.vlttinss = par_vldcampo.
            WHEN  8   THEN ASSIGN crapffm.vltrdeit = par_vldcampo.
            WHEN  9   THEN ASSIGN crapffm.vlsatait = par_vldcampo.
            WHEN 10   THEN ASSIGN crapffm.vlfatbra = par_vldcampo.
            WHEN 11   THEN ASSIGN crapffm.vlconven = par_vldcampo.
            WHEN 12   THEN 
              DO:
                 FIND b-crapcop1 WHERE b-crapcop1.cdcooper = par_cdcooper 
                                       NO-LOCK NO-ERROR.
              
                 UNIX SILENT VALUE("echo "                                   + 
                                  STRING(par_dtmvtolt,"99/99/9999")          +
                                  " "     + STRING(TIME,"HH:MM:SS")          +
                                  "' --> '" + "Operador " + par_cdoperad     +
                                  " - "                                      +
                                  "alterou o valor do repasse de "           +
                                  STRING(crapffm.vlrepass,"zzzz,zzz,zz9.99") +
                                  " para "                                   +
                                  STRING(par_vldcampo,"zzzz,zzz,zz9.99")     +
                                  ", banco " + STRING(crapffm.cdbccxlt)      +
                                  (IF par_tpdmovto = 1 THEN 
                                      ", Entrada"         
                                   ELSE
                                      ", Saida")                             +
                                  ". >> /usr/coop/"                          + 
                                  TRIM(b-crapcop1.dsdircop)                  +
                                  "/log/previs.log").

                 ASSIGN crapffm.vlrepass = par_vldcampo.
              
              END.

            WHEN 13   THEN
              DO:
                 FIND b-crapcop1 WHERE b-crapcop1.cdcooper = par_cdcooper 
                                       NO-LOCK NO-ERROR.

                 UNIX SILENT VALUE("echo "                                 +
                             STRING(par_dtmvtolt,"99/99/9999")             +
                             " " + STRING(TIME,"HH:MM:SS")                 +
                             "' --> '" + "Operador " + par_cdoperad        +
                             " - "                                         +
                            (IF par_tpdmovto = 1 THEN 
                                "alterou o valor do deposito de numerario de "
                             ELSE 
                                "alterou o valor do alivio de numerario")  +
                             STRING(crapffm.vlnumera,"zzzz,zzz,zz9.99")    +
                             " para "                                      +
                             STRING(par_vldcampo,"zzzz,zzz,zz9.99")        +
                             ", banco " + STRING(crapffm.cdbccxlt)         +
                             (IF par_tpdmovto = 1 THEN 
                                 ", Entrada"         
                              ELSE
                                 ", Saida")                                +
                             ". >> /usr/coop/" + TRIM(b-crapcop1.dsdircop) +
                             "/log/previs.log").

                 ASSIGN crapffm.vlnumera = par_vldcampo.

              END.
            WHEN 14   THEN 
              DO: 
                 FIND b-crapcop1 WHERE b-crapcop1.cdcooper = par_cdcooper 
                                       NO-LOCK NO-ERROR.

                 UNIX SILENT VALUE("echo "                                    +
                                STRING(par_dtmvtolt,"99/99/9999")             +
                                " " + STRING(TIME,"HH:MM:SS") + "' --> '"     +
                                "Operador " + par_cdoperad + " - "            +
                                (IF par_tpdmovto = 1 THEN 
                                    "alterou o valor da folha de pagamento de "
                                 ELSE
                                    "alterou o valor do saque numerario")     +
                                STRING(crapffm.vlrfolha,"zzzz,zzz,zz9.99")    +
                                " para "                                      +
                                STRING(par_vldcampo,"zzzz,zzz,zz9.99")        +
                                ", banco " + STRING(crapffm.cdbccxlt)         +
                                (IF par_tpdmovto = 1 THEN 
                                    ", Entrada"         
                                 ELSE
                                    ", Saida")                                +
                                ". >> /usr/coop/" + TRIM(b-crapcop1.dsdircop) +
                                "/log/previs.log").

                 ASSIGN crapffm.vlrfolha = par_vldcampo.

              END.
            WHEN 15   THEN 
              DO: 
                 FIND b-crapcop1 WHERE b-crapcop1.cdcooper = par_cdcooper 
                                       NO-LOCK NO-ERROR.

                 UNIX SILENT VALUE("echo "                                    +
                                STRING(par_dtmvtolt,"99/99/9999")             +
                                " " + STRING(TIME,"HH:MM:SS") + "' --> '"     +
                                "Operador " + par_cdoperad + " - "            +
                                "Alterou o valor outros de "                  +
                                STRING(crapffm.vloutros,"zzzz,zzz,zz9.99")    +
                                " para "                                      +
                                STRING(par_vldcampo,"zzzz,zzz,zz9.99")        +
                                ", banco " + STRING(crapffm.cdbccxlt)         +
                                (IF par_tpdmovto = 1 THEN 
                                    ", Entrada"         
                                 ELSE
                                    ", Saida")                                +
                                ". >> /usr/coop/" + TRIM(b-crapcop1.dsdircop) +
                                "/log/previs.log").

                 ASSIGN crapffm.vloutros = par_vldcampo.

              END.

        END CASE.

    END.

    RELEASE crapffm.
        
    RETURN "OK".
  
END PROCEDURE.


PROCEDURE busca_dados_consolidado_central:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-ffin-cons-cent.

    EMPTY TEMP-TABLE tt-ffin-cons-cent.

    CREATE tt-ffin-cons-cent.

    ASSIGN tt-ffin-cons-cent.cdcooper = par_cdcooper
           tt-ffin-cons-cent.dtmvtolt = par_dtmvtolx.

    RUN busca_dados_fluxo_central (INPUT par_cdcooper,
                                   INPUT par_dtmvtolx,
                                   INPUT 1, /* Entrada */
                                   INPUT par_cdcoopex,
                                  OUTPUT TABLE tt-ffin-mvto-cent). 

    FIND FIRST tt-ffin-mvto-cent NO-LOCK NO-ERROR.

    IF   AVAIL tt-ffin-mvto-cent   THEN
         ASSIGN tt-ffin-cons-cent.vlentrad[1] = tt-ffin-mvto-cent.vlttcrdb[1]
                tt-ffin-cons-cent.vlentrad[2] = tt-ffin-mvto-cent.vlttcrdb[2]
                tt-ffin-cons-cent.vlentrad[3] = tt-ffin-mvto-cent.vlttcrdb[3].

    RUN busca_dados_fluxo_central (INPUT par_cdcooper,
                                   INPUT par_dtmvtolx,
                                   INPUT 2, /* Saida */
                                   INPUT par_cdcoopex,
                                  OUTPUT TABLE tt-ffin-mvto-cent). 

    FIND FIRST tt-ffin-mvto-cent NO-LOCK NO-ERROR.

    IF   AVAIL tt-ffin-mvto-cent   THEN
         ASSIGN tt-ffin-cons-cent.vlsaidas[1] = tt-ffin-mvto-cent.vlttcrdb[1]
                tt-ffin-cons-cent.vlsaidas[2] = tt-ffin-mvto-cent.vlttcrdb[2]
                tt-ffin-cons-cent.vlsaidas[3] = tt-ffin-mvto-cent.vlttcrdb[3].

    ASSIGN tt-ffin-cons-cent.vlresult[1] = tt-ffin-cons-cent.vlentrad[1] - 
                                           tt-ffin-cons-cent.vlsaidas[1]      
           tt-ffin-cons-cent.vlresult[2] = tt-ffin-cons-cent.vlentrad[2] -
                                           tt-ffin-cons-cent.vlsaidas[2]  
           tt-ffin-cons-cent.vlresult[3] = tt-ffin-cons-cent.vlentrad[3] - 
                                           tt-ffin-cons-cent.vlsaidas[3].

    RETURN "OK".
 
END PROCEDURE.


PROCEDURE busca_dados_consolidado_singular:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-ffin-cons-sing.

    DEF VAR aux_vlsldfin AS DECI                                    NO-UNDO.


    EMPTY TEMP-TABLE tt-ffin-cons-sing.

    FOR EACH crapcop WHERE (IF par_cdcooper <> 3 THEN
                               crapcop.cdcooper = par_cdcooper
                            ELSE
                               IF par_cdcoopex = 0 THEN 
                                  crapcop.cdcooper <> 3
                               ELSE
                                  crapcop.cdcooper = par_cdcoopex)
                            NO-LOCK:
                             
        FOR EACH crapffc WHERE crapffc.cdcooper = crapcop.cdcooper AND
                               crapffc.dtmvtolt = par_dtmvtolt   
                               NO-LOCK:

            CREATE tt-ffin-cons-sing.

            BUFFER-COPY crapffc EXCEPT hrtransa TO tt-ffin-cons-sing.
       
            ASSIGN aux_vlsldfin = IF crapffc.vlresgat > 0 THEN
                                     crapffc.vlresgat
                                  ELSE
                                     - crapffc.vlaplica
                   tt-ffin-cons-sing.vlresult = crapffc.vlentrad - 
                                                crapffc.vlsaidas
                   tt-ffin-cons-sing.vlsldfin = crapffc.vlsldcta + 
                                                aux_vlsldfin     +
                                                tt-ffin-cons-sing.vlresult
                   tt-ffin-cons-sing.nmrescop = crapcop.nmrescop
                   tt-ffin-cons-sing.hrtransa = STRING(crapffc.hrtransa,
                                                       "HH:MM:SS").

            /*  Nome do Operador  */
            FOR FIRST crapope FIELDS(nmoperad)
                WHERE crapope.cdcooper = crapcop.cdcooper AND
                      crapope.cdoperad = crapffc.cdoperad 
                      NO-LOCK:

            END.

            IF NOT AVAIL crapope THEN
               ASSIGN tt-ffin-cons-sing.nmoperad = " - NAO CADASTRADO.".
            ELSE
               ASSIGN tt-ffin-cons-sing.nmoperad = crapope.nmoperad.

               
        END.

    END.


    RETURN "OK".


END PROCEDURE.

PROCEDURE busca_dados_fluxo_central:

  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_tpdmovto AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-ffin-mvto-cent.

  DEF VAR aux_indice AS INTE                                      NO-UNDO.
  DEF VAR aux_contador AS INT                                     NO-UNDO.
  DEF VAR aux_vlcheque AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vltotdoc AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vltotted AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vltottit AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vldevolu AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vlmvtitg AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vlttinss AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vldivers AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vlrepass AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vlrfolha AS DEC EXTENT 3                            NO-UNDO.   
  DEF VAR aux_vlttcrdb AS DEC EXTENT 3                            NO-UNDO.   

  EMPTY TEMP-TABLE tt-ffin-mvto-cent.

  CREATE tt-ffin-mvto-cent.

  ASSIGN tt-ffin-mvto-cent.cdbcoval[1] = 85
         tt-ffin-mvto-cent.cdbcoval[2] = 1
         tt-ffin-mvto-cent.cdbcoval[3] = 756
         tt-ffin-mvto-cent.tpdmovto    = par_tpdmovto
         aux_vlcheque = 0
         aux_vltotdoc = 0
         aux_vltotted = 0
         aux_vltottit = 0
         aux_vldevolu = 0
         aux_vlmvtitg = 0
         aux_vlttinss = 0
         aux_vldivers = 0
         aux_vlrepass = 0
         aux_vlrfolha = 0
         aux_vlttcrdb = 0.

  FOR EACH crapcop WHERE (IF par_cdcooper <> 3 THEN
                             crapcop.cdcooper = par_cdcooper
                          ELSE
                             IF par_cdcoopex = 0 THEN 
                                crapcop.cdcooper <> 3
                             ELSE
                                crapcop.cdcooper = par_cdcoopex)
                          NO-LOCK:

      FOR EACH crapffm WHERE crapffm.cdcooper = crapcop.cdcooper AND
                             crapffm.dtmvtolt = par_dtmvtolx     AND
                             crapffm.tpdmovto = par_tpdmovto   
                             NO-LOCK:

          CASE crapffm.cdbccxlt:
          
              WHEN 85     THEN   ASSIGN aux_indice = 1.
              WHEN 1      THEN   ASSIGN aux_indice = 2.
              WHEN 756    THEN   ASSIGN aux_indice = 3.
              OTHERWISE NEXT.
          
          END CASE.
          
          IF par_tpdmovto = 1 THEN
             DO:
                ASSIGN aux_vlmvtitg[aux_indice] = aux_vlmvtitg[aux_indice] +
                                                  crapffm.vlmvtitg
                       aux_vlcheque[aux_indice] = aux_vlcheque[aux_indice] +
                                                  crapffm.vlcheque
                       aux_vltotdoc[aux_indice] = aux_vltotdoc[aux_indice] +
                                                  crapffm.vltotdoc
                       aux_vltotted[aux_indice] = aux_vltotted[aux_indice] +
                                                  crapffm.vltotted
                       aux_vltottit[aux_indice] = aux_vltottit[aux_indice] +
                                                  crapffm.vltottit
                       aux_vldevolu[aux_indice] = aux_vldevolu[aux_indice] +
                                                  crapffm.vldevolu
                       aux_vlttinss[aux_indice] = aux_vlttinss[aux_indice] +
                                                  crapffm.vlttinss
                       aux_vldivers[aux_indice] = aux_vldivers[aux_indice] +
                                                  crapffm.vlrepass         +
                                                  crapffm.vlnumera         +
                                                  crapffm.vlrfolha         +
                                                  crapffm.vloutros
                       aux_vlttcrdb[aux_indice] = aux_vlttcrdb[aux_indice] +
                                                  crapffm.vlmvtitg         +
                                                  crapffm.vlcheque         +
                                                  crapffm.vltotdoc         +
                                                  crapffm.vltotted         +
                                                  crapffm.vltottit         +
                                                  crapffm.vldevolu         +
                                                  crapffm.vlttinss         +
                                                  crapffm.vlrepass         +
                                                  crapffm.vlnumera         +
                                                  crapffm.vlrfolha         +
                                                  crapffm.vloutros.

             END.
          ELSE
             IF par_tpdmovto = 2 THEN
                DO:
                   
                   ASSIGN aux_vlmvtitg[aux_indice] = aux_vlmvtitg[aux_indice] +
                                                     crapffm.vlmvtitg
                          aux_vlcheque[aux_indice] = aux_vlcheque[aux_indice] +
                                                     crapffm.vlcheque
                          aux_vltotdoc[aux_indice] = aux_vltotdoc[aux_indice] +
                                                     crapffm.vltotdoc
                          aux_vltotted[aux_indice] = aux_vltotted[aux_indice] +
                                                     crapffm.vltotted
                          aux_vltottit[aux_indice] = aux_vltottit[aux_indice] +
                                                     crapffm.vltottit
                          aux_vldevolu[aux_indice] = aux_vldevolu[aux_indice] +
                                                     crapffm.vldevolu
                          aux_vlttinss[aux_indice] = aux_vlttinss[aux_indice] +
                                                     crapffm.vlttinss
                          aux_vldivers[aux_indice] = aux_vldivers[aux_indice] +
                                                     crapffm.vlrepass         +
                                                     crapffm.vlnumera         +
                                                     crapffm.vlrfolha         +
                                                     crapffm.vloutros
                          aux_vlttcrdb[aux_indice] = aux_vlttcrdb[aux_indice] +
                                                     crapffm.vlmvtitg         +
                                                     crapffm.vlcheque         +
                                                     crapffm.vltotdoc         +
                                                     crapffm.vltotted         +
                                                     crapffm.vltottit         +
                                                     crapffm.vldevolu         +
                                                     crapffm.vlttinss         +
                                                     crapffm.vlrepass         +
                                                     crapffm.vlnumera         +
                                                     crapffm.vlrfolha         +
                                                     crapffm.vloutros.
             
                 
                END.
      END.

  END.

  DO aux_contador = 1 TO 3:

     ASSIGN tt-ffin-mvto-cent.vlcheque[aux_contador] = 
                                      aux_vlcheque[aux_contador]
            tt-ffin-mvto-cent.vltotdoc[aux_contador] = 
                                      aux_vltotdoc[aux_contador]
            tt-ffin-mvto-cent.vltotted[aux_contador] = 
                                      aux_vltotted[aux_contador]
            tt-ffin-mvto-cent.vltottit[aux_contador] = 
                                      aux_vltottit[aux_contador]
            tt-ffin-mvto-cent.vldevolu[aux_contador] = 
                                      aux_vldevolu[aux_contador]
            tt-ffin-mvto-cent.vlmvtitg[aux_contador] = 
                                      aux_vlmvtitg[aux_contador]
            tt-ffin-mvto-cent.vlttinss[aux_contador] = 
                                      aux_vlttinss[aux_contador]
            tt-ffin-mvto-cent.vldivers[aux_contador] = 
                                      aux_vldivers[aux_contador]
            tt-ffin-mvto-cent.vlttcrdb[aux_contador] = 
                                      aux_vlttcrdb[aux_contador].

  END.

  RETURN "OK".


END PROCEDURE.


PROCEDURE busca_dados_fluxo_singular:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdmovto AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-ffin-mvto-sing.

    DEF VAR aux_indice AS INTE                                      NO-UNDO.

    EMPTY TEMP-TABLE tt-ffin-mvto-sing.

    CREATE tt-ffin-mvto-sing.

    ASSIGN tt-ffin-mvto-sing.cdbcoval[1] = 85
           tt-ffin-mvto-sing.cdbcoval[2] = 1
           tt-ffin-mvto-sing.cdbcoval[3] = 756
           tt-ffin-mvto-sing.cdbcoval[4] = 100
           tt-ffin-mvto-sing.tpdmovto    = par_tpdmovto.


    FOR EACH crapffm WHERE crapffm.cdcooper = par_cdcooper AND
                           crapffm.dtmvtolt = par_dtmvtolx AND
                           crapffm.tpdmovto = par_tpdmovto   
                           NO-LOCK:

        CASE crapffm.cdbccxlt:

              WHEN 85    THEN   ASSIGN aux_indice = 1.
              WHEN 1     THEN   ASSIGN aux_indice = 2.
              WHEN 756   THEN   ASSIGN aux_indice = 3.
              WHEN 100   THEN   ASSIGN aux_indice = 4.
              OTHERWISE NEXT.

        END CASE.

        IF par_tpdmovto = 1 THEN
           DO:
              ASSIGN tt-ffin-mvto-sing.vlcheque[aux_indice] = crapffm.vlcheque      
                     tt-ffin-mvto-sing.vltotdoc[aux_indice] = crapffm.vltotdoc      
                     tt-ffin-mvto-sing.vltotted[aux_indice] = crapffm.vltotted      
                     tt-ffin-mvto-sing.vltottit[aux_indice] = crapffm.vltottit      
                     tt-ffin-mvto-sing.vldevolu[aux_indice] = crapffm.vldevolu      
                     tt-ffin-mvto-sing.vlmvtitg[aux_indice] = crapffm.vlmvtitg      
                     tt-ffin-mvto-sing.vlttinss[aux_indice] = crapffm.vlttinss      
                     tt-ffin-mvto-sing.vltrdeit[aux_indice] = crapffm.vltrdeit   
                     tt-ffin-mvto-sing.vlsatait[aux_indice] = crapffm.vlsatait
                     tt-ffin-mvto-sing.vlrepass[aux_indice] = crapffm.vlrepass 
                     tt-ffin-mvto-sing.vlnumera[aux_indice] = crapffm.vlnumera 
                     tt-ffin-mvto-sing.vlrfolha[aux_indice] = crapffm.vlrfolha 
                     tt-ffin-mvto-sing.vloutros[aux_indice] = crapffm.vloutros 
                     tt-ffin-mvto-sing.vldivers[aux_indice] = crapffm.vlrepass + 
                                                              crapffm.vlnumera +
                                                              crapffm.vlrfolha + 
                                                              crapffm.vloutros
                     tt-ffin-mvto-sing.vlttcrdb[aux_indice] = crapffm.vlcheque + 
                                                              crapffm.vltotdoc +
                                                              crapffm.vltotted + 
                                                              crapffm.vltottit +  
                                                              crapffm.vlmvtitg +
                                                              crapffm.vlttinss + 
                                                              crapffm.vltrdeit +
                                                              crapffm.vlsatait + 
                                                              crapffm.vlrepass +
                                                              crapffm.vlnumera + 
                                                              crapffm.vlrfolha +
                                                              crapffm.vloutros + 
                                                              crapffm.vldevolu.
           END.
        ELSE
           DO:
              ASSIGN tt-ffin-mvto-sing.vlcheque[aux_indice] = crapffm.vlcheque      
                     tt-ffin-mvto-sing.vltotdoc[aux_indice] = crapffm.vltotdoc      
                     tt-ffin-mvto-sing.vltotted[aux_indice] = crapffm.vltotted      
                     tt-ffin-mvto-sing.vltottit[aux_indice] = crapffm.vltottit      
                     tt-ffin-mvto-sing.vldevolu[aux_indice] = crapffm.vldevolu      
                     tt-ffin-mvto-sing.vlmvtitg[aux_indice] = crapffm.vlmvtitg      
                     tt-ffin-mvto-sing.vlttinss[aux_indice] = crapffm.vlttinss 
                     tt-ffin-mvto-sing.vltrdeit[aux_indice] = crapffm.vltrdeit  
                     tt-ffin-mvto-sing.vlsatait[aux_indice] = crapffm.vlsatait  
                     tt-ffin-mvto-sing.vlfatbra[aux_indice] = crapffm.vlfatbra  
                     tt-ffin-mvto-sing.vlconven[aux_indice] = crapffm.vlconven  
                     tt-ffin-mvto-sing.vlrepass[aux_indice] = crapffm.vlrepass 
                     tt-ffin-mvto-sing.vlnumera[aux_indice] = crapffm.vlnumera 
                     tt-ffin-mvto-sing.vlrfolha[aux_indice] = crapffm.vlrfolha 
                     tt-ffin-mvto-sing.vloutros[aux_indice] = crapffm.vloutros
                     tt-ffin-mvto-sing.vldivers[aux_indice] = crapffm.vlrepass + 
                                                              crapffm.vlnumera +
                                                              crapffm.vlrfolha + 
                                                              crapffm.vloutros
                     tt-ffin-mvto-sing.vlttcrdb[aux_indice] = crapffm.vlcheque + 
                                                              crapffm.vltotdoc +
                                                              crapffm.vltotted + 
                                                              crapffm.vltottit +  
                                                              crapffm.vlmvtitg +
                                                              crapffm.vlttinss + 
                                                              crapffm.vltrdeit +
                                                              crapffm.vlsatait + 
                                                              crapffm.vlfatbra +
                                                              crapffm.vlconven + 
                                                              crapffm.vlrepass +
                                                              crapffm.vlnumera + 
                                                              crapffm.vlrfolha +
                                                              crapffm.vloutros + 
                                                              crapffm.vldevolu.
           END.

    END.

    RETURN "OK".

END PROCEDURE.

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

PROCEDURE pi_devolu_l_nr:

    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtdparam AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtliquid AS DATE                        NO-UNDO.

   
    /*** COMPE NOTURNA - DEVOLU ***/
    Lancamentos:
    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.dtmvtolt = par_dtliquid AND
                           CAN-DO("47,191,338,573",
                                 STRING(craplcm.cdhistor)) 
                           NO-LOCK:

        IF  craplcm.cdbanchq = 85  AND 
            craplcm.dsidenti = "1" /* noturna */ THEN
            ASSIGN tt-fluxo.vlchqnot = tt-fluxo.vlchqnot +
                                       craplcm.vllanmto.

    END. /* Fim Lancamentos */

    /*** COMPE DIRUNA - DEVOLU ***/
    Lancamentos:
    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.dtmvtolt = par_dtdparam AND
                           CAN-DO("47,191,338,573",
                                 STRING(craplcm.cdhistor)) 
                           NO-LOCK:

        CASE craplcm.cdbanchq:

            WHEN 85 THEN
                IF  craplcm.dsidenti = "2"   /* diurna */ THEN
                    ASSIGN tt-fluxo.vlchqdia = tt-fluxo.vlchqdia +
                                               craplcm.vllanmto.
        END CASE.

    END. /* Fim Lancamentos */

    RETURN "OK".

END PROCEDURE. /* pi_devolu_l_nr */

PROCEDURE pi_doc_f_nr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF  VAR aux_idbcoctl AS INTE                                   NO-UNDO.
    DEF  VAR aux_vlrdocnr AS DEC                                    NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    
    ASSIGN aux_vlrdocnr = 0
           aux_contador = 0.

    Transferencias:
    FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcoopex AND 
                           craptvl.dtmvtolt  = par_dtmvtolt AND 
                           craptvl.cdagenci >= par_cdagenci AND 
                           craptvl.cdagenci <= par_cdagefim AND 
                           craptvl.tpdoctrf <> 3 /* DOC */  
                           NO-LOCK:

        CASE craptvl.cdbcoenv:
               
            WHEN 85 THEN 
                 ASSIGN aux_vlrdocnr = aux_vlrdocnr     + 
                                       craptvl.vldocrcb.
                                            
            WHEN 0 THEN 
                 DO:
                    RUN pi_identifica_bcoctl (INPUT craptvl.cdcooper,
                                              INPUT craptvl.cdagenci,
                                              INPUT "D",
                                              OUTPUT aux_idbcoctl).
                
                    IF aux_idbcoctl = 1 THEN
                       ASSIGN aux_vlrdocnr = aux_vlrdocnr     +
                                             craptvl.vldocrcb.
                                  
                 END.

        END CASE.

    END. /* Fim Transferencias */

    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
    
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 2,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 2,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                 aux_vlrdocnr
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE. /* FIM pi_doc_f_nr */

PROCEDURE pi_doc_l_nr:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagefim AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtdparam AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_dtliquid AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_valorvlb AS DECI                            NO-UNDO.


    Transferencias:
    FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcooper AND
                           craptvl.dtmvtolt  = par_dtliquid AND
                           craptvl.cdagenci >= par_cdagenci AND
                           craptvl.cdagenci <= par_cdagefim AND
                           craptvl.tpdoctrf <> 3 /* DOC */  
                           NO-LOCK:

        IF  craptvl.vldocrcb >= par_valorvlb THEN
            ASSIGN tt-fluxo.vlcobbil = tt-fluxo.vlcobbil +
                                       craptvl.vldocrcb.
        ELSE
            ASSIGN tt-fluxo.vlcobmlt = tt-fluxo.vlcobmlt +
                                       craptvl.vldocrcb.

    END. /* Fim Transferencias*/

    RETURN "OK".

END PROCEDURE. /* pi_doc_l_nr */

PROCEDURE pi_tedtec_nr_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF  VAR aux_vlrtednr AS DEC                                    NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    
    ASSIGN aux_contador = 0
           aux_vlrtednr = 0.
            

    /* Verificar TED p/ estornos */
    Lancamentos:
    FOR EACH craplcs WHERE craplcs.cdcooper  = par_cdcoopex AND 
                           craplcs.dtmvtolt  = par_dtmvtolt AND 
                           craplcs.cdagenci >= par_cdagenci AND 
                           craplcs.cdagenci <= par_cdagefim 
                           NO-LOCK:
 
        IF craplcs.cdhistor = 827 THEN /* TEC ENVIADA PELA NOSSA IF */
           ASSIGN aux_vlrtednr = aux_vlrtednr     +
                                 craplcs.vllanmto.
                                          
       
    END. /* Fim Lancamentos */
        
    /* TED */
    Transferencias:
    FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcoopex AND 
                           craptvl.dtmvtolt  = par_dtmvtolt AND 
                           craptvl.cdagenci >= par_cdagenci AND 
                           craptvl.cdagenci <= par_cdagefim AND 
                           craptvl.tpdoctrf = 3 /* TED */   
                           NO-LOCK:

        CASE craptvl.cdbcoenv:
            
                
            WHEN 85  THEN aux_vlrtednr = aux_vlrtednr     +
                                         craptvl.vldocrcb.
                                                 
        END CASE.

    END. /* Fim Transferencias */
    
    /*** Desprezar TEC'S  e TED'S rejeitadas pela cabine da JD ***/
    Lancamentos:
    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcoopex AND
                           craplcm.dtmvtolt = par_dtmvtolt AND
                           craplcm.cdhistor = 887   
                           NO-LOCK:
                        
        ASSIGN aux_vlrtednr = aux_vlrtednr     - 
                              craplcm.vllanmto.
        

    END. /* Fim Lancamentos */

    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
          
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 2,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 3,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                 aux_vlrtednr
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.


    RETURN "OK".

    
END PROCEDURE. /* pi_tedtec_nr */  

PROCEDURE pi_titulos_f_nr:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_idbcoctl  AS INTE                                  NO-UNDO.
   DEF  VAR aux_vltitliq  AS DEC                                   NO-UNDO. 
   DEF  VAR aux_vlfatliq  AS DEC                                   NO-UNDO. 
   DEF  VAR aux_vlinss    AS DEC                                   NO-UNDO. 
   DEF  VAR aux_vlrtitnr  AS DEC                                   NO-UNDO.

                                                                
   ASSIGN aux_contador  = 0
          aux_vltitliq  = 0
          aux_vlfatliq  = 0
          aux_vlinss    = 0
          aux_idbcoctl  = 0
          aux_vlrtitnr  = 0.   

    
   FOR EACH craptit WHERE craptit.cdcooper  = par_cdcoopex       AND 
                          craptit.dtdpagto  = par_dtmvtolt       AND 
                          craptit.cdagenci >= par_cdagenci       AND 
                          craptit.cdagenci <= par_cdagefim       AND 
                          craptit.tpdocmto  = 20                 AND
                          craptit.intitcop  = 0                  AND
                          CAN-DO("2,4",STRING(craptit.insittit))
                          NO-LOCK:

       CASE craptit.cdbcoenv:
           
           WHEN 85 THEN
              ASSIGN aux_vlrtitnr = aux_vlrtitnr      +
                                    craptit.vldpagto.
           WHEN 0 THEN DO:

              RUN pi_identifica_bcoctl (INPUT craptit.cdcooper,
                                        INPUT craptit.cdagenci,
                                        INPUT "T",
                                        OUTPUT aux_idbcoctl).

              IF aux_idbcoctl = 1 THEN
                 ASSIGN aux_vlrtitnr = aux_vlrtitnr     +
                                       craptit.vldpagto.

           END.
               
       
       END CASE.

   END.

   FIND craptab WHERE craptab.cdcooper = par_cdcoopex     AND
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "GENERI"         AND
                      craptab.cdempres = 00               AND
                      craptab.cdacesso = "PARFLUXOFINAN"  AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF AVAIL craptab THEN
      ASSIGN aux_vlrtitnr = aux_vlrtitnr + 
                          ((aux_vlrtitnr * 
                            DECIMAL(ENTRY(3,craptab.dstextab,";"))) / 100).


   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 4,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                aux_vlrtitnr
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".


   END.

   ASSIGN aux_contador = 0 
          aux_vlrtitnr = 0.
                
   FOR EACH craprcb WHERE 
            craprcb.cdcooper = par_cdcoopex AND
            craprcb.dtmvtolt = par_dtmvtoan AND
           (craprcb.cdtransa = "268"        OR   /* Titulos */
            craprcb.cdtransa = "358"        OR   /* Faturas */
            craprcb.cdtransa = "284")       AND  /* Recebto INSS */
            craprcb.cdagenci <> 9999     /* Totais dias anteriores */
            NO-LOCK:
   
       /* para resumo do banco do brasil */    
       IF craprcb.cdtransa = "268"  THEN   /* Titulos */
          DO:
             IF craprcb.flgrgatv = YES THEN
                ASSIGN aux_vltitliq = aux_vltitliq     + 
                                      craprcb.valorpag.
          END.
       ELSE
         DO:                                                            
             IF craprcb.cdtransa = "358" THEN    /* Faturas */
                DO: 
                   IF craprcb.flgrgatv = YES THEN 
                      ASSIGN aux_vlfatliq = aux_vlfatliq     + 
                                            craprcb.valorpag.

                END.
             ELSE
                DO:
                   IF craprcb.flgrgatv = YES THEN
                      ASSIGN aux_vlinss = aux_vlinss       +  
                                          craprcb.valorpag.

                END.    
       
         END.

   END.

   ASSIGN aux_vlrtitnr = (aux_vltitliq + aux_vlfatliq) - (aux_vlinss).
              
   RUN grava-movimentacao(INPUT par_cdcoopex,
                          INPUT par_cdoperad,
                          INPUT par_dtmvtolt,
                          INPUT 2,
                          INPUT 01,
                          INPUT 4,
                          INPUT aux_vlrtitnr).
   
   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".


   RETURN "OK".


END PROCEDURE.

PROCEDURE pi_titulos_l_nr:

    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagefim AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtdparam AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtliquid AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_valorvlb AS DECI                        NO-UNDO.

    
    Titulos:
    FOR EACH craptit WHERE craptit.cdcooper  = par_cdcooper AND 
                           craptit.dtdpagto  = par_dtliquid AND 
                           craptit.cdagenci >= par_cdagenci AND 
                           craptit.cdagenci <= par_cdagefim AND 
                           craptit.tpdocmto  = 20           AND
                           craptit.intitcop  = 0            AND
                           CAN-DO("2,4",STRING(craptit.insittit))
                           NO-LOCK:

        IF  craptit.vldpagto >= par_valorvlb THEN
            ASSIGN tt-fluxo.vlcobbil = tt-fluxo.vlcobbil +
                                       craptit.vldpagto.
        ELSE
            ASSIGN tt-fluxo.vlcobmlt = tt-fluxo.vlcobmlt +
                                       craptit.vldpagto.

    END. /* Fim Titulos */

    RETURN "OK".

END PROCEDURE. /* pi_titulos_l_nr */

PROCEDURE pi_cheques_f_nr:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.


    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"          NO-UNDO.
    DEF  VAR aux_vlrchenr AS DEC                                NO-UNDO.
    DEF  VAR aux_contador AS INT                                NO-UNDO.
    DEF  VAR aux_idbcoctl AS INTE                               NO-UNDO.

    ASSIGN aux_vlrchenr = 0
           aux_contador = 0.
    
    Cheques:
    FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcoopex       AND
                           crapchd.dtmvtolt  = par_dtmvtolt       AND 
                           crapchd.cdagenci >= par_cdagenci       AND 
                           crapchd.cdagenci <= par_cdagefim       AND 
                           CAN-DO("0,2",STRING(crapchd.insitchq)) AND
                           crapchd.inchqcop  = 0                  
                           NO-LOCK:

           
        CASE crapchd.cdbcoenv:
            
            WHEN 85  THEN
                ASSIGN aux_vlrchenr = aux_vlrchenr + 
                                      crapchd.vlcheque.                        
            WHEN 0   THEN 
                DO:
                    RUN pi_identifica_bcoctl
                        (INPUT crapchd.cdcooper,
                         INPUT crapchd.cdagenci,
                         INPUT "C",
                         OUTPUT aux_idbcoctl).
                    
                    IF aux_idbcoctl = 1 THEN
                       ASSIGN aux_vlrchenr = aux_vlrchenr + 
                                             crapchd.vlcheque.
                END.

        END CASE.    
           

    END. 
    
    
    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
       
       
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 1,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                 aux_vlrchenr
                              ELSE
                                 0)).
       
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi_cheques_l_nr:
    
    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagefim AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtdparam AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtliquid AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtliqui2 AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_valorchq AS DECI                        NO-UNDO.

    DEF VAR aux_idbcoctl AS INTE                                NO-UNDO.

    
    FOR FIRST crapage FIELDS(cdcomchq) 
        WHERE crapage.cdcooper = crapcop.cdcooper AND
              crapage.flgdsede = YES 
              NO-LOCK: 
        
    END.

    /* Se nao houver Coop como Sede, NEXT */
    IF NOT AVAILABLE crapage THEN 
       RETURN.

    /*** COMPE 16 (D - 1) ***/
    Cheques:
    FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper AND 
                           crapchd.dtmvtolt  = par_dtliquid AND 
                           crapchd.cdagenci >= par_cdagenci AND 
                           crapchd.cdagenci <= par_cdagefim AND 
                           CAN-DO("0,2",
                                  STRING(crapchd.insitchq)) AND
                           crapchd.inchqcop  = 0
                           NO-LOCK:
        
        /* Se for DIFERENTE => NACIONAL (DESCONSIDERA) */
        IF  crapage.cdcomchq <> crapchd.cdcmpchq THEN 
            NEXT Cheques.

        IF  crapchd.vlcheque >= par_valorchq THEN
            ASSIGN tt-fluxo.vlchqnot = tt-fluxo.vlchqnot +
                                       crapchd.vlcheque.
        ELSE
            ASSIGN tt-fluxo.vlchqdia = tt-fluxo.vlchqdia +
                                       crapchd.vlcheque.
    END. /* Fim Cheques */

    /*** COMPE NACIONAL (D - 2) ***/
    Cheques:
    FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper  AND
                           crapchd.dtmvtolt  = par_dtliqui2  AND
                           crapchd.cdagenci >= par_cdagenci  AND 
                           crapchd.cdagenci <= par_cdagefim  AND 
                           CAN-DO("0,2",
                                  STRING(crapchd.insitchq))  AND
                           crapchd.inchqcop  = 0
                           NO-LOCK:

        /* Se for IGUAL => COMPE16 (DESCONSIDERA) */
        IF  crapage.cdcomchq = crapchd.cdcmpchq THEN 
            NEXT Cheques.

        IF  crapchd.vlcheque >= par_valorchq THEN
            ASSIGN tt-fluxo.vlchqnot = tt-fluxo.vlchqnot +
                                       crapchd.vlcheque.
        ELSE
            ASSIGN tt-fluxo.vlchqdia = tt-fluxo.vlchqdia +
                                       crapchd.vlcheque.

    END. /* Fim Cheques */      

    RETURN "OK".

END PROCEDURE. /* pi_cheques_l_nr */


PROCEDURE pi_identifica_bcoctl:

    DEF  INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_idtblida AS CHAR                       NO-UNDO.

    DEF OUTPUT PARAM aux_idbcoctl AS INTE                       NO-UNDO.

    DEF VAR aux_cdbcoenv AS INTE                                NO-UNDO.

    ASSIGN aux_idbcoctl = 0
           aux_cdbcoenv = 0. 

    FOR FIRST crapage FIELDS(cdbantit cdbandoc cdbanchq)
        WHERE crapage.cdcooper = par_cdcooper AND 
              crapage.cdagenci = par_cdagenci 
              NO-LOCK: 
        
    END.

    IF  AVAIL crapage THEN 
        DO:
            CASE par_idtblida:

                WHEN "T" THEN ASSIGN aux_cdbcoenv = crapage.cdbantit.
                WHEN "D" THEN ASSIGN aux_cdbcoenv = crapage.cdbandoc.
                WHEN "C" THEN ASSIGN aux_cdbcoenv = crapage.cdbanchq.

            END CASE.

            CASE aux_cdbcoenv:

                WHEN 85   THEN ASSIGN aux_idbcoctl = 1.
                WHEN 1    THEN ASSIGN aux_idbcoctl = 2.
                WHEN 756  THEN ASSIGN aux_idbcoctl = 3.

            END CASE.

        END.

    RETURN "OK".


END PROCEDURE. /* pi_identifica_bcoctl */

PROCEDURE pi_calcula_datas:

    DEF INPUT  PARAM par_cdcooper AS INTE                          NO-UNDO.
    DEF INPUT  PARAM par_dtdatela AS DATE                          NO-UNDO.

    DEF OUTPUT PARAM par_flferiad AS LOGI                          NO-UNDO.
    DEF OUTPUT PARAM par_dtliquid AS DATE                          NO-UNDO.
    DEF OUTPUT PARAM par_dtliqui2 AS DATE                          NO-UNDO.
    
    IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtdatela)))             OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                               crapfer.dtferiad = par_dtdatela) THEN
        ASSIGN par_flferiad = TRUE.
    ELSE
        DO:    
            ASSIGN par_flferiad = FALSE
                   par_dtliquid = par_dtdatela - 1.

            DO WHILE TRUE:

                IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtliquid)))             OR
                    CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                           crapfer.dtferiad = par_dtliquid) THEN
                    DO:
                        ASSIGN par_dtliquid = par_dtliquid - 1.
                        NEXT.
                    END.

                LEAVE.
            
            END. /* Fim do DO WHILE TRUE */

            ASSIGN par_dtliqui2 = par_dtliquid - 1.

            DO WHILE TRUE:

                IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtliqui2)))             OR
                    CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                           crapfer.dtferiad = par_dtliqui2) THEN
                    DO:
                        ASSIGN par_dtliqui2 = par_dtliqui2 - 1.
                        NEXT.
                    END.

                LEAVE.

            END.   /* Fim do DO WHILE TRUE */

        END.    

    RETURN "OK".

END PROCEDURE. /* pi_calcula_datas */


PROCEDURE pi_sr_ted_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_vlrtedsr AS DEC                                    NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    DEF  VAR h-b1wgen0050 AS HANDLE                                 NO-UNDO.

    ASSIGN aux_vlrtedsr = 0
           aux_contador = 0.

    IF NOT VALID-HANDLE(h-b1wgen0050) THEN
       RUN sistema/generico/procedures/b1wgen0050.p 
           PERSISTENT SET h-b1wgen0050.

    RUN atualiza_tabela_erros (INPUT par_cdcooper,
                               INPUT FALSE).

    RUN obtem-log-cecred IN h-b1wgen0050 (INPUT par_cdcoopex,
                                          INPUT par_cdagenci,
                                          INPUT 0,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT 0,   /* TODOS */
                                          INPUT par_dtmvtolt,
                                          INPUT par_dtmvtolt,
                                          INPUT 2,   /* RECEBIDAS */
                                          INPUT "P", /* Processadas */
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT 1,
                                          INPUT 99999,
                                          INPUT 0, /* par_vlrdated */
                                          INPUT 0, /* inestcri, 0 Nao, 1 Sim */                                          
                                          INPUT 3,  /* IF da TED - Todas */
                                          OUTPUT TABLE tt-logspb,
                                          OUTPUT TABLE tt-logspb-detalhe,
                                          OUTPUT TABLE tt-logspb-totais,
                                          OUTPUT TABLE tt-erro).

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST tt-logspb-totais NO-LOCK NO-ERROR.

    IF AVAIL tt-logspb-totais THEN
       ASSIGN aux_vlrtedsr = tt-logspb-totais.vlrrecok.
    ELSE
       ASSIGN aux_vlrtedsr = 0.


    IF VALID-HANDLE(h-b1wgen0050) THEN
       DELETE OBJECT h-b1wgen0050.
    

    RUN atualiza_tabela_erros (INPUT par_cdcooper,
                               INPUT TRUE).


    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
        
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 3,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                 aux_vlrtedsr
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.

    RETURN "OK".


END PROCEDURE. 


PROCEDURE pi_dev_cheques_rem_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
    
    DEF  VAR aux_vlrttdev AS DECI                                   NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    DEF  VAR aux_vldevolu AS DECI                                   NO-UNDO.
    DEF  VAR aux_valorvlb AS DECI                                   NO-UNDO.

    ASSIGN aux_vlrttdev = 0
           aux_contador = 0.

    /* No crps624 executa após limpeza da crapdev usar este para o mesmo */
    IF   par_nmdatela <> "PREVIS" THEN
         DO: 
            FOR EACH gncpdev WHERE gncpdev.cdcooper  = par_cdcoopex   AND
                                   gncpdev.dtmvtolt  = par_dtmvtoan   AND
                                   gncpdev.cdbanchq  = 85             AND
                                   (gncpdev.cdtipreg = 1 OR gncpdev.cdtipreg = 2)              
                                   NO-LOCK:
        
                ASSIGN aux_vlrttdev  = aux_vlrttdev  + gncpdev.vlcheque.
            END.
                
         END.
    ELSE
         DO: /* Cooperativa precisa saber o valor antes da criação do gncpdev 
             Feito como no relatório 219 crps264 */
            FIND crapcop WHERE crapcop.cdcooper = par_cdcoopex NO-LOCK NO-ERROR.
            IF NOT AVAIL crapcop THEN
               RETURN "NOK".
        
            FIND craptab WHERE craptab.cdcooper = par_cdcoopex  AND
                               craptab.nmsistem = "CRED"        AND
                               craptab.tptabela = "GENERI"      AND
                               craptab.cdempres = 0             AND
                               craptab.cdacesso = "VALORESVLB"  AND
                               craptab.tpregist = 0             
                               NO-LOCK NO-ERROR.
            IF NOT AVAIL craptab THEN
               RETURN "NOK".
        
            ASSIGN aux_vldevolu = DECIMAL(ENTRY(3, craptab.dstextab, ";"))
                   aux_valorvlb = DECIMAL(ENTRY(2, craptab.dstextab, ";")).
                
            FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcoopex     AND
                                   crapdev.cdbanchq = crapcop.cdbcoctl AND
                                   crapdev.insitdev = 1                AND
                                   crapdev.cdhistor <> 46              AND
                                   crapdev.cdalinea > 0                NO-LOCK
                                   BY crapdev.nrctachq
                                   BY crapdev.nrcheque:
            
                IF crapdev.nrdconta = 0 THEN
                   DO:
                        CASE crapdev.indevarq:
                             WHEN 1 THEN 
                                   ASSIGN aux_vlrttdev = aux_vlrttdev + crapdev.vllanmto.
                             WHEN 2 THEN 
                                IF   crapdev.vllanmto < aux_valorvlb THEN
                                     ASSIGN aux_vlrttdev = aux_vlrttdev + crapdev.vllanmto.
                        END CASE.     
                   END.
                ELSE
                   IF   crapdev.cdpesqui = "" THEN
                        DO:
                            FIND LAST gncpchq WHERE 
                                      gncpchq.cdcooper = par_cdcoopex     AND
                                      gncpchq.dtmvtolt = par_dtmvtoan     AND
                                      gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                      gncpchq.cdagechq = crapcop.cdagectl AND
                                      gncpchq.nrctachq = crapdev.nrdconta AND
                                      gncpchq.nrcheque = crapdev.nrcheque AND
                                     (gncpchq.cdtipreg = 3                OR
                                      gncpchq.cdtipreg = 4)               AND
                                      gncpchq.vlcheque = crapdev.vllanmto
                                      NO-LOCK NO-ERROR.
                                               
                            IF   NOT AVAILABLE gncpchq THEN
                                 NEXT.
                        END.
                   ELSE
                        IF   crapdev.cdpesqui = "TCO" THEN /* Contas transferidas */
                             DO: /* Tabela de contas transferidas entre cooperativas */
                                 FIND craptco WHERE craptco.cdcopant = crapdev.cdcooper AND
                                                    craptco.nrctaant = crapdev.nrdconta AND
                                                    craptco.tpctatrf = 1 /* 1 = C/C */  AND
                                                    craptco.flgativo = TRUE
                                                    NO-LOCK NO-ERROR.
            
                                 IF   NOT AVAILABLE craptco THEN
                                      NEXT.
                                 
                                 FIND LAST gncpchq WHERE 
                                           gncpchq.cdcooper = craptco.cdcopant AND
                                           gncpchq.dtmvtolt = par_dtmvtoan     AND
                                           gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                           gncpchq.cdagechq = crapcop.cdagectl AND
                                           gncpchq.nrctachq = craptco.nrctaant AND
                                           gncpchq.nrcheque = crapdev.nrcheque AND
                                          (gncpchq.cdtipreg = 3                OR
                                           gncpchq.cdtipreg = 4)               AND
                                           gncpchq.vlcheque = crapdev.vllanmto
                                           NO-LOCK NO-ERROR.
                                               
                                 IF   NOT AVAILABLE gncpchq THEN
                                      NEXT.
                             END.
            
                IF   crapdev.cdpesqui <> ""    AND                          
                     crapdev.cdpesqui <> "TCO" THEN
                     NEXT.
                 ELSE
                     DO:
                        CASE crapdev.indevarq:
                                 WHEN 1 THEN 
                                      ASSIGN aux_vlrttdev = aux_vlrttdev + crapdev.vllanmto.
                   
                                 WHEN 2 THEN 
                                 DO: 
                                    IF crapdev.vllanmto < aux_valorvlb THEN
                                       ASSIGN aux_vlrttdev = aux_vlrttdev + crapdev.vllanmto.
                                 END.
                        END CASE.     
                     END.
            END.
    END.
     
    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
    
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 5,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                 aux_vlrttdev
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE. /* FIM  pi_dev_cheques_f_rem */


PROCEDURE pi_rec_mov_conta_itg_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
     
    DEF  VAR aux_maiorvlr AS DECI INIT 0                            NO-UNDO.
    DEF  VAR aux_vlrttdev AS DECI                                   NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    DEF  VAR aux_vlrmedia AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
    
    ASSIGN aux_vlrttdev = 0
           aux_contador = 0
           aux_vlrmedia = 0.


    RUN gera-periodos-projecao-itg(INPUT par_cdcoopex,
                                   INPUT par_dtmvtolt,
                                   INPUT 1,
                                   OUTPUT TABLE tt-per-datas).


    FOR EACH tt-per-datas WHERE tt-per-datas.dtmvtolt >= 09/01/2011 
                                BREAK BY tt-per-datas.cdagrupa:
                        
        FOR EACH craplcm 
            WHERE craplcm.cdcooper = par_cdcoopex                    AND
                  CAN-DO("170,646,314,584,651,169,444,662,191,694", 
                         STRING(craplcm.cdhistor))                   AND
                  craplcm.dtmvtolt = tt-per-datas.dtmvtolt 
                  NO-LOCK:
            
            ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + 
                                           craplcm.vllanmto.

        
        END.
        
        IF tt-per-datas.vlrtotal > aux_maiorvlr THEN
           aux_maiorvlr = tt-per-datas.vlrtotal.

        ASSIGN aux_vlrttdev = aux_vlrttdev + tt-per-datas.vlrtotal
               aux_contador = aux_contador + 1.

        IF LAST-OF(tt-per-datas.cdagrupa) THEN
           DO:
              IF (aux_contador > 1) THEN  
                 ASSIGN aux_vlrttdev = aux_vlrttdev - aux_maiorvlr
                        aux_vlrmedia = aux_vlrmedia + (aux_vlrttdev  / (aux_contador - 1)).
             ELSE 
                 ASSIGN aux_vlrttdev = aux_maiorvlr
                        aux_vlrmedia = aux_vlrmedia + (aux_vlrttdev  / (aux_contador)).
              
              ASSIGN aux_vlrttdev = 0 
                     aux_contador = 0
                     aux_maiorvlr = 0.

           END.

    END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper         AND
                            craptab.nmsistem = "CRED"          AND
                            craptab.tptabela = "GENERI"        AND
                            craptab.cdempres = 00              AND
                            craptab.cdacesso = "PARFLUXOFINAN" AND
                            craptab.tpregist = 0
                            NO-LOCK NO-ERROR.
         
         IF AVAIL craptab THEN
            ASSIGN aux_vlrmedia = aux_vlrmedia + 
                                ((aux_vlrmedia * 
                                  DECIMAL(ENTRY(6,craptab.dstextab,";"))) / 100).

    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
    
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 6,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "01" THEN
                                 aux_vlrmedia
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.


    RETURN "OK".


END PROCEDURE. 


PROCEDURE pi_inss_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF  VAR aux_vlttlicr AS DECI                                   NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    
    
    ASSIGN aux_vlttlicr = 0
           aux_contador = 0.
    

    FOR EACH craplbi WHERE craplbi.cdcooper = par_cdcoopex AND
                           craplbi.cdagenci >= 1           AND
                           craplbi.cdagenci <= 99999       AND
                           craplbi.dtdpagto = par_dtmvtolt
                           NO-LOCK:
    
    
        ASSIGN aux_vlttlicr = aux_vlttlicr     + 
                              craplbi.vlliqcre.
    
    END.
    
    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
    
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 7,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "756" THEN
                                 aux_vlttlicr
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.

    
    RETURN "OK".


END PROCEDURE. 


PROCEDURE pi_rec_transf_dep_intercoop_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF  VAR aux_vltsfcop AS DECI                                   NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    
    
    ASSIGN aux_vltsfcop = 0
           aux_contador = 0.
    

    /* Credito deposito/transferencia/tec salario intercooperativo */
    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcoopex  AND
                           craplcm.dtmvtolt = par_dtmvtolt  AND
                          (craplcm.cdhistor = 1004          OR
                           craplcm.cdhistor = 1011          OR
                           craplcm.cdhistor = 1022)         NO-LOCK:
                           
        ASSIGN aux_vltsfcop = aux_vltsfcop + craplcm.vllanmto.

    END.
    
    
    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
    
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 8,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                 aux_vltsfcop
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".


    END.

    
    RETURN "OK".


END PROCEDURE. 


PROCEDURE pi_rec_saq_taa_intercoop_f:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

    DEF  VAR aux_vlsaqtaa AS DECI                                   NO-UNDO.
    DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
    DEF  VAR aux_contador AS INT                                    NO-UNDO.
    DEF  VAR h-b1wgen0025 AS HANDLE                                 NO-UNDO.  
    
    ASSIGN aux_vlsaqtaa = 0
           aux_contador = 0.
    

    IF NOT VALID-HANDLE(h-b1wgen0025) THEN
       RUN sistema/generico/procedures/b1wgen0025.p 
           PERSISTENT SET h-b1wgen0025.
   
    RUN busca_movto_saque_cooperativa IN h-b1wgen0025(INPUT 0,
                                                      INPUT par_cdcoopex,
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_dtmvtolt,
                                                      INPUT 1,
                                                      OUTPUT TABLE tt-lancamentos).
    
    IF VALID-HANDLE(h-b1wgen0025) THEN
       DELETE PROCEDURE h-b1wgen0025.
   
    FOR EACH tt-lancamentos NO-LOCK:
   
        ASSIGN aux_vlsaqtaa = aux_vlsaqtaa + tt-lancamentos.vlrtotal.
   
    END.
   
    
    DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
    
       RUN grava-movimentacao 
                      (INPUT par_cdcoopex,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT 1,
                       INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                       INPUT 9,
                       INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                 aux_vlsaqtaa
                              ELSE
                                 0)).
       
       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

    END.

    
    RETURN "OK".


END PROCEDURE. 


PROCEDURE pi_rem_mov_conta_itg_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vlrttdev  AS DECI                                  NO-UNDO.
   DEF  VAR aux_vlrmedia  AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"    NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vlrttdev = 0
          aux_vlrmedia = 0.


    RUN gera-periodos-projecao-itg(INPUT par_cdcoopex,
                                   INPUT par_dtmvtolt,
                                   INPUT 1,
                                   OUTPUT TABLE tt-per-datas).


    FOR EACH tt-per-datas WHERE tt-per-datas.dtmvtolt >= 09/01/2011 
                                BREAK BY tt-per-datas.cdagrupa:
                        
        FOR EACH craplcm 
            WHERE craplcm.cdcooper = par_cdcoopex                 AND
                  CAN-DO("297,290,614,658,613,668,471,661,50,59", 
                         STRING(craplcm.cdhistor))                AND
                  craplcm.dtmvtolt = tt-per-datas.dtmvtolt 
                  NO-LOCK:
                
            ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + 
                                           craplcm.vllanmto.
            
        END.
        
    
        ASSIGN aux_vlrttdev = aux_vlrttdev + tt-per-datas.vlrtotal
               aux_contador = aux_contador + 1.

        IF LAST-OF(tt-per-datas.cdagrupa) THEN
           DO:
              ASSIGN aux_vlrmedia = aux_vlrmedia  + 
                                   (aux_vlrttdev  / aux_contador).
                     aux_vlrttdev = 0.
                     aux_contador = 0.

           END.

    END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper         AND
                            craptab.nmsistem = "CRED"          AND
                            craptab.tptabela = "GENERI"        AND
                            craptab.cdempres = 00              AND
                            craptab.cdacesso = "PARFLUXOFINAN" AND
                            craptab.tpregist = 0
                            NO-LOCK NO-ERROR.
         
         IF AVAIL craptab THEN
            ASSIGN aux_vlrmedia = aux_vlrmedia + 
                                ((aux_vlrmedia * 
                                  DECIMAL(ENTRY(7,craptab.dstextab,";"))) / 100).
   
   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 6,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "01" THEN
                                aux_vlrmedia
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

   END.


   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_gps_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vltitrec  AS DECI                                  NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vltitrec = 0.

   FOR EACH craplgp WHERE craplgp.cdcooper  = par_cdcoopex AND
                          craplgp.dtmvtolt  = par_dtmvtolt AND 
                          craplgp.cdagenci >= 1            AND
                          craplgp.cdagenci <= 9999         AND     
                          craplgp.nrdcaixa >= 1            AND
                          craplgp.nrdcaixa <= 9999        
                          NO-LOCK:
       
       ASSIGN aux_vltitrec = aux_vltitrec     + 
                             craplgp.vlrtotal. 
                
   
   END.  /*  Fim do FOR EACH  */
   
   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 7,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "756" THEN
                                aux_vltitrec
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".


   END.


   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_rem_transf_dep_intercoop_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   
   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vlrtsfns  AS DECI                                  NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vlrtsfns = 0.

   /* Debito deposito intercooperativo */
   FOR EACH craplcm WHERE craplcm.cdcooper <> par_cdcoopex AND
                          craplcm.dtmvtolt = par_dtmvtolt  AND
                          craplcm.cdcoptfn = par_cdcoopex  AND
                          craplcm.cdhistor = 1004
                          NO-LOCK:
       
       ASSIGN aux_vlrtsfns = aux_vlrtsfns     +
                             craplcm.vllanmto.
                        
   END.
                      
   /* Debito transferencia/tec salario intercooperativo */
   FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcoopex AND
                          craplcm.dtmvtolt = par_dtmvtolt AND
                         (craplcm.cdhistor = 1009         OR
                          craplcm.cdhistor = 1018)
                         NO-LOCK:
       
       ASSIGN aux_vlrtsfns = aux_vlrtsfns     +
                             craplcm.vllanmto.
       
   END.
   
   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 8,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                aux_vlrtsfns
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".
      

   END.


   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_rem_saq_taa_intercoop_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   
   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vlsaqtaa  AS DECI                                  NO-UNDO.
   DEF  VAR h-b1wgen0025  AS HANDLE                                NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vlsaqtaa = 0.


   IF NOT VALID-HANDLE(h-b1wgen0025) THEN
      RUN sistema/generico/procedures/b1wgen0025.p
          PERSISTENT SET h-b1wgen0025.

   RUN busca_movto_saque_cooperativa IN h-b1wgen0025(INPUT par_cdcoopex,
                                                     INPUT 0,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtolt,
                                                     INPUT 1,
                                                     OUTPUT TABLE tt-lancamentos).
   
   IF VALID-HANDLE(h-b1wgen0025) THEN
      DELETE PROCEDUR h-b1wgen0025.

   FOR EACH tt-lancamentos NO-LOCK:

       ASSIGN aux_vlsaqtaa = aux_vlsaqtaa + tt-lancamentos.vlrtotal.

   END.
   
   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 9,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                aux_vlsaqtaa
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".


   END.


   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_rem_fatura_bradesco_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   
   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vlremfat  AS DECI                                  NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vlremfat = 0.

  
   FOR EACH craplau WHERE craplau.cdcooper = par_cdcoopex AND
                          craplau.cdhistor = 293          AND
                          craplau.dtmvtopg = par_dtmvtolt
                          NO-LOCK:
   
       ASSIGN aux_vlremfat = aux_vlremfat      + 
                             craplau.vllanaut.

   
   END.


   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 10,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                aux_vlremfat
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

   END.


   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_convenios_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vlrconve  AS DECI                                  NO-UNDO.
   DEF  VAR aux_qtregist  AS INT                                   NO-UNDO.

   DEF VAR h-b1wgen0101 AS HANDLE                                  NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vlrconve = 0
          aux_qtregist = 0.

  
   IF NOT VALID-HANDLE(h-b1wgen0101) THEN
      RUN sistema/generico/procedures/b1wgen0101.p 
          PERSISTENT SET h-b1wgen0101.

   RUN atualiza_tabela_erros (INPUT par_cdcooper,
                              INPUT FALSE).

   RUN consulta_faturas IN h-b1wgen0101 (INPUT par_cdcoopex,
                                         INPUT par_dtmvtolt,
                                         INPUT 0,
                                         INPUT par_dtmvtolt,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT FALSE,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT FALSE,
                                         OUTPUT aux_qtregist,
                                         OUTPUT aux_vlrconve,
                                         OUTPUT TABLE tt-dados-pesqti,
                                         OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0101) THEN
      DELETE OBJECT h-b1wgen0101.
                  
   EMPTY TEMP-TABLE tt-erro.

   RUN atualiza_tabela_erros (INPUT par_cdcooper,
                              INPUT TRUE).

   IF RETURN-VALUE <> "OK" THEN
      DO:
          IF VALID-HANDLE(h-b1wgen0101) THEN
             DELETE OBJECT h-b1wgen0101.

          RETURN "NOK".

      END.

  

   /* Débito automatico */
   FOR EACH gncvcop WHERE gncvcop.cdcooper = par_cdcoopex NO-LOCK,

       FIRST gnconve WHERE gnconve.cdconven = gncvcop.cdconven AND
                           gnconve.flgativo = YES              AND
                           gnconve.cdconven <> 39              AND
                           gnconve.cdhisdeb > 0                NO-LOCK: 


       FOR EACH craplcm WHERE (craplcm.cdcooper = par_cdcoopex AND
                               craplcm.dtmvtolt = par_dtmvtolt     AND   
                               craplcm.cdhistor = gnconve.cdhisdeb) NO-LOCK:
                           
                           
            ASSIGN aux_vlrconve = aux_vlrconve + craplcm.vllanmto.
       END.                        
    
   END.
   
   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 11,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                aux_vlrconve
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".


   END.


   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_dev_cheques_rec_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_vldevchq  AS DECI                                  NO-UNDO.
   DEF  VAR aux_idbcoctl  AS INTE                                  NO-UNDO.

   DEF  VAR aux_dscritic  AS CHAR                                  NO-UNDO.

   ASSIGN aux_contador = 0
          aux_vldevchq = 0
          aux_idbcoctl = 0
          aux_dscritic = "".


   FIND craptab WHERE craptab.cdcooper = par_cdcoopex     AND
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "GENERI"         AND
                      craptab.cdempres = 00               AND
                      craptab.cdacesso = "PARFLUXOFINAN"  AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

    IF AVAIL craptab THEN
       DO:
          IF DECIMAL(ENTRY(5,craptab.dstextab,";")) > 0 THEN
             DO:
                FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcoopex       AND
                                       crapchd.dtmvtolt  = par_dtmvtoan       AND 
                                       crapchd.cdagenci >= par_cdagenci       AND 
                                       crapchd.cdagenci <= par_cdagefim       AND 
                                       CAN-DO("0,2",STRING(crapchd.insitchq)) AND
                                       crapchd.inchqcop  = 0
                                       NO-LOCK:
              
                    CASE crapchd.cdbcoenv:
              
                        WHEN 85  THEN
                            ASSIGN aux_vldevchq = aux_vldevchq + 
                                                  crapchd.vlcheque.
              
                        WHEN 0   THEN 
                            DO:
                                RUN pi_identifica_bcoctl 
                                                  (INPUT crapchd.cdcooper,
                                                   INPUT crapchd.cdagenci,
                                                   INPUT "C",
                                                   OUTPUT aux_idbcoctl).
                                 
                                 IF aux_idbcoctl = 1 THEN
                                    ASSIGN aux_vldevchq = aux_vldevchq + 
                                                          crapchd.vlcheque.
              
                            END.
              
                    END CASE.
              
                END. 

                ASSIGN aux_vldevchq = ((aux_vldevchq * 
                              DECIMAL(ENTRY(5,craptab.dstextab,";"))) / 100).
              
             END.
          ELSE
             DO:
                FIND LAST tt-erro NO-LOCK NO-ERROR.
         
                IF AVAIL tt-erro THEN
                   ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
                ELSE
                   ASSIGN aux_nrsequen = aux_nrsequen + 1.
         
                ASSIGN aux_dscritic = "Base de calculo devolucao de " + 
                                      "cheques nao informada.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT aux_nrsequen,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
         
             END.
            
       END.

   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):

      RUN grava-movimentacao 
                     (INPUT par_cdcoopex,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 5,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                aux_vldevchq
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".
              
   END.
          
   RETURN "OK".

END PROCEDURE.
              

PROCEDURE grava_consolidado_singular:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_tpdcampo AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_vldcampo AS DECI                            NO-UNDO.
    

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:


        FIND crapffc WHERE crapffc.cdcooper = par_cdcooper AND
                           crapffc.dtmvtolt = par_dtmvtolt   
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL crapffc THEN
           DO:
               CREATE crapffc.

               ASSIGN crapffc.cdcooper = par_cdcooper
                      crapffc.dtmvtolt = par_dtmvtolt.

           END.

        CASE par_tpdcampo:

            WHEN  0   THEN LEAVE.
            WHEN  1   THEN ASSIGN crapffc.vlentrad = par_vldcampo.
            WHEN  2   THEN ASSIGN crapffc.vlsaidas = par_vldcampo.
            WHEN  3   THEN ASSIGN crapffc.vlsldcta = par_vldcampo.
            WHEN  4   THEN 
                DO:  
                   ASSIGN crapffc.vlresgat = par_vldcampo
                          crapffc.vlaplica = 0.

                END.
            WHEN  5   THEN 
                DO:
                   ASSIGN crapffc.vlaplica = par_vldcampo
                          crapffc.vlresgat = 0.

                END.

        END CASE.

    END.

    RELEASE crapffc.

    RETURN "OK".
  
END PROCEDURE.


PROCEDURE pi_grava_consolidado_singular_entrada_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

   DEF  VAR aux_vlresent  AS DECI                                  NO-UNDO.

   ASSIGN aux_vlresent = 0.

   RUN busca_dados_fluxo_singular(INPUT par_cdcoopex,
                                  INPUT par_dtmvtolt,
                                  INPUT 1,
                                  OUTPUT TABLE tt-ffin-mvto-sing).

   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

   FIND FIRST tt-ffin-mvto-sing NO-LOCK NO-ERROR.

   IF AVAIL tt-ffin-mvto-sing THEN 
      ASSIGN aux_vlresent = tt-ffin-mvto-sing.vlttcrdb[1] +
                            tt-ffin-mvto-sing.vlttcrdb[2] +
                            tt-ffin-mvto-sing.vlttcrdb[3] +
                            tt-ffin-mvto-sing.vlttcrdb[4].

   RUN grava_consolidado_singular (INPUT par_cdcoopex,
                                   INPUT par_dtmvtolt,
                                   INPUT 1,
                                   INPUT aux_vlresent).
      
   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

   
   RETURN "OK".


END PROCEDURE.

PROCEDURE pi_grava_consolidado_singular_saida_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.

   DEF  VAR aux_vlressai  AS DECI                                  NO-UNDO.

   ASSIGN aux_vlressai = 0.

   RUN busca_dados_fluxo_singular(INPUT par_cdcoopex,
                                  INPUT par_dtmvtolt,
                                  INPUT 2,
                                  OUTPUT TABLE tt-ffin-mvto-sing).

   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

   FIND FIRST tt-ffin-mvto-sing NO-LOCK NO-ERROR.

   IF AVAIL tt-ffin-mvto-sing THEN 
      ASSIGN aux_vlressai = tt-ffin-mvto-sing.vlttcrdb[1] +
                            tt-ffin-mvto-sing.vlttcrdb[2] +
                            tt-ffin-mvto-sing.vlttcrdb[3] +
                            tt-ffin-mvto-sing.vlttcrdb[4].

   RUN grava_consolidado_singular (INPUT par_cdcoopex,
                                   INPUT par_dtmvtolt,
                                   INPUT 2,
                                   INPUT aux_vlressai).
      
   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

   
   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_grava_consolidado_sld_dia_ant_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_vlressal  AS DEC                                   NO-UNDO.
   DEF  VAR h-b1wgen0001  AS HANDLE                                NO-UNDO.

   DEF BUFFER b-crapcop1 FOR crapcop.

   ASSIGN aux_vlressal = 0.

   IF NOT VALID-HANDLE(h-b1wgen0001) THEN
      RUN sistema/generico/procedures/b1wgen0001.p 
          PERSISTENT SET h-b1wgen0001.

   FIND b-crapcop1 WHERE b-crapcop1.cdcooper = par_cdcoopex 
                         NO-LOCK NO-ERROR.

   
   RUN atualiza_tabela_erros (INPUT par_cdcooper,
                              INPUT FALSE).

   RUN obtem-saldos-anteriores IN h-b1wgen0001 (INPUT 3,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT 1,
                                                INPUT b-crapcop1.nrctactl,
                                                INPUT 1,
                                                INPUT par_dtmvtolt,
                                                INPUT par_dtmvtoan,
                                                INPUT par_dtmvtoan,
                                                INPUT TRUE,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-saldos).

   EMPTY TEMP-TABLE tt-erro.

   RUN atualiza_tabela_erros (INPUT par_cdcooper,
                              INPUT TRUE).

   IF RETURN-VALUE = "NOK" THEN
      DO:
         IF VALID-HANDLE(h-b1wgen0001) THEN
            DELETE OBJECT(h-b1wgen0001).

         RETURN "NOK".
        
      END.

   IF VALID-HANDLE(h-b1wgen0001) THEN
      DELETE OBJECT(h-b1wgen0001).

   FIND FIRST tt-saldos NO-LOCK NO-ERROR.

   IF AVAIL tt-saldos THEN
      ASSIGN aux_vlressal = tt-saldos.vlstotal.

   RUN grava_consolidado_singular (INPUT par_cdcoopex,
                                   INPUT par_dtmvtolt,
                                   INPUT 3,
                                   INPUT aux_vlressal).
      
   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

   
   RETURN "OK".


END PROCEDURE.


PROCEDURE grava-fluxo-financeiro:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dscritic AS CHAR                                   NO-UNDO.
   DEF  VAR aux_cdcooper AS INT                                    NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-auxerros.

   ASSIGN aux_dscritic = "" 
          aux_cdcooper = 0.

   FOR EACH crapcop WHERE (IF par_cdcooper <> 3 THEN
                              crapcop.cdcooper = par_cdcooper
                           ELSE
                              IF par_cdcoopex = 0 THEN
                                 crapcop.cdcooper <> 3
                              ELSE
                                 crapcop.cdcooper = par_cdcoopex)
                           NO-LOCK:

       ASSIGN aux_cdcooper = 0.

       IF par_cdcooper = 3 THEN
          IF par_cdcoopex = 0 THEN
             ASSIGN aux_cdcooper = crapcop.cdcooper.
          ELSE
             ASSIGN aux_cdcooper = par_cdcoopex.
       ELSE
          ASSIGN aux_cdcooper = par_cdcooper.

       RUN grava-fluxo-entrada(INPUT par_cdcooper,              
                               INPUT par_cdagenci,              
                               INPUT par_nrdcaixa,              
                               INPUT par_cdoperad,              
                               INPUT par_dtmvtolt,              
                               INPUT par_nmdatela,
                               INPUT par_dtmvtoan,
                               INPUT aux_cdcooper,
                               INPUT par_cdagefim,
                               INPUT crapcop.nmrescop,
                               OUTPUT TABLE tt-erro).     
       
       
       IF RETURN-VALUE <> "OK" THEN
          DO:
             FIND LAST tt-erro NO-LOCK NO-ERROR.

             IF AVAIL tt-erro THEN
                ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
             ELSE
                ASSIGN aux_nrsequen = aux_nrsequen + 1.

             ASSIGN aux_dscritic = "Calculo do fluxo de entrada " + 
                                   "nao foi efetuado - "          + 
                                   crapcop.nmrescop + ".".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 0,
                            INPUT-OUTPUT aux_dscritic).
             
          END.

       RUN grava-fluxo-saida(INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,
                             INPUT par_nmdatela,
                             INPUT par_dtmvtoan,
                             INPUT aux_cdcooper,
                             INPUT par_cdagefim,
                             INPUT crapcop.nmrescop,
                             OUTPUT TABLE tt-erro).

       IF RETURN-VALUE <> "OK" THEN
          DO:
             FIND LAST tt-erro NO-LOCK NO-ERROR.

             IF AVAIL tt-erro THEN
                ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
             ELSE
                ASSIGN aux_nrsequen = aux_nrsequen + 1.

             ASSIGN aux_dscritic = "Calculo do fluxo de saida " + 
                                   "nao foi efetuado - "        +
                                   crapcop.nmrescop + ".".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 0,
                            INPUT-OUTPUT aux_dscritic).
             
          END.

       
       RUN pi_grava_consolidado_singular_entrada_f (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_dtmvtolt,
                                                    INPUT par_nmdatela,
                                                    INPUT aux_cdcooper).
       
       
       IF RETURN-VALUE <> "OK" THEN
          DO:
             FIND LAST tt-erro NO-LOCK NO-ERROR.

             IF AVAIL tt-erro THEN
                ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
             ELSE
                ASSIGN aux_nrsequen = aux_nrsequen + 1.

             ASSIGN aux_dscritic = "Calculo das entradas nao foi efetuado - " +
                                   crapcop.nmrescop + ".".
       
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 0,
                            INPUT-OUTPUT aux_dscritic).
             
          END.

       
       RUN pi_grava_consolidado_singular_saida_f (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_dtmvtolt,
                                                  INPUT par_nmdatela,
                                                  INPUT aux_cdcooper).
       
       IF RETURN-VALUE <> "OK" THEN
          DO:
             FIND LAST tt-erro NO-LOCK NO-ERROR.

             IF AVAIL tt-erro THEN
                ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
             ELSE
                ASSIGN aux_nrsequen = aux_nrsequen + 1.

             ASSIGN aux_dscritic = "Calculo das saidas nao foi efetuado - " + 
                                   crapcop.nmrescop + ".".
       
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 0,
                            INPUT-OUTPUT aux_dscritic).
             
          END.

       
       RUN pi_grava_consolidado_sld_dia_ant_f (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nmdatela,
                                               INPUT par_dtmvtoan,
                                               INPUT aux_cdcooper,
                                               OUTPUT TABLE tt-erro).
       
       IF RETURN-VALUE <> "OK" THEN
          DO:
             FIND LAST tt-erro NO-LOCK NO-ERROR.
             
             IF AVAIL tt-erro THEN
                ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
             ELSE
                ASSIGN aux_nrsequen = aux_nrsequen + 1.

             ASSIGN aux_dscritic = "Calculo do saldo do dia anterior "       + 
                                   "nao foi efetuado - " + crapcop.nmrescop + 
                                   ".".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 0,
                            INPUT-OUTPUT aux_dscritic).
          END.
          

   END.

   
   RETURN "OK".


END PROCEDURE.


PROCEDURE grava-fluxo-entrada:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_dscritic  AS CHAR                                  NO-UNDO.

   ASSIGN aux_contador = 0
          aux_dscritic = "".

   
   RUN pi_sr_ted_f (INPUT par_cdcooper, 
                    INPUT par_cdagenci, 
                    INPUT par_nrdcaixa, 
                    INPUT par_cdoperad, 
                    INPUT par_dtmvtolt,     
                    INPUT par_nmdatela,
                    INPUT par_cdcoopex,
                    OUTPUT TABLE tt-erro).

   IF RETURN-VALUE <> "OK" THEN
      DO: 
         FIND LAST tt-erro NO-LOCK NO-ERROR.
    
         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do SR TED nao foi efetuado - " + 
                               par_nmrescop + ".".
         
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.


   RUN pi_cheques_f_nr(INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT par_nmdatela,
                       INPUT par_cdagefim,
                       INPUT par_cdcoopex).

   
   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do NR CHEQUES nao foi efetuado - " +
                               par_nmrescop + ".".
         
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).

      END.

   RUN pi_dev_cheques_rem_f (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,    
                             INPUT par_nmdatela,
                             INPUT par_dtmvtoan,
                             INPUT par_cdcoopex).
  

  IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo da Devolucao Cheques Remet. "       + 
                               "nao foi efetuado - " + par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.

   RUN pi_inss_f (INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_dtmvtolt,
                  INPUT par_nmdatela,
                  INPUT par_cdcoopex).

  
  IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.
                                                   
         ASSIGN aux_dscritic = "Calculo do INSS nao foi efetuado - " + 
                               par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.


   RUN pi_rec_transf_dep_intercoop_f (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nmdatela,
                                      INPUT par_cdcoopex).

   
   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo da Transf/Depos Interc. "          + 
                               "nao foi efetuado - " + par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.

   

      RUN pi_sr_titulos_f (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_dtmvtolt,
                          INPUT par_nmdatela,
                          INPUT par_dtmvtoan,
                          INPUT par_cdcoopex,
                          INPUT FALSE,
                          OUTPUT TABLE tt-erro).
  
      IF RETURN-VALUE <> "OK" THEN
         DO:
            FIND LAST tt-erro NO-LOCK NO-ERROR.
   
            IF AVAIL tt-erro THEN
               ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
            ELSE
               ASSIGN aux_nrsequen = aux_nrsequen + 1.
   
               ASSIGN aux_dscritic = "Nao foi possivel realizar o calculo " + 
                                     "do SR Titulos - " + par_nmrescop + ".".
               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT aux_nrsequen,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
   
         END.
    

   RUN pi_rec_saq_taa_intercoop_f (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nmdatela,
                                   INPUT par_cdcoopex).
   
   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do Saque TAA Interc. "            + 
                               "nao foi efetuado - " + par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.
   

   RETURN "OK".


END PROCEDURE.


PROCEDURE grava-fluxo-saida:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_cdagefim AS INT                            NO-UNDO.
   DEF  INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_cdbccxlt  AS CHAR INIT "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_contador  AS INT                                   NO-UNDO.
   DEF  VAR aux_dscritic  AS CHAR                                  NO-UNDO.


   ASSIGN aux_contador = 0
          aux_dscritic = "".


   RUN pi_convenios_f (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT par_nmdatela,
                       INPUT par_cdcoopex).


   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do convenio nao foi efetuado - " + 
                               par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.

   
   RUN pi_doc_f_nr (INPUT par_cdcooper,
                    INPUT par_cdagenci,
                    INPUT par_nrdcaixa,
                    INPUT par_cdoperad,
                    INPUT par_dtmvtolt,
                    INPUT par_nmdatela,
                    INPUT par_cdagefim,
                    INPUT par_cdcoopex).


   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do NR DOC nao foi efetuado - " + 
                               par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).

      END.


   RUN pi_tedtec_nr_f (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT par_nmdatela,
                       INPUT par_cdagefim,
                       INPUT par_cdcoopex).


   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do NR TED nao foi efetuado - " +
                               par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.


   RUN pi_titulos_f_nr (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_cdoperad,
                        INPUT par_dtmvtolt,
                        INPUT par_nmdatela,
                        INPUT par_cdagefim,
                        INPUT par_cdcoopex,
                        INPUT par_dtmvtoan).


  IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do NR Titulos nao foi efetuado - " +
                               par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.


   RUN pi_dev_cheques_rec_f(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nmdatela,
                            INPUT par_dtmvtoan,
                            INPUT par_cdcoopex,
                            INPUT par_cdagefim).

   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo de devolucao de cheques recebidos " + 
                               "nao foi efetuado - " + par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.

   RUN pi_gps_f (INPUT par_cdcooper,
                 INPUT par_cdagenci,
                 INPUT par_nrdcaixa,
                 INPUT par_cdoperad,
                 INPUT par_dtmvtolt,
                 INPUT par_nmdatela,
                 INPUT par_cdcoopex).

   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo do GPS nao foi efetuado - " + 
                               par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.


   RUN pi_rem_transf_dep_intercoop_f (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nmdatela,
                                      INPUT par_cdcoopex).


   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo das Transf/Depos Interc. "         + 
                               "nao foi efetuado - " + par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).
         
      END.


   RUN pi_rem_saq_taa_intercoop_f (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nmdatela,
                                   INPUT par_cdcoopex).


  IF RETURN-VALUE <> "OK" THEN
     DO:
        FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

        ASSIGN aux_dscritic = "Calculo do Saque TAA Interc. nao "    + 
                              "foi efetuado - " + par_nmrescop + ".".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT aux_nrsequen,
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        
     END.


   RUN pi_rem_fatura_bradesco_f (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_nmdatela,
                                 INPUT par_cdcoopex).


   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND LAST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
         ELSE
            ASSIGN aux_nrsequen = aux_nrsequen + 1.

         ASSIGN aux_dscritic = "Calculo das faturas do cartão Bradesco " + 
                               "nao foi efetuado - " + par_nmrescop + ".".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT aux_nrsequen,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).

      END.

   
   RETURN "OK".


END PROCEDURE.


PROCEDURE pi_sr_titulos_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_cdcoopex AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_calcproj AS LOG                            NO-UNDO.
   
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_mesanter AS DEC FORMAT "9"                         NO-UNDO.
   DEF  VAR aux_vltotger AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_vlrmedia AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_cdbccxlt AS CHAR INIT  "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_vlrdotit AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.


   ASSIGN aux_contador = 0
          aux_vltotger = 0
          aux_vlrmedia = 0
          aux_vlrdotit = 0
          aux_mesanter = 0.

   IF par_calcproj THEN
      DO:
         RUN gera-periodos-projecao-titulo(INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nmdatela,
                                           INPUT 1,
                                           OUTPUT TABLE tt-per-datas).
                                          
         IF RETURN-VALUE <> "OK" THEN
            RETURN "NOK".
         
         ASSIGN aux_contador = 0
                aux_vltotger = 0
                aux_vlrmedia = 0.
         
         FOR EACH tt-per-datas WHERE tt-per-datas.dtmvtolt >= 09/01/2011
                                   BREAK BY tt-per-datas.cdagrupa:
         
             FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper          AND
                                    craplcm.cdhistor = 977                   AND
                                    craplcm.dtmvtolt = tt-per-datas.dtmvtolt
                                    NO-LOCK:
         
                 ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal +
                                                craplcm.vllanmto.
         
             END.

             ASSIGN aux_vltotger = aux_vltotger + tt-per-datas.vlrtotal
                    aux_contador = aux_contador + 1.
         
             IF LAST-OF(tt-per-datas.cdagrupa) THEN
                DO:
                  ASSIGN aux_vlrmedia = aux_vlrmedia  + (aux_vltotger / aux_contador)
                         aux_vltotger = 0
                         aux_contador = 0.
                END.
         
         END.
         
         FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                            craptab.nmsistem = "CRED"          AND
                            craptab.tptabela = "GENERI"        AND
                            craptab.cdempres = 00              AND
                            craptab.cdacesso = "PARFLUXOFINAN" AND
                            craptab.tpregist = 0
                            NO-LOCK NO-ERROR.
         
         IF AVAIL craptab THEN
            ASSIGN aux_vlrmedia = aux_vlrmedia + 
                                ((aux_vlrmedia * 
                                  DECIMAL(ENTRY(4,craptab.dstextab,";"))) / 100).
         
         
         DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
         
            RUN grava-movimentacao 
                           (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT 1,
                            INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                            INPUT 4,
                            INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                      aux_vlrmedia
                                   ELSE
                                      0)).
            
            IF RETURN-VALUE <> "OK" THEN
               RETURN "NOK".
         
         END.
      END.
   ELSE
      DO:
          ASSIGN aux_contador = 0.
          
          FOR EACH crapcob WHERE crapcob.cdcooper = par_cdcoopex          AND
                                 crapcob.dtdpagto = par_dtmvtoan          AND
                                 crapcob.cdbandoc = 1 /*Banco do Brasil*/ AND
                                 crapcob.incobran = 5 /*Compensacao*/     AND
                                 crapcob.indpagto = 0                     AND
                                 crapcob.vldpagto > 0
                                 USE-INDEX crapcob6 NO-LOCK:
          
              ASSIGN aux_vlrdotit = aux_vlrdotit    + 
                                    crapcob.vldpagto.
                                       
          END.
          
          RUN grava-movimentacao(INPUT par_cdcoopex,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT 1,
                                 INPUT 01,
                                 INPUT 4,
                                 INPUT aux_vlrdotit).
          
          IF RETURN-VALUE <> "OK" THEN
             RETURN "NOK".
      END.         
   
      
   RETURN "OK".


END PROCEDURE.


PROCEDURE gera-periodos-projecao-titulo:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdagrupa AS INTE                           NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-per-datas.

   DEF VAR aux_dtnumdia AS INTE FORMAT "99"                        NO-UNDO.
   DEF VAR aux_dtsemdia AS INTE FORMAT "9"                         NO-UNDO.
   DEF VAR aux_listadia AS CHAR                                    NO-UNDO.

   EMPTY TEMP-TABLE tt-per-datas.

   IF fnDiaAnteriorEhFeriado(par_cdcooper, par_dtmvtolt) THEN
      DO:
        RUN gera-periodos-projecao-titulo(INPUT par_cdcooper, 
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT fnBuscaDataAnteriorFeriado(par_cdcooper, par_dtmvtolt),
                                          INPUT par_nmdatela,
                                          INPUT par_cdagrupa + 1,
                                          OUTPUT TABLE tt-per-datas).
      END.
   
   ASSIGN aux_dtnumdia = DAY(par_dtmvtolt)
          aux_dtsemdia = WEEKDAY(par_dtmvtolt).

   IF (aux_dtsemdia <> 2) THEN
      DO:
         ASSIGN aux_listadia = STRING(DAY(par_dtmvtolt)).


         RUN RegraMediaDiasUteisDaSemanaTitulo(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "3,4,5,6",
                                               INPUT aux_listadia,
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).
      END.
   ELSE
      DO:
         CASE aux_dtnumdia:

              WHEN 1  OR
              WHEN 2  OR
              WHEN 3  THEN
              DO:
                RUN RegraMediaPrimeiroDiaUtilSegundaFeiraTit
                                                (INPUT par_cdcooper,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_cdagrupa,
                                                 OUTPUT TABLE tt-per-datas).
              END.

              WHEN 4 THEN
              DO:
                  RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT STRING(aux_dtnumdia),
                                                   INPUT par_cdagrupa,
                                                   OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                        RUN RegraMediaSegundaFeiraTitulo
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolt,
                                         INPUT "2,3,4,5",
                                         INPUT par_cdagrupa,
                                         OUTPUT TABLE tt-per-datas).

                     END.

              END.

              WHEN 5 OR
              WHEN 6 OR 
              WHEN 7 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "5,6,7",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

              END.

              WHEN 8  OR
              WHEN 9  THEN
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).
                 
                 FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                 IF (NOT AVAIL tt-per-datas) THEN
                    DO:
                       
                       RUN RegraMediaSegundaFeiraTitulo
                                                 (INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "8,9",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

                    END.

              END.

              WHEN 10 OR
              WHEN 11 OR
              WHEN 12 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "10,11,12",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

              END.

              WHEN 13 OR
              WHEN 14 THEN
              DO:
                  RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT STRING(aux_dtnumdia),
                                                   INPUT par_cdagrupa,
                                                   OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                       
                         RUN RegraMediaSegundaFeiraTitulo
                                                   (INPUT par_cdcooper,
                                                    INPUT par_dtmvtolt,
                                                    INPUT "13,14",
                                                    INPUT par_cdagrupa,
                                                    OUTPUT TABLE tt-per-datas).

                     END.

              END.

              WHEN 15 OR
              WHEN 16 OR
              WHEN 17 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "15,16,17",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

              END.

              WHEN 18 OR
              WHEN 19 THEN
              DO:
                  RUN RegraMediaSegundaFeiraTitulo
                                            (INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT STRING(aux_dtnumdia),
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                         RUN RegraMediaSegundaFeiraTitulo
                                                   (INPUT par_cdcooper,
                                                    INPUT par_dtmvtolt,
                                                    INPUT "18,19",
                                                    INPUT par_cdagrupa,
                                                    OUTPUT TABLE tt-per-datas).

                     END.

              END.

              WHEN 20 OR
              WHEN 21 OR
              WHEN 22 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "20,21,22",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

              END.

              WHEN 23 OR
              WHEN 24 THEN
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeiraTitulo
                                                 (INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "23,24",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

                     END.

              END.

              WHEN 25 OR
              WHEN 26 OR
              WHEN 27 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "25,26,27",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

              END.

              WHEN 28 OR
              WHEN 29 THEN
              DO:
                  RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT STRING(aux_dtnumdia),
                                                   INPUT par_cdagrupa,
                                                   OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                        RUN RegraMediaSegundaFeiraTitulo
                                                  (INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT "28,29",
                                                   INPUT par_cdagrupa,
                                                   OUTPUT TABLE tt-per-datas).

                     END.

              END.

              WHEN 30 THEN
              DO:
                  RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT STRING(aux_dtnumdia),
                                                   INPUT par_cdagrupa,
                                                   OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                        RUN RegraMediaSegundaFeiraTitulo
                                                   (INPUT par_cdcooper,
                                                    INPUT par_dtmvtolt,
                                                    INPUT "30,31",
                                                    INPUT par_cdagrupa,
                                                    OUTPUT TABLE tt-per-datas).

                     END.

              END.

              WHEN 31 THEN
              DO:
                  RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT "30,31",
                                                   INPUT par_cdagrupa,
                                                   OUTPUT TABLE tt-per-datas).

              END.

              OTHERWISE
              DO:
                 RUN RegraMediaSegundaFeiraTitulo(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

              END.                  

         END CASE.

      END.

   RETURN "OK".

END PROCEDURE.


PROCEDURE RegraMediaSegundaFeiraItg:
    
   DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
   DEF  INPUT PARAM par_listdias AS CHAR            NO-UNDO.
   DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.

   DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

   DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
   
   ASSIGN aux_dtperiod = par_dtmvtolt - 360.
   
   DO WHILE aux_dtperiod < par_dtmvtolt:

      IF CAN-DO(par_listdias, STRING(DAY(aux_dtperiod)))        AND 
         WEEKDAY(aux_dtperiod) = 2                              AND
         fnEhDataUtil(par_cdcooper, aux_dtperiod)               AND
         NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod) THEN
         DO:
             ASSIGN aux_nrsequen = fnRetornaProximaSequencia().

             FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                                           NO-LOCK NO-ERROR.

             IF NOT AVAIL tt-per-datas THEN
                DO:
                   CREATE tt-per-datas.

                   ASSIGN tt-per-datas.nrsequen = aux_nrsequen 
                          tt-per-datas.dtmvtolt = aux_dtperiod
                          tt-per-datas.cdagrupa = par_cdagrupa.

                END.

          END.

      ASSIGN aux_dtperiod = aux_dtperiod + 1.

   END.

   RETURN "OK".

END.


PROCEDURE RegraMediaSegundaFeiraTitulo:
    
    DEF  INPUT PARAM par_cdcooper AS INTE             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE             NO-UNDO.
    DEF  INPUT PARAM par_listdias AS CHAR             NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE             NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.
                                      
    DEF  VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.
    
    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF CAN-DO(par_listdias, STRING(DAY(aux_dtperiod)))        AND
          WEEKDAY(aux_dtperiod) = 2                              AND
          fnEhDataUtil(par_cdcooper, aux_dtperiod)               AND
          NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod) THEN
          DO:
             ASSIGN aux_sequenci = fnRetornaProximaSequencia().
           
             FIND FIRST tt-per-datas 
                  WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                  NO-LOCK NO-ERROR.
          
             IF NOT AVAIL tt-per-datas THEN
                DO:
                  CREATE tt-per-datas.
             
                  ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                         tt-per-datas.dtmvtolt = aux_dtperiod
                         tt-per-datas.cdagrupa = par_cdagrupa.
                END.

          END.

       ASSIGN aux_dtperiod = aux_dtperiod + 1.

     END.

    RETURN "OK".
     
END.

PROCEDURE RegraMediaPrimeiroDiaUtilSegundaFeiraItg:
    
    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    
   
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF ((WEEKDAY(aux_dtperiod) = 2)                                     AND
           (DAY(aux_dtperiod) = fnRetornaNumeroDiaUtilItg(par_cdcooper, 1, 
                                                          aux_dtperiod)))  AND
           NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod)          THEN
           DO:
              ASSIGN aux_nrsequen = fnRetornaProximaSequencia().
              
              FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod
                                            NO-LOCK NO-ERROR.
              
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.
              
                    ASSIGN tt-per-datas.nrsequen = aux_nrsequen 
                           tt-per-datas.dtmvtolt = aux_dtperiod
                           tt-per-datas.cdagrupa = par_cdagrupa.
              
                 END.

         END.

       ASSIGN aux_dtperiod = aux_dtperiod + 1.

    END.

    RETURN "OK".

END.



PROCEDURE RegraMediaPrimeiroDiaUtilSegundaFeiraTit:
                                                     
    DEF  INPUT PARAM par_cdcooper AS INTE             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE             NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE             NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF  VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF ((WEEKDAY(aux_dtperiod) = 2)                                                 AND 
          (DAY(aux_dtperiod) = fnRetornaNumeroDiaUtilTitulo(par_cdcooper, 1, aux_dtperiod))) AND
          NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod)                       THEN
          DO:
             ASSIGN aux_sequenci = fnRetornaProximaSequencia().
           
             FIND FIRST tt-per-datas 
                  WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                  NO-LOCK NO-ERROR.
          
             IF NOT AVAIL tt-per-datas THEN
                DO:
                   CREATE tt-per-datas.
             
                   ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                          tt-per-datas.dtmvtolt = aux_dtperiod
                          tt-per-datas.cdagrupa = par_cdagrupa.

                END.

          END.

       ASSIGN aux_dtperiod = aux_dtperiod + 1.

    END.

    RETURN "OK".

END.


PROCEDURE RegraMediaDiasUteisDaSemanaTitulo:

    DEF  INPUT PARAM par_cdcooper AS INTE             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE             NO-UNDO.
    DEF  INPUT PARAM par_nrdiasse AS CHAR             NO-UNDO.
    DEF  INPUT PARAM par_nrdiasme AS CHAR             NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF  VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF  VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF (NUM-ENTRIES(par_nrdiasme) = 2) THEN
          DO:
              IF fnValidaRegraMediaDiasUteisDaSemanaTitulo
                                                    (INPUT par_nrdiasme,
                                                     INPUT par_nrdiasse,
                                                     INPUT aux_dtperiod,
                                                     INPUT par_cdcooper) AND
                 (fnValidaRegraMediaDiasUteisDaSemanaTitulo
                                                    (INPUT par_nrdiasme,
                                                     INPUT par_nrdiasse,
                                                     INPUT aux_dtperiod + 1,
                                                     INPUT par_cdcooper)) THEN
                 DO:
                    ASSIGN aux_sequenci = fnRetornaProximaSequencia().
           
                    FIND FIRST tt-per-datas 
                         WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                         NO-LOCK NO-ERROR.
                  
                    IF NOT AVAIL tt-per-datas THEN
                       DO:
                          CREATE tt-per-datas.
                     
                           ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                                  tt-per-datas.dtmvtolt = aux_dtperiod
                                  tt-per-datas.cdagrupa = par_cdagrupa.
                       END.

                    ASSIGN aux_sequenci = fnRetornaProximaSequencia().

                    FIND FIRST tt-per-datas 
                         WHERE tt-per-datas.dtmvtolt = aux_dtperiod + 1
                         NO-LOCK NO-ERROR.
                  
                    IF NOT AVAIL tt-per-datas THEN
                       DO:
                          CREATE tt-per-datas.
                     
                           ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                                  tt-per-datas.dtmvtolt = aux_dtperiod + 1
                                  tt-per-datas.cdagrupa = par_cdagrupa.
                       END.

                 END.

          END.
       ELSE
          IF fnValidaRegraMediaDiasUteisDaSemanaTitulo(INPUT par_nrdiasme,
                                                       INPUT par_nrdiasse,
                                                       INPUT aux_dtperiod,
                                                       INPUT par_cdcooper) THEN
          
             DO:
                ASSIGN aux_sequenci = fnRetornaProximaSequencia().
           
                FIND FIRST tt-per-datas 
                     WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                     NO-LOCK NO-ERROR.
              
                IF NOT AVAIL tt-per-datas THEN
                   DO:
                      CREATE tt-per-datas.
                 
                       ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                              tt-per-datas.dtmvtolt = aux_dtperiod
                              tt-per-datas.cdagrupa = par_cdagrupa.
                   END.

             END.

       ASSIGN aux_dtperiod = aux_dtperiod + 1.

    END.

    RETURN "OK".

END.


PROCEDURE pi_sr_doc_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_mesanter AS DEC FORMAT "9"                         NO-UNDO.
   DEF  VAR aux_vltotger AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_vlrmedia AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_cdbccxlt AS CHAR INIT  "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_vlrdotit AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.


   ASSIGN aux_contador = 0
          aux_vltotger = 0
          aux_vlrmedia = 0
          aux_vlrdotit = 0
          aux_mesanter = 0
          aux_sequenci = 0.

   RUN gera-periodos-projecao-chqdoc(INPUT par_cdcooper, 
                                     INPUT par_dtmvtolt,
                                     OUTPUT TABLE tt-per-datas).


   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".


   FOR EACH tt-per-datas:

       FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper          AND
                              craplcm.cdhistor = 575                   AND
                              craplcm.dtmvtolt = tt-per-datas.dtmvtolt
                              NO-LOCK:

           ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + 
                                          craplcm.vllanmto.

       END.

       IF aux_mesanter <> MONTH(tt-per-datas.dtmvtolt) THEN
          ASSIGN aux_contador = aux_contador + 1.


       ASSIGN aux_mesanter = MONTH(tt-per-datas.dtmvtolt)
              aux_vltotger = aux_vltotger + 
                             tt-per-datas.vlrtotal.

   END.


   IF aux_contador > 0 THEN
      ASSIGN aux_vlrmedia = (aux_vltotger / aux_contador).
   ELSE
      ASSIGN aux_vlrmedia = 0.

   FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 00              AND
                      craptab.cdacesso = "PARFLUXOFINAN" AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF AVAIL craptab THEN
      ASSIGN aux_vlrmedia = aux_vlrmedia + 
                          ((aux_vlrmedia * 
                            DECIMAL(ENTRY(1,craptab.dstextab,";"))) / 100).


   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 1,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 2,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                aux_vlrmedia
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

   END.

   RETURN "OK".

END PROCEDURE.


PROCEDURE pi_sr_cheques_f:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.


   DEF  VAR aux_mesanter AS DEC FORMAT "9"                         NO-UNDO.
   DEF  VAR aux_vltotger AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_vlrmedia AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_cdbccxlt AS CHAR INIT  "01,85,756,100"             NO-UNDO.
   DEF  VAR aux_vlrdotit AS DEC FORMAT "zzz,zzz,zz,zzz,zz9.99"     NO-UNDO.
   DEF  VAR aux_dtproxim AS DATE                                   NO-UNDO.


   ASSIGN aux_contador = 0
          aux_vltotger = 0
          aux_vlrmedia = 0
          aux_vlrdotit = 0
          aux_mesanter = 0
          aux_sequenci = 0.
          

   RUN gera-periodos-projecao-chqdoc(INPUT par_cdcooper, 
                                     INPUT par_dtmvtolt,
                                     OUTPUT TABLE tt-per-datas).

   
   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

   FOR EACH tt-per-datas:

       ASSIGN aux_dtproxim = fnRetornaProximaDataUtil(par_cdcooper,
                                                      tt-per-datas.dtmvtolt).
                                                                  
       FOR EACH craplcm WHERE (craplcm.cdcooper = par_cdcooper)           AND
                              ((craplcm.dtmvtolt = aux_dtproxim)          AND 
                              (craplcm.dtrefere <> ?)                     AND 
                              (craplcm.dtrefere = tt-per-datas.dtmvtolt)) AND 
                               craplcm.cdhistor = 524  
                              NO-LOCK:
                                    
            ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + 
                                           craplcm.vllanmto.
                
       END.
        
       FOR EACH craplcm WHERE (craplcm.cdcooper = par_cdcooper)           AND
                              ((craplcm.dtmvtolt = tt-per-datas.dtmvtolt) AND 
                              (craplcm.dtrefere = ?))                     AND
                               craplcm.cdhistor = 524   
                              NO-LOCK:
                                     
           ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + 
                                          craplcm.vllanmto.
                     
       END.
        
       FOR EACH craplcm WHERE (craplcm.cdcooper = par_cdcooper)           AND
                              ((craplcm.dtmvtolt = tt-per-datas.dtmvtolt) AND 
                              (craplcm.dtrefere <> ?)                     AND 
                              (craplcm.dtrefere = tt-per-datas.dtmvtolt)) AND
                               craplcm.cdhistor = 524 
                              NO-LOCK:
                                     
             ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + 
                                            craplcm.vllanmto.
              
       END.
       
       IF aux_mesanter <> MONTH(tt-per-datas.dtmvtolt) THEN
          ASSIGN aux_contador = aux_contador + 1.


       ASSIGN aux_mesanter = MONTH(tt-per-datas.dtmvtolt)
              aux_vltotger = aux_vltotger + 
                             tt-per-datas.vlrtotal.

   END.                                        


   IF aux_contador > 0 THEN
      ASSIGN aux_vlrmedia = (aux_vltotger / aux_contador).
   ELSE
      ASSIGN aux_vlrmedia = 0.

   FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 00              AND
                      craptab.cdacesso = "PARFLUXOFINAN" AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF AVAIL craptab THEN
      ASSIGN aux_vlrmedia = aux_vlrmedia + 
                          ((aux_vlrmedia * 
                            DECIMAL(ENTRY(2,craptab.dstextab,";"))) / 100).

   DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
   
      RUN grava-movimentacao 
                     (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                      INPUT 1,
                      INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                                aux_vlrmedia
                             ELSE
                                0)).
      
      IF RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

   END.

   RETURN "OK".

END PROCEDURE.


PROCEDURE RegraMediaSegundaFeiraChqDoc:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF  INPUT PARAM par_listdias AS CHAR                        NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999"             NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.
       
    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF CAN-DO(par_listdias, STRING(DAY(aux_dtperiod)))        AND 
          WEEKDAY(aux_dtperiod) = 2                              AND 
          fnEhDataUtil(par_cdcooper, aux_dtperiod)               AND
          NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod) THEN
          DO:
             ASSIGN aux_sequenci = fnRetornaProximaSequencia().
           
              FIND FIRST tt-per-datas 
                   WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                   NO-LOCK NO-ERROR.
              
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.

                    ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                           tt-per-datas.dtmvtolt = aux_dtperiod.
                 END.
          END.

       ASSIGN aux_dtperiod = aux_dtperiod + 1.

     END.

    RETURN "OK". 

END.


PROCEDURE RegraMediaDiaUtilSegundaFeira:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF  INPUT PARAM par_numdiaut AS INTE                        NO-UNDO.
    DEF  INPUT PARAM par_diaminim AS INTE                        NO-UNDO.
    DEF  INPUT PARAM par_diamaxim AS INTE                        NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999"             NO-UNDO.
    DEF VAR aux_numdiaut AS INTE FORMAT "99"                     NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.
    
    DO WHILE aux_dtperiod < par_dtmvtolt:
         
       ASSIGN aux_numdiaut = fnRetornaNumeroDiaUtilChqDoc(par_cdcooper, 
                                                    par_numdiaut, 
                                                    aux_dtperiod).

       IF (WEEKDAY(aux_dtperiod) = 2)        AND 
          (DAY(aux_dtperiod) = aux_numdiaut) AND 
          (aux_numdiaut < par_diamaxim)      AND 
          (aux_numdiaut > par_diaminim)      THEN
          DO:
              ASSIGN aux_sequenci = fnRetornaProximaSequencia().
           
              FIND FIRST tt-per-datas 
                   WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                   NO-LOCK NO-ERROR.
              
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.

                    ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                           tt-per-datas.dtmvtolt = aux_dtperiod.
                 END.

          END.

       ASSIGN aux_dtperiod = aux_dtperiod + 1.

    END.

    RETURN "OK".
    
END.


PROCEDURE RegraMediaDiasUteisDaSemanaChqDoc:

    DEF  INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF  INPUT PARAM par_nrdiasse AS CHAR                        NO-UNDO.
    DEF  INPUT PARAM par_nrdiasme AS CHAR                        NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.                   
                                                                
    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999"             NO-UNDO.
    DEF VAR aux_dtnumdia AS INTE FORMAT "99"                     NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF fnValidaRegraMediaDiasUteisDaSemanaChqDoc(INPUT par_nrdiasme,
                                                    INPUT par_nrdiasse,
                                                    INPUT aux_dtperiod,
                                                    INPUT par_cdcooper) THEN
          DO:
              ASSIGN aux_sequenci = fnRetornaProximaSequencia().
              
              FIND FIRST tt-per-datas 
                   WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                   NO-LOCK NO-ERROR.
              
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.

                    ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                           tt-per-datas.dtmvtolt = aux_dtperiod.
                 END.
          END.

         ASSIGN aux_dtperiod = aux_dtperiod + 1.

    END.

    RETURN "OK".

END.

FUNCTION fnRetornaUltimoDiaUtilAno DATE (INPUT par_cdcooper AS INT,
                                         INPUT par_numerano AS INT):

    DEF VAR aux_contador AS INT  INIT 0 NO-UNDO.
    DEF VAR aux_dtverdat AS DATE        NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(12, 31, par_numerano).
    
    DO WHILE MONTH(aux_dtverdat) = 12:
    
        IF NOT  CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat))) AND 
           NOT  CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                       crapfer.dtferiad = aux_dtverdat AND
                                       (  DAY(crapfer.dtferiad) <> 31    AND 
                                        MONTH(crapfer.dtferiad) <> 12)) THEN
                                       
           LEAVE.
        
        ASSIGN aux_dtverdat = aux_dtverdat - 1.
                
    END. 
    
    RETURN aux_dtverdat.
    
END FUNCTION.

FUNCTION fnRetornaPrimeiroDiaUtilAno DATE (INPUT par_cdcooper AS INT,
                                           INPUT par_numerano AS INT):

    DEF VAR aux_contador AS INT  INIT 0 NO-UNDO.
    DEF VAR aux_dtverdat AS DATE        NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(01, 01, par_numerano).
    
    DO WHILE MONTH(aux_dtverdat) = 1:
    
        IF NOT  CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat))) AND 
           NOT  CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                       crapfer.dtferiad = aux_dtverdat) THEN
           LEAVE.
        
        ASSIGN aux_dtverdat = aux_dtverdat + 1.
                
    END. 
    
    RETURN aux_dtverdat.
    
END FUNCTION.


PROCEDURE gera-periodos-projecao-chqdoc:

   DEF  INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-per-datas.                       
                                                                  
   DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999"               NO-UNDO.
   DEF VAR aux_dtnumdia AS INTE FORMAT "99"                       NO-UNDO.
   DEF VAR aux_dtsemdia AS INTE FORMAT "9"                        NO-UNDO.
   DEF VAR aux_sequenci AS INTE                                   NO-UNDO.

   EMPTY TEMP-TABLE tt-per-datas.


   IF par_dtmvtolt = fnRetornaUltimoDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt))  THEN
      DO:
         aux_dtperiod = fnRetornaUltimoDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt) - 1).

         ASSIGN aux_sequenci = fnRetornaProximaSequencia().
       
         FIND FIRST tt-per-datas 
              WHERE tt-per-datas.dtmvtolt = aux_dtperiod
              NO-LOCK NO-ERROR.
      
         IF NOT AVAIL tt-per-datas THEN
            DO:
              CREATE tt-per-datas.
         
              ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                     tt-per-datas.dtmvtolt = aux_dtperiod.
            END.
    
          RETURN "OK".
      END.
 ELSE 
      IF par_dtmvtolt = fnRetornaPrimeiroDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt))  THEN
         DO: 
             ASSIGN aux_sequenci = fnRetornaProximaSequencia().
             
             aux_dtperiod = fnRetornaPrimeiroDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt) - 1).
             
             FIND FIRST tt-per-datas 
                  WHERE tt-per-datas.dtmvtolt = aux_dtperiod
                  NO-LOCK NO-ERROR.
          
             IF NOT AVAIL tt-per-datas THEN
                DO:
                  CREATE tt-per-datas.
             
                  ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                         tt-per-datas.dtmvtolt = aux_dtperiod.
                END.

             RETURN "OK".
         END.
   
   ASSIGN aux_dtnumdia = DAY(par_dtmvtolt)
          aux_dtsemdia = WEEKDAY(par_dtmvtolt).

   IF fnEhFeriado(par_cdcooper, par_dtmvtolt - 1) THEN
      ASSIGN aux_dtsemdia = 2. 
                 
   IF (aux_dtsemdia <> 2) THEN
      DO:
         CASE aux_dtnumdia:

              WHEN 07 OR
              WHEN 08 OR
              WHEN 12 OR
              WHEN 13 OR
              WHEN 17 OR
              WHEN 18 THEN
              DO:
                  IF aux_dtsemdia = 3 THEN
                     DO:
                        RUN RegraMediaDiasUteisDaSemanaChqDoc
                                          (INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT "3",
                                           INPUT STRING(DAY(par_dtmvtolt)),
                                           OUTPUT TABLE tt-per-datas). 

                        FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                        IF (NOT AVAIL tt-per-datas) THEN
                           DO:
                              IF aux_dtnumdia = 07 OR
                                 aux_dtnumdia = 12 OR
                                 aux_dtnumdia = 17 THEN
                                 DO:
                                    RUN RegraMediaDiasUteisDaSemanaChqDoc
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolt,
                                         INPUT "3",
                                         INPUT STRING(DAY(par_dtmvtolt - 1)),
                                         OUTPUT TABLE tt-per-datas). 
                                 END.
                                 ELSE
                                 DO:
                                   RUN RegraMediaDiasUteisDaSemanaChqDoc
                                       (INPUT par_cdcooper,
                                        INPUT par_dtmvtolt,
                                        INPUT "3",
                                        INPUT STRING(DAY(par_dtmvtolt - 1)) +
                                              "," + 
                                              STRING(DAY(par_dtmvtolt - 2)),
                                        OUTPUT TABLE tt-per-datas). 

                                 END.

                           END.

                     END.
                  ELSE
                     DO:
                        IF aux_dtnumdia = 07 OR
                           aux_dtnumdia = 08 OR
                           aux_dtnumdia = 13 OR
                           aux_dtnumdia = 18 THEN
                           DO:
                               RUN RegraMediaDiasUteisDaSemanaChqDoc
                                           (INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "3,4,5,6",
                                            INPUT STRING(DAY(par_dtmvtolt)),
                                            OUTPUT TABLE tt-per-datas). 
                           END.
                         ELSE
                           DO:
                               RUN RegraMediaDiasUteisDaSemanaChqDoc
                                           (INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "4,5,6",
                                            INPUT STRING(DAY(par_dtmvtolt)),
                                            OUTPUT TABLE tt-per-datas). 
                            END.
                     END.

              END.
              OTHERWISE
              DO:
                IF ((aux_dtnumdia = 28)                                     OR
                   (aux_dtnumdia = 29))                                     AND 
                   (fnBuscaDataDoUltimoDiaMes(par_dtmvtolt) = par_dtmvtolt) THEN
                   DO:
                      RUN RegraMediaDiasUteisDaSemanaChqDoc
                                                  (INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT "3,4,5,6",
                                                   INPUT "30",
                                                   OUTPUT TABLE tt-per-datas). 
                   END.
                ELSE
                   DO:
                     RUN RegraMediaDiasUteisDaSemanaChqDoc
                                            (INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT "3,4,5,6",
                                             INPUT STRING(DAY(par_dtmvtolt)),
                                             OUTPUT TABLE tt-per-datas). 

                   END.

              END.

         END CASE.

      END.
   ELSE
      DO:
         CASE aux_dtnumdia:

              WHEN 1  OR
              WHEN 2  OR
              WHEN 3  THEN
              DO:
                 RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "1,2,3",
                                                  OUTPUT TABLE tt-per-datas).

              END.
              WHEN 15 THEN
              DO:
                 RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  OUTPUT TABLE tt-per-datas).

                 FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                 IF (NOT AVAIL tt-per-datas) THEN
                    DO:
                       RUN RegraMediaSegundaFeiraChqDoc
                                         (INPUT par_cdcooper,
                                          INPUT par_dtmvtolt,
                                          INPUT fnBuscaListaDias(aux_dtnumdia),
                                          OUTPUT TABLE tt-per-datas).

                    END.

              END.
              WHEN 21 THEN
              DO:
                  RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT "20,21",
                                                   OUTPUT TABLE tt-per-datas).

                  FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                  IF (NOT AVAIL tt-per-datas) THEN
                     DO:
                         RUN RegraMediaSegundaFeiraChqDoc
                                         (INPUT par_cdcooper,
                                          INPUT par_dtmvtolt,
                                          INPUT fnBuscaListaDias(aux_dtnumdia),
                                          OUTPUT TABLE tt-per-datas).

                     END.

              END.
              WHEN 22 THEN
              DO:
                 RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "20,22",
                                                  OUTPUT TABLE tt-per-datas).

                 FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                 IF (NOT AVAIL tt-per-datas) THEN
                    DO:
                       RUN RegraMediaSegundaFeiraChqDoc
                                         (INPUT par_cdcooper,
                                          INPUT par_dtmvtolt,
                                          INPUT fnBuscaListaDias(aux_dtnumdia),
                                          OUTPUT TABLE tt-per-datas).

                    END.

              END.
              WHEN 28 OR
              WHEN 29 THEN
              DO:
                 IF fnBuscaDataDoUltimoDiaMes(par_dtmvtolt) = par_dtmvtolt THEN
                    DO:
                       RUN RegraMediaSegundaFeiraChqDoc
                                                 (INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT 30,
                                                  OUTPUT TABLE tt-per-datas).

                       FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                       IF (NOT AVAIL tt-per-datas) THEN
                          DO:
                            RUN RegraMediaSegundaFeiraChqDoc
                                                 (INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT fnBuscaListaDias(30),
                                                  OUTPUT TABLE tt-per-datas).

                          END.

                    END.
                 ELSE
                    DO:
                       RUN RegraMediaSegundaFeiraChqDoc
                                                 (INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  OUTPUT TABLE tt-per-datas).

                       FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                       IF (NOT AVAIL tt-per-datas) THEN
                          DO:
                             RUN RegraMediaDiaUtilSegundaFeira
                                (INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT fnCalculaDiaUtil(aux_dtnumdia),
                                 INPUT fnBuscaLimiteMinimo(aux_dtnumdia),
                                 INPUT fnBuscalimiteMaximo(aux_dtnumdia),
                                 OUTPUT TABLE tt-per-datas).

                             FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                             IF (NOT AVAIL tt-per-datas) THEN
                                DO:
                                  RUN RegraMediaSegundaFeiraChqDoc
                                     (INPUT par_cdcooper,
                                      INPUT par_dtmvtolt,
                                      INPUT fnBuscaListaDias(aux_dtnumdia),
                                      OUTPUT TABLE tt-per-datas).

                                END.

                          END.

                    END.

              END.
              WHEN 30 THEN
              DO:
                 RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  OUTPUT TABLE tt-per-datas).

                 FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                 IF (NOT AVAIL tt-per-datas) THEN
                    DO:
                       RUN RegraMediaSegundaFeiraChqDoc
                                     (INPUT par_cdcooper,
                                      INPUT par_dtmvtolt,
                                      INPUT fnBuscaListaDias(aux_dtnumdia),
                                      OUTPUT TABLE tt-per-datas).

                    END.

              END.
              WHEN 31 THEN
              DO:
                 RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "30,31",
                                                  OUTPUT TABLE tt-per-datas).

                 FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                 IF (NOT AVAIL tt-per-datas) THEN
                    DO:
                       RUN RegraMediaSegundaFeiraChqDoc
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolt,
                                         INPUT fnBuscaListaDias(aux_dtnumdia),
                                         OUTPUT TABLE tt-per-datas).

                    END.

              END.
              OTHERWISE
              DO:
                 RUN RegraMediaSegundaFeiraChqDoc(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT STRING(aux_dtnumdia),
                                                  OUTPUT TABLE tt-per-datas).

                 FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                 IF (NOT AVAIL tt-per-datas) THEN
                    DO:
                       RUN RegraMediaDiaUtilSegundaFeira
                                     (INPUT par_cdcooper,
                                      INPUT par_dtmvtolt,
                                      INPUT fnCalculaDiaUtil(aux_dtnumdia),
                                      INPUT fnBuscaLimiteMinimo(aux_dtnumdia),
                                      INPUT fnBuscalimiteMaximo(aux_dtnumdia),
                                      OUTPUT TABLE tt-per-datas).

                       FIND LAST tt-per-datas WHERE tt-per-datas.nrsequen > 1 NO-LOCK NO-ERROR.

                       IF (NOT AVAIL tt-per-datas) THEN
                          DO:
                             RUN RegraMediaSegundaFeiraChqDoc
                                 (INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT fnBuscaListaDias(aux_dtnumdia),
                                  OUTPUT TABLE tt-per-datas).

                          END.

                    END.

              END.

         END CASE.

      END.

END.

PROCEDURE gera-periodos-projecao-itg:

   DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
   DEF  INPUT PARAM par_cdagrupa AS INT             NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-per-datas.

   DEF VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
   DEF VAR aux_dtsemdia AS INTE FORMAT "9"          NO-UNDO.
   DEF VAR aux_listadia AS CHAR                     NO-UNDO.
   DEF VAR aux_dtperiod AS DATE FORMAT 99/99/9999   NO-UNDO.
   DEF VAR aux_sequenci AS INTE INIT 0              NO-UNDO.

   EMPTY TEMP-TABLE tt-per-datas. 


   IF par_dtmvtolt = fnRetornaUltimoDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt))  THEN
      DO:
         ASSIGN aux_dtperiod = fnRetornaUltimoDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt) - 1).

         ASSIGN aux_sequenci = fnRetornaProximaSequencia().
       
         FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod
                                       NO-LOCK NO-ERROR.
      
         IF NOT AVAIL tt-per-datas THEN
            DO:
              CREATE tt-per-datas.
         
              ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                     tt-per-datas.dtmvtolt = aux_dtperiod.

            END.

        
         RETURN "OK".
         
      END.
   ELSE 
      IF par_dtmvtolt = fnRetornaPrimeiroDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt))  THEN
         DO: 
            ASSIGN aux_sequenci = fnRetornaProximaSequencia()
                   aux_dtperiod = fnRetornaPrimeiroDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt) - 1).
            
            FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod
                                          NO-LOCK NO-ERROR.
          
            IF NOT AVAIL tt-per-datas THEN
               DO:
                  CREATE tt-per-datas.
              
                  ASSIGN tt-per-datas.nrsequen = aux_sequenci 
                         tt-per-datas.dtmvtolt = aux_dtperiod.

               END.

            RETURN "OK".

         END.
   ELSE
      IF fnDiaAnteriorEhFeriado(par_cdcooper, par_dtmvtolt) THEN
         DO:
           RUN gera-periodos-projecao-itg(INPUT par_cdcooper, 
                                          INPUT fnBuscaDataAnteriorFeriado(par_cdcooper, par_dtmvtolt),
                                          INPUT par_cdagrupa + 1,
                                          OUTPUT TABLE tt-per-datas).

         END.
   
   ASSIGN aux_dtnumdia = DAY(par_dtmvtolt)
          aux_dtsemdia = WEEKDAY(par_dtmvtolt).

   IF (aux_dtsemdia <> 2) THEN
      DO:
         ASSIGN aux_listadia = STRING(DAY(par_dtmvtolt)).
         
         IF ((aux_dtnumdia = 28) OR (aux_dtnumdia = 29)) AND 
            (fnBuscaDataDoUltimoDiaMes(par_dtmvtolt) = par_dtmvtolt) THEN
           DO:
              RUN RegraMediaDiasUteisDaSemanaItg(INPUT par_cdcooper,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "3,4,5,6",
                                                 INPUT 30,
                                                 INPUT par_cdagrupa,
                                                 OUTPUT TABLE tt-per-datas).
                                            
           END.
         ELSE
            DO:
               RUN RegraMediaDiasUteisDaSemanaItg(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "3,4,5,6",
                                                  INPUT aux_listadia,
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).

           END.
         
      END.
   ELSE
      DO:
         CASE aux_dtnumdia:

              WHEN 1  OR
              WHEN 2  OR
              WHEN 3  THEN
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              INPUT "1,2,3",
                                              INPUT par_cdagrupa,
                                              OUTPUT TABLE tt-per-datas).

              END.
              WHEN 4 THEN
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "1,2,3,4",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 5 OR
              WHEN 6 OR 
              WHEN 7 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "5,6,7",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 8  OR
              WHEN 9  THEN
              DO:
                   RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "8,9",
                                                 INPUT par_cdagrupa,
                                                 OUTPUT TABLE tt-per-datas).

              END.
              WHEN 10 OR
              WHEN 11 OR
              WHEN 12 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "10,11,12",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 13 OR
              WHEN 14 THEN
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "13,14",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 15 OR
              WHEN 16 OR
              WHEN 17 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "15,16,17",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 18 OR
              WHEN 19 THEN
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "18,19",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 20 OR
              WHEN 21 OR
              WHEN 22 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "20,21,22",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 23 OR
              WHEN 24 THEN
              DO:
                       
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "23,24",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).
                 
              END.
              WHEN 25 OR
              WHEN 26 OR
              WHEN 27 THEN 
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "25,26,27",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.
              WHEN 28 OR
              WHEN 29 THEN
              DO:
                 IF fnBuscaDataDoUltimoDiaMes(par_dtmvtolt) = par_dtmvtolt THEN     
                    DO:
                       RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                                     INPUT par_dtmvtolt,
                                                     INPUT "30,31",
                                                     INPUT par_cdagrupa,
                                                     OUTPUT TABLE tt-per-datas).

                    END.
                 ELSE 
                    RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "28,29",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).
                 
              END.
              WHEN 30 OR
              WHEN 31 THEN
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT "30,31",
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).
              END.
              OTHERWISE
              DO:
                 RUN RegraMediaSegundaFeiraItg(INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT STRING(aux_dtnumdia),
                                               INPUT par_cdagrupa,
                                               OUTPUT TABLE tt-per-datas).

              END.

         END CASE.

      END.

END.


PROCEDURE RegraMediaDiasUteisDaSemanaItg:

    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_nrdiasse AS CHAR            NO-UNDO.
    DEF  INPUT PARAM par_nrdiasme AS CHAR            NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:

       IF (NUM-ENTRIES(par_nrdiasme) = 2) THEN
          DO:
             IF fnValidaRegraMediaDiasUteisDaSemanaItg(INPUT par_nrdiasme,
                                                       INPUT par_nrdiasse,
                                                       INPUT aux_dtperiod,
                                                       INPUT par_cdcooper)  AND
               (fnValidaRegraMediaDiasUteisDaSemanaItg(INPUT par_nrdiasme,
                                                       INPUT par_nrdiasse,
                                                       INPUT aux_dtperiod + 1,
                                                       INPUT par_cdcooper)) THEN
                DO:
                   ASSIGN aux_nrsequen = fnRetornaProximaSequencia().

                   FIND FIRST tt-per-datas 
                        WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                              NO-LOCK NO-ERROR.

                   IF NOT AVAIL tt-per-datas THEN
                      DO:
                         CREATE tt-per-datas.

                         ASSIGN tt-per-datas.nrsequen = aux_nrsequen 
                                tt-per-datas.dtmvtolt = aux_dtperiod
                                tt-per-datas.cdagrupa = par_cdagrupa.
                      END.

                   ASSIGN aux_nrsequen = fnRetornaProximaSequencia().

                   FIND FIRST tt-per-datas 
                        WHERE tt-per-datas.dtmvtolt = aux_dtperiod + 1 
                              NO-LOCK NO-ERROR.

                   IF NOT AVAIL tt-per-datas THEN
                      DO:
                         CREATE tt-per-datas.

                         ASSIGN tt-per-datas.nrsequen = aux_nrsequen 
                                tt-per-datas.dtmvtolt = aux_dtperiod + 1
                                tt-per-datas.cdagrupa = par_cdagrupa.

                      END.

                 END.

          END.
        ELSE
           IF fnValidaRegraMediaDiasUteisDaSemanaItg(INPUT par_nrdiasme,
                                                     INPUT par_nrdiasse,
                                                     INPUT aux_dtperiod,
                                                     INPUT par_cdcooper) THEN
              DO:
                 ASSIGN aux_nrsequen = fnRetornaProximaSequencia().

                 FIND FIRST tt-per-datas 
                      WHERE tt-per-datas.dtmvtolt = aux_dtperiod 
                            NO-LOCK NO-ERROR.

                 IF NOT AVAIL tt-per-datas THEN
                    DO:
                       CREATE tt-per-datas.

                       ASSIGN tt-per-datas.nrsequen = aux_nrsequen 
                              tt-per-datas.dtmvtolt = aux_dtperiod
                              tt-per-datas.cdagrupa = par_cdagrupa.

                    END.

              END.

        ASSIGN aux_dtperiod = aux_dtperiod + 1.

    END.

    RETURN "OK".

END.

PROCEDURE pi_diversos_f:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_tpdmovto AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_vlrepass AS DEC EXTENT 4                   NO-UNDO. 
   DEF  INPUT PARAM par_vlnumera AS DEC EXTENT 4                   NO-UNDO.
   DEF  INPUT PARAM par_vlrfolha AS DEC EXTENT 4                   NO-UNDO.
   DEF  INPUT PARAM par_vloutros AS DEC EXTENT 4                   NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dscritic AS CHAR                                   NO-UNDO.
   DEF  VAR aux_cdbccxlt AS CHAR INIT "01,85,756,100"              NO-UNDO.
   DEF  VAR aux_contador AS INT                                    NO-UNDO.
   DEF  VAR aux_tpdmovto AS INT                                    NO-UNDO.
   DEF  VAR aux_hrpermit AS LOG                                    NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_dscritic = ""
          aux_tpdmovto = 0
          aux_contador = 0.

   IF NOT valida_horario 
   ( INPUT par_cdcooper,                            
     INPUT TIME,
     OUTPUT aux_hrpermit,
     OUTPUT aux_dscritic) THEN
     DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".

     END.


   CASE par_tpdmovto:

            WHEN "E"   THEN   ASSIGN aux_tpdmovto = 1.
            WHEN "S"   THEN   ASSIGN aux_tpdmovto = 2.

   END CASE.


   IF par_nmdatela = "PREVIS" THEN
      DO:
         DO aux_contador = 1 TO NUM-ENTRIES(aux_cdbccxlt,","):
         
            RUN grava-movimentacao 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT par_dtmvtolt,
                 INPUT aux_tpdmovto,
                 INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                 INPUT 12,
                 INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                           par_vlrepass[1]
                        ELSE
                          IF ENTRY(aux_contador,aux_cdbccxlt) = "01" THEN
                             par_vlrepass[2]
                          ELSE
                             IF ENTRY(aux_contador,aux_cdbccxlt) = "756" THEN
                                par_vlrepass[3]
                             ELSE
                                IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                   par_vlrepass[4]
                                ELSE
                                   0)).
            
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND LAST tt-erro NO-LOCK NO-ERROR.
                  
                  IF AVAIL tt-erro THEN
                     ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
                  ELSE
                     ASSIGN aux_nrsequen = aux_nrsequen + 1.

                  ASSIGN aux_dscritic = "Nao foi possivel gravar o " +
                                        "valor do repasse de "       +
                                        "recursos.".
            
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT aux_nrsequen,
                                 INPUT 0,
                                 INPUT-OUTPUT aux_dscritic).
                  
               END.
         
            RUN grava-movimentacao 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT par_dtmvtolt,
                 INPUT aux_tpdmovto,
                 INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                 INPUT 13,
                 INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                           par_vlnumera[1]
                        ELSE
                          IF ENTRY(aux_contador,aux_cdbccxlt) = "01" THEN
                             par_vlnumera[2]
                          ELSE
                             IF ENTRY(aux_contador,aux_cdbccxlt) = "756" THEN
                                par_vlnumera[3]
                             ELSE
                                IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                   par_vlnumera[4]
                                 ELSE
                                    0)).
            
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND LAST tt-erro NO-LOCK NO-ERROR.
                  
                  IF AVAIL tt-erro THEN
                     ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
                  ELSE
                     ASSIGN aux_nrsequen = aux_nrsequen + 1.

                  IF aux_tpdmovto = 1 THEN
                     ASSIGN aux_dscritic = "Nao foi possivel gravar o valor do " + 
                                           "deposito numerario.".
                  ELSE
                     ASSIGN aux_dscritic = "Nao foi possivel gravar o " + 
                                           "valor do alivio de numerario.".

                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT aux_nrsequen,
                                 INPUT 0,
                                 INPUT-OUTPUT aux_dscritic).
                  
            END.
                
            RUN grava-movimentacao 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT par_dtmvtolt,
                 INPUT aux_tpdmovto,
                 INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                 INPUT 14,
                 INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                           par_vlrfolha[1]
                        ELSE
                          IF ENTRY(aux_contador,aux_cdbccxlt) = "01" THEN
                             par_vlrfolha[2]
                          ELSE
                             IF ENTRY(aux_contador,aux_cdbccxlt) = "756" THEN
                                par_vlrfolha[3]
                             ELSE
                                IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                   par_vlrfolha[4]
                                 ELSE
                                    0)).
            
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND LAST tt-erro NO-LOCK NO-ERROR.
                  
                  IF AVAIL tt-erro THEN
                     ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
                  ELSE
                     ASSIGN aux_nrsequen = aux_nrsequen + 1.

                  IF aux_tpdmovto = 1 THEN
                     ASSIGN aux_dscritic = "Nao foi possivel gravar o " + 
                                           "valor da folha de pagamento.".
                  ELSE
                     ASSIGN aux_dscritic = "Nao foi possivel gravar o " +
                                           "valor do saque numerario.".
            
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT aux_nrsequen,
                                 INPUT 0,
                                 INPUT-OUTPUT aux_dscritic).
                  
               END.
         
            RUN grava-movimentacao 
                (INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT par_dtmvtolt,
                 INPUT aux_tpdmovto,
                 INPUT INT(ENTRY(aux_contador,aux_cdbccxlt)),
                 INPUT 15,
                 INPUT (IF ENTRY(aux_contador,aux_cdbccxlt) = "85" THEN
                           par_vloutros[1]
                        ELSE
                          IF ENTRY(aux_contador,aux_cdbccxlt) = "01" THEN
                             par_vloutros[2]
                          ELSE
                             IF ENTRY(aux_contador,aux_cdbccxlt) = "756" THEN
                                par_vloutros[3]
                             ELSE
                                IF ENTRY(aux_contador,aux_cdbccxlt) = "100" THEN
                                   par_vloutros[4]
                                ELSE
                                   0)).
            
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND LAST tt-erro NO-LOCK NO-ERROR.
                  
                  IF AVAIL tt-erro THEN
                     ASSIGN aux_nrsequen = tt-erro.nrsequen + 1.
                  ELSE
                     ASSIGN aux_nrsequen = aux_nrsequen + 1.

                  ASSIGN aux_dscritic = "Nao foi possivel gravar o " + 
                                        "valor Outros.".
              
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT aux_nrsequen,
                                 INPUT 0,
                                 INPUT-OUTPUT aux_dscritic).
              
               END.
                
         END.

   END.
  
   RETURN "OK".


END PROCEDURE.


PROCEDURE verifica_acesso:

   DEF INPUT PARAM par_cdcooper AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                              NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_nmoperad AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_cdcoopex AS INT                              NO-UNDO.
   DEF OUTPUT PARAM par_permiace AS LOG                             NO-UNDO.
   DEF OUTPUT PARAM par_dstextab AS CHAR                            NO-UNDO.
   DEF OUTPUT PARAM par_msgaviso AS CHAR                            NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_contador AS INT                                      NO-UNDO.
   DEF VAR aux_cdcritic AS INT                                      NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.


   ASSIGN aux_contador = 0
          aux_cdcritic = 0
          par_permiace = TRUE.

   EMPTY TEMP-TABLE tt-erro.

   IF par_cdcoopex = 0 OR
      par_cdcoopex = 3 THEN
      DO:
         FOR EACH crapcop NO-LOCK:

             FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.tptabela = "GENERI"         AND
                                craptab.cdempres = 00               AND
                                craptab.cdacesso = "PREVISOPCAOF"      
                                NO-LOCK NO-ERROR.
             
             IF craptab.dstextab <> "" THEN
                DO:
                   ASSIGN par_dstextab = "Esta tela esta sendo usada " + 
                                         "pelo operador "              + 
                                         craptab.dstextab
                          par_msgaviso = "Aguarde ou pressione " + 
                                         "F4/END para sair..."
                          par_permiace = FALSE.

                   RETURN "OK".
             
                END.
               
         END.

      END.

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
                ASSIGN aux_cdcritic = 0.
                
                IF craptab.dstextab <> ""           AND
                  ((par_cdcoopex = 0                OR
                    par_cdcoopex = 3)               OR
                   crapcop.cdcooper = par_cdcoopex) THEN
                   DO:    
                      ASSIGN par_dstextab = "Esta tela esta sendo usada " + 
                                            "pelo operador "              + 
                                            craptab.dstextab
                             par_msgaviso = "Aguarde ou pressione " + 
                                            "F4/END para sair..."
                             par_permiace = FALSE.
                               
                   END.   
                ELSE
                   DO:
                      FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
                      IF AVAILABLE craptab THEN
                         craptab.dstextab = STRING(par_cdoperad,"x(10)") + 
                                            "-" + par_nmoperad.
                             
                   END.
       
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


PROCEDURE grava_apli_resg:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_vlresgat AS DEC                            NO-UNDO.
   DEF  INPUT PARAM par_vlresgan AS DEC                            NO-UNDO.
   DEF  INPUT PARAM par_vlaplica AS DEC                            NO-UNDO.
   DEF  INPUT PARAM par_vlaplian AS DEC                            NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dscritic AS CHAR                                   NO-UNDO.
   DEF  VAR aux_cdcritic AS INT                                    NO-UNDO.
   DEF  VAR aux_hrpermit AS LOG                                    NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_dscritic = ""
          aux_cdcritic = 0.

   IF NOT valida_horario 
    ( INPUT par_cdcooper,                            
      INPUT TIME,
      OUTPUT aux_hrpermit,
      OUTPUT aux_dscritic) THEN
      DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT 0,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

      END.
   
   IF par_vlresgat > 0  OR 
     (par_vlresgat = 0  AND 
      par_vlaplica = 0) THEN
      DO:
         RUN grava_resgate(INPUT par_cdcooper, 
                           INPUT par_cdagenci, 
                           INPUT par_nrdcaixa, 
                           INPUT par_cdoperad, 
                           INPUT par_nmdatela, 
                           INPUT par_dtmvtolt, 
                           INPUT par_dtmvtolx, 
                           INPUT par_vlresgat, 
                           INPUT par_vlresgan, 
                           OUTPUT TABLE tt-erro).
      
         IF RETURN-VALUE <> "OK" THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF NOT AVAIL tt-erro THEN
                  DO:
                     ASSIGN aux_dscritic = "Nao foi possivel gravar o valor " +
                                           "do resgate.".
                      
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,
                                    INPUT 0,
                                    INPUT-OUTPUT aux_dscritic).

                  END.

               RETURN "NOK".
               
            END.

      END.

   IF par_vlaplica > 0 THEN
      DO:
         RUN grava_aplicacao(INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_dtmvtolt,
                             INPUT par_dtmvtolx,
                             INPUT par_vlaplica,
                             INPUT par_vlaplian,
                             OUTPUT TABLE tt-erro).
         
         IF RETURN-VALUE <> "OK" THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF NOT AVAIL tt-erro THEN
                  DO:
                     ASSIGN aux_dscritic = "Nao foi possivel gravar o valor " +
                                           "da aplicacao.".
                     
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,
                                    INPUT 0,
                                    INPUT-OUTPUT aux_dscritic).

                  END.

               RETURN "NOK".
               
            END.

      END.

   RETURN "OK".


END PROCEDURE.


PROCEDURE grava_resgate:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_vlresgat AS DEC                            NO-UNDO.
   DEF  INPUT PARAM par_vlresgan AS DEC                            NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dscritic AS CHAR                                   NO-UNDO.
   DEF  VAR aux_cdcritic AS INT                                    NO-UNDO.
   
   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_dscritic = ""
          aux_cdcritic = 0.
   
   RUN grava_consolidado_singular (INPUT par_cdcooper,
                                   INPUT par_dtmvtolx,
                                   INPUT 4,
                                   INPUT par_vlresgat).
      
   IF RETURN-VALUE <> "OK" THEN
      DO:
         ASSIGN aux_dscritic = "Nao foi possivel gravar o valor do resgate".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

      END.

   DO aux_contador = 1 TO 10:

      FIND crapffc WHERE crapffc.cdcooper = par_cdcooper AND
                         crapffc.dtmvtolt = par_dtmvtolx
                         EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
   
      IF NOT AVAILABLE crapffc THEN
         DO:
            IF LOCKED crapffc THEN
               DO:
                  ASSIGN aux_cdcritic = 77.
                  PAUSE 1 NO-MESSAGE.
                  NEXT.
   
               END.
            ELSE
              DO: 
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Nao foi possivel atualizar " + 
                                       "a tabela de fluxo consolidado.".
                 LEAVE.
   
              END.
         END.
      ELSE
         DO: 
             FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad
                                NO-LOCK NO-ERROR.

             ASSIGN aux_cdcritic = 0 
                    aux_dscritic = ""
                    crapffc.cdagenci = (IF AVAIL crapope THEN
                                           crapope.cdpactra 
                                        ELSE
                                           0)
                    crapffc.cdoperad = par_cdoperad
                    crapffc.hrtransa = TIME.

             LEAVE.

         END.

    END.


   IF aux_cdcritic <> 0  OR 
      aux_dscritic <> "" THEN
      DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT 0,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

      END.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                      NO-LOCK NO-ERROR.
   
   
   UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")           +
                     " "     + STRING(TIME,"HH:MM:SS")   + "' --> '"       +
                     "Operador "  + par_cdoperad         + " - "           +
                     "alterou o valor do resgate de "                      +
                     STRING(par_vlresgan,"zzzz,zzz,zzz,zz9.99")            +
                     " para " + STRING(par_vlresgat,"zzzz,zzz,zzz,zz9.99") +
                     ". >> /usr/coop/" + TRIM(crapcop.dsdircop)            +
                     "/log/previs.log"). 
                     
                        
   RETURN "OK".


END PROCEDURE.


PROCEDURE grava_aplicacao:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_vlaplica AS DEC                            NO-UNDO.
   DEF  INPUT PARAM par_vlaplian AS DEC                            NO-UNDO.
   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dscritic AS CHAR                                   NO-UNDO.
   DEF  VAR aux_cdcritic AS INT                                    NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_dscritic = ""
          aux_cdcritic = 0.

   RUN grava_consolidado_singular (INPUT par_cdcooper,
                                   INPUT par_dtmvtolx,
                                   INPUT 5,
                                   INPUT par_vlaplica).
      

   IF RETURN-VALUE <> "OK" THEN
      DO:
         ASSIGN aux_dscritic = "Nao foi possivel gravar o valor da aplicacao.".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT 0,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".

      END.
          
   DO aux_contador = 1 TO 10:

      FIND crapffc WHERE crapffc.cdcooper = par_cdcooper AND
                         crapffc.dtmvtolt = par_dtmvtolx
                         EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
   
      IF NOT AVAILABLE crapffc THEN
         DO:
            IF LOCKED crapffc THEN
               DO:
                  ASSIGN aux_cdcritic = 77.
                  PAUSE 1 NO-MESSAGE.
                  NEXT.
   
               END.
            ELSE
              DO: 
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Nao foi possivel atualizar " + 
                                       "a tabela de fluxo consolidado.".
                 LEAVE.
   
              END.
         END.
      ELSE
         DO: 
             FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad
                                NO-LOCK NO-ERROR.

             ASSIGN aux_cdcritic = 0 
                    aux_dscritic = ""
                    crapffc.cdagenci = (IF AVAIL crapope THEN
                                           crapope.cdpactra
                                        ELSE
                                           0)
                    crapffc.cdoperad = par_cdoperad
                    crapffc.hrtransa = TIME.

             LEAVE.

         END.

   END.


   IF aux_cdcritic <> 0  OR 
      aux_dscritic <> "" THEN
      DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT 0,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

      END.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                      NO-LOCK NO-ERROR.
   
   UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")           +
                     " "     + STRING(TIME,"HH:MM:SS")   + "' --> '"       +
                     "Operador "  + par_cdoperad         + " - "           +
                     "alterou o valor da aplicacao de "                    +
                     STRING(par_vlaplian,"zzzz,zzz,zzz,zz9.99")            +
                     " para " + STRING(par_vlaplica,"zzzz,zzz,zzz,zz9.99") +
                     ". >> /usr/coop/" + TRIM(crapcop.dsdircop)            +
                     "/log/previs.log").


   RETURN "OK".


END PROCEDURE.


/*Todos os erros gerados atraves da opcao F na tela previs deverao ser mostrados
ao final da operacao. Devido a algumas procedures usadas pela opcao F chamarem
procedures de outras BO's que acabam limpando a tt-erro, foi-se necessario 
criar um tabela auxiliar para controlar os erros.*/
PROCEDURE atualiza_tabela_erros:

   DEF INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
   DEF INPUT PARAM par_attterro AS LOG                            NO-UNDO.
   
   IF par_attterro = FALSE THEN
      DO:
         EMPTY TEMP-TABLE tt-auxerros.

         IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
            FOR EACH tt-erro NO-LOCK:
            
                CREATE tt-auxerros.

                BUFFER-COPY tt-erro TO tt-auxerros.

            END.
        
      END.
   ELSE
      DO:
         IF TEMP-TABLE tt-auxerros:HAS-RECORDS THEN
            DO:
               FOR EACH tt-auxerros NO-LOCK BY tt-auxerros.nrsequen:
               
                   CREATE tt-erro.
               
                   BUFFER-COPY tt-auxerros EXCEPT tt-auxerros.cdcooper
                                                  TO tt-erro.
                   
                   ASSIGN tt-erro.cdcooper = par_cdcooper.

               END.

               EMPTY TEMP-TABLE tt-auxerros.


            END.
         

      END.


   RETURN "OK".


END PROCEDURE.


/*--------------------------------------------------------------------------
                                FUNCCOES 
  -------------------------------------------------------------------------*/

FUNCTION valida_horario RETURNS LOGICAL 
   (INPUT par_cdcooper AS INT,                            
    INPUT par_hrmvtolt AS INT,
    OUTPUT par_hrpermit AS LOG,
    OUTPUT par_dscritic AS CHAR):                            

   DEF VAR aux_hrlimite AS INT                                      NO-UNDO.

   ASSIGN aux_hrlimite = 0.
          
   
   FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 00              AND
                      craptab.cdacesso = "PARFLUXOFINAN" AND
                      craptab.tpregist = 0 
                      NO-LOCK NO-ERROR.
               
   IF AVAIL craptab THEN
      DO:
         IF INT(ENTRY(1,ENTRY(8,craptab.dstextab,";"),":")) = 0 THEN
            ASSIGN aux_hrlimite = (24 * 3600) +
                                  (INT(ENTRY(2,ENTRY(8,craptab.dstextab,";"),":")) * 60).  
         ELSE
            ASSIGN aux_hrlimite = (INT(ENTRY(1,ENTRY(8,craptab.dstextab,";"),":")) * 
                                   3600) +
                                  (INT(ENTRY(2,ENTRY(8,craptab.dstextab,";"),":")) * 
                                   60).
         
         ASSIGN par_hrpermit = par_hrmvtolt <= aux_hrlimite.

         IF par_hrpermit = FALSE THEN
            ASSIGN par_dscritic = "676 - Horario esgotado para digitacao.".

      END.

   RETURN par_hrpermit.


END FUNCTION.


FUNCTION fnEhDataUtil RETURN LOG PRIVATE
   (INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE):

    DEF VAR aux_result AS LOG                                NO-UNDO.

    IF CAN-DO("1,7",STRING(WEEKDAY(par_dtrefmes)))             OR
       CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                              crapfer.dtferiad = par_dtrefmes) THEN
       ASSIGN aux_result = FALSE.
    ELSE
       ASSIGN aux_result = TRUE.


    RETURN aux_result.


END FUNCTION.


FUNCTION fnRetornaNumeroDiaUtilTitulo INTEGER PRIVATE 
   (INPUT par_cdcooper AS INT,
    INPUT par_numdiaut AS INT,
    INPUT par_dtdatmes AS DATE):

    DEF VAR aux_contador AS INT  INIT 0                      NO-UNDO.
    DEF VAR aux_dtverdat AS DATE                             NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(MONTH(par_dtdatmes), 01, YEAR(par_dtdatmes)).
                                                
    DO WHILE MONTH(aux_dtverdat) = MONTH(par_dtdatmes):
    
        IF NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat)))              AND 
           NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                      crapfer.dtferiad = aux_dtverdat)  THEN
           DO:
               ASSIGN aux_contador = aux_contador + 1.

               IF aux_contador = par_numdiaut THEN
                  LEAVE.

           END.
           
        ASSIGN aux_dtverdat = aux_dtverdat + 1.
                
    END. 

    RETURN DAY(aux_dtverdat).
    
END FUNCTION.


FUNCTION fnEhFeriado RETURN LOG PRIVATE
   (INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE):

    RETURN CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                  crapfer.dtferiad = par_dtrefmes).


END FUNCTION.


FUNCTION fnRetornaProximaSequencia RETURN INT PRIVATE:

    FIND LAST tt-per-datas NO-LOCK NO-ERROR.
    
    IF AVAIL tt-per-datas THEN
       RETURN  tt-per-datas.nrsequen + 1.
    ELSE
       RETURN  1.

END FUNCTION.


FUNCTION fnDiaAnteriorEhFeriado RETURN LOG PRIVATE 
   (INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE):

    DEF VAR aux_datautil AS DATE                            NO-UNDO.

    /* Dia anterior */
    ASSIGN aux_datautil = par_dtrefmes - 1.
    
    /* Domingo */
    IF WEEKDAY(aux_datautil) = 1 THEN
       ASSIGN aux_datautil = aux_datautil - 2.
    ELSE
    /* Sabado */ 
    IF WEEKDAY(aux_datautil) = 7 THEN
       ASSIGN aux_datautil = aux_datautil - 1.

    
    RETURN fnEhFeriado(par_cdcooper, aux_datautil).

END FUNCTION.


FUNCTION fnValidaRegraMediaDiasUteisDaSemanaTitulo RETURN LOG PRIVATE 
   (INPUT par_nrdiasme AS CHAR,
    INPUT par_nrdiasse AS CHAR,
    INPUT par_dtperiod AS DATE,
    INPUT par_cdcooper AS INTE):
    
    RETURN CAN-DO(par_nrdiasme, STRING(DAY(par_dtperiod)))         AND
           CAN-DO(par_nrdiasse, STRING(WEEKDAY(par_dtperiod)))     AND
           fnEhDataUtil(par_cdcooper, par_dtperiod)                AND
           NOT fnDiaAnteriorEhFeriado(par_cdcooper, par_dtperiod).
    
END FUNCTION.


FUNCTION fnValidaDiasUteisMes RETURN LOGICAL PRIVATE
  (INPUT par_cdcooper AS INT,
   INPUT par_dtdatmes AS DATE):

   DEF VAR aux_contador AS INT  INIT 0 NO-UNDO.
   DEF VAR aux_dtverdat AS DATE        NO-UNDO.
   
   ASSIGN aux_dtverdat = DATE(MONTH(par_dtdatmes), 01, YEAR(par_dtdatmes)).
                                               
   DO WHILE MONTH(aux_dtverdat) = MONTH(par_dtdatmes):
   
      IF NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat)))             AND 
         NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                    crapfer.dtferiad = aux_dtverdat) THEN
         DO:
             ASSIGN aux_contador = aux_contador + 1.

         END.
         
      ASSIGN aux_dtverdat = aux_dtverdat + 1.
               
   END. 
   
   RETURN (aux_contador >= 20).


END FUNCTION.


FUNCTION fnDataExiste RETURN LOG PRIVATE
   (INPUT par_mes AS INT,
    INPUT par_dia AS INT,
    INPUT par_ano AS INT) : 
   
  DEF VAR aux_dtcalcul AS DATE INIT ?                           NO-UNDO.
  
  DO ON ERROR UNDO, LEAVE:
     
     ASSIGN aux_dtcalcul = DATE(par_mes, par_dia, par_ano).
      
     CATCH eAnyError AS Progress.Lang.ERROR:

           ASSIGN aux_dtcalcul = ?.
           DELETE OBJECT eAnyError.

     END CATCH.

  END.

  RETURN (aux_dtcalcul <> ?).

END FUNCTION.

/***********************************************/

FUNCTION fnCalculaDiaUtil INTEGER PRIVATE 
  ( INPUT par_dtdiames AS INT):

   CASE par_dtdiames:

       WHEN 1  OR
       WHEN 2  OR
       WHEN 3  THEN
           RETURN 0. 
       WHEN 4 THEN
           RETURN 2.
       WHEN 5 THEN
           RETURN 3.
       WHEN 6 THEN
           RETURN 4.
       WHEN 7 THEN
           RETURN 5.
       WHEN 8 THEN
           RETURN 6.
       WHEN 9 THEN
           RETURN 6.
       WHEN 10 THEN
           RETURN 7.
       WHEN 11 THEN
           RETURN 7.
       WHEN 12 THEN
           RETURN 8.
       WHEN 13 THEN
           RETURN 9.
       WHEN 14 THEN
           RETURN 10.
       WHEN 15 THEN
           RETURN 0.
       WHEN 16 THEN
           RETURN 11.
       WHEN 17 THEN
           RETURN 12.
       WHEN 18 THEN
           RETURN 12.
       WHEN 19 THEN
           RETURN 13.
       WHEN 20 THEN
           RETURN 14.
       WHEN 21 THEN
           RETURN 0.
       WHEN 22 THEN
           RETURN 0.
       WHEN 23 THEN
           RETURN 16.
       WHEN 24 THEN
           RETURN 16.
       WHEN 25 THEN
           RETURN 17.
       WHEN 26 THEN
           RETURN 18.
       WHEN 27 THEN
           RETURN 19.
       WHEN 28 THEN
           RETURN 20.
       WHEN 29 THEN
           RETURN 21.
       WHEN 30 THEN
           RETURN 0.
       WHEN 31 THEN
           RETURN 0.
       OTHERWISE
           RETURN 0.

   END CASE.

END FUNCTION.

FUNCTION fnBuscaLimiteMinimo RETURN INT PRIVATE 
  ( INPUT par_dtdiames AS INT):

   CASE par_dtdiames:

       WHEN 1  OR
       WHEN 2  OR
       WHEN 3  THEN
           RETURN 0. 
       WHEN 4 THEN
           RETURN 0.
       WHEN 5 THEN
           RETURN 5.
       WHEN 6 THEN
           RETURN 5.
       WHEN 7 THEN
           RETURN 5.
       WHEN 8 THEN
           RETURN 5.
       WHEN 9 THEN
           RETURN 5.
       WHEN 10 THEN
           RETURN 9.
       WHEN 11 THEN
           RETURN 9.
       WHEN 12 THEN
           RETURN 9.
       WHEN 13 THEN
           RETURN 10.
       WHEN 14 THEN
           RETURN 10.
       WHEN 15 THEN
           RETURN 14.
       WHEN 16 THEN
           RETURN 14.
       WHEN 17 THEN
           RETURN 15.
       WHEN 18 THEN
           RETURN 15.
       WHEN 19 THEN
           RETURN 15.
       WHEN 20 THEN
           RETURN 19.
       WHEN 21 THEN
           RETURN 19.
       WHEN 22 THEN
           RETURN 20.
       WHEN 23 THEN
           RETURN 20.
       WHEN 24 THEN
           RETURN 20.
       WHEN 25 THEN
           RETURN 25.
       WHEN 26 THEN
           RETURN 25.
       WHEN 27 THEN
           RETURN 25.
       WHEN 28 THEN
           RETURN 25.
       WHEN 29 THEN
           RETURN 25.
       WHEN 30 THEN
           RETURN 25.
       WHEN 31 THEN
           RETURN 25.
       OTHERWISE
           RETURN 0.

   END CASE.

END FUNCTION.

FUNCTION fnBuscaLimiteMaximo RETURN INT PRIVATE 
  ( INPUT par_dtdiames AS INT):

    CASE par_dtdiames:

       WHEN 1  OR
       WHEN 2  OR
       WHEN 3  THEN
           RETURN 3. 
       WHEN 4 THEN
           RETURN 5.
       WHEN 5 THEN
           RETURN 10.
       WHEN 6 THEN
           RETURN 10.
       WHEN 7 THEN
           RETURN 10.
       WHEN 8 THEN
           RETURN 10.
       WHEN 9 THEN
           RETURN 10.
       WHEN 10 THEN
           RETURN 15.
       WHEN 11 THEN
           RETURN 15.
       WHEN 12 THEN
           RETURN 15.
       WHEN 13 THEN
           RETURN 15.
       WHEN 14 THEN
           RETURN 15.
       WHEN 15 THEN
           RETURN 19.
       WHEN 16 THEN
           RETURN 20.
       WHEN 17 THEN
           RETURN 20.
       WHEN 18 THEN
           RETURN 20.
       WHEN 19 THEN
           RETURN 20.
       WHEN 20 THEN
           RETURN 25.
       WHEN 21 THEN
           RETURN 25.
       WHEN 22 THEN
           RETURN 25.
       WHEN 23 THEN
           RETURN 25.
       WHEN 24 THEN
           RETURN 25.
       WHEN 25 THEN
           RETURN 30.
       WHEN 26 THEN
           RETURN 30.
       WHEN 27 THEN
           RETURN 30.
       WHEN 28 THEN
           RETURN 30.
       WHEN 29 THEN
           RETURN 31.
       WHEN 30 THEN
           RETURN 31.
       WHEN 31 THEN
           RETURN 99.
       OTHERWISE
           RETURN 99.

   END CASE.

END FUNCTION.

FUNCTION fnBuscaListaDias RETURN CHAR PRIVATE
  ( INPUT par_dtdiames AS INT):

    CASE par_dtdiames:

       WHEN 1  OR
       WHEN 2  OR
       WHEN 3  THEN
            RETURN "1,2,3".
       WHEN 4 THEN
            RETURN "1,2,3,4".
       WHEN 5 OR
       WHEN 6 OR
       WHEN 7 OR
       WHEN 8 OR
       WHEN 9 THEN
            RETURN "6,7,8,9".
       WHEN 10 OR
       WHEN 11 OR
       WHEN 12 THEN
            RETURN "10,11,12,13,14".
       WHEN 13 OR
       WHEN 14 THEN
            RETURN "11,12,13,14".
       WHEN 15 THEN
            RETURN "15,16,17,18".
       WHEN 16 THEN
            RETURN "15,16,17,18,19".
       WHEN 17 OR 
       WHEN 18 OR 
       WHEN 19 THEN
            RETURN "16,17,18,19".
       
       WHEN 20 OR
       WHEN 21 THEN
            RETURN "20,21,22,23,24".

       WHEN 22 OR
       WHEN 23 OR
       WHEN 24 THEN
            RETURN "21,22,23,24".
       WHEN 25 OR
       WHEN 26 OR
       WHEN 27 OR
       WHEN 28 THEN
           RETURN "26,27,28,29".
       WHEN 29 OR
       WHEN 30 THEN
            RETURN "26,27,28,29,30".
       WHEN 31 THEN
            RETURN "26,27,28,29,30,31".
       OTHERWISE
            RETURN STRING(par_dtdiames). 

   END CASE.

END FUNCTION.


FUNCTION fnBuscaDataDoUltimoDiaMes RETURN DATE PRIVATE 
  ( INPUT par_dtrefmes AS DATE):
  
    DEF VAR aux_dtcalcul AS DATE   NO-UNDO.
  
    /* Calcular o ultimo dia do mes */
    ASSIGN aux_dtcalcul = ((DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4) -
                            DAY(DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4)).
 
    RETURN aux_dtcalcul.

END. 

FUNCTION fnBuscaDataAnteriorFeriado RETURN DATE(INPUT par_cdcooper AS INT,
                                                INPUT par_dtrefmes AS DATE):

    DEF VAR aux_datautil AS DATE NO-UNDO.

    /* Dia anterior */
    ASSIGN aux_datautil = par_dtrefmes - 1.
    
    /* Domingo */
    IF WEEKDAY(aux_datautil) = 1 THEN
       ASSIGN aux_datautil = aux_datautil - 2.
    ELSE
    /* Sabado */ 
    IF WEEKDAY(aux_datautil) = 7 THEN
       ASSIGN aux_datautil = aux_datautil - 1.

    
   IF fnEhFeriado(par_cdcooper, aux_datautil) THEN
      RETURN aux_datautil.
   ELSE
      RETURN ?.

END FUNCTION.

FUNCTION fnRetornaNumeroDiaUtilChqDoc INTEGER PRIVATE 
  ( INPUT par_cdcooper AS INT,
    INPUT par_numdiaut AS INT,
    INPUT par_dtdatmes AS DATE):

    DEF VAR aux_contador AS INT  INIT 0                         NO-UNDO.
    DEF VAR aux_dtverdat AS DATE                                NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(MONTH(par_dtdatmes), 01, YEAR(par_dtdatmes)).
    
    DO WHILE MONTH(aux_dtverdat) = MONTH(par_dtdatmes):
    
       IF NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat)))             AND 
          NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                     crapfer.dtferiad = aux_dtverdat) THEN
          DO:
              ASSIGN aux_contador = aux_contador + 1.

              IF aux_contador = par_numdiaut THEN
                 LEAVE.

          END.
    
       ASSIGN aux_dtverdat = aux_dtverdat + 1.
                
    END. 

    IF aux_contador = par_numdiaut THEN
       RETURN DAY(aux_dtverdat).
    ELSE
       RETURN 0.

    
END FUNCTION.


FUNCTION fnValidaRegraMediaDiasUteisDaSemanaChqDoc RETURN LOG PRIVATE 
  ( INPUT par_nrdiasme AS CHAR,
    INPUT par_nrdiasse AS CHAR,
    INPUT par_dtperiod AS DATE,
    INPUT par_cdcooper AS INTE):
    
    RETURN CAN-DO(par_nrdiasme, STRING(DAY(par_dtperiod)))        AND
           CAN-DO(par_nrdiasse, STRING(WEEKDAY(par_dtperiod)))    AND
           fnEhDataUtil(par_cdcooper, par_dtperiod)               AND
           NOT fnDiaAnteriorEhFeriado(par_cdcooper, par_dtperiod) AND
           ((CAN-DO("1,2,3", par_nrdiasme)                        AND 
             fnValidaDiasUteisMes(par_cdcooper, par_dtperiod))    OR
           (NOT CAN-DO("1,2,3", par_nrdiasme))).

    
END FUNCTION.


FUNCTION fnRetornaProximaDataUtil RETURN DATE PRIVATE
  ( INPUT par_cdcooper AS INT,
    INPUT par_dtrefmes AS DATE):

    DEF VAR aux_datautil AS DATE NO-UNDO.

    ASSIGN aux_datautil = par_dtrefmes + 1.
   
    DO WHILE NOT fnEhDataUtil(par_cdcooper, aux_datautil) :

       ASSIGN aux_datautil = aux_datautil + 1.

    END.


    RETURN aux_datautil.
        

END FUNCTION.


FUNCTION fnRetornaNumeroDiaUtilItg RETURN INTEGER (INPUT par_cdcooper AS INT,
                                                   INPUT par_numdiaut AS INT,
                                                   INPUT par_dtdatmes AS DATE):
                                              
    DEF VAR aux_contador AS INT  INIT 0 NO-UNDO.
    DEF VAR aux_dtverdat AS DATE        NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(MONTH(par_dtdatmes), 01, YEAR(par_dtdatmes)).
                                                
    DO WHILE MONTH(aux_dtverdat) = MONTH(par_dtdatmes):
    
       IF NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat)))              AND 
          NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                      crapfer.dtferiad = aux_dtverdat) THEN
          DO:
             ASSIGN aux_contador = aux_contador + 1.

             IF aux_contador = par_numdiaut THEN
                LEAVE.

          END.
          
       ASSIGN aux_dtverdat = aux_dtverdat + 1.
                
    END. 

    RETURN DAY(aux_dtverdat).
    
END FUNCTION.


FUNCTION fnValidaRegraMediaDiasUteisDaSemanaItg RETURN LOG
         (INPUT par_nrdiasme AS CHAR,
          INPUT par_nrdiasse AS CHAR,
          INPUT par_dtperiod AS DATE,
          INPUT par_cdcooper AS INTE):
    
    RETURN CAN-DO(par_nrdiasme, STRING(DAY(par_dtperiod)))     AND 
           CAN-DO(par_nrdiasse, STRING(WEEKDAY(par_dtperiod))) AND 
           fnEhDataUtil(par_cdcooper, par_dtperiod)            AND
           NOT fnDiaAnteriorEhFeriado(par_cdcooper, par_dtperiod).
    
END FUNCTION.
