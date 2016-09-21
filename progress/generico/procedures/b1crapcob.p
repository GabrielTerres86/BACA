/*..............................................................................

   Programa: b1crapcob.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Outubro/2006                    Ultima atualizacao: 02/10/2015

   Dados referentes ao programa:

   Frequcobia: Diario (Ayllos).
   Objetivo  : Tratar INCLUSAO na tabela crapcob.

   Alteracoes: 26/12/2006 - Alterado FIND FIRST para FOR EACH na temp-table
                            cratcob (David).
                            
               12/09/2008 - Alterado campo cdbccxlt -> cdbandoc (Diego).

               17/12/2013 - Adicionado validate para tabela crapcob (Tiago).
               
               02/10/2015 - Ajustado rotina inclui-registro, para caso o nrnosnum
                           estiver nulo montar essa informacao SD339759 (Odirlei-Amcom)
                           
..............................................................................*/

DEF TEMP-TABLE cratcob NO-UNDO LIKE crapcob.


PROCEDURE inclui-registro:

    DEF  INPUT PARAM TABLE         FOR cratcob.
    DEF OUTPUT PARAM par_dscritic  AS CHAR           NO-UNDO.
    
    DEF VAR aux_nrnosnum LIKE crapcob.nrnosnum       NO-UNDO.

    FOR EACH cratcob NO-LOCK:
    
        /* Verifica se o bloqueto ja foi cadastrado */
        FIND crapcob WHERE crapcob.cdcooper = cratcob.cdcooper AND
                           crapcob.cdbandoc = cratcob.cdbandoc AND
                           crapcob.nrdctabb = cratcob.nrdctabb AND
                           crapcob.nrcnvcob = cratcob.nrcnvcob AND
                           crapcob.nrdocmto = cratcob.nrdocmto AND
                           crapcob.nrdconta = cratcob.nrdconta
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcob  THEN
            DO:
                par_dscritic = "Bloqueto de cobranca ja cadastrado.".
                RETURN "NOK".
            END.
         
        /* Cria o registro */
        CREATE crapcob.
        BUFFER-COPY cratcob TO crapcob.
        
        /* Verificar se possui informacao do nosso numero,
           caso nao existir deve montar */
        IF TRIM(crapcob.nrnosnum) = "" AND 
           crapcob.nrdconta <> 0  THEN
            DO:
                IF  crapcob.cdbandoc <> 085 THEN
                    DO: 
                        IF LENGTH(STRING(crapcob.nrcnvcob)) = 6 THEN
                          ASSIGN aux_nrnosnum = STRING(crapcob.nrdconta ,"99999999") +
                                                STRING(crapcob.nrdocmto ,"999999999").
                        ELSE
                            DO:
                              FIND FIRST crapceb 
                                   WHERE crapceb.cdcooper = crapcob.cdcooper AND
                                         crapceb.nrdconta = crapcob.nrdconta AND
                                         crapceb.nrconven = crapcob.nrcnvcob NO-LOCK NO-ERROR.

                              ASSIGN aux_nrnosnum = STRING(crapcob.nrcnvcob, "9999999") + 
                                                    STRING(crapceb.nrcnvceb, "9999") + 
                                                    STRING(crapcob.nrdocmto, "999999").
                            END.

                          
                    END. /* se for banco 085 */
                    ELSE
                        DO:
                            ASSIGN aux_nrnosnum = STRING(crapcob.nrdconta,"99999999") +
                                                  STRING(crapcob.nrdocmto,"999999999").
                        END.

                ASSIGN  crapcob.nrnosnum = aux_nrnosnum.
            END.

        
        VALIDATE crapcob.
        
    END. /* Fim do FOR EACH */

END PROCEDURE. /* inclui-registro */

/*............................................................................*/
