/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0012c.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 12/11/2009

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Propostas de Fornecedores
   
   Alteracoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
               
               12/11/2009 - Alterado para que o campo vlinvest critique somente 
                            quando receber valores maiores que 999.999,99 
                            (Elton).
                            
               07/12/2015 - Retirado a validacao do campo dspublic e incluida
                            a validacao do campo nrseqpap (Jean Michel).
                            
               14/12/2015 - Incluido a validacao dos recursos craprdf (Vanessa).

			   19/04/2016 - Removi validacao sobre o campo nrseqpap de Publico Alvo 
							(Carlos Rafael Tanhol).
............................................................................ */
&SCOPED-DEFINE tttabela gnatpdp
&SCOPED-DEFINE tabela   gnappdp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VARIABLE m-erros       AS CHAR   FORMAT "x(256)" NO-UNDO.

/*** Declara��o de BOs auxiliares ***/
DEFINE VARIABLE h-b1wpgd0012d AS HANDLE                 NO-UNDO.
DEFINE VARIABLE h-b1wpgd0012e AS HANDLE                 NO-UNDO.
DEFINE TEMP-TABLE gtfacep LIKE gnfacep.
DEFINE TEMP-TABLE cratrdf LIKE craprdf.


/*  Procedimento: valida-inclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela tempor�ria est� OK para ser inserido na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.      */
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                     */
/*       m-erros = Guarda a mensagem de erro da valida��o                                             */
PROCEDURE valida-inclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE INPUT PARAMETER par_dsobjeti AS CHAR.
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

    /* Verifica se o conte�do do evento n�o est� em branco */
    IF TRIM({&tttabela}.dsconteu) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Conte�do do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a metodologia do evento n�o est� em branco */
    IF TRIM({&tttabela}.dsmetodo) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Metodologia do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o objetivo do evento n�o est� em branco */
    IF TRIM(par_dsobjeti) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Objetivo do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a observa��o do evento n�o est� em branco */
    /* 
    Agnaldo - 24/11 - Campo n�o � obrigat�rio 
    
    IF TRIM({&tttabela}.dsobserv) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Observa��o do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.
    */

    /* Verifica se o p�blico-alvo do evento n�o est� em branco */
    /*IF {&tttabela}.nrseqpap = 0 OR {&tttabela}.nrseqpap = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "P�blico-alvo do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.*/

    /* Verifica se a data de Recebimento n�o � nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data do Recebimento n�o pode ser nula.".
        RETURN "NOK".
    END.

    /* Verifica se a data de validade da proposta n�o � nula */
    IF {&tttabela}.dtvalpro = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de validade da proposta n�o pode ser nula.".
        RETURN "NOK".
    END.

    /* Valida se a data de validade da proposta n�o � inferior � data do Recebimento */
    IF {&tttabela}.dtmvtolt > {&tttabela}.dtvalpro THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de validade da proposta deve ser maior ou igual que a data do Recebimento.".
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

    /* Verifica se o nome do evento n�o est� em branco */
    IF TRIM({&tttabela}.nmevefor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o CPF/CNPJ existe como fornecedor */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor n�o encontrado com o CPF/CNPJ informado.".
        RETURN "NOK".
    END.

    /* Verifica se o c�digo da proposta n�o est� em branco */
    IF TRIM({&tttabela}.nrpropos) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo da Proposta n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o c�digo da proposta j� foi usado para este mesmo fornecedor */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                       AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc    AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos    NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo da Proposta j� foi utilizado para este fornecedor.".
        RETURN "NOK".
    END.

    /* Valida o valor do investimento */
    IF {&tttabela}.vlinvest > 999999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "N�o � permitido valor de investimento maior do que 999999.99.".
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
    DEFINE INPUT PARAMETER par_dsobjeti  AS CHAR                 NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR                 NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */
    
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-inclusao(INPUT TABLE {&tttabela},
                        INPUT par_dsobjeti).

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
           /* {&tabela}.cdeixtem = integer zz9 Codigo do Eixo Tematico Codigo do Eixo Tematico */
           /* {&tabela}.cdevento = integer zz9 Codigo do Evento Codigo do Evento               */
           /* {&tabela}.cdfacili = integer zz9 Codigo do Facilitador Codigo do Facilitador     */
           {&tabela}.dsconteu = TRIM(CAPS({&tabela}.dsconteu))     
           {&tabela}.dsmetodo = TRIM(CAPS({&tabela}.dsmetodo))     
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv))     
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
    ASSIGN gnappob.dsobjeti = TRIM(CAPS(par_dsobjeti)).

    /* Fim - Efetuar sobreposi��es necess�rias */ 

    RETURN "OK".
END PROCEDURE.

/*  Procedimento: valida-alteracao                                                                    */
/*  Objetivo: Verifica se 4o registro da tabela tempor�ria est� OK para ser alte~ rado na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.      */ 
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                     */
/*       m-erros = Guarda a mensagem de erro da valida��o                                             */
PROCEDURE valida-alteracao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE INPUT PARAMETER par_dsobjeti AS CHAR NO-UNDO.
 
    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND 
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos NO-LOCK NO-ERROR.

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

    /* Verifica se o conte�do do evento n�o est� em branco */
    IF TRIM({&tttabela}.dsconteu) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Conte�do do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a metodologia do evento n�o est� em branco */
    IF TRIM({&tttabela}.dsmetodo) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Metodologia do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o objetivo do evento n�o est� em branco */
    IF TRIM(par_dsobjeti) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Objetivo do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se a observa��o do evento n�o est� em branco */
    /* 
    Agnaldo - 24/11 - Campo n�o � obrigat�rio 

    IF TRIM({&tttabela}.dsobserv) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Observa��o do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.
    */

    /* Verifica se o p�blico-alvo do evento n�o est� em branco */
    /*IF {&tttabela}.nrseqpap = 0 OR {&tttabela}.nrseqpap = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "P�blico-alvo do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.*/

    /* Verifica se a data de Recebimento n�o � nula */
    IF {&tttabela}.dtmvtolt = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data do Recebimento n�o pode ser nula.".
        RETURN "NOK".
    END.

    /* Verifica se a data de validade da proposta n�o � nula */
    IF {&tttabela}.dtvalpro = ? THEN
    DO:
        ASSIGN m-erros = m-erros + "Data de validade da proposta n�o pode ser nula.".
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

    /* Verifica se o nome do evento n�o est� em branco */
    IF TRIM({&tttabela}.nmevefor) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento n�o pode ficar em branco.".
        RETURN "NOK".
    END.

    /* Verifica se o CPF/CNPJ existe como fornecedor */
    FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                    AND
                             gnapfdp.nrcpfcgc = {&tttabela}.nrcpfcgc NO-LOCK NO-ERROR.
    IF NOT AVAIL gnapfdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Fornecedor n�o encontrado com o CPF/CNPJ informado.".
        RETURN "NOK".
    END.

    /* Verifica se o c�digo da proposta n�o est� em branco */
    IF TRIM({&tttabela}.nrpropos) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo da Proposta n�o pode ficar em branco.".
        RETURN "NOK".
    END.
      
    /* Valida o valor do investimento */
    IF {&tttabela}.vlinvest > 999999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "N�o � permitido valor de investimento maior do que 999999.99.".
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
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    DEFINE INPUT PARAMETER par_dsobjeti AS CHAR.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */

    FIND FIRST {&tttabela} NO-LOCK NO-ERROR.

    RUN valida-alteracao (INPUT TABLE {&tttabela},
                          INPUT par_dsobjeti).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.cdcooper = 0                    AND 
                               {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos EXCLUSIVE-LOCK NO-ERROR.
                               
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN {&tabela}.cdcooper = 0
           /* {&tabela}.cdeixtem = integer zz9 Codigo do Eixo Tematico Codigo do Eixo Tematico */
           /* {&tabela}.cdevento = integer zz9 Codigo do Evento Codigo do Evento               */
           /* {&tabela}.cdfacili = integer zz9 Codigo do Facilitador Codigo do Facilitador     */
           {&tabela}.dsconteu = TRIM(CAPS({&tabela}.dsconteu))     
           {&tabela}.dsmetodo = TRIM(CAPS({&tabela}.dsmetodo))     
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv))     
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

    /* Fim - Efetuar sobreposi��es necess�rias */ 

    FIND gnappob WHERE gnappob.idevento = {&tttabela}.idevento  AND
                       gnappob.cdcooper = {&tttabela}.cdcooper  AND
                       gnappob.nrcpfcgc = {&tttabela}.nrcpfcgc  AND
                       gnappob.nrpropos = {&tttabela}.nrpropos
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
    IF   AVAIL gnappob   THEN   
         ASSIGN gnappob.dsobjeti = TRIM(CAPS(par_dsobjeti)).

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
                               {&tabela}.nrcpfcgc = {&tttabela}.nrcpfcgc AND
                               {&tabela}.nrpropos = {&tttabela}.nrpropos NO-LOCK NO-ERROR.

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
    
       /* "mata" a inst�ncia da BO */
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
    
       /* "mata" a inst�ncia da BO */
       DELETE PROCEDURE h-b1wpgd0012d NO-ERROR.
    END.
    ELSE
        m-erros = "Erro na BO".

    PUT "Facili Prop: " m-erros.

    IF m-erros <> "" THEN
        RETURN "NOK":U.
    
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
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
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
