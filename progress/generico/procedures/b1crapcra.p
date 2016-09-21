/*..............................................................................

   Programa: b1crapcra.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Marco/2007                    Ultima atualizacao: 17/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Ayllos).
   Objetivo  : Tratar ALTERACAO, EXCLUSAO e INCLUSAO na tabela crapcra.

   Alteracoes: 17/12/2013 - Adicionado validate para tabela crapcra (Tiago).

..............................................................................*/

DEF TEMP-TABLE cratcra NO-UNDO LIKE crapcra.

DEF BUFFER crabcra FOR crapcra.


PROCEDURE inclui-registro:

    DEF  INPUT PARAM TABLE        FOR cratcra.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratcra EXCLUSIVE-LOCK.
    
    
    /* Verifica se o informativo ja foi solicitado */
    FIND crapcra WHERE crapcra.cdcooper = cratcra.cdcooper   AND
                       crapcra.nrdconta = cratcra.nrdconta   AND
                       crapcra.idseqttl = cratcra.idseqttl   AND
                       crapcra.cdrelato = cratcra.cdrelato   AND
                       crapcra.cdprogra = cratcra.cdprogra   AND
                       crapcra.cddfrenv = cratcra.cddfrenv   AND
                       crapcra.cdseqinc = cratcra.cdseqinc   AND
                       crapcra.cdselimp = cratcra.cdselimp
                       NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE crapcra   THEN
         DO:
             par_dscritic =
                "Informativo com forma de envio e recebimento ja cadastrados.".
             RETURN "NOK".
         END.
         
    /* Cria o registro */
    CREATE crapcra.
    BUFFER-COPY cratcra TO crapcra.
    VALIDATE crapcra.

END PROCEDURE. /* inclui-registro */


PROCEDURE altera-registro:
    
    DEF  INPUT PARAM TABLE        FOR cratcra.
    DEF  INPUT PARAM par_cdseqinc  AS INT            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.

    FIND FIRST cratcra EXCLUSIVE-LOCK.
    
    /* Le registro ATUAL do banco */ 
    FIND crapcra WHERE crapcra.cdcooper = cratcra.cdcooper  AND
                       crapcra.nrdconta = cratcra.nrdconta  AND
                       crapcra.idseqttl = cratcra.idseqttl  AND
                       crapcra.cdrelato = cratcra.cdrelato  AND
                       crapcra.cdprogra = cratcra.cdprogra  AND
                       crapcra.cddfrenv = cratcra.cddfrenv  AND
                       crapcra.cdseqinc = cratcra.cdseqinc  AND
                       crapcra.cdselimp = cratcra.cdselimp
                       EXCLUSIVE-LOCK NO-ERROR.
                                          
    IF   crapcra.cdseqinc <> par_cdseqinc  THEN
         DO: 
             FIND crabcra WHERE crabcra.cdcooper = cratcra.cdcooper  AND
                                crabcra.nrdconta = cratcra.nrdconta  AND
                                crabcra.idseqttl = cratcra.idseqttl  AND
                                crabcra.cdrelato = cratcra.cdrelato  AND
                                crabcra.cdprogra = cratcra.cdprogra  AND
                                crabcra.cddfrenv = cratcra.cddfrenv  AND
                                crabcra.cdseqinc = par_cdseqinc      AND
                                crabcra.cdselimp = cratcra.cdselimp
                                NO-LOCK NO-ERROR.
                                         
             IF   AVAIL crabcra  THEN
                  DO:
                      par_dscritic = 
                   "Local de Recebimento ja cadastrado para este informativo".
                      RETURN "NOK".                  
                  END.
             ELSE
                  DO:
                       ASSIGN crapcra.cdseqinc = par_cdseqinc.
                       
                       IF   crapcra.cdperiod <> cratcra.cdperiod  THEN
                            ASSIGN crapcra.cdperiod = cratcra.cdperiod.
                  END.
         END.
    ELSE
         IF   crapcra.cdperiod <> cratcra.cdperiod  THEN
              ASSIGN crapcra.cdperiod = cratcra.cdperiod.

END PROCEDURE. /* altera-registro */


PROCEDURE exclui-registro:
    
    DEF  INPUT PARAM TABLE        FOR cratcra.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratcra EXCLUSIVE-LOCK.
    
    /* Pega o registro do banco */
    FIND crapcra WHERE crapcra.cdcooper = cratcra.cdcooper   AND
                       crapcra.nrdconta = cratcra.nrdconta   AND
                       crapcra.idseqttl = cratcra.idseqttl   AND
                       crapcra.cdrelato = cratcra.cdrelato   AND
                       crapcra.cdprogra = cratcra.cdprogra   AND
                       crapcra.cddfrenv = cratcra.cddfrenv   AND
                       crapcra.cdseqinc = cratcra.cdseqinc   AND
                       crapcra.cdselimp = cratcra.cdselimp
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapcra   THEN
         DO: 
             par_dscritic = "Registro nao encontrado.".
             RETURN "NOK".
         END.
                       
    DELETE crapcra.
    
END PROCEDURE. /* exclui-registro */

/*............................................................................*/
