/*..............................................................................

 Programa: siscaixa/web/InternetBank109.p
 Sistema : Internet - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Tiago
 Data    : setembro/2014.                       Ultima atualizacao: 04/09/2014

 Dados referentes ao programa:

 Frequencia: Sempre que for chamado (On-Line)
 Objetivo  : Buscar intervalo de dias entre duas datas.

 Alteracoes: 
..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_numrdias AS INTEGER                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapaar.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapaar.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtiniitr AS   DATE                                 NO-UNDO.
DEF INPUT PARAM par_dtfinitr AS   DATE                                 NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR contador AS INTEGER NO-UNDO.

ASSIGN aux_dstransa = "Consulta intervalo de dias entre duas datas.".

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_intervalo_dias
      aux_handproc = PROC-HANDLE NO-ERROR
                       (INPUT par_dtiniitr, 
                        INPUT par_dtfinitr,
                        OUTPUT 0).

CLOSE STORED-PROC pc_intervalo_dias
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

ASSIGN aux_numrdias = 0
       aux_numrdias = pc_intervalo_dias.pr_numrdias
                      WHEN pc_intervalo_dias.pr_numrdias <> ?.


CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DADOS>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<AGENDAMENTO>" + 
     "<numrdias>"  + STRING(aux_numrdias) + "</numrdias>" +
   "</AGENDAMENTO>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</DADOS>".

RUN proc_geracao_log (INPUT TRUE). 

RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

  DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.

  RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
      SET h-b1wgen0014.

  IF  VALID-HANDLE(h-b1wgen0014)  THEN
      DO:
          RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                        INPUT "996",
                                        INPUT aux_dscritic,
                                        INPUT "INTERNET",
                                        INPUT aux_dstransa,
                                        INPUT TODAY,
                                        INPUT par_flgtrans,
                                        INPUT TIME,
                                        INPUT par_idseqttl,
                                        INPUT "INTERNETBANK",
                                        INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).

          DELETE PROCEDURE h-b1wgen0014.
      END.

END PROCEDURE.

/*............................................................................*/


