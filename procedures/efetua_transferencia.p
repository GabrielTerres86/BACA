/* ..............................................................................

Procedure: efetua_transferencia.p 
Objetivo : Efetuar a transferencia de valores entre contas
Autor    : Evandro
Data     : Abril 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  04/04/2011 - Ajustes devido o agendamento do TAA (Henrique).
                  
                  08/08/2011 - Incluir o protocolo do TAA (Gabriel).
                  
                  16/05/2013 - Transferencia interCooperativa (Gabriel).

                  24/12/2015 - Adicionado tratamento para contas com assinatura 
                               conjunta. (Reinert)

............................................................................... */

DEFINE  INPUT PARAMETER par_cdagetra   AS INTEGER                  NO-UNDO.
DEFINE  INPUT PARAMETER par_nrtransf    AS INTEGER                  NO-UNDO.
DEFINE  INPUT PARAMETER par_vltransf    AS DECIMAL                  NO-UNDO.
DEFINE  INPUT PARAMETER par_dttransf    AS DATE                     NO-UNDO.
DEFINE  INPUT PARAMETER par_tpoperac    AS INTE                     NO-UNDO.
DEFINE  INPUT PARAMETER par_flagenda    AS LOGICAL                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.
DEFINE OUTPUT PARAMETER par_dsprotoc    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_idastcjt    AS INT                      NO-UNDO.

{ includes/var_taa.i }
  

DEFINE         VARIABLE aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_dstransf    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                      NO-UNDO.
DEFINE         VARIABLE aux_nrsequni    AS INT                      NO-UNDO.


/* verifica se a transferencia pode ser realizada */
RUN procedures/verifica_transferencia.p ( INPUT par_cdagetra,
                                          INPUT par_nrtransf,
                                          INPUT par_vltransf,
                                          INPUT par_dttransf,
                                          INPUT par_tpoperac,
                                          INPUT par_flagenda,
                                          OUTPUT par_flgderro).

IF  par_flgderro  THEN
    RETURN "NOK".


IF  par_flagenda THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Efetuando agendamento da transferência...").

        RUN mensagem.w (INPUT NO,
                        INPUT "    ATENÇÃO",
                        INPUT "",
                        INPUT "",
                        INPUT "Efetuando Agendamento",
                        INPUT "de Transfêrencia",
                        INPUT "").
    END.
ELSE
    DO:
        RUN procedures/grava_log.p (INPUT "Efetuando transferência...").

        RUN mensagem.w (INPUT NO,
                        INPUT "    ATENÇÃO",
                        INPUT "",
                        INPUT "",
                        INPUT "Efetuando Transfêrencia",
                        INPUT "",
                        INPUT "").
    END.

ASSIGN aux_hrtransa = TIME
       
       /* valor com separador decimal "." */
       aux_dstransf = REPLACE(STRING(par_vltransf),",",".").

RUN procedures/obtem_nsu.p (OUTPUT aux_nrsequni,
                            OUTPUT par_flgderro).

IF  par_flgderro  THEN
    RETURN "NOK".


/* grava no log local - FireBird */
DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.


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

IF par_flagenda THEN
    DO:
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
                                  STRING(aux_nrsequni)  + ", " +
                                  STRING(aux_hrtransa)  + ", " +
                                  aux_dsdtoday          + ", " +
                                  STRING(aux_hrtransa)  + ", " +
                                  "13"                  + ", " +
                                  STRING(glb_nrcartao)  + ", " +
                                  STRING(aux_dstransf)  + ", " +
                                  "0)".
    END.
ELSE
    DO:
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
                                      STRING(aux_nrsequni)  + ", " +
                                      STRING(aux_hrtransa)  + ", " +
                                      aux_dsdtoday          + ", " +
                                      STRING(aux_hrtransa)  + ", " +
                                      "5"                   + ", " +
                                      STRING(glb_nrcartao)  + ", " +
                                      STRING(aux_dstransf)  + ", " +
                                      "0)".                         
    END.


resultado = comando:EXECUTE(,,) NO-ERROR.

IF  resultado = ?  THEN
    DO: 
        h_mensagem:HIDDEN = YES.

        RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
        
        /* fechar e liberar a conexao */
        conexao:CLOSE()          NO-ERROR.
        RELEASE OBJECT conexao   NO-ERROR.
        RELEASE OBJECT comando   NO-ERROR.
        RELEASE OBJECT resultado NO-ERROR.

        par_flgderro = YES.
        RETURN "NOK".
    END.


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
    xText:NODE-VALUE = "19".
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
    xDoc:CREATE-NODE(xField,"CDAGETRA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_cdagetra).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRTRANSF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_nrtransf).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLTRANSF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_vltransf).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQUNI","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrsequni).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTTRANSF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dttransf).
    xField:APPEND-CHILD(xText).

     /* ---------- */
    xDoc:CREATE-NODE(xField,"TPOPERAC","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_tpoperac).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"FLAGENDA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_flagenda).
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

        h_mensagem:HIDDEN = YES.
                           
        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
        IF  xDoc:NUM-CHILDREN = 0  OR
            xRoot:NAME <> "TAA"    THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Transferencia - Sem comunicação com o servidor.").
                
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


            IF  xField:NAME = "TRANSFERENCIA"  AND
                xText:NODE-VALUE = "OK"        THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "PROTOCOLO"     THEN
                par_dsprotoc = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "IDASTCJT"     THEN
                par_idastcjt = INT(xText:NODE-VALUE).
            ELSE    
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Transferencia - " + xText:NODE-VALUE).

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


/* atualiza o log local */
IF  par_flagenda THEN
    DO:
        comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                               "WHERE CDCOOPER = " + STRING(glb_cdcooper)  + " AND " +
                                     "DTMVTOLT = " + aux_dsmvtolt          + " AND " +
                                     "NRDCONTA = " + STRING(glb_nrdconta)  + " AND " +
                                     "NRSEQUNI = " + STRING(aux_nrsequni)  + " AND " +
                                     "NRDOCMTO = " + STRING(aux_hrtransa)  + " AND " +
                                     "DTTRANSA = " + aux_dsdtoday          + " AND " +
                                     "HRTRANSA = " + STRING(aux_hrtransa)  + " AND " +
                                     "TPDTRANS = 13"                        + " AND " +
                                     "NRCARTAO = " + STRING(glb_nrcartao)  + " AND " +
                                     "VLLANMTO = " + STRING(aux_dstransf)  + " AND " +
                                     "CDSITATU = 0".
END.
ELSE
    DO:
        comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                       "WHERE CDCOOPER = " + STRING(glb_cdcooper)  + " AND " +
                             "DTMVTOLT = " + aux_dsmvtolt          + " AND " +
                             "NRDCONTA = " + STRING(glb_nrdconta)  + " AND " +
                             "NRSEQUNI = " + STRING(aux_nrsequni)  + " AND " +
                             "NRDOCMTO = " + STRING(aux_hrtransa)  + " AND " +
                             "DTTRANSA = " + aux_dsdtoday          + " AND " +
                             "HRTRANSA = " + STRING(aux_hrtransa)  + " AND " +
                             "TPDTRANS = 5"                        + " AND " +
                             "NRCARTAO = " + STRING(glb_nrcartao)  + " AND " +
                             "VLLANMTO = " + STRING(aux_dstransf)  + " AND " +
                             "CDSITATU = 0".
    END.

        
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


IF par_idastcjt = 0 THEN
  DO:
    IF par_flagenda THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Agendamento de Transferência efetuada com sucesso.").
            
            RUN mensagem.w (INPUT NO,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Agendamento de Transfêrencia",
                            INPUT "Efetuado com sucesso.",
                            INPUT "",
                            INPUT "").
        END.
    ELSE
        DO:   
            RUN procedures/grava_log.p (INPUT "Transferência efetuada com sucesso.").
            
            RUN mensagem.w (INPUT NO,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Transfêrencia",
                            INPUT "Efetuada com sucesso.",
                            INPUT "",
                            INPUT "").
        END.
  END.
ELSE
  DO:
      RUN procedures/grava_log.p (INPUT "Transferencia registrada com sucesso. Aguardando aprovaçao dos demais responsáveis..").
      
      RUN mensagem.w (INPUT NO,
                      INPUT "    ATENÇÃO",
                      INPUT "",
                      INPUT "Transfêrencia",
                      INPUT "Efetuado com sucesso.",
                      INPUT "",
                      INPUT "").
  
  END.
PAUSE 3 NO-MESSAGE.
h_mensagem:HIDDEN = YES.


RETURN "OK".

/* ............................................................................ */
