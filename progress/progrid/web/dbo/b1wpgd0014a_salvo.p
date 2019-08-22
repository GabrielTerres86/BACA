/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0014a.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Evandro
   Data    : Setembro/2005                      Ultima atualizacao: 10/09/2013

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Exclusão de Eventos para o PA
   
   Alterações: 10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................ */
&SCOPED-DEFINE tttabela cratedp
&SCOPED-DEFINE tabela   crapedp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros AS CHAR FORMAT "x(256)" NO-UNDO.

/*  Procedimento: valida-inclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela temporária está OK para ser inserido na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.      */
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                     */
/*       m-erros = Guarda a mensagem de erro da validação                                             */
PROCEDURE valida-inclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    
    FIND FIRST {&tttabela} NO-ERROR.

    /* Validacoes obrigatórias a todas as tabelas */

    IF NOT AVAIL {&tttabela} THEN
    DO:       
        ASSIGN m-erros = m-erros + "Registro da Tabela Temporária não disponível.".
        RETURN "NOK".
    END.

    /* verifica se o Evento selecionado existe */
    FIND FIRST crapedp WHERE crapedp.idevento = {&tttabela}.idevento AND
                             crapedp.cdcooper = 0                    AND /* eventos genéricos não possuem cooperativa */
                             crapedp.cdevento = {&tttabela}.cdevento AND
                             crapedp.dtanoage = 0                    NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapedp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inexistente".
        RETURN "NOK".
    END.

    /* valida o código de cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida a Identificação do Evento, se é progrid ou assembléia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.
    /* Fim - Validações específicas */

    RETURN "OK".

END PROCEDURE.

/*  Procedimento: inclui-registro                                                                 */
/*  Objetivo: Cria registro na tabela fisica a partir dos dados gravados na tabela temporaria     */
/*  Parametros de Entrada:                                                                        */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.  */
/*  Parametros de Saida:                                                                          */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                 */
/*       retorno-erro = Guarda a mensagem de erro da validação                                    */
/*       aux_nrdrowid = Rowid do registro criado na tabela                                        */
PROCEDURE inclui-registro:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    
    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */

    FIND FIRST {&tttabela}.

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela temporária */
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.
    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */
    
    RETURN "OK".

END PROCEDURE.


/*  Procedimento: valida-exclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela temporária está OK para ser excluido da tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.      */      
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                     */
/*       m-erros = Guarda a mensagem de erro da validação                                             */
PROCEDURE valida-exclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.

    FIND FIRST {&tttabela}.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro não encontrado para exclusão.".
        RETURN "NOK".
    END.
    /* Fim - Validações obrigatórias a todas as tabelas */


    /* Verifica se algum dos PA'S que possui o evento já teve a lista de eventos enviada */
    FOR EACH crapeap WHERE crapeap.cdcooper = {&tabela}.cdcooper   AND
                           crapeap.idevento = {&tabela}.idevento   AND
                           crapeap.dtanoage = {&tabela}.dtanoage   AND
                           crapeap.cdevento = {&tabela}.cdevento   NO-LOCK:

        FIND crapagp WHERE crapagp.idevento = crapeap.idevento  AND
                           crapagp.cdcooper = crapeap.cdcooper  AND
                           crapagp.dtanoage = crapeap.dtanoage  AND
                           crapagp.cdagenci = crapeap.cdagenci  NO-LOCK NO-ERROR.
        
     
        IF   AVAILABLE crapagp       AND 
             crapagp.idstagen > 0    AND
             {&tabela}.idevento = 1  THEN
             DO:
                ASSIGN m-erros = m-erros + "Um ou mais PA'S já tiveram este evento enviado.".
                RETURN "NOK".
             END.

    END.

    
    RETURN "OK".
END PROCEDURE.

/*  Procedimento: exclui-registro                                                                 */
/*  Objetivo: Elimina registro na tabela fisica a partir dos dados gravados na tabela temporaria  */
/*  Parametros de Entrada:                                                                        */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.  */
/*  Parametros de Saida:                                                                          */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                 */
/*       retorno-erro = Guarda a mensagem de erro da validação                                    */
PROCEDURE exclui-registro:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */

    FIND FIRST {&tttabela}.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.


    /* Apaga os registros do evento para os PA'S */
    FOR EACH crapeap WHERE crapeap.cdcooper = {&tabela}.cdcooper   AND
                           crapeap.idevento = {&tabela}.idevento   AND
                           crapeap.dtanoage = {&tabela}.dtanoage   AND
                           crapeap.cdevento = {&tabela}.cdevento   EXCLUSIVE-LOCK:
        DELETE crapeap.
    END.
    
    /* Elimina o registro da tabela */
    DELETE {&tabela} NO-ERROR.

    RETURN "OK".
END PROCEDURE.

