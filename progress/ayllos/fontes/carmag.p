/* ............................................................................

   Programa: Fontes/carmag.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/99.                         Ultima atualizacao: 22/07/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar o cartao magnetico dos associados.

   Alteracoes: 08/03/2002 - Mostrar na tela quando o cartao estiver vencido
                            (Junior).
                            
               12/03/2002 - Ocultar cartoes cancelados e vencidos ha mais de 
                            180 dias para usuarios e mostrar todos os cartoes 
                            para o super-usuario (Junior).

               21/08/2003 - Mostrar DISPONIVEL para os cartoes ja disponiveis
                            (Julio).
                            
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               11/09/2006 - Consertado para verificar tipo de cartao ao
                            carregar browse de Cartoes Magneticos (Diego). 
                            
               19/09/2006 - Alterado o nome da rotina e permitir o uso do
                            F2-AJUDA (Evandro).
               
               05/03/2008 - Tratamentos para pessoa juridica (Guilherme).
               
               09/06/2008 - Incluir parametro de entrada inpessoa pois a tela
                            OPERAD tambem chama este fonte (Guilherme).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
                            
               13/05/2009 - Utilizacao da BO b1wgen0032 - GATI - Eder
               
               21/12/2011 - Incluido botao Solicitar Letras na opcao Senha
                            (Diego).
                            
               04/01/2012 - Incluido a alteracao de senha quando for optado
                            por entregar o cartao (Adriano).  
                            
               07/11/2012 - Alteração nos param. da chamada da procedure
                            'grava-senha-letras' (Lucas).           
                            
               11/01/2013 - Requisitar cadastro de letras ao entregar
                            cartão magnético (Lucas).
               
               01/12/2014 - #223022 Verificada a situacao do cartao magnetico
                            (validar-entrega-cartao) para somente entrega-lo 
                            quando disponivel (Carlos)
                            
               22/07/2015 - Remover as opcoes Limite, Entrega e Recibo de Saque.
                            (James)
............................................................................. */

{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/gg0000.i }
{ includes/var_carmag.i "NEW" }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inpessoa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flgtecla AS LOGI                                  NO-UNDO.

ASSIGN tel_nrdconta = par_nrdconta.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.

RUN obtem-cartoes-magneticos IN h_b1wgen0032 
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,  
                                 INPUT glb_nmdatela,
                                 INPUT 1,
                                 INPUT par_nrdconta,
                                 INPUT 1,
                                 INPUT glb_dtmvtolt,
                                 INPUT par_flgtecla, 
                                OUTPUT aux_qtcarmag,
                                OUTPUT TABLE tt-cartoes-magneticos).

DELETE PROCEDURE h_b1wgen0032.

IF  RETURN-VALUE = "NOK"  THEN
    RETURN "NOK".
 
IF  par_flgtecla  THEN
    DO:
        IF  aux_iddopcao = 0  THEN
            IF  CAN-FIND(FIRST tt-cartoes-magneticos)  THEN
                aux_iddopcao = 3.      /*  Consulta  */
            ELSE
                aux_iddopcao = 6.      /*  Inclusao  */

        DISPLAY tab_dsdopcao WITH FRAME f_opcoes.
        
        /* Tela Atenda nao mostra o botao Entregar */
        IF glb_nmdatela = "ATENDA" THEN
           ASSIGN tab_dsdopcao[7]:HIDDEN = TRUE.
        
        CHOOSE FIELD tab_dsdopcao[aux_iddopcao] PAUSE 0 WITH FRAME f_opcoes.
        
        DO WHILE TRUE:
            
            IF  aux_flgreabr  THEN 
                DO:
                    RUN sistema/generico/procedures/b1wgen0032.p 
                        PERSISTENT SET h_b1wgen0032.
                    
                    RUN obtem-cartoes-magneticos IN h_b1wgen0032
                                       (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,  
                                        INPUT glb_nmdatela,
                                        INPUT 1,
                                        INPUT par_nrdconta,
                                        INPUT 1,
                                        INPUT glb_dtmvtolt,
                                        INPUT par_flgtecla,
                                       OUTPUT aux_qtcarmag,
                                       OUTPUT TABLE tt-cartoes-magneticos).
                    
                    DELETE PROCEDURE h_b1wgen0032.

                    OPEN QUERY q_cartoes FOR EACH tt-cartoes-magneticos NO-LOCK.
                    
                    IF  aux_nrdlinha > 0  THEN
                        REPOSITION q_cartoes TO ROW(aux_nrdlinha).

                    ASSIGN aux_flgreabr = FALSE.
                END.
                 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE b_cartoes WITH FRAME f_cartoes.
                LEAVE.
            
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                LEAVE.

            IF  NOT CAN-FIND(FIRST tt-cartoes-magneticos)  AND
                tab_cddopcao[aux_iddopcao] <> "S"          THEN
                NEXT.

            ASSIGN glb_cddopcao = tab_cddopcao[aux_iddopcao]
                   glb_nmrotina = "MAGNETICO".
                            
            { includes/acesso.i }
                     
            IF  AVAILABLE tt-cartoes-magneticos  THEN
                DO:
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
                                      INPUT tt-cartoes-magneticos.nrcartao,
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
                          
                    FIND tt-dados-carmag NO-ERROR.
                END.    
                               
            IF  aux_iddopcao = 1  THEN /* BLOQUEIO */
                DO:
                    IF  par_inpessoa = 1  THEN
                        DISP tt-dados-carmag.dsusucar 
                             tt-dados-carmag.nmtitcrd
                             tt-dados-carmag.nrcartao
                             tt-dados-carmag.nrseqcar                                                          
                             tt-dados-carmag.dtemscar
                             tt-dados-carmag.dscarcta
                             tt-dados-carmag.dtvalcar
                             tt-dados-carmag.dssitcar
                             tt-dados-carmag.dtentcrm
                             tt-dados-carmag.dtcancel 
                             tt-dados-carmag.dttransa
                             tt-dados-carmag.hrtransa
                             tt-dados-carmag.nmoperad
                             WITH FRAME f_cartao_magnetico.
                    ELSE
                        DISP tt-dados-carmag.nmtitcrd
                             tt-dados-carmag.nrcartao
                             tt-dados-carmag.nrseqcar                             
                             tt-dados-carmag.dtemscar
                             tt-dados-carmag.dscarcta
                             tt-dados-carmag.dtvalcar
                             tt-dados-carmag.dssitcar
                             tt-dados-carmag.dtentcrm
                             tt-dados-carmag.dtcancel 
                             tt-dados-carmag.dttransa
                             tt-dados-carmag.hrtransa
                             tt-dados-carmag.nmoperad
                             WITH FRAME f_cartao_magnetico2.
                                          
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        ASSIGN aux_confirma = "N"
                               glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        glb_cdcritic = 0.
                        
                        BELL.
                        MESSAGE COLOR NORMAL glb_dscritic 
                                UPDATE aux_confirma.
                        
                        LEAVE.
                   
                    END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        aux_confirma <> "S"                 THEN
                        DO:
                            ASSIGN glb_cdcritic = 79.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.

                            BELL.
                            MESSAGE glb_dscritic.

                            HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                            HIDE FRAME f_cartao_magnetico2 NO-PAUSE.

                            NEXT.
                        END.
                    
                    RUN sistema/generico/procedures/b1wgen0032.p
                        PERSISTENT SET h_b1wgen0032.
                   
                    RUN bloquear-cartao-magnetico IN h_b1wgen0032
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
             
                    IF  RETURN-VALUE = "OK" THEN
                        ASSIGN aux_flgreabr = YES.
                    ELSE
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                            IF  AVAIL tt-erro  THEN
                                DO: 
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                END.
                        END.

                    HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                END.
            ELSE
            IF  aux_iddopcao = 2  THEN /* CANCELAMENTO */ 
                DO:
                    IF  par_inpessoa = 1  THEN
                        DISP tt-dados-carmag.dsusucar 
                             tt-dados-carmag.nmtitcrd
                             tt-dados-carmag.nrcartao
                             tt-dados-carmag.nrseqcar
                             tt-dados-carmag.dtemscar
                             tt-dados-carmag.dscarcta
                             tt-dados-carmag.dtvalcar
                             tt-dados-carmag.dssitcar
                             tt-dados-carmag.dtentcrm
                             tt-dados-carmag.dtcancel 
                             tt-dados-carmag.dttransa
                             tt-dados-carmag.hrtransa
                             tt-dados-carmag.nmoperad
                             WITH FRAME f_cartao_magnetico.
                    ELSE
                        DISP tt-dados-carmag.nmtitcrd
                             tt-dados-carmag.nrcartao
                             tt-dados-carmag.nrseqcar                             
                             tt-dados-carmag.dtemscar
                             tt-dados-carmag.dscarcta
                             tt-dados-carmag.dtvalcar
                             tt-dados-carmag.dssitcar
                             tt-dados-carmag.dtentcrm
                             tt-dados-carmag.dtcancel 
                             tt-dados-carmag.dttransa
                             tt-dados-carmag.hrtransa
                             tt-dados-carmag.nmoperad
                             WITH FRAME f_cartao_magnetico2.
                          
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        ASSIGN aux_confirma = "N"
                               glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        glb_cdcritic = 0.
                        
                        BELL.
                        MESSAGE COLOR NORMAL glb_dscritic 
                                UPDATE aux_confirma.
                        
                        LEAVE.
                    
                    END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        aux_confirma <> "S"                 THEN
                        DO:
                            ASSIGN glb_cdcritic = 79.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.

                            BELL.
                            MESSAGE glb_dscritic.
                            
                            HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                            HIDE FRAME f_cartao_magnetico2 NO-PAUSE.

                            NEXT.
                        END.
                     
                    RUN sistema/generico/procedures/b1wgen0032.p 
                        PERSISTENT SET h_b1wgen0032.
                  
                    RUN cancelar-cartao-magnetico IN h_b1wgen0032
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

                    IF  RETURN-VALUE = "OK"  THEN
                        ASSIGN aux_flgreabr = YES.
                    ELSE    
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                            IF  AVAIL tt-erro  THEN
                                DO: 
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                END.
                        END.
                              
                    HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                END.
            ELSE
            IF  aux_iddopcao = 3  THEN /* CONSULTA */
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                        IF  par_inpessoa = 1  THEN
                            DISP tt-dados-carmag.dsusucar 
                                 tt-dados-carmag.nmtitcrd
                                 tt-dados-carmag.nrcartao
                                 tt-dados-carmag.nrseqcar                                 
                                 tt-dados-carmag.dtemscar
                                 tt-dados-carmag.dscarcta
                                 tt-dados-carmag.dtvalcar
                                 tt-dados-carmag.dssitcar
                                 tt-dados-carmag.dtentcrm
                                 tt-dados-carmag.dtcancel 
                                 tt-dados-carmag.dttransa
                                 tt-dados-carmag.hrtransa
                                 tt-dados-carmag.nmoperad
                                 WITH FRAME f_cartao_magnetico.
                        ELSE
                            DISP tt-dados-carmag.nmtitcrd
                                 tt-dados-carmag.nrcartao
                                 tt-dados-carmag.nrseqcar                                 
                                 tt-dados-carmag.dtemscar
                                 tt-dados-carmag.dscarcta
                                 tt-dados-carmag.dtvalcar
                                 tt-dados-carmag.dssitcar
                                 tt-dados-carmag.dtentcrm
                                 tt-dados-carmag.dtcancel 
                                 tt-dados-carmag.dttransa
                                 tt-dados-carmag.hrtransa
                                 tt-dados-carmag.nmoperad
                                 WITH FRAME f_cartao_magnetico2.
                              
                        PAUSE MESSAGE "Tecle algo para retornar...".
                    
                        LEAVE.
                    
                    END. /* Fim do DO WHILE TRUE */
                    
                    HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                END.    
            ELSE            
            IF  aux_iddopcao = 4  THEN /* IMPRESSAO */
                DO:
                    RUN sistema/generico/procedures/b1wgen0032.p
                        PERSISTENT SET h_b1wgen0032.      
                    
                    RUN consiste-cartao IN h_b1wgen0032
                                        (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1,
                                         INPUT tel_nrdconta,
                                         INPUT 1,
                                         INPUT tt-dados-carmag.nrcartao,
                                         INPUT FALSE,
                                        OUTPUT TABLE tt-erro).
                    
                    DELETE PROCEDURE h_b1wgen0032.
                       
                    IF  RETURN-VALUE = "NOK" THEN 
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                              
                            IF  AVAILABLE tt-erro  THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                    BELL.
                                END.
                              
                              NEXT.
                        END.
                          
                    IF  par_inpessoa = 1  THEN
                        RUN fontes/carmag_m.p (INPUT par_nrdconta,
                                               INPUT tt-dados-carmag.nrcartao).
                    ELSE 
                        RUN fontes/carmag_j.p (INPUT par_nrdconta).
                END.
            ELSE
            IF  aux_iddopcao = 5  THEN /* SENHA */
                DO:
                    IF  par_inpessoa = 1  THEN
                        DISP tt-dados-carmag.dsusucar 
                             tt-dados-carmag.nmtitcrd
                             tt-dados-carmag.nrcartao
                             tt-dados-carmag.nrseqcar                             
                             tt-dados-carmag.dtemscar
                             tt-dados-carmag.dscarcta
                             tt-dados-carmag.dtvalcar
                             tt-dados-carmag.dssitcar
                             tt-dados-carmag.dtentcrm
                             tt-dados-carmag.dtcancel 
                             tt-dados-carmag.dttransa
                             tt-dados-carmag.hrtransa
                             tt-dados-carmag.nmoperad
                             WITH FRAME f_cartao_magnetico.
                    ELSE
                        DISP tt-dados-carmag.nmtitcrd
                             tt-dados-carmag.nrcartao
                             tt-dados-carmag.nrseqcar                             
                             tt-dados-carmag.dtemscar
                             tt-dados-carmag.dscarcta
                             tt-dados-carmag.dtvalcar
                             tt-dados-carmag.dssitcar
                             tt-dados-carmag.dtentcrm
                             tt-dados-carmag.dtcancel 
                             tt-dados-carmag.dttransa
                             tt-dados-carmag.hrtransa
                             tt-dados-carmag.nmoperad
                             WITH FRAME f_cartao_magnetico2.

                    RUN sistema/generico/procedures/b1wgen0032.p
                        PERSISTENT SET h_b1wgen0032.

                    RUN verifica-senha-atual IN h_b1wgen0032
                                            (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,   
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT par_nrdconta,
                                             INPUT tt-cartoes-magneticos.tpusucar,
                                             INPUT tt-dados-carmag.nrcartao,
                                             INPUT 1, /* Altera senha */
                                            OUTPUT aux_flgsenha, 
                                            OUTPUT aux_flgletca,
                                            OUTPUT TABLE tt-erro).
             
                    DELETE PROCEDURE h_b1wgen0032.
             
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                END.

                            HIDE FRAME f_opcao_senha       NO-PAUSE.
                            HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                            HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                            
                            NEXT.
                        END.

                    PAUSE(0).
                     
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                        DISPLAY tel_sennumer tel_solletra 
                                WITH FRAME f_opcao_senha.

                        CHOOSE FIELD tel_sennumer tel_solletra 
                                     WITH FRAME f_opcao_senha.

                        IF  FRAME-VALUE = tel_sennumer  THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                   IF  aux_flgsenha = FALSE  THEN
                                       UPDATE tel_nrsennov tel_nrsencon
                                              WITH FRAME f_senha.
                                   ELSE
                                       UPDATE tel_nrsenatu tel_nrsennov
                                              tel_nrsencon
                                              WITH FRAME f_senha.
                               
                                   ASSIGN aux_confirma = "N"
                                         glb_cdcritic = 78.

                                   RUN fontes/critic.p.
                                   glb_cdcritic = 0.
                               
                                   BELL.
                                   MESSAGE COLOR NORMAL glb_dscritic 
                                           UPDATE aux_confirma.
                               
                                   IF  aux_confirma <> "S"  THEN 
                                       LEAVE.
                                   
                                   RUN sistema/generico/procedures/b1wgen0032.p
                                       PERSISTENT SET h_b1wgen0032. 
                                   
                                   RUN alterar-senha-cartao-magnetico 
                                       IN h_b1wgen0032
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
                                             INPUT tel_nrsenatu,
                                             INPUT tel_nrsennov,
                                             INPUT tel_nrsencon,
                                             INPUT YES,
                                            OUTPUT TABLE tt-erro).
                                   
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
                                   
                                   LEAVE.
                               
                                END.
                            END.
                        ELSE
                        IF  FRAME-VALUE = tel_solletra  THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                   UPDATE tel_dssennov tel_dssencon
                                          WITH FRAME f_senha_let.

                                   ASSIGN aux_confirma = "N"
                                         glb_cdcritic = 78.
                                   RUN fontes/critic.p.
                                   glb_cdcritic = 0.

                                   BELL.
                                   MESSAGE COLOR NORMAL glb_dscritic 
                                           UPDATE aux_confirma.

                                   IF  aux_confirma <> "S"  THEN 
                                       LEAVE.

                                   RUN sistema/generico/procedures/b1wgen0032.p
                                       PERSISTENT SET h_b1wgen0032. 

                                   RUN grava-senha-letras 
                                       IN h_b1wgen0032
                                       (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT 1,
                                        INPUT tel_nrdconta,
                                        INPUT tt-cartoes-magneticos.tpusucar,
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_dssennov,
                                        INPUT tel_dssencon,
                                        INPUT TRUE,
                                       OUTPUT aux_flgcadas,
                                       OUTPUT TABLE tt-erro).

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

                                   MESSAGE "Operacao efetuada com sucesso!".

                                   PAUSE 5 NO-MESSAGE.

                                   LEAVE.

                                END.
                            END.

                        ASSIGN aux_flgreabr = YES.

                        LEAVE.

                    END. /* Fim do DO WHILE TRUE */

                    IF  (KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        aux_confirma <> "S")                 THEN
                        DO:
                                glb_cdcritic = 79.
                                RUN fontes/critic.p.
                                glb_cdcritic = 0.
                            
                            BELL.
                            MESSAGE glb_dscritic.
                        END.

                    HIDE FRAME f_senha             NO-PAUSE.
                    HIDE FRAME f_opcao_senha       NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                END.
            ELSE
            IF  aux_iddopcao = 6  THEN /* SOLICITACAO */
                DO: 
                    IF  AVAILABLE tt-cartoes-magneticos  THEN
                        RUN fontes/carmag_s.p (INPUT par_nrdconta, 
                                               INPUT tt-dados-carmag.nrcartao,
                                               INPUT tt-dados-carmag.inpessoa).
                    ELSE
                        RUN fontes/carmag_s.p (INPUT par_nrdconta, 
                                               INPUT 0,
                                               INPUT 0).
                                
                    HIDE MESSAGE NO-PAUSE.
                    
                    IF  RETURN-VALUE = "OK"  THEN
                        ASSIGN aux_flgreabr = YES.
                END.                
            ELSE   
            IF  aux_iddopcao = 7  THEN /* ENTREGA */ 
                DO: 
                    RUN sistema/generico/procedures/b1wgen0032.p 
                                    PERSISTENT SET h_b1wgen0032.  
                    
                    RUN consiste-cartao IN h_b1wgen0032
                                            (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT tel_nrdconta,
                                             INPUT 1,
                                             INPUT tt-dados-carmag.nrcartao,
                                             INPUT TRUE,
                                            OUTPUT TABLE tt-erro).
                    
                    DELETE PROCEDURE h_b1wgen0032.
                       
                    IF RETURN-VALUE = "NOK"  THEN 
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                             
                           IF  AVAILABLE tt-erro  THEN
                               DO:
                                  MESSAGE tt-erro.dscritic.
                                  BELL.
                               END.
                             
                           NEXT.
                       END.

                    /* Valida a situacao do cartao antes de efetivar a entrega */
                    RUN sistema/generico/procedures/b1wgen0032.p 
                                    PERSISTENT SET h_b1wgen0032.  
                    RUN validar-entrega-cartao IN h_b1wgen0032
                                               (INPUT glb_cdcooper,
                                                INPUT tel_nrdconta,
                                                tt-dados-carmag.nrcartao,
                                                OUTPUT TABLE tt-erro).
                    
                    DELETE PROCEDURE h_b1wgen0032.
                    IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                             
                        IF  AVAILABLE tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            BELL.
                        END.
                        NEXT.
                    END.
                    /* fim valida situacao cartao */

                    DISP tt-dados-carmag.dsusucar 
                         tt-dados-carmag.nmtitcrd
                         tt-dados-carmag.nrcartao
                         tt-dados-carmag.nrseqcar                            
                         tt-dados-carmag.dtemscar
                         tt-dados-carmag.dscarcta
                         tt-dados-carmag.dtvalcar
                         tt-dados-carmag.dssitcar
                         tt-dados-carmag.dtentcrm
                         tt-dados-carmag.dtcancel 
                         tt-dados-carmag.dttransa
                         tt-dados-carmag.hrtransa
                         tt-dados-carmag.nmoperad
                         WITH FRAME f_cartao_magnetico.
                    
                    PAUSE(0).

                    RUN sistema/generico/procedures/b1wgen0032.p
                                    PERSISTENT SET h_b1wgen0032.

                    RUN verifica-senha-atual IN h_b1wgen0032
                                            (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,   
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT par_nrdconta,
                                             INPUT tt-cartoes-magneticos.tpusucar,
                                             INPUT tt-dados-carmag.nrcartao,
                                             INPUT 2, /* Entrega cartao */
                                             OUTPUT aux_flgsenha,
                                             OUTPUT aux_flgletca,
                                             OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h_b1wgen0032.
        
                    IF RETURN-VALUE = "NOK"  THEN
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                           IF AVAIL tt-erro  THEN
                              DO:
                                  BELL.
                                  MESSAGE tt-erro.dscritic.

                              END.
                       
                           HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                           HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                           
                           NEXT.

                       END.

                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                          IF  aux_flgsenha = FALSE  THEN
                              UPDATE tel_nrsennov 
                                     tel_nrsencon
                                     WITH FRAME f_senha.
                          ELSE
                              UPDATE tel_nrsenatu 
                                     tel_nrsennov
                                     tel_nrsencon
                                     WITH FRAME f_senha.
                              
                          ASSIGN aux_confirma = "N"
                                 glb_cdcritic = 78.
                          
                          RUN fontes/critic.p.
                          
                          glb_cdcritic = 0.
                       
                          BELL. 

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                             MESSAGE COLOR NORMAL glb_dscritic
                                     UPDATE aux_confirma.       

                             LEAVE.
                       
                          END.

                          IF aux_confirma <> "S"  THEN 
                             LEAVE.

                          HIDE FRAME f_senha              NO-PAUSE.
                          HIDE FRAME f_opcao_senha2       NO-PAUSE.
               
                          
                          RUN sistema/generico/procedures/b1wgen0032.p
                                          PERSISTENT SET h_b1wgen0032. 
                          
                          RUN entregar-cartao-magnetico IN h_b1wgen0032
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
                                        INPUT tel_nrsenatu,
                                        INPUT tel_nrsennov,
                                        INPUT tel_nrsencon,
                                        INPUT YES,
                                        OUTPUT TABLE tt-erro).
                          
                          DELETE PROCEDURE h_b1wgen0032.
                                      
                          IF RETURN-VALUE = "NOK"  THEN
                             DO:
                                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                 
                                 IF AVAIL tt-erro  THEN
                                    DO: 
                                        BELL.
                                        MESSAGE tt-erro.dscritic.
                          
                                    END.
                                 
                                 HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                                 HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
                          
                                 LEAVE.                        
                          
                             END.

                          ASSIGN aux_flgreabr = TRUE
                                 aux_flcarmag = TRUE.
                           
                          RUN fontes/carmag_m.p (INPUT par_nrdconta,
                                                 INPUT tt-dados-carmag.nrcartao).
                          
                          HIDE MESSAGE NO-PAUSE.

                          IF  NOT aux_flgletca THEN
                              DO:
                                 MESSAGE "Necessario cadastramento das Letras" +
                                            " de Seguranca.".

                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 
                                    ASSIGN tel_dssennov = ""
                                           tel_dssencon = "".
                                    
                                    UPDATE tel_dssennov tel_dssencon
                                           WITH FRAME f_senha_let.
                                    
                                    ASSIGN aux_confirma = "N"
                                           glb_cdcritic = 78.
                                    
                                    RUN fontes/critic.p.
                                        glb_cdcritic = 0.
                                    
                                    BELL.
                                    MESSAGE COLOR NORMAL glb_dscritic 
                                            UPDATE aux_confirma.
                                    
                                    IF  aux_confirma <> "S"  THEN 
                                        LEAVE.
                                    
                                    RUN sistema/generico/procedures/b1wgen0032.p
                                        PERSISTENT SET h_b1wgen0032. 
                                    
                                    RUN grava-senha-letras 
                                        IN h_b1wgen0032
                                        (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1,
                                         INPUT tel_nrdconta,
                                         INPUT tt-cartoes-magneticos.tpusucar,
                                         INPUT glb_dtmvtolt,
                                         INPUT tel_dssennov,
                                         INPUT tel_dssencon,
                                         INPUT TRUE,
                                        OUTPUT aux_flgcadas,
                                        OUTPUT TABLE tt-erro).
                                    
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
                                    
                                    MESSAGE "Operacao efetuada com sucesso!".
                                    
                                    PAUSE 5 NO-MESSAGE.

                                    LEAVE.

                                 END.
                             END.
                          
                          LEAVE.
                       
                       END.

                    IF (KEYFUNCTION(LASTKEY) = "END-ERROR"    OR
                        aux_confirma <> "S"                 ) AND
                        aux_flcarmag = FALSE                  THEN
                       DO:
                           ASSIGN glb_cdcritic = 79.
                           RUN fontes/critic.p.
                           ASSIGN glb_cdcritic = 0.

                           BELL.
                           MESSAGE glb_dscritic.
                            
                           HIDE FRAME f_senha             NO-PAUSE.
                           HIDE FRAME f_opcao_senha2      NO-PAUSE.
                           HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                           HIDE FRAME f_cartao_magnetico2 NO-PAUSE.

                           NEXT.

                       END.
                     
                    HIDE FRAME f_senha             NO-PAUSE.
                    HIDE FRAME f_opcao_senha2      NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico  NO-PAUSE.
                    HIDE FRAME f_cartao_magnetico2 NO-PAUSE.

                END.            

        END. /* Fim do DO WHILE TRUE */
        
        HIDE FRAME f_opcoes            NO-PAUSE.
        HIDE FRAME f_cartao_magnetico  NO-PAUSE.
        HIDE FRAME f_cartao_magnetico2 NO-PAUSE.
        HIDE FRAME f_cartoes           NO-PAUSE.
        HIDE FRAME f_senha             NO-PAUSE.

    END.

IF  VALID-HANDLE(h_b1wgen0032)  THEN
    DELETE PROCEDURE h_b1wgen0032.

RETURN "OK".

/* .......................................................................... */
