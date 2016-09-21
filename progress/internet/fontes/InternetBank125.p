/*..............................................................................

 Programa: siscaixa/web/InternetBank125.p
 Sistema : Internet - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Tiago
 Data    : outubro/2014.                       Ultima atualizacao: 06/10/2014

 Dados referentes ao programa:

 Frequencia: Sempre que for chamado (On-Line)
 Objetivo  : Buscar a data do proximo movimento

 Alteracoes: 
..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dtmvtopr AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapaar.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapaar.idseqttl                     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR contador AS INTEGER NO-UNDO.

ASSIGN aux_dstransa = "Consulta proximo dia de movimento.".

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.

IF VALID-HANDLE(h-b1wgen0081)  THEN
   DO:

      RUN busca-proxima-data-movimento
          IN h-b1wgen0081 (INPUT par_cdcooper,
                           OUTPUT aux_dtmvtopr).
      
      DELETE PROCEDURE h-b1wgen0081.

      IF RETURN-VALUE = "NOK" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi consultar data do proximo vencimento.".

             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

             RUN proc_geracao_log (INPUT FALSE).

             RETURN "NOK".
         END.

      RUN proc_geracao_log (INPUT TRUE). 
      
   END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DADOS>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<AGENDAMENTO>" + 
     "<dtmvtopr>"  + aux_dtmvtopr + "</dtmvtopr>" +
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



