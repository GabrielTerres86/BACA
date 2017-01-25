/* .............................................................................

   Programa: Fontes/formge.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Outubro/2012.                     Ultima alteracao: 01/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Geração do Grupo Economico.

   Alteracoes: 22/10/2012 - Ajustes referente ao projeot GE (Adriano).
   
               22/03/2013 - Ajuste para alimentar a aux_persocio com as posicoes
                            "91,6" ao inves de "28,6" (Adriano).
                            
               28/03/2013 - Incluido a passagem do parametro cdprogra na 
                            chamada da procedure forma_grupo_economico
                            (Adriano).
                                                     
               01/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom) 
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/var_internet.i }

DEF    VAR aux_confirma  AS CHAR     FORMAT "!"                       NO-UNDO.
DEF    VAR aux_dstextab  AS CHAR                                      NO-UNDO.
DEF    VAR aux_persocio  AS DECI                                      NO-UNDO.
DEF    VAR aux_cddopcao  AS CHAR                                      NO-UNDO.
DEF    VAR aux_contador  AS INTE                                      NO-UNDO.
DEF    VAR aux_flgok     AS LOGI                                      NO-UNDO.

DEF    VAR h-b1wgen0138  AS HANDLE                                    NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM  SKIP(1)
      glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN
                         HELP "Entre com a opcao desejada (C ou G)"
                         VALIDATE(CAN-DO("C,G",glb_cddopcao),
                                  "014 - Opcao errada.")
      SKIP(4)
      WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_formge.

FORM  SKIP(1)
    aux_persocio LABEL "Percentual Societario Exigido"
    WITH ROW 5 COLUMN 20 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_persocio.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
VIEW FRAME f_moldura. 
PAUSE(0).
VIEW FRAME f_persocio.
PAUSE(0).

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_cdprogra = "FORMGE".


lab:
DO WHILE TRUE:
    
 
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
       UPDATE glb_cddopcao 
              WITH FRAME f_formge.

       LEAVE.
   
   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.
          IF CAPS(glb_nmdatela) <> "FORMGE"   THEN
             DO:
                 HIDE FRAME f_formge.
                 HIDE FRAME f_moldura.
                 HIDE FRAME f_persocio.
                 RETURN.
             END.
          ELSE
             NEXT.

      END.
   
   IF glb_cddopcao = "G" THEN
      DO:
          IF glb_cddepart <> 20  AND  /* TI        */
             glb_cddepart <> 14  THEN /* PRODUTOS  */
             DO:
                ASSIGN glb_cdcritic = 36.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.

                BELL.
                MESSAGE glb_dscritic.
                NEXT.
              
             END.

      END.

   IF glb_cddopcao = "C"   THEN
      DO:
          FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "GENERI"     AND
                             craptab.cdempres = 00           AND
                             craptab.cdacesso = "PROVISAOCL" AND
                             craptab.tpregist = 999          
                             NO-LOCK NO-ERROR NO-WAIT.
          
          ASSIGN aux_persocio = DEC(SUBSTRING(craptab.dstextab,91,6)). 

          DISPLAY aux_persocio 
                  WITH FRAME f_persocio.

          NEXT.
   
      END.
   ELSE
      DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                            craptab.nmsistem = "CRED"       AND
                            craptab.tptabela = "GENERI"     AND
                            craptab.cdempres = 00           AND
                            craptab.cdacesso = "PROVISAOCL" AND
                            craptab.tpregist = 999          
                            NO-LOCK NO-ERROR NO-WAIT.
        
         ASSIGN aux_persocio = DEC(SUBSTRING(craptab.dstextab,91,6)). 

         DISPLAY aux_persocio 
                 WITH FRAME f_persocio.
         
         ASSIGN aux_confirma = "N".

         RUN fontes/confirma.p (INPUT  "",
                                OUTPUT aux_confirma).
             
         IF aux_confirma = "N" THEN 
            NEXT lab.
         
         ASSIGN glb_dscritic = ""
                glb_cdcritic = 0.
         
         CONTROLE:
             DO TRANSACTION ON ENDKEY UNDO CONTROLE, LEAVE CONTROLE
                            ON ERROR  UNDO CONTROLE, LEAVE CONTROLE:
         
             Contador_Controle:
                DO aux_contador = 1 TO 10:
         
                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                      craptab.nmsistem = "CRED"       AND
                                      craptab.tptabela = "USUARI"     AND       
                                      craptab.cdempres = 00           AND        
                                      craptab.cdacesso = "CTRGRPECON" AND
                                      craptab.tpregist = 99           
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                   IF NOT AVAIL craptab THEN
                      DO:
                         IF LOCKED craptab THEN
                            DO:
                                IF aux_contador = 10 THEN
                                   DO:   
                                       ASSIGN glb_cdcritic = 341.

                                       UNDO CONTROLE, LEAVE CONTROLE.

                                   END.

                                NEXT Contador_Controle.

                            END.
                         ELSE
                            DO:
                                ASSIGN glb_cdcritic = 55.
                                UNDO CONTROLE, LEAVE CONTROLE.

                            END.

                      END.
                   ELSE
                      DO:
                         ASSIGN glb_cdcritic = 0.
         
                         IF craptab.dstextab <> "" THEN
                            DO:
                                HIDE MESSAGE NO-PAUSE.
                                ASSIGN glb_dscritic = "Grupo Econômico "    + 
                                                      "sendo refeito pelo " + 
                                                      "operador "           +
                                                      craptab.dstextab      + 
                                                      ". Aguarde.".
                                BELL.
                                MESSAGE glb_dscritic. 
                                PAUSE(2) NO-MESSAGE.
                                HIDE MESSAGE NO-PAUSE.
                                UNDO CONTROLE, LEAVE CONTROLE.

                            END.
                   
                         /* Grava o codigo do operador da Tabela de Controle */
                         ASSIGN craptab.dstextab = SUBSTR(glb_nmoperad,1,15)
                                aux_flgok = TRUE.
         
                         LEAVE Contador_Controle.

                      END. 
         
                END. /* Fim do DO ... TO */
         
                IF glb_cdcritic > 0   OR 
                   glb_dscritic <> "" THEN
                   DO:
                       BELL.
                       RUN fontes/critic.p.
                       MESSAGE glb_dscritic. 
                       PAUSE(2) NO-MESSAGE.
                       HIDE MESSAGE NO-PAUSE.
                       ASSIGN glb_cdcritic = 0.
                       UNDO CONTROLE, NEXT lab.

                   END.
         
                IF NOT aux_flgok THEN
                   UNDO CONTROLE, NEXT lab.
         
             END. /* Transaction CONTROLE */
         
         FIND CURRENT craptab.
         RELEASE craptab.
         
         IF aux_flgok THEN
            DO:
                MESSAGE "Aguarde...".

                IF NOT VALID-HANDLE(h-b1wgen0138) THEN    
                   RUN sistema/generico/procedures/b1wgen0138.p 
                       PERSISTENT SET h-b1wgen0138.
                 
         
                RUN forma_grupo_economico IN h-b1wgen0138(INPUT glb_cdcooper,
                                                          INPUT glb_cdagenci,
                                                          INPUT 0,
                                                          INPUT glb_cdoperad,
                                                          INPUT glb_dtmvtolt,
                                                          INPUT glb_nmdatela,
                                                          INPUT glb_cdprogra,
                                                          INPUT 1,
                                                          INPUT aux_persocio,
                                                          INPUT TRUE,
                                                          OUTPUT TABLE tt-grupo,
                                                          OUTPUT TABLE tt-erro).

                IF VALID-HANDLE(h-b1wgen0138) THEN
                   DELETE OBJECT h-b1wgen0138.
            
                IF RETURN-VALUE <> "OK"  THEN
                   DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF AVAIL tt-erro  THEN
                          DO: 
                              HIDE MESSAGE NO-PAUSE.
                              BELL.
                              MESSAGE tt-erro.dscritic.
                              PAUSE(2) NO-MESSAGE.
                              HIDE MESSAGE NO-PAUSE.

                          END.
                       ELSE
                          DO:   
                             HIDE MESSAGE NO-PAUSE.
                             BELL.
                             MESSAGE "Nao foi possivel gerar os grupos.".
                             PAUSE(2) NO-MESSAGE.
                             HIDE MESSAGE NO-PAUSE.

                          END.

                       NEXT lab.
         
                   END.
         
                HIDE MESSAGE NO-PAUSE.
         
                /* Limpa registro do Operador da craptab */
                LIMPA:
                    DO TRANSACTION ON ENDKEY UNDO LIMPA, LEAVE LIMPA
                                   ON ERROR  UNDO LIMPA, LEAVE LIMPA:
                    
                    Contador_Limpa:
                       DO aux_contador = 1 TO 10:
                    
                          FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                             craptab.nmsistem = "CRED"       AND
                                             craptab.tptabela = "USUARI"     AND       
                                             craptab.cdempres = 00           AND        
                                             craptab.cdacesso = "CTRGRPECON" AND
                                             craptab.tpregist = 99        
                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
                          IF NOT AVAIL craptab THEN
                             DO:
                                IF LOCKED craptab THEN
                                   DO:
                                      IF aux_contador = 10 THEN
                                         DO: 
                                             ASSIGN glb_cdcritic = 341.

                                             UNDO LIMPA, LEAVE LIMPA.

                                         END.

                                      NEXT Contador_Limpa.

                                   END.
                                ELSE
                                   DO:
                                      ASSIGN glb_cdcritic = 55.
                                      UNDO LIMPA, LEAVE LIMPA.

                                   END.

                             END.
                          ELSE
                             DO:
                                ASSIGN glb_cdcritic = 0.
         
                                /* Remove o nome do operador */
                                ASSIGN craptab.dstextab = "".
                    
                                LEAVE Contador_Limpa.

                             END. 
                    
                       END. /* Fim do DO ... TO */
                    
                       IF glb_cdcritic > 0   OR 
                          glb_dscritic <> "" THEN
                          DO:
                              BELL.
                              RUN fontes/critic.p.
                              MESSAGE glb_dscritic. 
                              PAUSE(2) NO-MESSAGE .
                              HIDE MESSAGE NO-PAUSE.
                              ASSIGN glb_cdcritic = 0.
                              UNDO LIMPA, NEXT lab.

                          END.

                          /* Gera log */
                          UNIX SILENT VALUE("echo "                           +
                                            STRING(glb_dtmvtolt,"99/99/9999") +
                                            " " + STRING(TIME,"HH:MM:SS")     +
                                            "' --> '" + "Operador "           +
                                            glb_cdoperad + "gerou Grupo "     +
                                            "Economico com Percentual "       +
                                            "Societario de "                  +
                                            STRING(aux_persocio, "z99.99")    +
                                            "%. "  + " >> log/formge.log").
                          
                          MESSAGE "Grupo Economico gerado com sucesso!".
                          NEXT lab.
                    
                    END. /* Transaction LIMPA */
                
            END.

      END.

   LEAVE.

END.
