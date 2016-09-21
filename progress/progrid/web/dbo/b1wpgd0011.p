/* ...................................................................................
   Programa: progrid/web/dbo/b1wpgd0011.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Sugest�es
   
   Altera��es: 10/10/2008 - Alterado para permitir o Descarte de Sugest�o sem ter que
                            selecionar um Evento (Diego).
				
               10/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada, 
                            incluida (Carlos)
                            
              25/08/2015 - Ajustes de homologa�ao( Vanessa)
.................................................................................... */
&SCOPED-DEFINE tttabela cratsdp
&SCOPED-DEFINE tabela   crapsdp


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
   
    IF NOT AVAIL crapage            AND
        {&tttabela}.cdagenci <> 0   AND    /* Todos os PAs */
        ({&tttabela}.cdorisug = 1   OR    /* Comit� Educativo */
         {&tttabela}.cdorisug = 2   OR    /* Pesquisa */
         {&tttabela}.cdorisug = 10  OR    /* EAD */
         {&tttabela}.cdorisug = 4   OR    /* Cooperados */
         {&tttabela}.cdorisug = 5)  THEN  /* N�o Cooperados */
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.
            
    /* Valida a Cooperativa */
    FIND FIRST CRAPCOP WHERE CRAPCOP.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL CRAPCOP AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Evento */
    /*FIND FIRST crapedp WHERE
        crapedp.cdevento = {&tttabela}.cdevento NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inv�lido.".
        RETURN "NOK".
    END.
    */
    /* Valida o Operador */
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
        RETURN "NOK".
    END.

    /* Valida a Origem da Sugest�o */
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
            ASSIGN m-erros = m-erros + "Tipo de Origem inv�lido.".
            RETURN "NOK".
        END.
    END.

    /* Verifica se o texto da sugest�o n�o � branco */
    IF TRIM({&tttabela}.dssugeve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Texto da Sugest�o n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se a data do movimento n�o � nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da sugest�o n�o pode ser nula.".
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

    /* Verifica se o cooperado existe no cadastro */
    FIND FIRST crapttl WHERE crapttl.nrdconta = {&tttabela}.nrdconta    AND
                             crapttl.idseqttl = {&tttabela}.idseqttl    AND 
                             crapttl.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapttl AND {&tttabela}.cdorisug = 4 THEN
    DO:
        ASSIGN m-erros = m-erros + "Cooperado n�o encontrado.".
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
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */
    
    FIND FIRST {&tttabela}.
    
    RUN valida-inclusao (INPUT TABLE {&tttabela}).
    
    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.
    
    /* Cria o registro na tabela fisica, a partir da tabela tempor�ria */
    
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.
    
    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    IF {&tabela}.qtsugeve = 0 THEN
    DO:
        ASSIGN {&tabela}.qtsugeve = 1.
    END.

    /* Limpar os campos que n�o precisam ter dados, de acordo com a origem */
    CASE {&tabela}.cdorisug:
        WHEN 1 THEN /* Comit� Educativo */
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
        WHEN 5 THEN /* N�o Cooperado */
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

    IF NOT AVAIL crapage            AND
        {&tttabela}.cdagenci <> 0   AND    /* Todos os PAs */
        ({&tttabela}.cdorisug = 1   OR    /* Comit� Educativo */
         {&tttabela}.cdorisug = 2   OR    /* Pesquisa */
         {&tttabela}.cdorisug = 10  OR    /* EAD */
         {&tttabela}.cdorisug = 4   OR    /* Cooperados */
         {&tttabela}.cdorisug = 5)  THEN  /* N�o Cooperados */
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST CRAPCOP WHERE CRAPCOP.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL CRAPCOP AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /***** Valida o Evento 
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inv�lido.".
        RETURN "NOK".
    END.
    *******/ 
	
    /* Verifica se a sugest�o j� foi atendida */
   IF {&tabela}.dtanoage <> 0  AND  {&tabela}.dtanoage <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Sugest�o j� atendida. Altera��o n�o permitida.".
        RETURN "NOK".
    END.


    /* Se a sugest�o tem j� tem evento, o cadastro de sugest�es n�o pode alter�-la */
    IF {&tabela}.cdevento <> ? AND {&tttabela}.cdevento = ? THEN
    /*IF {&tabela}.cdevento <> ?  THEN*/
    DO:
        ASSIGN m-erros = m-erros + "Sugest�o j� analisada. Altera��o n�o permitida.".
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

    /* Valida a Origem da Sugest�o */
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
            ASSIGN m-erros = m-erros + "Tipo de Origem inv�lido.".
            RETURN "NOK".
        END.
    END.

    /* Verifica se a origem foi alterada */
    IF {&tttabela}.cdorisug <> {&tabela}.cdorisug THEN
    DO:
        ASSIGN m-erros = m-erros + "Altera��o de Origem n�o � permitida.".
        RETURN "NOK".
    END.

    /* Verifica se o texto da sugest�o n�o � branco */
    IF TRIM({&tttabela}.dssugeve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Texto da Sugest�o n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se a data do movimento n�o � nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data da sugest�o n�o pode ser nula.".
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

    /* Verifica se o cooperado existe no cadastro */
    FIND FIRST crapttl WHERE crapttl.nrdconta = {&tttabela}.nrdconta    AND
                             crapttl.idseqttl = {&tttabela}.idseqttl    AND 
                             crapttl.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapttl AND {&tttabela}.cdorisug = 4 THEN
    DO:
        ASSIGN m-erros = m-erros + "Cooperado n�o encontrado.".
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
        {&tabela}.dssugeve = TRIM(CAPS({&tabela}.dssugeve))
        .

    IF {&tabela}.qtsugeve = 0 THEN
    DO:
        ASSIGN {&tabela}.qtsugeve = 1.
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

    IF {&tttabela}.dtanoage <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Sugest�o possui ano de agenda. Exclus�o n�o permitida.".
        RETURN "NOK".
    END.

    IF {&tttabela}.cdevento <> ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Sugest�o possui evento relacionado. Exclus�o n�o permitida.".
        RETURN "NOK".
    END.
    
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
