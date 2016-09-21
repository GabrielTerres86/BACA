/* .............................................................................

   Programa: Fontes/dolfat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/98                       Ultima alteracao: 23/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DOLFAT.

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
 

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_dtdolfat AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_vldolfat AS DECIMAL FORMAT "zzzzzzzz9.9999"       NO-UNDO.

DEF        VAR aux_cdacesso AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP (3)
     "Opcao:"     AT 35
     glb_cddopcao AT 42 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A ou C)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")
     SKIP (2)
     tel_dtdolfat AT 26 LABEL "Data da fatura"             

     SKIP (2)
     tel_vldolfat AT 12 LABEL "Valor do dolar para a fatura"             
                  HELP "Entre com o valor do dolar para a fatura."
                  VALIDATE(tel_vldolfat > 0,"269 - Valor errado")

     SKIP(6)
     WITH SIDE-LABELS 
     TITLE COLOR MESSAGE " Dolar para Faturas Bradesco-Visa "
           ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_dolfat.

glb_cddopcao = "A".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY glb_cddopcao WITH FRAME f_dolfat.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      PROMPT-FOR glb_cddopcao  tel_dtdolfat  WITH FRAME f_dolfat.
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "DOLFAT"   THEN
                 DO:
                     HIDE FRAME f_dolfat.
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

   ASSIGN glb_cddopcao = INPUT glb_cddopcao
          tel_dtdolfat = INPUT tel_dtdolfat
          aux_cdacesso = "DC" + STRING(YEAR(tel_dtdolfat),"9999") +
                                STRING(MONTH(tel_dtdolfat),"99") +
                                STRING(DAY(tel_dtdolfat),"99").

   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO  aux_contador = 1 TO 10:

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                      craptab.nmsistem = "CRED"         AND
                                      craptab.tptabela = "USUARI"       AND
                                      craptab.cdempres = 11             AND
                                      craptab.cdacesso = aux_cdacesso   AND
                                      craptab.tpregist = 000
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptab   THEN
                        IF   LOCKED craptab   THEN
                             DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                     INPUT "banco",
                                                     INPUT "craptab",
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
                                                              
                                NEXT.

                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 55.
                                 CLEAR FRAME f_dolfat.
                                 LEAVE.
                             END.
                   ELSE
                        DO:
                            aux_contador = 0.
                            LEAVE.
                        END.
               END.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
              
              ASSIGN tel_vldolfat = DECIMAL(craptab.dstextab).

              DISPLAY tel_vldolfat WITH FRAME f_dolfat.

              DO WHILE TRUE:

                 SET tel_vldolfat WITH FRAME f_dolfat.
                 craptab.dstextab = STRING(tel_vldolfat,"zzzzzzzz9.9999").
                 LEAVE.

              END.

            END. /* Fim da transacao */

            RELEASE craptab.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_dolfat NO-PAUSE.

        END.
   ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 11             AND
                                    craptab.cdacesso = aux_cdacesso   AND
                                    craptab.tpregist = 000
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN tel_vldolfat = DECIMAL(craptab.dstextab).
                          DISPLAY tel_vldolfat WITH FRAME f_dolfat.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 55.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_dolfat.
                          NEXT.
                      END.
             END.
END.
/* .......................................................................... */

