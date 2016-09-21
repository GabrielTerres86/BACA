/* .............................................................................

   Programa: Fontes/tab087.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Novembro/2010                       Ultima alteracao: 19/09/2014
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : TAB087 - Execucao da Compensacao ABBC
   
   Alteracao : 01/03/2011 - Incluir os operadores Viacredi - Marilu/Edesio/Jones/
                            Alexandre - para possibilitar alteracao na tela (Ze).
                          
               03/03/2011 - Incluir campos novos (Gabriel) .
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              
                            
               10/01/2014 - Alterada critica "015 - Agencia nao cadastrada"
                            para "962 - PA nao cadastrado". (Reinert)
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                        
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR tel_nmrespac AS CHAR   FORMAT "x(30)"                 NO-UNDO.
DEF        VAR tel_insitage AS CHAR   FORMAT "x(15)"                 NO-UNDO.
DEF        VAR tel_lgcmpimg AS LOG    FORMAT "SIM/NAO"               NO-UNDO.
DEF        VAR tel_dsdirmic AS CHAR   FORMAT "x(38)"                 NO-UNDO.
DEF        VAR tel_prevlote AS LOGI   FORMAT "SIM/NAO"               NO-UNDO.
DEF        VAR tel_microcus AS CHAR   FORMAT "x(38)"                 NO-UNDO.

DEF        VAR aux_lgcmpimg AS LOG FORMAT "SIM/NAO"                  NO-UNDO.
DEF        VAR aux_dsdirmic AS CHAR                                  NO-UNDO.
DEF        VAR aux_prevlote AS LOGI                                  NO-UNDO.
DEF        VAR aux_microcus AS CHAR                                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM WITH ROW 4 COLUMN 1 OVERLAY TITLE glb_tldatela SIZE 80 BY 18 
     FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 10 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                           HELP "Entre com a opcao desejada (A,C)."
                           VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP
     tel_cdagenci AT 36 LABEL "PA"
         HELP "Informe o numero do PA ou <F7> para Zoom de PAs"
         VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper
                                     AND crapage.cdagenci = INPUT tel_cdagenci),
                                     "962 - PA nao cadastrado.")
     SKIP(1)
     tel_nmrespac AT 25 LABEL "Nome Resumido"
     SKIP(1)
     tel_insitage AT 24 LABEL "Situacao do PA"
     SKIP(1)
     tel_lgcmpimg AT 14 LABEL "Executa Compe por Imagem"
         HELP "Informe se o PA executará Compensacao por Imagem"
     SKIP(1)
     "Previa por Lote na Custodia/Desconto:" AT 02 
     tel_prevlote AT 40 NO-LABEL       
        HELP "Informe (S)im ou (N)ao para previa por Lote."
     SKIP(1)
     "Micro Digit. para Caixa On-line:"      AT 07  
     tel_dsdirmic AT 40 NO-LABEL 
        HELP "Informe caminho do micro que recebera os arquivos de truncagem"
     SKIP(1)
     "Micro Digit. para Custodia/Desconto:"  AT 03
     tel_microcus AT 40 NO-LABEL 
        HELP "Informe o micro para Custodia/Desconto."

     WITH WIDTH 78 CENTERED ROW 5 OVERLAY NO-BOX SIDE-LABELS FRAME f_tab087.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_cdprogra = "tab087".

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   glb_cdcritic <> 0  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab087.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "tab087"   THEN
                 DO:
                     HIDE FRAME f_tab087.
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

    UPDATE tel_cdagenci WITH FRAME f_tab087
        
        EDITING:
            READKEY.
            IF   LASTKEY = KEYCODE("F7") THEN
                 DO:
                    IF   FRAME-FIELD = "tel_cdagenci" THEN
                         DO:

                            RUN fontes/zoom_pac.p(OUTPUT tel_cdagenci).
                            DISPLAY tel_cdagenci WITH FRAME f_tab087.

                         END.
                 END.
            ELSE
                 APPLY LASTKEY.
        END. /*** Fim EDITING ***/

   FIND FIRST crapage WHERE crapage.cdcooper = glb_cdcooper AND
                            crapage.cdagenci = tel_cdagenci
                            NO-LOCK NO-ERROR.

   ASSIGN tel_nmrespac = crapage.nmresage
          tel_insitage = IF   crapage.insitage = 0  THEN
                              "0 - EM OBRAS"
                         ELSE
                         IF   crapage.insitage = 1  THEN
                              "1 - ATIVO"
                         ELSE
                              "2 - INATIVO".

   /* VERIFICA SE EXECUTA TRUNCAGEM */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "EXETRUNCAGEM" AND
                      craptab.tpregist = tel_cdagenci   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        ASSIGN tel_lgcmpimg = NO
               aux_lgcmpimg = NO.
   ELSE
        ASSIGN tel_lgcmpimg = IF craptab.dstextab = "SIM" THEN YES ELSE NO
               aux_lgcmpimg = tel_lgcmpimg.
   /* FIM - VERIFICA SE EXECUTA TRUNCAGEM */

   /* VERIFICA PASTA PARA GRAVAR ARQUIVOS DE TRUNCAGEM */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "GENERI"     AND
                      craptab.cdempres = 0            AND
                      craptab.cdacesso = "MICROTRUNC" AND
                      craptab.tpregist = tel_cdagenci   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        ASSIGN tel_dsdirmic = ""
               aux_dsdirmic = "".
   ELSE
        ASSIGN tel_dsdirmic = craptab.dstextab
               aux_dsdirmic = tel_dsdirmic.

   /* FIM - VERIFICA PASTA PARA GRAVAR ARQUIVOS DE TRUNCAGEM */

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 0               AND
                      craptab.cdacesso = "MICROCUSTOD"   AND
                      craptab.tpregist = tel_cdagenci    NO-LOCK NO-ERROR.

   IF   AVAIL craptab   THEN
        ASSIGN tel_prevlote = (SUBSTR(craptab.dstextab,1,1) = "1")
               tel_microcus = SUBSTR(craptab.dstextab,3).             
   ELSE
        ASSIGN tel_prevlote = ?
               tel_microcus = "".

   /* Guardar valores */
   ASSIGN aux_prevlote = tel_prevlote
          aux_microcus = tel_microcus.

   DISPLAY tel_lgcmpimg tel_nmrespac 
           tel_insitage tel_dsdirmic 
           tel_prevlote tel_microcus WITH FRAME f_tab087.

   IF   glb_cddopcao = "A" THEN
        DO:
            IF   glb_dsdepart <> "TI"                   AND
                 glb_dsdepart <> "SUPORTE"              AND
                 glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
                 glb_dsdepart <> "COORD.PRODUTOS"       AND
                 glb_dsdepart <> "COMPE"                THEN
                 DO:
                     IF   glb_cdcooper = 1       AND
                         (glb_cdoperad = "478"   OR
                          glb_cdoperad = "372"   OR
                          glb_cdoperad = "357"   OR
                          glb_cdoperad = "130")  THEN
                          .
                     ELSE
                          DO:
                              glb_cdcritic = 36.
                              NEXT.
                          END.    
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               UPDATE tel_lgcmpimg 
                      tel_prevlote     
                      tel_dsdirmic
                      tel_microcus WITH FRAME f_tab087.
                              
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               /* Se nao modificou nada ... NEXT */
               IF   NOT (tel_lgcmpimg <> aux_lgcmpimg   OR 
                         tel_prevlote <> aux_prevlote   OR
                         tel_dsdirmic <> aux_dsdirmic   OR
                         tel_microcus <> aux_microcus)   THEN
                    NEXT.

               RUN fontes/confirma.p (INPUT "",
                                     OUTPUT aux_confirma).

               IF   aux_confirma <> "S"   THEN
                    NEXT.

               /* Atualizando EXETRUNCAGEM */
               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "GENERI"       AND
                                     craptab.cdempres = 0              AND
                                     craptab.cdacesso = "EXETRUNCAGEM" AND
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
                            DO:
                                CREATE craptab.
                                ASSIGN craptab.cdcooper = glb_cdcooper
                                       craptab.nmsistem = "CRED"
                                       craptab.tptabela = "GENERI"
                                       craptab.cdempres = 0
                                       craptab.cdacesso = 
                                               "EXETRUNCAGEM"
                                       craptab.tpregist = tel_cdagenci
                                       craptab.dstextab = "NAO".
                                VALIDATE craptab.
                            END.
                  
                  glb_cdcritic = 0.
                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               IF   tel_lgcmpimg THEN
                    ASSIGN craptab.dstextab = "SIM".
               ELSE
                    ASSIGN craptab.dstextab = "NAO".

               /* Atualizando MICROTRUNC */
               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "GENERI"     AND
                                     craptab.cdempres = 0            AND
                                     craptab.cdacesso = "MICROTRUNC" AND
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
                            DO:
                                CREATE craptab.
                                ASSIGN craptab.cdcooper = glb_cdcooper
                                       craptab.nmsistem = "CRED"
                                       craptab.tptabela = "GENERI"
                                       craptab.cdempres = 0
                                       craptab.cdacesso = "MICROTRUNC"
                                       craptab.tpregist = tel_cdagenci
                                       craptab.dstextab = tel_dsdirmic.
                                VALIDATE craptab.
                            END.
                  
                  glb_cdcritic = 0.
                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN craptab.dstextab = tel_dsdirmic.

               /* Atualizando a MICROCUSTOD */
               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "GENERI"       AND
                                     craptab.cdempres = 0              AND
                                     craptab.cdacesso = "MICROCUSTOD"  AND
                                     craptab.tpregist = tel_cdagenci
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAIL craptab   THEN
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
                            DO:
                                CREATE craptab.
                                ASSIGN craptab.cdcooper = glb_cdcooper
                                       craptab.nmsistem = "CRED"
                                       craptab.tptabela = "GENERI"
                                       craptab.cdempres = 0
                                       craptab.cdacesso = "MICROCUSTOD"
                                       craptab.tpregist = tel_cdagenci.
                                VALIDATE craptab.
                            END.

                  glb_cdcritic = 0.
                  LEAVE.

               END. /* Fim Lock craptab */

               IF   glb_cdcritic <> 0   THEN
                    NEXT.
                    
               ASSIGN craptab.dstextab = ""
                      SUBSTR(craptab.dstextab,1,1) = IF   tel_prevlote   THEN
                                                          "1"
                                                     ELSE
                                                          "0"                       
                      SUBSTR(craptab.dstextab,3)   = tel_microcus. 

            END. /* Fim da transacao */
                                                         
            RELEASE craptab.

            CLEAR FRAME f_tab087 NO-PAUSE.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

