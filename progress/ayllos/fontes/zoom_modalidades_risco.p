/*.............................................................................

   Programa: fontes/zoom_modalidades_risco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Isara - RKAM
   Data    : Abril/2011                            Ultima alteracao: 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de modalidades

   Alteracoes: 
   
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF OUTPUT PARAM par_cdmodali LIKE gnmodal.cdmodali NO-UNDO.

DEF QUERY gnmodal-q FOR tt-gnmodal. 

DEF BROWSE gnmodal-b QUERY gnmodal-q
    DISP tt-gnmodal.cdmodali  FORMAT "x(02)"  COLUMN-LABEL "Codigo" 
         tt-gnmodal.dsmodali  FORMAT "x(40)"  COLUMN-LABEL "Descricao"
         WITH 8 DOWN OVERLAY TITLE " Modalidades de Risco ".    
          
FORM gnmodal-b HELP "Use <Seta para baixo> ou <Seta para cima> para navegar" SKIP 
    WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.

IF NOT aux_fezbusca THEN
DO:
    IF NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p
            PERSISTENT SET h-b1wgen0059.
   
    /* Cria a temp-table tt-gnmodal */
    RUN busca-modalidade IN h-b1wgen0059 (OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-gnmodal).
   
    DELETE PROCEDURE h-b1wgen0059.
    ASSIGN aux_fezbusca = YES.
END.

OPEN QUERY gnmodal-q FOR EACH tt-gnmodal NO-LOCK.

ON RETURN OF gnmodal-b 
DO:
    ASSIGN par_cdmodali = tt-gnmodal.cdmodali.
       
    CLOSE QUERY gnmodal-q.               
    APPLY "END-ERROR" TO gnmodal-b.
END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    SET gnmodal-b WITH FRAME f_alterar.
    LEAVE.
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */
