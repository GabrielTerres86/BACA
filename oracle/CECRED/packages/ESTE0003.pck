create or replace package body CECRED.ESTE0003 is

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
                                     pr_cdagenci IN craplim.cdagenci%TYPE,    -- Numero do PA ou Agencia.
                                     pr_nrctrlim IN craplim.nrctrlim%TYPE,    -- Numero do Contrato do Limite. 
                                     pr_cdoperad IN crapass.inpessoa%TYPE,    --Codigo do operador.
                                     pr_agenci IN craplim.cdagenci%TYPE,      -- Código da Agencia
                                     pr_cdageori IN craplim.cdageori%TYPE,    --Codigo da agencia original do registro.
                                     pr_tpctrlim IN crawepr.cdfinemp%TYPE,
                                     pr_idcobope IN crawepr.cdlcremp%TYPE,
                                     pr_nrdconta IN crawepr.nrdconta%TYPE,    --Numero da conta/dv do associado.
                                     pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    --Data do movimento atual
                                     pr_nrctremp IN crawepr.nrctremp%TYPE,    --Numero da proposta de emprestimo
                                     pr_tpenvest IN OUT CHAR,                 --Tipo do envestimento I - inclusao Proposta
                                                                              --                     D - Derivacao Proposta
                                                                              --                     A - Alteracao Proposta
                                                                              --                     N - Alterar Numero Proposta
                                                                              --                     C - Cancelar Proposta
                                                                              --                     E - Efetivar Proposta
                                     pr_dsmensag OUT CHAR,                    --Descriçao da mensagem
                                     pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                     pr_dscritic IN OUT character)IS           --Código da critica.) IS         --Código da critica.
-- DECLARE
    vr_dscritic CHARACTER :=  '';
    --vr_exc_erro CHARACTER :=  '';
    vr_dsmensag CHARACTER :=  '';
    vr_cdcritic NUMBER :=0;
    vr_inobriga CHARACTER :=  '';

    -- Declaraçao do cursor para busca do limite do contrato
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE,
                      pr_nrdconta IN craplim.nrdconta%TYPE,
                      pr_cdageori IN craplim.cdageori%TYPE,
                      pr_cdoperad IN crapass.inpessoa%TYPE,
                      pr_tpctrlim IN craplim.tpctrlim%TYPE,
                      pr_idcobope IN craplim.cddlinha%TYPE,
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
              --vr_exc_erro := 'Contrato nao encontrado.';
            ELSE
              vr_inobriga := 'N';
              -- Verificar se a proposta devera passar por analise automatica
              ESTE0001.pc_obrigacao_analise_automatic( pr_cdcooper => rw_craplim.pr_cdcooper,      -- Código da Cooperativa
                                                       pr_inpessoa => rw_craplim.pr_cdoperad,      --> Tipo da Pessoa
--                                                      pr_tpctrlim => rw_craplim.pr_tpctrlim,      --> Cód. finalidade do credito
--                                                      pr_cddlinha => rw_craplim.pr_idcobope,      -- Código da ~ linha de crédito
                                                       pr_cdfinemp  => rw_craplim.pr_tpctrlim,  --> Cód. finalidade do credito
                                                       pr_cdlcremp => rw_craplim.pr_idcobope,  --> Cód. linha de crédito
                                                       pr_inobriga => vr_inobriga,                 -- Obrigaçao de análise automática (S/N)
                                                       pr_cdcritic => vr_cdcritic,                 -- Código da crítica
                                                       pr_dscritic => vr_dscritic);                -- Descriçao da crítica
             -- Se:
              --    1 - Jah houve envio para a Esteira
              --    2 - Nao precisar passar por Analise Automatica
              --    3 - Nao existir protocolo gravado

              IF (rw_craplim.dtenvest IS NOT NULL AND vr_inobriga <> 'S' AND (trim(rw_craplim.dsprotoc) IS NULL) ) THEN
                    -- Significa que a proposta jah foi para a Esteira,
                    -- entao devemos mandar um reinicio de Fluxo
                    pr_tpenvest := 'A';
              END IF;
              -- Verificar se a Esteira esta em contigencia
              ESTE0001.pc_verifica_regras_esteira ( pr_cdcooper => rw_craplim.pr_cdcooper,                   -- Código da Cooperativa
                                                    pr_nrdconta => rw_craplim.pr_nrdconta,                --> Numero da conta do cooperado
--                                                    cpr_nrctrlim => rw_craplim.pr_nrctrlim,             --> Numero da proposta de emprestimo 
--                                                    pr_tpenvest => 'I',                                 --> Tipo de envio C - Consultar(Get)
                                                    pr_nrctremp  => rw_craplim.pr_nrctrlim,               --> Numero da proposta de emprestimo                                        
                                                    pr_tpenvest  => 'I',                                  --> Tipo de envio C - Consultar(Get)
                                                    pr_cdcritic => vr_cdcritic,                           -- Código da crítica
                                                    pr_dscritic => vr_dscritic);                          -- Descriçao da crítica
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
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
                                               --cpr_nrctrlim => cpr_nrctrlim,     -- cpr_nrctrlim
                                               pr_nrctremp => pr_nrctremp,     -- cpr_nrctrlim
                                               pr_dtmvtolt => pr_dtmvtolt,     -- pr_dtmvtolt
                                               pr_nmarquiv => '',              -- pr_nmarquiv
                                               --out--------------
                                               pr_dsmensag => vr_dsmensag,     -- pr_dsmensag
                                               pr_cdcritic => vr_cdcritic,     -- pr_cdcritic
                                               pr_dscritic => vr_dscritic);    -- pr_dscritic
              --Fechar Cursor do contrato
              CLOSE cr_craplim;
            END IF;
            

          

          /*REMOVER*/
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
		
  Alteraçao : 
				
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
	 
  --> Commit para garantir que guarde as informaçoes do log de acionamento
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
		
  Alteraçao : 
				
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

PROCEDURE pc_obrigacao_analise_automatic(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cód. cooperativa
                                        ,pr_inpessoa IN crapass.inpessoa%TYPE  -- Tipo da Pessoa
                                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE  -- Cód. finalidade do credito
                                        ,pr_cddlinha IN craplim.cddlinha%TYPE  -- Cód. linha de crédito
                                         ---- OUT ----                                          
                                        ,pr_inobriga OUT VARCHAR2              -- Indicador de obrigação de análisa automática ('S' - Sim / 'N' - Não)
                                        ,pr_cdcritic OUT PLS_INTEGER           -- Cód. da crítica
                                        ,pr_dscritic OUT VARCHAR2) IS          -- Desc. da crítica
/* .........................................................................
Programa : pc_obrigacao_analise_automatica
Sistema  : 
Sigla    : 
Autor    : Lindon Carlos Pecile (GFT - Brasil)
Data     : Fevereiro/2018                    Ultima atualizacao: --/--/----
Dados referentes ao programa:
Frequencia: Sempre que for chamado
Objetivo  : Tem como objetivo retornar positivo caso a proposta deverá passar 
            por análise automática ou posteriormente manual na Esteira de Crédito
Alteração : 
..........................................................................*/
/* DECLARE */
-- Verificação de finalidade pré-aprovada nas tabelas
--  creppre (Cadastro de Parametros de Regras.)
--  e crapfin (Cadastro de finalidades)


BEGIN 
 
    -- Se finalidade PRE-APROVADO
    -- OU linha dispensa aprovação 
    -- OU é linha CDC
    -- OU Esteira está em contingência 
    -- OU a Cooperativa não Obriga Análise Automática
  IF GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'CONTIGENCIA_ESTEIRA_IBRA') = 1 
        OR GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'ANALISE_OBRIG_MOTOR_CRED') = 0 THEN
           pr_inobriga := 'N';
  ELSE 
      pr_inobriga := 'S';
  END IF;
      
  EXCEPTION     
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado na rotina que verifica o tipo de análise da proposta: '||SQLERRM;
END pc_obrigacao_analise_automatic;  

  
PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN craplim.cdcooper%TYPE,  -- Codigo da cooperativa                                        
                                      pr_nrdconta  IN craplim.nrdconta%TYPE,  -- Numero da conta do cooperado
                                      cpr_nrctrlim  IN craplim.nrctrlim%TYPE,  -- Numero da proposta de emprestimo                                        
                                      pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  -- Tipo de envio C - Consultar(Get)
                                      ---- OUT ----                                        
                                      pr_cdcritic OUT NUMBER,                 -- Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            -- Descricao da critica
/* ..........................................................................
    
  Programa : pc_verifica_regras_esteira        
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Odirlei Busana(Amcom)
  Data     : Março/2016.                   Ultima atualizacao: 09/03/2016
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Procedimento para verificar as regras da esteira 
    
  Alteração : 
        
..........................................................................*/
  ----------- CURSORES <-----------
  -- Buscar dados da proposta de emprestimo
  CURSOR cr_craplim (pr_cdcooper  IN craplim.cdcooper%TYPE,
                     pr_nrdconta  IN craplim.nrdconta%TYPE,
                     cpr_nrctrlim IN craplim.nrctrlim%TYPE)IS
                     SELECT epr.insitest, epr.cdopeapr, epr.insitapr
                        FROM craplim epr
                       WHERE epr.cdcooper = pr_cdcooper
                             AND epr.nrdconta = pr_nrdconta
                             AND epr.nrctrlim = cpr_nrctrlim; 
  rw_craplim cr_craplim%ROWTYPE;
  
  vr_contige_este VARCHAR2(500);
  vr_exc_erro     EXCEPTION;
  vr_dscritic     VARCHAR2(4000);
  vr_cdcritic     NUMBER;
    
BEGIN
  
  -- Verificar se a Esteira esta em contigencia para a cooperativa
  vr_contige_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',pr_cdcooper => pr_cdcooper, pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA');
  IF vr_contige_este IS NULL THEN
    vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_IBRA não encontrado.';
    RAISE vr_exc_erro;      
  END IF;
    
  IF vr_contige_este = '1' THEN
    vr_dscritic := 'Atenção! A aprovação da proposta deve ser feita pela tela CMAPRV.';
    RAISE vr_exc_erro;      
  END IF; 
    
  -- Para inclusão, alteração ou derivação
  IF nvl(pr_tpenvest,' ') IN ('I','A','D') THEN    
      
    -- Buscar dados da proposta
    OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     cpr_nrctrlim => cpr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
      
    -- Somente permitirá se ainda não enviada 
    -- OU se foi Reprovada pelo Motor
    -- ou se houve Erro Conexão
    -- OU se foi enviada e recebemos a Derivação 
    IF rw_craplim.insitest = 0 
    OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 2 AND rw_craplim.cdopeapr = 'MOTOR') 
    OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 6 AND pr_tpenvest = 'I')       
    OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 5) THEN
      -- Sair pois pode ser enviada
      RETURN;
    END IF;
    -- Não será possível enviar/reenviar para a Esteira
    vr_dscritic := 'A proposta não pode ser enviada para Análise de crédito, verifique a situação da proposta!';
    RAISE vr_exc_erro;      
  END IF;
    
EXCEPTION
  WHEN vr_exc_erro THEN     
    -- Buscar critica
    IF nvl(vr_cdcritic,0) > 0 AND 
      TRIM(vr_dscritic) IS NULL THEN
      -- Busca descricao        
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
    END IF;  
      
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    
  WHEN OTHERS THEN
    pr_dscritic := 'Não foi possivel verificar regras da Análise de Crédito: '||SQLERRM;
END pc_verifica_regras_esteira;  


PROCEDURE pc_incluir_proposta_est(pr_cdcooper  IN craplim.cdcooper%TYPE
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                 ,pr_cdorigem  IN INTEGER
                                 ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                 ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nmarquiv  IN VARCHAR2
                                  ---- OUT ----
                                 ,pr_dsmensag OUT VARCHAR2
                                 ,pr_cdcritic OUT NUMBER
                                 ,pr_dscritic OUT VARCHAR2) IS
  /* ...........................................................................
  
    Programa : pc_incluir_proposta_est        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 13/07/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
    Alteração : 
                13/07/2017 - P337 - Ajustes para envio ao Motor - Marcos(Supero)
        
                15/12/2017 - P337 - SM - Ajustes no envio para retormar reinício 
                             de fluxo (Marcos-Supero)        
  ..........................................................................*/
    
  ----------- VARIAVEIS <-----------
  -- Tratamento de erros
  vr_cdcritic NUMBER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
    
  vr_obj_proposta json := json();
  vr_obj_proposta_clob clob;
    
  vr_dsprotoc VARCHAR2(1000);
  vr_comprecu VARCHAR2(1000);
    
  -- Buscar informações da Proposta
  CURSOR cr_craplim IS
    SELECT wpr.insitest, wpr.insitapr, wpr.cdopeapr, wpr.cdagenci,
           wpr.nrctaav1, wpr.nrctaav2,ass.inpessoa, wpr.dsprotoc,
           wpr.cddlinha, wpr.tpctrlim, wpr.rowid
       FROM craplim wpr, crapass ass
       WHERE wpr.cdcooper = ass.cdcooper
         AND wpr.nrdconta = ass.nrdconta
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctrlim = pr_nrctrlim;
  rw_craplim cr_craplim%ROWTYPE;
    
  -- Tipo Envio Esteira
  vr_tpenvest varchar2(1);
    
  -- Acionamentos de retorno
  CURSOR cr_aciona_retorno(pr_dsprotocolo VARCHAR2) IS
    SELECT ac.dsconteudo_requisicao
      FROM tbepr_acionamento ac
      WHERE ac.cdcooper = pr_cdcooper
       AND ac.nrdconta = pr_nrdconta
       AND ac.nrctrprp = pr_nrctrlim
       AND ac.dsprotocolo = pr_dsprotocolo
       AND ac.tpacionamento = 2; 
  -- Somente Retorno
  vr_dsconteudo_requisicao tbepr_acionamento.dsconteudo_requisicao%TYPE;
    
  -- Hora de Envio
  vr_hrenvest craplim.hrenvest%TYPE;
  -- Quantidade de segundos de Espera
  vr_qtsegund NUMBER;
  -- Analise finalizada
  vr_flganlok boolean := FALSE;
    
  -- Objetos para retorno das mensagens
  vr_obj     cecred.json := json();
  vr_obj_anl cecred.json := json();
  vr_obj_lst cecred.json_list := json_list();
  vr_obj_msg cecred.json := json();
  vr_destipo varchar2(1000);
  vr_desmens varchar2(4000);
  vr_dsmensag VARCHAR2(32767);
  vr_inobriga VARCHAR2(1);
    
  -- Variaveis para DEBUG
  vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbepr_acionamento.idacionamento%TYPE;
    
BEGIN    
    
  -- Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    -- Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => pr_nrctrlim,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                         pr_dsoperacao            => 'INICIO INCLUIR PROPOSTA',       
                         pr_dsuriservico          => NULL,       
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => 0,
                         pr_dsconteudo_requisicao => null,
                         pr_dsresposta_requisicao => null,
                         pr_idacionamento         => vr_idaciona,
                         pr_dscritic              => vr_dscritic);
    -- Sem tratamento de exceção para DEBUG                    
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;
  END IF; 
  
  -- Buscar informações da proposta
  OPEN cr_craplim;
  FETCH cr_craplim INTO rw_craplim;
  CLOSE cr_craplim;
    
  -- Verificar se a Cooperativa/Linha/Finalidade Obriga a passagem pelo Motor
  pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                ,pr_inpessoa => rw_craplim.inpessoa
                                ,pr_tpctrlim => rw_craplim.tpctrlim
                                ,pr_cddlinha => rw_craplim.cddlinha                                      
                                ,pr_inobriga => vr_inobriga
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
    
  -- Se Obrigatorio e ainda não Enviada ou Enviada mas com Erro Conexao
  IF vr_inobriga = 'S' AND (rw_craplim.insitest = 0 OR rw_craplim.insitapr = 6) THEN 
      
    -- Gerar informações no padrao JSON da proposta de emprestimo
    ESTE0002.pc_gera_json_analise(pr_cdcooper  => pr_cdcooper,         -- Codigo da cooperativa
                                  pr_cdagenci  => rw_craplim.cdagenci, -- Agência da Proposta
                                  pr_nrdconta  => pr_nrdconta,         -- Numero da conta do cooperado
                                  --pr_nrctrlim  => pr_nrctrlim,       -- Numero da proposta de emprestimo
                                  pr_nrctremp => pr_nrctrlim,       -- Numero da proposta de emprestimo
                                  pr_nrctaav1  => rw_craplim.nrctaav1, -- Avalista 01
                                  pr_nrctaav2  => rw_craplim.nrctaav2, -- Avalista 02
                                  ---- OUT ----
                                  pr_dsjsonan  => vr_obj_proposta,     -- Retorno do clob em modelo json das informações
                                  pr_cdcritic  => vr_cdcritic,         -- Codigo da critica
                                  pr_dscritic  => vr_dscritic);        -- Descricao da critica
      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;           
      
    -- Efetuar montagem do nome do Fluxo de Análise Automatica conforme o tipo de pessoa da Proposta
    IF rw_craplim.inpessoa = 1 THEN 
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_IBRA_PF')||'/start';    
    ELSE
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_IBRA_PJ')||'/start';            
    END IF;    
          
                                                          
    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);
      
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      -- Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctrlim,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;       
      
    -- Enviar dados para Análise Automática Esteira (Motor)
    pc_enviar_esteira(pr_cdcooper    => pr_cdcooper,          -- Codigo da cooperativa

                      pr_cdagenci    => pr_cdagenci,          -- Codigo da agencia                                          
                      pr_cdoperad    => pr_cdoperad,          -- codigo do operador
                      pr_cdorigem    => pr_cdorigem,          -- Origem da operacao
                      pr_nrdconta    => pr_nrdconta,          -- Numero da conta do cooperado
                      cpr_nrctrlim    => pr_nrctrlim,          -- Numero da proposta de emprestimo          
                      pr_dtmvtolt    => pr_dtmvtolt,          -- Data do movimento                                      
                      pr_comprecu    => vr_comprecu,          -- Complemento do recuros da URI
                      pr_dsmetodo    => 'POST',               -- Descricao do metodo
                      pr_conteudo    => vr_obj_proposta_clob,  -- Conteudo no Json para comunicacao
                      pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE AUTOMATICA DE CREDITO',  -- Operação efetuada
                      pr_tpenvest    => 'M',                  -- Tipo de envio (Motor)
                      pr_dsprotocolo => vr_dsprotoc,           -- Protocolo gerado
                      pr_dscritic    => vr_dscritic) IS            

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_obj_proposta_clob);
    dbms_lob.freetemporary(vr_obj_proposta_clob);                        
                        
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
    -- Atualizar a proposta
    vr_hrenvest := to_char(SYSDATE,'sssss');
    BEGIN
      UPDATE craplim wpr 
         SET wpr.insitest = 1, --  1 – Enviada para Analise 
             wpr.dtenvmot = trunc(SYSDATE), 
             wpr.hrenvmot = vr_hrenvest,
             wpr.cdopeste = pr_cdoperad,
             wpr.dsprotoc = nvl(vr_dsprotoc,' '),
             wpr.insitapr = 0,
             wpr.cdopeapr = NULL,
             wpr.dtaprova = NULL,
             wpr.hraprova = 0
       WHERE wpr.rowid = rw_craplim.rowid;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Análise Automática de Crédito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Efetuar gravação
    COMMIT;
      
    -- Buscar a quantidade de segundos de espera pela Análise Automática
    vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_IBRA'),30);

    -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
    WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

      -- Aguardar 0.5 segundo para evitar sobrecarga de processador
      sys.dbms_lock.sleep(0.5);
        
      -- Verificar se a analise jah finalizou 
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      CLOSE cr_craplim;
        
      -- Se a proposta mudou de situação Esteira
      IF rw_craplim.insitest <> 1 THEN 
        -- Indica que terminou a analise 
        vr_flganlok := true;
      END IF;

    END LOOP;
      
    -- Se chegarmos neste ponto e a analise não voltou OK signifca que houve timeout
    IF NOT vr_flganlok THEN 
      -- Então acionaremos a rotina que solicita via GET o termino da análise
      -- e caso a mesma ainda não tenha terminado, a proposta será salva como Expirada
      ESTE0001.pc_solicita_retorno_analise(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,cpr_nrctrlim => cpr_nrctrlim
                                          ,pr_dsprotoc => vr_dsprotoc);
    END IF;
      
    -- Reconsultar a situação esteira e parecer para retorno
    OPEN cr_craplim;
    FETCH cr_craplim INTO rw_craplim;
    CLOSE cr_craplim;
      
    -- Se houve expiração
    IF rw_craplim.insitest = 1 THEN 
      pr_dsmensag := 'Proposta permanece em <b>Processamento</b>...';
    ELSIF rw_craplim.insitest = 2 THEN 
      pr_dsmensag := '<b>Avaliação Manual</b>';
    ELSIF rw_craplim.insitest = 3 THEN 
      -- Conforme tipo de aprovacao
      IF rw_craplim.insitapr = 1 THEN
        pr_dsmensag := '<b>Aprovada</b>';
      ELSIF rw_craplim.insitapr = 2 THEN 
        pr_dsmensag := '<b>Rejeitada</b>';          
      ELSIF rw_craplim.insitapr IN(0,6) THEN 
        pr_dsmensag := '<b>Erro</b> motor de crédito';
      ELSIF rw_craplim.insitapr = 3 THEN 
        pr_dsmensag := '<b>Com Restricoes</b>';        
      ELSIF rw_craplim.insitapr = 4 THEN
        pr_dsmensag := '<b>Refazer Proposta</b>';
      ELSIF rw_craplim.insitapr = 5 THEN
        pr_dsmensag := '<b>Avaliação Manual</b>';
      END IF;
    ELSIF rw_craplim.insitest = 4 THEN
      pr_dsmensag := '<b>Expirada</b> apos '||vr_qtsegund||' segundos de espera.';        
    ELSE 
      pr_dsmensag := '<b>Finalizada</b> com situação indefinida!';
    END IF;
      
    -- Gerar mensagem padrao:
    pr_dsmensag := 'Resultado da Avaliação: '||pr_dsmensag;
      
    -- Se houver protocolo e a analise foi encerrada ou derivada
    IF vr_dsprotoc IS NOT NULL AND rw_craplim.insitest in(2,3) THEN 
      -- Buscar os detalhes do acionamento de retorno
      OPEN cr_aciona_retorno(vr_dsprotoc);
      FETCH cr_aciona_retorno
       INTO vr_dsconteudo_requisicao;
      -- Somente se encontrou
      IF cr_aciona_retorno%FOUND THEN 
        CLOSE cr_aciona_retorno; 
        -- Processar as mensagens para adicionar ao retorno
        BEGIN 
          -- Efetuar cast para JSON
          vr_obj := json(vr_dsconteudo_requisicao);            
          -- Se existe o objeto de analise
          IF vr_obj.exist('analises') THEN
            vr_obj_anl := json(vr_obj.get('analises').to_char());        
            -- Se existe a lista de mensagens
            IF vr_obj_anl.exist('mensagensDeAnalise') THEN
              vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());
              -- Para cada mensagem 
              for vr_idx in 1..vr_obj_lst.count() loop
                BEGIN
                  vr_obj_msg := json( vr_obj_lst.get(vr_idx));
                  -- Se encontrar o atributo texto e tipo
                  if vr_obj_msg.exist('texto') AND vr_obj_msg.exist('tipo') THEN
                    vr_desmens := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                    vr_destipo := REPLACE(RTRIM(LTRIM(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                  end if;
                  IF vr_destipo <> 'DETALHAMENTO' THEN
                  vr_dsmensag := vr_dsmensag || '<BR>['||vr_destipo||'] '||vr_desmens;                              
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL; -- Ignorar essa linha
                END;
              END LOOP;
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN 
            -- Ignorar se o conteudo nao for JSON não conseguiremos ler as mensagens
            null; 
        END; 
      ELSE
        CLOSE cr_aciona_retorno;           
      END IF;
        
      -- Se nao encontrou mensagem
      IF vr_dsmensag IS NULL THEN 
        -- Usar mensagem padrao
        vr_dsmensag := '<br>Obs: para acessar detalhes da decisão, acionar <b>[Detalhes Proposta]</b>';            
      ELSE
        -- Gerar texto padrão 
        vr_dsmensag := '<br>Detalhes da decisão:<br>###'|| vr_dsmensag;
      END IF;
      -- Concatenar ao retorno a mensagem montada
      pr_dsmensag := pr_dsmensag ||vr_dsmensag;
    END IF;
      
    -- Commitar o encerramento da rotina 
    COMMIT;
      
  ELSE
            
    -- Gerar informações no padrao JSON da proposta de emprestimo
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  -- Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  -- Codigo da agencia                                            
                          pr_cdoperad  => pr_cdoperad,  -- codigo do operado
                          pr_cdorigem  => pr_cdorigem,  -- Origem da operacao
                          pr_nrdconta  => pr_nrdconta,  -- Numero da conta do cooperado
                          cpr_nrctrlim  => cpr_nrctrlim,  -- Numero da proposta de emprestimo
                          pr_nmarquiv  => pr_nmarquiv,  -- Diretorio e nome do arquivo pdf da proposta de emprestimo
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  -- Retorno do clob em modelo json da proposta de emprestimo
                          pr_cdcritic  => vr_cdcritic,  -- Codigo da critica
                          pr_dscritic  => vr_dscritic); -- Descricao da critica
      
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;  
  
    -- Se origem veio do Motor/Esteira
    IF pr_cdorigem = 9 THEN 
      -- É uma derivação
      vr_tpenvest := 'D';
    ELSE 
      vr_tpenvest := 'I';
    END IF;
  
    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);  
      
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      -- Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => cpr_nrctrlim,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
      
    -- Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          -- Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          -- Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,          -- codigo do operador
                        pr_cdorigem    => pr_cdorigem,          -- Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          -- Numero da conta do cooperado
                        cpr_nrctrlim    => cpr_nrctrlim,          -- Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,          -- Data do movimento                                      
                        pr_comprecu    => NULL,                 -- Complemento do recuros da URI
                        pr_dsmetodo    => 'POST',               -- Descricao do metodo
                        pr_conteudo    => vr_obj_proposta_clob, -- Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO',   -- Operacao realizada
                        pr_tpenvest    => vr_tpenvest,          -- Tipo de envio
                        pr_dsprotocolo => vr_dsprotoc,
                        pr_dscritic    => vr_dscritic);            
      
    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    IF lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%' THEN

      -- Tentaremos enviar alteração com reinício de fluxo para a Esteira 
      este0001.pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper          -- Codigo da cooperativa
                                       ,pr_cdagenci => pr_cdagenci          -- Codigo da agencia 
                                       ,pr_cdoperad => pr_cdoperad          -- codigo do operador
                                       ,pr_cdorigem => pr_cdorigem          -- Origem da operacao
                                       ,pr_nrdconta => pr_nrdconta          -- Numero da conta do cooperado
                                       ,cpr_nrctrlim => cpr_nrctrlim          -- Numero da proposta de emprestimo atual/antigo
                                       ,pr_dtmvtolt => pr_dtmvtolt          -- Data do movimento   
                                      ,pr_flreiflx => 1                    -- Reiniciar o fluxo
                                      ,pr_nmarquiv => pr_nmarquiv
                                       ,pr_cdcritic => vr_cdcritic          
                                       ,pr_dscritic => vr_dscritic);

      END IF;
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_obj_proposta_clob);
    dbms_lob.freetemporary(vr_obj_proposta_clob);    
      
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
      
    vr_hrenvest := to_char(SYSDATE,'sssss');
      
    -- Atualizar proposta
    BEGIN
      UPDATE craplim wpr 
         SET wpr.insitest = 2, --  2 – Enviada para Analise Manual
             wpr.dtenvest = trunc(SYSDATE), 
             wpr.hrenvest = vr_hrenvest,
             wpr.cdopeste = pr_cdoperad,
             wpr.dsprotoc = nvl(vr_dsprotoc,' '),
             wpr.insitapr = 0,
             wpr.cdopeapr = NULL,
             wpr.dtaprova = NULL,
             wpr.hraprova = 0
       WHERE wpr.rowid = rw_craplim.rowid;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
      
    pr_dsmensag := 'Proposta Enviada para Analise Manual de Credito.';
      
    -- Efetuar gravação
    COMMIT;
    
  END IF;
    
  -- Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    -- Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => cpr_nrctrlim,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                         pr_dsoperacao            => 'TERMINO INCLUIR PROPOSTA',       
                         pr_dsuriservico          => NULL,       
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => 0,
                         pr_dsconteudo_requisicao => null,
                         pr_dsresposta_requisicao => null,
                         pr_idacionamento         => vr_idaciona,
                         pr_dscritic              => vr_dscritic);
    -- Sem tratamento de exceção para DEBUG                    
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;
  END IF;  
    
  COMMIT;   
    
EXCEPTION
  WHEN vr_exc_erro THEN
      
    -- Buscar critica
    IF nvl(vr_cdcritic,0) > 0 AND 
      TRIM(vr_dscritic) IS NULL THEN
      -- Busca descricao        
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
    END IF;  
      
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
END pc_incluir_proposta_est;
  
 -- Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctremp    IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tpenvest    IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio, I-Inclusao C - Consultar(Get)
																pr_dsprotocolo OUT VARCHAR2,              --> Protocolo retornado na requisiçao
                                pr_dscritic    OUT VARCHAR2 ) IS

    --Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    
    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_idacionamento  tbepr_acionamento.idacionamento%TYPE;
		
    vr_tab_split     gene0002.typ_split;
    vr_idx_split     VARCHAR2(1000);
    
  BEGIN
    
    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                          pr_nrdconta      => pr_nrdconta,                   -- Numero da conta do cooperado
                          pr_nrctremp      => pr_nrctremp,                   -- Numero da proposta de emprestimo
                          pr_tpenvest      => pr_tpenvest,                   -- Tipo do Envio 
                          pr_host_esteira  => vr_host_esteira,               -- Host da esteira
                          pr_recurso_este  => vr_recurso_este,               -- URI da esteira
                          pr_dsdirlog      => vr_dsdirlog    ,               -- Diretorio de log dos arquivos 
                          pr_autori_este   => vr_autori_este  ,              -- Authorization 
                          pr_chave_aplica  => vr_chave_aplica ,              -- Chave de acesso
                          pr_dscritic      => vr_dscritic    );
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;
    
    -- Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN 
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;
    
    -- Para envio do Motor
    IF pr_tpenvest = 'M' THEN
      -- Incluiremos o Reply-To para devoluçao da Análise
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
    END IF;
    
        
    vr_request.content := pr_conteudo;
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato é o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
    --> Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => pr_nrctremp,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */      
                         pr_dsoperacao            => pr_dsoperacao,       
                         pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,       
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => vr_response.status_code,
                         pr_dsconteudo_requisicao => pr_conteudo,
                         pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                     ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                     ',"Content":'||vr_response.content||'}',
                         pr_idacionamento         => vr_idacionamento,
                         pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE 
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para Análise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN   
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN   
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN   
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta da Análise de Crédito.';   
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN   
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'GET' THEN   
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da Análise Automática de Crédito.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para Análise de Crédito.';  
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := fn_retorna_critica('{"Content":'||vr_response.content||'}');
        
        IF pr_dscritic IS NOT NULL THEN
          -- Tratar mensagem específica de Fluxo Atacado:
          -- "Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa"
          IF pr_dscritic != 'Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa' THEN 
            -- Mensagens diferentes dela terao o prefixo, somente ela nao terá
            pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;            
          END IF;  
        ELSE
          pr_dscritic := vr_dscritic_aux;            
        END IF;
        
      ELSE  
        pr_dscritic := vr_dscritic_aux;    
      END IF;                         
      
    END IF;
		
		IF pr_tpenvest = 'M' AND pr_dsmetodo = 'POST' THEN
	    --> Transformar texto em objeto json
			BEGIN
        
        -- Transformar os Headers em uma lista (\n é o separador)
        vr_tab_split := gene0002.fn_quebra_string(vr_response.headers,'\n');
        vr_idx_split  := vr_tab_split.FIRST;
        -- Iterar sobre todos os headers até encontrar o protocolo
        WHILE vr_idx_split IS NOT NULL AND pr_dsprotocolo IS NULL LOOP
          -- Testar se é o Location
          IF lower(vr_tab_split(vr_idx_split)) LIKE 'location%' THEN
            -- Extrair o final do atributo, ou seja, o conteúdo após a ultima barra
            pr_dsprotocolo := SUBSTR(vr_tab_split(vr_idx_split),INSTR(vr_tab_split(vr_idx_split),'/',-1)+1);
          END IF;        
          -- Buscar proximo header        
          vr_idx_split := vr_tab_split.NEXT(vr_idx_split);    
        END LOOP;
        
        -- Se conseguiu encontrar Protocolo
        IF pr_dsprotocolo IS NOT NULL THEN 
  				-- Atualizar acionamento																										 
	  			UPDATE tbepr_acionamento
		  			 SET dsprotocolo = pr_dsprotocolo
			  	 WHERE idacionamento = vr_idacionamento;
        ELSE    
				  -- Gerar erro 
          vr_dscritic := 'Nao foi possivel retornar Protocolo da Análise Automática de Crédito!';
					RAISE vr_exc_erro;																						 
				END IF;
			EXCEPTION
				WHEN OTHERS THEN   
					vr_dscritic := 'Nao foi possivel retornar Protocolo de Análise Automática de Crédito!';
					RAISE vr_exc_erro;
			END;  
		END IF;
		
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel enviar proposta para Análise de Crédito: '||SQLERRM;  
  END pc_enviar_esteira;

END ESTE0003;
