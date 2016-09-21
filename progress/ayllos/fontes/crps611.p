/* ...........................................................................

   Programa: Fontes/crps611.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Oscar A. Junior
   Data    : Setembro/2011.                     Ultima atualizacao: 27/02/2014

   Dados referentes ao programa:

   Frequencia: Mensal
   Objetivo  : Gerar relatorio de pre exigibilidade 612
   
   Ultimas alteracoes:  25/10/2011 - Realizado a geracao do relatorio crrl612
                                     (Adriano).
                                     
                        06/12/2011 - Inserido o "NEW" na linha relativa ao
                                     include do arquivo var_batch.i (Lucas).
                                     
                        02/08/2012 - Ajuste do format no campo nmrescop 
                                     (David Kruger).
                                     
   27/02/2014 - Mudancas nos formats para comportar o aumento do nome resumido
                das cooperativas para 20 chars (Carlos)
                
   ........................................................................ */


{ includes/var_batch.i "NEW"}

DEF VAR aux_fill     AS CHAR FORMAT "x(132)"                         
                     EXTENT 3                                        NO-UNDO.
DEF VAR aux_vlpredep AS DEC FORMAT "->,>>>,>>>,>>>,>>9.99"     
                     EXTENT 5                                        NO-UNDO. 
DEF VAR aux_vltotcre AS DEC FORMAT "->,>>>,>>>,>>>,>>9.99"     
                     EXTENT 5                                        NO-UNDO.
DEF VAR aux_vltotcal AS DEC FORMAT "->,>>>,>>>,>>>,>>9.99"     
                     EXTENT 10                                       NO-UNDO.
DEF VAR aux_vlbascal AS DEC FORMAT "->,>>>,>>>,>>>,>>9.99"     
                     EXTENT 10                                       NO-UNDO.
                                                                     
DEF VAR aux_dtcalcul AS DATE EXTENT 10                               NO-UNDO.
DEF VAR aux_dtiniper AS DATE EXTENT 5                                NO-UNDO.
DEF VAR aux_dtfimper AS DATE EXTENT 5                                NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.                                                                     
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_flgdispl AS LOG                                          NO-UNDO.

DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                          NO-UNDO.
DEF VAR rel_nmresemp AS CHAR FORMAT "x(15)"                          NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                 NO-UNDO.
DEF VAR rel_nrmodulo AS INT  FORMAT "9"                              NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5           
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                   "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]                NO-UNDO.

DEF TEMP-TABLE tt-calculo NO-UNDO
    FIELD idexigib AS INT  
    FIELD cdcooper AS INT
    FIELD dtcalcul AS DATE FORMAT "99/99/9999"
    FIELD vlbascal AS DEC  FORMAT "->>>,>>>,>>>,>>>,>>9.99"
    INDEX tt-calculo  idexigib dtcalcul cdcooper.

DEF TEMP-TABLE tt-exigib NO-UNDO
    FIELD idexigib AS INT
    FIELD cdcooper AS INT
    FIELD nrperiod AS INT
    FIELD dtiniper AS DATE FORMAT "99/99/9999"
    FIELD dtfimper AS DATE FORMAT "99/99/9999"
    FIELD vlpredep AS DEC  FORMAT "->>>,>>>,>>>,>>>,>>9.99"
    INDEX tt-exigib1 idexigib dtiniper dtfimper cdcooper nrperiod
    INDEX tt-exigib2 dtiniper dtfimper cdcooper nrperiod idexigib.


DEF  BUFFER b-tt-exigib1  FOR tt-exigib.
DEF  BUFFER b-tt-calculo1 FOR tt-calculo.

DEF STREAM str_1.


FORM "PRE EXIGIBILIDADE" AT 54
     SKIP
     aux_fill[1]
     SKIP
     "PERIODO EXIGIBILIDADE"
     aux_dtiniper[1]     AT 37
     aux_dtiniper[2]     AT 59
     aux_dtiniper[3]     AT 81
     aux_dtiniper[4]     AT 103
     aux_dtiniper[5]     AT 125
     SKIP               
     "ATE"               AT 39
     "ATE"               AT 61
     "ATE"               AT 83
     "ATE"               AT 105
     "ATE"               AT 127
     SKIP               
     aux_dtfimper[1]     AT 37 
     aux_dtfimper[2]     AT 59 
     aux_dtfimper[3]     AT 81 
     aux_dtfimper[4]     AT 103
     aux_dtfimper[5]     AT 125
     SKIP
     aux_fill[2]
     SKIP
     "COOPERATIVA"
     SKIP
     aux_fill[3]
     SKIP
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_exigibilidade.
     
FORM crapcop.nmrescop FORMAT "X(20)"
     aux_vlpredep[1]     AT 24
     aux_vlpredep[2] 
     aux_vlpredep[3] 
     aux_vlpredep[4] 
     aux_vlpredep[5]
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_exigibilidade.

FORM SKIP
     aux_fill[1]
     SKIP
     "TOTAL CECRED"
     aux_vltotcre[1]     AT 24
     aux_vltotcre[2]
     aux_vltotcre[3]
     aux_vltotcre[4]
     aux_vltotcre[5]
     SKIP
     aux_fill[2]
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_tot_exigibilidade.

FORM aux_fill[1]
     "BASE DE CALCULO DO PERIODO EXIGIBILIDADE" AT 30
     tt-exigib.dtiniper
     " ATE "           
     tt-exigib.dtfimper
     SKIP
     aux_fill[2]
     SKIP
     "PERIODO DE CALCULO"
     aux_dtcalcul[1]  FORMAT "99/99/9999"       AT 35
     aux_dtcalcul[2]  FORMAT "99/99/9999"       AT 57
     aux_dtcalcul[3]  FORMAT "99/99/9999"       AT 79
     aux_dtcalcul[4]  FORMAT "99/99/9999"       AT 101
     aux_dtcalcul[5]  FORMAT "99/99/9999"       AT 123
     SKIP
     aux_fill[3]
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_calculo.

FORM aux_fill[1]
     SKIP
     "PERIODO DE CALCULO"
     aux_dtcalcul[6]  FORMAT "99/99/9999"       AT 35
     aux_dtcalcul[7]  FORMAT "99/99/9999"       AT 57
     aux_dtcalcul[8]  FORMAT "99/99/9999"       AT 79
     aux_dtcalcul[9]  FORMAT "99/99/9999"       AT 101
     aux_dtcalcul[10] FORMAT "99/99/9999"       AT 123
     SKIP
     aux_fill[2]
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_calculo_2.

FORM crapcop.nmrescop FORMAT "X(20)"
     aux_vlbascal[1] AT 24
     aux_vlbascal[2] 
     aux_vlbascal[3] 
     aux_vlbascal[4] 
     aux_vlbascal[5]
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_calculo.

FORM crapcop.nmrescop  FORMAT "X(20)"
     aux_vlbascal[6] AT 24
     aux_vlbascal[7] 
     aux_vlbascal[8] 
     aux_vlbascal[9] 
     aux_vlbascal[10]
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_calculo_2.

FORM aux_fill[1]
     SKIP
     "TOTAL CECRED"
     aux_vltotcal[1] AT 24
     aux_vltotcal[2]
     aux_vltotcal[3]
     aux_vltotcal[4]
     aux_vltotcal[5]
     SKIP
     aux_fill[2]
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_tot_calculo.

FORM aux_fill[1]
     SKIP
     "TOTAL CECRED"
     aux_vltotcal[6] AT 24
     aux_vltotcal[7]
     aux_vltotcal[8]
     aux_vltotcal[9]
     aux_vltotcal[10]
     SKIP
     aux_fill[2]
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_tot_calculo_2.



FUNCTION fget_proxiseq RETURNS INT(INPUT TABLE FOR tt-exigib):

  FIND LAST tt-exigib 
            NO-LOCK NO-ERROR.
  
  IF AVAIL(tt-exigib) THEN
     RETURN tt-exigib.idexigib + 1.
  ELSE
     RETURN 1.
  
END FUNCTION.    


/* Valor total compensação dos cheques do banco 085 que veio dos outros
   bancos com valor maior ou igual a R$ 5000. */
FUNCTION fgte_vlrdcomp RETURNS DEC(INPUT par_cdcooper AS INT, 
                                   INPUT par_dtmvtolt AS DATE):
    
   DEF VAR aux_vlrttsom AS DEC                          NO-UNDO.
   DEF VAR aux_vlrttsub AS DEC                          NO-UNDO.
   DEF VAR aux_cdbanchq AS INT                          NO-UNDO.
   DEF VAR aux_vlminimo AS DEC                          NO-UNDO.
   DEF VAR aux_vlmaximo AS DEC                          NO-UNDO.

   ASSIGN aux_vlrttsom = 0
          aux_vlrttsub = 0
          aux_cdbanchq = 85
          aux_vlminimo = 5000
          aux_vlmaximo = 250000.

   FOR EACH gncpchq WHERE (gncpchq.cdcooper = par_cdcooper)                AND
                          (gncpchq.cdtipreg = 3                            OR
                           gncpchq.cdtipreg = 4)                           AND
                          (gncpchq.dtmvtolt = par_dtmvtolt)                AND 
                          (gncpchq.cdbanchq = aux_cdbanchq)                AND
                          (gncpchq.vlcheque >= aux_vlminimo)               AND
                          (gncpchq.vlcheque < aux_vlmaximo)                AND
                          (INT(SUBSTRING (gncpchq.dsidenti, 56, 3)) <> 85)
                           NO-LOCK:
        
       ASSIGN aux_vlrttsom = aux_vlrttsom + gncpchq.vlcheque.
            
   END.
       
   FOR EACH gncpdev WHERE (gncpdev.cdcooper = par_cdcooper)  AND
                          (gncpdev.dtliquid = par_dtmvtolt)  AND
                          (gncpdev.cdtipreg = 2)             AND
                          (gncpdev.cdalinea = 20             OR
                           gncpdev.cdalinea = 24             OR
                           gncpdev.cdalinea = 25             OR
                           gncpdev.cdalinea = 30)            AND
                          (gncpdev.vlcheque >= aux_vlminimo) AND
                          (gncpdev.vlcheque < aux_vlmaximo)  AND
                          (gncpdev.cdbanchq = aux_cdbanchq)
                           NO-LOCK:
                  
       ASSIGN aux_vlrttsub = aux_vlrttsub + gncpdev.vlcheque.
        
   END.
  
   RETURN aux_vlrttsom - aux_vlrttsub.


END FUNCTION.

PROCEDURE calc_total_central:

  DEF INPUT-OUTPUT PARAM TABLE FOR tt-exigib.
  DEF INPUT-OUTPUT PARAM TABLE FOR tt-calculo.
  DEF INPUT-OUTPUT PARAM TABLE FOR b-tt-exigib1.
  DEF INPUT-OUTPUT PARAM TABLE FOR b-tt-calculo1.

  DEF VAR aux_vlttexig AS DEC                                 NO-UNDO.
  DEF VAR aux_vlttcalc AS DEC                                 NO-UNDO.

  ASSIGN aux_vlttexig = 0
         aux_vlttcalc = 0.

  FOR EACH tt-exigib WHERE tt-exigib.cdcooper = 3
                           NO-LOCK:
  
      ASSIGN aux_vlttexig = 0.
  
      FOR EACH b-tt-exigib1 WHERE b-tt-exigib1.dtiniper = tt-exigib.dtiniper AND
                                  b-tt-exigib1.dtfimper = tt-exigib.dtfimper AND
                                  b-tt-exigib1.cdcooper <> 3
                                  NO-LOCK:
                                         
          ASSIGN aux_vlttexig = aux_vlttexig + b-tt-exigib1.vlpredep.
      
      END.
  
      ASSIGN tt-exigib.vlpredep = aux_vlttexig. 

      FOR EACH tt-calculo WHERE tt-calculo.idexigib = tt-exigib.idexigib
                                NO-LOCK:
      
          ASSIGN aux_vlttcalc = 0.
      
          FOR EACH b-tt-calculo1 
                        WHERE b-tt-calculo1.dtcalcul = tt-calculo.dtcalcul AND 
                              b-tt-calculo1.cdcooper <> 3 
                              NO-LOCK BREAK BY b-tt-calculo1.cdcooper:
           
              IF LAST-OF(b-tt-calculo1.cdcooper) THEN                       
                 ASSIGN  aux_vlttcalc = aux_vlttcalc + b-tt-calculo1.vlbascal.
             
          END.
      
          ASSIGN  tt-calculo.vlbascal = aux_vlttcalc 
                  aux_vlttcalc = 0.
                           
      END.

  END.


END PROCEDURE.


PROCEDURE calc_periodo_calc_mes:

    DEF INPUT PARAM par_dtiniexi  AS DATE                      NO-UNDO.
    DEF INPUT PARAM par_idexigib  AS INT                       NO-UNDO.
    DEF INPUT PARAM par_cdcooper  AS INT                       NO-UNDO.
                                                              
    DEF OUTPUT PARAM TABLE FOR tt-calculo.                
    DEF OUTPUT PARAM par_vlrmedia AS DEC                       NO-UNDO.

    DEF VAR aux_dtiniper AS DATE                               NO-UNDO.
    DEF VAR aux_diaseman AS INT                                NO-UNDO.
    DEF VAR aux_dialimit AS INT                                NO-UNDO.
    DEF VAR aux_diauteis AS INT                                NO-UNDO.
    DEF VAR aux_vlrdcomp AS DEC                                NO-UNDO.
    DEF VAR aux_vlrdsoma AS DEC                                NO-UNDO.
    
    /* Inicializa variaveis */
    ASSIGN aux_dtiniper = par_dtiniexi - 1 
           aux_diaseman = WEEKDAY (aux_dtiniper)
           aux_dialimit = 0
           aux_diauteis = 0
           aux_vlrdcomp = 0
           aux_vlrdsoma = 0.
    
    /* Procura a primeira quarta feira antes do periodo de exigibilidade
       para descobrir o ultimo dia para calculo */
    DO WHILE aux_diaseman <> 4:

       ASSIGN aux_dtiniper = aux_dtiniper - 1
              aux_diaseman = WEEKDAY (aux_dtiniper).

    END.
    
    /* Ultimo dia do periodo de calculo */
    ASSIGN aux_dtiniper = aux_dtiniper - 1.
    
    /* Procurar os dias que entram no periodo de calculo 
       fim de semana e feriados não entra no calculo mas 
       contam nos dias. */
    DO aux_dialimit = 14 TO 1 BY -1:

       /* Qual dia da semana */
       aux_diaseman = WEEKDAY(aux_dtiniper).
       
       /* Ver se é feriado */
       FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND 
                          crapfer.dtferiad = aux_dtiniper 
                          NO-LOCK NO-ERROR.
                          
       /* Se nao for sabado ou domingo ou feriado entao o dia entra 
          no calculo */
       IF ((NOT AVAIL crapfer)          AND  
          (WEEKDAY(aux_dtiniper) <> 7)  AND  /* SABADO */  
          (WEEKDAY(aux_dtiniper) <> 1)) THEN /* DOMINGO */
          DO:
             ASSIGN aux_diauteis = aux_diauteis + 1
                    aux_vlrdcomp = fgte_vlrdcomp(par_cdcooper, aux_dtiniper).  
            
             CREATE tt-calculo.
             
             ASSIGN tt-calculo.dtcalcul = aux_dtiniper
                    tt-calculo.cdcooper = par_cdcooper
                    tt-calculo.idexigib = par_idexigib
                    tt-calculo.vlbascal = aux_vlrdcomp.
             
             ASSIGN aux_vlrdsoma = aux_vlrdsoma + tt-calculo.vlbascal.
             
          END.
        
       /* Próximo dia */
       ASSIGN aux_dtiniper = aux_dtiniper - 1.
        
    END.
    
    par_vlrmedia = aux_vlrdsoma / aux_diauteis. 
    
END PROCEDURE.
    
PROCEDURE calc_periodo_exig_mes:

    DEF INPUT PARAM par_anoexigi AS INT                        NO-UNDO.
    DEF INPUT PARAM par_mesexigi AS INT                        NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INT                        NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-exigib.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-calculo.
   
    DEF VAR aux_dtinimes AS DATE                               NO-UNDO.
    DEF VAR aux_diaseman AS INT                                NO-UNDO.
    DEF VAR aux_dtiniexi AS DATE                               NO-UNDO.
    DEF VAR aux_dtfimexi AS DATE                               NO-UNDO.
    DEF VAR aux_nrperiod AS INT                                NO-UNDO.
    DEF VAR aux_nrsequen AS INT                                NO-UNDO.
    DEF VAR aux_vlrmedia AS DEC                                NO-UNDO.
    
    
    ASSIGN aux_dtinimes = DATE(par_mesexigi, 1, par_anoexigi) 
           aux_diaseman = WEEKDAY(aux_dtinimes)
           aux_dtiniexi = ?
           aux_dtfimexi = ?
           aux_nrperiod = 0
           aux_nrsequen = 0
           aux_vlrmedia = 0.
    
    /* O periodo de exigibilidade é valido durante uma semana e começa na
       segunda, quando o primeiro dia do mes em questão não for uma segunda
       então o periodo de exigibilidade começo no mês anterior */
    IF aux_diaseman <> 2 THEN /* Segunda */
       DO:
          /* Buscar a data de inicio do primeiro periodo de exigibilidade 
             pois a mesma começou no mes anterior */
          DO WHILE aux_diaseman <> 2:

             ASSIGN aux_dtinimes = aux_dtinimes - 1
                    aux_diaseman = WEEKDAY(aux_dtinimes).
         
          END.
          
       END.
    
    /* Data de inicio e fim do primeiro periodo de exigibilidade, 
       começa na segunda e termina na sexta da mesma semana */
    ASSIGN aux_dtiniexi = aux_dtinimes
           aux_dtfimexi = aux_dtinimes + 4.
   
    ASSIGN aux_nrsequen = fget_proxiseq(INPUT TABLE tt-exigib). 
                 
                              
    /* Cria registro do primeiro periodo de exigibilidade */ 
    CREATE tt-exigib.
    
    ASSIGN tt-exigib.idexigib = aux_nrsequen
           tt-exigib.cdcooper = par_cdcooper
           tt-exigib.nrperiod = 1 /* Primeiro periodo */
           tt-exigib.dtiniper = aux_dtiniexi
           tt-exigib.vlpredep = 0
           tt-exigib.dtfimper = aux_dtfimexi.
           
    /* Cria registro filhos com os dias para calculo do periodo
       de exigibilidade */
    RUN calc_periodo_calc_mes(INPUT aux_dtiniexi, 
                              INPUT aux_nrsequen, 
                              INPUT par_cdcooper, 
                              OUTPUT TABLE tt-calculo,
                              OUTPUT aux_vlrmedia).
                               
    ASSIGN tt-exigib.vlpredep = aux_vlrmedia.          
    
    /* Calcula as datas de inicio e fim dos demais periodos de exigibilidade */
    DO aux_nrperiod = 2 TO 5 BY 1:
         
       ASSIGN aux_dtiniexi = aux_dtfimexi + 3  /* Próxima segunda */
              aux_dtfimexi = aux_dtiniexi + 4  /* Próxima sexta */
              aux_nrsequen = fget_proxiseq(INPUT TABLE tt-exigib).  
                                               /* Próximo sequencia */
    
       CREATE tt-exigib.
       
       ASSIGN tt-exigib.idexigib = aux_nrsequen 
              tt-exigib.cdcooper = par_cdcooper
              tt-exigib.nrperiod = aux_nrperiod /* Proximo periodo */
              tt-exigib.dtiniper = aux_dtiniexi
              tt-exigib.vlpredep = 0
              tt-exigib.dtfimper = aux_dtfimexi.
              
       /* Cria registro filhos com os dias para calculo do periodo
          de exigibilidade */
       RUN calc_periodo_calc_mes(INPUT aux_dtiniexi, 
                                 INPUT aux_nrsequen, 
                                 INPUT par_cdcooper, 
                                 OUTPUT TABLE tt-calculo,
                                 OUTPUT aux_vlrmedia).
       
       ASSIGN tt-exigib.vlpredep = aux_vlrmedia.
                                                                       
    END.

END PROCEDURE.    
   

PROCEDURE rel_exig_pre_deposito:

    DEF INPUT PARAM par_anoexigi  AS INT                     NO-UNDO.
    DEF INPUT PARAM par_mesexigi  AS INT                     NO-UNDO. 
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-exigib.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-calculo.
    DEF INPUT-OUTPUT PARAM TABLE FOR b-tt-exigib1.
    DEF INPUT-OUTPUT PARAM TABLE FOR b-tt-calculo1.
     
    EMPTY TEMP-TABLE tt-exigib.
    EMPTY TEMP-TABLE tt-calculo.
    EMPTY TEMP-TABLE b-tt-exigib1.
    EMPTY TEMP-TABLE b-tt-calculo1.
    
    FOR EACH crapcop NO-LOCK:

        RUN calc_periodo_exig_mes(INPUT par_anoexigi, 
                                  INPUT par_mesexigi, 
                                  INPUT crapcop.cdcooper, 
                                  INPUT-OUTPUT TABLE tt-exigib, 
                                  INPUT-OUTPUT TABLE tt-calculo).
    END.

    RUN calc_total_central(INPUT-OUTPUT TABLE tt-exigib, 
                           INPUT-OUTPUT TABLE tt-calculo,
                           INPUT-OUTPUT TABLE b-tt-exigib1,
                           INPUT-OUTPUT TABLE b-tt-calculo1).

                        
END PROCEDURE.


ASSIGN glb_cdprogra = "crps611"
       aux_flgdispl = FALSE
       aux_fill[1] = FILL("-",132)
       aux_fill[2] = FILL("-",132)
       aux_fill[3] = FILL("-",132).

RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
   RETURN.

RUN rel_exig_pre_deposito(INPUT DATE(YEAR(glb_dtmvtolt)),
                          INPUT DATE(MONTH(glb_dtmvtolt)), 
                          INPUT-OUTPUT TABLE tt-exigib, 
                          INPUT-OUTPUT TABLE tt-calculo,
                          INPUT-OUTPUT TABLE b-tt-exigib1,
                          INPUT-OUTPUT TABLE b-tt-calculo1).

{ includes/cabrel132_1.i}

OUTPUT STREAM str_1 TO rl/crrl612.lst PAGED PAGE-SIZE 80.


VIEW STREAM str_1 FRAME f_cabrel132_1.

/* Gera o resumo de PRE EXIGIBILIDADE */
FOR EACH crapcop NO-LOCK:

    DO aux_contador = 1 TO 5:

       ASSIGN aux_dtiniper[aux_contador] = ?
              aux_dtfimper[aux_contador] = ?
              aux_vlpredep[aux_contador] = 0.

    END.
    
   FOR EACH tt-exigib WHERE tt-exigib.cdcooper = crapcop.cdcooper 
                            NO-LOCK:
    
       ASSIGN aux_vlpredep[tt-exigib.nrperiod] = tt-exigib.vlpredep
              aux_dtiniper[tt-exigib.nrperiod] = tt-exigib.dtiniper
              aux_dtfimper[tt-exigib.nrperiod] = tt-exigib.dtfimper.
               
        IF tt-exigib.cdcooper = 3 THEN
           aux_vltotcre[tt-exigib.nrperiod] = tt-exigib.vlpredep.
                 

   END.
        

   IF aux_flgdispl = FALSE THEN
      DISP STREAM str_1 aux_dtiniper[1]
                        aux_dtiniper[2]
                        aux_dtiniper[3]
                        aux_dtiniper[4]
                        aux_dtiniper[5]
                        aux_dtfimper[1]
                        aux_dtfimper[2]
                        aux_dtfimper[3]
                        aux_dtfimper[4]
                        aux_dtfimper[5]
                        aux_fill[1]
                        aux_fill[2]
                        aux_fill[3]
                        WITH FRAME f_cab_exigibilidade.
   
   IF crapcop.cdcooper <> 3 THEN
      DO:
         DISP STREAM str_1 crapcop.nmrescop
                           aux_vlpredep[1]
                           aux_vlpredep[2]
                           aux_vlpredep[3]
                           aux_vlpredep[4]
                           aux_vlpredep[5]
                           WITH FRAME f_exigibilidade.

         DOWN STREAM str_1 WITH FRAME f_exigibilidade.

      END.

   aux_flgdispl = TRUE.


END.

DISP STREAM str_1 aux_vltotcre[1]      
                  aux_vltotcre[2]
                  aux_vltotcre[3]
                  aux_vltotcre[4]
                  aux_vltotcre[5]
                  aux_fill[1]
                  aux_fill[2]
                  WITH FRAM f_tot_exigibilidade.


/* Gera o resumo da BASE DE CALCULO para cada periodo de exigibilidade */
FOR EACH tt-exigib NO-LOCK BREAK BY tt-exigib.nrperiod
                                  BY tt-exigib.idexigib:

    DO aux_contador = 1 TO 10:

       ASSIGN aux_dtcalcul[aux_contador] = ?
              aux_vlbascal[aux_contador] = 0.

    END.

    ASSIGN aux_contador = 0.
    
    FOR EACH tt-calculo WHERE tt-calculo.idexigib = tt-exigib.idexigib
                              NO-LOCK:
    
        aux_contador = aux_contador + 1.
    
        ASSIGN aux_dtcalcul[aux_contador] = tt-calculo.dtcalcul
               aux_vlbascal[aux_contador] = tt-calculo.vlbascal.
           
        IF tt-calculo.cdcooper = 3 THEN
           aux_vltotcal[aux_contador] = tt-calculo.vlbascal.
    
        IF aux_contador = 5 THEN
           LEAVE.

    END.

    IF FIRST-OF(tt-exigib.nrperiod) THEN
       DO:
          IF LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 22) THEN
             PAGE STREAM str_1.

          DISP STREAM str_1 aux_dtcalcul[1] 
                            aux_dtcalcul[2]
                            aux_dtcalcul[3]
                            aux_dtcalcul[4]
                            aux_dtcalcul[5]
                            tt-exigib.dtiniper
                            tt-exigib.dtfimper
                            aux_fill[1]
                            aux_fill[2]
                            aux_fill[3]
                            WITH FRAME f_cab_calculo.

       END.

    FIND crapcop WHERE crapcop.cdcooper = tt-exigib.cdcooper 
                       NO-LOCK NO-ERROR.
    
    IF crapcop.cdcooper <> 3 THEN
       DO:
          DISP STREAM str_1 crapcop.nmrescop WHEN AVAIL crapcop
                            aux_vlbascal[1]
                            aux_vlbascal[2]
                            aux_vlbascal[3]
                            aux_vlbascal[4]
                            aux_vlbascal[5]
                            WITH FRAME f_calculo.
    
          DOWN STREAM str_1 WITH FRAME f_calculo.

       END.

    IF LAST-OF(tt-exigib.nrperiod) THEN
       DO:
          DISP STREAM str_1 aux_vltotcal[1]      
                            aux_vltotcal[2]
                            aux_vltotcal[3]
                            aux_vltotcal[4]
                            aux_vltotcal[5]
                            aux_fill[1]
                            aux_fill[2]
                            WITH FRAM f_tot_calculo.

          DO aux_contador = 1 TO 10:

             aux_vltotcal[aux_contador] = 0.

          END.

       END.


    IF NOT LAST-OF(tt-exigib.nrperiod) THEN
       NEXT.

    FOR EACH b-tt-exigib1 WHERE b-tt-exigib1.nrperiod = tt-exigib.nrperiod
                                NO-LOCK BREAK BY b-tt-exigib1.nrperiod
                                               BY b-tt-exigib1.idexigib:
    
        DO aux_contador = 1 TO 10:

           ASSIGN aux_dtcalcul[aux_contador] = ?
                  aux_vlbascal[aux_contador] = 0.

        END.

        ASSIGN aux_contador = 0.
    
        FOR EACH tt-calculo WHERE tt-calculo.idexigib = b-tt-exigib1.idexigib
                                  NO-LOCK:
    
            aux_contador = aux_contador + 1.
    
            IF aux_contador <= 5 THEN
               NEXT.
    
            ASSIGN aux_dtcalcul[aux_contador] = tt-calculo.dtcalcul
                   aux_vlbascal[aux_contador] = tt-calculo.vlbascal.
               
            IF tt-calculo.cdcooper = 3 THEN
               aux_vltotcal[aux_contador] = tt-calculo.vlbascal.
    
        END.

        IF FIRST-OF(b-tt-exigib1.nrperiod)  THEN
           DO:
              IF LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 20) THEN
                 PAGE STREAM str_1.

              DISP STREAM str_1 aux_dtcalcul[6]
                                aux_dtcalcul[7]
                                aux_dtcalcul[8]
                                aux_dtcalcul[9]
                                aux_dtcalcul[10]
                                aux_fill[1]
                                aux_fill[2]
                                WITH FRAME f_cab_calculo_2.

           END.


        FIND crapcop WHERE crapcop.cdcooper = b-tt-exigib1.cdcooper
                           NO-LOCK NO-ERROR.


        IF crapcop.cdcooper <> 3 THEN
           DO:
              DISP STREAM str_1 crapcop.nmrescop WHEN AVAIL crapcop
                                aux_vlbascal[6]
                                aux_vlbascal[7]
                                aux_vlbascal[8]
                                aux_vlbascal[9]
                                aux_vlbascal[10]
                                WITH FRAME f_calculo_2.
              
              DOWN STREAM str_1 WITH FRAME f_calculo_2.

           END.

        IF LAST-OF(b-tt-exigib1.nrperiod) THEN
           DO: 
              DISP STREAM str_1 aux_vltotcal[6]      
                                aux_vltotcal[7]
                                aux_vltotcal[8]
                                aux_vltotcal[9]
                                aux_vltotcal[10]
                                aux_fill[1]
                                aux_fill[2]
                                WITH FRAM f_tot_calculo_2.

              DO aux_contador = 1 TO 10:

                 aux_vltotcal[aux_contador] = 0.

              END.

           END.

        IF NOT LAST-OF(b-tt-exigib1.nrperiod) THEN
           NEXT.
       

    END.

           
END.


OUTPUT STREAM str_1 CLOSE.
                                       
ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = "rl/crrl612.lst".
       

RUN fontes/imprim.p.


RUN fontes/fimprg.p.



