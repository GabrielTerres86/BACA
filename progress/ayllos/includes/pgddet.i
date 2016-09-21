/*.............................................................................

   Programa: Includes/pgddet.i 
   Sistema : Conta-Corrente - Cooperativa de Credito  
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao:  /  /
  
   Dados referentes ao programa:
   
   Frequencia: Diario(Online).
   Objetivo  : Mostrar os detalhes do evento na opcao de Eventos em andamento
               do item RELACIONAMENTO da tela ATENDA.
    
   Alteracoes:

..............................................................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   RUN obtem-detalhe-evento IN h-b1wgen0039(INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_dtmvtolt,
                                            INPUT tel_nrdconta,
                                            INPUT YEAR(glb_dtmvtolt),
                                            INPUT tt-eventos-andamento.rowidedp,
                                            INPUT tt-eventos-andamento.rowidadp,
                                            INPUT 1,
                                            INPUT 1, 
                                            INPUT glb_nmdatela,
                                            INPUT FALSE,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-detalhe-evento).
   IF   RETURN-VALUE = "NOK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-erro   THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     RETURN.
                 END.
        END.    
     
   FIND FIRST tt-detalhe-evento NO-LOCK NO-ERROR.

   DISPLAY tt-detalhe-evento.nmevento 
           tt-detalhe-evento.dtinieve
           tt-detalhe-evento.dtfineve
           tt-detalhe-evento.dshroeve
           tt-detalhe-evento.dslocali
           tt-detalhe-evento.nmfornec
           tt-detalhe-evento.nmfacili 
           tt-detalhe-evento.dsconteu[1]
           tt-detalhe-evento.dsconteu[2]
           tt-detalhe-evento.dsconteu[3] 
           tt-detalhe-evento.dsconteu[4]
           tt-detalhe-evento.dsconteu[5]
           tt-detalhe-evento.dsconteu[6]
           tt-detalhe-evento.dsconteu[7]
           tt-detalhe-evento.dsconteu[8]
           tt-detalhe-evento.dsconteu[9]
           tt-detalhe-evento.dsconteu[10] WITH FRAME f_detalhe_evento.

   HIDE FRAME f_detalhe_evento.
   
   LEAVE.
   
END. 


/*......,.....................................................................*/
