/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0024.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : outubro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de pessoas para a abertura dos eventos
   
   Alteracoes: 16/10/2012 - Ajustear para o DataServer Oracle (Gabriel).
               
               29/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela crataep
&SCOPED-DEFINE tabela   crapaep


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VAR m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.
DEFINE VAR aux_nrseqaep AS INT                  NO-UNDO.

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
                    ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

                RETURN "NOK".
            END.
        END.

    /* Valida a Cooperativa */
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
        /*ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".*/
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se o abridor esta preenchido */
    IF TRIM({&tttabela}.nmabreve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome pode ser branco.".
        RETURN "NOK".
    END.

    ASSIGN aux_nrseqaep = NEXT-VALUE(nrseqaep).
	
    /* Verifica se a sequ�ncia ainda n�o foi utilizada */
    FIND FIRST {&tabela} WHERE {&tabela}.nrseqdig = aux_nrseqaep NO-LOCK NO-ERROR.
    IF AVAIL {&tabela} THEN
    DO:
    
        ASSIGN m-erros = m-erros + "Problemas com o c�digo de sequ�ncia do abridor do evento".

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

    ASSIGN {&tabela}.nrseqdig = CURRENT-VALUE(nrseqaep)
           {&tabela}.flgativo = {&tabela}.flgativo
           {&tabela}.nmabreve = TRIM(CAPS({&tabela}.nmabreve))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv)).
                                              

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

    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    NO-LOCK NO-ERROR.


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
                    ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

                RETURN "NOK".
            END.
        END.

    /* Valida a Cooperativa */
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
        /*ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".*/
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida se o abridor esta preenchido */
    IF TRIM({&tttabela}.nmabreve) = "" THEN
    DO:
        ASSIGN m-erros = m-erros + "Nome pode ser branco.".
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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} TO {&tabela} NO-ERROR.

    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */ 

    ASSIGN {&tabela}.flgativo = {&tabela}.flgativo
           {&tabela}.nmabreve = TRIM(CAPS({&tabela}.nmabreve))
           {&tabela}.dsobserv = TRIM(CAPS({&tabela}.dsobserv)).

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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    NO-LOCK NO-ERROR.

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
            
    /*verifica se o abridor j� esta vinculado a algum evento da agenda*/
    
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
