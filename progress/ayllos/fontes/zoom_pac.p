/*.............................................................................
   Programa: fontes/zoom_pac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Julho/2010                       Ultima alteracao: 07/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela crapage - Cadastro de PACs

   Alteracoes: 07/11/2011 - Adaptado zoom para BO. ( Gabriel Capoia - DB1 )
 
               07/10/2013 - Alteracao de PAC/P.A.C para PA. (James)
............................................................................ */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/var_online.i }

DEF OUTPUT PARAMETER par_cdagenci AS INT.
                 
DEF QUERY q_crapage FOR tt-crapage.
 
DEF BROWSE b_crapage QUERY q_crapage
    DISPLAY tt-crapage.cdagepac FORMAT "zz9"   COLUMN-LABEL "PA"
            tt-crapage.dsagepac FORMAT "x(15)" COLUMN-LABEL "Agencia"
            WITH 10 DOWN OVERLAY TITLE "PA".    
          
FORM b_crapage HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_crapage.

/* .........................................................................*/
    IF  NOT aux_fezbusca THEN
        DO:
            IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.
            
                RUN busca-crapage IN h-b1wgen0059
                    ( INPUT glb_cdcooper,
                      INPUT par_cdagenci,
                      INPUT "", /*dsagepac*/
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapage ).

                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.
               
        END.

/* .........................................................................*/

ON END-ERROR OF b_crapage
   DO:
       HIDE FRAME f_crapage.
   END.

ON RETURN OF b_crapage
    DO:
        IF  AVAIL tt-crapage THEN
            ASSIGN par_cdagenci = tt-crapage.cdagepac.

        CLOSE QUERY q_crapage.               

        HIDE FRAME f_crapage NO-PAUSE.

        APPLY "END-ERROR" TO b_crapage.
    END.

OPEN QUERY q_crapage FOR EACH tt-crapage NO-LOCK.

DO WHILE TRUE ON END-KEY UNDO, LEAVE:

    UPDATE b_crapage WITH FRAME f_crapage.
    
    LEAVE.

END.
   
HIDE FRAME f_crapage.
   
/* .......................................................................... */

