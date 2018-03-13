/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0012.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Fornecedores
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
               
               04/05/2009 - Adicionada verifica��o dos campos de data de nascimento
                            nos dados banc�rios do fornecedor e de data de inicio de 
                            vigencia e data do fim da vigencia no formul�rio principal.
                            Projeto 229 - Melhorias OQS(Lombardi).
............................................................................ */
&SCOPED-DEFINE tttabela gnatfdp
&SCOPED-DEFINE tabela   gnapfdp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros AS CHAR FORMAT "x(256)" NO-UNDO.

DEFINE NEW SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" NO-UNDO.
DEFINE NEW SHARED VAR glb_stsnrcal AS LOGICAL                         NO-UNDO.
DEFINE NEW SHARED VAR shr_inpessoa AS INTEGER                         NO-UNDO.

/*** Declara��o de BOs auxiliares ***/
DEFINE VARIABLE h-b1wpgd0012a AS HANDLE NO-UNDO.
DEFINE VARIABLE h-b1wpgd0012b AS HANDLE NO-UNDO.
DEFINE VARIABLE h-b1wpgd0012c AS HANDLE NO-UNDO.
DEFINE VARIABLE h-b1wpgd0016  AS HANDLE NO-UNDO.

DEFINE TEMP-TABLE gnatcfp   LIKE gnapcfp.
DEFINE TEMP-TABLE gnatefp   LIKE gnapefp.
DEFINE TEMP-TABLE gnatpdp   LIKE gnappdp.
DEFINE TEMP-TABLE gnatfep   LIKE gnapfep.

DEFINE TEMP-TABLE ttgnapcfp LIKE gnapcfp.

DEFINE BUFFER bfgnapcfp FOR gnapcfp.  
DEFINE BUFFER bfgnapefp FOR gnapefp.  
DEFINE BUFFER bfgnappdp FOR gnappdp.  
DEFINE BUFFER bfgnapfep FOR gnapfep.  

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
            
    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Operador 
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
        RETURN "NOK".
    END.
    */
    /* Valida data de cadastramento do fornecedor */
    IF {&tttabela}.dtforati = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Cadastramento do Fornecedor � inv�lida.".
        RETURN "NOK".
    END.

    /* Valida data de atualiza��o do fornecedor */
    IF {&tttabela}.dtultalt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Atualiza��o do Fornecedor � inv�lida.".
        RETURN "NOK".
    END.
    
    /* Valida data de atualiza��o do fornecedor */
    IF {&tttabela}.dtnasfor = ? AND {&tttabela}.cddbanco <> ? AND {&tttabela}.inpesrcb = 1 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Nascimento do Fornecedor � inv�lida.".
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

    /* Valida o Tipo de Pessoa, se � Fisica ou Jur�dica */
    IF {&tttabela}.inpessoa <> 1 /* F�sica */
       AND {&tttabela}.inpessoa <> 2 /* Jur�dica */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Tipo de Pessoa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o nome da cooperativa do fornecedor, caso ele seja um cooperado */
    IF {&tttabela}.flgcoope = YES AND TRIM({&tttabela}.nmcoofor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome da Cooperativa do Fornecedor n�o pode ser branco, quando for selecionado 'Cooperado'.".
        RETURN "NOK".
    END.

    /* Valida o nome do fornecedor */
    IF TRIM({&tttabela}.nmfornec) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Fornecedor n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida unicidade de CPF/CNPJ na tabela */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "CPF/CNPJ j� utilizado no cadastro.".
        RETURN "NOK".
    END.

    /* Verifica se o CPF/CPNJ � v�lido */
    ASSIGN
        glb_nrcalcul = {&tttabela}.nrcpfcgc.
    IF SEARCH("fontes/cpfcgc.p") <> ? THEN
        RUN fontes/cpfcgc.p.

    IF NOT glb_stsnrcal THEN
    DO:
        /* Se a valida��o de pessoa f�sica n�o deu certo */
        IF {&tttabela}.inpessoa = 1 THEN
        DO:
            ASSIGN m-erros = m-erros + "CPF inv�lido.".
            RETURN "NOK".
        END.
        /* Se a valida��o de pessoa jur�dica n�o deu certo */
        ELSE
        DO:
            ASSIGN m-erros = m-erros + "CNPJ inv�lido.".
            RETURN "NOK".
        END.
    END.

    /* Se foi informado um tipo de pessoa e passado n�mero do outro tipo de pessoa */
    IF shr_inpessoa <> {&tttabela}.inpessoa THEN
    DO:
        ASSIGN m-erros = m-erros + "N�mero de identifica��o n�o confere com o tipo de pessoa.".
        RETURN "NOK".
    END.

    /* Valida se cidade est� em branco */
    IF TRIM({&tttabela}.nmcidfor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do Fornecedor n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Data de inativo n�o pode ser menor que data de ativo */
    IF {&tttabela}.dtforina <> ? AND {&tttabela}.dtforina < {&tttabela}.dtforati THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de inativo n�o pode ser menor do que data de ativo.".
        RETURN "NOK".
    END.

    /* CEP tem tamanho limitado */
    IF {&tttabela}.nrcepfor > 99999999 THEN
    DO:
        ASSIGN m-erros = m-erros + "CEP inv�lido.".
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

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.
      
    /* Cria o registro na tabela fisica, a partir da tabela tempor�ria */
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.
    
    IF {&tttabela}.idforpri = 1 THEN /* somente um fornecedor poder� ser o principal fornecedor de material de divulga��o*/
      DO: 
        FOR EACH {&tabela} WHERE {&tabela}.idforpri = 1 EXCLUSIVE-LOCK: 
          ASSIGN {&tabela}.idforpri = 0.      
        END.
    END.
    
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dtultalt = TODAY
           {&tabela}.cdufforn = CAPS(TRIM({&tabela}.cdufforn))
           {&tabela}.dsendfor = CAPS(TRIM({&tabela}.dsendfor))
           {&tabela}.dsobserv = CAPS(TRIM({&tabela}.dsobserv))
           {&tabela}.dsreffor = CAPS(TRIM({&tabela}.dsreffor))
           {&tabela}.nmbaifor = CAPS(TRIM({&tabela}.nmbaifor))
           {&tabela}.nmcidfor = CAPS(TRIM({&tabela}.nmcidfor))
           {&tabela}.nmcoofor = CAPS(TRIM({&tabela}.nmcoofor))
           {&tabela}.nmfornec = CAPS(TRIM({&tabela}.nmfornec))
           {&tabela}.nmhompag = CAPS(TRIM({&tabela}.nmhompag))
           {&tabela}.dsjusain = CAPS(TRIM({&tabela}.dsjusain)).

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
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.

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

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Operador
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
        RETURN "NOK".
    END.
    */
    /* Valida data de cadastramento do fornecedor */
    IF {&tttabela}.dtforati = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Cadastramento do Fornecedor � inv�lida.".
        RETURN "NOK".
    END.

    /* Valida data de atualiza��o do fornecedor */
    IF {&tttabela}.dtultalt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Atualiza��o do Fornecedor � inv�lida.".
        RETURN "NOK".
    END.

    /* Valida data de nascimento do fornecedor */
    IF {&tttabela}.dtnasfor = ? AND {&tttabela}.cddbanco <> ? AND {&tttabela}.inpesrcb = 1 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Nascimento do Fornecedor � inv�lida.".
        RETURN "NOK".
    END.
    
    /* Valida data de atualiza��o do fornecedor */
    IF {&tttabela}.dtinivig = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Inicio da Vigencia � inv�lida.".
        RETURN "NOK".
    END.
    
    /* Valida data de atualiza��o do fornecedor */
    IF {&tttabela}.dtfimvig = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Fim da Vigencia � inv�lida.".
        RETURN "NOK".
    END.
    
    IF {&tttabela}.dtinivig > {&tttabela}.dtfimvig THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Inicio da Vigencia n�o pode ser maior que data de Fim.".
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

    /* Valida o Tipo de Pessoa, se � Fisica ou Jur�dica */
    IF {&tttabela}.inpessoa <> 1 /* F�sica */
       AND {&tttabela}.inpessoa <> 2 /* Jur�dica */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Tipo de Pessoa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o nome da cooperativa do fornecedor, caso ele seja um cooperado */
    IF {&tttabela}.flgcoope = YES AND TRIM({&tttabela}.nmcoofor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome da Cooperativa do Fornecedor n�o pode ser branco, quando for selecionado 'Cooperado'.".
        RETURN "NOK".
    END.

    /* Valida o nome do fornecedor */
    IF TRIM({&tttabela}.nmfornec) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Fornecedor n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se CPF/CNPJ foi alterado */
    IF {&tabela}.nrcpfcgc <> {&tttabela}.nrcpfcgc THEN
    DO:
        ASSIGN m-erros = m-erros + "N�o � permitida a altera��o de CPF/CNPJ.".
        RETURN "NOK".
    END.

    /* Verifica se foi alterado o tipo de pessoa */
    IF {&tabela}.inpessoa <> {&tttabela}.inpessoa THEN
    DO:
        ASSIGN m-erros = m-erros + "N�o � permitida a altera��o do tipo de pessoa.".
        RETURN "NOK".
    END.

    /* Valida se cidade est� em branco */
    IF TRIM({&tttabela}.nmcidfor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do Fornecedor n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Data de inativo n�o pode ser menor que data de ativo */
    IF {&tttabela}.dtforina <> ? AND {&tttabela}.dtforina < {&tttabela}.dtforati THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de inativo n�o pode ser menor do que data de ativo.".
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
    
    IF {&tttabela}.idforpri = 1 THEN /* somente um fornecedor poder� ser o principal fornecedor de material de divulga��o*/
      DO: 
        FOR EACH {&tabela} WHERE {&tabela}.idforpri = 1 EXCLUSIVE-LOCK: 
          ASSIGN {&tabela}.idforpri = 0.      
        END.
    END.
    
    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc EXCLUSIVE-LOCK NO-ERROR.
    
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */  
    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dtultalt = TODAY
           {&tabela}.cdufforn = CAPS(TRIM({&tabela}.cdufforn))
           {&tabela}.dsendfor = CAPS(TRIM({&tabela}.dsendfor))
           {&tabela}.dsobserv = CAPS(TRIM({&tabela}.dsobserv))
           {&tabela}.dsreffor = CAPS(TRIM({&tabela}.dsreffor))
           {&tabela}.nmbaifor = CAPS(TRIM({&tabela}.nmbaifor))
           {&tabela}.nmcidfor = CAPS(TRIM({&tabela}.nmcidfor))
           {&tabela}.nmcoofor = CAPS(TRIM({&tabela}.nmcoofor))
           {&tabela}.nmfornec = CAPS(TRIM({&tabela}.nmfornec))
           {&tabela}.nmhompag = CAPS(TRIM({&tabela}.nmhompag))
           {&tabela}.dsjusain = CAPS(TRIM({&tabela}.dsjusain)).

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

    DEF VAR aux-m-erros AS CHAR NO-UNDO.

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */    
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.

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

    /*************** INCLUIR AQUI AS VALIDA��ES DE EXCLUS�O DE:
    - CONTATOS
    - EIXOS DE ATUA��O
    - PROPOSTAS
    - FACILITADORES DAS PROPOSTAS
    - FACILITADORES DO FORNECEDOR 
    ***********************************************************/

    /* Fim - Valida��es espec�ficas */

    /*m-erros = m-erros + "Passou ileso(2).".*/
    IF m-erros <> "" THEN
        RETURN "NOK".
    ELSE
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
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc EXCLUSIVE-LOCK NO-ERROR.

    /* exclui contatos */
    FOR EACH gnapcfp WHERE gnapcfp.cdcooper = 0                     AND
                           gnapcfp.nrcpfcgc = {&tttabela}.nrcpfcgc  EXCLUSIVE-LOCK:
        DELETE gnapcfp NO-ERROR.
    END.

    /* exclui eixos de atua��o */
    FOR EACH gnapefp WHERE gnapefp.cdcooper = 0                     AND
                           gnapefp.nrcpfcgc = {&tttabela}.nrcpfcgc  EXCLUSIVE-LOCK:
        DELETE gnapefp NO-ERROR.
    END.

    /* exclui propostas */
    FOR EACH gnappdp WHERE gnappdp.cdcooper = 0                     AND
                           gnappdp.nrcpfcgc = {&tttabela}.nrcpfcgc  EXCLUSIVE-LOCK:
        DELETE gnappdp NO-ERROR.
    END.

    /* exclui facilitadore das propostas */
    FOR EACH gnapfep WHERE gnapfep.cdcooper = 0                     AND
                           gnapfep.nrcpfcgc = {&tttabela}.nrcpfcgc  EXCLUSIVE-LOCK:
        DELETE gnapfep NO-ERROR.
    END.

    /* exclui facilitadores do fornecedor */
    FOR EACH gnfacep WHERE gnfacep.cdcooper = 0                     AND
                           gnfacep.nrcpfcgc = {&tttabela}.nrcpfcgc  EXCLUSIVE-LOCK:
        DELETE gnfacep NO-ERROR.
    END.

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
