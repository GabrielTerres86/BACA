/* .............................................................................

   Programa: Fontes/sol030.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : marco/93                          Ultima atualizacao: 30/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL030.

   Alteracoes: 24/03/95 - Alterado para permitir a solicitacao no mes de abril.
                          (Deborah)

               04/02/97 - Alterado para permitir a solicitacao no mes de feve-
                          reiro (Deborah).

               14/01/98 - Alterado para permitir a solicitacao de janeiro a
                          abril (Edson).

               06/03/2001 - Tratar os percentuais de retorno sobre juros ao
                            capital e sobre rendimentos pagos (Deborah).

               25/02/2005 - Atualizacao do layout da tela (Edson).

               07/03/2005 - Tirado atualizacao do indicador de credito do 
                            retorno. Deve ser sempre S para entrar os demais
                            calculos. (Deborah).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/02/2008 - Incluir parametro para tratar contas com data de
                            demissao (David).
               
               29/04/2008 - Permitir emitir relatorios quando execucao for 
                            PREVIA (Sidnei - Precise)

               14/10/2008 - Incluir indicador para retorno de sobra sobre 
                            o desconto de titulos (David).

               06/02/2009 - Acerto na atualizacao da craptab EXEICMIRET (David).
               
               26/03/2009 - Nao permitir previa no processo batch (David).
               
               15/02/2011 - Incluso saldo medio, retirado PJ (Guilherme).
               
               22/03/2011 - Aumento das casas decimais para 8 dig (Guilherme).
               
               16/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               11/08/2014 - Permitir informar se o credito de sobras deve
                            ser efetuado (David).
                            
               11/02/2015 - Adicionado opcao 'D' e botao de alterar. (Reinert)
                            
               30/10/2015 - Adição de cotas sobre tarifas pagas. (Dionathan)
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_ininccmi AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR tel_increret AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR tel_indeschq AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR tel_indestit AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR tel_txretorn AS DECIMAL FORMAT "zz9.99999999"         NO-UNDO.
DEF        VAR tel_inpredef AS LOGICAL FORMAT "PREVIO/DEFINITIVO"    NO-UNDO.
DEF        VAR tel_dtanoinc AS INTEGER FORMAT "9999"                 NO-UNDO.
DEF        VAR tel_dtanoret AS INTEGER FORMAT "9999"                 NO-UNDO.
DEF        VAR tel_txjurcap AS DECIMAL FORMAT "zz9.99999999-"        NO-UNDO.
DEF        VAR tel_txjurapl AS DECIMAL FORMAT "zz9.99999999"         NO-UNDO.
DEF        VAR tel_txjursdm AS DECIMAL FORMAT "zz9.99999999"         NO-UNDO.
DEF        VAR tel_txjurtar AS DECIMAL FORMAT "zz9.99999999"         NO-UNDO.
DEF        VAR tel_indemiti AS LOGICAL FORMAT "S/N"                  NO-UNDO.

DEF        VAR tel_dtinform AS DATE                                  NO-UNDO.

DEF     BUTTON tel_btnalter LABEL "ALTERAR".

DEF        VAR aux_ininccmi AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_indeschq AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_indestit AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_indemiti AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_increret AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_inpredef AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SKIP (1)
     glb_cddopcao AT 47 LABEL "Opcao" AUTO-RETURN
                  HELP "Entre com a opcao desejada (C ou D)"
                  VALIDATE (glb_cddopcao = "D" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")
    WITH SIDE-LABELS TITLE glb_tldatela 
          ROW 4 SIZE 80 BY 18 COLUMN 1 OVERLAY FRAME f_opcao.

FORM SKIP (1)    
     "Credito de retorno sobre juros pagos em " AT 8
     tel_dtanoret AT 48 NO-LABEL
     ":"          AT 52
     tel_increret AT 54 NO-LABEL
                  HELP "Entre com S ou N"
     "(S/N)"      AT 56
     SKIP
     "Considerar juros de descontos de cheques:" AT 12
     tel_indeschq AT 54 NO-LABEL
                        HELP "Entre com S ou N"
     "(S/N)"      AT 56
     SKIP
     "Considerar juros de descontos de titulos:" AT 12
     tel_indestit AT 54 NO-LABEL
                        HELP "Entre com S ou N"
     "(S/N)"      AT 56
     SKIP
     "Considerar demitidos:" AT 32 
     tel_indemiti AT 54 NO-LABEL
                        HELP "Considerar demitidos (anterior ao ano atual)"
     "(S/N)"      AT 56
     SKIP(1)
     "Percentual de retorno sobre juros pagos:" AT 13
     tel_txretorn AT 54 NO-LABEL
         HELP "Entre com o percentual de retorno a ser pago s/juros pagos"
     "%"
     SKIP
     "Percentual de retorno sobre rendimentos pagos:" AT 7
     tel_txjurapl AT 54 NO-LABEL
                  HELP "Entre com o percentual de retorno s/rendimentos pagos"
     "%"
     SKIP
     "Percentual de retorno sobre saldo medio de C/C:" AT 6
     tel_txjursdm AT 54 NO-LABEL
                  HELP "Entre com o percentual de retorno s/ saldo medio c/c"
     "%"
     SKIP
     "Percentual de retorno sobre tarifas:" AT 17
     tel_txjurtar AT 54 NO-LABEL
                  HELP "Entre com o percentual de retorno s/ tarifas"
     "%"
     SKIP
     "Percentual de juros ao capital" AT 23
     tel_txjurcap AT 54 NO-LABEL
                  HELP "Entre com o percentual de retorno s/juros ao capital"
     SPACE(0) "%"
     SKIP
     "Tipo de calculo:" AT 37
     tel_inpredef AT 54 NO-LABEL
                  HELP "Entre com (P)revio ou (D)efinitivo"     
     WITH SIDE-LABELS OVERLAY NO-BOX ROW 7 COLUMN 2 WIDTH 78 
        FRAME f_sol030.

FORM
    tel_dtinform AT 10 LABEL "Data apresentacao informativo Conta Online"
    FORMAT "99/99/9999"
    WITH SIDE-LABELS OVERLAY NO-BOX ROW 12 COLUMN 2 WIDTH 78 
        FRAME f_d_sol030.

FORM
    SKIP(1)
    tel_btnalter AT 35 HELP "Pressione ENTER para alterar."
     WITH SIDE-LABELS OVERLAY NO-BOX ROW 19 COLUMN 2 WIDTH 78 
        FRAME f_but_sol030.

ASSIGN tel_dtanoinc = INTEGER(YEAR(glb_dtmvtolt) - 1)
       tel_dtanoret = INTEGER(YEAR(glb_dtmvtolt) - 1).

ON CHOOSE OF tel_btnalter IN FRAME f_but_sol030 
DO: 
    IF glb_cddopcao = "C" THEN
       ASSIGN glb_cddopcao = "A".
    ELSE IF glb_cddopcao = "D" THEN
       ASSIGN glb_cddopcao = "I".

    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
         END.

    IF  glb_cddopcao = "A" THEN
        DO TRANSACTION ON ENDKEY UNDO, LEAVE:
           
            DO  aux_contador = 1 TO 10:
       
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND
                                  UPPER(craptab.nmsistem) = "CRED"       AND
                                  UPPER(craptab.tptabela) = "GENERI"     AND
                                  craptab.cdempres = 00                  AND
                                  UPPER(craptab.cdacesso) = "EXEICMIRET" AND
                                  craptab.tpregist = 001
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
               IF   NOT AVAILABLE craptab   THEN
                    IF   LOCKED craptab   THEN
                         DO:
                             glb_cdcritic = 120.
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 115.
                             CLEAR FRAME f_sol030.
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
       
            ASSIGN tel_ininccmi = IF INT(SUBSTRING(dstextab,1,1)) = 1
                                     THEN TRUE
                                     ELSE FALSE
                   tel_increret = IF INT(SUBSTRING(dstextab,3,1)) = 1
                                     THEN TRUE
                                     ELSE FALSE
                   tel_txretorn = DECIMAL(SUBSTRING(dstextab,5,12))
                   tel_txjurcap = DECIMAL(SUBSTRING(dstextab,20,13))
                   tel_txjurapl = DECIMAL(SUBSTRING(dstextab,33,12))
                   tel_txjursdm = DECIMAL(SUBSTRING(dstextab,54,12))
                   tel_txjurtar = DECIMAL(SUBSTRING(dstextab,78,12))
                   tel_inpredef = IF INT(SUBSTRING(dstextab,18,1)) = 1
                                     THEN FALSE
                                     ELSE TRUE
                   tel_indeschq = IF INT(SUBSTRING(dstextab,46,1)) = 1
                                     THEN TRUE
                                     ELSE FALSE
                   tel_indemiti = IF INT(SUBSTRING(dstextab,50,1)) = 1
                                     THEN TRUE
                                     ELSE FALSE
                   tel_indestit = IF INT(SUBSTRING(dstextab,52,1)) = 1
                                     THEN TRUE
                                     ELSE FALSE.
            
            DISPLAY tel_dtanoret tel_increret tel_txretorn 
                    tel_inpredef tel_indeschq tel_indestit
                    tel_indemiti tel_txjurcap tel_txjurapl
                    tel_txjursdm tel_txjurtar
                    WITH FRAME f_sol030.
                                      
            IF   MONTH(glb_dtmvtolt) > 4   THEN
                 DO:
                     ASSIGN glb_cdcritic = 282.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
                 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE tel_increret tel_indeschq tel_indestit 
                       tel_indemiti tel_txretorn tel_txjurapl 
                       tel_txjursdm tel_txjurtar tel_txjurcap
                       tel_inpredef
                       WITH FRAME f_sol030
               
                EDITING:
                         READKEY.
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                END.
                
                IF   NOT tel_ininccmi AND
                     NOT tel_increret AND 
                     tel_txjurcap = 0 AND
                     tel_txjurapl = 0 AND 
                     tel_txjursdm = 0 THEN
                     DO:
                         ASSIGN glb_cdcritic = 284.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT.
                     END.
                
                IF   (tel_txretorn > 0 AND NOT tel_increret) OR
                     (tel_txretorn = 0 AND tel_increret)     THEN
                     DO:
                         ASSIGN glb_cdcritic = 180.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT-PROMPT tel_txretorn WITH FRAME f_sol030.
                         NEXT.
                     END.
               
                IF   tel_txjurcap < -100 THEN
                     DO:
                         ASSIGN glb_cdcritic = 180.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT-PROMPT tel_txjurcap WITH FRAME f_sol030.
                         NEXT.
                     END.
           
                ASSIGN aux_ininccmi = IF  tel_ininccmi  THEN
                                          "1"
                                      ELSE 
                                          "0"
                       aux_increret = IF  tel_increret  THEN
                                          "1"
                                      ELSE 
                                          "0"
                       aux_inpredef = IF  tel_inpredef  THEN
                                          "0"
                                      ELSE 
                                          "1"
                       aux_indeschq = IF  tel_indeschq  THEN
                                          "1"
                                      ELSE 
                                          "0"
                       aux_indestit = IF  tel_indestit  THEN
                                          "1"
                                      ELSE 
                                          "0"
                       aux_indemiti = IF  tel_indemiti  THEN
                                          "1"
                                      ELSE 
                                          "0".
               
                IF   NOT tel_inpredef   THEN
                     DO:
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                            aux_confirma = "N".
                            glb_dscritic = "ATENCAO!!! Voce esta " +
                                 "solicitando o processo DEFINITIVO.".
                            BELL.
                            MESSAGE COLOR NORMAL glb_dscritic.
                            MESSAGE COLOR NORMAL 
                                    "           Este processo NAO TEM"
                                    "VOLTA. Confirme"
                                    "a operacao (S/N):"
                                    UPDATE aux_confirma.
                            LEAVE.
               
                         END.
               
                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                              aux_confirma <> "S" THEN
                              DO:
                                  NEXT-PROMPT tel_inpredef 
                                              WITH FRAME f_sol030.
                                  NEXT.
                              END.
               
                         ASSIGN SUBSTR(craptab.dstextab, 1, 89) = aux_ininccmi + " " +
                                         aux_increret + " " +
                                         STRING(tel_txretorn, "999.99999999")
                                         + " " +
                                         aux_inpredef + " " +
                                         STRING(tel_txjurcap, "999.99999999-") +
                                         STRING(tel_txjurapl, "999.99999999") + " " +
                                         aux_indeschq + "   " +
                                         aux_indemiti + " " +
                                         aux_indestit + " " +
                                         STRING(tel_txjursdm, "999.99999999") + " " +
                                         SUBSTR(craptab.dstextab, 67, 10) + " " +
                                         STRING(tel_txjurtar, "999.99999999").
                         VALIDATE craptab.
                     END.
                ELSE 
                     /* PARA PREVIO, EMITIR RELATORIOS ON-LINE */
                     DO:
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                            aux_confirma = "N".
                            MESSAGE COLOR NORMAL 
                                    "O calculo previo sera executado " +
                                    "on-line. Deseja continuar (S/N):"
                                    UPDATE aux_confirma.
                            LEAVE.
                         
                         END.
               
                         IF  aux_confirma = "S"  THEN
                             DO:
                                 ASSIGN SUBSTR(craptab.dstextab, 1, 89) = aux_ininccmi + 
                                         " " + aux_increret + " " +
                                         STRING(tel_txretorn, "999.99999999")
                                         + " " +
                                         aux_inpredef + " " +
                                         STRING(tel_txjurcap, "999.99999999-") +
                                         STRING(tel_txjurapl, "999.99999999") + " " +
                                         aux_indeschq + "   " +
                                         aux_indemiti + " " +
                                         aux_indestit + " " +
                                         STRING(tel_txjursdm, "999.99999999") + " " +
                                         SUBSTR(craptab.dstextab, 67, 10) + " " +
                                         STRING(tel_txjurtar, "999.99999999").
                                 VALIDATE craptab.
               
                                 CREATE crapsol.
                                 ASSIGN crapsol.nrsolici = 106
                                        crapsol.dtrefere = glb_dtmvtolt
                                        crapsol.nrseqsol = 01
                                        crapsol.cdempres = 11
                                        crapsol.dsparame = ""
                                        crapsol.insitsol = 1
                                        crapsol.nrdevias = 1
                                        crapsol.cdcooper = glb_cdcooper.
                                 VALIDATE crapsol.
               
                                 MESSAGE "Executando Relatorios .....".
                                 
                                 RUN fontes/crps510.p.
                                 
                                 DELETE crapsol.
                             END.
                     END.
                LEAVE.
               
            END.  /*  Fim do DO WHILE TRUE  */
       
            CLEAR FRAME f_sol030 NO-PAUSE.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
       
       END. /* Fim da transacao */
    ELSE
       IF  glb_cddopcao = "I" THEN
           DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   UPDATE tel_dtinform WITH FRAME f_d_sol030.    
    
                   IF  tel_dtinform < glb_dtmvtolt OR 
                       tel_dtinform = ?            THEN
                       DO:
                           MESSAGE "Data informada deve ser maior ou igual a data atual.".
                           NEXT.
                       END.
                   ELSE                       
                       DO:
                           aux_confirma = "N".
                           MESSAGE COLOR NORMAL 
                                   "Confirma operacao? (S/N):"
                                   UPDATE aux_confirma.
                           LEAVE.
                       END.
               END.
       
               IF  aux_confirma = "S"  THEN
                   DO:
                       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "GENERI"       AND
                                    craptab.cdempres = 00             AND
                                    craptab.cdacesso = "EXEICMIRET"   AND
                                    craptab.tpregist = 001
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       IF   AVAIL craptab THEN
                            DO:
                                ASSIGN SUBSTR(craptab.dstextab,67,10) = STRING(tel_dtinform,"99/99/9999").
                                VALIDATE craptab.
                            END.
                          
                   END.               
              
           END.
   
    RELEASE craptab.      

END.

DO WHILE TRUE:

    RUN fontes/inicia.p.

    ASSIGN glb_cddopcao = "C".

    DISPLAY glb_cddopcao WITH FRAME f_opcao.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE glb_cddopcao WITH FRAME f_opcao.
       LEAVE.

    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "SOL030"   THEN
                  DO:
                      HIDE FRAME f_opcao.
                      HIDE FRAME f_sol030.
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
    
    IF   glb_cddopcao = "C" THEN
         DO:
             FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "GENERI"       AND
                                craptab.cdempres = 00             AND
                                craptab.cdacesso = "EXEICMIRET"   AND
                                craptab.tpregist = 001
                                NO-LOCK NO-ERROR NO-WAIT.

             IF   AVAILABLE craptab   THEN
                  DO:
                      ASSIGN
                      tel_ininccmi = IF INTEGER(SUBSTRING(dstextab,1,1)) = 1
                                        THEN TRUE
                                        ELSE FALSE
                      tel_increret = IF INTEGER(SUBSTRING(dstextab,3,1)) = 1
                                        THEN TRUE
                                        ELSE FALSE
                      tel_txretorn = DECIMAL(SUBSTRING(dstextab,5,12))
                      tel_txjurcap = DECIMAL(SUBSTRING(dstextab,20,13))
                      tel_txjurapl = DECIMAL(SUBSTRING(dstextab,33,12))
                      tel_txjursdm = DECIMAL(SUBSTRING(dstextab,54,12))
                      tel_txjurtar = DECIMAL(SUBSTRING(dstextab,78,12))
                      tel_inpredef = IF INTEGER(SUBSTRING(dstextab,18,1))
                                        = 1 THEN FALSE
                                     ELSE        TRUE

                      tel_indeschq = IF INT(SUBSTRING(dstextab,46,1)) = 1
                                        THEN TRUE
                                        ELSE FALSE
                      tel_indemiti = IF INT(SUBSTRING(dstextab,50,1)) = 1
                                        THEN TRUE
                                        ELSE FALSE
                      tel_indestit = IF INT(SUBSTRING(dstextab,52,1)) = 1
                                        THEN TRUE
                                        ELSE FALSE.
                                        
                      DISPLAY tel_dtanoret tel_increret tel_txretorn 
                              tel_inpredef tel_indeschq tel_indestit
                              tel_txjurcap tel_txjurapl tel_txjursdm
                              tel_indemiti tel_txjurtar
                              WITH FRAME f_sol030.
                      
                      ENABLE tel_btnalter WITH FRAME f_but_sol030.                      
                      WAIT-FOR CHOOSE OF tel_btnalter.
                      HIDE FRAME f_sol030.
                      HIDE FRAME f_but_sol030.
                      
                  END.
             ELSE
                  DO:
                      glb_cdcritic = 115.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      CLEAR FRAME f_sol030.
                      NEXT.
                  END.
         END.
     ELSE
         IF  glb_cddopcao = "D" THEN
             DO:
                FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "GENERI"       AND
                                   craptab.cdempres = 00             AND
                                   craptab.cdacesso = "EXEICMIRET"   AND
                                   craptab.tpregist = 001
                                   NO-LOCK NO-ERROR.
                IF  AVAIL craptab THEN
                    DO:                        
                        ASSIGN tel_dtinform = DATE(SUBSTR(craptab.dstextab,67,10)).
                                              
                        DISP tel_dtinform WITH FRAME f_d_sol030.

                        ENABLE tel_btnalter WITH FRAME f_but_sol030.                      
                        WAIT-FOR CHOOSE OF tel_btnalter.

                        HIDE FRAME f_sol030.
                        HIDE FRAME f_but_sol030.
                      
                    END.
                ELSE
                    DO:
                        glb_cdcritic = 115.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_sol030.
                        NEXT.
                    END.                
             END.
END.

/* .......................................................................... */



