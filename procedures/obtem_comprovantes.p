/* ............................................................................

Procedure: obtem_comprovantes.p 
Objetivo : Obter os comprovantes do associado
Autor    : Gabriel
Data     : Agosto 2011


Ultima alteração:   09/03/2012 - Adicionado os campos cdbcoctl e cdagectl
                                 na temp-table tt-lista_comprovantes. (Fabricio)

                    03/03/2017 - Adicionado os campos nrtelefo, nmopetel,
                                 dsnsuope na temp-table tt-comprovantes para
                                 o projeto 321 - Recarga de celular. (Reinert)

                    21/06/2017 - Ajusts NPC.
                                 PRJ340 - NPC (Odirlei-AMcom)
............................................................................ */

DEFINE TEMP-TABLE tt-lista_comprovantes NO-UNDO
       FIELD dtmvtolt AS DATE  /* Data do comprovantes       */
       FIELD dscedent AS CHAR  /* Descricao do comprovante   */
       FIELD vldocmto AS DECI  /* Valor do documento         */
       FIELD dsinform AS CHAR  /* Tipo de pagamento          */
       FIELD lndigita AS CHAR  /* Linha digitavel            */
       FIELD nrtransf AS INTE  /* Conta transferencia        */
       FIELD nmtransf AS CHAR EXTENT 2  /* Nome conta acima  */
       FIELD tpdpagto AS CHAR
       FIELD dsprotoc AS CHAR
       FIELD cdbcoctl AS INTE  /* Banco 085 */
       FIELD cdagectl AS INTE  /* Agencia da cooperativa */
       FIELD dsagectl AS CHAR
       FIELD nrtelefo AS CHAR  /* Nr telefone */
       FIELD nmopetel AS CHAR  /* Nome operadora */
       FIELD dsnsuope AS CHAR  /* NSU operadora */      
       FIELD dspagador      AS CHAR  /* nome do pagador do boleto */
       FIELD nrcpfcgc_pagad AS CHAR  /* NRCPFCGC_PAGAD */
       FIELD dtvenctit      AS CHAR  /* vencimento do titulo */
       FIELD vlrtitulo      AS CHAR  /* valor do titulo */
       FIELD vlrjurmul      AS CHAR  /* valor de juros + multa */
       FIELD vlrdscaba      AS CHAR  /* valor de desconto + abatimento */
       FIELD nrcpfcgc_benef AS CHAR. /* CPF/CNPJ do beneficiario  */   


EMPTY TEMP-TABLE tt-lista_comprovantes.

DEFINE INPUT  PARAMETER par_dtinipro AS DATE                        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtfimpro AS DATE                        NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro AS LOGICAL.
DEFINE OUTPUT PARAMETER TABLE FOR tt-lista_comprovantes.

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


RUN procedures/grava_log.p (INPUT "Obtendo comprovantes...").


aux_hrtransa = TIME.
                     


/* processo que pode demorar bastante devido aos produtos que o
   associado possui */
RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Obtendo comprovantes...",
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
                              "17"                  + ", " + 
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
    xText:NODE-VALUE = "35".    
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
    xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_dtmvtolt).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTINIPRO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dtinipro).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTFIMPRO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dtfimpro).
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
    DEFINE VARIABLE  aux_qtcompro AS INTEGER     NO-UNDO.
    DEFINE VARIABLE  aux_ifcompro AS INTEGER     NO-UNDO.
    
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
    
        IF  xDoc:NUM-CHILDREN = 0  OR
            xRoot:NAME <> "TAA"    THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Saldo/Limite - Sem comunicação com o servidor.").
                
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
    
        DO  aux_qtcompro = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xRoot2,aux_qtcompro).
            
            IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN
                NEXT.

            IF  xRoot2:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Comprovantes - " + xText:NODE-VALUE).

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

           CREATE tt-lista_comprovantes. 

           DO  aux_ifcompro = 1 TO xRoot2:NUM-CHILDREN:

               xRoot2:GET-CHILD(xField,aux_ifcompro).

                IF  xField:SUBTYPE <> "ELEMENT"  THEN
                    NEXT.

                xField:GET-CHILD(xText,1).
           
                IF   xField:NAME = "DTMVTOLT"   THEN
                     ASSIGN tt-lista_comprovantes.dtmvtolt = DATE(xText:NODE-VALUE).
                ELSE                
                IF   xField:NAME = "DSCEDENT"   THEN
                     ASSIGN tt-lista_comprovantes.dscedent = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "VLDOCMTO"   THEN
                     ASSIGN tt-lista_comprovantes.vldocmto = DECI(xText:NODE-VALUE).
                ELSE
                IF   xField:NAME = "DSINFORM"   THEN
                     ASSIGN tt-lista_comprovantes.dsinform = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "LNDIGITA"   AND 
                     xText:NODE-VALUE <> ""     THEN
                     ASSIGN tt-lista_comprovantes.lndigita = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "NRTRANSF"   THEN
                     ASSIGN tt-lista_comprovantes.nrtransf = INTE(xText:NODE-VALUE).
                ELSE
                IF   xField:NAME = "NMTRANS1"   THEN
                     ASSIGN tt-lista_comprovantes.nmtransf[1] = xText:NODE-VALUE. 
                ELSE                                                    
                IF   xField:NAME = "NMTRANS2"   THEN
                     ASSIGN tt-lista_comprovantes.nmtransf[2] = xText:NODE-VALUE.  
                ELSE
                IF   xField:NAME = "TPDPAGTO"   THEN
                     ASSIGN tt-lista_comprovantes.tpdpagto = xText:NODE-VALUE. 
                ELSE
                IF   xField:NAME = "DSPROTOC"   THEN
                ASSIGN tt-lista_comprovantes.dsprotoc = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "CDBCOCTL"   THEN
                ASSIGN tt-lista_comprovantes.cdbcoctl = INTE(xText:NODE-VALUE).
                ELSE
                IF   xField:NAME = "CDAGECTL"   THEN
                ASSIGN tt-lista_comprovantes.cdagectl = INTE(xText:NODE-VALUE).
                ELSE
                IF   xField:NAME = "DSAGECTL"   THEN
                ASSIGN tt-lista_comprovantes.dsagectl = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "DSPAGADOR"   THEN
                ASSIGN tt-lista_comprovantes.dspagador = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "NRCPFCGC_PAGAD"   THEN
                ASSIGN tt-lista_comprovantes.nrcpfcgc_pagad = xText:NODE-VALUE.
                ELSE                                 
                IF   xField:NAME = "DTVENCTIT"   THEN
                ASSIGN tt-lista_comprovantes.dtvenctit = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "VLRTITULO"   THEN
                ASSIGN tt-lista_comprovantes.vlrtitulo = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "VLRJURMUL"   THEN
                ASSIGN tt-lista_comprovantes.vlrjurmul = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "VLRDSCABA"   THEN
                ASSIGN tt-lista_comprovantes.vlrdscaba = xText:NODE-VALUE.
                ELSE
                IF   xField:NAME = "NRCPFCGC_BENEF"   THEN
                ASSIGN tt-lista_comprovantes.nrcpfcgc_benef = xText:NODE-VALUE.                
                IF   xField:NAME = "NMOPETEL"   THEN
                ASSIGN tt-lista_comprovantes.nmopetel = xText:NODE-VALUE.                
                IF   xField:NAME = "NRTELEFO"   THEN
                ASSIGN tt-lista_comprovantes.nrtelefo = xText:NODE-VALUE.
                IF   xField:NAME = "DSNSUOPE"   THEN
                ASSIGN tt-lista_comprovantes.dsnsuope = xText:NODE-VALUE.

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
                                  "TPDTRANS = 17 "                      + " AND " +
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



RUN procedures/grava_log.p (INPUT "Comprovantes obtidos com sucesso.").

RETURN "OK".

/* ......................................................................... */

