/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+---------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                   |
  +-------------------------------------+---------------------------------------+
  |      Busca_Dados                    | PC_VERPRO                             |
  |      Busca_Protocolos               | PC_VERPRO                             |
  |      ValidaDigFun                   | gene0005.fn_valida_digito_verificador |
  +-------------------------------------+---------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0122.p
    Autor   : Rogerius Militao (DB1)
    Data    : Outubro/2011                      Ultima atualizacao: 09/04/2015

    Objetivo  : Tranformacao BO tela VERPRO

    Alteracoes: 05/04/2012 - Incluir Bco Age nos pagamentos ref. Projeto 
                             Autenticacao (Guilherme).
                             
                28/02/2013 - Incluso paginacao tela web (Daniel).
                
                02/05/2013 - Transferencia Intercooperativa (Gabriel).
                
                27/06/2014 - Ajustes referente ao projeto de captacao
                            (Adriano).
                             
                02/10/2014 - Ajuste realizados:
                            - Desprezar protocolos do tipo 11 - Debito Facil na
                              Busca_Protocolos             
                            (Adriano).
                             
                09/10/2014 - Incluido a impressao do tipo de protocolo
                             12 - Resgate de aplicacoes 
                             (Adriano).
                             
                09/04/2015 - Incluido nome do produto junto com o nr da aplicacao 
                             quando for novos produtos de captacao na procedure
                             impressao_aplicacao. (Reinert)
                             
                22/04/2015 - Alteracao na procedure impressao_ted para mostrar
                             o numero do ISPB na impressão SD271603 FDR041 (Vanessa)
                                          
                
                21/09/2015 - Criacao da procedure impressao_gps para gerar comprovantes
                             de pagamento da Guia de Previdencia Social
                             (Projeto GPS - Carlos Rafael Tanholi).                          
                                          
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0122tt.i }
{ sistema/generico/includes/bo_algoritmo_seguranca.i }


DEF STREAM str_1.

DEF VAR h-bo-a-s     AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

DEF VAR aux_dscabeca AS CHAR EXTENT 5                               NO-UNDO.
DEF VAR aux_dsddados AS CHAR EXTENT 14                              NO-UNDO.
DEF VAR aux_dsdados2 AS CHAR EXTENT 10                              NO-UNDO.

DEF VAR aux_contador AS INTE                                        NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                      EFETUA A BUSCA DA TELA VERPRO                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabass FOR crapass.
        
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca para Verificacao de Protocolos"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nmprimtl = "".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_nrdconta >= 0   THEN
            DO:
                /* Validar o digito da conta */
                IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_nrdconta ) THEN
                    DO:
                       ASSIGN aux_cdcritic = 8.
                       LEAVE Busca.
                    END.
        
                /* Informacoes sobre o cooperado */
                FOR FIRST crabass FIELDS(nmprimtl)
                                  WHERE crabass.cdcooper = par_cdcooper AND
                                        crabass.nrdconta = par_nrdconta NO-LOCK:
                END.
        
                IF  NOT AVAILABLE crabass THEN
                    DO:
                       ASSIGN aux_cdcritic = 9.
                       LEAVE Busca.
                    END.
                
                ASSIGN aux_nmprimtl = crabass.nmprimtl.

            END. /* Fim do IF .. THEN */
        ELSE
            ASSIGN aux_nmprimtl = "".


        ASSIGN aux_returnvl = "OK".
        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF  par_flgerlog THEN
               RUN proc_gerar_log (INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT aux_dscritic,
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT FALSE,
                                   INPUT 1, /** idseqttl **/
                                   INPUT par_nmdatela, 
                                   INPUT par_nrdconta, 
                                  OUTPUT aux_nrdrowid).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */ 


/* ------------------------------------------------------------------------ */
/*                      EFETUA A BUSCA DE PROTOCOLOS                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Protocolos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dataini  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_datafin  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtippro AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-cratpro.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_qttotreg AS INTE                                    NO-UNDO.
    DEF VAR aux_dsinfor2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrregist AS INTE                                    NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca para Verificacao de Protocolos"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        EMPTY TEMP-TABLE tt-cratpro.
        EMPTY TEMP-TABLE tt-erro.

        /*Desprezar protocolos do tipo 11 - Debito Facil*/
        IF  par_cdtippro = 11   THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de protocolo invalido.".
                LEAVE Busca.
            END.

        IF  NOT VALID-HANDLE(h-bo-a-s) THEN
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                PERSISTENT SET h-bo-a-s.

        RUN lista_protocolos IN h-bo-a-s (INPUT par_cdcooper, 
                                          INPUT par_nrdconta, 
                                          INPUT par_dataini,  
                                          INPUT par_datafin,  
                                          INPUT 0, 
                                          INPUT 0, 
                                          INPUT par_cdtippro,
                                          INPUT 1,  /* Ayllos */
                                         OUTPUT aux_dstransa,
                                         OUTPUT aux_dscritic,
                                         OUTPUT aux_qttotreg,
                                         OUTPUT TABLE cratpro).

        IF  VALID-HANDLE(h-bo-a-s) THEN
            DELETE OBJECT h-bo-a-s.
            
        IF  aux_qttotreg = 0   THEN
            DO:
                ASSIGN aux_dscritic = "Protocolo(s) nao encontrado(s).".
                LEAVE Busca.
            END.

        /* Tratamento de paginação somente para web*/
        IF  par_idorigem = 5 THEN
            DO:
                ASSIGN aux_nrregist = par_nrregist.
            END.

        /* copiando tt*/
        FOR EACH cratpro:

            IF  par_idorigem = 5 THEN
                DO:
                    ASSIGN par_qtregist = par_qtregist + 1.
        
                    /*IF  ( par_qtregist = ( par_nriniseq - 1 )) AND
                        ( par_qtregist > 1 ) THEN
                        ASSIGN aux_vlsldant = tt-extrato_cotas.vlsldtot.*/
        
                    /* controles da paginação */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
        
                    /* controles da paginação */
                    IF  (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
                END.

            IF  aux_nrregist > 0 THEN
                DO: 
             
                    CREATE tt-cratpro.
                    ASSIGN tt-cratpro.cdtippro    = cratpro.cdtippro
                           tt-cratpro.dstippro    = cratpro.dsinform[1] 
                           tt-cratpro.dtmvtolt    = cratpro.dtmvtolt
                           tt-cratpro.dttransa    = cratpro.dttransa
                           tt-cratpro.hrautent    = cratpro.hrautent
                           tt-cratpro.hrautenx    =  STRING(cratpro.hrautent,"HH:MM:SS")
                           tt-cratpro.vldocmto    = cratpro.vldocmto
                           tt-cratpro.nrdocmto    = cratpro.nrdocmto
                           tt-cratpro.nrseqaut    = cratpro.nrseqaut
                           tt-cratpro.dsinform[1] = cratpro.dsinform[1]
                           tt-cratpro.dsinform[2] = cratpro.dsinform[2]
                           tt-cratpro.dsinform[3] = cratpro.dsinform[3]
                           tt-cratpro.dsprotoc    = cratpro.dsprotoc
                           tt-cratpro.dscedent    = cratpro.dscedent
                           tt-cratpro.flgagend    = cratpro.flgagend
                           tt-cratpro.nmprepos    = cratpro.nmprepos
                           tt-cratpro.nrcpfpre    = cratpro.nrcpfpre
                           tt-cratpro.nmoperad    = cratpro.nmoperad
                           tt-cratpro.nrcpfope    = cratpro.nrcpfope.
                    
                    IF  cratpro.cdtippro = 9  THEN /* TED */
                        ASSIGN tt-cratpro.dsdbanco = TRIM(ENTRY(2,cratpro.dsinform[2],"#"))
                               tt-cratpro.dsageban = TRIM(ENTRY(3,cratpro.dsinform[2],"#"))
                               tt-cratpro.nrctafav = TRIM(ENTRY(4,cratpro.dsinform[2],"#"))
                               tt-cratpro.nmfavore = TRIM(ENTRY(1,cratpro.dsinform[3],"#"))
                               tt-cratpro.nrcpffav = TRIM(ENTRY(2,cratpro.dsinform[3],"#"))
                               tt-cratpro.dsfinali = TRIM(ENTRY(3,cratpro.dsinform[3],"#"))
                               tt-cratpro.dstransf = TRIM(ENTRY(4,cratpro.dsinform[3],"#")).
        
                    /* tratamento para codigo de barra, linha digitavel e terminal */
                    IF  CAN-DO("2,6,7",STRING(cratpro.cdtippro))   THEN
                        ASSIGN tt-cratpro.cdbarras = 
                                   TRIM(ENTRY(1,cratpro.dsinform[3],"#"))   
                               tt-cratpro.lndigita = 
                                   TRIM(ENTRY(2,cratpro.dsinform[3],"#")).
                    ELSE
                        ASSIGN tt-cratpro.cdbarras = "" 
                               tt-cratpro.lndigita = "".
        
                    IF  cratpro.cdtippro = 1   THEN  /* Transferencia */
                        ASSIGN tt-cratpro.terminax = 
                                   TRIM(ENTRY(1,cratpro.dsinform[3],"#")) NO-ERROR.
                    ELSE
                    IF  cratpro.cdtippro = 5   THEN  /* Deposito TAA */
                        ASSIGN tt-cratpro.terminax = 
                                   TRIM(ENTRY(2,cratpro.dsinform[3],"#")) NO-ERROR.
                    ELSE
                    IF  cratpro.cdtippro = 6   THEN  /* Pagamento TAA */
                        ASSIGN tt-cratpro.terminax =  
                                   TRIM(ENTRY(3,cratpro.dsinform[3],"#")) NO-ERROR.
                    ELSE
                        ASSIGN tt-cratpro.terminax =  "".
        
                    IF  ERROR-STATUS:ERROR THEN
                        ASSIGN tt-cratpro.terminax =  "".                    
        
                    IF  cratpro.cdtippro = 7   THEN
                        ASSIGN tt-cratpro.lndigita = FILL(" ",8) + tt-cratpro.lndigita. 
                    
                    
                    /* busca a flgpagto */
                    IF  cratpro.cdtippro = 3 THEN
                        DO:
                            ASSIGN tt-cratpro.nmprimtl = ""
                                   tt-cratpro.tppgamto = ""
                                   tt-cratpro.dsdbanco = "". 
        
                            FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                                     crappla.nrdconta = par_nrdconta AND
                                                     crappla.tpdplano = 1            AND
                                                     crappla.nrctrpla = INT(cratpro.nrdocmto)
                                                     NO-LOCK NO-ERROR.
                            IF  AVAIL crappla  THEN
                                ASSIGN tt-cratpro.flgpagto = crappla.flgpagto.
                        END.
                    ELSE
                    IF  cratpro.cdtippro <> 9  THEN
                        ASSIGN aux_dsinfor2 = TRIM(ENTRY(2,cratpro.dsinform[2],"#"))
                               tt-cratpro.nmprimtl = TRIM(ENTRY(1,cratpro.dsinform[2],"#"))
                               tt-cratpro.tppgamto = TRIM(ENTRY(1,aux_dsinfor2,":")) /* forma pagamento */
                               tt-cratpro.dsdbanco = TRIM(ENTRY(2,aux_dsinfor2,":")). /* banco */

                    /* Se transf. Pega Coop. destino */
                    IF  cratpro.cdtippro = 1   THEN
                        ASSIGN tt-cratpro.dsageban = 
                            TRIM(ENTRY(3,cratpro.dsinform[2],"#")).

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
                
            ELSE
                DO: 
             
                    CREATE tt-cratpro.
                    ASSIGN tt-cratpro.cdtippro    = cratpro.cdtippro
                           tt-cratpro.dstippro    = cratpro.dsinform[1] 
                           tt-cratpro.dtmvtolt    = cratpro.dtmvtolt
                           tt-cratpro.dttransa    = cratpro.dttransa
                           tt-cratpro.hrautent    = cratpro.hrautent
                           tt-cratpro.hrautenx    =  STRING(cratpro.hrautent,"HH:MM:SS")
                           tt-cratpro.vldocmto    = cratpro.vldocmto
                           tt-cratpro.nrdocmto    = cratpro.nrdocmto
                           tt-cratpro.nrseqaut    = cratpro.nrseqaut
                           tt-cratpro.dsinform[1] = cratpro.dsinform[1]
                           tt-cratpro.dsinform[2] = cratpro.dsinform[2]
                           tt-cratpro.dsinform[3] = cratpro.dsinform[3]
                           tt-cratpro.dsprotoc    = cratpro.dsprotoc
                           tt-cratpro.dscedent    = cratpro.dscedent
                           tt-cratpro.flgagend    = cratpro.flgagend
                           tt-cratpro.nmprepos    = cratpro.nmprepos
                           tt-cratpro.nrcpfpre    = cratpro.nrcpfpre
                           tt-cratpro.nmoperad    = cratpro.nmoperad
                           tt-cratpro.nrcpfope    = cratpro.nrcpfope.
                    
                    IF  cratpro.cdtippro = 9  THEN /* TED */
                        ASSIGN tt-cratpro.dsdbanco = TRIM(ENTRY(2,cratpro.dsinform[2],"#"))
                               tt-cratpro.dsageban = TRIM(ENTRY(3,cratpro.dsinform[2],"#"))
                               tt-cratpro.nrctafav = TRIM(ENTRY(4,cratpro.dsinform[2],"#"))
                               tt-cratpro.nmfavore = TRIM(ENTRY(1,cratpro.dsinform[3],"#"))
                               tt-cratpro.nrcpffav = TRIM(ENTRY(2,cratpro.dsinform[3],"#"))
                               tt-cratpro.dsfinali = TRIM(ENTRY(3,cratpro.dsinform[3],"#"))
                               tt-cratpro.dstransf = TRIM(ENTRY(4,cratpro.dsinform[3],"#")).
        
                    /* tratamento para codigo de barra, linha digitavel e terminal */
                    IF  CAN-DO("2,6,7",STRING(cratpro.cdtippro))   THEN
                        ASSIGN tt-cratpro.cdbarras = 
                                   TRIM(ENTRY(1,cratpro.dsinform[3],"#"))   
                               tt-cratpro.lndigita = 
                                   TRIM(ENTRY(2,cratpro.dsinform[3],"#")).
                    ELSE
                        ASSIGN tt-cratpro.cdbarras = "" 
                               tt-cratpro.lndigita = "".
        
                    IF  cratpro.cdtippro = 1   THEN  /* Transferencia */
                        ASSIGN tt-cratpro.terminax = 
                                   TRIM(ENTRY(1,cratpro.dsinform[3],"#")) NO-ERROR.
                    ELSE
                    IF  cratpro.cdtippro = 5   THEN  /* Deposito TAA */
                        ASSIGN tt-cratpro.terminax = 
                                   TRIM(ENTRY(2,cratpro.dsinform[3],"#")) NO-ERROR.
                    ELSE
                    IF  cratpro.cdtippro = 6   THEN  /* Pagamento TAA */
                        ASSIGN tt-cratpro.terminax =  
                                   TRIM(ENTRY(3,cratpro.dsinform[3],"#")) NO-ERROR.
                    ELSE
                        ASSIGN tt-cratpro.terminax =  "".
        
                    IF  ERROR-STATUS:ERROR THEN
                        ASSIGN tt-cratpro.terminax =  "".                    
        
                    IF  cratpro.cdtippro = 7   THEN
                        ASSIGN tt-cratpro.lndigita = FILL(" ",8) + tt-cratpro.lndigita. 
                    
                    
                    /* busca a flgpagto */
                    IF  cratpro.cdtippro = 3 THEN
                        DO:
                            ASSIGN tt-cratpro.nmprimtl = ""
                                   tt-cratpro.tppgamto = ""
                                   tt-cratpro.dsdbanco = "". 
        
                            FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                                     crappla.nrdconta = par_nrdconta AND
                                                     crappla.tpdplano = 1            AND
                                                     crappla.nrctrpla = INT(cratpro.nrdocmto)
                                                     NO-LOCK NO-ERROR.
                            IF  AVAIL crappla  THEN
                                ASSIGN tt-cratpro.flgpagto = crappla.flgpagto.
                        END.
                    ELSE
                    IF  cratpro.cdtippro <> 9  THEN
                        ASSIGN aux_dsinfor2 = TRIM(ENTRY(2,cratpro.dsinform[2],"#"))
                               tt-cratpro.nmprimtl = TRIM(ENTRY(1,cratpro.dsinform[2],"#"))
                               tt-cratpro.tppgamto = TRIM(ENTRY(1,aux_dsinfor2,":")) /* forma pagamento */
                               tt-cratpro.dsdbanco = TRIM(ENTRY(2,aux_dsinfor2,":")). /* banco */

                    /* Se transf. Pega Coop. destino */
                    IF  cratpro.cdtippro = 1   THEN
                        ASSIGN tt-cratpro.dsageban = 
                            TRIM(ENTRY(3,cratpro.dsinform[2],"#")).
                END.
        END.
        
        ASSIGN aux_returnvl = "OK".
        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF  par_flgerlog THEN
               RUN proc_gerar_log (INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT aux_dscritic,
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT FALSE,
                                   INPUT 1, /** idseqttl **/
                                   INPUT par_nmdatela, 
                                   INPUT par_nrdconta, 
                                  OUTPUT aux_nrdrowid).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".       
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Protocolos */ 


/* ------------------------------------------------------------------------ */
/*                   EFETUA A IMPRESSAO DOS PROTOCOLOS                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:
   
    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdtippro  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto  AS DECI                           NO-UNDO.   
    DEF  INPUT PARAM par_nrseqaut  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_cdbarras  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_lndigita  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_label     AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_label2    AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_valor     AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar2 AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_auxiliar3 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_auxiliar4 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdbanco  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsageban  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctafav  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmfavore  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpffav  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsfinali  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dstransf  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog  AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_dsinform  LIKE crappro.dsinform             NO-UNDO.
                                                                 
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                          
                                                              
    DEF VAR aux_dstransa AS CHAR                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Imprimir a Verificacao de Protocolos"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Imprimir: DO ON ERROR UNDO Imprimir, LEAVE Imprimir:

        FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
            
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop +
                              "/rl/" + par_dsiduser.
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2> /dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
        IF  par_cdtippro = 1 THEN
            DO: 
                RUN impressao_transf  (INPUT par_nrdconta, 
                                       INPUT par_nmprimtl, 
                                       INPUT par_cdtippro, 
                                       INPUT par_nrdocmto, 
                                       INPUT par_nrseqaut, 
                                       INPUT par_nmprepos, 
                                       INPUT par_nmoperad, 
                                       INPUT par_dttransa, 
                                       INPUT par_hrautent,                           
                                       INPUT par_dtmvtolx,                           
                                       INPUT par_dsprotoc,    
                                       INPUT par_cdbarras, 
                                       INPUT par_lndigita, 
                                       INPUT par_label,    
                                       INPUT par_valor,    
                                       INPUT par_auxiliar, 
                                       INPUT par_auxiliar2,
                                       INPUT par_auxiliar3,
                                       INPUT par_dsageban).
            END.
        ELSE   
        IF  par_cdtippro = 2 THEN
            DO:
                RUN impressao_Pag (INPUT crabcop.cdbcoctl,
                                   INPUT crabcop.cdagectl,
                                   INPUT par_nrdconta,
                                   INPUT par_label,
                                   INPUT par_nmprimtl,
                                   INPUT par_nmprepos,
                                   INPUT par_nmoperad,
                                   INPUT par_auxiliar3,
                                   INPUT par_dttransa,
                                   INPUT par_hrautent,
                                   INPUT par_dtmvtolx,
                                   INPUT par_valor,
                                   INPUT par_dsprotoc,
                                   INPUT par_cdbarras,
                                   INPUT par_lndigita,
                                   INPUT par_auxiliar4,
                                   INPUT par_auxiliar2).    
            END.
        ELSE
        IF  par_cdtippro = 3 THEN
            DO:
                RUN impressao_Cap (INPUT par_nrdconta,
                                   INPUT par_nmprimtl,
                                   INPUT par_auxiliar,
                                   INPUT par_dttransa,
                                   INPUT par_hrautent,
                                   INPUT par_dtmvtolx,
                                   INPUT par_valor,
                                   INPUT par_dsprotoc).     
            END.
        ELSE
        IF  par_cdtippro = 4 THEN
            DO:
                RUN impressao_Credito (INPUT par_nrdconta,   
                                       INPUT par_nmprimtl,   
                                       INPUT par_cdtippro,   
                                       INPUT par_nrdocmto,   
                                       INPUT par_nrseqaut,   
                                       INPUT par_nmprepos,   
                                       INPUT par_nmoperad,   
                                       INPUT par_dttransa,   
                                       INPUT par_hrautent,   
                                       INPUT par_dtmvtolx,   
                                       INPUT par_dsprotoc,   
                                       INPUT par_cdbarras,   
                                       INPUT par_lndigita,   
                                       INPUT par_label,      
                                       INPUT par_valor,      
                                       INPUT par_auxiliar,   
                                       INPUT par_auxiliar2,  
                                       INPUT par_auxiliar3).
            END.
        ELSE
        IF  par_cdtippro = 5 THEN
            DO:
                RUN impressao_taa (INPUT par_nrdconta,
                                   INPUT par_cdbarras,
                                   INPUT par_nmprimtl,
                                   INPUT par_auxiliar,
                                   INPUT par_label,
                                   INPUT par_dttransa,
                                   INPUT par_hrautent,
                                   INPUT par_dtmvtolx,
                                   INPUT par_valor,
                                   INPUT par_dsprotoc).     
            END.        
        ELSE
        IF  par_cdtippro = 6 THEN
            DO:
                RUN impressao_pag_taa (INPUT crabcop.cdbcoctl,
                                       INPUT crabcop.cdagectl,
                                       INPUT par_nrdconta,
                                       INPUT par_label,
                                       INPUT par_nmprimtl,
                                       INPUT par_auxiliar3,
                                       INPUT par_dttransa,
                                       INPUT par_hrautent,
                                       INPUT par_dtmvtolx, 
                                       INPUT par_valor,
                                       INPUT par_dsprotoc,
                                       INPUT par_cdbarras,
                                       INPUT par_lndigita,
                                       INPUT par_auxiliar4,
                                       INPUT par_auxiliar2).
            END.
        ELSE    
        IF  par_cdtippro = 7 THEN
            DO:
                RUN impressao_rem (INPUT par_label,
                                   INPUT par_nrdocmto,
                                   INPUT par_nrdconta,
                                   INPUT par_nmprimtl,
                                   INPUT par_dttransa,
                                   INPUT par_dtmvtolx,
                                   INPUT par_valor,
                                   INPUT par_cdbarras,
                                   INPUT par_lndigita,
                                   INPUT par_dsprotoc).
            END.
        ELSE
        IF  par_cdtippro = 9  THEN
            DO: 
                RUN impressao_ted (INPUT crabcop.cdbcoctl,        
                                   INPUT crabcop.cdagectl,        
                                   INPUT par_nrdconta,        
                                   INPUT par_nmprimtl,        
                                   INPUT par_cdtippro,  
                                   INPUT par_nrdocmto,  
                                   INPUT par_nrseqaut,  
                                   INPUT par_nmprepos,  
                                   INPUT par_nmoperad,  
                                   INPUT par_dttransa,   
                                   INPUT par_hrautent,  
                                   INPUT par_dtmvtolx,  
                                   INPUT par_dsprotoc,  
                                   INPUT par_dsdbanco,        
                                   INPUT par_dsageban,        
                                   INPUT par_nrctafav,        
                                   INPUT par_nmfavore,        
                                   INPUT par_nrcpffav,        
                                   INPUT par_dsfinali,       
                                   INPUT par_dstransf,       
                                   INPUT par_valor).
            END.
        ELSE
        IF  par_cdtippro = 10  THEN
            DO:
                RUN impressao_aplicacao (INPUT crabcop.cdbcoctl,        
                                         INPUT crabcop.cdagectl,        
                                         INPUT par_nrdconta,        
                                         INPUT par_nmprimtl,        
                                         INPUT par_cdtippro,  
                                         INPUT par_nrdocmto,  
                                         INPUT par_nrseqaut,  
                                         INPUT par_nmprepos,  
                                         INPUT par_nmoperad,  
                                         INPUT par_dttransa,   
                                         INPUT par_hrautent,  
                                         INPUT par_dtmvtolx,  
                                         INPUT par_dsprotoc,  
                                         INPUT par_dsdbanco,        
                                         INPUT par_dsageban,        
                                         INPUT par_nrctafav,        
                                         INPUT par_nmfavore,        
                                         INPUT par_nrcpffav,        
                                         INPUT par_dsfinali,       
                                         INPUT par_dstransf,       
                                         INPUT par_valor,
                                         INPUT par_dsinform).
            END.
        ELSE
        IF  par_cdtippro = 12  THEN
            DO:
                RUN impressao_resg_aplicacao (INPUT crabcop.cdbcoctl,        
                                              INPUT crabcop.cdagectl,        
                                              INPUT par_nrdconta,        
                                              INPUT par_nmprimtl,        
                                              INPUT par_cdtippro,  
                                              INPUT par_nrdocmto,  
                                              INPUT par_nrseqaut,  
                                              INPUT par_nmprepos,  
                                              INPUT par_nmoperad,  
                                              INPUT par_dttransa,   
                                              INPUT par_hrautent,  
                                              INPUT par_dtmvtolx,  
                                              INPUT par_dsprotoc,  
                                              INPUT par_dsdbanco,        
                                              INPUT par_dsageban,        
                                              INPUT par_nrctafav,        
                                              INPUT par_nmfavore,        
                                              INPUT par_nrcpffav,        
                                              INPUT par_dsfinali,       
                                              INPUT par_dstransf,       
                                              INPUT par_valor,
                                              INPUT par_dsinform).
            END.
        ELSE
        IF  par_cdtippro = 13  THEN
            DO:

                RUN impressao_gps(INPUT crabcop.cdbcoctl,
                                  INPUT crabcop.cdagectl,
                                  INPUT par_nrdconta,
                                  INPUT par_nmprimtl,
                                  INPUT par_nmprepos, 
                                  INPUT par_auxiliar3,
                                  INPUT par_dttransa,
                                  INPUT par_hrautent,
                                  INPUT par_dsprotoc).


            END.
            
        OUTPUT STREAM str_1 CLOSE.
        ASSIGN aux_returnvl = "OK".      
        LEAVE Imprimir.        
        
    END. /* Imprimir */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF  par_flgerlog THEN
               RUN proc_gerar_log (INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT aux_dscritic,
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT FALSE,
                                   INPUT 1, /** idseqttl **/
                                   INPUT par_nmdatela, 
                                   INPUT par_nrdconta, 
                                  OUTPUT aux_nrdrowid).
        END.
    ELSE
        DO:

            ASSIGN aux_returnvl = "OK".       

            IF  par_idorigem = 5  THEN  /** Ayllos Web **/
                DO:
                    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                        SET h-b1wgen0024.

                    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                        DO:
                            ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                  "b1wgen0024.".

                        END.

                    RUN envia-arquivo-web IN h-b1wgen0024 
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro ).

                    IF  VALID-HANDLE(h-b1wgen0024)  THEN
                        DELETE PROCEDURE h-b1wgen0024.

                    IF  RETURN-VALUE <> "OK" THEN
                        ASSIGN aux_returnvl = "NOK".
                END.
        END.
        
    
    RETURN aux_returnvl.

    
END PROCEDURE.


PROCEDURE impressao_transf:
    
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdtippro  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrseqaut  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_cdbarras  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_lndigita  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_label     AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_valor     AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar2 AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_auxiliar3 AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_dsageban  AS CHAR                           NO-UNDO.

    DEFINE VARIABLE aux_dataEmis AS DATE                             NO-UNDO.
    DEFINE VARIABLE aux_horaEmis AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_cdtippro AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_nrseqaut AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_banco    AS CHARACTER FORMAT "X(50)"         NO-UNDO.

    ASSIGN aux_nrdconta = STRING(par_nrdconta)
           aux_nrdocmto = STRING(par_nrdocmto)
           aux_nrseqaut = STRING(par_nrseqaut)
           aux_banco    = TRIM(ENTRY(2,par_label,":"))
           aux_horaEmis = STRING(TIME,"HH:MM:SS").
    
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_transferencia.
        
    ASSIGN aux_dataEmis = TODAY.
    
    ASSIGN aux_dscabeca[1] =
           "     " + crabcop.nmrescop + " - Comprovante Transferencia - " +
           "Emissao: " + STRING(aux_dataEmis) + " as " + STRING(aux_horaEmis) 
            + " Hr" 
            aux_dscabeca[2] = 
           "           Conta/DV: " + STRING(aux_nrdconta) + " - " 
            + par_nmprimtl.

    ASSIGN aux_dsddados = ""
           aux_contador = 0.
   
    IF  TRIM(par_nmprepos) <> "" THEN
        ASSIGN aux_dsddados[1] = 
               "           Preposto: " + par_nmprepos
               aux_contador = 1.

    IF TRIM(par_nmoperad) <> "" THEN
       ASSIGN aux_dsddados[1 + aux_contador] =
              "           Operador: " + par_nmoperad
              aux_contador = aux_contador + 1.
         
    IF TRIM(par_dsageban) <> ""   THEN
       ASSIGN aux_dsddados[1 + aux_contador] =
           "      Coop. Destino: " + par_dsageban
              aux_contador = aux_contador + 1.

    ASSIGN aux_dsddados[1 + aux_contador] = 
           "   Conta/dv Destino: " + STRING(par_auxiliar)
           aux_dsddados[2 + aux_contador] = 
           "     Data Transacao: " + STRING(par_dttransa)
           aux_dsddados[3 + aux_contador] = 
           "               Hora: " + STRING(par_hrautent,"HH:MM:SS")
           aux_dsddados[4 + aux_contador] = 
           "  Dt. Transferencia: " + STRING(par_dtmvtolx)
           aux_dsddados[5 + aux_contador] =
           "              Valor: " + STRING(par_valor)
           aux_dsddados[6 + aux_contador] = 
           "          Protocolo: " + STRING(par_dsprotoc).
    IF  TRIM(par_cdbarras) <> "" THEN
        ASSIGN aux_dsddados[7 + aux_contador] =
               "   " + par_cdbarras 
               aux_contador = aux_contador + 1.
   
    IF  TRIM(par_lndigita) <> "" THEN
        ASSIGN aux_dsddados[7 + aux_contador] = 
               "    " + par_lndigita 
               aux_contador = aux_contador + 1.

    ASSIGN aux_dsddados[7 + aux_contador] = 
           "      Nr. Documento: " + par_auxiliar2
           aux_dsddados[8 + aux_contador] =
           "  Seq. Autenticacao: " + par_auxiliar3.

    DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" aux_dsddados FORMAT "x(76)" 
         WITH FRAME f_transferencia.

END PROCEDURE.


PROCEDURE impressao_Pag:

    DEF  INPUT PARAM par_cdbcoctl  AS CHAR                        NO-UNDO.
    DEF  INPUT PARAM par_cdagectl  AS CHAR                        NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                        NO-UNDO.         
    DEF  INPUT PARAM par_label     AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                        NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                        NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                        NO-UNDO.   
    DEF  INPUT PARAM par_auxiliar3 AS CHAR                        NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                        NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                        NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                        NO-UNDO.   
    DEF  INPUT PARAM par_valor     AS CHAR                        NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_cdbarras  AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_lndigita  AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar4 AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar2 AS CHAR                        NO-UNDO.         

    DEFINE VARIABLE aux_dataEmis   AS DATE                        NO-UNDO.
    DEFINE VARIABLE aux_horaEmis   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdtippro   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_nrdconta   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdbcoctl   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdagectl   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_banco      AS CHARACTER FORMAT "X(50)"    NO-UNDO.
    
    ASSIGN aux_nrdconta = STRING(par_nrdconta)
           aux_cdbcoctl = STRING(par_cdbcoctl)
           aux_cdagectl = STRING(par_cdagectl)
           aux_banco    = TRIM(ENTRY(2,par_label,":"))
           aux_horaEmis = STRING(TIME,"HH:MM:SS").                 
    
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         aux_dscabeca[3]  AT 1  SKIP
         aux_dscabeca[4]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_pagamento.

    ASSIGN aux_dataEmis = TODAY.

    ASSIGN aux_dscabeca[1] =
           "     " + crabcop.nmrescop + " - Comprovante Pagamento - " +
           "Emissao: " + STRING(aux_dataEmis) + " as " 
           + STRING(aux_horaEmis) + " Hr" 
           aux_dscabeca[2] = 
           "              Banco: " + STRING(aux_cdbcoctl)
           aux_dscabeca[3] = 
           "            Agencia: " + STRING(aux_cdagectl)
           aux_dscabeca[4] = 
           "           Conta/DV: " + STRING(aux_nrdconta) + " - " 
           + par_nmprimtl.

    ASSIGN aux_dsddados = ""
           aux_contador = 0.
   
    IF  TRIM(par_nmprepos) <> "" THEN
        ASSIGN aux_dsddados[1] = 
               "           Preposto: " + par_nmprepos
               aux_contador = 1.
   
    IF TRIM(par_nmoperad) <> "" THEN
       ASSIGN aux_dsddados[1 + aux_contador] =
              "           Operador: " + par_nmoperad
              aux_contador = aux_contador + 1.

    IF TRIM(ENTRY(1,par_label,":")) = "Banco" THEN DO:
        
        ASSIGN aux_dsddados[1 + aux_contador] = 
              "              Banco: " + aux_banco
              aux_dsddados[2 + aux_contador] = 
              "            Cedente: " + par_auxiliar3
              aux_dsddados[3 + aux_contador] = 
              "     Data Transacao: " + STRING(par_dttransa)
                     + "      Hora: " + STRING(par_hrautent,"HH:MM:SS") 
              aux_dsddados[4 + aux_contador] = 
              "     Data Pagamento: " + STRING(par_dtmvtolx)
              aux_dsddados[5 + aux_contador] =
              "              Valor: " + STRING(par_valor)
              aux_dsddados[6 + aux_contador] = 
              "          Protocolo: " + STRING(par_dsprotoc).
        IF  TRIM(par_cdbarras) <> "" THEN
            ASSIGN aux_dsddados[7 + aux_contador] =
                   "   " + par_cdbarras 
                   aux_contador = aux_contador + 1.

        IF  TRIM(par_lndigita) <> "" THEN
            ASSIGN aux_dsddados[7 + aux_contador] = 
                   "    " + par_lndigita 
                   aux_contador = aux_contador + 1.

        ASSIGN aux_dsddados[7 + aux_contador] = 
               "      Nr. Documento: " + par_auxiliar2
               aux_dsddados[8 + aux_contador] =
               "  Seq. Autenticacao: " + par_auxiliar4.

       DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" 
                         aux_dsddados FORMAT "x(76)" WITH FRAME f_pagamento.
     
    END.
    ELSE DO:
        ASSIGN aux_dsddados[1 + aux_contador] = 
               "           " + TRIM(ENTRY(1,par_label,":")) + ": " 
                             + aux_banco
               aux_dsddados[2 + aux_contador] = 
               "     Data Transacao: " + STRING(par_dttransa)
               aux_dsddados[3 + aux_contador] =
               "               Hora: " + 
                              STRING(par_hrautent,"HH:MM:SS")
               aux_dsddados[4 + aux_contador] = 
               "     Data Pagamento: " + STRING(par_dtmvtolx)
               aux_dsddados[5 + aux_contador] =
               "              Valor: " + STRING(par_valor)
               aux_dsddados[6 + aux_contador] = 
               "          Protocolo: " + STRING(par_dsprotoc).
        IF  TRIM(par_cdbarras) <> "" THEN
            ASSIGN aux_dsddados[7 + aux_contador] =
                   "   " + par_cdbarras 
                   aux_contador = aux_contador + 1.

        IF  TRIM(par_lndigita) <> "" THEN
            ASSIGN aux_dsddados[7 + aux_contador] = 
                   "    " + par_lndigita 
                   aux_contador = aux_contador + 1.

        ASSIGN aux_dsddados[7 + aux_contador] = 
               "      Nr. Documento: " + par_auxiliar2
               aux_dsddados[8 + aux_contador] =
               "  Seq. Autenticacao: " + par_auxiliar4.

        DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" 
                          aux_dsddados FORMAT "x(76)" WITH FRAME f_pagamento.
    END.
END.


PROCEDURE impressao_Cap:
    
    DEF  INPUT PARAM par_nrdconta AS INTE                 NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl AS CHAR FORMAT "x(40)"  NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar AS CHAR FORMAT "x(50)"  NO-UNDO.   
    DEF  INPUT PARAM par_dttransa AS DATE                 NO-UNDO.   
    DEF  INPUT PARAM par_hrautent AS INTE                 NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx AS DATE                 NO-UNDO.   
    DEF  INPUT PARAM par_valor    AS CHAR                 NO-UNDO.    
    DEF  INPUT PARAM par_dsprotoc AS CHAR FORMAT "x(40)"  NO-UNDO.   

    DEFINE VARIABLE aux_dataEmis   AS DATE        NO-UNDO.
    DEFINE VARIABLE aux_horaEmis   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_cdtippro   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nrdconta   AS CHARACTER   NO-UNDO.

    ASSIGN aux_nrdconta = STRING(par_nrdconta)
           aux_horaEmis = STRING(TIME,"HH:MM:SS").                 

    FORM "--------------------------------------------------------------------------------" SKIP
         crabcop.nmrescop NO-LABEL              AT 5  
         "  -  Comprovante Capital  - "         AT 17
         aux_dataEmis     LABEL "Emissao"       
         "as"
         aux_horaEmis                           
         "Hr"                                           SKIP(1)
         aux_nrdconta     LABEL "Conta/DV"      AT 11    
         " - "                                  AT 31   
         par_nmprimtl     NO-LABEL              AT 34   SKIP
         "--------------------------------------------------------------------------------" SKIP
         par_auxiliar      AT 03 LABEL "Nr. do Plano"   SKIP 
         par_dttransa  AT 11 LABEL "Data"           SKIP
         par_hrautent  AT 11 LABEL "Hora"           SKIP
         par_dtmvtolx  AT 01 LABEL "Data Movimento" SKIP
         par_valor         AT 10 LABEL "Valor"          SKIP
         par_dsprotoc  AT 06 LABEL "Protocolo"      SKIP
        "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_capital.

    ASSIGN aux_dataEmis = TODAY.

    DISPLAY STREAM str_1 crabcop.nmrescop
                         aux_dataEmis
                         aux_horaEmis
                         aux_nrdconta
                         par_nmprimtl
                         par_dttransa
                         STRING(par_hrautent,"HH:MM:SS") @ par_hrautent                 
                         par_auxiliar
                         par_dtmvtolx
                         par_valor
                         par_dsprotoc 
        WITH FRAME f_capital.

    
END.


PROCEDURE impressao_Credito:

    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdtippro  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrseqaut  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_cdbarras  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_lndigita  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_label     AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_valor     AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_auxiliar2 AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_auxiliar3 AS CHAR                           NO-UNDO.        
    
    DEFINE VARIABLE aux_dataEmis AS DATE                             NO-UNDO.
    DEFINE VARIABLE aux_horaEmis AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_cdtippro AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_nrseqaut AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_banco    AS CHARACTER FORMAT "X(50)"         NO-UNDO.

    ASSIGN aux_nrdconta = STRING(par_nrdconta)
           aux_nrdocmto = STRING(par_nrdocmto)
           aux_nrseqaut = STRING(par_nrseqaut)
           aux_banco    = TRIM(ENTRY(2,par_label,":"))
           aux_horaEmis = STRING(TIME,"HH:MM:SS").
    
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_transferencia.
        
    ASSIGN aux_dataEmis = TODAY.
    
    ASSIGN aux_dscabeca[1] =
           "     " + crabcop.nmrescop + " - Comprovante Transferencia - " +
           "Emissao: " + STRING(aux_dataEmis) + " as " + STRING(aux_horaEmis) 
            + " Hr" aux_dscabeca[2] = 
           "           Conta/DV: " + STRING(aux_nrdconta) + " - " 
            + par_nmprimtl.

    ASSIGN aux_dsddados = ""
           aux_contador = 0.
   
    IF  TRIM(par_nmprepos) <> "" THEN
        ASSIGN aux_dsddados[1] = 
               "           Preposto: " + par_nmprepos
               aux_contador = 1.
    IF TRIM(par_nmoperad) <> "" THEN
       ASSIGN aux_dsddados[1 + aux_contador] =
              "           Operador: " + par_nmoperad
              aux_contador = aux_contador + 1.
         
    ASSIGN aux_dsddados[1 + aux_contador] = 
           "   Conta/dv Destino: " + STRING(par_auxiliar)
           aux_dsddados[2 + aux_contador] = 
           "     Data Transacao: " + STRING(par_dttransa)
           aux_dsddados[3 + aux_contador] = 
           "               Hora: " + STRING(par_hrautent,"HH:MM:SS")
           aux_dsddados[4 + aux_contador] = 
           "  Dt. Transferencia: " + STRING(par_dtmvtolx)
           aux_dsddados[5 + aux_contador] =
           "              Valor: " + STRING(par_valor)
           aux_dsddados[6 + aux_contador] = 
           "          Protocolo: " + STRING(par_dsprotoc).
    IF  TRIM(par_cdbarras) <> "" THEN
        ASSIGN aux_dsddados[7 + aux_contador] =
               "   " + par_cdbarras 
               aux_contador = aux_contador + 1.
   
    IF  TRIM(par_lndigita) <> "" THEN
        ASSIGN aux_dsddados[7 + aux_contador] = 
               "    " + par_lndigita 
               aux_contador = aux_contador + 1.

    ASSIGN aux_dsddados[7 + aux_contador] = 
           "      Nr. Documento: " + par_auxiliar2
           aux_dsddados[8 + aux_contador] =
           "  Seq. Autenticacao: " + par_auxiliar3.

    DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" aux_dsddados FORMAT "x(76)" 
         WITH FRAME f_transferencia.
END.

PROCEDURE impressao_taa:

    DEF  INPUT PARAM par_nrdconta AS INTE                         NO-UNDO.         
    DEF  INPUT PARAM par_cdbarras AS CHAR                         NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl AS CHAR FORMAT "x(40)"          NO-UNDO.   
    DEF  INPUT PARAM par_auxiliar AS CHAR FORMAT "x(50)"          NO-UNDO.
    DEF  INPUT PARAM par_label    AS CHAR                         NO-UNDO.
    DEF  INPUT PARAM par_dttransa AS DATE                         NO-UNDO.   
    DEF  INPUT PARAM par_hrautent AS INTE                         NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx AS DATE                         NO-UNDO.    
    DEF  INPUT PARAM par_valor    AS CHAR                         NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc AS CHAR FORMAT "x(40)"          NO-UNDO. 


    DEFINE VARIABLE aux_dataEmis   AS DATE                        NO-UNDO.
    DEFINE VARIABLE aux_horaEmis   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdtippro   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_nrdconta   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_banco      AS CHARACTER FORMAT "X(50)"    NO-UNDO.
    DEFINE VARIABLE aux_cdbarras   AS CHARACTER FORMAT "X(50)"    NO-UNDO.
    
    ASSIGN aux_nrdconta = STRING(par_nrdconta)
           aux_cdbarras = STRING(par_cdbarras)
           aux_horaEmis = STRING(TIME,"HH:MM:SS").   

    FORM "--------------------------------------------------------------------------------" SKIP
         crabcop.nmrescop NO-LABEL                  AT 5  
         " - Comprovante Deposito TAA -"            AT 17
         aux_dataEmis     LABEL "Emissao"           
         "as"
         aux_horaEmis                                     
         "Hr"                                             SKIP(1)
         aux_nrdconta     LABEL "Conta/DV"          AT 11  
         " - "                                      AT 31 
         par_nmprimtl     NO-LABEL                  AT 34 SKIP
         "--------------------------------------------------------------------------------" SKIP
         par_auxiliar      AT 13 LABEL "aaaaaaaaaaa"     SKIP   
         par_dttransa  AT 20 LABEL "Data"            SKIP
         par_hrautent  AT 20 LABEL "Hora"            SKIP
         par_dtmvtolx  AT 10 LABEL "Data Movimento"  SKIP
         par_valor         AT 19 LABEL "Valor"           SKIP
         par_dsprotoc  AT 15 LABEL "Protocolo"       SKIP
         aux_cdbarras      AT 08 NO-LABEL
        "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_taa.
    par_auxiliar:LABEL = TRIM(ENTRY(1,par_label,":")).

    ASSIGN aux_dataEmis = TODAY.

    DISPLAY STREAM str_1 crabcop.nmrescop
                         aux_dataEmis
                         aux_horaEmis
                         aux_nrdconta
                         par_nmprimtl
                         par_auxiliar
                         par_dttransa
                         STRING(par_hrautent,"HH:MM:SS") @ par_hrautent                 
                         par_dtmvtolx
                         par_valor
                         par_dsprotoc 
                         aux_cdbarras
        WITH FRAME f_taa.
END.

PROCEDURE impressao_pag_taa:

    DEF  INPUT PARAM par_cdbcoctl  AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_cdagectl  AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_nrdconta  AS INTE                        NO-UNDO.         
    DEF  INPUT PARAM par_label     AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR FORMAT "x(40)"         NO-UNDO.   
    DEF  INPUT PARAM par_auxiliar3 AS CHAR                        NO-UNDO.
    DEF  INPUT PARAM par_dttransa  AS DATE                        NO-UNDO.
    DEF  INPUT PARAM par_hrautent  AS INTE                        NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                        NO-UNDO.   
    DEF  INPUT PARAM par_valor     AS CHAR                        NO-UNDO.    
    DEF  INPUT PARAM par_dsprotoc  AS CHAR FORMAT "x(40)"         NO-UNDO.   
    DEF  INPUT PARAM par_cdbarras  AS CHAR FORMAT "x(65)"         NO-UNDO. 
    DEF  INPUT PARAM par_lndigita  AS CHAR FORMAT "x(75)"         NO-UNDO.  
    DEF  INPUT PARAM par_auxiliar4 AS CHAR                        NO-UNDO.
    DEF  INPUT PARAM par_auxiliar2 AS CHAR                        NO-UNDO.
                                                                          
    DEFINE VARIABLE aux_dataEmis   AS DATE                        NO-UNDO.
    DEFINE VARIABLE aux_horaEmis   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdtippro   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_nrdconta   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdbcoctl   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_cdagectl   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_banco      AS CHARACTER FORMAT "X(50)"    NO-UNDO.
    
    ASSIGN aux_nrdconta = STRING(par_nrdconta)
           aux_cdbcoctl = STRING(par_cdbcoctl)
           aux_cdagectl = STRING(par_cdagectl)
           aux_banco    = TRIM(ENTRY(2,par_label,":"))
           aux_horaEmis = STRING(TIME,"HH:MM:SS").  
                                                      
    FORM "--------------------------------------------------------------------------------" SKIP
         crabcop.nmrescop NO-LABEL                     AT 5  
         "- Comprovante Pagamento TAA -"               AT 17
         aux_dataEmis    LABEL "Emissao"            
         "as"
         aux_horaEmis                                 
         "Hr"                                                SKIP(1)
         aux_cdbcoctl    LABEL "Banco"                 AT 14 SKIP 
         aux_cdagectl    LABEL "Agencia"               AT 12 SKIP 
         aux_nrdconta    LABEL "Conta/DV"              AT 11  
         " - "                                         AT 31 
         par_nmprimtl    NO-LABEL                      AT 34 SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_banco        AT 14 LABEL "Banco"           SKIP
         par_auxiliar3    AT 12 LABEL "Cedente"         SKIP
         par_dttransa AT 5  LABEL "Data Transacao"  SKIP
         par_hrautent AT 15 LABEL "Hora"            SKIP
         par_dtmvtolx AT 05 LABEL "Data Pagamento"  SKIP
         par_valor        AT 14 LABEL "Valor"           SKIP
         par_dsprotoc AT 10 LABEL "Protocolo"       SKIP
         par_cdbarras     AT 3  SKIP                        
         par_lndigita     AT 4  SKIP
         par_auxiliar4    AT 2  LABEL "Seq. Autenticacao" SKIP
         par_auxiliar2    AT 6  LABEL "Nr. Documento" SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_pagamento_taa.

    FORM "--------------------------------------------------------------------------------" SKIP
         crabcop.nmrescop NO-LABEL                     AT 5  
         "- Comprovante Pagamento TAA -"               AT 17
         aux_dataEmis     LABEL "Emissao"            
         "as"
         aux_horaEmis                                  
         "Hr"                                                SKIP(1)
         aux_cdbcoctl    LABEL "Banco"                 AT 14 SKIP 
         aux_cdagectl    LABEL "Agencia"               AT 12 SKIP 
         aux_nrdconta    LABEL "Conta/DV"              AT 11  
         " - "                                         AT 31 
         par_nmprimtl    NO-LABEL                      AT 34 SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_banco        AT 9  LABEL "aaaaaaaaaa" SKIP
         par_dttransa AT 5  LABEL "Data Transacao"  SKIP
         par_hrautent AT 15 LABEL "Hora"  SKIP
         par_dtmvtolx AT 05 LABEL "Data Pagamento"   SKIP
         par_valor        AT 14 LABEL "Valor"  SKIP
         par_dsprotoc AT 10 LABEL "Protocolo"  SKIP
         par_cdbarras     AT 3  SKIP
         par_lndigita     AT 4  SKIP
         par_auxiliar4    AT 2  LABEL "Seq. Autenticacao" SKIP
         par_auxiliar2    AT 6  LABEL "Nr. Documento" SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_pagamento_taa2.

    ASSIGN aux_dataEmis = TODAY.

    IF TRIM(ENTRY(1,par_label,":")) = "Banco" THEN DO:
        DISPLAY STREAM str_1 crabcop.nmrescop 
                             aux_dataEmis
                             aux_horaEmis
                             aux_nrdconta
                             par_nmprimtl
                             aux_cdbcoctl
                             aux_cdagectl
    
                             aux_banco
                             par_auxiliar3
                             par_dttransa
                             STRING(par_hrautent,"HH:MM:SS") @ par_hrautent                 
                             par_dtmvtolx
                             par_valor
                             par_dsprotoc 
                             par_cdbarras
                             par_lndigita
                             par_auxiliar4
                             par_auxiliar2
            WITH FRAME f_pagamento_taa.
            aux_banco:LABEL = TRIM(ENTRY(1,par_label,":")).
    END.
    ELSE DO:
        DISPLAY STREAM str_1 crabcop.nmrescop 
                             aux_dataEmis
                             aux_horaEmis
                             aux_nrdconta
                             par_nmprimtl
                             aux_cdbcoctl
                             aux_cdagectl
    
                             aux_banco
                             par_dttransa 
                             STRING(par_hrautent,"HH:MM:SS") @ par_hrautent                 
                             par_dtmvtolx
                             par_valor
                             par_dsprotoc 
                             par_cdbarras
                             par_lndigita
                             par_auxiliar4
                             par_auxiliar2
            WITH FRAME f_pagamento_taa2.
            aux_banco:LABEL = TRIM(ENTRY(1,par_label,":")).
    END.

END PROCEDURE.


PROCEDURE impressao_rem:

    DEF  INPUT PARAM par_label     AS CHAR                        NO-UNDO.         
    DEF  INPUT PARAM par_nrdocmto  AS DECI                        NO-UNDO.         
    DEF  INPUT PARAM par_nrdconta  AS INTE                        NO-UNDO.   
    DEF  INPUT PARAM par_nmprimtl  AS CHAR FORMAT "x(40)"         NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                        NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                        NO-UNDO.   
    DEF  INPUT PARAM par_valor     AS CHAR                        NO-UNDO.   
    DEF  INPUT PARAM par_cdbarras  AS CHAR FORMAT "x(40)"         NO-UNDO.    
    DEF  INPUT PARAM par_lndigita  AS CHAR FORMAT "x(40)"         NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR FORMAT "x(40)"         NO-UNDO.   

    DEFINE VARIABLE aux_dataEmis   AS DATE                        NO-UNDO.
    DEFINE VARIABLE aux_horaEmis   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_dsconven   AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto   AS CHARACTER                   NO-UNDO.
    
    ASSIGN aux_horaEmis = STRING(TIME,"HH:MM:SS")
           aux_dataEmis = TODAY
           aux_dsconven = par_label
           aux_nrdocmto = 
                TRIM(STRING(par_nrdocmto,"zzz,zzz,zzz,zz9")) NO-ERROR.                
    
    FORM "--------------------------------------------------------------------------------" SKIP
         crabcop.nmrescop NO-LABEL              AT 5  
         "- Arquivo Remessa -"                  AT 19
         aux_dataEmis     LABEL "Emissao"       AT 39
         aux_nrdocmto     LABEL "Remessa"       AT 57
         SKIP(1)
         par_nrdconta     LABEL "Conta/DV"      AT 11  
         " - "                                  AT 31 
         par_nmprimtl     NO-LABEL              AT 34   SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsconven     AT 11 NO-LABEL FORMAT "x(30)"   SKIP
         par_dttransa AT 5  LABEL "Data Transacao"  
         aux_horaEmis     AT 2  LABEL "Hora da Transacao" SKIP   
         par_dtmvtolx AT 04 LABEL "Data da Remessa"   SKIP   
         par_valor        AT 14 LABEL "Valor"             SKIP
         par_cdbarras     AT 3  SKIP /* Total de boletos */
         par_lndigita     AT 4  SKIP    /* Arquivo */
         par_dsprotoc AT 10 LABEL "Protocolo"         SKIP
         
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_remessa.

    DISPLAY STREAM str_1 crabcop.nmrescop
                         aux_dataEmis
                         aux_nrdocmto   
                         par_nrdconta
                         par_nmprimtl
                         aux_dsconven
                         par_dttransa
                         aux_horaEmis
                         par_dtmvtolx
                         par_valor       
                         par_cdbarras    
                         par_lndigita    
                         par_dsprotoc WITH FRAME f_remessa.

END PROCEDURE.


PROCEDURE impressao_ted:
    
    DEF  INPUT PARAM par_cdbcoctl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdagectl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdtippro  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrseqaut  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dsdbanco  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_dsageban  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrctafav  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nmfavore  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrcpffav  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_dsfinali  AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_dstransf  AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_vldocmto  AS CHAR                           NO-UNDO.
    
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         aux_dsddados[13] AT 1  SKIP
         aux_dsddados[14] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_ted.
        
    ASSIGN aux_dscabeca[1] =
           "     " + crabcop.nmrescop + " - Comprovante TED - " +
           "Emissao: " + STRING(TODAY,"99/99/9999") + " as " + 
           STRING(TIME,"HH:MM:SS") + " Hr" 
           aux_dscabeca[2] = 
           "           Conta/DV: " + 
           TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + " - " +
           par_nmprimtl.

    ASSIGN aux_dsddados = ""
           aux_contador = 0.
   
    IF  TRIM(par_nmprepos) <> "" THEN
        ASSIGN aux_dsddados[1] = 
               "           Preposto: " + par_nmprepos
               aux_contador = 1.

    IF  TRIM(par_nmoperad) <> "" THEN
        ASSIGN aux_dsddados[1 + aux_contador] =
               "           Operador: " + par_nmoperad
               aux_contador = aux_contador + 1.
         
    ASSIGN aux_dsddados[1 + aux_contador] = 
                       "   Banco Favorecido: " + TRIM(ENTRY(1,par_dsdbanco,"#"))
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] = 
                       "    ISPB Favorecido: " + TRIM(ENTRY(2,par_dsdbanco,"#"))
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] = 
                       " Agencia Favorecido: " + par_dsageban
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] = 
                       "   Conta Favorecido: " + par_nrctafav
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] = 
                       "    Nome Favorecido: " + par_nmfavore
           aux_contador = aux_contador + 1.

    IF  LENGTH(par_nrcpffav) = 18  THEN
        ASSIGN aux_dsddados[1 + aux_contador] = 
               "    CNPJ Favorecido: " + par_nrcpffav
               aux_contador = aux_contador + 1.
    ELSE
        ASSIGN aux_dsddados[1 + aux_contador] = 
               "     CPF Favorecido: " + par_nrcpffav
               aux_contador = aux_contador + 1.

    ASSIGN aux_dsddados[1 + aux_contador] = 
                       "         Finalidade: " + par_dsfinali
           aux_contador = aux_contador + 1.

    IF  par_dstransf <> ""  THEN
        ASSIGN aux_dsddados[1 + aux_contador] = 
                       "  Cod.Identificador: " + par_dstransf
               aux_contador = aux_contador + 1.

    ASSIGN aux_dsddados[1 + aux_contador] = 
                       "Data/Hora Transacao: " +
                       STRING(par_dttransa,"99/99/9999") + " - " + 
                       STRING(par_hrautent,"HH:MM:SS")
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] =
                       "              Valor: " + 
                       par_vldocmto
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] = 
                       "          Protocolo: " +
                       STRING(par_dsprotoc)
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] = 
                       "      Nr. Documento: " + 
                       STRING(par_nrdocmto)
           aux_contador = aux_contador + 1
           aux_dsddados[1 + aux_contador] =
                       "  Seq. Autenticacao: " + 
                       STRING(par_nrseqaut)
           aux_contador = aux_contador + 1.

    DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" aux_dsddados FORMAT "x(76)" 
         WITH FRAME f_ted.

END PROCEDURE.

PROCEDURE impressao_aplicacao:
    
    DEF  INPUT PARAM par_cdbcoctl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdagectl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdtippro  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrseqaut  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dsdbanco  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_dsageban  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrctafav  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nmfavore  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrcpffav  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_dsfinali  AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_dstransf  AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_vldocmto  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinform  LIKE crappro.dsinform             NO-UNDO.
    
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         aux_dsddados[13] AT 1  SKIP
         aux_dsddados[14] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_ted.
        
    ASSIGN aux_dscabeca[1] =
           "     " + crabcop.nmrescop + " - Comprovante Aplicacao - " +
           "Emissao: " + STRING(TODAY,"99/99/9999") + " as " + 
           STRING(TIME,"HH:MM:SS") + " Hr" 
           aux_dscabeca[2] = 
           "           Conta/DV: " + 
           TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + " - " +
           par_nmprimtl.

    ASSIGN aux_dsddados = ""
           aux_contador = 0.
   
    IF  TRIM(par_nmprepos) <> "" THEN
        ASSIGN aux_dsddados[1] = 
               "           Preposto: " + par_nmprepos
               aux_contador = 1.

    IF  TRIM(par_nmoperad) <> "" THEN
        ASSIGN aux_dsddados[1 + aux_contador] =
               "           Operador: " + par_nmoperad
               aux_contador = aux_contador + 1.
         
    ASSIGN aux_dsddados[1 + aux_contador] = 
                   "          Solicitante: " + TRIM(ENTRY(1,par_dsinform[2],"#"))
           aux_dsddados[2 + aux_contador] = 
                   "    Data da aplicacao: " + TRIM(ENTRY(2,ENTRY(1,par_dsinform[3],"#"),":"))
           aux_dsddados[3 + aux_contador] =
                   "    Hora da Aplicacao: " + 
                         STRING(par_hrautent,"HH:MM:SS")
           aux_dsddados[4 + aux_contador] =
                   "  Numero da Aplicacao: " + 
                         TRIM(ENTRY(2,ENTRY(2,par_dsinform[3],"#"),":"))
           aux_dsddados[4 + aux_contador] = IF NUM-ENTRIES(par_dsinform[3],"#") >= 12 THEN
                                              IF TRIM(ENTRY(11,par_dsinform[3],"#")) = "N" THEN
                                                aux_dsddados[4 + aux_contador] + " - " + TRIM(ENTRY(12,par_dsinform[3],"#"))
                                              ELSE
                                                aux_dsddados[4 + aux_contador]                                                           
                                            ELSE
                                              aux_dsddados[4 + aux_contador]
           aux_dsddados[5 + aux_contador] =
           "                Valor: " + STRING(par_vldocmto)
           aux_dsddados[6 + aux_contador] =
           "      Taxa Contratada: " + TRIM(ENTRY(2,ENTRY(3,par_dsinform[3],"#"),":"))
           aux_dsddados[7 + aux_contador] =
           "          Taxa Minima: " + TRIM(ENTRY(2,ENTRY(4,par_dsinform[3],"#"),":"))
           aux_dsddados[8 + aux_contador] =
           "           Vencimento: " + TRIM(ENTRY(2,ENTRY(5,par_dsinform[3],"#"),":"))
           aux_dsddados[9 + aux_contador] =
           "             Carencia: " + TRIM(ENTRY(2,ENTRY(6,par_dsinform[3],"#"),":"))
           aux_dsddados[10 + aux_contador] =
           "     Data da Carencia: " + TRIM(ENTRY(2,ENTRY(7,par_dsinform[3],"#"),":"))
           aux_dsddados[11 + aux_contador] = 
           "            Protocolo: " + STRING(par_dsprotoc)
           aux_dsddados[12 + aux_contador] =
           "    Seq. Autenticacao: " + STRING(par_nrseqaut).

    DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" aux_dsddados FORMAT "x(76)" 
         WITH FRAME f_ted.

END PROCEDURE.

PROCEDURE impressao_resg_aplicacao:
    
    DEF  INPUT PARAM par_cdbcoctl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdagectl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_cdtippro  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrseqaut  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_nmoperad  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dttransa  AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_hrautent  AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolx  AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_dsdbanco  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_dsageban  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrctafav  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nmfavore  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_nrcpffav  AS CHAR                           NO-UNDO.         
    DEF  INPUT PARAM par_dsfinali  AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_dstransf  AS CHAR                           NO-UNDO.        
    DEF  INPUT PARAM par_vldocmto  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinform  LIKE crappro.dsinform             NO-UNDO.
    
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         aux_dsddados[13] AT 1  SKIP
         aux_dsddados[14] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_ted.
        
    ASSIGN aux_dscabeca[1] =
           "     " + crabcop.nmrescop + " - Comprovante Aplicacao - " +
           "Emissao: " + STRING(TODAY,"99/99/9999") + " as " + 
           STRING(TIME,"HH:MM:SS") + " Hr" 
           aux_dscabeca[2] = 
           "           Conta/DV: " + 
           TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + " - " +
           par_nmprimtl.

    ASSIGN aux_dsddados = ""
           aux_contador = 0.
   
    IF  TRIM(par_nmprepos) <> "" THEN
        ASSIGN aux_dsddados[1] = 
               "           Preposto: " + par_nmprepos
               aux_contador = 1.

    IF  TRIM(par_nmoperad) <> "" THEN
        ASSIGN aux_dsddados[1 + aux_contador] =
               "           Operador: " + par_nmoperad
               aux_contador = aux_contador + 1.
         
    ASSIGN aux_dsddados[1 + aux_contador] = 
                   "          Solicitante: " + TRIM(ENTRY(1,par_dsinform[2],"#"))
           aux_dsddados[2 + aux_contador] = 
                   "      Data do Resgate: " + TRIM(ENTRY(2,ENTRY(1,par_dsinform[3],"#"),":"))
           aux_dsddados[3 + aux_contador] =
                   "      Hora do Resgate: " + 
                         STRING(par_hrautent,"HH:MM:SS")
           aux_dsddados[4 + aux_contador] =
                   "  Numero da Aplicacao: " + 
                         TRIM(ENTRY(2,ENTRY(2,par_dsinform[3],"#"),":"))
           aux_dsddados[5 + aux_contador] =
                   "          Valor Bruto: " + TRIM(ENTRY(2,ENTRY(5,par_dsinform[3],"#"),":"))
           aux_dsddados[6 + aux_contador] =
                   "                 IRRF: " + TRIM(ENTRY(2,ENTRY(3,par_dsinform[3],"#"),":"))
           aux_dsddados[7 + aux_contador] = 
                            "                      (Imposto de Renda Retido na Fonte)"
           aux_dsddados[8 + aux_contador] =
                   "        Aliquota IRRF: " + TRIM(ENTRY(2,ENTRY(4,par_dsinform[3],"#"),":"))
           aux_dsddados[9 + aux_contador] =
                   "        Valor Liquido: " + STRING(par_vldocmto)
           aux_dsddados[10 + aux_contador] = 
           "            Protocolo: " + STRING(par_dsprotoc)
           aux_dsddados[11 + aux_contador] =
           "    Seq. Autenticacao: " + STRING(par_nrseqaut).

    DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" aux_dsddados FORMAT "x(76)" 
         WITH FRAME f_ted.

END PROCEDURE.

/* emissao de comprovante GPS */
PROCEDURE impressao_gps:

    DEF  INPUT PARAM par_cdbcoctl  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagectl  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.         
    DEF  INPUT PARAM par_nmprimtl  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprepos  AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_auxiliar3 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dttransa  LIKE crappro.dttransa             NO-UNDO.
    DEF  INPUT PARAM par_hrautent  LIKE crappro.hrautent             NO-UNDO.
    DEF  INPUT PARAM par_dsprotoc  AS CHAR                           NO-UNDO.

    DEF VAR aux_qtregist AS INTE                                           NO-UNDO. 
     
    FORM "--------------------------------------------------------------------------------" SKIP
         aux_dscabeca[1]  AT 1  SKIP(1)
         aux_dscabeca[2]  AT 1  SKIP
         aux_dscabeca[3]  AT 1  SKIP
         aux_dscabeca[4]  AT 1  SKIP
         aux_dscabeca[5]  AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP
         aux_dsddados[1]  AT 1  SKIP
         aux_dsddados[2]  AT 1  SKIP
         aux_dsddados[3]  AT 1  SKIP
         aux_dsddados[4]  AT 1  SKIP
         aux_dsddados[5]  AT 1  SKIP
         aux_dsddados[6]  AT 1  SKIP
         aux_dsddados[7]  AT 1  SKIP
         aux_dsddados[8]  AT 1  SKIP
         aux_dsddados[9]  AT 1  SKIP
         aux_dsddados[10] AT 1  SKIP
         aux_dsddados[11] AT 1  SKIP
         aux_dsddados[12] AT 1  SKIP
         aux_dsddados[13] AT 1  SKIP
         aux_dsddados[14] AT 1  SKIP
         "--------------------------------------------------------------------------------" SKIP(2)
    WITH NO-BOX NO-LABEL COLUMN 01 SIDE-LABELS DOWN WIDTH 80 FRAME f_gps.

    /* recupera a quantidade de registros */
    aux_qtregist = NUM-ENTRIES(par_auxiliar3, "#").
    
    IF aux_qtregist > 0 THEN
    DO:

        ASSIGN aux_dscabeca[1] = "Comprovante de Pagamento GPS "
               aux_dscabeca[2] = "       Banco: " + STRING(par_cdbcoctl)
               aux_dscabeca[3] = "     Agencia: " + STRING(par_cdagectl)
               aux_dscabeca[4] = "    Conta/DV: " + TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + " - " + par_nmprimtl
               aux_dscabeca[5] = "    Preposto: " + STRING(par_nmprepos).

        DO aux_contador = 1 TO aux_qtregist:
            /* monta os campos com as informacoes */
            aux_dsddados[aux_contador] = ENTRY(aux_contador,par_auxiliar3,"#").
            /* monta alinhamento dos campos com 30 espacos */
            aux_dsddados[aux_contador] = fill(" ", 30 - length(ENTRY(1, aux_dsddados[aux_contador],":"))) + aux_dsddados[aux_contador].
        END.

        aux_dsddados[aux_qtregist + 1] = "                Data Transacao: " + STRING(par_dttransa, "99/99/9999").
        aux_dsddados[aux_qtregist + 2] = "                          Hora: " + STRING(par_hrautent, "HH:MM:SS").
        aux_dsddados[aux_qtregist + 3] = "       Autenticação Eletrônica: " + STRING(par_dsprotoc).

        DISP STREAM str_1 aux_dscabeca FORMAT "x(76)" aux_dsddados FORMAT "x(76)" 
             WITH FRAME f_gps.
    END.

END PROCEDURE.

/*................................ FUNCTIONS ................................*/

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digita verificador
     Notas:  
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_vlresult AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    ASSIGN 
        aux_nrdconta = par_nrdconta
        aux_vlresult = TRUE.

    RUN dig_fun IN h-b1wgen9999 
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT aux_nrdconta,
         OUTPUT TABLE tt-erro ).
    
    DELETE OBJECT h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_vlresult = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_vlresult = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_nrdconta <> par_nrdconta THEN
        ASSIGN aux_vlresult = FALSE.

   RETURN aux_vlresult.
        
END FUNCTION.
