/*.............................................................................

   Programa: fontes/zoom_credito_rotativo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2007                            Ultima alteracao: 18/10/2010
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de linhas de credito.

   Alteracoes: 18/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Inclusao de novo parametro para filtrar por tipo
                              de limite (ou 0 para todos os registros);
                            - Inclusao de campos 'Tipo de limite' e 'Taxa' na 
                              listagem e retirada do campo 'Situacao'
                          - Alteracoes para padronizar zoom, utilizando BO
                            b1wgen0059 (GATI - Eder)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF INPUT  PARAM par_tpdlinha AS INT                             NO-UNDO.
DEF INPUT  PARAM par_flgstlcr AS LOG                             NO-UNDO.
DEF OUTPUT PARAM par_cddlinha AS INT                             NO-UNDO.

DEF VAR aux_dsdtxfix          AS CHAR                            NO-UNDO.
DEF VAR aux_dsdtplin          AS CHAR                            NO-UNDO.
                 
DEF QUERY  bgnetcvla-q FOR tt-craplrt. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
      DISP tt-craplrt.cddlinha                        COLUMN-LABEL "Cod"
           tt-craplrt.dsdlinha    FORMAT "x(30)"      COLUMN-LABEL "Descricao"
           tt-craplrt.dsdtplin    FORMAT "X(11)"      COLUMN-LABEL "Tipo"
           tt-craplrt.dsdtxfix    FORMAT "X(12)"      COLUMN-LABEL "Taxa":C12
           WITH 8 DOWN OVERLAY TITLE " Linhas de Credito Rotativo ".    
          
FORM bgnetcvla-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.

IF   NOT aux_fezbusca   THEN
     DO:
        IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
            RUN sistema/generico/procedures/b1wgen0059.p
                PERSISTENT SET h-b1wgen0059.
     
        RUN busca-craplrt IN h-b1wgen0059
            ( INPUT par_cdcooper,
              INPUT 0,
              INPUT "",
              INPUT par_tpdlinha, 
              INPUT par_flgstlcr,   
              INPUT 999999,
              INPUT 1,
             OUTPUT aux_qtregist,
             OUTPUT TABLE tt-craplrt).
     
        DELETE PROCEDURE h-b1wgen0059.
        ASSIGN aux_fezbusca = YES.
     END.

ON   RETURN OF bgnetcvla-b 
     DO:
         ASSIGN par_cddlinha = tt-craplrt.cddlinha.
            
         CLOSE QUERY bgnetcvla-q.               
         APPLY "END-ERROR" TO bgnetcvla-b.
     END.
     

OPEN QUERY bgnetcvla-q FOR EACH tt-craplrt NO-LOCK.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   SET bgnetcvla-b WITH FRAME f_alterar.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */

