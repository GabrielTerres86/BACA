/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank86.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Junho/2014.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Realiza o calculo da permanencia para resgate
   
   Alteracoes: 

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
DEF INPUT PARAM par_tpaplica AS INT                                    NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_flgerlog AS INT                                    NO-UNDO.
DEF INPUT PARAM par_qtdiaapl AS INT                                    NO-UNDO.
DEF INPUT PARAM par_qtdiacar AS INT                                    NO-UNDO.
DEF INPUT PARAM par_dtvencto AS DATE                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdiaapl AS INT                                            NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.
DEF VAR aux_perirapl AS DEC                                            NO-UNDO.

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
                             INPUT par_qtdiacar,
                             INPUT-OUTPUT par_qtdiaapl,
                             INPUT-OUTPUT par_dtvencto,
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_calcula_permanencia_resgate
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_dslinxml = ""
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_calcula_permanencia_resgate.pr_cdcritic 
                          WHEN pc_calcula_permanencia_resgate.pr_cdcritic <> ?
       aux_dscritic = pc_calcula_permanencia_resgate.pr_dscritic
                          WHEN pc_calcula_permanencia_resgate.pr_dscritic <> ?
       aux_qtdiaapl = pc_calcula_permanencia_resgate.pr_qtdiaapl
                          WHEN pc_calcula_permanencia_resgate.pr_qtdiaapl <> ?
       aux_dtvencto = pc_calcula_permanencia_resgate.pr_dtvencto
                          WHEN pc_calcula_permanencia_resgate.pr_dtvencto <> ?.

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
               ASSIGN aux_dscritic = "Nao foi possivel validar a permanencia" +
                                     " para resgate.".

         END.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".  
      
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

       aux_dscritic = pc_busca_aliquota_ir_rdc.pr_dscritic
                      WHEN pc_busca_aliquota_ir_rdc.pr_dscritic <> ?
       aux_perirapl = pc_busca_aliquota_ir_rdc.pr_perirapl
                      WHEN pc_busca_aliquota_ir_rdc.pr_perirapl <> ?.

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
                                      "a taxa de aliquota do IR".
          
          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
       
       RETURN "NOK".
                      
   END.

CREATE xml_operacao.


ASSIGN xml_operacao.dslinxml = "<PERMANENCIA>" + 
                                   "<qtdiaapl>" + STRING(aux_qtdiaapl) + "</qtdiaapl>" +
                                   "<dtresgat>" + STRING(aux_dtvencto,"99/99/9999") + "</dtresgat>" +
                                   "<perirapl>" + TRIM(STRING(aux_perirapl,"zz9.99")) + "%" + "</perirapl>" +
                               "</PERMANENCIA>".


RETURN "OK".


/*............................................................................*/




