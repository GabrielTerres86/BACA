/*.............................................................................

   Programa: fontes/zoom_seguradora.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jorge I. Hamaguchi
   Data    : Janeiro/2014                   Ultima alteracao:  00/00/0000

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para lista de seguradora.

   Alteracoes: 
............................................................................ */
{ sistema/generico/includes/b1wgen0181tt.i }

DEF  INPUT PARAM par_cdcooper AS INTE                                 NO-UNDO.
DEF OUTPUT PARAM par_cdsegura AS INTE                                 NO-UNDO.
DEF OUTPUT PARAM TABLE FOR tt-crapcsg.
                 
DEF VAR h-b1wgen0181 AS HANDLE                                        NO-UNDO.

DEF VAR aux_qtregist AS INTE                                          NO-UNDO.

DEF QUERY q_crapcsg FOR tt-crapcsg.
DEF BROWSE b_crapcsg QUERY q_crapcsg
    DISPLAY tt-crapcsg.cdsegura  COLUMN-LABEL "Codigo"
            tt-crapcsg.nmsegura  COLUMN-LABEL "Nome"
            tt-crapcsg.flgativo  COLUMN-LABEL "Ativa"
            WITH 5 DOWN TITLE  " Seguradoras ".    

FORM b_crapcsg
         HELP "Pressione <ENTER> p/ selecionar a seguradora ou <F4> p/ voltar."
         WITH NO-BOX ROW 10 COLUMN 2 OVERLAY CENTERED FRAME f_crapcsg.

ON  END-ERROR OF b_crapcsg
    DO:
        HIDE FRAME f_crapcsg.
    END.

ON  RETURN OF b_crapcsg 
    DO:
        IF  AVAIL tt-crapcsg THEN
            DO:
                ASSIGN par_cdsegura = tt-crapcsg.cdsegura.

                CLOSE QUERY q_crapcsg.               
                
                APPLY "END-ERROR" TO b_crapcsg.
            END.
    END.


IF  NOT VALID-HANDLE(h-b1wgen0181) THEN
    RUN sistema/generico/procedures/b1wgen0181.p
        PERSISTENT SET h-b1wgen0181.

RUN busca_crapcsg IN h-b1wgen0181
    ( INPUT par_cdcooper,
      INPUT 0,
      INPUT "",
      INPUT ?,
      INPUT 999999,
      INPUT 1,
     OUTPUT aux_qtregist,
     OUTPUT TABLE tt-crapcsg ).

IF  VALID-HANDLE(h-b1wgen0181)  THEN
    DELETE PROCEDURE h-b1wgen0181.
         

OPEN QUERY q_crapcsg FOR EACH tt-crapcsg NO-LOCK.
                  
DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE b_crapcsg WITH FRAME f_crapcsg.
    LEAVE.
END.
                 
IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    DO:
        EMPTY TEMP-TABLE tt-crapcsg.

        HIDE FRAME f_crapcsg NO-PAUSE.

        CLOSE QUERY q_crapcsg.
    END.

/* .......................................................................... */



