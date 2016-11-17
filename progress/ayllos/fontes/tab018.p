/* .............................................................................

   Programa: Fontes/tab018.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    :                                    Ultima alteracao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela tab018 - TARIFA de cobranca bancoob.
   
   Alteracoes: Alterar nrdolote p/6 posicoes (Margarete/Planner).
   
               27/01/2005 - Mudado o LABEL e o HELP do campo "tel_cdagenci" de
                            "Agencia" para "PAC" (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).        
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 

               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).     
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert) 
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cdhistor AS INT                                   NO-UNDO.
DEF        VAR tel_vltarifa AS DECI                                  NO-UNDO.
DEF        VAR tel_cdcartei AS INT                                   NO-UNDO.

DEF        VAR tel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR tel_nrdolote AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


FORM SKIP(2)
     glb_cddopcao AT 29 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C,E,I)."
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_cdcartei AT 11 LABEL "Carteira" FORMAT "9"
             HELP "Entre com o codigo da carteira  1-9."
     SKIP(1)
     tel_vltarifa AT 13 LABEL "Tarifa" FORMAT "zzz,zz9.99"
             HELP "Entre com o valor da tarifa."
     SKIP(1)
     "DADOS PARA OS LANCAMENTOS"  AT 25 
     SKIP(1)
     tel_cdagenci AT 5 LABEL "PA" FORMAT "zzz9"
         HELP "Entre com o codigo do PA."
           VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                             crapage.cdagenci =tel_cdagenci)
                                             ,"962 - PA nao cadastrado.")
      
     tel_cdbccxlt AT 20 LABEL "Banco/Caixa"  FORMAT "zz9"
        HELP "Entre com o codigo do Banco/Caixa."
              VALIDATE (CAN-FIND (crapbcl WHERE crapbcl.cdbccxlt = 
                                    tel_cdbccxlt),"057 - Banco nao cadastrado.")

     tel_nrdolote AT 40 LABEL "Lote" FORMAT "zzz,zz9"
          HELP "Entre com o numero do lote para os lancamentos de C/C."
          VALIDATE (tel_nrdolote > 0, "058 - Numero do lote errado.")
     
     tel_cdhistor AT 55 LABEL "Historico" FORMAT "zzz9"
         VALIDATE (tel_cdhistor > 0 AND
                   CAN-FIND(craphis WHERE
                            craphis.cdcooper = glb_cdcooper AND
                            craphis.cdhistor = tel_cdhistor),"093 - Historico errado.")
             HELP "Entre com o historico para lancamento em conta corrente."
     SKIP(5)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab018.

glb_cddopcao = "C".
glb_cdcritic = 0.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab018 NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab018.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab018"   THEN
                 DO:
                     HIDE FRAME f_tab018.
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

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE tel_cdcartei WITH FRAME f_tab018.
                  LEAVE.
                  
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                     craptab.nmsistem = "CRED"          AND
                                     craptab.tptabela = "USUARI"        AND
                                     craptab.cdempres = 11              AND
                                     craptab.cdacesso = "TRFACBRBCB"    AND
                                     craptab.tpregist = tel_cdcartei
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
                                LEAVE.
                            END.    
                            
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN tel_cdagenci = INT(SUBSTR(craptab.dstextab,1,04))
                      tel_cdbccxlt = INT(SUBSTR(craptab.dstextab,6,03))
                      tel_nrdolote = INT(SUBSTR(craptab.dstextab,10,06))
                      tel_cdhistor = INT(SUBSTR(craptab.dstextab,17,04)) /*Kbase*/
                      tel_vltarifa = DECI(SUBSTR(craptab.dstextab,21,9)).

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_vltarifa tel_cdagenci tel_cdbccxlt 
                         tel_nrdolote tel_cdhistor
                         WITH FRAME f_tab018

                         EDITING:

                            READKEY.
                            IF   FRAME-FIELD = "tel_vltarifa"  THEN
                                 IF   LASTKEY =  KEYCODE(".")   THEN
                                      APPLY 44.
                                 ELSE
                                      APPLY LASTKEY.
                            ELSE
                                 APPLY LASTKEY.

                         END.  /*  Fim do EDITING  */

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               craptab.dstextab = STRING(tel_cdagenci,"9999") + " " +                      
                                  STRING(tel_cdbccxlt,"999") + " " + 
                                  STRING(tel_nrdolote,"999999") + " " + 
                                  STRING(tel_cdhistor,"9999") + " " +
                                  STRING(tel_vltarifa,"999999.99").

            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_tab018 NO-PAUSE.

        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            DO WHILE TRUE:
            
               UPDATE tel_cdcartei WITH FRAME f_tab018.
               LEAVE.
            END.
               
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TRFACBRBCB"   AND
                               craptab.tpregist = tel_cdcartei
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT.
                 END.

            ASSIGN tel_cdagenci = INT(SUBSTR(craptab.dstextab,1,04))
                   tel_cdbccxlt = INT(SUBSTR(craptab.dstextab,6,03))
                   tel_nrdolote = INT(SUBSTR(craptab.dstextab,10,06))
                   tel_cdhistor = INT(SUBSTR(craptab.dstextab,17,04))
                   tel_vltarifa = DECI(SUBSTR(craptab.dstextab,21,9)).

            DISPLAY tel_cdagenci tel_cdbccxlt tel_nrdolote 
                    tel_vltarifa tel_cdhistor   WITH FRAME f_tab018.
        END.
   ELSE     
   IF   glb_cddopcao = "I" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE tel_cdcartei WITH FRAME f_tab018.
                  LEAVE.
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.
   
               IF CAN-FIND(craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                         craptab.nmsistem = "CRED"         AND
                                         craptab.tptabela = "USUARI"       AND
                                         craptab.cdempres = 11             AND
                                         craptab.cdacesso = "TRFACBRBCB"   AND
                                         craptab.tpregist = tel_cdcartei)  THEN

                   DO:
                       glb_cdcritic = 56.
                       NEXT.
                   END.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_vltarifa  
                         tel_cdagenci tel_cdbccxlt tel_nrdolote tel_cdhistor
                         WITH FRAME f_tab018

                         EDITING:

                            READKEY.
                            IF   FRAME-FIELD = "tel_vltarifa"  THEN
                                 IF   LASTKEY =  KEYCODE(".")   THEN
                                      APPLY 44.
                                 ELSE
                                      APPLY LASTKEY.
                            ELSE
                                 APPLY LASTKEY.

                         END.  /*  Fim do EDITING  */

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               CREATE craptab.

               ASSIGN craptab.nmsistem = "CRED"
                      craptab.tptabela = "USUARI"
                      craptab.cdempres = 11
                      craptab.cdacesso = "TRFACBRBCB"
                      craptab.tpregist = tel_cdcartei
                      craptab.cdcooper = glb_cdcooper
                      
                      craptab.dstextab = STRING(tel_cdagenci,"9999") + " " +  
                                         STRING(tel_cdbccxlt,"999") + " " + 
                                         STRING(tel_nrdolote,"999999") + " " + 
                                         STRING(tel_cdhistor,"9999") + " " +
                                         STRING(tel_vltarifa,"999999.99").

               RELEASE craptab.

               CLEAR FRAME f_tab018 NO-PAUSE.
           END.
        END.
     ELSE
     IF   glb_cddopcao = "E" THEN
          DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE tel_cdcartei WITH FRAME f_tab018.
                  LEAVE.
               END.
                
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.
   
               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "USUARI"       AND
                                     craptab.cdempres = 11             AND
                                     craptab.cdacesso = "TRFACBRBCB"   AND
                                     craptab.tpregist = tel_cdcartei
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
                                NEXT.
                            END.    
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN tel_cdagenci = INT(SUBSTR(craptab.dstextab,1,04))
                      tel_cdbccxlt = INT(SUBSTR(craptab.dstextab,6,03))
                      tel_nrdolote = INT(SUBSTR(craptab.dstextab,10,06))
                      tel_cdhistor = INT(SUBSTR(craptab.dstextab,17,04))
                      tel_vltarifa = DECI(SUBSTR(craptab.dstextab,21,9)).

               DISPLAY tel_cdagenci tel_cdbccxlt tel_nrdolote 
                    tel_vltarifa tel_cdhistor   WITH FRAME f_tab018.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

                    glb_cdcritic = 0.

               DELETE craptab.

            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_tab018 NO-PAUSE.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

