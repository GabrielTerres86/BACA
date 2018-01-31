/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank83.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Agosto/2014.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Retorna dados da qtd de dias de carencia da crapttx.
   
   Alteracoes: 

..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

/*
pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperartiva
,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
,pr_nrdcaixa IN INTEGER               --> Número do caixa
,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
,pr_nmdatela IN VARCHAR2              --> Nome da tela
,pr_idorigem IN INTEGER               --> Código de origem
,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequêncial do titular
,pr_tpaplica IN craprda.tpaplica%TYPE --> Tipo da aplicação
,pr_qtdiaapl IN craprda.qtdiaapl%TYPE --> Quantidade de dias
,pr_qtdiacar IN crapttx.qtdiacar%TYPE --> Quantidade de dias da carência
,pr_flgvalid IN INTEGER               --> Validar ou não -- 0 (FALSE) / 1 (TRUE)
,pr_flgerlog IN INTEGER               --> Gerar log      -- 0 (FALSE) / 1 (TRUE)                                                                       
,pr_cdcritic OUT crapcri.cdcritic%TYPE -->  Código da critica
,pr_dscritic OUT crapcri.dscritic%TYPE)
*/                                   

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_idorigem AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_tpaplica LIKE craprda.tpaplica                     NO-UNDO.
DEF INPUT PARAM par_qtdiaapl LIKE craprda.qtdiaapl                     NO-UNDO.
DEF INPUT PARAM par_qtdiacar LIKE crapttx.qtdiacar                     NO-UNDO.
DEF INPUT PARAM par_flgvalid AS INT                                    NO-UNDO.
DEF INPUT PARAM par_flgerlog AS INT                                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_txaplica AS DEC                                            NO-UNDO.
DEF VAR aux_txaplmes AS DEC                                            NO-UNDO.
DEF VAR aux_dsaplica AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdiaapl LIKE craprda.qtdiaapl                             NO-UNDO.
DEF VAR aux_qtdiacar LIKE crapttx.qtdiacar                             NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.
DEF VAR aux_perirapl AS DEC                                            NO-UNDO.
DEF VAR aux_dtmvtopr AS CHAR                                           NO-UNDO.
DEF VAR aux_qtmesage AS INT                                            NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                             
RUN STORED-PROCEDURE pc_obtem_dias_carencia_wt
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_dtmvtolt,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_tpaplica,
                             INPUT par_qtdiaapl,
                             INPUT par_qtdiacar,
                             INPUT par_flgvalid,
                             INPUT par_flgerlog,
                             OUTPUT 0,
                             OUTPUT "").     

CLOSE STORED-PROC pc_obtem_dias_carencia_wt
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_obtem_dias_carencia_wt.pr_cdcritic 
                          WHEN pc_obtem_dias_carencia_wt.pr_cdcritic <> ?
       aux_dscritic = pc_obtem_dias_carencia_wt.pr_dscritic
                          WHEN pc_obtem_dias_carencia_wt.pr_dscritic <> ?. 

IF aux_cdcritic <> 0   OR
   aux_dscritic <> ""  THEN
   DO:
       IF aux_dscritic = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                NO-LOCK NO-ERROR.
             
             IF AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar " +
                                      "o periodo de carencia.".

          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                             "</dsmsgerr>".  

       RETURN "NOK".
       
   END.

FIND FIRST wt_carencia_aplicacao NO-LOCK NO-ERROR.

IF NOT AVAIL wt_carencia_aplicacao THEN
   DO:
      ASSIGN aux_dscritic = "Nao foi possivel consultar " +
                            "o periodo de carencia."
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

      RETURN "NOK".

   END.


ASSIGN aux_dslinxml = "".

FOR EACH wt_carencia_aplicacao NO-LOCK:

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_qtdiaapl = wt_carencia_aplicacao.qtdiafim
           aux_qtdiacar = wt_carencia_aplicacao.qtdiacar.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }  

    RUN STORED-PROCEDURE pc_calcula_permanencia_resgate
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, 
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_tpaplica,
                                 INPUT par_dtmvtolt,
                                 INPUT par_flgerlog,
                                 INPUT aux_qtdiacar,
                                 INPUT-OUTPUT aux_qtdiaapl,
                                 INPUT-OUTPUT aux_dtvencto,
                                 OUTPUT 0,
                                 OUTPUT "").  

    CLOSE STORED-PROC pc_calcula_permanencia_resgate
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_dtvencto = par_dtmvtolt + aux_qtdiaapl.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dslinxml = aux_dslinxml + 
                          "<CARENCIA>" + 
                             "<cdperapl>" + STRING(wt_carencia_aplicacao.cdperapl) +  "</cdperapl>" +
                             "<qtdiaini>" + STRING(wt_carencia_aplicacao.qtdiaini) +  "</qtdiaini>" +
                             "<qtdiafim>" + STRING(wt_carencia_aplicacao.qtdiafim) +  "</qtdiafim>" +
                             "<qtdiacar>" + STRING(wt_carencia_aplicacao.qtdiacar) +  "</qtdiacar>" +
                             "<qtdiaapl>" + STRING(aux_qtdiaapl) +  "</qtdiaapl>" +
                             "<dtvencto>" + STRING(aux_dtvencto,"99/99/9999") +  "</dtvencto>" + 
                             "<dtmvtolt>" + STRING(par_dtmvtolt,"99/99/9999") +  "</dtmvtolt>" +
                             "<dtcarenc>" + STRING(wt_carencia_aplicacao.dtcarenc,"99/99/9999") +  "</dtcarenc>" +
                             "<perirapl>" + TRIM(STRING(aux_perirapl,"zz9.99")) + "%" + "</perirapl>" +
                          "</CARENCIA>".
END.



/* Buscar a data do proximo movimento - IB125 */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_prox_data_mov
      aux_handproc = PROC-HANDLE NO-ERROR
                       (INPUT par_cdcooper, 
                        OUTPUT ?,
                        OUTPUT 0,
                        OUTPUT "").

CLOSE STORED-PROC pc_prox_data_mov
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_dtmvtopr = " "
       aux_dtmvtopr = STRING(pc_prox_data_mov.pr_dtmvtopr,"99/99/9999")
                            WHEN pc_prox_data_mov.pr_dtmvtopr <> ?.


/* Buscar qtd de meses max para agendamento - IB121 */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_cons_mes_age
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper, 
                      INPUT 90, /* cdagenci - Internet */
                      INPUT par_nrdconta, 
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_cons_mes_age
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_cons_mes_age.pr_cdcritic 
                      WHEN pc_cons_mes_age.pr_cdcritic <> ?
       aux_dscritic = pc_cons_mes_age.pr_dscritic 
                      WHEN pc_cons_mes_age.pr_dscritic <> ?
       aux_qtmesage = pc_cons_mes_age.pr_qtmesage
                      WHEN pc_cons_mes_age.pr_qtmesage <> ?.
                      
IF aux_cdcritic <> 0   OR
   aux_dscritic <> ""  THEN
   DO:
       IF aux_dscritic = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                NO-LOCK NO-ERROR.             
             IF AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar quantidade de meses para agendamento.".
END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>". 
       
       RETURN "NOK".       
   END.                      


/* Somar data de vencimento - IB107 */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }     

RUN STORED-PROCEDURE pc_soma_data_vencto
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper, 
                      INPUT par_qtdiacar,
                      INPUT aux_dtvencto,
                      OUTPUT ?,
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_soma_data_vencto
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_soma_data_vencto.pr_cdcritic 
                      WHEN pc_soma_data_vencto.pr_cdcritic <> ?
       aux_dscritic = pc_soma_data_vencto.pr_dscritic 
                      WHEN pc_soma_data_vencto.pr_dscritic <> ?
       aux_dtvencto = pc_soma_data_vencto.pr_dtvencto
                      WHEN pc_soma_data_vencto.pr_dtvencto <> ?.

IF aux_cdcritic <> 0   OR
   aux_dscritic <> ""  THEN
   DO:
       IF aux_dscritic = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                NO-LOCK NO-ERROR.             
             IF AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar data de vencimento.".
          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>". 
       
       RETURN "NOK".       
END.

IF  aux_dtvencto = ? THEN 
    ASSIGN aux_dtvencto = 01/01/2012. 
    
ASSIGN aux_dslinxml = aux_dslinxml + 
                            "<dtmvtolt>"  + STRING(par_dtmvtolt,"99/99/9999")  + "</dtmvtolt>" +
                            "<dtmvtopr>"  + aux_dtmvtopr                       + "</dtmvtopr>" +
                            "<qtmesage>"  + STRING(aux_qtmesage)               + "</qtmesage>" + 
                            "<dtvencto>"  + STRING(aux_dtvencto, "99/99/9999") + "</dtvencto>".
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dslinxml.

RETURN "OK".
