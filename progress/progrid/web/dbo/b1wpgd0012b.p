/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0007.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Eixos Tem�ticos de atua��o do Fornecedor
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
............................................................................ */
&SCOPED-DEFINE tttabela gnatefp
&SCOPED-DEFINE tabela   gnapefp


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
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Validacoes obrigat�rias a todas as tabelas */

    IF NOT AVAIL {&tttabela} THEN
    DO:       
        ASSIGN m-erros = m-erros + "Registro da Tabela Tempor�ria n�o dispon�vel.".
        RETURN "NOK".
    END.

    /* Fim - Validacoes obrigat�rias a todas as tabelas */

    /* Valida��es espec�ficas */
    /* No caso de erro de valida��o, a forma de tratamento � a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */

    /* Verifica se o fornecedor existe */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor n�o encontrado.".
        RETURN "NOK".
    END.

    /* Verifica se o eixo tem�tico existe */
    FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                    AND
                             gnapetp.cdeixtem = {&tttabela}.cdeixtem NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapetp THEN
    DO:
        ASSIGN m-erros = m-erros + "Eixo Tem�tico n�o encontrado.".
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
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN {&tabela}.idevento = gnapfdp.idevento
           {&tabela}.cdcooper = 0.

    /* Fim - Efetuar sobreposi��es necess�rias */ 

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: valida-alteracao                                                                    */
/*  Objetivo: Verifica se o registro da tabela tempor�ria est� OK para ser alterado na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.      */ 
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                     */
/*       m-erros = Guarda a mensagem de erro da valida��o                                             */
PROCEDURE valida-alteracao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.cdeixtem = {&tttabela}.cdeixtem NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro n�o encontrado para altera��o.".
        RETURN "NOK".
    END.

    /* Fim - Valida��es obrigat�rias a todas as tabelas */

    /* Valida��es espec�ficas */
    /* No caso de erro de valida��o, a forma de tratamento � a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */

    /* Verifica se o fornecedor n�o foi alterado */
    
    IF {&tttabela}.nrcpfcgc <> {&tabela}.nrcpfcgc THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor n�o pode ser alterado.".
        RETURN "NOK".
    END.

    /* Verifica se o eixo tem�tico n�o foi alterado */
    IF {&tttabela}.cdeixtem <> {&tabela}.cdeixtem THEN
    DO:
        ASSIGN m-erros = m-erros + "Eixo Tem�tico n�o pode ser alterado.".
        RETURN "NOK".
    END.
    
    /* Fim - Valida��es espec�ficas */

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: altera-registro                                                                 */
/*  Objetivo: Altera registro na tabela fisica a partir dos dados gravados na tabela temporaria   */
/*  Parametros de Entrada:                                                                        */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.  */
/*  Parametros de Saida:                                                                          */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                 */
/*       retorno-erro = Guarda a mensagem de erro da valida��o                                    */
PROCEDURE altera-registro:
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.cdeixtem = {&tttabela}.cdeixtem EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */

    ASSIGN {&tabela}.idevento = gnapfdp.idevento
           {&tabela}.cdcooper = 0.

    /* Fim - Efetuar sobreposi��es necess�rias */ 

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

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.cdeixtem = {&tttabela}.cdeixtem NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro gnapefp n�o encontrado para exclus�o." .
        RETURN "NOK".
    END.
    /* Fim - Valida��es obrigat�rias a todas as tabelas */

    /* Valida��es espec�ficas */
    /* No caso de erro de valida��o, a forma de tratamento � a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */
    
    /* Fim - Valida��es espec�ficas */
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
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.cdeixtem = {&tttabela}.cdeixtem EXCLUSIVE-LOCK NO-ERROR.

    /* Elimina o registro da tabela */
    DELETE {&tabela} NO-ERROR.

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: posiciona-registro                                                       */
/*  Objetivo: Posiciona no registro correspondente ao ponteiro passado como parametro      */
/*  Parametros de Entrada:                                                                 */
/*       ponteiro = indice do registro que se deseja posicionar                            */
/*  Parametros de Saida:                                                                   */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                          */
/*       retorno-erro = Guarda a mensagem de erro da valida��o                             */
PROCEDURE posiciona-registro:
    DEFINE INPUT  PARAMETER ponteiro     AS ROWID                 NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR  FORMAT "x(256)" NO-UNDO.

    FIND FIRST {&tabela} WHERE ROWID({&tabela}) = ponteiro NO-LOCK NO-ERROR.

    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN retorno-erro = "Registro n�o encontrado.".
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.
