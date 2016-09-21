
/*..............................................................................

   Programa: siscaixa/web/InternetBank97.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Julho/2014.                       Ultima atualizacao: 29/08/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Somar data de vencimento.
   
   Alteracoes: 
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }


DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.

DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper                 NO-UNDO.
DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta                 NO-UNDO.
DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl                 NO-UNDO.
DEF INPUT PARAM par_qtdiacar  LIKE    crapaar.qtdiacar                 NO-UNDO.
DEF INPUT PARAM par_dtiniaar  LIKE    crapaar.dtiniaar                 NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Soma parametro de qtd de dias vencto na data de efetivacao do agendamento.".

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.
                
IF VALID-HANDLE(h-b1wgen0081)  THEN
   DO: 

      RUN soma-data-vencto
          IN h-b1wgen0081 (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_qtdiacar,
                           INPUT par_dtiniaar,
                           INPUT "966",  
                           INPUT "INTERNETBANK",
                           INPUT 3,
                           OUTPUT aux_dtvencto,
                           OUTPUT TABLE tt-erro).

      DELETE PROCEDURE h-b1wgen0081.
         
      IF RETURN-VALUE = "NOK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar data de vencimento.".
                 
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

             RUN proc_geracao_log (INPUT FALSE).
             
             RETURN "NOK".
         END.

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<DADOS>".

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<AGENDAMENTO>" + 
             "<dtvencto>"  + IF aux_dtvencto <> ? THEN STRING( aux_dtvencto, "99/99/9999" ) ELSE "01/01/2012". 
      ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</dtvencto>" + 
         "</AGENDAMENTO>". 

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "</DADOS>".

      RUN proc_geracao_log (INPUT TRUE). 

      RETURN "OK".
   END.


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




