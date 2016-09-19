/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0025.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Lan�amentos de Kits
   
   Altera��o : 10/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela cratkbq
&SCOPED-DEFINE tabela   crapkbq


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

    /* Fim - Validacoes obrigat�rias a todas as tabelas */

    /* Valida��es espec�ficas */
    /* No caso de erro de valida��o, a forma de tratamento � a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage AND {&tttabela}.cdagenci <> 0 THEN
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Operador */
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se � progrid ou assembl�ia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida data da solicita��o */
    IF {&tttabela}.dtsolici = ? AND {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da solicita��o deve ser informada.".
        RETURN "NOK".
    END.

    /* Data do envio deve ser >= que a data da solicita��o */
    IF {&tttabela}.dtdenvio <> ?                    AND
       {&tttabela}.dtdenvio  < {&tttabela}.dtsolici AND
       {&tttabela}.tpdeitem <> 3                    THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de envio n�o pode ser menor que data da solicita��o.".
        RETURN "NOK".
    END.

    /* Valida o tipo de lan�amento.
     Atualmente existem apenas 3:
     1 - Kits
     2 - Brindes
     3 - Question�rios */
    IF {&tttabela}.tpdeitem < 1 OR {&tttabela}.tpdeitem > 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Lan�amento inv�lido.".
        RETURN "NOK".
    END.

    /* Quantidade solicitada n�o pode ser zero */
    IF {&tttabela}.qtsolici  = 0 AND
       {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Quantidade solicitada n�o pode ser zero.".
        RETURN "NOK".
    END.

    /* Nome do Solicitante n�o pode ser branco */
    IF TRIM({&tttabela}.nmsolici) = "" AND
       {&tttabela}.tpdeitem      <> 3  THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do solicitante n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valor enviado n�o pode ser zero */
    IF {&tttabela}.dtdenvio <> ?    AND
       ({&tttabela}.vlrenvio <= 0   OR
        {&tttabela}.vlrenvio = ?)   AND
       {&tttabela}.tpdeitem <> 3    THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor de envio n�o pode ser zero.".
        RETURN "NOK".
    END.

    /* Data deve ser informada quando houver valor de envio */
    IF {&tttabela}.dtdenvio  = ?    AND
       {&tttabela}.vlrenvio  > 0    AND
       {&tttabela}.tpdeitem <> 3
        THEN
    DO:
        ASSIGN m-erros = m-erros + "Havendo valor de envio, data de envio n�o pode ser nula.".
        RETURN "NOK".
    END.

    /* Valida��o de lan�amento de question�rios */
    IF {&tttabela}.tpdeitem = 3   AND
        ({&tttabela}.dtdenvio = ? OR
         {&tttabela}.qtdenvio <= 0) THEN
    DO:
        ASSIGN m-erros = m-erros + "Data e quantidade devem ser informados corretamente.".
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
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR NO-UNDO.

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

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN
        {&tabela}.nrseqdig = NEXT-VALUE(nrseqkbq)
        {&tabela}.nmsolici = TRIM(CAPS({&tttabela}.nmsolici))
        {&tabela}.dtmvtolt = TODAY.

    IF {&tabela}.dtdenvio = ? THEN
    DO:
        ASSIGN
            {&tabela}.qtdenvio = ?
            {&tabela}.vlrenvio = ?.
    END.

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

    FIND FIRST {&tttabela}.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

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

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage AND {&tttabela}.cdagenci <> 0 THEN
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Operador */
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se � progrid ou assembl�ia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida data da solicita��o */
    IF {&tttabela}.dtsolici = ? AND {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da solicita��o deve ser informada.".
        RETURN "NOK".
    END.

    /* Data do envio deve ser >= que a data da solicita��o */
    IF {&tttabela}.dtdenvio <> ? AND
        {&tttabela}.dtdenvio < {&tttabela}.dtsolici AND
        {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de envio n�o pode ser menor que data da solicita��o.".
        RETURN "NOK".
    END.

    /* Valida o tipo de lan�amento.
     Atualmente existem apenas 3:
     1 - Kits
     2 - Brindes
     3 - Question�rios */
    IF {&tttabela}.tpdeitem < 1 OR {&tttabela}.tpdeitem > 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Lan�amento inv�lido.".
        RETURN "NOK".
    END.

    /* Quantidade solicitada n�o pode ser zero */
    IF {&tttabela}.qtsolici = 0 AND
        {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Quantidade solicitada n�o pode ser zero.".
        RETURN "NOK".
    END.

    /* Nome do Solicitante n�o pode ser branco */
    IF TRIM({&tttabela}.nmsolici) = "" AND
       {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do solicitante n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valor enviado n�o pode ser zero */
    IF {&tttabela}.dtdenvio <> ? AND
        ({&tttabela}.vlrenvio <= 0 OR
         {&tttabela}.vlrenvio = ?) AND
        {&tttabela}.tpdeitem <> 3 
         THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor de envio n�o pode ser zero.".
        RETURN "NOK".
    END.

    /* Data deve ser informada quando houver valor de envio */
    IF {&tttabela}.dtdenvio = ? AND
        {&tttabela}.vlrenvio > 0 AND
        {&tttabela}.tpdeitem <> 3
        THEN
    DO:
        ASSIGN m-erros = m-erros + "Havendo valor de envio, data de envio n�o pode ser nula.".
        RETURN "NOK".
    END.

    /* Valida��o de lan�amento de question�rios */
    IF {&tttabela}.tpdeitem = 3   AND
        ({&tttabela}.dtdenvio = ? OR
         {&tttabela}.qtdenvio <= 0) THEN
    DO:
        ASSIGN m-erros = m-erros + "Data e quantidade devem ser informados corretamente.".
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

    FIND FIRST {&tttabela}.

    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN
        {&tabela}.nmsolici = TRIM(CAPS({&tttabela}.nmsolici))
        {&tabela}.dtmvtolt = TODAY.

    IF {&tabela}.dtdenvio = ? THEN
    DO:
        ASSIGN
            {&tabela}.qtdenvio = ?
            {&tabela}.vlrenvio = ?.
    END.

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
