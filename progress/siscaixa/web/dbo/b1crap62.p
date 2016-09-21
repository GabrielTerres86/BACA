/*-----------------------------------------------------------------------------

    b1crap62.p - OPERAÇÕES DE RECEBIMENTO DE SMS DE DÉBITO AUTOMÁTICO [PROJ320]
    
    Alteracoes:
                
------------------------------------------------------------------------------*/
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0092tt.i }

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

DEF VAR h-b1wgen0092 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0025 AS HANDLE                                      NO-UNDO.

PROCEDURE opera-telefone-sms-debaut:

    DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa   AS DECI               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cddopcao   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS DECI               NO-UNDO.   
    DEF INPUT  PARAM par_flgacsms   AS LOGI               NO-UNDO.   
    DEF  INPUT-OUTPUT PARAM par_nrdddtfc AS DECI          NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_nrtelefo AS DECI          NO-UNDO.
    DEF OUTPUT PARAM par_dsmsgsms   AS CHAR               NO-UNDO.    
    DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.
                                                          
    DEF VAR aux_nmdcampo            AS CHAR               NO-UNDO.
    DEF VAR aux_flgerlog            AS LOGI               NO-UNDO.
                                                          
    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    IF  par_cddopcao <> "C" THEN
        ASSIGN aux_flgerlog = TRUE.
    ELSE 
        ASSIGN aux_flgerlog = FALSE.
            
    IF  NOT VALID-HANDLE(h-b1wgen0092) THEN
        RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN sms-cooperado-debaut IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                              INPUT par_cdagenci,     /* par_cdagenci */
                                              INPUT par_nrdcaixa,     /* par_nrdcaixa */
                                              INPUT par_cdoperad,     /* par_cdoperad */
                                              INPUT "CRAP062",        /* par_nmdatela */
                                              INPUT 2,                /* par_idorigem */
                                              INPUT par_cddopcao,     /* par_cddopcao */
                                              INPUT par_nrdconta,
                                              INPUT 1,                /* par_idseqttl */
                                              INPUT aux_flgerlog,     /* par_flgerlog */
                                              INPUT crapdat.dtmvtolt,
                                              INPUT par_flgacsms,     /* par_flgacsms */
                                              INPUT-OUTPUT par_nrdddtfc,
                                              INPUT-OUTPUT par_nrtelefo,
                                             OUTPUT par_dsmsgsms,
                                             OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0092.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
        
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                c-desc-erro = tt-erro.dscritic.
            ELSE
                ASSIGN c-desc-erro = IF par_cddopcao = "C" THEN "Problemas ao obter telefone para envio de SMS."
                                     ELSE IF par_cddopcao = "A" THEN "Problemas ao alterar telefone para envio de SMS."
                                     ELSE "Problemas ao excluir telefone para envio de SMS.".
                
            ASSIGN i-cod-erro  = 0
                   par_foco    = "13". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).  
            RETURN "NOK".            
        END.
    ELSE
        IF  par_cddopcao <> "C" THEN
            DO:
            
                RUN elimina-erro (INPUT par_nmrescop,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa).
            
                ASSIGN i-cod-erro  = 0 
                       c-desc-erro = IF par_cddopcao = "A" THEN "Alteracao do telefone para envio de SMS efetuada com sucesso!"
                                     ELSE "Exclusao do telefone para envio de SMS efetuada com sucesso!".
            
                RUN cria-erro (INPUT par_nmrescop,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
            END.
        
    RETURN "OK".
        
END PROCEDURE. 

PROCEDURE verifica-cartao:

  DEF INPUT        PARAM p-cooper              AS CHAR.
  DEF INPUT        PARAM p-cod-agencia         AS INTEGER.
  DEF INPUT        PARAM p-nro-caixa           AS INTEGER.
  DEF INPUT        PARAM p-cartao              AS DEC.
  DEF OUTPUT       PARAM p-nro-conta           AS DEC.
  DEF OUTPUT       PARAM p-nrcartao            AS DECI.
  DEF OUTPUT       PARAM p-idtipcar            AS INTE.
  
  DEF VAR aux_nrcartao AS DEC                  NO-UNDO.
  DEF VAR aux_nrdconta AS INT                  NO-UNDO.
  DEF VAR aux_cdcooper AS INT                  NO-UNDO.
  DEF VAR aux_inpessoa AS INT                  NO-UNDO.
  DEF VAR aux_idsenlet AS LOGICAL              NO-UNDO.
  DEF VAR aux_idseqttl AS INT                  NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                 NO-UNDO.
  DEF VAR aux_dscartao AS CHAR                 NO-UNDO.
  
  FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

  RUN elimina-erro (INPUT p-cooper,
                    INPUT p-cod-agencia,
                    INPUT p-nro-caixa).
                    
  FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
  
  ASSIGN aux_dscartao = "XX" + SUBSTR(STRING(p-cartao),1,16) + "=" + SUBSTR(STRING(p-cartao),17).
                  
  RUN sistema/generico/procedures/b1wgen0025.p 
       PERSISTENT SET h-b1wgen0025.
       
  RUN verifica_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                      INPUT 0,
                                      INPUT aux_dscartao, 
                                      INPUT crapdat.dtmvtolt,
                                     OUTPUT p-nro-conta,
                                     OUTPUT aux_cdcooper,
                                     OUTPUT p-nrcartao,
                                     OUTPUT aux_inpessoa,
                                     OUTPUT aux_idsenlet,
                                     OUTPUT aux_idseqttl,
                                     OUTPUT p-idtipcar,
                                     OUTPUT aux_dscritic).

  DELETE PROCEDURE h-b1wgen0025.
             
  IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
       DO:
          ASSIGN i-cod-erro  = 0 
                 c-desc-erro = aux_dscritic.
                                     
          RUN cria-erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT i-cod-erro,
                         INPUT c-desc-erro,
                         INPUT YES).
          RETURN "NOK".
       END.
                  
  RETURN "OK".

END PROCEDURE.


PROCEDURE valida-senha-cartao:

  DEF INPUT  PARAM p-cooper           AS CHAR.
  DEF INPUT  PARAM p-cod-agencia      AS INTE.
  DEF INPUT  PARAM p-nro-caixa        AS INTE.
  DEF INPUT  PARAM p-cod-operador     AS CHAR.
  DEF INPUT  PARAM p-nro-conta        AS DEC.     
  DEF INPUT  PARAM p-nrcartao         AS DECI.
  DEF INPUT  PARAM p-senha-cartao     AS CHAR.
  DEF INPUT  PARAM p-idtipcar         AS INTE.
  DEF INPUT  PARAM p-infocry          AS CHAR.
  DEF INPUT  PARAM p-chvcry           AS CHAR.   
  
  DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.    
  DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
    
  ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
  
  FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
  
  RUN sistema/generico/procedures/b1wgen0025.p 
                 PERSISTENT SET h-b1wgen0025.
                 
  RUN valida_senha_tp_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                             INPUT p-nro-conta, 
                                             INPUT p-nrcartao,
                                             INPUT p-idtipcar,
                                             INPUT p-senha-cartao,
                                             INPUT p-infocry,
                                             INPUT p-chvcry,
                                            OUTPUT aux_cdcritic,
                                            OUTPUT aux_dscritic). 

  DELETE PROCEDURE h-b1wgen0025.
            
  IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
       DO:
           ASSIGN i-cod-erro  = 0 
                  c-desc-erro = aux_dscritic.
                  
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.
   
  RETURN "OK".

END PROCEDURE.
/* .......................................................................... */

