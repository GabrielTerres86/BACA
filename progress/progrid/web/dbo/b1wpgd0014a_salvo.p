/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0014a.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Evandro
   Data    : Setembro/2005                      Ultima atualizacao: 10/09/2013

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Exclus�o de Eventos para o PA
   
   Altera��es: 10/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).
............................................................................ */
&SCOPED-DEFINE tttabela cratedp
&SCOPED-DEFINE tabela   crapedp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros AS CHAR FORMAT "x(256)" NO-UNDO.

/*  Procedimento: valida-inclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela tempor�ria est� OK para ser inserido na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.      */
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                     */
/*       m-erros = Guarda a mensagem de erro da valida��o                                             */
PROCEDURE valida-inclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    
    FIND FIRST {&tttabela} NO-ERROR.

    /* Validacoes obrigat�rias a todas as tabelas */

    IF NOT AVAIL {&tttabela} THEN
    DO:       
        ASSIGN m-erros = m-erros + "Registro da Tabela Tempor�ria n�o dispon�vel.".
        RETURN "NOK".
    END.

    /* verifica se o Evento selecionado existe */
    FIND FIRST crapedp WHERE crapedp.idevento = {&tttabela}.idevento AND
                             crapedp.cdcooper = 0                    AND /* eventos gen�ricos n�o possuem cooperativa */
                             crapedp.cdevento = {&tttabela}.cdevento AND
                             crapedp.dtanoage = 0                    NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapedp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inexistente".
        RETURN "NOK".
    END.

    /* valida o c�digo de cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida a Identifica��o do Evento, se � progrid ou assembl�ia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.
    /* Fim - Valida��es espec�ficas */

    RETURN "OK".

END PROCEDURE.

/*  Procedimento: inclui-registro                                                                 */
/*  Objetivo: Cria registro na tabela fisica a partir dos dados gravados na tabela temporaria     */
/*  Parametros de Entrada:                                                                        */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.  */
/*  Parametros de Saida:                                                                          */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                 */
/*       retorno-erro = Guarda a mensagem de erro da valida��o                                    */
/*       aux_nrdrowid = Rowid do registro criado na tabela                                        */
PROCEDURE inclui-registro:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    
    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */

    FIND FIRST {&tttabela}.

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela tempor�ria */
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.
    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */
    
    RETURN "OK".

END PROCEDURE.


/*  Procedimento: valida-exclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela tempor�ria est� OK para ser excluido da tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.      */      
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                     */
/*       m-erros = Guarda a mensagem de erro da valida��o                                             */
PROCEDURE valida-exclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.

    FIND FIRST {&tttabela}.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro n�o encontrado para exclus�o.".
        RETURN "NOK".
    END.
    /* Fim - Valida��es obrigat�rias a todas as tabelas */


    /* Verifica se algum dos PA'S que possui o evento j� teve a lista de eventos enviada */
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
                ASSIGN m-erros = m-erros + "Um ou mais PA'S j� tiveram este evento enviado.".
                RETURN "NOK".
             END.

    END.

    
    RETURN "OK".
END PROCEDURE.

/*  Procedimento: exclui-registro                                                                 */
/*  Objetivo: Elimina registro na tabela fisica a partir dos dados gravados na tabela temporaria  */
/*  Parametros de Entrada:                                                                        */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.  */
/*  Parametros de Saida:                                                                          */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                 */
/*       retorno-erro = Guarda a mensagem de erro da valida��o                                    */
PROCEDURE exclui-registro:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */

    FIND FIRST {&tttabela}.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
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

