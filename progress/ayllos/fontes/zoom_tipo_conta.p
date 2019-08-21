/*.............................................................................

   Programa: fontes/zoom_tipo_conta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao: 19/05/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela craptip - tipo de conta.

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               13/02/2006 - Inclusao do parametro par_cdcooper para a unificacao
                            dos Bancos de dados - SQLWorks - Fernando.
                            
               13/06/2006 - HIDE no frame f_alterar (Evandro).
               
               19/05/2010 - Adaptado para usar BO (Jose Luis, DB1)
               
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF INPUT  PARAM  par_cdcooper AS INT                               NO-UNDO.
DEF SHARED VAR    shr_cdtipcta LIKE craptip.cdtipcta                NO-UNDO.
DEF SHARED VAR    shr_dstipcta AS CHAR FORMAT "x(15)"               NO-UNDO.

DEF QUERY  bcraptipa-q FOR tt-craptip. 
DEF BROWSE bcraptipa-b QUERY bcraptipa-q
      DISP cdtipcta                            COLUMN-LABEL "Tipo"
           dstipcta        FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "TIPOS DE CONTA".    
          
FORM bcraptipa-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
    IF  NOT aux_fezbusca THEN
        DO:
            /* Verifica se o banco generico ja esta conectado */
            ASSIGN aux_flggener = f_verconexaogener().

            IF  aux_flggener OR f_conectagener()  THEN
                DO:
                    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                        RUN sistema/generico/procedures/b1wgen0059.p
                            PERSISTENT SET h-b1wgen0059.
    
                    RUN busca-craptip IN h-b1wgen0059
                       ( INPUT par_cdcooper,
                         INPUT 0,
                         INPUT "",
                         INPUT 999999,
                         INPUT 1,
                        OUTPUT aux_qtregist,
                        OUTPUT TABLE tt-craptip ).
            
                    DELETE PROCEDURE h-b1wgen0059.
        
                    ASSIGN aux_fezbusca = YES.
        
                    IF  NOT aux_flggener  THEN
                        RUN p_desconectagener.
                END.
        END.

   ON RETURN OF bcraptipa-b 
      DO:
          ASSIGN shr_cdtipcta = tt-craptip.cdtipcta
                 shr_dstipcta = tt-craptip.dstipcta.
          
          CLOSE QUERY bcraptipa-q.               
          HIDE FRAME f_alterar NO-PAUSE.
          APPLY "END-ERROR" TO bcraptipa-b.
                 
      END.

   OPEN QUERY bcraptipa-q FOR EACH tt-craptip NO-LOCK.
   
   SET bcraptipa-b WITH FRAME f_alterar.
   
/****************************************************************************/

