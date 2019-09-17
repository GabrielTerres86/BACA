/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0052.p                  
    Autor(a): Jose Luis Marchezoni (DB1)
    Data    : Junho/2010                      Ultima atualizacao: 01/12/2017
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela MATRIC.
                Baseado em fontes/matric.p.
                Gerenciador da Rotina Matric - Busca, Valida e Grava
    
    Alteracoes: 01/02/2011 - Incluido output table tt-prod_serv_ativos da 
                             procedure Valida_Dados que retorna do 
                             arquivo b1wgen0052v. (Jorge)

                27/04/2012 - Incluido Input na instancia da b1wgen0052v.
                             (David Kruger).
                             
                15/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).             
                             
                27/08/2012 - Tratamento para inclusao de contas na Viacredi
                             Alto Vale (Gabriel)
                             
                20/03/2013 - Incluido a chamada da alerta_fraude dentro
                             do Grava_Dados (Adriano).             
                             
                08/08/2013 - Incluido campo cdufnatu. (Reinert)
                
                15/08/2013 - Incluido flgdigit = FALSE na crpdoc, para
                             digitalização de documentos (Jean Michel).
                
                19/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James).
                             
                30/10/2013 - Alteração referente a criação de registros na
                             crapdoc (Jean Michel).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                16/01/2014 - Alterado criação de registros na crapdoc, quando
                             cooperado for demitido, não cria registros. 
                             (Jean Michel)
                
                28/02/2014 - Incluir validacao para somente gravar na crapdoc
                             se for alterado algum campo da Matric (Lucas R)
                             
                27/03/2014 - Ajustes para gerar pendencia na crapdoc se opcao
                             for X e alterou nome ou CPF (Lucas R.)
                             
                04/04/2014 - Ajustes para gerar pendencia na crapdoc, troca de
                             condicoes e tipos de documentos (Jean Michel)
                             
                08/04/2014 - Incluir create para crapdoc na Inclusao (Lucas R.)
                             
                29/04/2014 - Incluir filtro de pessoa fisica na validacao 
                             de emancipacao (Jaison - SF: 152091)

                08/05/2014 - Quando alterar CPF/CGC com opcao X da tela MATRIC
                             atualizar o campo na CRAPAVT (Douglas - 
                             Chamado 154912)
                             
                27/05/2014 - Incluir par_inpessoa = 1 na validacao de estado
                             civil, pois somente pessoa fisica tem estado civil
                             Softdesk 162045 (Lucas R.)
                             
                30/07/2014 - Nao gerar pendencia de matricula quando for
                             alterado CPF/CNPJ e/ou Nome/Razao Social; 
                             opcao 'X'. (Chamado 172185) - (Fabricio)
                             
                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                             0 - menor/maior. (Carlos)
                             
                06/03/2015 - #261010 Tratamento de inpessoa = 1 para validacao
                             dos responsaveis legais para menor (Carlos)
                             
                10/04/2015 - #271162 Retirada a validacao de responsaveis, 
                             procedure grava_dados pois a validacao acontece
                             antes de salvar (Carlos)
                             
                25/05/2015 - Inlcuir create da crapdoc na inclusão para o 
                             tpdocmto = 4 e tipo 6 (Lucas Ranghetti #287169)
                            
                10/07/2015 - Projeto reformulacao Cadastral (Gabriel-RKAM).             
                
                05/10/2015 - Adicionado nova opção "J" para alteração apenas do cpf/cnpj e 
                             removido a possibilidade de alteração pela opção "X", conforme 
                             solicitado no chamado 321572 (Kelvin).    
                
                17/12/2015 - Remocao da pendencia do documento de ficha cadastral
                             no DigiDoc conforme solicitado na melhoria 114.  
                             SD 372880 (Kelvin)
		        
				01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)
                             
                16/03/2016 - Incluir validacao para nao criar crapdoc para pessoa juridica
                             tipo 2 (Lucas Ranghetti #391492)
                17/06/2016 - Inclusao de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)
                  - Inclusão do parametro CDAGENCI para a funcao GRAVA_DADOS

                25/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

                26/06/2017 - Incluido rotina para buscar contas demitidas a serem listadas
				             na opcao "G" da tela MATRIC
							 (Jonata - RKAM P364).

                07/07/2017 - Opcao D nao estava funcionando corretamente, sempre retornava erro na
                             gravacao dos dados. Foi incluida opcao D novamente na rotina e tratado
                             problema com validacao da data de nascimento.
                             Heitor (Mouts) - Chamado 702785	    	

                11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                             Projeto 339 - CRM. (Lombardi)
				 
                22/09/2017 - Adicionar tratamento para caso o inpessoa for juridico gravar 
                             o idseqttl como zero (Luacas Ranghetti #756813)

                23/10/2017 - Ajustes para nao validar responsavel legal ao incluir CONTA
                             na tela MATRIC, pois validaçao ocorrerá apenas apos a inclusao
                             para garantir replicaçao dos dados da tbcadast.
                             PRJ339 - CRM (Odirlei-AMcom)
               
			   14/11/2017 - Ajuste na rotina que busca contas demitidas para enviar conta
						     para pesquisa e retornar valor total da pesquisa
							 (Jonata - RKAM P364). 

			   16/11/2017 - Ajuste para validar conta (Jonata - RKAM P364).

			   01/12/2017 - Retirado leitura da craplct ( Jonata - RKAM P364).

			   13/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)

			   10/09/2018 - Ajuste na busca pelo Nome Social (Andrey Formigari - Mouts)
				 
			   13/08/2019 - Atualizar cpf/cnpj na tabela de eventos - Projeto 484.2
                            Gabriel Marcos (Mouts).
				 
............................................................................*/


/*............................... DEFINICOES ...............................*/

{ sistema/generico/includes/b1wgen0052tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM 
    &SESSAO-BO=SIM &TELA-MATRIC=SIM &TELA-CONTAS=NAO }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_tpdopcao AS INTE INITIAL 1                              NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR EXTENT 8 INITIAL 
        ["Tela Principal","Consultar","Alterar","Alterar Nome",
         "Imprimir","Incluir","Desvincular Matricula"," Alterar Cpf-Cnpj"]             NO-UNDO.

/* Pre-Processador para controle de erros 'Progress' */
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

/*........................... PROCEDURES EXTERNAS ...........................*/


/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
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

    DEF OUTPUT PARAM TABLE FOR tt-crapass.
    DEF OUTPUT PARAM TABLE FOR tt-operadoras-celular.
    DEF OUTPUT PARAM TABLE FOR tt-crapavt.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-bens.
    DEF OUTPUT PARAM TABLE FOR tt-crapcrl.
	DEF OUTPUT PARAM TABLE FOR tt-crapttl.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR hb1wgen0052b AS HANDLE                                  NO-UNDO.

	FOR FIRST crapttl FIELDS(nmsocial)
					  WHERE crapttl.cdcooper = par_cdcooper AND
							crapttl.nrdconta = par_nrdconta AND
							crapttl.idseqttl = par_idseqttl 
							NO-LOCK:
        END.

	IF AVAILABLE crapttl THEN
		DO:
			CREATE tt-crapttl.
			ASSIGN tt-crapttl.nmsocial = crapttl.nmsocial.
		END.
	ELSE
		DO:
			CREATE tt-crapttl.
			ASSIGN tt-crapttl.nmsocial = " ".
		END.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(hb1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p
                PERSISTENT SET hb1wgen0052b.
                     
        RUN Busca_Dados IN hb1wgen0052b
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT par_cddopcao,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic,
             OUTPUT TABLE tt-crapass,
             OUTPUT TABLE tt-operadoras-celular,
             OUTPUT TABLE tt-crapavt,
             OUTPUT TABLE tt-alertas,
             OUTPUT TABLE tt-bens,
             OUTPUT TABLE tt-crapcrl) NO-ERROR.

        IF  VALID-HANDLE(hb1wgen0052b) THEN
            DELETE OBJECT hb1wgen0052b.

        IF  ERROR-STATUS:ERROR THEN
            DO: 
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               LEAVE Busca.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.

        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.
    END.

    IF  VALID-HANDLE(hb1wgen0052b) THEN
        DELETE OBJECT hb1wgen0052b.

    IF  aux_returnvl = "NOK" AND (aux_dscritic = "" AND aux_cdcritic = 0) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog THEN 
        DO:
           /* determina a descricao da acao */
           CASE par_cddopcao:

               WHEN "C" THEN ASSIGN aux_tpdopcao = 2.
               WHEN "A" THEN ASSIGN aux_tpdopcao = 3.
               WHEN "X" THEN ASSIGN aux_tpdopcao = 4.
               WHEN "R" THEN ASSIGN aux_tpdopcao = 5.
               WHEN "I" THEN ASSIGN aux_tpdopcao = 6.
               WHEN "D" THEN ASSIGN aux_tpdopcao = 7.
               WHEN "J" THEN ASSIGN aux_tpdopcao = 8.
               OTHERWISE ASSIGN aux_tpdopcao = 1.

           END CASE.

           ASSIGN aux_dstransa = "Busca dados do Associado - " + 
                                 aux_dsdopcao[aux_tpdopcao].

           RUN proc_gerar_log (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT aux_dscritic,
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                               INPUT par_idseqttl, 
                               INPUT par_nmdatela, 
                               INPUT par_nrdconta, 
                              OUTPUT aux_nrdrowid).
        END.

    RETURN aux_returnvl.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*               BUSCA OS DADOS DOS PROCURADORES DO ASSOCIADO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Procurador:

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
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapavt.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl  AS CHAR                                    NO-UNDO.
    DEF VAR hb1wgen0052b  AS HANDLE                                  NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados do Representante/Procurador"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Procurador: DO ON ERROR UNDO Procurador, LEAVE Procurador:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(hb1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p
                PERSISTENT SET hb1wgen0052b.

        RUN Busca_Procurador IN hb1wgen0052b
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_cddopcao,
              INPUT par_nrdctato,
              INPUT par_nrcpfcto,
              INPUT par_nrdrowid,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic,
             OUTPUT TABLE tt-crapavt ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               LEAVE Procurador.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Procurador.

        ASSIGN aux_returnvl = "OK".

        LEAVE Procurador.
    END.

    IF  VALID-HANDLE(hb1wgen0052b) THEN
        DELETE OBJECT hb1wgen0052b.

    IF  aux_returnvl = "NOK" AND (aux_dscritic = "" AND aux_cdcritic = 0) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*           EFETUA A BUSCA DE DADOS DO ASSOCIADO PARA IMPRESSAO            */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Impressao:

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

    DEF OUTPUT PARAM TABLE FOR tt-relat-cab.
    DEF OUTPUT PARAM TABLE FOR tt-relat-par.
    DEF OUTPUT PARAM TABLE FOR tt-relat-fis.
    DEF OUTPUT PARAM TABLE FOR tt-relat-jur.
    DEF OUTPUT PARAM TABLE FOR tt-relat-rep.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR hb1wgen0052b AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".


    Impressao: DO ON ERROR UNDO Impressao, LEAVE Impressao:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(hb1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p
                PERSISTENT SET hb1wgen0052b.

        RUN Busca_Impressao IN hb1wgen0052b
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT par_flgerlog,
              INPUT par_dtmvtolt,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic,
             OUTPUT TABLE tt-relat-cab,
             OUTPUT TABLE tt-relat-par,
             OUTPUT TABLE tt-relat-fis,
             OUTPUT TABLE tt-relat-jur,
             OUTPUT TABLE tt-relat-rep ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               LEAVE Impressao.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Impressao.

        ASSIGN aux_returnvl = "OK".

        LEAVE Impressao.
    END.

    IF  VALID-HANDLE(hb1wgen0052b) THEN
        DELETE OBJECT hb1wgen0052b.

    IF  aux_returnvl = "NOK" AND (aux_dscritic = "" AND aux_cdcritic = 0) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog THEN 
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT "Busca dados do Associado - Impressao",
                            INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*               REALIZA A VALIDACAO DOS DADOS DO ASSOCIADO                 */
/* ------------------------------------------------------------------------ */
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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtcadass AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmsegntl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu AS CHAR                           NO-UNDO.
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
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtabertu AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_natjurid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfansia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsest AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inmatric AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_valprocu AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_verrespo AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_permalte AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_inhabmen LIKE crapttl.inhabmen             NO-UNDO.
    DEF  INPUT PARAM par_dthabmen LIKE crapttl.dthabmen             NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-crapavt.
    DEF  INPUT PARAM TABLE FOR tt-crapcrl.
	
    DEF OUTPUT PARAM par_nrctanov AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtparcel AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlparcel AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdeanos AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_nrdmeses AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_dsdidade AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-prod_serv_ativos.
    
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_geraerro AS LOG                                     NO-UNDO.
    DEF VAR aux_nrdeanos AS INT                                     NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    
    DEF VAR hb1wgen0052v AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0058 AS HANDLE                                  NO-UNDO.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = "Erro na validacao dos dados. "
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_geraerro = FALSE.
    

    IF par_cddopcao = "PI" OR 
       par_cddopcao = "PA" THEN
       DO:
          IF VALID-HANDLE(h-b1wgen9999) THEN
             DELETE OBJECT h-b1wgen9999.
          
          RUN sistema/generico/procedures/b1wgen9999.p
              PERSISTENT SET h-b1wgen9999.
          
          /* validar pela procedure generica do b1wgen9999.p */
          RUN idade IN h-b1wgen9999 ( INPUT par_dtnasctl,
                                      INPUT par_dtmvtolt,
                                      OUTPUT par_nrdeanos,
                                      OUTPUT par_nrdmeses,
                                      OUTPUT par_dsdidade ).
       
           /* Sera realizada a validacao de emancipacao apenas para pessoas
              que tiverem o estado civil diferente dos apresentados na 
              condicao abaixo. Quando casado, a pessoa é automaticamente 
              emancipada.*/
           IF par_inpessoa = 1 AND 
              par_inhabmen = 1 AND 
              NOT CAN-DO("2,3,4,5,6,7,8,9,11",STRING(par_cdestcvl)) AND
              (par_nrdeanos < 16 OR par_nrdeanos > 17) THEN
              DO:
               
                  ASSIGN aux_dscritic = "Para emancipacao e necessario " + 
                                        "ter entre 16 e 18 anos.".

                  IF VALID-HANDLE(h-b1wgen9999) THEN
                     DELETE OBJECT h-b1wgen9999.

                   
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                    
                  RETURN "NOK".

              END.
          
          IF VALID-HANDLE(h-b1wgen9999) THEN
             DELETE OBJECT h-b1wgen9999.
       
          RETURN "OK".

       END.

    Dados: DO ON ERROR UNDO Dados, LEAVE Dados:
        
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-alertas.
        EMPTY TEMP-TABLE tt-prod_serv_ativos.

        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE OBJECT h-b1wgen9999.
        
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.
        
        /* validar pela procedure generica do b1wgen9999.p */
        RUN idade IN h-b1wgen9999 ( INPUT par_dtnasctl,
                                    INPUT par_dtmvtolt,
                                    OUTPUT par_nrdeanos,
                                    OUTPUT par_nrdmeses,
                                    OUTPUT par_dsdidade ).

        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE OBJECT h-b1wgen9999.

        IF CAN-DO("2,3,4,8,9,11",STRING(par_cdestcvl)) AND
           par_inhabmen = 0                            AND
           par_dthabmen = ?                            AND 
           par_nrdeanos < 18                           THEN
           DO:
               ASSIGN aux_dscritic = "Resp. Legal e data de emancipacao " + 
                                     "invalidos para estado civil.".

               LEAVE Dados.

           END.
        
        IF par_inhabmen = 0 OR
           par_inhabmen = 2 THEN
           DO:
               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE OBJECT h-b1wgen9999.
        
               RUN sistema/generico/procedures/b1wgen9999.p
                   PERSISTENT SET h-b1wgen9999.
        
               /* validar pela procedure generica do b1wgen9999.p */
               RUN idade IN h-b1wgen9999 ( INPUT par_dtnasctl,
                                           INPUT par_dtmvtolt,
                                           OUTPUT par_nrdeanos,
                                           OUTPUT par_nrdmeses,
                                           OUTPUT par_dsdidade ).

               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE OBJECT h-b1wgen9999.
                
           END.         
        
        IF  NOT VALID-HANDLE(hb1wgen0052v) THEN
            RUN sistema/generico/procedures/b1wgen0052v.p
                PERSISTENT SET hb1wgen0052v.

        RUN Valida_Dados IN hb1wgen0052v
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT par_flgerlog,
              INPUT par_cddopcao,
              INPUT par_inpessoa,
              INPUT par_cdagepac,
              INPUT par_nmprimtl,
              INPUT par_nrcpfcgc,
              INPUT par_dtmvtolt,
              INPUT par_dtcadass,
              INPUT par_nmsegntl,
              INPUT par_dtcnscpf,
              INPUT par_cdsitcpf,
              INPUT par_cdtipcta,
              INPUT par_tpdocptl,
              INPUT par_nrdocptl,
              INPUT par_cdoedptl,
              INPUT par_cdufdptl,
              INPUT par_dtemdptl,
              INPUT par_nmmaettl,
              INPUT par_nmpaittl,
              INPUT par_dtnasctl,
              INPUT par_cdsexotl,
              INPUT par_tpnacion,
              INPUT par_cdnacion,
              INPUT par_dsnatura,
              INPUT par_cdufnatu,
              INPUT par_cdestcvl,
              INPUT par_nmconjug,
              INPUT par_nrcepend,
              INPUT par_dsendere,
              INPUT par_nmbairro,
              INPUT par_nmcidade,
              INPUT par_cdufende,
              INPUT par_cdempres,
              INPUT par_nrcadast,
              INPUT par_cdocpttl,
              INPUT par_nmfansia,
              INPUT par_natjurid,
              INPUT par_dtabertu,
              INPUT par_cdseteco,
              INPUT par_cdrmativ,
              INPUT par_nrdddtfc,
              INPUT par_nrtelefo,
              INPUT par_inmatric,
              INPUT par_dtdemiss,
              INPUT par_cdmotdem,
              INPUT par_inhabmen,
              INPUT par_dthabmen,
             OUTPUT par_msgretor,
             OUTPUT par_nmdcampo,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic,
             OUTPUT TABLE tt-alertas,
             OUTPUT TABLE tt-prod_serv_ativos ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
                
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               LEAVE Dados.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Dados.

        IF par_inhabmen = 1 THEN
           DO: 
                
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE OBJECT h-b1wgen9999.
        
               RUN sistema/generico/procedures/b1wgen9999.p
                   PERSISTENT SET h-b1wgen9999.
                
               /* validar pela procedure generica do b1wgen9999.p */
               RUN idade IN h-b1wgen9999 ( INPUT par_dtnasctl,
                                           INPUT par_dtmvtolt,
                                           OUTPUT par_nrdeanos,
                                           OUTPUT par_nrdmeses,
                                           OUTPUT par_dsdidade ).
        
               /* Sera realizada a validacao de emancipacao apenas para pessoas
                  que tiverem o estado civil diferente dos apresentados na 
                  condicao abaixo. Quando casado, a pessoa é automaticamente 
                  emancipada.*/
               IF par_inpessoa = 1 AND 
                  NOT CAN-DO("2,3,4,5,6,7,8,9,11",STRING(par_cdestcvl)) AND
                  (par_nrdeanos < 16 OR par_nrdeanos > 17) THEN
                  DO:

                      ASSIGN aux_dscritic = "Para emancipacao e necessario " + 
                                            "ter entre 16 e 18 anos.".
        
                      IF  VALID-HANDLE(h-b1wgen9999) THEN
                          DELETE OBJECT h-b1wgen9999.
        
                      LEAVE Dados.
                        
                  END.
        
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE OBJECT h-b1wgen9999.
        
           END.         

        /* Procuradores e Avalistas */
        IF  par_valprocu                 AND 
            CAN-DO("I,A,E",par_cddopcao) AND 
           (par_inpessoa = 2             OR 
            par_inpessoa = 3)            THEN
            DO:
               IF NOT VALID-HANDLE(h-b1wgen0058) THEN
                  RUN sistema/generico/procedures/b1wgen0058.p 
                  PERSISTENT SET h-b1wgen0058.

                FOR EACH tt-crapcrl:
                    CREATE tt-resp.
                    BUFFER-COPY tt-crapcrl TO tt-resp.
                END.

               FOR EACH tt-crapavt WHERE tt-crapavt.cddopcao <> "C"
                                         NO-LOCK:

                   RUN Valida_Dados IN h-b1wgen0058
                                      (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT 1,
                                       INPUT par_nrdconta,
                                       INPUT 0,
                                       INPUT YES,
                                       INPUT par_dtmvtolt,
                                       INPUT tt-crapavt.cddopcao,
                                       INPUT tt-crapavt.nrdctato,
                                       INPUT tt-crapavt.nrcpfcgc,
                                       INPUT tt-crapavt.nmdavali,
                                       INPUT tt-crapavt.tpdocava,
                                       INPUT tt-crapavt.nrdocava,
                                       INPUT tt-crapavt.cdoeddoc,
                                       INPUT tt-crapavt.cdufddoc,
                                       INPUT tt-crapavt.dtemddoc,
                                       INPUT tt-crapavt.dtnascto,
                                       INPUT tt-crapavt.cdsexcto,
                                       INPUT tt-crapavt.cdestcvl,
                                       INPUT tt-crapavt.cdnacion,
                                       INPUT tt-crapavt.dsnatura,
                                       INPUT tt-crapavt.nrcepend,
                                       INPUT tt-crapavt.dsendres[1],
                                       INPUT tt-crapavt.nrendere,
                                       INPUT tt-crapavt.complend,
                                       INPUT tt-crapavt.nmbairro,
                                       INPUT tt-crapavt.nmcidade,
                                       INPUT tt-crapavt.cdufresd,
                                       INPUT tt-crapavt.nrcxapst,
                                       INPUT tt-crapavt.nmmaecto,
                                       INPUT tt-crapavt.nmpaicto,
                                       INPUT tt-crapavt.vledvmto,
                                       INPUT tt-crapavt.dsrelbem[1] + "," +
                                             tt-crapavt.dsrelbem[2] + "," + 
                                             tt-crapavt.dsrelbem[3] + "," +
                                             tt-crapavt.dsrelbem[1] + "," +
                                             tt-crapavt.dsrelbem[2] +  "," +
                                             tt-crapavt.dsrelbem[3],
                                       INPUT tt-crapavt.dtvalida,
                                       INPUT tt-crapavt.dsproftl,
                                       INPUT tt-crapavt.dtadmsoc,
                                       INPUT tt-crapavt.persocio,
                                       INPUT tt-crapavt.flgdepec,
                                       INPUT tt-crapavt.vloutren,
                                       INPUT tt-crapavt.dsoutren,
                                       INPUT tt-crapavt.inhabmen,
                                       INPUT tt-crapavt.dthabmen,
                                       INPUT "MATRIC",
                                       INPUT par_verrespo,
                                       INPUT par_permalte,
                                       INPUT TABLE tt-bens,
                                       INPUT TABLE tt-resp,
                                       INPUT TABLE tt-crapavt,
                                      OUTPUT aux_msgalert,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT aux_nrdeanos,
                                      OUTPUT aux_nrdmeses,
                                      OUTPUT aux_dsdidade) .
                
                
                  IF RETURN-VALUE <> "OK" THEN
                     DO:
                         IF VALID-HANDLE(h-b1wgen0058) THEN
                            DELETE OBJECT h-b1wgen0058.

                         ASSIGN aux_geraerro = TRUE.
                         LEAVE Dados.

                     END.
                  
               END.

               IF VALID-HANDLE(h-b1wgen0058) THEN
                  DELETE OBJECT h-b1wgen0058.

            END.


        /* Parcelamento do Capital */
        IF  CAN-DO("I",par_cddopcao) AND 
            par_inpessoa <> 3        THEN
            DO:
               RUN Calcula_Parcelamento IN hb1wgen0052v
                   ( INPUT par_cdcooper,
                     INPUT par_nrcpfcgc,
                    OUTPUT par_qtparcel,
                    OUTPUT par_vlparcel,
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic ) NO-ERROR.

               IF  ERROR-STATUS:ERROR THEN
                   DO:
                      ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
                      LEAVE Dados.
                   END.

               IF  RETURN-VALUE <> "OK" THEN        
                   LEAVE Dados.

            END.

        /* Nao validar para tela MATRIC Inclusao, pois validaçao deverá chamar apos a gravaçao
           e replicaçao da estrutura de pessao  */    
           
        IF par_nmdatela <> 'MATRIC' OR 
           par_cddopcao <> 'I' THEN
        DO:   
          IF   par_inpessoa = 1    AND 
               par_idorigem <> 1   AND
               par_dtnasctl <> ?   AND
               par_verrespo = TRUE THEN
               DO:
                  IF VALID-HANDLE(h-b1wgen9999) THEN
                     DELETE OBJECT h-b1wgen9999.
                
                  RUN sistema/generico/procedures/b1wgen9999.p
                      PERSISTENT SET h-b1wgen9999.
                
                  /* validar pela procedure generica do b1wgen9999.p */
                  RUN idade IN h-b1wgen9999 (INPUT par_dtnasctl,
                                             INPUT par_dtmvtolt,
                                             OUTPUT par_nrdeanos,
                                             OUTPUT par_nrdmeses,
                                             OUTPUT par_dsdidade ).
                
                  IF  VALID-HANDLE(h-b1wgen9999) THEN
                      DELETE OBJECT h-b1wgen9999.

                  IF  NOT CAN-FIND(FIRST crapcrl WHERE 
                                         crapcrl.cdcooper = par_cdcooper AND
                                         crapcrl.nrctamen = par_nrdconta AND
                                         crapcrl.idseqmen = 1) AND
                    ((par_inhabmen = 0    AND
                      par_nrdeanos < 18)  OR
                      par_inhabmen = 2  ) AND 
                      par_nrdconta > 0    THEN
                      DO:
                         ASSIGN aux_dscritic = "Cooperado menor de idade. " + 
                                               "Obrigatorio Responsavel Legal.".
                         LEAVE Dados.
                      END.

                  IF NOT VALID-HANDLE(h-b1wgen0072) THEN
                     RUN sistema/generico/procedures/b1wgen0072.p 
                              PERSISTENT SET h-b1wgen0072.
                     
                  FOR EACH tt-crapcrl:
                      CREATE tt-cratcrl.
                      BUFFER-COPY tt-crapcrl TO tt-cratcrl.
                  END.

                  FOR EACH tt-resp NO-LOCK:
               
                      RUN Valida_Dados IN h-b1wgen0072 
                                          (INPUT par_cdcooper,    
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT tt-resp.nrctamen,
                                           INPUT tt-resp.idseqmen,
                                           INPUT YES,
                                           INPUT tt-resp.nrdrowid,
                                           INPUT par_dtmvtolt,
                                           INPUT tt-resp.cddopcao,
                                           INPUT tt-resp.nrdconta,
                                           INPUT tt-resp.nrcpfcgc,
                                           INPUT tt-resp.nmrespon,
                                           INPUT tt-resp.tpdeiden,
                                           INPUT tt-resp.nridenti,
                                           INPUT tt-resp.dsorgemi,
                                           INPUT tt-resp.cdufiden,
                                           INPUT tt-resp.dtemiden,
                                           INPUT tt-resp.dtnascin,
                                           INPUT tt-resp.cddosexo,
                                           INPUT tt-resp.cdestciv,
                                           INPUT tt-resp.cdnacion,
                                           INPUT tt-resp.dsnatura,
                                           INPUT tt-resp.cdcepres,
                                           INPUT tt-resp.dsendres,
                                           INPUT tt-resp.dsbaires,
                                           INPUT tt-resp.dscidres,
                                           INPUT tt-resp.dsdufres,
                                           INPUT tt-resp.nmmaersp,
                                           INPUT NO,         
                                           INPUT tt-resp.nrcpfmen,
                                           INPUT "Identificacao",
                                           INPUT par_dtnasctl,
                                           INPUT par_inhabmen,
                                           INPUT par_permalte,
                                           INPUT TABLE tt-cratcrl,
                                           OUTPUT par_nmdcampo,
                                           OUTPUT TABLE tt-erro).
                     
                      IF   RETURN-VALUE <> "OK" THEN
                           DO:
                              IF VALID-HANDLE(h-b1wgen0072) THEN
                                 DELETE PROCEDURE(h-b1wgen0072).
                           
                              ASSIGN aux_geraerro = TRUE.
                           
                              LEAVE Dados.
                           
                           END.
                     
                  END.  
             
                  IF VALID-HANDLE(h-b1wgen0072) THEN
                     DELETE PROCEDURE(h-b1wgen0072).              

             END.
           END.

        /* Se esta na inclusao, gerar a nova conta no final da validacao */
        /* Somente Ayllos Web */
        IF   par_cddopcao = "I"    AND  
             par_idorigem = 5       THEN
             DO:
                 /* Se a conta ainda nao foi gerada, obter */
                 /* Senao devolver a conta ja criada  */
                 IF   par_nrdconta = 0   THEN
                      RUN Retorna_Conta (INPUT par_cdcooper,
                                         INPUT par_idorigem,
                                        OUTPUT par_nrctanov).
                 ELSE 
                      ASSIGN par_nrctanov = par_nrdconta.
             
             END.
            

        ASSIGN aux_returnvl = "OK"
               aux_dscritic = "".

        LEAVE Dados.

    END.

    IF  VALID-HANDLE(hb1wgen0052v) THEN
        DELETE OBJECT hb1wgen0052v.

    IF  aux_returnvl = "NOK" AND (aux_dscritic = "" AND aux_cdcritic = 0) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".

    IF aux_geraerro = FALSE THEN
       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           DO:
              ASSIGN aux_returnvl = "NOK".
       
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,           
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
           END.
       ELSE
           ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl = "NOK" THEN
        DO:
           ASSIGN aux_dstransa = "Valida dados do Associado".

           RUN proc_gerar_log (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT aux_dscritic,
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT (IF aux_returnvl = "OK" THEN 
                                         YES 
                                      ELSE 
                                         NO),
                               INPUT par_idseqttl, 
                               INPUT par_nmdatela, 
                               INPUT par_nrdconta, 
                              OUTPUT aux_nrdrowid).

        END.

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Retorna_Conta:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_nrdconta AS INTE                            NO-UNDO.

    DEF VAR h-b1wgen0052b AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999  AS HANDLE                                  NO-UNDO.


    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN sistema/generico/procedures/b1wgen0052b.p PERSISTENT SET h-b1wgen0052b.

    DO WHILE TRUE:

       /* Buscar nova conta para o cooperado */
       RUN STORED-PROCEDURE pc_sequence_progress
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPASS"
                                                ,INPUT "NRDCONTA"
                                                ,INPUT STRING(par_cdcooper)
                                                ,INPUT ""
                                                ,INPUT "").
          
       CLOSE STORED-PROC pc_sequence_progress
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
       ASSIGN par_nrdconta = INTE(pc_sequence_progress.pr_sequence)
                               WHEN pc_sequence_progress.pr_sequence <> ?.
            

       /* Conta reservada para Cia. Hering */
       IF   (par_nrdconta >= 95000    AND    par_nrdconta <= 100000)   THEN
             NEXT.

       /* Validar conta */
       RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                             INPUT-OUTPUT par_nrdconta,
                                   OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"    THEN
            NEXT.

       /* Validacoes da conta */
       RUN Verifica_Inclui IN h-b1wgen0052b (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_idorigem,
                                            OUTPUT aux_cdcritic,
                                            OUTPUT aux_dscritic).

       IF   RETURN-VALUE <> "OK"   THEN
            NEXT.

       LEAVE.

    END.

    DELETE PROCEDURE h-b1wgen0052b.
    DELETE PROCEDURE h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Valida_Cidades:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.	
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida cidade de atuacao da cooperativa.".

    Valida_Cidades: DO ON ERROR UNDO Valida_Cidades, LEAVE Valida_Cidades:
        
        EMPTY TEMP-TABLE tt-erro.
    
        /* Cidades de atuacao da cooperativa */
        FOR EACH tbgen_cid_atuacao_coop WHERE 
                 tbgen_cid_atuacao_coop.cdcooper = par_cdcooper NO-LOCK:

            /* Verifica se a cidade do cooperado tem atuacao da cooperativa */
            FIND FIRST crapmun WHERE 
                       crapmun.cdcidade = tbgen_cid_atuacao_coop.cdcidade   AND
                       crapmun.cdestado = par_cdufende                      AND
                       crapmun.dscidade = par_nmcidade                      
                       NO-LOCK NO-ERROR.

            /* Se achou, e' porque a cooperativa */
            /* atende na cidade do cooperado */
            IF   AVAIL crapmun   THEN
                 RETURN "OK".

        END.

    END.
    
    /* Se chegou aqui, e' porque a cidade do cooperado nao tem  */
    /* atuacao da cooperativa */
    ASSIGN aux_dscritic = "Cidade do CEP nao pertence a regiao de " + 
                          "atendimento da Cooperativa.".

    RUN gera_erro (INPUT par_cdcooper,
                   INPUT par_cdagenci,
                   INPUT par_nrdcaixa,
                   INPUT 1,           
                   INPUT aux_cdcritic,
                   INPUT-OUTPUT aux_dscritic).

    RETURN "NOK".

END PROCEDURE.


/* ------------------------------------------------------------------------ */
/*                VALIDA INICIO DO PROCEDIMENTO PARA INCLUSAO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Inicio_Inclusao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR hb1wgen0052v AS HANDLE                                  NO-UNDO.
     
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida inicio da inclusao do Associado".

    EMPTY TEMP-TABLE tt-erro.
    
    IF  NOT VALID-HANDLE(hb1wgen0052v) THEN
        RUN sistema/generico/procedures/b1wgen0052v.p
            PERSISTENT SET hb1wgen0052v.
        
    RUN Valida_Inicio_Inclusao IN hb1wgen0052v (INPUT par_cdcooper,
                                                INPUT par_nrdconta,
                                                INPUT par_inpessoa,
                                                INPUT par_cdagepac,
                                                INPUT par_idorigem,
                                                INPUT par_dtmvtolt,
                                               OUTPUT par_nmdcampo,
                                               OUTPUT aux_cdcritic,
                                               OUTPUT aux_dscritic).

    IF  VALID-HANDLE(hb1wgen0052v)  THEN
        DELETE OBJECT hb1wgen0052v.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Erro na validacao dos dados.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           
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

    RETURN "OK".

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*               REALIZA A VALIDACAO DOS DADOS DO PROCURADOR                */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Procurador:

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
    DEF  INPUT PARAM TABLE FOR tt-crapavt.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR hb1wgen0052v AS HANDLE                                  NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = "Erro na validacao dos Procuradores. "
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Procurador: DO ON ERROR UNDO Procurador, LEAVE Procurador:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(hb1wgen0052v) THEN
            RUN sistema/generico/procedures/b1wgen0052v.p
                PERSISTENT SET hb1wgen0052v.

        RUN Valida_Procurador IN hb1wgen0052v
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_dtmvtolt,
              INPUT TABLE tt-crapavt,
             OUTPUT par_nmdcampo,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               LEAVE Procurador.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Procurador.

        ASSIGN 
            aux_returnvl = "OK"
            aux_dscritic = "".
        
        LEAVE Procurador.
    END.

    IF  VALID-HANDLE(hb1wgen0052v) THEN
        DELETE OBJECT hb1wgen0052v.

    IF  aux_returnvl = "NOK" AND (aux_dscritic = "" AND aux_cdcritic = 0) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl = "NOK" THEN
        DO:
           ASSIGN aux_dstransa = "Valida dados do Procurador".

           RUN proc_gerar_log (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT aux_dscritic,
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                               INPUT par_idseqttl, 
                               INPUT par_nmdatela, 
                               INPUT par_nrdconta, 
                              OUTPUT aux_nrdrowid).
        END.

    RETURN aux_returnvl.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*               REALIZA A VALIDACAO DO PARCELAMENTO DE CAPITAL             */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Parcelamento:

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
    DEF  INPUT PARAM par_dtdebito AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtparcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlparcel AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-parccap.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR hb1wgen0052v AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dscritic = "Erro na validacao do Parcelamento de Capital. "
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Parcelamento: DO ON ERROR UNDO Parcelamento, LEAVE Parcelamento:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(hb1wgen0052v) THEN
            RUN sistema/generico/procedures/b1wgen0052v.p
                PERSISTENT SET hb1wgen0052v.

        RUN Valida_Parcelamento IN hb1wgen0052v
            ( INPUT par_cdcooper,
              INPUT par_dtmvtolt,
              INPUT par_dtdebito,
              INPUT par_qtparcel,
              INPUT par_vlparcel,
             OUTPUT par_msgretor,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic,
             OUTPUT TABLE tt-parccap ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               LEAVE Parcelamento.
            END.

        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            LEAVE Parcelamento.

        ASSIGN
            aux_returnvl = "OK"
            aux_dscritic = "".
        
        LEAVE Parcelamento.
    END.

    IF  VALID-HANDLE(hb1wgen0052v) THEN
        DELETE OBJECT hb1wgen0052v.

    IF  aux_returnvl = "NOK" AND (aux_dscritic = "" AND aux_cdcritic = 0) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl = "NOK" THEN
        DO:
           ASSIGN aux_dstransa = "Valida dados do Parcelamento de Capital".

           RUN proc_gerar_log (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT aux_dscritic,
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                               INPUT par_idseqttl, 
                               INPUT par_nmdatela, 
                               INPUT par_nrdconta, 
                              OUTPUT aux_nrdrowid).
        END.

    RETURN aux_returnvl.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*               REALIZA A GRAVACAO DOS DADOS DO ASSOCIADO                  */
/* ------------------------------------------------------------------------ */
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
    DEF  INPUT PARAM par_cdcnae   AS INTE                           NO-UNDO.                      
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
    DEF  INPUT PARAM par_dtabertu AS DATE                           NO-UNDO.
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
    DEF  INPUT PARAM TABLE FOR tt-crapcrl.
    DEF  INPUT PARAM TABLE FOR tt-bens.

	DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrlicamb AS DECI                           NO-UNDO.
	DEF  INPUT PARAM par_nmsocial AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgctsal AS LOG                            NO-UNDO.
	
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgconta AS CHARACTER                               NO-UNDO.
    DEF VAR aux_msgalert AS CHARACTER                               NO-UNDO.
    DEF VAR aux_nmrotina AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INT                                     NO-UNDO.
    DEF VAR aux_tiposdoc AS INT                                     NO-UNDO.
    DEF VAR aux_nrdeanos AS INT                                     NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrctanov AS INTE                                    NO-UNDO.
    DEF VAR aux_qtparcel AS INTE                                    NO-UNDO.
    DEF VAR aux_vlparcel AS DECI                                    NO-UNDO.
    DEF VAR aux_msgretor AS CHAR                                    NO-UNDO.   
    DEF VAR aux_nrcpfcgc AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_idseqttl AS INT                                     NO-UNDO.

    DEF VAR hb1wgen0052g AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0137 AS HANDLE                                  NO-UNDO.


    DEF BUFFER crabavt FOR crapavt.    
	
	ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = "Erro na gravacao dos dados. "
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nmrotina = ""
           aux_dsrotina = "".
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        ASSIGN par_idseqttl = 1.

        /* Se for pessoa fisica vamos gravar o idseqttl como 1 */
        IF  par_inpessoa = 1 THEN
            ASSIGN aux_idseqttl = 1.
        ELSE
            ASSIGN aux_idseqttl = 0.

        IF  par_cddopcao = "A" OR
            par_cddopcao = "I" OR 
            par_cddopcao = "X" OR 
            par_cddopcao = "D" OR
            par_cddopcao = "J" THEN
            DO:
                ASSIGN aux_dscritic = "".

                IF  par_cddopcao = "A" OR 
                    par_cddopcao = "X" OR
                    par_cddopcao = "J"THEN
                    DO:
                        
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdconta
                                           NO-LOCK NO-ERROR.
                       
                       
                        IF  NOT AVAIL crapass THEN
                            DO: 
                                ASSIGN aux_dscritic = "Erro ao consultar conta.".
                      
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1, /*sequencia*/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".
                            END.
                            
                        IF  par_inpessoa = 1 THEN
                            DO:
                                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                           crapttl.nrdconta = par_nrdconta AND
                                           crapttl.idseqttl = par_idseqttl
                                           NO-LOCK NO-ERROR.
                        
                                IF  NOT AVAIL crapttl  THEN
                                    DO:
                                        ASSIGN aux_dscritic = "Erro ao consultar titular.".
                      
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT 1, /*sequencia*/
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).

                                        RETURN "NOK".    

                                    END.
                                aux_nrcpfcgc = crapttl.nrcpfcgc.
                            END.
                        ELSE 
                          aux_nrcpfcgc = crapass.nrcpfcgc.
                       
                        IF  par_cddopcao = "X" OR 
                            par_cddopcao = "J" THEN
                            DO:
                                
                                IF  par_nmprimtl <> crapass.nmprimtl OR 
                                    par_nrcpfcgc <> crapass.nrcpfcgc THEN
                                    DO:
                                        IF par_nrcpfcgc <> crapass.nrcpfcgc THEN
                                            aux_nrcpfcgc = par_nrcpfcgc.
	
                                        IF  par_inpessoa = 1 THEN
                                            DO:
                                            
                                                IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                                    RUN sistema/generico/procedures/b1wgen0137.p 
                                                    PERSISTENT SET h-b1wgen0137.
                                                  
                                                RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                          ( INPUT par_cdcooper,
                                                            INPUT par_nrdconta,
                                                            INPUT par_idseqttl,
                                                            INPUT aux_nrcpfcgc,
                                                            INPUT par_dtmvtolt,
                                                            INPUT "1", /* CPF - CADASTRO DE PESSOAS FISICAS */
                                                            INPUT par_cdoperad,
                                                           OUTPUT aux_cdcritic,
                                                           OUTPUT aux_dscritic).

                                                IF  VALID-HANDLE(h-b1wgen0137) THEN
                                                  DELETE OBJECT h-b1wgen0137.
                                                
                                            END.
                                        ELSE
                                            DO:
                                                IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                                    RUN sistema/generico/procedures/b1wgen0137.p 
                                                    PERSISTENT SET h-b1wgen0137.
                                                  
                                                RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                          ( INPUT par_cdcooper,
                                                            INPUT par_nrdconta,
                                                            INPUT par_idseqttl,
                                                            INPUT aux_nrcpfcgc,
                                                            INPUT par_dtmvtolt,
                                                            INPUT "10", /* CARTAO DE CNPJ */
                                                            INPUT par_cdoperad,
                                                           OUTPUT aux_cdcritic,
                                                           OUTPUT aux_dscritic).

                                                IF  VALID-HANDLE(h-b1wgen0137) THEN
                                                  DELETE OBJECT h-b1wgen0137.
                                                
                                            END.
                                    END.
                                
                                /* Se o CPF/CGC foi alterado, vamos atualizar o campos crapavt.nrcpfcgc */
                                IF  par_nrcpfcgc <> crapass.nrcpfcgc THEN
                                    DO:
                                        /* Pesquisamos todos os avalistas que possuem a conta que teve o CPF/CGC alterado
                                           e atualizamos o CPF/CGC onde essa conta eh conta da pessoa contato */
                                        FOR EACH crapavt WHERE crapavt.cdcooper = crapass.cdcooper
                                                           AND crapavt.nrdctato = crapass.nrdconta /* Conta pessoa contato */
                                                           AND crapavt.tpctrato = 6 /* Juridico */
                                                           NO-LOCK.

                                            ContadorAvt: DO ON ENDKEY UNDO ContadorAvt, LEAVE ContadorAvt
                                                            ON ERROR  UNDO ContadorAvt, LEAVE ContadorAvt:

                                                FIND FIRST crabavt WHERE  ROWID(crabavt) = ROWID(crapavt)
                                                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                                DO aux_contador = 1 TO 10:
            
                                                    IF  NOT AVAILABLE crabavt THEN
                                                        DO:
                                                            IF  LOCKED(crabavt) THEN
                                                                DO:
                                                                    IF aux_contador = 10 THEN
                                                                        DO:                                                                            
                                                                            ASSIGN aux_cdcritic = 341.
                                                                            LEAVE ContadorAvt.
                                                                        END.
                                                                    ELSE 
                                                                        DO: 
                                                                            PAUSE 1 NO-MESSAGE.
                                                                            NEXT.
                                                                        END.
                                                                END.                                                            
                                                        END.
                                                    ELSE
                                                        DO:
                                                            ASSIGN crapavt.nrcpfcgc = par_nrcpfcgc.
                                                            LEAVE ContadorAvt.
                                                        END.
                                                END.
                                            END.
                                        END.
																				
																				/* Atualiza cpf na tabela de eventos */
                                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                        /* Efetuar a chamada a rotina Oracle  */
                                        RUN STORED-PROCEDURE pc_atualiza_matric_j
                                                                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                                                                      INPUT par_nrdconta,
                                                                                                      INPUT par_nrcpfcgc,
                                                                                                     OUTPUT 0,   /* pr_cdcritic */
                                                                                                     OUTPUT ""). /* pr_dscritic */  
                                        
                                        /* Fechar o procedimento para buscarmos o resultado */ 
                                        CLOSE STORED-PROC pc_atualiza_matric_j
                                                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                        
                                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
																				
                                    END.
                            END.

                        IF  par_cddopcao = "A" THEN
                            DO:
                                ASSIGN aux_dscritic = "".

                                    /*DESDEMISSAO*/    
                                    IF  crapass.dtdemiss <> ? AND
                                        par_dtdemiss = ? THEN
                                        DO:
                                        
                                            IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                                RUN sistema/generico/procedures/b1wgen0137.p 
                                                PERSISTENT SET h-b1wgen0137.
                                              
                                            RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                      ( INPUT par_cdcooper,
                                                        INPUT par_nrdconta,
                                                        INPUT aux_idseqttl,
                                                        INPUT aux_nrcpfcgc,
                                                        INPUT par_dtmvtolt,
                                                        INPUT "54", /* FICHA CADASTRAL */
                                                        INPUT par_cdoperad,
                                                       OUTPUT aux_cdcritic,
                                                       OUTPUT aux_dscritic).

                                            IF  VALID-HANDLE(h-b1wgen0137) THEN
                                              DELETE OBJECT h-b1wgen0137.
                                                                                        
                                        END.

                                IF  par_inpessoa = 1 THEN
                                    DO:                                    
                                    IF par_tpdocptl <> crapass.tpdocptl OR
                                       par_nrdocptl <> crapass.nrdocptl THEN
                                        DO:
                                            IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                                RUN sistema/generico/procedures/b1wgen0137.p 
                                                PERSISTENT SET h-b1wgen0137.
                                              
                                            RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                      ( INPUT par_cdcooper,
                                                        INPUT par_nrdconta,
                                                        INPUT par_idseqttl,
                                                        INPUT aux_nrcpfcgc,
                                                        INPUT par_dtmvtolt,
                                                        INPUT "2", /* CARTEIRA IDENTIFICAÇAO */
                                                        INPUT par_cdoperad,
                                                       OUTPUT aux_cdcritic,
                                                       OUTPUT aux_dscritic).

                                            IF  VALID-HANDLE(h-b1wgen0137) THEN
                                              DELETE OBJECT h-b1wgen0137.
                                              
                                            
                                            
                                        END.
                                    END.
                                    /* verificar estado civil somente para PF */
                                    IF  CAN-DO("2,3,4,8,9,11,12", STRING(par_cdestcvl)) AND
                                        par_inpessoa = 1 THEN
                                        DO:
                                            IF par_cdestcvl <> crapttl.cdestcvl THEN
                                                DO:
                                                    IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                                        RUN sistema/generico/procedures/b1wgen0137.p 
                                                        PERSISTENT SET h-b1wgen0137.
                                                      
                                                    RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                              ( INPUT par_cdcooper,
                                                                INPUT par_nrdconta,
                                                                INPUT par_idseqttl,
                                                                INPUT aux_nrcpfcgc,
                                                                INPUT par_dtmvtolt,
                                                                INPUT "4", /* COMPROVANTE DE ESTADO CIVIL */
                                                                INPUT par_cdoperad,
                                                               OUTPUT aux_cdcritic,
                                                               OUTPUT aux_dscritic).

                                                    IF  VALID-HANDLE(h-b1wgen0137) THEN
                                                      DELETE OBJECT h-b1wgen0137.
                                                    
                                                END.
                                        END.
                            END. /* Fim opcao A */
                    END. /* Fim do cddopcao = A or X */
                ELSE IF par_cddopcao = "I" THEN
                    DO:
                        aux_nrcpfcgc = par_nrcpfcgc.
                        
                        ASSIGN aux_dscritic = "".
                        IF  par_inpessoa = 1 THEN
                            DO:
                                /* Gerar pendencia de: 
                                          -> Contrato Abertura de Conta PF          
                                          -> ficha cadastral
                                          -> matricula 
                                          -> carteira de identificacao 
                                          -> CPF 
                                          -> comprovante de endereço 
                                          -> cartao assinatura */
                                IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                    RUN sistema/generico/procedures/b1wgen0137.p 
                                    PERSISTENT SET h-b1wgen0137.
                                  
                                RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                          ( INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT aux_nrcpfcgc,
                                            INPUT par_dtmvtolt,
                                            /* 45 - CONTRATO ABERTURA DE CONTA PF 
                                               54 - FICHA CADASTRAL 
                                                8 - MATRICULA
                                                2 - CARTEIRA IDENTIFICAÇAO 
                                                1 - CPF - CADASTRO DE PESSOAS FISICAS 
                                                3 - COMPROVANTE DE ENDEREÇO 
                                                6 - CARTAO DE ASSINATURA */
                                            INPUT "8;2;1;3;6", 
                                            INPUT par_cdoperad,
                                           OUTPUT aux_cdcritic,
                                           OUTPUT aux_dscritic).

                                IF  VALID-HANDLE(h-b1wgen0137) THEN
                                  DELETE OBJECT h-b1wgen0137.
                                

                                /* Gerar pendencia de estado civil */
                                /* Gerar pendencia de conjuge */
                                IF  CAN-DO("2,3,4,8,9,11,12", STRING(par_cdestcvl)) THEN
                                    DO:
                                        IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                            RUN sistema/generico/procedures/b1wgen0137.p 
                                            PERSISTENT SET h-b1wgen0137.
                                          
                                        RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                  ( INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT aux_nrcpfcgc,
                                                    INPUT par_dtmvtolt,
                                                    /* 4 - COMPROVANTE DE ESTADO CIVIL
                                                      22 - DOCUMENTOS DO CONJUGE */
                                                    INPUT "4;22", 
                                                    INPUT par_cdoperad,
                                                   OUTPUT aux_cdcritic,
                                                   OUTPUT aux_dscritic).

                                        IF  VALID-HANDLE(h-b1wgen0137) THEN
                                          DELETE OBJECT h-b1wgen0137. 
                                                                                  
                                    END.
                                
                                IF par_inhabmen = 1 THEN /*Menor habilitado*/
                                   DO:
                                     IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                         RUN sistema/generico/procedures/b1wgen0137.p 
                                         PERSISTENT SET h-b1wgen0137.
                                        
                                     RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                                ( INPUT par_cdcooper,
                                                  INPUT par_nrdconta, 
                                                  INPUT par_idseqttl,
                                                  INPUT aux_nrcpfcgc,
                                                  INPUT par_dtmvtolt, 
                                                  /*
                                                      59 - Documento de Emancipaçao 
                                                  */
                                                  INPUT "59", 
                                                    INPUT par_cdoperad,
                                                   OUTPUT aux_cdcritic,
                                                   OUTPUT aux_dscritic).

                                        IF  VALID-HANDLE(h-b1wgen0137) THEN
                                          DELETE OBJECT h-b1wgen0137. 
                                                                                  
                                    END.
                                

                                /* responsaveis  */
                                IF par_idorigem <> 5 THEN DO:
                                   IF VALID-HANDLE(h-b1wgen9999) THEN
                                      DELETE OBJECT h-b1wgen9999.
                                   RUN sistema/generico/procedures/b1wgen9999.p
                                       PERSISTENT SET h-b1wgen9999.
                                   /* validar pela procedure generica do b1wgen9999.p */
                                   RUN idade IN h-b1wgen9999 ( INPUT par_dtnasctl,
                                                               INPUT par_dtmvtolt,
                                                              OUTPUT aux_nrdeanos,
                                                              OUTPUT aux_nrdmeses,
                                                              OUTPUT aux_dsdidade ).
                                   IF  VALID-HANDLE(h-b1wgen9999) THEN
                                       DELETE OBJECT h-b1wgen9999.
                                   
                                   IF  NOT CAN-FIND(FIRST tt-crapcrl WHERE 
                                                          tt-crapcrl.cdcooper = par_cdcooper AND
                                                          tt-crapcrl.nrctamen = par_nrdconta AND
                                                          tt-crapcrl.idseqmen = 1) AND
                                     ((par_inhabmen = 0    AND
                                       aux_nrdeanos < 18)  OR
                                       par_inhabmen = 2  ) AND
                                       par_nrdconta > 0    THEN
                                   DO:
                                      ASSIGN aux_dscritic = "Cooperado menor de idade. " + 
                                                            "Obrigatorio Responsavel Legal.".
                                   END.
                            END.
                                /* fim responsaveis */

                            END. /* fim do pessoa fisica */
                        ELSE /* Juridica */
                            DO:
                                /* Gerar pendencia de: 
                                          -> Contrato Abertura de Conta PJ
                                          -> ficha cadastral
                                          -> matricula 
                                          -> CARTAO DE CNPJ  
                                          -> comprovante de endereço */
                                IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                                    RUN sistema/generico/procedures/b1wgen0137.p 
                                    PERSISTENT SET h-b1wgen0137.
                                  
                                RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                                          ( INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT 0,
                                            INPUT aux_nrcpfcgc,
                                            INPUT par_dtmvtolt,
                                            /* 46 - CONTRATO ABERTURA DE CONTA PJ 
                                               10 - CARTAO DE CNPJ 
                                                3 - COMPROVANTE DE ENDEREÇO                                                 
                                               54 - FICHA CADASTRAL                                                 
                                                8 - MATRICULA */
                                            INPUT "46;10;3;54;8", 
                                            INPUT par_cdoperad,
                                           OUTPUT aux_cdcritic,
                                           OUTPUT aux_dscritic).

                                IF  VALID-HANDLE(h-b1wgen0137) THEN
                                  DELETE OBJECT h-b1wgen0137.
                                
                            END. /* Fim do juridica */
                    END. /* Fim da opcao I */
            END. /* if par_cddopcao = "A,X,I" */
 
        IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            UNDO Grava, LEAVE Grava.

        IF NOT VALID-HANDLE(hb1wgen0052g) THEN
           DO:
              RUN sistema/generico/procedures/b1wgen0052g.p
                  PERSISTENT SET hb1wgen0052g NO-ERROR.
                  
              IF  ERROR-STATUS:ERROR THEN 
                  DO:
                     ASSIGN aux_dscritic = {&GET-MSG}.
                     UNDO Grava, LEAVE Grava.
                  END.
           END.
        
           RUN Valida_Dados
               ( INPUT par_cdcooper,
                 INPUT par_cdagenci,
                 INPUT par_nrdcaixa,
                 INPUT par_cdoperad,
                 INPUT par_nmdatela,
                 INPUT par_idorigem,
                 INPUT par_nrdconta,
                 INPUT par_idseqttl,
                 INPUT par_flgerlog,
                 INPUT par_cddopcao,
                 INPUT par_dtmvtolt,
                 INPUT par_inpessoa,
                 INPUT par_cdagepac,                 
                 INPUT STRING(par_nrcpfcgc),
                 INPUT par_nmprimtl, 
                 INPUT ?,
                 INPUT "",
                 INPUT par_nmpaittl,
                 INPUT par_nmmaettl,
                 INPUT par_nmconjug,
                 INPUT par_cdempres,
                 INPUT par_cdsexotl,
                 INPUT par_cdsitcpf,
                 INPUT 0,
                 INPUT par_dtcnscpf,
                 INPUT par_dtnasctl,
                 INPUT par_tpnacion,
                 INPUT par_cdnacion,
                 INPUT par_dsnatura,
                 INPUT par_cdufnatu,
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
                 INPUT par_cdufende,
                 INPUT par_dsendere,
                 INPUT par_nrendere,
                 INPUT par_nmbairro,
                 INPUT par_nmcidade,
                 INPUT par_complend,
                 INPUT par_nrcepend,
                 INPUT par_nrcxapst,
                 INPUT par_dtabertu,
                 INPUT par_natjurid,
                 INPUT par_nmfansia,
                 INPUT par_nrinsest,
                 INPUT par_cdseteco,
                 INPUT par_cdrmativ,
                 INPUT par_nrdddtfc,
                 INPUT par_nrtelefo,
                 INPUT 0,
                 INPUT FALSE,
                 INPUT TRUE,
                 INPUT FALSE,
                 INPUT par_inhabmen,
                 INPUT par_dthabmen,
                 INPUT TABLE tt-crapavt,
                 INPUT TABLE tt-crapcrl,
                OUTPUT aux_nrctanov,
                OUTPUT aux_qtparcel,
                OUTPUT aux_vlparcel,
                OUTPUT aux_nmdcampo,
                OUTPUT aux_msgretor,
                OUTPUT aux_nrdeanos,
                OUTPUT aux_nrdmeses,
                OUTPUT aux_dsdidade,
                OUTPUT TABLE tt-alertas,
                OUTPUT TABLE tt-erro,
                OUTPUT TABLE tt-prod_serv_ativos).
                 
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               UNDO Grava, LEAVE Grava.
            END.
        
        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.
        

        RUN Grava_Dados IN hb1wgen0052g
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT par_flgerlog,
              INPUT par_cddopcao,
              INPUT par_dtmvtolt,
              INPUT par_dtmvtoan,
              INPUT par_rowidass,
              INPUT par_inpessoa,
              INPUT par_cdagepac,
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
              INPUT par_cdcnae,
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
              INPUT par_dtabertu,
              INPUT par_natjurid,
              INPUT par_nmfansia,
              INPUT par_nrinsest,
              INPUT par_cdseteco,
              INPUT par_cdrmativ,
              INPUT par_nrdddtfc,
              INPUT par_nrtelefo,
              INPUT par_dtdebito,
              INPUT par_qtparcel,
              INPUT par_vlparcel,
              INPUT par_inhabmen,
              INPUT par_dthabmen,
              INPUT par_nmttlrfb,
              INPUT par_inconrfb,
              INPUT par_hrinicad,
              INPUT TABLE tt-crapavt,
              INPUT TABLE tt-bens,
              INPUT par_idorigee,
              INPUT par_nrlicamb,
			  INPUT par_nmsocial,
              INPUT par_flgctsal,
             OUTPUT par_msgretor,
             OUTPUT aux_cdcritic,
             OUTPUT aux_dscritic,
             OUTPUT log_tpatlcad,
             OUTPUT log_msgatcad,
             OUTPUT log_chavealt,
             OUTPUT log_msgrecad,
             OUTPUT TABLE tt-crapass-ant,
             OUTPUT TABLE tt-crapass-atl ) NO-ERROR.
        
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + {&GET-MSG}.
               UNDO Grava, LEAVE Grava.
            END.

        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.
        

        IF NOT VALID-HANDLE(h-b1wgen0072) THEN
           RUN sistema/generico/procedures/b1wgen0072.p 
               PERSISTENT SET h-b1wgen0072.

        IF par_idseqttl = 2 THEN
           ASSIGN aux_nmrotina = "MATRIC_JUR".
        ELSE
           ASSIGN aux_nmrotina = "MATRIC".

        FOR EACH tt-crapcrl:
            CREATE tt-resp.
            BUFFER-COPY tt-crapcrl TO tt-resp.
        END.

        FOR EACH tt-resp WHERE tt-resp.cddopcao = "E" AND
                               tt-resp.cddopcao = "I" AND
                               tt-resp.cddopcao = "A" NO-LOCK:

            RUN Grava_Dados IN h-b1wgen0072
                            (INPUT par_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT 1,
                             INPUT tt-resp.nrctamen,
                             INPUT tt-resp.idseqmen,
                             INPUT YES,
                             INPUT tt-resp.nrdrowid,
                             INPUT par_dtmvtolt,
                             INPUT tt-resp.cddopcao,
                             INPUT tt-resp.nrdconta,
                             INPUT (IF tt-resp.nrdconta = 0 THEN
                                       tt-resp.nrcpfcgc
                                    ELSE
                                       0),
                             INPUT tt-resp.nmrespon,
                             INPUT tt-resp.tpdeiden,
                             INPUT tt-resp.nridenti,
                             INPUT tt-resp.dsorgemi,
                             INPUT tt-resp.cdufiden,
                             INPUT tt-resp.dtemiden,
                             INPUT tt-resp.dtnascin,
                             INPUT tt-resp.cddosexo,
                             INPUT tt-resp.cdestciv,
                             INPUT tt-resp.cdnacion,
                             INPUT tt-resp.dsnatura,
                             INPUT INT(tt-resp.cdcepres),
                             INPUT tt-resp.dsendres,
                             INPUT tt-resp.dsbaires,
                             INPUT tt-resp.dscidres,
                             INPUT tt-resp.nrendres,
                             INPUT tt-resp.dsdufres,
                             INPUT tt-resp.dscomres,
                             INPUT tt-resp.nrcxpost,
                             INPUT tt-resp.nmmaersp,
                             INPUT tt-resp.nmpairsp,
                             INPUT (IF tt-resp.nrctamen = 0 THEN 
                                       tt-resp.nrcpfmen
                                    ELSE
                                       0),
                             INPUT tt-resp.cdrlcrsp,
                             INPUT aux_nmrotina,
                             OUTPUT aux_msgalert,
                             OUTPUT aux_tpatlcad,
                             OUTPUT aux_msgatcad, 
                             OUTPUT aux_chavealt, 
                             OUTPUT TABLE tt-erro).

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  IF VALID-HANDLE(h-b1wgen0072) THEN
                     DELETE PROCEDURE(h-b1wgen0072).

                  UNDO Grava, LEAVE Grava.

               END.  

        END.

        IF VALID-HANDLE(h-b1wgen0072) THEN
           DELETE PROCEDURE(h-b1wgen0072).

        IF  RETURN-VALUE <> "OK" THEN
            UNDO Grava, LEAVE Grava.

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
            IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic).

        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.

        IF VALID-HANDLE(h-b1wgen0168) THEN
           DELETE PROCEDURE(h-b1wgen0168).
        /* FIM - Atualizar os dados da tabela crapcyb */

        ASSIGN aux_returnvl = "OK"
               aux_dscritic = ""
               aux_cdcritic = 0.

        LEAVE Grava.

    END.

    IF  VALID-HANDLE(hb1wgen0052g) THEN
        DELETE OBJECT hb1wgen0052g.

    IF  aux_returnvl = "NOK"       AND 
       (aux_dscritic = ""          AND 
        aux_cdcritic = 0)          AND 
        NOT CAN-FIND(LAST tt-erro) THEN
        ASSIGN aux_dscritic = "Retorno de processamento incorreto, falta " +
                              "mensagem/critica.".
    
    IF (aux_dscritic <> ""        OR 
        aux_cdcritic <> 0)        AND 
        NOT CAN-FIND(LAST tt-erro) THEN
        DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF NOT CAN-FIND(LAST tt-erro) THEN
       ASSIGN aux_returnvl = "OK".
    
    IF aux_returnvl = "OK" AND
       par_cddopcao <> "D" THEN
       Cad_Restritivo:
       DO WHILE TRUE:
          /*Monta a mensagem da rotina para envio no e-mail*/
          IF par_cddopcao = "I" THEN
             ASSIGN aux_dsrotina = "Abertura da conta "              +
                                   STRING(par_nrdconta,"zzzz,zzz,9") + 
                                   " - CPF/CNPJ "                    +
                                   (IF par_inpessoa = 1 THEN 
                                       STRING((STRING(par_nrcpfcgc,
                                                      "99999999999")),
                                                      "xxx.xxx.xxx-xx")
                                   ELSE
                                      STRING((STRING(par_nrcpfcgc,
                                                     "99999999999999")),
                                                     "xx.xxx.xxx/xxxx-xx")).
          ELSE
             ASSIGN aux_dsrotina = "Alteracao dos dados "            + 
                                   "do associado conta "             +
                                   STRING(par_nrdconta,"zzzz,zzz,9") + 
                                   " - CPF/CNPJ "                    +
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
                 PERSISTEN SET h-b1wgen0110.

          /*Verifica se o associado esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT par_nrcpfcgc, 
                                            INPUT par_nrdconta, 
                                            INPUT par_idseqttl,
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 28,    /*cdoperac*/
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
          
                ASSIGN aux_returnvl = "NOK".

                LEAVE Cad_Restritivo.
          
             END.

          LEAVE Cad_Restritivo.

       END.

    IF par_flgerlog THEN
       DO:
          CASE par_cddopcao:
              WHEN "A" THEN ASSIGN aux_tpdopcao = 3.
              WHEN "X" THEN ASSIGN aux_tpdopcao = 4.
              WHEN "I" THEN ASSIGN aux_tpdopcao = 6.
              WHEN "D" THEN ASSIGN aux_tpdopcao = 7.
              WHEN "J" THEN ASSIGN aux_tpdopcao = 8.
              OTHERWISE ASSIGN aux_tpdopcao = 1.

          END CASE.
          /* Caso seja efetuada alguma alteracao na descricao deste log,
             devera ser tratado o relatorio de "demonstrativo produtos por
             colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
          ASSIGN aux_dstransa = "Grava dados do Associado - Opcao[" + 
                                par_cddopcao + "] " + 
                                aux_dsdopcao[aux_tpdopcao] .

          FIND FIRST tt-crapass-ant NO-ERROR.

          FIND FIRST tt-crapass-atl NO-ERROR.

          RUN proc_gerar_log_tab
              ( INPUT par_cdcooper,
                INPUT par_cdoperad,
                INPUT aux_dscritic,
                INPUT aux_dsorigem,
                INPUT aux_dstransa,
                INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                INPUT par_idseqttl,
                INPUT par_nmdatela,
                INPUT par_nrdconta,
                INPUT YES,
                INPUT BUFFER tt-crapass-ant:HANDLE,
                INPUT BUFFER tt-crapass-atl:HANDLE ).

       END.

    RETURN aux_returnvl.

END PROCEDURE.


PROCEDURE busca_contas_demitidas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
	DEF INPUT  PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtdregis AS INTE                           NO-UNDO.
	DEF OUTPUT PARAM par_vlrtotal AS DEC                            NO-UNDO.

	DEF OUTPUT PARAM TABLE FOR tt-contas_demitidas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
	
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
	DEF VAR aux_nrregist AS INT                                     NO-UNDO.
    DEF VAR aux_vldcotas LIKE crapcot.vldcotas					    NO-UNDO.
	
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
		   aux_nrregist = par_nrregist.

	IF par_nrdconta <> 0  THEN
	   DO:
	      FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
				 			 crapass.nrdconta = par_nrdconta
							 NO-LOCK NO-ERROR.                       
                       
	 	  IF  NOT AVAIL crapass THEN
			  DO: 
				  ASSIGN aux_cdcritic = 9.
                      
				  RUN gera_erro (INPUT par_cdcooper,
					 			 INPUT par_cdagenci,
							 	 INPUT par_nrdcaixa,
						 		 INPUT 1, /*sequencia*/
					 			 INPUT aux_cdcritic,
								 INPUT-OUTPUT aux_dscritic).

				  RETURN "NOK".
			 END.
			 
	   END.

    FOR EACH crapass FIELDS(cdcooper nrdconta inpessoa nmprimtl cdmotdem dtdemiss)
					 WHERE  crapass.cdcooper = par_cdcooper  AND				           
					       (par_nrdconta = 0                 OR
						    crapass.nrdconta = par_nrdconta) AND
						   (crapass.cdsitdct = 4             OR
						    crapass.cdsitdct = 7             OR
						    crapass.cdsitdct = 8            ) AND
							crapass.dtelimin = ? 
						    NO-LOCK:
		
		ASSIGN aux_vldcotas = 0.
		
		    
			
			FIND FIRST crapcot WHERE crapcot.cdcooper = crapass.cdcooper AND
									 crapcot.nrdconta = crapass.nrdconta AND
									 crapcot.vldcotas > 0
									 NO-LOCK NO-ERROR.
									   
			IF NOT AVAIL crapcot THEN
			   NEXT.			
		
			ASSIGN aux_vldcotas = crapcot.vldcotas.
				
		
			
		ASSIGN par_qtdregis = par_qtdregis + 1
		       par_vlrtotal = par_vlrtotal + aux_vldcotas.

		/* controles da paginação */
		IF  (par_qtdregis < par_nriniseq                    OR
			par_qtdregis > (par_nriniseq + par_nrregist))  THEN
			NEXT.
			
		IF aux_nrregist > 0 THEN
		   DO:					  			
				CREATE tt-contas_demitidas.
		
				ASSIGN tt-contas_demitidas.cdcooper = crapass.cdcooper
					   tt-contas_demitidas.nrdconta = crapass.nrdconta
					   tt-contas_demitidas.inpessoa = crapass.inpessoa
					   tt-contas_demitidas.nmprimtl = crapass.nmprimtl
					   tt-contas_demitidas.vldcotas = aux_vldcotas
					   tt-contas_demitidas.dtdemiss = crapass.dtdemiss
					   tt-contas_demitidas.mtdemiss = crapass.cdmotdem
					   tt-contas_demitidas.qtdparce = 1
					   tt-contas_demitidas.formadev = 1 /*No ato*/													  
					   tt-contas_demitidas.datadevo = TODAY.

				
		   END. 

		ASSIGN aux_nrregist = aux_nrregist - 1.     

	END.
	
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Produtos_Servicos_Ativos:
	
	/* entrada e saida */
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
	DEF OUTPUT PARAM TABLE FOR tt-prod_serv_ativos.
	
    DEF VAR h-b1wgen0052v AS HANDLE                                NO-UNDO.
    DEF VAR aux_cdcritic  AS INT 								   NO-UNDO.
	DEF VAR aux_dscritic  AS CHAR                                  NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0052v.p PERSISTENT SET h-b1wgen0052v.
				
    RUN Produtos_Servicos_Ativos IN h-b1wgen0052v(   INPUT par_cdcooper,
												     INPUT par_dtdemiss,
													 INPUT par_cdagenci,
													 INPUT par_nrdcaixa,
													 INPUT par_cdoperad,
													 INPUT par_nmdatela,
													 INPUT par_idorigem,
													 INPUT par_nrdconta,
													 INPUT par_idseqttl,
													 INPUT par_flgerlog,
													 INPUT par_dtmvtolt,
													OUTPUT aux_cdcritic,
													OUTPUT aux_dscritic,
													OUTPUT TABLE tt-prod_serv_ativos).
													
    IF  VALID-HANDLE( h-b1wgen0052v)  THEN
        DELETE OBJECT  h-b1wgen0052v.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Erro ao verificar servicos ativos.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).           

            RETURN "NOK".
        END.
										
	 RETURN "OK".
	 
END PROCEDURE.										
/*............................................................................*/