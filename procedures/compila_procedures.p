DEF STREAM str_1.

DEF VAR aux_nmprogra AS CHAR        NO-UNDO.

INPUT STREAM str_1 THROUGH VALUE ("dir *.p /b") NO-ECHO.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IMPORT STREAM str_1 UNFORMATTED aux_nmprogra.

    IF  aux_nmprogra = "compila_procedures.p"  THEN
        NEXT.

    COMPILE VALUE(aux_nmprogra) SAVE.
END.


