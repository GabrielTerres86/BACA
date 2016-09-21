 /*****************************************************************************

    Programa  : b1wgen0162.p
    Autor     : Lucas R.
    Data      : Julho/2013                   Ultima Atualizacao:
    
    Dados referentes ao programa:

    Objetivo  : BO refefente aos CONSORCIOS.
        
    Alteracoes:
    
*****************************************************************************/

{ sistema/generico/includes/var_internet.i }    
{ sistema/generico/includes/b1wgen0162tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/gera_erro.i }   
{ sistema/generico/includes/gera_log.i  }

DEF STREAM str_1.

PROCEDURE lista_consorcio:        
                                  
    DEF INPUT PARAM par_cdcooper  AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta  AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-consorcios.
    
    EMPTY TEMP-TABLE tt-consorcios.
    
    /*** Faz a busca de todas as cotas de consorcio para cada conta ***/
    FOR EACH crapcns WHERE crapcns.cdcooper = par_cdcooper AND 
                           crapcns.nrdconta = par_nrdconta
                           NO-LOCK :
       
        CREATE tt-consorcios.
        BUFFER-COPY crapcns TO tt-consorcios.


        ASSIGN tt-consorcios.parcpaga = STRING(crapcns.qtparpag, "999") + " de " +
                                        STRING(crapcns.qtparcns, "999").

        /*** busca tipo de consorcio ***/
        CASE crapcns.tpconsor:
            WHEN 1 THEN
                 ASSIGN tt-consorcios.dsconsor = "MOTO".
            WHEN 2 THEN
                 ASSIGN tt-consorcios.dsconsor = "AUTO".
            WHEN 3 THEN
                 ASSIGN tt-consorcios.dsconsor = "PESADOS".
            WHEN 4 THEN
                 ASSIGN tt-consorcios.dsconsor = "IMOVEIS".
            WHEN 5 THEN
                 ASSIGN tt-consorcios.dsconsor = "SERVICOS".
        END CASE.
        
        IF  crapcns.flgativo THEN
            ASSIGN tt-consorcios.instatus = "Ativo".
        ELSE
            ASSIGN tt-consorcios.instatus = "Cancelado".

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE indicativo_consorcio:
    
    DEF INPUT PARAM par_cdcooper  AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta  AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM par_flgativo AS LOG INIT FALSE                    NO-UNDO.

    FIND FIRST crapcns WHERE crapcns.cdcooper = par_cdcooper AND
                             crapcns.nrdconta = par_nrdconta AND
                             crapcns.flgativo = TRUE
                             NO-LOCK NO-ERROR NO-WAIT.

    IF  AVAIL crapcns THEN
        ASSIGN par_flgativo = TRUE.
    ELSE 
        ASSIGN par_flgativo = FALSE.

    RETURN "OK".

END PROCEDURE.

