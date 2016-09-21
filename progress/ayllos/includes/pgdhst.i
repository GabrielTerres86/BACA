/*.........................................................................

   Programa: Includes/pgdhst.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 16/10/2012

   Dados referentes ao programa:
   
   Frequencia: Diario (Online).
   Objetivo  : Chamado pela includes/pgdeve.i ou fontes/sitpgdp.p para
               consultar opcao de Historico de eventos do cooperado no item   
               RELACIONAMENTO da tela ATENDA.

   NOTA      : ESTA INCLUDES EH USADA EM - includes/pgdeve.i e fontes/sitpgdp.p
               VERIFICAR ANTES DE ALTERAR.                            

   Alteracoes: 10/09/2009 - Parametrizacao da BO (Gabriel).
   
               07/02/2011 - Incluida opcao para mostrar historico em tela
                            ou impressao (Gabriel). 
                            
               16/10/2012 - Correção relativa à exibição do histórico em 
                            (T)erminal ou (I)mpressora (Lucas). 

.............................................................................*/

/* Reposicionar o browse conforme o que o usuario digitar */
ON ANY-KEY OF b-historico-evento DO:


    IF   (LASTKEY >= 65 AND LASTKEY <= 90)    OR    /* Letras Maiusculas */
         (LASTKEY >= 97 AND LASTKEY <= 122)   THEN  /* Letras Minusculas */
          DO:
              aux_dsdbusca = aux_dsdbusca + KEYFUNCTION(LASTKEY).

              FIND FIRST tt-historico-evento WHERE
                         tt-historico-evento.nmevento BEGINS aux_dsdbusca 
                         NO-LOCK NO-ERROR.
                         
              IF  AVAILABLE tt-historico-evento   THEN
                  REPOSITION q-historico-evento TO ROWID 
                                                   ROWID(tt-historico-evento).  
          
          END.
     ELSE
          DO:
              aux_dsdbusca = "".
          END.
          
END.


ON ENTRY OF tel_nmevento DO:

   RUN lista-eventos IN h-b1wgen0039 (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_dtmvtolt,
                                      INPUT tel_nrdconta,
                                      INPUT INPUT tel_dtanoage[1],
                                      INPUT INPUT tel_dtanoage[2],
                                      INPUT 1,
                                      INPUT 1,
                                      INPUT glb_nmdatela,
                                      INPUT FALSE,
                               OUTPUT TABLE tt-lista-eventos).
END.


ON RETURN OF b-lista-eventos DO:

   IF   AVAILABLE tt-lista-eventos   THEN
        DO:
            ASSIGN tel_nmevento = tt-lista-eventos.nmevento.
            
            DISPLAY tel_nmevento WITH FRAME f_pesquisa_historico.
        
        END.

   APPLY "GO".

END.


DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
                              
    IF   aux_flgpesqu   THEN  /* Pede parametros de pesquisa */
         DO: 
             ASSIGN tel_nmevento = ""
                    tel_dtanoage = YEAR(glb_dtmvtolt) WHEN tel_dtanoage[1] = 0.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                UPDATE tel_dtanoage[1]  
                       tel_dtanoage[2]
                       tel_nmevento    WITH FRAME f_pesquisa_historico
                         
                EDITING:
                      
                    READKEY.         
                         
                    IF   FRAME-FIELD = "tel_nmevento"   THEN
                         DO:
                             IF   LASTKEY = KEYCODE("F7")   THEN
                                  DO:
                                      OPEN QUERY q-lista-eventos
                                        FOR EACH tt-lista-eventos NO-LOCK 
                                            BY tt-lista-eventos.nmevento.

                                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                       
                                         UPDATE b-lista-eventos 
                                                WITH FRAME f_lista_eventos.
                                         LEAVE.       
                                            
                                      END.      
                                    
                                      HIDE FRAME f_lista_eventos.
                                      
                                  END.
                             ELSE 
                             IF   CAN-DO("RETURN,GO",KEYFUNCTION(LASTKEY)) THEN
                                  DO:
                                      IF   tel_nmevento = ""  THEN
                                           RELEASE tt-lista-eventos.
                                      
                                      APPLY "GO".
                                  END.
                             ELSE 
                             IF   CAN-DO("END-ERROR,TAB,CURSOR-DOWN,CURSOR-UP" +
                                         ",CURSOR-LEFT,CURSOR-RIGHT",
                                         KEYFUNCTION(LASTKEY))  THEN
                                  DO:
                                      APPLY LASTKEY.
                                  END.
                         END.
                    ELSE
                         APPLY LASTKEY.

                END.  /* Fim do EDITING */      
                 
                LEAVE.
                
             END. /* Fim do DO WHILE TRUE */
             
             HIDE FRAME f_pesquisa_historico.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  LEAVE.

             ASSIGN aux_idevento = IF   AVAILABLE tt-lista-eventos   THEN
                                        tt-lista-eventos.idevento
                                   ELSE
                                        0
                    aux_cdevento = IF   AVAILABLE tt-lista-eventos   THEN
                                        tt-lista-eventos.cdevento
                                   ELSE
                                        0.

         END. /* Fim da pesquisa do historico */
    ELSE
         DO:  /* Evento selecionado a partir de 'Eventos em andamento' */
             
             ASSIGN aux_cdevento = tt-eventos-andamento.cdevento
                    aux_idevento = tt-eventos-andamento.idevento
                    
                    tel_dtanoage = 0.

         END.
      

    /* Se eh Historico de participacao da Tela Principal */
    IF   aux_flgpesqu   THEN
         DO: 
             ASSIGN aux_confirma = "T".
             MESSAGE "(T)erminal ou (I)mpressora:" UPDATE aux_confirma.
            
             HIDE MESSAGE NO-PAUSE.
            
             IF   aux_confirma <> "T"   AND
                  aux_confirma <> "I"   THEN
                  NEXT.
         END.
    ELSE
         aux_confirma = "T". /* Senao mostrar soh na tela */

    RUN obtem-historico IN h-b1wgen0039 (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT tel_nrdconta,
                                         INPUT tel_dtanoage[1],
                                         INPUT tel_dtanoage[2],
                                         INPUT aux_idevento,
                                         INPUT aux_cdevento,
                                         INPUT aux_confirma,
                                         INPUT 1,
                                         INPUT 1, 
                                         INPUT glb_nmdatela,
                                         INPUT FALSE,
                                        OUTPUT TABLE tt-historico-evento,
                                        OUTPUT par_nmarquiv,
                                        OUTPUT par_nmarqpdf).    
                                      
    IF   aux_confirma = "T"   THEN /* Terminal */
         DO:
             OPEN QUERY q-historico-evento FOR EACH tt-historico-evento NO-LOCK
                                       BY tt-historico-evento.nmevento
                                         BY tt-historico-evento.nminseve
                                          BY tt-historico-evento.dtinieve.
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                       
                UPDATE b-historico-evento WITH FRAME f_historico_evento
                
                EDITING:
                
                   READKEY PAUSE 1.
                
                   IF   LASTKEY = -1   THEN
                        DO:
                            aux_dsdbusca = "".
                        END.
             
                   APPLY LASTKEY.
                     
                END.   /* Fim EDITING */
                              
                LEAVE.
                 
             END.
    
             HIDE FRAME f_historico_evento.
         END.
    ELSE      /* Impressao */
         DO:
             RUN fontes/impressao_historico.p (INPUT par_nmarquiv).        
         END.

    IF   aux_flgpesqu = FALSE   THEN  /* Volta a tela de Eventos em andamento */
         DO:
             IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN
                  LEAVE.
         END.

END.   /* Fim do DO WHILE TRUE */


/*............................................................................*/
