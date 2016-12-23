
/*** No RDCPOS, quando provisionar e pagar rendimentos a taxa maxima, esta
     comparando a taxa CDI com a taxa POUPANCA e pagando o que for maior.
     Confirmar com a Tavares a seguinte decisao: usar a poupanca do mes
     anterior. Se sim, ver como proceder quando nao existir o dia. Por
     exemplo 31/06. Procurar rotina que calcule datas para tras.  ***/
/*..............................................................................

   Programa: b1wgen0004.p                  
   Autora  : Junior.
   Data    : 12/09/2005                        Ultima atualizacao: 12/08/2010

   Dados referentes ao programa:

   Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
               Baseada no programa fontes/impextrda.p.

   Alteracoes:  19/05/2006 - Incluido codigo da cooperativa nas leituras das
                             tebelas (Diego).

                02/10/2006 - Inclusao da variavel aux_vlajtsld (David).
                
                23/05/2007 - Inclusao das rotinas e variaveis para a modalidade
                             de aplicacoes RDC (Evandro).

                04/09/2007 - Melhor leitura do craplap no extrato_rdc (Magui).

                05/09/2007 - Definicoes de temp-tables para include (David).

                10/09/2007 - Utilizar craprda.qtdiauti para carencia nas 
                             aplicacoes RDC (David).
                
                01/10/2007 - Trabalhar com 4 casas na provisao RDCPOS E
                             RDCPRE (Magui).
                             
                09/10/2007 - Incluida procedure provisao_rdc_pos_var (Diego);
                           - Incluidas variaveis rd2_lshistor e rd2_contador
                             para a melhoria de performance (Evandro).
                             
                25/10/2007 - Inclusao da procedures acumula_aplicacoes (Magui).
                 
                26/11/2007 - Procedure saldo_rdc_pos nao esta atualizando
                             o percentual de imposto de renda (Magui).

                07/01/2008 - Acerto no uso das faixas de IR na procedure 
                             consulta-aplicacoes (David).
                             
                07/01/2008 - Calculo de dias em carencia no rdcpos 
                             com erro (Magui).

                18/01/2007 - Ajustes, resgate negativo (Magui).

                15/02/2008 - Resgate total da Cecred nao estava colocando
                             rendimento (Magui).

                01/03/2008 - Nova formula de calculo rdcpos (Magui).

                03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).
                
                04/07/2008 - provisao_rdc_pos_var usar dtfimper com
                             glb_dtmvtopr, d + 1 (Magui).

                07/08/2008 - Taxa do rendi rdcpre com 8 casas (Magui).
                
                19/09/2008 - Ajustes na maneira de pegar o % de IRRF para
                             o RDCPRE e o RDCPOS (Magui).

                04/12/2008 - Correcao no calculo para acumulo de aplicacoes,
                             nao somar quando tiver resgate agendando (David).
                
                08/01/2009 - Quando RDCPRE para calcular carencia usa-se
                             craprda.qtdiapl (Magui).

                25/05/2009 - Alteracao CDOPERAD (Kbase).

                10/07/2009 - Se taxa RDCPOS for menor que a POUPANCA,
                             usar POUPANCA (Magui).
                             
                12/08/2009 - Na procedure acumula_aplicacoes, alterar o parame-
                             tro p-txaplmes para receber crapftx.perapltx
                             somente para RDCPRE (Fernando).
                          
                17/08/2009 - Alteradas as procedures saldo_rdc_pos, 
                             rendi_apl_pos_com_resgate e provisao_rdc_pos para
                             utilizar a taxa da poupanca quando a taxa RDCPOS
                             for menor (Fernando).
                             
                23/09/2009 - Alteradas as procedures saldo_rdc_pos,
                             rendi_apl_pos_com_resgate e provisao_rdc_pos para
                             criticar caso nao encontre a crapmfx (Fernando).
                             
                09/10/2009 - Implementacao para rotina APLICACOES (David).
                
                12/08/2010 - Ajustada procedure acumula_aplicacoes para nao 
                             estourar variaveis do tipo extent (Elton).

		        07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)
..............................................................................*/
 
{ sistema/generico/includes/b1wgen0004tt_crps414.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEFINE VARIABLE h-b1wgen05         AS HANDLE  NO-UNDO.

DEF BUFFER crablap5 FOR craplap.

DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.

DEF        VAR aux_txmespop AS DECIMAL DECIMALS 6   NO-UNDO.
DEF        VAR aux_txdiapop AS DECIMAL DECIMALS 6   NO-UNDO.
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
DEF        VAR aux_occ      AS INTE                                  NO-UNDO.

DEF        VAR aux_dtcalajt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdolote AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtinitax AS DATE                                  NO-UNDO.
DEF        VAR aux_dtfimtax AS DATE                                  NO-UNDO.
DEF        VAR aux_dtinipop AS DATE                                  NO-UNDO. 

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
DEF        VAR aux_vlrenreg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_dtiniapl AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF        VAR aux_cdhisren LIKE craplap.cdhistor                    NO-UNDO.
DEF        VAR aux_cdhisajt LIKE craplap.cdhistor                    NO-UNDO.
DEF        VAR aux_vldajtir AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF        VAR aux_sldrgttt AS DECIMAL DECIMALS 8                    NO-UNDO.

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

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

/*** Carrega tabela de percentuais de IRRF ***/
DEF VAR aux_qtdfaxir AS INTE        FORMAT "z9"         NO-UNDO.
DEF VAR aux_qtmestab AS INTE        EXTENT 99           NO-UNDO. 
DEF VAR aux_cartaxas AS INTE                            NO-UNDO.
DEF VAR aux_vllidtab AS CHAR                            NO-UNDO.
DEF VAR aux_qtdiatab AS INTE        EXTENT 99           NO-UNDO.


/******************************************************************************/
/**               Procedure para obter aplicacoes do cooperado               **/
/******************************************************************************/
PROCEDURE obtem-dados-aplicacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_vlsldapl AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-saldo-rdca.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-saldo-rdca.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Leitura de aplicacoes RDCA e RDC"
           aux_vlsldapl = 0.

    RUN consulta-aplicacoes (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nrdconta,
                             INPUT par_nraplica,
                             INPUT 0,  
                             INPUT ?,
                             INPUT ?,
                             INPUT par_cdprogra,
                             INPUT par_idorigem,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-saldo-rdca).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel listar as " +
                                          "aplicacoes.".    
                                                     
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).                 
                END.
                       
            IF  par_flgerlog  THEN   
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).        
            
            RETURN "NOK".
        END.
        
    FOR EACH tt-saldo-rdca NO-LOCK:
                        
        ASSIGN aux_vlsldapl = aux_vlsldapl + tt-saldo-rdca.sldresga.

    END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
        
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**        Procedure para verificar permissao de resgate da aplicacao        **/
/******************************************************************************/
PROCEDURE valida-acesso-opcao-resgate:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flcadrgt AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /**********************************************************************/
    /** Essa procedure deve ser utilizada para validar o acesso a opcao  **/
    /** geral de resgate (resgates, cancelamento e proximos), e tambem   **/
    /** sera utilizada para verificar se a aplicacao pode ser resgatada. **/
    /**                                                                  **/
    /** Cadastro de resgate      -> par_flcadrgt = TRUE                  **/
    /** Acesso a "OPCAO" Resgate -> par_flcadrgt = FALSE                 **/
    /**********************************************************************/
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    IF  par_flgerlog  THEN
        ASSIGN aux_dstransa = IF  par_flcadrgt  THEN
                                  "Verifica permissao para resgate da aplicacao"
                              ELSE
                                  "Valida acesso para opcao resgate".

    FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                       craprda.nrdconta = par_nrdconta AND
                       craprda.nraplica = par_nraplica NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craprda  THEN
        DO:
            ASSIGN aux_cdcritic = 426
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.

    IF  craprda.dtmvtolt = par_dtmvtolt  THEN
        DO:
            ASSIGN aux_cdcritic = 834
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".         
        END.

    IF  craprda.tpaplica = 3  THEN
        DO:
            IF  craprda.vlsdrdca = 0.01  THEN
                ASSIGN aux_sldpresg = 0.01.
            ELSE
                RUN saldo-resg-rdca (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_nrdconta,
                                     INPUT par_nraplica,
                                     INPUT par_cdprogra,
                                    OUTPUT aux_vlsdrdca,
                                    OUTPUT aux_sldpresg,
                                    OUTPUT TABLE tt-erro).
        END.
    ELSE
    IF  craprda.tpaplica = 5  THEN
        RUN saldo-resg-rdca (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_nrdconta,
                             INPUT par_nraplica,
                             INPUT par_cdprogra,
                            OUTPUT aux_vlsdrdca,
                            OUTPUT aux_sldpresg,
                            OUTPUT TABLE tt-erro).
    ELSE                
        DO:
            FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper     AND
                               crapdtc.tpaplica = craprda.tpaplica 
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE crapdtc  THEN
                DO:
                    ASSIGN aux_cdcritic = 346
                           aux_dscritic = "".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                   
                    RETURN "NOK".         
                END.

            IF  crapdtc.tpaplrdc = 1  THEN
                ASSIGN aux_sldpresg = craprda.vlsdrdca.
            ELSE
            IF  crapdtc.tpaplrdc = 2  THEN
                DO:
                    RUN saldo_rgt_rdc_pos (INPUT par_cdcooper,
                                           INPUT craprda.nrdconta,
                                           INPUT craprda.nraplica,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtolt,
                                           INPUT 0,
                                          OUTPUT aux_sldpresg,
                                          OUTPUT aux_vlrenrgt,
                                          OUTPUT aux_vlrdirrf,
                                          OUTPUT aux_perirrgt,
                                          OUTPUT aux_vlrrgtot,
                                          OUTPUT aux_vlirftot,
                                          OUTPUT aux_vlrendmm,
                                          OUTPUT aux_vlrvtfim,
                                          OUTPUT TABLE tt-erro).
                    
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                            IF  AVAILABLE tt-erro  THEN
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel " +
                                                          "acessar a opcao.".
                                                          
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,  /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic). 
                                END.
                       
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).       
            
                            RETURN "NOK".
                        END.

                    ASSIGN aux_sldpresg = IF  aux_vlrrgtot > 0  THEN
                                              aux_vlrrgtot
                                          ELSE
                                              craprda.vlsdrdca.
                END.
        END.
        
    IF  par_flcadrgt  THEN
        DO:
            /** Verifica se a aplicacao esta Bloqueada **/
            FIND FIRST craptab WHERE 
                       craptab.cdcooper = par_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "BLQRGT"           AND
                       craptab.cdempres = 0                  AND
                       craptab.cdacesso = 
                               STRING(craprda.nrdconta,"9999999999") AND
                       INTE(SUBSTR(craptab.dstextab,1,7)) =
                               craprda.nraplica              NO-LOCK NO-ERROR.

            IF  AVAILABLE craptab  THEN
                DO:
                    ASSIGN aux_cdcritic = 669
                           aux_dscritic = "".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                   
                    RETURN "NOK".           
                END.    
        END.
        
    IF  aux_sldpresg < 0 OR (par_flcadrgt AND aux_sldpresg = 0)  THEN
        DO:  
            ASSIGN aux_cdcritic = IF par_flcadrgt THEN 428 ELSE 717
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".          
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**        Procedure para obter resgates programados para a aplicacao        **/
/******************************************************************************/
PROCEDURE obtem-resgates-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcance AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-resg-aplica.

    EMPTY TEMP-TABLE tt-resg-aplica.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem resgates da aplicacao".

    FOR EACH craplrg WHERE craplrg.cdcooper = par_cdcooper  AND 
                           craplrg.nrdconta = par_nrdconta  AND
                           craplrg.nraplica = par_nraplica  AND
                          (craplrg.inresgat = 0             OR
                           craplrg.inresgat = 2             OR
                           craplrg.dtmvtolt = par_dtmvtolt) NO-LOCK:
                       
        IF  par_flgcance AND craplrg.inresgat = 3  THEN 
            NEXT.
          
        IF  NOT (craplrg.inresgat = 2 AND par_flgcance)  THEN
            DO:    
                FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                                   crapope.cdoperad = craplrg.cdoperad   
                                   NO-LOCK NO-ERROR.
   
                CREATE tt-resg-aplica.
                ASSIGN tt-resg-aplica.dtresgat = craplrg.dtresgat
                       tt-resg-aplica.nrdocmto = craplrg.nrdocmto
                       tt-resg-aplica.tpresgat = IF  craplrg.tpresgat = 1  THEN
                                                     "Parcial"
                                                 ELSE
                                                 IF  craplrg.tpresgat = 2  THEN
                                                     "Total"
                                                 ELSE
                                                 IF  craplrg.tpresgat = 3  THEN
                                                     "Antecipado"
                                                 ELSE
                                                 IF  craplrg.tpresgat = 4  THEN
                                                     "Parc. Dia"
                                                 ELSE
                                                 IF  craplrg.tpresgat = 5  THEN
                                                     "Total Dia"
                                                 ELSE
                                                     "Antec. Dia"
                       tt-resg-aplica.dsresgat = IF  craplrg.inresgat = 0  THEN
                                                     "Nao Resg." 
                                                 ELSE
                                                 IF  craplrg.inresgat = 1  THEN
                                                     "Resgatado"
                                                 ELSE 
                                                 IF  craplrg.inresgat = 3  THEN
                                                     "Estornado"
                                                 ELSE     
                                                     "Cancelado"
                       tt-resg-aplica.nmoperad = IF  AVAILABLE crapope  THEN
                                                     ENTRY(1,crapope.nmoperad,
                                                           " ")
                                                 ELSE                        
                                                     "INEXISTENTE"
                       tt-resg-aplica.hrtransa = STRING(craplrg.hrtransa,
                                                        "HH:MM")
                       tt-resg-aplica.vllanmto = craplrg.vllanmto.
            END.   
            
    END. /** Fim do FOR EACH craplrg **/

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**               Procedure para cancelar resgate de aplicacao               **/
/******************************************************************************/
PROCEDURE cancelar-resgates-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_indabono AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vlmoefix AS DECI DECIMALS 8                         NO-UNDO.
    DEF VAR aux_vlorimfx AS DECI DECIMALS 8                         NO-UNDO.
    DEF VAR aux_txcpmfcc AS DECI                                    NO-UNDO.  
    DEF VAR aux_txiofrda AS DECI                                    NO-UNDO.
      
    DEF VAR aux_dtiniabo AS DATE                                    NO-UNDO.   
    DEF VAR aux_dtinipmf AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimpmf AS DATE                                    NO-UNDO.
    DEF VAR aux_dtiniiof AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimiof AS DATE                                    NO-UNDO.
     
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF BUFFER crablot FOR craplot.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar resgate da aplicacao"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRCPMFCCR" AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 641.
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.
 
    ASSIGN aux_dtinipmf = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           aux_dtfimpmf = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           aux_txcpmfcc = IF  par_dtmvtolt >= aux_dtinipmf  AND
                              par_dtmvtolt <= aux_dtfimpmf  THEN
                              DECI(SUBSTR(craptab.dstextab,23,13))
                          ELSE 
                              0
           aux_indabono = INTE(SUBSTR(craptab.dstextab,51,1))  
           aux_dtiniabo = DATE(INTE(SUBSTR(craptab.dstextab,56,2)),
                               INTE(SUBSTR(craptab.dstextab,53,2)),
                               INTE(SUBSTR(craptab.dstextab,59,4))). 
                               
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRIOFRDCA" AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.
                
    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 626.
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.
 
    ASSIGN aux_dtiniiof = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           aux_dtfimiof = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           aux_txiofrda = IF  par_dtmvtolt >= aux_dtiniiof  AND
                              par_dtmvtolt <= aux_dtfimiof  THEN
                              DECI(SUBSTR(craptab.dstextab,23,16))
                          ELSE 
                              0.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
                       
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
    
            FIND craplrg WHERE craplrg.cdcooper = par_cdcooper AND
                               craplrg.nrdconta = par_nrdconta AND
                               craplrg.nraplica = par_nraplica AND
                               craplrg.nrdocmto = par_nrdocmto AND
                               craplrg.dtresgat = par_dtresgat
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
            IF  NOT AVAILABLE craplrg  THEN
                DO:
                    IF  LOCKED craplrg  THEN
                        DO:
                            ASSIGN aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 730.
                END.        
                
            LEAVE.
                      
        END. /** Fim do DO ... TO **/
        
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
                        
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND craplot WHERE craplot.cdcooper = par_cdcooper     AND 
                               craplot.dtmvtolt = craplrg.dtmvtolt AND
                               craplot.cdagenci = 99               AND
                               craplot.cdbccxlt = 400              AND
                               craplot.nrdolote = 999
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN aux_cdcritic = 84.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 60.
                END.          

            LEAVE.
                              
        END. /** Fim do DO ... TO **/
                               
        IF  aux_cdcritic > 0  THEN                       
            UNDO TRANSACAO, LEAVE TRANSACAO.
                         
        ASSIGN craplot.qtcompln = craplot.qtcompln - 1
               craplot.qtinfoln = craplot.qtinfoln - 1
               craplot.vlcompdb = craplot.vlcompdb - craplrg.vllanmto
               craplot.vlinfodb = craplot.vlinfodb - craplrg.vllanmto
               craplrg.inresgat = IF  craplrg.dtresgat = par_dtmvtolt  AND
                                      craplrg.tpaplica = 3             THEN
                                      3   /** Estornado **/
                                  ELSE     
                                      2   /** Cancelado **/
               craplrg.cdoperad = par_cdoperad
               craplrg.hrtransa = TIME.
        
        /********************************************************************/
        /** Cancelamento do resgate on-line - Lancamento na conta-corrente **/
        /********************************************************************/
        
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 8474
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN aux_cdcritic = 84.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            IF  par_dtmvtolt = aux_datdodia  THEN
                                ASSIGN aux_cdcritic = 60.
                            ELSE
                                DO:
                                    ASSIGN aux_flgtrans = TRUE.
                                    LEAVE TRANSACAO.
                                END.
                        END.         
                END.
               
            LEAVE.
                          
        END. /** Fim do DO ... TO **/
        
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        DO aux_contador = 1 TO 10:
                
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                           
            FIND craplcm WHERE craplcm.cdcooper = par_cdcooper     AND
                               craplcm.dtmvtolt = craplot.dtmvtolt AND
                               craplcm.cdagenci = craplot.cdagenci AND
                               craplcm.cdbccxlt = craplot.cdbccxlt AND
                               craplcm.nrdolote = craplot.nrdolote AND
                               craplcm.nrdctabb = craplrg.nrdconta AND
                               craplcm.nrdocmto = craplrg.nrdocmto
                               USE-INDEX craplcm1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
            IF  NOT AVAILABLE craplcm  THEN
                DO:
                    IF  LOCKED craplcm  THEN
                        DO:
                            ASSIGN aux_cdcritic = 114.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                           craplot.qtinfoln = craplot.qtinfoln - 1
                           craplot.vlcompcr = craplot.vlcompcr -
                                              craplcm.vllanmto
                           craplot.vlinfocr = craplot.vlinfocr - 
                                              craplcm.vllanmto.

                    DELETE craplcm.
                END.

            LEAVE.
            
        END. /** Fim do DO ... TO **/
        
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
            
        IF  craplot.qtcompln = 0  AND
            craplot.qtinfoln = 0  AND
            craplot.vlcompdb = 0  AND
            craplot.vlinfodb = 0  AND
            craplot.vlcompcr = 0  AND
            craplot.vlinfocr = 0  THEN
            DELETE craplot.
                                          
        /** Lancamento do resgate **/
        DO aux_contador = 1 TO 10:
         
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 8382
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN aux_cdcritic = 84.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 60.
                END.
                                    
            LEAVE.
                                          
        END. /** Fim do DO ... TO **/
                                          
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
           
        DO aux_contador = 1 TO 10:
              
            FIND craplap WHERE craplap.cdcooper = par_cdcooper     AND
                               craplap.dtmvtolt = craplot.dtmvtolt AND
                               craplap.cdagenci = craplot.cdagenci AND
                               craplap.cdbccxlt = craplot.cdbccxlt AND
                               craplap.nrdolote = craplot.nrdolote AND
                               craplap.nrdconta = craplrg.nrdconta AND
                               craplap.nrdocmto = craplrg.nrdocmto   
                               USE-INDEX craplap1 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE craplap  THEN
                DO:
                    IF  LOCKED craplap  THEN
                        DO:
                            ASSIGN aux_cdcritic = 114.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            IF  craplot.qtcompln = 0  AND
                                craplot.qtinfoln = 0  AND
                                craplot.vlcompcr = 0  AND
                                craplot.vlinfocr = 0  AND
                                craplot.vlcompdb = 0  AND
                                craplot.vlinfodb = 0  THEN
                                DELETE craplot.
                                
                            ASSIGN aux_flgtrans = TRUE.    
                                
                            LEAVE TRANSACAO.
                        END.
                END.
                   
            LEAVE.
                             
        END. /** Fim do DO ... TO **/                     
        
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
            
        ASSIGN craplot.qtcompln = craplot.qtcompln - 1
               craplot.qtinfoln = craplot.qtinfoln - 1
               craplot.vlcompdb = craplot.vlcompdb - craplap.vllanmto
               craplot.vlinfodb = craplot.vlinfodb - craplap.vllanmto.
                       
        DO aux_contador = 1 TO 10:
                        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                               
            FIND craprda WHERE craprda.cdcooper = par_cdcooper     AND 
                               craprda.nrdconta = craplrg.nrdconta AND
                               craprda.nraplica = craplrg.nraplica         
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
            IF  NOT AVAILABLE craprda  THEN 
                DO:       
                    IF  LOCKED craprda  THEN
                        DO:
                            ASSIGN aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                END.
                
            LEAVE.
                
        END. /** Fim do DO ... TO **/
                
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
                
        IF  AVAILABLE craprda  THEN
            DO:
                /******************************************************/
                /** Cancelar saldo resgatado para a Cta.Investimento **/
                /******************************************************/
                IF  craprda.flgctain      AND   /** Nova aplicacao        **/  
                    NOT craplrg.flgcreci  THEN  /** Somente Transferencia **/
                    DO:
                        DO aux_contador = 1 TO 10:

                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".

                            FIND crablot WHERE 
                                 crablot.cdcooper = par_cdcooper AND
                                 crablot.dtmvtolt = par_dtmvtolt AND
                                 crablot.cdagenci = 1            AND
                                 crablot.cdbccxlt = 100          AND
                                 crablot.nrdolote = 10105   
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                 
                            IF  NOT AVAILABLE crablot THEN
                                DO:
                                    IF  LOCKED crablot  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 84.
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
        
                            LEAVE.
        
                        END. /** Fim do DO ... TO **/
        
                        IF  aux_cdcritic > 0  THEN
                            UNDO TRANSACAO, LEAVE TRANSACAO.

                        IF  AVAILABLE crablot  THEN
                            DO:
                                DO aux_contador = 1 TO 10:
        
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "".
                
                                    FIND craplci WHERE 
                                         craplci.cdcooper = par_cdcooper     AND
                                         craplci.dtmvtolt = crablot.dtmvtolt AND
                                         craplci.cdagenci = crablot.cdagenci AND
                                         craplci.cdbccxlt = crablot.cdbccxlt AND
                                         craplci.nrdolote = crablot.nrdolote AND
                                         craplci.nrdconta = craplrg.nrdconta AND
                                         craplci.nrdocmto = craplrg.nrdocmto 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                                    IF  NOT AVAILABLE craplci  THEN
                                        DO:
                                            IF  LOCKED craplci  THEN
                                                DO: 
                                                    ASSIGN aux_cdcritic = 114.
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                        END.
                
                                    LEAVE.
                
                                END. /** Fim do DO ... TO **/
                        
                                IF  aux_cdcritic > 0  THEN
                                    UNDO TRANSACAO, LEAVE TRANSACAO. 

                                IF  AVAILABLE craplci  THEN
                                    DO:
                                        ASSIGN crablot.qtinfoln = 
                                                       crablot.qtinfoln - 1
                                               crablot.qtcompln = 
                                                       crablot.qtcompln - 1
                                               crablot.vlinfodb = 
                                                       crablot.vlinfodb - 
                                                       craplci.vllanmto
                                               crablot.vlcompdb = 
                                                       crablot.vlcompdb - 
                                                       craplci.vllanmto.
                
                                        DELETE craplci.
                                    END.
        
                                IF  crablot.qtcompln = 0  AND
                                    crablot.qtinfoln = 0  AND
                                    crablot.vlcompdb = 0  AND
                                    crablot.vlinfodb = 0  AND
                                    crablot.vlcompcr = 0  AND
                                    crablot.vlinfocr = 0  THEN
                                    DELETE crablot.
                            END.
        
                        DO aux_contador = 1 TO 10:
        
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".
        
                            FIND crablot WHERE 
                                 crablot.cdcooper = par_cdcooper AND
                                 crablot.dtmvtolt = par_dtmvtolt AND
                                 crablot.cdagenci = 1            AND
                                 crablot.cdbccxlt = 100          AND
                                 crablot.nrdolote = 10104   
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                         
                            IF  NOT AVAILABLE crablot THEN
                                DO:
                                    IF  LOCKED crablot  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 84.
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
        
                            LEAVE.
        
                        END. /** Fim do DO ... TO **/
        
                        IF  aux_cdcritic > 0  THEN
                            UNDO TRANSACAO, LEAVE TRANSACAO.

                        IF  AVAILABLE crablot  THEN
                            DO:
                                DO aux_contador = 1 TO 10:
                
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "".
                
                                    FIND craplci WHERE 
                                         craplci.cdcooper = par_cdcooper     AND
                                         craplci.dtmvtolt = crablot.dtmvtolt AND
                                         craplci.cdagenci = crablot.cdagenci AND
                                         craplci.cdbccxlt = crablot.cdbccxlt AND
                                         craplci.nrdolote = crablot.nrdolote AND
                                         craplci.nrdconta = craplrg.nrdconta AND
                                         craplci.nrdocmto = craplrg.nrdocmto 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                                    IF  NOT AVAILABLE craplci  THEN
                                        DO:
                                            IF  LOCKED craplci  THEN
                                                DO: 
                                                    ASSIGN aux_cdcritic = 114.
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                        END.
                
                                    LEAVE.
                
                                END. /** Fim do DO ... TO **/
                                
                                IF  aux_cdcritic > 0  THEN
                                    UNDO TRANSACAO, LEAVE TRANSACAO.    

                                IF  AVAILABLE craplci  THEN
                                    DO:
                                        ASSIGN crablot.qtinfoln = 
                                                       crablot.qtinfoln - 1
                                               crablot.qtcompln = 
                                                       crablot.qtcompln - 1
                                               crablot.vlinfocr = 
                                                       crablot.vlinfocr - 
                                                       craplci.vllanmto
                                               crablot.vlcompcr = 
                                                       crablot.vlcompcr - 
                                                       craplci.vllanmto.
                        
                                        DELETE craplci.                        
                                    END.       
                                                                     
                                IF  crablot.qtcompln = 0  AND
                                    crablot.qtinfoln = 0  AND
                                    crablot.vlcompdb = 0  AND
                                    crablot.vlinfodb = 0  AND
                                    crablot.vlcompcr = 0  AND
                                    crablot.vlinfocr = 0  THEN
                                    DELETE crablot.    
                            END.
        
                        FIND CURRENT crablot NO-LOCK NO-ERROR.
                    END.
        
                IF  craplrg.flgcreci  THEN  /** Saldo CI **/
                    DO:                                   
                        DO aux_contador = 1 TO 10:
        
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".
        
                            FIND crablot WHERE 
                                 crablot.cdcooper = par_cdcooper AND 
                                 crablot.dtmvtolt = par_dtmvtolt AND
                                 crablot.cdagenci = 1            AND
                                 crablot.cdbccxlt = 100          AND
                                 crablot.nrdolote = 10106  
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                            IF  NOT AVAILABLE crablot THEN
                                DO:
                                    IF  LOCKED crablot  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 84.
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
        
                            LEAVE.
        
                        END. /** Fim do DO ... TO **/
        
                        IF  aux_cdcritic > 0  THEN
                            UNDO TRANSACAO, LEAVE TRANSACAO.
        
                        IF  AVAILABLE crablot  THEN
                            DO:
                                DO aux_contador = 1 TO 10:
                
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "".
                
                                    FIND craplci WHERE 
                                         craplci.cdcooper = par_cdcooper     AND
                                         craplci.dtmvtolt = crablot.dtmvtolt AND
                                         craplci.cdagenci = crablot.cdagenci AND
                                         craplci.cdbccxlt = crablot.cdbccxlt AND
                                         craplci.nrdolote = crablot.nrdolote AND
                                         craplci.nrdconta = craplrg.nrdconta AND
                                         craplci.nrdocmto = craplrg.nrdocmto 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                                    IF  NOT AVAILABLE craplci  THEN
                                        DO:
                                            IF  LOCKED craplci  THEN
                                                DO: 
                                                    ASSIGN aux_cdcritic = 114.
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                        END.
                
                                    LEAVE.
                
                                END. /** Fim do DO ... TO **/
                                
                                IF  aux_cdcritic > 0  THEN
                                    UNDO TRANSACAO, LEAVE TRANSACAO.   

                                IF  AVAILABLE craplci  THEN
                                    DO:
                                        ASSIGN crablot.qtinfoln = 
                                                       crablot.qtinfoln - 1
                                               crablot.qtcompln = 
                                                       crablot.qtcompln - 1
                                               crablot.vlinfocr = 
                                                       crablot.vlinfocr - 
                                                       craplci.vllanmto
                                               crablot.vlcompcr = 
                                                       crablot.vlcompcr - 
                                                       craplci.vllanmto.
                        
                                        DO aux_contador = 1 TO 10:
                        
                                            ASSIGN aux_cdcritic = 0
                                                   aux_dscritic = "".
                                 
                                            FIND crapsli WHERE 
                                                 crapsli.cdcooper  = 
                                                   par_cdcooper        AND
                                                 crapsli.nrdconta  = 
                                                   craplrg.nrdconta    AND
                                           MONTH(crapsli.dtrefere) = 
                                                   MONTH(par_dtmvtolt) AND
                                            YEAR(crapsli.dtrefere) = 
                                                   YEAR(par_dtmvtolt)
                                                 EXCLUSIVE-LOCK NO-ERROR 
                                                 NO-WAIT.
                                                            
                                            IF  NOT AVAILABLE crapsli  THEN
                                                DO:
                                                    IF  LOCKED crapsli  THEN
                                                        DO:
                                                            aux_cdcritic = 341.
                                                            PAUSE 1 NO-MESSAGE.
                                                            NEXT.
                                                        END.
                                                END.
                                            ELSE
                                                ASSIGN crapsli.vlsddisp = 
                                                             crapsli.vlsddisp -
                                                             craplci.vllanmto.

                                            LEAVE.
                        
                                        END. /** Fim do DO ... TO **/
                        
                                        IF  aux_cdcritic > 0  THEN
                                            UNDO TRANSACAO, LEAVE TRANSACAO.
                                        
                                        DELETE craplci.
                                    END.      

                                IF  crablot.qtcompln = 0  AND
                                    crablot.qtinfoln = 0  AND
                                    crablot.vlcompdb = 0  AND
                                    crablot.vlinfodb = 0  AND
                                    crablot.vlcompcr = 0  AND
                                    crablot.vlinfocr = 0  THEN
                                    DELETE crablot.
                            END.

                        FIND CURRENT crablot NO-LOCK NO-ERROR.
                        FIND CURRENT crapsli NO-LOCK NO-ERROR.
                    END.
                     
                /** Leitura do valor da UFIR para o dia do resgate **/
                FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper AND
                                   crapmfx.dtmvtolt = par_dtmvtolt AND
                                   crapmfx.tpmoefix = 2            
                                   NO-LOCK NO-ERROR.
              
                IF  NOT AVAILABLE crapmfx   THEN
                    DO:
                        ASSIGN aux_cdcritic = 211.
                        
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
        
                ASSIGN aux_vlmoefix = crapmfx.vlmoefix.
                             
                /** Leitura do valor da UFIR do dia da aplicacao **/
                FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper     AND
                                   crapmfx.dtmvtolt = craprda.dtmvtolt AND
                                   crapmfx.tpmoefix = 2                
                                   NO-LOCK NO-ERROR.
               
                IF  NOT AVAILABLE crapmfx  THEN
                    DO:
                        ASSIGN aux_cdcritic = 211.
        
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
        
                ASSIGN aux_vlorimfx = crapmfx.vlmoefix.
        
                IF  craplap.cdhistor = 118 OR craplap.cdhistor = 492  THEN
                    ASSIGN craprda.vlrgtacu = craprda.vlrgtacu - 
                                              craplap.vllanmto
                           craprda.qtrgtmfx = craprda.qtrgtmfx - 
                                   ROUND(craplap.vllanmto / aux_vlmoefix,4).
                ELSE
                    ASSIGN craprda.vlrgtacu = craprda.vlrgtacu - 
                                              craplap.vllanmto
                           craprda.qtrgtmfx = craprda.qtrgtmfx - 
                                   ROUND(craplap.vllanmto / aux_vlorimfx,4)
                           craprda.vlsdrdca = craprda.vlsdrdca + 
                                              craplap.vllanmto
                           craprda.vlabcpmf = 
                                       IF aux_indabono  = 0                AND
                                          aux_dtiniabo <= craprda.dtmvtolt THEN
                                          craprda.vlabcpmf +
                                          TRUNCATE(craplap.vllanmto * 
                                                   aux_txcpmfcc,2)
                                       ELSE 
                                          craprda.vlabcpmf
                           craprda.vlabdiof = 
                                       IF aux_indabono  = 0                AND
                                          aux_dtiniabo <= craprda.dtmvtolt THEN
                                          craprda.vlabdiof +
                                          TRUNCATE(craplap.vllanmto * 
                                                   aux_txiofrda,2)
                                       ELSE 
                                          craprda.vlabdiof.
            END.

        DELETE craplap.

        DO aux_contador = 1 TO 10:
                        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                               
            FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper     AND
                                     craplap.dtmvtolt = craplot.dtmvtolt AND
                                     craplap.cdagenci = craplot.cdagenci AND
                                     craplap.cdbccxlt = craplot.cdbccxlt AND
                                     craplap.nrdolote = craplot.nrdolote AND
                                     craplap.nrdconta = craplrg.nrdconta AND
                                     craplap.nraplica = craplrg.nraplica AND
                                     craplap.cdhistor = 875              AND
                                     craplap.nrdocmto = craplrg.nrdocmto 
                                                        + 888000           
                                     USE-INDEX craplap1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
            IF  NOT AVAILABLE craplap  THEN 
                DO:       
                    IF  LOCKED craplap  THEN
                        DO:
                            ASSIGN aux_cdcritic = 114.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                           craplot.qtinfoln = craplot.qtinfoln - 1
                           craplot.vlcompdb = craplot.vlcompdb - 
                                              craplap.vllanmto
                           craplot.vlinfodb = craplot.vlinfodb - 
                                              craplap.vllanmto.

                    DELETE craplap.
                END.     
                                
            LEAVE.
                
        END. /** Fim do DO ... TO **/
                
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        IF  craplot.qtcompln = 0  AND
            craplot.qtinfoln = 0  AND
            craplot.vlcompcr = 0  AND
            craplot.vlinfocr = 0  AND
            craplot.vlcompdb = 0  AND
            craplot.vlinfodb = 0  THEN
            DELETE craplot.

        FIND CURRENT craplrg NO-LOCK NO-ERROR.
        FIND CURRENT craprda NO-LOCK NO-ERROR.
        FIND CURRENT craplot NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            ELSE
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                    ELSE            
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Erro na transacao. Nao " +
                                                  "foi possivel cancelar o " +
                                                  "resgate.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,          /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
                END.

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nraplica",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nraplica,
                                                        "zzz,zzz,zzz"))).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "dtresgat",
                                             INPUT "",
                                             INPUT STRING(par_dtresgat,
                                                          "99/99/9999")).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrdocmto",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrdocmto,
                                                        "zzz,zzz,zzz,zzz"))).
                END.

            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nraplica",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nraplica,
                                                "zzz,zzz,zzz"))).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtresgat",
                                     INPUT "",
                                     INPUT STRING(par_dtresgat,
                                                  "99/99/9999")).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrdocmto",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrdocmto,
                                                "zzz,zzz,zzz,zzz"))).
        END.

    RETURN "OK".           

END PROCEDURE.


/******************************************************************************/
/**              Procedure para cadastrar resgate de aplicacao               **/
/******************************************************************************/
PROCEDURE cadastrar-resgate-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpresgat AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlresgat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctain AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flmensag AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdaplrg AS INTE                                    NO-UNDO.
    DEF VAR aux_tpresgat AS INTE                                    NO-UNDO.
    
    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.
    
    /**********************************************************************/
    /** A procedure deve ser chamada duas vezes. Na primeira retorna     **/
    /** mensagens de confirmacao e/ou aviso. Entao na segunda chamada    **/
    /** sera cadastrado o resgate. As validacoes serao executadas nas    **/
    /** duas chamadas.                                                   **/
    /**                                                                  **/
    /** Primeira chamada -> par_flmensag = TRUE                          **/
    /** Segunda chamada  -> par_flmensag = FALSE                         **/
    /**                                                                  **/
    /** A consulta dos registros craprda e crapdtc eh feita na procedure **/
    /** valida-acesso-opcao-resgate. O saldo para resgate eh calculcado  **/
    /** nessa procedure.                                                 **/
    /**********************************************************************/

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cadastrar resgate da aplicacao"
           aux_cdcritic = 0
           aux_dscritic = "".

    RUN valida-acesso-opcao-resgate (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT par_idorigem,
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT par_nraplica,
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdprogra,
                                     INPUT TRUE,
                                     INPUT FALSE,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel cadastrar o " +
                                          "resgate.".
                                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,          /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).                 
                END.
                                          
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
               
            RETURN "NOK".       
        END.

    DO WHILE TRUE:

        IF  NOT CAN-DO("P,T",par_tpresgat)  THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de resgate invalido.".
                LEAVE.
            END.

        IF  par_tpresgat = "P" AND par_vlresgat <= 0  THEN
            DO:
                ASSIGN aux_dscritic = "Informe o valor para resgate.".
                LEAVE.
            END.
    
        IF  par_tpresgat = "P"  THEN
            DO:
                IF  par_vlresgat >= aux_sldpresg  THEN
                    DO:
                        ASSIGN aux_cdcritic = 269.
                        LEAVE.
                    END.
                                                            
                IF  AVAILABLE crapdtc                                AND
                   (aux_sldpresg - par_vlresgat) < crapdtc.vlminapl  THEN
                    DO:
                        ASSIGN aux_dscritic = "Saldo da aplicacao nao pode " +
                                              "ser inferior a R$" +
                                              TRIM(STRING(crapdtc.vlminapl,
                                                          "zzz,zzz,zz9.99")).
                        LEAVE.
                    END.
            END.

        IF  par_dtresgat = ?  THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.

        IF  par_dtresgat > (par_dtmvtolt + 90)  THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.

        IF  craprda.tpaplica = 3 AND par_dtresgat < par_dtmvtolt  THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.
                 
        IF  craprda.tpaplica = 5          AND 
           (par_dtresgat <  par_dtmvtopr  OR 
            par_dtresgat <= par_dtmvtolt) THEN    
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.
                   
        IF  AVAILABLE crapdtc                AND
           (par_dtresgat < par_dtmvtolt      OR 
            par_dtresgat > craprda.dtvencto) THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.
                     
        IF  AVAILABLE crapdtc AND par_dtresgat = craprda.dtvencto  THEN
            DO:
                ASSIGN aux_cdcritic = 907.
                LEAVE.
            END.
               
        FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND 
                           crapfer.dtferiad = par_dtresgat NO-LOCK NO-ERROR.
                        
        IF  AVAILABLE crapfer                                OR
            CAN-DO("1,7",STRING(WEEKDAY(par_dtresgat),"9"))  THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.    

        FOR EACH craplrg WHERE craplrg.cdcooper = par_cdcooper AND
                               craplrg.dtmvtolt = par_dtmvtolt AND
                               craplrg.cdagenci = 99           AND
                               craplrg.cdbccxlt = 400          AND
                               craplrg.nraplica = par_nraplica AND
                               craplrg.nrdconta = par_nrdconta AND
                               craplrg.inresgat = 0            NO-LOCK:

            ASSIGN aux_qtdaplrg = aux_qtdaplrg + 1.
        
        END.
                                      
        IF  aux_qtdaplrg >= 2  THEN
            DO:
                ASSIGN aux_dscritic = "ATENCAO! Nao e possivel efetuar mais " +
                                      "de 2 resgates no mesmo dia.".
                LEAVE.
            END.
            
        LEAVE.      
                    
    END. /** Fim do DO WHILE TRUE **/
    
    IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,          /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".                         
        END.

    ASSIGN aux_dsmensag = "Confirma a operacao?".
        
    IF  NOT AVAILABLE crapdtc AND craprda.inaniver = 0  THEN
        DO:
            IF (craprda.tpaplica = 3                        AND
                NOT (craprda.inaniver = 0                   AND 
                craprda.dtfimper <= par_dtresgat))          OR
               (craprda.tpaplica = 5                        AND
                NOT ((craprda.dtfimper <= par_dtresgat)     AND
               (craprda.dtfimper - craprda.dtmvtolt) > 50)) THEN
                DO:
                    ASSIGN aux_dsmensag = "Aplicacao em carencia. " +
                                          aux_dsmensag.
                    
                    IF  par_dtmvtolt = par_dtresgat THEN
                        ASSIGN aux_tpresgat = 6.
                    ELSE
                        ASSIGN aux_tpresgat = 3.
                END.    
        END.

    IF  par_flmensag  THEN                   
        DO:
            CREATE tt-msg-confirma.
            ASSIGN tt-msg-confirma.inconfir = 1
                   tt-msg-confirma.dsmensag = aux_dsmensag.
                   
            IF  AVAILABLE crapdtc                AND 
                par_dtresgat < craprda.dtvencto  THEN
                DO:
                    IF  crapdtc.tpaplrdc = 1  THEN
                        aux_dsmensag = "ATENCAO! O cooperado nao recebera " +
                                       "rendimento. A data de resgate e " +
                                       "menor que o vencimento da aplicacao.".
                    ELSE
                    IF  crapdtc.tpaplrdc = 2  THEN
                        aux_dsmensag = "ATENCAO! O cooperado nao recebera " +
                                       "rendimento estipulado no contrato. " +
                                       "A data de resgate e menor que o " +
                                       "vencimento da aplicacao.".
                                       
                    CREATE tt-msg-confirma.
                    ASSIGN tt-msg-confirma.inconfir = 2
                           tt-msg-confirma.dsmensag = aux_dsmensag. 
                END.
                
            RETURN "OK".        
        END.
        
    IF  aux_tpresgat = 0  THEN
        DO:
            IF  craprda.tpaplica = 3 AND par_dtmvtolt = par_dtresgat  THEN
                DO:
                    IF  par_tpresgat = "P"  THEN 
                        ASSIGN aux_tpresgat = 4.
                    ELSE
                        ASSIGN aux_tpresgat = 5.
                END.
            ELSE               
                DO:
                    IF  par_tpresgat = "P"  THEN 
                        ASSIGN aux_tpresgat = 1.
                    ELSE
                        ASSIGN aux_tpresgat = 2.
                END.        
        END.
        
    ASSIGN aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

        DO aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 99           AND
                               craplot.cdbccxlt = 400          AND
                               craplot.nrdolote = 999
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN aux_cdcritic = 84.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                   craplot.dtmvtopg = par_dtmvtopr
                                   craplot.cdagenci = 99
                                   craplot.cdbccxlt = 400
                                   craplot.cdbccxpg = 0
                                   craplot.cdhistor = 00
                                   craplot.nrdolote = 999
                                   craplot.tplotmov = 11
                                   craplot.tpdmoeda = 1
                                   craplot.nrseqdig = 1
                                   craplot.qtcompln = 1
                                   craplot.qtinfoln = 1
                                   craplot.vlcompdb = par_vlresgat
                                   craplot.vlinfodb = par_vlresgat
                                   craplot.cdoperad = par_cdoperad
                                   craplot.cdcooper = par_cdcooper.
                        END.
                END.
            ELSE
                ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.vlcompdb = craplot.vlcompdb + par_vlresgat
                       craplot.vlinfodb = craplot.vlinfodb + par_vlresgat. 
                       
            LEAVE.

        END. /** Fim do DO WHILE TRUE **/

        CREATE craplrg.
        ASSIGN craplrg.flgcreci = par_flgctain
               craplrg.cdagenci = 99
               craplrg.cdbccxlt = 400
               craplrg.dtmvtolt = par_dtmvtolt
               craplrg.dtresgat = par_dtresgat
               craplrg.inresgat = 0
               craplrg.nraplica = par_nraplica
               craplrg.nrdconta = par_nrdconta
               craplrg.nrdocmto = craplot.nrseqdig             
               craplrg.nrdolote = 999
               craplrg.nrseqdig = craplot.nrseqdig             
               craplrg.tpaplica = craprda.tpaplica
               craplrg.tpresgat = aux_tpresgat
               craplrg.vllanmto = par_vlresgat
               craplrg.cdoperad = par_cdoperad
               craplrg.hrtransa = TIME
               craplrg.cdcooper = par_cdcooper.
               
        /** Para resgate on-line - Somente para aplicacoes RDCA30 **/       
        IF  craprda.tpaplica = 3 AND par_dtresgat = par_dtmvtolt  THEN
            DO:
                RUN efetua-resgate-online (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_nraplica,
                                           INPUT par_dtmvtolt,
                                           INPUT par_cdprogra,
                                          OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE = "NOK"  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        FIND CURRENT craplot NO-LOCK NO-ERROR.
        FIND CURRENT craplrg NO-LOCK NO-ERROR.
            
        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            ELSE
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Erro na transacao. Nao " +
                                                  "foi possivel cancelar o " +
                                                  "resgate.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,          /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
                END.

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nraplica",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nraplica,
                                                        "zzz,zzz,zzz"))).
                                                        
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "tpresgat",
                                             INPUT "",
                                             INPUT par_tpresgat).
                                             
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vlresgat",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_vlresgat,
                                                        "zzz,zzz,zz9.99"))).
                                                                               
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "dtresgat",
                                             INPUT "",
                                             INPUT STRING(par_dtresgat,
                                                          "99/99/9999")).
                                                          
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "flgctain",
                                             INPUT "",
                                             INPUT STRING(par_flgctain,
                                                          "SIM/NAO")).
                END.

            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nraplica",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nraplica,
                                                "zzz,zzz,zzz"))).
                                                
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrdocmto",
                                     INPUT "",
                                     INPUT TRIM(STRING(craplrg.nrdocmto,
                                                "zzz,zzz,zzz"))).                                                
                                                        
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "tpresgat",
                                     INPUT "",
                                     INPUT par_tpresgat).
                                             
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "vlresgat",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_vlresgat,
                                                "zzz,zzz,zz9.99"))).
                                                                               
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtresgat",
                                     INPUT "",
                                     INPUT STRING(par_dtresgat,"99/99/9999")).
                                                          
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "flgctain",
                                     INPUT "",
                                     INPUT STRING(par_flgctain,"SIM/NAO")).
        END.            
            
    RETURN "OK".

END PROCEDURE.           

/******************************************************************************/
/**           Procedure para efetuar resgate on-line da aplicacao            **/
/******************************************************************************/
PROCEDURE efetua-resgate-online:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctaini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctafim AS INTE                                    NO-UNDO.
    DEF VAR aux_nraplini AS INTE                                    NO-UNDO.
    DEF VAR aux_nraplfim AS INTE                                    NO-UNDO.
    DEF VAR aux_indabono AS INTE                                    NO-UNDO.

    DEF VAR aux_dtiniiof AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimiof AS DATE                                    NO-UNDO.
    DEF VAR aux_dtinipmf AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimpmf AS DATE                                    NO-UNDO.
    DEF VAR aux_dtiniabo AS DATE                                    NO-UNDO.   

    DEF VAR aux_txiofrda AS DECI                                    NO-UNDO.
    DEF VAR aux_vlmoefix AS DECI DECIMALS 8                         NO-UNDO.
    DEF VAR aux_vlorimfx AS DECI DECIMALS 8                         NO-UNDO.
    DEF VAR aux_vlresgat AS DECI                                    NO-UNDO.
    DEF VAR aux_saldorda AS DECI                                    NO-UNDO.
    DEF VAR aux_txcpmfcc AS DECI                                    NO-UNDO.

    DEF VAR aux_flgresga AS LOGI                                    NO-UNDO.

    DEF VAR h-b1wgen0005 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabrda FOR craprda.
    DEF BUFFER crablot FOR craplot.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vlmoefix = 0
           aux_nrctaini = 0
           aux_nrctafim = 99999999
           aux_nraplini = 0
           aux_nraplfim = 999999.

    IF  par_nrdconta <> 0  THEN
        ASSIGN aux_nrctaini = par_nrdconta
               aux_nrctafim = par_nrdconta.
            
    IF  par_nraplica <> 0  THEN
        ASSIGN aux_nraplini = par_nraplica
               aux_nraplfim = par_nraplica.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRCPMFCCR" AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 641.
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            RETURN "NOK".
        END.
 
    ASSIGN aux_dtinipmf = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           aux_dtfimpmf = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           aux_txcpmfcc = IF  par_dtmvtolt >= aux_dtinipmf  AND
                              par_dtmvtolt <= aux_dtfimpmf  THEN
                              DECI(SUBSTR(craptab.dstextab,23,13))
                          ELSE 
                              0
           aux_indabono = INTE(SUBSTR(craptab.dstextab,51,1))  
           aux_dtiniabo = DATE(INTE(SUBSTR(craptab.dstextab,56,2)),
                               INTE(SUBSTR(craptab.dstextab,53,2)),
                               INTE(SUBSTR(craptab.dstextab,59,4))).

    /** Tabela com a taxa do IOF **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRIOFRDCA" AND
                       craptab.tpregist = 1            NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 626
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,          /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
     
    ASSIGN aux_dtiniiof = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           aux_dtfimiof = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           aux_txiofrda = IF  par_dtmvtolt >= aux_dtiniiof  AND
                              par_dtmvtolt <= aux_dtfimiof  THEN
                              DECI(SUBSTR(craptab.dstextab,23,16))
                          ELSE 
                              0.

    FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper AND
                       crapmfx.dtmvtolt = par_dtmvtolt AND
                       crapmfx.tpmoefix = 2            NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapmfx  THEN
        DO:
            ASSIGN aux_cdcritic = 211
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
                
    ASSIGN aux_vlmoefix = crapmfx.vlmoefix.
                                          
    FOR EACH craplrg WHERE craplrg.cdcooper  = par_cdcooper AND
                           craplrg.nrdconta >= aux_nrctaini AND
                           craplrg.nrdconta <= aux_nrctafim AND
                           craplrg.nraplica >= aux_nraplini AND
                           craplrg.nraplica <= aux_nraplfim AND
                           craplrg.dtresgat <= par_dtmvtolt AND
                           craplrg.tpaplica  = 3            AND
                           craplrg.inresgat  = 0            AND
                          (craplrg.tpresgat  = 4            OR
                           craplrg.tpresgat  = 5            OR
                           craplrg.tpresgat  = 6)           EXCLUSIVE-LOCK
                           TRANSACTION ON ERROR UNDO, RETURN "NOK":

        ASSIGN aux_vlresgat = 0
               aux_saldorda = 0
               aux_cdcritic = 0 
               aux_dscritic = "".
        
        DO WHILE TRUE:

            FIND crabrda WHERE crabrda.cdcooper = par_cdcooper     AND
                               crabrda.nrdconta = craplrg.nrdconta AND
                               crabrda.nraplica = craplrg.nraplica
                               USE-INDEX craprda2 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  LOCKED crabrda  THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                
            LEAVE.

        END. /** Fim do DO WHILE TRUE **/
        
        IF  NOT AVAILABLE crabrda  THEN
            ASSIGN aux_cdcritic = 426.
        ELSE
            DO:
                /** Verifica se aplicacao esta disponivel para saque **/
                FIND FIRST craptab WHERE 
                           craptab.cdcooper = par_cdcooper             AND
                           craptab.nmsistem = "CRED"                   AND
                           craptab.tptabela = "BLQRGT"                 AND
                           craptab.cdempres = 00                       AND
                           craptab.cdacesso = STRING(craplrg.nrdconta,
                                                     "9999999999")     AND
                           INTE(SUBSTR(craptab.dstextab,1,7)) = craplrg.nraplica
                           NO-LOCK NO-ERROR.
             
                IF  AVAILABLE craptab  THEN
                    ASSIGN aux_cdcritic = 640.    
                ELSE   
                IF  crabrda.insaqtot = 1  THEN
                    ASSIGN aux_cdcritic = 428.
                ELSE
                IF  crabrda.inaniver  = 1                 OR
                   (crabrda.inaniver  = 0                 AND
                    craplrg.dtresgat >= crabrda.dtfimper) THEN
                    DO: 
                        /*****************************************************/
                        /** Como esta procedure foi desenvolvida baseada no **/
                        /** programa batch crps117_1.p deve ser passado por **/
                        /** parametro (p-cdprogra) o nome do programa para  **/
                        /** o calculo correto do saldo para resgate         **/
                        /*****************************************************/
                        RUN saldo-resg-rdca (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_nrdconta,
                                             INPUT par_nraplica,
                                             INPUT "crps117", /* Batch resg. */
                                            OUTPUT aux_vlsdrdca,
                                            OUTPUT aux_sldpresg,
                                            OUTPUT TABLE tt-erro).

                        IF  RETURN-VALUE = "NOK"  THEN
                            UNDO, RETURN "NOK".

                        ASSIGN aux_flgresga = TRUE
                               aux_saldorda = IF  aux_vlsdrdca < 0  THEN 
                                                  0
                                              ELSE 
                                                  aux_sldpresg.
                
                        IF  crabrda.vlsdrdca = 0.01  THEN
                            ASSIGN aux_saldorda = 0.01
                                   aux_vlsdrdca = 0.01
                                   aux_sldpresg = 0.01.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_flgresga = FALSE
                               aux_saldorda = crabrda.vlsdrdca.
                        
                        /** Leitura do valor da UFIR do dia da aplicacao **/
                        FIND crapmfx WHERE 
                             crapmfx.cdcooper = par_cdcooper     AND
                             crapmfx.dtmvtolt = crabrda.dtmvtolt AND
                             crapmfx.tpmoefix = 2                
                             NO-LOCK NO-ERROR.
            
                        IF  NOT AVAILABLE crapmfx  THEN
                            DO:
                                ASSIGN aux_cdcritic = 211
                                       aux_dscritic = "".

                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,      /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                   
                                UNDO, RETURN "NOK".
                            END.
                        ELSE
                            aux_vlorimfx = crapmfx.vlmoefix.
                    END.
            END.
        
        IF  aux_cdcritic = 0  THEN
            DO:
                IF  aux_saldorda > 0  THEN
                    DO: 
                        CASE craplrg.tpresgat:
                        
                            WHEN 4 THEN DO:   /** Parcial do DIA     **/
                                IF  craplrg.vllanmto > aux_saldorda  THEN
                                    ASSIGN aux_vlresgat = aux_saldorda
                                           aux_cdcritic = 429.
                                ELSE
                                    aux_vlresgat = craplrg.vllanmto.
                            END.
                            WHEN 5 THEN       /** Total do DIA       **/
                                aux_vlresgat = aux_saldorda.                   
                            WHEN 6 THEN DO:   /**  Antecipado do DIA **/
                                IF  craplrg.vllanmto = 0  THEN
                                    aux_vlresgat = aux_saldorda.
                                ELSE 
                                IF  craplrg.vllanmto > aux_saldorda  THEN
                                    ASSIGN aux_vlresgat = aux_saldorda
                                           aux_cdcritic = 429.
                                ELSE       
                                    aux_vlresgat = craplrg.vllanmto.
                            END.

                        END CASE.
    
                        /** Resgate Conta Corrente **/
                        IF  NOT craplrg.flgcreci  THEN 
                            DO:
                                /** Gera lancamento na conta-corrente **/
                                DO WHILE TRUE:
    
                                    FIND craplot WHERE
                                         craplot.cdcooper = par_cdcooper AND
                                         craplot.dtmvtolt = par_dtmvtolt AND
                                         craplot.cdagenci = 1            AND
                                         craplot.cdbccxlt = 100          AND
                                         craplot.nrdolote = 8474
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
                                    IF  NOT AVAILABLE craplot  THEN
                                        IF  LOCKED craplot  THEN
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT.
                                            END.
                                        ELSE
                                            DO:
                                                CREATE craplot.
                                                ASSIGN 
                                                craplot.dtmvtolt = par_dtmvtolt
                                                craplot.cdagenci = 1
                                                craplot.cdbccxlt = 100
                                                craplot.nrdolote = 8474
                                                craplot.tplotmov = 1
                                                craplot.cdcooper = par_cdcooper.
                                            END.
    
                                    LEAVE.
    
                                END. /** Fim do DO WHILE TRUE **/
    
                                CREATE craplcm.
                                ASSIGN craplcm.cdcooper = par_cdcooper
                                       craplcm.dtmvtolt = craplot.dtmvtolt
                                       craplcm.dtrefere = crabrda.dtmvtolt
                                       craplcm.cdagenci = craplot.cdagenci
                                       craplcm.cdbccxlt = craplot.cdbccxlt
                                       craplcm.nrdolote = craplot.nrdolote
                                       craplcm.nrdconta = crabrda.nrdconta
                                       craplcm.nrdctabb = crabrda.nrdconta
                                       craplcm.nrdctitg = 
                                               STRING(crabrda.nrdconta,
                                                      "99999999")
                                       craplcm.nrdocmto = craplrg.nrdocmto
                                       craplcm.cdhistor = IF  aux_flgresga  THEN
                                                              115
                                                          ELSE 
                                                              186
                                       craplcm.vllanmto = aux_vlresgat
                                       craplcm.cdpesqbb = 
                                        IF (NOT aux_flgresga)                AND
                                           (crabrda.dtmvtolt >= aux_dtinipmf AND
                                            crabrda.dtmvtolt <= aux_dtfimpmf)
                                            THEN " " ELSE "."
                                       craplcm.nrseqdig = craplot.nrseqdig + 1.
                            
                                IF  crabrda.flgctain  THEN  
                                    ASSIGN craplcm.cdhistor = 
                                                   IF  aux_flgresga  THEN
                                                       497
                                                   ELSE 
                                                       498.
    
                                ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                                       craplot.qtcompln = craplot.qtcompln + 1
                                       craplot.vlinfocr = craplot.vlinfocr + 
                                                          aux_vlresgat
                                       craplot.vlcompcr = craplot.vlcompcr + 
                                                          aux_vlresgat
                                       craplot.nrseqdig = craplcm.nrseqdig.
                            END.
                            
                        IF  crabrda.flgctain       AND  
                            NOT craplrg.flgcreci  THEN  
                            DO:
                                /** Gera lancamentos Conta Investimento **/
                                DO WHILE TRUE:
        
                                    FIND crablot WHERE 
                                         crablot.cdcooper = par_cdcooper AND
                                         crablot.dtmvtolt = par_dtmvtolt AND
                                         crablot.cdagenci = 1            AND
                                         crablot.cdbccxlt = 100          AND
                                         crablot.nrdolote = 10105
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAILABLE crablot  THEN
                                        IF  LOCKED crablot  THEN
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT.
                                            END.
                                        ELSE
                                            DO:
                                                CREATE crablot.
                                                ASSIGN crablot.dtmvtolt = 
                                                               par_dtmvtolt
                                                       crablot.cdagenci = 1
                                                       crablot.cdbccxlt = 100
                                                       crablot.nrdolote = 10105  
                                                       crablot.tplotmov = 29
                                                       crablot.cdcooper = 
                                                               par_cdcooper.
                                            END.
                        
                                    LEAVE.
                                    
                                END. /** Fim do DO WHILE TRUE **/

                                CREATE craplci.
                                ASSIGN craplci.cdcooper = par_cdcooper
                                       craplci.dtmvtolt = crablot.dtmvtolt
                                       craplci.cdagenci = crablot.cdagenci
                                       craplci.cdbccxlt = crablot.cdbccxlt
                                       craplci.nrdolote = crablot.nrdolote
                                       craplci.nrdconta = crabrda.nrdconta
                                       craplci.nrdocmto = craplrg.nrdocmto
                                       craplci.cdhistor = IF aux_flgresga THEN
                                                             492
                                                          ELSE 
                                                             493
                                       craplci.vllanmto = aux_vlresgat
                                       craplci.nrseqdig = crablot.nrseqdig + 1
                                       crablot.qtinfoln = crablot.qtinfoln + 1
                                       crablot.qtcompln = crablot.qtcompln + 1
                                       crablot.vlinfodb = crablot.vlinfodb + 
                                                          aux_vlresgat
                                       crablot.vlcompdb = crablot.vlcompdb + 
                                                          aux_vlresgat
                                       crablot.nrseqdig = craplci.nrseqdig.

                                /** Gera lancamentos Conta Investmento **/
                                DO  WHILE TRUE:
        
                                    FIND crablot WHERE 
                                         crablot.cdcooper = par_cdcooper AND
                                         crablot.dtmvtolt = par_dtmvtolt AND
                                         crablot.cdagenci = 1            AND
                                         crablot.cdbccxlt = 100          AND
                                         crablot.nrdolote = 10104
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAILABLE crablot  THEN
                                        IF  LOCKED crablot  THEN
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT.
                                            END.
                                        ELSE
                                            DO:
                                                CREATE crablot.
                                                ASSIGN crablot.dtmvtolt = 
                                                               par_dtmvtolt
                                                       crablot.cdagenci = 1
                                                       crablot.cdbccxlt = 100
                                                       crablot.nrdolote = 10104 
                                                       crablot.tplotmov = 29
                                                       crablot.cdcooper = 
                                                               par_cdcooper.
                                            END.
             
                                    LEAVE.

                                END. /** Fim do DO WHILE TRUE **/

                                CREATE craplci.
                                ASSIGN craplci.cdcooper = par_cdcooper
                                       craplci.dtmvtolt = crablot.dtmvtolt
                                       craplci.cdagenci = crablot.cdagenci
                                       craplci.cdbccxlt = crablot.cdbccxlt
                                       craplci.nrdolote = crablot.nrdolote
                                       craplci.nrdconta = crabrda.nrdconta
                                       craplci.nrdocmto = craplrg.nrdocmto
                                       craplci.cdhistor = 489  /** Credito **/
                                       craplci.vllanmto = aux_vlresgat
                                       craplci.nrseqdig = crablot.nrseqdig + 1
                                       crablot.qtinfoln = crablot.qtinfoln + 1
                                       crablot.qtcompln = crablot.qtcompln + 1
                                       crablot.vlinfocr = crablot.vlinfocr + 
                                                          aux_vlresgat
                                       crablot.vlcompcr = crablot.vlcompcr + 
                                                          aux_vlresgat
                                       crablot.nrseqdig = craplci.nrseqdig.
                            END.

                        /** Resgatar para Conta Investimento **/
                        IF  craplrg.flgcreci  THEN  
                            DO: 
                                DO WHILE TRUE:
        
                                    FIND crablot WHERE 
                                         crablot.cdcooper = par_cdcooper AND
                                         crablot.dtmvtolt = par_dtmvtolt AND
                                         crablot.cdagenci = 1            AND
                                         crablot.cdbccxlt = 100          AND
                                         crablot.nrdolote = 10106
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAILABLE crablot  THEN
                                        IF  LOCKED crablot  THEN
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT.
                                            END.
                                        ELSE
                                            DO:
                                                CREATE crablot.
                                                ASSIGN crablot.dtmvtolt = 
                                                               par_dtmvtolt
                                                       crablot.cdagenci = 1
                                                       crablot.cdbccxlt = 100
                                                       crablot.nrdolote = 10106
                                                       crablot.tplotmov = 29
                                                       crablot.cdcooper = 
                                                               par_cdcooper.
                                            END.
                        
                                    LEAVE.

                                END. /** Fim do DO WHILE TRUE **/

                                CREATE craplci.
                                ASSIGN craplci.cdcooper = par_cdcooper
                                       craplci.dtmvtolt = crablot.dtmvtolt
                                       craplci.cdagenci = crablot.cdagenci
                                       craplci.cdbccxlt = crablot.cdbccxlt
                                       craplci.nrdolote = crablot.nrdolote
                                       craplci.nrdconta = crabrda.nrdconta
                                       craplci.nrdocmto = craplrg.nrdocmto
                                       craplci.cdhistor = 490   
                                       craplci.vllanmto = aux_vlresgat
                                       craplci.nrseqdig = crablot.nrseqdig + 1
                                       crablot.qtinfoln = crablot.qtinfoln + 1
                                       crablot.qtcompln = crablot.qtcompln + 1
                                       crablot.vlinfocr = crablot.vlinfocr + 
                                                          aux_vlresgat
                                       crablot.vlcompcr = crablot.vlcompcr + 
                                                          aux_vlresgat
                                       crablot.nrseqdig = craplci.nrseqdig.
                                 
                                DO WHILE TRUE:
                                
                                    /** Atualizar Saldo Conta Investimento **/
                                    FIND crapsli WHERE 
                                         crapsli.cdcooper  = 
                                                 par_cdcooper        AND
                                         crapsli.nrdconta  = 
                                                 crabrda.nrdconta    AND
                                   MONTH(crapsli.dtrefere) = 
                                                 MONTH(par_dtmvtolt) AND
                                    YEAR(crapsli.dtrefere) = 
                                                 YEAR(par_dtmvtolt) 
                                     EXCLUSIVE NO-ERROR NO-WAIT.
                    
                                    IF  NOT AVAIL crapsli  THEN
                                        DO:
                                            IF  LOCKED crapsli  THEN
                                                DO:
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                            ELSE
                                                DO:    
                                                    aux_dtrefere = 
                                                    ((DATE(MONTH(par_dtmvtolt),
                                                      28,YEAR(par_dtmvtolt)) 
                                                      + 4) -
                                                   DAY(DATE(MONTH(par_dtmvtolt),
                                                   28,YEAR(par_dtmvtolt)) + 4)).
                               
                                                    CREATE crapsli.
                                                    ASSIGN crapsli.dtrefere = 
                                                            aux_dtrefere
                                                           crapsli.nrdconta = 
                                                            crabrda.nrdconta
                                                           crapsli.cdcooper = 
                                                            par_cdcooper.
                                                END.
                                        END.
                                    ELSE
                                        ASSIGN crapsli.vlsddisp = 
                                                       crapsli.vlsddisp + 
                                                       aux_vlresgat.
                                                       
                                    LEAVE.
                                                          
                                END. /** Fim do DO WHILE TRUE **/
                            END.                  
                             
                        /** Gera lancamento do resgate **/
                        DO WHILE TRUE:
    
                            FIND craplot WHERE 
                                 craplot.cdcooper = par_cdcooper AND
                                 craplot.dtmvtolt = par_dtmvtolt AND
                                 craplot.cdagenci = 1            AND
                                 craplot.cdbccxlt = 100          AND
                                 craplot.nrdolote = 8382
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                            IF  NOT AVAILABLE craplot  THEN
                                IF  LOCKED craplot  THEN
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE
                                    DO:
                                        CREATE craplot.
                                        ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                               craplot.cdagenci = 1
                                               craplot.cdbccxlt = 100
                                               craplot.nrdolote = 8382
                                               craplot.tplotmov = 10
                                               craplot.cdcooper = par_cdcooper.
                                    END.
    
                            LEAVE.
    
                        END. /** Fim do DO WHILE TRUE **/
    
                        CREATE craplap.
                        ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                               craplap.cdagenci = craplot.cdagenci
                               craplap.cdbccxlt = craplot.cdbccxlt
                               craplap.nrdolote = craplot.nrdolote
                               craplap.nrdconta = crabrda.nrdconta
                               craplap.nraplica = crabrda.nraplica
                               craplap.nrdocmto = craplrg.nrdocmto
                               craplap.cdcooper = par_cdcooper
                               craplap.txaplica = IF  aux_flgresga  THEN
                                                      aux_txaplica * 100
                                                  ELSE 
                                                      0
                               craplap.nrseqdig = craplot.nrseqdig + 1
                               craplap.dtrefere = crabrda.dtfimper
                               craplap.vllanmto = aux_vlresgat
                               craplap.txaplmes = 0
                               craplap.cdhistor = IF  aux_flgresga  THEN 
                                                      118
                                                  ELSE 
                                                      126
                               craplot.vlinfodb = craplot.vlinfodb +
                                                  craplap.vllanmto
                               craplot.vlcompdb = craplot.vlcompdb +
                                                  craplap.vllanmto
                               craplot.qtinfoln = craplot.qtinfoln + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                               craplot.nrseqdig = craplot.nrseqdig + 1.
    
                        /** Nova aplicacao **/                                                   
                        IF  crabrda.flgctain  THEN 
                            ASSIGN craplap.cdhistor = IF  aux_flgresga  THEN
                                                          492
                                                      ELSE 
                                                          493.
                          
                        /** Calcular ajuste de IRRF enxergando novas faixas **/
                        ASSIGN aux_vlsldapl = IF  craplrg.tpresgat = 5  THEN
                                                  aux_vlsdrdca 
                                              ELSE 
                                                  aux_vlresgat
                               aux_sldpresg = 0.
                          
                        RUN sistema/generico/procedures/b1wgen0005.p 
                            PERSISTENT SET h-b1wgen0005.

                        IF  NOT VALID-HANDLE(h-b1wgen0005)  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Handle invalido para " +
                                                      "BO b1wgen0005.".

                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,      /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                   
                                UNDO, RETURN "NOK".
                            END.
    
                        RUN saldo-rdca-resgate IN h-b1wgen0005 
                                              (INPUT par_cdcooper,       
                                               INPUT par_cdagenci,       
                                               INPUT par_nrdcaixa,       
                                               INPUT par_cdoperad,       
                                               INPUT par_idorigem,       
                                               INPUT par_cdprogra,       
                                               INPUT par_nrdconta,       
                                               INPUT craplrg.dtresgat,       
                                               INPUT par_nraplica,       
                                               INPUT aux_vlsldapl,       
                                               INPUT aux_vlrentot,       
                                              OUTPUT aux_pcajsren,       
                                              OUTPUT aux_vlrenreg, 
                                              OUTPUT aux_vldajtir, 
                                              OUTPUT aux_sldrgttt, 
                                              OUTPUT aux_vlslajir, 
                                              OUTPUT aux_vlrenacu, 
                                              OUTPUT aux_nrmeses,       
                                              OUTPUT aux_nrdias,       
                                              OUTPUT aux_dtiniapl,       
                                              OUTPUT aux_cdhisren,       
                                              OUTPUT aux_cdhisajt,       
                                              OUTPUT aux_perirapl,
                                              INPUT-OUTPUT aux_sldpresg, 
                                              OUTPUT TABLE tt-erro).
    
                        DELETE PROCEDURE h-b1wgen0005.
    
                        IF  RETURN-VALUE = "NOK"  THEN
                            UNDO, RETURN "NOK".
                            
                        ASSIGN craplap.vlslajir = TRUNCATE(aux_vlslajir,2)
                               craplap.vlrenacu = ROUND(aux_vlrenacu,2)
                               craplap.pcajsren = TRUNCATE(aux_pcajsren,2) 
                               craplap.vlrenreg = ROUND(aux_vlrenreg,2) 
                               craplap.vldajtir = IF aux_sldrgttt <= -0.03 AND
                                                     aux_sldrgttt >= 0.03  THEN
                                                     TRUNCATE(aux_vldajtir + 
                                                              aux_sldrgttt,2)
                                                  ELSE
                                                     TRUNCATE(aux_vldajtir,2)
                               craplap.aliaplaj = aux_perirapl
                               craplap.qtdmesaj = aux_nrmeses
                               craplap.qtddiaaj = aux_nrdias
                               craplap.rendatdt = ROUND(aux_vlrentot,2).
                               
                        IF  craplap.vldajtir > 0  THEN
                            DO:
                                CREATE craplap.
                                ASSIGN craplap.cdcooper = par_cdcooper
                                       craplap.dtmvtolt = craplot.dtmvtolt
                                       craplap.cdagenci = craplot.cdagenci
                                       craplap.cdbccxlt = craplot.cdbccxlt
                                       craplap.nrdolote = craplot.nrdolote
                                       craplap.nrdconta = crabrda.nrdconta
                                       craplap.nraplica = crabrda.nraplica
                                       craplap.nrdocmto = craplrg.nrdocmto + 
                                                          888000 
                                       craplap.txaplica = aux_perirapl
                                       craplap.txaplmes = aux_perirapl
                                       craplap.cdhistor = aux_cdhisajt
                                       craplap.nrseqdig = craplot.nrseqdig + 1 
                                       craplap.vllanmto = 
                                               IF aux_sldrgttt <= -0.03 AND
                                                  aux_sldrgttt >= 0.03  THEN
                                                  TRUNCATE(aux_vldajtir + 
                                                           aux_sldrgttt,2)
                                               ELSE
                                                  TRUNCATE(aux_vldajtir,2)
                                       craplap.dtrefere = crabrda.dtfimper
                                       craplap.vlslajir = TRUNCATE(aux_vlslajir,
                                                                   2)
                                       craplap.vlrenacu = ROUND(aux_vlrenacu,2)
                                       craplap.pcajsren = TRUNCATE(aux_pcajsren,
                                                                   2) 
                                       craplap.vlrenreg = ROUND(aux_vlrenreg,2) 
                                       craplap.vldajtir = 
                                               IF aux_sldrgttt <= -0.03 AND
                                                  aux_sldrgttt >= 0.03  THEN
                                                  TRUNCATE(aux_vldajtir + 
                                                           aux_sldrgttt,2)
                                               ELSE
                                                  TRUNCATE(aux_vldajtir,2)
                                       craplap.aliaplaj = aux_perirapl
                                       craplap.qtdmesaj = aux_nrmeses
                                       craplap.qtddiaaj = aux_nrdias
                                       craplap.rendatdt = ROUND(aux_vlrentot,2)
                                       craplap.vlregpaj = TRUNCATE(aux_vlresgat,
                                                                   2) 
                                       craplot.vlinfocr = craplot.vlinfocr + 
                                                          craplap.vllanmto
                                       craplot.vlcompcr = craplot.vlcompcr + 
                                                          craplap.vllanmto
                                       craplot.qtinfoln = craplot.qtinfoln + 1
                                       craplot.qtcompln = craplot.qtcompln + 1
                                       craplot.nrseqdig = craplot.nrseqdig + 1.
                            END.
                          
                        IF  aux_flgresga  THEN
                            ASSIGN crabrda.vlrgtacu = crabrda.vlrgtacu +
                                                      aux_vlresgat
                                   crabrda.qtrgtmfx = crabrda.qtrgtmfx +
                                                      ROUND(aux_vlresgat / 
                                                            aux_vlmoefix,4).
                        ELSE
                            ASSIGN crabrda.vlrgtacu = crabrda.vlrgtacu +
                                                      aux_vlresgat
                                   crabrda.qtrgtmfx = crabrda.qtrgtmfx +
                                          ROUND(aux_vlresgat / aux_vlorimfx,4)
                                   crabrda.vlsdrdca = crabrda.vlsdrdca -
                                                      aux_vlresgat
                                   crabrda.vlabcpmf =
                                    IF  aux_indabono = 0                  AND
                                        crabrda.vlabcpmf > 0              AND
                                        aux_dtiniabo <= crabrda.dtmvtolt  THEN 
                                        crabrda.vlabcpmf -
                                        TRUNCATE(aux_vlresgat * aux_txcpmfcc,2)
                                    ELSE 
                                        crabrda.vlabcpmf
                                   crabrda.vlabdiof =
                                    IF  aux_indabono = 0                  AND
                                        aux_dtiniabo <= crabrda.dtmvtolt  THEN 
                                        crabrda.vlabdiof -
                                        TRUNCATE(aux_vlresgat * aux_txiofrda,2)
                                    ELSE 
                                        crabrda.vlabdiof
                                   crabrda.vlsdextr = 
                                               IF  crabrda.vlsdrdca <= 0  THEN 
                                                   0 
                                               ELSE 
                                                   crabrda.vlsdextr.    
                    END.
                ELSE
                    ASSIGN aux_cdcritic = 428.
            END.

        IF  aux_cdcritic = 0  THEN
            ASSIGN aux_cdcritic = 434.
    
        CREATE craprej.
        ASSIGN craprej.dtmvtolt = par_dtmvtolt
               craprej.cdagenci = 117
               craprej.cdbccxlt = 117
               craprej.nrdolote = 117
               craprej.nrdconta = craplrg.nrdconta
               craprej.nraplica = craplrg.nraplica
               craprej.dtdaviso = craplrg.dtmvtolt
               craprej.vldaviso = craplrg.vllanmto
               craprej.vlsdapli = aux_saldorda
               craprej.vllanmto = aux_vlresgat
               craprej.cdcritic = aux_cdcritic
               craprej.tpintegr = 117
               craprej.cdcooper = par_cdcooper
               craplrg.inresgat = 1.
                                          
    END. /** Fim do FOR EACH craplrg **/

    FIND CURRENT crabrda NO-LOCK NO-ERROR.
    FIND CURRENT craplrg NO-LOCK NO-ERROR.
    FIND CURRENT craplot NO-LOCK NO-ERROR.
    FIND CURRENT crablot NO-LOCK NO-ERROR.
    FIND CURRENT crapsli NO-LOCK NO-ERROR.
                                          
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**         Procedure para consultar saldos acumulados da aplicacao          **/
/******************************************************************************/
PROCEDURE consultar-saldo-acumulado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-acumulo.
    DEF OUTPUT PARAM TABLE FOR tt-acumula.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-dados-acumulo.
    EMPTY TEMP-TABLE tt-acumula.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar saldo acumulado da aplicacao".

    FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                       craprda.nrdconta = par_nrdconta AND
                       craprda.nraplica = par_nraplica NO-LOCK NO-ERROR.      

    IF  NOT AVAILABLE craprda  THEN
        DO:
            ASSIGN aux_cdcritic = 426
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.
   
    FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper     AND
                       crapdtc.tpaplica = craprda.tpaplica NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdtc  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de aplicacao deve ser 'RDCPRE' ou " +
                                  "'RDCPOS'.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".         
        END.
                
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper     AND
                             craplap.nrdconta = par_nrdconta     AND
                             craplap.nraplica = par_nraplica     AND
                             craplap.dtmvtolt = craprda.dtmvtolt
                             NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE craplap  THEN                         
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao ha lancamento para a aplicacao.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".         
        END.
                         
    IF  crapdtc.tpaplrdc = 1  THEN  /** RDCPRE **/
        DO:
            RUN saldo_rdc_pre (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_nraplica,
                               INPUT par_dtmvtolt,
                               INPUT ?,
                               INPUT ?,
                               INPUT 0,
                               INPUT-OUTPUT aux_vlsldrdc,
                              OUTPUT aux_vlrdirrf,
                              OUTPUT aux_perirrgt,
                              OUTPUT TABLE tt-erro).
                                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Nao foi possivel concluir " +
                                                  "a operacao.".
                                                  
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,   /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).         
                        END.                          
                        
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                   
                    RETURN "NOK".
                END.
        END.           
    ELSE
    IF  crapdtc.tpaplrdc = 2  THEN
        DO:  
            RUN saldo_rdc_pos (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_nraplica,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT aux_vlsldrdc,
                              OUTPUT aux_vlrentot,
                              OUTPUT aux_vlrdirrf,
                              OUTPUT aux_perirrgt,
                              OUTPUT TABLE tt-erro).
                                    
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Nao foi possivel concluir " +
                                                  "a operacao.".
                                                  
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,   /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).         
                        END.
                                                                      
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                   
                    RETURN "NOK".
                END.
        END.
                        
    CREATE tt-dados-acumulo.
    ASSIGN tt-dados-acumulo.nrdconta = par_nrdconta
           tt-dados-acumulo.nraplica = par_nraplica
           tt-dados-acumulo.dsaplica = crapdtc.dsaplica
           tt-dados-acumulo.dtmvtolt = craprda.dtmvtolt
           tt-dados-acumulo.dtvencto = craprda.dtvencto
           tt-dados-acumulo.vlaplica = craprda.vlaplica
           tt-dados-acumulo.txaplica = IF  crapdtc.tpaplrdc = 1  THEN
                                          (EXP((1 + craplap.txaplica / 100),
                                                 craprda.qtdiauti) - 1) * 100
                                       ELSE            
                                           craplap.txaplica
           tt-dados-acumulo.txaplmes = craplap.txaplmes                        
           tt-dados-acumulo.vlsldrdc = aux_vlsldrdc.         
           tt-dados-acumulo.vlstotal = craprda.vlaplica.
            
    FOR EACH crapcap WHERE crapcap.cdcooper = par_cdcooper AND
                           crapcap.nrdconta = par_nrdconta AND
                           crapcap.nraplica = par_nraplica NO-LOCK:
                           
        CREATE tt-acumula.
        ASSIGN tt-acumula.nraplica = crapcap.nraplacu.
            
        IF  crapcap.tpaplacu = 2  THEN
            ASSIGN tt-acumula.tpaplica = "RPP".
        ELSE    
        IF  crapcap.tpaplacu = 3  THEN
            ASSIGN tt-acumula.tpaplica = "RDCA".
        ELSE
        IF  crapcap.tpaplacu = 5  THEN
            ASSIGN tt-acumula.tpaplica = "RDCA60".
        ELSE 
            DO:
                FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper     AND
                                   crapdtc.tpaplica = crapcap.tpaplacu
                                   NO-LOCK NO-ERROR.
                                      
                IF  AVAILABLE crapdtc  THEN
                    ASSIGN tt-acumula.tpaplica = crapdtc.dsaplica.
                ELSE
                    ASSIGN tt-acumula.tpaplica = "NAO CADASTRADO".
            END.
                             
        ASSIGN tt-acumula.vlsdrdca       = crapcap.vlsddapl
               tt-dados-acumulo.vlstotal = tt-dados-acumulo.vlstotal +
                                           crapcap.vlsddapl.
                        
    END. /** Fim do FOR EACH crapcap **/
                        
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**                Procedure para carregar tipos de aplicacao                **/
/******************************************************************************/
PROCEDURE obtem-tipos-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-tipo-aplicacao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-tipo-aplicacao.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem tipos de aplicacao".

    IF  NOT CAN-FIND(FIRST crapdtc WHERE crapdtc.cdcooper = par_cdcooper AND
                                         crapdtc.flgstrdc = TRUE         AND
                                        (crapdtc.tpaplrdc = 1            OR
                                         crapdtc.tpaplrdc = 2))          THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao ha tipo de aplicacao cadastrado.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".       
        END.
        
    FOR EACH crapdtc WHERE crapdtc.cdcooper = par_cdcooper AND
                           crapdtc.flgstrdc = TRUE         AND
                          (crapdtc.tpaplrdc = 1            OR
                           crapdtc.tpaplrdc = 2)           NO-LOCK:
                           
        CREATE tt-tipo-aplicacao.
        ASSIGN tt-tipo-aplicacao.tpaplica = crapdtc.tpaplica
               tt-tipo-aplicacao.dsaplica = crapdtc.dsaplica
               tt-tipo-aplicacao.tpaplrdc = crapdtc.tpaplrdc.
                              
    END. /** Fim do FOR EACH crapdtc **/

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**    Procedure para obter carencias de determinada faixa de dias (taxas)   **/
/******************************************************************************/
PROCEDURE obtem-dias-carencia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiaapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgvalid AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-carencia-aplicacao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-carencia-aplicacao.
    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Obtem carencias para aplicacao".
        
    IF  par_flgvalid  THEN
        DO:
            IF  NOT CAN-FIND(FIRST crapttx WHERE 
                                   crapttx.cdcooper  = par_cdcooper   AND
                                   crapttx.tptaxrdc  = par_tpaplica   AND
                                   crapttx.qtdiaini <= par_qtdiaapl   AND
                                   crapttx.qtdiafim >= par_qtdiaapl)  THEN
                DO:
                    ASSIGN aux_cdcritic = 892
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,          
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
            
                    RETURN "NOK".                    
                END.
                                     
            RETURN "OK".                         
        END.
        
    FOR EACH crapttx WHERE crapttx.cdcooper  = par_cdcooper AND
                           crapttx.tptaxrdc  = par_tpaplica AND
                           crapttx.qtdiaini <= par_qtdiaapl AND
                           crapttx.qtdiafim >= par_qtdiaapl NO-LOCK:
                                      
        CREATE tt-carencia-aplicacao.
        ASSIGN tt-carencia-aplicacao.cdperapl = crapttx.cdperapl
               tt-carencia-aplicacao.qtdiaini = crapttx.qtdiaini
               tt-carencia-aplicacao.qtdiafim = crapttx.qtdiafim
               tt-carencia-aplicacao.qtdiacar = crapttx.qtdiacar.
        
    END.
    
    IF  NOT CAN-FIND(FIRST tt-carencia-aplicacao)  THEN
        DO: 
            ASSIGN aux_cdcritic = 892
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,          
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
    
    RETURN "OK".           

END PROCEDURE.


/******************************************************************************/
/** Calcular qtde de dias para permanencia da aplicacao e/ou data do resgate **/
/******************************************************************************/
PROCEDURE calcula-permanencia-resgate:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  INPUT-OUTPUT PARAM par_qtdiaapl AS INTE                    NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_dtvencto AS DATE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Calcular permanencia da aplicacao".
    
    IF  par_qtdiaapl = 0 AND par_dtvencto = ?  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe a quantidade de dias para " +
                                  "permanencia da aplicacao.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                  
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).               
                                
            RETURN "NOK".
        END.
                
    IF  par_qtdiaapl > 0  THEN
        ASSIGN par_dtvencto = par_dtmvtolt + par_qtdiaapl.
    ELSE
    IF  par_dtvencto <> ?  THEN
        DO:
            IF  par_dtvencto < par_dtmvtolt  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Data de vencimento invalida.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).               
                               
                    RETURN "NOK".
                END.
                
            ASSIGN par_qtdiaapl = par_dtvencto - par_dtmvtolt.
        END.
             
    FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper     AND
                       crapdtc.tpaplica = par_tpaplica NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdtc  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de aplicacao deve ser 'RDCPRE' ou " +
                                  "'RDCPOS'.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                  
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).               
                                
            RETURN "NOK".
        END.
                
    FIND LAST crapfer WHERE crapfer.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                    
    IF  AVAILABLE crapfer                AND
        crapfer.dtferiad < par_dtvencto  AND
        crapdtc.tpaplrdc = 1             THEN 
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Data de vencimento invalida.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).               
                               
            RETURN "NOK".
        END.
                       
    RUN obtem-dias-carencia (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_tpaplica,
                             INPUT par_qtdiaapl,
                             INPUT TRUE,  /** Somente validacao **/
                             INPUT FALSE, /** Nao gera LOG      **/
                            OUTPUT TABLE tt-carencia-aplicacao,
                            OUTPUT TABLE tt-erro).
                
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0 
                           aux_dscritic = "Nao foi possivel concluir a " +
                                          "operacao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,   /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                        
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                                  
            RETURN "NOK".
        END.        
    
    RETURN "OK".
 
END PROCEDURE. 


/******************************************************************************/
/**   Procedure para calcular saldo acumulado para resgate (Aplicacoes RDC)  **/
/******************************************************************************/
PROCEDURE simular-saldo-acumulado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlaplica AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdperapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-acumulo.
    DEF OUTPUT PARAM TABLE FOR tt-acumula.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_qtddiaut AS INTE                                    NO-UNDO.
    
    DEF VAR aux_dtiniper AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimper AS DATE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-acumulo.
    EMPTY TEMP-TABLE tt-acumula.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Simular saldo de resgate acumulado".
           
    FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper AND
                       crapdtc.tpaplica = par_tpaplica NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdtc  THEN
        DO:
            ASSIGN aux_cdcritic = 346
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,   /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                        
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                                  
            RETURN "NOK".      
        END.

    IF  par_vlaplica <= 0  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe o valor da aplicacao.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,   /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                        
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                                  
            RETURN "NOK".      
        END.

    IF  par_dtvencto = ?  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe a data de vencimento.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,   /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                        
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                                  
            RETURN "NOK".      
        END.

    RUN acumula_aplicacoes (INPUT par_cdcooper,
                            INPUT par_cdprogra,
                            INPUT par_nrdconta,
                            INPUT 0,
                            INPUT par_tpaplica,
                            INPUT par_vlaplica,
                            INPUT par_cdperapl,
                           OUTPUT aux_vlstotal,
                           OUTPUT aux_txaplica,  
                           OUTPUT aux_txaplmes,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-acumula).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:     
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0 
                           aux_dscritic = "Nao foi possivel concluir a " +
                                          "simulacao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,   /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                        
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                                  
            RETURN "NOK".      
        END.
        
    IF  crapdtc.tpaplrdc = 1  THEN  /** RDCPRE **/   
        DO:          
            ASSIGN aux_dtiniper = par_dtmvtolt
                   aux_dtfimper = par_dtvencto
                   aux_qtddiaut = 0.
                             
            DO WHILE aux_dtiniper < aux_dtfimper:
                            
                DO WHILE TRUE:
                                
                    IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper))) OR
                        CAN-FIND(crapfer WHERE
                                 crapfer.cdcooper = par_cdcooper   AND
                                 crapfer.dtferiad = aux_dtiniper)  THEN
                        DO:
                            aux_dtiniper = aux_dtiniper + 1.
                            NEXT.
                        END.
                    
                    LEAVE.
                                
                END. /** Fim do DO WHILE TRUE **/
                            
                IF  aux_dtiniper >= aux_dtfimper  THEN
                    LEAVE.
                                                   
                ASSIGN aux_qtddiaut = aux_qtddiaut + 1
                       aux_dtiniper = aux_dtiniper + 1.
                            
            END. /** Fim do DO WHILE TRUE **/
                            
            RUN saldo_rdc_pre (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtolt,  
                               INPUT par_dtvencto,
                               INPUT TRUNCATE((aux_txaplica / 100),6),
                               INPUT-OUTPUT par_vlaplica,
                              OUTPUT aux_vlrdirrf,
                              OUTPUT aux_perirrgt,
                              OUTPUT TABLE tt-erro).
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0 
                                   aux_dscritic = "Nao foi possivel concluir " +
                                                  "a simulacao.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,   /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
                        
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                                  
                    RETURN "NOK".
                END.

            ASSIGN aux_txaplica = (EXP((1 + aux_txaplica / 100),
                                        aux_qtddiaut) - 1) * 100.
        END.
                 
    CREATE tt-dados-acumulo.
    ASSIGN tt-dados-acumulo.vlaplica = par_vlaplica
           tt-dados-acumulo.txaplica = aux_txaplica
           tt-dados-acumulo.txaplmes = aux_txaplmes                        
           tt-dados-acumulo.vlstotal = aux_vlstotal.         
           
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).           

    RETURN "OK".           
 
END PROCEDURE. 


/*............................................................................*/


PROCEDURE consulta-aplicacoes.

    DEF INPUT  PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador  AS CHAR                        NO-UNDO.  
    DEF INPUT  PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-tip-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-data-inicio   AS DATE                        NO-UNDO.
    DEF INPUT  PARAM p-data-fim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM p-cdprogra      AS CHAR                        NO-UNDO.    
    DEF INPUT  PARAM p-origem        AS INTE                        NO-UNDO.
                                       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-saldo-rdca.

    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
    
    FOR EACH tt-saldo-rdca:
        DELETE tt-saldo-rdca.
    END.
     
    ASSIGN aux_vllidtab = ""
           aux_qtdfaxir = 0
           aux_qtmestab = 0
           aux_perirtab = 0
           aux_sequen   = 0.
       
    FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    IF  p-tip-aplicacao = 0  OR
        p-tip-aplicacao = 1  THEN  /*** RDCA ***/
        DO:
            FIND craptab WHERE craptab.cdcooper = p-cdcooper   AND
                               craptab.nmsistem = "CRED"       AND   
                               craptab.cdempres = 0            AND
                               craptab.tptabela = "CONFIG"     AND   
                               craptab.cdacesso = "PERCIRRDCA" AND
                               craptab.tpregist = 0            NO-LOCK NO-ERROR.
                   
            DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):

                ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
                       aux_qtdfaxir = aux_qtdfaxir + 1
                       aux_qtmestab[aux_qtdfaxir] = DECIMAL(ENTRY(1,
                                                            aux_vllidtab,"#"))
                       aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,
                                                            aux_vllidtab,"#")).
    
            END.
        END.
        
    FOR EACH craprda WHERE craprda.cdcooper = p-cdcooper  AND
                           craprda.nrdconta = p-nro-conta AND
                           craprda.insaqtot = 0            
                           NO-LOCK USE-INDEX craprda3:

        IF  p-nro-aplicacao > 0 AND craprda.nraplica <> p-nro-aplicacao  THEN
            NEXT.
        
        IF  craprda.tpaplica = 3  AND 
           (p-tip-aplicacao  = 0  OR 
            p-tip-aplicacao  = 1) THEN  /** RDCA **/
            DO:  
                { sistema/generico/includes/b1wgen0004.i } 
            END.
        ELSE
        IF  craprda.tpaplica = 5  AND
           (p-tip-aplicacao  = 0  OR
            p-tip-aplicacao  = 1) THEN /** RDCA **/
            DO: 
                { sistema/generico/includes/b1wgen0004a.i }
            END.
        ELSE
        IF  p-tip-aplicacao = 0  OR
            p-tip-aplicacao = 2  THEN  /** RDC **/
            DO:
                FIND crapdtc WHERE crapdtc.cdcooper = p-cdcooper       AND
                                   crapdtc.tpaplica = craprda.tpaplica 
                                   NO-LOCK NO-ERROR.
                               
                IF  NOT AVAILABLE crapdtc  THEN
                    NEXT.
                
                IF  crapdtc.tpaplrdc = 1  THEN
                    DO:
                        RUN saldo_rdc_pre (INPUT p-cdcooper,
                                           INPUT craprda.nrdconta,
                                           INPUT craprda.nraplica,
                                           INPUT crapdat.dtmvtolt,
                                           INPUT ?,
                                           INPUT ?,
                                           INPUT 0,
                                           INPUT-OUTPUT aux_vlsldrdc,
                                           OUTPUT aux_vlrdirrf,
                                           OUTPUT aux_perirrgt,
                                           OUTPUT TABLE tt-erro).
                     
                        IF  RETURN-VALUE = "NOK"  THEN
                            RETURN "NOK".
                        
                        ASSIGN aux_sldpresg = craprda.vlsdrdca.
                    END.
                ELSE
                IF  crapdtc.tpaplrdc = 2  THEN
                    DO:
                        RUN saldo_rdc_pos (INPUT p-cdcooper,
                                           INPUT craprda.nrdconta,
                                           INPUT craprda.nraplica,
                                           INPUT crapdat.dtmvtolt,
                                           INPUT crapdat.dtmvtolt,
                                           INPUT FALSE,
                                           OUTPUT aux_vlsldrdc,
                                           OUTPUT aux_vlrentot,
                                           OUTPUT aux_vlrdirrf,
                                           OUTPUT aux_perirrgt,
                                           OUTPUT TABLE tt-erro).
                                                
                        IF  RETURN-VALUE = "NOK"  THEN
                            RETURN "NOK".
                        
                        RUN saldo_rgt_rdc_pos (INPUT p-cdcooper,
                                               INPUT craprda.nrdconta,
                                               INPUT craprda.nraplica,
                                               INPUT crapdat.dtmvtolt,
                                               INPUT crapdat.dtmvtolt,
                                               INPUT 0,
                                               OUTPUT aux_sldpresg,
                                               OUTPUT aux_vlrenrgt,
                                               OUTPUT aux_vlrdirrf,
                                               OUTPUT aux_perirrgt,
                                               OUTPUT aux_vlrrgtot,
                                               OUTPUT aux_vlirftot,
                                               OUTPUT aux_vlrendmm,
                                               OUTPUT aux_vlrvtfim,
                                               OUTPUT TABLE tt-erro).
                    
                        IF  RETURN-VALUE = "NOK"  THEN
                            RETURN "NOK".
                    
                        ASSIGN aux_sldpresg = IF  aux_vlrrgtot > 0  THEN
                                                  aux_vlrrgtot
                                              ELSE
                                                  craprda.vlsdrdca.
                    END.
            END.
        ELSE     
            NEXT.        
            
        IF (rd2_vlsdrdca <= 0 AND craprda.tpaplica = 5) OR
           (aux_vlsdrdca <= 0 AND craprda.tpaplica = 3) OR
           (aux_vlsldrdc <= 0 AND craprda.tpaplica <> 3 AND 
            craprda.tpaplica <> 5)                      THEN
            DO:
                /** Nao foi resgatado no dia **/
                FIND craplrg WHERE craplrg.cdcooper  = p-cdcooper       AND
                                   craplrg.nrdconta  = craprda.nrdconta AND
                                   craplrg.nraplica  = craprda.nraplica AND
                                   craplrg.dtresgat >= crapdat.dtmvtolt AND
                                   craplrg.dtmvtolt  = crapdat.dtmvtolt 
                                   NO-LOCK NO-ERROR.
                                    
                IF  NOT AVAILABLE craplrg  THEN
                    NEXT.                               
            END.

        ASSIGN aux_sldresga = aux_sldpresg.

        FIND FIRST craptab WHERE craptab.cdcooper = p-cdcooper AND
                                 craptab.nmsistem = "CRED"     AND
                                 craptab.tptabela = "BLQRGT"   AND
                                 craptab.cdempres = 0          AND
                                 craptab.cdacesso = 
                                      STRING(craprda.nrdconta,"9999999999") AND
                                 INT(SUBSTR(craptab.dstextab,1,7)) = 
                                      craprda.nraplica 
                                 NO-LOCK NO-ERROR.

        IF  AVAILABLE craptab  THEN
            ASSIGN aux_indebcre = "B".
        ELSE
            DO:
                IF  craprda.tpaplica = 3  THEN
                    DO:
                        IF  craprda.inaniver  = 1                 OR
                           (craprda.inaniver  = 0                 AND
                            craprda.dtfimper <= crapdat.dtmvtolt) THEN 
                            ASSIGN aux_indebcre = "D". 
                        ELSE 
                            ASSIGN aux_indebcre = " ".
                    END.
                ELSE
                IF  craprda.tpaplica = 5  THEN
                    DO:
                        IF  craprda.inaniver  = 1                      OR
                          ((craprda.dtfimper <= crapdat.dtmvtolt)      AND
                           (craprda.dtfimper - craprda.dtmvtolt) > 50) THEN
                            ASSIGN aux_indebcre = "D". 
                        ELSE 
                            ASSIGN aux_indebcre = " ".
                    END.
                ELSE
                    ASSIGN aux_indebcre = " ".
            END.

        FIND FIRST craplrg WHERE craplrg.cdcooper = p-cdcooper       AND 
                                 craplrg.nrdconta = craprda.nrdconta AND
                                 craplrg.tpaplica = craprda.tpaplica AND
                                 craplrg.nraplica = craprda.nraplica AND 
                                 craplrg.inresgat = 0                
                                 NO-LOCK NO-ERROR. 

        IF  NOT AVAILABLE craplrg  THEN
            FIND FIRST craplrg WHERE craplrg.cdcooper = p-cdcooper       AND 
                                     craplrg.nrdconta = craprda.nrdconta AND
                                     craplrg.tpaplica = craprda.tpaplica AND
                                     craplrg.nraplica = craprda.nraplica AND 
                                     craplrg.inresgat = 1                AND
                                     craplrg.dtmvtolt = crapdat.dtmvtolt 
                                     NO-LOCK USE-INDEX craplrg2 NO-ERROR. 
                                
        CREATE tt-saldo-rdca.
        ASSIGN tt-saldo-rdca.dtmvtolt = craprda.dtmvtolt
               tt-saldo-rdca.nraplica = craprda.nraplica
               tt-saldo-rdca.dshistor = (IF  craprda.tpaplica = 3  THEN 
                                             "Apl. RDCA  :"
                                         ELSE
                                         IF  craprda.tpaplica = 5  THEN
                                             "Apl. RDCA60:"
                                         ELSE
                                             "Apl. " + 
                                             STRING(crapdtc.dsaplica,"x(6)") + 
                                             ":") +
                                         STRING(craprda.vlaplica,
                                                "zzz,zzz,zz9.99") 
               tt-saldo-rdca.nrdocmto = STRING(craprda.nraplica,"zzz,zz9") 
               tt-saldo-rdca.dtvencto = craprda.dtvencto
               tt-saldo-rdca.indebcre = aux_indebcre 
               tt-saldo-rdca.vllanmto = IF  craprda.tpaplica = 3  THEN
                                            aux_vlsdrdca
                                        ELSE
                                        IF  craprda.tpaplica = 5  THEN
                                            rd2_vlsdrdca
                                        ELSE 
                                            aux_vlsldrdc
               tt-saldo-rdca.sldresga = aux_sldresga
               tt-saldo-rdca.cddresga = IF  AVAILABLE craplrg  THEN
                                            "S"
                                        ELSE
                                            "N".

    END. /*** Fim do FOR EACH craprda ***/
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-extrato-rdca.

    DEF INPUT  PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador  AS CHAR                        NO-UNDO.  
    DEF INPUT  PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-tip-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-saldo-aplic   AS DECI                        NO-UNDO.
    DEF INPUT  PARAM p-data-inicio   AS DATE                        NO-UNDO.
    DEF INPUT  PARAM p-data-fim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM p-cdprogra      AS CHAR                        NO-UNDO.    
    DEF INPUT  PARAM p-origem        AS INTE                        NO-UNDO. 

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extr-rdca.
            
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
    
    FOR EACH tt-extr-rdca:
        DELETE tt-extr-rdca.
    END.
   
    ASSIGN aux_sequen   = 0
           aux_lsoperad = "TI,CONTABILIDADE,COORD.ADM/FINANCEIRO".
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.
        
    FIND craprda WHERE craprda.cdcooper = p-cdcooper      AND
                       craprda.nrdconta = p-nro-conta     AND
                       craprda.nraplica = p-nro-aplicacao NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE craprda  THEN
        DO:
            ASSIGN i-cod-erro = 426
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i } 

            RETURN "NOK".
        END.

    FIND crapope WHERE crapope.cdcooper = p-cdcooper  AND
                       crapope.cdoperad = p-cod-operador NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope  THEN
        DO:
            ASSIGN i-cod-erro = 67 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.

    IF  p-cdcooper = 3  THEN
        aux_lsoperad = aux_lsoperad + "," + STRING(crapope.cddepart).

    IF  NOT CAN-DO(aux_lsoperad,crapope.dsdepar)  THEN  
        aux_listahis = "113,116,118,119,121,126,143,144,176,178,179," +
                       "183,861,862,868,871,492,493,494,495,875,876,877," +
                       "472,473,474,475,463,478,476,477,527,528,529,530," +
                       "531,532,533,534".
    ELSE       
        aux_listahis = "113,116,117,118,119,121,126,143,144,176,178,179," +
                       "183,861,862,868,871,492,493,494,495,875,876,877,180," +
                       "472,473,474,475,463,478,476,477,527,528,529,530," +
                       "531,532,533,534".
    
    /* Nao lista aplicacoes resgatadas a mais de 1 ano */
    IF crapope.cddepart <> 18 THEN    /* SUPORTE */
        IF  p-saldo-aplic <= 0                           AND
            craprda.dtsaqtot < (crapdat.dtmvtolt - 365)  THEN
            NEXT.
    
    /* Tratamento para as aplicacoes da Cecrisacred que foram convertidas */  
    IF  p-cdcooper = 5                 AND 
       (craprda.dtmvtolt = 09/01/2003  OR
        craprda.dtmvtolt = 11/01/2003) THEN 
        ASSIGN aux_vlstotal = craprda.vlaplica. 
    ELSE 
        ASSIGN aux_vlstotal = 0.
        
    IF  craprda.tpaplica = 3  THEN
        ASSIGN aux_dsaplica = STRING(craprda.nraplica,"zzz,zz9") + " - RDCA".
    ELSE
    IF  craprda.tpaplica = 5  THEN
        ASSIGN aux_dsaplica = STRING(craprda.nraplica,"zzz,zz9") + " - RDCA60".
    ELSE
        DO:
            FIND crapdtc WHERE crapdtc.cdcooper = p-cdcooper       AND
                               crapdtc.tpaplica = craprda.tpaplica 
                               NO-LOCK NO-ERROR.
                               
            IF  AVAILABLE crapdtc  THEN
                ASSIGN aux_dsaplica = STRING(craprda.nraplica,"zzz,zz9") +
                                      " - " + STRING(crapdtc.dsaplica,"x(6)").
            ELSE
                ASSIGN aux_dsaplica = STRING(craprda.nraplica,"zzz,zz9").
        END.
        
    FOR EACH craplap WHERE craplap.cdcooper = p-cdcooper      AND
                           craplap.nrdconta = p-nro-conta     AND
                           craplap.nraplica = p-nro-aplicacao AND
                           CAN-DO(aux_listahis,STRING(craplap.cdhistor)) 
                           USE-INDEX craplap2 NO-LOCK:

        FIND craphis WHERE craphis.cdcooper = p-cdcooper       AND
                           craphis.cdhistor = craplap.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craphis  THEN
            DO:
                ASSIGN i-cod-erro = 80 
                       c-dsc-erro = " ".
           
                { sistema/generico/includes/b1wgen0001.i }

                RETURN "NOK".
            END.

        aux_dshistor = STRING(craphis.cdhistor,"999") + "-" + craphis.dshistor.
        
        IF  NOT CAN-DO("999",STRING(craphis.cdhistor))  THEN
            DO:
                IF  CAN-DO(aux_lsoperad,STRING(crapope.cddepart)) AND   
                   (craphis.cdhistor = 116                OR
                    craphis.cdhistor = 179)               THEN
                    .
                ELSE
                IF  craphis.indebcre = "C"  THEN
                    aux_vlstotal = aux_vlstotal + craplap.vllanmto.
                ELSE
                IF  craphis.indebcre = "D"  THEN
                    aux_vlstotal = aux_vlstotal - craplap.vllanmto.
                ELSE
                    DO:
                        ASSIGN i-cod-erro = 83
                               c-dsc-erro = " ".
           
                        { sistema/generico/includes/b1wgen0001.i }

                        RETURN "NOK".
                    END.
            END.

        CREATE tt-extr-rdca.
        
        ASSIGN tt-extr-rdca.dtmvtolt = craplap.dtmvtolt
               tt-extr-rdca.dshistor = aux_dshistor
               tt-extr-rdca.nrdocmto = craplap.nrdocmto
               tt-extr-rdca.indebcre = craphis.indebcre
               tt-extr-rdca.vllanmto = craplap.vllanmto
               tt-extr-rdca.vlsldapl = aux_vlstotal
               tt-extr-rdca.txaplica = IF  craplap.txaplica < 0  THEN 
                                           0 
                                       ELSE
                                           craplap.txaplica.
               tt-extr-rdca.dsaplica = aux_dsaplica.

    END. /* Fim do FOR EACH craplap */
    
END PROCEDURE.

PROCEDURE saldo-resg-rdca:

    DEF  INPUT PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-nro-aplicacao AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-cdprogra      AS CHAR                        NO-UNDO.
           
    DEF OUTPUT PARAM p-vlsdrdca      AS DECI DECIMALS 8             NO-UNDO.
    DEF OUTPUT PARAM p-sldpresg      AS DECI DECIMALS 8             NO-UNDO.
                                           
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.    

    ASSIGN aux_vllidtab = ""
           aux_qtdfaxir = 0
           aux_qtmestab = 0
           aux_perirtab = 0
           aux_sequen   = 0.
       
    FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    FIND craptab WHERE craptab.cdcooper = p-cdcooper   AND
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

    FIND craprda WHERE craprda.cdcooper = p-cdcooper      AND
                       craprda.nrdconta = p-nro-conta     AND
                       craprda.nraplica = p-nro-aplicacao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craprda  THEN
        DO:
            ASSIGN i-cod-erro = 426 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.
        
    IF  craprda.tpaplica = 3  THEN
        DO:  
            { sistema/generico/includes/b1wgen0004.i } 
        END.
    ELSE
    IF  craprda.tpaplica = 5  THEN
        DO: 
            { sistema/generico/includes/b1wgen0004a.i }
        END.
            
    ASSIGN p-vlsdrdca = aux_vlsdrdca
           p-sldpresg = aux_sldpresg.
    
    RETURN "OK".

END PROCEDURE.


/* =========================================================================
   ================ ROTINAS PARA AS APLICACOES RDC - PRE/POS ===============
   ========================================================================= */

PROCEDURE saldo_rdc_pre:

    /* Rotina de calculo do saldo das aplicacoes RDC PRE para resgate
       enxergando as novas aliquotas de imposto de renda.
       Retorna o saldo para resgate no dia do vencimento.
       Se resgatado antes nao recebe nada, saldo em craprda.vlsdrdca.
               
       Observacao: Se a conta e o numero da aplicacao estiverem ZERADOS, o
                   programa fara uma simulacao da aplicacao.
                   O saldo sera o mesmo do craprda.vlsdrdca enquanto a
                   aplicacao estiver em carencia */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF        INPUT PARAM par_txaplica AS DEC DECIMALS 8              NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsdrdca AS DECIMAL DECIMALS 4
               /*LIKE craprda.vlsdrdca*/          NO-UNDO.
    DEF       OUTPUT PARAM par_vlrdirrf LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    ASSIGN aux_pcajsren = 0       
           aux_nrmeses  = 0
           aux_nrdias   = 0  
           aux_perirapl = 0
           aux_vlrenacu = 0
           aux_vlrentot = 0
           aux_qtdfaxir = 0
           par_vlrdirrf = 0.
     
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
     FIND craptab WHERE craptab.nmsistem = "CRED"        AND   
                       craptab.cdempres = 0              AND
                       craptab.tptabela = "CONFIG"       AND   
                       craptab.cdacesso = "PERCIRFRDC"   AND
                       craptab.tpregist = 0              AND
                       craptab.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtdiatab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    END.                 

    /* Calcula o saldo de uma aplicacao existente */
    IF   par_nrctaapl <> 0   AND
         par_nraplres <> 0   THEN
         DO:      
             FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                                craprda.nrdconta = par_nrctaapl   AND
                                craprda.nraplica = par_nraplres
                                NO-LOCK NO-ERROR.
                   
             IF   NOT AVAILABLE craprda   THEN                   
                  DO:     
                      ASSIGN i-cod-erro = 426
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.
         
             /*** Verifica se aplicacao esta em carencia ***/
             IF   craprda.dtvencto >= crapdat.dtmvtolt   AND
                  craprda.dtvencto <= crapdat.dtmvtopr   THEN
                  .
             ELSE     
             IF   par_dtmvtolt - craprda.dtmvtolt < craprda.qtdiaapl   THEN
                  DO:
                      ASSIGN par_vlsdrdca = craprda.vlsdrdca.
                      RETURN "OK".
                  END.
         
             /*** Buscar as taxas contratas ***/
             FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                                      craplap.nrdconta = craprda.nrdconta   AND
                                      craplap.nraplica = craprda.nraplica   AND
                                      craplap.dtmvtolt = craprda.dtmvtolt   
                                      NO-LOCK NO-ERROR.
        
             IF   NOT AVAILABLE craplap   THEN  
                  DO:
                      ASSIGN i-cod-erro = 90
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.

             ASSIGN par_txaplica = TRUNCATE(craplap.txaplica / 100,8)
                    par_dtiniper = craprda.dtmvtolt
                    par_dtfimper = craprda.dtvencto
                    par_vlsdrdca = craprda.vlsdrdca.
         END.

    ASSIGN aux_nrdias = par_dtfimper - par_dtiniper.
    IF   aux_nrdias = ?   OR
         aux_nrdias = 0   THEN                   
         DO: 
             ASSIGN i-cod-erro = 840
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}
 
             RETURN "NOK".
         END.
    DO aux_occ = aux_qtdfaxir TO 1 BY -1:
       IF   aux_nrdias > aux_qtdiatab[aux_occ]   THEN
            DO:
                ASSIGN aux_perirapl = aux_perirtab[aux_occ].
                LEAVE.
            END.
    END.        

    IF   aux_perirapl = 0   THEN          
         ASSIGN aux_perirapl = aux_perirtab[4].
    
    IF   aux_perirapl  = 0   AND  
         par_cdcooper <> 3   THEN
         DO:
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
          END.

    DO WHILE par_dtiniper < par_dtfimper:

       DO WHILE TRUE:

          IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = par_dtiniper)   THEN
               DO:
                   par_dtiniper = par_dtiniper + 1.
                   NEXT.
               END.
           
               LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   par_dtiniper >= par_dtfimper   THEN
            LEAVE.

       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * par_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              aux_vlrentot = aux_vlrentot + aux_vlrendim
              par_dtiniper = par_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */
    ASSIGN aux_vlrentot = ROUND(aux_vlrentot,2)
           par_vlsdrdca = ROUND(par_vlsdrdca,2)
           aux_vlsldapl = ROUND(par_vlsdrdca - 
                          TRUNCATE((aux_vlrentot * aux_perirapl / 100),2),2)
           par_vlrdirrf = TRUNCATE((aux_vlrentot * aux_perirapl / 100),2)
           par_perirrgt = aux_perirapl.

END PROCEDURE. /* Fim saldo_rdc_pre */

PROCEDURE provisao_rdc_pre:

    /* Rotina de calculo da provisao no final do mes e no vencimento. */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
             /*LIKE craprda.vlsdrdca Magui em 08/10/2007*/             NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
             /*LIKE craprda.vlsdrdca Magui em 08/10/2007*/             NO-UNDO.
    DEF       OUTPUT PARAM par_vllctprv LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    ASSIGN par_vllctprv = 0
           aux_vlrendim = 0
           par_vlsdrdca = 0
           par_vlrentot = 0.
        
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Buscas as taxas contratadas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_txaplica = craplap.txaplica / 100.

    FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper       AND
                           craplap.nrdconta = craprda.nrdconta   AND 
                           craplap.nraplica = craprda.nraplica   AND
                          (craplap.cdhistor = 474                OR /* AJT+ */
                           craplap.cdhistor = 463)                  /* AJT- */
                           NO-LOCK:

        IF  craplap.cdhistor = 474  THEN /* AJT+ */
            ASSIGN par_vllctprv = par_vllctprv + craplap.vllanmto.
        ELSE
        IF  craplap.cdhistor = 463  THEN /* AJT- */
            ASSIGN par_vllctprv = par_vllctprv - craplap.vllanmto.
    END.

    ASSIGN par_vlsdrdca = craprda.vlsdrdca + par_vllctprv.

    DO WHILE par_dtiniper < par_dtfimper:
   
       DO WHILE TRUE:
        
          IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtiniper)))               OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper    AND
                                      crapfer.dtferiad = par_dtiniper)   THEN
               DO:
                   par_dtiniper = par_dtiniper + 1.
                   NEXT.
               END.
      
          LEAVE.
   
       END.  /*  Fim do DO WHILE TRUE  */
 
       IF   par_dtiniper >= par_dtfimper   THEN
            LEAVE.
        
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              par_vlrentot = par_vlrentot + aux_vlrendim
              par_dtiniper = par_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */

    ASSIGN par_vlrentot = ROUND(par_vlrentot,2)
           par_vlsdrdca = ROUND(par_vlsdrdca,2).
                  
END PROCEDURE. /* Fim provisao_rdc_pre */

PROCEDURE ajuste_provisao_rdc_pre:
    
    /* Rotina de calculo do ajuste da provisao a estornar nos casos de resgate
       antes do vencimento.

       Observacoes: Para se saber o quanto de rendimento esta sendo resgatado
                    se calculo o quanto esse resgate rendeu ate a ultima pro
                    visao */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_vllanmto LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM par_vlestprv LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_vllctprv LIKE craplap.vllanmto          NO-UNDO.
    DEF                VAR aux_pcajtprv AS DEC DECIMALS 2              NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    
    ASSIGN aux_vllctprv = 0
           aux_pcajtprv = 0
           par_vlestprv = 0.

    FOR EACH tt-erro:
        DELETE tt-erro.
    END.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    ASSIGN aux_dtmvtolt = craprda.dtmvtolt
           aux_dtultdia = craprda.dtatslmx.
                  
    IF   aux_dtultdia <> ?   THEN
         DO:
             IF   par_vllanmto <> craprda.vlsdrdca   THEN
                  DO:
                      /*** Buscas as taxas contratadas ***/
                      FIND FIRST craplap
                           WHERE craplap.cdcooper = par_cdcooper       AND
                                 craplap.nrdconta = craprda.nrdconta   AND
                                 craplap.nraplica = craprda.nraplica   AND
                                 craplap.dtmvtolt = craprda.dtmvtolt   
                                 NO-LOCK NO-ERROR.
                      IF   NOT AVAILABLE craplap   THEN  
                           DO:
                               ASSIGN i-cod-erro = 90
                                      c-dsc-erro = " ".
           
                             {sistema/generico/includes/b1wgen0001.i}

                               RETURN "NOK".
                           END.

                      ASSIGN aux_txaplica = craplap.txaplica / 100.
 
                      DO WHILE aux_dtmvtolt < aux_dtultdia:
                         DO WHILE TRUE:
                            IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                                 CAN-FIND(crapfer WHERE crapfer.cdcooper = 
                                                                par_cdcooper AND
                                           crapfer.dtferiad = aux_dtmvtolt) THEN
                                 DO:
                                     aux_dtmvtolt = aux_dtmvtolt + 1.
                                     NEXT.
                                 END.
                            LEAVE.
                         END.  /*  Fim do DO WHILE TRUE  */
                         IF   aux_dtmvtolt >= aux_dtultdia   THEN
                              LEAVE.
                     
                         ASSIGN aux_vlrendim = 
                                    TRUNCATE(par_vllanmto * aux_txaplica,8)
                                par_vllanmto = par_vllanmto + aux_vlrendim 
                                par_vlestprv = par_vlestprv + aux_vlrendim
                                aux_dtmvtolt = aux_dtmvtolt + 1.
                      END.  /*  Fim do DO WHILE  */
                      ASSIGN par_vlestprv = ROUND(par_vlestprv,2).
                  END.
             ELSE
                  /*** quando resgate total reverter todas as provisoes ***/
                  FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper AND
                                     craplap.nrdconta = craprda.nrdconta AND 
                                     craplap.nraplica = craprda.nraplica AND
                                    (craplap.cdhistor = 474  OR  /* AJT+ */
                                     craplap.cdhistor = 463) /* AJT- */
                                     NO-LOCK:
                      IF   craplap.cdhistor = 474   THEN /* AJT+ */
                           ASSIGN par_vlestprv = 
                                      par_vlestprv + craplap.vllanmto.
                      ELSE
                           IF   craplap.cdhistor = 463   THEN /* AJT- */
                                ASSIGN par_vlestprv = 
                                           par_vlestprv - craplap.vllanmto.
                  END.
         END.                       
END PROCEDURE. /* Fim ajuste_provisao_rdc_pre */

PROCEDURE saldo_rdc_pos:
        
    /* Rotina de calculo do saldo das aplicacoes RDC POS enxergando as novas
       aliquotas de imposto de renda. Retorna o saldo ate a data.
       
       Observacao: O saldo sera craprda.vlsdrdca sera craprda.vlaplica -
                   resgate trazidos a valor presente */
    
    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_dtcalsld LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_flantven AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
                   /*LIKE craprda.vlsdrdca Magui em 01/10/2007*/       NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
                   /*LIKE craprda.vlsdrdca Magui em 01/10/2007*/       NO-UNDO.
    DEF       OUTPUT PARAM par_vlrdirrf LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

     ASSIGN aux_pcajsren = 0       
           aux_nrmeses  = 0
           aux_nrdias   = 0  
           aux_perirapl = 0
           aux_vlrenacu = 0
           par_vlrdirrf = 0
           aux_vlrentot = 0
           aux_qtdfaxir = 0.
    
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
    
    FIND craptab WHERE craptab.nmsistem = "CRED"         AND   
                       craptab.cdempres = 0              AND
                       craptab.tptabela = "CONFIG"       AND   
                       craptab.cdacesso = "PERCIRFRDC"   AND
                       craptab.tpregist = 0              AND
                       craptab.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtdiatab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    END.                 
    
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    ASSIGN aux_nrdias = craprda.dtvencto - craprda.dtmvtolt.
    IF   aux_nrdias = ?   OR
         aux_nrdias = 0   THEN                   
         DO: 
             ASSIGN i-cod-erro = 840
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    DO aux_occ = aux_qtdfaxir TO 1 BY -1:
       IF   aux_nrdias > aux_qtdiatab[aux_occ]   THEN
            DO:
                ASSIGN aux_perirapl = aux_perirtab[aux_occ].
                LEAVE.
            END.
    END.        
     
    IF   aux_perirapl = 0   THEN          
         ASSIGN aux_perirapl = aux_perirtab[4].
    
    IF   aux_perirapl = 0   AND  
         par_cdcooper <> 3 THEN
         DO:
             ASSIGN i-cod-erro = 180
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
          END.
         
    ASSIGN aux_dtfimper = par_dtcalsld
           par_vlsdrdca = craprda.vlsdrdca
           par_perirrgt = aux_perirapl.

    /*** Verifica se aplicacao esta em carencia ***/
    IF   craprda.dtvencto >= crapdat.dtmvtolt   AND
         craprda.dtvencto <= crapdat.dtmvtopr   THEN
         .
    ELSE     
    IF   par_dtmvtolt - craprda.dtmvtolt < craprda.qtdiauti   THEN
         DO:
             ASSIGN par_vlsdrdca = craprda.vlsdrdca.
             RETURN.
         END.

    IF   par_flantven = YES   THEN  /* TAXA MINIMA */
         ASSIGN par_vlsdrdca = craprda.vlsltxmm
                aux_dtiniper = craprda.dtatslmm.
    ELSE
         ASSIGN par_vlsdrdca  = craprda.vlsltxmx
                aux_dtiniper = craprda.dtatslmx.
     
    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt 
                             USE-INDEX craplap5 NO-LOCK NO-ERROR.
     
    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
             
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.      
     
    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).
                 
    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:     
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.                                  END.
               
          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
       
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */

       IF   NOT AVAILABLE crapmfx   THEN  
            DO: 
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.
        
       ASSIGN aux_txaplmes = 
                     (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
                     
       /* Calcula o saldo com a taxa minina se for antes do vencimento */
       IF   par_flantven = YES   AND
            craplap.txaplica <> craplap.txaplmes   THEN
            aux_txaplica = 
                ROUND((aux_txaplmes * craplap.txaplmes / 100 ) / 100 ,8).
       ELSE 
            DO:           
                aux_txaplica =
                    ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).

                IF   aux_dtiniper > aux_dtinitax AND 
                     aux_dtiniper < aux_dtfimtax     THEN
                     DO:       
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(aux_dtiniper) - 1,
                                          DAY(aux_dtiniper),YEAR(aux_dtiniper)) 
                                             NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(aux_dtiniper) = 1   THEN
                                  aux_dtinipop = aux_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */
                                  aux_dtinipop = DATE(MONTH(aux_dtiniper),01,
                                                          YEAR(aux_dtiniper)).

                        FIND crapmfx WHERE 
                             crapmfx.cdcooper = par_cdcooper AND
                             crapmfx.dtmvtolt = aux_dtinipop AND
                             crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.  
                        
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO: 
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".
                                
                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.
                                               
                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).  
              
                        IF   aux_txaplica < aux_txdiapop / 100   THEN
                             ASSIGN aux_txaplica = aux_txdiapop / 100. 
                     END.
            END.          
       
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              aux_vlrentot = aux_vlrentot + aux_vlrendim
              aux_dtiniper = aux_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */

    ASSIGN aux_vlrentot = ROUND(aux_vlrentot,2)
           par_vlrentot = aux_vlrentot
           par_vlsdrdca = ROUND(par_vlsdrdca,2)
           aux_vlsldapl = ROUND(par_vlsdrdca - 
                          TRUNCATE((aux_vlrentot * aux_perirapl / 100),2),2)
           par_vlrdirrf = TRUNCATE((aux_vlrentot * aux_perirapl / 100),2)
           par_perirrgt = aux_perirapl.
    
END PROCEDURE. /* Fim saldo_rdc_pos */

PROCEDURE saldo_rgt_rdc_pos:

    /* Rotina de calculo do saldo das aplicacoes RDC POS para resgate 
       enxergando as novas aliquotas de imposto de renda.
       Retorna o saldo para resgate no dia solicitado.
       
       Observacoes: Saldo sera craprda.vlsdrdca sera craprda.vlaplica menos
                    os resgates a valor presente */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_dtaplrgt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_vlsdorgt LIKE craprda.vlsdrdca          NO-UNDO.
    DEF       OUTPUT PARAM par_vlsddrgt LIKE craprda.vlsdrdca          NO-UNDO.
    /* par_vlsddrgt = valor do resgate total sem irrf ou o solicitado */
    DEF       OUTPUT PARAM par_vlrenrgt LIKE craprda.vlsdrdca          NO-UNDO.
    /* par_vlrenrgt = rendimento total a ser pago quando resgate total ou
                      o rendimento do esta sendo solicitado */
    DEF       OUTPUT PARAM par_vlrdirrf LIKE craplap.vllanmto          NO-UNDO.
    /* par_vlrdirrf = irrf do que foi solicitado */
    DEF       OUTPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    /* par_perirrgt = percentual de aliquota para calculo do irrf */
    DEF       OUTPUT PARAM par_vlrgttot AS DEC DECIMALS 2              NO-UNDO.
    /* par_vlrgttot = resgate para zerar a aplicacao */
    DEF       OUTPUT PARAM par_vlirftot AS DEC DECIMALS 2              NO-UNDO.
    /* par_vlirftot = irrf para finalizar a aplicacao */
    DEF       OUTPUT PARAM par_vlrendmm AS DEC DECIMALS 2              NO-UNDO.
    /* par_vlrendmm = rendimento da ultima provisao ate a data do resgate */
    DEF       OUTPUT PARAM par_vlrvtfim LIKE craplap.vllanmto          NO-UNDO.
    /* par_vlrvtfim = quanta provisao reverter para zerar a aplicacao */
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF                VAR aux_txaplrgt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF                VAR aux_vlrenmlt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_vlrgtsol LIKE craprda.vlsdrdca          NO-UNDO.
    DEF                VAR aux_vlrnttmm LIKE craplap.vlrendmm          NO-UNDO.
    DEF                VAR aux_vlrenpgt LIKE craplap.vllanmto          NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    DEF BUFFER crablap FOR craplap.
    
    ASSIGN aux_vlrgtsol = 0     aux_nrmeses  = 0
           aux_nrdias   = 0     aux_perirapl = 0
           aux_vlrenacu = 0     aux_vlrenmlt = 0
           par_vlsddrgt = 0     par_vlrenrgt = 0 
           par_vlrdirrf = 0     par_perirrgt = 0
           par_vlrgttot = 0     par_vlirftot = 0
           par_vlrendmm = 0     par_vlrvtfim = 0.
        
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    FIND craptab WHERE craptab.nmsistem = "CRED"         AND   
                       craptab.cdempres = 0              AND
                       craptab.tptabela = "CONFIG"       AND   
                       craptab.cdacesso = "PERCIRFRDC"   AND
                       craptab.tpregist = 0              AND
                       craptab.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtdiatab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    END.                 
    
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_dtiniper = craprda.dtmvtolt
           aux_dtfimper = par_dtaplrgt
           aux_vlrgtsol = par_vlsdorgt.
    
    IF   aux_vlrgtsol = 0   THEN
         ASSIGN aux_vlrgtsol = craprda.vlsltxmm
                aux_dtiniper = craprda.dtatslmm. 
    /*** Preciso do que ja foi provisionado e estornada para zerar a 
         aplicacao se resgate total ***/
    FOR EACH crablap WHERE  crablap.cdcooper = par_cdcooper
                       AND  crablap.nrdconta = craprda.nrdconta
                       AND  crablap.nraplica = craprda.nraplica
                       AND (crablap.cdhistor = 529 OR
                            crablap.cdhistor = 531 OR
                            crablap.cdhistor = 532) NO-LOCK:
        IF   crablap.cdhistor = 529   THEN  /*provisao*/
             ASSIGN aux_vlrnttmm = aux_vlrnttmm + crablap.vlrendmm
                    par_vlrvtfim = par_vlrvtfim + crablap.vllanmto.
        ELSE
             IF  crablap.cdhistor = 532 THEN /*rendimento cred*/
                 ASSIGN aux_vlrenpgt = aux_vlrenpgt + crablap.vllanmto.
             ELSE
                 ASSIGN par_vlrvtfim = par_vlrvtfim - crablap.vllanmto
                        aux_vlrnttmm = aux_vlrnttmm - crablap.vlrendmm.
    END.                     
    
    /*** Verifica se aplicacao esta em carencia ***/
    IF   par_dtaplrgt - craprda.dtmvtolt < craprda.qtdiauti   THEN
         DO:
             ASSIGN par_vlsddrgt = craprda.vlsdrdca
                    par_vlrgttot = craprda.vlsdrdca
                    par_vlrendmm = aux_vlrnttmm.
             RETURN.
         END.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             USE-INDEX craplap5 NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Retorna percentual do imposto de renda a ser cobrado no resgate ***/
    IF   craplap.txaplmes <> 0   AND
         par_dtaplrgt     <> ?   THEN
         DO:
             ASSIGN aux_nrdias = par_dtaplrgt - craprda.dtmvtolt.
             IF   aux_nrdias = ?   OR
                  aux_nrdias = 0   THEN                   
                  DO: 
                      ASSIGN i-cod-erro = 840
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.

             DO aux_occ = aux_qtdfaxir TO 1 BY -1:
                IF   aux_nrdias > aux_qtdiatab[aux_occ]   THEN
                     DO:
                        ASSIGN aux_perirrgt = aux_perirtab[aux_occ].
                        LEAVE.
                     END.
             END.        
             
             IF   aux_perirrgt = 0   THEN          
                  ASSIGN aux_perirrgt = aux_perirtab[4].

             IF   aux_perirrgt = 0   AND  
                  par_cdcooper <> 3 THEN
                  DO:
                      ASSIGN i-cod-erro = 180
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.
         END.
    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.

          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */

       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100
              aux_txaplrgt = 
                  ROUND(((aux_txaplmes * craplap.txaplmes / 100) / 100),8)
              aux_vlrenrgt = TRUNCATE(aux_vlrgtsol * aux_txaplrgt,8)
              aux_vlrgtsol = aux_vlrgtsol + aux_vlrenrgt 
              aux_vlrenmlt = aux_vlrenmlt + aux_vlrenrgt
              aux_dtiniper = aux_dtiniper + 1.
    END.  /*  Fim do DO WHILE  */

    ASSIGN aux_vlrenmlt = ROUND(aux_vlrenmlt,2)
           par_vlrenrgt = aux_vlrenmlt
           aux_vlrgtsol = ROUND(aux_vlrgtsol,2)
           par_vlrdirrf = TRUNCATE((par_vlrenrgt * aux_perirrgt / 100),2)
           par_perirrgt = aux_perirrgt.
    IF   par_vlsdorgt <> 0  THEN /* resgate parcial */  
         DO:       
             ASSIGN par_vlsddrgt = par_vlsdorgt.
             RETURN.
         END.

    /*** Quando resgate total precisamos descobrir o quanto falta pagar de 
         rendimento e de irrf ***/
    ASSIGN par_vlsddrgt = aux_vlrgtsol. /* falta descontar o irrf */ 

    /*** Busca todos os rendimentos que foram calculados quando houve um       
         lancamento 529 a taxa minima. E os rendimentos ja pagos ***/
    ASSIGN par_vlrendmm = par_vlrenrgt
                    /* no caso de resgate total, o rendimento calculado acima e                         so da ultima provisao ate a data do resgate */
           aux_vlrnttmm = (craprda.vlsltxmm - craprda.vlsdrdca) + par_vlrenrgt
           par_vlrenrgt = aux_vlrnttmm 
           par_vlrgttot = ROUND(par_vlsddrgt -
                          TRUNCATE((par_vlrenrgt * par_perirrgt / 100),2),2).
                
END PROCEDURE. /* Fim saldo_rgt_rdc_pos */


PROCEDURE provisao_rdc_pos_var.

    /***** Rotina para calcular quanto a rdcpos valera na 
           data do vencimento para calculo do var *****/

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    DEF                VAR aux_dtiniper  AS DATE   FORMAT "99/99/9999" NO-UNDO.
    DEF                VAR aux_dtfimper  AS DATE   FORMAT "99/99/9999" NO-UNDO.
    DEF                VAR aux_vlmoefix  LIKE crapmfx.vlmoefix         NO-UNDO.
    
    ASSIGN aux_dtcalcul = ?
           par_vlsdrdca = 0
           aux_vlrendim = 0
           par_vlrentot = 0.

    FOR EACH tt-erro:
        DELETE tt-erro.
    END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Buscas as taxas contratadas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.
                                                           
    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN par_vlsdrdca = craprda.vlsltxmx
           aux_dtiniper = craprda.dtatslmx
           aux_dtfimper = crapdat.dtmvtopr 
           aux_vlmoefix = 0.

    DO WHILE aux_dtiniper < aux_dtfimper:

       DO WHILE TRUE:
        
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.
   
          LEAVE.
   
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       IF   aux_dtiniper <= crapdat.dtmvtolt   THEN
            DO:
                FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                                   crapmfx.dtmvtolt = aux_dtiniper   AND
                                   crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR.
                                   /* CDI ANO */
                IF   AVAILABLE crapmfx   THEN  
                     ASSIGN aux_vlmoefix = crapmfx.vlmoefix.
            END.
            
       ASSIGN aux_txaplmes = 
                 (EXP((1 + aux_vlmoefix / 100),(1 / 252)) - 1) * 100
                 
              aux_txaplica =
                 ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).
                               
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              par_vlrentot = par_vlrentot + aux_vlrendim
              aux_dtiniper = aux_dtiniper + 1.
   
    END.  /*  Fim do DO WHILE  */

    ASSIGN par_vlrentot = ROUND(par_vlrentot,2)
           par_vlsdrdca = ROUND(par_vlsdrdca,2).
 
END PROCEDURE. /* Fim provisao_rdc_pos_var */


PROCEDURE rendi_apl_pos_com_resgate:

 /*** Calcula quanto o que esta sendo resgatado rendeu ate a data ***/  

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtaplrgt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_vlsdrdca AS DEC DECIMALS 8              NO-UNDO.
    DEF        INPUT PARAM par_flantven AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlrenrgt LIKE craprda.vlsdrdca          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF                VAR aux_txaplrgt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_perirrgt AS DEC DECIMALS 2              NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    ASSIGN aux_pcajsren = 0       
           aux_vlrenacu = 0
           aux_vlrentot = 0.
        
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
    
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_dtiniper = craprda.dtmvtolt
           aux_dtfimper = par_dtaplrgt.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                   
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).

    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.

          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */

       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
         
       IF   par_flantven = YES   THEN /* taxa minima */
            ASSIGN aux_txaplrgt = 
                      ROUND(((aux_txaplmes * craplap.txaplmes / 100) / 100),8).
       ELSE 
            DO:     
                ASSIGN aux_txaplrgt = 
                       ROUND(((aux_txaplmes * craplap.txaplica / 100) / 100),8).
                
                IF   aux_dtiniper > aux_dtinitax AND 
                     aux_dtiniper < aux_dtfimtax     THEN
                     DO:
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(aux_dtiniper) - 1,
                                          DAY(aux_dtiniper),YEAR(aux_dtiniper)) 
                                            NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(aux_dtiniper) = 1   THEN
                                  aux_dtinipop = aux_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */  
                                  aux_dtinipop = DATE(MONTH(aux_dtiniper),01,
                                                          YEAR(aux_dtiniper)).

                        FIND crapmfx WHERE 
                             crapmfx.cdcooper = par_cdcooper AND
                             crapmfx.dtmvtolt = aux_dtinipop AND
                             crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.  
                        
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".

                                {sistema/generico/includes/b1wgen0001.i}
                
                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.
                        
                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).
                        
                        IF   aux_txaplrgt < aux_txdiapop / 100   THEN
                             ASSIGN aux_txaplrgt = aux_txdiapop / 100.
                     END.
            END.
                  
       ASSIGN aux_vlrenrgt = TRUNCATE(par_vlsdrdca * aux_txaplrgt,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrenrgt 
              aux_vlrentot = aux_vlrentot + aux_vlrenrgt
              aux_dtiniper = aux_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */

    ASSIGN aux_vlrentot = ROUND(aux_vlrentot,2)
           par_vlrenrgt = aux_vlrentot
           par_vlsdrdca = ROUND(par_vlsdrdca,2).
                   
END PROCEDURE. /* Fim rendi_apl_pos_com_resgate */

PROCEDURE valor_original_resgatado:

 /*** Calcula quanto o que esta sendo resgatado representa do total ***/  

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtaplrgt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_vlsdrdca AS DEC DECIMALS 8              NO-UNDO.
    DEF        INPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF       OUTPUT PARAM par_vlbasrgt AS DEC DECIMALS 6              NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF                VAR aux_txaplrgt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_txaplcum AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_percirrf AS DEC DECIMALS 4              NO-UNDO.
    
    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    ASSIGN aux_txaplcum = 0
           par_vlbasrgt = par_vlsdrdca
           aux_percirrf = par_perirrgt / 100.
        
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_dtiniper = craprda.dtmvtolt
           aux_dtfimper = par_dtaplrgt.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Buscar o acumulado das taxas ***/
    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.

          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */

       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
         
       /*** Como e resgate antes do vencimento sempre taxa minima ***/
       ASSIGN aux_txaplrgt = 
                      ROUND((aux_txaplmes * craplap.txaplmes / 100),6).
       /*** Magui acumulando taxas ***/           
       IF   aux_txaplcum = 0   THEN
            ASSIGN aux_txaplcum = aux_txaplrgt.
       ELSE
            ASSIGN aux_txaplcum = ((aux_txaplcum / 100 + 1) *
                                   (aux_txaplrgt / 100 + 1) - 1) * 100.
              
       ASSIGN aux_dtiniper = aux_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */
                
    ASSIGN par_vlbasrgt = par_vlbasrgt / 
               (1 + ( TRUNCATE(aux_txaplcum,6) / 100 * (1 - aux_percirrf)))
           par_vlbasrgt = TRUNCATE(par_vlbasrgt,2).

END PROCEDURE. /* Fim valor_original_resgatado */


PROCEDURE extrato_rdc:

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.
    DEF       OUTPUT PARAM TABLE FOR tt-extr-rdc.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
 
    FOR EACH tt-extr-rdc:
        DELETE tt-extr-rdc.
    END.
     
    ASSIGN aux_sequen = 0.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapdat   THEN
         DO:
             ASSIGN i-cod-erro = 1 
                    c-dsc-erro = " ".
           
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.
         
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND 
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE craprda   THEN
         DO:
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.
     
    /* Lista de historicos que serao listados */
    ASSIGN aux_listahis = "527,528,529,530,531,533,534,532,472,473,474,475," +
                          "463,478,475,476,477,121" 
           aux_vlstotal = 0.
    
    FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper                 AND
                           craplap.nrdconta = par_nrctaapl                 AND
                           craplap.nraplica = par_nraplres                 AND
                           CAN-DO(aux_listahis,STRING(craplap.cdhistor))   AND
                          (craplap.dtmvtolt >= par_dtiniper   OR
                           par_dtiniper      = ?)                          AND
                          (craplap.dtmvtolt <= par_dtfimper   OR
                           par_dtfimper      = ?)
                           NO-LOCK BY craplap.dtmvtolt
                                   BY craplap.cdhistor:

        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplap.cdhistor NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craphis   THEN
             DO:
                 ASSIGN i-cod-erro = 80 
                        c-dsc-erro = " ".
           
                 { sistema/generico/includes/b1wgen0001.i }

                 RETURN "NOK".
             END.

        aux_dshistor = STRING(craphis.cdhistor,"999") + "-" + craphis.dshistor.
        
        IF   NOT CAN-DO("999",STRING(craphis.cdhistor))   THEN
             DO:
                  IF   craphis.indebcre = "C"   THEN
                       aux_vlstotal = aux_vlstotal + craplap.vllanmto.
                  ELSE
                  IF   craphis.indebcre = "D"   THEN
                       aux_vlstotal = aux_vlstotal - craplap.vllanmto.
                  ELSE
                       DO:
                          ASSIGN i-cod-erro = 83
                                 c-dsc-erro = " ".
           
                          { sistema/generico/includes/b1wgen0001.i }

                          RETURN "NOK".
                       END.
             END.

        CREATE tt-extr-rdc.
        ASSIGN tt-extr-rdc.dtmvtolt = craplap.dtmvtolt
               tt-extr-rdc.cdagenci = craplap.cdagenci
               tt-extr-rdc.cdbccxlt = craplap.cdbccxlt
               tt-extr-rdc.nrdolote = craplap.nrdolote
               tt-extr-rdc.cdhistor = craplap.cdhistor
               tt-extr-rdc.dshistor = aux_dshistor
               tt-extr-rdc.nrdocmto = craplap.nrdocmto
               tt-extr-rdc.indebcre = craphis.indebcre
               tt-extr-rdc.vllanmto = craplap.vllanmto
               tt-extr-rdc.vlsdlsap = aux_vlstotal
               tt-extr-rdc.txaplica = IF craplap.txaplica < 0 THEN 0
                                      ELSE craplap.txaplica
               tt-extr-rdc.vlpvlrgt = IF  craplap.cdhistor = 534  THEN
                                          craplap.vlpvlrgt
                                      ELSE
                                          0.
         
    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos  */
 
END PROCEDURE. /* Fim extrato_rdc */

PROCEDURE provisao_rdc_pos:

    /* Rotina de calculo da provisao no final do mes e no vencimento. */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF        INPUT PARAM par_flantven AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
     
    ASSIGN aux_dtcalcul = ?
           par_vlsdrdca = 0
           aux_vlrendim = 0
           par_vlrentot = 0.

    FOR EACH tt-erro:
        DELETE tt-erro.
    END.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Buscas as taxas contratadas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.
                                                           
    IF   NOT AVAILABLE craplap   THEN  
         DO:
             ASSIGN i-cod-erro = 90 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    IF   par_flantven = YES   THEN /* TAXA MINIMA */
         ASSIGN par_vlsdrdca = craprda.vlsltxmm.
    ELSE     
         ASSIGN par_vlsdrdca = craprda.vlsltxmx.

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).
 
    DO WHILE par_dtiniper < par_dtfimper:

       DO WHILE TRUE:
        
          IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = par_dtiniper)   THEN
               DO:
                   par_dtiniper = par_dtiniper + 1.
                   NEXT.
               END.
   
          LEAVE.
   
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   par_dtiniper >= par_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = par_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */
   
       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
                 
       /* Calcula o saldo com a taxa minina se for antes do vencimento */
       IF   par_flantven = YES   THEN                     
            aux_txaplica = 
                ROUND((aux_txaplmes * craplap.txaplmes / 100 ) / 100 ,8).
       ELSE 
            DO:      
                aux_txaplica =
                    ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).
                
                IF   par_dtiniper > aux_dtinitax AND
                     par_dtiniper < aux_dtfimtax     THEN
                     DO:
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(par_dtiniper) - 1,
                                          DAY(par_dtiniper),YEAR(par_dtiniper)) 
                                             NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(par_dtiniper) = 1   THEN
                                  aux_dtinipop = par_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */
                                  aux_dtinipop = DATE(MONTH(par_dtiniper),01,
                                                          YEAR(par_dtiniper)).

                        FIND crapmfx WHERE 
                             crapmfx.cdcooper = par_cdcooper AND
                             crapmfx.dtmvtolt = aux_dtinipop AND
                             crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.  
              
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".
                                    
                                {sistema/generico/includes/b1wgen0001.i}

                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.

                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).

                        IF   aux_txaplica < aux_txdiapop / 100   then
                             ASSIGN aux_txaplica = aux_txdiapop / 100.
                     END.
            END.          
                  
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              par_vlrentot = par_vlrentot + aux_vlrendim
              par_dtiniper = par_dtiniper + 1.
   
    END.  /*  Fim do DO WHILE  */

    ASSIGN par_vlrentot = ROUND(par_vlrentot,4)
           par_vlsdrdca = ROUND(par_vlsdrdca,4).
 
END PROCEDURE. /* Fim provisao_rdc_pos */

PROCEDURE acumula_aplicacoes:

    DEF  INPUT PARAM p-cdcooper LIKE crapcop.cdcooper                  NO-UNDO.
    DEF  INPUT PARAM p-cdprogra AS CHAR                                NO-UNDO.
    DEF  INPUT PARAM p-nrdconta LIKE crapass.nrdconta                  NO-UNDO.
    DEF  INPUT PARAM p-nraplica LIKE craprda.nraplica                  NO-UNDO.
    DEF  INPUT PARAM p-tpaplica LIKE craprda.tpaplica                  NO-UNDO.
    DEF  INPUT PARAM p-vlaplica LIKE craprda.vlaplica                  NO-UNDO.
    DEF  INPUT PARAM p-cdperapl LIKE crapttx.cdperapl                  NO-UNDO.

    DEF OUTPUT PARAM p-vlsdrdca LIKE craprda.vlsdrdca                  NO-UNDO.
    DEF OUTPUT PARAM p-txaplica LIKE craplap.txaplica /* taxa max. */  NO-UNDO.
    DEF OUTPUT PARAM p-txaplmes LIKE craplap.txaplmes /* taxa min. */  NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-acumula.

    DEF BUFFER crabtab FOR craptab.

    DEF VAR aux_vltotrgt LIKE craplrg.vllanmto                         NO-UNDO.
    DEF VAR aux_vllanmto LIKE craprda.vlsdrdca                         NO-UNDO.
    DEF VAR aux_vllctprv LIKE craprda.vlsdrdca                         NO-UNDO.
    DEF VAR aux_vlsldrpp LIKE craprpp.vlsdrdpp                         NO-UNDO.

    DEF VAR aux_dtiniper AS DATE                                       NO-UNDO.

    DEF VAR h-b1wgen0006 AS HANDLE                                     NO-UNDO.
    
    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF VAR p-cod-agencia AS INTE INIT 1                               NO-UNDO.
    DEF VAR p-nro-caixa   AS INTE INIT 999                             NO-UNDO.
    
    FOR EACH tt-erro:
        DELETE tt-erro.
    END.
        
    FOR EACH tt-acumula:
        DELETE tt-acumula.
    END.
        
    ASSIGN  p-vlsdrdca   = p-vlaplica
            aux_qtdfaxir = 0.

    
    FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN i-cod-erro = 1 
                    c-dsc-erro = " ".
             
             { sistema/generico/includes/b1wgen0001.i }
             
             RETURN "NOK".
         END.
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapdat   THEN
         DO:
             ASSIGN i-cod-erro = 1 
                    c-dsc-erro = " ".
             
             { sistema/generico/includes/b1wgen0001.i }
             
             RETURN "NOK".
         END. 

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                       craptab.nmsistem = "CRED"             AND   
                       craptab.cdempres = 0                  AND
                       craptab.tptabela = "CONFIG"           AND   
                       craptab.cdacesso = "PERCIRRDCA"       AND
                       craptab.tpregist = 0                  NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):

       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtmestab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    
    END.
    
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                       crapass.nrdconta = p-nrdconta       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN i-cod-erro = 9 
                    c-dsc-erro = " ".
             
             { sistema/generico/includes/b1wgen0001.i }
             
             RETURN "NOK".
         END. 
                    
    FOR EACH crabtab WHERE crabtab.cdcooper = crapcop.cdcooper AND
                           crabtab.nmsistem = "CRED"           AND
                           crabtab.cdempres = p-tpaplica       AND
                           crabtab.tptabela = "GENERI"         AND
                           crabtab.cdacesso = "SOMAPLTAXA"     AND
                           crabtab.dstextab = "SIM"            NO-LOCK:
                           
        IF   crabtab.tpregist = 1   THEN /* RDCA30 */ 
             DO:
                 APLICACOES_RDCA30:
                 
                 FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper AND
                                        craprda.tpaplica = 3                AND
                                        craprda.insaqtot = 0                AND
                                        craprda.cdageass = crapass.cdagenci AND
                                        craprda.nrdconta = crapass.nrdconta 
                                        USE-INDEX craprda6 NO-LOCK:
                 
                     ASSIGN aux_vltotrgt = 0.
                     
                     FOR EACH craplrg WHERE 
                              craplrg.cdcooper  = crapcop.cdcooper AND
                              craplrg.nrdconta  = craprda.nrdconta AND
                              craplrg.tpaplica  = craprda.tpaplica AND
                              craplrg.nraplica  = craprda.nraplica AND
                              craplrg.dtresgat <= crapdat.dtmvtopr AND
                              craplrg.inresgat  = 0                AND
                              CAN-DO("1,2",STRING(craplrg.tpresgat))
                              USE-INDEX craplrg2 NO-LOCK:
                 
                         /* Resgate total */                   
                         IF   craplrg.tpresgat = 2   THEN
                              NEXT APLICACOES_RDCA30.
                     
                         ASSIGN aux_vltotrgt = aux_vltotrgt + craplrg.vllanmto.
                         
                     END. /* Fim do FOR EACH craplrg */

                     { sistema/generico/includes/b1wgen0004.i } 
                 
                     IF   aux_vlsdrdca > 0   THEN
                          DO:
                              ASSIGN aux_vlsdrdca = aux_vlsdrdca - aux_vltotrgt
                                     p-vlsdrdca   = p-vlsdrdca + aux_vlsdrdca.
                          
                              CREATE tt-acumula.
                              ASSIGN tt-acumula.nraplica = craprda.nraplica
                                     tt-acumula.tpaplica = "RDCA" 
                                     tt-acumula.vlsdrdca = aux_vlsdrdca.
                          END.
                        
                 END. /* Fim do FOR EACH craprda */
             END.
        ELSE
        IF   crabtab.tpregist = 2   THEN /* RPP */
             DO:
                 RUN sistema/generico/procedures/b1wgen0006.p 
                     PERSISTENT SET h-b1wgen0006.

                 IF   NOT VALID-HANDLE(h-b1wgen0006)   THEN
                      DO:
                          ASSIGN i-cod-erro = 0 
                                 c-dsc-erro = "Handle invalido para BO " +
                                              "b1wgen0006.".
                          
                          { sistema/generico/includes/b1wgen0001.i }
                          
                          RETURN "NOK".
                      END.

                 RUN consulta-poupanca IN h-b1wgen0006 
                                      (INPUT p-cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT "",  /* Operador */
                                       INPUT p-cdprogra,
                                       INPUT 1,   /* Origem   */
                                       INPUT crapass.nrdconta,
                                       INPUT 1,   /* Titular  */
                                       INPUT 0,   /* Contrato */ 
                                       INPUT crapdat.dtmvtolt,
                                       INPUT crapdat.dtmvtopr,
                                       INPUT crapdat.inproces,
                                       INPUT p-cdprogra,
                                       INPUT FALSE,
                                      OUTPUT aux_vlsldrpp,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-dados-rpp).

                 DELETE PROCEDURE h-b1wgen0006.

                 IF   RETURN-VALUE = "NOK"   THEN
                      RETURN "NOK".

                 FOR EACH tt-dados-rpp NO-LOCK:
                    
                     IF  tt-dados-rpp.vlrgtrpp > 0   THEN
                         DO:
                             ASSIGN p-vlsdrdca = p-vlsdrdca + 
                                                 tt-dados-rpp.vlrgtrpp.
                          
                             CREATE tt-acumula.
                             ASSIGN tt-acumula.nraplica = tt-dados-rpp.nrctrrpp
                                    tt-acumula.tpaplica = "RPP"
                                    tt-acumula.vlsdrdca = tt-dados-rpp.vlrgtrpp.
                         END.

                 END. /** Fim do FOR EACH tt-dados-rpp **/
             END.
        ELSE
        IF   crabtab.tpregist = 3   THEN /* RDCA60 */
             DO:
                 APLICACOES_RDCA60:
                 
                 FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper AND
                                        craprda.tpaplica = 5                AND
                                        craprda.insaqtot = 0                AND
                                        craprda.cdageass = crapass.cdagenci AND
                                        craprda.nrdconta = crapass.nrdconta 
                                        USE-INDEX craprda6 NO-LOCK:
                 
                     IF   craprda.nraplica = p-nraplica   THEN
                          NEXT.
                          
                     ASSIGN aux_vltotrgt = 0.

                     FOR EACH craplrg WHERE 
                              craplrg.cdcooper  = crapcop.cdcooper AND
                              craplrg.nrdconta  = craprda.nrdconta AND
                              craplrg.tpaplica  = craprda.tpaplica AND
                              craplrg.nraplica  = craprda.nraplica AND
                              craplrg.dtresgat <= crapdat.dtmvtopr AND
                              craplrg.inresgat  = 0                AND
                              CAN-DO("1,2",STRING(craplrg.tpresgat))
                              USE-INDEX craplrg2 NO-LOCK:
                 
                         /* Resgate total */                   
                         IF   craplrg.tpresgat = 2   THEN
                              NEXT APLICACOES_RDCA60.
                     
                         ASSIGN aux_vltotrgt = aux_vltotrgt + craplrg.vllanmto.
                         
                     END. /* Fim do FOR EACH craplrg */

                     { sistema/generico/includes/b1wgen0004a.i } 
                 
                     IF   rd2_vlsdrdca > 0   THEN
                          DO:
                              ASSIGN rd2_vlsdrdca = rd2_vlsdrdca - aux_vltotrgt 
                                     p-vlsdrdca   = p-vlsdrdca + rd2_vlsdrdca.
                          
                              CREATE tt-acumula.
                              ASSIGN tt-acumula.nraplica = craprda.nraplica
                                     tt-acumula.tpaplica = "RDCA60"
                                     tt-acumula.vlsdrdca = rd2_vlsdrdca.
                          END.

                 END. /* Fim do FOR EACH craprda */
             END.
        ELSE
        IF   crabtab.tpregist = 7    THEN /* RDCPRE */
             DO:
                 APLICACOES_RDCPRE:
                 
                 FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper AND
                                        craprda.tpaplica = 7                AND
                                        craprda.insaqtot = 0                AND
                                        craprda.cdageass = crapass.cdagenci AND
                                        craprda.nrdconta = crapass.nrdconta 
                                        USE-INDEX craprda6 NO-LOCK:
                 
                     IF   craprda.nraplica = p-nraplica   THEN
                          NEXT.
                      
                     ASSIGN aux_vltotrgt = 0.

                     FOR EACH craplrg WHERE 
                              craplrg.cdcooper  = crapcop.cdcooper AND
                              craplrg.nrdconta  = craprda.nrdconta AND
                              craplrg.tpaplica  = craprda.tpaplica AND
                              craplrg.nraplica  = craprda.nraplica AND
                              craplrg.dtresgat <= crapdat.dtmvtopr AND
                              craplrg.inresgat  = 0                AND
                              CAN-DO("1,2",STRING(craplrg.tpresgat))
                              USE-INDEX craplrg2 NO-LOCK:
                 
                         /* Resgate total */                   
                         IF   craplrg.tpresgat = 2   THEN
                              NEXT APLICACOES_RDCPRE.
                     
                         ASSIGN aux_vltotrgt = aux_vltotrgt + craplrg.vllanmto.
                         
                     END. /* Fim do FOR EACH craplrg */

                     /*** Calcula a provisao do inicio mes ate a data ***/
                     ASSIGN aux_dtiniper = DATE(MONTH(crapdat.dtmvtolt),
                                                01,
                                                YEAR(crapdat.dtmvtolt)).
                 
                     IF   aux_dtiniper < craprda.dtmvtolt   THEN
                          ASSIGN aux_dtiniper = craprda.dtmvtolt.
                                                
                     RUN provisao_rdc_pre (INPUT crapcop.cdcooper,
                                           INPUT craprda.nrdconta,
                                           INPUT craprda.nraplica,
                                           INPUT aux_dtiniper,
                                           INPUT crapdat.dtmvtolt,
                                           OUTPUT aux_vlsldrdc,
                                           OUTPUT aux_vllanmto,
                                           OUTPUT aux_vllctprv,
                                           OUTPUT TABLE tt-erro).
                 
                     IF   RETURN-VALUE = "NOK"   THEN
                          RETURN "NOK".
                     
                     ASSIGN aux_vlsldrdc = aux_vlsldrdc - aux_vltotrgt
                            p-vlsdrdca   = p-vlsdrdca + aux_vlsldrdc.
                 
                     CREATE tt-acumula.
                     ASSIGN tt-acumula.nraplica = craprda.nraplica
                            tt-acumula.tpaplica = "RDCPRE" 
                            tt-acumula.vlsdrdca = aux_vlsldrdc.
                    
                 END. /* Fim do FOR EACH craprda */
             END.
        ELSE
        IF   crabtab.tpregist = 8   THEN /* RDCPOS */
             DO:
                 APLICACOES_RDCPOS:
                 
                 FOR EACH craprda WHERE craprda.cdcooper = crapcop.cdcooper AND
                                        craprda.tpaplica = 8                AND
                                        craprda.insaqtot = 0                AND
                                        craprda.cdageass = crapass.cdagenci AND
                                        craprda.nrdconta = crapass.nrdconta 
                                        USE-INDEX craprda6 NO-LOCK:
                 
                     IF   craprda.nraplica = p-nraplica   THEN
                          NEXT.
                      
                     ASSIGN aux_vltotrgt = 0.

                     FOR EACH craplrg WHERE 
                              craplrg.cdcooper  = crapcop.cdcooper AND
                              craplrg.nrdconta  = craprda.nrdconta AND
                              craplrg.tpaplica  = craprda.tpaplica AND
                              craplrg.nraplica  = craprda.nraplica AND
                              craplrg.dtresgat <= crapdat.dtmvtopr AND
                              craplrg.inresgat  = 0                AND
                              CAN-DO("1,2",STRING(craplrg.tpresgat))
                              USE-INDEX craplrg2 NO-LOCK:
                 
                         /* Resgate total */                   
                         IF   craplrg.tpresgat = 2   THEN
                              NEXT APLICACOES_RDCPOS.
                     
                         ASSIGN aux_vltotrgt = aux_vltotrgt + craplrg.vllanmto.
                         
                     END. /* Fim do FOR EACH craplrg */

                     RUN provisao_rdc_pos (INPUT crapcop.cdcooper,
                                           INPUT craprda.nrdconta,
                                           INPUT craprda.nraplica,
                                           INPUT craprda.dtatslmx,
                                           INPUT crapdat.dtmvtolt,
                                           INPUT NO, /* TAXA MAXIMA */
                                           OUTPUT aux_vlsldrdc,
                                           OUTPUT aux_vllanmto,
                                           OUTPUT TABLE tt-erro).
                 
                     IF   RETURN-VALUE = "NOK"   THEN
                          RETURN "NOK".
                     
                     ASSIGN aux_vlsldrdc = aux_vlsldrdc - aux_vltotrgt
                            p-vlsdrdca   = p-vlsdrdca + aux_vlsldrdc.
                 
                     CREATE tt-acumula.
                     ASSIGN tt-acumula.nraplica = craprda.nraplica
                            tt-acumula.tpaplica = "RDCPOS" 
                            tt-acumula.vlsdrdca = aux_vlsldrdc.
                    
                 END. /* Fim do FOR EACH craprda */
             END.
    END.    

    /*** Se nao for aplicacao RDCPRE ou RDCPOS ***/
    IF   p-tpaplica < 7   THEN
         RETURN "OK".
         
    IF   p-vlsdrdca < 0 THEN
         ASSIGN p-vlsdrdca = p-vlaplica.
         
    /*** Procurando a faixa em que aplicacao se encaixa ***/
    FIND FIRST crapftx WHERE crapftx.cdcooper  = crapcop.cdcooper AND
                             crapftx.tptaxrdc  = p-tpaplica       AND
                             crapftx.cdperapl  = p-cdperapl       AND
                             crapftx.vlfaixas <= p-vlsdrdca
                             NO-LOCK NO-ERROR.
                               
    IF   NOT AVAILABLE crapftx   THEN
         DO:      
             message "magui2" crapcop.cdcooper p-tpaplica p-cdperapl
                     p-vlsdrdca.
                     pause.
             ASSIGN i-cod-erro = 891 
                    c-dsc-erro = " ".
            
             { sistema/generico/includes/b1wgen0001.i }
            
             RETURN "NOK".
         END.
               
    IF   p-tpaplica = 8   THEN /* RDCPOS */
         DO:
             ASSIGN p-txaplica = crapftx.perapltx
                    p-txaplmes = crapftx.perrdttx.    
            
             RETURN "OK".
         END.
               
    /*** Magui, quando rdcpre pegar a taxa do dia anterior porque o cdi so
         e cadastrado no final do dia ***/
    FIND FIRST craptrd WHERE craptrd.cdcooper = crapcop.cdcooper AND
                             craptrd.dtiniper = crapdat.dtmvtoan AND
                             craptrd.tptaxrda = p-tpaplica       AND
                             craptrd.incarenc = 0                AND
                             craptrd.vlfaixas = crapftx.vlfaixas AND
                             craptrd.cdperapl = p-cdperapl     
                             NO-LOCK NO-ERROR.
            
    IF   NOT AVAILABLE craptrd   THEN
         DO:      
             ASSIGN i-cod-erro  = 347 
                    c-dsc-erro = " ".
            
             { sistema/generico/includes/b1wgen0001.i }
             
             RETURN "NOK".
         END.
               
    ASSIGN p-txaplica = craptrd.txofidia
           p-txaplmes = crapftx.perapltx.
              
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE calctx_poupanca:

 DEF INPUT  PARAMETER par_cdcooper AS INTE                 NO-UNDO.
 DEF INPUT  PARAMETER par_qtdiaute AS INTE                 NO-UNDO.
 DEF INPUT  PARAMETER par_vlmoefix LIKE crapmfx.vlmoefix   NO-UNDO.
 DEF OUTPUT PARAMETER par_txmespop AS DECIMAL DECIMALS 6   NO-UNDO.
 DEF OUTPUT PARAMETER par_txdiapop AS DECIMAL DECIMALS 6   NO-UNDO.
 
 ASSIGN aux_qtdfaxir = 0.

 FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                    craptab.nmsistem = "CRED"        AND
                    craptab.cdempres = 0             AND
                    craptab.tptabela = "CONFIG"      AND
                    craptab.cdacesso = "PERCIRRDCA"  AND
                    craptab.tpregist = 0             NO-LOCK NO-ERROR.

 DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
    ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
           aux_qtdfaxir = aux_qtdfaxir + 1
           aux_qtmestab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
           aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
 END. /* Fim do DO TO */
 
 ASSIGN par_txmespop = ROUND(par_vlmoefix / (1 - (aux_perirtab[1] / 100)),6)
        par_txdiapop = ROUND(((EXP(1 + (par_txmespop / 100),
                                        1 / par_qtdiaute) - 1) * 100),6).

END PROCEDURE.

/*.......................................................................... */
 

