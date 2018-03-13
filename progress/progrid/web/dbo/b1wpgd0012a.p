/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0012a.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Contatos do Fornecedor
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
   
               16/10/2012 - Ajustes DataServer Oracle (Gabriel). 
............................................................................ */
&SCOPED-DEFINE tttabela gnatcfp
&SCOPED-DEFINE tabela gnapcfp

DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VARIABLE m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VARIABLE aux_nrseqcfp AS INT                  NO-UNDO.

DEFINE BUFFER bf-gnapfdp FOR gnapfdp.

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
        RETURN "NOK":U.
    END.

    /* Fim - Validacoes obrigatórias a todas as tabelas */

    /* Validações específicas */
    /* No caso de erro de validação, a forma de tratamento é a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */

    /* Verifica se o nome do contato não é todo branco */
    IF TRIM({&tttabela}.nmconfor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Contato do Fornecedor não pode ser branco.".
        RETURN "NOK":U.
    END.

    /* Sequencia nao pode aparecer numa clausula de where */
    ASSIGN aux_nrseqcfp = NEXT-VALUE(nrseqcfp).
    
    /* Valida se a sequência que vai ser usada ainda não existe na tabela */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0            AND
                               {&tabela}.nrseqdig = aux_nrseqcfp NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Erro na sequência do código do contato.".
        RETURN "NOK":U.
    END.

    /* Verifica se o fornecedor existe */
    FIND FIRST bf-gnapfdp WHERE bf-gnapfdp.cdcooper = 0 AND
                                bf-gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL bf-gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor não encontrado.".
        RETURN "NOK":U.
    END.

    /* Fim - Validações Específicas */

    IF m-erros <> "" THEN
    DO:
        RETURN "NOK":U.
    END.
    ELSE
    DO:
       m-erros = m-erros + "Registro já implantado.".
       RETURN "OK":U.
    END.

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

    IF RETURN-VALUE = "NOK":U THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK":U.
    END.
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Cria o registro na tabela fisica, a partir da tabela temporária */
    CREATE {&tabela}.     
    BUFFER-COPY {&tttabela} TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).
    
    /* Efetuar sobreposições necessárias */ 
    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.nrseqdig = CURRENT-VALUE(nrseqcfp)
           {&tabela}.dsdepart = TRIM(CAPS({&tabela}.dsdepart))
           {&tabela}.nmconfor = TRIM(CAPS({&tabela}.nmconfor))
           {&tabela}.flgativo = YES
           {&tabela}.dsdemail = TRIM(CAPS({&tabela}.dsdemail)).

    /* Fim - Efetuar sobreposições necessárias */     
    
    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */
    
    
    DELETE {&tttabela} NO-ERROR.
    RETURN "OK":U.
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
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

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

    /* Verifica se o nome do contato não é todo branco */
    IF TRIM({&tttabela}.nmconfor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Contato do Fornecedor não pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se não foi alterado o CPF/CNPJ do fornecedor */
    IF {&tttabela}.nrcpfcgc <> {&tabela}.nrcpfcgc THEN
    DO:
        ASSIGN m-erros = m-erros + "CPF/CNPJ do Fornecedor não pode ser alterado.".
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
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    FIND FIRST bf-gnapfdp WHERE bf-gnapfdp.cdcooper = 0                  AND
                                bf-gnapfdp.nrcpfcgc = {&tabela}.nrcpfcgc NO-LOCK NO-ERROR.
                                
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dsdepart = TRIM(CAPS({&tabela}.dsdepart))
           {&tabela}.nmconfor = TRIM(CAPS({&tabela}.nmconfor))
           {&tabela}.idevento = bf-gnapfdp.idevento
           {&tabela}.cdcooper = bf-gnapfdp.cdcooper
           {&tabela}.flgativo = YES
           {&tabela}.dsdemail = TRIM(CAPS({&tabela}.dsdemail)).

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

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro gnapcfp não encontrado para exclusão.".
        RETURN "NOK".
    END.
    /* Fim - Validações obrigatórias a todas as tabelas */

    /* Validações específicas */
    /* No caso de erro de validação, a forma de tratamento é a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */
    
    /* Fim - Validações específicas */
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
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
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
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig EXCLUSIVE-LOCK NO-ERROR.

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
