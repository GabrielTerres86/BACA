/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank63.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jorge
    Data    : Abril/2011                   Ultima atualizacao: 26/07/2011
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Consulta de sacado eletronico (DDA)
    
    Alteracoes: 26/07/2011 - Substituido o campo nrlivdda pelo idlivdda
                             na crapcop (Gabriel).
                            
				25/10/2017 -  Adicionado novos campos para exibição de DDA no Mobile
							  PRJ356.4 - DDA (Ricardo Linhares)
                            
..............................................................................*/

CREATE WIDGET-POOL.    

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0078tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

IF  NOT VALID-HANDLE(h-b1wgen0078)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0078.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN consulta-sacado-eletronico IN h-b1wgen0078 
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT TRUE,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-sacado-eletronico).
DELETE PROCEDURE h-b1wgen0078.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-erro  THEN
            ASSIGN aux_dscritic = tt-erro.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Falha na requisicao.".

        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

IF  NOT VALID-HANDLE(h-b1wgen0078)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0078.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN busca-coop IN h-b1wgen0078  (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-crapcop).

DELETE PROCEDURE h-b1wgen0078.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro  THEN
            ASSIGN aux_dscritic = tt-erro.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Falha na requisicao.".

        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<SACADO_ELETRONICO>".

FIND FIRST tt-sacado-eletronico NO-LOCK NO-ERROR.

IF AVAIL tt-sacado-eletronico THEN 
DO:
    FIND FIRST tt-crapcop NO-LOCK NO-ERROR.
    IF AVAIL tt-crapcop THEN
    DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = 
           "<flgativo>" + STRING(tt-sacado-eletronico.flsacpro,"SIM/NAO") + 
           "</flgativo>"
         + "<dtadesao>" + (IF tt-sacado-eletronico.dtadesao = ?  THEN 
                               ""
                           ELSE 
                               STRING(tt-sacado-eletronico.dtadesao,
                                      "99/99/9999")) + "</dtadesao>"
         + "<dtexclus>" + (IF tt-sacado-eletronico.dtexclus = ?  THEN 
                               ""
                           ELSE 
                               STRING(tt-sacado-eletronico.dtexclus,
                                      "99/99/9999")) + "</dtexclus>"
         + "<btnaderi>" + STRING(tt-sacado-eletronico.btnaderi) + "</btnaderi>"
         + "<dtctrdda>" + (IF tt-crapcop.dtctrdda = ?  THEN 
                               ""
                           ELSE 
                               STRING(tt-crapcop.dtctrdda,
                                      "99/99/9999")) + "</dtctrdda>"
         + "<nrctrdda>" + STRING(tt-crapcop.nrctrdda) + "</nrctrdda>"
         + "<idlivdda>" + STRING(tt-crapcop.idlivdda) + "</idlivdda>"
         + "<nrfoldda>" + STRING(tt-crapcop.nrfoldda) + "</nrfoldda>"
         + "<dslocdda>" + STRING(tt-crapcop.dslocdda) + "</dslocdda>"
         + "<dsciddda>" + STRING(tt-crapcop.dsciddda) + "</dsciddda>"
         + "<nmextcop>" + STRING(tt-crapcop.nmextcop) + "</nmextcop>"
         + "<nmrescop>" + STRING(tt-crapcop.nmrescop) + "</nmrescop>"
         + "<nmcidade>" + STRING(tt-crapcop.nmcidade) + "</nmcidade>"
         + "<cdufdcop>" + STRING(tt-crapcop.cdufdcop) + "</cdufdcop>"
         + "<nrcpfcgc>" + STRING(tt-sacado-eletronico.nrcpfcgc) + "</nrcpfcgc>"
		 + "<inpessoa>" + STRING(tt-sacado-eletronico.inpessoa) + "</inpessoa>"
         + "<dspessoa>" + STRING(tt-sacado-eletronico.dspessoa) + "</dspessoa>"
         + "<nmextttl>" + STRING(tt-sacado-eletronico.nmextttl) + "</nmextttl>"
         + "<dscpfcgc>" + STRING(tt-sacado-eletronico.dscpfcgc) + "</dscpfcgc>".         
          
    END.
    ELSE
    DO:
        ASSIGN aux_dscritic = "Falha na requisicao.".
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
END. /** Fim do FIND FIRST tt-sacado-eletronico **/
ELSE
DO:
    ASSIGN aux_dscritic = "Falha na requisicao.".
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</SACADO_ELETRONICO>".
           
RETURN "OK".

/*............................................................................*/

