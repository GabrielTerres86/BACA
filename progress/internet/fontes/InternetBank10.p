/* ............................................................................

   Programa: siscaixa/web/InternetBank10.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2007.                      Ultima atualizacao: 03/10/2012

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Montar extrato da conta investimento para Internet.
   
   Alteracoes: 04/10/2007 - Utilizar BO b1wgen0020 e nao BO b1wgen0001 (David).
    
               12/11/2007 - Retirar log. Sera gerado log dentro da BO (David).
               
               10/03/2008 - Utilizar include var_ibank.i (David).
               
               03/11/2008 - Inclusao widget-pool (Martin).
               
               08/02/2012 - Incluir parametro em extrato_investimento (David).
               
               03/10/2012 - Alterado campo dshistor pelo dsextrat (Lcuas R.).
   
 ............................................................................ */
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0020tt.i }

DEF VAR h-b1wgen0020 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_vlsldant AS DECI                                           NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_dtfimper AS DATE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao10.

RUN sistema/generico/procedures/b1wgen0020.p PERSISTENT 
    SET h-b1wgen0020.

IF  VALID-HANDLE(h-b1wgen0020)  THEN
    DO: 
        RUN extrato_investimento IN h-b1wgen0020 
                                          (INPUT par_cdcooper,
                                           INPUT 90,            /** PAC      **/
                                           INPUT 900,           /** Caixa    **/
                                           INPUT "996",         /** Operador **/
                                           INPUT "INTERNETBANK",/** Tela     **/
                                           INPUT 3,             /** Origem   **/                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtiniper,
                                           INPUT par_dtfimper,
                                           INPUT TRUE,
                                          OUTPUT aux_vlsldant,
                                          OUTPUT TABLE tt-extrato_inv).

        DELETE PROCEDURE h-b1wgen0020.
        
        FIND FIRST tt-extrato_inv NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt-extrato_inv  THEN
            DO:
                ASSIGN aux_dscritic = "Nao houve movimentacao na conta " +
                                      "investimento durante esse periodo."
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                                      
                RETURN "NOK".
            END.
            
        CREATE xml_operacao10.
        ASSIGN xml_operacao10.dscabini = "<SALDO_ANTERIOR>"
               xml_operacao10.dtmvtolt = "<dtmvtolt></dtmvtolt>"
               xml_operacao10.dshistor = "<dsextrat>" +
                                         "SALDO ANTERIOR" +
                                         "</dsextrat>"
               xml_operacao10.nrdocmto = "<nrdocmto></nrdocmto>"
               xml_operacao10.indebcre = "<indebcre></indebcre>"
               xml_operacao10.vllanmto = "<vllanmto></vllanmto>"
               xml_operacao10.vlsldtot = "<vlsldant>" + 
                                  TRIM(STRING(aux_vlsldant,"zzz,zzz,zz9.99-")) +
                                         "</vlsldant>"
               xml_operacao10.dscabfim = "</SALDO_ANTERIOR>".
               
        FOR EACH tt-extrato_inv NO-LOCK BY tt-extrato_inv.dtmvtolt:
        
            CREATE xml_operacao10.
            ASSIGN xml_operacao10.dscabini = "<LANCAMENTO>"
                   xml_operacao10.dtmvtolt = "<dtmvtolt>" +
                                STRING(tt-extrato_inv.dtmvtolt,"99/99/9999") +
                                             "</dtmvtolt>"
                   xml_operacao10.dshistor = "<dsextrat>" +
                                             tt-extrato_inv.dsextrat +
                                             "</dsextrat>"
                   xml_operacao10.nrdocmto = "<nrdocmto>" +
                           TRIM(STRING(tt-extrato_inv.nrdocmto,"zzzzzz,zz9")) +
                                             "</nrdocmto>"
                   xml_operacao10.indebcre = "<indebcre>" +
                                             tt-extrato_inv.indebcre +
                                             "</indebcre>"
                   xml_operacao10.vllanmto = "<vllanmto>" +
                     TRIM(STRING(tt-extrato_inv.vllanmto,"zzz,zzz,zz9.99-")) +
                                             "</vllanmto>"
                   xml_operacao10.vlsldtot = "<vlsldtot>" +
                     TRIM(STRING(tt-extrato_inv.vlsldtot,"zzz,zzz,zz9.99-")) +
                                             "</vlsldtot>" 
                   xml_operacao10.dscabfim = "</LANCAMENTO>".
        
        END.
        
        RETURN "OK".
    END.

/* .......................................................................... */
