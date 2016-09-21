/* .............................................................................

   Programa: Fontes/sol077.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/2000

   Dados referentes ao programa:                 Ultima Alteracao : 17/01/2014

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL077.

   Alteracoes: 05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cdsecext AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nmresage AS CHAR                                  NO-UNDO.
DEF        VAR tel_cdagenci AS INTEGER FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dssecext AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_tpseletq AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_tpetique AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_poevirgu AS CHAR                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGI                                  NO-UNDO.
DEF        VAR aux_flgtodas AS LOGI                                  NO-UNDO.

DEF        VAR tel_lssecext AS CHAR                                  NO-UNDO.


FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (2)
     glb_cddopcao AT  25 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (C,E ou I)"
                        VALIDATE (glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")
     SKIP (1)
     tel_cdagenci AT 27 LABEL "PA"
        HELP "Entre com o PA especifico."
        VALIDATE (CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper AND 
                                         crapage.cdagenci = tel_cdagenci),
                          "962 - PA nao cadastrado.")
     tel_nmresage NO-LABELS FORMAT "x(35)"
     SKIP(1) 
     tel_tpetique AT 14 LABEL "Tipo de etiqueta"
        HELP "Entre com o tipo de etiq. 1-para correio, 2-dest. de extrato"
        VALIDATE (CAN-DO("1,2",STRING(tel_tpetique)),
                     "513 - Tipo errado.")
     SKIP(1)
     tel_tpseletq AT 15 LABEL "Tipo de selecao"
         HELP "Entre com o tipo de selecao 1-p/secao, 2-geral."
         VALIDATE (CAN-DO("1,2",STRING(tel_tpseletq)),
                     "513 - Tipo errado.")
     SKIP(1)
     tel_cdsecext AT 25 LABEL "Secao"
                        HELP "Entre com a secao de extrato."
                        VALIDATE(tel_cdsecext <> 0,
                          "019 - Secao para extrato nao cadastrada.")
         
                        AUTO-RETURN
                        
     tel_dssecext NO-LABELS FORMAT "x(35)"
     SKIP (1)
     tel_lssecext AT 12 LABEL "Secoes cadastradas"  FORMAT "x(40)"
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol077.

VIEW FRAME f_moldura.

glb_cddopcao = "I".
glb_cdcritic = 0.

PAUSE(0).

RUN fontes/inicia.p.

DO WHILE TRUE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
         END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao  WITH FRAME f_sol077.
      LEAVE.

   END.

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao =  glb_cddopcao.
        END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "sol077"   THEN
                 DO:
                     HIDE FRAME f_sol077.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   CAN-DO("C",glb_cddopcao) THEN
        DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_cdagenci tel_tpetique WITH FRAME f_sol077.
                
                RUN proc_trata_pac.

                LEAVE.
             END.   
        END.
   ELSE
        DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_cdagenci tel_tpetique tel_tpseletq 
                       WITH FRAME f_sol077.
                
                RUN proc_trata_pac.

                LEAVE.
             END. 
               
             ASSIGN tel_lssecext = ""
                    tel_dssecext = ""
                    tel_cdsecext = 0.
             
             DISPLAY tel_lssecext tel_dssecext WITH FRAME f_sol077.

             IF   tel_tpseletq = 1 THEN
                  DO:
                      DO WHILE TRUE:
                               
                         UPDATE tel_cdsecext WITH FRAME f_sol077.
                              
                         FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper AND
                                            crapdes.cdagenci = tel_cdagenci AND
                                            crapdes.cdsecext = tel_cdsecext 
                                            USE-INDEX crapdes1 NO-LOCK NO-ERROR.

                         IF   NOT AVAILABLE crapdes   THEN
                              DO:
                                  glb_cdcritic = 19.
                                  NEXT-PROMPT tel_cdsecext WITH FRAME f_sol077.
                                  CLEAR FRAME f_sol077.
                                  NEXT.
                              END.
                                
                         tel_dssecext = crapdes.nmsecext.
                                  
                         DISPLAY tel_dssecext WITH FRAME f_sol077.         
                                  
                         LEAVE.
                      END.
                  END.    
             ELSE 
                  DO:
                      ASSIGN tel_cdsecext = 0 
                             tel_dssecext = "TODAS".
                    
                      DISPLAY "  " @ tel_cdsecext   tel_dssecext 
                              WITH FRAME f_sol077.
                  END.            
        END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        NEXT.

   IF   glb_cddopcao = "C" THEN
        DO:

            ASSIGN aux_poevirgu = ""
                   aux_regexist = FALSE
                   tel_lssecext = ""
                   tel_tpseletq = 0.
            
            FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                   crapsol.nrsolici = 77             AND
                                   crapsol.dtrefere = glb_dtmvtolt   AND
                                   crapsol.nrdevias = tel_tpetique   AND
                                   crapsol.cdempres = tel_cdagenci   NO-LOCK:
                
                IF   INT(crapsol.dsparame) = 0 THEN
                         tel_lssecext = "Todas".
                ELSE     
                     ASSIGN tel_lssecext = tel_lssecext + TRIM(aux_poevirgu) + 
                                           TRIM(crapsol.dsparame)
                            aux_poevirgu = ",".
                            
                aux_regexist = TRUE.
            
            END.            

            DISPLAY  " " @ tel_tpseletq 
                     " " @ tel_cdsecext 
                     " " @ tel_dssecext 
                     tel_lssecext 
                    WITH FRAME f_sol077.

            IF   NOT aux_regexist THEN
                 DO:
                     glb_cdcritic = 115.
                     NEXT-PROMPT tel_cdsecext WITH FRAME f_sol077.
                     NEXT.
                 END.
        END.
   ELSE
        IF   glb_cddopcao = "E"   THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND FIRST crapsol WHERE 
                                   crapsol.cdcooper = glb_cdcooper  AND
                                   crapsol.nrsolici = 77            AND
                                   crapsol.dtrefere = glb_dtmvtolt  AND
                                   crapsol.cdempres = tel_cdagenci  AND
                                   crapsol.nrdevias = tel_tpetique  AND
                           INTEGER(crapsol.dsparame) = tel_cdsecext
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
                                      LEAVE.
                                  END.
                        ELSE
                             DO:
                                 aux_contador = 0.
                                 LEAVE.
                             END.
                    END.

                    IF   glb_cdcritic > 0 THEN
                         NEXT.

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
                             NEXT.
                         END.

                    DELETE crapsol.
                    CLEAR FRAME f_sol077 NO-PAUSE.

                 END. /* Fim da transacao */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.
             END.
        ELSE
             IF   glb_cddopcao = "I"   THEN
                  DO:
                      tel_lssecext = "".
                      
                      DISPLAY tel_lssecext WITH FRAME f_sol077.
                      
                      FIND LAST crapsol WHERE
                                crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 77             AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapsol THEN
                           aux_nrseqsol = 1.
                      ELSE
                           aux_nrseqsol = crapsol.nrseqsol + 1.

                      IF   tel_cdsecext = 0 THEN
                           DO:

                               FIND FIRST crapsol WHERE
                                          crapsol.cdcooper = glb_cdcooper   AND
                                          crapsol.nrsolici = 77             AND
                                          crapsol.dtrefere = glb_dtmvtolt   AND
                                          crapsol.cdempres = tel_cdagenci   AND
                                          crapsol.nrdevias = tel_tpetique 
                                          USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                               IF   AVAILABLE crapsol   THEN
                                    DO:
                                        ASSIGN glb_cdcritic = 682.
                                        NEXT.
                                    END.
                           END.
                      ELSE     
                           DO:
                               FIND FIRST crapsol WHERE
                                          crapsol.cdcooper = glb_cdcooper   AND
                                          crapsol.nrsolici = 77             AND
                                          crapsol.dtrefere = glb_dtmvtolt   AND
                                          crapsol.cdempres = tel_cdagenci   AND
                                          crapsol.nrdevias = tel_tpetique   AND
                                  INTEGER(crapsol.dsparame) = 0          
                                          USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                               IF   AVAILABLE crapsol   THEN
                                    DO:
                                        ASSIGN glb_cdcritic = 683.
                                        NEXT-PROMPT tel_cdsecext 
                                                    WITH FRAME f_sol077.
                                        NEXT.
                                    END.
                           END.

                      FIND FIRST crapsol WHERE
                                 crapsol.cdcooper = glb_cdcooper   AND 
                                 crapsol.nrsolici = 77             AND
                                 crapsol.dtrefere = glb_dtmvtolt   AND
                                 crapsol.cdempres = tel_cdagenci   AND
                                 crapsol.nrdevias = tel_tpetique   AND
                         INTEGER(crapsol.dsparame) = tel_cdsecext
                                 USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                      IF   AVAILABLE crapsol   THEN
                           DO:
                               ASSIGN glb_cdcritic = 118.
                               NEXT-PROMPT tel_cdsecext WITH FRAME f_sol077.
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
                               NEXT.
                           END.

                      DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                         CREATE crapsol.
                         ASSIGN crapsol.nrsolici = 77
                                crapsol.dtrefere = glb_dtmvtolt
                                crapsol.nrseqsol = aux_nrseqsol
                                crapsol.dsparame = TRIM(STRING(tel_cdsecext))
                                crapsol.cdempres = tel_cdagenci
                                crapsol.nrdevias = tel_tpetique
                                crapsol.insitsol = 1
                                crapsol.cdcooper = glb_cdcooper.

                      END. /* Fim da transacao */

                      RELEASE crapsol.

                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                           NEXT.
                  END.
END.

/* ......................................................................... */

PROCEDURE proc_trata_pac:
   
   FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND 
                      crapage.cdagenci = tel_cdagenci   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapage   THEN
        DO:
            glb_cdcritic = 15.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT-PROMPT tel_cdagenci WITH FRAME f_sol077.
            CLEAR FRAME f_sol077.
        END.

   tel_nmresage = crapage.nmresage.
        
   DISPLAY tel_nmresage WITH FRAME f_sol077.
   
END PROCEDURE.   
 
