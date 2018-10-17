
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank83.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Maio/2014.                       Ultima atualizacao: 14/08/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Valida se existe saldo disponivel para realizar a aplicacao
               e busca tabela de rentabilidade.
   
   Alteracoes: 14/08/2018 - Inclusao da TAG <cdmsgerr> nos retornos de erro do XML,
                            Prj.427 - URA (Jean Michel)

..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_idorigem AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_vlaplica LIKE craprda.vlaplica                     NO-UNDO.
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
       aux_dscritic = TRIM(pc_obtem_dias_carencia_wt.pr_dscritic)
                          WHEN pc_obtem_dias_carencia_wt.pr_dscritic <> ?. 

IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
   DO:
       IF TRIM(aux_dscritic) = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
             
             IF AVAILABLE crapcri THEN
                ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar o periodo de carencia.".
          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                             "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".

       RETURN "NOK".
       
   END.

FIND FIRST wt_carencia_aplicacao NO-LOCK NO-ERROR.

IF NOT AVAIL wt_carencia_aplicacao THEN
   DO:
      ASSIGN aux_dscritic = "Nao foi possivel consultar o periodo de carencia."
             xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                            "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".

      RETURN "NOK".

   END.
 
ASSIGN aux_dslinxml = "".

FOR EACH wt_carencia_aplicacao NO-LOCK:
   
   ASSIGN aux_txaplica = 0
          aux_txaplmes = 0
          aux_dsaplica = ""
          aux_cdcritic = 0
          aux_dscritic = "".

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }  

   RUN STORED-PROCEDURE pc_obtem_taxa_aplicacao
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
                                INPUT wt_carencia_aplicacao.cdperapl,
                                INPUT par_vlaplica,
                                INPUT par_flgerlog,
                                OUTPUT 0,
                                OUTPUT 0,
                                OUTPUT "",
                                OUTPUT 0,
                                OUTPUT "").  

   CLOSE STORED-PROC pc_obtem_taxa_aplicacao
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
   
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   
   ASSIGN aux_txaplica = pc_obtem_taxa_aplicacao.pr_txaplica
                             WHEN pc_obtem_taxa_aplicacao.pr_txaplica <> ?

          aux_txaplmes = pc_obtem_taxa_aplicacao.pr_txaplmes
                             WHEN pc_obtem_taxa_aplicacao.pr_txaplmes <> ?

          aux_dsaplica = pc_obtem_taxa_aplicacao.pr_dsaplica
                             WHEN pc_obtem_taxa_aplicacao.pr_dsaplica <> ?

          aux_cdcritic = pc_obtem_taxa_aplicacao.pr_cdcritic 
                             WHEN pc_obtem_taxa_aplicacao.pr_cdcritic <> ?

          aux_dscritic = TRIM(pc_obtem_taxa_aplicacao.pr_dscritic)
                             WHEN pc_obtem_taxa_aplicacao.pr_dscritic <> ?.

   IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> ""  THEN
      DO:
          IF TRIM(aux_dscritic) = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
                
                IF AVAILABLE crapcri THEN
                   ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
                ELSE
                   ASSIGN aux_dscritic = "Nao foi possivel consultar a taxa da aplicacao.".

             END.

          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                                "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".
          
          RETURN "NOK".
                         
      END.
      
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }  

   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_qtdiaapl = wt_carencia_aplicacao.qtdiafim
          aux_qtdiacar = wt_carencia_aplicacao.qtdiacar.

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
   
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   ASSIGN aux_cdcritic = pc_calcula_permanencia_resgate.pr_cdcritic 
                             WHEN pc_calcula_permanencia_resgate.pr_cdcritic <> ?

          aux_dscritic = TRIM(pc_calcula_permanencia_resgate.pr_dscritic)
                             WHEN pc_calcula_permanencia_resgate.pr_dscritic <> ?
          aux_qtdiaapl = pc_calcula_permanencia_resgate.pr_qtdiaapl
                             WHEN pc_calcula_permanencia_resgate.pr_qtdiaapl <> ?
          aux_dtvencto = pc_calcula_permanencia_resgate.pr_dtvencto
                             WHEN pc_calcula_permanencia_resgate.pr_dtvencto <> ?.

   IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> ""  THEN
      DO:
          IF TRIM(aux_dscritic) = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
                
                IF AVAILABLE crapcri THEN
                   ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
                ELSE
                   ASSIGN aux_dscritic = "Nao foi possivel consultar a taxa da aplicacao.".

             END.

          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                                "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".
          
          RETURN "NOK".
                         
      END.

   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_perirapl = 0.

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }  

   RUN STORED-PROCEDURE pc_busca_aliquota_ir_rdc
       aux_handproc = PROC-HANDLE NO-ERROR
                               (INPUT par_cdcooper, 
                                INPUT aux_dtvencto,
                                INPUT par_dtmvtolt,
                                OUTPUT 0,
                                OUTPUT 0,
                                OUTPUT "").  
   
   CLOSE STORED-PROC pc_busca_aliquota_ir_rdc
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
   
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   ASSIGN aux_cdcritic = pc_busca_aliquota_ir_rdc.pr_cdcritic 
                         WHEN pc_busca_aliquota_ir_rdc.pr_cdcritic <> ?
          aux_dscritic = TRIM(pc_busca_aliquota_ir_rdc.pr_dscritic)
                         WHEN pc_busca_aliquota_ir_rdc.pr_dscritic <> ?
          aux_perirapl = pc_busca_aliquota_ir_rdc.pr_perirapl
                         WHEN pc_busca_aliquota_ir_rdc.pr_perirapl <> ?.
   
   IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
      DO:
          IF TRIM(aux_dscritic) = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
                
                IF AVAILABLE crapcri THEN
                   ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
                ELSE
                   ASSIGN aux_dscritic = "Nao foi possivel consultar a taxa de aliquota do IR".
             END.

          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                                "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".
          
          RETURN "NOK".
                         
      END.

   ASSIGN aux_dslinxml = aux_dslinxml + 
                         "<CARENCIA>" + 
                            "<cdperapl>" + STRING(wt_carencia_aplicacao.cdperapl) +  "</cdperapl>" +
                            "<qtdiaini>" + STRING(wt_carencia_aplicacao.qtdiaini) +  "</qtdiaini>" +
                            "<qtdiafim>" + STRING(wt_carencia_aplicacao.qtdiafim) +  "</qtdiafim>" +
                            "<qtdiacar>" + STRING(wt_carencia_aplicacao.qtdiacar) +  "</qtdiacar>" +
                            "<txaplica>" + TRIM(STRING(aux_txaplica,"zz9.99")) + "%" + "</txaplica>" +
                            "<txaplmes>" + TRIM(STRING(aux_txaplmes,"zz9.99")) + "%" + "</txaplmes>" +
                            "<dsaplica>" + aux_dsaplica +  "</dsaplica>" +
                            "<qtdiaapl>" + STRING(aux_qtdiaapl) +  "</qtdiaapl>" +
                            "<dtvencto>" + STRING(aux_dtvencto,"99/99/9999") +  "</dtvencto>" +
                            "<dtmvtolt>" + STRING(par_dtmvtolt,"99/99/9999") +  "</dtmvtolt>" +
                            "<dtcarenc>" + STRING(wt_carencia_aplicacao.dtcarenc,"99/99/9999") +  "</dtcarenc>" +
                            "<perirapl>" + TRIM(STRING(aux_perirapl,"zz9.99")) + "%" + "</perirapl>" +
                         "</CARENCIA>".

END.

CREATE xml_operacao.
    
ASSIGN xml_operacao.dslinxml = aux_dslinxml.

RETURN "OK".

/*............................................................................*/