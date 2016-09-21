/*.............................................................................
  
  Programa: fontes/testemunhas.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Julho/2011                  Ultima atualizacao : 
  
  Dados referentes ao programa:
  
  Frequancia: Diario (On-line)
  Objetivo  : Tela das testemunhas nas rotinas de COBRANCA/ATENDA e DDA/CONTAS.
  
  
  Alteracoes:
            
.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0078tt.i }


DEF INPUT  PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_nmdtest1 AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_cpftest1 AS DECI                                  NO-UNDO.
DEF OUTPUT PARAM par_nmdtest2 AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_cpftest2 AS DECI                                  NO-UNDO.


DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.


FORM SKIP(1)
     par_cpftest1 LABEL "CPF testemunha 1"  AT 04 FORMAT "zzzzzzzzzzzzzzzzzz"
     SKIP
     par_nmdtest1 LABEL "Nome testemunha 1" AT 03 FORMAT "x(50)"
     SKIP(1)
     par_cpftest2 LABEL "CPF testemunha 2"  AT 04 FORMAT "zzzzzzzzzzzzzzzzzz"
     SKIP
     par_nmdtest2 LABEL "Nome testemunha 2" AT 03 FORMAT "x(50)"
     SKIP(1)
     WITH ROW 9 CENTERED OVERLAY SIDE-LABELS WIDTH 76 
                    TITLE " Testemunhas " FRAME f_testemunhas.


ON LEAVE, GO OF par_cpftest1 DO:
   
    IF   INPUT par_cpftest1 = 0   THEN
         DO:
             ASSIGN par_nmdtest1 = "".
             DISPLAY par_nmdtest1 WITH FRAME f_testemunhas.
             RETURN.
         END.
         
    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN traz-nome-testemunha IN h-b1wgen0078 (INPUT glb_cdcooper,       
                                              INPUT INPUT par_cpftest1,
                                             OUTPUT TABLE tt-testemunha).
    DELETE PROCEDURE h-b1wgen0078.

    FIND FIRST tt-testemunha NO-LOCK NO-ERROR.

    ASSIGN par_nmdtest1 = tt-testemunha.nmdteste WHEN AVAIL tt-testemunha.
                                      
    DISPLAY par_nmdtest1 WITH FRAME f_testemunhas.

END.

/* Buscar a Testemunha  2 pelo CPF */
ON LEAVE, GO OF par_cpftest2 DO:
    
    IF   INPUT par_cpftest2 = 0   THEN
         DO:
             ASSIGN par_nmdtest2 = "".
             DISPLAY par_nmdtest2 WITH FRAME f_testemunhas.
             RETURN.
         END.

    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN traz-nome-testemunha IN h-b1wgen0078 (INPUT glb_cdcooper,       
                                              INPUT INPUT par_cpftest2,
                                             OUTPUT TABLE tt-testemunha).
    DELETE PROCEDURE h-b1wgen0078.

    FIND FIRST tt-testemunha NO-LOCK NO-ERROR.

    ASSIGN par_nmdtest2 = tt-testemunha.nmdteste WHEN AVAIL tt-testemunha.

    DISPLAY par_nmdtest2 WITH FRAME f_testemunhas.

END.


/* Nome e CPF de duas testemunhas */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE par_cpftest1
          par_nmdtest1
          par_cpftest2 
          par_nmdtest2 WITH FRAME f_testemunhas.

   RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.   
       
   RUN valida-cpf-testemunhas IN h-b1wgen0078 
                                       (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT 1, /* Ayllos */
                                        INPUT par_nrdconta,
                                        INPUT par_nmdtest1,
                                        INPUT par_cpftest1,
                                        INPUT par_nmdtest2,
                                        INPUT par_cpftest2,
                                        INPUT 1, /* Tit*/
                                        INPUT glb_dtmvtolt,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro). 

   DELETE PROCEDURE h-b1wgen0078.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro  THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
                 MESSAGE "Erro na validacao das testemunhas.".
             
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               PAUSE 3 NO-MESSAGE.
               LEAVE.
            END.

            HIDE MESSAGE NO-PAUSE.
            NEXT.

        END.

   LEAVE.

END. /* Fim Bloco Principal */

HIDE FRAME f_testemunhas.

/* ......................................................................... */
