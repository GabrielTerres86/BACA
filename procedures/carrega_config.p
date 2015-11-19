/* ..............................................................................

Procedure: carrega_config.p 
Objetivo : Ler as configurações do TAA do banco FireBird
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEF VAR conexao   AS COM-HANDLE         NO-UNDO.
DEF VAR resultado AS COM-HANDLE         NO-UNDO.
DEF VAR comando   AS COM-HANDLE         NO-UNDO.

RUN procedures/grava_log.p (INPUT "Carregando as configurações...").


IF  NOT xfs_painop_em_uso  THEN
    DO:
        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "",
                        INPUT "Carregando as configurações.",
                        INPUT "",
                        INPUT "").
        
        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
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

        IF  NOT xfs_painop_em_uso  THEN
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
            END.

        
        /* fechar e liberar a conexao */
        conexao:CLOSE()        NO-ERROR.
        RELEASE OBJECT conexao NO-ERROR.

        par_flgderro = YES.
        RETURN "NOK".
    END.


CREATE "ADODB.Command" comando.
comando:ActiveConnection = conexao.
comando:CommandText = "SELECT * FROM CRAPTFN".

CREATE "ADODB.RecordSet" resultado.
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO:
        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.
        
    

/* Quando o campo nao estiver alimentado no firebird, para o progress,
   é retornado ?, por isso o tratamento se o valor > 0 */

DO  WHILE NOT resultado:EOF():

    /* Configuracao do Terminal */
    IF  INT(resultado:FIELDS("CDCOPTFN"):VALUE) > 0  THEN
        glb_cdcoptfn = INT(resultado:FIELDS("CDCOPTFN"):VALUE).

    IF  INT(resultado:FIELDS("NRTERFIN"):VALUE) > 0  THEN
        glb_nrterfin = INT(resultado:FIELDS("NRTERFIN"):VALUE).

    IF  INT(resultado:FIELDS("CDAGETFN"):VALUE) > 0  THEN
        glb_cdagetfn = INT(resultado:FIELDS("CDAGETFN"):VALUE).

    ASSIGN glb_ipterfin = TRIM(resultado:FIELDS("IPTERFIN"):VALUE)
           glb_nmserver = TRIM(resultado:FIELDS("NMSERVER"):VALUE)
           glb_nmservic = TRIM(resultado:FIELDS("NMSERVIC"):VALUE).

    /* Temporizador */
    IF  INT(resultado:FIELDS("NRTEMPOR"):VALUE) > 0  THEN
        glb_nrtempor = INT(resultado:FIELDS("NRTEMPOR"):VALUE).
    
    /* Saque Noturno */
    IF  INT(resultado:FIELDS("HRININOT"):VALUE) > 0  THEN
        glb_hrininot = INT(resultado:FIELDS("HRININOT"):VALUE).

    IF  INT(resultado:FIELDS("HRFIMNOT"):VALUE) > 0  THEN
        glb_hrfimnot = INT(resultado:FIELDS("HRFIMNOT"):VALUE).

    IF  DEC(resultado:FIELDS("VLSAQNOT"):VALUE) > 0  THEN
        glb_vlsaqnot = DEC(resultado:FIELDS("VLSAQNOT"):VALUE).
    
    /* Leitora de Cartão */
    IF  INT(resultado:FIELDS("TPLEITOR"):VALUE) > 0  THEN
        glb_tpleitor = INT(resultado:FIELDS("TPLEITOR"):VALUE).

    /* Depositário */
    IF  INT(resultado:FIELDS("TPENVELO"):VALUE) > 0  THEN
        glb_tpenvelo = INT(resultado:FIELDS("TPENVELO"):VALUE).

    resultado:MoveNext().
END.


/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.


/* verifica se os parametros principais estao carregados */
IF  glb_cdcoptfn = 0   OR
    glb_nrterfin = 0   OR
    glb_cdagetfn = 0   OR
    glb_ipterfin = ""  OR
    glb_nmserver = ""  OR
    glb_nmservic = ""  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Configuração inválida.").

        IF  NOT xfs_painop_em_uso  THEN
            DO:        
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "Configuração Inválida!",
                                INPUT "",
                                INPUT "Um ou mais parâmetros não são",
                                INPUT "válidos. Verifique a",
                                INPUT "configuração do equipamento").
                
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            END.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.
        

/* Verifica o IP do TAA */
DEFINE VARIABLE aux_nmdohost    AS CHAR     NO-UNDO.
DEFINE VARIABLE aux_ipdohost    AS CHAR     NO-UNDO.

RUN procedures/ver_ip_host.p (OUTPUT aux_nmdohost,
                              OUTPUT aux_ipdohost).

IF  glb_ipterfin <> aux_ipdohost  AND   /* mudou IP */
    aux_ipdohost <> "127.0.0.1"   THEN  /* fora da rede, localhost */
    DO:
        RUN procedures/grava_log.p (INPUT "IP inválido.").

        IF  NOT xfs_painop_em_uso  THEN
            DO:
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "IP Inválido!",
                                INPUT "O sistema pode ter sido",
                                INPUT "configurado em outro TAA.",
                                INPUT "Verifique a configuração do",
                                INPUT "equipamento.").
                
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            END.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.

RUN procedures/grava_log.p (INPUT "Configurações carregadas com sucesso.").

RETURN "OK".
    
/* ............................................................................ */
