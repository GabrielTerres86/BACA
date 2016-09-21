def stream str_1.

def var aux_contador        as int        no-undo.
def var aux_linhas          as int        no-undo.
def var aux_nmusuari        as char       no-undo.

def temp-table lock  no-undo
    field contador     as int
    field qtcap        as int                  format "zzz9"
    field Lock-Name    like _lock._Lock-Name   format "x(8)"
    field User-Id      like _lock._Lock-Usr    format "9999"
    field nmusuari     as char                 format "x(20)"
    field file-name    like _file._file-name   format "x(10)"
    field Lock-RecId   like _lock._Lock-RecId  format "zzzzzzzzzzzzzzzz9"
    field Lock-Flags   like _lock._Lock-Flags  format "x(2)".

empty temp-table lock.

do  while true on endkey undo, leave:

    aux_contador = aux_contador + 1.
    
    disp aux_contador label "Capturas Totais" with side-labels.
    
    for each _lock no-lock:
    
        if _lock._Lock-RecId = ? then
           leave.
           
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
               find first _file where _file._file-number = _lock._Lock-Table
                                      no-lock.

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
               
               create lock.
               assign lock.contador   = aux_contador
                      lock.qtcap      = 1
                      lock.Lock-Name  = _lock._Lock-Name
                      lock.User-id    = _lock._Lock-Usr
                      lock.nmusuari   = aux_nmusuari                                                   lock.file-name  = _file._file-name
                      lock.Lock-RecId = _lock._Lock-RecId
                      lock.Lock-Flags = _lock._Lock-Flags.
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
             lock.User-Id     column-label "ID"
             lock.Lock-Name   column-label "Usuario"
             lock.nmusuari    column-label "Nome"
             lock.file-name   column-label "Tabela"
             lock.Lock-RecId  column-label "RECID"
             lock.Lock-Flags  column-label "LOCK"
             with down frame f_locks.
    end.
    
    pause 2 no-message.
end.

QUIT.
