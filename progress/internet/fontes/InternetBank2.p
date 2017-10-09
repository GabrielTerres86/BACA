/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank2.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Agosto/2007.                      Ultima atualizacao: 09/10/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validar senha numerica e frase secreta do InternetBank.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).

               09/11/2007 - Incluir parametro para bloqueio de senha (David).
               
               03/11/2008 - Incluir CREATE WIDGET-POOL (martin)

               12/11/2008 - Adaptacao para novo acesso a conta para pessoas
                            juridicas (David).
                            
               23/08/2010 - Receber ip do usuário para controle de acesso
                            (David).
                            
               25/11/2011 - Incluir parametros na operacao com dados da origem
                            da solicitacao (IP usuario) (David). 
                            
               07/11/2012 - Implementar letras de seguranca (David).
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
                            
               21/12/2015 - Passar parametro flmobile para b1wnet0002.verifica-acesso
                            (Dionathan)
                            
               22/08/2016 - Adicao do parametro par_indlogin
                            PRJ286.5 - Cecred Mobile (Dionathan)
                            
               09/10/2017 - Executar verifica_acesso quando requisicao também 
                            for pela Conta Online (David).
    
..............................................................................*/
    
CREATE WIDGET-POOL. 

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0002tt.i }

DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_qtdiaace AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.
     
DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF  INPUT PARAM par_cddsenha LIKE crapsnh.cddsenha                    NO-UNDO.
DEF  INPUT PARAM par_dssenweb LIKE crapsnh.dssenweb                    NO-UNDO.
DEF  INPUT PARAM par_dssenlet AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_vldshlet AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_vldfrase AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inaceblq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nripuser AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_dsorigip AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_indlogin AS INTE                                  NO-UNDO.
     
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT SET h-b1wnet0002.
                
IF  NOT VALID-HANDLE(h-b1wnet0002)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0002."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic  + "</dsmsgerr>".
        
        RETURN "NOK".
    END.

RUN valida-senha IN h-b1wnet0002 (INPUT par_cdcooper,
                                  INPUT 90,             /** PAC      **/
                                  INPUT 900,            /** Caixa    **/
                                  INPUT "996",          /** Operador **/
                                  INPUT "INTERNETBANK", /** Tela     **/
                                  INPUT 3,              /** Origem   **/
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_nrcpfope,
                                  INPUT par_cddsenha,
                                  INPUT par_dssenweb,
                                  INPUT par_dssenlet,
                                  INPUT par_vldshlet,
                                  INPUT par_vldfrase,
                                  INPUT par_inaceblq,
                                  INPUT par_nripuser,
                                  INPUT par_dsorigip,
                                  INPUT TRUE,          /** Logar    **/
                                  INPUT par_flmobile,
                                 OUTPUT TABLE tt-erro).


IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wnet0002.

        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel validar a senha.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".
    END.

IF par_indlogin <> 0 THEN /* Apenas se for login */
   DO:
       RUN verifica-acesso IN h-b1wnet0002 (INPUT par_cdcooper,
                                            INPUT 90,
                                            INPUT 900,
                                            INPUT "996",
                                            INPUT "InternetBank",
                                            INPUT 3,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nrcpfope,
                                            INPUT par_nripuser,
                                            INPUT par_dsorigip,
                                            INPUT TRUE,
                                            INPUT par_flmobile,
                                           OUTPUT TABLE tt-erro, 
                                           OUTPUT TABLE tt-acesso).
										   
       RUN carrega-titulares IN h-b1wnet0002 (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT TRUE,           /** Logar    **/  
                                       INPUT par_flmobile,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-titulares,
                                      OUTPUT aux_qtdiaace,
                                      OUTPUT aux_nmprimtl).										 
       
              
	      FIND FIRST tt-titulares WHERE tt-titulares.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
        FIND FIRST tt-acesso NO-LOCK NO-ERROR.
        
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK. END.

        IF  AVAIL crapcop  THEN 
            DO:
                IF  crapcop.cdcooper = 16  THEN
                    aux_nmrescop = "VIACREDI ALTO VALE".
                ELSE
                    aux_nmrescop = crapcop.nmrescop.
            END.
		
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<nmrescop>" + TRIM(STRING(UPPER(aux_nmrescop))) + "</nmrescop>" +
                                       "<nrdconta>" + REPLACE(TRIM(STRING(par_nrdconta,"zzzzzzz,9")),".","-") + "</nrdconta>" +
                                       "<nmtitula>" + (IF AVAILABLE tt-titulares THEN TRIM(STRING(tt-titulares.nmtitula)) ELSE "") + "</nmtitula>" +
                                       "<nmrazsoc>" + TRIM(STRING(aux_nmprimtl)) + "</nmrazsoc>" +
                                       "<dtacemob>" + (IF AVAILABLE tt-acesso AND tt-acesso.dtultace <> ? THEN TRIM(STRING(tt-acesso.dtultace)) ELSE "") + "</dtacemob>" +
                                       "<hracemob>" + (IF AVAILABLE tt-acesso THEN TRIM(STRING(tt-acesso.hrultace)) ELSE "") + "</hracemob>" +
                                       "<cdblqsnh>" + (IF AVAILABLE tt-acesso THEN TRIM(STRING(tt-acesso.cdblqsnh)) ELSE "") + "</cdblqsnh>" +
                                       "<qtdiams1>" + (IF AVAILABLE tt-acesso THEN TRIM(STRING(tt-acesso.qtdiams1)) ELSE "") + "</qtdiams1>" +
                                       "<qtdiams2>" + (IF AVAILABLE tt-acesso THEN TRIM(STRING(tt-acesso.qtdiams2)) ELSE "") + "</qtdiams2>".
   END.
   
DELETE PROCEDURE h-b1wnet0002.                                              

RETURN "OK".

/*............................................................................*/
