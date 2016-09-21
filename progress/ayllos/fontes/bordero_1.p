/* .............................................................................

   Programa: Fontes/bordero_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 02/01/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar BORDEROS DE DESCONTOS DE CHEQUES
               para a tela ATENDA.

   Alteracoes: 18/06/2004 - Incluida a opcao EXCLUIR (Edson).
   
               19/09/2006 - Alterado o nome da rotina e permitir o uso do
                            F2-AJUDA (Evandro).
                            
               10/08/2012 - Alterado nome do campo de "ANALISAR" para
                            "PRE-ANALISE" (Lucas).
                            
               27/12/2012 - Bloquear Alteracoes para Migracao AltoVale (Ze).
               
               02/01/2013 - Ignorar registro de cooperado migrado ALTO VALE.
                            (Fabricio).
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_bordero.i }

DEFINE VARIABLE p_down   AS INTEGER                          NO-UNDO.
DEFINE VARIABLE p_init   AS INTEGER            INITIAL ?     NO-UNDO.
DEFINE VARIABLE p_line   AS INTEGER                          NO-UNDO.
DEFINE VARIABLE p_recid  AS INTEGER            INITIAL 1     NO-UNDO.
DEFINE VARIABLE p_redraw AS LOGICAL            INITIAL TRUE  NO-UNDO.
DEFINE VARIABLE p_spot   AS INTEGER                          NO-UNDO.

DEFINE VARIABLE p_opcao  AS CHAR EXTENT 5 INIT
       ["Pre-Analise","Consultar","Excluir","Imprimir","Liberar"]  NO-UNDO.

DEFINE VARIABLE tab_cddopcao AS CHAR EXTENT 5 INIT
                                ["N","C","E","M","L"] NO-UNDO.

DEF VAR opcao AS INT NO-UNDO.

FORM SPACE(10)
     p_opcao[1] FORMAT "x(11)"
     p_opcao[2] FORMAT "x(9)"
     p_opcao[3] FORMAT "x(7)"
     p_opcao[4] FORMAT "x(8)"
     p_opcao[5] FORMAT "x(7)"
     SPACE(11)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM e_chlist[p_recid] FORMAT "x(70)"
     LABEL "     Data     Bordero   Contrato  Qt.Chqs           Valor  Situacao"
     WITH FRAME pick1 SCROLL 1 OVERLAY NO-LABELS NO-ATTR-SPACE NO-UNDERLINE
     p_down DOWN ROW 10 CENTERED TITLE COLOR NORMAL e_title.

FUNCTION cooperado-migrado RETURNS LOGICAL (INPUT par_nrctaant AS INT):

    FIND FIRST craptco WHERE craptco.cdcopant = glb_cdcooper  AND
                             craptco.nrctaant = par_nrctaant  AND
                             craptco.tpctatrf = 1             AND
                             craptco.flgativo = TRUE
                             NO-LOCK NO-ERROR.

    IF AVAIL craptco THEN
        RETURN TRUE.
    ELSE
        RETURN FALSE.

END FUNCTION.

ASSIGN e_choice = -1
       e_chcnt  = 0
       e_row    = (IF e_row = 0    THEN 5 ELSE e_row)
       e_column = (IF e_column = 0 THEN 10 ELSE e_column)
       e_title  = (IF e_title = "" THEN " Choices " ELSE e_title)
       p_down   = 7.

IF   e_init <> ""   THEN
     DO:
         DO p_spot = 1 TO e_chextent:
            IF e_init = e_chlist[p_spot] THEN LEAVE.
         END.

         IF   p_spot <= e_chextent THEN
              ASSIGN p_init  = MINIMUM(p_down,p_spot)
                     p_recid = p_spot.
     END.

IF   e_chextent > 0   THEN
     opcao = 1.      /*  Consulta  */
ELSE
     opcao = 1.      /*  Consulta  */

COLOR DISPLAY MESSAGE p_opcao[opcao] WITH FRAME f_opcoes.
DISPLAY p_opcao WITH FRAME f_opcoes.

_pick:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   p_recid = MINIMUM(e_chextent,MAXIMUM(p_recid,1)).

   IF   p_redraw   THEN
        DO:
            ASSIGN p_line = MAXIMUM(1, FRAME-LINE(pick1))
                p_spot = p_recid - (IF p_init = ? THEN p_line ELSE p_init) + 1.

            UP p_line - 1 WITH FRAME pick1.

            IF   p_spot < 1 THEN
                 ASSIGN p_spot  = 1
                        p_line  = 1
                        p_recid = 1.

            DO e_chcnt = p_spot TO p_spot + p_down - 1:

               IF   e_chcnt > e_chextent THEN
                    CLEAR FRAME pick1 NO-PAUSE.
               ELSE
                    DISPLAY e_chlist[e_chcnt] @ e_chlist[p_recid]
                            WITH FRAME pick1.

               IF   e_chcnt < p_spot + p_down - 1 THEN
                    DOWN WITH FRAME pick1.
            END.

            p_line = (IF p_init = ? THEN p_line /*1*/ ELSE p_init).

            UP p_down - p_line WITH FRAME pick1.

            ASSIGN p_init   = ?
                   e_chcnt  = 0
                   p_redraw = FALSE.
        END.

   IF   e_chextent > 0   THEN
        DO:
            DISPLAY e_chlist[p_recid] WITH FRAME pick1.

            COLOR DISPLAY MESSAGES e_chlist[p_recid] WITH FRAME pick1.
        END.

   READKEY.

   IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
        KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"    OR
        KEYFUNCTION(LASTKEY) = "HOME"           OR
        KEYFUNCTION(LASTKEY) = "PAGE-UP"        OR
        KEYFUNCTION(LASTKEY) = "PAGE-DOWN"      THEN
        IF   e_chextent > 0   THEN
             COLOR DISPLAY NORMAL e_chlist[p_recid] WITH FRAME pick1.
        ELSE
             NEXT.

   PAUSE 0.

   IF   CAN-DO("RETURN,PICK",KEYFUNCTION(LASTKEY)) AND e_multiple THEN
        DO:
            PAUSE 0.
            IF   p_recid < e_chextent THEN
                 DO:
                     p_recid = p_recid + 1.
                     IF   FRAME-LINE(pick1) = FRAME-DOWN(pick1) THEN
                          SCROLL UP WITH FRAME pick1.
                     ELSE
                          DOWN WITH FRAME pick1.
                 END.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" AND p_recid < e_chextent THEN
        DO:
            p_recid = p_recid + 1.
            IF   FRAME-LINE(pick1) = FRAME-DOWN(pick1) THEN
                 SCROLL UP WITH FRAME pick1.
            ELSE
                 DOWN WITH FRAME pick1.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP" AND p_recid > 1 THEN
        DO:
            p_recid = p_recid - 1.
            IF   FRAME-LINE(pick1) = 1 THEN
                 SCROLL DOWN WITH FRAME pick1.
            ELSE
                 UP WITH FRAME pick1.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "PAGE-DOWN" THEN
        ASSIGN p_recid  = p_recid + p_down
               p_redraw = TRUE.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "PAGE-UP" THEN
        ASSIGN p_recid  = p_recid - p_down
               p_redraw = TRUE.
   ELSE
   IF   CAN-DO("HOME,MOVE",KEYFUNCTION(LASTKEY)) AND p_recid > 1 THEN
        DO:
            ASSIGN p_recid  = 1
                   p_redraw = TRUE.
            UP FRAME-LINE(pick1) - 1 WITH FRAME pick1.
        END.
   ELSE
   IF   CAN-DO("END,HOME,MOVE",KEYFUNCTION(LASTKEY)) THEN
        DO:
            ASSIGN p_recid  = e_chextent
                   p_redraw = TRUE.
            DOWN p_down - FRAME-LINE(pick1) WITH FRAME pick1.
        END.
   ELSE
   IF   CAN-DO("GO,RETURN",KEYFUNCTION(LASTKEY))   THEN
        DO:
            ASSIGN e_chcnt  = (IF e_multiple THEN 0 ELSE 1)
                   e_choice = (IF e_multiple THEN -1 ELSE p_recid)
                   glb_cddopcao = tab_cddopcao[opcao].
            
            ASSIGN glb_cddopcao = tab_cddopcao[opcao]
                   glb_nmrotina = "DSC CHQS - BORDERO".
            
            { includes/acesso.i }
                        
            IF   e_chextent = 0   THEN
                 IF   tab_cddopcao[opcao] <> "I"   THEN
                      NEXT.

            IF   opcao = 1   AND   e_chextent > 0   THEN
                 DO:
                    IF cooperado-migrado(INPUT tel_nrdconta) THEN
                    DO:
                        MESSAGE "Conta migrada.".
                        NEXT.
                    END.
                     
                     RUN fontes/bordero_ln.p (INPUT e_recid[e_choice[e_chcnt]],
                                              INPUT "N").
                     p_init = ?.
                     p_redraw = TRUE.
                 END.
            ELSE
            IF   opcao = 2   AND   e_chextent > 0   THEN
                 RUN fontes/bordero_c.p (INPUT e_recid[e_choice[e_chcnt]]).
            ELSE
            IF   opcao = 3   AND   e_chextent > 0   THEN
                 DO:
                    IF cooperado-migrado(INPUT tel_nrdconta) THEN
                    DO:
                        MESSAGE "Conta migrada.".
                        NEXT.
                    END.

                     RUN fontes/bordero_e.p (INPUT e_recid[e_choice[e_chcnt]]).
                     p_init = ?.
                     p_redraw = TRUE.
                 END.
            ELSE
            IF   opcao = 4   AND   e_chextent > 0   THEN
                 RUN fontes/bordero_m.p (INPUT e_recid[e_choice[e_chcnt]],
                                         INPUT 0).
            ELSE
            IF   opcao = 5   AND   e_chextent > 0   THEN
                 DO:
                    IF cooperado-migrado(INPUT tel_nrdconta) THEN
                    DO:
                        MESSAGE "Conta migrada.".
                        NEXT.
                    END.
                     
                     RUN fontes/bordero_ln.p (INPUT e_recid[e_choice[e_chcnt]],
                                              INPUT "L").
                     p_init = ?.
                     p_redraw = TRUE.
                 END.

            NEXT _pick.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   OR
        KEYFUNCTION(LASTKEY) = " "              THEN
        DO:
            COLOR DISPLAY NORMAL p_opcao[opcao] WITH FRAME f_opcoes.
            opcao = opcao + 1.
            IF   opcao > 5   THEN
                 opcao = 1.
            COLOR DISPLAY MESSAGES p_opcao[opcao] WITH FRAME f_opcoes.

            DISPLAY p_opcao WITH FRAME f_opcoes.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            COLOR DISPLAY NORMAL p_opcao[opcao] WITH FRAME f_opcoes.
            opcao = opcao - 1.
            IF   opcao < 1   THEN
                 opcao = 5.
            COLOR DISPLAY MESSAGES p_opcao[opcao] WITH FRAME f_opcoes.

            DISPLAY p_opcao WITH FRAME f_opcoes.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        LEAVE _pick.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
        APPLY "HELP".

   p_line = 1.

END.

HIDE FRAME pick1 NO-PAUSE.
HIDE FRAME f_opcoes NO-PAUSE.

/* .......................................................................... */
