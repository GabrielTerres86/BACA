/*..............................................................................

   Programa: siscaixa/web/InternetBank91.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Julho/2014.                       Ultima atualizacao: 27/01/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar agendamentos de aplicacoes e resgates.
   
   Alteracoes: 27/01/2016 - Desconsiderar sequencia de titular. 
                            Projeto 131 Assinatura Conjunta (David).
   
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

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_flgtipar AS   INTEGER                              NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapaar.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapaar.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_nrctraar LIKE crapaar.nrctraar                     NO-UNDO.
DEF INPUT PARAM par_cdsitaar LIKE crapaar.cdsitaar                     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR contador AS INTEGER NO-UNDO.

ASSIGN aux_dstransa = "Leitura de agendamentos de aplicacoes e resgates.".


FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.
                
IF VALID-HANDLE(h-b1wgen0081)  THEN
   DO: 

      RUN consulta-agendamento  IN h-b1wgen0081 (INPUT par_cdcooper,
                                                 INPUT 90,
                                                 INPUT 900,
                                                 INPUT "996",
                                                 INPUT par_nrdconta,
                                                 INPUT 0, /*seq titular*/
                                                 INPUT par_nrctraar, /*cod agendamento*/
                                                 INPUT par_flgtipar, /*tipo agendamento*/
                                                 INPUT par_cdsitaar, /*situacao*/
                                                 INPUT "InternetBank", /*cdprogra*/
                                                 INPUT 3, /*origem*/ 
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT TABLE tt-agendamento).

      DELETE PROCEDURE h-b1wgen0081.
         
      IF RETURN-VALUE = "NOK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar agendamentos.".
                 
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

             RUN proc_geracao_log (INPUT FALSE).
             
             RETURN "NOK".
         END.

      CREATE xml_operacao.

      ASSIGN xml_operacao.dslinxml = "<DADOS>".

      FOR EACH tt-agendamento NO-LOCK:

         CREATE xml_operacao.

         ASSIGN xml_operacao.dslinxml = "<AGENDAMENTO>" + 
               "<cdcooper>"  + STRING( tt-agendamento.cdcooper) + "</cdcooper>" +
               "<cdageass>"  + STRING( tt-agendamento.cdageass) + "</cdageass>" +
               "<cdagenci>"  + STRING( tt-agendamento.cdagenci) + "</cdagenci>" +
               "<cdoperad>"  + tt-agendamento.cdoperad + "</cdoperad>" +
               "<cdsitaar>"  + STRING( tt-agendamento.cdsitaar) + "</cdsitaar>" +
               "<flgctain>"  + STRING( tt-agendamento.flgctain, "1/0") + "</flgctain>" +
               "<flgresin>"  + STRING( tt-agendamento.flgresin, "1/0") + "</flgresin>" +
               "<flgtipar>"  + STRING( tt-agendamento.flgtipar, "1/0") + "</flgtipar>" +
               "<flgtipin>"  + STRING( tt-agendamento.flgtipin, "1/0") + "</flgtipin>" +
               "<hrtransa>"  + STRING( tt-agendamento.hrtransa) + "</hrtransa>" +
               "<idseqttl>"  + STRING( tt-agendamento.idseqttl) + "</idseqttl>" +
               "<nrctraar>"  + STRING( tt-agendamento.nrctraar) + "</nrctraar>" +
               "<nrdconta>"  + STRING( tt-agendamento.nrdconta) + "</nrdconta>" +
               "<nrdocmto>"  + STRING( tt-agendamento.nrdocmto) + "</nrdocmto>" +
               "<nrmesaar>"  + STRING( tt-agendamento.nrmesaar) + "</nrmesaar>" +
               "<qtdiacar>"  + STRING( tt-agendamento.qtdiacar) + "</qtdiacar>" +
               "<qtmesaar>"  + STRING( tt-agendamento.qtmesaar) + "</qtmesaar>" +
               "<vlparaar>"  + TRIM(STRING(tt-agendamento.vlparaar,"zzz,zzz,zz9.99-")) + "</vlparaar>".

         IF tt-agendamento.dtcancel <> ? THEN
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtcancel>" + STRING(tt-agendamento.dtcancel, "99/99/9999") + "</dtcancel>".
         ELSE
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtcancel></dtcancel>".

         IF tt-agendamento.dtcarenc <> ? THEN
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtcarenc>" + STRING(tt-agendamento.dtcarenc, "99/99/9999") + "</dtcarenc>".
         ELSE
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtcarenc></dtcarenc>".

         IF tt-agendamento.dtiniaar <> ? THEN
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtiniaar>" + STRING(tt-agendamento.dtiniaar, "99/99/9999") + "</dtiniaar>".
         ELSE
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtiniaar></dtiniaar>".

         IF tt-agendamento.dtvencto <> ? THEN
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtvencto>" + STRING(tt-agendamento.dtvencto, "99/99/9999") + "</dtvencto>".
         ELSE
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtvencto></dtvencto>".

         IF tt-agendamento.dtmvtolt <> ? THEN
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtmvtolt>" + STRING(tt-agendamento.dtmvtolt, "99/99/9999") + "</dtmvtolt>".
         ELSE
            ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<dtmvtolt></dtmvtolt>".
            
         ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + 
                                        "<incancel>" + STRING(tt-agendamento.incancel) + "</incancel>" +
                                        "<dssitaar>" + tt-agendamento.dssitaar + "</dssitaar>" +
                                        "<dstipaar>" + tt-agendamento.dstipaar + "</dstipaar>" +
                                        "</AGENDAMENTO>". 

      END.

      
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

