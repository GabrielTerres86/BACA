/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0013.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Locais para Eventos
   
   Altera��es: 25/01/2008 - Inclu�do campo "Refer�ncia" (Diego).

               16/10/2012 - Tratar DataServer Oracle (Gabriel).
               
               29/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).  
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela cratldp
&SCOPED-DEFINE tabela   crapldp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqldp AS INT                  NO-UNDO.

/*  Procedimento: valida-inclusao                                                                     */
/*  Objetivo: Verifica se o registro da tabela tempor�ria est� OK para ser inserido na tabela fisica  */
/*  Parametros de Entrada:                                                                            */
/*       {&tttabela} = Tabela tempor�ria usada no programa final para a manipula��o do registro.      */
/*  Parametros de Saida:                                                                              */
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                                     */
/*       m-erros = Guarda a mensagem de erro da valida��o                                             */
PROCEDURE valida-inclusao:
    DEFINE INPUT PARAMETER TABLE FOR {&tttabela}.
    
    FIND FIRST {&tttabela} NO-ERROR.

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

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage THEN 
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic + " " + STRING({&tttabela}.cdagenci) + STRING({&tttabela}.cdcooper).
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro. Cooperativa: " + STRING({&tttabela}.cdcooper) + ", PA: " + STRING({&tttabela}.cdagenci).
        
        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se o Endere�o do Local est� em branco */
    IF TRIM({&tttabela}.dsendloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Endere�o do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Estrutura do Local est� em branco */
    IF TRIM({&tttabela}.dsestloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Estrutura do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Descri��o do Local est� em branco */
    IF TRIM({&tttabela}.dslocal) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descri��o do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se � progrid ou assembl�ia */
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBL�IA */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se a Cidade do Local est� em branco */
    IF TRIM({&tttabela}.nmcidloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do local n�o pode ser branco.".
        RETURN "NOK".
    END.

        /* Valida se o valor di�rio est� no limite aceit�vel pela tabela */
    IF {&tttabela}.vldialoc > 9999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor di�rio est� acima do aceit�vel pelo campo (9.999,99).".
        RETURN "NOK".
    END.
    
    ASSIGN aux_nrseqldp = NEXT-VALUE(nrseqldp).

    /* Verifica se a sequ�ncia ainda n�o foi utilizada */
    FIND FIRST {&tabela} WHERE {&tabela}.nrseqdig = aux_nrseqldp NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Problemas com o c�digo de sequ�ncia do local do evento".
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

    FIND FIRST {&tttabela}.

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

    ASSIGN {&tabela}.nrseqdig = CURRENT-VALUE(nrseqldp)
           {&tabela}.dsendloc = TRIM(CAPS({&tabela}.dsendloc))
           {&tabela}.dsestloc = TRIM(CAPS({&tabela}.dsestloc))
           {&tabela}.dslocali = TRIM(CAPS({&tabela}.dslocali))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv))
           {&tabela}.nmbailoc = TRIM(CAPS({&tabela}.nmbailoc))
           {&tabela}.nmcidloc = TRIM(CAPS({&tabela}.nmcidloc))
           {&tabela}.nmconloc = TRIM(CAPS({&tabela}.nmconloc))
                   {&tabela}.dsrefloc = TRIM(CAPS({&tabela}.dsrefloc)).                                           

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

    FIND FIRST {&tttabela}.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/

    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBL�IA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

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

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage THEN 
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se o Endere�o do Local est� em branco */
    IF TRIM({&tttabela}.dsendloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Endere�o do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Estrutura do Local est� em branco */
    IF TRIM({&tttabela}.dsestloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Estrutura do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a Descri��o do Local est� em branco */
    IF TRIM({&tttabela}.dslocal) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Descri��o do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida o Evento, se � progrid ou assembl�ia */
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBL�IA */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
        AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se a Cidade do Local est� em branco */
    IF TRIM({&tttabela}.nmcidloc) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Cidade do local n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se o valor di�rio est� no limite aceit�vel pela tabela */
    IF {&tttabela}.vldialoc > 9999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor di�rio est� acima do aceit�vel pelo campo (9.999,99).".
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

    FIND FIRST {&tttabela}.

    RUN valida-alteracao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBL�IA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig EXCLUSIVE-LOCK NO-ERROR.
                               
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN {&tabela}.dsendloc = TRIM(CAPS({&tabela}.dsendloc))
           {&tabela}.dsestloc = TRIM(CAPS({&tabela}.dsestloc))
           {&tabela}.dslocali = TRIM(CAPS({&tabela}.dslocali))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv))
           {&tabela}.nmbailoc = TRIM(CAPS({&tabela}.nmbailoc))
           {&tabela}.nmcidloc = TRIM(CAPS({&tabela}.nmcidloc))
           {&tabela}.nmconloc = TRIM(CAPS({&tabela}.nmconloc))
                   {&tabela}.dsrefloc = TRIM(CAPS({&tabela}.dsrefloc)).

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

    FIND FIRST {&tttabela}.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBL�IA */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro n�o encontrado para exclus�o.".
        RETURN "NOK".
    END.

    FIND FIRST crapadp WHERE crapadp.idevento = {&tttabela}.idevento AND
                             crapadp.cdcooper = {&tttabela}.cdcooper AND
                             crapadp.cdagenci = {&tttabela}.cdagenci AND
                             crapadp.cdlocali = {&tttabela}.nrseqdig NO-LOCK NO-ERROR.

    IF   AVAIL crapadp  THEN
         DO: 
             ASSIGN m-erros = m-erros + "Local de evento j� est� sendo utilizado.".
             RETURN "NOK".
         END.
    
    /* Fim - Valida��es obrigat�rias a todas as tabelas */

    /* Valida��es espec�ficas */
    /* No caso de erro de valida��o, a forma de tratamento � a seguinte:
            ASSIGN m-erros = m-erros + "<mensagem de erro da validacao especifica>".
            RETURN "NOK".
    */
            

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

    FIND FIRST {&tttabela}.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    /*FIND FIRST {&tabela} OF {&tttabela} NO-ERROR.*/
    /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBL�IA */
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
/*       "OK" ou "NOK" = indica se houve erro ou n�o na valida��o                          */
/*       retorno-erro = Guarda a mensagem de erro da valida��o                             */
PROCEDURE posiciona-registro:
    DEFINE INPUT  PARAMETER ponteiro     AS ROWID                   NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR    FORMAT "x(256)" NO-UNDO.

    FIND FIRST {&tabela} WHERE ROWID({&tabela}) = ponteiro NO-LOCK NO-ERROR.

    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN retorno-erro = "Registro n�o encontrado.".
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.
