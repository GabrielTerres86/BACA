/* ..............................................................................

Procedure: efetua_pagamento_convenio.p 
Objetivo : Efetuar o pagamento do convenio
Autor    : Evandro
Data     : Maio 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  23/03/2011 - Ajustes para agendamento de pagamentos (Henrique).
                  
                  28/03/2012 - Dados de banco e agencia no comprovante de pagto
                               (Guilherme/Fabricio).

                  30/12/2015 - Adicionado parametro aux_idastcjt na chamada da 
                               procedure obtem_saldo_limite.p
............................................................................... */

DEFINE  INPUT PARAM par_cdbarra1    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra2    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra3    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra4    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_dscodbar    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_vldpagto    AS DECIMAL          NO-UNDO.
DEFINE  INPUT PARAM par_datpagto    AS DATE             NO-UNDO.
DEFINE  INPUT PARAM par_flagenda    AS LOGICAL          NO-UNDO.
DEFINE OUTPUT PARAM par_dsprotoc    AS CHAR             NO-UNDO.     
DEFINE OUTPUT PARAM par_cdbcoctl    AS CHAR             NO-UNDO.     
DEFINE OUTPUT PARAM par_cdagectl    AS CHAR             NO-UNDO.     
DEFINE OUTPUT PARAM par_flgderro    AS LOGICAL          NO-UNDO.


{ includes/var_TAA.i }


DEFINE VARIABLE     aux_dsmvtolt    AS CHAR             NO-UNDO.
DEFINE VARIABLE     aux_dsdtoday    AS CHAR             NO-UNDO.
DEFINE VARIABLE     aux_hrtransa    AS INT              NO-UNDO.
DEFINE VARIABLE     aux_dsdpagto    AS CHAR             NO-UNDO.
DEFINE VARIABLE     aux_nrsequni    AS INT              NO-UNDO.
DEFINE VARIABLE     aux_idastcjt    AS INT              NO-UNDO.

/* para o saldo */
DEFINE VARIABLE     tmp_vlsddisp    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vllautom    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vlsdbloq    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vlblqtaa    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vlsdblpr    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vlsdblfp    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vlsdchsl    AS DECIMAL          NO-UNDO.    
DEFINE VARIABLE     tmp_vllimcre    AS DECIMAL          NO-UNDO.  


IF par_flagenda THEN
    RUN procedures/grava_log.p (INPUT "Validando Agendamento no valor de R$" + STRING(par_vldpagto,"zzz,zz9.99")).
ELSE
    RUN procedures/grava_log.p (INPUT "Validando Pagamento no valor de R$" + STRING(par_vldpagto,"zzz,zz9.99")).

/* Não verifica o saldo e o pagamento for agendado. */
IF  NOT par_flagenda THEN
    DO:
        /* verifica o saldo - nao logar */
        RUN procedures/obtem_saldo_limite.p ( INPUT 0,
                                             OUTPUT tmp_vlsddisp,
                                             OUTPUT tmp_vllautom,
                                             OUTPUT tmp_vlsdbloq,
                                             OUTPUT tmp_vlblqtaa,
                                             OUTPUT tmp_vlsdblpr,
                                             OUTPUT tmp_vlsdblfp,
                                             OUTPUT tmp_vlsdchsl,
                                             OUTPUT tmp_vllimcre,
                                             OUTPUT aux_idastcjt,
                                             OUTPUT par_flgderro).
        
        IF  par_flgderro   OR
            par_vldpagto > (tmp_vlsddisp + tmp_vllimcre)  THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Pagamento de Convênio - Saldo Insuficiente").
        
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "",
                                INPUT "",
                                INPUT "Não há saldo suficiente",
                                INPUT "para a operação",
                                INPUT "").
        
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
                RETURN "NOK".
            END.
        ELSE
            RUN procedures/grava_log.p (INPUT "Pagamento autorizado.").     

        RUN procedures/grava_log.p (INPUT "Efetuando Pagamento de convênio...").

        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "Efetuando Pagamento",
                        INPUT "de Convênio.",
                        INPUT "",
                        INPUT "").
    END.
ELSE 
    DO:
        RUN procedures/grava_log.p (INPUT "Agendamento autorizado.").        

        RUN procedures/grava_log.p (INPUT "Efetuando Agendamento de convênio...").

        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "Efetuando Agendamento",
                        INPUT "do Pagamento.",
                        INPUT "",
                        INPUT "").
    END.

/* para a mensagem aparecer, a operacao eh rapida */
PAUSE 1 NO-MESSAGE.



ASSIGN aux_hrtransa = TIME
       
       /* valor com separador decimal "." */
       aux_dsdpagto = REPLACE(STRING(par_vldpagto),",",".").


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

/* Se é agendado TPDTRANS = 11, senão TPDTRANS = 10 */
IF  par_flagenda THEN
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
                                      "11"                  + ", " +
                                      STRING(glb_nrcartao)  + ", " +
                                      STRING(aux_dsdpagto)  + ", " +
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
                                      "10"                  + ", " +
                                      STRING(glb_nrcartao)  + ", " +
                                      STRING(aux_dsdpagto)  + ", " +
                                      "0)".
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
    xText:NODE-VALUE = "29".
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

    IF  par_cdbarra1 <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"CDBARRA1","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_cdbarra1.
            xField:APPEND-CHILD(xText).
        END.

    IF  par_cdbarra2 <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"CDBARRA2","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_cdbarra2.
            xField:APPEND-CHILD(xText).
        END.

    IF  par_cdbarra3 <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"CDBARRA3","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_cdbarra3.
            xField:APPEND-CHILD(xText).
        END.

    IF  par_cdbarra4 <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"CDBARRA4","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_cdbarra4.
            xField:APPEND-CHILD(xText).
        END.

    IF  par_dscodbar <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"DSCODBAR","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_dscodbar.
            xField:APPEND-CHILD(xText).
        END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLDPAGTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_vldpagto).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DATPAGTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_datpagto).
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
                RUN procedures/grava_log.p (INPUT "Pagamento de Convênio - Sem comunicação com o servidor.").
                
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

    
            IF  xField:NAME      = "PAGAMENTO"  AND
                xText:NODE-VALUE = "OK"         THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "PROTOCOLO"  THEN
                ASSIGN par_dsprotoc = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "CDBCOCTL"  THEN
                ASSIGN par_cdbcoctl = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "CDAGECTL"  THEN
                ASSIGN par_cdagectl = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Pagamento de Convênio - " + xText:NODE-VALUE).

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
IF par_flagenda THEN
    DO:
        comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                                    "WHERE CDCOOPER = " + STRING(glb_cdcooper)  + " AND " +
                                          "DTMVTOLT = " + aux_dsmvtolt          + " AND " +
                                          "NRDCONTA = " + STRING(glb_nrdconta)  + " AND " +
                                          "NRSEQUNI = " + STRING(aux_nrsequni)  + " AND " +
                                          "NRDOCMTO = " + STRING(aux_hrtransa)  + " AND " +
                                          "DTTRANSA = " + aux_dsdtoday          + " AND " +
                                          "HRTRANSA = " + STRING(aux_hrtransa)  + " AND " +
                                          "TPDTRANS = 11 "                      + " AND " +
                                          "NRCARTAO = " + STRING(glb_nrcartao)  + " AND " +
                                          "VLLANMTO = " + STRING(aux_dsdpagto)  + " AND " +
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
                                          "TPDTRANS = 10 "                      + " AND " +
                                          "NRCARTAO = " + STRING(glb_nrcartao)  + " AND " +
                                          "VLLANMTO = " + STRING(aux_dsdpagto)  + " AND " +
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


IF par_flagenda THEN
    RUN procedures/grava_log.p (INPUT "Agendamento de convênio efetuado com sucesso.").
ELSE
    RUN procedures/grava_log.p (INPUT "Pagamento de convênio efetuado com sucesso.").

RETURN "OK".


/* ........................................................................... */

