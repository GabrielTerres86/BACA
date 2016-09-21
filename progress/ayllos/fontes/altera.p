/* .............................................................................

   Programa: Fontes/altera.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/94.                       Ultima atualizacao: 28/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ALTERA.

   Alteracao : 04/03/98 - Tratar datas (Odair).

               23/11/98 - Acerto na rotina (Deborah).

             03/09/2004 - Tratar conta integracao (Margarete).

             25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
             
             02/10/2006 - Alterado help do campo "Conta/dv" (Elton). 

             29/12/2008 - Usar includes/sititg.i para situacao da Conta 
                          Integracao (Gabriel).
                          
             28/06/2011 - Alterado para utilizar a procedure busca-alteracoes
                          na b1wgen0031 (Henrique).
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0031tt.i }
/* Devido tt-erro */
{ sistema/generico/includes/var_internet.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_lnaltera AS CHAR    FORMAT "x(41)"                NO-UNDO.
DEF        VAR tel_tpaltera AS CHAR    FORMAT "x(12)"                NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_nrdctitg AS CHAR    FORMAT "9.999.999-X"          NO-UNDO.
DEF        VAR tel_dssititg AS CHAR    FORMAT "x(07)"                NO-UNDO.
                                                             
DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_indesloc AS INT                                   NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0031 AS HANDLE                                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     tel_nrdconta     AT  2 LABEL "Conta/dv" FORMAT "zzzz,zzz,9" AUTO-RETURN
                            HELP "Informe o numero da conta."

     tel_nmprimtl     AT 27 FORMAT "x(40)" LABEL "Titular"
     tel_nrdctitg     AT 25 LABEL "Conta/ITG" 
     tel_dssititg     NO-LABEL    
     SKIP 
     "Data Alt.  T Dados Alterados/Incluidos" AT 2
     "Operador"                               AT 58
     SKIP(1)
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_altera.

FORM tel_lnaltera AT  2 FORMAT "x(76)"
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta WITH FRAME f_altera.

      CLEAR FRAME f_lanctos ALL NO-PAUSE.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0
             tel_lnaltera = "".

      RUN fontes/digfun.p.
                        
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_altera NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "ALTERA"   THEN
                 DO:
                     HIDE FRAME f_altera.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

    RUN sistema/generico/procedures/b1wgen0031.p PERSISTENT SET h-b1wgen0031.

    RUN busca-alteracoes IN h-b1wgen0031 (INPUT  glb_cdcooper,
                                          INPUT  tel_nrdconta,
                                          OUTPUT tel_nmprimtl,
                                          OUTPUT tel_nrdctitg,
                                          OUTPUT tel_dssititg,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-crapalt).

    DELETE PROCEDURE h-b1wgen0031.
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                MESSAGE tt-erro.dscritic.

            NEXT.

        END.

    DISPLAY tel_nmprimtl tel_nrdctitg tel_dssititg WITH FRAME f_altera.

    CLEAR FRAME f_lanctos ALL NO-PAUSE.
    
    FOR EACH tt-crapalt NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1
               aux_indesloc = 41.

        IF  aux_contador = 1 THEN
            IF  aux_flgretor  THEN
                DO: 
                    PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
                END.
            ELSE
                aux_flgretor = TRUE.

        PAUSE (0).

        tel_lnaltera = STRING(tt-crapalt.dtaltera,"99/99/9999") + " " +
                       tt-crapalt.tpaltera + " " +
                       STRING(SUBSTRING(tt-crapalt.dsaltera,001,041),"x(41)")
                       + "  " + tt-crapalt.nmoperad.
                     
        DISPLAY tel_lnaltera WITH FRAME f_lanctos.

        IF  aux_contador = 11   THEN
            aux_contador = 0.
        ELSE
        IF  aux_indesloc > LENGTH(tt-crapalt.dsaltera)   THEN
            IF  aux_contador < 10   THEN
                DO:
                    aux_contador = aux_contador + 1.
                    DOWN 2 WITH FRAME f_lanctos.
                END.
            ELSE
                DO:
                    aux_contador = 0.
                    DOWN WITH FRAME f_lanctos.
                END.
        ELSE
            DOWN WITH FRAME f_lanctos.

        IF  LENGTH(tt-crapalt.dsaltera) > 41   THEN
            DO WHILE aux_indesloc < LENGTH(tt-crapalt.dsaltera):

                aux_contador = aux_contador + 1.

                IF  aux_contador = 1 THEN
                    IF  aux_flgretor  THEN
                        DO:
                            PAUSE MESSAGE
                           "Tecle <Entra> para continuar ou <Fim> para encerrar".
                            CLEAR FRAME f_lanctos ALL NO-PAUSE.
                        END.
                    ELSE
                        aux_flgretor = TRUE.

                PAUSE (0).

                ASSIGN tel_lnaltera = FILL(" ",13) + 
                                      SUBSTRING(tt-crapalt.dsaltera,
                                     aux_indesloc + 1,41) + FILL(" ",22)

                       aux_indesloc = aux_indesloc + 41.

                DISPLAY tel_lnaltera WITH FRAME f_lanctos.

                IF  aux_contador = 11   THEN
                    aux_contador = 0.
                ELSE
                IF  aux_indesloc > LENGTH(tt-crapalt.dsaltera)   THEN
                    IF  aux_contador < 10   THEN
                        DO:
                            aux_contador = aux_contador + 1.
                            DOWN 2 WITH FRAME f_lanctos.
                        END.
                    ELSE
                        DO:
                            aux_contador = 0.
                            DOWN WITH FRAME f_lanctos.
                        END.
                ELSE
                    DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do DO WHILE  */
    END. /* FIM FOR EACH tt-crapalt */
                                                                
    ASSIGN aux_flgretor = FALSE
           aux_contador = 0.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
