/* ..............................................................................

Procedure: vira_data.p 
Objetivo : Grava registros de saldo devido a virada de data
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

............................................................................... */

DEFINE  INPUT PARAMETER par_dtmvtolt    AS DATE                 NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.

DEFINE         VARIABLE aux_vldsdini    AS DECIMAL              NO-UNDO.
DEFINE         VARIABLE aux_vldmovto    AS DECIMAL              NO-UNDO.
DEFINE         VARIABLE aux_vldsdfin    AS DECIMAL              NO-UNDO.


RUN procedures/grava_log.p (INPUT "Virando a data...").

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
    xText:NODE-VALUE = "15".
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dtmvtolt).
    xField:APPEND-CHILD(xText).
    

    RUN verifica_saldos.

    IF  par_flgderro  THEN
        RETURN "NOK".
    

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLDSDINI","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vldsdini).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLDMOVTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vldmovto).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLDSDFIN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vldsdfin).
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

    DO  WHILE TRUE:

        xDoc:LOAD("FILE","http://" + glb_nmserver + ".cecred.coop.br/" +
                         "cgi-bin/cgiip.exe/WService=" + glb_nmservic + "/" + 
                         "TAA_autorizador.p?xml=" + xml_req,FALSE) NO-ERROR.
                           
        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
        IF  xDoc:NUM-CHILDREN  = 0       OR
            xRoot:NAME        <> "TAA"  THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Vira Data - Sem comunicação com o servidor").

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
    
            IF  xField:NAME = "VIRADATA"  AND
                xText:NODE-VALUE = "OK"   THEN
                par_flgderro = NO.
            ELSE
                DO:
                    par_flgderro = YES.

                    RUN procedures/grava_log.p (INPUT "Vira Data - " + xText:NODE-VALUE). 

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

/* se o servidor aceitou a virada, grava local */
RUN grava_saldos.

IF  par_flgderro  THEN
    RETURN "NOK".


RUN procedures/grava_log.p (INPUT "Data virada com sucesso.").

RETURN "OK".



PROCEDURE verifica_saldos:

    DEF VAR aux_dsmvtolt    AS CHAR             NO-UNDO.
    
    DEF VAR conexao         AS COM-HANDLE       NO-UNDO.
    DEF VAR resultado       AS COM-HANDLE       NO-UNDO.
    DEF VAR comando         AS COM-HANDLE       NO-UNDO.
    
    
    RUN procedures/grava_log.p (INPUT "Verificando saldos...").

    
    /* Conexao com o Firebird 
       1-Conexao ODBC criada em Ferramentas ADM do Windows
       2-Usuario
       3-Senha */
    CREATE "ADODB.Connection" conexao.
    conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 
    
    IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Erro na conexão com o banco de dados FireBird").
    
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
    CREATE "ADODB.RecordSet" resultado.


    /* MM/DD/YYYY */
    aux_dsmvtolt = "'" + SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2) + "/" +
                         SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2) + "/" +
                         SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4) + "'".

    comando:ActiveConnection = conexao.
    comando:CommandText = "SELECT VLDSDINI FROM CRAPSTF WHERE DTMVTOLT = " + aux_dsmvtolt.
    
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
       é retornado ?, por isso o tratamento se o valor > 0 */
    
    DO  WHILE NOT resultado:EOF():
    
        /* Saldo inicial */
        IF  INT(resultado:FIELDS("VLDSDINI"):VALUE) > 0  THEN
            aux_vldsdini = DEC(resultado:FIELDS("VLDSDINI"):VALUE).
    
        resultado:MoveNext().
    END.
    
    
   
    /* Saldo final */
    aux_vldsdfin = (glb_qtnotK7A * glb_vlnotK7A) +
                   (glb_qtnotK7B * glb_vlnotK7B) +
                   (glb_qtnotK7C * glb_vlnotK7C) +
                   (glb_qtnotK7D * glb_vlnotK7D).




    /* Saques efetuados no dia, atualizados no servidor */
    comando:ActiveConnection = conexao.
    comando:CommandText = "SELECT VLLANMTO FROM CRAPLTL WHERE DTTRANSA = " + aux_dsmvtolt + " AND " +
                          "TPDTRANS = 1 AND " +
                          "CDSITATU = 1".
    
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
       é retornado ?, por isso o tratamento se o valor > 0 */
    
    DO  WHILE NOT resultado:EOF():
    
        /* Saldo inicial */
        IF  INT(resultado:FIELDS("VLLANMTO"):VALUE) > 0  THEN
            aux_vldmovto = aux_vldmovto + DEC(resultado:FIELDS("VLLANMTO"):VALUE).
    
        resultado:MoveNext().
    END.


    /* fechar e liberar a conexao */
    conexao:CLOSE()          NO-ERROR.
    RELEASE OBJECT conexao   NO-ERROR.
    RELEASE OBJECT comando   NO-ERROR.
    RELEASE OBJECT resultado NO-ERROR.


    RUN procedures/grava_log.p (INPUT "Saldo inicial: R$ " + STRING(aux_vldsdini,"zzz,zz9.99")).
    RUN procedures/grava_log.p (INPUT "Movimentos: R$ "    + STRING(aux_vldmovto,"zzz,zz9.99")).
    RUN procedures/grava_log.p (INPUT "Saldo final: R$ "   + STRING(aux_vldsdfin,"zzz,zz9.99")).

    RETURN "OK".

END PROCEDURE.
/* Fim verifica_saldos */



PROCEDURE grava_saldos:

    DEF VAR aux_dsmvtolt    AS CHAR             NO-UNDO.
    
    DEF VAR conexao         AS COM-HANDLE       NO-UNDO.
    DEF VAR resultado       AS COM-HANDLE       NO-UNDO.
    DEF VAR comando         AS COM-HANDLE       NO-UNDO.
    


    RUN procedures/grava_log.p (INPUT "Gravando saldos finalizados...").

    
    /* Conexao com o Firebird 
       1-Conexao ODBC criada em Ferramentas ADM do Windows
       2-Usuario
       3-Senha */
    CREATE "ADODB.Connection" conexao.
    conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 
    
    IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Erro na conexão com o banco de dados FireBird").
    
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
    CREATE "ADODB.RecordSet" resultado.
    comando:ActiveConnection = conexao.


    /* MM/DD/YYYY */
    aux_dsmvtolt = "'" + SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2) + "/" +
                         SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2) + "/" +
                         SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4) + "'".

    comando:CommandText = "UPDATE CRAPSTF SET VLDMOVTO = " + REPLACE(STRING(aux_vldmovto),",",".") + ", " +
                                             "VLDSDFIN = " + REPLACE(STRING(aux_vldsdfin),",",".") + " "  +
                          "WHERE DTMVTOLT = " + aux_dsmvtolt.
    
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



    RUN procedures/grava_log.p (INPUT "Iniciando nova data...").


    /* MM/DD/YYYY */
    aux_dsmvtolt = "'" + SUBSTRING(STRING(glb_dtmvtocd,"99999999"),3,2) + "/" +
                         SUBSTRING(STRING(glb_dtmvtocd,"99999999"),1,2) + "/" +
                         SUBSTRING(STRING(glb_dtmvtocd,"99999999"),5,4) + "'".

    /* Cria o registro de saldo para a nova data:
       SALDO INICIAL = SALDO FINAL (dia anterior) */
    comando:ActiveConnection = conexao.
    comando:CommandText = "INSERT INTO CRAPSTF ( " +
                                    "DTMVTOLT, "   +
                                    "VLDSDINI) "   +
                          "VALUES ( " + 
                                    aux_dsmvtolt                          + ", " +
                                    REPLACE(STRING(aux_vldsdfin),",",".") + ")".
    
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

    /* fechar e liberar a conexao */
    conexao:CLOSE()          NO-ERROR.
    RELEASE OBJECT conexao   NO-ERROR.
    RELEASE OBJECT comando   NO-ERROR.
    RELEASE OBJECT resultado NO-ERROR.

    RUN procedures/grava_log.p (INPUT "Nova data iniciada").

    RETURN "OK".

END PROCEDURE.
/* Fim grava_saldos */

/* ............................................................................ */
