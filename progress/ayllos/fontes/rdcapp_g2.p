/* .............................................................................

   Programa: Fontes/rdcapp_g2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2001.                        Ultima atualizacao: 06/07/2011.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento de CANCELAMENTE e CONSULTA de resgates
               da poupanca programada.
   
   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.
   
               06/07/2011 - Melhoria do codigo fonte, com implementacao de
                            Browse e chamada de BOs em b1wgen0006 (Jorge). 

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0006tt.i }

DEF INPUT  PARAM par_cddopcao AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                    NO-UNDO.
DEF INPUT  PARAM par_nraplica AS INT                                    NO-UNDO.
DEF OUTPUT PARAM par_flgconsl AS LOGICAL                                NO-UNDO.

DEF VAR aux_flgerlog AS LOGI                                            NO-UNDO.
DEF VAR aux_flgcance AS LOGI                                            NO-UNDO.

DEF VAR aux_nrdlinha AS INTE                                            NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                            NO-UNDO.

DEF VAR aux_dtresgat AS DATE                                            NO-UNDO.

DEF VAR aux_titframe AS CHAR                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                              NO-UNDO.

DEF VAR h-b1wgen0006 AS HANDLE                                          NO-UNDO.

DEF QUERY q_resgates FOR tt-resgates-rpp.

IF par_cddopcao = "C" THEN
    ASSIGN aux_flgcance = TRUE.

DEF BROWSE b_resgates QUERY q_resgates
    DISP tt-resgates-rpp.dtresgat LABEL "Data"       FORMAT "99/99/9999"
         tt-resgates-rpp.nrdocmto LABEL "Documento"  FORMAT "zz,zzz,zz9"
         tt-resgates-rpp.tpresgat LABEL "Tp.Resgate" FORMAT "x(10)"
         tt-resgates-rpp.dsresgat LABEL "Situacao"   FORMAT "x(9)"
         tt-resgates-rpp.nmoperad LABEL "Operador"   FORMAT "x(10)"
         tt-resgates-rpp.hrtransa LABEL "Hora"       FORMAT "x(5)"
         tt-resgates-rpp.vlresgat LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
         WITH NO-LABEL NO-BOX 9 DOWN.

FORM b_resgates
     HELP "Use as SETAS para navegar e <F4> para sair" 
     WITH CENTERED OVERLAY ROW 9 FRAME f_resgates TITLE aux_titframe.

ON RETURN OF b_resgates IN FRAME f_resgates DO:
    
    IF  NOT AVAILABLE tt-resgates-rpp  OR 
        NOT aux_flgcance THEN  /** CANCELAMENTO **/
        RETURN.

    ASSIGN aux_nrdocmto = tt-resgates-rpp.nrdocmto
           aux_dtresgat = tt-resgates-rpp.dtresgat.

    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0.

        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
        aux_confirma <> "S"                 THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.
            
            RETURN NO-APPLY.
        END.                    

    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
        SET h-b1wgen0006.

    RUN cancelar-resgate IN h-b1wgen0006 (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT 1,
                                          INPUT par_nrdconta,
                                          INPUT 1,
                                          INPUT par_nraplica,
                                          INPUT aux_nrdocmto,
                                          INPUT TRUE,
                                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0006.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            MESSAGE tt-erro.dscritic.

        END.
        
    APPLY "GO".
    
END.

ASSIGN aux_flgerlog = TRUE.
       aux_titframe = IF  aux_flgcance THEN 
                          " Cancelamento de Resgates "
                      ELSE 
                          " Consulta de Resgates ".

IF  aux_flgcance  THEN
    BROWSE b_resgates:HELP = "Tecle <Entra> para cancelar o resgate ou <Fim> " +
                             "para encerrar.".
ELSE
    BROWSE b_resgates:HELP = "Tecle <Fim> para encerrar a consulta.".

DO WHILE TRUE:

    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006.

    RUN consultar-resgates IN h-b1wgen0006 (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_nmdatela,
                                            INPUT 1,
                                            INPUT par_nrdconta,
                                            INPUT 1,
                                            INPUT par_nraplica,
                                            INPUT aux_flgcance,
                                            INPUT aux_flgerlog,
                                           OUTPUT TABLE tt-resgates-rpp).
    
    DELETE PROCEDURE h-b1wgen0006.
    
    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.
    ELSE
        CLOSE QUERY q_resgates.

    OPEN QUERY q_resgates PRESELECT EACH tt-resgates-rpp NO-LOCK.

    IF  aux_nrdlinha > 0  THEN
        DO: 
            IF  aux_nrdlinha > NUM-RESULTS("q_resgates")  THEN
                ASSIGN aux_nrdlinha = NUM-RESULTS("q_resgates").

            REPOSITION q_resgates TO ROW(aux_nrdlinha).
        END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE b_resgates WITH FRAME f_resgates.
       LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
    
END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_resgates NO-PAUSE.

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */
