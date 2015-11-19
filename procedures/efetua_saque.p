/* ..............................................................................

Procedure: efetua_saque.p 
Objetivo : Validar e efetuar o saque
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
                  
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
                               
                  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                               (Lucas Lunelli - Melhoria 83 [SD 279180])

............................................................................... */

DEFINE  INPUT PARAMETER par_vldsaque    AS DECIMAL                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_tximpres    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }


DEFINE         VARIABLE aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_dsdsaque    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_dssaqmax    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_flgcompr    AS LOGICAL                  NO-UNDO.
DEFINE         VARIABLE aux_flgderro    AS LOGICAL                  NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                      NO-UNDO.
DEFINE         VARIABLE aux_nrsequni    AS INT                      NO-UNDO.
DEFINE         VARIABLE aux_dscomand    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_nrtelsac    AS CHARACTER                NO-UNDO.
DEFINE         VARIABLE aux_nrtelouv    AS CHARACTER                NO-UNDO.


/* verifica se pode sacar */
RUN procedures/verifica_saque.p ( INPUT par_vldsaque,
                                 OUTPUT aux_dssaqmax,
                                 OUTPUT aux_flgcompr,
                                 OUTPUT par_flgderro).

IF  par_flgderro  THEN
    RETURN "NOK".




RUN procedures/grava_log.p (INPUT "Efetuando Saque de R$ " + STRING(par_vldsaque,"zz,zz9.99") + "...").

ASSIGN aux_hrtransa = TIME
       
       /* valor com separador decimal "." */
       aux_dsdsaque = REPLACE(STRING(par_vldsaque),",",".").


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
                              "1"                   + ", " +
                              STRING(glb_nrcartao)  + ", " +
                              STRING(aux_dsdsaque)  + ", " +
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
    xText:NODE-VALUE = "21".
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
    xDoc:CREATE-NODE(xField,"VLDSAQUE","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_vldsaque).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQUNI","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrsequni).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"HRTRANSA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_hrtransa).
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
                RUN procedures/grava_log.p (INPUT "Saque - Sem comunicação com o servidor.").
                
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


            IF  xField:NAME = "SAQUE"    AND
                xText:NODE-VALUE = "OK"  THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Saque - " + xText:NODE-VALUE).

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




/* comando de atualizacao do saque caso consiga dispensar as notas */
aux_dscomand = "UPDATE CRAPLTL SET CDSITATU = 1 " +
                       "WHERE CDCOOPER = " + STRING(glb_cdcooper)  + " AND " +
                             "DTMVTOLT = " + aux_dsmvtolt          + " AND " +
                             "NRDCONTA = " + STRING(glb_nrdconta)  + " AND " +
                             "NRSEQUNI = " + STRING(aux_nrsequni)  + " AND " +
                             "NRDOCMTO = " + STRING(aux_hrtransa)  + " AND " +
                             "DTTRANSA = " + aux_dsdtoday          + " AND " +
                             "HRTRANSA = " + STRING(aux_hrtransa)  + " AND " +
                             "TPDTRANS = 1"                        + " AND " +
                             "NRCARTAO = " + STRING(glb_nrcartao)  + " AND " +
                             "VLLANMTO = " + STRING(aux_dsdsaque)  + " AND " +
                             "CDSITATU = 0".


RUN procedures/dispensa_notas.p ( INPUT par_vldsaque,
                                  INPUT YES, /* pagar */
                                  INPUT aux_dscomand,
                                 OUTPUT par_flgderro).


/* em caso de erros, ja verifica as pendencias de saque */
IF  par_flgderro  THEN
    DO:
        RUN procedures/verifica_pendencias.p (OUTPUT par_flgderro).

        /* atualiza os saldos, principalmente neste caso, rejeitados */
        RUN procedures/atualiza_saldo.p (OUTPUT par_flgderro).

        RETURN "NOK".
    END.


RUN procedures/grava_log.p (INPUT "Saque efetuado com sucesso.").



/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.




RUN procedures/atualiza_saldo.p (OUTPUT par_flgderro).

IF  par_flgderro  THEN
    RETURN "NOK".


/* impressao do comprovante de saque */
IF  aux_flgcompr  THEN
    DO:
        /* São 48 caracteres */

        RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                        OUTPUT aux_nrtelouv,
                                                        OUTPUT aux_flgderro).
        
        /* centraliza o cabeçalho */
                              /* coop do associado */
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
                              "              COMPROVANTE DE SAQUE              " +
                              "                                                " + 
                              "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                                  " - " + STRING(glb_nmtitula[1],"x(28)").


        IF  glb_nmtitula[2] <> ""  THEN
            par_tximpres = par_tximpres +
                           "                    " + STRING(glb_nmtitula[2],"x(28)").

        par_tximpres = par_tximpres +
                       "                                                "       +
                       "VALOR.........: R$ " + STRING(par_vldsaque,"zz,zz9.99") +
                                                   "                    "       +
                       "DOCUMENTO.....: "    + STRING(aux_hrtransa,"zzz,zz9")   +
                                              "                         "       +
                       "SEQUENCIAL....: "    + STRING(aux_nrsequni,"zzz,zz9")   + 
                                              "                         " +
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
                       "                                                ".
    END.

RETURN "OK".


/* ............................................................................ */
