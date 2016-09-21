/*.............................................................................
   Programa: fontes/zoom_cooper.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Junho/2010                       Ultima alteracao:        

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela cracop - Dados da Cooperativa

   Alteracoes: 
   
............................................................................. */

DEF OUTPUT PARAMETER par_cdcooper AS INT.
                 
DEF QUERY q_crapcop FOR crapcop.
 
DEF BROWSE b_crapcop QUERY q_crapcop
    DISPLAY crapcop.cdcooper COLUMN-LABEL "Codigo"
            crapcop.nmrescop COLUMN-LABEL "Cooperativa"
            WITH 10 DOWN OVERLAY TITLE "COOPERATIVA".    
          
FORM b_crapcop HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_crapcop.          

ON END-ERROR OF b_crapcop
   DO:
       HIDE FRAME f_crapcop.
   END.

ON RETURN OF b_crapcop
   DO:
       ASSIGN par_cdcooper = crapcop.cdcooper.
          
       CLOSE QUERY q_crapcop.               
       HIDE FRAME f_crapcop NO-PAUSE.
       APPLY "END-ERROR" TO b_crapcop.
                 
   END.

   OPEN QUERY q_crapcop FOR EACH crapcop NO-LOCK.

 DO WHILE TRUE ON END-KEY UNDO, LEAVE:
     UPDATE b_crapcop WITH FRAME f_crapcop.
     LEAVE.
 END.
   
HIDE FRAME f_crapcop.
   
/* .......................................................................... */
