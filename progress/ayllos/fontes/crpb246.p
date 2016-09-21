def var qtdade as int.
def var descri as char format "x(40)".
def var glb_cdcooper as int.

qtdade = 0.

DEFINE TEMP-TABLE crattmp 
       FIELD cdagenci  AS INTEGER
       FIELD quantida  AS INTEGER                     
       INDEX crattmp_1 AS PRIMARY cdagenci.


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

for each crapass where crapass.cdcooper = crapcop.cdcooper NO-LOCK:

    qtdade = 0.
    
    for each crapcrm WHERE crapcrm.cdcooper = glb_cdcooper     and
                           crapcrm.nrdconta = crapass.nrdconta no-lock:

        if  crapcrm.cdsitcar <> 2 then
            next.

        qtdade = qtdade + 1.
        
    end.
     
    find crattmp where crattmp.cdagenci = crapass.cdagenci no-error.

    if   not available crattmp then
         do:
             CREATE crattmp.
             ASSIGN crattmp.cdagenci = crapass.cdagenci.
         end.

    assign crattmp.quantida = crattmp.quantida + qtdade.
end.


for each crattmp BREAK by crattmp.cdagenci:

    find crapage where crapage.cdcooper = crapcop.cdcooper and
                       crapage.cdagenci = crattmp.cdagenci 
                       USE-INDEX crapage1 no-lock.
 
    descri = string(crapage.cdagenci,"999") + " - " + crapage.nmresage.

    disp descri column-label "PA"
         crattmp.quantida(total) column-label "Quantidade"
         with centered title "Quantidade de Cartao Magnetico - " +
                             STRING(today,"99/99/9999") + " - " +
                             STRING(crapcop.nmrescop,"x(11)").
        
end.

pause.
quit.
