/* .............................................................................

   Programa: Fontes/sol045.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94                          Ultima atualizacao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL045.

   Alteracoes: 10/05/1995 - Permitido solicitar integracoes de 2 meses atras.
                          (Deborah).

               25/03/1998 - Tratamento para milenio e troca para V8 (Margarete).

               07/10/2004 - Chamada do programa 085 para o caso de escolher nao
                            integrar no processo (Julio)

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               28/06/2006 - Melhorias na consistencia do arquivo de integracao
                            (Julio)
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               10/10/2013 - SD 93349. Retirado o parametro NEW na chamada
                            de crps085 para impressao direta pelo usuario,
                            ao inves de ir para processo noturno (Carlos)
                            
               27/12/2013 - SD 108354 - inclusao da opcao R para reimprimir
                            o relatorio (Carlos)
							
			   25/03/2014 - Ajuste processo busca impressora (Daniel). 	
............................................................................. */

{ includes/var_online.i } 

DEF STREAM str_grep.

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(17)"                NO-UNDO.
DEF        VAR tel_dialiber AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_inexecut AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR tel_insitsol AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_inexecut AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 45           NO-UNDO.

DEF        VAR aux_tpintegr AS CHAR    INIT "e"                      NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(21)"                NO-UNDO.
DEF        VAR prn_nmdafila AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEf        VAR aux_grep     AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_nmimpres AS CHAR    FORMAT "x(15)"                NO-UNDO.

FORM SKIP(1)
     glb_nmdafila LABEL "  Imprimir em" " "
     SKIP(1)
     WITH ROW 14 CENTERED OVERLAY SIDE-LABELS 
          TITLE COLOR NORMAL " Destino " FRAME f_nmdafila.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE COLOR MESSAGE " Creditos de Emprestimos "
                   FRAME f_moldura.

FORM
SKIP (1)
glb_cddopcao AT  4 LABEL "Opcao           " AUTO-RETURN
                   HELP "Entre com a opcao desejada (A,C,E,I ou R)"
                   VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                             glb_cddopcao = "E" OR glb_cddopcao = "I" OR
                             glb_cddopcao = "R",
                             "014 - Opcao errada.")
SKIP (1)
tel_nrseqsol AT  4 LABEL "Sequencia       " AUTO-RETURN
                   HELP "Entre com o numero de sequencia da solicitacao."
                   VALIDATE (tel_nrseqsol > 0,
                             "117 - Sequencia errada.")

SKIP(1)
tel_cdempres AT  4 LABEL "Empresa         " AUTO-RETURN
                   HELP "Entre com o codigo da empresa."
                   VALIDATE (CAN-FIND (crapemp WHERE 
                                       crapemp.cdcooper = glb_cdcooper AND 
                                       crapemp.cdempres = tel_cdempres),
                                       "040 - Empresa nao cadastrada.")
tel_dsempres AT 27 NO-LABEL

SKIP (1)
tel_dtrefere AT  4 LABEL "Data Referencia " AUTO-RETURN
                   HELP "Entre com a data a que se refere o pagamento."
                   VALIDATE (tel_dtrefere <> ?,"013 - Data errada.")
SKIP (1)
tel_inexecut AT  4 LABEL "Integr. Processo" AUTO-RETURN
                 HELP "S p/integrar no processo e N p/integrar durante o dia."
                   VALIDATE (tel_inexecut = "S" OR tel_inexecut = "N",
                             "024 - Deve ser S ou N.")
SKIP (1)
tel_insitsol AT  4 LABEL "Situacao        "
tel_dssitsol AT 24 NO-LABEL

WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol045.

VIEW FRAME f_moldura.

glb_cddopcao = "I".

PAUSE(0).

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol045.
        NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol045.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           PROMPT-FOR glb_cddopcao tel_nrseqsol
                      WITH FRAME f_sol045.
           LEAVE.

        END.
          
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL045"   THEN
                      DO:
                          HIDE FRAME f_integra.
                          HIDE FRAME f_sol045.
                          HIDE FRAME f_moldura.
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
         
        { includes/listaint.i }
          
        ASSIGN tel_nrseqsol = INPUT tel_nrseqsol
               aux_nrseqsol = INPUT tel_nrseqsol
               glb_cddopcao = INPUT glb_cddopcao
               tel_inexecut = "N"
               glb_cdcritic = 0.
            
        IF   INPUT glb_cddopcao = "A" THEN
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
                                      glb_cdcritic = 115.
                                      CLEAR FRAME f_sol045.
                                      LEAVE.
                                  END.
                        ELSE
                             DO:
                                 aux_contador = 0.
                                 LEAVE.
                             END.
                    END.

                    IF   aux_contador = 0 THEN
                         IF   crapsol.insitsol <> 1 THEN
                              ASSIGN glb_cdcritic = 150
                                     aux_contador = 1.

                    IF   aux_contador <> 0   THEN
                         DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             ASSIGN tel_nrseqsol = aux_nrseqsol.
                             DISPLAY tel_nrseqsol WITH FRAME f_sol045.
                             NEXT.
                         END.

                    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                                       crapemp.cdempres = crapsol.cdempres
                                       NO-LOCK NO-ERROR.

                    IF   AVAILABLE (crapemp) THEN
                         tel_dsempres = " - " + crapemp.nmresemp.
                    ELSE
                         tel_dsempres = " - NAO CADASTRADA".

                    ASSIGN tel_cdempres = crapsol.cdempres
                           tel_dtrefere =
                           DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                           tel_dialiber =
                               INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                           tel_inexecut = IF
                               (SUBSTRING(crapsol.dsparame,15,1)) = "1" THEN
                                "S" ELSE "N"
                           tel_insitsol = crapsol.insitsol
                           tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                             " - A FAZER"         ELSE
                                             " - PROCESSADA".
                    DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                            tel_inexecut tel_insitsol tel_dssitsol
                            WITH FRAME f_sol045.

                    DO WHILE TRUE:

                       SET  tel_cdempres tel_dtrefere tel_inexecut
                            WITH FRAME f_sol045.

                       IF   YEAR(tel_dtrefere)  = YEAR(glb_dtmvtolt) - 1   AND
                            MONTH(tel_dtrefere) = 12                       THEN
                            glb_cdcritic = 0.
                       ELSE
                       IF   MONTH(tel_dtrefere) > MONTH(glb_dtmvtolt)       OR
                            MONTH(tel_dtrefere) < (MONTH(glb_dtmvtolt) - 2)
                            THEN
                            DO:
                                ASSIGN glb_cdcritic = 13.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT-PROMPT tel_dtrefere WITH FRAME f_sol045.
                                NEXT.
                            END.

                       ASSIGN crapsol.cdempres = tel_cdempres
                              aux_inexecut     = IF   tel_inexecut = "S" THEN
                                                      1 ELSE 2
                              crapsol.dsparame =
                                      STRING(tel_dtrefere,"99/99/9999") + " " +
                                      STRING(tel_dialiber,"99")         + " " +
                                      STRING(aux_inexecut,"9").

                       LEAVE.

                    END.

                 END. /* Fim da transacao */

                 RELEASE crapsol.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_sol045 NO-PAUSE.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
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
                          CLEAR FRAME f_sol045.
                          ASSIGN tel_nrseqsol = aux_nrseqsol.
                          DISPLAY tel_nrseqsol WITH FRAME f_sol045.
                          NEXT.
                      END.

                 FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                                    crapemp.cdempres = crapsol.cdempres
                                    NO-LOCK NO-ERROR.

                 IF   AVAILABLE (crapemp) THEN
                      tel_dsempres = " - " + crapemp.nmresemp.
                 ELSE
                      tel_dsempres = " - NAO CADASTRADA".
                 
                 ASSIGN tel_cdempres = crapsol.cdempres
                        tel_dtrefere =
                            DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                 INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                        tel_dialiber =
                            INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                        tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                       = "1" THEN "S" ELSE "N"
                        tel_insitsol = crapsol.insitsol
                        tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                          " - A FAZER"         ELSE
                                          " - PROCESSADA".
                 DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                         tel_inexecut tel_insitsol tel_dssitsol
                         WITH FRAME f_sol045.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "E"   THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                           crapsol.nrsolici = aux_nrsolici   AND
                                           crapsol.dtrefere = glb_dtmvtolt   AND
                                           crapsol.nrseqsol = tel_nrseqsol
                                           USE-INDEX crapsol1
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
                                      ASSIGN glb_cdcritic = 115.
                                      CLEAR FRAME f_sol045.
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
                             ASSIGN tel_nrseqsol = aux_nrseqsol.
                             DISPLAY tel_nrseqsol WITH FRAME f_sol045.
                             NEXT.
                         END.

                    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                                       crapemp.cdempres = crapsol.cdempres
                                       NO-LOCK NO-ERROR.

                    IF   AVAILABLE (crapemp) THEN
                         tel_dsempres = " - " + crapemp.nmresemp.
                    ELSE
                         tel_dsempres = " - NAO CADASTRADA".

                    ASSIGN tel_cdempres = crapsol.cdempres
                           tel_dtrefere =
                               DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                           tel_dialiber =
                               INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                           tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                          = "1" THEN "S" ELSE "N"
                           tel_insitsol = crapsol.insitsol
                           tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                             " - A FAZER"         ELSE
                                             " - PROCESSADA".
                    DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                            tel_inexecut tel_insitsol tel_dssitsol
                            WITH FRAME f_sol045.

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
                    CLEAR FRAME f_sol045 NO-PAUSE.

                 END. /* Fim da transacao */
                      
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.
             END.
        ELSE
        IF   INPUT glb_cddopcao = "I"   THEN
             DO:

                 ASSIGN tel_cdempres = 0
                        tel_dtrefere = ?
                        tel_inexecut = "N".

                 CLEAR FRAME f_sol045 NO-PAUSE.
                  
                 DISPLAY glb_cddopcao tel_nrseqsol WITH FRAME f_sol045.

                 FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                    crapsol.nrsolici = aux_nrsolici   AND
                                    crapsol.dtrefere = glb_dtmvtolt   AND
                                    crapsol.nrseqsol = tel_nrseqsol
                                    USE-INDEX crapsol1 NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE crapsol   THEN
                      DO:
                          ASSIGN glb_cdcritic = 118.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_sol045.
                          ASSIGN tel_nrseqsol = aux_nrseqsol.
                          DISPLAY tel_nrseqsol WITH FRAME f_sol045.
                          NEXT.
                      END.

                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    CREATE crapsol.
                    ASSIGN crapsol.nrsolici = aux_nrsolici
                           crapsol.dtrefere = glb_dtmvtolt
                           crapsol.nrseqsol = tel_nrseqsol
                           crapsol.cdcooper = glb_cdcooper.

                    DO WHILE TRUE:

                       UPDATE tel_cdempres tel_dtrefere tel_inexecut
                              WITH FRAME f_sol045.

                       IF   YEAR(tel_dtrefere)  = YEAR(glb_dtmvtolt) - 1   AND
                            MONTH(tel_dtrefere) = 12                       THEN
                            glb_cdcritic = 0.
                       ELSE
                       IF   MONTH(tel_dtrefere) > MONTH(glb_dtmvtolt)   OR
                            MONTH(tel_dtrefere) < (MONTH(glb_dtmvtolt) - 2)
                            THEN
                            DO:
                                ASSIGN glb_cdcritic = 13.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT-PROMPT tel_dtrefere WITH FRAME f_sol045.
                                NEXT.
                            END.

                       ASSIGN crapsol.cdempres = tel_cdempres
                              aux_inexecut     = IF   tel_inexecut = "S" THEN
                                                      1 ELSE 2
                              crapsol.dsparame =
                                 STRING(tel_dtrefere,"99/99/9999") + " " +
                                 STRING(tel_dialiber,"99") + " " +
                                 STRING(aux_inexecut,"9")
                              crapsol.insitsol = 1
                              crapsol.nrdevias = 1.
                       LEAVE.
                    END.

                 END. /* Fim da transacao */

                 RELEASE crapsol.
                 
                 IF   tel_inexecut = "N"   THEN
                      DO:
                          MESSAGE COLOR NORMAL "Integrando...".
                          
                          RUN fontes/crps085.p.

                          IF RETURN-VALUE <> "0" THEN
                             DO:
                                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:
                                    FIND crapsol WHERE 
                                            crapsol.cdcooper = glb_cdcooper AND 
                                            crapsol.nrsolici = aux_nrsolici AND
                                            crapsol.dtrefere = glb_dtmvtolt AND
                                            crapsol.nrseqsol = tel_nrseqsol
                                            EXCLUSIVE-LOCK NO-ERROR.
                                          
                                    IF   AVAILABLE crapsol   THEN         
                                         DELETE crapsol.
                                 END. /* transaction */

                                 ASSIGN glb_cdcritic = INT(RETURN-VALUE).
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 NEXT-PROMPT tel_dtrefere WITH FRAME f_sol045.
                                 ASSIGN glb_cdcritic = 0.
                                 NEXT.
                             END.
                      END.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_sol045 NO-PAUSE.

             END.
        ELSE
        /* Recuperar a impressão de críticas dos arquivos integrados  */
        IF  INPUT glb_cddopcao = "R"  THEN
            DO:
                DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                           crapsol.nrsolici = aux_nrsolici   AND
                                           crapsol.dtrefere = glb_dtmvtolt   AND
                                           crapsol.nrseqsol = tel_nrseqsol
                                           NO-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAILABLE crapsol   THEN
                            IF  LOCKED crapsol   THEN
                                DO:
                                    glb_cdcritic = 120.
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    glb_cdcritic = 115.
                                    CLEAR FRAME f_sol045.
                                    LEAVE.
                                END.
                    END.

                    IF  glb_cdcritic <> 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            NEXT.
                        END.

                    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                                       crapemp.cdempres = crapsol.cdempres
                                       NO-LOCK NO-ERROR.

                    IF   AVAILABLE (crapemp) THEN
                         tel_dsempres = " - " + crapemp.nmresemp.
                    ELSE
                         tel_dsempres = " - NAO CADASTRADA".

                    ASSIGN tel_cdempres = crapsol.cdempres
                           tel_dtrefere =
                           DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                           tel_dialiber =
                               INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                           tel_inexecut = IF
                               (SUBSTRING(crapsol.dsparame,15,1)) = "1" THEN
                                "S" ELSE "N"
                           tel_insitsol = crapsol.insitsol
                           tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                             " - A FAZER"         ELSE
                                             " - PROCESSADA".
                    DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                            tel_inexecut tel_insitsol tel_dssitsol
                            WITH FRAME f_sol045.

                END. /* Fim da transacao */

                ASSIGN aux_nmarquiv = "rlnsv/crrl072_" +
                                      STRING(crapsol.nrseqsol,"999") + ".lst".
                RELEASE crapsol.

                IF  SEARCH(aux_nmarquiv) = ?  THEN
                DO:
                    MESSAGE "Arquivo nao disponivel para reimpressao.".
                    NEXT.
                END.

                /* confirmar reimpressao */
                ASSIGN aux_confirma = "N".
                BELL.
                MESSAGE COLOR NORMAL "Reimprimir relatorio?"
                    UPDATE aux_confirma.
                
                IF  aux_confirma = "S" THEN
                    DO:
                        MESSAGE COLOR NORMAL "Imprimindo.....".

                        ASSIGN glb_nmarqimp = aux_nmarquiv
                               glb_nrcopias = 1
                               glb_nrdevias = 1
                               glb_nmformul = "padrao"
                               prn_nmdafila = glb_nmdafila.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                            UPDATE glb_nmdafila WITH FRAME f_nmdafila.

                            IF  glb_nmdafila <> prn_nmdafila   THEN

                                ASSIGN aux_grep = ""
                                 	   aux_nmimpres = "^" + glb_nmdafila + ":".
                                
                                INPUT STREAM str_grep THROUGH
                                	VALUE ('grep -Ew "' + aux_nmimpres + '" /etc/qconfig' ) NO-ECHO.
                                
                                DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                                	IMPORT STREAM str_grep UNFORMATTED aux_grep.
                                END.
                                
                                IF TRIM(aux_grep) = "" THEN
/*
                                IF  SEARCH("/var/spool/lp/interface/" + 
                                            TRIM(glb_nmdafila)) = ? THEN */
                                    DO:
                                        BELL.
                                        MESSAGE "Impressora nao cadastrada -" glb_nmdafila.
                                        NEXT.
                                    END.
                                
                            HIDE FRAME f_nmdafila NO-PAUSE.

                            LEAVE.

                        END. /*  Fim do DO WHILE TRUE  */
                             
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                            DO:
                               BELL.
                                   glb_nmdafila = prn_nmdafila.
                                   HIDE FRAME f_nmdafila NO-PAUSE.
                                   MESSAGE "Impressao NAO efetuada...".
                                   RETURN.
                            END.
                                             
                        aux_dscomand = "lp -d" + glb_nmdafila +
                                       " -n" + STRING(glb_nrdevias) +   
                                       " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                                       glb_nmarqimp +
                                       " > /dev/null".
                    
                        UNIX SILENT VALUE(aux_dscomand).
                        
                        glb_nmdafila = prn_nmdafila.

                    END.
                ELSE
                    DO:
                        MESSAGE COLOR NORMAL
                            "Reimpressao cancelada.".
                        ASSIGN glb_cdcritic = 0.
                        PAUSE.
                        UNDO, LEAVE.        
                    END.


                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                    NEXT.

                CLEAR FRAME f_sol045 NO-PAUSE.
            END.
END.
/* .......................................................................... */
