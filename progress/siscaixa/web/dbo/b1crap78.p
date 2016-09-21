/*----------------------------------------------------------------------*/
/*  b1crap78.p   - Estorno de Cheque Capturado                          */
/*  Hist¢ricos   - 21 ou 26(conta - 978809)                             */
/*  Autentica‡Æo - PG                                                   */
/*----------------------------------------------------------------------*/
/*

    Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
                
                20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).
                
                17/06/2010 - Remoção da conferência da agência 95 (Vitor).
                
                12/07/2010 - Adaptar para Cheques IF CECRED (Guilherme).
                
                18/01/2010 - Adaptar para Migracao de PAC (Guilherme).
                
                21/05/2012 - substituição do FIND craptab para os registros 
                             CONTACONVE pela chamada do fontes ver_ctace.p
                             (Lucas R.)
                        
                18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                
                09/10/2012 - Alteracao da logica para migracao de PAC
                             devido a migracao da AltoVale (Guilherme).
                             
                19/02/2014 - Ajuste leitura craptco (Daniel).
    
----------------------------------------------------------------------  */
                                                                        
{dbo/bo-erro1.i}

DEFINE VARIABLE i-cod-erro  AS INT                                  NO-UNDO.
DEFINE VARIABLE c-desc-erro AS CHAR                                 NO-UNDO.

DEFINE VARIABLE h_b2crap00  AS HANDLE                               NO-UNDO.

DEF VAR p-nro-calculado     AS DEC                                  NO-UNDO.
DEF VAR p-lista-digito      AS CHAR                                 NO-UNDO.
DEF VAR de-nrctachq         AS DEC     FORMAT "zzz,zzz,zzz,9"       NO-UNDO.
DEF VAR c-cmc-7             AS CHAR                                 NO-UNDO.
DEF VAR i-nro-lote          AS INTE                                 NO-UNDO.
DEF VAR i-cdhistor          AS INTE                                 NO-UNDO.
DEF VAR aux_lsconta3        AS CHAR                                 NO-UNDO.
DEF VAR aux_lscontas        AS CHAR                                 NO-UNDO.
DEF VAR i_conta             AS INTE                                 NO-UNDO.
DEF VAR aux_nrdconta        AS INTE                                 NO-UNDO.
DEF VAR i_nro-folhas        AS INTE                                 NO-UNDO.
DEF VAR i_posicao           AS INTE                                 NO-UNDO.
DEF VAR i_nro-talao         AS INTE                                 NO-UNDO.
DEF VAR i_nro-docto         AS INTE                                 NO-UNDO.
DEF VAR i_cheque            AS DEC     FORMAT "zzz,zzz,9"           NO-UNDO.
DEF VAR aux_indevchq        AS INTE                                 NO-UNDO.
DEF VAR i-codigo-erro       AS INTE                                 NO-UNDO.
DEF VAR in99                AS INTE                                 NO-UNDO. 

DEF VAR i-cdbanchq          AS INTE                                 NO-UNDO.
DEF VAR i-cdagechq          AS INTE                                 NO-UNDO.

DEF  VAR aux_ctpsqitg       AS DEC                                  NO-UNDO.
DEF  VAR aux_nrdctitg LIKE crapass.nrdctitg                         NO-UNDO.
DEF  VAR aux_nrctaass LIKE crapass.nrdconta                         NO-UNDO.
DEF  VAR aux_nrdigitg       AS CHAR                                 NO-UNDO.
DEF  VAR aux_nrcalcul       AS INTE                                 NO-UNDO.
DEF  VAR flg_ctamigra       AS LOG                                  NO-UNDO.
DEF  VAR glb_dsdctitg       AS CHAR                                 NO-UNDO.
DEF  VAR glb_stsnrcal       AS LOGICAL                              NO-UNDO.


/**   Conta Integracao **/
DEF  BUFFER crabass5 FOR crapass.
DEF  VAR glb_cdcooper       AS INT                                  NO-UNDO.     {includes/proc_conta_integracao.i}

PROCEDURE valida-codigo-cheque-valor.

    DEF INPUT PARAM  p-cooper      AS CHAR.
    DEF INPUT PARAM  p-cod-agencia AS INTE.  /* Cod. Agencia       */
    DEF INPUT PARAM  p-nro-caixa   AS INTE FORMAT "999". /* Numero Caixa */   
    DEF INPUT PARAM  p-sequencia   AS INTE. /* sequencia de autenticacao */
    DEF INPUT PARAM  p-cmc-7       AS CHAR.
    DEF INPUT PARAM  p-cmc-7-dig   AS CHAR.

    DEF OUTPUT PARAM p-cdcmpchq    AS INT  FORMAT "zz9". /* Comp */            
    DEF OUTPUT PARAM p-cdbanchq    AS INT  FORMAT "zz9". /* Banco */
    DEF OUTPUT PARAM p-cdagechq    AS INT  FORMAT "zzz9". /* Agencia */
    DEF OUTPUT PARAM p-nrddigc1    AS INT  FORMAT "9". /* C1 */
    DEF OUTPUT PARAM p-nrctabdb    AS DEC  FORMAT "zzz,zzz,zzz,9". /* Conta */
    DEF OUTPUT PARAM p-nrddigc2    AS INT  FORMAT "9". /* C2 */
    DEF OUTPUT PARAM p-nrcheque    AS INT  FORMAT "zzz,zz9". /* Cheque */
    DEF OUTPUT PARAM p-nrddigc3    AS INT  FORMAT "9". /* C3 */
    
      
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-cmc-7 <> " " THEN
         ASSIGN c-cmc-7              = p-cmc-7
                substr(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig. /*<99999999<9999999999>999999999999:*/

    ASSIGN p-cdbanchq = INT(SUBSTRING(c-cmc-7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
       
    ASSIGN p-cdagechq = INT(SUBSTRING(c-cmc-7,05,04)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
 
    ASSIGN  p-cdcmpchq = INT(SUBSTRING(c-cmc-7,11,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
 
    ASSIGN p-nrcheque = INT(SUBSTR(c-cmc-7,14,06)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
                                                 
    ASSIGN de-nrctachq = DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN p-nrctabdb = IF p-cdbanchq = 1 
                        THEN DEC(SUBSTR(c-cmc-7,25,08))
                        ELSE DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    /* Le tabela com as contas convenio do Banco Brasil - Geral */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    ASSIGN aux_nrdctitg = "".
    /**  Conta Integracao **/
    IF   LENGTH(STRING(p-nrctabdb)) <= 8   THEN
         DO:
            ASSIGN aux_ctpsqitg = p-nrctabdb
                   glb_cdcooper = crapcop.cdcooper.
            RUN existe_conta_integracao.  
         END.                    
    
    /* verificar se a folha de cheque é de uma conta migrada *********/
    ASSIGN i_nro-docto  = INTE(STRING(p-nrcheque) + STRING(p-nrddigc3))
           flg_ctamigra = FALSE.

    RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,     /* Nro Cheque       */
                       INPUT-OUTPUT i_nro-talao,     /* Nro Talao        */
                       INPUT-OUTPUT i_posicao,       /* Posicao          */  
                       INPUT-OUTPUT i_nro-folhas).   /* Nro Folhas       */ 

    ASSIGN aux_nrcalcul = INT(SUBSTR(STRING(i_nro-docto, "9999999"),1,6)).  

    /* Validar se a folha de cheque é da cooperativa */
    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = p-cdbanchq         AND
                       crapfdc.cdagechq = p-cdagechq         AND
                       crapfdc.nrctachq = p-nrctabdb         AND
                       crapfdc.nrcheque = INT(aux_nrcalcul)
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapfdc   THEN
         DO:
            /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
            /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
            IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                p-cdbanchq = 756               THEN
            DO:
                /* Localiza se o cheque é de uma conta migrada */
                FIND FIRST craptco WHERE 
                           craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                           craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                           craptco.tpctatrf = 1                AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

                IF  AVAIL craptco  THEN
                DO:
                    /* verifica se o cheque pertence a conta migrada */
                    FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                             crapfdc.cdbanchq = p-cdbanchq       AND
                                             crapfdc.cdagechq = p-cdagechq       AND
                                             crapfdc.nrctachq = p-nrctabdb       AND
                                             crapfdc.nrcheque = INT(aux_nrcalcul)
                                             NO-LOCK NO-ERROR.
                    IF  NOT AVAIL crapfdc  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Cheque nao e da Cooperativa ".                           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.

                END.
            END.
            ELSE 
            /* Se for BB usa a conta ITG para buscar conta migrada */
            /* Usa o nrdctitg = p-nrctabdb na busca da conta */
            IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
            DO:
                /* Formata conta integracao */
                RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal).
                IF   NOT glb_stsnrcal   THEN
                     DO:
                         ASSIGN i-cod-erro  = 8
                                c-desc-erro = " ".           
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.

                /* Localiza se o cheque é de uma conta migrada */
                FIND FIRST craptco WHERE 
                           craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                           craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                           craptco.tpctatrf = 1                AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

                IF  AVAIL craptco  THEN
                DO:
                    /* verifica se o cheque pertence a conta migrada */
                    FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                             crapfdc.cdbanchq = p-cdbanchq       AND
                                             crapfdc.cdagechq = p-cdagechq       AND
                                             crapfdc.nrctachq = p-nrctabdb       AND
                                             crapfdc.nrcheque = INT(aux_nrcalcul)
                                             NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapfdc  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Cheque nao e da Cooperativa ".                           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.

                END.

            END.

         END. 
    ELSE
    DO:
        /* Localiza se o cheque é de uma conta migrada */
        FIND FIRST craptco WHERE 
                   craptco.cdcopant = crapfdc.cdcooper AND 
                   craptco.nrctaant = crapfdc.nrdconta AND
                   craptco.tpctatrf = 1                AND
                   craptco.flgativo = TRUE
                   NO-LOCK NO-ERROR.
        IF  AVAIL craptco  THEN
        DO:
            ASSIGN flg_ctamigra = TRUE.

            FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt          AND
                               craplcm.cdagenci = craptco.cdagenci          AND
                               craplcm.cdbccxlt = 100                       AND /* Fixo */
                               craplcm.nrdolote = 205000 + craptco.cdagenci AND
                               craplcm.nrdctabb = int(p-nrctabdb)           AND
                               craplcm.nrdocmto = i_cheque          
                               USE-INDEX craplcm1 NO-LOCK NO-ERROR.

            IF  AVAIL craplcm  THEN
            DO:
                IF   craplcm.nrautdoc = p-sequencia  THEN
                     DO:
                         ASSIGN i-cod-erro  = 92
                                c-desc-erro = " ".           
                     END.
            END.

        END.

    END.
    /************************************************************************/
       
    /* utilizado a forma acima de validar o cheque 
    IF   ((p-cdbanchq = 1   AND
           p-cdagechq = 3420) AND 
         CAN-DO(aux_lscontas,
                    STRING((INT(SUBSTR(c-cmc-7,25,08))))) ) OR
         (p-cdbanchq = 756 AND
          p-cdagechq = crapcop.cdagebcb) 
        OR
          /* IF CECRED */
         (p-cdbanchq = crapcop.cdbcoctl AND
          p-cdagechq = crapcop.cdagectl)
          /** Conta Integracao **/
          OR
          (aux_nrdctitg <> ""  AND   
           CAN-DO("3420", STRING(p-cdagechq)))    

           THEN                           
         DO:
                 
         END.
    ELSE 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Cheque nao e da Cooperativa ".                           RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END. 
    ******************************/

    /*  Calcula primeiro digito de controle  */
    ASSIGN p-nro-calculado = DECIMAL(STRING(p-cdcmpchq,"999") +
                                     STRING(p-cdbanchq,"999") +
                                     STRING(p-cdagechq,"9999") + "0").
                                  
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
   
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    
    DELETE PROCEDURE h_b2crap00.

    ASSIGN p-nrddigc1 = 
      INT(SUBSTRING(STRING(p-nro-calculado),LENGTH(STRING(p-nro-calculado)))).
                           
    /*  Calcula segundo digito de controle  */
    assign p-nro-calculado =  de-nrctachq * 10.
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.

    ASSIGN p-nrddigc2 =
     INT(SUBSTRING(STRING(p-nro-calculado),LENGTH(STRING(p-nro-calculado)))).   
    
    /*  Calcula terceiro digito de controle  */
    ASSIGN p-nro-calculado = p-nrcheque * 10.
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    FIND FIRST craperr WHERE
               craperr.cdcooper = crapcop.cdcooper     AND
               craperr.cdagenci = int(p-cod-agencia)   AND
               craperr.nrdcaixa = int(p-nro-caixa)     AND
               craperr.cdcritic = 8                    NO-ERROR.

    IF AVAIL craperr THEN 
       DELETE craperr.

    DELETE PROCEDURE h_b2crap00.

    ASSIGN p-nrddigc3 = 
      INT(SUBSTRING(STRING(p-nro-calculado),LENGTH(STRING(p-nro-calculado)))).

    ASSIGN i_cheque  = 
    int(string(p-nrcheque,"999999") + string(p-nrddigc3,"9")). /* Num Cheque */

    IF  NOT flg_ctamigra   THEN
    DO:
        FIND FIRST crapass WHERE
                   crapass.cdcooper = crapcop.cdcooper  AND
                   crapass.nrdconta = INT(p-nrctabdb)   NO-LOCK NO-ERROR.

        IF   AVAIL crapass   THEN
             DO:
                 IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                      DO:
                          FIND FIRST craptrf WHERE
                                     craptrf.cdcooper = crapcop.cdcooper AND
                                     craptrf.nrdconta = crapass.nrdconta AND
                                     craptrf.tptransa = 1 AND
                                     craptrf.insittrs = 2 
                                     USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                          IF   AVAIL craptrf   THEN 
                               ASSIGN p-nrctabdb  = craptrf.nrsconta.
                      END.    
             END.
    END.

    IF  flg_ctamigra  THEN
    DO:
        IF  i-cod-erro > 0  THEN 
        DO:
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    END.
    ELSE
    DO:
        FIND  craplcm WHERE
              craplcm.cdcooper = crapcop.cdcooper  AND
              craplcm.dtmvtolt = crapdat.dtmvtolt  AND
              craplcm.cdagenci = p-cod-agencia     AND
              craplcm.cdbccxlt = 11                AND /* Fixo */
              craplcm.nrdolote = i-nro-lote        AND
              craplcm.nrdctabb = int(p-nrctabdb)   AND
              craplcm.nrdocmto = i_cheque          
              USE-INDEX craplcm1 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN
             DO:
                 IF   craplcm.nrautdoc = p-sequencia  THEN
                      DO:
                          ASSIGN i-cod-erro  = 92
                                 c-desc-erro = " ".           
                          run cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
             END. 
    END.
    
    RETURN "OK".

END procedure.

PROCEDURE critica-autenticacao.
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-sequencia     AS INTE.
    DEF OUTPUT PARAM p-valor         AS DEC.
    DEF OUTPUT PARAM p-histor        AS INTE.
    DEF OUTPUT PARAM p-docto         AS INTE.

    DEF VAR aux_nrseqaut LIKE crapaut.nrseqaut.
    DEF BUFFER crabaut FOR crapaut.
    
      
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN aux_nrseqaut = 0.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND FIRST crapaut WHERE crapaut.cdcooper = crapcop.cdcooper AND
                             crapaut.cdagenci = p-cod-agencia    AND 
                             crapaut.nrdcaixa = p-nro-caixa      AND 
                             crapaut.dtmvtolt = crapdat.dtmvtolt AND 
                             crapaut.nrsequen = p-sequencia  
                             NO-LOCK NO-ERROR.
   
    IF   AVAIL crapaut THEN
         DO:
             IF   crapaut.cdhistor <> 386   THEN
                  DO:
                      ASSIGN i-cod-erro = 0
                             c-desc-erro = 
                               "Essa autenticacao nao e de CHEQUE CAPTURADO".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         
             FOR EACH crabaut WHERE crabaut.cdcooper = crapcop.cdcooper   AND
                                    crabaut.cdagenci = crapaut.cdagenci   AND
                                    crabaut.nrdcaixa = crapaut.nrdcaixa   AND
                                    crabaut.dtmvtolt = crapaut.dtmvtolt   AND
                                    crabaut.nrsequen > crapaut.nrsequen 
                                    NO-LOCK:
      
                 IF   crabaut.nrseqaut = crapaut.nrsequen   THEN 
                      DO:
                          ASSIGN aux_nrseqaut = crabaut.nrseqaut.
                          LEAVE.
                      END.              
             END.
             IF   aux_nrseqaut <> 0   THEN
                  DO:
                      ASSIGN i-cod-erro = 0
                             c-desc-erro = 
                               "ESTORNO ja realizado".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         
          END.
    ELSE
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Sequencia nao encontrada".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN p-valor  = crapaut.vldocmto
           p-histor = crapaut.cdhistor
           p-docto  = crapaut.nrdocmto.  
    
    RETURN "OK".

END PROCEDURE.

/* b1crap78.p */



