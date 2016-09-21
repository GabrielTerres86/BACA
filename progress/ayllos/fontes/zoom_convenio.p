/*.............................................................................

   Programa: fontes/zoom_convenio.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Junho/2015                       Ultima alteracao: 25/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom de convenios tarifarios para Folha de Pagamento IB

   Alteracoes: 22/10/2015 - Correcao no format para os valores dos convenios
                            (Marcos-Supero)
                            
               25/11/2015 - Ajustando a busca dos valores de tarifas dos
                            convenios. (Andre Santos - SUPERO)

............................................................................. */

{ sistema/generico/includes/b1wgen0166tt.i &VAR-AMB=SIM }
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ includes/gg0000.i}
{ sistema/generico/includes/var_oracle.i }

DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
DEF OUTPUT PARAM par_cdcontar AS INTE                            NO-UNDO.
DEF OUTPUT PARAM par_dscontar AS CHAR                            NO-UNDO.

DEF VAR h-b1wgen0166 AS HANDLE                                   NO-UNDO.

DEF QUERY  bgnetcvla-q FOR tt-convenio. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
           DISP dscontar FORMAT "x(30)"  COLUMN-LABEL "Convenio"
                cdcontar FORMAT "zzz"    COLUMN-LABEL "Codigo"
                vltarid0 FORMAT "zz9.99" COLUMN-LABEL "D 0"
                vltarid1 FORMAT "zz9.99" COLUMN-LABEL "D-1"
                vltarid2 FORMAT "zz9.99" COLUMN-LABEL "D-2"
           WITH 7 DOWN OVERLAY TITLE " Convenio Tarifario ".

FORM bgnetcvla-b
     HELP "Use <ENTER> para selecionar um Convenio."
     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_alterar.

ON  RETURN OF bgnetcvla-b DO:
    IF  AVAILABLE tt-convenio  THEN
        ASSIGN par_cdcontar = tt-convenio.cdcontar
               par_dscontar = tt-convenio.dscontar.
        
    HIDE FRAME f_alterar.

    CLOSE QUERY bgnetcvla-q.               
    APPLY "END-ERROR" TO bgnetcvla-b.
END.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  NOT VALID-HANDLE(h-b1wgen0166) THEN
        RUN sistema/generico/procedures/b1wgen0166.p
        PERSISTENT SET h-b1wgen0166.

    RUN Busca_Convenios_Tarifarios IN h-b1wgen0166
                                  (INPUT par_cdcooper
                                  ,OUTPUT TABLE tt-convenio).

    IF  VALID-HANDLE(h-b1wgen0166) THEN
        DELETE PROCEDURE h-b1wgen0166.

    OPEN QUERY bgnetcvla-q FOR EACH tt-convenio NO-LOCK.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

IF  CAN-FIND(FIRST tt-convenio)   THEN
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        SET bgnetcvla-b WITH FRAME f_alterar.
        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
ELSE DO:
    glb_cdcritic = 0.
    MESSAGE "Nao foram encontrados convenios tarifarios!".
    PAUSE(2) NO-MESSAGE.
END.

glb_cdcritic = 0.

HIDE FRAME f_alterar NO-PAUSE.
