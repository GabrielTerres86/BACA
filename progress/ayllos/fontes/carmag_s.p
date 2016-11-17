/* ............................................................................

   Programa: Fontes/carmag_s.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/99.                         Ultima atualizacao: 23/07/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar a solicitacao do cartao magnetico de C/C.

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               19/09/2006 - Alterado o nome da rotina (Evandro).

               05/03/2008 - Tratamentos para pessoa juridica (Guilherme).
               
               19/05/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder
                            
               23/07/2015 - Remover os campos Limite, Forma de Saque e Recido
                            de entrega. (James)
.............................................................................*/

{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_carmag.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcartao AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_inpessoa AS INTE                                  NO-UNDO.

DEF VAR aux_dsdopcao AS CHAR EXTENT 3 
                     INIT ["Alteracao","Exclusao","Inclusao"]          NO-UNDO.

DEF VAR aux_flgalter AS LOGI INIT FALSE                                NO-UNDO.

FORM SPACE(25)
     aux_dsdopcao[1] FORMAT "x(9)"
     aux_dsdopcao[2] FORMAT "x(8)"
     aux_dsdopcao[3] FORMAT "x(8)"
     SPACE(26)
     SKIP
     SPACE(35) "  " SPACE(35)
     WITH ROW 19 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes_solicitacao.
     
DISPLAY aux_dsdopcao WITH FRAME f_opcoes_solicitacao.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  glb_cdcritic > 0  THEN
        DO:
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            MESSAGE glb_dscritic.
            BELL.
        END.

    IF par_inpessoa = 1 THEN
       DO:  
           CHOOSE FIELD aux_dsdopcao[1]
                        aux_dsdopcao[2]
                        aux_dsdopcao[3]
                        WITH FRAME f_opcoes_solicitacao.
       END.                 
    ELSE
       DO:
           ASSIGN aux_dsdopcao[1]:HIDDEN = TRUE.
           
           CHOOSE FIELD aux_dsdopcao[2]
                        aux_dsdopcao[3]
                        WITH FRAME f_opcoes_solicitacao.                        
           
       END.                 
       
    HIDE MESSAGE NO-PAUSE.
    
    IF  FRAME-VALUE = aux_dsdopcao[1]  THEN /* ALTERACAO */
        DO:
            IF  par_nrcartao = 0  THEN
                NEXT.
        
            ASSIGN glb_cddopcao = "A"
                   glb_nmrotina = "MAGNETICO".

            { includes/acesso.i }
    
            RUN fontes/carmag_a.p (INPUT par_nrdconta, 
                                   INPUT par_nrcartao).
            
            IF  RETURN-VALUE = "OK"  THEN
                ASSIGN aux_flgalter = YES.
            ELSE
                NEXT.
        END.
    ELSE
    IF  FRAME-VALUE = aux_dsdopcao[2]  THEN /* EXCLUSAO */
        DO:
            IF  par_nrcartao = 0  THEN
                NEXT.
        
            ASSIGN glb_cddopcao = "E"
                   glb_nmrotina = "MAGNETICO".

            { includes/acesso.i }
            
            RUN sistema/generico/procedures/b1wgen0032.p 
                PERSISTENT SET h_b1wgen0032.
     
            RUN consulta-cartao-magnetico IN h_b1wgen0032
                                     (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,   
                                      INPUT glb_nmdatela,
                                      INPUT 1,
                                      INPUT par_nrdconta,
                                      INPUT 1,
                                      INPUT glb_dtmvtolt,
                                      INPUT par_nrcartao,
                                      INPUT YES,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados-carmag).
            
            DELETE PROCEDURE h_b1wgen0032.
                       
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.
                
                    NEXT.
                END.
             
            FIND FIRST tt-dados-carmag NO-ERROR.
            
            IF  NOT AVAIL tt-dados-carmag  THEN 
                NEXT.
                
            IF  tt-dados-carmag.inpessoa = 1  THEN
                DISP tt-dados-carmag.dsusucar   tt-dados-carmag.nmtitcrd
                     tt-dados-carmag.nrcartao   tt-dados-carmag.nrseqcar                    
                     tt-dados-carmag.dtemscar   tt-dados-carmag.dscarcta   
                     tt-dados-carmag.dtvalcar   tt-dados-carmag.dssitcar   
                     tt-dados-carmag.dtentcrm   tt-dados-carmag.dtcancel   
                     tt-dados-carmag.dttransa   tt-dados-carmag.hrtransa   
                     tt-dados-carmag.nmoperad
                     WITH FRAME f_cartao_magnetico.
            ELSE
                DISP tt-dados-carmag.nmtitcrd
                     tt-dados-carmag.nrcartao   tt-dados-carmag.nrseqcar
                     tt-dados-carmag.dtemscar   tt-dados-carmag.dscarcta   
                     tt-dados-carmag.dtvalcar   tt-dados-carmag.dssitcar   
                     tt-dados-carmag.dtentcrm   tt-dados-carmag.dtcancel   
                     tt-dados-carmag.dttransa   tt-dados-carmag.hrtransa   
                     tt-dados-carmag.nmoperad
                     WITH FRAME f_cartao_magnetico2.
                     
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                glb_cdcritic = 0.

                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                
                LEAVE.
                
            END.
                       
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                aux_confirma <> "S"                 THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.
                    
                    BELL.
                    MESSAGE glb_dscritic.
                    
                    HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                    
                    NEXT.
                END.

            RUN sistema/generico/procedures/b1wgen0032.p 
                PERSISTENT SET h_b1wgen0032.
            
            RUN excluir-cartao-magnetico IN h_b1wgen0032
                                           (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,   
                                            INPUT glb_nmdatela,
                                            INPUT 1,
                                            INPUT par_nrdconta,
                                            INPUT 1,
                                            INPUT glb_dtmvtolt,
                                            INPUT tt-dados-carmag.nrcartao,
                                            INPUT YES,
                                           OUTPUT TABLE tt-erro).
            
            DELETE PROCEDURE h_b1wgen0032.
                                         
            HIDE FRAME f_cartao_magnetico  NO-PAUSE.
            HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
            
            IF  RETURN-VALUE = "OK"  THEN
                ASSIGN aux_flgalter = YES.
            ELSE
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.
                
                    NEXT.
                END.
        END.
    ELSE
    IF  FRAME-VALUE = aux_dsdopcao[3]  THEN /* INCLUSAO */
        DO:
            ASSIGN glb_cddopcao = "I"
                   glb_nmrotina = "MAGNETICO".

            { includes/acesso.i }
            
            RUN fontes/carmag_i.p (INPUT par_nrdconta, 
                                   INPUT IF  glb_nmdatela = "ATENDA"  THEN 
                                             1
                                         ELSE 
                                             9).
                                            
            IF  RETURN-VALUE = "OK"  THEN
                ASSIGN aux_flgalter = YES.
            ELSE
                NEXT.
        END.
                       
    LEAVE.
         
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_opcoes NO-PAUSE.

IF  aux_flgalter = YES  THEN
    RETURN "OK".
ELSE
    RETURN "NOK".

/* ......................................................................... */
