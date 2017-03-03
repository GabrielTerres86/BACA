/*..............................................................................
   Programa: sistema/internet/fontes/InternetBank25.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007.                       Ultima atualizacao: 22/02/2017
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Listar protocolos de transferencias e pagamentos para Internet.
   
   Alteracoes: 13/09/2007 - Retornar campo com data da transacao (David).
   
               09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
               
               14/11/2007 - Chamada para nova BO que lista protocolos (David).
               
               10/03/2008 - Utilizar include var_ibank.i (David).
               14/04/2008 - Adaptacao para agendamentos (David).
               31/07/2008 - Retornar sequencia de autenticacao (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               15/06/2010 - Incluido parametro "origem" na chamada da 
                            procedure lista_protocolos (Diego).
                            
               11/08/2011 - Passar a temp-table cratpro para a includes
                            da bo de seguranca (Gabriel).
                            
               03/10/2011 - Adicionado campos nmprepos, nrcpfpre, nmoperad e 
                            nrcpfope para xml_operacao25. (Jorge)
                            
               12/03/2012 - Alimentado os campos cdbcoctl e cdagectl em
                            xml_operacao25. (Fabricio)
                            
               21/07/2015 - Aumentando a formatacao do campo nrdocmto para
                            realizar o ajustes do erro relatado no chamado
                            304892. (Kelvin)

               09/09/2016 - Ajustar tamanho da formatacao do campo nrdocmto,
                            pois nao esta sendo formatado corretamente quando
                            o numero possuir muitas casas (Anderson).

 				22/02/2017 - Alteraçoes para compor comprovantes DARF/DAS 
                             Modelo Sicredi (Lucas Lunelli)                            
.............................................................................*/
 
create widget-pool.
 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/bo_algoritmo_seguranca.i }

DEF VAR h-b1wgen0014             AS HANDLE                             NO-UNDO.
DEF VAR h-bo_algoritmo_seguranca AS HANDLE                             NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_qttotreg AS INTE                                           NO-UNDO.
DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtinipro LIKE crappro.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtfimpro LIKE crappro.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_iniconta AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrregist AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao25.

RUN sistema/generico/procedures/bo_algoritmo_seguranca.p PERSISTENT 
    SET h-bo_algoritmo_seguranca.
                
IF  VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
    DO:
        RUN lista_protocolos IN h-bo_algoritmo_seguranca 
                                             (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_dtinipro,
                                              INPUT par_dtfimpro,
                                              INPUT par_iniconta,
                                              INPUT par_nrregist,
                                              INPUT 0, /** Todos os tipos **/
                                              INPUT 3, /** Internet **/
                                              OUTPUT aux_dstransa,
                                              OUTPUT aux_dscritic,
                                              OUTPUT aux_qttotreg,
                                              OUTPUT TABLE cratpro).

        DELETE PROCEDURE h-bo_algoritmo_seguranca.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".
                                           
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
        
        FOR EACH cratpro NO-LOCK:
            
            CREATE xml_operacao25.
            ASSIGN xml_operacao25.dscabini = "<DADOS>"
                   xml_operacao25.cdtippro = "<cdtippro>" +
                                             STRING(cratpro.cdtippro) +
                                             "</cdtippro>"
                   xml_operacao25.dtmvtolt = "<dtmvtolt>" + 
                                        STRING(cratpro.dtmvtolt,"99/99/9999") + 
                                             "</dtmvtolt>"
                   xml_operacao25.dttransa = "<dttransa>" + 
                                        STRING(cratpro.dttransa,"99/99/9999") + 
                                             "</dttransa>"
                   xml_operacao25.hrautent = "<hrautent>" +
                                          STRING(cratpro.hrautent,"HH:MM:SS") +
                                             "</hrautent>"
                   xml_operacao25.vldocmto = "<vldocmto>" +
                              TRIM(STRING(cratpro.vldocmto,"zzz,zzz,zz9.99")) +
                                             "</vldocmto>"
                   xml_operacao25.nrdocmto = "<nrdocmto>" +
                                    TRIM(STRING(cratpro.nrdocmto,"zzzzzzzzzzzzzzzzzzzzzzzz9")) +
                                             "</nrdocmto>"
                   xml_operacao25.nrseqaut = "<nrseqaut>" +
                                    TRIM(STRING(cratpro.nrseqaut,"zzzzzzz9")) +
                                             "</nrseqaut>"
                   xml_operacao25.dsinfor1 = "<dsinfor1>" +
                                             TRIM(cratpro.dsinform[1]) +
                                             "</dsinfor1>"
                   xml_operacao25.dsinfor2 = "<dsinfor2>" +
                                             TRIM(cratpro.dsinform[2]) +
                                             "</dsinfor2>"
                   xml_operacao25.dsinfor3 = "<dsinfor3>" +
                                             TRIM(cratpro.dsinform[3]) +
                                             "</dsinfor3>"
                   xml_operacao25.dsprotoc = "<dsprotoc>" + 
                                             TRIM(cratpro.dsprotoc) +
                                             "</dsprotoc>"
                   xml_operacao25.dscedent = "<dscedent>" +
                                             TRIM(cratpro.dscedent) +
                                             "</dscedent>"
                   xml_operacao25.cdagenda = "<cdagenda>" +
                                            (IF  cratpro.flgagend  THEN
                                                 "S"
                                             ELSE
                                                 "N") +
                                             "</cdagenda>"
                   xml_operacao25.qttotreg = "<qttotreg>" +
                                      TRIM(STRING(aux_qttotreg,"zzzzzzzzz9")) +
                                             "</qttotreg>"
                   xml_operacao25.nmprepos = "<nmprepos>" + 
                                             TRIM(cratpro.nmprepos) +
                                             "</nmprepos>"
                   xml_operacao25.nrcpfpre = "<nrcpfpre>" +
                                             STRING(cratpro.nrcpfpre) +
                                             "</nrcpfpre>"
                   xml_operacao25.nmoperad = "<nmoperad>" +
                                             TRIM(cratpro.nmoperad) +
                                             "</nmoperad>"
                   xml_operacao25.nrcpfope = "<nrcpfope>" +
                                             STRING(cratpro.nrcpfope) +
                                             "</nrcpfope>"
                   xml_operacao25.cdbcoctl = "<cdbcoctl>" +
                                             STRING(cratpro.cdbcoctl, "999") +
                                             "</cdbcoctl>" 
                                             WHEN cratpro.cdbcoctl <> 0
                   xml_operacao25.cdagectl = "<cdagectl>" +
                                             STRING(cratpro.cdagectl, "9999") +
                                             "</cdagectl>"
                   xml_operacao25.cdagesic = "<cdagesic>" +
                                             STRING(cratpro.cdagesic, "9999") +
                                             "</cdagesic>"
                   xml_operacao25.dscabfim = "</DADOS>".
        
        END. /** Fim do FOR EACH cratpro **/
                   
        RUN proc_geracao_log (INPUT TRUE). 
             
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
