/* ..............................................................................

Procedure: calcula_valor_titulo.p 
Objetivo : Obter valor do titulo vencido calculadp
Autor    : Kelvin Souza Ott
Data     : Setembro 2016


Ultima alteração: 19/06/2017 - Ajustes NPC.
                               PRJ340 - NPC (Odirlei-AMcom) 

............................................................................... */
DEFINE INPUT  PARAMETER pr_cdcooper        AS INTE         NO-UNDO.
DEFINE INPUT  PARAMETER pr_nrdconta        AS INTE         NO-UNDO.
DEFINE INPUT  PARAMETER pr_idseqttl        AS INTE         NO-UNDO.
DEFINE INPUT  PARAMETER pr_cdagenci        AS INTE         NO-UNDO.
DEFINE INPUT  PARAMETER pr_nrdcaixa        AS INTE         NO-UNDO.
        
DEFINE INPUT  PARAMETER pr_titulo1         AS DECI         NO-UNDO.
DEFINE INPUT  PARAMETER pr_titulo2         AS DECI         NO-UNDO.
DEFINE INPUT  PARAMETER pr_titulo3         AS DECI         NO-UNDO.
DEFINE INPUT  PARAMETER pr_titulo4         AS DECI         NO-UNDO.
DEFINE INPUT  PARAMETER pr_titulo5         AS DECI         NO-UNDO.
DEFINE INPUT  PARAMETER pr_codigo_barras   AS CHAR         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_vlfatura       AS DECI         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_vlrjuros       AS DECI         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_vlrmulta       AS DECI         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_fltitven       AS INTE         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_flblqval       AS INTE         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_inpesbnf       AS INTE         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_nrdocbnf       AS DECI         NO-UNDO. 
DEFINE OUTPUT  PARAMETER pr_nmbenefi       AS CHAR         NO-UNDO. 
DEFINE OUTPUT  PARAMETER pr_nrctlnpc       AS CHAR         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_des_erro       AS CHAR         NO-UNDO.
DEFINE OUTPUT  PARAMETER pr_dscritic       AS CHAR         NO-UNDO.

{ includes/var_taa.i }

DEFINE         VARIABLE xml_req         AS CHAR                 NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE               NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE               NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE               NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE               NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                  NO-UNDO.
DEFINE         VARIABLE aux_flgerro     AS LOG                  NO-UNDO.
		
RUN procedures/grava_log.p (INPUT "Consultar Valor Titulo...").
aux_hrtransa = TIME.
aux_flgerro = FALSE.
                     


/* processo que pode demorar bastante devido aos produtos que o
   associado possui */
RUN mensagem.w (INPUT NO,
                INPUT "  AGUARDE...",
                INPUT "",
                INPUT "",
                INPUT "Consultando Valor Titulo...",
                INPUT "",
                INPUT "").

/* para garantir a mensagem mesmo que a operacao seja rapida */
PAUSE 1 NO-MESSAGE.



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
    xText:NODE-VALUE = "63".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDCOOPER","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_cdcooper).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRCARTAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(glb_nrcartao).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"NRDCONTA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_nrdconta).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"IDSEQTTL","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_idseqttl).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"NRDCAIXA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_nrdcaixa).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"TITULO1","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_titulo1).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"TITULO2","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_titulo2).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"TITULO3","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_titulo3).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"TITULO4","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_titulo4).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"TITULO5","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_titulo5).
    xField:APPEND-CHILD(xText).
	
	/* ---------- */
    xDoc:CREATE-NODE(xField,"CODIGO_BARRAS","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(pr_codigo_barras).
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
                RUN procedures/grava_log.p (INPUT "Valor Titulo Vencido - Sem comunicação com o servidor.").

                /* Limpa mensagem de aguarde */
                h_mensagem:HIDDEN = YES.
                aux_flgerro = TRUE.
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
    
        DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
            
            xRoot:GET-CHILD(xField,aux_contador).
            
            IF  xField:SUBTYPE <> "ELEMENT"  THEN
                NEXT.
			
            xField:GET-CHILD(xText,1).

            IF  xField:NAME = "DSCRITIC"  THEN
                DO:
                    pr_dscritic = STRING(xText:NODE-VALUE).
                    RUN procedures/grava_log.p (INPUT "Calcula valor titulo - " + xText:NODE-VALUE).

                    /* Limpa mensagem de aguarde */
                    h_mensagem:HIDDEN = YES. 
                    aux_flgerro = TRUE.

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
            ELSE
            DO:
                IF  xField:NAME = "VLFATURA"  THEN 			
                    pr_vlfatura = DECIMAL(xText:NODE-VALUE).		
    			ELSE
    			IF  xField:NAME = "VLRJUROS"  THEN 
    				pr_vlrjuros = DECIMAL(xText:NODE-VALUE). 
    			ELSE
    			IF  xField:NAME = "VLRMULTA"  THEN 
    				pr_vlrmulta = DECIMAL(xText:NODE-VALUE). 
    			ELSE
    			IF  xField:NAME = "FLTITVEN"  THEN 
    				pr_fltitven = INTEGER(xText:NODE-VALUE). 
    			ELSE
                IF  xField:NAME = "FLBLQVAL"  THEN 
    				pr_flblqval = INTEGER(xText:NODE-VALUE). 
    			ELSE
                IF  xField:NAME = "INPESBNF"  THEN 
    				pr_inpesbnf = INTEGER(xText:NODE-VALUE). 
    			ELSE
                IF  xField:NAME = "NRDOCBNF"  THEN 
    				pr_nrdocbnf = DECI(xText:NODE-VALUE). 
    			ELSE
                IF  xField:NAME = "NMBENEFI"  THEN 
    				pr_nmbenefi = STRING(xText:NODE-VALUE). 
    			ELSE
                IF  xField:NAME = "NRCRLNPC"  THEN 
    				pr_nrctlnpc = STRING(xText:NODE-VALUE). 
    			ELSE
    			IF  xField:NAME = "DSCRITIC"  THEN 
    				pr_dscritic = STRING(xText:NODE-VALUE).
    			ELSE
    			IF  xField:NAME = "DES_ERRO"  THEN 
    				pr_des_erro = STRING(xText:NODE-VALUE).
            END.
			
				
        END. /* Fim DO..TO.. */

        LEAVE.
    END. /* Fim WHILE */
        
    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xField.
    DELETE OBJECT xText.

    IF aux_flgerro = FALSE THEN
    DO:
        /* Limpa mensagem de aguarde */
        h_mensagem:HIDDEN = YES.
    END.
    



END. /* Fim RESPOSTA */

RUN procedures/grava_log.p (INPUT "Valor Titulo obtido com sucesso").
                

RETURN "OK".
