/* .............................................................................

   Programa: Fontes/aplicacoes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/95.                          Ultima atualizacao: 28/05/2007

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas (on-line)
   Objetivo  : Mostrar a lista de lay-out de telas.

   Alteracoes: 21/09/65 - Alterado para mostrar em ordem de data no F7
                          (Deborah).

               26/11/96 - Tratar RDCAII (Odair).

               14/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               25/01/06 - Unificacao dos Bancos - SQLWorks - Luciane
               
               28/05/2007 - Adequacao para as modalidades de aplicacao RDC
                            (Evandro).

............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_nraplica AS INT                                 NO-UNDO.

{ includes/ctremp.i "NEW" }

DEF VAR tab_nraplica     AS INT       EXTENT 400                     NO-UNDO.

DEF VAR rel_dsaplica     AS CHAR    FORMAT "x(06)"                   NO-UNDO.

DEFINE VARIABLE p_down   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_flag   AS LOGICAL   INITIAL FALSE EXTENT 5000      NO-UNDO.
DEFINE VARIABLE p_line   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_recid  AS INTEGER   INITIAL 1                      NO-UNDO.
DEFINE VARIABLE p_redraw AS LOGICAL   INITIAL TRUE                   NO-UNDO.
DEFINE VARIABLE p_spot   AS INTEGER                                  NO-UNDO.
DEFINE VARIABLE p_typed  AS CHARACTER INITIAL ""                     NO-UNDO.

DEF VAR aux_nrctatos AS INT NO-UNDO.

ASSIGN s_chextent   = 0
       s_chlist     = ""
       aux_nrctatos = 0

       s_row      = 10
       s_column   = 15
       s_hide     = TRUE
       s_title    = " Aplicacoes "
       s_dbfilenm = "craprda"
       s_multiple = FALSE
       s_wide     = TRUE.

/*  Leitura dos contratos de emprestimos  */

FOR EACH craprda WHERE craprda.cdcooper = par_cdcooper  AND 
                       craprda.nrdconta = par_nrdconta  NO-LOCK
                       BY craprda.dtmvtolt :

    IF   craprda.tpaplica = 3   THEN
         rel_dsaplica = " RDCA ".
    ELSE
    IF   craprda.tpaplica = 5   THEN
         rel_dsaplica = "RDCA60".
    ELSE
         DO:
             /* Novas modalidades RDC */
             FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper       AND
                                crapdtc.tpaplica = craprda.tpaplica
                                NO-LOCK NO-ERROR.
                                   
             rel_dsaplica = IF   AVAILABLE crapdtc   THEN
                                 crapdtc.dsaplica
                            ELSE "".
         END.

    
    ASSIGN aux_nrctatos = aux_nrctatos + 1
           tab_nraplica[aux_nrctatos] = craprda.nraplica

           s_chextent           = s_chextent + 1
           s_chlist[s_chextent] = STRING(craprda.nraplica,"zzz,zz9") + " " +
                                  STRING(craprda.dtmvtolt,"99/99/9999") + " " +
                                  rel_dsaplica                      + " " +
                                  STRING(craprda.vlaplica,"zzz,zzz,zz9.99").

END.  /*  Fim do FOR EACH  --  Leitura dos contratos de emprestimos  */

ASSIGN p_down   = MINIMUM(9,s_chextent)
       s_choice = -1
       s_chcnt  = 0
       s_row    = (IF s_row = 0    THEN 5 ELSE s_row)
      s_column = (IF s_column = 0 THEN (IF s_wide THEN 2 ELSE 48) ELSE s_column)
       s_title  = (IF s_title = "" THEN " Choices " ELSE s_title).

FORM p_flag[p_recid] FORMAT "* /  " SPACE(0) s_chlist[p_recid] FORMAT "x(7)"
     WITH FRAME pick1 SCROLL 1 OVERLAY NO-LABELS p_down DOWN
          ROW s_row COLUMN s_column TITLE COLOR MESSAGES s_title.

FORM p_flag[p_recid] FORMAT "* /  " SPACE(0) s_chlist[p_recid] FORMAT "x(43)"
     WITH FRAME pick2 SCROLL 1 OVERLAY NO-LABELS p_down DOWN
          ROW s_row CENTERED TITLE COLOR MESSAGES s_title.

FORM p_typed FORMAT "x(9)"
     WITH FRAME type1 OVERLAY NO-LABELS ROW s_row + p_down + 2 COLUMN s_column.

FORM p_typed FORMAT "x(43)"
     WITH FRAME type2 OVERLAY NO-LABELS ROW s_row + p_down + 2 COLUMN s_column.

IF   aux_nrctatos > 1   THEN
     MESSAGE "Escolha com as setas, pgant, pgseg e tecle <Entra>".

_pick:
DO WHILE TRUE:

   IF   aux_nrctatos = 0   THEN
        LEAVE.

   IF   aux_nrctatos = 1   THEN
        DO:
            par_nraplica = tab_nraplica[aux_nrctatos].
            LEAVE.
        END.

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

IF   aux_nrctatos > 1   THEN
     IF   s_chcnt > 0   THEN
           par_nraplica = tab_nraplica[s_choice[s_chcnt]].

/* .......................................................................... */

