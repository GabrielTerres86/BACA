/*..............................................................................

   Programa: b1crapenc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                    Ultima atualizacao: 17/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Ayllos).
   Objetivo  : Tratar ALTERACAO, EXCLUSAO e INCLUSAO na tabela crapenc.

   Alteracoes: 17/12/2013 - Adicionado validate para tabela crapenc (Tiago).

..............................................................................*/

DEF TEMP-TABLE cratenc NO-UNDO LIKE crapenc.


PROCEDURE inclui-registro:
    DEF  INPUT PARAM TABLE        FOR cratenc.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratenc EXCLUSIVE-LOCK.
    
    /* Verifica se o endereco ja foi cadastrado */
    FIND LAST crapenc WHERE crapenc.cdcooper = cratenc.cdcooper   AND
                            crapenc.nrdconta = cratenc.nrdconta   AND
                            crapenc.idseqttl = cratenc.idseqttl   AND
                            crapenc.tpendass = cratenc.tpendass   AND
                            crapenc.dsendere = cratenc.dsendere   AND
                            crapenc.nrendere = cratenc.nrendere
                            NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE crapenc   THEN
         DO:
             par_dscritic = "Endereco ja cadastrado para o titular.".
             RETURN "NOK".
         END.
         
         
    /* Pega o sequencial */
    FIND LAST crapenc WHERE crapenc.cdcooper = cratenc.cdcooper   AND
                            crapenc.nrdconta = cratenc.nrdconta   AND
                            crapenc.idseqttl = cratenc.idseqttl   
                            NO-LOCK NO-ERROR.
                            
    ASSIGN cratenc.cdseqinc = IF   AVAILABLE crapenc   THEN 
                                   crapenc.cdseqinc + 1
                              ELSE 1.
                                                   
    /* Cria o registro */
    CREATE crapenc.
    BUFFER-COPY cratenc TO crapenc.
    VALIDATE crapenc.

END PROCEDURE. /* inclui-registro */


PROCEDURE altera-registro:
    DEF  INPUT PARAM TABLE        FOR cratenc.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratenc EXCLUSIVE-LOCK.
    
    /* Verifica se o endereco ja foi cadastrado */
    FIND LAST crapenc WHERE crapenc.cdcooper  = cratenc.cdcooper   AND
                            crapenc.nrdconta  = cratenc.nrdconta   AND
                            crapenc.idseqttl  = cratenc.idseqttl   AND
                            crapenc.tpendass  = cratenc.tpendass   AND
                            crapenc.dsendere  = cratenc.dsendere   AND
                            crapenc.nrendere  = cratenc.nrendere   AND
                            crapenc.cdseqinc <> cratenc.cdseqinc
                            NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE crapenc   THEN
         DO:
             par_dscritic = "Endereco ja cadastrado para o titular.".
             RETURN "NOK".
         END.
         
    /* Pega o registro do banco */
    FIND crapenc WHERE crapenc.cdcooper = cratenc.cdcooper   AND
                       crapenc.nrdconta = cratenc.nrdconta   AND
                       crapenc.idseqttl = cratenc.idseqttl   AND
                       crapenc.cdseqinc = cratenc.cdseqinc   EXCLUSIVE-LOCK.
      
    /* Altera o registro */
    BUFFER-COPY cratenc TO crapenc.

END PROCEDURE. /* altera-registro */



PROCEDURE exclui-registro:
    DEF  INPUT PARAM TABLE        FOR cratenc.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratenc EXCLUSIVE-LOCK.
    
    /* Pega o registro do banco */
    FIND crapenc WHERE crapenc.cdcooper = cratenc.cdcooper   AND
                       crapenc.nrdconta = cratenc.nrdconta   AND
                       crapenc.idseqttl = cratenc.idseqttl   AND
                       crapenc.cdseqinc = cratenc.cdseqinc   
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapenc   THEN
         DO:
             par_dscritic = "Registro nao encontrado.".
             RETURN "NOK".
         END.
                       
    DELETE crapenc.

END PROCEDURE. /* exclui-registro */

/*............................................................................*/
