/* ..............................................................................

Procedure: obtem_lancamentos_futuros.p 
Objetivo : Obter o lancamentos Futuros
Autor    : Lenilson (Mouts)
Data     : Outubro 2016

Alteracoes: 09/11/2017 - Alteradas variaveis utilizadas no calculo total de debitos
                         e creditos. Rotina se perdia no calculo quando havia lancamento
                         futuro de credito.
                         Heitor (Mouts) - Chamado 689749

............................................................................... */

DEFINE  INPUT PARAMETER par_dtiniext    AS DATE                     NO-UNDO.
DEFINE  INPUT PARAMETER par_dtfimext    AS DATE                     NO-UNDO.
DEFINE  INPUT PARAMETER par_inisenta    AS INTEGER                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_tximpres    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

/* para o saldo, ao final do extrato */
DEFINE VARIABLE aux_nmtitula            AS CHARACTER    EXTENT 2    NO-UNDO.
DEFINE VARIABLE aux_vlsddisp            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllautom            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllautoma           AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllaudeb            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllaudebi           AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllaucred           AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllauded            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vlldeb              AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_debcre              AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_vllcre              AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllaucre            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vlsdbloq            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vlblqtaa            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vlsdblpr            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vlsdblfp            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vlsdchsl            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vllimcre            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_vldiscrd            AS DECIMAL   INIT 0         NO-UNDO.
DEFINE VARIABLE aux_vlstotal            AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_tximpres            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_idastcjt        	AS INTEGER      			NO-UNDO.



/* para controle de deposito TAA */
DEFINE VARIABLE aux_fldeptaa            AS LOGICAL      INIT NO     NO-UNDO.

DEF TEMP-TABLE tt-dados-cpa NO-UNDO
    FIELD vldiscrd AS DECI
    FIELD txmensal AS DECI.




{ includes/var_taa.i }

DEFINE VARIABLE aux_dsdtoday            AS CHAR                     NO-UNDO.     
DEFINE VARIABLE aux_dsmvtolt            AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_hrtransa            AS INT                      NO-UNDO.
DEFINE VARIABLE aux_contchar            AS INT                      NO-UNDO.
DEFINE VARIABLE aux_nrtelsac            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_nrtelouv            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_flgderro            AS LOGICAL                  NO-UNDO.


RUN procedures/grava_log.p (INPUT "Obtendo Lancamentos Futuros...").

aux_hrtransa = TIME.





/* processo que pode demorar bastante devido aos produtos que o
   associado possui */
RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Verificando Lancamentos.",
                INPUT "",
                INPUT "").



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
                      "           LANCAMENTOS FUTUROS                  " +
                      "                                                " + 
                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                          " - " + STRING(glb_nmtitula[1],"x(28)").
        

IF  glb_nmtitula[2] <> ""  THEN
    par_tximpres = par_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").

par_tximpres = par_tximpres +
               "                                                " +
               "PERIODO: " + STRING(par_dtiniext,"99/99/9999")    +
               " ATE " + STRING(par_dtfimext,"99/99/9999") +
                                                 "              " +
               "                                                " +
               "DTA   HISTORICO       DOCUMENTO  D/C       VALOR".






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
                              "3"                   + ", " +
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
    xText:NODE-VALUE = "64".
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

    /* ---------- */
    xDoc:CREATE-NODE(xField,"INISENTA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(par_inisenta).
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
    DEFINE VARIABLE aux_conttext  AS DECIMAL     NO-UNDO.
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
                RUN procedures/grava_log.p (INPUT "Extrato Conta - Sem comunicação com o servidor.").
                
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
    
        ASSIGN aux_vllcre = 0.       
        DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xField,aux_contador).
            
            IF  xField:SUBTYPE <> "ELEMENT"  THEN
                NEXT.
    
            xField:GET-CHILD(xText,1).

            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Lancamentos Conta - " + xText:NODE-VALUE).

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
            IF  xField:NAME = "DTMVTOLT"  THEN
                par_tximpres = par_tximpres + STRING(xText:NODE-VALUE,"x(5)"+ " ").
            ELSE
            IF  xField:NAME = "DSHISTOR"  THEN
                DO:
                    IF  LENGTH(STRING(xText:NODE-VALUE)) > 15 THEN
                        DO: 
                            IF (INDEX(xText:NODE-VALUE," ") = 0) THEN
                                DO:
                                    par_tximpres = par_tximpres + SUBSTRING(STRING(xText:NODE-VALUE),1,15) + " ".
                                END.
                            ELSE
                                DO:
                                    par_tximpres = par_tximpres + SUBSTRING(STRING(xText:NODE-VALUE),1,INDEX(xText:NODE-VALUE," ")).
                                    
                                    aux_contchar = (INDEX(xText:NODE-VALUE," ") - 1).
                                    aux_contchar = (47 - aux_contchar).
                                    
                                    par_tximpres = par_tximpres + FILL(" ", aux_contchar).
                                    par_tximpres = par_tximpres + SUBSTRING(STRING(xText:NODE-VALUE + FILL(" ",15)),(INDEX(xText:NODE-VALUE," ") + 1),15).
                                END.
                        END.
                    ELSE
                        par_tximpres = par_tximpres + STRING(xText:NODE-VALUE, "X(14)") + " ".
                    
                    
                    /* verifica se possui deposito TAA */
                    IF  xText:NODE-VALUE MATCHES "*DEPOSITO TAA*"  THEN
                        aux_fldeptaa = YES.
                END.
            ELSE
            /* Documento pode vir em branco "-" */
            IF  xField:NAME = "NRDOCMTO"  THEN
                DO:
                    IF  xText:NODE-VALUE = "-"  THEN
                        par_tximpres = par_tximpres + "           ".
                    ELSE
                        par_tximpres = par_tximpres + STRING(xText:NODE-VALUE,"x(11)") + " ".
                END.
            ELSE
            /* Debito/Credito pode vir em branco "-" */
            IF  xField:NAME = "INDEBCRE"  THEN
                DO:
                    IF  xText:NODE-VALUE = "-"  THEN
                        par_tximpres = par_tximpres + "   ".
                    ELSE
                        par_tximpres = par_tximpres + " " + xText:NODE-VALUE .
                        aux_debcre   = STRING(xText:NODE-VALUE).
                END.
            ELSE
            IF  xField:NAME = "VLLANMTO"  THEN
               DO: 
                par_tximpres = par_tximpres + STRING(DECIMAL(xText:NODE-VALUE),"zzzzz,zz9.99-").
                IF aux_debcre = "C" THEN
                   aux_vlldeb = STRING(DECIMAL(xText:NODE-VALUE),"zzzzz,zz9.99-").
                   aux_vllcre = aux_vllcre + DECIMAL(aux_vlldeb).
               END.    

			IF  xField:NAME = "VLLAUTOM"  THEN
               DO: 
                   aux_vllautoma = DECIMAL(xText:NODE-VALUE).
               END.
			
			IF  xField:NAME = "VLLAUDEB"  THEN
               DO: 
                   aux_vllaudebi = DECIMAL(xText:NODE-VALUE).
               END.
			
			IF  xField:NAME = "VLLAUCRE"  THEN
               DO: 
                   aux_vllaucred = DECIMAL(xText:NODE-VALUE).
               END.
        END. /* Fim DO..TO.. */
        
        LEAVE.

    END. /* Fim WHILE */

	par_tximpres = par_tximpres +
               "    TOTAL DE DEBITOS:              " + STRING(DECIMAL(aux_vllaudebi),"zzzzz,zz9.99-")   + 
               "    TOTAL DE CREDITOS - DEBITOS:   " + STRING(DECIMAL(aux_vllautoma),"zzzzz,zz9.99-"). 

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
                                  "TPDTRANS = 3 "                       + " AND " +
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

/* se possuir deposito TAA, informa que os valores estao sujeitos a
   verificacao */
IF  aux_fldeptaa  THEN
    par_tximpres = par_tximpres +
                   "                                                " +
                   "* VALORES SUJEITOS A CONFERENCIA E  NAO  SOMADOS" +
                   "  NO SALDO DO DIA.                              " +
                   "                                                ".



/* coloca o saldo ao final do extrato */

/* obtem os valores dos saldos - nao logar */
RUN procedures/obtem_saldo_limite.p ( INPUT 0,
                                     OUTPUT aux_vlsddisp,
                                     OUTPUT aux_vllautom,
                                     OUTPUT aux_vllaucre,
                                     OUTPUT aux_vlsdbloq,
                                     OUTPUT aux_vlblqtaa,
                                     OUTPUT aux_vlsdblpr,
                                     OUTPUT aux_vlsdblfp,
                                     OUTPUT aux_vlsdchsl,
                                     OUTPUT aux_vllimcre,
                                     OUTPUT aux_idastcjt,
                                     OUTPUT par_flgderro).

aux_vlstotal = aux_vlsddisp - aux_vlsdbloq +
               aux_vlsdblpr + aux_vlsdblfp + aux_vlsdchsl.
IF aux_conttext = 0 THEN
   DO:
     aux_vllautom = 0. 
   END.
ELSE
   DO:
        aux_vllautom = aux_vllauded. 
        aux_vlstotal = aux_vlsddisp + aux_vllauded.

   END.
/* monta o comprovante do saldo, passa os nome em branco para
   nao montar o cabecalho dos saldos */

aux_nmtitula = "".

/* Busca o saldo do credito pre-aprovado */
RUN procedures/busca_saldo_pre_aprovado.p (OUTPUT aux_flgderro,
                                           OUTPUT TABLE tt-dados-cpa).
FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
IF  AVAIL tt-dados-cpa THEN
    ASSIGN aux_vldiscrd = tt-dados-cpa.vldiscrd.

RUN procedures/imprime_saldo_limite_lanc.p ( INPUT aux_nmtitula,
                                        INPUT aux_vlsddisp, 
                                        INPUT aux_vllaudebi, 
                                        INPUT aux_vllaucred,
                                        INPUT aux_vlsdbloq, 
                                        INPUT aux_vlblqtaa,
                                        INPUT aux_vlsdblpr, 
                                        INPUT aux_vlsdblfp, 
                                        INPUT aux_vlsdchsl,
                                        INPUT aux_vllimcre, 
                                        INPUT aux_vldiscrd, /* pré-aprovado */
                                        INPUT aux_vlsddisp,
                                        INPUT aux_vllautoma + aux_vlsddisp,
                                        OUTPUT aux_tximpres).


RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                OUTPUT aux_nrtelouv,
                                                OUTPUT aux_flgderro).


par_tximpres = par_tximpres +
               aux_tximpres +
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

RUN procedures/grava_log.p (INPUT "Extrato de Conta Corrente obtido com sucesso.").

RETURN "OK".

/* ............................................................................ */
