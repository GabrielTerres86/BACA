/* .............................................................................

   Programa: Fontes/proepr_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                         Ultima atualizacao: 15/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da impressao da proposta e/ou contrato
               de emprestimo.

   Alteracoes: 31/12/96 - Criada rotina proepr_m1.p para gerar o contrato
                          do emprestimo (Estourou 63K) (Edson).

               25/02/97 - Alteracao geral para tratar varios modelos de
                          contratos de emprestimo/financiamento (Edson).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               05/10/2010 - Modificar nome do arquivo de geracao da impressao
                            (Gabriel)
                            
               24/03/2011 - Alteração de fonte para se ajustar a chamada
                            da impressão na bo0002i. (André - DB1)   
                            
               07/06/2011 - Passada temp-table como parametro. (André - DB1)
               
               26/07/2011 - Alterada a form f_aguarde_1 para "Aguarde... 
                            Imprimindo contrato e nota promissoria!"
                            (Isara - KAM)
                            
               14/09/2011 - Nao imprimir rating na CECRED (Guilherme).
               
               21/01/2014 - Ajuste em mensagem adequada para aguardar. (Jorge)
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               27/08/2014 - Ajustes Referentes ao Projeto CET (Lucas R./Gielow)
               
               01/09/2014 - Projeto Automatização de Consultas em Propostas 
                            de Crédito.(Jonata-RKAM).
                            
               10/09/2014 - Projeto contratos, retirar opcoes de impressao
                            de contratos de emprestimos 
                            "COMPLETA", "CONTRATO" e "NOTA PROMISSORIA" 
                            (Tiago Castro - RKAM).
                            
               06/11/2014 - Ocultar apenas o botao de  PROPOSTA  mantendo 
                            as demais opcoes habilitadas e visiveis. (Jaison)
                            
               07/05/2015 - Consultas automatizadas para o limite 
                            de credito (Gabriel-RKAM).
               
               15/03/2016 - Alterado rotina para verificar se deve permitir 
                           o envio de email para o comite. PRJ207 - Esteira
                           PRJ207 - Esteira de Credito (Odirlei - AMcom)
                                         
............................................................................ */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_proepr_m.i "NEW" }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i } 
{ includes/gg0000.i }
{ sistema/generico/includes/var_oracle.i }


DEF INPUT PARAM par_recidepr AS INTE                                   NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-proposta-epr.
                  

FIND tt-proposta-epr WHERE 
     tt-proposta-epr.nrdrecid = par_recidepr NO-LOCK NO-ERROR.

IF  NOT AVAILABLE tt-proposta-epr   THEN
    DO:
        glb_cdcritic = 510.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        RETURN.
    END.

ASSIGN aux_idimpres = 0
       aux_flgentra = TRUE
       aux_flgemail = FALSE
       aux_nrpagina = 0.


/* Verificar deve permitir enviar email para o comite*/
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_verifica_email_comite aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,     /* pr_cdcooper */
    INPUT tel_nrdconta,     /* pr_nrdconta */
    INPUT tt-proposta-epr.nrctremp, /* pr_nrctremp */
    
    OUTPUT 0, /* pr_flgenvio */
    OUTPUT 0,  /* pr_cdcritic */
    OUTPUT ""   /* pr_dscritic */
    ).

CLOSE STORED-PROCEDURE pc_verifica_email_comite WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN aux_flemail_comite = 0
       glb_cdcritic       = 0
       glb_dscritic       = ""
       aux_flemail_comite = pc_verifica_email_comite.pr_flgenvio
                            WHEN pc_verifica_email_comite.pr_flgenvio <> ?
       glb_cdcritic       = pc_verifica_email_comite.pr_cdcritic
                            WHEN pc_verifica_email_comite.pr_cdcritic <> ?
       glb_dscritic       = pc_verifica_email_comite.pr_dscritic 
                            WHEN pc_verifica_email_comite.pr_dscritic <> ?.

IF glb_cdcritic > 0 OR 
   glb_dscritic <> "" THEN        
DO:
   /* se possuir codigo e nao ter descricao*/
   IF glb_cdcritic > 0 AND 
      glb_dscritic = "" THEN        
     RUN fontes/critic.p.
    
   BELL.
   MESSAGE glb_dscritic.
   glb_cdcritic = 0.
   RETURN.
   
END.

DO WHILE TRUE:

    ASSIGN aux_flggener = f_verconexaogener().

    IF  aux_flggener OR f_conectagener()  THEN  
        DO: 
             RUN sistema/generico/procedures/b1wgen0002i.p 
             PERSISTENT SET h-b1wgen0002i.

            IF  NOT VALID-HANDLE(h-b1wgen0002i)  THEN
                DO:
                    BELL.
                    MESSAGE "Handle invalido para BO b1wgen0002i.".
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                    RETURN.
                END.
            
            RUN valida_impressao IN h-b1wgen0002i ( INPUT glb_cdcooper,
                                                    INPUT glb_cdoperad,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT 1,
                                                    INPUT glb_nmdatela,
                                                    INPUT tel_nrdconta,
                                                    INPUT 1,
                                                    INPUT par_recidepr,
                                                    INPUT tt-proposta-epr.tplcremp,
                                                   OUTPUT TABLE tt-erro ). 

            DELETE PROCEDURE h-b1wgen0002i.
            IF  NOT aux_flggener  THEN
                RUN p_desconectagener.
        END.

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                IF  AVAILABLE tt-erro THEN
                    DO: 
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                    END.
    
                RETURN.
            END.

   /*  Pergunta o que deve imprimir quando ha proposta ou nota promissoria  */
   /* IF  (tt-proposta-epr.flgimppr  OR  
         tt-proposta-epr.flgimpnp) AND  aux_flgentra  THEN */
    IF  aux_flgentra  THEN
        DO:
            /* Imprimir Proposta */
            IF  tt-proposta-epr.flgimppr THEN
                DO:
                    DISPLAY tel_impricet 
                            tel_proposta 
                            tel_dsconsul 
                            tel_dsrating 
                            tel_dscancel
                            WITH FRAME f_imprime.
                END.
            ELSE
                DO:
                    DISPLAY tel_impricet 
                            tel_dsconsul 
                            tel_dsrating 
                            tel_dscancel
                            WITH FRAME f_imprime_2.
                END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                /* Imprimir Proposta */
                IF  tt-proposta-epr.flgimppr THEN
                    DO:
                        CHOOSE FIELD tel_impricet 
                                     tel_proposta 
                                     tel_dsrating 
                                     tel_dsconsul 
                                     tel_dscancel
                                     WITH FRAME f_imprime.
                    END.
                ELSE
                    DO:
                        CHOOSE FIELD tel_impricet 
                                     tel_dsrating 
                                     tel_dsconsul 
                                     tel_dscancel
                                     WITH FRAME f_imprime_2.
                    END.

                IF  FRAME-VALUE = tel_proposta  THEN
                    ASSIGN aux_idimpres = 3.
                ELSE
                IF  FRAME-VALUE = tel_dsconsul  THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen0191.p
                            PERSISTENT SET h-b1wgen0191.

                        RUN Imprime_Consulta IN h-b1wgen0191
                                            (INPUT glb_cdcooper,
                                             INPUT tel_nrdconta,
                                             INPUT 1, /* inprodut */
                                             INPUT tt-proposta-epr.nrctremp,
                                             INPUT 1,
                                             INPUT "I",
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf,
                                            OUTPUT TABLE tt-erro).    

                        DELETE PROCEDURE h-b1wgen0191.

                        IF   RETURN-VALUE <> "OK"   THEN
                             DO:
                                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                  IF   AVAIL tt-erro   THEN
                                       MESSAGE tt-erro.dscritic.
                                  ELSE
                                       MESSAGE
                                            "Erro na impressao das consultas.".

                                  PAUSE 3 NO-MESSAGE.
                                  HIDE MESSAGE.
                             END.

                        FIND crapass WHERE 
                             crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
        
                        glb_nmformul = "132col".

                        RUN impressao.

                    END.
                ELSE
                IF  FRAME-VALUE = tel_dsrating  THEN
                    DO:
                         IF  glb_cdcooper = 3  THEN
                         DO:
                             MESSAGE "Utilize a ATURAT para impressao " +
                                     "do Rating.".

                             IF  tt-proposta-epr.flgimppr THEN
                                 DO:
                                     HIDE FRAME f_imprime NO-PAUSE.
                                 END.
                             ELSE
                                 DO:
                                     HIDE FRAME f_imprime_2 NO-PAUSE.
                                 END.
                             
                             RETURN.
                         END.

                         RUN fontes/gera_rating.p 
                                         (INPUT glb_cdcooper,
                                          INPUT tel_nrdconta,
                                          INPUT 90, /* Emprestimo */
                                          INPUT tt-proposta-epr.nrctremp,
                                          INPUT FALSE). /* Nao grava*/
                         RETURN.
                    END.
                ELSE
                IF  FRAME-VALUE = tel_impricet  THEN /*** CET ***/
                    ASSIGN aux_idimpres = 6.
                ELSE
                IF  FRAME-VALUE = tel_dscancel  THEN
                    DO:
                        IF  tt-proposta-epr.flgimppr THEN
                            DO:
                                HIDE FRAME f_imprime NO-PAUSE.
                            END.
                        ELSE
                            DO:
                                HIDE FRAME f_imprime_2 NO-PAUSE.
                            END.

                        HIDE MESSAGE NO-PAUSE.
                        RETURN.
                    END.
               
                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

        END.

    IF  tt-proposta-epr.flgimppr THEN
        DO:
            HIDE FRAME f_imprime NO-PAUSE.
        END.
    ELSE
        DO:
            HIDE FRAME f_imprime_2 NO-PAUSE.
        END.
   
    IF  aux_idimpres <> 5  AND aux_idimpres <> 0  THEN 
        DO:
            IF  tt-proposta-epr.tplcremp <> 1  AND  
                glb_flgescra           AND 
                CAN-DO("1,2", STRING(aux_idimpres)) THEN
                DO:
                    DISPLAY tel_primeira  tel_segundap
                            tel_dscancel WITH FRAME f_pagina.
           
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                        CHOOSE FIELD tel_primeira tel_segundap
                                     tel_dscancel WITH FRAME f_pagina.
                
                        IF   FRAME-VALUE = tel_primeira   THEN
                             ASSIGN aux_nrpagina = 1
                                    aux_flgentra = FALSE.
                        ELSE
                        IF   FRAME-VALUE = tel_segundap   THEN
                             aux_nrpagina = 2.
                        ELSE
                        IF   FRAME-VALUE = tel_dscancel   THEN
                             DO:
                                 HIDE FRAME f_pagina NO-PAUSE.

                                 IF  tt-proposta-epr.flgimppr THEN
                                     DO:
                                         HIDE FRAME f_imprime NO-PAUSE.
                                     END.
                                 ELSE
                                     DO:
                                         HIDE FRAME f_imprime_2 NO-PAUSE.
                                     END.

                                 HIDE MESSAGE NO-PAUSE.
                                 RETURN.
                             END.
                       
                        LEAVE.
                
                    END.  /*  Fim do DO WHILE TRUE  */
           
                    HIDE FRAME f_pagina NO-PAUSE.
           
                END.

            IF  tt-proposta-epr.flgimppr THEN
                DO:
                    HIDE FRAME f_imprime NO-PAUSE.
                END.
            ELSE
                DO:
                    HIDE FRAME f_imprime_2 NO-PAUSE.
                END.

            HIDE MESSAGE NO-PAUSE.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                RETURN.

            ASSIGN aux_promsini = 1.

            IF  tt-proposta-epr.flgimpnp AND 
                CAN-DO("1,4", STRING(aux_idimpres))  THEN
                DO:

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   
                        UPDATE aux_promsini WITH FRAME f_promis_inicial.
                        HIDE FRAME f_promis_inicial.
                                                         
                        IF  aux_promsini = 0 OR
                            aux_promsini > tt-proposta-epr.qtpromis THEN
                            DO:
                                glb_cdcritic = 380.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT.
                            END.           
                                         
                        LEAVE.
                         
                    END.  /*  Fim do DO WHILE TRUE  */
        
                    HIDE FRAME f_promis_inicial NO-PAUSE.
        
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            ASSIGN aux_promsini = 1.
                            RETURN.
                        END.
                END.
                
            /* Verificar se permite enviar email para o comite */
            IF aux_flemail_comite = 1 THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                    UPDATE aux_flgemail WITH FRAME f_email.
                    LEAVE.
                
                END. /** Fim do DO WHILE TRUE **/
                
                HIDE FRAME f_email NO-PAUSE.
                
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        ASSIGN aux_flgemail = FALSE.
                        HIDE MESSAGE NO-PAUSE.
                        RETURN.
                    END.
           END.
        END.
    
    CASE aux_idimpres:
        WHEN 1 THEN DO:
            IF tt-proposta-epr.qtpromis > 0 AND 
               tt-proposta-epr.flgimpnp THEN
                VIEW FRAME f_aguarde_1.
            ELSE
                VIEW FRAME f_aguarde_2.
        END.
        WHEN 2 THEN VIEW FRAME f_aguarde_2.
        WHEN 3 THEN VIEW FRAME f_aguarde_3.
        WHEN 4 THEN VIEW FRAME f_aguarde_4.
        WHEN 6 THEN VIEW FRAME f_aguarde_cet.
        OTHERWISE RETURN.
    END CASE.

    INPUT THROUGH basename `tty` NO-ECHO.
    
    SET aux_nmendter WITH FRAME f_terminal.
    
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.
    
    UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
    
    ASSIGN aux_flggener = f_verconexaogener().

    IF  aux_flggener OR f_conectagener()  THEN  
        DO:
            RUN sistema/generico/procedures/b1wgen0002i.p 
                PERSISTENT SET h-b1wgen0002i.
           
            IF  NOT VALID-HANDLE(h-b1wgen0002i)  THEN
                DO:
                    BELL.
                    MESSAGE "Handle invalido para BO b1wgen0002i.".
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                    RETURN.
                END.

            RUN gera-impressao-empr IN h-b1wgen0002i (INPUT glb_cdcooper,  
                                                      INPUT 0,
                                                      INPUT 0,
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_nmdatela,
                                                      INPUT 1,
                                                      INPUT tel_nrdconta,
                                                      INPUT 1,
                                                      INPUT glb_dtmvtolt,
                                                      INPUT glb_dtmvtopr,
                                                      INPUT TRUE,
                                                      INPUT par_recidepr,
                                                      INPUT aux_idimpres,
                                                      INPUT glb_flgescra,
                                                      INPUT aux_nrpagina,
                                                      INPUT aux_flgemail,
                                                      INPUT aux_nmendter,
                                                      INPUT tel_dtcalcul,
                                                      INPUT glb_inproces,
                                                      INPUT aux_promsini,
                                                      INPUT glb_cdprogra,
                                                      INPUT aux_flgentra,
                                                     OUTPUT aux_flgentrv,
                                                     OUTPUT aux_nmarqimp,
                                                     OUTPUT aux_nmarqpdf,
                                                     OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0002i.

            IF  NOT aux_flggener  THEN
                RUN p_desconectagener.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO: 
                    HIDE FRAME f_aguarde_1   NO-PAUSE.
                    HIDE FRAME f_aguarde_2   NO-PAUSE.
                    HIDE FRAME f_aguarde_3   NO-PAUSE.
                    HIDE FRAME f_aguarde_4   NO-PAUSE.
                    HIDE FRAME f_aguarde_cet NO-PAUSE.
                    BELL.
                    MESSAGE tt-erro.dscritic VIEW-AS ALERT-BOX.
                    HIDE MESSAGE NO-PAUSE.
                END.

            HIDE FRAME f_aguarde_1   NO-PAUSE.
            HIDE FRAME f_aguarde_2   NO-PAUSE.
            HIDE FRAME f_aguarde_3   NO-PAUSE.
            HIDE FRAME f_aguarde_4   NO-PAUSE.
            HIDE FRAME f_aguarde_cet NO-PAUSE.

            RETURN.
        END.

    ASSIGN aux_flgentra = aux_flgentrv. 
    
    DO WHILE TRUE ON END-KEY UNDO, LEAVE:
        PAUSE 3 NO-MESSAGE.
        LEAVE.
    END.

    HIDE FRAME f_aguarde_1   NO-PAUSE.
    HIDE FRAME f_aguarde_2   NO-PAUSE.
    HIDE FRAME f_aguarde_3   NO-PAUSE.
    HIDE FRAME f_aguarde_4   NO-PAUSE.
    HIDE FRAME f_aguarde_cet NO-PAUSE.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
        
    glb_nmformul = "132col".
    
    RUN impressao.

    IF  NOT  glb_flgescra   THEN
        LEAVE.

END.  /*  Fim do DO   WHILE TRUE  */

PROCEDURE impressao:

    { includes/impressao.i }

END PROCEDURE.



