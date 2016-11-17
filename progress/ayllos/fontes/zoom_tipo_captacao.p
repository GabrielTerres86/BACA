/*............................................................................

   Programa: fontes/zoom_tipo_captacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Julho/2014                       Ultima Atualizacao:
     
   Dados referente ao programa:

   Frequencia: Sempre que chamado.
   Objetivo  : Zoom das finalidades de produtos de captacao. 

   Alteracoes:
.............................................................................*/
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }
    
DEF INPUT  PARAMETER par_cdcooper AS INT  NO-UNDO.

DEF OUTPUT PARAMETER par_cdprodut AS INT  NO-UNDO.
DEF OUTPUT PARAMETER par_nmprodut AS CHAR NO-UNDO.
DEF OUTPUT PARAMETER par_tpaplrdc AS INT  NO-UNDO.
DEF OUTPUT PARAMETER par_dstipapl AS CHAR NO-UNDO.
DEF OUTPUT PARAMETER par_nmprdcom AS CHAR NO-UNDO.

DEF VAR h-b1wgen0081 AS HANDLE NO-UNDO.   

DEF QUERY q_crapcpc FOR tt-tipo-aplicacao.
 
DEF BROWSE b_crapcpc QUERY q_crapcpc
    DISPLAY tt-tipo-aplicacao.dsaplica COLUMN-LABEL "Nome" FORMAT "x(50)"
      WITH CENTERED WIDTH 55 7 DOWN OVERLAY TITLE "PRODUTOS DE CAPTACAO".    
          
FORM b_crapcpc HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED WIDTH 55 OVERLAY ROW 8 FRAME f_crapcpc.

ON END-ERROR OF b_crapcpc
    DO:
        HIDE FRAME f_crapcpc.
    END.

ON RETURN OF b_crapcpc
   DO:
        IF AVAIL tt-tipo-aplicacao THEN
            DO:
                ASSIGN par_cdprodut = tt-tipo-aplicacao.tpaplica
                       par_nmprodut = tt-tipo-aplicacao.dsaplica
                       par_tpaplrdc = tt-tipo-aplicacao.tpaplrdc
                       par_dstipapl = tt-tipo-aplicacao.dstipapl.
            END.

        CLOSE QUERY q_crapcpc.

        HIDE FRAME f_crapcpc NO-PAUSE.
                                           
        APPLY "END-ERROR" TO b_crapcpc.
    
   END.
 
 IF  NOT VALID-HANDLE(h-b1wgen0081)  THEN
        RUN sistema/generico/procedures/b1wgen0081.p
            PERSISTENT SET h-b1wgen0081.
    
 RUN obtem-tipos-aplicacao IN h-b1wgen0081(INPUT par_cdcooper,
                                           INPUT 0, /*cdagenci*/
                                           INPUT 0, /*nrdcaixa*/
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT 1, /*idorigem*/
                                           INPUT 0,
                                           INPUT 1,  /** idseqttl **/
                                           INPUT FALSE,  /** flgerlog **/
                                          OUTPUT TABLE tt-tipo-aplicacao,
                                          OUTPUT TABLE tt-erro ).
    
 IF VALID-HANDLE(h-b1wgen0081)  THEN
    DELETE PROCEDURE h-b1wgen0081.
 
 OPEN QUERY q_crapcpc FOR EACH tt-tipo-aplicacao NO-LOCK.
 
 SET b_crapcpc WITH FRAME f_crapcpc.
/* .......................................................................... */
