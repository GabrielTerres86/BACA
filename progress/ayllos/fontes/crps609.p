/* ...........................................................................

   Programa: Fontes/crps609.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Gabriel
   Data    : Outubro/2011                          Ultima alteracao: 03/10/2017

   Dados referentes ao programa:

   Frequencia: Mensal. Solicitacao 83. Ordem 8. Cadeia Exclusiva.

   Objetivo  : Ira rodar MENSALMENTE na CENTRAL. 
               Efetuar acerto de tarifas entre cooperativas referente a 
               operacao de deposito.
                                                            
   Alteracoes: 10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               11/03/2014 - Tratado para mostrar a mensagem "==> TARIFA 
                            DEPOSITO INTERCOOPERATIVO NAO CADASTRADA ." quando
                            o valor da tarifa for 0. (Reinert)
                            
               04/07/2014 - Buscar tpoperac = 5 (Deposito em cheque) na crapldt. 
                            (Reinert)
                            
               09/07/2014 - Desconsiderar depositos em cheque estornados (Diego).
               
               21/07/2014 - Adicionado para tratar tarifa de operacoes de 
                            deposito em TAA. (Reinert)
                            
               20/06/2017 - Geraçao de tabela com lançamentos contábeis centralizados de 
                            cada cooperativa filiada na central para posterior geraçao de 
                            arquivo para o Matera. (Jonatas-Supero)                                  
                            
               03/10/2017 - SD762958 - Ajuste no rateio das tarifas por PA (Marcos-Supero)             
............................................................................ */

{ includes/var_batch.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0118tt.i }
{ sistema/generico/includes/var_oracle.i }


DEF STREAM str_1.


DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_dtmvtini AS DATE                                        NO-UNDO. 
DEF VAR aux_contareg AS INTE                                        NO-UNDO.
DEF VAR aux_cntrgtaa AS INTE                                        NO-UNDO.
DEF VAR aux_vllanmto AS DECI                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_nrctactl AS INTE                                        NO-UNDO.
DEF VAR aux_vltarifa AS DECI EXTENT 2 INIT[0,0]                     NO-UNDO.
DEF VAR aux_dsorigem AS CHAR EXTENT 2                               NO-UNDO.
DEF VAR aux_contador AS INTE INIT 0                                 NO-UNDO.
DEF VAR aux_contado2 AS INTE INIT 1                                 NO-UNDO.
DEF VAR aux_qtdlancm AS INTE INIT 1                                 NO-UNDO.
DEF VAR aux_indictaa AS INTE INIT 0                                 NO-UNDO.
DEF VAR aux_indicaix AS INTE INIT 0                                 NO-UNDO.
DEF VAR aux_lsttarif AS CHAR                                        NO-UNDO.

/* Includes do cabecalho do relatorio */
DEF VAR rel_nmempres AS CHAR       FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmresemp AS CHAR       FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS CHAR       FORMAT "x(40)" EXTENT 5          NO-UNDO.

DEF VAR rel_nrmodulo AS INT        FORMAT "9"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR       FORMAT "x(15)" EXTENT 5         
                               INIT ["DEP. A VISTA   ","CAPITAL       ",
                                     "EMPRESTIMOS    ","DIGITACAO     ",
                                     "GENERICO       "]             NO-UNDO.

DEF VAR h-b1wgen0118 AS HANDLE                                      NO-UNDO.

DEF TEMP-TABLE tt-detlctctl NO-UNDO
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

ASSIGN glb_cdprogra = "crps609".

RUN fontes/iniprg.p.

IF   glb_cdcritic  > 0   THEN
     RETURN.
        
/* Primeiro dia do mes */
ASSIGN aux_dtmvtini = DATE( MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt) ).


FOR EACH crapthi WHERE crapthi.cdcooper = 3        AND
                       crapthi.cdhistor = 1007     AND
                     ( crapthi.dsorigem = "CAIXA"  OR
                       crapthi.dsorigem = "CASH" ) NO-LOCK:
    ASSIGN aux_contador = aux_contador + 1
           aux_vltarifa[aux_contador] = crapthi.vltarifa.

    IF crapthi.dsorigem = "CASH" THEN
       ASSIGN aux_dsorigem[aux_contador] = "TAA"
              aux_indictaa = aux_contador.
    ELSE
       ASSIGN aux_dsorigem[aux_contador] = crapthi.dsorigem
              aux_indicaix = aux_contador.

END.

Deposito: DO TRANSACTION ON ERROR UNDO, RETURN:

    RUN sistema/generico/procedures/b1wgen0118.p PERSISTENT SET h-b1wgen0118.

    /* Busca dados da cooperativa */
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
            
        /* Lancamentos do mes (Depositos) - Agencias Diferentes */
        FOR EACH crapldt WHERE crapldt.cdcooper  = crapcop.cdcooper AND   
                              (crapldt.tpoperac  = 1                OR
                               crapldt.tpoperac  = 5)               AND
                               crapldt.cdagerem <> crapldt.cdagedst AND
                               crapldt.dttransa >= aux_dtmvtini     AND 
                               crapldt.dttransa <= glb_dtmvtolt     AND
                        /* Desconsiderar estorno de deposito em cheque */ 
                               crapldt.flgestor  = FALSE        NO-LOCK
                               BREAK BY crapldt.cdagedst
                                     BY crapldt.cdpacrem:

            IF   FIRST-OF (crapldt.cdagedst)   THEN
                 DO:
                    /* Cooperativa destino */
                    FIND crabcop WHERE crabcop.cdagectl = crapldt.cdagedst 
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL crabcop   THEN
                         ASSIGN aux_cdcooper = crabcop.cdcooper
                                aux_nrctactl = crabcop.nrctactl.
                 END.
                 
            /* Conta destino */
            FIND crapass WHERE crapass.cdcooper = aux_cdcooper   AND
                               crapass.nrdconta = crapldt.nrctadst  
                               NO-LOCK NO-ERROR.
                        
            IF crapldt.cdpacrem = 91 THEN
              ASSIGN aux_cntrgtaa = aux_cntrgtaa + 1
                     aux_contador = aux_indictaa.
            ELSE
              ASSIGN aux_contareg = aux_contareg + 1
                     aux_contador = aux_indicaix.

            CREATE tt-crapldt.
            BUFFER-COPY crapldt TO tt-crapldt.
           
                   /* PA destino */
            ASSIGN tt-crapldt.cdpacdst = crapass.cdagenci WHEN AVAIL crapass
                   /* Valor da Tarifa */
                   tt-crapldt.vllanmto = aux_vltarifa[aux_contador]
                   tt-crapldt.dsorigem = aux_dsorigem[aux_contador].    


            IF   LAST-OF (crapldt.cdagedst) OR
                 (crapldt.cdpacrem = 91 AND LAST-OF (crapldt.cdpacrem)) THEN  
                 DO:
                     IF   LAST-OF (crapldt.cdagedst) AND
                         (crapldt.cdpacrem = 91 AND LAST-OF (crapldt.cdpacrem)) THEN  
                        ASSIGN aux_qtdlancm = 2.
                     ELSE
                        ASSIGN aux_qtdlancm = 1.

                     IF   aux_vltarifa[aux_contador] <> 0   THEN
                          DO:
                              DO aux_contado2 = 1 TO aux_qtdlancm:

                                 IF  crapldt.cdpacrem = 91 AND aux_contado2 = 1 THEN
                                     ASSIGN aux_vllanmto = 
                                            aux_cntrgtaa * aux_vltarifa[aux_indictaa]
                                            aux_cntrgtaa = 0.
                                 ELSE
                                     ASSIGN aux_vllanmto = 
                                            aux_contareg * aux_vltarifa[aux_indicaix]
                                            aux_contareg = 0.
    
                                 IF  aux_vllanmto > 0  THEN
                                     DO:
                                         RUN deposito-tarifa IN h-b1wgen0118 
                                               (INPUT crapcop.cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_cdprogra,
                                                INPUT 1, /* Ayllos */
                                                INPUT crapldt.cdagedst,
                                                INPUT aux_vllanmto,
                                                INPUT glb_dtmvtolt,
                                                INPUT FALSE,
                                                OUTPUT TABLE tt-erro).
                         
                                         IF   RETURN-VALUE <> "OK"   THEN
                                              DO:
                                                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                             
                                                  IF   AVAIL tt-erro   THEN
                                                       ASSIGN aux_dscritic = 
                                                                tt-erro.dscritic.
                                                  ELSE
                                                       ASSIGN aux_dscritic = "Erro na cobranca da tarifa de deposito.".
            
                                                  UNIX SILENT VALUE ("echo "       +
                                                    STRING(TIME,"HH:MM:SS")   + " - " +
                                                    glb_cdprogra  + "' --> '" + 
                                                    aux_dscritic  + " >> log/proc_batch.log").
                                                                                 
            
                                                  DELETE PROCEDURE h-b1wgen0118.
            
                                                  UNDO, LEAVE Deposito.
                                              END.

                                     END.
                              END.                              
                          END.                                  
                 END.                                           
        END.
    END.

    DELETE PROCEDURE h-b1wgen0118.

    RUN emite-relatorio-609.
    
    RUN pi_insere_det_lct_ctl.

END.

RUN fontes/fimprg.p. 

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
                            (INPUT glb_dtmvtolt,
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

/******************************************************************************
 Geracao do relatorio 609 - Relatorio de Tarifas de Depositos
******************************************************************************/
PROCEDURE emite-relatorio-609:    

    DEF VAR aux_indebcre AS CHAR                                    NO-UNDO.
    DEF VAR aux_vllanmt2 AS DECI                                    NO-UNDO.       

    DEF BUFFER crabcop FOR crapcop.
    
    FORM crapcop.nrctactl    COLUMN-LABEL "CONTA DEBITO"
         crabcop.nrctactl    COLUMN-LABEL "CONTA CREDITO"
         craphis.dshistor    COLUMN-LABEL "HISTORICO"  FORMAT "x(20)"
         aux_dsorigem[1]     COLUMN-LABEL "ORIGEM"     FORMAT "x(6)"
         aux_vllanmto        COLUMN-LABEL "VALOR"      FORMAT "zzz,zzz,zz9.99"
         aux_indebcre        COLUMN-LABEL "D/C"        FORMAT "x(1)"
         tt-crapldt.cdpacrem COLUMN-LABEL "PA"         FORMAT "z,zz9"
         aux_vllanmt2        COLUMN-LABEL "VALOR"      FORMAT "zzz,zzz,zz9.99"
         WITH DOWN WIDTH 132 FRAME f_list609.

    FORM aux_indebcre         FORMAT "x(1)"        
         tt-crapldt.cdpacrem  FORMAT "z,zz9" 
         aux_vllanmto         FORMAT "zzz,zzz,zz9.99"      
         WITH DOWN NO-LABEL WIDTH 132 COLUMN 73 FRAME f_list609-2.

    ASSIGN glb_cdcritic    = 0
           glb_cdempres    = 11
           glb_cdrelato[1] = 609
            
           aux_vllanmto    = 0
           aux_nmarqimp    = "rl/crrl609.lst".


    { includes/cabrel132_1.i }    
       
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.

    DO aux_contador = 1 TO 2:

        IF  aux_vltarifa[aux_contador] <> 0 THEN
            LEAVE.
        ELSE
            DO:
                IF  aux_contador = 2 THEN
                    DO:
                        PUT STREAM str_1
                            "==> TARIFA DEPOSITO INTERCOOPERATIVO NAO CADASTRADA .".
            
                        OUTPUT STREAM str_1 CLOSE.
            
                        ASSIGN glb_nrcopias = 1
                               glb_nmformul = "132col"
                               glb_nmarqimp = aux_nmarqimp.
                    
                        RUN fontes/imprim.p.
            
                        RETURN.
                    END.   
            END.
    END.
    
    FIND craphis WHERE craphis.cdcooper = 3      AND
                       craphis.cdhistor = 1007   NO-LOCK NO-ERROR.

    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK,

        EACH crabcop WHERE crabcop.cdcooper <> crapcop.cdcooper   AND
                           crabcop.cdcooper <> 3                  NO-LOCK:
     
        DO aux_contador = 1 TO 2:        
            
            IF  aux_vltarifa[aux_contador] = 0 THEN
                NEXT.

            /* Total dos lancamentos */
            FOR EACH tt-crapldt WHERE tt-crapldt.cdagedst = crapcop.cdagectl   AND
                                      tt-crapldt.cdagerem = crabcop.cdagectl   AND
                                      tt-crapldt.dsorigem = aux_dsorigem[aux_contador]
                                      NO-LOCK:
    
                ASSIGN aux_vllanmto = aux_vllanmto + tt-crapldt.vllanmto.
                
            END.
    
            IF   aux_vllanmto <> 0   THEN  
                 DO:                    
                    DISPLAY STREAM str_1 crapcop.nrctactl
                                         craphis.dshistor
                                         aux_dsorigem[aux_contador]  @ aux_dsorigem[1]
                                         crabcop.nrctactl   
                                         aux_vllanmto 
                                         WITH FRAME f_list609.
                     
                    DOWN WITH FRAME f_list609.
    
                    /* Linhas com valor total - Credito */
                    FIND tt-detlctctl WHERE 
                         tt-detlctctl.cdcooper = crabcop.cdcooper AND
                         tt-detlctctl.cdhistor = 1008 AND
                         tt-detlctctl.cdagenci = 0 AND
                         tt-detlctctl.intiplct = 0 EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-detlctctl  THEN
                        DO:
                             CREATE tt-detlctctl.
                             ASSIGN tt-detlctctl.cdcooper = crabcop.cdcooper
                                    tt-detlctctl.cdhistor = 1008
                                    tt-detlctctl.cdagenci = 0 
                                    tt-detlctctl.nrdconta = crabcop.nrctactl
                                    tt-detlctctl.nrctadeb = 1452
                                    tt-detlctctl.nrctacrd = 7254
                                    tt-detlctctl.dsrefere = "CREDITO C/C " + 
                                                            STRING(crabcop.nrctactl,"zzzz,zzz,9") + 
                                                            " CECRED REF. TARIFA DEPOSITO INTERCOOPERATIVO" +
                                                            " RECEBIDA DE OUTRAS COOPERATIVAS DO SISTEMA"
                                    tt-detlctctl.intiplct = 0.
                    
                        END.
                    ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vllanmto.
                     
                    /* Linhas com valor total - Debito */
                    FIND tt-detlctctl WHERE 
                         tt-detlctctl.cdcooper = crapcop.cdcooper AND
                         tt-detlctctl.cdhistor = 1007 AND
                         tt-detlctctl.cdagenci = 0 AND
                         tt-detlctctl.intiplct = 0 EXCLUSIVE-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-detlctctl  THEN
                        DO:
                             CREATE tt-detlctctl.
                             ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                    tt-detlctctl.cdhistor = 1007
                                    tt-detlctctl.cdagenci = 0 
                                    tt-detlctctl.nrdconta = crapcop.nrctactl
                                    tt-detlctctl.nrctadeb = 8308
                                    tt-detlctctl.nrctacrd = 1452
                                    tt-detlctctl.dsrefere = "DEBITO C/C " + 
                                                            STRING(crapcop.nrctactl,"zzzz,zzz,9") + 
                                                            " CECRED REF. TARIFA DEPOSITO INTERCOOPERATIVO" +
                                                            " PAGAS A OUTRAS COOPERATIVAS DO SISTEMA"
                                    tt-detlctctl.intiplct = 0.
                    
                        END.
                    ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vllanmto.
                    
                    ASSIGN aux_vllanmto = 0.
                 END.
    
            ASSIGN aux_indebcre = "D".
                  
            FOR EACH tt-crapldt WHERE tt-crapldt.cdagedst = crapcop.cdagectl   AND 
                                      tt-crapldt.cdagerem = crabcop.cdagectl   AND
                                      tt-crapldt.dsorigem = aux_dsorigem[aux_contador]
                                      NO-LOCK BREAK BY tt-crapldt.cdpacdst:
    
                ASSIGN aux_vllanmto = aux_vllanmto + tt-crapldt.vllanmto.
    
                IF   LAST-OF(tt-crapldt.cdpacdst)   THEN
                     DO:
                         DISPLAY STREAM str_1 
                                    aux_indebcre
                                    tt-crapldt.cdpacdst @ tt-crapldt.cdpacrem 
                                    aux_vllanmto
                                    WITH FRAME f_list609-2.
                         
                         DOWN WITH FRAME f_list609-2.
    
                         /* Linhas com valor por agencia */
                         FIND tt-detlctctl WHERE 
                              tt-detlctctl.cdcooper = crapcop.cdcooper AND
                              tt-detlctctl.cdhistor = 1007 AND
                              tt-detlctctl.cdagenci = tt-crapldt.cdpacdst AND
                              tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                         IF  NOT AVAILABLE tt-detlctctl  THEN
                             DO:
                                  CREATE tt-detlctctl.
                                  ASSIGN tt-detlctctl.cdcooper = crapcop.cdcooper
                                         tt-detlctctl.cdhistor = 1007
                                         tt-detlctctl.cdagenci = tt-crapldt.cdpacdst
                                         tt-detlctctl.nrdconta = crapcop.nrctactl
                                         tt-detlctctl.nrctadeb = 8308
                                         tt-detlctctl.nrctacrd = 1452
                                         tt-detlctctl.dsrefere = "DEBITO C/C " + 
                                                                 STRING(crapcop.cdagectl,"zzzz,zzz,9") + 
                                                                 " CECRED REF. TARIFA DEPOSITO INTERCOOPERATIVO" +
                                                                 " PAGAS A OUTRAS COOPERATIVAS DO SISTEMA"
                                         tt-detlctctl.intiplct = 1.
                             END.
                
                             ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vllanmto. 
                         
                         ASSIGN aux_vllanmto = 0.
                     END.
            END.
    
            ASSIGN aux_indebcre = "C".
    
            FOR EACH tt-crapldt WHERE tt-crapldt.cdagedst = crapcop.cdagectl   AND
                                      tt-crapldt.cdagerem = crabcop.cdagectl   AND
                                      tt-crapldt.dsorigem = aux_dsorigem[aux_contador]
                                      NO-LOCK BREAK BY tt-crapldt.cdpacrem :
                                          
                ASSIGN aux_vllanmto = aux_vllanmto + tt-crapldt.vllanmto.
    
                IF   LAST-OF(tt-crapldt.cdpacrem)   THEN
                     DO:
                        DISPLAY STREAM str_1 aux_indebcre
                                             tt-crapldt.cdpacrem   
                                             aux_vllanmto
                                             WITH FRAME f_list609-2.
    
                        DOWN WITH FRAME f_list609-2.
                        
                        /*Linhas com valor por agencia*/
                         FIND tt-detlctctl WHERE 
                              tt-detlctctl.cdcooper = crabcop.cdcooper AND
                              tt-detlctctl.cdhistor = 1008 AND
                              tt-detlctctl.cdagenci = tt-crapldt.cdpacrem AND
                              tt-detlctctl.intiplct = 1 EXCLUSIVE-LOCK NO-ERROR.
     
                         IF  NOT AVAILABLE tt-detlctctl  THEN
                             DO:
                                  CREATE tt-detlctctl.
                                  ASSIGN tt-detlctctl.cdcooper = crabcop.cdcooper
                                         tt-detlctctl.cdhistor = 1008
                                         tt-detlctctl.cdagenci = tt-crapldt.cdpacrem 
                                         tt-detlctctl.nrdconta = crabcop.nrctactl
                                         tt-detlctctl.nrctadeb = 1452
                                         tt-detlctctl.nrctacrd = 7254
                                         tt-detlctctl.dsrefere = "CREDITO C/C " + 
                                                                 STRING(crabcop.nrctactl,"zzzz,zzz,9") + 
                                                                 " CECRED REF. TARIFA DEPOSITO INTERCOOPERATIVO" +
                                                                 " RECEBIDA DE OUTRAS COOPERATIVAS DO SISTEMA"
                                         tt-detlctctl.intiplct = 1.
                             END.
                
                             ASSIGN tt-detlctctl.vllamnto = tt-detlctctl.vllamnto + aux_vllanmto.
                        
                        ASSIGN aux_vllanmto = 0.
                     END.
            END.     
        END.

    END.

    OUTPUT STREAM str_1 CLOSE.
    
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqimp.

    RUN fontes/imprim.p.

END PROCEDURE.
         
/*...........................................................................*/
