/* .............................................................................

   Programa: Fontes/lancstr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 24/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de resgate de cheques da tela lancst.

   Alteracoes: 11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               27/07/2001 - Alterado para permitir o resgate de cheques
                            liberados no dia (Edson).

               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior).

               20/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               03/11/2003 - Tratamento para cheques descontados (Julio).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               29/11/2005 - Ajustes na conversao crapchq/crapfdc (Edson).
               
               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               19/10/2010 - Nao resgatar caso ja tenha gerado o arquivo -
                            Compe por Imagem (Ze).
                            
               18/04/2013 - Ajuste para AltoVale - Task 54211 (Ze).

               13/08/2015 - Projeto Melhorias de Tarifas. (Jaison/Diego)
               
               26/08/2015 - Alterado parametro cdpesqbb para o Prj. Tarifas
                            - 218 (Jean Michel).
                            
               31/10/2018 - PRJ450 - Regulatorios de Credito - centralizacao de 
                            estorno de lançamentos na conta corrente              
                            pc_estorna_lancto_prog (Fabio Adriano - AMcom).             
............................................................................. */

{ includes/var_online.i }

{ includes/var_lancst.i }

{ includes/proc_conta_integracao.i }

{ sistema/generico/includes/var_oracle.i }
 
{ sistema/generico/includes/b1wgen0200tt.i }

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                                NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                                NO-UNDO.
 
ASSIGN tel_nmcustod = ""
       tel_dtlibera = ?
       tel_nrcustod = 0
       tel_cdcmpchq = 0
       tel_cdbanchq = 0
       tel_cdagechq = 0
       tel_nrddigc1 = 0
       tel_nrctachq = 0
       tel_nrddigc2 = 0
       tel_nrcheque = 0
       tel_nrddigc3 = 0
       tel_vlcheque = 0
       tel_nrseqdig = 1.

CMC-7:
      
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_dsdocmc7 = "".
        END.
      
   UPDATE tel_dsdocmc7 WITH FRAME f_lancst
         
   EDITING:
            
      READKEY.
       
      IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
           DO:
               glb_cdcritic = 666.
               NEXT.
           END.

      IF   KEYLABEL(LASTKEY) = "G"   THEN
           APPLY KEYCODE(":").
      ELSE
           APPLY LASTKEY.
    
   END.  /*  Fim do EDITING  */
         
   HIDE MESSAGE NO-PAUSE.
       
   IF   TRIM(tel_dsdocmc7) <> ""   THEN
        DO:
            IF   LENGTH(tel_dsdocmc7) <> 34            OR
                 SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                 SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                 DO:
                     glb_cdcritic = 666.
                     NEXT.
                 END.
        
            RUN mostra_dados.

            IF   glb_cdcritic > 0   THEN
                 NEXT.
        END.
   ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                     
               IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                    APPLY "END-ERROR".

               DISPLAY tel_dsdocmc7 WITH FRAME f_lancst.
                     
               RUN mostra_dados.

               IF   glb_cdcritic > 0   THEN
                    NEXT.
                   
               LEAVE.
                  
            END.  /*  Fim do DO WHILE TRUE  */
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                 NEXT.
        END.
     
     DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:    

        FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                           crapcst.dtmvtolt = tel_dtmvtolt   AND
                           crapcst.cdagenci = tel_cdagenci   AND
                           crapcst.cdbccxlt = tel_cdbccxlt   AND
                           crapcst.nrdolote = tel_nrdolote   AND
                           crapcst.cdcmpchq = tel_cdcmpchq   AND
                           crapcst.cdbanchq = tel_cdbanchq   AND
                           crapcst.cdagechq = tel_cdagechq   AND
                           crapcst.nrctachq = tel_nrctachq   AND
                           crapcst.nrcheque = tel_nrcheque
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE crapcst   THEN
             IF   LOCKED crapcst   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      IF  (tel_cdbanchq = 756            AND 
                           tel_cdagechq = aux_cdagebcb)  OR
                          (tel_cdbanchq = aux_cdbcoctl   AND
                           tel_cdagechq = aux_cdagectl)  THEN
                           DO:
                               FIND FIRST craptrf WHERE
                                    craptrf.cdcooper = glb_cdcooper      AND 
                                    craptrf.nrdconta = INT(tel_nrctachq) AND
                                    craptrf.tptransa = 1 
                                    USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                               IF   AVAILABLE craptrf THEN
                                    DO:
                                        tel_nrctachq = craptrf.nrsconta.
                                        DISPLAY tel_nrctachq
                                                WITH FRAME f_lancst.
                                        NEXT.
                                    END.
                           END.
                      
                      glb_cdcritic = 90.
                      LEAVE.
                  END.

        FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                           craplot.dtmvtolt = tel_dtmvtolt   AND
                           craplot.cdagenci = tel_cdagenci   AND
                           craplot.cdbccxlt = tel_cdbccxlt   AND
                           craplot.nrdolote = tel_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE craplot   THEN
             IF   LOCKED craplot   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  glb_cdcritic = 60.
        ELSE
             DO:   
                 IF   craplot.tplotmov <> 19   THEN
                      glb_cdcritic = 100.
             END.
                   
        IF   glb_cdcritic > 0   THEN
             LEAVE.

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                           crapass.nrdconta = crapcst.nrdconta NO-LOCK NO-ERROR.
      
        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 9.
                 LEAVE.
             END.

        ASSIGN tel_nmcustod = crapass.nmprimtl
               tel_vlcheque = crapcst.vlcheque
               tel_dtlibera = crapcst.dtlibera
               tel_nrcustod = crapcst.nrdconta
               tel_nrseqdig = crapcst.nrseqdig
      
               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_qtcompln = craplot.qtcompln
               tel_vlinfodb = craplot.vlinfodb
               tel_vlinfocr = craplot.vlinfocr
               tel_qtinfoln = craplot.qtinfoln
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
               tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln

               tel_qtinfocc = craplot.qtinfocc
               tel_vlinfocc = craplot.vlinfocc
               tel_qtcompcc = craplot.qtcompcc
               tel_vlcompcc = craplot.vlcompcc
               tel_qtdifecc = craplot.qtinfocc - craplot.qtcompcc
               tel_vldifecc = craplot.vlinfocc - craplot.vlcompcc

               tel_qtinfoci = craplot.qtinfoci
               tel_vlinfoci = craplot.vlinfoci
               tel_qtcompci = craplot.qtcompci
               tel_vlcompci = craplot.vlcompci
               tel_qtdifeci = craplot.qtinfoci - craplot.qtcompci
               tel_vldifeci = craplot.vlinfoci - craplot.vlcompci

               tel_qtinfocs = craplot.qtinfocs
               tel_vlinfocs = craplot.vlinfocs
               tel_qtcompcs = craplot.qtcompcs
               tel_vlcompcs = craplot.vlcompcs
               tel_qtdifecs = craplot.qtinfocs - craplot.qtcompcs
               tel_vldifecs = craplot.vlinfocs - craplot.vlcompcs.

       DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
               tel_vlcompcc tel_qtdifecc tel_vldifecc
               tel_qtinfoci tel_vlinfoci tel_qtcompci
               tel_vlcompci tel_qtdifeci tel_vldifeci
               tel_qtinfocs tel_vlinfocs tel_qtcompcs
               tel_vlcompcs tel_qtdifecs tel_vldifecs
               tel_cdcmpchq tel_cdbanchq tel_cdagechq
               tel_nrddigc1 tel_nrctachq tel_nrddigc2
               tel_nrcheque tel_nrddigc3 tel_nrcustod 
               tel_nmcustod tel_dtlibera tel_vlcheque
               tel_nrseqdig
               WITH FRAME f_lancst.
 
        IF   (crapcst.insitchq = 1)   OR
             (crapcst.insitchq = 5)   THEN                  /*  Ja resgatado  */
             DO:
                 glb_cdcritic = 672.

                 NEXT CMC-7.
             END.
        ELSE
        IF   crapcst.insitchq = 2   AND    /*  Processado em dias anteriores  */
             crapcst.dtlibera <= glb_dtmvtoan   THEN
/*             crapcst.dtlibera < glb_dtmvtolt   THEN   */
             DO:
                 glb_cdcritic = 670.
                      
                 NEXT CMC-7.
             END.        

        
        
        IF   CAN-FIND(crapcst WHERE  crapcst.cdcooper = glb_cdcooper   AND 
                                     crapcst.cdcmpchq = tel_cdcmpchq   AND
                                     crapcst.cdbanchq = tel_cdbanchq   AND
                                     crapcst.cdagechq = tel_cdagechq   AND
                                     crapcst.nrctachq = tel_nrctachq   AND
                                     crapcst.nrcheque = tel_nrcheque   AND
                                     crapcst.dtdevolu = glb_dtmvtolt)  THEN
             DO:
                 glb_cdcritic = 673.
                 NEXT CMC-7.
             END.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           aux_confirma = "N".

           glb_cdcritic = 78.
           RUN fontes/critic.p.
           BELL.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
             aux_confirma <> "S" THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT CMC-7.
             END.

        aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                           STRING(crapcst.nrddigc3,"9")).

        IF   crapcst.dtlibera <= glb_dtmvtopr  OR
             crapcst.insitchq  = 2             THEN   /* Liber. inf a D-2 */
             DO:
                 glb_cdcritic = 677.

                 /*
                 Procedure que possibilitava o resgate no dia da liberacao
                 RUN proc_liberado. 
                 */
             END.
        ELSE 
        IF   crapcst.insitchq = 0   THEN         /*  Cheques NAO processados  */
             DO:
                 DO WHILE TRUE:
        
                    FIND craplau WHERE 
                         craplau.cdcooper = glb_cdcooper          AND 
                         craplau.dtmvtolt = crapcst.dtmvtolt      AND
                         craplau.cdagenci = crapcst.cdagenci      AND
                         craplau.cdbccxlt = crapcst.cdbccxlt      AND
                         craplau.nrdolote = crapcst.nrdolote      AND
                         craplau.nrdctabb = INT(crapcst.nrctachq) AND
                         craplau.nrdocmto = aux_nrdocmto
                         USE-INDEX craplau1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craplau   THEN
                         IF   LOCKED craplau   THEN
                              DO:
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                              END.
                      
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 RUN STORED-PROCEDURE pc_tarifa_resgate_cheq_custod
                     aux_handproc = PROC-HANDLE NO-ERROR
                                     (INPUT glb_cdcooper,       /* Codigo Cooperativa*/
                                      INPUT crapass.nrdconta,   /* Numero da Conta */
                                      INPUT crapass.inpessoa,   /* Tipo de pessoa */
                                      INPUT crapcst.nrcheque,   /* Numero do Cheque */
                                     OUTPUT 0,                  /* Codigo Critica */
                                     OUTPUT "").                /* Descricao Critica */

                 CLOSE STORED-PROC pc_tarifa_resgate_cheq_custod
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                 IF  pc_tarifa_resgate_cheq_custod.pr_dscritic <> ? THEN
                     DO:
                        MESSAGE pc_tarifa_resgate_cheq_custod.pr_dscritic.
                        BELL.
                        NEXT CMC-7.
                     END.

                 IF   AVAILABLE craplau   THEN
                      ASSIGN craplau.dtdebito = glb_dtmvtolt
                             craplau.insitlau = 3.

                 ASSIGN crapcst.dtdevolu = glb_dtmvtolt 
                        crapcst.cdopedev = glb_cdoperad
                        crapcst.insitchq = 1.
             END.
        ELSE
             DO:
                 glb_cdcritic = 999.               /*  Rotina nao disponivel  */
             END.
             
        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE e da transacao  */

     IF   glb_cdcritic > 0   THEN
          NEXT.

     IF   tel_qtdifeln = 0   AND  
          tel_vldifedb = 0   AND 
          tel_vldifecr = 0   THEN
          DO:
              glb_nmdatela = "LOTE".
              RETURN.                        /*  Volta ao lancst.p  */
          END.
     
     ASSIGN tel_reganter[2] = tel_reganter[1]

            tel_reganter[1] = STRING(tel_cdcmpchq,"zz9") + " " +
                              STRING(tel_cdbanchq,"zz9") + " " +
                              STRING(tel_cdagechq,"zzz9") + "  " +
                              STRING(tel_nrddigc1,"9") + " " +
                              STRING(tel_nrctachq,"zzz,zzz,zzz,9") + "  " +
                              STRING(tel_nrddigc2,"9") + " " +
                              STRING(tel_nrcheque,"zzz,zz9") + "  " +
                              STRING(tel_nrddigc3,"9") + "    " +
                              STRING(tel_vlcheque,"zzz,zzz,zzz,zz9.99") +
                              "   " +
                              STRING(tel_nrseqdig,"zz,zz9")

            tel_dsdocmc7 = ""
            tel_cdcmpchq = 0
            tel_cdbanchq = 0 
            tel_cdagechq = 0
            tel_nrddigc1 = 0
            tel_nrctachq = 0
            tel_nrddigc2 = 0
            tel_nrcheque = 0
            tel_nrddigc3 = 0
            tel_vlcheque = 0.
         
    DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
            tel_vlcompcc tel_qtdifecc tel_vldifecc
            tel_qtinfoci tel_vlinfoci tel_qtcompci
            tel_vlcompci tel_qtdifeci tel_vldifeci
            tel_qtinfocs tel_vlinfocs tel_qtcompcs
            tel_vlcompcs tel_qtdifecs tel_vldifecs
            tel_cdcmpchq tel_cdbanchq tel_cdagechq
            tel_nrddigc1 tel_nrctachq tel_nrddigc2
            tel_nrcheque tel_nrddigc3 tel_vlcheque
            tel_nrseqdig
            WITH FRAME f_lancst.

     HIDE FRAME f_lanctos.

     DISPLAY tel_reganter[1] tel_reganter[2] WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lancst.i }

PROCEDURE proc_liberado:

    DEF VAR aux_flgcopmig AS LOGICAL                            NO-UNDO.


    DO WHILE TRUE:
    
       FIND craplot WHERE craplot.cdcooper = glb_cdcooper       AND 
                          craplot.dtmvtolt = glb_dtmvtolt       AND
                          craplot.cdagenci = 1                  AND
                          craplot.cdbccxlt = 100                AND
                          craplot.nrdolote = 4500                  
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
       IF   NOT AVAILABLE craplot   THEN
            IF   LOCKED craplot   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 60.
                     RETURN.
                 END.
       
       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */
    
    

    /*  Tratamento para Migracao da AltoVale */
    aux_flgcopmig = FALSE.

    IF   glb_cdcooper     = 16   AND
         crapcst.cdbanchq = 85   AND
         crapcst.cdagechq = 101  THEN
         DO:
            FIND FIRST craptco WHERE 
                       craptco.cdcooper = crapcst.cdcooper       AND
                       craptco.nrdconta = INT(crapcst.nrctachq)  AND
                       craptco.tpctatrf = 1                      AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.     
            
            IF   AVAILABLE craptco THEN
                 aux_flgcopmig = TRUE.
         END.

    
    IF   crapcst.inchqcop = 1  OR
         aux_flgcopmig = TRUE  THEN                /*  Cheque da Cooperativa  */
         DO:
             ASSIGN aux_nrdconta = crapcst.nrctachq
                    aux_nrdctabb = crapcst.nrctachq
                    aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                                       STRING(crapcst.nrddigc3,"9")).

             RUN fontes/digbbx.p (INPUT  INT(crapcst.nrctachq),
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
                                              
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      glb_cdcritic = 8.
                      RETURN.
                  END.

             ASSIGN glb_nrchqsdv = crapcst.nrcheque
                    glb_nrchqcdv = aux_nrdocmto.
 
             DO WHILE TRUE:
                     
                FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper      AND
                                   crapfdc.cdbanchq = crapcst.cdbanchq  AND
                                   crapfdc.cdagechq = crapcst.cdagechq  AND
                                   crapfdc.nrctachq = crapcst.nrctachq  AND
                                   crapfdc.nrcheque = crapcst.nrcheque
                                   USE-INDEX crapfdc1 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
                IF   NOT AVAILABLE crapfdc  THEN
                     IF   LOCKED crapfdc   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 108.
                              RETURN.
                          END.

                IF   crapfdc.tpcheque = 2   THEN
                     DO:
                         glb_cdcritic = 646.  
                         RETURN.
                     END.
                ELSE
                IF   crapfdc.tpcheque = 3   THEN
                     DO:
                         IF   crapfdc.vlcheque <> crapcst.vlcheque   THEN
                              DO:
                                  glb_cdcritic = 91.
                                  RETURN. 
                              END.
                     END.

                ASSIGN aux_nrdconta = crapfdc.nrdconta
                       aux_nrdctabb = crapfdc.nrdctabb.

                IF   crapfdc.incheque <> 5   THEN
                     DO:
                         glb_cdcritic = 99.
                         RETURN.
                     END.

                FIND craplau WHERE craplau.cdcooper = glb_cdcooper          AND
                                   craplau.dtmvtolt = crapcst.dtmvtolt      AND
                                   craplau.cdagenci = crapcst.cdagenci      AND
                                   craplau.cdbccxlt = crapcst.cdbccxlt      AND
                                   craplau.nrdolote = crapcst.nrdolote      AND
                                   craplau.nrdctabb = INT(crapcst.nrctachq) AND
                                   craplau.nrdocmto = aux_nrdocmto
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplau   THEN
                     IF   LOCKED craplau   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.
                     
                /*  Registro do cheque acolhido  */
             
                FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND 
                                   crapchd.dtmvtolt = glb_dtmvtolt   AND
                                   crapchd.dsdocmc7 = crapcst.dsdocmc7
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE crapchd   THEN
                     IF   LOCKED crapchd   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.
          
                LEAVE.
                
             END.  /*  Fim do DO WHILE TRUE  */
         END.
    ELSE                                        /*  Cheques de outros bancos  */
         DO:
             /*  Verifica o horario de corte  */

             FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "GENERI"       AND
                                craptab.cdempres = 0              AND
                                craptab.cdacesso = "HRTRCOMPEL"   AND
                                craptab.tpregist = tel_cdagenci 
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craptab   THEN
                  DO:
                      glb_cdcritic = 676.
                      RETURN.
                  END.

             IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                  DO:
                      glb_cdcritic = 676.
                      RETURN.
                  END.
             
             /*  Registro do cheque acolhido  */
             
             DO WHILE TRUE:
             
                FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND 
                                   crapchd.dtmvtolt = glb_dtmvtolt   AND
                                   crapchd.dsdocmc7 = crapcst.dsdocmc7
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE crapchd   THEN
                     IF   LOCKED crapchd   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 244.   
                              RETURN.
                          END.
         
                LEAVE.
                
             END.  /*  Fim do DO WHILE TRUE  */
             
             IF   crapchd.insitchq = 3   THEN
                  DO:
                      glb_cdcritic = 999.   /*  DEFINIR - compe. terceiros  */
                      RETURN.
                  END.
         END.

    DO WHILE TRUE:
 
       FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND 
                          craplcm.dtmvtolt = craplot.dtmvtolt   AND
                          craplcm.cdagenci = craplot.cdagenci   AND
                          craplcm.cdbccxlt = craplot.cdbccxlt   AND
                          craplcm.nrdolote = craplot.nrdolote   AND
                          craplcm.nrdctabb = crapcst.nrdconta   AND
                          craplcm.nrdocmto = crapcst.nrdocmto 
                          USE-INDEX craplcm1
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
       IF   NOT AVAILABLE craplcm   THEN
            IF   LOCKED craplcm   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     IF   crapcst.nrdconta <> 85448   THEN
                          DO:
                              glb_cdcritic = 90.    /*  DEFINIR  */
                              RETURN.
                          END.
                     ELSE
                          LEAVE.
                 END.
        
       FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper       AND 
                          crapdpb.dtmvtolt = craplcm.dtmvtolt   AND
                          crapdpb.cdagenci = craplcm.cdagenci   AND
                          crapdpb.cdbccxlt = craplcm.cdbccxlt   AND
                          crapdpb.nrdolote = craplcm.nrdolote   AND
                          crapdpb.nrdconta = craplcm.nrdconta   AND
                          crapdpb.nrdocmto = craplcm.nrdocmto 
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
 
       IF   NOT AVAILABLE crapdpb   THEN
            IF   LOCKED crapdpb   THEN
                 NEXT.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

    DISPLAY SKIP(1)
            " ATENCAO! Esta operacao NAO tem volta! "
            SKIP(1)
            WITH ROW 10 CENTERED OVERLAY color message FRAME f_sem_volta.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       aux_confirma = "N".

       glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       glb_cdcritic = 0.
       LEAVE.

    END.

    HIDE FRAME f_sem_volta NO-PAUSE.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S" THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             RETURN.
         END.

    ASSIGN crapcst.dtdevolu = glb_dtmvtolt 
           crapcst.cdopedev = glb_cdoperad
           crapcst.insitchq = 1
           
           craplot.vlinfocr = craplot.vlinfocr - crapcst.vlcheque
           craplot.vlcompcr = craplot.vlcompcr - crapcst.vlcheque.
 
    IF   AVAILABLE crapchd   THEN
         DELETE crapchd.
    
    IF   AVAILABLE craplcm   THEN
         DO:
             IF   craplcm.vllanmto = crapcst.vlcheque   THEN
                  DO:
                      ASSIGN craplot.qtinfoln = craplot.qtinfoln - 1
                             craplot.qtcompln = craplot.qtcompln - 1.

                      
                      
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                          RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                                        
                      RUN estorna_lancamento_conta IN h-b1wgen0200 
                          (INPUT craplcm.cdcooper               /* par_cdcooper */
                          ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
                          ,INPUT craplcm.cdagenci               /* par_cdagenci*/
                          ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
                          ,INPUT craplcm.nrdolote               /* par_nrdolote */
                          ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
                          ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
                          ,INPUT craplcm.cdhistor               /* par_cdhistor */           
                          ,INPUT craplcm.nrctachq               /* par_nrctachq */
                          ,INPUT craplcm.nrdconta               /* par_nrdconta */
                          ,INPUT craplcm.cdpesqbb               /* par_cdpesqbb */
                          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                          
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                          glb_cdcritic = aux_cdcritic.
                          glb_dscritic = aux_dscritic.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                          RETURN.
                      END.
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                          DELETE PROCEDURE h-b1wgen0200.
             
                      IF   AVAILABLE crapdpb   THEN
                           DELETE crapdpb.
                  END.
             ELSE
                  DO:
                      craplcm.vllanmto = craplcm.vllanmto - crapcst.vlcheque.

                      IF   AVAILABLE crapdpb   THEN
                           crapdpb.vllanmto = crapdpb.vllanmto - 
                                                      crapcst.vlcheque.
                  END.
         END.
         
    IF   AVAILABLE craplau   THEN
         DO:
             ASSIGN craplau.dtdebito = glb_dtmvtolt
                    craplau.insitlau = 3.
         
             DO WHILE TRUE:
             
                FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND 
                                   craplcm.dtmvtolt = craplot.dtmvtolt   AND
                                   craplcm.cdagenci = craplot.cdagenci   AND
                                   craplcm.cdbccxlt = craplot.cdbccxlt   AND
                                   craplcm.nrdolote = craplot.nrdolote   AND
                                   craplcm.nrdctabb = craplau.nrdctabb   AND
                                   craplcm.nrdocmto = craplau.nrdocmto 
                                   USE-INDEX craplcm1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
                IF   NOT AVAILABLE craplcm   THEN
                     IF   LOCKED craplcm   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.

                LEAVE.
             
             END.  /*  Fim do DO WHILE TRUE  */
             
             IF   AVAILABLE craplcm   THEN
                  DO:
                      ASSIGN craplot.qtinfoln = craplot.qtinfoln - 1
                             craplot.qtcompln = craplot.qtcompln - 1

                             craplot.vlinfodb = craplot.vlinfodb -
                                                        crapcst.vlcheque
                             craplot.vlcompdb = craplot.vlcompdb -
                                                        crapcst.vlcheque.
 
                      
                      
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                          RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                                        
                      RUN estorna_lancamento_conta IN h-b1wgen0200 
                          (INPUT craplcm.cdcooper               /* par_cdcooper */
                          ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
                          ,INPUT craplcm.cdagenci               /* par_cdagenci*/
                          ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
                          ,INPUT craplcm.nrdolote               /* par_nrdolote */
                          ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
                          ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
                          ,INPUT craplcm.cdhistor               /* par_cdhistor */           
                          ,INPUT craplcm.nrctachq               /* par_nrctachq */
                          ,INPUT craplcm.nrdconta               /* par_nrdconta */
                          ,INPUT craplcm.cdpesqbb               /* par_cdpesqbb */
                          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                      
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                          glb_cdcritic = aux_cdcritic.
                          glb_dscritic = aux_dscritic.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                          RETURN.
                      END.
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                          DELETE PROCEDURE h-b1wgen0200.
                      
                  END.
         END.

    IF   AVAILABLE crapfdc   THEN
         ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                crapfdc.dtliqchq = ?
                crapfdc.vlcheque = 0
                crapfdc.vldoipmf = 0.

    IF   craplot.vlcompcr = 0   AND
         craplot.vlcompdb = 0   THEN
         DELETE craplot.

END PROCEDURE.

/* .......................................................................... */

