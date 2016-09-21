/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0025.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Lançamentos de Kits
   
   Alteração : 10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela cratkbq
&SCOPED-DEFINE tabela   crapkbq


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

    /* Fim - Validacoes obrigatórias a todas as tabelas */

    /* Validações específicas */
    /* No caso de erro de validação, a forma de tratamento é a seguinte:
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
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Operador */
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Operador inválido.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se é progrid ou assembléia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida data da solicitação */
    IF {&tttabela}.dtsolici = ? AND {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da solicitação deve ser informada.".
        RETURN "NOK".
    END.

    /* Data do envio deve ser >= que a data da solicitação */
    IF {&tttabela}.dtdenvio <> ?                    AND
       {&tttabela}.dtdenvio  < {&tttabela}.dtsolici AND
       {&tttabela}.tpdeitem <> 3                    THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de envio não pode ser menor que data da solicitação.".
        RETURN "NOK".
    END.

    /* Valida o tipo de lançamento.
     Atualmente existem apenas 3:
     1 - Kits
     2 - Brindes
     3 - Questionários */
    IF {&tttabela}.tpdeitem < 1 OR {&tttabela}.tpdeitem > 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Lançamento inválido.".
        RETURN "NOK".
    END.

    /* Quantidade solicitada não pode ser zero */
    IF {&tttabela}.qtsolici  = 0 AND
       {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Quantidade solicitada não pode ser zero.".
        RETURN "NOK".
    END.

    /* Nome do Solicitante não pode ser branco */
    IF TRIM({&tttabela}.nmsolici) = "" AND
       {&tttabela}.tpdeitem      <> 3  THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do solicitante não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valor enviado não pode ser zero */
    IF {&tttabela}.dtdenvio <> ?    AND
       ({&tttabela}.vlrenvio <= 0   OR
        {&tttabela}.vlrenvio = ?)   AND
       {&tttabela}.tpdeitem <> 3    THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor de envio não pode ser zero.".
        RETURN "NOK".
    END.

    /* Data deve ser informada quando houver valor de envio */
    IF {&tttabela}.dtdenvio  = ?    AND
       {&tttabela}.vlrenvio  > 0    AND
       {&tttabela}.tpdeitem <> 3
        THEN
    DO:
        ASSIGN m-erros = m-erros + "Havendo valor de envio, data de envio não pode ser nula.".
        RETURN "NOK".
    END.

    /* Validação de lançamento de questionários */
    IF {&tttabela}.tpdeitem = 3   AND
        ({&tttabela}.dtdenvio = ? OR
         {&tttabela}.qtdenvio <= 0) THEN
    DO:
        ASSIGN m-erros = m-erros + "Data e quantidade devem ser informados corretamente.".
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
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR NO-UNDO.

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

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Efetuar sobreposições necessárias */ 

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

    /* Fim - Efetuar sobreposições necessárias */ 

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: valida-alteracao                                                                    */
/*  Objetivo: Verifica se o registro da tabela temporária está OK para ser alterado na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.      */ 
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                     */
/*       m-erros = Guarda a mensagem de erro da validação                                             */
PROCEDURE valida-alteracao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.

    FIND FIRST {&tttabela}.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro não encontrado para alteração.".
        RETURN "NOK".
    END.

    /* Fim - Validações obrigatórias a todas as tabelas */

    /* Validações específicas */
    /* No caso de erro de validação, a forma de tratamento é a seguinte:
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
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Operador */
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Operador inválido.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se é progrid ou assembléia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida data da solicitação */
    IF {&tttabela}.dtsolici = ? AND {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da solicitação deve ser informada.".
        RETURN "NOK".
    END.

    /* Data do envio deve ser >= que a data da solicitação */
    IF {&tttabela}.dtdenvio <> ? AND
        {&tttabela}.dtdenvio < {&tttabela}.dtsolici AND
        {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de envio não pode ser menor que data da solicitação.".
        RETURN "NOK".
    END.

    /* Valida o tipo de lançamento.
     Atualmente existem apenas 3:
     1 - Kits
     2 - Brindes
     3 - Questionários */
    IF {&tttabela}.tpdeitem < 1 OR {&tttabela}.tpdeitem > 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Lançamento inválido.".
        RETURN "NOK".
    END.

    /* Quantidade solicitada não pode ser zero */
    IF {&tttabela}.qtsolici = 0 AND
        {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Quantidade solicitada não pode ser zero.".
        RETURN "NOK".
    END.

    /* Nome do Solicitante não pode ser branco */
    IF TRIM({&tttabela}.nmsolici) = "" AND
       {&tttabela}.tpdeitem <> 3 THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do solicitante não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valor enviado não pode ser zero */
    IF {&tttabela}.dtdenvio <> ? AND
        ({&tttabela}.vlrenvio <= 0 OR
         {&tttabela}.vlrenvio = ?) AND
        {&tttabela}.tpdeitem <> 3 
         THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor de envio não pode ser zero.".
        RETURN "NOK".
    END.

    /* Data deve ser informada quando houver valor de envio */
    IF {&tttabela}.dtdenvio = ? AND
        {&tttabela}.vlrenvio > 0 AND
        {&tttabela}.tpdeitem <> 3
        THEN
    DO:
        ASSIGN m-erros = m-erros + "Havendo valor de envio, data de envio não pode ser nula.".
        RETURN "NOK".
    END.

    /* Validação de lançamento de questionários */
    IF {&tttabela}.tpdeitem = 3   AND
        ({&tttabela}.dtdenvio = ? OR
         {&tttabela}.qtdenvio <= 0) THEN
    DO:
        ASSIGN m-erros = m-erros + "Data e quantidade devem ser informados corretamente.".
        RETURN "NOK".
    END.
    
    /* Fim - Validações específicas */

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: altera-registro                                                                 */
/*  Objetivo: Altera registro na tabela fisica a partir dos dados gravados na tabela temporaria   */
/*  Parametros de Entrada:                                                                        */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.  */
/*  Parametros de Saida:                                                                          */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                 */
/*       retorno-erro = Guarda a mensagem de erro da validação                                    */
PROCEDURE altera-registro:
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */

    FIND FIRST {&tttabela}.

    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN
        {&tabela}.nmsolici = TRIM(CAPS({&tttabela}.nmsolici))
        {&tabela}.dtmvtolt = TODAY.

    IF {&tabela}.dtdenvio = ? THEN
    DO:
        ASSIGN
            {&tabela}.qtdenvio = ?
            {&tabela}.vlrenvio = ?.
    END.

    /* Fim - Efetuar sobreposições necessárias */ 

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

    /* Validações específicas */
    /* No caso de erro de validação, a forma de tratamento é a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */
            

    
    /* Fim - Validações específicas */
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

    /* Elimina o registro da tabela */
    DELETE {&tabela} NO-ERROR.

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: posiciona-registro                                                       */
/*  Objetivo: Posiciona no registro correspondente ao ponteiro passado como parametro      */
/*  Parametros de Entrada:                                                                 */
/*       ponteiro = indice do registro que se deseja posicionar                            */
/*  Parametros de Saida:                                                                   */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                          */
/*       retorno-erro = Guarda a mensagem de erro da validação                             */
PROCEDURE posiciona-registro:
    DEFINE INPUT  PARAMETER ponteiro     AS ROWID                 NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR  FORMAT "x(256)" NO-UNDO.

    FIND FIRST {&tabela} WHERE ROWID({&tabela}) = ponteiro NO-LOCK NO-ERROR.

    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN retorno-erro = "Registro não encontrado.".
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.
