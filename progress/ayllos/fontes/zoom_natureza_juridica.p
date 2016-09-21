/*.............................................................................

   Programa: fontes/zoom_natureza_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                   Ultima alteracao:  03/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gncdntj - natureza juridica.

   Alteracoes: 15/03/2010 - Adaptado para usar BO (Jose Luis, DB1)
   
              03/11/2015 - Reformulacao cadastral (Gabriel-RKAM)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_cdnatjur LIKE gncdntj.cdnatjur                NO-UNDO.
DEF SHARED VAR shr_rsnatjur AS CHAR FORMAT "x(15)"               NO-UNDO.
DEF SHARED VAR shr_dsnatjur AS CHAR FORMAT "x(50)"               NO-UNDO.

                 
DEF QUERY  bgncdntja-q FOR tt-gncdntj. 
DEF BROWSE bgncdntja-b QUERY bgncdntja-q
      DISP cdnatjur        FORMAT "zzz9"       COLUMN-LABEL "Cod"
           dsnatjur        FORMAT "x(50)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "NATUREZA JURIDICA".    
          
FORM bgncdntja-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

    IF  NOT aux_fezbusca THEN
        DO:
           IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
               RUN sistema/generico/procedures/b1wgen0059.p
                   PERSISTENT SET h-b1wgen0059.
    
           RUN busca-gncdntj IN h-b1wgen0059
               ( INPUT 0,
                 INPUT "",
                 INPUT 999999,
                 INPUT 1,
                OUTPUT aux_qtregist,
                OUTPUT TABLE tt-gncdntj ).
    
           DELETE PROCEDURE h-b1wgen0059.
           ASSIGN aux_fezbusca = YES.
        END.

   ON RETURN OF bgncdntja-b 
      DO:
          ASSIGN shr_cdnatjur = tt-gncdntj.cdnatjur
                 shr_rsnatjur = tt-gncdntj.rsnatjur
                 shr_dsnatjur = tt-gncdntj.dsnatjur.
          
          CLOSE QUERY bgncdntja-q.
          APPLY "END-ERROR" TO bgncdntja-b.
      END.
      
   OPEN QUERY bgncdntja-q FOR EACH tt-gncdntj NO-LOCK BY tt-gncdntj.dsnatjur.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      SET bgncdntja-b WITH FRAME f_alterar.
      LEAVE.
   END.
   
   HIDE FRAME f_alterar NO-PAUSE.
           
/*............................................................................*/
