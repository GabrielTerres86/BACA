/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank21.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Fevereiro/2008.                   Ultima atualizacao: 16/12/2009
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar cheques do cooperado.
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               16/12/2009 - Implementar nova consulta de cheques (David).
 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0040tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0040 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_qtcheque AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_idconchq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
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

RUN consultar-folhas-cheque IN h-b1wgen0040 
                           (INPUT par_cdcooper,
                            INPUT 90,             /** PAC      **/
                            INPUT 900,            /** Caixa    **/
                            INPUT "996",          /** Operador **/
                            INPUT "INTERNETBANK", /** Tela     **/
                            INPUT 3,              /** Origem   **/ 
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_idconchq,
                            INPUT par_dtiniper,
                            INPUT par_dtfimper,
                            INPUT TRUE,
                            INPUT par_nriniseq,
                            INPUT par_nrregist,
                            INPUT TRUE,
                           OUTPUT aux_qtcheque,
                           OUTPUT TABLE tt-consulta-cheque).
    
DELETE PROCEDURE h-b1wgen0040.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '<CHEQUES qtcheque="' + STRING(aux_qtcheque) + 
                               '">'.

FOR EACH tt-consulta-cheque NO-LOCK:
         
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<CHEQUE><nrcheque>" + 
                                   TRIM(STRING(tt-consulta-cheque.nrcheque,
                                               "zzz,zzz,zz9")) + "-" +
                                   STRING(tt-consulta-cheque.nrdigchq) +
                                   "</nrcheque><nrdctabb>" +
                                   TRIM(STRING(tt-consulta-cheque.nrdctabb,
                                               "zzzz,zzz,9")) + 
                                   "</nrdctabb><vlcheque>" +
                                   TRIM(STRING(tt-consulta-cheque.vlcheque,
                                               "zzz,zzz,zz9.99")) + 
                                   "</vlcheque><dtretchq>" +
                                   STRING(tt-consulta-cheque.dtretchq,
                                          "99/99/9999") +
                                   "</dtretchq><dtliqchq>" +
                           (IF  tt-consulta-cheque.dtliqchq = ?           OR
                                tt-consulta-cheque.dtliqchq = 01/01/0001  THEN
                                ""
                            ELSE
                                STRING(tt-consulta-cheque.dtliqchq,
                                       "99/99/9999")) +
                                   "</dtliqchq><dssitchq>" +
                                   tt-consulta-cheque.dssitchq +
                                   "</dssitchq><cdbanchq>" +
                                   STRING(tt-consulta-cheque.cdbanchq) +
                                   "</cdbanchq><cdagechq>" +
                                   STRING(tt-consulta-cheque.cdagechq) +
                                   "</cdagechq></CHEQUE>".
           
END. /** Fim do FOR EACH tt-consulta-cheque **/
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '</CHEQUES>'.
                          
RETURN "OK".
                
/*............................................................................*/
