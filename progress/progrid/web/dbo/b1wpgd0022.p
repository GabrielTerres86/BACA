/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0022.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 06/01/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Custos Realizados
   
   Altera��o : 10/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).
                            
               06/01/2014 - Busca da critica 962, para crapage nao encontrada,
                            incluida (Carlos)
............................................................................ */
&SCOPED-DEFINE tttabela cratcrp
&SCOPED-DEFINE tabela   crapcrp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

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
    IF NOT AVAIL crapage AND {&tttabela}.cdagenci <> 0 THEN
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN     
            ASSIGN m-erros = m-erros + crapcri.dscritic.
        ELSE
            ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.

    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> ? AND {&tttabela}.cdevento <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inv�lido.".
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

    /* Valida se o custo do evento � aceito pela tabela */
    IF {&tttabela}.vlcusrea > 9999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor muito grande para ser gravado na tabela.".
        RETURN "NOK".
    END.

    /* verifica se o tipo de evento existe */
    IF  {&tttabela}.tpcuseve = 1 THEN 
    DO:
        FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "CONFIG"        AND
                                 craptab.cdempres = 0               AND
                                 craptab.cdacesso = "PGDCUSTEVE"    AND
                                 craptab.tpregist = 0               NO-LOCK NO-ERROR.
        IF AVAIL craptab THEN
        DO:
            IF lookup(string({&tttabela}.cdcuseve), craptab.dstextab, ",") = 0 THEN 
            DO:
                ASSIGN m-erros = m-erros + "Tipo de Custo inv�lido.".
                RETURN "NOK".
            END.
        END.
        ELSE DO:
            ASSIGN m-erros = m-erros + "Problemas na grava��o do custo.".
            RETURN "NOK".
        END.
    END.
    /*
    IF  {&tttabela}.tpcuseve = 2 THEN 
    DO:
        ASSIGN m-erros = m-erros + STRING({&tttabela}.idEvento)+ STRING({&tttabela}.cdCooper) + STRING({&tttabela}.dtAnoAge) + STRING({&tttabela}.cdcuseve).
            RETURN "NOK".                                                             
                                                                
    END.                           
    ELSE                           
        DO:
        ASSIGN m-erros = m-erros + "tpcuseve = 1".
            RETURN "NOK".

    END.*/
    /* verifica se o tipo de evento existe */
    IF  {&tttabela}.tpcuseve = 2 THEN 
    DO:
        FIND FIRST crapcdi WHERE crapcdi.nrseqdig = {&tttabela}.cdcuseve NO-LOCK NO-ERROR.
        IF NOT AVAIL crapcdi THEN
        DO:
            ASSIGN m-erros = m-erros + "Custo indireto n�o encontrado.".
            RETURN "NOK".
        END.
    END.
  
    /*valida a existencia de um or�amento para o custo realizado a ser informado*/
    IF  {&tttabela}.tpcuseve = 2 THEN 
    DO:
        
        FIND FIRST Crapcdp WHERE Crapcdp.IdEvento = {&tttabela}.idEvento    AND
                                 Crapcdp.CdCooper = {&tttabela}.cdCooper    AND
                                 Crapcdp.DtAnoAge = {&tttabela}.dtAnoAge    AND
                                 Crapcdp.TpCusEve = 2                       AND           
                                 Crapcdp.CdCusEve = {&tttabela}.cdcuseve    NO-LOCK NO-ERROR.
        IF NOT AVAIL Crapcdp THEN
        DO:
            ASSIGN m-erros = m-erros + "Custo sem or�amento. Inclua um or�amento para esse custo atrav�s da tela de Custos Or�ados.".
            RETURN "NOK".
        END.
    END.
   
    /* Verifica se a chave �nica est� sendo respeitada */
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento    AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper    AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci    AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage    AND
                               {&tabela}.tpcuseve = {&tttabela}.tpcuseve    AND
                               {&tabela}.cdevento = {&tttabela}.cdevento    AND
                               {&tabela}.cdcuseve = {&tttabela}.cdcuseve    AND 
                               {&tabela}.nrseqdig = {&tttabela}.nrseqdig    NO-LOCK NO-ERROR.

    IF AVAIL {&tabela} THEN
    DO:
        ASSIGN m-erros = m-erros + "Registro j� existe com a chave informada." + STRING({&tabela}.nrseqdig)  + STRING({&tttabela}.nrseqdig).
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
    BUFFER-COPY {&tttabela} /*EXCEPT xxx*/ TO {&tabela}.
    ASSIGN {&tabela}.nrseqdig = NEXT-VALUE(nrseqcrp).

    aux_nrdrowid = STRING(ROWID({&tabela})).

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

    FIND FIRST {&tttabela}.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
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

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp AND {&tttabela}.cdevento <> ? AND {&tttabela}.cdevento <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inv�lido.".
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

    /* Valida se o custo do evento � aceito pela tabela */
    IF {&tttabela}.vlcusrea > 9999.99 THEN
    DO:
        ASSIGN m-erros = m-erros + "Valor muito grande para ser gravado na tabela.".
        RETURN "NOK".
    END.

    /* verifica se o tipo de evento existe */
    IF  {&tttabela}.tpcuseve = 1 THEN /* 1-custo diretos gravado na tabela CRAPTAB*/
    DO:
        FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                 craptab.nmsistem = "CRED"          AND
                                 craptab.tptabela = "CONFIG"        AND
                                 craptab.cdempres = 0               AND
                                 craptab.cdacesso = "PGDCUSTEVE"    AND
                                 craptab.tpregist = 0               NO-LOCK NO-ERROR.
        IF AVAIL craptab THEN
        DO:
            IF lookup(string({&tttabela}.cdcuseve), craptab.dstextab, ",") = 0 THEN 
            DO:
                ASSIGN m-erros = m-erros + "Tipo de Custo inv�lido.".
                RETURN "NOK".
            END.
        END.
        ELSE DO:
            ASSIGN m-erros = m-erros + "Problemas na grava��o do custo.".
            RETURN "NOK".
        END.
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
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} /*EXCEPT xxx*/ TO {&tabela} NO-ERROR.

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

    FIND FIRST {&tttabela}.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
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
    FIND FIRST {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.

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
    DEFINE INPUT  PARAMETER ponteiro AS ROWID NO-UNDO.
    DEFINE OUTPUT PARAMETER retorno-erro AS CHAR FORMAT "x(256)" NO-UNDO.

    FIND FIRST {&tabela} WHERE ROWID({&tabela}) = ponteiro NO-LOCK NO-ERROR.

    IF NOT AVAIL {&tabela} THEN
    DO:
        ASSIGN retorno-erro = "Registro n�o encontrado.".
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.
