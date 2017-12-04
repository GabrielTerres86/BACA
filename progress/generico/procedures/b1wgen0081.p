/******************************************************************************
                ATENCAO!    CONVERSAO PROGRESS - ORACLE
           ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
 +--------------------------------------+-----------------------------------------+
 | Rotina Progress                      | Rotina Oracle PLSQL                     |
 +--------------------------------------+-----------------------------------------+
 | b1wgen0081.p                         | APLI0002                                |
 | obtem-dias-carencia                  | APLI0002.pc_obtem_dias_carencia         |
 | validar-tipo-aplicacao               | APLI0002.pc_validar_tipo_aplicacao      |
 | calcula-permanencia-resgate          | APLI0002.pc_calcula_permanencia_resgate | 
 | obtem-taxa-aplicacao                 | APLI0002.pc_obtem_taxa_aplicacao        |
 | validar-nova-aplicacao               | APLI0002.pc_validar_nova_aplicacao      |
 | incluir-nova-aplicacao               | APLI0002.pc_incluir_nova_aplicacao      |
 | excluir-nova-aplicacao               | APLI0002.pc_excluir_nova_aplicacao      |
 | simular-saldo-acumulado              | APLI0002.pc_simular_saldo_acumulado     |
 | consultar-saldo-acumulado            | APLI0002.pc_consultar_saldo_acumul      |
 | cadastrar-resgate-aplicacao          | APLI0002.pc_cad_resgate_aplica          |
 | efetua-resgate-online                | APLI0002.pc_efetua_resgate_online       |  
 | obtem-dados-aplicacoes               | APLI0002.pc_obtem_dados_aplicacoes      |
 | consulta-extrato-rdca                | EXTR0002.pc_consulta_extrato_rdca       |
 | valida-acesso-opcao-resgate          | APLI0002.pc_valid_acesso_opcao_resg     |
 | filtra-aplicacoes-resgate-automatico | APLI0002.pc_filtra_aplic_resg_auto      |
 | filtra-aplicacoes-resgate-manual     | APLI0002.pc_filtra_aplic_resg_manu      |  
 | ver-valores-bloqueados-judicial      | APLI0002.pc_ver_valor_blq_judicial      |
 | obtem-resgates-aplicacao             | APLI0002.pc_obtem_resgates_aplicacao    |
 | calcula-saldo-resgate-varias         | APLI0005.pc_calc_sld_resg_varias        |
 | retorna-aplicacoes-resgate-automatico| APLI0005.pc_ret_apl_resg_aut            |
 | retorna-aplicacoes-resgate-manual    | APLI0005.pc_ret_apl_resg_manu           |
 | obtem-resgates-conta                 | APLI0005.pc_obtem_resgates_conta        |
 +--------------------------------------+-----------------------------------------+

 TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 08/05/2014 DEVERA
 SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

 PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
 PESSOAS:
  - GUILHERME STRUBE    (CECRED)
  - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: b1wgen0081.p                  
   Autora  : Adriano.
   Data    : 29/11/2010                        Ultima atualizacao: 30/11/2017

   Dados referentes ao programa:

   Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
               Baseada no programa fontes/impextrda.p.

   Alteracoes:  13/12/2010 - Incluido controle de saldo disponivel para resgate 
                             parcial e total (Henrique).
   
                21/12/2010 - Incluir his 923 e 924, sobreposicao (Magui).
                
                20/05/2011 - Nao encontrando craplap, ler com first. Antes
                             eles eram eliminados (Magui).
                             
                01/08/2011 - Alterado condição na consulta-extrato-rdca para
                             retornar dados corretamente para tela "EXTRDA".
                             Carregar dshistoi na tt-extr-rdca.(Gabriel - DB1)
                             
                11/08/2011 - Criado proc. obtem-resgates-conta. (Jorge)
                
                12/08/2011 - Adicionado procedure calcula-saldo-resgate-varias.
                             (Fabricio)
                             
                15/08/2011 - Criado proc. cancelar-varias-resgates-aplicacao.
                             (Jorge).
                             
                15/08/2011 - Criado procedure 
                             retorna-aplicacoes-resgate-automatico e
                             filtra-aplicacoes-resgate-automatico. (Fabricio)
                             
                08/09/2011 - Carregado o campo tpaplrdc na tt-extr-rdca,
                             Procedure consulta-extrato-rdca. (Gabriel - DB1)
                             
                13/09/2011 - Acrescentado nome da tela EXTRDA como condição na
                             Procedure consulta-extrato-rdca. (Rogerius - DB1)

                26/10/2011 - Ajuste no controle de aplicacoes convertidas da 
                             Cecrisacred na consulta de extrato (David).

                23/12/2011 - Retirar Warnings (Gabriel).             

                08/02/2012 - Incluir historicos para extrato via IMPRES (David)

                09/04/2012 - Ajuste para impressao do extrato. (Utilizar 
                             variavel aux_lsoperad). (Irlan)

                18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                             R$ 1,00 (Ze).

                18/09/2012 - Novos parametros DATA na chamada da procedure
                             obtem-dados-aplicacoes (Guilherme/Supero).
                             
                01/10/2012 - Alimentado campo tt-extr-rdca.dsextrat em procedure
                             consulta-extrato-rdca. (Jorge)
                             
                11/12/2012 - Incluir historicos de migracao (Ze).
                             
                06/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
                
                23/08/2013 - Implementação novos produtos Aplicação (Lucas).
                
                16/09/2013 - Tratamento para Imunidade Tributaria (Ze).
                
                24/10/2013 - Ajuste log agendamento resgate (David).
                
                17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                04/06/2014 - Ajustes realizados referente ao projeto de 
                             captacao (Adriano).
                             
                16/07/2014 - Corrigido regra imunidade tributaria na
                             procedure consulta-extrato-rdca (Daniel).
                
                24/07/2014 - Incluido leitura na crapcpc/crapmpc/crapdtc na
                             procedure obtem-tipos-aplicacao para o projeto
                             de captacao (Jean Michel).
                             
                07/10/2014 - Inclusao da chamada para PLSQL da procedure
                             convertida obtem-resgates-aplicacao.(Jean Michel) 
                 
                21/08/2014 - Incluido as procedures consulta-agendamento e
                             incluir-novo-agendamento (Tiago/Gielow).
                             
                12/09/2014 - Incluido a procedure atualiza-status-agendmto
                             (Tiago/Gielow).
                             
                           - Alterado a procedure cadastrar-resgate-aplicacao
                             para chamar a procedure convertida no Oracle.
                             (Douglas - Projeto Captação Internet 2014/2)
                
                19/09/2014 - Incluido a procedure busca-intervalo-dias
                             (Douglas - Projeto Captação Internet 2014/2)

                02/10/2014 - Alterado para chamar o altera_session_depois sempre que
                             chamar as procedures no oracle e não apenas quando retornar erro
                             (Douglas - Projeto Captação Internet 2014/2)
                             
                06/10/2014 - Incluido a procedure busca-proxima-data-movimento
                             (Tiago - Projeto Captação Internet 2014/2)
                             
                06/10/2014 - Conversão da procedure obtem-resgates-aplicacao
                             para pc_obtem_resgates_aplicacao (Jean Michel)
                                                                                                                 
                16/10/2014 - Adicionar parametro id origem na procedure 
                             validar-novo-agendamento
                             (Douglas - Projeto Captação Internet 2014/2)
                             
                29/10/2014 - Limpar tt-msg-confirma e tt-erro  na procedure
                             cadastrar-resgate-aplicacao
                             (Douglas - Projeto Captação Internet 2014/2)
                             
                06/11/2014 - Conversão calcula-saldo-resgate-varias para
                             APLI0005.pc_calc_sld_resg_varias (Jean Michel).
                             
                06/11/2014 - Conversão retorna-aplicacoes-resgate-automatico
                             APLI0005.pc_ret_apl_resg_aut (Jean Michel).                           
                
                13/11/2014 - Ajuste para qdo chamar pc_cons_mes_age passar
                             cdagenci como pa 90 internet (Tiago).   
                             
                17/11/2014 - Efetuado ajuste nas procedures abaixo para incluir
                             tramtamento de no-error nos comandos de XML e
                             desprezados tags vazias ou com erros.            
                             - consulta-agendamento
                             - consulta-agendamento-det (Adriano).
                             
                05/12/2014 - Retirado calcula-saldo-resgate-varias, chamada
                             sera feito somente via OCI (Jean Michel).
                             
                08/12/2014 - Retirado retorna-aplicacoes-resgate-automatico,
                             chamada sera feito somente via OCI (Jean Michel). 
                             
                09/12/2014 - Ajustado a procedure retorna-aplicacoes-resgate-manual
                             para listar as novas aplicacoes (Jean Michel).                         
                 
                26/01/2015 - Validacao de historicos na procedure
                             obtem-tipos-aplicacao(Jean Michel).
                             
                03/03/2015 - Conversao e retirada da procedure obtem-resgates-conta
                             (Jean Michel).
                             
                25/05/2015 - Incluido o BY crapdtc.tpaplica DESC na procedure
                             obtem-tipos-aplicacao (Jean Michel)      
							 
				       07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)
                             
               08/02/2016 - P341-Automatização BACENJUD - Ajuste da liberacao anterior (Andrino - Mouts)
               
               07/03/2017 - Ajuste no comando can-do realizado na variavel aux_lsoperad. Estava pesquisando
                            por ",<Departamento>," quando na verdade deveria pesquisar apenas por "<Departamento>"
                            Heitor (Mouts) - Chamado 606151

			  25/09/2017 - Inclusao do departamento 14 - Produtos, na listagem do Demonstrativo de aplicacoes
						   procedure consulta-extrato-rdca. SD 759762. (Carlos Rafael Tanholi)
               
                            
               30/11/2017 - Removido rotina ver-valores-bloqueados-judicial,
                            pois foi convertida e nao é mais utilizada.
                            PRJ404-Garantia(Odirlei-AMcom)             
............................................................................*/
 
 { sistema/generico/includes/b1wgen0001tt.i }
 { sistema/generico/includes/b1wgen0081tt.i }
 { sistema/generico/includes/b1wgen0004tt.i }
 { sistema/generico/includes/b1wgen0006tt.i }
 { sistema/generico/includes/var_internet.i }
 { sistema/generico/includes/gera_erro.i }
 { sistema/generico/includes/gera_log.i }
 { sistema/generico/includes/var_oracle.i } 
 
 
DEF VAR aux_sldresga AS DECIMAL                               NO-UNDO. 
DEF VAR tot_sldresga AS DECIMAL                               NO-UNDO. 
DEF VAR aux_vlrenrgt AS DECIMAL DECIMALS 8      
    /*  like craprda.vlsdrdca Magui em 27/09/2007 */          NO-UNDO. 
DEF VAR aux_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF VAR aux_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF VAR aux_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF VAR aux_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF VAR aux_vlrdirrf AS DECIMAL                               NO-UNDO.
DEF VAR aux_perirrgt AS DECIMAL                               NO-UNDO.
DEF VAR aux_vlrrgtot AS DECIMAL                               NO-UNDO.
DEF VAR aux_vlirftot AS DECIMAL                               NO-UNDO.
DEF VAR aux_vlrendmm AS DECIMAL                               NO-UNDO.
DEF VAR aux_vlrvtfim AS DECIMAL                               NO-UNDO. 
DEF VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                  NO-UNDO. 
DEF VAR aux_dtrefere AS DATE                                  NO-UNDO. 
DEF VAR aux_nrdolote AS INT                                   NO-UNDO. 
DEF VAR aux_vlsldapl AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF VAR aux_sldpresg AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF VAR aux_vlsldrdc AS DECI                                  NO-UNDO.
DEF VAR aux_lsoperad AS CHAR                                  NO-UNDO.
DEF VAR aux_lsopera2 AS CHAR                                  NO-UNDO.
DEF VAR aux_listahis AS CHAR                                  NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                  NO-UNDO.
DEF VAR aux_vlstotal AS DECIMAL                               NO-UNDO.
DEF VAR aux_dsaplica AS CHAR                                  NO-UNDO. 
DEF VAR aux_nmprdcom AS CHAR                                  NO-UNDO.
DEF VAR aux_vlrenacu AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF VAR aux_vlslajir AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF VAR aux_pcajsren AS DECIMAL                               NO-UNDO.
DEF VAR aux_nrmeses  AS INTEGER                               NO-UNDO.
DEF VAR aux_nrdias   AS INTEGER                               NO-UNDO.
DEF VAR aux_perirapl AS DECIMAL                               NO-UNDO.
DEF VAR aux_vlrenreg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF VAR aux_dtiniapl AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF VAR aux_cdhisren LIKE craplap.cdhistor                    NO-UNDO.
DEF VAR aux_cdhisajt LIKE craplap.cdhistor                    NO-UNDO.
DEF VAR aux_vldajtir AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF VAR aux_sldrgttt AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF VAR aux_saldomes AS DECIMAL EXTENT 14                     NO-UNDO.
DEF VAR tot_saldomes AS DECIMAL EXTENT 14                     NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                  NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                  NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                  NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                 NO-UNDO.

DEF STREAM str_1.


DEF VAR h-b1wgen0004 AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0159 AS HANDLE                                NO-UNDO.


/** Tabelas para registro de log **/
DEF TEMP-TABLE tt-aplicacao-ant NO-UNDO
    FIELD cdagenci LIKE craprda.cdagenci
    FIELD cdbccxlt LIKE craprda.cdbccxlt
    FIELD nrdolote LIKE craprda.nrdolote
    FIELD nrseqdig LIKE craplap.nrseqdig
    FIELD tpaplica LIKE craprda.tpaplica
    FIELD nraplica LIKE craprda.nraplica
    FIELD vlaplica LIKE craprda.vlaplica
    FIELD qtdiaapl LIKE craprda.qtdiaapl
    FIELD dtvencto LIKE craprda.dtvencto
    FIELD qtdiauti LIKE craprda.qtdiauti
    FIELD txaplica LIKE craplap.txaplica
    FIELD txaplmes LIKE craplap.txaplmes
    FIELD flgdebci LIKE craprda.flgdebci.

DEF TEMP-TABLE tt-aplicacao-new NO-UNDO LIKE tt-aplicacao-ant.

/* DEF BUFFER bt-saldo-demonst  FOR tt-demonstrativo. */

/******************************************************************************/
/**               Procedure para cancelar regates de aplicacao               **/
/******************************************************************************/
PROCEDURE cancelar-varias-resgates-aplicacao:
    
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
    DEF  INPUT PARAM TABLE FOR tt-resg-aplica.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_nraplica AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                                    NO-UNDO.
    DEF VAR aux_dtresgat AS DATE                                    NO-UNDO.

    ASSIGN aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
       FOR EACH tt-resg-aplica NO-LOCK:
           
           IF tt-resg-aplica.idtipapl = "A" THEN
                DO:    
                    RUN cancelar-resgates-aplicacao(INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_idorigem,
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT tt-resg-aplica.nraplica,
                                                    INPUT tt-resg-aplica.nrdocmto,
                                                    INPUT tt-resg-aplica.dtresgat,
                                                    INPUT par_dtmvtolt,
                                                    INPUT TRUE,
                                                   OUTPUT TABLE tt-erro).
                    
                    IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           ASSIGN aux_nraplica = tt-resg-aplica.nraplica
                                  aux_nrdocmto = tt-resg-aplica.nrdocmto
                                  aux_dtresgat = tt-resg-aplica.dtresgat.
        
                           UNDO TRANSACAO, LEAVE TRANSACAO.
                       END.
                END.
           ELSE
                DO:
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
                    /* Efetuar a chamada a rotina Oracle */ 
                    RUN STORED-PROCEDURE pc_cancela_resgate
                       aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,            /* Codigo da Cooperativa */
                                                           INPUT par_cdagenci,            /* Codigo do PA */
                                                           INPUT par_nrdcaixa,            /* Numero do caixa */
                                                           INPUT par_cdoperad,            /* Codigo do operador */
                                                           INPUT par_nmdatela,            /* Nome da tela */
                                                           INPUT par_idorigem,            /* Identificador de sistema de origem */
                                                           INPUT par_nrdconta,            /* Numero da conta */
                                                           INPUT par_idseqttl,            /* Sequencia do titular */
                                                           INPUT tt-resg-aplica.nraplica, /* Numero da aplicacao */
                                                           INPUT tt-resg-aplica.nrdocmto, /* Numero do documento */
                                                           INPUT tt-resg-aplica.dtresgat, /* Data de resgate */
                                                           INPUT par_dtmvtolt,            /* Data de movimento atual */
                                                           INPUT 1,                       /* Flag para gerar log */
                                                          OUTPUT pr_cdcritic,             /* Codigo da critica */
                                                          OUTPUT pr_dscritic).            /* Descricao da critica */  
                    
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_cancela_resgate
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                    
                    /* Busca possíveis erros */ 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_cancela_resgate.pr_cdcritic 
                                          WHEN pc_cancela_resgate.pr_cdcritic <> ?
                           aux_dscritic = pc_cancela_resgate.pr_dscritic 
                                          WHEN pc_cancela_resgate.pr_dscritic <> ?.
                    IF aux_cdcritic <> 0 AND
                       aux_dscritic <> ? THEN

                        DO:
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,          /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                      
                END.
       END. /* FIM FOR EACH */

           ASSIGN aux_flgtrans = TRUE.
    
    END. /* FIM TRANSACAO */

    IF NOT aux_flgtrans THEN
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
                                            INPUT TRIM(STRING(aux_nraplica,
                                                       "zzz,zzz,zzz"))).

                   RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                            INPUT "dtresgat",
                                            INPUT "",
                                            INPUT STRING(aux_dtresgat,
                                                         "99/99/9999")).
                   RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                            INPUT "nrdocmto",
                                            INPUT "",
                                            INPUT TRIM(STRING(aux_nrdocmto,
                                                       "zzz,zzz,zzz,zzz"))).
               END.

           RETURN "NOK".        
           END.
   
   RETURN "OK".

END PROCEDURE. 

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
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_vlsldapl AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-saldo-rdca.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-saldo-rdca.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    IF  par_flgerlog  THEN
        ASSIGN aux_dstransa = "Leitura de aplicacoes RDCA e RDC".
    
    RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT SET h-b1wgen0004.
    
    RUN consulta-aplicacoes IN h-b1wgen0004 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nrdconta,
                                             INPUT par_nraplica,
                                             INPUT 0,  
                                             INPUT par_dtiniper,
                                             INPUT par_dtfimper,
                                             INPUT par_cdprogra,
                                             INPUT par_idorigem,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-saldo-rdca).

    DELETE PROCEDURE h-b1wgen0004.

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
                        
        ASSIGN par_vlsldapl = par_vlsldapl + tt-saldo-rdca.sldresga.

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

PROCEDURE filtra-aplicacoes-resgate-automatico:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-saldo-rdca.
    DEF INPUT PARAM par_tpaplica AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtresgat AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-resgate.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-resposta-cliente.
    DEF INPUT-OUTPUT PARAM par_vltotrgt AS DECI NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_tpresgat AS CHAR  NO-UNDO.
    DEF VAR aux_vlresgat AS DECI  NO-UNDO.

    FIND LAST tt-resposta-cliente NO-LOCK NO-ERROR.
    
    IF AVAIL tt-resposta-cliente THEN
        IF tt-resposta-cliente.resposta = "SIM" THEN
        DO:
            FIND tt-dados-resgate WHERE tt-dados-resgate.nraplica = 
                                        tt-resposta-cliente.nraplica 
                                        NO-LOCK NO-ERROR.

            IF NOT AVAIL tt-dados-resgate THEN
            DO:    
                FIND tt-saldo-rdca WHERE tt-saldo-rdca.nraplica = 
                                         tt-resposta-cliente.nraplica 
                                                        NO-LOCK NO-ERROR.

                IF (par_vltotrgt >= tt-saldo-rdca.sldresga) THEN
                    ASSIGN aux_vlresgat = tt-saldo-rdca.sldresga
                           par_vltotrgt = par_vltotrgt - aux_vlresgat
                           aux_tpresgat = "T".
                ELSE
                    ASSIGN aux_vlresgat = par_vltotrgt
                           aux_tpresgat = "P"
                           par_vltotrgt = 0.

                CREATE tt-dados-resgate.
                ASSIGN tt-dados-resgate.nraplica = tt-saldo-rdca.nraplica
                       tt-dados-resgate.dtmvtolt = tt-saldo-rdca.dtmvtolt
                       tt-dados-resgate.dshistor = tt-saldo-rdca.dshistor
                       tt-dados-resgate.nrdocmto = tt-saldo-rdca.nrdocmto
                       tt-dados-resgate.dtvencto = tt-saldo-rdca.dtvencto
                       tt-dados-resgate.sldresga = tt-saldo-rdca.sldresga
                       tt-dados-resgate.vlresgat = aux_vlresgat
                       tt-dados-resgate.tpresgat = aux_tpresgat.
            END.

        END.
    
    FOR EACH tt-saldo-rdca WHERE tt-saldo-rdca.tpaplica = par_tpaplica
                             AND tt-saldo-rdca.dtmvtolt < par_dtmvtolt
                             AND tt-saldo-rdca.sldresga > 0
                             AND (tt-saldo-rdca.dssitapl = "DISPONIVEL"
                              OR tt-saldo-rdca.dssitapl = "")
                             NO-LOCK
                             BY tt-saldo-rdca.dtmvtolt
                             BY tt-saldo-rdca.qtdiacar:

        IF CAN-FIND(tt-resposta-cliente 
                        WHERE tt-resposta-cliente.nraplica = 
                              tt-saldo-rdca.nraplica) 
                           OR
           CAN-FIND(tt-dados-resgate 
                        WHERE tt-dados-resgate.nraplica = 
                              tt-saldo-rdca.nraplica) THEN
        
            NEXT.
        
        FIND craplrg WHERE craplrg.cdcooper = par_cdcooper
                       AND craplrg.nrdconta = par_nrdconta
                       AND craplrg.nraplica = tt-saldo-rdca.nraplica
                       AND craplrg.tpaplica = tt-saldo-rdca.tpaplica
                       AND craplrg.dtresgat >= par_dtmvtolt
                       AND craplrg.inresgat = 0 NO-LOCK NO-ERROR.

        IF AVAIL craplrg THEN
            NEXT.

        IF (tt-saldo-rdca.dtvencto > par_dtmvtolt) THEN
        DO:
            IF ((tt-saldo-rdca.dtvencto - par_dtmvtolt) < 10) THEN
            DO:
                CREATE tt-resposta-cliente.
                ASSIGN tt-resposta-cliente.nraplica = tt-saldo-rdca.nraplica
                       tt-resposta-cliente.dtvencto = tt-saldo-rdca.dtvencto
                       tt-resposta-cliente.resposta = "".
            END.
            ELSE
            DO:
                IF (par_vltotrgt >= tt-saldo-rdca.sldresga) THEN
                    ASSIGN aux_vlresgat = tt-saldo-rdca.sldresga
                           par_vltotrgt = par_vltotrgt - aux_vlresgat
                           aux_tpresgat = "T".
                ELSE
                    ASSIGN aux_vlresgat = par_vltotrgt
                           aux_tpresgat = "P"
                           par_vltotrgt = 0.
                
                CREATE tt-dados-resgate.
                ASSIGN tt-dados-resgate.nraplica = tt-saldo-rdca.nraplica
                       tt-dados-resgate.dtmvtolt = tt-saldo-rdca.dtmvtolt
                       tt-dados-resgate.dshistor = tt-saldo-rdca.dshistor
                       tt-dados-resgate.nrdocmto = tt-saldo-rdca.nrdocmto
                       tt-dados-resgate.dtvencto = tt-saldo-rdca.dtvencto
                       tt-dados-resgate.sldresga = tt-saldo-rdca.sldresga
                       tt-dados-resgate.vlresgat = aux_vlresgat
                       tt-dados-resgate.tpresgat = aux_tpresgat.

            END.
        END.
        ELSE
        DO:
            IF (par_vltotrgt >= tt-saldo-rdca.sldresga) THEN
                ASSIGN aux_vlresgat = tt-saldo-rdca.sldresga
                       par_vltotrgt = par_vltotrgt - aux_vlresgat
                       aux_tpresgat = "T".
            ELSE
                ASSIGN aux_vlresgat = par_vltotrgt
                       aux_tpresgat = "P"
                       par_vltotrgt = 0.
            
            CREATE tt-dados-resgate.
            ASSIGN tt-dados-resgate.nraplica = tt-saldo-rdca.nraplica
                   tt-dados-resgate.dtmvtolt = tt-saldo-rdca.dtmvtolt
                   tt-dados-resgate.dshistor = tt-saldo-rdca.dshistor
                   tt-dados-resgate.nrdocmto = tt-saldo-rdca.nrdocmto
                   tt-dados-resgate.dtvencto = tt-saldo-rdca.dtvencto
                   tt-dados-resgate.sldresga = tt-saldo-rdca.sldresga
                   tt-dados-resgate.vlresgat = aux_vlresgat
                   tt-dados-resgate.tpresgat = aux_tpresgat.

        END.

        /*************************************************************/

        RUN valida-acesso-opcao-resgate(INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT tt-saldo-rdca.nraplica,
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

        IF  par_dtresgat = ?  THEN
        DO:
            ASSIGN aux_cdcritic = 13.    
        END.
        ELSE
        IF  par_dtresgat > (par_dtmvtolt + 90)  THEN
        DO:
            ASSIGN aux_cdcritic = 13.
        END.
        ELSE
        IF  craprda.tpaplica = 3 AND par_dtresgat < par_dtmvtolt  THEN
        DO:
            ASSIGN aux_cdcritic = 13.
        END.
        ELSE         
        IF  craprda.tpaplica = 5          AND 
           (par_dtresgat <  par_dtmvtopr  OR 
            par_dtresgat <= par_dtmvtolt) THEN    
        DO:
            ASSIGN aux_cdcritic = 13.
        END.
        ELSE           
        IF  AVAILABLE crapdtc                AND
           (par_dtresgat < par_dtmvtolt      OR 
            par_dtresgat > craprda.dtvencto) THEN
        DO:
            ASSIGN aux_cdcritic = 13.
        END.
        ELSE             
        IF  AVAILABLE crapdtc AND par_dtresgat = craprda.dtvencto  THEN
        DO:
            ASSIGN aux_cdcritic = 907.
        END.
        ELSE       
        FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND 
                           crapfer.dtferiad = par_dtresgat NO-LOCK NO-ERROR.
                        
        IF  AVAILABLE crapfer                                OR
            CAN-DO("1,7",STRING(WEEKDAY(par_dtresgat),"9"))  THEN
        DO:
            ASSIGN aux_cdcritic = 13.
        END.

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

        /************************************************************/

        FIND LAST tt-resposta-cliente WHERE tt-resposta-cliente.resposta = ""
                                                                NO-ERROR.

        IF ((AVAIL tt-resposta-cliente) OR (par_vltotrgt = 0)) THEN
            RETURN "QUESTION".
        
    END.

END PROCEDURE.

/******************************************************************************/
/**        Procedure para listar o resgate de varias aplicacoes de forma     **/
/**        manual                                                            **/
/******************************************************************************/
PROCEDURE retorna-aplicacoes-resgate-manual:

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
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados-resgate.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.

    /* Leitura do XML de novas aplicacoes */
    
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

   /* Efetuar a chamada a rotina Oracle  */
   RUN STORED-PROCEDURE pc_lista_aplicacoes_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                            INPUT par_cdoperad, /* Código do Operador */
                                            INPUT par_nmdatela, /* Nome da Tela */
                                            INPUT par_idorigem, /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                            INPUT par_nrdcaixa, /* Numero do Caixa */
                                            INPUT par_nrdconta, /* Número da Conta */
                                            INPUT par_idseqttl, /* Titular da Conta */
                                            INPUT par_cdagenci, /* Codigo da Agencia */
                                            INPUT par_cdprogra, /* Codigo do Programa */
                                            INPUT par_nraplica, /* Número da Aplicação - Parâmetro Opcional */
                                            INPUT 0,            /* Código do Produto – Parâmetro Opcional */ 
                                            INPUT par_dtmvtolt, /* Data de Movimento */
                                            INPUT 6,            
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
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        RETURN "NOK".
        
     END.
   

   EMPTY TEMP-TABLE tt-saldo-rdca.

   /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
   /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 
        
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
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
                   
                    ASSIGN tt-saldo-rdca.nraplica =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
                    ASSIGN tt-saldo-rdca.qtdiauti =  INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".
                    ASSIGN tt-saldo-rdca.vlaplica =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
                    ASSIGN tt-saldo-rdca.nrdocmto =      xText:NODE-VALUE  WHEN xField:NAME = "nrdocmto".
                    ASSIGN tt-saldo-rdca.indebcre =      xText:NODE-VALUE  WHEN xField:NAME = "indebcre".
                    ASSIGN tt-saldo-rdca.vllanmto =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
                    ASSIGN tt-saldo-rdca.sldresga =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                    ASSIGN tt-saldo-rdca.cddresga =      xText:NODE-VALUE  WHEN xField:NAME = "cddresga".
                    ASSIGN tt-saldo-rdca.txaplmax =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmax".
                    ASSIGN tt-saldo-rdca.txaplmin =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmin".
                    ASSIGN tt-saldo-rdca.dshistor =      xText:NODE-VALUE  WHEN xField:NAME = "dshistor".
                    ASSIGN tt-saldo-rdca.dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
                    ASSIGN tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                    ASSIGN tt-saldo-rdca.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto" AND xText:NODE-VALUE <> "01/01/1900".
                    ASSIGN tt-saldo-rdca.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
                    ASSIGN tt-saldo-rdca.cdprodut =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdprodut".
                    ASSIGN tt-saldo-rdca.idtipapl =      xText:NODE-VALUE  WHEN xField:NAME = "idtipapl".
                    
                END. 
                
            END.
        
            SET-SIZE(ponteiro_xml) = 0. 
        END.

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

    RUN filtra-aplicacoes-resgate-manual(INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_dtmvtolt,
                                         INPUT TABLE tt-saldo-rdca,
                                         OUTPUT TABLE tt-dados-resgate,
                                         OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
            IF NOT AVAILABLE tt-erro  THEN
                DO:
                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel concluir a operacao.".
                                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,   /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).             
             END.

           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE filtra-aplicacoes-resgate-manual:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.

    DEF INPUT  PARAM TABLE FOR tt-saldo-rdca.
    DEF OUTPUT PARAM TABLE FOR tt-dados-resgate.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FOR EACH tt-saldo-rdca WHERE tt-saldo-rdca.dtmvtolt < par_dtmvtolt
                             AND tt-saldo-rdca.sldresga > 0
                             AND (tt-saldo-rdca.dssitapl = "DISPONIVEL"
                              OR tt-saldo-rdca.dssitapl = "")
                             NO-LOCK
                             BY tt-saldo-rdca.dtmvtolt
                             BY tt-saldo-rdca.qtdiacar:

        IF tt-saldo-rdca.idtipapl <> "N" THEN
            DO:
                FIND craplrg WHERE craplrg.cdcooper = par_cdcooper
                       AND craplrg.nrdconta = par_nrdconta
                       AND craplrg.nraplica = tt-saldo-rdca.nraplica
                       AND craplrg.tpaplica = tt-saldo-rdca.tpaplica
                       AND craplrg.dtresgat >= par_dtmvtolt
                       AND craplrg.inresgat = 0 NO-LOCK NO-ERROR.

                IF AVAIL craplrg THEN
                    NEXT.
        
                CREATE tt-dados-resgate.
                ASSIGN tt-dados-resgate.nraplica = tt-saldo-rdca.nraplica
                       tt-dados-resgate.dtmvtolt = tt-saldo-rdca.dtmvtolt
                       tt-dados-resgate.dshistor = tt-saldo-rdca.dshistor
                       tt-dados-resgate.nrdocmto = tt-saldo-rdca.nrdocmto
                       tt-dados-resgate.dtvencto = tt-saldo-rdca.dtvencto
                       tt-dados-resgate.vllanmto = tt-saldo-rdca.vllanmto
                       tt-dados-resgate.sldresga = tt-saldo-rdca.sldresga
                       tt-dados-resgate.dssitapl = tt-saldo-rdca.dssitapl
                       tt-dados-resgate.txaplmax = tt-saldo-rdca.txaplmax
                       tt-dados-resgate.txaplmin = tt-saldo-rdca.txaplmin
                       tt-dados-resgate.cddresga = tt-saldo-rdca.cddresga
                       tt-dados-resgate.idtipapl = tt-saldo-rdca.idtipapl.
        
                ASSIGN tt-dados-resgate.dtresgat = tt-saldo-rdca.dtresgat WHEN STRING(tt-saldo-rdca.dtresgat) <> "01/01/1900".    
            END.
        ELSE
            DO:
            /*
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
                /* Efetuar a chamada a rotina Oracle */ 
                RUN STORED-PROCEDURE pc_val_solicit_resg
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,           /* Código da Cooperativa */
                                                        INPUT "344",                    /* Código do Operador */
                                                        INPUT "ATENDA",               /* Nome da Tela */
                                                        INPUT 5,                      /* Identificador de Origem (1-AYLLOS/2-CAIXA/3-INTERNET/4-TAA/5-AYLLOS WEB/6-URA) */
                                                        INPUT par_nrdconta,           /* Número da Conta */
                                                        INPUT 1,                      /* Titular da Conta */
                                                        INPUT tt-saldo-rdca.nraplica, /* Número da Aplicação */
                                                        INPUT tt-saldo-rdca.cdprodut, /* Código do Produto */
                                                        INPUT par_dtmvtolt,           /* Data do Resgate (Data informada em tela) */
                                                        INPUT 0,                      /* Valor do Resgate (Valor informado em tela) */
                                                        INPUT 2,                      /* Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total) */
                                                        INPUT 0,                      /* Resgate na Conta Investimento (Identificador informado em tela, 0 – Não) */
                                                        INPUT 1,                      /* Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim) */
                                                        INPUT 0,                      /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                                        INPUT '',                     /*Operador*/
                                                        INPUT '',                     /*Senha*/
                                                        INPUT 0,                      /*Validar senha*/
                                                       OUTPUT 0,                      /* Código da crítica */
                                                       OUTPUT "").                    /* Descricao da Critica */
                
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_val_solicit_resg
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                
                /* Busca possíveis erros */ 
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = pc_val_solicit_resg.pr_cdcritic 
                                      WHEN pc_val_solicit_resg.pr_cdcritic <> ?
                       aux_dscritic = pc_val_solicit_resg.pr_dscritic 
                                      WHEN pc_val_solicit_resg.pr_dscritic <> ?.
                
                IF aux_cdcritic <> 0 OR
                  aux_dscritic <> "" THEN
                    DO:
                        CREATE tt-erro.
                        ASSIGN tt-erro.cdcritic = aux_cdcritic
                               tt-erro.dscritic = aux_dscritic.
                        
                        RETURN "NOK".
                    
                    END.
              */
                CREATE tt-dados-resgate.
                ASSIGN tt-dados-resgate.nraplica = tt-saldo-rdca.nraplica
                       tt-dados-resgate.dtmvtolt = tt-saldo-rdca.dtmvtolt
                       tt-dados-resgate.dshistor = tt-saldo-rdca.dshistor
                       tt-dados-resgate.nrdocmto = tt-saldo-rdca.nrdocmto
                       tt-dados-resgate.dtvencto = tt-saldo-rdca.dtvencto
                       tt-dados-resgate.vllanmto = tt-saldo-rdca.vllanmto
                       tt-dados-resgate.sldresga = tt-saldo-rdca.sldresga
                       tt-dados-resgate.dssitapl = tt-saldo-rdca.dssitapl
                       tt-dados-resgate.txaplmax = tt-saldo-rdca.txaplmax
                       tt-dados-resgate.txaplmin = tt-saldo-rdca.txaplmin
                       tt-dados-resgate.cddresga = tt-saldo-rdca.cddresga
                       tt-dados-resgate.idtipapl = tt-saldo-rdca.idtipapl.
            END.
    END.

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

    DEF  VAR    aux_vlrresga AS DECI                                NO-UNDO.

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
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Aplicacao feita HOJE. Use a opcao EXCLUIR.".
                   
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
                DO:
                   RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT
                       SET h-b1wgen0004.
                                 
                   RUN saldo-resg-rdca IN h-b1wgen0004 (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT par_nrdconta,
                                                        INPUT par_nraplica,
                                                        INPUT par_cdprogra,
                                                       OUTPUT aux_vlsdrdca,
                                                       OUTPUT aux_sldpresg,
                                                       OUTPUT TABLE tt-erro).
                
                   DELETE PROCEDURE h-b1wgen0004.

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
        END.
    ELSE
    IF  craprda.tpaplica = 5  THEN
        DO:
           RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT
               SET h-b1wgen0004.
    
           RUN saldo-resg-rdca IN h-b1wgen0004 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_nrdconta,
                                                INPUT par_nraplica,
                                                INPUT par_cdprogra,
                                               OUTPUT aux_vlsdrdca,
                                               OUTPUT aux_sldpresg,
                                               OUTPUT TABLE tt-erro).
     
           DELETE PROCEDURE h-b1wgen0004.

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
        DO:
            FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper      AND
                              (crapdtc.tpaplrdc = 1                 OR
                               crapdtc.tpaplrdc = 2)                AND
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
                    RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT
                        SET h-b1wgen0004.
                
                    RUN saldo_rgt_rdc_pos IN h-b1wgen0004 (INPUT par_cdcooper,
                                                           INPUT craprda.nrdconta,
                                                           INPUT craprda.nraplica,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dtmvtolt,
                                                           INPUT 0,
                                                           INPUT FALSE,
                                                          OUTPUT aux_sldpresg,
                                                          OUTPUT aux_vlrenrgt,
                                                          OUTPUT aux_vlrdirrf,
                                                          OUTPUT aux_perirrgt,
                                                          OUTPUT aux_vlrrgtot,
                                                          OUTPUT aux_vlirftot,
                                                          OUTPUT aux_vlrendmm,
                                                          OUTPUT aux_vlrvtfim,
                                                          OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h-b1wgen0004.
                    
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

            ASSIGN aux_vlrresga = 0.

            FIND craplrg WHERE craplrg.cdcooper = par_cdcooper
                           AND craplrg.nrdconta = par_nrdconta
                           AND craplrg.nraplica = par_nraplica
                           AND craplrg.tpresgat = 2
                           AND craplrg.inresgat = 0
                           
                           NO-LOCK NO-ERROR.
            
            IF  AVAILABLE craplrg THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "A Aplicacao ja possui um resgate total.".
                           
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
            ELSE
                DO:
                    FOR EACH craplrg WHERE craplrg.cdcooper = par_cdcooper
                                       AND craplrg.nrdconta = par_nrdconta
                                       AND craplrg.nraplica = par_nraplica
                                       AND craplrg.inresgat = 0
                                       NO-LOCK:
                        ASSIGN aux_vlrresga = aux_vlrresga + craplrg.vllanmto.
                    END.
                END.
                
            IF  aux_sldpresg < aux_vlrresga THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Saldo insuficiente para resgate.".
                           
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
  
  /* Variaveis para o XML */ 
  DEF VAR xDoc          AS HANDLE   NO-UNDO.   
  DEF VAR xRoot         AS HANDLE   NO-UNDO.  
  DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
  DEF VAR xField        AS HANDLE   NO-UNDO. 
  DEF VAR xText         AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req       AS LONGCHAR NO-UNDO.  

  /* Variaveis locais */
  DEF VAR aux_flgcance AS INTE NO-UNDO.
  DEF VAR aux_flgerlog AS INTE NO-UNDO.
    
  /* Leitura do XML de novas aplicacoes */
   
  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

  IF par_flgcance THEN
      ASSIGN aux_flgcance = 1.
  ELSE
      ASSIGN aux_flgcance = 0.

  IF par_flgerlog THEN
      ASSIGN aux_flgerlog = 1.
  ELSE
      ASSIGN aux_flgerlog = 0.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
  
  /* Efetuar a chamada a rotina Oracle */ 
  RUN STORED-PROCEDURE pc_consulta_resgates_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT 1,            /* Codigo da Agencia */
                                         INPUT 1,            /* Numero do Caixa */
                                         INPUT par_cdoperad, /* Código do Operador */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT par_idorigem, /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT par_idseqttl, /* Sequencial do Titular */
                                         INPUT par_nrdconta, /* Número da Conta */
                                         INPUT par_dtmvtolt, /* Data de Movimento */
                                         INPUT par_nraplica, /* Numero da Aplicacao */
                                         INPUT aux_flgcance, /* Indicador de opcao (Cancelamento/Proximo) */
                                         INPUT aux_flgerlog, /* Gravar log */ 
                                        OUTPUT ?,            /* XML com informações de LOG */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descrição da crítica */

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_consulta_resgates_car
     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
               
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

   /* Busca possíveis erros */ 
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_consulta_resgates_car.pr_cdcritic 
                         WHEN pc_consulta_resgates_car.pr_cdcritic <> ?
          aux_dscritic = pc_consulta_resgates_car.pr_dscritic 
                         WHEN pc_consulta_resgates_car.pr_dscritic <> ?.
      
   IF aux_cdcritic <> 0 OR
      aux_dscritic <> "" THEN
     DO:
         BELL.
         MESSAGE aux_dscritic.
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            PAUSE 3 NO-MESSAGE.
            LEAVE.
         END.
        
         HIDE MESSAGE NO-PAUSE.
    
         RETURN "NOK".
     END.

   /* Limpa dados da tabela temporaria */
   EMPTY TEMP-TABLE tt-resg-aplica.

   /*Leitura do XML de retorno da proc e criacao dos registros na tt-resg-aplica
    para visualizacao dos registros na tela */
       
   /* Buscar o XML na tabela de retorno da procedure Progress */ 
   ASSIGN xml_req = pc_consulta_resgates_car.pr_clobxmlc.
                  
   /* Efetuar a leitura do XML*/ 
   SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
   PUT-STRING(ponteiro_xml,1) = xml_req. 
                                 
   IF ponteiro_xml <> ? THEN
     DO:
       xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
       xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
       DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
         xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
         IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
           NEXT. 
        
         IF xRoot2:NUM-CHILDREN > 0 THEN
           CREATE tt-resg-aplica.
        
         DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
           xRoot2:GET-CHILD(xField,aux_cont).
                        
           IF xField:SUBTYPE <> "ELEMENT" THEN 
             NEXT. 
                    
           xField:GET-CHILD(xText,1).
                      
           ASSIGN tt-resg-aplica.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
           ASSIGN tt-resg-aplica.nrdocmto =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto".
           ASSIGN tt-resg-aplica.tpresgat =      xText:NODE-VALUE  WHEN xField:NAME = "tpresgat".
           ASSIGN tt-resg-aplica.dsresgat =      xText:NODE-VALUE  WHEN xField:NAME = "dsresgat".
           ASSIGN tt-resg-aplica.nmoperad =      xText:NODE-VALUE  WHEN xField:NAME = "nmoperad".
           ASSIGN tt-resg-aplica.hrtransa =      xText:NODE-VALUE  WHEN xField:NAME = "hrtransa".
           ASSIGN tt-resg-aplica.vllanmto = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".

         END. 
                
       END.
        
       SET-SIZE(ponteiro_xml) = 0. 
     END.

   DELETE OBJECT xDoc. 
   DELETE OBJECT xRoot. 
   DELETE OBJECT xRoot2. 
   DELETE OBJECT xField. 
   DELETE OBJECT xText.

   /* Fim leitura do XML de resgates de aplicacoes */

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
    DEF  INPUT PARAM par_nrdocmto AS DEC                            NO-UNDO.
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
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    IF  par_flgerlog  THEN
        ASSIGN aux_dstransa = "Cancelar resgate da aplicacao".

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
                               
            FIND craprda WHERE craprda.cdcooper = par_cdcooper AND 
                               craprda.nrdconta = par_nrdconta AND
                               craprda.nraplica = par_nraplica         
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
            IF  NOT AVAILABLE craprda  THEN 
                DO:       
                    IF  LOCKED craprda  THEN
                        DO:
                            ASSIGN aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 426.

                END.
                
            LEAVE.
                
        END. /** Fim do DO ... TO **/
                
        IF  aux_cdcritic > 0  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

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
        
        IF  craprda.tpaplica <> 3                 OR  
           (craprda.tpaplica  = 3                 AND
            craplrg.dtresgat <> craplrg.dtmvtolt) THEN
            DO:
                ASSIGN aux_flgtrans = TRUE.
                LEAVE TRANSACAO.
            END.

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
                            IF  par_dtmvtolt <> aux_datdodia  THEN    
                                DO:
                                    ASSIGN aux_flgtrans = TRUE.
                                    LEAVE TRANSACAO.
                                END.
                            ELSE
                                ASSIGN aux_cdcritic = 60.
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
        
                            IF NOT AVAILABLE craplci  THEN
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
                                ASSIGN crablot.qtinfoln = crablot.qtinfoln - 1
                                       crablot.qtcompln = crablot.qtcompln - 1
                                       crablot.vlinfocr = crablot.vlinfocr - 
                                                          craplci.vllanmto
                                       crablot.vlcompcr = crablot.vlcompcr - 
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
            ASSIGN craprda.vlrgtacu = craprda.vlrgtacu - craplap.vllanmto
                   craprda.qtrgtmfx = craprda.qtrgtmfx - 
                           ROUND(craplap.vllanmto / aux_vlmoefix,4).
        ELSE
            ASSIGN craprda.vlrgtacu = craprda.vlrgtacu - craplap.vllanmto
                   craprda.qtrgtmfx = craprda.qtrgtmfx - 
                           ROUND(craplap.vllanmto / aux_vlorimfx,4)
                   craprda.vlsdrdca = craprda.vlsdrdca + craplap.vllanmto
                   craprda.vlabcpmf = IF aux_indabono  = 0                AND
                                         aux_dtiniabo <= craprda.dtmvtolt THEN
                                         craprda.vlabcpmf +
                                         TRUNCATE(craplap.vllanmto * 
                                                  aux_txcpmfcc,2)
                                      ELSE 
                                         craprda.vlabcpmf
                   craprda.vlabdiof = IF aux_indabono  = 0                AND
                                         aux_dtiniabo <= craprda.dtmvtolt THEN
                                         craprda.vlabdiof +
                                         TRUNCATE(craplap.vllanmto * 
                                                  aux_txiofrda,2)
                                      ELSE 
                                         craprda.vlabdiof.

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

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF  AVAILABLE craplrg  THEN
        FIND CURRENT craplrg NO-LOCK NO-ERROR.

    IF  AVAILABLE craprda  THEN
        FIND CURRENT craprda NO-LOCK NO-ERROR.

    IF  AVAILABLE craplot  THEN
        FIND CURRENT craplot NO-LOCK NO-ERROR.

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
    DEF  INPUT PARAM par_vlresgat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctain AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flmensag AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdopera2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_inproces LIKE crapdat.inproces                      NO-UNDO.

    /* Limpar a temp-table para não ficar informação do resgate de outras aplicações */
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_inproces = 0.

    /* Buscar o inproces da crapdat */
    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK.

    IF AVAIL crapdat THEN
      ASSIGN aux_inproces = crapdat.inproces.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_cad_resgate_aplica_wt
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_nraplica,
                          INPUT par_idseqttl,
                          INPUT par_cdprogra,
                          INPUT par_dtmvtolt,
                          INPUT par_dtmvtopr,
                          INPUT aux_inproces,
                          INPUT par_vlresgat,
                          INPUT par_dtresgat,
                          INPUT INT(par_flmensag),
                          INPUT par_tpresgat,
                          INPUT INT(par_flgctain),
                          INPUT INT(par_flgerlog),
                          INPUT par_cdopera2,
                          INPUT par_cddsenha,
                         OUTPUT 0,
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "").
          
    CLOSE STORED-PROC pc_cad_resgate_aplica_wt
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }    

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nrdocmto = pc_cad_resgate_aplica_wt.pr_nrdocmto 
                          WHEN pc_cad_resgate_aplica_wt.pr_nrdocmto <> ?
           aux_cdcritic = pc_cad_resgate_aplica_wt.pr_cdcritic 
                          WHEN pc_cad_resgate_aplica_wt.pr_cdcritic <> ?
           aux_dscritic = pc_cad_resgate_aplica_wt.pr_dscritic 
                          WHEN pc_cad_resgate_aplica_wt.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
        DO:
            IF aux_dscritic = "" THEN
                DO:
                    FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                 NO-LOCK NO-ERROR.
            
                    IF AVAIL crapcri THEN
                        ASSIGN aux_dscritic = crapcri.dscritic.
                END.
    
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
            RETURN "NOK".
        END.

    /* Buscar todas as mensagens de confirmação */
    FOR EACH wt_msg_confirma NO-LOCK:
        CREATE tt-msg-confirma.
        ASSIGN tt-msg-confirma.inconfir = wt_msg_confirma.inconfir
               tt-msg-confirma.dsmensag = wt_msg_confirma.dsmensag.
    END.
            
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**              Procedure para cadastrar varios resgates de aplicacao       **/
/******************************************************************************/
PROCEDURE cadastrar-varios-resgates-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctain AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flmensag AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-dados-resgate.
    
    DEF OUTPUT PARAM par_nrdocmto AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdocmto AS DECI                                    NO-UNDO.
    DEF VAR aux_flgerlog AS INTE                                    NO-UNDO.
    DEF VAR aux_flgctain AS INTE                                    NO-UNDO.
    DEF VAR aux_tpresgat AS INTE                                    NO-UNDO.
    DEF VAR aux_tpresgac AS CHAR                                    NO-UNDO.
    
    Cadastrar: DO TRANSACTION ON ERROR UNDO Cadastrar, RETURN "NOK":

        FOR EACH tt-dados-resgate NO-LOCK:

            IF tt-dados-resgate.idtipapl = "A" THEN
                DO:
                    IF tt-dados-resgate.tpresgat = "1" THEN
                      ASSIGN aux_tpresgac = "P".
                    ELSE
                      ASSIGN aux_tpresgac = "T".        
                    
                    RUN cadastrar-resgate-aplicacao(INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_idorigem,
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT tt-dados-resgate.nraplica,
                                                    INPUT aux_tpresgac,
                                                    INPUT tt-dados-resgate.vlresgat,
                                                    INPUT par_dtresgat,
                                                    INPUT par_flgctain,
                                                    INPUT par_dtmvtolt,
                                                    INPUT par_dtmvtopr,
                                                    INPUT par_cdprogra,
                                                    INPUT par_flmensag,
                                                    INPUT par_flgerlog,
                                                    INPUT "", /*operador*/
                                                    INPUT "", /*senha*/
                                                   OUTPUT aux_nrdocmto,
                                                   OUTPUT TABLE tt-msg-confirma,
                                                   OUTPUT TABLE tt-erro).
            
                    IF RETURN-VALUE <> "OK"  THEN
                        DO: 
                      
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                            IF NOT AVAILABLE tt-erro THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel listar as aplicacoes.".
                                                                         
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,            /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).                 
                                END.
                                       
                            IF par_flgerlog  THEN   
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
                            
                            UNDO Cadastrar, RETURN "NOK".
                        END.
                    ELSE
                       DO:
                           IF par_nrdocmto = "" THEN
                              ASSIGN par_nrdocmto = STRING(aux_nrdocmto).
                           ELSE
                              ASSIGN par_nrdocmto = par_nrdocmto + ";" + 
                                                    STRING(aux_nrdocmto).
        
                       END.
                END. /*FIM IF*/
            ELSE IF NOT par_flmensag THEN
                DO:
    
                    /* Verifica se deve creditar em conta-investimento */
                    IF par_flgctain THEN
                      ASSIGN aux_flgctain = 1.       
                    ELSE
                      ASSIGN aux_flgctain = 0. 
    
                    /* Verifica se deve gerar log */
                    IF par_flgerlog THEN
                      ASSIGN aux_flgerlog = 1. 
                    ELSE
                      ASSIGN aux_flgerlog = 0. 
        
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                   
                    /* Efetuar a chamada a rotina Oracle */ 
                    RUN STORED-PROCEDURE pc_solicita_resgate
                       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,                   /* Código da Cooperativa */
                                                            INPUT par_cdoperad,                   /* Código do Operador */
                                                            INPUT par_nmdatela,                   /* Nome da Tela */
                                                            INPUT par_idorigem,                   /* Identificador de Origem (1-AYLLOS/2-CAIXA/3-INTERNET/4-TAA/5-AYLLOS WEB/6-URA) */
                                                            INPUT par_nrdconta,                   /* Número da Conta */
                                                            INPUT par_idseqttl,                   /* Titular da Conta */
                                                            INPUT tt-dados-resgate.nraplica,      /* Número da Aplicação */
                                                            INPUT tt-dados-resgate.cdprodut,      /* Código do Produto */
                                                            INPUT par_dtresgat,                   /* Data do Resgate (Data informada em tela) */
                                                            INPUT tt-dados-resgate.vlresgat,      /* Valor do Resgate (Valor informado em tela) */
                                                            INPUT INT(tt-dados-resgate.tpresgat), /* Tipo do Resgate (Tipo informado em tela,1–Parcial/2–Total) */
                                                            INPUT aux_flgctain,                   /* Resgate na Conta Investimento (Identificador informado em tela,0– Não) */
                                                            INPUT aux_flgerlog,                   /* Identificador de Log (Fixo no código,0–Não/1-Sim) */
                                                            INPUT "",
                                                            INPUT "",
                                                            INPUT 0,
                                                           OUTPUT 0,                              /* Código da crítica */
                                                           OUTPUT "").                            /* Descricao da Critica */
    
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_solicita_resgate
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                    
                    /* Busca possíveis erros */ 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_solicita_resgate.pr_cdcritic 
                                          WHEN pc_solicita_resgate.pr_cdcritic <> ?
                           aux_dscritic = pc_solicita_resgate.pr_dscritic
                                          WHEN pc_solicita_resgate.pr_dscritic <> ?.
                    
                    IF aux_cdcritic <> 0 OR
                       aux_dscritic <> "" THEN
                        DO:
                    
                            CREATE tt-erro.
                            ASSIGN tt-erro.cdcritic = aux_cdcritic
                                   tt-erro.dscritic = aux_dscritic + ". Teste Jean2".
    
                            IF par_flgerlog  THEN   
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

                            UNDO Cadastrar, RETURN "NOK".
                        
                        END.               
                END.    
        END.
    END. /*Fim transaction Cadastrar*/
    
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
                        
                        RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT
                            SET h-b1wgen0004.
                         
                        RUN saldo-resg-rdca IN h-b1wgen0004 (INPUT par_cdcooper,
                                                             INPUT par_cdagenci,
                                                             INPUT par_nrdcaixa,
                                                             INPUT par_nrdconta,
                                                             INPUT par_nraplica,
                                                             INPUT "crps117", /* Batch resg. */
                                                            OUTPUT aux_vlsdrdca,
                                                            OUTPUT aux_sldpresg,
                                                            OUTPUT TABLE tt-erro).
                        
                        DELETE PROCEDURE h-b1wgen0004.


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
                                VALIDATE craplcm.
    
                                ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                                       craplot.qtcompln = craplot.qtcompln + 1
                                       craplot.vlinfocr = craplot.vlinfocr + 
                                                          aux_vlresgat
                                       craplot.vlcompcr = craplot.vlcompcr + 
                                                          aux_vlresgat
                                       craplot.nrseqdig = craplcm.nrseqdig.

                                VALIDATE craplot.
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

                                VALIDATE crablot.
                                VALIDATE craplci.

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
                                                ASSIGN crablot.dtmvtolt = par_dtmvtolt
                                                       crablot.cdagenci = 1
                                                       crablot.cdbccxlt = 100
                                                       crablot.nrdolote = 10104 
                                                       crablot.tplotmov = 29
                                                       crablot.cdcooper = par_cdcooper.
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

                                VALIDATE crablot.
                                VALIDATE craplci.
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
                                                       crablot.cdcooper = par_cdcooper.
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

                                VALIDATE crablot.
                                VALIDATE craplci. 

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
                                                    VALIDATE crapsli.
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

                        VALIDATE craplap.
                               
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
                          
                        VALIDATE craplot.
                        VALIDATE craplap.

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
        VALIDATE craprej.                                  
    END. /** Fim do FOR EACH craplrg **/
    
    FIND CURRENT crabrda NO-LOCK NO-ERROR.
    FIND CURRENT craplcm NO-LOCK NO-ERROR.
    FIND CURRENT craplci NO-LOCK NO-ERROR.
    FIND CURRENT craplap NO-LOCK NO-ERROR.
    FIND CURRENT craplrg NO-LOCK NO-ERROR.
    FIND CURRENT craplot NO-LOCK NO-ERROR.
    FIND CURRENT crablot NO-LOCK NO-ERROR.
    FIND CURRENT crapsli NO-LOCK NO-ERROR.
    FIND CURRENT craprej NO-LOCK NO-ERROR.
                                          
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
  DEF  INPUT PARAM par_idtipapl AS CHAR                           NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-dados-acumulo.
  DEF OUTPUT PARAM TABLE FOR tt-acumula.
  DEF OUTPUT PARAM TABLE FOR tt-erro.
  
  EMPTY TEMP-TABLE tt-dados-acumulo.
  EMPTY TEMP-TABLE tt-acumula.
  EMPTY TEMP-TABLE tt-erro.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

  RUN STORED-PROCEDURE pc_consulta_sld_acumul_wt
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_nraplica,
                             INPUT par_dtmvtolt,
                             INPUT INT(par_flgerlog),
                             INPUT par_idtipapl,
                             OUTPUT 0, 
                             OUTPUT "").     

  
  CLOSE STORED-PROC pc_consulta_sld_acumul_wt
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
  
  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
  
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_consulta_sld_acumul_wt.pr_cdcritic 
                         WHEN pc_consulta_sld_acumul_wt.pr_cdcritic <> ?
         aux_dscritic = pc_consulta_sld_acumul_wt.pr_dscritic
                         WHEN pc_consulta_sld_acumul_wt.pr_dscritic <> ?.
  
  IF aux_cdcritic <> 0   OR
     aux_dscritic <> ""  THEN
     DO:
         IF aux_dscritic = "" THEN
            DO:
               FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                  NO-LOCK NO-ERROR.

               IF AVAIL crapcri THEN
                  ASSIGN aux_dscritic = crapcri.dscritic.

            END.

         CREATE tt-erro.

         ASSIGN tt-erro.cdcritic = aux_cdcritic
                tt-erro.dscritic = aux_dscritic.
  
         RETURN "NOK".
                        
     END.

  FOR EACH wt_dados_acumulo NO-LOCK:
      
      CREATE tt-dados-acumulo.

      ASSIGN tt-dados-acumulo.nrdconta = wt_dados_acumulo.nrdconta
             tt-dados-acumulo.nraplica = wt_dados_acumulo.nraplica
             tt-dados-acumulo.dsaplica = wt_dados_acumulo.dsaplica
             tt-dados-acumulo.dtmvtolt = wt_dados_acumulo.dtmvtolt
             tt-dados-acumulo.dtvencto = wt_dados_acumulo.dtvencto
             tt-dados-acumulo.vlaplica = wt_dados_acumulo.vlaplica
             tt-dados-acumulo.txaplica = wt_dados_acumulo.txaplica
             tt-dados-acumulo.txaplmes = wt_dados_acumulo.txaplmes
             tt-dados-acumulo.vlsldrdc = wt_dados_acumulo.vlsldrdc
             tt-dados-acumulo.vlstotal = wt_dados_acumulo.vlstotal.

  END.

  FOR EACH wt_acumula NO-LOCK:
      
      CREATE tt-acumula.

      ASSIGN tt-acumula.nraplica = wt_acumula.nraplica
             tt-acumula.tpaplica = STRING(wt_acumula.tpaplica)
             tt-acumula.vlsdrdca = wt_acumula.vlsdrdca.

  END.

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
    
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Obtem tipos de aplicacao".
    
    FOR EACH crapdtc WHERE crapdtc.cdcooper = par_cdcooper AND
                           crapdtc.flgstrdc = TRUE         AND
                          (crapdtc.tpaplrdc = 1            OR
                           crapdtc.tpaplrdc = 2) NO-LOCK           
                           BY crapdtc.tpaplica DESC:
                           
        CREATE tt-tipo-aplicacao.
        ASSIGN tt-tipo-aplicacao.tpaplica = crapdtc.tpaplica
               tt-tipo-aplicacao.dsaplica = crapdtc.dsaplica
               tt-tipo-aplicacao.tpaplrdc = crapdtc.tpaplrdc
               tt-tipo-aplicacao.dstipapl = 'A'.
                              
    END. /** Fim do FOR EACH crapdtc **/
    
    FOR EACH crapcpc FIELDS(cdprodut nmprodut idtippro cdhscacc cdhsvrcc
                                                        cdhsraap cdhsnrap cdhsprap cdhsrvap cdhsrdap
                                cdhsirap cdhsrgap cdhsvtap) WHERE crapcpc.idsitpro = 1 NO-LOCK:

        FOR EACH crapdpc FIELDS(cdcooper idsitmod cdmodali)
            WHERE crapdpc.cdcooper = par_cdcooper AND
                  crapdpc.idsitmod = 1  /* DESBLOQUEADA */ NO-LOCK:
        
            FOR EACH crapmpc FIELDS(cdmodali cdprodut)
            WHERE crapmpc.cdmodali = crapdpc.cdmodali AND
                  crapmpc.cdprodut = crapcpc.cdprodut NO-LOCK:

                FOR FIRST craphis WHERE craphis.cdcooper = par_cdcooper AND
                                       (craphis.cdhistor = crapcpc.cdhscacc OR
                                        craphis.cdhistor = crapcpc.cdhsvrcc OR
                                        craphis.cdhistor = crapcpc.cdhsraap OR
                                        craphis.cdhistor = crapcpc.cdhsnrap OR
                                        craphis.cdhistor = crapcpc.cdhsprap OR
                                        craphis.cdhistor = crapcpc.cdhsrvap OR
                                        craphis.cdhistor = crapcpc.cdhsrdap OR
                                        craphis.cdhistor = crapcpc.cdhsirap OR
                                        craphis.cdhistor = crapcpc.cdhsrgap OR
                                        craphis.cdhistor = crapcpc.cdhsvtap) NO-LOCK: END.

                IF crapcpc.cdhscacc = 0 OR 
                   crapcpc.cdhsvrcc = 0 OR
                   crapcpc.cdhsraap = 0 OR
                   crapcpc.cdhsnrap = 0 OR
                   crapcpc.cdhsprap = 0 OR
                   crapcpc.cdhsrvap = 0 OR
                   crapcpc.cdhsrdap = 0 OR
                   crapcpc.cdhsirap = 0 OR
                   crapcpc.cdhsrgap = 0 OR
                   crapcpc.cdhsvtap = 0 OR
                   NOT AVAIL craphis  THEN
                  NEXT.
                
                FIND tt-tipo-aplicacao WHERE 
                     tt-tipo-aplicacao.tpaplica = crapcpc.cdprodut AND
                     tt-tipo-aplicacao.dstipapl = 'N'
                     NO-LOCK NO-ERROR NO-WAIT.

                IF NOT AVAIL tt-tipo-aplicacao THEN
                    DO:
                        CREATE tt-tipo-aplicacao.
                        ASSIGN tt-tipo-aplicacao.tpaplica = crapcpc.cdprodut
                               tt-tipo-aplicacao.dsaplica = crapcpc.nmprodut
                               tt-tipo-aplicacao.tpaplrdc = crapcpc.idtippro
                               tt-tipo-aplicacao.dstipapl = 'N'.
                    END.
            
            END. /** Fim do FOR EACH crapmpc **/ 
        END. /** Fim do FOR EACH crapdpc **/                                
    END. /** Fim do FOR EACH crapcpc **/

    IF  NOT CAN-FIND(FIRST tt-tipo-aplicacao)          THEN
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
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiaapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiacar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgvalid AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-carencia-aplicacao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-carencia-aplicacao.
    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_obtem_dias_carencia_wt
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_dtmvtolt,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_tpaplica,
                                 INPUT par_qtdiaapl,
                                 INPUT par_qtdiacar,
                                 INPUT INT(par_flgvalid),
                                 INPUT INT(par_flgerlog),
                                 OUTPUT 0,
                                 OUTPUT "").     
    
    CLOSE STORED-PROC pc_obtem_dias_carencia_wt
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_obtem_dias_carencia_wt.pr_cdcritic 
                              WHEN pc_obtem_dias_carencia_wt.pr_cdcritic <> ?
           aux_dscritic = pc_obtem_dias_carencia_wt.pr_dscritic
                              WHEN pc_obtem_dias_carencia_wt.pr_dscritic <> ?. 
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
       DO:
           IF aux_dscritic = "" THEN
              DO:
                 FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                    NO-LOCK NO-ERROR.

                 IF AVAIL crapcri THEN
                    ASSIGN aux_dscritic = crapcri.dscritic.

              END.

           CREATE tt-erro.

           ASSIGN tt-erro.cdcritic = aux_cdcritic
                  tt-erro.dscritic = aux_dscritic.
    
           RETURN "NOK".
                          
       END.

    FOR EACH wt_carencia_aplicacao NO-LOCK:
        
        CREATE tt-carencia-aplicacao.

        ASSIGN tt-carencia-aplicacao.cdperapl = wt_carencia_aplicacao.cdperapl 
               tt-carencia-aplicacao.qtdiaini = wt_carencia_aplicacao.qtdiaini
               tt-carencia-aplicacao.qtdiafim = wt_carencia_aplicacao.qtdiafim
               tt-carencia-aplicacao.qtdiacar = wt_carencia_aplicacao.qtdiacar
               tt-carencia-aplicacao.dtcarenc = wt_carencia_aplicacao.dtcarenc.

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
    DEF  INPUT PARAM par_qtdiacar AS INT                            NO-UNDO.
    
    DEF  INPUT-OUTPUT PARAM par_qtdiaapl AS INTE                    NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_dtvencto AS DATE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }  

    RUN STORED-PROCEDURE pc_calcula_permanencia_resgate
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, 
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_tpaplica,
                                 INPUT par_dtmvtolt,
                                 INPUT INT(par_flgerlog),
                                 INPUT par_qtdiacar,
                                 INPUT-OUTPUT par_qtdiaapl,
                                 INPUT-OUTPUT par_dtvencto,
                                 OUTPUT 0,
                                 OUTPUT "").  
    
    CLOSE STORED-PROC pc_calcula_permanencia_resgate
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = pc_calcula_permanencia_resgate.pr_cdcritic 
                              WHEN pc_calcula_permanencia_resgate.pr_cdcritic <> ?
    
           aux_dscritic = pc_calcula_permanencia_resgate.pr_dscritic
                              WHEN pc_calcula_permanencia_resgate.pr_dscritic <> ?
           par_qtdiaapl = pc_calcula_permanencia_resgate.pr_qtdiaapl
                              WHEN pc_calcula_permanencia_resgate.pr_qtdiaapl <> ?
           par_dtvencto = pc_calcula_permanencia_resgate.pr_dtvencto
                              WHEN pc_calcula_permanencia_resgate.pr_dtvencto <> ?.
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
       DO:
           IF aux_dscritic = "" THEN
              DO:
                 FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                    NO-LOCK NO-ERROR.

                 IF AVAIL crapcri THEN
                    ASSIGN aux_dscritic = crapcri.dscritic.

              END.

           CREATE tt-erro.

           ASSIGN tt-erro.cdcritic = aux_cdcritic
                  tt-erro.dscritic = aux_dscritic.
    
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

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

  RUN STORED-PROCEDURE pc_simula_saldo_acumul_wt
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_tpaplica,
                               INPUT par_dtvencto,
                               INPUT par_vlaplica,
                               INPUT par_cdperapl,
                               INPUT par_dtmvtolt,
                               INPUT par_cdprogra,
                               INPUT INT(par_flgerlog),
                               OUTPUT 0,
                               OUTPUT "").     
  
  CLOSE STORED-PROC pc_simula_saldo_acumul_wt
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
  
  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
  
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_simula_saldo_acumul_wt.pr_cdcritic 
                         WHEN pc_simula_saldo_acumul_wt.pr_cdcritic <> ?
         aux_dscritic = pc_simula_saldo_acumul_wt.pr_dscritic
                         WHEN pc_simula_saldo_acumul_wt.pr_dscritic <> ?.
  
  IF aux_cdcritic <> 0   OR
     aux_dscritic <> ""  THEN
     DO:
         IF aux_dscritic = "" THEN
            DO:
               FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                  NO-LOCK NO-ERROR.

               IF AVAIL crapcri THEN
                  ASSIGN aux_dscritic = crapcri.dscritic.

            END.

         CREATE tt-erro.

         ASSIGN tt-erro.cdcritic = aux_cdcritic
                tt-erro.dscritic = aux_dscritic.
  
         RETURN "NOK".
                        
     END.
      
  FOR EACH wt_dados_acumulo NO-LOCK: 
      
      CREATE tt-dados-acumulo.

      ASSIGN tt-dados-acumulo.nrdconta = wt_dados_acumulo.nrdconta
             tt-dados-acumulo.nraplica = wt_dados_acumulo.nraplica
             tt-dados-acumulo.dsaplica = wt_dados_acumulo.dsaplica
             tt-dados-acumulo.dtmvtolt = wt_dados_acumulo.dtmvtolt
             tt-dados-acumulo.dtvencto = wt_dados_acumulo.dtvencto
             tt-dados-acumulo.vlaplica = wt_dados_acumulo.vlaplica
             tt-dados-acumulo.txaplica = wt_dados_acumulo.txaplica
             tt-dados-acumulo.txaplmes = wt_dados_acumulo.txaplmes
             tt-dados-acumulo.vlsldrdc = wt_dados_acumulo.vlsldrdc
             tt-dados-acumulo.vlstotal = wt_dados_acumulo.vlstotal.
      
  END.  
  
  FOR EACH wt_acumula NO-LOCK: 
      
      CREATE tt-acumula.

      ASSIGN tt-acumula.nraplica = wt_acumula.nraplica
             tt-acumula.tpaplica = STRING(wt_acumula.tpaplica)
             tt-acumula.vlsdrdca = wt_acumula.vlsdrdca.
      
  END.  

  RETURN "OK".
  
END PROCEDURE.          

/******************************************************************************/
/**                Procedure para validar o tipo de aplicacao                **/
/******************************************************************************/
PROCEDURE validar-tipo-aplicacao:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM par_tpaplrdc AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_validar_tipo_aplicacao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdageope,
                                 INPUT par_nrcxaope,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_tpaplica,
                                 INPUT INT(par_flgerlog),
                                 OUTPUT 0,
                                 OUTPUT 0,
                                 OUTPUT "").     
    
    CLOSE STORED-PROC pc_validar_tipo_aplicacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_validar_tipo_aplicacao.pr_cdcritic 
                              WHEN pc_validar_tipo_aplicacao.pr_cdcritic <> ?
           aux_dscritic = pc_validar_tipo_aplicacao.pr_dscritic
                              WHEN pc_validar_tipo_aplicacao.pr_dscritic <> ? 
           par_tpaplrdc = pc_validar_tipo_aplicacao.pr_tpaplrdc
                              WHEN pc_validar_tipo_aplicacao.pr_tpaplrdc <> ?. 
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
       DO:
           IF aux_dscritic = "" THEN
              DO:
                 FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                    NO-LOCK NO-ERROR.

                 IF AVAIL crapcri THEN
                    ASSIGN aux_dscritic = crapcri.dscritic.

              END.

           CREATE tt-erro.

           ASSIGN tt-erro.cdcritic = aux_cdcritic
                  tt-erro.dscritic = aux_dscritic.
    
           RETURN "NOK".
                          
       END.

    RETURN "OK".

END PROCEDURE.  

/******************************************************************************/
/**                 Procedure para carregar taxa da aplicacao                **/
/******************************************************************************/
PROCEDURE obtem-taxa-aplicacao:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM par_txaplica LIKE craplap.txaplmes             NO-UNDO.
    DEF OUTPUT PARAM par_txaplmes LIKE craplap.txaplica             NO-UNDO.
    DEF OUTPUT PARAM par_dsaplica AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
  
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_obtem_taxa_aplicacao
       aux_handproc = PROC-HANDLE NO-ERROR
                               (INPUT par_cdcooper, 
                                INPUT par_cdageope,
                                INPUT par_nrcxaope,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_tpaplica,
                                INPUT par_cdperapl,
                                INPUT par_vllanmto,
                                INPUT INT(par_flgerlog),
                                OUTPUT 0,
                                OUTPUT 0,
                                OUTPUT "",
                                OUTPUT 0,
                                OUTPUT "").  
   
   CLOSE STORED-PROC pc_obtem_taxa_aplicacao
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
   
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   ASSIGN par_txaplica = pc_obtem_taxa_aplicacao.pr_txaplica
                             WHEN pc_obtem_taxa_aplicacao.pr_txaplica <> ?

          par_txaplmes = pc_obtem_taxa_aplicacao.pr_txaplmes
                             WHEN pc_obtem_taxa_aplicacao.pr_txaplmes <> ?

          par_dsaplica = pc_obtem_taxa_aplicacao.pr_dsaplica
                             WHEN pc_obtem_taxa_aplicacao.pr_dsaplica <> ?

          aux_cdcritic = pc_obtem_taxa_aplicacao.pr_cdcritic 
                             WHEN pc_obtem_taxa_aplicacao.pr_cdcritic <> ?

          aux_dscritic = pc_obtem_taxa_aplicacao.pr_dscritic
                             WHEN pc_obtem_taxa_aplicacao.pr_dscritic <> ?.
    
   IF aux_cdcritic <> 0   OR
      aux_dscritic <> ""  THEN
      DO:
          IF aux_dscritic = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                   NO-LOCK NO-ERROR.

                IF AVAIL crapcri THEN
                   ASSIGN aux_dscritic = crapcri.dscritic.

             END.

          CREATE tt-erro.

          ASSIGN tt-erro.cdcritic = aux_cdcritic
                 tt-erro.dscritic = aux_dscritic.
   
          RETURN "NOK".
                         
      END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/** Procedure que busca dados da aplicacao p/ alteracao, exclusao e inclusao **/
/******************************************************************************/
PROCEDURE buscar-dados-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-tipo-aplicacao.
    DEF OUTPUT PARAM TABLE FOR tt-dados-aplicacao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtdiacar AS INTE                                    NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgregis AS LOGI                                    NO-UNDO.

    DEFINE BUFFER crabdtc FOR crapdtc.

    EMPTY TEMP-TABLE tt-tipo-aplicacao.
    EMPTY TEMP-TABLE tt-dados-aplicacao.
    EMPTY TEMP-TABLE tt-erro.           
    
    IF par_flgerlog THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar dados para " +
                             (IF  par_cddopcao = "E"  THEN
                                  "excluir"
                              ELSE
                                  "incluir") + " aplicacao".

    ASSIGN aux_flgerror = TRUE  
           aux_cdcritic = 0
           aux_dscritic = "".
    
    DO WHILE TRUE:
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        RUN obtem-tipos-aplicacao (INPUT par_cdcooper,
                                   INPUT par_cdageope,
                                   INPUT par_nrcxaope,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT FALSE,
                                  OUTPUT TABLE tt-tipo-aplicacao,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        IF  par_cddopcao = "I"  THEN  /** Inclusao **/
            DO:
                ASSIGN aux_flgerror = FALSE.
                LEAVE.
            END.

        FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                           craprda.nrdconta = par_nrdconta AND
                           craprda.nraplica = par_nraplica
                           NO-LOCK USE-INDEX craprda2 NO-ERROR.

        IF  NOT AVAILABLE craprda  THEN
            DO:
                FIND craprac WHERE craprac.cdcooper = par_cdcooper AND
                                   craprac.nrdconta = par_nrdconta AND
                                   craprac.nraplica = par_nraplica
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE craprac THEN
                    DO:
                        ASSIGN aux_cdcritic = 426
                               aux_flgerror = TRUE.    
                        LEAVE.
                    END.
                ELSE
                    ASSIGN aux_flgerror = FALSE.
            END.
        ELSE
            DO:
                FIND craplap WHERE craplap.cdcooper = par_cdcooper     AND
                                   craplap.dtmvtolt = par_dtmvtolt     AND
                                   craplap.cdagenci = craprda.cdagenci AND
                                   craplap.cdbccxlt = craprda.cdbccxlt AND
                                   craplap.nrdolote = craprda.nrdolote AND
                                   craplap.nrdconta = par_nrdconta     AND
                                   craplap.nraplica = par_nraplica
                                   NO-LOCK USE-INDEX craplap1 NO-ERROR.

                IF  NOT AVAILABLE craprda  THEN
                    DO:
                        ASSIGN aux_cdcritic = 90.
                        LEAVE.
                    END.
        
                IF  craprda.dtmvtolt <> par_dtmvtolt  THEN
                    DO:                                   
                        ASSIGN aux_dscritic = "ATENCAO! So podem ser excluidas " +
                                              "aplicacoes feitas na data de HOJE!".
                        LEAVE.
                    END.
        
                FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper     AND
                                  (crapdtc.tpaplrdc = 1                OR
                                   crapdtc.tpaplrdc = 2)               AND
                                   crapdtc.tpaplica = craprda.tpaplica NO-LOCK NO-ERROR.
        
                IF  NOT AVAILABLE crapdtc  THEN
                    DO:
                        ASSIGN aux_cdcritic = 346.
                        LEAVE.
                    END.
        
                ASSIGN aux_qtdiacar = IF  crapdtc.tpaplrdc = 1  THEN 
                                          0
                                      ELSE
                                          craprda.qtdiauti.
        
                FIND FIRST crapttx WHERE crapttx.cdcooper  = par_cdcooper     AND
                                         crapttx.tptaxrdc  = craprda.tpaplica AND
                                         crapttx.qtdiaini <= craprda.qtdiaapl AND
                                         crapttx.qtdiafim >= craprda.qtdiaapl AND
                                         crapttx.qtdiacar  = aux_qtdiacar
                                         NO-LOCK NO-ERROR.
        
                IF  NOT AVAILABLE crapttx  THEN
                    DO:                      
                        ASSIGN aux_cdcritic = 892.
                        LEAVE.
                    END.
        
                ASSIGN aux_dsaplica = "".
        
                IF  crapdtc.tpaplrdc = 2  THEN /* RDCPOS */
                    DO:
                        FIND crabdtc WHERE crabdtc.cdcooper = par_cdcooper     AND
                                           crabdtc.tpaplica = craprda.tpnomapl AND
                                           crabdtc.tpaplrdc = 3                
                                           NO-LOCK NO-ERROR.
        
                        ASSIGN aux_nmprdcom = IF  AVAIL crabdtc  THEN
                                                  crabdtc.dsaplica    
                                              ELSE
                                                  "".
                        ASSIGN aux_dsaplica = "RDCPOS".
                    END.
                ELSE
                  ASSIGN aux_dsaplica = "RDCPRE"
                         aux_nmprdcom = ?.

                ASSIGN aux_flgerror = FALSE.
        
                LEAVE.
            END.
      
      LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF  aux_flgerror  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF AVAILABLE tt-erro  THEN
              ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                        ASSIGN aux_dscritic = "Nao foi possivel carregar " +
                                              "os dados.".

                    RUN gera_erro (INPUT par_cdcooper,                         
                                   INPUT par_cdageope,                         
                                   INPUT par_nrcxaope,                         
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

    CREATE tt-dados-aplicacao.
    ASSIGN tt-dados-aplicacao.tpaplrdc = 0
           tt-dados-aplicacao.tpaplica = 0
           tt-dados-aplicacao.nraplica = 0
           tt-dados-aplicacao.qtdiaapl = 0
           tt-dados-aplicacao.dtresgat = ?
           tt-dados-aplicacao.qtdiacar = 0
           tt-dados-aplicacao.cdperapl = 0
           tt-dados-aplicacao.flgdebci = FALSE
           tt-dados-aplicacao.vllanmto = 0
           tt-dados-aplicacao.txaplica = 0
           tt-dados-aplicacao.dsaplica = aux_dsaplica
           tt-dados-aplicacao.dtcarenc = ?.
    
    IF  par_cddopcao = "E"  THEN  /** Exclusao **/
        DO:
          
          IF AVAIL craprda THEN
            DO: 

              ASSIGN tt-dados-aplicacao.tpaplrdc = crapdtc.tpaplrdc
                     tt-dados-aplicacao.tpaplica = craprda.tpaplica
                     tt-dados-aplicacao.nraplica = craprda.nraplica
                     tt-dados-aplicacao.qtdiaapl = craprda.qtdiaapl
                     tt-dados-aplicacao.dtresgat = craprda.dtvencto
                     tt-dados-aplicacao.qtdiacar = IF crapdtc.tpaplrdc = 1 THEN 0 ELSE craprda.qtdiauti          
                     tt-dados-aplicacao.cdperapl = crapttx.cdperapl
                     tt-dados-aplicacao.flgdebci = craprda.flgdebci
                     tt-dados-aplicacao.vllanmto = craprda.vlaplica
                     tt-dados-aplicacao.txaplica = craplap.txaplica
                     tt-dados-aplicacao.dtcarenc = par_dtmvtolt + craprda.qtdiaapl
                     tt-dados-aplicacao.dsaplica = aux_dsaplica
                     tt-dados-aplicacao.nmprdcom = aux_nmprdcom
                     aux_flgregis = TRUE.                                                            
          END.
          ELSE IF AVAIL craprac THEN
            DO:
                FIND craplac WHERE craplac.cdcooper = craprac.cdcooper AND
                                   craplac.nraplica = craprac.nraplica NO-LOCK NO-ERROR NO-WAIT.
                                
                FOR FIRST crapcpc FIELDS(cdprodut nmprodut cdhsraap cdhsnrap) WHERE crapcpc.cdprodut = craprac.cdprodut NO-LOCK. END.
                
                FOR FIRST crapnpc FIELDS(cdnomenc dsnomenc) WHERE crapnpc.cdprodut = crapcpc.cdprodut AND
                                                                  crapnpc.cdnomenc = craprac.cdnomenc NO-LOCK. END.
           
                ASSIGN tt-dados-aplicacao.tpaplrdc = 0
                       tt-dados-aplicacao.tpaplica = crapcpc.cdprodut
                       tt-dados-aplicacao.dsaplica = crapcpc.nmprodut
                       tt-dados-aplicacao.nmprdcom = IF AVAIL crapnpc THEN crapnpc.dsnomenc ELSE crapcpc.nmprodut
                       tt-dados-aplicacao.nraplica = craprac.nraplica
                       tt-dados-aplicacao.qtdiaapl = craprac.qtdiaapl
                       tt-dados-aplicacao.dtresgat = craprac.dtvencto
                       tt-dados-aplicacao.qtdiacar = craprac.qtdiacar
                       tt-dados-aplicacao.cdperapl = 0
                       tt-dados-aplicacao.flgdebci = IF craprac.iddebcti = 0 THEN FALSE ELSE TRUE
                       tt-dados-aplicacao.vllanmto = craprac.vlaplica
                       tt-dados-aplicacao.txaplica = craprac.txaplica
                       tt-dados-aplicacao.dtcarenc = craprac.dtmvtolt + craprac.qtdiacar.

                FOR FIRST crapcpc FIELDS(cdprodut nmprodut) WHERE crapcpc.cdprodut = craprac.cdprodut AND
                                                                  crapcpc.cdhsraap = craplac.cdhistor NO-LOCK. END.
                
                IF AVAIL crapcpc THEN
                  ASSIGN tt-dados-aplicacao.flgrecno = FALSE.
                ELSE
                  ASSIGN tt-dados-aplicacao.flgrecno = TRUE.

                aux_flgregis = TRUE.                                        

            END.
          ELSE
            ASSIGN aux_flgregis = FALSE.

          IF NOT aux_flgregis THEN
            DO:
                FIND craprac WHERE craprac.cdcooper = par_cdcooper AND
                                   craprac.nrdconta = par_nrdconta AND
                                   craprac.nraplica = par_nraplica NO-LOCK NO-ERROR.

                IF AVAIL craprac THEN
                  DO:
                    
                    FOR FIRST crapcpc FIELD(cdprodut nmprodut) WHERE crapcpc.cdprodut = craprac.cdprodut NO-LOCK. END.

                    FOR FIRST crapnpc FIELDS(dsnomenc) WHERE crapnpc.cdprodut = crapcpc.cdprodut AND
                                                             crapnpc.cdnomenc = craprac.cdnomenc NO-LOCK. END.

                    ASSIGN tt-dados-aplicacao.tpaplrdc = 0
                           tt-dados-aplicacao.tpaplica = crapcpc.cdprodut
                           tt-dados-aplicacao.dsaplica = crapcpc.nmprodut
                           tt-dados-aplicacao.nmprdcom = IF AVAIL crapnpc THEN crapnpc.dsnomenc ELSE crapcpc.nmprodut
                           tt-dados-aplicacao.nraplica = craprac.nraplica
                           tt-dados-aplicacao.qtdiaapl = craprac.qtdiaapl
                           tt-dados-aplicacao.dtresgat = craprac.dtvencto
                           tt-dados-aplicacao.qtdiacar = craprac.qtdiacar
                           tt-dados-aplicacao.cdperapl = 0
                           tt-dados-aplicacao.flgdebci = IF craprac.iddebcti = 0 THEN FALSE ELSE TRUE
                           tt-dados-aplicacao.vllanmto = craprac.vlaplica
                           tt-dados-aplicacao.txaplica = craprac.txaplica
                           tt-dados-aplicacao.dtcarenc = craprac.dtmvtolt + craprac.qtdiacar.
                  END.
            END.
        END.

    IF par_flgerlog THEN                                              
        RUN proc_gerar_log (INPUT par_cdcooper,                         
                            INPUT par_cdoperad,                         
                            INPUT aux_dscritic,                         
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
/**            Procedure para validar operacoes de nova aplicacao            **/
/******************************************************************************/
PROCEDURE validar-nova-aplicacao:  

  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdageope AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrcxaope AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_inproces AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_tpaplica AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nraplica AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_qtdiaapl AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_dtresgat AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_qtdiacar AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdperapl AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_flgdebci AS LOGI                            NO-UNDO.
  DEF INPUT PARAM par_vllanmto AS DECI                            NO-UNDO.
  DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
  DEF OUTPUT PARAM TABLE FOR tt-erro.
  
  DEF VAR aux_nraplica AS INTE                                    NO-UNDO.
  DEF VAR aux_dsaplica AS CHAR                                    NO-UNDO.
  DEF VAR aux_tpregist AS INT                                     NO-UNDO.
  DEF VAR aux_vllimite AS DEC                                     NO-UNDO.
  DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

  DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.

  EMPTY TEMP-TABLE tt-msg-confirma.
  EMPTY TEMP-TABLE tt-erro.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
  RUN STORED-PROCEDURE pc_validar_nova_aplic_wt
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper,
                               INPUT par_cdageope,
                               INPUT par_nrcxaope,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_inproces,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               INPUT par_cddopcao,
                               INPUT par_tpaplica,
                               INPUT par_nraplica,
                               INPUT par_qtdiaapl,
                               INPUT par_dtresgat,
                               INPUT par_qtdiacar,
                               INPUT par_cdperapl,
                               INPUT INT(par_flgdebci),
                               INPUT par_vllanmto,
                               INPUT INT(par_flgerlog),
                               OUTPUT "",                             
                               OUTPUT 0,
                               OUTPUT "").
  
  CLOSE STORED-PROC pc_validar_nova_aplic_wt
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
  
  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
  
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_validar_nova_aplic_wt.pr_cdcritic 
                            WHEN pc_validar_nova_aplic_wt.pr_cdcritic <> ?
         aux_dscritic = pc_validar_nova_aplic_wt.pr_dscritic
                            WHEN pc_validar_nova_aplic_wt.pr_dscritic <> ?. 

  IF aux_cdcritic <> 0   OR
     aux_dscritic <> ""  THEN
     DO:
         IF aux_dscritic = "" THEN
            DO:
               FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                  NO-LOCK NO-ERROR.

               IF AVAIL crapcri THEN
                  ASSIGN aux_dscritic = crapcri.dscritic.

            END.

         CREATE tt-erro.

         ASSIGN tt-erro.cdcritic = aux_cdcritic
                tt-erro.dscritic = aux_dscritic.
   
         RETURN "NOK".
                        
     END.

  FOR EACH wt_msg_confirma NO-LOCK:

      CREATE tt-msg-confirma.

      ASSIGN tt-msg-confirma.inconfir = wt_msg_confirma.inconfir
             tt-msg-confirma.dsmensag = wt_msg_confirma.dsmensag.
  
  END.

  RETURN "OK".

END PROCEDURE.
                        
/******************************************************************************/
/**                  Procedure para incluir nova aplicacao                   **/
/******************************************************************************/
PROCEDURE incluir-nova-aplicacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiaapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtresgat AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiacar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgdebci AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nrdocmto AS DEC                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    RUN STORED-PROCEDURE pc_incluir_nova_aplic_wt
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,
                                   INPUT par_cdageope,
                                   INPUT par_nrcxaope,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_tpaplica,
                                   INPUT par_qtdiaapl,
                                   INPUT par_dtresgat,
                                   INPUT par_qtdiacar,
                                   INPUT par_cdperapl,
                                   INPUT INT(par_flgdebci),
                                   INPUT par_vllanmto,
                                   INPUT INT(par_flgerlog),
                                   OUTPUT "",
                                   OUTPUT 0,
                                   OUTPUT 0,
                                   OUTPUT "").
      
    CLOSE STORED-PROC pc_incluir_nova_aplic_wt
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_incluir_nova_aplic_wt.pr_cdcritic 
                              WHEN pc_incluir_nova_aplic_wt.pr_cdcritic <> ?
           aux_dscritic = pc_incluir_nova_aplic_wt.pr_dscritic
                              WHEN pc_incluir_nova_aplic_wt.pr_dscritic <> ?
           par_nrdocmto = pc_incluir_nova_aplic_wt.pr_nrdocmto
                              WHEN pc_incluir_nova_aplic_wt.pr_nrdocmto <> ?.
    
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
       DO:
           IF aux_dscritic = "" THEN
              DO:
                 FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                    NO-LOCK NO-ERROR.

                 IF AVAIL crapcri THEN
                    ASSIGN aux_dscritic = crapcri.dscritic.

              END.

           CREATE tt-erro.

           ASSIGN tt-erro.cdcritic = aux_cdcritic
                  tt-erro.dscritic = aux_dscritic.
    
           RETURN "NOK".
                          
       END.

    FOR EACH wt_msg_confirma NO-LOCK:

        CREATE tt-msg-confirma.

        ASSIGN tt-msg-confirma.inconfir = wt_msg_confirma.inconfir
               tt-msg-confirma.dsmensag = wt_msg_confirma.dsmensag.
  
    END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para excluir nova aplicacao                   **/
/******************************************************************************/
PROCEDURE excluir-nova-aplicacao:

  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdageope AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrcxaope AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-erro.

  EMPTY TEMP-TABLE tt-erro. /*pc_exclui_aplicacao*/

  FIND FIRST craprda WHERE craprda.cdcooper = par_cdcooper AND
                           craprda.nrdconta = par_nrdconta AND
                           craprda.nraplica = par_nraplica NO-ERROR NO-WAIT.

  IF AVAIL craprda THEN
    DO:
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_excluir_nova_aplicacao
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper,
                               INPUT par_cdageope,
                               INPUT par_nrcxaope,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT par_nraplica,
                               INPUT INT(par_flgerlog),
                               OUTPUT 0,
                               OUTPUT "").
    
    CLOSE STORED-PROC pc_excluir_nova_aplicacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_excluir_nova_aplicacao.pr_cdcritic 
                           WHEN pc_excluir_nova_aplicacao.pr_cdcritic <> ?
         aux_dscritic = pc_excluir_nova_aplicacao.pr_dscritic
                           WHEN pc_excluir_nova_aplicacao.pr_dscritic <> ?. 
    END.
  ELSE
    DO:
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_exclui_aplicacao_car
      aux_handproc = PROC-HANDLE NO-ERROR
                               (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_nrcxaope,
                                INPUT par_nraplica,
                                INPUT 1,
                                OUTPUT 0,
                                OUTPUT "").
    
      CLOSE STORED-PROC pc_exclui_aplicacao_car
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
      ASSIGN aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdcritic = pc_exclui_aplicacao_car.pr_cdcritic 
                               WHEN pc_exclui_aplicacao_car.pr_cdcritic <> ?
             aux_dscritic = pc_exclui_aplicacao_car.pr_dscritic
                               WHEN pc_exclui_aplicacao_car.pr_dscritic <> ?.  
    END.

  IF aux_cdcritic <> 0   OR
     aux_dscritic <> ""  THEN
     DO:
         IF aux_dscritic = "" THEN
            DO:
               FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                  NO-LOCK NO-ERROR.

               IF AVAIL crapcri THEN
                  ASSIGN aux_dscritic = crapcri.dscritic.

            END.

         CREATE tt-erro.

         ASSIGN tt-erro.cdcritic = aux_cdcritic
                tt-erro.dscritic = aux_dscritic.
  
         RETURN "NOK".
                        
     END.
  
  RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-extrato-rdca.

    DEF INPUT  PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cdageope AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrcxaope AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                        NO-UNDO.  
    DEF INPUT  PARAM par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_nraplica AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_tpaplica AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_vlsdrdca AS DECI                        NO-UNDO.
    DEF INPUT  PARAM par_dtinicio AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_datafim  AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                        NO-UNDO.    
    DEF INPUT  PARAM par_idorigem AS INTE                        NO-UNDO. 
    DEF INPUT  PARAM par_flgerlog AS LOGI                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extr-rdca.

    DEF VAR aux_tpaplrdc AS INTE                                 NO-UNDO.
    DEF VAR aux_txaplic2 AS DECIMAL DECIMALS 6                   NO-UNDO.
    DEF VAR aux_flgimune AS LOGICAL                              NO-UNDO.
    DEF VAR aux_dsextrat AS CHAR                                 NO-UNDO.
    DEF VAR aux_dtiniimu AS DATE                                 NO-UNDO.
    DEF VAR aux_dtfimimu AS DATE                                 NO-UNDO.
        
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-extr-rdca.
   
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consulta extrato RDCA"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_tpaplrdc = 0
           aux_lsoperad = ",20,18,8,6,9,14,".

    FIND craprda WHERE craprda.cdcooper = par_cdcooper AND
                       craprda.nrdconta = par_nrdconta AND
                       craprda.nraplica = par_nraplica
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE craprda  THEN
        DO:
            ASSIGN aux_cdcritic = 426
                   aux_dscritic = " ".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdageope,
                           INPUT par_nrcxaope,
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
                       crapope.cdoperad = par_cdoperad 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope  THEN
        DO:
            ASSIGN aux_cdcritic = 67
                   aux_dscritic = " ".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdageope,
                           INPUT par_nrcxaope,
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

    IF  par_cdcooper = 3  THEN
        aux_lsoperad = aux_lsoperad + STRING(crapope.cddepart) + ",".

    IF  par_nmdatela = "EXTRDA" THEN
        DO:
            IF  CAN-DO(aux_lsoperad,STRING(crapope.cddepart)) THEN 
                aux_listahis = "113,116,117,118,119,121,124,125,126,143,144," +
                "176,178,179,180,181,182,183,861,862,866,868,871,492,493,494," +
                "495,875,877,876,527,528,529,530,531,533,534,532,472,473,474," +
                "475,463,478,476,477,923,924,1111,1112,1113,1114".
            ELSE
                aux_listahis = "113,116,118,119,121,126,143,144,176,178,179," +
                "183,861,862,868,871,492,493,494,495,875,877,876,527,528,529," +
                "530,531,533,534,532,472,473,474,475,463,478,476,477,923,924," +
                "1111,1112,1113,1114".
        END.
    ELSE
    IF  par_nmdatela = "IMPRES"  THEN
        DO:
            IF  NOT CAN-DO(aux_lsoperad,STRING(crapope.cddepart))   THEN
                aux_listahis = "113,116,118,119,121,126,143,144,176,178,179," +
                               "183,861,862,868,871,492,493,494,495,875,876," +
                               "877,923,924,527,528,529,530,531,533,534,532," +
                               "472,473,474,475,463,478,476,477,1111,1112," +
                               "1113,1114".
            ELSE
                aux_listahis = "113,116,117,118,119,121,124,125,126,143,144," +
                               "176,178,179,183,861,862,868,871,492,493,494," +
                               "495,875,876,877,180,923,924,527,528,529,530," +
                               "531,533,534,532,472,473,474,475,463,478,476," +
                               "477,1111,1112,1113,1114".
        END.
    ELSE
        DO: 
            IF  NOT CAN-DO(aux_lsoperad,STRING(crapope.cddepart)) THEN  
                aux_listahis = "113,116,118,119,121,126,143,144,176,178,179," +
                           "183,861,862,868,871,492,493,494,495,875,876,877," +
                           "472,473,474,475,463,478,476,477,527,528,529,530," +
                           "531,532,533,534,923,924,1111,1112,1113,1114".
            ELSE       
                aux_listahis = "113,116,117,118,119,121,126,143,144,176,178," +
                    "179,183,861,862,868,871,492,493,494,495,875,876,877,180," +
                    "472,473,474,475,463,478,476,477,527,528,529,530,531,532," +
                    "533,534,923,924,1111,1112,1113,1114".
        END.
    
    /* Nao lista aplicacoes resgatadas a mais de 1 ano */
    IF (crapope.cddepart <> 18)   AND
        par_nmdatela <> "EXTRDA"  THEN
        IF  craprda.insaqtot = 1                    AND
            craprda.dtsaqtot < (par_dtmvtolt - 365) THEN
            RETURN "OK".
                        
    /* Tratamento para as aplicacoes da Cecrisacred que foram convertidas */  
    IF  par_cdcooper = 5               AND 
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
            FIND crapdtc WHERE crapdtc.cdcooper = par_cdcooper AND
                              (crapdtc.tpaplrdc = 1            OR
                               crapdtc.tpaplrdc = 2)           AND
                               crapdtc.tpaplica = craprda.tpaplica 
                               NO-LOCK NO-ERROR.
                               
            IF  AVAILABLE crapdtc  THEN
                ASSIGN aux_dsaplica = STRING(craprda.nraplica,"zzz,zz9") +
                                      " - " + STRING(crapdtc.dsaplica,"x(6)")
                       aux_tpaplrdc = crapdtc.tpaplrdc.
            ELSE
                ASSIGN aux_dsaplica = STRING(craprda.nraplica,"zzz,zz9").
        END.
    
    RUN sistema/generico/procedures/b1wgen0159.p
                                 PERSISTENT SET h-b1wgen0159.

    RUN verifica-periodo-imune IN h-b1wgen0159(INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                              OUTPUT aux_flgimune,
                                              OUTPUT aux_dtiniimu,
                                              OUTPUT aux_dtfimimu,
                                              OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0159.    
        
    FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper AND
                           craplap.nrdconta = par_nrdconta AND
                           craplap.nraplica = par_nraplica AND
                           CAN-DO(aux_listahis,STRING(craplap.cdhistor)) 
                           USE-INDEX craplap5 NO-LOCK:
        
        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplap.cdhistor 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craphis  THEN
            DO:
                ASSIGN aux_cdcritic = 80
                       aux_dscritic = " ".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdageope,
                               INPUT par_nrcxaope,
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

        ASSIGN aux_dshistor = STRING(craphis.cdhistor,"9999") + 
                              "-" + craphis.dshistor.
        
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
                        ASSIGN aux_cdcritic = 83
                               aux_dscritic = " ".
                     
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdageope,
                                       INPUT par_nrcxaope,
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

        IF   aux_flgimune THEN
             DO:
                  IF  (craplap.cdhistor = 475             OR
                       craplap.cdhistor = 532)            AND
                       craplap.dtmvtolt >= aux_dtiniimu   AND
                      (aux_dtfimimu      = ?              OR
                      (aux_dtfimimu     <> ?              AND
                       craplap.dtmvtolt <= aux_dtfimimu)) THEN
                       aux_dsextrat = craphis.dsextrat + "*".
                  ELSE
                       aux_dsextrat = craphis.dsextrat.
             END.
        ELSE
             aux_dsextrat = craphis.dsextrat.
            
        CREATE tt-extr-rdca.
        ASSIGN tt-extr-rdca.dtmvtolt = craplap.dtmvtolt
               tt-extr-rdca.dshistor = IF  par_nmdatela = "EXTRDA" AND 
                                           NOT AVAIL crapdtc  THEN
                                           craphis.dshistor
                                       ELSE
                                           aux_dshistor
               tt-extr-rdca.nrdocmto = craplap.nrdocmto
               tt-extr-rdca.indebcre = craphis.indebcre
               tt-extr-rdca.vllanmto = craplap.vllanmto
               tt-extr-rdca.cdagenci = craplap.cdagenci
               tt-extr-rdca.vlpvlrgt = IF  craplap.cdhistor = 534  THEN
                                           STRING(craplap.vlpvlrgt,"zzzzz,zz9.99")
                                       ELSE 
                                           ""
               tt-extr-rdca.cdhistor = craplap.cdhistor
               tt-extr-rdca.vlsldapl = aux_vlstotal
               tt-extr-rdca.dsaplica = aux_dsaplica
               tt-extr-rdca.tpaplrdc = aux_tpaplrdc
               tt-extr-rdca.dsextrat = aux_dsextrat
               tt-extr-rdca.nraplica = craplap.nraplica.

        IF (par_nmdatela = "EXTRDA"  OR 
            par_nmdatela = "IMPRES") AND 
            CAN-DO("5,3",STRING(craprda.tpaplica))  THEN
            ASSIGN tt-extr-rdca.txaplica = craplap.txaplmes.
        ELSE
            ASSIGN tt-extr-rdca.txaplica = craplap.txaplica.

    END. /* Fim do FOR EACH craplap */

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

PROCEDURE critica-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "Registro sendo alterado em outro terminal (" + 
                          par_nmtabela + ").".

    IF  par_idorigem = 3  THEN  /** InternetBank **/
        RETURN.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
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

PROCEDURE consulta-agendamento:
                              
    DEF INPUT  PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador  AS CHAR                        NO-UNDO.  
    DEF INPUT  PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-id-seqttl     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-tip-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cdprogra      AS CHAR                        NO-UNDO.    
    DEF INPUT  PARAM p-origem        AS INTE                        NO-UNDO.
                                       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-agendamento.
    
    DEF VAR aux_contador AS INTE     NO-UNDO INIT 0.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO. 

    /* Variaveis para copia das informacoes do XML */ 
    
    DEF VAR aux_qtdiacar  LIKE crapaar.qtdiacar NO-UNDO. 
    
    DEF VAR aux_cdcooper  LIKE crapaar.cdcooper NO-UNDO.
    DEF VAR aux_cdageass  LIKE crapaar.cdageass NO-UNDO.
    DEF VAR aux_cdagenci  LIKE crapaar.cdagenci NO-UNDO.
    DEF VAR aux_cdoperad  LIKE crapaar.cdoperad NO-UNDO.
    DEF VAR aux_cdsitaar  LIKE crapaar.cdsitaar NO-UNDO.
    DEF VAR aux_dtcancel  LIKE crapaar.dtcancel NO-UNDO.
    DEF VAR aux_dtcarenc  LIKE crapaar.dtcarenc NO-UNDO.
    DEF VAR aux_dtiniaar  LIKE crapaar.dtiniaar NO-UNDO.
    DEF VAR aux_dtvencto  LIKE crapaar.dtvencto NO-UNDO.
    DEF VAR aux_dtmvtolt  LIKE crapaar.dtmvtolt NO-UNDO.
    DEF VAR aux_flgctain  AS INTEGER            NO-UNDO.
    DEF VAR aux_flgresin  AS INTEGER            NO-UNDO.
    DEF VAR aux_flgtipar  AS INTEGER            NO-UNDO.
    DEF VAR aux_flgtipin  AS INTEGER            NO-UNDO.
    DEF VAR aux_hrtransa  LIKE crapaar.hrtransa NO-UNDO.
    DEF VAR aux_idseqttl  LIKE crapaar.idseqttl NO-UNDO.
    DEF VAR aux_nrctraar  LIKE crapaar.nrctraar NO-UNDO.
    DEF VAR aux_nrdconta  LIKE crapaar.nrdconta NO-UNDO.
    DEF VAR aux_nrdocmto  LIKE crapaar.nrdocmto NO-UNDO.
    DEF VAR aux_nrmesaar  LIKE crapaar.nrmesaar NO-UNDO.
    DEF VAR aux_qtmesaar  LIKE crapaar.qtmesaar NO-UNDO.
    DEF VAR aux_vlparaar  LIKE crapaar.vlparaar NO-UNDO.
                                      
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_consulta_agendmto_car
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, 
                          INPUT p-tip-aplicacao, 
                          INPUT p-nro-conta,     
                          INPUT p-id-seqttl,
                          INPUT p-nro-aplicacao, 
                          OUTPUT "",
                          OUTPUT 0,               
                          OUTPUT "").
     
    CLOSE STORED-PROC pc_consulta_agendmto_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_consulta_agendmto_car.pr_cdcritic 
                          WHEN pc_consulta_agendmto_car.pr_cdcritic <> ?
           aux_dscritic = pc_consulta_agendmto_car.pr_dscritic 
                          WHEN pc_consulta_agendmto_car.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        RETURN "NOK".
        
    END.
       
    EMPTY TEMP-TABLE tt-agendamento.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    /*************************************************************/
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_agendmto_car.pr_clobxmlc. 

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
   
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
    xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.

    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

        xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

        IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
             NEXT. 

        /* Limpar variaveis  */ 
        ASSIGN aux_cdcooper = 0
               aux_cdageass = 0
               aux_cdagenci = 0
               aux_cdoperad = ""
               aux_cdsitaar = 0
               aux_dtcancel = ?
               aux_dtcarenc = ?
               aux_dtiniaar = ?
               aux_dtvencto = ?
               aux_dtmvtolt = ?
               aux_flgctain = 0
               aux_flgresin = 0
               aux_flgtipar = 0
               aux_flgtipin = 0
               aux_hrtransa = 0
               aux_idseqttl = 0
               aux_nrctraar = 0
               aux_nrdconta = 0
               aux_nrdocmto = 0
               aux_nrmesaar = 0
               aux_qtdiacar = 0
               aux_qtmesaar = 0
               aux_vlparaar = 0.                                           

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

            xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 

            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 

            xField:GET-CHILD(xText,1) NO-ERROR. 

            /* Se nao vier conteudo na TAG */ 
            IF ERROR-STATUS:ERROR             OR  
               ERROR-STATUS:NUM-MESSAGES > 0  THEN
               NEXT.
                    
            ASSIGN aux_cdcooper = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdcooper"
                   aux_cdageass = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdaegass"
                   aux_cdagenci = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdagenci"
                   aux_cdoperad = xText:NODE-VALUE       WHEN xField:NAME = "cdoperad"
                   aux_cdsitaar = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdsitaar"
                   aux_dtcancel = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcancel"
                   aux_dtcarenc = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcarenc"
                   aux_dtiniaar = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtiniaar"
                   aux_dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto" 
                   aux_dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt"
                   aux_flgctain = INT(xText:NODE-VALUE)  WHEN xField:NAME = "flgctain"
                   aux_flgresin = INT(xText:NODE-VALUE)  WHEN xField:NAME = "flgresin"
                   aux_flgtipar = INT(xText:NODE-VALUE)  WHEN xField:NAME = "flgtipar"
                   aux_flgtipin = INT(xText:NODE-VALUE)  WHEN xField:NAME = "flgtipin"
                   aux_hrtransa = INT(xText:NODE-VALUE)  WHEN xField:NAME = "hrtransa"
                   aux_idseqttl = INT(xText:NODE-VALUE)  WHEN xField:NAME = "idseqttl"
                   aux_nrctraar = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrctraar"
                   aux_nrdconta = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdconta"
                   aux_nrdocmto = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdocmto"
                   aux_nrmesaar = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrmesaar"
                   aux_qtdiacar = INT(xText:NODE-VALUE)  WHEN xField:NAME = "qtdiacar"
                   aux_qtmesaar = INT(xText:NODE-VALUE)  WHEN xField:NAME = "qtmesaar"
                   aux_vlparaar = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlparaar".
            
        END. 

        CREATE tt-agendamento.
        ASSIGN tt-agendamento.cdcooper = aux_cdcooper.
               tt-agendamento.cdageass = aux_cdageass.
               tt-agendamento.cdagenci = aux_cdagenci.
               tt-agendamento.cdoperad = aux_cdoperad.
               tt-agendamento.cdsitaar = aux_cdsitaar.
               tt-agendamento.dtcancel = aux_dtcancel.
               tt-agendamento.dtcarenc = aux_dtcarenc.
               tt-agendamento.dtiniaar = aux_dtiniaar.
               tt-agendamento.dtvencto = aux_dtvencto.
               tt-agendamento.dtmvtolt = aux_dtmvtolt.
               tt-agendamento.flgctain = IF aux_flgctain = 0 THEN
                                            FALSE
                                         ELSE
                                            TRUE.
               tt-agendamento.flgresin = IF aux_flgresin = 0 THEN
                                            FALSE
                                         ELSE 
                                            TRUE.
               tt-agendamento.flgtipar = IF aux_flgtipar = 0 THEN
                                            FALSE
                                         ELSE 
                                            TRUE.
               tt-agendamento.flgtipin = IF aux_flgtipin = 0 THEN
                                            FALSE
                                         ELSE
                                            TRUE.
               tt-agendamento.hrtransa = aux_hrtransa.
               tt-agendamento.idseqttl = aux_idseqttl.
               tt-agendamento.nrctraar = aux_nrctraar.
               tt-agendamento.nrdconta = aux_nrdconta.
               tt-agendamento.nrdocmto = aux_nrdocmto.
               tt-agendamento.nrmesaar = aux_nrmesaar.
               tt-agendamento.qtdiacar = aux_qtdiacar.
               tt-agendamento.qtmesaar = aux_qtmesaar.
               tt-agendamento.vlparaar = aux_vlparaar.

               VALIDATE tt-agendamento.
    END.
    
    SET-SIZE(ponteiro_xml) = 0. 

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE consulta-agendamento-det:

    DEF INPUT  PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador  AS CHAR                        NO-UNDO.  
    DEF INPUT  PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-id-seqttl     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-flgtipar      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nrdocmto      LIKE crapaar.nrdocmto          NO-UNDO.
                                       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-agen-det.
    
    DEF VAR aux_contador AS INTE     NO-UNDO INIT 0.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO. 

    /* Variaveis para copia das informacoes do XML */ 
    DEF VAR aux_cdcooper  LIKE crapaar.cdcooper NO-UNDO.
    DEF VAR aux_cdageass  LIKE crapaar.cdageass NO-UNDO.
    DEF VAR aux_cdagenci  LIKE crapaar.cdagenci NO-UNDO.
    DEF VAR aux_cdoperad  LIKE crapaar.cdoperad NO-UNDO.

    DEF VAR aux_cdbccxlt  LIKE craplau.cdbccxlt NO-UNDO.
    DEF VAR aux_cdbccxpg  LIKE craplau.cdbccxpg NO-UNDO.
    DEF VAR aux_cdhistor  LIKE craplau.cdhistor NO-UNDO.
    DEF VAR aux_dtdebito  LIKE craplau.dtdebito NO-UNDO.
    DEF VAR aux_dtmvtolt  LIKE craplau.dtmvtolt NO-UNDO.
    DEF VAR aux_dtmvtopg  LIKE craplau.dtmvtopg NO-UNDO.
    DEF VAR aux_insitlau  LIKE craplau.insitlau NO-UNDO.
    DEF VAR aux_nrdconta  LIKE craplau.nrdconta NO-UNDO.
    DEF VAR aux_nrdctabb  LIKE craplau.nrdctabb NO-UNDO.
    DEF VAR aux_nrdolote  LIKE craplau.nrdolote NO-UNDO.
    DEF VAR aux_nrseqlan  LIKE craplau.nrseqlan NO-UNDO.
    DEF VAR aux_tpdvalor  LIKE craplau.tpdvalor NO-UNDO.
    DEF VAR aux_vllanaut  LIKE craplau.vllanaut NO-UNDO.
    DEF VAR aux_nrdocmto  AS   CHAR             NO-UNDO.
 
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }              

    IF  p-flgtipar = 0 THEN /*aplicacao*/
        DO:
          ASSIGN aux_nrdolote = 32001
                 aux_cdhistor = 527.
        END.
    ELSE                    /*resgate*/
        DO:
            ASSIGN aux_nrdolote = 32002
                   aux_cdhistor = 530.
        END.

    RUN STORED-PROCEDURE pc_cons_det_agendmto_car
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, 
                          INPUT aux_nrdolote,
                          INPUT p-nrdocmto, 
                          INPUT p-nro-conta,     
                          INPUT aux_cdhistor,
                          OUTPUT "",
                          OUTPUT 0,               
                          OUTPUT "").
     
    CLOSE STORED-PROC pc_cons_det_agendmto_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_cons_det_agendmto_car.pr_cdcritic 
                          WHEN pc_cons_det_agendmto_car.pr_cdcritic <> ?
           aux_dscritic = pc_cons_det_agendmto_car.pr_dscritic 
                          WHEN pc_cons_det_agendmto_car.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        RETURN "NOK".
        
    END.
       
    EMPTY TEMP-TABLE tt-agen-det.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }             

    /*************************************************************/
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_cons_det_agendmto_car.pr_clobxmlc. 

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
   
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
    xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.

    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

        xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

        IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
             NEXT. 

        /* Limpar variaveis  */ 
        ASSIGN aux_cdcooper = 0
               aux_cdageass = 0
               aux_cdagenci = 0
               aux_cdoperad = "".

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

            xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 

            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 

            xField:GET-CHILD(xText,1) NO-ERROR. 

            /* Se nao vier conteudo na TAG */ 
            IF ERROR-STATUS:ERROR             OR  
               ERROR-STATUS:NUM-MESSAGES > 0  THEN
               NEXT.

            ASSIGN aux_cdcooper = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdcooper"
                   aux_cdageass = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdaegass"
                   aux_cdagenci = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdagenci"
                   aux_cdoperad = xText:NODE-VALUE       WHEN xField:NAME = "cdoperad"
                   aux_cdbccxlt = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdbccxlt"
                   aux_cdbccxpg = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdbccxpg"
                   aux_cdhistor = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdhistor"
                   aux_dtdebito = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtdebito"
                   aux_dtmvtolt = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtmvtolt"
                   aux_dtmvtopg = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtmvtopg"
                   aux_insitlau = INT(xText:NODE-VALUE)  WHEN xField:NAME = "insitlau"
                   aux_nrdconta = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdconta"
                   aux_nrdctabb = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdctabb"
                   aux_nrdolote = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdolote"
                   aux_nrseqlan = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrseqlan"
                   aux_tpdvalor = INT(xText:NODE-VALUE)  WHEN xField:NAME = "tpdvalor"
                   aux_vllanaut = DEC(xText:NODE-VALUE)  WHEN xField:NAME = "vllanaut"
                   aux_nrdocmto = xText:NODE-VALUE       WHEN xField:NAME = "nrdocmto".

        END. 

        CREATE tt-agen-det.
        ASSIGN tt-agen-det.cdcooper = aux_cdcooper
               tt-agen-det.cdagenci = aux_cdagenci
               tt-agen-det.cdbccxlt = aux_cdbccxlt
               tt-agen-det.cdbccxpg = aux_cdbccxpg
               tt-agen-det.cdhistor = aux_cdhistor
               tt-agen-det.dtdebito = aux_dtdebito
               tt-agen-det.dtmvtolt = aux_dtmvtolt
               tt-agen-det.dtmvtopg = aux_dtmvtopg
               tt-agen-det.insitlau = aux_insitlau
               tt-agen-det.nrdconta = aux_nrdconta
               tt-agen-det.nrdctabb = aux_nrdctabb
               tt-agen-det.nrdolote = aux_nrdolote
               tt-agen-det.nrseqlan = aux_nrseqlan
               tt-agen-det.tpdvalor = aux_tpdvalor
               tt-agen-det.vllanaut = aux_vllanaut
               tt-agen-det.cdcooper = aux_cdcooper
               tt-agen-det.nrdocmto = aux_nrdocmto.

        VALIDATE tt-agen-det.
    END.

    SET-SIZE(ponteiro_xml) = 0. 

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
                          
    VALIDATE tt-agen-det.

    RETURN "OK".

END PROCEDURE.
    
PROCEDURE incluir-novo-agendamento:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_flgtipar  AS      INTE                         NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl             NO-UNDO.
    DEF INPUT PARAM par_vlparaar  LIKE    crapaar.vlparaar             NO-UNDO.
    DEF INPUT PARAM par_flgtipin  AS      INTE                         NO-UNDO.
    DEF INPUT PARAM par_qtdiacar  LIKE    crapaar.qtdiacar             NO-UNDO.
    DEF INPUT PARAM par_qtmesaar  LIKE    crapaar.qtmesaar             NO-UNDO.
    DEF INPUT PARAM par_dtiniaar  LIKE    crapaar.dtiniaar             NO-UNDO.
    DEF INPUT PARAM par_dtdiaaar  LIKE    crapaar.dtdiaaar             NO-UNDO.
    DEF INPUT PARAM par_dtvencto  LIKE    crapaar.dtvencto             NO-UNDO.
    DEF INPUT PARAM par_qtdiaven  LIKE    crapaar.qtdiacar             NO-UNDO.
    DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad             NO-UNDO.
    DEF INPUT PARAM par_cdprogra  AS      CHAR                         NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS      INTE                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_incluir_novo_agendmto
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT par_flgtipar, 
                          INPUT par_nrdconta,     
                          INPUT par_idseqttl,
                          INPUT par_vlparaar,
                          INPUT par_flgtipin, 
                          INPUT par_qtdiacar,
                          INPUT par_qtmesaar,
                          INPUT par_dtdiaaar,
                          INPUT par_dtiniaar,
                          INPUT par_dtvencto, 
                          INPUT par_qtdiaven,
                          INPUT par_cdoperad,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_incluir_novo_agendmto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_incluir_novo_agendmto.pr_cdcritic 
                          WHEN pc_incluir_novo_agendmto.pr_cdcritic <> ?
           aux_dscritic = pc_incluir_novo_agendmto.pr_dscritic 
                          WHEN pc_incluir_novo_agendmto.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        VALIDATE tt-erro.

        RETURN "NOK".
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE validar-novo-agendamento:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_flgtipar  AS      INTE                         NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl             NO-UNDO.
    DEF INPUT PARAM par_vlparaar  LIKE    crapaar.vlparaar             NO-UNDO.
    DEF INPUT PARAM par_flgtipin  AS      INTE                         NO-UNDO.
    DEF INPUT PARAM par_qtdiacar  LIKE    crapaar.qtdiacar             NO-UNDO.
    DEF INPUT PARAM par_qtmesaar  LIKE    crapaar.qtmesaar             NO-UNDO.
    DEF INPUT PARAM par_dtiniaar  LIKE    crapaar.dtiniaar             NO-UNDO.
    DEF INPUT PARAM par_dtdiaaar  LIKE    crapaar.dtdiaaar             NO-UNDO.
    DEF INPUT PARAM par_dtvencto  LIKE    crapaar.dtvencto             NO-UNDO.
    DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad             NO-UNDO.
    DEF INPUT PARAM par_cdprogra  AS      CHAR                         NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS      INTE                         NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_validar_novo_agendmto
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT par_flgtipar, 
                          INPUT par_nrdconta,     
                          INPUT par_idseqttl,
                          INPUT par_vlparaar,
                          INPUT par_flgtipin, 
                          INPUT par_qtdiacar,
                          INPUT par_qtmesaar,
                          INPUT par_dtdiaaar,
                          INPUT par_dtiniaar,
                          INPUT par_dtvencto, 
                          INPUT par_cdoperad,
                          INPUT par_idorigem,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_validar_novo_agendmto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_validar_novo_agendmto.pr_cdcritic 
                          WHEN pc_validar_novo_agendmto.pr_cdcritic <> ?
           aux_dscritic = pc_validar_novo_agendmto.pr_dscritic 
                          WHEN pc_validar_novo_agendmto.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        RETURN "NOK".
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE soma-data-vencto:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl             NO-UNDO.
    DEF INPUT PARAM par_qtdiacar  LIKE    crapaar.qtdiacar             NO-UNDO.
    DEF INPUT PARAM par_dtiniaar  LIKE    crapaar.dtiniaar             NO-UNDO.
    DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad             NO-UNDO.
    DEF INPUT PARAM par_cdprogra  AS      CHAR                         NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS      INTE                         NO-UNDO.

    DEF OUTPUT PARAM par_dtvencto LIKE    crapaar.dtvencto             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
        

    RUN STORED-PROCEDURE pc_soma_data_vencto
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT par_qtdiacar,
                          INPUT par_dtiniaar,
                          OUTPUT ?,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_soma_data_vencto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_soma_data_vencto.pr_cdcritic 
                          WHEN pc_soma_data_vencto.pr_cdcritic <> ?
           aux_dscritic = pc_soma_data_vencto.pr_dscritic 
                          WHEN pc_soma_data_vencto.pr_dscritic <> ?
           par_dtvencto = pc_soma_data_vencto.pr_dtvencto
                          WHEN pc_soma_data_vencto.pr_dtvencto <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO: 

        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.

        RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE excluir-agendamento:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl             NO-UNDO.
    DEF INPUT PARAM par_nrctraar  LIKE    crapaar.nrctraar             NO-UNDO.
    DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_excluir_agendmto
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT par_nrdconta,     
                          INPUT par_idseqttl,
                          INPUT par_nrctraar,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_excluir_agendmto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_excluir_agendmto.pr_cdcritic 
                          WHEN pc_excluir_agendmto.pr_cdcritic <> ?
           aux_dscritic = pc_excluir_agendmto.pr_dscritic 
                          WHEN pc_excluir_agendmto.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        RETURN "NOK".
        
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE excluir-agendamento-det:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl             NO-UNDO.
    DEF INPUT PARAM par_flgtipar  AS      INTEGER                      NO-UNDO.
    DEF INPUT PARAM par_nrdocmto  AS      CHAR                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_excluir_det_agendmto
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT par_nrdconta,     
                          INPUT par_idseqttl,
                          INPUT par_nrdocmto,
                          INPUT par_flgtipar,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_excluir_det_agendmto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_excluir_det_agendmto.pr_cdcritic 
                          WHEN pc_excluir_det_agendmto.pr_cdcritic <> ?
           aux_dscritic = pc_excluir_det_agendmto.pr_dscritic 
                          WHEN pc_excluir_det_agendmto.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        RETURN "NOK".
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza-status-agendmto:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl             NO-UNDO.
    DEF INPUT PARAM par_detagend  AS      CHAR                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_atual_status_agendmto
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT par_nrdconta,     
                          INPUT par_idseqttl,
                          INPUT par_detagend,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_atual_status_agendmto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_atual_status_agendmto.pr_cdcritic 
                          WHEN pc_atual_status_agendmto.pr_cdcritic <> ?
           aux_dscritic = pc_atual_status_agendmto.pr_dscritic 
                          WHEN pc_atual_status_agendmto.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        RETURN "NOK".
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE cons-qtd-mes-age:

    DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper             NO-UNDO.
    DEF INPUT PARAM par_cdagenci  LIKE    crapage.cdagenci             NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE    crapass.nrdconta             NO-UNDO.
    DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad             NO-UNDO.
    DEF INPUT PARAM par_cdprogra  AS      CHAR                         NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS      INTE                         NO-UNDO.

    DEF OUTPUT PARAM par_qtmesage LIKE    crapage.qtmesage             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_cons_mes_age
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, 
                          INPUT 90, /* cdagenci - Internet */
                          INPUT par_nrdconta, 
                          OUTPUT 0,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_cons_mes_age
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_cons_mes_age.pr_cdcritic 
                          WHEN pc_cons_mes_age.pr_cdcritic <> ?
           aux_dscritic = pc_cons_mes_age.pr_dscritic 
                          WHEN pc_cons_mes_age.pr_dscritic <> ?
           par_qtmesage = pc_cons_mes_age.pr_qtmesage
                          WHEN pc_cons_mes_age.pr_qtmesage <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO: 

        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**             Procedure para buscar o intervalo entre duas datas           **/
/******************************************************************************/
PROCEDURE busca-intervalo-dias:

    DEF  INPUT PARAM par_cdcooper LIKE    crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE    crapaar.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE    crapaar.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE    crapaar.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS      CHAR                         NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS      INTE                         NO-UNDO.
    DEF  INPUT PARAM par_dtiniitr AS      DATE                         NO-UNDO.
    DEF  INPUT PARAM par_dtfinitr AS      DATE                         NO-UNDO.

    DEF OUTPUT PARAM par_numrdias AS      INTE                         NO-UNDO.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_intervalo_dias
          aux_handproc = PROC-HANDLE NO-ERROR
                           (INPUT par_dtiniitr, 
                            INPUT par_dtfinitr,
                            OUTPUT 0).

    CLOSE STORED-PROC pc_intervalo_dias
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_numrdias = 0
           par_numrdias = pc_intervalo_dias.pr_numrdias
                          WHEN pc_intervalo_dias.pr_numrdias <> ?.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**             Procedure para buscar a proxima data de movimento            **/
/******************************************************************************/
PROCEDURE busca-proxima-data-movimento:

    DEF  INPUT PARAM par_cdcooper LIKE    crapcop.cdcooper             NO-UNDO.
    DEF OUTPUT PARAM par_dtmvtopr AS      CHAR                         NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_prox_data_mov
          aux_handproc = PROC-HANDLE NO-ERROR
                           (INPUT par_cdcooper, 
                            OUTPUT ?,
                            OUTPUT 0,
                            OUTPUT "").

    CLOSE STORED-PROC pc_prox_data_mov
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dtmvtopr = " "
           par_dtmvtopr = STRING(pc_prox_data_mov.pr_dtmvtopr,"99/99/9999")
                          WHEN pc_prox_data_mov.pr_dtmvtopr <> ?.
    
    RETURN "OK".

END PROCEDURE.
