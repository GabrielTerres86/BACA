/*..............................................................................

   Programa: b1crapcem.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                    Ultima atualizacao: 17/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Ayllos).
   Objetivo  : Tratar ALTERACAO, EXCLUSAO e INCLUSAO na tabela crapcem.

   Alteracoes: 22/03/2007 - Verificar se E-mail esta sendo utilizado para
                            envio de informativos na exclusao (Diego).
                            
               01/08/2007 - Controles para o e-mail de cobranca, nao deixar
                            excluir e alterar quando necessario (Evandro).
               
               17/12/2013 - Adicionado validate para tabela crapcem (Tiago).             
..............................................................................*/

DEF TEMP-TABLE cratcem NO-UNDO LIKE crapcem.


PROCEDURE inclui-registro:
    DEF  INPUT PARAM TABLE        FOR cratcem.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratcem EXCLUSIVE-LOCK.
    
    /* Verifica se o endereco ja foi cadastrado */
    FIND LAST crapcem WHERE crapcem.cdcooper = cratcem.cdcooper   AND
                            crapcem.nrdconta = cratcem.nrdconta   AND
                            crapcem.idseqttl = cratcem.idseqttl   AND
                            crapcem.dsdemail = cratcem.dsdemail
                            NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE crapcem   THEN
         DO:
             par_dscritic = "Endereco ja cadastrado para o titular.".
             RETURN "NOK".
         END.
         
    /* Verifica se ha "@" no e-mail */
    IF   NOT cratcem.dsdemail MATCHES "*@*"   THEN
         DO:
             par_dscritic = "Endereco de e_mail invalido!".
             RETURN "NOK".
         END.
         
    /* Pega o sequencial */
    FIND LAST crapcem WHERE crapcem.cdcooper = cratcem.cdcooper   AND
                            crapcem.nrdconta = cratcem.nrdconta   AND
                            crapcem.idseqttl = cratcem.idseqttl   
                            NO-LOCK NO-ERROR.
                            
    ASSIGN cratcem.cddemail = IF   AVAILABLE crapcem   THEN 
                                   crapcem.cddemail + 1
                              ELSE 1.
                                                   
    /* Cria o registro */
    CREATE crapcem.
    BUFFER-COPY cratcem TO crapcem.
    VALIDATE crapcem.

END PROCEDURE. /* inclui-registro */


PROCEDURE altera-registro:
    DEF  INPUT PARAM TABLE        FOR cratcem.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.

    FIND FIRST cratcem EXCLUSIVE-LOCK.
    
    /* Verifica se o endereco ja foi cadastrado */
    FIND LAST crapcem WHERE crapcem.cdcooper  = cratcem.cdcooper   AND
                            crapcem.nrdconta  = cratcem.nrdconta   AND
                            crapcem.idseqttl  = cratcem.idseqttl   AND
                            crapcem.dsdemail  = cratcem.dsdemail   AND
                            crapcem.cddemail <> cratcem.cddemail
                            NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE crapcem   THEN
         DO:
             par_dscritic = "Endereco ja cadastrado para o titular.".
             RETURN "NOK".
         END.
         
    /* Verifica se ha "@" no e-mail */
    IF   NOT cratcem.dsdemail MATCHES "*@*"   THEN
         DO:
             par_dscritic = "Endereco de e_mail invalido!".
             RETURN "NOK".
         END.
         
    /* Pega o registro do banco */
    FIND crapcem WHERE crapcem.cdcooper = cratcem.cdcooper   AND
                       crapcem.nrdconta = cratcem.nrdconta   AND
                       crapcem.idseqttl = cratcem.idseqttl   AND
                       crapcem.cddemail = cratcem.cddemail   EXCLUSIVE-LOCK.
                       
                       
    /* Se o e-mail alterado eh o mesmo e-mail usado para retorno de arquivo de
       cobranca, atualiza o e-mail de cobranca */
    FIND crapass WHERE crapass.cdcooper = cratcem.cdcooper   AND
                       crapass.nrdconta = cratcem.nrdconta
                       NO-LOCK NO-ERROR.
                          
    IF   NOT AVAILABLE crapass   THEN
         DO:
             par_dscritic = "Associado nao encontrado!".
             RETURN "NOK".
         END.
         
    IF   crapcem.dsdemail = crapass.dsdemail   THEN
         DO WHILE TRUE:
         
            FIND crapass WHERE crapass.cdcooper = cratcem.cdcooper   AND
                               crapass.nrdconta = cratcem.nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
            IF   NOT AVAILABLE crapass   AND
                 LOCKED(crapass)         THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
                 
            ASSIGN crapass.dsdemail = cratcem.dsdemail.
            LEAVE.
         END.
         
    /* Altera o registro */
    BUFFER-COPY cratcem TO crapcem.

END PROCEDURE. /* altera-registro */



PROCEDURE exclui-registro:
    DEF  INPUT PARAM TABLE        FOR cratcem.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratcem EXCLUSIVE-LOCK.
    
    /* Pega o registro do banco */
    FIND crapcem WHERE crapcem.cdcooper = cratcem.cdcooper   AND
                       crapcem.nrdconta = cratcem.nrdconta   AND
                       crapcem.idseqttl = cratcem.idseqttl   AND
                       crapcem.cddemail = cratcem.cddemail   
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapcem   THEN
         DO:
             par_dscritic = "Registro nao encontrado.".
             RETURN "NOK".
         END.
                       
    /* Verifica se email esta sendo utilizado para envio de informativo */
    FIND FIRST crapcra WHERE crapcra.cdcooper = cratcem.cdcooper  AND
                             crapcra.nrdconta = cratcem.nrdconta  AND
                             crapcra.idseqttl = cratcem.idseqttl  AND
                             crapcra.cdseqinc = cratcem.cddemail
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapcra  THEN
         DO:
             par_dscritic = 
                 "Existem informativos cadastrados com esta informacao.".
                 RETURN "NOK".
         END.
    
    /* Se o e-mail a ser excluido eh o mesmo e-mail usado para retorno de
       arquivo de cobranca. Nao pode ser excluido */
    FIND crapass WHERE crapass.cdcooper = cratcem.cdcooper   AND
                       crapass.nrdconta = cratcem.nrdconta
                       NO-LOCK NO-ERROR.
                          
    IF   NOT AVAILABLE crapass   THEN
         DO:
             par_dscritic = "Associado nao encontrado!".
             RETURN "NOK".
         END.
         
    IF   crapcem.dsdemail = crapass.dsdemail   THEN
         DO:
             par_dscritic = "E-mail usado para retorno de arquivo de " +
                            "cobranca. Impossivel excluir!".
             RETURN "NOK".
         END.
     
    DELETE crapcem.

END PROCEDURE. /* exclui-registro */

/*............................................................................*/
