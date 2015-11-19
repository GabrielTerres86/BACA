/* ..............................................................................

Procedure: efetua_abertura.p 
Objetivo : Efetuar abertura do TAA
Autor    : Evandro
Data     : Fevereiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }


DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.

DEFINE VARIABLE aux_dsdtoday            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_dsmvtolt            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_hrtransa            AS INT                      NO-UNDO.

DEFINE VARIABLE tmp_tximpres            AS CHARACTER                NO-UNDO.

DEFINE VARIABLE buff                    AS CHAR        EXTENT 6     NO-UNDO.


RUN procedures/grava_log.p (INPUT "Efetuando abertura do terminal...").


       /* 'MM/DD/YYYY' */
ASSIGN aux_dsdtoday = "'" + SUBSTRING(STRING(TODAY,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),5,4) + "'"

       /* 'MM/DD/YYYY' */
       aux_dsmvtolt = "'" + SUBSTRING(STRING(glb_dtmvtolt,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),5,4) + "'".

IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
                          
        ASSIGN buff[2] = "             AGUARDE..."
               buff[4] = "      EFETUANDO ABERTURA DO TAA".
        RUN procedures/atualiza_painop.p (INPUT buff).

        PAUSE 2 NO-MESSAGE.
    END.
ELSE
    DO:
        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "",
                        INPUT "Efetuando abertura do TAA.",
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
        
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            END.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.

aux_hrtransa = TIME.

CREATE "ADODB.Command" comando.
CREATE "ADODB.RecordSet" resultado.

comando:ActiveConnection = conexao.
comando:CommandText = "INSERT INTO CRAPLFN ( " +
                                "DTTRANSA, " +
                                "HRTRANSA, " +
                                "CDOPERAD, " +
                                "DTMVTOLT, " +
                                "TPDTRANS, " +
                                "VLTRANSA, " +
                                "CDSITATU) " +
                      "VALUES ( " +
                                aux_dsdtoday          + ", " +
                                STRING(aux_hrtransa)  + ", " +
                                STRING(glb_nrdconta)  + ", " +
                                aux_dsmvtolt          + ", " +
                                "1"                   + ", " +
                                "0"                   + ", " +
                                "0)".

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



    
/* Atualiza a abertura no Servidor */
RUN procedures/grava_log.p (INPUT "Efetuando atualização do servidor...").

DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.

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
    xText:NODE-VALUE = "9".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDOPERAD","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_nrdconta).
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
    
        IF  xDoc:NUM-CHILDREN = 0  OR
            xRoot:NAME <> "TAA"    THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Abertura - Sem comunicação com o servidor.").

                IF  xfs_painop_em_uso  THEN
                    DO:
                        buff = "".
                        RUN procedures/atualiza_painop.p (INPUT buff).

                        buff[4] = "    SEM COMUNICACAO COM O SERVIDOR".
                        RUN procedures/atualiza_painop.p (INPUT buff).

                        PAUSE 2 NO-MESSAGE.
                    END.
                ELSE
                    DO:
                        RUN mensagem.w (INPUT YES,
                                        INPUT "      ERRO!",
                                        INPUT "",
                                        INPUT "Sem comunicação com o Servidor",
                                        INPUT "",
                                        INPUT "",
                                        INPUT "").
                        
                        PAUSE 3 NO-MESSAGE.
                        h_mensagem:HIDDEN = YES.
                    END.

                par_flgderro = YES.
                LEAVE.
            END.
    
    
        DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xField,aux_contador).
            
            IF  xField:SUBTYPE <> "ELEMENT"   THEN
                NEXT.
    
            xField:GET-CHILD(xText,1).

    
            IF  xField:NAME = "ABERTURA"  AND
                xText:NODE-VALUE = "OK"   THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Abertura - " + xText:NODE-VALUE).

                    IF  xfs_painop_em_uso  THEN
                        DO:
                            buff = "".
                            RUN procedures/atualiza_painop.p (INPUT buff).

                            ASSIGN buff[2] = "          ABERTURA CRITICADA"
                                   buff[4] = "   VERIFIQUE LOG PARA MAIS DETALHES".

                            RUN procedures/atualiza_painop.p (INPUT buff).
                            
                            PAUSE 2 NO-MESSAGE.
                        END.
                    ELSE
                        DO:
                            RUN mensagem.w (INPUT YES,
                                            INPUT "      ERRO!",
                                            INPUT "",
                                            INPUT xText:NODE-VALUE,
                                            INPUT "",
                                            INPUT "",
                                            INPUT "").
                            
                            PAUSE 3 NO-MESSAGE.
                            h_mensagem:HIDDEN = YES.
                        END.

                    par_flgderro = YES.
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


/* Se atualizou no Servidor, atualiza como OK no FireBird */
RUN procedures/grava_log.p (INPUT "Confimando abertura no terminal...").

comando:CommandText = "UPDATE CRAPLFN SET CDSITATU = 1 " +
                             "WHERE DTTRANSA = " + aux_dsdtoday         + " AND " +
                                   "HRTRANSA = " + STRING(aux_hrtransa) + " AND " +
                                   "CDOPERAD = " + STRING(glb_nrdconta) + " AND " +
                                   "DTMVTOLT = " + aux_dsmvtolt         + " AND " +
                                   "TPDTRANS = 1 AND " +
                                   "VLTRANSA = 0 AND " +
                                   "CDSITATU = 0".

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


RUN procedures/grava_log.p (INPUT "Terminal aberto com sucesso.").

/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.

RETURN "OK".

/* ........................................................................... */

