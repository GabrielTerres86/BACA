/*..............................................................................

   Programa: b1crapmvi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007                    Ultima atualizacao: 17/12/2013       

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Tratar ALTERACAO,INCLUSAO,EXCLUSAO na tabela crapmvi.

   Alteracoes: 20/05/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).

               17/12/2013 - Adicionado validate para tabela crapmvi (Tiago).
..............................................................................*/

DEF TEMP-TABLE cratmvi NO-UNDO LIKE crapmvi.

PROCEDURE inclui-registro:

    DEF INPUT  PARAM TABLE        FOR cratmvi.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    FIND FIRST cratmvi NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE cratmvi  THEN
        DO:
            par_dscritic = "Registro para inclusao (crapmvi) nao encontrado.".
            RETURN "NOK".
        END.
        
    FIND crapmvi WHERE crapmvi.cdcooper = cratmvi.cdcooper AND
                       crapmvi.nrdconta = cratmvi.nrdconta AND
                       crapmvi.idseqttl = cratmvi.idseqttl AND
                       crapmvi.dtmvtolt = cratmvi.dtmvtolt AND
                       crapmvi.hrtransa = cratmvi.hrtransa NO-LOCK NO-ERROR.

    IF  AVAILABLE crapmvi  THEN
        DO:
            par_dscritic = "Movimento da web ja cadastrado.".
            RETURN "NOK".
        END.
         
    CREATE crapmvi.
    BUFFER-COPY cratmvi TO crapmvi.
    VALIDATE crapmvi.

    RETURN "OK".

END PROCEDURE. 

PROCEDURE altera-registro:

    DEF INPUT  PARAM TABLE        FOR cratmvi.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FIND FIRST cratmvi NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE cratmvi  THEN
        DO:
            par_dscritic = "Registro para alteracao (crapmvi) nao encontrado.".
            RETURN "NOK".
        END.
        
    DO aux_contador = 1 TO 10:
    
        par_dscritic = "".
    
        FIND crapmvi WHERE crapmvi.cdcooper = cratmvi.cdcooper AND
                           crapmvi.nrdconta = cratmvi.nrdconta AND
                           crapmvi.idseqttl = cratmvi.idseqttl AND
                           crapmvi.dtmvtolt = cratmvi.dtmvtolt 
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
        IF  NOT AVAILABLE crapmvi  THEN
            DO:
                IF  LOCKED(crapmvi)  THEN
                    DO:
                        par_dscritic = "Movimento ja esta sendo alterada. " +
                                       "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.    
                ELSE
                    par_dscritic = "Movimento nao encontrado.".                    
            END.
    
        LEAVE.
        
    END. /* Fim do DO ... TO */
    
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".                           

    BUFFER-COPY cratmvi TO crapmvi.
    
    RELEASE crapmvi.
    
    RETURN "OK".
    
END PROCEDURE.
 
PROCEDURE exclui-registro:

    DEF INPUT  PARAM TABLE        FOR cratmvi.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FIND FIRST cratmvi NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE cratmvi  THEN
        DO:
            par_dscritic = "Registro para exclusao (crapmvi) nao encontrado.".
            RETURN "NOK".
        END.
        
    DO aux_contador = 1 TO 10:
    
        par_dscritic = "".
    
        FIND crapmvi WHERE crapmvi.cdcooper = cratmvi.cdcooper AND
                           crapmvi.nrdconta = cratmvi.nrdconta AND
                           crapmvi.idseqttl = cratmvi.idseqttl AND
                           crapmvi.dtmvtolt = cratmvi.dtmvtolt 
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
        IF  NOT AVAILABLE crapmvi  THEN
            DO:
                IF  LOCKED(crapmvi)  THEN
                    DO:
                        par_dscritic = "Movimento ja esta sendo alterada. " +
                                       "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.    
                ELSE
                    par_dscritic = "Movimento nao encontrado.".                    
            END.
    
        LEAVE.
        
    END. /* Fim do DO ... TO */
    
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".                           

    DELETE crapmvi.
    
    RETURN "OK".
    
END PROCEDURE.

/*............................................................................*/
