/*.............................................................................

   Programa: Includes/pgdqst.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 01/11/2010

   Dados referentes ao programa:
  
   Frequencia: Diario (Online).
   Objetivo  : Chamada por fontes/sitpgdp.p. Mostrar as datas de entrega e
               devolucao do questionario, permitindo a alteracao delas.
  
   Alteracoes: 24/08/2009 - Alterar mensagem de confirmacao e aproveitar o
                            fontes/confirma.p (Gabriel).
                            
               01/11/2010 - Incluso o campo DTCADQST p/ questionario (Vitor).             

..............................................................................*/


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY tt-qtdade-eventos.dtcadqst WITH FRAME f_questionario.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
    
        UPDATE tt-qtdade-eventos.dtinique
               tt-qtdade-eventos.dtfimque WITH FRAME f_questionario.
        LEAVE.
    
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:
             HIDE FRAME f_questionario.
             LEAVE.   
         END.
 
    RUN fontes/confirma.p (INPUT "",
                           OUTPUT aux_confirma).
                           
    IF   aux_confirma <> "S"   THEN
         NEXT.
   
    RUN grava-data-questionario IN h-b1wgen0039
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_nrdconta,
                                     INPUT tt-qtdade-eventos.dtinique,
                                     INPUT tt-qtdade-eventos.dtfimque,
                                     INPUT 1,
                                     INPUT 1,
                                     INPUT glb_nmdatela,
                                     INPUT FALSE,
                                    OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
             IF   AVAILABLE tt-erro  THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      PAUSE 2 NO-MESSAGE.
                      HIDE MESSAGE NO-PAUSE.  
                  END.
             
             NEXT.
         
         END.

    MESSAGE "Operacao efetuada com sucesso !!".

    PAUSE 2 NO-MESSAGE.
         
    HIDE MESSAGE NO-PAUSE.     

    HIDE FRAME f_questionario.
    
    LEAVE.

END. /* Fim do DO WHILE TRUE */


/*............................................................................*/
