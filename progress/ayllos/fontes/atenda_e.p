/* .............................................................................

   Programa: fontes/atenda_e.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/94.                            Ultima atualizacao: 16/10/97

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina que gera extratos da tela ATENDA.

   Alteracoes: 29/08/97 - Alterado para tratar o extrato de FOLHA (Odair).

               16/10/97 - Alterado para mostrar a data de liberacao nos
                          depositos bloqueados (Edson).

............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }

DEF VAR aux_flgretor AS LOGICAL                                      NO-UNDO.
DEF VAR aux_regexist AS LOGICAL                                      NO-UNDO.

FORM crawext.dtmvtolt AT  2 LABEL "   Data"
     crawext.dshistor AT 14 LABEL "Historico"
     crawext.nrdocmto AT 41 LABEL " Documento"
     crawext.indebcre AT 53 LABEL "D/C"
     crawext.vllanmto AT 57 LABEL "Valor"
     WITH ROW 9 CENTERED OVERLAY 9 DOWN TITLE " Extrato " FRAME f_lanctos.

ASSIGN aux_flgretor = FALSE
       aux_regexist = FALSE
       aux_contador = 0.

CLEAR FRAME f_lanctos ALL NO-PAUSE.

FOR EACH crawext NO-LOCK.

    ASSIGN aux_regexist = TRUE
           aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         IF   aux_flgretor   THEN
              DO:
                  PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar.".
                  CLEAR FRAME f_lanctos ALL NO-PAUSE.
              END.

    PAUSE (0).

    IF   crawext.dtmvtolt = 01/01/9999 THEN
         DISPLAY "FOLHA" @ crawext.dtmvtolt
                  crawext.dshistor
                  crawext.nrdocmto crawext.indebcre crawext.vllanmto
                  WITH FRAME f_lanctos.
    ELSE
         DISPLAY
            crawext.dtmvtolt
            crawext.dshistor
            crawext.nrdocmto crawext.indebcre crawext.vllanmto
            WITH FRAME f_lanctos.

    IF   aux_contador = 9   THEN
         ASSIGN aux_contador = 0
                aux_flgretor = TRUE.
    ELSE
         DOWN WITH FRAME f_lanctos.

END.  /*  Fim do FOR EACH  */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 81.
         RUN fontes/critic.p.
         CLEAR FRAME f_lanctos ALL NO-PAUSE.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         PAUSE 2 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         RETURN.
     END.


IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <Entra> para continuar ou <Fim> para encerrar.".
        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_lanctos NO-PAUSE.

/* .......................................................................... */
