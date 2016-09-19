/*.............................................................................

   Programa: Includes/pgdsit.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 04/06/2010
   
   Dados referentes ao programa:

   Frequencia: Diario (Online).
   Objetivo  : Chamada pela includes/pgdeve.i para mostrar e/o alterar a situa- 
               cao da inscricao do cooperado no evento selecionado e imprimir
               o termo de compromisso.

   Alteracoes: 25/08/2009 - Alterar confirmacao fixa por fontes/confirma.p
                            (Gabriel).
                            
               16/10/2009 - Imprimir termo de compromisso quando confirmar
                            pre-inscricao (Gabriel).             
                            
               04/06/2010 - Esconder o frame da situacao sempre que sair
                            desta tela.
                            Corrigir erro de inscricao nao disponivel
                            quando impressao do termo. (Gabriel).             

.............................................................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN situacao-inscricao IN h-b1wgen0039(INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad, 
                                           INPUT glb_dtmvtolt,
                                           INPUT tel_nrdconta,
                                           INPUT tt-eventos-andamento.rowidedp,
                                           INPUT tt-eventos-andamento.rowidadp,
                                           INPUT 1, 
                                           INPUT 1,
                                           INPUT glb_nmdatela, 
                                           INPUT FALSE,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-situacao-inscricao).
                                          
    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                        
             IF   AVAILABLE tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      PAUSE 2 NO-MESSAGE.
                      HIDE MESSAGE NO-PAUSE.
                  END.

             LEAVE.
                                        
         END.                         
                        
    DISPLAY tel_sitopcao[1]
            tel_sitopcao[2]
            tel_sitopcao[3]
            tel_sitopcao[4]
            tel_sitopcao[5] 
            tel_sitopcao[6] WITH FRAME f_situacao_inscricao.  
                  
    /* Destacar opcao 2 */

    COLOR DISPLAY MESSAGE tel_sitopcao[2] WITH FRAME f_situacao_inscricao.
       
    COLOR DISPLAY NORMAL  tel_sitopcao[1]
                          tel_sitopcao[3]
                          tel_sitopcao[4]
                          tel_sitopcao[5] 
                          tel_sitopcao[6] WITH FRAME f_situacao_inscricao.
                             
    ASSIGN ind_opcaosit = 2.                      

    OPEN QUERY q-situacao-inscricao FOR EACH tt-situacao-inscricao NO-LOCK
                                        BY tt-situacao-inscricao.nminseve.
                                          
    /* Selecionar evento e opcao ao mesmo tempo */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
          ENABLE b-situacao-inscricao WITH FRAME f_situacao_inscricao.
                                         
          APPLY "ENTRY" TO b-situacao-inscricao IN FRAME f_situacao_inscricao.  
          
          READKEY.
        
          HIDE MESSAGE NO-PAUSE.
          
          /* Eventos do browse */
          IF  CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                   KEYFUNCTION(LASTKEY))  THEN
           
              APPLY KEYFUNCTION(LASTKEY) TO b-situacao-inscricao
                                            IN FRAME f_situacao_inscricao.
          ELSE
          IF   CAN-DO("CURSOR-RIGHT,TAB",KEYFUNCTION(LASTKEY))   THEN
               DO:
                   COLOR DISPLAY NORMAL tel_sitopcao[ind_opcaosit]

                                        WITH FRAME f_situacao_inscricao.
                                       
                   ASSIGN ind_opcaosit = IF   ind_opcaosit = 6   THEN
                                              1
                                         ELSE
                                              ind_opcaosit + 1.
               END.
          ELSE
          IF   CAN-DO("CURSOR-LEFT",KEYFUNCTION(LASTKEY))   THEN
               DO:
                   COLOR DISPLAY NORMAL tel_sitopcao[ind_opcaosit]

                                       WITH FRAME f_situacao_inscricao.
                                       
                   ASSIGN ind_opcaosit = IF   ind_opcaosit = 1   THEN
                                              6
                                         ELSE
                                              ind_opcaosit - 1.
               END.
          ELSE
          IF   CAN-DO("GO,RETURN,END-ERROR",KEYFUNCTION(LASTKEY))  THEN
               DO:
                   LEAVE.
               END.

          COLOR DISPLAY MESSAGE tel_sitopcao[ind_opcaosit]
                                 
                                WITH FRAME f_situacao_inscricao.

       END. /* Fim do DO WHILE TRUE */

       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            LEAVE.
                        
       IF   CAN-DO("1,2,3,4,5",STRING(ind_opcaosit))   THEN
            DO:
                ASSIGN glb_cddopcao = "A"
                       glb_nmrotina = "RELACIONAMENTO".
               
                { includes/acesso.i }
                
            END.
       
       HIDE MESSAGE NO-PAUSE.
       
       RUN fontes/confirma.p (INPUT "",
                              OUTPUT aux_confirma).
                               
       IF   aux_confirma <> "S"   THEN
            NEXT.

       IF   ind_opcaosit = 6   THEN   /* Termo de compromisso */
            DO:
                IF   NOT tt-eventos-andamento.flgcompr   THEN
                     DO:
                         MESSAGE "Este evento nao possui termo de compromisso.".
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                
                par_nrdrowid = tt-situacao-inscricao.rowididp.
                
                { includes/pgdter.i }

                LEAVE.

            END.


       /* ind_opcaosit: 1- Pendente, 2- Confir, 3- Desist. , 4- Excluido */
       /*               5 - Excedente                                    */
       RUN grava-nova-situacao IN h-b1wgen0039 
                                 (INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                  INPUT glb_dtmvtolt,
                                  INPUT tel_nrdconta,
                                  INPUT tt-situacao-inscricao.rowididp,
                                  INPUT ind_opcaosit,
                                  INPUT 1,
                                  INPUT 1,
                                  INPUT glb_nmdatela,
                                  INPUT FALSE,
                                 OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"   THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF   AVAILABLE tt-erro   THEN
                     DO:
                         MESSAGE tt-erro.dscritic.
                         PAUSE 2 NO-MESSAGE.
                         HIDE MESSAGE NO-PAUSE.
                     END.
                
                LEAVE.

            END.

       IF   ind_opcaosit = 2                AND /* Confirmou */   
            tt-eventos-andamento.flgcompr  THEN /* Termo de compromisso */
            DO:
                par_nrdrowid = tt-situacao-inscricao.rowididp.
                      
                { includes/pgdter.i }

            END.

       LEAVE.
       
    END.  /* Fim do DO WHILE TRUE */
    
    HIDE FRAME f_situacao_inscricao.
    LEAVE.

END. /* Fim do DO WHILE TRUE */


/*............................................................................*/
