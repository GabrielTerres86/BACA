/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank11.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 13/04/2017

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
               
               17/08/2016 - Adição da coluna nomconta e remoção da tabela
                            xml_operacao11 para utilizacao da tabela generica.
                            PRJ286.5 - Cecred Mobile (Dionathan)
                            
			   13/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
                            
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
DEF VAR aux_qtdiaace AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmsegntl AS CHAR										   NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.


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
                                      OUTPUT TABLE tt-titulares,
                                      OUTPUT aux_qtdiaace,
                                      OUTPUT aux_nmprimtl).
    
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

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<TITULARES>".

FOR EACH tt-titulares NO-LOCK:

    ASSIGN aux_flsenlet = FALSE.

	IF tt-titulares.inpessoa = 1 AND 
	   tt-titulares.idseqttl = 2 THEN
	   ASSIGN aux_nmsegntl = tt-titulares.nmtitula.
	   
    IF  VALID-HANDLE(h-b1wgen0032)  THEN
        RUN verifica-letras-seguranca IN h-b1wgen0032 
                                     (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT tt-titulares.idseqttl,
                                     OUTPUT aux_flsenlet).
            
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<TITULAR>".
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<nmtitula>" +
                                     tt-titulares.nmtitula +
                                     "</nmtitula>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<incadsen>" + 
                                     STRING(tt-titulares.incadsen) +
                                     "</incadsen>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<idseqttl>" +
                                     STRING(tt-titulares.idseqttl) +
                                     "</idseqttl>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<inbloque>" +
                                     STRING(tt-titulares.inbloque) +
                                     "</inbloque>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<nrcpfope>" +
                                     STRING(tt-titulares.nrcpfope) +
                                     "</nrcpfope><flsenlet>" +
                                     STRING(aux_flsenlet,"SIM/NAO") +
                                     "</flsenlet><nrctanov>" + 
                                     STRING(aux_nrctanov) + 
                                     "</nrctanov>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<inpessoa>" +
                                     STRING(tt-titulares.inpessoa) +
                                     "</inpessoa>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</TITULAR>".

END. /** Fim do FOR EACH tt-titulares **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</TITULARES>".

IF  VALID-HANDLE(h-b1wgen0032)  THEN
    DELETE PROCEDURE h-b1wgen0032.

FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<nomconta>" + STRING(crapass.nmprimtl) +  " " + aux_nmsegntl + "</nomconta>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<qtdiaace>" + STRING(aux_qtdiaace) + "</qtdiaace>".

RETURN "OK".

/*............................................................................*/
