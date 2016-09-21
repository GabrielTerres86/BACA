/*.............................................................................

   Programa: fontes/zoom_natureza_ocupacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao: 06/03/2010 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela tt-gncdnto - natureza da ocupacao.

   Alteracoes: 06/03/2010 - Busca dados da BO generica p/ ZOOM (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_cdnatocp LIKE crapttl.cdnatopc                NO-UNDO.
DEF SHARED VAR shr_rsnatocp AS CHAR FORMAT "x(15)"               NO-UNDO.
                 
DEF QUERY  b-gncdntoa-q FOR tt-gncdnto. 
DEF BROWSE b-gncdntoa-b QUERY b-gncdntoa-q
      DISP cdnatocp                            COLUMN-LABEL "Cod"
           rsnatocp        FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "NATUREZA OCUPACAO".    
          
FORM b-gncdntoa-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gncdnto IN h-b1wgen0059
              ( INPUT 0,
                INPUT "",
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gncdnto ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.

   ON RETURN OF b-gncdntoa-b 
      DO:
          ASSIGN shr_cdnatocp = tt-gncdnto.cdnatocp
                 shr_rsnatocp = tt-gncdnto.rsnatocp.
          
          CLOSE QUERY b-gncdntoa-q.               
          APPLY "END-ERROR" TO b-gncdntoa-b.
                 
      END.

   OPEN QUERY b-gncdntoa-q FOR EACH tt-gncdnto NO-LOCK BY tt-gncdnto.rsnatocp.
   
   SET b-gncdntoa-b WITH FRAME f_alterar.
           
/****************************************************************************/
