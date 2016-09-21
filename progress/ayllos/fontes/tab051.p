/*.............................................................................

    Programa: fontes/tab051.p
    Sistema : Conta-Corrente
    Sigla   : CRED
    Autor   : Gabriel
    Data    : Junho/2008                        Ultima Atualizacao: /  /

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Mostrar a tela TAB051 - Agendamento de GPS - Bancoob.
    
    Alteracoes:
    
    
.............................................................................*/

{ includes/var_online.i }

DEF     VAR tel_dppesfis AS INTEGER   FORMAT "99"                      NO-UNDO.
DEF     VAR tel_dppesjur AS INTEGER   FORMAT "99"                      NO-UNDO.

DEF     VAR aux_cddopcao AS CHARACTER                                  NO-UNDO.
DEF     VAR aux_confirma AS CHARACTER FORMAT "!"                       NO-UNDO.

FORM SKIP(3)
     glb_cddopcao AT 35 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A ou C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                        "014 - Opcao errada.")
     SKIP(2)
     
     tel_dppesfis AT 26 LABEL "Dia para pessoa fisica  "
     HELP "Informe o dia p/ agendamento de GPS - Bancoob pessoa fisica."
     
     SKIP(1)
     
     tel_dppesjur AT 26 LABEL "Dia para pessoa juridica"
     HELP "Informe o dia p/ agendamento de GPS - Bancoob pessoa juridica."

     SKIP(7)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_tab051.
     
ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.
       
       
DO WHILE TRUE:
       
   RUN fontes/inicia.p.
          
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
             
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab050 NO-PAUSE.
               glb_cdcritic = 0.
           END.
     
      UPDATE glb_cddopcao WITH FRAME f_tab051.
              
      LEAVE.
   
   END. 
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    THEN
        DO:
            RUN fontes/novatela.p.
           
            IF   CAPS(glb_nmdatela) <> "TAB051"    THEN
                 DO:
                     HIDE FRAME f_tab051.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    
   FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                          craptab.cdacesso = "GPSAGEBCOB" AND
                          craptab.cdempres = 0            AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "GENERI"     AND
                         (craptab.tpregist = 1            OR
                          craptab.tpregist = 2)           NO-LOCK:
                          
       IF   craptab.tpregist = 1   THEN
            tel_dppesfis = INTEGER(craptab.dstextab).
       ELSE
            tel_dppesjur = INTEGER(craptab.dstextab).
   END.                      

   DISPLAY tel_dppesfis
           tel_dppesjur WITH FRAME f_tab051.
           
   
   IF   glb_cddopcao = "A"   THEN
        DO:
            UPDATE tel_dppesfis
                   tel_dppesjur WITH FRAME f_tab051.
                   
            RUN confirma.       
        
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 DO:
                     ASSIGN tel_dppesfis = 0
                            tel_dppesjur = 0.
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 
                 END.
        
            FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                   craptab.cdacesso = "GPSAGEBCOB"   AND
                                   craptab.cdempres = 0              AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "GENERI"       AND
                                  (craptab.tpregist = 1              OR
                                   craptab.tpregist = 2)             
                                   EXCLUSIVE-LOCK:

                IF   craptab.tpregist = 1    THEN
                     ASSIGN craptab.dstextab = STRING(tel_dppesfis).
                ELSE
                     ASSIGN craptab.dstextab = STRING(tel_dppesjur).

            END. /* Fim do FOR EACH craptab */
        
        END. /* Fim da Opcao "A" */

END. /* Fim do DO WHILE TRUE */

PROCEDURE confirma:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.
              RUN fontes/critic.p.
              BELL.
              glb_cdcritic = 0.
              MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
              LEAVE.
       
    END.

END PROCEDURE.

/*............................................................................*/
