/*.............................................................................

   Programa: fontes/zoom_nivel_cargo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao:  08/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gncdncg - nivel do cargo.

   Alteracoes: 08/03/2010  - Busca dados da BO generica p/ ZOOM (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_cdnvlcgo  LIKE crapttl.cdnvlcgo                NO-UNDO.
DEF SHARED VAR shr_rsnvlcgo  AS CHAR FORMAT "x(10)"               NO-UNDO.
                 
DEF QUERY  bgncdncga-q FOR tt-gncdncg. 
DEF BROWSE bgncdncga-b QUERY bgncdncga-q
      DISP tt-gncdncg.cdnvlcgo                     COLUMN-LABEL "Cod"
           tt-gncdncg.rsnvlcgo FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "NIVEL DO CARGO".    
          
FORM bgncdncga-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gncdncg IN h-b1wgen0059
              ( INPUT 0,
                INPUT "",
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gncdncg ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.

   ON RETURN OF bgncdncga-b 
      DO:
          IF  AVAILABLE tt-gncdncg THEN
              ASSIGN shr_cdnvlcgo = tt-gncdncg.cdnvlcgo
                     shr_rsnvlcgo = tt-gncdncg.rsnvlcgo.
          
          CLOSE QUERY bgncdncga-q.               
          APPLY "END-ERROR" TO bgncdncga-b.
                 
      END.

   OPEN QUERY bgncdncga-q FOR EACH tt-gncdncg WHERE tt-gncdncg.cdnvlcgo <> 0 
                                   NO-LOCK.
   
   SET bgncdncga-b WITH FRAME f_alterar.
           
/****************************************************************************/
