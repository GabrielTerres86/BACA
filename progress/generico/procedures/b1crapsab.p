/* .............................................................................

   Programa: b1crapsab.p                  
   Autor   : David.
   Data    : 07/12/2006                     Ultima atualizacao: 22/05/2015 

   Dados referentes ao programa:

   Objetivo  : BO PARA GERENCIMENTO DE SACADOS DOS BOLETOS

   Alteracoes: 26/06/2009 - Criada a procedure exclui_sacado (Fernando).
               
               17/12/2013 - Adicionado validate para tabela crapsab (Tiago).                                                    

               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                            
               22/05/2015 - Substituir "&" por "E" ao cadastrar sacado. (Rafael)
                           
............................................................................. */

DEF TEMP-TABLE cratsab LIKE crapsab.

/*----------------------------------------------------------------------------*/

PROCEDURE cadastra_sacado.

    DEF INPUT        PARAM TABLE FOR  cratsab.    
    DEF OUTPUT       PARAM par_dscritic     AS CHAR.
    
    FIND FIRST cratsab NO-LOCK NO-ERROR.
    
    FIND crapsab WHERE crapsab.cdcooper = cratsab.cdcooper AND
                       crapsab.nrdconta = cratsab.nrdconta AND
                       crapsab.nrinssac = cratsab.nrinssac NO-LOCK NO-ERROR.
                       
    IF  AVAILABLE crapsab  THEN
        DO:
            ASSIGN par_dscritic = "Pagador informado ja cadastrado!".
            
            RETURN "NOK".
        END.
        
    CREATE crapsab.
    BUFFER-COPY cratsab TO crapsab
        ASSIGN crapsab.nmdsacad = REPLACE(cratsab.nmdsacad,"&","E").

    VALIDATE crapsab.

END PROCEDURE.

/*----------------------------------------------------------------------------*/

PROCEDURE altera_sacado.

    DEF INPUT        PARAM TABLE FOR  cratsab.    
    DEF OUTPUT       PARAM par_dscritic     AS CHAR.
    
    DEF VAR aux_contador AS INTE                NO-UNDO.

    FIND FIRST cratsab NO-LOCK NO-ERROR.
    
    ASSIGN par_dscritic = "".
    
    DO aux_contador = 1 TO 20:
    
        FIND crapsab WHERE crapsab.cdcooper = cratsab.cdcooper AND
                           crapsab.nrdconta = cratsab.nrdconta AND
                           crapsab.nrinssac = cratsab.nrinssac 
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
        IF  NOT AVAILABLE crapsab  THEN
            IF  LOCKED crapsab  THEN
                DO:
                    ASSIGN par_dscritic = "Dados do Pagador estao sendo " +
                                              "alterados no momento!".
                        
                    NEXT.
                END.
            ELSE
                DO:
                    ASSIGN par_dscritic = "Pagador informado nao esta " +
                                          "cadastrado!".
                END.
    
        LEAVE.
        
    END. /* Fim do DO TO */       
        
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".
        
    BUFFER-COPY cratsab 
    EXCEPT cratsab.cdcooper cratsab.nrdconta cratsab.nrinssac TO crapsab.
    
    RELEASE crapsab.

END PROCEDURE.

/*----------------------------------------------------------------------------*/

PROCEDURE exclui_sacado.

    DEF INPUT        PARAM TABLE FOR  cratsab.
    DEF OUTPUT       PARAM par_dscritic     AS CHAR.

    DEF VAR aux_contador AS INTE                NO-UNDO. 
    
    FIND FIRST cratsab NO-LOCK NO-ERROR.
    
    ASSIGN par_dscritic = "".
    
    DO aux_contador = 1 TO 10:
            
       FIND crapsab WHERE crapsab.cdcooper = cratsab.cdcooper AND
                          crapsab.nrdconta = cratsab.nrdconta AND
                          crapsab.nrinssac = cratsab.nrinssac 
                          EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                                       
       IF  NOT AVAILABLE crapsab  THEN
           DO:
              IF  LOCKED crapsab  THEN
                  DO:
                     ASSIGN par_dscritic = "Dados do Pagador estao sendo" +
                                           " alterados no momento.".
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                  END.
              ELSE
                  ASSIGN par_dscritic = "Pagador informado nao esta cadastrado.".           
           END.
                       
       LEAVE.
                       
    END. /** Fim do DO ... TO **/

    FIND FIRST crapcob WHERE crapcob.cdcooper = cratsab.cdcooper AND
                             crapcob.nrdconta = cratsab.nrdconta AND
                             crapcob.nrinssac = cratsab.nrinssac 
                             NO-LOCK NO-ERROR. 
                                      
    IF  AVAILABLE crapcob  THEN
        DO:
           ASSIGN par_dscritic = "O Pagador ja possui um boleto cadastrado. " +
                                 "Exclusao nao permitida.".
                    
        END.
    ELSE
        DELETE crapsab.   
                            
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".

    RELEASE crapsab.
END.      
/*----------------------------------------------------------------------------*/

/* b1crapsab.p */

/* .......................................................................... */

