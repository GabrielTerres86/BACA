/* ..............................................................................

Procedure: entrega_envelope.p 
Objetivo : Rotina de Entrega de Envelope
Autor    : Evandro
Data     : Fevereiro 2010

Ultima alteração: 05/06/2010 - Correcao de ortografia da mensagem de
                               confirmacao do envelope (Evandro).
                               
                  20/08/2010 - Alimentar NSU para envelope de pagamento de
                               contas (Evandro).
                               
                  15/10/2010 - Ajustes para TAA compartilhado (Evandro).                               
                  
                  02/07/2014 - Alterado para permitir o deposito intercooperativas.
                               (Reinert)
                               
                  27/10/2014 - Alterado para chamar a procedure 
                               obtem_sequencial_deposito ao inves da obtem_nsu. 
                               (Reinert)

                  14/11/2014 - Alterado para atualizar campo hrtransa com o nr.
                               sequencial do envelope. (Reinert)
                               
                  18/02/2015 - Alteração para identificação de envelopes de dinheiro
                               ou cheque (Lunelli - SD 229246).
                  
                  24/09/2015 - Alterado termo 'impressão' para 'visualização'
                               (Lucas Lunelli - Melhoria 83 [SD 279180])
                               
                  22/02/2016 - Adicionado informacoes adicionais no log. 
                               (Jorge/Thiago) - SD 399030
............................................................................... */


DEFINE  INPUT PARAM par_tpdtrans    AS INT                      NO-UNDO.
DEFINE  INPUT PARAM par_nrctafav    AS INT                      NO-UNDO.
DEFINE  INPUT PARAM par_vldinhei    AS DECIMAL                  NO-UNDO.
DEFINE  INPUT PARAM par_vlcheque    AS DECIMAL                  NO-UNDO.
DEFINE  INPUT PARAM par_agctltfn    AS INTEGER                  NO-UNDO.
DEFINE OUTPUT PARAM par_nrdocmto    AS INTEGER                  NO-UNDO.
DEFINE OUTPUT PARAM par_dsprotoc    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEFINE VARIABLE aux_nrseqenl        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_nrsequni        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_dsdeposi        AS CHAR                     NO-UNDO.     
DEFINE VARIABLE aux_dsdtoday        AS CHAR                     NO-UNDO.     
DEFINE VARIABLE aux_dsmvtolt        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_cdcopdst        AS INT                      NO-UNDO.

DEFINE VARIABLE cnt_detalhe         AS INT                      NO-UNDO.
DEFINE VARIABLE aux_tpdeposi        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_dsdlinha        AS CHAR                     NO-UNDO.
DEFINE VARIABLE LT_Resp             AS INT                      NO-UNDO.

par_nrdocmto = TIME.

/* para o comprovante do deposito antigo */
IF  par_vldinhei = 0  AND
    par_vlcheque = 0  THEN
    ASSIGN aux_dsdlinha = STRING(TODAY,"99/99/9999")      + " " + 
                          STRING(par_nrdocmto,"HH:MM:SS") + " " +  
                          STRING(glb_cdagetfn,"999")      + "/" +
                          STRING(glb_nrterfin,"9999")     + " " +
                          STRING(par_nrdocmto,"99999")
           aux_nrseqenl = par_nrdocmto. 
ELSE
    DO:
        /* Pega nsu da coop. de destino e sequencial unico geral */
        RUN procedures/obtem_sequencial_deposito.p (INPUT par_agctltfn,
                                                    OUTPUT aux_nrsequni, /* Sequencial único coop. de destino */
                                                    OUTPUT aux_nrseqenl, /*Sequencial unico geral*/
                                                    OUTPUT aux_cdcopdst, /* Coop. de destino */ 
                                                    OUTPUT par_flgderro).
        
        IF  par_flgderro  THEN
            RETURN "NOK".

        aux_dsdlinha = STRING(DAY(TODAY),"99")         +
                       STRING(MONTH(TODAY),"99")       + " " +
                       STRING(aux_nrseqenl,"99999999") + " " + /* Sequencial unico geral */ 
                       STRING(glb_nrterfin,"9999")     + " " +
                       STRING(par_nrdocmto,"99999")    + 
                       STRING(par_nrdocmto,"HH:MM").

        IF  par_vldinhei > 0  THEN
            ASSIGN aux_tpdeposi = 0
                   aux_dsdlinha = aux_dsdlinha                    + " " + 
                           TRIM(STRING(par_vldinhei,"zzzz9.99")) + "D".
        ELSE
            ASSIGN aux_tpdeposi = 1
                   aux_dsdlinha = aux_dsdlinha                    + " " + 
                           TRIM(STRING(par_vlcheque,"zzzz9.99")) + "C".
       
    END.


/* Depositário InterBold */
IF  glb_tpenvelo = 1  THEN
    DO:
        DEFINE VARIABLE Imprime    AS MEMPTR   NO-UNDO.
        DEFINE VARIABLE TimeOut    AS MEMPTR   NO-UNDO.
        DEFINE VARIABLE ErroDep    AS MEMPTR   NO-UNDO.

        SET-SIZE(Imprime) = LENGTH(aux_dsdlinha) + 3.
        SET-SIZE(TimeOut) = 1.
        SET-SIZE(ErroDep) = 1.

        PUT-STRING(Imprime,1) = aux_dsdlinha + CHR(0).
        PUT-BYTE(TimeOut,1) = 30.
        PUT-BYTE(ErroDep,1) = 0.

        ASSIGN LT_Resp = 0.

        RUN WinDepositaDepIbold IN aux_xfsliteh 
            (INPUT  GET-POINTER-VALUE(Imprime),
             INPUT  20,
             INPUT  GET-POINTER-VALUE(ErroDep),
             OUTPUT LT_Resp).

        ASSIGN cnt_detalhe = GET-BYTE(ErroDep,1).

        SET-SIZE(Imprime) = 0.
        SET-SIZE(TimeOut) = 0.
        SET-SIZE(ErroDep) = 0.
    END.
ELSE
/* Depositário Pentasys */
IF  glb_tpenvelo = 2  THEN
    DO:
        ASSIGN LT_Resp     = 0
               cnt_detalhe = 0.
   
        RUN WinDeposita IN aux_xfsliteh (INPUT aux_dsdlinha + CHR(0), 
                                         OUTPUT LT_Resp, 
                                         OUTPUT cnt_detalhe).
    END.

IF  LT_resp <> 0   THEN
    DO:
        IF  LT_resp = 16   THEN
            RUN procedures/grava_log.p (INPUT "Envelope - Tempo esgotado.").

        par_flgderro = YES.
    END.
    

IF  par_flgderro  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro no recebimento do envelope. "    +
                                          "RETORNO:" + STRING(LT_Resp) + " - "   +
                                          "DETALHE:" + STRING(cnt_detalhe) + " " + 
                                          "P32CONTA.DLL (" + (IF glb_tpenvelo = 1 THEN "WinDepositaDepIbold" ELSE "WinDeposita") + ").").

        RUN mensagem.w (INPUT YES,
                        INPUT "      ERRO!",
                        INPUT "",
                        INPUT "",
                        INPUT "Problemas no recebimento",
                        INPUT "do envelope.",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        RETURN "NOK".
    END.



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



/* valor com separador decimal "." */
ASSIGN aux_dsdeposi = STRING(par_vldinhei + par_vlcheque)
       aux_dsdeposi = REPLACE(aux_dsdeposi,",",".").

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
                              STRING(aux_cdcopdst)  + ", " +  /* Coop. Destino */ 
                              aux_dsmvtolt          + ", " +
                              STRING(par_nrctafav)  + ", " +  /* Conta Destino */
                              STRING(aux_nrsequni)  + ", " +
                              STRING(par_nrdocmto)  + ", " +
                              aux_dsdtoday          + ", " +
                              STRING(aux_nrseqenl)  + ", " + /* Utilizaremos o nr. de sequencial de depositos para este campo, a hora de transacao pode ser obtida no nrdocmto */
                              STRING(par_tpdtrans)  + ", " +
                              STRING(aux_tpdeposi)  + ", " + /* Uso do NRCARTAO: 0 - Dinheiro / 1 - Cheque */
                              aux_dsdeposi          + ", " +
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





/* Atualiza o deposito no Servidor */
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
    xDoc:CREATE-NODE(xField,"CDCOPTFN","ELEMENT").  /* Cooperativa acolhedora */
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
    xText:NODE-VALUE = "14".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDCOOPER","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_cdcopdst). /*Cooperativa de destino*/ 
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQENV","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrsequni).  /* NSU da coop. destino */
    xField:APPEND-CHILD(xText).   

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQENL","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrseqenl).  /* Sequence unico geral */
    xField:APPEND-CHILD(xText).   

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRDOCMTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_nrdocmto).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRCTAFAV","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_nrctafav).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLDININF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_vldinhei).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLCHQINF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_vlcheque).
    xField:APPEND-CHILD(xText).

    /* ---------- */

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
                RUN procedures/grava_log.p (INPUT "Envelope - Sem comunicação com o servidor").
                
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

    
            IF  xField:NAME = "ENVELOPE"  AND
                xText:NODE-VALUE = "OK"   THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "PROTOCOLO"  THEN
                par_dsprotoc = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Envelope - " + xText:NODE-VALUE).

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



/* Se atualizou no Servidor, atualiza como OK no FireBird */
RUN procedures/grava_log.p (INPUT "Confirmando envelope no terminal...").

comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                             "WHERE CDCOOPER = " + STRING(aux_cdcopdst) + " AND " +
                                   "DTMVTOLT = " + aux_dsmvtolt         + " AND " +
                                   "NRDCONTA = " + STRING(par_nrctafav) + " AND " +
                                   "NRSEQUNI = " + STRING(aux_nrsequni) + " AND " +
                                   "NRDOCMTO = " + STRING(par_nrdocmto) + " AND " +
                                   "DTTRANSA = " + aux_dsdtoday         + " AND " +
                                   "HRTRANSA = " + STRING(aux_nrseqenl) + " AND " +
                                   "TPDTRANS = " + STRING(par_tpdtrans) + " AND " +
                                   "NRCARTAO = " + STRING(aux_tpdeposi) + " AND " + /* Uso do NRCARTAO: 0 - Dinheiro / 1 - Cheque */
                                   "VLLANMTO = " + aux_dsdeposi         + " AND " +
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



glb_qtenvelo = glb_qtenvelo + 1.

RUN mensagem.w (INPUT NO,
                INPUT "    ATENÇÃO",
                INPUT "",
                INPUT "",
                INPUT "Aguarde a visualização",
                INPUT "do comprovante.",
                INPUT "").

PAUSE 3 NO-MESSAGE.
h_mensagem:HIDDEN = YES.



comando:CommandText = "UPDATE CRAPTFN SET QTENVELO = " + STRING(glb_qtenvelo).

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


RUN procedures/grava_log.p (INPUT "Envelope recebido com sucesso.").

RETURN "OK".


/* ........................................................................... */

