/*..............................................................................

   Programa: fontes/msgsob.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Janeiro/2009                      Ultima atualizacao: 23/09/2014

   Dados referentes ao programa:
    
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MSGSOB - (Manutencao de mensagem impressa no
               informativo de Credito de Sobras).
   Alteracoes: 
                23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                             b1wgen9999.p procedure acha-lock, que identifica qual 
                             é o usuario que esta prendendo a transaçao. (Vanessa)

..............................................................................*/

{ includes/var_online.i }

DEF        VAR tel_dsmensob AS CHAR    FORMAT "x(50)" EXTENT 7       NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP(3)
     glb_cddopcao    AT  7 LABEL "Opcao"    AUTO-RETURN
        HELP "Entre com a opcao desejada (A ou C)."
        VALIDATE(CAN-DO("A,C",glb_cddopcao),"014 - Opcao errada.")
     SKIP(1)
     tel_dsmensob[1] AT  4 LABEL "Mensagem" AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     tel_dsmensob[2] AT 14 NO-LABEL         AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     tel_dsmensob[3] AT 14 NO-LABEL         AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     tel_dsmensob[4] AT 14 NO-LABEL         AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     tel_dsmensob[5] AT 14 NO-LABEL         AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     tel_dsmensob[6] AT 14 NO-LABEL         AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     tel_dsmensob[7] AT 14 NO-LABEL         AUTO-RETURN
        HELP "Informe a mensagem para o informativo de Credito de Sobras."
     SKIP(4)
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_mensob.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               CLEAR FRAME f_mensob.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
                                        
      UPDATE glb_cddopcao WITH FRAME f_mensob.

      LEAVE.
       
   END.  /*  Fim do DO WHILE TRUE  */
            
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
     
            IF   CAPS(glb_nmdatela) <> "MSGSOB"   THEN
                 DO:
                     HIDE FRAME f_mensob.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"    THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "MSGDSOBRAS"   AND
                               craptab.tpregist = 1
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT.
                 END.
        
            ASSIGN tel_dsmensob[1] = SUBSTRING(craptab.dstextab,001,050)
                   tel_dsmensob[2] = SUBSTRING(craptab.dstextab,051,050)
                   tel_dsmensob[3] = SUBSTRING(craptab.dstextab,101,050)
                   tel_dsmensob[4] = SUBSTRING(craptab.dstextab,151,050)
                   tel_dsmensob[5] = SUBSTRING(craptab.dstextab,201,050)
                   tel_dsmensob[6] = SUBSTRING(craptab.dstextab,251,050)
                   tel_dsmensob[7] = SUBSTRING(craptab.dstextab,301,050).

            DISPLAY tel_dsmensob WITH FRAME f_mensob.
        
        END.  /* Fim da opcao "C" */
   ELSE 
        DO TRANSACTION ON ENDKEY UNDO, LEAVE:
             
           DO aux_contador = 1 TO 10:
                                    
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "USUARI"       AND
                                 craptab.cdempres = 11             AND
                                 craptab.cdacesso = "MSGDSOBRAS"   AND
                                 craptab.tpregist = 1 
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
              
              glb_cdcritic = 0.
              LEAVE.
              
           END. /* Fim do DO ... TO */

           IF   glb_cdcritic > 0   THEN
                NEXT.
                
           ASSIGN tel_dsmensob[1] = SUBSTRING(craptab.dstextab,001,050)
                  tel_dsmensob[2] = SUBSTRING(craptab.dstextab,051,050)
                  tel_dsmensob[3] = SUBSTRING(craptab.dstextab,101,050)
                  tel_dsmensob[4] = SUBSTRING(craptab.dstextab,151,050)
                  tel_dsmensob[5] = SUBSTRING(craptab.dstextab,201,050)
                  tel_dsmensob[6] = SUBSTRING(craptab.dstextab,251,050)
                  tel_dsmensob[7] = SUBSTRING(craptab.dstextab,301,050).

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
              UPDATE tel_dsmensob WITH FRAME f_mensob.
                         
              ASSIGN craptab.dstextab = STRING(tel_dsmensob[1],"x(50)") +
                                        STRING(tel_dsmensob[2],"x(50)") +
                                        STRING(tel_dsmensob[3],"x(50)") +
                                        STRING(tel_dsmensob[4],"x(50)") +
                                        STRING(tel_dsmensob[5],"x(50)") +
                                        STRING(tel_dsmensob[6],"x(50)") +
                                        STRING(tel_dsmensob[7],"x(50)").
              LEAVE.

           END. /* Fim do DO WHILE TRUE */

           tel_dsmensob = "".
             
           DISPLAY tel_dsmensob WITH FRAME f_mensob.

           RELEASE craptab.
            
        END. /* Fim do TRANSACTION, opcao "A" */

END.  /* Fim do DO WHILE TRUE */

/*............................................................................*/
