/* ............................................................................

   Programa: Fontes/crps552.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Precise
   Data    : Janeiro/2010.                    Ultima atualizacao: 13/01/2014
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Calculo das tarifas dos lancamentos da Compensacao.


   Alteracoes: 26/01/2010 - Primeira Versao
   
               07/05/2010 - Correcoes (Diego).

               05/07/2010 - Acertos Gerais (Ze).
               
               02/08/2010 - Dividindo atualizacao no banco Generico, para nao
                            ocorrer o erro de -L (Ze).

               04/08/2010 - Alteracao na Soma dos Valores CHQ/TIT/DOC (Ze).
               
               01/10/2010 - Realizado a divisao dos lancamentos em dois grupos
                            (Adriano).
                            
               18/05/2011 - Inclusao do COB SR/VLB.  (Guilherme/Supero)
               
               20/04/2012 - Inclusao do COB NR DDA/SR DDA. (Rafael)  
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).

               03/09/2012 - Gerar lançamento da TIC no gntarcp (Ze).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               20/06/2017 - Geraçao de tabela com lançamentos contábeis centralizados de 
                            cada cooperativa filiada na central para posterior geraçao de 
                            arquivo para o Matera. (Jonatas-Supero)                                
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
                                     
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR aux_tplotmov AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.

DEF        VAR aux_dataini  AS DATE                                  NO-UNDO.
DEF        VAR aux_datafim  AS DATE                                  NO-UNDO.
DEF        VAR aux_vllanmto AS DEC                                   NO-UNDO.

DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.

DEF        VAR aux_vlcretib AS DEC                                   NO-UNDO.
DEF        VAR aux_vldebtib AS DEC                                   NO-UNDO.

DEF        VAR aux_vlcrechr AS DEC                                   NO-UNDO.
DEF        VAR aux_vldebchr AS DEC                                   NO-UNDO.

DEF        VAR aux_vldebdev AS DEC                                   NO-UNDO.
DEF        VAR aux_vldebccf AS DEC                                   NO-UNDO.
DEF        VAR aux_vldebicf AS DEC                                   NO-UNDO.
DEF        VAR aux_vldebtic AS DEC                                   NO-UNDO.

DEF        VAR aux_flgfirst AS LOGI     INIT TRUE                    NO-UNDO.
DEF        VAR aux_dsrefere AS CHAR     FORMAT "x(200)"              NO-UNDO.
DEF        VAR aux_cdagectl AS INT                                   NO-UNDO.

DEF TEMP-TABLE tt-aux-detlctctl NO-UNDO
    FIELD cdcooper AS INT
    FIELD cdagenci AS INT
    FIELD vllamnto AS DEC
    FIELD indebcrd AS INT.
    
DEF TEMP-TABLE tt-detlctctl                                            NO-UNDO
    FIELD cdcooper AS INT
    FIELD cdagenci AS INT
    FIELD cdhistor AS INT
    FIELD vllamnto AS DEC
    FIELD nrdconta AS INT
    FIELD nrctadeb AS INT
    FIELD nrctacrd AS INT
    FIELD dsrefere AS CHAR FORMAT "x(200)"
    FIELD intiplct AS INT.    
    
    

DEF BUFFER crabcop FOR crapcop.

ASSIGN glb_cdprogra = "crps552".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
          
/* Busca dados da cooperativa */
FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN aux_cdbccxlt = crabcop.cdbcoctl.

TRANS_1:
DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    /* Será executado sempre no primeiro dia do mes, sendo assim, a variavel
       glb_dtmvtoan conterá a data do ultimo dia do mes anterior  */
       
    ASSIGN aux_dataini = DATE(MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt))
           aux_datafim = glb_dtmvtolt.
           
    /* Processa todos os lancamentos do periodo informado */
    FOR EACH gntarcp WHERE gntarcp.cdcooper <> 3             AND 
                           gntarcp.dtmvtolt >= aux_dataini   AND
                           gntarcp.dtmvtolt <= aux_datafim   AND
                           gntarcp.flgpcctl =  FALSE     NO-LOCK
                           BREAK BY gntarcp.cdcooper
                                    BY gntarcp.cdtipdoc:

        IF   FIRST-OF(gntarcp.cdcooper)  THEN
             DO:
             ASSIGN aux_vllanmto = 0
                    aux_vlcretib = 0 
                    aux_vldebtib = 0
                    aux_vlcrechr = 0
                    aux_vldebchr = 0
                    aux_vldebccf = 0
                    aux_vldebicf = 0
                    aux_vldebdev = 0.
        
                  FIND FIRST crapcop WHERE crapcop.cdcooper = gntarcp.cdcooper
                       NO-LOCK NO-ERROR.
             END.
        IF   gntarcp.cdtipdoc = 1  OR    /* Cheque Inferior Nossa Remessa */
             gntarcp.cdtipdoc = 2  OR    /* Cheque Superior Nossa Remessa */
             gntarcp.cdtipdoc = 3  OR    /* Titulo/Cobranca Nossa Remessa */
             gntarcp.cdtipdoc = 4  OR    /* Titulo/Cobranca VLB Nossa Remessa */
             gntarcp.cdtipdoc = 8  OR    /* DOC Sua Remessa */
             gntarcp.cdtipdoc = 21 OR    /* Titulo/Cobranca NR DDA */
             gntarcp.cdtipdoc = 22 THEN  /* Titulo/Cobranca VLB NR DDA */
             ASSIGN aux_vlcretib = aux_vlcretib + gntarcp.vldocmto.
        ELSE
        IF   gntarcp.cdtipdoc = 5  OR    /* DOC Nossa Remessa */
             gntarcp.cdtipdoc = 6  OR    /* Cheque Inferior Sua Remessa */
             gntarcp.cdtipdoc = 7  OR    /* Cheque Superior Sua Remessa */
             gntarcp.cdtipdoc = 19 OR    /* Titulo/Cobranca Sua Remessa */
             gntarcp.cdtipdoc = 20 OR    /* Titulo/Cobranca VLB Sua Remessa */
             gntarcp.cdtipdoc = 23 OR    /* Titulo/Cobranca SR DDA */
             gntarcp.cdtipdoc = 24 THEN  /* Titulo/Cobranca VLB SR DDA */
             ASSIGN aux_vldebtib = aux_vldebtib + gntarcp.vldocmto.
        ELSE
        IF   gntarcp.cdtipdoc = 12 THEN  /* Cheque Roubado Sua Remessa */
             DO:
             
                  IF gntarcp.cdagenci = 0 THEN
                       DO:
                            FIND FIRST crapage WHERE crapage.cdcooper = gntarcp.cdcooper AND
                                                     crapage.flgdsede = TRUE
                                                     NO-LOCK NO-ERROR.
                                 
                            ASSIGN aux_cdagectl = crapage.cdagenci.
                       END.
                  ELSE
                       ASSIGN aux_cdagectl = gntarcp.cdagenci. 
                            
                  ASSIGN aux_vlcrechr = aux_vlcrechr + gntarcp.vldocmto.
             

                  FIND tt-aux-detlctctl WHERE 
                       tt-aux-detlctctl.cdcooper = gntarcp.cdcooper AND 
                       tt-aux-detlctctl.cdagenci = aux_cdagectl AND
                       tt-aux-detlctctl.indebcrd = 0 EXCLUSIVE-LOCK NO-ERROR.

                  IF  NOT AVAILABLE tt-aux-detlctctl  THEN
                      DO:
                  
                  CREATE tt-aux-detlctctl.
                  ASSIGN tt-aux-detlctctl.cdcooper = gntarcp.cdcooper
                                  tt-aux-detlctctl.cdagenci = aux_cdagectl
                                  tt-aux-detlctctl.indebcrd = 0. /*debito*/
                      END.
                  ASSIGN tt-aux-detlctctl.vllamnto = tt-aux-detlctctl.vllamnto + gntarcp.vldocmto.                     
             
             END.
             
        ELSE
        IF   gntarcp.cdtipdoc = 11 THEN  /* Cheque Roubado Nossa Remessa */
             DO:
             
                  IF gntarcp.cdagenci = 0 THEN
                       DO:
                            FIND FIRST crapage WHERE crapage.cdcooper = gntarcp.cdcooper AND
                                                     crapage.flgdsede = TRUE
                                                     NO-LOCK NO-ERROR.
                                 
                            ASSIGN aux_cdagectl = crapage.cdagenci.
                       END.
                  ELSE
                       ASSIGN aux_cdagectl = gntarcp.cdagenci. 
                       
                  ASSIGN aux_vldebchr = aux_vldebchr + gntarcp.vldocmto.

                  FIND tt-aux-detlctctl WHERE 
                       tt-aux-detlctctl.cdcooper = gntarcp.cdcooper AND 
                       tt-aux-detlctctl.cdagenci = aux_cdagectl AND
                       tt-aux-detlctctl.indebcrd = 1 EXCLUSIVE-LOCK NO-ERROR.

                  IF  NOT AVAILABLE tt-aux-detlctctl  THEN
                      DO:
                  
                  CREATE tt-aux-detlctctl.
                  ASSIGN tt-aux-detlctctl.cdcooper = gntarcp.cdcooper
                                  tt-aux-detlctctl.cdagenci = aux_cdagectl
                                  tt-aux-detlctctl.indebcrd = 1. /*debito*/
                      END.
                  ASSIGN tt-aux-detlctctl.vllamnto = tt-aux-detlctctl.vllamnto + gntarcp.vldocmto.   
             END.
             
        ELSE
        IF   gntarcp.cdtipdoc = 9  OR    /* Devolucao Sua Remessa Noturna */
             gntarcp.cdtipdoc = 10 THEN  /* Devolucao Sua Remessa Diurna */
             
             DO:
                  ASSIGN aux_vldebdev = aux_vldebdev + gntarcp.vldocmto.
             
                  IF gntarcp.cdagenci = 0 THEN
                       DO:
                            FIND FIRST crapage WHERE crapage.cdcooper = gntarcp.cdcooper AND
                                                     crapage.flgdsede = TRUE
                                                     NO-LOCK NO-ERROR.
                                 
                            ASSIGN aux_cdagectl = crapage.cdagenci.
                       END.
                  ELSE
                       ASSIGN aux_cdagectl = gntarcp.cdagenci. 

             
                 /*Linhas com valor por agencia*/
                  FIND tt-detlctctl WHERE 
                       tt-detlctctl.cdcooper = gntarcp.cdcooper AND
                       tt-detlctctl.cdhistor = 814 AND
                       tt-detlctctl.cdagenci = aux_cdagectl AND
                       tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                  IF  NOT AVAILABLE tt-detlctctl  THEN
                      DO:
                           CREATE tt-detlctctl.
                           ASSIGN tt-detlctctl.cdcooper = gntarcp.cdcooper
                                  tt-detlctctl.cdhistor = 814
                                  tt-detlctctl.cdagenci = aux_cdagectl 
                                  tt-detlctctl.nrdconta = crapcop.nrctacmp
                                  tt-detlctctl.nrctadeb = 8308
                                  tt-detlctctl.nrctacrd = 1455
                                  tt-detlctctl.dsrefere = "DEBITO C/C " +
                                                          STRING(crapcop.nrctacmp,"zzzz,zzz,9") + 
                                                          " COMPE CECRED REF. TAXA DEVOLUCAO CHEQUE"
                                  tt-detlctctl.intiplct = 1.
                                         
                      END.
                  ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + gntarcp.vldocmto.             
             
             END.
             
        ELSE
        IF   gntarcp.cdtipdoc = 13 THEN  /* ICF */
             DO:
                  ASSIGN aux_vldebicf = aux_vldebicf + gntarcp.vldocmto.
                  
                  IF gntarcp.cdagenci = 0 THEN
                       DO:
                            FIND FIRST crapage WHERE crapage.cdcooper = gntarcp.cdcooper AND
                                                     crapage.flgdsede = TRUE
                                                     NO-LOCK NO-ERROR.
                                 
                            ASSIGN aux_cdagectl = crapage.cdagenci.
                       END.
                  ELSE
                       ASSIGN aux_cdagectl = gntarcp.cdagenci. 
                  
                 /*Linhas com valor por agencia*/
                  FIND tt-detlctctl WHERE 
                       tt-detlctctl.cdcooper = gntarcp.cdcooper AND
                       tt-detlctctl.cdhistor = 822 AND
                       tt-detlctctl.cdagenci = aux_cdagectl AND
                       tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                  IF  NOT AVAILABLE tt-detlctctl  THEN
                      DO:
                           CREATE tt-detlctctl.
                           ASSIGN tt-detlctctl.cdcooper = gntarcp.cdcooper
                                  tt-detlctctl.cdhistor = 822
                                  tt-detlctctl.cdagenci = aux_cdagectl 
                                  tt-detlctctl.nrdconta = crapcop.nrctacmp
                                  tt-detlctctl.nrctadeb = 8308
                                  tt-detlctctl.nrctacrd = 1455
                                  tt-detlctctl.dsrefere = "DEBITO C/C " +
                                                          STRING(crapcop.nrctacmp,"zzzz,zzz,9") + 
                                                          " COMPE CECRED REF. TAXA ICF"
                                  tt-detlctctl.intiplct = 1.
                                         
                      END.
                  ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + gntarcp.vldocmto.                    
                                              
             END.   
        ELSE
        IF   gntarcp.cdtipdoc = 18 THEN  /* CCF */
             DO:
                  ASSIGN aux_vldebccf = aux_vldebccf + gntarcp.vldocmto.
                  
                  IF gntarcp.cdagenci = 0 THEN
                       DO:
                            FIND FIRST crapage WHERE crapage.cdcooper = gntarcp.cdcooper AND
                                                     crapage.flgdsede = TRUE
                                                     NO-LOCK NO-ERROR.
                                 
                            ASSIGN aux_cdagectl = crapage.cdagenci.
                       END.
                  ELSE
                       ASSIGN aux_cdagectl = gntarcp.cdagenci.                   
                  
                 /*Linhas com valor por agencia*/
                  FIND tt-detlctctl WHERE 
                       tt-detlctctl.cdcooper = gntarcp.cdcooper AND
                       tt-detlctctl.cdhistor = 839 AND
                       tt-detlctctl.cdagenci = aux_cdagectl AND
                       tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                  IF  NOT AVAILABLE tt-detlctctl  THEN
                      DO:
                           CREATE tt-detlctctl.
                           ASSIGN tt-detlctctl.cdcooper = gntarcp.cdcooper
                                  tt-detlctctl.cdhistor = 839
                                  tt-detlctctl.cdagenci = aux_cdagectl 
                                  tt-detlctctl.nrdconta = crapcop.nrctacmp
                                  tt-detlctctl.nrctadeb = 8308
                                  tt-detlctctl.nrctacrd = 1455
                                  tt-detlctctl.dsrefere = "DEBITO C/C " +
                                                          STRING(crapcop.nrctacmp,"zzzz,zzz,9") + 
                                                          " COMPE CECRED REF. TAXA CCF"
                                  tt-detlctctl.intiplct = 1.
                                         
                      END.
                  ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + gntarcp.vldocmto.                    
         
             END.
        ELSE
        IF   gntarcp.cdtipdoc = 25 THEN  /* TIC */
             ASSIGN aux_vldebtic = aux_vldebtic + gntarcp.vldocmto.

        
        IF   LAST-OF(gntarcp.cdcooper)  THEN
             DO:
                 FIND FIRST crapcop WHERE crapcop.cdcooper = gntarcp.cdcooper
                            NO-LOCK NO-ERROR.
                 
                 /* Contabiliza saldo para efetuar lancamento */
                 ASSIGN aux_vllanmto = aux_vlcretib - aux_vldebtib.
           
                 /* Cheque, Doc e Titulos */
                 IF   aux_vllanmto <> 0 THEN
                      DO:
                          IF   aux_vllanmto < 0   THEN
                               ASSIGN aux_cdhistor = 587 /*TIB COMPE DEBITO*/
                                      aux_vllanmto = aux_vllanmto * -1.
                          ELSE                    
                               ASSIGN aux_cdhistor = 577. /*TIB COMPE CREDITO*/

                          RUN pi_cria_craplcm (INPUT aux_vllanmto,
                                               INPUT aux_cdhistor).
                                               
                          ASSIGN aux_vllanmto = 0.
                      END.
                 
                 ASSIGN aux_vllanmto = aux_vlcrechr - aux_vldebchr.

                 IF   aux_vllanmto <> 0 THEN
                      DO:
                          IF   aux_vllanmto < 0   THEN
                               ASSIGN aux_cdhistor = 811 /*TIB DEBITO*/
                                      aux_vllanmto = aux_vllanmto * -1.
                                      
                          ELSE                    
                               ASSIGN aux_cdhistor = 809. /*TIB CREDITO*/

                          RUN pi_cria_craplcm (INPUT aux_vllanmto,
                                               INPUT aux_cdhistor).
                                               
                          IF   aux_vlcrechr > 0 THEN
                              DO:
                                               
                                   CREATE tt-detlctctl.
                                   ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                           tt-detlctctl.cdhistor = 811
                                          tt-detlctctl.cdagenci = 0 
                                          tt-detlctctl.nrdconta = crapcop.nrctacmp
                                           tt-detlctctl.vllamnto = aux_vlcrechr
                                           tt-detlctctl.nrctadeb = 1455
                                           tt-detlctctl.nrctacrd = 7264
                                          tt-detlctctl.dsrefere = "CREDITO C/C " + 
                                                                  STRING(crapcop.nrctacmp,"zzzz,zzz,9") +
                                                                  " COMPE CECRED REF. TIB CHEQUE ROUBO"
                                          tt-detlctctl.intiplct = 0.
                                         
                              END.

                          
                          IF   aux_vldebchr > 0 THEN
                              DO:

                                   CREATE tt-detlctctl.
                                   ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                          tt-detlctctl.cdhistor = 809
                                          tt-detlctctl.cdagenci = 0 
                                          tt-detlctctl.nrdconta = crapcop.nrctacmp
                                          tt-detlctctl.vllamnto = aux_vldebchr                                          
                                          tt-detlctctl.nrctadeb = 7264
                                          tt-detlctctl.nrctacrd = 1455
                                          tt-detlctctl.dsrefere = "DEBITO C/C " + 
                                                                  STRING(crapcop.nrctacmp,"zzzz,zzz,9") +
                                                                  " COMPE CECRED REF. TIB CHEQUE ROUBO"
                                          tt-detlctctl.intiplct = 0.
                                         
                              END.
                          
                                                     
                          FOR EACH tt-aux-detlctctl WHERE tt-aux-detlctctl.cdcooper = crapcop.cdcooper NO-LOCK:
                          
                            IF tt-aux-detlctctl.indebcrd = 0 THEN
                                 DO:
                                 /*Linhas com valor por agencia*/
                                 FIND tt-detlctctl WHERE 
                                      tt-detlctctl.cdcooper = tt-aux-detlctctl.cdcooper AND
                                      tt-detlctctl.cdhistor = 811 AND
                                      tt-detlctctl.cdagenci = tt-aux-detlctctl.cdagenci AND
                                      tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                                 IF  NOT AVAILABLE tt-detlctctl  THEN
                                     DO:
                                          CREATE tt-detlctctl.
                                          ASSIGN tt-detlctctl.cdcooper = tt-aux-detlctctl.cdcooper
                                                 tt-detlctctl.cdhistor = 811
                                                 tt-detlctctl.cdagenci = tt-aux-detlctctl.cdagenci 
                                                 tt-detlctctl.nrdconta = crapcop.nrctacmp
                                                 tt-detlctctl.nrctadeb = 1455
                                                 tt-detlctctl.nrctacrd = 7264
                                                 tt-detlctctl.dsrefere = "CREDITO C/C " + 
                                                                         STRING(crapcop.nrctacmp,"zzzz,zzz,9") +
                                                                         " COMPE CECRED REF. TIB CHEQUE ROUBO"
                                                 tt-detlctctl.intiplct = 1.
                                         
                                     END.
                                 ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + tt-aux-detlctctl.vllamnto.                             
                                 END.
                            
                            ELSE
                                 DO:
                                 /*Linhas com valor por agencia*/
                                 FIND tt-detlctctl WHERE 
                                      tt-detlctctl.cdcooper = tt-aux-detlctctl.cdcooper AND
                                      tt-detlctctl.cdhistor = 809 AND
                                      tt-detlctctl.cdagenci = tt-aux-detlctctl.cdagenci AND
                                      tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                                 IF  NOT AVAILABLE tt-detlctctl  THEN
                                     DO:
                                          CREATE tt-detlctctl.
                                          ASSIGN tt-detlctctl.cdcooper = tt-aux-detlctctl.cdcooper
                                                 tt-detlctctl.cdhistor = 809
                                                 tt-detlctctl.cdagenci = tt-aux-detlctctl.cdagenci 
                                                      tt-detlctctl.nrdconta = crapcop.nrctacmp
                                                 tt-detlctctl.nrctadeb = 7264
                                                 tt-detlctctl.nrctacrd = 1455
                                                 tt-detlctctl.dsrefere = "DEBITO C/C " + 
                                                                         STRING(crapcop.nrctacmp,"zzzz,zzz,9") +
                                                                         " COMPE CECRED REF. TIB CHEQUE ROUBO"
                                                 tt-detlctctl.intiplct = 1.
                                         
                                     END.
                                 ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + tt-aux-detlctctl.vllamnto. 
                                 END.       
                          END.
                                               
                          ASSIGN aux_vllanmto = 0.
                      END.

                 IF   aux_vldebdev > 0 THEN
                      DO:
                          RUN pi_cria_craplcm (INPUT aux_vldebdev,
                                               INPUT 814).
                                               
                          /*Linhas com valor total*/
                          FIND tt-detlctctl WHERE 
                               tt-detlctctl.cdcooper = crapcop.cdcooper AND
                               tt-detlctctl.cdhistor = 814 AND
                               tt-detlctctl.cdagenci = 0 AND
                               tt-detlctctl.intiplct = 0 EXCLUSIVE-LOCK NO-ERROR.
     
                          IF  NOT AVAILABLE tt-detlctctl  THEN
                              DO:
                                   CREATE tt-detlctctl.
                                   ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                          tt-detlctctl.cdhistor = 814
                                          tt-detlctctl.cdagenci = 0 
                                          tt-detlctctl.nrdconta = crapcop.nrctacmp
                                          tt-detlctctl.nrctadeb = 8308
                                          tt-detlctctl.nrctacrd = 1455
                                          tt-detlctctl.dsrefere = "DEBITO C/C " +
                                                                  STRING(crapcop.nrctacmp,"zzzz,zzz,9") + 
                                                                  " COMPE CECRED REF. TAXA DEVOLUCAO CHEQUE"
                                          tt-detlctctl.intiplct = 0.
                                         
                              END.
                          ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vldebdev. 
                                               
                          ASSIGN aux_vldebdev = 0.
                          
                      END.
                      
                 IF   aux_vldebicf > 0 THEN
                      DO:
                          RUN pi_cria_craplcm (INPUT aux_vldebicf,
                                               INPUT 822).
                                               
                          /*Linhas com valor total*/
                          FIND tt-detlctctl WHERE 
                               tt-detlctctl.cdcooper = crapcop.cdcooper AND
                               tt-detlctctl.cdhistor = 822 AND
                               tt-detlctctl.cdagenci = 0 AND
                               tt-detlctctl.intiplct = 0 EXCLUSIVE-LOCK NO-ERROR.
     
                          IF  NOT AVAILABLE tt-detlctctl  THEN
                              DO:
                                   CREATE tt-detlctctl.
                                   ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                          tt-detlctctl.cdhistor = 822
                                          tt-detlctctl.cdagenci = 0 
                                          tt-detlctctl.nrdconta = crapcop.nrctacmp
                                          tt-detlctctl.nrctadeb = 8308
                                          tt-detlctctl.nrctacrd = 1455
                                          tt-detlctctl.dsrefere = "DEBITO C/C " +
                                                                  STRING(crapcop.nrctacmp,"zzzz,zzz,9") + 
                                                                  " COMPE CECRED REF. TAXA ICF"
                                          tt-detlctctl.intiplct = 0.
                                         
                              END.
                          ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vldebicf.                                                
                                               
                          ASSIGN aux_vldebicf = 0.
                      END.

                 IF   aux_vldebccf > 0 THEN
                      DO:
                          RUN pi_cria_craplcm (INPUT aux_vldebccf,
                                               INPUT 839).

                          /*Linhas com valor total*/
                          FIND tt-detlctctl WHERE 
                               tt-detlctctl.cdcooper = crapcop.cdcooper AND
                               tt-detlctctl.cdhistor = 839 AND
                               tt-detlctctl.cdagenci = 0 AND
                               tt-detlctctl.intiplct = 0 EXCLUSIVE-LOCK NO-ERROR.
     
                          IF  NOT AVAILABLE tt-detlctctl  THEN
                              DO:
                                   CREATE tt-detlctctl.
                                   ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                          tt-detlctctl.cdhistor = 839
                                          tt-detlctctl.cdagenci = 0 
                                          tt-detlctctl.nrdconta = crapcop.nrctacmp
                                          tt-detlctctl.nrctadeb = 8308
                                          tt-detlctctl.nrctacrd = 1455
                                          tt-detlctctl.dsrefere = "DEBITO C/C " +
                                                                  STRING(crapcop.nrctacmp,"zzzz,zzz,9") + 
                                                                  " COMPE CECRED REF. TAXA CCF"
                                          tt-detlctctl.intiplct = 0.
                                         
                              END.
                          ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vldebccf.  
                                               
                          ASSIGN aux_vldebccf = 0.
                      END.

                 IF   aux_vldebtic > 0 THEN
                      DO:
                          RUN pi_cria_craplcm (INPUT aux_vldebtic,
                                               INPUT 1103).

                          ASSIGN aux_vldebtic = 0.
                      END.
             END.
        
    END.  /* END FOR EACH */

END. /* DO TRANSACTION */

/*Gera tabela lançamentos para o Matera*/
RUN pi_insere_det_lct_ctl.

/*  Atualiza Registros do gntarcp  */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + 
                  "' --> '" + "Atualizando registros na tabela gntarcp... " +
                  " >> log/proc_batch.log").

RUN atualiza_gntarcp(01).  /* Cheque Inferior Nossa Remessa */
RUN atualiza_gntarcp(02).  /* Cheque Superior Nossa Remessa */
RUN atualiza_gntarcp(03).  /* Titulo/Cobranga Nossa Remessa */
RUN atualiza_gntarcp(04).  /* Titulo/Cobranga VLB Nossa Remessa */
RUN atualiza_gntarcp(05).  /* DOC Nossa Remessa */
RUN atualiza_gntarcp(06).  /* Cheque Inferior Sua Remessa */
RUN atualiza_gntarcp(07).  /* Cheque Superior Sua Remessa */
RUN atualiza_gntarcp(08).  /* DOC Sua Remessa */
RUN atualiza_gntarcp(09).  /* Devolucao Sua Remessa Noturna */
RUN atualiza_gntarcp(10).  /* Devolucao Sua Remessa Diurna */
RUN atualiza_gntarcp(11).  /* Cheque Roubado Nossa Remessa */
RUN atualiza_gntarcp(12).  /* Cheque Roubado Sua Remessa */
RUN atualiza_gntarcp(13).  /* ICF */
RUN atualiza_gntarcp(18).  /* CCF */
RUN atualiza_gntarcp(19).  /* Titulo/Cobranga Sua Remessa */
RUN atualiza_gntarcp(20).  /* Titulo/Cobranga VLB Sua Remessa */
RUN atualiza_gntarcp(21).  /* Titulo/Cobranga NR DDA */
RUN atualiza_gntarcp(22).  /* Titulo/Cobranga VLB NR DDA */
RUN atualiza_gntarcp(23).  /* Titulo/Cobranga SR DDA */
RUN atualiza_gntarcp(24).  /* Titulo/Cobranga VLB SR DDA */
RUN atualiza_gntarcp(25).  /* TIC */

RUN fontes/fimprg.p.

/*............................................................................*/

PROCEDURE pi_cria_craplcm:

   DEF INPUT PARAM par_vlrlamto AS DEC                       NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT                       NO-UNDO.

   IF   aux_flgfirst  THEN 
        DO:
            DO WHILE TRUE:
    
               FIND craptab WHERE craptab.cdcooper = crabcop.cdcooper AND
                                  craptab.nmsistem = "CRED"           AND
                                  craptab.tptabela = "GENERI"         AND
                                  craptab.cdempres = 00               AND
                                  craptab.cdacesso = "NUMLOTEBCO"     AND
                                  craptab.tpregist = 001
                                  EXCLUSIVE-LOCK NO-ERROR.
    
               IF   NOT AVAILABLE craptab THEN
                    IF   LOCKED craptab THEN
                         DO:
                             PAUSE 2 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 60.
                             RUN fontes/critic.p.
                             UNIX SILENT VALUE("echo " +
                                               STRING(TIME,"HH:MM:SS") +
                                               " - " + glb_cdprogra + 
                                               "' --> '" + glb_dscritic + 
                                               " >> log/proc_batch.log").
                             RETURN.                   
                         END.
               LEAVE.
            END.    /*  Fim do DO WHILE TRUE  */
    
            ASSIGN aux_nrdolote = INT(craptab.dstextab) + 1.

            DO WHILE TRUE:
    
               IF CAN-FIND(craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                                         craplot.dtmvtolt = glb_dtmvtopr     AND
                                         craplot.cdagenci = aux_cdagenci     AND
                                         craplot.cdbccxlt = aux_cdbccxlt     AND
                                         craplot.nrdolote = aux_nrdolote
                                         USE-INDEX craplot1) THEN
                    ASSIGN aux_nrdolote = aux_nrdolote + 1.
               ELSE
                    LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
    
            CREATE craplot.
            ASSIGN craplot.cdcooper = crabcop.cdcooper
                   craplot.dtmvtolt = glb_dtmvtopr
                   craplot.cdagenci = aux_cdagenci
                   craplot.cdbccxlt = aux_cdbccxlt
                   craplot.nrdolote = aux_nrdolote
                   craplot.tplotmov = aux_tplotmov
                   /* Atualiza registro na craptab */ 
                   craptab.dstextab = STRING(aux_nrdolote).
            VALIDATE craplot.

            ASSIGN aux_flgfirst = FALSE.
            
            RELEASE craptab.
        END. /* FIM do IF flgfirst */

   FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                      craplot.dtmvtolt = glb_dtmvtopr     AND
                      craplot.cdagenci = aux_cdagenci     AND
                      craplot.cdbccxlt = aux_cdbccxlt     AND
                      craplot.nrdolote = aux_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

   ASSIGN aux_nrdocmto = craplot.nrseqdig + 1.

   DO WHILE TRUE:

     FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper  AND
                        craplcm.dtmvtolt = craplot.dtmvtolt  AND
                        craplcm.cdagenci = craplot.cdagenci  AND
                        craplcm.cdbccxlt = craplot.cdbccxlt  AND
                        craplcm.nrdolote = craplot.nrdolote  AND
                        craplcm.nrdctabb = crapcop.nrctactl  AND
                        craplcm.nrdocmto = aux_nrdocmto
                        USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   AVAILABLE craplcm THEN
          aux_nrdocmto = (aux_nrdocmto + 1000).
     ELSE
          LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */


   CREATE craplcm.
   ASSIGN craplcm.cdcooper = crabcop.cdcooper
          craplcm.nrdconta = crapcop.nrctacmp
          craplcm.nrdctabb = crapcop.nrctacmp
          craplcm.dtmvtolt = craplot.dtmvtolt
          craplcm.dtrefere = craplot.dtmvtolt
          craplcm.cdagenci = craplot.cdagenci
          craplcm.cdbccxlt = craplot.cdbccxlt
          craplcm.nrdolote = craplot.nrdolote
          craplcm.nrdocmto = aux_nrdocmto
          craplcm.cdhistor = par_cdhistor
          craplcm.vllanmto = par_vlrlamto
          craplcm.nrseqdig = craplot.nrseqdig + 1.
   VALIDATE craplcm.
       
   ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.nrseqdig = craplcm.nrseqdig.
   

   IF   par_cdhistor = 577 OR
        par_cdhistor = 809 THEN
        ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
   ELSE 
        ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
               craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
   
END PROCEDURE.

/*............................................................................*/

PROCEDURE atualiza_gntarcp:

    DEF INPUT PARAM par_cdtipdoc AS INTEGER                      NO-UNDO.

    
    DO TRANSACTION:
       FOR EACH gntarcp WHERE gntarcp.cdcooper <> 3             AND 
                              gntarcp.dtmvtolt >= aux_dataini   AND
                              gntarcp.dtmvtolt <= aux_datafim   AND
                              gntarcp.cdtipdoc  = par_cdtipdoc  AND
                              gntarcp.flgpcctl  = FALSE         EXCLUSIVE-LOCK:
                           
           gntarcp.flgpcctl = TRUE.

       END.  /* END FOR EACH */
    END.
                   
END PROCEDURE.

/******************************************************************************
 Geracao do tabela de lançamentos contábeis centralizados para envio ao Matera
******************************************************************************/
PROCEDURE pi_insere_det_lct_ctl:
    
    DO TRANSACTION:
    
         FOR EACH tt-detlctctl:
    
              /* Preparando a sessao para conectar-se no Oracle */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                       
              /* Efetuar a chamada a rotina Oracle */
              RUN STORED-PROCEDURE pc_insere_lct_central
                   aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT glb_dtmvtopr,
                             INPUT tt-detlctctl.cdcooper,
                             INPUT tt-detlctctl.cdagenci,
                             INPUT tt-detlctctl.cdhistor,
                             INPUT tt-detlctctl.vllamnto,
                             INPUT tt-detlctctl.nrdconta,
                             INPUT tt-detlctctl.nrctadeb,
                             INPUT tt-detlctctl.nrctacrd,
                             INPUT tt-detlctctl.dsrefere,
                             INPUT tt-detlctctl.intiplct,
                             OUTPUT 0,
                             OUTPUT "").
                                                    
              /* Fechar o procedimento para buscarmos o resultado */
              CLOSE STORED-PROC pc_insere_lct_central
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
              
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                               
              /* Busca possíveis erros */
              ASSIGN glb_dscritic = pc_insere_lct_central.pr_dscritic
                WHEN pc_insere_lct_central.pr_dscritic <> ?. 
         END.
    END.

END PROCEDURE.

/*............................................................................*/