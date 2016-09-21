/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank129.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Fevereiro/2009                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Resumo de desconto de cheques 
   
   Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0018tt.i }

DEF VAR h-b1wgen0018 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_vllimite AS DECI                                           NO-UNDO.
DEF VAR aux_vlutiliz AS DECI                                           NO-UNDO.

DEF VAR aux_qtdtotal AS INTE                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_flgregis AS LOGICAL                               NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0018.p PERSISTENT SET h-b1wgen0018.

IF  NOT VALID-HANDLE(h-b1wgen0018)  THEN DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0018.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

RUN busca_limite_chq_bordero IN h-b1wgen0018
                            (INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT 90,
                             INPUT 900,
                             INPUT "996",
                             INPUT "INTERNETBANK",
                             INPUT 3,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             OUTPUT aux_vllimite,
                             OUTPUT aux_vlutiliz).

DELETE PROCEDURE h-b1wgen0018.

RUN sistema/generico/procedures/b1wgen0018.p PERSISTENT SET h-b1wgen0018.

IF  NOT VALID-HANDLE(h-b1wgen0018)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0018.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN consulta_desconto_cheques IN h-b1wgen0018
                             (INPUT par_cdcooper,
                              INPUT par_dtmvtolt,
                              INPUT 90,             /** PAC       **/
                              INPUT 900,            /** Caixa     **/
                              INPUT "996",          /** Operador  **/
                              INPUT "INTERNETBANK", /** Tela      **/
                              INPUT 3,              /** Origem    **/
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_dtiniper,
                              INPUT par_dtfimper,
                              INPUT par_flgregis,
                              OUTPUT TABLE tt-resumo-bordero).

DELETE PROCEDURE h-b1wgen0018.

FIND FIRST tt-resumo-bordero NO-LOCK NO-ERROR.

CREATE xml_operacao.

IF  NOT AVAILABLE tt-resumo-bordero  THEN DO:
    ASSIGN xml_operacao.dslinxml = "<DESCONTO qtcheque='" +
                                    TRIM(STRING(0,"zzz,zzz,zzz,zz9")) +
                                    "' vlcheque='" +
                                    TRIM(STRING(0,"zzz,zzz,zzz,zz9.99")) +
                                    "' vllimite='" +
                                    TRIM(STRING(aux_vllimite,"zzz,zzz,zzz,zz9.99")) +
                                    "' vlutiliz='" +
                                    TRIM(STRING(aux_vlutiliz,"zzz,zzz,zzz,zz9.99")) + "'>"
           xml_operacao.dslinxml = xml_operacao.dslinxml + "</DESCONTO>".

    RETURN "OK".
END.
   
FOR EACH tt-resumo-bordero NO-LOCK:
    ASSIGN aux_qtdtotal = aux_qtdtotal + tt-resumo-bordero.qtcheque
           aux_vlrtotal = aux_vlrtotal + tt-resumo-bordero.vlcheque.
END.

ASSIGN xml_operacao.dslinxml = "<DESCONTO qtcheque='" + 
                               TRIM(STRING(aux_qtdtotal,
                                           "zzz,zzz,zzz,zz9")) +
                               "' vlcheque='" +
                               TRIM(STRING(aux_vlrtotal,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "' vllimite='" +
                               TRIM(STRING(aux_vllimite,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "' vlutiliz='" +
                               TRIM(STRING(aux_vlutiliz,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "'>".

FOR EACH tt-resumo-bordero NO-LOCK BY tt-resumo-bordero.dtmvtolt DESC
                                   BY tt-resumo-bordero.nrborder:

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "<RESUMO><dtlibera>" +
                                   STRING(tt-resumo-bordero.dtmvtolt,
                                          "99/99/9999") +
                                   "</dtlibera><nrborder>" +
                                   TRIM(STRING(tt-resumo-bordero.nrborder,
                                               "zzz,zzz,zzz,zz9")) +
                                   "</nrborder><qtcheque>" +
                                   TRIM(STRING(tt-resumo-bordero.qtcheque,
                                               "zzz,zzz,zzz,zz9")) +  
                                   "</qtcheque><vlcheque>" +
                                   TRIM(STRING(tt-resumo-bordero.vlcheque,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlcheque></RESUMO>".
                
END. /** Fim do FOR EACH tt-cheques-custodia **/

ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</DESCONTO>".
           
RETURN "OK".

/*............................................................................*/

