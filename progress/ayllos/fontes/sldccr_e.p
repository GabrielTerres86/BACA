/* ............................................................................

   Programa: Fontes/sldccr_e.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                      Ultima atualizacao: 14/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para entregar cartoes de credito.

   Alteracoes: 08/12/97 - Alterar para ler a tabela de valores de anuidade com
                          data da proposta <= data da tabela (Odair)

               05/05/98 - Troca de tabela de anuidade (Deborah).

               25/08/98 - Criar novos campos (tpcartao e cdadmcrd) no crapcrd
                          (Deborah).

               31/08/98 - Tratar tipo de cartoes (Odair)

             19/07/2002 - Sempre imprimir promissoria no contrato (Margarete).
             
             31/07/2002 - Incluir nova situacao da conta (Margarete).
             
             09/12/2002 - Consistir numero do cartao na liberacao (Junior).

             11/06/2004 - Mensagem de alerta para digitacao do numero de 
                          cartao (Julio)
                          
             29/07/2004 - Removida Mensagem de alerta para digitacao do numero
                          do cartao e Incluida a rotina para confirmacao do
                          numero do cartao (Evandro).

             05/07/2005 - Alimentado campo cdcooper da tabela crapcrd (Diego). 
             
             18/01/2006 - Tratamento para desfazer entrega de 2.a via de cartao
                          (Julio)

             27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

             19/04/2006 - NUMICARTAO pode ter mais de um numero inicial (Julio)
             
             19/06/2006 - Bloqueada opcao de entrega para Cartao BB (Diego).
             
             19/12/2008 - Informar apenas mes e ano na validade(Guilherme).
             
             10/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                          (GATI - Eder)
                          
             20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                          (Gati - Daniel).
                          
             03/01/2011 - Alterado para solicitar numero completo do cartao
                          novamente na entrega (Diego).
                          
             05/09/2011 - Incluido a chamada da procedure alerta_fraude
                          (Adriano).
                          
             01/04/2013 - Retirado a chamada da procedure alerta_fraude
                          (Adriano). 
                          
              29/05/2014 - Bloqueio da opcao desfazer entrega p/ cartoes
                           BANCOOB (Jean Michel).
                           
              14/10/2015 - Desenvolvimento do projeto 126. (James)
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF VAR tel_dsentreg  AS CHAR INIT "Entregar"                          NO-UNDO.
DEF VAR tel_dsdesfaz  AS CHAR INIT "Desfazer" FORMAT "x(08)"           NO-UNDO.

DEF VAR aux_nrcrcard2 AS DECI FORMAT "9999,9999,9999,9999"             NO-UNDO.
DEF VAR aux_nrcrcard  AS DECI FORMAT "9999,9999,9999,9999"             NO-UNDO.
DEF VAR aux_vlanuida  AS DECI                                          NO-UNDO.

DEF VAR aux_dtvalida  AS CHAR FORMAT "xx/xxxx"                         NO-UNDO.
DEF VAR aux_confirma  AS CHAR FORMAT "!"                               NO-UNDO.
DEF VAR aux_cdprgctr  AS CHAR                                          NO-UNDO.
DEF VAR aux_dstextab  AS CHAR                                          NO-UNDO.

DEF VAR aux_dttabela  AS DATE                                          NO-UNDO.
DEF VAR aux_dtcalcu2  AS DATE FORMAT "99/99/9999"                      NO-UNDO.
DEF VAR aux_ultdiame  AS DATE FORMAT "99/99/9999"                      NO-UNDO.

DEF VAR aux_dtexiste  AS LOGI                                          NO-UNDO.

DEF VAR aux_inpessoa LIKE tt-dados_cartao.inpessoa                     NO-UNDO.

DEF VAR aux_qtparcan  AS INTE                                          NO-UNDO.

DEF VAR h_b1wgen0028  AS HANDLE                                        NO-UNDO.

DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.


FORM SKIP(1)
     tel_dsentreg AT  5
     tel_dsdesfaz AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 40
     NO-LABELS TITLE COLOR NORMAL " Entrega " FRAME f_entrega.

FORM SKIP(1)
     aux_nrcrcard  LABEL "Cartao de Credito" 
     HELP "Entre com o numero do novo cartao"  AT 5 "     "
     SKIP(1)
     aux_dtvalida  LABEL "Data de Validade"  AT 6
     SKIP(1)
     WITH SIDE-LABELS ROW 12
     OVERLAY CENTERED TITLE COLOR NORMAL " Entrega " FRAME f_cartao.

FORM SKIP(1)
     tel_repsolic FORMAT "x(40)" LABEL "Representante Solicitante" 
     HELP "Utilizar setas direita/esquerda para escolher Representante" 
     SKIP (1)   
     "Cartao de Credito:" AT 9
     aux_nrcrcard 
     HELP "Entre com o numero do novo cartao" 
     SKIP(1)
     aux_dtvalida  LABEL "Data de Validade"  AT 10
     WITH SIDE-LABELS NO-LABEL ROW 10
     OVERLAY CENTERED TITLE COLOR NORMAL " Entrega " FRAME f_cartao_pj.
     
FORM SKIP(2)
     aux_nrcrcard2  LABEL "Cartao de Credito" AT 5
     HELP "Confirme o numero do cartao"     "     "
     SKIP(2)
     WITH SIDE-LABELS ROW 12 OVERLAY CENTERED
     TITLE COLOR NORMAL " Confirme o numero do cartao " FRAME f_confirma_cartao.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
                 
RUN carrega_representante IN h_b1wgen0028(INPUT glb_cdcooper,
                                          INPUT tel_nrdconta,  
                                          OUTPUT aux_represen,
                                          OUTPUT aux_cpfrepre).
 
DELETE PROCEDURE h_b1wgen0028.

ASSIGN tel_repsolic = ENTRY(1,aux_represen). 


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY tel_dsentreg tel_dsdesfaz WITH FRAME f_entrega.

    CHOOSE FIELD tel_dsentreg
           HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
                 tel_dsdesfaz
           HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
           WITH FRAME f_entrega.

    HIDE MESSAGE NO-PAUSE.
       
    IF  FRAME-VALUE = tel_dsentreg  THEN /* Entregar */
        DO: 
            HIDE FRAME f_entrega.
            
            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.

            RUN valida_entrega_cartao IN h_b1wgen0028
                         (INPUT glb_cdcooper,
                          INPUT 0, 
                          INPUT 0, 
                          INPUT glb_cdoperad,
                          INPUT tel_nrdconta,
                          INPUT glb_dtmvtolt,
                          INPUT glb_dtmvtopr,
                          INPUT 1, 
                          INPUT 1, 
                          INPUT glb_nmdatela,
                          INPUT 99, 
                          INPUT par_nrctrcrd,
                          INPUT aux_nrcrcard,
                          INPUT 0, 
                          INPUT aux_dtvalida,
                          INPUT tel_repsolic,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-msg-confirma).
            
            DELETE PROCEDURE h_b1wgen0028.
            
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

            ASSIGN aux_nrcrcard = 0
                   aux_dtvalida = "".

            RUN sistema/generico/procedures/b1wgen0028.p 
                    PERSISTENT SET h_b1wgen0028.

            RUN consulta_dados_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT par_nrctrcrd,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-dados_cartao,
                             OUTPUT TABLE tt-msg-confirma).
            
            DELETE PROCEDURE h_b1wgen0028.

            FIND tt-dados_cartao NO-ERROR.

            IF  NOT AVAIL tt-dados_cartao  THEN
                RETURN "NOK".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF   tt-dados_cartao.inpessoa = 2 THEN
                     DO:
                         HIDE FRAME f_cartao_PJ.
                        
                         UPDATE tel_repsolic aux_nrcrcard aux_dtvalida
                                WITH FRAME f_cartao_pj
                        
                         EDITING:
                             READKEY.
                        
                             IF  FRAME-FIELD = "tel_repsolic"  THEN
                                 DO:
            
                                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                         DO:
                                             aux_indposi2 = aux_indposi2 - 1.
                         
                                             IF  aux_indposi2 = 0  THEN
                                                 aux_indposi2 = NUM-ENTRIES(aux_represen).
                         
                                             tel_repsolic = ENTRY(aux_indposi2,aux_represen).
                         
                                             DISPLAY tel_repsolic WITH FRAME f_cartao_PJ.
                                         END.
            
                                    ELSE
                                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                        DO:
                                            aux_indposi2 = aux_indposi2 + 1.
                         
                                            IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                                aux_indposi2 = 1.
                         
                                            tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                                       aux_represen)).
                         
                                            DISPLAY tel_repsolic WITH FRAME f_cartao_PJ.
                                        END.
                                    ELSE
                                    IF  LASTKEY =  KEYCODE(",")  THEN
                                        APPLY 46.
                                    ELSE
                                    IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                                        KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                                        KEYFUNCTION(LASTKEY) = "GO"          OR
                                        KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                                        KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                                        KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                        APPLY LASTKEY.

                                 END. 

                             ELSE
                                 APPLY LASTKEY.
                                                           
                         END. /* EDITING */
                         
                     END.
                ELSE 
                     DO:
                         UPDATE aux_nrcrcard aux_dtvalida  WITH FRAME f_cartao.
                     END.

                RUN sistema/generico/procedures/b1wgen0028.p 
                    PERSISTENT SET h_b1wgen0028.

                RUN valida_entrega_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT glb_dtmvtolt,
                              INPUT glb_dtmvtopr,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                              INPUT 1, /* 1a. validacao */
                              INPUT par_nrctrcrd,
                              INPUT aux_nrcrcard,
                              INPUT 0, /* Confirmacao - 2a. validacao */
                              INPUT aux_dtvalida,
                              INPUT tel_repsolic,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-msg-confirma).
                
                DELETE PROCEDURE h_b1wgen0028.
                              
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                        IF  AVAIL tt-erro THEN
                            DO:
                                BELL.
                                MESSAGE tt-erro.dscritic.
                            END.

                        NEXT.
                    END.

                
                HIDE FRAME f_cartao NO-PAUSE.
                HIDE FRAME f_cartao_PJ NO-PAUSE.


                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE aux_nrcrcard2  WITH FRAME f_confirma_cartao.

                    RUN sistema/generico/procedures/b1wgen0028.p 
                        PERSISTENT SET h_b1wgen0028.

                    RUN valida_entrega_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT glb_dtmvtolt,
                              INPUT glb_dtmvtopr,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                              INPUT 2, /* 2a. validacao */
                              INPUT par_nrctrcrd,
                              INPUT aux_nrcrcard,
                              INPUT aux_nrcrcard2,
                              INPUT aux_dtvalida,
                              INPUT tel_repsolic,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-msg-confirma).
                    
                    DELETE PROCEDURE h_b1wgen0028.

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
               
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        HIDE FRAME f_confirma_cartao NO-PAUSE.
                        NEXT.
                    END.


                LEAVE.
              
            END. /* FIM DO WHILE TRUE */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    HIDE FRAME f_cartao NO-PAUSE.
                    HIDE FRAME f_cartao_PJ NO-PAUSE.

                    NEXT.
                END.    
                
            FOR EACH tt-msg-confirma:
            
                aux_confirma = "N".

                HIDE MESSAGE NO-PAUSE.
               
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    BELL.
                    MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag 
                            UPDATE aux_confirma.

                    LEAVE.

                END.
                            
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        aux_confirma = "N".
                        LEAVE.
                    END.

            END. /* FOR EACH tt-msg-confirma */
           
            IF  aux_confirma <> "S"  THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.

                    BELL.
                    MESSAGE glb_dscritic.

                    HIDE FRAME f_confirma_cartao NO-PAUSE.
                    
                    NEXT.
                END.

            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.

            ASSIGN aux_inpessoa = tt-dados_cartao.inpessoa.
           
            RUN entrega_cartao IN h_b1wgen0028
                              (INPUT glb_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT glb_cdoperad,
                               INPUT tel_nrdconta,
                               INPUT glb_dtmvtolt,
                               INPUT 1,
                               INPUT 1,
                               INPUT glb_nmdatela,
                               INPUT par_nrctrcrd,
                               INPUT aux_nrcrcard,
                               INPUT aux_dtvalida,
                               INPUT aux_cpfrepre[aux_indposi2],
                               INPUT aux_inpessoa,
                              OUTPUT TABLE tt-erro).

            
            DELETE PROCEDURE h_b1wgen0028.

            HIDE FRAME f_confirma_cartao NO-PAUSE.
             
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

            ASSIGN aux_flgimp2v = NO
                   aux_cdprgctr = "fontes/sldccr_ct" + 
                                  STRING(par_cdadmcrd,"9") + ".p".

            RUN VALUE(aux_cdprgctr) (INPUT par_nrctrcrd).
                                     
        END. 
    ELSE  
    IF  FRAME-VALUE = tel_dsdesfaz  THEN /* Desfazer entrega */
        DO: 
            IF par_cdadmcrd <= 80  AND
               par_cdadmcrd >= 10 THEN
                DO:
                    BELL.
                    MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                    NEXT.
                END.
            ELSE
                DO:
                RUN sistema/generico/procedures/b1wgen0028.p 
                    PERSISTENT SET h_b1wgen0028.
            
                RUN desfaz_entrega_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT glb_dtmvtolt,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                              INPUT par_nrctrcrd,
                              INPUT 1, /* 1a. execucao */
                             OUTPUT TABLE tt-msg-confirma,
                             OUTPUT TABLE tt-erro).
            
                DELETE PROCEDURE h_b1wgen0028.
            
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
                    
                FOR EACH tt-msg-confirma:
                
                    aux_confirma = "N".
    
                    HIDE MESSAGE NO-PAUSE.
                
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                        BELL.
                        MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag 
                                UPDATE aux_confirma.
                              
                        LEAVE.
    
                    END.
    
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            aux_confirma = "N".
                            LEAVE.
                        END.
                                   
                END. /* FOR EACH tt-msg-confirma */
            
                IF  aux_confirma <> "S"  THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        glb_cdcritic = 0.
    
                        BELL.
                        MESSAGE glb_dscritic.
                     
                        NEXT.
                    END.
                
                RUN sistema/generico/procedures/b1wgen0028.p 
                    PERSISTENT SET h_b1wgen0028.
                
                RUN desfaz_entrega_cartao IN h_b1wgen0028
                                 (INPUT glb_cdcooper,
                                  INPUT 0, 
                                  INPUT 0, 
                                  INPUT glb_cdoperad,
                                  INPUT tel_nrdconta,
                                  INPUT glb_dtmvtolt,
                                  INPUT 1, 
                                  INPUT 1, 
                                  INPUT glb_nmdatela,
                                  INPUT par_nrctrcrd,
                                  INPUT 2, /* 2a. execucao */
                                 OUTPUT TABLE tt-msg-confirma,
                                 OUTPUT TABLE tt-erro).
                
                DELETE PROCEDURE h_b1wgen0028.
    
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
            END.
        END.

    LEAVE.

END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_entrega NO-PAUSE.

RETURN "OK".

/* ......................................................................... */
