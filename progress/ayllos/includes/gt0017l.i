/* ............................................................................

   Programa: Includes/gt0017l.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Isara - RKAM
   Data    : Maio/2011                    Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Listagem da Modalidade (Generico)

   Alteracoes: 
                
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    FOR EACH gnsbmod NO-LOCK,
       FIRST gnmodal NO-LOCK
       WHERE gnmodal.cdmodali = gnsbmod.cdmodali:

        CREATE tt-gnsbmod.
        ASSIGN tt-gnsbmod.cdmodsub = gnsbmod.cdmodali + gnsbmod.cdsubmod
               tt-gnsbmod.dsmodali = gnmodal.dsmodali
               tt-gnsbmod.dssubmod = gnsbmod.dssubmod.
    END.

    OPEN QUERY q_opcaol FOR EACH tt-gnsbmod.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE b_opcaol WITH FRAME f_listar.
        LEAVE.
    END.

    IF CAN-FIND(FIRST tt-gnsbmod) THEN
        EMPTY TEMP-TABLE tt-gnsbmod.

    LEAVE.

END.

/* F4, END ou FIM */
IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  
DO:
    HIDE FRAME f_listar.

    IF CAN-FIND(FIRST tt-gnsbmod) THEN
        EMPTY TEMP-TABLE tt-gnsbmod.

    NEXT.
END.

/* .......................................................................... */


