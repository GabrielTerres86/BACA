/* ..........................................................................

   Programa: Fontes/abcpmf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Abril/2007                          Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ABCPMF (Abono de CPMF nas aplicacoes).

   
   Alteracoes:                                               
                
............................................................................. */

{includes/var_online.i }

DEF VAR tel_cddopcao AS CHAR     FORMAT "x(1)"        INIT "C"       NO-UNDO.
DEF VAR tel_abonaapl AS LOGICAL  FORMAT "Sim/Nao"     INIT TRUE      NO-UNDO.
DEF VAR tel_tpaplica AS INT      FORMAT "z9"                         NO-UNDO.
DEF VAR tel_dtdabono AS DATE     FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR aux_abonaapl AS LOG                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_confirma AS CHAR     FORMAT "!(1)"                       NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM 
    "Opcao: " glb_cddopcao  
              HELP "Informe a opcao desejada (A, C, E ou I)."
              VALIDATE (CAN-DO("A,C,E,I", glb_cddopcao), 
                                "014 - Opcao errada.")
    SKIP(3)
    "Aplicacao      :" tel_tpaplica 
    HELP "Informe o tipo de aplicacao."
    SKIP(1)
    "Abona CPMF?    : " tel_abonaapl
    HELP "Informe se abona CPMF da aplicacao."
    SKIP(1)
    "Inicio do Abono: "tel_dtdabono
    WITH FRAME f_dados ROW 6 COLUMN 8 NO-BOX NO-LABEL OVERLAY.


VIEW FRAME f_moldura.

PAUSE (0).
    
ASSIGN glb_cddopcao = "C".

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    RUN fontes/inicia.p.
       
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE : 
        UPDATE glb_cddopcao WITH FRAME f_dados. 
        LEAVE.
    END.    
    
         
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:
             RUN  fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "ABCPMF"   THEN
                  DO:
                    HIDE FRAME f_dados.
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
    
    
    UPDATE  tel_tpaplica WITH FRAME f_dados.
    
    IF glb_cddopcao = "C" THEN
       DO:                                      
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                              craptab.nmsistem = "CRED"          AND
                              craptab.tptabela = "CONFIG"        AND
                              craptab.cdempres = 0               AND
                              craptab.cdacesso = "TXADIAPLIC"    AND
                              craptab.tpregist = tel_tpaplica
                              NO-LOCK NO-ERROR.
                
           IF  AVAIL craptab THEN   
               DO:   
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                                     craptab.nmsistem = "CRED"          AND
                                     craptab.tptabela = "CONFIG"        AND
                                     craptab.cdempres = 0               AND
                                     craptab.cdacesso = "ABNCPMFAPL"    AND
                                     craptab.tpregist = tel_tpaplica
                                     NO-LOCK NO-ERROR.
                  
                  IF  AVAIL craptab THEN 
                      DO:
                          IF (SUBSTR(craptab.dstextab,1,1)) = "0" THEN
                              ASSIGN tel_abonaapl = YES.
                          ELSE
                              ASSIGN tel_abonaapl = NO.
                          
                          tel_dtdabono = DATE(SUBSTR(craptab.dstextab,3,10)).
                  
                          DISPLAY tel_abonaapl
                                  tel_dtdabono WITH FRAME f_dados.
                          NEXT.        
                      END.
                  ELSE
                      MESSAGE "Abono de CPMF nao cadastrado " + 
                              "para esta aplicacao.".
               END.  
           ELSE
               DO:
                    FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                                     craptab.nmsistem = "CRED"          AND
                                     craptab.tptabela = "CONFIG"        AND
                                     craptab.cdempres = 0               AND
                                     craptab.cdacesso = "ABNCPMFAPL"    AND
                                     craptab.tpregist = tel_tpaplica
                                     NO-LOCK NO-ERROR.
                    IF AVAIL craptab THEN
                       DO:
                          IF (SUBSTR(craptab.dstextab,1,1)) = "0" THEN
                              ASSIGN tel_abonaapl = YES.
                          ELSE
                              ASSIGN tel_abonaapl = NO.
                          
                          ASSIGN tel_dtdabono =
                                           DATE(SUBSTR(craptab.dstextab,3,10)).
                  
                          DISPLAY tel_abonaapl
                                  tel_dtdabono WITH FRAME f_dados.
                          NEXT.
                       END.
                    ELSE
                       DO:
                            ASSIGN glb_cdcritic = 347.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            CLEAR FRAME f_dados.  
                            NEXT.
                       END.
               END.
       END.
    ELSE
       IF glb_cddopcao = "I" THEN
          DO:
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "CONFIG"        AND
                                 craptab.cdempres = 0               AND
                                 craptab.cdacesso = "TXADIAPLIC"    AND
                                 craptab.tpregist = tel_tpaplica
                                 NO-LOCK NO-ERROR.
              
              IF AVAIL craptab THEN
                 DO:
                    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                       craptab.nmsistem = "CRED"        AND
                                       craptab.tptabela = "CONFIG"      AND
                                       craptab.cdempres = 0             AND
                                       craptab.cdacesso = "ABNCPMFAPL"  AND
                                       craptab.tpregist = tel_tpaplica
                                       NO-LOCK NO-ERROR .
                    
                    IF  NOT AVAIL craptab THEN
                        DO:
                    
                            UPDATE  tel_abonaapl  
                                    WITH FRAME f_dados.
                            
                            IF tel_abonaapl = YES THEN
                               DO:
                                  IF MONTH(TODAY) = 12 THEN
                                     ASSIGN tel_dtdabono = 
                                     DATE("01/01/" + STRING(YEAR(TODAY) + 1)).
                                  ELSE
                                     ASSIGN tel_dtdabono = 
                                                    DATE("01/"               + 
                                                    STRING(MONTH(TODAY) + 1) + 
                                                    "/" + STRING(YEAR(TODAY))).
                               END.
                            ELSE
                                ASSIGN tel_dtdabono = ?.
                            
                            DISPLAY tel_dtdabono WITH FRAME f_dados.
                                                        
                            RUN confirma.
                            IF aux_confirma = "S"   THEN 
                               DO:   
                                   CREATE  craptab.
                                   ASSIGN  craptab.cdcooper = glb_cdcooper 
                                           craptab.nmsistem = "CRED"
                                           craptab.tptabela = "CONFIG"
                                           craptab.cdempres = 0
                                           craptab.cdacesso = "ABNCPMFAPL"
                                           craptab.tpregist = tel_tpaplica.
                                            
                                   IF  tel_abonaapl = YES THEN
                                       ASSIGN craptab.dstextab = "0 " +
                                       STRING(tel_dtdabono,"99/99/9999").
                                   ELSE       
                                       ASSIGN craptab.dstextab = "1 ". 
                                     
                               END. /** Fim if aux_confirma **/
                        END.
                    ELSE
                        DO:
                            MESSAGE "Abono ja incluido para esta aplicacao.".
                            PAUSE 2 NO-MESSAGE.
                        END.
                 END.
              ELSE
                  DO:
                      ASSIGN glb_cdcritic = 347.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      CLEAR FRAME f_dados.  
                      NEXT.
                  END.
              LEAVE.
          END.
       ELSE
            IF  glb_cddopcao = "A" THEN
                DO:
                    FIND craptab WHERE  craptab.cdcooper = glb_cdcooper    AND
                                        craptab.nmsistem = "CRED"          AND
                                        craptab.tptabela = "CONFIG"        AND
                                        craptab.cdempres = 0               AND
                                        craptab.cdacesso = "TXADIAPLIC"    AND
                                        craptab.tpregist = tel_tpaplica
                                        NO-LOCK NO-ERROR.
                    
                    IF  AVAIL craptab THEN
                        DO:
                            FIND craptab WHERE 
                                         craptab.cdcooper = glb_cdcooper  AND
                                         craptab.nmsistem = "CRED"        AND
                                         craptab.tptabela = "CONFIG"      AND
                                         craptab.cdempres = 0             AND
                                         craptab.cdacesso = "ABNCPMFAPL"  AND
                                         craptab.tpregist = tel_tpaplica
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                        
                            IF  AVAIL craptab THEN
                                DO:
                                   IF (SUBSTR(craptab.dstextab,1,1)) = "0" THEN
                                       ASSIGN tel_abonaapl = YES
                                              aux_abonaapl = YES.
                                   ELSE
                                       ASSIGN tel_abonaapl = NO
                                              aux_abonaapl = NO.

                                   ASSIGN tel_dtdabono =
                                          DATE(SUBSTR(craptab.dstextab,3,10)).
                  
                                   DISPLAY tel_dtdabono WITH FRAME f_dados.
                                   
                                   UPDATE  tel_abonaapl
                                           WITH FRAME f_dados.
                                   
                                   IF tel_abonaapl = YES THEN
                                      DO: 
                                        IF  MONTH(TODAY) = 12 THEN
                                            ASSIGN 
                                                tel_dtdabono = DATE("01/01/" + 
                                                     STRING(YEAR(TODAY) + 1)).
                                        ELSE
                                            ASSIGN tel_dtdabono = 
                                        DATE("01/" + STRING(MONTH(TODAY) + 1) + 
                                             "/" + STRING(YEAR(TODAY))).
                                      END.  
                             
                                   ELSE
                                      DO:
                                        IF MONTH(glb_dtmvtolt) = 
                                           MONTH(glb_dtmvtoan) THEN
                                           DO:
                                             MESSAGE "Somente permitido " +
                                             "nao abonar no 1 dia util do mes.".
                                             ASSIGN tel_abonaapl = aux_abonaapl.
                                             DISPLAY tel_abonaapl 
                                                     WITH FRAME f_dados.
                                             NEXT.
                                           END.
                                          ELSE
                                              ASSIGN tel_dtdabono = ?.
                                       
                                       END.
                                   DISPLAY tel_dtdabono WITH FRAME f_dados.
                                   
                                   RUN confirma.
                                   
                                   IF aux_confirma = "S"   THEN
                                      DO:
                                         IF tel_abonaapl = YES THEN
                                            DO:
                                              ASSIGN craptab.dstextab = "0 " + 
                                              STRING(tel_dtdabono,"99/99/9999").
                                            END.
                                         ELSE
                                              ASSIGN craptab.dstextab = "1 ".
                                           
                                         DISPLAY tel_abonaapl 
                                                 tel_dtdabono 
                                                 WITH FRAME f_dados.
                                         NEXT.                          
                                       END. /** Fim IF aux_confirma **/
                                END.  
                            ELSE
                                MESSAGE "Abono de CPMF nao " + 
                                        "cadastrado para esta aplicacao.".
                        END.
                    ELSE
                        DO:
                            ASSIGN glb_cdcritic = 347.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            CLEAR FRAME f_dados.  
                            NEXT.
                        END.
                END.
            ELSE
               IF glb_cddopcao = "E" THEN
                  DO:
                    FIND craptab WHERE 
                                 craptab.cdcooper = glb_cdcooper    AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "CONFIG"        AND
                                 craptab.cdempres = 0               AND
                                 craptab.cdacesso = "TXADIAPLIC"    AND
                                 craptab.tpregist = tel_tpaplica
                                 NO-LOCK NO-ERROR.
                    
                    IF  NOT AVAIL craptab THEN  
                        DO:
                            FIND craptab WHERE 
                                          craptab.cdcooper = glb_cdcooper  AND
                                          craptab.nmsistem = "CRED"        AND
                                          craptab.tptabela = "CONFIG"      AND
                                          craptab.cdempres = 0             AND
                                          craptab.cdacesso = "ABNCPMFAPL"  AND
                                          craptab.tpregist = tel_tpaplica
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                        
                            IF  AVAIL craptab THEN
                                DO:
                                   IF (SUBSTR(craptab.dstextab,1,1)) = "0" THEN 
                                      ASSIGN tel_abonaapl = YES. 
                                   ELSE 
                                      ASSIGN tel_abonaapl = NO.
                                   
                                   tel_dtdabono =
                                            DATE(SUBSTR(craptab.dstextab,3,10)).
                  
                                   DISPLAY  tel_abonaapl
                                            tel_dtdabono WITH FRAME f_dados.
                                   
                                   RUN confirma.
                                   IF  aux_confirma = "S"   THEN
                                       DELETE craptab.
                                END.
                            ELSE
                                DO:
                                    ASSIGN glb_cdcritic = 347.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    CLEAR FRAME f_dados.  
                                    NEXT.
                                END.
                        END.
                    ELSE
                        DO:
                            MESSAGE "Exclusao nao permitida para" +  
                                    " aplicacao existente.".
                            BELL.
                            CLEAR FRAME f_dados.  
                            NEXT.
                        END.
                  END.
          
    CLEAR FRAME f_dados.      
    NEXT.

END.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

