/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0014b.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Evandro
   Data    : Setembro/2005                      Ultima atualizacao: 16/12/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Exclusão de Associações dos Eventos aos PAC'S
   
   Alterações: 16/12/2014 - Incluir VALIDADE {&tabela} (Lucas R.)
............................................................................ */
&SCOPED-DEFINE tttabela crateap
&SCOPED-DEFINE tabela   crapeap


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

    FIND {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    IF AVAILABLE {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro já existe.".
        RETURN "NOK".
    END.

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
      
     RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END. 

    /* Cria o registro na tabela fisica, a partir da tabela temporária */
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.
    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Se o evento é obrigatório, ele deve estar previamente selecionado */
    IF {&tabela}.flgevobr THEN
       ASSIGN {&tabela}.flgevsel = YES.

    VALIDATE {&tabela}.

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

    FIND FIRST {&tttabela} NO-ERROR.

    IF NOT AVAILABLE {&tttabela} THEN
       RETURN "NOK".

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro não encontrado para exclusão.".
        RETURN "NOK".
    END.
    /* Fim - Validações obrigatórias a todas as tabelas */
    
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

    FIND FIRST {&tttabela} NO-ERROR.

    IF NOT AVAILABLE {&tttabela} THEN
       RETURN "NOK".

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK.
        
    /* Elimina o registro da tabela */
    DELETE {&tabela} NO-ERROR.

    RETURN "OK".
END PROCEDURE.

