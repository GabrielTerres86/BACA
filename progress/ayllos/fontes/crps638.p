/*..............................................................................

    Programa: fontes/crps638.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013                  Ultima Atualizacao : 06/10/2016

    Dados referente ao programa:

    Frequencia : Diario (Batch).
    Objetivo   : Convenios Sicredi - Relatório de Conciliação.
                 Chamado Softdesk 43337.

    Alteracoes : 06/05/2013 - Alteração para rodar em cada cooperativa (Lucas).

                 24/05/2013 - Tratamento DARFs (Lucas).

                 03/06/2013 - Correção format vlrs totais (Lucas).

                 11/06/2013 - Somatória de multas e juros ao campo de
                              valor da fatura e melhorias em consultas
                              (Lucas).

                 14/06/2013 - Correção listagem DARF SIMPLES (Lucas).

                 19/06/2013 - Quebra de listagem de convenios por segmto (Lucas).

                 24/06/2013 - Rel.636 Totalização por Cooperativa (Lucas).

                 15/08/2013 - Incluir procedure tt-totais para totalizar por
                              convenios e ordenar pela quantidade total maior
                              para menor no rel636 (Lucas R.).

                 23/04/2014 - Alterar campo.crapscn.nrdiaflt por dsdianor
                              Softdesk 142529 (Lucas R.)

                 24/04/2014 - Inclusao de FIELDS para os for craplft e crapcop
                              (Lucas R.)

                 28/04/2014 - Inclusão de deb. automatico para os relatorios
                              crrl634,crrl635,crrl636 Softdesk 149911 (Lucas R.)

                 05/05/2014 - Ajustes migracao Oracle (Elton).

                 17/06/2014 - 135941 Correcao de quebra de pagina e inclusao do
                              campo vltardrf nos fields da crapcop, procedure
                              gera-rel-mensal-cecred (Carlos)

                 06/08/2014 - Ajustes de paginacao e espacamentos no relatorio
                              crrl636, nos totais de DEBITO AUTOMATICO e
                              TOTAL POR MEIO DE ARRECADACAO (Carlos)

                 29/12/2014 - #232620 Correcao na busca dos convenios que nao
                              sao de debito automatico com a inclusao da clausula
                              crapscn.dsoparre <> "E" (Carlos)

                 06/01/2015 - #232620 Correcao do totalizador de receita liquida
                              da cooperativa para deb automatico e totalizadores
                              gerais do relatorio 636 (Carlos)

                 24/02/2015 - Correção na alimentação do campo 'tt-rel634.vltrfuni'
                              (Lunelli - SD 249805)

                30/04/2015 - Proj. 186 -> Segregacao receita e tarifa em PF e PJ
                             Criacao do novo arquivo AAMMDD_CONVEN_SIC.txt
                             (Guilherme/SUPERO)

                26/06/2015 - Incluir Format com negativo nos FORMs do rel634 no 
                             campo vlrecliq (Lucas Ranghetti #299004)
                                   
                06/07/2015 - Alterar calculo no meio de arrecadacao CAIXA no 
                             acumulativo do campo tt-rel634.vlrecliq, pois estava
                             calculando a tarifa errada. (Lucas Ranghetti #302607)
                             
                21/09/2015 - Incluindo calculo de pagamentos GPS.
                             (André Santos - SUPERO)
                             
                04/12/2015 - Retirar trecho do codigo onde faz a reversao 
                             (Lucas Ranghetti #326987 )
                             
                11/12/2015 - Adicionar sinal negativo nos campos tot_vlrliqpj e 
                             deb_vlrliqpj crrl635 (Lucas Ranghetti #371573 )
                
                06/01/2016 - Retirado o valor referente a taxa de GPS do cabecalho 
                             do arquivo que vai para o radar. (Lombardi #378512)
                
                19/05/2016 - Adicionado negativo no format do f_totais_rel635 
                             (Lucas Ranghetti #447067)
                             
                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                             (Guilherme/SUPERO)
..............................................................................*/

DEF STREAM str_1.  /* Rel.634 - CONCILIACAO CONV. SICREDI DIARIO         */
DEF STREAM str_2.  /* Rel.635 - CONCILIACAO CONV. SICREDI MENSAL         */
DEF STREAM str_3.  /* Rel.636 - CONCILIACAO CONV. SICREDI MENSAL p/ COOP */

{ includes/var_batch.i "NEW" }

DEF VAR aux_datainic AS    DATE                                   NO-UNDO.
DEF VAR aux_datafina AS    DATE                                   NO-UNDO.
DEF VAR aux_dtmvtolt AS    DATE                                   NO-UNDO.
DEF VAR aux_dtvencto AS    DATE                                   NO-UNDO.
DEF VAR aux_cdcooper AS    INTE                                   NO-UNDO.
DEF VAR aux_vltarfat AS    DECI                                   NO-UNDO.

DEF VAR aux_qttotfat AS    INTE                                   NO-UNDO.
DEF VAR aux_vltotfat AS    DECI                                   NO-UNDO.
DEF VAR aux_vltottar AS    DECI                                   NO-UNDO.

/* Acumuladores */
DEF VAR tot_qttotfat AS    INTE                                   NO-UNDO.
DEF VAR tot_vltotfat AS    DECI                                   NO-UNDO.
DEF VAR tot_vlrecliq AS    DECI                                   NO-UNDO.
DEF VAR tot_vltrfuni AS    DECI                                   NO-UNDO.
/* Divisao PF/PJ*/
DEF VAR tot_vlrliqpf AS    DECI                                   NO-UNDO.
DEF VAR tot_vlrliqpj AS    DECI                                   NO-UNDO.
DEF VAR tot_vlrtrfpf AS    DECI                                   NO-UNDO.
DEF VAR tot_vlrtrfpj AS    DECI                                   NO-UNDO.
DEF VAR tot_trfgpspf AS    DECI                                   NO-UNDO.
DEF VAR tot_trfgpspj AS    DECI                                   NO-UNDO.

/* TOTAIS INTERNET */
DEF VAR int_qttotfat AS    INTE                                   NO-UNDO.
DEF VAR int_vltotfat AS    DECI                                   NO-UNDO.
DEF VAR int_vlrecliq AS    DECI                                   NO-UNDO.
DEF VAR int_vltrfuni AS    DECI                                   NO-UNDO.
/* Divisao PF/PJ*/
DEF VAR int_vlrliqpf AS    DECI                                   NO-UNDO.
DEF VAR int_vlrliqpj AS    DECI                                   NO-UNDO.
DEF VAR int_vlrtrfpf AS    DECI                                   NO-UNDO.
DEF VAR int_vlrtrfpj AS    DECI                                   NO-UNDO.

/* TOTAIS CAIXA */
DEF VAR cax_qttotfat AS    INTE                                   NO-UNDO.
DEF VAR cax_vltotfat AS    DECI                                   NO-UNDO.
DEF VAR cax_vlrecliq AS    DECI                                   NO-UNDO.
DEF VAR cax_vltrfuni AS    DECI                                   NO-UNDO.
/* Divisao PF/PJ*/
DEF VAR cax_vlrliqpf AS    DECI                                   NO-UNDO.
DEF VAR cax_vlrliqpj AS    DECI                                   NO-UNDO.
DEF VAR cax_vlrtrfpf AS    DECI                                   NO-UNDO.
DEF VAR cax_vlrtrfpj AS    DECI                                   NO-UNDO.

/* TOTAIS TAA */
DEF VAR taa_qttotfat AS    INTE                                   NO-UNDO.
DEF VAR taa_vltotfat AS    DECI                                   NO-UNDO.
DEF VAR taa_vlrecliq AS    DECI                                   NO-UNDO.
DEF VAR taa_vltrfuni AS    DECI                                   NO-UNDO.
/* Divisao PF/PJ*/
DEF VAR taa_vlrliqpf AS    DECI                                   NO-UNDO.
DEF VAR taa_vlrliqpj AS    DECI                                   NO-UNDO.
DEF VAR taa_vlrtrfpf AS    DECI                                   NO-UNDO.
DEF VAR taa_vlrtrfpj AS    DECI                                   NO-UNDO.

/* TOTAIS DEB AUTOMATICO */
DEF VAR deb_qttotfat AS    INTE                                   NO-UNDO.
DEF VAR deb_vltotfat AS    DECI                                   NO-UNDO.
DEF VAR deb_vlrecliq AS    DECI                                   NO-UNDO.
DEF VAR deb_vltrfuni AS    DECI                                   NO-UNDO.
/* Divisao PF/PJ*/
DEF VAR deb_vlrliqpf AS    DECI                                   NO-UNDO.
DEF VAR deb_vlrliqpj AS    DECI                                   NO-UNDO.
DEF VAR deb_vlrtrfpf AS    DECI                                   NO-UNDO.
DEF VAR deb_vlrtrfpj AS    DECI                                   NO-UNDO.

/* INTERNET */
DEF VAR tot_qtfatint AS    INTE                                   NO-UNDO.
DEF VAR tot_vlfatint AS    DECI                                   NO-UNDO.
/* TAA */
DEF VAR tot_qtfattaa AS    INTE                                   NO-UNDO.
DEF VAR tot_vlfattaa AS    DECI                                   NO-UNDO.
/* CAIXA */
DEF VAR tot_qtfatcxa AS    INTE                                   NO-UNDO.
DEF VAR tot_vlfatcxa AS    DECI                                   NO-UNDO.
/* DEB AUTO */
DEF VAR tot_qtfatdeb AS    INTE                                   NO-UNDO.
DEF VAR tot_vlfatdeb AS    DECI                                   NO-UNDO.
DEF VAR aux_vltarifa AS    DECI                                   NO-UNDO.
/* SICREDI - GPS */
DEF VAR tot_qtgpsdeb AS    INTE                                   NO-UNDO.
DEF VAR tot_vlgpsdeb AS    DECI                                   NO-UNDO.
DEF VAR aux_vltfcxcb AS    DECI                                   NO-UNDO.
DEF VAR aux_vltfcxsb AS    DECI                                   NO-UNDO.
DEF VAR aux_vlrtrfib AS    DECI                                   NO-UNDO.
DEF VAR aux_vltargps AS    DECI                                   NO-UNDO.
DEF VAR aux_dsempgps AS    CHAR                                   NO-UNDO.
DEF VAR aux_dsnomcnv AS    CHAR                                   NO-UNDO.
DEF VAR aux_tpmeiarr AS    CHAR                                   NO-UNDO.
DEF VAR aux_dsmeiarr AS    CHAR                                   NO-UNDO.


DEF VAR ger_vltrpapf AS    DECI    EXTENT 999 /*Vl Tarif PA PF */ NO-UNDO.
DEF VAR ger_vltrpapj AS    DECI    EXTENT 999 /*Vl Tarif PA PJ */ NO-UNDO.

DEF VAR aux_inpessoa AS    INTE                                   NO-UNDO.
DEF VAR aux_nmarqint AS    CHAR   FORMAT "x(21)"                  NO-UNDO.

/* Para arquivo */
DEF VAR aux_nmarqimp AS    CHAR   FORMAT "x(21)"                  NO-UNDO.
DEF VAR aux_nomedarq AS    CHAR   FORMAT "x(21)"                  NO-UNDO.
DEF VAR aux_dscooper AS    CHAR   FORMAT "x(21)"                  NO-UNDO.
DEF VAR aux_nmarqrel AS    CHAR   FORMAT "x(21)"                  NO-UNDO.

/* variaveis para includes/cabrel132_X.i */
DEF VAR rel_nmresemp AS    CHAR   FORMAT "x(15)"                  NO-UNDO.
DEF VAR rel_nmrelato AS    CHAR   FORMAT "x(40)" EXTENT 5         NO-UNDO.
DEF VAR rel_nrmodulo AS    INTE   FORMAT "9"                      NO-UNDO.
DEF VAR rel_nmempres AS    CHAR   FORMAT "x(15)"                  NO-UNDO.
DEF VAR rel_nmmodulo AS    CHAR   FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]   NO-UNDO.

DEF BUFFER b-crapthi FOR crapthi.

/* Para relatorio 634 */
DEF TEMP-TABLE tt-rel634 NO-UNDO
    FIELD nmconven AS  CHAR
    FIELD qttotgps AS  INTE
    FIELD vltotgps AS  DECI
    FIELD qttotfat AS  INTE
    FIELD vltotfat AS  DECI
    FIELD vlrecliq AS  DECI
    FIELD vltrfuni AS  DECI
    FIELD dsdianor LIKE crapscn.dsdianor
    FIELD dsmeiarr AS  CHAR
    FIELD cdempres AS  CHAR
    FIELD tpmeiarr AS  CHAR
    FIELD nrrenorm LIKE crapscn.nrrenorm.

/* Para relatorio 635 */
DEF TEMP-TABLE tt-rel635 NO-UNDO
    FIELD cdempres AS  CHAR
    FIELD tpmeiarr AS  CHAR
    FIELD nmconven AS  CHAR
    FIELD dsmeiarr AS  CHAR
    FIELD inpessoa AS  INTE
    FIELD qtfatura AS  INTE
    FIELD vltotfat AS  DECI
    FIELD vlrecliq AS  DECI
    FIELD vlrliqpf AS  DECI /* Divisao PF/PJ*/
    FIELD vlrliqpj AS  DECI /* Divisao PF/PJ*/
    FIELD vltottar AS  DECI
    FIELD vlrtrfpf AS  DECI /* Divisao PF/PJ*/
    FIELD vlrtrfpj AS  DECI /* Divisao PF/PJ*/
    FIELD dsdianor LIKE crapscn.dsdianor
    FIELD nrrenorm LIKE crapscn.nrrenorm.

/* Para relatorio 636 */
DEF TEMP-TABLE tt-totais NO-UNDO
    FIELD cdempres AS  CHAR
    FIELD tpmeiarr AS  CHAR
    FIELD dsmeiarr AS  CHAR
    FIELD nmconven AS  CHAR
    FIELD qtfatura AS  INTE
    FIELD vltotfat AS  DECI
    FIELD vltottar AS  DECI
    FIELD vlrecliq AS  DECI.

/* Para relatorio 636 */
DEF TEMP-TABLE tt-rel636 NO-UNDO
    FIELD cdcooper AS INT
    FIELD cdempres AS CHAR
    FIELD tpmeiarr AS CHAR
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmconven AS CHAR
    FIELD dsmeiarr AS CHAR
    FIELD qtfatura AS INTE
    FIELD vltotfat AS DECI
    FIELD vlrecliq AS DECI
    FIELD vltottar AS DECI
    FIELD dsdianor LIKE crapscn.dsdianor
    FIELD nrrenorm LIKE crapscn.nrrenorm.

FORM "TOTAL INTERNET" AT 01
     int_qttotfat   AT 58  FORMAT "zzzzzz9"
     int_vltotfat   AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     int_vlrecliq   AT 87  FORMAT "zzz,zzz,zzz,zz9.99-"
     int_vltrfuni   AT 107 FORMAT "zz,zzz,zz9.99"
     SKIP
     "TOTAL CAIXA" AT 01
     cax_qttotfat   AT 58  FORMAT "zzzzzz9"
     cax_vltotfat   AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     cax_vlrecliq   AT 87  FORMAT "zzz,zzz,zzz,zz9.99-"
     cax_vltrfuni   AT 107 FORMAT "zz,zzz,zz9.99"
     SKIP
     "TOTAL TAA" AT 01
     taa_qttotfat   AT 58  FORMAT "zzzzzz9"
     taa_vltotfat   AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     taa_vlrecliq   AT 87  FORMAT "zzz,zzz,zzz,zz9.99-"
     taa_vltrfuni   AT 107 FORMAT "zz,zzz,zz9.99"
     SKIP
     "TOTAL DEB. AUTOMATICO" AT 01
     deb_qttotfat   AT 58  FORMAT "zzzzzz9"
     deb_vltotfat   AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     deb_vlrecliq   AT 87  FORMAT "zzz,zzz,zzz,zz9.99-"
     deb_vltrfuni   AT 107 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     "TOTAL GERAL"  AT 01
     tot_qttotfat   AT 58  FORMAT "zzzzzz9"
     tot_vltotfat   AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vlrecliq   AT 87  FORMAT "zzz,zzz,zzz,zz9.99-"
     tot_vltrfuni   AT 107 FORMAT "zz,zzz,zz9.99"
     WITH WIDTH 132 NO-LABELS FRAME f_totais_rel634.


FORM "TOTAL INTERNET" AT 01
     int_qttotfat     AT 58  FORMAT "zzzzzz9"
     int_vltotfat     AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     /* Divisao PF/PJ */
     int_vlrliqpf     AT 088 FORMAT "zzz,zzz,zzz,zz9.99"
     int_vlrtrfpf     AT 109 FORMAT "zz,zzz,zz9.99"
     int_vlrliqpj     AT 126 FORMAT "zzz,zzz,zzz,zz9.99-"
     int_vlrtrfpj     AT 147 FORMAT "zz,zzz,zz9.99"
     int_vlrecliq     AT 165 FORMAT "zzz,zzz,zzz,zz9.99"
     int_vltrfuni     AT 183 FORMAT "zz,zzz,zz9.99"

     SKIP
     "TOTAL CAIXA"    AT 01
     cax_qttotfat     AT 58  FORMAT "zzzzzz9"
     cax_vltotfat     AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     /* Divisao PF/PJ */
     cax_vlrliqpf     AT 088 FORMAT "zzz,zzz,zzz,zz9.99"
     cax_vlrtrfpf     AT 109 FORMAT "zz,zzz,zz9.99"
     cax_vlrliqpj     AT 126 FORMAT "zzz,zzz,zzz,zz9.99-"
     cax_vlrtrfpj     AT 147 FORMAT "zz,zzz,zz9.99"
     cax_vlrecliq     AT 165 FORMAT "zzz,zzz,zzz,zz9.99"
     cax_vltrfuni     AT 183 FORMAT "zz,zzz,zz9.99"
     SKIP
     "TOTAL TAA"      AT 01
     taa_qttotfat     AT 58  FORMAT "zzzzzz9"
     taa_vltotfat     AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     /* Divisao PF/PJ */
     taa_vlrliqpf     AT 088 FORMAT "zzz,zzz,zzz,zz9.99"
     taa_vlrtrfpf     AT 109 FORMAT "zz,zzz,zz9.99"
     taa_vlrliqpj     AT 126 FORMAT "zzz,zzz,zzz,zz9.99-"
     taa_vlrtrfpj     AT 147 FORMAT "zz,zzz,zz9.99"
     taa_vlrecliq     AT 165 FORMAT "zzz,zzz,zzz,zz9.99"
     taa_vltrfuni     AT 183 FORMAT "zz,zzz,zz9.99"
     SKIP
     "TOTAL DEB. AUTOMATICO" AT 01
     deb_qttotfat     AT 58  FORMAT "zzzzzz9"
     deb_vltotfat     AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     /* Divisao PF/PJ */
     deb_vlrliqpf     AT 088 FORMAT "zzz,zzz,zzz,zz9.99"
     deb_vlrtrfpf     AT 109 FORMAT "zz,zzz,zz9.99"
     deb_vlrliqpj     AT 126 FORMAT "zzz,zzz,zzz,zz9.99-"
     deb_vlrtrfpj     AT 147 FORMAT "zz,zzz,zz9.99"
     deb_vlrecliq     AT 165 FORMAT "zzz,zzz,zzz,zz9.99"
     deb_vltrfuni     AT 183 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     "TOTAL GERAL"    AT 01
     tot_qttotfat     AT 58  FORMAT "zzzzzz9"
     tot_vltotfat     AT 66  FORMAT "zzz,zzz,zzz,zz9.99"
     /* Divisao PF/PJ */
     tot_vlrliqpf     AT 088 FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vlrtrfpf     AT 109 FORMAT "zz,zzz,zz9.99"
     tot_vlrliqpj     AT 126 FORMAT "zzz,zzz,zzz,zz9.99-"
     tot_vlrtrfpj     AT 147 FORMAT "zz,zzz,zz9.99"
     tot_vlrecliq     AT 165 FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vltrfuni     AT 183 FORMAT "zz,zzz,zz9.99"
     SKIP
     WITH WIDTH 234 NO-LABELS FRAME f_totais_rel635.

FORM "INTERNET"       AT 01
     int_qttotfat     AT 22 FORMAT "zzzzzz9"
     int_vltotfat     AT 30 FORMAT "zzz,zzz,zzz,zz9.99"
     int_vlrecliq     AT 52 FORMAT "zzz,zzz,zzz,zz9.99"
     int_vltrfuni     AT 71 FORMAT "zz,zzz,zz9.99"
     SKIP
     "CAIXA"        AT 01
     cax_qttotfat   AT 22 FORMAT "zzzzzz9"
     cax_vltotfat   AT 30 FORMAT "zzz,zzz,zzz,zz9.99"
     cax_vlrecliq   AT 52 FORMAT "zzz,zzz,zzz,zz9.99"
     cax_vltrfuni   AT 71 FORMAT "zz,zzz,zz9.99"
     SKIP
     "TAA"          AT 01
     taa_qttotfat   AT 22 FORMAT "zzzzzz9"
     taa_vltotfat   AT 30 FORMAT "zzz,zzz,zzz,zz9.99"
     taa_vlrecliq   AT 52 FORMAT "zzz,zzz,zzz,zz9.99"
     taa_vltrfuni   AT 71 FORMAT "zz,zzz,zz9.99"
     SKIP
     "DEB. AUTOMATICO" AT 01
     deb_qttotfat   AT 22 FORMAT "zzzzzz9"
     deb_vltotfat   AT 30 FORMAT "zzz,zzz,zzz,zz9.99"
     deb_vlrecliq   AT 52 FORMAT "zzz,zzz,zzz,zz9.99"
     deb_vltrfuni   AT 71 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     "TOTAL GERAL:" AT 01
     tot_qttotfat   AT 22  FORMAT "zzzzzz9"
     tot_vltotfat   AT 30  FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vlrecliq   AT 52  FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vltrfuni   AT 71 FORMAT "zz,zzz,zz9.99"
     WITH WIDTH 132 NO-LABELS FRAME f_totais_rel636.

FORM "TOTAL:"           AT 01
     tt-totais.qtfatura AT 51  FORMAT "zzzzzz9"
     tt-totais.vltotfat AT 59  FORMAT "zzz,zzz,zzz,zz9.99"
     tt-totais.vlrecliq AT 82  FORMAT "zzz,zzz,zzz,zz9.99"
     tt-totais.vltottar AT 101 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABEL WIDTH 132 FRAME f_totais_convenio.

FORM tt-rel634.nmconven COLUMN-LABEL "CONVENIO"              FORMAT "X(35)"
     tt-rel634.dsmeiarr COLUMN-LABEL "MEIO ARRECADACAO"      FORMAT "X(16)"
     tt-rel634.qttotfat COLUMN-LABEL "QTD.FATURAS"           FORMAT "zzzzzz9"
     tt-rel634.vltotfat COLUMN-LABEL "VALOR FATURAS"         FORMAT "zzz,zzz,zzz,zz9.99"
     tt-rel634.vlrecliq COLUMN-LABEL "RECEITA LIQUIDA COOP." FORMAT "zzz,zzz,zzz,zz9.99-"
     tt-rel634.vltrfuni COLUMN-LABEL "VALOR TARIFA"          FORMAT "zz,zzz,zz9.99"
     tt-rel634.nrrenorm COLUMN-LABEL "FLOAT"                 FORMAT "z9"
     tt-rel634.dsdianor COLUMN-LABEL "DIAS"                  FORMAT "x(2)"
     WITH WIDTH 132 DOWN FRAME f_rel634.

FORM tt-rel635.nmconven COLUMN-LABEL "CONVENIO"              FORMAT "X(35)"
     tt-rel635.dsmeiarr COLUMN-LABEL "MEIO ARRECADACAO"      FORMAT "X(16)"
     tt-rel635.qtfatura COLUMN-LABEL "QTD.FATURAS"           FORMAT "zzzzzz9"
     tt-rel635.vltotfat COLUMN-LABEL "VALOR FATURAS"         FORMAT "zzz,zzz,zzz,zz9.99"

     tt-rel635.vlrliqpf COLUMN-LABEL "RECEITA LIQ. COOP. PF" FORMAT "zzz,zzz,zzz,zz9.99"
     tt-rel635.vlrtrfpf COLUMN-LABEL "VALOR TARIFA PF"       FORMAT "zz,zzz,zz9.99"
     tt-rel635.vlrliqpj COLUMN-LABEL "RECEITA LIQ. COOP. PJ" FORMAT "zzz,zzz,zzz,zz9.99"
     tt-rel635.vlrtrfpj COLUMN-LABEL "VALOR TARIFA PJ"       FORMAT "zz,zzz,zz9.99"

     tt-rel635.vlrecliq COLUMN-LABEL "RECEITA LIQUIDA COOP." FORMAT "zzz,zzz,zzz,zz9.99"
     tt-rel635.vltottar COLUMN-LABEL "VALOR TARIFA"          FORMAT "zz,zzz,zz9.99"
     tt-rel635.nrrenorm COLUMN-LABEL "FLOAT"                 FORMAT "z9"
     tt-rel635.dsdianor COLUMN-LABEL "DIAS"                  FORMAT "x(2)"
     WITH WIDTH 234 DOWN FRAME f_rel635.


FORM "CONVENIO                     MEIO ARRECADACAO QTD.FATURAS      VALOR FATURAS "
     "RECEITA LIQUIDA COOP.  VALOR TARIFA FLOAT DIAS"
     SKIP
     "---------------------------- ---------------- ----------- ------------------ "
     "--------------------- ------------- ----- ----"
     WITH WIDTH 132 FRAME f_titulo_rel636.

FORM tt-rel636.nmconven AT 01  FORMAT "X(28)"
     tt-rel636.dsmeiarr AT 30  FORMAT "X(16)"
     tt-rel636.qtfatura AT 51  FORMAT "zzzzzz9"
     tt-rel636.vltotfat AT 59  FORMAT "zzz,zzz,zzz,zz9.99"
     tt-rel636.vlrecliq AT 82  FORMAT "zzz,zzz,zzz,zz9.99"
     tt-rel636.vltottar AT 101 FORMAT "zz,zzz,zz9.99"
     tt-rel636.nrrenorm AT 118 FORMAT "z9"
     tt-rel636.dsdianor AT 123 FORMAT "x(2)"
     WITH  NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABEL WIDTH 132 FRAME f_rel636.

ASSIGN glb_cdprogra = "crps638".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0   THEN
    QUIT.
       
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop   THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
        QUIT.
    END.

ASSIGN tot_vltrfuni = 0
       tot_vltotfat = 0
       tot_qttotfat = 0
       tot_vlrecliq = 0.

/* Gera relatório diário crrl634 */
ASSIGN glb_cdcritic    = 0
       aux_qttotfat    = 0
       aux_vltotfat    = 0
       aux_vltottar    = 0
       glb_cdcritic    = 0
       glb_cdrelato[1] = 634
       aux_dscooper    = "/usr/coop/" + crapcop.dsdircop + "/"
       aux_nmarqrel    = aux_dscooper + "rl/crrl634.lst"
       glb_cdempres    = 11
       glb_nrcopias    = 1
       glb_nmformul    = "132col"
       glb_nmarqimp    = aux_nmarqrel.

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

/* Tipos de Arrecadação SICREDI
   A - ATM
   B - Correspondente Bancário
   C - Caixa
   D - Internet Banking
   E - Debito Auto
   F - Arquivo de Pagamento (CNAB 240)  */

FIND FIRST crapthi WHERE crapthi.cdcooper = crapcop.cdcooper AND
                         crapthi.cdhistor = 1154             AND /* SICREDI */
                         crapthi.dsorigem = "AYLLOS"
                         NO-LOCK NO-ERROR.

/* deb automatico */
FIND FIRST b-crapthi WHERE b-crapthi.cdcooper = glb_cdcooper AND
                           b-crapthi.cdhistor = 1019         AND
                           b-crapthi.dsorigem = "AYLLOS"
                           NO-LOCK NO-ERROR.

IF  AVAIL b-crapthi THEN
    ASSIGN aux_vltarifa = b-crapthi.vltarifa.

/* Leitura para Convenios e DARFs */
FOR EACH craplft FIELDS(cdtribut cdempcon cdsegmto tpfatura vllanmto
                        vlrmulta vlrjuros cdagenci)
                 WHERE craplft.cdcooper  = crapcop.cdcooper      AND
                       craplft.dtvencto  = glb_dtmvtolt          AND 
                       craplft.insitfat  = 2                     AND
                       craplft.cdhistor  = 1154                 /* SICREDI */
                       NO-LOCK BREAK BY craplft.cdtribut
                                     BY craplft.cdempcon
                                     BY craplft.cdsegmto.

    IF  FIRST-OF (craplft.cdtribut) OR
        FIRST-OF (craplft.cdempcon) OR
        FIRST-OF (craplft.cdsegmto) THEN
        ASSIGN tot_qtfatint = 0
               tot_vlfatint = 0
               tot_qtfattaa = 0
               tot_vlfattaa = 0
               tot_qtfatcxa = 0
               tot_vlfatcxa = 0.

    IF  craplft.tpfatura <> 2  OR
        craplft.cdempcon <> 0  THEN
        DO:

            IF  FIRST-OF (craplft.cdempcon) OR
                FIRST-OF (craplft.cdsegmto) THEN
                DO:

                    /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
                    FIND FIRST crapscn WHERE crapscn.cdempcon = craplft.cdempcon AND
                                             crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
                                             crapscn.dtencemp = ?                        AND
                                             crapscn.dsoparre <> "E"   /* Debaut */
                                             NO-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapscn THEN
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempco2 = craplft.cdempcon AND
                                                     crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
                                                     crapscn.dtencemp = ?                        AND
                                                     crapscn.dsoparre <> "E"   /* Debaut */
                                                     NO-LOCK NO-ERROR NO-WAIT.
                            IF  NOT AVAIL crapscn THEN
                                NEXT.
                        END.
                END.
        END.
    ELSE
        DO:
            IF  FIRST-OF (craplft.cdtribut) THEN
                DO:
                    IF  craplft.cdtribut = "6106" THEN /* DARF SIMPLES */
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempres = "D0"
                                                    NO-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAIL crapscn THEN
                                NEXT.
                        END.
                    ELSE
                        DO: /* DARF PRETO EUROPA */
                            FIND FIRST crapscn WHERE crapscn.cdempres = "A0"
                                                    NO-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAIL crapscn THEN
                                NEXT.
                        END.
                END.
        END.

    /* Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16 */
    IF  craplft.tpfatura >= 1 THEN
        ASSIGN aux_vltarfat = crapcop.vltardrf. /* 0.16 era o valor antigo */
    ELSE
        ASSIGN aux_vltarfat = crapthi.vltarifa.


    IF  craplft.cdagenci = 90 THEN  /** Internet **/
        ASSIGN  tot_qtfatint = tot_qtfatint + 1
                tot_vlfatint = tot_vlfatint + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

    ELSE
    IF  craplft.cdagenci = 91 THEN  /** TAA **/
        ASSIGN  tot_qtfattaa = tot_qtfattaa + 1
                tot_vlfattaa = tot_vlfattaa + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

    ELSE                            /** Caixa **/
        ASSIGN  tot_qtfatcxa = tot_qtfatcxa + 1
                tot_vlfatcxa = tot_vlfatcxa + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

    IF  LAST-OF (craplft.cdempcon) OR
        LAST-OF (craplft.cdsegmto) THEN
        DO:
            /* INTERNET */
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "D"
                                     NO-LOCK NO-ERROR.
            IF  tot_qtfatint > 0 AND
                AVAIL crapstn    AND
                AVAIL crapthi    THEN
                DO:
                    FIND tt-rel634 WHERE tt-rel634.cdempres = crapscn.cdempres AND
                                         tt-rel634.tpmeiarr = crapstn.tpmeiarr EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-rel634  THEN
                        DO:
                            CREATE tt-rel634.
                            ASSIGN tt-rel634.nmconven = crapscn.dsnomcnv
                                   tt-rel634.cdempres = crapscn.cdempres
                                   tt-rel634.tpmeiarr = crapstn.tpmeiarr
                                   tt-rel634.qttotfat = tot_qtfatint
                                   tt-rel634.vltotfat = tot_vlfatint
                                   tt-rel634.vltrfuni = (crapstn.vltrfuni * tot_qtfatint)
                                   tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tot_qtfatint * aux_vltarfat)
                                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq)
                                   tt-rel634.dsdianor = crapscn.dsdianor
                                   tt-rel634.nrrenorm = crapscn.nrrenorm
                                   tt-rel634.dsmeiarr = "INTERNET".
                        END.
                    ELSE    /* Incrementa os valores anteriores */
                        ASSIGN tt-rel634.qttotfat = tt-rel634.qttotfat + tot_qtfatint
                               tt-rel634.vltotfat = tt-rel634.vltotfat + tot_vlfatint
                               tt-rel634.vltrfuni = (crapstn.vltrfuni * tt-rel634.qttotfat) 
                               /* Recalcula e sobrescreve valores derivados de tarifas */
                               tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tt-rel634.qttotfat * aux_vltarfat)
                               tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq).
                END.

            /* TAA */
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "A"
                                     NO-LOCK NO-ERROR.
            IF  tot_qtfattaa > 0 AND
                AVAIL crapstn    AND
                AVAIL crapthi    THEN
                DO:
                    FIND tt-rel634 WHERE tt-rel634.cdempres = crapscn.cdempres AND
                                         tt-rel634.tpmeiarr = crapstn.tpmeiarr EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-rel634  THEN
                        DO:
                            CREATE tt-rel634.
                            ASSIGN tt-rel634.nmconven = crapscn.dsnomcnv
                                   tt-rel634.cdempres = crapscn.cdempres
                                   tt-rel634.tpmeiarr = crapstn.tpmeiarr
                                   tt-rel634.qttotfat = tot_qtfattaa
                                   tt-rel634.vltotfat = tot_vlfattaa
                                   tt-rel634.vltrfuni = (crapstn.vltrfuni * tot_qtfattaa)
                                   tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tot_qtfattaa * crapthi.vltarifa)
                                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq)
                                   tt-rel634.dsdianor = crapscn.dsdianor
                                   tt-rel634.nrrenorm = crapscn.nrrenorm
                                   tt-rel634.dsmeiarr = "TAA".
                        END.
                    ELSE  /* Incrementa os valores anteriores */
                        ASSIGN tt-rel634.qttotfat = tt-rel634.qttotfat + tot_qtfattaa
                               tt-rel634.vltotfat = tt-rel634.vltotfat + tot_vlfattaa
                               tt-rel634.vltrfuni = (crapstn.vltrfuni * tt-rel634.qttotfat) 
                               /* Recalcula e sobrescreve valores derivados de tarifas */
                               tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tt-rel634.qttotfat * crapthi.vltarifa)
                               tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq).
                END.

            /* CAIXA */
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "C"
                                     NO-LOCK NO-ERROR.

            IF  tot_qtfatcxa > 0 AND
                AVAIL crapstn    AND
                AVAIL crapthi    THEN
                DO:
                    FIND tt-rel634 WHERE tt-rel634.cdempres = crapscn.cdempres AND
                                         tt-rel634.tpmeiarr = crapstn.tpmeiarr EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-rel634  THEN
                        DO:
                            CREATE tt-rel634.
                            ASSIGN tt-rel634.nmconven = crapscn.dsnomcnv
                                   tt-rel634.cdempres = crapscn.cdempres
                                   tt-rel634.tpmeiarr = crapstn.tpmeiarr
                                   tt-rel634.qttotfat = tot_qtfatcxa
                                   tt-rel634.vltotfat = tot_vlfatcxa
                                   tt-rel634.vltrfuni = (crapstn.vltrfuni * tot_qtfatcxa)
                                   tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tot_qtfatcxa * aux_vltarfat)
                                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq)
                                   tt-rel634.dsdianor = crapscn.dsdianor
                                   tt-rel634.nrrenorm = crapscn.nrrenorm
                                   tt-rel634.dsmeiarr = "CAIXA".

                        END.
                   ELSE /* Incrementa os valores anteriores */
                        ASSIGN tt-rel634.qttotfat = tt-rel634.qttotfat + tot_qtfatcxa
                               tt-rel634.vltotfat = tt-rel634.vltotfat + tot_vlfatcxa
                               tt-rel634.vltrfuni = (crapstn.vltrfuni * tt-rel634.qttotfat)
                               /* Recalcula e sobrescreve valores derivados de tarifas */
                               tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tt-rel634.qttotfat * aux_vltarfat)
                               tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq).

                END.

        END.

END. /* FOR EACH craplft */

/* Para debito aumatico SICREDI */
FOR EACH craplcm FIELD(cdcooper cdhistor nrdocmto nrdconta cdagenci
                       dtmvtolt nrdolote vllanmto )
                 WHERE craplcm.cdcooper = glb_cdcooper AND
                       craplcm.cdhistor = 1019         AND
                       craplcm.dtmvtolt = glb_dtmvtolt
                       NO-LOCK:

    FIND craplau WHERE craplau.cdcooper = craplcm.cdcooper AND
                       craplau.cdhistor = craplcm.cdhistor AND
                       craplau.nrdocmto = craplcm.nrdocmto AND
                       craplau.nrdconta = craplcm.nrdconta AND
                       craplau.cdagenci = craplcm.cdagenci AND
                       craplau.dtmvtopg = craplcm.dtmvtolt
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplau THEN
        NEXT.

     ASSIGN tot_qtfatdeb = 0
            tot_vlfatdeb = 0.

    /* somatoria por empresa */
    FOR EACH crapscn WHERE crapscn.cdempres = craplau.cdempres
                           NO-LOCK:

        ASSIGN tot_qtfatdeb = tot_qtfatdeb + 1
               tot_vlfatdeb = tot_vlfatdeb + craplcm.vllanmto.

    END.

    /* Se nao for debito automatico não faz */
    FIND FIRST crapscn WHERE crapscn.dsoparre = "E"                AND
                            (crapscn.cddmoden = "A"                OR
                             crapscn.cddmoden = "C")               AND
                             crapscn.cdempres = craplau.cdempres
                             NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL crapscn THEN
        NEXT.

    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                             crapstn.tpmeiarr = "E"
                             NO-LOCK NO-ERROR.

    IF  AVAIL crapstn THEN
        DO:

            FIND tt-rel634 WHERE tt-rel634.cdempres = crapscn.cdempres AND
                                 tt-rel634.tpmeiarr = crapstn.tpmeiarr
                                 EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL tt-rel634  THEN
                DO:
                    CREATE tt-rel634.
                    ASSIGN tt-rel634.nmconven = crapscn.dsnomcnv
                           tt-rel634.cdempres = crapscn.cdempres
                           tt-rel634.tpmeiarr = "E"
                           tt-rel634.qttotfat = tot_qtfatdeb
                           tt-rel634.vltotfat = tot_vlfatdeb
                           tt-rel634.vltrfuni = (crapstn.vltrfuni * tot_qtfatdeb)
                           tt-rel634.vlrecliq = tt-rel634.vltrfuni - (tot_qtfatdeb * aux_vltarifa)
                           tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq)
                           tt-rel634.dsdianor = crapscn.dsdianor
                           tt-rel634.nrrenorm = crapscn.nrrenorm
                           tt-rel634.dsmeiarr = "DEB. AUTOMATICO".
                END.
            ELSE    /* Incrementa os valores anteriores */
                ASSIGN tt-rel634.qttotfat = tt-rel634.qttotfat + tot_qtfatdeb
                       tt-rel634.vltotfat = tt-rel634.vltotfat + tot_vlfatdeb
                       tt-rel634.vltrfuni = tt-rel634.vltrfuni + (tot_qtfatdeb * crapstn.vltrfuni)
                       tt-rel634.vlrecliq = tt-rel634.vlrecliq + ((tot_qtfatdeb * crapstn.vltrfuni) - (tot_qtfatdeb * aux_vltarifa))
                       tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq).
        END.

END.

IF glb_cdcooper <> 3 THEN DO:

    /* GUIA DA PREVIDENVIA SOCIAL - SICREDI */

    /* Tarifa a ser paga ao SICREDI */
    FIND FIRST crapthi WHERE crapthi.cdcooper = glb_cdcooper
                         AND crapthi.cdhistor = 1414
                         AND crapthi.dsorigem = "AYLLOS"
                         NO-LOCK NO-ERROR.

    /* Localizar a tarifa da base */
    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                         AND craptab.nmsistem = "CRED"
                         AND craptab.tptabela = "GENERI"
                         AND craptab.cdempres = 00
                         AND craptab.cdacesso = "GPSCXASCOD"
                         AND craptab.tpregist = 0
                         NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
        ASSIGN aux_vltfcxsb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Sem.Barra */
    ELSE
        ASSIGN aux_vltfcxsb = 0.

    /* Localizar a tarifa da base */
    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                         AND craptab.nmsistem = "CRED"
                         AND craptab.tptabela = "GENERI"
                         AND craptab.cdempres = 00
                         AND craptab.cdacesso = "GPSCXACCOD"
                         AND craptab.tpregist = 0
                         NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
        ASSIGN aux_vltfcxcb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Com.Barra */
    ELSE
        ASSIGN aux_vltfcxcb = 0.

    /* Localizar a tarifa da base */
    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                         AND craptab.nmsistem = "CRED"
                         AND craptab.tptabela = "GENERI"
                         AND craptab.cdempres = 00
                         AND craptab.cdacesso = "GPSINTBANK"
                         AND craptab.tpregist = 0
                         NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
        ASSIGN aux_vlrtrfib = DECI(craptab.dstextab).  /*  Valor Tarifa IB  */
    ELSE
        ASSIGN aux_vlrtrfib = 0.

    /* Para todos os lancamentos ja pagos */
    FOR EACH craplgp
       WHERE craplgp.cdcooper = glb_cdcooper
                       AND craplgp.dtmvtolt = glb_dtmvtolt 
                       AND craplgp.idsicred <> 0
         AND craplgp.flgativo = YES
                       BREAK BY craplgp.cdcooper
                             BY craplgp.cdagenci
                             BY craplgp.tpdpagto:

        /* Inicializa Variaveis */
        ASSIGN aux_dsempgps = ""
               aux_dsnomcnv = ""
               aux_tpmeiarr = ""
               aux_dsmeiarr = ""
               aux_vltargps = 0.

        IF  craplgp.cdagenci <> 90 THEN /* CAIXA*/
            ASSIGN aux_tpmeiarr = "C"
                   aux_dsmeiarr = "CAIXA"
                   aux_vltargps = IF craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
                                     aux_vltfcxcb
                                  ELSE /* Sem Cod.Barras*/
                                     aux_vltfcxsb.
        ELSE /* INTERNET */
            ASSIGN aux_tpmeiarr = "D"
                   aux_dsmeiarr = "INTERNET"
                   aux_vltargps = aux_vlrtrfib.


        IF  craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
            ASSIGN aux_dsempgps = "GP1"
                   aux_dsnomcnv = "GPS - COM COD.BARRAS".
        ELSE /* Sem Cod.Barras*/
            ASSIGN aux_dsempgps = "GP2"
                   aux_dsnomcnv = "GPS - SEM COD.BARRAS".


        FIND FIRST tt-rel634 WHERE tt-rel634.cdempres = aux_dsempgps
                               AND tt-rel634.tpmeiarr = aux_tpmeiarr
                               EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL tt-rel634  THEN DO:
            CREATE tt-rel634.
            ASSIGN tt-rel634.nmconven = aux_dsnomcnv
                   tt-rel634.cdempres = aux_dsempgps
                   tt-rel634.tpmeiarr = aux_tpmeiarr
                   tt-rel634.qttotfat = 1
                   tt-rel634.vltotfat = craplgp.vlrtotal
                   tt-rel634.vltrfuni = aux_vltargps
                   tt-rel634.vlrecliq = tt-rel634.vltrfuni - b2crapthi.vltarifa
                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq)
                   tt-rel634.dsdianor = ""
                   tt-rel634.nrrenorm = 0
                   tt-rel634.dsmeiarr = aux_dsmeiarr.
        END.
        ELSE DO:    /* Incrementa os valores anteriores */
            ASSIGN tt-rel634.qttotfat = tt-rel634.qttotfat + 1
                   tt-rel634.vltotfat = tt-rel634.vltotfat + craplgp.vlrtotal
                   tt-rel634.vltrfuni = tt-rel634.vltrfuni + aux_vltargps
                   tt-rel634.vlrecliq = tt-rel634.vlrecliq + (aux_vltargps - b2crapthi.vltarifa)
                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq).
        END.

    END. /* Fim do FOR - CRAPLGP */

END.
ELSE DO:

    /* GUIA DA PREVIDENVIA SOCIAL - SICREDI - TODAS COOP'S */

    /* Tarifa a ser paga ao SICREDI */
    FOR EACH craplgp
       WHERE craplgp.cdcooper <> 3
                       AND craplgp.dtmvtolt = glb_dtmvtolt
                       AND craplgp.idsicred <> 0
         AND craplgp.flgativo = YES
                       BREAK BY craplgp.cdcooper
                             BY craplgp.cdagenci
                             BY craplgp.tpdpagto:

        IF  FIRST-OF(craplgp.cdcooper) THEN DO:
            FIND FIRST  crapthi WHERE crapthi.cdcooper = craplgp.cdcooper
                                  AND crapthi.cdhistor = 1414
                                  AND crapthi.dsorigem = "AYLLOS"
                                  NO-LOCK NO-ERROR.

            /* Localizar a tarifa da base */
            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                                 AND craptab.nmsistem = "CRED"
                                 AND craptab.tptabela = "GENERI"
                                 AND craptab.cdempres = 00
                                 AND craptab.cdacesso = "GPSCXASCOD"
                                 AND craptab.tpregist = 0
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_vltfcxsb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Sem.Barra */
            ELSE
                ASSIGN aux_vltfcxsb = 0.
        
            /* Localizar a tarifa da base */
            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                                 AND craptab.nmsistem = "CRED"
                                 AND craptab.tptabela = "GENERI"
                                 AND craptab.cdempres = 00
                                 AND craptab.cdacesso = "GPSCXACCOD"
                                 AND craptab.tpregist = 0
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_vltfcxcb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Com.Barra */
            ELSE
                ASSIGN aux_vltfcxcb = 0.
        
            /* Localizar a tarifa da base */
            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                                 AND craptab.nmsistem = "CRED"
                                 AND craptab.tptabela = "GENERI"
                                 AND craptab.cdempres = 00
                                 AND craptab.cdacesso = "GPSINTBANK"
                                 AND craptab.tpregist = 0
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_vlrtrfib = DECI(craptab.dstextab).  /*  Valor Tarifa IB  */
            ELSE
                ASSIGN aux_vlrtrfib = 0.

        END.

        /* Inicializa Variaveis */
        ASSIGN aux_dsempgps = ""
               aux_dsnomcnv = ""
               aux_tpmeiarr = ""
               aux_dsmeiarr = ""
               aux_vltargps = 0.

        IF  craplgp.cdagenci <> 90 THEN /* CAIXA*/
            ASSIGN aux_tpmeiarr = "C"
                   aux_dsmeiarr = "CAIXA"
                   aux_vltargps = IF craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
                                     aux_vltfcxcb
                                  ELSE /* Sem Cod.Barras*/
                                     aux_vltfcxsb.
        ELSE /* INTERNET */
            ASSIGN aux_tpmeiarr = "D"
                   aux_dsmeiarr = "INTERNET"
                   aux_vltargps = aux_vlrtrfib.


        IF  craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
            ASSIGN aux_dsempgps = "GP1"
                   aux_dsnomcnv = "GPS - COM COD.BARRAS".
        ELSE /* Sem Cod.Barras*/
            ASSIGN aux_dsempgps = "GP2"
                   aux_dsnomcnv = "GPS - SEM COD.BARRAS".


        FIND FIRST tt-rel634 WHERE tt-rel634.cdempres = aux_dsempgps
                               AND tt-rel634.tpmeiarr = aux_tpmeiarr
                               EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL tt-rel634  THEN DO:
            CREATE tt-rel634.
            ASSIGN tt-rel634.nmconven = aux_dsnomcnv
                   tt-rel634.cdempres = aux_dsempgps
                   tt-rel634.tpmeiarr = aux_tpmeiarr
                   tt-rel634.qttotfat = 1
                   tt-rel634.vltotfat = craplgp.vlrtotal
                   tt-rel634.vltrfuni = aux_vltargps
                   tt-rel634.vlrecliq = tt-rel634.vltrfuni - b2crapthi.vltarifa
                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq)
                   tt-rel634.dsdianor = ""
                   tt-rel634.nrrenorm = 0
                   tt-rel634.dsmeiarr = aux_dsmeiarr.
        END.
        ELSE DO:    /* Incrementa os valores anteriores */
            ASSIGN tt-rel634.qttotfat = tt-rel634.qttotfat + 1
                   tt-rel634.vltotfat = tt-rel634.vltotfat + craplgp.vlrtotal
                   tt-rel634.vltrfuni = tt-rel634.vltrfuni + aux_vltargps
                   tt-rel634.vlrecliq = tt-rel634.vlrecliq + (aux_vltargps - b2crapthi.vltarifa)
                   tt-rel634.vltrfsic = IF tt-rel634.vlrecliq < 0 THEN  tt-rel634.vltrfuni ELSE (tt-rel634.vltrfuni - tt-rel634.vlrecliq).
        END.
    END. /* Fim do FOR - CRAPLGP */

END. /* Fim do IF glb_cdcooper <> 3 */


/* zerar variaveis dos totais */
ASSIGN /* internet */
       int_qttotfat = 0
       int_vltotfat = 0
       int_vlrecliq = 0
       int_vltrfuni = 0
        /* caixa */
       cax_qttotfat = 0
       cax_vltotfat = 0
       cax_vlrecliq = 0
       cax_vltrfuni = 0
       /* taa */
       taa_qttotfat = 0
       taa_vltotfat = 0
       taa_vlrecliq = 0
       taa_vltrfuni = 0
       /* deb automatico */
       deb_qttotfat = 0
       deb_vltotfat = 0
       deb_vlrecliq = 0
       deb_vltrfuni = 0.

FOR EACH tt-rel634 NO-LOCK BREAK BY tt-rel634.nmconven:

    IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_cabrel132_1.
        END.

    IF  tt-rel634.tpmeiarr = "D" THEN
        DO:
             /* TOTAIS INTERNET */
            ASSIGN int_vltrfuni = int_vltrfuni + tt-rel634.vltrfuni
                   int_vltotfat = int_vltotfat + tt-rel634.vltotfat
                   int_qttotfat = int_qttotfat + tt-rel634.qttotfat
                   int_vlrecliq = int_vlrecliq + tt-rel634.vlrecliq.
        END.

    IF  tt-rel634.tpmeiarr = "C" THEN
        DO:
             /* TOTAIS CAIXA */
            ASSIGN cax_vltrfuni = cax_vltrfuni + tt-rel634.vltrfuni
                   cax_vltotfat = cax_vltotfat + tt-rel634.vltotfat
                   cax_qttotfat = cax_qttotfat + tt-rel634.qttotfat
                   cax_vlrecliq = cax_vlrecliq + tt-rel634.vlrecliq.
        END.

    IF  tt-rel634.tpmeiarr = "A" THEN
        DO:
             /* TOTAIS TAA */
            ASSIGN taa_vltrfuni = taa_vltrfuni + tt-rel634.vltrfuni
                   taa_vltotfat = taa_vltotfat + tt-rel634.vltotfat
                   taa_qttotfat = taa_qttotfat + tt-rel634.qttotfat
                   taa_vlrecliq = taa_vlrecliq + tt-rel634.vlrecliq.
        END.

    IF  tt-rel634.tpmeiarr = "E" THEN
        DO:
             /* TOTAIS DEB AUTOMATICO */
            ASSIGN deb_vltrfuni = deb_vltrfuni + tt-rel634.vltrfuni
                   deb_vltotfat = deb_vltotfat + tt-rel634.vltotfat
                   deb_qttotfat = deb_qttotfat + tt-rel634.qttotfat
                   deb_vlrecliq = deb_vlrecliq + tt-rel634.vlrecliq.
        END.


    /* TOTAI GERAL */
    ASSIGN tot_vltrfuni = tot_vltrfuni + tt-rel634.vltrfuni
           tot_vltotfat = tot_vltotfat + tt-rel634.vltotfat
           tot_qttotfat = tot_qttotfat + tt-rel634.qttotfat
           tot_vlrecliq = tot_vlrecliq + tt-rel634.vlrecliq.

    /* Corrige valores negativos */
    IF  tt-rel634.vltotfat < 0 THEN
        ASSIGN tt-rel634.vltotfat = 0.

    IF  tt-rel634.vlrecliq < 0 THEN
        ASSIGN tt-rel634.vlrecliq = 0.

    IF  tt-rel634.vltrfuni < 0 THEN
        ASSIGN tt-rel634.vltrfuni = 0.

    DISPLAY STREAM str_1 tt-rel634.nmconven
                         tt-rel634.dsmeiarr
                         tt-rel634.qttotfat
                         tt-rel634.vltotfat
                         tt-rel634.vlrecliq
                         tt-rel634.vltrfuni
                         tt-rel634.nrrenorm
                         tt-rel634.dsdianor
                         WITH FRAME f_rel634.

    DOWN STREAM str_1 WITH FRAME f_rel634.
END.

/* Exibe Totais por Coluna */
DISPLAY STREAM str_1
                     /*internet*/
                     int_qttotfat
                     int_vltotfat
                     int_vlrecliq
                     int_vltrfuni
                      /* caixa */
                     cax_qttotfat
                     cax_vltotfat
                     cax_vlrecliq
                     cax_vltrfuni
                     /* taa */
                     taa_qttotfat
                     taa_vltotfat
                     taa_vlrecliq
                     taa_vltrfuni
                     /*Deb Auto*/
                     deb_qttotfat
                     deb_vltotfat
                     deb_vlrecliq
                     deb_vltrfuni
                    /*total geral*/
                     tot_vltrfuni
                     tot_vltotfat
                     tot_vlrecliq
                     tot_qttotfat
                     WITH FRAME f_totais_rel634.

OUTPUT STREAM str_1 CLOSE.

IF  NOT TEMP-TABLE tt-rel634:HAS-RECORDS THEN
    UNIX SILENT VALUE ("rm " + aux_nmarqrel + "* 2>/dev/null").
ELSE
    RUN fontes/imprim.p.

/* Realiza verificação para gerar relatórios mensais  */
IF  MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
    DO:
        /* Gera relatorios mensais para as Coop. */
        RUN executa-rel-mensais.

        /* Gera arquivo conciliacao Convenios "AAMMDD_CONVEN_SIC.txt" */
        RUN gera_conciliacao_conven.

        /* Salva cod da Coop. */
        aux_cdcooper = crapcop.cdcooper.

        /* Gera o rel636 apenas na cecred */
        IF  glb_cdcooper = 3 THEN
            RUN gera-rel-mensal-cecred.
    END.

RUN fontes/fimprg.p.

PROCEDURE executa-rel-mensais:

    /* Pega primeiro e último dia do mês */
    ASSIGN aux_dtmvtolt = glb_dtmvtolt.
    
    IF (MONTH(aux_dtmvtolt) + 1 = 13) THEN
        ASSIGN aux_datafina = DATE(1,21,YEAR(aux_dtmvtolt)+ 1).
    ELSE
        ASSIGN aux_datafina = DATE(MONTH(aux_dtmvtolt) + 1,21,YEAR(aux_dtmvtolt)).

    ASSIGN aux_datafina = aux_datafina - 21
           aux_datainic = DATE(MONTH(aux_datafina),01,YEAR(aux_datafina)).

    /* Gera relatório mensal crrl635 */
    ASSIGN glb_cdrelato[2] = 635
           glb_cdempres    = 11
           glb_nrcopias    = 1
           glb_nmformul    = "234dh".

    { includes/cabrel234_2.i }

    ASSIGN tot_qttotfat    = 0
           tot_vltotfat    = 0
           tot_vlrecliq    = 0
           tot_vltrfuni    = 0
           tot_vlrliqpf    = 0
           tot_vlrliqpj    = 0
           tot_vlrtrfpf    = 0
           tot_vlrtrfpj    = 0
           tot_trfgpspf    = 0
           tot_trfgpspj    = 0
           ger_vltrpapf    = 0
           ger_vltrpapj    = 0
           aux_qttotfat    = 0
           aux_vltotfat    = 0
           aux_vltottar    = 0
           glb_cdcritic    = 0
           aux_dscooper    = "/usr/coop/" + crapcop.dsdircop + "/"
           aux_nmarqrel    = aux_dscooper + "rl/crrl635.lst"
           glb_nmarqimp    = aux_nmarqrel.

    OUTPUT STREAM str_2 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_2 FRAME f_cabrel234_2.

    /* Percorre todos os dias */
    DO aux_dtvencto = aux_datainic TO aux_datafina:

        /* Leitura para Convenios e DARFs */
        FOR EACH craplft FIELDS(cdtribut cdempcon cdsegmto tpfatura
                                vllanmto vlrmulta vlrjuros cdagenci
                                nrdconta)
                         WHERE craplft.cdcooper  = crapcop.cdcooper AND
                               craplft.dtvencto  = aux_dtvencto     AND
                               craplft.insitfat  = 2                AND
                               craplft.cdhistor  = 1154   /* SICREDI */
                               NO-LOCK BREAK BY craplft.cdtribut
                                             BY craplft.cdempcon
                                             BY craplft.cdsegmto
                                             BY craplft.cdagenci.

            IF  FIRST-OF (craplft.cdtribut) OR
                FIRST-OF (craplft.cdempcon) OR
                FIRST-OF (craplft.cdsegmto) THEN
                ASSIGN tot_qtfatint = 0
                       tot_vlfatint = 0
                       tot_qtfattaa = 0
                       tot_vlfattaa = 0
                       tot_qtfatcxa = 0
                       tot_vlfatcxa = 0.

            /** Divisao PF/PJ - Verificar Tipo Pessoa */
            FIND FIRST crapass
                 WHERE crapass.cdcooper = craplft.cdcooper
                   AND crapass.nrdconta = craplft.nrdconta
               NO-LOCK NO-ERROR.
            IF  AVAIL crapass THEN
                IF  crapass.inpessoa = 1 THEN
                    ASSIGN aux_inpessoa = crapass.inpessoa.
                ELSE
                    ASSIGN aux_inpessoa = 2.
            ELSE
                aux_inpessoa = 1. /* Se por acaso nao encontrar ASS ... */

            IF  craplft.tpfatura <> 2  OR
                craplft.cdempcon <> 0  THEN
                DO:
                    IF  FIRST-OF (craplft.cdempcon) OR
                        FIRST-OF (craplft.cdsegmto) THEN
                        DO:
                            /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
                            FIND FIRST crapscn WHERE crapscn.cdempcon = craplft.cdempcon AND
                                                     crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
                                                     crapscn.dtencemp = ?                        AND
                                                     crapscn.dsoparre <> "E"   /* Debaut */
                                                     NO-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAIL crapscn THEN
                                DO:
                                    FIND FIRST crapscn WHERE crapscn.cdempco2 = craplft.cdempcon AND
                                                             crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
                                                             crapscn.dtencemp = ?                        AND
                                                             crapscn.dsoparre <> "E"   /* Debaut */
                                                             NO-LOCK NO-ERROR NO-WAIT.
                                    IF  NOT AVAIL crapscn THEN
                                        NEXT.
                                END.
                        END.
                END.
            ELSE
                DO:
                    IF  FIRST-OF (craplft.cdtribut) THEN
                        DO:
                            IF  craplft.cdtribut = "6106" THEN /* DARF SIMPLES */
                                DO:
                                    FIND FIRST crapscn WHERE crapscn.cdempres = "D0"
                                               NO-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAIL crapscn THEN
                                        NEXT.
                                END.
                            ELSE
                                DO: /* DARF PRETO EUROPA */
                                    FIND FIRST crapscn WHERE crapscn.cdempres = "A0"
                                               NO-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAIL crapscn THEN
                                        NEXT.
                                END.
                        END.
                END.

            /* Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16 */
            IF  craplft.tpfatura >= 1 THEN
                ASSIGN aux_vltarfat = crapcop.vltardrf. /* 0.16 era o valor antigo */
            ELSE
                ASSIGN aux_vltarfat = crapthi.vltarifa.


            IF  craplft.cdagenci = 90 THEN  /** Internet **/
                ASSIGN  tot_qtfatint = tot_qtfatint + 1
                        tot_vlfatint = tot_vlfatint + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).
            ELSE
            IF  craplft.cdagenci = 91 THEN  /** TAA **/
                ASSIGN  tot_qtfattaa = tot_qtfattaa + 1
                        tot_vlfattaa = tot_vlfattaa + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

            ELSE                            /** Caixa **/
                ASSIGN  tot_qtfatcxa = tot_qtfatcxa + 1
                        tot_vlfatcxa = tot_vlfatcxa + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

            IF  LAST-OF (craplft.cdempcon) OR
                LAST-OF (craplft.cdsegmto) THEN
                DO:
                    /* INTERNET */
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                             crapstn.tpmeiarr = "D"
                                             NO-LOCK NO-ERROR.

                    IF  tot_qtfatint > 0 AND
                        AVAIL crapstn    AND
                        AVAIL crapthi    THEN
                        DO:
                            FIND tt-rel635 WHERE tt-rel635.cdempres = crapscn.cdempres AND
                                                 tt-rel635.tpmeiarr = crapstn.tpmeiarr EXCLUSIVE-LOCK NO-ERROR.

                            IF  NOT AVAIL tt-rel635 THEN
                                DO:
                                    CREATE tt-rel635.
                                    ASSIGN tt-rel635.nmconven = crapscn.dsnomcnv
                                           tt-rel635.dsmeiarr = "INTERNET"
                                           tt-rel635.cdempres = crapscn.cdempres
                                           tt-rel635.tpmeiarr = crapstn.tpmeiarr
                                           tt-rel635.qtfatura = tot_qtfatint
                                           tt-rel635.vltotfat = tot_vlfatint
                                           tt-rel635.vltottar = (crapstn.vltrfuni * tot_qtfatint)
                                           tt-rel635.vlrecliq = tt-rel635.vltottar - (tot_qtfatint * aux_vltarfat)
                                           tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq)
                                           tt-rel635.dsdianor = crapscn.dsdianor
                                           tt-rel635.nrrenorm = crapscn.nrrenorm
                                           tt-rel635.inpessoa = aux_inpessoa.

                                    /* Divisao PF/PJ */
                                    IF  aux_inpessoa = 1 THEN
                                        ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vltottar
                                               tt-rel635.vlrliqpf = tt-rel635.vlrecliq.
                                    ELSE
                                        ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vltottar
                                               tt-rel635.vlrliqpj = tt-rel635.vlrecliq.
                                END.
                            ELSE DO: /* Incrementa os valores de dias anteriores */
                            
                                ASSIGN tt-rel635.qtfatura = tt-rel635.qtfatura + tot_qtfatint
                                       tt-rel635.vltotfat = tt-rel635.vltotfat + tot_vlfatint
                                       tt-rel635.vltottar = (crapstn.vltrfuni * tt-rel635.qtfatura)
                                       /* Recalcula e sobrescreve valores derivados de tarifas */
                                       tt-rel635.vlrecliq = tt-rel635.vltottar - (tt-rel635.qtfatura * aux_vltarfat)
                                       tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq).

                                /* Divisao PF/PJ */
                                IF  aux_inpessoa = 1 THEN
                                    ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vlrtrfpf + (crapstn.vltrfuni * tot_qtfatint)
                                           tt-rel635.vlrliqpf = tt-rel635.vlrliqpf + ((crapstn.vltrfuni * tot_qtfatint) - (tot_qtfatint * aux_vltarfat)).
                                ELSE
                                    ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vlrtrfpj + (crapstn.vltrfuni * tot_qtfatint)
                                           tt-rel635.vlrliqpj = tt-rel635.vlrliqpj + ((crapstn.vltrfuni * tot_qtfatint) - (tot_qtfatint * aux_vltarfat)).
                            END.

                            IF  aux_inpessoa = 1 THEN
                                ASSIGN ger_vltrpapf[craplft.cdagenci] = 
                                                ger_vltrpapf[craplft.cdagenci] + 
                                                (crapstn.vltrfuni * tot_qtfatint).
                            ELSE
                                ASSIGN ger_vltrpapj[craplft.cdagenci] = 
                                                ger_vltrpapj[craplft.cdagenci] + 
                                                (crapstn.vltrfuni * tot_qtfatint).
                    END.

                    /* TAA */
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                             crapstn.tpmeiarr = "A"
                                             NO-LOCK NO-ERROR.

                    IF  tot_qtfattaa > 0 AND
                        AVAIL crapstn    AND
                        AVAIL crapthi    THEN
                        DO:
                            FIND tt-rel635 WHERE tt-rel635.cdempres = crapscn.cdempres AND
                                                 tt-rel635.tpmeiarr = crapstn.tpmeiarr
                                                 EXCLUSIVE-LOCK NO-ERROR.

                            IF  NOT AVAIL tt-rel635 THEN
                                DO:
                                    CREATE tt-rel635.
                                    ASSIGN tt-rel635.nmconven = crapscn.dsnomcnv
                                           tt-rel635.dsmeiarr = "TAA"
                                           tt-rel635.cdempres = crapscn.cdempres
                                           tt-rel635.tpmeiarr = crapstn.tpmeiarr
                                           tt-rel635.qtfatura = tot_qtfattaa
                                           tt-rel635.vltotfat = tot_vlfattaa
                                           tt-rel635.vltottar = (crapstn.vltrfuni * tot_qtfattaa)
                                           tt-rel635.vlrecliq = tt-rel635.vltottar - (tot_qtfattaa * crapthi.vltarifa)
                                           tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq)
                                           tt-rel635.dsdianor = crapscn.dsdianor
                                           tt-rel635.nrrenorm = crapscn.nrrenorm
                                           tt-rel635.inpessoa = aux_inpessoa.

                                    /* Divisao PF/PJ */
                                    IF  aux_inpessoa = 1 THEN
                                        ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vltottar
                                               tt-rel635.vlrliqpf = tt-rel635.vlrecliq.
                                    ELSE
                                        ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vltottar
                                               tt-rel635.vlrliqpj = tt-rel635.vlrecliq.
                                END.
                            ELSE DO: /* Incrementa os valores de dias anteriores */
                                ASSIGN tt-rel635.qtfatura = tt-rel635.qtfatura + tot_qtfattaa
                                       tt-rel635.vltotfat = tt-rel635.vltotfat + tot_vlfattaa
                                       tt-rel635.vltottar = (crapstn.vltrfuni * tt-rel635.qtfatura)
                                       /* Recalcula e sobrescreve valores derivados de tarifas */
                                       tt-rel635.vlrecliq = tt-rel635.vltottar - (tt-rel635.qtfatura * crapthi.vltarifa)
                                       tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq).                                       

                                /* Divisao PF/PJ */
                                IF  aux_inpessoa = 1 THEN
                                    ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vlrtrfpf + (crapstn.vltrfuni * tot_qtfattaa)
                                           tt-rel635.vlrliqpf = tt-rel635.vlrliqpf + ((crapstn.vltrfuni * tot_qtfattaa) - (tot_qtfattaa * crapthi.vltarifa)).
                                ELSE
                                    ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vlrtrfpj + (crapstn.vltrfuni * tot_qtfattaa)
                                           tt-rel635.vlrliqpj = tt-rel635.vlrliqpj + ((crapstn.vltrfuni * tot_qtfattaa) - (tot_qtfattaa * crapthi.vltarifa)).
                            END.

                            IF  aux_inpessoa = 1 THEN
                                ASSIGN ger_vltrpapf[craplft.cdagenci] = 
                                                ger_vltrpapf[craplft.cdagenci] + 
                                                (crapstn.vltrfuni * tot_qtfattaa).
                            ELSE
                                ASSIGN ger_vltrpapj[craplft.cdagenci] = 
                                                ger_vltrpapj[craplft.cdagenci] + 
                                                (crapstn.vltrfuni * tot_qtfattaa).
                    END.

                    /* CAIXA */
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                             crapstn.tpmeiarr = "C"
                                             NO-LOCK NO-ERROR.

                    IF  tot_qtfatcxa > 0 AND
                        AVAIL crapstn    AND
                        AVAIL crapthi    THEN
                        DO:
                            FIND tt-rel635 WHERE tt-rel635.cdempres = crapscn.cdempres AND
                                                 tt-rel635.tpmeiarr = crapstn.tpmeiarr
                                                 EXCLUSIVE-LOCK NO-ERROR.

                            IF  NOT AVAIL tt-rel635 THEN
                                DO:
                                    CREATE tt-rel635.
                                    ASSIGN tt-rel635.nmconven = crapscn.dsnomcnv
                                           tt-rel635.dsmeiarr = "CAIXA"
                                           tt-rel635.cdempres = crapscn.cdempres
                                           tt-rel635.tpmeiarr = crapstn.tpmeiarr
                                           tt-rel635.qtfatura = tot_qtfatcxa
                                           tt-rel635.vltotfat = tot_vlfatcxa
                                           tt-rel635.vltottar = (crapstn.vltrfuni * tot_qtfatcxa)
                                           tt-rel635.vlrecliq = tt-rel635.vltottar - (tot_qtfatcxa * aux_vltarfat)
                                           tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq)
                                           tt-rel635.dsdianor = crapscn.dsdianor
                                           tt-rel635.nrrenorm = crapscn.nrrenorm
                                           tt-rel635.inpessoa = aux_inpessoa.

                                    /* Divisao PF/PJ */
                                    IF  aux_inpessoa = 1 THEN
                                        ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vltottar
                                               tt-rel635.vlrliqpf = tt-rel635.vlrecliq.
                                    ELSE
                                        ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vltottar
                                               tt-rel635.vlrliqpj = tt-rel635.vlrecliq.
                                END.
                            ELSE DO: /* Incrementa os valores de dias anteriores */
                                ASSIGN tt-rel635.qtfatura = tt-rel635.qtfatura + tot_qtfatcxa
                                       tt-rel635.vltotfat = tt-rel635.vltotfat + tot_vlfatcxa
                                       tt-rel635.vltottar = (crapstn.vltrfuni * tt-rel635.qtfatura)
                                       /* Recalcula e sobrescreve valores derivados de tarifas */
                                       tt-rel635.vlrecliq = tt-rel635.vltottar - (tt-rel635.qtfatura * aux_vltarfat)
                                       tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq).   

                                /* Divisao PF/PJ */
                                IF  aux_inpessoa = 1 THEN
                                    ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vlrtrfpf + (crapstn.vltrfuni * tot_qtfatcxa)
                                           tt-rel635.vlrliqpf = tt-rel635.vlrliqpf + ((crapstn.vltrfuni * tot_qtfatcxa) - (tot_qtfatcxa * aux_vltarfat)).
                                ELSE
                                    ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vlrtrfpj + (crapstn.vltrfuni * tot_qtfatcxa)
                                           tt-rel635.vlrliqpj = tt-rel635.vlrliqpj + ((crapstn.vltrfuni * tot_qtfatcxa) - (tot_qtfatcxa * aux_vltarfat)).
                            END.

                            IF  aux_inpessoa = 1 THEN
                                ASSIGN ger_vltrpapf[craplft.cdagenci] = 
                                                ger_vltrpapf[craplft.cdagenci] + 
                                                (crapstn.vltrfuni * tot_qtfatcxa).
                            ELSE
                                ASSIGN ger_vltrpapj[craplft.cdagenci] = 
                                                ger_vltrpapj[craplft.cdagenci] + 
                                                (crapstn.vltrfuni * tot_qtfatcxa).
                    END.
            END.

        END. /* FOR EACH craplft */

        /* Para debito aumatico SICREDI */
        FOR EACH craplcm FIELD(cdcooper cdhistor nrdocmto nrdconta cdagenci
                               dtmvtolt nrdolote vllanmto )
                         WHERE craplcm.cdcooper = glb_cdcooper AND
                               craplcm.cdhistor = 1019         AND
                               craplcm.dtmvtolt = aux_dtvencto
                               NO-LOCK:

            FIND craplau WHERE craplau.cdcooper = craplcm.cdcooper AND
                               craplau.cdhistor = craplcm.cdhistor AND
                               craplau.nrdocmto = craplcm.nrdocmto AND
                               craplau.nrdconta = craplcm.nrdconta AND
                               craplau.cdagenci = craplcm.cdagenci AND
                               craplau.dtmvtopg = craplcm.dtmvtolt
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL craplau THEN
                NEXT.

             ASSIGN tot_qtfatdeb = 0
                    tot_vlfatdeb = 0.

            /* somatoria por empresa */
            FOR EACH crapscn WHERE crapscn.cdempres = craplau.cdempres
                                   NO-LOCK:

                ASSIGN tot_qtfatdeb = tot_qtfatdeb + 1
                       tot_vlfatdeb = tot_vlfatdeb + craplcm.vllanmto.

            END.

            /* Se nao for debito automatico não faz */
            FIND FIRST crapscn WHERE crapscn.dsoparre = "E"                AND
                                    (crapscn.cddmoden = "A"                OR
                                     crapscn.cddmoden = "C")               AND
                                     crapscn.cdempres = craplau.cdempres
                                     NO-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapscn THEN
                NEXT.

            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "E"
                                     NO-LOCK NO-ERROR.

            IF  AVAIL crapstn THEN DO:

                /** Divisao PF/PJ - Verificar Tipo Pessoa */
                FIND FIRST crapass
                     WHERE crapass.cdcooper = craplcm.cdcooper
                       AND crapass.nrdconta = craplcm.nrdconta
                   NO-LOCK NO-ERROR.
                IF  AVAIL crapass THEN
                    IF  crapass.inpessoa = 1 THEN
                        ASSIGN aux_inpessoa = crapass.inpessoa.
                    ELSE
                        ASSIGN aux_inpessoa = 2.
                ELSE
                    aux_inpessoa = 1. /* Se por acaso nao encontrar ASS ... */


                FIND tt-rel635 WHERE tt-rel635.cdempres = crapscn.cdempres AND
                                     tt-rel635.tpmeiarr = crapstn.tpmeiarr
                                     EXCLUSIVE-LOCK NO-ERROR.

                IF  NOT AVAIL tt-rel635  THEN
                    DO:

                        CREATE tt-rel635.
                        ASSIGN tt-rel635.nmconven = crapscn.dsnomcnv
                               tt-rel635.dsmeiarr = "DEB. AUTOMATICO"
                               tt-rel635.cdempres = crapscn.cdempres
                               tt-rel635.tpmeiarr = "E"
                               tt-rel635.qtfatura = tot_qtfatdeb
                               tt-rel635.vltotfat = tot_vlfatdeb
                               tt-rel635.vltottar = (crapstn.vltrfuni * tot_qtfatdeb)
                               tt-rel635.vlrecliq = tt-rel635.vltottar - (tot_qtfatdeb * aux_vltarifa)
                               tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq)
                               tt-rel635.dsdianor = crapscn.dsdianor
                               tt-rel635.nrrenorm = crapscn.nrrenorm
                               tt-rel635.inpessoa = aux_inpessoa.

                        /* Divisao PF/PJ */
                        IF  aux_inpessoa = 1 THEN
                            ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vltottar
                                   tt-rel635.vlrliqpf = tt-rel635.vlrecliq.
                        ELSE
                            ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vltottar
                                   tt-rel635.vlrliqpj = tt-rel635.vlrecliq.

                    END.
                ELSE DO:   /* Incrementa os valores anteriores */
                    ASSIGN tt-rel635.qtfatura = tt-rel635.qtfatura + tot_qtfatdeb
                           tt-rel635.vltotfat = tt-rel635.vltotfat + tot_vlfatdeb
                           tt-rel635.vltottar = tt-rel635.vltottar + (crapstn.vltrfuni * tot_qtfatdeb)
                           tt-rel635.vlrecliq = tt-rel635.vlrecliq + ((crapstn.vltrfuni * tot_qtfatdeb) - (tot_qtfatdeb * aux_vltarifa))
                           tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq).

                    /* Divisao PF/PJ */
                    IF  aux_inpessoa = 1 THEN
                        ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vlrtrfpf + (crapstn.vltrfuni * tot_qtfatdeb)
                               tt-rel635.vlrliqpf = tt-rel635.vlrliqpf + ((crapstn.vltrfuni * tot_qtfatdeb) - (tot_qtfatdeb * aux_vltarifa)).
                    ELSE
                        ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vlrtrfpj + (crapstn.vltrfuni * tot_qtfatdeb)
                               tt-rel635.vlrliqpj = tt-rel635.vlrliqpj + ((crapstn.vltrfuni * tot_qtfatdeb) - (tot_qtfatdeb * aux_vltarifa)).
                END.

                IF  aux_inpessoa = 1 THEN
                    ASSIGN ger_vltrpapf[craplcm.cdagenci] = 
                                    ger_vltrpapf[craplcm.cdagenci] + 
                                    (crapstn.vltrfuni * tot_qtfatdeb).
                ELSE
                    ASSIGN ger_vltrpapj[craplcm.cdagenci] = 
                                    ger_vltrpapj[craplcm.cdagenci] + 
                                    (crapstn.vltrfuni * tot_qtfatdeb).
            END.
        END.

        /* GUIA DA PREVIDENVIA SOCIAL - SICREDI */

        /* Tarifa a ser paga ao SICREDI */
        FIND FIRST crapthi WHERE crapthi.cdcooper = glb_cdcooper
                             AND crapthi.cdhistor = 1414
                             AND crapthi.dsorigem = "AYLLOS"
                             NO-LOCK NO-ERROR.
    
        /* Localizar a tarifa da base */
        FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                             AND craptab.nmsistem = "CRED"
                             AND craptab.tptabela = "GENERI"
                             AND craptab.cdempres = 00
                             AND craptab.cdacesso = "GPSCXASCOD"
                             AND craptab.tpregist = 0
                             NO-LOCK NO-ERROR.
    
        IF  AVAIL craptab THEN
            ASSIGN aux_vltfcxsb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Sem.Barra */
        ELSE
            ASSIGN aux_vltfcxsb = 0.
    
        /* Localizar a tarifa da base */
        FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                             AND craptab.nmsistem = "CRED"
                             AND craptab.tptabela = "GENERI"
                             AND craptab.cdempres = 00
                             AND craptab.cdacesso = "GPSCXACCOD"
                             AND craptab.tpregist = 0
                             NO-LOCK NO-ERROR.
    
        IF  AVAIL craptab THEN
            ASSIGN aux_vltfcxcb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Com.Barra */
        ELSE
            ASSIGN aux_vltfcxcb = 0.
    
        /* Localizar a tarifa da base */
        FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                             AND craptab.nmsistem = "CRED"
                             AND craptab.tptabela = "GENERI"
                             AND craptab.cdempres = 00
                             AND craptab.cdacesso = "GPSINTBANK"
                             AND craptab.tpregist = 0
                             NO-LOCK NO-ERROR.
    
        IF  AVAIL craptab THEN
            ASSIGN aux_vlrtrfib = DECI(craptab.dstextab).  /*  Valor Tarifa IB  */
        ELSE
            ASSIGN aux_vlrtrfib = 0.
        
        /* Para todos os lancamentos ja pagos */
        FOR EACH craplgp
           WHERE craplgp.cdcooper = glb_cdcooper
                           AND craplgp.dtmvtolt = aux_dtvencto
                           AND craplgp.idsicred <> 0
             AND craplgp.flgativo = YES
                           BREAK BY craplgp.cdcooper
                                 BY craplgp.cdagenci
                                 BY craplgp.tpdpagto:
            
            /* Inicializa Variaveis */
            ASSIGN aux_dsempgps = ""
                   aux_dsnomcnv = ""
                   aux_tpmeiarr = ""
                   aux_dsmeiarr = ""
                   aux_vltargps = 0.
    
            IF  craplgp.cdagenci <> 90 THEN /* CAIXA*/
                ASSIGN aux_tpmeiarr = "C"
                       aux_dsmeiarr = "CAIXA"
                       aux_vltargps = IF craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
                                         aux_vltfcxcb
                                      ELSE /* Sem Cod.Barras*/
                                         aux_vltfcxsb.
            ELSE /* INTERNET */
                ASSIGN aux_tpmeiarr = "D"
                       aux_dsmeiarr = "INTERNET"
                       aux_vltargps = aux_vlrtrfib.
    
    
            IF  craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
                ASSIGN aux_dsempgps = "GP1"
                       aux_dsnomcnv = "GPS - COM COD.BARRAS".
            ELSE /* Sem Cod.Barras*/
                ASSIGN aux_dsempgps = "GP2"
                       aux_dsnomcnv = "GPS - SEM COD.BARRAS".
    
    
            FIND tt-rel635 WHERE tt-rel635.cdempres = aux_dsempgps
                             AND tt-rel635.tpmeiarr = aux_tpmeiarr
                             EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL tt-rel635  THEN DO:
                CREATE tt-rel635.
                ASSIGN tt-rel635.nmconven = aux_dsnomcnv
                       tt-rel635.dsmeiarr = aux_dsmeiarr
                       tt-rel635.cdempres = aux_dsempgps
                       tt-rel635.tpmeiarr = aux_tpmeiarr
                       tt-rel635.qtfatura = 1
                       tt-rel635.vltotfat = craplgp.vlrtotal
                       tt-rel635.vltottar = aux_vltargps
                       tt-rel635.vlrecliq = tt-rel635.vltottar - b2crapthi.vltarifa
                       tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq)
                       tt-rel635.dsdianor = ""
                       tt-rel635.nrrenorm = 0
                       tt-rel635.inpessoa = craplgp.inpesgps.

                /* Divisao PF/PJ */
                IF  craplgp.inpesgps = 1 THEN
                    ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vltottar
                           tt-rel635.vlrliqpf = tt-rel635.vlrecliq
                           tot_trfgpspf = tot_trfgpspf + aux_vltargps.
                ELSE
                    ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vltottar
                           tt-rel635.vlrliqpj = tt-rel635.vlrecliq
                           tot_trfgpspj = tot_trfgpspj + aux_vltargps.

            END.
            ELSE DO:   /* Incrementa os valores anteriores */

                ASSIGN tt-rel635.qtfatura = tt-rel635.qtfatura + 1
                       tt-rel635.vltotfat = tt-rel635.vltotfat + craplgp.vlrtotal
                       tt-rel635.vltottar = tt-rel635.vltottar + aux_vltargps
                       tt-rel635.vlrecliq = tt-rel635.vlrecliq + (aux_vltargps - b2crapthi.vltarifa)
                       tt-rel635.vltrfsic = IF tt-rel635.vlrecliq < 0 THEN  tt-rel635.vltottar ELSE (tt-rel635.vltottar - tt-rel635.vlrecliq).

                /* Divisao PF/PJ */
                IF  craplgp.inpesgps = 1 THEN
                    ASSIGN tt-rel635.vlrtrfpf = tt-rel635.vlrtrfpf + aux_vltargps
                           tt-rel635.vlrliqpf = tt-rel635.vlrliqpf + (aux_vltargps - crapthi.vltarifa)
                           tot_trfgpspf = tot_trfgpspf + aux_vltargps.
                ELSE   
                    ASSIGN tt-rel635.vlrtrfpj = tt-rel635.vlrtrfpj + aux_vltargps
                           tt-rel635.vlrliqpj = tt-rel635.vlrliqpj + (aux_vltargps - crapthi.vltarifa)
                           tot_trfgpspj = tot_trfgpspj + aux_vltargps.
            END.
    
        END. /* Fim do FOR - CRAPLGP */

    END. /* DO... TO */


    /* zerar variaveis dos totais */
    ASSIGN /* internet */
           int_qttotfat = 0
           int_vltotfat = 0
           int_vlrecliq = 0
           int_vltrfuni = 0
           int_vlrliqpf = 0
           int_vlrliqpj = 0
           int_vlrtrfpf = 0
           int_vlrtrfpj = 0
            /* caixa */
           cax_qttotfat = 0
           cax_vltotfat = 0
           cax_vlrecliq = 0
           cax_vltrfuni = 0
           cax_vlrliqpf = 0
           cax_vlrliqpj = 0
           cax_vlrtrfpf = 0
           cax_vlrtrfpj = 0
           /* taa */
           taa_qttotfat = 0
           taa_vltotfat = 0
           taa_vlrecliq = 0
           taa_vltrfuni = 0
           taa_vlrliqpf = 0
           taa_vlrliqpj = 0
           taa_vlrtrfpf = 0
           taa_vlrtrfpj = 0
           /* deb automatico */
           deb_qttotfat = 0
           deb_vltotfat = 0
           deb_vlrecliq = 0
           deb_vltrfuni = 0
           deb_vlrliqpf = 0
           deb_vlrliqpj = 0
           deb_vlrtrfpf = 0
           deb_vlrtrfpj = 0.


    FOR EACH tt-rel635 NO-LOCK BREAK BY tt-rel635.nmconven:

        IF  LINE-COUNTER(str_2) > PAGE-SIZE(str_2)  THEN
            DO:
                PAGE STREAM str_2.
                VIEW STREAM str_2 FRAME f_cabrel234_2.
            END.

        IF  tt-rel635.tpmeiarr = "D" THEN
            DO:
                 /* TOTAIS INTERNET */
                ASSIGN int_vltotfat = int_vltotfat + tt-rel635.vltotfat
                       int_qttotfat = int_qttotfat + tt-rel635.qtfatura
                       int_vltrfuni = int_vltrfuni + tt-rel635.vltottar
                       int_vlrecliq = int_vlrecliq + tt-rel635.vlrecliq.

                /* Divisao PF/PJ */
                ASSIGN int_vlrtrfpf = int_vlrtrfpf + tt-rel635.vlrtrfpf 
                       int_vlrliqpf = int_vlrliqpf + tt-rel635.vlrliqpf
                       int_vlrtrfpj = int_vlrtrfpj + tt-rel635.vlrtrfpj 
                       int_vlrliqpj = int_vlrliqpj + tt-rel635.vlrliqpj.

            END.

        IF  tt-rel635.tpmeiarr = "C" THEN
            DO:
                 /* TOTAIS CAIXA */
                ASSIGN cax_vltrfuni = cax_vltrfuni + tt-rel635.vltottar
                       cax_vltotfat = cax_vltotfat + tt-rel635.vltotfat
                       cax_qttotfat = cax_qttotfat + tt-rel635.qtfatura
                       cax_vlrecliq = cax_vlrecliq + tt-rel635.vlrecliq.

                /* Divisao PF/PJ */
                ASSIGN cax_vlrtrfpf = cax_vlrtrfpf + tt-rel635.vlrtrfpf 
                       cax_vlrliqpf = cax_vlrliqpf + tt-rel635.vlrliqpf
                       cax_vlrtrfpj = cax_vlrtrfpj + tt-rel635.vlrtrfpj 
                       cax_vlrliqpj = cax_vlrliqpj + tt-rel635.vlrliqpj.
            END.

        IF  tt-rel635.tpmeiarr = "A" THEN
            DO:
                 /* TOTAIS TAA */
                ASSIGN taa_vltrfuni = taa_vltrfuni + tt-rel635.vltottar
                       taa_vltotfat = taa_vltotfat + tt-rel635.vltotfat
                       taa_qttotfat = taa_qttotfat + tt-rel635.qtfatura
                       taa_vlrecliq = taa_vlrecliq + tt-rel635.vlrecliq.

                /* Divisao PF/PJ */
                ASSIGN taa_vlrtrfpf = taa_vlrtrfpf + tt-rel635.vlrtrfpf 
                       taa_vlrliqpf = taa_vlrliqpf + tt-rel635.vlrliqpf
                       taa_vlrtrfpj = taa_vlrtrfpj + tt-rel635.vlrtrfpj 
                       taa_vlrliqpj = taa_vlrliqpj + tt-rel635.vlrliqpj.
            END.

        IF  tt-rel635.tpmeiarr = "E" THEN DO:
             /* TOTAIS DEB AUTOMATICO */
            ASSIGN deb_vltrfuni = deb_vltrfuni + tt-rel635.vltottar
                   deb_vltotfat = deb_vltotfat + tt-rel635.vltotfat
                   deb_qttotfat = deb_qttotfat + tt-rel635.qtfatura
                   deb_vlrecliq = deb_vlrecliq + tt-rel635.vlrecliq.

            /* Divisao PF/PJ */
            ASSIGN deb_vlrtrfpf = deb_vlrtrfpf + tt-rel635.vlrtrfpf 
                   deb_vlrliqpf = deb_vlrliqpf + tt-rel635.vlrliqpf
                   deb_vlrtrfpj = deb_vlrtrfpj + tt-rel635.vlrtrfpj 
                   deb_vlrliqpj = deb_vlrliqpj + tt-rel635.vlrliqpj.
        END.

        /* TOTAL GERAL */
        ASSIGN tot_vltotfat = tot_vltotfat + tt-rel635.vltotfat
               tot_qttotfat = tot_qttotfat + tt-rel635.qtfatura
               tot_vltrfuni = tot_vltrfuni + tt-rel635.vltottar
               tot_vlrecliq = tot_vlrecliq + tt-rel635.vlrecliq.

        /* Divisao PF/PJ */
        ASSIGN tot_vlrtrfpf = tot_vlrtrfpf + tt-rel635.vlrtrfpf
               tot_vlrliqpf = tot_vlrliqpf + tt-rel635.vlrliqpf
               tot_vlrtrfpj = tot_vlrtrfpj + tt-rel635.vlrtrfpj
               tot_vlrliqpj = tot_vlrliqpj + tt-rel635.vlrliqpj.

        /* Corrige valores negativos */
        IF  tt-rel635.vltotfat < 0 THEN
            ASSIGN tt-rel635.vltotfat = 0.

        IF  tt-rel635.vlrecliq < 0 THEN
            ASSIGN tt-rel635.vlrecliq = 0.

        IF  tt-rel635.vltottar < 0 THEN
            ASSIGN tt-rel635.vltottar = 0.

        IF  tt-rel635.vlrtrfpf < 0 THEN
            ASSIGN tt-rel635.vlrtrfpf = 0.

        IF  tt-rel635.vlrliqpf < 0 THEN
            ASSIGN tt-rel635.vlrliqpf = 0.

        IF  tt-rel635.vlrtrfpj < 0 THEN
            ASSIGN tt-rel635.vlrtrfpj = 0.

        IF  tt-rel635.vlrliqpj < 0 THEN
            ASSIGN tt-rel635.vlrliqpj = 0.


        DISPLAY STREAM str_2 tt-rel635.nmconven
                             tt-rel635.dsmeiarr
                             tt-rel635.qtfatura
                             tt-rel635.vltotfat

                             tt-rel635.vlrecliq
                             tt-rel635.vltottar

                             tt-rel635.vlrtrfpf
                             tt-rel635.vlrliqpf
                             tt-rel635.vlrtrfpj
                             tt-rel635.vlrliqpj

                             tt-rel635.nrrenorm
                             tt-rel635.dsdianor
                             WITH FRAME f_rel635.

        DOWN STREAM str_2 WITH FRAME f_rel635.

    END.

    /* Exibe Totais por Coluna */
    DISPLAY STREAM str_2 /*internet*/
                         int_qttotfat
                         int_vltotfat
                         int_vlrecliq
                         int_vltrfuni
                         int_vlrtrfpf
                         int_vlrtrfpj
                         int_vlrliqpf
                         int_vlrliqpj
                          /* caixa */
                         cax_qttotfat
                         cax_vltotfat
                         cax_vlrecliq
                         cax_vltrfuni
                         cax_vlrtrfpf
                         cax_vlrtrfpj
                         cax_vlrliqpf
                         cax_vlrliqpj
                         /* taa */
                         taa_qttotfat
                         taa_vltotfat
                         taa_vlrecliq
                         taa_vltrfuni
                         taa_vlrtrfpf
                         taa_vlrtrfpj
                         taa_vlrliqpf
                         taa_vlrliqpj
                         /*Deb Auto*/
                         deb_qttotfat
                         deb_vltotfat
                         deb_vlrecliq
                         deb_vltrfuni
                         deb_vlrtrfpf
                         deb_vlrtrfpj
                         deb_vlrliqpf
                         deb_vlrliqpj

                        /*total geral*/
                         tot_vltrfuni
                         tot_vltotfat
                         tot_vlrecliq
                         tot_qttotfat

                         tot_vlrtrfpf
                         tot_vlrtrfpj
                         tot_vlrliqpf
                         tot_vlrliqpj
              WITH FRAME f_totais_rel635.

    OUTPUT STREAM str_2 CLOSE.


    IF  NOT TEMP-TABLE tt-rel635:HAS-RECORDS THEN
        UNIX SILENT VALUE ("rm " + aux_nmarqrel + "* 2>/dev/null").
    ELSE
        RUN fontes/imprim.p.

END PROCEDURE.

/*****************************************************************/

PROCEDURE gera_conciliacao_conven:


    DEF VAR aux_dtmvtolt        AS DATE                                    NO-UNDO.
    DEF VAR aux_dtmvtopr        AS DATE                                    NO-UNDO.
    DEF VAR con_dtmvtolt        AS CHAR                                    NO-UNDO.
    DEF VAR con_dtmvtopr        AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdccuage        AS INTE EXTENT 999                         NO-UNDO.
    DEF VAR aux_nrmaxpas        AS INTE                                    NO-UNDO.
    DEF VAR aux_linhadet        AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtmovime        AS DATE                                    NO-UNDO.
    DEF VAR con_dtmovime        AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador        AS INTE FORMAT "z9"                        NO-UNDO.

    DEF VAR aux_nmarqdat        AS CHAR                                    NO-UNDO.


/* MODELO
    70141128,281114,7255,7367,692.36,1434,"TARIFAS CONVENIO SICREDI  - COOPERADOS PESSOA FISICA"
    001,482.44
    002,64.19
    090,120.27
    091,25.46
    70141201,011214,7367,7255,692.36,1434,"TARIFAS CONVENIO SICREDI  - COOPERADOS PESSOA FISICA"
    001,482.44
    002,64.19
    090,120.27
    091,25.46
    70141128,281114,7255,7368,863.26,1434,"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
    001,441.43
    002,80.77
    090,320.95
    091,20.11
    70141201,011214,7368,7255,863.26,1434,"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
    001,441.43
    002,80.77
    090,320.95
    091,20.11
*/



    FOR LAST crapage FIELDS (cdagenci)
       WHERE crapage.cdcooper = glb_cdcooper
     NO-LOCK
          BY crapage.cdagenci:
    
        ASSIGN aux_nrmaxpas = crapage.cdagenci.
    END.


    ASSIGN aux_dtmvtopr = glb_dtmvtolt.
    
    DO WHILE TRUE:          /*  Procura pela proxima data de movimento */
    
       aux_dtmvtopr = aux_dtmvtopr + 1.
    
       IF   LOOKUP(STRING(WEEKDAY(aux_dtmvtopr)),"1,7") <> 0   THEN
            NEXT.
    
       IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                   crapfer.dtferiad = aux_dtmvtopr)  THEN
            NEXT.
    
       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */
    
    
    ASSIGN aux_dtmvtolt = glb_dtmvtolt + 1.
    
    DO WHILE TRUE:          /*  Procura pela proxima data de movimento */
    
       ASSIGN aux_dtmvtolt = aux_dtmvtolt - 1.
    
       IF   LOOKUP(STRING(WEEKDAY(aux_dtmvtolt)),"1,7") <> 0   THEN
            NEXT.
    
       IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                   crapfer.dtferiad = aux_dtmvtolt)  THEN
            NEXT.
    
       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */
    
    ASSIGN con_dtmvtolt = "70" +
                          SUBSTR(STRING(YEAR(aux_dtmvtolt),"9999"),3,2) +
                          STRING(MONTH(aux_dtmvtolt),"99")   +
                          STRING(DAY  (aux_dtmvtolt),"99").
    
    ASSIGN  con_dtmvtopr = "70" +
                          SUBSTR(STRING(YEAR(aux_dtmvtopr),"9999"),3,2) +
                          STRING(MONTH(aux_dtmvtopr),"99")   +
                          STRING(DAY  (aux_dtmvtopr),"99")
           aux_nmarqdat = "contab/" + SUBSTR(con_dtmvtolt,3,6) + "_CONVEN_SIC.txt".
    
    
    FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper
                           NO-LOCK:
        aux_cdccuage[crapage.cdagenci] = crapage.cdccuage.
    
    END.


    OUTPUT STREAM str_2 TO VALUE(aux_nmarqdat).

    
    FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapdat   THEN
       DO:
           glb_cdcritic = 1.
           RUN fontes/critic.p.
           UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " >> log/proc_batch.log").
           RETURN.
    
       END.
    ELSE
       aux_dtmovime = crapdat.dtultdia.
       
    ASSIGN con_dtmovime = "70" +
                          SUBSTR(STRING(YEAR(aux_dtmovime),"9999"),3,2) + 
                          STRING(MONTH(aux_dtmovime),"99") + 
                          STRING(DAY(aux_dtmovime),"99").


    /** Valor Tarifa Pessoa Fisica **/
    IF  tot_vlrtrfpf <> 0  THEN DO:

        ASSIGN aux_linhadet =  TRIM(con_dtmvtolt) + "," +
               TRIM(STRING(aux_dtmvtolt,"999999")) + ",7268,7376," +
               TRIM(STRING((tot_vlrtrfpf - tot_trfgpspf)* 100,"zzzzzzzzzzzzz9,99"))
               + ",1434,"+ '"' +
               "TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA FISICA"
               + '"' .

        PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.

        DO  aux_contador = 1 TO aux_nrmaxpas:
            IF  ger_vltrpapf[aux_contador] <> 0 THEN DO:
                aux_linhadet = STRING(aux_cdccuage[aux_contador],"999")
                               + "," +
                               TRIM(STRING(ger_vltrpapf[aux_contador] * 100,
                               "zzzzzzzzzz9,99")).

                PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.
            END.
        END.

        DO  aux_contador = 1 to aux_nrmaxpas:
            IF  ger_vltrpapf[aux_contador] <> 0 THEN DO:
                aux_linhadet = STRING(aux_cdccuage[aux_contador],"999")
                               + "," +
                               TRIM(STRING(ger_vltrpapf[aux_contador] * 100,
                               "zzzzzzzzzz9,99")).

                PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.
             END.
        END.

    END.    

    /** Valor Tarifa Pessoa Juridica **/
    IF  tot_vlrtrfpj <> 0  THEN DO:
        ASSIGN aux_linhadet =  TRIM(con_dtmvtolt) + "," +
               TRIM(STRING(aux_dtmvtolt,"999999")) + ",7268,7377," +
               TRIM(STRING((tot_vlrtrfpj - tot_trfgpspj)* 100,"zzzzzzzzzzzzz9,99"))
               + ",1434,"+ '"' +
               "TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
               + '"' .

        PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.

        DO  aux_contador = 1 TO aux_nrmaxpas:
            IF  ger_vltrpapj[aux_contador] <> 0 THEN DO:
                aux_linhadet = STRING(aux_cdccuage[aux_contador],"999")
                               + "," +
                               TRIM(STRING(ger_vltrpapj[aux_contador] * 100,
                               "zzzzzzzzzz9,99")).

                PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.
            END.
        END.

        DO  aux_contador = 1 to aux_nrmaxpas:
            IF  ger_vltrpapj[aux_contador] <> 0 THEN DO:
                aux_linhadet = STRING(aux_cdccuage[aux_contador],"999")
                               + "," +
                               TRIM(STRING(ger_vltrpapj[aux_contador] * 100,
                               "zzzzzzzzzz9,99")).

                PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.
             END.
        END.
    END.
    
    OUTPUT STREAM str_2 CLOSE.
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    UNIX SILENT VALUE("ux2dos " + aux_nmarqdat +
                              " > /micros/" + crapcop.dsdircop + "/" +
                              aux_nmarqdat + " 2>/dev/null").

END PROCEDURE. /* FIM - gera_conciliacao_conven */

/*****************************************************************/

PROCEDURE gera-rel-mensal-cecred:

    /* Pega primeiro e último dia do mês */
    ASSIGN aux_dtmvtolt = glb_dtmvtolt.
    
    IF (MONTH(aux_dtmvtolt) + 1 = 13) THEN
        ASSIGN aux_datafina = DATE(1,21,YEAR(aux_dtmvtolt)+ 1).
    ELSE
        ASSIGN aux_datafina = DATE(MONTH(aux_dtmvtolt) + 1,21,YEAR(aux_dtmvtolt)).

    ASSIGN aux_datafina = aux_datafina - 21
           aux_datainic = DATE(MONTH(aux_datafina),01,YEAR(aux_datafina)).

    /* Gera relatório mensal crrl636 para a CECRED */
    ASSIGN aux_qttotfat    = 0
           aux_vltotfat    = 0
           aux_vltottar    = 0
           glb_cdcritic    = 0
           glb_cdrelato[3] = 636
           aux_nmarqimp    = "/usr/coop/cecred/rl/crrl636.lst"
           glb_cdempres    = 11
           glb_nrcopias    = 1
           glb_nmformul    = "132col"
           glb_nmarqimp    = aux_nmarqimp
           tot_vltrfuni    = 0
           tot_vltotfat    = 0
           tot_qttotfat    = 0
           tot_vlrecliq    = 0.

    { includes/cabrel132_3.i }

    OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_3 FRAME f_cabrel132_3.

    VIEW STREAM str_3 FRAME f_titulo_rel636.

    /* Percorre todos os dias */
    DO aux_dtvencto = aux_datainic TO aux_datafina:

        /* Leitura para Convenios e DARFs para cada cooperativa */
        FOR EACH crapcop FIELDS(cdcooper nmrescop vltardrf vltarcrs) NO-LOCK:

            FOR EACH craplft FIELDS(cdtribut cdempcon cdsegmto tpfatura
                                    vllanmto vlrmulta vlrjuros cdagenci)
                         WHERE craplft.cdcooper  = crapcop.cdcooper AND
                               craplft.dtvencto  = aux_dtvencto     AND
                               craplft.insitfat  = 2                AND
                               craplft.cdhistor  = 1154   /* SICREDI */
                               NO-LOCK BREAK BY craplft.cdtribut
                                             BY craplft.cdempcon
                                             BY craplft.cdsegmto.

                IF  FIRST-OF (craplft.cdtribut) OR
                    FIRST-OF (craplft.cdempcon) OR
                    FIRST-OF (craplft.cdsegmto) THEN
                    ASSIGN tot_qtfatint = 0
                           tot_vlfatint = 0
                           tot_qtfattaa = 0
                           tot_vlfattaa = 0
                           tot_qtfatcxa = 0
                           tot_vlfatcxa = 0.

                IF  craplft.tpfatura <> 2  OR
                    craplft.cdempcon <> 0  THEN
                    DO:
                        IF  FIRST-OF (craplft.cdempcon) OR
                            FIRST-OF (craplft.cdsegmto) THEN
                            DO:
                                /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
                                FIND FIRST crapscn WHERE crapscn.cdempcon = craplft.cdempcon AND
                                                         crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
                                                         crapscn.dtencemp = ?                        AND
                                                         crapscn.dsoparre <> "E"   /* Debaut */
                                                         NO-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crapscn THEN
                                    DO:
                                        FIND FIRST crapscn WHERE crapscn.cdempco2 = craplft.cdempcon AND
                                                                 crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
                                                                 crapscn.dtencemp = ?                        AND
                                                                 crapscn.dsoparre <> "E"   /* Debaut */
                                                                 NO-LOCK NO-ERROR NO-WAIT.
                                        IF  NOT AVAIL crapscn THEN
                                            NEXT.
                                    END.
                            END.
                    END.
                ELSE
                    DO:
                        IF  FIRST-OF (craplft.cdtribut) THEN
                            DO:
                                IF  craplft.cdtribut = "6106" THEN /* DARF SIMPLES */
                                    DO:
                                        FIND FIRST crapscn WHERE crapscn.cdempres = "D0"
                                                   NO-LOCK NO-ERROR NO-WAIT.

                                        IF  NOT AVAIL crapscn THEN
                                            NEXT.
                                    END.
                                ELSE
                                    DO: /* DARF PRETO EUROPA */
                                        FIND FIRST crapscn WHERE crapscn.cdempres = "A0"
                                                   NO-LOCK NO-ERROR NO-WAIT.

                                        IF  NOT AVAIL crapscn THEN
                                            NEXT.
                                    END.
                            END.
                    END.

                /* Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16 */
                IF  craplft.tpfatura >= 1 THEN
                    ASSIGN aux_vltarfat = crapcop.vltardrf. /* 0.16 era o valor antigo */
                ELSE
                    ASSIGN aux_vltarfat = crapthi.vltarifa.

                IF  craplft.cdagenci = 90 THEN  /** Internet **/
                    ASSIGN  tot_qtfatint = tot_qtfatint + 1
                            tot_vlfatint = tot_vlfatint + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).
                ELSE
                IF  craplft.cdagenci = 91 THEN  /** TAA **/
                    ASSIGN  tot_qtfattaa = tot_qtfattaa + 1
                            tot_vlfattaa = tot_vlfattaa + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

                ELSE                            /** Caixa **/
                    ASSIGN  tot_qtfatcxa = tot_qtfatcxa + 1
                            tot_vlfatcxa = tot_vlfatcxa + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

                IF  LAST-OF (craplft.cdempcon) OR
                    LAST-OF (craplft.cdsegmto) THEN
                    DO:
                        /* INTERNET */
                        FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                                 crapstn.tpmeiarr = "D"
                                                 NO-LOCK NO-ERROR.

                        IF  tot_qtfatint > 0 AND
                            AVAIL crapstn    AND
                            AVAIL crapthi    THEN
                            DO:
                                FIND tt-rel636 WHERE tt-rel636.cdempres = crapscn.cdempres AND
                                                     tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL tt-rel636 THEN
                                    DO:
                                        CREATE tt-rel636.
                                        ASSIGN tt-rel636.nmrescop = crapcop.nmrescop
                                               tt-rel636.nmconven = crapscn.dsnomcnv
                                               tt-rel636.dsmeiarr = "INTERNET"
                                               tt-rel636.cdcooper = crapcop.cdcooper
                                               tt-rel636.cdempres = crapscn.cdempres
                                               tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                               tt-rel636.qtfatura = tot_qtfatint
                                               tt-rel636.vltotfat = tot_vlfatint
                                               tt-rel636.vltottar = (crapstn.vltrfuni * tot_qtfatint)
                                               tt-rel636.vlrecliq = tt-rel636.vltottar - (tot_qtfatint * aux_vltarfat)
                                               tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq)
                                               tt-rel636.dsdianor = crapscn.dsdianor
                                               tt-rel636.nrrenorm = crapscn.nrrenorm.
                                    END.
                                ELSE /* Incrementa os valores de dias anteriores */
                                    ASSIGN tt-rel636.qtfatura = tt-rel636.qtfatura + tot_qtfatint
                                           tt-rel636.vltotfat = tt-rel636.vltotfat + tot_vlfatint
                                           tt-rel636.vltottar = (crapstn.vltrfuni * tt-rel636.qtfatura)
                                           /* Recalcula e sobrescreve valores derivados de tarifas */
                                           tt-rel636.vlrecliq = tt-rel636.vltottar - (tt-rel636.qtfatura * aux_vltarfat)
                                           tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq).
                            END.

                        /* TAA */
                        FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                                 crapstn.tpmeiarr = "A"
                                                 NO-LOCK NO-ERROR.

                        IF  tot_qtfattaa > 0 AND
                            AVAIL crapstn    AND
                            AVAIL crapthi    THEN
                            DO:
                                FIND tt-rel636 WHERE tt-rel636.cdempres = crapscn.cdempres AND
                                                     tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL tt-rel636 THEN
                                    DO:
                                        CREATE tt-rel636.
                                        ASSIGN tt-rel636.nmrescop = crapcop.nmrescop
                                               tt-rel636.nmconven = crapscn.dsnomcnv
                                               tt-rel636.dsmeiarr = "TAA"
                                               tt-rel636.cdcooper = crapcop.cdcooper
                                               tt-rel636.cdempres = crapscn.cdempres
                                               tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                               tt-rel636.qtfatura = tot_qtfattaa
                                               tt-rel636.vltotfat = tot_vlfattaa
                                               tt-rel636.vltottar = (crapstn.vltrfuni * tot_qtfattaa)
                                               tt-rel636.vlrecliq = tt-rel636.vltottar - (tot_qtfattaa * crapthi.vltarifa)
                                               tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq)
                                               tt-rel636.dsdianor = crapscn.dsdianor
                                               tt-rel636.nrrenorm = crapscn.nrrenorm.
                                    END.
                                ELSE /* Incrementa os valores de dias anteriores */
                                    ASSIGN tt-rel636.qtfatura = tt-rel636.qtfatura + tot_qtfattaa
                                           tt-rel636.vltotfat = tt-rel636.vltotfat + tot_vlfattaa
                                           tt-rel636.vltottar = (crapstn.vltrfuni * tt-rel636.qtfatura)
                                           /* Recalcula e sobrescreve valores derivados de tarifas */
                                           tt-rel636.vlrecliq = tt-rel636.vltottar - (tt-rel636.qtfatura * crapthi.vltarifa)
                                           tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq).
                            END.

                        /* CAIXA */
                        FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                                 crapstn.tpmeiarr = "C"
                                                 NO-LOCK NO-ERROR.

                        IF  tot_qtfatcxa > 0 AND
                            AVAIL crapstn    AND
                            AVAIL crapthi    THEN
                            DO:
                                FIND tt-rel636 WHERE tt-rel636.cdempres = crapscn.cdempres AND
                                                     tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL tt-rel636 THEN
                                    DO:
                                        CREATE tt-rel636.
                                        ASSIGN tt-rel636.nmrescop = crapcop.nmrescop
                                               tt-rel636.nmconven = crapscn.dsnomcnv
                                               tt-rel636.dsmeiarr = "CAIXA"
                                               tt-rel636.cdcooper = crapcop.cdcooper
                                               tt-rel636.cdempres = crapscn.cdempres
                                               tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                               tt-rel636.qtfatura = tot_qtfatcxa
                                               tt-rel636.vltotfat = tot_vlfatcxa
                                               tt-rel636.vltottar = (crapstn.vltrfuni * tot_qtfatcxa)
                                               tt-rel636.vlrecliq = tt-rel636.vltottar - (tot_qtfatcxa * aux_vltarfat)
                                               tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq)
                                               tt-rel636.dsdianor = crapscn.dsdianor
                                               tt-rel636.nrrenorm = crapscn.nrrenorm.
                                    END.
                                ELSE /* Incrementa os valores de dias anteriores */
                                    ASSIGN tt-rel636.qtfatura = tt-rel636.qtfatura + tot_qtfatcxa
                                           tt-rel636.vltotfat = tt-rel636.vltotfat + tot_vlfatcxa
                                           tt-rel636.vltottar = (crapstn.vltrfuni * tt-rel636.qtfatura)
                                           tt-rel636.vlrecliq = tt-rel636.vltottar - (tt-rel636.qtfatura * aux_vltarfat)
                                           tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq).
                            END.
                    END.
            END. /* fim do for each craplft */

            /* Para debito aumatico SICREDI */
            FOR EACH craplcm FIELD(cdcooper cdhistor nrdocmto nrdconta
                                   cdagenci dtmvtolt nrdolote vllanmto)
                             WHERE craplcm.cdcooper = crapcop.cdcooper AND
                                   craplcm.cdhistor = 1019             AND
                                   craplcm.dtmvtolt = aux_dtvencto
                                   NO-LOCK:

                FIND craplau WHERE craplau.cdcooper = craplcm.cdcooper AND
                                   craplau.cdhistor = craplcm.cdhistor AND
                                   craplau.nrdocmto = craplcm.nrdocmto AND
                                   craplau.nrdconta = craplcm.nrdconta AND
                                   craplau.cdagenci = craplcm.cdagenci AND
                                   craplau.dtmvtopg = craplcm.dtmvtolt
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL craplau THEN
                    NEXT.

                ASSIGN tot_qtfatdeb = 0
                       tot_vlfatdeb = 0.

                /* somatoria por empresa */
                FOR EACH crapscn WHERE crapscn.cdempres = craplau.cdempres
                                       NO-LOCK:

                    ASSIGN tot_qtfatdeb = tot_qtfatdeb + 1
                           tot_vlfatdeb = tot_vlfatdeb + craplcm.vllanmto.

                END.

                /* Se nao for debito automatico não faz */
                FIND FIRST crapscn WHERE crapscn.dsoparre = "E"                AND
                                        (crapscn.cddmoden = "A"                OR
                                         crapscn.cddmoden = "C")               AND
                                         crapscn.cdempres = craplau.cdempres
                                         NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapscn THEN
                    NEXT.

                FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                         crapstn.tpmeiarr = "E"
                                         NO-LOCK NO-ERROR.

                IF  AVAIL crapstn THEN
                    DO:

                        FIND tt-rel636 WHERE tt-rel636.cdempres = crapscn.cdempres AND
                                             tt-rel636.tpmeiarr = crapstn.tpmeiarr
                                             EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL tt-rel636  THEN
                            DO:

                                CREATE tt-rel636.
                                ASSIGN tt-rel636.nmconven = crapscn.dsnomcnv
                                       tt-rel636.cdempres = crapscn.cdempres
                                       tt-rel636.tpmeiarr = "E"
                                       tt-rel636.qtfatura = tot_qtfatdeb
                                       tt-rel636.vltotfat = tot_vlfatdeb
                                       tt-rel636.vltottar = (crapstn.vltrfuni * tot_qtfatdeb)
                                       tt-rel636.vlrecliq = tt-rel636.vltottar - (tot_qtfatdeb * aux_vltarifa)
                                       tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq)
                                       tt-rel636.dsdianor = crapscn.dsdianor
                                       tt-rel636.nrrenorm = crapscn.nrrenorm
                                       tt-rel636.dsmeiarr = "DEB. AUTOMATICO".
                            END.
                        ELSE    /* Incrementa os valores anteriores */
                            ASSIGN tt-rel636.qtfatura = tt-rel636.qtfatura + tot_qtfatdeb
                                   tt-rel636.vltotfat = tt-rel636.vltotfat + tot_vlfatdeb
                                   tt-rel636.vltottar = tt-rel636.vltottar + (crapstn.vltrfuni * tot_qtfatdeb)
                                   tt-rel636.vlrecliq = tt-rel636.vlrecliq + ((tot_qtfatdeb * crapstn.vltrfuni) - (tot_qtfatdeb * aux_vltarifa))
                                   tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq).
                    END.
            END.

            /* GUIA DA PREVIDENVIA SOCIAL - SICREDI */

            /* Tarifa a ser paga ao SICREDI */
            FIND FIRST crapthi WHERE crapthi.cdcooper = crapcop.cdcooper
                                 AND crapthi.cdhistor = 1414
                                 AND crapthi.dsorigem = "AYLLOS"
                                 NO-LOCK NO-ERROR.
        
            /* Localizar a tarifa da base */
            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                                 AND craptab.nmsistem = "CRED"
                                 AND craptab.tptabela = "GENERI"
                                 AND craptab.cdempres = 00
                                 AND craptab.cdacesso = "GPSCXASCOD"
                                 AND craptab.tpregist = 0
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_vltfcxsb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Sem.Barra */
            ELSE
                ASSIGN aux_vltfcxsb = 0.
        
            /* Localizar a tarifa da base */
            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                                 AND craptab.nmsistem = "CRED"
                                 AND craptab.tptabela = "GENERI"
                                 AND craptab.cdempres = 00
                                 AND craptab.cdacesso = "GPSCXACCOD"
                                 AND craptab.tpregist = 0
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_vltfcxcb = DECI(craptab.dstextab).  /* Valor Tarifa Caixa Com Com.Barra */
            ELSE
                ASSIGN aux_vltfcxcb = 0.
        
            /* Localizar a tarifa da base */
            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper
                                 AND craptab.nmsistem = "CRED"
                                 AND craptab.tptabela = "GENERI"
                                 AND craptab.cdempres = 00
                                 AND craptab.cdacesso = "GPSINTBANK"
                                 AND craptab.tpregist = 0
                                 NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_vlrtrfib = DECI(craptab.dstextab).  /*  Valor Tarifa IB  */
            ELSE
                ASSIGN aux_vlrtrfib = 0.

            /* Para todos os lancamentos ja pagos */
            FOR EACH craplgp
               WHERE craplgp.cdcooper = crapcop.cdcooper
                               AND craplgp.dtmvtolt = aux_dtvencto
                               AND craplgp.idsicred <> 0
                 AND craplgp.flgativo = YES
                               BREAK BY craplgp.cdcooper
                                     BY craplgp.cdagenci
                                     BY craplgp.tpdpagto:
        
                /* Inicializa Variaveis */
                ASSIGN aux_dsempgps = ""
                       aux_dsnomcnv = ""
                       aux_tpmeiarr = ""
                       aux_dsmeiarr = ""
                       aux_vltargps = 0.
        
                IF  craplgp.cdagenci <> 90 THEN /* CAIXA*/
                    ASSIGN aux_tpmeiarr = "C"
                           aux_dsmeiarr = "CAIXA"
                           aux_vltargps = IF craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
                                             aux_vltfcxcb
                                          ELSE /* Sem Cod.Barras*/
                                             aux_vltfcxsb.
                ELSE /* INTERNET */
                    ASSIGN aux_tpmeiarr = "D"
                           aux_dsmeiarr = "INTERNET"
                           aux_vltargps = aux_vlrtrfib.
        
        
                IF  craplgp.tpdpagto = 1 THEN /* Com Cod.Barras*/
                    ASSIGN aux_dsempgps = "GP1"
                           aux_dsnomcnv = "GPS - COM COD.BARRAS".
                ELSE /* Sem Cod.Barras*/
                    ASSIGN aux_dsempgps = "GP2"
                           aux_dsnomcnv = "GPS - SEM COD.BARRAS".

                FIND tt-rel636 WHERE tt-rel636.cdempres = aux_dsempgps
                                 AND tt-rel636.tpmeiarr = aux_tpmeiarr
                                 EXCLUSIVE-LOCK NO-ERROR.

                IF  NOT AVAIL tt-rel636  THEN DO:
                    CREATE tt-rel636.
                    ASSIGN tt-rel636.nmconven = aux_dsnomcnv
                           tt-rel636.cdempres = aux_dsempgps
                           tt-rel636.tpmeiarr = aux_tpmeiarr
                           tt-rel636.qtfatura = 1
                           tt-rel636.vltotfat = craplgp.vlrtotal
                           tt-rel636.vltottar = aux_vltargps
                           tt-rel636.vlrecliq = tt-rel636.vltottar - b2crapthi.vltarifa
                           tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq)
                           tt-rel636.dsdianor = ""
                           tt-rel636.nrrenorm = 0
                           tt-rel636.dsmeiarr = aux_dsmeiarr.
                END.
                ELSE    /* Incrementa os valores anteriores */
                    ASSIGN tt-rel636.qtfatura = tt-rel636.qtfatura + 1
                           tt-rel636.vltotfat = tt-rel636.vltotfat + craplgp.vlrtotal
                           tt-rel636.vltottar = tt-rel636.vltottar + aux_vltargps
                           tt-rel636.vlrecliq = tt-rel636.vlrecliq + (aux_vltargps - b2crapthi.vltarifa)
                           tt-rel636.vltrfsic = IF tt-rel636.vlrecliq < 0 THEN  tt-rel636.vltottar ELSE (tt-rel636.vltottar - tt-rel636.vlrecliq).

            END. /* Fim do FOR - CRAPLGP */

        END. /* FOR EACH crapcop */
    END. /* DO... TO */

    /* Faz o calculo dos totais por convenio */
    FOR EACH tt-rel636 NO-LOCK BREAK BY tt-rel636.cdempres:

        FIND tt-totais WHERE tt-totais.cdempres = tt-rel636.cdempres
                             NO-LOCK NO-ERROR.

        IF  NOT AVAIL tt-totais THEN
            DO:
                CREATE tt-totais.
                ASSIGN tt-totais.cdempres = tt-rel636.cdempres
                       tt-totais.tpmeiarr = tt-rel636.tpmeiarr
                       tt-totais.dsmeiarr = tt-rel636.dsmeiarr
                       tt-totais.nmconven = tt-rel636.nmconven.
            END.

        ASSIGN tt-totais.qtfatura = tt-totais.qtfatura + tt-rel636.qtfatura
               tt-totais.vltotfat = tt-totais.vltotfat + tt-rel636.vltotfat
               tt-totais.vltottar = tt-totais.vltottar + tt-rel636.vltottar
               tt-totais.vlrecliq = tt-totais.vlrecliq + tt-rel636.vlrecliq.

        IF  tt-totais.vlrecliq < 0 THEN
            ASSIGN tt-totais.vlrecliq = 0.

        IF  tt-totais.vltottar < 0 THEN
            ASSIGN tt-totais.vltottar = 0.

        IF  tt-totais.vltotfat < 0 THEN
            ASSIGN tt-totais.vltotfat = 0.

    END.

    FOR EACH tt-totais NO-LOCK WHERE tt-totais.tpmeiarr <> "E",
        EACH tt-rel636 WHERE tt-rel636.cdempres = tt-totais.cdempres NO-LOCK
                       BREAK BY tt-totais.qtfatura DESC
                             BY tt-rel636.cdempres
                             BY tt-rel636.qtfatura DESC.

        IF  LINE-COUNTER(str_3) > PAGE-SIZE(str_3)  THEN
            DO:
                PAGE STREAM str_3.
                VIEW STREAM str_3 FRAME f_cabrel132_3.
                VIEW STREAM str_3 FRAME f_titulo_rel636.
            END.

        IF  tt-rel636.tpmeiarr = "D" THEN
            DO:
                 /* TOTAIS INTERNET */
                ASSIGN int_vltrfuni = int_vltrfuni + tt-rel636.vltottar
                       int_vltotfat = int_vltotfat + tt-rel636.vltotfat
                       int_qttotfat = int_qttotfat + tt-rel636.qtfatura
                       int_vlrecliq = int_vlrecliq + tt-rel636.vlrecliq.
            END.

        IF  tt-rel636.tpmeiarr = "C" THEN
            DO:
                 /* TOTAIS CAIXA */
                ASSIGN cax_vltrfuni = cax_vltrfuni + tt-rel636.vltottar
                       cax_vltotfat = cax_vltotfat + tt-rel636.vltotfat
                       cax_qttotfat = cax_qttotfat + tt-rel636.qtfatura
                       cax_vlrecliq = cax_vlrecliq + tt-rel636.vlrecliq.
            END.

        IF  tt-rel636.tpmeiarr = "A" THEN
            DO:
                 /* TOTAIS TAA */
                ASSIGN taa_vltrfuni = taa_vltrfuni + tt-rel636.vltottar
                       taa_vltotfat = taa_vltotfat + tt-rel636.vltotfat
                       taa_qttotfat = taa_qttotfat + tt-rel636.qtfatura
                       taa_vlrecliq = taa_vlrecliq + tt-rel636.vlrecliq.
            END.

        /* TOTAIS GERAL */
        ASSIGN tot_vltrfuni = tot_vltrfuni + tt-rel636.vltottar
               tot_vltotfat = tot_vltotfat + tt-rel636.vltotfat
               tot_qttotfat = tot_qttotfat + tt-rel636.qtfatura
               tot_vlrecliq = tot_vlrecliq + tt-rel636.vlrecliq.

         /* Corrige valores negativos */
        IF  tt-rel636.vltotfat < 0 THEN
            ASSIGN tt-rel636.vltotfat = 0.

        IF  tt-rel636.vlrecliq < 0 THEN
            ASSIGN tt-rel636.vlrecliq = 0.

        IF  tt-rel636.vltottar < 0 THEN
            ASSIGN tt-rel636.vltottar = 0.

        DISPLAY STREAM str_3 tt-rel636.nmconven
                             tt-rel636.dsmeiarr
                             tt-rel636.qtfatura
                             tt-rel636.vltotfat
                             tt-rel636.vlrecliq
                             tt-rel636.vltottar
                             tt-rel636.nrrenorm
                             tt-rel636.dsdianor
                             WITH FRAME f_rel636.

        DOWN STREAM str_3 WITH FRAME f_rel636.

        IF  LAST-OF(tt-rel636.cdempres) THEN
            DISPLAY STREAM str_3 tt-totais.qtfatura
                                 tt-totais.vltotfat
                                 tt-totais.vlrecliq
                                 tt-totais.vltottar
                                 WITH FRAME f_totais_convenio.

    END.

    PUT STREAM str_3 "TOTAL GERAL: " AT 01
               tot_qttotfat AT 51 FORMAT "zzzzzz9"
               tot_vltotfat AT 59 FORMAT "zzz,zzz,zzz,zz9.99"
               tot_vlrecliq AT 82 FORMAT "zzz,zzz,zzz,zz9.99"
               tot_vltrfuni AT 101 FORMAT "zz,zzz,zz9.99"
               SKIP(1).


    /*** Impressao dos registros de debito automatico que deverao ir
         depois que listou todos os outros convenios ***/
    VIEW STREAM str_3 FRAME f_cabrel132_3.
    PUT  STREAM str_3 SKIP(2) "DEBITO AUTOMATICO " SKIP.
    VIEW STREAM str_3 FRAME f_titulo_rel636.

    FOR EACH tt-totais NO-LOCK WHERE tt-totais.tpmeiarr = "E",
        EACH tt-rel636 WHERE tt-rel636.cdempres = tt-totais.cdempres NO-LOCK
                       BREAK BY tt-totais.qtfatura DESC
                             BY tt-rel636.cdempres
                             BY tt-rel636.qtfatura DESC.

        IF  LINE-COUNTER(str_3) > PAGE-SIZE(str_3) THEN
            DO:
                PAGE STREAM str_3.
                VIEW STREAM str_3 FRAME f_cabrel132_3.
                VIEW STREAM str_3 FRAME f_titulo_rel636.
            END.

        /* TOTAIS DEB AUTOMATICO */
        ASSIGN deb_vltrfuni = deb_vltrfuni + tt-rel636.vltottar
               deb_vltotfat = deb_vltotfat + tt-rel636.vltotfat
               deb_qttotfat = deb_qttotfat + tt-rel636.qtfatura
               deb_vlrecliq = deb_vlrecliq + tt-rel636.vlrecliq.

        /* TOTAIS GERAL */
        ASSIGN tot_vltrfuni = tot_vltrfuni + tt-rel636.vltottar
               tot_vltotfat = tot_vltotfat + tt-rel636.vltotfat
               tot_qttotfat = tot_qttotfat + tt-rel636.qtfatura
               tot_vlrecliq = tot_vlrecliq + tt-rel636.vlrecliq.

         /* Corrige valores negativos */
        IF  tt-rel636.vltotfat < 0 THEN
            ASSIGN tt-rel636.vltotfat = 0.

        IF  tt-rel636.vlrecliq < 0 THEN
            ASSIGN tt-rel636.vlrecliq = 0.

        IF  tt-rel636.vltottar < 0 THEN
            ASSIGN tt-rel636.vltottar = 0.

        DISPLAY STREAM str_3 tt-rel636.nmconven
                             tt-rel636.dsmeiarr
                             tt-rel636.qtfatura
                             tt-rel636.vltotfat
                             tt-rel636.vlrecliq
                             tt-rel636.vltottar
                             tt-rel636.nrrenorm
                             tt-rel636.dsdianor
                             WITH FRAME f_rel636.
        DOWN STREAM str_3 WITH FRAME f_rel636.

    END.

    PUT STREAM str_3 SKIP(1)
               "TOTAL GERAL: " AT 01
               deb_qttotfat    AT 51  FORMAT "zzzzzz9"
               deb_vltotfat    AT 59  FORMAT "zzz,zzz,zzz,zz9.99"
               deb_vlrecliq    AT 82  FORMAT "zzz,zzz,zzz,zz9.99"
               deb_vltrfuni    AT 101 FORMAT "zz,zzz,zz9.99"
               SKIP.


    PUT STREAM str_3
    SKIP(3)
    "TOTAL POR MEIO DE ARRECADACAO"
    SKIP(1)
    "MEIO ARRECADACAO QTD.FATURAS      VALOR FATURAS "
    "RECEITA LIQUIDA COOP.  VALOR TARIFA"
    SKIP
    "---------------- ----------- ------------------ "
    "--------------------- -------------".

    /* Exibe Totais por Coluna */
    DISPLAY STREAM str_3 /*internet*/
                         int_qttotfat
                         int_vltotfat
                         int_vlrecliq
                         int_vltrfuni
                          /* caixa */
                         cax_qttotfat
                         cax_vltotfat
                         cax_vlrecliq
                         cax_vltrfuni
                         /* taa */
                         taa_qttotfat
                         taa_vltotfat
                         taa_vlrecliq
                         taa_vltrfuni
                         /*Deb Auto*/
                         deb_qttotfat
                         deb_vltotfat
                         deb_vlrecliq
                         deb_vltrfuni
                        /*total geral*/
                         tot_qttotfat
                         tot_vltotfat
                         tot_vlrecliq
                         tot_vltrfuni
                         WITH FRAME f_totais_rel636.

    OUTPUT STREAM str_3 CLOSE.

    IF  NOT TEMP-TABLE tt-rel636:HAS-RECORDS THEN
        UNIX SILENT VALUE ("rm " + aux_nmarqimp + "* 2>/dev/null").
    ELSE
        RUN fontes/imprim.p.

END PROCEDURE.


