/*..............................................................................
   
   Programa: siscaixa/web/InternetBank29.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2007.                       Ultima atualizacao: 07/06/2013
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Montar extrato de capital para Internet.
   
   Alteracoes: 04/10/2007 - Utilizar BO b1wgen0021 e nao BO b1wgen0021 (David).
                
               06/11/2007 - Retirar log. Sera gerado log dentro da BO (David).
               
               10/03/2008 - Utilizar include var_ibank.i (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               14/09/2010 - Ajustar FORMAT para o campo nrdocmto (David).
               
               05/10/2011 - Incluir parametro na procedure extrato_cotas (David)
               
               03/10/2012 - Anterado campo dshistor pelo dsextrat (Lucas R.).
               
               07/06/2013 - Incluir procedure retorna-valor-blqjud e tag xml
                            <vlblqjud> (Lucas R.).
 
			   21/09/2016 - P169 Adicionada novas tags para o projeto de integralizacao
							de cotas (Ricardo Linhares).
 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0021tt.i }

DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_vlsldant AS DECI                                           NO-UNDO.
DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.

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
                                         INPUT 4, /* 4 - Capital */
                                         INPUT par_dtmvtolt,
                                         OUTPUT aux_vlblqjud,
                                         OUTPUT aux_vlresblq).

IF  VALID-HANDLE(h-b1wgen0155) THEN
    DELETE PROCEDURE h-b1wgen0155.

RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT SET h-b1wgen0021.
                
IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
    DO: 
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0021." +
                              "</dsmsgerr>".
        RETURN "NOK".
    END.

RUN extrato_cotas IN h-b1wgen0021 (INPUT par_cdcooper,
                                   INPUT 90,            /** PAC      **/
                                   INPUT 900,           /** Caixa    **/
                                   INPUT "996",         /** Operador **/
                                   INPUT "INTERNETBANK",/** Tela     **/
                                   INPUT 3,             /** Origem   **/
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtiniper,
                                   INPUT par_dtfimper,
                                   INPUT TRUE,
                                  OUTPUT aux_vlsldant,
                                  OUTPUT TABLE tt-extrato_cotas).

DELETE PROCEDURE h-b1wgen0021.

FIND FIRST tt-extrato_cotas NO-LOCK NO-ERROR.

IF  NOT AVAILABLE tt-extrato_cotas  THEN
    DO:
        ASSIGN aux_dscritic = "Nao houve movimentacao no capital " +
                              "durante esse periodo."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                              "</dsmsgerr>".
                              
        RETURN "NOK".
    END.
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<SALDO_ANTERIOR>" +
                               "<dtmvtolt>" +
                               (IF par_dtiniper <> ? THEN
                                   STRING((par_dtiniper - 1),"99/99/9999")
                                ELSE
                                   "") +
                               "</dtmvtolt>" +
                               "<dsextrat>SALDO ANTERIOR</dsextrat>" +
                               "<nrdocmto></nrdocmto>" +
                               "<nrctrpla></nrctrpla>" +
                               "<indebcre></indebcre>" +
                               "<vllanmto></vllanmto>" +
                               "<vlsldant>" + 
                               TRIM(STRING(aux_vlsldant,"zzz,zzz,zz9.99-")) +
                               "</vlsldant><vlblqjud>" +
                               TRIM(STRING(aux_vlblqjud,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "</vlblqjud><incancel></incancel><lctrowid></lctrowid></SALDO_ANTERIOR>".
       


FOR EACH tt-extrato_cotas NO-LOCK BY tt-extrato_cotas.dtmvtolt:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<LANCAMENTO><dtmvtolt>" +
                             STRING(tt-extrato_cotas.dtmvtolt,"99/99/9999") +
                                   "</dtmvtolt><dsextrat>" +
                                   tt-extrato_cotas.dsextrat +
                                   "</dsextrat><nrdocmto>" +
                      TRIM(STRING(tt-extrato_cotas.nrdocmto,"zzz,zzz,zz9")) +
                                   "</nrdocmto><nrctrpla>" +
                          TRIM(STRING(tt-extrato_cotas.nrctrpla,"zzz,zz9")) +
                                   "</nrctrpla><indebcre>" +
                                   tt-extrato_cotas.indebcre +
                                   "</indebcre><vllanmto>" +
                  TRIM(STRING(tt-extrato_cotas.vllanmto,"zzz,zzz,zz9.99-")) +
                                   "</vllanmto><vlsldtot>" +
                  TRIM(STRING(tt-extrato_cotas.vlsldtot,"zzz,zzz,zz9.99-")) +
                                   "</vlsldtot><incancel>" +
                                   TRIM(STRING(tt-extrato_cotas.incancel)) +
                                   "</incancel>"+
                                   "<lctrowid>" + 
                                   TRIM(STRING(tt-extrato_cotas.lctrowid)) +
                                   "</lctrowid></LANCAMENTO>".
END.
    
RETURN "OK".
    
/*............................................................................*/
