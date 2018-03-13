/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0032.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                   Ultima atualizacao: 16/10/2012

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Itens de Avaliação
   
   Alteracoes: 29/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
   
               16/12/2012 - Ajustes para o DataServer Oracle (Gabriel). 
............................................................................ */
&SCOPED-DEFINE tttabela cratiap
&SCOPED-DEFINE tabela   crapiap


DEFINE TEMP-TABLE cratiap             
         FIELD idevento       LIKE crapiap.idevento
         FIELD cdcooper       LIKE crapiap.cdcooper
         FIELD cdgruava       LIKE crapiap.cdgruava
         FIELD cditeava       LIKE crapiap.cditeava
         FIELD dsiteava       LIKE crapiap.dsiteava
         FIELD nrordite       LIKE crapiap.nrordite.  

DEF VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEF VAR aux_nrseqiap AS INT                  NO-UNDO.

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

    /* Valida o Evento, se é progrid ou assembléia */
    IF {&tttabela}.idevento <> 1 AND   /* PROGRID    */
       {&tttabela}.idevento <> 2 THEN  /* ASSEMBLÉIA */       
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Sequencia nao pode aparecer numa clausula de where */
    ASSIGN aux_nrseqiap = NEXT-VALUE(nrseqiap).
    
    /* Valida se a sequência que vai ser usada ainda não existe na tabela */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0            AND
                               {&tabela}.cditeava = aux_nrseqiap NO-LOCK NO-ERROR.
    
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Erro na sequência do código do Item de Avaliação.".
        RETURN "NOK".
    END.

    /* Descrição não pode ser branco */
    IF TRIM({&tttabela}.dsiteava) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descrição do Item de Avaliação não pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se o grupo de avaliação existe */
    FIND FIRST crapgap WHERE crapgap.cdcooper = 0                    AND
                             crapgap.cdgruava = {&tttabela}.cdgruava NO-LOCK NO-ERROR.
                             
    IF NOT AVAIL crapgap THEN
    DO:
        ASSIGN m-erros = m-erros + "Grupo de Avaliação não encontrado.".
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

    IF RETURN-VALUE = "NOK" THEN 
    DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela temporária */

    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} EXCEPT cditeava TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.cditeava = CURRENT-VALUE(nrseqiap)
           {&tabela}.dsiteava = TRIM(CAPS({&tabela}.dsiteava)).

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
                               {&tabela}.cditeava = {&tttabela}.cditeava AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava NO-LOCK NO-ERROR.

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

    /* Valida o Evento, se é progrid ou assembléia */
    IF {&tttabela}.idevento <> 1 AND   /* PROGRID */
       {&tttabela}.idevento <> 2 THEN  /* ASSEMBLÉIA */
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Descrição não pode ser branco */
    IF TRIM({&tttabela}.dsiteava) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descrição do Item de Avaliação não pode ser branco.".
        RETURN "NOK".
    END.

    /* Verifica se o grupo de avaliação existe */
    FIND FIRST crapgap WHERE crapgap.cdcooper = 0                    AND
                             crapgap.cdgruava = {&tttabela}.cdgruava NO-LOCK NO-ERROR.
                             
    IF NOT AVAIL crapgap THEN
    DO:
        ASSIGN m-erros = m-erros + "Grupo de Avaliação não encontrado.".
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

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cditeava = {&tttabela}.cditeava AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava 
                               EXCLUSIVE-LOCK NO-ERROR.
    
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.cdcooper = 0
           {&tabela}.dsiteava = TRIM(CAPS({&tabela}.dsiteava)).

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
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cditeava = {&tttabela}.cditeava AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava NO-LOCK NO-ERROR.    

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

    /* Verifica se já não foi feito lançamento para este item */
    FIND FIRST craprap WHERE craprap.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.

    IF AVAIL craprap THEN
    DO:
        ASSIGN m-erros = m-erros + "Item de avaliação já foi utilizado.".
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
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cditeava = {&tttabela}.cditeava AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava 
                               EXCLUSIVE-LOCK NO-ERROR.

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
