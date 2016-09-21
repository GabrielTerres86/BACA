/*.............................................................................

   Programa: fontes/zoom_motivo_nao_aprovacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Eder
   Data    : Setembro/2009                       Ultima alteracao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom dos motivos de nao aprovacao de emprestimos 

   Alteracoes: 06/10/11 - Fonte adaptado para utilizar BO 59 (Rogerius - DB1)

............................................................................ */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF OUTPUT PARAM par_cdcmaprv AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_dscmaprv AS CHAR                            NO-UNDO.

DEF QUERY  bgnetcvla-q FOR tt-gncmapr. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
      DISP cdcmaprv  FORMAT ">9"         COLUMN-LABEL "Motivo"
           dscmaprv  FORMAT "x(60)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE " Motivos de Nao Aprovacao ".
          
FORM bgnetcvla-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN busca-gncmapr IN h-b1wgen0059
              ( INPUT 0,
                INPUT "",
                INPUT 999999,
                INPUT 1,
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-gncmapr ).

          DELETE PROCEDURE h-b1wgen0059.
          ASSIGN aux_fezbusca = YES.
       END.

ON RETURN OF bgnetcvla-b 
   DO:
       ASSIGN par_cdcmaprv = tt-gncmapr.cdcmaprv
              par_dscmaprv = tt-gncmapr.dscmaprv.
          
       CLOSE QUERY bgnetcvla-q.               
       APPLY "END-ERROR" TO bgnetcvla-b.
   END.

OPEN QUERY bgnetcvla-q 
     FOR EACH tt-gncmapr NO-LOCK.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET bgnetcvla-b WITH FRAME f_alterar.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

RETURN "OK".

/* .......................................................................... */
