/* .............................................................................

   Programa: Fontes/deschq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 23/06/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar PROPOSTAS DE LIMITE DE DESCONTO DE CHEQUES
               para a tela ATENDA.

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               05/04/2006 - Inclusao da data de inicio de vigencia na listagem
                            da tela (Julio)

               12/04/2006 - Estava ocorrendo erro quando a data da vigencia
                            vazia (Julio).
                            
               13/09/2009 - Alterado para um browse dinamico (Gabriel).       
               
               26/03/2010 - Trazer campo de envio a sede, usar a BO 09
                            (Gabriel).

............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i "NEW" }

  
DEF VAR h-b1wgen0009 AS HANDLE                                       NO-UNDO.

DO WHILE TRUE:
    
   RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.

   RUN busca_limites IN h-b1wgen0009 (INPUT glb_cdcooper,
                                      INPUT tel_nrdconta,
                                      INPUT glb_dtmvtolt,
                                      OUTPUT TABLE tt-limite_chq).

   DELETE PROCEDURE h-b1wgen0009.
    
   RUN fontes/deschq_1.p(INPUT TABLE tt-limite_chq).

   IF   aux_flgsaida   THEN
        LEAVE.   

END.


/* .......................................................................... */
