
/*..............................................................................

   Programa: siscaixa/web/InternetBank91.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : setembro/2014.                       Ultima atualizacao: 17/11/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar detalhes dos agendamentos de aplicacoes e resgates.
   
   Alteracoes: 17/11/2014 - Ajuste para gerar as tags que contenham data
                            de forma correta.
                            (Adriano).
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.


DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapaar.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapaar.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_flgtipar AS   INTEGER                              NO-UNDO.
DEF INPUT PARAM par_nrdocmto LIKE crapaar.nrdocmto                     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR contador AS INTEGER NO-UNDO.

ASSIGN aux_dstransa = "Leitura dos detalhes de agendamentos de aplicacoes e resgates.".

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.
                
IF VALID-HANDLE(h-b1wgen0081)  THEN
   DO: 

      RUN consulta-agendamento-det  IN h-b1wgen0081 (INPUT par_cdcooper,
                                                     INPUT 90,
                                                     INPUT 900,
                                                     INPUT "996",
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl, /*seq titular*/
                                                     INPUT par_flgtipar, /*tipo agendamento*/
                                                     INPUT par_nrdocmto, /*numero documento*/
                                                     OUTPUT TABLE tt-erro,
                                                     OUTPUT TABLE tt-agen-det).

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

      FOR EACH tt-agen-det NO-LOCK:

          CREATE xml_operacao.

          ASSIGN xml_operacao.dslinxml = "<AGENDAMENTO>" + 
               "<dtmvtolt>"  + (IF STRING(tt-agen-det.dtmvtolt) = ? THEN
                                   ""
                                ELSE
                                   STRING(tt-agen-det.dtmvtolt)) 
                              + "</dtmvtolt>" +
               "<cdagenci>"  + STRING(tt-agen-det.cdagenci) + "</cdagenci>" +
               "<cdbccxlt>"  + STRING(tt-agen-det.cdbccxlt) + "</cdbccxlt>" +
               "<nrdolote>"  + STRING(tt-agen-det.nrdolote) + "</nrdolote>" +
               "<nrdconta>"  + STRING(tt-agen-det.nrdconta) + "</nrdconta>" +
               "<nrdocmto>"  + STRING(tt-agen-det.nrdocmto) + "</nrdocmto>" +
               "<cdhistor>"  + STRING(tt-agen-det.cdhistor) + "</cdhistor>" +
               "<vllanaut>"  + TRIM(STRING(tt-agen-det.vllanaut,"zzz,zzz,zz9.99-")) + "</vllanaut>" +
               "<tpdvalor>"  + STRING(tt-agen-det.tpdvalor) + "</tpdvalor>" +
               "<insitlau>"  + STRING(tt-agen-det.insitlau) + "</insitlau>" +
               "<dtmvtopg>"  + (IF STRING(tt-agen-det.dtmvtopg) = ? THEN
                                   ""
                                ELSE 
                                   STRING(tt-agen-det.dtmvtopg))
                             + "</dtmvtopg>" +
               "<cdbccxpg>"  + STRING(tt-agen-det.cdbccxpg) + "</cdbccxpg>" +
               "<nrdctabb>"  + STRING(tt-agen-det.nrdctabb) + "</nrdctabb>" +
               "<dtdebito>"  + (IF STRING(tt-agen-det.dtdebito) = ? THEN
                                   ""
                                ELSE
                                   STRING(tt-agen-det.dtdebito))
                             + "</dtdebito>" + 
               "<nrseqlan>"  + (IF STRING(tt-agen-det.dtdebito) = ? THEN
                                   ""
                                ELSE
                                   STRING(tt-agen-det.dtdebito))
                             + "</nrseqlan>" +
               "<cdcooper>"  + STRING(tt-agen-det.cdcooper) + "</cdcooper>" +
               "<flgtipar>" + STRING(tt-agen-det.flgtipar) + "</flgtipar>" +
               "<dstipaar>" + tt-agen-det.dstipaar + "</dstipaar>" +
               "<flgtipin>" + STRING(tt-agen-det.flgtipin) + "</flgtipin>" +
               "<dstipinv>" + tt-agen-det.dstipinv + "</dstipinv>" +
               "<qtdiacar>" + STRING(tt-agen-det.qtdiacar) + "</qtdiacar>" +
               "<dssitlau>" + tt-agen-det.dssitlau + "</dssitlau>" +
               "<vlsolaar>" + TRIM(STRING(tt-agen-det.vlsolaar,"zzz,zzz,zzz,zz9.99")) + "</vlsolaar>" +
               "<dsprotoc>" + tt-agen-det.dsprotoc + "</dsprotoc>" +
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


