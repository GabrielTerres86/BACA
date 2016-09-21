/* .............................................................................

   Programa: Fontes/sol001.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                         Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL001.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrsolici            LIKE crapsol.nrsolici         NO-UNDO.
DEF        VAR tel_nrseqsol            LIKE crapsol.nrseqsol         NO-UNDO.

DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SKIP (3)
     "Opcao:"         AT 6
     glb_cddopcao     AT 13 NO-LABEL AUTO-RETURN
                      HELP "Entre com a opcao desejada"
                      VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                glb_cddopcao = "E" OR glb_cddopcao = "I",
                                "014 - Opcao errada.")
     SKIP (1)
     tel_nrsolici     AT 5 AUTO-RETURN
                      HELP "Entre com o numero da solicitacao."
                      VALIDATE (tel_nrsolici > 0,
                                "116 - Numero da solicitacao errado.")
     tel_nrseqsol     AT 31 AUTO-RETURN
                      HELP "Entre com a sequencia da solicitacao."
                      VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP (1)
     crapsol.cdempres AT 4 AUTO-RETURN
                      HELP "Entre com o codigo da empresa."
                      VALIDATE (cdempres = 0 OR
                      CAN-FIND(crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                                             crapemp.cdempres = INPUT cdempres),
                               "040 - Empresa nao cadastrada.")
     SKIP (1)
     crapsol.nrdevias AT 7 AUTO-RETURN
                      HELP "Entre com o numero de vias."
     SKIP (1)
     crapsol.dsparame AT 2 AUTO-RETURN
     SKIP(4)
     WITH SIDE-LABELS TITLE COLOR MESSAGE " Solicitacao Geral "
          ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_sol001.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol001.
        NEXT-PROMPT tel_nrsolici WITH FRAME f_sol001.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PROMPT-FOR glb_cddopcao tel_nrsolici tel_nrseqsol
                            WITH FRAME f_sol001.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL001"   THEN
                      DO:
                          HIDE FRAME f_sol001.
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

        ASSIGN tel_nrsolici = INPUT tel_nrsolici
               tel_nrseqsol = INPUT tel_nrseqsol
               glb_cddopcao = INPUT glb_cddopcao.

        aux_dsacesso = STRING(tel_nrsolici,"zz9")  +
                       STRING(tel_nrseqsol,"z9").

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 { includes/sol001a.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      { includes/sol001c.i }
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E"   THEN
                       DO:
                           { includes/sol001e.i }
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I"   THEN
                            DO:
                                { includes/sol001i.i }
                            END.
END.

/* .......................................................................... */
