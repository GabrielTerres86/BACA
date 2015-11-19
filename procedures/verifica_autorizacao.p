/* ..............................................................................

 Procedure: verifica_autorizacao.p 
 Objetivo : Solicitar ao servidor se o TAA pode funcionar
 Autor    : Evandro
 Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado
                               Buscar a agencia da cooperativa na central
                               (Evandro).
                               
                  23/02/2011 - Incluidos campo para reboot e update do sistema
                              (Evandro).
                              
                  27/08/2015 - Detalhamento de log na inicialização do TAA
                               Lucas Lunelli (SD 291639)            

............................................................................... */


DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.

DEFINE         VARIABLE aux_dtmvtocd    AS DATE                 NO-UNDO.

RUN procedures/grava_log.p (INPUT "Verificando autorização...").

REQUISICAO:
DO:
    DEFINE VARIABLE ponteiro_xml AS MEMPTR      NO-UNDO.
    
    CREATE X-DOCUMENT xDoc.
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xField.
    CREATE X-NODEREF  xText.
    
    /* ---------- */
    xDoc:CREATE-NODE(xRoot,"TAA","ELEMENT").
    xDoc:APPEND-CHILD(xRoot).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDCOPTFN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_cdcoptfn).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDAGETFN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_cdagetfn).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRTERFIN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_nrterfin).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"OPERACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "9999".
    xField:APPEND-CHILD(xText).
    
    xDoc:SAVE("MEMPTR",ponteiro_xml).
    
    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xField.
    DELETE OBJECT xText.
    
    xml_req = GET-STRING(ponteiro_xml,1).

    /* Em requisicao HTML nao usa " ", "=" e quebra de linha */
    ASSIGN xml_req = REPLACE(xml_req," ","%20")
           xml_req = REPLACE(xml_req,"=","%3D")
           xml_req = REPLACE(xml_req,CHR(10),"")
           xml_req = REPLACE(xml_req,CHR(13),"").

    SET-SIZE(ponteiro_xml) = 0.
END. /* Fim REQUISICAO */


RESPOSTA:
DO:
    DEFINE VARIABLE aux_contador  AS INTEGER     NO-UNDO.
    
    CREATE X-DOCUMENT xDoc.
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xField.
    CREATE X-NODEREF  xText.

    /* guarda a data antes da autorizacao */
    RUN carrega_ultima_data (OUTPUT aux_dtmvtocd).

    IF  aux_dtmvtocd = ?  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Autorização - Sem data de saldo.").
        
            RUN mensagem.w (INPUT YES,
                            INPUT "      ERRO!",
                            INPUT "",
                            INPUT "TAA sem data de saldo",
                            INPUT "",
                            INPUT "",
                            INPUT "").
        
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
        
            par_flgderro = YES.
            LEAVE.
        END.

    /* seta reboot e update como default - NO */
    ASSIGN glb_flreboot = NO
           glb_flupdate = NO.

    DO  WHILE TRUE:

        xDoc:LOAD("FILE","http://" + glb_nmserver + ".cecred.coop.br/" +
                         "cgi-bin/cgiip.exe/WService=" + glb_nmservic + "/" + 
                         "TAA_autorizador.p?xml=" + xml_req,FALSE) NO-ERROR.
                           
        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
        IF  xDoc:NUM-CHILDREN  = 0       OR
            xRoot:NAME        <> "TAA"  THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Autorização - Sem comunicação com o servidor").

                RUN mensagem.w (INPUT YES,
                                INPUT "      ERRO!",
                                INPUT "",
                                INPUT "Sem comunicação com o Servidor",
                                INPUT "",
                                INPUT "",
                                INPUT "").

                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
    
                par_flgderro = YES.
                LEAVE.
            END.
    
        DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xField,aux_contador).
            
            IF  xField:SUBTYPE <> "ELEMENT"  THEN
                NEXT.
    
            xField:GET-CHILD(xText,1).
    
            IF  xField:NAME = "AUTORIZACAO"  AND
                xText:NODE-VALUE = "OK"      THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "NMCOPTFN"  THEN
                glb_nmcoptfn = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "AGCTLTFN"  THEN
                glb_agctltfn = INT(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DTMVTOAN"  THEN
                glb_dtmvtoan = DATE(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DTMVTOLT"  THEN
                glb_dtmvtolt = DATE(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DTMVTOPR"  THEN
                glb_dtmvtopr = DATE(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DTMVTOCD"  THEN
                glb_dtmvtocd = DATE(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "REBOOT"  THEN
                glb_flreboot = LOGICAL(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "UPDATE"  THEN
                glb_flupdate = LOGICAL(xText:NODE-VALUE).
            ELSE
                DO:
                    par_flgderro = YES.

                    RUN procedures/grava_log.p (INPUT "Autorização - " + xText:NODE-VALUE). 

                    RUN mensagem.w (INPUT YES,
                                    INPUT "      ERRO!",
                                    INPUT "",
                                    INPUT "",
                                    INPUT xText:NODE-VALUE,
                                    INPUT "",
                                    INPUT "").

                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
                END.
        END. /* Fim DO..TO.. */


        LEAVE.
    END. /* Fim WHILE */
        
    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xField.
    DELETE OBJECT xText.

END. /* Fim RESPOSTA */

IF  par_flgderro  THEN
    RETURN "NOK".


/* Virou a data */
IF  aux_dtmvtocd <> ?             AND
    aux_dtmvtocd <> glb_dtmvtocd  THEN
    DO:
        /* nao permite mudanca de data para o passado */
        IF  aux_dtmvtocd > glb_dtmvtocd  THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Autorização - Virada de data inválida"). 

                RUN mensagem.w (INPUT YES,
                                INPUT "      ERRO!",
                                INPUT "",
                                INPUT "",
                                INPUT "Data do sistema inválida!",
                                INPUT "",
                                INPUT "").

                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.

                par_flgderro = YES.
                RETURN "NOK".
            END.


        /* faz os tratamentos de virada de data referente a
           data anterior, fechamento e abertura de novo
           registro de saldo */
        RUN procedures/vira_data.p ( INPUT aux_dtmvtocd,
                                    OUTPUT par_flgderro).

        IF  par_flgderro  THEN
            RETURN "NOK".
    END.

    RUN procedures/grava_log.p (INPUT "Autorizações Verificadas.").

RETURN "OK".



PROCEDURE carrega_ultima_data:
    DEFINE OUTPUT PARAM par_dtmvtocd    AS DATE         NO-UNDO.

    DEF VAR conexao   AS COM-HANDLE         NO-UNDO.
    DEF VAR resultado AS COM-HANDLE         NO-UNDO.
    DEF VAR comando   AS COM-HANDLE         NO-UNDO.
    
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
    
            
            /* fechar e liberar a conexao */
            conexao:CLOSE()        NO-ERROR.
            RELEASE OBJECT conexao NO-ERROR.
    
            par_flgderro = YES.
            RETURN "NOK".
        END.
    
    
    CREATE "ADODB.Command" comando.
    comando:ActiveConnection = conexao.
    comando:CommandText = "SELECT MAX(DTMVTOLT) ~"DTMVTOLT~" FROM CRAPSTF".
    
    CREATE "ADODB.RecordSet" resultado.
    resultado = comando:EXECUTE(,,) NO-ERROR.
    
    IF  resultado = ?  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Autorização - Erro no comando SQL.").

            /* fechar e liberar a conexao */
            conexao:CLOSE()          NO-ERROR.
            RELEASE OBJECT conexao   NO-ERROR.
            RELEASE OBJECT comando   NO-ERROR.
            RELEASE OBJECT resultado NO-ERROR.
            
            par_flgderro = YES.
            RETURN "NOK".
        END.
            
        
    
    DO  WHILE NOT resultado:EOF():
    
        /* Ultima data de saldos */
        IF  DATE(resultado:FIELDS("DTMVTOLT"):VALUE) <> ?  THEN
            par_dtmvtocd = DATE(resultado:FIELDS("DTMVTOLT"):VALUE).
    
        resultado:MoveNext().
    END.
    
    
    /* fechar e liberar a conexao */
    conexao:CLOSE()          NO-ERROR.
    RELEASE OBJECT conexao   NO-ERROR.
    RELEASE OBJECT comando   NO-ERROR.
    RELEASE OBJECT resultado NO-ERROR.

    /* forca o carregamento dos saldos */
    RUN procedures/carrega_suprimento(OUTPUT par_flgderro).


    RETURN "OK".
END PROCEDURE.
/* Fim carrega_ultima_data */

/* ............................................................................ */

