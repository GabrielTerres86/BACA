/* .............................................................................

   Programa: Fontes/sol044.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94                      Ultima Atualizacao: 02/02/2006 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL044 (Cem maiores devedores)

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_tprelato AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 44           NO-UNDO.

FORM
SKIP (4)
glb_cddopcao AT 20 LABEL "Opcao         " AUTO-RETURN
                   HELP "Entre com a opcao desejada (A,C,E ou I)"
                   VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                             glb_cddopcao = "E" OR glb_cddopcao = "I",
                             "014 - Opcao errada.")

SKIP  (1)
tel_nrseqsol AT 20 LABEL "Sequencia     " AUTO-RETURN
                   HELP "Entre com o numero de sequencia da solicitacao."
                   VALIDATE (tel_nrseqsol > 0,
                             "117 - Sequencia errada.")

SKIP (1)
tel_tprelato AT 20 LABEL "Tipo relatorio" AUTO-RETURN
           HELP "Tipo: 1 - emprestimos, 2 - conta-corrente, 3 - ambos"
                   VALIDATE (tel_tprelato = 1 or tel_tprelato = 2 or
                             tel_tprelato = 3,"170 - Selecao errada.")

SKIP(1)
tel_nrdevias AT 20 LABEL "Numero de vias" AUTO-RETURN
                   HELP "Entre com o numero de vias desejadas."
                   VALIDATE (tel_nrdevias > 0, "119 - Numero de vias errado.")

SKIP(5)
WITH ROW 4 COLUMN 1 OVERLAY TITLE COLOR MESSAGE tel_dstitulo
     SIDE-LABELS NO-ATTR-SPACE WIDTH 80 FRAME f_sol044.

glb_cddopcao = "I".

FIND craprel WHERE craprel.cdcooper = glb_cdcooper  AND 
                   craprel.cdrelato = 71            NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craprel   THEN
     ASSIGN tel_dstitulo = FILL("?",40).
ELSE
     ASSIGN tel_dstitulo = " " + craprel.nmrelato + " ".

RELEASE craprel.

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol044.
        NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol044.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           PROMPT-FOR glb_cddopcao tel_nrseqsol WITH FRAME f_sol044.
           LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL044"   THEN
                      DO:
                          HIDE FRAME f_sol044.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN tel_nrseqsol = INPUT tel_nrseqsol
               aux_nrseqsol = INPUT tel_nrseqsol
               glb_cddopcao = INPUT glb_cddopcao.

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 { includes/sol044a.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      { includes/sol044c.i }
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E"   THEN
                       DO:
                           { includes/sol044e.i }
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I"   THEN
                            DO:
                                { includes/sol044i.i }
                            END.
END.

/* .......................................................................... */
