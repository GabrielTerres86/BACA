/* ..............................................................................

Procedure: atualiza_nmserver.p 
Objetivo : Alterar crampo nmserver na tabela local craptfn (firebird) para
           novo dom�nio que ser� utilizado no Projeto Oracle
Autor    : David
Data     : Abril 2014


Ultima altera��o: 

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_TAA.i }

DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.

RUN procedures/grava_log.p (INPUT "Atualizando dom�nio do servidor...").

RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Atualizando dom�nio do servidor.",
                INPUT "",
                INPUT "").

PAUSE 3 NO-MESSAGE.
h_mensagem:HIDDEN = YES.

/* Conexao com o Firebird 
   1-Conexao ODBC criada em Ferramentas ADM do Windows
   2-Usuario
   3-Senha */

CREATE "ADODB.Connection" conexao.
conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro na conex�o com o banco de dados FireBird").

        RUN mensagem.w (INPUT YES,
                        INPUT "    ATEN��O",
                        INPUT "",
                        INPUT "Erro na conex�o com o banco de",
                        INPUT "dados. Verifique a instala��o",
                        INPUT "do equipamento.",
                        INPUT "").

        PAUSE 4 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        RUN libera_conexao.
        par_flgderro = YES.

        RETURN "NOK".
    END.

RUN procedures/grava_log.p (INPUT "Efetuando atualiza��o: NMSERVER=taa").

CREATE "ADODB.Command" comando.
CREATE "ADODB.RecordSet" resultado.
comando:ActiveConnection = conexao.

/* atualiza nmserver no banco local */
comando:CommandText = "UPDATE CRAPTFN SET NMSERVER = 'taa'".
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.

        RETURN "NOK".
    END.

RUN libera_conexao.

/* atualiza nmserver na vari�vel global */
ASSIGN glb_nmserver = "taa".

/* Informa a configuracao ao Servidor */
RUN procedures/grava_log.p (INPUT "Dom�nio do servidor atualizado com sucesso.").

RETURN "OK".

PROCEDURE libera_conexao:
    
    /* fechar e liberar a conexao */
    conexao:CLOSE()          NO-ERROR.
    RELEASE OBJECT conexao   NO-ERROR.
    RELEASE OBJECT comando   NO-ERROR.
    RELEASE OBJECT resultado NO-ERROR.

END PROCEDURE.


/* ........................................................................... */

