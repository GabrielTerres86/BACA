/* ..............................................................................

Procedure: verifica_valor_nota.p 
Objetivo : Verifica se o TAA usa notas de R$100,00.
           Chamada pelo programa manutencao_suprimento.w e manutencao_painop.w
Autor    : Carlos Henrique
Data     : Julho 2017

Ultima alteração: 

............................................................................... */

DEF OUTPUT  PARAM par_flgntcem AS LOGICAL                       NO-UNDO.
DEF OUTPUT  PARAM par_flgderro AS LOGICAL                       NO-UNDO.

{ includes/var_taa.i }
{ includes/var_xfs_lite.i }


DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.


RUN procedures/grava_log.p (INPUT "Verificando utilizacao de notas de 100... ").

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

    /* ------ OPERACAO ----- */
    xDoc:CREATE-NODE(xField,"OPERACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "75".
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
    /**** FIM NODES DO XML **/

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

            IF  xField:NAME = "FLGNTCEM"  THEN DO:

                ASSIGN par_flgntcem = LOGICAL(xText:NODE-VALUE)
                       par_flgderro = NO.
            END.
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN DO:
                RUN procedures/grava_log.p (INPUT "Verificacao notas de 100 - " + xText:NODE-VALUE).

                RUN mensagem.w (INPUT YES,
                                INPUT "      ERRO!",
                                INPUT "",
                                INPUT xText:NODE-VALUE,
                                INPUT "",
                                INPUT "",
                                INPUT "").

                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.

                ASSIGN par_flgntcem = NO
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

