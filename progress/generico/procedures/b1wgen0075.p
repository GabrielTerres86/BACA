/*.............................................................................

    Programa: b1wgen0075.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Maio/2010                   Ultima atualizacao: 30/07/2019

    Objetivo  : Tranformacao BO tela CONTAS - COMERCIAL

    Alteracoes: 12/08/2010 - Ajuste na validacao de UF (David).
     
                31/08/2010 - Removido campo crapass.cdempres (Diego).
                
                22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel -DB1).
                              
                20/12/2010 -  Dados do endereço salvos em letra maiuscula. 
                              Parametro de log para procedure Replica_Dados
                              (Gabriel - DB1).
   
                24/02/2011 - Adicionado criterio de validacao do
                             Digito Verificador, validando ou nao, conforme 
                             a empresa. (Jorge)
                             
                15/04/2011 - Incluida validação para CEP na valida_dados.
                             (André - DB1)
                             
                16/06/2011 - Ignorar o Nat Ocupacao = 99.
                             Gravar campo de 'Politcamente exposta' dependendo
                             a ocupacao do titular (Gabriel).           
                             
                23/11/2011 - Criado as procedures 
                             - Grava_Rendimentos
                             - Busca_Rendimentos 
                             (Adriano).
                             
                09/08/2013 - Gravação de registro na crapdoc quando houver
                             alteração de salario (Jean Michel).
                             
                14/10/2013 - Alimentado parametro par_flgcance na procedure
                             Grava_Dados para tratamento de alteracao de 
                             empresa que nao debita cotas capital em folha.
                            (Fabricio)

                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)

                17/01/2014 - Alteração na gravação de registro na crapdoc
                             quando houver alteração de salario, foi retirado
                             a inclusão de registros do tipo Identidade
                             (Jean Michel).

                12/05/2014 - Tratado na procedre Grava_Dados para alterar
                             os campos pertinentes 'a tabela crapcje quando
                             o titular em questao for conjuge, de acordo com
                             o que foi informado nos respectivos campos da ttl.
                             (Chamado 155606) - (Fabricio)

                15/05/2015 - Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)
                            
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).

                19/08/2015 - Projeto reformulacao cadastral (Gabriel-RKAM).            
				
                06/11/2015 - Ajuste na geração de log na rotina grava_dados,
                             conforme solicitado no chamado 351111. (Kelvin)
                             
                05/01/2016 - #350828 Tela PPE, procedures Busca_Dados_PPE 
                             e Grava_Dados_Ppe (Carlos)

                12/04/2016 - Incluir crapdoc.cdoperad na procedure Grava_Dados e
                             Grava_Dados_Ppe (Lucas Ranghetti #410302)
                             
                04/08/2016 - Ajuste para pegar o idcidade e nao mais cdcidade.
                             (Jaison/Anderson)
                             
                31/08/2016 - Ajustar gravacao na crapdoc do documento 37 para 
                             gerar pendencia apenas para o primeiro titular
                             e tambem duplicar dados de pessoa politicamente
                             exposta para todos as contas do cooperado incluido
                             contas onde ele eh primeiro titular (Lucas Ranghetti #491441)
                             
                16/11/2016 - Ajuste para nao gerar mais pendencia no digidoc com
                             tpdocmto = 37 e criar o campo inpolexp sempre como
                             nao inpolexp = 0 (Tiago/Thiago SD532690)

               17/01/2017 - Adicionado chamada a procedure de replicacao do 
                            endereco para o CDC. (Reinert Prj 289)
                             
			   08/03/2017 - Ajuste na rotina Busca_Dados_PPE para pegar o nome completo
			                da coupacao para as informacoes do PEP
							(Adriano - SD 614408).

			   18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
							
               11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                            Projeto 339 - CRM. (Lombardi)		 
							
			   16/08/2017 - Ajustes realizado para que não se crie crapenc sem informar 
							ao menos o CEP na tela comercial. (Kelvin/Andrino)

			   27/09/2017 - Removido regra que fazia com que só carregasse endereco comercial
							caso Tp. Ctr. Trab. seja diferente de 3. (PRJ339 - Kelvin/Andrino).
              13/10/2017 - Removido tratamento para colocar como inpolexp
                           qnd for da natureza de ocupacao igual a 99, pois
                           campo nao existe mais e nao era utilizado. 
                           PRJ339-CRM (Odirlei-AMcom)
			  27/02/2018 - Na procedure grava_dados removido o endereco comercial quando a
                     natureza da ocupaçao for 12(Sem vinculo) (Tiago #857499)
					 
			  16/06/2018 - Bloqueio realizado para que nao seja possivel salvar o CNPJ da empresa
						   com o cpf do titular. (SD 860231 - Kelvin).
                           
              13/02/2018 - Ajustes na geraçao de pendencia de digitalizaçao.
                             PRJ366 - tipo de conta (Odirlei-AMcom)
                             
			  05/07/2018 - Ajuste realizado para validar a atualização da unificação cadastral
						   na camada do progress (INC0018113).
						   
	          30/07/2018 - Feito a inversao das chamadas da procedures pc_revalida_nome_cad_unc e pc_revalida_cnpj_cad_unc. (Kelvin)
							
			  17/04/2019 - Validar também o CNPJ da empresa se é maior que zero, não apenas pela nome.
			               Para não ter problema ao cadastrar o cooperado como APOSENTADO.
						   Alcemir Mouts (INC0011837).
            
			  17/05/2019 - Correcao INC00015454 na chamada da procedure pc_valida_emp_conta_salari (Augusto - SUPERO). 

              16/07/2019 - Valida_dados P437 Nao validar o campo matricula(par_nrcadast) Jackson Barcellos - AMcom							

              30/07/2019 - Adicionado as variáveis aux_vlsalari e aux_nrcpfemp para validação em executar as procedures pc_confirma_pessoa_renda e 
                           pc_confirma_pessoa_empresa somente quando houver alteração da renda e da empresa por parte do usuário 
                           pelo sistema Aimaro (Paulo Penteado GFT)
                           
             29/08/2019 PJ485.6 - Ajuste na validaçao e retorno do empregador PF - Augusto (Supero)
							
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0075tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ) FORWARD.

FUNCTION ValidaDigFun RETURNS LOGICAL 
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrcadast AS INTEGER ) FORWARD.

FUNCTION ValidaNome RETURNS LOGICAL 
    ( INPUT  par_nmdbusca AS CHARACTER,
      OUTPUT par_cdcritic AS INTEGER ) FORWARD.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Dados:

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
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatopc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpcttrab AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsecao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnvlcgo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdturnos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrendi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrendi AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend3 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend3 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend4 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend4 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inpolexp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-comercial.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_criticas AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_dssituac_e AS CHAR                                    NO-UNDO.
    DEF VAR aux_idcanal_e  AS INTE                                    NO-UNDO.
    DEF VAR aux_dscanal_e  AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtrevisa_e AS DATE                                    NO-UNDO.
    DEF VAR aux_dscritic_e AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssituac_r AS CHAR                                    NO-UNDO.
    DEF VAR aux_idcanal_r  AS INTE                                    NO-UNDO.
    DEF VAR aux_dscanal_r  AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtrevisa_r AS DATE                                    NO-UNDO.
    DEF VAR aux_dscritic_r AS CHAR                                    NO-UNDO.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcpfcto AS DEC                                     NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Comercial"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno  = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-comercial.
        EMPTY TEMP-TABLE tt-erro.   

     
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

        FOR FIRST crapttl FIELDS(cdnatopc cdocpttl tpcttrab cdempres nmextemp
                                 nrcpfemp dsproftl cdnvlcgo nrcadast dtadmemp
								 vlsalari tpdrendi vldrendi cdturnos dsjusren 
								 inpolexp)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = par_idseqttl NO-LOCK:
        END.

        IF  NOT AVAILABLE crapttl THEN
            DO:
               ASSIGN aux_dscritic = "Dados do titular nao encontrados".
               LEAVE Busca.
            END.

        CREATE tt-comercial.

        ASSIGN 
            tt-comercial.nrdrowid = ROWID(crapttl)
            tt-comercial.cdnatopc = crapttl.cdnatopc
            tt-comercial.cdocpttl = crapttl.cdocpttl
            tt-comercial.tpcttrab = crapttl.tpcttrab
            tt-comercial.cdempres = crapttl.cdempres
            tt-comercial.nmextemp = crapttl.nmextemp
            tt-comercial.dsproftl = crapttl.dsproftl
            tt-comercial.cdnvlcgo = crapttl.cdnvlcgo
            tt-comercial.nrcadast = crapttl.nrcadast
            tt-comercial.dtadmemp = crapttl.dtadmemp
            tt-comercial.vlsalari = crapttl.vlsalari
            tt-comercial.cdturnos = crapttl.cdturnos
            tt-comercial.dsjusren = crapttl.dsjusren
            tt-comercial.inpolexp = crapttl.inpolexp
            tt-comercial.tppesemp = 2. /* Tipo de pessoa do empregador: inicialmente PJ */
            
        
        /* Se for empresa PF... */
        IF crapttl.cdempres = 9998 THEN
          ASSIGN tt-comercial.tppesemp = 1
                 tt-comercial.nrcpfemp = STRING(crapttl.nrcpfemp,"99999999999").
        ELSE 
          ASSIGN tt-comercial.nrcpfemp = STRING(crapttl.nrcpfemp,"99999999999999").

        DO aux_contador = 1 TO EXTENT(tt-comercial.tpdrendi):
          ASSIGN 
          tt-comercial.tpdrendi[aux_contador] = crapttl.tpdrendi[aux_contador]
          tt-comercial.vldrendi[aux_contador] = crapttl.vldrendi[aux_contador].
        
        END.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        /* Efetuar a chamada a rotina Oracle */
        RUN STORED-PROCEDURE pc_busca_tbcadast
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.nrcpfcgc /* Cpf */
                                            ,INPUT par_idseqttl     /* Numero sequencial  */
                                            ,INPUT "EMPRESA"        /* Tabela que será buscada */ 
                                            ,OUTPUT 0               /* Codigo da situacao */
                                            ,OUTPUT ""              /* Descricao da situacao   */
                                            ,OUTPUT 0               /* Codigo do Canal    */
                                            ,OUTPUT ""              /* Descricao do Canal */
                                            ,OUTPUT ?               /* Data da Revisao    */
                                            ,OUTPUT "").            /* Descrição da crítica    */
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_busca_tbcadast
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        ASSIGN aux_dssituac_e = pc_busca_tbcadast.pr_dssituac
                              WHEN pc_busca_tbcadast.pr_dssituac <> ?
               aux_idcanal_e  = pc_busca_tbcadast.pr_idcanal
                              WHEN pc_busca_tbcadast.pr_idcanal <> ?
               aux_dscanal_e  = pc_busca_tbcadast.pr_dscanal
                              WHEN pc_busca_tbcadast.pr_dscanal <> ?
               aux_dtrevisa_e = pc_busca_tbcadast.pr_dtrevisa
                              WHEN pc_busca_tbcadast.pr_dtrevisa <> ?
               aux_dscritic_e = pc_busca_tbcadast.pr_dscritic
                              WHEN pc_busca_tbcadast.pr_dscritic <> ?.
                             
        /* Se retornou erro */
        IF aux_dscritic <> "" THEN 
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, /** Sequencia **/
                             INPUT 0,
                             INPUT-OUTPUT aux_dscritic).
          END.    

        ASSIGN tt-comercial.dssituae = aux_dssituac_e
               tt-comercial.dscanale = aux_dscanal_e
               tt-comercial.dtrevise = aux_dtrevisa_e.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        /* Efetuar a chamada a rotina Oracle */
        RUN STORED-PROCEDURE pc_busca_tbcadast
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.nrcpfcgc /* Cpf */
                                            ,INPUT par_idseqttl     /* Numero sequencial  */
                                            ,INPUT "RENDA"          /* Tabela que será buscada */ 
                                            ,OUTPUT 0               /* Codigo da situacao */
                                            ,OUTPUT ""              /* Descricao da situacao   */
                                            ,OUTPUT 0               /* Codigo do Canal    */
                                            ,OUTPUT ""              /* Descricao do Canal */
                                            ,OUTPUT ?               /* Data da Revisao    */
                                            ,OUTPUT "").            /* Descrição da crítica    */
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_busca_tbcadast
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        ASSIGN aux_dssituac_r = pc_busca_tbcadast.pr_dssituac
                              WHEN pc_busca_tbcadast.pr_dssituac <> ?
               aux_idcanal_r  = pc_busca_tbcadast.pr_idcanal
                              WHEN pc_busca_tbcadast.pr_idcanal <> ?
               aux_dscanal_r  = pc_busca_tbcadast.pr_dscanal
                              WHEN pc_busca_tbcadast.pr_dscanal <> ?
               aux_dtrevisa_r = pc_busca_tbcadast.pr_dtrevisa
                              WHEN pc_busca_tbcadast.pr_dtrevisa <> ?
               aux_dscritic_r = pc_busca_tbcadast.pr_dscritic
                              WHEN pc_busca_tbcadast.pr_dscritic <> ?.
                             
        /* Se retornou erro */
        IF aux_dscritic <> "" THEN 
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, /** Sequencia **/
                             INPUT 0,
                             INPUT-OUTPUT aux_dscritic).
          END.    

        ASSIGN tt-comercial.dssituar = aux_dssituac_r
               tt-comercial.dscanalr = aux_dscanal_r
               tt-comercial.dtrevisr = aux_dtrevisa_r. 
        
        IF  par_cddopcao = "A" THEN
            ASSIGN
                tt-comercial.cdempres    = par_cdempres
                tt-comercial.cdnatopc    = par_cdnatopc
                tt-comercial.cdocpttl    = par_cdocpttl
                tt-comercial.tpcttrab    = par_tpcttrab
                tt-comercial.dsproftl    = par_dsproftl
                tt-comercial.cdnvlcgo    = par_cdnvlcgo
                tt-comercial.cdturnos    = par_cdturnos
                tt-comercial.dtadmemp    = par_dtadmemp
                tt-comercial.vlsalari    = par_vlsalari
                tt-comercial.nrcadast    = par_nrcadast
                tt-comercial.tpdrendi[1] = par_tpdrendi
                tt-comercial.vldrendi[1] = par_vldrendi
                tt-comercial.tpdrendi[2] = par_tpdrend2
                tt-comercial.vldrendi[2] = par_vldrend2
                tt-comercial.tpdrendi[3] = par_tpdrend3
                tt-comercial.vldrendi[3] = par_vldrend3
                tt-comercial.tpdrendi[4] = par_tpdrend4
                tt-comercial.vldrendi[4] = par_vldrend4
                tt-comercial.inpolexp    = par_inpolexp.

        
		/*Regra removida solicitacao Andrino (PRJ339)*/
        /*IF  tt-comercial.tpcttrab <> 3 THEN
            DO:*/ 
               /* Endereco */
               FOR LAST crapenc FIELDS(nrcepend dsendere nrendere complend 
                                       nmbairro nmcidade cdufende nrcxapst)
                                WHERE crapenc.cdcooper = par_cdcooper   AND
                                      crapenc.nrdconta = par_nrdconta   AND
                                      crapenc.idseqttl = par_idseqttl   AND
                                      crapenc.tpendass = 9 /* Cml */ NO-LOCK:
    
                   ASSIGN 
                       tt-comercial.cepedct1 = crapenc.nrcepend
                       tt-comercial.endrect1 = crapenc.dsendere
                       tt-comercial.nrendcom = crapenc.nrendere
                       tt-comercial.complcom = crapenc.complend
                       tt-comercial.bairoct1 = crapenc.nmbairro
                       tt-comercial.cidadct1 = crapenc.nmcidade
                       tt-comercial.ufresct1 = crapenc.cdufende
                       tt-comercial.cxpotct1 = crapenc.nrcxapst.
               END.
            /*END.*/

        /* empresa */
        FOR FIRST crapemp FIELDS(cdcooper nmextemp nrcepend dsendemp nrendemp
                                 dscomple nmbairro nmcidade cdufdemp nrdocnpj
                                 nmresemp cdempres)
                          WHERE crapemp.cdcooper = par_cdcooper AND
                                crapemp.cdempres = tt-comercial.cdempres 
                                NO-LOCK:

            ASSIGN tt-comercial.nmresemp = crapemp.nmresemp.

            /* Empresas diversas */
            IF par_cddopcao <> "C" AND 
               par_cddopcao <> "CA" THEN
            DO:
            
            IF  crapemp.cdempres <> 81   AND
                crapemp.cdempres <> 9998 AND
                NOT(crapemp.cdcooper = 2 AND crapemp.cdempres = 88) THEN
                DO:
                   ASSIGN
                       tt-comercial.nmextemp = crapemp.nmextemp
                         tt-comercial.nrcpfemp = STRING(crapemp.nrdocnpj,
                                                        "99999999999999")
                       tt-comercial.cepedct1 = crapemp.nrcepend
                       tt-comercial.endrect1 = CAPS(crapemp.dsendemp)
                       tt-comercial.nrendcom = crapemp.nrendemp
                       tt-comercial.complcom = CAPS(crapemp.dscomple)
                       tt-comercial.bairoct1 = CAPS(crapemp.nmbairro)
                       tt-comercial.cidadct1 = CAPS(crapemp.nmcidade)
                       tt-comercial.ufresct1 = CAPS(crapemp.cdufdemp)
                       tt-comercial.cxpotct1 = 0.
                END.
        END.
        END.

        IF  NOT AVAILABLE crapemp THEN
            ASSIGN tt-comercial.nmresemp = "NAO CADASTRADA".

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* tipos de rendimento */
        DYNAMIC-FUNCTION ("BuscaTipoRendimento" IN h-b1wgen0060,
                          INPUT par_cdcooper,
                          INPUT tt-comercial.tpdrendi[1],
                         OUTPUT aux_dsdrendi,
                         OUTPUT aux_criticas ).

        ASSIGN tt-comercial.dsdrendi[1] = aux_dsdrendi.

        DYNAMIC-FUNCTION ("BuscaTipoRendimento" IN h-b1wgen0060,
                          INPUT par_cdcooper,
                          INPUT tt-comercial.tpdrendi[2],
                         OUTPUT aux_dsdrendi,
                         OUTPUT aux_criticas ).

        ASSIGN tt-comercial.dsdrendi[2] = aux_dsdrendi.

        DYNAMIC-FUNCTION ("BuscaTipoRendimento" IN h-b1wgen0060,
                          INPUT par_cdcooper,
                          INPUT tt-comercial.tpdrendi[3],
                         OUTPUT aux_dsdrendi,
                         OUTPUT aux_criticas ).

        ASSIGN tt-comercial.dsdrendi[3] = aux_dsdrendi.

        DYNAMIC-FUNCTION ("BuscaTipoRendimento" IN h-b1wgen0060,
                          INPUT par_cdcooper,
                          INPUT tt-comercial.tpdrendi[4],
                         OUTPUT aux_dsdrendi,
                         OUTPUT aux_criticas ).

        ASSIGN tt-comercial.dsdrendi[4] = aux_dsdrendi.

        /* busca turnos */
        DYNAMIC-FUNCTION("BuscaTurnos" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-comercial.cdturnos,
                        OUTPUT tt-comercial.dsturnos,
                        OUTPUT aux_criticas).

        /* natureza da ocupacao */
        DYNAMIC-FUNCTION("BuscaNatOcupacao" IN h-b1wgen0060,
                         INPUT tt-comercial.cdnatopc,
                        OUTPUT tt-comercial.rsnatocp,
                        OUTPUT aux_criticas).
        
        /* ocupacao */
        DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                         INPUT tt-comercial.cdocpttl,
                        OUTPUT tt-comercial.rsocupa,
                        OUTPUT aux_criticas).

        /* nivel do cargo */
        DYNAMIC-FUNCTION("BuscaNivelCargo" IN h-b1wgen0060,
                         INPUT tt-comercial.cdnvlcgo,
                        OUTPUT tt-comercial.rsnvlcgo,
                        OUTPUT aux_criticas).

        /* tipo contrato trabalho */
        DYNAMIC-FUNCTION("BuscaTpContrTrab" IN h-b1wgen0060,
                         INPUT tt-comercial.tpcttrab,
                        OUTPUT tt-comercial.dsctrtab,
                        OUTPUT aux_criticas).


        /*Alteração: Busco o CPF para usa como parametro na Busca_Conta
                     (Gabriel - DB1) */
        FOR FIRST crapttl FIELDS(nrcpfcgc)
                           WHERE crapttl.cdcooper = par_cdcooper AND
                                 crapttl.nrdconta = par_nrdconta AND
                                 crapttl.idseqttl = par_idseqttl NO-LOCK:
                ASSIGN aux_nrcpfcto = crapttl.nrcpfcgc.
        END.
        
        /*Alteração:  Rotina para controle/replicacao entre contas 
                      (Gabriel - DB1)*/
        IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
            RUN sistema/generico/procedures/b1wgen0077.p 
                PERSISTENT SET h-b1wgen0077.

        RUN Busca_Conta IN h-b1wgen0077
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT aux_nrcpfcto,
              INPUT par_idseqttl,
             OUTPUT aux_nrdconta,
             OUTPUT par_msgconta,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic ).
        
        IF  VALID-HANDLE(h-b1wgen0077) THEN
            DELETE OBJECT h-b1wgen0077.

        LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatopc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpcttrab AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnvlcgo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ufresct1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdturnos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrendi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrendi AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend3 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend3 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend4 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend4 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cepedct1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_endrect1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inpolexp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Comercial"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        /* natureza da ocupacao */
        IF  NOT CAN-FIND(gncdnto WHERE gncdnto.cdnatocp = par_cdnatopc) OR 
            par_cdnatopc = 99                                           THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdnatopc"
                   aux_cdcritic = 827.
               LEAVE Valida.
            END.

        /* ocupacao */
        IF  NOT CAN-FIND(gncdocp WHERE gncdocp.cdocupa = par_cdocpttl) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdocpttl"
                   aux_dscritic = "Ocupacao invalida.".
               LEAVE Valida.
            END.

        /* tipo do contrato de trabalho */
        IF  NOT CAN-DO("1,2,3,4",STRING(par_tpcttrab,"9")) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "tpcttrab"
                   aux_dscritic = "Tipo de contrato de trabalho invalido.".
               LEAVE Valida.
            END.
                 
        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
						   crapttl.nrdconta = par_nrdconta AND
						   crapttl.idseqttl = par_idseqttl 
						   NO-LOCK NO-ERROR.
		IF AVAIL crapttl THEN
		DO:
			IF  STRING(par_nrcpfemp) = STRING(crapttl.nrcpfcgc) THEN
				DO:
				   ASSIGN 
					   par_nmdcampo = "nrcpfemp"
					   aux_cdcritic = 0.
					   aux_dscritic = "CNPJ da empresa nao pode ser o CPF da conta".
					   
				   LEAVE Valida.
				END.
		END.	
		
         /* [PJ485.6] Validaçoes para empregador PF */
         IF par_cdempres = 9998 THEN
         DO:
            IF TRIM(par_nrcpfemp) = "0" THEN
            DO:
               ASSIGN aux_dscritic = "CPF do empregador deve ser informado."
                      par_nmdcampo = "nrcpfemp".
               LEAVE Valida.
            END.
            IF  TRIM(par_nmextemp) = "" THEN
            DO:
               ASSIGN aux_dscritic = "Nome do empregador deve ser informado."
                      par_nmdcampo = "nmextemp".
               LEAVE Valida.
            END.
         END.
		
        /* efetuar validacoes quando o contrato de trabalho for = 1 ou 2 */
        IF  par_tpcttrab = 3   OR
            par_tpcttrab = 4   THEN
            LEAVE Valida.

        /* se o TPCTTRAB for igual a 3 nao precisa validar os campos abaixo */

        /* validacoes p/ tpcttrab = 1 ou = 2 */
        IF DECI(par_nrcpfemp) > 0 AND (par_nmextemp = "" OR 
            NOT CAN-FIND(crapemp WHERE crapemp.cdcooper = par_cdcooper AND 
                                       crapemp.cdempres = par_cdempres)) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdempres"
                   aux_cdcritic = 40.
               LEAVE Valida.
            END.
            
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

          RUN STORED-PROCEDURE pc_valida_emp_conta_salario
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                               INPUT par_nrdconta, /* Número da conta */
                                               INPUT DECI(par_nrcpfemp), /*CNPJ da empresa*/
                                               INPUT par_cdempres, /*Código da empresa*/
                                               OUTPUT ""). /* Descriçao da crítica */

          CLOSE STORED-PROC pc_valida_emp_conta_salario
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
              
          { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_dscritic = pc_valida_emp_conta_salario.pr_dscritic
            WHEN pc_valida_emp_conta_salario.pr_dscritic <> ?.

          IF aux_dscritic <> ""  THEN
            DO:
               ASSIGN par_nmdcampo = "cdtipcta"
                      aux_cdcritic = 0.
              LEAVE Valida.
            END.

        /* cnpj da empresa */
        IF  NOT ValidaCpfCnpj(STRING(par_nrcpfemp)) AND 
            DECI(par_nrcpfemp) <> 0 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nrcpfemp"
                   aux_cdcritic = 27.
               LEAVE Valida.
            END.

					   
        /* funcao */
        IF  par_dsproftl = "" THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "dsproftl"
                   aux_cdcritic = 44.
               LEAVE Valida.
            END.

        ASSIGN aux_cdcritic = 0.
        /* validar o nome da funcao */
        IF  NOT ValidaNome(par_dsproftl, OUTPUT aux_cdcritic) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "dsproftl"
                   aux_cdcritic = 0
                   aux_dscritic = "Campo 'FUNCAO' preenchido com caracteres " +
                                  "invalidos, use somente letras".
               LEAVE Valida.
            END.

        /* Nivel de cargo */
        IF  NOT CAN-FIND(gncdncg WHERE gncdncg.cdnvlcgo = par_cdnvlcgo) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdnvlcgo"
                   aux_dscritic = "Nivel do cargo nao cadastrado".
               LEAVE Valida.
            END.

        /* Turnos */
        IF  NOT CAN-FIND(craptab WHERE craptab.cdcooper = par_cdcooper AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "GENERI"     AND
                                       craptab.cdempres = 0            AND
                                       craptab.cdacesso = "DSCDTURNOS" AND
                                       craptab.tpregist = par_cdturnos) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdturnos"
                   aux_cdcritic = 43.
               LEAVE Valida.
            END.

        /* data de admissao na empresa */
        IF  par_dtadmemp > par_dtmvtolt OR par_dtadmemp = ? THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "dtadmemp"
                   aux_dscritic = "A data de admissao na empresa esta " + 
                                  "incorreta".
               LEAVE Valida.
            END.

        /* rendimentos */
        IF  par_cdturnos <> 0 AND par_vlsalari = 0 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "vlsalari"
                   aux_cdcritic = 269.
               LEAVE Valida.
            END.

		/*P437 Nao validar o campo matricula (par_nrcadast) removida validaçao DV*/

        /* validar a UF - pode ser vazio, nao eh obrigatorio */
        IF  NOT CAN-DO("AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                       "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                       "RS,RO,RR,SC,SP,SE,TO,",par_ufresct1) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "ufresct"
                   aux_cdcritic = 33.
               LEAVE Valida.
            END.

        /* outros rendimentos */
        IF  par_tpdrendi <> 0 AND par_vldrendi = 0 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "vldrendi"
                   aux_dscritic = "Informe o valor de outros rendimentos.".
               LEAVE Valida.
            END.
        ELSE
            /* validar o valor do rendimento */
            IF  par_vldrendi > 999999.99 THEN
                DO:
                  ASSIGN 
                      par_nmdcampo = "vldrendi"
                      aux_dscritic = "Valor do rendimento maior que o " + 
                                     "permitido".
                  LEAVE Valida.
                END.

       /* demais rendimentos */
       IF  par_tpdrend2 <> 0 AND par_vldrend2 = 0 THEN
           DO:
              ASSIGN 
                  par_nmdcampo = "vldrend2"
                  aux_dscritic = "Informe o valor de outros rendimentos 2.".
              LEAVE Valida.
           END.
       ELSE
           /* validar o valor do rendimento */
           IF  par_vldrend2 > 999999.99 THEN
               DO:
                 ASSIGN 
                     par_nmdcampo = "vldrend2"
                     aux_dscritic = "Valor do rendimento 2 maior que o " + 
                                    "permitido".
                 LEAVE Valida.
               END.

       IF  par_tpdrend3 <> 0 AND par_vldrend3 = 0 THEN
           DO:
              ASSIGN 
                  par_nmdcampo = "vldrend3"
                  aux_dscritic = "Informe o valor de outros rendimentos 3.".
              LEAVE Valida.
           END.
       ELSE
           /* validar o valor do rendimento */
           IF  par_vldrend3 > 999999.99 THEN
               DO:
                 ASSIGN 
                     par_nmdcampo = "vldrend3"
                     aux_dscritic = "Valor do rendimento 3 maior que o " + 
                                    "permitido".
                 LEAVE Valida.
               END.

       IF  par_tpdrend4 <> 0 AND par_vldrend4 = 0 THEN
           DO:
              ASSIGN 
                  par_nmdcampo = "vldrend4"
                  aux_dscritic = "Informe o valor de outros rendimentos 4.".
              LEAVE Valida.
           END.
       ELSE
           /* validar o valor do rendimento */
           IF  par_vldrend4 > 999999.99 THEN
               DO:
                 ASSIGN 
                     par_nmdcampo = "vldrend4"
                     aux_dscritic = "Valor do rendimento 4 maior que o " + 
                                     "permitido".
                 LEAVE Valida.
               END.

        /* Validação CEP existente (André - DB1) */
       IF  par_cepedct1 <> 0  AND 
         ((par_cdcooper = 2   AND 
           par_cdempres = 88) OR 
           par_cdempres = 81) THEN
           DO:
               IF NOT CAN-FIND(FIRST crapdne 
                               WHERE crapdne.nrceplog = par_cepedct1)  THEN
                   DO:
                       ASSIGN
                           par_nmdcampo = "cepedct1"
                           aux_dscritic = "CEP nao cadastrado.".
                       LEAVE Valida.
                   END.
               IF  NOT CAN-FIND(FIRST crapdne 
                                WHERE crapdne.nrceplog = par_cepedct1  
                                  AND (TRIM(par_endrect1) MATCHES 
                                      ("*" + TRIM(crapdne.nmextlog) + "*")
                                   OR TRIM(par_endrect1) MATCHES
                                      ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
                   DO:
                       ASSIGN aux_dscritic = "Endereco nao pertence ao CEP."
                              par_nmdcampo = "endrect1".
                       LEAVE Valida.
                   END.
           END.

       LEAVE Valida.
    END.
    

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Grava_Dados:

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
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdnatopc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpcttrab AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnvlcgo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ufresct1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_endrect1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_bairoct1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cidadct1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_complcom AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cepedct1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cxpotct1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdturnos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsecao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendcom AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrendi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrendi AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend3 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrend4 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend3 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldrend4 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inpolexp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cotcance AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdseqinc AS INTE                                    NO-UNDO.
    DEF VAR aux_cdempres AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtroca AS LOG                                     NO-UNDO.
    DEF VAR aux_flgpagto AS LOG                                     NO-UNDO.
    DEF VAR aux_rowidenc AS ROWID                                   NO-UNDO.
	DEF VAR aux_nmpesout AS CHAR                                    NO-UNDO.
	DEF VAR aux_nrcnpjot AS DECI                                    NO-UNDO.
    DEF VAR aux_nrcpfemp AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsalari AS DECI                                    NO-UNDO.
	
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0137 AS HANDLE                                  NO-UNDO.
    
    DEF BUFFER crabpla  FOR crappla.
    DEF BUFFER crabavs  FOR crapavs.
    DEF BUFFER crabepr  FOR crapepr.
    DEF BUFFER bcrapttl FOR crapttl.
    DEF BUFFER b-crapdoc FOR crapdoc.

    &SCOPED-DEFINE CAMPOS-TTL cdnatopc cdocpttl tpcttrab nmextemp nrcpfemp dsproftl cdnvlcgo dtadmemp vlsalari cdturnos nrcadast cdempres tpdrendi vldrendi inpolexp

    &SCOPED-DEFINE CAMPOS-ENC cdufende nmbairro nmcidade complend dsendere nrcepend nrcxapst tpendass nrendere
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados Comerciais"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        /* Dados do Titular */
        ContadorTtl: DO aux_contador = 1 TO 10:

            FIND crapttl WHERE ROWID(crapttl) = par_nrdrowid
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapttl THEN
                DO:
                   IF  LOCKED(crapttl) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 ASSIGN aux_cdcritic = 341.
                                 LEAVE ContadorTtl.
                              END.
                          ELSE 
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorTtl.
                              END.
                       END.
                   ELSE
                       DO:
                          ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                                                " encontrados.".
                          LEAVE ContadorTtl.
                       END.
                END.
            ELSE
                LEAVE ContadorTtl.
        END.
        
        CREATE tt-comercial-ant.
        ASSIGN tt-comercial-ant.cdnatopc = crapttl.cdnatopc
               tt-comercial-ant.cdocpttl = crapttl.cdocpttl                	
               tt-comercial-ant.tpcttrab = crapttl.tpcttrab                	
               tt-comercial-ant.cdempres = crapttl.cdempres                	
               tt-comercial-ant.nrcpfemp = STRING(crapttl.nrcpfemp)              	
               tt-comercial-ant.dsproftl = crapttl.dsproftl		
               tt-comercial-ant.cdnvlcgo = crapttl.cdnvlcgo  		
               tt-comercial-ant.nrcadast = crapttl.nrcadast  	
               tt-comercial-ant.dtadmemp = crapttl.dtadmemp
               tt-comercial-ant.vlsalari = crapttl.vlsalari  	
               tt-comercial-ant.tpdrendi[1] = crapttl.tpdrendi[1]  	
               tt-comercial-ant.tpdrendi[2] = crapttl.tpdrendi[2]  	
               tt-comercial-ant.tpdrendi[3] = crapttl.tpdrendi[3]  	
               tt-comercial-ant.tpdrendi[4] = crapttl.tpdrendi[4]  	
               tt-comercial-ant.vldrendi[1] = crapttl.vldrendi[1] 	
               tt-comercial-ant.vldrendi[2] = crapttl.vldrendi[2] 	
               tt-comercial-ant.vldrendi[3] = crapttl.vldrendi[3] 	
               tt-comercial-ant.vldrendi[4] = crapttl.vldrendi[4] 	
               tt-comercial-ant.cdturnos  = crapttl.cdturnos
               tt-comercial-ant.inpolexp  = crapttl.inpolexp.                   

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                crapenc.nrdconta = par_nrdconta   AND
                                crapenc.idseqttl = par_idseqttl   AND
                                crapenc.tpendass = 9 /* Comercial */
                                NO-LOCK NO-ERROR.

        IF  AVAILABLE crapenc THEN
            ASSIGN aux_rowidenc = ROWID(crapenc).
        ELSE 
            ASSIGN aux_rowidenc = ?.

        /* Endereco Comercial */
        ContadorEnc: DO aux_contador = 1 TO 10:

            FIND crapenc WHERE ROWID(crapenc) = aux_rowidenc
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapenc THEN
                DO:
                   IF  LOCKED(crapenc) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 ASSIGN aux_cdcritic = 341.
                                 LEAVE ContadorEnc.
                              END.
                          ELSE 
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorEnc.
                              END.
                       END.
                   ELSE
                       DO:
					      IF par_cepedct1 <> 0 THEN
						     DO:
                                ASSIGN aux_cdseqinc = 1.
                                /* Pegar o sequencial */
                                FOR LAST crapenc FIELDS(cdseqinc) WHERE 
                                                 crapenc.cdcooper = par_cdcooper AND
                                                 crapenc.nrdconta = par_nrdconta AND
                                                 crapenc.idseqttl = par_idseqttl
                                                 NO-LOCK:
                                    ASSIGN aux_cdseqinc = crapenc.cdseqinc + 1.
                                END.
                                
                                CREATE crapenc.
                                ASSIGN
                                    crapenc.cdcooper = par_cdcooper
                                    crapenc.nrdconta = par_nrdconta
                                    crapenc.idseqttl = par_idseqttl
                                    crapenc.tpendass = 9           
                                    crapenc.dsendere = CAPS(par_endrect1)
                                    crapenc.nrendere = par_nrendcom
                                    crapenc.cdseqinc = aux_cdseqinc NO-ERROR.
                                VALIDATE crapenc.  
                                
                                IF  ERROR-STATUS:ERROR THEN
                                    aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                
                                LEAVE ContadorEnc.
							 END.
                       END.
                END.
            ELSE
            DO:
            
              IF par_cdnatopc = 12 THEN
              DO:                
                DELETE crapenc.
              END.
              
                LEAVE ContadorEnc.
            END.
        END.
        
        IF par_cepedct1 <> 0 THEN
		   DO:
		      ASSIGN tt-comercial-ant.cepedct1 = crapenc.nrcepend
                     tt-comercial-ant.endrect1 = crapenc.dsendere
                     tt-comercial-ant.nrendcom = crapenc.nrendere
                     tt-comercial-ant.complcom = crapenc.complend
                     tt-comercial-ant.bairoct1 = crapenc.nmbairro
                     tt-comercial-ant.cidadct1 = crapenc.nmcidade
                     tt-comercial-ant.ufresct1 = crapenc.cdufende
                     tt-comercial-ant.cxpotct1 = crapenc.nrcxapst.
	       END.		 

        VALIDATE tt-comercial-ant.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
        
        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.
                   
        /* Caso possua valor informardo e for diferente do anterior */
        IF (par_vlsalari <> 0 OR par_nmextemp <> "") AND  
           (crapttl.vlsalari <> par_vlsalari OR 
            crapttl.nmextemp <> par_nmextemp) THEN
            DO:
                IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                    RUN sistema/generico/procedures/b1wgen0137.p 
                    PERSISTENT SET h-b1wgen0137.
    
                RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                          ( INPUT par_cdcooper,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT crapttl.nrcpfcgc,
                            INPUT par_dtmvtolt,
                            INPUT "5", /* COMPROVANTE DE RENDA */
                            INPUT par_cdoperad,
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic).
    
                IF  VALID-HANDLE(h-b1wgen0137) THEN
                  DELETE OBJECT h-b1wgen0137.

            END. 

        IF aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.
        
		{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
		
		RUN STORED-PROCEDURE pc_revalida_cnpj_cad_unc
			aux_handproc = PROC-HANDLE NO-ERROR
									(INPUT DECIMAL(par_cdcooper),
									 INPUT DECIMAL(par_cdempres),
									 INPUT DECIMAL(par_nrcpfemp),
									 OUTPUT 0,
									 OUTPUT 0,           /* Código da crítica */
									 OUTPUT "").         /* Descrição da crítica */
		
		CLOSE STORED-PROC pc_revalida_cnpj_cad_unc
			aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
	
		{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
		
		ASSIGN aux_cdcritic = 0
			   aux_dscritic = ""
			   aux_nrcnpjot = 0
			   aux_cdcritic = pc_revalida_cnpj_cad_unc.pr_cdcritic WHEN pc_revalida_cnpj_cad_unc.pr_cdcritic <> ?
			   aux_dscritic = pc_revalida_cnpj_cad_unc.pr_dscritic WHEN pc_revalida_cnpj_cad_unc.pr_dscritic <> ?
			   aux_nrcnpjot = pc_revalida_cnpj_cad_unc.pr_nrcnpjot WHEN pc_revalida_cnpj_cad_unc.pr_nrcnpjot <> ?.
		
		IF aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.
		
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
		
		RUN STORED-PROCEDURE pc_revalida_nome_cad_unc
			aux_handproc = PROC-HANDLE NO-ERROR
									(INPUT par_nrcpfemp,
									 INPUT par_nmextemp,
									 OUTPUT "",
									 OUTPUT 0,           /* Código da crítica */
									 OUTPUT "").         /* Descrição da crítica */
		
		CLOSE STORED-PROC pc_revalida_nome_cad_unc
			aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
	
		{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
		
		ASSIGN aux_cdcritic = 0
			   aux_dscritic = ""
			   aux_nmpesout = ""
			   aux_cdcritic = pc_revalida_nome_cad_unc.pr_cdcritic WHEN pc_revalida_nome_cad_unc.pr_cdcritic <> ?
			   aux_dscritic = pc_revalida_nome_cad_unc.pr_dscritic WHEN pc_revalida_nome_cad_unc.pr_dscritic <> ?
			   aux_nmpesout = pc_revalida_nome_cad_unc.pr_nmpesout WHEN pc_revalida_nome_cad_unc.pr_nmpesout <> ?.
	    
		IF aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.           
		
        ASSIGN aux_nrcpfemp = crapttl.nrcpfemp
               aux_vlsalari = crapttl.vlsalari.
		
        ASSIGN 
            aux_cdempres        = crapttl.cdempres
            crapttl.cdnatopc    = par_cdnatopc
            crapttl.cdocpttl    = par_cdocpttl
            crapttl.tpcttrab    = par_tpcttrab
            crapttl.nmextemp    = CAPS(SUBSTR(aux_nmpesout,1,40))
            crapttl.nrcpfemp    = aux_nrcnpjot
            crapttl.dsproftl    = CAPS(par_dsproftl)
            crapttl.cdnvlcgo    = par_cdnvlcgo
            crapttl.dtadmemp    = par_dtadmemp
            crapttl.vlsalari    = par_vlsalari
            crapttl.cdturnos    = par_cdturnos
            crapttl.nrcadast    = par_nrcadast
            crapttl.cdempres    = par_cdempres
            crapttl.tpdrendi[1] = par_tpdrendi
            crapttl.tpdrendi[2] = par_tpdrend2
            crapttl.tpdrendi[3] = par_tpdrend3
            crapttl.tpdrendi[4] = par_tpdrend4
            crapttl.vldrendi[1] = par_vldrendi
            crapttl.vldrendi[2] = par_vldrend2
            crapttl.vldrendi[3] = par_vldrend3
            crapttl.vldrendi[4] = par_vldrend4
            crapttl.inpolexp    = par_inpolexp NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               UNDO Grava, LEAVE Grava.
            END.

        IF  (par_vlsalari <> 0 OR par_nrcpfemp <> 0) AND  
            (aux_vlsalari <> par_vlsalari OR 
             aux_nrcpfemp <> par_nrcpfemp) THEN
            DO:
        IF  crapass.inpessoa = 1 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                /* Efetuar a chamada a rotina Oracle */
                RUN STORED-PROCEDURE pc_retorna_IdPessoa
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.nrcpfcgc            
                                                    ,OUTPUT 0 
                                                    ,OUTPUT "").               /* Descrição da crítica*/
                /* Fechar o procedimento para buscarmos o resultado */  
                CLOSE STORED-PROC pc_retorna_IdPessoa
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                ASSIGN aux_dscritic = pc_retorna_IdPessoa.pr_dscritic
                                  WHEN pc_retorna_IdPessoa.pr_dscritic <> ?.
                /* Se retornou erro */
                IF aux_dscritic <> "" THEN 
                  DO:
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /** Sequencia **/
                                     INPUT 0,
                                     INPUT-OUTPUT aux_dscritic).
                  END.

                        IF  (par_vlsalari <> 0) AND (aux_vlsalari <> par_vlsalari) THEN
                            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                /* Efetuar a chamada a rotina Oracle */
                RUN STORED-PROCEDURE pc_confirma_pessoa_renda
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT pc_retorna_IdPessoa.pr_idpessoa
                                                    ,INPUT 1                /*Numero sequecial do endereço*/
                                                    ,INPUT 1                /*Situacao: 1 - Ativo/ 2 - Rejeitado*/
                                                    ,INPUT 3                /*Canal que efetuou a atualização*/
                                                    ,OUTPUT "").            /* Descrição da crítica*/
                /* Fechar o procedimento para buscarmos o resultado */  
                CLOSE STORED-PROC pc_confirma_pessoa_renda
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_dscritic = pc_confirma_pessoa_renda.pr_dscritic
                                  WHEN pc_confirma_pessoa_renda.pr_dscritic <> ?.
                /* Se retornou erro */
                IF aux_dscritic <> "" THEN 
                  DO:

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /** Sequencia **/
                                     INPUT 0,
                                     INPUT-OUTPUT aux_dscritic).
                  END.
                            END.

                        IF  (par_nrcpfemp <> 0) AND (aux_nrcpfemp <> par_nrcpfemp) THEN
                            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                /* Efetuar a chamada a rotina Oracle */
                RUN STORED-PROCEDURE pc_confirma_pessoa_empresa
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT pc_retorna_IdPessoa.pr_idpessoa
                                                    ,INPUT 1                /*Numero sequecial do endereço*/
                                                    ,INPUT 1                /*Situacao: 1 - Ativo/ 2 - Rejeitado*/
                                                    ,INPUT 3                /*Canal que efetuou a atualização*/
                                                    ,OUTPUT "").            /* Descrição da crítica*/
                /* Fechar o procedimento para buscarmos o resultado */  
                CLOSE STORED-PROC pc_confirma_pessoa_empresa
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_dscritic = pc_confirma_pessoa_empresa.pr_dscritic
                                  WHEN pc_confirma_pessoa_empresa.pr_dscritic <> ?.
                /* Se retornou erro */
                IF aux_dscritic <> "" THEN 
                  DO:
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /** Sequencia **/
                                     INPUT 0,
                                     INPUT-OUTPUT aux_dscritic).
                  END.
            END.
                    END.

            END.

        /* Se nao for politicamente exposto, excluir tabela 
        tbcadast_politico_exposto */
        IF par_inpolexp <> 1 THEN
        DO:
            FOR EACH tbcadast_politico_exposto WHERE 
                tbcadast_politico_exposto.cdcooper = par_cdcooper AND
                tbcadast_politico_exposto.nrdconta = par_nrdconta AND
                tbcadast_politico_exposto.idseqttl = par_idseqttl
                EXCLUSIVE-LOCK:
                
                DELETE tbcadast_politico_exposto.
            END.
        END.
                 
        IF tt-comercial-ant.inpolexp <> par_inpolexp AND
           par_inpolexp = 1 /*Politicamente exposto SIM*/ THEN
        DO:
            IF par_idseqttl = 1 THEN        
            DO: 
                /*******************************************************************
                 ************ se entrou aqui entao nao veio pelo Replica ***********
                 *******************************************************************/                
                
                /* Replicar informacoes de pessoa politicamente exposta para todas 
                   contas onde o cooperado eh primeiro titular */
                FOR EACH bcrapttl WHERE bcrapttl.nrcpfcgc = crapttl.nrcpfcgc
                                    AND bcrapttl.idseqttl = 1
                                    AND bcrapttl.nrdconta <> crapttl.nrdconta
                                    EXCLUSIVE-LOCK:
                                   
                    ASSIGN bcrapttl.inpolexp = par_inpolexp.
                                   
                END.
            END.
        END.   

        ASSIGN aux_contador = 1.
        
        /* Verifica se o titular em questao eh conjuge ... */
        IF CAN-FIND(FIRST crapcje WHERE crapcje.cdcooper = crapttl.cdcooper AND
                                        crapcje.nrdconta = crapttl.nrdconta AND
                                        crapcje.nrcpfcjg = crapttl.nrcpfcgc NO-LOCK) THEN
        DO:
            DO WHILE TRUE:
                FIND crapcje WHERE crapcje.cdcooper = crapttl.cdcooper AND
                                   crapcje.nrdconta = crapttl.nrdconta AND
                                   crapcje.nrcpfcjg = crapttl.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF NOT AVAIL crapcje THEN
                DO:
                    IF LOCKED crapcje THEN
                    DO:
                        IF aux_contador = 10 THEN
                        DO:
                            ASSIGN aux_dscritic = "Tabela crapcje em uso.".
                            LEAVE.
                        END.
                        ELSE
                        DO:
                            ASSIGN aux_contador = aux_contador + 1.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    END.
    
                    LEAVE.
                END.
                
                ASSIGN crapcje.cdnatopc = crapttl.cdnatopc
                       crapcje.cdnvlcgo = crapttl.cdnvlcgo
                       crapcje.cdturnos = crapttl.cdturnos
                       crapcje.dsproftl = crapttl.dsproftl
                       crapcje.dtadmemp = crapttl.dtadmemp
                       crapcje.nmextemp = crapttl.nmextemp
                       crapcje.tpcttrab = crapttl.tpcttrab
                       crapcje.vlsalari = crapttl.vlsalari NO-ERROR.
    
                LEAVE.
            END.
        END.

        IF aux_dscritic <> "" THEN
        DO:
            UNDO Grava, LEAVE Grava.
        END.

        IF ERROR-STATUS:ERROR THEN
        DO:
            ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
            UNDO Grava, LEAVE Grava.
        END.
         
        IF par_cepedct1 <> 0 THEN
		   DO:
		      ASSIGN
                 crapenc.cdufende = CAPS(par_ufresct1)
                 crapenc.nmbairro = CAPS(par_bairoct1)
                 crapenc.nmcidade = CAPS(par_cidadct1)
                 crapenc.complend = CAPS(par_complcom)
                 crapenc.dsendere = CAPS(par_endrect1)
                 crapenc.nrcepend = par_cepedct1
                 crapenc.nrcxapst = par_cxpotct1
                 crapenc.nrendere = par_nrendcom NO-ERROR.
		   END.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               UNDO Grava, LEAVE Grava.
            END.

        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.
        
            
        /* Se for primeiro titular, atualiza o nrcadast na crapass */
        IF  crapttl.idseqttl = 1 AND crapttl.tpcttrab <> 3 THEN
            DO:
               /* Cadastro do Associado */
               ContadorAss: DO aux_contador = 1 TO 10:
                   FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                      crapass.nrdconta = par_nrdconta
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                   IF  NOT AVAILABLE crapass THEN
                       DO:
                           IF  LOCKED(crapass) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN aux_cdcritic = 72.
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
                                  ASSIGN aux_cdcritic = 9.
                                  LEAVE ContadorAss.
                               END.
                       END.
                   ELSE
                       LEAVE ContadorAss.
               END.
    
               IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                   UNDO Grava, LEAVE Grava.

               IF  aux_cdempres     <> crapttl.cdempres OR
                   crapass.nrcadast <> crapttl.nrcadast THEN
                   DO:
                      IF  aux_cdempres <> crapttl.cdempres THEN
                          DO:  
                             ASSIGN aux_flgtroca = TRUE.

                             /* buscar dados da empresa antiga */
                             FOR FIRST crapemp FIELDS(flgpagto flgpgtib)
                                 WHERE crapemp.cdcooper = crapass.cdcooper AND
                                       crapemp.cdempres = aux_cdempres NO-LOCK:

                                 ASSIGN aux_flgpagto = (crapemp.flgpagto OR crapemp.flgpgtib).
                             END.
    
                             /* buscar dados da nova empresa */
                             FOR FIRST crapemp FIELDS(flgpagto flgpgtib)
                                 WHERE crapemp.cdempres = crapttl.cdempres AND
                                       crapemp.cdcooper = crapass.cdcooper 
                                      NO-LOCK:

                                 IF  aux_flgpagto AND (NOT crapemp.flgpagto AND NOT crapemp.flgpgtib) THEN
                                     ASSIGN aux_flgtroca = TRUE.
                                 ELSE
                                     ASSIGN aux_flgtroca = FALSE.
                             END.

                             RUN sistema/generico/procedures/b1wgen0021.p
                                 PERSISTENT SET h-b1wgen0021.
    
                             /* atualiza planos de capitalização */
                             Plano: FOR EACH crappla 
                                 WHERE crappla.cdcooper = crapass.cdcooper AND
                                       crappla.nrdconta = crapass.nrdconta
                                       USE-INDEX crappla1 NO-LOCK:

                                 ContadorPla: DO aux_contador = 1 TO 10:

                                    FIND crabpla WHERE
                                        ROWID(crabpla) = ROWID(crappla) 
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAILABLE crabpla THEN
                                        DO:
                                           IF  LOCKED(crabpla) THEN
                                               DO:
                                                  IF  aux_contador = 10 THEN
                                                      DO:
                                                         aux_cdcritic = 341.
                                                         LEAVE ContadorPla.
                                                      END.
                                                  ELSE 
                                                      DO:
                                                         PAUSE 1 NO-MESSAGE.
                                                         NEXT ContadorPla.
                                                      END.
                                               END.
                                           ELSE
                                               LEAVE ContadorPla.
                                        END.
                                    ELSE 
                                        DO:
                                           IF  crabpla.cdsitpla = 1  AND 
                                               aux_flgtroca          AND
                                               crabpla.flgpagto     THEN
                                           DO:
                                               IF crabpla.dtinipla = 
                                                  par_dtmvtolt THEN
                                               DO:
                                                   RUN exclui-plano IN
                                                   h-b1wgen0021 (
                                                          INPUT par_cdcooper,
                                                          INPUT par_cdagenci,
                                                          INPUT par_nrdcaixa,
                                                          INPUT par_cdoperad,
                                                          INPUT par_nmdatela,
                                                          INPUT par_idorigem,
                                                          INPUT par_nrdconta,
                                                          INPUT par_idseqttl,
                                                         OUTPUT TABLE tt-erro).

                                                   IF RETURN-VALUE = "NOK" THEN
                                                   DO:
                                                       ASSIGN aux_retorno = "NOK".

                                                       UNDO Grava, LEAVE Grava.
                                                   END.
                                               END.
                                               ELSE
                                                   ASSIGN crabpla.cdsitpla = 2
                                                          crabpla.dtcancel = 
                                                                  par_dtmvtolt
                                                          crabpla.cdempres = 
                                                               crapttl.cdempres.

                                               ASSIGN par_cotcance = "Plano de"
                                               + " Cotas com vinculo em Folha "
                                               + "cancelado - Efetue novo Plano.".
                                           END.

                                           LEAVE ContadorPla.
                                        END.
                                 END. /* ContadorPla */
                                 
                                 IF  aux_dscritic <> ""  OR 
                                     aux_cdcritic <> 0   THEN
                                     UNDO Grava, LEAVE Grava.

                                 RELEASE crabpla.
                             END.  /*  Fim do FOR EACH crappla */

                             /*Altera empresa dos debitos automaticos*/
                             Aviso: FOR EACH crapavs 
                                 WHERE crapavs.cdcooper = crapass.cdcooper AND
                                       crapavs.tpdaviso = 1                AND
                                       crapavs.nrdconta = crapass.nrdconta
                                       USE-INDEX crapavs2 NO-LOCK:
                                 
                                 ContadorAvs: DO aux_contador = 1 TO 10:

                                     FIND crabavs WHERE
                                         ROWID(crabavs) = ROWID(crapavs) 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                     IF  NOT AVAILABLE crabavs THEN
                                         DO:
                                            IF  LOCKED(crabavs) THEN
                                                DO:
                                                   IF  aux_contador = 10 THEN
                                                       DO:
                                                          aux_cdcritic = 341.
                                                          LEAVE ContadorAvs.
                                                       END.
                                                   ELSE 
                                                       DO:
                                                          PAUSE 1 NO-MESSAGE.
                                                          NEXT ContadorAvs.
                                                       END.
                                                END.
                                            ELSE
                                                LEAVE ContadorAvs.
                                         END.
                                     ELSE
                                         DO:
                                           crabavs.cdempres = crapttl.cdempres.
                                           LEAVE ContadorAvs.
                                         END.
                                 END. /* ContadorAvs */

                                 IF  aux_dscritic <> ""  OR 
                                     aux_cdcritic <> 0   THEN
                                     UNDO Grava, LEAVE Grava.

                                 RELEASE crabavs.
                             END. /* Fim do FOR EACH crapavs  */

                          END. /* aux_cdempres <> crapttl.cdempres */

                      /*  Altera a empresa dos emprestimos  */
                      Emprestimo: FOR EACH crapepr WHERE 
                                       crapepr.cdcooper = crapass.cdcooper AND
                                       crapepr.nrdconta = crapass.nrdconta
                                       USE-INDEX crapepr2 NO-LOCK:
    
                          ContadorEpr: DO aux_contador = 1 TO 10:

                              FIND crabepr WHERE 
                                           ROWID(crabepr) = ROWID(crapepr)
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF  NOT AVAILABLE crabepr THEN
                                  DO:
                                     IF  LOCKED(crabepr) THEN
                                         DO:
                                            IF  aux_contador = 10 THEN
                                                DO:
                                                   aux_cdcritic = 341.
                                                   LEAVE ContadorEpr.
                                                END.
                                            ELSE 
                                                DO:
                                                   PAUSE 1 NO-MESSAGE.
                                                   NEXT ContadorEpr.
                                                END.
                                         END.
                                     ELSE
                                         LEAVE ContadorEpr.
                                  END.
                              ELSE
                                  DO:
                                     ASSIGN 
                                         crabepr.cdempres = crapttl.cdempres
                                         crabepr.nrcadast = crapttl.nrcadast.

                                     LEAVE ContadorEpr.
                                  END.
                          END. /* ContadorEpr */

                          IF  aux_dscritic <> ""  OR 
                              aux_cdcritic <> 0   THEN
                              UNDO Grava, LEAVE Grava.

                          RELEASE crabepr.
                      END.  /*  Fim do FOR EACH crapepr */    
                  END.

                  ASSIGN 
                      crapass.nrcadast = crapttl.nrcadast
                      crapass.dsproftl = crapttl.dsproftl
                      crapass.dtadmemp = crapttl.dtadmemp.

            END. /* IF crapttl.idseqttl = 1 AND crapttl.tpcttrab <> 3 */
         
        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
    
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "COMERCIAL",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.
               
               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Grava, LEAVE Grava.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.

               IF AVAILABLE bcrapttl THEN DO:

                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.

                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ).

                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.
               END.

            END.

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    RELEASE crapttl.
	
	IF par_cepedct1 <> 0 THEN
	   RELEASE crapenc.
    
	RELEASE crapass.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF VALID-HANDLE(h-b1wgen0021) THEN
        DELETE PROCEDURE h-b1wgen0021.

    IF  par_idseqttl = 1 THEN
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
                                                ,INPUT 1
                                                ,INPUT 0
                                                ,INPUT 0
                                                ,INPUT 0
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


    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

   CREATE tt-comercial-atl.
   
   FIND crapttl WHERE ROWID(crapttl) = par_nrdrowid NO-LOCK NO-ERROR NO-WAIT.
   IF AVAIL crapttl THEN
     DO:
       
       ASSIGN tt-comercial-atl.cdnatopc = crapttl.cdnatopc
              tt-comercial-atl.cdocpttl = crapttl.cdocpttl                	
              tt-comercial-atl.tpcttrab = crapttl.tpcttrab                	
              tt-comercial-atl.cdempres = crapttl.cdempres                	
              tt-comercial-atl.nrcpfemp = STRING(crapttl.nrcpfemp)              	
              tt-comercial-atl.dsproftl = crapttl.dsproftl		
              tt-comercial-atl.cdnvlcgo = crapttl.cdnvlcgo  		
              tt-comercial-atl.nrcadast = crapttl.nrcadast  	
              tt-comercial-atl.dtadmemp = crapttl.dtadmemp
              tt-comercial-atl.vlsalari = crapttl.vlsalari  	
              tt-comercial-atl.tpdrendi[1] = crapttl.tpdrendi[1]  	
              tt-comercial-atl.tpdrendi[2] = crapttl.tpdrendi[2]  	
              tt-comercial-atl.tpdrendi[3] = crapttl.tpdrendi[3]  	
              tt-comercial-atl.tpdrendi[4] = crapttl.tpdrendi[4]  	
              tt-comercial-atl.vldrendi[1] = crapttl.vldrendi[1] 	
              tt-comercial-atl.vldrendi[2] = crapttl.vldrendi[2] 	
              tt-comercial-atl.vldrendi[3] = crapttl.vldrendi[3] 	
              tt-comercial-atl.vldrendi[4] = crapttl.vldrendi[4]    
              tt-comercial-atl.cdturnos  = crapttl.cdturnos
              tt-comercial-atl.inpolexp  = crapttl.inpolexp.
    
     END.
   
   FIND crapenc WHERE ROWID(crapenc) = aux_rowidenc NO-LOCK NO-ERROR NO-WAIT. 
   IF AVAIL crapenc THEN
     DO:
       ASSIGN tt-comercial-atl.cepedct1 = crapenc.nrcepend
              tt-comercial-atl.endrect1 = crapenc.dsendere
              tt-comercial-atl.nrendcom = crapenc.nrendere
              tt-comercial-atl.complcom = crapenc.complend
              tt-comercial-atl.bairoct1 = crapenc.nmbairro
              tt-comercial-atl.cidadct1 = crapenc.nmcidade
              tt-comercial-atl.ufresct1 = crapenc.cdufende
              tt-comercial-atl.cxpotct1 = crapenc.nrcxapst.
     END.
   
   VALIDATE tt-comercial-atl.
   
   IF  par_flgerlog THEN
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
             INPUT BUFFER tt-comercial-ant:HANDLE,
             INPUT BUFFER tt-comercial-atl:HANDLE ).

   RETURN aux_retorno.

END PROCEDURE.



PROCEDURE Grava_Rendimentos:

    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrendi AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_vldrendi AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_tpdrend2 AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_vldrend2 AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_dsjusren AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsjusre2 AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INT                            NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_flgmaxim AS LOG                                     NO-UNDO.
    DEF VAR aux_flgexist AS LOG                                     NO-UNDO.
    DEF VAR aux_dsjusren AS CHAR FORMAT "x(160)"                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    
    DEF BUFFER bcrapttl FOR crapttl.


    &SCOPED-DEFINE CAMPOS-TTL cdnatopc cdocpttl tpcttrab nmextemp nrcpfemp~
                              dsproftl cdnvlcgo dtadmemp vlsalari cdturnos~
							  nrcadast cdempres tpdrendi vldrendi
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF par_cddopcao = "A" THEN 
                              "Alterar" 
                           ELSE 
                             IF par_cddopcao = "E" THEN
                                "Excluir" 
                             ELSE 
                               "Incluir") + 
                            " dados Comerciais"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_flgmaxim = FALSE
           aux_flgexist = FALSE
           aux_dsjusren = ""
           aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        /* Dados do Titular */
        DO aux_contador = 1 TO 10:

           FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                              crapttl.nrdconta = par_nrdconta AND
                              crapttl.idseqttl = par_idseqttl
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crapttl THEN
              DO:
                 IF LOCKED(crapttl) THEN
                    DO:
                       IF aux_contador = 10 THEN
                          DO:
                             ASSIGN aux_cdcritic = 341.
                             LEAVE.

                          END.
                       ELSE 
                         DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.

                         END.

                    END.
                 ELSE
                   DO:
                      ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                                            " encontrados.".
                      LEAVE.

                   END.

              END.
           ELSE
             LEAVE.

        END.

        IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
        
        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.
        
        EMPTY TEMP-TABLE tt-comercial-ant.
        EMPTY TEMP-TABLE tt-comercial-atl.


        IF par_cddopcao = "A" THEN
           DO:
              ASSIGN aux_contador = 0 
                     aux_dsjusren = par_dsjusre2.
              
              IF par_tpdrend2 = 6   AND 
                 par_dsjusre2 = ""  THEN
                 ASSIGN aux_dscritic = "Deve ser informado uma justificativa.".
              
              IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                 UNDO Grava, LEAVE Grava.
              
              IF (par_tpdrend2 <> par_tpdrendi) AND
                  par_tpdrend2 = 6              THEN
                  DO aux_contador = 1 TO 4:
                      
                    IF crapttl.tpdrendi[aux_contador] = par_tpdrend2 THEN
                       DO:
                          ASSIGN aux_dscritic = "Rendimento (Outros) ja" + 
                                                " cadastrado.".
                          
                          LEAVE.
              
                       END.
              
                 END.
              
              IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                 UNDO Grava, LEAVE Grava.
              
              
              DO aux_contador = 1 TO 4:
              
                 IF crapttl.tpdrendi[aux_contador] = par_tpdrendi AND
                    crapttl.vldrendi[aux_contador] = par_vldrendi THEN
                    DO:
                       ASSIGN crapttl.tpdrendi[aux_contador] = par_tpdrend2
                              crapttl.vldrendi[aux_contador] = par_vldrend2
                              crapttl.dsjusren = "" WHEN par_tpdrendi = 6 AND
                                                         par_tpdrend2 <> 6
                              crapttl.dsjusren = aux_dsjusren 
                                                 WHEN par_tpdrend2 = 6.
              
                       LEAVE.
              
                    END.
              
              END.
             
           END.
        ELSE
          IF par_cddopcao = "E" THEN
             DO:
                DO aux_contador = 1 TO 4:
                
                   IF crapttl.tpdrendi[aux_contador] = par_tpdrendi AND
                      crapttl.vldrendi[aux_contador] = par_vldrendi THEN
                      DO:
                         ASSIGN crapttl.tpdrendi[aux_contador] = 0
                                crapttl.vldrendi[aux_contador] = 0
                                crapttl.dsjusren = "" WHEN par_tpdrendi = 6.

                         LEAVE.

                      END.

                END.

             END.
          ELSE
            DO:  
              ASSIGN aux_contador = 0
                     aux_dsjusren = par_dsjusre2.

              IF par_tpdrend2 = 6 THEN
                 DO: 
                    IF par_dsjusre2 = "" THEN
                       ASSIGN aux_dscritic = "Deve ser informado uma " + 
                                             "justificativa.".
                    
                    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                       UNDO Grava, LEAVE Grava.

                    DO aux_contador = 1 TO 4:
                     
                       IF crapttl.tpdrendi[aux_contador] = par_tpdrend2 THEN
                          DO:
                             aux_flgexist = TRUE.
                             LEAVE.
                    
                          END.
                    
                    END.

                 END.

              aux_contador = 0.

              IF aux_flgexist = FALSE THEN
                 DO:
                    DO aux_contador = 1 TO 4:
                       
                       IF crapttl.tpdrendi[aux_contador] = 0 THEN
                          DO:
                             ASSIGN crapttl.tpdrendi[aux_contador] = par_tpdrend2
                                    crapttl.vldrendi[aux_contador] = par_vldrend2
                                    crapttl.dsjusren = aux_dsjusren 
                                                       WHEN par_tpdrend2 = 6
                                    aux_flgmaxim = TRUE.
                    
                             LEAVE.
                    
                          END.
                    
                    END.

                    IF aux_flgmaxim = FALSE THEN
                       ASSIGN aux_dscritic = "Numero maximo de rendimentos" + 
                                             " alcancado.".

                 END.
               
              IF aux_flgexist = TRUE THEN
                 ASSIGN aux_dscritic = "Rendimento (Outros) ja cadastrado.".

            END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenllog.i }

            END.
        
        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
    
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "COMERCIAL",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, 
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.
               
               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Grava, LEAVE Grava.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.

               IF AVAILABLE bcrapttl THEN DO:

                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.

                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ).

                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.

               END.

            END.

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
        
    END.

    RELEASE crapttl.
    RELEASE crapass.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    
    IF  par_flgerlog THEN
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
              INPUT BUFFER tt-comercial-ant:HANDLE,
              INPUT BUFFER tt-comercial-atl:HANDLE ).

    RETURN aux_retorno.


END PROCEDURE.



PROCEDURE Busca_Rendimentos:

    DEF INPUT PARAM par_cdcooper AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nrdrowid AS ROWID                   NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INT                     NO-UNDO.
    DEF INPUT PARAM par_flgpagin AS LOG                     NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INT                    NO-UNDO.
    DEF OUTPUT PARAM par_flgexist AS LOG                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-rendimentos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                             NO-UNDO.
    DEF VAR h-b1wgen0059 AS HANDLE                          NO-UNDO.
    DEF VAR aux_cdcritic AS INT                             NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    DEF VAR aux_qtregist AS INT                             NO-UNDO.
    DEF VAR aux_nrregist AS INT                             NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_qtregist = 0
           par_flgexist = TRUE
           aux_nrregist = par_nrregist.
    

    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p 
                         PERSISTENT SET h-b1wgen0059.


   EMPTY TEMP-TABLE tt-rendimentos.
   EMPTY TEMP-TABLE tt-erro.

    RUN busca-tipo-rendi IN h-b1wgen0059
               ( INPUT par_cdcooper,
                 INPUT 0,
                 INPUT "",
                 INPUT 99999,
                 INPUT 0,
                OUTPUT aux_qtregist,
                OUTPUT TABLE tt-tipo-rendi).

    DELETE PROCEDURE h-b1wgen0059.


    FIND crapttl WHERE ROWID(crapttl) = par_nrdrowid
                       NO-LOCK NO-ERROR.


    DO aux_contador = 1 TO 4:

       FIND FIRST tt-tipo-rendi WHERE tt-tipo-rendi.tpdrendi = 
                                      crapttl.tpdrendi[aux_contador] 
                                      NO-LOCK NO-ERROR.

       IF AVAIL tt-tipo-rendi THEN
          DO:
             ASSIGN par_qtregist = par_qtregist + 1.

             /* controles da paginação */
             IF  par_flgpagin  AND
                (par_qtregist < par_nriniseq  OR
                 par_qtregist > (par_nriniseq + par_nrregist))  THEN
                 NEXT.
            
             
             IF NOT par_flgpagin OR aux_nrregist > 0 THEN
                DO: 
                   CREATE tt-rendimentos.
                   
                   IF AVAIL tt-tipo-rendi THEN
                      ASSIGN tt-rendimentos.tpdrendi = tt-tipo-rendi.tpdrendi
                             tt-rendimentos.dsdrendi = tt-tipo-rendi.dsdrendi
                             tt-rendimentos.dsorigem = 
                                        STRING(tt-tipo-rendi.tpdrendi) +
                                        " - " + tt-tipo-rendi.dsdrendi
                             tt-rendimentos.vldrendi = 
                                        crapttl.vldrendi[aux_contador].
                       
                END.

             IF par_flgpagin THEN
                ASSIGN aux_nrregist = aux_nrregist - 1.

          END.

    END.
      

    FIND FIRST tt-rendimentos NO-LOCK NO-ERROR.

    IF NOT AVAIL tt-rendimentos THEN
       ASSIGN par_flgexist = FALSE.


    RETURN "OK".


END PROCEDURE.


PROCEDURE Busca_Dados_PPE:

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
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-ppe.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_criticas AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcpfcto AS DEC                                     NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR.
    

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados de PPE"

        aux_dsmesref = "janeiro,fevereiro,marco,abril," +
                        "maio,junho,julho,agosto,setembro," +
                        "outubro,novembro,dezembro"

        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno  = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-ppe.
        EMPTY TEMP-TABLE tt-erro.   

        IF  NOT CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta) THEN
        DO:
           ASSIGN aux_cdcritic = 9.
           LEAVE Busca.
        END.

        FOR FIRST crapttl FIELDS(inpolexp nmextttl nrcpfcgc)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = par_idseqttl NO-LOCK:
        END.

        IF  NOT AVAILABLE crapttl THEN
        DO:
           ASSIGN aux_dscritic = "Dados do titular nao encontrados".
           LEAVE Busca.
        END.

        IF crapttl.inpolexp = 1 THEN /* Sim, pessoa politicamente exposta */
        DO:

            FOR FIRST tbcadast_politico_exposto FIELDS(
                tpexposto       cdocupacao      cdrelacionamento
                dtinicio        dttermino       nmempresa
                nrcnpj_empresa  nmpolitico      nrcpf_politico
                )
                WHERE tbcadast_politico_exposto.cdcooper = par_cdcooper AND
                      tbcadast_politico_exposto.nrdconta = par_nrdconta AND
                      tbcadast_politico_exposto.idseqttl = par_idseqttl 
                NO-LOCK:
            END.

            IF  AVAILABLE tbcadast_politico_exposto THEN
            DO:

                CREATE tt-ppe.
                ASSIGN 
                tt-ppe.cdcooper          = par_cdcooper
                tt-ppe.nrdconta          = par_nrdconta
                tt-ppe.idseqttl          = par_idseqttl
                tt-ppe.tpexposto         = tbcadast_politico_exposto.tpexposto
                tt-ppe.cdocupacao        = tbcadast_politico_exposto.cdocupacao
                tt-ppe.cdrelacionamento  = tbcadast_politico_exposto.cdrelacionamento
                tt-ppe.dtinicio          = tbcadast_politico_exposto.dtinicio
                tt-ppe.dttermino         = tbcadast_politico_exposto.dttermino  
                tt-ppe.nmempresa         = tbcadast_politico_exposto.nmempresa
                tt-ppe.nrcnpj_empresa    = tbcadast_politico_exposto.nrcnpj_empresa
                tt-ppe.nmpolitico        = tbcadast_politico_exposto.nmpolitico
                tt-ppe.nrcpf_politico    = tbcadast_politico_exposto.nrcpf_politico
                tt-ppe.inpolexp          = 1
                tt-ppe.nmextttl          = crapttl.nmextttl
                tt-ppe.nrcpfcgc          = crapttl.nrcpfcgc.

                FOR FIRST crapass FIELDS (cdagenci) 
                    WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK:
                END.

                /* Busca dados da agencia */
                FOR FIRST crapage FIELDS(idcidade)
                                  WHERE crapage.cdcooper = par_cdcooper     AND
                                        crapage.cdagenci = crapass.cdagenci 
                                        NO-LOCK:
                END.
        
                IF AVAIL crapage THEN
                DO:
                    FIND FIRST crapmun WHERE crapmun.idcidade = crapage.idcidade 
                        NO-LOCK NO-ERROR.
                
                    ASSIGN tt-ppe.cidade = IF AVAIL crapmun 
                                           THEN crapmun.dscidade
                                           ELSE 'CIDADE NAO CADASTRADA'.
                END.
                ELSE 
                    ASSIGN tt-ppe.cidade = 'CIDADE NAO CADASTRADA'.

                ASSIGN tt-ppe.cidade = tt-ppe.cidade + ", " + 
                    STRING(DAY(TODAY)) + 
                    " de " + 
                    ENTRY(MONTH(TODAY),aux_dsmesref) +
                    " de " + 
                    STRING(YEAR(TODAY)) + ".".
                

                FOR FIRST gncdocp FIELDS(dsdocupa)
                    WHERE gncdocp.cdocupa = tbcadast_politico_exposto.cdocupacao
                    NO-LOCK:
                    ASSIGN tt-ppe.rsdocupa = gncdocp.dsdocupa.
                END.

                FOR FIRST craptab
                    WHERE craptab.cdcooper = 1 AND
        				  craptab.nmsistem = 'CRED'       AND
        				  craptab.tptabela = 'GENERI'     AND
        				  craptab.cdempres = 0            AND
        				  craptab.cdacesso = 'VINCULOTTL' AND
        				  craptab.tpregist = 0 NO-LOCK:
                    /* dstextab: conjuge,1,pai,3*/

                    ASSIGN tt-ppe.dsrelacionamento = 
                         ENTRY(LOOKUP(STRING(tbcadast_politico_exposto.cdrelacionamento),
                               craptab.dstextab) - 1,craptab.dstextab) NO-ERROR.
                END.
            END.
            ELSE
            DO:
                CREATE tt-ppe.
                ASSIGN 
                tt-ppe.cdcooper          = par_cdcooper
                tt-ppe.nrdconta          = par_nrdconta
                tt-ppe.idseqttl          = par_idseqttl
                tt-ppe.tpexposto         = 0
                tt-ppe.inpolexp          = 1
                tt-ppe.nmextttl          = crapttl.nmextttl
                tt-ppe.nrcpfcgc          = crapttl.nrcpfcgc.

                FOR FIRST crapass FIELDS (cdagenci) 
                    WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK:
                END.

                /* Busca dados da agencia */
                FOR FIRST crapage FIELDS(idcidade)
                                  WHERE crapage.cdcooper = par_cdcooper     AND
                                        crapage.cdagenci = crapass.cdagenci 
                                        NO-LOCK:
                END.
        
                IF AVAIL crapage THEN
                DO:
                    FIND FIRST crapmun WHERE crapmun.idcidade = crapage.idcidade 
                        NO-LOCK NO-ERROR.
                
                    ASSIGN tt-ppe.cidade = IF AVAIL crapmun 
                                           THEN crapmun.dscidade
                                           ELSE 'CIDADE NAO CADASTRADA'.
                END.
                ELSE 
                    ASSIGN tt-ppe.cidade = 'CIDADE NAO CADASTRADA'.

                ASSIGN tt-ppe.cidade = tt-ppe.cidade + ", " + 
                    STRING(DAY(TODAY)) + 
                    " de " + 
                    ENTRY(MONTH(TODAY),aux_dsmesref) +
                    " de " + 
                    STRING(YEAR(TODAY)) + ".".

            END.
        END.
        ELSE
        DO:
            CREATE tt-ppe.
            ASSIGN 
            tt-ppe.cdcooper          = par_cdcooper
            tt-ppe.nrdconta          = par_nrdconta
            tt-ppe.idseqttl          = par_idseqttl
            tt-ppe.tpexposto         = 0
            tt-ppe.inpolexp          = crapttl.inpolexp
            tt-ppe.nmextttl          = crapttl.nmextttl
            tt-ppe.nrcpfcgc          = crapttl.nrcpfcgc.

            FOR FIRST crapass FIELDS (cdagenci) 
                WHERE crapass.cdcooper = par_cdcooper AND
                      crapass.nrdconta = par_nrdconta
                      NO-LOCK:
            END.

            /* Busca dados da agencia */
            FOR FIRST crapage FIELDS(idcidade)
                              WHERE crapage.cdcooper = par_cdcooper     AND
                                    crapage.cdagenci = crapass.cdagenci 
                                    NO-LOCK:
            END.
    
            IF AVAIL crapage THEN
            DO:
                FIND FIRST crapmun WHERE crapmun.idcidade = crapage.idcidade 
                    NO-LOCK NO-ERROR.
            
                ASSIGN tt-ppe.cidade = IF AVAIL crapmun 
                                       THEN crapmun.dscidade
                                       ELSE 'CIDADE NAO CADASTRADA'.
            END.
            ELSE 
                ASSIGN tt-ppe.cidade = 'CIDADE NAO CADASTRADA'.

            ASSIGN tt-ppe.cidade = tt-ppe.cidade + ", " + 
                STRING(DAY(TODAY)) + 
                " de " + 
                ENTRY(MONTH(TODAY),aux_dsmesref) +
                " de " + 
                STRING(YEAR(TODAY)) + ".".

        END.
        LEAVE Busca.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.





/*............................. FUNCTIONS ...................................*/
FUNCTION ValidaCpfCnpj RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER     NO-UNDO.

    /* Se houve erro na conversao para DEC, faz a critica */
    DEC(par_nrcpfcgc) NO-ERROR.
    
    IF  ERROR-STATUS:ERROR   THEN
        RETURN FALSE.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT par_nrcpfcgc,
                                         OUTPUT aux_stsnrcal,
                                         OUTPUT aux_inpessoa).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN aux_stsnrcal.
        
END FUNCTION.

FUNCTION ValidaDigFun RETURNS LOGICAL 
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrcadast AS INTEGER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_confirma AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    ASSIGN 
        aux_nrdconta = par_nrcadast
        aux_confirma = TRUE.

    RUN dig_fun IN h-b1wgen9999 
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT aux_nrdconta,
          OUTPUT TABLE tt-erro ).

    EMPTY TEMP-TABLE tt-erro.
    DELETE PROCEDURE h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_confirma = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_confirma = FALSE.

    IF  aux_nrdconta <> par_nrcadast THEN
        ASSIGN aux_confirma = FALSE.

   RETURN aux_confirma.
        
END FUNCTION.

FUNCTION ValidaNome RETURNS LOGICAL 
    ( INPUT  par_nmdbusca AS CHARACTER,
      OUTPUT par_cdcritic AS INTEGER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN Critica_Nome IN h-b1wgen9999 (INPUT par_nmdbusca,
                                     OUTPUT par_cdcritic).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN (par_cdcritic = 0).
        
END FUNCTION.


PROCEDURE Grava_Dados_Ppe:

    DEF INPUT PARAM par_cdcooper            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_cdagenci            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_cdoperad            AS CHAR   NO-UNDO.
    DEF INPUT PARAM par_nmdatela            AS CHAR   NO-UNDO.
    DEF INPUT PARAM par_idorigem            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_nrdconta            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_idseqttl            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_flgerlog            AS LOG    NO-UNDO.
    DEF INPUT PARAM par_cddopcao            AS CHAR   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt            AS DATE   NO-UNDO.
    
    DEF INPUT PARAM par_tpexposto           AS INTE   NO-UNDO.
    DEF INPUT PARAM par_cdocpttl            AS INTE   NO-UNDO.
    DEF INPUT PARAM par_cdrelacionamento    AS INTE   NO-UNDO.
    DEF INPUT PARAM par_dtinicio            AS DATE   NO-UNDO.
    DEF INPUT PARAM par_dttermino           AS DATE   NO-UNDO.
    DEF INPUT PARAM par_nmempresa           AS CHAR   NO-UNDO.
    DEF INPUT PARAM par_nrcnpj_empresa      AS DECI   NO-UNDO.
    DEF INPUT PARAM par_nmpolitico          AS CHAR   NO-UNDO.
    DEF INPUT PARAM par_nrcpf_politico      AS DECI   NO-UNDO.
    
    DEF OUTPUT PARAM par_tpatlcad           AS INTE   NO-UNDO.
    DEF OUTPUT PARAM par_msgatcad           AS CHAR   NO-UNDO.
    DEF OUTPUT PARAM par_chavealt           AS CHAR   NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad           AS CHAR   NO-UNDO.
    DEF OUTPUT PARAM par_cotcance           AS CHAR   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF VAR h-b1wgen0137 AS HANDLE                    NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados Comerciais"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        /* Dados do Titular */
        ContadorTtl: DO aux_contador = 1 TO 10:

            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl
                               NO-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapttl THEN
            DO:
                IF  LOCKED(crapttl) THEN
                DO:
                    IF  aux_contador = 10 THEN
                    DO:
                        ASSIGN aux_cdcritic = 341.
                        LEAVE ContadorTtl.
                    END.
                    ELSE 
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT ContadorTtl.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                    " encontrados.".
                    LEAVE ContadorTtl.
                END.
            END.
            ELSE
                LEAVE ContadorTtl.
        END. /* ContadorTtl */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        FIND tbcadast_politico_exposto WHERE 
            tbcadast_politico_exposto.cdcooper = crapttl.cdcooper AND
            tbcadast_politico_exposto.nrdconta = crapttl.nrdconta AND
            tbcadast_politico_exposto.idseqttl = crapttl.idseqttl 
            EXCLUSIVE-LOCK NO-ERROR.

        IF AVAIL tbcadast_politico_exposto THEN
        DO:
            /* atualizar dados tbcadast_politico_exposto */
            ASSIGN 
                tbcadast_politico_exposto.tpexposto        = par_tpexposto
                tbcadast_politico_exposto.cdocupacao       = par_cdocpttl
                tbcadast_politico_exposto.cdrelacionamento = par_cdrelacionamento
                tbcadast_politico_exposto.dtinicio         = par_dtinicio
                tbcadast_politico_exposto.dttermino        = par_dttermino
                tbcadast_politico_exposto.nmempresa        = par_nmempresa
                tbcadast_politico_exposto.nrcnpj_empresa   = par_nrcnpj_empresa
                tbcadast_politico_exposto.nmpolitico       = par_nmpolitico
                tbcadast_politico_exposto.nrcpf_politico   = par_nrcpf_politico.
            VALIDATE tbcadast_politico_exposto.

            
            IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                RUN sistema/generico/procedures/b1wgen0137.p 
                PERSISTENT SET h-b1wgen0137.
              
            RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                      ( INPUT crapttl.cdcooper,
                        INPUT crapttl.nrdconta,
                        INPUT crapttl.idseqttl,
                        INPUT crapttl.nrcpfcgc,
                        INPUT par_dtmvtolt,
                        INPUT "37", /* PESSOA EXPOSTA POLITICAMENTE - PEP  */
                        INPUT par_cdoperad,
                       OUTPUT aux_cdcritic,
                       OUTPUT aux_dscritic).

            IF  VALID-HANDLE(h-b1wgen0137) THEN
              DELETE OBJECT h-b1wgen0137.


        END.                                                  
        ELSE                                                  
        DO:
            CREATE tbcadast_politico_exposto.
            ASSIGN 
                tbcadast_politico_exposto.cdcooper         = crapttl.cdcooper 
                tbcadast_politico_exposto.nrdconta         = crapttl.nrdconta 
                tbcadast_politico_exposto.idseqttl         = crapttl.idseqttl 
                tbcadast_politico_exposto.tpexposto        = par_tpexposto
                tbcadast_politico_exposto.cdocupacao       = par_cdocpttl
                tbcadast_politico_exposto.cdrelacionamento = par_cdrelacionamento
                tbcadast_politico_exposto.dtinicio         = par_dtinicio
                tbcadast_politico_exposto.dttermino        = par_dttermino
                tbcadast_politico_exposto.nmempresa        = par_nmempresa
                tbcadast_politico_exposto.nrcnpj_empresa   = par_nrcnpj_empresa
                tbcadast_politico_exposto.nmpolitico       = par_nmpolitico
                tbcadast_politico_exposto.nrcpf_politico   = par_nrcpf_politico.
            VALIDATE tbcadast_politico_exposto.
            

        END.

        LEAVE Grava.
    END. /* Grava */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
    DO:
        ASSIGN aux_retorno = "NOK".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    END.


END PROCEDURE.