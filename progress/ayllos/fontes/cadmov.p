/*..............................................................................
   
   Programa: Fontes/cadmov.p
   Sistema : Conta-Corrente - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Adriano
   Data    : Fevereiro/2011.                    Ultima Atualizacao: 30/11/2016
            
   Dados referentes ao programa:

   Frequencia: Diario 
   Objetivo  : Mostra a tela CADMOV.
               Tela para cadastramento dos movimentos descritos no extrato
               do INSS.
               
   Alteracoes: 31/01/2013 - Liberar departamento COMPE (Diego).
   
               29/11/2013 - Inclusao de VALIDATE crapmei (Carlos)

               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
.............................................................................*/

{ includes/var_online.i }

DEF   VAR tel_cdmovext AS INT FORMAT "zzz9"                    NO-UNDO.
DEF   VAR tel_dsmovext AS CHAR FORMAT  "x(35)"                 NO-UNDO.
DEF   VAR tel_tpmovext AS CHAR FORMAT "!"                      NO-UNDO.


DEF   VAR aux_cdmovext LIKE crapmei.cdmovext                   NO-UNDO.
DEF   VAR aux_dsmovext LIKE crapmei.dsmovext                   NO-UNDO.
DEF   VAR aux_tpmovext LIKE crapmei.tpmovext                   NO-UNDO.

DEF   VAR aux_confirma AS CHAR FORMAT "!" INIT "N"             NO-UNDO.
DEF   VAR aux_ultlinha AS INT                                  NO-UNDO.
DEF   VAR aux_contador AS INT                                  NO-UNDO.


DEF   BUFFER b-crapmei1 FOR crapmei.
DEF   BUFFER b-crapmei2 FOR crapmei.

FORM SKIP(1)
     glb_cddopcao COLON 10 LABEL "Opcao"   AUTO-RETURN
                  HELP "Informe a opcao desejada (A-Alt/C-Cons/E-Excl/I-Incl)."
     VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao), "014 - Opcao errada.")
     SKIP(14)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_opcao.


FORM SKIP(1)
    tel_cdmovext LABEL "Codigo" AUTO-RETURN
                  HELP "Informe o código do movimento." 
    tel_tpmovext LABEL "Tipo" AUTO-RETURN AT 25
                  HELP "Informe (D) Debito ou (C) Crédito."
    VALIDATE(CAN-DO("D,C",tel_tpmovext), "513 - Tipo errado.")
    SKIP(1)
    tel_dsmovext LABEL "Descricao" AUTO-RETURN
                  HELP "Informe a descrição do código."
    VALIDATE(INPUT tel_dsmovext <> " ", "375 - O campo deve ser preenchido.")
    WITH NO-BOX ROW 5 COLUMN 20 OVERLAY SIDE-LABELS FRAME f_cadmov.    

DEF QUERY q_consulta   FOR crapmei.

DEF BROWSE b_consulta QUERY q_consulta
    DISPLAY crapmei.cdmovext   COLUMN-LABEL "Codigo"
            crapmei.tpmovext   COLUMN-LABEL "Tipo" FORMAT "x(1)"
            crapmei.dsmovext   COLUMN-LABEL "Descricao"   FORMAT "x(35)"
            WITH 8 DOWN NO-BOX WIDTH 52.

FORM b_consulta
     WITH ROW 8 CENTERED OVERLAY SIDE-LABELS NO-LABELS WIDTH 54
          TITLE " Movimentos INSS " FRAME f_browse.


ON LEAVE OF b_consulta IN FRAME f_browse DO:

    IF  NOT AVAILABLE crapmei   THEN  
        RETURN.

END.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_dscritic = "".
       


DO   WHILE TRUE:
     
     RUN fontes/inicia.p.
     
     CLEAR FRAME f_cadmov.
    
     ASSIGN tel_cdmovext = 0
            tel_dsmovext = ""
            tel_tpmovext = "".
   
     DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
          IF   glb_cdcritic > 0 THEN
               DO:
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   ASSIGN glb_cdcritic = 0.            
              
               END.
          
          UPDATE glb_cddopcao 
                 WITH FRAME f_opcao.
            
          IF   glb_cddopcao <> "C" THEN
               IF   glb_cddepart <> 20 AND  /* TI       */
                    glb_cddepart <> 14 AND  /* PRODUTOS */
                    glb_cddepart <> 4  THEN /* COMPE    */
                    DO:
                        BELL.
                        MESSAGE "Sistema liberado somente para Consulta!".
                        NEXT.
              
                    END.
                
          LEAVE.
    
     END.

    
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
          DO:
              RUN fontes/novatela.p.
                               
              IF   CAPS(glb_nmdatela) <> "CADMOV" THEN
                   DO:
                       HIDE FRAME f_opcao.
                       HIDE FRAME f_cadmov.
                       RETURN.
                   END.
              ELSE
                 NEXT.

          END.
    
     IF   glb_cddopcao = "I" THEN
          DO:
             aux_confirma = "N".

             VIEW FRAME f_cadmov.
             

             UPDATE tel_cdmovext 
                    tel_tpmovext
                    tel_dsmovext
                    WITH FRAME f_cadmov.
        
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                  NEXT.
             
             DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  MESSAGE "Confirma a operação?"
                  UPDATE aux_confirma.
                  LEAVE.
             END.
                    
             IF  aux_confirma = "S" THEN
                 DO:
                   DO TRANSACTION:
                 
                      FIND crapmei WHERE crapmei.cdmovext = tel_cdmovext 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                      IF   NOT AVAILABLE crapmei   THEN
                           DO:
                             IF   LOCKED crapmei   THEN
                                   DO:
                                       PAUSE 2 NO-MESSAGE.
                                       NEXT.
                                   END.
                              ELSE
                                 DO: 
                                    CREATE crapmei.
                                           
                                    ASSIGN crapmei.cdmovext = tel_cdmovext
                                           crapmei.dsmovext = tel_dsmovext
                                           crapmei.tpmovext = tel_tpmovext
                                           crapmei.dtmvtolt = glb_dtmvtolt
                                           crapmei.cdoperad = glb_cdoperad.

                                    VALIDATE crapmei.

                                    RUN gera_log (INPUT glb_cddopcao,
                                                  INPUT 0,
                                                  INPUT "",
                                                  INPUT "",
                                                  INPUT 0,
                                                  INPUT "",
                                                  INPUT "").
                                                          

                                 END.


                           END.
                      ELSE
                         glb_cdcritic = 873.

                      
                   END.
                  
                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            RETURN.
                        END.  
                  
                      
                 END.

             ELSE
                DO:
                   HIDE FRAME f_cadmov.
                   tel_cdmovext = 0.
                   tel_tpmovext = "".
                   tel_dsmovext = "".
                   
                END.
                
        
          END. /* Fim da opcao I */
     ELSE 
        IF   glb_cddopcao = "C" THEN
             DO:
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:            
                    OPEN QUERY q_consulta FOR EACH crapmei BY crapmei.cdmovext.
                    
                    UPDATE b_consulta WITH FRAME f_browse.
                    CLOSE QUERY q_consulta.
                    LEAVE.
                   
                END.

                CLOSE QUERY q_consulta.
                CLEAR FRAME f_browser.
                CLEAR FRAME f_cadmov.
                HIDE  FRAME f_browse.
          
    
             END. /* Fim da opcao C */
      ELSE
          IF   glb_cddopcao = "E" THEN
               DO:
                  aux_confirma = "N".
              
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     UPDATE tel_cdmovext 
                            tel_tpmovext
                            WITH FRAME f_cadmov.

                     FIND crapmei WHERE crapmei.cdmovext = tel_cdmovext AND
                                        crapmei.tpmovext = tel_tpmovext
                                        NO-LOCK NO-ERROR.
                    
                     IF  NOT AVAIL crapmei THEN
                         DO:
                            MESSAGE glb_dscritic "Registro nao encontrado".
                            NEXT.
                        
                         END.
                
                     tel_dsmovext = crapmei.dsmovext.
                      
                     DISP tel_dsmovext WITH FRAME f_cadmov.

                     LEAVE.


                  END.
                  
                  IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                      NEXT.
              
                  DO TRANSACTION:
              
                     DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         MESSAGE "Confirma a operacão?"
                         UPDATE aux_confirma.
                         LEAVE.
                     END.
                 
                     IF  aux_confirma = "S" THEN
                         DO:
                            DO aux_contador = 1 TO 10:
                          
                                FIND b-crapmei1 WHERE b-crapmei1.cdmovext = tel_cdmovext AND
                                                      b-crapmei1.dsmovext = tel_dsmovext AND
                                                      b-crapmei1.tpmovext = tel_tpmovext   
                                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
                                IF   NOT AVAILABLE b-crapmei1   THEN
                                     IF   LOCKED b-crapmei1   THEN
                                          DO:
                                             PAUSE 2 NO-MESSAGE.
                                             NEXT.
                                          END.
                                    
                                DELETE b-crapmei1.

                        
                                LEAVE.
                        
                            END.


                            RUN gera_log (INPUT glb_cddopcao,
                                          INPUT 0,
                                          INPUT "",
                                          INPUT "",
                                          INPUT 0,
                                          INPUT "",
                                          INPUT "").
                        
                         END.
                     ELSE
                        DO:
                           HIDE FRAME f_cadmov.
                           tel_cdmovext = 0.
                           tel_tpmovext = "".
                           tel_dsmovext = "".

                        END.
              
                  END.
                       
                 IF   glb_cdcritic > 0 OR
                      glb_dscritic <> ""  THEN
                      DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         RETURN.
                      END.  
                 
              
              
               END. /* Fim da opcao E */
      ELSE
         IF  glb_cddopcao = "A" THEN
             DO:
                aux_confirma = "N".
                

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   UPDATE tel_cdmovext
                          tel_tpmovext
                          WITH FRAME f_cadmov.

                   DO TRANSACTION:
                   
                      FIND crapmei WHERE crapmei.cdmovext = tel_cdmovext AND
                                         crapmei.tpmovext = tel_tpmovext
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                      IF  NOT AVAIL crapmei THEN
                          DO:
                            IF LOCKED crapmei THEN
                               DO:
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                              
                               END.
                            ELSE
                               DO:   
                                 MESSAGE glb_dscritic  "Registro nao encontrado".
                                 NEXT. 
                               END.       
                   
                          END.
                  
                  
                      tel_dsmovext = crapmei.dsmovext.
                         
                      DISP tel_dsmovext WITH FRAME f_cadmov.
                   
                      ASSIGN aux_cdmovext = crapmei.cdmovext
                             aux_dsmovext = crapmei.dsmovext
                             aux_tpmovext = crapmei.tpmovext.
                  
                  
                      UPDATE tel_dsmovext
                             WITH FRAME f_cadmov.
                     
                      DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          MESSAGE "Confirma a operação?"
                          UPDATE aux_confirma.
                          LEAVE.
                     
                      END.
                  
                      IF aux_confirma = "S" THEN
                         DO:
                           IF tel_cdmovext = aux_cdmovext AND 
                              tel_tpmovext = aux_tpmovext AND
                              tel_dsmovext <> aux_dsmovext THEN
                              DO:
                                 FIND b-crapmei1 WHERE b-crapmei1.cdmovext = tel_cdmovext AND
                                                       b-crapmei1.dsmovext = tel_dsmovext
                                                       NO-LOCK NO-ERROR.
                  
                                 IF NOT AVAIL b-crapmei1 THEN
                                    DO: 
                                       ASSIGN crapmei.dsmovext = tel_dsmovext.
                  
                                       RUN gera_log (INPUT glb_cddopcao,
                                                     INPUT aux_cdmovext,
                                                     INPUT aux_tpmovext,
                                                     INPUT aux_dsmovext,
                                                     INPUT crapmei.cdmovext,
                                                     INPUT crapmei.tpmovext,
                                                     INPUT crapmei.dsmovext). 
                  
                                    END.
                                 ELSE
                                    MESSAGE glb_dscritic "Movimento com codigo e desc. ja existente.". 
                                  
                              END.
                           ELSE
                              DO: 
                                FIND b-crapmei1 WHERE b-crapmei1.cdmovext = tel_cdmovext AND
                                                      b-crapmei1.dsmovext = tel_dsmovext AND
                                                      b-crapmei1.tpmovext = tel_tpmovext 
                                                      NO-LOCK NO-ERROR.
                         
                                IF NOT AVAIL b-crapmei1 THEN
                                   DO: 
                                     FIND b-crapmei2 WHERE b-crapmei2.cdmovext = tel_cdmovext AND
                                                           b-crapmei2.tpmovext = tel_tpmovext
                                                           NO-LOCK NO-ERROR.
                         
                                     IF NOT AVAIL b-crapmei2 THEN
                                        DO: 
                                           ASSIGN crapmei.cdmovext = tel_cdmovext
                                                  crapmei.dsmovext = tel_dsmovext
                                                  crapmei.tpmovext = tel_tpmovext.
                         
                                            RUN gera_log (INPUT glb_cddopcao,
                                                          INPUT aux_cdmovext,
                                                          INPUT aux_tpmovext,
                                                          INPUT aux_dsmovext,
                                                          INPUT crapmei.cdmovext,
                                                          INPUT crapmei.tpmovext,
                                                          INPUT crapmei.dsmovext).
                                            
                                        END.
                                     ELSE
                                        glb_cdcritic = 873. 
                  
                  
                                   END.
                                ELSE 
                                   MESSAGE glb_dscritic "Movimento com codigo e desc. ja existente.". 
                         
                         
                              END.
                         END.
                      ELSE
                         DO:
                            HIDE FRAME f_cadmov.
                            tel_cdmovext = 0.
                            tel_tpmovext = "".
                            tel_dsmovext = "".
                            aux_cdmovext = 0.
                            aux_tpmovext = "".
                            aux_dsmovext = "".
                       
                         END.
                      
                   END.
             
                   LEAVE.

                 END.
                 IF   glb_cdcritic > 0 THEN
                      DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         RETURN.
                      END.  
                
             
              END.
    
          
END. /* Fim do DO WHILE TRUE */   


PROCEDURE gera_log:

    DEF INPUT PARAM par_cddopcao LIKE glb_cddopcao      NO-UNDO.
    DEF INPUT PARAM par_cdmovext AS INT                 NO-UNDO.
    DEF INPUT PARAM par_tpmovext AS CHAR FORMAT "x(35)" NO-UNDO.
    DEF INPUT PARAM par_dsmovext AS CHAR FORMAT "!"     NO-UNDO.
    DEF INPUT PARAM par_auxcdmov AS INT                 NO-UNDO.
    DEF INPUT PARAM par_auxtpmov AS CHAR FORMAT "x(35)"  NO-UNDO.
    DEF INPUT PARAM par_auxdsmov AS CHAR FORMAT "!"     NO-UNDO.



    IF par_cddopcao = "I" THEN
       UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")   +
                                  " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"    +
                                  " Operador " + glb_cdoperad + " - " + "Criou"     +
                                  " o movimento " + STRING(tel_cdmovext)            +
                                  ", tipo " + tel_tpmovext + " , com a descricao "  + 
                                  tel_dsmovext + "."    +
                                  " >> log/cadmov.log").
    ELSE
       IF par_cddopcao = "E" THEN
          UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")      +
                           " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"    +
                           " Operador " + glb_cdoperad + " - " + "Excluiu"   +
                           " o movimento " + STRING(tel_cdmovext)            +
                           ", tipo " + tel_tpmovext + " , com a descricao "  + 
                           tel_dsmovext + "."    +
                           " >> log/cadmov.log").
    ELSE
       IF par_cddopcao = "A" THEN
          UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                    " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"      +
                    " Operador " + glb_cdoperad + " - " + "Alterou"     +
                    " o movimento " + STRING(par_cdmovext) + " para "   +
                    (IF par_cdmovext = par_auxcdmov THEN 
                      "---" ELSE
                      STRING(par_auxcdmov)) 
                    + ", tipo " + par_tpmovext + " para "               + 
                    (IF par_tpmovext = par_auxtpmov THEN
                      "---" ELSE 
                      par_auxtpmov) 
                    + " , com a descricao " + par_dsmovext + " para "   +
                    (IF par_dsmovext = par_auxdsmov THEN
                      "---" ELSE
                      par_auxdsmov) 
                    + "." + " >> log/cadmov.log").



END PROCEDURE.


/*...........................................................................*/
