/*..............................................................................

   Programa: internet/fontes/InternetBank121.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Julho/2014.                       Ultima atualizacao: 17/09/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar qtd de meses max para agendamento.
   
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
DEF VAR aux_qtmesage AS INTEGER                                        NO-UNDO.

DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper                 NO-UNDO.
DEF INPUT PARAM par_cdagenci  LIKE    crapage.cdagenci                 NO-UNDO.
DEF INPUT PARAM par_idseqttl  LIKE    crapttl.idseqttl                 NO-UNDO.
DEF INPUT PARAM par_nrdconta  LIKE    crapass.nrdconta                 NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Busca quantidade de meses max para agendamentos.".

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.
                
IF VALID-HANDLE(h-b1wgen0081)  THEN
   DO: 

      RUN cons-qtd-mes-age
          IN h-b1wgen0081 (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdconta,
                           INPUT "966",  
                           INPUT "INTERNETBANK",
                           INPUT 3,
                           OUTPUT aux_qtmesage,
                           OUTPUT TABLE tt-erro).

      DELETE PROCEDURE h-b1wgen0081.
         
      IF RETURN-VALUE = "NOK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar quantidade de meses para agendamento.".
                 
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

             RUN proc_geracao_log (INPUT FALSE).
             
             RETURN "NOK".
         END.

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<DADOS>".

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<AGENDAMENTO>" + 
               "<qtmesage>"  + STRING(aux_qtmesage) + "</qtmesage>" + 
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





