/* .............................................................................

   Programa: Fontes/gerimp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Abril/2003                         Ultima atualizacao: 31/08/2004

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Chamar o MTSPOOL

   Alteracoes: 31/08/2004 - Verificar se o operador tem usuario cadastrado no
                            mtspool (Edson).
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmdlogin AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_inacesso AS INT                                   NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(5)
     glb_cddopcao AT 10 LABEL
     "Executar Gerenciador de Impressao? (S/N)" AUTO-RETURN
                        HELP "Use <Enter> para executar ou <F4> para sair"
     SKIP(1)
     WITH ROW 6 COLUMN 10 OVERLAY SIDE-LABELS NO-BOX FRAME f_impres.

VIEW FRAME f_moldura.

PAUSE 0.

ASSIGN glb_cddopcao = "S".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_impres.

      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i}
               aux_cddopcao = glb_cddopcao.
           END.

      IF   glb_cddopcao = "S" THEN
           DO:                         
               RUN proc_valida_usuario.
               
               IF   glb_cdcritic > 0   THEN
                    DO:
                        DISPLAY SKIP(1)
                        "  Acesso ao Gerenciador de Impressao NAO autorizado.  "
                        SKIP(1)
                        "  Solicite autorizacao de acesso via 0800net, produ-  "
                        SKIP
                        "  to: Gerenciador de Impressao.                       "
                        SKIP(1)
                        WITH ROW 13 OVERLAY CENTERED 
                             TITLE COLOR NORMAL " Erro " FRAME f_0800.
                                
                        NEXT.
                    END.
               ELSE
                    DO:
                        UNIX VALUE ("mtspool adm").
                        PAUSE 0.
                    END.
               LEAVE.
           END.
      ELSE
           LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "GERIMP"   THEN
                 DO:
                     HIDE FRAME f_0800.
                     HIDE FRAME f_impres.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   HIDE FRAME f_impres NO-PAUSE.
   HIDE FRAME f_0800.
   PAUSE 0.
   
   glb_nmdatela = "MENU01".
   LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE proc_valida_usuario:

    INPUT THROUGH echo $LOGNAME NO-ECHO.

    SET aux_nmdlogin.

    INPUT THROUGH VALUE("grep -wc " + aux_nmdlogin +
                        " /usr/spool/lp/mt_usuarios") NO-ECHO.

    SET aux_inacesso.
    
    IF   aux_inacesso > 0   THEN
         glb_cdcritic = 0.
    ELSE
         glb_cdcritic = 36.
         
END PROCEDURE.

/* .......................................................................... */

