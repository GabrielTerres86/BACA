/* ..............................................................................

Procedure: efetua_suprimento.p 
Objetivo : Efetuar a alimentação do suprimento do TAA do banco FireBird
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
                  
                  26/08/2013 - Somente atualizar as notas no FireBird depois
                               de retorno OK do Servidor (Evandro).
                               
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)             

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }


DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.

DEFINE VARIABLE aux_dstotsup            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_dsdtoday            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_dsmvtolt            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_hrtransa            AS INTEGER                  NO-UNDO.

DEFINE VARIABLE aux_nmoperad            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE tmp_tximpres            AS CHARACTER                NO-UNDO.

DEFINE VARIABLE buff                    AS CHARACTER     EXTENT 6   NO-UNDO.


RUN procedures/grava_log.p (INPUT "Efetuando suprimento do terminal...").



IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).

        buff[4] = "        EFETUANDO SUPRIMENTO".
        RUN procedures/atualiza_painop.p (INPUT buff).

        PAUSE 2 NO-MESSAGE.
    END.
ELSE
    DO:
        RUN mensagem.w (INPUT NO,
                        INPUT "  AGUARDE...",
                        INPUT "",
                        INPUT "",
                        INPUT "Efetuando o suprimento.",
                        INPUT "",
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
        RUN procedures/grava_log.p (INPUT "Erro na conexão com o banco de dados FireBird.").

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

CREATE "ADODB.Command" comando.
CREATE "ADODB.RecordSet" resultado.

comando:ActiveConnection = conexao.

       /* valor com separador decimal "." */
ASSIGN aux_dstotsup = STRING((glb_qtnotk7A * glb_vlnotk7A)  +
                             (glb_qtnotk7B * glb_vlnotk7B)  +
                             (glb_qtnotk7C * glb_vlnotk7C)  +
                             (glb_qtnotk7D * glb_vlnotk7D))

       aux_dstotsup = REPLACE(aux_dstotsup,",",".")


       /* 'MM/DD/YYYY' */
       aux_dsdtoday = "'" + SUBSTRING(STRING(TODAY,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(TODAY,"99999999"),5,4) + "'"

       /* 'MM/DD/YYYY' */
       aux_dsmvtolt = "'" + SUBSTRING(STRING(glb_dtmvtolt,"99999999"),3,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),1,2) + "/" +
                            SUBSTRING(STRING(glb_dtmvtolt,"99999999"),5,4) + "'".

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
                                "4"                   + ", " +
                                aux_dstotsup          + ", " +
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



/* Atualiza o suprimento no Servidor */
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
    xText:NODE-VALUE = "11".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDOPERAD","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_nrdconta).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"QTNOTK7A","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_qtnotK7A).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"QTNOTK7B","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_qtnotK7B).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"QTNOTK7C","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_qtnotK7C).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"QTNOTK7D","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_qtnotK7D).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLNOTK7A","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_vlnotK7A).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLNOTK7B","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_vlnotK7B).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLNOTK7C","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_vlnotK7C).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLNOTK7D","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_vlnotK7D).
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
                RUN procedures/grava_log.p (INPUT "Suprimento - Sem comunicação com o servidor.").
                
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

    
            IF  xField:NAME = "SUPRIMENTO"  AND
                xText:NODE-VALUE = "OK"   THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Suprimento - " + xText:NODE-VALUE).

                    IF  xfs_painop_em_uso  THEN
                        DO:
                            buff = "".
                            RUN procedures/atualiza_painop.p (INPUT buff).

                            ASSIGN buff[2] = "         SUPRIMENTO CRITICADO"
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



/* Se atualizou no Servidor, atualiza como OK no FireBird */
RUN procedures/grava_log.p (INPUT "Confimando suprimento no terminal...").

comando:CommandText = "UPDATE CRAPLFN SET CDSITATU = 1 " +
                             "WHERE DTTRANSA = " + aux_dsdtoday         + " AND " +
                                   "HRTRANSA = " + STRING(aux_hrtransa) + " AND " +
                                   "CDOPERAD = " + STRING(glb_nrdconta) + " AND " +
                                   "DTMVTOLT = " + aux_dsmvtolt         + " AND " +
                                   "TPDTRANS = 4 AND " +
                                   "VLTRANSA = " + aux_dstotsup         + " AND " +
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



comando:CommandText = "UPDATE CRAPTFN SET " +
                              "QTNOTK7A = " + STRING(glb_qtnotK7A) + ", " +
                              "QTNOTK7B = " + STRING(glb_qtnotK7B) + ", " +
                              "QTNOTK7C = " + STRING(glb_qtnotK7C) + ", " +
                              "QTNOTK7D = " + STRING(glb_qtnotK7D) + ", " +
                              "VLNOTK7A = " + STRING(glb_vlnotK7A) + ", " +
                              "VLNOTK7B = " + STRING(glb_vlnotK7B) + ", " +
                              "VLNOTK7C = " + STRING(glb_vlnotK7C) + ", " +
                              "VLNOTK7D = " + STRING(glb_vlnotK7D).

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





RUN procedures/grava_log.p (INPUT "Terminal suprido com sucesso.").

RUN procedures/grava_log.p (INPUT "Notas Supridas: ").
RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7A) + " x K7A (" + STRING(glb_vlnotK7A,"zz9.99") + ") = R$ " + STRING(glb_qtnotK7A * glb_vlnotK7A,"zz,zz9.99")).
RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7B) + " x K7B (" + STRING(glb_vlnotK7B,"zz9.99") + ") = R$ " + STRING(glb_qtnotK7B * glb_vlnotK7B,"zz,zz9.99")).
RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7C) + " x K7C (" + STRING(glb_vlnotK7C,"zz9.99") + ") = R$ " + STRING(glb_qtnotK7C * glb_vlnotK7C,"zz,zz9.99")).
RUN procedures/grava_log.p (INPUT STRING(glb_qtnotK7D) + " x K7D (" + STRING(glb_vlnotK7D,"zz9.99") + ") = R$ " + STRING(glb_qtnotK7D * glb_vlnotK7D,"zz,zz9.99")).


RUN procedures/busca_operador.p ( INPUT STRING(glb_nrdconta),
                                 OUTPUT aux_nmoperad,
                                 OUTPUT par_flgderro).

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
                      "    COMPROVANTE DE SUPRIMENTO DE NUMERARIOS     " +
                      "                                                " +
                      "OPERADOR: " + STRING(glb_nrdconta,"zzzzzzzzz9")   +
                      " - " + STRING(aux_nmoperad,"x(25)")               +
                      "                                                " +
                      "                  QTD   VLR NOTA           TOTAL" + 
                
                      "CASSETE A:     " + STRING(glb_qtnotK7A,"zz,zz9") + "     " + 
                                          STRING(glb_vlnotK7A,"zz9.99") + "      " +
                                          STRING(glb_qtnotK7A * glb_vlnotK7A,"zzz,zz9.99") +
                
                      "CASSETE B:     " + STRING(glb_qtnotK7B,"zz,zz9") + "     " + 
                                          STRING(glb_vlnotK7B,"zz9.99") + "      " +
                                          STRING(glb_qtnotK7B * glb_vlnotK7B,"zzz,zz9.99") +
                
                      "CASSETE C:     " + STRING(glb_qtnotK7C,"zz,zz9") + "     " + 
                                          STRING(glb_vlnotK7C,"zz9.99") + "      " +
                                          STRING(glb_qtnotK7C * glb_vlnotK7C,"zzz,zz9.99") +
                
                      "CASSETE D:     " + STRING(glb_qtnotK7D,"zz,zz9") + "     " + 
                                          STRING(glb_vlnotK7D,"zz9.99") + "      " +
                                          STRING(glb_qtnotK7D * glb_vlnotK7D,"zzz,zz9.99") +
                
                      "              -------                 ----------" +
                
                      "    TOTAL:    "  + STRING(glb_qtnotK7A + glb_qtnotK7B +
                                                 glb_qtnotK7C + glb_qtnotK7D,"zzz,zz9") +
                                          "                 " +
                                          STRING((glb_qtnotK7A * glb_vlnotK7A) +
                                                 (glb_qtnotK7B * glb_vlnotK7B) +
                                                 (glb_qtnotK7C * glb_vlnotK7C) +
                                                 (glb_qtnotK7D * glb_vlnotK7D),"zzz,zz9.99") +
                      "                                                " +
                      "                                                " +
                      "            **  FIM DA IMPRESSAO  **            " +
                      "                                                " +
                      "                                                ".


RUN procedures/grava_log.p (INPUT "Imprimindo comprovante de suprimento.").

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

  
/* pelo sistema, considerar cassetes como ok */
sis_cassetes = YES.

/* desativar os nao alimentados */
IF  glb_vlnotK7A = 0  OR
    glb_qtnotK7A = 0  THEN
    sis_cassetes[1] = NO.

IF  glb_vlnotK7B = 0  OR
    glb_qtnotK7B = 0  THEN
    sis_cassetes[2] = NO.

IF  glb_vlnotK7C = 0  OR
    glb_qtnotK7C = 0  THEN
    sis_cassetes[3] = NO.

IF  glb_vlnotK7D = 0  OR
    glb_qtnotK7D = 0  THEN
    sis_cassetes[4] = NO.

IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).

        ASSIGN buff[2] = "       REINICIANDO DISPENSADOR"
               buff[4] = "              AGUARDE...".

        RUN procedures/atualiza_painop.p (INPUT buff).
    END.
ELSE
    RUN mensagem.w (INPUT YES,
                    INPUT "   ATENÇÃO",
                    INPUT "",
                    INPUT "Reiniciando dispensador.",
                    INPUT "",
                    INPUT "Aguarde...",
                    INPUT "").

/* reinicia o dispositivo sem os cassetes desabilitados */
RUN procedures/inicializa_dispositivo.p ( INPUT 1,
                                         OUTPUT par_flgderro).

IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
    END.
ELSE
    h_mensagem:HIDDEN = YES.


RETURN "OK".

/* ........................................................................... */

