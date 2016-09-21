/* ............................................................................

   Programa: Fontes/crps558.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Marco/2010.                      Ultima atualizacao: 28/09/2015
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Zerar conta movimento das cooperativas na Central.
               Gera relatorio crrl561. 
               
   Observacao: Executado no processo diario. Cadeia Exclusiva.
               Solicitacao => 1 Ordem => 17  (Somente processo da Cecred).

   Alteracoes: 26/05/2010 - Emite relatorio com o lancamento dos historicos 
                            807 e 808 realizadas na conta centralizadora das 
                            cooperativas (Elton).
                            
               28/05/2010 - Alterado layout do relatorio crrl561.lst (Elton).
               
               10/06/2010 - Inclui valor do saldo disponivel do dia 
                            "crapsld.vlsddisp" na soma do lancamentos (Elton).
                            
               02/08/2011 - Incluir glb_flgbatch p/ rodar no COMPEFORA (Ze).
               
               23/04/2012 - Nao cancelar programa se cooperativa nao estiver 
                            cadastrada na Cecred (David).
                            
               06/06/2012 - Preve lancamento futuro antes de Zerar o saldo da
                            conta movimento - Trf. 48653 (Ze).
                
               22/06/2012 - Substituido gncoper por crapcop (Tiago).
               
               27/11/2012 - Incluir tratamento para multa sobre saldo devedor 
                            e juros sobre chq. especial (Ze).
                            
               28/02/2013 - Ajuste no saldo de conta-corrente negativa (Ze).
               
               02/04/2013 - Tratamento para os historicos 37, 38 e 58 (Ze).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               01/04/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               28/09/2015 - incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
............................................................................. */

DEF STREAM str_1. 

{ includes/var_batch.i } 

DEF        VAR aux_flgfirst AS LOGI    INIT TRUE                     NO-UNDO.
DEF        VAR aux_cdagenci AS INTE                                  NO-UNDO.
DEF        VAR aux_cdbccxlt AS INTE                                  NO-UNDO.
DEF        VAR aux_tplotmov AS INTE    INIT 1                        NO-UNDO.

DEF        VAR aux_nrdocmto AS INTE                                  NO-UNDO.
DEF        VAR aux_nrdolote AS INTE                                  NO-UNDO.

DEF        VAR aux_vldsaldo AS DECI                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl561.lst"         NO-UNDO.

DEF        VAR aux_txjurneg AS DECI    DECIMALS 10                   NO-UNDO.
DEF        VAR aux_txjursaq AS DECI    DECIMALS 10                   NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR aux_vljurmes AS DEC                                   NO-UNDO.
DEF        VAR aux_vljursaq AS DEC                                   NO-UNDO.
DEF        VAR aux_vljuresp AS DEC                                   NO-UNDO.

DEF        VAR sub_vllandeb AS DEC                                   NO-UNDO.
DEF        VAR sub_vllancre AS DEC                                   NO-UNDO.
DEF        VAR tot_vllandeb AS DEC                                   NO-UNDO.
DEF        VAR tot_vllancre AS DEC                                   NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF TEMP-TABLE w-lanctos NO-UNDO
         FIELD nrdconta LIKE crapass.nrdconta
         FIELD nmprimtl LIKE crapass.nmprimtl
         FIELD dshistor LIKE craphis.dshistor
         FIELD nrdocmto LIKE craplcm.nrdocmto
         FIELD vllandeb LIKE craplcm.vllanmto
         FIELD vllancre LIKE craplcm.vllanmto.

FORM SKIP(1)
     "LANCAMENTOS EM: " glb_dtmvtolt FORMAT "99/99/9999"
     SKIP(2)
     "CONTA/DV"                         AT 03
     "NOME"                             AT 13
     "HISTORICO"                        AT 45
     "DOCUMENTO"                        AT 64
     "VALOR DEBITO"                     AT 81
     "VALOR CREDITO"                    AT 100 SKIP
     "----------"                       AT 01
     "------------------------------"   AT 13
     "-----------------"                AT 45
     "---------"                        AT 64
     "------------------"               AT 75
     "------------------"               AT 95  
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_lanctos.

FORM w-lanctos.nrdconta   FORMAT "zzzz,zzz,9"  
     w-lanctos.nmprimtl   FORMAT "x(30)"       AT 13
     w-lanctos.dshistor   FORMAT "x(17)"       AT 45
     w-lanctos.nrdocmto   FORMAT "zzzz,zzz9"   AT 64
     w-lanctos.vllandeb                        AT 75
     w-lanctos.vllancre                        AT 95
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_lanctos.
              
  
FORM "------------------"                          AT 75
     "------------------"                          AT 95 SKIP
     sub_vllandeb   FORMAT "zzz,zzz,zzz,zz9.99"    AT 75
     sub_vllancre   FORMAT "zzz,zzz,zzz,zz9.99"    AT 95 SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total_lancamento.

FORM "TOTAL GERAL"                                 AT 59
     tot_vllandeb   FORMAT "zzz,zzz,zzz,zz9.99"    AT 75
     tot_vllancre   FORMAT "zzz,zzz,zzz,zz9.99"    AT 95 SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_totalgeral_lancamento.
     

ASSIGN glb_cdprogra = "crps558"
       glb_flgbatch = false.
       
RUN  fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crabcop  THEN
    DO:
       glb_cdcritic = 651.
       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
       RETURN.  
    END.

/* Carrega taxa de juros do cheque especial, da multa c/c multa s/saque bloq. */

FIND craptab WHERE craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "JUROSNEGAT"   AND
                   craptab.tpregist = 1              AND
                   craptab.cdcooper = glb_cdcooper
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 162.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.  
    END.
        
aux_txjurneg = DECIMAL(SUBSTRING(craptab.dstextab,1,10)) / 100.


FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "JUROSSAQUE"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 162.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            "saque bloq." + " >> log/proc_batch.log").
         RETURN.
     END.

aux_txjursaq = DECIMAL(SUBSTRING(craptab.dstextab,1,10)) / 100.

 

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84. 

VIEW STREAM str_1 FRAME f_cabrel132_1.


DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETURN:

    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
            
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = crapcop.nrctacmp
                           NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO:
                glb_cdcritic = 564.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  glb_dscritic + " - " + crapcop.nmrescop +
                                  " Conta: " + TRIM(STRING(crapcop.nrctacmp,
                                  "zzzz,zzz,9")) + " >> log/proc_batch.log").
                NEXT.  
            END.
            
        ASSIGN aux_vldsaldo = 0
               aux_vljurmes = 0
               aux_vljursaq = 0.
                
        FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper      AND
                           crapsld.nrdconta = crapcop.nrctacmp
                           NO-LOCK NO-ERROR.
                
        IF  AVAIL crapsld THEN
            aux_vldsaldo = crapsld.vlsddisp.
                
        IF  MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
            DO:
                /*   TAXA C/C NEG.   -    Historico  37  */
                IF   crapsld.vlsmnmes < 0   THEN
                     DO:
                         aux_vljurmes = (crapsld.vlsmnmes * aux_txjurneg) * -1.
                         
                         IF   aux_vljurmes > 0 THEN
                              aux_vldsaldo = aux_vldsaldo - aux_vljurmes.
                     END.

                /*   JR.SAQ.DEP.BL   -    Historico 57  */
                IF   crapsld.vlsmnblq < 0   THEN
                     DO:
                         aux_vljursaq = (crapsld.vlsmnblq * aux_txjursaq) * -1.

                         IF   aux_vljursaq > 0 THEN
                              aux_vldsaldo = aux_vldsaldo - aux_vljursaq.
                     END.
 
                /*   JUROS LIM.CRD    -   Historico 38   */
                IF   crapsld.vlsmnesp < 0   THEN
                     DO:
                         FIND LAST craplim WHERE 
                                   craplim.cdcooper = glb_cdcooper       AND
                                   craplim.nrdconta = crapsld.nrdconta   AND
                                   craplim.tpctrlim = 1                  AND
                                   craplim.insitlim = 2 
                                   USE-INDEX craplim2 NO-LOCK NO-ERROR.

                         IF   NOT AVAILABLE craplim THEN
                              DO:
                                  FIND LAST craplim WHERE 
                                       craplim.cdcooper = glb_cdcooper     AND
                                       craplim.nrdconta = crapsld.nrdconta AND
                                       craplim.tpctrlim = 1                AND
                                       craplim.insitlim = 3 
                                       USE-INDEX craplim2 NO-LOCK NO-ERROR.
                                        
                                  IF   NOT AVAILABLE craplim THEN
                                       DO:
                                           glb_cdcritic = 105.
                                           RUN fontes/critic.p.
                                           UNIX SILENT VALUE("echo " +
                                              STRING(TIME,"HH:MM:SS") + " - "
                                              + glb_cdprogra + "' --> '" +
                                              glb_dscritic + " CONTA = " +
                                              STRING(crapsld.nrdconta) +
                                               " >> log/proc_batch.log").
                                           NEXT.
                                       END.    
                              END.
                           
                         FIND craplrt WHERE 
                              craplrt.cdcooper = glb_cdcooper      AND
                              craplrt.cddlinha = craplim.cddlinha  
                              NO-LOCK NO-ERROR.
                       
                         IF   NOT AVAILABLE craplrt THEN
                              DO:
                                  glb_cdcritic = 363.
                                  RUN fontes/critic.p.
                                  UNIX SILENT VALUE("echo " +
                                              STRING(TIME,"HH:MM:SS") + 
                                              " - " + glb_cdprogra + "' --> '" +
                                              glb_dscritic + " CONTA = " +
                                              STRING(crapsld.nrdconta) +
                                              " >> log/proc_batch.log").
                                  NEXT.
                              END.
                      
                         aux_vljuresp = (crapsld.vlsmnesp * 
                                        (craplrt.txmensal / 100)) * -1.
                
                         IF   aux_vljuresp > 0 THEN
                              aux_vldsaldo = aux_vldsaldo - aux_vljuresp.
                     END.
            END.
            
        FOR EACH craplau WHERE craplau.cdcooper  = glb_cdcooper      AND
                               craplau.dtmvtopg <= glb_dtmvtopr      AND
                               craplau.insitlau  = 1                 AND
                               craplau.dsorigem <> "CAIXA"           AND
                               craplau.dsorigem <> "INTERNET"        AND
                               craplau.dsorigem <> "TAA"             AND
                               craplau.dsorigem <> "PG555"           AND
                               craplau.dsorigem <> "CARTAOBB"        AND
                               craplau.dsorigem <> "DAUT BANCOOB"    NO-LOCK:

            FIND craphis WHERE craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor 
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craphis   THEN
                 NEXT.

            IF   craphis.indebcta <> 1   THEN
                 NEXT.
               
            IF   craphis.inautori = 1   THEN
                 NEXT.
           
            IF   crapass.dtdemiss <> ?   THEN
                 NEXT.

            IF   crapsld.dtdsdclq <> ?   THEN
                 NEXT.
                
            aux_vldsaldo = aux_vldsaldo + craplau.vllanaut.
                
        END.    /*  Fim da leitura dos lancamentos automaticos  */

            
        FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper          AND
                               craplcm.nrdconta = crapcop.nrctacmp      AND
                               craplcm.dtmvtolt = glb_dtmvtolt
                               NO-LOCK:
                
            FIND craphis WHERE craphis.cdcooper = glb_cdcooper     AND
                               craphis.cdhistor = craplcm.cdhistor
                               NO-LOCK NO-ERROR.
                
            IF   craphis.indebcre = "C" THEN
                 aux_vldsaldo = aux_vldsaldo + craplcm.vllanmto.
            
            IF   craphis.indebcre = "D" THEN
                 aux_vldsaldo = aux_vldsaldo - craplcm.vllanmto.
        END.
    
        IF  aux_vldsaldo > 0   THEN
            DO:    
                /*** Lancamento de Debito ***/
                RUN pi_cria_craplcm (INPUT crapcop.nrctacmp,
                                     INPUT aux_vldsaldo,
                                     INPUT 807).
                       
                /*** Lancamento de Credito ***/
                RUN pi_cria_craplcm (INPUT crapcop.nrctactl,
                                     INPUT aux_vldsaldo,
                                     INPUT 808).
            END.
    
        IF  aux_vldsaldo < 0  THEN
            DO:    
                ASSIGN aux_vldsaldo = aux_vldsaldo * (-1).
                
                /*** Lancamento de Credito ***/
                RUN pi_cria_craplcm (INPUT crapcop.nrctacmp,
                                     INPUT aux_vldsaldo,
                                     INPUT 808).
                       
                /*** Lancamento de Debito ***/
                RUN pi_cria_craplcm (INPUT crapcop.nrctactl,
                                     INPUT aux_vldsaldo,
                                     INPUT 807).
            END.
    END.
    
    FOR EACH w-lanctos BREAK BY w-lanctos.nrdconta:

        IF  FIRST (w-lanctos.nrdconta) THEN
            DISPLAY STREAM str_1 glb_dtmvtolt WITH FRAME f_cab_lanctos.

        DISPLAY STREAM str_1 w-lanctos WITH FRAME f_lanctos.
        
        DOWN STREAM str_1 WITH FRAME f_lanctos.

        ASSIGN  sub_vllandeb = sub_vllandeb + w-lanctos.vllandeb
                sub_vllancre = sub_vllancre + w-lanctos.vllancre
                tot_vllandeb = tot_vllandeb + w-lanctos.vllandeb
                tot_vllancre = tot_vllancre + w-lanctos.vllancre.

        IF  LAST-OF (w-lanctos.nrdconta) THEN
            DO:
                DISPLAY STREAM str_1  sub_vllandeb
                                      sub_vllancre 
                                      WITH FRAME f_total_lancamento.

                ASSIGN  sub_vllandeb = 0 
                        sub_vllancre = 0.
            END.
    END.

    DISPLAY STREAM str_1 tot_vllandeb 
                         tot_vllancre 
                         WITH FRAME f_totalgeral_lancamento.

    LEAVE.

END. /** Fim Transaction **/

OUTPUT STREAM str_1 CLOSE.
                            
ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.

RUN fontes/imprim.p.

RUN fontes/fimprg.p.


PROCEDURE pi_cria_craplcm:

   DEF INPUT PARAM par_nrdconta AS INT                       NO-UNDO.
   DEF INPUT PARAM par_vlrlamto AS DEC                       NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT                       NO-UNDO.

   ASSIGN   aux_nrdolote = 7100 
            aux_cdagenci = 1   
            aux_cdbccxlt = 85
            aux_nrdocmto = 1.


   IF  aux_flgfirst  THEN 
       DO:
           FIND  craplot WHERE craplot.cdcooper = glb_cdcooper AND
                               craplot.dtmvtolt = glb_dtmvtolt     AND 
                               craplot.cdagenci = aux_cdagenci     AND
                               craplot.cdbccxlt = aux_cdbccxlt     AND
                               craplot.nrdolote = aux_nrdolote
                               USE-INDEX craplot1 NO-LOCK NO-ERROR.
           
           IF  NOT AVAIL craplot THEN
               DO:
                   CREATE craplot.
                   ASSIGN craplot.cdcooper = glb_cdcooper
                          craplot.dtmvtolt = glb_dtmvtolt 
                          craplot.cdagenci = aux_cdagenci
                          craplot.cdbccxlt = aux_cdbccxlt
                          craplot.nrdolote = aux_nrdolote
                          craplot.tplotmov = aux_tplotmov.
                   VALIDATE craplot.
               END.
    
           ASSIGN aux_flgfirst = FALSE.
           
       END. /* FIM do IF flgfirst */

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                      craplot.dtmvtolt = glb_dtmvtolt     AND 
                      craplot.cdagenci = aux_cdagenci     AND
                      craplot.cdbccxlt = aux_cdbccxlt     AND
                      craplot.nrdolote = aux_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

   DO WHILE TRUE:

     FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper  AND
                        craplcm.dtmvtolt = craplot.dtmvtolt  AND
                        craplcm.cdagenci = craplot.cdagenci  AND
                        craplcm.cdbccxlt = craplot.cdbccxlt  AND
                        craplcm.nrdolote = craplot.nrdolote  AND
                        craplcm.nrdctabb = par_nrdconta      AND  
                        craplcm.nrdocmto = aux_nrdocmto
                        USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   AVAILABLE craplcm THEN
          aux_nrdocmto = (aux_nrdocmto + 10000).
     ELSE
          LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */


   CREATE craplcm.
   ASSIGN craplcm.cdcooper = glb_cdcooper
          craplcm.nrdconta = par_nrdconta 
          craplcm.nrdctabb = par_nrdconta 
          craplcm.dtmvtolt = craplot.dtmvtolt
          craplcm.dtrefere = craplot.dtmvtolt
          craplcm.cdagenci = craplot.cdagenci
          craplcm.cdbccxlt = craplot.cdbccxlt
          craplcm.nrdolote = craplot.nrdolote
          craplcm.nrdocmto = aux_nrdocmto
          craplcm.cdhistor = par_cdhistor
          craplcm.vllanmto = par_vlrlamto
          craplcm.nrseqdig = craplot.nrseqdig + 1

          craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.nrseqdig = craplcm.nrseqdig.
   VALIDATE craplcm.
   
   IF par_cdhistor = 808  THEN 
      ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
             craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
   ELSE
      ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
             craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
  
   /*** Somente grava na temp-table as contas movimentos ***/
   IF  craplcm.nrdconta = crapcop.nrctactl  THEN     
       DO:
            FIND craphis WHERE  craphis.cdcooper = glb_cdcooper     AND
                                craphis.cdhistor = craplcm.cdhistor
                                NO-LOCK NO-ERROR.
       
            CREATE w-lanctos.
            ASSIGN w-lanctos.nrdconta = craplcm.nrdconta
                   w-lanctos.nmprimtl = crapass.nmprimtl
                   w-lanctos.dshistor = STRING(craphis.cdhistor,"z999") + "-" + 
                                        craphis.dshistor
                   w-lanctos.nrdocmto = craplcm.nrdocmto.

            IF  craphis.indebcre = "D" THEN
                ASSIGN w-lanctos.vllandeb = craplcm.vllanmto.
            ELSE
                ASSIGN w-lanctos.vllancre = craplcm.vllanmto.

       END.
   
END PROCEDURE.


