/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank23.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2007.                       Ultima atualizacao: 29/02/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Listar contas destino para transferencia via Internet.
   
   Alteracoes: 10/08/2007 - Alterado para usar os horarios de disponibilidade
                            da transferencia (Evandro).

               28/09/2007 - Acrescentada validacao pela procedure da BO 15
                            verifica_operacao (David).

               09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
               
               06/03/2008 - Utilizar include de temp-tables (David).
               
               24/04/2008 - Adaptacao para agendamentos (David).
               
               25/06/2008 - Nova procedures para obter contas destino (David).
                            
               03/11/2008 - Inclusao widget-pool (martin)
               
               27/07/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               25/01/2010 - Retirado by no for each tt-contas-destino(Guilherme)
               
               04/11/2010 - Criar novo registro na temp-table para cada linha
                            do XML (David).
                            
               05/10/2011 - Parametro cpf operador na verifica_operacao
                            (Guilherme).
                            
               14/05/2012 - Projeto TED Internet (David).
               
               26/03/2013 - Transferencia intecooperativa (Gabriel).
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               30/06/2014 - Retornar a situacao do beneficiario da TED
                            (Chamado 161848) (Jonata - RKAM).
                            
               20/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)                
                            
               20/04/2015 - Inclusão do campos de tipo de Transação nos limites.
                            (Dionathan)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
                            
               20/01/2016 - Ajuste para chamada efetuada por operador PJ.
                            Projeto 131 - Assinatura Conjunta (David).
                            
               17/02/2016 - Melhorias para o envio e cadastro de contas para
                            efetivar TED, M. 118 (Jean Michel).
                            
               29/02/2016 - Inclusão da lista de Bancos para cadastro de favorecido
                            via Mobile (Dionathan)
                            
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0142tt.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0142 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_tppeslst AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_tpoperac AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_intipdif LIKE crapcti.intipdif                    NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_nmtitpes LIKE crapcti.nmtitula                    NO-UNDO.
DEF INPUT  PARAM par_flgpesqu AS LOGI                                  NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF  par_flgpesqu  THEN
    ASSIGN aux_dstransa = "Consulta favorecidos".
ELSE
IF  par_tpoperac = 1  THEN
    ASSIGN aux_dstransa = "Acesso a tela de transferencias".
ELSE
    ASSIGN aux_dstransa = "Acesso a tela de TED".

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
    DO: 
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".
                              
        RUN proc_geracao_log (INPUT FALSE).                      
                                   
        RETURN "NOK".
    END.

IF  NOT par_flgpesqu  THEN
    DO:
        RUN verifica_operacao IN h-b1wgen0015 
                              (INPUT par_cdcooper,
                               INPUT 90,           /** PA           **/
                               INPUT 900,          /** CAIXA         **/
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT 0,            /** AGENDAMENTO   **/
                               INPUT par_dtmvtolt, /** DATA DEBITO   **/
                               INPUT 0,            /** VALOR OPER.   **/
                               INPUT 0,            /** BANCO DESTINO **/
                               INPUT 0,            /** AGENC.DESTINO **/
                               INPUT 0,            /** CONTA DESTINO **/
                               INPUT 0,            /** IND.TRANSACAO **/
                               INPUT "996",        /** OPERADOR      **/
                               INPUT par_tpoperac,
                               INPUT FALSE,        /** VALIDACOES    **/
                               INPUT "INTERNET",   /** ORIGEM        **/
                               INPUT par_nrcpfope, /** CPF OPERADOR  **/
                               INPUT TRUE,         /** VALIDA LIMITES**/
                              OUTPUT aux_dstrans1,
                              OUTPUT aux_dscritic,
                              OUTPUT TABLE tt-limite,
                              OUTPUT TABLE tt-limites-internet).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0015.
                
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
                
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<LIMITE>".
        
        FIND FIRST tt-limite NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-limite  THEN
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<hrinipag>" +
                                               tt-limite.hrinipag +
                                               "</hrinipag><hrfimpag>" +
                                               tt-limite.hrfimpag +
                                               "</hrfimpag><idesthor>" +
                                               STRING(tt-limite.idesthor) +
                                               "</idesthor><qtmesagd>" +
                                               STRING(tt-limite.qtmesagd) +
                                               "</qtmesagd><iddiauti>" +
                                               STRING(tt-limite.iddiauti) +
                                               "</iddiauti>".
            END.
        
        IF  par_nrcpfope = 0  THEN
            FIND FIRST tt-limites-internet 
                 WHERE tt-limites-internet.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
        ELSE
            FIND FIRST tt-limites-internet NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-limites-internet  THEN
                DO:
                    CREATE xml_operacao.
                    ASSIGN xml_operacao.dslinxml = "<vllimted>" +
                                        TRIM(STRING(tt-limites-internet.vllimted,
                                                    "zzz,zzz,zz9.99-")) +
                                                   "</vllimted><vldspted>" +
                                        TRIM(STRING(tt-limites-internet.vldspted,
                                                    "zzz,zzz,zz9.99-")) +
                                                   "</vldspted>".
                END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<cdtiptra>" + "1" +
									   "</cdtiptra><dstiptra>" +
                                       "TRANSFERENCIA" + "</dstiptra></LIMITE>".
    END.
         
RUN consulta-contas-cadastradas IN h-b1wgen0015 
                               (INPUT par_cdcooper,
                                INPUT 90,             /** PA      **/
                                INPUT 900,            /** Caixa    **/
                                INPUT "996",          /** Operador **/
                                INPUT "INTERNETBANK", /** Tela     **/
                                INPUT 3,              /** Origem   **/
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_dtmvtolt,
                                INPUT par_tppeslst,
                                INPUT par_intipdif, /** Outras IF's **/
                                INPUT par_nmtitpes,
                               OUTPUT TABLE tt-contas-cadastradas).
                                                                                    
IF  NOT TEMP-TABLE tt-contas-cadastradas:HAS-RECORDS  THEN
    DO:
        IF  par_flgpesqu  THEN
            ASSIGN aux_dscritic = "Nenhum favorecido foi encontrado para o " +
                                  "nome informado.".
        ELSE
        IF   par_tpoperac <> 1 AND par_tpoperac <> 5 AND par_tpoperac <> 4 THEN
            ASSIGN aux_dscritic = "Sua conta nao possui favorecidos " +
                   "cadastrados.\nAcesse o link para cadastramento " +
                   "do favorecido ou entre em contato com seu PA.".

        IF  aux_dscritic <> ""   THEN
            DO:
                DELETE PROCEDURE h-b1wgen0015.
                
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".
                                  
                RUN proc_geracao_log (INPUT FALSE).                      
                                       
                RETURN "NOK".
            END.           
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<CONTAS_DESTINO>".

FOR EACH tt-contas-cadastradas NO-LOCK BY tt-contas-cadastradas.nmtitula:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS><nrctatrf>" +
                                   STRING(tt-contas-cadastradas.nrctatrf) +
                                   "</nrctatrf><nmprimtl>" +
                                   tt-contas-cadastradas.nmtitula +
                                   "</nmprimtl><cddbanco>" +
                                   STRING(tt-contas-cadastradas.cddbanco,
                                          "999") +
                                   "</cddbanco><nmextbcc>" +
                                   tt-contas-cadastradas.nmextbcc +
                                   "</nmextbcc><cdageban>" +
                                   STRING(tt-contas-cadastradas.cdageban,
                                          "9999") +
                                   "</cdageban><inpessoa>" +
                                   STRING(tt-contas-cadastradas.inpessoa,
                                          "9") +
                                   "</inpessoa><nrcpfcgc>" +
                                   STRING(tt-contas-cadastradas.nrcpfcgc) +
                                   "</nrcpfcgc><dsctatrf>" +
                                   TRIM(tt-contas-cadastradas.dsctatrf) +
                                   "</dsctatrf><nrseqcad>" +
                                   STRING(tt-contas-cadastradas.nrseqcad) +
                                   "</nrseqcad><dstipcta>" +
                                   tt-contas-cadastradas.dstipcta +
                                   "</dstipcta><intipcta>" +
                                   STRING(tt-contas-cadastradas.intipcta) +
                                   "</intipcta><dscpfcgc>" +
                                   tt-contas-cadastradas.dscpfcgc +
                                   "</dscpfcgc><insitcta>" +
                                   STRING(tt-contas-cadastradas.insitcta) +
                                  "</insitcta><cdispbif>" +
                                   STRING(tt-contas-cadastradas.nrispbif) +
                                  "</cdispbif><dsageban>" +
                                   STRING(tt-contas-cadastradas.dsageban) +
                                  "</dsageban><nmageban>" +
                                   STRING(tt-contas-cadastradas.nmageban) +
                                  "</nmageban></DADOS>".
        
        
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</CONTAS_DESTINO>". 

IF  NOT par_flgpesqu AND par_tpoperac = 4  THEN
    DO:
        RUN consulta-finalidades IN h-b1wgen0015 (INPUT par_cdcooper,
                                                  INPUT 90,
                                                  INPUT 900,
                                                 OUTPUT TABLE tt-finted,
                                                 OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0015.
                
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<FINALIDADES>".

        FOR EACH tt-finted NO-LOCK:

            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<FINALIDADE><cdfinali>"+
                                           STRING(tt-finted.cdfinali) +
                                           "</cdfinali><dsfinali>" + 
                                           tt-finted.dsfinali + 
                                           "</dsfinali><flgselec>" + 
                                           STRING(tt-finted.flgselec) + 
                                           "</flgselec></FINALIDADE>".

        END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "</FINALIDADES>".
    END.

/* Chamar a BO para trazer as coop. */
RUN sistema/generico/procedures/b1wgen0142.p PERSISTENT SET h-b1wgen0142.

RUN pi_carrega_cooperativas IN h-b1wgen0142 (OUTPUT aux_nmcooper,
                                             OUTPUT TABLE tt-crapcop).

DELETE PROCEDURE h-b1wgen0142.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<COOPERATIVAS_DESTINO>".

FOR EACH tt-crapcop WHERE tt-crapcop.cdcooper > 0 NO-LOCK BY tt-crapcop.cdagectl:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS>" +
                                      "<cdagectl>" +
                                            STRING(tt-crapcop.cdagectl,"9999") +
                                      "</cdagectl>" +
                                      "<nmrescop>"  +
                                             tt-crapcop.nmrescop +
                                      "</nmrescop>" +
                                   "</DADOS>". 
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</COOPERATIVAS_DESTINO>".

RUN acesso-cadastro-favorecidos IN h-b1wgen0015 
                               (INPUT par_cdcooper,
                                INPUT 90,
                                INPUT 900,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_nrcpfope,
                               OUTPUT aux_dscritic,
                               OUTPUT TABLE tt-bancos-favorecido,
                               OUTPUT TABLE tt-tp-contas,
                               OUTPUT TABLE tt-autorizacao-favorecido).
                               
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0015.
        
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                              "</dsmsgerr>".
        
        RUN proc_geracao_log (INPUT FALSE).
        
        RETURN "NOK".
    END.
    
DELETE PROCEDURE h-b1wgen0015.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<BANCOS>".

FOR EACH tt-bancos-favorecido NO-LOCK BY tt-bancos-favorecido.cddbanco:

  IF CAN-DO("1,104,237,341,33,756,399,748,41,87",STRING(tt-bancos-favorecido.cddbanco)) THEN
  DO:
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<BANCO><cddbanco>" + 
                                     STRING(tt-bancos-favorecido.cddbanco,"999") +
                                     "</cddbanco><nmresbcc>" + 
                                     tt-bancos-favorecido.nmresbcc +
                                     "</nmresbcc><nrispbif>" + 
                                     STRING(tt-bancos-favorecido.nrispbif,"99999999") +
                                     "</nrispbif>
                     </BANCO>".
  END.
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</BANCOS>".
               
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
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
            
            RUN gera_log_item IN h-b1wgen0014
							  (INPUT aux_nrdrowid,
							   INPUT "Origem",
							   INPUT "",
							   INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 

/*............................................................................*/

