/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0012c.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 07/07/2016

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Propostas de Fornecedores
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
               
               12/11/2009 - Alterado para que o campo vlinvest critique somente 
                            quando receber valores maiores que 999.999,99 
                            (Elton).
                            
               07/12/2015 - Retirado a validacao do campo dspublic e incluida
                            a validacao do campo nrseqpap (Jean Michel).
                            
               14/12/2015 - Incluido a validacao dos recursos craprdf (Vanessa).

			         19/04/2016 - Removi validacao sobre o campo nrseqpap de Publico Alvo 
							              (Carlos Rafael Tanhol).
                            
               07/07/2016 - Alterar para permitir informar os campos conforme informado
                            maiusculo/minusculo, para melhor exibiçao nos relatorios.
                            PRJ229 - Melhorias OQS (Odirlei-AMcom)
............................................................................ */
&SCOPED-DEFINE tttabela gnatpdp
&SCOPED-DEFINE tabela   gnappdp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VARIABLE m-erros       AS CHAR   FORMAT "x(256)" NO-UNDO.

/*** Declaração de BOs auxiliares ***/
DEFINE VARIABLE h-b1wpgd0012d AS HANDLE                 NO-UNDO.
DEFINE VARIABLE h-b1wpgd0012e AS HANDLE                 NO-UNDO.
DEFINE TEMP-TABLE gtfacep LIKE gnfacep.
DEFINE TEMP-TABLE cratrdf LIKE craprdf.


/*  Procedimento: valida-inclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela temporária está OK para ser inserido na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.      */
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                     */
/*       m-erros = Guarda a mensagem de erro da validação                                             */
PROCEDURE valida-inclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE INPUT PARAMETER par_dsobjeti AS CHAR.
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
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdcooper = 0                       AND
                             crapedp.dtanoage = 0                       AND
                             crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inexistente.".
        RETURN "NOK".
    END.

    /*/* Valida o Facilitador */
    FIND FIRST gnapfep WHERE
        gnapfep.cdcooper = 0                    AND
        gnapfep.cdfacili = {&tttabela}.cdfacili NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfep THEN
    DO:
        ASSIGN m-erros = m-erros + "Facilitador inexistente.".
        RETURN "NOK".
    END.*/

    /* Verifica se o conteúdo do evento não está em branco */
    IF TRIM({&tttabela}.dsconteu) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Conteúdo do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a metodologia do evento não está em branco */
    IF TRIM({&tttabela}.dsmetodo) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Metodologia do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o objetivo do evento não está em branco */
    IF TRIM(par_dsobjeti) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Objetivo do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a observação do evento não está em branco */
    /* 
    Agnaldo - 24/11 - Campo não é obrigatório 
    
    IF TRIM({&tttabela}.dsobserv) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Observação do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.
    */

    /* Verifica se o público-alvo do evento não está em branco */
    /*IF {&tttabela}.nrseqpap = 0 OR {&tttabela}.nrseqpap = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Público-alvo do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.*/

    /* Verifica se a data de Recebimento não é nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data do Recebimento não pode ser nula.".
        RETURN "NOK".
    END.

    /* Verifica se a data de validade da proposta não é nula */
    IF {&tttabela}.dtvalpro = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de validade da proposta não pode ser nula.".
        RETURN "NOK".
    END.

    /* Valida se a data de validade da proposta não é inferior à data do Recebimento */
    IF {&tttabela}.dtmvtolt > {&tttabela}.dtvalpro THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de validade da proposta deve ser maior ou igual que a data do Recebimento.".
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

    /* Verifica se o nome do evento não está em branco */
    IF TRIM({&tttabela}.nmevefor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o CPF/CNPJ existe como fornecedor */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor não encontrado com o CPF/CNPJ informado.".
        RETURN "NOK".
    END.

    /* Verifica se o código da proposta não está em branco */
    IF TRIM({&tttabela}.nrpropos) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Código da Proposta não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o código da proposta já foi usado para este mesmo fornecedor */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                       AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc    AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos    NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Código da Proposta já foi utilizado para este fornecedor.".
        RETURN "NOK".
    END.

    /* Valida o valor do investimento */
    IF {&tttabela}.vlinvest > 999999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Não é permitido valor de investimento maior do que 999999.99.".
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
    DEFINE INPUT PARAMETER par_dsobjeti  AS CHAR                 NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-inclusao(INPUT TABLE {&tttabela},
                        INPUT par_dsobjeti).

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

    ASSIGN {&tabela}.cdcooper = 0
           /* {&tabela}.cdeixtem = integer zz9 Codigo do Eixo Tematico Codigo do Eixo Tematico */
           /* {&tabela}.cdevento = integer zz9 Codigo do Evento Codigo do Evento               */
           /* {&tabela}.cdfacili = integer zz9 Codigo do Facilitador Codigo do Facilitador     */
           {&tabela}.dsconteu = TRIM({&tabela}.dsconteu)
           {&tabela}.dsmetodo = TRIM({&tabela}.dsmetodo)
           {&tabela}.dsobserv = TRIM({&tabela}.dsobserv)
           {&tabela}.dspublic = TRIM(CAPS({&tabela}.dspublic))     
           {&tabela}.dsrecurs = TRIM(CAPS({&tabela}.dsrecurs))     
           /* {&tabela}.dtmvtolt = date 99/99/9999 Data do Recebimento Data do Recebimento */
           /* {&tabela}.dtvalpro = date 99/99/9999 Data de Validade Data de Validade   */
           /* {&tabela}.idevento = integer 9 Identificacao Identificacao               */
           {&tabela}.nmevefor = TRIM(CAPS({&tabela}.nmevefor))     
           /* {&tabela}.nrcpfcgc = decimal zzzzzzzzzzzzz9 CPF/CGC CPF/CGC                        */
           /* {&tabela}.nrpropos = character x(20) Codigo da Proposta Codigo da Proposta         */
           /* {&tabela}.qtcarhor = decimal zz9.99 Carga Horaria Carga Horaria                    */
           /* {&tabela}.vlinvest = decimal zz,zzz.99 Valor do Investimento Valor do Investimento */
           .
    
    CREATE gnappob.
    BUFFER-COPY {&tabela} TO gnappob.
    ASSIGN gnappob.dsobjeti = TRIM(par_dsobjeti).

    /* Fim - Efetuar sobreposições necessárias */ 

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: valida-alteracao                                                                    */
/*  Objetivo: Verifica se 4o registro da tabela temporária está OK para ser alte~ rado na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela temporária usada no programa final para a manipulação do registro.      */ 
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou não na validação                                     */
/*       m-erros = Guarda a mensagem de erro da validação                                             */
PROCEDURE valida-alteracao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE INPUT PARAMETER par_dsobjeti AS CHAR NO-UNDO.
 
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND 
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos NO-LOCK NO-ERROR.

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
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdcooper = 0                       AND
                             crapedp.dtanoage = 0                       AND
                             crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inexistente.".
        RETURN "NOK".
    END.

    /*/* Valida o Facilitador */
    FIND FIRST gnapfep WHERE
        gnapfep.cdcooper = 0                    AND
        gnapfep.cdfacili = {&tttabela}.cdfacili NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfep THEN
    DO:
        ASSIGN m-erros = m-erros + "Facilitador inexistente.".
        RETURN "NOK".
    END.*/

    /* Verifica se o conteúdo do evento não está em branco */
    IF TRIM({&tttabela}.dsconteu) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Conteúdo do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a metodologia do evento não está em branco */
    IF TRIM({&tttabela}.dsmetodo) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Metodologia do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o objetivo do evento não está em branco */
    IF TRIM(par_dsobjeti) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Objetivo do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a observação do evento não está em branco */
    /* 
    Agnaldo - 24/11 - Campo não é obrigatório 

    IF TRIM({&tttabela}.dsobserv) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Observação do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.
    */

    /* Verifica se o público-alvo do evento não está em branco */
    /*IF {&tttabela}.nrseqpap = 0 OR {&tttabela}.nrseqpap = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Público-alvo do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.*/

    /* Verifica se a data de Recebimento não é nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data do Recebimento não pode ser nula.".
        RETURN "NOK".
    END.

    /* Verifica se a data de validade da proposta não é nula */
    IF {&tttabela}.dtvalpro = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de validade da proposta não pode ser nula.".
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

    /* Verifica se o nome do evento não está em branco */
    IF TRIM({&tttabela}.nmevefor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento não pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o CPF/CNPJ existe como fornecedor */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor não encontrado com o CPF/CNPJ informado.".
        RETURN "NOK".
    END.

    /* Verifica se o código da proposta não está em branco */
    IF TRIM({&tttabela}.nrpropos) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Código da Proposta não pode ficar em branco.".
        RETURN "NOK".
    END.
      
    /* Valida o valor do investimento */
    IF {&tttabela}.vlinvest > 999999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Não é permitido valor de investimento maior do que 999999.99.".
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
    DEFINE INPUT PARAMETER par_dsobjeti AS CHAR.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela temporária e executa o procedimento de validação. */
    /* Este procedimento não deve executar nenhuma validação */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-alteracao (INPUT TABLE {&tttabela},
                          INPUT par_dsobjeti).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela física o registro correspondente à tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND 
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos EXCLUSIVE-LOCK NO-ERROR.
                               
    /* Copia o registro da tabela temporária para a tabela física */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

    ASSIGN {&tabela}.cdcooper = 0
           /* {&tabela}.cdeixtem = integer zz9 Codigo do Eixo Tematico Codigo do Eixo Tematico */
           /* {&tabela}.cdevento = integer zz9 Codigo do Evento Codigo do Evento               */
           /* {&tabela}.cdfacili = integer zz9 Codigo do Facilitador Codigo do Facilitador     */
           {&tabela}.dsconteu = TRIM({&tabela}.dsconteu)
           {&tabela}.dsmetodo = TRIM({&tabela}.dsmetodo)
           {&tabela}.dsobserv = TRIM({&tabela}.dsobserv)
           {&tabela}.dspublic = TRIM(CAPS({&tabela}.dspublic))     
           {&tabela}.dsrecurs = TRIM(CAPS({&tabela}.dsrecurs))     
           /* {&tabela}.dtmvtolt = date 99/99/9999 Data do Recebimento Data do Recebimento */
           /* {&tabela}.dtvalpro = date 99/99/9999 Data de Validade Data de Validade   */
           /* {&tabela}.idevento = integer 9 Identificacao Identificacao               */
           {&tabela}.nmevefor = TRIM(CAPS({&tabela}.nmevefor))     
           /* {&tabela}.nrcpfcgc = decimal zzzzzzzzzzzzz9 CPF/CGC CPF/CGC                        */
           /* {&tabela}.nrpropos = character x(20) Codigo da Proposta Codigo da Proposta         */
           /* {&tabela}.qtcarhor = decimal zz9.99 Carga Horaria Carga Horaria                    */
           /* {&tabela}.vlinvest = decimal zz,zzz.99 Valor do Investimento Valor do Investimento */
           .

    /* Fim - Efetuar sobreposições necessárias */ 

    FIND gnappob WHERE gnappob.idevento = {&tttabela}.idevento  AND
                       gnappob.cdcooper = {&tttabela}.cdcooper  AND
                       gnappob.nrcpfcgc = {&tttabela}.nrcpfcgc  AND
                       gnappob.nrpropos = {&tttabela}.nrpropos
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
    IF   AVAIL gnappob   THEN   
         ASSIGN gnappob.dsobjeti = TRIM(par_dsobjeti).

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
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos NO-LOCK NO-ERROR.

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

    /* Exclui os facilitadores da proposta */
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0012d.p PERSISTENT SET h-b1wpgd0012d.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0012d) THEN
    DO:
        FOR EACH gnfacep WHERE gnfacep.cdcooper = 0                    AND
                               gnfacep.nrpropos = {&tttabela}.nrpropos NO-LOCK:

            EMPTY TEMP-TABLE gtfacep NO-ERROR.
        
            CREATE gtfacep.
            BUFFER-COPY gnfacep TO gtfacep.
               
            RUN exclui-registro IN h-b1wpgd0012d(INPUT TABLE gtfacep, OUTPUT aux-m-erros).

            m-erros = m-erros + aux-m-erros.

        END.
    
       /* "mata" a instância da BO */
       DELETE PROCEDURE h-b1wpgd0012d NO-ERROR.
    END.
    ELSE
        m-erros = "Erro na BO".

    PUT "Facili Prop: " m-erros.

    IF m-erros <> "" THEN
        RETURN "NOK":U.
    
    /*Exclui os Recursos da proposta*/
    RUN dbo/b1wpgd0012e.p PERSISTENT SET h-b1wpgd0012e.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0012e) THEN
    DO:
        
        FOR EACH craprdf WHERE craprdf.idevento = {&tttabela}.idevento 
                             AND craprdf.cdcooper = 0
                             AND craprdf.nrcpfcgc = {&tttabela}.nrcpfcgc
                             AND craprdf.dspropos = {&tttabela}.nrpropos NO-LOCK:
          EMPTY TEMP-TABLE cratrdf.
          
          CREATE cratrdf.
          BUFFER-COPY craprdf TO cratrdf.
          
          RUN exclui-registro IN h-b1wpgd0012e(INPUT TABLE cratrdf, OUTPUT aux-m-erros).
        
          m-erros = m-erros + aux-m-erros.

        END.
    
       /* "mata" a instância da BO */
       DELETE PROCEDURE h-b1wpgd0012d NO-ERROR.
    END.
    ELSE
        m-erros = "Erro na BO".

    PUT "Facili Prop: " m-erros.

    IF m-erros <> "" THEN
        RETURN "NOK":U.
    
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
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos EXCLUSIVE-LOCK NO-ERROR.

    /* Apaga todos os facilitadores da proposta */
    FOR EACH gnfacep WHERE gnfacep.cdcooper = 0                    AND
                           gnfacep.idevento = {&tabela}.idevento   AND
                           gnfacep.nrcpfcgc = {&tabela}.nrcpfcgc   AND
                           gnfacep.nrpropos = {&tabela}.nrpropos   EXCLUSIVE-LOCK:
        DELETE gnfacep.
    END.

    FIND gnappob WHERE gnappob.idevento = {&tttabela}.idevento  AND
                       gnappob.cdcooper = {&tttabela}.cdcooper  AND
                       gnappob.nrcpfcgc = {&tttabela}.nrcpfcgc  AND
                       gnappob.nrpropos = {&tttabela}.nrpropos
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF   AVAIL gnappob   THEN
         DELETE gnappob.

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
