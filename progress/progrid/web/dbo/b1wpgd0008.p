/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0008.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 07/12/2016

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Eventos
   
   Alterações: 14/12/2007 - Atribuir "1" em Participação permitida quando for 
                            Assembléia (Diego).
                            
               30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).      
               
               16/12/2012 - Ajustes para o DataServer Oracle (Gabriel).       
               
               07/12/2016 - Retirada de tratamento de maximo de participantes e
                            quantidade minima por turma, Prj. 229 (Jean Michel).
............................................................................ */
&SCOPED-DEFINE tttabela cratedp
&SCOPED-DEFINE tabela   crapedp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqedp AS INT                  NO-UNDO.

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

    /* verifica se o eixo temático selecionado existe */
    /* Se for idevento = 2 - ASSEMBLEIA, lê o unico eixo para assembleias */
    IF {&tttabela}.idevento = 2 THEN
       DO:
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                     AND
                                   gnapetp.idevento = {&tttabela}.idevento  NO-LOCK NO-ERROR.

          IF NOT AVAIL gnapetp THEN
             DO:
                 ASSIGN m-erros = m-erros + "Eixo temático inexistente".
                 RETURN "NOK".
             END.

          ASSIGN {&tttabela}.cdeixtem = gnapetp.cdeixtem
                 {&tttabela}.prfreque = 100
				 {&tttabela}.tppartic = 1.
       END.
    ELSE
       DO:
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                     AND
                                   gnapetp.cdeixtem = {&tttabela}.cdeixtem  AND
                                   gnapetp.idevento = {&tttabela}.idevento  NO-LOCK NO-ERROR.

          IF NOT AVAIL gnapetp THEN
             DO:
                 ASSIGN m-erros = m-erros + "Eixo temático inexistente".
                 RETURN "NOK".
             END.
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

    /* Valida o nome do evento */
    IF TRIM({&tttabela}.nmevento) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a frequência é menor ou igual a 100% */
    IF {&tttabela}.prfreque > 100 THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento não pode ser branco.".
        RETURN "NOK".
    END.


    /* Validações para eventos do Progrid (Assembléias não possuem essas validações) */
    IF {&tttabela}.idevento = 1 THEN 
    DO:
    
        /* verifica se o tipo de evento existe */
        FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "CONFIG"        AND
                                 craptab.cdempres = 0               AND
                                 craptab.cdacesso = "PGTPEVENTO"    AND
                                 craptab.tpregist = 0               NO-LOCK NO-ERROR.
        IF AVAIL craptab THEN
        DO:
            IF lookup(string({&tttabela}.tpevento), craptab.dstextab, ",") = 0 THEN 
            DO:
                ASSIGN m-erros = m-erros + "Tipo de Evento inválido.".
                RETURN "NOK".
            END.
        END.
    
        /* verifica se a quantidade de participantes por turma é maior ou igual que o 
           mínimo por turma */
        /*IF {&tttabela}.qtmaxtur < {&tttabela}.qtmintur THEN
        DO:
            ASSIGN m-erros = m-erros + "Quantidade mínima por turma deve ser menor ou igual a quantidade de participantes.".
            RETURN "NOK".
        END.
        */
    END.

    /* Evento de Integração deve ser único */
    FIND FIRST crapedp WHERE crapedp.tpevento = 2   AND 
                             crapedp.cdcooper = 0   NO-LOCK NO-ERROR.

    IF AVAIL crapedp AND {&tttabela}.tpevento = 2 AND {&tttabela}.cdcooper = 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Evento Integração já existe na base.".
        RETURN "NOK".
    END.
    
    /* Sequencia nao pode aparecer numa clausula de where */
    aux_nrseqedp = NEXT-VALUE(nrseqedp).
    
    /* Valida se a sequência que vai ser usada ainda não existe na tabela */
    FIND FIRST {&tabela} WHERE {&tabela}.cdevento = aux_nrseqedp NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO: 
        ASSIGN m-erros = m-erros + "Erro na sequência do código do evento.".
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

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-inclusao(INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela temporária */

    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} EXCEPT cdevento TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.cdevento = CURRENT-VALUE(nrseqedp)
           {&tabela}.dtanoage = 0
           {&tabela}.nmevento = TRIM(CAPS({&tabela}.nmevento)).

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

    /* Procura na tabela física o registro correspondente a tabela temporaria */
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

    
    /* verifica se o eixo temático selecionado existe */
    /* Se for idevento = 2 - ASSEMBLEIA, lê o unico eixo para assembleias */
    IF {&tttabela}.idevento = 2 THEN
       DO:
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                     AND
                                   gnapetp.idevento = {&tttabela}.idevento  NO-LOCK NO-ERROR.

          IF NOT AVAIL gnapetp THEN
             DO:
                 ASSIGN m-erros = m-erros + "Eixo temático inexistente".
                 RETURN "NOK".
             END.

          ASSIGN {&tttabela}.cdeixtem = gnapetp.cdeixtem.
       END.
    ELSE
       DO:
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                     AND
                                   gnapetp.cdeixtem = {&tttabela}.cdeixtem  AND
                                   gnapetp.idevento = {&tttabela}.idevento  NO-LOCK NO-ERROR.

          IF NOT AVAIL gnapetp THEN
             DO:
                 ASSIGN m-erros = m-erros + "Eixo temático inexistente".
                 RETURN "NOK".
             END.
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

    /* Valida o nome do evento */
    IF TRIM({&tttabela}.nmevento) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a frequência é menor ou igual a 100% */
    IF {&tttabela}.prfreque > 100 THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento não pode ser branco.".
        RETURN "NOK".
    END.


    /* Validações para eventos do Progrid (Assembléias não possuem essas validações) */
    IF {&tttabela}.idevento = 1 THEN 
    DO:
    
        /* verifica se o tipo de evento existe */
        FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "CONFIG"        AND
                                 craptab.cdempres = 0               AND
                                 craptab.cdacesso = "PGTPEVENTO"    AND
                                 craptab.tpregist = 0               NO-LOCK NO-ERROR.
        
        IF AVAIL craptab THEN
        DO:
            IF lookup(string({&tttabela}.tpevento), craptab.dstextab, ",") = 0 THEN 
            DO:
                ASSIGN m-erros = m-erros + "Tipo de Evento inválido.".
                RETURN "NOK".
            END.
        END.
    
        /* verifica se a quantidade de participantes por turma é maior ou igual que o 
           mínimo por turma */
        /*IF {&tttabela}.qtmaxtur < {&tttabela}.qtmintur THEN
        DO:
            ASSIGN m-erros = m-erros + "Quantidade mínima por turma deve ser menor ou igual a quantidade de participantes.".
            RETURN "NOK".
        END.
        */
    END.

    /* Evento de Integração deve ser único */
    FIND FIRST crapedp WHERE crapedp.tpevento  = 2                      AND 
                             crapedp.cdcooper  = 0                      AND 
                             crapedp.cdevento <> {&tttabela}.cdevento   NO-LOCK NO-ERROR.

    IF AVAIL crapedp AND {&tttabela}.tpevento = 2 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Evento Integração já existe na base.".
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

    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente a tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */

    ASSIGN
        {&tabela}.nmevento = TRIM(CAPS({&tabela}.nmevento)).

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

    /* Procura na tabela física o registro correspondente a tabela temporaria */
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
            
    /* Verifica se o evento não está relacionado com alguma sugestão */
    FIND FIRST crapsdp WHERE crapsdp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF AVAIL crapsdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento possui sugestões relacionadas. Exclusão não permitida. ".
        RETURN "NOK".
    END.

    FIND FIRST gnappdp WHERE gnappdp.cdcooper = 0                    AND
                             gnappdp.cdevento = {&tttabela}.cdevento NO-LOCK NO-ERROR.
    IF AVAIL gnappdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento possui propostas relacionadas. Exclusão não permitida. ".
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

    /* Procura na tabela física o registro correspondente a tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.

    /* Elimina todos os Recursos associados a esse evento */
    FOR EACH craprep WHERE craprep.idevento = crapedp.idevento  AND
                           craprep.cdcooper = 0                 AND 
                           craprep.cdevento = crapedp.cdevento  EXCLUSIVE-LOCK:

        DELETE craprep.
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
