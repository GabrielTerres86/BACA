/* ..........................................................................

   Programa: Fontes/crps606.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Agosto/2011.                       Ultima atualizacao: 06/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 100.
               Integrar arquivo com o total da fatura Cartao de Credito BB.

   Alteracoes: 05/10/2011 - Finalizacao do desenvolvimento do programa.
                            (Fabricio) 
               15/04/2013 - Efetuar cópia do arquivo para 
                            /micros/cooperativa/compel/recepcao/retornos
                            (Rodrigo)
               07/05/2013 - Incluir craplau.dsorigem = "CARTAOBB" (Ze).

               06/03/2015 - Foi alterado para inicializar a variavel 
                            aux_nrsequen = craplot.nrseqdig caso ja 
                            exista na craplot. (Jaison/Cechet - SD: 261569)

............................................................................. */

DEF STREAM str_1.   /*  Para arquivo de trabalho */

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tab_nmarqtel AS CHAR    FORMAT "x(25)" EXTENT 99      NO-UNDO.
DEF        VAR aux_contador AS INT     INIT 0                        NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(320)"               NO-UNDO.

DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.

DEF        VAR aux_cdagenci AS INT  INIT 1                           NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT  INIT 100                         NO-UNDO.
DEF        VAR aux_nrdolote AS INT  INIT 6860                        NO-UNDO.

DEF        VAR aux_tpregist AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrcrcard AS DECI                                  NO-UNDO.
DEF        VAR aux_nrsequen AS INT    INIT 0                         NO-UNDO.
DEF        VAR aux_totregis AS INT                                   NO-UNDO.
DEF        VAR aux_totrejei AS INT                                   NO-UNDO.
DEF        VAR aux_vldebito AS DECI                                  NO-UNDO.
                
FORM aux_setlinha  FORMAT "x(320)"
     WITH FRAME AA WIDTH 320 NO-BOX NO-LABELS.

ASSIGN glb_cdprogra = "crps606"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                                      STRING(MONTH(glb_dtmvtolt),"99") +
                                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR. 

IF  NOT AVAILABLE crapcop  THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        RUN fontes/fimprg.p.
        RETURN.
    END.


INPUT STREAM str_1 THROUGH VALUE("ls /micros/" + crapcop.dsdircop + 
             "/compel/recepcao/VIP*.ret 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
   
   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "/usr/coop/" + crapcop.dsdircop + "/integra/" +
                         "VIP-" + STRING(YEAR(glb_dtmvtolt),"9999") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(DAY(glb_dtmvtolt),"99") + "-" +
                         STRING(aux_contador,"999").
   
   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + aux_nmarqdat + 
                     " 2> /dev/null").
                     
   UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + "/micros/" + 
                     crapcop.dsdircop + "/compel/recepcao/retornos").

   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
                     
   tab_nmarqtel[aux_contador] = aux_nmarqdat.

END. /** Fim do DO WHILE TRUE **/  

INPUT STREAM str_1 CLOSE.

IF   aux_contador = 0 THEN
     DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " -  VIP   - " + glb_cdprogra + "' --> '"  +
                      "NAO HA ARQUIVO PARA PROCESSAMENTO." +
                      " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

DO i = 1 TO aux_contador:
    
    ASSIGN aux_totregis = 0
           aux_totrejei = 0.
    
    INPUT STREAM str_1 FROM VALUE(tab_nmarqtel[i]) NO-ECHO.

    TRANS_1:
    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                              ON ERROR  UNDO TRANS_1, LEAVE TRANS_1:
   
        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

        ASSIGN aux_tpregist = SUBSTR(aux_setlinha,1,1).
               
        IF   aux_tpregist = "0" OR     /* Header  */
             aux_tpregist = "9" THEN   /* Trailer */
             NEXT TRANS_1.
       
        ASSIGN aux_totregis = aux_totregis + 1.
        
        ASSIGN aux_diarefer = INTEGER(SUBSTR(aux_setlinha,71,02))
               aux_mesrefer = INTEGER(SUBSTR(aux_setlinha,74,02))
               aux_anorefer = INTEGER(SUBSTR(aux_setlinha,77,04))
               aux_vldebito = DECIMAL(SUBSTR(aux_setlinha,92,14))
               aux_nrcrcard = INTEGER(SUBSTR(aux_setlinha,44,09))
               aux_dtrefere = DATE(aux_mesrefer,aux_diarefer,aux_anorefer)
               NO-ERROR.
        
        IF   ERROR-STATUS:ERROR THEN
             DO:
                 ASSIGN aux_totrejei = aux_totrejei + 1
                        glb_cdcritic = 301.

                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " -  VIP   - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " -  Seq: "  +
                                   STRING(aux_totregis,"zzzz,zz9") + " - " + 
                                   tab_nmarqtel[i] +
                                   " >> " + aux_nmarqlog).
                 NEXT TRANS_1.
             END.

        FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                           crapcrd.nrcrcard = aux_nrcrcard 
                           NO-LOCK NO-ERROR. 

        IF   NOT AVAILABLE crapcrd THEN
             DO: 
                 ASSIGN aux_totrejei = aux_totrejei + 1.
                 NEXT TRANS_1.
             END.
    
        FIND FIRST craplau WHERE craplau.cdcooper = glb_cdcooper      AND
                                 craplau.nrdconta = crapcrd.nrdconta  AND
                                 craplau.dtmvtopg = aux_dtrefere      AND
                                 craplau.cdhistor = 658               AND
                                 craplau.nrdocmto = crapcrd.nrcrcard 
                                 NO-LOCK NO-ERROR.

        IF   AVAIL craplau THEN
             DO:
                 ASSIGN aux_totrejei = aux_totrejei + 1.
                 NEXT TRANS_1.
             END.    
        
        /* CRIACAO DO LAU */
    
        DO WHILE TRUE:
                            
            FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                               craplot.dtmvtolt = glb_dtmvtolt AND
                               craplot.cdagenci = aux_cdagenci AND
                               craplot.cdbccxlt = aux_cdbccxlt AND
                               craplot.nrdolote = aux_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craplot   THEN
                 IF   LOCKED craplot   THEN
                      DO:
                          PAUSE 2 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          CREATE craplot.
                          ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                 craplot.dtmvtopg = aux_dtrefere
                                 craplot.cdagenci = 1
                                 craplot.cdbccxlt = 100
                                 craplot.cdhistor = 658
                                 craplot.cdoperad = "1"
                                 craplot.nrdolote = aux_nrdolote
                                 craplot.tplotmov = 17
                                 craplot.tpdmoeda = 1
                                 craplot.cdcooper = glb_cdcooper.
                      END.
            ELSE
                ASSIGN aux_nrsequen = craplot.nrseqdig.

            LEAVE.
        
        END.  /*  Fim do DO WHILE TRUE  */
 

        ASSIGN aux_nrsequen = aux_nrsequen + 1.
      
        CREATE craplau.
        ASSIGN craplau.cdagenci = craplot.cdagenci
               craplau.cdbccxlt = craplot.cdbccxlt
               craplau.cdbccxpg = craplot.cdbccxpg
               craplau.cdcritic = 0               
               craplau.cdhistor = craplot.cdhistor
               craplau.dtdebito = ?               
               craplau.dtmvtolt = craplot.dtmvtolt
               craplau.dtmvtopg = aux_dtrefere
               craplau.insitlau = 3               
               craplau.nrcrcard = crapcrd.nrcrcard
               craplau.nrdconta = crapcrd.nrdconta    
               craplau.nrdctabb = crapcrd.nrdconta    
               craplau.nrdocmto = crapcrd.nrcrcard
               craplau.nrdolote = craplot.nrdolote
               craplau.nrseqdig = aux_nrsequen
               craplau.nrseqlan = aux_nrsequen
               craplau.tpdvalor = 1                   
               craplau.cdseqtel = ""                   
               craplau.vllanaut = aux_vldebito
               craplau.cdcooper = glb_cdcooper
               craplau.dsorigem = "CARTAOBB"
 
               craplot.nrseqdig = craplot.nrseqdig + 1 
               craplot.qtcompln = craplot.qtcompln + 1 
               craplot.qtinfoln = craplot.qtinfoln + 1 
               craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
               craplot.vlcompcr = 0
               craplot.vlinfodb = craplot.vlcompdb
               craplot.vlinfocr = 0.

    END.  /* FIM DO TRANSACTION */  

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " salvar").

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " -  VIP   - " + glb_cdprogra + "' --> '"  +
                      "ARQUIVO PROCESSADO COM SUCESSO - " +
                      " TOTAL REGISTROS: " + STRING(aux_totregis,"zzz,zz9") +
                      "/TOTAL REJEITADOS: " + STRING(aux_totrejei,"zzz,zz9") +
                      " - " +
                      SUBSTR(tab_nmarqtel[i],R-INDEX(tab_nmarqtel[i],"/") + 1)
                      + " >> " + aux_nmarqlog).
    
END.

RUN fontes/fimprg.p.

/* .......................................................................... */
