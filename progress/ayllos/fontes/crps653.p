/* .............................................................................

   Programa: Fontes/crps653.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo      
   Data    : Julho/13.                           Ultima atualizacao: 18/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 082.
               Efetuar os lancamentos pendentes de Bloqueio Judicial.

   Alteracoes: 18/11/2015 - Ajustado para que seja utilizado o obtem-saldo-dia
                            convertido em Oracle. (Douglas - Chamado 285228)
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllanaut AS DECIMAL                               NO-UNDO.
DEF        VAR aux_cddebtot AS INT                                   NO-UNDO.

DEF        VAR aux_cdcritic LIKE crapcri.cdcritic                    NO-UNDO.
DEF        VAR aux_dscritic LIKE crapcri.dscritic                    NO-UNDO.

DEF BUFFER crabass FOR crapass.
DEF BUFFER crablau FOR craplau.

ASSIGN glb_cdprogra = "crps653".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN
    RETURN.

TRANS_1:

FOR EACH craplau WHERE craplau.cdcooper  = glb_cdcooper      AND
                       craplau.dtmvtopg <= glb_dtmvtolt      AND
                       craplau.insitlau  = 1                 AND
                       craplau.dsorigem  = "BLOQJUD"  
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
    
    ASSIGN aux_nrdconta = craplau.nrdconta
           glb_cdcritic = 0
           aux_vllanaut = 0
           aux_cddebtot = 0.

    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = craplau.cdcooper AND
                          crapass.nrdconta = craplau.nrdconta NO-LOCK NO-ERROR.

       IF  NOT AVAILABLE crapass   THEN
           glb_cdcritic = 9.
       ELSE
       IF  crapass.dtelimin <> ?   THEN
           glb_cdcritic = 410.
       ELSE
       IF  CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
           glb_cdcritic = 695.
       ELSE
       IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               FIND FIRST craptrf WHERE craptrf.cdcooper = crapass.cdcooper AND
                                        craptrf.nrdconta = crapass.nrdconta AND
                                        craptrf.tptransa = 1                AND
                                        craptrf.insittrs = 2
                                        USE-INDEX craptrf1 NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptrf THEN
                    glb_cdcritic = 95.
               ELSE
                    DO:
                        aux_nrdconta = craptrf.nrsconta.
                        NEXT.
                    END.
           END.
           
       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */
    
    IF   glb_cdcritic = 0 THEN
         DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
            /* Utilizar o tipo de busca A, para carregar do dia anterior
              (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
            RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT glb_cdcooper,
                                         INPUT 0, /* cdagenci */
                                         INPUT 0, /* nrdcaixa */
                                         INPUT glb_cdoperad, 
                                         INPUT aux_nrdconta,
                                         INPUT glb_dtmvtolt,
                                         INPUT "A", /* Tipo Busca */
                                         OUTPUT 0,
                                         OUTPUT "").

            CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                                      WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
                   aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                                      WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
    
            IF aux_cdcritic <> 0  OR 
               aux_dscritic <> "" THEN
               DO: 
                   IF  aux_dscritic = "" THEN
                       ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".
                    
                   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                     " - " + glb_cdprogra + "' --> '"  +
                                     aux_dscritic + " >> log/proc_batch.log").
                   
                   UNDO, RETURN.
               END.
        
             /* cria lancamento apenas se saldo em CC for maior que zero */
             FIND FIRST wt_saldos NO-LOCK NO-ERROR.
             IF AVAIL wt_saldos THEN
             DO:
                 IF   wt_saldos.vlsddisp >= craplau.vllanaut THEN
                      ASSIGN aux_vllanaut = craplau.vllanaut
                             aux_cddebtot = 1. /* Debito Total */
                 ELSE
                 IF   wt_saldos.vlsddisp > 0  THEN
                      ASSIGN aux_vllanaut = wt_saldos.vlsddisp
                             aux_cddebtot = 2. /* Debito Parcial */
             END.
             ELSE     
                  ASSIGN glb_cdcritic = 10.
         END.        

    
    IF  glb_cdcritic = 0   THEN
        DO:
            DO WHILE TRUE:

               FIND craplot WHERE craplot.cdcooper = craplau.cdcooper   AND
                                  craplot.dtmvtolt = glb_dtmvtolt       AND
                                  craplot.cdagenci = 1                  AND
                                  craplot.cdbccxlt = 100                AND
                                  craplot.nrdolote = 6875       
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF  NOT AVAILABLE craplot   THEN
                   IF   LOCKED craplot   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = 6875
                                   craplot.cdbccxpg = 11
                                   craplot.tplotmov = 1
                                   craplot.cdcooper = craplau.cdcooper.
                        END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            ASSIGN aux_nrdocmto = craplau.nrdocmto.

            DO WHILE TRUE:
        
               IF   CAN-FIND(craplcm WHERE 
                                   craplcm.cdcooper = craplau.cdcooper  AND
                                   craplcm.dtmvtolt = glb_dtmvtolt      AND
                                   craplcm.cdagenci = craplot.cdagenci  AND
                                   craplcm.cdbccxlt = craplot.cdbccxlt  AND
                                   craplcm.nrdolote = craplot.nrdolote  AND
                                   craplcm.nrdctabb = aux_nrdconta      AND
                                   craplcm.nrdocmto = aux_nrdocmto
                                   USE-INDEX craplcm1)                  THEN
                    DO:
                        aux_nrdocmto = aux_nrdocmto + 100000000.
                        NEXT.
                    END.
              
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
        
            CREATE craplcm.
            ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrdconta = aux_nrdconta
                   craplcm.nrdctabb = craplau.nrdctabb
                   craplcm.nrdctitg = STRING(craplau.nrdctabb,"99999999")
                   craplcm.nrdocmto = aux_nrdocmto
                   craplcm.cdhistor = craplau.cdhistor
                   craplcm.vllanmto = aux_vllanaut
                   craplcm.nrseqdig = craplot.nrseqdig + 1
                   craplcm.cdcooper = craplau.cdcooper 
                   craplcm.cdpesqbb = "Lote " + 
                                      STRING(DAY(craplau.dtmvtolt),"99") +
                                      "/" +
                                      STRING(MONTH(craplau.dtmvtolt),"99") +
                                      "-" +
                                      STRING(craplot.cdagenci,"999") + "-" +
                                      STRING(craplau.cdbccxlt,"999") + "-" +
                                      STRING(craplau.nrdolote,"999999") + "-" +
                                      STRING(craplau.nrseqdig,"99999") + "-" +
                                      STRING(craplau.nrdocmto)
                                        
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.vlcompdb = craplot.vlcompdb + aux_vllanaut
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.vlinfodb = craplot.vlinfodb + aux_vllanaut
                   craplot.nrseqdig = craplcm.nrseqdig.
                   
            IF   aux_cddebtot = 1 THEN   /* Debito Total */
                 ASSIGN craplau.insitlau = 2
                        craplau.nrcrcard = craplcm.nrdolote
                        craplau.nrseqlan = craplcm.nrseqdig
                        craplau.dtdebito = glb_dtmvtolt.
            
            IF   aux_cddebtot = 2 THEN   /* Debito Parcial */
                 ASSIGN craplau.vllanaut = 
                                 (craplau.vllanaut - aux_vllanaut).
                   
            DO WHILE TRUE:

               FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper  AND
                                  crapsld.nrdconta = aux_nrdconta
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                    
               IF   NOT AVAILABLE crapsld THEN
                    DO:
                        IF   LOCKED crapsld   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 10.
        
                                 UNIX SILENT VALUE("echo " + 
                                      STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '"  +
                                      glb_dscritic + " >> log/proc_batch.log").
         
                                 UNDO, RETURN.
                             END.
                         END.
                    ELSE
                         ASSIGN crapsld.vlblqjud = crapsld.vlblqjud +
                                                   craplcm.vllanmto.
                    LEAVE.                               
                                                   
                 END.

            RUN baixa_craplau_blqjud (INPUT crapass.nrdconta,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT craplau.cdseqtel,
                                      INPUT aux_vllanaut).
        END.
    ELSE
        DO:
             ASSIGN craplau.insitlau = 3
                    craplau.dtdebito = glb_dtmvtolt
                    craplau.cdcritic = glb_cdcritic.
        END.
END.  /* Fim da leitura dos lancamentos automaticos  e da transacao  */

RUN fontes/fimprg.p.


PROCEDURE baixa_craplau_blqjud: 

  DEF INPUT PARAM par_nrdconta AS INT           NO-UNDO.
  DEF INPUT PARAM par_nrcpfcgc AS DEC           NO-UNDO.
  DEF INPUT PARAM par_cdseqtel AS CHAR          NO-UNDO.     
  DEF INPUT PARAM par_vllanaut AS DEC           NO-UNDO.
  
  FOR EACH crabass WHERE crabass.cdcooper = glb_cdcooper AND
                         crabass.nrcpfcgc = par_nrcpfcgc
                         NO-LOCK:
  
      IF   crabass.nrdconta = par_nrdconta THEN
           NEXT.
      
      FOR EACH crablau WHERE crablau.cdcooper = crabass.cdcooper AND
                             crablau.nrdconta = crabass.nrdconta AND
                             crablau.dtmvtopg <= glb_dtmvtolt    AND
                             crablau.insitlau = 1                AND
                             crablau.dsorigem = "BLOQJUD"
                             EXCLUSIVE-LOCK:

          IF   crablau.cdseqtel = par_cdseqtel THEN
               DO:
                   IF   aux_cddebtot = 1 THEN   /* Debito Total */
                        ASSIGN crablau.insitlau = 3
                               crablau.dtdebito = glb_dtmvtolt.
                   ELSE
                   IF   aux_cddebtot = 2 THEN   /* Debito Parcial */
                        ASSIGN crablau.vllanaut = 
                                 (crablau.vllanaut - par_vllanaut).
               END.           
      END.
      
      RELEASE crablau.

  END.
  
END PROCEDURE.

/* .......................................................................... */
