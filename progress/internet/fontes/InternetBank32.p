/* ............................................................................
   Programa: sistema/internet/fontes/InternetBank32.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2007.                   Ultima atualizacao: 25/02/2014
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validar e cadastrar novo plano de capital na Internet.
   
   Alteracoes: 
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               25/02/2014 - Adicionado chamada das procedures 
                            valida-dados-alteracao-plano e altera-plano.
                            (Fabricio)
 
 ............................................................................ */
 
create widget-pool.
 
    
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_vlprepla AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdtipcor AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlcorfix AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_flgpagto AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_qtpremax AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtdpagto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_flcadast AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flcancel AS LOGI                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT 
    SET h-b1wgen0021.
IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DO: 
        IF  par_flcadast = 1 AND NOT par_flcancel  THEN
            RUN valida-dados-plano IN h-b1wgen0021 
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/ 
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT par_vlprepla,
                                        INPUT par_cdtipcor,
                                        INPUT par_vlcorfix,
                                        INPUT par_flgpagto,
                                        INPUT par_qtpremax,
                                        INPUT par_dtdpagto,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro).
        ELSE
        IF par_flcadast = 2 AND NOT par_flcancel THEN
            RUN cria-plano IN h-b1wgen0021 
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/ 
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT par_vlprepla,
                                        INPUT par_cdtipcor,
                                        INPUT par_vlcorfix,
                                        INPUT par_flgpagto,
                                        INPUT par_qtpremax,
                                        INPUT par_dtdpagto,
                                        INPUT 0,
                                       OUTPUT TABLE tt-erro).
        ELSE
        IF par_flcadast = 1 AND par_flcancel THEN
            RUN valida-dados-alteracao-plano IN h-b1wgen0021 
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/ 
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT par_vlprepla,
                                        INPUT par_cdtipcor,
                                        INPUT par_vlcorfix,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro).
        ELSE
        IF par_flcadast = 2 AND par_flcancel THEN
            RUN altera-plano IN h-b1wgen0021 
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/ 
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT par_vlprepla,
                                        INPUT par_cdtipcor,
                                        INPUT par_vlcorfix,
                                        INPUT par_flgpagto,
                                        INPUT par_qtpremax,
                                        INPUT par_dtdpagto,
                                        INPUT 0,
                                       OUTPUT TABLE tt-erro).
        ELSE
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                      "Parametro de cadastro invalido.".
                                      "</dsmsgerr>".
                 
                RETURN "NOK".
            END.
        DELETE PROCEDURE h-b1wgen0021.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  NOT AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = "Nao foi possivel cadastrar o novo" +
                                          " plano de capital.".
                ELSE
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                    
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                 
                RETURN "NOK".
            END.
        RETURN "OK".
    END.
