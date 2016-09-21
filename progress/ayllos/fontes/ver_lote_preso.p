def stream str_1.

def var aux_contador        as int        no-undo.
def var aux_linhas          as int        no-undo.
def var aux_nmusuari        as char       no-undo.

def temp-table lock  no-undo
    field contador     as int
    field qtcap        as int                  format "zzz9"
    field Lock-Name    like _lock._Lock-Name   format "x(8)"
    field User-Id      like _lock._Lock-Usr    format "999"
    field nmusuari     as char                 format "x(20)"
    field nrdolote     like craplot.nrdolote   format "zzz,zz9"
    field cdbccxlt     like craplot.cdbccxlt   format "z,zz9"
    field cdagenci     like craplot.cdagenci   format "zz9"
    field tplotmov     like craplot.tplotmov   format "z,zz9"
    field Lock-RecId   as recid                format "zzzzzzzzzzz9".
empty temp-table lock.

do  while true on endkey undo, leave:

    aux_contador = aux_contador + 1.
    
    disp aux_contador label "Capturas Totais" with side-labels.
    
    find _file where _file._file-name = "craplot" no-lock.
    
    for each _lock no-lock:
    
        if _lock._Lock-RecId = ?  then
           leave.

        if _lock._lock-table <> _file._file-num then
           next.
           
        find lock where lock.Lock-Name  = _lock._Lock-Name and
                        lock.Lock-RecId = _lock._Lock-RecId
                        exclusive-lock no-error.
                        
        if avail lock then
           do:
               assign lock.qtcap    = lock.qtcap + 1
                      lock.contador = aux_contador.
               release lock.
               next.
           end.
        else
           do:
               /* pega o nome do usuario */
               INPUT STREAM str_1 THROUGH 
                     VALUE( "pwget -n " + _lock._Lock-Name + " 2> /dev/null")
                     NO-ECHO.
                                          
               DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

                  IMPORT STREAM str_1 UNFORMATTED aux_nmusuari.
               END.
               
               INPUT STREAM str_1 CLOSE.
               
               assign aux_nmusuari = substring(aux_nmusuari,34)
                      aux_nmusuari = entry(1,aux_nmusuari,":").
               
               find craplot where recid(craplot) = _lock._Lock-RecId 
                                  no-lock no-error.
                                  
               create lock.
               assign lock.contador   = aux_contador
                      lock.qtcap      = 1
                      lock.Lock-Name  = _lock._Lock-Name
                      lock.User-id    = _lock._Lock-Usr
                      lock.nmusuari   = aux_nmusuari                                                 lock.Lock-RecId = _lock._Lock-RecId
                      lock.nrdolote   = craplot.nrdolote
                      lock.cdagenci   = craplot.cdagenci
                      lock.cdbccxlt   = craplot.cdbccxlt
                      lock.tplotmov   = craplot.tplotmov.
           end.
    end.
    
    /* limpa os liberados */
    for each lock where lock.contador < aux_contador:
        delete lock.
    end.
    
    hide frame f_locks.
    for each lock by lock.qtcap desc  
                    by lock.Lock-Name
                       aux_linhas = 1 to 14:

        disp lock.qtcap       column-label "Capturas"
             lock.Lock-Name   column-label "Usuario"
             lock.nmusuari    column-label "Nome"
             lock.nrdolote    column-label "LOTE"
             lock.cdagenci    column-label "PAC"
             lock.cdbccxlt    column-label "Bc/Cx"
             lock.tplotmov    column-label "Tipo"
             lock.Lock-RecId  column-label "RecId"
             with down frame f_locks.
    end.
    
    pause 2 no-message.
end.

QUIT.
