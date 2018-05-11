/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank17.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   
   Data    : Marco/2007                        Ultima atualizacao: 29/11/2017
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar extrato da poupanca programada.
   
   Alteracoes: 29/08/2008 - Alterar nomes de variaveis (David).
                            
               03/11/2008 - Inclusao widget-pool (martin)
               
               05/03/2010 - Novos parametros para a procedure 
                            consulta-extrato-poupanca (David).
                            
               06/09/2011 - Valor retornado no campo tt-extr-rpp.txaplica
                            agora retorna no campo tt-extr-rpp.txaplmes
                            ( Gabriel Capoia - DB1 ).
 
               04/10/2012 - Troca de parametro na tag <dshistor> para passar
                            o parametro dsextrat vinda da temp-table. (Jorge)
                            
               07/06/2013 - Incluir procedure retorna-valor-blqjud e tag xml
                            <vlblqjud> (Lucas R.).
                            
               29/11/2017 - Inclusao do valor de bloqueio em garantia. 
                            PRJ404 - Garantia.(Odirlei-AMcom)                
..............................................................................*/
 
                                                                               
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.
DEF VAR aux_vlblqapl_gar  AS DECI                                      NO-UNDO.
DEF VAR aux_vlblqpou_gar  AS DECI                                      NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctrrpp LIKE craprpp.nrctrrpp                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_vlblqjud = 0
       aux_vlresblq = 0
       aux_vlblqapl_gar = 0
       aux_vlblqpou_gar = 0.

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

/*** Busca Saldo Bloqueado Judicial ***/
IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
    RUN sistema/generico/procedures/b1wgen0155.p 
        PERSISTENT SET h-b1wgen0155.

RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 0, /* fixo - nrcpfcgc */
                                         INPUT 0, /* fixo - cdtipmov */
                                         INPUT 3, /* 3 - Poupanca Programada */
                                         INPUT crapdat.dtmvtolt,
                                         OUTPUT aux_vlblqjud,
                                         OUTPUT aux_vlresblq).

IF  VALID-HANDLE(h-b1wgen0155) THEN
    DELETE PROCEDURE h-b1wgen0155.

/*** Busca Saldo Bloqueado Garantia ***/
IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
    RUN sistema/generico/procedures/b1wgen0112.p 
        PERSISTENT SET h-b1wgen0112.

RUN calcula_bloq_garantia IN h-b1wgen0112
                         ( INPUT par_cdcooper,
                           INPUT par_nrdconta,                                             
                          OUTPUT aux_vlblqapl_gar,
                          OUTPUT aux_vlblqpou_gar,
                          OUTPUT aux_dscritic).

IF aux_dscritic <> "" THEN
DO:
   ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".          
   RETURN "NOK".

END.
    
IF  VALID-HANDLE(h-b1wgen0112) THEN
    DELETE PROCEDURE h-b1wgen0112.    

RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006.

IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0006.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        
        RETURN "NOK".
    END.

RUN consulta-extrato-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                               INPUT 90,
                                               INPUT 900,
                                               INPUT "996",
                                               INPUT "INTERNETBANK",
                                               INPUT 3,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_nrctrrpp,
                                               INPUT par_dtiniper,
                                               INPUT par_dtfimper,
                                               INPUT TRUE,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-extr-rpp).
                                                                 
DELETE PROCEDURE h-b1wgen0006.
       
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel carregar extrato da " +
                           "poupanca programada.".
            
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        
        RETURN "NOK".
    END.

FOR EACH tt-extr-rpp NO-LOCK:
              
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<EXTRATO_PPR><dtmvtolt>" +       
                                   STRING(tt-extr-rpp.dtmvtolt,"99/99/9999") +
                                   "</dtmvtolt><dshistor>" +
                                   TRIM(tt-extr-rpp.dsextrat) +
                                   "</dshistor><nrdocmto>" +
                                  (IF  tt-extr-rpp.nrdocmto = 0  THEN 
                                       "" 
                                   ELSE
                                       TRIM(STRING(tt-extr-rpp.nrdocmto,
                                                   "zzz,zzz,zz9"))) + 
                                   "</nrdocmto><indebcre>" +
                                   TRIM(tt-extr-rpp.indebcre) +
                                   "</indebcre><vllanmto>" +
                                  (IF  tt-extr-rpp.vllanmto = 0  THEN 
                                       "" 
                                   ELSE
                                       TRIM(STRING(tt-extr-rpp.vllanmto,
                                                   "zzz,zzz,zz9.99-"))) + 
                                   "</vllanmto><vlsldapl>" +
                                   TRIM(STRING(tt-extr-rpp.vlsldppr,
                                               "zzz,zzz,zz9.99-")) +
                                   "</vlsldapl><txaplica>" +
                                  (IF  tt-extr-rpp.txaplmes = 0  THEN 
                                       "" 
                                   ELSE
                                       TRIM(STRING(tt-extr-rpp.txaplmes,
                                                   "zz9.999999"))) + 
                                   "</txaplica><vlblqjud>" +
                                   TRIM(STRING(aux_vlblqjud,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlblqjud>" +
                                   "<vlblqapl_gar>" +
                                   TRIM(STRING(aux_vlblqapl_gar,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlblqapl_gar>"+
                                   "<vlblqpou_gar>" +
                                   TRIM(STRING(aux_vlblqpou_gar,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlblqpou_gar>"+                                   
                                   "</EXTRATO_PPR>".
                             
END. /** Fim do FOR EACH tt-extr-rpp **/
        
RETURN "OK".


/*............................................................................*/
