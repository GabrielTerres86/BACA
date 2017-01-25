/*.............................................................................

   Programa: fontes/zoom_departamento.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago Castro (RKAM)
   Data    : Setembro/2014                          Ultima alteracao: 06/12/2016
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de departamentos.

   Alteracoes: 06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)         
                            
                            
............................................................................. */
DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
DEF OUTPUT PARAM par_dsdepart AS CHAR                            NO-UNDO.
DEF OUTPUT PARAM par_cddepart AS INTE                            NO-UNDO.
                 
DEF QUERY  q_crapdpo FOR crapdpo. 
DEF BROWSE b_crapdpo QUERY q_crapdpo
      DISP cddepart                            COLUMN-LABEL "cod." 
           dsdepart                            COLUMN-LABEL "Dept."
           WITH 7 DOWN OVERLAY TITLE " Departamentos ".
          
FORM b_crapdpo HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7 FRAME f_crapdpo.          

ON RETURN OF b_crapdpo 
   DO:
       par_dsdepart = crapdpo.dsdepart.
       par_cddepart = crapdpo.cddepart.
          
       CLOSE QUERY q_crapdpo.               
       APPLY "END-ERROR" TO b_crapdpo.
   END.

OPEN QUERY q_crapdpo FOR EACH crapdpo WHERE 
                              crapdpo.cdcooper = par_cdcooper AND 
                              crapdpo.insitdpo = 1
                              NO-LOCK BY crapdpo.dsdepart.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET b_crapdpo WITH FRAME f_crapdpo.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_crapdpo NO-PAUSE.

/* .......................................................................... */


