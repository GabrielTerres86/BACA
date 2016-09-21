/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank65.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jorge
    Data    : Abril/2011                   Ultima atualizacao: 00/00/0000
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Listar titulos bloqueados do sacado eletronico (DDA)
    
    Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdinstr AS CHAR EXTENT 2                                  NO-UNDO.

DEF VAR aux_qttitulo AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_inpessoa LIKE crapass.inpessoa                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_dtvenini AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvenfin AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_idordena AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flgerlog AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.


RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

IF  NOT VALID-HANDLE(h-b1wgen0078)  THEN
DO:

    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0078.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.
        
RUN lista-grupo-titulos-sacado IN h-b1wgen0078 
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
                               INPUT 13,  /** Situacao **/
                               INPUT par_idordena,
                               INPUT par_flgerlog,
                              OUTPUT aux_qttitulo,
                              OUTPUT TABLE tt-grupo-titulos-sacado-dda,
                              OUTPUT TABLE tt-grupo-instr-tit-sacado-dda,
                              OUTPUT TABLE tt-grupo-descto-tit-sacado-dda,
                              OUTPUT TABLE tt-erro).

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
ASSIGN xml_operacao.dslinxml = "<TITULOS_DDA qttitulo='" + 
                               STRING(aux_qttitulo) + "'>".

FOR EACH tt-grupo-titulos-sacado-dda NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<TITULO>" +
       "<nrorditm>" + STRING(tt-grupo-titulos-sacado-dda.nrorditm) + 
                      "</nrorditm>" +
       "<idtitdda>" + STRING(tt-grupo-titulos-sacado-dda.idtitdda) + 
                      "</idtitdda>" +
       "<nmdsacad>" + tt-grupo-titulos-sacado-dda.nmdsacad + "</nmdsacad>" +
       "<tppessac>" + tt-grupo-titulos-sacado-dda.tppessac + "</tppessac>" +
       "<nrdocsac>" + STRING(tt-grupo-titulos-sacado-dda.nrdocsac) + 
                      "</nrdocsac>" +
       "<dsdocsac>" + tt-grupo-titulos-sacado-dda.dsdocsac + "</dsdocsac>" +
       "<nmcedent>" + tt-grupo-titulos-sacado-dda.nmcedent + "</nmcedent>" +
       "<tppesced>" + tt-grupo-titulos-sacado-dda.tppesced + "</tppesced>" +
       "<nrdocced>" + STRING(tt-grupo-titulos-sacado-dda.nrdocced) + 
                      "</nrdocced>" +
       "<dsdocced>" + tt-grupo-titulos-sacado-dda.dsdocced + "</dsdocced>" +
       "<nrdocmto>" + tt-grupo-titulos-sacado-dda.nrdocmto + "</nrdocmto>" +
       "<dtvencto>" + (IF  tt-grupo-titulos-sacado-dda.dtvencto = ?  THEN 
                           ""
                       ELSE 
                           STRING(tt-grupo-titulos-sacado-dda.dtvencto,
                                  "99/99/9999")) + "</dtvencto>" +
       "<cddmoeda>" + tt-grupo-titulos-sacado-dda.cddmoeda + "</cddmoeda>" +
       "<dsdmoeda>" + tt-grupo-titulos-sacado-dda.dsdmoeda + "</dsdmoeda>" +
       "<vltitulo>" + TRIM(STRING(tt-grupo-titulos-sacado-dda.vltitulo,
                                  "zzz,zzz,zzz,zz9.99")) + "</vltitulo>" +
       "<nossonum>" + tt-grupo-titulos-sacado-dda.nossonum + "</nossonum>" +
       "<dtemissa>" + (IF  tt-grupo-titulos-sacado-dda.dtemissa = ?  THEN 
                           ""
                       ELSE 
                           STRING(tt-grupo-titulos-sacado-dda.dtemissa,
                                  "99/99/9999")) + "</dtemissa>" + 
       "<qtdiapro>" + STRING(tt-grupo-titulos-sacado-dda.qtdiapro) + 
                      "</qtdiapro>" +
       "<vlrabati>" + TRIM(STRING(tt-grupo-titulos-sacado-dda.vlrabati,
                      "zzz,zzz,zzz,zz9.99")) + "</vlrabati>" +
       "<dsdamora>" + tt-grupo-titulos-sacado-dda.dsdamora + "</dsdamora>" +
       "<dsdmulta>" + tt-grupo-titulos-sacado-dda.dsdmulta + "</dsdmulta>" +
       "<nmsacava>" + tt-grupo-titulos-sacado-dda.nmsacava + "</nmsacava>" +
       "<dsdocsav>" + tt-grupo-titulos-sacado-dda.dsdocsav + "</dsdocsav>" +
       "<cdsittit>" + STRING(tt-grupo-titulos-sacado-dda.cdsittit) + 
                      "</cdsittit>" +
       "<dssittit>" + tt-grupo-titulos-sacado-dda.dssittit + "</dssittit>" +
       "<dscodbar>" + tt-grupo-titulos-sacado-dda.dscodbar + "</dscodbar>" +
       "<dslindig>" + tt-grupo-titulos-sacado-dda.dslindig + "</dslindig>" +
       "<idtpdpag>" + STRING(tt-grupo-titulos-sacado-dda.idtpdpag) + 
                      "</idtpdpag>" + 
       "<flgvenci>" + STRING(tt-grupo-titulos-sacado-dda.flgvenci,"VENCIDO/") + 
                      "</flgvenci>" + 
       "<nmressac>" + tt-grupo-titulos-sacado-dda.nmressac + "</nmressac>" +
       "<nmresced>" + tt-grupo-titulos-sacado-dda.nmresced + "</nmresced>" +
       "<nmcedhis>" + tt-grupo-titulos-sacado-dda.nmcedhis + "</nmcedhis>" +
       "<cdbccced>" + tt-grupo-titulos-sacado-dda.cdbccced + "</cdbccced>" +
       "<nmbccced>" + tt-grupo-titulos-sacado-dda.nmbccced + "</nmbccced>" +
       "<flgpghab>" + STRING(tt-grupo-titulos-sacado-dda.flgpghab,"SIM/NAO") + 
                      "</flgpghab>" +
       "<cdcartei>" + tt-grupo-titulos-sacado-dda.cdcartei + "</cdcartei>" +
       "<dscartei>" + tt-grupo-titulos-sacado-dda.dscartei + "</dscartei>" +
       "<idtitneg>" + tt-grupo-titulos-sacado-dda.idtitneg + "</idtitneg>" +
       "<INSTRUCOES>".
    
    FOR EACH tt-grupo-instr-tit-sacado-dda WHERE
             tt-grupo-instr-tit-sacado-dda.nrorditm = 
             tt-grupo-titulos-sacado-dda.nrorditm
             NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<INSTRUCAO>" + 
                "<dsdinstr>" + TRIM(tt-grupo-instr-tit-sacado-dda.dsdinstr) + 
                "</dsdinstr></INSTRUCAO>".
        
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</INSTRUCOES><DESCONTOS>".

    FOR EACH tt-grupo-descto-tit-sacado-dda WHERE
             tt-grupo-descto-tit-sacado-dda.nrorditm = 
             tt-grupo-titulos-sacado-dda.nrorditm
             NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<DESCONTO>" + 
            "<dsdescto>" + tt-grupo-descto-tit-sacado-dda.dsdescto + 
            "</dsdescto></DESCONTO>".

    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</DESCONTOS></TITULO>".
                
END. /** Fim do FOR EACH tt-grupo-titulos-sacado-dda **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</TITULOS_DDA>".
           
RETURN "OK".

/*............................................................................*/

