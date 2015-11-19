/* ..............................................................................

Procedure: obtem_extrato_aplicacoes.p 
Objetivo : Obter o extrato de aplicações do associado
Autor    : Evandro
Data     : Fevereiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
                  
                  22/07/2013 - Incluir chamada da procedure retorna_valor_blqjud
                               e ajustes para inpressao do Valor bloqueado
                               Judicialmente (Lucas R.).
                               
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)             
                               
                  24/03/2015 - Alterado para mostrar extrato dos novos produtos de
                               captacao. (Reinert)
                               
                  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                               (Lucas Lunelli - Melhoria 83 [SD 279180])

............................................................................... */

DEFINE  INPUT PARAMETER par_dtiniext    AS DATE                     NO-UNDO.
DEFINE  INPUT PARAMETER par_dtfimext    AS DATE                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_tximpres    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }

DEFINE VARIABLE         aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE VARIABLE         aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE VARIABLE         aux_hrtransa    AS INT                      NO-UNDO.

DEFINE VARIABLE         tot_tpaplica    AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE         tot_todasapl    AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE         tot_vlblqjud    AS DECIMAL                  NO-UNDO.

DEFINE         VARIABLE aux_nrtelsac    AS CHARACTER                NO-UNDO.
DEFINE         VARIABLE aux_nrtelouv    AS CHARACTER                NO-UNDO.
DEFINE         VARIABLE aux_flgderro    AS LOGICAL                  NO-UNDO.

DEFINE  TEMP-TABLE tt-saldo-aplicacoes   NO-UNDO
        FIELD dsaplica     AS CHARACTER
        FIELD ddmvtolt     AS INTEGER
        FIELD dtvencto     AS DATE
        FIELD dshistor     AS CHARACTER
        FIELD nrdocmto     AS CHARACTER
        FIELD vllanmto     AS DECIMAL
        FIELD vlprerpp     AS DECIMAL
        FIELD dssitrpp     AS CHAR.



RUN procedures/grava_log.p (INPUT "Obtendo Extrato de aplicações...").


aux_hrtransa = TIME.


/* processo que pode demorar bastante devido aos produtos que o
   associado possui */
RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Verificando Extrato.",
                INPUT "",
                INPUT "").

/* para a mensagem aparecer mesmo que a rotina seja rapida */
PAUSE 1 NO-MESSAGE.



/* São 48 caracteres */

/* centraliza o cabeçalho */
                      /* Coop do associado */
ASSIGN par_tximpres = TRIM(glb_nmrescop) + " AUTOATENDIMENTO"
       par_tximpres = FILL(" ",INT((48 - LENGTH(par_tximpres)) / 2)) + par_tximpres
       par_tximpres = par_tximpres + FILL(" ",48 - length(par_tximpres))
       par_tximpres = par_tximpres +
                      "                                                "   +
                      "EMISSAO: " + STRING(TODAY,"99/99/9999") + "      "  +
                              "               " + STRING(TIME,'HH:MM:SS')  +
                      "                                                "   +
                      /* dados do TAA */             /* agencia na central, sem digito */
                      "COOPERATIVA/PA/TERMINAL: " + STRING(glb_agctltfn,"9999") + "/" +
                                                    STRING(glb_cdagetfn,"9999") + "/" +
                                                    STRING(glb_nrterfin,"9999") +
                                                             "         " +
                      "                                                " +
                      "             EXTRATO DE APLICACOES              " +
                      "                                                " +
                      "                                                " +
                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                          " - " + STRING(glb_nmtitula[1],"x(28)").
    
IF  glb_nmtitula[2] <> ""  THEN
    par_tximpres = par_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").





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
                              "4"                   + ", " +
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
    xText:NODE-VALUE = "8".
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
    xDoc:CREATE-NODE(xField,"DTINIEXT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dtiniext,"99/99/9999").
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTFIMEXT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_dtfimext,"99/99/9999").
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

        /* limpa a mensagem de aguarde.. */
        h_mensagem:HIDDEN = YES.

                           
        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
        IF  xDoc:NUM-CHILDREN = 0  OR
            xRoot:NAME <> "TAA"    THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Extrato Aplicações - Sem comunicação com o servidor.").
                
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

            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Extrato Aplicações - " + xText:NODE-VALUE).
                    
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
            ELSE
            IF  xField:NAME = "DSAPLICA"  THEN
                DO:
                    CREATE tt-saldo-aplicacoes.
                    tt-saldo-aplicacoes.dsaplica = xText:NODE-VALUE.
                END.
            ELSE
            IF  xField:NAME = "DDMVTOLT"  THEN
                tt-saldo-aplicacoes.ddmvtolt = INT(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DTVENCTO"  THEN
                tt-saldo-aplicacoes.dtvencto = DATE(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DSHISTOR"  THEN
                tt-saldo-aplicacoes.dshistor = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "NRDOCMTO"  THEN
                tt-saldo-aplicacoes.nrdocmto= TRIM(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "VLLANMTO"  THEN
                tt-saldo-aplicacoes.vllanmto = DEC(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "VLPRERPP"  THEN
                tt-saldo-aplicacoes.vlprerpp = DEC(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DSSITRPP"  THEN
                tt-saldo-aplicacoes.dssitrpp = xText:NODE-VALUE.


        END. /* Fim DO..TO.. */

        LEAVE.
    END. /* Fim WHILE */

    
    /* monta o extrato */
    IF  NOT par_flgderro  THEN
        DO:

            RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                            OUTPUT aux_nrtelouv,
                                                            OUTPUT aux_flgderro).

            /* RDCA */
            IF  CAN-FIND(FIRST tt-saldo-aplicacoes WHERE
                               tt-saldo-aplicacoes.dsaplica = "RDCA")  THEN
                DO:
                    ASSIGN tot_tpaplica = 0
                           par_tximpres = par_tximpres +
                                          "                                                " +
                                          "TIPO: RDCA                                      " +
                                          "DIA HISTORICO    DOCUMENTO                 SALDO".
                    
                                
                    FOR EACH tt-saldo-aplicacoes WHERE
                             tt-saldo-aplicacoes.dsaplica = "RDCA" NO-LOCK
                             BY tt-saldo-aplicacoes.ddmvtolt:
                    
                    
                        ASSIGN tot_tpaplica = tot_tpaplica + tt-saldo-aplicacoes.vllanmto
                               par_tximpres = par_tximpres +
                                              STRING(tt-saldo-aplicacoes.ddmvtolt,"z99") + " " +
                                              STRING(tt-saldo-aplicacoes.dshistor,"x(11)") + "  " +
                                              STRING(tt-saldo-aplicacoes.nrdocmto,"x(15)") + "  " +
                                              STRING(tt-saldo-aplicacoes.vllanmto,"zzz,zzz,zz9.99").
                    END.
                    
                    ASSIGN tot_todasapl = tot_todasapl + tot_tpaplica.
                           par_tximpres = par_tximpres +
                                          "                            --------------------" +
                                          "                            TOTAL " +
                                          STRING(tot_tpaplica,"zzz,zzz,zz9.99").
                END.


            /* RDC */
            IF  CAN-FIND(FIRST tt-saldo-aplicacoes WHERE
                               tt-saldo-aplicacoes.dsaplica = "RDC")  THEN
                DO:
                    ASSIGN tot_tpaplica = 0
                           par_tximpres = par_tximpres +
                                          "                                                " +
                                          "TIPO: RDC                                       " +
                                          "DT.VENCTO HISTORICO   DOCUMENTO            SALDO".
                    
                                
                    FOR EACH tt-saldo-aplicacoes WHERE
                             tt-saldo-aplicacoes.dsaplica = "RDC" NO-LOCK
                             BY tt-saldo-aplicacoes.ddmvtolt:
                    
                    
                        ASSIGN tot_tpaplica = tot_tpaplica + tt-saldo-aplicacoes.vllanmto
                               par_tximpres = par_tximpres +
                                              STRING(tt-saldo-aplicacoes.dtvencto,"99/99/99") + "  " +
                                              STRING(tt-saldo-aplicacoes.dshistor,"x(11)")    + " "  +
                                              STRING(tt-saldo-aplicacoes.nrdocmto,"x(13)")    + " "  +
                                              STRING(tt-saldo-aplicacoes.vllanmto,"zzzzz,zz9.99").
                    END.
                    
                    ASSIGN tot_todasapl = tot_todasapl + tot_tpaplica.
                           par_tximpres = par_tximpres +
                                          "                            --------------------" +
                                          "                            TOTAL " +
                                          STRING(tot_tpaplica,"zzz,zzz,zz9.99").
                END.


                                                                                             
            /* POUP.PROGRAMADA */
            IF  CAN-FIND(FIRST tt-saldo-aplicacoes WHERE
                               tt-saldo-aplicacoes.dsaplica = "POUP.PROGRAMADA")  THEN
                DO:
                    ASSIGN tot_tpaplica = 0
                           par_tximpres = par_tximpres +
                                          "                                                " +
                                          "TIPO: POUP.PROGRAMADA                           " +
                                          "DIA   SITUACAO      PRESTACAO              SALDO".
                    
                    FOR EACH tt-saldo-aplicacoes WHERE
                             tt-saldo-aplicacoes.dsaplica = "POUP.PROGRAMADA" NO-LOCK
                             BY tt-saldo-aplicacoes.ddmvtolt:
                    
                    
                        ASSIGN tot_tpaplica = tot_tpaplica + tt-saldo-aplicacoes.vllanmto
                               par_tximpres = par_tximpres +
                                              STRING(tt-saldo-aplicacoes.ddmvtolt,"z99")       + "   "      +
                                              STRING(tt-saldo-aplicacoes.dssitrpp,"x(12)")     + "  "       +
                                              STRING(tt-saldo-aplicacoes.vlprerpp,"zz,zz9.99") + "       "  +
                                              STRING(tt-saldo-aplicacoes.vllanmto,"zzzzz,zz9.99").
                    END.
                    
                    ASSIGN tot_todasapl = tot_todasapl + tot_tpaplica.
                           par_tximpres = par_tximpres +
                                          "                            --------------------" +
                                          "                            TOTAL " +
                                          STRING(tot_tpaplica,"zzz,zzz,zz9.99").
                END.

            /* NOVOS PRODUTOS PRE */
            IF  CAN-FIND(FIRST tt-saldo-aplicacoes WHERE
                               tt-saldo-aplicacoes.dsaplica = "PRE-FIXADA")  THEN
                DO:
                    ASSIGN tot_tpaplica = 0
                           par_tximpres = par_tximpres +
                                          "                                                " +
                                          "TIPO: PRE-FIXADA                                " +
                                          "DT.VENCTO HISTORICO   DOCUMENTO            SALDO".
                    
                                
                    FOR EACH tt-saldo-aplicacoes WHERE
                             tt-saldo-aplicacoes.dsaplica = "PRE-FIXADA" NO-LOCK
                             BY tt-saldo-aplicacoes.ddmvtolt:
                    
                    
                        ASSIGN tot_tpaplica = tot_tpaplica + tt-saldo-aplicacoes.vllanmto											  
							   par_tximpres = par_tximpres +
                                              STRING(tt-saldo-aplicacoes.dtvencto,"99/99/99") + "  " +
                                              STRING(tt-saldo-aplicacoes.dshistor,"x(11)")    + " "  +
                                              STRING(tt-saldo-aplicacoes.nrdocmto,"x(13)")    + " "  +
                                              STRING(tt-saldo-aplicacoes.vllanmto,"zzzzz,zz9.99").
                    END.
                    
                    ASSIGN tot_todasapl = tot_todasapl + tot_tpaplica.
                           par_tximpres = par_tximpres +
                                          "                            --------------------" +
                                          "                            TOTAL " +
                                          STRING(tot_tpaplica,"zzz,zzz,zz9.99").
                END.

            /* NOVOS PRODUTOS POS */
            IF  CAN-FIND(FIRST tt-saldo-aplicacoes WHERE
                               tt-saldo-aplicacoes.dsaplica = "POS-FIXADA")  THEN
                DO:
                    ASSIGN tot_tpaplica = 0
                           par_tximpres = par_tximpres +
                                          "                                                " +
                                          "TIPO: POS-FIXADA                                " +
                                          "DT.VENCTO HISTORICO   DOCUMENTO            SALDO".
                    
                                
                    FOR EACH tt-saldo-aplicacoes WHERE
                             tt-saldo-aplicacoes.dsaplica = "POS-FIXADA" NO-LOCK
                             BY tt-saldo-aplicacoes.ddmvtolt:
                    
                    
                        ASSIGN tot_tpaplica = tot_tpaplica + tt-saldo-aplicacoes.vllanmto
                               par_tximpres = par_tximpres +
                                              STRING(tt-saldo-aplicacoes.dtvencto,"99/99/99") + "  " +
                                              STRING(tt-saldo-aplicacoes.dshistor,"x(11)")    + " "  +
                                              STRING(tt-saldo-aplicacoes.nrdocmto,"x(13)")    + " "  +
                                              STRING(tt-saldo-aplicacoes.vllanmto,"zzzzz,zz9.99").
                    END.
                    
                    ASSIGN tot_todasapl = tot_todasapl + tot_tpaplica.
                           par_tximpres = par_tximpres +
                                          "                            --------------------" +
                                          "                            TOTAL " +
                                          STRING(tot_tpaplica,"zzz,zzz,zz9.99").
                END.

            RUN procedures/retorna_valor_blqjud.p (OUTPUT tot_vlblqjud).        
            
            par_tximpres = par_tximpres +
                           "                                                " +
                           "      TOTAL GERAL DAS APLICACOES: "               +
                                        STRING(tot_todasapl,"zzz,zzz,zz9.99"). 
                            
            IF   tot_vlblqjud > 0 THEN
                 par_tximpres = par_tximpres +
                           "                                                " +
                           "   VALOR BLOQUEADO JUDICIALMENTE: "               +
                                        STRING(tot_vlblqjud,"zzz,zzz,zz9.99").

                  par_tximpres = par_tximpres +
                           "                                                " +
                           "    SAC - Servico de Atendimento ao Cooperado   " +
    
                         FILL(" ", 14) + STRING(aux_nrtelsac, "x(20)") + FILL(" ", 14) +
            
                           "     Atendimento todos os dias das 6h as 22h    " +
                           "                                                " +
                           "                   OUVIDORIA                    " +
            
                         FILL(" ", 14) + STRING(aux_nrtelouv, "x(20)") + FILL(" ", 14) +               
                
                           "    Atendimento nos dias uteis das 8h as 17h    " +
                           "                                                " +
                           "            **  FIM DA IMPRESSAO  **            " +
                           "                                                " +
                           "                                                ".
        END.	

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
                                  "TPDTRANS = 4 "                       + " AND " +
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



RUN procedures/grava_log.p (INPUT "Extrato de aplicações obtido com sucesso.").

RETURN "OK".

/* ............................................................................ */
