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
