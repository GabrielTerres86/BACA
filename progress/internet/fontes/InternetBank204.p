/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank204.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Agosto/2017                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obter permissoes de acesso para efetuar upload do arquivo 
               de agendamento de pagamento pela Internet 
               Internet.
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.

DEF VAR aux_hrinipag AS   CHAR                                         NO-UNDO.
DEF VAR aux_hrfimpag AS   CHAR                                         NO-UNDO.
DEF VAR aux_hrcancel AS   CHAR                                         NO-UNDO.
DEF VAR aux_nrtelfax AS   CHAR                                         NO-UNDO.
DEF VAR aux_nrconven AS   INTE                                         NO-UNDO.
DEF VAR aux_flghomol AS   INTE                                         NO-UNDO.
DEF VAR aux_idretorn AS   INTE                                         NO-UNDO.
DEF VAR aux_cdagectl AS   INTE                                         NO-UNDO.
DEF VAR aux_dtadesao AS   DATE                                         NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                             NO-UNDO.


DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.


ASSIGN aux_dstransa = "Acesso a tela de upload do arquivo de agendamento de pagamentos"
       aux_hrinipag = ""
       aux_hrfimpag = ""
       aux_hrcancel = ""
       aux_nrtelfax = ""
       aux_nrconven = 0
       aux_flghomol = 0
       aux_idretorn = 0
       aux_cdagectl = 0
       aux_nrcpfcgc = 0
       aux_dtadesao = ?.

/* Carregar as informacoes da agencia do cooperado */ 
FIND FIRST crapcop 
     WHERE crapcop.cdcooper = par_cdcooper 
     NO-LOCK NO-ERROR.
     
IF  AVAILABLE crapcop  THEN
    DO:
        ASSIGN aux_cdagectl = crapcop.cdagectl.
    END.

/* Buscar o CPF/CNPJ da conta do cooperado */ 
FIND FIRST crapass 
     WHERE crapass.cdcooper = par_cdcooper
       AND crapass.nrdconta = par_nrdconta
     NO-LOCK NO-ERROR.

IF  AVAILABLE crapass  THEN
    DO:
        ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
    END.

/* Buscar os dados do PA 90 */
FIND FIRST crapage 
     WHERE crapage.cdcooper = par_cdcooper 
       AND crapage.cdagenci = 90
     NO-LOCK NO-ERROR.

IF  AVAILABLE crapage  THEN
    DO:
        ASSIGN aux_nrtelfax = crapage.nrtelfax
               aux_hrcancel = STRING(crapage.hrcancel,"HH:MM").
    END.       
       
/* Buscar as informaçoes dos horarios de pagamento e estorno */ 
RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  VALID-HANDLE(h-b1wgen0015)  THEN
    DO:
        RUN verifica_operacao IN h-b1wgen0015 
                                      (INPUT par_cdcooper,
                                       INPUT 90,         /** PAC           **/
                                       INPUT 900,        /** CAIXA         **/
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT par_dtmvtolt,
                                       INPUT 0,          /** AGENDAMENTO   **/
                                       INPUT ?,          /** DATA DEBITO   **/
                                       INPUT 0,          /** VALOR OPER.   **/
                                       INPUT 0,          /** BANCO DESTINO **/
                                       INPUT 0,          /** AGENC.DESTINO **/
                                       INPUT 0,          /** CONTA DESTINO **/
                                       INPUT 0,          /** IND.TRANSACAO **/
                                       INPUT "996",      /** OPERADOR      **/
                                       INPUT 2,          /** PAGAMENTO     **/
                                       INPUT FALSE,      /** VALIDACOES    **/
                                       INPUT "INTERNET", /** ORIGEM        **/
                                       INPUT par_nrcpfope, /** CPF OPERADOR  */
                                       INPUT TRUE,       /** VALIDA LIMITES**/
                                      OUTPUT aux_dstrans1,
                                      OUTPUT aux_dscritic,
                                      OUTPUT TABLE tt-limite,
                                      OUTPUT TABLE tt-limites-internet).
    
        DELETE PROCEDURE h-b1wgen0015.
                
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
            
        /* armazenar os dados de horario limite */
        FIND FIRST tt-limite NO-LOCK NO-ERROR.
        IF  AVAILABLE tt-limite  THEN
            DO:
                ASSIGN aux_hrinipag = tt-limite.hrinipag
                       aux_hrfimpag = tt-limite.hrfimpag.
            END.
    END.
    
    /* Verificar se o cooperado possui convenio homologado e enviou algum arquivo */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_conv_pgto
        aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper, /* Codigo da Cooperativa */
                       INPUT par_nrdconta, /* Numero da Conta */
                      OUTPUT 0,            /* Numero do Convenio */
                      OUTPUT ?,            /* Data de adesao */
                      OUTPUT 0,            /* Convenio esta homologado */
                      OUTPUT 0,            /* Retorno para o Cooperado (1-Internet/2-FTP) */
                      OUTPUT 0,            /* Flag convenio homologado */
                      OUTPUT 0,            /* Flag enviou arquivo remessa */
                      OUTPUT 0,            /* Cód. da crítica */
                      OUTPUT "").          /* Descricao da critica */
    
    
    CLOSE STORED-PROC pc_verifica_conv_pgto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
    ASSIGN aux_nrconven = pc_verifica_conv_pgto.pr_nrconven
                          WHEN pc_verifica_conv_pgto.pr_nrconven <> ?
           aux_dtadesao = pc_verifica_conv_pgto.pr_dtadesao
                          WHEN pc_verifica_conv_pgto.pr_dtadesao <> ?               
           aux_flghomol = pc_verifica_conv_pgto.pr_flghomol
                          WHEN pc_verifica_conv_pgto.pr_flghomol <> ?
           aux_idretorn = pc_verifica_conv_pgto.pr_idretorn
                          WHEN pc_verifica_conv_pgto.pr_idretorn <> ?.
                          

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = " <LIMITE>" + 
                               "   <hrinipag>" + aux_hrinipag + "</hrinipag>" + 
                               "   <hrfimpag>" + aux_hrfimpag + "</hrfimpag>" + 
                               "   <nrtelfax>" + aux_nrtelfax + "</nrtelfax>" + 
                               "   <hrcancel>" + aux_hrcancel + "</hrcancel>" + 
                               "   <nrconven>" + STRING(aux_nrconven) + "</nrconven>" + 
                               "   <dtadesao>" + STRING(aux_dtadesao,"99/99/9999") + "</dtadesao>" +                                
                               "   <flghomol>" + STRING(aux_flghomol) + "</flghomol>" + 
                               "   <idretorn>" + STRING(aux_idretorn) + "</idretorn>" +
                               "   <nrcpfcgc>" + STRING(aux_nrcpfcgc) + "</nrcpfcgc>" + 
                               "   <cdagectl>" + STRING(aux_cdagectl) + "</cdagectl>" + 
                               " </LIMITE>".

RUN proc_geracao_log (INPUT TRUE).

    
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