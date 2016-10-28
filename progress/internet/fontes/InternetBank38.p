/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank38.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2008.                       Ultima atualizacao: 19/09/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Obter dados dos agendamentos para listar no InternetBank.
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               04/10/2011 - Adicioando parametros de retorno xml referente aos 
                            campos nmprepos, nrcpfpre, nmoperad e nrcpfope
                            (Jorge).
                            
               09/01/2012 - Adicionado parametro de retorno xml referente ao
                            campo idtitdda. (Jorge)
                            
               24/04/2013 - Transferencia intercooperativa (Gabriel).
               
               29/10/2015 - Tratando a data de transacao para evitar erro
                            na montagem do XML. (Andre Santos - SUPERO) 
                            
               01/12/2015 - Retirar mascara no numero do documento para evitar
                            erro no cancelamento do agendamento via app
                            mobile (David).
 
		       04/05/2016 - Incluido a saida do campo cdageban
							(Adriano - M117).
              
           16/05/2016 - Incluido o parametro par_flmobile e verificacao do mesmo
                        para nao carregar os agendamentos de TED (Carlos)
                        
               27/06/2016 - Retornar agendamentos de TED para canal Mobile 
                            (David).         

               19/09/2016 - Altera�oes pagamento/agendamento de DARF/DAS 
                            pelo InternetBanking (Projeto 338 - Lucas Lunelli)

..............................................................................*/
 
create widget-pool.
 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0016tt.i }
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0016 AS HANDLE                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_qttotage AS INTE                                           NO-UNDO.
DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_dtageini LIKE craplau.dtmvtopg                    NO-UNDO.
DEF  INPUT PARAM par_dtagefim LIKE craplau.dtmvtopg                    NO-UNDO.
DEF  INPUT PARAM par_insitlau LIKE craplau.insitlau                    NO-UNDO.
DEF  INPUT PARAM par_iniconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGICAL                               NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao38.

RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.

IF  VALID-HANDLE(h-b1wgen0016)  THEN
    DO:
        RUN obtem-agendamentos IN h-b1wgen0016 
                                        (INPUT par_cdcooper,
                                         INPUT 90,          /** PAC   **/
                                         INPUT 900,         /** CAIXA **/
                                         INPUT par_nrdconta,
                                         INPUT "INTERNET",  /** ORIGEM **/
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtageini,
                                         INPUT par_dtagefim,
                                         INPUT par_insitlau,
                                         INPUT par_iniconta,
                                         INPUT par_nrregist,
                                        OUTPUT aux_dstransa,
                                        OUTPUT aux_dscritic,
                                        OUTPUT aux_qttotage,
                                        OUTPUT TABLE tt-dados-agendamento).
        DELETE PROCEDURE h-b1wgen0016.
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
            
        FOR EACH tt-dados-agendamento NO-LOCK:
            
            CREATE xml_operacao38.
            ASSIGN xml_operacao38.dscabini = "<AGENDAMENTO>"
                   xml_operacao38.tpcaptur = "<tpcaptur>" + STRING(tt-dados-agendamento.tpcaptur)                        + "</tpcaptur>"
                   xml_operacao38.nmprimtl = "<nmprimtl>" + STRING(tt-dados-agendamento.nmprimtl)                        + "</nmprimtl>"
                   xml_operacao38.dtmvtage = "<dtmvtage>" + STRING(tt-dados-agendamento.dtmvtage,"99/99/9999")           + "</dtmvtage>"
                   xml_operacao38.dtmvtopg = "<dtmvtopg>" + STRING(tt-dados-agendamento.dtmvtopg,"99/99/9999")           + "</dtmvtopg>"
                   xml_operacao38.vllanaut = "<vllanaut>" + TRIM(STRING(tt-dados-agendamento.vllanaut,"zzz,zzz,zz9.99")) + "</vllanaut>"
                   xml_operacao38.dttransa = "<dttransa>" + (IF  tt-dados-agendamento.dttransa = ?  THEN ""
                                                             ELSE STRING(tt-dados-agendamento.dttransa,"99/99/9999"))    + "</dttransa>"
                   xml_operacao38.hrtransa = "<hrtransa>" + STRING(tt-dados-agendamento.hrtransa,"HH:MM:SS")             + "</hrtransa>"
                   xml_operacao38.nrdocmto = "<nrdocmto>" + TRIM(STRING(tt-dados-agendamento.nrdocmto, "zzzzzzzzzzz9"))  + "</nrdocmto>"  
                   xml_operacao38.dssitlau = "<dssitlau>" + STRING(tt-dados-agendamento.dssitlau)                        + "</dssitlau>"
                   xml_operacao38.dslindig = "<dslindig>" + STRING(tt-dados-agendamento.dslindig)                        + "</dslindig>"
                   xml_operacao38.dscedent = "<dscedent>" + STRING(tt-dados-agendamento.dscedent)                        + "</dscedent>" 
                   xml_operacao38.dtvencto = "<dtvencto>" + (IF  tt-dados-agendamento.dtvencto = ?  THEN "" 
                                                             ELSE STRING(tt-dados-agendamento.dtvencto,"99/99/9999"))    + "</dtvencto>"
                   xml_operacao38.nrctadst = "<nrctadst>" + STRING(tt-dados-agendamento.nrctadst)                        + "</nrctadst>"
                   xml_operacao38.cdtiptra = "<cdtiptra>" + STRING(tt-dados-agendamento.cdtiptra,"99")                   + "</cdtiptra>"
                   xml_operacao38.dstiptra = "<dstiptra>" + STRING(tt-dados-agendamento.dstiptra)                        + "</dstiptra>"
                   xml_operacao38.incancel = "<incancel>" + STRING(tt-dados-agendamento.incancel,"9")                    + "</incancel>"
                   xml_operacao38.qttotage = "<qttotage>" + TRIM(STRING(aux_qttotage,"zzzzzzzzzzz9"))                    + "</qttotage>"
                   xml_operacao38.nmprepos = "<nmprepos>" + STRING(tt-dados-agendamento.nmprepos)                        + "</nmprepos>"
                   xml_operacao38.nrcpfpre = "<nrcpfpre>" + STRING(tt-dados-agendamento.nrcpfpre)                        + "</nrcpfpre>"
                   xml_operacao38.nmoperad = "<nmoperad>" + STRING(tt-dados-agendamento.nmoperad)                        + "</nmoperad>"
                   xml_operacao38.nrcpfope = "<nrcpfope>" + STRING(tt-dados-agendamento.nrcpfope)                        + "</nrcpfope>"
                   xml_operacao38.idtitdda = "<idtitdda>" + STRING(tt-dados-agendamento.idtitdda)                        + "</idtitdda>"
                   xml_operacao38.dsageban = "<dsageban>" + STRING(tt-dados-agendamento.dsageban)                        + "</dsageban>"
                   xml_operacao38.cdageban = "<cdageban>" + STRING(tt-dados-agendamento.cdageban)                        + "</cdageban>"
                   /* DARF/DAS */
                   xml_operacao38.dstipcat = "<dstipcat>" + STRING(tt-dados-agendamento.dstipcat)                        + "</dstipcat>"
                   xml_operacao38.dsidpgto = "<dsidpgto>" + STRING(tt-dados-agendamento.dsidpgto)                        + "</dsidpgto>"
                   xml_operacao38.dsnomfon = "<dsnomfon>" + STRING(tt-dados-agendamento.dsnomfon)                        + "</dsnomfon>"
                   xml_operacao38.vlprinci = "<vlprinci>" + TRIM(STRING(tt-dados-agendamento.vlprinci,"zzz,zzz,zz9.99")) + "</vlprinci>"
                   xml_operacao38.vlrmulta = "<vlrmulta>" + TRIM(STRING(tt-dados-agendamento.vlrmulta,"zzz,zzz,zz9.99")) + "</vlrmulta>"
                   xml_operacao38.vlrjuros = "<vlrjuros>" + TRIM(STRING(tt-dados-agendamento.vlrjuros,"zzz,zzz,zz9.99")) + "</vlrjuros>"
                   xml_operacao38.vlrtotal = "<vlrtotal>" + TRIM(STRING(tt-dados-agendamento.vlrtotal,"zzz,zzz,zz9.99")) + "</vlrtotal>"
                   xml_operacao38.vlrrecbr = "<vlrrecbr>" + TRIM(STRING(tt-dados-agendamento.vlrrecbr,"zzz,zzz,zz9.99")) + "</vlrrecbr>"
                   xml_operacao38.vlrperce = "<vlrperce>" + TRIM(STRING(tt-dados-agendamento.vlrperce,"zzz,zzz,zz9.99")) + "</vlrperce>"
                   xml_operacao38.cdreceit = "<cdreceit>" + TRIM(STRING(tt-dados-agendamento.cdreceit,"zzzzzzzzzzzzz9")) + "</cdreceit>"
                   xml_operacao38.nrrefere = "<nrrefere>" + TRIM(STRING(tt-dados-agendamento.nrrefere,"zzzzzzzzzzzzzzzzzzz9")) + "</nrrefere>"
                   xml_operacao38.dtagenda = "<dtagenda>" + (IF  tt-dados-agendamento.dtagenda = ?  THEN "" 
                                                             ELSE STRING(tt-dados-agendamento.dtagenda,"99/99/9999"))    + "</dtagenda>"
                   xml_operacao38.dtperiod = "<dtperiod>" + (IF  tt-dados-agendamento.dtperiod = ?  THEN "" 
                                                             ELSE STRING(tt-dados-agendamento.dtperiod,"99/99/9999"))    + "</dtperiod>"
                   xml_operacao38.dtvendrf = "<dtvendrf>" + STRING(tt-dados-agendamento.dtvendrf,"99/99/9999")           + "</dtvendrf>"
                   xml_operacao38.nrcpfcgc = "<nrcpfcgc>" + STRING(tt-dados-agendamento.nrcpfcgc)                        + "</nrcpfcgc>"
                   xml_operacao38.dscabfim = "</AGENDAMENTO>".
                   
                   RUN proc_geracao_log (INPUT TRUE). 
        END.
             
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
                                          INPUT aux_datdodia,
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
