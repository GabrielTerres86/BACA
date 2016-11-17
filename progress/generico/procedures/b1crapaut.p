/*..............................................................................

   Programa: b1crapaut.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2007                    Ultima atualizacao: 17/12/2013    

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Tratar INCLUSAO,ALTERACAO,EXCLUSAO na tabela crapaut.

   Alteracoes: 20/05/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).
                            
               17/12/2013 - Adicionado validate para tabela crapaut (Tiago).
..............................................................................*/

DEF TEMP-TABLE crataut NO-UNDO LIKE crapaut.

PROCEDURE inclui-registro:

    DEF INPUT  PARAM TABLE         FOR crataut.
    DEF OUTPUT PARAM par_dscritic  AS CHAR                          NO-UNDO.
    
    FIND FIRST crataut NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crataut  THEN
        DO:
            par_dscritic = "Registro para exclusao (crapaut) nao encontrado.".
            RETURN "NOK".
        END.
        
    FIND crapaut WHERE crapaut.cdcooper = crataut.cdcooper AND
                       crapaut.cdagenci = crataut.cdagenci AND
                       crapaut.nrdcaixa = crataut.nrdcaixa AND
                       crapaut.dtmvtolt = crataut.dtmvtolt AND
                       crapaut.nrsequen = crataut.nrsequen
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE crapaut   THEN
        DO:
            par_dscritic = "Autenticacao ja cadastrada.".
            RETURN "NOK".
        END.
         
    CREATE crapaut.
    BUFFER-COPY crataut TO crapaut.
    VALIDATE crapaut.

    RETURN "OK".
    
END PROCEDURE. 

PROCEDURE altera-registro:

    DEF  INPUT  PARAM TABLE       FOR crataut.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FIND FIRST crataut NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crataut  THEN
        DO:
            par_dscritic = "Registro para alteracao (crapaut) nao encontrado.".
            RETURN "NOK".
        END.
        
    DO aux_contador = 1 TO 10:
    
        par_dscritic = "".
        
        FIND crapaut WHERE crapaut.cdcooper = crataut.cdcooper AND
                           crapaut.cdagenci = crataut.cdagenci AND
                           crapaut.nrdcaixa = crataut.nrdcaixa AND
                           crapaut.dtmvtolt = crataut.dtmvtolt AND
                           crapaut.nrsequen = crataut.nrsequen 
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
        IF  NOT AVAILABLE crapaut  THEN
            DO:
                IF  LOCKED crapaut  THEN
                    DO:
                        par_dscritic = "Autenticacao ja esta sendo alterada. " +
                                       "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.    
                ELSE
                    par_dscritic = "Autenticacao nao encontrada.".                    
            END.
    
        LEAVE.
        
    END. /* Fim do DO ... TO */
    
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".                          

    BUFFER-COPY crataut TO crapaut.
    
    RELEASE crapaut NO-ERROR.
    
    RETURN "OK".
    
END PROCEDURE.
 
PROCEDURE exclui-registro:

    DEF INPUT  PARAM TABLE        FOR crataut.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FIND FIRST crataut NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crataut  THEN
        DO:
            par_dscritic = "Registro para exclusao (crapaut) nao encontrado.".
            RETURN "NOK".
        END.
        
    DO aux_contador = 1 TO 10:
    
        par_dscritic = "".
    
        FIND crapaut WHERE crapaut.cdcooper = crataut.cdcooper AND
                           crapaut.cdagenci = crataut.cdagenci AND
                           crapaut.nrdcaixa = crataut.nrdcaixa AND
                           crapaut.dtmvtolt = crataut.dtmvtolt AND
                           crapaut.nrsequen = crataut.nrsequen
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
        IF  NOT AVAILABLE crapaut  THEN
            DO:
                IF  LOCKED crapaut  THEN
                    DO:
                        par_dscritic = "Autenticacao ja esta sendo alterada. " +
                                       "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.    
                ELSE
                    par_dscritic = "Autenticacao nao encontrada.".                    
            END.
    
        LEAVE.
        
    END. /* Fim do DO ... TO */        
    
    IF  par_dscritic <> ""  THEN
        RETURN "NOK". 

    DELETE crapaut.
    
    RETURN "OK".
    
END PROCEDURE.

/*............................................................................*/
