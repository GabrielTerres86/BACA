/* ............................................................................

   Programa: Fontes/impsac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Janeiro/2011                   Ultima Atualizacao: 05/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPSAC (importação de sacados)
                                                 
   Alteracoes: 29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
   
               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).   
               
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).                            
                           
               05/10/2016 - Remover a validacao de permissao por departamento
                            (Douglas - Chamado 534460)
.............................................................................*/ 

{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0083tt.i }

DEF   VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF   VAR tel_nrdconta LIKE crapass.nrdconta                         NO-UNDO.
DEF   VAR tel_nmarqimp AS CHAR  FORMAT "x(45)"                       NO-UNDO. 
DEF   VAR aux_nmarqimp AS CHAR  FORMAT "x(20)"                       NO-UNDO.
DEF   VAR aux_nmarqint AS CHAR  FORMAT "x(20)"                       NO-UNDO.
DEF   VAR aux_nmrescop AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmarqdat AS CHAR  FORMAT "x(20)"                       NO-UNDO.
DEF   VAR aux_timearqv AS CHAR                                       NO-UNDO.
                                                                   
DEF   VAR aux_confirma AS CHAR FORMAT "!"                            NO-UNDO.
                                                                   
DEF   VAR aux_dscritic AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscrdlog AS CHAR     FORMAT "x(50)"                    NO-UNDO.
DEF   VAR aux_logerror AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmendter AS CHAR                                       NO-UNDO.
DEF   VAR aux_flgdados AS LOGICAL                                    NO-UNDO. 
DEF   VAR aux_flgerror AS LOGICAL                                    NO-UNDO.

/*Variaveis Impressao*/
DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR par_flgrodar AS LOGICAL                                    NO-UNDO.
DEF   VAR par_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR par_flgcance AS LOGICAL                                    NO-UNDO. 

DEF   VAR aux_contador AS INTE                                       NO-UNDO.

DEF   VAR aux_recidobs AS RECID                                      NO-UNDO.
DEF   VAR aux_tipconsu AS LOGI FORMAT "Visualizar/Imprimir"          NO-UNDO.
                                                                  
DEF   VAR h-b1wgen0083 AS HANDLE                                     NO-UNDO.

DEF QUERY q-sacados FOR tt-sacados.

DEF BROWSE b-sacados QUERY q-sacados
    DISPLAY tt-sacados.nrcpfcgc  LABEL "CPF/CNPJ"            
            tt-sacados.nmdsacad  LABEL "Nome do Pagador" 
            tt-sacados.dssitsac  LABEL "Situacao"
            WITH 8 DOWN WIDTH 75 NO-LABELS OVERLAY.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (1) 
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (C)onsulta,(I)mportacao."
                  VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "I",
                            "014 - Opcao errada.") 
     WITH WIDTH 11 ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM SKIP (1)
     tel_nrdconta AT 13 LABEL "Conta" FORMAT "zzzz,zzz,9"
                  HELP "Entre com numero da conta."
     WITH ROW 5 COLUMN 13 SIDE-LABELS  NO-LABEL OVERLAY NO-BOX FRAME f_conta.

FORM "Arquivo:" AT 2
      aux_nmarqimp AT 11 NO-LABEL
      tel_nmarqimp AT 32 NO-LABEL 
                 HELP "Entre com o nome do arquivo."
     WITH ROW 10 COLUMN 2 WIDTH 78 SIDE-LABELS NO-LABEL 
     OVERLAY NO-BOX FRAME f_arqimp.

FORM b-sacados  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse.

DEF VAR edi_error  AS CHAR VIEW-AS EDITOR SIZE 132 BY 15 PFCOLOR 0.     

DEF FRAME f_error 
    edi_error HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "C"
       aux_flgdados = FALSE.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   RUN limpa_campos.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
       ASSIGN glb_cddopcao = "C".                  
       UPDATE glb_cddopcao WITH FRAME f_opcao.
       LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "IMPSAC"   THEN
                 DO:
                     HIDE BROWSE b-sacados.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao =  glb_cddopcao.
        END.

   RUN limpa_campos.

   UPDATE tel_nrdconta WITH FRAME f_conta.

   RUN sistema/generico/procedures/b1wgen0083.p 
                                  PERSISTENT SET h-b1wgen0083.

   RUN carrega_dados IN h-b1wgen0083 ( INPUT  glb_cdcooper,
                                       INPUT  0,            
                                       INPUT  0,           
                                       INPUT  tel_nrdconta,
                                       INPUT  1,
                                       INPUT  aux_nmendter,
                                      OUTPUT  aux_nmrescop,
                                      OUTPUT  aux_nmarqimp,
                                      OUTPUT  aux_logerror,
                                      OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0083.

   IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     
            IF  AVAILABLE tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN glb_dscritic = "Associado nao cadastrado.".

            BELL.
            MESSAGE glb_dscritic.

            RUN limpa_campos.
            
            NEXT.
        END.

   IF  glb_cddopcao = "C" THEN
       DO:
   
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               RUN sistema/generico/procedures/b1wgen0083.p 
                                                   PERSISTENT SET h-b1wgen0083.
              
               RUN busca-dados-sacado IN h-b1wgen0083 (INPUT glb_cdcooper,
                                                       INPUT tel_nrdconta,
                                                      OUTPUT TABLE tt-sacados).
               
               DELETE PROCEDURE h-b1wgen0083.

               OPEN QUERY q-sacados FOR EACH tt-sacados BY tt-sacados.nmdsacad.  

               IF NOT AVAILABLE tt-sacados THEN
                  DO:
                      MESSAGE "Nenhum pagador cadastrado p/ conta " + 
                                            STRING(tel_nrdconta) + ".".
                      PAUSE(2) NO-MESSAGE.
                      LEAVE.
                  END.
               ELSE
                  DO:
                      ENABLE b-sacados WITH FRAME f_browse.

                      WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
                  END.
               
           END. /*DO WHILE TRUE*/

           HIDE FRAME f_browse NO-PAUSE.
        END. /*glb_cddopcao = "C"*/
   ELSE
      DO: /*glb_cddopcao = "I"*/
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
             DISP aux_nmarqimp WITH FRAME f_arqimp.

             UPDATE tel_nmarqimp WITH FRAME f_arqimp.

             ASSIGN aux_nmarqint = aux_nmarqimp + tel_nmarqimp.

             RUN sistema/generico/procedures/b1wgen0083.p 
                                                   PERSISTENT SET h-b1wgen0083.
              
             RUN importa_arquivo IN h-b1wgen0083 ( INPUT  glb_cdcooper,
                                                   INPUT  0,           
                                                   INPUT  0,           
                                                   INPUT  1,           
                                                   INPUT  tel_nrdconta,
                                                   INPUT  glb_dtmvtolt,
                                                   INPUT  1,
                                                   INPUT tel_nmarqimp,
                                                   INPUT aux_nmarqint,
                                                   INPUT aux_nmrescop,
                                                   INPUT aux_nmendter,
                                                  OUTPUT aux_flgerror,
                                                  OUTPUT aux_flgdados,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-crapsab,
                                                  OUTPUT TABLE tt-logerro).
            
             DELETE PROCEDURE h-b1wgen0083.

             IF RETURN-VALUE = "NOK" THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN glb_dscritic = "Arquivo '" + tel_nmarqimp + 
                                                      "' nao encontrado!" .
                   
                    BELL.
                    MESSAGE glb_dscritic.

                    ASSIGN tel_nmarqimp = "".

                    NEXT.
                
                END.

             IF aux_flgerror  = TRUE THEN
                 DO:
                     ASSIGN aux_confirma = "N".

                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                         MESSAGE "Foram encontrados erros na importacao. " + 
                                 "Deseja continuar" +
                                 "(S/N):" 
                            UPDATE aux_confirma.

                         LEAVE.
                         
                      END.  /*  Fim do DO WHILE TRUE  */

                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/
                           aux_confirma <> "S"                THEN
                         DO: 
                            UNIX SILENT VALUE("rm " + aux_nmarqint + " 2> /dev/null").
                            
                            RUN mostra_errors. 

                            RUN imprime_errors.

                            UNIX SILENT VALUE ("rm " + aux_logerror + " 2> /dev/null").
                           
                            LEAVE.

                         END.
                      ELSE
                          DO:
                               RUN mostra_errors.
                                                             
                               RUN imprime_errors.
                          END.
                 END.

             RUN fontes/confirma.p                                             
                 (INPUT "Confirma importacao? (S/N)",OUTPUT aux_confirma).       
                                                                               
             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/ 
                 aux_confirma <> "S"                THEN                      
                 DO:                                                           
                    UNIX SILENT VALUE ("rm " + aux_logerror + " 2> /dev/null").
                    UNIX SILENT VALUE("rm " + aux_nmarqint + " 2> /dev/null").
                    EMPTY TEMP-TABLE tt-crapsab.                               
                    PAUSE(2) NO-MESSAGE.
                    LEAVE.
                 END.
             
             IF aux_flgdados = TRUE THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0083.p 
                                                  PERSISTENT SET h-b1wgen0083.
                     
                    RUN cria_sacados IN h-b1wgen0083 ( INPUT TABLE tt-crapsab,
                                                      OUTPUT aux_dscritic).
                    
                    DELETE PROCEDURE h-b1wgen0083.
               
                    IF RETURN-VALUE = "OK" THEN
                        DO:
                            BELL.                                    
                            MESSAGE aux_dscritic. 
                            PAUSE(3) NO-MESSAGE.                     
                        END.
                END.
                  
                
             aux_timearqv = STRING(TIME,"HH:MM:SS").
             
             aux_timearqv = REPLACE(aux_timearqv,":","").
             
             aux_nmarqdat = tel_nmarqimp + "-" + 
                            STRING(DAY(glb_dtmvtolt), "99") +
                            STRING(MONTH(glb_dtmvtolt), "99") +
                            STRING(YEAR(glb_dtmvtolt), "9999") +
                            aux_timearqv + ".txt".
                                                                            
             UNIX SILENT VALUE("mv " + aux_nmarqint + " salvar/" + aux_nmarqdat).


             ASSIGN aux_dscrdlog = "' --> Operador '" + glb_cdoperad +
                                   "' importou pagadores do arquivo '" +
                                   tel_nmarqimp + "' para a conta/dv '" +
                                   STRING(tel_nrdconta).

             RUN sistema/generico/procedures/b1wgen0083.p 
                                                   PERSISTENT SET h-b1wgen0083.
              
             RUN gera_log IN h-b1wgen0083 ( INPUT aux_nmrescop, 
                                            INPUT aux_dscrdlog, 
                                            INPUT glb_dtmvtolt,
                                            INPUT aux_nmendter,
                                           OUTPUT aux_logerror).

             IF aux_flgerror  = TRUE THEN
                 DO:                     
                    RUN gera_log_erros IN h-b1wgen0083 (INPUT aux_nmrescop,
                                                        INPUT glb_dtmvtolt,
                                                        INPUT TABLE tt-logerro).
                 END.

             DELETE PROCEDURE h-b1wgen0083.

             UNIX SILENT VALUE("rm " + aux_logerror + " 2> /dev/null").
             UNIX SILENT VALUE("rm " + aux_nmarqint + " 2> /dev/null").

             LEAVE.
                
         END. /*DO WHILE TRUE*/
     
      END. /*ELSE DO*/

END. /*DO WHILE TRUE*/

HIDE FRAME f_arqimp.

PROCEDURE limpa_campos.

    ASSIGN  tel_nrdconta = 0
            tel_nmarqimp = ""
            aux_flgerror = FALSE
            aux_flgdados = FALSE.

    EMPTY TEMP-TABLE tt-sacados.    
    HIDE BROWSE b-sacados.
    HIDE FRAME  f_error.
    HIDE FRAME  f_arqimp.
    HIDE FRAME  f_anota.
    HIDE FRAME  f_conta.
      
END PROCEDURE. /*limpa_campos*/

PROCEDURE mostra_errors.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ENABLE  edi_error WITH FRAME f_error.                     
        DISPLAY edi_error WITH FRAME f_error.        
        ASSIGN  edi_error:READ-ONLY IN FRAME f_error = YES. 
                                                                   
        IF   edi_error:INSERT-FILE(aux_logerror)   THEN            
             DO:                                                   
                 ASSIGN edi_error:CURSOR-LINE IN FRAME f_error = 1.
                 WAIT-FOR GO OF edi_error IN FRAME f_error.        
             END.

        LEAVE.
    END.

END PROCEDURE.  /*mostra_errors*/

PROCEDURE imprime_errors.

    ASSIGN aux_confirma = "N".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        MESSAGE "Imprimir lista de erros? (S/N):" 
            UPDATE aux_confirma.

        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE  */
    
    
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR   /*   F4 OU FIM   */
          aux_confirma <> "S"                THEN
          LEAVE.
     ELSE
          DO:
              FIND FIRST crapass WHERE 
                         crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
              
              IF   NOT AVAILABLE crapass THEN
                   NEXT.
              
                   ASSIGN aux_nmarqimp = aux_logerror
                          glb_nrdevias = 1
                          par_flgrodar = TRUE
                          glb_nmformul = "234dh".
                    
                   { includes/impressao.i }

                       NEXT.
          END.

END PROCEDURE. /*imprime_errors*/



  
