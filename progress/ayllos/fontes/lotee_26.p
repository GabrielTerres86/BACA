/* .............................................................................

   Programa: Fontes/lotee_26.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2004.                       Ultima atualizacao: 02/02/2006

   Dados referentes ao programa:

   Frequencia: Sempre que chamado pela rotina de exclusao de lotes (on-line).
   Objetivo  : Exclusao do bordero de cheques descontados.

   Alteracoes: 13/09/2004 - Excluir o craplau dos cheques descontados (Edson).

               20/09/2005 - Alterado para fazer leitura tbm do codigo da
                            cooperativa na tabela crapabc (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
............................................................................. */

DEF  INPUT PARAM par_nrborder AS INTEGER                            NO-UNDO.

DEF VAR aux_nrdocmto AS INT                                         NO-UNDO.

{ includes/var_online.i }

DO WHILE TRUE:

   FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper   AND
                      crapbdc.nrborder = par_nrborder 
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
   IF   NOT AVAILABLE crapbdc   THEN
        IF   LOCKED crapbdc   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 MESSAGE "Bordero nao encontrado.".
                 glb_cdcritic = 79.
                 RETURN.
             END.
                  
   IF   crapbdc.insitbdc > 2   THEN 
        DO:
             MESSAGE "Boletim ja LIBERADO.".
             glb_cdcritic = 79.
             RETURN.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/*  Exclusao dos cheques do bordero ......................................... */

FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper      AND 
                       crapcdb.nrborder = crapbdc.nrborder  AND
                       crapcdb.nrdconta = crapbdc.nrdconta  EXCLUSIVE-LOCK
                       USE-INDEX crapcdb7:
                        
    IF   crapcdb.inchqcop = 1   THEN
         DO:
             aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                                  STRING(crapcdb.nrddigc3,"9")).

             DO WHILE TRUE:
        
                FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND
                                   craplau.dtmvtolt = crapcdb.dtmvtolt   AND
                                   craplau.cdagenci = crapcdb.cdagenci   AND
                                   craplau.cdbccxlt = crapcdb.cdbccxlt   AND
                                   craplau.nrdolote = crapcdb.nrdolote   AND
                           DECIMAL(craplau.nrdctabb) = crapcdb.nrctachq  AND
                                   craplau.nrdocmto = aux_nrdocmto
                                   USE-INDEX craplau1 EXCLUSIVE-LOCK 
                                   NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplau   THEN
                     IF   LOCKED craplau   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.
                      
                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */
        
             IF   AVAILABLE craplau   THEN
                  DELETE craplau.
         END.
    
    DELETE crapcdb.                   
                       
END.  /*  Fim do FOR EACH crapcdb  */

/*  Exclusao das restricoes dos cheques do bordero .......................... */

FOR EACH crapabc WHERE crapabc.cdcooper = glb_cdcooper      AND
                       crapabc.nrborder = crapbdc.nrborder  EXCLUSIVE-LOCK:

    DELETE crapabc.

END.  /*  Fim do FOR EACH crapabc  */

/*  Exclui o bordero ........................................................ */

DELETE crapbdc.

glb_cdcritic = 0.

/* .......................................................................... */

