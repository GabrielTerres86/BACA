/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0008.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 16/10/2012 

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Eventos
   
   Altera��es: 14/12/2007 - Atribuir "1" em Participa��o permitida quando for 
                            Assembl�ia (Diego).
                            
               30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).      
               
               16/12/2012 - Ajustes para o DataServer Oracle (Gabriel).       
............................................................................ */
&SCOPED-DEFINE tttabela cratedp
&SCOPED-DEFINE tabela   crapedp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqedp AS INT                  NO-UNDO.

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

    /* verifica se o eixo tem�tico selecionado existe */
    /* Se for idevento = 2 - ASSEMBLEIA, l� o unico eixo para assembleias */
    IF {&tttabela}.idevento = 2 THEN
       DO:
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                     AND
                                   gnapetp.idevento = {&tttabela}.idevento  NO-LOCK NO-ERROR.

          IF NOT AVAIL gnapetp THEN
             DO:
                 ASSIGN m-erros = m-erros + "Eixo tem�tico inexistente".
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
                 ASSIGN m-erros = m-erros + "Eixo tem�tico inexistente".
                 RETURN "NOK".
             END.
       END.

    /* valida o c�digo de cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
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

    /* Valida o nome do evento */
    IF TRIM({&tttabela}.nmevento) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a frequ�ncia � menor ou igual a 100% */
    IF {&tttabela}.prfreque > 100 THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento n�o pode ser branco.".
        RETURN "NOK".
    END.


    /* Valida��es para eventos do Progrid (Assembl�ias n�o possuem essas valida��es) */
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
                ASSIGN m-erros = m-erros + "Tipo de Evento inv�lido.".
                RETURN "NOK".
            END.
        END.
    
        /* verifica se a quantidade de participantes por turma � maior ou igual que o 
           m�nimo por turma */
        IF {&tttabela}.qtmaxtur < {&tttabela}.qtmintur THEN
        DO:
            ASSIGN m-erros = m-erros + "Quantidade m�nima por turma deve ser menor ou igual a quantidade de participantes.".
            RETURN "NOK".
        END.

    END.

    /* Evento de Integra��o deve ser �nico */
    FIND FIRST crapedp WHERE crapedp.tpevento = 2   AND 
                             crapedp.cdcooper = 0   NO-LOCK NO-ERROR.

    IF AVAIL crapedp AND {&tttabela}.tpevento = 2 AND {&tttabela}.cdcooper = 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Evento Integra��o j� existe na base.".
        RETURN "NOK".
    END.
    
    /* Sequencia nao pode aparecer numa clausula de where */
    aux_nrseqedp = NEXT-VALUE(nrseqedp).
    
    /* Valida se a sequ�ncia que vai ser usada ainda n�o existe na tabela */
    FIND FIRST {&tabela} WHERE {&tabela}.cdevento = aux_nrseqedp NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO: 
        ASSIGN m-erros = m-erros + "Erro na sequ�ncia do c�digo do evento.".
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
    BUFFER-COPY {&tttabela} EXCEPT cdevento TO {&tabela}.

    aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN {&tabela}.cdevento = CURRENT-VALUE(nrseqedp)
           {&tabela}.dtanoage = 0
           {&tabela}.nmevento = TRIM(CAPS({&tabela}.nmevento)).

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

    /* Procura na tabela f�sica o registro correspondente a tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

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

    
    /* verifica se o eixo tem�tico selecionado existe */
    /* Se for idevento = 2 - ASSEMBLEIA, l� o unico eixo para assembleias */
    IF {&tttabela}.idevento = 2 THEN
       DO:
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                     AND
                                   gnapetp.idevento = {&tttabela}.idevento  NO-LOCK NO-ERROR.

          IF NOT AVAIL gnapetp THEN
             DO:
                 ASSIGN m-erros = m-erros + "Eixo tem�tico inexistente".
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
                 ASSIGN m-erros = m-erros + "Eixo tem�tico inexistente".
                 RETURN "NOK".
             END.
       END.

    /* valida o c�digo de cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
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

    /* Valida o nome do evento */
    IF TRIM({&tttabela}.nmevento) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento n�o pode ser branco.".
        RETURN "NOK".
    END.

    /* Valida se a frequ�ncia � menor ou igual a 100% */
    IF {&tttabela}.prfreque > 100 THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome do Evento n�o pode ser branco.".
        RETURN "NOK".
    END.


    /* Valida��es para eventos do Progrid (Assembl�ias n�o possuem essas valida��es) */
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
                ASSIGN m-erros = m-erros + "Tipo de Evento inv�lido.".
                RETURN "NOK".
            END.
        END.
    
        /* verifica se a quantidade de participantes por turma � maior ou igual que o 
           m�nimo por turma */
        IF {&tttabela}.qtmaxtur < {&tttabela}.qtmintur THEN
        DO:
            ASSIGN m-erros = m-erros + "Quantidade m�nima por turma deve ser menor ou igual a quantidade de participantes.".
            RETURN "NOK".
        END.

    END.

    /* Evento de Integra��o deve ser �nico */
    FIND FIRST crapedp WHERE crapedp.tpevento  = 2                      AND 
                             crapedp.cdcooper  = 0                      AND 
                             crapedp.cdevento <> {&tttabela}.cdevento   NO-LOCK NO-ERROR.

    IF AVAIL crapedp AND {&tttabela}.tpevento = 2 THEN
    DO:
        ASSIGN m-erros = m-erros + "Tipo de Evento Integra��o j� existe na base.".
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

    /* Procura na tabela f�sica o registro correspondente a tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */

    ASSIGN
        {&tabela}.nmevento = TRIM(CAPS({&tabela}.nmevento)).

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

    /* Procura na tabela f�sica o registro correspondente a tabela temporaria */
    FIND FIRST {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

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
            
    /* Verifica se o evento n�o est� relacionado com alguma sugest�o */
    FIND FIRST crapsdp WHERE crapsdp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF AVAIL crapsdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento possui sugest�es relacionadas. Exclus�o n�o permitida. ".
        RETURN "NOK".
    END.

    FIND FIRST gnappdp WHERE gnappdp.cdcooper = 0                    AND
                             gnappdp.cdevento = {&tttabela}.cdevento NO-LOCK NO-ERROR.
    IF AVAIL gnappdp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento possui propostas relacionadas. Exclus�o n�o permitida. ".
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

    /* Procura na tabela f�sica o registro correspondente a tabela temporaria */
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
