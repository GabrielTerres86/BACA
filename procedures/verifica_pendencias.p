/* ..............................................................................

Procedure: verifica_pendencias.p 
Objetivo : Verificar junto ao servidor, transacoes pendentes de fechamento
Autor    : Evandro
Data     : Maio 2010


Ultima alteração: 23/08/2010 - Ajuste na leitura dos registros no FireBird
                               (Evandro).
                               
                  01/09/2010 - Passar a data de transação no estorno de saque
                               para contemplar o fim de semana (Evandro).
                               
                  15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                  
                  27/08/2015 - Detalhamento de log na inicialização do TAA
                               Lucas Lunelli (SD 291639)
                               
............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEFINE  TEMP-TABLE cratltl       NO-UNDO
        FIELD cdcooper  AS INT
        FIELD dtmvtolt  AS DATE
        FIELD nrdconta  AS INT
        FIELD nrsequni  AS INT
        FIELD nrdocmto  AS INT
        FIELD dttransa  AS DATE
        FIELD hrtransa  AS INT
        FIELD tpdtrans  AS INT
        FIELD nrcartao  AS DEC
        FIELD vllanmto  AS DEC
        FIELD cdsitatu  AS INT
        FIELD flgderro  AS LOGICAL.



DEF VAR conexao   AS COM-HANDLE         NO-UNDO.
DEF VAR resultado AS COM-HANDLE         NO-UNDO.
DEF VAR comando   AS COM-HANDLE         NO-UNDO.


RUN procedures/grava_log.p (INPUT "Verificando pendências...").

RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Verificando Pendências.",
                INPUT "",
                INPUT "").

/* garantir que a mensagem apareça mesmo que a operação seja rápida */
PAUSE 1 NO-MESSAGE.


/* Conexao com o Firebird 
   1-Conexao ODBC criada em Ferramentas ADM do Windows
   2-Usuario
   3-Senha */
CREATE "ADODB.Connection" conexao.
conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    DO:
        /* tira a msg de aguarde */
        h_mensagem:HIDDEN = YES.

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
CREATE "ADODB.RecordSet" resultado.
comando:ActiveConnection = conexao.


RUN carrega_transacoes.

IF  RETURN-VALUE = "NOK"  THEN
    DO:

        RUN procedures/grava_log.p (INPUT "Pendências - Erro ao carregar transações.").

        /* tira a msg de aguarde */
        h_mensagem:HIDDEN = YES.
        
        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.
        
        par_flgderro = YES.
        RETURN "NOK".
    END.



FOR EACH cratltl:
     
    /* tratamento para saques nao completados */
    IF  cratltl.tpdtrans = 1  THEN
        DO:
            RUN confere_saque( INPUT cratltl.cdcooper,
                               INPUT cratltl.nrdconta,
                               INPUT cratltl.nrcartao,
                               /* passa a data de transacao para o estorno */
                               INPUT cratltl.dttransa,
                               INPUT cratltl.nrsequni,
                               INPUT cratltl.vllanmto,
                              OUTPUT cratltl.cdsitatu,
                              OUTPUT cratltl.flgderro).
        END.
    ELSE
        /* demais transacoes somente sao marcadas como
           atualizadas, equivalente a desprezar */
        ASSIGN cratltl.cdsitatu = 1
               cratltl.flgderro = NO.
END.



RUN atualiza_transacoes.

                                        
/* tira a msg de aguarde */
h_mensagem:HIDDEN = YES.
    
/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.

/* se houve erro em qualquer registro */
IF  par_flgderro  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Pendências - Erro ao atualizar transações.").
        RETURN "NOK".
    END.
    
RUN procedures/grava_log.p (INPUT "Pendências Resolvidas.").

RETURN "OK".





PROCEDURE carrega_transacoes:
    /* verifica todas as transacoes que estao no banco local e que
       ainda estao pendentes de finalizacao */
    EMPTY TEMP-TABLE cratltl.

    
    comando:CommandText = "SELECT * FROM CRAPLTL WHERE CDSITATU = 0".

    resultado = comando:EXECUTE(,,) NO-ERROR.

    IF  resultado = ?  THEN
        DO:
            par_flgderro = YES.
            RETURN "NOK".
        END.

        
    /* Quando o campo nao estiver alimentado no firebird, para o progress,
       é retornado ?, por isso o tratamento se o valor > 0 */
    
    /* Carrega a temp-table com os registros */
    DO  WHILE NOT resultado:EOF():
    
        
        /* Cooperativa */
        IF  INT(resultado:FIELDS("CDCOOPER"):VALUE) >= 0  THEN
            DO:
                CREATE cratltl.
                ASSIGN cratltl.cdcooper = INT(resultado:FIELDS("CDCOOPER"):VALUE).
            END.

        /* Data de movimento */
        IF  DATE(resultado:FIELDS("DTMVTOLT"):VALUE) <> ?  THEN
            cratltl.dtmvtolt = DATE(resultado:FIELDS("DTMVTOLT"):VALUE).

        /* Conta */
        IF  INT(resultado:FIELDS("NRDCONTA"):VALUE) >= 0  THEN
            cratltl.nrdconta = INT(resultado:FIELDS("NRDCONTA"):VALUE).

        /* NSU */
        IF  INT(resultado:FIELDS("NRSEQUNI"):VALUE) >= 0  THEN
            cratltl.nrsequni = INT(resultado:FIELDS("NRSEQUNI"):VALUE).

        /* Documento */
        IF  INT(resultado:FIELDS("NRDOCMTO"):VALUE) >= 0  THEN
            cratltl.nrdocmto = INT(resultado:FIELDS("NRDOCMTO"):VALUE).

        /* Data da transacao */
        IF  DATE(resultado:FIELDS("DTTRANSA"):VALUE) <> ?  THEN
            cratltl.dttransa = DATE(resultado:FIELDS("DTTRANSA"):VALUE).

        /* Hora da transacao */
        IF  INT(resultado:FIELDS("HRTRANSA"):VALUE) >= 0  THEN
            cratltl.hrtransa = INT(resultado:FIELDS("HRTRANSA"):VALUE).

        /* Tipo */
        IF  INT(resultado:FIELDS("TPDTRANS"):VALUE) >= 0  THEN
            cratltl.tpdtrans = INT(resultado:FIELDS("TPDTRANS"):VALUE).

        /* Cartao */
        IF  DEC(resultado:FIELDS("NRCARTAO"):VALUE) >= 0  THEN
            cratltl.nrcartao = DEC(resultado:FIELDS("NRCARTAO"):VALUE).

        /* Valor */
        IF  DEC(resultado:FIELDS("VLLANMTO"):VALUE) >= 0  THEN
            cratltl.vllanmto = DEC(resultado:FIELDS("VLLANMTO"):VALUE).

        /* Situacao inicia sempre com 0-nao atualizado */
        resultado:MoveNext().
    END.

    RETURN "OK".

END PROCEDURE.
/* Fim carrega_transacoes */


PROCEDURE atualiza_transacoes:
    /* atualiza as transacoes do banco local conforme 
       conferencias do servidor, finalizadas sem erro */

    DEFINE         VARIABLE aux_dstransa    AS CHAR                     NO-UNDO.     
    DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
    DEFINE         VARIABLE aux_dsdsaque    AS CHAR                     NO-UNDO.

    
    FOR EACH cratltl WHERE cratltl.flgderro = NO:

               /* 'MM/DD/YYYY' */
        ASSIGN aux_dstransa = "'" + SUBSTRING(STRING(cratltl.dttransa,"99999999"),3,2) + "/" +
                                    SUBSTRING(STRING(cratltl.dttransa,"99999999"),1,2) + "/" +
                                    SUBSTRING(STRING(cratltl.dttransa,"99999999"),5,4) + "'"
        
               /* 'MM/DD/YYYY' */
               aux_dsmvtolt = "'" + SUBSTRING(STRING(cratltl.dtmvtolt,"99999999"),3,2) + "/" +
                                    SUBSTRING(STRING(cratltl.dtmvtolt,"99999999"),1,2) + "/" +
                                    SUBSTRING(STRING(cratltl.dtmvtolt,"99999999"),5,4) + "'"

               /* valor com separador decimal "." */
               aux_dsdsaque = REPLACE(STRING(cratltl.vllanmto),",",".").
        
        
        comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = " + STRING(cratltl.cdsitatu) + " " +
                               "WHERE CDCOOPER = " + STRING(cratltl.cdcooper)  + " AND " +
                                     "DTMVTOLT = " + aux_dsmvtolt              + " AND " +
                                     "NRDCONTA = " + STRING(cratltl.nrdconta)  + " AND " +
                                     "NRSEQUNI = " + STRING(cratltl.nrsequni)  + " AND " +
                                     "NRDOCMTO = " + STRING(cratltl.hrtransa)  + " AND " +
                                     "DTTRANSA = " + aux_dstransa              + " AND " +
                                     "HRTRANSA = " + STRING(cratltl.hrtransa)  + " AND " +
                                     "TPDTRANS = " + STRING(cratltl.tpdtrans)  + " AND " +
                                     "NRCARTAO = " + STRING(cratltl.nrcartao)  + " AND " +
                                     "VLLANMTO = " + STRING(aux_dsdsaque)      + " AND " +
                                     "CDSITATU = 0".

        resultado = comando:EXECUTE(,,) NO-ERROR.

        IF  resultado = ?  THEN
            DO:
                par_flgderro = YES.
                RETURN "NOK".
            END.
    END.

    RETURN "OK".

END PROCEDURE.
/* Fim atualiza_transacoes */



PROCEDURE confere_saque:

    /* Solicita ao servidor se o saque foi efetuado com sucesso.
       Considerando que se está como pendência é porque houve problemas
       e não foram dispensadas as notas, caso o saque tenha sido
       sucesso, o servidor fará o estorno do mesmo */

    DEFINE  INPUT PARAMETER par_cdcooper    AS INT                  NO-UNDO.
    DEFINE  INPUT PARAMETER par_nrdconta    AS INT                  NO-UNDO.
    DEFINE  INPUT PARAMETER par_nrcartao    AS DEC                  NO-UNDO.
    DEFINE  INPUT PARAMETER par_dtmvtolt    AS DATE                 NO-UNDO.
    DEFINE  INPUT PARAMETER par_nrsequni    AS INT                  NO-UNDO.
    DEFINE  INPUT PARAMETER par_vldsaque    AS DEC                  NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdsitatu    AS INT                  NO-UNDO.
    /* erro individual para cada registro */
    DEFINE OUTPUT PARAMETER reg_flgderro    AS LOGICAL              NO-UNDO.

    DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
    DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
    DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
    DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
    DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.
    
    
    RUN procedures/grava_log.p (INPUT "Conferindo saque Coop:" + STRING(par_cdcooper) + " - " +
                                                        "C/C:" + STRING(par_nrdconta) + " - " +
                                                      "Valor:" + STRING(par_vldsaque) + " - " +
                                                       "Data:" + STRING(par_dtmvtolt) + " - " +
                                                        "NSU:" + STRING(par_nrsequni)).

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
        xText:NODE-VALUE = "22".
        xField:APPEND-CHILD(xText).
        
        /* ---------- */
        xDoc:CREATE-NODE(xField,"CDCOOPER","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(par_cdcooper).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRCARTAO","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(par_nrcartao).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(par_dtmvtolt).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRSEQUNI","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(par_nrsequni).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLDSAQUE","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(par_vldsaque).
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
                    RUN procedures/grava_log.p (INPUT "Pendências - Sem comunicação com o servidor").
    
                    RUN mensagem.w (INPUT YES,
                                    INPUT "      ERRO!",
                                    INPUT "",
                                    INPUT "Sem comunicação com o Servidor",
                                    INPUT "",
                                    INPUT "",
                                    INPUT "").
    
                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
        
                    ASSIGN par_flgderro = YES
                           reg_flgderro = YES.

                    LEAVE.
                END.
        
            DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
                
                xRoot:GET-CHILD(xField,aux_contador).
                
                IF  xField:SUBTYPE <> "ELEMENT"  THEN
                    NEXT.
        
                xField:GET-CHILD(xText,1).
        
                IF  xField:NAME = "ESTORNO"  AND
                    xText:NODE-VALUE = "OK"  THEN
                    ASSIGN par_cdsitatu = 3 /* Saque estornado */
                           reg_flgderro = NO.
                ELSE
                    ASSIGN par_flgderro = YES
                           reg_flgderro = YES.

            END. /* Fim DO..TO.. */
    
    
            LEAVE.
        END. /* Fim WHILE */
            
        DELETE OBJECT xDoc.
        DELETE OBJECT xRoot.
        DELETE OBJECT xField.
        DELETE OBJECT xText.
    
    END. /* Fim RESPOSTA */
    
    IF  reg_flgderro  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Saque com problemas").
            RETURN "NOK".
        END.

    IF  par_cdsitatu = 3  THEN
        RUN procedures/grava_log.p (INPUT "Saque OK - ESTORNADO").
    ELSE
        RUN procedures/grava_log.p (INPUT "Saque OK").

    RETURN "OK".

END PROCEDURE.
/* Fim confere_saque */

/* ............................................................................ */
