/* ..............................................................................

 Procedure: verifica_opcao_recarga.p
 Objetivo : Verificar se a situa��o de recarga no celular est� ativa
 Autor    : Lucas Reinert
 Data     : Fevereiro 2017

Ultima altera��o: 

............................................................................... */
DEFINE OUTPUT PARAMETER par_flgsitrc    AS INTEGER  INIT 0      NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i } 


DEFINE         VARIABLE aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                      NO-UNDO.


DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.


/* grava no log local - FireBird */
DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.


RUN procedures/grava_log.p (INPUT "Verifica situacao de recarga de celular...").


aux_hrtransa = TIME.


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

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        par_flgderro = YES.
        RETURN "NOK".
    END.


CREATE "ADODB.Command" comando.
CREATE "ADODB.RecordSet" resultado.
comando:ActiveConnection = conexao.


       /* 'MM/DD/YYYY' */
ASSIGN aux_dsdtoday = "'" + SUBSTRING(STRING(TODAY,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),5,4) + "'"

       /* 'MM/DD/YYYY' */
       aux_dsmvtolt = "'" + SUBSTRING(STRING(glb_dtmvtolt,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),5,4) + "'".


comando:CommandText = "INSERT INTO CRAPLTL ( " +
                              "CDCOOPER, " +
                              "DTMVTOLT, " +
                              "NRDCONTA, " +
                              "NRSEQUNI, " +
                              "NRDOCMTO, " +
                              "DTTRANSA, " +
                              "HRTRANSA, " +
                              "TPDTRANS, " +
                              "NRCARTAO, " +
                              "VLLANMTO, " +
                              "CDSITATU) " +
                    "VALUES ( " +
                              STRING(glb_cdcooper)  + ", " +
                              aux_dsmvtolt          + ", " +
                              STRING(glb_nrdconta)  + ", " +
                              STRING(aux_hrtransa)  + ", " +
                              STRING(aux_hrtransa)  + ", " +
                              aux_dsdtoday          + ", " +
                              STRING(aux_hrtransa)  + ", " +
                              "68"                  + ", " + 
                              STRING(glb_nrcartao)  + ", " +
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
        h_mensagem:HIDDEN = YES.
        RETURN "NOK".
    END.


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
    xText:NODE-VALUE = "68".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDCOOPER","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_cdcooper).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRCARTAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_nrcartao).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"TPUSUCAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_tpusucar).
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
    DEFINE VARIABLE aux_contador  AS INTEGER                          NO-UNDO.
    
    CREATE X-DOCUMENT xDoc.
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xField.
    CREATE X-NODEREF  xText.

    DO  WHILE TRUE:
            
        xDoc:LOAD("FILE","http://" + glb_nmserver + ".cecred.coop.br/" +
                         "cgi-bin/cgiip.exe/WService=" + glb_nmservic + "/" + 
                         "TAA_autorizador.p?xml=" + xml_req,FALSE) NO-ERROR.
            
        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
        IF xDoc:NUM-CHILDREN = 0 OR xRoot:NAME <> "TAA" THEN
           DO:
               LEAVE.
           END.
    
        DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xField,aux_contador).
            
            IF  xField:SUBTYPE <> "ELEMENT"  THEN
                NEXT.
    
            xField:GET-CHILD(xText,1).

            IF  xField:NAME = "FLGSITRC"  THEN
                DO:
                    ASSIGN par_flgsitrc = INTE(xText:NODE-VALUE).
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


/* atualiza o log local */
comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                            "WHERE CDCOOPER = " + STRING(glb_cdcooper)  + " AND " +
                                  "DTMVTOLT = " + aux_dsmvtolt          + " AND " +
                                  "NRDCONTA = " + STRING(glb_nrdconta)  + " AND " +
                                  "NRSEQUNI = " + STRING(aux_hrtransa)  + " AND " +
                                  "NRDOCMTO = " + STRING(aux_hrtransa)  + " AND " +
                                  "DTTRANSA = " + aux_dsdtoday          + " AND " +
                                  "HRTRANSA = " + STRING(aux_hrtransa)  + " AND " +
                                  "TPDTRANS = 68 "                      + " AND " +
                                  "NRCARTAO = " + STRING(glb_nrcartao)  + " AND " +
                                  "VLLANMTO = 0 "                       + " AND " +
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



RUN procedures/grava_log.p (INPUT "Verificado situacao de recarga com sucesso.").

RETURN "OK".

/* ............................................................................ */
