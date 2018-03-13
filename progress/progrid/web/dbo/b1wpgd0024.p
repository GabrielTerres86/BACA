/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0024.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : outubro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de pessoas para a abertura dos eventos
   
   Alteracoes: 16/10/2012 - Ajustear para o DataServer Oracle (Gabriel).
               
               29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela crataep
&SCOPED-DEFINE tabela   crapaep


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqaep AS INT                  NO-UNDO.

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

    
    /* Se nao for TODOS os PA's */
    IF  {&tttabela}.cdagenci <> 0  THEN
        DO:
            /* Valida PA */
            FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                                     crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
            IF  NOT AVAIL crapage THEN 
            DO:
                FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

                IF  AVAILABLE crapcri  THEN     
                    ASSIGN m-erros = m-erros + crapcri.dscritic.
                ELSE
                    ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

                RETURN "NOK".
            END.
        END.

    /* Valida a Cooperativa */
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
        /*ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".*/
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida se o abridor esta preenchido */
    IF TRIM({&tttabela}.nmabreve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome pode ser branco.".
        RETURN "NOK".
    END.

    ASSIGN aux_nrseqaep = NEXT-VALUE(nrseqaep).
	
    /* Verifica se a sequência ainda não foi utilizada */
    FIND FIRST {&tabela} WHERE {&tabela}.nrseqdig = aux_nrseqaep NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
    
        ASSIGN m-erros = m-erros + "Problemas com o código de sequência do abridor do evento".

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

    ASSIGN {&tabela}.nrseqdig = CURRENT-VALUE(nrseqaep)
           {&tabela}.flgativo = {&tabela}.flgativo
           {&tabela}.nmabreve = TRIM(CAPS({&tabela}.nmabreve))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv)).
                                              

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

    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    NO-LOCK NO-ERROR.


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

    /* Se nao for TODOS os PA's */
    IF  {&tttabela}.cdagenci <> 0  THEN
        DO:
            /* Valida PA */
            FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                                     crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
            IF  NOT AVAIL crapage THEN 
            DO:
                FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.
                
                IF  AVAILABLE crapcri  THEN     
                    ASSIGN m-erros = m-erros + crapcri.dscritic.
                ELSE
                    ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

                RETURN "NOK".
            END.
        END.

    /* Valida a Cooperativa */
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
        /*ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".*/
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida se o abridor esta preenchido */
    IF TRIM({&tttabela}.nmabreve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome pode ser branco.".
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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.flgativo = {&tabela}.flgativo
           {&tabela}.nmabreve = TRIM(CAPS({&tabela}.nmabreve))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv)).

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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    NO-LOCK NO-ERROR.

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
            
    /*verifica se o abridor já esta vinculado a algum evento da agenda*/
    
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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    EXCLUSIVE-LOCK NO-ERROR.

    /* Elimina o registro da tabela */
    DELETE {&tabela} NO-ERROR.

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: posiciona-registro                                                       */
/*  Objetivo: Posiciona no registro corresp1ondente ao ponteiro passado como parametro      */
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
