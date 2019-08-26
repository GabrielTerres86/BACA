{ includes/var_online.i }

DEF VAR tel_dtfluxo AS DATE FORMAT "99/99/9999" LABEL "Dt. Fluxo" NO-UNDO.
DEF VAR aux_diaopca AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_diabase AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_mesbase AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_anobase AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_contado AS INT  FORMAT "zzzzzzz9"                     NO-UNDO.
DEF VAR aux_agruant AS INT  FORMAT "999999999"                    NO-UNDO.
DEF VAR aux_vlttger AS DEC  FORMAT "zzz,zzz,zz,zzz,zz9.99"        NO-UNDO.
DEF VAR aux_vlmedia AS DEC  FORMAT "zzz,zzz,zz,zzz,zz9.99"        NO-UNDO.
DEF VAR aux_nrseque AS INT  FORMAT "999999999"                    NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                      NO-UNDO.
DEF VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX          
                             INNER-LINES 10 
                             LABEL "Cooperativa"                  NO-UNDO.


DEF TEMP-TABLE tt-per-datas NO-UNDO 
    FIELD nrsequen AS INTE FORMAT "9999999999"
    FIELD cdagrupa AS INTE FORMAT "9999999999"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD vlrtotal AS DECI FORMAT "zzz,zzz,zz,zzz,zz9.99"
    INDEX tt-per-datas nrsequen.

FORM tel_dtfluxo  AUTO-RETURN
     tel_cdcooper AUTO-RETURN WITH  FRAME e.

FORM tt-per-datas.dtmvtolt 
     tt-per-datas.vlrtotal WITH FRAME f.



PROCEDURE Busca_Cooperativas:

    DEF OUTPUT PARAM par_nmcooper AS CHAR                           NO-UNDO.

    aux_contado = 0.

    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK BY crapcop.dsdircop:

        IF  aux_contado = 0 THEN
            ASSIGN par_nmcooper = CAPS(crapcop.dsdircop) + "," + STRING(crapcop.cdcooper)
                   aux_contado = 1.
        ELSE
            ASSIGN par_nmcooper = par_nmcooper + "," + CAPS(crapcop.dsdircop)
                                              + "," + STRING(crapcop.cdcooper).

    END. /* FIM FOR EACH crapcop  */   

    RETURN "OK".
    
END PROCEDURE. /* Busca_Cooperativas */



FUNCTION fnEhDataUtil RETURN LOG
    
    (par_cdcooper AS INT,
     par_dtrefmes AS DATE):

    DEF VAR aux_result AS LOG   NO-UNDO.

    IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtrefmes)))    OR
         CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper    AND
                                crapfer.dtferiad = par_dtrefmes)   THEN
                     
         aux_result = FALSE.
     ELSE
         aux_result = TRUE.


    RETURN aux_result.

END FUNCTION.

FUNCTION fnRetornaNumeroDiaUtil INTEGER (INPUT par_cdcooper AS INT,
                                         INPUT par_numdiaut AS INT,
                                         INPUT par_dtdatmes AS DATE):

    DEF VAR aux_contador AS INT  INIT 0 NO-UNDO.
    DEF VAR aux_dtverdat AS DATE        NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(MONTH(par_dtdatmes), 01, YEAR(par_dtdatmes)).
                                                
    DO WHILE MONTH(aux_dtverdat) = MONTH(par_dtdatmes):
    
        IF NOT  CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat))) AND 
           NOT  CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
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

FUNCTION fnEhFeriado RETURN LOG
    
    (par_cdcooper AS INT,
     par_dtrefmes AS DATE):

    RETURN   CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                           crapfer.dtferiad = par_dtrefmes).

    

END FUNCTION.

FUNCTION fnRetornaProximaSequencia RETURN INT:

    FIND LAST tt-per-datas NO-LOCK NO-ERROR.
    
    IF AVAIL tt-per-datas THEN
       RETURN  tt-per-datas.nrsequen + 1.
    ELSE
       RETURN  1.

END FUNCTION.


FUNCTION fnDiaAnteriorEhFeriado RETURN LOG(par_cdcooper AS INT,
                                           par_dtrefmes AS DATE):

    DEF VAR aux_datautil AS DATE NO-UNDO.

    /* Dia anterior */
    aux_datautil = par_dtrefmes - 1.
    
    /* Domingo */
    IF WEEKDAY(aux_datautil) = 1 THEN
       aux_datautil = aux_datautil - 2.
    ELSE
    /* Sabado */ 
    IF WEEKDAY(aux_datautil) = 7 THEN
       aux_datautil = aux_datautil - 1.

    
    RETURN fnEhFeriado(par_cdcooper, aux_datautil).

END FUNCTION.

FUNCTION fnBuscaDataAnteriorFeriado RETURN DATE(INPUT par_cdcooper AS INT,
                                                INPUT par_dtrefmes AS DATE):

    DEF VAR aux_datautil AS DATE NO-UNDO.

    /* Dia anterior */
    aux_datautil = par_dtrefmes - 1.
    
    /* Domingo */
    IF WEEKDAY(aux_datautil) = 1 THEN
       aux_datautil = aux_datautil - 2.
    ELSE
    /* Sabado */ 
    IF WEEKDAY(aux_datautil) = 7 THEN
       aux_datautil = aux_datautil - 1.

    
   IF fnEhFeriado(par_cdcooper, aux_datautil) THEN
      RETURN aux_datautil.
   ELSE
      RETURN ?.

END FUNCTION.

PROCEDURE RegraMediaSegundaFeira:
    
    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_listdias AS CHAR            NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    
    aux_dtperiod = par_dtmvtolt - 360.
    
    DO WHILE aux_dtperiod < par_dtmvtolt:
       IF  CAN-DO(par_listdias, STRING(DAY(aux_dtperiod)))
       AND WEEKDAY(aux_dtperiod) = 2
       AND fnEhDataUtil(par_cdcooper, aux_dtperiod) 
       AND NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod) THEN
           DO:
              aux_nrseque = fnRetornaProximaSequencia().
              FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod NO-LOCK NO-ERROR.
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.
                    ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                           tt-per-datas.dtmvtolt = aux_dtperiod
                           tt-per-datas.cdagrupa = par_cdagrupa.
                 END.
           END.
       aux_dtperiod = aux_dtperiod + 1.
     END.
     
END.

PROCEDURE RegraMediaPrimeiroDiaUtilSegundaFeira:
    
    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    
   
    aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:
        IF  ((WEEKDAY(aux_dtperiod) = 2) AND 
             (DAY(aux_dtperiod) = fnRetornaNumeroDiaUtil(par_cdcooper, 1, aux_dtperiod))) AND
            NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod) THEN
            DO:
              aux_nrseque = fnRetornaProximaSequencia().
              FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod NO-LOCK NO-ERROR.
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.
                    ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                           tt-per-datas.dtmvtolt = aux_dtperiod
                           tt-per-datas.cdagrupa = par_cdagrupa.
                 END.
            END.
        aux_dtperiod = aux_dtperiod + 1.
    END.


END.

FUNCTION fnValidaRegraMediaDiasUteisDaSemana RETURN LOG(INPUT par_nrdiasme AS CHAR,
                                                        INPUT par_nrdiasse AS CHAR,
                                                        INPUT par_dtperiod AS DATE,
                                                        INPUT par_cdcooper AS INTE):
    
    RETURN CAN-DO(par_nrdiasme, STRING(DAY(par_dtperiod)))
       AND CAN-DO(par_nrdiasse, STRING(WEEKDAY(par_dtperiod)))
       AND fnEhDataUtil(par_cdcooper, par_dtperiod) 
       AND NOT fnDiaAnteriorEhFeriado(par_cdcooper, par_dtperiod).
    
END FUNCTION.

PROCEDURE RegraMediaDiasUteisDaSemana:

    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_nrdiasse AS CHAR            NO-UNDO.
    DEF  INPUT PARAM par_nrdiasme AS CHAR            NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE            NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
    
    aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:
        IF (NUM-ENTRIES(par_nrdiasme) = 2) THEN
           DO:
                IF  fnValidaRegraMediaDiasUteisDaSemana(INPUT par_nrdiasme,
                                                        INPUT par_nrdiasse,
                                                        INPUT aux_dtperiod,
                                                        INPUT par_cdcooper) 
                
                AND (fnValidaRegraMediaDiasUteisDaSemana(INPUT par_nrdiasme,
                                                         INPUT par_nrdiasse,
                                                         INPUT aux_dtperiod + 1,
                                                         INPUT par_cdcooper)) THEN
                    DO:
                       aux_nrseque = fnRetornaProximaSequencia().
                       FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod NO-LOCK NO-ERROR.
                       IF NOT AVAIL tt-per-datas THEN
                          DO:
                             CREATE tt-per-datas.
                             ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                                    tt-per-datas.dtmvtolt = aux_dtperiod
                                    tt-per-datas.cdagrupa = par_cdagrupa.
                          END.

                       aux_nrseque = fnRetornaProximaSequencia().
                       FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod + 1 NO-LOCK NO-ERROR.
                      IF NOT AVAIL tt-per-datas THEN
                         DO:
                            CREATE tt-per-datas.
                            ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                                   tt-per-datas.dtmvtolt = aux_dtperiod + 1
                                   tt-per-datas.cdagrupa = par_cdagrupa.
                         END.
                    END.
           END.
         ELSE
           IF  fnValidaRegraMediaDiasUteisDaSemana(INPUT par_nrdiasme,
                                                   INPUT par_nrdiasse,
                                                   INPUT aux_dtperiod,
                                                   INPUT par_cdcooper) THEN
           
               DO:
                  aux_nrseque = fnRetornaProximaSequencia().
                  FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod NO-LOCK NO-ERROR.
                  IF NOT AVAIL tt-per-datas THEN
                     DO:
                        CREATE tt-per-datas.
                        ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                               tt-per-datas.dtmvtolt = aux_dtperiod
                               tt-per-datas.cdagrupa = par_cdagrupa.
                     END.
               END.

         aux_dtperiod = aux_dtperiod + 1.
    END.

END.

FUNCTION fnDataExiste RETURN LOG (par_mes AS INT,
                                  par_dia AS INT,
                                  par_ano AS INT) : 
   
  DEF VAR aux_dtcalcul AS DATE INIT ? NO-UNDO.
  
  DO ON ERROR UNDO, LEAVE:

     aux_dtcalcul = DATE(par_mes, par_dia, par_ano).
  
     CATCH eAnyError AS Progress.Lang.ERROR:
           aux_dtcalcul = ?.
           DELETE OBJECT eAnyError.
     END CATCH.
  END.

  RETURN (aux_dtcalcul <> ?).

END FUNCTION.


PROCEDURE gera-periodos-projecao:

   DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
   DEF  INPUT PARAM par_cdagrupa AS INT             NO-UNDO.
   
   
   DEF OUTPUT PARAM TABLE FOR tt-per-datas.

   DEF VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
   DEF VAR aux_dtsemdia AS INTE FORMAT "9"          NO-UNDO.
   DEF VAR aux_listadia AS CHAR                     NO-UNDO.

   EMPTY TEMP-TABLE tt-per-datas. 

   IF fnDiaAnteriorEhFeriado(par_cdcooper, par_dtmvtolt) THEN
      DO:
        RUN gera-periodos-projecao(INPUT par_cdcooper, 
                                   INPUT fnBuscaDataAnteriorFeriado(par_cdcooper, par_dtmvtolt),
                                   INPUT par_cdagrupa + 1,
                                  OUTPUT TABLE tt-per-datas).
      END.
   
   ASSIGN aux_dtnumdia = DAY(par_dtmvtolt)
          aux_dtsemdia = WEEKDAY(par_dtmvtolt).

   IF (aux_dtsemdia <> 2) THEN
      DO:
         ASSIGN aux_listadia = STRING(DAY(par_dtmvtolt)).
         
         /*ELSE
            ASSIGN aux_listadia = STRING(DAY(par_dtmvtolt)) + "," + 
                                  STRING(DAY(par_dtmvtolt - 1)).  */

         RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
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
                RUN RegraMediaPrimeiroDiaUtilSegundaFeira(INPUT par_cdcooper,
                                                          INPUT par_dtmvtolt,
                                                          INPUT par_cdagrupa,
                                                          OUTPUT TABLE tt-per-datas).
              END.
              WHEN 4 THEN
              DO:
                  RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT STRING(aux_dtnumdia),
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
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
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "5,6,7",
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
              END.
              WHEN 8  OR
              WHEN 9  THEN
              DO:
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT STRING(aux_dtnumdia),
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
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
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "10,11,12",
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).

              END.
              WHEN 13 OR
              WHEN 14 THEN
              DO:
                  RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT STRING(aux_dtnumdia),
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
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
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "15,16,17",
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
              END.
              WHEN 18 OR
              WHEN 19 THEN
              DO:
                  RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT STRING(aux_dtnumdia),
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
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
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "20,21,22",
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
              END.
              WHEN 23 OR
              WHEN 24 THEN
              DO:
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT STRING(aux_dtnumdia),
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
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
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "25,26,27",
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
              END.
              WHEN 28 OR
              WHEN 29 THEN
              DO:
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT STRING(aux_dtnumdia),
                                            INPUT par_cdagrupa,
                                            OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "28,29",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).
                     END.
              END.
              WHEN 30 THEN
              DO:
                  RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT STRING(aux_dtnumdia),
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
                 
                  FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                  IF (NOT AVAIL tt-per-datas) OR
                     (tt-per-datas.nrsequen < 2) THEN
                     DO:
                       
                       RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT "30,31",
                                                  INPUT par_cdagrupa,
                                                  OUTPUT TABLE tt-per-datas).
                     END.
              END.
              WHEN 31 THEN
              DO:
                  RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT "30,31",
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
              END.
              OTHERWISE
              DO:
                  RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT STRING(aux_dtnumdia),
                                             INPUT par_cdagrupa,
                                             OUTPUT TABLE tt-per-datas).
              END.
         END CASE.
      END.
END.


RUN Busca_Cooperativas(OUTPUT aux_nmcooper).

tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

ON RETURN OF tel_cdcooper  IN FRAME e
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
              
       APPLY "GO".
   END.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 

   UPDATE tel_dtfluxo tel_cdcooper WITH FRAME e.
    
   RUN gera-periodos-projecao(INPUT 1, 
                              INPUT tel_dtfluxo,
                              INPUT 1,
                              OUTPUT TABLE tt-per-datas).

   LEAVE.

END.   

aux_contado = 0.
aux_vlttger = 0.
aux_vlmedia = 0.

FOR EACH tt-per-datas WHERE tt-per-datas.dtmvtolt >= 09/01/2011 BREAK BY tt-per-datas.cdagrupa:
                        
    
    FOR EACH craplcm WHERE craplcm.cdcooper = INT(tel_cdcooper)
                       AND craplcm.cdhistor = 977
                       AND craplcm.dtmvtolt = tt-per-datas.dtmvtolt 
                       NO-LOCK:
        
        ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + craplcm.vllanmto.
    
    END.

    DISP tt-per-datas.cdagrupa COLUMN-LABEL "Agrupa"
         tt-per-datas.dtmvtolt COLUMN-LABEL "Dt. Mvto." 
         tt-per-datas.vlrtotal COLUMN-LABEL "Vl Total" 
         aux_vlmedia  COLUMN-LABEL "Media" 
        WITH DOWN WIDTH 300 FRAME f.
    DOWN WITH FRAME f.

    aux_vlttger = aux_vlttger + tt-per-datas.vlrtotal.
    aux_contado = aux_contado + 1.

    IF LAST-OF(tt-per-datas.cdagrupa) THEN
       DO:
         aux_vlmedia = aux_vlmedia  + (aux_vlttger  / aux_contado).
         aux_vlttger = 0.
         aux_contado = 0.
       END.

END.


/*aux_vlmedia = aux_vlmedia + (aux_vlmedia * 10) / 100.*/
                  
FIND craptab WHERE craptab.cdcooper = INT(tel_cdcooper)        AND
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "GENERI"         AND
                      craptab.cdempres = 00               AND
                      craptab.cdacesso = "PARFLUXOFINAN"  AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF AVAIL craptab THEN
      ASSIGN aux_vlmedia = aux_vlmedia + 
                          ((aux_vlmedia * 
                            DECIMAL(ENTRY(3,craptab.dstextab,";"))) / 100).
                            

DISP aux_contado @ tt-per-datas.dtmvtolt
     aux_vlttger @ tt-per-datas.vlrtotal
     aux_vlmedia 
    WITH DOWN WIDTH 300 FRAME f.
    DOWN WITH FRAME f.




IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    /*   F4 OU FIM   */
    DO:
        CLEAR FRAME f ALL NO-PAUSE.
        CLEAR FRAME e ALL NO-PAUSE.
        HIDE FRAME f.
        HIDE FRAME e.
        RUN fontes/novatela.p.
        IF  glb_nmdatela <> "PROTIT" THEN
            DO:
              CLEAR FRAME f ALL NO-PAUSE.
              HIDE FRAME f.
              RETURN.
            END.
        ELSE
            NEXT.
    END.
