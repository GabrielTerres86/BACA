
/* .............................................................................
   
   Programa: sistema/internet/fontes/bloqueto2via.p
   Sistema : Internet - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Jorge
   Data    : Setembro/2011                   Ultima Atualizacao: 27/01/2017
   
   Dados referentes ao programa:
   
   Frequencia: esporadica(internet)
   Objetivo  : chama a BO de busca de boleto e retona um XML
      
   Alteracoes: 27/01/2017 - Recuperar os campos flserasa e qtdianeg 
	                        e gravar no objeto boleto (Tiago/Ademir SD601919)

			   11/07/2017 - Inclusão do campo flgcbdda, Prj. 340 - NPC (Jean Michel)
	                        
..............................................................................*/

CREATE WIDGET-POOL.
  
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/internet/includes/b1wnet0001tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

/* parâmetros recebidos pela URL */
DEF VAR par_cdcooper AS INTE                                          NO-UNDO.
DEF VAR par_cpfcgcce AS DECI                                          NO-UNDO.
DEF VAR par_cpfcgcsa AS DECI                                          NO-UNDO.
DEF VAR par_nrnosnum AS DECI                                          NO-UNDO.
DEF VAR par_dsdoccop AS CHAR                                          NO-UNDO.
DEF VAR par_lindigi1 AS DECI                                          NO-UNDO.
DEF VAR par_lindigi2 AS DECI                                          NO-UNDO.
DEF VAR par_lindigi3 AS DECI                                          NO-UNDO.
DEF VAR par_lindigi4 AS DECI                                          NO-UNDO.
DEF VAR par_lindigi5 AS DECI                                          NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                          NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.


/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wnet0001 AS HANDLE                                NO-UNDO.


/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):
    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot:APPEND-CHILD(xField).
    xDoc:CREATE-NODE(xText,"","TEXT").
    xField:APPEND-CHILD(xText).
    xText:NODE-VALUE = STRING(textoCampo).
    RETURN TRUE.
END FUNCTION.

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN par_cdcooper = INT(GET-VALUE("aux_cdcooper"))
       par_cpfcgcce = DECI(GET-VALUE("aux_cpfcgcce"))
       par_cpfcgcsa = DECI(GET-VALUE("aux_cpfcgcsa"))
       par_nrnosnum = DECI(GET-VALUE("aux_nrnosnum"))
       par_dsdoccop = GET-VALUE("aux_dsdoccop")
       par_lindigi1 = DECI(GET-VALUE("aux_lindigi1"))
       par_lindigi2 = DECI(GET-VALUE("aux_lindigi2"))
       par_lindigi3 = DECI(GET-VALUE("aux_lindigi3"))
       par_lindigi4 = DECI(GET-VALUE("aux_lindigi4"))
       par_lindigi5 = DECI(GET-VALUE("aux_lindigi5")).

CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

xDoc:ENCODING = "ISO-8859-1".

/* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
xDoc:APPEND-CHILD( xRoot ).

/* Instancia a BO para executar as procedures */
RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

/* Se BO foi instanciada */
IF  VALID-HANDLE(h-b1wnet0001)  THEN
    DO:
        EMPTY TEMP-TABLE tt-consulta-blt.
        EMPTY TEMP-TABLE tt-erro.

        RUN gerar-2via-boleto IN h-b1wnet0001(INPUT par_cdcooper,
                                              INPUT 90,
                                              INPUT "996",
                                              INPUT par_cpfcgcce,
                                              INPUT par_cpfcgcsa,
                                              INPUT par_nrnosnum,
                                              INPUT par_dsdoccop,
                                              INPUT par_lindigi1,
                                              INPUT par_lindigi2,
                                              INPUT par_lindigi3,
                                              INPUT par_lindigi4,
                                              INPUT par_lindigi5,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-consulta-blt).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel efetuar a consulta.".
    
                criaCampo("DSMSGERR",aux_dscritic).
            END.
        
        FOR EACH tt-consulta-blt NO-LOCK:

            criaCampo("nossonro",tt-consulta-blt.nossonro).
            criaCampo("nmdsacad",tt-consulta-blt.nmdsacad).
            criaCampo("nrinssac",STRING(tt-consulta-blt.nrinssac)).
            criaCampo("dsendsac",tt-consulta-blt.dsendsac).
            criaCampo("nmbaisac",tt-consulta-blt.nmbaisac).
            criaCampo("nmcidsac",tt-consulta-blt.nmcidsac).
            criaCampo("cdufsaca",tt-consulta-blt.cdufsaca).
            criaCampo("nrcepsac",STRING(tt-consulta-blt.nrcepsac,"99999999")).
            criaCampo("nmdavali",tt-consulta-blt.nmdavali).
            criaCampo("nrconven",STRING(tt-consulta-blt.nrcnvcob)).
            criaCampo("nrcnvceb",STRING(tt-consulta-blt.nrcnvceb)).
            criaCampo("nrdctabb",STRING(tt-consulta-blt.nrdctabb)).
            criaCampo("nrcpfcgc",STRING(tt-consulta-blt.nrcpfcgc)).
            criaCampo("nrdocmto",STRING(tt-consulta-blt.nrdocmto)).
            criaCampo("dtmvtolt",STRING(tt-consulta-blt.dtmvtolt,"99/99/9999")).
            criaCampo("dsdinstr",tt-consulta-blt.dsdinstr).        
            criaCampo("dsdoccop",STRING(tt-consulta-blt.dsdoccop)).
            criaCampo("dtvencto",STRING(tt-consulta-blt.dtvencto,"99/99/9999")).
            criaCampo("dtdpagto",(IF  tt-consulta-blt.dtdpagto = ?  THEN " "
                                  ELSE STRING(tt-consulta-blt.dtdpagto,
                                             "99/99/9999"))).
            criaCampo("vltitulo",TRIM(STRING(tt-consulta-blt.vltitulo,
                                             "zzzzzzzzz9.99"))).
            criaCampo("vldpagto",TRIM(STRING(tt-consulta-blt.vldpagto,
                                             "zzzzzzzzz9.99"))).
            criaCampo("cdtpinsc",STRING(tt-consulta-blt.cdtpinsc)).
            criaCampo("inpessoa",STRING(tt-consulta-blt.inpessoa)).
            criaCampo("nmprimtl",tt-consulta-blt.nmprimtl).
            criaCampo("vldescto",TRIM(STRING(tt-consulta-blt.vldescto,
                                             "zzzzzzzzz9.99"))).
            criaCampo("cdmensag",STRING(tt-consulta-blt.cdmensag)).
            criaCampo("complend",tt-consulta-blt.complend).
            criaCampo("idbaiexc",STRING(tt-consulta-blt.idbaiexc)).
            criaCampo("cdsituac",tt-consulta-blt.cdsituac).
            criaCampo("dsinform",tt-consulta-blt.dsinform).
            criaCampo("vlabatim",TRIM(STRING(tt-consulta-blt.vlabatim,
                                             "zzzzzzzzz9.99"))).
            criaCampo("cddespec",STRING(tt-consulta-blt.cddespec)).
            criaCampo("dtdocmto",STRING(tt-consulta-blt.dtdocmto,"99/99/9999")).
            criaCampo("dsdpagto",tt-consulta-blt.dsdpagto).
            criaCampo("cdbanpag",STRING(tt-consulta-blt.cdbanpag)).
            criaCampo("cdagepag",STRING(tt-consulta-blt.cdagepag)).
            criaCampo("dssituac",tt-consulta-blt.dssituac).
            criaCampo("flgdesco",tt-consulta-blt.flgdesco).
            criaCampo("dtelimin",(IF  tt-consulta-blt.dtelimin = ?  THEN " "
                                  ELSE STRING(tt-consulta-blt.dtelimin,
                                             "99/99/9999"))).
            criaCampo("cdcartei",STRING(tt-consulta-blt.cdcartei)).
            criaCampo("cdbandoc",STRING(tt-consulta-blt.cdbandoc)).
            criaCampo("flgregis",(IF TRIM(tt-consulta-blt.flgregis) = "S"  THEN
                                  "1" ELSE "2")).
            criaCampo("nrnosnum",tt-consulta-blt.nrnosnum).
            criaCampo("agencidv",tt-consulta-blt.agencidv).
            criaCampo("nrvarcar",STRING(tt-consulta-blt.nrvarcar)).
            criaCampo("flgaceit",TRIM(tt-consulta-blt.flgaceit)).
            criaCampo("tpjurmor",STRING(tt-consulta-blt.tpjurmor)).
            criaCampo("vljurdia",TRIM(STRING(tt-consulta-blt.vlrjuros,
                                             "zzzzzzzzz9.99"))).
            criaCampo("tpdmulta",STRING(tt-consulta-blt.tpdmulta)).
            criaCampo("vlrmulta",TRIM(STRING(tt-consulta-blt.vlrmulta,
                                             "zzzzzzzzz9.99"))).
            criaCampo("flgdprot",(IF tt-consulta-blt.flgdprot = TRUE THEN 
                                  "S" ELSE "N")).
            criaCampo("qtdiaprt",STRING(tt-consulta-blt.qtdiaprt, "99")).
            criaCampo("indiaprt",STRING(tt-consulta-blt.indiaprt, "9")).
            criaCampo("insitpro",STRING(tt-consulta-blt.insitpro, "9")).
            criaCampo("cdtpinav",STRING(tt-consulta-blt.cdtpinav, "9")).
            criaCampo("nrinsava",STRING(tt-consulta-blt.nrinsava)).
            criaCampo("nrdconta",STRING(tt-consulta-blt.nrdconta)).
			            
            criaCampo("vldocmto",TRIM(STRING(tt-consulta-blt.vldocmto,
                                             "zzzzzzzzz9.99"))).
            criaCampo("vlmormul",TRIM(STRING(tt-consulta-blt.vlmormul,
                                             "zzzzzzzzz9.99"))).
            criaCampo("dtvctori",(IF  tt-consulta-blt.dtvctori = ?  THEN " "
                                  ELSE STRING(tt-consulta-blt.dtvctori,
                                             "99/99/9999"))).
            criaCampo("flserasa",(IF tt-consulta-blt.flserasa = TRUE THEN
                                  "S" ELSE "N")).
			criaCampo("qtdianeg",STRING(tt-consulta-blt.qtdianeg, "99")).											  
			criaCampo("flgcbdda",STRING(tt-consulta-blt.flgcbdda)).								 
			
        END. /* fim for each tt-consulta-blt */

    END. /* IF VALID-HANDLE(h-b1wnet0001) */
ELSE
    DO:
        criaCampo("DSMSGERR","BO b1wnet0001 não inicializada").
        LEAVE.
    END.

DELETE PROCEDURE  h-b1wnet0001 NO-ERROR.

xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.


  
/* .......................................................................... */

