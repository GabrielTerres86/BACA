/*..................................................................................

    Programa: b1wgen0053.p
    Autor   : Jose Luis (DB1)
    Data    : Janeiro/2010                   Ultima atualizacao: 16/11/2017

    Objetivo  : Tranformacao BO tela CONTAS - Pessoa Juridica

    Alteracoes: 04/04/2013 - Incluido a chamada da procedure alerta_fraude
                             dentro da procedure grava_dados (Adriano).
    
                14/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James).
                
                04/09/2013 - Incluido a verificacao para alteracao de identificacao
                             e gravacao na crapdoc (Jean Michel).
                             
                04/10/2013 - Incluido a verificacao para alteracao na procedure
                             grava_dados e gravacao na crapdoc (Jean Michel).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)   
                
                05/05/2014 - Alterar tpdocmto de 15 para 10 (Lucas R.)     
                
                01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)

                25/10/2016 - Melhoria 310 - Verificacao da data de validade da
				             licença (Tiago/Thiago).
                     
                17/01/2017 - Adicionado chamada a procedure de replicacao do 
                             nome fantasia para o CDC. (Reinert Prj 289)     	

                11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                             Projeto 339 - CRM. (Lombardi)		                  		  
                 
                22/09/2017 - Adicionar tratamento para caso o inpessoa for juridico gravar 
                             o idseqttl como zero (Luacas Ranghetti #756813)

				09/10/2017 - Projeto 410 - RF 52 / 62 - Diogo (Mouts): alterada 
                             procedure grava_dados com as regras:
                             - se o campo tpregtrb (regime de tributaçao) for Nao, 
                               gravar o campo idimpdsn com zero.
                             - se o campo tpregtrb for Sim, gravar o campo 
                               idimpdsn com o valor 1; 
                               Porém se o idimpdsn já estiver com 2, nao deve ser 
                               alterado pois indica que a declaraçao já foi impressa.
                             
                16/11/2017 - Adicionar tratamento para licenca socio ambiental do idseqttl
                             como zero para pessoa juridica (Lucas Ranghetti #786704)
                             
                13/02/2018 - Ajustes na geraçao de pendencia de digitalizaçao.
                             PRJ366 - tipo de conta (Odirlei-AMcom)             
..................................................................................*/


/*................................ DEFINICOES ....................................*/


{ sistema/generico/includes/b1wgen0053tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.

/*................................ PROCEDURES ...............................*/
PROCEDURE busca_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 
    DEF OUTPUT PARAM TABLE FOR tt-dados-jur. 

    DEF BUFFER bcrapass FOR crapass.
    DEF BUFFER bcrapjur FOR crapjur.

    ASSIGN
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_retorno  = "NOK".

    Busca: DO ON ERROR UNDO, RETURN "Erro na busca":
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-dados-jur. 

        FIND bcrapass WHERE bcrapass.cdcooper = par_cdcooper AND
                            bcrapass.nrdconta = par_nrdconta 
                            NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE  bcrapass THEN
            DO:
               ASSIGN aux_dscritic = "Associado nao cadastrado".
               LEAVE Busca.
            END.

        FIND bcrapjur WHERE bcrapjur.cdcooper = bcrapass.cdcooper AND
                            bcrapjur.nrdconta = bcrapass.nrdconta 
                            NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE  bcrapjur THEN
            DO:
               aux_dscritic = "Dados da pessoa Juridica nao encontrados".
               LEAVE Busca.
                END.

        FIND gncdntj WHERE gncdntj.cdnatjur = bcrapjur.natjurid 
                     NO-LOCK NO-ERROR.

        CREATE tt-dados-jur.
        ASSIGN 
            tt-dados-jur.nmprimtl = bcrapass.nmprimtl 
            tt-dados-jur.inpessoa = bcrapass.inpessoa
            tt-dados-jur.dspessoa = "JURIDICA"
            tt-dados-jur.nrcpfcgc = STRING(STRING(bcrapass.nrcpfcgc,
                                                  "99999999999999"),
                                           "xx.xxx.xxx/xxxx-xx")
            tt-dados-jur.dtcnscpf = bcrapass.dtcnscpf
            tt-dados-jur.cdsitcpf = bcrapass.cdsitcpf
            tt-dados-jur.nmfatasi = bcrapjur.nmfansia
            tt-dados-jur.cdnatjur = bcrapjur.natjurid
            tt-dados-jur.dsnatjur = IF   AVAILABLE gncdntj THEN 
                                         gncdntj.dsnatjur
                                    ELSE 
                                         "Nao Cadastrado"
            tt-dados-jur.cdrmativ = bcrapjur.cdrmativ 
            tt-dados-jur.dsendweb = bcrapjur.dsendweb 
            tt-dados-jur.nmtalttl = bcrapjur.nmtalttl 
            tt-dados-jur.qtfoltal = bcrapass.qtfoltal 
            tt-dados-jur.qtfilial = bcrapjur.qtfilial 
            tt-dados-jur.qtfuncio = bcrapjur.qtfuncio 
            tt-dados-jur.dtiniatv = bcrapjur.dtiniatv 
            tt-dados-jur.cdseteco = bcrapjur.cdseteco
            tt-dados-jur.dtcadass = bcrapass.dtmvtolt
            tt-dados-jur.cdclcnae = bcrapass.cdclcnae
            tt-dados-jur.nrlicamb = bcrapjur.nrlicamb
			tt-dados-jur.dtvallic = bcrapjur.dtvallic
            tt-dados-jur.tpregtrb = bcrapjur.tpregtrb.

        /* Situacao do CPF/CNPJ */
        CASE tt-dados-jur.cdsitcpf:
            WHEN 1 THEN tt-dados-jur.dssitcpf = "(Regular)".
            WHEN 2 THEN tt-dados-jur.dssitcpf = "(Pendente)".
            WHEN 3 THEN tt-dados-jur.dssitcpf = "(CANCELADO)".
            WHEN 4 THEN tt-dados-jur.dssitcpf = "(IRREGULAR)".
            WHEN 5 THEN tt-dados-jur.dssitcpf = "(SUSPENSO)".
            OTHERWISE tt-dados-jur.dssitcpf = "".
        END CASE.

        IF   tt-dados-jur.cdseteco <> 0   THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                    craptab.cdacesso = "SETORECONO" AND
                                    craptab.tpregist = tt-dados-jur.cdseteco
                                    NO-LOCK NO-ERROR.

                 ASSIGN tt-dados-jur.nmseteco = IF   AVAILABLE craptab THEN 
                                                     craptab.dstextab
                                                ELSE 
                                                     "Nao cadastrado".
             END.

        IF   tt-dados-jur.cdrmativ <> 0   AND
             tt-dados-jur.cdseteco <> 0   THEN
             DO:
                  FIND gnrativ WHERE 
                               gnrativ.cdseteco = tt-dados-jur.cdseteco AND
                               gnrativ.cdrmativ = tt-dados-jur.cdrmativ
                               NO-LOCK NO-ERROR.

                  ASSIGN tt-dados-jur.dsrmativ = IF   AVAILABLE gnrativ THEN 
                                                      gnrativ.nmrmativ
                                                 ELSE 
                                                      "NAO CADASTRADO".
             END.

        LEAVE Busca.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE valida_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfatasi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmovass AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatjur AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM tel_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtalttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                           NO-UNDO.
	  DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.
	  DEF  INPUT PARAM par_dtvallic AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdclcnae AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_dssitcpf AS CHAR                                    NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados da Identificacao "
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_retorno  = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* Nome Fantasia */
        IF  par_nmfatasi = "" THEN
            DO:
                ASSIGN aux_dscritic = "Nome Fantasia deve ser informado." .
                LEAVE Valida.
            END.

        /* Consulta do CNPJ */
        IF  par_dtcnscpf > par_dtmvtolt OR par_dtcnscpf < par_dtmovass THEN
            DO:
               ASSIGN aux_dscritic = "Data da consulta do CPF na Receita " +
                                     "Federal esta incorreta.".
               LEAVE Valida.
            END.

        /* Situacao do CNPJ */
        IF   NOT  DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                                   INPUT par_cdsitcpf,
                                   OUTPUT aux_dssitcpf,
                                   OUTPUT aux_dscritic) THEN
             LEAVE Valida.

        /* Natureza Juridica */
        IF  NOT CAN-FIND(gncdntj WHERE gncdntj.cdnatjur = par_cdnatjur NO-LOCK)
            OR par_cdnatjur = 0 THEN 
            DO:
                ASSIGN aux_dscritic = "Natureza Juridica incorreta.".
                LEAVE Valida.
            END.

        /* Inicio Atividade */                
        IF   (par_dtiniatv > par_dtmvtolt) OR (par_dtiniatv = ?) THEN
             DO:
                 ASSIGN aux_dscritic = "Data do inicio da atividade deve " + 
                                       "ser informada.".
                 LEAVE Valida.
             END.

        /* Setor Economico */
        IF   NOT CAN-FIND(craptab WHERE craptab.cdcooper = par_cdcooper AND
                                        craptab.cdacesso = "SETORECONO" AND
                                        craptab.tpregist = par_cdseteco
                                        NO-LOCK) THEN
             DO:
                 ASSIGN aux_cdcritic = 879.
                 LEAVE Valida.
             END.

        /* Ramo Atividade */                
        IF  NOT CAN-FIND(gnrativ WHERE gnrativ.cdseteco = par_cdseteco AND
                                       gnrativ.cdrmativ = tel_cdrmativ 
                                       NO-LOCK)  THEN
             DO:
                 ASSIGN aux_cdcritic = 878.
                 LEAVE Valida.
             END.
             
        /* CNAE */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
        RUN STORED-PROCEDURE pc_valida_cnae
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdclcnae, 0, "").

        CLOSE STORED-PROC pc_valida_cnae
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_valida_cnae.pr_cdcritic 
                                 WHEN pc_valida_cnae.pr_cdcritic <> ?
               aux_dscritic = pc_valida_cnae.pr_dscritic 
                                 WHEN pc_valida_cnae.pr_dscritic <> ?.
        
        IF  aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> ""  THEN
            DO:
               ASSIGN aux_cdcritic = 1501.
               LEAVE Valida.
            END. 

        IF  par_nmtalttl = "" THEN
            DO:
               ASSIGN aux_dscritic = "Informe o nome para impressao no " + 
                                     "talao de cheques.".
               LEAVE Valida.
            END.

        IF  par_qtfoltal <> 10 AND par_qtfoltal <> 20 THEN
            DO:
               ASSIGN aux_dscritic = "Quantidade de folhas deve ser 10 ou 20".
               LEAVE Valida.
            END.

        /* Data Validade da Licenca se houver numero*/
        IF  par_nrlicamb <> ? and par_nrlicamb > 0 THEN
            DO:
              IF  par_dtvallic = ? THEN				
                  DO:
                    ASSIGN aux_dscritic = "Data de Validade da Licenca deve ser informada." .
        LEAVE Valida.
    END.

            END.
    END.
    
    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    IF  aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.
END.

PROCEDURE grava_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfatasi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatjur AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfilial AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfuncio AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtalttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdclcnae AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.
	  DEF  INPUT PARAM par_dtvallic AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_tpregtrb AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_impdecpjcoop AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_idseqttl AS INT                                     NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0137 AS HANDLE                                  NO-UNDO.
    
	DEF VAR aux_idimpdsn AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro. 

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava dados da Identificacao"
           aux_retorno  = "NOK"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsrotina = "".
    
    Grava: DO TRANSACTION
       ON ERROR  UNDO Grava, LEAVE Grava 
       ON QUIT   UNDO Grava, LEAVE Grava
       ON STOP   UNDO Grava, LEAVE Grava
       ON ENDKEY UNDO Grava, LEAVE Grava:

       ContadorAss: DO aux_contador = 1 TO 10:

           FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                              crapass.nrdconta = par_nrdconta
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crapass THEN
              DO:
                 IF LOCKED(crapass) THEN
                    DO:
                       IF aux_contador = 10 THEN
                          DO:
                             ASSIGN aux_dscritic = "Associado sendo alterado" +
                                            " em outra estacao".
                             LEAVE ContadorAss.
                          END.
                       ELSE 
                          DO: 
                             PAUSE 1 NO-MESSAGE.
                             NEXT ContadorAss.
                          END.

                    END.
                 ELSE 
                    DO:
                       ASSIGN aux_dscritic = "Associado nao cadastrado.".
                       LEAVE ContadorAss.  
                    END.

              END.
           ELSE 
              LEAVE ContadorAss.

       END.

       IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
          UNDO Grava, LEAVE Grava.

       ContadorJur: DO aux_contador = 1 TO 10:

           FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                              crapjur.nrdconta = par_nrdconta
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crapjur THEN
              DO:
                 IF LOCKED(crapjur) THEN
                    DO:
                       IF aux_contador = 10 THEN
                          DO:
                             ASSIGN aux_dscritic = "Associado sendo alterado" +
                                                   " em outra estacao." .
                             LEAVE ContadorJur.
                          END.
                       ELSE 
                          DO:
                              PAUSE 1 NO-MESSAGE.
                              NEXT ContadorJur.
                          END.

                    END.
                 ELSE 
                    DO:
                        ASSIGN aux_dscritic = "Associado (pessoa juridica) " + 
                                              "nao cadastrado.".
                        LEAVE ContadorJur.  
                    END.

              END.
           ELSE 
              LEAVE ContadorJur.

       END.
        
       ASSIGN aux_idseqttl = 0.
        
       /* Se passou para PJ Cooperativa, seta a flag para gerar a impressao automatica */
       ASSIGN log_impdecpjcoop = "N".
       IF par_cdnatjur = 2143 AND ((par_cdnatjur <> crapjur.natjurid) OR (crapass.dtinsori = TODAY)) THEN
        DO:
          ASSIGN log_impdecpjcoop = "S".
        END.
       IF  CAPS(par_nmfatasi) <> crapjur.nmfansia OR
           par_cdnatjur <> crapjur.natjurid OR 
           par_cdrmativ <> crapjur.cdrmativ THEN
            DO:

              IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                  RUN sistema/generico/procedures/b1wgen0137.p 
                  PERSISTENT SET h-b1wgen0137.

              RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT aux_idseqttl,
                          INPUT crapass.nrcpfcgc,
                          INPUT par_dtmvtolt,
                          INPUT "10",
                          INPUT par_cdoperad,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic).
                                            
              IF  VALID-HANDLE(h-b1wgen0137) THEN
                DELETE OBJECT h-b1wgen0137.              
                                END.
    
       IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
          UNDO Grava, LEAVE Grava.

       { sistema/generico/includes/b1wgenalog.i }

       EMPTY TEMP-TABLE tt-dados-jur-ant.
       EMPTY TEMP-TABLE tt-dados-jur-atl.

       CREATE tt-dados-jur-ant.
       BUFFER-COPY crapass TO tt-dados-jur-ant.
       BUFFER-COPY crapjur TO tt-dados-jur-ant.
        
	   /* Proj 410 - RF 52 / 62 - Se tpregtrb for diferente de 1 (Simples Nacional), grava IDIMPDSN com zero. Caso contrário, grava com 1 se está já não estiver sido impressa (IDIMPDSN = 2) */
       IF par_tpregtrb <> 1 THEN
            ASSIGN aux_idimpdsn = 0.
       ELSE
            IF crapjur.idimpdsn = 2 THEN
                ASSIGN aux_idimpdsn = 2.
            ELSE
                ASSIGN aux_idimpdsn = 1.
       ASSIGN crapass.qtfoltal = par_qtfoltal
              crapass.dtcnscpf = par_dtcnscpf
              crapass.cdsitcpf = par_cdsitcpf
              crapass.cdclcnae = par_cdclcnae
              crapjur.nmfansia = CAPS(par_nmfatasi)
              crapjur.natjurid = par_cdnatjur
              crapjur.dtiniatv = par_dtiniatv
              crapjur.cdrmativ = par_cdrmativ
              crapjur.qtfilial = par_qtfilial
              crapjur.qtfuncio = par_qtfuncio
              crapjur.dsendweb = par_dsendweb
              crapjur.nmtalttl = CAPS(par_nmtalttl)
              crapjur.cdseteco = par_cdseteco
              crapjur.nrlicamb = par_nrlicamb 
			  crapjur.dtvallic = par_dtvallic
              crapjur.tpregtrb = par_tpregtrb	
			  crapjur.idimpdsn = aux_idimpdsn NO-ERROR.

       IF ERROR-STATUS:ERROR THEN
          DO:
             ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
             LEAVE Grava.
          END.

       CREATE tt-dados-jur-atl.
       BUFFER-COPY crapass TO tt-dados-jur-atl.
       BUFFER-COPY crapjur TO tt-dados-jur-atl.

       /* Criar pendencia no digidoc caso uma licenca tenho sido informada */
       IF  par_nrlicamb > 0 AND
	       (tt-dados-jur-ant.nrlicamb <> tt-dados-jur-atl.nrlicamb OR
		      tt-dados-jur-ant.dtvallic <> tt-dados-jur-atl.dtvallic) THEN
           DO:
              IF NOT VALID-HANDLE(h-b1wgen0137) THEN
              RUN sistema/generico/procedures/b1wgen0137.p 
                  PERSISTENT SET h-b1wgen0137.
                  
              /* cria registros na crapdoc de 131 - Licenças Sócio Ambientais */  
              RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                        ( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT aux_idseqttl,
                          INPUT crapass.nrcpfcgc,
                          INPUT par_dtmvtolt,
                          INPUT "40",  /* Licenças Sócio Ambientais */
                                          INPUT par_cdoperad,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic).

              IF  VALID-HANDLE(h-b1wgen0137) THEN
                DELETE OBJECT h-b1wgen0137.

              IF  aux_cdcritic > 0 OR 
                  aux_dscritic <> "" THEN
                   LEAVE Grava.
           END.

       { sistema/generico/includes/b1wgenllog.i }
       
       /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
       IF NOT VALID-HANDLE(h-b1wgen0168) THEN
          RUN sistema/generico/procedures/b1wgen0168.p
              PERSISTENT SET h-b1wgen0168.
                 
       EMPTY TEMP-TABLE tt-crapcyb.

       CREATE tt-crapcyb.
       ASSIGN tt-crapcyb.cdcooper = par_cdcooper
              tt-crapcyb.nrdconta = par_nrdconta
              tt-crapcyb.dtmancad = par_dtmvtolt.

       RUN atualiza_data_manutencao_cadastro
           IN h-b1wgen0168(INPUT  TABLE tt-crapcyb,
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic).
                 
       IF VALID-HANDLE(h-b1wgen0168) THEN
          DELETE PROCEDURE(h-b1wgen0168).

       IF RETURN-VALUE <> "OK" THEN
          UNDO Grava, LEAVE Grava.
       /* FIM - Atualizar os dados da tabela crapcyb */

       ASSIGN aux_retorno = "OK".

       LEAVE Grava.

    END.

    RELEASE crapjur.
    RELEASE crapass.

    IF CAPS(par_nmfatasi) <> tt-dados-jur-ant.nmfansia THEN
      DO:
          FOR FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper
                              AND crapcdr.nrdconta = par_nrdconta
                              AND crapcdr.flgconve = TRUE NO-LOCK:

            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
            RUN STORED-PROCEDURE pc_replica_cdc
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                  ,INPUT par_nrdconta
                                                  ,INPUT par_cdoperad
                                                  ,INPUT par_idorigem
                                                  ,INPUT par_nmdatela
                                                  ,INPUT 0
                                                  ,INPUT 0
                                                  ,INPUT 0
                                                  ,INPUT 1
                                                  ,0
                                                  ,"").

            CLOSE STORED-PROC pc_replica_cdc
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_replica_cdc.pr_cdcritic 
                                    WHEN pc_replica_cdc.pr_cdcritic <> ?
                   aux_dscritic = pc_replica_cdc.pr_dscritic 
                                    WHEN pc_replica_cdc.pr_dscritic <> ?.
                                    
          END.

      END.

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       DO:
          ASSIGN aux_retorno = "NOK".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
       END.

    IF aux_retorno = "OK" THEN
       Cad_Restritivo:
       DO WHILE TRUE:
                   
          FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

          IF NOT AVAIL crapass THEN
             DO:
                ASSIGN aux_cdcritic = 9.
                      
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            
                ASSIGN aux_retorno = "NOK".
            
                LEAVE Cad_Restritivo.
            
             END.

          /*Monta a mensagem da rotina para envio no e-mail*/
          ASSIGN aux_dsrotina = "Alteracao na identificacao da conta "    +
                                STRING(crapass.nrdconta,"zzzz,zzz,9")     +
                                " - CPF/CNPJ "                            +
                                STRING((STRING(crapass.nrcpfcgc,
                                               "99999999999999")),
                                               "xx.xxx.xxx/xxxx-xx").

          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p
                 PERSISTENT SET h-b1wgen0110.
         
          /*Verifica se o associado esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT crapass.nrcpfcgc, 
                                            INPUT crapass.nrdconta,
                                            INPUT 1,     /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 27,    /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).

          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE(h-b1wgen0110).

          IF RETURN-VALUE <> "OK" THEN
             DO:
                IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                            "cadastro restritivo.".
                      
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
          
                   END.
          
                ASSIGN aux_retorno = "NOK".

                LEAVE Cad_Restritivo.
          
             END.

          LEAVE Cad_Restritivo.

       END.

    IF par_flgerlog THEN
       RUN proc_gerar_log_tab
           ( INPUT par_cdcooper,
             INPUT par_cdoperad,
             INPUT aux_dscritic,
             INPUT aux_dsorigem,
             INPUT aux_dstransa,
             INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
             INPUT par_idseqttl,
             INPUT par_nmdatela,
             INPUT par_nrdconta,
             INPUT YES,
             INPUT BUFFER tt-dados-jur-ant:HANDLE,
             INPUT BUFFER tt-dados-jur-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.

/*................................ FUNCTIONS ................................*/


/*............................................................................*/



