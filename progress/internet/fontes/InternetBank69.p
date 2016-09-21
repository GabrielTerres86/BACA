
/* ............................................................................
   Programa: siscaixa/web/InternetBank69.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jorge
   Data    : Setembro/2011                        Ultima atualizacao: 11/03/2014
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Importar dados de remessa de cobrança enviado pelo cooperado.
   
   Alteracoes: 03/07/2012 - tratamento do cdoperad "operador" de INTE para CHAR.
                           (Lucas R.)   
                           
               25/04/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB240 - 085. (Rafael)
                            
               28/09/2013 - Projeto Melhorias da Cobranca - Retornar cddbanco 
                            no XML. (Rafael)
                            
               11/03/2014 - Correcao fechamento instancia b1wgen0090 (Daniel) 
                            
 ............................................................................ */
 
create widget-pool.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }


DEF VAR h-b1wgen0010 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0090 AS HANDLE                                         NO-UNDO.

DEF INPUT  PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nmarquiv AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_idorigem AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_flvalarq AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_qtreqimp AS INTE                                           NO-UNDO.
DEF VAR aux_nrremret AS INTE                                           NO-UNDO.
DEF VAR aux_nrprotoc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_hrtransa AS INTE                                           NO-UNDO.
DEF VAR aux_tparquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.

ASSIGN aux_dstransa = "Importar dados de cobranca contidos em arquivo".

RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0010.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  AVAIL(crapdat) THEN
    ASSIGN par_dtmvtolt = crapdat.dtmvtolt.

/* se for validar arquivo */
IF  par_flvalarq THEN
    DO:
        RUN valida-arquivo-cobranca IN 
            h-b1wgen0010 (INPUT par_cdcooper,
                          INPUT ("/usr/coop/" + 
                                 crapcop.dsdircop + "/upload/" + par_nmarquiv),
                         OUTPUT TABLE tt-rejeita).
        
        DELETE PROCEDURE h-b1wgen0010.

        IF  CAN-FIND(FIRST tt-rejeita NO-LOCK) THEN
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<rejeitados>".
                FOR EACH tt-rejeita NO-LOCK:
                    CREATE xml_operacao.
                    ASSIGN xml_operacao.dslinxml = "<cobranca><tpcritic>" +
                                                    STRING(tt-rejeita.tpcritic) + 
                                                   "</tpcritic><cdseqcri>" +
                                                    STRING(tt-rejeita.cdseqcri) +
                                                   "</cdseqcri>" +
                                                   "<nrdocmto>0</nrdocmto>" + 
                                                   "<dscritic>" +
                                                    tt-rejeita.dscritic +
                                                   "</dscritic><nrlinseq>" +
                                                    tt-rejeita.nrlinseq +
                                                   "</nrlinseq></cobranca>".        
                END.
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "</rejeitados>".
            
            END.
        ELSE
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<flgvalok>OK</flgvalok>".
            END.

        RETURN "OK".
                
    END. /* if par_flvalarq */
ELSE
    DO:
        RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT SET h-b1wgen0090.
        
        IF  NOT VALID-HANDLE(h-b1wgen0090)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0090."
                      xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        
                RETURN "NOK".
            END.

        RUN identifica-arq-cnab IN h-b1wgen0010
            (INPUT par_cdcooper,
             INPUT ("/usr/coop/" + crapcop.dsdircop + "/upload/" + par_nmarquiv),
            OUTPUT aux_tparquiv,
            OUTPUT aux_cddbanco,
            OUTPUT TABLE tt-rejeita).

        DELETE PROCEDURE h-b1wgen0010.

        IF  CAN-FIND(FIRST tt-rejeita NO-LOCK) THEN
            DO:
                 CREATE xml_operacao.
                 ASSIGN xml_operacao.dslinxml = "<rejeitados>".
                 FOR EACH tt-rejeita NO-LOCK:
                     CREATE xml_operacao.
                     ASSIGN xml_operacao.dslinxml = "<cobranca><tpcritic>" +
                                                     STRING(tt-rejeita.tpcritic) + 
                                                    "</tpcritic><cdseqcri>" +
                                                     STRING(tt-rejeita.cdseqcri) +
                                                    "</cdseqcri>" +
                                                    "<nrdocmto>0</nrdocmto>" + 
                                                    "<dscritic>" +
                                                     tt-rejeita.dscritic +
                                                    "</dscritic><nrlinseq>" +
                                                     tt-rejeita.nrlinseq +
                                                    "</nrlinseq></cobranca>".        
                 END.
                 CREATE xml_operacao.
                 ASSIGN xml_operacao.dslinxml = "</rejeitados>".

                 RETURN "NOK".
             END.

        IF  aux_tparquiv = "CNAB240" AND aux_cddbanco = 001 THEN
            RUN p_integra_arq_remessa IN h-b1wgen0090 
                (INPUT par_cdcooper,
                 INPUT par_nrdconta,
                 INPUT ("/usr/coop/" + crapcop.dsdircop + "/upload/" + 
                        par_nmarquiv),
                 INPUT par_idorigem,
                 INPUT par_dtmvtolt,
                 INPUT par_cdoperad,
                 INPUT par_nmdatela,
                OUTPUT aux_qtreqimp,
                OUTPUT aux_nrremret,
                OUTPUT aux_nrprotoc,
                OUTPUT aux_cdcritic,
                OUTPUT aux_hrtransa,
                OUTPUT TABLE crawrej).
        ELSE 
        IF  aux_tparquiv = "CNAB240" AND aux_cddbanco = 085 THEN
            RUN p_integra_arq_remessa_cnab240_085 IN h-b1wgen0090 
                (INPUT par_cdcooper,
                 INPUT par_nrdconta,
                 INPUT ("/usr/coop/" + crapcop.dsdircop + "/upload/" + 
                        par_nmarquiv),
                 INPUT par_idorigem,
                 INPUT par_dtmvtolt,
                 INPUT par_cdoperad,
                 INPUT par_nmdatela,
                OUTPUT aux_qtreqimp,
                OUTPUT aux_nrremret,
                OUTPUT aux_nrprotoc,
                OUTPUT aux_cdcritic,
                OUTPUT aux_hrtransa,
                OUTPUT TABLE crawrej).
        ELSE 
        IF  aux_tparquiv = "CNAB400" AND aux_cddbanco = 085 THEN
            RUN p_integra_arq_remessa_cnab400_085 IN h-b1wgen0090 
                (INPUT par_cdcooper,
                 INPUT par_nrdconta,
                 INPUT ("/usr/coop/" + crapcop.dsdircop + "/upload/" + 
                        par_nmarquiv),
                 INPUT par_idorigem,
                 INPUT par_dtmvtolt,
                 INPUT par_cdoperad,
                 INPUT par_nmdatela,
                OUTPUT aux_qtreqimp,
                OUTPUT aux_nrremret,
                OUTPUT aux_nrprotoc,
                OUTPUT aux_cdcritic,
                OUTPUT aux_hrtransa,
                OUTPUT TABLE crawrej).
        ELSE
            DO:
                ASSIGN aux_dscritic = "Formato de arquivo invalido."
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

                DELETE PROCEDURE h-b1wgen0090.
    
                RETURN "NOK".
            END.

        DELETE PROCEDURE h-b1wgen0090.
        
        IF  CAN-FIND(FIRST crawrej NO-LOCK) THEN
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<rejeitados>".
                FOR EACH crawrej NO-LOCK:
                    CREATE xml_operacao.
                    ASSIGN xml_operacao.dslinxml = "<cobranca>" +
                                                   "<tpcritic>9</tpcritic>" +
                                                   "<cdseqcri>0</cdseqcri>" +
                                                   "<nrdocmto>" +
                                                   STRING(crawrej.nrdocmto) +
                                                   "</nrdocmto>" + 
                                                   "<dscritic>" +
                                                    crawrej.dscritic +
                                                   "</dscritic>" +
                                                   "<nrlinseq>99999</nrlinseq>" +
                                                   "</cobranca>".
                END.
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "</rejeitados>".
            END.
            
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<dados><qtreqimp>" +
                                       STRING(aux_qtreqimp) +
                                       "</qtreqimp><nrremret>" +
                                       STRING(aux_nrremret) +
                                       "</nrremret><nrprotoc>" +
                                       STRING(aux_nrprotoc) +
                                       "</nrprotoc><cdcritic>" +
                                       STRING(aux_cdcritic) +
                                       "</cdcritic><hrtransa>" +
                                       STRING(aux_hrtransa,"HH:MM:SS") +
                                       "</hrtransa><cddbanco>" + 
                                       STRING(aux_cddbanco,"999") + 
                                       "</cddbanco></dados>".
        
        RETURN "OK".

    END. /* else de flvalarq */
