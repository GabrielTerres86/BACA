/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank6.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 07/06/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar dados da poupanca programada.
   
   Alteracoes: 02/05/2008 - Retornar data de vencimento da poupanca (David).

               04/11/2008 - Inclusao Widget-Pool (Martin).             
               
               04/03/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David).
                            
               07/06/2013 - Incluir procedure retorna-valor-blqjud e tag xml
                            <vlblqjud> (Lucas R.).
                            
..............................................................................*/
    
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0006tt.i }

DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_vlsdrdpp AS DECI DECIMALS 8                                NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtopr LIKE crapdat.dtmvtopr                    NO-UNDO.
DEF  INPUT PARAM par_inproces LIKE crapdat.inproces                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_vlblqjud = 0
       aux_vlresblq = 0.

/*** Busca Saldo Bloqueado Judicial ***/
IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
    RUN sistema/generico/procedures/b1wgen0155.p 
        PERSISTENT SET h-b1wgen0155.

RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 0, /* fixo - nrcpfcgc */
                                         INPUT 0, /* fixo - cdtipmov */
                                         INPUT 3, /* 3 - Poupanca Programada */
                                         INPUT par_dtmvtolt,
                                         OUTPUT aux_vlblqjud,
                                         OUTPUT aux_vlresblq).

IF  VALID-HANDLE(h-b1wgen0155) THEN
    DELETE PROCEDURE h-b1wgen0155.


RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006.

IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0006.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        
        RETURN "NOK".
    END.

RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,        
                                       INPUT 90,                   
                                       INPUT 900,                 
                                       INPUT "996",
                                       INPUT "INTERNETBANK",
                                       INPUT 3,
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT 0,
                                       INPUT par_dtmvtolt,    
                                       INPUT par_dtmvtopr,
                                       INPUT par_inproces,
                                       INPUT "INTERNETBANK",      
                                       INPUT TRUE,
                                      OUTPUT aux_vlsdrdpp,
                                      OUTPUT TABLE tt-erro,      
                                      OUTPUT TABLE tt-dados-rpp).
                       
DELETE PROCEDURE h-b1wgen0006.
                                                         
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel carregar poupanca programada.".
            
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        
        RETURN "NOK".
    END.
                 
FIND FIRST tt-dados-rpp NO-LOCK NO-ERROR.

IF  NOT AVAILABLE tt-dados-rpp  THEN
    DO:
        ASSIGN aux_dscritic = "Nao ha poupanca programada nesta conta."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        
        RETURN "NOK".
    END.
      
    
FOR EACH tt-dados-rpp NO-LOCK:
      
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<POUPANCA><dtmvtolt>" + 
                                   STRING(tt-dados-rpp.dtmvtolt,"99/99/9999") +
                                   "</dtmvtolt><dshistor>Poup. Prog. :" +
                                   TRIM(STRING(tt-dados-rpp.vlprerpp,
                                               "zzz,zz9.99")) +
                                   "</dshistor><nrdocmto>" +
                                   TRIM(STRING(tt-dados-rpp.nrctrrpp,
                                               "z,zzz,zz9")) +
                                   "</nrdocmto><indiadeb>" + 
                                   TRIM(STRING(tt-dados-rpp.indiadeb,"99")) +
                                   "</indiadeb><dssitrpp>" + 
                                   TRIM(tt-dados-rpp.dssitrpp) +
                                   "</dssitrpp><vllanmto>" +
                                   TRIM(STRING(tt-dados-rpp.vlsdrdpp,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vllanmto><dtvctopp>" + 
                                   STRING(tt-dados-rpp.dtvctopp,"99/99/9999") +
                                   "</dtvctopp><vlblqjud>" +
                                   TRIM(STRING(aux_vlblqjud,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlblqjud><vlprerpp>" +
                                   TRIM(STRING(tt-dados-rpp.vlprerpp,
                                               "zzz,zz9.99")) +
                                   "</vlprerpp><dsprodut>"  +
                                    "Poupança Programada" +
                                   "</dsprodut></POUPANCA>".
                           
END. /** Fim do FOR EACH tt-dados-rpp **/

RETURN "OK".


/*............................................................................*/
