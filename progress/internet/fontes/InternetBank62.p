/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank62.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Dezembro/2010                   Ultima atualizacao: 24/09/2013
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Listar titulos do sacado eletronico (DDA)
    
    Alteracoes: 
    
    26/11/2011 - Adicionado campo em tt-titulos-sacado-dda.vlliquid para retirar 
                 abatimento e desconto, identificando valor liquido a pagar. 
                 (Jorge)
                 
    30/01/2012 - Adicionado parametros da tt-titulos-sadado-dda: vldsccal, 
                 vljurcal, vlmulcal e vltotcob. Passando para XML (Jorge)
                 
    12/03/2012 - Adicioando parametro da tt-titulos-sacado-dda dtlimpgt, 
                 passando para XML. (Jorge)
                 
    24/09/2013 - Informar horario de pagto de VR Boletos no XML. (Rafael)            
                            
	25/10/2017 -  Permitir filtrar situação do Boleto na pesquisa de titulos
				  PRJ356.4 - DDA (Ricardo Linhares)   
							
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0079 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdinstr AS CHAR EXTENT 2                                  NO-UNDO.

DEF VAR aux_qttitulo AS INTE                                           NO-UNDO.

DEF VAR aux_hrinivrb LIKE tt-limite.hrinipag                           NO-UNDO.
DEF VAR aux_hrfimvrb LIKE tt-limite.hrfimpag                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_inpessoa LIKE crapass.inpessoa                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_dtvenini AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvenfin AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nritmini AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nritmfin AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idordena AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flgerlog AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_cdsittit AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.


IF par_inpessoa = 0 THEN DO:
  FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND 
						  crapass.nrdconta = par_nrdconta 
						  NO-LOCK. END.
  
  IF AVAILABLE crapass  THEN
	 ASSIGN par_inpessoa = crapass.inpessoa.
  ELSE 
	 ASSIGN par_inpessoa = 1.	
END. 



RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

RUN sistema/generico/procedures/b1wgen0079.p PERSISTENT SET h-b1wgen0079.

IF  NOT VALID-HANDLE(h-b1wgen0079)  THEN
DO:
    DELETE PROCEDURE h-b1wgen0015.

    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0079.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

/* Verificar horario de pagto de VR Boletos */
RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90,         /** PAC       **/
                                      INPUT 6,          /** VR Boletos **/
                                      INPUT par_inpessoa,
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite).

FIND FIRST tt-limite NO-LOCK NO-ERROR.

IF  AVAIL tt-limite THEN
    DO:
        ASSIGN aux_hrinivrb = tt-limite.hrinipag
               aux_hrfimvrb = tt-limite.hrfimpag.
    END.

EMPTY TEMP-TABLE tt-limite.

RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90,         /** PAC       **/
                                      INPUT 2,          /** PAGAMENTO **/
                                      INPUT par_inpessoa,
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite).

DELETE PROCEDURE h-b1wgen0015.

IF  RETURN-VALUE = "NOK"  THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.

FIND FIRST tt-limite NO-LOCK NO-ERROR.

IF  NOT AVAILABLE tt-limite  THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Dados de acesso nao encontrados." + 
                          "</dsmsgerr>".
    RETURN "NOK".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<LIMITE><hrinipag>" +
                               tt-limite.hrinipag +
                               "</hrinipag>" +
                               "<hrfimpag>" +
                               tt-limite.hrfimpag +
                               "</hrfimpag>" +
                               "<idesthor>" +
                               STRING(tt-limite.idesthor) +
                               "</idesthor>" + 
                               "<hrinivrb>" + aux_hrinivrb + "</hrinivrb>" +
                               "<hrfimvrb>" + aux_hrfimvrb + "</hrfimvrb>" +
                               "</LIMITE>".

RUN lista-titulos-sacado IN h-b1wgen0079 
                              (INPUT par_cdcooper,
                               INPUT 90,             /** PAC       **/
                               INPUT 900,            /** Caixa     **/
                               INPUT "996",          /** Operador  **/
                               INPUT "INTERNETBANK", /** Tela      **/
                               INPUT 3,              /** Origem    **/
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtvenini,
                               INPUT par_dtvenfin,
                               INPUT par_nritmini,
                               INPUT par_nritmfin,
							   INPUT par_cdsittit, /* Situacao */
							   /*INPUT 0, */  /** Situacao **/
                               INPUT par_idordena,
                               INPUT par_flgerlog,
                              OUTPUT aux_qttitulo,
                              OUTPUT TABLE tt-titulos-sacado-dda,
                              OUTPUT TABLE tt-instr-tit-sacado-dda,
                              OUTPUT TABLE tt-descto-tit-sacado-dda,
                              OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0079.

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
ASSIGN xml_operacao.dslinxml = "<TITULOS_DDA qttitulo='" + 
                               STRING(aux_qttitulo) + "'>".

FOR EACH tt-titulos-sacado-dda NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<TITULO>" +
           "<nrorditm>" + STRING(tt-titulos-sacado-dda.nrorditm) + 
                          "</nrorditm>" +
           "<idtitdda>" + STRING(tt-titulos-sacado-dda.idtitdda) + 
                          "</idtitdda>" +
           "<nmdsacad>" + tt-titulos-sacado-dda.nmdsacad + "</nmdsacad>" +
           "<tppessac>" + tt-titulos-sacado-dda.tppessac + "</tppessac>" +
           "<nrdocsac>" + STRING(tt-titulos-sacado-dda.nrdocsac) + 
                          "</nrdocsac>" +
           "<dsdocsac>" + tt-titulos-sacado-dda.dsdocsac + "</dsdocsac>" +
           "<nmcedent>" + tt-titulos-sacado-dda.nmcedent + "</nmcedent>" +
           "<tppesced>" + tt-titulos-sacado-dda.tppesced + "</tppesced>" +
           "<nrdocced>" + STRING(tt-titulos-sacado-dda.nrdocced) + 
                          "</nrdocced>" +
           "<dsdocced>" + tt-titulos-sacado-dda.dsdocced + "</dsdocced>" +
           "<nrdocmto>" + tt-titulos-sacado-dda.nrdocmto + "</nrdocmto>" +
           "<dtvencto>" + (IF  tt-titulos-sacado-dda.dtvencto = ?  THEN 
                               ""
                           ELSE 
                               STRING(tt-titulos-sacado-dda.dtvencto,
                                      "99/99/9999")) + "</dtvencto>" +
           "<cddmoeda>" + tt-titulos-sacado-dda.cddmoeda + "</cddmoeda>" +
           "<dsdmoeda>" + tt-titulos-sacado-dda.dsdmoeda + "</dsdmoeda>" +
           "<vltitulo>" + TRIM(STRING(tt-titulos-sacado-dda.vltitulo,
                                      "zzz,zzz,zzz,zz9.99")) + "</vltitulo>" +
           "<nossonum>" + tt-titulos-sacado-dda.nossonum + "</nossonum>" +
           "<dtemissa>" + (IF  tt-titulos-sacado-dda.dtemissa = ?  THEN 
                               ""
                           ELSE 
                               STRING(tt-titulos-sacado-dda.dtemissa,
                                      "99/99/9999")) + "</dtemissa>" + 
           "<qtdiapro>" + STRING(tt-titulos-sacado-dda.qtdiapro) + 
                          "</qtdiapro>" +
           "<vlrabati>" + TRIM(STRING(tt-titulos-sacado-dda.vlrabati,
                          "zzz,zzz,zzz,zz9.99")) + "</vlrabati>" +
           "<dsdamora>" + tt-titulos-sacado-dda.dsdamora + "</dsdamora>" +
           "<dsdmulta>" + tt-titulos-sacado-dda.dsdmulta + "</dsdmulta>" +
           "<nmsacava>" + tt-titulos-sacado-dda.nmsacava + "</nmsacava>" +
           "<dsdocsav>" + tt-titulos-sacado-dda.dsdocsav + "</dsdocsav>" +
           "<cdsittit>" + STRING(tt-titulos-sacado-dda.cdsittit) + 
                          "</cdsittit>" +
           "<dssittit>" + tt-titulos-sacado-dda.dssittit + "</dssittit>" +
           "<dscodbar>" + tt-titulos-sacado-dda.dscodbar + "</dscodbar>" +
           "<dslindig>" + tt-titulos-sacado-dda.dslindig + "</dslindig>" +
           "<idtpdpag>" + STRING(tt-titulos-sacado-dda.idtpdpag) + 
                          "</idtpdpag>" + 
           "<flgvenci>" + STRING(tt-titulos-sacado-dda.flgvenci,"VENCIDO/") + 
                          "</flgvenci>" + 
           "<nmressac>" + tt-titulos-sacado-dda.nmressac + "</nmressac>" +
           "<nmresced>" + tt-titulos-sacado-dda.nmresced + "</nmresced>" +
           "<nmcedhis>" + tt-titulos-sacado-dda.nmcedhis + "</nmcedhis>" +
           "<cdbccced>" + tt-titulos-sacado-dda.cdbccced + "</cdbccced>" +
           "<nmbccced>" + tt-titulos-sacado-dda.nmbccced + "</nmbccced>" +
           "<flgpghab>" + STRING(tt-titulos-sacado-dda.flgpghab,"SIM/NAO") + 
                          "</flgpghab>" +
           "<cdcartei>" + tt-titulos-sacado-dda.cdcartei + "</cdcartei>" +
           "<dscartei>" + tt-titulos-sacado-dda.dscartei + "</dscartei>" +
           "<idtitneg>" + tt-titulos-sacado-dda.idtitneg + "</idtitneg>" +
           "<vlliquid>" + TRIM(STRING(tt-titulos-sacado-dda.vlliquid,
                          "zzz,zzz,zzz,zz9.99")) + "</vlliquid>" +
           "<vldsccal>" + TRIM(STRING(tt-titulos-sacado-dda.vldsccal,
                          "zzz,zzz,zzz,zz9.99")) + "</vldsccal>" +
           "<vljurcal>" + TRIM(STRING(tt-titulos-sacado-dda.vljurcal,
                          "zzz,zzz,zzz,zz9.99")) + "</vljurcal>" +
           "<vlmulcal>" + TRIM(STRING(tt-titulos-sacado-dda.vlmulcal,
                          "zzz,zzz,zzz,zz9.99")) + "</vlmulcal>" +
           "<vltotcob>" + TRIM(STRING(tt-titulos-sacado-dda.vltotcob,
                          "zzz,zzz,zzz,zz9.99")) + "</vltotcob>" +
           "<dtlimpgt>" + (IF  tt-titulos-sacado-dda.dtlimpgt = ?  THEN 
                               ""
                           ELSE 
                               STRING(tt-titulos-sacado-dda.dtlimpgt,
                                      "99/99/9999")) + "</dtlimpgt>" +
           "<INSTRUCOES>".
    
    FOR EACH tt-instr-tit-sacado-dda WHERE
             tt-instr-tit-sacado-dda.nrorditm = tt-titulos-sacado-dda.nrorditm
             NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<INSTRUCAO><dsdinstr>" + 
                                       TRIM(tt-instr-tit-sacado-dda.dsdinstr) + 
                                       "</dsdinstr></INSTRUCAO>".
        
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</INSTRUCOES><DESCONTOS>".

    FOR EACH tt-descto-tit-sacado-dda WHERE
             tt-descto-tit-sacado-dda.nrorditm = tt-titulos-sacado-dda.nrorditm
             NO-LOCK:
        
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<DESCONTO><dsdescto>" +
               tt-descto-tit-sacado-dda.dsdescto + "</dsdescto></DESCONTO>".

    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</DESCONTOS></TITULO>".
                
END. /** Fim do FOR EACH tt-titulos-sacado-dda **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</TITULOS_DDA>".
           
RETURN "OK".

/*............................................................................*/




