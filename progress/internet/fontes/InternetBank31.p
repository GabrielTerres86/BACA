/* ............................................................................
   Programa: sistema/internet/fontes/InternetBank31.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2007.                   Ultima atualizacao: 25/02/2014
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Obter dados para cadastrar novo plano de capital na Internet.
   
   Alteracoes: 10/03/2008 - Utilizar include var_ibank.i (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               25/02/2014 - Adicionado atribuicao aos campos cdtipcor e
                            vlcorfix, e removido atribuicao do campo flgplano.
                            (Fabricio)
 
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
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
    
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao31.
RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT 
    SET h-b1wgen0021.
IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DO:
        RUN obtem-novo-plano IN h-b1wgen0021 
                                        (INPUT par_cdcooper,
                                         INPUT 90,             /** PAC      **/
                                         INPUT 900,            /** Caixa    **/
                                         INPUT "996",          /** Operador **/
                                         INPUT "INTERNETBANK", /** Tela     **/
                                         INPUT 3,              /** Origem   **/
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_dtmvtolt,
                                         OUTPUT TABLE tt-horario,
                                         OUTPUT TABLE tt-novo-plano,
                                         OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0021.
        FIND FIRST tt-horario NO-LOCK NO-ERROR.
        IF  AVAILABLE tt-horario  THEN
            DO:
                CREATE xml_operacao31.
                ASSIGN xml_operacao31.dscabini = "<PLANO_CAPITAL>"
                       xml_operacao31.hrinipla = "<hrinipla>" +
                                                 tt-horario.hrinipla +
                                                 "</hrinipla>"
                       xml_operacao31.hrfimpla = "<hrfimpla>" +
                                                 tt-horario.hrfimpla +
                                                 "</hrfimpla>"
                       xml_operacao31.dscabfim = "</PLANO_CAPITAL>".
            END.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  NOT AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = "Nao foi possivel retornar dados " +
                                          "para cadastro de novo plano de " +
                                          "capital.".
                ELSE
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                    
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                 
                RETURN "NOK".
            END.
        FIND FIRST tt-novo-plano NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt-novo-plano  THEN
            DO:
                ASSIGN aux_dscritic = "Nao foi possivel retornar dados para " +
                                      "cadastro de novo plano de capital.".
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                                      
                RETURN "NOK".
            END.
            
        ASSIGN xml_operacao31.despagto = "<despagto>" +
                                         tt-novo-plano.despagto +
                                         "</despagto>"
               xml_operacao31.vlprepla = "<vlprepla>" +
                                         TRIM(STRING(tt-novo-plano.vlprepla,
                                                     "zzz,zzz,zz9.99")) +
                                         "</vlprepla>"
               xml_operacao31.qtpremax = "<qtpremax>" +
                                         STRING(tt-novo-plano.qtpremax) +
                                         "</qtpremax>"
               xml_operacao31.dtdpagto = "<dtdpagto>" +
                                         STRING(tt-novo-plano.dtdpagto,
                                                "99/99/9999") +
                                         "</dtdpagto>"
               xml_operacao31.flcancel = "<flcancel>" +
                                         STRING(tt-novo-plano.flcancel) +
                                         "</flcancel>"
               xml_operacao31.dtlimini = "<dtlimini>" +
                                        (IF  tt-novo-plano.dtlimini <> ?  THEN
                                             STRING(tt-novo-plano.dtlimini,
                                                    "99/99/9999") 
                                         ELSE
                                             "") +
                                         "</dtlimini>"
               xml_operacao31.dtinipla = "<dtinipla>" +
                                         STRING(tt-novo-plano.dtinipla,
                                                "99/99/9999") +
                                         "</dtinipla>"
               xml_operacao31.dtfuturo = "<dtfuturo>" +
                                         STRING(tt-novo-plano.dtfuturo,
                                                "99/99/9999") +
                                         "</dtfuturo>"
               xml_operacao31.cdtipcor = "<cdtipcor>" +
                                         STRING(tt-novo-plano.cdtipcor) +
                                         "</cdtipcor>"
               xml_operacao31.vlcorfix = "<vlcorfix>" +
                                         TRIM(STRING(tt-novo-plano.vlcorfix,
                                                "zz,zz9.99")) +
                                         "</vlcorfix>".
        
        RETURN "OK".
    END.
