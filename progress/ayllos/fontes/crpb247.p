/*
  Alterações: 06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
*/

def var aux_qtcartao as int   extent 99    no-undo.
def var aux_contador as int                no-undo.
def var aux_nomeadm  as char               no-undo.
def var glb_cdcooper as int                no-undo.

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

/*  Verifica se a cooperativa esta cadastrada ............................... */
   
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                   USE-INDEX crapcop1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         MESSAGE "ERRO NO CRAPCOP".
         QUIT.
     END.


DEFINE TEMP-TABLE crattmp 
       FIELD cdagenci  AS INTEGER
       FIELD cdadmcrd  AS INTEGER
       FIELD quantida  AS INTEGER                     
       INDEX crattmp_1 AS PRIMARY cdadmcrd cdagenci.


for each crapass where crapass.cdcooper = crapcop.cdcooper
                       no-lock:

    aux_qtcartao = 0.
        
    for each crapcrd where crapcrd.cdcooper = crapcop.cdcooper and
                           crapcrd.nrdconta = crapass.nrdconta no-lock:
         
        IF   crapcrd.cdmotivo <> 0 OR 
             crapcrd.dtcancel <> ? THEN
             NEXT.
         
        find crattmp where crattmp.cdagenci = crapass.cdagenci    and
                           crattmp.cdadmcrd = crapcrd.cdadmcrd
                          no-error.

       if   not available crattmp then
            do:
               CREATE crattmp.
               ASSIGN crattmp.cdagenci = crapass.cdagenci
                      crattmp.cdadmcrd = crapcrd.cdadmcrd.
            end.

       assign crattmp.quantida = crattmp.quantida + 1.
            
    end.        
            
end.
 

for each crattmp BREAK BY crattmp.cdadmcrd by crattmp.cdagenci:
        
   IF   FIRST-OF(crattmp.cdadmcrd) THEN
        DO:
            find crapadc where crapadc.cdcooper = crapcop.cdcooper and
                               crapadc.cdadmcrd = crattmp.cdadmcrd
                               use-index crapadc1 no-lock no-error.
   
            if   not available crapadc then
                 do:
                    message "administradora nao existe".
                    pause.
                    quit. 
                 end.
            else
                 aux_nomeadm = crapadc.nmresadm. 
        END.
   
   disp aux_nomeadm      column-label "Administradora" format "x(20)"
        crattmp.cdagenci column-label "PA" FORMAT "zz9"
        crattmp.quantida(total by crattmp.cdadmcrd) 
        column-label "Quantidade" format "zz,zz9"
        with down centered title "Quantidade de Cartao de Credito - " +
                            STRING(today,"99/99/9999") + " - " +
                            STRING(crapcop.nmrescop,"x(11)").
   down.                         

end.

pause.
quit.
