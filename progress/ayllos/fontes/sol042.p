/* .............................................................................

   Programa: Fontes/sol042.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 17/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL042 (reajuste das prestacoes variaveis)

   Alteracoes: 31/10/95 - Alterado para tratar o campo filial (Deborah).
   
               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)                            

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tel_nmempres AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nmresage AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 42           NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.

FORM SKIP (2)
     glb_cddopcao AT 15 LABEL "Opcao         " AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")
     SKIP (1)
     tel_nrseqsol AT 15 LABEL "Sequencia     " AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP (1)
     tel_cdempres AT 15 LABEL "Empresa       " AUTO-RETURN
                        HELP "Entre com o codigo da empresa."
                        VALIDATE (CAN-FIND (crapemp WHERE 
                                            crapemp.cdcooper = glb_cdcooper AND
                                            crapemp.cdempres = tel_cdempres),
                                            "040 - Empresa nao cadastrada.")
     tel_nmempres AT 37 NO-LABEL
     SKIP (1)
     tel_cdagenci AT 9  LABEL "Posto de Atendimento" AUTO-RETURN
                        HELP "Posto de atendimento ou zero para toda a empresa."
                        VALIDATE (CAN-FIND (crapage WHERE 
                                            crapage.cdcooper = glb_cdcooper AND
                                            crapage.cdagenci = tel_cdagenci) 
                                            OR tel_cdagenci = 0,
                                            "962 - PA nao cadastrado.")
     tel_nmresage AT 34 NO-LABEL
     SKIP (1)
     tel_dtrefere AT 15 LABEL "Data Limite   "
                      HELP "Entre com a data limite para reajustar os contratos"
                      VALIDATE (tel_dtrefere <> ? AND
                                tel_dtrefere <= glb_dtmvtolt,
                                  "13 - Data errada")
     SKIP (1)
     tel_percentu AT 15 LABEL "Percentual    " AUTO-RETURN
                        HELP "Entre com o percentual de reajuste (999,99)"
                        VALIDATE (tel_percentu > 0,"180 - Percentual errado.")
     SKIP (3)
     WITH ROW 4 COLUMN 1 OVERLAY TITLE COLOR MESSAGE tel_dstitulo
     SIDE-LABELS NO-ATTR-SPACE WIDTH 80 FRAME f_sol042.

glb_cddopcao = "I".

FIND craprel WHERE craprel.cdcooper = glb_cdcooper  AND
                   craprel.cdrelato = 64            NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craprel   THEN
     ASSIGN tel_dstitulo = FILL("*",40).
ELSE
     ASSIGN tel_dstitulo = " " + craprel.nmrelato + " ".

RELEASE craprel.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY glb_cddopcao tel_nrseqsol tel_cdempres tel_dtrefere
           tel_percentu tel_nmempres
           tel_cdagenci tel_nmresage WITH FRAME f_sol042.

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol042.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrseqsol WITH FRAME f_sol042.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL042"   THEN
                 DO:
                     HIDE FRAME f_sol042.
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

               DO  aux_contador = 1 TO 10:

                   FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                      crapsol.nrsolici = aux_nrsolici   AND
                                      crapsol.dtrefere = glb_dtmvtolt   AND
                                      crapsol.nrseqsol = tel_nrseqsol
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapsol   THEN
                        IF   LOCKED crapsol   THEN
                             DO:
                                 glb_cdcritic = 120.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 115
                                        tel_cdempres = 0
                                        tel_cdagenci = 0
                                        tel_percentu = 0
                                        tel_dtrefere = ?
                                        tel_nmresage = ""
                                        tel_nmempres = "".
                                 CLEAR FRAME f_sol042.
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

               ASSIGN tel_percentu = DECIMAL(SUBSTRING(crapsol.dsparame,1,6))
                      tel_cdempres = crapsol.cdempres
                      tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,8,3))
                      tel_dtrefere = DATE(INT(SUBSTR(crapsol.dsparame,15,2)),
                                          INT(SUBSTR(crapsol.dsparame,12,2)),
                                          INT(SUBSTR(crapsol.dsparame,18,4))).

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper   AND
                                  crapemp.cdempres = tel_cdempres   
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapemp THEN
                    tel_nmempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_nmempres = " - NAO CADASTRADA".

               IF   tel_cdagenci > 0 THEN
                    DO:
                        FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                           crapage.cdagenci = tel_cdagenci
                                           NO-LOCK NO-ERROR.

                        IF   AVAILABLE crapage THEN
                             tel_nmresage = " - " + crapage.nmresage.
                        ELSE
                             tel_nmresage = " - NAO CADASTRADA".
                    END.
               ELSE
                    tel_nmresage = " - GERAL".

               DISPLAY tel_cdempres tel_dtrefere
                       tel_percentu tel_nmempres
                       tel_cdagenci tel_nmresage WITH FRAME f_sol042.

               DO WHILE TRUE:

                  UPDATE tel_cdempres tel_cdagenci tel_dtrefere tel_percentu
                         WITH FRAME f_sol042

                  EDITING:
                           READKEY.
                           IF   FRAME-FIELD = "tel_percentu"   THEN
                                IF   LASTKEY =  KEYCODE(".")   THEN
                                     APPLY 44.
                                ELSE
                                     APPLY LASTKEY.
                           ELSE
                                APPLY LASTKEY.
                  END.

                  IF   tel_cdagenci = 0 THEN
                       DO:
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                              ASSIGN aux_confirma = "N"
                                     glb_cdcritic = 78.

                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE COLOR MESSAGE
                              "Atencao! Reajuste para toda a empresa".
                              MESSAGE COLOR NORMAL glb_dscritic
                                                   UPDATE aux_confirma.
                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                aux_confirma <> "S"   THEN
                                DO:
                                    glb_cdcritic = 79.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    UNDO, LEAVE.
                                END.

                           glb_cdcritic = 0.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         crapsol.dsparame = STRING(tel_percentu,"999.99") +
                                            " " + STRING(tel_cdagenci,"999") +
                                            " " +
                                            STRING(tel_dtrefere,"99/99/9999")

                         tel_nrseqsol     = 0
                         tel_cdempres     = 0
                         tel_percentu     = 0
                         tel_nmempres     = " "
                         tel_cdagenci     = 0
                         tel_dtrefere     = ?
                         tel_nmresage     = " ".

                  LEAVE.

               END.

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper AND 
                               crapsol.nrsolici = aux_nrsolici AND
                               crapsol.dtrefere = glb_dtmvtolt AND
                               crapsol.nrseqsol = tel_nrseqsol NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapsol   THEN
                 DO:
                     ASSIGN glb_cdcritic = 115
                            tel_cdempres = 0
                            tel_percentu = 0
                            tel_nmempres = " "
                            tel_cdagenci = 0
                            tel_dtrefere = ?
                            tel_nmresage = " ".
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol042.
                     DISPLAY tel_cdempres tel_dtrefere tel_percentu
                             tel_nmempres tel_cdagenci tel_nmresage
                             WITH FRAME f_sol042.
                     NEXT.
                 END.

            ASSIGN tel_percentu = DECIMAL(SUBSTRING(crapsol.dsparame,1,6))
                   tel_cdempres = crapsol.cdempres
                   tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,8,3))
                   tel_dtrefere = DATE(INT(SUBSTR(crapsol.dsparame,15,2)),
                                       INT(SUBSTR(crapsol.dsparame,12,2)),
                                       INT(SUBSTR(crapsol.dsparame,18,4))).

            FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND 
                               crapemp.cdempres = tel_cdempres  
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE crapemp THEN
                 tel_nmempres = " - " + crapemp.nmresemp.
            ELSE
                 tel_nmempres = " - NAO CADASTRADA".

            IF   tel_cdagenci > 0 THEN
                 DO:
                     FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                        crapage.cdagenci = tel_cdagenci
                                        NO-LOCK NO-ERROR.

                     IF   AVAILABLE crapage THEN
                          tel_nmresage = " - " + crapage.nmresage.
                     ELSE
                          tel_nmresage = " - NAO CADASTRADA".
                 END.
            ELSE
                 tel_nmresage = " - GERAL".

            DISPLAY tel_cdempres tel_dtrefere tel_percentu tel_nmempres
                    tel_cdagenci tel_nmresage WITH FRAME f_sol042.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO  aux_contador = 1 TO 10:

                   FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                      crapsol.nrsolici = aux_nrsolici   AND
                                      crapsol.dtrefere = glb_dtmvtolt   AND
                                      crapsol.nrseqsol = tel_nrseqsol
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapsol   THEN
                        IF   LOCKED crapsol   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 120.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 115
                                        tel_cdempres = 0
                                        tel_percentu = 0
                                        tel_nmempres = " "
                                        tel_cdagenci = 0
                                        tel_dtrefere = ?
                                        tel_nmresage = " ".
                                 CLEAR FRAME f_sol042.
                                 LEAVE.
                             END.
                   ELSE
                        DO:
                            ASSIGN aux_contador = 0.
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

               ASSIGN tel_percentu = DECIMAL(SUBSTRING(crapsol.dsparame,1,6))
                      tel_cdempres = crapsol.cdempres
                      tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,8,3))
                      tel_dtrefere = DATE(INT(SUBSTR(crapsol.dsparame,15,2)),
                                          INT(SUBSTR(crapsol.dsparame,12,2)),
                                          INT(SUBSTR(crapsol.dsparame,18,4))).

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper   AND
                                  crapemp.cdempres = tel_cdempres 
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapemp THEN
                    tel_nmempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_nmempres = " - NAO CADASTRADA".

               IF   tel_cdagenci > 0 THEN
                    DO:
                        FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                           crapage.cdagenci = tel_cdagenci
                                           NO-LOCK NO-ERROR.

                        IF   AVAILABLE crapage THEN
                             tel_nmresage = " - " + crapage.nmresage.
                        ELSE
                             tel_nmresage = " - NAO CADASTRADA".
                    END.
               ELSE
                    tel_nmresage = " - GERAL".

               DISPLAY tel_cdempres tel_dtrefere
                       tel_percentu tel_nmempres
                       tel_cdagenci tel_nmresage WITH FRAME f_sol042.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.

                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                    aux_confirma <> "S" THEN
                    DO:
                        ASSIGN glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               DELETE crapsol.

               ASSIGN  tel_nrseqsol = 0
                       tel_cdempres = 0
                       tel_percentu = 0
                       tel_nmempres = " "
                       tel_cdagenci = 0
                       tel_dtrefere = ?
                       tel_nmresage = " ".

            END. /* Fim da transacao */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            IF   CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                        crapsol.nrsolici = aux_nrsolici   AND
                                        crapsol.dtrefere = glb_dtmvtolt   AND
                                        crapsol.nrseqsol = tel_nrseqsol)  THEN
                 DO:
                     ASSIGN glb_cdcritic = 118
                            tel_cdempres = 0
                            tel_percentu = 0
                            tel_nmempres = " "
                            tel_cdagenci = 0
                            tel_dtrefere = ?
                            tel_nmresage = " ".
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol042.
                     DISPLAY tel_cdempres tel_dtrefere tel_percentu
                             tel_nmempres tel_cdagenci tel_nmresage
                             WITH FRAME f_sol042.
                     NEXT.
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = aux_nrsolici
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = tel_nrseqsol
                      crapsol.insitsol = 1
                      crapsol.cdcooper = glb_cdcooper
                      tel_cdempres     = 0
                      tel_percentu     = 0
                      tel_nmempres     = " "
                      tel_cdagenci     = 0
                      tel_dtrefere     = ?
                      tel_nmresage     = " ".

               DO WHILE TRUE:

                  UPDATE tel_cdempres tel_cdagenci tel_dtrefere tel_percentu
                         WITH FRAME f_sol042

                  EDITING:
                           READKEY.
                           IF   FRAME-FIELD = "tel_percentu"   THEN
                                IF   LASTKEY =  KEYCODE(".")   THEN
                                     APPLY 44.
                                ELSE
                                     APPLY LASTKEY.
                           ELSE
                                APPLY LASTKEY.
                  END.

                  IF   tel_cdagenci = 0 THEN
                       DO:
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                              ASSIGN aux_confirma = "N"
                                     glb_cdcritic = 78.

                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE COLOR MESSAGE
                              "Atencao! Reajuste para toda a empresa".
                              MESSAGE COLOR NORMAL glb_dscritic
                                                   UPDATE aux_confirma.
                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                aux_confirma <> "S"   THEN
                                DO:
                                    glb_cdcritic = 79.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    UNDO, LEAVE.
                                END.

                           glb_cdcritic = 0.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         crapsol.dsparame = STRING(tel_percentu,"999.99")
                                            + " " + STRING(tel_cdagenci,"999") +
                                            " " +
                                            STRING(tel_dtrefere,"99/99/9999")

                         tel_nrseqsol     = 0
                         tel_cdempres     = 0
                         tel_percentu     = 0
                         tel_nmempres     = " "
                         tel_cdagenci     = 0
                         tel_dtrefere     = ?
                         tel_nmresage     = " ".

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
