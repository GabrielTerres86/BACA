/* ..............................................................................

Procedure: efetua_recolhimento.p 
Objetivo : Efetuar recolhimento do suprimento do TAA do banco FireBird
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 11/08/2010 - Zerar contadores dos deposirários ao efetuar
                               recolhimento (Evandro).
                               
                  20/08/2010 - No recolhimento de envelopes, exibir a data de
                               transação ao invés da data do movimento (Evandro).
                               
                  15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                  
                  13/04/2011 - Incluido o valor total do recolhimento (Evandro).
                  
                  31/05/2013 - Incluido o valor de cada envelope no recolhimento
                               devido à exigência da Prosegur (Evandro).
                               
                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
                  
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
							   
                  14/02/2014 - Ajustar FORMAT para apresentar 
                  
                  14/11/2014 - Alterado para mostrar campo hrtransa no comprovante
                               de recolhimento de envelopes, este contera o nr. de
                               sequencia do envelope. (Reinert)
                               
                  18/02/2015 - Separação de enveloper de dinheiro ou cheque no
                               comprovante de recolhimento (Lunelli - SD 229246).
                               
                  25/03/2015 - Correção tipo de dado do campo NRDCARTAO (Lunelli)

............................................................................... */

DEFINE  INPUT PARAMETER par_tprecolh    AS INT                      NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.

DEFINE VARIABLE aux_dsdtoday            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_dsmvtolt            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_hrtransa            AS INT                      NO-UNDO.
DEFINE VARIABLE aux_dsrecolh            AS CHARACTER                NO-UNDO.

DEFINE VARIABLE aux_nmoperad            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE tmp_tximpres            AS CHARACTER                NO-UNDO.

DEFINE VARIABLE buff                    AS CHARACTER     EXTENT 6   NO-UNDO.

DEFINE TEMP-TABLE tt-envelopes                                      NO-UNDO
       FIELD tpdtrans AS INT
       FIELD dttransa AS DATE
       FIELD nrdocmto AS INT
       FIELD nrsequni AS INT
       FIELD vllanmto AS DEC
       FIELD hrtransa AS INT
       FIELD tpdeposi AS DECI.


       /* 'MM/DD/YYYY' */
ASSIGN aux_dsdtoday = "'" + SUBSTRING(STRING(TODAY,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),5,4) + "'"

       /* 'MM/DD/YYYY' */
       aux_dsmvtolt = "'" + SUBSTRING(STRING(glb_dtmvtolt,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),5,4) + "'".


IF  par_tprecolh = 1  THEN
    aux_dsrecolh = "Numerários".
ELSE
    aux_dsrecolh = "Envelopes".


RUN procedures/grava_log.p (INPUT "Efetuando recolhimento de " + aux_dsrecolh + " do terminal...").

IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).

        buff[2] = "       EFETUANDO O RECOLHIMENTO".

        IF  par_tprecolh = 1  THEN
            buff[4] = "            DE NUMERARIOS".
        ELSE
            buff[4] = "             DE ENVELOPES".

        RUN procedures/atualiza_painop.p (INPUT buff).

        PAUSE 2 NO-MESSAGE.
    END.
ELSE
    DO:
        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "",
                        INPUT "Efetuando o recolhimento",
                        INPUT "de " + aux_dsrecolh,
                        INPUT "").
        
        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
    END.


/* Conexao com o Firebird 
   1-Conexao ODBC criada em Ferramentas ADM do Windows
   2-Usuario
   3-Senha */

CREATE "ADODB.Connection" conexao.
conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Erro na conexão com o banco de dados FireBird").

        IF  xfs_painop_em_uso  THEN
            DO:
                buff = "".
                RUN procedures/atualiza_painop.p (INPUT buff).
                                  
                ASSIGN buff[2] = " ERRO NA CONEXAO COM O BANCO DE DADOS"
                       buff[4] = "VERIFIQUE A INSTALACAO DO EQUIPAMENTO".
        
                RUN procedures/atualiza_painop.p (INPUT buff).
        
                PAUSE 2 NO-MESSAGE.
            END.
        ELSE
            DO:
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "",
                                INPUT "Erro na conexão com o banco de",
                                INPUT "dados. Verifique a instalação",
                                INPUT "do equipamento.",
                                INPUT "").
                
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            END.

        par_flgderro = YES.
        RETURN "NOK".
    END.

aux_hrtransa = TIME.

RUN procedures/busca_operador ( INPUT STRING(glb_nrdconta),
                               OUTPUT aux_nmoperad,
                               OUTPUT par_flgderro).

CREATE "ADODB.Command" comando.
CREATE "ADODB.RecordSet" resultado.

comando:ActiveConnection = conexao.



IF  par_tprecolh = 1  THEN
    RUN recolhe_numerarios.
ELSE
    RUN recolhe_envelopes.


IF  RETURN-VALUE = "NOK"  THEN
    RETURN "NOK".


RUN procedures/grava_log.p (INPUT "Terminal recolhido com sucesso.").



RUN procedures/grava_log.p (INPUT "Imprimindo comprovante de recolhimento.").

/* se a impressora estiver habilitada e com papel */
IF  xfs_impressora       AND
    NOT xfs_impsempapel  THEN
    RUN impressao.w (INPUT "Comprovante...",
                     INPUT tmp_tximpres).


/* fechar e liberar a conexao */
conexao:CLOSE()          NO-ERROR.
RELEASE OBJECT conexao   NO-ERROR.
RELEASE OBJECT comando   NO-ERROR.
RELEASE OBJECT resultado NO-ERROR.

RETURN "OK".





PROCEDURE recolhe_numerarios:

    comando:CommandText = "UPDATE CRAPTFN SET " +
                                  "QTNOTK7A = 0, " +
                                  "QTNOTK7B = 0, " +
                                  "QTNOTK7C = 0, " +
                                  "QTNOTK7D = 0, " +
                                  "QTNOTK7R = 0, " +

                                  "VLNOTK7A = 0, " +
                                  "VLNOTK7B = 0, " +
                                  "VLNOTK7C = 0, " +
                                  "VLNOTK7D = 0, " +
                                  "VLNOTK7R = 0".
        
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
    

    comando:CommandText = "INSERT INTO CRAPLFN ( " +
                                    "DTTRANSA, " +
                                    "HRTRANSA, " +
                                    "CDOPERAD, " +
                                    "DTMVTOLT, " +
                                    "TPDTRANS, " +
                                    "VLTRANSA, " +
                                    "CDSITATU) " +
                          "VALUES ( " +
                                    aux_dsdtoday          + ", " +
                                    STRING(aux_hrtransa)  + ", " +
                                    STRING(glb_nrdconta)  + ", " +
                                    aux_dsmvtolt          + ", " +
                                    "5"                   + ", " +
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
            RETURN "NOK".
        END.


    RUN atualiza_servidor.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* Se atualizou no Servidor, atualiza como OK no FireBird */
    RUN procedures/grava_log.p (INPUT "Confimando recolhimento no terminal...").
    
    comando:CommandText = "UPDATE CRAPLFN SET CDSITATU = 1 " +
                                 "WHERE DTTRANSA = " + aux_dsdtoday         + " AND " +
                                       "HRTRANSA = " + STRING(aux_hrtransa) + " AND " +
                                       "CDOPERAD = " + STRING(glb_nrdconta) + " AND " +
                                       "DTMVTOLT = " + aux_dsmvtolt         + " AND " +
                                       "TPDTRANS = 5 AND " +
                                       "VLTRANSA = 0 AND " +
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

    
        /* São 48 caracteres */
        
        /* centraliza o cabeçalho */
        ASSIGN tmp_tximpres = TRIM(glb_nmcoptfn) + " AUTOATENDIMENTO"
               tmp_tximpres = FILL(" ",INT((48 - LENGTH(tmp_tximpres)) / 2)) + tmp_tximpres
               tmp_tximpres = tmp_tximpres + FILL(" ",48 - length(tmp_tximpres))
               tmp_tximpres = tmp_tximpres +
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
                              "   COMPROVANTE DE RECOLHIMENTO DE NUMERARIOS    " +
                              "                                                " +
                              "OPERADOR: " + STRING(glb_nrdconta,"zzzzzzzzz9")   +
                              " - " + STRING(aux_nmoperad,"x(25)")               +
                              "                                                " +
                              "                  QTD   VLR NOTA           TOTAL" + 
                      
                              "CASSETE A:    " + STRING(glb_qtnotK7A,"zz,zz9-") + "    " + 
                                               STRING(glb_vlnotK7A,"zz9.99-")  + "     " +
                                               STRING(glb_qtnotK7A * glb_vlnotK7A,"zzz,zz9.99-") +
                      
                              "CASSETE B:    " + STRING(glb_qtnotK7B,"zz,zz9-") + "    " + 
                                               STRING(glb_vlnotK7B,"zz9.99-")  + "     " +
                                               STRING(glb_qtnotK7B * glb_vlnotK7B,"zzz,zz9.99-") +
                      
                              "CASSETE C:    " + STRING(glb_qtnotK7C,"zz,zz9-") + "    " + 
                                               STRING(glb_vlnotK7C,"zz9.99-")  + "     " +
                                               STRING(glb_qtnotK7C * glb_vlnotK7C,"zzz,zz9.99-") +
                      
                              "CASSETE D:    " + STRING(glb_qtnotK7D,"zz,zz9-") + "    " + 
                                               STRING(glb_vlnotK7D,"zz9.99-")  + "     " +
                                               STRING(glb_qtnotK7D * glb_vlnotK7D,"zzz,zz9.99-") +
                      
                              /* No K7R existem diversas notas, no valor das notas esta a soma
                                 de todas as notas rejeitadas */
                              "CASSETE R:    " + STRING(glb_qtnotK7R,"zz,zz9-") + "    " + 
                                                "            " +
                                                STRING(glb_vlnotK7R,"zzz,zz9.99-") +
                      
                              "              -------                 ----------" +
                      
                              "    TOTAL:   "  + STRING(glb_qtnotK7A + glb_qtnotK7B +
                                                        glb_qtnotK7C + glb_qtnotK7D + 
                                                        glb_qtnotK7R,"zzz,zz9-") +
                                                "                " +
                                                STRING((glb_qtnotK7A * glb_vlnotK7A) +
                                                       (glb_qtnotK7B * glb_vlnotK7B) +
                                                       (glb_qtnotK7C * glb_vlnotK7C) +
                                                       (glb_qtnotK7D * glb_vlnotK7D) +
                                                        glb_vlnotK7R,"zzz,zz9.99-") +
                              "                                                " +
                              "                                                " +
                              "            **  FIM DA IMPRESSAO  **            " +
                              "                                                " +
                              "                                                ".


    RUN procedures/grava_log.p (INPUT "Notas Recolhidas: ").
    RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7A) + " x K7A (" + STRING(glb_vlnotK7A,"zz9.99-") + ") = R$ " + STRING(glb_qtnotK7A * glb_vlnotK7A,"zz,zz9.99-")).
    RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7B) + " x K7B (" + STRING(glb_vlnotK7B,"zz9.99-") + ") = R$ " + STRING(glb_qtnotK7B * glb_vlnotK7B,"zz,zz9.99-")).
    RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7C) + " x K7C (" + STRING(glb_vlnotK7C,"zz9.99-") + ") = R$ " + STRING(glb_qtnotK7C * glb_vlnotK7C,"zz,zz9.99-")).
    RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7D) + " x K7D (" + STRING(glb_vlnotK7D,"zz9.99-") + ") = R$ " + STRING(glb_qtnotK7D * glb_vlnotK7D,"zz,zz9.99-")).
    RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7R) + " x K7R = R$ " + STRING(glb_vlnotK7R,"zz,zz9.99-")).

    RUN procedures/grava_log.p (INPUT "Total do Recolhimento: R$ " + STRING((glb_qtnotK7A * glb_vlnotK7A) +
                                                                            (glb_qtnotK7B * glb_vlnotK7B) +
                                                                            (glb_qtnotK7C * glb_vlnotK7C) +
                                                                            (glb_qtnotK7D * glb_vlnotK7D) +
                                                                             glb_vlnotK7R,"zzz,zz9.99-")).

    RETURN "OK".

END PROCEDURE.
/* Fim recolhe_numerarios */





PROCEDURE recolhe_envelopes:

    DEFINE VARIABLE cnt_detalhe         AS INT          NO-UNDO.
    DEFINE VARIABLE aux_vlenvelo        AS DEC          NO-UNDO.
    DEFINE VARIABLE aux_qtenvelo        AS INT          NO-UNDO.

    RUN atualiza_servidor.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    comando:CommandText = "UPDATE CRAPTFN SET QTENVELO = 0".

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


   /* São 48 caracteres */

   /* centraliza o cabeçalho */
   ASSIGN tmp_tximpres = TRIM(glb_nmcoptfn) + " AUTOATENDIMENTO"
          tmp_tximpres = FILL(" ",INT((48 - LENGTH(tmp_tximpres)) / 2)) + tmp_tximpres
          tmp_tximpres = tmp_tximpres + FILL(" ",48 - length(tmp_tximpres))
          tmp_tximpres = tmp_tximpres +
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
                         "    COMPROVANTE DE RECOLHIMENTO DE ENVELOPES    " +
                         "                                                " +
                         "OPERADOR: " + STRING(glb_nrdconta,"zzzzzzzzz9")   +
                         " - " + STRING(aux_nmoperad,"x(25)")               +
                         "                                                ".


    /* Verifica os envelopes ainda nao recolhidos */
    comando:CommandText = "SELECT TPDTRANS, DTTRANSA, NRDOCMTO, NRCARTAO, NRSEQUNI, VLLANMTO, HRTRANSA FROM CRAPLTL " +
                                 "WHERE CDSITATU = 1".


    resultado = comando:EXECUTE(,,) NO-ERROR.

    IF  resultado = ?  THEN
        DO:
            /* fechar e liberar a conexao */
            conexao:CLOSE()          NO-ERROR.
            RELEASE OBJECT conexao   NO-ERROR.
            RELEASE OBJECT comando   NO-ERROR.
            RELEASE OBJECT resultado NO-ERROR.
            
            par_flgderro = YES.
            RETURN "NOK".
        END.

    EMPTY TEMP-TABLE tt-envelopes.
    


    /* Quando o campo nao estiver alimentado no firebird, para o progress,
       é retornado ?, por isso o tratamento se o valor >= 0 */
    
    DO  WHILE NOT resultado:EOF():

        IF  INT(resultado:FIELDS("TPDTRANS"):VALUE) >= 0  THEN
            DO: 
                CREATE tt-envelopes.
                ASSIGN tt-envelopes.tpdtrans = INT(resultado:FIELDS("TPDTRANS"):VALUE).
            END.

        IF  DATE(resultado:FIELDS("DTTRANSA"):VALUE) <> ?  THEN
            ASSIGN tt-envelopes.dttransa = DATE(resultado:FIELDS("DTTRANSA"):VALUE).
    
        IF  INT(resultado:FIELDS("NRDOCMTO"):VALUE) >= 0  THEN
            ASSIGN tt-envelopes.nrdocmto = INT(resultado:FIELDS("NRDOCMTO"):VALUE).

        IF  DECI(resultado:FIELDS("NRCARTAO"):VALUE) >= 0  THEN
            ASSIGN tt-envelopes.tpdeposi = DECI(resultado:FIELDS("NRCARTAO"):VALUE). /* Uso do NRCARTAO: 0 - Dinheiro / 1 - Cheque */
    
        IF  INT(resultado:FIELDS("NRSEQUNI"):VALUE) >= 0  THEN
            ASSIGN tt-envelopes.nrsequni = INT(resultado:FIELDS("NRSEQUNI"):VALUE).

        IF  INT(resultado:FIELDS("VLLANMTO"):VALUE) >= 0  THEN
            ASSIGN tt-envelopes.vllanmto = DEC(resultado:FIELDS("VLLANMTO"):VALUE).

        IF  INT(resultado:FIELDS("HRTRANSA"):VALUE) >= 0  THEN
            ASSIGN tt-envelopes.hrtransa = INT(resultado:FIELDS("HRTRANSA"):VALUE).
    
        resultado:MoveNext().
    END.


    tmp_tximpres = tmp_tximpres +
                   "             DEPOSITO IDENTIFICADO              " +
                   "                                                ".
    
    FOR EACH tt-envelopes WHERE tt-envelopes.tpdtrans = 8 NO-LOCK
                        BREAK BY tt-envelopes.tpdeposi DESC
                                BY tt-envelopes.dttransa
                                  BY tt-envelopes.nrsequni:
       
        IF  FIRST-OF(tt-envelopes.tpdeposi) THEN
            DO:
                /* Cabeçalho de envelopes de Depósito em Dinheiro */
                IF tt-envelopes.tpdeposi = 0 THEN
                    ASSIGN tmp_tximpres = tmp_tximpres +
                                          "       DATA    DOCTO    CONFERENCIA     ESPECIE ".
                /* Cabeçalho de envelopes de Depósito em Cheque */
                ELSE
                    ASSIGN tmp_tximpres = tmp_tximpres +
                                          "       DATA    DOCTO    CONFERENCIA      CHEQUE ".
            END.

        ASSIGN tmp_tximpres = tmp_tximpres +
                              " " + STRING(tt-envelopes.dttransa,"99/99/9999") +
                              "    " +
                              STRING(tt-envelopes.nrdocmto,"99999") +
                              "    " +
                              STRING(tt-envelopes.hrtransa,"zzz,zzz,zz9") +
                              "  " +
                              STRING(tt-envelopes.vllanmto,"zzz,zz9.99") +
                              " "
               aux_vlenvelo = aux_vlenvelo + tt-envelopes.vllanmto
               aux_qtenvelo = aux_qtenvelo + 1.


        IF  LAST-OF(tt-envelopes.tpdeposi) THEN
            DO:
                ASSIGN tmp_tximpres = tmp_tximpres +
                                        "                                                " +
                                        "       TOTAL         QUANTIDADE:        " + STRING(aux_qtenvelo,"zzz,zz9") + " "  +
                                        "                          VALOR: " + STRING(aux_vlenvelo,"zzz,zzz,zz9.99") + " "  +
                                        "                                                ".               
                ASSIGN aux_qtenvelo = 0
                       aux_vlenvelo = 0.
            END.
    END.


    tmp_tximpres = tmp_tximpres +
                   "                                                " +
                   "                                                " +
                   "            **  FIM DA IMPRESSAO  **            " +
                   "                                                " +
                   "                                                ".


    /* Atualiza os envelopes como recolhidos */
    comando:CommandText = "UPDATE CRAPLTL SET CDSITATU = 2 " +
                                 "WHERE CDSITATU = 1".


    resultado = comando:EXECUTE(,,) NO-ERROR.

    IF  resultado = ?  THEN
        DO:
            /* fechar e liberar a conexao */
            conexao:CLOSE()          NO-ERROR.
            RELEASE OBJECT conexao   NO-ERROR.
            RELEASE OBJECT comando   NO-ERROR.
            RELEASE OBJECT resultado NO-ERROR.
            
            par_flgderro = YES.
            RETURN "NOK".
        END.


    /* Zera o contador de envelopes do Hardware */
    RUN procedures/grava_log.p (INPUT "Zerando contador do Hardware...").

    /* Depositário InterBold */
    IF  glb_tpenvelo = 1  THEN
        RUN WinIniciaContadorDepIbold IN aux_xfsliteh (OUTPUT LT_Resp).
    ELSE
        /* Depositário Pentasys */
        RUN WinZeraContadorDep IN aux_xfsliteh (OUTPUT LT_Resp,
                                                OUTPUT cnt_detalhe).

    RETURN "OK".

END PROCEDURE.
/* Fim recolhe_envelopes */



PROCEDURE atualiza_servidor:

    /* Atualiza o recolhimento no Servidor */
    RUN procedures/grava_log.p (INPUT "Efetuando recolhimento do servidor...").
    
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
        xText:NODE-VALUE = "12".
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"CDOPERAD","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(glb_nrdconta).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"TPRECOLH","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(par_tprecolh).
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
                    RUN procedures/grava_log.p (INPUT "Recolhimento - Sem comunicação com o servidor").
                    
                    IF  xfs_painop_em_uso  THEN
                        DO:
                            buff = "".
                            RUN procedures/atualiza_painop.p (INPUT buff).
                    
                            buff[4] = "    SEM COMUNICACAO COM O SERVIDOR".
                            RUN procedures/atualiza_painop.p (INPUT buff).
                    
                            PAUSE 2 NO-MESSAGE.
                        END.
                    ELSE
                        DO:
                            RUN mensagem.w (INPUT YES,
                                            INPUT "      ERRO!",
                                            INPUT "",
                                            INPUT "Sem comunicação com o Servidor",
                                            INPUT "",
                                            INPUT "",
                                            INPUT "").
                          
                            PAUSE 3 NO-MESSAGE.
                            h_mensagem:HIDDEN = YES.
                        END.

                    par_flgderro = YES.
                    LEAVE.
                END.
        
            DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
                
                xRoot:GET-CHILD(xField,aux_contador).
                
                IF  xField:SUBTYPE <> "ELEMENT"   THEN
                    NEXT.
        
                xField:GET-CHILD(xText,1).
    
        
                IF  xField:NAME = "RECOLHIMENTO"  AND
                    xText:NODE-VALUE = "OK"       THEN
                    par_flgderro = NO.
                ELSE
                IF  xField:NAME = "DSCRITIC"  THEN
                    DO:
                        RUN procedures/grava_log.p (INPUT "Recolhimento - " + xText:NODE-VALUE).
    
                        IF  xfs_painop_em_uso  THEN
                            DO:
                                buff = "".
                                RUN procedures/atualiza_painop.p (INPUT buff).
                   
                                ASSIGN buff[2] = "             RECOLHIMENTO CRITICADO"
                                       buff[4] = "   VERIFIQUE LOG PARA MAIS DETALHES".
                   
                                RUN procedures/atualiza_painop.p (INPUT buff).
                                
                                PAUSE 2 NO-MESSAGE.
                            END.
                        ELSE
                            DO:
                                RUN mensagem.w (INPUT YES,
                                                INPUT "      ERRO!",
                                                INPUT "",
                                                INPUT xText:NODE-VALUE,
                                                INPUT "",
                                                INPUT "",
                                                INPUT "").
                       
                                PAUSE 3 NO-MESSAGE.
                                h_mensagem:HIDDEN = YES.
                            END.
        
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

    RETURN "OK".

END PROCEDURE.
/* Fim atualiza_servidor */

/* ........................................................................... */

