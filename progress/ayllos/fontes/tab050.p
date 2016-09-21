/*.............................................................................

    Programa: fontes/tab050.p
    Sistema : Conta-Corrente
    Sigla   : CRED
    Autor   : Gabriel
    Data    : Junho/2008                      Ultima atualizacao: 25/03/2016

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Mostrar a tela TAB050 - Cadastro de prazo minimo e maximo para
                vencimento das poupancas programadas.

    Alteracoes: 25/05/2009 - Alteracao CDOPERAD (Kbase).
    
                25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
..............................................................................*/

{ includes/var_online.i }


DEF     VAR tel_pzmaxpro AS INTEGER FORMAT "zz9"                       NO-UNDO.
DEF     VAR tel_pzminpro AS INTEGER FORMAT "zz9"                       NO-UNDO.
    
DEF     VAR aux_cddopcao AS CHARACTER                                  NO-UNDO.
DEF     VAR aux_confirma AS CHARACTER FORMAT "!"                       NO-UNDO.

FORM SKIP(3)
     glb_cddopcao AT 35 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                        "014 - Opcao errada.")
     SKIP(2)
     
     tel_pzminpro AT 16 LABEL "Prazo minimo para vencimento(meses)" AUTO-RETURN
     HELP "Informe em meses o prazo min. para o vencimento da PP."
     
     SKIP(1)
     tel_pzmaxpro AT 16 LABEL "Prazo maximo para vencimento(meses)" AUTO-RETURN
     HELP "Informe em meses o prazo max. para o vencimento da PP."
     
     SKIP(7)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_tab050.
     
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
     
      UPDATE glb_cddopcao WITH FRAME f_tab050.
      
      LEAVE.
   
   END.
    
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    THEN
        DO:
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "TAB050"    THEN
                 DO:
                     HIDE FRAME f_tab050.
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

   FOR EACH craptab WHERE craptab.cdcooper = 0               AND
                          craptab.nmsistem = "CRED"          AND
                          craptab.tptabela = "GENERI"        AND
                          craptab.cdempres = 0               AND
                          craptab.tpregist = 1               AND
                         (craptab.cdacesso = "PZMAXPPROG"    OR
                          craptab.cdacesso = "PZMINPPROG")   NO-LOCK:   
       
       IF   craptab.cdacesso = "PZMAXPPROG"   THEN
            tel_pzmaxpro = INTEGER(craptab.dstextab).
       ELSE               
            tel_pzminpro = INTEGER(craptab.dstextab).
   
   END.

   DISPLAY tel_pzminpro
           tel_pzmaxpro WITH FRAME f_tab050.

   IF   glb_cddopcao = "A"   THEN
        DO:
            /* Critica para permitir somente os operadores 1, 996 e 997 */
            IF   glb_dsdepart <> "TI"                   AND
                 glb_dsdepart <> "COORD.ADM/FINANCEIRO" THEN
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
            
            UPDATE tel_pzminpro
                   tel_pzmaxpro WITH FRAME f_tab050.
        
            RUN confirma.
        
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 DO:
                     ASSIGN tel_pzminpro = 0
                            tel_pzmaxpro = 0.
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.

            FOR EACH craptab WHERE craptab.cdcooper = 0               AND
                                   craptab.nmsistem = "CRED"          AND
                                   craptab.tptabela = "GENERI"        AND
                                   craptab.cdempres = 0               AND
                                   craptab.tpregist = 1               AND
                                  (craptab.cdacesso = "PZMAXPPROG"    OR
                                   craptab.cdacesso = "PZMINPPROG")   
                                   EXCLUSIVE-LOCK:
            
                IF   craptab.cdacesso = "PZMAXPPROG"   THEN
                     craptab.dstextab = STRING(tel_pzmaxpro).
                ELSE
                     craptab.dstextab = STRING(tel_pzminpro).
            
            END.  /* Fim do FOR EACH craptab */
        
        END.  /* Fim da opcao "A" */

END.   /* Fim do WHILE TRUE */

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
     
/*...........................................................................*/
