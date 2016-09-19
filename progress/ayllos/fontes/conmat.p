/* .............................................................................

   Programa: Fontes/conmat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Marco/98.                           Ultima atualizacao: 26/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CONMAT - consulta de matriculas.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando

               14/12/2010 - incluido format no compo crapass.nmprimtl.
                            Kbase
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrinimat AS INT     FORMAT "zzz,zz9"              NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Consultar a partir da matricula:" AT 10
      tel_nrinimat  NO-LABEL
                    HELP "Informe a matricula inicial."
     SKIP(1)
     "Matricula   Conta/dv   Admissao Nome          " AT 3
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_conmat.

FORM crapass.nrmatric AT 5
     crapass.nrdconta
     crapass.dtadmiss FORMAT "99/99/9999"
     crapass.nmprimtl FORMAT "x(44)"
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrinimat WITH FRAME f_conmat.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CONMAT"   THEN
                 DO:
                     HIDE FRAME f_conmat.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper  AND
                          crapass.nrmatric >= tel_nrinimat  NO-LOCK 
                          BY crapass.nrmatric:

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

       PAUSE(0).

       DISPLAY crapass.nrmatric crapass.nrdconta
               crapass.dtadmiss crapass.nmprimtl
               WITH FRAME f_lanctos.

       IF   aux_contador = 11  THEN
            aux_contador = 0.
       ELSE
            DOWN WITH FRAME f_lanctos.

   END.  /*  Fim do FOR EACH  --  Leitura dos associados */

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 11.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
END.
/* .......................................................................... */

