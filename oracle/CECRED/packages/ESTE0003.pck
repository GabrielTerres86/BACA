create or replace package ESTE0003 is
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
                                   pr_cdoperad IN craplim.cdoperad%TYPE,    --Codigo do operador.
                                   pr_agenci IN craplim.cdagenci%TYPE,      -- Código da Agencia
                                   pr_cdageori IN craplim.cdageori%TYPE,    --Codigo da agencia original do registro.
                                   pr_tpctrlim IN craplim.tpctrlim%TYPE,
                                   pr_idcobope IN craplim.idcobope%TYPE,
                                   pr_nrdconta IN crawepr.nrdconta%TYPE,    --Numero da conta/dv do associado.
                                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    --Data do movimento atual
                                   pr_nrctremp IN crawepr.nrctremp%TYPE,    --Numero da proposta de emprestimo
                                   pr_dsiduser IN VARCHAR2,                  --Gera ID aleatório,
                                   pr_tpenvest IN CHAR,                     --Tipo do envestimento
                                   pr_dsmensag OUT CHAR,                    --Descrição da mensagem
                                   pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                   pr_dscritic IN OUT character);           --Código da critica.
END ESTE0003;
/
create or replace package body ESTE0003 is

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
                                   pr_dsiduser IN VARCHAR2,                 --Gera ID aleatório,
                                   pr_tpenvest IN OUT CHAR,                 --Tipo do envestimento
                                   pr_dsmensag OUT CHAR,                    --Descrição da mensagem
                                   pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                   pr_dscritic IN OUT character) IS         --Código da critica.
--NRCTRLIM



-- DECLARE
vr_recidepr NUMBER := 0;
vr_flgentrv BOOLEAN := FALSE;
vr_nmarqimp CHARACTER := '';
vr_nmarqpdf CHARACTER :=  '';
vr_flcontes CHARACTER :=  '';
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
            ESTE0001.pc_verifica_regras_esteira ( pr_cdcooper => rw_craplim.pr_cdcooper,                -- Código da Cooperativa
                                                  pr_nrdconta => rw_craplim.pr_nrdconta,                --> Numero da conta do cooperado
                                                  pr_nrctremp => rw_craplim.pr_nrctrlim,                --> Numero da proposta de emprestimo 
                                                  pr_tpenvest => 'I',                --> Tipo de envio C - Consultar(Get)
                                                  pr_cdcritic => vr_cdcritic,                           -- Código da crítica
                                                  pr_dscritic => vr_dscritic);                          -- Descriçao da crítica

/*
                                          
  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                        pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                        pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                        ---- OUT ----                                        
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                        
*/

                                        
            IF vr_cdcritic > 0 OR vr_dscritic <> '' THEN
               RETURN 'NOK';
            END IF;

            -- Gerar impressao da proposta em PDF para as opcoes abaixo
            ESTE0001.pc_extrai_dados(pr_xml      => pr_retxml,
                                     pr_cdcooper => vr_cdcooper,
                                     pr_nmdatela => vr_nmdatela,
                                     pr_nmeacao  => vr_nmeacao,
                                     pr_cdagenci => vr_cdagenci,
                                     pr_nrdcaixa => vr_nrdcaixa,
                                     pr_idorigem => vr_idorigem,
                                     pr_cdoperad => vr_cdoperad,
                                     pr_dscritic => vr_dscritic);
                                    
                                    
            IF pr_cdcritic > 0 OR   pr_dscritic <> '' THEN
               RETURN "NOK";
            END IF;

            IF vr_nmarqpdf = '' THEN
                vr_dscritic := 'Nao foi possivel gerar impressao da proposta para Analise de Credito.';
                RETURN "NOK";
            END IF;
            -- Chamar rotina de inclusao da proposta na Esteira
            pc_incluir_proposta_esteira(vr_cdcooper => pr_cdcooper,    -- pr_cdcooper
                                        vr_cdagenci => pr_cdagenci,     -- pr_cdagenci
                                        vr_cdoperad => pr_cdoperad,     -- pr_cdoperad
                                        vr_idorigem => pr_idorigem,     -- pr_cdorigem
                                        vr_nrdconta => pr_nrdconta,     -- pr_nrdconta
                                        vr_nrctremp => pr_nrctremp,     -- pr_nrctremp
                                        vr_dtmvtolt => pr_dtmvtolt,     -- pr_dtmvtolt
                                        vr_nmarqpdf => pr_nmarqpdf,     -- pr_nmarquiv
                                        pr_dsmensag => vr_dsmensag,     -- pr_dsmensag
                                        pr_cdcritic => vr_cdcritic,     -- pr_cdcritic
                                        pr_dscritic => vr_dscritic);    -- pr_dscritic

            --Fechar Cursor do contrato
            CLOSE cr_craplim;
          
          
            END IF;
	          
          pr_dsmensag := vr_dsmensag;
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
      END IF;


END incluir_proposta_esteira;



END ESTE0003;
/
