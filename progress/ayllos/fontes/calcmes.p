/* .............................................................................
   Programa: Fontes/calcmes.p 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Dezembro/2004                    Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular nro de meses/dias recebendo como parametro
               data inicio e data fim.

............................................................................. */

DEF INPUT  PARAMETER aux_datadini AS DATE      NO-UNDO.
DEF INPUT  PARAMETER aux_datadfim AS DATE      NO-UNDO.
DEF OUTPUT PARAMETER aux_qtdadmes AS INTE      NO-UNDO.
DEF OUTPUT PARAMETER aux_qtdadias AS INTE      NO-UNDO.

DEF VAR aux_dtdentra    AS DATE NO-UNDO.
DEF VAR aux_dtdsaida    AS DATE NO-UNDO.


ASSIGN aux_qtdadmes  = 0
       aux_qtdadias  = 0.

IF  aux_datadini = ? OR                
    aux_datadfim = ? THEN
    RETURN.

IF  aux_datadfim <= aux_datadini THEN    
    RETURN.
    
ASSIGN  aux_dtdentra = aux_datadini.
ASSIGN  aux_qtdadias = aux_datadfim - aux_datadini.  /* Qdo menos que 1 mes*/


DO  WHILE TRUE:


    RUN fontes/calcdata.p (INPUT  aux_dtdentra, 
                                  1,
                                  "M",
                                   0,
                                  OUTPUT aux_dtdsaida).

    IF  aux_dtdsaida  > aux_datadfim THEN
        LEAVE.
 
    ASSIGN aux_dtdentra = aux_dtdsaida    
           aux_qtdadmes = aux_qtdadmes  + 1
           aux_qtdadias = aux_datadfim - aux_dtdsaida.
END.        
        
        
 


