/* ..............................................................................

Procedure: carrega_suprimento.p 
Objetivo : Ler o suprimento do TAA do banco FireBird
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEF VAR aux_mostralog AS LOGICAL    INIT NO     NO-UNDO.

DEF VAR conexao       AS COM-HANDLE             NO-UNDO.
DEF VAR resultado     AS COM-HANDLE             NO-UNDO.
DEF VAR comando       AS COM-HANDLE             NO-UNDO.

/* Quando for ler o suprimento na primeira vez, exibe no log */
IF  glb_qtnotK7A = 0  AND
    glb_qtnotK7B = 0  AND
    glb_qtnotK7C = 0  AND
    glb_qtnotK7D = 0  AND

    glb_vlnotK7A = 0  AND
    glb_vlnotK7B = 0  AND
    glb_vlnotK7C = 0  AND
    glb_vlnotK7D = 0  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Carregando o suprimento...").
        aux_mostralog = YES.
    END.


/* Conexao com o Firebird 
   1-Conexao ODBC criada em Ferramentas ADM do Windows
   2-Usuario
   3-Senha */
CREATE "ADODB.Connection" conexao.
conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro na conexão com o banco de dados FireBird.").

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

        /* fechar e liberar a conexao */
        conexao:CLOSE()        NO-ERROR.
        RELEASE OBJECT conexao NO-ERROR.

        RETURN "NOK".
    END.


CREATE "ADODB.Command" comando.
comando:ActiveConnection = conexao.
comando:CommandText = "SELECT * FROM CRAPTFN".

CREATE "ADODB.RecordSet" resultado.
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").

        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.


/* Quando o campo nao estiver alimentado no firebird, para o progress,
   é retornado ?, por isso o tratamento se o valor >= 0 */

DO  WHILE NOT resultado:EOF():

    /* Quantidade de Notas */
    IF  INT(resultado:FIELDS("QTNOTK7A"):VALUE) >= 0  THEN
        glb_qtnotk7A = INT(resultado:FIELDS("QTNOTK7A"):VALUE).

    IF  INT(resultado:FIELDS("QTNOTK7B"):VALUE) >= 0  THEN
        glb_qtnotk7B = INT(resultado:FIELDS("QTNOTK7B"):VALUE).

    IF  INT(resultado:FIELDS("QTNOTK7C"):VALUE) >= 0  THEN
        glb_qtnotk7C = INT(resultado:FIELDS("QTNOTK7C"):VALUE).

    IF  INT(resultado:FIELDS("QTNOTK7D"):VALUE) >= 0  THEN
        glb_qtnotk7D = INT(resultado:FIELDS("QTNOTK7D"):VALUE).

    IF  INT(resultado:FIELDS("QTNOTK7R"):VALUE) >= 0  THEN
        glb_qtnotk7R = INT(resultado:FIELDS("QTNOTK7R"):VALUE).


    /* Valor das Notas */
    IF  INT(resultado:FIELDS("VLNOTK7A"):VALUE) >= 0  THEN
        glb_vlnotk7A = INT(resultado:FIELDS("VLNOTK7A"):VALUE).

    IF  INT(resultado:FIELDS("VLNOTK7B"):VALUE) >= 0  THEN
        glb_vlnotk7B = INT(resultado:FIELDS("VLNOTK7B"):VALUE).

    IF  INT(resultado:FIELDS("VLNOTK7C"):VALUE) >= 0  THEN
        glb_vlnotk7C = INT(resultado:FIELDS("VLNOTK7C"):VALUE).

    IF  INT(resultado:FIELDS("VLNOTK7D"):VALUE) >= 0  THEN
        glb_vlnotk7D = INT(resultado:FIELDS("VLNOTK7D"):VALUE).

    IF  INT(resultado:FIELDS("VLNOTK7R"):VALUE) >= 0  THEN
        glb_vlnotk7R = INT(resultado:FIELDS("VLNOTK7R"):VALUE).


    /* Envelopes */
    IF  INT(resultado:FIELDS("QTENVELO"):VALUE) >= 0  THEN
        glb_qtenvelo = INT(resultado:FIELDS("QTENVELO"):VALUE).


    resultado:MoveNext().
END.



/* Busca o último registro de operações para verificar situação do TAA, 1-ABERTO OU 2-FECHADO */                              
comando:CommandText = "SELECT TPDTRANS FROM CRAPLFN " +
                             "WHERE (TPDTRANS = 1 OR " +
                                    "TPDTRANS = 2) AND " +
                                    "CDSITATU = 1 AND " +
                                    "DTTRANSA = (SELECT MAX(DTTRANSA) FROM CRAPLFN " +
                                                       "WHERE  CDSITATU = 1 AND " +
                                                             "(TPDTRANS = 1 OR " +
                                                              "TPDTRANS = 2)) AND " +
                                    
                                    "HRTRANSA = (SELECT MAX(HRTRANSA) FROM CRAPLFN " +
                                                       "WHERE CDSITATU = 1 AND " +
                                                            "(TPDTRANS = 1 OR " +
                                                             "TPDTRANS = 2) AND " +
                                                             "DTTRANSA = (SELECT MAX(DTTRANSA) FROM CRAPLFN " +
                                                                                "WHERE CDSITATU = 1 AND " +
                                                                                     "(TPDTRANS = 1 OR " +
                                                                                      "TPDTRANS = 2)))".
                         
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").

        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.


/* Quando o campo nao estiver alimentado no firebird, para o progress,
   é retornado ?, por isso o tratamento se o valor >= 0 */

DO  WHILE NOT resultado:EOF():

    /* Situacao do Terminal é controlada pela ultima operação efetuada */
    IF  INT(resultado:FIELDS("TPDTRANS"):VALUE) >= 0  THEN
        glb_cdsittfn = INT(resultado:FIELDS("TPDTRANS"):VALUE).

    resultado:MoveNext().
END.
                                

/* se nao tiver situacao, configura como fechado */
IF  glb_cdsittfn = 0  THEN
    glb_cdsittfn = 2.


/* verifica a ultima operacao de suprimento ou recolhimento */
comando:CommandText = "SELECT TPDTRANS FROM CRAPLFN " +
                             "WHERE (TPDTRANS = 4 OR " +
                                    "TPDTRANS = 5) AND " +
                                    "CDSITATU = 1 AND " +
                                    "DTTRANSA = (SELECT MAX(DTTRANSA) FROM CRAPLFN " +
                                                       "WHERE  CDSITATU = 1 AND " +
                                                             "(TPDTRANS = 4 OR " +
                                                              "TPDTRANS = 5)) AND " +
                                    
                                    "HRTRANSA = (SELECT MAX(HRTRANSA) FROM CRAPLFN " +
                                                       "WHERE CDSITATU = 1 AND " +
                                                            "(TPDTRANS = 4 OR " +
                                                             "TPDTRANS = 5) AND " +
                                                             "DTTRANSA = (SELECT MAX(DTTRANSA) FROM CRAPLFN " +
                                                                                "WHERE CDSITATU = 1 AND " +
                                                                                     "(TPDTRANS = 4 OR " +
                                                                                      "TPDTRANS = 5)))".
                         
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").

        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.


/* Quando o campo nao estiver alimentado no firebird, para o progress,
   é retornado ?, por isso o tratamento se o valor >= 0 */

DO  WHILE NOT resultado:EOF():

    /* se a ultima operação for de suprimento */
    IF  INT(resultado:FIELDS("TPDTRANS"):VALUE) = 4  THEN
        glb_flgsupri = YES.
    ELSE
        glb_flgsupri = NO.

    resultado:MoveNext().
END.
       



/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.

IF  aux_mostralog  THEN
    RUN procedures/grava_log.p (INPUT "Suprimento carregado com sucesso.").

RETURN "OK".

/* ............................................................................ */
