/*.............................................................................

   Programa: fontes/zoom_curso_superior.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao: 01/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gncdfrm - gncdfrm - curso superior.

   Alteracoes: 15/12/2004 - Zoom pesquisar com begins(Mirtes)
   
               01/03/2010 - Buscar dados da BO generica de ZOOM (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_cdfrmttl LIKE crapttl.cdfrmttl                NO-UNDO.
DEF SHARED VAR shr_rsfrmttl AS CHAR FORMAT "x(15)"               NO-UNDO.
DEF SHARED VAR shr_formacao_pesq AS CHAR FORMAT "x(15)"           NO-UNDO.

DEF QUERY  gncdfrm-q FOR tt-gncdfrm. 
DEF BROWSE gncdfrm-b QUERY gncdfrm-q
      DISP cdfrmttl FORMAT ">>>9"  COLUMN-LABEL "Cod"
           rsfrmttl FORMAT "x(15)" COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "FORMACAO - CURSO SUPERIOR".    
          
FORM gncdfrm-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_gncdfrm.          
/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gncdfrm IN h-b1wgen0059
              ( INPUT 0,
                INPUT shr_formacao_pesq,
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gncdfrm ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.
   
   ON RETURN OF gncdfrm-b 
      DO:
          ASSIGN shr_cdfrmttl = tt-gncdfrm.cdfrmttl
                 shr_rsfrmttl = tt-gncdfrm.rsfrmttl.
          
          CLOSE QUERY gncdfrm-q.               
          APPLY "END-ERROR" TO gncdfrm-b.
                 
      END.    

   OPEN QUERY gncdfrm-q FOR EACH tt-gncdfrm NO-LOCK.

   SET gncdfrm-b WITH FRAME f_gncdfrm.
           
/****************************************************************************/
