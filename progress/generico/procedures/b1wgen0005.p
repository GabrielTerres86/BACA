/*..............................................................................

   Programa: b1wgen0005.p                  
   Autor   : Junior.
   Data    : 31/10/2005                        Ultima atualizacao: 03/11/2009

   Dados referentes ao programa:

   Objetivo  : CALCULO SALDO PARA RESGATE APLICACAO
               Baseado em fontes/saldo_rdca_resgate.p.

   Alteracoes: 22/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).

               03/08/2007 - Definicoes de temp-tables para include (David).

               27/12/2007 - Retirada do FIND crapcop, pois este nao
                            estava sendo necessario (Julio)
                            
               21/02/2008 - Retirar includes/b1wge0005tt.i (Guilherme).
               
               03/11/2009 - Alterar variáveis internas para parametros de
                            saida (David).
               
..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

PROCEDURE saldo-rdca-resgate.
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaplica AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsldapl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenper AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_pcajsren AS DECI                           NO-UNDO. 
    DEF OUTPUT PARAM par_vlrenreg AS DECI DECIMALS 8                NO-UNDO. 
    DEF OUTPUT PARAM par_vldajtir AS DECI DECIMALS 8                NO-UNDO. 
    DEF OUTPUT PARAM par_sldrgttt AS DECI DECIMALS 8                NO-UNDO.
    DEF OUTPUT PARAM par_vlslajir AS DECI DECIMALS 8                NO-UNDO.
    DEF OUTPUT PARAM par_vlrenacu AS DECI DECIMALS 8                NO-UNDO.
    DEF OUTPUT PARAM par_nrdmeses AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdedias AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dtiniapl AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhisren AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhisajt AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_perirapl AS DECI                           NO-UNDO.    

    DEF INPUT-OUTPUT PARAM par_sldpresg AS DECI                     NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
            
    DEF VAR h-b1wgen0007 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_qtmestab AS INTE EXTENT 99                          NO-UNDO. 
    DEF VAR aux_cartaxas AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdfaxir AS INTE                                    NO-UNDO.

    DEF VAR aux_vllidtab AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_vlrabnir AS DECI                                    NO-UNDO. 
    DEF VAR aux_perirtab AS DECI EXTENT 99                          NO-UNDO.    

    EMPTY TEMP-TABLE tt-erro.
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN aux_cdcritic = 1 
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).  

            RETURN "NOK".
        END. 

    ASSIGN aux_vllidtab = ""
           aux_qtdfaxir = 0
           aux_qtmestab = 0
           aux_perirtab = 0.
       
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND   
                       craptab.cdempres = 0            AND
                       craptab.tptabela = "CONFIG"     AND   
                       craptab.cdacesso = "PERCIRRDCA" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
                       
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       
        ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
               aux_qtdfaxir = aux_qtdfaxir + 1
               aux_qtmestab[aux_qtdfaxir] = DECI(ENTRY(1,aux_vllidtab,"#"))
               aux_perirtab[aux_qtdfaxir] = DECI(ENTRY(2,aux_vllidtab,"#")).

    END.         
    
    FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                       craprda.nrdconta = par_nrdconta AND
                       craprda.nraplica = par_nraplica NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craprda  THEN                   
        DO: 
            ASSIGN aux_cdcritic = 426 
                   aux_dscritic = " ".
             
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic). 
             
            RETURN "NOK".
        END.
    
    IF  craprda.dtmvtolt <= 12/22/2004  THEN
        ASSIGN par_dtiniapl = 07/01/2004.
    ELSE
        ASSIGN par_dtiniapl = craprda.dtmvtolt.
    
    RUN sistema/generico/procedures/b1wgen0007.p PERSISTENT SET h-b1wgen0007.
  
    IF  NOT VALID-HANDLE(h-b1wgen0007)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0007.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    RUN calcmes IN h-b1wgen0007 (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtiniapl,
                                 INPUT par_dtaplica,
                                OUTPUT par_nrdmeses,
                                OUTPUT par_nrdedias,
                                OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0007.
    
    IF  par_nrdmeses = ? OR par_nrdedias  = ?  THEN                   
        DO: 
            ASSIGN aux_cdcritic = 840 
                   aux_dscritic = " ".
             
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic). 
             
            RETURN "NOK".
        END.
    
    IF  craprda.tpaplica = 3  THEN   /* RDCA30 */
        ASSIGN par_cdhisren = 116
               par_cdhisajt = 875.
    ELSE
    IF  craprda.tpaplica = 5   THEN  /* RDCA60 */
        ASSIGN par_cdhisren = 179
               par_cdhisajt = 876.
    
    IF  par_cdhisren = 0  THEN  
        DO:
            ASSIGN aux_cdcritic = 526 
                   aux_dscritic = " ".
             
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic). 
            
            RETURN "NOK".
        END.   
             
    IF  par_nrdmeses <= 6  THEN
        DO:
            IF  par_nrdedias = 0 OR par_nrdmeses < 6  THEN
                ASSIGN par_perirapl = aux_perirtab[1].
        END.              
    
    IF  par_perirapl = 0  THEN
        DO:
            IF  par_nrdmeses >= 6 AND par_nrdmeses <= 12  THEN
                DO:
                    IF  par_nrdedias = 0 OR par_nrdmeses < 12  THEN
                        ASSIGN par_perirapl = aux_perirtab[2].
                END.
        END.

    IF  par_perirapl = 0  THEN
        DO:
            IF  par_nrdmeses >= 12 AND par_nrdmeses <= 24  THEN
                DO:
                    IF  par_nrdedias = 0 OR par_nrdmeses < 24  THEN
                        ASSIGN par_perirapl = aux_perirtab[3].
                END.  
        END.
    
    IF  par_perirapl = 0  THEN          
        ASSIGN par_perirapl = aux_perirtab[4].
    
    IF  par_perirapl = 0 AND par_cdcooper <> 3  THEN      
        DO:
            ASSIGN aux_cdcritic = 180 
                   aux_dscritic = " ".
             
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic). 
             
            RETURN "NOK".
        END.
         
    FIND LAST craplap WHERE craplap.cdcooper = par_cdcooper     AND 
                            craplap.nrdconta = craprda.nrdconta AND
                            craplap.nraplica = craprda.nraplica AND
                            craplap.cdhistor = par_cdhisren     
                            USE-INDEX craplap5 NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE craplap  THEN  
        DO:
            ASSIGN par_sldpresg = par_vlsldapl
                   par_vlslajir = craprda.vlsdrdca.
                   aux_vlrabnir = 0.
    
            IF  ((craprda.dtfimper > crapdat.dtmvtoan    AND
                  craprda.dtfimper <= crapdat.dtmvtolt)  AND 
                  craprda.vlabcpmf > 0)                  OR
                ((par_cdprogra = "crps105"               AND
                 (craprda.dtfimper = crapdat.dtmvtopr)   OR
                 (craprda.dtfimper < crapdat.dtmvtopr    AND
                  craprda.dtfimper > crapdat.dtmvtolt)   AND
                  craprda.vlabcpmf > 0))                 THEN
                ASSIGN aux_vlrabnir = TRUNCATE((craprda.vlabcpmf * 
                                                aux_perirtab[1] / 100),2)
                       par_sldpresg = par_sldpresg - aux_vlrabnir -
                                      TRUNCATE((par_vlrenper * 
                                                aux_perirtab[1] / 100),2).
        END. 
    ELSE     
        DO:
            ASSIGN par_vlslajir = craplap.vlslajir
                   par_vlrenacu = craplap.vlrenacu.
    
            IF  par_vlslajir > 0  THEN       
                DO:
                    ASSIGN par_pcajsren = par_vlsldapl / par_vlslajir * 100.
                    
                    IF  par_pcajsren > 100  THEN        
                        ASSIGN par_pcajsren = 100.
                 
                    ASSIGN aux_vlrabnir = 0.
                    
                    IF  (craprda.dtfimper > crapdat.dtmvtoan    AND
                         craprda.dtfimper <= crapdat.dtmvtolt)  AND 
                         craprda.vlabcpmf > 0                   THEN
                        ASSIGN aux_vlrabnir = TRUNCATE((craprda.vlabcpmf * 
                                                     aux_perirtab[1] / 100),2).
                               
                    ASSIGN par_vlrenreg = par_vlrenacu * par_pcajsren / 100
                           par_vldajtir = TRUNCATE((par_vlrenreg * 
                                                    par_perirapl / 100) -
                                                   (par_vlrenreg * 
                                                    aux_perirtab[4] / 100),2)
                           par_sldpresg = ROUND(par_vlsldapl - 
                                                aux_vlrabnir - par_vldajtir -
                                                TRUNCATE((par_vlrenper * 
                                                     par_perirapl / 100),2),2).

                    IF  par_sldpresg < 0  THEN
                        ASSIGN par_sldpresg = 0.
                                        
                    ASSIGN par_sldrgttt = par_vlsldapl - par_sldpresg -
                                          par_vldajtir.
                END.
        END.  
    
    IF  craprda.tpaplica = 3  THEN /** RDCA30 **/
        ASSIGN par_sldrgttt = 0.

    RETURN "OK".
    
END PROCEDURE.

  
/*...........................................................................*/
    
    
