/* ..............................................................................

 Procedure: verifica_bloqueio_saque.p 
 Objetivo : Verificar se o saque no TAA esta Bloqueado ou Desbloqieado
 Autor    : Jorge I. Hamaguchi
 Data     : Novembro 2013

Ultima altera��o: 

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgblsaq    AS LOGICAL  INIT NO     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i }

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
    xText:NODE-VALUE = "40".
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
    
        IF  xDoc:NUM-CHILDREN  = 0       OR
            xRoot:NAME        <> "TAA"  THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Autoriza��o - Sem comunica��o com o servidor").

                RUN mensagem.w (INPUT YES,
                                INPUT "      ERRO!",
                                INPUT "",
                                INPUT "Sem comunica��o com o Servidor",
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
            
            IF  xField:NAME = "FLGBLSAQ"  THEN
                par_flgblsaq = LOGICAL(xText:NODE-VALUE).
            ELSE
                DO:
                    par_flgderro = YES.

                    RUN procedures/grava_log.p (INPUT "Autoriza��o - " + xText:NODE-VALUE). 

                    RUN mensagem.w (INPUT YES,
                                    INPUT "      ERRO!",
                                    INPUT "",
                                    INPUT "",
                                    INPUT xText:NODE-VALUE,
                                    INPUT "",
                                    INPUT "").

                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
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

