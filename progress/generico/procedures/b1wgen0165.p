/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0165.p
    Autor   : Renersson Ricardo Agostini (GATI)
    Data    : Julho/2013                          Ultima alteracao: 04/08/2017

    Objetivo  : Consultar contratos de empréstimos de cooperado.
    
    Alteracao: 24/02/2014 - Adionado param. de paginacao em proc. 
                            obtem-dados-emprestimos. (Jorge)

               07/03/2014 - Ajustes para deixar codigo no padrao (Lucas R.) 
               
               28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
               
               07/05/2014 - Incluir procedure busca_data_limite_cal (Lucas R.)
               
               27/05/2014 - Nao permitir consulta de saldo devedor para novo
                            tipo de emprestimo (crapepr.tpemprst = 1);
                            desdobramento do chamado 145767. (Fabricio)
                            
               13/11/2014 - Ajsute proc. Busca_contrato, em frase quando consultado 
                            contrato tpemprst = 1 e adicionado novo parametro de
                            entrada flgempt0, para true quando querer apenas contratos
                            price TR. (Jorge/Elton) - SD 168151
               
               30/07/2015 - Alterado para permitir calcular valor do emprestimo dentro
                            do mes, conforme solicitado no chamado 308426 (Kelvin) 
               
               23/11/2015 - Removido message que estava no fonte posto no ajuste
                            anterior, conforme solicitado no chamado 361573 (Kelvin)

               04/08/2017 - Nao permitir acessar tipo de emprestimo do Pos-Fixado. 
                            (Jaison/James - PRJ298)

.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0165tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEFINE VARIABLE aux_cdempres AS INTEGER FORMAT "zzzz9"                NO-UNDO.
DEFINE VARIABLE tab_diapagto AS INTEGER                               NO-UNDO.
DEFINE VARIABLE tab_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEFINE VARIABLE tab_flgfolha AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE tab_dtlimcal AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEFINE VARIABLE tab_inusatab AS LOGICAL                               NO-UNDO.
                                                                      
DEFINE VARIABLE aux_dscritic AS CHARACTER                             NO-UNDO.
                                                                      
DEFINE VARIABLE h-b1wgen0002 AS HANDLE                                NO-UNDO.

PROCEDURE Busca_contrato:

    /* Parâmetros de entrada */
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER                 NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                      NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER                 NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER                 NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTEGER                   NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgempt0 AS LOGICAL                   NO-UNDO.

    /* Parâmetros de saída */
    DEFINE OUTPUT PARAMETER par_nmdcampo AS CHAR                      NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapass.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapepr.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.

    EMPTY TEMP-TABLE tt-crapass.
    EMPTY TEMP-TABLE tt-crapepr.
    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta 
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_cdbccxlt,
                           INPUT 1,
                           INPUT 09, /* Associado nao cadastrado */
                           INPUT-OUTPUT aux_dscritic).
       
            ASSIGN par_nmdcampo = "nrdconta".
            RETURN "NOK".
        END.

    /* Iniciar carga de dados dos contratos */
    Busca: 
    DO ON ERROR UNDO Busca, LEAVE Busca:
        
        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_cdbccxlt,
                                     INPUT-OUTPUT par_nrdconta,
                                     OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

        IF  VALID-HANDLE(h-b1wgen9999) THEN
            DELETE OBJECT h-b1wgen9999.

        IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN 
            LEAVE Busca.

        /* Dados do cooperado */
        FOR FIRST crapass FIELDS(cdcooper nrdconta cdtipsfx nmprimtl) WHERE 
                  crapass.cdcooper = par_cdcooper AND 
                  crapass.nrdconta = par_nrdconta NO-LOCK:
        
            CREATE tt-crapass.
            ASSIGN tt-crapass.cdtipsfx = crapass.cdtipsfx
                   tt-crapass.nmprimtl = crapass.nmprimtl.
        
            /* Dados dos contratos do cooperado */
            FOR EACH crapepr FIELDS(cdcooper nrdconta nrctremp dtmvtolt
                                    vlemprst qtpreemp vlpreemp cdlcremp
                                    cdfinemp inliquid tpemprst) WHERE 
                     crapepr.cdcooper = crapass.cdcooper AND
                     crapepr.nrdconta = crapass.nrdconta NO-LOCK:
        
                /* Indicador de liquidação - Carregar apenas não liquidados */
                /* ou quando vier apenas para pegar tpemprst = 0 */
                IF  crapepr.inliquid <> 0  OR 
                   (par_flgempt0 AND crapepr.tpemprst <> 0) THEN 
                    NEXT.
        
                CREATE tt-crapepr.
                ASSIGN tt-crapepr.cdcooper = crapepr.cdcooper
                       tt-crapepr.nrdconta = crapepr.nrdconta
                       tt-crapepr.nrctremp = crapepr.nrctremp
                       tt-crapepr.dtmvtolt = crapepr.dtmvtolt
                       tt-crapepr.vlemprst = crapepr.vlemprst
                       tt-crapepr.qtpreemp = crapepr.qtpreemp
                       tt-crapepr.vlpreemp = crapepr.vlpreemp
                       tt-crapepr.cdlcremp = crapepr.cdlcremp
                       tt-crapepr.cdfinemp = crapepr.cdfinemp
                       tt-crapepr.dscontra = "LC " +
                                              STRING(crapepr.cdlcremp,"9999") +
                                              " " + "Fin " +
                                              STRING(crapepr.cdfinemp,"999").
        
            END. /* Fim do FOR EACH - Leitura dos contratos de emprestimos */
        
        END. /* Fim do for crapass */
        
        IF  NOT TEMP-TABLE tt-crapepr:HAS-RECORDS THEN 
            DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_cdbccxlt,
                              INPUT 1,
                              INPUT 355,
                              INPUT-OUTPUT aux_dscritic).
               LEAVE Busca.
            END.
        
        IF  NOT TEMP-TABLE tt-crapass:HAS-RECORDS THEN 
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_cdbccxlt,
                               INPUT 1,
                               INPUT 9,
                               INPUT-OUTPUT aux_dscritic).
                LEAVE Busca.
            END.
    END. /* Fim do DO Busca */

    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_emprestimo.

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER FORMAT "x(10)" NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtcalcul AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctremp AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgcondc AS LOGICAL                  NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-pesqsr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtregist AS INTE                                     NO-UNDO.

    DEFINE VARIABLE h-b1wgen0002 AS HANDLE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Se digitou numero do contrado verifica se existe */
    IF  NOT CAN-FIND(FIRST crapepr
                     WHERE crapepr.cdcooper = par_cdcooper  AND
                           crapepr.nrdconta = par_nrdconta  AND
                           crapepr.nrctremp = par_nrctremp) THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_cdbccxlt,
                           INPUT 1,
                           INPUT 356, /* Contrato nao encontrado */
                           INPUT-OUTPUT aux_dscritic).
       
            ASSIGN par_nmdcampo = "nrctremp".
            RETURN "NOK".
        END.

    /* Se o contrato digitado existir mas for do tipo novo; entao critica */
    IF CAN-FIND(FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                    crapepr.nrdconta = par_nrdconta AND
                                    crapepr.nrctremp = par_nrctremp AND
                                   (crapepr.tpemprst = 1 /* PP */   OR
                                    crapepr.tpemprst = 2 /* POS */)) THEN
    DO:
        ASSIGN aux_dscritic = "Operacao nao permitida para o emprestimo informado.".

        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = 0
               tt-erro.dscritic = aux_dscritic.
       
        ASSIGN par_nmdcampo = "nrctremp".
        RETURN "NOK".
    END.

    RUN busca_data_limite_cal(INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_dtmvtolt,
                             OUTPUT tab_dtlimcal).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
    
    IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
        RUN sistema/generico/procedures/b1wgen0002.p 
            PERSISTENT SET h-b1wgen0002.

    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_cdbccxlt,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT par_dtcalcul,
                                                 INPUT par_nrctremp,
                                                 INPUT par_cdprogra,
                                                 INPUT par_inproces,
                                                 INPUT par_flgerlog,
                                                 INPUT par_flgcondc,
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                 OUTPUT aux_qtregist,
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT TABLE tt-dados-epr).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE OBJECT h-b1wgen0002.
    
    FOR EACH tt-dados-epr NO-LOCK:

        CREATE tt-pesqsr.
        ASSIGN tt-pesqsr.cdpesqui = tt-dados-epr.cdpesqui
               tt-pesqsr.vlemprst = tt-dados-epr.vlemprst
               tt-pesqsr.txdjuros = tt-dados-epr.txjuremp
               tt-pesqsr.vlsdeved = tt-dados-epr.vlsdeved
               tt-pesqsr.vljurmes = tt-dados-epr.vljurmes
               tt-pesqsr.vlpreemp = tt-dados-epr.vlpreemp
               tt-pesqsr.vljuracu = tt-dados-epr.vljuracu
               tt-pesqsr.vlprepag = tt-dados-epr.vlprepag
               tt-pesqsr.qtmesdec = tt-dados-epr.qtmesdec
               tt-pesqsr.vlpreapg = tt-dados-epr.vlpreapg
               tt-pesqsr.dsdpagto = tt-dados-epr.dsdpagto
               tt-pesqsr.qtprecal = tt-dados-epr.qtprecal
               tt-pesqsr.dslcremp = tt-dados-epr.dslcremp
               tt-pesqsr.qtpreapg = tt-dados-epr.qtpreemp - 
                                    tt-dados-epr.qtprecal
               tt-pesqsr.dsfinemp = tt-dados-epr.dsfinemp.

        FOR FIRST craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                                craplcr.cdlcremp = par_nrctremp NO-LOCK:

            ASSIGN tt-pesqsr.nrctaav2 = crapepr.nrctaav2    
                   tt-pesqsr.nrctaav1 = crapepr.nrctaav1.
        END.

        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND    
                               crapavt.nrdconta = par_nrdconta AND
                               crapavt.nrctremp = par_nrctremp AND
                               crapavt.tpctrato = 1 NO-LOCK:

            IF  crapepr.nrctaav1 = 0 AND 
                tt-pesqsr.nmdaval1 = " " THEN
                ASSIGN tt-pesqsr.nmdaval1 = crapavt.nmdavali 
                       tt-pesqsr.cpfcgc1  = crapavt.nrcpfcgc.
            ELSE   
                IF  crapepr.nrctaav2 = 0 THEN   
                    ASSIGN tt-pesqsr.nmdaval2 = crapavt.nmdavali 
                           tt-pesqsr.cpfcgc2  = crapavt.nrcpfcgc.
        END.         
    END.

    IF  NOT TEMP-TABLE tt-pesqsr:HAS-RECORDS THEN 
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_cdbccxlt,
                           INPUT 1,
                           INPUT 356,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_data_limite_cal:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER par_dtlimcal AS DATE                     NO-UNDO.

    /* Valida numero da conta digitada */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper  AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.
    
    IF  AVAIL crapass THEN
        DO:
            IF  crapass.inpessoa = 1   THEN 
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 1 
                                       NO-LOCK NO-ERROR.
                    
                    IF  AVAIL crapttl  THEN
                        ASSIGN aux_cdempres = crapttl.cdempres.
                END.
            ELSE
                DO:
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                       crapjur.nrdconta = crapass.nrdconta
                                       NO-LOCK NO-ERROR.
            
                    IF  AVAIL crapjur  THEN
                        ASSIGN aux_cdempres = crapjur.cdempres.
                END.

        END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "DIADOPAGTO" AND
                       craptab.tpregist = aux_cdempres
                       NO-LOCK NO-ERROR.
    
    IF  AVAILABLE craptab   THEN
        DO:
                /*  Mensal  */    
            IF  CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
                tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)).  
            ELSE /*  Horis.  */
                tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)).  
            
            /*  Verifica se a data do pagamento da empresa cai num dia util  */
            
           ASSIGN tab_dtcalcul = DATE(MONTH(par_dtmvtolt),
                                 tab_diapagto,YEAR(par_dtmvtolt)).
            
            DO WHILE TRUE:
            
               IF   WEEKDAY(tab_dtcalcul) = 1   OR
                    WEEKDAY(tab_dtcalcul) = 7   THEN
                    DO:
                        ASSIGN tab_dtcalcul = tab_dtcalcul + 1.
                        NEXT.
                    END.
            
               FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND 
                                  crapfer.dtferiad = tab_dtcalcul NO-LOCK NO-ERROR.
            
               IF   AVAILABLE crapfer   THEN
                    DO:
                        ASSIGN tab_dtcalcul = tab_dtcalcul + 1.
                        NEXT.
                    END.
            
               ASSIGN tab_diapagto = DAY(tab_dtcalcul).
            
               LEAVE.
            
            END.  /*  Fim do DO WHILE TRUE  */
        END.

   ASSIGN  par_dtlimcal = DATE((IF MONTH(par_dtmvtolt) = 12 THEN 1
                                ELSE MONTH(par_dtmvtolt) + 1),
                          tab_diapagto,(IF MONTH(par_dtmvtolt) = 12
                                        THEN YEAR(par_dtmvtolt) + 1
                                        ELSE YEAR(par_dtmvtolt))).

    RETURN "OK".

END.
