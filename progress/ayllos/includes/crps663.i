/*.............................................................................

   Programa: includes/crps663.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2013                       Ultima atualizacao: 25/11/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Procedimentos para o debito de agendamentos de consorcios. 

   Alteracoes: 05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               15/01/2014 - Correcoes e melhorias conforme softdesk 121162
                            (Carlos).
                            
               23/06/2014 - Ajustado cria-crapndb para buscar craplau.cdseqtel
                            (Lucas R.) 
                            
               07/11/2014 - Retirado as declaracoes de variaveis da includes 
                            crps663.i e declarado aqui na debcns.p para evitar 
                            problemas de imcompatibilidade na hora de usar a 
                            includes, alteracoes referentes a automatizacao da 
                            DEBCNS (Tiago SD199974).

               19/11/2015 - Ajustado para que a procedure efetua-debito-consorcio
                            utilize a obtem-saldo-dia convertida em Oracle.
                            (Douglas - Chamado 285228)
                            
               25/11/2015 - Incluida procedure gera_log_execucao_663 para gerar
                            log quando debcns for executada manualmente
                            (Tiago SD338533).
.............................................................................*/


/****************************************************************************/
/******* faz a busca de consorcios nao debitados no processo noturno ********/
/****************************************************************************/
PROCEDURE obtem-consorcio:
         

     FOR EACH craplau WHERE craplau.cdcooper = crapcop.cdcooper AND
                            craplau.dtmvtopg = glb_dtmvtolt     AND
                           (craplau.cdhistor = 1230             OR 
                            craplau.cdhistor = 1231             OR
                            craplau.cdhistor = 1232             OR 
                            craplau.cdhistor = 1233             OR 
                            craplau.cdhistor = 1234)            AND
                            insitlau = 1 
                            NO-LOCK: 

         CASE craplau.cdhistor:
              WHEN 1230 THEN ASSIGN aux_tpconsor = 1.
              WHEN 1231 THEN ASSIGN aux_tpconsor = 2.
              WHEN 1232 THEN ASSIGN aux_tpconsor = 3.
              WHEN 1233 THEN ASSIGN aux_tpconsor = 4.
              WHEN 1234 THEN ASSIGN aux_tpconsor = 5.
         END CASE.

         /* nrdocmto com 22 posicoes - joga como string para poder dar o
            substr corretamente logo abaixo */
         aux_nrdoc = STRING(craplau.nrdocmto,"9999999999999999999999").
         
         FOR EACH crapcns WHERE crapcns.cdcooper = craplau.cdcooper      AND
                                crapcns.tpconsor = aux_tpconsor          AND
                                crapcns.nrdconta = craplau.nrdconta      AND
                                crapcns.nrctrato = DEC(SUBSTR(aux_nrdoc,1,8))
                                NO-LOCK:

             CREATE tt-obtem-consorcio.
             ASSIGN tt-obtem-consorcio.nrdconta = crapcns.nrdconta
                    tt-obtem-consorcio.nrcotcns = crapcns.nrcotcns
                    tt-obtem-consorcio.qtparcns = crapcns.qtparcns
                    tt-obtem-consorcio.vlrcarta = crapcns.vlrcarta
                    tt-obtem-consorcio.vlparcns = craplau.vllanaut
                    tt-obtem-consorcio.nrctacns = crapcns.nrctacns
                    tt-obtem-consorcio.dscooper = CAPS(crapcop.nmrescop)
                    tt-obtem-consorcio.cdcooper = crapcns.cdcooper
                    tt-obtem-consorcio.fldebito = TRUE
                    tt-obtem-consorcio.nrdocmto = craplau.nrdocmto
                    tt-obtem-consorcio.nrdgrupo = crapcns.nrdgrupo
                    tt-obtem-consorcio.nrctrato = crapcns.nrctrato.
     
             /*** busca tipo de consorcio ***/
             CASE crapcns.tpconsor:
                 WHEN 1 THEN ASSIGN tt-obtem-consorcio.dsconsor = "MOTO".
                 WHEN 2 THEN ASSIGN tt-obtem-consorcio.dsconsor = "AUTO".
                 WHEN 3 THEN ASSIGN tt-obtem-consorcio.dsconsor = "PESADOS".
                 WHEN 4 THEN ASSIGN tt-obtem-consorcio.dsconsor = "IMOVEIS".
                 WHEN 5 THEN ASSIGN tt-obtem-consorcio.dsconsor = "SERVICOS".
             END CASE.
     
             FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                      crapass.nrdconta = crapcns.nrdconta
                                      NO-LOCK NO-ERROR.
     
             IF  NOT AVAILABLE crapass  THEN
                 DO:
                    ASSIGN glb_cdcritic = 9.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                    
                    RETURN "NOK".
                 END.
             ELSE
                 ASSIGN tt-obtem-consorcio.nmprimtl = crapass.nmprimtl
                        tt-obtem-consorcio.cdagenci = crapass.cdagenci.
             END.
                 
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE efetua-debito-consorcio:

    DEF INPUT PARAM par_flmanual AS LOGICAL NO-UNDO.

    DEF VAR aux_cdcritic AS INTE NO-UNDO.
    DEF VAR aux_dscritic AS CHAR NO-UNDO.

    TRANS_1:
    
    FOR EACH tt-obtem-consorcio NO-LOCK 
        BREAK BY tt-obtem-consorcio.cdcooper :  
                   
        IF  FIRST-OF(tt-obtem-consorcio.cdcooper) AND par_flmanual THEN
            DO:
                RUN gera_log_execucao_663(INPUT "DEBCNS",
                                      INPUT "Inicio execucao",
                                      INPUT tt-obtem-consorcio.cdcooper,
                                      INPUT "").
            END.
                    
        IF FIRST (tt-obtem-consorcio.cdcooper) THEN
            DO:
                FIND LAST craplot WHERE craplot.cdcooper = tt-obtem-consorcio.cdcooper AND 
                                        craplot.dtmvtolt = glb_dtmvtolt                AND
                                        craplot.nrdolote > 6500                        AND
                                        craplot.nrdolote < 6600                        AND
                                        craplot.tplotmov = 1             
                                        NO-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAILABLE craplot   THEN
                    ASSIGN aux_nrdolot1 = 6500.        
                ELSE
                    ASSIGN aux_nrdolot1 = craplot.nrdolote.
            END.
    
        FOR EACH craplau WHERE craplau.cdcooper = tt-obtem-consorcio.cdcooper AND 
                               craplau.dtmvtopg = glb_dtmvtolt                AND
                               craplau.nrdconta = tt-obtem-consorcio.nrdconta AND 
                               craplau.nrdocmto = tt-obtem-consorcio.nrdocmto AND 
                              (craplau.cdhistor = 1230                        OR 
                               craplau.cdhistor = 1231                        OR
                               craplau.cdhistor = 1232                        OR 
                               craplau.cdhistor = 1233                        OR 
                               craplau.cdhistor = 1234)                       AND
                               craplau.insitlau = 1 
                               BREAK BY craplau.cdagenci
                                     BY craplau.cdbccxlt 
                                     BY craplau.cdbccxpg 
                                     BY craplau.cdhistor
                                     BY craplau.nrdocmto
                               TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
    
                                            
            ASSIGN  flg_ctamigra = FALSE
                    aux_flgentra = FALSE
                    aux_cdcooper = glb_cdcooper
                    aux_cdagenci = craplau.cdagenci
                    aux_nrdolote = aux_nrdolot1
                    aux_cdbccxlt = IF craplau.cdbccxlt = 911 THEN 11
                                   ELSE craplau.cdbccxlt
                    aux_nrdconta = craplau.nrdconta. 
            ASSIGN aux_nrdolote = aux_nrdolot1 + 1. 
            
            DO  WHILE TRUE:
                
                FIND craplot WHERE craplot.cdcooper = craplau.cdcooper AND
                                   craplot.dtmvtolt = glb_dtmvtolt     AND
                                   craplot.cdagenci = aux_cdagenci     AND
                                   craplot.cdbccxlt = aux_cdbccxlt     AND
                                   craplot.nrdolote = aux_nrdolote 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF  NOT AVAILABLE craplot THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                   craplot.cdagenci = aux_cdagenci
                                   craplot.cdbccxlt = aux_cdbccxlt 
                                   craplot.nrdolote = aux_nrdolote      
                                   craplot.cdbccxpg = 11
                                   craplot.tplotmov = 1
                                   craplot.cdcooper = craplau.cdcooper.
                            VALIDATE craplot.
                        END.
                LEAVE.
    
            END.  /*  Fim do DO WHILE TRUE  */
            
            IF  flg_ctamigra THEN
                ASSIGN aux_nrdolot2 = aux_nrdolote.
            ELSE
                ASSIGN aux_nrdolot1 = aux_nrdolote.
                    
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

            /* Utilizar o tipo de busca A, para carregar do dia anterior
              (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
            RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT craplau.cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT 1, /* nrdcaixa */
                                         INPUT glb_cdoperad, 
                                         INPUT craplau.nrdconta,
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

                   ASSIGN glb_dscritic = aux_dscritic.

                   RUN cria-crapndb.

                   NEXT.
               END.

            /* cria lancamento apenas se saldo em CC for maior que zero */
            FIND FIRST wt_saldos NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE wt_saldos  THEN
            DO:
                ASSIGN glb_dscritic = "Nao foi possivel consultar saldo para " +
                                      "operacao.".
                    
                RUN cria-crapndb.
    
                NEXT.
            END.

            ASSIGN aux_nrdocmto = craplau.nrdocmto.

            IF  craplau.vllanaut > (wt_saldos.vlsddisp + wt_saldos.vllimcre) THEN 
                DO: 
                    ASSIGN glb_dscritic = "Nao ha saldo suficiente para a operacao.".
    
                    RUN cria-crapndb.
                END.
            ELSE                          
                DO:
                    DO WHILE TRUE:
            
                        IF  CAN-FIND(craplcm WHERE 
                                craplcm.cdcooper = craplau.cdcooper AND
                                craplcm.dtmvtolt = glb_dtmvtolt     AND
                                craplcm.cdagenci = craplot.cdagenci AND
                                craplcm.cdbccxlt = craplot.cdbccxlt AND
                                craplcm.nrdolote = craplot.nrdolote AND
                                craplcm.nrdctabb = aux_nrdconta     AND
                                craplcm.nrdocmto = aux_nrdocmto
                                USE-INDEX craplcm1)     THEN
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
                           craplcm.vllanmto = craplau.vllanaut
                           craplcm.nrseqdig = craplot.nrseqdig + 1
                           craplcm.cdcooper = craplau.cdcooper 
                           craplcm.cdpesqbb = "Lote " + 
                                              STRING(DAY(craplau.dtmvtolt),"99")      +
                                              "/"                                     +
                                              STRING(MONTH(craplau.dtmvtolt),"99")    +
                                              "-"                                     +
                                              STRING(aux_cdagenci,"999") + "-"        +
                                              STRING(craplau.cdbccxlt,"999") + "-"    +
                                              STRING(craplau.nrdolote,"999999") + "-" +
                                              STRING(craplau.nrseqdig,"99999") + "-"  +
                                              STRING(craplau.nrdocmto)
                                                
                           craplot.qtcompln = craplot.qtcompln + 1
                           craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
                           craplot.qtinfoln = craplot.qtinfoln + 1
                           craplot.vlinfodb = craplot.vlinfodb + craplau.vllanaut
                           craplot.nrseqdig = craplcm.nrseqdig
                           
                           craplau.insitlau = 2
                           craplau.nrcrcard = IF craplau.nrcrcard = 0 THEN  
                                                 craplcm.nrdolote
                                              ELSE craplau.nrcrcard
                           craplau.nrseqlan = craplcm.nrseqdig
                           craplau.dtdebito = glb_dtmvtolt
                           craplau.dsorigem = "DEBCNS".
                    VALIDATE craplcm.
                
                END. /* fim else */
        END. /* fim for each craplau */

                                     
        IF  LAST-OF(tt-obtem-consorcio.cdcooper) AND par_flmanual THEN
            DO:
                RUN gera_log_execucao_663(INPUT "DEBCNS",
                                      INPUT "Fim execucao",
                                      INPUT tt-obtem-consorcio.cdcooper,
                                      INPUT "").                        
            END.          


    END. /* fim for each tt-obtem-consorcio */

    RETURN "OK".

END PROCEDURE.

PROCEDURE imprime-consorcios:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.

    DEF VAR aux_cddopcao AS LOGICAL FORMAT "S/N"                       NO-UNDO.
    DEF VAR aux_registro AS LOG     INIT NO                            NO-UNDO.
    
    FIND FIRST tt-obtem-consorcio WHERE 
               par_cdcooper = 0   OR 
               tt-obtem-consorcio.cdcooper = par_cdcooper 
               NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL tt-obtem-consorcio THEN
        RETURN.
    
    IF  glb_inproces = 1  THEN
        ASSIGN aux_dtrefere = glb_dtmvtolt.
    ELSE
        ASSIGN aux_dtrefere = glb_dtmvtopr.
                             
    { includes/cabrel132_1.i }

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
        
    VIEW STREAM str_1 FRAME f_cabrel132_1.
 
    FOR EACH tt-obtem-consorcio WHERE 
             par_cdcooper = 0   OR 
             tt-obtem-consorcio.cdcooper = crapcop.cdcooper
             NO-LOCK BREAK BY tt-obtem-consorcio.cdcooper
                           BY tt-obtem-consorcio.fldebito
                           BY tt-obtem-consorcio.cdagenci
                           BY tt-obtem-consorcio.nrdconta 
                           BY tt-obtem-consorcio.dsconsor 
                           BY tt-obtem-consorcio.nrcotcns 
                           BY tt-obtem-consorcio.qtparcns 
                           BY tt-obtem-consorcio.vlrcarta 
                           BY tt-obtem-consorcio.vlparcns:
        
        ASSIGN aux_registro = YES.
       
        FIND FIRST crapcop WHERE 
                   crapcop.cdcooper = tt-obtem-consorcio.cdcooper 
                   NO-LOCK NO-ERROR.

        IF  AVAIL crapcop THEN
            ASSIGN aux_dscooper = CAPS(crapcop.nmrescop).

        IF  FIRST-OF(tt-obtem-consorcio.cdcooper) THEN
            DO:
                ASSIGN aux_qtefetua = 0
                       aux_vlefetua = 0.
                
                ASSIGN aux_dstiptra = "CONSORCIOS".

                DISP STREAM str_1 aux_dstiptra
                                  aux_dscooper WITH FRAME f_transacao1.

            END.
  
        IF  FIRST-OF(tt-obtem-consorcio.fldebito) THEN
            DO:
                ASSIGN aux_dstitulo = IF tt-obtem-consorcio.fldebito THEN
                                         " EFETUADOS "
                                      ELSE
                                          "NAO EFETUADOS ".
                DISP STREAM str_1 aux_dtrefere aux_dstitulo
                     WITH FRAME f_titulo.
                   
                VIEW STREAM str_1 FRAME f_transacao2.
                  
           END. 

         
        ASSIGN aux_qtefetua = aux_qtefetua + 1
               aux_vlefetua = aux_vlefetua + tt-obtem-consorcio.vlparcns.
        
        IF  tt-obtem-consorcio.fldebito  THEN
            DO:                               
                DISP STREAM str_1 tt-obtem-consorcio.cdagenci
                                  tt-obtem-consorcio.nrdconta
                                  tt-obtem-consorcio.nrctacns
                                  tt-obtem-consorcio.nmprimtl               
                                  tt-obtem-consorcio.dsconsor
                                  tt-obtem-consorcio.nrdgrupo
                                  tt-obtem-consorcio.nrcotcns
                                  tt-obtem-consorcio.vlparcns
                                  WITH FRAME f_efetuados.
                                  
                DOWN STREAM str_1 WITH FRAME f_efetuados.   
            END.
        ELSE
            DO:
                DISP STREAM str_1 tt-obtem-consorcio.cdagenci
                                  tt-obtem-consorcio.nrdconta
                                  tt-obtem-consorcio.nrctacns
                                  tt-obtem-consorcio.nmprimtl               
                                  tt-obtem-consorcio.dsconsor
                                  tt-obtem-consorcio.nrdgrupo
                                  tt-obtem-consorcio.nrcotcns
                                  tt-obtem-consorcio.vlparcns
                                  tt-obtem-consorcio.dscritic
                                  WITH FRAME f_nao_efetuados.    

                DOWN STREAM str_1 WITH FRAME f_nao_efetuados.
            END.

        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN 
            DO:
                PAGE STREAM str_1.
        
                DISP STREAM str_1 aux_dstitulo 
                                  aux_dtrefere WITH FRAME f_titulo.
                
                DISP STREAM str_1 aux_dstiptra WITH FRAME f_transacao.
            END.
        
        IF  LAST-OF(tt-obtem-consorcio.cdcooper) THEN
            DISP STREAM str_1 aux_qtefetua aux_vlefetua
                 WITH FRAME f_total.
        
    END.

    OUTPUT STREAM str_1 CLOSE.

    IF  glb_inproces = 1  THEN
        DO: 
            UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nmarquiv).
                     
            HIDE MESSAGE NO-PAUSE.
        END.

    ASSIGN glb_nrcopias = 1            
           glb_nmformul = "132col"     
           glb_nmarqimp = aux_nmarqimp.

    IF  par_cdcooper = 0 THEN /* PROCESSO */
        DO:
            RUN fontes/imprim.p.               
        END.
    ELSE
        DO:
            RUN fontes/imprim_unif.p (INPUT par_cdcooper).    
        END.

    IF  aux_registro  THEN
        RETURN "OK".
    ELSE
        RETURN "NOK".

END PROCEDURE.

PROCEDURE cria-crapndb:

    ASSIGN aux_cdcritic = "01". /** Insuficiencias de fundos **/
     
    FIND FIRST crapcop WHERE 
               crapcop.cdcooper = tt-obtem-consorcio.cdcooper 
               NO-LOCK NO-ERROR.
                             
    IF  AVAIL crapcop THEN                                     
        ASSIGN aux_nrctasic = STRING(crapcop.cdagesic,"9999").
    
    CREATE crapndb.
    ASSIGN crapndb.cdcooper = craplau.cdcooper
           crapndb.dtmvtolt = glb_dtmvtolt 
           crapndb.nrdconta = craplau.nrdconta
           crapndb.cdhistor = craplau.cdhistor
           crapndb.flgproce = FALSE.

    ASSIGN crapndb.dstexarq = "F"                              +
           STRING(craplau.nrdocmto,"9999999999999999999999")   +
                  FILL(" ",3)                                  +
                  aux_nrctasic                                 +
                  STRING(tt-obtem-consorcio.nrctacns,"999999") +
                  FILL(" ",8)                                +
                  STRING(YEAR(glb_dtmvtolt),"9999")          +
                  STRING(MONTH(glb_dtmvtolt),"99")           +
                  STRING(DAY(glb_dtmvtolt),"99")             +
                  STRING(craplau.vllanaut * 100,       
                         "999999999999999")                  +
                         aux_cdcritic + STRING(craplau.cdseqtel,"x(60)") +
                  FILL(" ",16) +
                         STRING(aux_cdagenci,"99")           +
                  "J5"                                       + /* Codigo da empresa */
                  FILL(" ",8) + "0".
    
    ASSIGN craplau.insitlau = 3
           craplau.dtdebito = glb_dtmvtolt
           craplau.nrcrcard = IF craplau.nrcrcard = 0
                              THEN craplot.nrdolote
                              ELSE craplau.nrcrcard
           tt-obtem-consorcio.fldebito = FALSE
           tt-obtem-consorcio.dscritic = glb_dscritic.
    VALIDATE crapndb.

END PROCEDURE.

PROCEDURE gera_log_execucao_663:

    DEF INPUT PARAM par_nmprgexe    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_indexecu    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_tpexecuc    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "log/prcctl_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo " + "Manual - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " '" +  
                      par_tpexecuc + "' - '" + 
                      par_nmprgexe + "': " + 
                      par_indexecu +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.
