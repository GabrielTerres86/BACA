/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+-----------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL               |
  +------------------------------------------+-----------------------------------+
  | sistema/generico/procedures/b1wgen0006.p |                                   |
  | consulta-poupanca                        | APLI0001.pc_consulta_poupanca     |
  | consulta-extrato-poupanca                | EXTR0002.pc_consulta_extrato_poup |
  | gera-saldo-anterior                      | EXTR0002.pc_gera_saldo_anterior   |
  | ver-valores-bloqueados-judicial          | APLI0002.pc_ver_val_bloqueio_poup |
  +------------------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/*..............................................................................

    Programa: sistema/generico/procedures/b1wgen0006.p                  
    Autora  : Junior
    Data    : 12/09/2005                      Ultima atualizacao: 07/02/2018

    Dados referentes ao programa:

    Objetivo  : BO de regras de negocio para Poupancas Programadas.
                Baseada no programa fontes/sldppr.p.
               
    Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                             tabelas  (Diego).                    
   
                03/08/2007 - Definicoes de temp-tables para include (David).
                
                25/10/2007 - Incluir variaveis rpp na b1wgen0006tt.i (Magui).
   
                30/04/2008 - Retornar campo dtvctopp - Vencimento (David).
                
                04/06/2008 - Incluir cdcooper nos FIND's da craphis (David)
   
                24/07/2008 - Incluida procedure gera-saldo-anterior (Elton).
                           - Acertar procedure de extrato para carregar dados
                             conforme periodo informado (David).
                             
                25/05/2009 - Alteracao CDOPERAD (Kbase).
                
                03/03/2010 - Adaptacao para rotina POUP.PROGRAMADA (David).
                
                27/04/2010 - Ajuste para nao usar mais a tabela de estudo
                             da poupança (Gabriel).
                           - Desconsiderar poupanca vencida no extrato
                             (Evandro).
                             
                23/06/2010 - Corrigir criacao dos lotes (Gabriel).
                
                24/06/2010 - Utilizar o lote 1537 ao criar as poupancas 
                             (Gabriel).
                             
                02/07/2010 - Alimentar o indebito com 0 na criacao
                             (Gabriel).             
                             
                09/08/2010 - Quando alterado o valor da poupança e o lote
                             for criado no mesmo dia , mudar os valores dos
                             lotes tambem (Gabriel).
                             
                26/11/2010 - Ajuste nas procedures validar-dados-suspensao e
                             suspender-poupanca (Vitor).
                             
                03/12/2010 - Atualizar lote quando a poupanca for cancelada
                             no mesmo dia da criacao dela (Gabriel).           
                21/12/2010 - Incluir his 925, sobreposicao Pacs (Magui).
                
                18/01/2011 - Criado variavel aux_vllan925 (Irlan).
                
                05/07/2011 - Ajuste em campo dtresgat, log da procedure
                             efetuar-resgate.
                           - Adicionado parametro aux_vlrppold para receber
                             valor antigo da poupanca programada e gerar log
                             (Jorge).
                             
                27/07/2011 - Alteração na leitura da craprpp no procedure
                             consulta-poupanca. ( Gabriel Capoia - DB1 )
                             
                23/12/2011 - Obter poupancas vencidas para tela ADITIV na 
                             procedure consulta-poupancas (David).
                             
                26/12/2011 - Alterações na procedure 'obtem-dados-inclusao'
                             para cálcuo de prazo de vencimento máximo (Lucas).
                             
                03/10/2012 - Adicionado campo dsextrat da tt-extr-rpp em
                             procedure consulta-extrato-poupanca. (Jorge).
                
                18/12/2012 - incluido historico 1115-transferencia
                             Viacredi/AltoVale(Rosangela)
                             
                02/08/2013 - Tratamento Bloqueiro Judicial (Andre/Supero).
                
                21/08/2013 - Tratamento para Imunidade Tributaria (Ze).
                
                18/12/2013 - Adicionado validate para as tabelas craplot,
                             craplrg, craprpp, crapspp (Tiago).
                             
                21/03/2014 - Ajuste na procedure "incluir-poupanca-programada" 
                             para buscar a proxima sequencia crapmat.nrseqcar 
                             da sequence banco Oracle (James)      
                             
                16/07/2014 - Ajuste regra imunidade tributaria na procedure
                             consulta-extrato-poupanca (Daniel).
                            
                11/12/2014 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                02/03/2016 - Remover a validacao par_dtresgat > craprpp.dtvctopp
                             para possibilitar o resgate da poupança programada
                             (Douglas - Chamado 408688)

                17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

                07/09/2016 - Incluido historico 863 no extrato da poupanca programada da ATENDA
                             Andrey (RKAM) - Chamado 507087

				        07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

			          30/11/2017 - Implementei controle de lock sobre a tabela CRAPLOT na efetuar-resgate. 
							               (SD 799728 - Carlos Rafael Tanholi)

                23/01/2018 - Correcao ao buscar lancamentos de resgate para descontar do saldo da poupanca.
                             Uma busca utilizava <= dtmvtopr e a outra >= dtmvtolt, sobrepondo lancamentos e
                             descontando 2x, fazendo com que o cooperado nao conseguisse sacar o valor desejado.
                             Heitor (Mouts) - Chamado 825869

			   07/02/2018 - Retirada com controle de lock da tabela CRAPLOT. Carlos Rafael Tanholi (SD 845899).

..............................................................................*/


{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/ayllos/includes/var_online.i NEW }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

/** Variaveis da include b1wgen0006.i **/
DEF VAR aux_vlrentot AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlrendim AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vldperda AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlsdrdpp AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlprovis AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlajuste AS DECI                                           NO-UNDO.
DEF VAR aux_vllan150 AS DECI                                           NO-UNDO.
DEF VAR aux_vllan152 AS DECI                                           NO-UNDO.
DEF VAR aux_vllan158 AS DECI                                           NO-UNDO.
DEF VAR aux_vllan925 AS DECI                                           NO-UNDO.
DEF VAR aux_txaplica AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_txaplmes AS DECI DECIMALS 8                                NO-UNDO.
                                                           
DEF VAR aux_dtcalcul AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR aux_dtdolote AS DATE                                           NO-UNDO.
DEF VAR aux_dtultdia AS DATE                                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.
                                                                    
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE INIT 100                                  NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_vlrirrpp AS DECI                                           NO-UNDO.
DEF VAR aux_percenir AS DECI                                           NO-UNDO.

DEF VAR aux_flgimune AS LOGI                                           NO-UNDO.
DEF VAR h-b1wgen0159 AS HANDLE                                         NO-UNDO.


/** Variaveis da include b1wgen0006.i **/

FUNCTION ValorMaximoPrestacao RETURN DECI (INPUT par_cdcooper AS INTE) FORWARD.


/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**  Procedure para consultar saldo e demais dados de poupancas programadas  **/
/******************************************************************************/
PROCEDURE consulta-poupanca:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_vlsldrpp AS DECI DECIMALS 8                NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-rpp.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_vlrgtrpp AS DECI DECIMALS 8                         NO-UNDO.

    DEF VAR aux_qtsaqppr AS INTE                                    NO-UNDO.

    DEF VAR aux_dsresgat AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmsgsaq AS CHAR                                    NO-UNDO.

    DEF BUFFER crabspp FOR crapspp.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-rpp.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Consulta de poupanca programada".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
   
    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper       AND
                               craprpp.nrdconta = par_nrdconta       AND
                              (par_nrctrrpp     = 0                  OR
                              (par_nrctrrpp     > 0                  AND
                               craprpp.nrctrrpp = par_nrctrrpp))     NO-LOCK
                               ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP
                               ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:
                      
            IF  par_nmdatela <> "EXTPPR"            AND
                par_nmdatela <> "ADITIV"            AND
                par_nmdatela <> "IMPRES"            AND
                craprpp.cdsitrpp = 5 /* Vencida */  THEN
                NEXT.
    
            { sistema/generico/includes/b1wgen0006.i }
                                                             
            IF  aux_vlsdrdpp < 0                        AND
                NOT CAN-DO("1,5",STRING(par_idorigem))  THEN  
                NEXT.

            ASSIGN par_vlsldrpp = par_vlsldrpp + aux_vlsdrdpp
                   aux_vlrgtrpp = aux_vlsdrdpp
                   aux_dsresgat = "N"         
                   aux_qtsaqppr = 0
                   aux_dsmsgsaq = "".

            /** Totalizar valores de resgate **/
            FOR EACH craplrg WHERE 
                     craplrg.cdcooper  = par_cdcooper     AND
                     craplrg.nrdconta  = par_nrdconta     AND
                     craplrg.tpaplica  = 4                AND
                     craplrg.nraplica  = craprpp.nrctrrpp AND
                     craplrg.dtresgat <= par_dtmvtopr     AND
                     craplrg.inresgat  = 0                AND
                     CAN-DO("1,2",STRING(craplrg.tpresgat))
                     USE-INDEX craplrg2 NO-LOCK:
                         
                /** Resgate total **/
                IF  craplrg.tpresgat = 2  THEN
                    DO:
                        ASSIGN aux_vlrgtrpp = 0.
                        LEAVE.
                    END.

                ASSIGN aux_vlrgtrpp = aux_vlrgtrpp - craplrg.vllanmto.
            
            END. /** Fim do FOR EACH craplrg **/

            FOR EACH craplpp WHERE craplpp.cdcooper = par_cdcooper     AND 
                                   craplpp.nrdconta = par_nrdconta     AND
                                   craplpp.nrctrrpp = craprpp.nrctrrpp AND
                                  (craplpp.cdhistor = 158              OR
                                   craplpp.cdhistor = 496)             AND
                                   craplpp.dtmvtolt > (par_dtmvtolt - 180)
                                   USE-INDEX craplpp2 NO-LOCK:
                                   
                ASSIGN aux_qtsaqppr = aux_qtsaqppr + 1.

            END. /** Fim do FOR EACH craplpp **/
           
            IF  aux_qtsaqppr > 3  THEN
                ASSIGN aux_dsmsgsaq = "ATENCAO! Mais de 3 saques em 180 dias.".
            
            /** Verifica se poupanca esta bloqueada **/
            FIND FIRST craptab WHERE 
                       craptab.cdcooper = par_cdcooper             AND
                       craptab.nmsistem = "CRED"                   AND
                       craptab.tptabela = "BLQRGT"                 AND
                       craptab.cdempres = 00                       AND
                       craptab.cdacesso = STRING(craprpp.nrdconta,
                                                 "9999999999")     AND 
                       INTE(SUBSTR(craptab.dstextab,
                                  1,7)) = craprpp.nrctrrpp         
                       NO-LOCK NO-ERROR.
                                     
            /** Verifica se a resgate programado para a poupanca **/
            FIND FIRST craplrg WHERE craplrg.cdcooper = par_cdcooper     AND
                                     craplrg.nrdconta = craprpp.nrdconta AND
                                     craplrg.tpaplica = 4                AND
                                     craplrg.nraplica = craprpp.nrctrrpp AND 
                                     craplrg.inresgat = 0  
                                     NO-LOCK NO-ERROR.

            FOR FIRST crabspp WHERE crabspp.cdcooper = par_cdcooper AND
                                    crabspp.nrdconta = par_nrdconta AND
                                    crabspp.nrctrrpp = craprpp.nrctrrpp 
                                    NO-LOCK: END.
            
            CREATE tt-dados-rpp.
            ASSIGN tt-dados-rpp.nrctrrpp = craprpp.nrctrrpp
                   tt-dados-rpp.cdagenci = craprpp.cdagenci
                   tt-dados-rpp.cdbccxlt = craprpp.cdbccxlt
                   tt-dados-rpp.nrdolote = craprpp.nrdolote
                   tt-dados-rpp.dtmvtolt = craprpp.dtmvtolt 
                   tt-dados-rpp.dtvctopp = craprpp.dtvctopp
                   tt-dados-rpp.dtdebito = craprpp.dtdebito
                   tt-dados-rpp.indiadeb = DAY(craprpp.dtdebito)
                   tt-dados-rpp.vlprerpp = craprpp.vlprerpp
                   tt-dados-rpp.qtprepag = craprpp.qtprepag
                   tt-dados-rpp.vlprepag = craprpp.vlprepag
                   tt-dados-rpp.vlsdrdpp = aux_vlsdrdpp
                   tt-dados-rpp.vlrgtrpp = aux_vlrgtrpp
                   tt-dados-rpp.vljuracu = craprpp.vljuracu
                   tt-dados-rpp.vlrgtacu = craprpp.vlrgtacu
                   tt-dados-rpp.dtinirpp = craprpp.dtinirpp
                   tt-dados-rpp.dtrnirpp = craprpp.dtrnirpp
                   tt-dados-rpp.dtaltrpp = craprpp.dtaltrpp
                   tt-dados-rpp.dtcancel = craprpp.dtcancel
                   tt-dados-rpp.dssitrpp = IF  craprpp.cdsitrpp = 1  THEN
                                               "Ativa"
                                           ELSE
                                           IF  craprpp.cdsitrpp = 2  THEN
                                               "Suspensa"
                                           ELSE
                                           IF  craprpp.cdsitrpp = 3  OR
                                               craprpp.cdsitrpp = 4  THEN
                                               "Cancelada"
                                           ELSE
                                           IF  craprpp.cdsitrpp = 5  THEN
                                               "Vencida"
                                           ELSE
                                               "??????"
                   tt-dados-rpp.dsblqrpp = IF  AVAILABLE craptab  THEN
                                               "Sim"
                                           ELSE
                                               "Nao"
                   tt-dados-rpp.dsresgat = IF  AVAILABLE craplrg  THEN
                                               "Sim"
                                           ELSE
                                               "Nao"
                   tt-dados-rpp.dsctainv = IF  craprpp.flgctain  THEN
                                               "Sim"
                                           ELSE
                                               "Nao"
                   tt-dados-rpp.dsmsgsaq = aux_dsmsgsaq
                   tt-dados-rpp.cdtiparq = 0
                   tt-dados-rpp.dtsldrpp = IF   AVAIL crabspp THEN 
                                                crabspp.dtsldrpp
                                           ELSE ?
                   tt-dados-rpp.nrdrowid = ROWID(craprpp).
    
        END. /** Fim do FOR EACH craprpp **/

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel consultar as " +
                                      "poupancas programadas.".

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
/**           Procedure para atualizar dados da poupanca programada          **/
/******************************************************************************/
PROCEDURE atualizar-dados-poupanca:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Atualizar dados da poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
   
    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        DO aux_contador = 1 TO 10:

            FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                               craprpp.nrdconta = par_nrdconta AND
                               craprpp.nrctrrpp = par_nrctrrpp 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craprpp  THEN
                DO:
                    IF  LOCKED craprpp  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craprpp WHERE 
                                         craprpp.cdcooper = par_cdcooper AND
                                         craprpp.nrdconta = par_nrdconta AND
                                         craprpp.nrctrrpp = par_nrctrrpp 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craprpp),
                                                      INPUT "banco",
                                                      INPUT "craprpp").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 495.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.
                                                           
        { sistema/generico/includes/b1wgen0006.i }

        FIND CURRENT craprpp NO-LOCK NO-ERROR.
                                                             
        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar a " +
                                      "poupanca programada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**          Procedure para consultar extrato da poupanca programada         **/
/******************************************************************************/
PROCEDURE consulta-extrato-poupanca:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extr-rpp.
            
    DEF VAR aux_flgfirst AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_vlstotal AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldant AS DECI                                    NO-UNDO.
    
    DEF VAR aux_listahis AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtiniimu AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimimu AS DATE                                    NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsextrat AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    EMPTY TEMP-TABLE tt-extr-rpp.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Carregar extrato da poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = "".
        
    FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                       craprpp.nrdconta = par_nrdconta AND
                       craprpp.nrctrrpp = par_nrctrrpp NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craprpp  THEN
        DO: 
            ASSIGN aux_cdcritic = 495 
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

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope THEN
        DO:   
            ASSIGN aux_cdcritic = 67 
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

    RUN gera-saldo-anterior (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_nrctrrpp,
                             INPUT par_dtiniper,
                            OUTPUT par_dtiniper,
                            OUTPUT aux_vlsldant).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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

    ASSIGN aux_flgfirst = TRUE
           aux_vlstotal = aux_vlsldant.
    
    
    RUN sistema/generico/procedures/b1wgen0159.p
                                 PERSISTENT SET h-b1wgen0159.

    RUN verifica-periodo-imune IN h-b1wgen0159(INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                              OUTPUT aux_flgimune,
                                              OUTPUT aux_dtiniimu,
                                              OUTPUT aux_dtfimimu,
                                              OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0159.
    
    IF  par_nmdatela = "ATENDA"  THEN
        DO:
            IF  crapope.cddepart = 20  THEN  /** SUPER-USUARIO **/
                ASSIGN aux_listahis = "150,151,152,154,155,158,496,863,925,1115".
            ELSE
                ASSIGN aux_listahis = "150,151,158,496,863,925,1115".
        END.
    ELSE
        DO:
            IF  crapope.cddepart = 20  THEN  /** SUPER-USUARIO **/
                ASSIGN aux_listahis = 
                       "150,151,152,154,155,158,496,863,869,870,925,1115".
            ELSE
                ASSIGN aux_listahis = "150,151,158,496,863,870,925,1115".
        END.
                                                    
    FOR EACH craplpp WHERE craplpp.cdcooper  = par_cdcooper AND
                           craplpp.nrdconta  = par_nrdconta AND
                           craplpp.nrctrrpp  = par_nrctrrpp AND
                           craplpp.dtrefere >= par_dtiniper AND
                           craplpp.dtmvtolt >= par_dtiniper AND
                           craplpp.dtmvtolt <= par_dtfimper AND
                           CAN-DO(aux_listahis,STRING(craplpp.cdhistor)) 
                           USE-INDEX craplpp2 NO-LOCK:

        /** Faz parte da composicao do saldo anterior **/
        IF  craplpp.dtrefere = par_dtiniper  AND
           (craplpp.cdhistor = 150           OR
            craplpp.cdhistor = 151           OR 
            craplpp.cdhistor = 152           OR
            craplpp.cdhistor = 154           OR
            craplpp.cdhistor = 155           OR
            craplpp.cdhistor = 863           OR
            craplpp.cdhistor = 869           OR
            craplpp.cdhistor = 870)          THEN
            NEXT.
               
        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplpp.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craphis  THEN
            DO: 
                ASSIGN aux_cdcritic = 80
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

        IF  craphis.indebcre = "C"  THEN
            ASSIGN aux_vlstotal = aux_vlstotal + craplpp.vllanmto.
        ELSE
        IF  craphis.indebcre = "D"  THEN
            ASSIGN aux_vlstotal = aux_vlstotal - craplpp.vllanmto.
        ELSE
            DO: 
                ASSIGN aux_cdcritic = 83
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

        IF  aux_flgfirst  THEN
            DO:
                ASSIGN aux_flgfirst = FALSE.

                CREATE tt-extr-rpp.
                ASSIGN tt-extr-rpp.dtmvtolt = par_dtiniper
                       tt-extr-rpp.dshistor = "SALDO ANTERIOR"
                       tt-extr-rpp.nrdocmto = 0
                       tt-extr-rpp.indebcre = ""
                       tt-extr-rpp.vllanmto = 0
                       tt-extr-rpp.vlsldppr = aux_vlsldant
                       tt-extr-rpp.txaplica = 0
                       tt-extr-rpp.txaplmes = 0
                       tt-extr-rpp.dsextrat = "SALDO ANTERIOR".

                IF  par_nmdatela <> "INTERNETBANK"  THEN
                    ASSIGN tt-extr-rpp.vllanmto = aux_vlsldant.

            END.
            
        IF   aux_flgimune THEN
             DO:
                  IF   craplpp.cdhistor = 151             AND
                       craplpp.dtmvtolt >= aux_dtiniimu   AND
                      (aux_dtfimimu      = ?              OR
                      (aux_dtfimimu     <> ?              AND
                       craplpp.dtmvtolt <= aux_dtfimimu)) THEN
                       ASSIGN aux_dshistor = craphis.dshistor + "*"
                              aux_dsextrat = craphis.dsextrat + "*".
                  ELSE
                       ASSIGN aux_dshistor = craphis.dshistor
                              aux_dsextrat = craphis.dsextrat.
             END.
        ELSE
             ASSIGN aux_dshistor = craphis.dshistor
                    aux_dsextrat = craphis.dsextrat.

        CREATE tt-extr-rpp.
        ASSIGN tt-extr-rpp.dtmvtolt = craplpp.dtmvtolt
               tt-extr-rpp.cdagenci = craplpp.cdagenci
               tt-extr-rpp.cdbccxlt = craplpp.cdbccxlt
               tt-extr-rpp.nrdolote = craplpp.nrdolote
               tt-extr-rpp.dshistor = aux_dshistor
               tt-extr-rpp.nrdocmto = craplpp.nrdocmto
               tt-extr-rpp.indebcre = craphis.indebcre
               tt-extr-rpp.vllanmto = craplpp.vllanmto
               tt-extr-rpp.vlsldppr = aux_vlstotal
               tt-extr-rpp.txaplmes = IF  craplpp.txaplmes > 0  THEN
                                          craplpp.txaplmes 
                                      ELSE 
                                          0
               tt-extr-rpp.txaplica = IF  craplpp.txaplica > 0  THEN
                                          craplpp.txaplica 
                                      ELSE 
                                          0
               tt-extr-rpp.dsextrat = aux_dsextrat.
                                         
    END. /** Fim do FOR EACH craplpp **/

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
/**                Procedure para cancelar poupanca programada               **/
/******************************************************************************/
PROCEDURE cancelar-poupanca:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdsitrpp AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltrpp AS DATE                                    NO-UNDO.
    DEF VAR aux_dtcancel AS DATE                                    NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
        
    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        DO aux_contador = 1 TO 10:

            FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                               craprpp.nrdconta = par_nrdconta AND
                               craprpp.nrctrrpp = par_nrctrrpp 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craprpp  THEN
                DO:
                    IF  LOCKED craprpp  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craprpp WHERE 
                                         craprpp.cdcooper = par_cdcooper AND
                                         craprpp.nrdconta = par_nrdconta AND
                                         craprpp.nrctrrpp = par_nrctrrpp 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craprpp),
                                                      INPUT "banco",
                                                      INPUT "craprpp").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 495.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        IF  craprpp.cdsitrpp = 5  THEN
            DO:
                ASSIGN aux_cdcritic = 919
                       aux_dscritic = "".
                
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.
    
        IF  craprpp.cdsitrpp > 2  THEN
            DO:
                ASSIGN aux_cdcritic = 481
                       aux_dscritic = "".

                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        /* Se o lote for de hoje , entao alterar o valor dele tambem */
        DO aux_contador = 1 TO 10:
        
            FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                               craplot.dtmvtolt = craprpp.dtmvtolt   AND
                               craplot.dtmvtolt = par_dtmvtolt       AND
                               craplot.cdagenci = craprpp.cdagenci   AND
                               craplot.cdbccxlt = craprpp.cdbccxlt   AND
                               craplot.nrdolote = craprpp.nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF    NOT AVAIL craplot THEN
                  IF   LOCKED craplot   THEN
                       DO:
                           aux_cdcritic = 84.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
             UNDO TRANS_POUP, LEAVE TRANS_POUP.

        /* Se lote é de hoje entao atualizar valor */
        IF   AVAIL craplot   THEN
             ASSIGN craplot.vlcompcr = craplot.vlcompcr - craprpp.vlprerpp
                    craplot.vlinfocr = craplot.vlinfocr - craprpp.vlprerpp   
                    craplot.qtcompln = craplot.qtcompln - 1
                    craplot.qtinfoln = craplot.qtinfoln - 1.

        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        ASSIGN aux_cdsitrpp     = craprpp.cdsitrpp
               aux_dtaltrpp     = craprpp.dtaltrpp
               aux_dtcancel     = craprpp.dtcancel
               craprpp.cdsitrpp = craprpp.cdsitrpp + 2
               craprpp.dtaltrpp = par_dtmvtolt
				/* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craprpp.cdopeexc = par_cdoperad
               craprpp.cdageexc = par_cdagenci
               craprpp.dtinsexc = TODAY
				/* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craprpp.dtcancel = par_dtmvtolt.

        FIND CURRENT craprpp NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/
    
    IF  NOT aux_flgtrans  THEN
        DO: 
            
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel cancelar a poupanca " +
                                      "programada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Situacao da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cdsitrpp",
                                     INPUT STRING(aux_cdsitrpp),
                                     INPUT STRING(craprpp.cdsitrpp)).

            /** Data da Alteracao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtaltrpp",
                                     INPUT IF  aux_dtaltrpp = ?  THEN 
                                               ""
                                           ELSE
                                               STRING(aux_dtaltrpp,
                                                      "99/99/9999"),
                                     INPUT STRING(craprpp.dtaltrpp,
                                                  "99/99/9999")).

            /** Data do Cancelamento **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtcancel",
                                     INPUT IF  aux_dtcancel = ?  THEN
                                               ""
                                           ELSE
                                               STRING(aux_dtcancel,
                                                      "99/99/9999"),
                                     INPUT STRING(craprpp.dtcancel,
                                                  "99/99/9999")).
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**       Procedure que obtem dados para suspender poupanca programada       **/
/******************************************************************************/
PROCEDURE obtem-dados-suspensao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-rpp.

    DEF VAR aux_vlsldrpp AS DECI DECIMALS 8                         NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-rpp.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados da poupanca para suspensao"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.
           
    DO WHILE TRUE:

        FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND 
                           craprpp.nrdconta = par_nrdconta AND
                           craprpp.nrctrrpp = par_nrctrrpp NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craprpp  THEN
            DO:
                ASSIGN aux_cdcritic = 495.
                LEAVE.
            END.

        IF  craprpp.cdsitrpp = 5  THEN
            DO:
                ASSIGN aux_cdcritic = 919.
                LEAVE.
            END.   
       
        IF  craprpp.cdsitrpp <> 1  THEN
            DO:
                ASSIGN aux_cdcritic = 481.
                LEAVE.
            END.
            
        RUN consulta-poupanca (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nrctrrpp,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               INPUT par_inproces,
                               INPUT par_cdprogra,
                               INPUT FALSE,  /** Nao Gerar Log **/
                              OUTPUT aux_vlsldrpp,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-dados-rpp).
    
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
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
/**     Procedure para validar dados para suspender poupanca programada     **/
/******************************************************************************/
PROCEDURE validar-dados-suspensao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrmesusp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    DEF VAR aux_nrdiaini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrmesini AS INTE                                    NO-UNDO.
    DEF VAR aux_nranoini AS INTE                                    NO-UNDO.

    DEF VAR aux_dtreinic AS DATE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados para suspensao da poupanca"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.
           
    DO WHILE TRUE:

        FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND 
                           craprpp.nrdconta = par_nrdconta AND
                           craprpp.nrctrrpp = par_nrctrrpp NO-LOCK NO-ERROR.
                        
        IF  NOT AVAILABLE craprpp  THEN
            DO:
                ASSIGN aux_cdcritic = 495.
                LEAVE.
            END.
    
        IF  par_nrmesusp < 1  OR
            par_nrmesusp > 6  THEN
            DO:
                ASSIGN aux_cdcritic = 26.
                LEAVE.
            END.

        ASSIGN aux_nrdiaini = DAY(craprpp.dtdebito)
               aux_nrmesini = MONTH(craprpp.dtdebito) + par_nrmesusp 
               aux_nranoini = YEAR(craprpp.dtdebito).

        IF  aux_nrmesini > 12  THEN
            ASSIGN aux_nrmesini = aux_nrmesini - 12
                   aux_nranoini = aux_nranoini + 1.

        ASSIGN aux_dtreinic = DATE(aux_nrmesini,aux_nrdiaini,aux_nranoini).

        /** Data de reinicio da poupanca nao pode ser maior que o vencimento **/
        IF  aux_dtreinic > craprpp.dtvctopp  THEN
            DO:
                ASSIGN aux_cdcritic = 26.
                LEAVE.
            END.
        
        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
                END.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**              Procedure para suspender a poupanca programada              **/
/******************************************************************************/
PROCEDURE suspender-poupanca:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrmesusp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdsitrpp AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdiaini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrmesini AS INTE                                    NO-UNDO.
    DEF VAR aux_nranoini AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltrpp AS DATE                                    NO-UNDO.
    DEF VAR aux_dtrnirpp AS DATE                                    NO-UNDO.
    DEF VAR aux_dtreinic AS DATE                                    NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Suspender poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
        
    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        DO aux_contador = 1 TO 10:
           
            FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                               craprpp.nrdconta = par_nrdconta AND
                               craprpp.nrctrrpp = par_nrctrrpp 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craprpp  THEN
                DO:
                    IF  LOCKED craprpp  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craprpp WHERE 
                                         craprpp.cdcooper = par_cdcooper AND
                                         craprpp.nrdconta = par_nrdconta AND
                                         craprpp.nrctrrpp = par_nrctrrpp 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craprpp),
                                                      INPUT "banco",
                                                      INPUT "craprpp").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 495.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        ASSIGN aux_nrdiaini = DAY(craprpp.dtdebito)
               aux_nrmesini = MONTH(craprpp.dtdebito) + par_nrmesusp
               aux_nranoini = YEAR(craprpp.dtdebito).
                
        IF  aux_nrmesini > 12  THEN
            ASSIGN aux_nrmesini = aux_nrmesini - 12
                   aux_nranoini = aux_nranoini + 1.

        ASSIGN aux_dtreinic = DATE(aux_nrmesini,aux_nrdiaini,aux_nranoini).
        
        ASSIGN aux_cdsitrpp     = craprpp.cdsitrpp
               aux_dtaltrpp     = craprpp.dtaltrpp
               aux_dtrnirpp     = craprpp.dtrnirpp
               craprpp.cdsitrpp = 2
               craprpp.dtaltrpp = par_dtmvtolt
               craprpp.dtrnirpp = aux_dtreinic.

        
        FIND CURRENT craprpp NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/

    IF  NOT aux_flgtrans  THEN
        DO: 
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel suspender a poupanca " +
                                      "programada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Situacao da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cdsitrpp",
                                     INPUT STRING(aux_cdsitrpp),
                                     INPUT STRING(craprpp.cdsitrpp)).

            /** Data da Alteracao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtaltrpp",
                                     INPUT IF  aux_dtaltrpp = ?  THEN
                                               ""
                                           ELSE
                                               STRING(aux_dtaltrpp,
                                                      "99/99/9999"),
                                     INPUT STRING(craprpp.dtaltrpp,
                                                  "99/99/9999")).

            /** Data do Reinicio **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtrnirpp",
                                     INPUT IF  aux_dtrnirpp = ?  THEN
                                               ""
                                           ELSE
                                               STRING(aux_dtrnirpp,
                                                      "99/99/9999"),
                                     INPUT STRING(craprpp.dtrnirpp,
                                                  "99/99/9999")).
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**              Procedure para reativar a poupanca programada               **/
/******************************************************************************/
PROCEDURE reativar-poupanca:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdsitrpp AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltrpp AS DATE                                    NO-UNDO.
    DEF VAR aux_dtcancel AS DATE                                    NO-UNDO.
    DEF VAR aux_dtdebito AS DATE                                    NO-UNDO.
    DEF VAR aux_dtrnirpp AS DATE                                    NO-UNDO.

    DEF VAR aux_vlmaxppr AS DECI                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Reativar poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
        
    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        DO aux_contador = 1 TO 10:

            FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                               craprpp.nrdconta = par_nrdconta AND
                               craprpp.nrctrrpp = par_nrctrrpp 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craprpp  THEN
                DO:
                    IF  LOCKED craprpp  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craprpp WHERE 
                                         craprpp.cdcooper = par_cdcooper AND
                                         craprpp.nrdconta = par_nrdconta AND
                                         craprpp.nrctrrpp = par_nrctrrpp 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craprpp),
                                                      INPUT "banco",
                                                      INPUT "craprpp").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 495.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        IF  craprpp.cdsitrpp = 5  THEN
            DO:
                ASSIGN aux_cdcritic = 919
                       aux_dscritic = "".
                
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.
    
        IF  craprpp.cdsitrpp = 1  THEN
            DO:
                ASSIGN aux_cdcritic = 483
                       aux_dscritic = "".

                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        IF  NOT craprpp.flgctain  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Poupanca nao pode ser reativada.".

                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        ASSIGN aux_vlmaxppr = ValorMaximoPrestacao(INPUT par_cdcooper).
                                  
        IF  craprpp.vlprerpp > aux_vlmaxppr  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor acima do permitido. Maximo de " +
                           TRIM(STRING(aux_vlmaxppr,"zzz,zzz,zz9.99")) + ".".

                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        IF  craprpp.cdsitrpp = 2  THEN
            ASSIGN aux_cdsitrpp     = craprpp.cdsitrpp
                   aux_dtaltrpp     = craprpp.dtaltrpp
                   aux_dtrnirpp     = craprpp.dtrnirpp
                   craprpp.cdsitrpp = 1
                   craprpp.dtaltrpp = par_dtmvtolt
                   craprpp.dtrnirpp = ?.
        ELSE
        IF  craprpp.cdsitrpp = 3  THEN
            ASSIGN aux_cdsitrpp     = craprpp.cdsitrpp
                   aux_dtaltrpp     = craprpp.dtaltrpp
                   aux_dtcancel     = craprpp.dtcancel
                   aux_dtdebito     = craprpp.dtdebito
                   craprpp.cdsitrpp = 1
                   craprpp.dtaltrpp = par_dtmvtolt
                   craprpp.dtcancel = ?
                   craprpp.dtdebito = craprpp.dtfimper.
        ELSE
        IF  craprpp.cdsitrpp = 4  THEN
            DO:
                IF  craprpp.dtrnirpp < par_dtmvtolt  THEN
                    ASSIGN aux_cdsitrpp     = craprpp.cdsitrpp
                           aux_dtaltrpp     = craprpp.dtaltrpp
                           aux_dtrnirpp     = craprpp.dtrnirpp
                           aux_dtcancel     = craprpp.dtcancel
                           aux_dtdebito     = craprpp.dtdebito
                           craprpp.cdsitrpp = 1
                           craprpp.dtaltrpp = par_dtmvtolt
                           craprpp.dtrnirpp = ?
                           craprpp.dtcancel = ?
                           craprpp.dtdebito = craprpp.dtfimper.
                ELSE
                    ASSIGN aux_cdsitrpp     = craprpp.cdsitrpp
                           aux_dtaltrpp     = craprpp.dtaltrpp
                           aux_dtcancel     = craprpp.dtcancel
                           craprpp.cdsitrpp = 2
                           craprpp.dtaltrpp = par_dtmvtolt
                           craprpp.dtcancel = ?.
            END.

        FIND CURRENT craprpp NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/
    
    IF  NOT aux_flgtrans  THEN
        DO: 
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel reativar a poupanca " +
                                      "programada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Situacao da Poupanca **/
            IF  aux_cdsitrpp <> craprpp.cdsitrpp  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdsitrpp",
                                         INPUT STRING(aux_cdsitrpp),
                                         INPUT STRING(craprpp.cdsitrpp)).

            /** Data da Alteracao **/
            IF  aux_dtaltrpp <> craprpp.dtaltrpp  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtaltrpp",
                                         INPUT IF  aux_dtaltrpp = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtaltrpp,
                                                      "99/99/9999"),
                                         INPUT STRING(craprpp.dtaltrpp,
                                                      "99/99/9999")).

            /** Data do Reinicio **/
            IF  aux_dtrnirpp <> craprpp.dtrnirpp  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtrnirpp",
                                         INPUT IF  aux_dtrnirpp = ?  THEN 
                                                   ""
                                               ELSE 
                                                   STRING(aux_dtrnirpp,
                                                          "99/99/9999"),
                                         INPUT IF  craprpp.dtrnirpp = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(craprpp.dtrnirpp,
                                                          "99/99/9999")).

            /** Data do Cancelamento **/
            IF  aux_dtcancel <> craprpp.dtcancel  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtcancel",
                                         INPUT IF  aux_dtcancel = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtcancel,
                                                         "99/99/9999"),
                                         INPUT IF  craprpp.dtcancel = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(craprpp.dtcancel,
                                                          "99/99/9999")).

            /** Data do Debito **/
            IF  aux_dtdebito <> craprpp.dtdebito  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtdebito",
                                         INPUT IF  aux_dtdebito = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtdebito,
                                                         "99/99/9999"),
                                         INPUT IF  craprpp.dtdebito = ?  THEN
                                                   ""
                                               ELSE 
                                                   STRING(craprpp.dtdebito,
                                                          "99/99/9999")).
        END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**     Procedure para validar alcada limite capatacao do operador           **/
/******************************************************************************/
PROCEDURE validar-limite-resgate:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl              NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta              NO-UNDO.
    DEF INPUT PARAM par_vlrrsgat LIKE crapope.vlapvcap              NO-UNDO.
    DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT PARAM par_cddsenha LIKE crapope.cddsenha              NO-UNDO.
    DEF INPUT PARAM par_flgsenha AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic    LIKE    crapcri.cdcritic                NO-UNDO.
    DEF VAR aux_dscritic    LIKE    crapcri.dscritic                NO-UNDO.

    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_validar_limite_resgate
       aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,            /* Codigo da Cooperativa */
                                           INPUT par_idorigem,            /* Identificador de sistema de origem */
                                           INPUT par_nmdatela,            /* Nome da tela */
                                           INPUT par_idseqttl,            /* Sequencia do titular */
                                           INPUT par_nrdconta,            /* Numero da conta */
                                           INPUT par_vlrrsgat,            /* Valor resgate */
                                           INPUT par_cdoperad,            /* Codigo do operador */
                                           INPUT par_cddsenha,            /* Senha operador */
                                           INPUT par_flgsenha,            /* Se deve validar senha operador ou nao */
                                          OUTPUT aux_cdcritic,             /* Codigo da critica */
                                          OUTPUT aux_dscritic).            /* Descricao da critica */  

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_validar_limite_resgate
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_validar_limite_resgate.pr_cdcritic 
                          WHEN pc_validar_limite_resgate.pr_cdcritic <> ?
           aux_dscritic = pc_validar_limite_resgate.pr_dscritic 
                          WHEN pc_validar_limite_resgate.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR
       aux_dscritic <> "" THEN
       DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.

            RETURN "NOK".
        END.
    
    RETURN "OK".
END PROCEDURE.

/******************************************************************************/
/**     Procedure para validar dados do resgate ou acesso a opcao resgate    **/
/******************************************************************************/
PROCEDURE valida-resgate:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpresgat AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlresgat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgoprgt AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlsldrpp AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    DEF VAR aux_dtmvtopr AS DATE                                    NO-UNDO.

    DEF VAR aux_vlsldrpp AS DECI DECIMALS 8                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = IF  par_flgoprgt  THEN 
                                  "Validar acesso a opcao resgate"
                              ELSE
                                  "Validar dados do resgate".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE
           par_vlsldrpp = 0.

    IF  NOT par_flgoprgt  THEN
        DO:
            RUN ver-valores-bloqueados-poup (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT par_inproces,
                                                 INPUT par_cdprogra,
                                                 INPUT par_vlresgat,
                                                 INPUT par_flgerlog,
                                                 OUTPUT TABLE tt-erro).
                                         
            IF   RETURN-VALUE = "NOK"  THEN
                 DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF  AVAILABLE tt-erro  THEN
                         ASSIGN aux_cdcritic = tt-erro.cdcritic
                                aux_dscritic = tt-erro.dscritic.
                     ELSE
                         DO:
                             ASSIGN aux_cdcritic = 0
                                    aux_dscritic = 
                                            "Nao foi possivel cadastrar o " +
                                            "resgate.".
                                          
                             RUN gera_erro (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT 1,          /** Sequencia **/
                                            INPUT aux_cdcritic,
                                            INPUT-OUTPUT aux_dscritic).
                         END.
                                                   
                     IF  par_flgerlog THEN
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
    
    DO WHILE TRUE:

        RUN consulta-poupanca (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nrctrrpp,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               INPUT par_inproces,
                               INPUT par_cdprogra,
                               INPUT FALSE,  /** Nao Gerar Log **/
                              OUTPUT aux_vlsldrpp,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-dados-rpp).
    
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.
               
        ASSIGN par_vlsldrpp = aux_vlsldrpp.

        FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                           craprpp.nrdconta = par_nrdconta AND
                           craprpp.nrctrrpp = par_nrctrrpp NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE craprpp  THEN
            DO:
                ASSIGN aux_cdcritic = 495.
                LEAVE.
            END.
            
        IF  craprpp.cdsitrpp = 5  THEN
            DO:
                ASSIGN aux_cdcritic = 919.
                LEAVE.
            END.
            
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "USUARI"     AND
                           craptab.cdempres = 11           AND
                           craptab.cdacesso = "DIARESGATE" AND
                           craptab.tpregist = 001          NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE craptab  THEN
            DO:
                ASSIGN aux_cdcritic = 486.
                LEAVE.
            END.
        ELSE
            aux_dtmvtopr = par_dtmvtolt + INTE(SUBSTR(craptab.dstextab,1,3)).

        /** Validando acesso a opcao resgate **/
        IF  par_flgoprgt  THEN
            DO:
                ASSIGN aux_flgerror = FALSE.
                LEAVE.
            END.

        IF  NOT CAN-DO("P,T",par_tpresgat)  THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de resgate invalido.".
                LEAVE.
            END.    

        IF  par_tpresgat = "P"  THEN  /** Resgate Parcial **/
            DO:
                IF  par_vlresgat  = 0             OR 
                    par_vlresgat >= aux_vlsldrpp  THEN
                    DO:
                        ASSIGN aux_cdcritic = 269.
                        LEAVE.
                    END.
            END.

        IF  par_dtresgat = ?  THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE.
            END.

        IF  par_dtresgat = craprpp.dtvctopp  THEN
            DO:
                ASSIGN aux_cdcritic = 907.
                LEAVE.                 
            END.

        FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND 
                           crapfer.dtferiad = par_dtresgat NO-LOCK NO-ERROR.
              
        IF  AVAILABLE crapfer                                OR
            par_dtresgat < aux_dtmvtopr                      OR
            par_dtresgat > (par_dtmvtolt + 180)              OR
            CAN-DO("1,7",STRING(WEEKDAY(par_dtresgat),"9"))  THEN
            DO:
                ASSIGN aux_cdcritic =  13.
                LEAVE.
            END.
            
        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
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
/**           Procedure para efetuar resgate da poupanca programada          **/
/******************************************************************************/
PROCEDURE efetuar-resgate:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO. 
    DEF  INPUT PARAM par_tpresgat AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlresgat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctain AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Efetuar resgate para poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
    
    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

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
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craplot WHERE 
                                         craplot.cdcooper = par_cdcooper AND 
                                         craplot.dtmvtolt = par_dtmvtolt AND
                                         craplot.cdagenci = 99           AND
                                         craplot.cdbccxlt = 400          AND
                                         craplot.nrdolote = 999 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craplot),
                                                      INPUT "banco",
                                                      INPUT "craplot").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.cdcooper = par_cdcooper
                                   craplot.dtmvtolt = par_dtmvtolt
                                   craplot.dtmvtopg = par_dtmvtopr
                                   craplot.cdoperad = par_cdoperad
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
                                   craplot.vlinfodb = par_vlresgat.
                            VALIDATE craplot.
                        END.
                END.
            ELSE
                ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.vlcompdb = craplot.vlcompdb + par_vlresgat
                       craplot.vlinfodb = craplot.vlinfodb + par_vlresgat. 

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        CREATE craplrg.
        ASSIGN craplrg.cdcooper = par_cdcooper
               craplrg.cdagenci = 99
               craplrg.cdbccxlt = 400
               craplrg.dtmvtolt = par_dtmvtolt
               craplrg.dtresgat = par_dtresgat
               craplrg.inresgat = 0
               craplrg.nraplica = par_nrctrrpp
               craplrg.nrdconta = par_nrdconta
               craplrg.nrdocmto = craplot.nrseqdig             
               craplrg.nrdolote = 999
               craplrg.nrseqdig = craplot.nrseqdig             
               craplrg.tpaplica = 4
               craplrg.tpresgat = IF  par_tpresgat = "P"  THEN 
                                      1
                                  ELSE
                                      2
               craplrg.vllanmto = par_vlresgat
               craplrg.cdoperad = par_cdoperad
               craplrg.hrtransa = TIME
               craplrg.flgcreci = par_flgctain.
        
        VALIDATE craplrg.

		FIND CURRENT craplot NO-LOCK NO-ERROR.
        FIND CURRENT craplrg NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANS_POUP **/
    
    
    IF  NOT aux_flgtrans  THEN
        DO: 

            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel efetuar o resgate.".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).

                    /** Tipo do resgate **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "tpresgat",
                                             INPUT "",
                                             INPUT par_tpresgat).

                    /** Valor do resgate **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vlresgat",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_vlresgat,
                                                        "zzz,zzz,zz9.99"))).

                    /** Data do resgate **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "dtresgat",
                                             INPUT "",
                                             INPUT STRING(par_dtresgat,
                                                          "99/99/9999")).

                    /** Resgatar para a conta investimento? **/
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Tipo do resgate **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "tpresgat",
                                     INPUT "",
                                     INPUT par_tpresgat).

            /** Valor do resgate **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "vlresgat",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_vlresgat,
                                                       "zzz,zzz,zz9.99"))).

            /** Data do resgate **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtresgat",
                                     INPUT "",
                                     INPUT STRING(par_dtresgat,"99/99/9999")).

            /** Resgatar para a conta investimento? **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "flgctain",
                                     INPUT "",
                                     INPUT STRING(par_flgctain,"SIM/NAO")).
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**         Procedure para consultar resgates da poupanca programada         **/
/******************************************************************************/
PROCEDURE consultar-resgates:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcance AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-resgates-rpp.

    EMPTY TEMP-TABLE tt-resgates-rpp.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar resgates da poupanca programada".
           
    FOR EACH craplrg WHERE craplrg.cdcooper = par_cdcooper AND 
                           craplrg.nrdconta = par_nrdconta AND
                           craplrg.nraplica = par_nrctrrpp AND
                          (craplrg.inresgat = 0            OR
                           craplrg.inresgat = 2)           NO-LOCK:
                       
        IF  NOT (craplrg.inresgat = 2 AND par_flgcance)  THEN
            DO:    
                FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND 
                                   crapope.cdoperad = craplrg.cdoperad 
                                   NO-LOCK NO-ERROR.
   
                CREATE tt-resgates-rpp.
                ASSIGN tt-resgates-rpp.tpresgat = IF  craplrg.tpresgat = 1  THEN
                                                      "Parcial"
                                                  ELSE 
                                                      "Total"
                       tt-resgates-rpp.vlresgat = craplrg.vllanmto
                       tt-resgates-rpp.dtresgat = craplrg.dtresgat
                       tt-resgates-rpp.nrdocmto = craplrg.nrdocmto
                       tt-resgates-rpp.dsresgat = IF  craplrg.inresgat = 0 THEN
                                                      "Nao Resgatado" 
                                                  ELSE
                                                      "Cancelado"  
                       tt-resgates-rpp.nmoperad = IF  AVAILABLE crapope  THEN
                                                      ENTRY(1,crapope.nmoperad,
                                                            " ")
                                                  ELSE                        
                                                      "NOME INEXISTENTE"
                       tt-resgates-rpp.hrtransa = STRING(craplrg.hrtransa, 
                                                         "HH:MM").
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
/**          Procedure para cancelar resgate da poupanca programada          **/
/******************************************************************************/
PROCEDURE cancelar-resgate:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar resgate da poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        DO aux_contador = 1 TO 10:
    
            FIND craplrg WHERE craplrg.cdcooper = par_cdcooper AND
                               craplrg.nrdconta = par_nrdconta AND
                               craplrg.nraplica = par_nrctrrpp AND
                               craplrg.nrdocmto = par_nrdocmto AND
                               craplrg.inresgat = 0  
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
            IF  NOT AVAILABLE craplrg  THEN
                DO:
                    IF  LOCKED craplrg  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craplrg WHERE 
                                         craplrg.cdcooper = par_cdcooper AND
                                         craplrg.nrdconta = par_nrdconta AND
                                         craplrg.nraplica = par_nrctrrpp AND
                                         craplrg.nrdocmto = par_nrdocmto AND
                                         craplrg.inresgat = 0   
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craplrg),
                                                      INPUT "banco",
                                                      INPUT "craplrg").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 730.
                END.
                    
            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        DO aux_contador = 1 TO 10:
    
            FIND craplot WHERE craplot.cdcooper = par_cdcooper     AND 
                               craplot.dtmvtolt = craplrg.dtmvtolt AND
                               craplot.cdagenci = 99               AND
                               craplot.cdbccxlt = 400              AND
                               craplot.nrdolote = 999
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot   THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craplot WHERE 
                                         craplot.cdcooper = par_cdcooper     AND 
                                         craplot.dtmvtolt = craplrg.dtmvtolt AND
                                         craplot.cdagenci = 99               AND
                                         craplot.cdbccxlt = 400              AND
                                         craplot.nrdolote = 999   
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craplot),
                                                      INPUT "banco",
                                                      INPUT "craplot").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 60.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.
                    
        ASSIGN craplrg.inresgat = 2
               craplrg.cdoperad = par_cdoperad
               craplrg.hrtransa = TIME
               craplot.qtcompln = craplot.qtcompln - 1
               craplot.qtinfoln = craplot.qtinfoln - 1
               craplot.vlcompdb = craplot.vlcompdb - craplrg.vllanmto
               craplot.vlinfodb = craplot.vlinfodb - craplrg.vllanmto.

        FIND CURRENT craplrg NO-LOCK NO-ERROR.
        FIND CURRENT craplot NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/

    IF  NOT aux_flgtrans  THEN
        DO: 

            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel cancelar o resgate.".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).

                    /** Nr.Documento do Resgate **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrdocmto",
                                             INPUT "",
                                             INPUT STRING(par_nrdocmto,
                                                          "zzz,zzz,zz9")).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Nr.Documento do Resgate **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrdocmto",
                                     INPUT "",
                                     INPUT STRING(par_nrdocmto,"zzz,zzz,zz9")).
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**        Procedure que obtem dados para alterar poupanca programada        **/
/******************************************************************************/
PROCEDURE obtem-dados-alteracao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-rpp.

    DEF VAR aux_vlsldrpp AS DECI DECIMALS 8                         NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-rpp.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados da poupanca para alteracao"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.
           
    DO WHILE TRUE:

        FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND 
                           craprpp.nrdconta = par_nrdconta AND
                           craprpp.nrctrrpp = par_nrctrrpp NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craprpp  THEN
            DO:
                ASSIGN aux_cdcritic = 495.
                LEAVE.
            END.

        IF  craprpp.cdsitrpp = 5  THEN
            DO:
                ASSIGN aux_cdcritic = 919.
                LEAVE.
            END.   
       
        IF  craprpp.cdsitrpp <> 1  THEN
            DO:
                ASSIGN aux_cdcritic = 481.
                LEAVE.
            END.
            
        IF  craprpp.dtvctopp < craprpp.dtdebito  THEN
            DO: 
                ASSIGN aux_dscritic = "Transacao nao permitida. Data de " +
                                      "vencimento proxima.".
                LEAVE.
            END.

        RUN consulta-poupanca (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nrctrrpp,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               INPUT par_inproces,
                               INPUT par_cdprogra,
                               INPUT FALSE,  /** Nao Gerar Log **/
                              OUTPUT aux_vlsldrpp,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-dados-rpp).
    
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
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
/**    Procedure para validar dados da poupanca programada para alteracao    **/
/******************************************************************************/
PROCEDURE validar-dados-alteracao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprerpp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados para alteracao da poupanca"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.
           
    DO WHILE TRUE:

        FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND 
                           craprpp.nrdconta = par_nrdconta AND
                           craprpp.nrctrrpp = par_nrctrrpp NO-LOCK NO-ERROR.
                        
        IF  NOT AVAILABLE craprpp  THEN
            DO:
                ASSIGN aux_cdcritic = 495.
                LEAVE.
            END.
    
        IF  par_vlprerpp <= 0                                        OR
            par_vlprerpp = craprpp.vlprerpp                          OR
            par_vlprerpp > ValorMaximoPrestacao(INPUT par_cdcooper)  THEN
            DO:
                ASSIGN aux_cdcritic = 208.
                LEAVE.
            END.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
                END.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**            Procedure para alterar dados da poupanca programada           **/
/******************************************************************************/
PROCEDURE alterar-poupanca-programada:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprerpp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlrppold AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        DO aux_contador = 1 TO 10:
    
            FIND craprpp WHERE craprpp.cdcooper = par_cdcooper AND 
                               craprpp.nrdconta = par_nrdconta AND
                               craprpp.nrctrrpp = par_nrctrrpp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
            IF  NOT AVAILABLE craprpp  THEN
                DO:
                    IF  LOCKED craprpp  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craprpp WHERE 
                                         craprpp.cdcooper = par_cdcooper AND
                                         craprpp.nrdconta = par_nrdconta AND
                                         craprpp.nrctrrpp = par_nrctrrpp 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(craprpp),
                                                      INPUT "banco",
                                                      INPUT "craprpp").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 495.
                END.
                    
            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        
        /* Se o lote for de hoje , entao alterar o valor dele tambem */
        DO aux_contador = 1 TO 10:
        
            FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                               craplot.dtmvtolt = craprpp.dtmvtolt   AND
                               craplot.dtmvtolt = par_dtmvtolt       AND
                               craplot.cdagenci = craprpp.cdagenci   AND
                               craplot.cdbccxlt = craprpp.cdbccxlt   AND
                               craplot.nrdolote = craprpp.nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF    NOT AVAIL craplot THEN
                  IF   LOCKED craplot   THEN
                       DO:
                           aux_cdcritic = 84.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.
    
        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        /* Se lote é de hoje entao atualizar valor */
        IF   AVAIL craplot   THEN
             ASSIGN craplot.vlcompcr = craplot.vlcompcr - craprpp.vlprerpp
                    craplot.vlcompcr = craplot.vlcompcr + par_vlprerpp

                    craplot.vlinfocr = craplot.vlinfocr - craprpp.vlprerpp
                    craplot.vlinfocr = craplot.vlinfocr + par_vlprerpp.
        
        /* Guardar valor anterior e Atualizar valor da Prestaçao */
        ASSIGN aux_vlrppold     = craprpp.vlprerpp
               craprpp.vlprerpp = par_vlprerpp
               craprpp.dtaltrpp = par_dtmvtolt.

        FIND CURRENT craprpp NO-LOCK NO-ERROR.
        
        FIND CURRENT craplot NO-LOCK NO-ERROR.


        ASSIGN par_nrdrowid = ROWID(craprpp)
                                                                        
               aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/

    IF  NOT aux_flgtrans  THEN
        DO: 

            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel alterar a poupanca.".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(par_nrctrrpp,
                                                               "zzz,zzz,zz9"))).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(par_nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Valor da Prestacao da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "vlprerpp",
                                     INPUT TRIM(STRING(aux_vlrppold,
                                                "zzz,zzz,zz9.99")),
                                     INPUT TRIM(STRING(par_vlprerpp,
                                                "zzz,zzz,zz9.99"))).
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**        Procedure que obtem dados para incluir poupanca programada        **/
/******************************************************************************/
PROCEDURE obtem-dados-inclusao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT-OUTPUT PARAM par_dtinirpp AS DATE                    NO-UNDO.
    DEF  OUTPUT PARAM par_dtmaxvct AS DATE                          NO-UNDO.
    DEF  OUTPUT PARAM par_tpemiext AS INTE                          NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.
    DEF VAR aux_pzmaxpro AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    IF par_dtinirpp = ? THEN
        ASSIGN par_dtinirpp = par_dtmvtolt.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados de poupanca para inclusao"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE
           par_tpemiext = 3.
          
           
    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
     
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 251.
                LEAVE.
            END.
     
        IF  CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))  THEN
            DO:
                ASSIGN aux_cdcritic = 695.
                LEAVE.
            END.
        
        IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
            DO:
                ASSIGN aux_cdcritic = 95.
                LEAVE.
            END.

        RUN sistema/generico/procedures/b1wgen0001.p 
            PERSISTENT SET h-b1wgen0001.

        IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0001.".
                LEAVE.
            END.
        
        RUN ver_capital IN h-b1wgen0001 (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 0,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdprogra,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro).
     
        DELETE PROCEDURE h-b1wgen0001.
    
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.
        
        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "GENERI"       AND
                           craptab.cdempres = 0              AND
                           craptab.tpregist = 2              AND 
                           craptab.cdacesso = "PZMAXPPROG"   NO-LOCK.
   
        IF AVAILABLE(craptab) THEN
                        ASSIGN aux_pzmaxpro = INTEGER(craptab.dstextab).
        ELSE
                ASSIGN aux_pzmaxpro = 0.

        ASSIGN par_dtmaxvct = 
                        ADD-INTERVAL(par_dtinirpp, aux_pzmaxpro, "MONTH").

        ASSIGN aux_flgerror = FALSE.
        
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
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
/**     Procedure para validar dados da poupanca programada para inclusao    **/
/******************************************************************************/
PROCEDURE validar-dados-inclusao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinirpp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_mesdtvct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_anodtvct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprerpp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpemiext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmcampos AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
    DEF VAR aux_pzminppr AS INTE                                    NO-UNDO.
    DEF VAR aux_pzmaxppr AS INTE                                    NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados para inclusao de poupanca"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.
           
    DO WHILE TRUE:

        IF  par_dtinirpp = ?                    OR
            par_dtinirpp > (par_dtmvtolt + 60)  OR
            par_dtinirpp < par_dtmvtolt         THEN
            DO:
                ASSIGN aux_cdcritic = 13
                       par_nmcampos = "dtinirpp".
                LEAVE.
            END.

        IF  par_mesdtvct < 1   OR
            par_mesdtvct > 12  THEN
            DO:
                ASSIGN aux_cdcritic = 13
                       par_nmcampos = "mesdtvct".
                LEAVE.
            END.

        IF  par_anodtvct = 0                   OR
            par_anodtvct < YEAR(par_dtinirpp)  THEN 
            DO:
                ASSIGN aux_cdcritic = 13
                       par_nmcampos = "anodtvct".
                LEAVE.
            END.
                        
        IF  par_tpemiext < 1   OR 
            par_tpemiext > 3   THEN
            DO:
                ASSIGN aux_cdcritic = 264
                par_nmcampos = "tpemiext".
                LEAVE.
            END.          

        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.tpregist = 2            AND
                           craptab.cdacesso = "PZMAXPPROG" NO-LOCK NO-ERROR.
   
        ASSIGN aux_pzmaxppr = IF  AVAILABLE craptab  THEN
                                  INTE(craptab.dstextab)
                              ELSE
                                  0.

        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.tpregist = 2            AND
                           craptab.cdacesso = "PZMINPPROG" NO-LOCK NO-ERROR.
   
        ASSIGN aux_pzminppr = IF  AVAILABLE craptab  THEN
                                  INTE(craptab.dstextab)
                              ELSE
                                  0.

        ASSIGN aux_nrdmeses = ((par_anodtvct -  YEAR(par_dtinirpp)) * 12) - 
                              ((par_mesdtvct - MONTH(par_dtinirpp)) * -1).
       
        IF  aux_nrdmeses > aux_pzmaxppr  OR
            aux_nrdmeses < aux_pzminppr  THEN 
            DO:
                ASSIGN aux_cdcritic = 916
                       par_nmcampos = "anodtvct".
                LEAVE.
            END.

        IF  par_vlprerpp <= 0                                        OR
            par_vlprerpp > ValorMaximoPrestacao(INPUT par_cdcooper)  THEN
            DO:
                ASSIGN aux_cdcritic = 208
                       par_nmcampos = "vlprerpp".
                LEAVE.
            END.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    /** Se alguma critica foi encontrada **/
    IF  aux_flgerror  THEN
        DO:
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
/**                Procedure para incluir poupanca programada                **/
/******************************************************************************/
PROCEDURE incluir-poupanca-programada:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinirpp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_mesdtvct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_anodtvct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprerpp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpemiext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nrdrowid AS ROWID                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.
    DEF VAR aux_nrrdcapp LIKE crapmat.nrrdcapp                      NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
           aux_dstransa = "Incluir poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE TRANS_POUP.
             END.

        /* Vamos buscar a proxima sequencia do campo crapmat.nrrdcapp */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                            ,INPUT "NRRDCAPP"
                                            ,INPUT STRING(par_cdcooper)
                                            ,INPUT "N"
                                            ,"").
       
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
        ASSIGN aux_nrrdcapp = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        DO aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                               craplot.dtmvtolt = par_dtmvtolt       AND
                               craplot.cdagenci = crapass.cdagenci   AND
                               craplot.cdbccxlt = 200                AND
                               craplot.nrdolote = 1537                                                         
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL craplot   THEN
                 DO:
                     IF   LOCKED craplot   THEN
                          DO:
                              IF   aux_contador = 10   THEN
                                   DO:
                                       FIND craplot WHERE 
                                            craplot.cdcooper = par_cdcooper       AND
                                            craplot.dtmvtolt = par_dtmvtolt       AND
                                            craplot.cdagenci = crapass.cdagenci   AND
                                            craplot.cdbccxlt = 200                AND
                                            craplot.nrdolote = 1537
                                            NO-LOCK NO-ERROR.

                                       RUN critica-lock (INPUT RECID(craplot),
                                                         INPUT "banco",
                                                         INPUT "craplot").
                                   END.
                              ELSE
                                   DO:
                                       PAUSE 1 NO-MESSAGE.
                                       NEXT.
                                   END.
                          END.
                     ELSE
                          DO:
                              CREATE craplot.
                              ASSIGN craplot.cdcooper = par_cdcooper
                                     craplot.dtmvtolt = par_dtmvtolt
                                     craplot.cdagenci = crapass.cdagenci
                                     craplot.cdbccxlt = 200
                                     craplot.nrdolote = 1537
                                     craplot.tplotmov = 14
                                     craplot.nrseqdig = 1
                                     craplot.tpdmoeda = 1
                                     craplot.flgltsis = TRUE.
                          END.
                 END.

            LEAVE.

        END.

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        ASSIGN aux_nrseqdig = 1.

        /* Controle da chave unica craprpp3 */
        FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper      AND
                               craprpp.dtmvtolt = par_dtmvtolt      AND
                               craprpp.cdagenci = craplot.cdagenci  AND
                               craprpp.cdbccxlt = craplot.cdbccxlt  AND
                               craprpp.nrdolote = 1537              NO-LOCK
                               BREAK BY craprpp.nrseqdig:

            IF   LAST-OF (craprpp.nrseqdig) THEN
                 ASSIGN aux_nrseqdig = craprpp.nrseqdig + 1.

        END.


        ASSIGN craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.vlcompcr = craplot.vlcompcr + par_vlprerpp
               craplot.vlinfocr = craplot.vlinfocr + par_vlprerpp.

        VALIDATE craplot.

        CREATE craprpp.

        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        ASSIGN craprpp.cdcooper = par_cdcooper
               craprpp.cdageass = crapass.cdagenci
               craprpp.cdagenci = craplot.cdagenci
               craprpp.cdbccxlt = craplot.cdbccxlt
               craprpp.cdsecext = crapass.cdsecext
               craprpp.cdsitrpp = 1
               craprpp.dtaltrpp = ?
               craprpp.dtcalcul = ?
               craprpp.dtrnirpp = ?
               craprpp.tpemiext = par_tpemiext  
               craprpp.dtdebito = par_dtinirpp                
               craprpp.dtiniper = par_dtinirpp
               craprpp.dtiniext = par_dtinirpp
               craprpp.dtfimext = par_dtinirpp 
               craprpp.dtsdppan = par_dtinirpp
               craprpp.dtsppant = par_dtinirpp
               craprpp.dtsppext = par_dtinirpp 
                       
               craprpp.dtinirpp = par_dtinirpp
               craprpp.dtvctopp = DATE(par_mesdtvct,
                                       DAY(par_dtinirpp),
                                       par_anodtvct)
            
               craprpp.dtmvtolt = par_dtmvtolt 
               craprpp.nrctrrpp = aux_nrrdcapp
               craprpp.flgctain = TRUE
               craprpp.nrdconta = par_nrdconta
               craprpp.nrdolote = craplot.nrdolote
               craprpp.nrseqdig = aux_nrseqdig
               craprpp.vlprerpp = par_vlprerpp
               craprpp.dtimpcrt = ?
              /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craprpp.cdopeori = par_cdoperad
               craprpp.cdageori = par_cdagenci
               craprpp.dtinsori = TODAY
              /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craprpp.indebito = 0.

        ASSIGN craprpp.dtfimper = IF   MONTH(par_dtinirpp) = 12 THEN
                                       DATE(1,DAY(par_dtinirpp),
                                       YEAR(par_dtinirpp) + 1)
                                  ELSE
                                       DATE(MONTH(par_dtinirpp) + 1,
                                            DAY(par_dtinirpp),
                                            YEAR(par_dtinirpp)) NO-ERROR. 
    
        IF   ERROR-STATUS:ERROR   THEN
             IF   MONTH(par_dtinirpp) = 11 THEN  
                  craprpp.dtfimper = DATE(1, 1,(YEAR(par_dtinirpp) + 1)).
             ELSE
             IF   MONTH(par_dtinirpp) = 12 THEN
                  craprpp.dtfimper = DATE(2, 1,(YEAR(par_dtinirpp) + 1)).
             ELSE
                  craprpp.dtfimper = DATE((MONTH(par_dtinirpp) + 2), 1, 
                                        YEAR(par_dtinirpp)).
                                            
        /* Saldo da Aplicacao */
        CREATE crapspp.
        ASSIGN crapspp.cdcooper = par_cdcooper
               crapspp.nrdconta = par_nrdconta
               crapspp.nrctrrpp = craprpp.nrctrrpp
               crapspp.dtsldrpp = craprpp.dtdebito
               crapspp.vlsldrpp = 0
               crapspp.dtmvtolt = par_dtmvtolt.

        VALIDATE craprpp.
        VALIDATE crapspp.

        FIND CURRENT craplot NO-LOCK NO-ERROR.
        FIND CURRENT craprpp NO-LOCK NO-ERROR.
        FIND CURRENT crapspp NO-LOCK NO-ERROR.

        ASSIGN par_nrdrowid = ROWID(craprpp)
               aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/

    IF  NOT aux_flgtrans  THEN
        DO: 
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel incluir a poupanca.".
                    
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(craprpp.nrctrrpp,
                                                       "zzz,zzz,zz9"))).

            /** Data de Inicio da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtinirpp",
                                     INPUT "",
                                     INPUT STRING(craprpp.dtinirpp,
                                                  "99/99/9999")).

            /** Valor da Prestacao da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "vlprerpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(craprpp.vlprerpp,
                                                "zzz,zzz,zz9.99"))).

            /** Data de Vencimento da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "dtvctopp",
                                     INPUT "",
                                     INPUT STRING(craprpp.dtvctopp,
                                                  "99/99/9999")).
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE ver-valores-bloqueados-poup:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlresgat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
        
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_ver_val_bloqueio_poup
       aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_dtmvtolt,
                           INPUT par_dtmvtopr,
                           INPUT par_inproces,
                           INPUT par_cdprogra,
                           INPUT par_vlresgat,
                           INPUT IF par_flgerlog THEN 1 ELSE 0 ,
                           OUTPUT 0,
                           OUTPUT "").

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_ver_val_bloqueio_poup
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_ver_val_bloqueio_poup.pr_cdcritic 
                          WHEN pc_ver_val_bloqueio_poup.pr_cdcritic <> ?
           aux_dscritic = pc_ver_val_bloqueio_poup.pr_dscritic 
                          WHEN pc_ver_val_bloqueio_poup.pr_dscritic <> ?.
    
   IF aux_cdcritic <> 0 OR
     aux_dscritic <> "" THEN
             DO:
          CREATE tt-erro.
          ASSIGN tt-erro.cdcritic = aux_cdcritic
                 tt-erro.dscritic = aux_dscritic.
                            
             RETURN "NOK".               
         END.

   RETURN "OK".
   
END.






/******************************************************************************/
/**      Procedure para impressao de autorizacao da poupanca programada      **/
/******************************************************************************/
PROCEDURE obtem-dados-autorizacao:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdtiparq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-autoriza-rpp.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_txaplica AS DECI                                    NO-UNDO.
    DEF VAR aux_vlprerpp AS DECI                                    NO-UNDO.

    DEF VAR aux_nrctrrpp AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdiargt AS INTE                                    NO-UNDO.

    DEF VAR aux_dtvctopp AS DATE                                    NO-UNDO.
    DEF VAR aux_dtdebito AS DATE                                    NO-UNDO.

    DEF VAR aux_nmextcop AS CHAR EXTENT 2                           NO-UNDO.
    DEF VAR aux_dsprerpp AS CHAR EXTENT 2                           NO-UNDO.
    DEF VAR aux_nmmesano AS CHAR EXTENT 12 
                         INIT ["JANEIRO","FEVEREIRO","MARCO",
                               "ABRIL","MAIO","JUNHO",
                               "JULHO","AGOSTO","SETEMBRO",
                               "OUTUBRO","NOVEMBRO","DEZEMBRO"]     NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    
    EMPTY TEMP-TABLE tt-autoriza-rpp.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Imprimir autorizacao da poupanca programada"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_POUP:

    DO TRANSACTION ON ERROR  UNDO TRANS_POUP, LEAVE TRANS_POUP 
                   ON ENDKEY UNDO TRANS_POUP, LEAVE TRANS_POUP:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                   
        IF  NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.
        
        DO aux_contador = 1 TO 10:
    
            FIND craprpp WHERE ROWID(craprpp) = par_nrdrowid
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE craprpp  THEN
                DO:
                    IF  LOCKED craprpp  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND craprpp WHERE 
                                         ROWID(craprpp) = par_nrdrowid
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock 
                                       (INPUT RECID(craprpp),
                                        INPUT "banco",
                                        INPUT "craprpp").
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic= 495.
                END.
            ELSE
                ASSIGN aux_nrctrrpp = craprpp.nrctrrpp
                       aux_vlprerpp = craprpp.vlprerpp
                       aux_dtvctopp = craprpp.dtvctopp
                       aux_dtdebito = craprpp.dtdebito.
                                       
            LEAVE.
    
        END. /** Fim do DO ... TO **/
      

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
            SET h-b1wgen9999.
            
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                       
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        RUN valor-extenso IN h-b1wgen9999 (INPUT aux_vlprerpp, 
                                           INPUT 60, 
                                           INPUT 60, 
                                           INPUT "M",
                                          OUTPUT aux_dsprerpp[1], 
                                          OUTPUT aux_dsprerpp[2]).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
        
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = aux_dsprerpp[1].
               
                UNDO TRANS_POUP, LEAVE TRANS_POUP.       
            END.

        RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                             OUTPUT aux_nmextcop[1],
                                             OUTPUT aux_nmextcop[2]).

        DELETE PROCEDURE h-b1wgen9999.

        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "CONFIG"     AND
                           craptab.cdacesso = "TXADIAPLIC" AND
                           craptab.tpregist = 2            NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE craptab  THEN
            DO:
                ASSIGN aux_cdcritic = 347
                       aux_dscritic = "".
                 
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        ASSIGN aux_txaplica = DECI(ENTRY(2,craptab.dstextab,"#")).

        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "USUARI"     AND
                           craptab.cdempres = 11           AND
                           craptab.cdacesso = "DIARESGATE" AND
                           craptab.tpregist = 1            NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE craptab  THEN
            ASSIGN aux_nrdiargt = 0.
        ELSE
            ASSIGN aux_nrdiargt = INTE(craptab.dstextab).

        CREATE tt-autoriza-rpp.
        ASSIGN tt-autoriza-rpp.nmextcop = crapcop.nmextcop
               tt-autoriza-rpp.nmrescop = crapcop.nmrescop
               tt-autoriza-rpp.nmexcop1 = aux_nmextcop[1] 
               tt-autoriza-rpp.nmexcop2 = aux_nmextcop[2]
               tt-autoriza-rpp.nmcidade = crapcop.nmcidade
               tt-autoriza-rpp.cdufdcop = crapcop.cdufdcop
               tt-autoriza-rpp.nrdocnpj = STRING(STRING(crapcop.nrdocnpj,
                                        "99999999999999"),"xx.xxx.xxx/xxxx-xx")
               tt-autoriza-rpp.nrdconta = crapass.nrdconta
               tt-autoriza-rpp.nmprimtl = crapass.nmprimtl
               tt-autoriza-rpp.nrctrrpp = aux_nrctrrpp
               tt-autoriza-rpp.vlprerpp = aux_vlprerpp
               tt-autoriza-rpp.dsprerpp = aux_dsprerpp[1]
               tt-autoriza-rpp.dtvctopp = aux_dtvctopp
               tt-autoriza-rpp.ddaniver = STRING(DAY(aux_dtdebito),"99")
               tt-autoriza-rpp.dsmesano = aux_nmmesano[MONTH(aux_dtdebito)]
               tt-autoriza-rpp.nranoini = STRING(YEAR(aux_dtdebito),"9999")
               tt-autoriza-rpp.nrdiargt = aux_nrdiargt 
               tt-autoriza-rpp.txaplica = aux_txaplica
               tt-autoriza-rpp.dtmvtolt = par_dtmvtolt
                
               /* Se tiver alteraçao mostra paragrafo que trata sobre isso */ 
               tt-autoriza-rpp.flgsubst = (craprpp.dtaltrpp <> ?). 

        ASSIGN craprpp.dtimpcrt = par_dtmvtolt.

        FIND CURRENT craprpp NO-LOCK NO-ERROR.
        
        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_POUP **/

    IF  NOT aux_flgtrans  THEN
        DO: 
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel imprimir a " + 
                                      "autorizacao.".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

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

                    /** Numero de Contrato da Poupanca **/
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrctrrpp",
                                             INPUT "",
                                             INPUT TRIM(STRING(aux_nrctrrpp,
                                                        "zzz,zzz,zz9"))).
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

            /** Numero de Contrato da Poupanca **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrrpp",
                                     INPUT "",
                                     INPUT TRIM(STRING(aux_nrctrrpp,
                                                       "zzz,zzz,zz9"))).
        END.

    RETURN "OK".

END PROCEDURE.

              
/******************************************************************************/
/**         Procedure para gerar saldo anterior ao periodo informado         **/
/******************************************************************************/
PROCEDURE gera-saldo-anterior:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlsldrpp AS DECI                           NO-UNDO.
    
    FIND LAST crapspp WHERE crapspp.cdcooper  = par_cdcooper AND
                            crapspp.nrdconta  = par_nrdconta AND
                            crapspp.nrctrrpp  = par_nrctrrpp AND
                            crapspp.dtsldrpp <= par_dtiniper NO-LOCK NO-ERROR.

    IF  AVAILABLE crapspp  THEN
        ASSIGN par_dtrefere = crapspp.dtsldrpp
               par_vlsldrpp = crapspp.vlsldrpp.
    ELSE 
        DO: 
            FIND FIRST crapspp WHERE crapspp.cdcooper = par_cdcooper AND
                                     crapspp.nrdconta = par_nrdconta AND
                                     crapspp.nrctrrpp = par_nrctrrpp AND
                                     crapspp.dtsldrpp > par_dtiniper
                                     NO-LOCK NO-ERROR.
              
            IF  AVAILABLE crapspp  THEN
                ASSIGN par_dtrefere = crapspp.dtsldrpp
                       par_vlsldrpp = crapspp.vlsldrpp.
        END.
    
    RETURN "OK".        

END PROCEDURE.


/******************************************************************************/
/**         Procedure para gerar saldo atual da poupanca programada          **/
/******************************************************************************/
PROCEDURE gera-saldo-atual:
 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_vlsldrpp AS DECI                           NO-UNDO.
    
    DEF VAR aux_dtiniper AS DATE                                    NO-UNDO.
    
    FIND LAST crapspp WHERE crapspp.cdcooper  = par_cdcooper AND
                            crapspp.nrdconta  = par_nrdconta AND
                            crapspp.nrctrrpp  = par_nrctrrpp AND
                            crapspp.dtsldrpp <= par_dtfimper NO-LOCK NO-ERROR.
      
    IF  AVAILABLE crapspp  THEN
        ASSIGN par_vlsldrpp = crapspp.vlsldrpp
               aux_dtiniper = crapspp.dtsldrpp.
    
    FOR EACH craplpp WHERE craplpp.cdcooper  = par_cdcooper AND
                           craplpp.nrdconta  = par_nrdconta AND
                           craplpp.nrctrrpp  = par_nrctrrpp AND
                           craplpp.dtmvtolt >= aux_dtiniper AND  
                           craplpp.dtmvtolt <= par_dtfimper NO-LOCK:
    
        IF  craplpp.dtmvtolt = aux_dtiniper  AND
           (craplpp.cdhistor = 151           OR 
            craplpp.cdhistor = 152           OR
            craplpp.cdhistor = 154           OR
            craplpp.cdhistor = 155           OR
            craplpp.cdhistor = 863           OR
            craplpp.cdhistor = 869           OR
            craplpp.cdhistor = 870)          THEN
            NEXT.                            
        ELSE    
        IF  CAN-DO("152,154,155,869",STRING(craplpp.cdhistor))  THEN
            NEXT.
       
        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplpp.cdhistor NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE craphis  THEN
            DO:
                ASSIGN aux_cdcritic = 80 
                       aux_dscritic = "".
               
                RETURN "NOK".
            END.

        IF  craphis.indebcre = "C"  THEN
            ASSIGN par_vlsldrpp = par_vlsldrpp + craplpp.vllanmto.
        ELSE
        IF  craphis.indebcre = "D"  THEN
            ASSIGN par_vlsldrpp = par_vlsldrpp - craplpp.vllanmto.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 83 
                       aux_dscritic = "".
               
                RETURN "NOK".
            END.
    
    END. /** Fim do FOR EACH craplpp **/
          
    RETURN "OK".
    
END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


PROCEDURE critica-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "Registro sendo alterado em outro terminal (" + 
                          par_nmtabela + ").".

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT par_nrdrecid,
                                   INPUT par_nmdbanco,
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN aux_dscritic = aux_dscritic + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN "OK".

END PROCEDURE.




/*................................. FUNCTIONS ................................*/


FUNCTION ValorMaximoPrestacao RETURNS DECI (INPUT par_cdcooper AS INTE):

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "VLMAXPPROG" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
                     
    RETURN IF AVAILABLE craptab THEN DECI(craptab.dstextab) ELSE 0.

END FUNCTION.


/*............................................................................*/

