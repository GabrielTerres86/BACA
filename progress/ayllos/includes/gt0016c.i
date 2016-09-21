/* .............................................................................

   Programa: Includes/gt0016c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Isara - RKAM
   Data    : Abril/2011                    Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Consulta da Modalidade (Generico)

   Alteracoes: 
   
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    ASSIGN tel_cdmodali = ""
           tel_dsmodali = "".

    DISPLAY tel_cdmodali 
            tel_dsmodali 
            WITH FRAME f_modalida.

    SET tel_cdmodali WITH FRAME f_modalida.

    IF NOT CAN-FIND(FIRST gnmodal
                    WHERE gnmodal.cdmodali = INPUT tel_cdmodali) THEN
    DO: 
        tel_dsmodali = "".
        DISPLAY tel_dsmodali WITH FRAME f_modalida.

        MESSAGE "Codigo nao cadastrado.".
        PAUSE 2 NO-MESSAGE.

        NEXT-PROMPT tel_cdmodali WITH FRAME f_modalida.
        NEXT.
    END.

    FIND FIRST gnmodal NO-LOCK 
         WHERE gnmodal.cdmodali = INPUT tel_cdmodali NO-ERROR.
    IF AVAIL gnmodal THEN
    DO:
        tel_dsmodali = gnmodal.dsmodali.
        DISPLAY tel_dsmodali WITH FRAME f_modalida.
    END.

    LEAVE.
END.

/* F4, END ou FIM */
IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    
    NEXT.

/* .......................................................................... */

