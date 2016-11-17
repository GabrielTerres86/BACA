/*** Busca as aplicacoes dos cooperados conforme parametrizacao da cooperativa
***/
/*** definicao da temp-table que estara no programa chamador ***/
DEF TEMP-TABLE tt-acumula NO-UNDO
    FIELD nraplica LIKE craprda.nraplica
    FIELD tpaplica LIKE craprda.tpaplica
    FIELD vlsdrdca LIKE craprda.vlsdrdca.
/***************************************************************/
   
{ sistema/generico/includes/var_internet.i }

DEFINE VARIABLE h-b1wgen05         AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-b1wgen0004       AS HANDLE  NO-UNDO.
DEF BUFFER crablap5 FOR craplap.

DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.

DEF INPUT  PARAM p-cdcooper LIKE crapcop.cdcooper.
DEF INPUT  PARAM p-nrdconta LIKE crapass.nrdconta.
DEF INPUT  PARAM p-tpaplica LIKE craprda.tpaplica.
DEF INPUT  PARAM p-vlaplica LIKE craprda.vlaplica.
DEF OUTPUT PARAM p-vlsdrdca LIKE craprda.vlsdrdca.
DEF OUTPUT PARAM TABLE FOR tt-erro.
DEF OUTPUT PARAM TABLE FOR tt-acumula.

DEF VAR aux_vllanmto like craprda.vlsdrdca.
DEF VAR aux_vllctprv like craprda.vlsdrdca.

/* Variaveis para a include de erros - valores fixos usados na internet */
DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.



DEF        VAR aux_dsmsgerr AS CHAR                                  NO-UNDO.
DEF        VAR aux_sldresga AS DECIMAL                               NO-UNDO.
DEF        VAR aux_ttrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrenrgt AS DECIMAL DECIMALS 8      
          /*  like craprda.vlsdrdca Magui em 27/09/2007 */ NO-UNDO.
DEF        VAR aux_ajtirrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdat AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdresg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllan117 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txapllap AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrdirrf AS DECIMAL                               NO-UNDO.
DEF        VAR aux_perirrgt AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrrgtot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlirftot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrendmm AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrvtfim AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtcalajt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdolote AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_vlajtsld AS DEC                                   NO-UNDO.

DEF        VAR aux_flglanca AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlabcpmf AS DECIMAL                               NO-UNDO.
DEF        VAR aux_flgncalc AS LOGICAL                               NO-UNDO.
DEF        VAR aux_sldcaren AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR dup_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR dup_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR dup_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR dup_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_vlrgtper AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrenper AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_renrgper AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_nrctaapl AS INTEGER FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_nraplres AS INTEGER FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_vlsldapl AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_sldpresg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_dtregapl AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_ttajtlct AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_ttpercrg AS DECIMAL                               NO-UNDO.
DEF        VAR aux_trergtaj AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_perirtab AS DECIMAL     EXTENT 99                 NO-UNDO.

DEF        VAR aux_indebcre AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlsldrdc AS DECI                                  NO-UNDO.
DEF        VAR aux_lsoperad AS CHAR                                  NO-UNDO.
DEF        VAR aux_listahis AS CHAR                                  NO-UNDO.
DEF        VAR aux_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlstotal AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dsaplica AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgslneg AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlrenacu AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlslajir AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_pcajsren AS DECIMAL                               NO-UNDO.
DEF        VAR aux_nrmeses  AS INTEGER                               NO-UNDO.
DEF        VAR aux_nrdias   AS INTEGER                               NO-UNDO.
DEF        VAR aux_perirapl AS DECIMAL                               NO-UNDO.

DEF        VAR rd2_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_vllan178 AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_vllan180 AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtdolote AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtultdia AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtrefant AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR rd2_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR rd2_nrdolote AS INT                                   NO-UNDO.
DEF        VAR rd2_cdhistor AS INT                                   NO-UNDO.
DEF        VAR rd2_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR rd2_nrdiames AS INT                                   NO-UNDO.
DEF        VAR rd2_flgentra AS LOGICAL                               NO-UNDO.
DEF        VAR rd2_lshistor AS CHAR                                  NO-UNDO.
DEF        VAR rd2_contador AS INT                                   NO-UNDO.

/*** Carrega tabela de percentuais de IRRF ***/
DEF VAR aux_qtdfaxir AS INT     FORMAT "z9"             NO-UNDO.
DEF VAR aux_qtmestab AS INTE        EXTENT 99           NO-UNDO. 
DEF VAR aux_cartaxas AS INTE                            NO-UNDO.
DEF VAR aux_vllidtab AS CHAR                            NO-UNDO.

DEF var p-cdprogra      AS CHAR                        NO-UNDO.    
DEF BUFFER crabtab FOR craptab.

DEF        VAR rpp_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlsdrdpp AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan150 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan152 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan158 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR rpp_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtdolote AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtultdia AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR rpp_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR rpp_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR rpp_nrdolote AS INT                                   NO-UNDO.
DEF        VAR rpp_cdhistor AS INT                                   NO-UNDO.
DEF        VAR rpp_vlrirrpp AS DEC                                   NO-UNDO.
DEF        VAR rpp_percenir AS DEC                                   NO-UNDO.

ASSIGN p-vlsdrdca = p-vlaplica.

FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN i-cod-erro = 1 
               c-dsc-erro = " ".
           
        { sistema/generico/includes/b1wgen0001.i }
        RETURN "NOK".

    END.
        
FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
IF  NOT AVAILABLE crapdat  THEN
    DO:
        ASSIGN i-cod-erro = 1 
               c-dsc-erro = " ".
           
        { sistema/generico/includes/b1wgen0001.i }

        RETURN "NOK".
    END. 

FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                   crapass.nrdconta = p-nrdconta   NO-LOCK NO-ERROR.
                   
IF  NOT AVAILABLE crapass  THEN
    DO:
        ASSIGN i-cod-erro = 9 
               c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
                    
FOR EACH crabtab WHERE crabtab.cdcooper = crapcop.cdcooper   AND
                       crabtab.nmsistem = "CRED"             AND
                       crabtab.cdempres = p-tpaplica         AND
                       crabtab.tptabela = "GENERI"           AND
                       crabtab.cdacesso = "SOMAPLTAXA"       NO-LOCK:
    IF   crabtab.tpregist = 1   THEN /* RDCA30 */ 
         FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper   AND
                                craprda.tpaplica = 3                  AND
                                craprda.insaqtot = 0                  AND
                                craprda.cdageass = crapass.cdagenci   AND
                                craprda.nrdconta = crapass.nrdconta   NO-LOCK:
        
               
             { sistema/generico/includes/b1wgen0004.i } 
             IF   aux_vlsdrdca > 0   THEN
                  DO:
                      ASSIGN p-vlsdrdca = p-vlsdrdca + aux_vlsdrdca.
                      CREATE tt-acumula.
                      ASSIGN tt-acumula.nraplica = craprda.nraplica
                             tt-acumula.tpaplica = craprda.tpaplica
                             tt-acumula.vlsdrdca = aux_vlsdrdca.
                  END.  
         END.
    ELSE
    IF   crabtab.tpregist = 2   THEN /* RPP */
         FOR EACH craprpp WHERE craprpp.cdcooper = crapcop.cdcooper   AND
                                craprpp.nrdconta = crapass.nrdconta   AND
                                craprpp.vlsdrdpp > 0                  NO-LOCK:
             { sistema/generico/includes/b1wgen0006.i }
             IF   rpp_vlsdrdpp > 0   THEN
                  DO:
                      ASSIGN p-vlsdrdca = p-vlsdrdca + rpp_vlsdrdpp.
                      CREATE tt-acumula.
                      ASSIGN tt-acumula.nraplica = craprpp.nrctrrpp
                             tt-acumula.tpaplica = 2
                             tt-acumula.vlsdrdca = rpp_vlsdrdpp.
                  END.
         END.
    ELSE
    IF   crabtab.tpregist = 3   THEN /* RDCA60 */
         FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper   AND
                                craprda.tpaplica = 5                  AND
                                craprda.insaqtot = 0                  AND
                                craprda.cdageass = crapass.cdagenci   AND
                                craprda.nrdconta = crapass.nrdconta   NO-LOCK:
             { sistema/generico/includes/b1wgen0004a.i } 
             IF   rd2_vlsdrdca > 0   THEN
                  DO:
                      ASSIGN p-vlsdrdca = p-vlsdrdca + rd2_vlsdrdca.
                      CREATE tt-acumula.
                      ASSIGN tt-acumula.nraplica = craprda.nraplica
                             tt-acumula.tpaplica = craprda.tpaplica
                             tt-acumula.vlsdrdca = rd2_vlsdrdca.
                  END.
         END.
    ELSE
    IF   crabtab.tpregist = 7    THEN /* RDCPRE */
         FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper   AND
                                craprda.tpaplica = 7                  AND
                                craprda.insaqtot = 0                  AND
                                craprda.cdageass = crapass.cdagenci   AND
                                craprda.nrdconta = crapass.nrdconta   NO-LOCK:
             RUN sistema/generico/procedures/b1wgen0004.p 
                 PERSISTENT SET h-b1wgen0004.
                
             IF  NOT VALID-HANDLE(h-b1wgen0004)  THEN
                 NEXT.
                
             FOR EACH tt-erro:
                 DELETE tt-erro.
             END.
                 
             RUN provisao_rdc_pre IN h-b1wgen0004 (INPUT crapcop.cdcooper,
                                                   INPUT craprda.nrdconta,
                                                   INPUT craprda.nraplica,
                                                   INPUT craprda.dtmvtolt,
                                                   INPUT crapdat.dtmvtolt,
                                                   OUTPUT aux_vlsldrdc,
                                                   OUTPUT aux_vllanmto,
                                                   OUTPUT aux_vllctprv,
                                                   OUTPUT TABLE tt-erro).
                     
             IF   RETURN-VALUE = "NOK" THEN
                  DO:
                      DELETE PROCEDURE h-b1wgen0004.
                      NEXT.
                  END.
                   
             ASSIGN p-vlsdrdca = p-vlsdrdca + aux_vlsldrdc.
             CREATE tt-acumula.
             ASSIGN tt-acumula.nraplica = craprda.nraplica
                    tt-acumula.tpaplica = craprda.tpaplica
                    tt-acumula.vlsdrdca = aux_vlsldrdc.
         END.
    ELSE
    IF   crabtab.tpregist = 8    THEN /* RDCPos */
         FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper   AND
                                craprda.tpaplica = 8                  AND
                                craprda.insaqtot = 0                  AND
                                craprda.cdageass = crapass.cdagenci   AND
                                craprda.nrdconta = crapass.nrdconta   NO-LOCK:
             RUN sistema/generico/procedures/b1wgen0004.p 
                 PERSISTENT SET h-b1wgen0004.
                
             IF  NOT VALID-HANDLE(h-b1wgen0004)  THEN
                 NEXT.
                
             FOR EACH tt-erro:
                 DELETE tt-erro.
             END.
                 
             RUN provisao_rdc_pos IN h-b1wgen0004 (INPUT crapcop.cdcooper,
                                                   INPUT craprda.nrdconta,
                                                   INPUT craprda.nraplica,
                                                   INPUT craprda.dtatslmx,
                                                   INPUT crapdat.dtmvtolt,
                                                   INPUT NO, /* TAXA MAXIMA */
                                                   OUTPUT aux_vlsldrdc,
                                                   OUTPUT aux_vllanmto,
                                                   OUTPUT TABLE tt-erro).
            
        
             IF   RETURN-VALUE = "NOK" THEN
                  DO:
                      DELETE PROCEDURE h-b1wgen0004.
                      NEXT.
                  END.
                   
             ASSIGN p-vlsdrdca = p-vlsdrdca + aux_vlsldrdc.
             CREATE tt-acumula.
             ASSIGN tt-acumula.nraplica = craprda.nraplica
                    tt-acumula.tpaplica = craprda.tpaplica
                    tt-acumula.vlsdrdca = aux_vlsldrdc.
         END.
END.                       
                       
