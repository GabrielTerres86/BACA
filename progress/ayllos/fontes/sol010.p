/* .............................................................................

   Programa: Fontes/sol010.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                        Ultima atualizacao: 15/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL010.

   Alteracoes: 31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

              01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
              
              15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_tprelato AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_indclass AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_inoqlist AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_nrviadef AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_nrviamax AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 10           NO-UNDO.

FORM SKIP (1)
     glb_cddopcao AT 15 LABEL "Opcao        " AUTO-RETURN
                  HELP "Entre com a opcao desejada (A,C,E ou I) - SEXTA-FEIRA"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")

     tel_nrseqsol AT 33 LABEL "Sequencia" AUTO-RETURN
                  HELP "Entre com o numero de sequencia da solicitacao."
                  VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")

     SKIP (1)
     tel_tprelato AT 15 LABEL "Selecao      " AUTO-RETURN
                  HELP "Entre com a selecao de relatorio."
                  VALIDATE (tel_tprelato >= 1 AND tel_tprelato <= 3,
                            "170 - Selecao errada.")

     "1 - Geral"             AT 33
     "2 - Geral por PA"     AT 33
     "3 - Geral por Empresa" AT 33

     SKIP (1)
     tel_indclass AT 15 LABEL "Classificacao" AUTO-RETURN
                  HELP "Entre com o tipo de classificacao desejada."
                  VALIDATE (tel_indclass >= 1 AND tel_indclass <= 3,
                            "171 - Classificacao errada.")

     "1 - Alfabetica"            AT 33
     "2 - Numerica por conta"    AT 33
     "3 - Numerica por cadastro" AT 33

     SKIP(1)
     tel_inoqlist AT 15 LABEL "O que listar " AUTO-RETURN
                  HELP "Entre com o escopo do relatorio"
                  VALIDATE (tel_inoqlist >= 1 AND tel_inoqlist <= 3,
                            "014 - Opcao errada.")

     "1 - Todos os associados"             AT 33
     "2 - Somente os ativos"               AT 33
     "3 - Somente os inativos (Demitidos)" AT 33

     SKIP(1)
     tel_nrdevias AT 15 LABEL "Em quantas vias" AUTO-RETURN
                  HELP "Entre com o numero de vias desejadas."
                  VALIDATE (tel_nrdevias <= tel_nrviamax,
                            "119 - Numero de vias errado.")

     "Na omissao assume " AT 36

     tel_nrviadef         AT 54 NO-LABEL
     "via(s), max."       AT 57
     tel_nrviamax         AT 70 NO-LABEL
     "via(s)"

     WITH ROW 4 COLUMN 1 OVERLAY TITLE COLOR MESSAGE tel_dstitulo
          SIDE-LABELS NO-ATTR-SPACE WIDTH 80 FRAME f_sol010.

glb_cddopcao = "I".

FIND craprel WHERE craprel.cdcooper = glb_cdcooper AND
                   craprel.cdrelato = 18 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craprel   THEN
     ASSIGN tel_nrviamax = 0
            tel_nrviadef = 0
            tel_dstitulo = FILL("?",40).
ELSE
     ASSIGN tel_nrviamax = craprel.nrviamax
            tel_nrviadef = craprel.nrviadef
            tel_dstitulo = " " + craprel.nmrelato + " ".

RELEASE craprel.

DO ~WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao tel_nrviadef tel_nrviamax WITH FRAME f_sol010.
        NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol010.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           PROMPT-FOR glb_cddopcao tel_nrseqsol WITH FRAME f_sol010.

           /*
           IF   WEEKDAY(glb_dtmvtolt) <> 6   THEN
                DO:
                    glb_cdcritic = 316.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

           */
           LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL010"   THEN
                      DO:
                          HIDE FRAME f_sol010.
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
                 { includes/sol010a.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      { includes/sol010c.i }
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E"   THEN
                       DO:
                           { includes/sol010e.i }
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I"   THEN
                            DO:
                                { includes/sol010i.i }
                            END.
END.

/* .......................................................................... */
