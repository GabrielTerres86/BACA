/* .............................................................................

   Programa: Fontes/natnac.p.
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 16/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas (on-line)
   Objetivo  : Mostrar a lista de naturalidades/nacionalidades disponiveis.

   Alteracoes: 24/08/94 - Alterado para aumentar a naturalidade para 25 posi-
                          coes (Deborah).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/12/2013 - VALIDATE crapnac e crapnat (Carlos)

............................................................................. */

{ includes/var_online.i }
{ includes/natnac.i }

DEFINE VARIABLE p_down   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_flag   AS LOGICAL   INITIAL FALSE EXTENT 5000      NO-UNDO.
DEFINE VARIABLE p_line   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_recid  AS INTEGER   INITIAL 1                      NO-UNDO.
DEFINE VARIABLE p_redraw AS LOGICAL   INITIAL TRUE                   NO-UNDO.
DEFINE VARIABLE p_spot   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_typed  AS CHARACTER INITIAL ""                     NO-UNDO.

DEFINE VARIABLE p_cddopcao AS CHARACTER INIT "I"                     NO-UNDO.
DEFINE VARIABLE p_dsnatnac AS CHARACTER INIT ""                      NO-UNDO.

ASSIGN p_down   = MINIMUM(11,s_chextent)
       s_choice = -1
       s_chcnt  = 0
       s_row    = (IF s_row = 0    THEN 5 ELSE s_row)
      s_column = (IF s_column = 0 THEN (IF s_wide THEN 2 ELSE 48) ELSE s_column)
       s_title  = (IF s_title = "" THEN " Choices " ELSE s_title).

IF   s_chextent <= 0   THEN
     RETURN.

FORM p_flag[p_recid] FORMAT "* /  " SPACE(0) s_chlist[p_recid] FORMAT "x(26)"
     WITH FRAME pick1 SCROLL 1 OVERLAY NO-LABELS p_down DOWN
          ROW s_row COLUMN s_column TITLE COLOR MESSAGES s_title.

FORM p_flag[p_recid] FORMAT "* /  " SPACE(0) s_chlist[p_recid] FORMAT "x(70)"
     WITH FRAME pick2 SCROLL 1 OVERLAY NO-LABELS p_down DOWN
          ROW s_row COLUMN s_column TITLE COLOR MESSAGES s_title.

FORM p_typed FORMAT "x(28)"
     WITH FRAME type1 OVERLAY NO-LABELS ROW s_row + p_down + 2 COLUMN s_column.

FORM p_typed FORMAT "x(72)"
     WITH FRAME type2 OVERLAY NO-LABELS ROW s_row + p_down + 2 COLUMN s_column.

FORM p_cddopcao FORMAT "x"     LABEL "Opcao" AUTO-RETURN
                               VALIDATE(p_cddopcao = "I" OR p_cddopcao = "E",
                                        "014 - Opcao errada")
     p_dsnatnac FORMAT "x(25)" LABEL "  Descricao"
                               VALIDATE(p_dsnatnac <> "","Deve ser informada")
     WITH ROW s_row + 4 COLUMN s_column - 50
          SIDE-LABELS TITLE COLOR MESSAGES " Manutencao das" + s_title
          OVERLAY FRAME f_natnac.

MESSAGE "Escolha com as setas, pgant, pgseg e tecle <Entra>".
MESSAGE "Tecle F8 para manutencao das" s_title.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

_pick:
DO WHILE TRUE:

   p_recid = MINIMUM(s_chextent,MAXIMUM(p_recid,1)).

   IF   LENGTH(p_typed) > 0 THEN
        DO:
            PAUSE 0.
            IF   s_wide   THEN
                 DISPLAY p_typed WITH FRAME type2.
            ELSE
                 DISPLAY p_typed WITH FRAME type1.
        END.
   ELSE
        DO:
            HIDE FRAME type1 NO-PAUSE.
            HIDE FRAME type2 NO-PAUSE.
        END.

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
            p_flag[p_recid] = NOT p_flag[p_recid].

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
   IF   LASTKEY = KEYCODE("F8")   THEN
        DO:
            MANUTENCAO:

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE p_cddopcao WITH FRAME f_natnac.

               IF   p_cddopcao = "I"   THEN
                    IF   s_dbfilenm = "crapnac"   then
                         DO:
                             UPDATE p_dsnatnac WITH FRAME f_natnac.

                             p_dsnatnac = CAPS(p_dsnatnac).

                             IF   CAN-FIND(crapnac WHERE
                                           crapnac.dsnacion = p_dsnatnac)   THEN
                                  DO:
                                      BELL.
                                      MESSAGE "Nacionalidade ja existente".
                                      NEXT.
                                  END.

                             CREATE crapnac.
                             crapnac.dsnacion = p_dsnatnac.
                             VALIDATE crapnac.
                         END.
                    ELSE
                    IF   s_dbfilenm = "crapnat"   THEN
                         DO:
                             UPDATE p_dsnatnac WITH FRAME f_natnac.

                             p_dsnatnac = CAPS(p_dsnatnac).

                             IF   CAN-FIND(crapnat WHERE
                                           crapnat.dsnatura = p_dsnatnac)   THEN
                                  DO:
                                      BELL.
                                      MESSAGE "Naturalidade ja existente".
                                      NEXT.
                                  END.

                             CREATE crapnat.
                             crapnat.dsnatura = p_dsnatnac.
                             VALIDATE crapnat.
                         END.
                    ELSE
                         DO:
                             BELL.
                             MESSAGE "Nao sei o que devo incluir".
                         END.
               ELSE
               IF   p_cddopcao = "E"   THEN
                    IF   s_dbfilenm = "crapnac"   then
                         DO:
                             UPDATE p_dsnatnac WITH FRAME f_natnac.

                             DO WHILE TRUE:

                                FIND crapnac WHERE
                                     crapnac.dsnacion = p_dsnatnac
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF   NOT AVAILABLE crapnac   THEN
                                     IF   LOCKED crapnac   THEN
                                          DO:
                                              PAUSE 2 NO-MESSAGE.
                                              NEXT.
                                          END.
                                     ELSE
                                          DO:
                                              BELL.
                                              MESSAGE
                                                "Nacionalidade nao existente".
                                              NEXT MANUTENCAO.
                                          END.

                                LEAVE.

                             END.  /*  Fim do DO WHILE TRUE  */

                             DELETE crapnac.
                         END.
                    ELSE
                    IF   s_dbfilenm = "crapnat"   then
                         DO:
                             UPDATE p_dsnatnac WITH FRAME f_natnac.

                             DO WHILE TRUE:

                                FIND crapnat WHERE
                                     crapnat.dsnatura = p_dsnatnac
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF   NOT AVAILABLE crapnat   THEN
                                     IF   LOCKED crapnat   THEN
                                          DO:
                                              PAUSE 2 NO-MESSAGE.
                                              NEXT.
                                          END.
                                     ELSE
                                          DO:
                                              BELL.
                                              MESSAGE
                                                "Naturalidade nao existente".
                                              NEXT MANUTENCAO.
                                          END.

                                LEAVE.

                             END.  /*  Fim do DO WHILE TRUE  */

                             DELETE crapnat.
                         END.
                    ELSE
                         DO:
                             BELL.
                             MESSAGE "Nao sei o que devo excluir".
                             NEXT.
                         END.

               HIDE FRAME f_natnac NO-PAUSE.

               IF   s_dbfilenm = "crapnac"   THEN
                    FOR EACH crapnac NO-LOCK s_chextent = 1 TO 5000:
                        s_chlist[s_chextent] = crapnac.dsnacion.
                    END.
               ELSE
               IF   s_dbfilenm = "crapnat"   THEN
                    FOR EACH crapnat NO-LOCK s_chextent = 1 TO 5000:
                        s_chlist[s_chextent] = crapnat.dsnatura.
                    END.

               IF   p_cddopcao = "I"   THEN
                    DO:
                        DO p_line = 1 TO s_chextent:

                           IF   s_chlist[p_line] BEGINS p_dsnatnac   THEN
                                LEAVE.

                        END.  /*  Fim do DO .. TO  */

                        IF   p_line <= s_chextent   THEN
                             p_recid  = p_line.
                    END.

               p_redraw = TRUE.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE FRAME f_natnac NO-PAUSE.
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

END.

ASSIGN s_row    = 0
       s_column = 0
       s_title  = "".

IF   s_hide   THEN
     DO:
         HIDE FRAME pick1 NO-PAUSE.
         HIDE FRAME pick2 NO-PAUSE.
     END.

HIDE FRAME type1 NO-PAUSE.
HIDE FRAME type2 NO-PAUSE.

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */
