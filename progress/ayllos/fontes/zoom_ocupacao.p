/*.............................................................................

   Programa: fontes/zoom_ocupacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao: 06/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gncdocp - ocupacao.

   Alteracoes: 15/12/2004  - Zoom ocupacao pesquisar com begins(Mirtes)
   
               06/03/2010  - Busca dados da BO generica p/ ZOOM (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_cdocpttl  LIKE crapttl.cdocpttl                NO-UNDO.
DEF SHARED VAR shr_rsdocupa  AS CHAR FORMAT "x(15)"               NO-UNDO.
DEF SHARED VAR shr_ocupacao_pesq AS CHAR FORMAT "x(15)"           NO-UNDO.
                  
DEF QUERY  bgncdocpa-q FOR tt-gncdocp. 
DEF BROWSE bgncdocpa-b QUERY bgncdocpa-q
      DISP cdocupa                            COLUMN-LABEL "Cod"
           rsdocupa        FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "OCUPACAO".    
          
FORM bgncdocpa-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
   EMPTY TEMP-TABLE tt-gncdocp NO-ERROR.

   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gncdocp IN h-b1wgen0059
              ( INPUT 0,
                INPUT shr_ocupacao_pesq,
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gncdocp ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.

   ON RETURN OF bgncdocpa-b 
      DO:
          ASSIGN shr_cdocpttl = tt-gncdocp.cdocupa
                 shr_rsdocupa = tt-gncdocp.rsdocupa.
          
          CLOSE QUERY bgncdocpa-q.               
          APPLY "END-ERROR" TO bgncdocpa-b.
                 
      END.
   OPEN QUERY bgncdocpa-q FOR EACH tt-gncdocp BY tt-gncdocp.rsdocupa.

   SET bgncdocpa-b WITH FRAME f_alterar.
           
/****************************************************************************/
