/*.............................................................................

   Programa: fontes/zoom_cash.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Outubro/2004                          Ultima alteracao: 07/11/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de cashes.

   Alteracoes: 25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/02/2006 - Inclusao do parametro par_cdcooper para a unificacao
                            dos Bancos de dados - SQLWorks - Fernando

               27/09/2007 - Mostrar o nome na rede do cash (Edson).
               
               06/05/2008 - Alterada pesquisa dos caixas eletronicos por PAC
                            (Gabriel).
                            
               07/11/2011 - Adaptado zoom para BO. ( Gabriel Capoia - DB1 )
                            
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_nrterfin AS INT                             NO-UNDO.
                 
DEF QUERY  bgnetcvla-q FOR tt-craptfn.
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
    DISP tt-craptfn.nrterfin                   COLUMN-LABEL "Cash"
         tt-craptfn.nmnarede   FORMAT "x(11)"  COLUMN-LABEL "Rede"
         tt-craptfn.nmterfin   FORMAT "x(25)"  COLUMN-LABEL "Descricao"
    WITH 10 DOWN OVERLAY TITLE " Cashes ".
          
FORM bgnetcvla-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar. 
/* .........................................................................*/
    IF  NOT aux_fezbusca THEN
        DO:
            IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.
            
                RUN busca-craptfn IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT par_nrterfin,
                      INPUT "", /*nmterfin*/
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-craptfn ).

                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.
               
        END.
/* .........................................................................*/

ON RETURN OF bgnetcvla-b 
    DO:
        IF  AVAIL tt-craptfn THEN
            ASSIGN par_nrterfin = tt-craptfn.nrterfin.

        CLOSE QUERY bgnetcvla-q.

        APPLY "END-ERROR" TO bgnetcvla-b.
    END.

OPEN QUERY bgnetcvla-q FOR EACH tt-craptfn NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    SET bgnetcvla-b WITH FRAME f_alterar.

    LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */

