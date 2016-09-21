/* .............................................................................

   Programa: Fontes/sol020.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                        Ultima Atualizacaco:02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL020.
  
   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 20           NO-UNDO.

FORM SKIP (5)
     glb_cddopcao AT 20 LABEL "Opcao         " AUTO-RETURN
                  HELP "Entre com a opcao desejada (A,C,E ou I)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")

     SKIP  (1)
     tel_nrseqsol AT 20 LABEL "Sequencia     " AUTO-RETURN
                  HELP "Entre com o numero de sequencia da solicitacao."
                  VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")

     SKIP(1)
     tel_nrdevias AT 20 LABEL "Numero de vias" AUTO-RETURN
                  HELP "Entre com o numero de vias desejadas."
                  VALIDATE (tel_nrdevias > 0, "119 - Numero de vias errado.")

     SKIP (6)

     WITH ROW 4 COLUMN 1 OVERLAY TITLE COLOR MESSAGE tel_dstitulo
          SIDE-LABELS NO-ATTR-SPACE WIDTH 80 FRAME f_sol020.

glb_cddopcao = "I".

FIND craprel WHERE craprel.cdcooper = glb_cdcooper  AND
                   craprel.cdrelato = 28            NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craprel   THEN
     ASSIGN tel_dstitulo = FILL("?",40).
ELSE
     ASSIGN tel_dstitulo = " " + craprel.nmrelato + " ".

RELEASE craprel.

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol020.
        NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol020.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           PROMPT-FOR glb_cddopcao tel_nrseqsol WITH FRAME f_sol020.
           LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL020"   THEN
                      DO:
                          HIDE FRAME f_sol020.
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
                 { includes/sol020a.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      { includes/sol020c.i }
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E"   THEN
                       DO:
                           { includes/sol020e.i }
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I"   THEN
                            DO:
                                { includes/sol020i.i }
                            END.
END.

/* .......................................................................... */
