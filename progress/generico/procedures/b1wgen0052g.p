/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0052g.p                  
    Autor(a): Jose Luis Marchezoni (DB1 Informatica)
    Data    : Junho/2010                      Ultima atualizacao: 06/09/2018
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela MATRIC.
                Baseado em fontes/matric.p.
                Rotinas de Gravacao de Dados
                Apenas Procedure Grava_Dados eh a rotina que obrigatoriamente 
                pode ser executada por programas externos, a demais procedures
                sao 'internas/locais ou privadas' e dependem de objetos da 
                gerenciados pela Grava_Dados
  
    Alteracoes: 15/10/2010 - Eliminar registro da tabela de Nao Cooperados
                             (Tabela crapncp) (GATI - Eder)    
                             
                26/11/2010 - Correcao na geracao da subscricao inicial.
                             Procedure Parcelamento. (David).     
                             
                26/11/2010 - Incluir parametros de revisao cadastral nas 
                             rotinas de cadastro de fone e endereco (DB1).
                             
                14/03/2011 - Incluido condicao, caso seja pessoa fisica,
                             passar em branco o campo dsestcvl p/ tt (Jorge).
                             
                05/05/2011 - Substituido campo tempo resid por dtinires.
                             (André - DB1)
                             
                20/05/2011 - Incluida alteracao de agencia na tabela crapcld
                             (Henrique)
    
                16/06/2011 - Incluir campo de 'Politicamente Exposta'  
                             (Gabriel)                                 
                             
                04/07/2011 - Incluir parametros na procedure alterar-endereco
                             (David).
                             
                25/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).             
                                         
                05/10/2012 - Ajusta na procedure PROCURADOR para colocar os
                             campos abaixo na criacao da crapavt:
                             - dtadmsoc
                             - flgdepec
                             - persocio
                             - vloutren
                             - dsoutren
                             (Adriano).
                             
                14/12/2012 - Criado a procedure atualiza_avt_crl e feito a 
                             chamada desta, dentro da procedure Altera.
                             Projeto GE - (Adriano).             
                             
                11/04/2013 - Ajuste realizados:
                             - Incluido a chamada alerta_fraude dentro da 
                               procedure Procurador e incluidos novos 
                               parametros de entrada;
                             - Incluido novos parametros na chamada da 
                               procedure Procurador (Adriano).             
                               
                26/07/2013 - Retirado campo crabass.dsnatura (Reinert).
                
                08/08/2013 - Incluido campo cdufnatu. (Reinert)
                
                26/09/2013 - Removido a gravacao na tabela crapttl para os 
                             campos de endereço: dsendres,  nmbairro, 
                             nrcepend, nmcidade, cdufresd, nrcxpost. (Reinert)
                                                                       
                01/10/2013 - Removido a gravacao na tabela crapass o campo
                             nrfonres. (Reinert)
                             
                28/10/2013 - Retirada criaçao automatica da senha, tabela
                             crapsnh. (Oliver - GATI)
                             
                18/12/2013 - Removido campo dscpfcgc (Lucas R.)
                
                30/01/2014 - Removido bloco do ContadorSnh e RELEASE crapsnh.
                             (Reinert)
                             
                19/02/2014 - Alterado para salvar o código do estado civil na
                             crapttl, e nao mais na crapass (Carlos)
                             
                28/02/2014 - Incluso VALIDATE (Daniel).
                
                16/04/2014 - Ajustes para gerar pendencia na crapdoc, troca de
                             condicoes e tipos de documentos (Lucas R.)
                             
                25/03/2014 - Ajuste nas procedures "Altera_Cad","Inclui_Cad",
                             "Desvincula" para buscar a proxima 
                             sequencia crapmat.qtdemmes apartir banco Oracle 
                             (James)
                             
                28/04/2014 - Ajuste na procedure "Altera_CadC" para buscar a 
                             sequence do banco Oracle para a tabela crapneg. 
                             (James)
                             
                14/05/2014 - Na atualizacao do registro do Responsavel Legal 
                             foi colocado "crapcrl.nrcpfcgc = 0".
                             (Jaison - SF: 140964)
                             
                14/05/2014 - Retirada a alteracao de 19/02/2014 (Carlos)
                
                26/05/2014 - Alterado o campo do estado civil da crapass para
                             crapttl (Douglas - Chamado 131253)
                             
                18/06/2014 - Exclusao do uso da tabela crapcar
                             (Tiago Castro - Tiago RKAM)
                            
                11/12/2014 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                15/05/2015 - Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)
                            
                15/07/2015 - Reformulacao cadastral (Gabriel-RKAM).  

				12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                
                05/10/2015 - Adicionado nova opção "J" para alteração apenas do cpf/cnpj e 
                             removido a possibilidade de alteração pela opção "X", conforme 
                             solicitado no chamado 321572 (Kelvin). 
                             
                27/11/2015 - Gravar 60 posicoes do nome RFB na crapass
                             (Gabriel-RKAM).             
				
                20/01/2016 - #350828 Forcando a situacao de pessoa exposta politicamente
                             para 2 (Pendente) (Carlos)
				        
                21/01/2016 - Adicionar procedure para atualizar o nome do titular da conta
                             em todos os campos da crapass de acordo com a sequencia em 
                             que ele eh titular. (Douglas - Chamado 374605)
				        
                22/01/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de	 
                             Transferencia entre PAs (Heitor - RKAM)

                29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                             solicitado no chamado 402159 (Kelvin).

                12/05/2016 - Ajustado rotina Grava_Dados para verificar situaçao
                             do novo associado na cabine JBNF apos gerar a nova
                             matricula PRJ318. (Odirlei-AMcom)

                17/06/2016 - Inclusao de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

                15/07/2016 - Incluir chamada da procedure pc_grava_tbchq_param_conta - Melhoria 69
                             (Lucas Ranghetti #484923)
				
                01/12/2016 - Definir a não obrigatoriedade do PEP (Tiago/Thiago SD532690)

				19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
										
                25/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

                17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)  	

                11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                             Projeto 339 - CRM. (Lombardi)	


                22/09/2017 - Adicionar tratamento para caso o inpessoa for juridico gravar 
                             o idseqttl como zero (Luacas Ranghetti #756813)

				05/10/2017 - Incluindo procedure para replicar informacoes do crm. 
							 (PRJ339 - Kelvin/Andrino).				  

                09/10/2017 - Incluido rotina para ao cadastrar cooperado carregar dados
                             da pessoa do cadastro unificado, para completar o cadastro com dados
                             que nao estao na tela. PRJ339 - CRM (Odirlei-AMcom)

                12/03/2018 - Alterado de forma que o tipo de conta nao seja mais fixo e sim 
                             parametrizado através da tela CADPAR. PRJ366 (Lombardi).

                13/02/2018 - Ajustes na geraçao de pendencia de digitalizaçao.
                             PRJ366 - tipo de conta (Odirlei-AMcom)             


                24/04/2018 - Adicionado campo cdcatego na inclusao de nova conta.
                           - Gravar historico de inclusao dos campos cdtipcta,
                             cdsitdct e cdcatego. PRJ366 (Lombardi).

                04/05/2018 - Alteracao nos codigos da situacao de conta (cdsitdct). 
                             PRJ366 (Lombardi).		

				13/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)	

				06/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
                             corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
.............................................................................*/
                                                     

/*............................... DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0052tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/ayllos/includes/var_online.i NEW }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM 
    &TELA-MATRIC=SIM &TELA-CONTAS=NAO }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                     NO-UNDO.

FUNCTION LockTabela RETURNS CHARACTER PRIVATE
  ( INPUT par_recidtab AS RECID,
    INPUT par_nmdbanco AS CHAR, 
    INPUT par_nmtabela AS CHAR ) FORWARD .

/* Pre-Processador para controle de erros 'Progress' */
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

/*........................... PROCEDURES EXTERNAS ...........................*/

/* ------------------------------------------------------------------------ */
/*               REALIZA A GRAVACAO DOS DADOS DO ASSOCIADO                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_rowidcem AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdclcnae AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsecao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdptl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_natjurid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfansia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsest AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdebito AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtparcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlparcel AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmttlrfb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inconrfb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_hrinicad AS INTE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-crapavt.
    DEF  INPUT PARAM TABLE FOR tt-bens.

    DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.	
	
    DEF  INPUT PARAM par_nmsocial AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgctsal AS LOGI                           NO-UNDO.
	
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapass-ant.
    DEF OUTPUT PARAM TABLE FOR tt-crapass-atl.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_rowidttl AS ROWID                                   NO-UNDO.
    DEF VAR aux_rowidjur AS ROWID                                   NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    ASSIGN aux_idorigem = par_idorigem
           aux_dsorigem = TRIM(ENTRY(aux_idorigem,des_dorigens,","))
           par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        ASSIGN aux_rowidttl = ?
               aux_rowidjur = ?.

        EMPTY TEMP-TABLE tt-crapass-ant.
        EMPTY TEMP-TABLE tt-crapass-atl.
        
        /* Prepara a atualizacao do registro 'crapalt' e 'log' */
        RUN Atualiza_His 
            ( INPUT par_cddopcao,
              INPUT par_dtmvtolt,  
              INPUT par_cdcooper,  
              INPUT par_nrdconta,  
              INPUT par_idseqttl,  
              INPUT par_nmdatela,  
              INPUT par_cdoperad,
              INPUT par_rowidass,
              INPUT "A", /* alog */
             OUTPUT log_tpatlcad,
             OUTPUT log_msgatcad,
             OUTPUT log_chavealt,
             OUTPUT log_msgrecad,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Grava, LEAVE Grava.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Grava, LEAVE Grava.
        
        /* realiza a busca dos rowid's */
        RUN Id_Registro
            ( INPUT par_rowidass,
              INPUT par_cddopcao,
             OUTPUT aux_rowidttl,
             OUTPUT aux_rowidjur,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Grava, LEAVE Grava.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Grava, LEAVE Grava.
            
        CASE par_cddopcao:
            WHEN "I" OR WHEN "A" THEN DO:
                IF  par_cddopcao = "I" THEN
                    DO:
                       /* matrici.p */
                       RUN Inclui /* INCLUSAO */ 
                           ( INPUT par_cdcooper,
                             INPUT par_nrdconta,  
                             INPUT par_cdoperad,  
                             INPUT par_cdagenci,  
                             INPUT par_idorigem,
                             INPUT par_nmdatela,
                             INPUT par_dtmvtolt,  
                             INPUT par_dtmvtoan,  
                             INPUT par_inpessoa,  
                             INPUT par_nrcpfcgc,
                             INPUT par_cdestcvl,
                             INPUT 0,
                             INPUT par_cdufende,  
                             INPUT par_complend,  
                             INPUT par_dsendere,  
                             INPUT par_nmbairro,  
                             INPUT par_nmcidade,  
                             INPUT par_nrcepend,  
                             INPUT par_nrcxapst,  
                             INPUT par_nrendere,
                             INPUT par_inhabmen,
                             INPUT par_dthabmen,
                             INPUT par_nmttlrfb,
                             INPUT par_inconrfb,
                             INPUT par_hrinicad,
                             INPUT par_idorigee,
                             INPUT par_nrlicamb,
                             INPUT par_nmsocial,
                             INPUT par_cdempres,
						     INPUT par_flgctsal,
                            OUTPUT par_rowidass,
                            OUTPUT aux_rowidttl,               
                            OUTPUT aux_rowidjur,
                            OUTPUT par_msgretor,
                            OUTPUT par_cdcritic,
                            OUTPUT par_dscritic ) NO-ERROR.

                       IF  ERROR-STATUS:ERROR THEN
                           DO:
                              ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                              UNDO Grava, LEAVE Grava.
                           END.

                       IF  RETURN-VALUE <> "OK" THEN
                           UNDO Grava, LEAVE Grava.

                       /* Buscar associado e atualizar variavel, caso esteja nula
                          pois na criaçao dado nao é informado e pega por 
                          padrao do cadastro de pessoa */
                       IF par_dsproftl = "" THEN
                       DO:
                         FIND crapass 
                         WHERE ROWID(crapass) = par_rowidass.
                         
                         IF AVAILABLE crapass THEN
                         DO:
                            ASSIGN par_dsproftl = crapass.dsproftl.                       
                         END.
                       END.

                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
                       RUN STORED-PROCEDURE pc_grava_tbchq_param_conta 
                            aux_handproc = PROC-HANDLE NO-ERROR
                                             (INPUT "I",  /* Opcao, Incluir*/
                                              INPUT par_cdcooper,  /* Cooperativa */
                                              INPUT par_nrdconta,  /* Numero da Conta */
                                              INPUT 1,  /* Flag devolucao automatica/ 1=sim/0=nao */
                                              INPUT par_cdoperad,  /* Operador */  
                                              INPUT " ", /* Operador Coordenador */
                                             OUTPUT "").

                        CLOSE STORED-PROC pc_grava_tbchq_param_conta 
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                        
                        ASSIGN aux_dscritic = ""                         
                               aux_dscritic = pc_grava_tbchq_param_conta.pr_dscritic 
                                              WHEN pc_grava_tbchq_param_conta.pr_dscritic <> ?.
                            
                        IF  aux_dscritic <> ""  THEN
                            DO:  
                                ASSIGN par_dscritic = aux_dscritic.
                                UNDO Grava, LEAVE Grava.
                            END.
                       
                       /* Parcelamento do Capital - 'fontes/matric_pc.p' */
                       IF  par_inpessoa <> 3  THEN
                           DO:
                              RUN Parcelamento
                                  ( INPUT par_cdcooper,
                                    INPUT par_nrdconta,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtdebito,
                                    INPUT par_qtparcel,
                                    INPUT par_vlparcel,
                                   OUTPUT par_cdcritic,
                                   OUTPUT par_dscritic ) NO-ERROR.
        
                              IF  ERROR-STATUS:ERROR THEN 
                                  DO:
                                     ASSIGN par_dscritic = par_dscritic + 
                                                          {&GET-MSG}.
                                     UNDO Grava, LEAVE Grava.
                                  END.
       
                              IF  RETURN-VALUE <> "OK" THEN
                                  UNDO Grava, LEAVE Grava.
                           END.
                    
                       /* Verificar situacao do cpf/cnpj na cabine e enviar e-mail*/
                       RUN verifica_sit_JDBNF 
                           (INPUT par_cdcooper,
                            INPUT par_nrdconta,
                            INPUT par_nrcpfcgc,
                            INPUT par_inpessoa).
                    
                    END.

                /* Procurador/Representante */
                IF  par_inpessoa = 2 OR par_inpessoa = 3 THEN
                    DO:
                       RUN Procurador
                           ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_idorigem,
                             INPUT par_dtmvtolt,
                             INPUT par_nrdconta,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_inpessoa,
                             INPUT par_idseqttl,
                             INPUT par_nrcpfcgc,
                             INPUT TABLE tt-crapavt,
                             INPUT TABLE tt-bens,
                            OUTPUT par_cdcritic,
                            OUTPUT par_dscritic ) NO-ERROR.

                       IF  ERROR-STATUS:ERROR THEN
                           DO:
                              ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                              UNDO Grava, LEAVE Grava.
                           END.

                       IF  RETURN-VALUE <> "OK" THEN
                           UNDO Grava, LEAVE Grava.
                    END.
                
                /* matrica.p */                          
                RUN Altera /* ALTERACAO */
                    ( INPUT par_cdcooper,
                      INPUT par_idorigem,
                      INPUT aux_dsorigem,
                      INPUT par_nmdatela,
                      INPUT par_cdagepac,
                      INPUT par_nrdconta,
                      INPUT par_cdoperad,
                      INPUT par_cddopcao,
                      INPUT par_dtmvtolt,
                      INPUT par_rowidass,
                      INPUT aux_rowidttl,
                      INPUT aux_rowidjur,
                      INPUT par_nrcpfcgc,
                      INPUT par_nmprimtl,
                      INPUT par_nmpaittl,
                      INPUT par_nmmaettl,
                      INPUT par_nmconjug,
                      INPUT par_cdempres,
                      INPUT par_cdsexotl,
                      INPUT par_cdsitcpf,  
                      INPUT par_dtcnscpf,  
                      INPUT par_dtnasctl,  
                      INPUT par_tpnacion,  
                      INPUT par_cdnacion,  
                      INPUT par_dsnatura,
                      INPUT par_cdufnatu,
                      INPUT par_cdocpttl,
                      INPUT par_rowidcem,
                      INPUT par_dsdemail,
                      INPUT par_nrdddres,
                      INPUT par_nrtelres,
                      INPUT par_nrdddcel,
                      INPUT par_nrtelcel,
                      INPUT par_cdopetfn,
                      INPUT par_cdclcnae,
                      INPUT par_cdestcvl,  
                      INPUT par_dsproftl,
                      INPUT par_nmdsecao,
                      INPUT par_nrcadast,
                      INPUT par_tpdocptl,
                      INPUT par_nrdocptl,
                      INPUT par_cdoedptl,
                      INPUT par_cdufdptl,
                      INPUT par_dtemdptl,
                      INPUT par_dtdemiss,
                      INPUT par_cdmotdem,
                      INPUT par_cdufende,
                      INPUT par_dsendere,
                      INPUT par_nrendere,
                      INPUT par_nmbairro,
                      INPUT par_nmcidade,
                      INPUT par_complend,
                      INPUT par_nrcepend,
                      INPUT par_nrcxapst,
                      INPUT par_dtiniatv,
                      INPUT par_natjurid,
                      INPUT par_nmfansia,  
                      INPUT par_nrinsest,  
                      INPUT par_cdseteco,
                      INPUT par_cdrmativ,  
                      INPUT par_nrdddtfc,  
                      INPUT par_nrtelefo,  
                      INPUT par_inhabmen,
                      INPUT par_dthabmen,
                      INPUT par_idorigee,
                      INPUT par_nrlicamb,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.
                
                IF  ERROR-STATUS:ERROR THEN 
                    DO: 
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.  
                    END.
                
                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Grava, LEAVE Grava. 
            END.
            WHEN "X" THEN DO:
                /* matricx.p */
                RUN Nome_Cpf /* RAZAO SOCIAL-NOME / CPF-CNPJ */
                    ( INPUT par_rowidass, 
                      INPUT aux_rowidttl,
                      INPUT aux_rowidjur,
                      INPUT par_nmprimtl,
                      INPUT par_nrcpfcgc,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Grava, LEAVE Grava.
                    
                /* Atualizar o nome dos cooperados quando Pessoa Fisica
                   em todos os titulares que possuem o CPF informado */
                IF  par_inpessoa = 1 THEN
                DO:
                    RUN atualiza_nome_cooperado (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrcpfcgc,
                                                 INPUT par_nmprimtl,
                                                OUTPUT par_cdcritic, 
                                                OUTPUT par_dscritic).
    
                    IF  RETURN-VALUE <> "OK" THEN
                        UNDO Grava, LEAVE Grava.
            END.

            END.
            WHEN "J" THEN DO:
                /* matricj.p */
                RUN Nome_Cpf /*CPF-CNPJ */
                    ( INPUT par_rowidass, 
                      INPUT aux_rowidttl,
                      INPUT aux_rowidjur,
                      INPUT par_nmprimtl,
                      INPUT par_nrcpfcgc,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Grava, LEAVE Grava.
            END.
            WHEN "D" THEN DO:
                /* matricd.p */
                RUN Desvincula /* DESVINCULA MATRICULA */
                    ( INPUT par_rowidass,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                     OUTPUT par_msgretor,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT TABLE tt-alertas ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Grava, LEAVE Grava.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Grava, LEAVE Grava.
            END.
        END CASE.

        /* Atualiza os historicos, registro 'crapalt' e 'log' apos alteracao */
        RUN Atualiza_His 
            ( INPUT par_cddopcao,
              INPUT par_dtmvtolt,  
              INPUT par_cdcooper,  
              INPUT par_nrdconta,  
              INPUT par_idseqttl,  
              INPUT par_nmdatela,  
              INPUT par_cdoperad,
              INPUT par_rowidass,
              INPUT "L", /* llog */
             OUTPUT log_tpatlcad,
             OUTPUT log_msgatcad,
             OUTPUT log_chavealt,
             OUTPUT log_msgrecad,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Grava, LEAVE Grava.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Grava, LEAVE Grava.

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.
    END.

    RELEASE crapass.
    RELEASE crapttl.
    RELEASE crapjur.
    RELEASE crapcje.

    IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

/*........................ PROCEDURES INTERNAS/PRIVADAS ....................*/

/* ------------------------------------------------------------------------ */
/*               GERENCIA A ATUALIZACAO/GRAVACAO DOS DADOS                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Altera PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_rowidttl AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_rowidjur AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidcem AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdclcnae AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsecao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdptl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_natjurid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfansia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsest AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdmotant AS INTE                                    NO-UNDO.
    DEF VAR aux_dsmotant AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtdemant AS DATE                                    NO-UNDO.
    DEF VAR aux_dsmotdem AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgpagto AS LOG                                     NO-UNDO.
    DEF VAR ant_flgpagto AS LOG                                     NO-UNDO.
    DEF VAR aux_flgtroca AS LOG                                     NO-UNDO.
    DEF VAR aux_cdempant AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcadant AS INTE                                    NO-UNDO.
    DEF VAR aux_cdageant AS INTE                                    NO-UNDO.
    DEF VAR aux_cdsecant AS INTE                                    NO-UNDO.
    DEF VAR aux_cdsitant AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabenc FOR crapenc.
    DEF BUFFER crabemp FOR crapemp.

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".
           
    Altera: DO TRANSACTION
        ON ERROR  UNDO Altera, LEAVE Altera
        ON QUIT   UNDO Altera, LEAVE Altera
        ON STOP   UNDO Altera, LEAVE Altera
        ON ENDKEY UNDO Altera, LEAVE Altera:

        ContadorAss: DO aux_contador = 1 TO 10:
            
            FIND crabass WHERE ROWID(crabass) = par_rowidass
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabass THEN
                DO:
                   IF  LOCKED crabass THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crapass
                                     WHERE ROWID(crapass) = par_rowidass
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crapass THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapass),"banco","crapass").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
                                 LEAVE ContadorAss.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorAss.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 9.
                          LEAVE ContadorAss.
                       END.
                END.
            ELSE
                LEAVE ContadorAss.
        END.

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO Altera, LEAVE Altera.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        /* armazena os dados do associado antes de atualiza-los */
        ASSIGN aux_dtdemant = crabass.dtdemiss
               aux_cdmotant = crabass.cdmotdem
               aux_nrcadant = crabass.nrcadast
               aux_cdageant = crabass.cdagenci
               aux_cdsecant = crabass.cdsecext
               aux_cdsitant = crabass.cdsitdct.

        /* o associado esta sendo readmitido - mudou o motivo da demissao */
        IF  (par_dtdemiss = ? AND crabass.dtdemiss <> ?) OR 
            (par_cdmotdem <> crabass.cdmotdem) THEN
            /* busca motivo demissão */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle */ 
                RUN STORED-PROCEDURE prc_busca_motivo_demissao
                aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT crabass.cdcooper      /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT crabass.cdmotdem      /* pr_cdmotdem --> Código Motivo Demissao */
                   /* --------- OUT --------- */
                   ,OUTPUT ""           /* pr_dsmotdem --> Descriçao Motivo Demissao */
                   ,OUTPUT 0            /* pr_cdcritic --> Codigo da critica)   */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).  */

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC prc_busca_motivo_demissao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_dsmotant = prc_busca_motivo_demissao.pr_dsmotdem
                                 WHEN prc_busca_motivo_demissao.pr_dsmotdem <> ?.   
                                 

        /* busca motivo demissão - novo (informou na tela) */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
                /* Efetuar a chamada a rotina Oracle */ 
                RUN STORED-PROCEDURE prc_busca_motivo_demissao
                aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT crabass.cdcooper      /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT par_cdmotdem      /* pr_cdmotdem --> Código Motivo Demissao */
                   /* --------- OUT --------- */
                   ,OUTPUT ""           /* pr_dsmotdem --> Descriçao Motivo Demissao */
                   ,OUTPUT 0            /* pr_cdcritic --> Codigo da critica)   */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).  */
                                        
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC prc_busca_motivo_demissao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_dsmotdem = prc_busca_motivo_demissao.pr_dsmotdem
                                 WHEN prc_busca_motivo_demissao.pr_dsmotdem <> ?.  


        /* Atualiza o conjuge somente se o estado civil for correspondente */
        IF  CAN-DO("01,05,06,07",STRING(par_cdestcvl,"99")) THEN
            ASSIGN par_nmconjug = "".
        
        /* Registra os dados do associado */
        RUN Altera_Ass
            ( BUFFER crabass,
              INPUT par_nrcpfcgc,
              INPUT par_nmprimtl,
              INPUT par_nmpaittl,
              INPUT par_nmmaettl,
              INPUT par_nmconjug,
              INPUT par_cdempres,
              INPUT par_cdsexotl,
              INPUT par_cdagepac,
              INPUT par_cdsitcpf,
              INPUT par_dtcnscpf,
              INPUT par_dtnasctl,
              INPUT par_tpnacion,
              INPUT par_cdnacion,
              INPUT par_dsnatura,
              INPUT par_cdocpttl,
              INPUT par_cdestcvl,
              INPUT par_dsproftl,
              INPUT par_nrcadast,
              INPUT par_tpdocptl,
              INPUT par_nrdocptl,
              INPUT par_cdoedptl,
              INPUT par_cdufdptl,
              INPUT par_dtemdptl,
              INPUT par_dtdemiss,
              INPUT par_cdmotdem,
              INPUT par_dtiniatv,
              INPUT par_nrdddtfc,
              INPUT par_nrtelefo,
              INPUT par_cdclcnae,
              INPUT (IF par_cddopcao = "A" THEN par_dtmvtolt ELSE ?),
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Altera, LEAVE Altera.
            END.
        

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Altera, LEAVE Altera.

        CASE crabass.inpessoa:
            WHEN 1 THEN DO:
                FOR FIRST crabttl FIELDS(cdempres cdestcvl)
                                  WHERE crabttl.cdcooper = par_cdcooper AND
                                        crabttl.nrdconta = par_nrdconta AND
                                        crabttl.idseqttl = 1 NO-LOCK:
                    ASSIGN aux_cdempant = crabttl.cdempres.
                END.

                FOR FIRST crabemp FIELDS(flgpagto flgpgtib)
                    WHERE crabemp.cdcooper = par_cdcooper AND
                          crabemp.cdempres = aux_cdempant NO-LOCK:
                    ASSIGN 
                        ant_flgpagto = (crabemp.flgpagto OR crabemp.flgpgtib)
                        aux_flgpagto = (crabemp.flgpagto OR crabemp.flgpgtib).
                END.

                IF  aux_cdempant <> par_cdempres THEN                      
                    DO:
                       FOR FIRST crabemp FIELDS(flgpagto flgpgtib)
                           WHERE crabemp.cdcooper = par_cdcooper AND
                                 crabemp.cdempres = par_cdempres NO-LOCK:

                           IF  ant_flgpagto AND (NOT crabemp.flgpagto OR NOT crabemp.flgpgtib) THEN
                               ASSIGN aux_flgtroca = TRUE.

                           ASSIGN aux_flgpagto = (crabemp.flgpagto OR crabemp.flgpgtib).
                       END.
                    END.
                
                /* Atualiza os dados PESSOA FISICA */
                RUN Altera_Fis 
                    ( INPUT par_rowidttl,
                      INPUT crabass.nrcpfcgc,
                      INPUT par_cdempres,
                      INPUT par_cdsexotl,
                      INPUT crabass.cdsitcpf,
                      INPUT crabass.dtcnscpf,
                      INPUT crabass.dtnasctl,
                      INPUT par_tpnacion,
                      INPUT crabass.cdnacion,
                      INPUT par_dsnatura,
                      INPUT par_cdufnatu,
                      INPUT crabttl.cdestcvl,
                      INPUT crabass.dsproftl,
                      INPUT par_cdufende,
                      INPUT par_dsendere,
                      INPUT par_nrendere,
                      INPUT par_nmbairro,
                      INPUT par_nmcidade,
                      INPUT par_nrcepend,
                      INPUT par_nrcxapst,
                      INPUT par_nmconjug,
                      INPUT crabass.nmprimtl,
                      INPUT par_nmmaettl,
                      INPUT par_nmpaittl,
                      INPUT crabass.nrcadast,
                      INPUT par_cdocpttl,
                      INPUT par_tpdocptl,
                      INPUT par_nrdocptl,
                      INPUT par_cdoedptl,
                      INPUT par_cdufdptl,
                      INPUT par_dtemdptl,
                      INPUT par_nmdsecao,
                      INPUT par_cdoperad, 
                      INPUT par_dtmvtolt,
                      INPUT par_inhabmen,
                      INPUT par_dthabmen,					  
                     OUTPUT par_cdcritic, 
                     OUTPUT par_dscritic ) NO-ERROR.
                
                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Altera, LEAVE Altera.
                    END.


                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Altera, LEAVE Altera.


                RUN atualiza_avt_crl (INPUT par_cdcooper,
                                      INPUT par_idorigem,
                                      INPUT par_nmdatela,
                                      INPUT par_cdoperad,
                                      INPUT par_cddopcao,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrdconta,
                                      INPUT par_nrcpfcgc,
                                      OUTPUT TABLE tt-erro)NO-ERROR.
          
                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Altera, LEAVE Altera.
                    END.
          
                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Altera, LEAVE Altera.

            END.
            OTHERWISE DO:                                               
                /* Atualiza os dados PESSOA JURIDICA */
                RUN Altera_Jur
                    ( INPUT par_rowidjur,
                      INPUT par_idorigem,
                      INPUT par_nmdatela,
                      INPUT par_cdoperad,
                      INPUT par_cddopcao,
                      INPUT par_dtmvtolt,
                      INPUT crabass.nmprimtl,
                      INPUT par_dtiniatv,
                      INPUT par_natjurid,
                      INPUT par_nmfansia,
                      INPUT par_nrinsest,
                      INPUT par_cdseteco,
                      INPUT par_cdrmativ,
                      INPUT par_nrdddtfc,
                      INPUT par_nrtelefo,
                      INPUT par_nrlicamb,
                      INPUT par_nrcpfcgc,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Altera, LEAVE Altera.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Altera, LEAVE Altera.
            END.
        END CASE.

        IF   par_idorigem = 5   THEN /* Somente Ayllos Web */
             DO:
                 RUN Atualiza_Email 
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT 1, /* idseqttl */
                      INPUT par_nmdatela,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT par_rowidcem,
                      INPUT par_dsdemail,
                     OUTPUT par_dscritic).              
              
                 IF  RETURN-VALUE <> "OK" THEN
                     UNDO Altera, LEAVE Altera.   

                 IF   crabass.inpessoa = 1 THEN
                      DO:
                          RUN Atualiza_Telefones 
                                (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT 1,/* idseqttl */
                                 INPUT par_nmdatela,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_nrdddres,
                                 INPUT par_nrtelres,
                                 INPUT par_nrdddcel,
                                 INPUT par_nrtelcel,
                                 INPUT par_cdopetfn,
                                OUTPUT par_dscritic). 
                          
                          IF  RETURN-VALUE <> "OK" THEN
                              UNDO Altera, LEAVE Altera. 
                      END.
             END.

        
        /* se for inclusao nao atualiza tab. auxiliares, endereco e telefone */
        IF  par_cddopcao = "I" THEN 
            DO:
               ASSIGN aux_returnvl = "OK".
               LEAVE Altera.
            END.
        
        /* ATUALIZAR TABELAS CADASTRAIS/AUXILIARES */
        RUN Altera_Cad
            ( INPUT crabass.cdcooper,
              INPUT crabass.nrdconta,
              INPUT crabass.cdagenci,
              INPUT crabass.inmatric,
              INPUT par_dtmvtolt,
              INPUT par_dtdemiss,
              INPUT aux_dtdemant,
              INPUT aux_dsmotdem,
              INPUT aux_cdmotant,
              INPUT aux_dsmotant,
              INPUT par_cdoperad,
              INPUT par_dsorigem,
              INPUT par_nmdatela,
              INPUT aux_flgpagto,
              INPUT aux_flgtroca,
              INPUT par_nrcadast,
              INPUT aux_nrcadant,
              INPUT par_cdempres,
              INPUT aux_cdempant,
              INPUT aux_cdageant,
              INPUT aux_cdsecant, /*cdsecext*/
              INPUT aux_cdsitant, /*cdsitdtl*/
              INPUT crabass.vllimcre,
              INPUT-OUTPUT crabass.cdmotdem,
              INPUT-OUTPUT crabass.cdsecext,
              INPUT-OUTPUT crabass.nrramemp,
              INPUT-OUTPUT crabass.vledvmto,
              INPUT-OUTPUT crabass.cdopedem,
              INPUT-OUTPUT crabass.cdsitdtl,
              INPUT-OUTPUT crabass.cdsitdct,
              INPUT-OUTPUT crabass.dtasitct,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ) NO-ERROR.
        
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Altera, LEAVE Altera.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Altera, LEAVE Altera.
                
        /* Atualizacao do Endereco */
        RUN Atualiza_End
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT 1, /* idseqttl */
              INPUT par_idorigem,
              INPUT par_nmdatela,
              INPUT par_cdoperad,
              INPUT par_cddopcao,
              INPUT par_dtmvtolt,
              INPUT crabass.inpessoa,
              INPUT UPPER(par_dsendere),
              INPUT par_nrendere,
              INPUT par_nrcepend,
              INPUT UPPER(par_complend),
              INPUT UPPER(par_nmbairro),
              INPUT UPPER(par_nmcidade),
              INPUT UPPER(par_cdufende),			  
              INPUT par_nrcxapst,
              INPUT par_idorigee,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Altera, LEAVE Altera.
            END.

        
        IF  RETURN-VALUE <> "OK" THEN
            UNDO Altera, LEAVE Altera.

        ASSIGN aux_returnvl = "OK".

        LEAVE Altera.
     END.

     IF VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

 END PROCEDURE. /* Altera */

/* ------------------------------------------------------------------------ */
/*                      GRAVA OS DADOS DO ASSOCIADO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Altera_Ass PRIVATE :

    DEF  PARAM BUFFER crabass FOR crapass.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdptl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdclcnae AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    AlteraAss: DO TRANSACTION
        ON ERROR  UNDO AlteraAss, LEAVE AlteraAss
        ON QUIT   UNDO AlteraAss, LEAVE AlteraAss
        ON STOP   UNDO AlteraAss, LEAVE AlteraAss
        ON ENDKEY UNDO AlteraAss, LEAVE AlteraAss:

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_dscritic = "Buffer da tabela da Associados nao " +
                                     "esta disponivel.".
               UNDO AlteraAss, LEAVE AlteraAss.
            END.

        /* Atualiza cadastro do associado */
        ASSIGN
            crabass.cdagenci = par_cdagepac
            crabass.cdsitcpf = par_cdsitcpf
            crabass.nrcpfcgc = par_nrcpfcgc
            crabass.nmprimtl = CAPS(par_nmprimtl)
            crabass.dtcnscpf = par_dtcnscpf
            crabass.dtdemiss = par_dtdemiss
            crabass.cdmotdem = par_cdmotdem
            crabass.cdclcnae = par_cdclcnae
            crabass.dtultalt = par_dtmvtolt NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO AlteraAss, LEAVE AlteraAss.
            END.

        CASE crabass.inpessoa:
            WHEN 1 THEN DO:
                /* Dados inerentes a PESSOA FISICA */
                ASSIGN
                   crabass.dsfiliac = CAPS(par_nmpaittl + " E " + par_nmmaettl)
                   crabass.nmpaiptl = CAPS(par_nmpaittl)
                   crabass.nmmaeptl = CAPS(par_nmmaettl)
                   crabass.cdsexotl = par_cdsexotl
                   crabass.dtnasctl = par_dtnasctl
                   crabass.cdnacion = par_cdnacion
                   /* Retirado campo crabass.dsnatura */
                   crabass.dsproftl = CAPS(par_dsproftl)
                   crabass.nrcadast = par_nrcadast
                   crabass.tpdocptl = CAPS(par_tpdocptl)
                   crabass.nrdocptl = par_nrdocptl
                   crabass.cdufdptl = CAPS(par_cdufdptl)
                   crabass.dtemdptl = par_dtemdptl NO-ERROR.


                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       UNDO AlteraAss, LEAVE AlteraAss.
                    END.

                /* Identificar orgao expedidor */
                IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                    RUN sistema/generico/procedures/b1wgen0052b.p 
                        PERSISTENT SET h-b1wgen0052b.

                ASSIGN crabass.idorgexp = 0.
                RUN identifica_org_expedidor IN h-b1wgen0052b 
                                   ( INPUT CAPS(par_cdoedptl),
                                    OUTPUT crabass.idorgexp,
                                    OUTPUT par_cdcritic, 
                                    OUTPUT par_dscritic).

                DELETE PROCEDURE h-b1wgen0052b.   

                IF  RETURN-VALUE = "NOK" THEN
                DO:
                    UNDO AlteraAss, LEAVE AlteraAss.
                END.

                /* Dados do Titular - Pessoa Fisica */
                ContadorTtl: DO aux_contador = 1 TO 10:

                    FIND crapttl WHERE crapttl.cdcooper = crabass.cdcooper AND
                                       crapttl.nrdconta = crabass.nrdconta AND
                                       crapttl.idseqttl = 1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapttl THEN
                        DO:
                           IF  LOCKED(crapttl) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        FIND crapttl WHERE
                                        crapttl.cdcooper = crapass.cdcooper AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1
                                        NO-LOCK NO-ERROR.

                                        IF  AVAILABLE crapttl THEN
                                            /* mostra us. que esta travando */
                                            ASSIGN par_dscritic = LockTabela(
                                                RECID(crapttl),"banco",
                                                "crapttl").
                                        ELSE
                                            ASSIGN par_cdcritic = 341.

                                        LEAVE ContadorTtl.
                                     END.
                                  
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorTtl.
                               END.
                           ELSE
                               DO:
                                  ASSIGN par_cdcritic = 821.
                                  LEAVE ContadorTtl.
                               END.
                        END.
                    ELSE
                        DO:
                           crapttl.cdestcvl = par_cdestcvl.
                           LEAVE ContadorTtl.
                        END.
                END. /* ContadorTtl */

                IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                    RUN sistema/generico/procedures/b1wgen0060.p
                        PERSISTENT SET h-b1wgen0060.

                ASSIGN par_dscritic = "".
            END.
            OTHERWISE DO:
                /* Dados inerentes a PESSOA JURIDICA */
                IF  crabass.inpessoa = 3 THEN
                    ASSIGN crabass.nrmatric = 999999.

                /*** Magui temporario ate eliminacao da CADAST ***/
                ASSIGN 
                    crabass.dtnasctl = par_dtiniatv.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       UNDO AlteraAss, LEAVE AlteraAss.
                    END.
            END.
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE AlteraAss.
     END.

     IF  VALID-HANDLE(h-b1wgen0060) THEN
         DELETE OBJECT h-b1wgen0060.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

END PROCEDURE. /* Altera_Ass */

/* ------------------------------------------------------------------------ */
/*       OPERACAO DE ALTERACAO [A] - LOGICA DO {cadastra_dados_matrica.i}   */
/* ------------------------------------------------------------------------ */
PROCEDURE Altera_Cad PRIVATE :

    DEF         INPUT PARAM par_cdcooper AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_nrdconta AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_cdagenci AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_inmatric AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_dtmvtolt AS DATE                      NO-UNDO.
    DEF         INPUT PARAM par_dtdematl AS DATE /* dtdemiss atual */ NO-UNDO.
    DEF         INPUT PARAM par_dtdemant AS DATE /* dtdemiss antiga*/ NO-UNDO.
    DEF         INPUT PARAM par_dsmotdem AS CHAR                      NO-UNDO.
    DEF         INPUT PARAM par_cdmotant AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_dsmotant AS CHAR                      NO-UNDO.
    DEF         INPUT PARAM par_cdoperad AS CHAR                      NO-UNDO.
    DEF         INPUT PARAM par_dsorigem AS CHAR                      NO-UNDO.
    DEF         INPUT PARAM par_nmdatela AS CHAR                      NO-UNDO.
    DEF         INPUT PARAM par_flgpagto AS LOG                       NO-UNDO.
    DEF         INPUT PARAM par_flgtroca AS LOG                       NO-UNDO.
    DEF         INPUT PARAM par_nrcadast AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_nrcadant AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_cdempres AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_cdempant AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_cdageant AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_cdsecant AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_cdsitant AS INTE                      NO-UNDO.
    DEF         INPUT PARAM par_vllimcre AS DECI                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdmotdem AS INTE                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdsecext AS INTE                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_nrramemp AS INTE                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_vledvmto AS DECI                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdopedem AS CHAR                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdsitdtl AS INTE                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdsitdct AS INTE                      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_dtasitct AS DATE                      NO-UNDO.
    DEF        OUTPUT PARAM par_cdcritic AS INTE                      NO-UNDO.
    DEF        OUTPUT PARAM par_dscritic AS CHAR                      NO-UNDO.
                                                                    
    DEF VAR aux_returnvl AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                     NO-UNDO.
    DEF VAR h-b1wgen0008 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_qtdemmes AS INTE                                      NO-UNDO.
    DEF VAR aux_qtdesmes AS INTE                                      NO-UNDO.

    DEF BUFFER crabrpp FOR craprpp.
    DEF BUFFER crabpla FOR crappla.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    AlteraCad: DO TRANSACTION
        ON ERROR  UNDO AlteraCad, LEAVE AlteraCad
        ON QUIT   UNDO AlteraCad, LEAVE AlteraCad
        ON STOP   UNDO AlteraCad, LEAVE AlteraCad
        ON ENDKEY UNDO AlteraCad, LEAVE AlteraCad:
        
        /* Tabela de matriculas */
        ContadorMat: DO aux_contador = 1 TO 10:

            FIND FIRST crapmat WHERE crapmat.cdcooper = par_cdcooper 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapmat THEN
                DO:
                   IF  LOCKED crapmat THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND FIRST crapmat 
                                         WHERE crapmat.cdcooper = par_cdcooper 
                                         NO-LOCK NO-ERROR .
                                 IF  AVAILABLE crapmat THEN
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapmat),"banco","crapmat").   
                                 ELSE 
                                     ASSIGN par_cdcritic = 73.   

                                 LEAVE ContadorMat.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorMat.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 71.
                          LEAVE ContadorMat.
                       END.
                END.
            LEAVE ContadorMat.
        END.

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO AlteraCad, LEAVE AlteraCad.

        /*  Na DEMISSAO  */
        IF  par_dtdematl <> ? AND par_dtdemant = ? THEN
            DO:
               IF  par_cdsecext > 0 THEN
                   ASSIGN par_cdsecext = 999.

               ASSIGN 
                   par_nrramemp = 9999
                   par_vledvmto = 0
                   par_cdopedem = par_cdoperad.

               IF  par_cdsitdtl < 3 THEN
                   ASSIGN 
                       par_cdsitdct = 4
                       par_cdsitdtl = par_cdsitdtl + 2
                       par_dtasitct = par_dtmvtolt.

               IF  par_inmatric = 1 THEN
                   DO:
                      /* Buscar a proxima sequencia */
                      RUN STORED-PROCEDURE pc_sequence_progress
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                          ,INPUT "QTDEMMES"
                                                          ,INPUT STRING(par_cdcooper)
                                                          ,INPUT "N"
                                                          ,"").
                      
                      CLOSE STORED-PROC pc_sequence_progress
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                
                      ASSIGN aux_qtdemmes = INTE(pc_sequence_progress.pr_sequence)
                                            WHEN pc_sequence_progress.pr_sequence <> ?.

                      ASSIGN crapmat.qtdemmes = aux_qtdemmes.
                   END.

               BlocoRpp:
               FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                      craprpp.nrdconta = par_nrdconta AND
                                     (craprpp.cdsitrpp = 1 OR
                                      craprpp.cdsitrpp = 2) NO-LOCK:

                   ContadorRpp: DO aux_contador = 1 TO 10:
                       FIND crabrpp WHERE ROWID(crabrpp) = ROWID(craprpp)
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF  NOT AVAILABLE crabrpp THEN
                           IF  LOCKED crabrpp THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         /* encontra o us.que esta travando */
                                         ASSIGN par_dscritic = LockTabela(
                                             RECID(craprpp),"banco","craprpp").
                                         
                                         LEAVE ContadorRpp.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorRpp.
                               END.
                       LEAVE ContadorRpp.
                   END. /* BlocoRpp */

                   IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                       UNDO AlteraCad, LEAVE AlteraCad.

                   ASSIGN 
                       crabrpp.cdsitrpp = crabrpp.cdsitrpp + 2
                       crabrpp.dtcancel = par_dtdematl.

                   RELEASE crabrpp.
               END.  /*  Fim do FOR EACH craprpp */
            END.
        ELSE
        /*  Na DESDEMISSAO  */
        IF  par_dtdematl = ? AND par_dtdemant <> ? THEN
            DO:
               /* campos que vao atualizar o crapass via INPUT-OUTPUT */
               ASSIGN 
                   par_cdsitdct = 1
                   par_cdsitdtl = par_cdsitdtl - 2
                   par_dtasitct = par_dtmvtolt
                   par_cdopedem = ""
                   par_cdmotdem = 0. /* retirar o motivo da demissao */

               /* Registrar o log da operacao */
               RUN proc_gerar_log 
                   ( INPUT par_cdcooper,
                     INPUT par_cdoperad,
                     INPUT "",
                     INPUT par_dsorigem,
                     INPUT ("Retirada da data de demissao:"   + " Data: "   + 
                            STRING(par_dtdemant,"99/99/9999") + " Motivo: " +
                            STRING(par_cdmotant) + "-" + par_dsmotant),
                     INPUT YES,
                     INPUT 1, 
                     INPUT par_nmdatela, 
                     INPUT par_nrdconta, 
                    OUTPUT aux_nrdrowid ).

               /* item log - data */
               RUN proc_gerar_log_item 
                   ( INPUT aux_nrdrowid,
                     INPUT "dtdemiss",
                     INPUT STRING(par_dtdemant,"99/99/99"),
                     INPUT "" ).

               /* item log - codigo/motivo */
               RUN proc_gerar_log_item 
                   ( INPUT aux_nrdrowid,
                     INPUT "cdmotdem",
                     INPUT STRING(par_cdmotant) + "-" + par_dsmotant,
                     INPUT "" ).

               IF  par_inmatric = 1 THEN
                   IF MONTH(par_dtmvtolt) = MONTH(par_dtdemant) AND
                      YEAR(par_dtmvtolt)  = YEAR(par_dtdemant) THEN
                      DO:
                         /* Buscar a proxima sequencia */ 
                         RUN STORED-PROCEDURE pc_sequence_progress
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                         									 ,INPUT "QTDEMMES"
                         									 ,INPUT STRING(par_cdcooper)
                         									 ,INPUT "S"
                         									 ,"").
                         
                         CLOSE STORED-PROC pc_sequence_progress
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                         		  
                         ASSIGN aux_qtdemmes = INTE(pc_sequence_progress.pr_sequence)
                         					   WHEN pc_sequence_progress.pr_sequence <> ?.

                         ASSIGN crapmat.qtdemmes = aux_qtdemmes.
                      END.
                   ELSE
                      DO:
                         /* Buscar a proxima sequencia */ 
                         RUN STORED-PROCEDURE pc_sequence_progress
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                         									 ,INPUT "QTDESMES"
                         									 ,INPUT STRING(par_cdcooper)
                         									 ,INPUT "N"
                         									 ,"").
                         
                         CLOSE STORED-PROC pc_sequence_progress
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                         		  
                         ASSIGN aux_qtdesmes = INTE(pc_sequence_progress.pr_sequence)
                         					   WHEN pc_sequence_progress.pr_sequence <> ?.

                         ASSIGN crapmat.qtdesmes = aux_qtdesmes.
                      END.

               IF  NOT VALID-HANDLE(h-b1wgen0008) THEN
                   RUN sistema/generico/procedures/b1wgen0008.p
                       PERSISTENT SET h-b1wgen0008.

               BlocoRpp:
               FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                      craprpp.nrdconta = par_nrdconta AND
                                     (craprpp.cdsitrpp = 3 OR
                                      craprpp.cdsitrpp = 4)           AND
                                      craprpp.dtcancel = par_dtdemant
                                      NO-LOCK:

                   ContadorRpp: DO aux_contador = 1 TO 10:
                       FIND crabrpp WHERE ROWID(crabrpp) = ROWID(craprpp)
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF  NOT AVAILABLE crabrpp THEN
                           IF  LOCKED crabrpp THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         /* encontra o us.que esta travando */
                                         ASSIGN par_dscritic = LockTabela(
                                             RECID(craprpp),"banco","craprpp").

                                         LEAVE ContadorRpp.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorRpp.
                               END.
                       LEAVE ContadorRpp.
                   END. /* ContadorRpp */

                   IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                       UNDO AlteraCad, LEAVE AlteraCad.

                   ASSIGN 
                       crabrpp.cdsitrpp = craprpp.cdsitrpp - 2
                       crabrpp.dtcancel = ?.

                   IF  crabrpp.dtdebito < par_dtmvtolt THEN
                       RUN calcdata IN h-b1wgen0008
                           ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT 0,
                             INPUT par_cdoperad,
                             INPUT crabrpp.dtdebito,
                             INPUT 1,
                             INPUT "M",
                             INPUT 0,
                            OUTPUT crabrpp.dtdebito,
                            OUTPUT TABLE tt-erro ).

                   EMPTY TEMP-TABLE tt-erro.

                   RELEASE crabrpp.
               END.  /*  Fim do FOR EACH craprpp */
            END.

        /* Atualizar o motivo da demissao */
        IF  (par_cdmotant <> par_cdmotdem) AND 
            (par_dtdemant <> ? AND par_dtdematl <> ?) THEN
            DO:
               /* atualizacao do crapass via INPUT-OUTPUT */
               ASSIGN par_cdopedem = par_cdoperad.

               /* Registrar o log da operacao */
               RUN proc_gerar_log 
                   ( INPUT par_cdcooper,
                     INPUT par_cdoperad,
                     INPUT "",
                     INPUT par_dsorigem,
                     INPUT ("Alterado o motivo da saida de socio De: " + 
                            STRING(par_cdmotant) + "-" + par_dsmotant  + 
                            " Para: " + STRING(par_cdmotdem)     + "-" + 
                            par_dsmotdem),
                     INPUT YES,
                     INPUT 1, 
                     INPUT par_nmdatela, 
                     INPUT par_nrdconta, 
                    OUTPUT aux_nrdrowid ).

               /* item log - codigo/motivo */
               RUN proc_gerar_log_item 
                   ( INPUT aux_nrdrowid,
                     INPUT "cdmotdem",
                     INPUT STRING(par_cdmotant) + "-" + par_dsmotant,
                     INPUT STRING(par_cdmotdem) + "-" + par_dsmotdem ).
            END.

        /* DEMISSAO OU 'DESDEMISSAO' */
        IF  par_dtdematl <> par_dtdemant THEN
            DO:
               /* Altera os planos de capital na demissao e desdemissao */
               FOR EACH crappla WHERE crappla.cdcooper = par_cdcooper AND
                                      crappla.nrdconta = par_nrdconta AND
                                      crappla.cdsitpla <> 9 NO-LOCK:

                   ContadorPla: DO aux_contador = 1 TO 10:
                       FIND crabpla WHERE ROWID(crabpla) = ROWID(crappla)
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF  NOT AVAILABLE crabpla THEN
                           IF  LOCKED crabpla THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         /* encontra o us.que esta travando */
                                         ASSIGN par_dscritic = LockTabela(
                                             RECID(crappla),"banco","crappla").

                                         LEAVE ContadorPla.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorPla.
                               END.
                       LEAVE ContadorPla.
                   END. /* ContadorPla */

                   IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                       UNDO AlteraCad, LEAVE AlteraCad.

                   /*  Na DEMISSAO  */
                   IF  par_dtdemant = ? THEN
                       DO:
                          IF  crabpla.cdsitpla = 1 THEN
                              ASSIGN 
                                  crabpla.cdsitpla = 2
                                  crabpla.dtcancel = par_dtdematl.
                       END.
                   ELSE
                       /* Na DESDEMISSAO  */
                       IF  par_dtdematl = ? THEN
                           DO:
                              IF  crabpla.dtcancel = par_dtdemant THEN  
                                  DO:
                                     IF  NOT crabpla.flgpagto THEN /* CONTA */
                                         ASSIGN 
                                             crabpla.cdsitpla = 1
                                             crabpla.dtcancel = ?.
                                     ELSE  /* FOLHA */
                                         IF  par_flgpagto THEN
                                             ASSIGN 
                                                 crabpla.cdsitpla = 1
                                                 crabpla.dtcancel = ?.
                                  END.
                           END.

                   RELEASE crabpla.

               END. /* FOR EACH crappla */
            END. /* par_dtdematl <> par_dtdemant  */

        /* atualizar tabelas complementares */
        RUN Altera_CadC
           ( INPUT par_cdcooper,
             INPUT par_nrdconta,
             INPUT par_cdoperad,
             INPUT par_dtmvtolt,
             INPUT par_dtdematl,
             INPUT par_dtdemant,
             INPUT par_cdmotant,
             INPUT par_flgpagto,
             INPUT par_flgtroca,
             INPUT par_nrcadast,
             INPUT par_nrcadant,
             INPUT par_cdempres,
             INPUT par_cdempant,
             INPUT par_cdagenci,
             INPUT par_cdageant,
             INPUT par_cdsecext,
             INPUT par_cdsecant,
             INPUT par_cdsitdct,
             INPUT par_cdsitant,
             INPUT par_vllimcre,
            OUTPUT par_cdcritic,
            OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO AlteraCad, LEAVE AlteraCad.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO AlteraCad, LEAVE AlteraCad.

        ASSIGN aux_returnvl = "OK".

        LEAVE AlteraCad.
    END.

    RELEASE crapmat.
    
    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Altera_Cad */

/* ------------------------------------------------------------------------ */
/*  OPERACAO DE ALTERACAO [A], COMPLEMENTO  - {cadastra_dados_matrica.i}    */
/* ------------------------------------------------------------------------ */
PROCEDURE Altera_CadC PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtdematl AS DATE /* dtdemiss atual */        NO-UNDO.
    DEF  INPUT PARAM par_dtdemant AS DATE /* dtdemiss antiga*/        NO-UNDO.
    DEF  INPUT PARAM par_cdmotant AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOG                              NO-UNDO.
    DEF  INPUT PARAM par_flgtroca AS LOG                              NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrcadant AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdempant AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdageant AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdsecant AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdsitant AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_vllimcre AS DECI                             NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                             NO-UNDO.
                                                                    
    DEF VAR aux_returnvl AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrseqneg AS INTE                                      NO-UNDO.

    DEF BUFFER crabpla FOR crappla.
    DEF BUFFER crabepr FOR crapepr.
    DEF BUFFER crabavs FOR crapavs.
    DEF BUFFER crabreq FOR crapreq.
    DEF BUFFER crabext FOR crapext.
    DEF BUFFER crabrda FOR craprda.
    DEF BUFFER crabrpp FOR craprpp.
    DEF BUFFER crabcld FOR crapcld.

    ASSIGN 
        par_cdcritic = 0
        par_dscritic = ""
        aux_returnvl = "NOK".

    AlteraCadC: DO TRANSACTION
        ON ERROR  UNDO AlteraCadC, LEAVE AlteraCadC
        ON QUIT   UNDO AlteraCadC, LEAVE AlteraCadC
        ON STOP   UNDO AlteraCadC, LEAVE AlteraCadC
        ON ENDKEY UNDO AlteraCadC, LEAVE AlteraCadC:

        IF  (par_nrcadast <> par_nrcadant) OR 
            (par_cdempant <> par_cdempres) THEN
            /*  Altera o cadastro dos emprestimos  */
            FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                   crapepr.nrdconta = par_nrdconta NO-LOCK:

                ContadorEpr: DO aux_contador = 1 TO 10:
                    FIND crabepr WHERE ROWID(crabepr) = ROWID(crapepr)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabepr THEN
                        IF  LOCKED crabepr THEN
                            DO:
                               IF  aux_contador = 10 THEN
                                   DO:
                                       /* encontra o us. que esta travando */
                                       ASSIGN par_dscritic = LockTabela(
                                           RECID(crapepr),"banco","crapepr").
                                      
                                      LEAVE ContadorEpr.
                                   END.

                               PAUSE 1 NO-MESSAGE.
                               NEXT ContadorEpr.
                            END.
                    LEAVE ContadorEpr.
                END. /* ContadorEpr */

                IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                    UNDO AlteraCadC, LEAVE AlteraCadC.

                /* nr. do cadastro */
                IF  par_nrcadast <> par_nrcadant THEN
                    ASSIGN crabepr.nrcadast = par_nrcadast.

                /* cod. da empresa */
                IF  par_cdempant <> par_cdempres THEN
                    ASSIGN crabepr.cdempres = par_cdempres.

                RELEASE crabepr.
            END.  /* Fim do FOR EACH crapepr par_nrcadast <> par_nrcadant */

        /*  Altera a empresa dos planos de capital  */
        IF  par_cdempant <> par_cdempres THEN
            FOR EACH crappla WHERE crappla.cdcooper = par_cdcooper AND
                                   crappla.nrdconta = par_nrdconta NO-LOCK:

                ContadorPla: DO aux_contador = 1 TO 10:

                    FIND crabpla WHERE ROWID(crabpla) = ROWID(crappla)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabpla THEN
                        IF  LOCKED crabpla THEN
                            DO:
                               IF  aux_contador = 10 THEN
                                   DO:
                                      /* encontra o us. que esta travando */
                                      ASSIGN par_dscritic = LockTabela(
                                          RECID(crappla),"banco","crappla").
                                      
                                      LEAVE ContadorPla.
                                   END.

                               PAUSE 1 NO-MESSAGE.
                               NEXT ContadorPla.
                            END.
                    LEAVE ContadorPla.
                END. /* ContadorPla */

                IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                    UNDO AlteraCadC, LEAVE AlteraCadC.

                IF  par_flgtroca     = YES AND 
                    crappla.cdsitpla = 1   AND 
                    crappla.flgpagto = YES THEN
                    ASSIGN 
                       crabpla.cdsitpla = 2
                       crabpla.dtcancel = par_dtmvtolt.

                ASSIGN crabpla.cdempres = par_cdempres.

                RELEASE crabpla.
            END.  /*  Fim do FOR EACH crappla par_cdempant <> par_cdempres */

        IF  (par_cdagenci <> par_cdageant) OR 
            (par_cdsecext <> par_cdsecant) OR 
            (par_cdempant <> par_cdempres) THEN
            BLOCO-ALT: DO:
               /* Altera a agencia dos debitos automaticos */
               FOR EACH crapavs WHERE crapavs.cdcooper = par_cdcooper AND
                                      crapavs.nrdconta = par_nrdconta NO-LOCK:
    
                   ContadorAvs: DO aux_contador = 1 TO 10:
                       FIND crabavs WHERE ROWID(crabavs) = ROWID(crapavs)
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF  NOT AVAILABLE crabavs THEN
                           IF  LOCKED crabavs THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         /* encontra o us. que esta travando */
                                         ASSIGN par_dscritic = LockTabela(
                                             RECID(crapavs),"banco","crapavs").
                                         
                                         LEAVE ContadorAvs.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorAvs.
                               END.
                       LEAVE ContadorAvs.
                   END. /* ContadorAvs */
    
                   IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                       UNDO AlteraCadC, LEAVE AlteraCadC.
    
                   IF  par_cdagenci <> par_cdageant THEN
                       ASSIGN crabavs.cdagenci = par_cdagenci.
    
                   IF  par_cdsecext <> par_cdsecant THEN
                       ASSIGN crabavs.cdsecext = par_cdsecext.
    
                   IF  (par_cdempres <> par_cdempant) AND 
                       crabavs.tpdaviso = 1 THEN
                       ASSIGN crabavs.cdempres = par_cdempres.
    
                   RELEASE crabavs.
               END. /* Fim do FOR EACH crapavs  */

               /* houve alteracao apenas na empresa e foi atualizado acima */
               IF  par_cdagenci = par_cdageant AND
                   par_cdsecext = par_cdsecant THEN
                   LEAVE BLOCO-ALT.

               IF  par_cdagenci <> par_cdageant THEN
                   DO:
                      /* Altera agencia das requisicoes */
                      FOR EACH crapreq WHERE 
                          crapreq.cdcooper = par_cdcooper AND
                          crapreq.cdagenci = par_cdageant AND
                          crapreq.nrdconta = par_nrdconta NO-LOCK:
    
                          ContadorReq: DO aux_contador = 1 TO 10:
                              FIND crabreq 
                                  WHERE ROWID(crabreq) = ROWID(crapreq)
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF  NOT AVAILABLE crabreq THEN
                                  IF  LOCKED crabreq THEN
                                      DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                /* usar. que esta travando */
                                                par_dscritic = LockTabela(
                                                    RECID(crapreq),
                                                    "banco","crapreq").
                                                
                                                LEAVE ContadorReq.
                                             END.

                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorReq.
                                      END.

                              LEAVE ContadorReq.
                          END. /* ContadorReq */
    
                          IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                              UNDO AlteraCadC, LEAVE AlteraCadC.
    
                          ASSIGN crabreq.cdagenci = par_cdagenci.
    
                          RELEASE crabreq.
                      END.  /*  Fim do FOR EACH  */
    
                      /* Altera agencia dos extratos solicitados */
                      FOR EACH crapext WHERE 
                          crapext.cdcooper = par_cdcooper AND
                          crapext.cdagenci = par_cdageant AND
                          crapext.nrdconta = par_nrdconta NO-LOCK:
    
                          ContadorExt: DO aux_contador = 1 TO 10:
                              FIND crabext 
                                  WHERE ROWID(crabext) = ROWID(crapext)
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF  NOT AVAILABLE crabext THEN
                                  IF  LOCKED crabext THEN
                                      DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                /* usar. que esta travando */
                                                par_dscritic = LockTabela(
                                                    RECID(crapext),
                                                    "banco","crapext").
                                                
                                                LEAVE ContadorExt.
                                             END.

                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorExt.
                                      END.
                              LEAVE ContadorExt.
                          END. /* ContadorExt */
    
                          IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                              UNDO AlteraCadC, LEAVE AlteraCadC.
    
                          ASSIGN crabext.cdagenci = par_cdagenci.
    
                          RELEASE crabext.
                      END.  /*  Fim do FOR EACH  */

                      /* Altera agencia no controle de lavagem de dinheiro */
                      FOR EACH crapcld WHERE 
                          crapcld.cdcooper = par_cdcooper AND
                          crapcld.cdagenci = par_cdageant AND
                          crapcld.nrdconta = par_nrdconta NO-LOCK:
    
                          ContadorCld: DO aux_contador = 1 TO 10:
                              FIND crabcld 
                                  WHERE ROWID(crabcld) = ROWID(crapcld)
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF  NOT AVAILABLE crabcld THEN
                                  IF  LOCKED crabcld THEN
                                      DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                /* usar. que esta travando */
                                                par_dscritic = LockTabela(
                                                    RECID(crapcld),
                                                    "banco","crapbld").
                                                
                                                LEAVE ContadorCld.
                                             END.

                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorCld.
                                      END.
                              LEAVE ContadorCld.
                          END. /* ContadorCar */
    
                          IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                              UNDO AlteraCadC, LEAVE AlteraCadC.
    
                          ASSIGN crabcld.cdagenci = par_cdagenci.
    
                          RELEASE crabcld.
                      END.  /*  Fim do FOR EACH  */

                   END. /* par_cdagenci <> par_cdageant */

               /* Altera agencia das aplicacoes RDCA */
               FOR EACH craprda WHERE craprda.cdcooper = par_cdcooper AND
                                      craprda.nrdconta = par_nrdconta NO-LOCK:

                   ContadorRda: DO aux_contador = 1 TO 10:
                       FIND crabrda WHERE ROWID(crabrda) = ROWID(craprda)
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF  NOT AVAILABLE crabrda THEN
                           IF  LOCKED crabrda THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         /* encontra o us. que esta travando */
                                         ASSIGN par_dscritic = LockTabela(
                                             RECID(craprda),"banco","craprda").

                                         LEAVE ContadorRda.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorRda.
                               END.
                       LEAVE ContadorRda.
                   END. /* ContadorRda */

                   IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                       UNDO AlteraCadC, LEAVE AlteraCadC.

                   IF  par_cdagenci <> par_cdageant THEN
                       ASSIGN crabrda.cdageass = par_cdagenci.

                   IF  par_cdsecext <> par_cdsecant THEN
                       ASSIGN crabrda.cdsecext = par_cdsecext.

                   RELEASE crabrda.
               END.  /*  Fim do FOR EACH craprda */

               /* Altera agencia das aplicacoes RDCA  Programadas */
               FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                      craprpp.nrdconta = par_nrdconta NO-LOCK:

                   ContadorRpp: DO aux_contador = 1 TO 10:
                       FIND crabrpp WHERE ROWID(crabrpp) = ROWID(craprpp)
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF  NOT AVAILABLE crabrpp THEN
                           IF  LOCKED crabrpp THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         /* encontra o us. que esta travando */
                                         ASSIGN par_dscritic = LockTabela(
                                             RECID(craprpp),"banco","craprpp").
                                         
                                         LEAVE ContadorRpp.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorRpp.
                               END.
                       LEAVE ContadorRpp.
                   END. /* ContadorRpp */

                   IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                       UNDO AlteraCadC, LEAVE AlteraCadC.

                   IF  par_cdagenci <> par_cdageant THEN
                       ASSIGN crabrpp.cdageass = par_cdagenci.

                   IF  par_cdsecext <> par_cdsecant THEN
                       ASSIGN crabrpp.cdsecext = par_cdsecext.

                   RELEASE crabrpp.
               END.  /*  Fim do FOR EACH craprpp */
            END. /* par_cdagenci <> par_cdageant */

        /* Gera registro no crapneg de alteracao de situacao de conta */
        IF  par_cdsitdct <> par_cdsitant THEN
            DO:
               ContadorNeg: DO aux_contador = 1 TO 10:

                   FIND FIRST crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                                            crapneg.nrdconta = par_nrdconta AND
                                            crapneg.dtiniest = par_dtmvtolt AND
                                            crapneg.cdhisest = 3 
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF  NOT AVAILABLE crapneg THEN
                       DO:
                          IF  LOCKED crapneg THEN
                              DO:
                                 IF  aux_contador = 10 THEN
                                     DO:
                                        FIND FIRST crapneg 
                                          WHERE crapneg.cdcooper = par_cdcooper
                                            AND crapneg.nrdconta = par_nrdconta
                                            AND crapneg.dtiniest = par_dtmvtolt
                                            AND crapneg.cdhisest = 3 
                                          NO-LOCK NO-ERROR.

                                        IF  AVAILABLE crapneg THEN
                                            /* mostra usar.que esta travando */
                                            ASSIGN par_dscritic = LockTabela(
                                                RECID(crapneg),
                                                "banco","crapneg").
                                        ELSE
                                            ASSIGN par_cdcritic = 341.
                                        
                                        LEAVE ContadorNeg.
                                     END.

                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorNeg.
                              END.

                          RUN STORED-PROCEDURE pc_sequence_progress
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
                                                              ,INPUT "NRSEQDIG"
                                                              ,INPUT STRING(par_cdcooper) + ";" + STRING(par_nrdconta)
                                                              ,INPUT "N"
                                                              ,"").
                          
                          CLOSE STORED-PROC pc_sequence_progress
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                    
                          ASSIGN aux_nrseqneg = INTE(pc_sequence_progress.pr_sequence)
                                                WHEN pc_sequence_progress.pr_sequence <> ?.

                          CREATE crapneg.
                          ASSIGN 
                              crapneg.cdhisest = 3
                              crapneg.cdobserv = 0
                              crapneg.dtiniest = par_dtmvtolt
                              crapneg.nrdconta = par_nrdconta
                              crapneg.nrdctabb = 0
                              crapneg.nrdocmto = 0
                              crapneg.nrseqdig = aux_nrseqneg
                              crapneg.qtdiaest = 0
                              crapneg.vlestour = 0
                              crapneg.vllimcre = par_vllimcre
                              crapneg.cdtctant = par_cdsitant
                              crapneg.cdtctatu = par_cdsitdct
                              crapneg.dtfimest = ?
                              crapneg.cdoperad = par_cdoperad
                              crapneg.cdbanchq = 0
                              crapneg.cdagechq = 0
                              crapneg.nrctachq = 0
                              crapneg.cdcooper = par_cdcooper.
                          VALIDATE crapneg.
                       END.
                   ELSE
                       DO:
                          ASSIGN crapneg.cdtctatu = par_cdsitdct.
        
                          IF  crapneg.cdtctant = crapneg.cdtctatu THEN
                              DELETE crapneg.

                          LEAVE ContadorNeg.
                       END.
               END. /* ContadorNeg */

               IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                   UNDO AlteraCadC, LEAVE AlteraCadC.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE AlteraCadC.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Altera_CadC */

/* ------------------------------------------------------------------------ */
/*                  GRAVA OS DADOS DO ASSOCIADO PESSOA FISICA               */
/* ------------------------------------------------------------------------ */
PROCEDURE Altera_Fis PRIVATE :

    DEF  INPUT PARAM par_rowidttl AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdptl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsecao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmtalttl AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabcje FOR crapcje.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    AlteraFis: DO TRANSACTION
        ON ERROR  UNDO AlteraFis, LEAVE AlteraFis
        ON QUIT   UNDO AlteraFis, LEAVE AlteraFis
        ON STOP   UNDO AlteraFis, LEAVE AlteraFis
        ON ENDKEY UNDO AlteraFis, LEAVE AlteraFis:

        /* Registro do Titular */
        ContadorTtl: DO aux_contador = 1 TO 10:

            FIND crabttl WHERE ROWID(crabttl) = par_rowidttl
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabttl THEN
                DO:
                   IF  LOCKED(crabttl) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabttl 
                                     WHERE ROWID(crabttl) = par_rowidttl
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabttl THEN
                                     /* encontra o us. que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabttl),"banco","crapttl").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorTtl.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorTtl.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 821.
                          LEAVE ContadorTtl.
                       END.
                END.
            ELSE
                LEAVE ContadorTtl.
        END. /* ContadorTtl */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO AlteraFis, LEAVE AlteraFis.

        ASSIGN crabttl.cdempres = par_cdempres
               crabttl.cdsexotl = par_cdsexotl
               crabttl.cdsitcpf = par_cdsitcpf
               crabttl.dtcnscpf = par_dtcnscpf
               crabttl.dtnasttl = par_dtnasctl
               crabttl.tpnacion = par_tpnacion
               crabttl.cdnacion = par_cdnacion
               crabttl.dsnatura = CAPS(par_dsnatura)
               crabttl.cdufnatu = CAPS(par_cdufnatu)
               crabttl.cdestcvl = par_cdestcvl
               crabttl.dsproftl = CAPS(par_dsproftl)
               crabttl.nmextttl = CAPS(par_nmprimtl)
               crabttl.nmmaettl = CAPS(par_nmmaettl)
               crabttl.nmpaittl = CAPS(par_nmpaittl)
               crabttl.nrcadast = par_nrcadast
               crabttl.inpessoa = 1
               crabttl.cdocpttl = par_cdocpttl
               crabttl.tpdocttl = CAPS(par_tpdocptl)
               crabttl.nrdocttl = par_nrdocptl
               crabttl.cdufdttl = CAPS(par_cdufdptl)
               crabttl.dtemdttl = par_dtemdptl
               crabttl.nrcpfcgc = par_nrcpfcgc
               crabttl.cdoperad = par_cdoperad
               crabttl.hrtransa = TIME
               crabttl.dttransa = par_dtmvtolt 
               crabttl.inhabmen = par_inhabmen
               crabttl.dthabmen = par_dthabmen
               crabttl.flgimpri = TRUE NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO AlteraFis, LEAVE AlteraFis.
            END.

        /* Identificar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN crabttl.idorgexp = 0.
        RUN identifica_org_expedidor IN h-b1wgen0052b 
                           ( INPUT CAPS(par_cdoedptl),
                            OUTPUT crabttl.idorgexp,
                            OUTPUT par_cdcritic, 
                            OUTPUT par_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            UNDO AlteraFis, LEAVE AlteraFis.
        END.     

        /* CONJUGE */
        ContadorCje: DO aux_contador = 1 TO 10:

            FIND crabcje WHERE crabcje.cdcooper = crabttl.cdcooper AND
                               crabcje.nrdconta = crabttl.nrdconta AND
                               crabcje.idseqttl = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabcje THEN
                DO:
                   IF  LOCKED(crabcje) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabcje 
                                     WHERE crabcje.cdcooper = crabttl.cdcooper
                                       AND crabcje.nrdconta = crabttl.nrdconta
                                       AND crabcje.idseqttl = 1 
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabcje THEN
                                     /* encontra o us. que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabcje),"banco","crapcje").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorCje.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorCje.
                       END.
                   ELSE
                       DO:
                          IF  NOT CAN-DO("01,07,05,06,07",
                                         STRING(par_cdestcvl,"99")) THEN
                              DO:
                                 /* Se nao for solteiro, viuvo, separado ou
                                    divorciado */

                                 /* Dados do Titular - Conjuge */
                                 CREATE crabcje.
                                 ASSIGN
                                     crabcje.cdcooper = crabttl.cdcooper
                                     crabcje.nrdconta = crabttl.nrdconta
                                     crabcje.idseqttl = 1 
                                     crabcje.nmconjug = CAPS(par_nmconjug)
                                     NO-ERROR.
    
                                 IF  ERROR-STATUS:ERROR THEN
                                     DO:
                                        ASSIGN par_dscritic = {&GET-MSG}.
                                        LEAVE ContadorCje.
                                     END.
                                 VALIDATE crabcje.
                              END.

                          LEAVE ContadorCje.
                       END.
                END.
            ELSE 
                DO:
                   IF  CAN-DO("01,07,05,06,07",STRING(par_cdestcvl,"99")) THEN
                       DO:
                          /* Solteiro, viuvo, separado ou divorciado */
                          DELETE crabcje.
                       END.
                   ELSE
                       ASSIGN crabcje.nmconjug = CAPS(par_nmconjug).

                   LEAVE ContadorCje.
                END.
        END. /* conjuge */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            LEAVE AlteraFis.

        /* Instancia a BO para executar as procedures */
        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        /* Se BO foi instanciada */
        IF  VALID-HANDLE(h-b1wgen9999) THEN
            DO:
                RUN Abrevia_Nome IN h-b1wgen9999
                    ( INPUT crabttl.nmextttl,
                      INPUT 25,
                     OUTPUT aux_nmtalttl ).

                /* Mata a instancia da BO */
                DELETE OBJECT h-b1wgen9999.
            END.

        ASSIGN crabttl.nmtalttl = REPLACE(aux_nmtalttl, ".", "").

        ASSIGN aux_returnvl = "OK".

        LEAVE AlteraFis.
    END.

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE OBJECT h-b1wgen9999.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Altera_Fis */

/* ------------------------------------------------------------------------ */
/*                GRAVA OS DADOS DO ASSOCIADO PESSOA JURIDICA               */
/* ------------------------------------------------------------------------ */
PROCEDURE Altera_Jur PRIVATE :

    DEF  INPUT PARAM par_rowidjur AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_natjurid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfansia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsest AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_idseqttl AS INT                                     NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR h-b1craptfc  AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0137 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabjur FOR crapjur.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    AlteraJur: DO TRANSACTION
        ON ERROR  UNDO AlteraJur, LEAVE AlteraJur
        ON QUIT   UNDO AlteraJur, LEAVE AlteraJur
        ON STOP   UNDO AlteraJur, LEAVE AlteraJur
        ON ENDKEY UNDO AlteraJur, LEAVE AlteraJur:

        ContadorJur: DO aux_contador = 1 TO 10:

            FIND crabjur WHERE ROWID(crabjur) = par_rowidjur
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabjur THEN
                DO:
                   IF  LOCKED(crabjur) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabjur 
                                     WHERE ROWID(crabjur) = par_rowidjur
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabjur THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabjur),"banco","crapjur").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorJur.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorJur.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_dscritic = "Cadastro de Pessoa Juridica" +
                                                " nao foi encontrado.".
                          LEAVE ContadorJur.
                       END.
                END.
            ELSE
                LEAVE ContadorJur.
                
        END. /* ContadorJur */

        ASSIGN aux_idseqttl = 0.

        IF  par_natjurid <> crabjur.natjurid OR
            par_nmfansia <> crabjur.nmfansia OR 
            par_cdrmativ <> crabjur.cdrmativ THEN
        	DO:
        
        
            IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                RUN sistema/generico/procedures/b1wgen0137.p 
                PERSISTENT SET h-b1wgen0137.
              
            RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                      ( INPUT crabjur.cdcooper,
                        INPUT crabjur.nrdconta,
                        INPUT aux_idseqttl,
                        INPUT par_nrcpfcgc,
                        INPUT par_dtmvtolt,
                        INPUT "10", /* CARTAO DE CNPJ */
                        INPUT par_cdoperad,
                       OUTPUT par_cdcritic,
                       OUTPUT par_dscritic).

            IF  VALID-HANDLE(h-b1wgen0137) THEN
              DELETE OBJECT h-b1wgen0137.
        	
        	END.

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO AlteraJur, LEAVE AlteraJur.

        ASSIGN 
            crabjur.nmextttl = CAPS(par_nmprimtl)
            crabjur.dtiniatv = par_dtiniatv
            crabjur.natjurid = par_natjurid
            crabjur.nmfansia = CAPS(par_nmfansia)
            crabjur.nrinsest = par_nrinsest
            crabjur.cdseteco = par_cdseteco
            crabjur.cdrmativ = par_cdrmativ
            crabjur.cdempres = 88
            crabjur.nrlicamb = par_nrlicamb NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO AlteraJur, LEAVE AlteraJur.
            END.

        /* Atualizacao do Telefone */
        RUN Atualiza_Tel
            ( INPUT crabjur.cdcooper,
              INPUT crabjur.nrdconta,
              INPUT 1, /* idseqttl */
              INPUT par_idorigem,
              INPUT par_nmdatela,
              INPUT par_cdoperad,
              INPUT par_cddopcao,
              INPUT par_dtmvtolt,
              INPUT par_nrdddtfc,
              INPUT par_nrtelefo,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO AlteraJur, LEAVE AlteraJur.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO AlteraJur, LEAVE AlteraJur.

        ASSIGN aux_returnvl = "OK".

        LEAVE AlteraJur.
     END.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

END PROCEDURE. /* Altera_Jur */

/* ------------------------------------------------------------------------ */
/*           ATUALIZA OS CONTROLES DE HISTORICO, CRAPALT E LOG              */
/* ------------------------------------------------------------------------ */
PROCEDURE Atualiza_His PRIVATE:

    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_tpaltera AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpendass AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        aux_returnvl = "NOK".

    AtualizaHis: DO ON ERROR UNDO AtualizaHis, LEAVE AtualizaHis:

        /* Dados do Associado */
        FIND crapass WHERE ROWID(crapass) = par_rowidass
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crapass THEN 
            DO:
               /* determina o tipo de pessoa da conta */
               CASE crapass.inpessoa:
                   WHEN 1 THEN DO:
                       /* Dados do Titular - Pessoa Fisica */
                       FIND crapttl WHERE 
                                    crapttl.cdcooper = crapass.cdcooper AND
                                    crapttl.nrdconta = crapass.nrdconta AND
                                    crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
    
                       ASSIGN aux_tpendass = 10.
                   END.
                   WHEN 2 OR WHEN 3 THEN DO:
                       /* Dados do Titular - Pessoa Juridica */
                       FIND crapjur WHERE 
                                    crapjur.cdcooper = crapass.cdcooper AND
                                    crapjur.nrdconta = crapass.nrdconta
                                    NO-LOCK NO-ERROR.
    
                       ASSIGN aux_tpendass = 9.
                   END.
               END CASE.
    
               /* Endereco (nro e complemento) */
               FIND crapenc WHERE crapenc.cdcooper = crapass.cdcooper AND
                                  crapenc.nrdconta = crapass.nrdconta AND
                                  crapenc.idseqttl = 1                AND
                                  crapenc.cdseqinc = 1                AND
                                  crapenc.tpendass = aux_tpendass
                                  NO-LOCK NO-ERROR.
              

               /* Telefone e DDD */
               FIND FIRST craptfc WHERE craptfc.cdcooper = crapass.cdcooper AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1              
                                        NO-LOCK NO-ERROR.
    
            END.

        /* esta variavel e usado na include de log */
        ASSIGN aux_dscritic = "".

        /* Tipos: A = b1wgenalog.i, L = b1wgenllog.i */
        IF  par_tpaltera = "A" THEN
            DO:
               IF  CAN-DO("A,X,J",par_cddopcao) THEN
                   DO:
                      { sistema/generico/includes/b1wgenalog.i 
                          &TELA-MATRIC=SIM &TELA-CONTAS=NAO }
                   END.
               
               /* Preparar registro para gravar log de alteracao */
               CREATE tt-crapass-ant.

               IF  AVAILABLE crapenc THEN
                   BUFFER-COPY crapenc TO tt-crapass-ant.
               
               IF  AVAILABLE craptfc THEN
                   BUFFER-COPY craptfc TO tt-crapass-ant.

               IF  AVAILABLE crapttl AND crapass.inpessoa = 1 THEN
                   BUFFER-COPY crapttl TO tt-crapass-ant.

               IF  AVAILABLE crapjur AND crapass.inpessoa > 1 THEN
                   BUFFER-COPY crapjur TO tt-crapass-ant.

               /* copiar registro para LOG */
               IF  AVAILABLE crapass THEN
                   BUFFER-COPY crapass TO tt-crapass-ant.
               
               /* alteracoes feitas especificas para cada tipo de pessoa */
               IF  tt-crapass-ant.inpessoa = 1 THEN
                   ASSIGN 
                       tt-crapass-ant.dsestcvl = "".
               ELSE
                   ASSIGN 
                       tt-crapass-ant.nrfonres = ""
                       tt-crapass-ant.dtnasctl = ?.
                
            END.

        ELSE
            IF  par_tpaltera = "L" THEN
                DO:
                   IF  CAN-DO("A,X,J",par_cddopcao) THEN
                       DO:
                          { sistema/generico/includes/b1wgenllog.i 
                              &TELA-MATRIC=SIM &TELA-CONTAS=NAO }
    
                          /* ocorreu erro no log */
                          IF  aux_dscritic <> "" THEN
                              DO:
                                 ASSIGN par_dscritic = aux_dscritic.
                                 LEAVE AtualizaHis.
                              END.
                       END.


                   /* Registros para gravar log de alteracao */
                   CREATE tt-crapass-atl.


                   IF  AVAILABLE crapenc THEN
                       BUFFER-COPY crapenc TO tt-crapass-atl.

                   IF  AVAILABLE craptfc THEN
                       BUFFER-COPY craptfc TO tt-crapass-atl.

                   IF  AVAILABLE crapttl AND crapass.inpessoa = 1 THEN
                       BUFFER-COPY crapttl TO tt-crapass-atl.

                   IF  AVAILABLE crapjur AND crapass.inpessoa > 1 THEN
                       BUFFER-COPY crapjur TO tt-crapass-atl.

                   /* copiar registro alterados para LOG */
                   IF  AVAILABLE crapass THEN
                       BUFFER-COPY crapass TO tt-crapass-atl.

                   /* alteracoes feitas especificas para cada tipo de pessoa */
                   IF  tt-crapass-atl.inpessoa = 1 THEN
                       ASSIGN 
                            tt-crapass-atl.dsestcvl = "".
                   ELSE
                        ASSIGN 
                           tt-crapass-atl.nrfonres = ""
                           tt-crapass-atl.dtnasctl = ?.

               END.

        ASSIGN aux_returnvl = "OK".

        LEAVE AtualizaHis.
    END.

    IF  par_dscritic <> "" THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Atualiza_His */


/* ------------------------------------------------------------------------ */
/*                       ATUALIZA OS DADOS DO EMAIL                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Atualiza_Email PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidcem AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.


    DEF VAR aux_returnvl          AS CHAR                           NO-UNDO.
    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR aux_secpscto          AS CHAR                           NO-UNDO.
    DEF VAR aux_nmpescto          AS CHAR                           NO-UNDO.
    DEF VAR aux_prgqfalt          AS CHAR                           NO-UNDO.
    DEF VAR aux_tpaltcad          AS INTE                           NO-UNDO.
    DEF VAR aux_msgatcad          AS CHAR                           NO-UNDO.
    DEF VAR aux_chavealt          AS CHAR                           NO-UNDO.           
    DEF VAR aux_msgrvcad          AS CHAR                           NO-UNDO.
    DEF VAR aux_cddopcao          AS CHAR                           NO-UNDO.

    DEF VAR h-b1wgen0071          AS HANDLE                         NO-UNDO.


    ASSIGN par_dscritic = ""
           aux_returnvl = "OK".

    EMPTY TEMP-TABLE tt-erro.

    Email: DO ON ERROR UNDO Email, LEAVE Email: 
              
        /* Se ja tem email, obter os outros dados */
        IF   par_rowidcem <> ?   THEN 
             DO:
                 FIND crapcem WHERE ROWID(crapcem) = par_rowidcem 
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapcem   THEN
                      ASSIGN aux_secpscto = crapcem.secpscto
                             aux_nmpescto = crapcem.nmpescto
                             aux_prgqfalt = crapcem.prgqfalt.
             END.

        IF   AVAIL crapcem       AND   /* Se tinha email e agora  */
             par_dsdemail = ""   THEN  /* esta em branco, remover */  
             DO:                  
                 ASSIGN aux_cddopcao = "E".
             END.
        ELSE   
        IF   AVAIL crapcem        AND  /* Se ainda tem email, alterar  */ 
             par_dsdemail <> ""   THEN
             DO:                                    
                 ASSIGN aux_cddopcao = "A".        
             END.
        ELSE
        IF   NOT AVAIL crapcem     AND   /* Inclusao */
             par_dsdemail <> ""    THEN
             DO: 
                 ASSIGN aux_cddopcao = "I".
             END.
        ELSE                           /* Nao tinha email e nao enviou */
             DO:
                 ASSIGN aux_flgtrans = TRUE.
                 LEAVE Email.
             END.

        RUN sistema/generico/procedures/b1wgen0071.p 
            PERSISTENT SET h-b1wgen0071.
             
        RUN validar-email IN h-b1wgen0071
                         (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT 5, /* Ayllos Web */
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT aux_cddopcao,
                          INPUT par_rowidcem,
                          INPUT par_dsdemail,
                          INPUT aux_secpscto,
                          INPUT aux_nmpescto,
                          INPUT FALSE,
                          INPUT 0,
                         OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0071.

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Email, LEAVE Email.

        RUN sistema/generico/procedures/b1wgen0071.p 
            PERSISTENT SET h-b1wgen0071.

        RUN gerenciar-email IN h-b1wgen0071
                                 (INPUT par_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT 5, /* Ayllos Web */
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT aux_cddopcao,
                                  INPUT par_dtmvtolt,
                                  INPUT par_rowidcem,
                                  INPUT par_dsdemail,
                                  INPUT aux_secpscto,
                                  INPUT aux_nmpescto,
                                  INPUT aux_prgqfalt,
                                  INPUT FALSE,
                                  OUTPUT aux_tpaltcad,
                                  OUTPUT aux_msgatcad,
                                  OUTPUT aux_chavealt,
                                  OUTPUT aux_msgrvcad,
                                  OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0071.

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Email, LEAVE Email.

        ASSIGN aux_flgtrans = TRUE.

    END.
    
    IF   NOT aux_flgtrans THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro   THEN
                 ASSIGN par_dscritic = tt-erro.dscritic.
             ELSE 
                 ASSIGN par_dscritic = "Erro na gravacao do e-mail".

             ASSIGN aux_returnvl = "NOK".
         END.
        
    RETURN aux_returnvl.

END PROCEDURE.


PROCEDURE Atualiza_Telefones PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.


    DEF VAR aux_returnvl          AS CHAR                           NO-UNDO.
    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.


    ASSIGN par_dscritic = ""
           aux_returnvl = "OK".

    EMPTY TEMP-TABLE tt-erro.

    Telefones: DO ON ERROR UNDO Telefones, LEAVE Telefones: 

        /* Atualizar o telefone residencial */
        RUN Atualiza_Telefone (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT 1, /* Residencial */
                               INPUT par_nrdddres,
                               INPUT par_nrtelres,
                               INPUT 0,
                              OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Telefones, LEAVE Telefones.

        /* Atualizar o telefone celular */
        RUN Atualiza_Telefone (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT 2, /* Celular */
                               INPUT par_nrdddcel,
                               INPUT par_nrtelcel,
                               INPUT par_cdopetfn,
                              OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Telefones, LEAVE Telefones.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro   THEN
                 ASSIGN par_dscritic = tt-erro.dscritic.
             ELSE 
                 ASSIGN par_dscritic = "Erro na gravacao dos Telefones".

             ASSIGN aux_returnvl = "NOK".
         END.
        
    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Atualiza_Telefone:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tptelefo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro. 


    DEF VAR aux_returnvl          AS CHAR                           NO-UNDO.
    DEF VAR aux_cddopcao          AS CHAR                           NO-UNDO.
    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR aux_rowidtfc          AS ROWID                          NO-UNDO.
    DEF VAR aux_tpaltcad          AS INTE                           NO-UNDO.
    DEF VAR aux_msgatcad          AS CHAR                           NO-UNDO.
    DEF VAR aux_chavealt          AS CHAR                           NO-UNDO.           
    DEF VAR aux_msgrvcad          AS CHAR                           NO-UNDO.
    
    DEF VAR h-b1wgen0070          AS HANDLE                         NO-UNDO.


    ASSIGN aux_returnvl = "OK".

    EMPTY TEMP-TABLE tt-erro.

    Telefone: DO ON ERROR UNDO Telefone, LEAVE Telefone: 

        FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper   AND
                                 craptfc.nrdconta = par_nrdconta   AND
                                 craptfc.idseqttl = par_idseqttl   AND
                                 craptfc.tptelefo = par_tptelefo
                                 NO-LOCK NO-ERROR.

        IF   AVAILABLE craptfc THEN
             ASSIGN aux_rowidtfc = ROWID(craptfc).
           
        IF   AVAIL craptfc      AND   /* Se tinha telefone e agora  */
             par_nrtelefo = 0   THEN  /* esta em branco, remover */  
             DO:                  
                 ASSIGN aux_cddopcao = "E".
             END.
        ELSE   
        IF   AVAIL craptfc       AND  /* Se ainda tem telefone, alterar  */ 
             par_nrtelefo <> 0   THEN
             DO:                                    
                 ASSIGN aux_cddopcao = "A".        
             END.
        ELSE
        IF   NOT AVAIL craptfc   AND   /* Inclusao */
             par_nrtelefo <> 0   THEN
             DO: 
                 ASSIGN aux_cddopcao = "I".
             END.
        ELSE                           /* Nao tinha telefone e nao enviou */
             DO:
                 ASSIGN aux_flgtrans = TRUE.
                 LEAVE Telefone.
             END.

        RUN sistema/generico/procedures/b1wgen0070.p
            PERSISTENT SET h-b1wgen0070.

        RUN gerenciar-telefone IN h-b1wgen0070
                 ( INPUT par_cdcooper,
                   INPUT 0,
                   INPUT 0,
                   INPUT par_cdoperad,
                   INPUT par_nmdatela,
                   INPUT 5, /* Ayllos Web */
                   INPUT par_nrdconta,
                   INPUT par_idseqttl,
                   INPUT aux_cddopcao,
                   INPUT par_dtmvtolt,
                   INPUT aux_rowidtfc,
                   INPUT par_tptelefo,   
                   INPUT par_nrdddtfc,                 
                   INPUT par_nrtelefo,                 
                   INPUT 0,
                   INPUT "",  
                   INPUT "",  
                   INPUT par_cdopetfn,                      
                   INPUT "A",
                   INPUT NO,
                   INPUT 1,
                   INPUT 1,
                  OUTPUT aux_tpatlcad,
                  OUTPUT aux_msgatcad,
                  OUTPUT aux_chavealt,
                  OUTPUT aux_msgrvcad,
                  OUTPUT TABLE tt-erro ).

        DELETE PROCEDURE h-b1wgen0070.

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Telefone, LEAVE Telefone.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans THEN
         aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE.



/* ------------------------------------------------------------------------ */
/*                       ATUALIZA OS DADOS DO ENDERECO                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Atualiza_End PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0038 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpatlcad AS INTE                                    NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                    NO-UNDO.
    DEF VAR aux_incasprp AS INTE                                    NO-UNDO.
    DEF VAR aux_dtinires AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlalugue AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdoapto AS INTE                                    NO-UNDO.
    DEF VAR aux_cddbloco AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.

    DEF BUFFER crabenc FOR crapenc.

    ASSIGN
        par_dscritic = ""
        aux_returnvl = "NOK".

    Endereco: DO ON ERROR UNDO Endereco, LEAVE Endereco:
        EMPTY TEMP-TABLE tt-erro.

        FIND crabenc WHERE crabenc.cdcooper = par_cdcooper   AND
                           crabenc.nrdconta = par_nrdconta   AND
                           crabenc.idseqttl = 1              AND
                           crabenc.cdseqinc = 1              AND
                           crabenc.tpendass = (IF  par_inpessoa = 1  THEN
                                                   10  /* Residencial */
                                               ELSE
                                                   9)  /* Comercial */
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crabenc  THEN
            DO:
                ASSIGN aux_incasprp = crabenc.incasprp
                       aux_vlalugue = crabenc.vlalugue
                       aux_nrdoapto = crabenc.nrdoapto
                       aux_cddbloco = crabenc.cddbloco.

                IF  crabenc.dtinires <> ?  THEN
                    ASSIGN aux_dtinires = 
                           SUBSTR(STRING(crabenc.dtinires,"99/99/9999"),4).
            END.
        ELSE
            ASSIGN aux_incasprp = 0
                   aux_dtinires = ""
                   aux_vlalugue = 0
                   aux_nrdoapto = 0
                   aux_cddbloco = "".

        IF  NOT VALID-HANDLE(h-b1wgen0038) THEN
            RUN sistema/generico/procedures/b1wgen0038.p 
                PERSISTENT SET h-b1wgen0038.
        
        RUN alterar-endereco IN h-b1wgen0038
            ( INPUT par_cdcooper,
              INPUT 0, 
              INPUT 0, 
              INPUT par_cdoperad, 
              INPUT par_nmdatela, 
              INPUT par_idorigem, 
              INPUT par_nrdconta, 
              INPUT 1, /* idseqttl */
              INPUT par_cddopcao, 
              INPUT par_dtmvtolt, 
              INPUT aux_incasprp,
              INPUT aux_dtinires, /* Formato 99/9999 */
              INPUT aux_vlalugue,
              INPUT par_dsendere, 
              INPUT par_nrendere, 
              INPUT par_nrcepend, 
              INPUT par_complend, 
              INPUT aux_nrdoapto,
              INPUT aux_cddbloco,
              INPUT par_nmbairro, 
              INPUT par_nmcidade, 
              INPUT par_cdufende, 
              INPUT par_nrcxapst,
              INPUT 0, /* Valor e qtd de parcelas */
              INPUT 0, /* Atualizados somente via tela CONTAS */ 
              INPUT 0,
              INPUT NO,
              INPUT par_idorigee,	
             OUTPUT aux_msgalert,
             OUTPUT aux_tpatlcad,
             OUTPUT aux_msgatcad,
             OUTPUT aux_chavealt,
             OUTPUT aux_msgrvcad,
             OUTPUT TABLE tt-erro ) NO-ERROR.
        
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO Endereco, LEAVE Endereco.
            END.
        
        IF  RETURN-VALUE <> "OK" THEN DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN 
                DO: 
                   ASSIGN par_dscritic = tt-erro.dscritic.

                   EMPTY TEMP-TABLE tt-erro.
                END.
            ELSE
                ASSIGN par_dscritic = "Erro na gravacao do Endereco".

            UNDO Endereco, LEAVE Endereco.
        END.
		
        ASSIGN aux_returnvl = "OK".

        LEAVE Endereco.

    END.

    IF  VALID-HANDLE(h-b1wgen0038) THEN
        DELETE OBJECT h-b1wgen0038.

    IF  par_dscritic <> "" THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Atualiza_End */

/* ------------------------------------------------------------------------ */
/*                       ATUALIZA OS DADOS DO TELEFONE                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Atualiza_Tel PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0070 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_tpatlcad AS INTE                                    NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                    NO-UNDO.
    DEF VAR aux_rowidtfc AS ROWID                                   NO-UNDO.
    DEF VAR aux_nrdramal AS INTE                                    NO-UNDO.
    DEF VAR aux_secpscto AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmpescto AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdopetfn AS INTE                                    NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.

    DEF BUFFER crabtfc FOR craptfc.

    ASSIGN
        par_dscritic = ""
        aux_returnvl = "NOK".

    Telefone: DO ON ERROR UNDO Telefone, LEAVE Telefone:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0070) THEN
            RUN sistema/generico/procedures/b1wgen0070.p
                PERSISTENT SET h-b1wgen0070.

        FIND FIRST crabtfc WHERE crabtfc.cdcooper = par_cdcooper AND
                                 crabtfc.nrdconta = par_nrdconta AND
                                 crabtfc.idseqttl = 1
                                 NO-LOCK NO-ERROR.

        IF  AVAILABLE crabtfc THEN
            ASSIGN aux_rowidtfc = ROWID(crabtfc)
                   aux_nrdramal = crabtfc.nrdramal
                   aux_secpscto = crabtfc.secpscto
                   aux_nmpescto = crabtfc.nmpescto
                   aux_cdopetfn = crabtfc.cdopetfn.
        ELSE 
            ASSIGN aux_rowidtfc = ?
                   aux_nrdramal = 0
                   aux_secpscto = ""
                   aux_nmpescto = ""
                   aux_cdopetfn = 0.

        RUN gerenciar-telefone IN h-b1wgen0070
            ( INPUT par_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT 1,
              INPUT par_cddopcao,
              INPUT par_dtmvtolt,
              INPUT aux_rowidtfc,
              INPUT 3,            /* tptelefo */  
              INPUT par_nrdddtfc,                 
              INPUT par_nrtelefo,                 
              INPUT aux_nrdramal,
              INPUT aux_secpscto,  
              INPUT aux_nmpescto,  
              INPUT aux_cdopetfn,                      
              INPUT "A",
              INPUT NO,
              INPUT 1,
              INPUT 1,
             OUTPUT aux_tpatlcad,
             OUTPUT aux_msgatcad,
             OUTPUT aux_chavealt,
             OUTPUT aux_msgrvcad,
             OUTPUT TABLE tt-erro ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO Telefone, LEAVE Telefone.
            END.

        IF  RETURN-VALUE <> "OK" THEN DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                   ASSIGN par_dscritic = tt-erro.dscritic.
                   EMPTY TEMP-TABLE tt-erro.
                END.
            ELSE
                ASSIGN par_dscritic = "Erro na gravacao do Telefone".

            UNDO Telefone, LEAVE Telefone.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Telefone.
    END.

    IF  VALID-HANDLE(h-b1wgen0070) THEN
        DELETE OBJECT h-b1wgen0070.

    IF  par_dscritic <> "" THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Atualiza_Tel */

/* ------------------------------------------------------------------------ */
/*      GRAVA OS DADOS ORIGINADOS NA OPCAO [D]=DESVINCULAR MATRICULA        */
/* ------------------------------------------------------------------------ */
PROCEDURE Desvincula PRIVATE :

    DEF  INPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                    NO-UNDO.
    DEF VAR aux_dtadmiss AS DATE                                    NO-UNDO.

    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.
    DEF VAR aux_nrmatric AS INTE                                    NO-UNDO.
    DEF VAR aux_qtassmes AS INTE                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabmat FOR crapmat.
    DEF BUFFER crabadm FOR crapadm.
    DEF BUFFER crabneg FOR crapneg.
    DEF BUFFER crabtrf FOR craptrf.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Desvincula: DO TRANSACTION
        ON ERROR  UNDO Desvincula, LEAVE Desvincula
        ON QUIT   UNDO Desvincula, LEAVE Desvincula
        ON STOP   UNDO Desvincula, LEAVE Desvincula
        ON ENDKEY UNDO Desvincula, LEAVE Desvincula:

        ContadorAss: DO aux_contador = 1 TO 10:

            FIND crabass WHERE ROWID(crabass) = par_rowidass
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabass THEN
                DO:
                   IF  LOCKED crabass THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabass 
                                     WHERE ROWID(crabass) = par_rowidass
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabass THEN
                                     /* encontra o us. que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabass),"banco","crapass").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
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
                          ASSIGN par_cdcritic = 9.
                          LEAVE ContadorAss.
                       END.
                END.
            ELSE
                LEAVE ContadorAss.
        END. /* ContadorAss */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO Desvincula, LEAVE Desvincula.

        ContadorTrf: DO aux_contador = 1 TO 10:

            FIND crabtrf WHERE crabtrf.cdcooper = crabass.cdcooper AND
                               crabtrf.nrsconta = crabass.nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabtrf THEN
                DO:
                   IF  LOCKED(crabtrf) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabtrf 
                                     WHERE crabtrf.cdcooper = crabass.cdcooper 
                                       AND crabtrf.nrsconta = crabass.nrdconta
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabtrf THEN
                                     /* encontra o us. que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabtrf),"banco","craptrf").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorTrf.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorTrf.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 124.
                          LEAVE ContadorTrf.
                       END.
                END.
            ELSE
                DO:
                   IF  crabtrf.tptransa <> 2 THEN
                       ASSIGN par_cdcritic = 810.

                   LEAVE ContadorTrf.
                END.
        END. /* ContadorTrf */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO Desvincula, LEAVE Desvincula.

        ContadorMat: DO aux_contador = 1 TO 10:

            FIND FIRST crabmat WHERE crabmat.cdcooper = crabass.cdcooper
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabmat THEN
                DO:
                   IF  LOCKED(crabmat) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                  FIND FIRST crabmat 
                                      WHERE crabmat.cdcooper = crabass.cdcooper
                                      NO-LOCK NO-ERROR .
                                  IF  AVAILABLE crabmat THEN
                                      ASSIGN par_dscritic = LockTabela(
                                          RECID(crabmat),"banco","crapmat").   
                                  ELSE 
                                      ASSIGN par_cdcritic = 73.   
                                  LEAVE ContadorMat.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorMat.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 642.
                          LEAVE ContadorMat.
                       END.
                END.
            ELSE
                DO:
                   /* Buscar a proxima sequencia de associado no mes */
                   RUN STORED-PROCEDURE pc_sequence_progress
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                       ,INPUT "QTASSMES"
                                                       ,STRING(crabmat.cdcooper)
                                                       ,INPUT "N"
                                                       ,"").
                      
                   CLOSE STORED-PROC pc_sequence_progress
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                             
                   ASSIGN aux_qtassmes = INTE(pc_sequence_progress.pr_sequence)
                                         WHEN pc_sequence_progress.pr_sequence <> ?.

                   /* Buscar a proxima sequencia matricula */
                   RUN STORED-PROCEDURE pc_sequence_progress
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                       ,INPUT "NRMATRIC"
                                                       ,STRING(crabmat.cdcooper)
                                                       ,INPUT "N"
                                                       ,"").
                      
                   CLOSE STORED-PROC pc_sequence_progress
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                             
                   ASSIGN aux_nrmatric = INTE(pc_sequence_progress.pr_sequence)
                                         WHEN pc_sequence_progress.pr_sequence <> ?.

                   ASSIGN crabmat.nrmatric = aux_nrmatric
                          crabmat.qtassmes = aux_qtassmes.
                   LEAVE ContadorMat.
                END.
        END. /* ContadorMat */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO Desvincula, LEAVE Desvincula.

        aux_dtadmiss = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4) 
                       - DAY(DATE(MONTH(par_dtmvtolt),28,
                                  YEAR(par_dtmvtolt)) + 4)).

        Admissao: DO WHILE TRUE: /* Verifica se a data e' valida p/o sistema */

           IF  LOOKUP(STRING(WEEKDAY(aux_dtadmiss)),"1,7") <> 0   THEN
               DO:
                   ASSIGN aux_dtadmiss = aux_dtadmiss - 1.
                   NEXT Admissao.
               END.
           ELSE
               DO:
                  IF  CAN-FIND(crapfer WHERE 
                               crapfer.cdcooper = crabass.cdcooper AND
                               crapfer.dtferiad = aux_dtadmiss)    THEN
                      DO:
                         ASSIGN aux_dtadmiss = aux_dtadmiss - 1.
                         NEXT Admissao.
                      END.
                  ELSE
                      DO:
                         ASSIGN aux_dtadmiss = IF crabass.inpessoa = 3 
                                               THEN crabass.dtnasctl
                                               ELSE aux_dtadmiss.        
                         LEAVE Admissao.
                      END.
               END.
        END.

        ASSIGN
            crabass.nrmatric = crabmat.nrmatric
            crabass.inmatric = 1
            crabass.dtadmiss = aux_dtadmiss
            NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO Desvincula, LEAVE Desvincula.
            END.

        ContadorAdm: DO aux_contador = 1 TO 10:

            FIND crabadm WHERE crabadm.cdcooper = crabass.cdcooper AND
                               crabadm.nrmatric = crabmat.nrmatric
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabadm THEN
                DO:
                   IF  LOCKED(crabadm) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND FIRST crabadm 
                                     WHERE crabadm.cdcooper = crabass.cdcooper
                                       AND crabadm.nrmatric = crabmat.nrmatric
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabadm THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabadm),"banco","crapadm").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
                                 LEAVE ContadorAdm.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorAdm.
                       END.
                   ELSE
                       DO:
                          CREATE crabadm.
                          ASSIGN 
                              crabadm.nrmatric = crabmat.nrmatric
                              crabadm.nrdconta = crabass.nrdconta
                              crabadm.cdcooper = crabass.cdcooper NO-ERROR.
    
                          IF  ERROR-STATUS:ERROR THEN
                              DO:
                                 ASSIGN par_dscritic = {&GET-MSG}.
                                 UNDO Desvincula, LEAVE Desvincula.
                              END.
  
                          VALIDATE crabadm.

                          LEAVE ContadorAdm.

                       END.
                END.
            ELSE
                LEAVE ContadorAdm.
        END. /* ContadorAdm */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO Desvincula, LEAVE Desvincula.

        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
                                            ,INPUT "NRSEQDIG"
                                            ,INPUT STRING(crabass.cdcooper) + ";" + STRING(crabass.nrdconta)
                                            ,INPUT "N"
                                            ,"").
      
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
        ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        CREATE crabneg.
        ASSIGN crabneg.cdcooper = crabass.cdcooper
               crabneg.nrdconta = crabass.nrdconta
               crabneg.nrseqdig = aux_nrsequen
               crabneg.dtiniest = par_dtmvtolt
               crabneg.cdoperad = par_cdoperad
               crabneg.cdtctatu = crabass.cdtipcta
               crabneg.cdhisest = 0
               crabneg.cdobserv = 0
               crabneg.cdtctant = 0
               crabneg.dtfimest = ?
               crabneg.nrdctabb = 0
               crabneg.qtdiaest = 0
               crabneg.vlestour = 0
               crabneg.vllimcre = 0
               crabneg.cdbanchq = 0
               crabneg.cdagechq = 0
               crabneg.nrctachq = 0.

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO Desvincula, LEAVE Desvincula.

        DELETE crabtrf NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO Desvincula, LEAVE Desvincula.
            END.

        ASSIGN par_msgretor = "Operacao efetuada com sucesso! " + 
                              "Nova matricula: "                + 
                              TRIM(STRING(crabadm.nrmatric,"zzz,zz9")).

        ASSIGN aux_returnvl = "OK".

        LEAVE Desvincula.
     END.

     RELEASE crabmat.
     RELEASE crabadm.
     RELEASE crabtrf.
     RELEASE crabneg.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

END PROCEDURE. /* Desvincula */

/* ------------------------------------------------------------------------ */
/*                REALIZA A BUSCA DO ID DAS TABELAS PRINCPAIS               */
/* ------------------------------------------------------------------------ */
PROCEDURE Id_Registro PRIVATE :

    DEF  INPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_rowidttl AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_rowidjur AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    IdRegistro: DO ON ERROR UNDO IdRegistro, LEAVE IdRegistro:

        IF  par_cddopcao = "I" THEN
            DO:
               ASSIGN aux_returnvl = "OK".
               LEAVE IdRegistro.
            END.
        ELSE
            DO:
               IF  par_rowidass = ? THEN
                   DO:
                      ASSIGN par_dscritic = "Para a operacao [" + par_cddopcao
                                            + "] o 'rowid' da tabela deve ser "
                                            + "informado.".
                      LEAVE IdRegistro.
                   END.
            END.

        /* Dados do Associado */
        ContadorAss: DO aux_contador = 1 TO 10:

            FIND crapass WHERE ROWID(crapass) = par_rowidass
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapass THEN
                DO:
                   IF  LOCKED(crapass) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crapass
                                     WHERE ROWID(crapass) = par_rowidass
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crapass THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapass),"banco","crapass").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorAss.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorAss.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 9.
                          LEAVE ContadorAss.
                       END.
                END.
            ELSE
                LEAVE ContadorAss.
        END. /* ContadorAss */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO IdRegistro, LEAVE IdRegistro.

        /* determina o tipo de pessoa da conta */
        CASE crapass.inpessoa:
            WHEN 1 THEN DO:
                /* Dados do Titular - Pessoa Fisica */
                ContadorTtl: DO aux_contador = 1 TO 10:

                    FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapttl THEN
                        DO:
                           IF  LOCKED(crapttl) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        FIND crapttl WHERE
                                        crapttl.cdcooper = crapass.cdcooper AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1
                                        NO-LOCK NO-ERROR.

                                        IF  AVAILABLE crapttl THEN
                                            /* mostra us. que esta travando */
                                            ASSIGN par_dscritic = LockTabela(
                                                RECID(crapttl),"banco",
                                                "crapttl").
                                        ELSE
                                            ASSIGN par_cdcritic = 341.

                                        LEAVE ContadorTtl.
                                     END.
                                  
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorTtl.
                               END.
                           ELSE
                               DO:
                                  ASSIGN par_cdcritic = 821.
                                  LEAVE ContadorTtl.
                               END.
                        END.
                    ELSE
                        DO:
                           ASSIGN par_rowidttl = ROWID(crapttl).
                           LEAVE ContadorTtl.
                        END.
                END. /* ContadorTtl */

                IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                    UNDO IdRegistro, LEAVE IdRegistro.
            END.
            WHEN 2 OR WHEN 3 THEN DO:
                /* Dados do Titular - Pessoa Juridica */
                ContadorJur: DO aux_contador = 1 TO 10:

                    FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND
                                       crapjur.nrdconta = crapass.nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapjur THEN
                        DO:
                           IF  LOCKED(crapjur) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        FIND crapjur WHERE 
                                        crapjur.cdcooper = crapass.cdcooper AND
                                        crapjur.nrdconta = crapass.nrdconta
                                        NO-LOCK NO-ERROR.

                                        IF  AVAILABLE crapjur THEN
                                            /* mostra usar.que esta travando */
                                            ASSIGN par_dscritic = LockTabela(
                                                RECID(crapjur),"banco",
                                                "crapjur").
                                        ELSE
                                            ASSIGN par_cdcritic = 341.

                                        LEAVE ContadorJur.
                                     END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorJur.
                               END.
                           ELSE
                               DO:
                                  ASSIGN par_dscritic = "Pessoa Juridica" +
                                                        " nao encontrada.".
                                  LEAVE ContadorJur.
                               END.
                        END.
                    ELSE
                        DO:
                           ASSIGN par_rowidjur = ROWID(crapjur).
                           LEAVE ContadorJur.
                        END.
                END. /* ContadorJur */

                IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                    UNDO IdRegistro, LEAVE IdRegistro.
            END.
            OTHERWISE DO:
                ASSIGN par_dscritic = "Tipo da pessoa deve ser [1]=Fisica," +
                                      " [2]=Juridica ou [3]=Administrativa.".
                LEAVE IdRegistro.
            END. 
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE IdRegistro.
     END.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

END PROCEDURE. /* Id_Registro */

/* ------------------------------------------------------------------------ */
/*             INCLUI OS DADOS ORIGINADOS NA OPCAO [I]=INCLUSAO             */
/* ------------------------------------------------------------------------ */
PROCEDURE Inclui PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmttlrfb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inconrfb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_hrinicad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmsocial AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctsal AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_rowidttl AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_rowidjur AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdconta AS INT     INIT 0                          NO-UNDO.
    DEF VAR aux_nrcalcul AS DEC     FORMAT ">>>>>>>>>>>>>9"         NO-UNDO.
    DEF VAR aux_vldigito AS INT     INIT 0                          NO-UNDO.
    DEF VAR aux_posicao  AS INT     INIT 0                          NO-UNDO.
    DEF VAR aux_vlrdpeso AS INT     INIT 9                          NO-UNDO.
    DEF VAR aux_vlrdcalc AS INT     INIT 0                          NO-UNDO.
    DEF VAR aux_vldresto AS INT     INIT 06                         NO-UNDO.
    DEF VAR aux_vlnumero AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtadmiss AS DATE                                    NO-UNDO.
    DEF VAR aux_tpendass AS INTE                                    NO-UNDO.
    DEF VAR h-b1crapenc  AS HANDLE                                  NO-UNDO.

    DEF VAR aux_cdpartar AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtpcta AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabenc FOR crapenc.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Inclui: DO TRANSACTION
        ON ERROR  UNDO Inclui, LEAVE Inclui
        ON QUIT   UNDO Inclui, LEAVE Inclui
        ON STOP   UNDO Inclui, LEAVE Inclui
        ON ENDKEY UNDO Inclui, LEAVE Inclui:
        
        
        ContadorAss: DO aux_contador = 1 TO 10:

            FIND crabass WHERE ROWID(crabass) = par_rowidass
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabass THEN
                DO:
                   IF  LOCKED crabass THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabass 
                                     WHERE ROWID(crabass) = par_rowidass
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabass THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabass),"banco","crapass").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
                                 LEAVE ContadorAss.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorAss.
                       END.

                   FOR FIRST crapcop FIELDS(nrdocnpj)
                                     WHERE crapcop.cdcooper = par_cdcooper 
                                     NO-LOCK:
                   END.
    
                   IF  NOT AVAILABLE crapcop THEN
                       DO:
                          ASSIGN par_cdcritic = 651.
                          LEAVE ContadorAss.
                       END.
    
                   IF  crapcop.nrdocnpj = par_nrcpfcgc THEN
                       ASSIGN par_inpessoa = 3.

                   /* associado foi criado simultaneamente */
                   IF  CAN-FIND(crabass WHERE 
                                crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta) THEN
                       DO:
                          ASSIGN par_cdcritic = 46.
                          PAUSE 2 NO-MESSAGE.
                          LEAVE ContadorAss.
                       END.
    
                   /* Elimina registro da tabela de Nao Cooperados */
                   FOR EACH crapncp WHERE 
                            crapncp.nrdoccpf = par_nrcpfcgc EXCLUSIVE-LOCK:
                       DELETE crapncp.
                   END.
                   
                    /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                    IF par_cdagenci = 0 THEN
                      ASSIGN par_cdagenci = glb_cdagenci.
                    /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */


                   IF par_inpessoa = 1 THEN
                      DO:
                        IF par_flgctsal = YES THEN
                          aux_cdpartar = 71.  /* TIPO DE CONTA INICIAL PF SALARIO */
                        ELSE
                          aux_cdpartar = 54.  /* TIPO DE CONTA INICIAL PF */
                      END.
                   ELSE
                       aux_cdpartar = 55.  /* TIPO DE CONTA INICIAL PJ */
                       
                   FIND crappco WHERE crappco.cdcooper = par_cdcooper AND
                                      crappco.cdpartar = aux_cdpartar NO-ERROR NO-WAIT.
                   
                   IF NOT AVAILABLE crappco THEN
                       DO:
                           ASSIGN par_dscritic = "Parametro de tipo de conta inicial nao cadastrado.".
                           LEAVE ContadorAss.
                       END.
                              
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   
                   RUN STORED-PROCEDURE pc_valida_tipo_conta_coop
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,          /* cooperativa */
                                                        INPUT par_inpessoa,          /* tipo de pessoa */
                                                        INPUT INT(crappco.dsconteu), /* tipo de conta */
                                                       OUTPUT "",                    /* Descricao do tipo de conta */
                                                       OUTPUT "",                    /* Flag Erro */
                                                       OUTPUT "").                   /* Descrição da crítica */
                   
                   CLOSE STORED-PROC pc_valida_tipo_conta_coop
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                   
                   ASSIGN aux_flgtpcta = ""
                          aux_des_erro = ""
                          aux_dscritic = ""
                          aux_flgtpcta = pc_valida_tipo_conta_coop.pr_flgtpcta 
                                         WHEN pc_valida_tipo_conta_coop.pr_flgtpcta <> ?
                          aux_des_erro = pc_valida_tipo_conta_coop.pr_des_erro 
                                         WHEN pc_valida_tipo_conta_coop.pr_des_erro <> ?
                          aux_dscritic = pc_valida_tipo_conta_coop.pr_dscritic
                                         WHEN pc_valida_tipo_conta_coop.pr_dscritic <> ?.
                   
                   IF aux_des_erro = "NOK"  THEN
                       DO:
                           ASSIGN par_dscritic = aux_dscritic.
                           LEAVE ContadorAss.
                       END.
                   
                   IF aux_flgtpcta = "0" THEN
                       DO:
                           ASSIGN par_dscritic = "Tipo de Conta do parametro, nao cadastrado para cooperativa.".
                           LEAVE ContadorAss.
                       END.
                    
                   CREATE crabass.
                   ASSIGN 
                       crabass.cdcooper = par_cdcooper
                       crabass.nrdconta = par_nrdconta
                       crabass.dtmvtolt = par_dtmvtolt
                       crabass.inpessoa = par_inpessoa
                       crabass.nrcpfcgc = par_nrcpfcgc
                       crabass.inmatric = 1
                       crabass.tpavsdeb = 0
                       crabass.qtfoltal = 10 
                       crabass.nmttlrfb = SUBSTR(par_nmttlrfb,1,200) 
                       crabass.inconrfb = par_inconrfb 
                       crabass.hrinicad = par_hrinicad 
                       crabass.cdsitdct = 1  /* Em uso */
                       crabass.cdtipcta = INT(crappco.dsconteu)  /* Normal Convenio */
                       /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                       crabass.cdopeori = par_cdoperad
                       crabass.cdageori = par_cdagenci
                       crabass.dtinsori = TODAY
                       /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                       crabass.cdbcochq = 85
                       crabass.cdcatego = 1 NO-ERROR.  

                       /* Para esta tela deve gravar essas informaçoes como padrao */
                       IF par_nmdatela = 'CADMAT' THEN
                       DO:
                          ASSIGN crabass.cdsecext = 999 NO-ERROR.
                       END.
                       

                   IF  ERROR-STATUS:ERROR THEN 
                       DO:
                          ASSIGN par_dscritic = {&GET-MSG}.
                          LEAVE ContadorAss.
                       END.

                   VALIDATE crabass.
                   
                   /* Historico */
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   
                   RUN STORED-PROCEDURE pc_grava_dados_hist 
                       aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT "CRAPASS"                /* pr_nmtabela */
                                        ,INPUT "CDTIPCTA"               /* pr_nmdcampo */
                                        ,INPUT par_cdcooper             /* pr_cdcooper */  
                                        ,INPUT par_nrdconta             /* pr_nrdconta */  
                                        ,INPUT 0                        /* pr_inpessoa */  
                                        ,INPUT 0                        /* pr_idseqttl */  
                                        ,INPUT 0                        /* pr_cdtipcta */  
                                        ,INPUT 0                        /* pr_cdsituac */  
                                        ,INPUT 0                        /* pr_cdprodut */  
                                        ,INPUT 1                        /* pr_tpoperac */  
                                        ,INPUT ?                        /* pr_dsvalant */
                                        ,INPUT STRING(crabass.cdtipcta) /* pr_dsvalnov */  
                                        ,INPUT par_cdoperad             /* pr_cdoperad */  
                                       ,OUTPUT "").
                   
                   CLOSE STORED-PROC pc_grava_dados_hist 
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                   
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                   
                   ASSIGN aux_dscritic = ""                         
                          aux_dscritic = pc_grava_dados_hist.pr_dscritic 
                                         WHEN pc_grava_dados_hist.pr_dscritic <> ?.
                   
                   IF  aux_dscritic <> "" THEN
                       LEAVE ContadorAss.
                   
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   
                   RUN STORED-PROCEDURE pc_grava_dados_hist 
                       aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT "CRAPASS"                /* pr_nmtabela */
                                        ,INPUT "CDSITDCT"               /* pr_nmdcampo */
                                        ,INPUT par_cdcooper             /* pr_cdcooper */  
                                        ,INPUT par_nrdconta             /* pr_nrdconta */  
                                        ,INPUT 0                        /* pr_inpessoa */  
                                        ,INPUT 0                        /* pr_idseqttl */  
                                        ,INPUT 0                        /* pr_cdtipcta */  
                                        ,INPUT 0                        /* pr_cdsituac */  
                                        ,INPUT 0                        /* pr_cdprodut */  
                                        ,INPUT 1                        /* pr_tpoperac */  
                                        ,INPUT ?                        /* pr_dsvalant */
                                        ,INPUT STRING(crabass.cdsitdct) /* pr_dsvalnov */  
                                        ,INPUT par_cdoperad             /* pr_cdoperad */  
                                       ,OUTPUT "").
                   
                   CLOSE STORED-PROC pc_grava_dados_hist 
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                   
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                   
                   ASSIGN aux_dscritic = ""                         
                          aux_dscritic = pc_grava_dados_hist.pr_dscritic 
                                         WHEN pc_grava_dados_hist.pr_dscritic <> ?.
                   
                   IF  aux_dscritic <> "" THEN
                       LEAVE ContadorAss.
                   
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   
                   RUN STORED-PROCEDURE pc_grava_dados_hist 
                       aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT "CRAPASS"                /* pr_nmtabela */
                                        ,INPUT "CDCATEGO"               /* pr_nmdcampo */
                                        ,INPUT par_cdcooper             /* pr_cdcooper */  
                                        ,INPUT par_nrdconta             /* pr_nrdconta */  
                                        ,INPUT 0                        /* pr_inpessoa */  
                                        ,INPUT 0                        /* pr_idseqttl */  
                                        ,INPUT 0                        /* pr_cdtipcta */  
                                        ,INPUT 0                        /* pr_cdsituac */  
                                        ,INPUT 0                        /* pr_cdprodut */  
                                        ,INPUT 1                        /* pr_tpoperac */  
                                        ,INPUT ?                        /* pr_dsvalant */
                                        ,INPUT STRING(crabass.cdcatego) /* pr_dsvalnov */  
                                        ,INPUT par_cdoperad             /* pr_cdoperad */  
                                       ,OUTPUT "").
                   
                   CLOSE STORED-PROC pc_grava_dados_hist 
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                   
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                   
                   ASSIGN aux_dscritic = ""                         
                          aux_dscritic = pc_grava_dados_hist.pr_dscritic 
                                         WHEN pc_grava_dados_hist.pr_dscritic <> ?.
                   
                   IF  aux_dscritic <> "" THEN
                       LEAVE ContadorAss.
                   
                   LEAVE ContadorAss.
                END.
            ELSE
                DO:
                   ASSIGN par_cdcritic = 46.
                   LEAVE ContadorAss.
                END.
        END. /* ContadorAss */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO Inclui, LEAVE Inclui.

        ASSIGN par_rowidass = ROWID(crabass).

        /*** INICIO - Cria Conta de Investimento ***/
        ASSIGN 
            aux_nrdconta = crabass.nrdconta
            aux_nrcalcul = 600000000 + aux_nrdconta
            aux_vlrdcalc = 0 
            aux_vlrdpeso = 9.

        DO aux_posicao = (LENGTH(STRING(aux_nrcalcul)) - 1) TO 1 BY -1:
            ASSIGN 
                aux_vlrdcalc = aux_vlrdcalc + (INT(SUBSTR(STRING(aux_nrcalcul),
                                                        aux_posicao,1)) * 
                                                aux_vlrdpeso)
            aux_vlrdpeso = aux_vlrdpeso - 1.

           IF  aux_vlrdpeso = 1 THEN
               ASSIGN aux_vlrdpeso = 9.
        END.  /*  Fim do DO .. TO  */

        ASSIGN aux_vldresto = aux_vlrdcalc MODULO 11.

        IF  aux_vldresto > 9  THEN
            ASSIGN aux_vldigito = 0.
        ELSE
            ASSIGN aux_vldigito = aux_vldresto.

        ASSIGN 
            aux_vlnumero = STRING(aux_nrcalcul,"999999999").
            aux_vlnumero = SUBSTR(aux_vlnumero,1,8) + STRING(aux_vldigito,"9").
            aux_nrcalcul = INTE(aux_vlnumero).

        ASSIGN crabass.nrctainv = aux_nrcalcul.
        /*** FINAL - Cria Conta de Investimento ***/

        aux_dtadmiss = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4) 
                       - DAY(DATE(MONTH(par_dtmvtolt),28,
                                  YEAR(par_dtmvtolt)) + 4)).
        
        Admissao: DO WHILE TRUE: /* Verifica se a data e' valida p/o sistema */

           IF  LOOKUP(STRING(WEEKDAY(aux_dtadmiss)),"1,7") <> 0   THEN
               DO:
                   ASSIGN aux_dtadmiss = aux_dtadmiss - 1.
                   NEXT Admissao.
               END.
           ELSE
               DO:
                  IF  CAN-FIND(crapfer WHERE 
                               crapfer.cdcooper = par_cdcooper AND
                               crapfer.dtferiad = aux_dtadmiss) THEN
                      DO:
                         ASSIGN aux_dtadmiss = aux_dtadmiss - 1.
                         NEXT Admissao.
                      END.
                  ELSE
                      DO:
                         ASSIGN crabass.dtadmiss = IF par_inpessoa = 3
                                                   THEN crabass.dtnasctl
                                                   ELSE aux_dtadmiss.        
                         LEAVE Admissao.
                      END.
               END.
        END.

        CASE crabass.inpessoa:
            WHEN 1 THEN DO:
                ASSIGN aux_tpendass = 10.

                /* PESSOA FISICA */
                RUN Inclui_Fis 
                    ( INPUT par_cdcooper, 
                      INPUT par_nrdconta,
                      INPUT par_nrcpfcgc,
                      INPUT par_inhabmen,
                      INPUT par_dthabmen,
					  INPUT par_nmsocial,
					  INPUT par_cdempres,
                     OUTPUT par_rowidttl,
                     OUTPUT crabass.dsproftl,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN 
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Inclui, LEAVE Inclui.
                    END.


                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Inclui, LEAVE Inclui.

            END.
            OTHERWISE DO:
                ASSIGN aux_tpendass = 9.

                /* PESSOA JURIDICA */
                RUN Inclui_Jur 
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_nrcpfcgc,
                     OUTPUT par_rowidjur,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN 
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       UNDO Inclui, LEAVE Inclui.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Inclui, LEAVE Inclui.
            END.
        END CASE.

        /* grava registros cadastrais/auxiliares */
        RUN Inclui_Cad
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_cdoperad,
              INPUT par_inpessoa,
              INPUT par_dtmvtolt,
              INPUT par_dtmvtoan,
              INPUT crabass.cdtipcta,
              INPUT crabass.dtadmiss,
              INPUT-OUTPUT crabass.nrmatric,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN 
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Inclui, LEAVE Inclui.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Inclui, LEAVE Inclui.

        /* Atualiazacao do Endereco */
        RUN Atualiza_End
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT 1, /* idseqttl */
              INPUT par_idorigem,
              INPUT par_nmdatela,
              INPUT par_cdoperad,
              INPUT "I",
              INPUT par_dtmvtolt,
              INPUT crabass.inpessoa,
              INPUT UPPER(par_dsendere),
              INPUT par_nrendere,
              INPUT par_nrcepend,
              INPUT UPPER(par_complend),
              INPUT UPPER(par_nmbairro),
              INPUT UPPER(par_nmcidade),
              INPUT UPPER(par_cdufende),			  		
              INPUT par_nrcxapst,
              INPUT par_idorigee,
             OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN 
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               UNDO Inclui, LEAVE Inclui.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Inclui, LEAVE Inclui.

        ASSIGN par_msgretor = "A conta utilizada foi " + 
                              TRIM(STRING(crabass.nrdconta,"zzzz,zzz,9")).

        IF  crabass.nrmatric <> 0 THEN
            ASSIGN par_msgretor = par_msgretor + 
                                  " e a matricula " +
                                  TRIM(STRING(crabass.nrmatric,"zzz,zz9")) + ".".

        ASSIGN aux_returnvl = "OK".

        LEAVE Inclui.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Inclui */

/* ------------------------------------------------------------------------ */
/*       OPERACAO DE INCLUSAO [I] - LOGICA DO {cadastra_dados_matrici.i}    */
/* ------------------------------------------------------------------------ */
PROCEDURE Inclui_Cad PRIVATE :

    DEF        INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF        INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF        INPUT PARAM par_cdoperad AS CHAR                     NO-UNDO.
    DEF        INPUT PARAM par_inpessoa AS INTE                     NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt AS DATE                     NO-UNDO.
    DEF        INPUT PARAM par_dtmvtoan AS DATE                     NO-UNDO.
    DEF        INPUT PARAM par_cdtipcta AS INTE                     NO-UNDO.
    DEF        INPUT PARAM par_dtadmiss AS DATE                     NO-UNDO.
                                                                  
    DEF INPUT-OUTPUT PARAM par_nrmatric AS INTE                     NO-UNDO.
                                                                  
    DEF       OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF       OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_senhatmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cddsenha AS CHAR                                    NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.
    DEF VAR aux_nrmatric AS INTE                                    NO-UNDO.
    DEF VAR aux_qtassmes AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    IncluiCad: DO TRANSACTION
        ON ERROR  UNDO IncluiCad, LEAVE IncluiCad
        ON QUIT   UNDO IncluiCad, LEAVE IncluiCad
        ON STOP   UNDO IncluiCad, LEAVE IncluiCad
        ON ENDKEY UNDO IncluiCad, LEAVE IncluiCad:



        /* Realiza criacao de tabelas auxiliares */
        ContadorMat: DO aux_contador = 1 TO 10:

            FIND FIRST crapmat WHERE crapmat.cdcooper = par_cdcooper 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapmat THEN
                DO:
                   IF  LOCKED crapmat THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                  FIND FIRST crapmat 
                                      WHERE crapmat.cdcooper = par_cdcooper 
                                      NO-LOCK NO-ERROR .
                                  IF  AVAILABLE crapmat THEN
                                      ASSIGN par_dscritic = LockTabela(
                                          RECID(crapmat),"banco","crapmat").   
                                  ELSE 
                                      ASSIGN par_cdcritic = 73.

                                 LEAVE ContadorMat.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorMat.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 71.
                          LEAVE ContadorMat.
                       END.
                END.
            ELSE
                LEAVE ContadorMat.
        END. /* ContadorMat */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO IncluiCad, LEAVE IncluiCad.

        Senha: DO WHILE TRUE:
        
            ASSIGN aux_cddsenha = "".
        
            DO aux_contador = 1 TO 6:
                ASSIGN 
                    aux_senhatmp = RANDOM(0,9)
                    aux_cddsenha = aux_cddsenha + STRING(aux_senhatmp,"9").
            END.
        
            IF aux_cddsenha <> "000000"  THEN
               LEAVE Senha.
        END.

        ASSIGN par_dscritic = "".
        
        
        IF  par_inpessoa <> 3 THEN
            DO:        
               /* Buscar a proxima sequencia da matric */
               RUN STORED-PROCEDURE pc_sequence_progress
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                   ,INPUT "NRMATRIC"
                                                   ,INPUT STRING(par_cdcooper)
                                                   ,INPUT "N"
                                                   ,"").
      
               CLOSE STORED-PROC pc_sequence_progress
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                        
               ASSIGN aux_nrmatric = INTE(pc_sequence_progress.pr_sequence)
                                     WHEN pc_sequence_progress.pr_sequence <> ?.

               /* Buscar a proxima sequencia qtassmes */
               RUN STORED-PROCEDURE pc_sequence_progress
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                   ,INPUT "QTASSMES"
                                                   ,INPUT STRING(par_cdcooper)
                                                   ,INPUT "N"
                                                   ,"").
      
               CLOSE STORED-PROC pc_sequence_progress
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                        
               ASSIGN aux_qtassmes = INTE(pc_sequence_progress.pr_sequence)
                                     WHEN pc_sequence_progress.pr_sequence <> ?.

               ASSIGN crapmat.nrmatric = aux_nrmatric
                      crapmat.qtassmes = aux_qtassmes
                      par_nrmatric     = crapmat.nrmatric.

              
               ContadorAdm: DO aux_contador = 1 TO 10:


                   FIND crapadm WHERE crapadm.cdcooper = par_cdcooper AND
                                      crapadm.nrmatric = par_nrmatric
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF  NOT AVAILABLE crapadm THEN
                       DO:
                          IF  LOCKED crapadm THEN
                              DO:
                                 IF  aux_contador = 10 THEN
                                     DO:
                                        FIND crapadm 
                                          WHERE crapadm.cdcooper = par_cdcooper
                                            AND crapadm.nrmatric = par_nrmatric
                                          NO-LOCK NO-ERROR.
    
                                        IF  AVAILABLE crapadm THEN
                                            /* usuario que esta travando */
                                            ASSIGN par_dscritic = LockTabela(
                                                RECID(crapadm),"banco",
                                                "crapadm").
                                        ELSE 
                                            ASSIGN par_cdcritic = 341.
                                        LEAVE ContadorAdm.
                                     END.

                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorAdm.
                              END.
                         
                                        CREATE crapadm.
                          ASSIGN 
                              crapadm.nrmatric = par_nrmatric
                              crapadm.nrdconta = par_nrdconta
                              crapadm.cdcooper = par_cdcooper
                              crapadm.dtmvtolt = par_dtmvtolt NO-ERROR.

                          IF  ERROR-STATUS:ERROR THEN 
                              ASSIGN par_dscritic = {&GET-MSG}.
                            
                          VALIDATE crapadm.

                       END.
                   
                                 LEAVE ContadorAdm.
               END. /* ContadorAdm */

              IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
                   UNDO IncluiCad, LEAVE IncluiCad.
            END. /* par_inpessoa <> 3  */

        ContadorSld: DO aux_contador = 1 TO 10:

            FIND crapsld WHERE crapsld.cdcooper = par_cdcooper AND
                               crapsld.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapsld THEN
                DO:
                   IF  LOCKED crapsld THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crapsld 
                                     WHERE crapsld.cdcooper = par_cdcooper
                                       AND crapsld.nrdconta = par_nrdconta
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crapsld THEN
                                     /* usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapsld),"banco","crapsld").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
                                 LEAVE ContadorSld.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorSld.
                       END.

                   CREATE crapsld.
                   ASSIGN 
                       crapsld.nrdconta = par_nrdconta
                       crapsld.cdcooper = par_cdcooper
                       crapsld.dtrefere = par_dtmvtoan 
                       crapsld.dtsdanes = par_dtmvtolt - 1 NO-ERROR.

                   IF  ERROR-STATUS:ERROR THEN 
                       ASSIGN par_dscritic = {&GET-MSG}.

                   VALIDATE crapsld.

                END.
            LEAVE ContadorSld.
        END. /* ContadorSld */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO IncluiCad, LEAVE IncluiCad.

        ContadorCot: DO aux_contador = 1 TO 10:

            FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                               crapcot.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcot THEN
                DO:
                   IF  LOCKED crapcot THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crapcot 
                                     WHERE crapcot.cdcooper = par_cdcooper
                                       AND crapcot.nrdconta = par_nrdconta
                                     NO-LOCK NO-ERROR.
    
                                 IF  AVAILABLE crapcot THEN
                                     /* usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapcot),"banco","crapcot").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
                                 LEAVE ContadorCot.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorCot.
                       END.

                   CREATE crapcot.
                   ASSIGN
                       crapcot.nrdconta = par_nrdconta
                       crapcot.cdcooper = par_cdcooper NO-ERROR.

                   IF  ERROR-STATUS:ERROR THEN 
                       ASSIGN par_dscritic = {&GET-MSG}.

                   VALIDATE crapcot.

                END.
            LEAVE ContadorCot.
        END. /* ContadorCot */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO IncluiCad, LEAVE IncluiCad.

        ContadorSda: DO aux_contador = 1 TO 10:

            FIND crapsda WHERE crapsda.cdcooper = par_cdcooper AND
                               crapsda.nrdconta = par_nrdconta AND
                               crapsda.dtmvtolt = par_dtmvtoan
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapsda THEN
                DO:
                   IF  LOCKED crapsda THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crapsda 
                                     WHERE crapsda.nrdconta = par_nrdconta 
                                       AND crapsda.cdcooper = par_cdcooper 
                                       AND crapsda.dtmvtolt = par_dtmvtoan
                                     NO-LOCK NO-ERROR.
    
                                 IF  AVAILABLE crapsda THEN
                                     /* usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapsda),"banco","crapsda").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.
                                 
                                 LEAVE ContadorSda.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorSda.
                       END.

                   CREATE crapsda.
                   ASSIGN
                       crapsda.nrdconta = par_nrdconta
                       crapsda.cdcooper = par_cdcooper
                       crapsda.dtmvtolt = par_dtmvtoan NO-ERROR.

                   IF  ERROR-STATUS:ERROR THEN 
                       ASSIGN par_dscritic = {&GET-MSG}.

                   VALIDATE crapsda.

                END.
            LEAVE ContadorSda.
        END. /* ContadorSda */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO IncluiCad, LEAVE IncluiCad.

        ContadorNeg: DO aux_contador = 1 TO 10:

            FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                               crapneg.nrdconta = par_nrdconta AND
                               crapneg.nrseqdig = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapneg THEN
                DO:
                   IF  LOCKED crapneg THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crapneg 
                                     WHERE crapneg.cdcooper = par_cdcooper 
                                       AND crapneg.nrdconta = par_nrdconta 
                                       AND crapneg.nrseqdig = 1
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crapneg THEN
                                     /* usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapneg),"banco","crapneg").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorNeg.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorNeg.
                       END.

                   RUN STORED-PROCEDURE pc_sequence_progress
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
                                                       ,INPUT "NRSEQDIG"
                                                       ,INPUT STRING(par_cdcooper) + ";" + STRING(par_nrdconta)
                                                       ,INPUT "N"
                                                       ,"").
                   
                   CLOSE STORED-PROC pc_sequence_progress
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                             
                   ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                                         WHEN pc_sequence_progress.pr_sequence <> ?.

                   CREATE crapneg.
                   ASSIGN 
                       crapneg.nrdconta = par_nrdconta
                       crapneg.cdcooper = par_cdcooper
                       crapneg.cdoperad = par_cdoperad
                       crapneg.cdtctatu = par_cdtipcta
                       crapneg.dtiniest = par_dtmvtolt
                       crapneg.cdhisest = 0
                       crapneg.cdobserv = 0
                       crapneg.cdtctant = 0
                       crapneg.dtfimest = ?
                       crapneg.nrdctabb = 0
                       crapneg.nrseqdig = aux_nrseqdig
                       crapneg.qtdiaest = 0
                       crapneg.vlestour = 0
                       crapneg.vllimcre = 0 NO-ERROR.

                   IF  ERROR-STATUS:ERROR THEN 
                       ASSIGN par_dscritic = {&GET-MSG}.

                   VALIDATE crapneg.

                END.
            LEAVE ContadorNeg.
        END. /* ContadorNeg */

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO IncluiCad, LEAVE IncluiCad.        

        ASSIGN aux_returnvl = "OK".

        LEAVE IncluiCad.
    END.

    RELEASE crapmat.
    RELEASE crapadm.
    RELEASE crapsld.
    RELEASE crapcot.
    RELEASE crapsda.
    RELEASE crapneg.
    
    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Inclui_Cad */

/* ------------------------------------------------------------------------ */
/*      INCLUI OS DADOS ORIGINADOS NA OPCAO [I]=INCLUSAO PESSOA FISICA      */
/* ------------------------------------------------------------------------ */
PROCEDURE Inclui_Fis PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_nmsocial AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_rowidttl AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    DEF BUFFER crabttl FOR crapttl.

    IncluiFis: DO TRANSACTION
        ON ERROR  UNDO IncluiFis, LEAVE IncluiFis
        ON QUIT   UNDO IncluiFis, LEAVE IncluiFis
        ON STOP   UNDO IncluiFis, LEAVE IncluiFis
        ON ENDKEY UNDO IncluiFis, LEAVE IncluiFis:

        ContadorFis: DO aux_contador = 1 TO 10:

            FIND crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                               crabttl.nrdconta = par_nrdconta AND
                               crabttl.idseqttl = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabttl THEN
                DO:
                   IF  LOCKED crabttl THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabttl 
                                     WHERE crabttl.cdcooper = par_cdcooper 
                                       AND crabttl.nrdconta = par_nrdconta 
                                       AND crabttl.idseqttl = 1
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crabttl THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabttl),"banco","crapttl").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorFis.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorFis.
                       END.
                   ELSE
                       DO:
                          CREATE crabttl.
                          
                          
                          /* Chamar rotina para retornar dados de pessoa para complementar cadastro do titular */
                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                          RUN STORED-PROCEDURE pc_busca_crapttl_compl 
                                aux_handproc = PROC-HANDLE NO-ERROR
                                                   (INPUT par_cdcooper  /* pa_cdcooper*/
												   ,INPUT par_cdempres  /* pr_cdempres */
												   ,INPUT par_nrcpfcgc  /* pr_nrcpfcgc  */ 
                                                   ,OUTPUT 0   /* pr_cdnatopc   */
                                                   ,OUTPUT 0   /* pr_cdocpttl   */   
                                                   ,OUTPUT 0   /* pr_tpcttrab   */   
                                                   ,OUTPUT ""  /* pr_nmextemp   */   
                                                   ,OUTPUT 0   /* pr_nrcpfemp   */   
                                                   ,OUTPUT ?   /* pr_dtadmemp   */
                                                   ,OUTPUT ""  /* pr_dsproftl   */
                                                   ,OUTPUT 0   /* pr_cdnvlcgo   */
                                                   ,OUTPUT 0   /* pr_vlsalari   */
                                                   ,OUTPUT 0   /* pr_cdturnos   */
                                                   ,OUTPUT ""  /* pr_dsjusren   */
                                                   ,OUTPUT ?   /* pr_dtatutel   */
                                                   ,OUTPUT 0   /* pr_cdgraupr   */
												                           ,OUTPUT 0   /* pr_cdfrmttl   */
                                                   ,OUTPUT 0   /* pr_tpdrendi##1*/
                                                   ,OUTPUT 0   /* pr_vldrendi##1*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##2*/
                                                   ,OUTPUT 0   /* pr_vldrendi##2*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##3*/
                                                   ,OUTPUT 0   /* pr_vldrendi##3*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##4*/
                                                   ,OUTPUT 0   /* pr_vldrendi##4*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##5*/
                                                   ,OUTPUT 0   /* pr_vldrendi##5*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##6*/
                                                   ,OUTPUT 0   /* pr_vldrendi##6*/
                                                   ,OUTPUT ""  /* pr_nmpaittl   */
                                                   ,OUTPUT ""  /* pr_nmmaettl   */
                                                   ,OUTPUT ""). /* pr_dscritic   */

                            CLOSE STORED-PROC pc_busca_crapttl_compl 
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            ASSIGN crabttl.cdnatopc = pc_busca_crapttl_compl.pr_cdnatopc 
                                                      WHEN pc_busca_crapttl_compl.pr_cdnatopc <> ?
                                   crabttl.cdocpttl = pc_busca_crapttl_compl.pr_cdocpttl 
                                                      WHEN pc_busca_crapttl_compl.pr_cdocpttl <> ? 
                                   crabttl.tpcttrab = pc_busca_crapttl_compl.pr_tpcttrab 
                                                      WHEN pc_busca_crapttl_compl.pr_tpcttrab <> ? 
                                   crabttl.nmextemp = pc_busca_crapttl_compl.pr_nmextemp 
                                                      WHEN pc_busca_crapttl_compl.pr_nmextemp <> ? 
                                   crabttl.nrcpfemp = pc_busca_crapttl_compl.pr_nrcpfemp 
                                                      WHEN pc_busca_crapttl_compl.pr_nrcpfemp <> ? 
                                   crabttl.dtadmemp = pc_busca_crapttl_compl.pr_dtadmemp 
                                                      WHEN pc_busca_crapttl_compl.pr_dtadmemp <> ? 
                                   crabttl.dsproftl = pc_busca_crapttl_compl.pr_dsproftl 
                                                      WHEN pc_busca_crapttl_compl.pr_dsproftl <> ? 
                                   /* popular também para garantir que sera mantida a inf.
                                      visto que a mesma é replicadas nas duas tabelas e vem por parametro zerado */                   
                                   par_dsproftl= crabttl.dsproftl
                                   crabttl.cdnvlcgo = pc_busca_crapttl_compl.pr_cdnvlcgo 
                                                      WHEN pc_busca_crapttl_compl.pr_cdnvlcgo <> ? 
                                   crabttl.vlsalari = pc_busca_crapttl_compl.pr_vlsalari 
                                                      WHEN pc_busca_crapttl_compl.pr_vlsalari <> ? 
                                   crabttl.cdturnos = pc_busca_crapttl_compl.pr_cdturnos 
                                                      WHEN pc_busca_crapttl_compl.pr_cdturnos <> ? 
                                   crabttl.dsjusren = pc_busca_crapttl_compl.pr_dsjusren 
                                                      WHEN pc_busca_crapttl_compl.pr_dsjusren <> ? 
                                   crabttl.dtatutel = pc_busca_crapttl_compl.pr_dtatutel 
                                                      WHEN pc_busca_crapttl_compl.pr_dtatutel <> ?
                                   crabttl.grescola = pc_busca_crapttl_compl.pr_cdgraupr 
                                                      WHEN pc_busca_crapttl_compl.pr_cdgraupr <> ? 
                                   crabttl.cdfrmttl = pc_busca_crapttl_compl.pr_cdfrmttl 
                                                      WHEN pc_busca_crapttl_compl.pr_cdfrmttl <> ?
                                   crabttl.nmpaittl = pc_busca_crapttl_compl.pr_nmpaittl 
                                                      WHEN pc_busca_crapttl_compl.pr_nmpaittl <> ?
                                   crabttl.nmmaettl = pc_busca_crapttl_compl.pr_nmmaettl 
                                                      WHEN pc_busca_crapttl_compl.pr_nmmaettl <> ?.
                                                      
                            ASSIGN crabttl.tpdrendi[1] = pc_busca_crapttl_compl.pr_tpdrendi##1 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##1 <> ?
                                   crabttl.vldrendi[1] = pc_busca_crapttl_compl.pr_vldrendi##1 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##1 <> ?
                                   crabttl.tpdrendi[2] = pc_busca_crapttl_compl.pr_tpdrendi##2 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##2 <> ?                                                         
                                   crabttl.vldrendi[2] = pc_busca_crapttl_compl.pr_vldrendi##2
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##2 <> ?                                                        
                                   crabttl.tpdrendi[3] = pc_busca_crapttl_compl.pr_tpdrendi##3
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##3 <> ?
                                   crabttl.vldrendi[3] = pc_busca_crapttl_compl.pr_vldrendi##3 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##3 <> ?                                                         
                                   crabttl.tpdrendi[4] = pc_busca_crapttl_compl.pr_tpdrendi##4
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##4 <> ?
                                   crabttl.vldrendi[4] = pc_busca_crapttl_compl.pr_vldrendi##4
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##4 <> ?
                                   crabttl.tpdrendi[5] = pc_busca_crapttl_compl.pr_tpdrendi##5 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##5 <> ?
                                   crabttl.vldrendi[5] = pc_busca_crapttl_compl.pr_vldrendi##5 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##5 <> ?
                                   crabttl.tpdrendi[6] = pc_busca_crapttl_compl.pr_tpdrendi##6 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##6 <> ?
                                   crabttl.vldrendi[6] = pc_busca_crapttl_compl.pr_vldrendi##6 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##6 <> ?.
                          
                          ASSIGN
                              crabttl.cdcooper = par_cdcooper
                              crabttl.nrdconta = par_nrdconta
                              crabttl.idseqttl = 1   
                              crabttl.inhabmen = par_inhabmen
                              crabttl.dthabmen = par_dthabmen
                              crabttl.flgimpri = TRUE 
                              crabttl.inpolexp = 0
                              crabttl.nrcpfcgc = par_nrcpfcgc 
							  crabttl.nmsocial = par_nmsocial  
                              NO-ERROR.
    
                          IF  ERROR-STATUS:ERROR THEN
                              DO:
                                 ASSIGN par_dscritic = {&GET-MSG}.
                                 LEAVE ContadorFis.
                              END.

                          VALIDATE crabttl.

                          LEAVE ContadorFis.
                       END.
                END.
            ELSE
                LEAVE ContadorFis.
        END. /* ContadorFis */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO IncluiFis, LEAVE IncluiFis.

        ASSIGN par_rowidttl = ROWID(crabttl).

        ASSIGN aux_returnvl = "OK".

        LEAVE IncluiFis.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Inclui_Fis */

/* ------------------------------------------------------------------------ */
/*      INCLUI OS DADOS ORIGINADOS NA OPCAO [I]=INCLUSAO PESSOA JURIDICA    */
/* ------------------------------------------------------------------------ */
PROCEDURE Inclui_Jur PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DEC                            NO-UNDO.

    DEF OUTPUT PARAM par_rowidjur AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    DEF BUFFER crabjur FOR crapjur.

    IncluiJur: DO TRANSACTION
        ON ERROR  UNDO IncluiJur, LEAVE IncluiJur
        ON QUIT   UNDO IncluiJur, LEAVE IncluiJur
        ON STOP   UNDO IncluiJur, LEAVE IncluiJur
        ON ENDKEY UNDO IncluiJur, LEAVE IncluiJur:

        ContadorJur: DO aux_contador = 1 TO 10:

            FIND crabjur WHERE crabjur.cdcooper = par_cdcooper AND
                               crabjur.nrdconta = par_nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabjur THEN
                DO:
                   IF  LOCKED crabjur THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabjur 
                                     WHERE crabjur.cdcooper = par_cdcooper 
                                       AND crabjur.nrdconta = par_nrdconta 
                                     NO-LOCK NO-ERROR.
    
                                 IF  AVAILABLE crabjur THEN
                                     /* encontra o usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crabjur),"banco","crapjur").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorJur.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorJur.
                       END.
                   ELSE
                       DO:
                          CREATE crabjur.
                          
                          /* Chamar rotina para retornar dados de pessoa para complementar cadastro de PJ */
                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                          RUN STORED-PROCEDURE pc_busca_crapjur 
                                aux_handproc = PROC-HANDLE NO-ERROR
                                                 (  INPUT par_nrcpfcgc  /* pr_nrcpfcgc   */
                                                   ,OUTPUT 0    /* pr_qtfuncio */
                                                   ,OUTPUT 0    /* pr_vlcaprea */   
                                                   ,OUTPUT ?    /* pr_dtregemp */   
                                                   ,OUTPUT 0    /* pr_nrregemp */   
                                                   ,OUTPUT ""   /* pr_orregemp */   
                                                   ,OUTPUT 0    /* pr_nrcdnire */
                                                   ,OUTPUT ?    /* pr_dtinsmun */
                                                   ,OUTPUT 0    /* pr_flgrefis */
                                                   ,OUTPUT ""   /* pr_dsendweb */
                                                   ,OUTPUT 0    /* pr_nrinsmun */
                                                   ,OUTPUT 0    /* pr_vlfatano */
                                                   ,OUTPUT 0    /* pr_nrlicamb */
                                                   ,OUTPUT ?    /* pr_dtvallic */
                                                   ,OUTPUT 0    /* pr_tpregtrb */
                                                   ,OUTPUT 0    /* pr_qtfilial */
                                                   ,OUTPUT ""). /* pr_dscritic */

                            CLOSE STORED-PROC pc_busca_crapjur 
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }                            
                            
                            ASSIGN crabjur.qtfuncio = pc_busca_crapjur.pr_qtfuncio 
                                                      WHEN pc_busca_crapjur.pr_qtfuncio <> ?
                                   crabjur.vlcaprea = pc_busca_crapjur.pr_vlcaprea 
                                                      WHEN pc_busca_crapjur.pr_vlcaprea <> ? 
                                   crabjur.dtregemp = pc_busca_crapjur.pr_dtregemp 
                                                      WHEN pc_busca_crapjur.pr_dtregemp <> ? 
                                   crabjur.nrregemp = pc_busca_crapjur.pr_nrregemp 
                                                      WHEN pc_busca_crapjur.pr_nrregemp <> ? 
                                   crabjur.orregemp = pc_busca_crapjur.pr_orregemp 
                                                      WHEN pc_busca_crapjur.pr_orregemp <> ? 
                                   crabjur.nrcdnire = pc_busca_crapjur.pr_nrcdnire 
                                                      WHEN pc_busca_crapjur.pr_nrcdnire <> ? 
                                   crabjur.dtinsnum = pc_busca_crapjur.pr_dtinsmun 
                                                      WHEN pc_busca_crapjur.pr_dtinsmun <> ?                                    
                                   crabjur.dsendweb = pc_busca_crapjur.pr_dsendweb 
                                                      WHEN pc_busca_crapjur.pr_dsendweb <> ? 
                                   crabjur.nrinsmun = pc_busca_crapjur.pr_nrinsmun 
                                                      WHEN pc_busca_crapjur.pr_nrinsmun <> ?                                                       
                                   crabjur.vlfatano = pc_busca_crapjur.pr_vlfatano 
                                                      WHEN pc_busca_crapjur.pr_vlfatano <> ? 
                                   crabjur.nrlicamb = pc_busca_crapjur.pr_nrlicamb 
                                                      WHEN pc_busca_crapjur.pr_nrlicamb <> ?
                                   crabjur.dtvallic = pc_busca_crapjur.pr_dtvallic 
                                                      WHEN pc_busca_crapjur.pr_dtvallic <> ?
                                   crabjur.tpregtrb = pc_busca_crapjur.pr_tpregtrb 
                                                      WHEN pc_busca_crapjur.pr_tpregtrb <> ?
                                   crabjur.qtfilial = pc_busca_crapjur.pr_qtfilial
                                                      WHEN pc_busca_crapjur.pr_qtfilial <> ?. 
                                                      
                                   IF  pc_busca_crapjur.pr_flgrefis = 1 THEN                   
                                     DO:
                                       ASSIGN crabjur.flgrefis = TRUE.
                                     END.
                                   ELSE   
                                     DO:
                                       ASSIGN crabjur.flgrefis = FALSE.
                                     END.
                                 
                          ASSIGN
                              crabjur.cdcooper = par_cdcooper
                              crabjur.nrdconta = par_nrdconta 
                              crabjur.cdempres = 88 NO-ERROR.
    
                          IF  ERROR-STATUS:ERROR THEN
                              DO:
                                 ASSIGN par_dscritic = {&GET-MSG}.
                                 LEAVE ContadorJur.
                              END.

                          VALIDATE crabjur.
                          
                          LEAVE ContadorJur.
                       END.
                END.
            ELSE
                LEAVE ContadorJur.
        END. /* ContadorJur */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO IncluiJur, LEAVE IncluiJur.

        ASSIGN par_rowidjur = ROWID(crabjur).

        ASSIGN aux_returnvl = "OK".

        LEAVE IncluiJur.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Inclui_Jur */

/* ------------------------------------------------------------------------ */
/*      GRAVA OS DADOS ORIGINADOS NA OPCAO [X]=ALTERACAO RAZAO/CPF-CNPJ     */
/* ------------------------------------------------------------------------ */
PROCEDURE Nome_Cpf PRIVATE :
    
    DEF  INPUT PARAM par_rowidass AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_rowidttl AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_rowidjur AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabjur FOR crapjur.
    DEF BUFFER crabavt FOR crapavt.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    NomeCpf: DO TRANSACTION
        ON ERROR  UNDO NomeCpf, LEAVE NomeCpf
        ON QUIT   UNDO NomeCpf, LEAVE NomeCpf
        ON STOP   UNDO NomeCpf, LEAVE NomeCpf
        ON ENDKEY UNDO NomeCpf, LEAVE NomeCpf:

        ContadorAss: DO aux_contador = 1 TO 10:


            FIND crabass WHERE ROWID(crabass) = par_rowidass
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabass THEN
                DO:
                   IF  LOCKED crabass THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 FIND crabass 
                                     WHERE ROWID(crabass) = par_rowidass
                                     NO-LOCK NO-ERROR.
    
                                  IF  AVAILABLE crabass THEN
                                      /* mostra o usuario que esta travando */
                                      ASSIGN par_dscritic = LockTabela(
                                          RECID(crabass),"banco","crapass").
                                  ELSE
                                      ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorAss.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorAss.
                       END.
                   ELSE
                       DO:
                          ASSIGN par_cdcritic = 9.
                          LEAVE ContadorAss.
                       END.
                END.
            ELSE
                LEAVE ContadorAss.
        END. /* ContadorAss */

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO NomeCpf, LEAVE NomeCpf.

        /* Atualiza cadastro de titulares na CRAPASS */
        ASSIGN 
            aux_nrcpfcgc     = crabass.nrcpfcgc
            crabass.nmprimtl = CAPS(par_nmprimtl)
            crabass.nrcpfcgc = par_nrcpfcgc NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = {&GET-MSG}.
               UNDO NomeCpf, LEAVE NomeCpf.
            END.

        CASE crabass.inpessoa:
            WHEN 1 THEN DO:
                /* Registro do Titular */
                ContadorFis: DO aux_contador = 1 TO 10:

                    FIND crabttl WHERE ROWID(crabttl) = par_rowidttl
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabttl THEN
                        DO:
                           IF  LOCKED crabttl THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         FIND crabttl 
                                            WHERE ROWID(crabttl) = par_rowidttl
                                            NO-LOCK NO-ERROR.

                                         IF  AVAILABLE crabttl THEN
                                             /* mostra usuar.esta travando */
                                             ASSIGN par_dscritic = LockTabela(
                                                 RECID(crabttl),"banco",
                                                 "crapttl").
                                         ELSE
                                             ASSIGN par_cdcritic = 341.

                                         LEAVE ContadorFis.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorFis.
                               END.
                           ELSE
                               DO:
                                  ASSIGN par_cdcritic = 821.
                                  LEAVE ContadorFis.
                               END.
                        END.
                    ELSE
                        LEAVE ContadorFis.

                END. /* ContadorFis */

                IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                    UNDO NomeCpf, LEAVE NomeCpf.

                ASSIGN
                    crabttl.nmextttl = crabass.nmprimtl
                    crabttl.nrcpfcgc = crabass.nrcpfcgc
                    crabttl.flgimpri = TRUE NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       UNDO NomeCpf, LEAVE NomeCpf.
                    END.

                /* atualizar o cpf do registro de procurador/representante */
                IF  aux_nrcpfcgc <> crabass.nrcpfcgc THEN
                    FOR EACH crapavt WHERE 
                                     crapavt.cdcooper = crabass.cdcooper AND
                                     crapavt.tpctrato = 6 /*juridica*/   AND
                                     crapavt.nrdctato = crabass.nrdconta 
                                     NO-LOCK:

                        /* nao prosseguir se existir c/ o mesmo cpf */
                        IF  CAN-FIND(FIRST crabavt WHERE 
                                     crabavt.cdcooper = crapavt.cdcooper AND
                                     crabavt.nrdconta = crapavt.nrdconta AND
                                     crabavt.tpctrato = 6                AND
                                     crabavt.nrcpfcgc = crabass.nrcpfcgc) THEN
                            NEXT.

                        /* efetuar lock no registro e atualizar o cpf */
                        ContadorAvt: DO aux_contador = 1 TO 10:

                            FIND crabavt WHERE ROWID(crabavt) = ROWID(crapavt)
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAILABLE crabavt THEN
                                DO:
                                   IF  LOCKED(crabavt) THEN
                                       DO:
                                          IF  aux_contador = 10 THEN
                                              DO:
                                                 /*mostra usuar.esta travando*/
                                                 par_dscritic = LockTabela(
                                                     RECID(crapavt),"banco",
                                                     "crapavt").

                                                 LEAVE NomeCpf.
                                              END.

                                          PAUSE 1 NO-MESSAGE.
                                          NEXT ContadorAvt.
                                       END.
                                   ELSE
                                       LEAVE ContadorAvt.
                                END.
                            ELSE
                                DO:
                                   ASSIGN crabavt.nrcpfcgc = crabass.nrcpfcgc 
                                          crabavt.flgimpri = TRUE NO-ERROR.

                                   IF  ERROR-STATUS:ERROR THEN
                                       DO:
                                          ASSIGN par_dscritic = {&GET-MSG}.
                                          UNDO NomeCpf, LEAVE NomeCpf.
                                       END.
                                   LEAVE ContadorAvt.
                                END.
                        END. /* ContadorAvt */

                        RELEASE crabavt.

                        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                            UNDO NomeCpf, LEAVE NomeCpf.

                    END. /* FOR EACH crapavt  */
            END.
            OTHERWISE DO:
                /* Registro de pessoa Juridica */
                ContadorJur: DO aux_contador = 1 TO 10:

                    FIND crabjur WHERE ROWID(crabjur) = par_rowidjur
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabjur THEN
                        DO:
                           IF  LOCKED(crabjur) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         FIND crabjur 
                                            WHERE ROWID(crabjur) = par_rowidjur
                                            NO-LOCK NO-ERROR.

                                         IF  AVAILABLE crabjur THEN
                                             /* mostra usuar. esta travando */
                                             ASSIGN par_dscritic = LockTabela(
                                                 RECID(crabjur),"banco",
                                                 "crapjur").
                                         ELSE
                                             ASSIGN par_cdcritic = 341.

                                         LEAVE ContadorJur.
                                      END.

                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorJur.
                               END.
                           ELSE
                               DO:
                                  ASSIGN par_dscritic = "Cadastro de Pessoa " +
                                                        "Juridica nao foi en" +
                                                        "contrado.".
                                  LEAVE ContadorJur.
                               END.
                        END.
                    ELSE
                        LEAVE ContadorJur.

                END. /* ContadorJur */

                IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                    UNDO NomeCpf, LEAVE NomeCpf.

                ASSIGN crabjur.nmextttl = crabass.nmprimtl  NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = {&GET-MSG}.
                       UNDO NomeCpf, LEAVE NomeCpf.
                    END.
            END.
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE NomeCpf.
     END.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

END PROCEDURE. /* Nome_Cpf */

/* ------------------------------------------------------------------------ */
/*              GRAVA OS DADOS DO PARCELAMENTO DE CAPITAL                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Parcelamento PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdebito AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtparcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlparcel AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlparcel AS DECI                                    NO-UNDO.
    DEF VAR aux_vldsobra AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdebito AS DATE                                    NO-UNDO.
    DEF VAR aux_contareg AS INTE                                    NO-UNDO.
    DEF VAR aux_contasdc AS INTE                                    NO-UNDO.
    DEF VAR aux_hrtransa AS INTE                                    NO-UNDO.
    DEF VAR aux_vllanmto AS DECI                                    NO-UNDO.
    DEF VAR h-b1wgen0008 AS HANDLE                                  NO-UNDO.

    DEF BUFFER brapass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Parcelamento: DO TRANSACTION
        ON ERROR  UNDO Parcelamento, LEAVE Parcelamento
        ON QUIT   UNDO Parcelamento, LEAVE Parcelamento
        ON STOP   UNDO Parcelamento, LEAVE Parcelamento
        ON ENDKEY UNDO Parcelamento, LEAVE Parcelamento:

        IF  NOT VALID-HANDLE(h-b1wgen0008) THEN
            RUN sistema/generico/procedures/b1wgen0008.p
                PERSISTENT SET h-b1wgen0008.

        FOR FIRST brapass FIELDS(nrmatric)
                          WHERE brapass.cdcooper = par_cdcooper AND
                                brapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE brapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE Parcelamento.
            END.

        ASSIGN 
            aux_hrtransa = TIME.
        
        IF  par_qtparcel > 0  THEN
            DO:
               ASSIGN
                   aux_vlparcel = TRUNCATE(par_vlparcel / par_qtparcel,2).
                   aux_vldsobra = par_vlparcel - (aux_vlparcel * par_qtparcel).

               IF  NOT VALID-HANDLE(h-b1wgen0008) THEN
                   RUN sistema/generico/procedures/b1wgen0008.p
                       PERSISTENT SET h-b1wgen0008.
        
               DO aux_contador = 1 TO par_qtparcel:
        
                  IF  aux_contador = 1 THEN 
                      ASSIGN aux_dtdebito = par_dtdebito.
                  ELSE
                      RUN calcdata IN h-b1wgen0008
                          ( INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT "",
                            INPUT par_dtdebito,
                            INPUT aux_contador - 1,
                            INPUT "M",
                            INPUT 0,
                           OUTPUT aux_dtdebito,
                           OUTPUT TABLE tt-erro ).
        
                  FIND FIRST tt-erro NO-ERROR.
        
                  IF  AVAILABLE tt-erro THEN
                      DO:
                         ASSIGN par_dscritic = tt-erro.dscritic.
                         EMPTY TEMP-TABLE tt-erro.
                         LEAVE Parcelamento.
                      END.
        
                  IF  aux_contador > 0 AND aux_contador < 4  THEN
                      ASSIGN aux_contareg = 1.
                  ELSE
                  IF  aux_contador > 3 AND aux_contador < 7  THEN
                      ASSIGN aux_contareg = 2.
                  ELSE
                  IF  aux_contador > 6 AND aux_contador < 10 THEN
                      ASSIGN aux_contareg = 3.
                  ELSE
                  IF  aux_contador > 9 AND aux_contador < 13 THEN
                      ASSIGN aux_contareg = 4.
        
                  IF  aux_contador = par_qtparcel THEN
                      ASSIGN aux_vlparcel = aux_vlparcel + aux_vldsobra.
        
                  ContadorSdc: DO aux_contasdc = 1 TO 10:
        
                      FIND crapsdc WHERE crapsdc.cdcooper = par_cdcooper AND
                                         crapsdc.dtrefere = aux_dtdebito AND
                                         crapsdc.nrdconta = par_nrdconta AND
                                         crapsdc.tplanmto = 2
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                      IF  NOT AVAILABLE crapsdc THEN
                          DO:
                             IF  LOCKED(crapsdc) THEN
                                 DO:
                                    IF  aux_contasdc = 10 THEN
                                        DO:
                                           FIND crapsdc 
                                               WHERE crapsdc.cdcooper = par_cdcooper 
                                                 AND crapsdc.dtrefere = aux_dtdebito 
                                                 AND crapsdc.nrdconta = par_nrdconta 
                                                 AND crapsdc.tplanmto = 2
                                               NO-LOCK NO-ERROR.
        
                                           IF  AVAILABLE crapsdc THEN
                                               /* mostra usuario que esta travando */
                                               ASSIGN par_dscritic = LockTabela(
                                                   RECID(crapsdc),"banco","crapsdc").
                                           ELSE 
                                               ASSIGN par_cdcritic = 341.
        
                                           LEAVE ContadorSdc.
                                        END.
        
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorSdc.
                                 END.
                             ELSE
                                 DO:
                                    CREATE crapsdc.
                                    ASSIGN 
                                        crapsdc.cdcooper = par_cdcooper
                                        crapsdc.dtrefere = aux_dtdebito
                                        crapsdc.nrdconta = par_nrdconta
                                        crapsdc.tplanmto = 2
                                        crapsdc.nrmatric = brapass.nrmatric
                                        crapsdc.dtmvtolt = par_dtmvtolt
                                        crapsdc.dtdebito = ?
                                        crapsdc.vllanmto = aux_vlparcel
                                        crapsdc.vldebito = 0
                                        crapsdc.indebito = 0
                                        crapsdc.nrseqdig = aux_contador + 1
                                        crapsdc.cdoperad = par_cdoperad
                                        crapsdc.hrtransa = aux_hrtransa NO-ERROR.
        
                                    IF  ERROR-STATUS:ERROR THEN
                                        ASSIGN par_dscritic = {&GET-MSG}.

                                    VALIDATE crapsdc.
        
                                    LEAVE ContadorSdc.
                                 END.
                          END.
                      ELSE
                          LEAVE ContadorSdc.
        
                  END. /* ContadorSdc */ 
        
                  RELEASE crapsdc.
        
                  IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                      UNDO Parcelamento, LEAVE Parcelamento.
               END.  /*  Fim do DO .. TO  */
            END.

        /*  Cria registro para subscricao do capital inicial ............... */
        ContadorSdc: DO aux_contasdc = 1 TO 10:

            FIND crapsdc WHERE crapsdc.cdcooper = par_cdcooper AND
                               crapsdc.dtrefere = par_dtmvtolt AND
                               crapsdc.nrdconta = par_nrdconta AND
                               crapsdc.tplanmto = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapsdc THEN
                DO:
                   IF  LOCKED(crapsdc) THEN
                       DO:
                          IF  aux_contasdc = 10 THEN
                              DO:
                                 FIND crapsdc 
                                     WHERE crapsdc.cdcooper = par_cdcooper 
                                       AND crapsdc.dtrefere = par_dtmvtolt 
                                       AND crapsdc.nrdconta = par_nrdconta 
                                       AND crapsdc.tplanmto = 1
                                     NO-LOCK NO-ERROR.

                                 IF  AVAILABLE crapsdc THEN
                                     /* mostra usuario que esta travando */
                                     ASSIGN par_dscritic = LockTabela(
                                         RECID(crapsdc),"banco","crapsdc").
                                 ELSE
                                     ASSIGN par_cdcritic = 341.

                                 LEAVE ContadorSdc.
                              END.

                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorSdc.
                       END.
                   ELSE
                       DO:
                          FOR FIRST crapmat FIELDS(vlcapini vlcapsub)
                              WHERE crapmat.cdcooper = par_cdcooper NO-LOCK:
                          END.
    
                          IF  NOT AVAILABLE crapmat THEN
                              DO:
                                 ASSIGN par_cdcritic = 71.
                                 LEAVE ContadorSdc.
                              END.

                          IF  crapmat.vlcapsub <> crapmat.vlcapini THEN 
                              ASSIGN aux_vllanmto = crapmat.vlcapsub - 
                                                    crapmat.vlcapini.
                          ELSE 
                              ASSIGN aux_vllanmto = crapmat.vlcapsub.

                          CREATE crapsdc.
                          ASSIGN 
                              crapsdc.cdcooper = par_cdcooper
                              crapsdc.dtrefere = par_dtmvtolt
                              crapsdc.nrdconta = par_nrdconta
                              crapsdc.tplanmto = 1
                              crapsdc.nrmatric = brapass.nrmatric
                              crapsdc.dtmvtolt = par_dtmvtolt
                              crapsdc.dtdebito = ?
                              crapsdc.vllanmto = aux_vllanmto
                              crapsdc.vldebito = 0
                              crapsdc.indebito = 0
                              crapsdc.nrseqdig = 1
                              crapsdc.cdoperad = par_cdoperad
                              crapsdc.hrtransa = aux_hrtransa NO-ERROR.

                          IF  ERROR-STATUS:ERROR THEN
                              ASSIGN par_dscritic = {&GET-MSG}.

                          VALIDATE crapsdc.

                          LEAVE ContadorSdc.
                       END.
                END.
            ELSE
                LEAVE ContadorSdc.

        END. /* ContadorSdc */ 

        IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
            UNDO Parcelamento, LEAVE Parcelamento.

        ASSIGN aux_returnvl = "OK".

        LEAVE Parcelamento.
     END.

     RELEASE brapass.
     RELEASE crapsdc.

     IF  VALID-HANDLE(h-b1wgen0008) THEN
         DELETE OBJECT h-b1wgen0008.

     IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
         ASSIGN aux_returnvl = "NOK".

     RETURN aux_returnvl.

END PROCEDURE. /* Parcelamento */

/* ------------------------------------------------------------------------ */
/*                      GRAVA OS DADOS DOS PROCURADORES                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Procurador PRIVATE :

  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INT                             NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INT                             NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INT                             NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_inpessoa AS INT                             NO-UNDO.
  DEF INPUT PARAM par_idseqttl AS INT                             NO-UNDO.
  DEF INPUT PARAM par_nrcpfcgc AS DEC                             NO-UNDO.

  DEF INPUT PARAM TABLE FOR tt-crapavt.
  DEF INPUT PARAM TABLE FOR tt-bens.

  DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
  DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

  DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
  DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
  DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
  DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
  DEF VAR aux_geroerro AS LOG                                     NO-UNDO.
  DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
  DEF VAR aux_tpatlcad AS INT                                     NO-UNDO.
  DEF VAR aux_msgatcad AS CHAR                                    NO-UNDO.
  DEF VAR aux_chavealt AS CHAR                                    NO-UNDO. 
  DEF VAR aux_qtdavali AS INT                                     NO-UNDO.
  DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
  DEF VAR aux_inpessoa AS INT                                     NO-UNDO.
  DEF VAR aux_stsnrcal AS LOG                                     NO-UNDO.
  DEF VAR aux_nrcpfcgc AS DEC                                     NO-UNDO.
  DEF VAR aux_nrdctato AS INT                                     NO-UNDO.
  DEF VAR aux_cdorgexp AS CHAR                                    NO-UNDO.

  DEF BUFFER b-crapavt1 FOR crapavt.

  ASSIGN par_dscritic = ""
         par_cdcritic = 0
         aux_returnvl = "NOK"
         aux_qtdavali = 0
         aux_dsrotina = ""
         aux_inpessoa = 0
         aux_stsnrcal = FALSE
         aux_nrcpfcgc = 0
         aux_nrdctato = 0.
         

  Procurador: DO TRANSACTION
     ON ERROR  UNDO Procurador, LEAVE Procurador
     ON QUIT   UNDO Procurador, LEAVE Procurador
     ON STOP   UNDO Procurador, LEAVE Procurador
     ON ENDKEY UNDO Procurador, LEAVE Procurador:

     IF NOT VALID-HANDLE(h-b1wgen0072) THEN
        RUN sistema/generico/procedures/b1wgen0072.p
            PERSISTENT SET h-b1wgen0072.

     FOR EACH tt-crapavt BY NOT tt-crapavt.deletado:

         ASSIGN aux_geroerro = FALSE.

         ContadorAvt: DO aux_contador = 1 TO 10:

            FIND crapavt WHERE ROWID(crapavt) = tt-crapavt.rowidavt
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE crapavt THEN
               DO:
                  IF LOCKED(crapavt) THEN
                     DO:
                        IF aux_contador = 10 THEN
                           DO:
                              FIND crapavt WHERE 
                                   ROWID(crapavt) = tt-crapavt.rowidavt
                                   NO-LOCK NO-ERROR.

                              IF AVAILABLE crapavt THEN
                                 ASSIGN par_dscritic = LockTabela(
                                        RECID(crapavt),"banco","crapavt").
                              ELSE
                                 ASSIGN par_cdcritic = 341.

                              LEAVE ContadorAvt.

                           END.

                        PAUSE 1 NO-MESSAGE.
                        NEXT ContadorAvt.

                     END.
                  ELSE
                     DO:
                        ASSIGN par_dscritic = "".

                        IF NOT tt-crapavt.deletado THEN
                           DO:
                              CREATE crapavt.
                              ASSIGN crapavt.cdcooper = par_cdcooper
                                     crapavt.tpctrato = 6 /*juridica*/
                                     crapavt.nrdconta = par_nrdconta
                                     crapavt.nrctremp = tt-crapavt.nrctremp
                                     crapavt.nrdctato = tt-crapavt.nrdctato
                                     crapavt.dtvalida = tt-crapavt.dtvalida
                                     crapavt.dsproftl = tt-crapavt.dsproftl
                                     crapavt.nrcpfcgc = tt-crapavt.nrcpfcgc
                                     crapavt.dtmvtolt = tt-crapavt.dtmvtolt
                                     crapavt.dtadmsoc = tt-crapavt.dtadmsoc
                                     crapavt.flgdepec = tt-crapavt.flgdepec
                                     crapavt.persocio = tt-crapavt.persocio
                                     crapavt.vloutren = tt-crapavt.vloutren
                                     crapavt.dsoutren = TRIM(tt-crapavt.dsoutren)
                                     NO-ERROR.
     
                              IF ERROR-STATUS:ERROR THEN
                                 ASSIGN par_dscritic = {&GET-MSG}.

                              VALIDATE crapavt.

                           END.

                        LEAVE ContadorAvt.

                     END.

               END.
            ELSE
               DO:
                  IF tt-crapavt.deletado THEN
                     DO:
                        ASSIGN aux_qtdavali = 0.

                        DELETE crapavt.

                        /*Soh serao deletados os resp. legal de procuradores
                          que nao sao associados e que estejam relacionados 
                          a apenas um cooperado.*/
                        FIND FIRST crapass WHERE 
                                   crapass.cdcooper = tt-crapavt.cdcooper AND
                                   crapass.nrcpfcgc = tt-crapavt.nrcpfcgc
                                   NO-LOCK NO-ERROR.

                        IF NOT AVAIL crapass THEN
                           DO:
                               FOR EACH b-crapavt1 WHERE 
                                   b-crapavt1.cdcooper = tt-crapavt.cdcooper AND
                                   b-crapavt1.tpctrato = tt-crapavt.tpctrato AND
                                   b-crapavt1.nrctremp = tt-crapavt.nrctremp AND
                                   b-crapavt1.nrcpfcgc = tt-crapavt.nrcpfcgc
                                   NO-LOCK:
                                
                                   ASSIGN aux_qtdavali = aux_qtdavali + 1.

                               END.

                               IF aux_qtdavali <= 1 THEN
                                  DO:
                                     FOR EACH crapcrl WHERE 
                                         crapcrl.cdcooper = tt-crapavt.cdcooper         AND
                                         crapcrl.nrctamen = tt-crapavt.nrdctato         AND
                                         crapcrl.nrcpfmen = (IF tt-crapavt.nrdctato = 0 THEN 
                                                                tt-crapavt.nrcpfcgc
                                                             ELSE
                                                                0)                      AND
                                         crapcrl.idseqmen = tt-crapavt.nrctremp
                                         NO-LOCK:
                                     
                                         /* Retornar orgao expedidor */
                                         IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                                              RUN sistema/generico/procedures/b1wgen0052b.p 
                                                  PERSISTENT SET h-b1wgen0052b.

                                         ASSIGN aux_cdorgexp = "".
                                         RUN busca_org_expedidor IN h-b1wgen0052b 
                                                             ( INPUT crapcrl.idorgexp,
                                                              OUTPUT aux_cdorgexp,
                                                              OUTPUT par_cdcritic, 
                                                              OUTPUT par_dscritic).

                                         DELETE PROCEDURE h-b1wgen0052b.   

                                         IF  RETURN-VALUE = "NOK" THEN
                                         DO:
                                           LEAVE ContadorAvt.   
                                         END.
                                     
                                         RUN Grava_Dados IN h-b1wgen0072 
                                                   (INPUT par_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT 1,
                                                    INPUT tt-crapavt.nrdctato,
                                                    INPUT tt-crapavt.nrctremp,
                                                    INPUT FALSE,
                                                    INPUT ?,
                                                    INPUT TODAY,
                                                    INPUT "E",
                                                    INPUT crapcrl.nrdconta,
                                                    INPUT crapcrl.nrcpfcgc,
                                                    INPUT crapcrl.nmrespon,
                                                    INPUT crapcrl.tpdeiden,
                                                    INPUT crapcrl.nridenti,
                                                    INPUT aux_cdorgexp,
                                                    INPUT crapcrl.cdufiden,
                                                    INPUT crapcrl.dtemiden,
                                                    INPUT crapcrl.dtnascin,
                                                    INPUT crapcrl.cddosexo,
                                                    INPUT crapcrl.cdestciv,
                                                    INPUT crapcrl.cdnacion,
                                                    INPUT crapcrl.dsnatura,
                                                    INPUT crapcrl.cdcepres,
                                                    INPUT crapcrl.dsendres,
                                                    INPUT crapcrl.dsbaires,
                                                    INPUT crapcrl.dscidres,
                                                    INPUT crapcrl.nrendres,
                                                    INPUT crapcrl.dsdufres,
                                                    INPUT crapcrl.dscomres,
                                                    INPUT crapcrl.nrcxpost,
                                                    INPUT crapcrl.nmmaersp,
                                                    INPUT crapcrl.nmpairsp,
                                                    INPUT tt-crapavt.nrcpfcgc,
                                                    INPUT crapcrl.cdrlcrsp,
                                                    INPUT "PROC_RESP",
                                                    OUTPUT aux_msgalert,
                                                    OUTPUT aux_tpatlcad,
                                                    OUTPUT aux_msgatcad, 
                                                    OUTPUT aux_chavealt, 
                                                    OUTPUT TABLE tt-erro) NO-ERROR.
                                         
                                         IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                               ASSIGN aux_geroerro = TRUE.
                                               LEAVE ContadorAvt.
                                     
                                            END.
                                     
                                     END.

                                  END.

                           END.

                     END.
                  ELSE
                     ASSIGN crapavt.dtvalida = tt-crapavt.dtvalida
                            crapavt.dsproftl = tt-crapavt.dsproftl
                            crapavt.dtadmsoc = tt-crapavt.dtadmsoc
                            crapavt.flgdepec = tt-crapavt.flgdepec
                            crapavt.persocio = tt-crapavt.persocio
                            crapavt.vloutren = tt-crapavt.vloutren
                            crapavt.dsoutren = TRIM(tt-crapavt.dsoutren).

                  ASSIGN par_dscritic = "".

                  LEAVE ContadorAvt.

               END.

         END. /* ContadorAvt */

         IF par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO Procurador, LEAVE Procurador.

         IF tt-crapavt.nrdctato = 0 AND 
            NOT tt-crapavt.deletado THEN
            DO:
               ASSIGN crapavt.nmdavali    = UPPER(tt-crapavt.nmdavali)
                      crapavt.tpdocava    = tt-crapavt.tpdocava
                      crapavt.nrdocava    = tt-crapavt.nrdocava
                      crapavt.cdufddoc    = UPPER(tt-crapavt.cdufddoc)
                      crapavt.dtemddoc    = tt-crapavt.dtemddoc
                      crapavt.dtnascto    = tt-crapavt.dtnascto
                      crapavt.cdsexcto    = tt-crapavt.cdsexcto
                      crapavt.cdestcvl    = tt-crapavt.cdestcvl
                      crapavt.cdnacion    = tt-crapavt.cdnacion
                      crapavt.dsnatura    = UPPER(tt-crapavt.dsnatura)
                      crapavt.nrcepend    = tt-crapavt.nrcepend
                      crapavt.dsendres[1] = UPPER(tt-crapavt.dsendres[1])
                      crapavt.nrendere    = tt-crapavt.nrendere
                      crapavt.complend    = UPPER(tt-crapavt.complend)
                      crapavt.nmbairro    = UPPER(tt-crapavt.nmbairro)
                      crapavt.nmcidade    = UPPER(tt-crapavt.nmcidade)
                      crapavt.cdufresd    = UPPER(tt-crapavt.cdufresd)
                      crapavt.nrcxapst    = tt-crapavt.nrcxapst
                      crapavt.vledvmto    = tt-crapavt.vledvmto
                      crapavt.nmmaecto    = UPPER(tt-crapavt.nmmaecto)
                      crapavt.nmpaicto    = UPPER(tt-crapavt.nmpaicto)
                      crapavt.inhabmen    = tt-crapavt.inhabmen
                      crapavt.dthabmen    = tt-crapavt.dthabmen NO-ERROR.
  
               IF ERROR-STATUS:ERROR THEN
                  DO:
                     ASSIGN par_dscritic = {&GET-MSG}.
                     LEAVE Procurador.

                  END.

               /* Identificar orgao expedidor */
               IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                    RUN sistema/generico/procedures/b1wgen0052b.p 
                        PERSISTENT SET h-b1wgen0052b.

               ASSIGN crapavt.idorgexp = 0.
               RUN identifica_org_expedidor IN h-b1wgen0052b 
                                   ( INPUT UPPER( tt-crapavt.cdoeddoc),
                                    OUTPUT crapavt.idorgexp,
                                    OUTPUT par_cdcritic, 
                                    OUTPUT par_dscritic).

               DELETE PROCEDURE h-b1wgen0052b.   

               IF  RETURN-VALUE = "NOK" THEN
               DO:
                    LEAVE Procurador.
                  END.

               ASSIGN aux_contador = 0.
                
               /* Realiza a gravacao dos bens */
               IF tt-crapavt.cddopcao <> "E" THEN
                  DO:
                     ASSIGN crapavt.dsrelbem = ""
                            crapavt.persemon = 0
                            crapavt.qtprebem = 0
                            crapavt.vlprebem = 0
                            crapavt.vlrdobem = 0.
                     
                     FOR EACH tt-bens WHERE 
                        (tt-bens.nrdrowid = tt-crapavt.nrdrowid          OR
                         tt-bens.cpfdoben = STRING(tt-crapavt.nrcpfcgc)) AND
                         tt-bens.deletado = NO
                         NO-LOCK:

                         ASSIGN aux_contador = aux_contador + 1
                                crapavt.dsrelbem[aux_contador] = 
                                                     CAPS(tt-bens.dsrelbem)
                                crapavt.persemon[aux_contador] = 
                                                     tt-bens.persemon
                                crapavt.qtprebem[aux_contador] = 
                                                     tt-bens.qtprebem
                                crapavt.vlprebem[aux_contador] = 
                                                     tt-bens.vlprebem
                                crapavt.vlrdobem[aux_contador] = 
                                                     tt-bens.vlrdobem.
                         
                         IF ERROR-STATUS:ERROR THEN
                            DO:
                               ASSIGN par_dscritic = {&GET-MSG}.
                               LEAVE Procurador.
                           
                            END.
                     
                     END.
                     
                  END.

            END.

         IF NOT tt-crapavt.deletado THEN
            DO:
               ASSIGN aux_nrcpfcgc = 0
                      aux_stsnrcal = FALSE
                      aux_inpessoa = 0
                      aux_dsrotina = ""
                      aux_nrdctato = 0.

               IF crapavt.nrdctato <> 0 THEN
                  DO:
                     FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                        crapass.nrdconta = crapavt.nrdctato
                                        NO-LOCK NO-ERROR.

                     IF NOT AVAIL crapass THEN
                        DO:
                           ASSIGN par_cdcritic = 9.
    
                           LEAVE Procurador.

                        END.

                     ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                            aux_nrdctato = crapass.nrdconta.

                  END.
               ELSE
                  ASSIGN aux_nrcpfcgc = crapavt.nrcpfcgc
                         aux_nrdctato = crapavt.nrdctato.

               IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                  RUN sistema/generico/procedures/b1wgen9999.p
                      PERSISTENT SET h-b1wgen9999.


               RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT aux_nrcpfcgc,
                                                   OUTPUT aux_stsnrcal,
                                                   OUTPUT aux_inpessoa).
                                                   
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE PROCEDURE h-b1wgen9999.

               IF NOT aux_stsnrcal THEN
                  DO:
                      ASSIGN par_cdcritic = 9.

                      LEAVE Procurador.

                  END.

               ASSIGN aux_dsrotina = "Inclusao/alteracao do Rep/Procurador " +
                                     "conta "                                +
                                     STRING(aux_nrdctato,"zzzz,zzz,9")       +
                                     " - CPF/CNPJ "                          + 
                                     (IF aux_inpessoa = 1 THEN 
                                         STRING((STRING(aux_nrcpfcgc,
                                                 "99999999999")),
                                                 "xxx.xxx.xxx-xx")
                                      ELSE
                                         STRING((STRING(aux_nrcpfcgc,
                                                 "99999999999999")),
                                                 "xx.xxx.xxx/xxxx-xx"))      +
                                     " no " + STRING(par_idseqttl)           +
                                     "o titular da conta "                   +
                                     STRING(par_nrdconta,"zzzz,zzz,9")       +
                                     " - CPF/CNPJ "                          +
                                    (IF par_inpessoa = 1 THEN
                                        STRING((STRING(par_nrcpfcgc,
                                                "99999999999")),
                                                "xxx.xxx.xxx-xx")
                                     ELSE
                                        STRING((STRING(par_nrcpfcgc,
                                                "99999999999999")),
                                                "xx.xxx.xxx/xxxx-xx")).
                                                 
     
               IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                  RUN sistema/generico/procedures/b1wgen0110.p
                      PERSISTENT SET h-b1wgen0110.

               /*Verifica se o Rep/Procurador esta no cadastro restritivo. Se 
                 estiver, sera enviado um e-mail informando a situacao*/
               RUN alerta_fraude IN h-b1wgen0110
                                (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT aux_nrcpfcgc,
                                 INPUT aux_nrdctato,
                                 INPUT 1,     /*idseqttl*/
                                 INPUT FALSE, /*nao bloq. operacao*/
                                 INPUT 29,    /*cdoperac*/
                                 INPUT aux_dsrotina,
                                 OUTPUT TABLE tt-erro).

               IF VALID-HANDLE(h-b1wgen0110) THEN
                  DELETE PROCEDURE(h-b1wgen0110).

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF NOT AVAIL tt-erro THEN
                        ASSIGN par_dscritic = "Nao foi possivel verificar" +
                                              " cadastro restritivo.".
                     ELSE
                        ASSIGN par_cdcritic = tt-erro.cdcritic.

                     LEAVE Procurador.

                  END.
                     
            END.

         RELEASE crapavt.

     END. /* FOR EACH tt-crapavt  */

     ASSIGN aux_returnvl = "OK".

     LEAVE Procurador.

  END.

  IF VALID-HANDLE(h-b1wgen0072) THEN
     DELETE OBJECT h-b1wgen0072.

  IF par_dscritic <> "" OR par_cdcritic <> 0 THEN
     ASSIGN aux_returnvl = "NOK".

  RETURN aux_returnvl.

END PROCEDURE. /* Procurador */

/*........................... FUNCOES INTERNAS/PRIVADAS .....................*/

FUNCTION LockTabela RETURNS CHARACTER PRIVATE
  ( INPUT par_recidtab AS RECID,
    INPUT par_nmdbanco AS CHAR, 
    INPUT par_nmtabela AS CHAR ) :
/*-----------------------------------------------------------------------------
  Objetivo:  Identifica o usuario que esta locando o registro
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_mslocktb AS CHAR                                    NO-UNDO.

    ASSIGN aux_mslocktb = "Registro sendo alterado em outro terminal (" + 
                           par_nmtabela + ").".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT par_recidtab,
                                   INPUT par_nmdbanco,
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE OBJECT h-b1wgen9999.

    ASSIGN aux_mslocktb = aux_mslocktb + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN aux_mslocktb.   /* Function return value. */

END FUNCTION.


/*Se o cpf em questao ja tiver registros nas tabelas AVT (nrdctato = 0) e 
  CRL (nrdconta = 0) entao, serao atualizados com o numero da conta que
  esta sendo criada.*/
PROCEDURE atualiza_avt_crl PRIVATE:

   DEF INPUT PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INT                               NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INT                               NO-UNDO.
   DEF INPUT PARAM par_nrcpfcgc AS DEC                               NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_returnvl AS CHAR                                      NO-UNDO.

   ASSIGN aux_returnvl = "NOK".

   Atualiza_avt_crl: 
   DO TRANSACTION ON ERROR  UNDO Atualiza_avt_crl, LEAVE Atualiza_avt_crl
                  ON QUIT   UNDO Atualiza_avt_crl, LEAVE Atualiza_avt_crl
                  ON STOP   UNDO Atualiza_avt_crl, LEAVE Atualiza_avt_crl
                  ON ENDKEY UNDO Atualiza_avt_crl, LEAVE Atualiza_avt_crl:

      /* Atualiza o resgistro do Rep./Proc. */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
         FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                crapavt.nrcpfcgc = par_nrcpfcgc AND
                                crapavt.tpctrato = 6            AND
                                crapavt.nrdctato = 0
                                EXCLUSIVE-LOCK:
         
             ASSIGN crapavt.nrdctato = par_nrdconta
                    crapavt.nmdavali = "" 
                    crapavt.tpdocava = "" 
                    crapavt.nrdocava = "" 
                    crapavt.idorgexp = 0 
                    crapavt.cdufddoc = "" 
                    crapavt.dtemddoc = ? 
                    crapavt.dtnascto = ? 
                    crapavt.cdsexcto = 0
                    crapavt.cdestcvl = 0 
                    crapavt.cdnacion = 0
                    crapavt.dsnatura = "" 
                    crapavt.nrcepend = 0 
                    crapavt.dsendres = ""
                    crapavt.nrendere = 0
                    crapavt.complend = "" 
                    crapavt.nmbairro = "" 
                    crapavt.nmcidade = "" 
                    crapavt.cdufresd = "" 
                    crapavt.nrcxapst = 0 
                    crapavt.vledvmto = 0 
                    crapavt.nmmaecto = "" 
                    crapavt.nmpaicto = ""
                    crapavt.inhabmen = 0 
                    crapavt.dthabmen = ?
                    crapavt.dsrelbem = ""
                    crapavt.persemon = 0 
                    crapavt.qtprebem = 0 
                    crapavt.vlprebem = 0 
                    crapavt.vlrdobem = 0.

         END.

         RELEASE crapavt.

         LEAVE.

      END.

    
      /*Atualiza o registro do Responsavel Legal*/
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                                crapcrl.nrcpfcgc = par_nrcpfcgc AND
                                crapcrl.nrdconta = 0
                                EXCLUSIVE-LOCK:

             ASSIGN crapcrl.nrdconta = par_nrdconta
                    crapcrl.nmrespon = ""
                    crapcrl.tpdeiden = ""
                    crapcrl.nridenti = ""
                    crapcrl.idorgexp = 0
                    crapcrl.cdufiden = ""
                    crapcrl.dtemiden = ?
                    crapcrl.dtnascin = ?
                    crapcrl.cddosexo = 0
                    crapcrl.cdestciv = 0
                    crapcrl.cdnacion = 0
                    crapcrl.dsnatura = ""
                    crapcrl.cdcepres = 0
                    crapcrl.dsendres = ""
                    crapcrl.nrendres = 0
                    crapcrl.dscomres = ""
                    crapcrl.dsbaires = ""
                    crapcrl.dscidres = ""
                    crapcrl.dsdufres = ""
                    crapcrl.nrcxpost = 0
                    crapcrl.nmmaersp = ""
                    crapcrl.nmpairsp = ""
                    crapcrl.nrcpfcgc = 0.


         END.

         RELEASE crapcrl.

         LEAVE.

      END.

      ASSIGN aux_returnvl = "OK".

      LEAVE Atualiza_avt_crl.
             
   END.

   RETURN aux_returnvl.


END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*        ATUALIZA NOME DO COOPERADO EM TODAS AS CONTAS COM MESMO CPF       */
/* ------------------------------------------------------------------------ */
PROCEDURE atualiza_nome_cooperado PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmextttl AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_cont_ass AS INTE                                    NO-UNDO.
    DEF VAR aux_cont_ttl AS INTE                                    NO-UNDO.

    FOR EACH crapttl WHERE crapttl.cdcooper =  par_cdcooper
                       AND crapttl.nrcpfcgc =  par_nrcpfcgc
                     EXCLUSIVE-LOCK:
        /* Dados do Titular - Pessoa Fisica */
        ContadorTtl: DO aux_cont_ttl = 1 TO 10:
            IF  LOCKED(crapttl) THEN
                DO:
                    IF aux_cont_ttl = 10 THEN
                        DO:
                            IF  AVAILABLE crapttl THEN
                                /* mostra us. que esta travando */
                                ASSIGN par_dscritic = LockTabela(
                                                      RECID(crapttl),"banco",
                                                      "crapttl").
                            ELSE
                                ASSIGN par_cdcritic = 341.

                            LEAVE ContadorTtl.
                        END.

                    PAUSE 1 NO-MESSAGE.
                    NEXT ContadorTtl.
                END.
            ELSE
                DO:
                    /* Atualizar o nome do titular */
                    ASSIGN crapttl.nmextttl = UPPER(par_nmextttl).
                    /* Buscar o Associado corresponte e atualiza o nome tambem */
                    ContadorAss: DO aux_cont_ass = 1 TO 10:

                        FIND crapass WHERE crapass.cdcooper = crapttl.cdcooper
                                       AND crapass.nrdconta = crapttl.nrdconta
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAILABLE crapass THEN
                            DO:
                                IF  LOCKED(crapass) THEN
                                    DO:
                                        IF aux_cont_ass = 10 THEN
                                            DO:
                                                IF  AVAILABLE crapass THEN
                                                    /* mostra us. que esta travando */
                                                    ASSIGN par_dscritic = LockTabela(
                                                                          RECID(crapass),"banco",
                                                                          "crapass").
                                                ELSE
                                                    ASSIGN par_cdcritic = 341.

                                                LEAVE ContadorAss.
                                            END.

                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorAss.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN par_cdcritic = 821.
                                        LEAVE ContadorAss.
                                    END.
                            END.
                        ELSE
                            DO:
                                CASE crapttl.idseqttl:
                                    WHEN 1 THEN DO:
                                        ASSIGN crapass.nmprimtl = UPPER(par_nmextttl).
                                    END.
                                END CASE.

                                LEAVE ContadorAss.
                            END.
                    END. /* ContadorAss */

                    LEAVE ContadorTtl.
                END.
        END. /* ContadorTtl */
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        RETURN "NOK".

    FOR EACH crapttl WHERE crapttl.cdcooper =  par_cdcooper
                       AND crapttl.nrcpfcgc =  par_nrcpfcgc
                     EXCLUSIVE-LOCK:
        /* Dados do Titular - Pessoa Fisica */
        ContadorTtl: DO aux_cont_ttl = 1 TO 10:
            IF  LOCKED(crapttl) THEN
                DO:
                    IF aux_cont_ttl = 10 THEN
                        DO:
                            IF  AVAILABLE crapttl THEN
                                /* mostra us. que esta travando */
                                ASSIGN par_dscritic = LockTabela(
                                                      RECID(crapttl),"banco",
                                                      "crapttl").
                            ELSE
                                ASSIGN par_cdcritic = 341.

                            LEAVE ContadorTtl.
                        END.

                    PAUSE 1 NO-MESSAGE.
                    NEXT ContadorTtl.
                END.
            ELSE
                DO:
                    /* Atualizar o nome do titular */
                    ASSIGN crapttl.nmextttl = UPPER(par_nmextttl).
                    /* Buscar o Associado corresponte e atualiza o nome tambem */
                    ContadorAss: DO aux_cont_ass = 1 TO 10:

                        FIND crapass WHERE crapass.cdcooper = crapttl.cdcooper
                                       AND crapass.nrdconta = crapttl.nrdconta
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAILABLE crapass THEN
                            DO:
                                IF  LOCKED(crapass) THEN
                                    DO:
                                        IF aux_cont_ass = 10 THEN
                                            DO:
                                                IF  AVAILABLE crapass THEN
                                                    /* mostra us. que esta travando */
                                                    ASSIGN par_dscritic = LockTabela(
                                                                          RECID(crapass),"banco",
                                                                          "crapass").
                                                ELSE
                                                    ASSIGN par_cdcritic = 341.

                                                LEAVE ContadorAss.
                                            END.

                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorAss.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN par_cdcritic = 821.
                                        LEAVE ContadorAss.
                                    END.
                            END.
                        ELSE
                            DO:
                                CASE crapttl.idseqttl:
                                    WHEN 1 THEN DO:
                                        ASSIGN crapass.nmprimtl = UPPER(par_nmextttl).
                                    END.
                                END CASE.

                                LEAVE ContadorAss.
                            END.
                    END. /* ContadorAss */

                    LEAVE ContadorTtl.
                END.
        END. /* ContadorTtl */
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

PROCEDURE verifica_sit_JDBNF: 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.

    DEF VAR aux_insitif  AS CHAR                                    NO-UNDO.
    DEF VAR aux_insitcip AS CHAR                                    NO-UNDO. 
	DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    /* Chamar rotina para verificar situacao do CPF/CNPJ e enviar email */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_sit_JDBNF 
          aux_handproc = PROC-HANDLE NO-ERROR
                           (INPUT par_cdcooper,  /* Codigo da cooperativa */
                            INPUT par_nrdconta,  /* Numero da conta do cooperado */
                            INPUT par_inpessoa,  /* Tipo de pessoa */
                            INPUT par_nrcpfcgc,  /* CPF/CNPJ do beneficiario */
                           OUTPUT "",            /* pr_insitif  Retornar situaçao IF */  
                           OUTPUT "",            /* pr_insitcip Retornar situaçao CIP */  
                           OUTPUT "").

      CLOSE STORED-PROC pc_verifica_sit_JDBNF 
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_dscritic = ""
             aux_insitif  = ""
             aux_insitcip = ""
             aux_insitif  = pc_verifica_sit_JDBNF.pr_insitif 
                            WHEN pc_verifica_sit_JDBNF.pr_insitif <> ?
             aux_insitcip = pc_verifica_sit_JDBNF.pr_dscritic 
                            WHEN pc_verifica_sit_JDBNF.pr_insitcip <> ?
             aux_dscritic = pc_verifica_sit_JDBNF.pr_insitcip 
                            WHEN pc_verifica_sit_JDBNF.pr_dscritic <> ?.
          
      RETURN "OK".

END PROCEDURE. /* Fim procedure verifica_sit_JDBNF*/