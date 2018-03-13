/* .............................................................................
   Programa: progrid/web/dbo/b1wpgd0009.p
   Sistema : Progrid
   Sigla   :   
   Autor   : Rosangela
   Data    : Setembro/2005                      Ultima atualizacao: 28/06/2016

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cria��o/Altera��o/Exclus�o de Eixos Tem�ticos

   Alteracoes: 17/06/2008 - Corrigidos os FINDs e FOR EACHs e endenta��o do
                            c�digo (Evandro).
                                                        
               28/07/2009 - Inclu�da verifica��o do Nome do inscrito na procedure
                            valida-inclusao (Diego).           
                                                 
               16/10/2012 - Ajustes para o DataServer Oracle,
                            retirar CURRENT VALUE nao utilizado
                            (Gabriel).
               
               29/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                             a escrita ser� PA (Andr� Euz�bio - Supero).
               
               06/01/2014 - Busca da critica 962, para crapage nao encontrada, 
                            incluida (Carlos)
                            
               28/06/2016 - Permitir excluir se a nova situa�ao � excluido
                            PRJ229 - Melhorias OQS(Odirlei-AMcom)
............................................................................ */

&SCOPED-DEFINE tttabela cratidp
&SCOPED-DEFINE tabela   crapidp


DEFINE TEMP-TABLE {&tttabela} LIKE {&tabela}.  

DEFINE VARIABLE m-erros      AS CHAR FORMAT "x(256)" NO-UNDO.

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

    IF   NOT AVAIL {&tttabela}   THEN
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
    IF   {&tttabela}.idevento <> 1 /* PROGRID */      AND
         {&tttabela}.idevento <> 2 /* ASSEMBL�IA */   THEN
         DO:
             ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
             RETURN "NOK".
         END.

    /* Valida a Cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapcop           AND
         {&tttabela}.cdcooper <> 0   THEN
         DO:
             ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
             RETURN "NOK".
         END.

    /* Valida PA */
    FIND crapage WHERE crapage.cdcooper = {&tttabela}.cdcooper    AND
                       crapage.cdagenci = {&tttabela}.cdagenci
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapage           AND
         {&tttabela}.cdagenci <> 0   THEN 
         DO:
            FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

            IF  AVAILABLE crapcri  THEN     
                ASSIGN m-erros = m-erros + crapcri.dscritic.
            ELSE
                ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

            RETURN "NOK".
         END.

    /* Valida o Evento */
    FIND crapedp WHERE crapedp.idevento = {&tttabela}.idevento   AND
                       crapedp.cdcooper = {&tttabela}.cdcooper   AND
                       crapedp.dtanoage = {&tttabela}.dtanoage   AND
                       crapedp.cdevento = {&tttabela}.cdevento   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapedp   THEN
         DO:
             ASSIGN m-erros = m-erros + "Evento inv�lido.".
             RETURN "NOK".
         END.

    /* Valida o Operador (se nao for inscri��o da internet) */
    FIND crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper   AND
                       crapope.cdoperad = {&tttabela}.cdoperad   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapope           AND
         {&tttabela}.flginsin = NO   THEN
         DO:
             ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
             RETURN "NOK".
         END.

    /* Verifica se o cooperado existe no cadastro */
    FIND crapttl WHERE crapttl.cdcooper = {&tttabela}.cdcooper    AND
                       crapttl.nrdconta = {&tttabela}.nrdconta    AND
                       crapttl.idseqttl = {&tttabela}.idseqttl
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapttl           AND
         {&tttabela}.nrdconta <> 0   THEN
         DO:
             FIND crapass WHERE crapass.cdcooper = {&tttabela}.cdcooper    AND
                                crapass.nrdconta = {&tttabela}.nrdconta
                                NO-LOCK NO-ERROR.

             IF   NOT AVAIL crapass   THEN
                  DO:
                      ASSIGN m-erros = m-erros + "Cooperado n�o encontrado.".
                      RETURN "NOK".
                  END.
         END.
                 
        /* Valida o nome do inscrito */
    IF   TRIM({&tttabela}.nminseve) = ""   THEN
         DO:
                         ASSIGN m-erros = m-erros + "Nome do inscrito n�o pode ser branco.".
             RETURN "NOK".
         END.         
    
    /* Valida se a sequ�ncia que vai ser usada ainda n�o existe na tabela */
    FIND {&tabela} WHERE {&tabela}.idevento = {&tttabela}.idevento   AND
                         {&tabela}.cdcooper = {&tttabela}.cdcooper   AND
                         {&tabela}.dtanoage = {&tttabela}.dtanoage   AND
                         {&tabela}.cdagenci = {&tttabela}.cdagenci   AND
                         {&tabela}.cdevento = {&tttabela}.cdevento   AND
                         {&tabela}.nrseqdig = {&tttabela}.nrseqdig   AND
                         {&tabela}.nrseqeve = {&tttabela}.nrseqeve   NO-LOCK NO-ERROR.
                         
    IF   AVAIL {&tabela}   THEN
         DO:
             ASSIGN m-erros = m-erros + "Erro na sequ�ncia do c�digo da inscri��o.".
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
    DEFINE OUTPUT PARAMETER aux_nrdrowid AS CHAR NO-UNDO.

    /* Posiciona o registro da tabela tempor�ria e executa o procedimento de valida��o. */
    /* Este procedimento n�o deve executar nenhuma valida��o */
    
    FIND FIRST {&tttabela}.
        
    RUN valida-inclusao(INPUT TABLE {&tttabela}).
    
    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             retorno-erro = m-erros.
             RETURN "NOK".
         END.
    
    /* Cria o registro na tabela fisica, a partir da tabela tempor�ria */
    CREATE {&tabela}.      
    BUFFER-COPY {&tttabela} /*EXCEPT xxx*/ TO {&tabela}.
    
    aux_nrdrowid = STRING(ROWID({&tabela})).
    
    /* Fim - Cria o registro na tabela fisica, a partir da tabela tempor�ria */
    
    /* Efetuar sobreposi��es necess�rias */ 
    ASSIGN {&tabela}.nrseqdig = NEXT-VALUE(nrseqidp)
           {&tabela}.nminseve = TRIM(CAPS({&tabela}.nminseve)).
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
    FIND {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF   NOT AVAIL {&tabela}   THEN
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
    IF   {&tttabela}.idevento <> 1 /* PROGRID */      AND
         {&tttabela}.idevento <> 2 /* ASSEMBL�IA */   THEN
         DO:
             ASSIGN m-erros = m-erros + "Identifica��o do Evento inv�lido.".
             RETURN "NOK".
         END.

    /* Valida a Cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = {&tttabela}.cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapcop           AND
         {&tttabela}.cdcooper <> 0   THEN
         DO:
             ASSIGN m-erros = m-erros + "C�digo de Cooperativa inv�lido.".
             RETURN "NOK".
         END.

    /* Valida PA */
    FIND crapage WHERE crapage.cdcooper = {&tttabela}.cdcooper   AND
                       crapage.cdagenci = {&tttabela}.cdagenci
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapage           AND
         {&tttabela}.cdagenci <> 0   THEN 
         DO:
            FIND crapcri WHERE crapcri.cdcritic = 962 NO-LOCK NO-ERROR.

            IF  AVAILABLE crapcri  THEN     
                ASSIGN m-erros = m-erros + crapcri.dscritic.
            ELSE
                ASSIGN m-erros = m-erros + "C�digo do PA n�o encontrado no cadastro.".

            RETURN "NOK".
         END.

    /* Valida o Evento */
    FIND crapedp WHERE crapedp.idevento = {&tttabela}.idevento   AND
                       crapedp.cdcooper = {&tttabela}.cdcooper   AND
                       crapedp.dtanoage = {&tttabela}.dtanoage   AND
                       crapedp.cdevento = {&tttabela}.cdevento   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapedp   THEN
         DO:
             ASSIGN m-erros = m-erros + "Evento inv�lido.".
             RETURN "NOK".
         END.

    /* Valida o Operador */
    FIND crapope WHERE crapope.cdcooper = {&tttabela}.cdcooper   AND
                       crapope.cdoperad = {&tttabela}.cdoperad   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapope           AND
         {&tttabela}.flginsin = NO   THEN
         DO:
             ASSIGN m-erros = m-erros + "C�digo de Operador inv�lido.".
             RETURN "NOK".
         END.

    /* Verifica se o cooperado existe no cadastro */
    FIND crapttl WHERE crapttl.cdcooper = {&tttabela}.cdcooper   AND
                       crapttl.nrdconta = {&tttabela}.nrdconta   AND
                       crapttl.idseqttl = {&tttabela}.idseqttl
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapttl           AND
         {&tttabela}.nrdconta <> 0   THEN
         DO: 
             FIND crapass WHERE crapass.cdcooper = {&tttabela}.cdcooper   AND
                                crapass.nrdconta = {&tttabela}.nrdconta
                                NO-LOCK NO-ERROR.

             IF   NOT AVAIL crapass   THEN
                  DO: 
                      ASSIGN m-erros = m-erros + "Cooperado n�o encontrado.".
                      RETURN "NOK".
                  END.
         END.
                 
    /* Valida o nome do inscrito */
    IF   TRIM({&tttabela}.nminseve) = ""   THEN
         DO:
             ASSIGN m-erros = m-erros + "Nome do inscrito n�o pode ser branco.".
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             retorno-erro = m-erros.
             RETURN "NOK".
         END.
 
    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.
        
    /* Copia o registro da tabela tempor�ria para a tabela f�sica */
    BUFFER-COPY {&tttabela} /*EXCEPT xxx*/ TO {&tabela} NO-ERROR.
    /* Fim - Copia o registro da tabela tempor�ria para a tabela f�sica */

    /* Efetuar sobreposi��es necess�rias */ 
    ASSIGN {&tabela}.nminseve = TRIM(CAPS({&tabela}.nminseve)).
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
    FIND {&tabela} OF {&tttabela} NO-LOCK NO-ERROR.

    /* Valida��es Obrigat�rias a todas as tabelas */
    IF   NOT AVAIL {&tabela}   THEN
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

    /* Se n�o est� pendente, n�o pode alterar, a nao ser que seja inscri��o autom�tica */
    IF   {&tabela}.idstains <> 1  AND
         NOT {&tabela}.nminseve BEGINS "Inscri��o Autom�tica"   THEN
         DO:
             /* Permite excluir se a nova situa�ao � excluido */
             IF  {&tttabela}.idstains <> 5  THEN
             DO:
               ASSIGN m-erros = m-erros + "Somente inscri��es pendentes podem ser exclu�das.".
               RETURN "NOK".
             END.
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

    FIND FIRST {&tttabela}.

    RUN valida-exclusao (INPUT TABLE {&tttabela}).

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             retorno-erro = m-erros.
             RETURN "NOK".
         END.

    /* Procura na tabela f�sica o registro correspondente � tabela temporaria */
    FIND {&tabela} OF {&tttabela} EXCLUSIVE-LOCK NO-ERROR.

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

