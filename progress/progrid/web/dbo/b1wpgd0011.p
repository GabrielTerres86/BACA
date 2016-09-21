/* ...................................................................................
   Programa: progrid/web/dbo/b1wpgd0011.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Sugestões
   
   Alterações: 10/10/2008 - Alterado para permitir o Descarte de Sugestão sem ter que
                            selecionar um Evento (Diego).
				
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada, 
                            incluida (Carlos)
                            
              25/08/2015 - Ajustes de homologaçao( Vanessa)
.................................................................................... */
&SCOPED-DEFINE tttabela cratsdp
&SCOPED-DEFINE tabela   crapsdp


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
   
    IF NOT AVAIL crapage            AND
        {&tttabela}.cdagenci <> 0   AND    /* Todos os PAs */
        ({&tttabela}.cdorisug = 1   OR    /* Comitê Educativo */
         {&tttabela}.cdorisug = 2   OR    /* Pesquisa */
         {&tttabela}.cdorisug = 10  OR    /* EAD */
         {&tttabela}.cdorisug = 4   OR    /* Cooperados */
         {&tttabela}.cdorisug = 5)  THEN  /* Não Cooperados */
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.
            
    /* Valida a Cooperativa */
    FIND FIRST CRAPCOP WHERE CRAPCOP.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL CRAPCOP AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Evento */
    /*FIND FIRST crapedp WHERE
        crapedp.cdevento = {&tttabela}.cdevento NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inválido.".
        RETURN "NOK".
    END.
    */
    /* Valida o Operador */
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Operador inválido.".
        RETURN "NOK".
    END.

    /* Valida a Origem da Sugestão */
    FIND FIRST craptab WHERE craptab.cdcooper = 0                       AND
                             craptab.nmsistem = "CRED"                  AND
                             craptab.tptabela = "CONFIG"                AND
                             craptab.cdempres = 0                       AND
                             craptab.cdacesso = "PGTPORIGEM"            AND
                             craptab.tpregist = 0                       NO-LOCK NO-ERROR.
    IF AVAIL craptab THEN
    DO:
        IF lookup(string({&tttabela}.cdorisug), craptab.dstextab, ",") = 0 OR {&tttabela}.cdorisug = ? THEN 
        DO:
            ASSIGN m-erros = m-erros + "Tipo de Origem inválido.".
            RETURN "NOK".
        END.
    END.

    /* Verifica se o texto da sugestão não é branco */
    IF TRIM({&tttabela}.dssugeve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Texto da Sugestão não pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se a data do movimento não é nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da sugestão não pode ser nula.".
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

    /* Verifica se o cooperado existe no cadastro */
    FIND FIRST crapttl WHERE crapttl.nrdconta = {&tttabela}.nrdconta    AND
                             crapttl.idseqttl = {&tttabela}.idseqttl    AND 
                             crapttl.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapttl AND {&tttabela}.cdorisug = 4 THEN
    DO:
        ASSIGN m-erros = m-erros + "Cooperado não encontrado.".
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
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */
    
    FIND FIRST {&tttabela}.
    
    RUN valida-inclusao (INPUT TABLE {&tttabela}).
    
    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.
    
    /* Cria o registro na tabela fisica, a partir da tabela temporária */
    
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.
    
    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    IF {&tabela}.qtsugeve = 0 THEN
    DO:
        ASSIGN {&tabela}.qtsugeve = 1.
    END.

    /* Limpar os campos que não precisam ter dados, de acordo com a origem */
    CASE {&tabela}.cdorisug:
        WHEN 1 THEN /* Comitê Educativo */
        DO:
           /* ASSIGN
                {&tabela}.idseqttl = ?
                {&tabela}.nrdconta = ?.*/
        END.
        WHEN 2 THEN /* Pesquisa */
        DO:
            ASSIGN
                {&tabela}.idseqttl = ?
                {&tabela}.nrdconta = ?.
        END.
        WHEN 3 THEN /* Cooperativa */
        DO:
           /* ASSIGN
                {&tabela}.idseqttl = ?
                {&tabela}.nrdconta = ?.*/
        END.
        WHEN 5 THEN /* Não Cooperado */
        DO:
            ASSIGN
                {&tabela}.idseqttl = ?
                {&tabela}.nrdconta = ?.
        END.
        WHEN 6 THEN /* Cooperativa */
        DO:
         /*   ASSIGN
                {&tabela}.idseqttl = ?
                {&tabela}.nrdconta = ?.*/
                /*{&tabela}.cdagenci = 0.*/
        END.
    END CASE.

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

    IF NOT AVAIL crapage            AND
        {&tttabela}.cdagenci <> 0   AND    /* Todos os PAs */
        ({&tttabela}.cdorisug = 1   OR    /* Comitê Educativo */
         {&tttabela}.cdorisug = 2   OR    /* Pesquisa */
         {&tttabela}.cdorisug = 10  OR    /* EAD */
         {&tttabela}.cdorisug = 4   OR    /* Cooperados */
         {&tttabela}.cdorisug = 5)  THEN  /* Não Cooperados */
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST CRAPCOP WHERE CRAPCOP.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL CRAPCOP AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /***** Valida o Evento 
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inválido.".
        RETURN "NOK".
    END.
    *******/ 
	
    /* Verifica se a sugestão já foi atendida */
   IF {&tabela}.dtanoage <> 0  AND  {&tabela}.dtanoage <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Sugestão já atendida. Alteração não permitida.".
        RETURN "NOK".
    END.


    /* Se a sugestão tem já tem evento, o cadastro de sugestões não pode alterá-la */
    IF {&tabela}.cdevento <> ? AND {&tttabela}.cdevento = ? THEN
    /*IF {&tabela}.cdevento <> ?  THEN*/
    DO:
        ASSIGN m-erros = m-erros + "Sugestão já analisada. Alteração não permitida.".
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

    /* Valida a Origem da Sugestão */
    FIND FIRST craptab WHERE craptab.cdcooper = 0                       AND
                             craptab.nmsistem = "CRED"                  AND
                             craptab.tptabela = "CONFIG"                AND
                             craptab.cdempres = 0                       AND
                             craptab.cdacesso = "PGTPORIGEM"            AND
                             craptab.tpregist = 0                       NO-LOCK NO-ERROR.
    IF AVAIL craptab THEN
    DO:
        IF lookup(string({&tttabela}.cdorisug), craptab.dstextab, ",") = 0 OR {&tttabela}.cdorisug = ? THEN 
        DO:
            ASSIGN m-erros = m-erros + "Tipo de Origem inválido.".
            RETURN "NOK".
        END.
    END.

    /* Verifica se a origem foi alterada */
    IF {&tttabela}.cdorisug <> {&tabela}.cdorisug THEN
    DO:
        ASSIGN m-erros = m-erros + "Alteração de Origem não é permitida.".
        RETURN "NOK".
    END.

    /* Verifica se o texto da sugestão não é branco */
    IF TRIM({&tttabela}.dssugeve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Texto da Sugestão não pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se a data do movimento não é nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da sugestão não pode ser nula.".
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

    /* Verifica se o cooperado existe no cadastro */
    FIND FIRST crapttl WHERE crapttl.nrdconta = {&tttabela}.nrdconta    AND
                             crapttl.idseqttl = {&tttabela}.idseqttl    AND 
                             crapttl.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapttl AND {&tttabela}.cdorisug = 4 THEN
    DO:
        ASSIGN m-erros = m-erros + "Cooperado não encontrado.".
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
        {&tabela}.dssugeve = TRIM(CAPS({&tabela}.dssugeve))
        .

    IF {&tabela}.qtsugeve = 0 THEN
    DO:
        ASSIGN {&tabela}.qtsugeve = 1.
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

    IF {&tttabela}.dtanoage <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Sugestão possui ano de agenda. Exclusão não permitida.".
        RETURN "NOK".
    END.

    IF {&tttabela}.cdevento <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Sugestão possui evento relacionado. Exclusão não permitida.".
        RETURN "NOK".
    END.
    
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
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
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
