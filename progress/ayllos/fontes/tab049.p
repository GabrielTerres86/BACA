/*..............................................................................

   Programa: Fontes/tab049.p
   Sistema : Conta-Corrente
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Fevereiro/2008                     Ultima alteracao: 07/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tab049 - Manutencao referente aos parametros de seguro
                        prestamista.
   
   Alteracao : 07/08/2008 - Incluidos campos "Subestipulante" e "Sigla arquivo"
                          - Acerto no layout da tela (Diego).
                          
               14/11/2008 - Incluido campo "Sequencia" (Diego).
               
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               24/03/2010 - Criacao de um arquivo de log (Daniel Steiner)
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
               
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
..............................................................................*/


{ includes/var_online.i }

     /*  Valor minimo */
DEF  VAR tel_valormin AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

     /*  Valor maximo   */
DEF  VAR tel_valormax AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

     /*  Data inicio da vigencia */
DEF  VAR tel_datadvig AS DATE    FORMAT "99/99/9999"                    NO-UNDO.

     /*  Pagamento seguradora  */                           
DEF  VAR tel_pgtosegu AS DECIMAL FORMAT "9.99999"                       NO-UNDO.

DEF  VAR tel_subestip AS CHAR    FORMAT "x(25)"                         NO-UNDO.

DEF  VAR tel_sglarqui AS CHAR    FORMAT "x(02)"                         NO-UNDO.

DEF  VAR tel_nrsequen AS INT     FORMAT "99999"                         NO-UNDO.

DEF  VAR aux_cddopcao AS CHARACTER                                      NO-UNDO.
DEF  VAR aux_confirma AS CHARACTER FORMAT "!"                           NO-UNDO.
DEF  VAR aux_contador AS INTEGER                                        NO-UNDO.

/*variaveis de log*/
DEF  VAR log_valormin AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF  VAR log_valormax AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF  VAR log_datadvig AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF  VAR log_pgtosegu AS DECIMAL FORMAT "9.99999"                       NO-UNDO.
DEF  VAR log_subestip AS CHAR    FORMAT "x(25)"                         NO-UNDO.
DEF  VAR log_sglarqui AS CHAR    FORMAT "x(02)"                         NO-UNDO.
DEF  VAR log_nrsequen AS INT     FORMAT "99999"                         NO-UNDO.

DEF  VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF  VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF  VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF  VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF  VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF  VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF  VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     glb_cddopcao AT 32 LABEL "Opcao" AUTO-RETURN
                        HELP  "Informe a opcao desejada (A ou C)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                                  "014 - Opcao errada.")
     SKIP(1)
     "---------  PARAMETROS SEGURO PRESTAMISTA  ---------"   AT 15
     SKIP(1)
     tel_valormin AT 25 LABEL "Valor minimo" AUTO-RETURN
                        HELP  "Informe o valor minimo"          
     SKIP
     tel_valormax AT 25 LABEL "Valor maximo" AUTO-RETURN
                        HELP  "Informe o valor maximo"
     SKIP
     "Data inicio da vigencia:" AT 14 
     tel_datadvig               AT 43  NO-LABEL
                                HELP  "Informe a data inicio da vigencia"
     SKIP
     "Pagamento seguradora:"    AT 17
     tel_pgtosegu               AT 46  NO-LABEL
                        HELP  "Informe o pagamento seguradora"
     SKIP(1)
     "---------  PARAMETROS SEGURO CASA(CHUBB)  ---------"   AT 15
     SKIP(1)
     "Subestipulante:"          AT 23
     tel_subestip               NO-LABEL
                        HELP "Informe o Subestipulante"
     SKIP
     "Sigla arquivo:"           AT 24
     tel_sglarqui               NO-LABEL
                        HELP "Informe a Sigla do arquivo"
     SKIP                       
     "Sequencia:"               AT 28
     tel_nrsequen               NO-LABEL
     SKIP
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_tab049.
     
glb_cddopcao = "C".

DO WHILE TRUE:
   
   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao WITH FRAME f_tab049.
      LEAVE.
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN           /*  F4 ou fim  */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB049"   THEN
                 DO:
                     HIDE FRAME f_tab049.
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
            
   FIND craptab NO-LOCK WHERE craptab.cdcooper = glb_cdcooper   AND
                              craptab.nmsistem = "CRED"         AND
                              craptab.tptabela = "USUARI"       AND
                              craptab.cdempres = 11             AND
                              craptab.cdacesso = "SEGPRESTAM"   AND
                              craptab.tpregist = 0 NO-ERROR.
        
   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 55.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
            
   ASSIGN tel_valormin = DEC(SUBSTRING(craptab.dstextab,1,12))
          log_valormin = DEC(SUBSTRING(craptab.dstextab,1,12))
          tel_valormax = DEC(SUBSTRING(craptab.dstextab,14,12))
          log_valormax = DEC(SUBSTRING(craptab.dstextab,14,12))
          tel_datadvig = DATE(SUBSTRING(craptab.dstextab,40,10))     
          log_datadvig = DATE(SUBSTRING(craptab.dstextab,40,10))     
          tel_pgtosegu = DEC(SUBSTRING(craptab.dstextab,51,7))
          log_pgtosegu = DEC(SUBSTRING(craptab.dstextab,51,7))
          tel_subestip = SUBSTRING(craptab.dstextab,59,25)
          log_subestip = SUBSTRING(craptab.dstextab,59,25)
          tel_sglarqui = SUBSTRING(craptab.dstextab,85,2)
          log_sglarqui = SUBSTRING(craptab.dstextab,85,2)
          tel_nrsequen = INT(SUBSTRING(craptab.dstextab,88,5))
          log_nrsequen = INT(SUBSTRING(craptab.dstextab,88,5)).
   
   DISPLAY tel_valormin
           tel_valormax
           tel_datadvig   
           tel_pgtosegu 
           tel_subestip
           tel_sglarqui 
           tel_nrsequen WITH FRAME f_tab049.
           
   
   IF   glb_cddopcao = "A"   THEN
        DO: 
            /* Critica para permitir somente os operadores 1, 996 e 997 */  
            IF   glb_cddepart <> 20 AND   /*TI             */
                 glb_cddepart <>  9 THEN  /*COORD.PRODUTOS */
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            UPDATE tel_valormin 
                   tel_valormax
                   tel_datadvig
                   tel_pgtosegu 
                   tel_subestip
                   tel_sglarqui WITH FRAME f_tab049.
             
            DO WHILE TRUE:
               
               IF   tel_valormax <= tel_valormin   THEN
                    DO:
                        MESSAGE "Valor maximo deve ser maior que o valor " +
                                "minimo.".
                        UPDATE  tel_valormax WITH FRAME f_tab049.
                    END.
               ELSE
                    LEAVE.
            END.
             
                  
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.
               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.
            END.
               

            IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"   THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.    

            DO aux_contador = 1 TO 10 TRANSACTION:
            
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "USUARI"       AND
                                  craptab.cdempres = 11             AND
                                  craptab.cdacesso = "SEGPRESTAM"   AND
                                  craptab.tpregist = 0 
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
            
               ASSIGN craptab.dstextab = STRING(tel_valormin, "999999999.99") +
                                         " " +
                                         STRING(tel_valormax, "999999999.99") +
                                         " " +
                                         STRING(tel_valormin, "999999999.99") +
                                         " " +
                                         STRING(tel_datadvig, "99/99/9999")   +
                                         " " +
                                         STRING(tel_pgtosegu, "9.99999") + 
                                         " " + tel_subestip + 
                                         " " + tel_sglarqui + 
                                         " " + STRING(tel_nrsequen,"99999").
               LEAVE.
            
            END.  /* Fim do DO... TO  */ 
                                 

            IF   glb_cdcritic > 0   THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     glb_cdcritic = 0.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
            /*geracao do log*/
            IF   tel_valormin <> log_valormin   THEN 
                DO:
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o valor minimo de " +
                     TRIM(STRING(log_valormin)) + " para  " +
                     TRIM(STRING(tel_valormin)) + 
                     " >> log/tab049.log").
                END. 

            IF   tel_valormax <> log_valormax   THEN 
                DO:
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o valor maximo de " +
                     TRIM(STRING(log_valormax)) + " para  " +
                     TRIM(STRING(tel_valormax)) + 
                     " >> log/tab049.log").
                END.

            IF   tel_datadvig <> log_datadvig   THEN 
                DO:
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a data de inicio da vigencia de " +
                     TRIM(STRING(log_datadvig)) + " para  " +
                     TRIM(STRING(tel_datadvig)) + 
                     " >> log/tab049.log").
                END.

           IF   tel_pgtosegu <> log_pgtosegu   THEN 
                DO:
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o pagamento a seguradora de " +
                     TRIM(STRING(log_pgtosegu)) + " para  " +
                     TRIM(STRING(tel_pgtosegu)) + 
                     " >> log/tab049.log").
                END.

           IF   tel_subestip <> log_subestip   THEN 
                DO:
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou o Subestipulante de " +
                     TRIM(STRING(log_subestip)) + " para  " +
                     TRIM(STRING(tel_subestip)) + 
                     " >> log/tab049.log").
                END.

           IF   tel_sglarqui <> log_sglarqui    THEN 
                DO:
                UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                     "Operador " + glb_cdoperad +
                     " alterou a Sigla do arquivo de " +
                     TRIM(STRING(log_sglarqui)) + " para  " +
                     TRIM(STRING(tel_sglarqui)) + 
                     " >> log/tab049.log").
                END.
        END.   /* Fim da opcao "A" */

END.  /* Fim do DO WHILE TRUE  */

/*............................................................................*/
