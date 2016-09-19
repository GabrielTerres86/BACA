/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank132.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Fevereiro/2015                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Detalhes de descontos de titulos
   
   Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0018tt.i }

DEF VAR h-b1wgen0018 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_vllimite AS DECI                                           NO-UNDO.
DEF VAR aux_vldsctit AS DECI                                           NO-UNDO.

DEF VAR aux_qttitulos AS INTE                                           NO-UNDO.

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

IF  NOT VALID-HANDLE(h-b1wgen0018)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0018.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN busca_limite_tit_bordero IN h-b1wgen0018
                            (INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT 90,             /** PAC       **/
                             INPUT 900,            /** Caixa     **/
                             INPUT "996",          /** Operador  **/
                             INPUT "INTERNETBANK", /** Tela      **/
                             INPUT 3,              /** Origem    **/
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             OUTPUT aux_vllimite,
                             OUTPUT aux_vldsctit).

DELETE PROCEDURE h-b1wgen0018.


RUN sistema/generico/procedures/b1wgen0018.p PERSISTENT SET h-b1wgen0018.

IF  NOT VALID-HANDLE(h-b1wgen0018)  THEN DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0018.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

RUN detalhe_desconto_titulos IN h-b1wgen0018
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
                             OUTPUT aux_qttitulos,
                             OUTPUT TABLE tt-detalhes-titulo).

DELETE PROCEDURE h-b1wgen0018.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DESCONTO qttitulos='" + STRING(aux_qttitulos) +
                               "' vllimite='" +
                               TRIM(STRING(aux_vllimite,"zzz,zzz,zzz,zz9.99")) +
                               "' vldsctit='" +
                               TRIM(STRING(aux_vldsctit,"zzz,zzz,zzz,zz9.99")) + "'>".

FOR EACH tt-detalhes-titulo NO-LOCK:

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "<CHEQUE><dtlibbdt>" +
                                   STRING(tt-detalhes-titulo.dtlibbdt,
                                          "99/99/9999") +
                                   "</dtlibbdt><dtvencto>" +
                                  (IF  tt-detalhes-titulo.dtvencto = ?  THEN
                                       " "
                                   ELSE
                                       STRING(tt-detalhes-titulo.dtvencto,
                                              "99/99/9999")) +
                                   "</dtvencto><nrcnvcob>" +  
                                   STRING(tt-detalhes-titulo.nrcnvcob,
                                          "zzzzzzz,zz9") +
                                   "</nrcnvcob><tpcobran>" +
                                   STRING(tt-detalhes-titulo.tpcobran) +
                                   "</tpcobran><cdbandoc>" +
                                   STRING(tt-detalhes-titulo.cdbandoc) +
                                   "</cdbandoc><nrdocmto>" +
                                   TRIM(STRING(tt-detalhes-titulo.nrdocmto,
                                               "zzzzzzz,zz9")) +  
                                   "</nrdocmto><vltitulo>" +
                                   TRIM(STRING(tt-detalhes-titulo.vltitulo,
                                               "zzz,zzz,zz9.99")) +  
                                   "</vltitulo><vlliquid>" +
                                   TRIM(STRING(tt-detalhes-titulo.vlliquid,
                                               "zzz,zzz,zz9.99")) +
                                   "</vlliquid><dtresgat>" +
                                  (IF  tt-detalhes-titulo.dtresgat = ?  THEN
                                       " "
                                   ELSE
                                       STRING(tt-detalhes-titulo.dtresgat,
                                              "99/99/9999")) +
                                   "</dtresgat><vlliqres>" +
                                   TRIM(STRING(tt-detalhes-titulo.vlliqres,
                                               "zzz,zzz,zz9.99")) +  
                                   "</vlliqres></CHEQUE>".
                
END. /** Fim do FOR EACH tt-detalhes-titulo **/

ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</DESCONTO>".
           
RETURN "OK".

/*............................................................................*/

