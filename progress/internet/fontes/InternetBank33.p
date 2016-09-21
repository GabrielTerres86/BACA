/* ............................................................................
   Programa: sistema/internet/fontes/InternetBank33.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2007.                   Ultima atualizacao:   /  /
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Excluir novo plano de capital na Internet.
   
   Alteracoes: 
   
               03/11/2008 - Inclusao widget-pool (martin)
 
 ............................................................................ */
 
create widget-pool.
 
    
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT 
    SET h-b1wgen0021.
IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DO: 
        RUN exclui-plano IN h-b1wgen0021 (INPUT par_cdcooper,
                                          INPUT 90,             /** PAC      **/
                                          INPUT 900,            /** Caixa    **/
                                          INPUT "996",          /** Operador **/
                                          INPUT "INTERNETBANK", /** Tela     **/
                                          INPUT 3,              /** Origem   **/
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0021.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  NOT AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = "Nao foi possivel excluir o novo" +
                                          " plano de capital.".
                ELSE
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                    
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                 
                RETURN "NOK".
            END.
        RETURN "OK".
    END.
