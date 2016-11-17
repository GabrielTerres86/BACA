def stream str_1.

def var aux_dsdlinha as char   no-undo.

def temp-table servicos        no-undo
    field cdcooper as int
    field nmservic as char
    field dsstatus as char
    field agativos as int
    field agdispon as int
    index servicos1 cdcooper nmservic.
    
def query q_servicos for servicos.
    
def browse b_servicos query q_servicos
    display servicos.nmservic column-label "Servico"           FORMAT "x(32)"
            servicos.dsstatus column-label "Status"            FORMAT "x(10)"
            servicos.agativos column-label "Agentes Ativos"    FORMAT "zzz9"
            servicos.agdispon column-label "Agentes Dispon."   FORMAT "zzz9"
            with 17 down no-box.
    
form b_servicos help
     "ENTER-Ativ./Desativ.|A-Atualiz.|U-Ativ.TODOS|D-Desativ.TODOS"
     with title " Status dos Sevicos WebSpeed " frame f_servicos.
     
on any-key of b_servicos in frame f_servicos do:
     
   def var aux_nrdlinha as int  no-undo.
   
   if   keyfunction(lastkey) = "return"   then
        do:
            if   servicos.dsstatus = "FORA"   then
                 do:
                     message "Ativando servico...".
                     unix silent value("wtbman -i " + servicos.nmservic + 
                                       " -start > /dev/null").
                 end.
            else
                 do:
                     message "Desativando servico...".
                     unix silent value("wtbman -i " + servicos.nmservic + 
                                       " -stop > /dev/null").
                 end.
                 
                     hide message no-pause.

            message "Verificando servico...".
            run verifica_servico(INPUT servicos.cdcooper,
                                 INPUT servicos.nmservic).
        end.
   else
   if   keyfunction(lastkey) = "a"   then
        run carrega_servicos.
   else
   if   keyfunction(lastkey) = "u"   then
        do:
            for each servicos no-lock:

                hide message no-pause.
                message "Ativando TODOS os servicos (" +
                        servicos.nmservic +
                        ")...".

                unix silent value("wtbman -i " + servicos.nmservic + 
                                  " -start > /dev/null").
            end.
            
            run carrega_servicos.
        end.
   else
   if   keyfunction(lastkey) = "d"   then
        do:
            for each servicos no-lock:

                hide message no-pause.
                message "Destivando TODOS os servicos (" +
                        servicos.nmservic +
                        ")...".
                        
                unix silent value("wtbman -i " + servicos.nmservic + 
                                  " -stop > /dev/null").
            end.
            
            run carrega_servicos.
        end.
   else
        return.
   
   hide message no-pause.
   aux_nrdlinha = CURRENT-RESULT-ROW("q_servicos").
   close query q_servicos.
   open query q_servicos for each servicos.
   REPOSITION q_servicos TO ROW aux_nrdlinha.
end.



run carrega_servicos.

hide message no-pause.
open query q_servicos for each servicos.

do  while true on endkey undo, leave:

    update b_servicos with frame f_servicos.
    leave.
end.

quit.



procedure carrega_servicos:

    empty temp-table servicos.

    for each crapcop no-lock:

        hide message no-pause.
        message "Verificando a cooperativa" crapcop.nmrescop + "...".
    
        run verifica_servico (INPUT crapcop.cdcooper,
                              INPUT crapcop.dsdircop).
    
        run verifica_servico (INPUT crapcop.cdcooper,
                              INPUT "progrid_" + crapcop.dsdircop).
    
        /* servico para internet independente na viacredi */
        if   crapcop.cdcooper = 1   then
             run verifica_servico (INPUT crapcop.cdcooper,
                                   INPUT crapcop.dsdircop + "_ib").

        if   (crapcop.cdcooper = 1)  OR  (crapcop.cdcooper = 2) OR
             (crapcop.cdcooper = 4)  then
             run verifica_servico (INPUT crapcop.cdcooper,
                                   INPUT "aut_" + crapcop.dsdircop).
                                   
        /* servico do TAA - cecred */
        if   crapcop.cdcooper = 3   then
             run verifica_servico (INPUT crapcop.cdcooper,
                                   INPUT "ws_TAA").
    
    end.

end procedure.


procedure verifica_servico:
    def input param par_cdcooper as int     no-undo.
    def input param par_nmservic as char    no-undo.

    find servicos where servicos.cdcooper = par_cdcooper and
                        servicos.nmservic = par_nmservic
                        exclusive-lock no-error.
                        
    if   not available servicos   then                        
         create servicos.
         
    assign servicos.cdcooper = par_cdcooper
           servicos.nmservic = par_nmservic
           servicos.dsstatus = "FORA"
           servicos.agativos = 0
           servicos.agdispon = 0.
    
    INPUT STREAM str_1 THROUGH VALUE("wtbman -i " + par_nmservic + " -q")
          NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       import STREAM str_1 unformatted aux_dsdlinha.
       
       if   aux_dsdlinha matches "*broker status*"   then
            do:
                servicos.dsstatus = 
                     trim(substring(aux_dsdlinha,index(aux_dsdlinha,":") + 1)).
                
                if   servicos.dsstatus = "ACTIVE"   then
                     servicos.dsstatus = "OK".
            end.
            
       if   aux_dsdlinha matches "*active agents*"   then
            servicos.agativos = 
                     int(substring(aux_dsdlinha,index(aux_dsdlinha,":") + 1)).

       if   aux_dsdlinha matches "*available agents*"   then
            servicos.agdispon =
                     int(substring(aux_dsdlinha,index(aux_dsdlinha,":") + 1)).
    end.

end procedure.