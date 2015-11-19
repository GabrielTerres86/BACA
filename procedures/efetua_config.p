/* ..............................................................................

Procedure: efetua_config.p 
Objetivo : Efetuar as configurações do TAA do banco FireBird
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

............................................................................... */

DEFINE  INPUT PARAMETER par_cdcoptfn    AS INTEGER                  NO-UNDO.
DEFINE  INPUT PARAMETER par_nrterfin    AS INTEGER                  NO-UNDO.
DEFINE  INPUT PARAMETER par_cdagetfn    AS INTEGER                  NO-UNDO.
DEFINE  INPUT PARAMETER par_ipterfin    AS CHARACTER                NO-UNDO.
DEFINE  INPUT PARAMETER par_nmserver    AS CHARACTER                NO-UNDO.
DEFINE  INPUT PARAMETER par_nmservic    AS CHARACTER                NO-UNDO.
DEFINE  INPUT PARAMETER par_tpleitor    AS INTEGER                  NO-UNDO.
DEFINE  INPUT PARAMETER par_tpenvelo    AS INTEGER                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_TAA.i }

DEFINE VARIABLE aux_dsmvtolt            AS CHAR                     NO-UNDO.
    
DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.


RUN procedures/grava_log.p (INPUT "Iniciando configuração do terminal...").


RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Salvando as configurações.",
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

        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.

CREATE "ADODB.Command" comando.
CREATE "ADODB.RecordSet" resultado.
comando:ActiveConnection = conexao.

/* Apaga os registros do banco local */

RUN procedures/grava_log.p (INPUT "Limpando dados de saldos.").

comando:CommandText = "DELETE FROM CRAPSTF".
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.



RUN procedures/grava_log.p (INPUT "Limpando dados de operações.").

comando:CommandText = "DELETE FROM CRAPLFN".
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.



RUN procedures/grava_log.p (INPUT "Limpando dados de transações.").

comando:CommandText = "DELETE FROM CRAPLTL".
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.



RUN procedures/grava_log.p (INPUT "Limpando dados de configurações/controle.").

comando:CommandText = "DELETE FROM CRAPTFN".
resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.




RUN procedures/grava_log.p (INPUT "Efetuando configuração: "         + " " +
                                  "CDCOPTFN=" + STRING(par_cdcoptfn) + " " +
                                  "NRTERFIN=" + STRING(par_nrterfin) + " " +
                                  "CDAGETFN=" + STRING(par_cdagetfn) + " " +
                                  "IPTERFIN=" + par_ipterfin         + " " +
                                  "NMSERVER=" + par_nmserver         + " " +
                                  "NMSERVIC=" + par_nmservic         + " " +
                                  "TPLEITOR=" + STRING(par_tpleitor) + " " +
                                  "TPENVELO=" + STRING(par_tpenvelo) + " " +
                                  "NRTEMPOR=10000").

comando:CommandText = "INSERT INTO CRAPTFN ( " +
                                "CDCOPTFN, " +
                                "NRTERFIN, " +
                                "CDAGETFN, " +
                                "IPTERFIN, " +
                                "NMSERVER, " +
                                "NMSERVIC, " +
                                "TPLEITOR, " +
                                "TPENVELO, " +
                                "NRTEMPOR) " +
                      "VALUES ( " +
                                STRING(par_cdcoptfn) +  ", " +
                                STRING(par_nrterfin) +  ", " +
                                STRING(par_cdagetfn) +  ", " +
                          "'" + par_ipterfin         + "', " +
                          "'" + par_nmserver         + "', " +
                          "'" + par_nmservic         + "', " +
                                STRING(par_tpleitor) +  ", " +
                                STRING(par_tpenvelo) +  ", " +
                                "10000"              +  ")" .

resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.




RUN procedures/grava_log.p (INPUT "Criando registro de saldo para " + STRING(TODAY,"99/99/9999")).

/* MM/DD/YYYY */
aux_dsmvtolt = "'" + SUBSTRING(STRING(TODAY,"99999999"),3,2) + "/" +
                     SUBSTRING(STRING(TODAY,"99999999"),1,2) + "/" +
                     SUBSTRING(STRING(TODAY,"99999999"),5,4) + "'".
                                           

comando:CommandText = "INSERT INTO CRAPSTF ( " +
                                "DTMVTOLT, " +
                                "VLDSDINI, " +
                                "VLDMOVTO, " +
                                "VLDSDFIN) " +
                      "VALUES ( " +
                                STRING(aux_dsmvtolt) +  ", " +
                                "0, " +
                                "0, " +
                                "0)".

resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        RUN libera_conexao.
        par_flgderro = YES.
        RETURN "NOK".
    END.


RUN libera_conexao.


/* carrega os parametros informados */
RUN procedures/carrega_config.p (OUTPUT par_flgderro).


/* Informa a configuracao ao Servidor */
RUN procedures/grava_log.p (INPUT "Informando configuração ao servidor...").

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
    xText:NODE-VALUE = "17".
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
                RUN procedures/grava_log.p (INPUT "Configuração - Sem comunicação com o servidor.").
                
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
            
            IF  xField:SUBTYPE <> "ELEMENT"   THEN
                NEXT.
    
            xField:GET-CHILD(xText,1).

    
            IF  xField:NAME = "CONFIGURACAO"  AND
                xText:NODE-VALUE = "OK"       THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Configuração - " + xText:NODE-VALUE).

                    RUN mensagem.w (INPUT YES,
                                    INPUT "      ERRO!",
                                    INPUT "",
                                    INPUT xText:NODE-VALUE,
                                    INPUT "",
                                    INPUT "",
                                    INPUT "").

                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
    
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


RUN procedures/grava_log.p (INPUT "Configuração efetuada com sucesso.").

RETURN "OK".





PROCEDURE libera_conexao:
    
    /* fechar e liberar a conexao */
    conexao:CLOSE()          NO-ERROR.
    RELEASE OBJECT conexao   NO-ERROR.
    RELEASE OBJECT comando   NO-ERROR.
    RELEASE OBJECT resultado NO-ERROR.
END PROCEDURE.


/* ........................................................................... */

