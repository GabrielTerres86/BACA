/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0015.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Evandro
   Data    : Setembro/2005                      Ultima atualizacao: 16/10/2012

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Recursos
   
   Alteracoes: 30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
   
               16/10/2012 - Ajustes para o DataServer Oracle (Gabriel). 
............................................................................ */
&SCOPED-DEFINE tttabela gnatrdp
&SCOPED-DEFINE tabela   gnaprdp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros AS CHAR FORMAT "x(256)" NO-UNDO.

DEFINE VARIABLE aux_nrseqrdp AS INTEGER    NO-UNDO.

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
    IF TRIM({&tttabela}.dsrecurs) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descrição do Recurso não pode ser branco.".
        RETURN "NOK".
    END.

    /* valida o código de cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
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
    
    /* Sequencia nao pode aparecer numa clausula de where */
    ASSIGN aux_nrseqrdp = NEXT-VALUE(nrseqrdp).
    
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0            AND
                               {&tabela}.nrseqdig = aux_nrseqrdp NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Erro na sequência do código do recurso.".
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
/*       aux_nrdrowid = Rowid do registro criado                                                  */
PROCEDURE inclui-registro:
    DEFINE INPUT  PARAMETER TABLE FOR {&tttabela}.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela temporária */
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} EXCEPT {&tttabela}.nrseqdig TO {&tabela}.
    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Efetuar sobreposições necessárias */ 
    ASSIGN aux_nrdrowid       = STRING(ROWID({&tabela}))
           {&tabela}.nrseqdig = CURRENT-VALUE(nrseqrdp)
           {&tabela}.cdcooper = 0
           {&tabela}.dsrecurs = TRIM(CAPS({&tabela}.dsrecurs)).
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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro não encontrado para alteração.".
        RETURN "NOK".
    END.
    /* Fim - Validações obrigatórias a todas as tabelas */

    /* Validações específicas */
    IF TRIM({&tttabela}.dsrecurs) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descrição do Recurso não pode ser branco.".
        RETURN "NOK".

    END.

    /* valida o código de cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig 
                               EXCLUSIVE-LOCK NO-ERROR.
    
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} EXCEPT {&tttabela}.nrseqdig TO {&tabela} NO-ERROR.
    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 
    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dsrecurs = CAPS({&tabela}.dsrecurs).

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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = 0                    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro não encontrado para exclusão.".
        RETURN "NOK".
    END.
    /* Fim - Validações obrigatórias a todas as tabelas */

    /* Validações específicas */
    /* Verifica se o recurso está relacionado a algum evento */
    FIND FIRST craprep WHERE craprep.cdcooper = 0                    AND
                             craprep.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    IF AVAIL craprep THEN
    DO:
        ASSIGN m-erros = m-erros + "Recurso possui eventos relacionados.".
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

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = 0                    AND
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
