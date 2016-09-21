/*.............................................................................

   Programa: fontes/zoom_tipo_nacion.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Outubro/2004                   Ultima alteracao:  19/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom das nacionalidades - le gntpnac.

   Alteracoes: 19/03/2010 - Busca dados da BO generica p/ ZOOM (Jose Luis, DB1)   
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_restpnac LIKE gntpnac.destpnac                NO-UNDO.
DEF SHARED VAR shr_tpnacion LIKE gntpnac.tpnacion                NO-UNDO.
                 
DEF QUERY  bgntpnaca-q FOR tt-gntpnac. 
DEF BROWSE bgntpnaca-b QUERY bgntpnaca-q
      DISP tpnacion                            COLUMN-LABEL "Cod"
           restpnac        FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "TIPO NACIONALIDADE".    
          
FORM bgntpnaca-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gntpnac IN h-b1wgen0059
              ( INPUT 0,
                INPUT "",
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gntpnac ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.

   ON RETURN OF bgntpnaca-b 
      DO:
          ASSIGN shr_restpnac = tt-gntpnac.restpnac
                 shr_tpnacion = tt-gntpnac.tpnacion.
                 
          CLOSE QUERY bgntpnaca-q.               
          APPLY "END-ERROR" TO bgntpnaca-b.
                 
      END.

   OPEN QUERY bgntpnaca-q 
        FOR EACH tt-gntpnac NO-LOCK.
   
   SET bgntpnaca-b WITH FRAME f_alterar.
           
/****************************************************************************/
