/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------------+-------------------------------------------+
  | Rotina Progress                       | Rotina Oracle PLSQL                       |
  +---------------------------------------+-------------------------------------------+
  | b1wgen0021.p (Variaveis)                 | EXTR0002                               |
  | blwgen0021.extrato_cotas                 | EXTR0002.pc_extrato_cotas              |
  +------------------------------------------+----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/
/*..............................................................................

   Programa: b1wgen0021.p
   Autor   : Murilo/David
   Data    : 21/06/2007                     Ultima atualizacao: 17/11/2015

   Objetivo  : BO CAPITAL

   Alteracoes: 07/11/2007 - Tratamentos para Plano de Capital na Internet e para
                            geracao de log (David).
                            
               10/12/2007 - Carregar Lote,PAC,Banco/Caixa do Capital (David).

               21/12/2007 - Nao validar data de inicio do novo plano quando
                            for debito em folha (David).

               19/02/2008 - Incluir procedure obtem-saldo-cotas (David).
               
               13/03/2008 - Gerar log na valida-dados-plano somente se origem
                            for Internet 
                          - Utilizar procedures de BO generica 9999 
                          - Incluir flag para gerar log na procedure 
                            obtem_dados_capital (David).

               31/07/2008 - Incluir parametro na procedure gera_protocolo
                            (David).
                            
               04/11/2008 - Alimentar o campo cdufdcop da tt-autorizacao e
                            tt-cancelamento (Guilherme).             
                            
               10/11/2008 - Dar empty temp-table e limpar variaveis de erro 
                            (Guilherme).
                            
               13/02/2009 - Alteracao cdempres (Diego).

               19/08/2009 - Acerto na geracao de log e liberacao de registros
                            em LOCK (David).
                            
               22/03/2009 - Alimentar tt-novo-plano.qtpremax para planos ja
                            existentes (Guilherme).
                            
               23/12/2010 - Alterada procedure extrato_cotas para permitir o 
                            calculo para mais de 1 ano atras (Henrique).

               03/03/2011 - Usar o primeiro craplct quando nao houver 
                            crapdir para o periodo informado. Estavamos
                            usando crapass.dtmvtolt, mais para cooperados
                            antigos estava como o ultimo dia do mes(Magui).

               04/10/2011 - Adicionado o parametro par_flgerlog na chamada da 
                            procedure extrato_cotas (Rogerius Militão - DB1)

               27/10/2011 - Parametros na gera_protocolo (Guilherme).

               17/05/2012 - Tratamento na procedure dados_autorizacao para 
                            verificar origem somente quando for chamado pelo
                            InternetBank (David).
                            (Lucas R.).

               03/06/2013 - Buscar Saldo Bloqueado Judicial e grava nas tt-table 
                            das procedure obtem-saldo-cotas, obtem_dados_capital             
                            (Andre Santos - SUPERO)

               10/09/2013 - Tratamento nas procedures cria-plano, 
                            cancelar-plano-atual e exclui-plano para
                            adequacao ao projeto de Debito Diario de Cotas.
                            (Fabricio)

               19/12/2013 - Adicionado validate para tabela craplot (Tiago).   


               02/01/2014 - Ajuste leitura crapmat evitando bloqueio da mesma (Daniel).

               25/02/2014 - Criado procedures valida-dados-alteracao-plano e
                            altera-plano. (Fabricio)

               24/03/2014 - Ajuste na procedure "cria-plano" para buscar a 
                            proxima sequencia crapmat.nrctrpla apartir banco 
                            Oracle (James)

               11/06/2014 - Alteracao a critica "Atenção: 269 – Valor errado", 
                            para "Para diminuir o valor do débito mensal do 
                            plano, entre em contato com o seu posto de atendimento."
                            (Carlos Rafael Tanholi - 167016)
                            Alteracao do conteudo do termo de plano de capital
                            (Guilherme/SUPERO)


               12/11/2014 - Alteração na procedure obtem-novo-plano 
                            tt-novo-plano.cdtipcor = 1 para trazer por DEFAULT
                            a opção "Correção por Indice de Inflação" SD 217660 (Vanessa)

               21/01/2015 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)

               15/05/2015 - Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)
                            
               17/09/2015 - Alterado as procedures cria-plano e altera-plano
                            para gera o log corretamente das alteracoes de plano
                            e corrigida a procedure log_itens_plano para ficar
                            de acordo com as aletracoes anteriores 
                            (Tiago/Gielow #324483)
                            
               21/10/2015 - Correcao da checagem de existencia do produto Folha
                            para os novos planos de cotas (Marcos-Supero)
                            
               17/11/2015 - Ajuste para utilizar a procedure obtem_saldo_dia
                            do Oracle (Douglas - Chamado 285228)
..............................................................................*/


/*................................ DEFINICOES ................................*/


{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**                  Procedure para obter saldo do capital                   **/
/******************************************************************************/
PROCEDURE obtem-saldo-cotas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-saldo-cotas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-saldo-cotas.
    
    ASSIGN aux_cdcritic = 0
           aux_vlblqjud = 0
           aux_vlresblq = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar dados atuais do capital".
           
    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                       crapcot.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcot  THEN
        DO:
            ASSIGN aux_cdcritic = 169
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.    
    
    /*** Busca Saldo Bloqueado Judicial ***/
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* fixo - nrcpfcgc  */
                                             INPUT 3, /* Bloqueio Capital */
                                             INPUT 4, /* 4 - CAPITAL      */
                                             INPUT crapdat.dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/
    
    CREATE tt-saldo-cotas.
    ASSIGN tt-saldo-cotas.vlsldcap = crapcot.vldcotas
           tt-saldo-cotas.vlblqjud = aux_vlblqjud.


    RETURN "OK".
 
END PROCEDURE.


/******************************************************************************/
/**               Procedure para consultar extrato do capital                **/
/******************************************************************************/
PROCEDURE extrato_cotas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM par_vlsldant AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-extrato_cotas.
    
    DEF VAR aux_vlsldtot AS DECI INIT 0                             NO-UNDO.
    DEF VAR aux_dtprmsld AS DATE INIT ?                             NO-UNDO.
    DEF VAR aux_flgusdir AS LOGI INIT NO                            NO-UNDO.
    
    EMPTY TEMP-TABLE tt-extrato_cotas.

    FOR EACH crapdir WHERE crapdir.cdcooper = par_cdcooper 
                       AND crapdir.nrdconta = par_nrdconta
                       NO-LOCK BY crapdir.dtmvtolt DESCENDING:

        IF crapdir.dtmvtolt <= par_dtiniper OR
           crapdir.dtmvtolt = 12/31/2004 THEN 
           DO:
             ASSIGN aux_dtprmsld = crapdir.dtmvtolt
                    aux_vlsldtot = crapdir.vlttccap
                    aux_flgusdir = YES.
             LEAVE.
           END.
    END.  /* Fim for each crapdir*/

    IF  aux_dtprmsld = ? THEN
        DO:
            FIND FIRST craplct WHERE craplct.cdcooper = par_cdcooper AND
                              craplct.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

            ASSIGN aux_dtprmsld = IF  AVAILABLE craplct  THEN 
                                      craplct.dtmvtolt
                                  ELSE
                                      par_dtmvtolt
                   aux_flgusdir = NO. /* Dia de abertura da conta */
        END.
               
    ASSIGN par_vlsldant = aux_vlsldtot. /* Saldo inicial */

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper
                       AND craplct.nrdconta = par_nrdconta
                       AND craplct.dtmvtolt >= aux_dtprmsld
                       NO-LOCK:
                
        IF aux_flgusdir AND
           craplct.dtmvtolt = aux_dtprmsld THEN 
           NEXT.

        FIND craphis WHERE craphis.cdcooper = craplct.cdcooper 
                       AND craphis.cdhistor = craplct.cdhistor
                       NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE craphis THEN
            NEXT.
            
        IF craphis.inhistor >= 6 AND
           craphis.inhistor <= 8 THEN
           ASSIGN aux_vlsldtot = aux_vlsldtot + craplct.vllanmto.
        ELSE
            IF craphis.inhistor >= 16 AND
               craphis.inhistor <= 19 THEN
                 ASSIGN aux_vlsldtot = aux_vlsldtot - craplct.vllanmto.
        CREATE tt-extrato_cotas.
        ASSIGN tt-extrato_cotas.dtmvtolt = craplct.dtmvtolt
               tt-extrato_cotas.cdagenci = craplct.cdagenci
               tt-extrato_cotas.cdbccxlt = craplct.cdbccxlt
               tt-extrato_cotas.nrdolote = craplct.nrdolote
               tt-extrato_cotas.dshistor = craphis.dshistor
               tt-extrato_cotas.indebcre = craphis.indebcre
               tt-extrato_cotas.nrdocmto = 
                      INT(SUBSTR(STRING(craplct.nrdocmto,
                                "9999999999999999999999999"),17,9))
               tt-extrato_cotas.nrctrpla = craplct.nrctrpla
               tt-extrato_cotas.vllanmto = craplct.vllanmto
               tt-extrato_cotas.vlsldtot = aux_vlsldtot
               tt-extrato_cotas.dsextrat = craphis.dsextrat.
    END. /* Fim for each craplct*/                    
                              
    IF  par_flgerlog THEN
        DO:

            ASSIGN  aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                    aux_dstransa = "Busca Extrato de Capital".

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
    
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure para obter dados do plano de capital atual           **/
/******************************************************************************/
PROCEDURE obtem_dados_capital:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-capital.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-capital.
    
    ASSIGN aux_cdcritic = 0
           aux_vlblqjud = 0
           aux_vlresblq = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar dados atuais do capital".
           
    /** Procura informacoes sobre as cotas **/
    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                       crapcot.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcot  THEN
        DO:
            ASSIGN aux_cdcritic = 169
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                        
            RETURN "NOK".
        END.    

    /** Moeda fixa do sistema **/
    FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper AND
                       crapmfx.dtmvtolt = par_dtmvtolt AND
                       crapmfx.tpmoefix = 2            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapmfx  THEN
        DO:
            ASSIGN aux_cdcritic = 140
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.    

    /*** Busca Saldo Bloqueado Judicial ***/
    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* fixo - nrcpfcgc */
                                             INPUT 3, /* 3 - Blq. Capital */
                                             INPUT 4, /* 4 - CAPITAL     */
                                             INPUT par_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/

    CREATE tt-dados-capital.
    ASSIGN tt-dados-capital.vldcotas = crapcot.vldcotas
           tt-dados-capital.vlcmicot = crapcot.vlcmicot
           tt-dados-capital.qtcotmfx = ROUND(crapcot.vldcotas /                
                                             crapmfx.vlmoefix,4)
           tt-dados-capital.qtprepag = crapcot.qtprpgpl
           tt-dados-capital.vlcaptal = tt-dados-capital.vldcotas
           tt-dados-capital.vlmoefix = crapmfx.vlmoefix
           tt-dados-capital.vlblqjud = aux_vlblqjud.

    /** Dados do plano atual, se existir **/
    FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                             crappla.nrdconta = par_nrdconta AND
                             crappla.tpdplano = 1            AND
                             crappla.cdsitpla = 1
                             USE-INDEX crappla3 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crappla  THEN
        ASSIGN tt-dados-capital.nrctrpla = 0
               tt-dados-capital.vlprepla = 0
               tt-dados-capital.dtinipla = ?
               tt-dados-capital.dspagcap = "".
    ELSE
    DO:
        ASSIGN tt-dados-capital.nrctrpla = crappla.nrctrpla
               tt-dados-capital.vlprepla = crappla.vlprepla
               tt-dados-capital.dtinipla = crappla.dtinipla
               tt-dados-capital.dspagcap = IF  crappla.flgpagto  THEN 
                                               "Folha"
                                           ELSE 
                                               "C/C dia " +
                                               STRING(DAY(crappla.dtdpagto),
                                                          "99").

        FIND FIRST craplpl WHERE craplpl.cdcooper = par_cdcooper     AND
                                 craplpl.nrdconta = par_nrdconta     AND
                                 craplpl.nrctratu = crappla.nrctrpla
                                 NO-LOCK NO-ERROR.

        IF  AVAILABLE craplpl  THEN
            ASSIGN tt-dados-capital.nrdolote = craplpl.nrdolote
                   tt-dados-capital.cdagenci = craplpl.cdagenci
                   tt-dados-capital.cdbccxlt = craplpl.cdbccxlt.
        ELSE           
            ASSIGN tt-dados-capital.nrdolote = 0
                   tt-dados-capital.cdagenci = 0
                   tt-dados-capital.cdbccxlt = 0.
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
/**         Procedure para consultar subscricoes iniciais no capital         **/
/******************************************************************************/
PROCEDURE proc-subscricao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-subscricao.

    DEF VAR tot_vlparcap AS DECI INIT 0                             NO-UNDO.
    
    EMPTY TEMP-TABLE tt-subscricao.
   
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar subscricoes iniciais do capital".
           
    FOR EACH crapsdc WHERE crapsdc.cdcooper = par_cdcooper AND
                           crapsdc.nrdconta = par_nrdconta NO-LOCK:
   
        IF  crapsdc.dtdebito <> ?  AND
            crapsdc.indebito = 1   THEN
            tot_vlparcap = tot_vlparcap + crapsdc.vllanmto.
       
        CREATE tt-subscricao.
        ASSIGN tt-subscricao.dtdebito = IF crapsdc.indebito < 2 THEN
                                           STRING(crapsdc.dtdebito,"99/99/9999")
                                        ELSE 
                                           "CANCELADO"
               tt-subscricao.dtrefere = crapsdc.dtrefere
               tt-subscricao.vllanmto = crapsdc.vllanmto
               tt-subscricao.vlparcap = tot_vlparcap.

    END. /** Fim do FOR EACH crapsdc **/
    
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
/** Procedure para gerar novo plano de capital ou obter dados se ja existir  **/
/** um novo plano cadastrado                                                 **/
/******************************************************************************/
PROCEDURE obtem-novo-plano:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-horario.
    DEF OUTPUT PARAM TABLE FOR tt-novo-plano.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dtdpagto AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimini AS DATE                                    NO-UNDO.
    DEF VAR aux_despagto AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdempres AS INT                                     NO-UNDO.
    DEF VAR flg_tempropo AS LOGICAL                                 NO-UNDO.
    
    EMPTY TEMP-TABLE tt-horario.
    EMPTY TEMP-TABLE tt-novo-plano.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""    
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados para novo plano de capital"
           aux_cdempres = 0.
           
    /** Validar horario para operacao se origem for "Internet" **/
    IF  par_idorigem = 3  THEN /** Internet **/
        DO:
            RUN carrega-horario (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT TRUE, /** Validar Horario **/
                                OUTPUT aux_dscritic,
                                OUTPUT TABLE tt-horario).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    ASSIGN aux_cdcritic = 0.

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    RETURN "NOK".
                END.
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                               
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            RETURN "NOK".
        END.
        
    IF   crapass.inpessoa = 1  THEN
         DO:
             FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = 1
                                NO-LOCK NO-ERROR.

             IF   AVAILABLE crapttl  THEN
                  ASSIGN aux_cdempres = crapttl.cdempres.
                 
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                crapjur.nrdconta = par_nrdconta
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
                  
         END.
        
    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper     AND
                       crapemp.cdempres = aux_cdempres 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapemp  THEN
        DO:
            ASSIGN aux_cdcritic = 40
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                              
            RETURN "NOK".
        END.

    /** Obtem data de inicio do pagamento **/
    IF  (crapemp.flgpagto OR crapemp.flgpgtib)  THEN /*Empresa com debito de cotas em FOLHA*/ 
        DO:
            IF  crapemp.inavscot = 1  AND /*Empresa ja creditou FOLHA*/
               (crapemp.tpdebcot = 2  OR
                crapemp.tpdebcot = 3) THEN
                /* Atribui data de pagamednto para o proximo mes */
                aux_dtdpagto = DATE(IF MONTH(par_dtmvtolt) = 12
                                    THEN 1
                                    ELSE MONTH(par_dtmvtolt) + 1,
                                    10,
                                    IF MONTH(par_dtmvtolt) = 12
                                    THEN YEAR(par_dtmvtolt) + 1
                                    ELSE YEAR(par_dtmvtolt)).
            ELSE
                aux_dtdpagto = DATE(MONTH(par_dtmvtolt),10,
                               YEAR(par_dtmvtolt)).
        END.
    ELSE
        aux_dtdpagto = par_dtmvtolt.

    /* Busca por um plano ativo */
    FIND FIRST crappla WHERE 
               crappla.cdcooper =  par_cdcooper AND 
               crappla.nrdconta =  par_nrdconta AND
               crappla.cdsitpla =  1
               NO-LOCK NO-ERROR.
                                     
    /* Se ja existe Plano ATIVO */ 
    IF  AVAILABLE crappla  THEN
        DO:
            /** Se associado possui um plano, carrega dados do mesmo **/
            CREATE tt-novo-plano.
            ASSIGN tt-novo-plano.vlprepla = crappla.vlprepla
                   tt-novo-plano.cdtipcor = crappla.cdtipcor
                   tt-novo-plano.vlcorfix = crappla.vlcorfix
                   tt-novo-plano.qtpremax = crappla.qtpremax
                   tt-novo-plano.flcancel = TRUE
                   /* Assume mesma data do plano atual */ 
                   tt-novo-plano.dtdpagto = crappla.dtdpagto
                   tt-novo-plano.dtinipla = crappla.dtinipla
                   tt-novo-plano.dtlimini = ?
                   tt-novo-plano.dtultcor = crappla.dtultcor
                   tt-novo-plano.dtprocor = 
                                    ADD-INTERVAL(crappla.dtultcor, 1, "years").
        END.
    ELSE
        DO:
            /** Carrega dados para cadastrar plano **/
            
            /** Calcula data limite para inicio do pagamento **/
            aux_dtlimini = par_dtmvtolt + 50.
            
            IF  DAY(aux_dtlimini) > 28  THEN
                aux_dtlimini = aux_dtlimini - (DAY(aux_dtlimini) - 28).
            
            CREATE tt-novo-plano.
            ASSIGN tt-novo-plano.flcancel = FALSE
                   tt-novo-plano.vlprepla = 0
                   tt-novo-plano.cdtipcor = 1 /* DEFAULD CORREÇÃO INDICE DE INFLACAO*/
                   tt-novo-plano.vlcorfix = 0
                   tt-novo-plano.qtpremax = 999
                   tt-novo-plano.dtdpagto = aux_dtdpagto
                   tt-novo-plano.dtinipla = aux_dtdpagto
                   tt-novo-plano.dtlimini = aux_dtlimini.
        END.
     
    /*************************************************************/
    /** Obtem os tipos de pagamentos que podem ser selecionados **/
    /** Obtem o tipo de pagamento da empresa do cooperado       **/
    /** 2 primeiras strings sao as opcoes permitidas            **/
    /** A 3 string e referente a opcao que devera estar focada  **/
    /*************************************************************/
    IF AVAIL crappla THEN
    DO:
        IF  (NOT crapemp.flgpagto AND NOT crapemp.flgpgtib) OR crapass.dtdemiss <> ?  THEN         
            aux_despagto = ",Conta,Conta".
        ELSE
            aux_despagto = "Conta,Folha," +
                       (IF crappla.flgpagto THEN "Folha" ELSE "Conta").
    END.
    ELSE
    DO:
        IF  (NOT crapemp.flgpagto AND NOT crapemp.flgpgtib) OR crapass.dtdemiss <> ?  THEN         
            aux_despagto = ",Conta,Conta".
        ELSE
            aux_despagto = "Conta,Folha,Conta".
    END.

    ASSIGN tt-novo-plano.despagto = aux_despagto
           tt-novo-plano.dtfuturo = aux_dtdpagto.
            
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
/**         Procedure para validar dados para novo plano de capital          **/
/******************************************************************************/
PROCEDURE valida-dados-plano:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprepla AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlreajus AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpremax AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgderro AS LOGI INIT TRUE                          NO-UNDO.
    DEF VAR aux_cdempres AS INT                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdempres = 0.
    
    DO WHILE TRUE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF NOT AVAILABLE crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            LEAVE.
        END.
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                    
                LEAVE.
            END.
            
        IF   crapass.inpessoa = 1  THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrdconta = par_nrdconta AND
                                    crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
        
                 IF  AVAILABLE crapttl  THEN
                     ASSIGN aux_cdempres = crapttl.cdempres.
                         
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                    crapjur.nrdconta = par_nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
                          
             END.

        FIND crapemp WHERE crapemp.cdcooper = par_cdcooper     AND
                           crapemp.cdempres = aux_cdempres NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapemp  THEN
            DO:
                ASSIGN aux_cdcritic = 40
                       aux_dscritic = "".
                    
                LEAVE.
            END. 
    
        /** Validar horario e valor minimo quando origem for "Internet" **/
        IF  par_idorigem = 3  THEN /** Internet **/  
            DO:
                RUN carrega-horario (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT TRUE,
                                    OUTPUT aux_dscritic,
                                    OUTPUT TABLE tt-horario).
                                    
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0.
                        
                        LEAVE.
                    END.
                    
                FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                         crappla.nrdconta = par_nrdconta AND
                                         crappla.cdsitpla = 1            
                                         NO-LOCK NO-ERROR.
                /* permite somente plano com valor maior do que o atual. */
                IF  AVAILABLE crappla AND par_vlprepla <= crappla.vlprepla  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Para diminuir o valor do débito mensal do plano, entre em contato com o seu posto de atendimento.".

                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                /* criticas copiadas do antigo fonte lancpli.p */

                IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                DO:
                    ASSIGN aux_cdcritic = 695 /* houve prejuizo na conta */
                           aux_dscritic = "".
                    
                    LEAVE.
                END.

                
                IF crapass.cdsitdct = 4 THEN /*  Associado demitido  */
                DO:
                    ASSIGN aux_cdcritic = 75
                           aux_dscritic = "".

                    LEAVE.
                END.
            END.
                
            
        /** Validar valor do plano **/
        IF  par_vlprepla <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 269
                       aux_dscritic = "".

                LEAVE.
            END.

        /** Validar tipo de debito **/
        IF  par_flgpagto AND (NOT crapemp.flgpagto AND NOT crapemp.flgpgtib)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Empresa do cooperado nao integra folha.".
                               
                LEAVE.
            END.
            
        /** Validar quantidade de prestacoes do plano **/
        IF  par_qtpremax <= 0 OR par_qtpremax > 999  THEN
            DO:
                ASSIGN aux_cdcritic = 26
                       aux_dscritic = "".

                LEAVE.
            END.
            
        /** Validar data de inicio do pagamento **/
        IF  NOT par_flgpagto                  AND /* Plano C/C */ 
            par_dtdpagto < par_dtmvtolt       OR
            par_dtdpagto - par_dtmvtolt > 50  OR
            DAY(par_dtdpagto) > 28            THEN
            DO:
                ASSIGN aux_cdcritic = 13
                       aux_dscritic = "".
                
                LEAVE.
            END.

        /* Verifica se valor informado nao esta abaixo do valor minimo para 
           plano de cotas (Tela CADCOP) */
        IF par_vlprepla < crapcop.vlmiplco THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor do plano é inferior ao valor minimo " +
                                  "para plano de cotas.".

            LEAVE.
        END.
        
        /* Valida tipo de correcao de reajuste do valor do plano */
        IF par_cdtipcor = 2 THEN /* correcao por valor fixo */
            IF par_vlreajus = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor de reajuste deve ser informado.".

                LEAVE.
            END.
            
        ASSIGN aux_flgderro = FALSE. /** Se nao houve critica **/
        
        LEAVE.            

    END. /** Fim do DO WHILE TRUE **/

    /** Se houve alguma critica referente aos dados **/
    IF  aux_flgderro  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            /** Se desejado, gera log da critica **/
            IF  par_idorigem = 3 AND par_flgerlog  THEN
                DO:
                    /** Atribui descricao da origem e da transacao **/
                    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,
                                                     des_dorigens,","))
                           aux_dstransa = "Validar dados para novo plano de " +
                                          "capital".
                                          
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
                END.
                            
            RETURN "NOK".
        END.
        
    RETURN "OK".
            
END PROCEDURE.

/******************************************************************************/
/**     Procedure para validar os dados do plano que podem ser alterados     **/
/******************************************************************************/
PROCEDURE valida-dados-alteracao-plano:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprepla AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlreajus AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgderro AS LOGI INIT TRUE                          NO-UNDO.
    DEF VAR aux_cdempres AS INT                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdempres = 0.
    
    DO WHILE TRUE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF NOT AVAILABLE crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            LEAVE.
        END.
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                    
                LEAVE.
            END.
            
        IF   crapass.inpessoa = 1  THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrdconta = par_nrdconta AND
                                    crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
        
                 IF  AVAILABLE crapttl  THEN
                     ASSIGN aux_cdempres = crapttl.cdempres.
                         
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                    crapjur.nrdconta = par_nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
                          
             END.

        FIND crapemp WHERE crapemp.cdcooper = par_cdcooper     AND
                           crapemp.cdempres = aux_cdempres NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapemp  THEN
            DO:
                ASSIGN aux_cdcritic = 40
                       aux_dscritic = "".
                    
                LEAVE.
            END. 
    
        /** Validar horario e valor minimo quando origem for "Internet" **/
        IF  par_idorigem = 3  THEN /** Internet **/  
            DO:
                RUN carrega-horario (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT TRUE,
                                    OUTPUT aux_dscritic,
                                    OUTPUT TABLE tt-horario).
                                    
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0.
                        
                        LEAVE.
                    END.
                    
                FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                         crappla.nrdconta = par_nrdconta AND
                                         crappla.cdsitpla = 1            
                                         NO-LOCK NO-ERROR.
                /* permite somente plano com valor maior do que o atual. */
                IF  AVAILABLE crappla AND par_vlprepla < crappla.vlprepla  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Para diminuir o valor do débito mensal do plano, entre em contato com o seu posto de atendimento.".

                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                /* criticas copiadas do antigo fonte lancpli.p */

                IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                DO:
                    ASSIGN aux_cdcritic = 695 /* houve prejuizo na conta */
                           aux_dscritic = "".
                    
                    LEAVE.
                END.

                
                IF crapass.cdsitdct = 4 THEN /*  Associado demitido  */
                DO:
                    ASSIGN aux_cdcritic = 75
                           aux_dscritic = "".

                    LEAVE.
                END.
            END.
                
            
        /** Validar valor do plano **/
        IF  par_vlprepla <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 269
                       aux_dscritic = "".

                LEAVE.
            END.

        /* Verifica se valor informado nao esta abaixo do valor minimo para 
           plano de cotas (Tela CADCOP) */
        IF par_vlprepla < crapcop.vlmiplco THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor do plano é inferior ao valor minimo " +
                                  "para plano de cotas.".

            LEAVE.
        END.
        
        /* Valida tipo de correcao de reajuste do valor do plano */
        IF par_cdtipcor = 2 THEN /* correcao por valor fixo */
            IF par_vlreajus = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor de reajuste deve ser informado.".

                LEAVE.
            END.
            
        ASSIGN aux_flgderro = FALSE. /** Se nao houve critica **/
        
        LEAVE.            

    END. /** Fim do DO WHILE TRUE **/

    /** Se houve alguma critica referente aos dados **/
    IF  aux_flgderro  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            /** Se desejado, gera log da critica **/
            IF  par_idorigem = 3 AND par_flgerlog  THEN
                DO:
                    /** Atribui descricao da origem e da transacao **/
                    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,
                                                     des_dorigens,","))
                           aux_dstransa = "Validar dados da alteracao do " +
                                          "plano de capital".
                                          
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
                END.
                            
            RETURN "NOK".
        END.
        
    RETURN "OK".
            
END PROCEDURE.
 
/******************************************************************************/
/**              Procedure para cadastrar novo plano de capital              **/
/******************************************************************************/
PROCEDURE cria-plano:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprepla AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlreajus AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpremax AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdempres AS INTE                                    NO-UNDO.
    
    DEF VAR aux_dsinfor1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsprotoc AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_nmarqdbo AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrctrpla AS INTE                                    NO-UNDO.

    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
           aux_dstransa = "Cadastrar novo plano de capital"
           aux_cdempres = 0
           aux_flgtrans = FALSE.
           
    RUN valida-dados-plano (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_dtmvtolt,
                            INPUT par_vlprepla,
                            INPUT par_cdtipcor,
                            INPUT par_vlreajus,
                            INPUT par_flgpagto,
                            INPUT par_qtpremax,
                            INPUT par_dtdpagto,
                            INPUT FALSE,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    TRANSACAO:

    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

        IF   crapass.inpessoa = 1  THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrdconta = par_nrdconta AND
                                    crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
        
                 IF  AVAILABLE crapttl  THEN
                     ASSIGN aux_cdempres = crapttl.cdempres.
                     
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                    crapjur.nrdconta = par_nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
                          
             END.

        RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET 
                                                            h-b1wgen0001.
  
        IF  VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
            RUN ver_capital IN h-b1wgen0001(INPUT  par_cdcooper,
                                            INPUT  par_nrdconta,
                                            INPUT  0, /* cod-agencia */
                                            INPUT  0, /* nro-caixa   */
                                            INPUT  0,        /* vllanmto */
                                            INPUT  par_dtmvtolt,
                                            INPUT  "lancpli",
                                            INPUT  1, /* AYLLOS */
                                           OUTPUT TABLE tt-erro).
            /* Verifica se houve erro */
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-erro   THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic.

            DELETE PROCEDURE h-b1wgen0001.
        END.

        IF   aux_cdcritic = 735 THEN
            ASSIGN aux_cdcritic = 0.                                
  
        IF   aux_cdcritic > 0   THEN
        DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                                                      
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.
        
        DO WHILE TRUE:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 10128        AND
                               craplot.tplotmov = 8
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE craplot THEN
                IF LOCKED craplot THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE
                DO:
                    CREATE craplot.
                    ASSIGN craplot.cdcooper = par_cdcooper
                           craplot.dtmvtolt = par_dtmvtolt
                           craplot.cdagenci = 1
                           craplot.cdbccxlt = 100
                           craplot.nrdolote = 10128
                           craplot.tplotmov = 8.
                END.

            LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */
        
        /* Busca a proxima sequencia do campo crapmat.nrseqcar */
    	RUN STORED-PROCEDURE pc_sequence_progress
    	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
    										,INPUT "NRCTRPLA"
    										,INPUT STRING(par_cdcooper)
    										,INPUT "N"
    										,"").
    	
    	CLOSE STORED-PROC pc_sequence_progress
    	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    			  
    	ASSIGN aux_nrctrpla = INTE(pc_sequence_progress.pr_sequence)
    						  WHEN pc_sequence_progress.pr_sequence <> ?.

        CREATE craplpl.
        ASSIGN craplpl.dtmvtolt = par_dtmvtolt
               craplpl.cdagenci = crapass.cdagenci
               craplpl.cdbccxlt = 100
               craplpl.nrdolote = 10128
               craplpl.nrdconta = par_nrdconta
               craplpl.nrctrant = 0
               craplpl.nrctratu = aux_nrctrpla
               craplpl.nrseqdig = craplot.nrseqdig + 1
               craplpl.cdcooper = par_cdcooper        
               craplpl.tplanmto = 1

               craplot.nrseqdig = craplot.nrseqdig + 1

               craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.vlcompcr = craplot.vlcompcr + par_vlprepla
               craplot.vlinfocr = craplot.vlinfocr + par_vlprepla.

        CREATE crappla.
        ASSIGN crappla.cdcooper = par_cdcooper
               crappla.cdempres = aux_cdempres
               crappla.cdoperad = par_cdoperad
               crappla.cdsitpla = 1
               crappla.dsorigem = aux_dsorigem
               crappla.dtcancel = ?
               crappla.dtdpagto = par_dtdpagto
               crappla.dtinipla = par_dtmvtolt /*data de contratacao do plano*/
               crappla.dtmvtolt = par_dtmvtolt
               crappla.dtultpag = ?
               crappla.flgpagto = par_flgpagto
               crappla.indpagto = 0
               crappla.nrctrpla = aux_nrctrpla
               crappla.nrdconta = par_nrdconta
               crappla.qtpremax = par_qtpremax
               crappla.qtpremin = 0
               crappla.qtprepag = 0
               crappla.tpdplano = 1
               crappla.vlpagmes = 0
               crappla.vlprepag = 0
               crappla.vlprepla = par_vlprepla
               crappla.cdtipcor = par_cdtipcor
               crappla.vlcorfix = par_vlreajus
               crappla.dtultcor = par_dtmvtolt WHEN par_cdtipcor <> 0.
    
        RELEASE craplot.
        RELEASE craplpl.
        RELEASE crappla.
    
        IF  par_idorigem = 3  THEN /** Internet **/
            DO:
                ASSIGN aux_nmarqdbo = "sistema/generico/procedures/" +
                                      "bo_algoritmo_seguranca.p".
                                      
                RUN VALUE(aux_nmarqdbo) PERSISTENT SET h-bo_algoritmo_seguranca.
                
                IF  VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
                    DO:
                        RUN dados_protocolo (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_idorigem,
                                             INPUT par_flgpagto,
                                            OUTPUT aux_dsinfor1,
                                            OUTPUT aux_dsinfor2,
                                            OUTPUT aux_dsinfor3,
                                            OUTPUT aux_cdcritic,
                                            OUTPUT aux_dscritic).
                        
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1, /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                                      
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                        RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                                          (INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT TIME,
                                           INPUT par_nrdconta,
                                           INPUT crappla.nrctrpla,
                                           INPUT 0,     /** Autenticacao   **/
                                           INPUT crappla.vlprepla,
                                           INPUT par_nrdcaixa,
                                           INPUT YES,   /** Gravar crappro **/
                                           INPUT 3,     /** Capital        **/
                                           INPUT aux_dsinfor1,
                                           INPUT aux_dsinfor2,
                                           INPUT aux_dsinfor3,
                                           INPUT "",    /** Cedente     **/
                                           INPUT FALSE, /** Agendamento **/
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT "",
                                          OUTPUT aux_dsprotoc,
                                          OUTPUT aux_dscritic). 
                                            
                        DELETE PROCEDURE h-bo_algoritmo_seguranca.

                        IF   RETURN-VALUE <> "OK"   THEN
                             UNDO TRANSACAO, LEAVE TRANSACAO.

                    END.
            END.

        FIND CURRENT crappla NO-LOCK NO-ERROR.
        
        ASSIGN aux_flgtrans = TRUE.
            
    END. /** Fim do DO TRANSACTION **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel criar o plano.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
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
                       
    /** Gerar log de itens do novo plano **/
    RUN log_itens_plano (INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT par_vlprepla,
                         INPUT par_cdtipcor,
                         INPUT par_vlreajus,
                         INPUT par_flgpagto,
                         INPUT par_qtpremax,
                         INPUT par_dtdpagto,
                         INPUT TRUE).                       

    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**               Procedure para alterar o plano cadastrado                  **/
/******************************************************************************/
PROCEDURE altera-plano:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprepla AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlreajus AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpremax AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dsinfor1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsprotoc AS CHAR                                    NO-UNDO.

    DEF  VAR log_vlprepla AS DECI                                   NO-UNDO.
    DEF  VAR log_cdtipcor AS INTE                                   NO-UNDO.
    DEF  VAR log_vlreajus AS DECI                                   NO-UNDO.
    DEF  VAR log_flgpagto AS LOGI                                   NO-UNDO.
    DEF  VAR log_qtpremax AS INTE                                   NO-UNDO.
    DEF  VAR log_dtdpagto AS DATE                                   NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_nmarqdbo AS CHAR                                    NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar plano de capital"
           aux_flgtrans = FALSE.
           
    RUN valida-dados-alteracao-plano (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_vlprepla,
                                      INPUT par_cdtipcor,
                                      INPUT par_vlreajus,
                                      INPUT FALSE,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    TRANSACAO:
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

        DO WHILE TRUE:

            FIND crappla WHERE crappla.cdcooper = par_cdcooper AND
                               crappla.nrdconta = par_nrdconta AND
                               crappla.cdsitpla = 1 /* ativo */
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAIL crappla THEN
            DO:
                IF LOCKED crappla THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE
                    UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

            ASSIGN log_vlprepla = crappla.vlprepla
                   log_cdtipcor = crappla.cdtipcor
                   log_vlreajus = crappla.vlcorfix
                   log_flgpagto = crappla.flgpagto
                   log_qtpremax = crappla.qtpremax
                   log_dtdpagto = crappla.dtdpagto.

            LEAVE.
        END.

        IF crappla.vlprepla = par_vlprepla AND
           crappla.cdtipcor = par_cdtipcor AND
           crappla.vlcorfix = par_vlreajus THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O plano de capital nao foi alterado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                                  
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.

        IF par_cdtipcor = 0 THEN
            ASSIGN crappla.dtultcor = ?.
        ELSE            
        IF (crappla.cdtipcor <> par_cdtipcor) OR 
           (crappla.vlcorfix <> par_vlreajus) THEN
            ASSIGN crappla.dtultcor = par_dtmvtolt.

        ASSIGN crappla.vlprepla = par_vlprepla
               crappla.cdtipcor = par_cdtipcor
               crappla.vlcorfix = IF par_cdtipcor = 2 THEN
                                      par_vlreajus
                                  ELSE
                                      0.

        IF  par_idorigem = 3  THEN /** Internet **/
        DO:
            ASSIGN aux_nmarqdbo = "sistema/generico/procedures/" +
                                  "bo_algoritmo_seguranca.p".
                                  
            RUN VALUE(aux_nmarqdbo) PERSISTENT SET h-bo_algoritmo_seguranca.
            
            IF  VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
            DO:
                RUN dados_protocolo (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT par_idorigem,
                                     INPUT par_flgpagto,
                                    OUTPUT aux_dsinfor1,
                                    OUTPUT aux_dsinfor2,
                                    OUTPUT aux_dsinfor3,
                                    OUTPUT aux_cdcritic,
                                    OUTPUT aux_dscritic).
                    
                IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1, /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                                  
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                        
                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                                  (INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT TIME,
                                   INPUT par_nrdconta,
                                   INPUT crappla.nrctrpla,
                                   INPUT 0,     /** Autenticacao   **/
                                   INPUT crappla.vlprepla,
                                   INPUT par_nrdcaixa,
                                   INPUT YES,   /** Gravar crappro **/
                                   INPUT 3,     /** Capital        **/
                                   INPUT aux_dsinfor1,
                                   INPUT aux_dsinfor2,
                                   INPUT aux_dsinfor3,
                                   INPUT "",    /** Cedente     **/
                                   INPUT FALSE, /** Agendamento **/
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT "",
                                  OUTPUT aux_dsprotoc,
                                  OUTPUT aux_dscritic). 
                                        
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.

            END.
        END.

        ASSIGN aux_flgtrans = TRUE.

    END. /* fim do DO TRANSACTION */

    /** Verifica se transacao foi executada com sucesso **/
    IF NOT aux_flgtrans THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAIL tt-erro THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro na transacao. Nao foi " + 
                                  "possivel alterar o plano.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
                   
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
                       
    /** Gerar log de itens do novo plano **/
    RUN log_itens_plano (INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT log_vlprepla,
                         INPUT log_cdtipcor,
                         INPUT log_vlreajus,
                         INPUT log_flgpagto,
                         INPUT log_qtpremax,
                         INPUT log_dtdpagto,
                         INPUT FALSE).                       

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**              Procedure para cancelar plano de capital atual              **/
/******************************************************************************/
PROCEDURE cancelar-plano-atual:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cancelamento.
    
    DEF VAR aux_nrdocnpj AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdebito AS CHAR                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_nrctrpla AS INTE                                    NO-UNDO.
    DEF VAR aux_vlprepla AS DECI                                    NO-UNDO.
    DEF VAR aux_dtinipla AS DATE                                    NO-UNDO.
    DEF VAR aux_flgpagto AS LOGI                                    NO-UNDO.
   
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cancelamento.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_contador = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar plano de capital atual".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                                      
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                                      
            RETURN "NOK".
        END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:
           
        FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                 crappla.nrdconta = par_nrdconta AND
                                 crappla.cdsitpla = 1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF NOT AVAILABLE crappla  THEN
        DO:
            IF LOCKED crappla THEN
            DO:
                IF aux_contador < 10 THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    ASSIGN aux_contador = aux_contador + 1.
                    NEXT.
                END.
                ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Tabela CRAPPLA esta em uso.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                                          
                    RETURN "NOK".
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_cdcritic = 200
                       aux_dscritic = "".
                       
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                          
                RETURN "NOK".
            END.
        END.

        ASSIGN aux_nrctrpla = crappla.nrctrpla
               aux_vlprepla = crappla.vlprepla
               aux_dtinipla = crappla.dtinipla
               aux_flgpagto = crappla.flgpagto.

        /* cancela o plano de cotas */
        ASSIGN crappla.cdsitpla = 2
               crappla.dtcancel = crapdat.dtmvtolt.

        /* Exclui registro de lancamento de plano de capital para nao ter
           problema com a chave da tabela, no caso de uma nova inclusao
           no mesmo dia */
        FIND FIRST craplpl WHERE craplpl.cdcooper = par_cdcooper     AND 
                                 craplpl.dtmvtolt = crapdat.dtmvtolt AND
                                 craplpl.nrdconta = par_nrdconta     AND
                                 craplpl.cdbccxlt = 100              AND
                                 craplpl.nrdolote = 10128            AND
                                 craplpl.nrctratu = crappla.nrctrpla
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                        
        IF NOT AVAILABLE craplpl THEN
        DO:
            IF LOCKED craplpl THEN
            DO:
                ASSIGN aux_dscritic = "Registro de lancamentos de plano " +
                                      "de capital esta sendo alterado. "  +
                                      "Tente Novamente.".
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Registro de lancamentos de plano " +
                                      "de capital nao encontrado.".
                LEAVE.
            END.
        END.

        DELETE craplpl.

        LEAVE.
    END.


    ASSIGN aux_nrdocnpj = "CNPJ " +
                          STRING(STRING(crapcop.nrdocnpj,"99999999999999"),
                                 "xx.xxx.xxx/xxxx-xx")
           aux_dsdebito = IF  aux_flgpagto  THEN
                              "folha"
                          ELSE
                              "conta-corrente".

    CREATE tt-cancelamento.
    ASSIGN tt-cancelamento.nmextcop = crapcop.nmextcop
           tt-cancelamento.nrdocnpj = aux_nrdocnpj
           tt-cancelamento.nrcancel = aux_nrctrpla
           tt-cancelamento.vlcancel = aux_vlprepla
           tt-cancelamento.nmprimtl = crapass.nmprimtl
           tt-cancelamento.dsdebito = aux_dsdebito
           tt-cancelamento.nrctrpla = aux_nrctrpla
           tt-cancelamento.dtinipla = aux_dtinipla
           tt-cancelamento.nmcidade = crapcop.nmcidade
           tt-cancelamento.cdufdcop = crapcop.cdufdcop
           tt-cancelamento.nmrescop = crapcop.nmrescop.
           
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
/**        Procedure para emitir autorizacao do novo plano de capital        **/
/******************************************************************************/
PROCEDURE autorizar-novo-plano:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-autorizacao.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-autorizacao.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Termo para autorizar novo plano de capital".
           
    RUN dados_autorizacao (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_idorigem,
                          OUTPUT aux_cdcritic,
                          OUTPUT aux_dscritic).
                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                                      
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
/**        Procedure para imprimir protocolo do novo plano de capital        **/
/******************************************************************************/
PROCEDURE imprimir_protocolo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-protocolo.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-protocolo.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""    
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Carregar protocolo do novo plano de capital".
     
    FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND 
                             crappla.nrdconta = par_nrdconta AND
                             crappla.cdsitpla = 1
                             NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crappla  THEN
        DO:
            ASSIGN aux_cdcritic = 200
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                                      
            RETURN "NOK".
        END.

    FIND LAST crappro WHERE crappro.cdcooper = par_cdcooper     AND
                            crappro.nrdconta = par_nrdconta     AND
                            crappro.cdtippro = 3                AND
                            crappro.nrdocmto = crappla.nrctrpla 
                            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crappro  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Protocolo nao encontrado.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                                      
            RETURN "NOK".
        END.

    CREATE tt-protocolo.
    ASSIGN tt-protocolo.cdtippro    = crappro.cdtippro
           tt-protocolo.dtmvtolt    = crappro.dtmvtolt
           tt-protocolo.dttransa    = crappro.dttransa
           tt-protocolo.hrautent    = crappro.hrautent
           tt-protocolo.vldocmto    = crappro.vldocmto
           tt-protocolo.nrdocmto    = crappro.nrdocmto
           tt-protocolo.dsinform[1] = crappro.dsinform[1]
           tt-protocolo.dsinform[2] = crappro.dsinform[2]
           tt-protocolo.dsinform[3] = crappro.dsinform[3]
           tt-protocolo.dsprotoc    = crappro.dsprotoc.

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


/*............................ PROCEDURES INTERNAS ...........................*/


/******************************************************************************/
/**        Procedure para montar dados que serao gravados no protocolo       **/
/******************************************************************************/
PROCEDURE dados_protocolo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dsinfor1 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsinfor2 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsinfor3 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_dsreajus AS CHAR                NO-UNDO.
    DEF VAR aux_vlcorfix AS CHAR FORMAT "x(10)" NO-UNDO.
    
    RUN dados_autorizacao (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_idorigem,
                          OUTPUT par_cdcritic,
                          OUTPUT par_dscritic).
                           
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    IF tt-autorizacao.cdtipcor = 0 THEN
        ASSIGN aux_dsreajus = "(   ) Correcao monetaria pela variacao do IPCA"     +
                              " (Indice Nacional de Precos ao Consumidor Amplo);#" + 
                              "(   ) Valor fixo;#" +
                              "( X ) Sem reajuste automatico de valor.".
    ELSE
    IF tt-autorizacao.cdtipcor = 1 THEN
        ASSIGN aux_dsreajus = "( X ) Correcao monetaria pela variacao do IPCA"     +
                              " (Indice Nacional de Precos ao Consumidor Amplo);#" + 
                              "(   ) Valor fixo;#" +
                              "(   ) Sem reajuste automatico de valor.".
    ELSE
    DO:
        IF INDEX(STRING(tt-autorizacao.vlcorfix), ",") > 0 THEN
            ASSIGN aux_vlcorfix = STRING(tt-autorizacao.vlcorfix).
        ELSE
            ASSIGN aux_vlcorfix = STRING(tt-autorizacao.vlcorfix) + ",00".

        ASSIGN aux_dsreajus = "(   ) Correcao monetaria pela variacao do IPCA"     +
                              " (Indice Nacional de Precos ao Consumidor Amplo);#" + 
                              "( X ) Valor fixo de R$ " + aux_vlcorfix + ";#"      +
                              "(   ) Sem reajuste automatico de valor.".
    END.
    
    ASSIGN par_dsinfor1 = "Capital"
           par_dsinfor2 = tt-autorizacao.nmprimtl + "#" +
                          tt-autorizacao.diadebit

           par_dsinfor3 = "O associado acima qualificado autoriza a realizacao " +
                          "do debito mensal em sua conta corrente de deposito a vista," +
                          "no valor de R$ " + 
                          TRIM(STRING(tt-autorizacao.vlprepla,
                                      "zzz,zzz,zz9.99")) + " (" +
                          TRIM(ENTRY(1,tt-autorizacao.dsprepla[1],"*")) +
                          ") a partir do mes de " + trim(tt-autorizacao.dsmesano) +
                          ", para integralizacao de Cotas de CAPITAL.#" +

                          "Este valor sera reajustado apos o periodo de 12(doze) " +
                          "meses, com base em:#" + aux_dsreajus + "#" .
                          
    IF  par_flgpagto  THEN 
        ASSIGN par_dsinfor3 = par_dsinfor3 + "O debito se dara sempre na data" +
                              " em que ocorrer o credito do salario, " +
                              "limitado ao saldo liquido do mesmo.".
    ELSE
        ASSIGN par_dsinfor3 = par_dsinfor3 + "O debito sera efetuado desde que " +
                              "haja provisao de fundos na conta corrente. Caso " +
                              "a data estabelecida para debito cair no sabado, " +
                              "domingo ou feriado, o lancamento sera efetuado no " +
                              "primeiro dia util subsequente.".

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**            Procedure para montar dados do termo de autorizacao           **/
/******************************************************************************/
PROCEDURE dados_autorizacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_dsmesano AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdocnpj AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdprazo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsprepla AS CHAR EXTENT 2                           NO-UNDO.
    DEF VAR aux_nmrescop AS CHAR EXTENT 2                           NO-UNDO.

    ASSIGN par_cdcritic = 0
           par_dscritic = "".
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_cdcritic = 651
                   par_dscritic = "".

            RETURN "NOK".
        END.
        
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN par_cdcritic = 9
                   par_dscritic = "".
                   
            RETURN "NOK".
        END.
        
    FIND FIRST crappla WHERE 
               crappla.cdcooper =  par_cdcooper AND 
               crappla.nrdconta =  par_nrdconta AND
               crappla.cdsitpla =  1
               NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crappla  THEN
        DO:
            ASSIGN par_cdcritic = 200
                   par_dscritic = "".
                   
            RETURN "NOK".
        END.

    ASSIGN aux_dsmesref = "janeiro,fevereiro,marco,abril,maio,junho,julho," +
                          "agosto,setembro,outubro,novembro,dezembro"
           aux_dsmesano = ENTRY(MONTH(crappla.dtdpagto),aux_dsmesref)
           aux_nrdocnpj = "CNPJ " + STRING(STRING(crapcop.nrdocnpj,
                                    "99999999999999"),"xx.xxx.xxx/xxxx-xx")
           aux_dsdprazo = IF  crappla.qtpremax = 999  THEN
                              "indeterminado"
                          ELSE 
                              "de " + TRIM(STRING(crappla.qtpremax,"zz9")) + 
                              " meses".

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN par_cdcritic = 0
                   par_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RETURN "NOK".
        END.
        
    RUN valor-extenso IN h-b1wgen9999 (INPUT crappla.vlprepla, 
                                       INPUT 78, 
                                       INPUT 78,
                                       INPUT "M",
                                      OUTPUT aux_dsprepla[1], 
                                      OUTPUT aux_dsprepla[2]).
          
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
            
            ASSIGN par_cdcritic = 0
                   par_dscritic = aux_dsprepla[1].
                   
            RETURN "NOK".       
        END.
        
    RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                         OUTPUT aux_nmrescop[1],
                                         OUTPUT aux_nmrescop[2]).
        
    DELETE PROCEDURE h-b1wgen9999.
    
    CREATE tt-autorizacao.
    ASSIGN tt-autorizacao.nmextcop    = crapcop.nmextcop
           tt-autorizacao.nmrescop[1] = aux_nmrescop[1]
           tt-autorizacao.nmrescop[2] = aux_nmrescop[2]
           tt-autorizacao.nrdocnpj    = aux_nrdocnpj 
           tt-autorizacao.nrctrpla    = crappla.nrctrpla
           tt-autorizacao.vlprepla    = crappla.vlprepla
           tt-autorizacao.dsprepla[1] = aux_dsprepla[1]
           tt-autorizacao.dsprepla[2] = aux_dsprepla[2]
           tt-autorizacao.nmprimtl    = crapass.nmprimtl
           tt-autorizacao.flgpagto    = crappla.flgpagto
           tt-autorizacao.diadebit    = STRING(DAY(crappla.dtdpagto),"99")
           tt-autorizacao.dsdprazo    = aux_dsdprazo 
           tt-autorizacao.dsmesano    = aux_dsmesano
           tt-autorizacao.nranoini    = STRING(YEAR(crappla.dtdpagto),"9999")
           tt-autorizacao.nmcidade    = crapcop.nmcidade
           tt-autorizacao.cdufdcop    = crapcop.cdufdcop
           tt-autorizacao.cdtipcor    = crappla.cdtipcor
           tt-autorizacao.vlcorfix    = crappla.vlcorfix.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**      Procedure para carregar horario permitido para gerar novo plano     **/
/******************************************************************************/
PROCEDURE carrega-horario:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgvalid AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-horario.   
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_hrinipla AS INTE                                    NO-UNDO.
    DEF VAR aux_hrfimpla AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-horario.
    
    ASSIGN par_dscritic = "".
    
    DO aux_contador = 1 TO 10:

        FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                           craptab.nmsistem = "CRED"        AND
                           craptab.tptabela = "GENERI"      AND
                           craptab.cdempres = 00            AND
                           craptab.cdacesso = "HRPLANCAPI"  AND
                           craptab.tpregist = par_cdagenci
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craptab  THEN
            DO:
                IF  LOCKED craptab  THEN
                    DO:
                        par_dscritic = "Registro de horario permitido sendo " +
                                       "alterado. Tente Novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        par_dscritic = "Registro de horario permitido nao " +
                                       "encontrado.".
                        LEAVE.
                    END.    
            END.
            
        par_dscritic = "".
 
        LEAVE.

    END. /** Fim do DO .. TO **/

    IF  par_dscritic <> ""  THEN
        RETURN "NOK".

    ASSIGN aux_hrinipla = INT(SUBSTRING(craptab.dstextab,9,5))
           aux_hrfimpla = INT(SUBSTRING(craptab.dstextab,3,5)).

    CREATE tt-horario.
    ASSIGN tt-horario.hrinipla = STRING(aux_hrinipla,"HH:MM")
           tt-horario.hrfimpla = STRING(aux_hrfimpla,"HH:MM").
                    
    /** Validar o horario de disponibilidade em relacao a hora atual **/
    IF  par_flgvalid AND (TIME < aux_hrinipla OR TIME > aux_hrfimpla)  THEN
        DO:
            par_dscritic = "Horario esgotado para cadastrar Plano de Capital.".
            RETURN "NOK".
        END.    
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**             Procedure para gerar log de itens do novo plano              **/
/******************************************************************************/
PROCEDURE log_itens_plano:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprepla AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlreajus AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpremax AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flinclus AS LOGI                           NO-UNDO.
    
    IF  par_flinclus THEN
        DO:
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Valor plano",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_vlprepla,
                                                       "zzz,zzz,zz9.99"))).
    
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Debitar em",
                                     INPUT "",
                                     INPUT STRING(par_flgpagto,"Folha/Conta")).
    
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Qtd Prestacoes",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_qtpremax,"999"))).
    
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Data inicio",
                                     INPUT "",
                                     INPUT STRING(par_dtdpagto,"99/99/9999")).
        END.
    ELSE
        DO:
            FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                     crappla.nrdconta = par_nrdconta AND
                                     crappla.cdsitpla = 1            NO-LOCK NO-ERROR.
                                     
            IF  AVAILABLE crappla  THEN 
                DO:
                    IF  crappla.vlprepla <> par_vlprepla  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Valor plano",
                                                 INPUT TRIM(STRING(par_vlprepla,
                                                                   "zzz,zzz,zz9.99")),
                                                 INPUT TRIM(STRING(crappla.vlprepla,
                                                                   "zzz,zzz,zz9.99"))).
                    
                    IF  crappla.flgpagto <> par_flgpagto  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Debitar em",
                                                 INPUT STRING(par_flgpagto,
                                                              "Folha/Conta"),
                                                 INPUT STRING(crappla.flgpagto,
                                                              "Folha/Conta")).
                                                                                    
                    IF  crappla.qtpremax <> par_qtpremax  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Qtd Prestacoes",
                                                 INPUT TRIM(STRING(par_qtpremax,
                                                                   "999")),
                                                 INPUT TRIM(STRING(crappla.qtpremax,
                                                                   "999"))).
                                                                                    
                    IF  crappla.dtdpagto <> par_dtdpagto  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Data inicio",
                                                 INPUT STRING(par_dtdpagto,
                                                              "99/99/9999"),
                                                 INPUT STRING(crappla.dtdpagto,
                                                              "99/99/9999")).
        
                    IF crappla.cdtipcor <> par_cdtipcor THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Tipo correcao",
                                                 INPUT TRIM(STRING(par_cdtipcor,"9")),
                                                 INPUT TRIM(STRING(crappla.cdtipcor,"9"))).        

                    IF crappla.vlcorfix <> par_vlreajus THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Vlr correcao fixa",
                                                 INPUT TRIM(STRING(par_vlreajus,
                                                                   "zz,zz9.99")),
                                                 INPUT TRIM(STRING(crappla.vlcorfix,
                                                                   "zz,zz9.99"))).
                END.
        END.
                    
    RETURN "OK".

END PROCEDURE.

PROCEDURE integraliza_cotas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vintegra AS DECI                           NO-UNDO.

    DEF  INPUT-OUTPUT PARAM par_flgsaldo AS LOGI                    NO-UNDO.
    DEF  OUTPUT       PARAM TABLE FOR tt-erro.

    DEF  VARIABLE    aux_vlsddisp AS DECI                           NO-UNDO.

    DEF VARIABLE aux_cdcritic LIKE crapcri.cdcritic                 NO-UNDO.
    DEF VARIABLE aux_dscritic LIKE crapcri.dscritic                 NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Integralizacao de capital".
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                                                      
        RETURN "NOK".
    END.
        
    IF NOT par_flgsaldo THEN
    DO:

        TRANS_SALDO:
        DO TRANSACTION ON ERROR UNDO, LEAVE:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
            /* Utilizar o tipo de busca A, para carregar do dia anterior
              (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
            RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT 0, /* nrdcaixa */
                                         INPUT par_cdoperad, 
                                         INPUT par_nrdconta,
                                         INPUT par_dtmvtolt,
                                         INPUT "A", /* Tipo Busca */
                                         OUTPUT 0,
                                         OUTPUT "").
            
            CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                                      WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
                   aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                                      WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
    
            IF aux_cdcritic <> 0  OR 
               aux_dscritic <> "" THEN
               DO: 
                   IF  aux_dscritic = "" THEN
                       ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".
                    
                   CREATE tt-erro.
                   ASSIGN tt-erro.cdcritic = aux_cdcritic
                          tt-erro.dscritic = aux_dscritic.
                   
                   RETURN "NOK".
               END.
        
            FIND FIRST wt_saldos NO-LOCK NO-ERROR.
            IF AVAIL wt_saldos THEN
            DO:
                ASSIGN aux_vlsddisp = wt_saldos.vlsddisp + wt_saldos.vlsdchsl + 
                                      wt_saldos.vlsdbloq + wt_saldos.vlsdblpr + 
                                      wt_saldos.vlsdblfp + wt_saldos.vllimcre.
            END.
        END. 

        IF aux_vlsddisp < par_vintegra THEN
        DO:
            ASSIGN par_flgsaldo = TRUE.
    
            RETURN "OK".
        END.
    END.

    ASSIGN par_flgsaldo = FALSE.

    TRANS_INTEGRA:
    DO TRANSACTION ON ERROR UNDO, LEAVE:

        DO aux_contador = 1 TO 10:
                                                                        
           /* Lote de lancamento craplct */ 
           FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                              craplot.dtmvtolt = par_dtmvtolt AND
                              craplot.cdagenci = 1            AND
                              craplot.cdbccxlt = 100          AND
                              craplot.nrdolote = 10002        EXCLUSIVE-LOCK
                              NO-ERROR NO-WAIT.
    
           IF   NOT AVAIL  craplot   THEN
                IF  LOCKED craplot   THEN
                    DO:
                       PAUSE 1 NO-MESSAGE.
                       ASSIGN aux_cdcritic = 77. 
                       NEXT.
                    END.
                ELSE
                    DO:
                       CREATE craplot.
                       ASSIGN craplot.cdcooper = par_cdcooper
                              craplot.dtmvtolt = par_dtmvtolt
                              craplot.cdagenci = 1
                              craplot.cdbccxlt = 100
                              craplot.nrdolote = 10002  
                              craplot.tplotmov = 2.
                    END.
    
                    ASSIGN aux_cdcritic = 0.
           LEAVE.
        END.  /*  Fim do DO...TO  */
    
        IF aux_cdcritic > 0 THEN
        DO:
            ASSIGN aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNDO TRANS_INTEGRA, LEAVE.
                                                          
        END.
    
        FIND craplct WHERE craplct.cdcooper = par_cdcooper         AND
                           craplct.dtmvtolt = par_dtmvtolt         AND
                           craplct.cdagenci = 1                    AND
                           craplct.cdbccxlt = 100                  AND
                           craplct.nrdolote = craplot.nrdolote     AND
                           craplct.nrseqdig = craplot.nrseqdig + 1
                           NO-LOCK NO-ERROR.
                           
        IF AVAILABLE craplct   THEN
        DO:
            ASSIGN aux_cdcritic = 92
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNDO TRANS_INTEGRA, LEAVE.
                 
        END.
        
        CREATE craplct.
        ASSIGN craplct.cdcooper = par_cdcooper
               craplct.dtmvtolt = par_dtmvtolt
               craplct.cdagenci = 1
               craplct.cdbccxlt = 100
               craplct.nrdolote = 10002
               craplct.nrdconta = par_nrdconta
               craplct.nrdocmto = craplot.nrseqdig + 1
               craplct.cdhistor = 61
               craplct.nrseqdig = craplot.nrseqdig + 1
               craplct.vllanmto = par_vintegra.
    
        ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.vlcompcr = craplot.vlcompcr + par_vintegra
               craplot.vlinfocr = craplot.vlinfocr + par_vintegra.
       VALIDATE craplot.
    
        /* cria craplcm */
        DO aux_contador = 1 TO 10:
                                                                        
           FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                              craplot.dtmvtolt = par_dtmvtolt AND
                              craplot.cdagenci = 1            AND
                              craplot.cdbccxlt = 100          AND
                              craplot.nrdolote = 10129        EXCLUSIVE-LOCK
                              NO-ERROR NO-WAIT.
    
           IF   NOT AVAIL  craplot   THEN
                IF  LOCKED craplot   THEN
                    DO:
                       PAUSE 1 NO-MESSAGE.
                       ASSIGN aux_cdcritic = 77. 
                       NEXT.
                    END.
                ELSE
                    DO:
                       CREATE craplot.
                       ASSIGN craplot.cdcooper = par_cdcooper
                              craplot.dtmvtolt = par_dtmvtolt
                              craplot.cdagenci = 1
                              craplot.cdbccxlt = 100
                              craplot.nrdolote = 10129
                              craplot.tplotmov = 1.
                    END.
    
                    ASSIGN aux_cdcritic = 0.
           LEAVE.
        END.  /*  Fim do DO...TO  */
    
        IF aux_cdcritic > 0 THEN
        DO:
            ASSIGN aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNDO TRANS_INTEGRA, LEAVE.
                                                          
        END.
    
        CREATE craplcm.
        ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtcompln
               craplot.vlcompdb = craplot.vlcompdb + par_vintegra
               craplot.vlinfodb = craplot.vlcompdb
            
               craplcm.cdagenci = craplot.cdagenci
               craplcm.cdbccxlt = craplot.cdbccxlt
               craplcm.cdhistor = 127
               craplcm.dtmvtolt = par_dtmvtolt
               craplcm.cdpesqbb = ""
               craplcm.nrdconta = par_nrdconta
               craplcm.nrdctabb = par_nrdconta
               craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
               craplcm.nrdocmto = craplot.nrseqdig
               craplcm.nrdolote = craplot.nrdolote
               craplcm.nrseqdig = craplot.nrseqdig
               craplcm.vllanmto = par_vintegra
               craplcm.cdcooper = par_cdcooper.
    
    
        DO aux_contador = 1 TO 10 :
                         
            FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                               crapcot.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
           IF   NOT AVAILABLE crapcot   THEN
                IF   LOCKED crapcot   THEN
                     DO:
                         ASSIGN aux_cdcritic = 77.   
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                 ELSE
                 DO:
                    ASSIGN aux_cdcritic = 55.
                    LEAVE.
                 END.
           ELSE
               ASSIGN aux_cdcritic = 0.
    
           LEAVE.
           
        END.  /*  Fim do DO WHILE TRUE   */
    
        IF   aux_cdcritic > 0   THEN
        DO:
            ASSIGN aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNDO TRANS_INTEGRA, LEAVE.
                                                          
        END.
    
        ASSIGN crapcot.vldcotas = crapcot.vldcotas + par_vintegra.
    
    
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT 1,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

        RELEASE craplot.
        RELEASE craplct.
        RELEASE craplcm.
        RELEASE crapcot.

        RETURN "OK".    
    END.

    RETURN "NOK".

END PROCEDURE.

PROCEDURE busca_integralizacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER b-craplct FOR craplct.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-lancamentos.

    /* Busca estornos do dia */
    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.nrdconta = par_nrdconta AND
                           craplct.dtmvtolt = par_dtmvtolt AND
                           craplct.nrdolote = 10002        AND
                           craplct.cdbccxlt = 100          AND
                           craplct.cdhistor = 402  /* ESTORNO INTEGRALIZACAO */
                           NO-LOCK:

        CREATE tt-estornos.
        ASSIGN tt-estornos.vllanmto = craplct.vllanmto.

    END.

    /* Busca integralizacoes do dia */ 
    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.nrdconta = par_nrdconta AND
                           craplct.dtmvtolt = par_dtmvtolt AND
                           craplct.nrdolote = 10002        AND
                           craplct.cdbccxlt = 100          AND
                           craplct.cdhistor = 61   /* CR.COTAS */ 
                           NO-LOCK:
        /* Verifica se existe um lancamento de estorno com o mesmo valor
           do credito */
        FIND FIRST tt-estornos WHERE tt-estornos.vllanmto = craplct.vllanmto
                                                    EXCLUSIVE-LOCK NO-ERROR.
        /* Se existe, deleta o registro da temp-table e busca o proximo
           registro, pois podem haver mais lançamentos de estorno com o mesmo
           valor */
        IF AVAIL tt-estornos THEN
        DO:
            DELETE tt-estornos.
            NEXT.
        END.
        
        CREATE tt-lancamentos.
        ASSIGN tt-lancamentos.nrdocmto = craplct.nrdocmto
               tt-lancamentos.vllanmto = craplct.vllanmto.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE estorna_integralizacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-lancamentos.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE h-b1wgen0140     AS HANDLE                         NO-UNDO.
    DEF VARIABLE aux_slcotnor     AS DECIMAL                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Estorno de integralizacao de capital".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                                                      
        RETURN "NOK".
    END.

    TRANS_ESTORNA:
    DO TRANSACTION ON ERROR UNDO, LEAVE:

        FOR EACH tt-lancamentos NO-LOCK:
    
            FIND craplct WHERE craplct.cdcooper = par_cdcooper AND
                               craplct.dtmvtolt = par_dtmvtolt AND
                               craplct.cdagenci = 1            AND
                               craplct.cdbccxlt = 100          AND
                               craplct.nrdolote = 10002        AND
                               craplct.nrdconta = par_nrdconta AND
                               craplct.nrdocmto = tt-lancamentos.nrdocmto AND
                               craplct.cdhistor = 402
                               NO-LOCK NO-ERROR.
                               
            IF AVAILABLE craplct   THEN
            DO:
                ASSIGN aux_cdcritic = 92
                       aux_dscritic = "".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_ESTORNA, LEAVE.
                     
            END.
                                        
            RUN sistema/generico/procedures/b1wgen0140.p PERSISTENT SET h-b1wgen0140.
        
            RUN saldo_cotas_normal IN h-b1wgen0140(INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                  OUTPUT aux_slcotnor).
        
            DELETE PROCEDURE h-b1wgen0140.
        
            /*** Busca Saldo Bloqueado Judicial ***/
            RUN sistema/generico/procedures/b1wgen0155.p PERSISTENT SET h-b1wgen0155.
        
            RUN retorna-valor-blqjud IN h-b1wgen0155 (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      INPUT 0, /* fixo - nrcpfcgc */
                                                      INPUT 3, /* Bloq. Capital   */
                                                      INPUT 4, /* 4 - CAPITAL     */
                                                      INPUT par_dtmvtolt,
                                                     OUTPUT aux_vlblqjud,
                                                     OUTPUT aux_vlresblq).
        
            DELETE PROCEDURE h-b1wgen0155.
        
            IF tt-lancamentos.vllanmto > (aux_slcotnor - aux_vlblqjud) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor acima do disponivel! " + 
                                      "Maximo de " + 
                                      TRIM(STRING((aux_slcotnor - aux_vlblqjud),
                                                  "zzz,zzz,zzz,zz9.99")).
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_ESTORNA, LEAVE.
                                                              
            END.
    
            DO aux_contador = 1 TO 10:
                                                                        
                FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                   craplot.dtmvtolt = par_dtmvtolt AND
                                   craplot.cdagenci = 1            AND
                                   craplot.cdbccxlt = 100          AND
                                   craplot.nrdolote = 10002        
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF   NOT AVAIL  craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            ASSIGN aux_cdcritic = 77. 
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Registro de lote nao encontrado.".
                            LEAVE.
                        END.
        
                        ASSIGN aux_cdcritic = 0.
                LEAVE.
            END.  /*  Fim do DO...TO  */
        
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_ESTORNA, LEAVE.
                                                              
            END.
            
            CREATE craplct.
    
            ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                   craplot.qtcompln = craplot.qtcompln - 1
                   craplot.qtinfoln = craplot.qtinfoln - 1
                   craplot.vlcompdb = craplot.vlcompdb + tt-lancamentos.vllanmto
                   craplot.vlinfodb = craplot.vlinfodb + tt-lancamentos.vllanmto
    
                   craplct.cdcooper = par_cdcooper
                   craplct.dtmvtolt = par_dtmvtolt
                   craplct.cdagenci = 1
                   craplct.cdbccxlt = 100
                   craplct.nrdolote = 10002
                   craplct.nrdconta = par_nrdconta
                   craplct.nrdocmto = craplot.nrseqdig
                   craplct.cdhistor = 402
                   craplct.nrseqdig = craplot.nrseqdig
                   craplct.vllanmto = tt-lancamentos.vllanmto.
    
    
            /* cria craplcm */
            DO aux_contador = 1 TO 10:
                                                                            
               FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                  craplot.dtmvtolt = par_dtmvtolt AND
                                  craplot.cdagenci = 1            AND
                                  craplot.cdbccxlt = 100          AND
                                  craplot.nrdolote = 10129        EXCLUSIVE-LOCK
                                  NO-ERROR NO-WAIT.
        
               IF   NOT AVAIL  craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                           PAUSE 1 NO-MESSAGE.
                           ASSIGN aux_cdcritic = 77. 
                           NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Registro de lote nao encontrado.".
                            LEAVE.
                        END.
        
                        ASSIGN aux_cdcritic = 0.
               LEAVE.
            END.  /*  Fim do DO...TO  */
        
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_ESTORNA, LEAVE.
                                                              
            END.
        
            CREATE craplcm.
            ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                   craplot.qtcompln = craplot.qtcompln - 1
                   craplot.qtinfoln = craplot.qtcompln
                   craplot.vlcompcr = craplot.vlcompcr + tt-lancamentos.vllanmto
                   craplot.vlinfocr = craplot.vlcompcr
                
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt
                   craplcm.cdhistor = 451
                   craplcm.dtmvtolt = par_dtmvtolt
                   craplcm.cdpesqbb = ""
                   craplcm.nrdconta = par_nrdconta
                   craplcm.nrdctabb = par_nrdconta
                   craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
                   craplcm.nrdocmto = craplot.nrseqdig
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrseqdig = craplot.nrseqdig
                   craplcm.vllanmto = tt-lancamentos.vllanmto
                   craplcm.cdcooper = par_cdcooper.
    
        
            DO aux_contador = 1 TO 10 :
                             
               FIND crapcot WHERE 
                    crapcot.cdcooper = par_cdcooper     AND
                    crapcot.nrdconta = par_nrdconta
                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
               IF   NOT AVAILABLE crapcot   THEN
                    IF   LOCKED crapcot   THEN
                         DO:
                             ASSIGN aux_cdcritic = 77.   
                             PAUSE 2 NO-MESSAGE.
                             NEXT.
                         END.
                     ELSE
                     DO:
                        ASSIGN aux_cdcritic = 55.
                        LEAVE.
                     END.
               ELSE
                   ASSIGN aux_cdcritic = 0.
        
               LEAVE.
               
            END.  /*  Fim do DO WHILE TRUE   */
        
            IF   aux_cdcritic > 0   THEN
            DO:
                ASSIGN aux_dscritic = "".
        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_ESTORNA, LEAVE.
                                                              
            END.
                 
            RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.
              
             IF   VALID-HANDLE(h-b1wgen0001)   THEN
                  DO:
                       RUN ver_capital IN h-b1wgen0001
                                      (INPUT  par_cdcooper,
                                       INPUT  par_nrdconta,
                                       INPUT  0, /*agencia*/
                                       INPUT  0, /* caixa */
                                       INPUT tt-lancamentos.vllanmto,
                                       INPUT  par_dtmvtolt,
                                       INPUT  "landpvi",
                                       INPUT  1, /* AYLLOS */
                                       OUTPUT TABLE tt-erro).
                                       
                       DELETE PROCEDURE h-b1wgen0001.
                       
                       /* Verifica se houve erro */
                       FIND FIRST tt-erro  NO-LOCK NO-ERROR.
                 
                       IF   AVAILABLE tt-erro   THEN
                           UNDO TRANS_ESTORNA, LEAVE.
                           
                  END.
                                                     
            ASSIGN crapcot.vldcotas = crapcot.vldcotas - tt-lancamentos.vllanmto.
    
    
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT 1,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
    
        END.

        RELEASE craplot.
        RELEASE craplct.
        RELEASE craplcm.
        RELEASE crapcot.
        
        RETURN "OK".

    END.

    RELEASE craplot.
    RELEASE craplct.
    RELEASE craplcm.
    RELEASE crapcot.

    RETURN "NOK".

END PROCEDURE.


/*............................................................................*/
