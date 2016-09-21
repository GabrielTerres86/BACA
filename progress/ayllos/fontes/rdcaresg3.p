/* .............................................................................

   Programa: Fontes/rdcaresg3.p                      
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Julho/2001.                     Ultima atualizacao: 29/11/2010.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento de CANCELAMENTE e CONSULTA de resgates
               das aplicacoes RDCA.
   
   Alteracoes: 03/04/2002 - Tratamento do resgate on_line (Margarete).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).

               27/05/2004 - Atualizar craprda.vlrgtacu (Margarete).
 
               06/09/2004 - Incluido Flag Conta Investimento(Mirtes).

               10/12/2004 - Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).

               03/01/2005 - Mais de um resgate solicitado no mesmo dia
                            nao cancela correto. Incluido data do resgate
                            para cancelamento (Margarete).

               12/01/2005 - Corrigir numero do documento (Margarete).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo (Margarete).

               19/09/2005 - Quando dinheiro da aplicacao vem da conta
                            de investimento nao tem cpmf (Margarete).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               10/02/2006 - Quando cancelamento antes do aniver nao estava
                            voltando o valor do cpmf (Magui).

               23/05/2007 - Alimentar craplrg.inresgat = 3 (estornado) somente
                            quando craplrg.tpaplica = 3 (RDCA30) (David).
                            
               11/10/2010 - Ajuste para utilizar BO da rotina (David).
               
               29/11/2010 - Utilizar BO b1wgen0081.p (Adriano).

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0081tt.i }

DEF  INPUT PARAM par_flgcance AS LOGI                                   NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.
DEF  INPUT PARAM par_nraplica AS INTE                                   NO-UNDO.
DEF  INPUT PARAM par_idtipapl AS CHAR                                   NO-UNDO.

DEF VAR aux_flgerlog AS LOGI                                            NO-UNDO.

DEF VAR aux_nrdlinha AS INTE                                            NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                            NO-UNDO.

DEF VAR aux_dtresgat AS DATE                                            NO-UNDO.

DEF VAR aux_titframe AS CHAR                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                              NO-UNDO.

DEF VAR h-b1wgen0081 AS HANDLE                                          NO-UNDO.

DEF QUERY q_resgates FOR tt-resg-aplica.

DEF BROWSE b_resgates QUERY q_resgates
    DISP tt-resg-aplica.dtresgat LABEL "Data"       FORMAT "99/99/9999"
         tt-resg-aplica.nrdocmto LABEL "Documento"  FORMAT "zz,zzz,zz9"
         tt-resg-aplica.tpresgat LABEL "Tp.Resgate" FORMAT "x(10)"
         tt-resg-aplica.dsresgat LABEL "Situacao"   FORMAT "x(9)"
         tt-resg-aplica.nmoperad LABEL "Operador"   FORMAT "x(10)"
         tt-resg-aplica.hrtransa LABEL "Hora"       FORMAT "x(5)"
         tt-resg-aplica.vllanmto LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
         WITH NO-LABEL NO-BOX 9 DOWN.

FORM b_resgates
     HELP "Use as SETAS para navegar e <F4> para sair" 
     WITH CENTERED OVERLAY ROW 9 FRAME f_resgates TITLE aux_titframe.

ON RETURN OF b_resgates IN FRAME f_resgates DO:
    
    IF NOT AVAILABLE tt-resg-aplica OR NOT par_flgcance THEN  /** CANCELAMENTO **/
        RETURN.

    ASSIGN aux_nrdocmto = tt-resg-aplica.nrdocmto
           aux_dtresgat = tt-resg-aplica.dtresgat.

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

    IF par_idtipapl = "A" THEN
        DO:
            IF NOT VALID-HANDLE(h-b1wgen0081) THEN
                RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
            
            RUN cancelar-resgates-aplicacao IN h-b1wgen0081 
                                           (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_nmdatela,
                                            INPUT 1,
                                            INPUT par_nrdconta,
                                            INPUT 1,
                                            INPUT par_nraplica,
                                            INPUT aux_nrdocmto,
                                            INPUT aux_dtresgat,
                                            INPUT glb_dtmvtolt,
                                            INPUT TRUE,
                                           OUTPUT TABLE tt-erro).
        
            IF VALID-HANDLE(h-b1wgen0081) THEN
                DELETE PROCEDURE h-b1wgen0081.
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                    IF  AVAILABLE tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.
        
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        DO:
            
            /* Rotina de cancelamento de novos produtos */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
            
            /* Efetuar a chamada a rotina Oracle */ 
            RUN STORED-PROCEDURE pc_cancela_resgate
                aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /* Codigo da Cooperativa */
                                                    INPUT 0,            /* Codigo do PA */
                                                    INPUT 0,            /* Numero do caixa */
                                                    INPUT glb_cdoperad, /* Codigo do operador */
                                                    INPUT glb_nmdatela, /* Nome da tela */
                                                    INPUT 1,            /* Identificador de sistema de origem */
                                                    INPUT par_nrdconta, /* Numero da conta */
                                                    INPUT 1,            /* Sequencia do titular */
                                                    INPUT par_nraplica, /* Numero da aplicacao */
                                                    INPUT aux_nrdocmto, /* Numero do documento */
                                                    INPUT aux_dtresgat, /* Data de resgate */
                                                    INPUT glb_dtmvtolt, /* Data de movimento atual */
                                                    INPUT 1,            /* Flag para gerar LOG */
                                                   OUTPUT 0,            /* Código da crítica */
                                                   OUTPUT "").          /* Descricao da Critica */

            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_cancela_resgate
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

            /* Busca possíveis erros */ 
            ASSIGN glb_cdcritic = pc_cancela_resgate.pr_cdcritic
                   glb_dscritic = pc_cancela_resgate.pr_dscritic.
    
            IF glb_dscritic <> ? AND
               glb_dscritic <> "" THEN
              DO:
                BELL.
                MESSAGE glb_dscritic.
                PAUSE 3 NO-MESSAGE.
                  
                RETURN "NOK".
              END.
        END.
       
    APPLY "GO".
    
END.

ASSIGN aux_flgerlog = TRUE.
       aux_titframe = IF  par_flgcance  THEN 
                          " Cancelamento de Resgates "
                      ELSE 
                          " Consulta de Resgates ".

IF  par_flgcance  THEN
    BROWSE b_resgates:HELP = "Tecle <Entra> para cancelar o resgate ou <Fim> " +
                             "para encerrar.".
ELSE
    BROWSE b_resgates:HELP = "Tecle <Fim> para encerrar a consulta.".

DO WHILE TRUE:
    IF NOT VALID-HANDLE(h-b1wgen0081) THEN
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
    
    RUN obtem-resgates-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmdatela,
                                                  INPUT 1,
                                                  INPUT par_nrdconta,
                                                  INPUT 1,
                                                  INPUT par_nraplica,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT IF par_flgcance THEN 1 ELSE 0,
                                                  INPUT aux_flgerlog,
                                                 OUTPUT TABLE tt-resg-aplica).
    
    IF VALID-HANDLE(h-b1wgen0081) THEN
        DELETE PROCEDURE h-b1wgen0081.
    
    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.
    ELSE
        CLOSE QUERY q_resgates.
    
    OPEN QUERY q_resgates PRESELECT EACH tt-resg-aplica NO-LOCK.
    
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
    
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_resgates NO-PAUSE.

HIDE MESSAGE NO-PAUSE.

/*............................................................................*/
