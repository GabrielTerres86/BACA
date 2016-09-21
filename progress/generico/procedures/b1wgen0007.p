/* .............................................................................

   Programa: b1wgen0007.p                  
   Autora  : Mirtes/Junior.
   Data    : 23/11/2005                     Ultima atualizacao: 27/12/2007 

   Dados referentes ao programa:

   Objetivo  : Calcular nro de meses/dias recebendo como parametro
               data inicio e data fim.
               
               Adaptado de fontes/calcmes.p

   Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).
                            
               27/12/2007 - Retirada dos FINDs crapcop e crapdat, pois este nao
                            estava sendo necessario (Julio)
............................................................................. */

DEFINE VARIABLE h-b1wgen08         AS HANDLE  NO-UNDO.

DEF TEMP-TABLE tt-erro LIKE craperr.

DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.

PROCEDURE calcmes:

    DEF INPUT        PARAM p-cdcooper      AS INTE.
    DEF INPUT        PARAM p-cod-agencia   AS INTE.
    DEF INPUT        PARAM p-nro-caixa     AS INTE.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR. 
    DEF INPUT        PARAM aux_datadini    AS DATE.
    DEF INPUT        PARAM aux_datadfim    AS DATE.

    DEF OUTPUT       PARAM aux_qtdadmes    AS INTE.
    DEF OUTPUT       PARAM aux_qtdadias    AS INTE.
    DEF OUTPUT       PARAM TABLE FOR tt-erro.

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
    ASSIGN  aux_qtdadias = aux_datadfim - aux_datadini. /* Qdo menos que 1 mes*/

    RUN sistema/generico/procedures/b1wgen0008.p 
                          PERSISTENT SET h-b1wgen08.

    DO  WHILE TRUE:

        RUN calcdata IN h-b1wgen08 (INPUT p-cdcooper,
                                    INPUT 1,
                                    INPUT 999,
                                    INPUT "996",
                                    INPUT  aux_dtdentra, 
                                    INPUT 1,
                                    INPUT "M",
                                    INPUT 0,
                                    OUTPUT aux_dtdsaida,
                                    OUTPUT TABLE tt-erro).

        IF  aux_dtdsaida  > aux_datadfim THEN
            LEAVE.
 
        ASSIGN aux_dtdentra = aux_dtdsaida    
               aux_qtdadmes = aux_qtdadmes  + 1
               aux_qtdadias = aux_datadfim - aux_dtdsaida.
    END.        

    IF  VALID-HANDLE(h-b1wgen08) THEN
        DELETE PROCEDURE h-b1wgen08.
    
END PROCEDURE.

/* b1wgen0007.p */

/* .......................................................................... */ 
