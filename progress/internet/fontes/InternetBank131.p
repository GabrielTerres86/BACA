/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank131.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Fevereiro/2015                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Detalhes de desconto de Cheques
   
   Alteracoes:
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0018tt.i }

DEF VAR h-b1wgen0018 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_vllimite AS DECI                                           NO-UNDO.
DEF VAR aux_vlutiliz AS DECI                                           NO-UNDO.

DEF VAR aux_qtcheque AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrborder AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nriniseq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INTE                                  NO-UNDO.

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

IF  NOT VALID-HANDLE(h-b1wgen0018)  THEN DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0018.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

RUN detalhe_desconto_cheques IN h-b1wgen0018
                            (INPUT par_cdcooper,
                             INPUT 90,             /** PAC       **/
                             INPUT 900,            /** Caixa     **/
                             INPUT "996",          /** Operador  **/
                             INPUT "INTERNETBANK", /** Tela      **/
                             INPUT 3,              /** Origem    **/
                             INPUT par_nrdconta,
                             INPUT par_nrborder,
                             INPUT par_idseqttl,
                             INPUT TRUE,           /** Paginacao **/
                             INPUT par_nriniseq,
                             INPUT par_nrregist,
                             OUTPUT aux_qtcheque,
                             OUTPUT TABLE tt-detalhes-bordero).

DELETE PROCEDURE h-b1wgen0018.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DESCONTO qtcheque='" + STRING(aux_qtcheque) +
                               "' vllimite='" +
                               TRIM(STRING(aux_vllimite,"zzz,zzz,zzz,zz9.99")) +
                               "' vlutiliz='" +
                               TRIM(STRING(aux_vlutiliz,"zzz,zzz,zzz,zz9.99")) + "'>".

FOR EACH tt-detalhes-bordero NO-LOCK:

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "<CHEQUE><dtlibera>" +
                                   STRING(tt-detalhes-bordero.dtlibera,
                                          "99/99/9999") +
                                   "</dtlibera><cdbanchq>" +
                                   STRING(tt-detalhes-bordero.cdbanchq) +
                                   "</cdbanchq><cdagechq>" +  
                                   STRING(tt-detalhes-bordero.cdagechq) +
                                   "</cdagechq><nrctachq>" +
                                   TRIM(STRING(tt-detalhes-bordero.nrctachq,
                                               "zzz,zzz,zzz,9")) +  
                                   "</nrctachq><nrcheque>" +
                                   TRIM(STRING(tt-detalhes-bordero.nrcheque,
                                               "zzz,zz9")) +  
                                   "</nrcheque><vlcheque>" +
                                   TRIM(STRING(tt-detalhes-bordero.vlcheque,
                                               "zzz,zzz,zz9.99")) +
                                   "</vlcheque><dtdevolu>" +
                                  (IF  tt-detalhes-bordero.dtdevolu = ?  THEN
                                       " "
                                   ELSE
                                       STRING(tt-detalhes-bordero.dtdevolu,
                                              "99/99/9999")) +
                                   "</dtdevolu></CHEQUE>".
                
END. /** Fim do FOR EACH tt-detalhes-bordero **/

ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</DESCONTO>".
           
RETURN "OK".

/*............................................................................*/
