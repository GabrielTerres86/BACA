/*.............................................................................

   Programa: Fontes/sitpgdp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 06/09/2013

   Dados referentes ao programa:
    
   Frequencia: Diario (Online).
   Objetivo  : Consultar item de RELACIONAMENTO na tela ATENDA para os
               eventos do PROGRID.
   
   Nota      : Devera estar conectado ao banco do PROGRID p/ compilar.
               (/usr/coop/cecred/progrid/arquivos/progrid.db) 

   Alteracoes: 28/09/2009 - Evitar chamada desnecessaria da BO.
    
                            Retirada de parametro desnecessario.
                            (Padronizacao da BO) (Gabriel).
                            
              06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                           a escrita será PA (André Euzébio - Supero).
..............................................................................*/

{ sistema/generico/includes/b1wgen0039tt.i }
{ sistema/generico/includes/var_internet.i }

{ includes/var_online.i }
{ includes/var_sitpgd.i }
{ includes/var_atenda.i }

DEF VAR h-b1wgen0039  AS HANDLE                                       NO-UNDO.


/* BO para trazer os dados do PROGRID */
RUN sistema/generico/procedures/b1wgen0039.p PERSISTENT SET h-b1wgen0039.

IF   NOT VALID-HANDLE (h-b1wgen0039)   THEN
     DO:
         MESSAGE "Handle invalido para h-b1wgen0039.".
         RETURN.
     END.


DO WHILE TRUE ON ENDKEY UNDO,  LEAVE:
    
   /* Traz os dados da tela principal, Relacionamentos */    
   RUN obtem-quantidade-eventos IN h-b1wgen0039 (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT tel_nrdconta,
                                                 INPUT YEAR(glb_dtmvtolt),
                                                 INPUT 1, /* Titular */
                                                 INPUT 1, /* Ayllos  */
                                                 INPUT glb_nmdatela,
                                                 INPUT FALSE, /* Log */
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-qtdade-eventos).

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-erro   THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     RETURN.
                 END.
        END.
     
   FIND FIRST tt-qtdade-eventos NO-ERROR.

   DISPLAY tt-qtdade-eventos.qtpenden   tt-qtdade-eventos.qtconfir   
           tt-qtdade-eventos.qtandame   tt-qtdade-eventos.qthispar
           tt-qtdade-eventos.dtinique   tt-qtdade-eventos.dtfimque   
           tel_qtandame                 tel_qthistor
           tel_question                 tel_qtpenden
           tel_qtconfir                 WITH FRAME f_relacionamento.
               
   
   /* Opcao de Eventos em andamento, historico do cooperado e questionario*/
   DO WHILE TRUE ON ENDKEY UNDO,  LEAVE:
  
      ASSIGN aux_flgcontr = FALSE.
      
      CHOOSE FIELD tel_qtandame  
                   tel_qthistor   
                   tel_qtpenden
                   tel_qtconfir
                   tel_question WITH FRAME f_relacionamento.
          
      IF   FRAME-FIELD = "tel_qtpenden"   THEN
           DO:
               IF   tt-qtdade-eventos.qtpenden = 0   THEN
                    DO:
                        MESSAGE "Nao foi encontrada nenhuma pre-inscricao"
                                "pendente.".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                        NEXT.
                    END.
         
               par_dsobserv = "P".    /* Parametro para a BO */
                                      /* Somente as  pendentes */

               { includes/pgdeve.i  } /*Eventos em andamento com Insc.Pend. */

           END.
      ELSE
      IF   FRAME-FIELD = "tel_qtconfir"   THEN
           DO:
               IF   tt-qtdade-eventos.qtconfir = 0   THEN
                    DO:
                        MESSAGE "Nao foi encontrada nenhuma inscricao"
                                "confirmada.".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                        NEXT.
                    END.
             
               par_dsobserv = "C".     /* Parametro para a BO */
                                     /* Somente os confirmados */
               
               { includes/pgdeve.i  } /*Eventos em andamento com Insc.Confirm.*/
         
           END.
           
      ELSE
      IF   FRAME-FIELD = "tel_qtandame"   THEN  /*Eventos em andamento do PA*/
           DO:
               IF   tt-qtdade-eventos.qtandame = 0   THEN
                    DO:
                        MESSAGE "Nenhum evento esta em andamento neste PA.".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                        NEXT.
                    END.
               
               par_dsobserv = "".    /* Todos os Eventos em andamento */
                                     /* Sem restricao na chamada da BO */
                         
               { includes/pgdeve.i  }  /* Eventos em andamento */
           
           END.
      ELSE                                      /* Historico de participacao */
      IF   FRAME-FIELD = "tel_qthistor"   THEN
           DO:
               IF   tt-qtdade-eventos.qthispar = 0   THEN
                    DO:
                        MESSAGE "Nao foi encontrado nenhum historico de"
                                "participacao.".
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                        NEXT.
                    END.
         
               aux_flgpesqu = TRUE. /* Pede parametros de pesquisa */
             
               { includes/pgdhst.i } /*Lista os eventos com historico de part*/
               
               NEXT. /* Evitar chamar BO desnecessariamente */
                         /* Aqui nao se alteram os dados */
           END.
      ELSE                                      
      IF   FRAME-FIELD = "tel_question"   THEN  /* Datas do Questionario */
           DO:
               ASSIGN glb_cddopcao = "A"
                      glb_nmrotina = "RELACIONAMENTO".
               
               { includes/acesso.i }
                
               { includes/pgdqst.i }
          
           END.
    
      ASSIGN aux_flgcontr = TRUE.
      
      LEAVE.
      
   END. /* Fim do DO WHILE TRUE */

   IF   aux_flgcontr   THEN
        NEXT.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.

END.  /* Fim do DO WHILE TRUE */

HIDE FRAME f_relacionamento.

DELETE PROCEDURE h-b1wgen0039.

/*............................................................................*/
