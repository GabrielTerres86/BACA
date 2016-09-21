{includes/var_batch.i "new" }
{sistema/generico/includes/var_internet.i }
{sistema/generico/includes/b1wgen0034.i }
DEF VAR h-b1wgen0034 AS HANDLE                                         NO-UNDO.

RUN sistema/generico/procedures/b1wgen0034.p PERSISTENT 
        SET h-b1wgen0034.

IF  NOT VALID-HANDLE(h-b1wgen0034)  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                          "Handle Invalido para BO b1wgen0004" +
                          " >> log/proc_batch.log").
     END.
        
     FOR EACH tt-erro:
         DELETE tt-erro.
     END.
    
find first crapcop no-lock no-error.
RUN gera_table_drm IN h-b1wgen0034 (INPUT crapcop.cdcooper,
                                    INPUT 07/31/2008,
                                    OUTPUT TABLE w_drm,
                                    OUTPUT TABLE tt-erro).
            
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
        IF  AVAILABLE tt-erro  THEN
            message "magui erro".
    END.

RUN gera_arquivo_drm IN h-b1wgen0034 (INPUT 07/31/2008,
                                      INPUT TABLE w_drm).

DELETE PROCEDURE h-b1wgen0034.

output to rl/drm_31072008.lst.
for each w_drm no-lock:
    disp w_drm.
end.
output close.    
