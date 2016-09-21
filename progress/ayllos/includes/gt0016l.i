/* ............................................................................

   Programa: Includes/gt0016l.i
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

    FOR EACH gnmodal NO-LOCK:
        CREATE tt-gnmodal.
        ASSIGN tt-gnmodal.cdmodali = gnmodal.cdmodali
               tt-gnmodal.dsmodali = gnmodal.dsmodali.
    END.

    OPEN QUERY q_opcaol FOR EACH tt-gnmodal.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE b_opcaol WITH FRAME f_listar.
        LEAVE.
    END.

    IF CAN-FIND(FIRST tt-gnmodal) THEN
        EMPTY TEMP-TABLE tt-gnmodal.

    LEAVE.

END.

/* F4, END ou FIM */
IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  
DO:
    HIDE FRAME f_listar.

    IF CAN-FIND(FIRST tt-gnmodal) THEN
        EMPTY TEMP-TABLE tt-gnmodal.

    NEXT.
END.

/* .......................................................................... */


