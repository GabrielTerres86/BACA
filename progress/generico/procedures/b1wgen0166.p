/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0166.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Agosto/2013                               Alteracao: 18/10/2018

    Objetivo  : Alterar, consultar, incluir e gerar relatório de empresas.

    Alteracoes: 21/11/2013 - Alteração para adequar o fonte no padrão CECRED
    
                05/03/2014 - Inclusao de VALIDATE crapemp e craptab (Carlos)
                
                25/03/2014 - Conteudo do log cademp_t.log alterado para o log
                             cademp.log para aparecer na tela logtel. Procedure
                             gera_log excluida (Carlos)
                             
                02/06/2014 - Concatena o numero do servidor no endereco do
                             terminal (Tiago-RKAM).
                
                12/06/2014 - Ajustar mensagem de critica do Codigo Empresa Sistema
                             Folha na "Valida_empresa" (Douglas - Chamado 122814)
                             
                14/07/2014 - Melhoria da procedure Define_cdempres (Carlos)
                
                05/08/2014 - Inclusão da opção de Pesquisa por Empresas (Vanessa)
                
                13/01/2015 - Inclusão de validacao na rotina valida_empresa
                             para obrigar informar o CNPJ (nrdocnpj) para 
                             empresas com emprestimo consignado (indescsg=2)
                             Ref Doc3040 - Ente Consignante - Marcos(Supero)
                          
                21/01/2015 - Alteracao na procedure Terceiro_quinto_dia_util. 
                             A data que deve ser verificada no find da crapfer existente 
                             no loop eh a dtavisos e nao o parametro par_dtferiad.
                             Dessa forma o código fica igual ao existente na crps659.
                             (Alisson - AMcom)             
                
                25/02/2015 - Inclusao do ano na validacao da exibicao da critica
                             da POUP. PROGRAMADA/COTAS/EMPRESTIMOS. 
                             (Jaison/Gielow - SD: 253206)
                             
                17/06/2015 - Prj-158 - Alteracoes no Layout, inclusao de novos campos
                             na tela. (Andre Santos - SUPERO)
                             
                08/07/2015 - Adicionado verificacao de codigo da empresa nao pode
                             ser 0. (Jorge/Elton) - Emergencial
                             
                28/10/2015 - Alteracao de INT para CHAR o par_cdoperad na 
                             Gera_arquivo_log. (Jaison/Marcos SUPERO)
                             
                25/11/2015 - Ajustando a busca dos valores de tarifas dos
                             convenios. (Andre Santos - SUPERO)
 
                27/11/2015 - Incluir substr na inclusao/alteracao nos campos
                             nmextemp e nmresemp, tambem ajustado procedure
                             Gera_arquivo_log_2 (Lucas Ranghetti #357980)

                15/02/2016 - Inclusao do parametro conta na chamada da
                             fn_valor_tarifa_folha. (Jaison/Marcos)

        				15/03/2016 - Correção nos cadastros de empresas com & (e comercial)
				              			 no nome, desta forma limpando este caracter do mesmo.
							               (Carlos Rafael Tanholi - SD 413044)           
							 
                12/04/2016 - Incluir crapemp.cdoperad na procedure Altera_inclui 
                             (Lucas Ranghetti #410302)
                                                                          
                18/05/2016 - Inclusao do campo dtlimdeb. (Jaison/Marcos)							                                                

                17/06/2016 - Inclusão de campos de controle de vendas - M181
                             ( Rafael Maciel - RKAM)

                04/08/2016 - SD495726 - Folha: Correcao gravacao/alteracao
                             de empresa (Guilherme/SUPERO)
                             
                26/09/2016 - Alterar na procedure Altera_inclui, para gravarmos 
                             a data de inclusao/cancelamento do produto Folha
                             (Lucas Ranghetti #480384)

                21/10/2016 - Ajuste na mascara do cdempres na "Busca_Conta_Emp"
                             (Guilherme/SUPERO)

				17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

                04/04/2018 - Adicionada chamada pc_valida_adesao_produto para verificar se o 
                             tipo de conta permite a contrataçao do produto. PRJ366 (Lombardi).
							 
                05/10/2018 - Adicionada validacao de CNPJ nao existente na procedure Altera_inclui. PRJ437 (CIS).							 

				18/10/2018 - Ajuste na gravacao dos campos indicadores de aviso de debito na
				             procedure Altera_inclui para considerar o valor ja gravado na tabela
							 caso exista. Necessario para evitar duplicidade de geracao de registro
							 na crapavs - INC0025297. (Fabricio)

                12/04/2016 - Ajuste nas rotinas Altera_inclui, Gera_arquivo_log e Imprime_relacao para gravar/alterar, gerar log
				             e imprimir o campo nrdddemp  da tabela crapemp - P437 - Consignado Josiane stiehler - AMcom.

                29/08/2019 PJ485.6 - Ajuste na rotina de gera�ao do c�digo da empresa (9999 sempre sera empresa PF) - Augusto (Supero)                     

.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0166tt.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/ayllos/includes/var_online.i NEW }

/* DEFINE VARIABLE aux_cdcritic AS INTEGER     NO-UNDO. */
DEF STREAM str_1. /* Relacao de Empresas */
DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

PROCEDURE Busca_empresas:
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdbusca AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdpesqui AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdempres AS INTEGER     NO-UNDO.
    
   
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapemp.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VAR aux_dscritic  AS CHAR                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapemp.

    IF par_cdempres >= 0 THEN
        FOR EACH crapemp NO-LOCK WHERE
                 crapemp.cdcooper = par_cdcooper
                 AND crapemp.cdempres =  par_cdempres   :
           
           CREATE tt-crapemp.
           BUFFER-COPY crapemp TO tt-crapemp.
           
           FIND FIRST crapass WHERE crapass.cdcooper = crapemp.cdcooper
                                AND crapass.nrdconta = crapemp.nrdconta
                                NO-LOCK NO-ERROR.

           IF  AVAIL crapass THEN
               ASSIGN tt-crapemp.nmextttl = crapass.nmprimtl.

           FIND FIRST crapcfp WHERE crapcfp.cdcooper = crapemp.cdcooper
                                AND crapcfp.cdcontar = crapemp.cdcontar
                                NO-LOCK NO-ERROR.

           IF  AVAIL crapcfp THEN
               ASSIGN tt-crapemp.dscontar = crapcfp.dscontar.

        END.

    ELSE DO:

        IF  par_nmdbusca = "" AND par_idorigem = 5 THEN DO:
            ASSIGN aux_dscritic = "Campo de pesquisa deve ser informado!".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

        IF par_cdpesqui = 0 THEN /*Pesquisa pela Razão Social*/
            FOR EACH crapemp NO-LOCK WHERE
                     crapemp.cdcooper = par_cdcooper
                     AND crapemp.nmextemp MATCHES("*" + par_nmdbusca + "*")   :
                CREATE tt-crapemp.
                BUFFER-COPY crapemp TO tt-crapemp.

                FIND FIRST crapass WHERE crapass.cdcooper = crapemp.cdcooper
                                AND crapass.nrdconta = crapemp.nrdconta
                                NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    ASSIGN tt-crapemp.nmextttl = crapass.nmprimtl.

                FIND FIRST crapcfp WHERE crapcfp.cdcooper = crapemp.cdcooper
                                AND crapcfp.cdcontar = crapemp.cdcontar
                                NO-LOCK NO-ERROR.

               IF  AVAIL crapcfp THEN
                   ASSIGN tt-crapemp.dscontar = crapcfp.dscontar.

            END. 
        ELSE /* Pesquisa pelo Nome da Empresa*/
            FOR EACH crapemp NO-LOCK WHERE
                     crapemp.cdcooper = par_cdcooper
                     AND crapemp.nmresemp MATCHES("*" + par_nmdbusca + "*")   :
                CREATE tt-crapemp.
                BUFFER-COPY crapemp TO tt-crapemp.

                FIND FIRST crapass WHERE crapass.cdcooper = crapemp.cdcooper
                                AND crapass.nrdconta = crapemp.nrdconta
                                NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    ASSIGN tt-crapemp.nmextttl = crapass.nmprimtl.

                FIND FIRST crapcfp WHERE crapcfp.cdcooper = crapemp.cdcooper
                                AND crapcfp.cdcontar = crapemp.cdcontar
                                NO-LOCK NO-ERROR.

                IF  AVAIL crapcfp THEN
                    ASSIGN tt-crapemp.dscontar = crapcfp.dscontar.

            END.

    END.

    IF  NOT TEMP-TABLE tt-crapemp:HAS-RECORDS THEN 
        DO:
            ASSIGN aux_dscritic = "Nenhuma Empresa encontrada.".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_tabela:
    
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmsistem LIKE craptab.nmsistem NO-UNDO.
    DEFINE INPUT  PARAMETER par_tptabela LIKE craptab.tptabela NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdempres LIKE craptab.cdempres NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdacesso LIKE craptab.cdacesso NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpregist LIKE craptab.tpregist NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-craptab.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VAR aux_dscritic  AS CHAR                       NO-UNDO.

    EMPTY TEMP-TABLE tt-craptab.
    EMPTY TEMP-TABLE tt-erro.
  
    FIND craptab WHERE
         craptab.cdcooper = par_cdcooper AND
         craptab.nmsistem = par_nmsistem AND
         craptab.tptabela = par_tptabela AND
         craptab.cdempres = par_cdempres AND
         craptab.cdacesso = par_cdacesso AND
         craptab.tpregist = par_tpregist 
         NO-LOCK NO-ERROR.
    IF  AVAIL craptab THEN 
        DO:
            CREATE tt-craptab.
            BUFFER-COPY craptab TO tt-craptab.
        END.
    ELSE 
        DO:
            ASSIGN aux_dscritic = "Tabela não encontrada.".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_dados_associado:

    DEF INPUT  PARAM par_cdcooper AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE               NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE               NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados-ass.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-dados-ass.
    EMPTY TEMP-TABLE tt-erro.

    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_cdcritic AS INTE                        NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                        NO-UNDO.

    /* Busca os dados do associado*/
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         AND crapass.inpessoa <> 1
                         AND crapass.dtdemiss = ?
                         NO-LOCK NO-ERROR.

    /* Busca os dados de complemento do associado */
    FIND FIRST crapenc WHERE crapenc.cdcooper = crapass.cdcooper
                         AND crapenc.nrdconta = crapass.nrdconta
                         AND crapenc.cdseqinc = 1
                         AND crapenc.idseqttl = 1
                          NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapenc THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nao foi localizados os dados do associado!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        RETURN "NOK".
    END.

    /* Criando o Registro */
    CREATE tt-dados-ass.

    /* Buscando o nome do Procurador - CONTATO */
    FIND FIRST crapavt WHERE crapavt.cdcooper = crapass.cdcooper
                         AND crapavt.nrdconta = crapass.nrdconta
                         AND crapavt.tpctrato = 6 /* Procuradores */
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapavt THEN DO:

        /* Busca o contato */
        FIND FIRST crabass WHERE crabass.cdcooper = crapavt.cdcooper
                             AND crabass.nrdconta = crapavt.nrdctato
                             NO-LOCK NO-ERROR.

        IF  AVAIL crabass THEN
            ASSIGN tt-dados-ass.nmcontat = crabass.nmprimtl.
        ELSE
            ASSIGN tt-dados-ass.nmcontat = "".

    END.

    /* Buscando o nome fantasia */
    FIND FIRST crapjur WHERE crapjur.cdcooper = crapass.cdcooper
                         AND crapjur.nrdconta = crapass.nrdconta
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapjur THEN DO:
        ASSIGN tt-dados-ass.nmfansia = crapjur.nmfansia.
    END.
    
	/* Emails */
    FOR FIRST crapcem FIELDS(dsdemail)
        WHERE crapcem.cdcooper = crapass.cdcooper AND
              crapcem.nrdconta = crapass.nrdconta AND
              crapcem.idseqttl = 1                AND
              crapcem.cddemail = 1 NO-LOCK:
    END.
    
    ASSIGN tt-dados-ass.nmrazsoc = crapass.nmprimtl
           tt-dados-ass.nrcpfcgc = crapass.nrcpfcgc
           tt-dados-ass.dsdemail = crapcem.dsdemail WHEN AVAIL crapcem
           tt-dados-ass.dsendere = crapenc.dsendere
           tt-dados-ass.nrendere = crapenc.nrendere
           tt-dados-ass.complend = crapenc.complend
           tt-dados-ass.nmbairro = crapenc.nmbairro
           tt-dados-ass.nmcidade = crapenc.nmcidade
           tt-dados-ass.cdufende = crapenc.cdufende
           tt-dados-ass.nrcepend = crapenc.nrcepend.

    RETURN "OK".

END.

PROCEDURE Altera_inclui:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_tiptrans AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_inavscot LIKE crapemp.inavscot NO-UNDO.
    DEFINE INPUT  PARAMETER par_inavsemp LIKE crapemp.inavsemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_inavsppr LIKE crapemp.inavsppr NO-UNDO.
    DEFINE INPUT  PARAMETER par_inavsden LIKE crapemp.inavsden NO-UNDO.
    DEFINE INPUT  PARAMETER par_inavsseg LIKE crapemp.inavsseg NO-UNDO.
    DEFINE INPUT  PARAMETER par_inavssau LIKE crapemp.inavssau NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdempres LIKE crapemp.cdempres NO-UNDO.
    DEFINE INPUT  PARAMETER par_idtpempr LIKE crapemp.idtpempr NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta LIKE crapemp.nrdconta NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtultufp LIKE crapemp.dtultufp NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcontat LIKE crapemp.nmcontat NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresemp LIKE crapemp.nmresemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmextemp LIKE crapemp.nmextemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdebemp LIKE crapemp.tpdebemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdebcot LIKE crapemp.tpdebcot NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdebppr LIKE crapemp.tpdebppr NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdempfol LIKE crapemp.cdempfol NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtavscot LIKE crapemp.dtavscot NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtavsemp LIKE crapemp.dtavsemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtavsppr LIKE crapemp.dtavsppr NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgpagto LIKE crapemp.flgpagto NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpconven LIKE crapemp.tpconven NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdufdemp LIKE crapemp.cdufdemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_dscomple LIKE crapemp.dscomple NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdemail LIKE crapemp.dsdemail NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsendemp LIKE crapemp.dsendemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtfchfol LIKE crapemp.dtfchfol NO-UNDO.
    DEFINE INPUT  PARAMETER par_indescsg LIKE crapemp.indescsg NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmbairro LIKE crapemp.nmbairro NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidade LIKE crapemp.nmcidade NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcepend LIKE crapemp.nrcepend NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdocnpj LIKE crapemp.nrdocnpj NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrendemp LIKE crapemp.nrendemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrfaxemp LIKE crapemp.nrfaxemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrfonemp LIKE crapemp.nrfonemp NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgarqrt LIKE crapemp.flgarqrt NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgvlddv LIKE crapemp.flgvlddv NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgpgtib LIKE crapemp.flgpgtib NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdcontar LIKE crapemp.cdcontar NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimfol LIKE crapemp.vllimfol NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgdgfib LIKE crapemp.flgdgfib NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlimdeb LIKE crapemp.dtlimdeb NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdddemp LIKE crapemp.nrdddemp NO-UNDO.
                                                
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INT                               NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                              NO-UNDO.
    DEF VAR aux_contador AS INT     FORMAT "99"               NO-UNDO.
    DEF VAR aux_inpagpen AS INT                               NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_cdempres = 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Codigo da empresa nao pode ser 0".
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.

    /* Verifica se tem pagamentos pendentes antes de remover o acesso ao folha */
    IF  par_flgpgtib = FALSE THEN DO:

        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_busca_pgto_pendente_ib aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdempres,
                             OUTPUT 0,
                             OUTPUT 0,
                             OUTPUT "").
        CLOSE STORED-PROC pc_busca_pgto_pendente_ib aux_statproc = PROC-STATUS
              WHERE PROC-HANDLE = aux_handproc.
    
        ASSIGN aux_inpagpen = 0
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_inpagpen = pc_busca_pgto_pendente_ib.pr_inpagpen
                              WHEN pc_busca_pgto_pendente_ib.pr_inpagpen <> ?
               aux_cdcritic = pc_busca_pgto_pendente_ib.pr_cdcritic
                              WHEN pc_busca_pgto_pendente_ib.pr_cdcritic <> ?
               aux_dscritic = pc_busca_pgto_pendente_ib.pr_dscritic
                              WHEN pc_busca_pgto_pendente_ib.pr_dscritic <> ?.
               
    
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
        IF  aux_cdcritic > 0 OR aux_inpagpen > 0 THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cancelamento nao pode ser efetuado! Existem agendamentos pendentes!".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        
            RETURN "NOK".
        END.

		IF par_tiptrans = "I" THEN DO:
			/* Buscando o cnpj */
			FIND crapemp WHERE crapemp.cdcooper = par_cdcooper
								AND crapemp.nrdocnpj = par_nrdocnpj
								 NO-LOCK NO-ERROR.

			
			
			IF  AVAIL crapemp THEN DO:
				ASSIGN aux_cdcritic = 0
					   aux_dscritic = "CNPJ já vinculado a empresa " + STRING(crapemp.cdempres) + "! Não é possivel cadastrar".
				
				RUN gera_erro (INPUT par_cdcooper,
							   INPUT par_cdagenci,
							   INPUT par_nrdcaixa,
							   INPUT 1,            /** Sequencia **/
							   INPUT aux_cdcritic,
							   INPUT-OUTPUT aux_dscritic).
			
				RETURN "NOK".
    END.
		END.
    END.

    Grava: 
    DO TRANSACTION
          ON ERROR  UNDO Grava, LEAVE Grava
          ON QUIT   UNDO Grava, LEAVE Grava
          ON STOP   UNDO Grava, LEAVE Grava
          ON ENDKEY UNDO Grava, LEAVE Grava:

        FIND FIRST tt-crapemp NO-ERROR.

        DO  aux_contador = 1 TO 10:
            FIND crapemp WHERE
                 crapemp.cdcooper = par_cdcooper AND
                 crapemp.cdempres = par_cdempres 
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapemp   THEN
                IF  LOCKED crapemp   THEN
                    DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        CREATE crapemp.
                        LEAVE.
                    END.    
            ELSE
                aux_cdcritic = 0.
            
            LEAVE.
        END.  /*  Fim do DO .. TO  */

        IF  aux_cdcritic > 0  THEN
            DO:
                ASSIGN aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        
                RETURN "NOK".
            END.

        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        IF  AVAIL crapemp THEN 
            DO:
			    /* SD 413044 */
                par_nmextemp = REPLACE(par_nmextemp,"&","").
                par_nmresemp = REPLACE(par_nmresemp,"&","").

                /* Se alterou(Incluiu/Alterou) o inidicador de servico de folha de pagamento,
                  iremos atualizar a data de Inclusao do servico ou Cancelamento */
                IF  crapemp.flgpgtib <> par_flgpgtib THEN
                    ASSIGN crapemp.dtinccan = TODAY. 

                ASSIGN crapemp.cdempfol = par_cdempfol
                       crapemp.cdempres = par_cdempres
                       crapemp.dtavscot = par_dtavscot
                       crapemp.dtavsemp = par_dtavsemp
                       crapemp.dtavsppr = par_dtavsppr
                       crapemp.flgpagto = par_flgpagto
                       crapemp.flgarqrt = par_flgarqrt
                       crapemp.nmextemp = SUBSTR(par_nmextemp,1,35)
                       crapemp.nmresemp = SUBSTR(par_nmresemp,1,15)
                       crapemp.dtfchfol = par_dtfchfol
                       crapemp.cdufdemp = par_cdufdemp
                       crapemp.nmbairro = SUBSTR(par_nmbairro,1,15)
                       crapemp.nmcidade = par_nmcidade
                       crapemp.dscomple = SUBSTR(par_dscomple,1,50)
                       crapemp.nrendemp = par_nrendemp
                       crapemp.dsendemp = par_dsendemp
                       crapemp.nrcepend = par_nrcepend
                       crapemp.nrfonemp = par_nrfonemp
                       crapemp.nrfaxemp = par_nrfaxemp
                       crapemp.nrdocnpj = par_nrdocnpj
                       crapemp.dsdemail = par_dsdemail
                       crapemp.flgvlddv = par_flgvlddv
                       crapemp.inavscot = IF crapemp.inavscot = ? THEN par_inavscot ELSE crapemp.inavscot
                       crapemp.inavsemp = IF crapemp.inavsemp = ? THEN par_inavsemp ELSE crapemp.inavsemp
                       crapemp.inavsppr = IF crapemp.inavsppr = ? THEN par_inavsppr ELSE crapemp.inavsppr
                       crapemp.inavsden = IF crapemp.inavsden = ? THEN par_inavsden ELSE crapemp.inavsden
                       crapemp.inavsseg = IF crapemp.inavsseg = ? THEN par_inavsseg ELSE crapemp.inavsseg
                       crapemp.inavssau = IF crapemp.inavssau = ? THEN par_inavssau ELSE crapemp.inavssau
                       crapemp.tpconven = par_tpconven
                       crapemp.tpdebcot = par_tpdebcot
                       crapemp.tpdebemp = par_tpdebemp
                       crapemp.tpdebppr = par_tpdebppr
                       crapemp.indescsg = par_indescsg
                       crapemp.cdcooper = par_cdcooper
                       crapemp.idtpempr = par_idtpempr
                       crapemp.nrdconta = par_nrdconta
                       crapemp.dtultufp = IF crapemp.dtultufp = ? THEN TODAY ELSE crapemp.dtultufp
                       crapemp.flgpgtib = par_flgpgtib
                       crapemp.cdcontar = par_cdcontar
                       crapemp.vllimfol = par_vllimfol
                       crapemp.nmcontat = par_nmcontat
                       /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                       crapemp.cdopeori = par_cdoperad
                       crapemp.cdageori = par_cdagenci
                       crapemp.dtinsori = TODAY
                       /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                       crapemp.flgdgfib = IF par_flgdgfib THEN FALSE ELSE crapemp.flgdgfib
                       crapemp.dtlimdeb = par_dtlimdeb
                       crapemp.cdoperad = par_cdoperad
                       crapemp.nrdddemp = par_nrdddemp.
                       
                VALIDATE crapemp.
            END.
    END.

    RELEASE crapemp.
    RETURN 'OK':U.

END PROCEDURE.

PROCEDURE Grava_tabela:
    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHARACTER   NO-UNDO.

    DEF INPUT PARAM par_nmsistem LIKE craptab.nmsistem NO-UNDO.
    DEF INPUT PARAM par_tptabela LIKE craptab.tptabela NO-UNDO.
    DEF INPUT PARAM par_cdempres LIKE craptab.cdempres NO-UNDO.
    DEF INPUT PARAM par_cdacesso LIKE craptab.cdacesso NO-UNDO.
    DEF INPUT PARAM par_tpregist LIKE craptab.tpregist NO-UNDO.
    DEF INPUT PARAM par_dstextab LIKE craptab.dstextab NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    Grava:
    DO  TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:
        FIND craptab WHERE
             craptab.cdcooper = par_cdcooper AND
             craptab.nmsistem = par_nmsistem AND
             craptab.tptabela = par_tptabela AND
             craptab.cdempres = par_cdempres AND
             craptab.cdacesso = par_cdacesso AND
             craptab.tpregist = par_tpregist 
             EXCLUSIVE-LOCK 
             NO-ERROR.
        IF  NOT AVAIL craptab THEN DO:
            CREATE craptab.
            ASSIGN craptab.cdcooper = par_cdcooper
                   craptab.nmsistem = par_nmsistem
                   craptab.tptabela = par_tptabela
                   craptab.cdempres = par_cdempres
                   craptab.cdacesso = par_cdacesso
                   craptab.tpregist = par_tpregist.
            VALIDATE craptab.
        END.

        ASSIGN craptab.dstextab = par_dstextab.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_feriado:
    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtferiad LIKE crapfer.dtferiad NO-UNDO.

    DEF OUTPUT PARAM par_feriad AS LOGICAL NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapfer WHERE
         crapfer.cdcooper = par_cdcooper AND
         crapfer.dtferiad = par_dtferiad 
    NO-LOCK NO-ERROR.

    ASSIGN par_feriad = AVAIL crapfer.

    RETURN "OK".

END PROCEDURE.

/*** retorna terceiro ou quinto dia util do mes. **/
PROCEDURE Terceiro_quinto_dia_util:
    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtferiad LIKE crapfer.dtferiad NO-UNDO. /* dtavisos */

    DEF OUTPUT PARAM aux_dtavisos AS DATE       NO-UNDO.
    DEF OUTPUT PARAM aux_dtavs001 AS DATE       NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR  aux_qtdiasut AS INTEGER            NO-UNDO.
    EMPTY TEMP-TABLE tt-erro.


    ASSIGN aux_dtavisos = 
           IF  MONTH(par_dtmvtolt) = 12  THEN
               DATE(1,1,YEAR(par_dtmvtolt) + 1)
           ELSE
               DATE(MONTH(par_dtmvtolt) + 1,1,YEAR(par_dtmvtolt))
           aux_dtavisos = aux_dtavisos - DAY(aux_dtavisos)
           aux_dtavs001 = aux_dtavisos
           aux_qtdiasut = 0.

    DO  WHILE aux_qtdiasut < 5:

        FIND FIRST crapfer WHERE
         crapfer.cdcooper = par_cdcooper AND
         crapfer.dtferiad = aux_dtavisos /* par_dtferiad */ 
        NO-LOCK NO-ERROR.

        IF  WEEKDAY(aux_dtavisos) = 1 OR 
            WEEKDAY(aux_dtavisos) = 7 OR
            AVAIL crapfer THEN.
        ELSE
            aux_qtdiasut = aux_qtdiasut + 1.

        IF  aux_qtdiasut < 5  THEN
            aux_dtavisos = aux_dtavisos - 1.

        IF  aux_qtdiasut < 3  THEN
            aux_dtavs001 = aux_dtavs001 - 1.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Define_cdempres:
    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHARACTER   NO-UNDO.

    DEF OUTPUT PARAM par_cdempres AS INTEGER INITIAL 0 NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /* Validaçao para empresa PF (9999) */
    FIND LAST crapemp WHERE crapemp.cdcooper = par_cdcooper AND crapemp.cdempres <> 9999.
        NO-LOCK NO-ERROR.
    
    IF AVAIL crapemp THEN
    DO:
        ASSIGN par_cdempres = crapemp.cdempres + 1.
        /* Se o proximo for 9999 (empresa PF) retorna 10.000 */
        IF par_cdempres = 9999 THEN
          ASSIGN par_cdempres = 10000.
    END.
    ELSE
        ASSIGN par_cdempres = 1.

    IF par_nmdatela = "AIMAROWEB" THEN
       ASSIGN par_cdempres = 0.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_empresa:

    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_indescsg AS LOG                NO-UNDO.
    DEF INPUT PARAM par_nrdocnpj LIKE crapemp.nrdocnpj NO-UNDO.
    DEF INPUT PARAM par_dtfchfol LIKE crapemp.dtfchfol NO-UNDO.
    DEF INPUT PARAM par_cdempfol LIKE crapemp.cdempfol NO-UNDO.
    DEF INPUT PARAM par_flgpagto LIKE crapemp.flgpagto NO-UNDO.
    DEF INPUT PARAM old_dtavsemp LIKE crapemp.dtavsemp NO-UNDO.
    DEF INPUT PARAM par_dtavsemp LIKE crapemp.dtavsemp NO-UNDO.
    DEF INPUT PARAM old_dtavscot LIKE crapemp.dtavscot NO-UNDO.
    DEF INPUT PARAM par_dtavscot LIKE crapemp.dtavscot NO-UNDO.
    DEF INPUT PARAM old_dtavsppr LIKE crapemp.dtavsppr NO-UNDO.
    DEF INPUT PARAM par_dtavsppr LIKE crapemp.dtavsppr NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis auxiliares */
    DEF VAR aux_dscritic  AS CHAR                      NO-UNDO.
        

    EMPTY TEMP-TABLE tt-erro.


    /* DEF VAR aux_cdcritic AS INT NO-UNDO. */

	/* P437 Validacao na tela
    IF  par_indescsg = FALSE AND
        par_dtfchfol > 0     THEN DO:

        ASSIGN aux_dscritic = "Dia Fechamento Folha deve ser igual a '0'.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 0,
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
	*/

    /* Para emprestimo consignado em folha */
    IF  par_indescsg = TRUE THEN DO:
        
        /* Validacao do dia de fechamendo da folha */
        IF (par_dtfchfol = 0 OR par_dtfchfol > 28) THEN DO:
            
            ASSIGN aux_dscritic = "Dia Fechamento Folha deve ser entre 1 e 28.".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
        
        /* Obrigar um CNPJ valido */
       
        /* Se houve erro na conversao para DEC, faz a critica */
        DEC(par_nrdocnpj) NO-ERROR.
        IF  ERROR-STATUS:ERROR THEN
            DO:
                ASSIGN aux_dscritic = "CPF/CNPJ contem caracteres invalidos, deve" +
                                      " possuir apenas numeros.".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 0,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            
        /* Se nao foi enviando CNPJ */
        IF (DEC(par_nrdocnpj) = 0) THEN
            DO:
                ASSIGN aux_dscritic = "CNPJ obrigatorio para Emprestimo Consignado.".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 0,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

    END.
    

    IF  par_flgpagto = FALSE AND
        par_cdempfol > 0     THEN
        DO:
            ASSIGN aux_dscritic = "Codigo da Empresa Sistema Folha deve ser igual a '0'.".
            RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 0,
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  par_flgpagto = TRUE AND
        par_cdempfol = 0    THEN
        DO:
            ASSIGN aux_dscritic = "Codigo da Empresa Sistema Folha deve ser maior que '0'.".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    /**********************************************************************
     Se a data para geracao de debito for menor ou igual a data atual
     (quer dizer que ja houve debito) e,
     Se a data para geracao de debito for menor que a data nova p/ geracao
     e o Mes da data para geracao de debito for maior ou igual a data nova
     Ira criticar e sair pois ja foi feito o debito neste mes e nao permitira
     alterar para fazer mais um debito no mesmo mes
     *********************************************************************/

    /* EMPRESTIMO */
    IF  old_dtavsemp        <=      par_dtmvtolt   AND
        old_dtavsemp        <       par_dtavsemp   AND
        MONTH(old_dtavsemp) >= MONTH(par_dtavsemp) AND
        YEAR(old_dtavsemp)  >= YEAR(par_dtavsemp)  THEN 
        DO:
            ASSIGN aux_dscritic = "JA HOUVE DEBITO NESTE MES! NAO E POSSIVEL ALTERAR"
                                + " A DATA DE GERACAO DE AVISO DE EMPRESTIMO, EM CASO DE"
                                + " DUVIDAS FAVOR ENTRAR EM CONTATO COM A TI(Magui) PARA"
                                + " ESCLARECIMENTO.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    /* COTAS */
    IF  old_dtavscot        <=      par_dtmvtolt   AND
        old_dtavscot        <       par_dtavscot   AND
        MONTH(old_dtavscot) >= MONTH(par_dtavscot) AND
        YEAR(old_dtavscot)  >= YEAR(par_dtavscot)  THEN 
        DO:
            ASSIGN aux_dscritic = "JA HOUVE DEBITO NESTE MES! NAO E POSSIVEL ALTERAR"
                                + " A DATA DE GERACAO DE AVISO DE COTAS, EM CASO DE"
                                + " DUVIDAS FAVOR ENTRAR EM CONTATO COM A TI(Magui) PARA"
                                + " ESCLARECIMENTO.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    /* POUP. PROGRAMADA */
    IF  old_dtavsppr        <=      par_dtmvtolt   AND
        old_dtavsppr        <       par_dtavsppr   AND
        MONTH(old_dtavsppr) >= MONTH(par_dtavsppr) AND
        YEAR(old_dtavsppr)  >= YEAR(par_dtavsppr)  THEN 
        DO:
            ASSIGN aux_dscritic = "JA HOUVE DEBITO NESTE MES! NAO E POSSIVEL ALTERAR"
                                + " A DATA DE GERACAO DE AVISO DE APLI. PROGR., EM CASO DE"
                                + " DUVIDAS FAVOR ENTRAR EM CONTATO COM A TI(Magui) PARA"
                                + " ESCLARECIMENTO.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Gera_arquivo_log_2:

    DEF INPUT PARAM par_cdcooper LIKE crapass.cdcooper NO-UNDO.
    DEF INPUT PARAM par_cdopcao  AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_cdempres LIKE crapemp.cdempres NO-UNDO.
    DEF INPUT PARAM par_verifi01 AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_verifi02 AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_verifi03 AS CHAR               NO-UNDO.
    
    DEF VAR aux_dsdircop AS CHAR FORMAT "x(20)" NO-UNDO.

    FOR FIRST crapcop FIELD(crapcop.dsdircop) 
        WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        aux_dsdircop = crapcop.dsdircop.
    END.

    /* Quando a data for ? deve-se substituir o valor por '',
    porque o simbolo ? gera erro na linha de comando do unix 
    
    O Comando REPLACE nao funciona para esse caso, pois o
    valor ? nao eh localizado para substituir */

    IF par_verifi01 = ? THEN par_verifi01 = "''".
    IF par_verifi02 = ? THEN par_verifi02 = "''".
    IF par_verifi03 = ? THEN par_verifi03 = "''".

    IF  par_cdopcao = "A" THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '" + 
                          " Operador " + par_cdoperad  +
                          " alterou  o campo "  +  "'" + par_verifi03  + "'" +
                          " de " + "'" + par_verifi02 + "'" + "  para   " + "'" +
                          par_verifi01 + "'" + " na empresa " + STRING(par_cdempres)  + 
                          " >> /usr/coop/"   + 
                          aux_dsdircop       +  
                          "/log/cademp.log").
    ELSE
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '" + 
                          " Operador " + par_cdoperad  +
                          " incluiu  o campo " + "'" + par_verifi03 + "'" + 
                          " com o valor " + "'" + par_verifi01 + "'" + 
                          " na empresa " + STRING(par_cdempres)  + 
                          " >> /usr/coop/"   + 
                          aux_dsdircop       +
                          "/log/cademp.log").
END PROCEDURE.

PROCEDURE Gera_arquivo_log:
    DEF INPUT PARAM par_cdcooper  LIKE crapass.cdcooper NO-UNDO.
    DEF INPUT PARAM par_cdopcao   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt  AS DATE               NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_cdempres  LIKE crapemp.cdempres NO-UNDO.
    DEF INPUT PARAM par_idtpempr  LIKE crapemp.idtpempr NO-UNDO.
    DEF INPUT PARAM par_nrdconta  LIKE crapemp.nrdconta NO-UNDO.
    DEF INPUT PARAM par_dtultufp  LIKE crapemp.dtultufp NO-UNDO.
    DEF INPUT PARAM par_flgpgtib  LIKE crapemp.flgpgtib NO-UNDO.
    DEF INPUT PARAM par_cdcontar  LIKE crapemp.cdcontar NO-UNDO.
    DEF INPUT PARAM par_vllimfol  LIKE crapemp.vllimfol NO-UNDO.
    DEF INPUT PARAM par_nmcontat  LIKE crapemp.nmcontat NO-UNDO.
    DEF INPUT PARAM old_indescsg  AS LOG                NO-UNDO.
    DEF INPUT PARAM par_indescsg  AS LOG                NO-UNDO.
    DEF INPUT PARAM old_dtfchfol  AS INT                NO-UNDO.
    DEF INPUT PARAM par_dtfchfol  AS INT                NO-UNDO.
    DEF INPUT PARAM old_flgpagto  AS LOG                NO-UNDO.
    DEF INPUT PARAM par_flgpagto  AS LOG                NO-UNDO.
    DEF INPUT PARAM old_flgarqrt  AS LOG                NO-UNDO.
    DEF INPUT PARAM par_flgarqrt  AS LOG                NO-UNDO.
    DEF INPUT PARAM old_flgvlddv  AS LOG                NO-UNDO.
    DEF INPUT PARAM par_flgvlddv  AS LOG                NO-UNDO.
    DEF INPUT PARAM old_cdempfol  AS INT                NO-UNDO.
    DEF INPUT PARAM par_cdempfol  AS INT                NO-UNDO.
    DEF INPUT PARAM old_tpconven  AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_tpconven  AS CHAR               NO-UNDO.
    DEF INPUT PARAM old_tpdebemp  AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_tpdebemp  AS CHAR               NO-UNDO.
    DEF INPUT PARAM old_tpdebcot  AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_tpdebcot  AS CHAR               NO-UNDO.
    DEF INPUT PARAM old_tpdebppr  AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_tpdebppr  AS CHAR               NO-UNDO.
    DEF INPUT PARAM old_cdempres  LIKE crapemp.cdempres NO-UNDO.
    DEF INPUT PARAM old_idtpempr  LIKE crapemp.idtpempr NO-UNDO.
    DEF INPUT PARAM old_nrdconta  LIKE crapemp.nrdconta NO-UNDO.
    DEF INPUT PARAM old_dtultufp  LIKE crapemp.dtultufp NO-UNDO.
    DEF INPUT PARAM old_flgpgtib  LIKE crapemp.flgpgtib NO-UNDO.
    DEF INPUT PARAM old_cdcontar  LIKE crapemp.cdcontar NO-UNDO.
    DEF INPUT PARAM old_vllimfol  LIKE crapemp.vllimfol NO-UNDO.
    DEF INPUT PARAM old_nmcontat  LIKE crapemp.nmcontat NO-UNDO.
    DEF INPUT PARAM aux_cdempres  LIKE crapemp.cdempres NO-UNDO.
    DEF INPUT PARAM aux_idtpempr  LIKE crapemp.idtpempr NO-UNDO.
    DEF INPUT PARAM aux_nrdconta  LIKE crapemp.nrdconta NO-UNDO.
    DEF INPUT PARAM aux_dtultufp  LIKE crapemp.dtultufp NO-UNDO.
    DEF INPUT PARAM aux_flgpgtib  LIKE crapemp.flgpgtib NO-UNDO.
    DEF INPUT PARAM aux_cdcontar  LIKE crapemp.cdcontar NO-UNDO.
    DEF INPUT PARAM aux_vllimfol  LIKE crapemp.vllimfol NO-UNDO.
    DEF INPUT PARAM aux_nmcontat  LIKE crapemp.nmcontat NO-UNDO.
    DEF INPUT PARAM old_dtavscot  LIKE crapemp.dtavscot NO-UNDO.
    DEF INPUT PARAM par_dtavscot  LIKE crapemp.dtavscot NO-UNDO.
    DEF INPUT PARAM old_dtavsemp  LIKE crapemp.dtavsemp NO-UNDO.
    DEF INPUT PARAM par_dtavsemp  LIKE crapemp.dtavsemp NO-UNDO.
    DEF INPUT PARAM old_dtavsppr  LIKE crapemp.dtavsppr NO-UNDO.
    DEF INPUT PARAM par_dtavsppr  LIKE crapemp.dtavsppr NO-UNDO.
    DEF INPUT PARAM old_nmextemp  LIKE crapemp.nmextemp NO-UNDO.
    DEF INPUT PARAM par_nmextemp  LIKE crapemp.nmextemp NO-UNDO.
    DEF INPUT PARAM old_nmresemp  LIKE crapemp.nmresemp NO-UNDO.
    DEF INPUT PARAM par_nmresemp  LIKE crapemp.nmresemp NO-UNDO.
    DEF INPUT PARAM old_cdufdemp  LIKE crapemp.cdufdemp NO-UNDO.
    DEF INPUT PARAM par_cdufdemp  LIKE crapemp.cdufdemp NO-UNDO.
    DEF INPUT PARAM old_dscomple  LIKE crapemp.dscomple NO-UNDO.
    DEF INPUT PARAM par_dscomple  LIKE crapemp.dscomple NO-UNDO.
    DEF INPUT PARAM old_dsdemail  LIKE crapemp.dsdemail NO-UNDO.
    DEF INPUT PARAM par_dsdemail  LIKE crapemp.dsdemail NO-UNDO.
    DEF INPUT PARAM old_dsendemp  LIKE crapemp.dsendemp NO-UNDO.
    DEF INPUT PARAM par_dsendemp  LIKE crapemp.dsendemp NO-UNDO.
    DEF INPUT PARAM old_nmbairro  LIKE crapemp.nmbairro NO-UNDO.
    DEF INPUT PARAM par_nmbairro  LIKE crapemp.nmbairro NO-UNDO.
    DEF INPUT PARAM old_nmcidade  LIKE crapemp.nmcidade NO-UNDO.
    DEF INPUT PARAM par_nmcidade  LIKE crapemp.nmcidade NO-UNDO.
    DEF INPUT PARAM old_nrcepend  LIKE crapemp.nrcepend NO-UNDO.
    DEF INPUT PARAM par_nrcepend  LIKE crapemp.nrcepend NO-UNDO.
    DEF INPUT PARAM old_nrdocnpj  LIKE crapemp.nrdocnpj NO-UNDO.
    DEF INPUT PARAM par_nrdocnpj  LIKE crapemp.nrdocnpj NO-UNDO.
    DEF INPUT PARAM old_nrendemp  LIKE crapemp.nrendemp NO-UNDO.
    DEF INPUT PARAM par_nrendemp  LIKE crapemp.nrendemp NO-UNDO.
    DEF INPUT PARAM old_nrfaxemp  LIKE crapemp.nrfaxemp NO-UNDO.
    DEF INPUT PARAM par_nrfaxemp  LIKE crapemp.nrfaxemp NO-UNDO.
    DEF INPUT PARAM old_nrfonemp  LIKE crapemp.nrfonemp NO-UNDO.
    DEF INPUT PARAM par_nrfonemp  LIKE crapemp.nrfonemp NO-UNDO.
    DEF INPUT PARAM old_dtlimdeb  LIKE crapemp.dtlimdeb NO-UNDO.
    DEF INPUT PARAM par_dtlimdeb  LIKE crapemp.dtlimdeb NO-UNDO.
	DEF INPUT PARAM old_nrdddemp  LIKE crapemp.nrdddemp NO-UNDO.
	DEF INPUT PARAM par_nrdddemp  LIKE crapemp.nrdddemp NO-UNDO.

    DEFINE VARIABLE aux_verifi01 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aux_verifi02 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aux_verifi03 AS CHARACTER NO-UNDO.

    /*  Verifica quais campos foram alterados e chama a procedure  */
    IF  old_indescsg <> par_indescsg   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_indescsg)
                    aux_verifi02 = STRING(old_indescsg)
                    aux_verifi03 = "Emprestimo Consignado".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dtfchfol <> par_dtfchfol   THEN
        DO:
            ASSIGN aux_verifi01 = STRING(par_dtfchfol)
                   aux_verifi02 = STRING(old_dtfchfol)
                   aux_verifi03 = "Dia Fechamento Folha".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_flgpagto <> par_flgpagto   THEN
        DO:
            ASSIGN aux_verifi01 = STRING(par_flgpagto)
                   aux_verifi02 = STRING(old_flgpagto)
                   aux_verifi03 = "Integra Folha".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_flgarqrt <> par_flgarqrt   THEN
        DO:
            ASSIGN aux_verifi01 = STRING(par_flgarqrt)
                   aux_verifi02 = STRING(old_flgarqrt)
                   aux_verifi03 = "Gera arq. retorno".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_flgvlddv <> par_flgvlddv   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_flgvlddv)
                    aux_verifi02 = STRING(old_flgvlddv)
                    aux_verifi03 = "Valida DV Cad.Emp.".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_cdempfol <> par_cdempfol   THEN
        DO:
            ASSIGN aux_verifi01 = STRING(par_cdempfol)
                   aux_verifi02 = STRING(old_cdempfol)
                   aux_verifi03 = "Codigo da Empresa Sistema Folha".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_tpconven <> par_tpconven   THEN
        DO:
            ASSIGN aux_verifi01 = par_tpconven
                   aux_verifi02 = old_tpconven
                   aux_verifi03 = "Impressao do Aviso".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_tpdebemp <> par_tpdebemp   THEN
        DO:
            ASSIGN aux_verifi01 = par_tpdebemp
                   aux_verifi02 = old_tpdebemp
                   aux_verifi03 = "Gera Aviso Emprestimo".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_tpdebcot <> par_tpdebcot   THEN
        DO:
            ASSIGN aux_verifi01 = par_tpdebcot
                   aux_verifi02 = old_tpdebcot
                   aux_verifi03 = "Gera Aviso Cotas".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_tpdebppr <> par_tpdebppr   THEN
        DO:
            ASSIGN aux_verifi01 = par_tpdebppr
                   aux_verifi02 = old_tpdebppr
                   aux_verifi03 = "Gera Aviso Apli.Prog.".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_cdempres <> aux_cdempres   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(aux_cdempres)
                    aux_verifi02 = STRING(old_cdempres)
                    aux_verifi03 = "Codigo".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dtavscot <> par_dtavscot   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dtavscot)
                    aux_verifi02 = STRING(old_dtavscot)
                    aux_verifi03 = "Data aviso deb. cotas".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dtavsemp <> par_dtavsemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dtavsemp)
                    aux_verifi02 = STRING(old_dtavsemp)
                    aux_verifi03 = "Data aviso deb. emprestimos".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dtavsppr <> par_dtavsppr   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dtavsppr)
                    aux_verifi02 = STRING(old_dtavsppr)
                    aux_verifi03 = "Data aviso deb. poupanca".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nmextemp <> par_nmextemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nmextemp)
                    aux_verifi02 = STRING(old_nmextemp)
                    aux_verifi03 = "Nome".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nmresemp <> par_nmresemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nmresemp)
                    aux_verifi02 = STRING(old_nmresemp)
                    aux_verifi03 = "Nome resumido".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_cdufdemp <> par_cdufdemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_cdufdemp)
                    aux_verifi02 = STRING(old_cdufdemp)
                    aux_verifi03 = "U.F.".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dscomple <> par_dscomple   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dscomple)
                    aux_verifi02 = STRING(old_dscomple)
                    aux_verifi03 = "Complemento".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.
    
    IF  old_dsdemail <> par_dsdemail   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dsdemail)
                    aux_verifi02 = STRING(old_dsdemail)
                    aux_verifi03 = "E-mail".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dsendemp <> par_dsendemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dsendemp)
                    aux_verifi02 = STRING(old_dsendemp)
                    aux_verifi03 = "Endereco".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nmbairro <> par_nmbairro   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nmbairro)
                    aux_verifi02 = STRING(old_nmbairro)
                    aux_verifi03 = "Bairro".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nmcidade <> par_nmcidade   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nmcidade)
                    aux_verifi02 = STRING(old_nmcidade)
                    aux_verifi03 = "Cidade".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nrcepend <> par_nrcepend   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrcepend)
                    aux_verifi02 = STRING(old_nrcepend)
                    aux_verifi03 = "CEP".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nrdocnpj <> par_nrdocnpj   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrdocnpj)
                    aux_verifi02 = STRING(old_nrdocnpj)
                    aux_verifi03 = "CNPJ".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nrendemp <> par_nrendemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrendemp)
                    aux_verifi02 = STRING(old_nrendemp)
                    aux_verifi03 = "Numero".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nrfaxemp <> par_nrfaxemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrfaxemp)
                    aux_verifi02 = STRING(old_nrfaxemp)
                    aux_verifi03 = "FAX".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nrdddemp <> par_nrdddemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrdddemp)
                    aux_verifi02 = STRING(old_nrdddemp)
                    aux_verifi03 = "DDD".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

		
    IF  old_nrfonemp <> par_nrfonemp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrfonemp)
                    aux_verifi02 = STRING(old_nrfonemp)
                    aux_verifi03 = "Telefone".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_idtpempr <> par_idtpempr   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_idtpempr)
                    aux_verifi02 = STRING(old_idtpempr)
                    aux_verifi03 = "Tipo Empresa".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nrdconta <> par_nrdconta   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nrdconta)
                    aux_verifi02 = STRING(old_nrdconta)
                    aux_verifi03 = "Conta/DV".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dtultufp <> par_dtultufp   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dtultufp)
                    aux_verifi02 = STRING(old_dtultufp)
                    aux_verifi03 = "Data Ultima Oferta".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_nmcontat <> par_nmcontat   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_nmcontat)
                    aux_verifi02 = STRING(old_nmcontat)
                    aux_verifi03 = "Contato".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_flgpgtib <> par_flgpgtib   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_flgpgtib)
                    aux_verifi02 = STRING(old_flgpgtib)
                    aux_verifi03 = "Flag Pagto IB".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_cdcontar <> par_cdcontar   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_cdcontar)
                    aux_verifi02 = STRING(old_cdcontar)
                    aux_verifi03 = "Tipo Cobranca".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_vllimfol <> par_vllimfol   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_vllimfol)
                    aux_verifi02 = STRING(old_vllimfol)
                    aux_verifi03 = "Valor Limite".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

    IF  old_dtlimdeb <> par_dtlimdeb   THEN
        DO:
            ASSIGN  aux_verifi01 = STRING(par_dtlimdeb)
                    aux_verifi02 = STRING(old_dtlimdeb)
                    aux_verifi03 = "Dia Limite Debitos Vinculados".
            RUN Gera_arquivo_log_2(INPUT par_cdcooper, INPUT par_cdopcao,
                                   INPUT par_dtmvtolt, INPUT par_cdoperad,
                                   INPUT par_cdempres, INPUT aux_verifi01,
                                   INPUT aux_verifi02, INPUT aux_verifi03).
        END.

END PROCEDURE.

PROCEDURE Imprime_relacao:
    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHARACTER   NO-UNDO.

    DEF INPUT PARAM par_flgordem AS LOGICAL NO-UNDO. /* Codigo da empresa (yes) / Nome da empresa (no) */

    DEF OUTPUT PARAM par_nmarqpdf AS CHARACTER   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    DEF VAR  aux_dscritic AS CHAR                               NO-UNDO.
    DEF VAR  aux_nmendter AS CHAR    FORMAT "x(20)"             NO-UNDO.
    DEF VAR  aux_server   AS CHAR                               NO-UNDO.
    DEF VAR  aux_nmarqimp AS CHAR                               NO-UNDO.
    DEF VAR  aux_nmarqpdf AS CHAR                               NO-UNDO.

    DEF VAR  h-b1wgen0024 AS HANDLE                             NO-UNDO. 

    /* Para a includes/impressao.i */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    FIND FIRST crapcop NO-LOCK WHERE
               crapcop.cdcooper = par_cdcooper NO-ERROR.

    INPUT THROUGH basename `tty` NO-ECHO.
    
    SET aux_nmendter WITH FRAME f_terminal.
    
    INPUT CLOSE.

    INPUT THROUGH basename `hostname -s` NO-ECHO.
    IMPORT UNFORMATTED aux_server.
    INPUT CLOSE.

    aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                          aux_nmendter.
    
    UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
    
    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmendter + STRING(TIME) + ".ex"
           aux_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmendter + STRING(TIME) + ".pdf".
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    IF  par_flgordem   THEN
        FOR EACH crapemp WHERE crapemp.cdcooper = par_cdcooper   
                         NO-LOCK
                         BY crapemp.cdempres:
    
            DISPLAY STREAM str_1 
                    crapemp.cdempres "   "
                    crapemp.nmextemp "   "
					crapemp.nrdddemp COLUMN-LABEL "DDD"
                    crapemp.nrfonemp
                    WITH CENTERED TITLE "RELACAO DE EMPRESAS CONVENIADAS\n\n"
                         FRAME f_numerica DOWN.
             
            DOWN WITH FRAME f_numerica.
        END.
    ELSE
        FOR EACH crapemp WHERE crapemp.cdcooper = par_cdcooper   
                         NO-LOCK
                         BY crapemp.nmextemp:
    
            DISPLAY STREAM str_1 
                    crapemp.cdempres "   "
                    crapemp.nmextemp "   "
					crapemp.nrdddemp COLUMN-LABEL "DDD"
                    crapemp.nrfonemp
                    WITH CENTERED TITLE "RELACAO DE EMPRESAS CONVENIADAS\n\n"
                    FRAME f_alfabetica DOWN.
    
            DOWN WITH FRAME f_alfabetica.
        END.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                    ASSIGN aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen0024.".
                END.

            RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT aux_nmarqimp,
                                                    OUTPUT par_nmarqpdf,
                                                    OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                RETURN 'NOK'.
        END.
    
    RETURN 'OK'.

END PROCEDURE.


PROCEDURE Busca_Procuradores_Emp:

    DEF INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF INPUT PARAM par_cdempres AS INTE            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-procuradores-emp.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-procuradores-emp.
    EMPTY TEMP-TABLE tt-erro.

    /* Busca os procuradores vinculados a empresa */
    FOR EACH crapemp WHERE crapemp.cdcooper = par_cdcooper
                       AND crapemp.cdempres = par_cdempres
                       NO-LOCK
       ,EACH crapavt WHERE crapavt.cdcooper = crapemp.cdcooper
                       AND crapavt.nrdconta = crapemp.nrdconta
                       AND crapavt.tpctrato = 6
                       NO-LOCK
       ,EACH crapass WHERE crapass.cdcooper = crapavt.cdcooper
                       AND crapass.nrdconta = crapavt.nrdctato
                       NO-LOCK:
    
        CREATE tt-procuradores-emp.
        ASSIGN tt-procuradores-emp.nrdctato = crapavt.nrdctato
               tt-procuradores-emp.nmprimtl = crapass.nmprimtl
               tt-procuradores-emp.nrcpfcgc = crapass.nrcpfcgc
               tt-procuradores-emp.dtvalida = crapavt.dtvalida
               tt-procuradores-emp.dsproftl = crapavt.dsproftl
               tt-procuradores-emp.idctasel = FALSE.
    END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE Impresao_Termo_Servico:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt            NO-UNDO.
    DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
    DEF INPUT PARAM par_cdempres LIKE crapemp.cdempres            NO-UNDO.
    DEF INPUT PARAM par_imptermo AS INTE                          NO-UNDO.
    DEF INPUT PARAM par_lisconta AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM par_nmarquiv AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                         NO-UNDO.

    IF  par_cdagenci  = 0 THEN DO:
        ASSIGN par_cdagenci = 1.
    END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_termo_adesao_cancel aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper,
                         INPUT par_dtmvtolt,
                         INPUT par_cdagenci,
                         INPUT par_idorigem,
                         INPUT par_cdempres,
                         INPUT par_imptermo,
                         INPUT par_lisconta,
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "").
    CLOSE STORED-PROC pc_termo_adesao_cancel aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN par_nmarquiv = ""
           par_cdcritic = 0
           par_dscritic = ""
           par_nmarquiv = pc_termo_adesao_cancel.pr_nmarquiv
                          WHEN pc_termo_adesao_cancel.pr_nmarquiv <> ?
           par_cdcritic = pc_termo_adesao_cancel.pr_cdcritic
                          WHEN pc_termo_adesao_cancel.pr_cdcritic <> ?
           par_dscritic = pc_termo_adesao_cancel.pr_dscritic
                          WHEN pc_termo_adesao_cancel.pr_dscritic <> ?.
           

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  par_cdcritic > 0 OR par_dscritic <> "" THEN DO:
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Busca_Convenios_Tarifarios:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-convenio.

    DEF VAR h-b1wgen0153 AS HANDLE                                   NO-UNDO.

    DEF VAR aux_ponteiro AS INTE                                     NO-UNDO.
    DEF VAR aux_cdtarifa AS DECI FORMAT "zzz,zzz,zz9.99"             NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_vltarifa AS DECI                                     NO-UNDO.
    DEF VAR aux_vltarif0 AS DECI                                     NO-UNDO.
    DEF VAR aux_vltarif1 AS DECI                                     NO-UNDO.
    DEF VAR aux_vltarif2 AS DECI                                     NO-UNDO.
    DEF VAR aux_flagerro AS LOGICAL                                  NO-UNDO.

    DEF VAR aux_cdhistor AS INTE                                     NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                     NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                     NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                     NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-convenio.

    ASSIGN aux_contador = 0.

    FOR EACH crapcfp WHERE crapcfp.cdcooper = par_cdcooper
                           NO-LOCK:

        aux_flagerro = FALSE.

        DO  aux_contador = 0 TO 2:
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /*** Faz a busca do historico da transação ***/
            RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                             aux_ponteiro = PROC-HANDLE
               
            ("SELECT folh0001.fn_valor_tarifa_folha(" + STRING(crapcfp.cdcooper) + ","
                                                      + "0," /* Conta */
                                                      + STRING(crapcfp.cdcontar) + ","
                                                      + STRING(aux_contador) + ","
                                                      + STRING(0) + ") FROM dual").
            
            FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
                ASSIGN aux_vltarifa = DECI(proc-text).
            END.
            
            CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
                  WHERE PROC-HANDLE = aux_ponteiro.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
            IF  aux_vltarifa = -1 THEN /* Nao pode haver tarifa menor que ZERO */
                ASSIGN aux_flagerro = TRUE.

            CASE aux_contador:
                WHEN 0 THEN
                    ASSIGN aux_vltarif0 = aux_vltarifa.
                WHEN 1 THEN
                    ASSIGN aux_vltarif1 = aux_vltarifa.
                WHEN 2 THEN
                    ASSIGN aux_vltarif2 = aux_vltarifa.
            END CASE.
        END.

        IF  NOT aux_flagerro THEN DO:
            CREATE tt-convenio.
            ASSIGN tt-convenio.dscontar = crapcfp.dscontar
                   tt-convenio.cdcontar = crapcfp.cdcontar.
                   tt-convenio.vltarid0 = aux_vltarif0.
                   tt-convenio.vltarid1 = aux_vltarif1.
                   tt-convenio.vltarid2 = aux_vltarif2.
        END.

    END. /* Fim FOR EACH */

    RETURN "OK".

END PROCEDURE.


PROCEDURE Busca_Conta_Emp:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdempres LIKE crapemp.cdempres              NO-UNDO.
    DEF  INPUT PARAM par_cdopcao  AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-titular.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-titular.
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    DEF BUFFER crabemp FOR crapemp.
  
    IF  par_nrdconta = 0 THEN DO: 
        FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper
                           AND crapass.inpessoa <> 1
                           AND crapass.dtdemiss = ?
                           AND (par_nmprimtl <> "" AND crapass.nmprimtl MATCHES("*" + par_nmprimtl + "*"))
                           NO-LOCK:

            CREATE tt-titular.
            ASSIGN tt-titular.nrdconta = crapass.nrdconta
                   tt-titular.nmpesttl = crapass.nmprimtl.
        END.

    END.
    ELSE DO:

        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                             AND crapass.nrdconta = par_nrdconta
                             AND crapass.dtdemiss = ?
                             NO-LOCK NO-ERROR.
        
        IF  AVAIL crapass THEN DO:
        
            /* buscar quantidade maxima de digitos aceitos para o convenio */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                          
            RUN STORED-PROCEDURE pc_valida_adesao_produto
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 8, /* Convenio Folha de Pagamento */
                                         OUTPUT 0,   /* pr_cdcritic */
                                         OUTPUT ""). /* pr_dscritic */
                        
            CLOSE STORED-PROC pc_valida_adesao_produto
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic                          
                                      WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
                   aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                                      WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
            
            IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
            
            IF  par_cdopcao = "A" THEN DO:
                     FIND FIRST crabemp
                     WHERE crabemp.cdcooper = crapass.cdcooper
                       AND crabemp.cdempres = par_cdempres
                   NO-LOCK NO-ERROR.

                IF  par_nrdconta <> crabemp.nrdconta THEN DO:

                    FIND FIRST crapemp
                         WHERE crapemp.cdcooper = par_cdcooper
                           AND crapemp.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL crapemp THEN DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Conta informada ja utilizada por outra empresa: " +
                                              STRING(crapemp.cdempres,"z999") + " - " + crapemp.nmresemp.
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                    IF crapass.inpessoa = 1 THEN DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Favor selecionar uma conta de pessoa Juridica.".
                        
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                END.


            END.
            ELSE DO:    /* Opcao I*/

                FIND FIRST crapemp
                     WHERE crapemp.cdcooper = par_cdcooper
                       AND crapemp.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.
    
                IF  AVAIL crapemp THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Conta informada ja utilizada por outra empresa: " +
                                          STRING(crapemp.cdempres,"z999") + " - " + crapemp.nmresemp.
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
                ELSE DO:
                    IF crapass.inpessoa = 1 THEN DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Favor selecionar uma conta de pessoa Juridica.".
                        
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
                END.

            END.

            CREATE tt-titular.
            ASSIGN tt-titular.nrdconta = crapass.nrdconta
                   tt-titular.nmpesttl = crapass.nmprimtl.    

        END.
        ELSE DO:  /** Nao encontrou ASS **/
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta inexistente ou demitida.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 0,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    END.

    RETURN "OK".

END PROCEDURE.
