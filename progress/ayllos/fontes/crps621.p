/* ............................................................................

   Programa: Fontes/crps621.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Marco/2012.                       Ultima atualizacao: 15/01/2014.
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : MOVE OS ARQ. DE CONCILIACAO DE TITULO NR P/ AS COOPERATIVAS
               Executado pelos scripts:
                ftpabbc_recebe_retorno1.pl
                ftpabbc_recebe_retorno1_manual.pl
                ftpabbc_recebe_retorno2.pl
                ftpabbc_recebe_retorno2_manual.pl

   Alteracoes: 29/03/2012 - Tratar arquivos devolução .DVN (Guilherme).
   
               19/04/2012 - Logar todo o procedimento do programa para o 
                            crps621.log (Guilherme).
                            
               23/04/2012 - Parametro de sessao com o tipo de retorno do script
                          - Remocao do log da alteracao acima (Guilherme).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).           
                            
               15/01/2014 - Alterado descricao da critica ao nao encontrar 
                            agencia do PA. (Reinert)                            
............................................................................ */

DEF STREAM str_1.

DEF VAR glb_cdcooper AS INTE NO-UNDO.
DEF VAR glb_cdprogra AS CHAR INIT "crps621" NO-UNDO.
DEF VAR glb_dscritic AS CHAR NO-UNDO.
DEF VAR aux_mes      AS CHAR NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR NO-UNDO.
DEF VAR aux_setlinha AS CHAR NO-UNDO.
DEF VAR aux_dsdlinha AS CHAR NO-UNDO.
DEF VAR aux_cdagepac AS INTE NO-UNDO.
DEF VAR aux_dsarquiv AS CHAR NO-UNDO.
DEF VAR aux_tpretorn AS CHAR NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

ASSIGN aux_tpretorn = STRING(SESSION:PARAMETER)
       glb_cdcooper = 3.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop THEN
    DO:
         glb_dscritic = "Registro de cooperativa nao encontrado".
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + 
                           " >> /usr/coop/cecred/log/proc_batch.log").
         RETURN.
    END.

FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapdat THEN
     DO:
         glb_dscritic = "Registro de data nao encontrado".
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + 
                           " >> /usr/coop/" + crapcop.dsdircop +
                           "/log/proc_batch.log").
         RETURN.
     END.                   
     
IF   MONTH(crapdat.dtmvtolt) > 9 THEN
     CASE MONTH(crapdat.dtmvtolt):
          WHEN 10 THEN aux_mes = "O".
          WHEN 11 THEN aux_mes = "N".
          WHEN 12 THEN aux_mes = "D".
     END CASE.
ELSE
     aux_mes = STRING(MONTH(crapdat.dtmvtolt),"9").     

/* Tipo de retorno 1 - ARQUIVOS REMESSA */
IF  aux_tpretorn = "REM" THEN
DO:
    
    ASSIGN aux_dsarquiv = "/usr/coop/cecred/integra/2*" + 
                          aux_mes +
                          STRING(DAY(crapdat.dtmvtolt),"99") + ".REM".
    
    /*  Verifica se existe arquivo a serem integrado  */
    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dsarquiv + 
                                   " 2>> /dev/null | wc -l") NO-ECHO.
                           
    SET STREAM str_1 aux_setlinha FORMAT "x(10)" WITH NO-BOX NO-LABELS.
    
    INPUT STREAM str_1 CLOSE.
    
    IF  INT(aux_setlinha) > 0  THEN
    DO:
        /* lista arquivos */
        INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dsarquiv + 
                                   " 2> /dev/null") NO-ECHO.
        
        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        
           SET STREAM str_1 aux_setlinha FORMAT "x(70)" WITH NO-BOX NO-LABELS.
           
           ASSIGN aux_nmarquiv = SUBSTR(aux_setlinha,
                                 R-INDEX(aux_setlinha,"/") + 1,
                                 LENGTH(aux_setlinha))
                  aux_cdagepac = INTE(SUBSTR(aux_nmarquiv,2,4)).
    
           FIND crapage WHERE crapage.cdagepac = aux_cdagepac NO-LOCK NO-ERROR. 
           
           IF  NOT AVAIL crapage  THEN
               DO:
                 glb_dscritic = "Registro da agencia do PA nao encontrado: " +
                                STRING(aux_cdagepac).
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '"  +
                                   glb_dscritic + 
                                   " >> /usr/coop/" + crapcop.dsdircop +
                                   "/log/proc_batch.log").
                 NEXT.      
               END.
        
           FIND crabcop WHERE crabcop.cdcooper = crapage.cdcooper NO-LOCK NO-ERROR.
        
           IF  NOT AVAILABLE crabcop THEN
               DO:
                  glb_dscritic = "Cooperativa do PA " + STRING(crapage.cdagepac) +  
                                 " nao encontrada: " + STRING(crapage.cdcooper).
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '"  +
                                    glb_dscritic + 
                                    " >> /usr/coop/" + crapcop.dsdircop +
                                   "/log/proc_batch.log").
                  NEXT.
               END.
    
           /* copia arquivo para o integra da cooperativa "dona" do arquivo */
           UNIX SILENT VALUE("cp " + aux_setlinha + 
                             " /usr/coop/" + crabcop.dsdircop + "/integra/" +
                             aux_nmarquiv + 
                             " 1>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log" +
                             " 2>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log").
           UNIX SILENT VALUE("mv " + aux_setlinha + 
                             " /usr/coop/" + crabcop.dsdircop + "/integra/" +
                             aux_nmarquiv +
                             " 1>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log" +
                             " 2>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log").
           
        END.  
                 
        INPUT STREAM str_1 CLOSE.
    
    END.

END.
ELSE
/* Tipo de retorno 2 - ARQUIVOS DEVOLUCAO */
IF  aux_tpretorn = "DVN"  THEN
DO:
    ASSIGN aux_dsarquiv = "/usr/coop/cecred/integra/2*" + 
                          aux_mes +
                          STRING(DAY(crapdat.dtmvtolt),"99") + ".DVN".
    
    /*  Verifica se existe arquivo a serem integrado  */
    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dsarquiv + 
                                   " 2>> /dev/null | wc -l") NO-ECHO.
                           
    SET STREAM str_1 aux_setlinha FORMAT "x(10)" WITH NO-BOX NO-LABELS.
    
    INPUT STREAM str_1 CLOSE.
    
    /* Se encontrou algum arquivo */
    IF  INT(aux_setlinha) > 0  THEN
    DO:
        /* lista arquivos */
        INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dsarquiv + 
                                       " 2> /dev/null") NO-ECHO.
                               
        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        
           SET STREAM str_1 aux_setlinha FORMAT "x(70)" WITH NO-BOX NO-LABELS.
           
           ASSIGN aux_nmarquiv = SUBSTR(aux_setlinha,
                                 R-INDEX(aux_setlinha,"/") + 1,
                                 LENGTH(aux_setlinha))
                  aux_cdagepac = INTE(SUBSTR(aux_nmarquiv,2,4)).
    
           FIND crapage WHERE crapage.cdagepac = aux_cdagepac NO-LOCK NO-ERROR. 
           
           IF  NOT AVAIL crapage  THEN
               DO:
                 glb_dscritic = "Registro de PA nao encontrado: " +
                                STRING(aux_cdagepac).
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '"  +
                                   glb_dscritic + 
                                   " >> /usr/coop/" + crapcop.dsdircop +
                                   "/log/proc_batch.log").
                 NEXT.      
               END.
        
           FIND crabcop WHERE crabcop.cdcooper = crapage.cdcooper NO-LOCK NO-ERROR.
        
           IF  NOT AVAILABLE crabcop THEN
               DO:
                  glb_dscritic = "Cooperativa do PA " + STRING(crapage.cdagepac) +  
                                 " nao encontrada: " + STRING(crapage.cdcooper).
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '"  +
                                    glb_dscritic + 
                                    " >> /usr/coop/" + crapcop.dsdircop +
                                   "/log/proc_batch.log").
                  NEXT.
               END.
           
           /* copia arquivo para o integra da cooperativa "dona" do arquivo */
           UNIX SILENT VALUE("cp " + aux_setlinha + 
                             " /usr/coop/" + crabcop.dsdircop + "/integra/" +
                             aux_nmarquiv + 
                             " 1>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log" +
                             " 2>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log").
           UNIX SILENT VALUE("mv " + aux_setlinha + 
                             " /usr/coop/" + crabcop.dsdircop + "/integra/" +
                             aux_nmarquiv + 
                             " 1>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log" +
                             " 2>>/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log").
           
        END.
    
        INPUT STREAM str_1 CLOSE.
    
    END.
END.
/* ......................................................................... */
