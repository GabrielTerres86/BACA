/*..............................................................................

   Programa: b1craplcm.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2007                    Ultima atualizacao: 31/05/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Tratar INCLUSAO na tabela craplcm.

   Alteracoes: 17/12/2013 - Adicionado validate para tabela craplcm (Tiago).
            
               07/12/2015 - Adicionada verificação pelo index craplcm1 (Lunelli SD 327199).

			   31/05/2016 - Adicionado tratamento de erro para quando estourar
			               chave da CRAPLCM##3 retornar critica corretamente
						   (Tiago/Elton SD391162);
..............................................................................*/

DEF TEMP-TABLE cratlcm NO-UNDO LIKE craplcm.


PROCEDURE inclui-registro:
    DEF INPUT  PARAM TABLE         FOR cratlcm.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratlcm EXCLUSIVE-LOCK.
    
    /* Verifica se o lancamento ja foi cadastrado (craplcm1) */
    FIND craplcm WHERE craplcm.cdcooper = cratlcm.cdcooper   AND
                       craplcm.dtmvtolt = cratlcm.dtmvtolt   AND
                       craplcm.cdagenci = cratlcm.cdagenci   AND
                       craplcm.cdbccxlt = cratlcm.cdbccxlt   AND
                       craplcm.nrdolote = cratlcm.nrdolote   AND
                       craplcm.nrdctabb = cratlcm.nrdctabb   AND
                       craplcm.nrdocmto = cratlcm.nrdocmto
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE craplcm   THEN
         DO:
             par_dscritic = "Lancamento ja cadastrado (01).".
             RETURN "NOK".
         END.

    /* Verifica se o lancamento ja foi cadastrado (craplcm3) */
    FIND craplcm WHERE craplcm.cdcooper = cratlcm.cdcooper   AND
                       craplcm.dtmvtolt = cratlcm.dtmvtolt   AND
                       craplcm.cdagenci = cratlcm.cdagenci   AND
                       craplcm.cdbccxlt = cratlcm.cdbccxlt   AND
                       craplcm.nrdolote = cratlcm.nrdolote   AND
                       craplcm.nrseqdig = cratlcm.nrseqdig
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE craplcm   THEN
         DO:
             par_dscritic = "Lancamento ja cadastrado (02).".
             RETURN "NOK".                             
         END.
         
    /* Cria o registro */
    CREATE craplcm.
    BUFFER-COPY cratlcm TO craplcm.
    VALIDATE craplcm.

    /*Bloco para tratamento de erro do create da lcm try catch*/
    CATCH eSysError AS Progress.Lang.SysError:
      /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
      /*Definindo minha propria critica*/
      par_dscritic = "Transferencia nao efetivada, tente novamente (03).".
      RETURN "NOK".
    END CATCH.

END PROCEDURE. /* inclui-registro */

PROCEDURE exclui-registro:
    DEF INPUT  PARAM TABLE         FOR cratlcm.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    FIND FIRST cratlcm EXCLUSIVE-LOCK.
    
    /* Verifica se o lancamento existe */
    FIND craplcm WHERE craplcm.cdcooper = cratlcm.cdcooper   AND
                       craplcm.dtmvtolt = cratlcm.dtmvtolt   AND
                       craplcm.cdagenci = cratlcm.cdagenci   AND
                       craplcm.cdbccxlt = cratlcm.cdbccxlt   AND
                       craplcm.nrdolote = cratlcm.nrdolote   AND
                       craplcm.nrseqdig = cratlcm.nrseqdig
                       EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplcm   THEN
         DO:
             par_dscritic = "Lancamento nao cadastrado.".
             RETURN "NOK".
         END.

    /* Cria o registro */
    DELETE craplcm.
    
END PROCEDURE. /* exclui-registro */


/*............................................................................*/
