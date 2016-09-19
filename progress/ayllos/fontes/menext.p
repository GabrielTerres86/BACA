/* .............................................................................

   Programa: Fontes/menext.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                          Ultima atualizacao: 23/09/2014 
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MENEXT (Manutencao da Mensagem do Extrato Mensal).

   Alteracoes: 12/01/98 - Alterado para permitir 7 linhas de texto com 50
                          caracteres cada (Edson).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               29/01/2007 - Alterado help dos campos da tela (Elton).
               
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dsmensag AS CHAR    FORMAT "x(50)" EXTENT 7       NO-UNDO.

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
     glb_cddopcao AT  4 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A ou C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                        "014 - Opcao errada.")
     "Mensagem para o Extrato Mensal de Conta Corrente" AT 19
     SKIP (2)
     tel_dsmensag AT 18 NO-LABEL AUTO-RETURN
                  HELP "Digite a mensagem do extrato mensal de conta corrente."
    SKIP (3)
    WITH SIDE-LABELS TITLE COLOR MESSAGE " Mensagem para o Extrato Mensal "
         ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_menext.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_menext.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "MENEXT"   THEN
                 DO:
                     HIDE FRAME f_menext.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "USUARI"       AND
                                     craptab.cdempres = 11             AND
                                     craptab.cdacesso = "MENSAGEM  "   AND
                                     craptab.tpregist = 001
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
                                CLEAR FRAME f_menext.
                                LEAVE.
                            END.
                  ELSE
                       DO:
                           aux_contador = 0.
                           LEAVE.
                       END.

               END.  /*  Fim do DO .. TO  */

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               ASSIGN tel_dsmensag[1] = SUBSTRING(craptab.dstextab,001,50)
                      tel_dsmensag[2] = SUBSTRING(craptab.dstextab,051,50)
                      tel_dsmensag[3] = SUBSTRING(craptab.dstextab,101,50)
                      tel_dsmensag[4] = SUBSTRING(craptab.dstextab,151,50)
                      tel_dsmensag[5] = SUBSTRING(craptab.dstextab,201,50)
                      tel_dsmensag[6] = SUBSTRING(craptab.dstextab,251,50)
                      tel_dsmensag[7] = SUBSTRING(craptab.dstextab,301,50).

               DO WHILE TRUE:

                  UPDATE tel_dsmensag WITH FRAME f_menext.

                  craptab.dstextab = STRING(tel_dsmensag[1],"x(50)") +
                                     STRING(tel_dsmensag[2],"x(50)") +
                                     STRING(tel_dsmensag[3],"x(50)") +
                                     STRING(tel_dsmensag[4],"x(50)") +
                                     STRING(tel_dsmensag[5],"x(50)") +
                                     STRING(tel_dsmensag[6],"x(50)") +
                                     STRING(tel_dsmensag[7],"x(50)").

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

            END. /* Fim da transacao */

            RELEASE craptab.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_menext NO-PAUSE.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "MENSAGEM  "   AND
                               craptab.tpregist = 001
                               NO-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_menext.
                     NEXT.
                 END.

            ASSIGN tel_dsmensag[1] = SUBSTRING(craptab.dstextab,001,50)
                   tel_dsmensag[2] = SUBSTRING(craptab.dstextab,051,50)
                   tel_dsmensag[3] = SUBSTRING(craptab.dstextab,101,50)
                   tel_dsmensag[4] = SUBSTRING(craptab.dstextab,151,50)
                   tel_dsmensag[5] = SUBSTRING(craptab.dstextab,201,50)
                   tel_dsmensag[6] = SUBSTRING(craptab.dstextab,251,50)
                   tel_dsmensag[7] = SUBSTRING(craptab.dstextab,301,50).

            DISPLAY tel_dsmensag WITH FRAME f_menext.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

