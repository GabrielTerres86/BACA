/* .............................................................................

   Programa: Fontes/ctremp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/93.                        Ultima atualizacao: 01/11/2007

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas (on-line)
   Objetivo  : Mostrar a lista de contratos de emprestimos.

   Alteracoes: 11/02/2005 - Acerto no programa (Ze).
   
               19/09/2006 - Permitir o uso do F2-AJUDA (Evandro).
               
               01/11/2007 - Alterado para nao deixar adicionar mais de 10
                            emprestimos para serem liquidados por uma nova 
                            proposta de emprestimo(Guilherme).

............................................................................. */

{ includes/var_online.i } 
{ includes/ctremp.i }

DEF VAR aux_contmax10    AS INTEGER                                  NO-UNDO.
DEF VAR aux_flagcont     AS LOGICAL                                  NO-UNDO.

DEFINE VARIABLE p_down   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_flag   AS LOGICAL   INITIAL FALSE EXTENT 5000      NO-UNDO.
DEFINE VARIABLE p_line   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_recid  AS INTEGER   INITIAL 1                      NO-UNDO.
DEFINE VARIABLE p_redraw AS LOGICAL   INITIAL TRUE                   NO-UNDO.
DEFINE VARIABLE p_spot   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_typed  AS CHARACTER INITIAL ""                     NO-UNDO.

DEFINE VARIABLE aux_contador AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_confirma AS CHAR  FORMAT "!" INIT "N"            NO-UNDO.

DEFINE VARIABLE tot_vlliquid AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE c_branco     AS CHARACTER FORMAT "x(80)"             NO-UNDO.

FORM c_branco
     WITH FRAME f_branco NO-BOX NO-LABELS ROW 24.

ASSIGN p_down   = MINIMUM(9,s_chextent)
       s_choice = -1
       s_chcnt  = 0
       s_row    = (IF s_row = 0    THEN 5 ELSE s_row)
      s_column = (IF s_column = 0 THEN (IF s_wide THEN 2 ELSE 48) ELSE s_column)
       s_title  = (IF s_title = "" THEN " Choices " ELSE s_title)

       tot_vlliquid = 0.

IF   s_chextent <= 0   THEN
     RETURN.

FORM p_flag[p_recid] FORMAT "* /  " SPACE(0) s_chlist[p_recid] FORMAT "x(7)"
     WITH FRAME pick1 SCROLL 1 OVERLAY NO-LABELS p_down DOWN
          ROW s_row COLUMN s_column TITLE COLOR MESSAGES s_title.

FORM p_flag[p_recid] FORMAT "* /  " SPACE(0) s_chlist[p_recid] FORMAT "x(73)"
     WITH FRAME pick2 SCROLL 1 OVERLAY NO-LABELS p_down DOWN
          ROW s_row CENTERED TITLE COLOR MESSAGES s_title.

FORM p_typed FORMAT "x(9)"
     WITH FRAME type1 OVERLAY NO-LABELS ROW s_row + p_down + 2 COLUMN s_column.

FORM p_typed FORMAT "x(72)"
     WITH FRAME type2 OVERLAY NO-LABELS ROW s_row + p_down + 2 COLUMN s_column.

ASSIGN aux_contmax10 = 1
       aux_flagcont = FALSE.

DO p_recid = 1 TO NUM-ENTRIES(s_liquidac):

   DO aux_contador = 1 TO s_chextent:

      IF   s_vlsdeved[p_recid] > 0   THEN
           IF   s_chlist[aux_contador]  MATCHES "*" +
                                   TRIM(ENTRY(p_recid,s_liquidac)) + "*"   THEN
                DO:
                    ASSIGN p_flag[aux_contador] = TRUE.
                           aux_flagcont = TRUE.
                           aux_contmax10 = aux_contmax10 + 1.
                           tot_vlliquid = tot_vlliquid + 
                                          s_vlsdeved[aux_contador].   
                END.    
                
   END.  /*  Fim do DO .. TO  */

END.  /*  Fim do DO .. TO  */

p_recid = 1.

/* Usado o mesmo contador p/ incluir e alterar. 
   na hora de alterar ele deve permitir somente 10 tambem 
   por isso eh feito este decremento. */
IF aux_flagcont THEN
   aux_contmax10 = aux_contmax10 - 1.

_pick:
DO WHILE TRUE:

   p_recid = MINIMUM(s_chextent,MAXIMUM(p_recid,1)).

   IF   p_redraw   THEN
        DO:
            ASSIGN p_line = MAXIMUM(1,IF s_wide
                                         THEN FRAME-LINE(pick2)
                                         ELSE FRAME-LINE(pick1))
                   p_spot = p_recid - p_line + 1.

            IF   s_wide   THEN
                 UP p_line - 1 WITH FRAME pick2.
            ELSE
                 UP p_line - 1 WITH FRAME pick1.

            IF   p_spot < 1   THEN
                 ASSIGN p_spot  = 1
                        p_line  = 1
                        p_recid = 1.

            DO s_chcnt = p_spot TO p_spot + p_down - 1:

               IF   s_chcnt > s_chextent   THEN
                    IF   s_wide   THEN
                         CLEAR FRAME pick2 NO-PAUSE.
                    ELSE
                         CLEAR FRAME pick1 NO-PAUSE.
               ELSE
                    IF   s_wide   THEN
                         DISPLAY p_flag[s_chcnt] @   p_flag[p_recid]
                                 s_chlist[s_chcnt] @ s_chlist[p_recid]
                                 WITH FRAME pick2.
                    ELSE
                         DISPLAY p_flag[s_chcnt] @   p_flag[p_recid]
                                 s_chlist[s_chcnt] @ s_chlist[p_recid]
                                 WITH FRAME pick1.

               IF   s_chcnt < p_spot + p_down - 1   THEN
                    IF   s_wide   THEN
                         DOWN WITH FRAME pick2.
                    ELSE
                         DOWN WITH FRAME pick1.

            END.  /*  Fim do DO .. TO  */

            IF   s_wide   THEN
                 UP p_down - p_line WITH FRAME pick2.
            ELSE
                 UP p_down - p_line WITH FRAME pick1.

            ASSIGN s_chcnt  = 0
                   p_redraw = FALSE.
        END.

   IF   s_wide   THEN
        DISPLAY p_flag[p_recid] s_chlist[p_recid] WITH FRAME pick2.
   ELSE
        DISPLAY p_flag[p_recid] s_chlist[p_recid] WITH FRAME pick1.

   IF   s_wide   THEN
        COLOR DISPLAY MESSAGES p_flag[p_recid] s_chlist[p_recid]
              WITH FRAME pick2.
   ELSE
        COLOR DISPLAY MESSAGES p_flag[p_recid] s_chlist[p_recid]
              WITH FRAME pick1.

   IF   s_multiple   THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
            /*PUT SCREEN ROW 24 FILL(" ",70).*/
            MESSAGE COLOR NORMAL
               "Marque os emprestimos a serem liquidados teclando <ENTRA> ou".
            MESSAGE COLOR NORMAL "tecle <FIM> para retornar.".
        END.
   ELSE
        DO:
            HIDE MESSAGE NO-PAUSE.
            MESSAGE COLOR NORMAL
                    "Escolha com as setas, pgant, pgseg e tecle <Entra>.".
        END.

   READKEY.

   IF   s_wide   THEN
        COLOR DISPLAY NORMAL   p_flag[p_recid] s_chlist[p_recid]
              WITH FRAME pick2.
   ELSE
        COLOR DISPLAY NORMAL   p_flag[p_recid] s_chlist[p_recid]
              WITH FRAME pick1.

   PAUSE 0.

   IF  (KEYFUNCTION(LASTKEY) = CHR(LASTKEY) AND LASTKEY >= 32)        OR
       (KEYFUNCTION(LASTKEY) = "BACKSPACE" AND LENGTH(p_typed) > 0)   THEN
        DO:
            p_typed = (IF KEYFUNCTION(LASTKEY) = "BACKSPACE"
                          THEN SUBSTRING(p_typed,1,LENGTH(p_typed) - 1)
                          ELSE p_typed + CHR(LASTKEY)).

            IF   p_typed = "" OR s_chlist[p_recid] BEGINS p_typed   THEN
                 NEXT.

            DO p_line = p_recid TO s_chextent:

               IF   s_chlist[p_line] BEGINS p_typed   THEN
                    LEAVE.

            END.  /*  Fim do DO .. TO  */

            IF   p_line > s_chextent   THEN
                 DO:
                     DO p_line = 1 TO p_recid:

                        IF   s_chlist[p_line] BEGINS p_typed   THEN
                             LEAVE.

                     END.  /*  Fim do DO .. TO  */

                     IF   p_line > p_recid   THEN
                          p_line = s_chextent + 1.
                 END.

            IF   p_line > s_chextent   THEN
                 DO:
                     p_typed = CHR(LASTKEY).

                     DO p_line = 1 TO s_chextent:

                        IF   s_chlist[p_line] BEGINS p_typed   THEN
                             LEAVE.

                     END.  /*  Fim do DO .. TO  */
                 END.

            IF   p_line <= s_chextent   THEN
                 ASSIGN p_recid  = p_line
                        p_redraw = TRUE.

            NEXT.
        END.

   p_typed = "".

   IF   CAN-DO("RETURN,PICK",KEYFUNCTION(LASTKEY)) AND s_multiple   THEN
        DO:
            HIDE MESSAGE NO-PAUSE.

            IF   SUBSTRING(s_chlist[p_recid],19,10) = STRING(glb_dtmvtolt,
                                                             "99/99/9999")  THEN
                 
                 DO:
                     DISPLAY SKIP(1)
                             "   Nao e' possivel liquidar emprestimo   " SKIP
                             "      feito nesta data -" 
                             glb_dtmvtolt FORMAT "99/99/9999"
                             SKIP(1)
                             WITH CENTERED OVERLAY ROW 10 NO-LABELS
                                  FRAME f_liquida.
                 
                     PAUSE 3 NO-MESSAGE.
                     
                     HIDE FRAME f_liquida NO-PAUSE.
                 END.
            ELSE
            IF   s_vlsdeved[p_recid] > 0   THEN
                 DO:
                     /* Guilherme */
                     
                     IF aux_contmax10 > 10 AND NOT p_flag[p_recid] THEN
                        DO:
                           MESSAGE "Maximo de emprestimos para liquidar - 10".
                           PAUSE 3 NO-MESSAGE .
                           NEXT.
                        END. 
                     /**************/
                     p_flag[p_recid] = NOT p_flag[p_recid].
                     
                     IF   p_flag[p_recid]   THEN
                          DO:
                              aux_contmax10 = aux_contmax10 + 1.
                              tot_vlliquid = tot_vlliquid + s_vlsdeved[p_recid].
                              IF   tot_vlliquid > s_vlemprst   THEN
                                   DO:
                                       BELL.

                                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                          aux_confirma = "N".

                                          MESSAGE COLOR NORMAL
                                                  "Saldo a liquidar e' maior"
                                                  "que o valor a emprestar."
                                                  "Confirme (S/N):"
                                                  UPDATE aux_confirma.

                                          LEAVE.

                                       END.  /*  Fim do DO WHILE TRUE  */

                                       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"
                                            OR aux_confirma <> "S" THEN
                                            ASSIGN p_flag[p_recid] = FALSE
                                                   tot_vlliquid = tot_vlliquid -
                                                       s_vlsdeved[p_recid].
                                   END.
                          END.
                     ELSE
                          DO:
                             tot_vlliquid = tot_vlliquid - s_vlsdeved[p_recid].
                             aux_contmax10 = aux_contmax10 - 1.
                          END.   
                 END.

            IF   s_wide   THEN
                 DISPLAY p_flag[p_recid] WITH FRAME pick2.
            ELSE
                 DISPLAY p_flag[p_recid] WITH FRAME pick1.

            PAUSE 0.

            IF   p_recid < s_chextent   THEN
                 DO:
                     p_recid = p_recid + 1.

                     IF   s_wide   THEN
                          DOWN WITH FRAME pick2.
                     ELSE
                          DOWN WITH FRAME pick1.
                 END.
        END.
   ELSE
   IF  (KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
        KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT") AND p_recid < s_chextent THEN
        DO:
            p_recid = p_recid + 1.

            IF   s_wide   THEN
                 DOWN WITH FRAME pick2.
            ELSE
                 DOWN WITH FRAME pick1.
        END.
   ELSE
   IF  (KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
        KEYFUNCTION(LASTKEY) = "CURSOR-LEFT") AND p_recid > 1   THEN
        DO:
            p_recid = p_recid - 1.

            IF   s_wide   THEN
                 UP WITH FRAME pick2.
            ELSE
                 UP WITH FRAME pick1.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "PAGE-DOWN"   THEN
        ASSIGN p_recid  = p_recid + p_down
               p_redraw = TRUE.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "PAGE-UP"   THEN
        ASSIGN p_recid  = p_recid - p_down
               p_redraw = TRUE.
   ELSE
   IF   CAN-DO("HOME,MOVE",KEYFUNCTION(LASTKEY)) AND p_recid > 1   THEN
        DO:
            ASSIGN p_recid  = 1
                   p_redraw = TRUE.

            IF   s_wide   THEN
                 UP FRAME-LINE(pick2) - 1 WITH FRAME pick2.
            ELSE
                 UP FRAME-LINE(pick1) - 1 WITH FRAME pick1.
        END.
   ELSE
   IF   CAN-DO("END,HOME,MOVE",KEYFUNCTION(LASTKEY))   THEN
        DO:
            ASSIGN p_recid  = s_chextent
                   p_redraw = TRUE.

            IF   s_wide   THEN
                 DOWN p_down - FRAME-LINE(pick2) WITH FRAME pick2.
            ELSE
                 DOWN p_down - FRAME-LINE(pick1) WITH FRAME pick1.
        END.
   ELSE
   IF   CAN-DO("GO,RETURN",KEYFUNCTION(LASTKEY))   THEN
        DO:
            ASSIGN s_chcnt  = (IF s_multiple THEN 0 ELSE 1)
                   s_choice = (IF s_multiple THEN -1 ELSE p_recid).

            DO p_recid = 1 TO s_chextent:

               IF   p_flag[p_recid]   THEN
                    ASSIGN s_chcnt = s_chcnt + 1
                           s_choice[s_chcnt] = p_recid.

            END.  /*  Fim do DO .. TO  */

            LEAVE _pick.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE _pick.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
        APPLY "HELP".
        
END.

ASSIGN s_row      = 0
       s_column   = 0
       s_title    = ""
       s_liquidac = "".

DO p_recid = 1 TO s_chextent:

   IF   p_flag[p_recid]   THEN
        s_liquidac = IF s_liquidac = ""
                        THEN STRING(p_recid)
                        ELSE s_liquidac + "," + STRING(p_recid).

END.  /*  Fim do DO .. TO  */

IF   s_hide   THEN
     DO:
         HIDE FRAME pick1 NO-PAUSE.
         HIDE FRAME pick2 NO-PAUSE.
     END.

HIDE FRAME type1 NO-PAUSE.
HIDE FRAME type2 NO-PAUSE.

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */
