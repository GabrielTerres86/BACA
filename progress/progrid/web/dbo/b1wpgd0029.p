/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0029.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 16/06/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Criação/Alteração/Exclusão de Avaliações de Eventos
   
   Alteracoes: 30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
   
               09/07/2012 - Tratamento de CLOB para CHAR - ORACLE (Guilherme).
               
               29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).

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
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
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
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inválido.".
        RETURN "NOK".
    END.

    /* Verifica se o item de avaliação existe */
    FIND FIRST crapiap WHERE crapiap.cdcooper = 0                    AND
                             crapiap.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.
    IF NOT AVAIL crapiap THEN
    DO:
        ASSIGN m-erros = m-erros + "Item de Avaliação não encontrado.".
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

    IF RETURN-VALUE = "NOK" THEN DO:
        retorno-erro = m-erros.
        RETURN "NOK".
    END.

    /* Cria o registro na tabela fisica, a partir da tabela temporária */
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

    /* Fim - Cria o registro na tabela fisica, a partir da tabela temporária */

    /* Efetuar sobreposições necessárias */ 

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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.

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
    IF {&tttabela}.idevento <> 1 /* PROGRID */
       AND {&tttabela}.idevento <> 2 /* ASSEMBLÉIA */
       THEN
    DO:
        ASSIGN m-erros = m-erros + "Identificação do Evento inválido.".
        RETURN "NOK".
    END.

    /* Valida a Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop AND {&tttabela}.cdcooper <> 0 THEN
    DO:
        ASSIGN m-erros = m-erros + "Código de Cooperativa inválido.".
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
            ASSIGN m-erros = m-erros + "Código do PA não encontrado no cadastro.".

        RETURN "NOK".
    END.

    /* Valida o Evento */
    FIND FIRST crapedp WHERE crapedp.cdevento = {&tttabela}.cdevento    NO-LOCK NO-ERROR.
    IF NOT AVAIL crapedp THEN
    DO:
        ASSIGN m-erros = m-erros + "Evento inválido.".
        RETURN "NOK".
    END.

    /* Verifica se o item de avaliação existe */
    FIND FIRST crapiap WHERE crapiap.cdcooper = 0                    AND
                             crapiap.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.
    IF NOT AVAIL crapiap THEN
    DO:
        ASSIGN m-erros = m-erros + "Item de Avaliação não encontrado.".
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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava     
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
    IF AVAILABLE {&tabela} THEN                           
      DO:
        /* Copia o registro da tabela temporária para a tabela física */
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
      END.

    /* Fim - Copia o registro da tabela temporária para a tabela física */

    /* Efetuar sobreposições necessárias */ 

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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND
                               {&tabela}.cdgruava = {&tttabela}.cdgruava AND
                               {&tabela}.cditeava = {&tttabela}.cditeava NO-LOCK NO-ERROR.

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
    FIND FIRST {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento AND
                               {&tabela}.cdcooper = {&tttabela}.cdcooper AND
                               {&tabela}.cdagenci = {&tttabela}.cdagenci AND
                               {&tabela}.dtanoage = {&tttabela}.dtanoage AND
                               {&tabela}.cdevento = {&tttabela}.cdevento AND
                               {&tabela}.nrseqeve = {&tttabela}.nrseqeve AND /* teste */
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
