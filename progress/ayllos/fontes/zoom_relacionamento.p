
/*.............................................................................

   Programa: fontes/zoom_relacionamento.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel (RKAM)
   Data    : Julho/2015                      Ultima alteracao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do relacionamento com o 1.ero titular

   Alteracoes:
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0072tt.i }

DEF INPUT        PARAM par_cdcooper AS INTE                            NO-UNDO.
DEF INPUT-OUTPUT PARAM par_cdrlcrsp AS INT                             NO-UNDO.
DEF INPUT-OUTPUT PARAM par_dsrlcrsp AS CHAR                            NO-UNDO.

                 
DEF VAR h-b1wgen0072                AS HANDLE                          NO-UNDO.

DEF QUERY  q-relacionamento FOR Relacionamento.

DEF BROWSE b-relacionamento QUERY q-relacionamento
      DISP Relacionamento.cdrelacionamento COLUMN-LABEL "Cod."
           Relacionamento.dsrelacionamento COLUMN-LABEL "Relacionamento"
                                             FORMAT "x(30)" 
           WITH 6 DOWN OVERLAY TITLE "Relacionamento com Titular".    
          

FORM b-relacionamento HELP "Use as setas para navegar" 
     SKIP 
     WITH NO-BOX CENTERED OVERLAY ROW 9 FRAME f_relacionamento.          
          

ON RETURN OF b-relacionamento DO:

   IF   NOT AVAIL Relacionamento THEN
        RETURN.
         
   ASSIGN par_cdrlcrsp = Relacionamento.cdrelacionamento
          par_dsrlcrsp = Relacionamento.dsrelacionamento.
      
   CLOSE QUERY q-relacionamento.               
      
   APPLY "END-ERROR" TO b-relacionamento.             

END.

RUN sistema/generico/procedures/b1wgen0072.p PERSISTENT SET h-b1wgen0072.

RUN BuscaResponsavelLegal IN h-b1wgen0072 (INPUT par_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT "",
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE Relacionamento).

DELETE PROCEDURE h-b1wgen0072.

OPEN QUERY q-relacionamento FOR EACH Relacionamento
                                     BY Relacionamento.cdrelacionamento.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   UPDATE b-relacionamento WITH FRAME f_relacionamento.
   LEAVE.
         
END.  /*  Fim do DO WHILE TRUE  */
         
HIDE FRAME f_relacionamento NO-PAUSE.
   
           
/****************************************************************************/
