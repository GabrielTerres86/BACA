/* ............................................................................

Procedure: obtem_parcelas_pre_aprovado.p
Objetivo : Obtem as parcelas do pre-aprovado
Autor    : James Prust Junior
Data     : Setembro/2014

Ultima alteração:   

............................................................................ */

DEFINE TEMP-TABLE tt-parcelas-cpa NO-UNDO
    FIELD nrparepr AS INTE
    FIELD vlparepr AS DECI
    FIELD dtvencto AS DATE
    FIELD flgdispo AS LOG.

EMPTY TEMP-TABLE tt-parcelas-cpa.

DEFINE INPUT  PARAMETER par_vlemprst AS DECI                         NO-UNDO.
DEFINE INPUT  PARAMETER par_diapagto AS INTE                         NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro AS LOGICAL.
DEFINE OUTPUT PARAMETER TABLE FOR tt-parcelas-cpa.

{ includes/var_taa.i }


DEFINE         VARIABLE aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                      NO-UNDO.
  

DEFINE         VARIABLE xml_req         AS CHAR                     NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE                   NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE                   NO-UNDO. 
DEFINE         VARIABLE xRoot2          AS HANDLE                   NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE                   NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE                   NO-UNDO.


/* grava no log local - FireBird */
DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.


RUN procedures/grava_log.p (INPUT "Carregando as parcelas do pre-aprovado...").


aux_hrtransa = TIME.
                     


/* processo que pode demorar bastante devido aos produtos que o
   associado possui */
RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Carregando as parcelas...",
                INPUT "",
                INPUT "").

/* para garantir a mensagem mesmo que a operacao seja rapida */
PAUSE 1 NO-MESSAGE.

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
                              "25"                  + ", " + 
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
    xText:NODE-VALUE = "47".    
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

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_dtmvtolt).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLEMPRST","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_vlemprst).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DIAPAGTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_diapagto).
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
    DEFINE VARIABLE  aux_contador AS INTEGER     NO-UNDO.
    DEFINE VARIABLE  aux_contparc AS INTEGER     NO-UNDO.
    
    CREATE X-DOCUMENT xDoc.
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xRoot2.
    CREATE X-NODEREF  xField.
    CREATE X-NODEREF  xText.

    DO  WHILE TRUE:

        xDoc:LOAD("FILE","http://" + glb_nmserver + ".cecred.coop.br/" +
                         "cgi-bin/cgiip.exe/WService=" + glb_nmservic + "/" + 
                         "TAA_autorizador.p?xml=" + xml_req,FALSE) NO-ERROR.

        /* limpa a mensagem de aguarde.. */
        h_mensagem:HIDDEN = YES.

        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
        IF  xDoc:NUM-CHILDREN = 0 OR xRoot:NAME <> "TAA" THEN
            DO:
                RUN procedures/grava_log.p 
                    (INPUT "Pre-Aprovado - Sem comunicação com o servidor.").

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

            IF  xField:NAME = "DSCRITIC" THEN
                DO:
                    RUN procedures/grava_log.p 
                        (INPUT "Pré-Aprovado - " + xText:NODE-VALUE).
                            
                    RUN mensagem.w (INPUT NO,
                                    INPUT "    ATENÇÃO  ",
                                    INPUT "",
                                    INPUT xText:NODE-VALUE,
                                    INPUT "",
                                    INPUT "",
                                    INPUT "").
        
                    PAUSE 5 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
        
                    ASSIGN par_flgderro = YES.
                END.
            ELSE
                DO:
                    xRoot:GET-CHILD(xRoot2,aux_contador).
                    
                    IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN
                        NEXT.
        
                    CREATE tt-parcelas-cpa.

                    DO  aux_contparc = 1 TO xRoot2:NUM-CHILDREN:
                
                        xRoot2:GET-CHILD(xField,aux_contparc).
                
                         IF  xField:SUBTYPE <> "ELEMENT"  THEN
                             NEXT.
                
                         xField:GET-CHILD(xText,1).
                
                         IF   xField:NAME = "NRPAREPR"   THEN
                              ASSIGN tt-parcelas-cpa.nrparepr = INTE(xText:NODE-VALUE).
                         ELSE
                         IF   xField:NAME = "VLPAREPR"   THEN
                              ASSIGN tt-parcelas-cpa.vlparepr = DECI(xText:NODE-VALUE).
                         ELSE
                         IF   xField:NAME = "DTVENCTO"   THEN
                              ASSIGN tt-parcelas-cpa.dtvencto = DATE(xText:NODE-VALUE).
                         ELSE
                         IF   xField:NAME = "FLGDISPO"   THEN
                              ASSIGN tt-parcelas-cpa.flgdispo = LOGICAL(xText:NODE-VALUE).
                         par_flgderro = NO.
                
                    END. /* Fim DO..TO.. */
                    
                END.

        END. /* Fim DO..TO.. */
        
        LEAVE.

    END. /* Fim WHILE */

    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xRoot2.
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
                                  "TPDTRANS = 25 "                      + " AND " +
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



RUN procedures/grava_log.p 
    (INPUT "Carregado as parcelas do pre-aprovado com sucesso.").



RETURN "OK".

/* ......................................................................... */

