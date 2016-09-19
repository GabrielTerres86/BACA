/* .............................................................................

   Programa: Fontes/tab031.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2004                         Ultima alteracao: 22/04/2008 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tab031 -  Tabela de valor maximo para poupanca programada.
               
   Alteracao : 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               22/04/2008 - Incluidos campos Prazo minimo e Prazo maximo
                            (Gabriel).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vllimepr AS DECIMAL                               NO-UNDO.
DEF        VAR tel_vllimctr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vlmaxppr AS DECIMAL FORMAT "zzz,zz9.99"           NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_pzmaxpro AS INT FORMAT "Z99"                      NO-UNDO.
DEF        VAR aux_pzminpro AS INT FORMAT "Z99"                      NO-UNDO.

FORM SKIP(2)
     glb_cddopcao AT 35 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(3)
     aux_vlmaxppr AT 16 LABEL "Valor maximo para Poupanca Programada" 
         HELP "Entre com o valor maximo para poupanca programada."
     
     SKIP(1)
     aux_pzminpro AT 16 LABEL "Prazo minimo para vencimento(meses)"
         HELP "Entre com o prazo minimo para o vencimento"
     
     SKIP(1)     
     aux_pzmaxpro AT 16 LABEL "Prazo maximo para vencimento(meses)"
         HELP "Entre com o prazo maximo para o vencimento"
     
     SKIP(5)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab031.

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
               CLEAR FRAME f_tab025 NO-PAUSE.  
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab031.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab031"   THEN
                 DO:
                     HIDE FRAME f_tab031.
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
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "VLMAXPPROG"   AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.
                   
   IF   AVAILABLE craptab   THEN
        ASSIGN aux_vlmaxppr = DECIMAL(craptab.dstextab).
   ELSE
        ASSIGN aux_vlmaxppr = 0.
 
   FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 0              AND
                          craptab.tpregist = 2 NO-LOCK:
   
       IF   craptab.cdacesso = "PZMAXPPROG"   THEN
            aux_pzmaxpro = INTEGER(craptab.dstextab).
       ELSE
       IF   craptab.cdacesso = "PZMINPPROG"   THEN
            aux_pzminpro = INTEGER(craptab.dstextab).
   
   END.
   
   DISPLAY aux_vlmaxppr 
           aux_pzmaxpro
           aux_pzminpro WITH FRAME f_tab031.

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE aux_vlmaxppr WITH FRAME f_tab031.
                  LEAVE.
                  
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "GENERI"       AND
                                  craptab.cdempres = 0              AND
                                  craptab.cdacesso = "VLMAXPPROG"   AND
                                  craptab.tpregist = 0   
                                  EXCLUSIVE-LOCK NO-ERROR.
                
               IF   AVAILABLE craptab   THEN         
                    ASSIGN craptab.dstextab = STRING(aux_vlmaxppr,
                                                     "999999.99"). 
               
               DO WHILE TRUE:
                  
                  UPDATE aux_pzminpro WITH FRAME f_tab031.
            
                  FIND craptab WHERE craptab.cdcooper = 0              AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "GENERI"       AND
                                     craptab.cdempres = 0              AND
                                     craptab.cdacesso = "PZMINPPROG"   AND
                                     craptab.tpregist = 1
                                     NO-LOCK NO-ERROR.
               
                  IF   AVAILABLE craptab THEN
                       DO:
                           IF   aux_pzminpro < INTEGER(craptab.dstextab)   THEN
                                DO:
                                    glb_cdcritic = 916.
                                    RUN fontes/critic.p.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    NEXT.
                                END.                               
                           ELSE
                                LEAVE.
                       END.
               END.                

               DO WHILE TRUE:
               
                  UPDATE aux_pzmaxpro WITH FRAME f_tab031.
                  
                  FIND craptab WHERE craptab.cdcooper = 0              AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "GENERI"       AND
                                     craptab.cdempres = 0              AND
                                     craptab.cdacesso = "PZMAXPPROG"   AND
                                     craptab.tpregist = 1 
                                     NO-LOCK NO-ERROR.

                  IF   AVAILABLE craptab   THEN
                       DO:
                           IF   aux_pzmaxpro > INTEGER(craptab.dstextab)   OR
                                aux_pzmaxpro < aux_pzminpro                THEN
                                DO:
                                    glb_cdcritic = 916.
                                    RUN fontes/critic.p.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    NEXT.
                                END.
                           ELSE
                                LEAVE.
                       END.
               END.
                    
               FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                      craptab.nmsistem = "CRED"        AND
                                      craptab.tptabela = "GENERI"      AND
                                      craptab.cdempres = 0             AND
                                      craptab.tpregist = 2     
                                      EXCLUSIVE-LOCK:
                                      
                   IF   craptab.cdacesso = "PZMINPPROG"   THEN
                        craptab.dstextab = STRING(aux_pzminpro).
                   ELSE
                   IF   craptab.cdacesso = "PZMAXPPROG"   THEN
                        craptab.dstextab = STRING(aux_pzmaxpro).
               END.
            
            END.
            
            RELEASE craptab.

            CLEAR FRAME f_tab031 NO-PAUSE.

        END.  /* Fim da opcao "A" */

END.  /*  Fim do DO WHILE TRUE  */
/* .......................................................................... */
