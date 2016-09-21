/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0029.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 16/06/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Avalia��es de Eventos
   
   Alteracoes: 30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
   
               09/07/2012 - Tratamento de CLOB para CHAR - ORACLE (Guilherme).
               
               29/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).

               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
                            
               16/06/2014 - Retirado condicao do idseqeve da procedure 
                            exclui-registro Softdesk 165668 (Lucas R.)
............................................................................ */
&SCOPED-DEFINE tttabela cratrap
&SCOPED-DEFINE tabela   craprap

DEF TEMP-TABLE {&tttabela}
	FIELD cdagenci LIKE {&tabela}.cdagenci	
	FIELD cdcooper LIKE {&tabela}.cdcooper
	FIELD cdevento LIKE {&tabela}.cdevento
	FIELD cdgruava LIKE {&tabela}.cdgruava
	FIELD cditeava LIKE {&tabela}.cditeava
	FIELD dsobserv AS CHAR
	FIELD dtanoage LIKE {&tabela}.dtanoage
	FIELD idevento LIKE {&tabela}.idevento
	FIELD nrseqeve LIKE {&tabela}.nrseqeve
	FIELD qtavabom LIKE {&tabela}.qtavabom
	FIELD qtavains LIKE {&tabela}.qtavains
	FIELD qtavaoti LIKE {&tabela}.qtavaoti
	FIELD qtavareg LIKE {&tabela}.qtavareg
	FIELD qtavares LIKE {&tabela}.qtavares.

DEFINE VAR m-erros AS CHAR FORMAT "x(256)" NO-UNDO.

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

    /* Valida o Evento, se � progrid ou assembl�ia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage AND {&tttabela}.cdagenci <> 0 THEN 
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Verifica se o item de avalia��o existe */
    FIND FIRST crapiap WHERE crapiap.cdcooper = 0                    AND
                             crapiap.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.
    IF NOT AVAIL crapiap THEN
    DO:
        ASSIGN m-erros = m-erros + "Item de Avalia��o n�o encontrado.".
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
    ASSIGN {&tabela}.dsobserv = {&tttabela}.dsobserv
           {&tabela}.cdagenci = {&tttabela}.cdagenci
           {&tabela}.nrseqeve = {&tttabela}.nrseqeve
           {&tabela}.cdcooper = {&tttabela}.cdcooper
           {&tabela}.cdevento = {&tttabela}.cdevento
           {&tabela}.cdgruava = {&tttabela}.cdgruava
           {&tabela}.cditeava = {&tttabela}.cditeava
           {&tabela}.dtanoage = {&tttabela}.dtanoage
           {&tabela}.idevento = {&tttabela}.idevento
           {&tabela}.qtavares = {&tttabela}.qtavares                
           {&tabela}.qtavabom = {&tttabela}.qtavabom
           {&tabela}.qtavains = {&tttabela}.qtavains
           {&tabela}.qtavaoti = {&tttabela}.qtavaoti
           {&tabela}.qtavareg = {&tttabela}.qtavareg.

   ASSIGN aux_nrdrowid = STRING(ROWID({&tabela})).

    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */

    /* Efetuar sobreposi��es necess�rias */ 

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

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.

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

    /* Valida o Evento, se � progrid ou assembl�ia */
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBL�IA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida PA */
    FIND FIRST crapage WHERE crapage.cdagenci = {&tttabela}.cdagenci    AND
                             crapage.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapage AND {&tttabela}.cdagenci <> 0 THEN 
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inv�lido.".
        RETURN "NOK".
    END.

    /* Verifica se o item de avalia��o existe */
    FIND FIRST crapiap WHERE crapiap.cdcooper = 0                    AND
                             crapiap.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.
    IF NOT AVAIL crapiap THEN
    DO:
        ASSIGN m-erros = m-erros + "Item de Avalia��o n�o encontrado.".
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

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava     
                               EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    ASSIGN {&tabela}.dsobserv = {&tttabela}.dsobserv
           {&tabela}.cdagenci = {&tttabela}.cdagenci
           {&tabela}.nrseqeve = {&tttabela}.nrseqeve
           {&tabela}.cdcooper = {&tttabela}.cdcooper
           {&tabela}.cdevento = {&tttabela}.cdevento
           {&tabela}.cdgruava = {&tttabela}.cdgruava
           {&tabela}.cditeava = {&tttabela}.cditeava
           {&tabela}.dtanoage = {&tttabela}.dtanoage
           {&tabela}.idevento = {&tttabela}.idevento
           {&tabela}.qtavares = {&tttabela}.qtavares                
           {&tabela}.qtavabom = {&tttabela}.qtavabom
           {&tabela}.qtavains = {&tttabela}.qtavains
           {&tabela}.qtavaoti = {&tttabela}.qtavaoti
           {&tabela}.qtavareg = {&tttabela}.qtavareg.


    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */ 

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

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.

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

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                              /* {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND */
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava     
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
