/*.............................................................................

   Programa: fontes/zoom_setoreconomico.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                            Ultima alteracao: 26/03/2010 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do setor economico.

   Alteracoes: 26/03/2010 - Adaptado para usar BO (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF INPUT PARAM par_cdcooper AS INT                               NO-UNDO.

DEF SHARED  VAR shr_cdseteco AS INTEGER                           NO-UNDO.
DEF SHARED  VAR shr_nmseteco AS CHAR      FORMAT "x(30)"          NO-UNDO.

DEF QUERY q_setoreco FOR tt-setorec. 
DEF BROWSE b_setoreco QUERY q_setoreco
      DISP tt-setorec.cdseteco                 COLUMN-LABEL "Cod."
           tt-setorec.nmseteco FORMAT "x(20)"  COLUMN-LABEL "Setor Economico"
           WITH 06 DOWN OVERLAY TITLE "SETOR ECONOMICO".    
          
FORM b_setoreco HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

    IF  NOT aux_fezbusca THEN
        DO:
            /* Verifica se o banco generico ja esta conectado */
            ASSIGN aux_flggener = f_verconexaogener().
           
            IF  aux_flggener OR f_conectagener()  THEN
                DO:
                    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                        RUN sistema/generico/procedures/b1wgen0059.p
                            PERSISTENT SET h-b1wgen0059.
              
                    RUN busca-setorec IN h-b1wgen0059
                         ( INPUT par_cdcooper,
                           INPUT 0,
                           INPUT "",
                           INPUT 999999,
                           INPUT 1,
                          OUTPUT aux_qtregist,
                          OUTPUT TABLE tt-setorec ).
                   
                    DELETE PROCEDURE h-b1wgen0059.

                    ASSIGN aux_fezbusca = YES.

                    IF  NOT aux_flggener  THEN
                        RUN p_desconectagener.
                END.
        END.

   ON RETURN OF b_setoreco 
      DO:
          ASSIGN shr_cdseteco = tt-setorec.cdseteco
                 shr_nmseteco = SUBSTR(tt-setorec.nmseteco,01,20).
                 
          CLOSE QUERY q_setoreco.               
          APPLY "END-ERROR" TO b_setoreco.
      END.

   OPEN QUERY q_setoreco FOR EACH tt-setorec NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET b_setoreco WITH FRAME f_alterar.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

/*............................................................................*/
