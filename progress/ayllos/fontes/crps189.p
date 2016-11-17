/* ..........................................................................

   Programa: Fontes/crps189.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97                           Ultima atualizacao: 24/10/2013

   Dados referentes ao programa:

   Frequencia: Mensal. Paralelo.

   Objetivo  : Atende a solicitacao 70.
               Mensal do cartao de credito.
               Ordem do programa na solicitacao 70.
               Relatorio 140.

   Alteracoes: 28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/05/98 - Alterado para emitir 2 copias (Edson).

               27/08/98 - Tratar novos tipos de cartao (odair)

               09/04/1999 - Mostrar renovados e 2via entregues no mes
                            (Deborah).

               19/07/9999 - Alterado para chamar a rotina de impressao (Edson).
               
               03/02/2000 - Gerar pedido de impressao (Deborah).
               
               11/11/2004 - O programa foi alterado de mensal para semanal
                            (Julio)

               06/12/2004 - So ira setar "crawcrd.inanuida = 0" se for a
                            primeira vez que esta rodando no mes ( Julio )  

               11/01/2005 - Alteracao dos parametros de solicitacao exclusiva
                            para paralela. (Julio)

               21/03/2005 - retirada a atualizacao do crawcrd.inanuida, 
                            atualizacao agora e feita no crps432 (Julio)
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               24/10/2013 - Alterado para nao utilizar codigo dos PAs fixos;
                          - Removidos Arrays e substituidos pela tt-relat.
                            (Reinert).
............................................................................ */

{ includes/var_batch.i "NEW" }

DEF    STREAM str_1.

DEF    VAR rel_nmresemp  AS CHAR                                     NO-UNDO.
DEF    VAR rel_nmrelato  AS CHAR    EXTENT 5                         NO-UNDO.
DEF    VAR rel_nrmodulo  AS INT                                      NO-UNDO.

DEF    VAR  aux_qtaprova AS INTEGER                                  NO-UNDO.
DEF    VAR  aux_qtsolici AS INTEGER                                  NO-UNDO.
DEF    VAR  aux_qtusando AS INTEGER                                  NO-UNDO.
DEF    VAR  aux_vllimite AS DECIMAL                                  NO-UNDO.
DEF    VAR  aux_vldebito AS DECIMAL                                  NO-UNDO.
DEF    VAR  aux_qtlibera AS INTEGER                                  NO-UNDO.

DEF    VAR  aux_dsagenci AS CHAR    FORMAT "x(21)"                   NO-UNDO.
DEF    VAR  aux_dstipimp AS CHAR    FORMAT "x(01)"                   NO-UNDO.

DEF    VAR  aux_dsmesano AS CHAR    FORMAT "x(30)"                   NO-UNDO.

DEF    VAR tab_dosmeses  AS CHAR    FORMAT "x(15)" EXTENT 12
                                    INIT ["JANEIRO/","FEVEREIRO/",
                                          "MARCO/","ABRIL/",
                                          "MAIO/","JUNHO/",
                                          "JULHO/","AGOSTO/",
                                          "SETEMBRO/","OUTUBRO/",
                                          "NOVEMBRO/","DEZEMBRO/"].

DEF    VAR aux_qtentmes  AS INT     FORMAT "zzz,zz9"                 NO-UNDO.
DEF    VAR aux_qtrenova  AS INT     FORMAT "zzz,zz9"                 NO-UNDO.
DEF    VAR aux_qtentr2v  AS INT     FORMAT "zzz,zz9"                 NO-UNDO.

DEF    VAR aux_regexist  AS LOGICAL                                  NO-UNDO.

DEF TEMP-TABLE tt-relat
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD qtaprova AS INTE
    FIELD qtsolici AS INTE
    FIELD qtusando AS INTE
    FIELD vllimite AS DECI
    FIELD vldebito AS DECI
    FIELD qtlibera AS DECI.

FORM  aux_dsagenci         LABEL "PA"
      tt-relat.qtaprova    LABEL "APROV."   FORMAT "zz,zz9"
      tt-relat.qtsolici    LABEL "SOLICIT"  FORMAT "zzz,zz9"
      tt-relat.qtlibera    LABEL "LIBER."   FORMAT "zz,zz9"
      tt-relat.qtusando    LABEL "EM USO"   FORMAT "zz,zz9"
      tt-relat.vllimite    LABEL "LIMITE"   FORMAT "zzz,zzz,zz9.99"
      tt-relat.vldebito    LABEL "DEBITOS"  FORMAT "zzz,zzz,zz9.99"
      WITH DOWN NO-LABELS NO-BOX WIDTH 80 FRAME f_dados.

FORM  aux_qtaprova    LABEL "------"           FORMAT "zz,zz9"  AT 23
      aux_qtsolici    LABEL "-------"          FORMAT "zzz,zz9"
      aux_qtlibera    LABEL "------"           FORMAT "zz,zz9"
      aux_qtusando    LABEL "------"           FORMAT "zz,zz9"
      aux_vllimite    LABEL "--------------"   FORMAT "zzz,zzz,zz9.99"
      aux_vldebito    LABEL "--------------"   FORMAT "zzz,zzz,zz9.99"
      WITH DOWN NO-LABELS NO-BOX NO-UNDERLINE WIDTH 80 FRAME f_final.

FORM  aux_dsmesano LABEL "MES DE REFERENCIA"
      SKIP(1)
      WITH SIDE-LABELS NO-BOX FRAME f_inicio.

FORM  crawcrd.nrdconta   LABEL "CONTA/DV"
      crawcrd.nrctrcrd   LABEL "PROPOSTA"
      crapass.cdagenci   LABEL "PA"    FORMAT "zz9"
      crawcrd.nmtitcrd   LABEL "TITULAR DO CARTAO" FORMAT "x(33)"
      crawcrd.nrcrcard   LABEL "NUMERO DO CARTAO"
      aux_dstipimp       LABEL "T"
      WITH DOWN NO-LABELS NO-BOX WIDTH 80 FRAME f_cartao.

FORM crapadc.nmresadm  LABEL "ADMINISTRADORA"
     SKIP(1)
     WITH SIDE-LABELS FRAME f_adm.

FORM  SKIP(1)
      "QUANTIDADE DE CARTOES ==> "
      aux_qtentmes  LABEL "ENTREGUES"
      aux_qtentr2v  LABEL "2.VIA" 
      aux_qtrenova  LABEL "RENOVADOS"
      WITH SIDE-LABELS NO-BOX FRAME f_entregues.

glb_cdprogra = "crps189".
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

{ includes/cabrel080_1.i }

OUTPUT STREAM str_1 TO VALUE("rl/crrl140.lst") PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

aux_dsmesano = tab_dosmeses[MONTH(glb_dtmvtolt)] +
               STRING(YEAR(glb_dtmvtolt),"9999").

aux_regexist = FALSE.

FOR EACH crapadc WHERE crapadc.cdcooper = glb_cdcooper  NO-LOCK:
  
  IF   aux_regexist THEN
       PAGE STREAM str_1.
       
  aux_regexist = TRUE.

  DISPLAY STREAM str_1 aux_dsmesano WITH FRAME f_inicio.

  DISPLAY STREAM str_1 crapadc.nmresadm WITH FRAME f_adm.

  ASSIGN  aux_qtaprova = 0  aux_qtsolici = 0  aux_qtlibera = 0
          aux_qtusando = 0  aux_vllimite = 0  aux_vldebito = 0.

  FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper        AND
                         crawcrd.cdadmcrd = crapadc.cdadmcrd    TRANSACTION:

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crawcrd.nrdconta  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
             glb_cdcritic = 9.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                " >> log/proc_batch.log").
             glb_cdcritic = 0.
             QUIT.
         END.

    IF   /* Entregues no mes */
         (TRUNC(INT(crawcrd.dtentreg) / 7, 0) = 
                TRUNC(INT(glb_dtmvtolt) / 7, 0) - 1) OR
         /* 2. via */
         (TRUNC(INT(crawcrd.dtentr2v) / 7, 0) = 
                TRUNC(INT(glb_dtmvtolt)/ 7, 0) - 1) OR
         /* Renovacao */
         (TRUNC(INT(crawcrd.dtultval) / 7, 0) = 
                TRUNC(INT(glb_dtmvtolt)/ 7, 0) - 1) THEN
         DO:
             IF   LINE-COUNTER(str_1) > 80 THEN
                  DO:
                      PAGE STREAM str_1.
                      DISPLAY STREAM str_1 aux_dsmesano WITH FRAME f_inicio.
                  END.

             ASSIGN aux_dstipimp = IF TRUNC(INT(crawcrd.dtentreg) / 7, 0) = 
                                       TRUNC(INT(glb_dtmvtolt) / 7, 0) - 1 
                                       THEN "E"
                                   ELSE
                                       IF TRUNC(INT(crawcrd.dtentr2v) / 7, 0)= 
                                          TRUNC(INT(glb_dtmvtolt) / 7, 0) - 1
                                           THEN "2"
                                           ELSE "R"

                    aux_qtentmes = IF aux_dstipimp = "E" 
                                      THEN aux_qtentmes + 1
                                      ELSE aux_qtentmes

                    aux_qtentr2v = IF aux_dstipimp = "2" 
                                      THEN aux_qtentr2v + 1
                                      ELSE aux_qtentr2v
                                      
                    aux_qtrenova = IF aux_dstipimp = "R" 
                                      THEN aux_qtrenova + 1
                                      ELSE aux_qtrenova.
             
             DISPLAY STREAM str_1
                     crawcrd.nrdconta crawcrd.nrctrcrd crapass.cdagenci
                     crawcrd.nmtitcrd crawcrd.nrcrcard aux_dstipimp
                     WITH FRAME f_cartao.

             DOWN STREAM str_1 WITH FRAME f_cartao.

         END.
    
    FIND tt-relat WHERE tt-relat.cdagenci = crapass.cdagenci 
                  NO-ERROR.
    IF NOT AVAIL tt-relat THEN
       DO:
          CREATE tt-relat.
          ASSIGN tt-relat.cdagenci = crapass.cdagenci.
       END.

    IF   crawcrd.insitcrd = 1 THEN
         ASSIGN aux_qtaprova = aux_qtaprova + 1
                tt-relat.qtaprova = tt-relat.qtaprova + 1.
    ELSE
    IF   crawcrd.insitcrd = 2 THEN
         ASSIGN aux_qtsolici = aux_qtsolici + 1
                tt-relat.qtsolici = tt-relat.qtsolici + 1.
    ELSE
    IF   crawcrd.insitcrd = 3 THEN
         ASSIGN aux_qtlibera = aux_qtlibera + 1
            tt-relat.qtlibera = tt-relat.qtlibera + 1.
    ELSE
    IF   crawcrd.insitcrd = 4 THEN
         DO:
             FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper      AND
                                craptlc.cdadmcrd = crawcrd.cdadmcrd  AND
                                craptlc.tpcartao = crawcrd.tpcartao  AND
                                craptlc.cdlimcrd = crawcrd.cdlimcrd  AND
                                craptlc.dddebito = 0                 
                                NO-LOCK NO-ERROR.
 
             IF   NOT AVAILABLE craptlc   THEN
                  DO:
                      glb_cdcritic = 532.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
                      glb_cdcritic = 0.
                      QUIT.
                  END.

             ASSIGN aux_vllimite = aux_vllimite + craptlc.vllimcrd
                    tt-relat.vllimite = tt-relat.vllimite + craptlc.vllimcrd.

             FOR EACH crapdcd WHERE crapdcd.cdcooper  = glb_cdcooper        AND
                                    crapdcd.nrdconta  = crawcrd.nrdconta    AND
                                    crapdcd.nrcrcard  = crawcrd.nrcrcard    AND
                              MONTH(crapdcd.dtdebito) = MONTH(glb_dtmvtolt) AND
                               YEAR(crapdcd.dtdebito) =  YEAR(glb_dtmvtolt)
                                    NO-LOCK:

                 ASSIGN aux_vldebito = aux_vldebito + crapdcd.vldebito
                        tt-relat.vldebito = tt-relat.vldebito + crapdcd.vldebito.
             END.

             ASSIGN aux_qtusando = aux_qtusando + 1
                    tt-relat.qtusando = tt-relat.qtusando + 1.

         END.
        
  END. /* Fim do FOR EACH crawcrd */
  
  DISPLAY STREAM str_1 aux_qtentmes aux_qtentr2v aux_qtrenova 
                 WITH FRAME f_entregues.

  ASSIGN aux_qtentmes = 0
         aux_qtentr2v = 0
         aux_qtrenova = 0.

  PAGE STREAM str_1.

  DISPLAY STREAM str_1 crapadc.nmresadm WITH FRAME f_adm.
  
  FOR EACH tt-relat EXCLUSIVE-LOCK
                    BREAK BY tt-relat.cdagenci:

      FIND crapage WHERE crapage.cdcooper = glb_cdcooper
                     AND crapage.cdagenci = tt-relat.cdagenci
                    NO-LOCK NO-ERROR.

      ASSIGN aux_dsagenci = STRING(crapage.cdagenci,"999") +
                                 " " + crapage.nmresage.

      IF   tt-relat.qtaprova = 0  AND  tt-relat.qtsolici = 0 AND
           tt-relat.qtlibera = 0  AND  tt-relat.qtusando = 0 AND
           tt-relat.vllimite = 0  AND  tt-relat.vldebito = 0 THEN
           NEXT.
           
      DISPLAY STREAM str_1
              aux_dsagenci        tt-relat.qtaprova   tt-relat.qtsolici
              tt-relat.qtlibera   tt-relat.qtusando   tt-relat.vllimite
              tt-relat.vldebito   WITH FRAME f_dados.
                     
      DOWN STREAM str_1 WITH FRAME f_dados.

      DELETE tt-relat.
  END.

  DISPLAY STREAM str_1 aux_qtaprova   aux_qtsolici   aux_qtlibera
                       aux_qtusando   aux_vllimite   aux_vldebito
                       WITH FRAME f_final.

END. /* FOR EACH crapadc */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmarqimp = "rl/crrl140.lst"
       glb_nmformul = "80col".

RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/* .......................................................................... */

