/* .............................................................................

   Programa: Fontes/numcob.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/97.                       Ultima atualizacao: 18/02/2011
    
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela NUMCOB.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               04/09/98 - Tratar tipo de conta 7 (Deborah).

               10/03/2004 - Permitir informar tambem contas de aplicacao
                            (crapass.cdtipcta = 6,7)(Mirtes)
                            
               24/09/2004 - Incluir mais duas posicoes do Nro Convenio (Ze)
               
               08/10/2004 - Nao reconhecer o dv para a Concredi (Ze).
               
               18/01/2005 - Nao reconhecer o dv para a Credcrea (Ze).
               
               02/03/2005 - Incluida a quantidade de bloquetos(Evandro).
               
               03/03/2005 - Tratamento de Erros (Ze).
               
               15/04/2005 - Tratamento para a importacao do cadastramento
                            dos bloquetos (Ze).

               05/08/2005 - Incluir F7 para numero convenios (Ze).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                            Eder

               21/02/2006 - Alteracao da consulta do craptab para o crapcco
                            (Julio)
                            
               12/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                            (Diego).
                            
               13/04/2009 - Tratar origem dos conv. - Proj. Melhorias Cob (Ze)
               
               01/12/2010 - Alteracao de Format (Kbase/Willian).
                            001 - Alterado para 50 posições, valor anterior 40
                            e posicao do campos. 
                            
               18/02/2011 - Incluir critica para validacao da crapceb
                            (Gabriel).

               08/03/2018 - Substituida verificacao "cdtipcta = 5" por codigo 
                            da modalidade = 2. PRJ366(Lombardi).

.............................................................................. */

{ sistema/generico/includes/var_oracle.i }
{ includes/var_online.i }


DEF        VAR tel_nrdctabb AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(50)"                NO-UNDO. /*001*/
DEF        VAR tel_cddbanco AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrcnvcob AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF        VAR tel_nrblqini AS INT     FORMAT "zzz,zzz,9"            NO-UNDO.
DEF        VAR tel_nrblqfim AS INT     FORMAT "zzz,zzz,9"            NO-UNDO.
DEF        VAR tel_qtbloque AS INT     FORMAT "z,zz9"                NO-UNDO.

DEF        VAR aux_nrblqfim AS INT                                   NO-UNDO.
DEF        VAR aux_cdnosnur AS DECI                                  NO-UNDO.
DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dsdocmto AS CHAR   FORMAT "x(24)"                 NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_cdmodali AS INT                                   NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.


DEF TEMP-TABLE crawcnv                                               NO-UNDO
           FIELD cdconven   AS INTEGER.

DEF        QUERY  q_numconve FOR crawcnv. 
DEF        BROWSE b_numconve QUERY q_numconve
                  DISP crawcnv.cdconven  COLUMN-LABEL "Convenio"
                       WITH 6 DOWN OVERLAY.    

FORM SKIP(2)
     glb_cddopcao AT  7 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E ou I)"
                        VALIDATE (glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     tel_cddbanco COLON 22 LABEL "Banco"
                        HELP "Informe o banco da cobranca"
     SKIP(1)
     tel_nrdctabb COLON 22 LABEL "Conta Base"
                        HELP "Informe a Conta Base da cobranca"
     SKIP(1)
     tel_nrcnvcob COLON 22 LABEL "Convenio"
                        HELP "Informe o numero do convenio / F7 para listar"
                        VALIDATE(tel_nrcnvcob > 0,
                                 "380 - Numero errado")
     tel_qtbloque AT 50 LABEL "Qtd. Bloquetos"
                        HELP "Informa a quantidade de bloquetos"
     SKIP(1)
     tel_nrblqini COLON 22 LABEL "Bloqueto inicial"
                        HELP "Informe o numero do bloqueto inicial"
                        VALIDATE(tel_nrblqini > 0, "380 - Numero errado")
     SKIP(1)
     tel_nrblqfim COLON 22 LABEL "Bloqueto final"
                        HELP "Informe o numero do bloqueto final"
                        VALIDATE(tel_nrblqfim >= tel_nrblqini,
                           "380 - Numero errado")
     SKIP(1)
     tel_nrdconta COLON 22 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado"
     SKIP(1)
     tel_nmprimtl COLON 22 LABEL "Titular"
     SKIP(1)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_numcob.

FORM b_numconve SKIP 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_num_convenio.


ON RETURN OF b_numconve DO:
                                  
   ASSIGN tel_nrcnvcob = crawcnv.cdconven.
                             
   DISPLAY tel_nrcnvcob WITH FRAME f_numcob.
       
   APPLY "GO".
END.


ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0.

NEXT-PROMPT tel_cddbanco WITH FRAME f_numcob.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            IF   glb_cdcritic = 589 OR glb_cdcritic = 588 OR glb_cdcritic = 593
                 THEN
                 MESSAGE glb_dscritic + aux_dsdocmto.
            ELSE
                 MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_numcob.

      HIDE tel_qtbloque IN FRAME f_numcob.

      UPDATE tel_cddbanco  tel_nrdctabb  tel_nrcnvcob  tel_qtbloque
             tel_nrblqini  WITH FRAME f_numcob
          
      EDITING:

         DO WHILE TRUE:
               
            IF   glb_cddopcao <> "I"   THEN
                 HIDE tel_qtbloque IN FRAME f_numcob.

            READKEY PAUSE 1.
               
            IF   LASTKEY = KEYCODE("F7")       AND
                 FRAME-FIELD = "tel_nrcnvcob"  THEN
                 DO:                      
                     EMPTY TEMP-TABLE crawcnv.
                           
                     FOR EACH crapcco WHERE crapcco.cdcooper = glb_cdcooper AND
                                            crapcco.cddbanco = 1       NO-LOCK.

                         CREATE crawcnv.
                         ASSIGN crawcnv.cdconven = crapcco.nrconven.
                     END.
                           
                     OPEN QUERY q_numconve FOR EACH crawcnv.

                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b_numconve WITH FRAME f_num_convenio.
                        LEAVE.
                     END.
                                   
                     HIDE FRAME f_num_convenio.
                  END.
                       
            APPLY LASTKEY.
                      
            LEAVE. 

         END. /* fim DO WHILE */
      
      END. 

      glb_nrcalcul = tel_nrdctabb.
      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT-PROMPT tel_nrdctabb WITH FRAME f_numcob.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "NUMCOB"   THEN
                 DO:
                     HIDE FRAME f_numcob.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   ASSIGN glb_cdcritic = 0.

   ASSIGN aux_regexist = FALSE.

   FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper AND
                      crapcco.cddbanco  = tel_cddbanco AND
                      crapcco.nrconven  = tel_nrcnvcob AND
                      crapcco.nrdctabb  = tel_nrdctabb             
                      NO-LOCK NO-ERROR.

   IF   AVAILABLE crapcco   THEN
        DO:
            ASSIGN aux_nrblqfim = crapcco.nrbloque.

            IF   crapcco.dsorgarq = "INTERNET"               OR
                 crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" THEN
                 DO:        
                     glb_cdcritic = 846.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.
                 END.
            ELSE
                 aux_regexist = TRUE.
        END.

   IF   NOT aux_regexist THEN
        DO:
            IF   glb_cdcritic = 0   THEN
                 glb_cdcritic = 586.
            NEXT-PROMPT tel_cddbanco WITH FRAME f_numcob.
            NEXT.
        END.

   IF   crapcco.tamannro = 12   THEN
        DO:
            aux_cdnosnur = DECI(STRING(tel_nrcnvcob,"99999999") +
                                STRING(tel_nrblqini,"999999")).

            glb_nrcalcul = aux_cdnosnur.
            RUN fontes/digfun.p.

            IF   NOT glb_stsnrcal THEN
                 DO:
                     glb_cdcritic = 8.
                     NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.
                     NEXT.
                 END.
        END.
        
   IF   glb_cddopcao = "C"   THEN
        DO:
            FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper      AND
                               crapcob.cdbandoc = tel_cddbanco      AND
                               crapcob.nrdctabb = tel_nrdctabb      AND
                               crapcob.nrcnvcob = tel_nrcnvcob      AND
                               crapcob.nrdocmto = tel_nrblqini
                               USE-INDEX crapcob1 
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcob THEN
                 DO:
                     glb_cdcritic = 592.
                     NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.
                     NEXT.
                 END.

            IF   crapcob.nrdconta = 0 THEN
                 DO:
                     glb_cdcritic = 589.
                     NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.
                     ASSIGN tel_nrdconta = 0
                            tel_nmprimtl = ""
                            tel_nrblqfim = 0
                            aux_dsdocmto = "".

                     DISPLAY tel_nrdconta tel_nmprimtl tel_nrblqfim WITH
                             FRAME f_numcob.

                     NEXT.
                 END.

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = crapcob.nrdconta
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapass THEN
                 DO:
                     glb_cdcritic = 251.
                     NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.
                     NEXT.
                 END.
            ELSE
                 DO:
                     ASSIGN tel_nmprimtl = crapass.nmprimtl
                            tel_nrdconta = crapcob.nrdconta
                            tel_nrblqfim = 0.

                     DISPLAY  tel_nrblqfim tel_nrdconta  tel_nmprimtl
                              WITH FRAME f_numcob.
                 END.

            NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.

        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            DO WHILE TRUE:

               IF   glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_nrblqfim tel_nrdconta WITH FRAME f_numcob.

               IF   crapcco.tamannro = 12   THEN
                    DO:
                        aux_cdnosnur = DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrblqfim,"999999")).

                        glb_nrcalcul = aux_cdnosnur.
                        
                        RUN fontes/digfun.p.

                        IF   NOT glb_stsnrcal THEN
                             DO:
                                 glb_cdcritic = 8.
                                 NEXT-PROMPT tel_nrblqfim WITH FRAME f_numcob.
                                 NEXT.
                             END.
                    END.
               
               glb_nrcalcul = tel_nrdconta.
               RUN fontes/digfun.p.

               IF   NOT glb_stsnrcal THEN
                    DO:
                        glb_cdcritic = 8.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_numcob.
                        NEXT.
                    END.
               
               IF   tel_nrblqfim > aux_nrblqfim THEN
                    DO:
                        glb_cdcritic = 380.
                        NEXT-PROMPT tel_nrblqfim WITH FRAME f_numcob.
                        NEXT.
                    END.

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                  crapass.nrdconta = tel_nrdconta
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass THEN
                    DO:
                        glb_cdcritic = 9.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_numcob.
                        NEXT.
                    END.

               tel_nmprimtl = crapass.nmprimtl.

               FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper  AND
                                      crapcob.cdbandoc  = tel_cddbanco  AND
                                      crapcob.nrdctabb  = tel_nrdctabb  AND
                                      crapcob.nrcnvcob  = tel_nrcnvcob  AND
                                      crapcob.nrdocmto >= tel_nrblqini  AND
                                      crapcob.nrdocmto <= tel_nrblqfim  NO-LOCK:

                   IF   tel_nrdconta = 0      OR
                        crapcob.incobran <> 0 OR
                        crapcob.dtretcob = ? THEN
                        DO:

                            ASSIGN tel_nmprimtl = ""
                                   glb_cdcritic = 589.

                            DISPLAY tel_nmprimtl  WITH FRAME f_numcob.

                            aux_dsdocmto = " Bloqueto -> "  +
                                           STRING(crapcob.nrdocmto,"zz,zzz,9").
                            LEAVE.
                        END.

                   IF   crapcob.nrdconta <> tel_nrdconta AND
                        tel_nrdconta <> 0 THEN
                        DO:
                            glb_cdcritic = 593.
                            aux_dsdocmto = " Bloqueto -> "  +
                                           STRING(crapcob.nrdocmto,"zz,zzz,9").
                            LEAVE.
                        END.

               END.

               LEAVE.

            END.

            IF   glb_cdcritic > 0 THEN
                 DO:
                     NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.
                     NEXT.
                 END.

            DISPLAY tel_nmprimtl WITH FRAME f_numcob.

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 DO:
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_numcob.
                     NEXT.
                 END.

            FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper     AND
                                   crapcob.cdbandoc  = tel_cddbanco     AND
                                   crapcob.nrdctabb  = tel_nrdctabb     AND
                                   crapcob.nrcnvcob  = tel_nrcnvcob     AND
                                   crapcob.nrdocmto >= tel_nrblqini     AND
                                   crapcob.nrdocmto <= tel_nrblqfim
                                   EXCLUSIVE-LOCK TRANSACTION:

                ASSIGN crapcob.nrdconta = 0
                       crapcob.dtretcob = ?.

            END.

        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            DO WHILE TRUE:

               IF   glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_nrblqfim tel_nrdconta WITH FRAME f_numcob.

               IF   crapcco.tamannro = 12   THEN
                    DO:
                        aux_cdnosnur = DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrblqfim,"999999")).
                        
                        glb_nrcalcul = aux_cdnosnur.
         
                        RUN fontes/digfun.p.

                        IF   NOT glb_stsnrcal THEN
                             DO:
                                 glb_cdcritic = 8.
                                 NEXT-PROMPT tel_nrblqfim WITH FRAME f_numcob.
                                 NEXT.
                             END.
                    END.
                    
               glb_nrcalcul = tel_nrdconta.
               RUN fontes/digfun.p.

               IF   NOT glb_stsnrcal THEN
                    DO:
                        glb_cdcritic = 8.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_numcob.
                        NEXT.
                    END.

               IF   tel_nrblqfim > aux_nrblqfim THEN
                    DO:
                        glb_cdcritic = 380.
                        NEXT-PROMPT tel_nrblqfim WITH FRAME f_numcob.
                        NEXT.
                    END.

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                                  crapass.nrdconta = tel_nrdconta
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass THEN
                    DO:
                        glb_cdcritic = 9.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_numcob.
                        NEXT.
                    END.

               tel_nmprimtl = crapass.nmprimtl.

               { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

               RUN STORED-PROCEDURE pc_busca_modalidade_tipo
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                    INPUT crapass.cdtipcta, /* Tipo de conta */
                                                   OUTPUT 0,                /* Modalidade */
                                                   OUTPUT "",               /* Flag Erro */
                                                   OUTPUT "").              /* Descrição da crítica */

               CLOSE STORED-PROC pc_busca_modalidade_tipo
                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

               { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

               ASSIGN aux_cdmodali = 0
                      aux_des_erro = ""
                      aux_dscritic = ""
                      aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                     WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                      aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                     WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                      aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                     WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.

               IF aux_des_erro = "NOK"  THEN
                   DO:
                      ASSIGN glb_dscritic = aux_dscritic.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_numcob.
                      NEXT.
                   END.
               
               IF aux_cdmodali = 2 THEN
                    DO:
                        glb_cdcritic = 127.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_numcob.
                        NEXT.
                    END.

               FIND crapceb WHERE crapceb.cdcooper = glb_cdcooper   AND
                                  crapceb.nrdconta = tel_nrdconta   AND
                                  crapceb.nrconven = crapcco.nrconven
                                  NO-LOCK NO-ERROR.

               IF  NOT AVAILABLE crapceb  THEN
                   DO:
                      MESSAGE 
          "Cooperado nao possui cadastro de cobranca. Verifique tela ATENDA.".
                       NEXT.
                   END.

               IF  crapceb.insitceb <> 1  THEN
                   DO:
                       MESSAGE
                        "Cadastro de cobranca inativo. Verifique tela ATENDA.".
                       NEXT.
                   END.
                  
               FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper  AND
                                      crapcob.cdbandoc  = tel_cddbanco  AND
                                      crapcob.nrdctabb  = tel_nrdctabb  AND
                                      crapcob.nrcnvcob  = tel_nrcnvcob  AND
                                      crapcob.nrdocmto >= tel_nrblqini  AND
                                      crapcob.nrdocmto <= tel_nrblqfim  NO-LOCK:

                   IF   crapcob.incobran <> 0 OR crapcob.nrdconta <> 0 OR
                        crapcob.dtretcob <> ? THEN
                        DO:
                            ASSIGN tel_nmprimtl = ""
                                   glb_cdcritic = 588.

                            DISPLAY tel_nmprimtl  WITH FRAME f_numcob.

                            aux_dsdocmto = " Bloqueto -> "  +
                                           STRING(crapcob.nrdocmto,"zz,zzz,9").

                            LEAVE.
                        END.
               END.

               LEAVE.
            END.

            IF   crapcco.tamannro = 17 THEN
                 DO:  
                     /* se a quantidade de bloquetos nao fechar */
                     IF  (INTEGER(tel_nrblqfim) -
                          INTEGER(tel_nrblqini) + 1) <>
                         tel_qtbloque   THEN
                         DO:
                             glb_cdcritic = 0.
                             MESSAGE "A quantidade de bloquetos nao confere "
                                     "com a informada.".
                             NEXT.
                         END.
                 END.
            ELSE
                 DO:
                     /* se a quantidade de bloquetos nao fechar */
                     IF  (INTEGER(TRUNCATE(tel_nrblqfim / 10,0)) -
                          INTEGER(TRUNCATE(tel_nrblqini / 10,0)) + 1) <>
                         tel_qtbloque   THEN
                         DO:
                             glb_cdcritic = 0.
                             MESSAGE "A quantidade de bloquetos nao confere "
                                     "com a informada.".
                             NEXT.
                         END.
                 END.
            
            IF   glb_cdcritic > 0 THEN
                 DO:
                     NEXT-PROMPT tel_nrblqini WITH FRAME f_numcob.
                     NEXT.
                 END.

            DISPLAY tel_nmprimtl WITH FRAME f_numcob.

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF   aux_confirma <> "S"  THEN
                 DO:
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_numcob.
                     NEXT.
                 END.
                              
            FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper     AND
                                   crapcob.cdbandoc  = tel_cddbanco     AND
                                   crapcob.nrdctabb  = tel_nrdctabb     AND
                                   crapcob.nrcnvcob  = tel_nrcnvcob     AND
                                   crapcob.nrdocmto >= tel_nrblqini     AND
                                   crapcob.nrdocmto <= tel_nrblqfim
                                   EXCLUSIVE-LOCK TRANSACTION:

                ASSIGN crapcob.nrdconta = tel_nrdconta
                       crapcob.dtretcob = glb_dtmvtolt.

            END.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */

