/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0124.p
    Autor   : Lucas
    Data    : Novembro/2011               Ultima Atualizacao: 22/03/2013
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela TAB036
                 
    Alteracoes: 22/03/2013 - Ajuste nas procedures busca_tab036, altera_tab036
                             para utilizar o dstextab nas posicoes '91,6" ao
                             inves de "28,6" (Adriano).
                             
                31/10/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                             
                

.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.


/*****************************************************************************
  Validar acesso à TAB036 
******************************************************************************/

PROCEDURE permiss_tab036:
         
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdepart AS CHAR                           NO-UNDO.
   
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
     
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Permiss:
    DO:
        IF  par_dsdepart <> "COORD.ADM/FINANCEIRO"   AND   
            par_dsdepart <> "COORD.PRODUTOS"      AND   
            par_dsdepart <> "TI"      THEN
            DO:
                aux_cdcritic = 36.
                LEAVE Permiss.
            END.
    END.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
  
    RETURN "OK".
  
END PROCEDURE.

/*****************************************************************************
  Carregar os dados gravados na TAB036 
******************************************************************************/

PROCEDURE busca_tab036:

   DEF  VAR         aux_dstextab  AS CHAR                           NO-UNDO. 

   DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.

   DEF  OUTPUT PARAM par_vlrating AS DEC                            NO-UNDO.
   DEF  OUTPUT PARAM par_pcgrpeco AS DEC                            NO-UNDO.

   DEF  OUTPUT PARAM TABLE FOR tt-erro.

   EMPTY TEMP-TABLE tt-erro.

   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 00             AND
                      craptab.cdacesso = "PROVISAOCL"   AND
                      craptab.tpregist = 999 
                      NO-LOCK NO-ERROR.

   /* Verifica Disponibilidade da Tabela */
   IF  AVAIL craptab THEN
       DO:
           ASSIGN aux_dstextab = craptab.dstextab
                  par_vlrating = DEC(SUBSTRING(aux_dstextab,15,11))
                  par_pcgrpeco = DEC(SUBSTRING(aux_dstextab,91,6)).
                  
           RETURN "OK".

       END.
   ELSE
       DO:
           ASSIGN aux_cdcritic = 55.
            
           RUN gera_erro (INPUT par_cdcooper,        
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,  /* Sequencia */  
                          INPUT aux_cdcritic,        
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

       END.

END PROCEDURE.

/*****************************************************************************
  Alterar os dados gravados na TAB036 
******************************************************************************/

PROCEDURE altera_tab036:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
   DEF  INPUT PARAM par_dstextab AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_dsdepart AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_vlrating AS DEC                            NO-UNDO.
   DEF  INPUT PARAM par_pcgrpeco AS DEC                            NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_flgtrans         AS LOGI                           NO-UNDO.
   DEF  VAR log_dstextab         AS DEC EXTENT 2                   NO-UNDO.
   DEF  VAR aux_valanter         AS CHAR                           NO-UNDO.    
   DEF  VAR aux_msgdolog         AS CHAR                           NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   /* Verifica Permissão de Acesso do Operador */
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                      crapope.cdoperad = par_cdoperad    
                      NO-LOCK NO-ERROR.

   IF NOT CAN-DO("TI,SUPORTE,COORD.ADM/FINANCEIRO,COORD.PRODUTOS",par_dsdepart) AND
      crapope.nvoperad <>  3                                                    THEN
      DO:
          ASSIGN aux_cdcritic = 36.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".
      END.

   IF par_flgerlog  THEN
      ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
             aux_dstransa = "Atualizar contas para validacao de prazo"
             aux_dscritic = ""
             aux_flgtrans = FALSE.

   TRANS_TAB:
   DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                  ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:

      DO aux_contador = 1 TO 10:
              
         ASSIGN aux_cdcritic = 0.

         FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                            craptab.nmsistem = "CRED"         AND
                            craptab.tptabela = "GENERI"       AND
                            craptab.cdempres = 00             AND
                            craptab.cdacesso = "PROVISAOCL"   AND
                            craptab.tpregist = 999
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
     
         IF NOT AVAILABLE craptab  THEN
            IF LOCKED craptab  THEN
               DO: 
                    ASSIGN aux_contador = aux_contador + 1.
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                    					 INPUT "banco",
                    					 INPUT "craptab",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                    aux_cdcritic = 0.
                   NEXT.
               END. 
            ELSE
               DO:
                   ASSIGN aux_cdcritic = 55.
               END.
   
         LEAVE.

      END. /* FIM do DO ... TO */

      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
         UNDO TRANS_TAB, LEAVE TRANS_TAB.

      IF AVAIL craptab THEN
         DO:
            /* Armazena Valores anteriores para o LOG */ 
            ASSIGN aux_valanter    = craptab.dstextab
                   log_dstextab[1] = DEC(SUBSTRING(aux_valanter,15,11))
                   log_dstextab[2] = DEC(SUBSTRING(aux_valanter,91,6)).

            ASSIGN SUBSTRING(craptab.dstextab,15,11) = STRING(par_vlrating,"99999999.99")
                   SUBSTRING(craptab.dstextab,91,6) =  STRING(par_pcgrpeco,"999.99").
   
         END.
                  
      FIND CURRENT craptab NO-LOCK NO-ERROR.

      RELEASE craptab.

      ASSIGN aux_flgtrans = TRUE.

   END. /* FIM do TRANSACTION */

   IF NOT aux_flgtrans THEN
      DO:
          IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
              ASSIGN aux_dscritic = "Nao foi possivel atualizar as contas.".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          IF par_flgerlog THEN
             DO:
                UNIX SILENT VALUE ("echo "                                    +
                                   STRING(par_dtmvtolt,"99/99/9999") + " - "  +
                                   STRING(TIME,"HH:MM:SS")                    +
                                    " Operador:"  + " " + par_cdoperad        +
                                    " --- " + aux_dscritic                    +
                                    " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                    "/log/tab036.log").
             END.                                                            
          
          RETURN "NOK".

      END.

   IF par_vlrating <> log_dstextab[1] THEN
      ASSIGN aux_msgdolog = "Alterou o Valor de Rating de "                 + 
                            STRING(log_dstextab[1],"zz,zzz,zz9.99")         + 
                            " para " + STRING(par_vlrating,"zz,zzz,zz9.99") + 
                            ".".
   
   IF par_pcgrpeco <> log_dstextab[2] THEN
      ASSIGN aux_msgdolog = aux_msgdolog                                    + 
                            " Alterou a porcentagem do Grupo Economico de " + 
                            STRING(log_dstextab[2]) + "% para "             + 
                            STRING(par_pcgrpeco) + "%.".
   
   /* Grava LOG (Sucesso) */ 
   IF par_flgerlog  THEN 
      DO:
         UNIX SILENT VALUE ("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                            " - " +   STRING(TIME,"HH:MM:SS")           +
                            " Operador: "  + par_cdoperad + " --- "     +
                            aux_msgdolog                                +
                            " >> /usr/coop/" + TRIM(crapcop.dsdircop)   +
                            "/log/tab036.log").

      END.

   RETURN "OK".

END PROCEDURE. 

/*****************************************************************************
  Fim da b1wgen0124.p 
******************************************************************************/
