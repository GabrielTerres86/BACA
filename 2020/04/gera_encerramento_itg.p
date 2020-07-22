
{ includes/var_batch.i new}  
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



FOR EACH crapcop WHERE CAN-DO("1,2,6,7,8,9,10,11,14,16",STRING(crapcop.cdcooper)) NO-LOCK:
   
    RUN fontes/iniprg.p.
    /* 
    IF   glb_cdcritic > 0 THEN 
         RETURN.
    */
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

