/*.............................................................................

   Programa: fontes/zoom_seq_titulares.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao:  17/05/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da sequencia de titulares existente - le crapttl.

   Alteracoes: 24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               24/10/2006 - Diminuir a altura do frame (Evandro).
               
               08/06/2010 - Adaptado para usar BO (Jose Luis, DB1)
               
               17/05/2011 - Alteração para dar 'hide' no frame f_alterar.
                            (André - DB1)
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i }

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.

DEF SHARED VAR shr_nrdconta LIKE crapttl.nrdconta                NO-UNDO.
DEF SHARED VAR shr_idseqttl LIKE crapttl.idseqttl                NO-UNDO.

DEF QUERY  bcrapttla-q FOR tt-crapttl. 
DEF BROWSE bcrapttla-b QUERY bcrapttla-q
      DISP tt-crapttl.idseqttl                      COLUMN-LABEL "Seq"
           tt-crapttl.nmextttl  FORMAT "x(40)"      COLUMN-LABEL "Titular"
           WITH 9 DOWN OVERLAY TITLE "TITULARES".    
          
FORM bcrapttla-b HELP "Use <TAB> para navegar" SKIP 
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
    
                RUN busca-crapttl IN h-b1wgen0059
                      ( INPUT par_cdcooper,
                        INPUT shr_nrdconta,
                        INPUT 999999,
                        INPUT 1,
                       OUTPUT aux_qtregist,
                       OUTPUT TABLE tt-crapttl ).
    
                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.

ON  END-ERROR OF bcrapttla-b
    DO:
        HIDE FRAME f_alterar.
    END.

ON RETURN OF bcrapttla-b DO:

    IF  AVAILABLE tt-crapttl THEN
        ASSIGN shr_idseqttl = tt-crapttl.idseqttl.
  
    CLOSE QUERY bcrapttla-q.              

    APPLY "END-ERROR" TO bcrapttla-b.
             
END.

OPEN QUERY bcrapttla-q FOR EACH tt-crapttl NO-LOCK.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE bcrapttla-b WITH FRAME f_alterar.
    LEAVE.
END.

HIDE FRAME f_alterar NO-PAUSE.

/****************************************************************************/
