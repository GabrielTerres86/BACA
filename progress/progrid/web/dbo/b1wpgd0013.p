/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0013.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Locais para Eventos
   
   Alterações: 25/01/2008 - Incluído campo "Referência" (Diego).

               16/10/2012 - Tratar DataServer Oracle (Gabriel).
               
               29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela cratldp
&SCOPED-DEFINE tabela   crapldp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqldp AS INT                  NO-UNDO.

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
    IF NOT AVAIL crapage THEN 
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic + " " + STRING({&tttabela}.cdagenci) + STRING({&tttabela}.cdcooper).
        ELSE
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro. Cooperativa: " + STRING({&tttabela}.cdcooper) + ", PA: " + STRING({&tttabela}.cdagenci).
        
        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida se o Endereço do Local está em branco */
    IF TRIM({&tttabela}.dsendloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Endereço do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Estrutura do Local está em branco */
    IF TRIM({&tttabela}.dsestloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Estrutura do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Descrição do Local está em branco */
    IF TRIM({&tttabela}.dslocal) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descrição do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se é progrid ou assembléia */
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida se a Cidade do Local está em branco */
    IF TRIM({&tttabela}.nmcidloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do local não pode ser branco.".
        RETURN "NOK".
    END.

        /* Valida se o valor diário está no limite aceitável pela tabela */
    IF {&tttabela}.vldialoc > 9999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor diário está acima do aceitável pelo campo (9.999,99).".
        RETURN "NOK".
    END.
    
    ASSIGN aux_nrseqldp = NEXT-VALUE(nrseqldp).

    /* Verifica se a sequência ainda não foi utilizada */
    FIND FIRST {&tabela} WHERE {&tabela}.nrseqdig = aux_nrseqldp NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Problemas com o código de sequência do local do evento".
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

    ASSIGN {&tabela}.nrseqdig = CURRENT-VALUE(nrseqldp)
           {&tabela}.dsendloc = TRIM(CAPS({&tabela}.dsendloc))
           {&tabela}.dsestloc = TRIM(CAPS({&tabela}.dsestloc))
           {&tabela}.dslocali = TRIM(CAPS({&tabela}.dslocali))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv))
           {&tabela}.nmbailoc = TRIM(CAPS({&tabela}.nmbailoc))
           {&tabela}.nmcidloc = TRIM(CAPS({&tabela}.nmcidloc))
           {&tabela}.nmconloc = TRIM(CAPS({&tabela}.nmconloc))
                   {&tabela}.dsrefloc = TRIM(CAPS({&tabela}.dsrefloc)).                                           

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
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/

    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
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

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage THEN 
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida se o Endereço do Local está em branco */
    IF TRIM({&tttabela}.dsendloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Endereço do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Estrutura do Local está em branco */
    IF TRIM({&tttabela}.dsestloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Estrutura do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Descrição do Local está em branco */
    IF TRIM({&tttabela}.dslocal) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descrição do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se é progrid ou assembléia */
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
        AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida se a Cidade do Local está em branco */
    IF TRIM({&tttabela}.nmcidloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do local não pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se o valor diário está no limite aceitável pela tabela */
    IF {&tttabela}.vldialoc > 9999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor diário está acima do aceitável pelo campo (9.999,99).".
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
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig EXCLUSIVE-LOCK NO-ERROR.
                               
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.dsendloc = TRIM(CAPS({&tabela}.dsendloc))
           {&tabela}.dsestloc = TRIM(CAPS({&tabela}.dsestloc))
           {&tabela}.dslocali = TRIM(CAPS({&tabela}.dslocali))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv))
           {&tabela}.nmbailoc = TRIM(CAPS({&tabela}.nmbailoc))
           {&tabela}.nmcidloc = TRIM(CAPS({&tabela}.nmcidloc))
           {&tabela}.nmconloc = TRIM(CAPS({&tabela}.nmconloc))
                   {&tabela}.dsrefloc = TRIM(CAPS({&tabela}.dsrefloc)).

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
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    /* Validações Obrigatórias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro não encontrado para exclusão.".
        RETURN "NOK".
    END.

    FIND FIRST crapadp WHERE crapadp.idevento = {&tttabela}.idevento AND
                             crapadp.cdcooper = {&tttabela}.cdcooper AND
                             crapadp.cdagenci = {&tttabela}.cdagenci AND
                             crapadp.cdlocali = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    IF   AVAIL crapadp  THEN
         DO: 
             ASSIGN m-erros = m-erros + "Local de evento já está sendo utilizado.".
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
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

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
    DEFINE INPUT  PARAMETER ponteiro     AS ROWID                   NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR    FORMAT "x(256)" NO-UNDO.

    FIND FIRST {&tabela} WHERE ROWID({&tabela}) = ponteiro NO-LOCK NO-ERROR.

    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN retorno-erro = "Registro não encontrado.".
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.
