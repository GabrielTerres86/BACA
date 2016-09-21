/* ............................................................................

   Programa: fontes/crps687.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos Henrique
   Data    : Maio/2014                       Ultima atualizacao: 23/09/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar relatorios das arrecadacoes de GPS
               crrl681 - Arrecadação Diaria
               crrl682 - Arrecadação Mensal.
               
               Sol. 2  / Ordem  / Exclusividade = paralelo
               
   Alteracoes: 23/09/2015 - Incluindo calculo de pagamentos GPS.
                            (André Santos - SUPERO)
.............................................................................*/

{ includes/var_batch.i "NEW" }

DEF STREAM str_1. /* rel 681 Arrecadação Diaria */
DEF STREAM str_2. /* rel 682 Arrecadação Mensal */

DEF VAR data_ini AS DATE                                           NO-UNDO.
DEF VAR data_fim AS DATE                                           NO-UNDO.
DEF VAR aux_data AS DATE                                           NO-UNDO.

DEF VAR aux_vlrtotal AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR aux_vlrtarif AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR aux_vlrrecec AS DECI FORMAT "zzz,zz9.99"                   NO-UNDO.
DEF VAR aux_vltarcrs AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR aux_vltarifa AS DECI FORMAT "zzz,zz9.99"                   NO-UNDO.
DEF VAR aux_vltarif1 AS DECI FORMAT "zzz,zz9.99"                   NO-UNDO.

DEF VAR aux_qttartot AS INTE FORMAT "zzz,zz9"                      NO-UNDO.
DEF VAR aux_qtddegps AS INTE FORMAT "zzz,zz9"                      NO-UNDO.

DEF VAR aux_arquivo1 AS CHAR FORMAT "X(40)"                        NO-UNDO.
DEF VAR aux_arquivo2 AS CHAR FORMAT "X(40)"                        NO-UNDO.

DEF VAR aux_vltfcxcb AS    DECI                                   NO-UNDO.
DEF VAR aux_vltfcxsb AS    DECI                                   NO-UNDO.
DEF VAR aux_vlrtrfib AS    DECI                                   NO-UNDO.

DEF VAR tot_qtddegps AS INTE FORMAT "zzz,zz9"                      NO-UNDO.
DEF VAR tot_vlrtotal AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR tot_vlrtarif AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR tot_vltarcrs AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.

DEF VAR totger_qtddegps AS INTE FORMAT "zzz,zz9"                   NO-UNDO.
DEF VAR totger_vlrtotal AS DECI FORMAT "z,zzz,zzz,zz9.99"          NO-UNDO.
DEF VAR totger_vlrtarif AS DECI FORMAT "z,zzz,zzz,zz9.99"          NO-UNDO.
DEF VAR totger_vltarcrs AS DECI FORMAT "z,zzz,zzz,zz9.99"          NO-UNDO.

/* Vars e include exclusivos para relatorio PDF */
DEF  VAR rel_nmrelato      AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF  VAR rel_nmempres      AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF  VAR rel_nmresemp      AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF  VAR rel_nrmodulo      AS INTE  FORMAT "9"                         NO-UNDO.
DEF  VAR rel_nmmodulo      AS CHAR  FORMAT "x(15)" EXTENT 5
                                    INIT ["DEP. A VISTA   ","CAPITAL        ",
                                          "EMPRESTIMOS    ","DIGITACAO      ",
                                          "GENERICO       "]           NO-UNDO.
/* fim Vars e include exclusivos para relatorio PDF */

DEF VAR aux_dtprimdm AS DATE NO-UNDO. /* dt do primeiro dia do mes */

/*Para os relatório diários informar PA, Qtd GPS arrecadada, Valor arrecadado e Tarifa de repasse Sicredi. */
DEF TEMP-TABLE tt-rel NO-UNDO
    FIELD cdcooper   LIKE craplgp.cdcooper
    FIELD cdagenci   LIKE craplgp.cdagenci
    FIELD quantida     AS INTE
    FIELD vlrtotal     AS DECI
    FIELD dtmvtolt   LIKE craplgp.dtmvtolt
    FIELD tarrepsi     AS DECI
    FIELD tpdpagto   LIKE craplgp.tpdpagto.

/* Cabecalho relatorio diario
PA    Qtd. GPS                 Valor GPS             Tarifa Sicredi */
FORM "PA"                        AT 1
     "Qtd. GPS"                  AT 18
     "Valor GPS"                 AT 41
     "Tarifa SICREDI"            AT 61
     WITH WIDTH 80 FRAME f_cab_diario.

FORM tt-rel.cdagenci NO-LABEL AT 1
     aux_qtddegps    NO-LABEL AT 19
     aux_vlrtotal    NO-LABEL AT 34
     aux_vlrtarif    NO-LABEL AT 59
     WITH WIDTH 80 DOWN FRAME f_diario.

FORM "Total" 
     tot_qtddegps  NO-LABEL AT 19
     tot_vlrtotal  NO-LABEL AT 34
     tot_vlrtarif  NO-LABEL AT 59
     WITH WIDTH 80 DOWN FRAME f_diario_totais.

FORM "Coop"                      AT 1
     "PA"                        AT 9
     "Qtd. GPS"                  AT 14
     "Valor GPS"                 AT 41
     "Tarifa SICREDI"            AT 64
     WITH WIDTH 80 FRAME f_cab_diario_cecred.

FORM tt-rel.cdcooper NO-LABEL AT 1
     tt-rel.cdagenci NO-LABEL AT 8
     aux_qtddegps    NO-LABEL AT 15
     aux_vlrtotal    NO-LABEL AT 34
     aux_vlrtarif    NO-LABEL AT 62
     WITH WIDTH 80 DOWN FRAME f_diario_cecred.

FORM "Total" 
     tot_qtddegps  NO-LABEL AT 15
     tot_vlrtotal  NO-LABEL AT 34
     tot_vlrtarif  NO-LABEL AT 62
     WITH WIDTH 80 DOWN FRAME f_diario_cecred_subtotais.

FORM "Total Geral" 
     tot_qtddegps  NO-LABEL AT 15
     tot_vlrtotal  NO-LABEL AT 34
     tot_vlrtarif  NO-LABEL AT 62
     WITH WIDTH 80 DOWN FRAME f_diario_cecred_totais.

/* Cabecalho relatorio mensal
PA    Qtd. GPS              Valor GPS           Tarifa Sicredi               Receita Cecred */
FORM "PA"                        AT 1
     "Qtd. GPS"                  AT 8
     "Valor GPS"                 AT 34
     "Tarifa SICREDI"            AT 47
     "Receita CECRED"            AT 64
     WITH WIDTH 80 FRAME f_cab_mensal.

FORM tt-rel.cdagenci NO-LABEL AT 1
     aux_qtddegps    NO-LABEL AT 8
     aux_vlrtotal    NO-LABEL AT 27
     aux_vlrtarif    NO-LABEL AT 45
     aux_vltarcrs    NO-LABEL 
     WITH WIDTH 80 DOWN FRAME f_mensal.

FORM "Total"                 AT 1
     tot_qtddegps    NO-LABEL AT 8
     tot_vlrtotal    NO-LABEL AT 27
     tot_vlrtarif    NO-LABEL AT 45
     tot_vltarcrs    NO-LABEL 
     WITH WIDTH 80 DOWN FRAME f_mensal_totais.

FORM "Coop"                      AT 1
     "PA"                        AT 9
     "Qtd. GPS"                  AT 14
     "Valor GPS"                 AT 33
     "Tarifa SICREDI"            AT 46
     "Receita CECRED"            AT 63 
     WITH WIDTH 80 FRAME f_cab_mensal_cecred.

FORM tt-rel.cdcooper NO-LABEL AT 1
     tt-rel.cdagenci NO-LABEL AT 8
     aux_qtddegps    NO-LABEL AT 15
     aux_vlrtotal    NO-LABEL AT 26
     aux_vlrtarif    NO-LABEL AT 44
     aux_vltarcrs    NO-LABEL  
     WITH WIDTH 80 DOWN FRAME f_mensal_cecred.

FORM "Total"
     tot_qtddegps    NO-LABEL AT 15
     tot_vlrtotal    NO-LABEL AT 26
     tot_vlrtarif    NO-LABEL AT 44
     tot_vltarcrs    NO-LABEL  
     WITH WIDTH 80 DOWN FRAME f_mensal_cecred_totais.

FORM "Total Geral"
     totger_qtddegps    NO-LABEL AT 15
     totger_vlrtotal    NO-LABEL AT 26
     totger_vlrtarif    NO-LABEL AT 44
     totger_vltarcrs    NO-LABEL 
     WITH WIDTH 80 DOWN FRAME f_mensal_cecred_total_geral.

/* =======================================================*/

ASSIGN  glb_cdprogra = "crps687"
        rel_nmmodulo = ""
        rel_nrmodulo = 5.
 
RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    RETURN.
END.

ASSIGN aux_arquivo1 = "rl/crrl681.lst"
       aux_arquivo2 = "rl/crrl682.lst".

/*
=================================================== 
                    Diário 
=================================================== */

EMPTY TEMP-TABLE tt-rel.

IF glb_cdcooper <> 3 THEN DO:
    
    FIND FIRST crapthi where crapthi.cdcooper = glb_cdcooper AND
                             crapthi.cdhistor = 1414         AND 
                             crapthi.dsorigem = 'AYLLOS' NO-LOCK.

    FOR EACH craplgp WHERE craplgp.cdcooper = glb_cdcooper AND
                           craplgp.dtmvtolt = glb_dtmvtolt AND
                           craplgp.idsicred <> 0
                           NO-LOCK:
        CREATE tt-rel.
        ASSIGN tt-rel.cdcooper = craplgp.cdcooper
               tt-rel.cdagenci = craplgp.cdagenci
               tt-rel.vlrtotal = craplgp.vlrtotal
               tt-rel.dtmvtolt = craplgp.dtmvtolt. 
    END.
END.
ELSE 
DO:
    FOR EACH craplgp WHERE craplgp.cdcooper <> 3           AND
                           craplgp.dtmvtolt = glb_dtmvtolt AND
                           craplgp.idsicred <> 0
                           NO-LOCK:
        CREATE tt-rel.
        ASSIGN tt-rel.cdcooper = craplgp.cdcooper
               tt-rel.cdagenci = craplgp.cdagenci
               tt-rel.vlrtotal = craplgp.vlrtotal
               tt-rel.dtmvtolt = craplgp.dtmvtolt. 
    END.
END.


IF TEMP-TABLE tt-rel:HAS-RECORDS THEN 
DO:

{ includes/cabrel080_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_arquivo1) PAGED PAGE-SIZE 84.
VIEW   STREAM str_1 FRAME f_cabrel080_1.

IF glb_cdcooper <> 3 THEN VIEW STREAM str_1 FRAME f_cab_diario.
ELSE                      VIEW STREAM str_1 FRAME f_cab_diario_cecred.

FOR EACH tt-rel BREAK BY tt-rel.cdcooper 
                      BY tt-rel.cdagenci:

    ASSIGN aux_qtddegps = aux_qtddegps + 1
           tot_qtddegps = tot_qtddegps + 1
           aux_vlrtotal = aux_vlrtotal + tt-rel.vlrtotal
           tot_vlrtotal = tot_vlrtotal + tt-rel.vlrtotal.

    IF  glb_cdcooper = 3 AND FIRST-OF(tt-rel.cdcooper) THEN DO:

        FIND FIRST crapthi where crapthi.cdcooper = tt-rel.cdcooper AND
                                 crapthi.cdhistor = 1414            AND 
                                 crapthi.dsorigem = 'AYLLOS' NO-LOCK.
    END.

    IF LAST-OF (tt-rel.cdagenci) THEN DO:

        ASSIGN aux_vlrtarif = crapthi.vltarifa * aux_qtddegps
               tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
        
        IF glb_cdcooper <> 3 THEN
        DO:
            DISP STREAM str_1 
                 tt-rel.cdagenci aux_qtddegps aux_vlrtotal aux_vlrtarif 
                 WITH FRAME f_diario.
            DOWN WITH FRAME f_diario.
        END.
        ELSE DO:
            DISP STREAM str_1 
                 tt-rel.cdcooper tt-rel.cdagenci aux_qtddegps aux_vlrtotal aux_vlrtarif 
                 WITH FRAME f_diario_cecred.
            DOWN WITH FRAME f_diario_cecred.
        END.

        ASSIGN aux_qtddegps = 0
               aux_vlrtotal = 0.
    END.

    IF  LAST-OF(tt-rel.cdcooper) AND glb_cdcooper = 3 THEN DO:
        DISP STREAM str_1 
            tot_qtddegps
            tot_vlrtotal
            tot_vlrtarif
            WITH FRAME f_diario_cecred_subtotais.
        ASSIGN tot_qtddegps = 0
               tot_vlrtotal = 0
               tot_vlrtarif = 0.
    END.

    IF  LINE-COUNTER(str_1) > 84 THEN DO:
        PAGE STREAM str_1.
        IF glb_cdcooper <> 3 THEN VIEW STREAM str_1 FRAME f_cab_diario.
        ELSE                      VIEW STREAM str_1 FRAME f_cab_diario_cecred.
    END.
END.

IF  glb_cdcooper <> 3 THEN 
    DISP STREAM str_1  
    tot_qtddegps   tot_vlrtotal   tot_vlrtarif  WITH FRAME f_diario_totais.
ELSE 
    DISP STREAM str_1  
    tot_qtddegps   tot_vlrtotal   tot_vlrtarif  WITH FRAME f_diario_cecred_totais.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "80col"
       glb_nmarqimp = aux_arquivo1
       glb_cdcritic = 0.

RUN fontes/imprim.p.

END. /* has-records */
/* ============= fim relatorio diario ============ */

ASSIGN
aux_vlrtotal = 0
aux_vlrtarif = 0
aux_vlrrecec = 0
aux_vltarcrs = 0
aux_vltarifa = 0
aux_qttartot = 0
aux_qtddegps = 0
tot_qtddegps = 0
tot_vlrtotal = 0
tot_vlrtarif = 0
tot_vltarcrs = 0.

/*
=================================================== 
                    Mensal
===================================================*/


IF MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN 
DO:

ASSIGN data_ini = DATE(MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt))
       data_fim = glb_dtmvtolt.

{ includes/cabrel080_2.i }              

OUTPUT STREAM str_2 TO VALUE(aux_arquivo2) PAGED PAGE-SIZE 84.
VIEW   STREAM str_2 FRAME f_cabrel080_2.


EMPTY TEMP-TABLE tt-rel.

IF glb_cdcooper <> 3 THEN DO:

    FIND FIRST crapthi where crapthi.cdcooper = glb_cdcooper AND
                             crapthi.cdhistor = 1414         AND 
                             crapthi.dsorigem = 'AYLLOS' NO-LOCK.

    DO aux_data = data_ini TO data_fim:
        FOR EACH craplgp WHERE craplgp.cdcooper = glb_cdcooper AND
                               craplgp.dtmvtolt = aux_data     AND
                               craplgp.idsicred <> 0
                               NO-LOCK:
            CREATE tt-rel.
            ASSIGN tt-rel.cdcooper = craplgp.cdcooper
                   tt-rel.cdagenci = craplgp.cdagenci
                   tt-rel.vlrtotal = craplgp.vlrtotal
                   tt-rel.dtmvtolt = craplgp.dtmvtolt
                   tt-rel.tpdpagto = craplgp.tpdpagto.
        END.
    END.
END.
ELSE 
DO:
    DO aux_data = data_ini TO data_fim:
        FOR EACH craplgp WHERE craplgp.cdcooper <> 3       AND
                               craplgp.dtmvtolt = aux_data AND
                               craplgp.idsicred <> 0
                               NO-LOCK:
            CREATE tt-rel.
            ASSIGN tt-rel.cdcooper = craplgp.cdcooper
                   tt-rel.cdagenci = craplgp.cdagenci
                   tt-rel.vlrtotal = craplgp.vlrtotal
                   tt-rel.dtmvtolt = craplgp.dtmvtolt
                   tt-rel.tpdpagto = craplgp.tpdpagto.
        END.
    END.
END.

IF TEMP-TABLE tt-rel:HAS-RECORDS THEN
DO:

IF glb_cdcooper <> 3 THEN VIEW STREAM str_2 FRAME f_cab_mensal.
ELSE                      VIEW STREAM str_2 FRAME f_cab_mensal_cecred.

FOR EACH tt-rel BREAK BY tt-rel.cdcooper 
                      BY tt-rel.cdagenci
                      BY tt-rel.tpdpagto:

    ASSIGN aux_qtddegps    = aux_qtddegps    + 1
           tot_qtddegps    = tot_qtddegps    + 1
           totger_qtddegps = totger_qtddegps + 1
           aux_vlrtotal    = aux_vlrtotal    + tt-rel.vlrtotal
           tot_vlrtotal    = tot_vlrtotal    + tt-rel.vlrtotal
           totger_vlrtotal = totger_vlrtotal + tt-rel.vlrtotal.

    IF  FIRST-OF(tt-rel.cdcooper) THEN DO:
        FIND FIRST crapthi where crapthi.cdcooper = tt-rel.cdcooper AND
                                 crapthi.cdhistor = 1414            AND 
                                 crapthi.dsorigem = 'AYLLOS' NO-LOCK.
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

    /* Tratamento de tarifas - GPS */

    IF  tt-rel.cdagenci <> 90 THEN /* CAIXA*/
        ASSIGN aux_vltarifa = IF tt-rel.tpdpagto = 1 THEN /* Com Cod.Barras*/
                                 aux_vltfcxcb
                              ELSE /* Sem Cod.Barras*/
                                 aux_vltfcxsb.
    ELSE /* INTERNET */
        ASSIGN aux_vltarifa = aux_vlrtrfib.

    ASSIGN aux_vltarif1 = aux_vltarif1 + aux_vltarifa.

    IF  LAST-OF (tt-rel.cdagenci) THEN DO:

        ASSIGN    aux_vlrtarif = crapthi.vltarifa * aux_qtddegps
                  tot_vlrtarif =    tot_vlrtarif + aux_vlrtarif
               totger_vlrtarif = totger_vlrtarif + aux_vlrtarif

                  aux_vltarcrs = aux_vltarif1
                  tot_vltarcrs =    tot_vltarcrs + aux_vltarcrs
               totger_vltarcrs = totger_vltarcrs + aux_vltarcrs.

        IF glb_cdcooper <> 3 THEN
        DO:
            DISP STREAM str_2 
                 tt-rel.cdagenci aux_qtddegps aux_vlrtotal aux_vlrtarif aux_vltarcrs
                 WITH FRAME f_mensal.
            DOWN WITH FRAME f_mensal.
        END.
        ELSE DO:
            DISP STREAM str_2 
                 tt-rel.cdcooper 
                 tt-rel.cdagenci aux_qtddegps aux_vlrtotal aux_vlrtarif aux_vltarcrs
                 WITH FRAME f_mensal_cecred.
            DOWN WITH FRAME f_mensal_cecred.
        END.

        ASSIGN aux_qtddegps = 0
               aux_vlrtotal = 0
               aux_vltarif1 = 0.
    END.

    IF  LAST-OF(tt-rel.cdcooper) AND glb_cdcooper = 3 THEN DO:
        DISP STREAM str_2 
            tot_qtddegps
            tot_vlrtotal
            tot_vlrtarif
            tot_vltarcrs
            WITH FRAME f_mensal_cecred_totais.
        ASSIGN tot_qtddegps = 0
               tot_vlrtotal = 0
               tot_vlrtarif = 0
               tot_vltarcrs = 0.
    END.

    IF  LINE-COUNTER(str_2) > 84 THEN DO:
        PAGE STREAM str_2.
        IF glb_cdcooper <> 3 THEN VIEW STREAM str_2 FRAME f_cab_mensal.
        ELSE                      VIEW STREAM str_2 FRAME f_cab_mensal_cecred.
    END.
        
END.

IF  glb_cdcooper <> 3 THEN 
    DISP STREAM str_2  
                tot_qtddegps
                tot_vlrtotal
                tot_vlrtarif
                tot_vltarcrs
                WITH FRAME f_mensal_totais.
ELSE 
    DISP STREAM str_2
                totger_qtddegps
                totger_vlrtotal
                totger_vlrtarif
                totger_vltarcrs
                WITH FRAME f_mensal_cecred_total_geral.

OUTPUT STREAM str_2 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "80col"
       glb_nmarqimp = aux_arquivo2
       glb_cdcritic = 0.

RUN fontes/imprim.p.

END. /* fim relatorio mensal */

END. /* has-records*/
/* ============= fim relatorio mensal ============ */


RUN fontes/fimprg.p.
