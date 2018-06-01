DEF  INPUT PARAM par_dsdsenha AS CHAR                           NO-UNDO.
DEF OUTPUT PARAM par_dssnhcla AS INTE                           NO-UNDO.

DEF VAR password      AS CHAR      NO-UNDO.
DEF VAR contador      AS INTE      NO-UNDO.

      
ASSIGN password = par_dsdsenha
       contador = 1
   par_dssnhcla = 0.

DO WHILE TRUE:

    IF  ENCODE(STRING(contador)) = password THEN
        LEAVE.
        
    IF  contador > 999999 THEN
        LEAVE.

    ASSIGN contador = contador + 1.
END.

IF  contador <= 999999 THEN
    ASSIGN par_dssnhcla = contador.