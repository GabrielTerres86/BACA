/*..............................................................................

   Programa: b1craptfc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                    Ultima atualizacao: 17/12/2013    

   Dados referentes ao programa:

   Frequencia: Diario (Ayllos).
   Objetivo  : Tratar ALTERACAO, EXCLUSAO e INCLUSAO na tabela craptfc.

   Alteracoes: 22/03/2007 - Verificar se Telefone esta sendo utilizado para
                            envio de informativos na exclusao (Diego).
                     
               17/12/2013 - Adicionado validate para tabela craptfc (Tiago).
..............................................................................*/

DEF TEMP-TABLE crattfc NO-UNDO LIKE craptfc.


PROCEDURE inclui-registro:
    DEF  INPUT PARAM TABLE        FOR crattfc.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST crattfc EXCLUSIVE-LOCK.
    
    /* Verifica se o telefone ja foi cadastrado */
    FIND LAST craptfc WHERE craptfc.cdcooper = crattfc.cdcooper   AND
                            craptfc.nrdconta = crattfc.nrdconta   AND
                            craptfc.idseqttl = crattfc.idseqttl   AND
                            craptfc.nrtelefo = crattfc.nrtelefo   AND
                            craptfc.nrdramal = crattfc.nrdramal 
                            NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE craptfc   THEN
         DO:
             par_dscritic = "Telefone ja cadastrado para o titular.".
             RETURN "NOK".
         END.
         
    /* Pega o sequencial */
    FIND LAST craptfc WHERE craptfc.cdcooper = crattfc.cdcooper   AND
                            craptfc.nrdconta = crattfc.nrdconta   AND
                            craptfc.idseqttl = crattfc.idseqttl
                            NO-LOCK NO-ERROR.
                            
    ASSIGN crattfc.cdseqtfc = IF   AVAILABLE craptfc   THEN 
                                   craptfc.cdseqtfc + 1
                              ELSE 1.
                                                   
    /* Cria o registro */
    CREATE craptfc.
    BUFFER-COPY crattfc TO craptfc.
    VALIDATE craptfc.

END PROCEDURE. /* inclui-registro */


PROCEDURE altera-registro:
    DEF  INPUT PARAM TABLE        FOR crattfc.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST crattfc EXCLUSIVE-LOCK.
    
    /* Verifica se o telefone ja foi cadastrado */
    FIND LAST craptfc WHERE craptfc.cdcooper  = crattfc.cdcooper   AND
                            craptfc.nrdconta  = crattfc.nrdconta   AND
                            craptfc.idseqttl  = crattfc.idseqttl   AND
                            craptfc.nrtelefo  = crattfc.nrtelefo   AND
                            craptfc.nrdramal  = crattfc.nrdramal   AND
                            craptfc.cdseqtfc <> crattfc.cdseqtfc
                            NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE craptfc   THEN
         DO:
             par_dscritic = "Telefone ja cadastrado para o titular.".
             RETURN "NOK".
         END.
         
    /* Pega o registro do banco */
    FIND craptfc WHERE craptfc.cdcooper = crattfc.cdcooper   AND
                       craptfc.nrdconta = crattfc.nrdconta   AND
                       craptfc.idseqttl = crattfc.idseqttl   AND
                       craptfc.cdseqtfc = crattfc.cdseqtfc   EXCLUSIVE-LOCK.
      
    /* Altera o registro */
    BUFFER-COPY crattfc TO craptfc.

END PROCEDURE. /* altera-registro */



PROCEDURE exclui-registro:
    DEF  INPUT PARAM TABLE        FOR crattfc.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST crattfc EXCLUSIVE-LOCK.
    
    /* Pega o registro do banco */
    FIND craptfc WHERE craptfc.cdcooper = crattfc.cdcooper   AND
                       craptfc.nrdconta = crattfc.nrdconta   AND
                       craptfc.idseqttl = crattfc.idseqttl   AND
                       craptfc.cdseqtfc = crattfc.cdseqtfc   
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE craptfc   THEN
         DO:
             par_dscritic = "Registro nao encontrado.".
             RETURN "NOK".
         END.
         
    /* Verifica se telefone esta sendo utilizado p/ envio de informativo */
    FIND FIRST crapcra WHERE crapcra.cdcooper = crattfc.cdcooper  AND
                             crapcra.nrdconta = crattfc.nrdconta  AND
                             crapcra.idseqttl = crattfc.idseqttl  AND
                             crapcra.cdseqinc = crattfc.cdseqtfc
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapcra  THEN
         DO:
             par_dscritic = 
                 "Existem informativos cadastrados com esta informacao.".
                 RETURN "NOK".
         END.
                       
    DELETE craptfc.

END PROCEDURE. /* exclui-registro */

/*............................................................................*/
