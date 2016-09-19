/*..............................................................................

   Programa: b1crapbcx.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2007                    Ultima atualizacao: 17/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Tratar INCLUSAO na tabela crapbcx.

   Alteracoes: 17/12/2013 - Adicionado validate para tabela crapbcx (Tiago).

..............................................................................*/

DEF TEMP-TABLE cratbcx NO-UNDO LIKE crapbcx.


PROCEDURE inclui-registro:
    DEF INPUT  PARAM TABLE         FOR cratbcx.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratbcx EXCLUSIVE-LOCK.
    
    /* Verifica se o banco caixa ja foi cadastrada */
    FIND crapbcx WHERE crapbcx.cdcooper = cratbcx.cdcooper   AND
                       crapbcx.dtmvtolt = cratbcx.dtmvtolt   AND
                       crapbcx.cdagenci = cratbcx.cdagenci   AND
                       crapbcx.nrdcaixa = cratbcx.nrdcaixa   AND
                       crapbcx.nrseqdig = cratbcx.nrseqdig
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE crapbcx   THEN
         DO:
             par_dscritic = "Banco Caixa ja cadastrado.".
             RETURN "NOK".
         END.
         
    /* Cria o registro */
    CREATE crapbcx.
    BUFFER-COPY cratbcx TO crapbcx.
    VALIDATE crapbcx.

END PROCEDURE. /* inclui-registro */

/*............................................................................*/
