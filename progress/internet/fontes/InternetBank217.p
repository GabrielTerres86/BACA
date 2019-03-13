/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank217.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael Cechet
   Data    : Abril/2018                        Ultima atualizacao: 07/06/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar Boleto de Cobrança (SOA - ObterDetalheTituloCobranca)
   
   Alteracoes: 07/06/2018 - Incluido novas tags do endereco do beneficiario (P352 - Cechet)

..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcnvcob LIKE crapcob.nrcnvcob                    NO-UNDO.
DEF  INPUT PARAM par_nrdocmto LIKE crapcob.nrdocmto                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0010 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR par_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR par_intipcob AS INTE INIT 0                                    NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_flgregis AS LOGI                                           NO-UNDO.
DEF VAR par_intipemi AS INTE INIT 0                                    NO-UNDO.
DEF VAR aux_nrdocmto LIKE crapcob.nrdocmto INIT 0                      NO-UNDO.

/* Informações do beneficiário */
DEF VAR aux_nmprimtl_ben LIKE crapass.nmprimtl                         NO-UNDO.
DEF VAR aux_nrcpfcgc_ben LIKE crapass.nrcpfcgc                         NO-UNDO.
DEF VAR aux_inpessoa_ben LIKE crapass.inpessoa                         NO-UNDO.
DEF VAR aux_dsdemail_ben LIKE crapcem.dsdemail                         NO-UNDO.
DEF VAR aux_dsendere_bnf LIKE crapenc.dsendere                         NO-UNDO.
DEF var aux_nrendere_bnf AS CHAR                                       NO-UNDO.
DEF var aux_nrcepend_bnf AS CHAR                                       NO-UNDO.
DEF var aux_complend_bnf LIKE crapenc.complend                         NO-UNDO.
DEF var aux_nmbairro_bnf LIKE crapenc.nmbairro                         NO-UNDO.
DEF var aux_nmcidade_bnf LIKE crapenc.nmcidade                         NO-UNDO.
DEF var aux_cdufende_bnf LIKE crapenc.cdufende                         NO-UNDO.

/* Variaveis de ROLLOUT */
DEF VAR aux_dstextab LIKE craptab.dstextab                             NO-UNDO.
DEF VAR aux_dtmvtolt LIKE crapdat.dtmvtolt                             NO-UNDO.
DEF VAR aux_vltitulo LIKE crapcob.vltitulo                             NO-UNDO.
DEF VAR aux_npc_cip       AS INTE                                      NO-UNDO.
DEF VAR aux_vldescto      AS DEC                                       NO-UNDO.


/* sistema deve atribuir data do dia vindo da crapdat
   Rafael Cechet - 06/04/2011 */
FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  AVAILABLE crapdat  THEN
    ASSIGN par_dtmvtolt = crapdat.dtmvtolt.

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015.".
           xml_dsmsgerr = "<dsmsgerr>" + 
                          aux_dscritic + 
                          "</dsmsgerr>".  
    RETURN "NOK".
END.
/** Verifica o horario inicial e final para a operacao **/
RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90,
                                      INPUT 3,
                                      INPUT 0,
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite).

DELETE PROCEDURE h-b1wgen0015.

FIND FIRST tt-limite NO-LOCK NO-ERROR.

IF  AVAILABLE tt-limite  THEN
DO:
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml =  "<LIMITE><hrinicob>" + 
                                    tt-limite.hrinipag + 
                                    "</hrinicob><hrfimcob>" +
                                    tt-limite.hrfimpag + 
                                    "</hrfimcob><idesthor>" + 
                                    STRING(tt-limite.idesthor) +
                                    "</idesthor></LIMITE>".
END.

IF  RETURN-VALUE = "NOK"  THEN
DO:
    ASSIGN xml_dsmsgerr = "<DSMSGERR>" + aux_dscritic + 
                          "</DSMSGERR>".

    RETURN "NOK".
END.

RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN consultar-boleto IN h-b1wnet0001 (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC        **/
                                      INPUT 900,            /** Caixa      **/
                                      INPUT "996",          /** Operador   **/
                                      INPUT "INTERNETBANK", /** Tela       **/
                                      INPUT "3",            /** Origem     **/
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT 2,              /* indordem = 2 - Numero do boleto */
                                      INPUT 0,              /** CPF Sacado **/
                                      INPUT "",             /* par_nmdsacad */
                                      INPUT 7,              /* par_idsituac */
                                      INPUT 20,             /* par_nrregist */
                                      INPUT 1,              /* par_nriniseq */
                                      INPUT par_nrdocmto,   /* par_inidocto */
                                      INPUT par_nrdocmto,   /* par_fimdocto */
                                      INPUT ?,              /* par_inivecto */
                                      INPUT ?,              /* par_fimvecto */
                                      INPUT ?,              /* par_inipagto */
                                      INPUT ?,              /* par_fimpagto */
                                      INPUT ?,              /* par_iniemiss */
                                      INPUT ?,              /* par_fimemiss */
                                      INPUT TRUE,           /** Logar      **/
                                      INPUT ?,              /* par_dsdoccop */
                                      INPUT ?,              /* aux_flgregis */
                                      INPUT 0,              /* par_inserasa 0 - Todos */
                                     OUTPUT TABLE tt-consulta-blt,
                                     OUTPUT TABLE tt-erro).
           
DELETE PROCEDURE h-b1wnet0001.
       
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel consultar boletos.".
                    
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.    
            
FIND LAST tt-consulta-blt NO-LOCK NO-ERROR.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<REGISTROS>".
                
IF  AVAILABLE tt-consulta-blt  THEN
    DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<nrregist>" + 
                                       STRING(tt-consulta-blt.nrregist) + 
                                       "</nrregist>".
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</REGISTROS>".


RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

RUN verifica-convenios IN h-b1wnet0001 (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                       OUTPUT par_intipcob,
                                       OUTPUT par_intipemi).
DELETE PROCEDURE h-b1wnet0001.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DADOS><intipcob>" + 
                               STRING(par_intipcob) + 
                               "</intipcob>" + 
                               "<intipemi>" + 
                               STRING(par_intipemi) + 
                               "</intipemi>" +
                               "</DADOS>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DADOS_BOLETOS>".

FIND craptab WHERE craptab.cdcooper = par_cdcooper  
               AND craptab.nmsistem = "CRED"         
               AND craptab.tptabela = "GENERI"       
               AND craptab.cdempres = 0              
               AND craptab.cdacesso = "ROLLOUT_CIP_PAG"  
               AND craptab.tpregist = 0 NO-LOCK NO-ERROR.


IF  NOT AVAILABLE craptab   THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel consultar ROLLOUT.".
                    
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".     

    END.
ELSE 
    DO:
       ASSIGN aux_dstextab = craptab.dstextab
              aux_dtmvtolt = DATE(ENTRY(1,aux_dstextab,";"))
              aux_vltitulo = DEC(ENTRY(2,aux_dstextab,";")).
    END.

RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0010.".
           xml_dsmsgerr = "<dsmsgerr>" + 
                          aux_dscritic + 
                          "</dsmsgerr>".  
    RETURN "NOK".
END.
        
FOR EACH tt-consulta-blt NO-LOCK:
   
    IF tt-consulta-blt.nrcnvcob <> par_nrcnvcob OR 
       tt-consulta-blt.nrdocmto <> par_nrdocmto THEN
       NEXT. 
              
    ASSIGN aux_nmprimtl_ben = tt-consulta-blt.nmprimtl
           aux_nrcpfcgc_ben = tt-consulta-blt.nrcpfcgc
           aux_inpessoa_ben = tt-consulta-blt.inpessoa
           aux_npc_cip      = 0
           aux_nrdocmto     = tt-consulta-blt.nrdocmto.

    RUN verifica-titulo-npc-cip IN h-b1wgen0010(INPUT par_cdcooper,
                                                INPUT crapdat.dtmvtolt,
                                                INPUT tt-consulta-blt.vltitulo,
                                                INPUT (IF tt-consulta-blt.flgcbdda = "S" THEN TRUE else FALSE),
                                                OUTPUT aux_npc_cip). 

    IF tt-consulta-blt.cdmensag = 0 /*OR 
           tt-consulta-blt.cdmensag = 1*/ THEN
                ASSIGN aux_vldescto = 0.
        ELSE
                ASSIGN aux_vldescto = tt-consulta-blt.vldescto.                                                                                   

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<BOLETO><nossonro>" +
                                   tt-consulta-blt.nossonro +
                                   "</nossonro><nmdsacad>" +
                                   tt-consulta-blt.nmdsacad +
                                   "</nmdsacad><nrinssac>" +
                                   STRING(tt-consulta-blt.nrinssac) +
                                   "</nrinssac><dsendsac>" +
                                   tt-consulta-blt.dsendsac +
                                   "</dsendsac><nmbaisac>" +
                                   tt-consulta-blt.nmbaisac +
                                   "</nmbaisac><nmcidsac>" +
                                   tt-consulta-blt.nmcidsac +
                                   "</nmcidsac><cdufsaca>" +
                                   tt-consulta-blt.cdufsaca +
                                   "</cdufsaca><nrcepsac>" +
                                   STRING(tt-consulta-blt.nrcepsac,
                                          "99999999") +
                                   "</nrcepsac><nmdavali>" +
                                   tt-consulta-blt.nmdavali + 
                                   "</nmdavali><nrconven>" +
                                   STRING(tt-consulta-blt.nrcnvcob) +
                                   "</nrconven><nrcnvceb>" +
                                   STRING(tt-consulta-blt.nrcnvceb) +
                                   "</nrcnvceb><nrdctabb>" +
                                   STRING(tt-consulta-blt.nrdctabb) +
                                   "</nrdctabb><nrcpfcgc>" +
                                   STRING(tt-consulta-blt.nrcpfcgc) +
                                   "</nrcpfcgc><nrdocmto>" +
                                   STRING(tt-consulta-blt.nrdocmto) +
                                   "</nrdocmto><dtmvtolt>" +
                                   STRING(tt-consulta-blt.dtmvtolt,
                                          "99/99/9999") +
                                   "</dtmvtolt><dsdinstr>" +
                                   tt-consulta-blt.dsdinstr +
                                   "</dsdinstr><dsdoccop>" +
                                   STRING(tt-consulta-blt.dsdoccop) + 
                                   "</dsdoccop><dtvencto>" +
                                   STRING(tt-consulta-blt.dtvencto,
                                          "99/99/9999") +
                                   "</dtvencto><dtdpagto>" +
                                   (IF  tt-consulta-blt.dtdpagto = ?  THEN 
                                       " "
                                   ELSE 
                                       STRING(tt-consulta-blt.dtdpagto,
                                              "99/99/9999")) +
                                   "</dtdpagto><vltitulo>" +
                                   TRIM(STRING(tt-consulta-blt.vltitulo,
                                               "zzzzzzzzz9.99")) +
                                   "</vltitulo><vldpagto>" + 
                                   TRIM(STRING(tt-consulta-blt.vldpagto,
                                               "zzzzzzzzz9.99")) +
                                   "</vldpagto><cdtpinsc>" +
                                   STRING(tt-consulta-blt.cdtpinsc) +
                                   "</cdtpinsc><inpessoa>" +
                                   STRING(tt-consulta-blt.inpessoa) +
                                   "</inpessoa><nmprimtl>" +
                                   tt-consulta-blt.nmprimtl +
                                   "</nmprimtl><vldescto>" +
                                   TRIM(STRING(aux_vldescto,
                                               "zzzzzzzzz9.99")) +
                                   "</vldescto><cdmensag>" +
                                   STRING(tt-consulta-blt.cdmensag) +
                                   "</cdmensag><complend>" +
                                   tt-consulta-blt.complend +
                                   "</complend><idbaiexc>" +
                                   STRING(tt-consulta-blt.idbaiexc) +
                                   "</idbaiexc><cdsituac>" +
                                   tt-consulta-blt.cdsituac +
                                   "</cdsituac><dsinform>" +
                                   tt-consulta-blt.dsinform +
                                   "</dsinform><vlabatim>" +
                                   TRIM(STRING(tt-consulta-blt.vlabatim,
                                               "zzzzzzzzz9.99")) +
                                   "</vlabatim><cddespec>" +
                                   STRING(tt-consulta-blt.cddespec) +
                                   "</cddespec><dtdocmto>" +
                                   STRING(tt-consulta-blt.dtdocmto,
                                          "99/99/9999") +
                                   "</dtdocmto><dsdpagto>" + 
                                   tt-consulta-blt.dsdpagto +
                                   "</dsdpagto><cdbanpag>" +
                                   STRING(tt-consulta-blt.cdbanpag) +
                                   "</cdbanpag><cdagepag>" +
                                   STRING(tt-consulta-blt.cdagepag) +
                                   "</cdagepag><dssituac>" + 
                                   tt-consulta-blt.dssituac + 
                                   "</dssituac><flgdesco>" +
                                   tt-consulta-blt.flgdesco +
                                   "</flgdesco><dtelimin>" +
                                  (IF  tt-consulta-blt.dtelimin = ?  THEN
                                       " "
                                   ELSE
                                       STRING(tt-consulta-blt.dtelimin,
                                              "99/99/9999")) +
                                   "</dtelimin><cdcartei>" +
                                   STRING(tt-consulta-blt.cdcartei) +
                                   "</cdcartei>" + 
                                   /* adicionado codigo do banco
                                      Rafael Cechet - 31/03/11 */
                                   "<cdbandoc>" + STRING(tt-consulta-blt.cdbandoc) + 
                                   "</cdbandoc>" + 
                                   /* adicionado flgregis,nrnosnum,agencidv - Cob. Registrada
                                      Rafael Cechet - 01/04/11 */
                                   "<flgregis>" + (IF TRIM(tt-consulta-blt.flgregis) = "S"  THEN
                                       "1" ELSE "2") + "</flgregis>" + 
                                   "<nrnosnum>" + tt-consulta-blt.nrnosnum + "</nrnosnum>" + 
                                   "<agencidv>" + tt-consulta-blt.agencidv + "</agencidv>" + 
                                   /* adicionado nrvarcar, flgaceit, tpjurmor, vljurdia, 
                                      tpdmulta, vlrmulta - Cob. Registrada
                                      Rafael Cechet - 18/04/11 */
                                   "<nrvarcar>" + STRING(tt-consulta-blt.nrvarcar) + "</nrvarcar>" +
                                   "<flgaceit>" + TRIM(tt-consulta-blt.flgaceit) + "</flgaceit>" +
                                   "<tpjurmor>" + STRING(tt-consulta-blt.tpjurmor) + "</tpjurmor>" +
                                   "<vljurdia>" + TRIM(STRING(tt-consulta-blt.vlrjuros,
                                               "zzzzzzzzz9.99")) + "</vljurdia>" + 
                                   "<tpdmulta>" + STRING(tt-consulta-blt.tpdmulta) + "</tpdmulta>" +
                                   "<vlrmulta>" + TRIM(STRING(tt-consulta-blt.vlrmulta,
                                               "zzzzzzzzz9.99")) + "</vlrmulta>" + 
                                   "<flgdprot>" + (IF (tt-consulta-blt.flgdprot = TRUE) THEN 
                                       "S" ELSE "N") + "</flgdprot>" +
                                   "<qtdiaprt>" + STRING(tt-consulta-blt.qtdiaprt, "99") + "</qtdiaprt>" +
                                   "<indiaprt>" + STRING(tt-consulta-blt.indiaprt, "9") + "</indiaprt>" +
                                   "<insitpro>" + STRING(tt-consulta-blt.insitpro, "9") + "</insitpro>" +
                                   "<cdtpinav>" + STRING(tt-consulta-blt.cdtpinav, "9") + "</cdtpinav>" + 
                                   "<nrinsava>" + STRING(tt-consulta-blt.nrinsava) + "</nrinsava>" +

                                   /* Campos de email do pagador */
                                   "<dsdemail>" + STRING(tt-consulta-blt.dsdemail) + "</dsdemail>" +
                                   "<flgemail>" + (IF(tt-consulta-blt.flgemail) THEN "1" ELSE "0")  + "</flgemail>" +
                    
                                    /* Identifica se o boleto pertence a algum carne */
                                    "<flgcarne>" + (IF(tt-consulta-blt.flgcarne) THEN "1" ELSE "0")  + "</flgcarne>" +
                                    
                                    "<inserasa>" + STRING(tt-consulta-blt.cdserasa, "9") + "</inserasa>" +
                                    "<dsserasa>" + tt-consulta-blt.dsserasa + "</dsserasa>" +
                                    "<flserasa>" + (IF (tt-consulta-blt.flserasa = TRUE) THEN 
                                       "S" ELSE "N") + "</flserasa>" +
                                    "<qtdianeg>" + STRING(tt-consulta-blt.qtdianeg) + "</qtdianeg>" +
                                    "<dtvencto_atualizado>" + STRING(tt-consulta-blt.dtvencto_atualizado,"99/99/9999") + "</dtvencto_atualizado>" +
                                    "<vltitulo_atualizado>" + STRING(tt-consulta-blt.vltitulo_atualizado,"zzzzzzzzz9.99") + "</vltitulo_atualizado>" +
                                    "<vlmormul_atualizado>" + STRING(tt-consulta-blt.vlmormul_atualizado,"zzzzzzzzz9.99") + "</vlmormul_atualizado>" +
                                    "<flg2viab>" + STRING(tt-consulta-blt.flg2viab) + "</flg2viab>" +
                                                                        "<flprotes>" + STRING(tt-consulta-blt.flprotes) + "</flprotes>" +
                                    /* Aviso SMS */
                                    "<inavisms>" + STRING(tt-consulta-blt.inavisms) + "</inavisms>" +
                                    "<insmsant>" + STRING(tt-consulta-blt.insmsant) + "</insmsant>" +
                                    "<insmsvct>" + STRING(tt-consulta-blt.insmsvct) + "</insmsvct>" +
                                    "<insmspos>" + STRING(tt-consulta-blt.insmspos) + "</insmspos>" +
                                    "<dtvctori>" + STRING(
                                      IF tt-consulta-blt.dtvctori = ? THEN 
                                        tt-consulta-blt.dtvencto 
                                      ELSE 
                                        tt-consulta-blt.dtvctori, "99/99/9999") + "</dtvctori>" + 
                                   "<flgcbdda>" + STRING(IF aux_npc_cip = 1 THEN "S" ELSE "N") + "</flgcbdda>" +
                                   "<vldocmto>" + STRING(tt-consulta-blt.vldocmto)+ "</vldocmto>" +
                                   "<dtmvtatu>" + STRING(tt-consulta-blt.dtmvtatu,"99/99/9999") + "</dtmvtatu>" +
                                   "<flgvenci>" + STRING(tt-consulta-blt.flgvenci) + "</flgvenci>" +                                   
                                   "<vldocmto_boleto>" + STRING(tt-consulta-blt.vldocmto_boleto,"zzzzzzzzz9.99") + "</vldocmto_boleto>" +
                                   "<vlcobrado_boleto>" + STRING(tt-consulta-blt.vlcobrado_boleto,"zzzzzzzzz9.99") + "</vlcobrado_boleto>" +
                                   "<dtvencto_boleto>" + STRING(tt-consulta-blt.dtvencto_boleto,"99/99/9999") + "</dtvencto_boleto>" +
                                   "<linhadigitavel>" + tt-consulta-blt.dslindig + "</linhadigitavel>" + 
                                   "<codigobarras>" + tt-consulta-blt.dscodbar + "</codigobarras>" +
                                   "<dsdespec>" + tt-consulta-blt.dsdespec + "</dsdespec>" +
                                   "<nrborder>" + STRING(tt-consulta-blt.nrborder) + "</nrborder>" +
                                   "<dsdinst1>" + STRING(tt-consulta-blt.dsdinst1) + "</dsdinst1>" +                                   
                                   "<dsdinst2>" + STRING(tt-consulta-blt.dsdinst2) + "</dsdinst2>" +                                   
                                   "<dsdinst3>" + STRING(tt-consulta-blt.dsdinst3) + "</dsdinst3>" +                                   
                                   "<dsdinst4>" + STRING(tt-consulta-blt.dsdinst4) + "</dsdinst4>" +                                   
                                   "<dsdinst5>" + STRING(tt-consulta-blt.dsdinst5) + "</dsdinst5>" +
                                   "<dtbloqueio>" + (IF tt-consulta-blt.dtbloqueio = ? THEN " " ELSE STRING(tt-consulta-blt.dtbloqueio,"99/99/9999")) + "</dtbloqueio>" + 
                                   "<insitcrt>"  + STRING(tt-consulta-blt.insitcrt) + "</insitcrt>" +
                                   "</BOLETO>".
END.

DELETE PROCEDURE h-b1wgen0010.

IF aux_nrdocmto = 0 THEN DO:
    ASSIGN aux_dscritic = "Boleto nao encontrado.".
           xml_dsmsgerr = "<dsmsgerr>" + 
                          aux_dscritic + 
                          "</dsmsgerr>".  
    RETURN "NOK".
END. 
    


CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</DADOS_BOLETOS>".

/* Buscar o e-mail do beneficiário que está enviando os boletos por e-mail */
FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper
                     AND crapcem.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.

IF AVAIL crapcem THEN
    ASSIGN aux_dsdemail_ben = crapcem.dsdemail.

FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                     AND crapass.nrdconta = par_nrdconta
                     NO-LOCK NO-ERROR.
    
/* Buscar o endereco comercial do beneficiario */
FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper
                     AND crapenc.nrdconta = par_nrdconta
                     AND crapenc.tpendass = (IF crapass.inpessoa = 1 THEN 10 ELSE 9)
                     NO-LOCK NO-ERROR.
                     
IF AVAIL crapenc THEN
   ASSIGN aux_dsendere_bnf = TRIM(crapenc.dsendere)
          aux_nrendere_bnf = TRIM(STRING(crapenc.nrendere))
          aux_nrcepend_bnf = STRING(crapenc.nrcepend,"99999999")
          aux_complend_bnf = TRIM(crapenc.complend)
          aux_nmbairro_bnf = TRIM(crapenc.nmbairro)
          aux_nmcidade_bnf = TRIM(crapenc.nmcidade)
          aux_cdufende_bnf = TRIM(crapenc.cdufende).
ELSE          
   ASSIGN aux_dsendere_bnf = 'NAO ENCONTRADO'
          aux_nrendere_bnf = '0'
          aux_nrcepend_bnf = '0'
          aux_complend_bnf = ' '
          aux_nmbairro_bnf = ' '
          aux_nmcidade_bnf = ' '
          aux_cdufende_bnf = ' '.
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DADOS_BENEFICIARIO><nmprimtl>" + 
                               aux_nmprimtl_ben + 
                               "</nmprimtl><nrcpfcgc>" + 
                               STRING(aux_nrcpfcgc_ben) + 
                               "</nrcpfcgc><inpessoa>" + 
                               STRING(aux_inpessoa_ben) + 
                               "</inpessoa><dsdemail>" + 
                               aux_dsdemail_ben + 
                               "</dsdemail>" + 
                               "<dsendere_bnf>" + aux_dsendere_bnf + "</dsendere_bnf>" +
                               "<nrendere_bnf>" + aux_nrendere_bnf + "</nrendere_bnf>" +
                               "<nrcepend_bnf>" + aux_nrcepend_bnf + "</nrcepend_bnf>" +
                               "<complend_bnf>" + aux_complend_bnf + "</complend_bnf>" +
                               "<nmbairro_bnf>" + aux_nmbairro_bnf + "</nmbairro_bnf>" +
                               "<nmcidade_bnf>" + aux_nmcidade_bnf + "</nmcidade_bnf>" +
                               "<cdufende_bnf>" + aux_cdufende_bnf + "</cdufende_bnf>" +
                               "</DADOS_BENEFICIARIO>".


RETURN "OK".

/*............................................................................*/


