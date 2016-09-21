/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank55.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obtem Dados para Inclusao de Informativo 
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0037tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0037 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_cdgrprel AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdrelato AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cddfrenv AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0037.p PERSISTENT SET h-b1wgen0037.
                
IF  NOT VALID-HANDLE(h-b1wgen0037)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0037.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN obtem-grupos-informativos IN h-b1wgen0037 
                                      (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT TRUE,           /** Logar    **/
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-grupo-informativo).

IF  RETURN-VALUE = "OK"  THEN
    DO:
        IF  par_cdgrprel = 0  THEN
            DO:
                FIND FIRST tt-grupo-informativo NO-LOCK NO-ERROR.
                
                ASSIGN par_cdgrprel = tt-grupo-informativo.cdgrprel.
            END.

        RUN obtem-informativos IN h-b1wgen0037 
                                      (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT par_cdgrprel,
                                       INPUT TRUE,           /** Logar    **/
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-informativos).
    
        IF  RETURN-VALUE = "OK"  THEN
            DO:
                IF  par_cdrelato = 0  THEN
                    DO:
                        FIND FIRST tt-informativos NO-LOCK NO-ERROR.
                
                        ASSIGN par_cdrelato = tt-informativos.cdrelato.
                    END.

                RUN obtem-canais-envio IN h-b1wgen0037 
                                      (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT par_cdrelato,
                                       INPUT TRUE,           /** Logar    **/
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-canais-envio).
                                      
                IF  RETURN-VALUE = "OK" AND par_cddfrenv > 0  THEN 
                    RUN obtem-dados-envio-inclusao IN h-b1wgen0037 
                                      (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT par_cdrelato,
                                       INPUT par_cddfrenv,
                                       INPUT TRUE,           /** Logar    **/
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-periodo-envio,
                                      OUTPUT TABLE tt-destino-envio).  
            END.
    END.
    
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0037.
        
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel obter dados para informativo.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

FOR EACH tt-grupo-informativo NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<GRUPO><cdgrprel>" +
                                   STRING(tt-grupo-informativo.cdgrprel) +
                                   "</cdgrprel><nmgrprel>" +
                                   tt-grupo-informativo.nmgrprel +
                                   "</nmgrprel><dsgrprel>" +
                                   tt-grupo-informativo.dsgrprel +
                                   "</dsgrprel><INFORMATIVOS>".
                                   
    FOR EACH tt-informativos WHERE 
             tt-informativos.cdgrprel = tt-grupo-informativo.cdgrprel NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<INFORMATIVO><cdprogra>" +
                                       STRING(tt-informativos.cdprogra) +
                                       "</cdprogra><cdrelato>" +
                                       STRING(tt-informativos.cdrelato) +
                                       "</cdrelato><nmrelato>" +
                                       tt-informativos.nmrelato +
                                       "</nmrelato><dsrelato>" +
                                       tt-informativos.dsrelato +
                                       "</dsrelato><CANAIS_ENVIO>".

        FOR EACH tt-canais-envio WHERE
                 tt-canais-envio.cdrelato = tt-informativos.cdrelato NO-LOCK:

            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<CANAL><cddfrenv>" +
                                           STRING(tt-canais-envio.cddfrenv) +
                                           "</cddfrenv><dsdfrenv>" +
                                           tt-canais-envio.dsdfrenv +
                                           "</dsdfrenv><PERIODOS_ENVIO>".

            IF  par_cddfrenv = 0  THEN
                DO:
                    RUN obtem-dados-envio-inclusao IN h-b1wgen0037 
                                      (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT par_cdrelato,
                                       INPUT tt-canais-envio.cddfrenv,
                                       INPUT TRUE,           /** Logar    **/
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-periodo-envio,
                                      OUTPUT TABLE tt-destino-envio).
                END.
    
            FOR EACH tt-periodo-envio WHERE 
                     tt-periodo-envio.cdrelato = tt-canais-envio.cdrelato AND
                     tt-periodo-envio.cddfrenv = tt-canais-envio.cddfrenv
                     NO-LOCK:

                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<PERIODO><cdperiod>" +
                                             STRING(tt-periodo-envio.cdperiod) +
                                               "</cdperiod><dsperiod>" +
                                               tt-periodo-envio.dsperiod +
                                               "</dsperiod></PERIODO>".

            END. /** Fim do FOR EACH tt-periodo-envio **/
        
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "</PERIODOS_ENVIO>" +
                                           "<DESTINOS_ENVIO>". 
 
            FOR EACH tt-destino-envio WHERE
                     tt-destino-envio.cdrelato = tt-canais-envio.cdrelato AND
                     tt-destino-envio.cddfrenv = tt-canais-envio.cddfrenv
                     NO-LOCK:

                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<DESTINO><cddestin>" +
                                             STRING(tt-destino-envio.cddestin) +
                                               "</cddestin><dsdestin>" +
                                               tt-destino-envio.dsdestin +
                                               "</dsdestin></DESTINO>".

            END. /** Fim do FOR EACH tt-destino-envio **/

            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "</DESTINOS_ENVIO></CANAL>".

        END. /** Fim do FOR EACH tt-canais-envio **/

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "</CANAIS_ENVIO></INFORMATIVO>".

    END. /** Fim do FOR EACH tt-informativos **/                               

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</INFORMATIVOS></GRUPO>".

END. /** Fim do FOR EACH tt-grupo-informativo **/

DELETE PROCEDURE h-b1wgen0037.

RETURN "OK".

/*............................................................................*/
