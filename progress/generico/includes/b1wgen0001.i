/* .............................................................................

   Include : b1wgen0001.i                   
   Autora  : Mirtes.
   Data    : 14/09/2005                     Ultima atualizacao: 

   Dados referentes ao programa:

   Objetivo  : INCLUDE GERACAO DE ERROS      

   Alteracoes: 
............................................................................ */

    ASSIGN aux_sequen = aux_sequen + 1.
                  
    CREATE tt-erro.
    ASSIGN tt-erro.cdagenci   = p-cod-agencia
           tt-erro.nrdcaixa   = p-nro-caixa
           tt-erro.nrsequen   = aux_sequen  
           tt-erro.cdcritic   = i-cod-erro            
           tt-erro.erro       = YES 
           tt-erro.dscritic   = c-dsc-erro.
    IF  i-cod-erro <> 0 AND
        c-dsc-erro <> " " THEN
        .
    ELSE    
    IF  i-cod-erro <> 0 THEN
        DO:
           FIND crapcri NO-LOCK WHERE
                crapcri.cdcritic = tt-erro.cdcritic NO-ERROR.
           IF  AVAIL crapcri THEN     
               ASSIGN   tt-erro.dscritic   = crapcri.dscritic.
        END.

/* b1wgen0001.i */      

           
