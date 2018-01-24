/* ............................................................................

   Programa: Fontes/crps650.p
   Sistema : MITRA - GERACAO DE ARQUIVO
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : JULHO/2013                      Ultima atualizacao: 09/10/2017
   
   Dados referentes ao programa:

   Frequencia: Diaria.
   Objetivo  : Gerar diariamente para o sistema MITRA as informações
               referentes as aplicações e operações de credito feitas pelas
               singulares na sua conta na central CECRED.
               
   Alteracoes: 29/08/2013 - Valor do campo financeiro_contabil_bruto
                            alterado para receber o mesmo valor que 
                            tt-dados.pu quando o campo nome for "CCB_CDI - RF".
                            (Reinert)
                            
               09/09/2013 - Valor do campo financeiro_contabil_provisao
                            alterado para receber tt-dados.pu * a porcentagem
                            do nivel de risco quando o campo nome for 
                            "CCB_CDI - RF". (Reinert)
                            
               09/09/2014 - Adicionada procedure pc_busca_aplicacoes_car para
                            tratar as aplicacoes de captacao. (Reinert)
                            
               05/05/2015 - Incluida as informações de emprestimos SD266082
                            (Vanessa).
               
               07/04/2016 - Incluida clausula where filtrando por inliquid
                            diferente de 1 ao buscar os contratos para geracao
                            do arquivo. Conforme solicitado pela Jessica, nao
                            devem aparecer contratos liquidados.
                            Chamado 415453 (Heitor - RKAM)

			   17/04/2017 - Adequacao da rotina para uma nova linha de
							credito. Chamado 595673 (Andrey - MOUTS)

               09/10/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

 .......................................................................... */

CREATE WIDGET-POOL.

{includes/var_batch.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR h-b1wgen0081   AS HANDLE                         NO-UNDO.
DEF VAR aux_caminho    AS CHAR                           NO-UNDO.
DEF VAR aux_sldresga   AS INT                            NO-UNDO.
DEF VAR aux_percrisc   AS DECI                           NO-UNDO.

DEF VAR aux_cdcritic AS INT                              NO-UNDO.
DEF VAR aux_dscritic AS CHAR                             NO-UNDO.

/* Variaveis retornadas da procedure pc_busca_aplicacoes_car */
DEF VAR aux_nraplica   AS INTE                           NO-UNDO.
DEF VAR aux_idtippro   AS INTE                           NO-UNDO.
DEF VAR aux_cdprodut   AS INTE                           NO-UNDO.
DEF VAR aux_nmprodut   AS CHAR                           NO-UNDO.
DEF VAR aux_dsnomenc   AS CHAR                           NO-UNDO.
DEF VAR aux_nmdindex   AS CHAR                           NO-UNDO.
DEF VAR aux_vlaplica   AS DECI                           NO-UNDO.
DEF VAR aux_vlsldtot   AS DECI                           NO-UNDO.
DEF VAR aux_vlsldrgt   AS DECI                           NO-UNDO.
DEF VAR aux_vlrdirrf   AS DECI                           NO-UNDO.
DEF VAR aux_percirrf   AS DECI                           NO-UNDO.
DEF VAR aux_dtmvtolt   AS CHAR                           NO-UNDO.
DEF VAR aux_dtvencto   AS CHAR                           NO-UNDO.
DEF VAR aux_qtdiacar   AS INTE                           NO-UNDO.
DEF VAR aux_txaplica   AS DECI                           NO-UNDO.
DEF VAR aux_idblqrgt   AS INTE                           NO-UNDO.
DEF VAR aux_dsblqrgt   AS CHAR                           NO-UNDO.
DEF VAR aux_dsresgat   AS CHAR                           NO-UNDO.
DEF VAR aux_dtresgat   AS CHAR                           NO-UNDO.
DEF VAR aux_cdoperad   AS CHAR                           NO-UNDO.
DEF VAR aux_nmoperad   AS CHAR                           NO-UNDO.
DEF VAR aux_idtxfixa   AS INTE                           NO-UNDO.

/* Variáveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.


/* Variáveis utilizadas para os emprestimos*/
DEF VAR aux_qtdparce  AS INTE   NO-UNDO.
DEF VAR aux_contador  AS INTE   NO-UNDO.
DEF VAR aux_vlamorti  AS DECI   NO-UNDO.
DEF VAR aux_qtcarenc  AS INTE   NO-UNDO.
DEF VAR aux_nmconpar  AS CHAR   NO-UNDO.
DEF VAR aux_diavecto  AS DATE   NO-UNDO.
DEF VAR aux_dsnomeli  AS CHAR   NO-UNDO.
DEF VAR aux_dsidendi  AS CHAR   NO-UNDO.
DEF VAR aux_dstratam  AS CHAR   NO-UNDO.
DEF VAR aux_identifi  AS CHAR   NO-UNDO.
DEF VAR aux_dstiprod  AS CHAR   NO-UNDO.
DEF VAR aux_dtultpre  AS DATE   NO-UNDO.
DEF VAR aux_dtinterv  AS DATE   NO-UNDO.
DEF VAR h-b1wgen0015  AS HANDLE NO-UNDO.

DEF TEMP-TABLE tt-datas-parcelas  NO-UNDO
    FIELD nrparepr AS INTE
    FIELD dtparepr AS DATE.

DEF TEMP-TABLE tt-dados-mitra NO-UNDO
    FIELD identificacao                  AS CHAR
    FIELD nome                           AS CHAR
    FIELD carteira                       AS CHAR
    FIELD corretora                      AS CHAR
    FIELD data_entrada                   AS CHAR
    FIELD descricao                      AS CHAR
    FIELD agrupamento                    AS CHAR
    FIELD quantidade                     AS CHAR
    FIELD pu                             AS CHAR
    FIELD corretagem                     AS CHAR
    FIELD emolumento                     AS CHAR
    FIELD rebate                         AS CHAR
    FIELD cpmf                           AS CHAR
    FIELD outras_despesas                AS CHAR
    FIELD inicio                         AS CHAR
    FIELD vencimento                     AS CHAR
    FIELD valor                          AS CHAR
    FIELD taxa                           AS CHAR
    FIELD taxa_registro                  AS CHAR
    FIELD porc_index                     AS CHAR
    FIELD contraparte                    AS CHAR
    FIELD impostos                       AS CHAR
    FIELD taxa_a                         AS CHAR
    FIELD taxa_p                         AS CHAR
    FIELD porc_index_a                   AS CHAR
    FIELD porc_index_p                   AS CHAR
    FIELD tipo_marcacao                  AS CHAR
    FIELD tipo_marcacao_a                AS CHAR
    FIELD tipo_marcacao_p                AS CHAR
    FIELD tipo_marcacao_stock            AS CHAR
    FIELD cotacao_base                   AS CHAR
    FIELD data_lancamento                AS CHAR
    FIELD gerar_provisao                 AS CHAR
    FIELD id                             AS CHAR
    FIELD codigo                         AS CHAR
    FIELD lastro                         AS CHAR
    FIELD cupom_operacao                 AS CHAR
    FIELD cupom_pol                      AS CHAR
    FIELD porc_index_pol                 AS CHAR
    FIELD tipo_marcacao_pol              AS CHAR
    FIELD tipo_marcacao_tes_pol          AS CHAR
    FIELD porc_rebate                    AS CHAR
    FIELD indexador                      AS CHAR
    FIELD contrato                       AS CHAR
    FIELD parcela                        AS CHAR
    FIELD correcao                       AS CHAR
    FIELD juros                          AS CHAR
    FIELD tarifas                        AS CHAR
    FIELD mora                           AS CHAR
    FIELD resgate_total                  AS CHAR
    FIELD limite_conta                   AS CHAR
    FIELD n_agencia                      AS CHAR
    FIELD n_conta_corrente               AS CHAR
    FIELD taxa_adp                       AS CHAR
    FIELD iof                            AS CHAR
    FIELD data_saldo                     AS CHAR
    FIELD data_encerramento              AS CHAR
    FIELD data_abertura                  AS CHAR
    FIELD cupom_pol_a                    AS CHAR
    FIELD cupom_pol_p                    AS CHAR
    FIELD porc_index_pol_a               AS CHAR
    FIELD porc_index_pol_p               AS CHAR
    FIELD pu_politica                    AS CHAR
    FIELD financeiro_liquido             AS CHAR
    FIELD cambio_base                    AS CHAR
    FIELD cambio_base_a                  AS CHAR
    FIELD cambio_base_p                  AS CHAR
    FIELD tipo_calculo_bacen             AS CHAR
    FIELD data_boletagem                 AS CHAR
    FIELD garantia_imobiliaria           AS CHAR
    FIELD valor_mitigador                AS CHAR
    FIELD data_aplicacao_inicial         AS CHAR
    FIELD status_quantidade              AS CHAR
    FIELD status_recurso                 AS CHAR
    FIELD pu_referencia                  AS CHAR
    FIELD volatilidade                   AS CHAR
    FIELD tipo_modalidade_operacao       AS CHAR
    FIELD tipo_calculo_modalidade        AS CHAR
    FIELD tipo_marcacao_modalidade       AS CHAR
    FIELD fator_mitigador                AS CHAR
    FIELD gerar_lancamento_automatico    AS CHAR
    FIELD cenario                        AS CHAR
    FIELD estrategia_1                   AS CHAR
    FIELD estrategia_2                   AS CHAR
    FIELD estrategia_3                   AS CHAR
    FIELD eh_clearing                    AS CHAR
    FIELD pu_a                           AS CHAR
    FIELD pu_p                           AS CHAR
    FIELD juros_a                        AS CHAR
    FIELD juros_p                        AS CHAR
    FIELD correcao_a                     AS CHAR
    FIELD correcao_p                     AS CHAR
    FIELD moeda2                         AS CHAR
    FIELD tratamento_moeda               AS CHAR
    FIELD tratamento_moeda2              AS CHAR
    FIELD tipo_marcacao_moeda2           AS CHAR
    FIELD vencimento_moeda2              AS CHAR
    FIELD tipo_posicao_operacao          AS CHAR
    FIELD status_operacao                AS CHAR
    FIELD metodo_desconto_mtm            AS CHAR
    FIELD modalidade_liquidacao          AS CHAR
    FIELD amortizacao                    AS CHAR
    FIELD saldo_devedor                  AS CHAR
    FIELD inicio_juros                   AS CHAR
    FIELD inicio_correcao                AS CHAR
    FIELD paga_amortizacao               AS CHAR
    FIELD paga_juros                     AS CHAR
    FIELD paga_correcao                  AS CHAR
    FIELD forma_aplicacao_juros          AS CHAR
    FIELD forma_aplicacao_correcao       AS CHAR
    FIELD tratamento                     AS CHAR
    FIELD pu_financeiro                  AS CHAR
    FIELD informa1                       AS CHAR
    FIELD informa2                       AS CHAR
    FIELD informa3                       AS CHAR
    FIELD informa4                       AS CHAR
    FIELD informa5                       AS CHAR
    FIELD financeiro_contabil_bruto      AS CHAR
    FIELD financeiro_contabil_provisao   AS CHAR
    FIELD taxa_base                      AS CHAR
    FIELD cambio_conversao_inicio        AS CHAR
    FIELD inicio_juros_a                 AS CHAR
    FIELD inicio_juros_p                 AS CHAR
    FIELD inicio_correcao_a              AS CHAR
    FIELD inicio_correcao_p              AS CHAR
    FIELD tratamento_a                   AS CHAR
    FIELD tratamento_p                   AS CHAR
    FIELD forma_aplicacao_juros_a        AS CHAR
    FIELD forma_aplicacao_juros_p        AS CHAR
    FIELD paga_juros_a                   AS CHAR
    FIELD paga_juros_p                   AS CHAR
    FIELD forma_aplicacao_correcao_a     AS CHAR
    FIELD forma_aplicacao_correcao_p     AS CHAR
    FIELD paga_correcao_a                AS CHAR
    FIELD paga_correcao_p                AS CHAR
    FIELD taxa_base_a                    AS CHAR
    FIELD taxa_base_p                    AS CHAR
    FIELD taxa_oper_a                    AS CHAR
    FIELD taxa_oper_p                    AS CHAR
    FIELD cambio_conversao_inicio_a      AS CHAR
    FIELD cambio_conversao_inicio_p      AS CHAR
    FIELD descricao_contrato             AS CHAR
    FIELD nome_visual_contrato           AS CHAR
    FIELD codigo_isin                    AS CHAR
    FIELD codigo_selic                   AS CHAR
    FIELD moeda_liquidacao               AS CHAR
    FIELD defasagem_moeda_liquidacao     AS CHAR
    FIELD tipo_dias_defas_liquidacao     AS CHAR
    FIELD tipo_evento                    AS CHAR
    FIELD moeda_conversao                AS CHAR
    FIELD defasagem_moed_conversao       AS CHAR
    FIELD tipo_dias_defa_conversao       AS CHAR
    FIELD moeda_conversao_a              AS CHAR
    FIELD defasagem_moeda_conversao_a    AS CHAR
    FIELD tipo_dias_defa_conversao_a     AS CHAR
    FIELD moeda_conversao_p              AS CHAR
    FIELD defasagem_moeda_conversao_p    AS CHAR
    FIELD tipo_dias_defa_conversao_p     AS CHAR
    FIELD data_incorporacao              AS CHAR
    FIELD incorpora_juros                AS CHAR
    FIELD incorpora_correcao             AS CHAR
    FIELD id_controle                    AS CHAR
    FIELD id_sistema                     AS CHAR
    FIELD data_referencia                AS CHAR
    FIELD id_connected                   AS CHAR
    FIELD id_cliente                     AS CHAR
    FIELD id_execucao                    AS CHAR.

ASSIGN glb_cdprogra = "crps650".
       
RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
   DO:
       UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + "' --> '" +
                          glb_dscritic + " >> log/proc_batch.log").
       RETURN.
END.

FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

IF AVAIL crapcop THEN
   ASSIGN aux_caminho = "/micros/" + crapcop.dsdircop + "/Risco_de_Mercado_Mitra/".

OUTPUT STREAM str_1 TO VALUE(aux_caminho + 
      STRING(DAY(glb_dtmvtolt), "99") + "_" + STRING(MONTH(glb_dtmvtolt), "99")
       + "_" + STRING(YEAR(glb_dtmvtolt), "9999") + "_MITRA.csv").

RUN carrega_dados.

PROCEDURE gera_arquivo:

    PUT STREAM str_1 UNFORMATTED "IDENTIFICACAO;NOME;CARTEIRA;"
                           + "CORRETORA;DATA_ENTRADA;DESCRICAO;"
                           + "AGRUPAMENTO;QUANTIDADE;PU;"
                           + "CORRETAGEM;EMOLUMENTO;REBATE;"
                           + "CPMF;OUTRAS_DESPESAS;INICIO;"
                           + "VENCIMENTO;VALOR;TAXA;TAXA_REGISTRO;"
                           + "PORC_INDEX;CONTRAPARTE;IMPOSTOS;"
                           + "TAXA_A;TAXA_P;PORC_INDEX_A;"
                           + "PORC_INDEX_P;TIPO_MARCACAO;"
                           + "TIPO_MARCACAO_A;TIPO_MARCACAO_P;"
                           + "TIPO_MARCACAO_STOCK;COTACAO_BASE;"
                           + "DATA_LANCAMENTO;GERAR_PROVISAO;"
                           + "ID;CODIGO;LASTRO;CUPOM_OPERACAO;"
                           + "CUPOM_POL;PORC_INDEX_POL;"
                           + "TIPO_MARCACAO_POL;TIPO_MARCACAO_TES_POL;"
                           + "PORC_REBATE;INDEXADOR;CONTRATO;PARCELA;"
                           + "CORRECAO;JUROS;TARIFAS;MORA;RESGATE_TOTAL;"
                           + "LIMITE_CONTA;N_AGENCIA;N_CONTA_CORRENTE;"
                           + "TAXA_ADP;IOF;DATA_SALDO;DATA_ENCERRAMENTO;"
                           + "DATA_ABERTURA;CUPOM_POL_A;CUPOM_POL_P;"
                           + "PORC_INDEX_POL_A;PORC_INDEX_POL_P;PU_POLITICA;"
                           + "FINANCEIRO_LIQUIDO;CAMBIO_BASE;CAMBIO_BASE_A;"
                           + "CAMBIO_BASE_P;TIPO_CALCULO_BACEN;"
                           + "DATA_BOLETAGEM;GARANTIA_IMOBILIARIA;"
                           + "VALOR_MITIGADOR;DATA_APLICACAO_INICIAL;"
                           + "STATUS_QUANTIDADE;STATUS_RECURSO;"
                           + "PU_REFERENCIA;VOLATILIDADE;"
                           + "TIPO_MODALIDADE_OPERACAO;"
                           + "TIPO_CALCULO_MODALIDADE;"
                           + "TIPO_MARCACAO_MODALIDADE;FATOR_MITIGADOR;"
                           + "GERAR_LANCAMENTO_AUTOMATICO;CENARIO;"
                           + "ESTRATEGIA_1;ESTRATEGIA_2;ESTRATEGIA_3;"
                           + "EH_CLEARING;PU_A;PU_P;JUROS_A;JUROS_P;"
                           + "CORRECAO_A;CORRECAO_P;MOEDA2;TRATAMENTO_MOEDA;"
                           + "TRATAMENTO_MOEDA2;TIPO_MARCACAO_MOEDA2;"
                           + "VENCIMENTO_MOEDA2;TIPO_POSICAO_OPERACAO;"
                           + "STATUS_OPERACAO;METODO_DESCONTO_MTM;"
                           + "MODALIDADE_LIQUIDACAO;AMORTIZACAO;"
                           + "SALDO_DEVEDOR;INICIO_JUROS;INICIO_CORRECAO;"
                           + "PAGA_AMORTIZACAO;PAGA_JUROS;PAGA_CORRECAO;"
                           + "FORMA_APLICACAO_JUROS;FORMA_APLICACAO_CORRECAO;"
                           + "TRATAMENTO;PU_FINANCEIRO;INFORMA1;INFORMA2;"
                           + "INFORMA3;INFORMA4;INFORMA5;"
                           + "FINANCEIRO_CONTABIL_BRUTO;"
                           + "FINANCEIRO_CONTABIL_PROVISAO;"
                           + "TAXA_BASE;CAMBIO_CONVERSAO_INICIO;"
                           + "INICIO_JUROS_A;INICIO_JUROS_P;"
                           + "INICIO_CORRECAO_A;INICIO_CORRECAO_P;"
                           + "TRATAMENTO_A;TRATAMENTO_P;"
                           + "FORMA_APLICACAO_JUROS_A;"
                           + "FORMA_APLICACAO_JUROS_P;"
                           + "PAGA_JUROS_A;PAGA_JUROS_P;"
                           + "FORMA_APLICACAO_CORRECAO_A;"
                           + "FORMA_APLICACAO_CORRECAO_P;"
                           + "PAGA_CORRECAO_A;PAGA_CORRECAO_P;TAXA_BASE_A;"
                           + "TAXA_BASE_P;TAXA_OPER_A;TAXA_OPER_P;"
                           + "CAMBIO_CONVERSAO_INICIO_A;"
                           + "CAMBIO_CONVERSAO_INICIO_P;"
                           + "DESCRICAO_CONTRATO;NOME_VISUAL_CONTRATO;"
                           + "CODIGO_ISIN;CODIGO_SELIC;MOEDA_LIQUIDACAO;"
                           + "DEFASAGEM_MOEDA_LIQUIDACAO;"
                           + "TIPO_DIAS_DEFAS_LIQUIDACAO;"
                           + "TIPO_EVENTO;MOEDA_CONVERSAO;"
                           + "DEFASAGEM_MOED_CONVERSAO;"
                           + "TIPO_DIAS_DEFA_CONVERSAO;"
                           + "MOEDA_CONVERSAO_A;DEFASAGEM_MOEDA_CONVERSAO_A;"
                           + "TIPO_DIAS_DEFA_CONVERSAO_A;MOEDA_CONVERSAO_P;"
                           + "DEFASAGEM_MOEDA_CONVERSAO_P;"
                           + "TIPO_DIAS_DEFA_CONVERSAO_P;"
                           + "DATA_INCORPORACAO;INCORPORA_JUROS;"
                           + "INCORPORA_CORRECAO;ID_CONTROLE;ID_SISTEMA;"
                           + "DATA_REFERENCIA;ID_CONNECTED;ID_CLIENTE;"
                           + "ID_EXECUCAO;" SKIP.


    FOR EACH tt-dados-mitra NO-LOCK:
        PUT STREAM str_1 UNFORMATTED tt-dados-mitra.identificacao          + ";"
                             + tt-dados-mitra.nome                         + ";"
                             + tt-dados-mitra.carteira                     + ";"
                             + tt-dados-mitra.corretora                    + ";"
                             + tt-dados-mitra.data_entrada                 + ";"
                             + tt-dados-mitra.descricao                    + ";"
                             + tt-dados-mitra.agrupamento                  + ";"
                             + tt-dados-mitra.quantidade                   + ";"
                             + tt-dados-mitra.pu                           + ";"
                             + tt-dados-mitra.corretagem                   + ";"
                             + tt-dados-mitra.emolumento                   + ";"
                             + tt-dados-mitra.rebate                       + ";"
                             + tt-dados-mitra.cpmf                         + ";"
                             + tt-dados-mitra.outras_despesas              + ";"
                             + tt-dados-mitra.inicio                       + ";"
                             + tt-dados-mitra.vencimento                   + ";"
                             + tt-dados-mitra.valor                        + ";"
                             + tt-dados-mitra.taxa                         + ";"
                             + tt-dados-mitra.taxa_registro                + ";"
                             + tt-dados-mitra.porc_index                   + ";"
                             + tt-dados-mitra.contraparte                  + ";"
                             + tt-dados-mitra.impostos                     + ";"
                             + tt-dados-mitra.taxa_a                       + ";"
                             + tt-dados-mitra.taxa_p                       + ";"
                             + tt-dados-mitra.porc_index_a                 + ";"
                             + tt-dados-mitra.porc_index_p                 + ";"
                             + tt-dados-mitra.tipo_marcacao                + ";"
                             + tt-dados-mitra.tipo_marcacao_a              + ";"
                             + tt-dados-mitra.tipo_marcacao_p              + ";"
                             + tt-dados-mitra.tipo_marcacao_stock          + ";"
                             + tt-dados-mitra.cotacao_base                 + ";"
                             + tt-dados-mitra.data_lancamento              + ";"
                             + tt-dados-mitra.gerar_provisao               + ";"
                             + tt-dados-mitra.id                           + ";"
                             + tt-dados-mitra.codigo                       + ";"
                             + tt-dados-mitra.lastro                       + ";"
                             + tt-dados-mitra.cupom_operacao               + ";"
                             + tt-dados-mitra.cupom_pol                    + ";"
                             + tt-dados-mitra.porc_index_pol               + ";"
                             + tt-dados-mitra.tipo_marcacao_pol            + ";"
                             + tt-dados-mitra.tipo_marcacao_tes_pol        + ";"
                             + tt-dados-mitra.porc_rebate                  + ";"
                             + tt-dados-mitra.indexador                    + ";"
                             + tt-dados-mitra.contrato                     + ";"
                             + tt-dados-mitra.parcela                      + ";"
                             + tt-dados-mitra.correcao                     + ";"
                             + tt-dados-mitra.juros                        + ";"
                             + tt-dados-mitra.tarifas                      + ";"
                             + tt-dados-mitra.mora                         + ";"
                             + tt-dados-mitra.resgate_total                + ";"
                             + tt-dados-mitra.limite_conta                 + ";"
                             + tt-dados-mitra.n_agencia                    + ";"
                             + tt-dados-mitra.n_conta_corrente             + ";"
                             + tt-dados-mitra.taxa_adp                     + ";"
                             + tt-dados-mitra.iof                          + ";"
                             + tt-dados-mitra.data_saldo                   + ";"
                             + tt-dados-mitra.data_encerramento            + ";"
                             + tt-dados-mitra.data_abertura                + ";"
                             + tt-dados-mitra.cupom_pol_a                  + ";"
                             + tt-dados-mitra.cupom_pol_p                  + ";"
                             + tt-dados-mitra.porc_index_pol_a             + ";"
                             + tt-dados-mitra.porc_index_pol_p             + ";"
                             + tt-dados-mitra.pu_politica                  + ";"
                             + tt-dados-mitra.financeiro_liquido           + ";"
                             + tt-dados-mitra.cambio_base                  + ";"
                             + tt-dados-mitra.cambio_base_a                + ";"
                             + tt-dados-mitra.cambio_base_p                + ";"
                             + tt-dados-mitra.tipo_calculo_bacen           + ";"
                             + tt-dados-mitra.data_boletagem               + ";"
                             + tt-dados-mitra.garantia_imobiliaria         + ";"
                             + tt-dados-mitra.valor_mitigador              + ";"
                             + tt-dados-mitra.data_aplicacao_inicial       + ";"
                             + tt-dados-mitra.status_quantidade            + ";"
                             + tt-dados-mitra.status_recurso               + ";"
                             + tt-dados-mitra.pu_referencia                + ";"
                             + tt-dados-mitra.volatilidade                 + ";"
                             + tt-dados-mitra.tipo_modalidade_operacao     + ";"
                             + tt-dados-mitra.tipo_calculo_modalidade      + ";"
                             + tt-dados-mitra.tipo_marcacao_modalidade     + ";"
                             + tt-dados-mitra.fator_mitigador              + ";"
                             + tt-dados-mitra.gerar_lancamento_automatico  + ";"
                             + tt-dados-mitra.cenario                      + ";"
                             + tt-dados-mitra.estrategia_1                 + ";"
                             + tt-dados-mitra.estrategia_2                 + ";"
                             + tt-dados-mitra.estrategia_3                 + ";"
                             + tt-dados-mitra.eh_clearing                  + ";"
                             + tt-dados-mitra.pu_a                         + ";"
                             + tt-dados-mitra.pu_p                         + ";"
                             + tt-dados-mitra.juros_a                      + ";"
                             + tt-dados-mitra.juros_p                      + ";"
                             + tt-dados-mitra.correcao_a                   + ";"
                             + tt-dados-mitra.correcao_p                   + ";"
                             + tt-dados-mitra.moeda2                       + ";"
                             + tt-dados-mitra.tratamento_moeda             + ";"
                             + tt-dados-mitra.tratamento_moeda2            + ";"
                             + tt-dados-mitra.tipo_marcacao_moeda2         + ";"
                             + tt-dados-mitra.vencimento_moeda2            + ";"
                             + tt-dados-mitra.tipo_posicao_operacao        + ";"
                             + tt-dados-mitra.status_operacao              + ";"
                             + tt-dados-mitra.metodo_desconto_mtm          + ";"
                             + tt-dados-mitra.modalidade_liquidacao        + ";"
                             + tt-dados-mitra.amortizacao                  + ";"
                             + tt-dados-mitra.saldo_devedor                + ";"
                             + tt-dados-mitra.inicio_juros                 + ";"
                             + tt-dados-mitra.inicio_correcao              + ";"
                             + tt-dados-mitra.paga_amortizacao             + ";"
                             + tt-dados-mitra.paga_juros                   + ";"
                             + tt-dados-mitra.paga_correcao                + ";"
                             + tt-dados-mitra.forma_aplicacao_juros        + ";"
                             + tt-dados-mitra.forma_aplicacao_correcao     + ";"
                             + tt-dados-mitra.tratamento                   + ";"
                             + tt-dados-mitra.pu_financeiro                + ";"
                             + tt-dados-mitra.informa1                     + ";"
                             + tt-dados-mitra.informa2                     + ";"
                             + tt-dados-mitra.informa3                     + ";"
                             + tt-dados-mitra.informa4                     + ";"
                             + tt-dados-mitra.informa5                     + ";"
                             + tt-dados-mitra.financeiro_contabil_bruto    + ";"
                             + tt-dados-mitra.financeiro_contabil_provisao + ";"
                             + tt-dados-mitra.taxa_base                    + ";"
                             + tt-dados-mitra.cambio_conversao_inicio      + ";"
                             + tt-dados-mitra.inicio_juros_a               + ";"
                             + tt-dados-mitra.inicio_juros_p               + ";"
                             + tt-dados-mitra.inicio_correcao_a            + ";"
                             + tt-dados-mitra.inicio_correcao_p            + ";"
                             + tt-dados-mitra.tratamento_a                 + ";"
                             + tt-dados-mitra.tratamento_p                 + ";"
                             + tt-dados-mitra.forma_aplicacao_juros_a      + ";"
                             + tt-dados-mitra.forma_aplicacao_juros_p      + ";"
                             + tt-dados-mitra.paga_juros_a                 + ";"
                             + tt-dados-mitra.paga_juros_p                 + ";"
                             + tt-dados-mitra.forma_aplicacao_correcao_a   + ";"
                             + tt-dados-mitra.forma_aplicacao_correcao_p   + ";"
                             + tt-dados-mitra.paga_correcao_a              + ";"
                             + tt-dados-mitra.paga_correcao_p              + ";"
                             + tt-dados-mitra.taxa_base_a                  + ";"
                             + tt-dados-mitra.taxa_base_p                  + ";"
                             + tt-dados-mitra.taxa_oper_a                  + ";"
                             + tt-dados-mitra.taxa_oper_p                  + ";"
                             + tt-dados-mitra.cambio_conversao_inicio_a    + ";"
                             + tt-dados-mitra.cambio_conversao_inicio_p    + ";"
                             + tt-dados-mitra.descricao_contrato           + ";"
                             + tt-dados-mitra.nome_visual_contrato         + ";"
                             + tt-dados-mitra.codigo_isin                  + ";"
                             + tt-dados-mitra.codigo_selic                 + ";"
                             + tt-dados-mitra.moeda_liquidacao             + ";"
                             + tt-dados-mitra.defasagem_moeda_liquidacao   + ";"
                             + tt-dados-mitra.tipo_dias_defas_liquidacao   + ";"
                             + tt-dados-mitra.tipo_evento                  + ";"
                             + tt-dados-mitra.moeda_conversao              + ";"
                             + tt-dados-mitra.defasagem_moed_conversao     + ";"
                             + tt-dados-mitra.tipo_dias_defa_conversao     + ";"
                             + tt-dados-mitra.moeda_conversao_a            + ";"
                             + tt-dados-mitra.defasagem_moeda_conversao_a  + ";"
                             + tt-dados-mitra.tipo_dias_defa_conversao_a   + ";"
                             + tt-dados-mitra.moeda_conversao_p            + ";"
                             + tt-dados-mitra.defasagem_moeda_conversao_p  + ";"
                             + tt-dados-mitra.tipo_dias_defa_conversao_p   + ";"
                             + tt-dados-mitra.data_incorporacao            + ";"
                             + tt-dados-mitra.incorpora_juros              + ";"
                             + tt-dados-mitra.incorpora_correcao           + ";"
                             + tt-dados-mitra.id_controle                  + ";"
                             + tt-dados-mitra.id_sistema                   + ";"
                             + tt-dados-mitra.data_referencia              + ";"
                             + tt-dados-mitra.id_connected                 + ";"
                             + tt-dados-mitra.id_cliente                   + ";"
                             + tt-dados-mitra.id_execucao                  + ";"
                             SKIP.
    END.
END. /* gera_arquivo */

PROCEDURE calcula_data_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparcel AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-datas-parcelas.

    DEF VAR aux_dtcalcul AS DATE                                    NO-UNDO.
    DEF VAR aux_nrparcel AS INTE                                    NO-UNDO.
    DEF VAR aux_dia      AS INTE                                    NO-UNDO.
    DEF VAR aux_mes      AS INTE                                    NO-UNDO.
    DEF VAR aux_ano      AS INTE                                    NO-UNDO.

    ASSIGN  aux_dtcalcul = par_dtvencto
            aux_dia      = DAY(aux_dtcalcul)
            aux_mes      = MONTH(aux_dtcalcul)
            aux_ano      = YEAR(aux_dtcalcul).

    DO  aux_nrparcel = 1 TO par_nrparcel:
        IF  aux_dia >= 29 THEN
            DO: /*  Se nao existir o dia no mes, joga o vencimento para
                    o ultimo deste mesmo mes. */
                aux_dtcalcul = DATE(aux_mes,aux_dia,aux_ano) NO-ERROR.
                IF  ERROR-STATUS:ERROR THEN
                    DO:
                      /* Calcular o ultimo dia do mês */
                      ASSIGN aux_dtcalcul = DATE((DATE(aux_mes, 28, aux_ano) + 4) -
                                                 DAY(DATE(aux_mes,28, aux_ano) + 4)).
                    END.
            END.
        ELSE
            DO:
                aux_dtcalcul = DATE(aux_mes, aux_dia, aux_ano).
            END.

        CREATE tt-datas-parcelas.
        ASSIGN tt-datas-parcelas.nrparepr = aux_nrparcel
               tt-datas-parcelas.dtparepr = aux_dtcalcul.

        IF  aux_mes = 12 THEN
            DO:
                aux_mes = 1.
                aux_ano = aux_ano + 1.
            END.
        ELSE
            aux_mes = aux_mes + 1.
    END.

END PROCEDURE. /* calcula data parcela */


PROCEDURE carrega_dados:

    DEF VAR aux_vlrtotal AS INT                 NO-UNDO.

    DEF QUERY q_crappep FOR crappep FIELDS(nrparepr).

    FOR EACH crapjur WHERE crapjur.cdcooper = glb_cdcooper AND
                           crapjur.nrdconta <> 820024      AND /* nao ler as contas da CECRED */
                           crapjur.nrdconta <> 850004        /* nao ler as contas da CECRED */
                           NO-LOCK:
        FIND LAST craplim WHERE craplim.cdcooper = crapjur.cdcooper AND
                                craplim.nrdconta = crapjur.nrdconta AND
                                craplim.tpctrlim = 1                AND /* Limite de credito */
                                craplim.insitlim = 2                    /* Somente ativos */
                                NO-LOCK NO-ERROR.
        FIND LAST crapsda WHERE crapsda.cdcooper = crapjur.cdcooper AND
                                crapsda.nrdconta = crapjur.nrdconta AND
                                crapsda.dtmvtolt = glb_dtmvtolt
                                NO-LOCK NO-ERROR.
        
        IF AVAIL craplim THEN
            DO:
                CREATE tt-dados-mitra.
                ASSIGN tt-dados-mitra.identificacao = "CCB_"
                                                    + STRING(craplim.nrdconta) 
                                                    + "_"
                                                    + STRING(craplim.nrctrlim)
                       tt-dados-mitra.nome = "LIMITE_DISPONIVEL"
                       tt-dados-mitra.carteira = "CECRED_PROPRIA"
                       tt-dados-mitra.inicio = STRING(craplim.dtinivig,
                                                       "99/99/9999")
                       tt-dados-mitra.vencimento = STRING((craplim.dtinivig +
                                                          craplim.qtdiavig),
                                                          "99/99/9999")
                       tt-dados-mitra.contraparte = crapjur.nmfansia
                       tt-dados-mitra.codigo = "CCBLMT_" + STRING(crapjur.nrdconta)
                       tt-dados-mitra.limite_conta = STRING(craplim.vllimite)
                       tt-dados-mitra.n_agencia = "85"
                       tt-dados-mitra.n_conta_corrente = STRING(crapjur.nrdconta)
                       tt-dados-mitra.data_saldo = STRING(glb_dtmvtolt, 
                                                          "99/99/9999")
                       tt-dados-mitra.data_abertura = tt-dados-mitra.inicio
                       tt-dados-mitra.status_recurso = "Terceiros"
                       tt-dados-mitra.financeiro_contabil_bruto = "0".
                
                IF AVAIL crapsda THEN
                    DO:
                        ASSIGN tt-dados-mitra.valor = STRING(crapsda.vllimutl 
                                                             * (-1)).
                    
                        IF crapsda.vllimutl > 0 THEN
                           DO:
                              FIND craplrt WHERE craplrt.cdcooper = glb_cdcooper 
                                             AND craplrt.cddlinha = craplim.cddlinha
                                                 NO-LOCK NO-ERROR.
                              FIND crapass WHERE crapass.cdcooper = crapjur.cdcooper
                                             AND crapass.nrdconta = crapjur.nrdconta
                                  NO-LOCK NO-ERROR.
                              CREATE tt-dados-mitra.
                              ASSIGN tt-dados-mitra.identificacao = "CCBCDI_"
                                                      + STRING(craplim.nrdconta) 
                                                      + "_"
                                                      + STRING(craplim.nrctrlim)
                                     tt-dados-mitra.nome = "CCB_CDI - RF"
                                     tt-dados-mitra.carteira = "CECRED_PROPRIA"
                                     tt-dados-mitra.data_entrada = STRING(glb_dtmvtolt,
                                                                          "99/99/9999")
                                     tt-dados-mitra.quantidade = "1"
                                     tt-dados-mitra.pu = STRING(crapsda.vllimutl)
                                     tt-dados-mitra.inicio = STRING(glb_dtmvtolt,
                                                                    "99/99/9999")
                                     tt-dados-mitra.vencimento = STRING((craplim.dtinivig +
                                                                        craplim.qtdiavig), 
                                                                        "99/99/9999")
                                     tt-dados-mitra.valor = tt-dados-mitra.pu
                                     tt-dados-mitra.porc_index = STRING(craplrt.txjurvar)
                                     tt-dados-mitra.contraparte = crapjur.nmfansia
                                     tt-dados-mitra.tipo_marcacao = "C"
                                     tt-dados-mitra.codigo = "CCBUTI_" + STRING(crapjur.nrdconta)
                                     tt-dados-mitra.contrato = tt-dados-mitra.codigo
                                     tt-dados-mitra.status_quantidade = "Disponivel"
                                     tt-dados-mitra.estrategia_1 = "CCB"
                                     tt-dados-mitra.estrategia_2 = tt-dados-mitra.status_quantidade
                                     tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                                     tt-dados-mitra.amortizacao  = "1"
                                     tt-dados-mitra.financeiro_contabil_bruto = tt-dados-mitra.pu.
                              IF AVAIL crapass THEN
                                 DO:
                                     RUN geraPercRisco(INPUT crapass.dsnivris,
                                                      OUTPUT aux_percrisc).
                                     ASSIGN tt-dados-mitra.financeiro_contabil_provisao = STRING(DECIMAL(tt-dados-mitra.pu) *
                                                                                          aux_percrisc, 
                                                                                          "-zzzzzzzzzzz9.99").
                                 END.
                           END.
                    END.
            END.

        IF AVAIL crapsda THEN
            DO:
                IF (crapsda.vlsddisp > 0) THEN
                    DO:
                        CREATE tt-dados-mitra.
                        ASSIGN tt-dados-mitra.identificacao = "DPV_" +
                                                      STRING(crapjur.nrdconta)
                                                      + "_1"
                               tt-dados-mitra.nome = "DEPOSITO_A_ VISTA"
                               tt-dados-mitra.carteira = "CECRED_PROPRIA"
                               tt-dados-mitra.valor = STRING(crapsda.vlsddisp)
                               tt-dados-mitra.contraparte = crapjur.nmfansia
                               tt-dados-mitra.codigo = tt-dados-mitra.identificacao
                               tt-dados-mitra.limite_conta = "0"
                               tt-dados-mitra.n_agencia = "85"
                               tt-dados-mitra.n_conta_corrente = STRING(crapjur.nrdconta)
                               tt-dados-mitra.data_saldo = STRING(glb_dtmvtolt,
                                                                 "99/99/9999")
                               tt-dados-mitra.data_abertura = STRING(glb_dtmvtoan,
                                                                 "99/99/9999")
                               tt-dados-mitra.status_recurso = "Proprio"
                               tt-dados-mitra.financeiro_contabil_bruto = "0".
                    END.
                
                IF (crapsda.vlsddisp < 0)                      AND
                   (((crapsda.vllimcre > 0)                    AND 
                   (crapsda.vllimutl >= crapsda.vllimcre)      AND
                   (ABS(crapsda.vlsddisp) > crapsda.vllimcre)) OR
                   (crapsda.vllimcre = 0))                     THEN
                    DO:
                        CREATE tt-dados-mitra.
                        ASSIGN tt-dados-mitra.identificacao = "ADP_"  
                                                       + STRING(crapjur.nrdconta)
                                                       + "_1"            
                               tt-dados-mitra.nome = "ADIANT DEP_PRE - RF"
                               tt-dados-mitra.carteira = "CECRED_PROPRIA"
                               tt-dados-mitra.data_entrada = STRING(glb_dtmvtolt,
                                                                    "99/99/9999")
                               tt-dados-mitra.quantidade = "1"
                               tt-dados-mitra.pu = STRING(ABS(crapsda.vlsddisp + 
                                                              crapsda.vllimcre))
                               tt-dados-mitra.inicio = STRING(glb_dtmvtolt,
                                                               "99/99/9999")
                               tt-dados-mitra.vencimento = STRING(glb_dtmvtopr, 
                                                                  "99/99/9999")
                               tt-dados-mitra.valor = tt-dados-mitra.pu
                               tt-dados-mitra.contraparte = crapjur.nmfansia
                               tt-dados-mitra.tipo_marcacao = "C"
                               tt-dados-mitra.codigo = tt-dados-mitra.identificacao
                               tt-dados-mitra.contrato = tt-dados-mitra.codigo
                               tt-dados-mitra.status_quantidade = "Disponivel"
                               tt-dados-mitra.estrategia_1 = "ADP"
                               tt-dados-mitra.estrategia_2 = tt-dados-mitra.status_quantidade
                               tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                               tt-dados-mitra.amortizacao = "1"
                               tt-dados-mitra.financeiro_contabil_bruto = "0".
        
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                           craptab.nmsistem = "CRED"       AND
                                           craptab.tptabela = "USUARI"     AND
                                           craptab.cdempres = 11           AND
                                           craptab.cdacesso = "JUROSNEGAT" AND
                                           craptab.tpregist = 001
                                           NO-LOCK NO-ERROR.
                        IF AVAIL craptab THEN
                            ASSIGN tt-dados-mitra.taxa = TRIM(STRING(DECIMAL
                              (SUBSTRING(craptab.dstextab,1,10)), "zz9.999999")).
                    END.
            END.


        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

        RUN obtem-dados-aplicacoes IN h-b1wgen0081 (INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT glb_cdoperad,
                                                    INPUT "MITRA",
                                                    INPUT 1,
                                                    INPUT crapjur.nrdconta,
                                                    INPUT 1,
                                                    INPUT 0,
                                                    INPUT "MITRA",
                                                    INPUT FALSE,
                                                    INPUT ?,
                                                    INPUT ?,
                                                    OUTPUT aux_sldresga,
                                                    OUTPUT TABLE tt-saldo-rdca,
                                                    OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0081.

        FOR EACH tt-saldo-rdca NO-LOCK:           
            CREATE tt-dados-mitra.
            ASSIGN tt-dados-mitra.identificacao = "RDC_"
                                                 + STRING(crapjur.nrdconta) + "_"
                                                 + STRING(tt-saldo-rdca.nraplica)
                   tt-dados-mitra.nome = "RDC_CDI - RF"
                   tt-dados-mitra.carteira = "CECRED_PROPRIA"
                   tt-dados-mitra.data_entrada = STRING(glb_dtmvtolt, 
                                                        "99/99/9999")
                   tt-dados-mitra.quantidade = "1"
                   tt-dados-mitra.pu = STRING(tt-saldo-rdca.sldresga)
                   tt-dados-mitra.inicio = STRING(glb_dtmvtolt, "99/99/9999")
                   tt-dados-mitra.vencimento = STRING(tt-saldo-rdca.dtvencto, 
                                                      "99/99/9999")
                   tt-dados-mitra.valor = tt-dados-mitra.pu
                   tt-dados-mitra.porc_index = STRING(tt-saldo-rdca.txaplmax)
                   tt-dados-mitra.contraparte = crapjur.nmfansia
                   tt-dados-mitra.tipo_marcacao = "C"
                   tt-dados-mitra.codigo = "RDC_" + STRING(crapjur.nrdconta) +
                                            STRING(tt-saldo-rdca.nraplica)
                   tt-dados-mitra.contrato = tt-dados-mitra.codigo
                   tt-dados-mitra.status_quantidade = IF (tt-saldo-rdca.dssitapl
                                                          = "BLOQUEADA") THEN
                                                          "Vinculado"
                                                      ELSE "Disponivel"
                   tt-dados-mitra.estrategia_1 = "RDC"
                   tt-dados-mitra.estrategia_2 = tt-dados-mitra.status_quantidade
                   tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                   tt-dados-mitra.amortizacao = "1"
                   tt-dados-mitra.financeiro_contabil_bruto = "0".
        END.

        /********NOVA CONSULTA APLICACOOES*********/
        /** Saldo das aplicacoes **/
        
        /* Inicializando objetos para leitura do XML */ 
        CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
        CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
        CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
        CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
        CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        
        /* Efetuar a chamada a rotina Oracle */
        RUN STORED-PROCEDURE pc_busca_aplicacoes_car
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper     /* Código da Cooperativa*/
                                            ,INPUT "1"              /* Código do Operador*/
                                            ,INPUT glb_cdprogra     /* Nome da Tela*/
                                            ,INPUT 1                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA*/
                                            ,INPUT crapjur.nrdconta /* Número da Conta*/
                                            ,INPUT 1                /* Titular da Conta*/
                                            ,INPUT 0                /* Número da Aplicação - Parâmetro Opcional*/
                                            ,INPUT 0                /* Código do Produto – Parâmetro Opcional */
                                            ,INPUT glb_dtmvtolt     /* Data de Movimento*/
                                            ,INPUT 0                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                            ,INPUT 0                /* Identificador de Log (0 – Não / 1 – Sim) */
                                            ,OUTPUT ?               /* XML com informações de LOG*/
                                            ,OUTPUT 0               /* Código da crítica */
                                            ,OUTPUT "").            /* Descrição da crítica */

        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_busca_aplicacoes_car
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

        /* Busca possíveis erros */ 
        ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_cdcritic = pc_busca_aplicacoes_car.pr_cdcritic 
                             WHEN pc_busca_aplicacoes_car.pr_cdcritic <> ?
              aux_dscritic = pc_busca_aplicacoes_car.pr_dscritic 
                             WHEN pc_busca_aplicacoes_car.pr_dscritic <> ?.
                                                            
        /* Buscar o XML na tabela de retorno da procedure Progress */ 
        ASSIGN xml_req = pc_busca_aplicacoes_car.pr_clobxmlc.

        /* Efetuar a leitura do XML*/ 
        SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
        PUT-STRING(ponteiro_xml,1) = xml_req. 
         
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
            xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
            IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
             NEXT. 
        
            IF xRoot2:NUM-CHILDREN > 0 THEN
               CREATE tt-dados-mitra.

            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
            
                xRoot2:GET-CHILD(xField,aux_cont).
                    
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                
                xField:GET-CHILD(xText,1).                   

                ASSIGN aux_nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                       aux_idtippro = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtippro"
                       aux_cdprodut = INT (xText:NODE-VALUE) WHEN xField:NAME = "cdprodut"
                       aux_nmprodut = xText:NODE-VALUE WHEN xField:NAME = "nmprodut"
                       aux_dsnomenc = xText:NODE-VALUE WHEN xField:NAME = "dsnomenc"
                       aux_nmdindex = xText:NODE-VALUE WHEN xField:NAME = "nmdindex"
                       aux_vlaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica"
                       aux_vlsldtot = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldtot"
                       aux_vlsldrgt = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldrgt"
                       aux_vlrdirrf = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlrdirrf"
                       aux_percirrf = DECI(xText:NODE-VALUE) WHEN xField:NAME = "percirrf"
                       aux_dtmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dtmvtolt"
                       aux_dtvencto = xText:NODE-VALUE WHEN xField:NAME = "dtvencto"
                       aux_qtdiacar = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiacar"
                       aux_txaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txaplica"
                       aux_idblqrgt = INT (xText:NODE-VALUE) WHEN xField:NAME = "idblqrgt"
                       aux_dsblqrgt = xText:NODE-VALUE WHEN xField:NAME = "dsblqrgt"
                       aux_dsresgat = xText:NODE-VALUE WHEN xField:NAME = "dsresgat"
                       aux_dtresgat = xText:NODE-VALUE WHEN xField:NAME = "dtresgat"
                       aux_cdoperad = xText:NODE-VALUE WHEN xField:NAME = "cdoperad"
                       aux_nmoperad = xText:NODE-VALUE WHEN xField:NAME = "nmoperad"
                       aux_idtxfixa = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtxfixa".                                                                                                      
            END.            

            ASSIGN tt-dados-mitra.identificacao = "RDC_"
                                                 + STRING(crapjur.nrdconta) + "_"
                                                 + STRING(aux_nraplica)
                   tt-dados-mitra.nome = "RDC_CDI - RF"
                   tt-dados-mitra.carteira = "CECRED_PROPRIA"
                   tt-dados-mitra.data_entrada = STRING(glb_dtmvtolt, 
                                                        "99/99/9999")
                   tt-dados-mitra.quantidade = "1"
                   tt-dados-mitra.pu = STRING(aux_vlsldrgt)
                   tt-dados-mitra.inicio = STRING(glb_dtmvtolt, "99/99/9999")
                   tt-dados-mitra.vencimento = aux_dtvencto
                   tt-dados-mitra.valor = tt-dados-mitra.pu
                   tt-dados-mitra.porc_index = IF aux_idtxfixa = 1 THEN
                                                  "100"
                                               ELSE
                                                  STRING(aux_txaplica)
                   tt-dados-mitra.taxa = IF aux_idtxfixa = 1 THEN
                                            STRING(aux_txaplica)
                                         ELSE
                                            ""
                   tt-dados-mitra.contraparte = crapjur.nmfansia
                   tt-dados-mitra.tipo_marcacao = "C"
                   tt-dados-mitra.codigo = "RDC_" + STRING(crapjur.nrdconta) +
                                            STRING(aux_nraplica)
                   tt-dados-mitra.contrato = tt-dados-mitra.codigo
                   tt-dados-mitra.status_quantidade = IF (aux_dsblqrgt = "BLOQUEADA") THEN
                                                          "Vinculado"
                                                      ELSE "Disponivel"
                   tt-dados-mitra.estrategia_1 = "RDC"
                   tt-dados-mitra.estrategia_2 = tt-dados-mitra.status_quantidade
                   tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                   tt-dados-mitra.amortizacao = "1"
                   tt-dados-mitra.financeiro_contabil_bruto = "0".
        END.                

        SET-SIZE(ponteiro_xml) = 0. 
     
        DELETE OBJECT xDoc. 
        DELETE OBJECT xRoot. 
        DELETE OBJECT xRoot2. 
        DELETE OBJECT xField. 
        DELETE OBJECT xText.
                
        /*******FIM CONSULTA APLICACAOES**********/
    END.

    /*******CONSULTA INFORMACOES DE EMPRESTIMOS **********/
     FOR EACH crapepr WHERE crapepr.cdcooper  = glb_cdcooper
                      AND   crapepr.inliquid <> 1 NO-LOCK:
         FIND FIRST crapass WHERE 
                                crapass.cdcooper = crapepr.cdcooper
                            AND crapass.nrdconta = crapepr.nrdconta NO-LOCK NO-ERROR.
         
       
            aux_nmconpar = substring(crapass.nmprimtl,1,
                           r-index(crapass.nmprimtl,"-") - 1).
        
        
        /*INFORMACAO DA COLUNA IDENTIFICACAO,  CONTRATO E AMORTIZAÇÃO*/
        IF crapepr.cdlcremp = 1 OR crapepr.cdlcremp = 2 THEN
           ASSIGN aux_dsidendi = "REPASSE CAIXA"
                  aux_dsnomeli = "BNDES_PRE_360 - RF".
        ELSE IF crapepr.cdlcremp = 3 THEN
           ASSIGN aux_dsidendi = "REFAP"
                  aux_dsnomeli = "EMPRESTIMOS_CDI - RF".
        ELSE IF crapepr.cdlcremp = 4 THEN
           ASSIGN aux_dsidendi = "CCB MAIS CREDITO"
                  aux_dsnomeli = "EMPRESTIMOS_CDI - RF".
        ELSE IF crapepr.cdlcremp = 5 THEN
           ASSIGN aux_dsidendi = "REPASSE BNDES"
                  aux_dsnomeli = "BNDES - PROCAPCRED_TJLP - RF".
		ELSE IF crapepr.cdlcremp = 6 THEN
           ASSIGN aux_dsidendi = "REPASSE CAIXA"
                  aux_dsnomeli = "BNDES_PRE_360 - RF".
        ELSE 
           ASSIGN aux_dsidendi = " "
                  aux_dsnomeli = "NAO CADASTRADA".

        
       /* INFORMAÇÃO DA COLUNA TRATAMENTO*/
       IF crapepr.cdlcremp = 3 THEN
          aux_dstratam = "Correção CDI - Diária_d.c./360 % Cmp_1".
       ELSE IF crapepr.cdlcremp = 4 THEN
          aux_dstratam = "Correção CDI - Diária_d.c./360 % Cmp_1".
	   ELSE IF crapepr.cdlcremp = 6 THEN
          aux_dstratam = "Prefixado_d.c./360 % Cmp_0".
       ELSE
          aux_dstratam = "".
      
       
       FIND FIRST crawepr WHERE
                   crawepr.cdcooper = crapepr.cdcooper AND
                   crawepr.nrdconta = crapepr.nrdconta AND
                   crawepr.nrctremp = crapepr.nrctremp NO-LOCK NO-ERROR.

        ASSIGN aux_dstiprod = "".

        /* Se for Pos-Fixado */
        IF crawepr.tpemprst = 2 THEN
           DO:
              IF crawepr.cddindex = 1 THEN
                 aux_dstiprod = "CDI".
              ELSE IF crawepr.cddindex = 2 THEN
                 aux_dstiprod = "TR".

              ASSIGN aux_dsnomeli = "EMPRESTIMO_" + aux_dstiprod + "360 - RF"
                     aux_dsidendi = "POS".
           END.

        ASSIGN aux_identifi = "EMP"
                            + aux_dstiprod + "_"
                            + STRING(crapass.nrdconta) + "_"
                            + STRING(crapepr.nrctremp).
  
           CREATE tt-dados-mitra.
           ASSIGN tt-dados-mitra.identificacao = aux_identifi
                  tt-dados-mitra.carteira = "CECRED_PROPRIA"
                  tt-dados-mitra.data_entrada = STRING(crapepr.dtmvtolt,"99/99/9999")
                  tt-dados-mitra.quantidade = "1"
                  tt-dados-mitra.pu = STRING(crapepr.vlemprst)
                  tt-dados-mitra.taxa = IF crapepr.cdlcremp = 1 OR crapepr.cdlcremp = 2 THEN
                                           STRING(crawepr.percetop)
                                        ELSE IF crapepr.cdlcremp = 6 THEN
                                             "8,73"
                                        ELSE
											 " "
                  tt-dados-mitra.contraparte = STRING(aux_nmconpar)
                  tt-dados-mitra.tipo_marcacao = "C"
                  tt-dados-mitra.codigo = IF crawepr.tpemprst = 2 THEN
                                             STRING(crapass.nrdconta) + "_" + STRING(crapepr.nrctremp)
                                          ELSE
                                             STRING(crapass.nrmatric) + "_" + STRING(crapepr.nrctremp)
                  tt-dados-mitra.contrato = tt-dados-mitra.identificacao
                  tt-dados-mitra.estrategia_1 = aux_dsidendi
                  tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                  tt-dados-mitra.financeiro_contabil_bruto = "0".
        
        /* Se for Pos-Fixado */
        IF crawepr.tpemprst = 2 THEN
           DO:
              OPEN QUERY q_crappep FOR EACH crappep NO-LOCK
                                      WHERE crappep.cdcooper = crapepr.cdcooper
                                        AND crappep.nrdconta = crapepr.nrdconta
                                        AND crappep.nrctremp = crapepr.nrctremp.

              REPEAT WHILE NOT QUERY-OFF-END("q_crappep"):
                GET NEXT q_crappep.
              END.

              EMPTY TEMP-TABLE tt-datas-parcelas.

              ASSIGN aux_contador = 0
                     aux_qtdparce = NUM-RESULTS("q_crappep")
                     aux_dtultpre = ADD-INTERVAL(crawepr.dtdpagto,crawepr.qtpreemp - 1,"months").

              IF DAY(crapepr.dtmvtolt) > DAY(crawepr.dtdpagto) THEN
                 ASSIGN aux_dtinterv = DATE("01/" + STRING(MONTH(crapepr.dtmvtolt)) + "/" + STRING(YEAR(crapepr.dtmvtolt)))
                        aux_dtinterv = ADD-INTERVAL(aux_dtinterv,1,"months").
              ELSE
                 ASSIGN aux_dtinterv = crapepr.dtmvtolt.

              ASSIGN aux_dtinterv = DATE(STRING(DAY(crawepr.dtdpagto)) + "/" + STRING(MONTH(aux_dtinterv)) + "/" + STRING(YEAR(aux_dtinterv))).

              DO WHILE TRUE:

                 CREATE tt-dados-mitra.
                 ASSIGN aux_contador = aux_contador + 1
                        tt-dados-mitra.identificacao = aux_identifi
                        tt-dados-mitra.nome = aux_dsnomeli 
                        tt-dados-mitra.inicio = STRING(crawepr.dtaprova,"99/99/9999")
                        tt-dados-mitra.vencimento = STRING(aux_dtinterv,"99/99/9999")
                        tt-dados-mitra.valor = STRING(crapepr.vlemprst)
                        tt-dados-mitra.taxa = STRING(ROUND((EXP((crawepr.txmensal / 100) + 1, 12) - 1) * 100, 2))
                        tt-dados-mitra.porc_index = "100"
                        tt-dados-mitra.contraparte =  STRING(aux_nmconpar)
                        tt-dados-mitra.contrato = tt-dados-mitra.identificacao
                        tt-dados-mitra.parcela = STRING(aux_contador)
                        tt-dados-mitra.amortizacao = STRING(ROUND(1 / aux_qtdparce, 2))
                        tt-dados-mitra.tratamento = aux_dstratam
                        tt-dados-mitra.estrategia_1 = aux_dsidendi
                        tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                        tt-dados-mitra.financeiro_contabil_bruto = "0".

                 IF NOT CAN-FIND(FIRST crappep WHERE crawepr.cdcooper = crapepr.cdcooper
                                                 AND crappep.nrdconta = crapepr.nrdconta
                                                 AND crappep.nrctremp = crapepr.nrctremp
                                                 AND crappep.dtvencto = aux_dtinterv) THEN
                    DO:
                       CREATE tt-datas-parcelas.
                       ASSIGN tt-datas-parcelas.nrparepr = 0
                              tt-datas-parcelas.dtparepr = aux_dtinterv

                              tt-dados-mitra.amortizacao = "0".
                    END.

                 ASSIGN aux_dtinterv = ADD-INTERVAL(aux_dtinterv,1,"months").

                 IF aux_dtinterv > aux_dtultpre THEN
                    LEAVE.

              END. /* DO WHILE TRUE */

              FOR EACH tt-datas-parcelas NO-LOCK:
                 CREATE tt-dados-mitra.
                 ASSIGN tt-dados-mitra.contrato = "EMP"
                                                + aux_dstiprod + "_"
                                                + STRING(crapass.nrdconta) + "_"
                                                + STRING(crapepr.nrctremp)
                        tt-dados-mitra.financeiro_contabil_bruto = "0"
                        tt-dados-mitra.tipo_evento = "Incorporacao"
                        tt-dados-mitra.data_incorporacao = STRING(tt-datas-parcelas.dtparepr,"99/99/9999")
                        tt-dados-mitra.incorpora_juros = "Sim"
                        tt-dados-mitra.incorpora_correcao = "Sim".
              END.

           END.
        ELSE
           DO:
              aux_qtdparce = ROUND((crawepr.dtvencto - crawepr.dtaprova)/ 30,0) + crapepr.qtpreemp.
              aux_qtcarenc = ROUND((crawepr.dtvencto - crawepr.dtaprova)/ 30,0).
              aux_vlamorti = 1 / INTE(crapepr.qtpreemp).
              aux_diavecto = crawepr.dtaprova + 30.
              
              /* Datas das Prestacoes */
              RUN calcula_data_parcela  (crawepr.cdcooper, aux_diavecto, aux_qtdparce).
                 
              DO aux_contador = 1 TO aux_qtdparce TRANSACTION:
                 
                FIND tt-datas-parcelas WHERE tt-datas-parcelas.nrparepr = aux_contador
                                             NO-LOCK NO-ERROR.
                 
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

                RUN retorna-dia-util IN h-b1wgen0015  (INPUT crawepr.cdcooper,
                                                        INPUT TRUE, /** Feriado  **/
                                                        INPUT FALSE,  /** Anterior **/
                                                        INPUT-OUTPUT tt-datas-parcelas.dtparepr). 
                                                                   
             
                DELETE PROCEDURE h-b1wgen0015.

                CREATE tt-dados-mitra. 
                 ASSIGN tt-dados-mitra.identificacao = aux_identifi
                        tt-dados-mitra.nome = aux_dsnomeli 
                        tt-dados-mitra.inicio = STRING(crawepr.dtaprova,"99/99/9999")
                        tt-dados-mitra.vencimento = STRING(tt-datas-parcelas.dtparepr,"99/99/9999")
                        tt-dados-mitra.valor = STRING(crapepr.vlemprst)
                        tt-dados-mitra.taxa = IF crapepr.cdlcremp = 5 THEN
                                                 "0,1"
                                              ELSE IF crapepr.cdlcremp = 6 THEN
                                                   "8,73"
                                              ELSE
                                                   " "
                        tt-dados-mitra.porc_index = "100"
                        tt-dados-mitra.contraparte =  STRING(aux_nmconpar)
                        tt-dados-mitra.contrato = tt-dados-mitra.identificacao
                        tt-dados-mitra.parcela = STRING(aux_contador)
                        tt-dados-mitra.amortizacao = IF (aux_contador <= aux_qtcarenc) THEN
                                                        "0"
                               ELSE IF crapepr.cdlcremp = 6 THEN
                                                        STRING(ROUND(aux_vlamorti, 9))
                               ELSE
                                                       STRING(aux_vlamorti)
                        tt-dados-mitra.tratamento = aux_dstratam
                        tt-dados-mitra.estrategia_1 = aux_dsidendi
                        tt-dados-mitra.estrategia_3 = tt-dados-mitra.contraparte
                        tt-dados-mitra.financeiro_contabil_bruto = "0".

              END.
           END.
    END.


    /*******FIM CONSULTA INFORMACOES DE EMPRESTIMOS**********/


    RUN gera_arquivo.

END. /* carrega_dados */

PROCEDURE geraPercRisco:

    DEF INPUT  PARAM par_dsnivris AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_percrisc AS DECI FORMAT "999.999"  NO-UNDO.
    
    IF par_dsnivris = "" THEN
        ASSIGN par_dsnivris = "A".

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND 
                       craptab.tptabela = "GENERI"      AND 
                       craptab.cdempres = 00            AND
                       craptab.cdacesso = "PROVISAOCL"  AND
                       TRIM(SUBSTR(craptab.dstextab,8,3)) = par_dsnivris
                       NO-LOCK NO-ERROR.
    ASSIGN par_percrisc = (DECIMAL(SUBSTR(craptab.dstextab,1,6))) / 100 .

END. /* geraPercRisco */

OUTPUT STREAM str_1 CLOSE.

RUN fontes/fimprg.p.
