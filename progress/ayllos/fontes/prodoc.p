{ includes/var_online.i }

DEF VAR tel_dtfluxo AS DATE FORMAT "99/99/9999" LABEL "Dt. Fluxo" NO-UNDO.
DEF VAR aux_diaopca AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_diabase AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_mesbase AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_anobase AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_contado AS INT  FORMAT "zzzzzzz9"                     NO-UNDO.
DEF VAR aux_mesante AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR aux_vlttger AS DEC  FORMAT "zzz,zzz,zz,zzz,zz9.99"        NO-UNDO.
DEF VAR aux_vlmedia AS DEC  FORMAT "zzz,zzz,zz,zzz,zz9.99"        NO-UNDO.
DEF VAR aux_dtproxi AS DATE FORMAT "99/99/9999"                   NO-UNDO.
DEF VAR aux_nrseque AS INT  FORMAT "999999999"                    NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                      NO-UNDO.
DEF VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX          
                             INNER-LINES 10 
                             LABEL "Cooperativa"                  NO-UNDO.

DEF TEMP-TABLE tt-per-datas NO-UNDO 
    FIELD nrsequen AS INTE FORMAT "9999999999"
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

FUNCTION fnRetornaUltimoDiaUtilAno DATE (INPUT par_cdcooper AS INT,
                                         INPUT par_numerano AS INT):

    DEF VAR aux_contador AS INT  INIT 0 NO-UNDO.
    DEF VAR aux_dtverdat AS DATE        NO-UNDO.
    
    ASSIGN aux_dtverdat = DATE(12, 31, par_numerano).
    
    DO WHILE MONTH(aux_dtverdat) = 12:
    
        IF NOT  CAN-DO("1,7",STRING(WEEKDAY(aux_dtverdat))) AND 
           NOT  CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                       crapfer.dtferiad = aux_dtverdat) THEN
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


FUNCTION fnCalculaDiaUtil INTEGER(INPUT par_dtdiames AS INT):
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

FUNCTION fnBuscaLimiteMinimo RETURN INT (INPUT par_dtdiames AS INT):

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

FUNCTION fnBuscaLimiteMaximo RETURN INT (INPUT par_dtdiames AS INT):

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

FUNCTION fnBuscaListaDias RETURN CHAR (INPUT par_dtdiames AS INT):

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

FUNCTION fnBuscaDataDoUltimoDiaMes RETURN DATE (par_dtrefmes AS DATE):
  
    DEF VAR aux_dtcalcul AS DATE   NO-UNDO.
  
    /* Calcular o ultimo dia do mes */
    ASSIGN aux_dtcalcul = ((DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4) -
                            DAY(DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4)).
 
    RETURN aux_dtcalcul.
END. 

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
    IF aux_contador = par_numdiaut THEN
       RETURN DAY(aux_dtverdat).
    ELSE
       RETURN 0.
    
END FUNCTION.

FUNCTION fnRetornaProximaSequencia RETURN INT:

    FIND LAST tt-per-datas NO-LOCK NO-ERROR.
    
    IF AVAIL tt-per-datas THEN
       RETURN  tt-per-datas.nrsequen + 1.
    ELSE
       RETURN  1.

END FUNCTION.


FUNCTION fnEhFeriado RETURN LOG
    
    (par_cdcooper AS INT,
     par_dtrefmes AS DATE):

    RETURN  CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                   crapfer.dtferiad = par_dtrefmes).

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



FUNCTION fnValidaDiasUteisMes RETURN LOGICAL (INPUT par_cdcooper AS INT,
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
           END.
           
        ASSIGN aux_dtverdat = aux_dtverdat + 1.
                
    END. 
    
    RETURN (aux_contador >= 20).

END FUNCTION.

PROCEDURE RegraMediaSegundaFeira:
    
    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_listdias AS CHAR            NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    
    
   
    aux_dtperiod = par_dtmvtolt - 360.
       
    DO WHILE aux_dtperiod < par_dtmvtolt:
       IF  CAN-DO(par_listdias, STRING(DAY(aux_dtperiod))) AND 
           WEEKDAY(aux_dtperiod) = 2 AND 
           fnEhDataUtil(par_cdcooper, aux_dtperiod)  AND
           NOT fnDiaAnteriorEhFeriado(par_cdcooper, aux_dtperiod) THEN
           DO:
              aux_nrseque = fnRetornaProximaSequencia().
              FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod NO-LOCK NO-ERROR.
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.
                    ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                           tt-per-datas.dtmvtolt = aux_dtperiod.
                 END.
           END.
       aux_dtperiod = aux_dtperiod + 1.
     END.
     
END.

PROCEDURE RegraMediaDiaUtilSegundaFeira:
    
    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_numdiaut AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_diaminim AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_diamaxim AS INTE            NO-UNDO.
    
    
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF VAR aux_numdiaut AS INTE FORMAT "99"         NO-UNDO.
    
    
   
    aux_dtperiod = par_dtmvtolt - 360.
    
    DO WHILE aux_dtperiod < par_dtmvtolt:
         
        aux_numdiaut = fnRetornaNumeroDiaUtil(par_cdcooper, 
                                              par_numdiaut, 
                                              aux_dtperiod).

        IF  (WEEKDAY(aux_dtperiod) = 2) AND 
            (DAY(aux_dtperiod) = aux_numdiaut) AND 
            (aux_numdiaut < par_diamaxim) AND
            (aux_numdiaut > par_diaminim) THEN
            DO:
              aux_nrseque = fnRetornaProximaSequencia().
              FIND FIRST tt-per-datas WHERE tt-per-datas.dtmvtolt = aux_dtperiod NO-LOCK NO-ERROR.
              IF NOT AVAIL tt-per-datas THEN
                 DO:
                    CREATE tt-per-datas.
                    ASSIGN tt-per-datas.nrsequen = aux_nrseque 
                           tt-per-datas.dtmvtolt = aux_dtperiod.
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
       AND NOT fnDiaAnteriorEhFeriado(par_cdcooper, par_dtperiod)
       AND ((CAN-DO(par_nrdiasme, "1,2,3") AND fnValidaDiasUteisMes(par_cdcooper, par_dtperiod)) 
         OR (NOT CAN-DO(par_nrdiasme, "1,2,3"))).
    
END FUNCTION.

PROCEDURE RegraMediaDiasUteisDaSemana:

    DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF  INPUT PARAM par_nrdiasse AS CHAR            NO-UNDO.
    DEF  INPUT PARAM par_nrdiasme AS CHAR            NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-per-datas.

    DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
    
    ASSIGN aux_dtperiod = par_dtmvtolt - 360.

    
   
    aux_dtperiod = par_dtmvtolt - 360.

    DO WHILE aux_dtperiod < par_dtmvtolt:
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
                           tt-per-datas.dtmvtolt = aux_dtperiod.
                 END.
           END.
         aux_dtperiod = aux_dtperiod + 1.
    END.

END.


PROCEDURE gera-periodos-projecao:

   DEF  INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-per-datas.

   DEF VAR aux_dtperiod AS DATE FORMAT "99/99/9999" NO-UNDO.
   DEF VAR aux_dtnumdia AS INTE FORMAT "99"         NO-UNDO.
   DEF VAR aux_dtsemdia AS INTE FORMAT "9"          NO-UNDO.
   DEF VAR aux_sequenci AS INTE                     NO-UNDO.


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
    
         
         aux_dtperiod = fnRetornaUltimoDiaUtilAno(par_cdcooper, YEAR(par_dtmvtolt) - 2).   
         
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

   
   ASSIGN aux_dtperiod = par_dtmvtolt - 360
          aux_dtnumdia = DAY(par_dtmvtolt)
          aux_dtsemdia = WEEKDAY(par_dtmvtolt).

   IF fnEhFeriado(par_cdcooper,
                  par_dtmvtolt - 1) THEN
      aux_dtsemdia = 2.
                 
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
                       RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
                                                       INPUT par_dtmvtolt,
                                                       INPUT "3",
                                                       INPUT STRING(DAY(par_dtmvtolt)),
                                                      OUTPUT TABLE tt-per-datas). 
                       FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                       IF (NOT AVAIL tt-per-datas) OR
                          (tt-per-datas.nrsequen < 2) THEN
                       DO:
                           IF aux_dtnumdia = 07 OR
                              aux_dtnumdia = 12 OR
                              aux_dtnumdia = 17 THEN
                           DO:
                              RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
                                                              INPUT par_dtmvtolt,
                                                              INPUT "3",
                                                              INPUT STRING(DAY(par_dtmvtolt - 1)),
                                                             OUTPUT TABLE tt-per-datas). 
                           END.
                           ELSE
                           DO:
                             RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
                                                             INPUT par_dtmvtolt,
                                                             INPUT "3",
                                                             INPUT STRING(DAY(par_dtmvtolt - 1)) + "," + 
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
                               RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
                                                               INPUT par_dtmvtolt,
                                                               INPUT "3,4,5,6",
                                                               INPUT STRING(DAY(par_dtmvtolt)),
                                                               OUTPUT TABLE tt-per-datas). 
                            END.
                        ELSE
                            DO:
                               RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
                                                               INPUT par_dtmvtolt,
                                                               INPUT "4,5,6",
                                                               INPUT STRING(DAY(par_dtmvtolt)),
                                                               OUTPUT TABLE tt-per-datas). 
                            
                            END.

                    END.
             END.
             OTHERWISE
             DO:
               IF ((aux_dtnumdia = 28) OR
                   (aux_dtnumdia = 29)) AND 
                   (fnBuscaDataDoUltimoDiaMes(par_dtmvtolt) = par_dtmvtolt) THEN
                  DO:
                     RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
                                                     INPUT par_dtmvtolt,
                                                     INPUT "3,4,5,6",
                                                     INPUT "30",
                                                     OUTPUT TABLE tt-per-datas). 
                  END.
               ELSE
                  DO:
                    RUN RegraMediaDiasUteisDaSemana(INPUT par_cdcooper,
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
                 RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT "1,2,3",
                                           OUTPUT TABLE tt-per-datas).
              END.
              WHEN 15 THEN
              DO:
                RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT STRING(aux_dtnumdia),
                                           OUTPUT TABLE tt-per-datas).
                FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                IF (NOT AVAIL tt-per-datas) OR
                   (tt-per-datas.nrsequen < 2) THEN
                   DO:
                     RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                INPUT par_dtmvtolt,
                                                INPUT fnBuscaListaDias(aux_dtnumdia),
                                                OUTPUT TABLE tt-per-datas).
                   END.
              END.
              WHEN 21 THEN
              DO:
                RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT "20,21",
                                           OUTPUT TABLE tt-per-datas).
                FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                IF (NOT AVAIL tt-per-datas) OR
                   (tt-per-datas.nrsequen < 2) THEN
                   DO:
                     RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                INPUT par_dtmvtolt,
                                                INPUT fnBuscaListaDias(aux_dtnumdia),
                                                OUTPUT TABLE tt-per-datas).
                   END.
              END.
              WHEN 22 THEN
              DO:
                RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT "20,22",
                                           OUTPUT TABLE tt-per-datas).
                FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                IF (NOT AVAIL tt-per-datas) OR
                   (tt-per-datas.nrsequen < 2) THEN
                   DO:
                     RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
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
                        RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT 30,
                                                   OUTPUT TABLE tt-per-datas).
                        FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                        IF (NOT AVAIL tt-per-datas) OR
                           (tt-per-datas.nrsequen < 2) THEN
                           DO:
                             RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                        INPUT par_dtmvtolt,
                                                        INPUT fnBuscaListaDias(30),
                                                        OUTPUT TABLE tt-per-datas).
                           END.
                     END.
                  ELSE
                     DO:
                        RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                   INPUT par_dtmvtolt,
                                                   INPUT STRING(aux_dtnumdia),
                                                   OUTPUT TABLE tt-per-datas).
                        FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                        IF (NOT AVAIL tt-per-datas) OR
                           (tt-per-datas.nrsequen < 2) THEN
                           DO:
                              RUN RegraMediaDiaUtilSegundaFeira(INPUT par_cdcooper,
                                                                INPUT par_dtmvtolt,
                                                                INPUT fnCalculaDiaUtil(aux_dtnumdia),
                                                                INPUT fnBuscaLimiteMinimo(aux_dtnumdia),
                                                                INPUT fnBuscalimiteMaximo(aux_dtnumdia),
                                                                OUTPUT TABLE tt-per-datas).
                              FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                              IF (NOT AVAIL tt-per-datas) OR
                                 (tt-per-datas.nrsequen < 2) THEN
                                 DO:
                                   RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                              INPUT par_dtmvtolt,
                                                              INPUT fnBuscaListaDias(aux_dtnumdia),
                                                             OUTPUT TABLE tt-per-datas).
                                 END.
                           END.
                     END.
              END.
              WHEN 30 THEN
              DO:
                RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT STRING(aux_dtnumdia),
                                           OUTPUT TABLE tt-per-datas).
                FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                IF (NOT AVAIL tt-per-datas) OR
                   (tt-per-datas.nrsequen < 2) THEN
                   DO:
                     RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                INPUT par_dtmvtolt,
                                                INPUT fnBuscaListaDias(aux_dtnumdia),
                                                OUTPUT TABLE tt-per-datas).
                   END.
              END.
              WHEN 31 THEN
              DO:
                RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT "30,31",
                                           OUTPUT TABLE tt-per-datas).
                FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                IF (NOT AVAIL tt-per-datas) OR
                   (tt-per-datas.nrsequen < 2) THEN
                   DO:
                     RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                INPUT par_dtmvtolt,
                                                INPUT fnBuscaListaDias(aux_dtnumdia),
                                                OUTPUT TABLE tt-per-datas).
                   END.
              END.
              OTHERWISE
              DO:
                RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT STRING(aux_dtnumdia),
                                           OUTPUT TABLE tt-per-datas).
                FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                IF (NOT AVAIL tt-per-datas) OR
                   (tt-per-datas.nrsequen < 2) THEN
                   DO:
                      RUN RegraMediaDiaUtilSegundaFeira(INPUT par_cdcooper,
                                                        INPUT par_dtmvtolt,
                                                        INPUT fnCalculaDiaUtil(aux_dtnumdia),
                                                        INPUT fnBuscaLimiteMinimo(aux_dtnumdia),
                                                        INPUT fnBuscalimiteMaximo(aux_dtnumdia),
                                                        OUTPUT TABLE tt-per-datas).
                      FIND LAST tt-per-datas NO-LOCK NO-ERROR.
                      IF (NOT AVAIL tt-per-datas) OR
                         (tt-per-datas.nrsequen < 2) THEN
                         DO:
                           RUN RegraMediaSegundaFeira(INPUT par_cdcooper,
                                                      INPUT par_dtmvtolt,
                                                      INPUT fnBuscaListaDias(aux_dtnumdia),
                                                     OUTPUT TABLE tt-per-datas).
                         END.
                   END.
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
                              OUTPUT TABLE tt-per-datas).

   LEAVE.

END. 

FUNCTION fnRetornaProximaDataUtil RETURN DATE(par_cdcooper AS INT,
                                              par_dtrefmes AS DATE):

    DEF VAR aux_datautil AS DATE NO-UNDO.

    aux_datautil = par_dtrefmes + 1.
   
    DO WHILE NOT fnEhDataUtil(par_cdcooper, aux_datautil) :
       aux_datautil = aux_datautil + 1.
    END.


    RETURN aux_datautil.
        

END FUNCTION.


aux_contado = 0.
aux_vlttger = 0.
FOR EACH tt-per-datas:
                        
aux_dtproxi = fnRetornaProximaDataUtil(1, tt-per-datas.dtmvtolt).
    
        FOR EACH craplcm WHERE (craplcm.cdcooper = INT(tel_cdcooper)) AND
                               ((craplcm.dtmvtolt = aux_dtproxi) AND 
                               (craplcm.dtrefere <> ?) AND 
                               (craplcm.dtrefere = tt-per-datas.dtmvtolt)) AND 
                               craplcm.cdhistor = 575
                               NO-LOCK:
                                   
                  ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + craplcm.vllanmto.
    
        END.
    
        FOR EACH craplcm WHERE (craplcm.cdcooper = INT(tel_cdcooper))  AND
                               ((craplcm.dtmvtolt = tt-per-datas.dtmvtolt) AND 
                                (craplcm.dtrefere = ?)) AND
                                craplcm.cdhistor = 575
                               NO-LOCK:
                                       
                   ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + craplcm.vllanmto.
                       
        END.
    
        FOR EACH craplcm WHERE (craplcm.cdcooper = INT(tel_cdcooper))  AND
                              ((craplcm.dtmvtolt = tt-per-datas.dtmvtolt) AND 
                              (craplcm.dtrefere <> ?) AND 
                              (craplcm.dtrefere = tt-per-datas.dtmvtolt)) AND
                             craplcm.cdhistor = 575
                            NO-LOCK:
                                   
                 ASSIGN tt-per-datas.vlrtotal = tt-per-datas.vlrtotal + craplcm.vllanmto.
            
        END.
    
    IF  aux_mesante <> MONTH(tt-per-datas.dtmvtolt) THEN
        aux_contado = aux_contado + 1.

    DISP tt-per-datas.dtmvtolt COLUMN-LABEL "Dt. Mvto." 
         tt-per-datas.vlrtotal COLUMN-LABEL "Vl Total" 
         aux_vlmedia  COLUMN-LABEL "Media" 
        WITH DOWN WIDTH 300 FRAME f.
    DOWN WITH FRAME f.

    aux_mesante = MONTH(tt-per-datas.dtmvtolt).
    aux_vlttger = aux_vlttger + tt-per-datas.vlrtotal.
END.

aux_vlmedia = (aux_vlttger  / aux_contado).
/*aux_vlmedia = aux_vlmedia + (aux_vlmedia * 10) / 100*/.

FIND craptab WHERE craptab.cdcooper = INT(tel_cdcooper)       AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 00              AND
                      craptab.cdacesso = "PARFLUXOFINAN" AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF AVAIL craptab THEN
      ASSIGN aux_vlmedia = aux_vlmedia + 
                          ((aux_vlmedia * 
                            DECIMAL(ENTRY(3,craptab.dstextab,";"))) / 100).
                            /*DECIMAL(SUBSTRING(craptab.dstextab,13,5))) / 100).*/


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
        IF  glb_nmdatela <> "PRODOC" THEN
            DO:
              RETURN.
            END.
        ELSE
            NEXT.
    END.
