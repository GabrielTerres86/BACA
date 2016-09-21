/* .............................................................................

   Programa: Fontes/senpac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Fevereiro/2004                      Ultima atualizacao: 23/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir efetuar manutencao - Senhas PAC.  

   Alteracoes: 15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
               
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i }
{ includes/var_altera.i }

DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR tel_cddsenha AS INT    FORMAT "999999"                NO-UNDO.
DEF        VAR aux_cdsenha1 AS INT    FORMAT "999999"                NO-UNDO.
DEF        VAR aux_cdsenha2 AS INT    FORMAT "999999"                NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR tel_dtaltera AS DATE   FORMAT "99/99/9999"            NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(2)
     glb_cddopcao      AT 13 LABEL "Opcao"
                             HELP "Informe a opcao desejada (A ou C)"
                             VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_cdagenci      AT 10 LABEL "PA"
                            HELP "Informe o codigo do PA"
     crapage.nmextage  AT 35 NO-LABELS FORMAT "x(40)"
     SKIP(1)
     WITH COLUMN 2 ROW 6 NO-BOX SIDE-LABELS OVERLAY WIDTH 78 FRAME f_senpac.

FORM tel_cddsenha  AT 10 LABEL "Senha"
     WITH COLUMN 2 ROW 12 NO-BOX SIDE-LABELS OVERLAY WIDTH 78 FRAME f_consulta.

FORM tel_cddsenha  AT 10 LABEL "Senha" BLANK
         VALIDATE(tel_cddsenha = INTEGER(crapage.cddsenha),
                                 "003 - Senha errada.")
     SKIP(1)
     aux_cdsenha1  AT 10 LABEL "Nova Senha" BLANK
                         HELP "Digita apenas numeros"
     SKIP(1)
     aux_cdsenha2  AT 10 LABEL "Confirme" BLANK
     WITH COLUMN 2 ROW 12 NO-BOX SIDE-LABELS OVERLAY WIDTH 78 FRAME f_alteracao.

ASSIGN  glb_cddopcao = "C"
        tel_cdagenci = 0
        glb_cdcritic = 0.

VIEW FRAME f_moldura.

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_senpac.
            CLEAR FRAME f_alteracao.
            CLEAR FRAME f_consulta.
            glb_cdcritic = 0.
        END.

   NEXT-PROMPT tel_cdagenci  WITH FRAME f_senpac.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_cdagenci WITH FRAME f_senpac.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   ASSIGN aux_cdsenha1 = 0
          aux_cdsenha2 = 0
          tel_cddsenha = 0.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "ACESSO"   THEN
                 DO:
                     HIDE FRAME f_consulta.
                     HIDE FRAME f_alteracao.
                     HIDE FRAME f_senpac.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   glb_cddopcao = "A" THEN
        HIDE FRAME f_consulta.
   ELSE
        HIDE FRAME f_alteracao.

   PAUSE(0).

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                      crapage.cdagenci = tel_cdagenci   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapage   THEN
        DO:
            glb_cdcritic = 15.
            NEXT.
        END.

   DISPLAY crapage.nmextage WITH FRAME f_senpac.

   IF   glb_cddopcao = "C" THEN
        DO:
            
            tel_cddsenha = INTEGER(TRIM(crapage.cddsenha)).

            DISPLAY tel_cddsenha WITH FRAME f_consulta.

        END.
   ELSE
        TRANS_A:
        DO TRANSACTION:

            DO WHILE TRUE:

               IF   glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               DO WHILE TRUE ON ENDKEY UNDO TRANS_A, LEAVE:

                  UPDATE tel_cddsenha aux_cdsenha1 aux_cdsenha2
                         WITH FRAME f_alteracao.

                  LEAVE.
               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.

               IF   (aux_cdsenha1 <> aux_cdsenha2) OR aux_cdsenha1 = 0 THEN
                    DO:
                        glb_cdcritic = 3.
                        NEXT-PROMPT aux_cdsenha1 WITH FRAME f_alteracao.
                        NEXT.
                    END.

               LEAVE.
            END.

            DO WHILE TRUE ON ERROR UNDO TRANS_A, NEXT:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        UNDO TRANS_A, NEXT.
                    END.

               DO aux_contador = 1 TO 5:

                  FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                                     crapage.cdagenci = tel_cdagenci
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapage   THEN
                       IF   LOCKED crapage   THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapage),
                                					 INPUT "banco",
                                					 INPUT "crapage",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                                                            END.
                       ELSE
                            glb_cdcritic = 15. /* Agencia nao Cadastrada */
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    UNDO TRANS_A, NEXT.

               ASSIGN crapage.cddsenha = STRING(aux_cdsenha1,"999999").
                      /*
                      crapage.dtaltsnh = glb_dtmvtolt.
                     */
               LEAVE.

            END. /* DO WHILE TRUE  */

        END.

END. /* Fim do DO WHILE TRUE */
..............................................................................
