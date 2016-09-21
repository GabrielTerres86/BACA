/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank162.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonathan - RKAM
   Data    : 11/12/2015.                       Ultima atualizacao: 30/03/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Realiza a consulta para geracao do extrato de operacoes 
               de credito
   
   Alteracoes: 01/03/2016 - Ajustes realizados:
                             -> Passar corretamento o paramentro com o nome
							    da tela;
						     -> Retirado o recebimento do parametro dsiduser;
							(Adriano).

		       30/03/2016 - Incluido o recebimento do parametro dsiduser para
							utiliza-lo na geracao do nome do arquivo
			               (Adriano).
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt AS DATE                                   NO-UNDO.
DEF INPUT PARAM par_dtrefere AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_dsiduser AS CHAR                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE NO-UNDO.
DEF VAR aux_qtd_str  AS INTE NO-UNDO.
DEF VAR aux_tot_str  AS INTE NO-UNDO.
DEF VAR aux_str_min  AS INTE NO-UNDO.

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.
DEF VAR xField        AS HANDLE                                        NO-UNDO.
DEF VAR xText         AS HANDLE                                        NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO.
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO.
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_gera_extrato_op_credito
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 3, /*Internet*/
                             INPUT par_nmdatela,
                             INPUT STRING(par_dtmvtolt),
                             INPUT "IMPRES",
                             INPUT par_cdoperad,
                             INPUT par_dsiduser,
                             INPUT par_nrdconta,
                             INPUT par_dtrefere,
                             INPUT 1, /*flgrodar*/
                             INPUT 1, /*flgerlog*/
                             OUTPUT "",
                             OUTPUT "",
                             OUTPUT "",
                             OUTPUT ?,
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_gera_extrato_op_credito 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""                                             
       aux_nmarqimp = pc_gera_extrato_op_credito.pr_nmarqimp
                          WHEN pc_gera_extrato_op_credito.pr_nmarqimp <> ?
       aux_nmarqpdf = pc_gera_extrato_op_credito.pr_nmarqpdf
                          WHEN pc_gera_extrato_op_credito.pr_nmarqpdf <> ? 
       aux_cdcritic = pc_gera_extrato_op_credito.pr_cdcritic 
                          WHEN pc_gera_extrato_op_credito.pr_cdcritic <> ?
       aux_dscritic = pc_gera_extrato_op_credito.pr_dscritic
                          WHEN pc_gera_extrato_op_credito.pr_dscritic <> ? 
       xml_req      = pc_gera_extrato_op_credito.pr_clobxml. 

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
               ASSIGN aux_dscritic =  "Nao foi possivel buscar as " +
                                      "informacoes.".

         END.

      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".  

      RETURN "NOK".

   END.

/* Dividir o xml de retorno a cada 30000 caracteres */
ASSIGN aux_qtd_str = 30000
       aux_tot_str = TRUNCATE(LENGTH(xml_req) / aux_qtd_str,0) + 1
       aux_str_min = 1.

REPEAT aux_contador = 1 TO aux_tot_str:
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = SUBSTR(xml_req,aux_str_min,aux_qtd_str).
  
    ASSIGN aux_str_min = aux_str_min + aux_qtd_str.

END.
  
RETURN "OK".

/*............................................................................*/




