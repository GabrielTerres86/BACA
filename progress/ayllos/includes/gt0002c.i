/* .............................................................................

   Programa: Includes/gt0002c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                    Ultima Atualizacao: 22/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Consulta dos Convenios/Cooperatva(Generico)

   Alteracoes: 22/06/2012 - Substituido gncoper por crapcop (Tiago).          
                
               19/09/2013 - Adaptar fonte para BO. (Gabriel Capoia - DB1).
............................................................................. */

IF  tel_cdconven <> 0 AND
    tel_cdcooper <> 0 THEN 
    DO:
        FIND FIRST tt-gt0002 NO-ERROR.

        IF  AVAIL tt-gt0002 THEN
            ASSIGN tel_nmempres = tt-gt0002.nmempres
                   tel_nmrescop = tt-gt0002.nmrescop.

        DISPLAY tel_nmempres tel_nmrescop
             WITH FRAME f_convenio.

    END. 
ELSE 
    DO:
        PAUSE(0).

        OPEN QUERY bgncvcopq 
            FOR EACH tt-gt0002 NO-LOCK.


        ENABLE bgncvcop-b WITH FRAME f_convenioc.

        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

        CLEAR FRAME f_convenio ALL NO-PAUSE.

    END.

HIDE FRAME f_convenioc.

/* .......................................................................... */
