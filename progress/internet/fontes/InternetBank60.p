/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank60.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Maio/2009                         Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar cheques em custodia 
   
   Alteracoes: 21/08/2019 - Ajuste para retornar o numero da remessa do cheque. RITM0011937 (Lombardi)
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0040tt.i }

DEF VAR h-b1wgen0040 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_qtcheque AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtlibera AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nriniseq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0040.p PERSISTENT SET h-b1wgen0040.

IF  NOT VALID-HANDLE(h-b1wgen0040)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0040.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN consultar-cheques-custodia IN h-b1wgen0040 
                              (INPUT par_cdcooper,
                               INPUT 90,             /** PAC       **/
                               INPUT 900,            /** Caixa     **/
                               INPUT "996",          /** Operador  **/
                               INPUT "INTERNETBANK", /** Tela      **/
                               INPUT 3,              /** Origem    **/
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtlibera,
                               INPUT TRUE,           /** Paginacao **/
                               INPUT par_nriniseq,
                               INPUT par_nrregist,
                               INPUT TRUE,           /** Logar     **/
                              OUTPUT aux_qtcheque,
                              OUTPUT TABLE tt-cheques-custodia).

DELETE PROCEDURE h-b1wgen0040.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<CUSTODIA qtcheque='" + STRING(aux_qtcheque) +
                               "'>".
        
FOR EACH tt-cheques-custodia NO-LOCK:

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "<CHEQUE><dtlibera>" +
                                   STRING(tt-cheques-custodia.dtlibera,
                                          "99/99/9999") +
                                   "</dtlibera><cdbanchq>" +
                                   STRING(tt-cheques-custodia.cdbanchq) +
                                   "</cdbanchq><cdagechq>" +  
                                   STRING(tt-cheques-custodia.cdagechq) +
                                   "</cdagechq><nrctachq>" +
                                   TRIM(STRING(tt-cheques-custodia.nrctachq,
                                               "zzz,zzz,zzz,9")) +  
                                   "</nrctachq><nrcheque>" +
                                   TRIM(STRING(tt-cheques-custodia.nrcheque,
                                               "zzz,zz9")) +  
                                   "</nrcheque><vlcheque>" +
                                   TRIM(STRING(tt-cheques-custodia.vlcheque,
                                               "zzz,zzz,zz9.99")) +
                                   "</vlcheque><dtdevolu>" +
                                  (IF  tt-cheques-custodia.dtdevolu = ?  THEN
                                       " "
                                   ELSE
                                       STRING(tt-cheques-custodia.dtdevolu,
                                              "99/99/9999")) +
                                   "</dtdevolu><tpdevolu>" +
                                   tt-cheques-custodia.tpdevolu + 
                                   "</tpdevolu><cdopedev>" +
                                   tt-cheques-custodia.cdopedev +
                                   "</cdopedev><nrremret>" +
                                   STRING(tt-cheques-custodia.nrremret) +
                                   "</nrremret></CHEQUE>".
                
END. /** Fim do FOR EACH tt-cheques-custodia **/

ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</CUSTODIA>".
           
RETURN "OK".

/*............................................................................*/
