/* .............................................................................

   Programa: Fontes/taxmes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 22/09/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAXMES -- Taxas de juros utilizadas no mes

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

               10/11/94 - Alterado para tratar tabela de juros s/saque s/blo-
                          queado (Deborah).

               30/01/95 - Alterado para permitir a variacao do ufir zero na
                          tela (Deborah).

               15/08/95 - Alterado para capitalizar o calculo da taxa mensal
                          (Edson).

               02/12/96 - Alterado para permitir a manutencao do uso da taxa
                          dentro do mes corrente para os novos contratos   e
                          liquidacoes (opcao T) (Edson).

               17/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).
                            
               23/03/2003 - Tratar linhas de credito especiais da CONCREDI
                            (Junior).

               05/07/2005 - Alimentado campo cdcooper das tabelas crapsol e
                            craptab (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               04/08/2006 - Desativada Rotina que roda somente na CONCREDI
                            (Diego).
                            
               12/04/2007 - Substituir craptab "JUROSESPEC" pela craplrt. (Ze).
               
               03/12/2010 - Adicionado controle pra nao permitir que a data
                            final seja maior que a inicial (Henrique).
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
              
............................................................................. */

DEF BUFFER crabtab FOR craptab.

{ includes/var_online.i }

DEF        VAR tel_txrefmes AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txufrmes AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txlimite AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_dtiniper AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dtfimper AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_flgtxmes AS LOGICAL FORMAT "TR/UFIR" INIT TRUE    NO-UNDO.
DEF        VAR tel_dsobserv AS CHAR    FORMAT "x(40)" EXTENT 4       NO-UNDO.
DEF        VAR tel_nrcopias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_txmesln4 AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txdialn4 AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txmesln5 AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txdialn5 AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txmesln6 AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txdialn6 AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.

DEF        VAR aux_txutiliz AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txjurfix AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txjurvar AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txminima AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txmaxima AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txmensal AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txdiaria AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_tentaler AS INT                                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


FORM SKIP(1)
     glb_cddopcao    AT 29 LABEL "Opcao" AUTO-RETURN
                           HELP "Informe a opcao desejada (A, C, R ou T)."
                           VALIDATE(CAN-DO("A,C,R,T",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(1)
     tel_flgtxmes    AT 15 LABEL "Indexador Utilizado" AUTO-RETURN
                           HELP "Informe a taxa utilizada no mes: TR/UFIR."
     SKIP(1)
     tel_txrefmes    AT 11 LABEL "Taxa Referencial do Mes" AUTO-RETURN
                           HELP "Informe o valor da T.R. do mes."
                           VALIDATE(tel_txrefmes > 0,"185 - Taxa errada.")
     "%"             AT 47
     tel_txufrmes    AT 23 LABEL "UFIR do Mes" AUTO-RETURN
                           HELP "Informe o valor da UFIR do mes."
                     /*    VALIDATE(tel_txufrmes > 0,"185 - Taxa errada.") */
     "%"             AT 47
     SKIP(1)
     tel_txlimite    AT  3 LABEL "Reajuste dos Limites de Credito" AUTO-RETURN
                           HELP "Informe a taxa de reajuste dos limites"
     "%"             AT 47
     SKIP(1)
     tel_dtiniper    AT 19 LABEL "Periodo da T.R." AUTO-RETURN
                           HELP "Informe a data do inicio do periodo."
                           VALIDATE(tel_dtiniper <> ?,"013 - Data errada.")
     "a"             AT 47
     tel_dtfimper    AT 49 NO-LABEL AUTO-RETURN
                           HELP "Informe a data do final do periodo."
                           VALIDATE(INPUT tel_dtfimper >= INPUT tel_dtiniper,
                                    "013 - Data errada.")
     SKIP(1)
     tel_dsobserv[1] AT 23 LABEL "Observacoes" AUTO-RETURN
                           HELP "Informe (se houver) a observacao do mes."
     SKIP
     tel_dsobserv[2] AT 36 NO-LABEL AUTO-RETURN
                           HELP "Informe (se houver) a observacao do mes."
     SKIP
     tel_dsobserv[3] AT 36 NO-LABEL AUTO-RETURN
                           HELP "Informe (se houver) a observacao do mes."
     SKIP
     tel_dsobserv[4] AT 36 NO-LABEL AUTO-RETURN
                           HELP "Informe (se houver) a observacao do mes."
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_taxmes.

FORM SKIP(1)
     "Tx. Mensal     Tx. Diaria"  AT 32
     SKIP
     "   Linha 4 - 2,35 + TBF: " AT 2
     SPACE(5)
     tel_txmesln4          HELP "Informe a taxa mensal."
     SPACE(5)
     tel_txdialn4          HELP "Informe a taxa diaria."
     SKIP(1)
     "   Linha 5 - 1,30 + TBF: " AT 2
     SPACE(5)
     tel_txmesln5          HELP "Informe a taxa mensal."
     SPACE(5)
     tel_txdialn5          HELP "Informe a taxa diaria."
     SKIP(1)
      "   Linha 6 - 1,55 + TBF: " AT 2
     SPACE(5)
     tel_txmesln6          HELP "Informe a taxa mensal."
     SPACE(5)
     tel_txdialn6          HELP "Informe a taxa diaria."
     SKIP(1)
     WITH ROW 11 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          " LINHAS ESPECIAIS DE CREDITO - CONCREDI " FRAME f_linesp.

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
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao WITH FRAME f_taxmes

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

      IF   glb_cdcooper <> 3 THEN
           DO:
               IF   glb_cddopcao = "A"  OR
                    glb_cddopcao = "T"  THEN
                    glb_cdcritic = 323.           
           END.
      
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "TAXMES"   THEN
                 DO:
                     HIDE FRAME f_taxmes.
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

   IF   glb_cddopcao = "A" THEN
        DO TRANSACTION ON ENDKEY UNDO, LEAVE:

           DO aux_tentaler = 1 TO 10:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                                 craptab.nmsistem = "CRED"             AND
                                 craptab.tptabela = "GENERI"           AND
                                 craptab.cdempres = 0                  AND
                                 craptab.cdacesso = "TAXASDOMES"       AND
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

                            glb_cdcritic = 0.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 55.
              ELSE
                   glb_cdcritic = 0.

              LEAVE.

           END.  /*  Fim do DO .. TO  */

           IF   glb_cdcritic > 0   THEN
                UNDO, NEXT.

           DO aux_tentaler = 1 TO 10:

              FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper    AND
                                 crabtab.nmsistem = "CRED"          AND
                                 crabtab.tptabela = "USUARI"        AND
                                 crabtab.cdempres = 11              AND
                                 crabtab.cdacesso = "REAJLIMITE"    AND
                                 crabtab.tpregist = 1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crabtab   THEN
                   IF   LOCKED crabtab   THEN
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
                            
                            glb_cdcritic = 0.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 55.
              ELSE
                   glb_cdcritic = 0.

              LEAVE.

           END.  /*  Fim do DO .. TO  */

           IF   glb_cdcritic > 0   THEN
                UNDO, NEXT.

           ASSIGN tel_flgtxmes = IF SUBSTRING(craptab.dstextab,1,1) = "T"
                                    THEN TRUE
                                    ELSE FALSE

                  tel_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,03,10))
                  tel_txufrmes = DECIMAL(SUBSTRING(craptab.dstextab,14,10))

                  tel_dtiniper = DATE(INTEGER(SUBSTR(craptab.dstextab,27,02)),
                                      INTEGER(SUBSTR(craptab.dstextab,25,02)),
                                      INTEGER(SUBSTR(craptab.dstextab,29,04)))

                  tel_dtfimper = DATE(INTEGER(SUBSTR(craptab.dstextab,36,02)),
                                      INTEGER(SUBSTR(craptab.dstextab,34,02)),
                                      INTEGER(SUBSTR(craptab.dstextab,38,04)))

                  tel_dsobserv[1] = SUBSTRING(craptab.dstextab,043,40)
                  tel_dsobserv[2] = SUBSTRING(craptab.dstextab,083,40)
                  tel_dsobserv[3] = SUBSTRING(craptab.dstextab,123,40)
                  tel_dsobserv[4] = SUBSTRING(craptab.dstextab,163,40)

                  tel_txlimite    = DECIMAL(SUBSTRING(crabtab.dstextab,1,10)).

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_flgtxmes tel_txrefmes tel_txufrmes tel_txlimite
                     tel_dtiniper tel_dtfimper tel_dsobserv
                     WITH FRAME f_taxmes

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

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 IF   FRAME-FIELD = "tel_txrefmes"   OR
                      FRAME-FIELD = "tel_txufrmes"   OR
                      FRAME-FIELD = "tel_txlimite"   THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.

              END.  /*  Fim do EDITING  */

              IF   MONTH(glb_dtmvtolt) = MONTH(tel_dtiniper)   AND
                    YEAR(glb_dtmvtolt) =  YEAR(tel_dtiniper)   THEN
                   .
              ELSE
                   DO:
                       MESSAGE "A data de inicio do periodo nao e' do mes"
                               "corrente.".

                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                          aux_confirma = "N".

                          glb_cdcritic = 78.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                          glb_cdcritic = 0.
                          LEAVE.

                       END.  /*  Fim do DO WHILE TRUE  */

                       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                            aux_confirma <> "S"   THEN
                            DO:
                                NEXT-PROMPT tel_dtiniper WITH FRAME f_taxmes.
                                NEXT.
                            END.
                   END.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                NEXT.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              aux_confirma = "N".

              glb_cdcritic = 78.
              RUN fontes/critic.p.
              BELL.
              MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
              glb_cdcritic = 0.
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
                    UNDO, NEXT.
                END.

           ASSIGN craptab.dstextab = (IF tel_flgtxmes THEN "T" ELSE "U") + " " +
                                     STRING(tel_txrefmes,"999.999999") + " " +
                                     STRING(tel_txufrmes,"999.999999") + " " +
                                     STRING(tel_dtiniper,"99999999") + " " +
                                     STRING(tel_dtfimper,"99999999") + " " +
                                     STRING(tel_dsobserv[1],"x(40)") +
                                     STRING(tel_dsobserv[2],"x(40)") +
                                     STRING(tel_dsobserv[3],"x(40)") +
                                     STRING(tel_dsobserv[4],"x(40)")

                  crabtab.dstextab = STRING(tel_txlimite,"999.999999")

                  craptab.dstextab = CAPS(craptab.dstextab)

                  aux_txutiliz     = IF tel_flgtxmes
                                        THEN tel_txrefmes
                                        ELSE tel_txufrmes.

           HIDE MESSAGE NO-PAUSE.

           MESSAGE "Aguarde, atualizando as taxas de juros...".
           PAUSE 2 NO-MESSAGE.


           /*  Atualizando a taxa de juros para o cheque especial  */

           FOR EACH craplrt WHERE craplrt.cdcooper = glb_cdcooper 
                                  EXCLUSIVE-LOCK:
           
               ASSIGN craplrt.txmensal = 
                      ROUND(((aux_txutiliz * (craplrt.txjurvar / 100) + 100) *
                             (1 + (craplrt.txjurfix / 100)) - 100),6).

           END.  /*  Fim da atualizacao da taxa de juros para chq. especial */


           /*  Atualizando a taxa de juros para o saque s/bloqueado */

           DO WHILE TRUE:

              FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper   AND
                                 crabtab.nmsistem = "CRED"         AND
                                 crabtab.tptabela = "USUARI"       AND
                                 crabtab.cdempres = 11             AND
                                 crabtab.cdacesso = "JUROSSAQUE"   AND
                                 crabtab.tpregist = 1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crabtab   THEN
                   IF   LOCKED crabtab   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 418.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    UNDO, NEXT.
                END.

           ASSIGN aux_txjurfix = DECIMAL(SUBSTRING(crabtab.dstextab,12,06))
                  aux_txjurvar = DECIMAL(SUBSTRING(crabtab.dstextab,19,06))

                  aux_txmensal = ROUND(((aux_txutiliz * (aux_txjurvar / 100) +
                                   100) * (1 + (aux_txjurfix / 100)) - 100),6)

                  crabtab.dstextab = STRING(aux_txmensal,"999.999999") +
                                     SUBSTRING(crabtab.dstextab,11,14).

           /*  Atualizando a taxa de juros para os saldos negativos - MULTA  */

           DO WHILE TRUE:

              FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper   AND
                                 crabtab.nmsistem = "CRED"         AND
                                 crabtab.tptabela = "USUARI"       AND
                                 crabtab.cdempres = 11             AND
                                 crabtab.cdacesso = "JUROSNEGAT"   AND
                                 crabtab.tpregist = 1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crabtab   THEN
                   IF   LOCKED crabtab   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 186.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    UNDO, NEXT.
                END.

           ASSIGN aux_txjurfix = DECIMAL(SUBSTRING(crabtab.dstextab,12,06))
                  aux_txjurvar = DECIMAL(SUBSTRING(crabtab.dstextab,19,06))

                  aux_txmensal = ROUND(((aux_txutiliz * (aux_txjurvar / 100) +
                                   100) * (1 + (aux_txjurfix / 100)) - 100),6)

                  crabtab.dstextab = STRING(aux_txmensal,"999.999999") +
                                     SUBSTRING(crabtab.dstextab,11,14).

           /*  Alterando as linhas de credito  */

           FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper                                          EXCLUSIVE-LOCK:

               IF   glb_cdcooper = 4 AND 
                    (craplcr.cdlcremp = 4 OR craplcr.cdlcremp = 5 OR 
                     craplcr.cdlcremp = 6) THEN
                     NEXT.
               
               ASSIGN aux_txjurfix = craplcr.txjurfix
                      aux_txjurvar = craplcr.txjurvar
                      aux_txminima = craplcr.txminima
                      aux_txmaxima = craplcr.txmaxima

                    aux_txmensal = ROUND(((aux_txutiliz * (aux_txjurvar / 100) +
                                   100) * (1 + (aux_txjurfix / 100)) - 100),6)

                      aux_txmensal = IF aux_txminima > aux_txmensal
                                        THEN aux_txminima
                                        ELSE IF aux_txmaxima > 0  AND
                                                aux_txmaxima < aux_txmensal
                                                THEN aux_txmaxima
                                                ELSE aux_txmensal

                      aux_txdiaria = ROUND(aux_txmensal / 3000,7)

                      craplcr.txmensal = aux_txmensal
                      craplcr.txdiaria = aux_txdiaria.

           END.  /*  Fim do FOR EACH  --  Atualizacao das linhas de credito  */
           
           /******** Desativado *******************************************
           IF   glb_cdcooper = 4 then
                DO:

                    FIND craplcr WHERE  craplcr.cdcooper = glb_cdcooper AND
                                        craplcr.cdlcremp = 4 
                                        NO-LOCK NO-ERROR.
                      
                    IF   NOT AVAILABLE craplcr THEN
                         ASSIGN tel_txmesln4 = 0
                                tel_txdialn4 = 0.
                    ELSE     
                         ASSIGN tel_txmesln4 = craplcr.txmensal 
                                tel_txdialn4 = craplcr.txdiaria * 100.

                    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                       craplcr.cdlcremp = 5  
                                       NO-LOCK NO-ERROR.
                      
                    IF   NOT AVAILABLE craplcr THEN
                         ASSIGN tel_txmesln5 = 0
                                tel_txdialn5 = 0.
                    ELSE     
                         ASSIGN tel_txmesln5 = craplcr.txmensal
                                tel_txdialn5 = craplcr.txdiaria * 100.

                    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                       craplcr.cdlcremp = 6  
                                       NO-LOCK NO-ERROR.
                      
                    IF   NOT AVAILABLE craplcr THEN
                         ASSIGN tel_txmesln6 = 0
                                tel_txdialn6 = 0.
                    ELSE
                         ASSIGN tel_txmesln6 = craplcr.txmensal
                                tel_txdialn6 = craplcr.txdiaria * 100.

                    UPDATE tel_txmesln4 tel_txdialn4 tel_txmesln5 tel_txdialn5
                           tel_txmesln6 tel_txdialn6 WITH FRAME f_linesp.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       aux_confirma = "N".

                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S"   THEN
                         DO:
                             NEXT-PROMPT tel_dtiniper WITH FRAME f_taxmes.
                             UNDO,NEXT.
                         END.

                    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                       craplcr.cdlcremp = 4 
                                       EXCLUSIVE-LOCK NO-ERROR.
                      
                    IF   NOT AVAILABLE craplcr THEN
                         DO:
                             glb_cdcritic = 363.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE COLOR NORMAL glb_dscritic.
                             glb_cdcritic = 0.
                             UNDO,NEXT.
                         END.
                    ELSE     
                         ASSIGN craplcr.txmensal = tel_txmesln4 
                                craplcr.txdiaria = tel_txdialn4 / 100.

                    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                       craplcr.cdlcremp = 5 
                                       EXCLUSIVE-LOCK NO-ERROR.
                      
                    IF   NOT AVAILABLE craplcr THEN
                         DO:
                             glb_cdcritic = 363.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE COLOR NORMAL glb_dscritic.
                             glb_cdcritic = 0.
                             UNDO,NEXT.
                         END.
                    ELSE     
                         ASSIGN craplcr.txmensal = tel_txmesln5 
                                craplcr.txdiaria = tel_txdialn5 / 100.

                    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                       craplcr.cdlcremp = 6
                                       EXCLUSIVE-LOCK NO-ERROR.
                      
                    IF   NOT AVAILABLE craplcr THEN
                         DO:
                             glb_cdcritic = 363.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE COLOR NORMAL glb_dscritic.
                             glb_cdcritic = 0.
                             UNDO,NEXT.
                         END.
                    ELSE     
                         ASSIGN craplcr.txmensal = tel_txmesln6 
                                craplcr.txdiaria = tel_txdialn6 / 100.

                END.
           ***************************************************************/
                
           HIDE MESSAGE NO-PAUSE.

           glb_cddopcao = "C".

           CLEAR FRAME f_taxmes NO-PAUSE.

        END.  /*  Fim da transacao  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "TAXASDOMES"   AND
                               craptab.tpregist = 001
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 347.
                     NEXT.
                 END.

            FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper   AND
                               crabtab.nmsistem = "CRED"         AND
                               crabtab.tptabela = "USUARI"       AND
                               crabtab.cdempres = 11             AND
                               crabtab.cdacesso = "REAJLIMITE"   AND
                               crabtab.tpregist = 1
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crabtab   THEN
                 DO:
                     glb_cdcritic = 347.
                     NEXT.
                 END.

            ASSIGN tel_flgtxmes = IF SUBSTRING(craptab.dstextab,1,1) = "T"
                                     THEN TRUE
                                     ELSE FALSE

                   tel_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,03,10))
                   tel_txufrmes = DECIMAL(SUBSTRING(craptab.dstextab,14,10))

                   tel_dtiniper = DATE(INTEGER(SUBSTR(craptab.dstextab,27,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,25,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,29,04)))

                   tel_dtfimper = DATE(INTEGER(SUBSTR(craptab.dstextab,36,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,34,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,38,04)))

                   tel_dsobserv[1] = SUBSTRING(craptab.dstextab,043,40)
                   tel_dsobserv[2] = SUBSTRING(craptab.dstextab,083,40)
                   tel_dsobserv[3] = SUBSTRING(craptab.dstextab,123,40)
                   tel_dsobserv[4] = SUBSTRING(craptab.dstextab,163,40)

                   tel_txlimite    = DECIMAL(SUBSTRING(crabtab.dstextab,1,10)).

            DISPLAY tel_flgtxmes tel_txrefmes tel_txufrmes tel_txlimite
                    tel_dtiniper tel_dtfimper tel_dsobserv
                    WITH FRAME f_taxmes.
        END.
   ELSE
   IF   glb_cddopcao = "R" THEN
        DO:
            ASSIGN tel_nrcopias = 3
                   glb_cdcritic = 0.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               BELL.
               MESSAGE COLOR NORMAL
                       "Entre com o numero de copias a serem impressas:"
                       UPDATE tel_nrcopias.

               IF    tel_nrcopias = 0   THEN
                     tel_nrcopias = 3.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            TRANS_R_1:

            DO WHILE TRUE TRANSACTION ON ERROR UNDO TRANS_R_1, NEXT.

               FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                  crapsol.nrsolici = 48             AND
                                  crapsol.dtrefere = glb_dtmvtolt   AND
                                  crapsol.nrseqsol = 1
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   AVAILABLE crapsol   THEN
                    IF   crapsol.insitsol = 1   THEN
                         DO:
                             glb_cdcritic = 386.
                             LEAVE.
                         END.
                    ELSE
                         DO:
                             ASSIGN crapsol.insitsol = 1
                                    crapsol.nrdevias = tel_nrcopias
                                    crapsol.dsparame = "".
                             LEAVE.
                         END.
               ELSE
               IF   LOCKED crapsol   THEN
                    NEXT.

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = 48
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = 1
                      crapsol.cdempres = 11
                      crapsol.dsparame = ""
                      crapsol.insitsol = 1
                      crapsol.nrdevias = tel_nrcopias
                      crapsol.cdcooper = glb_cdcooper.
               VALIDATE crapsol.

               LEAVE.

            END.  /*  Fim da transacao  --  TRANS_R_1  */

            IF   glb_cdcritic > 0   THEN
                 NEXT.

            RUN fontes/crps091.p.
        END.
   ELSE
   IF   glb_cddopcao = "T" THEN
        DO WHILE TRUE:

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "GENERI"        AND
                               craptab.cdempres = 0               AND
                               craptab.cdacesso = "TAXASDOMES"    AND
                               craptab.tpregist = 001
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 347.
                     NEXT.
                 END.

            FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper   AND
                               crabtab.nmsistem = "CRED"         AND
                               crabtab.tptabela = "USUARI"       AND
                               crabtab.cdempres = 11             AND
                               crabtab.cdacesso = "REAJLIMITE"   AND
                               crabtab.tpregist = 1
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crabtab   THEN
                 DO:
                     glb_cdcritic = 347.
                     NEXT.
                 END.

            ASSIGN tel_flgtxmes = IF SUBSTRING(craptab.dstextab,1,1) = "T"
                                     THEN TRUE
                                     ELSE FALSE

                   tel_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,03,10))
                   tel_txufrmes = DECIMAL(SUBSTRING(craptab.dstextab,14,10))

                   tel_dtiniper = DATE(INTEGER(SUBSTR(craptab.dstextab,27,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,25,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,29,04)))

                   tel_dtfimper = DATE(INTEGER(SUBSTR(craptab.dstextab,36,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,34,02)),
                                       INTEGER(SUBSTR(craptab.dstextab,38,04)))

                   tel_dsobserv[1] = SUBSTRING(craptab.dstextab,043,40)
                   tel_dsobserv[2] = SUBSTRING(craptab.dstextab,083,40)
                   tel_dsobserv[3] = SUBSTRING(craptab.dstextab,123,40)
                   tel_dsobserv[4] = SUBSTRING(craptab.dstextab,163,40)

                   tel_txlimite    = DECIMAL(SUBSTRING(crabtab.dstextab,1,10))

                   aux_confirma    = "N".

            DISPLAY tel_flgtxmes tel_txrefmes tel_txufrmes tel_txlimite
                    tel_dtiniper tel_dtfimper tel_dsobserv
                    WITH FRAME f_taxmes.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               BELL.
               MESSAGE COLOR NORMAL
                       "Voce realmente quer utilizar, a partir de agora,".
               MESSAGE COLOR NORMAL
                       "a taxa acima para os novos contratos e liquidacoes?"
                       "(S/N):" UPDATE aux_confirma.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     LEAVE.
                 END.

            TRANS_T:

            DO WHILE TRUE TRANSACTION ON ERROR UNDO TRANS_T, NEXT.

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                  craptab.nmsistem = "CRED"        AND
                                  craptab.tptabela = "USUARI"      AND
                                  craptab.cdempres = 11            AND
                                  craptab.cdacesso = "TAXATABELA"  AND
                                  craptab.tpregist = 0
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE craptab   THEN
                    IF   LOCKED craptab   THEN
                         DO:
                             PAUSE 2 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             CREATE craptab.
                             ASSIGN craptab.nmsistem = "CRED"
                                    craptab.tptabela = "USUARI"
                                    craptab.cdempres = 11
                                    craptab.cdacesso = "TAXATABELA"
                                    craptab.tpregist = 0
                                    craptab.cdcooper = glb_cdcooper.
                             
                         END.

               craptab.dstextab = "1".
               VALIDATE craptab.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE e da transacao  */

            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

