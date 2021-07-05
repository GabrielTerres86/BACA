
{ includes/var_batch.i "new" }  
DEF STREAM str_1.

DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqrel AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nrtextab AS INT                                      NO-UNDO.
DEF     VAR aux_nrregist AS INT                                      NO-UNDO.
DEF     VAR aux_nrencerr AS INT                                      NO-UNDO.
DEF     VAR aux_nrreativ AS INT                                      NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(70)"                 NO-UNDO.
DEF     VAR aux_nmarqlog AS CHAR                                     NO-UNDO.
DEF     VAR aux_nrcpfcgc AS CHAR      FORMAT "x(14)"                 NO-UNDO.
DEF     VAR aux_nrcpfcg2 AS CHAR      FORMAT "x(11)"                 NO-UNDO.

DEF     VAR aux_data     AS DATE                                     NO-undo.
DEF     VAR aux_dtainici AS DATE                                     NO-undo.
DEF     VAR aux_dtafinal AS DATE                                     NO-undo.
DEF     VAR aux_nrdconta AS CHAR                                     NO-UNDO.

DEF     VAR rel_dsagenci AS CHAR                                     NO-UNDO.
DEF     VAR rel_nmempres AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmresemp AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmrelato AS CHAR      FORMAT "x(40)" EXTENT 5        NO-UNDO.
DEF     VAR rel_nrmodulo AS INT       FORMAT "9"                     NO-UNDO.
DEF     VAR rel_nmmodulo AS CHAR      FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]                 NO-UNDO.


DEF BUFFER crabass FOR crapass.
DEF BUFFER crabalt FOR crapalt.


FORM SKIP(1)
     "PA: " rel_dsagenci  FORMAT "x(21)"  
     SKIP(1)
     WITH NO-LABEL SIDE-LABEL WIDTH 80 FRAME f_cab_contaitg.

ASSIGN glb_cdprogra = "crps503"
       glb_flgbatch = FALSE.

	   

FOR EACH crapcop WHERE flgativo = TRUE AND cdcooper <> 3 NO-LOCK:
   
    RUN fontes/iniprg.p.
    
    ASSIGN glb_cdcritic = 0.

    IF   glb_cdcritic > 0 THEN 
         RETURN.
    
    ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                          STRING(MONTH(glb_dtmvtolt),"99") + 
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".

    /* Verifica o bloqueio do arquivo */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "NRARQMVITG"   AND
                       craptab.tpregist = 409            NO-LOCK NO-ERROR.

    IF   NOT AVAIL craptab   THEN
         DO:
             glb_cdcritic = 393.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> " + aux_nmarqlog).

             RUN fontes/fimprg.p.                   
             RETURN.
         END.    

    IF   INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - COO409 - " + glb_cdprogra + "' --> '"  +
                               "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" +
                               " >> " + aux_nmarqlog).
             RUN fontes/fimprg.p.                   
             RETURN.
         END.
     
    RUN abre_arquivo.

    /* Nao enviada e Repr. */     
    FOR EACH crapalt WHERE crapalt.cdcooper  = crapcop.cdcooper
                       AND crapalt.dtaltera  = glb_dtmvtolt
                       NO-LOCK BY crapalt.nrdconta:

        IF  NOT (crapalt.dsaltera MATCHES "*exclusao conta-itg*"    AND
                 CAN-DO("0,3,4",STRING(crapalt.flgctitg)))  THEN
            NEXT.
        
        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                           crapass.nrdconta = crapalt.nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             NEXT.

        FIND crabass WHERE crabass.cdcooper = crapcop.cdcooper  AND
                           crabass.nrdconta = crapass.nrdconta
                           EXCLUSIVE-LOCK NO-ERROR.
                                                  
        FIND crabalt WHERE crabalt.cdcooper = crapcop.cdcooper      AND
                           crabalt.nrdconta = crapalt.nrdconta  AND
                           crabalt.dtaltera = crapalt.dtaltera
                           EXCLUSIVE-LOCK NO-ERROR.

        ASSIGN crapass.dtectitg = glb_dtmvtolt   
               crapalt.flgctitg = 1.  /* Enviada */

        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".                


        /* Resgistro w_contaitg.cdsituac (Quando 1- Encerrada, 2 - Reativada) */
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                              STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
           
    END.     /* Fim do FOR EACH */

/* ACENTRA */
IF  crapcop.cdcooper = 5 THEN 
DO:
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "2850796".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2872366".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

		ASSIGN aux_nrdconta = "2850966".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.


        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "2453".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.


		


END.
/* CREDCREA */		   
ELSE IF crapcop.cdcooper = 7 THEN		
DO:


        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "885738".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "765651".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "743534".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2850796".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0089818X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0065390X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "644250".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "768332".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "1037161".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "680443".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0101725X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "637173".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0098633X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "1055208".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "650196".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "933775".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "986348".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2052261".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "1080067".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "1084267".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052245".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052210".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052288".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "8159939".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "0205227X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052229".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052237".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052202".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052199".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2052253".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "1080040".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "817899".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "228028".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "216305".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "156523".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "4006".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		


END.
/* TRANSPOCRED */		   
ELSE IF crapcop.cdcooper = 9 THEN		
DO:
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "0066216X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "662178".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "662151".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "1569953".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2479249".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "1569961".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "660272".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2415771".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2415763".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2672103".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "1569945".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0156997X".
	
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
	
		ASSIGN aux_nrdconta = "1147692".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0081752X".
	
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
	
		ASSIGN aux_nrdconta = "2415801".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0241578X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2415755".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2415798".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "269751".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "307203".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "259993".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "244163".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "238520".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "219010".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "128422".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "108820".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "103152".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "66761".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "59218".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "41700".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "36110".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "16152".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "14800".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "8214".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "6262".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "5193".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "4022".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "1937".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "281638".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "266175".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		


END.		
/* VIACREDI AV */		   
ELSE IF crapcop.cdcooper = 16 THEN		
DO:

        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "226491".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "280445".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "362972".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "363022".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "389250".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "389277".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "425680".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "427446".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "427926".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "433306".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "456519".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "457027".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "509248".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "523011".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "528730".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "537357".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "542830".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "574783".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "599867".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "602965".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "614041".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "621617".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "622303".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "626155".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "632546".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "691402".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "854816".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "1241427".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "2808528".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0036293X".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0038612X".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0046578X".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "0055569X".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
END.
/* ACREDICOOP */		   
ELSE IF crapcop.cdcooper = 2 THEN		
DO:

        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "297488".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "432598".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.		
		
		ASSIGN aux_nrdconta = "838918".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "0021440X".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "842753".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "560162".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "51063".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "51829".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "70076".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "70238".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "73903".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "76295".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "76554".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "76619".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "76805".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "102610".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "221848".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "725919".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
		ASSIGN aux_nrdconta = "954594".
	
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.


		
END.	

/* VIACREDI */		   
ELSE IF crapcop.cdcooper = 1 THEN		
DO:

        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		ASSIGN aux_nrdconta = "2728567".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

		ASSIGN aux_nrdconta = "596493".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

		ASSIGN aux_nrdconta = "2120879".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "509574".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2183730".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2120860".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121158".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121433".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121093".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121212".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121263".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121409".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121522".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "875511".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "929158".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121298".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "835501".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121026".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "834971".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "857017".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "2121387".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121085".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121131".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836890".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "825549".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0212131X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0283684X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121220".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121336".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121352".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "755648".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121123".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0212095X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0212145X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121247".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121107".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0212128X".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2058308".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121484".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836831".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120925".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121069".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121239".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121395".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121360".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121379".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "860395".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "1008250".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120895".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120968".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2837005".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836947".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121441".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "236314".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121425".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120992".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0212114X".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "465569".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836815".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120909".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836866".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836912".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121255".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121344".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120976".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836939".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121018".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121417".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836920".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120887".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121492".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "474967".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121514".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121468".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "859567".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "873810".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "870269".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "929042".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121506".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836955".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2836998".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836904".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120933".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "857025".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "0087146X".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2120941".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "992054".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121166".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836807".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121077".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836823".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121328".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121204".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "637882".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2270595".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2176335".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "992267".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121190".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		
	ASSIGN aux_nrdconta = "2836785".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836963".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "663581".
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "491519".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121174".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121476".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121271".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2120984".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121182".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836971".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "435430".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2836793".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2121050".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "2176343".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.


		ASSIGN aux_nrdconta = "1914685".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

		
END.

/* CIVIA */		   
ELSE IF crapcop.cdcooper = 13 THEN			
DO: 
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   


	ASSIGN aux_nrdconta = "5406910".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "5447366".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "5447358".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "5567450".

        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "46876".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "38008".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "603490".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "401200".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "322733".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "314811".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "310352".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "300128".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "265179".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "245631".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "121886".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "47236".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "16381".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "25550".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.


END.
/* CREDELESC */		   
ELSE IF crapcop.cdcooper = 8 THEN
DO: 		
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

		
	ASSIGN aux_nrdconta = "76368".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "76376".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		
	ASSIGN aux_nrdconta = "69833".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
	ASSIGN aux_nrdconta = "68764".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "34959".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "760".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "9962".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "19020".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "26808".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "47384".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "45772".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "28215".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		ASSIGN aux_nrdconta = "31046".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

		
END.
/* EVOLUA */		   
ELSE IF crapcop.cdcooper = 14 THEN		
DO: 		
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   
		
	ASSIGN aux_nrdconta = "0055622X".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "556068".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "556211".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "753203".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "753211".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
END.
/* CREVISC */
ELSE IF crapcop.cdcooper = 12 THEN		
DO: 		
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

	ASSIGN aux_nrdconta = "57401".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "0005741X".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "57428".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "57576".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "57460".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
			   
END.			   
/* CREDICOMIN */
ELSE IF crapcop.cdcooper = 10 THEN		
DO:		
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

	ASSIGN aux_nrdconta = "66176".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "126284".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "5410".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "10995".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "53228".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "72257".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		

END.		
			   
		
/* CREDIFOZ */
ELSE IF crapcop.cdcooper = 11 THEN		
DO:		
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   

	ASSIGN aux_nrdconta = "859745".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2511274".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "859737".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1147722".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "728".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "1465".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "12181".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "12440".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "20087".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "22519".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "25640".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "27952".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "28479".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "35785".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "56650".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "63088".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "64599".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "66729".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "66869".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "67237".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "69450".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		

		ASSIGN aux_nrdconta = "79090".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "83046".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "90360".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "91537".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "94072".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "101044".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "105465".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "106747".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "116343".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "120995".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "121525".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "127060".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "133205".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "144380".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "155624".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "156620".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "168130".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "169218".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "170542".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "171590".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "173525".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "174629".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "175986".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "177903".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "179833".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "196886".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "198471".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "201626".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "221880".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "222364".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "222437".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "222658".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "223034".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "224685".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "234648".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "265349".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "265969".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "268569".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "269859".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "270334".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "278220".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "282740".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "283495".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "286834".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "289515".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "336459".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "369110".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		
		ASSIGN aux_nrdconta = "556130".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

			   
END.			   
		
/* UNILOS */
ELSE IF crapcop.cdcooper = 6 THEN		
DO:		
        ASSIGN aux_nrcpfcgc = "00000000000000" 
               aux_nrcpfcg2 = "00000000000".   			   
			   
	ASSIGN aux_nrdconta = "1084151".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2415712".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2417855".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1084135".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2415720".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1095455".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "244074".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "243469".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1084100".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1095447".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "241857".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1095463".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2415747".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1066137".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1084119".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "2415739".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "0108416X".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1084127".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1084143".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
	ASSIGN aux_nrdconta = "1084178".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.

		ASSIGN aux_nrdconta = "41246".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "51020".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "63363".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "71773".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "72192".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "78760".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "82740".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "89079".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "90212".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "101591".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "104507".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "114324".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "116327".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "156400".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "158798".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "169692".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "508209".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "38733".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "38520".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "38490".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "37699".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "35793".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "30902".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "25020".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "24430".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "23388".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "22675".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "18422".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "18414".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "14818".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "13382".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "12750".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "12459".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "11827".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "11070".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "8249".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "7374".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "4405".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "4227".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		
		
		ASSIGN aux_nrdconta = "213".
        ASSIGN aux_nrregist = aux_nrregist + 1
               aux_dsdlinha = STRING(SUBSTRING(aux_nrdconta,1,7),"x(7)") +
                              STRING(SUBSTRING(aux_nrdconta,8,1),"x(1)")
                         
               aux_dsdlinha = aux_dsdlinha                  +
                              STRING(1)   +
                              aux_nrcpfcgc                  +
                              aux_nrcpfcg2                  +
                              "0120"                        +
                              "        ".

        PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
        PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
		

    END. 
	
    RUN fecha_arquivo.

    RUN fontes/fimprg.p.

END. /* Fim do FOR EACH DAS COOP */
/****************************** PROCEDURES **********************************/

PROCEDURE abre_arquivo.

   ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
          aux_nmarqimp = "coo409" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
          aux_nrregist = 0.
       
   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).

   /* header */
   ASSIGN aux_dsdlinha = "0000000"  +
                         STRING(crapcop.cdageitg,"9999") + 
                         STRING(crapcop.nrctaitg,"99999999") + 
                         "COO409  " + 
                         STRING(aux_nrtextab,"99999")  +
                         STRING(glb_dtmvtolt,"99999999")  +
                         STRING(crapcop.cdcnvitg,"999999999") + 
                         FILL(" ", 21).
    
   PUT STREAM str_1 aux_dsdlinha SKIP.

END PROCEDURE.


PROCEDURE fecha_arquivo.

   /* trailer */
                         /* total de registros + header + trailer */
   ASSIGN aux_nrregist = aux_nrregist + 2
          aux_dsdlinha = "9999999" + STRING(aux_nrregist,"999999999").
                         
   PUT STREAM str_1 aux_dsdlinha SKIP.

   OUTPUT STREAM str_1 CLOSE.

   /* verifica se o arquivo gerado nao tem registros "detalhe" */
   IF   aux_nrregist <= 2   THEN
        DO:
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
            LEAVE.        
        END.
        
   glb_cdcritic = 847.
   RUN fontes/critic.p.
            
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - COO409 - " + glb_cdprogra + "' --> '"  + 
                     glb_dscritic + " - " + aux_nmarqimp +  
                     " >> " + aux_nmarqlog).
   
   /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
   UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                     ' | tr -d "\032"' +  
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").  
            
   UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null"). 

   /* Atualizacao da craptab */
   FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "NRARQMVITG"   AND
                      craptab.tpregist = 409            NO-ERROR.
                   
   ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1,"99999").
   
END PROCEDURE.

/*...........................................................................*/

