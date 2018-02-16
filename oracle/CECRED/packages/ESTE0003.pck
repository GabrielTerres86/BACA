CREATE OR REPLACE PACKAGE ESTE0003 IS
/* --------------------------------------------------------------------------------------------------

      Programa : ESTE0003
      Sistema  : BO - CRÉDITO CONSIGNADO
      Sigla    : XXXX
      Autor    : Lindon Carlos Pecile - GFT-Brasil
      Data     : Fevereiro/2018.          Ultima atualizacao: 10/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que solicitado
      Objetivo  : BO - Rotinas para envio de informacoes para a Esteira de Credito

-----------------------------------------------------------------------------------------------------
         ATENCAO!    CONVERSAO PROGRESS - ORACLE
   ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+--------------------------------------+
  | Rotina Progress   | Rotina Oracle PLSQL                                    |
  +-------------------------------------+--------------------------------------+
  |                   |                                                        |
  |                   |                                                        |
  |                   |                                                        |
  |                   |                                                        |
  |                   |                                                        |
  +-------------------------------------+--------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 01/MAR/2018 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - DANIEL       (CECRED)
   - LUIS FERNANDO         (GFT)
   - LINDON CARLOS PECILE  (GFT)
Alteracoes:
 - 000: [DD/MM/AAAA] NOME DO RESPONSÁVEL        (EMPRESA) : ALTERAÇÃO REALIZADA
.................................................................................................
 Declaração das Procedure para incluir  proposta ao motor
.................................................................................................*/

-- Public type declarations
--type <TypeName> is <Datatype>;
  
-- Public constant declarations
--<ConstantName> constant <Datatype> := <Value>;

-- Public variable declarations
/* Tratamento de erro */
vr_des_erro VARCHAR2(4000);
vr_exc_erro EXCEPTION;

/* Descrição e código da critica */
vr_cdcritic crapcri.cdcritic%TYPE;
vr_dscritic VARCHAR2(4000);

-- Public function and procedure declarations
--function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;

  
  

PROCEDURE incluir_proposta_esteira(pr_cdcooper IN crawepr.cdcooper%TYPE,    -- Codigo que identifica a Cooperativa.
                                   pr_cdagenci IN craplim.cdagenci%TYPE,    -- Numero do PA ou Agência.
                                   pr_nrctrlim IN craplim.nrctrlim%TYPE,    -- Numero do Contrato do Limite. 
                                   pr_nrdcaixa IN INTEGER,
                                   pr_nmdatela IN craplgm.nmdatela%TYPE,
                                   pr_cdoperad IN crapass.inpessoa%TYPE,    --Codigo do operador.
                                   pr_agenci IN craplim.cdagenci%TYPE,      -- Código da Agencia
                                   pr_cdageori IN craplim.cdageori%TYPE,    --Codigo da agencia original do registro.
                                   pr_tpctrlim IN crawepr.cdfinemp%TYPE,
                                   pr_idcobope IN crawepr.cdlcremp%TYPE,
                                   pr_nrdconta IN crawepr.nrdconta%TYPE,    --Numero da conta/dv do associado.
                                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    --Data do movimento atual
                                   pr_nrctremp IN crawepr.nrctremp%TYPE,    --Numero da proposta de emprestimo
                                   pr_nmarqpdf IN VARCHAR2,                 --Numero do Arquivo PDF
                                   pr_dsiduser IN VARCHAR2,                 --Gera ID aleatório,
                                   pr_tpenvest IN OUT CHAR,                 --Tipo do envestimento I - inclusao Proposta
                                                                            --                     D - Derivacao Proposta
                                                                            --                     A - Alteracao Proposta
                                                                            --                     N - Alterar Numero Proposta
                                                                            --                     C - Cancelar Proposta
                                                                            --                     E - Efetivar Proposta
                                   pr_dsmensag OUT CHAR,                    --Descrição da mensagem
                                   pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                   pr_dscritic IN OUT character);           --Código da critica.
								   
--> Rotina responsavel por gravar registro de log de acionamento
PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbgen_webservice_aciona.cdcooper%TYPE, 
																 pr_cdagenci                 IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
																 pr_cdoperad                 IN tbgen_webservice_aciona.cdoperad%TYPE, 
																 pr_cdorigem                 IN tbgen_webservice_aciona.cdorigem%TYPE, 
																 pr_nrctrprp                 IN tbgen_webservice_aciona.nrctrprp%TYPE, 
																 pr_nrdconta                 IN tbgen_webservice_aciona.nrdconta%TYPE, 
																 pr_tpacionamento            IN tbgen_webservice_aciona.tpacionamento%TYPE, 
																 pr_dsoperacao               IN tbgen_webservice_aciona.dsoperacao%TYPE, 
																 pr_dsuriservico             IN tbgen_webservice_aciona.dsuriservico%TYPE, 
																 pr_dtmvtolt                 IN tbgen_webservice_aciona.dtmvtolt%TYPE, 
																 pr_dhacionamento            IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP,
																 pr_cdstatus_http            IN tbgen_webservice_aciona.cdstatus_http%TYPE, 
																 pr_dsconteudo_requisicao    IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
																 pr_dsresposta_requisicao    IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
																 pr_dsprotocolo              IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL, -- Protocolo do Acionamento
																 pr_dsmetodo								 IN tbgen_webservice_aciona.dsmetodo%TYPE DEFAULT NULL,
																 pr_tpconteudo               IN tbgen_webservice_aciona.tpconteudo%TYPE DEFAULT NULL,  --tipo de retorno json/xml
																 pr_tpproduto                IN tbgen_webservice_aciona.tpproduto%TYPE DEFAULT NULL,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
																 pr_idacionamento           OUT tbgen_webservice_aciona.idacionamento%TYPE,
																 pr_dscritic                OUT VARCHAR2);
	
--> Rotina responsavel por buscar registro de log de acionamento																															 
PROCEDURE pc_busca_acionamento( pr_idacionamento IN tbgen_webservice_aciona.idacionamento%TYPE,
                                                                 pr_cdcooper                 OUT tbgen_webservice_aciona.cdcooper%TYPE, 
																 pr_cdagenci                 OUT tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
																 pr_cdoperad                 OUT tbgen_webservice_aciona.cdoperad%TYPE, 
																 pr_cdorigem                 OUT tbgen_webservice_aciona.cdorigem%TYPE, 
																 pr_nrctrprp                 OUT tbgen_webservice_aciona.nrctrprp%TYPE, 
																 pr_nrdconta                 OUT tbgen_webservice_aciona.nrdconta%TYPE, 
																 pr_tpacionamento            OUT tbgen_webservice_aciona.tpacionamento%TYPE, 
																 pr_dsoperacao               OUT tbgen_webservice_aciona.dsoperacao%TYPE, 
																 pr_dsuriservico             OUT tbgen_webservice_aciona.dsuriservico%TYPE, 
																 pr_dtmvtolt                 OUT tbgen_webservice_aciona.dtmvtolt%TYPE, 
																 pr_dhacionamento            OUT tbgen_webservice_aciona.dhacionamento%TYPE,
																 pr_cdstatus_http            OUT tbgen_webservice_aciona.cdstatus_http%TYPE, 
																 pr_dsconteudo_requisicao    OUT tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
																 pr_dsresposta_requisicao    OUT tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
																 pr_dsprotocolo              OUT tbgen_webservice_aciona.dsprotocolo%TYPE, -- Protocolo do Acionamento
																 pr_dsmetodo				 OUT tbgen_webservice_aciona.dsmetodo%TYPE,
																 pr_tpconteudo               OUT tbgen_webservice_aciona.tpconteudo%TYPE,  --tipo de retorno json/xml
																 pr_tpproduto                OUT tbgen_webservice_aciona.tpproduto%TYPE,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
																 pr_dscritic                 OUT VARCHAR2);

END ESTE0003;
/
CREATE OR REPLACE PACKAGE BODY ESTE0003 IS

-- Private type declarations
-- type <TypeName> is <Datatype>;
  
-- Private constant declarations
-- <ConstantName> constant <Datatype> := <Value>;

-- Private variable declarations
-- <VariableName> <Datatype>;

-- Function and procedure implementations
-- function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
--  <LocalVariable> <Datatype>;

PROCEDURE incluir_proposta_esteira(pr_cdcooper IN crawepr.cdcooper%TYPE,    -- Codigo que identifica a Cooperativa.
                                   pr_cdagenci IN craplim.cdagenci%TYPE,    -- Numero do PA ou Agência.
                                   pr_nrctrlim IN craplim.nrctrlim%TYPE,    -- Numero do Contrato do Limite. 
                                   --pr_nrdcaixa IN INTEGER,
                                   --pr_nmdatela IN craplgm.nmdatela%TYPE,
                                   pr_cdoperad IN crapass.inpessoa%TYPE,    --Codigo do operador.
                                   pr_agenci IN craplim.cdagenci%TYPE,      -- Código da Agencia
                                   pr_cdageori IN craplim.cdageori%TYPE,    --Codigo da agencia original do registro.
                                   pr_tpctrlim IN crawepr.cdfinemp%TYPE,
                                   pr_idcobope IN crawepr.cdlcremp%TYPE,
                                   pr_nrdconta IN crawepr.nrdconta%TYPE,    --Numero da conta/dv do associado.
                                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    --Data do movimento atual
                                   pr_nrctremp IN crawepr.nrctremp%TYPE,    --Numero da proposta de emprestimo
                                   --pr_nmarqpdf IN VARCHAR2,                 --Numero do Arquivo PDF
                                   --pr_dsiduser IN VARCHAR2,                 --Gera ID aleatório,
                                   pr_tpenvest IN OUT CHAR,                 --Tipo do envestimento I - inclusao Proposta
                                                                            --                     D - Derivacao Proposta
                                                                            --                     A - Alteracao Proposta
                                                                            --                     N - Alterar Numero Proposta
                                                                            --                     C - Cancelar Proposta
                                                                            --                     E - Efetivar Proposta
                                   pr_dsmensag OUT CHAR,                    --Descrição da mensagem
                                   pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                   pr_dscritic IN OUT character) IS         --Código da critica.

-- DECLARE


vr_dscritic CHARACTER :=  '';
vr_exc_erro CHARACTER :=  '';
vr_dsmensag CHARACTER :=  '';
vr_cdcritic NUMBER :=0;
vr_inobriga CHARACTER :=  '';

-- Declaraçao do cursor para busca do limite do contrato
CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE,
                  pr_nrdconta IN craplim.nrdconta%TYPE,
                  pr_cdageori IN craplim.cdageori%TYPE,
                  pr_cdoperad IN crapass.inpessoa%TYPE,
                  pr_tpctrlim IN crawepr.cdfinemp%TYPE,
                  pr_idcobope IN crawepr.cdlcremp%TYPE,
                  pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
                  SELECT craplim.ROWID, cdcooper AS pr_cdcooper, 
                         nrdconta AS pr_nrdconta, cdageori AS pr_cdageori, 
                         cdoperad AS pr_cdoperad, tpctrlim AS pr_tpctrlim,
                         idcobope AS pr_idcobope, nrctrlim AS pr_nrctrlim,
                          
                         craplim.*
                  FROM craplim
                  WHERE cdcooper = pr_cdcooper  AND cdagenci = pr_agenci AND cdageori  = pr_cdageori;

    -- Declaraçao da variavel tipo linha que receberá os dados selecionados
    rw_craplim cr_craplim%ROWTYPE;


BEGIN
      vr_dsmensag := pr_dsmensag;
      vr_cdcritic := pr_cdcritic;
      vr_dscritic := pr_dscritic;

      -- Caso a proposta já tenha sido enviada para a Esteira iremos considerar uma Alteracao.
      -- Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela
      -- ainda nao foi a Esteira
      -- Se parametro de entrada for de Inclusao
      IF pr_tpenvest = 'I' THEN
        -- Localiza o limite de crédito na tabela de limites referente aos dados efltuado
          -- Busca do nome do associado
          -- Abertura do cursor para obter o dados do limite do contrato
          OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_cdageori => pr_cdageori,
                          pr_cdoperad => pr_cdoperad,
                          pr_tpctrlim => pr_tpctrlim,
                          pr_idcobope => pr_idcobope,
                          pr_nrctrlim => pr_nrctrlim);
          -- Atribuiçao dos dados selecionados para a variavel tipo linha.
          FETCH cr_craplim INTO rw_craplim;

          --Se um contrato nao for localizado
          IF cr_craplim%NOTFOUND THEN
            --Fechar Cursor do contrato
            CLOSE cr_craplim;
            --armazena a Mensagem Erro
            vr_dscritic:= 'Contrato nao encontrado.';
            --Sair
            vr_exc_erro := 'Contrato nao encontrado.';
          ELSE
            vr_inobriga := 'N';
            -- Verificar se a proposta devera passar por analise automatica
            ESTE0001.pc_obrigacao_analise_automatic( pr_cdcooper => rw_craplim.pr_cdcooper,      -- Código da Cooperativa
                                                     pr_inpessoa => rw_craplim.pr_cdoperad,      --> Tipo da Pessoa
                                                     pr_cdfinemp => rw_craplim.pr_tpctrlim,      --> Cód. finalidade do credito
                                                     pr_cdlcremp => rw_craplim.pr_idcobope,      -- Código da ~ linha de crédito
                                                     pr_inobriga => vr_inobriga,                 -- Obrigaçao de análise automática (S/N)
                                                     pr_cdcritic => vr_cdcritic,                 -- Código da crítica
                                                     pr_dscritic => vr_dscritic);                -- Descriçao da crítica
           -- Se:
            --    1 - Jah houve envio para a Esteira
            --    2 - Nao precisar passar por Analise Automatica
            --    3 - Nao existir protocolo gravado

            IF (rw_craplim.dtenvest IS NOT NULL AND vr_inobriga <> 'S' AND (rw_craplim.dsprotoc =''  OR rw_craplim.dsprotoc = ' '  ) ) THEN
                  -- Significa que a proposta jah foi para a Esteira,
                  -- entao devemos mandar um reinicio de Fluxo
                  pr_tpenvest := 'A';
            END IF;

            -- Verificar se a Esteira esta em contigencia
            ESTE0001.pc_verifica_regras_esteira ( pr_cdcooper => rw_craplim.pr_cdcooper,                   -- Código da Cooperativa
                                                  pr_nrdconta => rw_craplim.pr_nrdconta,                --> Numero da conta do cooperado
                                                  pr_nrctremp => rw_craplim.pr_nrctrlim,                --> Numero da proposta de emprestimo 
                                                  pr_tpenvest => 'I',                                   --> Tipo de envio C - Consultar(Get)
                                                  pr_cdcritic => vr_cdcritic,                           -- Código da crítica
                                                  pr_dscritic => vr_dscritic);                          -- Descriçao da crítica



                                        
            IF vr_cdcritic > 0 OR vr_dscritic <> '' THEN
               pr_dsmensag := 'NOK';
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               RETURN;
            END IF;
   
            /* Gerar impressao da proposta em PDF para as opcoes abaixo*/

            -- Chamar rotina de inclusao da proposta na Esteira
            ESTE0001.pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper,     -- pr_cdcooper
                                             pr_cdagenci => pr_cdagenci,     -- pr_cdagenci
                                             pr_cdoperad => pr_cdoperad,     -- pr_cdoperad
                                             pr_cdorigem => pr_cdageori,     -- pr_cdorigem
                                             pr_nrdconta => pr_nrdconta,     -- pr_nrdconta
                                             pr_nrctremp => pr_nrctremp,     -- pr_nrctremp
                                             pr_dtmvtolt => pr_dtmvtolt,     -- pr_dtmvtolt
                                             pr_nmarquiv => '',              -- pr_nmarquiv
                                                 --out
                                                 pr_dsmensag => vr_dsmensag,     -- pr_dsmensag
                                                 pr_cdcritic => vr_cdcritic,     -- pr_cdcritic
                                                 pr_dscritic => vr_dscritic);    -- pr_dscritic

            --Fechar Cursor do contrato
            CLOSE cr_craplim;
          
          
            END IF;
	      

		  vr_dsmensag:='Aprovada Automaticamente';


          pr_dsmensag := vr_dsmensag;
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
      END IF;


END incluir_proposta_esteira;



	--> Rotina responsavel por gravar registro de log de acionamento
	PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbgen_webservice_aciona.cdcooper%TYPE, 
																 pr_cdagenci                 IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
																 pr_cdoperad                 IN tbgen_webservice_aciona.cdoperad%TYPE, 
																 pr_cdorigem                 IN tbgen_webservice_aciona.cdorigem%TYPE, 
																 pr_nrctrprp                 IN tbgen_webservice_aciona.nrctrprp%TYPE, 
																 pr_nrdconta                 IN tbgen_webservice_aciona.nrdconta%TYPE, 
																 pr_tpacionamento            IN tbgen_webservice_aciona.tpacionamento%TYPE, 
																 pr_dsoperacao               IN tbgen_webservice_aciona.dsoperacao%TYPE, 
																 pr_dsuriservico             IN tbgen_webservice_aciona.dsuriservico%TYPE, 
																 pr_dtmvtolt                 IN tbgen_webservice_aciona.dtmvtolt%TYPE, 
																 pr_dhacionamento            IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP,
																 pr_cdstatus_http            IN tbgen_webservice_aciona.cdstatus_http%TYPE, 
																 pr_dsconteudo_requisicao    IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
																 pr_dsresposta_requisicao    IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
																 pr_dsprotocolo              IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL, -- Protocolo do Acionamento
																 pr_dsmetodo								 IN tbgen_webservice_aciona.dsmetodo%TYPE DEFAULT NULL,
																 pr_tpconteudo               IN tbgen_webservice_aciona.tpconteudo%TYPE DEFAULT NULL,  --tipo de retorno json/xml
																 pr_tpproduto                IN tbgen_webservice_aciona.tpproduto%TYPE DEFAULT NULL,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
																 pr_idacionamento           OUT tbgen_webservice_aciona.idacionamento%TYPE,
																 pr_dscritic                OUT VARCHAR2)IS
																 
	/* ..........................................................................
		
		Programa : pc_grava_acionamento        
		Sistema  : Conta-Corrente - Cooperativa de Credito
		Sigla    : CRED
		Autor    : Luis Fernando - GFT
		Data     : Fevereiro/2018.                   Ultima atualizacao: 
		
		Dados referentes ao programa:
		
		Frequencia: Sempre que for chamado
		Objetivo  : Grava registro de log de acionamento
		
		Alteração : 
				
	..........................................................................*/
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		INSERT INTO tbgen_webservice_aciona                                                                                     /*@TROCAR PARA CECRED.TBGEN_WEBSERVICE_ACIONA*/
								( cdcooper, 
									cdagenci_acionamento, 
									cdoperad, 
									cdorigem, 
									nrctrprp, 
									nrdconta, 
									tpacionamento, 
									dhacionamento, 
									dsoperacao, 
									dsuriservico, 
									dtmvtolt, 
									cdstatus_http, 
									dsconteudo_requisicao,
									dsresposta_requisicao,
									dsmetodo,
									tpconteudo,
									tpproduto,
									dsprotocolo)  
					VALUES( pr_cdcooper,        --cdcooper
									pr_cdagenci,        -- cdagenci_acionamento, 
									pr_cdoperad,        -- cdoperad, 
									pr_cdorigem,        -- cdorigem
									pr_nrctrprp,        -- nrctrprp
									pr_nrdconta,        -- nrdconta
									pr_tpacionamento,   -- tpacionamento 
									pr_dhacionamento,   -- dhacionamento
									pr_dsoperacao,      -- dsoperacao
									pr_dsuriservico,    -- dsuriservico
									pr_dtmvtolt,        -- dtmvtolt
									pr_cdstatus_http,   -- cdstatus_http
									pr_dsconteudo_requisicao,
									pr_dsresposta_requisicao, --dsresposta_requisicao       
									pr_dsmetodo,				-- dsmetodo
									pr_tpconteudo,			-- tpconteudo
									pr_tpproduto,				--tpproduto
									pr_dsprotocolo)     -- protocolo
					 RETURNING tbgen_webservice_aciona.idacionamento INTO pr_idacionamento;
	 
		--> Commit para garantir que guarde as informações do log de acionamento
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao inserir tbgen_webservice_aciona: '||SQLERRM;
			ROLLBACK;
	END pc_grava_acionamento;

	--> Rotina responsavel por buscar registro de log de acionamento
	PROCEDURE pc_busca_acionamento( pr_idacionamento IN tbgen_webservice_aciona.idacionamento%TYPE,
                                                                 pr_cdcooper                 OUT tbgen_webservice_aciona.cdcooper%TYPE, 
																 pr_cdagenci                 OUT tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
																 pr_cdoperad                 OUT tbgen_webservice_aciona.cdoperad%TYPE, 
																 pr_cdorigem                 OUT tbgen_webservice_aciona.cdorigem%TYPE, 
																 pr_nrctrprp                 OUT tbgen_webservice_aciona.nrctrprp%TYPE, 
																 pr_nrdconta                 OUT tbgen_webservice_aciona.nrdconta%TYPE, 
																 pr_tpacionamento            OUT tbgen_webservice_aciona.tpacionamento%TYPE, 
																 pr_dsoperacao               OUT tbgen_webservice_aciona.dsoperacao%TYPE, 
																 pr_dsuriservico             OUT tbgen_webservice_aciona.dsuriservico%TYPE, 
																 pr_dtmvtolt                 OUT tbgen_webservice_aciona.dtmvtolt%TYPE, 
																 pr_dhacionamento            OUT tbgen_webservice_aciona.dhacionamento%TYPE,
																 pr_cdstatus_http            OUT tbgen_webservice_aciona.cdstatus_http%TYPE, 
																 pr_dsconteudo_requisicao    OUT tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
																 pr_dsresposta_requisicao    OUT tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
																 pr_dsprotocolo              OUT tbgen_webservice_aciona.dsprotocolo%TYPE, -- Protocolo do Acionamento
																 pr_dsmetodo				 OUT tbgen_webservice_aciona.dsmetodo%TYPE,
																 pr_tpconteudo               OUT tbgen_webservice_aciona.tpconteudo%TYPE,  --tipo de retorno json/xml
																 pr_tpproduto                OUT tbgen_webservice_aciona.tpproduto%TYPE,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
																 pr_dscritic                 OUT VARCHAR2) IS
																 
	/* ..........................................................................
		
		Programa : pc_busca_acionamento        
		Sistema  : Conta-Corrente - Cooperativa de Credito
		Sigla    : CRED
		Autor    : Leonardo Oliveira - GFT
		Data     : Fevereiro/2018.                   Ultima atualizacao: 
		
		Dados referentes ao programa:
		
		Frequencia: Sempre que for chamado
		Objetivo  : Buscar registro de log de acionamento
		
		Alteração : 
				
	..........................................................................*/
	BEGIN
		SELECT
			cdcooper,
			cdagenci_acionamento,
			cdoperad,
			cdorigem,
			nrctrprp,
			nrdconta,
			tpacionamento,
			dhacionamento,
			dsoperacao,
			dsuriservico,
			dtmvtolt,
			cdstatus_http,
			dsconteudo_requisicao,
			dsresposta_requisicao,
			dsmetodo,
			tpconteudo,
			tpproduto,
			dsprotocolo
		INTO 
			pr_cdcooper,
			pr_cdagenci,
			pr_cdoperad,
			pr_cdorigem,
			pr_nrctrprp,
			pr_nrdconta,
			pr_tpacionamento,
			pr_dhacionamento,
			pr_dsoperacao,
			pr_dsuriservico,
			pr_dtmvtolt,
			pr_cdstatus_http,
			pr_dsconteudo_requisicao,
			pr_dsresposta_requisicao,
			pr_dsmetodo,
			pr_tpconteudo,
			pr_tpproduto,
			pr_dsprotocolo
  		FROM tbgen_webservice_aciona
        WHERE idacionamento = pr_idacionamento;
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao buscar tbgen_webservice_aciona: '||SQLERRM;
	END pc_busca_acionamento;




END ESTE0003;
/
