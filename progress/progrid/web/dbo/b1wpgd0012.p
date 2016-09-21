/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0012.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Fornecedores
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
               
               04/05/2009 - Adicionada verificação dos campos de data de nascimento
                            nos dados bancários do fornecedor e de data de inicio de 
                            vigencia e data do fim da vigencia no formulário principal.
                            Projeto 229 - Melhorias OQS(Lombardi).
............................................................................ */
&SCOPED-DEFINE tttabela gnatfdp
&SCOPED-DEFINE tabela   gnapfdp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros AS CHAR FORMAT "x(256)" NO-UNDO.

DEFINE NEW SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" NO-UNDO.
DEFINE NEW SHARED VAR glb_stsnrcal AS LOGICAL                         NO-UNDO.
DEFINE NEW SHARED VAR shr_inpessoa AS INTEGER                         NO-UNDO.

/*** Declaração de BOs auxiliares ***/
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
/*  Objetivo: Verifica se o registro da tabela temporária está OK para ser inserido na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.      */
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                     */
/*       m-erros = Guarda a mensagem de erro da validação                                             */
PROCEDURE valida-inclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

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
            
    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Operador 
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Operador inválido.".
        RETURN "NOK".
    END.
    */
    /* Valida data de cadastramento do fornecedor */
    IF {&tttabela}.dtforati = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Cadastramento do Fornecedor é inválida.".
        RETURN "NOK".
    END.

    /* Valida data de atualização do fornecedor */
    IF {&tttabela}.dtultalt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Atualização do Fornecedor é inválida.".
        RETURN "NOK".
    END.
    
    /* Valida data de atualização do fornecedor */
    IF {&tttabela}.dtnasfor = ? AND {&tttabela}.cddbanco <> ? AND {&tttabela}.inpesrcb = 1 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Nascimento do Fornecedor é inválida.".
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

    /* Valida o Tipo de Pessoa, se é Fisica ou Jurídica */
    IF {&tttabela}.inpessoa <> 1 /* Física */
       AND {&tttabela}.inpessoa <> 2 /* Jurídica */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Tipo de Pessoa inválido.".
        RETURN "NOK".
    END.

    /* Valida o nome da cooperativa do fornecedor, caso ele seja um cooperado */
    IF {&tttabela}.flgcoope = YES AND TRIM({&tttabela}.nmcoofor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome da Cooperativa do Fornecedor não pode ser branco, quando for selecionado 'Cooperado'.".
        RETURN "NOK".
    END.

    /* Valida o nome do fornecedor */
    IF TRIM({&tttabela}.nmfornec) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Fornecedor não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida unicidade de CPF/CNPJ na tabela */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "CPF/CNPJ já utilizado no cadastro.".
        RETURN "NOK".
    END.

    /* Verifica se o CPF/CPNJ é válido */
    ASSIGN
        glb_nrcalcul = {&tttabela}.nrcpfcgc.
    IF SEARCH("fontes/cpfcgc.p") <> ? THEN
        RUN fontes/cpfcgc.p.

    IF NOT glb_stsnrcal THEN
    DO:
        /* Se a validação de pessoa física não deu certo */
        IF {&tttabela}.inpessoa = 1 THEN
        DO:
            ASSIGN m-erros = m-erros + "CPF inválido.".
            RETURN "NOK".
        END.
        /* Se a validação de pessoa jurídica não deu certo */
        ELSE
        DO:
            ASSIGN m-erros = m-erros + "CNPJ inválido.".
            RETURN "NOK".
        END.
    END.

    /* Se foi informado um tipo de pessoa e passado número do outro tipo de pessoa */
    IF shr_inpessoa <> {&tttabela}.inpessoa THEN
    DO:
        ASSIGN m-erros = m-erros + "Número de identificação não confere com o tipo de pessoa.".
        RETURN "NOK".
    END.

    /* Valida se cidade está em branco */
    IF TRIM({&tttabela}.nmcidfor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do Fornecedor não pode ser branco.".
        RETURN "NOK".
    END.

    /* Data de inativo não pode ser menor que data de ativo */
    IF {&tttabela}.dtforina <> ? AND {&tttabela}.dtforina < {&tttabela}.dtforati THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de inativo não pode ser menor do que data de ativo.".
        RETURN "NOK".
    END.

    /* CEP tem tamanho limitado */
    IF {&tttabela}.nrcepfor > 99999999 THEN
    DO:
        ASSIGN m-erros = m-erros + "CEP inválido.".
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
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */    

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.
      
    /* Cria o registro na tabela fisica, a partir da tabela temporária */
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.
    
    IF {&tttabela}.idforpri = 1 THEN /* somente um fornecedor poderá ser o principal fornecedor de material de divulgação*/
      DO: 
        FOR EACH {&tabela} WHERE {&tabela}.idforpri = 1 EXCLUSIVE-LOCK: 
          ASSIGN {&tabela}.idforpri = 0.      
        END.
    END.
    
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Efetuar sobreposições necessárias */ 

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
    
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.

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

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Operador
    FIND FIRST crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper    AND
                             crapope.cdoperad = {&tttabela}.cdoperad    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Operador inválido.".
        RETURN "NOK".
    END.
    */
    /* Valida data de cadastramento do fornecedor */
    IF {&tttabela}.dtforati = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Cadastramento do Fornecedor é inválida.".
        RETURN "NOK".
    END.

    /* Valida data de atualização do fornecedor */
    IF {&tttabela}.dtultalt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Atualização do Fornecedor é inválida.".
        RETURN "NOK".
    END.

    /* Valida data de nascimento do fornecedor */
    IF {&tttabela}.dtnasfor = ? AND {&tttabela}.cddbanco <> ? AND {&tttabela}.inpesrcb = 1 THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Nascimento do Fornecedor é inválida.".
        RETURN "NOK".
    END.
    
    /* Valida data de atualização do fornecedor */
    IF {&tttabela}.dtinivig = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Inicio da Vigencia é inválida.".
        RETURN "NOK".
    END.
    
    /* Valida data de atualização do fornecedor */
    IF {&tttabela}.dtfimvig = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Fim da Vigencia é inválida.".
        RETURN "NOK".
    END.
    
    IF {&tttabela}.dtinivig > {&tttabela}.dtfimvig THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de Inicio da Vigencia não pode ser maior que data de Fim.".
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

    /* Valida o Tipo de Pessoa, se é Fisica ou Jurídica */
    IF {&tttabela}.inpessoa <> 1 /* Física */
       AND {&tttabela}.inpessoa <> 2 /* Jurídica */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Tipo de Pessoa inválido.".
        RETURN "NOK".
    END.

    /* Valida o nome da cooperativa do fornecedor, caso ele seja um cooperado */
    IF {&tttabela}.flgcoope = YES AND TRIM({&tttabela}.nmcoofor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome da Cooperativa do Fornecedor não pode ser branco, quando for selecionado 'Cooperado'.".
        RETURN "NOK".
    END.

    /* Valida o nome do fornecedor */
    IF TRIM({&tttabela}.nmfornec) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Fornecedor não pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se CPF/CNPJ foi alterado */
    IF {&tabela}.nrcpfcgc <> {&tttabela}.nrcpfcgc THEN
    DO:
        ASSIGN m-erros = m-erros + "Não é permitida a alteração de CPF/CNPJ.".
        RETURN "NOK".
    END.

    /* Verifica se foi alterado o tipo de pessoa */
    IF {&tabela}.inpessoa <> {&tttabela}.inpessoa THEN
    DO:
        ASSIGN m-erros = m-erros + "Não é permitida a alteração do tipo de pessoa.".
        RETURN "NOK".
    END.

    /* Valida se cidade está em branco */
    IF TRIM({&tttabela}.nmcidfor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do Fornecedor não pode ser branco.".
        RETURN "NOK".
    END.

    /* Data de inativo não pode ser menor que data de ativo */
    IF {&tttabela}.dtforina <> ? AND {&tttabela}.dtforina < {&tttabela}.dtforati THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de inativo não pode ser menor do que data de ativo.".
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
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.
    
    IF {&tttabela}.idforpri = 1 THEN /* somente um fornecedor poderá ser o principal fornecedor de material de divulgação*/
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

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc EXCLUSIVE-LOCK NO-ERROR.
    
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */  
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

    DEF VAR aux-m-erros AS CHAR NO-UNDO.

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela física o registro correspondente à tabela temporaria */    
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.

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

    /*************** INCLUIR AQUI AS VALIDAÇÕES DE EXCLUSÃO DE:
    - CONTATOS
    - EIXOS DE ATUAÇÃO
    - PROPOSTAS
    - FACILITADORES DAS PROPOSTAS
    - FACILITADORES DO FORNECEDOR 
    ***********************************************************/

    /* Fim - Validações específicas */

    /*m-erros = m-erros + "Passou ileso(2).".*/
    IF m-erros <> "" THEN
        RETURN "NOK".
    ELSE
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

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */    
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND 
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc EXCLUSIVE-LOCK NO-ERROR.

    /* exclui contatos */
    FOR EACH gnapcfp WHERE gnapcfp.cdcooper = 0                     AND
                           gnapcfp.nrcpfcgc = {&tttabela}.nrcpfcgc  EXCLUSIVE-LOCK:
        DELETE gnapcfp NO-ERROR.
    END.

    /* exclui eixos de atuação */
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
