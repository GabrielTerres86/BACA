/* ..............................................................................

Procedure: verifica_saque.p 
Objetivo : Validar a tentativa de saque
Autor    : Evandro
Data     : Maio 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  15/09/2015 - Alterações para logar valores de saldo e limite em validação de 
                               operações de saque (Lunelli SD 306183).

............................................................................... */

DEFINE  INPUT PARAMETER par_vldsaque    AS DECIMAL                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_dssaqmax    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgcompr    AS LOGICAL                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }


DEFINE         VARIABLE aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                      NO-UNDO.
DEFINE         VARIABLE aux_snoturno    AS LOGICAL                  NO-UNDO.
DEFINE         VARIABLE aux_vlsddisp    AS DECI                     NO-UNDO.
DEFINE         VARIABLE aux_vllimcre    AS DECI                     NO-UNDO.

RUN procedures/grava_log.p (INPUT "Verificando Saque de R$ " + STRING(par_vldsaque,"zz,zz9.99") + "...").


RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Verificando Saque.",
                INPUT "",
                INPUT "").

/* para a mensagem aparecer na tela, mesmo que a operacao seja rapida */
PAUSE 1 NO-MESSAGE.


ASSIGN aux_hrtransa = TIME
       aux_snoturno = NO.

/* verifica se esta no horario de saque noturno */
IF  aux_hrtransa >= glb_hrininot  THEN
    DO:
        /* fim do horario no mesmo dia */
        IF  glb_hrfimnot >  glb_hrininot  AND
            aux_hrtransa <= glb_hrfimnot  THEN
            aux_snoturno = YES.
        ELSE
        /* fim do horario no dia seguinte (vira a noite) */
        IF  glb_hrfimnot < glb_hrininot THEN
            aux_snoturno = YES.
    END.
ELSE
/* fim do horario no dia seguinte (vira a noite) */
IF  glb_hrfimnot < glb_hrininot  THEN
    DO:
        IF  aux_hrtransa <= glb_hrfimnot  THEN
            aux_snoturno = YES.
    END.


IF  aux_snoturno                 AND
    par_vldsaque > glb_vlsaqnot  THEN
    DO:
        h_mensagem:HIDDEN = YES.

        RUN mensagem.w (INPUT YES,
                        INPUT "   ATENÇÃO",
                        INPUT "",
                        INPUT "",
                        INPUT "Valor Noturno Excedido.",
                        INPUT "",
                        INPUT "Máximo: R$ " + TRIM(STRING(glb_vlsaqnot,"zz,zz9.99"))).

        PAUSE 3 NO-MESSAGE.

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
    xText:NODE-VALUE = "20".
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
            IF  xField:NAME = "DSSAQMAX"  THEN
                par_dssaqmax = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "COMPROVANTE"  THEN
                par_flgcompr = LOGICAL(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "VLSDDISP"  THEN
                aux_vlsddisp = DECIMAL(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "VLLIMCRE"  THEN
                aux_vllimcre = DECIMAL(xText:NODE-VALUE).
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    RUN procedures/grava_log.p (INPUT "Saque - Saldo Disponivel: R$ "  + TRIM(STRING(aux_vlsddisp, "zzz,zzz,zz9.99-")) +
                                                          " | Limite Disponivel: R$ " + TRIM(STRING(aux_vllimcre, "zzz,zzz,zz9.99-"))).

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

RUN procedures/grava_log.p (INPUT "Saque - Saldo Disponivel: R$ "  + TRIM(STRING(aux_vlsddisp, "zzz,zzz,zz9.99-")) +
                                      " | Limite Disponivel: R$ " + TRIM(STRING(aux_vllimcre, "zzz,zzz,zz9.99-"))).

RUN procedures/grava_log.p (INPUT "Saque autorizado.").

RETURN "OK".


/* ............................................................................ */
