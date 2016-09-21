/*.............................................................................

   Programa: fontes/zoom_motivo_demissao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Maio/2005                             Ultima alteracao: 21/06/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom dos motivos de demissao (saida de socio).

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
   
               13/02/2006 - Inclusao do parametro par_cdcooper para unificacao
                            dos bancos de dados - SQLWorks - Andre
                            
               21/06/2010 - Adaptado para usar BO (Jose Luis, DB1) 
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_cdmotdem AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_dsmotdem AS CHAR                            NO-UNDO.

DEF QUERY  bmotdemi-q FOR tt-mot-demissao. 
DEF BROWSE bmotdemi-b QUERY bmotdemi-q
      DISP tt-mot-demissao.cdmotdem                COLUMN-LABEL "Motivo"
           tt-mot-demissao.dsmotdem FORMAT "x(25)" COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE " Motivos de Saida de Socio ".
          
FORM bmotdemi-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

IF  NOT aux_fezbusca THEN
    DO:
       IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
           RUN sistema/generico/procedures/b1wgen0059.p
               PERSISTENT SET h-b1wgen0059.

       RUN busca-mot-demissao IN h-b1wgen0059
           ( INPUT par_cdcooper,
             INPUT 0,
             INPUT "",
             INPUT 999999,
             INPUT 1,
            OUTPUT aux_qtregist,
            OUTPUT TABLE tt-mot-demissao ).

       DELETE PROCEDURE h-b1wgen0059.
       ASSIGN aux_fezbusca = YES.
    END.

ON RETURN OF bmotdemi-b 
   DO:
       ASSIGN par_cdmotdem = tt-mot-demissao.cdmotdem
              par_dsmotdem = tt-mot-demissao.dsmotdem.
          
       CLOSE QUERY bmotdemi-q.               
       APPLY "END-ERROR" TO bmotdemi-b.
   END.

OPEN QUERY bmotdemi-q 
     FOR EACH tt-mot-demissao NO-LOCK.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET bmotdemi-b WITH FRAME f_alterar.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */

