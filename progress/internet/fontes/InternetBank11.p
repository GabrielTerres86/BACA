/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank11.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 16/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carrega titulares para acesso a conta on-line 
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)

               12/11/2008 - Adaptacao para novo acesso a conta para pessoas
                            juridicas (David).
                            
               22/06/2010 - Logar transacao se nao foi possivel efetuar o
                            acesso ao InternetBank (David). 
                            
               14/11/2012 - Ajuste Letras de Seguranca (David).
               
               21/12/2012 - Ajuste Alto Vale (David).
               
               16/12/2013 - Verificar flgativo na tabela craptco (Rafael).
               
               02/06/2015 - Adição da coluna inpessoa na xml_operacao11
                            (Dionathan)
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0002tt.i }

DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0032 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_flsenlet AS LOGI                                           NO-UNDO.
DEF VAR aux_nrctanov AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao11.

RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT SET h-b1wnet0002.

IF  NOT VALID-HANDLE(h-b1wnet0002)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0002.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
        
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
                                      OUTPUT TABLE tt-titulares).
    
DELETE PROCEDURE h-b1wnet0002.
           
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel carregar os titulares.".
                    
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

/* Verificar se a conta pertence a um PAC sobreposto */
FIND craptco WHERE craptco.cdcopant = par_cdcooper AND
                   craptco.nrctaant = par_nrdconta AND
                   craptco.tpctatrf = 1            AND 
                   craptco.flgativo = TRUE
                   NO-LOCK NO-ERROR.

IF  NOT AVAIL craptco  THEN
    FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                       craptco.nrdconta = par_nrdconta AND
                       craptco.tpctatrf = 1            AND
                       craptco.flgativo = TRUE         
                       NO-LOCK NO-ERROR.

ASSIGN aux_nrctanov = IF AVAILABLE craptco THEN craptco.nrdconta ELSE 0.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.

FOR EACH tt-titulares NO-LOCK:

    ASSIGN aux_flsenlet = FALSE.

    IF  VALID-HANDLE(h-b1wgen0032)  THEN
        RUN verifica-letras-seguranca IN h-b1wgen0032 
                                     (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT tt-titulares.idseqttl,
                                     OUTPUT aux_flsenlet).
            
    CREATE xml_operacao11.
    ASSIGN xml_operacao11.dscabini = "<TITULAR>"
           xml_operacao11.nmtitula = "<nmtitula>" +
                                     tt-titulares.nmtitula +
                                     "</nmtitula>"
           xml_operacao11.incadsen = "<incadsen>" + 
                                     STRING(tt-titulares.incadsen) +
                                     "</incadsen>"
           xml_operacao11.idseqttl = "<idseqttl>" +
                                     STRING(tt-titulares.idseqttl) +
                                     "</idseqttl>"
           xml_operacao11.inbloque = "<inbloque>" +
                                     STRING(tt-titulares.inbloque) +
                                     "</inbloque>"
           xml_operacao11.nrcpfope = "<nrcpfope>" +
                                     STRING(tt-titulares.nrcpfope) +
                                     "</nrcpfope><flsenlet>" +
                                     STRING(aux_flsenlet,"SIM/NAO") +
                                     "</flsenlet><nrctanov>" + 
                                     STRING(aux_nrctanov) + 
                                     "</nrctanov>"
           xml_operacao11.inpessoa = "<inpessoa>" +
                                     STRING(tt-titulares.inpessoa) +
                                     "</inpessoa>"
           xml_operacao11.dscabfim = "</TITULAR>".

END. /** Fim do FOR EACH tt-titulares **/

IF  VALID-HANDLE(h-b1wgen0032)  THEN
    DELETE PROCEDURE h-b1wgen0032.

RETURN "OK".

/*............................................................................*/
