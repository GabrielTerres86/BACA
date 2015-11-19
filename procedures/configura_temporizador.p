/* ..............................................................................

 Procedure: configura_temporizador.p 
 Objetivo : Configura o temporizador de timeout das telas
 Autor    : Evandro
 Data     : Agosto 2011

Ultima alteração: 

............................................................................... */

DEFINE  INPUT PARAMETER par_nrtempor    AS INT                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i }


DEF VAR buff      AS CHAR     EXTENT 6  NO-UNDO.

DEF VAR conexao   AS COM-HANDLE         NO-UNDO.
DEF VAR resultado AS COM-HANDLE         NO-UNDO.
DEF VAR comando   AS COM-HANDLE         NO-UNDO.

/* Conexao com o Firebird 
   1-Conexao ODBC criada em Ferramentas ADM do Windows
   2-Usuario
   3-Senha */


RUN procedures/grava_log.p (INPUT "Configurando temporizador...").


CREATE "ADODB.Connection" conexao.
conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro na conexão com o banco de dados FireBird").

        IF  xfs_painop_em_uso  THEN
            DO:
                buff = "".
                RUN procedures/atualiza_painop.p (INPUT buff).
                                  
                ASSIGN buff[2] = " ERRO NA CONEXAO COM O BANCO DE DADOS"
                       buff[4] = "VERIFIQUE A INSTALACAO DO EQUIPAMENTO".
        
                RUN procedures/atualiza_painop.p (INPUT buff).
        
                PAUSE 2 NO-MESSAGE.
            END.
        ELSE
            DO:
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "",
                                INPUT "Erro na conexão com o banco de",
                                INPUT "dados. Verifique a instalação",
                                INPUT "do equipamento.",
                                INPUT "").
                
                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            END.

        /* fechar e liberar a conexao */
        conexao:CLOSE()        NO-ERROR.
        RELEASE OBJECT conexao NO-ERROR.

        par_flgderro = YES.
        RETURN "NOK".
    END.

IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
                          
        ASSIGN buff[4] = "      SALVANDO AS CONFIGURACOES".
        RUN procedures/atualiza_painop.p (INPUT buff).

        PAUSE 2 NO-MESSAGE.
    END.
ELSE
    DO:
        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "",
                        INPUT "Salvando as configurações.",
                        INPUT "",
                        INPUT "").
        
        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
    END.


RUN procedures/grava_log.p (INPUT "Escolhido tempo de " + STRING(par_nrtempor) + " segundos.").


CREATE "ADODB.Command" comando.
comando:ActiveConnection = conexao.
comando:CommandText = "UPDATE CRAPTFN " +
                      "SET NRTEMPOR = " + STRING(par_nrtempor * 1000).

CREATE "ADODB.RecordSet" resultado.
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").


        IF  xfs_painop_em_uso  THEN
            DO:
                buff = "".
                RUN procedures/atualiza_painop.p (INPUT buff).

                ASSIGN buff[2] = "        CONFIGURACAO CRITICADA"
                       buff[4] = "   VERIFIQUE LOG PARA MAIS DETALHES".

                RUN procedures/atualiza_painop.p (INPUT buff).
                
                PAUSE 2 NO-MESSAGE.
            END.
        ELSE
            DO:
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "",
                                INPUT "Não foi possível efetuar",
                                INPUT "a configuração.",
                                INPUT "",
                                INPUT "").
                
                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            END.


        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.

        par_flgderro = YES.
        RETURN "NOK".
    END.



/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.


RUN procedures/carrega_config.p (OUTPUT par_flgderro).

/* Atualiza o saque noturno e o temporizador no servidor */
RUN procedures/atualiza_noturno_temporizador.


IF  par_flgderro  THEN
    RETURN "NOK".

RETURN "OK".

/* ............................................................................ */

