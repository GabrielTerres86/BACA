/* .............................................................................

   Programa: Fontes/outras.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/94.                          Ultima atualizacao: 31/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela OUTRAS -- Pesquisa se outras contas associadas
               a conta informada.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             01/08/2002 - Incluir nova situacao da conta (Margarete).

             31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
             
             01/12/2010 - Alteracao de Format (Kbase/Willian).
                          001 - Alterado para 50 posições, valor anterior 48.
                          
             08/03/2018 - Substituida verificacao "cdtipcta <> 5" por codigo 
                          da modalidade <> 2. PRJ366 (Lombardi).
                          
............................................................................. */

{ sistema/generico/includes/var_oracle.i }
{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(48)"                NO-UNDO. /*001*/
DEF        VAR tel_nroutcta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmouttit AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_dsoutsit AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR tel_dsouttip AS CHAR    FORMAT "x(3)"                 NO-UNDO.
DEF        VAR tel_nroutcpf AS CHAR    FORMAT "x(18)"                NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdmodali AS INT                                   NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta LABEL "Conta/dv" AUTO-RETURN
                  HELP "Informe o numero da conta do associado."

     tel_nmprimtl LABEL "Titular"
     SKIP(1)
     "As Outras Tipo Titular                        CPF/CGC" AT  3
     "Situacao"                                              AT 68
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_outras.

FORM tel_nroutcta AT  2
     tel_dsouttip AT 14
     tel_nmouttit AT 18
     tel_nroutcpf AT 49
     tel_dsoutsit AT 68
     WITH ROW 10 COLUMN 2 OVERLAY 9 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_outras NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta WITH FRAME f_outras

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
               NEXT-PROMPT tel_nrdconta WITH FRAME f_outras.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "OUTRAS"   THEN
                 DO:
                     HIDE FRAME f_outras.
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

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                      crapass.nrdconta = tel_nrdconta  NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_outras.
            NEXT.
        END.

   ASSIGN tel_nmprimtl = crapass.nmprimtl

          aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0.

   DISPLAY tel_nmprimtl WITH FRAME f_outras.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   FOR EACH craptrf WHERE craptrf.cdcooper = glb_cdcooper  AND
                          craptrf.tptransa = 2             AND
                          craptrf.insittrs = 2             AND
                         (craptrf.nrdconta = tel_nrdconta  OR
                          craptrf.nrsconta = tel_nrdconta)
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

       IF   craptrf.nrdconta = tel_nrdconta   THEN
            ASSIGN tel_nroutcta = craptrf.nrsconta
                   tel_dsouttip = "DUP".
       ELSE
            ASSIGN tel_nroutcta = craptrf.nrdconta
                   tel_dsouttip = "ORI".

       FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                          crapass.nrdconta = tel_nroutcta   NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapass   THEN
            ASSIGN tel_nmouttit = "** NAO CADASTRADO **"
                   tel_nroutcpf = ""
                   tel_dsoutsit = "".
       ELSE
            DO:
                tel_nmouttit = crapass.nmprimtl.

                IF   crapass.inpessoa = 1 THEN
                     ASSIGN tel_nroutcpf = STRING(crapass.nrcpfcgc,
                                                  "99999999999")
                            tel_nroutcpf = STRING(tel_nroutcpf,
                                                  "xxx.xxx.xxx-xx").
                ELSE
                     ASSIGN tel_nroutcpf = STRING(crapass.nrcpfcgc,
                                                  "99999999999999")
                            tel_nroutcpf = STRING(tel_nroutcpf,
                                                  "xx.xxx.xxx/xxxx-xx").
                
                { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                
                RUN STORED-PROCEDURE pc_busca_modalidade_tipo
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                     INPUT crapass.cdtipcta, /* Tipo de conta */
                                                    OUTPUT 0,                /* Modalidade */
                                                    OUTPUT "",               /* Flag Erro */
                                                    OUTPUT "").              /* Descrição da crítica */
                
                CLOSE STORED-PROC pc_busca_modalidade_tipo
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux_cdmodali = 0
                       aux_des_erro = ""
                       aux_dscritic = ""
                       aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                      WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                       aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                      WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                       aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                      WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
                
                IF aux_des_erro = "NOK"  THEN
                    DO:
                       ASSIGN glb_dscritic = aux_dscritic.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_outras.
                       NEXT.
                    END.
                
                IF aux_cdmodali <> 2 THEN 
                     DO:
                         IF   crapass.cdsitdct = 1   THEN
                              tel_dsoutsit = "NORMAL".
                         ELSE
                         IF   crapass.cdsitdct = 6   THEN
                              tel_dsoutsit = "SEM TALAO".
                         ELSE
                              tel_dsoutsit = "ENCERRADA".
                     END.
               ELSE
                    tel_dsoutsit = "".
            END.

       DISPLAY tel_nroutcta tel_dsouttip tel_nmouttit tel_nroutcpf tel_dsoutsit
               WITH FRAME f_lanctos.

       IF   aux_contador = 10   THEN
            aux_contador = 0.
       ELSE
            DOWN WITH FRAME f_lanctos.

   END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos automaticos  */

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 81.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

