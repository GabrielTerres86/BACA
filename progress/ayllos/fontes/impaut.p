/* .............................................................................

   Programa: Fontes/impaut.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Outubro/2002                    Ultima alteracao: 14/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPAUT.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               19/10/2005 - Passado codigo da cooperativa para bo 40(Julio)
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).              
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.                                                      


DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_nrdcaixa AS INT    FORMAT "zz9"                   NO-UNDO.

DEF        VAR aux_nrdiasem AS INTE                                  NO-UNDO.
DEF        VAR aux_diaseman AS INTE                                  NO-UNDO.
DEF        VAR aux_nmdiasem AS CHAR FORMAT "x(03)" EXTENT 7          NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR FORMAT "x(256)"                  NO-UNDO. 
DEF        VAR aux_nmdirarq AS CHAR                                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_cdagefim LIKE crapaut.cdagenci                    NO-UNDO.
DEF        VAR aux_contador AS INTE                                  NO-UNDO.
DEF        VAR aux_flgexarq AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrcaifim AS INTE                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR FORMAT "x(40)"                   NO-UNDO.

DEF        VAR h-b1crap40   AS HANDLE                                NO-UNDO.

DEF TEMP-TABLE workarq                                               NO-UNDO
    FIELD nmarqimp AS CHAR
    FIELD cdagenci LIKE crapaut.cdagenci
    FIELD nrdcaixa LIKE crapaut.nrdcaixa
    FIELD nmdiasem AS CHAR 
    INDEX workarq1 AS UNIQUE PRIMARY
          nmarqimp
    INDEX workarq2 
          cdagenci
          nrdcaixa.

DEF QUERY q_arquivos FOR workarq.
                                     
DEF BROWSE b_arquivos QUERY q_arquivos 
    DISP cdagenci COLUMN-LABEL "PA"
         nrdcaixa COLUMN-LABEL "CAIXA"
         nmdiasem COLUMN-LABEL "DIA"
         WITH 9 DOWN.

DEF FRAME f_arquivos  
          SKIP(1)
          b_arquivos   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
  
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (I ou C)."
                        VALIDATE(CAN-DO("I,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_impaut.

FORM tel_cdagenci LABEL "         PA"
                  HELP "Entre com o numero do PA ou 0 para todos os PA's."
     tel_nrdcaixa       LABEL "     CAIXA"
                 HELP "Entre com o numero do CAIXA ou 0 para todos"
     WITH ROW 6 COLUMN 20 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

ASSIGN glb_cddopcao    = "C"
       glb_cdcritic    = 0
       aux_nmdiasem[1] = "DOM"
       aux_nmdiasem[2] = "SEG"
       aux_nmdiasem[3] = "TER"
       aux_nmdiasem[4] = "QUA"
       aux_nmdiasem[5] = "QUI"
       aux_nmdiasem[6] = "SEX"
       aux_nmdiasem[7] = "SAB".
 
VIEW FRAME f_moldura.
PAUSE(0).
   
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_impaut.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "IMPAUT"  THEN
                 DO:
                     HIDE FRAME f_arquivos NO-PAUSE.
                     HIDE FRAME f_impaut.
                     HIDE FRAME f_moldura.
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

   IF   glb_cddopcao = "C"   THEN
        DO:
            HIDE FRAME f_arquivos NO-PAUSE.
            
            ASSIGN tel_cdagenci = 0
                   tel_nrdcaixa = 0.

            RUN carrega_tabela.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
               
               UPDATE tel_cdagenci tel_nrdcaixa WITH FRAME f_refere.

               ASSIGN aux_confirma = "N" 
                      aux_cdagefim = IF tel_cdagenci = 0 
                                     THEN 9999
                                     ELSE tel_cdagenci.
               
               IF   aux_contador = 0   THEN
                    DO:
                        ASSIGN glb_cdcritic = 182.
                        LEAVE.
                    END.          
               ELSE
                    IF   glb_cdcritic <> 0   THEN      
                         LEAVE.
                                    
               IF   tel_cdagenci <> 0   THEN
                    DO:
               
                        ASSIGN aux_flgexarq = NO
                               aux_nrcaifim = IF tel_nrdcaixa <> 0  
                                              THEN tel_nrdcaixa
                                              ELSE 999.
               
                        FOR EACH workarq WHERE 
                                 workarq.cdagenci  = tel_cdagenci   AND
                                 workarq.nrdcaixa >= tel_nrdcaixa   AND
                                 workarq.nrdcaixa <= aux_nrcaifim   NO-LOCK:
                            ASSIGN aux_flgexarq = YES.
                            LEAVE.
                        END.
               
                        IF   NOT aux_flgexarq   THEN 
                             DO:
                                 glb_cdcritic = 182.
                                 NEXT-PROMPT tel_cdagenci WITH FRAME f_refere.
                                 NEXT.
                             END. 
                    END.              
               
               IF   tel_cdagenci = 0 THEN
                    DO:
                        OPEN QUERY q_arquivos FOR EACH workarq NO-LOCK.
 
                        ENABLE b_arquivos WITH FRAME f_arquivos.

                        WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                          
                        HIDE FRAME f_arquivos.
                    END.
               ELSE
                    DO: 
                        OPEN QUERY q_arquivos 
                        FOR EACH workarq WHERE 
                                 workarq.cdagenci  = tel_cdagenci AND
                                 workarq.nrdcaixa >= tel_nrdcaixa NO-LOCK.
 
                        ENABLE b_arquivos WITH FRAME f_arquivos.

                        WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
                        HIDE FRAME f_arquivos.
                    END.
               
               HIDE MESSAGE NO-PAUSE.
               
            END. /*  Fim do DO WHILE TRUE  */
       END.
   ELSE
   IF   glb_cddopcao = "I"   THEN  /*   Gera CRAPAUT   */
        DO:
            HIDE FRAME f_arquivos NO-PAUSE.
            
            ASSIGN tel_nrdcaixa = 0
                   tel_cdagenci = 0.
        
            DISPLAY tel_cdagenci tel_nrdcaixa WITH FRAME f_refere.

            RUN carrega_tabela.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
               UPDATE tel_cdagenci tel_nrdcaixa WITH FRAME f_refere.

               IF   tel_cdagenci = 0   THEN
                    DO:
                        ASSIGN glb_cdcritic = 89.
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_refere.
                        NEXT.
                    END.
               
               IF   tel_nrdcaixa = 0   THEN
                    DO:
                        ASSIGN glb_cdcritic = 375.
                        NEXT-PROMPT tel_nrdcaixa WITH FRAME f_refere.
                        NEXT.
                    END.
               
               IF   aux_contador = 0   THEN
                    DO:
                        ASSIGN glb_cdcritic = 182.
                        LEAVE. /*** erro do carrega_tabela ***/
                    END.          
               ELSE
                    IF   glb_cdcritic <> 0   THEN      
                         LEAVE. /*** erro do carrega_tabela ***/
               
               ASSIGN aux_flgexarq = NO.
               
               FOR EACH workarq WHERE workarq.cdagenci = tel_cdagenci  AND
                                      workarq.nrdcaixa = tel_nrdcaixa  NO-LOCK:
                   ASSIGN aux_flgexarq = YES.
                   LEAVE.
               END.
               
               IF   NOT aux_flgexarq   THEN 
                    DO:
                        glb_cdcritic = 182.
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_refere.
                        NEXT.
                    END.                   
            
               LEAVE.
               
            END.      
            
            OPEN QUERY q_arquivos 
                 FOR EACH workarq WHERE workarq.cdagenci = tel_cdagenci AND
                                        workarq.nrdcaixa = tel_nrdcaixa NO-LOCK.
 
            ENABLE b_arquivos WITH FRAME f_arquivos.

            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
            HIDE MESSAGE NO-PAUSE.
            
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
                     NEXT.
                 END.

            ASSIGN glb_cdcritic = 0.
            
            RUN siscaixa/web/dbo/b1crap40.p PERSISTENT SET h-b1crap40.

            RUN importacao IN h-b1crap40 (INPUT crapcop.nmrescop,
                                          INPUT tel_cdagenci,
                                          INPUT tel_nrdcaixa).
                
            DELETE PROCEDURE h-b1crap40.
                  
            FIND FIRST craperr WHERE craperr.cdcooper = glb_cdcooper 
                                     NO-LOCK NO-ERROR.
            
            IF   AVAILABLE craperr   THEN
                 DO:
                     FOR EACH craperr WHERE craperr.cdcooper = glb_cdcooper
                                            NO-LOCK:
                         BELL.
                         ASSIGN glb_dscritic = craperr.dscritic.
                         MESSAGE glb_dscritic.
                         PAUSE 2.
            
                     END.
                     
                 END.    
            ELSE
                 DO:              
                     PAUSE 2 NO-MESSAGE.
            
                     HIDE MESSAGE NO-PAUSE.

                     MESSAGE "Atualizacao com sucesso".
    
                     PAUSE 2. 

                 END.
                 
            LEAVE.
             
        END.
        
END.  /*  Fim do DO WHILE TRUE  */

/*  ........................................................................  */

PROCEDURE carrega_tabela.
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN aux_nmarqimp = crapcop.nmdireto + "/off-line/*".
   
    /*FOR EACH workarq:
        DELETE workarq.
    END.*/
    
    EMPTY TEMP-TABLE workarq.

    INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarqimp + " 2> /dev/null")
          NO-ECHO.
                                           
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1
           aux_nmarqimp FORMAT "x(200)" WITH WIDTH 256 .

       IF  SEARCH(aux_nmarqimp) <> ?  THEN
           DO:
           
               FIND workarq WHERE workarq.nmarqimp = aux_nmarqimp
                                  NO-LOCK NO-ERROR.
               IF   AVAILABLE workarq   THEN
                    DO:
                        glb_cdcritic = 745.
                        LEAVE.    
                    END.
               
               INPUT STREAM str_2 THROUGH 
                     value("basename " + aux_nmarqimp)  NO-ECHO.

               SET STREAM str_2 aux_nmendter WITH FRAME f_terminal.

               INPUT STREAM str_2 CLOSE.

               CREATE workarq.
               ASSIGN workarq.nmarqimp = aux_nmarqimp
                      workarq.cdagenci = INTE(SUBSTR(aux_nmendter,1,3))
                      workarq.nrdcaixa = INTE(SUBSTR(aux_nmendter,4,3))
                      workarq.nmdiasem = SUBSTR(aux_nmendter,7,3)
                      aux_contador     = aux_contador + 1.

           END.
            
    END.  /*  Fim do DO WHILE TRUE  */
                                             
    INPUT STREAM str_1 CLOSE.

END PROCEDURE.   

/****************************************************************************/

