/* .............................................................................

   Programa: Fontes/sol062.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/95

   Dados referentes ao programa:                 Ultima Alteracao : 17/11/2015

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL062.

   Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               05/11/1999 - Criticar a geracao de estouro quando nao for
                            solicitacao de credito de folha (final do mes)
                            (Deborah).

               17/01/2000 - Tratar tpdebemp = 3 (Deborah).

               18/12/2000 - Permitir que o usuario integre creditos de 
                            pagamentos pela tela (Margarete/Planner).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               11/09/2006 - Alterado help dos campos da tela (Elton).
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               26/05/2009 - Alterado para processar arquivos com FORMAT
                            cdempres "99999" e "99" (Diego).
                            
               31/05/2010 - Acerto no tratamento do campo cdempres (Diego).
               
               10/10/2013 - SD 93349. Retirado o parametro NEW na chamada
                            de crps120 para impressao direta pelo usuario,
                            ao inves de ir para processo noturno (Carlos)
                            
               30/12/2013 - SD 108354 - inclusao da opcao R para reimprimir
                            os relatorios (Carlos)
							
               25/03/2014 - Ajuste processo busca impressora (Daniel).
         
               08/10/2015 - A tela passa a chamar o fonte integra_folha.p ao 
                            inves do crps120.p. 
                          - Passa o numero sequencial como parametro para 
                            processar somente a solicitacao que foi pedida em 
                            tela, evitando duplicidades nos registros
                          - Criado novo estado para as solicitações: 3 - Abortado
                            para quando ocorrer algum erro durante o processo.
                          - Colocada verificação para não ocorrer mais a situação
                            de tentar mover o relatório 99 sem ele ter sido criado.
                            Chamado 306243 (Lombardi)
                            
               17/11/2015 - Estado de crise (Gabriel-RKAM).            
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }

DEF        STREAM str_1.
DEF        STREAM str_grep.

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_dialiber AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_inexecut AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR tel_ingerest AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_vltotfol AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_tpregist AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_inexecut AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 62           NO-UNDO.
DEF        VAR aux_arqfolha AS CHAR    FORMAT "x(45)"                NO-UNDO.
DEF        VAR aux_qtarqfol AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_ingerest AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_dtiniref AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dtfimref AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_flginteg AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "999999999999.99"      NO-UNDO.
DEF        VAR aux_tpintegr AS CHAR    INIT "f"                      NO-UNDO.
DEF        VAR aux_flgproce AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flestcri AS INTE                                  NO-UNDO.

DEF        VAR tot_qtarqfol AS INT     FORMAT "99"                   NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqest AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqden AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR prn_nmdafila AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

	  
DEf        VAR aux_grep     AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_nmimpres AS CHAR    FORMAT "x(15)"                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E,I ou R)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I" OR
                                  glb_cddopcao = "R",
                                  "014 - Opcao errada.")
     tel_nrseqsol AT 13 LABEL "Sequencia" AUTO-RETURN
                        HELP "Informe o numero da sequencia do arquivo."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_cdempres AT 15 LABEL "Empresa" AUTO-RETURN
                        HELP "Informe o codigo da empresa."
                        VALIDATE (CAN-FIND (crapemp WHERE 
                                            crapemp.cdcooper = glb_cdcooper AND
                                            crapemp.cdempres = tel_cdempres),
                                            "040 - Empresa nao cadastrada.")
     tel_dsempres AT 29 NO-LABEL
     SKIP(1)
     tel_dtrefere AT 04 LABEL "Data de Referencia" AUTO-RETURN
                        HELP "Informe a data de referencia do credito da folha."
                        VALIDATE(tel_dtrefere > aux_dtiniref AND
                                 tel_dtrefere < aux_dtfimref,
                                                     "013 - Data errada.") 
     SKIP (1)
     tel_dialiber AT 6  LABEL "Dia de Liberacao" AUTO-RETURN
                        HELP "Informe o dia para efetuar liberacao do credito."
                        VALIDATE (tel_dialiber > 00 and tel_dialiber < 32,
                                  "013 - Data errada.")
     SKIP (1)
     tel_ingerest AT 8  LABEL "Gerar Estouros" AUTO-RETURN
                        HELP "Informe 'S' p/ ultimo arq. no mes ou 'N' p/ mais arq."
                        VALIDATE (tel_ingerest = "S" OR tel_ingerest = "N",
                                  "024 - Deve ser S ou N.")
     SKIP (1)
     tel_inexecut AT 5 LABEL "Integrar Processo" AUTO-RETURN
                        HELP
                        "Informe 'S' p/integrar a noite ou 'N' p/integrar durante o dia."
                        VALIDATE (tel_inexecut = "S" OR tel_inexecut = "N",
                                  "024 - Deve ser S ou N.")
     SKIP (1)
     tel_dssitsol AT 14 LABEL "Situacao"
     SKIP (1)
     tel_vltotfol AT  6 LABEL "Total do arquivo"
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol062.

VIEW FRAME f_moldura.

FORM SKIP(1)
     glb_nmdafila LABEL "  Imprimir em" " "
     SKIP(1)
     WITH ROW 14 CENTERED OVERLAY SIDE-LABELS 
          TITLE COLOR NORMAL " Destino " FRAME f_nmdafila.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0.

PAUSE(0).

ASSIGN aux_dtfimref = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4)
                         - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                    YEAR(glb_dtmvtolt)) + 4)) + 1
       aux_dtiniref = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_dtiniref = aux_dtiniref - DAY(aux_dtiniref).

DO WHILE TRUE:

   IF   glb_cdcritic <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol062.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE  glb_cddopcao tel_nrseqsol WITH FRAME f_sol062.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL062"   THEN
                 DO:
                     HIDE FRAME f_integra.
                     HIDE FRAME f_sol062.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            NEXT.
        END.

   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

   /* Efetuar a chamada a rotina Oracle */
   RUN STORED-PROCEDURE pc_estado_crise
   aux_handproc = PROC-HANDLE NO-ERROR (INPUT "N" /* Identificador para verificar processo (N – Nao / S – Sim) */
                                      ,OUTPUT 0   /* Identificador estado de crise (0 - Nao / 1 - Sim) */
                                      ,OUTPUT ?). /* XML com informacoes das cooperativas */

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_estado_crise
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

   { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

   ASSIGN aux_flestcri = 0
          aux_flestcri = pc_estado_crise.pr_inestcri
                         WHEN pc_estado_crise.pr_inestcri <> ?.

   /* Se estiver em estado de crise */
   IF  aux_flestcri > 0  THEN
       DO: 
           MESSAGE "Sistema em estado de crise.".
           PAUSE 1 NO-MESSAGE.
           NEXT.
       END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   { includes/listaint.i }

   ASSIGN tel_inexecut = "S"
          tel_ingerest = "S"
          aux_flgproce = no.

   IF   glb_cddopcao = "A" THEN
        DO:
            
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               HIDE MESSAGE NO-PAUSE.
               ASSIGN aux_flgproce = no.
               
               DO  aux_contador = 1 TO 10:

                   FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                      crapsol.nrsolici = aux_nrsolici   AND
                                      crapsol.dtrefere = glb_dtmvtolt   AND
                                      crapsol.nrseqsol = tel_nrseqsol
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapsol   THEN
                        IF   LOCKED crapsol   THEN
                             DO:
                                 glb_cdcritic = 120.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 115.
                                 CLEAR FRAME f_sol062.
                                 LEAVE.
                             END.
                   ELSE
                        DO:
                            aux_contador = 0.
                            LEAVE.
                        END.
               END.

               IF   aux_contador = 0 THEN
                    IF   crapsol.insitsol <> 1 THEN
                         ASSIGN glb_cdcritic = 150
                                aux_contador = 1.

               IF   aux_contador <> 0   THEN
                    NEXT.

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper       AND 
                                  crapemp.cdempres = crapsol.cdempres   
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE (crapemp) THEN
                    tel_dsempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_dsempres = " - NAO CADASTRADA".

               ASSIGN tel_cdempres = crapsol.cdempres
                      tel_dtrefere =
                               DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                      tel_dialiber = INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                      tel_ingerest = IF (SUBSTRING(crapsol.dsparame,17,1))
                                         = "1" THEN "S" ELSE "N"
                      tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                         = "1" THEN "S" ELSE "N"
                      tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                             " 1 - A FAZER"
                                     ELSE IF crapsol.insitsol = 2  THEN 
                                             " 2 - PROCESSADA"
                                        ELSE
                                             " 3 - ABORTADA".
                                     

               DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                       tel_dialiber tel_ingerest tel_inexecut
                       tel_dssitsol WITH FRAME f_sol062.

               DO WHILE TRUE:

                  ASSIGN aux_flgproce = no.
                  
                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  HIDE MESSAGE NO-PAUSE.
                  
                  UPDATE   tel_cdempres   tel_dtrefere
                           tel_dialiber   tel_ingerest
                           tel_inexecut   WITH FRAME f_sol062.

                  FIND   crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND 
                                       crapemp.cdempres = tel_cdempres
                                       NO-LOCK NO-ERROR.

                  IF    NOT AVAILABLE crapemp THEN
                        DO:
                            glb_cdcritic = 40.
                            NEXT-PROMPT tel_cdempres WITH FRAME f_sol062.
                            NEXT.
                        END.

                  IF    NOT CAN-DO("2,3",STRING(crapemp.tpdebcot,"9")) OR
                        NOT CAN-DO("2,3",STRING(crapemp.tpdebemp,"9")) THEN
                        DO:
                            glb_cdcritic = 445.
                            NEXT-PROMPT tel_cdempres WITH FRAME f_sol062.
                            NEXT.
                        END.

                  /* Verifica arquivos com FORMAT cdempres "99999" e "99" */ 
                                    
                  aux_arqfolha = "f" + STRING(tel_cdempres,"99999") +
                                 STRING(tel_dtrefere,"99999999")   + ".*".

                  INPUT THROUGH VALUE("ll integra/" + aux_arqfolha +
                                      " 2> /dev/null | wc -l") NO-ECHO.

                  SET  aux_qtarqfol.
                  
                  INPUT CLOSE.
                  
                  ASSIGN tot_qtarqfol = aux_qtarqfol.
                  
                  IF   LENGTH(STRING(tel_cdempres)) > 2  THEN
                       aux_arqfolha = "f" + STRING(tel_cdempres,"999") +
                                      STRING(tel_dtrefere,"99999999") + ".*".
                  ELSE 
                       aux_arqfolha = "f" + STRING(tel_cdempres,"99") +
                                      STRING(tel_dtrefere,"99999999") + ".*".

                  INPUT THROUGH VALUE("ll integra/" + aux_arqfolha +
                                      " 2> /dev/null | wc -l") NO-ECHO.

                  SET  aux_qtarqfol.
                  
                  INPUT CLOSE.
                  
                  ASSIGN tot_qtarqfol = tot_qtarqfol + aux_qtarqfol.
                  
                  IF    tel_ingerest = "S" THEN
                        DO:
                            IF   tot_qtarqfol > 1 THEN
                                 DO:
                                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                        ASSIGN aux_confirma = "N"
                                               glb_cdcritic = 442.

                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE COLOR NORMAL glb_dscritic
                                                      UPDATE aux_confirma.
                                        glb_cdcritic = 0.
                                        LEAVE.

                                     END.

                                     IF   aux_confirma = "N" THEN
                                          DO:
                                              NEXT-PROMPT tel_ingerest WITH
                                                               FRAME f_sol062.
                                              NEXT.
                                          END.
                                 END.
                        END.
                  ELSE      /* Nao Solicitar */
                        DO:
                            IF   tot_qtarqfol <= 1 THEN
                                 DO:
                                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                        ASSIGN aux_confirma = "N"
                                               glb_cdcritic = 443.

                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE COLOR NORMAL  glb_dscritic
                                                            UPDATE aux_confirma.
                                        glb_cdcritic = 0.
                                        LEAVE.

                                     END.

                                     IF   aux_confirma = "N" THEN
                                          DO:
                                              NEXT-PROMPT tel_ingerest
                                                         WITH FRAME f_sol062.
                                              NEXT.
                                          END.
                                 END.
                        END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         aux_inexecut     = IF   tel_inexecut = "S" THEN
                                                 1 ELSE 2
                         aux_ingerest     = IF   tel_ingerest = "S" THEN
                                                 1 ELSE 2
                         crapsol.dsparame =
                                  STRING(tel_dtrefere,"99/99/9999") + " " +
                                  STRING(tel_dialiber,"99")         + " " +
                                  STRING(aux_inexecut,"9")          + " " +
                                  STRING(aux_ingerest,"9")
                         aux_nrseqsol = crapsol.nrseqsol.
                         
                  IF   tel_inexecut = "N"  THEN
                       DO:
                       
                           ASSIGN aux_flginteg = no.
                           MESSAGE COLOR NORMAL
                                  "Deseja fazer o credito neste momento ?" 
                                  UPDATE aux_flginteg.
                           IF   aux_flginteg THEN 
                                DO:
                                    ASSIGN aux_confirma = "N"
                                           aux_flgproce = no
                                           glb_cdcritic = 78.

                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE COLOR NORMAL glb_dscritic
                                                         UPDATE aux_confirma.
                                    IF   aux_confirma = "S" THEN
                                         DO:
                                             MESSAGE COLOR NORMAL
                                                     "Integrando.....".
                                             ASSIGN aux_flgproce = yes.        
                                             /*******
                                             RUN fontes/crps120.p "new".
                                             MESSAGE COLOR NORMAL
                                                     "Confira os lotes "
                                                     "integrados na 'RELLOT'".
                                             PAUSE MESSAGE 
                                "Pressione a barra de espacos para continuar".
                                             ASSIGN glb_cdcritic = 0.
                                             *********/
                                         END.
                                    ELSE DO:
                                        MESSAGE COLOR NROMAL
                                                "Alteracao cancelada".
                                        ASSIGN glb_cdcritic = 0.
                                        UNDO,NEXT.        
                                    END.
                           END.
                           ELSE DO:
                               MESSAGE COLOR NORMAL
                                       "Alteracao cancelada".
                               ASSIGN glb_cdcritic = 0.
                               UNDO,NEXT.        
                           END.
                       END.
                  
                  LEAVE.

               END.

            END. /* Fim da transacao */

            RELEASE crapsol.

            /****** testes Magui 22/12/2000 *****/
            IF   aux_flgproce  THEN
                 DO:
                     RUN fontes/integra_folha.p(INPUT aux_nrseqsol).

                     PAUSE MESSAGE 
                           "Pressione a barra de espacos para continuar".
                     ASSIGN glb_cdcritic = 0.
                 END.
            /*************************************/
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol062 NO-PAUSE.

        END.
        ELSE
        IF   glb_cddopcao = "C" THEN
             DO:
                 FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                    crapsol.nrsolici = aux_nrsolici   AND
                                    crapsol.dtrefere = glb_dtmvtolt   AND
                                    crapsol.nrseqsol = tel_nrseqsol
                                    USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapsol   THEN
                      DO:
                          glb_cdcritic = 115.
                          CLEAR FRAME f_sol062.
                          NEXT.
                      END.

                 FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND 
                                    crapemp.cdempres = crapsol.cdempres 
                                    NO-LOCK NO-ERROR.

                 IF   AVAILABLE (crapemp) THEN
                      tel_dsempres = " - " + crapemp.nmresemp.
                 ELSE
                      tel_dsempres = " - NAO CADASTRADA".

                 ASSIGN tel_cdempres = crapsol.cdempres
                        tel_dtrefere =
                            DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                 INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                        tel_dialiber =
                            INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                        tel_ingerest = IF (SUBSTRING(crapsol.dsparame,17,1))
                                       = "1" THEN "S" ELSE "N"
                        tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                       = "1" THEN "S" ELSE "N"
                        tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                          " 1 - A FAZER"
                                       ELSE 
                                          IF crapsol.insitsol = 2  THEN 
                                               " 2 - PROCESSADA"
                                          ELSE
                                               " 3 - ABORTADA".
                 DISPLAY tel_cdempres tel_dsempres tel_dtrefere tel_dialiber
                         tel_ingerest tel_inexecut tel_dssitsol
                         WITH FRAME f_sol062.

             END.
        ELSE
        IF   glb_cddopcao = "E"   THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                                           crapsol.nrsolici = aux_nrsolici  AND
                                           crapsol.dtrefere = glb_dtmvtolt  AND
                                           crapsol.nrseqsol = tel_nrseqsol
                                           USE-INDEX crapsol1
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE crapsol   THEN
                             IF   LOCKED crapsol   THEN
                                  DO:
                                      glb_cdcritic = 120.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      ASSIGN glb_cdcritic = 115.
                                      CLEAR FRAME f_sol062.
                                      LEAVE.
                                  END.
                        ELSE
                             DO:
                                 ASSIGN aux_contador = 0.
                                 LEAVE.
                             END.
                    END.

                    IF   aux_contador <> 0   THEN
                         NEXT.

                    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                                       crapemp.cdempres = crapsol.cdempres
                                       NO-LOCK NO-ERROR.

                    IF   AVAILABLE (crapemp) THEN
                         tel_dsempres = " - " + crapemp.nmresemp.
                    ELSE
                         tel_dsempres = " - NAO CADASTRADA".

                    ASSIGN tel_cdempres = crapsol.cdempres
                           tel_dtrefere =
                               DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                           tel_dialiber =
                               INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                           tel_ingerest = IF (SUBSTRING(crapsol.dsparame,17,1))
                                          = "1" THEN "S" ELSE "N"
                           tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                          = "1" THEN "S" ELSE "N"
                           tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                             " 1 - A FAZER"
                                          ELSE 
                                             IF crapsol.insitsol = 2  THEN 
                                                  " 2 - PROCESSADA"
                                             ELSE
                                                  " 3 - ABORTADA".

                    DISPLAY tel_cdempres tel_dsempres tel_dtrefere tel_dialiber
                            tel_ingerest tel_inexecut  tel_dssitsol
                            WITH FRAME f_sol062.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       ASSIGN aux_confirma = "N"
                              glb_cdcritic = 78.

                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             NEXT.
                         END.

                    DELETE crapsol.
                    CLEAR FRAME f_sol062 NO-PAUSE.

                 END. /* Fim da transacao */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.
             END.
        ELSE
        IF   glb_cddopcao = "I"   THEN
             DO:
                 ASSIGN tel_cdempres = 0
                        tel_dialiber = 0
                        tel_dtrefere = ?
                        tel_ingerest = "S"
                        tel_inexecut = "S"
                        tel_dssitsol = " "
                        tel_dsempres = " "
                        aux_flgproce = no.

                 FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                    crapsol.nrsolici = aux_nrsolici   AND
                                    crapsol.dtrefere = glb_dtmvtolt   AND
                                    crapsol.nrseqsol = tel_nrseqsol
                                    USE-INDEX crapsol1 NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE crapsol   THEN
                      DO:
                          glb_cdcritic = 118.
                          NEXT.
                      END.

                 DISPLAY tel_dsempres tel_dssitsol WITH FRAME f_sol062.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN aux_flgproce = no.
                    
                    IF   glb_cdcritic > 0 THEN
                         DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                         END.

                    UPDATE   tel_cdempres   tel_dtrefere
                             tel_dialiber   tel_ingerest
                             tel_inexecut   WITH FRAME f_sol062.

                    FIND   crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                                         crapemp.cdempres = tel_cdempres
                                         NO-LOCK NO-ERROR.

                    IF    NOT AVAILABLE crapemp THEN
                          DO:
                             glb_cdcritic = 40.
                             NEXT-PROMPT tel_cdempres WITH FRAME f_sol062.
                             NEXT.
                          END.

                    IF    NOT CAN-DO("2,3",STRING(crapemp.tpdebcot)) OR
                          NOT CAN-DO("2,3",STRING(crapemp.tpdebemp)) THEN
                          DO:
                             glb_cdcritic = 445.
                             NEXT-PROMPT tel_cdempres WITH FRAME f_sol062.
                             NEXT.
                          END.
                                         
                    IF  (crapemp.inavscot <> 1               OR
                         crapemp.inavsemp <> 1)              AND
                         tel_dtrefere = (aux_dtfimref - 1)   THEN
                         DO:
                             glb_cdcritic = 522.
                             NEXT-PROMPT tel_cdempres WITH FRAME f_sol062.
                             NEXT.
                         END.                 
                                            
                    IF   tel_ingerest = "S" AND 
                         MONTH(tel_dtrefere) = MONTH(tel_dtrefere + 1) THEN
                         DO:
                             glb_cdcritic = 653.
                             NEXT-PROMPT tel_ingerest WITH FRAME f_sol062.
                             NEXT.             
                         END.                  
                    
                    /* Verifica arquivos com FORMAT cdempres "99999" e "99" */ 
                                    
                    aux_arqfolha = "f" + STRING(tel_cdempres,"99999") +
                                   STRING(tel_dtrefere,"99999999")   + ".*".

                    INPUT THROUGH VALUE("ll integra/" + aux_arqfolha +
                                        " 2> /dev/null | wc -l") NO-ECHO.

                    SET  aux_qtarqfol.
                  
                    INPUT CLOSE.
                   
                    ASSIGN tot_qtarqfol = aux_qtarqfol.
                  
                    IF   LENGTH(STRING(tel_cdempres)) > 2  THEN
                         aux_arqfolha = "f" + STRING(tel_cdempres,"999") +
                                        STRING(tel_dtrefere,"99999999") + ".*".
                    ELSE
                         aux_arqfolha = "f" + STRING(tel_cdempres,"99") +
                                        STRING(tel_dtrefere,"99999999") + ".*".
                                         
                    INPUT THROUGH VALUE("ll integra/" + aux_arqfolha +
                                        " 2> /dev/null | wc -l") NO-ECHO.

                    SET  aux_qtarqfol.
                  
                    INPUT CLOSE.
                    
                    ASSIGN tot_qtarqfol = tot_qtarqfol + aux_qtarqfol.
                    
                    IF    tel_ingerest = "S" THEN
                          DO:
                              IF   tot_qtarqfol > 1 THEN
                                   DO:
                                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                         ASSIGN aux_confirma = "N"
                                                glb_cdcritic = 442.

                                         RUN fontes/critic.p.
                                         BELL.
                                         MESSAGE COLOR NORMAL glb_dscritic
                                                       UPDATE aux_confirma.
                                         glb_cdcritic = 0.
                                         LEAVE.

                                      END.

                                      IF   aux_confirma = "N" THEN
                                           DO:
                                               NEXT-PROMPT tel_ingerest WITH
                                                           FRAME f_sol062.
                                               NEXT.
                                           END.
                                   END.
                          END.
                    ELSE      /* Nao Solicitar */
                          DO:
                               IF   tot_qtarqfol <= 1 THEN
                                    DO:
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                           ASSIGN aux_confirma = "N"
                                                  glb_cdcritic = 443.

                                           RUN fontes/critic.p.
                                           BELL.
                                           MESSAGE COLOR NORMAL glb_dscritic
                                                         UPDATE aux_confirma.
                                           glb_cdcritic = 0.
                                           LEAVE.

                                        END.

                                        IF   aux_confirma = "N" THEN
                                             DO:
                                                 NEXT-PROMPT tel_ingerest
                                                         WITH FRAME f_sol062.
                                                 NEXT.
                                             END.
                                    END.
                          END.

                    RUN proc_total_arquivo.
                    
                    DISPLAY tel_vltotfol WITH FRAME f_sol062.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       aux_confirma = "N".

                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             NEXT.
                         END.
                    
                    DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                       CREATE crapsol.
                       ASSIGN crapsol.nrsolici = aux_nrsolici
                              crapsol.dtrefere = glb_dtmvtolt
                              crapsol.nrseqsol = tel_nrseqsol
                              crapsol.cdempres = tel_cdempres
                              aux_inexecut     = IF   tel_inexecut = "S" THEN
                                                      1 ELSE 2
                              aux_ingerest     = IF   tel_ingerest = "S" THEN
                                                      1 ELSE 2
                              crapsol.dsparame =
                                 STRING(tel_dtrefere,"99/99/9999") + " " +
                                 STRING(tel_dialiber,"99") + " " +
                                 STRING(aux_inexecut,"9")  + " " +
                                 STRING(aux_ingerest,"9")
                              crapsol.insitsol = 1
                              crapsol.nrdevias = 1
                              crapsol.cdcooper = glb_cdcooper
                              aux_nrseqsol = crapsol.nrseqsol.

                       IF   tel_inexecut = "N"  THEN
                            DO:
                       
                                ASSIGN aux_flginteg = no.
                                MESSAGE COLOR NORMAL
                                       "Deseja fazer o credito neste momento ?" 
                                        UPDATE aux_flginteg.
                                IF   aux_flginteg THEN 
                                     DO:
                                         ASSIGN aux_confirma = "N"
                                                aux_flgproce = no
                                                glb_cdcritic = 78.

                                         RUN fontes/critic.p.
                                         BELL.
                                         MESSAGE COLOR NORMAL glb_dscritic
                                                       UPDATE aux_confirma.

                                         IF   aux_confirma = "S" THEN
                                              DO:
                                                  MESSAGE COLOR NORMAL
                                                          "Integrando.....".
                                                  ASSIGN aux_flgproce = yes.
                                                  /*******
                                                  RUN fontes/crps120.p "new".
                                                  MESSAGE COLOR NORMAL
                                                       "Confira os lotes "
                                                   "integrados na 'RELLOT'".
                                                  PAUSE MESSAGE 
                                "Pressione a barra de espacos para continuar".
                                                  ASSIGN glb_cdcritic = 0.
                                                  ***********/
                                              END.
                                         ELSE DO:
                                                  MESSAGE COLOR NORMAL
                                                        "Inclusao cancelada".
                                                  ASSIGN glb_cdcritic = 0.
                                                  UNDO, LEAVE.        
                                         END.       
                                    END.
                                ELSE DO:
                                    MESSAGE COLOR NORMAL
                                            "Inclusao cancelada".
                                    ASSIGN glb_cdcritic = 0.
                                    UNDO, LEAVE.        
                                END.
                            END.
                            
                    END. /* Fim da Transacao */
                    LEAVE.
                 END.

                 RELEASE crapsol.

                 /****** testes Magui 22/12/2000 *****/
                 IF   aux_flgproce  THEN
                      DO:
                           RUN fontes/integra_folha.p(INPUT aux_nrseqsol).

                          PAUSE MESSAGE 
                                "Pressione a barra de espacos para continuar".
                          ASSIGN glb_cdcritic = 0.
                      END.
            /*************************************/

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_sol062 NO-PAUSE.

             END.
        ELSE
    IF  glb_cddopcao = "R" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                HIDE MESSAGE NO-PAUSE.
               
                DO  aux_contador = 1 TO 10:

                    FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                       crapsol.nrsolici = aux_nrsolici   AND
                                       crapsol.dtrefere = glb_dtmvtolt   AND
                                       crapsol.nrseqsol = tel_nrseqsol
                                       NO-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapsol   THEN
                        IF  LOCKED crapsol   THEN
                            DO:
                                glb_cdcritic = 120.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                glb_cdcritic = 115.
                                CLEAR FRAME f_sol062.
                                LEAVE.
                            END.
                END.

                IF  glb_cdcritic <> 0   THEN
                    NEXT.
                
                FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper       AND 
                                   crapemp.cdempres = crapsol.cdempres   
                                   NO-LOCK NO-ERROR.

                IF  AVAILABLE (crapemp) THEN
                    tel_dsempres = " - " + crapemp.nmresemp.
                ELSE
                    tel_dsempres = " - NAO CADASTRADA".

                ASSIGN tel_cdempres = crapsol.cdempres
                       tel_dtrefere =
                               DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                       tel_dialiber = INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                       tel_ingerest = IF (SUBSTRING(crapsol.dsparame,17,1))
                                         = "1" THEN "S" ELSE "N"
                       tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                         = "1" THEN "S" ELSE "N"
                       tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                             " 1 - A FAZER"
                                      ELSE 
                                         IF crapsol.insitsol = 2  THEN 
                                              " 2 - PROCESSADA"
                                         ELSE
                                              " 3 - ABORTADA".

                DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                        tel_dialiber tel_ingerest tel_inexecut
                        tel_dssitsol WITH FRAME f_sol062.

                ASSIGN
                aux_nmarquiv = "rlnsv/crrl098_" + STRING(crapsol.nrseqsol,"99") + ".lst"
                aux_nmarqest = "rlnsv/crrl099_" + STRING(crapsol.nrseqsol,"99") + ".lst"
                aux_nmarqden = "rlnsv/crrl114_" + STRING(crapsol.nrseqsol,"99") + ".lst".
                
                RELEASE crapsol.

                IF  SEARCH(aux_nmarquiv) = ? AND
                    SEARCH(aux_nmarqest) = ? AND
                    SEARCH(aux_nmarqden) = ? THEN
                DO:
                    MESSAGE "Arquivos nao disponiveis para reimpressao.".
                    NEXT.
                END.

                /* confirmar reimpressao */
                ASSIGN aux_confirma = "N".
                BELL.
                MESSAGE COLOR NORMAL "Reimprimir relatorios?"
                    UPDATE aux_confirma.
                
                IF  aux_confirma = "S" THEN
                    DO:
                        MESSAGE COLOR NORMAL "Imprimindo.....".

                        ASSIGN glb_nrcopias = 1
                               glb_nrdevias = 1
                               glb_nmformul = "padrao"
                               prn_nmdafila = glb_nmdafila.
                             
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
                            UPDATE glb_nmdafila WITH FRAME f_nmdafila.
                                
                            IF  glb_nmdafila <> prn_nmdafila   THEN

                                ASSIGN aux_grep = ""
                                 	   aux_nmimpres = "^" + glb_nmdafila + ":".
                                
                                INPUT STREAM str_grep THROUGH
                                	VALUE ('grep -Ew "' + aux_nmimpres + '" /etc/qconfig' ) NO-ECHO.
                                
                                DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                                	IMPORT STREAM str_grep UNFORMATTED aux_grep.
                                END.
                                
                                IF TRIM(aux_grep) = "" THEN
/*
                                IF  SEARCH("/var/spool/lp/interface/" + 
                                            TRIM(glb_nmdafila)) = ? THEN */
                                    DO:
                                        BELL.
                                        MESSAGE "Impressora nao cadastrada -" glb_nmdafila.
                                        NEXT.
                                    END.
                                
                            HIDE FRAME f_nmdafila NO-PAUSE.
                                
                            LEAVE.
                            
                        END. /*  Fim do DO WHILE TRUE  */
                             
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                            DO:
                               BELL.
                               glb_nmdafila = prn_nmdafila.
                               HIDE FRAME f_nmdafila NO-PAUSE.
                               MESSAGE "Impressao NAO efetuada...".
                               RETURN.
                            END.

                        IF  SEARCH(aux_nmarquiv) <> ? THEN
                        DO:
                            aux_dscomand = "lp -d" + glb_nmdafila +
                                           " -n" + STRING(glb_nrdevias) +   
                                           " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                                           aux_nmarquiv +
                                           " > /dev/null".
                            UNIX SILENT VALUE(aux_dscomand).
                        END.

                        IF  SEARCH(aux_nmarqest) <> ? THEN
                        DO:
                            aux_dscomand = "lp -d" + glb_nmdafila +
                                           " -n" + STRING(glb_nrdevias) +   
                                           " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                                           aux_nmarqest +
                                           " > /dev/null".
                            UNIX SILENT VALUE(aux_dscomand).
                        END.

                        IF  SEARCH(aux_nmarqden) <> ? THEN
                        DO:
                            aux_dscomand = "lp -d" + glb_nmdafila +
                                           " -n" + STRING(glb_nrdevias) +   
                                           " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                                           aux_nmarqden +
                                           " > /dev/null".
                            UNIX SILENT VALUE(aux_dscomand).
                        END.

                        glb_nmdafila = prn_nmdafila.
                    END.
                ELSE
                    DO:
                        MESSAGE COLOR NORMAL
                            "Reimpressao cancelada.".
                        ASSIGN glb_cdcritic = 0.
                        PAUSE.
                        UNDO, LEAVE.        
                    END.

            END. /* Fim da transacao */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.

            CLEAR FRAME f_sol062 NO-PAUSE.

        END. /* end opcao R */

END.

PROCEDURE proc_total_arquivo:

    aux_arqfolha = "integra/f" + STRING(tel_cdempres,"99999") +
                                 STRING(tel_dtrefere,"99999999") + "." +
                                 STRING(tel_dialiber,"99").

    IF   SEARCH(aux_arqfolha) = ?   THEN
         DO: 
             IF   LENGTH(STRING(tel_cdempres)) > 2  THEN
                  aux_arqfolha = "integra/f" + STRING(tel_cdempres,"999") +
                                 STRING(tel_dtrefere,"99999999") + "." +
                                 STRING(tel_dialiber,"99").
             ELSE
                  aux_arqfolha = "integra/f" + STRING(tel_cdempres,"99") +
                                 STRING(tel_dtrefere,"99999999") + "." +
                                 STRING(tel_dialiber,"99").
                            
             IF   SEARCH(aux_arqfolha) = ?   THEN
                  DO:  
                      tel_vltotfol = 0.
                      RETURN.  
                  END.           
                  
         END.

    INPUT STREAM str_1 FROM VALUE(aux_arqfolha) NO-ECHO.
     
    SET STREAM str_1 aux_tpregist ^ ^ ^ ^ NO-ERROR.
    
    tel_vltotfol = 0.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       SET STREAM str_1 aux_tpregist ^ ^ aux_vllanmto ^ NO-ERROR.
 
       IF   aux_tpregist = 0   THEN
            tel_vltotfol = tel_vltotfol + aux_vllanmto.
       ELSE
            LEAVE.
    
    END.  /*   Fim do DO WHILE TRUE  */
    
END PROCEDURE.

/* .......................................................................... */
