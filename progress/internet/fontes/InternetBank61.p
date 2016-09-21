/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank61.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2009                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Resumo de cheques em custodia 
   
   Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0040tt.i }

DEF VAR h-b1wgen0040 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0040.p PERSISTENT SET h-b1wgen0040.

IF  NOT VALID-HANDLE(h-b1wgen0040)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0040.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN resumo-cheques-custodia IN h-b1wgen0040 
                              (INPUT par_cdcooper,
                               INPUT 90,             /** PAC       **/
                               INPUT 900,            /** Caixa     **/
                               INPUT "996",          /** Operador  **/
                               INPUT "INTERNETBANK", /** Tela      **/
                               INPUT 3,              /** Origem    **/
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtiniper,
                               INPUT par_dtfimper,
                               INPUT TRUE,           /** Logar     **/
                              OUTPUT TABLE tt-resumo-custodia).

DELETE PROCEDURE h-b1wgen0040.

FIND tt-resumo-custodia WHERE tt-resumo-custodia.dtlibera = ? NO-LOCK NO-ERROR.

IF  NOT AVAILABLE tt-resumo-custodia  THEN
    DO:
        ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<CUSTODIA qtcheque='" + 
                               TRIM(STRING(tt-resumo-custodia.qtcheque,
                                           "zzz,zzz,zzz,zz9")) +
                               "' vlcheque='" +
                               TRIM(STRING(tt-resumo-custodia.vlcheque,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "'>".
        
FOR EACH tt-resumo-custodia WHERE tt-resumo-custodia.dtlibera <> ? 
                                  NO-LOCK BY tt-resumo-custodia.dtlibera:

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "<RESUMO><dtlibera>" +
                                   STRING(tt-resumo-custodia.dtlibera,
                                          "99/99/9999") +
                                   "</dtlibera><qtcheque>" +
                                   TRIM(STRING(tt-resumo-custodia.qtcheque,
                                               "zzz,zzz,zzz,zz9")) +  
                                   "</qtcheque><vlcheque>" +
                                   TRIM(STRING(tt-resumo-custodia.vlcheque,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlcheque></RESUMO>".
                
END. /** Fim do FOR EACH tt-cheques-custodia **/

ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</CUSTODIA>".
           
RETURN "OK".

/*............................................................................*/
