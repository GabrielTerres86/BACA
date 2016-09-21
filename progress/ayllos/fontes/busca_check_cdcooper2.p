/**************
fonte original fontes/check_cdcooper2.p - Guilherme
**************/
def input param par_nmsistem as char        no-undo.
def input param par_nmprogra as char        no-undo.
def input param par_camifull as char        no-undo.
def input param par_tipodout as log         no-undo.

if   par_nmsistem = ""   then
     do:
         message "O sistema deve ser informado!!!" view-as alert-box.
         leave.
     end.
     
if   par_nmprogra = ""   then
     do:
         message "O programa deve ser informado!!!" view-as alert-box.
         leave.
     end.   

def stream str_1.

def var tel_dsarquiv as char    view-as editor inner-chars 80 inner-lines 10
                                               no-box pfcolor 0
                                               no-undo.
                                               
def var aux_dsdlinha as char no-undo.
def var aux_confirma as log  no-undo.
def var aux_opened   as char no-undo.

def temp-table w_buscas     no-undo
    field fonte  as char
    field linha  as inte
    field tabela as char
    field chk    as logical.
    
def query q_buscas for w_buscas.

def browse b_buscas query q_buscas
    display w_buscas.linha  column-label "Linha"    format "zz,zz9"
            w_buscas.tabela column-label "Tabela"   format "x(25)"
            w_buscas.fonte  column-label "Fonte"    format "x(35)"
            w_buscas.chk    column-label "Check"    format "OK/ "
            with 5 down title " Programa: " + par_nmprogra + " ".

                                                 
form b_buscas
     SKIP
     "########################################"
     "########################################" at 41
     SKIP
     tel_dsarquiv
     SKIP
     "########################################"
     "########################################" at 41
     with no-labels side-labels no-box frame f_fonte.
                                                
/* Recarrega as buscas */
on entry of b_buscas in frame f_fonte do:

   close query q_buscas.
   open query q_buscas for each w_buscas no-lock.
end.



/* Posiciona na linha */
on return of b_buscas in frame f_fonte do:

   def var aux_caminho as char   no-undo.
   
   if   w_buscas.fonte = ""   then
        do:
            if   par_nmsistem = "ayllos"   then
                 aux_caminho = "/usr/coop/sistema/ayllos/fontes/" +
                               par_nmprogra.
        end.
   else
        do:
            if   par_nmsistem = "ayllos"   then
                 aux_caminho = "/usr/coop/sistema/ayllos/includes/" +
                               w_buscas.fonte.
        end.

   if   aux_opened <> par_camifull  OR
        tel_dsarquiv = ""           then
        do:
            tel_dsarquiv:read-file(par_camifull).
            aux_opened = par_camifull.
        end.
 
   tel_dsarquiv:cursor-line = w_buscas.linha.
   w_buscas.chk = YES.

   /* joga o cursor para o fonte */
   apply "tab".
end.

/* Posiciona na linha */
on return of tel_dsarquiv in frame f_fonte do:
   apply "tab".
end.





/* verifica se existe restricoes */
if   search("/tmp/check_cdcooper.lst") = ?   then
     do:
         hide frame f_fonte no-pause.
         return "OK".
     end.
     

empty temp-table w_buscas.

/* busca as linhas com problemas no arquivo */
input stream str_1 from 
     value("/tmp/check_cdcooper.lst") no-echo.
     
/* despreza a primeira linha pois eh o nome do programa */
import stream str_1 unformatted aux_dsdlinha.
if  not par_tipodout then /* arquivo */
OUTPUT TO VALUE("/tmp/cdcoopersis.log") APPEND.    

do while true on endkey undo, leave on error undo, leave:

    import stream str_1 unformatted aux_dsdlinha.
    
    aux_dsdlinha = TRIM(aux_dsdlinha).

    if   aux_dsdlinha = ""   then
         leave.

    create w_buscas.
    
    int(entry(1,aux_dsdlinha," ")) no-error.
    
    if   error-status:error   then
         assign w_buscas.fonte  = entry(1,aux_dsdlinha," ")
                w_buscas.linha  = int(entry(2,aux_dsdlinha," "))
                w_buscas.tabela = entry(4,aux_dsdlinha," ")
                w_buscas.chk    = NO.
    else
         assign w_buscas.fonte  = ""
                w_buscas.linha  = int(entry(1,aux_dsdlinha," "))
                w_buscas.tabela = entry(3,aux_dsdlinha," ")
                w_buscas.chk    = NO.

    if  not par_tipodout then /* arquivo */
        DISP "Fonte: " + par_camifull + 
             " Linha: " + string(w_buscas.linha) + 
             " Tabela: " + w_buscas.tabela
             FORMAT "x(234)" WITH WIDTH 234 NO-BOX NO-LABEL.  
end.
if  not par_tipodout then /* arquivo */
output close.                             

input stream str_1 close.     
if par_tipodout then /* tela */
do:
tel_dsarquiv:read-only in frame f_fonte = yes.

do while true:

   do while true on endkey undo, leave:
    
      update b_buscas
             tel_dsarquiv with frame f_fonte.
      leave.
   end.
   
   if   can-find(first w_buscas where w_buscas.chk = no no-lock)   then
        do:
            aux_confirma = false.
            do  while true on endkey undo, retry:
                message "Ainda existem linhas nao verificadas, abandonar?"
                        update aux_confirma format "S/N".
                leave.
            end.
                    
            if aux_confirma then
               do:
                   hide frame f_fonte no-pause.
                   return "NOK".
               end.
            else
               next.
        end.
        
   leave.
end.

aux_confirma = false.
do  while true on endkey undo, retry:
    message "O programa foi inteiramente verificado. Deseja continuar?"
            update aux_confirma format "S/N".
    leave.
end.
                    
hide frame f_fonte no-pause.

if aux_confirma then
   return "OK".
else
   return "NOK".
end.
else
return "OK".

