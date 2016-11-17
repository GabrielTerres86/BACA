/*..............................................................................

   Programa : Fontes/tab047.p
   Sistena  : Conta-Corrente -  Cooperativa de Credito
   Sigla    : CRED
   Autor    : Gabriel/Evandro
   Data     : Novembro/07.                     Ultima atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia : Dario (on-line)
   Objetivo   : Mostrar a tela tab047 (Tarifas INSS).
                 
   Alteracoes : 08/02/2008 - Gerar "log/tab047.log" (Gabriel). 
                
                06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).
                             
                19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
..............................................................................*/

{ includes/var_online.i }
        
         /* Taxa para agencia pioneira */
DEF VAR  tel_txpionei AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.

         /* Taxa para uso do cartao magnetico */
DEF VAR  tel_txcarmag AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.

         /* Taxa para o credito em conta corrente */
DEF VAR  tel_txcredcc AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.

         /* Taxa para uso do recibo */
DEF VAR  tel_txrecibo AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.

         /* Variaveis para verificar alteracao nos campos */
DEF VAR  aux_txpionei AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.
DEF VAR  aux_txcarmag AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.
DEF VAR  aux_txcredcc AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.
DEF VAR  aux_txrecibo AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.
    
         /* Variaveis para gerar log */
DEF VAR  aux_nmdcampo AS CHARACTER                                  NO-UNDO.
DEF VAR  aux_vldantes AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.
DEF VAR  aux_vldepois AS DECIMAL         FORMAT "zzzzz9.99"         NO-UNDO.

DEF VAR  aux_cddopcao AS CHAR                                       NO-UNDO.
DEF VAR  aux_contador AS INTEGER                                    NO-UNDO.
DEF VAR  aux_confirma AS CHAR            FORMAT "!"                 NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP(2) 
     glb_cddopcao AT 02 LABEL "Opcao" AUTO-RETURN
                        HELP  "Informe a opcao desejada (A ou C)"
                        VALIDATE(glb_cddopcao = "A"  OR glb_cddopcao = "C", 
                                 "014 - Opcao errada.")
     SKIP(3)
     tel_txpionei AT 26 LABEL "Tarifa para PAs pioneiros" AUTO-RETURN
               HELP "Informe o valor da tarifa para PAs pioneiros."
     SKIP(1)
     tel_txcarmag AT 02
          LABEL "Tarifa para pagamento atraves de cartao magnetico" AUTO-RETURN
          HELP "Informe o valor da tarifa para pagamento com cartao magnetico."
     SKIP(1)
     tel_txcredcc AT 04
            LABEL "Tarifa para pagamento atraves de credito em c/c" AUTO-RETURN
            HELP "Informe o valor da tarifa para credito em conta corrente."
     SKIP(1)
     tel_txrecibo AT 05
             LABEL "Tarifa para pagamento atraves de recibo avulso" AUTO-RETURN
             HELP "Informe o valor da tarifa para pagamento com recibo avulso."
     SKIP(3)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_tab047.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
      UPDATE glb_cddopcao WITH FRAME f_tab047.
      LEAVE.
   END.    

   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /*  F4 ou fim  */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS (glb_nmdatela) <> "TAB047"   THEN
                 DO:
                     HIDE FRAME f_tab047.
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
        
   FIND craptab WHERE craptab.cdcooper = 0              AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "TARINSBCOB"   AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 55.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
                        
   ASSIGN tel_txpionei = DEC(SUBSTRING(craptab.dstextab,01,9))
          tel_txcarmag = DEC(SUBSTRING(craptab.dstextab,11,9))
          tel_txcredcc = DEC(SUBSTRING(craptab.dstextab,21,9))
          tel_txrecibo = DEC(SUBSTRING(craptab.dstextab,31,9)).

   DISPLAY tel_txpionei
           tel_txcarmag
           tel_txcredcc
           tel_txrecibo
           WITH FRAME f_tab047.

   IF   glb_cddopcao = "A"   THEN
        DO:
            ASSIGN aux_txpionei = tel_txpionei
                   aux_txcarmag = tel_txcarmag
                   aux_txcredcc = tel_txcredcc
                   aux_txrecibo = tel_txrecibo.
            
            
            UPDATE tel_txpionei
                   tel_txcarmag
                   tel_txcredcc
                   tel_txrecibo
                   WITH FRAME f_tab047.
                     
            
            /* pede confirmacao */
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
                 aux_confirma <> "S"                   THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
                 
            DO aux_contador = 1 TO 10 TRANSACTION:

               FIND craptab WHERE craptab.cdcooper = 0              AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "GENERI"       AND
                                  craptab.cdempres = 0              AND
                                  craptab.cdacesso = "TARINSBCOB"   AND
                                  craptab.tpregist = 0
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE craptab   THEN
                    IF   LOCKED craptab      THEN
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

               IF   tel_txpionei <> aux_txpionei   THEN
                    DO: 
                        ASSIGN aux_nmdcampo = "Tarifa para PAs pioneiros"
                               aux_vldantes = aux_txpionei
                               aux_vldepois = tel_txpionei.
                        
                        RUN gera_log(aux_nmdcampo, aux_vldantes, aux_vldepois).
                    END.           
                               
               IF   tel_txcarmag <> aux_txcarmag   THEN
                    DO:
                        ASSIGN aux_nmdcampo = "Tarifa para pagamento atraves" +
                                              " de cartao magnetico"
                               aux_vldantes = aux_txcarmag   
                               aux_vldepois = tel_txcarmag. 
                               
                        RUN gera_log(aux_nmdcampo, aux_vldantes,
                                     aux_vldepois).
                    END.
                   
               IF   tel_txcredcc <> aux_txcredcc   THEN
                    DO:
                        ASSIGN aux_nmdcampo = "Tarifa para pagamento atraves" +
                                              " de credito em c/c"
                               aux_vldantes = aux_txcredcc
                               aux_vldepois = tel_txcredcc.
                    
                         
                        RUN gera_log(aux_nmdcampo, aux_vldantes, aux_vldepois).
                    END.                          
               
               IF   tel_txrecibo <> aux_txrecibo   THEN
                    DO:
                        ASSIGN aux_nmdcampo = "Tarifa para pagamento atraves" +
                                              " de recibo avulso"
                               aux_vldantes = aux_txrecibo
                               aux_vldepois = tel_txrecibo.
                    
                        RUN gera_log (aux_nmdcampo, aux_vldantes, aux_vldepois).
                    END.
               
               
               ASSIGN craptab.dstextab = STRING(tel_txpionei,"999999.99") +
                                         " " +
                                         STRING(tel_txcarmag,"999999.99") +
                                         " " +
                                         STRING(tel_txcredcc,"999999.99") +
                                         " " +
                                         STRING(tel_txrecibo,"999999.99").
               RELEASE craptab.
               
               LEAVE.
            END.      /*   Fim do DO TO   */
            
            IF   glb_cdcritic > 0   THEN
                 DO: 
                     RUN fontes/critic.p.
                     BELL.
                     glb_cdcritic = 0.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
        END.
        
END. /*  Fim do DO WHILE TRUE  */


PROCEDURE gera_log:
          
    DEF INPUT PARAM par_nmdcampo AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_vldantes AS DECIMAL                     NO-UNDO.
    DEF INPUT PARAM par_vldepois AS DECIMAL                     NO-UNDO.
          
    UNIX SILENT
         VALUE("echo " + STRING(glb_dtmvtolt, "99/99/9999")
               + " " +
               STRING(TIME,"HH:MM:SS") + "' --> '"   +
               " Operador " + glb_cdoperad           +
               " alterou  o campo " + par_nmdcampo   +
               " de " +   STRING (par_vldantes, "zzzzz9.99")      +  
               " para " + STRING (par_vldepois, "zzzzz9.99")      +
               " >> log/tab047.log").
END.
                                            

/*............................................................................*/
