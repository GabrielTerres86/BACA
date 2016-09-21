{ /usr/coop/sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_dstrecho AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_desdiret AS CHAR EXTENT 31                                 NO-UNDO.
DEF VAR aux_nmarqgre AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqtmp AS CHAR                                           NO-UNDO.
DEF VAR aux_ponteiro AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR aux_dsargumt AS CHAR                                           NO-UNDO.
DEF VAR aux_fonteant AS CHAR                                           NO-UNDO.
DEF VAR aux_tamanhop AS CHAR                                           NO-UNDO.

ASSIGN aux_desdiret[1]  = "/usr/coop/sistema/ayllos/fontes/*.p"
       aux_desdiret[2]  = "/usr/coop/sistema/ayllos/includes/*.i"
       aux_desdiret[3]  = "/usr/coop/sistema/siscaixa/web/*.html"
       aux_desdiret[4]  = "/usr/coop/sistema/siscaixa/web/*.htm"
       aux_desdiret[5]  = "/usr/coop/sistema/siscaixa/web/*.w"
       aux_desdiret[6]  = "/usr/coop/sistema/siscaixa/web/*.p"
       aux_desdiret[7]  = "/usr/coop/sistema/siscaixa/web/dbo/*.p"
       aux_desdiret[8]  = "/usr/coop/sistema/internet/procedures/*.p"
       aux_desdiret[9]  = "/usr/coop/sistema/internet/includes/*.i"
       aux_desdiret[10] = "/usr/coop/sistema/internet/fontes/*.html"
       aux_desdiret[11] = "/usr/coop/sistema/internet/fontes/*.htm"
       aux_desdiret[12] = "/usr/coop/sistema/internet/fontes/*.w"
       aux_desdiret[13] = "/usr/coop/sistema/internet/fontes/*.p"
       aux_desdiret[14] = "/usr/coop/sistema/generico/procedures/*.p"
       aux_desdiret[15] = "/usr/coop/sistema/generico/includes/*.i"
       aux_desdiret[16] = "/usr/coop/sistema/progrid/web/dbo/*.p"          
       aux_desdiret[17] = "/usr/coop/sistema/progrid/web/fontes/*.i"       
       aux_desdiret[18] = "/usr/coop/sistema/progrid/web/fontes/*.html"    
       aux_desdiret[19] = "/usr/coop/sistema/progrid/web/fontes/*.htm"     
       aux_desdiret[20] = "/usr/coop/sistema/progrid/web/fontes/*.w"       
       aux_desdiret[21] = "/usr/coop/sistema/progrid/web/fontes/*.p"       
       aux_desdiret[22] = "/usr/coop/sistema/progrid/web/includes/*.i"     
       aux_desdiret[23] = "/usr/coop/sistema/progrid/web/zoom/*.i"         
       aux_desdiret[24] = "/usr/coop/sistema/progrid/web/zoom/*.html"      
       aux_desdiret[25] = "/usr/coop/sistema/progrid/web/zoom/*.htm"       
       aux_desdiret[26] = "/usr/coop/sistema/progrid/web/zoom/*.w"         
       aux_desdiret[27] = "/usr/coop/sistema/progrid/web/zoom/*.p"         
       aux_desdiret[28] = "/usr/coop/sistema/TAA/*.p"
       aux_desdiret[29] = "/usr/coop/sistema/TAA/local/*.w"
       aux_desdiret[30] = "/usr/coop/sistema/TAA/local/includes/*.i"
       aux_desdiret[31] = "/usr/coop/sistema/TAA/local/procedures/*.p".
              

ASSIGN aux_dstrecho = ENTRY(1, SESSION:PARAMETER, ":")
       aux_nmarqgre = ENTRY(2, SESSION:PARAMETER, ":")
       aux_dsargumt = ENTRY(3, SESSION:PARAMETER, ":").

OUTPUT TO VALUE(TRIM(aux_nmarqgre)).

DO aux_contador = 1 TO 31:
                 
    INPUT STREAM str_1 THROUGH 
       VALUE('grep ' + aux_dsargumt + ' "' + aux_dstrecho + '" ' + 
             aux_desdiret[aux_contador] + ' 2> /dev/null') NO-ECHO.
      
    /* Pesquisa nos fontes do Progress */
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       IMPORT STREAM str_1 UNFORMATTED aux_dsdlinha.
      
       aux_tamanhop = '"x(' + STRING(LENGTH(TRIM(aux_dsdlinha))) + ')"'.

       PUT aux_dsdlinha FORMAT aux_tamanhop SKIP.
             
    END. 

    INPUT STREAM str_1 CLOSE.
END.
    
    /* Pesquisa nos fontes do Oracle */
    RUN STORED-PROC 
           {&sc2_dboraayl}.send-sql-statement aux_ponteiro = PROC-HANDLE
    ("SELECT type||'/'||name||': '||ltrim(replace(text,chr(9),' ')) " +
     "  from all_source "                                   +
     " where lower(owner) = 'cecred' "                      +
     "   and lower(text) like lower('%'||replace('" + aux_dstrecho + "',' ','%')||'%')" +
     "   and lower(type) <> 'trigger' " +
     " order by type ").

    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
                 
        IF INDEX(aux_dsargumt, "l") > 0 THEN
           DO: 
              IF  ENTRY(1,  TRIM(proc-text), ":") <> aux_fonteant THEN
                  PUT ENTRY(1,  TRIM(proc-text), ":")  FORMAT "x(78)" SKIP.
               
              aux_fonteant = ENTRY(1,  TRIM(proc-text), ":").    
           END.   
        ELSE
           DO:
              aux_tamanhop = '"x(' + STRING(LENGTH(TRIM(proc-text))) + ')"'.
              PUT TRIM(proc-text)  FORMAT aux_tamanhop SKIP.
           END.
    END.
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement WHERE PROC-HANDLE = aux_ponteiro.


OUTPUT CLOSE.

QUIT.
