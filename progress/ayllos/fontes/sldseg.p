/* .............................................................................

   Programa: Fontes/sldseg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/96.                        Ultima atualizacao: 31/08/11

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar seguros para a tela ATENDA.

   Alteracao : 06/03/97 - Tratar cancelamento de seguro (Odair)

	       25/04/97 - Tratar seguro auto (Edson).

	       12/06/97 - Tratar automacao dos seguros (Edson).
           
           31/12/2010 - Usar browse dinamico, e utilizar a BO de seguros 
                        (Gabriel).
                        
           31/08/2011 - Adicionada temp-table tt-erro como retorno da procedure
                        da blwgen0033 (Gati - Oliver)

............................................................................. */

{ includes/var_online.i }

    
{ includes/var_atenda.i }
{ includes/var_seguro.i "NEW" }
{ sistema/generico/includes/var_internet.i }

DEF INPUT  PARAM par_flgsaldo AS LOGICAL                             NO-UNDO.

DO WHILE TRUE:

    RUN sistema/generico/procedures/b1wgen0033.p 
                        PERSISTENT SET h-b1wgen0033.
            
            
    RUN busca_seguros IN h-b1wgen0033 (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_dtmvtolt,
                                      INPUT tel_nrdconta,
                                      INPUT 1,
                                      INPUT 1,
                                      INPUT glb_nmdatela,
                                      INPUT FALSE,
                                      OUTPUT TABLE tt-seguros,
                                      OUTPUT aux_qtsegass,
                                      OUTPUT aux_vltotseg,
                                      OUTPUT TABLE tt-erro).
    
    
    DELETE PROCEDURE h-b1wgen0033.
    
   IF   par_flgsaldo   THEN
        DO: 
            RUN fontes/seguro.p (INPUT TABLE tt-seguros).

            /* Se nao saiu da tela ... re-chama BO */
            IF   NOT aux_flgsaida   THEN
                 NEXT.
        END.

   LEAVE.

END. /* Fim do DO WHILE TRUE , volta para a ATENDA */


/* .......................................................................... */
