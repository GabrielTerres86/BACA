/*..............................................................................

   Programa: b1crapsnh.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2006                    Ultima atualizacao: 17/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Ayllos/Internet).
   Objetivo  : Tratar ALTERACAO, EXCLUSAO e INCLUSAO na tabela crapsnh.

   Alteracoes: 17/12/2013 - Adicionado validate para tabela crapsnh (Tiago).

..............................................................................*/

DEF TEMP-TABLE cratsnh NO-UNDO LIKE crapsnh.


PROCEDURE inclui-registro:
    DEF  INPUT PARAM TABLE        FOR cratsnh.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratsnh EXCLUSIVE-LOCK.
    
    /* Verifica se a senha ja foi cadastrada */
    FIND crapsnh WHERE crapsnh.cdcooper = cratsnh.cdcooper   AND
                       crapsnh.nrdconta = cratsnh.nrdconta   AND
                       crapsnh.tpdsenha = cratsnh.tpdsenha   AND
                       crapsnh.idseqttl = cratsnh.idseqttl   NO-LOCK NO-ERROR.

    IF   AVAILABLE crapsnh   THEN
         DO:
             par_dscritic = "Senha ja cadastrada para o titular.".
             RETURN "NOK".
         END.
         
    /* Cria o registro */
    CREATE crapsnh.
    BUFFER-COPY cratsnh TO crapsnh.
    VALIDATE crapsnh.

END PROCEDURE. /* inclui-registro */


PROCEDURE altera-registro:
    DEF  INPUT PARAM TABLE        FOR cratsnh.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.

    FIND FIRST cratsnh EXCLUSIVE-LOCK.
    
    /* Pega o registro do banco */
    FIND crapsnh WHERE crapsnh.cdcooper = cratsnh.cdcooper   AND
                       crapsnh.nrdconta = cratsnh.nrdconta   AND
                       crapsnh.tpdsenha = cratsnh.tpdsenha   AND
                       crapsnh.idseqttl = cratsnh.idseqttl   EXCLUSIVE-LOCK.
      
    /* Altera o registro */
    BUFFER-COPY cratsnh TO crapsnh.

END PROCEDURE. /* altera-registro */



PROCEDURE exclui-registro:
    DEF  INPUT PARAM TABLE        FOR cratsnh.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratsnh EXCLUSIVE-LOCK.
    
    /* Pega o registro do banco */
    FIND crapsnh WHERE crapsnh.cdcooper = cratsnh.cdcooper   AND
                       crapsnh.nrdconta = cratsnh.nrdconta   AND
                       crapsnh.tpdsenha = cratsnh.tpdsenha   AND
                       crapsnh.idseqttl = cratsnh.idseqttl   EXCLUSIVE-LOCK.
                       
    IF   NOT AVAILABLE crapsnh   THEN
         DO:
             par_dscritic = "Registro nao encontrado.".
             RETURN "NOK".
         END.
                       
    DELETE crapsnh.

END PROCEDURE. /* exclui-registro */

/*............................................................................*/
