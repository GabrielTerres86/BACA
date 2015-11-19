/* ..............................................................................

Procedure: efetua_saque.p 
Objetivo : Validar e efetuar o saque
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }


/* Atualiza o K7R com as notas rejeitadas */
DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.

/* Conexao com o Firebird 
   1-Conexao ODBC criada em Ferramentas ADM do Windows
   2-Usuario
   3-Senha */

CREATE "ADODB.Connection" conexao.
conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO",
                        INPUT "",
                        INPUT "Erro na conexão com o banco de",
                        INPUT "dados. Verifique a instalação",
                        INPUT "do equipamento.",
                        INPUT "").

        PAUSE 4 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        par_flgderro = YES.
        RETURN "NOK".
    END.

CREATE "ADODB.Command" comando.
comando:ActiveConnection = conexao.
comando:CommandText = "UPDATE CRAPTFN SET QTNOTK7R = " + STRING(glb_qtnotK7R) + ", " +
                                         "VLNOTK7R = " + STRING(glb_vlnotK7R).
                                  
CREATE "ADODB.RecordSet" resultado.
resultado = comando:EXECUTE(,,).

/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.

RETURN "OK".

/* ............................................................................ */
