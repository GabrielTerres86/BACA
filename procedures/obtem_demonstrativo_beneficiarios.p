
/* ............................................................................

Procedure: obtem_demonstrativo_beneficiario.p 
Objetivo : Obter o extrato do beneficiario
Autor    : Lucas Reinert
Data     : Dezembro 2015


Ultima alteração: 

............................................................................ */

DEFINE INPUT  PARAMETER par_dtcompet AS CHAR    NO-UNDO.
DEFINE INPUT  PARAMETER par_nrrecben AS DECIMAL NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER par_dsextrat AS CHAR    NO-UNDO.

{ includes/var_taa.i }

DEFINE         VARIABLE aux_contador    AS INTEGER                  NO-UNDO.  
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

/* Usada para exibir os beneficiarios do inss */
DEFINE TEMP-TABLE tt-demonst-dcb NO-UNDO
       FIELD nmemisso AS CHAR /* Nome do emissor */
       FIELD cnpjemis AS DECI /* CNPJ emissor */
       FIELD nmbenefi AS CHAR /* Nome do beneficiario*/
       FIELD dtcompet AS CHAR /* Data de competencia */
       FIELD nrrecben AS DECI /* Numero do recebimento do beneficiario    */
       FIELD nrnitins AS DECI /* Numero NIT */
       FIELD cdorgins AS INTE /* Codigo identificador do orgao pagador junto ao INSS*/
       FIELD nmrescop AS CHAR /* Nome da Cooperativa */
       FIELD vlliquid AS DECI. /* Valor liquido */

/* Usada para exibir os lancamentos do beneficiario do inss */
DEFINE TEMP-TABLE tt-demonst-ldcb NO-UNDO
       FIELD cdrubric AS INTE /* Codigo da rubrica */
       FIELD dsrubric AS CHAR /* Descricao da rubrica */
       FIELD vlrubric AS DECI. /* Valor da rubrica */


aux_hrtransa = TIME.

RUN procedures/grava_log.p (INPUT "Obtendo demonstrativo de beneficiario...").
                     
/* processo que pode demorar bastante devido aos produtos que o
   associado possui */
RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Obtendo demonstrativo de beneficiario...",
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
                              "56"                  + ", " + 
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
    xText:NODE-VALUE = "56".    
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTCOMPET","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dtcompet).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRRECBEN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_nrrecben).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRDCONTA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_nrdconta).
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
    DEFINE VARIABLE  aux_qtbenefi AS INTEGER     NO-UNDO.   
    
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
                RUN procedures/grava_log.p (INPUT "Beneficiarios - Sem comunicação com o servidor.").
                
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

        DO  aux_qtbenefi = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xRoot2,aux_qtbenefi).
            
            IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN  
                NEXT.

            IF  xRoot2:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Demonstrativo Beneficiario - " + xText:NODE-VALUE).

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
       
            IF xRoot2:NAME = "BENEFICIARIOS" THEN
               DO:               
                   CREATE tt-demonst-dcb. 
                   
                   DO  aux_contador = 1 TO xRoot2:NUM-CHILDREN:

                       xRoot2:GET-CHILD(xField,aux_contador).

                       IF  xField:SUBTYPE <> "ELEMENT"  THEN
                           NEXT.

                       xField:GET-CHILD(xText,1).
                   
                       IF   xField:NAME = "NMEMISSOR"   THEN
                            ASSIGN tt-demonst-dcb.nmemisso = xText:NODE-VALUE.
                       ELSE
                       IF   xField:NAME = "CNPJEMIS"   THEN
                            ASSIGN tt-demonst-dcb.cnpjemis = DECI(xText:NODE-VALUE).
                       ELSE
                       IF   xField:NAME = "NMBENEFI"   THEN
                            ASSIGN tt-demonst-dcb.nmbenefi = xText:NODE-VALUE.
                       ELSE
                       IF   xField:NAME = "NRRECBEN"   THEN
                            ASSIGN tt-demonst-dcb.nrrecben = DECI(xText:NODE-VALUE).
                       ELSE                       
                       IF   xField:NAME = "DTCOMPET"   THEN
                            ASSIGN tt-demonst-dcb.dtcompet = xText:NODE-VALUE.
                       ELSE
                       IF   xField:NAME = "NRNITINS"   THEN
                            ASSIGN tt-demonst-dcb.nrnitins = DECI(xText:NODE-VALUE).
                       ELSE
                       IF   xField:NAME = "CDORGINS"   THEN
                            ASSIGN tt-demonst-dcb.cdorgins = INTE(xText:NODE-VALUE).
                       ELSE
                       IF   xField:NAME = "VLLIQUID"   THEN
                            ASSIGN tt-demonst-dcb.vlliquid = DECI(xText:NODE-VALUE).
                       ELSE
                       IF   xField:NAME = "NMRESCOP"   THEN
                            ASSIGN tt-demonst-dcb.nmrescop = xText:NODE-VALUE.

                   END.
               END.
            ELSE
               DO:
                  CREATE tt-demonst-ldcb. 
                   
                   DO  aux_contador = 1 TO xRoot2:NUM-CHILDREN:

                       xRoot2:GET-CHILD(xField,aux_contador).

                       IF  xField:SUBTYPE <> "ELEMENT"  THEN
                           NEXT.

                       xField:GET-CHILD(xText,1).
                   
                       IF   xField:NAME = "CDRUBRIC"   THEN
                            ASSIGN tt-demonst-ldcb.cdrubric = INTE(xText:NODE-VALUE).
                       ELSE
                       IF   xField:NAME = "DSRUBRIC"   THEN
                            ASSIGN tt-demonst-ldcb.dsrubric = xText:NODE-VALUE.
                       ELSE
                       IF   xField:NAME = "VLRUBRIC"   THEN
                            ASSIGN tt-demonst-ldcb.vlrubric = DECI(xText:NODE-VALUE).

                   END.
               
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


FOR FIRST tt-demonst-dcb:
    ASSIGN par_dsextrat = STRING(TODAY,"99/99/9999") + "       DEMONSTRATIVO DE       " + STRING(TIME,'HH:MM:SS') +
                          "               CREDITO DE BENEFICIO             " +
                          "                                                " +
                          "Fonte Pagadora:" + STRING(tt-demonst-dcb.nmemisso,"x(7)") + " / CNPJ:" + STRING(STRING(tt-demonst-dcb.cnpjemis),"xx.xxx.xxx/xxxx-xx") +
                          "Beneficiario:........." + STRING(tt-demonst-dcb.nmbenefi,"x(26)") +
                          "Competencia:............................." + SUBSTRING(STRING(DATE(par_dtcompet), "99/99/9999"),4,8) + 
                          "Modalidade Pagamento:......................Conta" +
                          "NB:............" + STRING(STRING(tt-demonst-dcb.nrrecben), "x(11)") + "  / NIT:" + STRING(STRING(tt-demonst-dcb.nrnitins), "x(14)") +
                          "OP:......." + STRING(STRING(tt-demonst-dcb.cdorgins), "x(6)") + " / Cooperativa:......" + STRING(tt-demonst-dcb.nmrescop, "x(11)") + 
                          "                                                " +
                          "------------------------------------------------" +
                          "COD    DESCRICAO                 VALOR          " +
                          "                                                ".
                        
    FOR EACH tt-demonst-ldcb:
      ASSIGN par_dsextrat = par_dsextrat
                          + STRING(STRING(tt-demonst-ldcb.cdrubric), "x(5)") + "  " 
                          + STRING(tt-demonst-ldcb.dsrubric,"x(26)") + "  " 
                          + STRING(TRIM(STRING(tt-demonst-ldcb.vlrubric,"zzzzz,zz9.99-")), "x(13)").
    END.
    ASSIGN par_dsextrat = par_dsextrat +
                          "                                                " +
                          "TOTAL.............................." + STRING(TRIM(STRING(tt-demonst-dcb.vlliquid,"zzzzz,zz9.99-")),"x(13)") +
                          "                                                " +
                          "                                                " +
                          "                                                " +
                          "------------------------------------------------" +
                          " As informacoes sao de responsabilidade do INSS." +
                          " Duvidas, ligue 135.                            " + 
                          "------------------------------------------------".
END.
/* atualiza o log local */
comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                            "WHERE CDCOOPER = " + STRING(glb_cdcooper)  + " AND " +
                                  "DTMVTOLT = " + aux_dsmvtolt          + " AND " +
                                  "NRDCONTA = " + STRING(glb_nrdconta)  + " AND " +
                                  "NRSEQUNI = " + STRING(aux_hrtransa)  + " AND " +
                                  "NRDOCMTO = " + STRING(aux_hrtransa)  + " AND " +
                                  "DTTRANSA = " + aux_dsdtoday          + " AND " +
                                  "HRTRANSA = " + STRING(aux_hrtransa)  + " AND " +
                                  "TPDTRANS = 56 "                      + " AND " +
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
    

RUN procedures/grava_log.p (INPUT "Beneficiarios obtidos com sucesso.").

RETURN "OK".

/* ......................................................................... */


