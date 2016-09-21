/* .............................................................................

   Programa: Fontes/cadcob.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair                                Ultima Alteracao: 13/04/2009.
   Data    : Novembro/97

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADCOB.

   Alteracao : 24/09/2004 - Incluir mais duas posicoes do Nro Convenio (Ze).
   
               08/10/2004 - Nao reconhecer o dv para a Concredi (Ze).
               
               18/01/2005 - Nao reconhecer o dv para a Credcrea (Ze).
               
               15/04/2005 - Tratamento para a importacao do cadastramento
                            dos bloquetos (Ze).

               27/06/2005 - Alimentado campo cdcooper da tabela crapcob (Diego).

               05/08/2005 - Incluir F7 para numero convenios (Ze).
               
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               07/01/2006 - Troca da craptab pela crapcco (Julio/Ze).
               
               04/10/2006 - Incluir BO de Inclusao dos Bloquetos (Ze).

               27/12/2006 - Alimentar campos cdimpcob e flgimpre na temp-table
                            cratcob (David).
               19/11/2007 - Efetuada correcao opcao "E" numero boleto(Mirtes)

               29/02/2008 - Incluido tratamento referente cadastro do primeiro 
                            boleto na cooperativa (Diego).
                            
               12/09/2008 - Alterado campo cdbccxlt -> cdbancob (Diego).
               
               13/04/2009 - Tratar origem dos conv. - Proj. Melhorias Cob (Ze).............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cddbanco AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdctabb AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrcnvcob AS INT     FORMAT "zzzzzzz9"             NO-UNDO.
DEF        VAR tel_nrtalini AS INT     FORMAT "zz,zzz,9"             NO-UNDO.
DEF        VAR tel_nrtalfim AS INT     FORMAT "zz,zzz,9"             NO-UNDO.
DEF        VAR aux_nrtalfim AS INT                                   NO-UNDO.
DEF        VAR aux_cdnosnur AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS DECI    FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

DEF TEMP-TABLE crawcnv                                               NO-UNDO
    FIELD cdconven AS INTEGER.

DEF        QUERY  q_numconve FOR crawcnv. 
DEF        BROWSE b_numconve QUERY q_numconve
                  DISP crawcnv.cdconven  COLUMN-LABEL "Convenio"
                       WITH 6 DOWN OVERLAY.    


DEF TEMP-TABLE cratcob  NO-UNDO LIKE crapcob.

/* Handle para a BO */
DEF VAR h-b1crapcob     AS HANDLE                                    NO-UNDO.

DEF BUFFER crabcob FOR crapenc.


FORM b_numconve SKIP 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_num_convenio.

FORM SKIP (3)
     "Opcao:"     AT 30
     glb_cddopcao AT 37 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (C,E ou I)"
                  VALIDATE (glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")
     SKIP (2)
     "Banco   Conta base     Convenio     Numero Inicial  Numero Final" AT 9
     SKIP (2)
     tel_cddbanco AT 11
                  HELP "Entre com o codigo do banco."
     tel_nrdctabb AT 17
                  HELP "Entre com o numero da conta base."
     tel_nrcnvcob AT 32
                  HELP "Entre com o numero do convenio / F7 para listar"
     tel_nrtalini AT 48
                  HELP "Entre com o numero inicial do bloqueto."
                  VALIDATE(tel_nrtalini >= 1 ,"380 - Numero errado.")
     tel_nrtalfim AT 63
                  HELP "Entre com o numero final do bloqueto."
     SKIP (6)
     WITH NO-LABELS TITLE glb_tldatela
     ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_cob.

glb_cdcritic = 0.
glb_cddopcao = "C".

DISPLAY glb_cddopcao WITH FRAME f_cob.
NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao tel_cddbanco tel_nrdctabb tel_nrcnvcob
             WITH FRAME f_cob
             
      EDITING:

         DO WHILE TRUE:
               
                  READKEY PAUSE 1.
               
                  IF   LASTKEY = KEYCODE("F7")       AND
                       FRAME-FIELD = "tel_nrcnvcob"  THEN
                       DO:
                           EMPTY TEMP-TABLE crawcnv.
                           
                           FOR EACH crapcco WHERE 
                                          crapcco.cdcooper = glb_cdcooper AND
                                          crapcco.cddbanco = 1        NO-LOCK.
                              
                               CREATE crawcnv.
                               ASSIGN crawcnv.cdconven = crapcco.nrconven.
                           END.
                           
                           OPEN QUERY q_numconve 
                                      FOR EACH crawcnv.

                           ON RETURN OF b_numconve 
                              DO:
                                  ASSIGN tel_nrcnvcob = crawcnv.cdconven.
                              
                                  DISPLAY tel_nrcnvcob WITH FRAME f_cob.
       
                                  APPLY "GO".
                              END.
                                 
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
               NEXT-PROMPT tel_nrdctabb WITH FRAME f_cob.
               NEXT.
           END.

      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CADCOB"   THEN
                 DO:
                     HIDE FRAME f_cob.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C" THEN
        DO:
            ASSIGN aux_regexist = FALSE.

            FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper      AND
                               crapcco.nrconven  = tel_nrcnvcob      AND
                               crapcco.cddbanco  = tel_cddbanco      AND
                               crapcco.nrdctabb  = tel_nrdctabb  
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE crapcco   THEN
                 DO:
                     glb_cdcritic = 586.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.
                 END.
            
            IF   crapcco.dsorgarq = "INTERNET"               OR
                 crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" THEN
                 DO:
                     glb_cdcritic = 846.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.
                 END.
            ELSE
                 aux_regexist = TRUE.

            ASSIGN tel_nrtalfim = crapcco.nrbloque
                   tel_nrtalini = 0.

            IF   aux_regexist  THEN
                 DISPLAY tel_nrtalini tel_nrtalfim WITH FRAME f_cob.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:

            ASSIGN aux_regexist = FALSE.

            FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper       AND
                               crapcco.nrconven  = tel_nrcnvcob       AND
                               crapcco.cddbanco  = tel_cddbanco       AND
                               crapcco.nrdctabb = tel_nrdctabb  
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcco   THEN
                 DO:
                     glb_cdcritic = 586.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.
                 END.
            
            IF   crapcco.dsorgarq = "INTERNET"               OR
                 crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" THEN
                 DO:
                     glb_cdcritic = 846.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.
                 END.
            ELSE
                 aux_regexist = TRUE.

            ASSIGN aux_nrtalfim = crapcco.nrbloque.

            DO WHILE TRUE:

               IF   glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_nrtalini tel_nrtalfim WITH FRAME f_cob.

               IF   tel_nrtalini > tel_nrtalfim   OR
                    tel_nrtalfim <> aux_nrtalfim  THEN
                    DO:
                        glb_cdcritic = 380.
                        NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                        NEXT.
                    END.

               
               IF   crapcco.tamannro = 12   THEN
                    DO:
                        IF   (INT(SUBSTR(STRING(tel_nrtalfim,"999999"),1,5))  -
                              INT(SUBSTR(STRING(tel_nrtalini,"999999"),1,5))) 
                             > 1000 THEN
                             DO:
                                 glb_cdcritic = 26.
                                 NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                                 NEXT.
                             END.
                        
                        aux_cdnosnur = DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrtalini,"999999")).

                        glb_nrcalcul = aux_cdnosnur.

                        RUN fontes/digfun.p.

                        IF   NOT glb_stsnrcal THEN
                             DO:
                                 glb_cdcritic = 8.
                                 NEXT-PROMPT tel_nrtalini WITH FRAME f_cob.
                                 NEXT.
                             END.
                             
                        aux_cdnosnur = DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrtalfim,"999999")).

                        glb_nrcalcul = aux_cdnosnur.

                        RUN fontes/digfun.p.

                        IF   NOT glb_stsnrcal THEN
                             DO:
                                 glb_cdcritic = 8.
                                 NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                                 NEXT.
                             END.
                    END.
               ELSE
                    DO:
                        IF   (INT(SUBSTR(STRING(tel_nrtalfim,"999999"),1,5))  -
                              INT(SUBSTR(STRING(tel_nrtalini,"999999"),1,5))) 
                             > 500 THEN
                             DO:
                                 glb_cdcritic = 26.
                                 NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                                 NEXT.
                             END.
                    END.
                    
               FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper AND
                                      crapcob.cdbandoc  = tel_cddbanco AND
                                      crapcob.nrdctabb  = tel_nrdctabb AND
                                      crapcob.nrcnvcob  = tel_nrcnvcob AND
                                      crapcob.nrdocmto >= tel_nrtalini AND
                                      crapcob.nrdocmto <= tel_nrtalfim NO-LOCK:
                   IF   crapcob.incobran <> 0 OR crapcob.nrdconta <> 0 OR
                        crapcob.dtretcob <> ? THEN
                        DO:
                            glb_cdcritic = 587.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic   crapcob.nrdocmto.
                            LEAVE.
                        END.
               END. 

               LEAVE.

            END. /* DO WHILE TRUE */

            IF   glb_cdcritic > 0 THEN
                 DO:
                     glb_cdcritic = 0.
                     NEXT.
                 END.

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
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            DO TRANSACTION:

               FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper  AND
                                      crapcob.cdbandoc  = tel_cddbanco  AND
                                      crapcob.nrdctabb  = tel_nrdctabb  AND
                                      crapcob.nrcnvcob  = tel_nrcnvcob  AND
                                      crapcob.nrdocmto >= tel_nrtalini  AND
                                      crapcob.nrdocmto <= tel_nrtalfim
                                      EXCLUSIVE-LOCK:

                   DELETE crapcob.
               END.
               
               IF   crapcco.tamannro = 12   THEN
                    DO:
                        glb_nrcalcul = DECI(STRING(tel_nrcnvcob,"99999999") +
                                       STRING(tel_nrtalini - 10,"999999")).
                                       
                        RUN fontes/digfun.p.
                    END.
               ELSE
                    aux_cdnosnur = tel_nrtalini - 1.

               FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper  AND
                                  crapcco.nrconven  = tel_nrcnvcob  AND
                                  crapcco.cddbanco  = tel_cddbanco  AND
                                  crapcco.nrdctabb = tel_nrdctabb  
                                  EXCLUSIVE-LOCK NO-ERROR.

               IF   AVAILABLE crapcco   THEN
                    DO:
                        IF   crapcco.tamannro = 12   THEN
                             crapcco.nrbloque = INT(SUBSTR(STRING(glb_nrcalcul,
                                                     "9999999999999999"),9,7)).
                        ELSE
                             crapcco.nrbloque = INT(STRING(aux_cdnosnur,
                             "9999999")).
                    END. /* crapcco */

            END. /* TRANSACTION */

        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:

            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.

            ASSIGN aux_regexist = FALSE.

            FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper       AND
                               crapcco.nrconven  = tel_nrcnvcob       AND
                               crapcco.cddbanco  = tel_cddbanco       AND
                               crapcco.nrdctabb = tel_nrdctabb  
                               NO-LOCK NO-ERROR.

            IF   NOT  AVAILABLE crapcco   THEN
                 DO:
                     glb_cdcritic = 586.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.               
                 END.
                
            IF   crapcco.dsorgarq = "INTERNET"               OR
                 crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE" THEN
                 DO:
                     glb_cdcritic = 846.
                     NEXT-PROMPT tel_cddbanco WITH FRAME f_cob.
                     NEXT.
                 END.
            ELSE
                 aux_regexist = TRUE.

            ASSIGN aux_nrtalfim = crapcco.nrbloque.

            DO WHILE TRUE:

               IF   glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_nrtalini tel_nrtalfim WITH FRAME f_cob.

               IF   tel_nrtalini > tel_nrtalfim THEN
                    DO:
                        glb_cdcritic = 380.
                        NEXT-PROMPT tel_nrtalini WITH FRAME f_cob.
                        NEXT.
                    END.

               IF   crapcco.tamannro = 12   THEN
                    DO:
                        aux_cdnosnur = DEC(STRING(tel_nrcnvcob,"99999999") + 
                                           STRING(tel_nrtalini,"999999")).
                                           
                        glb_nrcalcul = aux_cdnosnur.

                        RUN fontes/digfun.p.

                        IF   NOT glb_stsnrcal THEN
                             DO:
                                 glb_cdcritic = 8.
                                 NEXT-PROMPT tel_nrtalini WITH FRAME f_cob.
                                 NEXT.
                             END.

                        aux_cdnosnur = DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrtalfim,"999999")).
 
                        glb_nrcalcul = aux_cdnosnur.
      
                        RUN fontes/digfun.p.

                        IF   NOT glb_stsnrcal THEN
                             DO:
                                 glb_cdcritic = 8.
                                 NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                                 NEXT.
                             END.
                    
                        IF   (INT(SUBSTR(STRING(tel_nrtalfim,"999999"),1,5))  -
                              INT(SUBSTR(STRING(tel_nrtalini,"999999"),1,5)))
                             > 1000 THEN
                             DO:
                                 glb_cdcritic = 26.
                                 NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                                 NEXT.
                             END.

                        IF   INT(SUBSTR(STRING(tel_nrtalini,"999999"),1,5))  -
                             INT(SUBSTR(STRING(aux_nrtalfim,"999999"),1,5)) 
                             <> 1 THEN
                             DO:
                                 glb_cdcritic = 380.
                                 NEXT-PROMPT tel_nrtalini WITH FRAME f_cob.
                                 NEXT.
                             END.
                    END.
               ELSE
                    DO:
                        IF   (INT(SUBSTR(STRING(tel_nrtalfim,"999999"),1,5))  -
                              INT(SUBSTR(STRING(tel_nrtalini,"999999"),1,5))) 
                             > 500 THEN
                             DO:
                                 glb_cdcritic = 26.
                                 NEXT-PROMPT tel_nrtalfim WITH FRAME f_cob.
                                 NEXT.
                             END.
                        
                        IF   (INT(STRING(tel_nrtalini,"999999"))  -
                              INT(STRING(aux_nrtalfim,"999999")) <> 1) AND
                              aux_nrtalfim <> 0  THEN
                             DO:
                                 glb_cdcritic = 380.
                                 NEXT-PROMPT tel_nrtalini WITH FRAME f_cob.
                                 NEXT.
                             END.
                      
                        IF   aux_nrtalfim = 0 AND
                             INT(STRING(tel_nrtalini,"999999")) <> 1  THEN
                             DO:
                                 glb_cdcritic = 380.
                                 NEXT-PROMPT tel_nrtalini WITH FRAME f_cob.
                                 NEXT.
                             END.
                    
                    END.
                    
               FOR EACH crapcob WHERE crapcob.cdcooper  = glb_cdcooper AND
                                      crapcob.cdbandoc  = tel_cddbanco AND
                                      crapcob.nrdctabb  = tel_nrdctabb AND
                                      crapcob.nrcnvcob  = tel_nrcnvcob AND
                                      crapcob.nrdocmto >= tel_nrtalini AND
                                      crapcob.nrdocmto <= tel_nrtalfim NO-LOCK:

                   IF   crapcob.incobran <> 0 OR crapcob.nrdconta <> 0 OR
                        crapcob.dtretcob <> ? THEN
                        DO:
                            glb_cdcritic = 588.
                            LEAVE.
                        END.
               END.
               
               IF   glb_cdcritic <> 0 THEN
                    NEXT.
               
               LEAVE.

            END. /* DO WHILE TRUE */

            IF   crapcco.tamannro = 12  THEN
                 DO TRANSACTION:

                     DO aux_contador = DECI(STRING(tel_nrcnvcob,"99999999") +
                                   SUBSTR(STRING(tel_nrtalini,"999999"),1,5)) 
                                   TO   DECI(STRING(tel_nrcnvcob,"99999999") +
                                   SUBSTR(STRING(tel_nrtalfim,"999999"),1,5)).

                         glb_nrcalcul = aux_contador * 10.
                         RUN fontes/digfun.p.

                         EMPTY TEMP-TABLE cratcob.
                         
                         CREATE cratcob.
                         ASSIGN cratcob.dtmvtolt = glb_dtmvtolt
                                cratcob.incobran = 0
                                cratcob.nrdconta = 0
                                cratcob.nrdctabb = tel_nrdctabb
                                cratcob.cdbandoc = tel_cddbanco
                                cratcob.nrdocmto = 
                                        INT(SUBSTR(STRING(glb_nrcalcul,
                                                  "99999999999999"),9,6))
                                cratcob.nrcnvcob = tel_nrcnvcob
                                cratcob.dtretcob = ?
                                cratcob.cdcooper = glb_cdcooper
                                cratcob.cdimpcob = 1
                                cratcob.flgimpre = TRUE.
                                
                         /* Instancia a BO para executar as procedures */
                         RUN sistema/generico/procedures/b1crapcob.p
                             PERSISTENT SET h-b1crapcob.
                             
                         /* Se BO foi instanciada */
                         IF   VALID-HANDLE(h-b1crapcob)   THEN
                              DO:
                                  RUN inclui-registro IN h-b1crapcob
                                      (INPUT TABLE cratcob, 
                                       OUTPUT glb_dscritic).

                                  /* Mata a instancia da BO */
                                  DELETE PROCEDURE h-b1crapcob.
                              END.
                         
                         IF   glb_dscritic <> ""   THEN
                              DO:
                                  MESSAGE glb_dscritic.
                                  glb_dscritic = "".
                                  UNDO, NEXT.
                              END.
                     END.

                     FIND crapcco WHERE crapcco.cdcooper = glb_cdcooper AND
                                        crapcco.nrconven = tel_nrcnvcob AND
                                        crapcco.cddbanco = tel_cddbanco AND
                                        crapcco.nrdctabb = tel_nrdctabb  
                                        EXCLUSIVE-LOCK NO-ERROR.

                     IF   AVAILABLE crapcco  THEN
                          ASSIGN crapcco.nrbloque = tel_nrtalfim. 

                 END. /* TRANSACTION */
            ELSE                        /* TRATAMENTO ESPECIAL PARA CONCREDI */
                 DO TRANSACTION:

                     DO aux_contador = DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrtalini,"999999"))
                                   TO  DECI(STRING(tel_nrcnvcob,"99999999") +
                                            STRING(tel_nrtalfim,"999999")):

                         EMPTY TEMP-TABLE cratcob.
                         
                         CREATE cratcob.
                         ASSIGN cratcob.dtmvtolt = glb_dtmvtolt
                                cratcob.incobran = 0
                                cratcob.nrdconta = 0
                                cratcob.nrdctabb = tel_nrdctabb
                                cratcob.cdbandoc = tel_cddbanco
                                cratcob.nrdocmto = 
                                        INT(SUBSTR(STRING(aux_contador,
                                                  "99999999999999"),9,6))
                                cratcob.nrcnvcob = tel_nrcnvcob
                                cratcob.dtretcob = ?
                                cratcob.cdcooper = glb_cdcooper
                                cratcob.cdimpcob = 1
                                cratcob.flgimpre = TRUE.
                                
                         /* Instancia a BO para executar as procedures */
                         RUN sistema/generico/procedures/b1crapcob.p
                             PERSISTENT SET h-b1crapcob.
                             
                         /* Se BO foi instanciada */
                         IF   VALID-HANDLE(h-b1crapcob)   THEN
                              DO:
                                  RUN inclui-registro IN h-b1crapcob
                                      (INPUT TABLE cratcob, 
                                       OUTPUT glb_dscritic).

                                  /* Mata a instancia da BO */
                                  DELETE PROCEDURE h-b1crapcob.
                              END.
                         
                         IF   glb_dscritic <> ""   THEN
                              DO:
                                  MESSAGE glb_dscritic.
                                  glb_dscritic = "".
                                  UNDO, NEXT.
                              END.       
                     END.

                     FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper AND
                                        crapcco.nrconven  = tel_nrcnvcob AND
                                        crapcco.cddbanco  = tel_cddbanco AND
                                        crapcco.nrdctabb = tel_nrdctabb  
                                        EXCLUSIVE-LOCK NO-ERROR.

                     IF   AVAILABLE crapcco   THEN
                          ASSIGN crapcco.nrbloque = tel_nrtalfim.

                 END. /* TRANSACTION */

        END.
END

/* .......................................................................... */
