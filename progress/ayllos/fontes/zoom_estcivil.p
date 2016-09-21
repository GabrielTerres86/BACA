/*.............................................................................

   Programa: fontes/zoom_estcivil.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao:  27/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gnetcvl - estado civil.

   Alteracoes:  19/08/2005 - Demonstrar na tela descricao completa(Mirtes)
   
                06/03/2010 - Busca dados da BO generica p/ZOOM (Jose Luis, DB1)

                27/05/2014 - Alterado o LIKE do shared "shr_cdestcvl" da crapass
                             para crapttl (Douglas - Chamado 131253)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF SHARED VAR shr_cdestcvl LIKE crapttl.cdestcvl                NO-UNDO.
DEF SHARED VAR shr_dsestcvl AS CHAR FORMAT "x(12)"               NO-UNDO.
                 
DEF QUERY  bgnetcvla-q FOR tt-gnetcvl. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
      DISP cdestcvl                            COLUMN-LABEL "Cod"
           dsestcvl        FORMAT "x(30)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "ESTADO CIVIL".    
          
FORM bgnetcvla-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

IF  NOT aux_fezbusca THEN
    DO:
        IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
            RUN sistema/generico/procedures/b1wgen0059.p
                PERSISTENT SET h-b1wgen0059.

        RUN busca-gnetcvl IN h-b1wgen0059
            ( INPUT 0,
              INPUT "",
              INPUT 999999,
              INPUT 1,
             OUTPUT aux_qtregist,
             OUTPUT TABLE tt-gnetcvl ).
    
        DELETE PROCEDURE h-b1wgen0059.
        ASSIGN aux_fezbusca = YES.
    END.

ON RETURN OF bgnetcvla-b DO:

    ASSIGN shr_cdestcvl = tt-gnetcvl.cdestcvl
           shr_dsestcvl = tt-gnetcvl.dsestcvl.
      
    CLOSE QUERY bgnetcvla-q.               

    APPLY "END-ERROR" TO bgnetcvla-b.
             
END.

OPEN QUERY bgnetcvla-q FOR EACH tt-gnetcvl NO-LOCK.

SET bgnetcvla-b WITH FRAME f_alterar.
       
/****************************************************************************/
