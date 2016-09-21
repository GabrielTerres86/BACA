/*.............................................................................

   Programa: fontes/zoom_grau_instrucao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao:  06/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gngresc - grau de instrucao.

   Alteracoes: 06/03/10 Buscar os dados da BO generica de ZOOM (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_grescola LIKE crapttl.grescola                NO-UNDO.
DEF SHARED VAR shr_dsescola AS CHAR FORMAT "x(15)"               NO-UNDO.

DEF QUERY  bgngresca-q FOR tt-gngresc. 
DEF BROWSE bgngresca-b QUERY bgngresca-q
      DISP grescola                            COLUMN-LABEL "Grau"
           dsescola        FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "GRAU INSTRUCAO".    
          
FORM bgngresca-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gngresc IN h-b1wgen0059
              ( INPUT 0,
                INPUT "",
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gngresc ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.

   ON RETURN OF bgngresca-b 
      DO:
          ASSIGN shr_grescola = tt-gngresc.grescola
                 shr_dsescola = tt-gngresc.dsescola.
          
          CLOSE QUERY bgngresca-q.               
          APPLY "END-ERROR" TO bgngresca-b.
                 
      END.

   OPEN QUERY bgngresca-q FOR EACH tt-gngresc NO-LOCK.
   
   SET bgngresca-b WITH FRAME f_alterar.
           
/****************************************************************************/
