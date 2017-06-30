/* ..............................................................................

Procedure: verifica_titulo.p 
Objetivo : Verificar e retornar dados do titulo
Autor    : Evandro
Data     : Maio 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  23/03/2011 - Inserido campo na XML devido agendamento (Henrique)
                  
                  26/05/2011 - Incluir campo no XML para calculo do valor do titulo
                               devido a cobranca registrada (Guilherme).
                                                           
                  12/03/2014 - Altercao processo calculo vencimento (Daniel). 

                  20/01/2017 - Ajustes Nova Plataforma de cobrança.
                               PRJ340 - NPC (Odirlei-AMcom)

............................................................................... */

DEFINE  INPUT PARAM par_cdbarra1    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra2    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra3    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra4    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_cdbarra5    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_dscodbar    AS CHAR             NO-UNDO.     
DEFINE  INPUT PARAM par_vldpagto    AS DECIMAL          NO-UNDO.
DEFINE  INPUT PARAM par_datpagto    AS DATE             NO-UNDO.
DEFINE  INPUT PARAM par_flagenda    AS LOGICAL          NO-UNDO.
DEFINE  INPUT PARAM par_nrctlnpc    AS CHAR             NO-UNDO.
DEFINE OUTPUT PARAM par_nmdbanco    AS CHAR             NO-UNDO.     
DEFINE OUTPUT PARAM par_dslindig    AS CHAR             NO-UNDO.
/* 
   Valor documento calculado com juros mora abatimento desconto 
   para cobranca registrada
*/
DEFINE OUTPUT PARAM par_vlrdocum    AS DECIMAL          NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro    AS LOGICAL          NO-UNDO.

DEFINE OUTPUT PARAM par_datavenc    AS DATE             NO-UNDO. /* Daniel */


{ includes/var_taa.i }



RUN procedures/grava_log.p (INPUT "Verificando título...").


RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Verificando Título.",
                INPUT "",
                INPUT "").

/* para a mensagem aparecer, a operacao eh rapida */
PAUSE 1 NO-MESSAGE.


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
    xText:NODE-VALUE = "25".
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

    IF  par_cdbarra5 <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"CDBARRA5","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_cdbarra5.
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

    /* ---------- */ 
    IF  par_nrctlnpc <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"NRCTLNPC","ELEMENT").
            xRoot:APPEND-CHILD(xField).

            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = par_nrctlnpc.
            xField:APPEND-CHILD(xText).
        END.

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
                RUN procedures/grava_log.p (INPUT "Verificação de Título - Sem comunicação com o servidor.").
                
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

    
            IF  xField:NAME = "NMDBANCO"  THEN
                par_nmdbanco = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "DSLINDIG"  THEN
                par_dslindig = xText:NODE-VALUE.
            ELSE
            IF  xField:NAME = "VLRDOCUM"  THEN
                par_vlrdocum = DECIMAL(xText:NODE-VALUE).
            ELSE
                        IF  xField:NAME = "DATAVENC"  THEN
                par_datavenc = DATE(xText:NODE-VALUE). /* Daniel */
            ELSE
            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    /* customizacao quando titulo esta vencido */
                    IF  xText:NODE-VALUE MATCHES "*titulo*vencido*"  THEN
                        DO:
                            RUN procedures/grava_log.p (INPUT "Verificação de Título - Título Vencido").
                            
                            RUN mensagem.w (INPUT YES,
                                            INPUT "    Atenção!",
                                            INPUT "",
                                            INPUT "Esse pagamento não pode ser",
                                            INPUT "efetuado nos terminais de",
                                            INPUT "autoatendimento - procure o",
                                            INPUT "banco cedente do título").

                            PAUSE 5 NO-MESSAGE.
                        END.
                    ELSE
                        DO:
                            RUN procedures/grava_log.p (INPUT "Verificação de Título - " + xText:NODE-VALUE).
                            
                            RUN mensagem.w (INPUT YES,
                                            INPUT "      ERRO!",
                                            INPUT "",
                                            INPUT xText:NODE-VALUE,
                                            INPUT "",
                                            INPUT "",
                                            INPUT "").

                            PAUSE 3 NO-MESSAGE.
                        END.

                    
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


RUN procedures/grava_log.p (INPUT "Título verificado com sucesso.").

RETURN "OK".


/* ........................................................................... */

