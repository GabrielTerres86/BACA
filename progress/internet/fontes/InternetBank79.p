/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank79.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2012.                       Ultima atualizacao: 15/12/2014
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Dados de acesso a rotina de cadastramento de favorecido.
   
   Alteracoes: 03/12/2014 - Ordenar codigo dos bancos no Combo-box (Diego).
   
               15/12/2014 - Melhorias Cadastro de Favorecidos TED
                           (André Santos - SUPERO)
                           
               15/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)
 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }


DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.

DEF VAR aux_flgopspb AS LOGI                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Acesso ao cadastro de favorecidos".

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
                
IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
    DO: 
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).
                
        RETURN "NOK".
    END.

RUN acesso-cadastro-favorecidos IN h-b1wgen0015 
                               (INPUT par_cdcooper,
                                INPUT 90,
                                INPUT 900,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_nrcpfope,
                               OUTPUT aux_dscritic,
                               OUTPUT TABLE tt-bancos-favorecido,
                               OUTPUT TABLE tt-tp-contas,
                               OUTPUT TABLE tt-autorizacao-favorecido).
    
DELETE PROCEDURE h-b1wgen0015.

IF  RETURN-VALUE = "NOK"  THEN
    DO: 
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                              "</dsmsgerr>".
        
        RUN proc_geracao_log (INPUT FALSE).
        
        RETURN "NOK".
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<FAVORECIDO><BANCOS>".

FOR EACH tt-bancos-favorecido NO-LOCK BY tt-bancos-favorecido.cddbanco:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<BANCO><cddbanco>" + 
                                   STRING(tt-bancos-favorecido.cddbanco,"999") +
                                   "</cddbanco><nmresbcc>" + 
                                   tt-bancos-favorecido.nmresbcc +
                                   "</nmresbcc><nrispbif>" + 
                                   STRING(tt-bancos-favorecido.nrispbif,"99999999") +
                                   "</nrispbif>
								   </BANCO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</BANCOS><TIPOS_CONTA>".

FOR EACH tt-tp-contas NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<TIPO><intipcta>" + 
                                   tt-tp-contas.intipcta +
                                   "</intipcta><nmtipcta>" + 
                                   tt-tp-contas.nmtipcta +
                                   "</nmtipcta></TIPO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</TIPOS_CONTA><AUTORIZACAO>".
    
FOR EACH tt-autorizacao-favorecido NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<AUTORIZACAO><nmextcop>" + 
                      tt-autorizacao-favorecido.nmextcop +
                                 "</nmextcop><nmrescop>" +
                      tt-autorizacao-favorecido.nmrescop +
                                 "</nmrescop><cdbcoctl>" +
                      STRING(tt-autorizacao-favorecido.cdbcoctl,
                             "999") +
                                 "</cdbcoctl><cdagectl>" +
                      STRING(tt-autorizacao-favorecido.cdagectl,
                             "9999") +
                                 "</cdagectl><nrdconta>" +
                      TRIM(STRING(tt-autorizacao-favorecido.nrdconta,
                           "zzzz,zzz,9")) +
                                 "</nrdconta><nmextttl>" +
                      tt-autorizacao-favorecido.nmextttl +
                                 "</nmextttl><nmprimtl>" +
                      tt-autorizacao-favorecido.nmprimtl +
                                 "</nmprimtl><nmsegttl>" +
                      tt-autorizacao-favorecido.nmsegttl +
                                 "</nmsegttl><cddbanco>" +
                      STRING(tt-autorizacao-favorecido.cddbanco,
                             "999") +
                                 "</cddbanco><cdageban>" +
                      STRING(tt-autorizacao-favorecido.cdageban,
                             "9999") +
                                 "</cdageban><nrctatrf>" +
                      TRIM(STRING(tt-autorizacao-favorecido.nrctatrf,
                                  "zzzzzzzzzzzzzz,9")) +
                                 "</nrctatrf><nmtitula>" +
                      tt-autorizacao-favorecido.nmtitula +
                                 "</nmtitula><dsprotoc>" +
                      tt-autorizacao-favorecido.dsprotoc +
                                 "</dsprotoc><nrtelfax>" +
                      tt-autorizacao-favorecido.nrtelfax +
                                 "</nrtelfax><dsdemail>" +
                      tt-autorizacao-favorecido.dsdemail +
                                 "</dsdemail><nmopecad>" +
                      tt-autorizacao-favorecido.nmopecad +
                                 "</nmopecad><idsequen>" +
                      STRING(tt-autorizacao-favorecido.idsequen) +
                                 "</idsequen><dttransa>" +
                      STRING(tt-autorizacao-favorecido.dttransa,
                             "99/99/9999") +
                                 "</dttransa><hrtransa>" +
                      STRING(tt-autorizacao-favorecido.hrtransa,
                             "HH:MM:SS") +
                                 "</hrtransa><nmbcoctl>" +
                      tt-autorizacao-favorecido.nmbcoctl +
                                 "</nmbcoctl><nmdbanco>" +
                      tt-autorizacao-favorecido.nmdbanco +
                                 "</nmdbanco><intipcta>" +
                      STRING(tt-autorizacao-favorecido.intipcta) +
                                 "</intipcta><inpessoa>" +
                      STRING(tt-autorizacao-favorecido.inpessoa) +
                                 "</inpessoa><nrcpfcgc>" +
                      STRING(tt-autorizacao-favorecido.nrcpfcgc) +
                                 "</nrcpfcgc><indrecid>" +
                      STRING(tt-autorizacao-favorecido.indrecid) +
                                 "</indrecid><nrispbif>" +
                      STRING(tt-autorizacao-favorecido.nrispbif,
                                     "99999999") +
                               "</nrispbif></AUTORIZACAO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</AUTORIZACAO></FAVORECIDO>".

RETURN "OK".
            
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                         OUTPUT aux_nrdrowid).
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 

/*............................................................................*/

