
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

/* para o relatorio de encerrados/reativados  */
DEF TEMP-TABLE w_contaitg                                            NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdsituac AS   INT 
    INDEX w_contaitg1   cdsituac cdagenci nrdconta.

DEF BUFFER crabass FOR crapass.
DEF BUFFER crabalt FOR crapalt.


FORM SKIP(1)
     "PA: " rel_dsagenci  FORMAT "x(21)"  
     SKIP(1)
     WITH NO-LABEL SIDE-LABEL WIDTH 80 FRAME f_cab_contaitg.

FORM w_contaitg.nrdconta    LABEL "Conta/DV"
     w_contaitg.nrdctitg    LABEL "Conta ITG."
     w_contaitg.nmprimtl    LABEL "Nome do Titular"
     WITH DOWN NO-LABELS WIDTH 80 FRAME f_contaitg.


ASSIGN glb_cdprogra = "crps503"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.
/* 
IF   glb_cdcritic > 0 THEN 
     RETURN.
*/
ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
     END.

/* Verifica o bloqueio do arquivo */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
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
FOR EACH crapalt WHERE crapalt.cdcooper  = glb_cdcooper
                   AND crapalt.dtaltera  = glb_dtmvtolt
                   NO-LOCK BY crapalt.nrdconta:

    IF  NOT (crapalt.dsaltera MATCHES "*exclusao conta-itg*"    AND
             CAN-DO("0,4",STRING(crapalt.flgctitg)))  THEN
        NEXT.
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = crapalt.nrdconta
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         NEXT.

    FIND crabass WHERE crabass.cdcooper = glb_cdcooper  AND
                       crabass.nrdconta = crapass.nrdconta
                       EXCLUSIVE-LOCK NO-ERROR.
                                              
    FIND crabalt WHERE crabalt.cdcooper = glb_cdcooper      AND
                       crabalt.nrdconta = crapalt.nrdconta  AND
                       crabalt.dtaltera = crapalt.dtaltera
                       EXCLUSIVE-LOCK NO-ERROR.

    ASSIGN crapass.dtectitg = glb_dtmvtolt   
           crapalt.flgctitg = 1.  /* Enviada */

    IF   crapalt.dsaltera MATCHES "*exclusao conta-itg*"    THEN
         DO:
             CREATE w_contaitg.
             ASSIGN w_contaitg.cdagenci = crapass.cdagenci
                    w_contaitg.nrdconta = crapass.nrdconta
                    w_contaitg.nrdctitg = crapass.nrdctitg
                    w_contaitg.nmprimtl = crapass.nmprimtl
                    w_contaitg.cdsituac = 1.
         END.  

     ASSIGN aux_nrcpfcgc = "00000000000000" 
            aux_nrcpfcg2 = "00000000000".                


    /* Resgistro w_contaitg.cdsituac (Quando 1- Encerrada, 2 - Reativada) */
    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)")
                     
           aux_dsdlinha = aux_dsdlinha                  +
                          STRING(w_contaitg.cdsituac)   +
                          aux_nrcpfcgc                  +
                          aux_nrcpfcg2                  +
                          "0120"                        +
                          "        ".

    PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
    PUT STREAM str_1  aux_dsdlinha FORMAT "x(63)" SKIP.
       
END.     /* Fim do FOR EACH */

RUN fecha_arquivo.

RUN rel_contasitg.

RUN fontes/fimprg.p.


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
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "NRARQMVITG"   AND
                      craptab.tpregist = 409            NO-ERROR.
                   
   ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1,"99999").
   
END PROCEDURE.


PROCEDURE rel_contasitg.

   ASSIGN aux_nmarqrel = "rl/crrl476_" + STRING(TIME) + ".lst".

   { includes/cabrel080_1.i }  /* Monta o cabecalho */
    
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.
    
   VIEW STREAM str_1 FRAME f_cabrel080_1.
       
   FOR EACH w_contaitg NO-LOCK USE-INDEX w_contaitg1
                                BREAK BY w_contaitg.cdsituac
                                         BY w_contaitg.cdagenci:
    
       IF   FIRST-OF(w_contaitg.cdsituac)   THEN
            DO:
                IF   w_contaitg.cdsituac = 1   THEN
                     PUT STREAM str_1 SKIP(1) "CONTAS ENCERRADAS:".
                ELSE     
                     PUT STREAM str_1 SKIP(1) "CONTAS REATIVADAS:". 
            END.
       
       IF   FIRST-OF(w_contaitg.cdagenci)   THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                                   crapage.cdagenci = w_contaitg.cdagenci
                                   NO-LOCK NO-ERROR.
                                
                rel_dsagenci = STRING(crapage.cdagenci,"zz9") + " - " +
                               crapage.nmresage.
                                
                DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_cab_contaitg.
                 
            END.
    
       IF   w_contaitg.cdsituac = 1   THEN
            aux_nrencerr = aux_nrencerr + 1. 
       ELSE
            aux_nrreativ = aux_nrreativ + 1.

       DISPLAY STREAM str_1 w_contaitg.nrdconta  w_contaitg.nrdctitg  
                            w_contaitg.nmprimtl  WITH FRAME f_contaitg.
            
       DOWN STREAM str_1 WITH FRAME f_contaitg.
        
       IF   LAST-OF(w_contaitg.cdsituac)   THEN
            DO:
                IF   w_contaitg.cdsituac = 1   THEN
                     PUT STREAM str_1 SKIP(2) "TOTAL DE CONTAS ENCERRADAS: "
                                              aux_nrencerr SKIP(1).
                ELSE
                     PUT STREAM str_1 SKIP(2) "TOTAL DE CONTAS REATIVADAS: "
                                              aux_nrreativ SKIP.             
            END.
   END.

   OUTPUT STREAM str_1 CLOSE.
    
   IF   aux_nrencerr = 0   AND   aux_nrreativ = 0   THEN
        DO:
            UNIX SILENT VALUE("rm " + aux_nmarqrel + " 2>/dev/null"). 
            LEAVE.        
        END.
    
   UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                     SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                     LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

   ASSIGN glb_nrcopias = 1
          glb_nmformul = "80col"
          glb_nmarqimp = aux_nmarqrel.
    
   RUN fontes/imprim.p. 

END PROCEDURE.

/*...........................................................................*/

