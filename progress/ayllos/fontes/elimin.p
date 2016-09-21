/* .............................................................................

   Programa: Fontes/elimin.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/94.                      Ultima atualizacao: 04/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ELIMIN -- Consultar as contas eliminadas do sis-
               tema.

   Alteracoes: 26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               16/01/2007 - Alterar label CGC para CNPJ (Magui).
               
               12/08/2009 - Melhoria de Performance (crapdem) (Diego).
               
               04/06/2012 - Projeto Oracle - Adaptação de Fontes - Substituição 
                            da função CONTAINS pela MATCHES (Lucas R.).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmpesqui AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR tel_nrcpfcgc AS CHAR    FORMAT "x(18)"                NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  5 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C ou N)"
                        VALIDATE (CAN-DO("C,N",glb_cddopcao),
                                  "014 - Opcao errada.")

     tel_nrdconta AT 15 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta."

     tel_nmpesqui AT 38 LABEL "Parte do Nome" AUTO-RETURN
                        HELP "Informe o nome para pesquisa."
     SKIP(1)
     "Conta/dv  Titular/Nascimento              CPF/CNPJ" AT  5
     "Data da Microfilmagem"                              AT 57
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_elimin.

FORM SKIP(1)
     crapdem.nrdconta AT  3
     crapdem.nmprimtl AT 15
     crapdem.dtdbaixa AT 63 FORMAT "99/99/9999"
     SKIP
     crapdem.dtnasctl AT 15 FORMAT "99/99/9999"
     tel_nrcpfcgc     AT 37
     WITH ROW 9 COLUMN 2 OVERLAY 4 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_elimin.

      ASSIGN tel_nrdconta = 0
             tel_nmpesqui = "".

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "elimin"   THEN
                 DO:
                     HIDE FRAME f_elimin.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   DISPLAY tel_nrdconta tel_nmpesqui WITH FRAME f_elimin.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   glb_cddopcao = "C"   THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    glb_cdcritic = 0.
                END.

           UPDATE tel_nrdconta WITH FRAME f_elimin

           EDITING:

              aux_stimeout = 0.

              DO WHILE TRUE:

                 READKEY PAUSE 1.

                 IF   LASTKEY = -1   THEN
                      DO:
                          aux_stimeout = aux_stimeout + 1.

                          IF   aux_stimeout > glb_stimeout   THEN
                               QUIT.

                          NEXT.
                      END.

                 APPLY LASTKEY.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */

           END.  /*  Fim do EDITING  */

           glb_nrcalcul = tel_nrdconta.

           RUN fontes/digfun.p.

           IF   NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    NEXT.
                END.

           FIND crapdem WHERE crapdem.cdcooper = glb_cdcooper AND
                              crapdem.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE crapdem   THEN
                IF   CAN-FIND(crapass WHERE 
                              crapass.cdcooper = glb_cdcooper AND
                              crapass.nrdconta = tel_nrdconta)   THEN
                     DO:
                         glb_cdcritic = 406.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 9.
                         NEXT.
                     END.

           IF   LENGTH(STRING(crapdem.nrcpfcgc)) < 12 THEN
                ASSIGN tel_nrcpfcgc = STRING(crapdem.nrcpfcgc,"99999999999")
                       tel_nrcpfcgc = STRING(tel_nrcpfcgc,"    xxx.xxx.xxx-xx").
           ELSE
                ASSIGN tel_nrcpfcgc = STRING(crapdem.nrcpfcgc,"99999999999999")
                       tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

           CLEAR FRAME f_lanctos ALL NO-PAUSE.

           DISPLAY crapdem.nrdconta crapdem.nmprimtl crapdem.dtdbaixa
                   crapdem.dtnasctl tel_nrcpfcgc WITH FRAME f_lanctos.

           DOWN WITH FRAME f_lanctos.

        END.  /*  Fim do DO WHILE TRUE  */
   ELSE
   IF   glb_cddopcao = "N"   THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    glb_cdcritic = 0.
                END.

           UPDATE tel_nmpesqui WITH FRAME f_elimin

           EDITING:

              aux_stimeout = 0.

              DO WHILE TRUE:

                 READKEY PAUSE 1.

                 IF   LASTKEY = -1   THEN
                      DO:
                          aux_stimeout = aux_stimeout + 1.

                          IF   aux_stimeout > glb_stimeout   THEN
                               QUIT.

                          NEXT.
                      END.

                 APPLY LASTKEY.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */

           END.  /*  Fim do EDITING  */

           ASSIGN aux_regexist = FALSE
                  aux_flgretor = FALSE
                  aux_contador = 0.

           CLEAR FRAME f_lanctos ALL NO-PAUSE.

           FOR EACH crapdem WHERE 
                    crapdem.cdcooper = glb_cdcooper AND
                    crapdem.nmprimtl MATCHES("*" + TRIM(tel_nmpesqui) + "*")
                    NO-LOCK:

               ASSIGN aux_regexist = TRUE
                      aux_contador = aux_contador + 1.

               IF   aux_contador = 1   THEN
                    IF   aux_flgretor   THEN
                         DO:
                              PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                         END.
                    ELSE
                         aux_flgretor = TRUE.

               IF   LENGTH(STRING(crapdem.nrcpfcgc)) < 12 THEN
                    ASSIGN tel_nrcpfcgc = STRING(crapdem.nrcpfcgc,"99999999999")
                           tel_nrcpfcgc = STRING(tel_nrcpfcgc,
                                                 "    xxx.xxx.xxx-xx").
               ELSE
                    ASSIGN tel_nrcpfcgc = STRING(crapdem.nrcpfcgc,
                                                 "99999999999999")
                           tel_nrcpfcgc = STRING(tel_nrcpfcgc,
                                                 "xx.xxx.xxx/xxxx-xx").

               DISPLAY crapdem.nrdconta crapdem.nmprimtl crapdem.dtdbaixa
                       crapdem.dtnasctl tel_nrcpfcgc
                       WITH FRAME f_lanctos.

               IF   aux_contador = 4   THEN
                    aux_contador = 0.
               ELSE
                    DOWN WITH FRAME f_lanctos.

           END.  /*  Fim do FOR EACH  */

           IF   NOT aux_regexist   THEN
                glb_cdcritic = 407.

        END.  /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

