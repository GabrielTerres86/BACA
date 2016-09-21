/*..............................................................................

    Programa  : b1wgen0022.p
    Autor     : Magui/Guilherme
    Data      : Setembro/2007                  Ultima Atualizacao: 10/10/2013
    
    Dados referentes ao programa:

    Objetivo  : BO referente tarifacao:
                - Tarifacao 2 via cartao magnetico.
                                                              
    Alteracoes: 21/11/2007 - Alterar gera_lancamento para ficar mais generica,
                             incluindo mais parametros(Guilherme).

                03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).
                
                15/05/2013 - Incluso nova estrutura para buscar valor tarifa
                             fornecimento segunda via de cartao magnetico 
                             utilizando b1wgen0153 (Daniel).  

                10/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).                                    
..............................................................................*/

DEF VAR h-b1craplot           AS HANDLE                         NO-UNDO.
DEF VAR h-b1craplcm           AS HANDLE                         NO-UNDO.

DEF TEMP-TABLE cratlot  NO-UNDO  LIKE craplot.
DEF TEMP-TABLE cratlcm  NO-UNDO  LIKE craplcm.

{ sistema/generico/includes/var_internet.i }

PROCEDURE verifica_2via:
        
    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper.
    DEF INPUT  PARAM par_nrdconta LIKE crapcrm.nrdconta.
    DEF INPUT  PARAM par_nrcartao LIKE crapcrm.nrcartao.
    DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt.
    DEF OUTPUT PARAM par_flgtarif AS LOG.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcrm FOR crapcrm.

    DEF VAR aux_sequen   AS INTE NO-UNDO.
    DEF VAR i-cod-erro   AS INTE NO-UNDO.
    DEF VAR c-dsc-erro   AS CHAR NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN par_flgtarif = NO.

    FIND crabcrm WHERE crabcrm.cdcooper = par_cdcooper   AND
                       crabcrm.nrdconta = par_nrdconta   AND
                       crabcrm.nrcartao = par_nrcartao   NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE crabcrm   THEN                   
         DO:
             ASSIGN i-cod-erro = 276 
                    c-dsc-erro = " ".        
             { sistema/generico/includes/b1wgen0001.i }
             RETURN "NOK".
         END.
         
    FOR EACH crapcrm WHERE crapcrm.cdcooper = par_cdcooper   AND      
                           crapcrm.nrdconta = par_nrdconta   NO-LOCK:

        IF   crabcrm.nrcartao = crapcrm.nrcartao   THEN
             NEXT.
        
        IF   crabcrm.tpusucar = crapcrm.tpusucar   THEN
             DO:
                 IF   (crapcrm.cdsitcar = 3 AND crapcrm.dtcancel < 
                                           (par_dtmvtolt - 180))  OR
                      (crapcrm.cdsitcar = 2 AND crapcrm.dtvalcar < 
                                           (par_dtmvtolt - 180)) THEN
                   /*  Despreza cancelados e vencidos ha mais de 180 dias  */
                      NEXT.
             
                 IF   crapcrm.cdsitcar = 3   THEN   /* CANCELADO */
                      DO:
                          IF   crapcrm.dtcancel > par_dtmvtolt - 90   AND
                               crapcrm.dtvalcar > par_dtmvtolt        THEN
                               ASSIGN par_flgtarif = YES.
                      END.
                 ELSE
                      ASSIGN par_flgtarif = YES.
                      
             END.
    END.

END PROCEDURE.

PROCEDURE gera_lancamento:

   DEF INPUT  PARAM par_cdcooper LIKE craplcm.cdcooper             NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt LIKE craplcm.dtmvtolt             NO-UNDO.
   DEF INPUT  PARAM par_cdagenci LIKE craplot.cdagenci             NO-UNDO.
   DEF INPUT  PARAM par_cdbccxlt LIKE craplot.cdbccxlt             NO-UNDO.
   DEF INPUT  PARAM par_nrdolote LIKE craplot.nrdolote             NO-UNDO.
   DEF INPUT  PARAM par_cdoperad LIKE craplot.cdoperad             NO-UNDO.
   DEF INPUT  PARAM par_tplotmov LIKE craplot.tplotmov             NO-UNDO.
   DEF INPUT  PARAM par_nrautdoc LIKE craplcm.nrautdoc             NO-UNDO.
   DEF INPUT  PARAM par_cdhistor LIKE craplcm.cdhistor             NO-UNDO.
   DEF INPUT  PARAM par_nrdocmto LIKE crapneg.nrdocmto             NO-UNDO.
   DEF INPUT  PARAM par_cdpesqbb LIKE craplcm.cdpesqbb             NO-UNDO.
   DEF INPUT  PARAM par_nrdconta LIKE craplcm.nrdconta             NO-UNDO.
   DEF INPUT  PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
   DEF INPUT  PARAM par_cdbanchq LIKE craplcm.cdbanchq             NO-UNDO.
   DEF INPUT  PARAM par_cdagechq LIKE craplcm.cdagechq             NO-UNDO.
   DEF INPUT  PARAM par_nrctachq LIKE craplcm.nrctachq             NO-UNDO.
   
   DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.

   DEF        VAR h-b1wgen0153     AS HANDLE                       NO-UNDO.

   DEF        VAR aux_cdbattar     AS CHAR                         NO-UNDO.
   DEF        VAR aux_cdhisest     AS INTE                         NO-UNDO.
   DEF        VAR aux_dtdivulg     AS DATE                         NO-UNDO.
   DEF        VAR aux_dtvigenc     AS DATE                         NO-UNDO.
   DEF        VAR aux_vllanaut     AS DECIMAL                      NO-UNDO.
   DEF        VAR aux_cdhistor     AS INTE                         NO-UNDO.
   DEF        VAR aux_cdfvlcop     AS INTE                         NO-UNDO.

   FIND crapass WHERE crapass.cdcooper = par_cdcooper      AND
                      crapass.nrdconta = par_nrdconta
                      NO-LOCK NO-ERROR .

   /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
   IF AVAIL crapass THEN
   DO:
       IF crapass.inpessoa = 1 THEN /* Fisica */
            ASSIGN aux_cdbattar = "2VCARMAGPF".
       ELSE
            ASSIGN aux_cdbattar = "2VCARMAGPJ".
   END.
   ELSE
       ASSIGN aux_cdbattar = "2VCARMAGPJ".


   IF NOT VALID-HANDLE(h-b1wgen0153) THEN
       RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

   /*  Busca valor da tarifa de 2 via cartao magnetico*/
   RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT par_cdcooper,
                                     INPUT aux_cdbattar,
                                     INPUT 1,             /* vllanmto */
                                     INPUT "",            /* cdprogra */
                                     OUTPUT aux_cdhistor,
                                     OUTPUT aux_cdhisest,
                                     OUTPUT aux_vllanaut,
                                     OUTPUT aux_dtdivulg,
                                     OUTPUT aux_dtvigenc,
                                     OUTPUT aux_cdfvlcop,
                                     OUTPUT TABLE tt-erro).

   IF  VALID-HANDLE(h-b1wgen0153) THEN
               DELETE PROCEDURE h-b1wgen0153.
    
   IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                par_dscritic = tt-erro.dscritic. 

            RETURN "NOK".
        END.

    IF aux_vllanaut > 0 THEN
    DO:

       /* Incluido find para buscar inprocess */
       FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.
    
       IF NOT VALID-HANDLE(h-b1wgen0153) THEN
           RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
    
       RUN cria_lan_auto_tarifa IN h-b1wgen0153
                               (INPUT par_cdcooper,
                                INPUT par_nrdconta,            
                                INPUT par_dtmvtolt,
                                INPUT aux_cdhistor, 
                                INPUT aux_vllanaut,
                                INPUT par_cdoperad,                     /* cdoperad */
                                INPUT par_cdagenci,                     /* cdagenci */
                                INPUT par_cdbccxlt,                     /* cdbccxlt */         
                                INPUT par_nrdolote,                     /* nrdolote */        
                                INPUT par_tplotmov,                     /* tpdolote */         
                                INPUT par_nrdocmto,                     /* nrdocmto */
                                INPUT par_nrdconta,                     /* nrdctabb */
                                INPUT STRING(par_nrdconta,"99999999"),  /* nrdctitg */
                                INPUT par_cdpesqbb,                     /* cdpesqbb */
                                INPUT par_cdbanchq,                     /* cdbanchq */
                                INPUT par_cdagechq,                     /* cdagechq */
                                INPUT par_nrctachq,                     /* nrctachq */
                                INPUT TRUE,                             /* flgaviso */
                                INPUT 2,                                /* tpdaviso */
                                INPUT aux_cdfvlcop,                     /* cdfvlcop */
                                INPUT crapdat.inproces,                 /* inproces */
                                OUTPUT TABLE tt-erro).
    
                
                IF  VALID-HANDLE(h-b1wgen0153) THEN
                            DELETE PROCEDURE h-b1wgen0153.
                                  
                IF  RETURN-VALUE = "NOK"  THEN
                    DO: 
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                        IF  AVAILABLE tt-erro  THEN
                            par_dscritic = tt-erro.dscritic. 
            
                        RETURN "NOK".
                   END.
    END.

END PROCEDURE.
/* ......................................................................... */
