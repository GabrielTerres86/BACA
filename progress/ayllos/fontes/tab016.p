/* .............................................................................

   Programa: Fontes/tab016.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/96                         Ultima alteracao: 07/12/2016
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela tab016 - Parametros para emissao da Proposta de
                                       Emprestimos.
   Alteracao : 19/03/2004 - Incluido tempo minimo filiacao(Mirtes)

               05/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               19/06/2009 - Incluir campos Operacoes de credito ativas
                            e Operacoes de credito liquidadas(Gabriel).
               
               17/07/2009 - Incluido os campos Operacoes de credito ativas e
                            Operacoes de credito liquidadas para pessoa 
                            Juridica (Elton).
                            
               17/02/2010 - Incluindo log na inclusao exclusao e alteracao.
                            (GATI - Daniel)
                            
               17/09/2010 - Incluir campo Utilizaçao Interveniente (Gabriel).             
               
               25/07/2012 - Correções no LOG da tela (Lucas).
               
               06/05/2013 - Adicionado parametro de Qtd de impressoes 
                            de NP (Lucas).
                            
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               27/12/2013 - Ajuste para poder salvar qtd notas promissorias
                            com "0". (Jorge)
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
               
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin). 
               
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................ */

{ includes/var_online.i }

DEF        VAR tel_cdagenci AS INTE FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR                               NO-UNDO.
DEF        VAR tel_qtcapemp AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_vltotemp AS DECI FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_vlemprst AS DECI FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_qtopeati AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_qtopeliq AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_qtopatpj AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_qtoplipj AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_flginter AS LOGI FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_diasmini AS INTE                               NO-UNDO.
DEF        VAR tel_inqrdimp AS INTE FORMAT "zz9"                  NO-UNDO.
/* Variaveis para gravacao do log dealteracao */                  
DEF        VAR log_qtcapemp AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR log_vltotemp AS DECI FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR log_vlemprst AS DECI FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR log_qtopeati AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR log_qtopeliq AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR log_qtopatpj AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR log_qtoplipj AS INTE FORMAT "z9"                   NO-UNDO.
DEF        VAR log_flginter AS LOGI FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_diasmini AS INTE                               NO-UNDO.
DEF        VAR log_inqrdimp AS INTE                               NO-UNDO.
                                                                  
DEF        VAR aux_cddopcao AS CHAR                               NO-UNDO.
DEF        VAR aux_confirma AS CHAR FORMAT "!"                    NO-UNDO.
DEF        VAR aux_contador AS INTE                               NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


DEF BUFFER crabtab FOR craptab.

FORM SKIP(1)
     glb_cddopcao AT 05 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Informe a opcao desejada (A,C,E,I)."
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_cdagenci AT 23 LABEL "PA" AUTO-RETURN FORMAT "zz9"
                  HELP "Informe o numero do PA. ou zero para GENERICA."
     
     tel_dsagenci AT 35 NO-LABEL FORMAT "x(30)"
     
     SKIP(1)
     "_______________ Parametros para Impressao da Proposta ___________________"
     AT 3 
     SKIP
     tel_qtcapemp AT 14 LABEL "Qtd. de vezes o capital" FORMAT "z9"
             HELP "Informe a quantidade de vezes o capital a ser emprestado."
     
     tel_vltotemp AT 16 LABEL "Valor total da divida"   FORMAT "zzz,zzz,zz9.99"
             HELP "Informe o valor total da divida emprestada."
     
     tel_vlemprst AT 21 LABEL "Valor emprestado" FORMAT "zzz,zzz,zz9.99"
             HELP "Informe o valor do emprestimo."
     
     tel_qtopeati AT 05 LABEL "Operacoes de credito ativas - PF" 
         HELP "Informe a quantidade de operacoes de credito ativas - Fisica."
             
     tel_qtopeliq AT 03 LABEL "Operac. de credito liquidadas - PF" 
         HELP "Informe a quantidade de operac. de credito liquidadas - Fisica."
    
     tel_qtopatpj AT 05 LABEL "Operacoes de credito ativas - PJ" 
         HELP "Informe quantidade de operacoes de credito ativas - Juridica."

     tel_qtoplipj AT 03 LABEL "Operac. de credito liquidadas - PJ" 
         HELP "Informe quantidade de operac. de credito liquidadas - Juridica."
     
     tel_flginter AT 15 LABEL "Inclusão Interveniente"
         HELP "Informe se deseja incluir/atualizar o(s) Interveniente(s)."   

     tel_inqrdimp AT 17 LABEL "Qtd. impressao de NP"
         HELP "Qtd de impressoes de NP a serem impressas na proposta."   
     SKIP
     "_________________________________________________________________________"
     AT 3
     SKIP
     tel_diasmini AT 13 LABEL "Tempo minimo de filiacao" FORMAT "zz9"
                        HELP "Entre com nro dias minimo de filiacao"
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab016.


glb_cddopcao = "C".

VIEW FRAME f_moldura.
PAUSE(0).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR NO-WAIT.

DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab016 NO-PAUSE.
               DISPLAY tel_dsagenci WITH FRAME f_tab016.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao tel_cdagenci WITH FRAME f_tab016.

      IF   tel_cdagenci > 0   THEN
           DO:              
               FIND crapage WHERE  crapage.cdcooper = glb_cdcooper  AND
                                   crapage.cdagenci = tel_cdagenci  
                                   NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapage   THEN
                    DO:
                        ASSIGN glb_cdcritic = 15
                               tel_dsagenci = "".
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                        NEXT.
                    END.
               ELSE
                    tel_dsagenci = "- " + crapage.nmresage.
           END.
      ELSE
           tel_dsagenci = "- GENERICA".

      DISPLAY tel_dsagenci WITH FRAME f_tab016.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "tab016"   THEN
                 DO:
                     HIDE FRAME f_tab016.
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

   IF   glb_cddopcao = "A"   THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:
                   
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                     craptab.nmsistem = "CRED"          AND
                                     craptab.tptabela = "USUARI"        AND
                                     craptab.cdempres = 11              AND
                                     craptab.cdacesso = "PROPOSTEPR"    AND
                                     craptab.tpregist = tel_cdagenci
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
                    DO:
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                        NEXT.
                    END.

               /* Busca registro de Qtd de impressoes de NP */
               DO aux_contador = 1 TO 10:

                  FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper    AND
                                     crabtab.nmsistem = "CRED"          AND
                                     crabtab.tptabela = "USUARI"        AND
                                     crabtab.cdempres = 11              AND
                                     crabtab.cdacesso = "PROPOSTANP"    AND
                                     crabtab.tpregist = 0
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
                    DO:
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                        NEXT.
                    END.

               ASSIGN tel_vltotemp = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                      log_vltotemp = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                      tel_vlemprst = DECIMAL(SUBSTRING(craptab.dstextab,17,15))
                      log_vlemprst = DECIMAL(SUBSTRING(craptab.dstextab,17,15))
                      tel_qtcapemp = INTEGER(SUBSTRING(craptab.dstextab,33,02))
                      log_qtcapemp = INTEGER(SUBSTRING(craptab.dstextab,33,02))
                      tel_diasmini = INTEGER(SUBSTRING(craptab.dstextab,36,03))
                      log_diasmini = INTEGER(SUBSTRING(craptab.dstextab,36,03))
                      tel_qtopeati = INTEGER(SUBSTRING(craptab.dstextab,40,03))
                      log_qtopeati = INTEGER(SUBSTRING(craptab.dstextab,40,03))
                      tel_qtopeliq = INTEGER(SUBSTRING(craptab.dstextab,44,03))
                      log_qtopeliq = INTEGER(SUBSTRING(craptab.dstextab,44,03))
                      tel_qtopatpj = INTEGER(SUBSTRING(craptab.dstextab,48,03))
                      log_qtopatpj = INTEGER(SUBSTRING(craptab.dstextab,48,03))
                      tel_qtoplipj = INTEGER(SUBSTRING(craptab.dstextab,52,03))
                      log_qtoplipj = INTEGER(SUBSTRING(craptab.dstextab,52,03))
                      tel_flginter = LOGICAL(SUBSTRING(craptab.dstextab,56,03))
                      log_flginter = LOGICAL(SUBSTRING(craptab.dstextab,56,03))
                      tel_inqrdimp = INTEGER(crabtab.dstextab)
                      log_inqrdimp = INTEGER(crabtab.dstextab).
                      
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  DISPLAY tel_inqrdimp
                          WITH FRAME f_tab016.

                  UPDATE tel_qtcapemp 
                         tel_vltotemp
                         tel_vlemprst
                         tel_qtopeati
                         tel_qtopeliq
                         tel_qtopatpj    
                         tel_qtoplipj
                         tel_flginter
                         tel_inqrdimp WHEN (glb_cddepart = 20   OR   /* TI */      
                                            glb_cddepart = 14 ) AND /* PRODUTOS */
                                            tel_cdagenci = 0
                         tel_diasmini
                         WITH FRAME f_tab016.

                /* -----------------------------------------------------------------------
                   A validação foi elaborada de tal forma onde todos os contratos com um
                   número de promissorias acima da quantidade de prestações gerem crítica.
                   O manejamentos de tais situações deverão ser verificados juntamente com
                   outras equipes.
                    
                   Exemplo: 1 prestação de empréstimo e 2 promissórias. 
                   ----------------------------------------------------------------------- */

                  IF  tel_inqrdimp MOD 2 > 0 THEN
                      DO:
                           IF  tel_inqrdimp <> 1  THEN
                           DO:
                               MESSAGE "Qtd. impressao de NP invalida.".
                               NEXT.
                           END.
                      END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               craptab.dstextab = STRING(tel_vltotemp,"999999999999.99") + " " +
                                  STRING(tel_vlemprst,"999999999999.99") + " " +
                                  STRING(tel_qtcapemp,"99")  + " " + 
                                  STRING(tel_diasmini,"999") + " " +
                                  STRING(tel_qtopeati,"999") + " " + 
                                  STRING(tel_qtopeliq,"999") + " " +
                                  STRING(tel_qtopatpj,"999") + " " + 
                                  STRING(tel_qtoplipj,"999") + " " +
                                  STRING(tel_flginter,"yes/no").

               crabtab.dstextab = STRING(tel_inqrdimp).

            END. /* Fim da transacao */

            RELEASE craptab.
            RELEASE crabtab.

            CLEAR FRAME f_tab016 NO-PAUSE.

            /* Verificacao de campos alterados */
            IF   tel_qtcapemp <> log_qtcapemp   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Quantidade de vezes o capital " + 
                          " do PA " + STRING(tel_cdagenci) + " de "         +
                          TRIM(STRING(log_qtcapemp)) + " para  "  +
                          TRIM(STRING(tel_qtcapemp))              + 
                          ">>/log/tab016.log").
                 END. 

            IF   tel_vltotemp <> log_vltotemp   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Valor total da divida do PA "   +
                          STRING(tel_cdagenci) + " de R$ "                  +
                          TRIM(STRING(log_vltotemp,"zzz,zzz,zz9.99"))       + 
                          " para R$ "                                       +
                          TRIM(STRING(tel_vltotemp,"zzz,zzz,zz9.99"))       + 
                          " >> log/tab016.log").
                 END.

            IF   tel_vlemprst <> log_vlemprst   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Valor emprestado do PA "       +
                          STRING(tel_cdagenci) + " de R$ "                  +
                          TRIM(STRING(log_vlemprst,"zzz,zzz,zz9.99"))       + 
                          " para R$ "                                       +
                          TRIM(STRING(tel_vlemprst,"zzz,zzz,zz9.99"))       + 
                          " >> log/tab016.log").
                 END.

            IF   tel_qtopeati <> log_qtopeati   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Qtde. de operacoes de credito " +
                          "ativas - PF do PA " + STRING(tel_cdagenci)       + 
                          " de " + TRIM(STRING(log_qtopeati)) + " para "    +
                          TRIM(STRING(tel_qtopeati))                        + 
                          " >> log/tab016.log").
                 END.

            IF   tel_qtopeliq <> log_qtopeliq   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Qtde. de operacoes de credito " +
                          "liquidadas - PF do PA " + STRING(tel_cdagenci)   + 
                          " de " + TRIM(STRING(log_qtopeliq)) + " para "    +
                          TRIM(STRING(tel_qtopeliq))                        + 
                          " >> log/tab016.log").
                 END.

            IF   tel_qtopatpj <> log_qtopatpj   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Qtde. de operacoes de credito " +
                          "ativas - PJ do PA " + STRING(tel_cdagenci)       + 
                          " de " + TRIM(STRING(log_qtopatpj)) + " para "    +
                          TRIM(STRING(tel_qtopatpj))                        + 
                          " >> log/tab016.log").
                 END.

            IF   tel_qtoplipj <> log_qtoplipj   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + glb_cdoperad                        +
                          " alterou o campo Qtde. de operacoes de credito " +
                          "liquidadas - PJ do PA " + STRING(tel_cdagenci)  +
                          " de " + TRIM(STRING(log_qtoplipj)) + " para "    +
                          TRIM(STRING(tel_qtoplipj))                        + 
                          " >> log/tab016.log").
                 END.

            IF   tel_flginter <> log_flginter THEN
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")   + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"           +
                          "Operador " + glb_cdoperad                          +
                          " alterou o campo Inclusão Interveniente"           +
                          " do PA " + STRING(tel_cdagenci)                   +
                          " de " + TRIM(STRING(log_flginter,"Sim/Não"))       + 
                          " para "    +  TRIM(STRING(tel_flginter,"Sim/Não")) + 
                          " >> log/tab016.log").
                 END.

            IF   tel_diasmini <> log_diasmini   THEN 
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                          "Operador " + glb_cdoperad +
                          " alterou o campo Tempo minimo de filiacao do PA " +
                          STRING(tel_cdagenci) + " de " +
                          TRIM(STRING(log_diasmini)) + " para " +
                          TRIM(STRING(tel_diasmini)) + 
                          " >> log/tab016.log").
                 END.

            IF   tel_inqrdimp <> log_inqrdimp THEN
                 DO:
                     UNIX SILENT 
                          VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")   + 
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"           +
                          "Operador " + glb_cdoperad                          +
                          " alterou o campo Qt. Impressao NP "                +
                          " do PA "  + STRING(tel_cdagenci)                   +
                          " de " +   STRING(log_inqrdimp)                     + 
                          " para " + STRING(tel_inqrdimp)                     + 
                          " >> log/tab016.log").
                 END.

            ASSIGN tel_cdagenci = 0
                   tel_vltotemp = 0
                   tel_vlemprst = 0
                   tel_qtcapemp = 0
                   tel_diasmini = 0
                   tel_qtopeati = 0
                   tel_qtopeliq = 0
                   tel_qtopatpj = 0
                   tel_qtoplipj = 0
                   tel_inqrdimp = 0
                   tel_flginter = NO.

        END. /* IF   glb_cddopcao = "A" */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "PROPOSTEPR" AND
                               craptab.tpregist = tel_cdagenci NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                     NEXT.
                 END.

            /* Busca registro de Qtd de impressoes de NP */
            FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper AND
                               crabtab.nmsistem = "CRED"       AND
                               crabtab.tptabela = "USUARI"     AND
                               crabtab.cdempres = 11           AND
                               crabtab.cdacesso = "PROPOSTANP" AND
                               crabtab.tpregist = 0
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crabtab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                     NEXT.
                 END.

            ASSIGN tel_vltotemp = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                   tel_vlemprst = DECIMAL(SUBSTRING(craptab.dstextab,17,15))
                   tel_qtcapemp = INTEGER(SUBSTRING(craptab.dstextab,33,02))
                   tel_diasmini = INTEGER(SUBSTRING(craptab.dstextab,36,03))
                   tel_qtopeati = INTEGER(SUBSTRING(craptab.dstextab,40,03))
                   tel_qtopeliq = INTEGER(SUBSTRING(craptab.dstextab,44,03))
                   tel_qtopatpj = INTEGER(SUBSTRING(craptab.dstextab,48,03))
                   tel_qtoplipj = INTEGER(SUBSTRING(craptab.dstextab,52,03))
                   tel_flginter = LOGICAL(SUBSTRING(craptab.dstextab,56,03))
                   tel_inqrdimp = INTEGER(crabtab.dstextab).
 
            DISPLAY tel_vltotemp                                      
                    tel_vlemprst
                    tel_qtcapemp
                    tel_diasmini
                    tel_qtopeati 
                    tel_qtopeliq 
                    tel_qtopatpj 
                    tel_qtoplipj
                    tel_flginter
                    tel_inqrdimp
                    WITH FRAME f_tab016.

        END. /* IF   glb_cddopcao = "C" */
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "USUARI"       AND
                                     craptab.cdempres = 11             AND
                                     craptab.cdacesso = "PROPOSTEPR"   AND
                                     craptab.tpregist = tel_cdagenci
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
                    DO:
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                        NEXT.
                    END.
               
               /* Busca registro de Qtd de impressoes de NP */
               FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper AND
                                  crabtab.nmsistem = "CRED"       AND
                                  crabtab.tptabela = "USUARI"     AND
                                  crabtab.cdempres = 11           AND
                                  crabtab.cdacesso = "PROPOSTANP" AND
                                  crabtab.tpregist = 0
                                  NO-LOCK NO-ERROR.
               
               IF   NOT AVAILABLE crabtab   THEN
                    DO:
                        glb_cdcritic = 55.
                        NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                        NEXT.
                    END.
               
               ASSIGN tel_vltotemp = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                      tel_vlemprst = DECIMAL(SUBSTRING(craptab.dstextab,17,15))
                      tel_qtcapemp = INTEGER(SUBSTRING(craptab.dstextab,33,02))
                      tel_diasmini = INTEGER(SUBSTRING(craptab.dstextab,36,03))
                      tel_qtopeati = INTEGER(SUBSTRING(craptab.dstextab,40,03))
                      tel_qtopeliq = INTEGER(SUBSTRING(craptab.dstextab,44,03))
                      tel_qtopatpj = INTEGER(SUBSTRING(craptab.dstextab,48,03))
                      tel_qtoplipj = INTEGER(SUBSTRING(craptab.dstextab,52,03))
                      tel_flginter = LOGICAL(SUBSTRING(craptab.dstextab,56,03))
                      tel_inqrdimp = INTEGER(crabtab.dstextab).
              
               DISPLAY tel_qtcapemp 
                       tel_vltotemp
                       tel_vlemprst
                       tel_diasmini
                       tel_qtopeati
                       tel_qtopeliq
                       tel_qtopatpj
                       tel_qtoplipj
                       tel_flginter
                       tel_inqrdimp
                       WITH FRAME f_tab016.

               /* Confirmaçao dos dados */
               RUN fontes/confirma.p (INPUT "",
                                      OUTPUT aux_confirma).
                                      
               
               IF   aux_confirma <> "S" THEN
                    NEXT.
                           
               DELETE craptab.
               CLEAR FRAME f_tab016 NO-PAUSE.
                        
               UNIX SILENT VALUE("echo " + 
                                 STRING(glb_dtmvtolt,"99/99/9999") + 
                                 " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                                 "Operador " + glb_cdoperad +
                                 " excluiu o cadastro dos Parametros para " +
                                 "emissao da Proposta de Emprestimos do " +
                                 "PA " + STRING(tel_cdagenci) +
                                 " >> log/tab016.log").

               ASSIGN tel_cdagenci = 0
                      tel_vltotemp = 0
                      tel_vlemprst = 0
                      tel_qtcapemp = 0
                      tel_diasmini = 0
                      tel_qtopeati = 0
                      tel_qtopeliq = 0
                      tel_qtopatpj = 0   
                      tel_qtoplipj = 0
                      tel_inqrdimp = 0
                      tel_flginter = NO.
         
            END. /* Fim da transacao */
             
        END. /* IF   glb_cddopcao = "E" */
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   CAN-FIND(craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                       craptab.nmsistem = "CRED"          AND
                                       craptab.tptabela = "USUARI"        AND
                                       craptab.cdempres = 11              AND
                                       craptab.cdacesso = "PROPOSTEPR"    AND
                                       craptab.tpregist = tel_cdagenci)   THEN
                DO:
                    glb_cdcritic = 56.
                    NEXT-PROMPT tel_cdagenci WITH FRAME f_tab016.
                    LEAVE.
                END.
           
           ASSIGN  tel_vltotemp = 0
                   tel_vlemprst = 0
                   tel_qtcapemp = 0
                   tel_diasmini = 0
                   tel_qtopeati = 0
                   tel_qtopeliq = 0
                   tel_qtopatpj = 0
                   tel_qtoplipj = 0
                   tel_flginter = NO.
                               
           UPDATE  tel_qtcapemp 
                   tel_vltotemp
                   tel_vlemprst
                   tel_qtopeati
                   tel_qtopeliq
                   tel_qtopatpj
                   tel_qtoplipj
                   tel_flginter
                   tel_diasmini
                   WITH FRAME f_tab016.
                    
           DO TRANSACTION ON ERROR UNDO, RETURN:

              CREATE craptab.

              ASSIGN craptab.nmsistem = "CRED"
                     craptab.tptabela = "USUARI"
                     craptab.cdempres = 11
                     craptab.cdacesso = "PROPOSTEPR"
                     craptab.tpregist = tel_cdagenci
                     craptab.dstextab = STRING(tel_vltotemp,"999999999999.99")
                                        + " " +
                                        STRING(tel_vlemprst,"999999999999.99")
                                        + " " +
                                        STRING(tel_qtcapemp,"99") 
                                        + " " +
                                        STRING(tel_diasmini,"999")
                                        + " " +
                                        STRING(tel_qtopeati,"999")
                                        + " " +
                                        STRING(tel_qtopeliq,"999")
                                        + " " +
                                        STRING(tel_qtopatpj,"999")
                                        + " " +
                                        STRING(tel_qtoplipj,"999")  
                                        + " " + 
                                        STRING(tel_flginter,"yes/no")
                                        
                     craptab.cdcooper = glb_cdcooper.
              VALIDATE craptab.       
              UNIX SILENT 
                   VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                   " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                   "Operador " + glb_cdoperad +
                   " incluiu o cadastro dos Parametros para emissao da " +
                   "Proposta de Emprestimos do PA " + STRING(tel_cdagenci) +
                   " >> log/tab016.log").

              ASSIGN tel_cdagenci = 0
                     tel_vltotemp = 0
                     tel_vlemprst = 0
                     tel_qtcapemp = 0
                     tel_diasmini = 0
                     tel_qtopeati = 0
                     tel_qtopeliq = 0
                     tel_qtopatpj = 0                  
                     tel_qtoplipj = 0
                     tel_flginter = NO.

           END.  /*  Fim da TRANSACAO  */
           
           CLEAR FRAME f_tab016.
            
           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  (IF   glb_cddopcao = "I") */

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */


