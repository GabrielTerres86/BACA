/* .............................................................................

   Programa: Fontes/sol008.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/92

   Dados referentes ao programa:                 Ultima Alteracao : 13/11/2015
      
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL008.

   Alteracoes: 26/05/95 - Alterado para nao permitir solicitar para empresas
                          que tenham tpdebcot e tpdebemp = 2 (Odair).

               20/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               17/01/2000 - Tratar tpdebemp = 3 (Deborah).
               
               28/08/2001 - Implementar os mesmos procedimentos da sol062 para
                            permitir o processamento imediato da solicitacao
                            (Junior).
                            
               08/11/2004 - Implementar os mesmos procedimentos da sol062 para
                            exibir o total do arquivo;
                            Pedir confirmacao na Inclusao "I" (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               12/09/2006 - Alteracao no help dos campos da tela (Elton).
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               05/06/2009 - Corrigido para mostrar Valor Total da folha
                            (Diego).
                    
               07/02/2013 - Ajuste no format do campo Sequencia para "99" 
                            (Daniele).
                           
               10/10/2013 - SD 93349. Retirado o parametro NEW na chamada
                            de crps012 para impressao direta pelo usuario,
                            ao inves de ir para processo noturno (Carlos)
                            
               27/12/2013 - SD 108354 - inclusao da opcao R para reimprimir
                            o relatorio (Carlos)
							
			   25/03/2014 - Ajuste processo busca impressora (Daniel).	
							
			   13/11/2015 - Inclusao de verificacao estado de crise. 
                            (Jaison/Andrino)

............................................................................. */

{ includes/var_online.i } 
{ sistema/generico/includes/var_oracle.i }

DEF        VAR tel_nrseqsol AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(17)"                NO-UNDO.
DEF        VAR tel_dialiber AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_inexecut AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR tel_insitsol AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_inexecut AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 08           NO-UNDO.

DEF        VAR aux_tpintegr AS CHAR    INIT "f"                      NO-UNDO.
DEF        VAR aux_flginteg AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR aux_flgproce AS LOGICAL                               NO-UNDO.

DEF        VAR tel_vltotfol AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_arqfolha AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR aux_tpregist AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "999999999999.99"      NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(20)"                NO-UNDO.

/* vars para impressao.i */
DEF    VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF    VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF    VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF    VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF    VAR par_flgcance AS LOGICAL                                    NO-UNDO.
DEF    VAR prn_nmdafila AS CHAR                                       NO-UNDO.
DEF    VAR aux_flestcri AS INTE                                       NO-UNDO.

DEf    VAR aux_grep     AS CHAR    FORMAT "x(15)"                     NO-UNDO.

DEF    VAR aux_nmimpres AS CHAR    FORMAT "x(15)"                     NO-UNDO.

DEF        STREAM str_1. /* somente para "pegar" o total do arquivo */

DEF        STREAM str_grep.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE COLOR MESSAGE " Creditos de Folha de Pagamento "
                   FRAME f_moldura.

FORM SKIP   
     glb_cddopcao AT  4 LABEL "Opcao           " AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E,I ou R)"
                        VALIDATE (glb_cddopcao = "A" OR 
                                  glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR 
                                  glb_cddopcao = "I" OR
                                  glb_cddopcao = "R",
                                  "014 - Opcao errada.")
     SKIP (1)
     tel_nrseqsol AT  4 LABEL "Sequencia       " AUTO-RETURN
                        HELP "Informe o numero da sequencia do arquivo."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_cdempres AT  4 LABEL "Empresa         " AUTO-RETURN
                        HELP "Informe o codigo da empresa."
                        VALIDATE (CAN-FIND (crapemp WHERE crapemp.cdcooper =
                                                          glb_cdcooper   AND
                                                          crapemp.cdempres =
                                  tel_cdempres),"040 - Empresa nao cadastrada.")
     tel_dsempres AT 27 NO-LABEL

     SKIP (1)
     tel_dtrefere AT  4 LABEL "Data Referencia " AUTO-RETURN
                        HELP "Informe a data de referencia do credito da folha."
                        VALIDATE (tel_dtrefere <> ?,"013 - Data errada.")
     SKIP (1)
     tel_dialiber AT  4 LABEL "Dia de Liberacao" AUTO-RETURN
                        HELP "Informe o dia para efetuar a liberacao do credito."
                        VALIDATE (tel_dialiber > 00 and tel_dialiber < 32,
                                  "013 - Data errada.")
     SKIP (1)
     tel_inexecut AT  4 LABEL "Integr. Processo" AUTO-RETURN
                        HELP
                        "Informe 'S' p/integrar a noite ou 'N' p/integrar durante o dia."
                        VALIDATE (tel_inexecut = "S" OR tel_inexecut = "N",
                                  "024 - Deve ser S ou N.")
     SKIP (1)
     tel_insitsol AT  4 LABEL "Situacao        "
     tel_dssitsol AT 24 NO-LABEL
     SKIP (1)
     tel_vltotfol AT  4 LABEL "Total do arquivo"
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol008.

VIEW FRAME f_moldura.

FORM SKIP(1)
     glb_nmdafila LABEL "  Imprimir em" " "
     SKIP(1)
     WITH ROW 14 CENTERED OVERLAY SIDE-LABELS 
          TITLE COLOR NORMAL " Destino " FRAME f_nmdafila.

glb_cddopcao = "I".

PAUSE(0).

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol008.
        NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol008.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           PROMPT-FOR glb_cddopcao tel_nrseqsol
                      WITH FRAME f_sol008.
           LEAVE.

        END.
                
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL008"   THEN
                      DO:
                          HIDE FRAME f_integra.
                          HIDE FRAME f_sol008.
                          HIDE FRAME f_moldura.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
        
        /* Efetuar a chamada a rotina Oracle */
        RUN STORED-PROCEDURE pc_estado_crise
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "N"              /* Identificador para verificar processo (N – Nao / S – Sim) */
                                            ,OUTPUT 0               /* Identificador estado de crise (0 - Nao / 1 - Sim) */
                                            ,OUTPUT ?).             /* XML com informacoes das cooperativas */
        
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
                BELL.
                MESSAGE "Sistema em estado de crise.".
                PAUSE 1 NO-MESSAGE.
            END.
        ELSE
            DO:
                IF   aux_cddopcao <> INPUT glb_cddopcao THEN
                     DO:
                         { includes/acesso.i }
                         aux_cddopcao = INPUT glb_cddopcao.
                     END.
        
                { includes/listaint.i }
        
                ASSIGN tel_nrseqsol = INPUT tel_nrseqsol
                       aux_nrseqsol = INPUT tel_nrseqsol
                       glb_cddopcao = INPUT glb_cddopcao
                       tel_inexecut = "S"
                       aux_flgproce = NO
                       glb_cdcritic = 0.
        
                IF   INPUT glb_cddopcao = "A" THEN
                     DO:
                         DO TRANSACTION ON ENDKEY UNDO, LEAVE:
        
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
                                              CLEAR FRAME f_sol008. 
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
                                 DO:
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     ASSIGN tel_nrseqsol = aux_nrseqsol.
                                     DISPLAY tel_nrseqsol WITH FRAME f_sol008.
                                     NEXT.
                                 END.
        
                            FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
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
                                   tel_inexecut = IF
                                       (SUBSTRING(crapsol.dsparame,15,1)) = "1" THEN
                                        "S" ELSE "N"
                                   tel_insitsol = crapsol.insitsol
                                   tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                                     " - A FAZER"         ELSE
                                                     " - PROCESSADA".
                            DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                                    tel_dialiber tel_inexecut
                                    tel_insitsol tel_dssitsol
                                    WITH FRAME f_sol008.
        
                            DO WHILE TRUE:
        
                               SET  tel_cdempres tel_dtrefere tel_dialiber
                                    tel_inexecut WITH FRAME f_sol008.
        
                               IF   YEAR(tel_dtrefere)  = YEAR(glb_dtmvtolt) - 1   AND
                                    MONTH(tel_dtrefere) = 12                       THEN
                                    glb_cdcritic = 0.
                               ELSE
                               IF   MONTH(tel_dtrefere) > MONTH(glb_dtmvtolt)       OR
                                    MONTH(tel_dtrefere) < (MONTH(glb_dtmvtolt) - 1) THEN
                                    DO:
                                        glb_cdcritic = 13.
                                        NEXT-PROMPT tel_dtrefere WITH FRAME f_sol008.
                                    END.
        
                               IF   glb_cdcritic = 0 THEN
                                    DO:
                                        FIND  crapemp WHERE
                                              crapemp.cdcooper = glb_cdcooper AND
                                              crapemp.cdempres = tel_cdempres
                                              NO-LOCK NO-ERROR.
                                                                          
                                        IF   crapemp.tpdebemp = 2    OR
                                             crapemp.tpdebemp = 3    OR
                                             crapemp.tpdebcot = 2    OR
                                             crapemp.tpdebcot = 3    THEN
                                             DO:
                                                glb_cdcritic = 440.
                                                NEXT-PROMPT tel_cdempres WITH FRAME
                                                                         f_sol008.
                                             END.                      
                                    END.
        
                               IF   glb_cdcritic > 0 THEN
                                    DO:
                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        glb_cdcritic = 0.
                                        NEXT.
                                    END.
        
                               ASSIGN crapsol.cdempres = tel_cdempres
                                      aux_inexecut     = IF   tel_inexecut = "S" THEN
                                                              1 ELSE 2
                                      crapsol.dsparame =
                                          STRING(tel_dtrefere,"99/99/9999") + " " +
                                          STRING(tel_dialiber,"99")       + " " +
                                          STRING(aux_inexecut,"9").
        
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
        
                         IF   aux_flgproce  THEN
                              DO:
                                  RUN fontes/crps012.p.
        
                                  PAUSE MESSAGE 
                                          "Pressione a barra de espacos para continuar".
                                  ASSIGN glb_cdcritic = 0.
                              END.
                          
                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                              NEXT.
        
                         CLEAR FRAME f_sol008 NO-PAUSE.
        
                     END.
                ELSE
                IF   INPUT glb_cddopcao = "C" THEN
                     DO:
                         FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                            crapsol.nrsolici = aux_nrsolici   AND
                                            crapsol.dtrefere = glb_dtmvtolt   AND
                                            crapsol.nrseqsol = tel_nrseqsol   NO-LOCK
                                            USE-INDEX crapsol1 NO-ERROR.
        
                         IF   NOT AVAILABLE crapsol   THEN
                              DO:
                                  ASSIGN glb_cdcritic = 115.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  CLEAR FRAME f_sol008.
                                  ASSIGN tel_nrseqsol = aux_nrseqsol.
                                  DISPLAY tel_nrseqsol WITH FRAME f_sol008.
                                  NEXT.
                              END.
        
                         FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
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
                                tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                               = "1" THEN "S" ELSE "N"
                                tel_insitsol = crapsol.insitsol
                                tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                                  " - A FAZER"         ELSE
                                                  " - PROCESSADA".
                         DISPLAY tel_cdempres tel_dsempres tel_dtrefere tel_dialiber
                                 tel_inexecut tel_insitsol tel_dssitsol
                                 WITH FRAME f_sol008.
        
                     END.
                ELSE
                IF   INPUT glb_cddopcao = "E"   THEN
                     DO:
                         DO TRANSACTION ON ENDKEY UNDO, LEAVE:
        
                            DO  aux_contador = 1 TO 10:
        
                                FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                                   crapsol.nrsolici = aux_nrsolici   AND
                                                   crapsol.dtrefere = glb_dtmvtolt   AND
                                                   crapsol.nrseqsol = tel_nrseqsol
                                                   USE-INDEX crapsol1
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                                IF   NOT AVAILABLE crapsol   THEN
                                     IF   LOCKED crapsol   THEN
                                          DO:
                                              ASSIGN glb_cdcritic = 120.
                                              PAUSE 1 NO-MESSAGE.
                                              NEXT.
                                          END.
                                     ELSE
                                          DO:
                                              ASSIGN glb_cdcritic = 115.
                                              CLEAR FRAME f_sol008.
                                              LEAVE.
                                          END.
                                ELSE
                                     DO:
                                         ASSIGN aux_contador = 0.
                                         LEAVE.
                                     END.
                            END.
        
                            IF   aux_contador <> 0   THEN
                                 DO:
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     ASSIGN tel_nrseqsol = aux_nrseqsol.
                                     DISPLAY tel_nrseqsol WITH FRAME f_sol008.
                                     NEXT.
                                 END.
        
                            FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
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
                                   tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                                  = "1" THEN "S" ELSE "N"
                                   tel_insitsol = crapsol.insitsol
                                   tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                                     " - A FAZER"         ELSE
                                                     " - PROCESSADA".
                            DISPLAY tel_cdempres tel_dsempres tel_dtrefere tel_dialiber
                                    tel_inexecut tel_insitsol tel_dssitsol
                                    WITH FRAME f_sol008.
        
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                               ASSIGN aux_confirma = "N"
                                      glb_cdcritic = 78.
        
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                               LEAVE.
        
                            END.
        
                            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                 aux_confirma <> "S" THEN
                                 DO:
                                     ASSIGN glb_cdcritic = 79.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     NEXT.
                                 END.
        
                            DELETE crapsol.
                            CLEAR FRAME f_sol008 NO-PAUSE.
        
                         END. /* Fim da transacao */
        
                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                              NEXT.
                     END.
                ELSE
                IF   INPUT glb_cddopcao = "I"   THEN
                     DO:
                         ASSIGN tel_cdempres = 0
                                tel_dialiber = 0
                                tel_dtrefere = ?
                                tel_inexecut = "S".
        
                         CLEAR FRAME f_sol008 NO-PAUSE.
        
                         DISPLAY glb_cddopcao tel_nrseqsol WITH FRAME f_sol008.
        
                         FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                            crapsol.nrsolici = aux_nrsolici   AND
                                            crapsol.dtrefere = glb_dtmvtolt   AND
                                            crapsol.nrseqsol = tel_nrseqsol
                                            USE-INDEX crapsol1 NO-LOCK NO-ERROR NO-WAIT.
        
                         IF   AVAILABLE crapsol   THEN
                              DO:
                                  ASSIGN glb_cdcritic = 118.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  CLEAR FRAME f_sol008.
                                  ASSIGN tel_nrseqsol = aux_nrseqsol.
                                  DISPLAY tel_nrseqsol WITH FRAME f_sol008.
                                  NEXT.
                              END.
        
                         DO TRANSACTION ON ENDKEY UNDO, LEAVE:
        
                            CREATE crapsol.
        
                            ASSIGN crapsol.nrsolici = aux_nrsolici
                                   crapsol.dtrefere = glb_dtmvtolt
                                   crapsol.nrseqsol = tel_nrseqsol
                                   crapsol.cdcooper = glb_cdcooper.
        
                            DO WHILE TRUE:
        
                               SET tel_cdempres tel_dtrefere tel_dialiber tel_inexecut
                                   WITH FRAME f_sol008.
        
                               IF   YEAR(tel_dtrefere)  = YEAR(glb_dtmvtolt) - 1    AND
                                    MONTH(tel_dtrefere) = 12                       THEN
                                    glb_cdcritic = 0.
                               ELSE
                               IF   MONTH(tel_dtrefere) > MONTH(glb_dtmvtolt)  OR
                                    MONTH(tel_dtrefere) < (MONTH(glb_dtmvtolt) - 1)
                                    THEN
                                    DO:
                                        glb_cdcritic = 13.
                                        NEXT-PROMPT tel_dtrefere WITH FRAME f_sol008.
                                    END.
        
                               IF   glb_cdcritic = 0 THEN
                                    DO:
                                        FIND  crapemp WHERE
                                              crapemp.cdcooper = glb_cdcooper AND
                                              crapemp.cdempres = tel_cdempres 
                                              NO-LOCK NO-ERROR.
        
                                        IF   crapemp.tpdebemp = 2    OR
                                             crapemp.tpdebemp = 3    OR
                                             crapemp.tpdebcot = 2    OR
                                             crapemp.tpdebcot = 3    THEN
                                             DO:
                                                glb_cdcritic = 440.
                                                NEXT-PROMPT tel_cdempres WITH FRAME
                                                                              f_sol008.
                                             END.
                                    END.
        
                               IF   glb_cdcritic > 0 THEN
                                    DO:
                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        glb_cdcritic = 0.
                                        NEXT.
                                    END.
        
                               RUN proc_total_arquivo.
        
                               DISPLAY tel_vltotfol WITH FRAME f_sol008.
        
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
        
                               ASSIGN crapsol.cdempres = tel_cdempres
                                      aux_inexecut     = IF   tel_inexecut = "S" THEN
                                                              1 ELSE 2
                                      crapsol.dsparame =
                                         STRING(tel_dtrefere,"99/99/9999") + " " +
                                         STRING(tel_dialiber,"99") + " " +
                                         STRING(aux_inexecut,"9")
                                      crapsol.insitsol = 1
                                      crapsol.nrdevias = 1.
                            
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
                               
                               LEAVE.
        
                            END.
        
                         END. /* Fim da transacao */
        
                         RELEASE crapsol.
         
                         IF   aux_flgproce  THEN
                              DO:
                                  RUN fontes/crps012.p.
        
                                  PAUSE MESSAGE 
                                        "Pressione a barra de espacos para continuar".
                                  ASSIGN glb_cdcritic = 0.
                              END.
         
                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                              NEXT.
        
                         CLEAR FRAME f_sol008 NO-PAUSE.
        
                     END.
                ELSE
                /* Recuperar a impressão de críticas dos arquivos integrados  */
                IF  INPUT glb_cddopcao = "R"  THEN
                    DO:
                        ASSIGN tel_cdempres = 0
                               tel_dialiber = 0
                               tel_dtrefere = ?
                               tel_inexecut = "S".
                        
                        CLEAR FRAME f_sol008 NO-PAUSE.
            
                        DISPLAY glb_cddopcao tel_nrseqsol WITH FRAME f_sol008.
            
                        DO TRANSACTION ON ENDKEY UNDO, LEAVE:
        
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
                                           /* CLEAR FRAME f_sol008.*/
                                            LEAVE.
                                        END.
                            END. /* contador 1 to 10 */
                            
                            IF  glb_cdcritic <> 0   THEN
                                DO:
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    NEXT.
                                END.
        
                            FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
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
                                   tel_dialiber =
                                       INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                                   tel_inexecut = IF
                                       (SUBSTRING(crapsol.dsparame,15,1)) = "1" THEN
                                        "S" ELSE "N"
                                   tel_insitsol = crapsol.insitsol
                                   tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                                     " - A FAZER"         ELSE
                                                     " - PROCESSADA".
                            DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                                    tel_dialiber tel_inexecut
                                    tel_insitsol tel_dssitsol
                                    WITH FRAME f_sol008.
        
                        END. /* DO TRANSACTION ON ENDKEY UNDO, LEAVE: */
        
                        ASSIGN aux_nmarquiv = "rlnsv/crrl016_" +
                                              STRING(crapsol.nrseqsol,"99") + ".lst".
        
                        IF  SEARCH(aux_nmarquiv) = ?  THEN
                        DO:
                            MESSAGE "Arquivo nao disponivel para reimpressao.".
                            NEXT.
                        END.
        
                        /* confirmar reimpressao */
                        ASSIGN aux_confirma = "N".
                        BELL.
                        MESSAGE COLOR NORMAL "Reimprimir relatorio?"
                            UPDATE aux_confirma.
                        
                        IF  aux_confirma = "S" THEN
                            DO:
                                MESSAGE COLOR NORMAL "Imprimindo.....".
        
                                ASSIGN glb_nmarqimp = aux_nmarquiv
                                       glb_nrcopias = 1
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
                             
                                aux_dscomand = "lp -d" + glb_nmdafila +
                                               " -n" + STRING(glb_nrdevias) +   
                                               " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                                               glb_nmarqimp +
                                               " > /dev/null".
                            
                                UNIX SILENT VALUE(aux_dscomand).
                                
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
        
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                            NEXT.
        
                        CLEAR FRAME f_sol008 NO-PAUSE.
        
                    END. /* cddopcao = R */
            END.
            
END.


PROCEDURE proc_total_arquivo:

    aux_arqfolha = "integra/f" + STRING(tel_cdempres,"99999") +
                                 STRING(tel_dtrefere,"99999999") + "." +
                                 STRING(tel_dialiber,"99").

    IF   SEARCH(aux_arqfolha) = ?   THEN
         DO:
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
    
    INPUT STREAM str_1 CLOSE.
    
END PROCEDURE.

/* ......................................................................... */


