/*.............................................................................

   Programa: Includes/pgdeve.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 04/06/2010

   Dados referentes ao programa:
  
   Frequencia: Diario (Online).
   Objetivo  : Chamado pelo fontes/sitpgdp.p para consultar opcao de eventos
               em andamento do item RELACIONAMENTO da tela ATENDA.
              
   Alteracoes: 03/09/2009 - Nao chamar BO desnecessariamente. (Gabriel)
    
                          - Retirada de parametro desnecessario
                            (Padronizacao da BO) (Gabriel)
                            
               16/10/2009 - Chamar BO sempre depois da pre-inscricao
                            (Gabriel)  
                            
               04/06/2010 - Retirar ordenacao do browse pois isto passara a
                            ser feito na BO, (Adaptacao Ayllos Web) (Gabriel).                        

..............................................................................*/


/* Reposicionar o browse segundo o que o usuario digitar */
ON ANY-KEY OF b-eventos-andamento IN FRAME f_eventos_andamento DO:

    IF   KEYFUNCTION(LASTKEY) = "RETURN"  THEN
         APPLY "GO".
    
    IF   (LASTKEY >= 65 AND LASTKEY <= 90)    OR    /* Letras Maiusculas */
         (LASTKEY >= 97 AND LASTKEY <= 122)   THEN  /* Letras Minusculas */
         DO:
             aux_dsdbusca = aux_dsdbusca + KEYFUNCTION(LASTKEY).
                        
             PAUSE 0.
             
             DISPLAY aux_dsdbusca WITH FRAME f_busca.
               
             FIND FIRST tt-eventos-andamento WHERE
                        tt-eventos-andamento.nmevento BEGINS aux_dsdbusca
                        NO-LOCK NO-ERROR.
                        
             IF   AVAILABLE tt-eventos-andamento   THEN
                  REPOSITION q-eventos-andamento TO ROWID 
                                           ROWID(tt-eventos-andamento).
         END.   
    ELSE
         DO:
             aux_dsdbusca = "".
             HIDE FRAME f_busca NO-PAUSE.
         END.

END.



DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   RUN obtem-eventos-andamento IN h-b1wgen0039(INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_dtmvtolt,
                                               INPUT tel_nrdconta,
                                               INPUT par_dsobserv,
                                               INPUT YEAR(glb_dtmvtolt),
                                               INPUT 1,  /* Titular */
                                               INPUT 1,  /* Ayllos  */
                                               INPUT glb_nmdatela,
                                               INPUT FALSE,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-eventos-andamento).
   
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
   
   DISPLAY tel_eveopcao[1]
           tel_eveopcao[2]
           tel_eveopcao[3]
           tel_eveopcao[4] WITH FRAME f_eventos_andamento.
    
   DO aux_contaopc = 1 TO 4:

      COLOR DISPLAY NORMAL tel_eveopcao[aux_contaopc]
    
                            WITH FRAME f_eventos_andamento.
   
   END.

   ASSIGN ind_opcaoeve = 1 WHEN ind_opcaoeve = 0.
   
   /* Destacar opcao em uso */
   COLOR DISPLAY MESSAGE  tel_eveopcao[ind_opcaoeve] 
                          
                          WITH FRAME f_eventos_andamento. 

   /* Exibe a lista dos eventos em andamento */
   OPEN QUERY q-eventos-andamento FOR EACH tt-eventos-andamento NO-LOCK. 

   PAUSE 0.
   
   /* Se nao tiver nenhum elemento na lista volta ... */
   IF   NUM-RESULTS ("q-eventos-andamento") = 0   THEN
        DO:
            HIDE FRAME f_eventos_andamento.
            LEAVE.
        END.
          
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      /* Selecionar evento e opcao ao mesmo tempo */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
         ENABLE b-eventos-andamento WITH FRAME f_eventos_andamento.
       
         APPLY "ENTRY" TO b-eventos-andamento IN FRAME f_eventos_andamento.
        
         APPLY "ANY-KEY" TO b-eventos-andamento IN FRAME f_eventos_andamento.
         
         READKEY PAUSE 1.
        
         /* se nao teclar nada oculta a busca */
         IF   LASTKEY = -1   THEN
              DO:
                  aux_dsdbusca = "".
                  HIDE FRAME f_busca NO-PAUSE.
              END.
            
            /* Eventos do browse */
         IF  CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                   KEYFUNCTION(LASTKEY))  THEN
      
            APPLY KEYFUNCTION(LASTKEY) TO b-eventos-andamento
                                          IN FRAME f_eventos_andamento.
         ELSE
         IF   CAN-DO("CURSOR-RIGHT,TAB",KEYFUNCTION(LASTKEY))   THEN
              DO:
                  COLOR DISPLAY NORMAL tel_eveopcao[ind_opcaoeve]
                 
                                       WITH FRAME f_eventos_andamento.
                 
                  ASSIGN ind_opcaoeve = IF   ind_opcaoeve = 4   THEN
                                             1
                                        ELSE
                                             ind_opcaoeve + 1.   
              END.
         ELSE
         IF   CAN-DO("CURSOR-LEFT",KEYFUNCTION(LASTKEY))   THEN
              DO:
                  COLOR DISPLAY NORMAL tel_eveopcao[ind_opcaoeve]
                                         
                                       WITH FRAME f_eventos_andamento.
                                      
                  ASSIGN ind_opcaoeve = IF   ind_opcaoeve = 1   THEN
                                             4
                                        ELSE
                                             ind_opcaoeve - 1.
              END.
         ELSE
         IF   CAN-DO("GO,RETURN,END-ERROR",KEYFUNCTION(LASTKEY))  THEN
              DO:
                  LEAVE.
              END.

         COLOR DISPLAY MESSAGE tel_eveopcao[ind_opcaoeve] 
                               WITH FRAME f_eventos_andamento.
                              
      END. /* Fim do DO WHILE TRUE */
    
      HIDE FRAME f_eventos_andamento.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* Sai da includes */
           DO:
               ind_opcaoeve = 0.
               LEAVE.
           END.

      IF   NOT AVAILABLE tt-eventos-andamento   THEN
           NEXT.
      
      /* Opcao selecionada */
    
      IF   ind_opcaoeve = 1   THEN 
           DO: 
               { includes/pgddet.i }  /* Detalhes do evento     */
        
               NEXT. /*Nao chama BO novamente, pois eh soh consulta*/
           END.
      ELSE  
      IF   ind_opcaoeve = 2   THEN 
           DO:
               ASSIGN glb_cddopcao = "I"
                      glb_nmrotina = "RELACIONAMENTO".
               
               { includes/acesso.i }
                             
               { includes/pgdins.i }  /* Pre-inscricao          */
                    
               LEAVE. /* Chama BO, pois altera os dados */
                
           END.
      ELSE               
      IF   ind_opcaoeve = 3   THEN 
           DO:                                                    
               IF   tt-eventos-andamento.dsobserv MATCHES "*H*"   OR
                    tt-eventos-andamento.dsobserv = ""            THEN
                    DO:
                        VIEW FRAME f_eventos_andamento.
                        
                        MESSAGE "Nao existe pre-inscricao para este evento.".

                        PAUSE 2 NO-MESSAGE.

                        NEXT.
                    END.
               
               { includes/pgdsit.i }  /* Situacao da inscricao  */

                LEAVE. /* Chama BO , pois pode alterar dados */
                        
           END.
      ELSE              
      IF   ind_opcaoeve = 4   THEN 
           DO:
               IF   tt-eventos-andamento.dsobserv = ""   THEN
                    DO:
                        VIEW FRAME f_eventos_andamento.

                        MESSAGE "O evento selecionado nao possui historico.".
                    
                        PAUSE 2 NO-MESSAGE.
                        
                        NEXT.
                    END.

               ASSIGN aux_flgpesqu = FALSE.
               
               { includes/pgdhst.i }  /* Historico */
               
               NEXT. /* Nao altera dados */
               
           END.
      
   END. /* Fim DO WHILE TRUE */

   IF   ind_opcaoeve <> 0  THEN
        NEXT.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.
   
END.  /* Fim do DO WHILE TRUE */          

/*...........................................................................*/
