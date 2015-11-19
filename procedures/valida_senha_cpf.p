/* ..............................................................................

Procedure: valida_senha.p 
Objetivo : Verificar se a senha esta ok
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  21/12/2011 - Receber indicador de senha de letras (Evandro).
                  
                  27/08/2015 - Enviar como parametro o tipo do cartao (James).

............................................................................... */

DEFINE  INPUT PARAMETER par_dssencar    AS CHAR                     NO-UNDO.
DEFINE  INPUT PARAMETER par_dtnascto    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }


DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.

DEFINE         VARIABLE buff            AS CHAR     EXTENT 6    NO-UNDO.


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
    xText:NODE-VALUE = "2".
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
    xDoc:CREATE-NODE(xField,"DSSENCAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = par_dssencar.
    xField:APPEND-CHILD(xText).

    /* ---------- */
    IF  par_dtnascto <> ""  THEN
        DO:
            xDoc:CREATE-NODE(xField,"DTNASCTO","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_dtnascto.
            xField:APPEND-CHILD(xText).
        END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDTIPCAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_idtipcar).
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
                RUN procedures/grava_log.p (INPUT "Senha - Sem comunicação com o servidor").
                
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

    
            IF  xField:NAME = "SENHA"    AND
                xText:NODE-VALUE = "OK"  THEN
                par_flgderro = NO.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Senha - " + xText:NODE-VALUE).

                    IF  xfs_painop_em_uso  THEN
                        DO:
                            buff = "".
                            RUN procedures/atualiza_painop.p (INPUT buff).

                            ASSIGN buff[2] = "           SENHA CRITICADA"
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

/* ............................................................................ */
