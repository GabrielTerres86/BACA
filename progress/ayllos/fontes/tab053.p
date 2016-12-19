/* .............................................................................

   Programa: Fontes/tab053.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                         Ultima alteracao: 07/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB053 - Tarifas para o desconto de titulos.
   
   Alteracoes: - 11/02/2009 - Permissao para as cooperativas alterar,
                              criar log/tab053.log (Gabriel).

                 09/03/2009 - Tirar permissoes pras cooperativas, incluir 
                              mais uma linha pra manter padrao (Gabriel).
                              
                 25/05/2009 - Alteracao CDOPERAD (Kbase).
                 
                 28/06/2012 - Alteração no layout da tela (David Kruger).
                 
                 07/12/2016 - Alterado campo dsdepart para cddepart.
                              PRJ341 - BANCENJUD (Odirlei-AMcom)
                 
............................................................................. */

{ includes/var_online.i }

{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF VAR aux_contador AS INT                                   NO-UNDO.
DEF VAR flg_erro     AS LOGICAL                               NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                NO-UNDO.

DEF        TEMP-TABLE  tt-log LIKE tt-tarifas_dsctit.

FORM SKIP(1)
     glb_cddopcao AT 36 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tt-tarifas_dsctit.vltarctr AT 29 LABEL "Por contrato"
                        HELP "Entre com o valor da tarifa por contrato."
     SKIP(1)
     tt-tarifas_dsctit.vltarrnv AT 28 LABEL "Por renovacao"
                        HELP "Entre com o valor da tarifa por renovacao."
     SKIP(1)
     tt-tarifas_dsctit.vltarbdt AT 30 LABEL "Por bordero"
                        HELP "Entre com o valor da tarifa por bordero."
     SKIP(1)
     tt-tarifas_dsctit.vlttitcr AT 18 LABEL "Por titulo (Registrado)"
                        HELP "Entre com o valor da tarifa por titulo."

     SKIP(1)
     tt-tarifas_dsctit.vlttitsr AT 17 LABEL "Por titulo (S/ Registro)"
                        HELP "Entre com o valor da tarifa por titulo resgatado."
     SKIP(1)
     tt-tarifas_dsctit.vltrescr AT 8 LABEL "Por titulo resgatado (Registrado)"
                        HELP "Entre com o valor da tarifa por titulo resgatado."
     SKIP(1)
     tt-tarifas_dsctit.vltressr AT 7 LABEL "Por titulo resgatado (S/ Registro)"
                        HELP "Entre com o valor da tarifa por titulo resgatado."
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab053.

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
               CLEAR FRAME f_tab053 NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao WITH FRAME f_tab053.

      IF   NOT CAN-DO("C",glb_cddopcao)   THEN
           IF   glb_cddepart <> 20 AND   /* TI                   */
                glb_cddepart <> 14 AND   /* PRODUTOS             */
                glb_cddepart <>  8 THEN  /* COORD.ADM/FINANCEIRO */
                DO:
                    glb_cdcritic = 36.
                    NEXT.
                END.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab053"   THEN
                 DO:
                     HIDE FRAME f_tab053.
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
            RUN sistema/generico/procedures/b1wgen0030.p 
                PERSISTENT SET h-b1wgen0030.
        
            IF   NOT VALID-HANDLE(h-b1wgen0030)  THEN
                 DO:
                    BELL.
                    glb_dscritic = "Handle invalido para b1wgen0030.".
                    MESSAGE glb_dscritic.
                    NEXT.        
                 END.            

            RUN busca_tarifas_dsctit IN h-b1wgen0030
                                          (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT glb_dtmvtolt,
                                           INPUT 1,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-tarifas_dsctit).

            IF   RETURN-VALUE = "NOK" THEN
                 DO:
                    DELETE PROCEDURE h-b1wgen0030.
                       
                    FIND FIRST tt-erro NO-LOCK.
                      
                    IF   AVAILABLE tt-erro  THEN
                         DO:
                             BELL.
                             MESSAGE tt-erro.dscritic.
                             ASSIGN flg_erro = TRUE.
                             LEAVE.                         
                         END.
                 END.            
                 
            FIND FIRST tt-tarifas_dsctit NO-LOCK NO-ERROR.     
            
            BUFFER-COPY tt-tarifas_dsctit TO tt-log.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
               UPDATE tt-tarifas_dsctit.vltarctr  tt-tarifas_dsctit.vltarrnv  
                      tt-tarifas_dsctit.vltarbdt  tt-tarifas_dsctit.vlttitcr   
                      tt-tarifas_dsctit.vlttitsr  tt-tarifas_dsctit.vltrescr   
                      tt-tarifas_dsctit.vltressr
                      WITH FRAME f_tab053

               EDITING:

                 READKEY.
              
                 IF   FRAME-FIELD = "tt-tarifas_dsctit.vltarctr"  OR
                      FRAME-FIELD = "tt-tarifas_dsctit.vltarrnv"  OR
                      FRAME-FIELD = "tt-tarifas_dsctit.vltarbdc"  OR
                      FRAME-FIELD = "tt-tarifas_dsctit.vlttitcr"  OR
                      FRAME-FIELD = "tt-tarifas_dsctit.vlttitsr"  OR
                      FRAME-FIELD = "tt-tarifas_dsctit.vltrescr"  OR
                      FRAME-FIELD = "tt-tarifas_dsctit.vltressr"  THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.

               END.  /*  Fim do EDITING  */                
                
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    aux_confirma = "N".

                    glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    BELL.
                    glb_cdcritic = 0.
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

                LEAVE. 
                
            END.  /*  Fim do DO WHILE TRUE  */
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 DO:
                     DELETE PROCEDURE h-b1wgen0030.
                     NEXT.
                 END.    

            IF  NOT flg_erro  THEN
                DO:
                    RUN grava_tarifas_dsctit IN h-b1wgen0030
                                               (INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_dtmvtolt,
                                                INPUT 1,
                                                INPUT  TABLE tt-tarifas_dsctit,
                                                OUTPUT TABLE tt-erro).
                                 
                    IF   RETURN-VALUE = "NOK" THEN
                         DO:
                            DELETE PROCEDURE h-b1wgen0030.
                             
                            FIND FIRST tt-erro NO-LOCK.
                      
                            IF   AVAILABLE tt-erro  THEN
                                 DO:
                                     BELL.
                                     MESSAGE tt-erro.dscritic.
                                     ASSIGN flg_erro = TRUE.
                                     LEAVE.                         
                                 END.
                         END.         
                         
                    FIND FIRST tt-log NO-LOCK NO-ERROR.
                    
                    RUN proc_log (INPUT tt-log.vltarctr,
                                  INPUT tt-tarifas_dsctit.vltarctr,
                                  INPUT "Por contrato").
                                  
                    RUN proc_log (INPUT tt-log.vltarrnv,
                                  INPUT tt-tarifas_dsctit.vltarrnv,
                                  INPUT "Por renovacao").
                                                                        
                    RUN proc_log (INPUT tt-log.vltarbdt,
                                  INPUT tt-tarifas_dsctit.vltarbdt,
                                  INPUT "Por bordero"). 

                    RUN proc_log (INPUT tt-log.vlttitcr,
                                  INPUT tt-tarifas_dsctit.vlttitcr,
                                  "Por titulo Registrado").

                    RUN proc_log (INPUT tt-log.vlttitsr,
                                  INPUT tt-tarifas_dsctit.vlttitsr,
                                  "Por titulo S/ Registro").
                                  
                    RUN proc_log (INPUT tt-log.vltrescr,
                                  INPUT tt-tarifas_dsctit.vltrescr,
                                  INPUT "Por titulo resgatado Registrado").

                    RUN proc_log (INPUT tt-log.vltressr,
                                  INPUT tt-tarifas_dsctit.vltressr,
                                  INPUT "Por titulo resgatado S/ Registro").
                
                END.
                
            DELETE PROCEDURE h-b1wgen0030.    
            
            CLEAR FRAME f_tab053 NO-PAUSE.

        END.  /*  Fim da alteracao  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0030.p 
                PERSISTENT SET h-b1wgen0030.
        
            IF   NOT VALID-HANDLE(h-b1wgen0030)  THEN
                 DO:
                    BELL.
                    glb_dscritic = "Handle invalido para b1wgen0030.".
                    MESSAGE glb_dscritic.
                    NEXT.        
                 END.            

            RUN busca_tarifas_dsctit IN h-b1wgen0030
                                          (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT glb_dtmvtolt,
                                           INPUT 1,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-tarifas_dsctit).

            IF   RETURN-VALUE = "NOK" THEN
                 DO:
                    DELETE PROCEDURE h-b1wgen0030.
                       
                    FIND FIRST tt-erro NO-LOCK.
                      
                    IF   AVAILABLE tt-erro  THEN
                         DO:
                             BELL.
                             MESSAGE tt-erro.dscritic.
                             ASSIGN flg_erro = TRUE.
                             LEAVE.                         
                         END.
                 END.            
                 
            FIND FIRST tt-tarifas_dsctit NO-LOCK NO-ERROR.
            
            DISPLAY tt-tarifas_dsctit.vltarctr  tt-tarifas_dsctit.vltarrnv  
                    tt-tarifas_dsctit.vltarbdt  tt-tarifas_dsctit.vlttitcr   
                    tt-tarifas_dsctit.vlttitsr  tt-tarifas_dsctit.vltrescr   
                    tt-tarifas_dsctit.vltressr
                    WITH FRAME f_tab053.
                    
            DELETE PROCEDURE h-b1wgen0030.         
        END.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE proc_log:

    DEF INPUT PARAM par_vldantes AS DEC   NO-UNDO.
    DEF INPUT PARAM par_vldepois AS DEC   NO-UNDO.
    DEF INPUT PARAM par_dsdcampo AS CHAR  NO-UNDO.

    IF   par_vldantes = par_vldepois   THEN
         RETURN.

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                      " Operador " + glb_cdoperad + " alterou o campo "     +
                      par_dsdcampo + " de " + STRING(par_vldantes,"zz9.99") + 
                      " para "  + STRING(par_vldepois,"zz9.99")             + 
                      " >> log/tab053.log").

END PROCEDURE.


/* .......................................................................... */
