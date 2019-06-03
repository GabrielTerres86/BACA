/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+--------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                  |
  +---------------------------------+--------------------------------------+
  | procedures/b1wgen0148.p         | BLOQ0001                             |
  | PROCEDURES:                     | PROCEDURES:                          |
  |   busca-blqrgt                  | BLOQ0001.pc_busca_blqrgt             |
  |   valida-blqrgt                 | BLOQ0001.pc_valida_blqrgt            | 
  |   valida-conta                  | BLOQ0001.pc_valida_conta             | 
  |   valida-bloqueio-judicial      | BLOQ0001.pc_valida_bloqueio_judicial |
  +---------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 14/05/2014 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Lucas Lunelli
    Data    : Janeiro/2013                Ultima Atualizacao: 07/01/2015.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQRGT
                 
    Alteracoes: 02/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
    
                06/03/2014 - Incluso VALIDATE (Daniel).

                23/05/2014 - Adicionado delete de HANDLE e ajuste na 
                             procedure "lista-aplicacoes" para buscar
                             aplicações de acordo com a opção selecionada 
                             na tela BLQRGT (Douglas - Chamado 77209)
                             
                17/10/2014 - Inclusão do parametro par_idtipapl nas procedures
                             busca-blqrgt, bloqueia-blqrgt, libera-blqrgt
                             (Jean Michel).
                             
                07/01/2015 - Ajuste no log de bloqueio de aplicacoes e
                             inclusao de novos parametros, alteracao na
                             procedure de validacao de bloqueio (Jean Michel).
                             
.............................................................................*/

{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0148tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_vlsldapl AS DECI                                           NO-UNDO.

DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

/*****************************************************************************
  Carrega aplicacoes da tela BLQRGT   
******************************************************************************/
PROCEDURE carrega-apl-blqrgt:

    DEF INPUT  PARAM par_cdcooper AS INTE  NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcpc.
   
    CREATE tt-crapcpc.
    ASSIGN tt-crapcpc.cdprodut = 1
           tt-crapcpc.nmprodut = "APLI.PROG"
           tt-crapcpc.idtipapl = "A". 
    
    CREATE tt-crapcpc.
    ASSIGN tt-crapcpc.cdprodut = 3
           tt-crapcpc.nmprodut = "RDCA"
           tt-crapcpc.idtipapl = "A".
    
    CREATE tt-crapcpc.
    ASSIGN tt-crapcpc.cdprodut = 5
           tt-crapcpc.nmprodut = "RDCA60"
           tt-crapcpc.idtipapl = "A".
    
    FOR EACH crapdtc WHERE crapdtc.cdcooper = par_cdcooper AND
                           crapdtc.flgstrdc = TRUE         AND
                          (crapdtc.tpaplrdc = 1            OR
                           crapdtc.tpaplrdc = 2)           NO-LOCK BY crapdtc.tpaplica:
    
        CREATE tt-crapcpc.
        ASSIGN tt-crapcpc.cdprodut = crapdtc.tpaplica
               tt-crapcpc.nmprodut = crapdtc.dsaplica
               tt-crapcpc.idtipapl = "A".
    
    END.
    

    /* Consulta novos produtos */
    FOR EACH crapdpc WHERE crapdpc.cdcooper = par_cdcooper AND
                           crapdpc.idsitmod = 1 NO-LOCK: /* VERIFICAE INSITMOD*/
        
        FOR EACH crapmpc WHERE crapmpc.cdmodali = crapdpc.cdmodali NO-LOCK:

            FOR EACH crapcpc WHERE crapcpc.cdprodut = crapmpc.cdprodut NO-LOCK BY crapcpc.nmprodut:
    
                FIND tt-crapcpc WHERE tt-crapcpc.cdprodut = crapcpc.cdprodut AND
                                      tt-crapcpc.nmprodut = crapcpc.nmprodut NO-LOCK NO-ERROR NO-WAIT.

                IF NOT AVAIL tt-crapcpc THEN
                    DO:
                    
                        FOR FIRST craprac FIELDS(cdprodut) WHERE craprac.idsaqtot = 0 AND
                                                                 craprac.cdprodut = crapcpc.cdprodut NO-LOCK. END.

                        IF AVAIL craprac THEN
                            DO:    
                                CREATE tt-crapcpc.
                                ASSIGN tt-crapcpc.cdprodut = crapcpc.cdprodut
                                       tt-crapcpc.nmprodut = crapcpc.nmprodut
                                       tt-crapcpc.idtipapl = "N".     
                            END.
                       
                    END.
            
            END.
        END.

    END.
    /* Fim Consulta novos produtos */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Validar existencia da Conta/dv   
******************************************************************************/
PROCEDURE valida-conta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF  OUTPUT PARAM par_dsdconta AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND  
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /* Sequencia */  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                
                RETURN "NOK".
            END.

    IF  crapass.inpessoa = 1 THEN
        DO:
            
            FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                     crapttl.nrdconta = crapass.nrdconta AND
                                     crapttl.idseqttl = 1   NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
        
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,  /* Sequencia */  
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    
                    RETURN "NOK".
                END.
            ELSE
                ASSIGN par_dsdconta = crapttl.nmextttl.

        END.
    ELSE
        DO:
            
            FIND FIRST crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND
                                     crapjur.nrdconta = crapass.nrdconta
                                     NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
        
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,  /* Sequencia */  
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    
                    RETURN "NOK".
                END.
            ELSE
                ASSIGN par_dsdconta = crapjur.nmextttl.
                                     
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Validar os dados da tela BLQRGT   
******************************************************************************/
PROCEDURE valida-blqrgt:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inoperac AS INT  /* 1=Bloqueio / 2=Lib.*/  NO-UNDO.
    DEF  INPUT PARAM par_idtipapl AS CHAR /* A= Antigo / N=Novo */  NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsdconta         AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    RUN valida-conta (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nrdconta,
                      OUTPUT aux_dsdconta,
                      OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

    IF par_idtipapl = "A" THEN
      DO:
        
          IF  par_tpaplica = 1 THEN
            DO:
                
                FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                   craprpp.nrdconta = par_nrdconta AND
                                   craprpp.nrctrrpp = par_nraplica NO-LOCK NO-ERROR.
                                     
                IF  NOT AVAIL craprpp THEN
                    DO:
                        ASSIGN aux_cdcritic = 426.
    
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,  /* Sequencia */  
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        
                        RETURN "NOK".
    
                    END.
            END.
        ELSE
            DO:
        
                IF  par_tpaplica <> 3  AND par_tpaplica <> 5 THEN
                    DO:
                        
                        FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper       AND
                                           crapdtc.flgstrdc = TRUE               AND
                                          (crapdtc.tpaplrdc = 1                  OR
                                           crapdtc.tpaplrdc = 2)                 AND
                                           crapdtc.tpaplica = par_tpaplica       NO-LOCK NO-ERROR.
    
                        IF  NOT AVAIL crapdtc THEN
                            DO:
                                ASSIGN aux_cdcritic = 346.
    
                                RUN gera_erro (INPUT par_cdcooper,        
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,  /* Sequencia */  
                                               INPUT aux_cdcritic,        
                                               INPUT-OUTPUT aux_dscritic).
                                 
                                RETURN "NOK".
                                
                            END.
                    END.
    
                FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                                   craprda.nrdconta = par_nrdconta AND
                                   craprda.nraplica = par_nraplica AND
                                   craprda.tpaplica = par_tpaplica NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL craprda THEN
                    DO:
                        ASSIGN aux_cdcritic = 426.
    
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,  /* Sequencia */  
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                         
                        RETURN "NOK".
    
                     END.
            END.
      END.
    ELSE
      DO:
        /* Verifica se o produto existe */
          FOR FIRST crapcpc FIELDS(cdprodut) WHERE crapcpc.cdprodut = par_tpaplica 
                                              NO-LOCK. END.

          /* Verifica se encontrou algum registro de produto */
          IF NOT AVAIL crapcpc THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Produto nao cadastrado.".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /* Sequencia */  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                 
                RETURN "NOK".
            END.

         /* Verifica se registro de aplicacao existe */
         FOR FIRST craprac FIELDS(nraplica) WHERE craprac.cdcooper = par_cdcooper AND
                                                   craprac.nrdconta = par_nrdconta AND
                                                   craprac.nraplica = par_nraplica AND
                                                   craprac.cdprodut = par_tpaplica
                                                   NO-LOCK. END.

         /* Verifica se encontrou algum registro de produto */
         IF NOT AVAIL craprac THEN
           DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Aplicacao nao cadastrada.".
    
             RUN gera_erro (INPUT par_cdcooper,        
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /* Sequencia */  
                            INPUT aux_cdcritic,        
                            INPUT-OUTPUT aux_dscritic).
                 
             RETURN "NOK".
           END.

      END.

    /*  Consulta o Bloqueio Judicial somente no Bloqueio como Garantia */
    
    IF   par_inoperac = 1 THEN
         RUN valida-bloqueio-judicial(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nrdconta,
                                      INPUT par_tpaplica,
                                      INPUT par_nraplica,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idtipapl, /* A= Antigo / N=Novo */
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Buscar os dados da tela BLQRGT   
******************************************************************************/
PROCEDURE busca-blqrgt:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_idtipapl AS CHAR /* A= Antigo / N=Novo */  NO-UNDO.
    DEF  OUTPUT PARAM par_flgstapl AS LOGI                           NO-UNDO.
    
    DEF OUTPUT  PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida-blqrgt (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nrdconta,
                       INPUT par_tpaplica,
                       INPUT par_nraplica,
                       INPUT par_dtmvtolt,
                       INPUT 0,
                       INPUT par_idtipapl, 
                       OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".
    
    /* Verifica se e produto antigo ou novo */
    IF par_idtipapl = "A" THEN
      DO:
        
        FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper                  AND
                             craptab.nmsistem = "CRED"                            AND
                             craptab.tptabela = "BLQRGT"                          AND
                             craptab.cdempres = 00                                AND
                             craptab.cdacesso = STRING(par_nrdconta,"9999999999") AND 
                             INT(SUBSTRING(craptab.dstextab,1,7)) = par_nraplica      
                             NO-LOCK NO-ERROR.

        IF  AVAIL craptab THEN
            ASSIGN par_flgstapl = FALSE.
        ELSE
            ASSIGN par_flgstapl = TRUE.  
      END.
    ELSE
      DO:
        
        FOR FIRST craprac FIELDS(idblqrgt) WHERE craprac.cdcooper = par_cdcooper
                                             AND craprac.nrdconta = par_nrdconta
                                             AND craprac.nraplica = par_nraplica 
                                             AND craprac.idblqrgt = 0 NO-LOCK.
                                            END.

        IF NOT AVAIL craprac THEN
          ASSIGN par_flgstapl = FALSE.
        ELSE
          ASSIGN par_flgstapl = TRUE.

      END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Bloquear aplicações na tela BLQRGT   
******************************************************************************/
PROCEDURE bloqueia-blqrgt:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT  PARAM par_idtipapl AS CHAR /* A= Antigo / N=Novo */  NO-UNDO.
    DEF  INPUT  PARAM par_nmprodut AS CHAR                           NO-UNDO.
    DEF OUTPUT  PARAM TABLE FOR tt-erro.

    DEF  VAR aux_tpregist AS INT                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    RUN valida-blqrgt (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nrdconta,
                       INPUT par_tpaplica,
                       INPUT par_nraplica,
                       INPUT par_dtmvtolt,
                       INPUT 1,     /* Bloqueio */
                       INPUT par_idtipapl,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:

    IF par_idtipapl = "A" THEN
      DO:
        
        FIND FIRST craptab WHERE
                   craptab.cdcooper = par_cdcooper                      AND
                   craptab.nmsistem = "CRED"                            AND
                   craptab.tptabela = "BLQRGT"                          AND
                   craptab.cdempres = 00                                AND
                   craptab.cdacesso = STRING(par_nrdconta,"9999999999") AND 
                   INT(SUBSTR(craptab.dstextab,1,7)) = par_nraplica      
                   NO-LOCK NO-ERROR NO-WAIT.
              
        IF AVAIL craptab THEN
          DO:
            ASSIGN aux_cdcritic = 669. /* Já bloqueada */
        
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
                         
            RETURN "NOK".
        
          END.
        ELSE
          DO:
            FIND LAST craptab WHERE craptab.cdcooper = par_cdcooper                      AND
                                    craptab.nmsistem = "CRED"                            AND 
                                    craptab.tptabela = "BLQRGT"                          AND
                                    craptab.cdempres = 00                                AND
                                    craptab.cdacesso = STRING(par_nrdconta,"9999999999") 
                                    NO-LOCK NO-ERROR NO-WAIT.
              
            IF   NOT AVAIL craptab THEN
                 aux_tpregist = 1.
            ELSE 
                 aux_tpregist = craptab.tpregist + 1.
            
            CREATE craptab.
            ASSIGN craptab.nmsistem = "CRED"
                   craptab.tptabela = "BLQRGT"
                   craptab.cdempres = 00 
                   craptab.cdacesso = STRING(par_nrdconta,"9999999999")
                   craptab.tpregist = aux_tpregist
                   craptab.dstextab = STRING(par_nraplica,"9999999")
                   craptab.cdcooper = par_cdcooper.
            VALIDATE craptab.
              
        END.
      END.
    ELSE
      DO:
        FOR FIRST craprac FIELDS(idblqrgt) WHERE craprac.cdcooper = par_cdcooper
                                             AND craprac.nrdconta = par_nrdconta
                                             AND craprac.nraplica = par_nraplica EXCLUSIVE-LOCK.
                                            END.

        IF NOT AVAIL craprac THEN
          DO:
            ASSIGN aux_cdcritic = 0 /* Inexistente */
                   aux_dscritic = "Aplicacao nao cadastrada".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
          END.
        ELSE
          DO:
            IF craprac.idblqrgt >= 1 THEN
              DO:
                ASSIGN aux_cdcritic = 669. /* Já bloqueada */

                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /* Sequencia */  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                 
                RETURN "NOK".
              END.
            ELSE
              ASSIGN craprac.idblqrgt = 1.
          END.
      END.
    
      IF par_flgerlog THEN 
        DO:
          UNIX SILENT VALUE ("echo " + STRING(par_dtmvtolt,"99/99/9999")  +
                             " - "   + STRING(TIME,"HH:MM:SS")            +
                             " Operador: "  + par_cdoperad + " --- "      +
                             "Bloqueou aplicacao " + STRING(par_nraplica) +
                             " da Conta/Dv " + STRING(par_nrdconta) + ". Tipo: " +
                             STRING(par_tpaplica) + " - " + STRING(par_nmprodut) +
                             " >> /usr/coop/" + TRIM(crapcop.dsdircop)    +
                             "/log/blqrgt.log").
        END.
    
    END. /* Fim da transacao */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Liberar aplicações na tela BLQRGT   
******************************************************************************/
PROCEDURE libera-blqrgt:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT  PARAM par_idtipapl AS CHAR /* A= Antigo / N=Novo */  NO-UNDO.
    DEF  INPUT  PARAM par_nmprodut AS CHAR                           NO-UNDO.

    DEF OUTPUT  PARAM TABLE FOR tt-erro.

    DEF  VAR aux_tpregist AS INT                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida-blqrgt (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nrdconta,
                       INPUT par_tpaplica,
                       INPUT par_nraplica,
                       INPUT par_dtmvtolt,
                       INPUT 2,         /* Liberacao */
                       INPUT par_idtipapl,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:

      IF par_idtipapl = "A" THEN
        DO:
            FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper                      AND
                                 craptab.nmsistem = "CRED"                            AND
                                 craptab.tptabela = "BLQRGT"                          AND
                                 craptab.cdempres = 00                                AND
                                 craptab.cdacesso = STRING(par_nrdconta,"9999999999") AND
                                 INT(SUBSTR(craptab.dstextab,1,7)) = par_nraplica      
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        	IF NOT AVAIL craptab THEN
        		DO:   
        			IF LOCKED craptab   THEN
        			  DO:
                        ASSIGN aux_cdcritic = 77.
                        
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,  /* Sequencia */  
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                         
                        RETURN "NOK".
        			  END.
                    ELSE
                	  DO:
                	    ASSIGN aux_cdcritic = 668. /* Não está bloqueada */
                						
                		RUN gera_erro (INPUT par_cdcooper,        
                		       		   INPUT par_cdagenci,
                					   INPUT par_nrdcaixa,
                					   INPUT 1,  /* Sequencia */  
                					   INPUT aux_cdcritic,        
                					   INPUT-OUTPUT aux_dscritic).
                						 
                        RETURN "NOK".
                      END.
                END.
            ELSE
              DELETE craptab.
        END.
      ELSE
        DO:
          FOR FIRST craprac FIELDS(idblqrgt) WHERE craprac.cdcooper = par_cdcooper
                                             AND craprac.nrdconta = par_nrdconta
                                             AND craprac.nraplica = par_nraplica EXCLUSIVE-LOCK.
                                             END.

          IF NOT AVAIL craprac THEN
            DO:
              ASSIGN aux_cdcritic = 0 /* Inexistente */
                     aux_dscritic = "Aplicacao nao cadastrada".
    
              RUN gera_erro (INPUT par_cdcooper,        
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,  /* Sequencia */  
                             INPUT aux_cdcritic,        
                             INPUT-OUTPUT aux_dscritic).
                 
              RETURN "NOK".
            END.
          ELSE
            DO:
              IF craprac.idblqrgt = 0 THEN
                DO:
                  ASSIGN aux_cdcritic = 668. /* Não está bloqueada */
                             
                  RUN gera_erro (INPUT par_cdcooper,        
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,  /* Sequencia */  
                                 INPUT aux_cdcritic,        
                                 INPUT-OUTPUT aux_dscritic).
                     
                  RETURN "NOK".
                END.
              ELSE
                ASSIGN craprac.idblqrgt = 0.
            END.
        END.

      IF par_flgerlog THEN 
        DO:
          UNIX SILENT VALUE ("echo " + STRING(par_dtmvtolt,"99/99/9999")  +
                             " - "   + STRING(TIME,"HH:MM:SS")            +
                             " Operador: "  + par_cdoperad + " --- "      +
                             "Liberou aplicacao " + STRING(par_nraplica)  +
                             " da Conta/Dv " + STRING(par_nrdconta) + ". Tipo: " +
                             STRING(par_tpaplica) + " - " + STRING(par_nmprodut) +
                             " >> /usr/coop/" + TRIM(crapcop.dsdircop)    +
                             "/log/blqrgt.log").
        END.
    END. /* Fim da transacao */

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Listagem de Aplicações 
******************************************************************************/
PROCEDURE lista-aplicacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR     NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR     NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE     NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR     NO-UNDO.
    DEF  INPUT PARAM par_idtipapl AS CHAR     NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE     NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-aplicacoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nrregist AS INT.

    DEF VAR aux_cria_tt-aplicacao AS LOGICAL INIT FALSE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-saldo-rdca.
    EMPTY TEMP-TABLE tt-aplicacoes.
    
    ASSIGN aux_nrregist = par_nrregist.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 

    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    
    IF par_tpaplica = 1 AND par_idtipapl = "A" THEN

        FOR EACH craprpp NO-LOCK WHERE craprpp.cdcooper = par_cdcooper AND
                                       craprpp.nrdconta = par_nrdconta AND
                                       (IF par_nraplica <> 0 THEN
                                       craprpp.nrctrrpp = par_nraplica ELSE 
                                       craprpp.nrctrrpp > 0).

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist >= 1 THEN
                DO:
                    ASSIGN aux_cria_tt-aplicacao = FALSE.
                    /* Quando a opção for "C", vamos carregar todas as aplicações indiferenta da situação */
                    IF  par_cddopcao = "C" THEN
                        ASSIGN aux_cria_tt-aplicacao = TRUE.
                    ELSE
                        DO:
                            /* Quando uma plicação for BLOQUEADA eh gerado um registro na tabela craptab */
                            FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper
                                                 AND craptab.nmsistem = "CRED"
                                                 AND craptab.tptabela = "BLQRGT"
                                                 AND craptab.cdempres = 00
                                                 AND craptab.cdacesso = STRING(par_nrdconta,"9999999999")
                                                 /* utilizamos o numero da aplicacao que esta sendo carregada */
                                                 AND INT(SUBSTR(craptab.dstextab,1,7)) = craprpp.nrctrrpp
                                               NO-LOCK NO-ERROR NO-WAIT.
                            
                            /* Quando estiver pesquisando a opção "B" é para bloquear uma aplicação dessa forma
                               vamos listar apenas aquelas que não estão na tabela craptab (ou seja estão liberadas)*/ 
                            IF  par_cddopcao = "B" AND NOT AVAIL craptab THEN
                                ASSIGN aux_cria_tt-aplicacao = TRUE.
                            
                            /* Quando estiver pesquisando a opção "L" é para liberar uma aplicação dessa forma
                               vamos listar apenas aquelas que estão na tabela craptab (ou seja estão bloqueadas) */ 
                            ELSE
                                IF  par_cddopcao = "L" AND AVAIL craptab THEN
                                    ASSIGN aux_cria_tt-aplicacao = TRUE.
                        END.

                    IF  aux_cria_tt-aplicacao THEN
                        DO:
                            CREATE tt-aplicacoes.
                            ASSIGN tt-aplicacoes.nraplica = STRING(craprpp.nrctrrpp, 'z,zzz,zz9')
                                   tt-aplicacoes.dtmvtolt = craprpp.dtmvtolt
                                   tt-aplicacoes.sldresga = "R$" + STRING(craprpp.vlsdrdpp,'zzz,zzz,zzz,zzz,zz9.99-').
                        END.
                END.
            
            ASSIGN aux_nrregist = aux_nrregist - 1.
        
        END.
    ELSE
        DO:
           /* Inicializando objetos para leitura do XML */ 
           CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
           CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
           CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
           CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
           CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
           
           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
           
           /* Efetuar a chamada a rotina Oracle */ 
           RUN STORED-PROCEDURE pc_lista_aplicacoes_car
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,     /* Código da Cooperativa */
                                                    INPUT par_cdoperad,     /* Código do Operador */
                                                    INPUT par_nmdatela,     /* Nome da Tela */
                                                    INPUT 1,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                    INPUT 1,                /* Numero do Caixa */
                                                    INPUT par_nrdconta,     /* Número da Conta */
                                                    INPUT 1,                /* Titular da Conta */
                                                    INPUT 1,                /* Codigo da Agencia */
                                                    INPUT par_nmdatela,     /* Codigo do Programa */
                                                    INPUT 0,                /* Número da Aplicação - Parâmetro Opcional */
                                                    INPUT 0,                /* Código do Produto – Parâmetro Opcional */ 
                                                    INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                                    INPUT 5,                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) -- 5*/ 
                                                    INPUT 1,                /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
                                                   OUTPUT ?,                /* XML com informações de LOG */
                                                   OUTPUT 0,                /* Código da crítica */
                                                   OUTPUT "").              /* Descrição da crítica */

           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_lista_aplicacoes_car
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
           
           /* Busca possíveis erros */ 
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = ""
                  aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                                 WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
                  aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                                 WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.

           IF aux_cdcritic <> 0 OR
              aux_dscritic <> "" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /* Sequencia */  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                     
                RETURN "NOK".
                
             END.
        
           EMPTY TEMP-TABLE tt-saldo-rdca.
        
           /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
            para visualizacao dos registros na tela */
            
           /* Buscar o XML na tabela de retorno da procedure Progress */ 
            ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 
            
            /* Efetuar a leitura do XML*/ 
            SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
            PUT-STRING(ponteiro_xml,1) = TRIM(xml_req).
             
            IF ponteiro_xml <> ? THEN
                DO:
                    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                    
                    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                
                        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                
                        IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                         NEXT. 
                
                        IF xRoot2:NUM-CHILDREN > 0 THEN
                          CREATE tt-saldo-rdca.
                
                        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                             
                            xRoot2:GET-CHILD(xField,aux_cont).
                                
                            IF xField:SUBTYPE <> "ELEMENT" THEN 
                                NEXT. 
                            
                            xField:GET-CHILD(xText,1).
                                                          
                            ASSIGN tt-saldo-rdca.nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                                   tt-saldo-rdca.sldresga = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vllanmto"
                                   tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt"
                                   tt-saldo-rdca.tpaplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "tpaplica"
                                   tt-saldo-rdca.dssitapl = TRIM(xText:NODE-VALUE) WHEN xField:NAME = "dssitapl"
                                   tt-saldo-rdca.idtipapl = TRIM(xText:NODE-VALUE) WHEN xField:NAME = "idtipapl".
                            
                        END. 
                        
                    END.
                
                    SET-SIZE(ponteiro_xml) = 0. 
                END.                                  
                                
            DELETE OBJECT xDoc. 
            DELETE OBJECT xRoot. 
            DELETE OBJECT xRoot2. 
            DELETE OBJECT xField. 
            DELETE OBJECT xText.
        
            /* Fim leitura do XML de novas aplicacoes JEAN */
            
            FOR EACH tt-saldo-rdca NO-LOCK WHERE  tt-saldo-rdca.tpaplica = par_tpaplica AND
                                                  tt-saldo-rdca.idtipapl = par_idtipapl AND 
                                                 (IF par_nraplica <> 0 THEN
                                                 tt-saldo-rdca.nraplica = par_nraplica ELSE 
                                                 tt-saldo-rdca.nraplica > 0)  AND 
                                                 (IF par_cddopcao = "B" THEN
                                                      tt-saldo-rdca.dssitapl <> "BLOQUEADA"
                                                  ELSE TRUE) AND
                                                 (IF par_cddopcao = "L" THEN
                                                      tt-saldo-rdca.dssitapl = "BLOQUEADA"
                                                  ELSE TRUE).
                        
                    ASSIGN par_qtregist = par_qtregist + 1.
                
                    /* controles da paginação */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
                
                    IF  aux_nrregist >= 1 THEN
                        DO:
                            CREATE tt-aplicacoes.
                            ASSIGN tt-aplicacoes.nraplica = STRING(tt-saldo-rdca.nraplica, 'z,zzz,zz9')
                                   tt-aplicacoes.dtmvtolt = tt-saldo-rdca.dtmvtolt
                                   tt-aplicacoes.sldresga = "R$" + STRING(tt-saldo-rdca.sldresga,'zzz,zzz,zzz,zzz,zz9.99-').
            
                        END.
                    
                    ASSIGN aux_nrregist = aux_nrregist - 1.
            
            END.

        END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-bloqueio-judicial:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idtipapl AS CHAR /* A= Antigo / N=Novo */  NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dscritic AS CHAR NO-UNDO.
    
    DEF  VAR aux_vlblqjud AS DECI NO-UNDO.
    DEF  VAR aux_vlresblq AS DECI NO-UNDO.
    DEF  VAR aux_vlsldrpp AS DECI NO-UNDO.
    DEF  VAR aux_vlsldpou AS DECI NO-UNDO.
    DEF  VAR aux_vlsldapl AS DECI NO-UNDO.
    DEF  VAR aux_vlsbloqu AS DECI NO-UNDO.
    
    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    
    IF par_idtipapl = "A" AND
       par_tpaplica =  1 THEN        /* Poupanca Programada */
      DO:
        /*** Busca Saldo Bloqueado Judicial ***/
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.

        RUN retorna-valor-blqjud IN h-b1wgen0155
                                (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT 0, /* fixo - nrcpfcgc */
                                 INPUT 1, /* Bloq. Normal    */
                                 INPUT 3, /* 3 - Poupanca    */
                                 INPUT par_dtmvtolt,
                                 OUTPUT aux_vlblqjud,
                                 OUTPUT aux_vlresblq).

        DELETE PROCEDURE h-b1wgen0155.

        IF aux_vlblqjud > 0 THEN
          DO:
             EMPTY TEMP-TABLE tt-dados-rpp.

             /** Saldo das aplicacoes **/
             RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT
                 SET h-b1wgen0006.

             IF  VALID-HANDLE(h-b1wgen0006)  THEN
                 DO:
                     RUN consulta-poupanca IN h-b1wgen0006 
                                   (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT "B1WGEN0148",
                                    INPUT 1,
                                    INPUT par_nrdconta,
                                    INPUT 1,
                                    INPUT 0,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtolt,
                                    INPUT 1,
                                    INPUT "B1WGEN0148",
                                    INPUT FALSE,  /** Nao Gerar Log **/
                                    OUTPUT aux_vlsldrpp,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dados-rpp).

                     DELETE PROCEDURE h-b1wgen0006.
    
                     IF  RETURN-VALUE = "NOK"  THEN
                         DO:
                             FIND FIRST tt-erro NO-LOCK NO-ERROR.
     
                             IF  AVAILABLE tt-erro  THEN
                                 DO:
                                     RUN gera_erro (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT 1,
                                                    INPUT
                                                      tt-erro.cdcritic,
                                                    INPUT-OUTPUT 
                                                      tt-erro.dscritic).

                                     RETURN "NOK".
                                 END.
                         END.
                     
             
                     FOR EACH tt-dados-rpp WHERE 
                              tt-dados-rpp.dsblqrpp <> "Sim" NO-LOCK:
  
                        ASSIGN aux_vlsldpou = aux_vlsldpou +
                                              tt-dados-rpp.vlrgtrpp.
                     END.
       
                    FIND LAST tt-dados-rpp WHERE 
                         tt-dados-rpp.nrctrrpp = par_nraplica
                         NO-LOCK NO-ERROR.
                         
                    IF   AVAILABLE tt-dados-rpp THEN
                         aux_vlsbloqu = tt-dados-rpp.vlrgtrpp.
    
                    IF  VALID-HANDLE(h-b1wgen0006) THEN
                        DELETE PROCEDURE h-b1wgen0006.
                 END.
         
             IF (aux_vlsldpou - aux_vlblqjud) < aux_vlsbloqu THEN
               DO:
                 aux_dscritic = 
                         "Aplicacao ja Bloqueada Judicialmente.".

                 RUN gera_erro 
                     (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,
                      INPUT 0,
                      INPUT-OUTPUT aux_dscritic).

                 RETURN "NOK".
               END.
          END.
      END.
    ELSE  /* Produto Novos e Antigos (Menos Poupança) */
      DO:
        
        /*** Busca Saldo Bloqueado Judicial ***/
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.
        
        RUN retorna-valor-blqjud IN h-b1wgen0155
                                (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT 0,            /* fixo - nrcpfcgc */
                                 INPUT 1,            /* Bloq. Normal    */
                                 INPUT 2,            /* 2 - Aplicacoes  */
                                 INPUT par_dtmvtolt,
                                OUTPUT aux_vlblqjud,
                                OUTPUT aux_vlresblq).
        
        DELETE PROCEDURE h-b1wgen0155.
        
        IF aux_vlblqjud > 0 THEN
          DO:
            
            ASSIGN aux_vlsldapl = 0.
            
            /** Saldo das aplicacoes **/
            
            /* Inicializando objetos para leitura do XML */ 
            CREATE X-DOCUMENT xDoc.   /* Vai conter o XML completo */ 
            CREATE X-NODEREF  xRoot.  /* Vai conter a tag raiz em diante */
            CREATE X-NODEREF  xRoot2. /* Vai conter a tag aplicacao em diante */
            CREATE X-NODEREF  xField. /* Vai conter os campos dentro da tag INF */
            CREATE X-NODEREF  xText.  /* Vai conter o texto que existe dentro da tag xField */
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
            
            /* Efetuar a chamada a rotina Oracle */ 
            RUN STORED-PROCEDURE pc_lista_aplicacoes_car
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                    INPUT par_cdoperad, /* Código do Operador */
                                                    INPUT "BLQRGT",     /* Nome da Tela */
                                                    INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                    INPUT 1,            /* Numero do Caixa */
                                                    INPUT par_nrdconta, /* Número da Conta */
                                                    INPUT 1,            /* Titular da Conta */
                                                    INPUT 1,            /* Codigo da Agencia */
                                                    INPUT "BLQRGT",     /* Codigo do Programa */
                                                    INPUT 0,            /* Número da Aplicação - Parâmetro Opcional */
                                                    INPUT 0,            /* Código do Produto – Parâmetro Opcional */ 
                                                    INPUT par_dtmvtolt, /* Data de Movimento */
                                                    INPUT 6,            /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                                    INPUT 1,            /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
                                                   OUTPUT ?,            /* XML com informações de LOG */
                                                   OUTPUT 0,            /* Código da crítica */
                                                   OUTPUT "").          /* Descrição da crítica */
            
            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_lista_aplicacoes_car
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
            
            /* Busca possíveis erros */ 
            ASSIGN aux_cdcritic = 0
                  aux_dscritic = ""
                  aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                                 WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
                  aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                                 WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.
            
            IF aux_cdcritic <> 0 OR
              aux_dscritic <> "" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /* Sequencia */  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                     
                RETURN "NOK".
                
             END.
            
            EMPTY TEMP-TABLE tt-saldo-rdca.
                                                                
            /* Buscar o XML na tabela de retorno da procedure Progress */ 
            ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc.
        
            /* Efetuar a leitura do XML*/ 
            SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
            PUT-STRING(ponteiro_xml,1) = xml_req. 
             
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
            
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
            
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
            
                IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                 NEXT. 
            
                IF xRoot2:NUM-CHILDREN > 0 THEN
                   CREATE tt-saldo-rdca.
        
                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                
                    xRoot2:GET-CHILD(xField,aux_cont).
                        
                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                    
                    xField:GET-CHILD(xText,1).                   
        
                    ASSIGN tt-saldo-rdca.nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                           tt-saldo-rdca.dsaplica =      xText:NODE-VALUE  WHEN xField:NAME = "dsnomenc"
                           tt-saldo-rdca.vlaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica"
                           tt-saldo-rdca.sldresga = DECI(xText:NODE-VALUE) WHEN xField:NAME = "sldresga"
                           tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                END.            
                
            END.                
        
            SET-SIZE(ponteiro_xml) = 0. 
         
            DELETE OBJECT xDoc.
            DELETE OBJECT xRoot. 
            DELETE OBJECT xRoot2.
            DELETE OBJECT xField.
            DELETE OBJECT xText.
            
            FOR EACH tt-saldo-rdca WHERE 
                     tt-saldo-rdca.dssitapl <> "BLOQUEADA" NO-LOCK:
                
              ASSIGN aux_vlsldapl = aux_vlsldapl + tt-saldo-rdca.sldresga.
            END.
                   
            FIND LAST tt-saldo-rdca WHERE tt-saldo-rdca.nraplica = par_nraplica
                                    NO-LOCK NO-ERROR.
                                     
            IF AVAILABLE tt-saldo-rdca THEN
              aux_vlsbloqu = tt-saldo-rdca.sldresga.
                
            IF (aux_vlsldapl - aux_vlblqjud) < aux_vlsbloqu THEN
              DO:
                aux_dscritic = "Aplicacao ja Bloqueada Judicialmente.".
               
                RUN gera_erro(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).
                              
                  RETURN "NOK".
              END.
          END.
          
      END.
         
END PROCEDURE.

/* .......................................................................... */
