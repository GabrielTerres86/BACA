/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank182.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Outubro/2017                      Ultima atualizacao: 27/04/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar informacoes gerais da conta corrente.

   Alteracoes: 27/04/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Douglas Quisinski)

               26/06/2018 - Inclusao de novos campos para retorno de dados da conta.
                            PRJ-CDC (Odirlei-AMcom)

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dtultace AS CHAR                                           NO-UNDO.
DEF VAR aux_hrultace AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagedbb AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbcoctl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagectl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitula AS CHAR										                       NO-UNDO.
DEF VAR aux_nmprepos AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.

DEF VAR tmp_cdagectl AS DECI                                           NO-UNDO.

DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dtadmiss AS CHAR                                           NO-UNDO.
DEF VAR aux_dtdemiss AS CHAR                                           NO-UNDO.

DEF VAR aux_idpessoa AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                             NO-UNDO.
DEF VAR aux_nrcpfpre LIKE crapsnh.nrcpfcgc                             NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
/*  Projeto 363 - Novo ATM */
DEF VAR aux_flgemiss AS INTE                                           NO-UNDO.
DEF VAR aux_xml      AS CHAR                                           NO-UNDO.


DEF BUFFER crabass FOR crapass.

DEF INPUT  PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtocd LIKE crapdat.dtmvtocd                    NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                                  NO-UNDO.
/*  Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdorigem AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_dsorigem AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nmprogra AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Consultar informacoes da conta corrente".

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN aux_dscritic = "Registro de cooperativa nao encontrado."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".
    END.
    
ASSIGN aux_nmrescop = IF crapcop.cdcooper = 16 THEN "VIACREDI ALTO VALE" ELSE crapcop.nmrescop.

ASSIGN tmp_cdagectl = crapcop.cdagectl.

IF  tmp_cdagectl <> 0  THEN
    DO:
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

        IF  VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN tmp_cdagectl = DECI(STRING(tmp_cdagectl) + "0").

                RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                             INPUT par_cdagenci, /* Projeto 363 - Novo ATM -> estava fixo 90,*/
                                             INPUT par_nrdcaixa, /* Projeto 363 - Novo ATM -> estava fixo 900,*/
                                             INPUT-OUTPUT tmp_cdagectl,
                                            OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen9999.
            END.
    END.

ASSIGN aux_cdagedbb = IF  crapcop.cdagedbb = 0  THEN
                          ""
                      ELSE
                          STRING(STRING(crapcop.cdagedbb,"zzzzzzz9"),"xxxxxxx-x")
       aux_cdbcoctl = IF  crapcop.cdbcoctl = 0  THEN
                          ""
                      ELSE
                          STRING(crapcop.cdbcoctl,"999")
       aux_cdagectl = IF  tmp_cdagectl = 0  THEN
                          ""
                      ELSE
                          STRING(STRING(tmp_cdagectl,"99999"),"xxxx-x").

FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapass  THEN
    DO:
        FIND crapcri WHERE crapcri.cdcritic = 9 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcri  THEN
            ASSIGN aux_dscritic = crapcri.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Nao foi possivel carregar os saldos.".

        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".
    END.


IF crapass.dtadmiss <> ? THEN
  ASSIGN aux_dtadmiss = STRING(crapass.dtadmiss,"99/99/9999").
ELSE
  ASSIGN aux_dtadmiss = "".


IF crapass.dtdemiss <> ? THEN
  ASSIGN aux_dtdemiss = STRING(crapass.dtdemiss,"99/99/9999").
ELSE
  ASSIGN aux_dtdemiss = "".

IF  crapass.inpessoa = 1  THEN
    DO:
        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                           crapttl.nrdconta = par_nrdconta AND
                           crapttl.idseqttl = par_idseqttl 
						   NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapttl  THEN
            DO:
                ASSIGN aux_dscritic = "Titular da conta invalido."
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.

        ASSIGN aux_nmtitula = crapttl.nmextttl
               aux_nmoperad = ""
               aux_nmprepos = ""
               aux_nrcpfpre = 0
               aux_nrcpfcgc = crapttl.nrcpfcgc
               aux_inpessoa = crapttl.inpessoa. /* TODO - Alterar para campo TB_CADAST_PESSOA.IDPESSOA - CRM */
    END.
ELSE
    DO:
        ASSIGN aux_nmtitula = crapass.nmprimtl
               aux_nmoperad = ""
               aux_nmprepos = ""
               aux_nrcpfpre = 0
               aux_nrcpfcgc = crapass.nrcpfcgc
               aux_inpessoa = crapass.inpessoa. /* TODO - Alterar para campo TB_CADAST_PESSOA.IDPESSOA - CRM */

        IF  par_nrcpfope > 0  THEN
            DO:
                FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                   crapopi.nrdconta = par_nrdconta AND
                                   crapopi.nrcpfope = par_nrcpfope
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapopi  THEN
                    DO:
                        ASSIGN aux_dscritic = "Operador nao cadastrado."
                               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                              "</dsmsgerr>".

                        RUN proc_geracao_log (INPUT FALSE).

                        RETURN "NOK".
                    END.

                ASSIGN aux_nmoperad = crapopi.nmoperad.
            END.
        ELSE 
            DO:
              /* Obter Dados do Representante Legal */
              /* buscar cpf do preposto */
              FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper
                                  AND crapsnh.nrdconta = par_nrdconta
                                  AND crapsnh.idseqttl = par_idseqttl
                                  AND crapsnh.tpdsenha = 1
                                      NO-LOCK. END.

              IF AVAIL crapsnh THEN
                 DO:
                    /* buscar nome do representante */
                    FOR FIRST crapavt WHERE crapavt.cdcooper = crapsnh.cdcooper
                                        AND crapavt.nrdconta = crapsnh.nrdconta
                                        AND crapavt.nrcpfcgc = crapsnh.nrcpfcgc
                                        AND crapavt.tpctrato = 6 /* Jur */
                                            NO-LOCK. END.
                    IF  AVAIL crapavt THEN
                        DO:
                          ASSIGN aux_nrcpfpre = crapsnh.nrcpfcgc.
                          
                          IF  crapavt.nrdctato <> 0 then
                              DO:
                                  FOR FIRST crabass
                                      WHERE crabass.cdcooper = par_cdcooper
                                        AND crabass.nrdconta = crapavt.nrdctato
                                            NO-LOCK. END.

                                IF  AVAIL crabass THEN
                                    ASSIGN aux_nmprepos = crabass.nmprimtl.
                                ELSE
                                    ASSIGN aux_nmprepos = crapavt.nmdavali.
                              END.
                          ELSE
                              ASSIGN aux_nmprepos = crapavt.nmdavali.
                        END.
                END.
            END.
    END.
    
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_retorna_idpessoa
  aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT aux_nrcpfcgc,                                            
                      OUTPUT 0,
                      OUTPUT "").
                      
                     
CLOSE STORED-PROC pc_retorna_idpessoa aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

ASSIGN aux_idpessoa = 0       
       aux_dscritic = ""
       aux_idpessoa = pc_retorna_idpessoa.pr_idpessoa
                      WHEN pc_retorna_idpessoa.pr_idpessoa <> ?
       aux_dscritic = pc_retorna_idpessoa.pr_dscritic
                      WHEN pc_retorna_idpessoa.pr_dscritic <> ?.      

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }       

  FIND FIRST tbtaa_limite_saque 
       WHERE tbtaa_limite_saque.cdcooper = par_cdcooper
         AND tbtaa_limite_saque.nrdconta = par_nrdconta
       NO-LOCK NO-ERROR.
   
  IF AVAIL tbtaa_limite_saque THEN
    ASSIGN aux_flgemiss = INTE(tbtaa_limite_saque.flgemissao_recibo_saque).
  ELSE 
    ASSIGN aux_flgemiss = 0.     

/* Carregar as informacoes do ultimo acesso apenas quando a requisicao for realizada do IB ou Mobile */
IF par_cdorigem = 3  OR    /* Internet Bank */
   par_cdorigem = 10 THEN  /* Mobile */ 
DO:
RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT
    SET h-b1wnet0002.

IF  VALID-HANDLE(h-b1wnet0002)  THEN
    DO:

            /* Somente a conta online armazena o acesso anterior,
               com isso os parametros nao foram ajustados para 
               o projeto 363 Novo caixa eletronico */
        RUN obtem-acesso-anterior IN h-b1wnet0002
                                 (INPUT par_cdcooper,
                                  INPUT 90,
                                  INPUT 900,
                                  INPUT "996",
                                  INPUT "InternetBank",
                                  INPUT 3,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_nrcpfope,
                                  INPUT FALSE,
                                  INPUT par_flmobile,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-acesso).

        DELETE PROCEDURE h-b1wnet0002.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os " +
                                   "saldos.".

                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                               "</dsmsgerr>".

                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.                

        FIND FIRST tt-acesso NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-acesso  THEN
            ASSIGN aux_dtultace = IF  tt-acesso.dtultace <> ?  THEN
                                      STRING(tt-acesso.dtultace,
                                             "99/99/9999")
                                  ELSE
                                      ""
                   aux_hrultace = STRING(tt-acesso.hrultace,"HH:MM:SS").                           
    END.
END.


/* Para pessoa física, buscar o nome de todos os titulares da conta */
IF  crapass.inpessoa = 1  THEN
    DO:
        ASSIGN aux_xml = '<TITULARES>'.
        
        FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta NO-LOCK:

             ASSIGN aux_xml = aux_xml + '<TITULAR><idseqttl>' +
                                           STRING(crapttl.idseqttl) +
                                           '</idseqttl><nmtitula>' +
                                           crapttl.nmextttl +
                                           '</nmtitula><nrcpfcgc>' +
                                           STRING(crapttl.nrcpfcgc,'99999999999') +
                                           '</nrcpfcgc></TITULAR>'.             

        END.
          
        ASSIGN aux_xml = aux_xml + '</TITULARES>'. 
        
    END.
ELSE
    DO:		
        /* Para pessoa jurídica, carregar o nome do dono da conta */ 
        ASSIGN aux_xml = aux_xml + '<TITULARES><TITULAR><idseqttl>' +
                                       '1</idseqttl><nmtitula>' +
                                       crapass.nmprimtl +
                                       '</nmtitula><nrcpfcgc>' +
                                       STRING(crapass.nrcpfcgc,'99999999999999') +
                                       '</nrcpfcgc></TITULAR></TITULARES>'.
                                       
    END.


CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<CORRENTISTA><nmtitula>" + 
                               aux_nmtitula + 
                               "</nmtitula><nmoperad>" +
                               aux_nmoperad +
                               "</nmoperad><nrdconta>" +
                               TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) +
                               "</nrdconta><nrdctitg>" +
                               (IF crapass.flgctitg = 2 AND TRIM(crapass.nrdctitg) <> "" THEN TRIM(STRING(crapass.nrdctitg,"9.999.999-X")) ELSE "") +
                               "</nrdctitg><cdagenci>" +
                               STRING(crapass.cdagenci,"999") +
                               "</cdagenci><inpessoa>" +
                               STRING(aux_inpessoa,"9") +
                               "</inpessoa><idpessoa>" +
                               STRING(aux_idpessoa) +
                               "</idpessoa><cdagedbb>" +
                               aux_cdagedbb +
                               "</cdagedbb><cdbcoctl>" +
                               aux_cdbcoctl +
                               "</cdbcoctl><cdagectl>" +
                               aux_cdagectl +
                               "</cdagectl><nrcpfope>" +
                               STRING(par_nrcpfope) +
                               "</nrcpfope><dtultace>" +
                               aux_dtultace +
                               "</dtultace><hrultace>" +
                               aux_hrultace +
                               "</hrultace><dtmvtocd>" +
                               STRING(par_dtmvtocd,"99/99/9999") +
                               "</dtmvtocd><datdodia>" +
                               STRING(aux_datdodia,"99/99/9999") +
                               "</datdodia><nmrescop>" +
                               aux_nmrescop + 
                               "</nmrescop><nmprepos>" +
                               aux_nmprepos + 
                               "</nmprepos><nrcpfpre>" +
                               STRING(aux_nrcpfpre) +
                               "</nrcpfpre><nrcpfcgc>" +
                               (IF aux_inpessoa = 1 THEN STRING(aux_nrcpfcgc,'99999999999') ELSE STRING(aux_nrcpfcgc,'99999999999999')) + 
                               "</nrcpfcgc><cdsitdct>" + 
                               STRING(crapass.cdsitdct) + 
                               "</cdsitdct><qtminast>" +
                               STRING(crapass.qtminast,"9999") +
                               "</qtminast><flrecsaq>" +
                               STRING(aux_flgemiss) +
                               "</flrecsaq><flgiddep>" +
                               STRING(crapass.flgiddep) +
                               "</flgiddep><dtadmiss>" +
                               aux_dtadmiss + 
                               "</dtadmiss><dtdemiss>" + 
                               aux_dtdemiss +
                               "</dtdemiss></CORRENTISTA>" +
                               aux_xml.

RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.

    DEF   VAR       aux_dsorigem AS CHAR                            NO-UNDO.

    IF	 par_flmobile THEN
        ASSIGN aux_dsorigem = "MOBILE".
    ELSE
        ASSIGN aux_dsorigem = par_nmprogra.

    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT
        SET h-b1wgen0014.

    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT par_dsorigem,   /* Projeto 363 - Novo ATM -> estava fixo "INTERNET",*/
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT par_nmprogra,   /* Projeto 363 - Novo ATM -> estava fixo "InternetBank",*/
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).

            RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Origem",
                           INPUT "",
                           INPUT aux_dsorigem).

            DELETE PROCEDURE h-b1wgen0014.
        END.

END PROCEDURE.

/*............................................................................*/


