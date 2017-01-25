/* .............................................................................

   Programa: Fontes/tab001.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 06/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB001.

   Alteracoes: 14/06/94 - Alterado para mudar o tamanho do texto da tabela para
                          200 posicoes (Edson).

               06/10/1999 - Tirar consistencia da empresa (Deborah). 

               05/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               03/10/2006 - Alterado para cooperativas singulares somente
                            consultar (Elton).
               
               19/04/2007 - Permitido ao operador "799" a opcao de alterar
                            (Elton).

               23/01/2009 - Retirar permissao do operador 799 e liberar 
                            o 979 (Gabriel).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).   
               
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................. */

{ includes/var_online.i }

DEF VAR tel_nmsistem            LIKE craptab.nmsistem         NO-UNDO.
DEF VAR tel_tptabela            LIKE craptab.tptabela         NO-UNDO.
DEF VAR tel_cdempres            LIKE craptab.cdempres
                                FORMAT "z9"                   NO-UNDO.
DEF VAR tel_cdacesso            LIKE craptab.cdacesso         NO-UNDO.
DEF VAR tel_tpregist            LIKE craptab.tpregist
                                FORMAT "zz9"                  NO-UNDO.

DEF VAR tel_dstextab AS CHAR    FORMAT "x(50)" EXTENT 4       NO-UNDO.

DEF VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP(2)
     glb_cddopcao AT  4 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_nmsistem AT  5 AUTO-RETURN
                        HELP "Entre com o nome do sistema."
                        VALIDATE(tel_nmsistem = "CRED",
                                 "052 - Nome do sistema errado.")
     tel_tptabela AT 29 AUTO-RETURN
                        HELP "Entre com o tipo da tabela."

     tel_cdempres AT 53 AUTO-RETURN
                        HELP "Entre com o codigo da empresa."
     SKIP(1)
     tel_cdacesso AT  4 AUTO-RETURN
                        HELP "Entre com o codigo de acesso."
                        VALIDATE(tel_cdacesso <> "",
                                 "054 - Codigo de acesso deve ser informado.")
     SKIP (1)
     tel_tpregist AT  4 AUTO-RETURN
                      HELP "Entre com o tipo de registro."
     SKIP(1)
     tel_dstextab[1] AT  5 LABEL "Texto da Tabela" AUTO-RETURN
     tel_dstextab[2] AT 22 NO-LABEL AUTO-RETURN
     tel_dstextab[3] AT 22 NO-LABEL AUTO-RETURN
     tel_dstextab[4] AT 22 NO-LABEL AUTO-RETURN
     SKIP(2)
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_tab001.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nmsistem WITH FRAME f_tab001.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nmsistem tel_tptabela
             tel_cdempres tel_cdacesso tel_tpregist
             WITH FRAME f_tab001.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB001"   THEN
                 DO:
                     HIDE FRAME f_tab001.
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

   IF   glb_cddopcao  <> "C"   THEN 
        IF   glb_cddepart <>  8 AND  /* COORD.ADM/FINANCEIRO */
             glb_cddepart <> 20 AND  /* TI                   */
             glb_cddepart <>  9 THEN /* COORD.PRODUTOS       */
             DO:
                 BELL.
                 MESSAGE "Sistema liberado somente para Consulta !!!".
                 NEXT.
            END.

   ASSIGN tel_nmsistem = CAPS(tel_nmsistem)
          tel_tptabela = CAPS(tel_tptabela)
          tel_cdacesso = CAPS(tel_cdacesso)
          tel_cdempres =      tel_cdempres
          tel_tpregist =      tel_tpregist.

   DISPLAY tel_nmsistem tel_tptabela tel_cdacesso WITH FRAME f_tab001.

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                     craptab.nmsistem = tel_nmsistem   AND
                                     craptab.tptabela = tel_tptabela   AND
                                     craptab.cdempres = tel_cdempres   AND
                                     craptab.cdacesso = tel_cdacesso   AND
                                     craptab.tpregist = tel_tpregist
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        IF   NOT AVAILABLE craptab   THEN
                            IF  LOCKED craptab   THEN
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
                              
                               UNDO, NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 55.
                                CLEAR FRAME f_tab001 NO-PAUSE.
                            END.
                  ELSE
                       ASSIGN glb_cdcritic = 0
                              tel_dstextab[1] = SUBSTR(craptab.dstextab,001,50)
                              tel_dstextab[2] = SUBSTR(craptab.dstextab,051,50)
                              tel_dstextab[3] = SUBSTR(craptab.dstextab,101,50)
                              tel_dstextab[4] = SUBSTR(craptab.dstextab,151,50).

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0   THEN
                    DO:                     
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_dstextab WITH FRAME f_tab001.

                  ASSIGN tel_dstextab[1]  = CAPS(tel_dstextab[1])
                         tel_dstextab[2]  = CAPS(tel_dstextab[2])
                         tel_dstextab[3]  = CAPS(tel_dstextab[3])
                         tel_dstextab[4]  = CAPS(tel_dstextab[4])

                         craptab.dstextab = STRING(tel_dstextab[1],"x(50)") +
                                            STRING(tel_dstextab[2],"x(50)") +
                                            STRING(tel_dstextab[3],"x(50)") +
                                            STRING(tel_dstextab[4],"x(50)").

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /*  F4 OU FIM  */
                    UNDO, NEXT.
               ELSE
                    DO:
                        ASSIGN tel_nmsistem = "CRED"
                               tel_tptabela = "GENERI"
                               tel_cdacesso = ""
                               tel_cdempres = 0
                               tel_tpregist = 0
                               tel_dstextab = "".

                        CLEAR FRAME f_tab001 NO-PAUSE.
                    END.

            END. /* Fim da transacao */
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                               craptab.nmsistem = tel_nmsistem AND
                               craptab.tptabela = tel_tptabela AND
                               craptab.cdempres = tel_cdempres AND
                               craptab.cdacesso = tel_cdacesso AND
                               craptab.tpregist = tel_tpregist NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_tab001 NO-PAUSE.
                     NEXT.
                 END.

            ASSIGN tel_dstextab[1] = SUBSTRING(craptab.dstextab,001,50)
                   tel_dstextab[2] = SUBSTRING(craptab.dstextab,051,50)
                   tel_dstextab[3] = SUBSTRING(craptab.dstextab,101,50)
                   tel_dstextab[4] = SUBSTRING(craptab.dstextab,151,50).

            DISPLAY tel_dstextab WITH FRAME f_tab001.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                     craptab.nmsistem = tel_nmsistem   AND
                                     craptab.tptabela = tel_tptabela   AND
                                     craptab.cdempres = tel_cdempres   AND
                                     craptab.cdacesso = tel_cdacesso   AND
                                     craptab.tpregist = tel_tpregist
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craptab   THEN
                       IF  LOCKED craptab   THEN
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
                        
                               glb_cdcritic = 77.
                               UNDO, NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 55.
                                CLEAR FRAME f_tab001 NO-PAUSE.
                            END.
                  ELSE
                       ASSIGN glb_cdcritic = 0
                              tel_dstextab[1] = SUBSTR(craptab.dstextab,001,50)
                              tel_dstextab[2] = SUBSTR(craptab.dstextab,051,50)
                              tel_dstextab[3] = SUBSTR(craptab.dstextab,101,50)
                              tel_dstextab[4] = SUBSTR(craptab.dstextab,151,50).

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               DISPLAY tel_dstextab WITH FRAME f_tab001.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.

                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               DELETE craptab.

               ASSIGN tel_nmsistem = "CRED"
                      tel_tptabela = "GENERI"
                      tel_cdacesso = ""
                      tel_cdempres = 0
                      tel_tpregist = 0
                      tel_dstextab = "".

               CLEAR FRAME f_tab001 NO-PAUSE.

            END. /* Fim da transacao */
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            IF   CAN-FIND(craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                        craptab.nmsistem = tel_nmsistem   AND
                                        craptab.tptabela = tel_tptabela   AND
                                        craptab.cdempres = tel_cdempres   AND
                                        craptab.cdacesso = tel_cdacesso   AND
                                        craptab.tpregist = tel_tpregist)  THEN
                 DO:
                     glb_cdcritic = 56.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_tab001 NO-PAUSE.
                     NEXT.
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               CREATE craptab.

               ASSIGN craptab.nmsistem = tel_nmsistem
                      craptab.tptabela = tel_tptabela
                      craptab.cdempres = tel_cdempres
                      craptab.cdacesso = tel_cdacesso
                      craptab.tpregist = tel_tpregist
                      craptab.cdcooper = glb_cdcooper.
                
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_dstextab WITH FRAME f_tab001.

                  ASSIGN tel_dstextab[1] = CAPS(tel_dstextab[1])
                         tel_dstextab[2] = CAPS(tel_dstextab[2])
                         tel_dstextab[3] = CAPS(tel_dstextab[3])
                         tel_dstextab[4] = CAPS(tel_dstextab[4])

                         craptab.dstextab = STRING(tel_dstextab[1],"x(50)") +
                                            STRING(tel_dstextab[2],"x(50)") +
                                            STRING(tel_dstextab[3],"x(50)") +
                                            STRING(tel_dstextab[4],"x(50)").

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */
               VALIDATE craptab. 

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /*  F4 OU FIM  */
                    UNDO, NEXT.
               ELSE
                    DO:
                    /*  ASSIGN tel_nmsistem = "CRED"
                               tel_tptabela = "GENERI"
                               tel_cdacesso = ""
                               tel_cdempres = 0
                               tel_tpregist = 0
                               tel_dstextab = "". */

               /*       CLEAR FRAME f_tab001 NO-PAUSE. */
                    END.

            END. /* Fim da transacao */
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
