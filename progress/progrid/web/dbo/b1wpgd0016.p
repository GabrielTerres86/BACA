/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0016.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 07/07/2016

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Facilitadores
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
   
               16/10/2012 - Ajuste para o DataServer Oracle (Gabriel)  
               
               07/07/2016 - Alterar para permitir informar os campos conforme informado
                            maiusculo/minusculo, para melhor exibi�ao nos relatorios.
                            PRJ229 - Melhorias OQS (Odirlei-AMcom)
............................................................................ */
&SCOPED-DEFINE tttabela gnatfep
&SCOPED-DEFINE tabela   gnapfep


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqfep AS INT                  NO-UNDO.

/* Vari�veis usadas na valida��o de CPF/CNPJ */
DEFINE NEW SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" NO-UNDO.
DEFINE NEW SHARED VAR glb_stsnrcal AS LOGICAL                         NO-UNDO.
DEFINE NEW SHARED VAR shr_inpessoa AS INTEGER                         NO-UNDO.

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
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se o curriculum n�o � branco */
    IF TRIM({&tttabela}.dscurric) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Curriculum do Facilitador n�o pode ser branco.".
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

    /* Valida se o curriculum n�o � branco */
    IF TRIM({&tttabela}.nmfacili) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Facilitador n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se o fornecedor existe com este CPF/CNPJ */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor n�o encontrado com este CPF/CNPJ.".
        RETURN "NOK".
    END.

    ASSIGN aux_nrseqfep = NEXT-VALUE(nrseqfep).

    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0            AND
                               {&tabela}.cdfacili = aux_nrseqfep NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Problemas com a sequ�ncia do facilitador.".
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

    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dsavalia = TRIM({&tabela}.dsavalia)
           {&tabela}.dscurric = TRIM({&tabela}.dscurric)
           {&tabela}.nmfacili = TRIM({&tabela}.nmfacili)
           {&tabela}.cdfacili = CURRENT-VALUE(nrseqfep).

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
                               {&tabela}.cdfacili = {&tttabela}.cdfacili NO-LOCK NO-ERROR.

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
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se o curriculum n�o � branco */
    IF TRIM({&tttabela}.dscurric) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Resumo do Curriculo Facilitador nao pode ser branco 1.".
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

    /* Valida se o curriculum n�o � branco */
    IF TRIM({&tttabela}.nmfacili) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Facilitador n�o pode ser branco 2.".
        RETURN "NOK".
    END.

    /* Valida se o fornecedor existe com este CPF/CNPJ */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor n�o encontrado com este CPF/CNPJ.".
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
                               {&tabela}.cdfacili = {&tttabela}.cdfacili EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */

    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dsavalia = TRIM({&tabela}.dsavalia)
           {&tabela}.dscurric = TRIM({&tabela}.dscurric)
           {&tabela}.nmfacili = TRIM({&tabela}.nmfacili).

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
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.cdfacili = {&tttabela}.cdfacili NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro n�o encontrado para exclus�o(16).".
        RETURN "NOK".
    END.
    /* Fim - Valida��es obrigat�rias a todas as tabelas */

    /* Valida��es espec�ficas */
    /* No caso de erro de valida��o, a forma de tratamento � a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */

    FIND FIRST gnfacep WHERE gnfacep.cdcooper = 0                    AND
                             gnfacep.cdfacili = {&tttabela}.cdfacili NO-LOCK NO-ERROR.
    IF AVAIL gnfacep THEN
    DO:
        ASSIGN m-erros = m-erros + "Facilitador est� vinculado a proposta(s).".
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
                               {&tabela}.cdfacili = {&tttabela}.cdfacili EXCLUSIVE-LOCK NO-ERROR.

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
