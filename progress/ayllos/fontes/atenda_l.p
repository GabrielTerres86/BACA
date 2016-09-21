/* .............................................................................

   Programa: fontes/atenda_l.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah      
   Data    : Marco/99                            Ultima atualizacao: 30/03/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina que gera extratos da tela ATENDA.

   Alteracoes: 30/03/2007 - Tratamento para poder usar o F2-AJUDA (Evandro).

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

FOR EACH crawext NO-LOCK BY crawext.dtmvtolt:

    ASSIGN aux_regexist = TRUE
           aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         IF   aux_flgretor   THEN
              DO WHILE TRUE:
              
                 MESSAGE COLOR NORMAL "Tecle <Entra> para continuar ou"
                                      "<Fim> para encerrar.".
                 READKEY.
                 
                 IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
                      DO:
                          APPLY "HELP".
                          NEXT.
                      END.
                 ELSE
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      do:
                          hide message no-pause.
                          HIDE FRAME f_lanctos NO-PAUSE.
                          return.
                      end.
                 ELSE
                      CLEAR FRAME f_lanctos ALL NO-PAUSE.
                      
                 LEAVE.
              END.

    PAUSE (0).

    IF   crawext.dtmvtolt = 01/01/1099 THEN
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
     DO WHILE TRUE:
              
        MESSAGE COLOR NORMAL "Tecle <Entra> para continuar ou"
                             "<Fim> para encerrar.".
        READKEY.
                 
        IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
             DO:
                 APPLY "HELP".
                 NEXT.
             END.
                     
        LEAVE.
     END.

HIDE MESSAGE NO-PAUSE.
HIDE FRAME f_lanctos NO-PAUSE.

/* .......................................................................... */
