/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank130.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Fevereiro/2015                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Resumo de desconto de titulos
   
   Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0018tt.i }

DEF VAR h-b1wgen0018 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_vllimite AS DECI                                           NO-UNDO.
DEF VAR aux_vldsctit AS DECI                                           NO-UNDO.

DEF VAR aux_qtdtotal AS INTE                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.
DEF VAR aux_vlrtotlq AS DECI                                           NO-UNDO.

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

IF  NOT VALID-HANDLE(h-b1wgen0018)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0018.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

RUN consulta_desconto_titulos IN h-b1wgen0018
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
                              OUTPUT TABLE tt-titulo-bordero).

DELETE PROCEDURE h-b1wgen0018.

FIND FIRST tt-titulo-bordero NO-LOCK NO-ERROR.

CREATE xml_operacao.

IF  NOT AVAILABLE tt-titulo-bordero  THEN DO:
    ASSIGN xml_operacao.dslinxml = "<CUSTODIA qttitulo='" + 
                               TRIM(STRING(0,
                                           "zzz,zzz,zzz,zz9")) +
                               "' vltitulo='" +
                               TRIM(STRING(0,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "' vlliquid='" +
                               TRIM(STRING(0,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "' vllimite='" +
                               TRIM(STRING(aux_vllimite,"zzz,zzz,zzz,zz9.99")) +
                               "' vldsctit='" +
                               TRIM(STRING(aux_vldsctit,"zzz,zzz,zzz,zz9.99")) + "'>".
            xml_operacao.dslinxml = xml_operacao.dslinxml + "</CUSTODIA>".

    RETURN "OK".
END.

FOR EACH tt-titulo-bordero NO-LOCK:
    ASSIGN aux_qtdtotal = aux_qtdtotal + tt-titulo-bordero.qttitulo
           aux_vlrtotal = aux_vlrtotal + tt-titulo-bordero.vltitulo
           aux_vlrtotlq = aux_vlrtotlq + tt-titulo-bordero.vlliquid.
END.

ASSIGN xml_operacao.dslinxml = "<DESCONTO qttitulo='" + 
                               TRIM(STRING(aux_qtdtotal,
                                           "zzz,zzz,zzz,zz9")) +
                               "' vltitulo='" +
                               TRIM(STRING(aux_vlrtotal,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "' vlliquid='" +
                               TRIM(STRING(aux_vlrtotlq,
                                           "zzz,zzz,zzz,zz9.99")) +
                               "' vllimite='" +
                               TRIM(STRING(aux_vllimite,"zzz,zzz,zzz,zz9.99")) +
                               "' vldsctit='" +
                               TRIM(STRING(aux_vldsctit,"zzz,zzz,zzz,zz9.99")) + "'>".

FOR EACH tt-titulo-bordero NO-LOCK BY tt-titulo-bordero.dtmvtolt DESC
                                   BY tt-titulo-bordero.nrborder:

    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                   "<RESUMO><dtmvtolt>" +
                                   STRING(tt-titulo-bordero.dtmvtolt,
                                          "99/99/9999") +
                                   "</dtmvtolt><nrborder>" +
                                   TRIM(STRING(tt-titulo-bordero.nrborder,
                                               "zzz,zzz,zzz,zz9")) +
                                   "</nrborder><qttitulo>" +
                                   TRIM(STRING(tt-titulo-bordero.qttitulo,
                                               "zzz,zzz,zzz,zz9")) +  
                                   "</qttitulo><vltitulo>" +
                                   TRIM(STRING(tt-titulo-bordero.vltitulo,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vltitulo><vlliquid>" +
                                   TRIM(STRING(tt-titulo-bordero.vlliquid,
                                               "zzz,zzz,zzz,zz9.99")) +
                                   "</vlliquid></RESUMO>".

END. /** Fim do FOR EACH tt-cheques-custodia **/

ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</DESCONTO>".

RETURN "OK".

/*............................................................................*/


