/* ............................................................................
   Programa: sistema/internet/fontes/InternetBank34.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2007.                   Ultima atualizacao: 10/03/2008
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Imprimir protocolo do novo plano de capital na Internet.
   
   Alteracoes: 10/03/2008 - Utilizar include var_ibank.i (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
 
 ............................................................................ */
 
create widget-pool.
 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao34.
RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT 
    SET h-b1wgen0021.
IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DO: 
        RUN imprimir_protocolo IN h-b1wgen0021 
                                         (INPUT par_cdcooper,
                                          INPUT 90,             /** PAC      **/
                                          INPUT 900,            /** Caixa    **/
                                          INPUT "996",          /** Operador **/
                                          INPUT "INTERNETBANK", /** Tela     **/
                                          INPUT 3,              /** Origem   **/
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-protocolo).
        DELETE PROCEDURE h-b1wgen0021.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  NOT AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = "Nao foi possivel carregar o " +
                                          "protocolo do novo plano de capital.".
                ELSE
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                    
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                 
                RETURN "NOK".
            END.
        FIND FIRST tt-protocolo NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-protocolo  THEN
            DO:
                CREATE xml_operacao34.
                ASSIGN xml_operacao34.dscabini = "<DADOS>"
                       xml_operacao34.cdtippto = "<cdtippro>" +
                                                STRING(tt-protocolo.cdtippro) +
                                                 "</cdtippro>"
                       xml_operacao34.dtmvtolt = "<dtmvtolt>" + 
                                   STRING(tt-protocolo.dtmvtolt,"99/99/9999") +
                                                 "</dtmvtolt>"
                       xml_operacao34.dttransa = "<dttransa>" + 
                                   STRING(tt-protocolo.dttransa,"99/99/9999") +
                                                 "</dttransa>"
                       xml_operacao34.hrautent = "<hrautent>" +
                                     STRING(tt-protocolo.hrautent,"HH:MM:SS") +
                                                 "</hrautent>"
                       xml_operacao34.vldocmto = "<vldocmto>" +
                         TRIM(STRING(tt-protocolo.vldocmto,"zzz,zzz,zz9.99")) +
                                                 "</vldocmto>"
                       xml_operacao34.nrdocmto = "<nrdocmto>" +
                               TRIM(STRING(tt-protocolo.nrdocmto,"zzzzzzz9")) +
                                                 "</nrdocmto>"
                       xml_operacao34.dsinfor1 = "<dsinfor1>" +
                                               TRIM(tt-protocolo.dsinform[1]) +
                                                 "</dsinfor1>"
                       xml_operacao34.dsinfor2 = "<dsinfor2>" +
                                               TRIM(tt-protocolo.dsinform[2]) +
                                                 "</dsinfor2>"
                       xml_operacao34.dsinfor3 = "<dsinfor3>" +
                                               TRIM(tt-protocolo.dsinform[3]) +
                                                 "</dsinfor3>"
                       xml_operacao34.dsprotoc = "<dsprotoc>" + 
                                                 TRIM(tt-protocolo.dsprotoc) +
                                                 "</dsprotoc>"
                       xml_operacao34.dscabfim = "</DADOS>".
            END.
        RETURN "OK".
    END.
