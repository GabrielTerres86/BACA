/* .............................................................................

   Programa: Fontes/sol043.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/92                            Ultima atualizacao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL043.

   Alteracoes: 05/07/94 - Alterado para eliminar o tipo de debito e o valor
                          da URV da tela e assumir sempre 1 e 0.

               06/10/94 - Alterado para incluir o codigo de calculo da folha -
                          Sistema RUBI (Edson).

               30/05/95 - Alterado para nao permitir soliticacao para empresas
                          que tenham tpdebemp igual a 2 (Deborah).

               17/01/2000 - Tratar tpdebemp = 3 (Deborah).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tel_cdcalcul AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_intipsai AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_dstipsai AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR tel_tpdebito AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_dsdebito AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR tel_vldaurvs AS DECIMAL FORMAT "zz,zz9.99"            NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_inexecut AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR tel_insitsol AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_lstipsai AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_inexecut AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrsolici AS INT     INIT 43                       NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE COLOR MESSAGE " Geracao dos Debitos de Emprestimo "
                   FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 05 LABEL "Opcao " AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_nrseqsol AT 22 LABEL "Sequencia       " AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
               VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_cdempres AT 22 LABEL "Empresa         " AUTO-RETURN
                        HELP "Entre com o codigo da empresa."
               VALIDATE (CAN-FIND (crapemp WHERE 
                                   crapemp.cdcooper = glb_cdcooper AND 
                                   crapemp.cdempres = tel_cdempres)
                                   ,"040 - Empresa nao cadastrada.")
     tel_dsempres AT 45 NO-LABEL
     SKIP(1)
     tel_cdcalcul AT 22 LABEL "Cod. de Calculo " AUTO-RETURN
                        HELP "Entre com o codigo de calculo - Sistema RUBI"
     SKIP(1)
     tel_intipsai AT 22 LABEL "Tipo de Geracao "  AUTO-RETURN
     HELP "1 - Arq , 2 - Rel. c/c , 3 - Rel. cadastro , 4 - 1+2 , 5 - 1+3"
               VALIDATE (tel_intipsai > 0 and tel_intipsai < 6,
                        "217 - Tipo de geracao errado.")
     tel_dstipsai AT 42 NO-LABEL
     SKIP(1)
     tel_nrdevias AT 22 LABEL "Numero de vias  "   AUTO-RETURN
                        HELP "Entre com o numero de vias do relatorio"
               VALIDATE (tel_nrdevias < 11,"119 - Numero de vias errado.")
     SKIP(1)
     tel_inexecut AT 22 LABEL "Geracao Processo" AUTO-RETURN
                        HELP "S p/gerar no processo e N p/gerar durante o dia."
               VALIDATE (tel_inexecut = "S" OR tel_inexecut = "N",
                         "024 - Deve ser S ou N.")
     SKIP (1)
     tel_insitsol AT 22 LABEL "Situacao        "
     tel_dssitsol AT 42 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol043.

VIEW FRAME f_moldura.

aux_lstipsai = " - ARQUIVO, - REL. P/CONTA-CORRENTE, - REL. P/CADASTRO," +
               " - ARQ + REL.P/CONTA-CORRENTE, - ARQ + REL.P/CADASTRO".

glb_cddopcao = "I".

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol043.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrseqsol WITH FRAME f_sol043.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL043"   THEN
                 DO:
                     HIDE FRAME f_sol043.
                     HIDE FRAME f_moldura.
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

   ASSIGN tel_inexecut = "S"
          tel_vldaurvs = 0
          glb_cdcritic = 0.

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

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
                                glb_cdcritic = 115.
                                CLEAR FRAME f_sol043.
                            END.
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic = 0 THEN
                    IF   crapsol.insitsol <> 1 THEN
                         ASSIGN glb_cdcritic = 150
                                aux_contador = 1.

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper       AND 
                                  crapemp.cdempres = crapsol.cdempres
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE (crapemp) THEN
                    tel_dsempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_dsempres = " - NAO CADASTRADA".

               ASSIGN tel_cdempres = crapsol.cdempres
                      tel_intipsai = INTEGER(SUBSTRING(crapsol.dsparame,1,1))
                      tel_tpdebito = INTEGER(SUBSTRING(crapsol.dsparame,5,1))
                      tel_dsdebito = IF tel_tpdebito = 1
                                        THEN " - EM REAIS"
                                        ELSE " - EM URV"
                      tel_vldaurvs = DECIMAL(SUBSTRING(crapsol.dsparame,7,9))
                      tel_cdcalcul = INTEGER(SUBSTRING(crapsol.dsparame,17,3))
                      tel_nrdevias = crapsol.nrdevias
                      tel_inexecut = IF (SUBSTRING(crapsol.dsparame,3,1)) = "1"
                                        THEN "S"
                                        ELSE "N"
                      tel_insitsol = crapsol.insitsol
                      tel_dssitsol = IF crapsol.insitsol = 1
                                        THEN " - A FAZER"
                                        ELSE " - PROCESSADA"

                      tel_dstipsai = ENTRY(tel_intipsai,aux_lstipsai).

               DISPLAY tel_cdempres tel_dsempres tel_intipsai tel_dstipsai
                       tel_nrdevias tel_inexecut tel_insitsol tel_dssitsol
                       tel_cdcalcul WITH FRAME f_sol043.

               DO WHILE TRUE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_cdempres tel_cdcalcul tel_intipsai tel_nrdevias
                         tel_inexecut WITH FRAME f_sol043.

                  FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND 
                                     crapemp.cdempres = tel_cdempres
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapemp THEN
                       DO:
                           glb_cdcritic = 40.
                           NEXT.
                       END.
                  ELSE
                       IF   crapemp.tpdebemp = 2 OR
                            crapemp.tpdebemp = 3 THEN
                            DO:
                                glb_cdcritic = 440.
                                NEXT-PROMPT tel_cdempres.
                                NEXT.
                            END.

                  IF   (tel_intipsai = 1 AND tel_nrdevias > 0) OR
                       (tel_intipsai > 1 AND tel_nrdevias = 0) THEN
                       DO:
                           glb_cdcritic = 119.
                           NEXT-PROMPT tel_nrdevias WITH FRAME f_sol043.
                           NEXT.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         aux_inexecut     = IF tel_inexecut = "S" THEN 1 ELSE 2
                         tel_tpdebito = 1
                         tel_vldaurvs = 0
                         crapsol.nrdevias = tel_nrdevias
                         crapsol.dsparame = STRING(tel_intipsai,"9") + " " +
                                            STRING(aux_inexecut,"9") + " " +
                                            STRING(tel_tpdebito,"9") + " " +
                                            STRING(tel_vldaurvs,"999999.99") +
                                            " " + STRING(tel_cdcalcul,"999").

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol043 NO-PAUSE.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
         
            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                               crapsol.nrsolici = aux_nrsolici   AND
                               crapsol.dtrefere = glb_dtmvtolt   AND
                               crapsol.nrseqsol = tel_nrseqsol
                               USE-INDEX crapsol1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapsol   THEN
                 DO:
                     ASSIGN glb_cdcritic = 115.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol043.
                     NEXT.
                 END.

            FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND 
                               crapemp.cdempres = crapsol.cdempres
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE crapemp   THEN
                 tel_dsempres = " - " + crapemp.nmresemp.
            ELSE
                 tel_dsempres = " - NAO CADASTRADA".

            ASSIGN tel_cdempres = crapsol.cdempres
                   tel_intipsai = INTEGER(SUBSTRING(crapsol.dsparame,1,1))
                   tel_dstipsai = ENTRY(tel_intipsai,aux_lstipsai)
                   tel_tpdebito = INTEGER(SUBSTRING(crapsol.dsparame,5,1))
                   tel_dsdebito = IF tel_tpdebito = 1
                                     THEN " - EM REAIS"
                                     ELSE " - EM URV"
                   tel_vldaurvs = DECIMAL(SUBSTRING(crapsol.dsparame,7,9))
                   tel_cdcalcul = INTEGER(SUBSTRING(crapsol.dsparame,17,3))
                   tel_nrdevias = crapsol.nrdevias
                   tel_inexecut = IF (SUBSTRING(crapsol.dsparame,3,1)) = "1"
                                      THEN "S"
                                      ELSE "N"
                   tel_insitsol = crapsol.insitsol
                   tel_dssitsol = IF crapsol.insitsol = 1
                                     THEN " - A FAZER"
                                     ELSE " - PROCESSADA".

            DISPLAY tel_cdempres tel_dsempres tel_intipsai tel_dstipsai
                    tel_nrdevias tel_inexecut tel_insitsol tel_dssitsol
                    tel_cdcalcul WITH FRAME f_sol043.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

                  FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                     crapsol.nrsolici = aux_nrsolici   AND
                                     crapsol.dtrefere = glb_dtmvtolt   AND
                                     crapsol.nrseqsol = tel_nrseqsol
                                     USE-INDEX crapsol1
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
                                glb_cdcritic = 115.
                                CLEAR FRAME f_sol043.
                            END.
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper       AND 
                                  crapemp.cdempres = crapsol.cdempres
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapemp   THEN
                    tel_dsempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_dsempres = " - NAO CADASTRADA".

               ASSIGN tel_cdempres = crapsol.cdempres
                      tel_intipsai = INTEGER(SUBSTRING(crapsol.dsparame,1,1))
                      tel_dstipsai = ENTRY(tel_intipsai,aux_lstipsai)
                      tel_tpdebito = INTEGER(SUBSTRING(crapsol.dsparame,5,1))
                      tel_dsdebito = IF tel_tpdebito = 1
                                        THEN " - EM REAIS"
                                        ELSE " - EM URV"
                      tel_vldaurvs = DECIMAL(SUBSTRING(crapsol.dsparame,7,9))
                      tel_cdcalcul = INTEGER(SUBSTRING(crapsol.dsparame,17,3))
                      tel_nrdevias = crapsol.nrdevias
                      tel_inexecut = IF (SUBSTRING(crapsol.dsparame,3,1)) = "1"
                                         THEN "S"
                                         ELSE "N"
                      tel_insitsol = crapsol.insitsol
                      tel_dssitsol = IF crapsol.insitsol = 1
                                        THEN " - A FAZER"
                                        ELSE " - PROCESSADA".

               DISPLAY tel_cdempres tel_dsempres tel_intipsai tel_dstipsai
                       tel_nrdevias tel_inexecut tel_insitsol tel_dssitsol
                       tel_cdcalcul WITH FRAME f_sol043.

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
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               DELETE crapsol.
               CLEAR FRAME f_sol043 NO-PAUSE.

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
                                        crapsol.nrseqsol = tel_nrseqsol
                                        USE-INDEX crapsol1)   THEN
                 DO:
                     glb_cdcritic = 118.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol043.
                     NEXT.
                 END.

            CLEAR FRAME f_sol043 NO-PAUSE.
            DISPLAY glb_cddopcao tel_nrseqsol WITH FRAME f_sol043.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = aux_nrsolici
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = tel_nrseqsol
                      crapsol.cdcooper = glb_cdcooper

                      tel_cdempres     = 0
                      tel_cdcalcul     = 0
                      tel_intipsai     = 0
                      tel_nrdevias     = 0.

               DO WHILE TRUE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_cdempres tel_cdcalcul tel_intipsai tel_nrdevias
                         tel_inexecut WITH FRAME f_sol043.

                  FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND 
                                     crapemp.cdempres = tel_cdempres
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapemp THEN
                       DO:
                           glb_cdcritic = 40.
                           NEXT.
                       END.
                  ELSE
                       IF   crapemp.tpdebemp = 2 OR
                            crapemp.tpdebemp = 3 THEN
                            DO:
                                glb_cdcritic = 440.
                                NEXT-PROMPT tel_cdempres.
                                NEXT.
                            END.

                  IF   (tel_intipsai = 1 AND tel_nrdevias > 0) OR
                       (tel_intipsai > 1 AND tel_nrdevias = 0) THEN
                       DO:
                           glb_cdcritic = 119.
                           NEXT-PROMPT tel_nrdevias WITH FRAME f_sol043.
                           NEXT.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         aux_inexecut     = IF tel_inexecut = "S"
                                               THEN 1
                                               ELSE 2
                         tel_tpdebito = 1
                         tel_vldaurvs = 0
                         crapsol.dsparame = STRING(tel_intipsai,"9") + " " +
                                            STRING(aux_inexecut,"9") + " " +
                                            STRING(tel_tpdebito,"9") + " " +
                                            STRING(tel_vldaurvs,"999999.99") +
                                            " " + STRING(tel_cdcalcul,"999")
                         crapsol.insitsol = 1
                         crapsol.nrdevias = tel_nrdevias.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol043 NO-PAUSE.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

