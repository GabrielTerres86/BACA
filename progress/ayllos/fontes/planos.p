/* .............................................................................

   Programa: Fontes/planos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92.                           Ultima atualizacao: 31/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PLANOS.

   Alteracoes: 06/12/96 - Mostrar na tela se o plano e vinculado a folha ou e
                          debito em conta (Odair).

               03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dssitpla AS CHAR    FORMAT "x(16)"                NO-UNDO.
DEF        VAR tel_dsdplano AS CHAR    FORMAT "x(16)"                NO-UNDO.

DEF        VAR tel_dsdlinha AS CHAR    FORMAT "x(75)"                NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "zzz,zzz,9"            NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtcancel AS CHAR    FORMAT "x(10)"                NO-UNDO.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Contratos de Planos "
                      FRAME f_moldura.

FORM "Conta/dv.:" AT 2
     tel_nrdconta AT 13 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado"
     "Titular:"   AT 24
     tel_nmprimtl AT 33 NO-LABEL
     SKIP(1)
  "Tipo/Situacao     Inic/Canc   Prest/Acumulado      Contrato   Min  Max  Pag"
                  AT 3
     WITH SIDE-LABELS ROW 6 COLUMN 2 OVERLAY NO-BOX FRAME f_planos.

FORM tel_dsdlinha     AT  3
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE (0).

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdconta WITH FRAME f_planos.

      ASSIGN aux_nrdconta = tel_nrdconta
             glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_planos.
           END.
      ELSE
           DO:
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                                  crapass.nrdconta = tel_nrdconta
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    DO:
                        glb_cdcritic = 9.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_planos.
                    END.
           END.

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_planos NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               tel_nrdconta = aux_nrdconta.
               DISPLAY tel_nrdconta WITH FRAME f_planos.
               NEXT.
           END.

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PLANOS"   THEN
                 DO:
                     HIDE FRAME f_planos.
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

   ASSIGN tel_nmprimtl = crapass.nmprimtl
          aux_contador = 0
          aux_regexist = FALSE
          aux_flgretor = FALSE.

   RELEASE crapass.

   DISPLAY tel_nmprimtl WITH frame f_planos.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   FOR EACH crappla WHERE crappla.cdcooper = glb_cdcooper   AND 
                          crappla.nrdconta = tel_nrdconta   AND
                          crappla.cdsitpla <> 9 NO-LOCK USE-INDEX crappla3:

       ASSIGN aux_regexist = TRUE
              aux_contador = aux_contador + 1.

       IF   aux_contador = 1 THEN
            IF   aux_flgretor  THEN
                 DO:
                     PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                     CLEAR FRAME f_lanctos ALL NO-PAUSE.
                 END.
            ELSE
                 aux_flgretor = TRUE.

       ASSIGN tel_dsdplano = IF crappla.tpdplano = 1
                                THEN "Plano de Capital"
                                ELSE STRING(crappla.tpdplano)
              tel_dssitpla = IF crappla.cdsitpla = 1
                                THEN "Ativo"
                                ELSE "Cancelado"

              tel_dsdlinha = STRING(tel_dsdplano,"x(16)")          + "  "  +
                             STRING(crappla.dtinipla,"99/99/9999") + "   " +
                             STRING(crappla.vlprepla,
                                          "zzz,zzz,zz9.99")  + "       " +
                             STRING(crappla.nrctrpla,"zzz,zz9")  + "   " +
                             STRING(crappla.qtpremin,"zz9")      + "  "  +
                             STRING(crappla.qtpremax,"zz9")      + "  "  +
                             STRING(crappla.qtprepag,"zz9")

              aux_dtcancel = IF crappla.dtcancel = ?
                                THEN "          "
                                ELSE STRING(crappla.dtcancel,"99/99/9999").

       PAUSE (0).

       DISPLAY tel_dsdlinha WITH FRAME f_lanctos.
       DOWN WITH FRAME f_lanctos.

       tel_dsdlinha = STRING(tel_dssitpla,"x(16)") + "  "         +
                      STRING(aux_dtcancel,"x(10)")  +
                      STRING(crappla.vlprepag,"zz,zzz,zzz,zz9.99") + "     " +
                      (IF crappla.flgpagto
                        THEN "Debito em C/C vinc. folha"
                        ELSE "Debito em C/C dia " +
                              STRING(DAY(crappla.dtdpagto),"99")).

       DISPLAY tel_dsdlinha WITH FRAME f_lanctos.

       IF   aux_contador = 4   THEN
            aux_contador = 0.
       ELSE
            DOWN 2 WITH FRAME f_lanctos.

   END.

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 200.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            tel_nrdconta = aux_nrdconta.
            DISPLAY tel_nrdconta WITH FRAME f_planos.
            NEXT.
        END.

END.

/* .......................................................................... */

