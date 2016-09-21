/*.............................................................................

   Programa: b1crapbem.p
   Sistema : Conta-Corrente - Cooperativa de Credito.
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2009

   Dados referentes ao programa:
   
   Frequencia: Diario(Ayllos).
   Objetivo  : Tratar ALTERACAO, EXCLUSAO e INCLUSAO da tabela crapbem
               (Bens do associado).
   
   Alteracoes:

..............................................................................*/

DEF TEMP-TABLE cratbem NO-UNDO LIKE crapbem.


PROCEDURE inclui-registro:

    DEF  INPUT PARAM TABLE FOR cratbem.
    DEF OUTPUT PARAM par_idseqbem AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                         NO-UNDO.


    FIND FIRST cratbem EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    
    IF   NOT AVAILABLE cratbem   THEN
         DO:
             par_dscritic = "Registro p/ inclusao (crapbem) nao encontrado.".
             RETURN "NOK".
         END.


         /* Verifica se o bem ja foi cadastrado */
    FIND LAST crapbem WHERE crapbem.cdcooper = cratbem.cdcooper   AND
                            crapbem.nrdconta = cratbem.nrdconta   AND
                            crapbem.idseqttl = cratbem.idseqttl   AND
                            crapbem.dsrelbem = cratbem.dsrelbem 
                            NO-LOCK NO-ERROR.

    IF   AVAILABLE crapbem   THEN
         DO:
             par_dscritic = "Este bem ja foi cadastrado para o titular.".
             RETURN "NOK".
         END.


    /* Pega o ultimo na sequencia do titular */
    FIND LAST crapbem WHERE crapbem.cdcooper = cratbem.cdcooper   AND
                            crapbem.nrdconta = cratbem.nrdconta   AND
                            crapbem.idseqttl = cratbem.idseqttl  
                            NO-LOCK NO-ERROR.

    ASSIGN cratbem.idseqbem = IF   AVAILABLE crapbem   THEN
                                   crapbem.idseqbem + 1
                              ELSE
                                   1
                                   
           par_idseqbem     = cratbem.idseqbem. 
    

    CREATE crapbem.
    
    BUFFER-COPY cratbem TO crapbem.
    
    RETURN "OK".
   
    
END PROCEDURE. /* Procedure de inclusao de registro */


PROCEDURE altera-registro:

    DEF  INPUT PARAM TABLE FOR cratbem.
    DEF OUTPUT PARAM par_dscritic AS CHAR                         NO-UNDO.

    DEF VAR          aux_contador AS INTE                         NO-UNDO.
    

    FIND FIRST cratbem NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE cratbem   THEN
         DO:
             par_dscritic = "Registro p/ alteracao (crapbem) nao encontrado.".
             RETURN "NOK".
         END.

    /* Verifica se o bem ja foi cadastrado */
    FIND LAST crapbem WHERE crapbem.cdcooper = cratbem.cdcooper    AND
                            crapbem.nrdconta = cratbem.nrdconta    AND
                            crapbem.idseqttl = cratbem.idseqttl    AND
                            crapbem.dsrelbem = cratbem.dsrelbem    AND
                            crapbem.idseqbem <> cratbem.idseqbem   
                            NO-LOCK NO-ERROR.

    IF   AVAILABLE crapbem   THEN
         DO:
             par_dscritic = "Este bem ja foi cadastrado para o titular.".
             RETURN "NOK".
         END.

    DO aux_contador = 1 TO 10:
    
        FIND crapbem WHERE crapbem.cdcooper = cratbem.cdcooper   AND
                           crapbem.nrdconta = cratbem.nrdconta   AND
                           crapbem.idseqttl = cratbem.idseqttl   AND
                           crapbem.idseqbem = cratbem.idseqbem   
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF  NOT AVAILABLE crapbem   THEN
            DO:
                IF   LOCKED crapbem  THEN
                     DO:
                         par_dscritic = "Registro do bem ja esta sendo " + 
                                        "alterado.".
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         par_dscritic = "Registro do bem nao foi encontrado.".
                         LEAVE.
                     END.
            END.
        
        par_dscritic = "".
        LEAVE.
        
    END. /* Fim do DO ... TO */

    IF   par_dscritic <> ""   THEN
         RETURN "NOK".
    
    BUFFER-COPY cratbem TO crapbem.
        
    RELEASE crapbem NO-ERROR.    
        
    RETURN "OK".

END PROCEDURE.


PROCEDURE exclui-registro:

    DEF  INPUT PARAM TABLE FOR cratbem.
    DEF OUTPUT PARAM par_dscritic AS CHAR                         NO-UNDO.
    
    DEF VAR          aux_contador AS INTE                         NO-UNDO.
    

    FIND FIRST cratbem NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE cratbem   THEN
         DO:
             par_dscritic = "Registro p/ exclusao (crapbem) nao encontrado.".
             RETURN "NOK".
         END.
    
    DO aux_contador = 1 TO 10:
    
       FIND crapbem WHERE crapbem.cdcooper = cratbem.cdcooper   AND
                          crapbem.nrdconta = cratbem.nrdconta   AND
                          crapbem.idseqttl = cratbem.idseqttl   AND
                          crapbem.idseqbem = cratbem.idseqbem   
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
       IF  NOT AVAILABLE crapbem   THEN
           DO:
               IF   LOCKED crapbem  THEN
                    DO:
                        par_dscritic = "Registro do bem ja esta sendo " + 
                                       "alterado.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        par_dscritic = "Registro do bem nao foi encontrado.".
                        LEAVE.
                    END.
           END.
        
       par_dscritic = "".
       LEAVE.
        
    END. /* Fim do DO ... TO */

    IF   par_dscritic <> ""   THEN
         RETURN "NOK".
    
    DELETE crapbem.     

    RETURN "OK".

END PROCEDURE.


/*............................................................................*/
