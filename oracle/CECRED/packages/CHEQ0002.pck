CREATE OR REPLACE PACKAGE CECRED.CHEQ0002 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CHEQ0002
  --  Sistema  : Rotinas focadas no sistema de Cheques - Imagens de Cheque
  --  Sigla    : CHEQ
  --  Autor    : Márcio José de Carvalho
  --  Data     : Maio/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Fazer as interfaces dos sistemas da Cecred com o IB e processar 
  --             as informações da imagem do cheque 
  --   Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------


  -- Retorna situação da cooperativa em relação a imagem do cheque
	PROCEDURE pc_situacao_img_chq_coop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
		                                   ,pr_idorigem IN INTEGER            --> Origem
    															 	   ,pr_flgsitim OUT INTEGER           --> Situação da Cooperativa (0-INATIVO/1-ATIVO)
		      														 ,pr_cdcritic OUT PLS_INTEGER       --> Cód. crítica
					   													 ,pr_dscritic OUT VARCHAR2);				--> Desc. crítica
                                      
  -- Verifica se para a cooperativa a imagem de cheque é tarifada e o valor para o cooperado
  PROCEDURE pc_valida_tarifacao_img_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta
                                          ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                          ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                          ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                          ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                          ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                          ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                          ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2);            --> Texto de erro/critica encontrada
                                          
  -- Valida e retorna os dados do cheque para que o SOA monte a URL e vefifique a existência da imagem 
  PROCEDURE pc_retorna_dados_img_chq(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                   ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                   ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                   ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                   ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                   ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                   ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta                                      
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador 
                                   ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                   ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                   ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                   ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2);            --> Texto de erro/critica encontrada

  -- Efetiva a tarifação da da imagem do cheque
  PROCEDURE pc_efetiva_tarifacao_img_chq(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                      ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                      ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                      ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                      ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                      ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                      ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta                                      
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador 
                                      ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                      ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                      ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                      ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2);            --> Texto de erro/critica encontrada
  -- Grava LOG nos casos de geração de PDF da imagem
  PROCEDURE pc_grava_log_pdf_img_chq (pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta                                      
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                     ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                     ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                     ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                     ,pr_nrcheque IN crapchd.nrctachq%TYPE  --> Número do cheque do cooperado
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2);            --> Texto de erro/critica encontrada
                                         
  -- Retorna as informações do cheque de acordo com sua situação
  PROCEDURE pc_consulta_detalhe_chq(pr_cdcooper IN crapfdc.cdcooper%TYPE  --> Cooperativa
                                   ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE  --> Código do Banco do cheque
                                   ,pr_cdagechq IN crapfdc.cdagechq%TYPE  --> Código da Agência do cheque
                                   ,pr_nrctachq IN crapfdc.nrctachq%TYPE  --> Número das conta                                      
                                   ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador 
                                   ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                   ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                   ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                   ,pr_cdorigem IN INTEGER                --> Código do Canal de Relacionamento – Valor '3' Internet ou '4' Caixa Eletrônico 
                                   ,pr_nrdcaixa IN INTEGER                --> Código de caixa do canal de atendimento – Valor fixo "900" para Internet e Caixa Eletrônico
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código de PA do canal de atendimento – Valor '90' para Internet ou '91' para Caixa Eletrônico
                                   ,pr_nmprogra IN VARCHAR2               --> Nome do programa – Valor "INTERNETBANK" Internet
                                   ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2);	--> Desc. crítica

  PROCEDURE pc_realiza_tarifa_imagem_chq(pr_cdcooper  IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                       pr_cdoperad  IN  crapope.cdoperad%TYPE, --> Código do operador 
                                       pr_nrdconta  IN  crapass.nrdconta%TYPE, --> Número da conta
                                       pr_cdbcc     IN  crapchd.cdbanchq%TYPE, -- Código do banco
                                       pr_cdagenci  IN  crapchd.cdagechq%TYPE, --> Agência
                                       pr_idorigem  IN  INTEGER,               --> Internet ou Ayllos
                                       pr_nmtela    IN  craplgm.nmdatela%TYPE, --> Nome da tela
                                       pr_idtipocns OUT INTEGER,               --> 0 - Pacote, 1 - Pacote sem saldo, 2 - Sem serviço no Pacote
                                       pr_cdcritic  OUT PLS_INTEGER,           --> Cód. crítica
                                       pr_dscritic  OUT VARCHAR2);             --> Desc. crítica

  PROCEDURE pc_bloqueia_imagem_chq(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                                   pr_dtmvtolt IN VARCHAR2,              --> Data de compenssção
                                   --pr_cdcmpchq IN crapchd.cdcmpchq%TYPE, --> Código de compensação
                                   pr_cdbanchq IN crapchd.cdbanchq%TYPE, --> Código do Banco do Cheque
                                   pr_cdagechq IN crapchd.cdagechq%TYPE, --> Código da Agência do cheque
                                   pr_nrctachq IN crapchd.nrctachq%TYPE, --> Número da conta do cheque 
                                   pr_nrcheque IN crapchd.nrcheque%TYPE, --> Número do cheque
                                   pr_tpremess IN VARCHAR2,              --> Tipo de remessa (S - Sua Remessa, N - Nossa Remessa)
                                   pr_flgblqim IN VARCHAR2,              --> Situação do bloqueio (N-Desbloqueio/S-Bloqueio)
                                   pr_xmllog   IN VARCHAR2 DEFAULT NULL, --XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER,          --> Cód. crítica
                                   pr_dscritic OUT VARCHAR2,             --> Desc. crítica
                                   pr_retxml   IN OUT NOCOPY XMLType,    --Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2,             --Nome do Campo
                                   pr_des_erro OUT VARCHAR2);            --> Desc. crítica                                       
                                   
  PROCEDURE pc_cobra_tarifa_imgchq_online(pr_cdcooper  IN NUMBER,
                                          pr_cdagechq  IN NUMBER,
                                          pr_nrctachq  IN NUMBER,
                                          pr_cdcritic OUT PLS_INTEGER,          --> Codigo da critica
                                          pr_dscritic OUT VARCHAR2,             --> Descricao da critica
                                          pr_des_erro OUT VARCHAR2);            --> Desc. erro		                                   
                                        
  PROCEDURE pc_valida_ultima_img_chq(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                                     pr_nrdconta IN crapass.nrdconta%TYPE, --> Número das conta
                                     pr_idseqttl IN crapsnh.idseqttl%TYPE, --> Sequência titular do cooperado
                                     pr_cdcritic OUT crapcri.cdcritic%TYPE,--> Crítica encontrada
                                     pr_dscritic OUT VARCHAR2);             --> Desc. crítica
                                     
  PROCEDURE pc_consulta_cheque_imgchq(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                                    pr_dtmvtolt IN VARCHAR2, --> Data de compenssção
                                    pr_cdbanchq IN crapchd.cdbanchq%TYPE, --> Código do Banco do Cheque
                                    pr_cdagechq IN crapchd.cdagechq%TYPE, --> Código da Agência do cheque
                                    pr_nrctachq IN crapchd.nrctachq%TYPE, --> Número da conta do cheque 
                                    pr_nrcheque IN crapchd.nrcheque%TYPE, --> Número do cheque
                                    pr_tpremess IN VARCHAR2,              --> Tipo de remessa (S - Sua Remessa, N - Nossa Remessa)
                                    pr_xmllog   IN VARCHAR2 DEFAULT NULL, --XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER,          --> Cód. crítica
                                    pr_dscritic OUT VARCHAR2,             --> Desc. crítica
                                    pr_retxml   IN OUT NOCOPY XMLType,    -- Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2,             -- Nome do Campo
                                    pr_des_erro OUT VARCHAR2);            -- Saida OK/NOK
                                                                                                                                                            
END CHEQ0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CHEQ0002 AS
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CHEQ0002
  --  Sistema  : Rotinas focadas no sistema de Cheques - Imagens de Cheque
  --  Sigla    : CHEQ
  --  Autor    : Márcio José de Carvalho
  --  Data     : Maio/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Fazer as interfaces dos sistemas da Cecred com o IB e processar 
  --             as informações da imagem do cheque 
  --   Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Retorna situação da cooperativa em relação a imagem do cheque
	PROCEDURE pc_situacao_img_chq_coop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
		                                ,pr_idorigem IN INTEGER              --> Origem
														        ,pr_flgsitim OUT INTEGER             --> Situação da Cooperativa (0-INATIVO/1-ATIVO)
    													 	    ,pr_cdcritic OUT PLS_INTEGER         --> Cód. crítica
		    													  ,pr_dscritic OUT VARCHAR2)	IS			 --> Desc. crítica
                                      		
  BEGIN
    /* .............................................................................
    Programa: pc_situacao_imagem_cheque_coop
    Sistema : CERED
    Autor   : Márcio José de Carvalho
    Data    : Maio/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar situação da cooperativa em relação a imagem do cheque

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
			-- Verificar situação da cooperativa
			CURSOR cr_coopparam(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
        SELECT
              decode(upper(c.dsconteu),'S',1,0) dsvlrprm
          FROM 
              crappco c 
         WHERE
              c.cdcooper = pr_cdcooper 
          AND c.cdpartar = 56; -- Código de produção que foi passado pela Sarah
			rw_coopparam cr_coopparam%ROWTYPE;
			
		BEGIN
		   IF pr_cdcooper IS NULL THEN
              vr_cdcritic  := 1143;
              RAISE vr_exc_erro;
       END IF;
           -- Verificar situação da cooperativa
			OPEN cr_coopparam(pr_cdcooper => pr_cdcooper);
			FETCH cr_coopparam INTO rw_coopparam;
      IF cr_coopparam%NOTFOUND THEN
        pr_flgsitim := 0;
      ELSE
         pr_flgsitim := rw_coopparam.dsvlrprm;
      END IF;
			CLOSE cr_coopparam;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_SITUACAO_IMAGEM_CHEQUE_COOP: ' || SQLERRM;
    END;
  END pc_situacao_img_chq_coop;

  -- Verifica se para a cooperativa a imagem de cheque é tarifada e o valor para o cooperado  
  PROCEDURE pc_valida_tarifacao_img_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta
                                        ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                        ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                        ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                        ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                        ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                        ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                        ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                        ,pr_dscritic OUT VARCHAR2) IS         --> Texto de erro/critica encontrada
    -- CURSORES
    CURSOR CR_CRAPASS IS
      select
            c.inpessoa
        from
            crapass c
       where
            c.cdcooper = pr_cdcooper
        and c.nrdconta = pr_nrdconta;
		
    -- Query para verificação do cheque -- Sua Remessa
		CURSOR crapfdc IS
      SELECT
           NVL(c.indimgvis, 'N') indimgvis
       FROM        
            crapfdc c,
            crapcop cc
      WHERE 
            c.cdcooper = pr_cdcooper
        AND c.cdbanchq = pr_cdbanchq             
        AND c.cdagechq = pr_cdagechq             
        AND c.nrctachq = pr_nrctachq
        AND c.nrcheque = pr_nrcheque
        and c.cdcooper = cc.cdcooper;

		-- Query para verificação do cheque -- Nossa Remessa
		CURSOR crapchd IS
      SELECT
           NVL(c.indimgvis, 'N') indimgvis
       FROM        
            crapchd c,
            crapcop cc
      WHERE 
            c.cdcooper = pr_cdcooper
        AND c.cdbanchq = pr_cdbanchq             
        AND c.cdagechq = pr_cdagechq             
        AND c.nrctachq = pr_nrctachq
        AND c.nrcheque = pr_nrcheque
        AND c.dtmvtolt = pr_dtmvtolt   
        --AND c.cdcmpchq = pr_cdcmpchq
        and c.cdcooper = cc.cdcooper;
       
    
    -- VARIÁVEIS
    vr_xml            CLOB;             --> XML do retorno
    vr_texto_completo VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    --Variáveis locais
    vr_flpacote NUMBER := 0; --> Flag de Pacote
    vr_flservic NUMBER := 0; --> Flag de Sevico
    vr_qtopdisp NUMBER := 0; --> Quantidade de Operacoes Disponiveis
    vr_cdhistor      INTEGER;
    vr_cdhisest      NUMBER;
    vr_vltarifa      NUMBER;
    vr_dtdivulg      DATE;
    vr_dtvigenc      DATE;
    vr_cdfvlcop      INTEGER;
    vr_tab_erro      GENE0001.typ_tab_erro;  
    vr_tarifa        NUMBER(5);    
    vr_achou_cheque  VARCHAR2(1):='N';
    vr_chq_vis       VARCHAR2(10) :='FALSE';      

  BEGIN

    -- Inicializar as informações do XML de dados para o 
    dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

	  IF pr_cdcooper IS NULL THEN
       vr_cdcritic  := 1143;
       RAISE vr_exc_saida;
    ELSIF pr_nrdconta IS NULL THEN
       vr_cdcritic  := 1144;
       RAISE vr_exc_saida;
    END IF;

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><InformacoesContas>'||chr(13));
    
    -- Verificar se o cheque já foi visualizado
    -- Primeiro verifica o cheque na tabela de NOSSA REMESSA
    FOR c2 in crapchd LOOP    
        vr_achou_cheque:='S';
        IF c2.indimgvis = 'S' THEN
          vr_chq_vis:= 'TRUE';
        END IF;
      END LOOP;
    
    -- Se não encontrou na NOSSA REMESSA, verifica na SUA REMESSA
    IF vr_achou_cheque = 'N' THEN
       FOR c3 in crapfdc LOOP    
           vr_achou_cheque:='S';
           IF c3.indimgvis = 'S' THEN
             vr_chq_vis:= 'TRUE';
           END IF;
       END LOOP;  
    END IF;
    
    FOR C1 in CR_CRAPASS LOOP
      -- Pessoa Fisica
      IF c1.inpessoa = 1 THEN
        vr_tarifa := 368;
      ELSE
        vr_tarifa := 369;        
      END IF;
      
    END LOOP;      
    -- Verificar se a conta do cooperatdo possui pacote de tarifa
    -- Se possuir pacote
    --vertificar se no pacote existe o tipo de serviço - Imagem de Cheque 
    TARI0001.pc_verifica_pacote_tarifas(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                       ,pr_idorigem => 3             --> Origem
                                       ,pr_tpservic => 23            --> Tipo de Servico
                                       ,pr_flpacote => vr_flpacote   --> Flag de Pacote
                                       ,pr_flservic => vr_flservic   --> Flag de Sevico
                                       ,pr_qtopdisp => vr_qtopdisp   --> Quantidade de Operacoes Disponiveis
                                       ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                       ,pr_dscritic => vr_dscritic); --> Descrição da crítica    
      
    IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
    END IF;
    
    IF vr_flpacote = 0 THEN -- Não encontrou o tipo de produto dentro do pacote de tarifa 
                            -- ou não encontro pacote associado a conta
                            
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                   ,pr_cdbattar => null          --Codigo Tarifa
                                   ,pr_cdtarifa => vr_tarifa     --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário                                         
                                   ,pr_vllanmto => 0             --Valor Lancamento
                                   ,pr_cdprogra => 'IMGCHQ'      --Codigo Programa
                                   ,pr_cdhistor => vr_cdhistor   --Codigo Historico
                                   ,pr_cdhisest => vr_cdhisest   --Historico Estorno
                                   ,pr_vltarifa => vr_vltarifa   --Valor tarifa
                                   ,pr_dtdivulg => vr_dtdivulg   --Data Divulgacao
                                   ,pr_dtvigenc => vr_dtvigenc   --Data Vigencia
                                   ,pr_cdfvlcop => vr_cdfvlcop   --Codigo faixa valor cooperativa
                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                   ,pr_dscritic => vr_dscritic   --Descricao Critica
                                   ,pr_tab_erro => vr_tab_erro); --Tabela de erros
   
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel carregar a tarifa.';
        END IF;
        -- Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      IF nvl(vr_vltarifa,0) > 0 THEN
      -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemtarifa>'||chr(13)||
             '<VlTarifa>'  ||to_char(vr_vltarifa,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.')||'</VlTarifa>' ||chr(13)||
             '<CdTarifa>'  ||vr_tarifa  ||'</CdTarifa>'  ||chr(13)||
             '<chequeVisualizado>'  ||vr_chq_vis  ||'</chequeVisualizado>'  ||chr(13)||             
             '<QtConsDisp></QtConsDisp>'||chr(13)             
             );
      ELSE -- valor da tarifa igual a zero
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemtarifa>'||chr(13)||
             '<VlTarifa>'  ||'0'||'</VlTarifa>'  ||chr(13)||
             '<CdTarifa></CdTarifa>'  ||chr(13)||             
             '<chequeVisualizado>'  ||vr_chq_vis  ||'</chequeVisualizado>'  ||chr(13)||                          
             '<QtConsDisp></QtConsDisp>'||chr(13));
      END IF;                                  
      -- Finaliza o nó
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</mensagemtarifa></InformacoesContas>',TRUE);                
    ELSE
    --Se a quantidade de consutas disponíveis for maior que zero
    IF nvl(vr_qtopdisp,0) > 0 THEN
      -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemtarifa>'||chr(13)||
             '<VlTarifa></VlTarifa>'||chr(13)||
             '<CdTarifa></CdTarifa>'  ||chr(13)||             
             '<chequeVisualizado>'  ||vr_chq_vis  ||'</chequeVisualizado>'  ||chr(13)||                          
             '<QtConsDisp>'||vr_qtopdisp||'</QtConsDisp>'||chr(13));
      -- Finaliza o nó
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</mensagemtarifa></InformacoesContas>',TRUE);                    
    ELSE -- Já utilizou o pacote de serviço
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                   ,pr_cdbattar => null          --Codigo Tarifa
                                   ,pr_cdtarifa => vr_tarifa           --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário                                         
                                   ,pr_vllanmto => 0             --Valor Lancamento
                                   ,pr_cdprogra => 'IMGCHQ'      --Codigo Programa
                                   ,pr_cdhistor => vr_cdhistor   --Codigo Historico
                                   ,pr_cdhisest => vr_cdhisest   --Historico Estorno
                                   ,pr_vltarifa => vr_vltarifa   --Valor tarifa
                                   ,pr_dtdivulg => vr_dtdivulg   --Data Divulgacao
                                   ,pr_dtvigenc => vr_dtvigenc   --Data Vigencia
                                   ,pr_cdfvlcop => vr_cdfvlcop   --Codigo faixa valor cooperativa
                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                   ,pr_dscritic => vr_dscritic   --Descricao Critica
                                   ,pr_tab_erro => vr_tab_erro); --Tabela de erros
    
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel carregar a tarifa.';
        END IF;
        -- Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      IF nvl(vr_vltarifa,0) > 0 THEN
      -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemtarifa>'||chr(13)||
             '<VlTarifa>'  ||to_char(vr_vltarifa,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.')||'</VlTarifa>' ||chr(13)||
             '<CdTarifa>'  ||vr_tarifa   ||'</CdTarifa>'  ||chr(13)||  
             '<chequeVisualizado>'  ||vr_chq_vis  ||'</chequeVisualizado>'  ||chr(13)||                                     
             '<QtConsDisp></QtConsDisp>'||chr(13));
      ELSE -- valor da tarifa igual a zero
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemtarifa>'||chr(13)||
             '<VlTarifa>'  ||'0'||'</VlTarifa>'  ||chr(13)||
             '<CdTarifa></CdTarifa>'  ||chr(13)||    
             '<chequeVisualizado>'  ||vr_chq_vis  ||'</chequeVisualizado>'  ||chr(13)||                                   
             '<QtConsDisp></QtConsDisp>'||chr(13));
      END IF;             
      -- Finaliza o nó
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</mensagemtarifa></InformacoesContas>',TRUE);                    END IF;
  END IF; 
  -- Converte o CLOB para o XML de retorno
  pr_xml := XMLType.createxml(vr_xml);
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Retorna as informacoes
      ROLLBACK;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro CHEQ0002.pc_valida_tarifacao_imagem_cheque: '||sqlerrm;

      -- Retorna as informacoes
      ROLLBACK;
    
  END pc_valida_tarifacao_img_chq;

  -- Valida e retorna os dados do cheque para que o SOA monte a URL e vefifique a existência da imagem 
  PROCEDURE pc_retorna_dados_img_chq(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                      ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                      ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                      ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                      ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                      ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                      ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta                                      
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador 
                                      ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                      ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                      ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                      ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS       --> Desc. crítica
                                          
  BEGIN
    /* .............................................................................
    Programa: pc_valida_dados_img_chq
    Sistema : CERED
    Autor   : Márcio José de Carvalho
    Data    : Maio/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consulta do cheque, retorno dos parâmetros do cheque 
                para que o SOA monte a URL e consulta a existência da imagem no servidor de imagens
                se a imagem existir o SOA irá chamar a rotina PC_EFETIVA_TARIFACAO_IMG_CHQ
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Query para verificação do cheque -- Sua Remessa
      CURSOR crapfdc IS
        SELECT
             replace(replace(replace(c.dsdocmc7,':',''),'<',''),'>','') dsdocmc7,
              NVL(c.indimgvis, 'N') indimgvis,
              NVL(c.indblqvic, 'N') indblqvic, 
              c.cdageaco,
              lpad(cc.cdagectl,4,'0') cdagenci ,
              to_char(c.dtliqchq, 'YYYY-MM-DD')dtmvtolt,               
              c.rowid,
              trunc(sysdate) - c.dtliqchq qtddias              
         FROM        
              crapfdc c,
              crapcop cc
        WHERE 
              c.cdcooper = pr_cdcooper
          AND c.cdbanchq = pr_cdbanchq             
          AND c.cdagechq = pr_cdagechq             
          AND c.nrctachq = pr_nrctachq
          AND c.nrcheque = pr_nrcheque
          and c.cdcooper = cc.cdcooper;

      -- Query para verificação do cheque -- Nossa Remessa
      CURSOR crapchd IS
        SELECT
             replace(replace(replace(c.dsdocmc7,':',''),'<',''),'>','') dsdocmc7,
              NVL(c.indimgvis, 'N') indimgvis,
              NVL(c.indblqvic, 'N') indblqvic, 
              lpad(cc.cdagectl,4,'0')cdagenci ,
              to_char(c.dtmvtolt, 'YYYY-MM-DD')dtmvtolt,               
              c.rowid,
              trunc(sysdate) - c.dtmvtolt qtddias                             
         FROM        
              crapchd c,
              crapcop cc
        WHERE 
              c.cdcooper = pr_cdcooper
          AND c.cdbanchq = pr_cdbanchq             
          AND c.cdagechq = pr_cdagechq             
          AND c.nrctachq = pr_nrctachq
          AND c.nrcheque = pr_nrcheque
          AND c.dtmvtolt = pr_dtmvtolt   
          --AND c.cdcmpchq = pr_cdcmpchq
          and c.cdcooper = cc.cdcooper;

    CURSOR  CR_CAMINHO_IMAGEM IS         
      SELECT
             cp.dsvlrprm
         FROM
             crapprm cp
        WHERE
             cp.nmsistem = 'CRED'
         AND cp.cdacesso = 'CAMINHO_IMG_CHQ'             
         AND cp.cdcooper = 0;
    RW_CAMINHO_IMAGEM CR_CAMINHO_IMAGEM%ROWTYPE;          
          
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_msgerro  VARCHAR2(200);
      
      vr_urlorigem             VARCHAR2(300);
--      vr_idtipocns             INTEGER;
      vr_xml                   CLOB;             --> XML do retorno
      vr_texto_completo        VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB      
      vr_nrdrowid              ROWID;
      vr_achou_cheque          varchar2(1):='N';      
                
    BEGIN
      -- Inicializar as informações do XML de dados para o 
      dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
    
      IF pr_cdcooper IS NULL THEN
         vr_cdcritic  := 1143;
         RAISE vr_exc_erro;
      ELSIF pr_cdbanchq IS NULL THEN
         vr_cdcritic  := 1265;
         RAISE vr_exc_erro; 
      ELSIF pr_cdagechq IS NULL THEN
         vr_cdcritic  := 89;
         RAISE vr_exc_erro;  
      ELSIF pr_nrctachq IS NULL THEN
         vr_cdcritic  := 1144;
         RAISE vr_exc_erro;  
      ELSIF pr_nrcheque IS NULL THEN
         vr_cdcritic  := 1266;
         RAISE vr_exc_erro;  
      ELSIF pr_idseqttl IS NULL THEN
         vr_cdcritic  := 1268;
         RAISE vr_exc_erro; 
      ELSIF pr_cdoperad IS NULL THEN         
         vr_cdcritic  := 87;
         RAISE vr_exc_erro; 
      ELSIF pr_dsorigem IS NULL THEN   
         vr_cdcritic  := 1269;
         RAISE vr_exc_erro; 
      ELSIF pr_nmtela IS NULL THEN   
         vr_cdcritic  := 1270;
         RAISE vr_exc_erro; 
      ELSIF pr_dsip IS NULL THEN   
         vr_cdcritic  := 1271;
         RAISE vr_exc_erro;                                                                                           
      END IF;
      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><ImagemCheque>'||chr(13));

     -- Busca o caminho da imágem do cheque
    OPEN cr_caminho_imagem;
    FETCH cr_caminho_imagem INTO rw_caminho_imagem;
    IF cr_caminho_imagem%NOTFOUND THEN
      CLOSE cr_caminho_imagem;
      vr_dscritic := 'Diretório da imagem do cheque não cadastrado!';
      RAISE vr_exc_erro;
    ELSE
       vr_urlorigem := rw_caminho_imagem.dsvlrprm;
    END IF;
    CLOSE cr_caminho_imagem;

    -- Se tratando em buscar a imagem de cheque primeiramente procuramos no NOSSA REMESSA
    -- Pois o cheque SOBE como NOSSA e BAIXA como SUA mas a imagem propriamente dita está no NOSSA REMESSA
    FOR c1 in crapchd LOOP
          -- Verifica se o cheque foi bloqueado devido imagem estar errada
          IF c1.indblqvic = 'S' THEN
            vr_msgerro:= 'Este cheque está bloqueado para visualização. Favor verificar com seu Posto de Atendimento.';            
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<CaminhoImagemCheque>'||chr(13)||
               '<Diretorio>'    ||' '        ||'</Diretorio>'||chr(13)||
               '<Data>'         ||' '        ||'</Data>'     ||chr(13)||
               '<Agencia>'      ||' '        ||'</Agencia>'  ||chr(13)||
               '<Tipo>'         ||' '        ||'</Tipo>'     ||chr(13)||
               '<Dsdocmc7>'     ||' '        ||'</Dsdocmc7>' ||chr(13)||
               '<MsgErro>'      ||vr_msgerro||'</MsgErro>'||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            
            -- gravar log do erro
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta da Imagem do Cheque'                           
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Nossa Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
            
        ELSIF c1.qtddias > 1825 THEN          
            vr_msgerro:= 'Imagem não disponível para cheques compensados em período superior a cinco anos (60 meses).';
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<CaminhoImagemCheque>'||chr(13)||
               '<Diretorio>'    ||' '        ||'</Diretorio>'||chr(13)||
               '<Data>'         ||' '        ||'</Data>'     ||chr(13)||
               '<Agencia>'      ||' '        ||'</Agencia>'  ||chr(13)||
               '<Tipo>'         ||' '        ||'</Tipo>'     ||chr(13)||
               '<Dsdocmc7>'     ||' '        ||'</Dsdocmc7>' ||chr(13)||
               '<MsgErro>'      ||vr_msgerro||'</MsgErro>'||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            
            -- gravar log do erro
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta da Imagem do Cheque'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Nossa Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
          ELSE
            vr_achou_cheque:='S';            
            -- gravar log da ação
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta da Imagem do Cheque'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Nossa Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                

              -- Popula a linha de detalhes
              gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                 '<CaminhoImagemCheque>'||chr(13)||
                 '<Diretorio>'    ||vr_urlorigem           ||'</Diretorio>'||chr(13)||
                 '<Data>'         ||c1.dtmvtolt            ||'</Data>'     ||chr(13)||
                 '<Agencia>'      ||lpad(c1.cdagenci,4,'0')||'</Agencia>'  ||chr(13)||
                 '<Tipo>'         ||'nr'                   ||'</Tipo>'     ||chr(13)||
                 '<Dsdocmc7>'     ||c1.dsdocmc7            ||'</Dsdocmc7>' ||chr(13)||
                 '<MsgErro>'      ||vr_msgerro             ||'</MsgErro>'      ||chr(13)                           
                );
              -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            
          END IF;
        END LOOP;
      
      -- Verifica se encontrou na NOSSA REMESSA, se não encontrou e não gerou erro, verifica na SUA REMESSA
		  IF vr_achou_cheque = 'N' and vr_msgerro is null THEN
        IF pr_dtmvtolt IS NULL THEN
           vr_cdcritic  := 1273;
           RAISE vr_exc_erro;
        --ELSIF pr_cdcmpchq IS NULL THEN
           --vr_cdcritic  := 1274;
           --RAISE vr_exc_erro; 
        END IF;

      FOR c2 in crapfdc LOOP
        -- Verifica se o cheque foi bloqueado devido imagem estar errada
        IF c2.indblqvic = 'S' THEN
            vr_msgerro:= 'Este cheque está bloqueado para visualização. Favor verificar com seu Posto de Atendimento.';
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<CaminhoImagemCheque>'                      ||chr(13)||
               '<Diretorio>'    ||' '        ||'</Diretorio>'||chr(13)||
               '<Data>'         ||' '        ||'</Data>'     ||chr(13)||
               '<Agencia>'      ||' '        ||'</Agencia>'  ||chr(13)||
               '<Tipo>'         ||' '        ||'</Tipo>'     ||chr(13)||
               '<Dsdocmc7>'     ||' '        ||'</Dsdocmc7>' ||chr(13)||
               '<MsgErro>'      ||vr_msgerro||'</MsgErro>'  ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            

            -- gravar log do erro
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta da Imagem do Cheque'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Sua Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
            
        ELSIF c2.qtddias > 1825 THEN
            vr_msgerro:= 'Imagem não disponível para cheques compensados em período superior a cinco anos (60 meses).';
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<CaminhoImagemCheque>'                      ||chr(13)||
               '<Diretorio>'    ||' '        ||'</Diretorio>'||chr(13)||
               '<Data>'         ||' '        ||'</Data>'     ||chr(13)||
               '<Agencia>'      ||' '        ||'</Agencia>'  ||chr(13)||
               '<Tipo>'         ||' '        ||'</Tipo>'     ||chr(13)||
               '<Dsdocmc7>'     ||' '        ||'</Dsdocmc7>' ||chr(13)||
               '<MsgErro>'      ||vr_msgerro||'</MsgErro>'  ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            

            -- gravar log do erro
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta da Imagem do Cheque'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Sua Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
                                
        ELSE
          vr_achou_cheque := 'S';
          -- gravar log da ação
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_msgerro
                              ,pr_dsorigem => pr_dsorigem
                              ,pr_dstransa => 'Consulta da Imagem do Cheque'                                           
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                    ELSE 0 
                                               END )
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmtela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Sua Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
                              

            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<CaminhoImagemCheque>'||chr(13)||
               '<Diretorio>'    ||vr_urlorigem           ||'</Diretorio>'||chr(13)||
               '<Data>'         ||c2.dtmvtolt            ||'</Data>'     ||chr(13)||
               '<Agencia>'      ||lpad(pr_cdagechq,4,'0')||'</Agencia>'  ||chr(13)||
               '<Tipo>'         ||'sr'                   ||'</Tipo>'     ||chr(13)||
               '<Dsdocmc7>'     ||c2.dsdocmc7            ||'</Dsdocmc7>' ||chr(13)||
               '<MsgErro>'      ||vr_msgerro             ||'</MsgErro>'  ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            
        END IF;
      END LOOP;
          
      END IF;   
      -- Se não encontrou o cheque, e se já não gerou erro por estar bloqueado, retorna mensagem de erro
      IF vr_achou_cheque = 'N' and vr_msgerro is null THEN   
        vr_msgerro:= 'Dados do cheque não encontrado.';            
        -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
           '<CaminhoImagemCheque>'||chr(13)||
           '<Diretorio>'    ||' '        ||'</Diretorio>'||chr(13)||
           '<Data>'         ||' '        ||'</Data>'     ||chr(13)||
           '<Agencia>'      ||' '        ||'</Agencia>'  ||chr(13)||
           '<Tipo>'         ||' '        ||'</Tipo>'     ||chr(13)||
           '<Dsdocmc7>'     ||' '        ||'</Dsdocmc7>' ||chr(13)||
           '<MsgErro>'      ||vr_msgerro||'</MsgErro>'||chr(13)                           
          );
        -- Finaliza o nó
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</CaminhoImagemCheque></ImagemCheque>',TRUE);            
        -- gravar log do erro
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_msgerro
                            ,pr_dsorigem => pr_dsorigem
                            ,pr_dstransa => 'Consulta da Imagem do Cheque'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                  ELSE 0 
                                             END )
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmtela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
                            
      END IF;
      -- Converte o CLOB para o XML de retorno
      pr_xml := XMLType.createxml(vr_xml);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_SITUACAO_IMAGEM_CHEQUE_COOP: ' || SQLERRM;
    END;
  END pc_retorna_dados_img_chq;
  
  -- Efetiva a tarifação da da imagem do cheque
  PROCEDURE pc_efetiva_tarifacao_img_chq(pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                      ,pr_cdbanchq IN crapchd.cdbanchq%TYPE  --> Código do banco do cheque      
                                      ,pr_cdagechq IN crapchd.cdagechq%TYPE  --> Código da agência do cheque    
                                      ,pr_nrctachq IN crapchd.nrctachq%TYPE  --> Número da conta do cheque
                                      ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                      ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE  --> Data da compensação
                                      ,pr_cdcmpchq IN crapchd.cdcmpchq%TYPE  --> Código da Compensação do cheque
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta                                      
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador 
                                      ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                      ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                      ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                      ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2)	IS			 --> Desc. crítica
                                      		
  BEGIN
    /* .............................................................................
    Programa: pc_efetiva_tarifacao_img_chq
    Sistema : CERED
    Autor   : Márcio José de Carvalho
    Data    : Maio/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetivar a cobrança da tarifa caso a mesma deva ser tarifada

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

			-- Query para verificação do cheque -- Sua Remessa
			CURSOR crapfdc IS
        SELECT
             replace(replace(replace(c.dsdocmc7,':',''),'<',''),'>','') dsdocmc7,
              NVL(c.indimgvis, 'N') indimgvis,
              NVL(c.indblqvic, 'N') indblqvic, 
              c.cdageaco,
              lpad(cc.cdagectl,4,'0') cdagenci ,
              to_char(c.dtliqchq, 'YYYY-MM-DD')dtmvtolt,               
              c.rowid
         FROM        
              crapfdc c,
              crapcop cc
        WHERE 
              c.cdcooper = pr_cdcooper
          AND c.cdbanchq = pr_cdbanchq             
          AND c.cdagechq = pr_cdagechq             
          AND c.nrctachq = pr_nrctachq
          AND c.nrcheque = pr_nrcheque
          and c.cdcooper = cc.cdcooper;

			-- Query para verificação do cheque -- Nossa Remessa
			CURSOR crapchd IS
        SELECT
             replace(replace(replace(c.dsdocmc7,':',''),'<',''),'>','') dsdocmc7,
              NVL(c.indimgvis, 'N') indimgvis,
              NVL(c.indblqvic, 'N') indblqvic, 
              lpad(cc.cdagectl,4,'0')cdagenci ,
              to_char(c.dtmvtolt, 'YYYY-MM-DD')dtmvtolt,               
              c.rowid              
         FROM        
              crapchd c,
              crapcop cc
        WHERE 
              c.cdcooper = pr_cdcooper
          AND c.cdbanchq = pr_cdbanchq             
          AND c.cdagechq = pr_cdagechq             
          AND c.nrctachq = pr_nrctachq
          AND c.nrcheque = pr_nrcheque
          AND c.dtmvtolt = pr_dtmvtolt   
          --AND c.cdcmpchq = pr_cdcmpchq
          and c.cdcooper = cc.cdcooper;
          
      -- CURSORES
      CURSOR CR_CRAPASS IS
        select
              c.inpessoa
          from
              crapass c
         where
              c.cdcooper = pr_cdcooper
          and c.nrdconta = pr_nrdconta;          

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_msgerro  VARCHAR2(200);
      
      vr_urlorigem             VARCHAR2(300);
      vr_indimgvis		         VARCHAR2(1);
      vr_tpconvic	             VARCHAR2(1);
      vr_idtipocns             INTEGER;
      vr_xml                   CLOB;             --> XML do retorno
      vr_texto_completo        VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB      
      vr_nrdrowid              ROWID;      
      vr_achou_cheque          varchar2(1):='N';
      vr_tarifa                NUMBER(5);       
      vr_cdhistor              INTEGER;
      vr_cdhisest              NUMBER;
      vr_vltarifa              NUMBER;
      vr_dtdivulg              DATE;
      vr_dtvigenc              DATE;
      vr_cdfvlcop              INTEGER;
      vr_tab_erro              GENE0001.typ_tab_erro;        
           
                			
		BEGIN
      -- Inicializar as informações do XML de dados para o 
      dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
	  
      IF pr_cdcooper IS NULL THEN
         vr_cdcritic  := 1143;
         RAISE vr_exc_erro;
      ELSIF pr_cdbanchq IS NULL THEN
         vr_cdcritic  := 1265;
         RAISE vr_exc_erro; 
      ELSIF pr_cdagechq IS NULL THEN
         vr_cdcritic  := 89;
         RAISE vr_exc_erro;  
      ELSIF pr_nrctachq IS NULL THEN
         vr_cdcritic  := 1144;
         RAISE vr_exc_erro;  
      ELSIF pr_nrcheque IS NULL THEN
         vr_cdcritic  := 1267;
         RAISE vr_exc_erro;  
      ELSIF pr_idseqttl IS NULL THEN
         vr_cdcritic  := 1268;
         RAISE vr_exc_erro; 
      ELSIF pr_cdoperad IS NULL THEN         
         vr_cdcritic  := 87;
         RAISE vr_exc_erro; 
      ELSIF pr_dsorigem IS NULL THEN   
         vr_cdcritic  := 1269;
         RAISE vr_exc_erro; 
      ELSIF pr_nmtela IS NULL THEN   
         vr_cdcritic  := 1270;
         RAISE vr_exc_erro; 
      ELSIF pr_dsip IS NULL THEN   
         vr_cdcritic  := 1271;
         RAISE vr_exc_erro;                                                                                           
      END IF;
      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><ImagemCheque>'||chr(13));

      FOR C1 in CR_CRAPASS LOOP
        -- Pessoa Fisica
        IF c1.inpessoa = 1 THEN
          vr_tarifa := 368;
        -- Pessoa Jurídica  
        ELSE
          vr_tarifa := 369;        
        END IF;
      END LOOP;  
    
      -- Se tratando em tarifar a consulta da imagem de cheque primeiramente procuramos no NOSSA REMESSA
      -- Pois o cheque SOBE como NOSSA e BAIXA como SUA mas a imagem propriamente dita está no NOSSA REMESSA
      FOR c1 in crapchd LOOP
          vr_achou_cheque:='S';
          -- Verifica se o cheque foi bloqueado devido imagem estar errada
          IF c1.indblqvic = 'S' THEN
            vr_msgerro:= 'Este cheque está bloqueado para visualização. Favor verificar com seu Posto de Atendimento.';            
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<Tarifacao>'                   ||chr(13)||
               '<CdTarifa></CdTarifa>'         ||chr(13)||               
               '<VlrTarifa></VlrTarifa>'       ||chr(13)||                              
               '<MsgErro>'  ||vr_msgerro||'</MsgErro>'  ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            
            -- gravar log do erro
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Verifica Tarifa Erro - Imagem Cheque'                           
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Nossa Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
                                
            
          ELSE
            -- gravar log da ação
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Verifica Tarifa - Imagem Cheque'                                       
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Nossa Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                

            -- Se encontrou o cheque e o mesmo não foi visualizado:
            IF vr_achou_cheque = 'S' AND c1.indimgvis = 'N' THEN
              -- chama rotina de tarifação
              CHEQ0002.pc_realiza_tarifa_imagem_chq(pr_cdcooper => pr_cdcooper,
                                                    pr_cdoperad => pr_cdoperad,
                                                    pr_nrdconta => pr_nrdconta,
                                                    pr_cdbcc    => 100,
                                                    pr_cdagenci => 1,
                                                    pr_idorigem => 3,
                                                    pr_nmtela   =>'IMGCHQON',
                                                    -- OUT
                                                    pr_idtipocns => vr_idtipocns,  --> 0 - Pacote, 1 - Pacote sem saldo, 2 - Sem serviço no Pacote                                                                                                                                                        
                                                    pr_cdcritic => vr_cdcritic,
                                                    pr_dscritic => vr_dscritic) ;         
              IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
                RAISE vr_exc_erro;
              END IF;            
              -- Se a consulta foi no pacote de serviços e tinha saldo
              IF vr_idtipocns = 0 THEN
                 vr_tpconvic := 'P'; -- Pacote cobriu
                 -- Popula a linha de detalhes
                 gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                    '<Tarifacao>'||chr(13)||
                    '<CdTarifa>'||vr_tarifa  ||'</CdTarifa>' ||chr(13)||             
                    '<VlrTarifa>'||0         ||'</VlrTarifa>'||chr(13)||                                    
                    '<MsgErro>'  ||vr_msgerro||'</MsgErro>'  ||chr(13)                           
                   );
                   
                  -- gravar log da ação
                  GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_dscritic => vr_msgerro
                                      ,pr_dsorigem => pr_dsorigem
                                      ,pr_dstransa => 'Desconta Consulta Pacote - Imagem Cheque'                                       
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                            ELSE 0 
                                                       END )
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_nmdatela => pr_nmtela
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
                  -- gravar item do log                                 
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => 'Nossa Remessa');  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cooperativa'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdcooper);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Banco do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdbanchq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Agência do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdagechq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Conta do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_nrctachq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Número do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_nrcheque);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Data de Compensação'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'IP Conectado'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_dsip);
                   
              ELSE
                 vr_tpconvic := 'I'; -- Pacote sem saldo ou não está no pacote 
                 -- Busca o valor da tarifa
                 TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                            ,pr_cdbattar => null          --Codigo Tarifa
                                            ,pr_cdtarifa => vr_tarifa     --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário                                         
                                            ,pr_vllanmto => 0             --Valor Lancamento
                                            ,pr_cdprogra => 'IMGCHQ'      --Codigo Programa
                                            ,pr_cdhistor => vr_cdhistor   --Codigo Historico
                                            ,pr_cdhisest => vr_cdhisest   --Historico Estorno
                                            ,pr_vltarifa => vr_vltarifa   --Valor tarifa
                                            ,pr_dtdivulg => vr_dtdivulg   --Data Divulgacao
                                            ,pr_dtvigenc => vr_dtvigenc   --Data Vigencia
                                            ,pr_cdfvlcop => vr_cdfvlcop   --Codigo faixa valor cooperativa
                                            ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                            ,pr_dscritic => vr_dscritic   --Descricao Critica
                                            ,pr_tab_erro => vr_tab_erro); --Tabela de erros
   
                 -- Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   -- Se possui erro no vetor
                   IF vr_tab_erro.Count > 0 THEN
                     vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                   ELSE
                     vr_cdcritic := 0;
                     vr_dscritic := 'Nao foi possivel carregar a tarifa.';
                   END IF;
                   -- Levantar Excecao
                   RAISE vr_exc_erro;
                 END IF;
                 -- Popula a linha de detalhes
                 gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                   '<Tarifacao>' ||chr(13)||
                    '<CdTarifa>' ||vr_tarifa  ||'</CdTarifa>' ||chr(13)||             
                    '<VlrTarifa>'||vr_vltarifa||'</VlrTarifa>'||chr(13)||                                    
                    '<MsgErro>'  ||vr_msgerro ||'</MsgErro>'  ||chr(13)                           
                   );
                   
                  -- gravar log da ação
                  GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_dscritic => vr_msgerro
                                      ,pr_dsorigem => pr_dsorigem
                                      ,pr_dstransa => 'Efetiva Tarifa Consulta - Imagem Cheque'                                       
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                            ELSE 0 
                                                       END )
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_nmdatela => pr_nmtela
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
                  -- gravar item do log                                 
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => 'Nossa Remessa');  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cooperativa'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdcooper);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Banco do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdbanchq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Agência do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdagechq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Conta do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_nrctachq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Número do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_nrcheque);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Data de Compensação'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'IP Conectado'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_dsip);
                   
              END IF;             

            --Faz update para cheque visualizado
              BEGIN
                UPDATE
                      crapchd c
                   SET
                      c.indimgvis = 'S',
                      c.tpconvic  = vr_tpconvic,
                      c.dtconvic  = sysdate
                 WHERE
                      c.rowid = c1.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao alterar a tabela CRAPCHD: ' || SQLERRM;             
              END;
              -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            
            -- Se encontrou o cheque e o mesmo já foi visualizado:
            ELSIF vr_achou_cheque = 'S'  AND c1.indimgvis = 'S' THEN
              -- Popula a linha de detalhes
               gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                 '<Tarifacao>'||chr(13)   ||
                 '<CdTarifa>' ||vr_tarifa ||'</CdTarifa>' ||chr(13)||                                  
                 '<VlrTarifa>'||0         ||'</VlrTarifa>'||chr(13)||                                                     
                 '<MsgErro>'  ||vr_msgerro||'</MsgErro>'  ||chr(13)                           
                );
                
               -- gravar log da ação
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dscritic => vr_msgerro
                                   ,pr_dsorigem => pr_dsorigem
                                   ,pr_dstransa => 'Cheque visualizado - Nao cobrar tarifa'                                       
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                        ELSE 0 
                                                    END )
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nmdatela => pr_nmtela
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
               -- gravar item do log                                 
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => 'Nossa Remessa');  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Cooperativa'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdcooper);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Banco do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdbanchq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Agência do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdagechq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Conta do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_nrctachq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Número do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_nrcheque);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Data de Compensação'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'IP Conectado'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_dsip);  
 
                
              -- Finaliza o nó
              gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            
            END IF;
          END IF;
        END LOOP;
      
      -- Verifica se encontrou na NOSSA REMESSA, se não encontrou e não gerou erro, verifica na SUA REMESSA
      IF vr_achou_cheque = 'N' and vr_msgerro is null THEN
         IF pr_dtmvtolt IS NULL THEN
            vr_cdcritic  := 1273;
            RAISE vr_exc_erro;
         --ELSIF pr_cdcmpchq IS NULL THEN
            --vr_cdcritic  := 1274;
            --RAISE vr_exc_erro; 
         END IF;
         
      FOR c2 in crapfdc LOOP
        vr_achou_cheque:='S';
        -- Verifica se o cheque foi bloqueado devido imagem estar errada
        IF c2.indblqvic = 'S' THEN
            vr_msgerro:= 'Este cheque está bloqueado para visualização. Favor verificar com seu Posto de Atendimento.';
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<Tarifacao>'                        ||chr(13)||
               '<CdTarifa></CdTarifa>'              ||chr(13)||
               '<VlrTarifa></VlrTarifa>'            ||chr(13)||               
               '<MsgErro>'||vr_msgerro||'</MsgErro>'||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            

            -- gravar log do erro
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Verifica Tarifa Erro - Imagem Cheque'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                      ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Sua Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
            
        ELSE
          -- gravar log da ação
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_msgerro
                              ,pr_dsorigem => pr_dsorigem
                              ,pr_dstransa => 'Verifica Tarifa - Imagem Cheque'                                  
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                    ELSE 0 
                                               END )
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmtela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => 'Sua Remessa');  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
          
          -- Se encontrou o cheque e o mesmo não foi visualizado:
          IF vr_achou_cheque = 'S' AND c2.indimgvis = 'N' THEN
            -- chama rotina de tarifação
            CHEQ0002.pc_realiza_tarifa_imagem_chq(pr_cdcooper  => pr_cdcooper,
                                                  pr_cdoperad  => pr_cdoperad,
                                                  pr_nrdconta  => pr_nrdconta,
                                                  pr_cdbcc     => 100,
                                                  pr_cdagenci  => 1,
                                                  pr_idorigem  => 3,
                                                  pr_nmtela    =>'IMGCHQON',
                                                  -- OUT
                                                  pr_idtipocns => vr_idtipocns,  --> 0 - Pacote, 1 - Pacote sem saldo, 2 - Sem serviço no Pacote                                                                                                    
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic) ;         
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
              RAISE vr_exc_erro;
            END IF;
            -- Se a consulta foi no pacote de serviços e tinha saldo
            IF vr_idtipocns = 0 THEN
               vr_tpconvic := 'P'; -- Pacote cobriu
               -- Popula a linha de detalhes
               gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                  '<Tarifacao>'||chr(13)||
                  '<CdTarifa>' ||vr_tarifa ||'</CdTarifa>' ||chr(13)||               
                  '<VlrTarifa>'||0         ||'</VlrTarifa>'||chr(13)||                              
                  '<MsgErro>'  ||vr_msgerro||'</MsgErro>'  ||chr(13)                           
                 );
                 
               -- gravar log da ação
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_dscritic => vr_msgerro
                                      ,pr_dsorigem => pr_dsorigem
                                      ,pr_dstransa => 'Desconta Consulta Pacote - Imagem Cheque'                                       
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                            ELSE 0 
                                                       END )
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_nmdatela => pr_nmtela
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
                  -- gravar item do log                                 
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => 'Sua Remessa');  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cooperativa'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdcooper);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Banco do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdbanchq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Agência do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_cdagechq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Conta do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_nrctachq);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Número do Cheque'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_nrcheque);  
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Data de Compensação'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'IP Conectado'
                                     ,pr_dsdadant => null
                                     ,pr_dsdadatu => pr_dsip);
                 
            ELSE
               vr_tpconvic := 'I'; -- Pacote sem saldo ou não está no pacote   
               -- Busca o valor da tarifa
               TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                            ,pr_cdbattar => null          --Codigo Tarifa
                                            ,pr_cdtarifa => vr_tarifa     --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário                                         
                                            ,pr_vllanmto => 0             --Valor Lancamento
                                            ,pr_cdprogra => 'IMGCHQ'      --Codigo Programa
                                            ,pr_cdhistor => vr_cdhistor   --Codigo Historico
                                            ,pr_cdhisest => vr_cdhisest   --Historico Estorno
                                            ,pr_vltarifa => vr_vltarifa   --Valor tarifa
                                            ,pr_dtdivulg => vr_dtdivulg   --Data Divulgacao
                                            ,pr_dtvigenc => vr_dtvigenc   --Data Vigencia
                                            ,pr_cdfvlcop => vr_cdfvlcop   --Codigo faixa valor cooperativa
                                            ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                            ,pr_dscritic => vr_dscritic   --Descricao Critica
                                            ,pr_tab_erro => vr_tab_erro); --Tabela de erros
   
               -- Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 -- Se possui erro no vetor
                 IF vr_tab_erro.Count > 0 THEN
                   vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                 ELSE
                   vr_cdcritic := 0;
                   vr_dscritic := 'Nao foi possivel carregar a tarifa.';
                 END IF;
                 -- Levantar Excecao
                 RAISE vr_exc_erro;
               END IF;
               -- Popula a linha de detalhes
               gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                  '<Tarifacao>'||chr(13)||
                  '<CdTarifa>' ||vr_tarifa  ||'</CdTarifa>' ||chr(13)||               
                  '<VlrTarifa>'||vr_vltarifa||'</VlrTarifa>'||chr(13)||                              
                  '<MsgErro>'  ||vr_msgerro ||'</MsgErro>'  ||chr(13)                           
                 );
               
               -- gravar log da ação
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dscritic => vr_msgerro
                                   ,pr_dsorigem => pr_dsorigem
                                   ,pr_dstransa => 'Efetiva Tarifa Consulta - Imagem Cheque'                                       
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                        ELSE 0 
                                                    END )
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nmdatela => pr_nmtela
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
               -- gravar item do log                                 
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => 'Sua Remessa');  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Cooperativa'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdcooper);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Banco do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdbanchq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Agência do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdagechq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Conta do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_nrctachq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Número do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_nrcheque);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Data de Compensação'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'IP Conectado'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_dsip);  
                 
            END IF;            
            --Faz update para cheque visualizado
            BEGIN
              UPDATE
                    crapfdc c
                 SET
                    c.indimgvis = 'S',
                    c.tpconvic  = vr_tpconvic,
                    c.dtconvic  = sysdate
               WHERE
                    c.rowid = c2.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao alterar a tabela CRAPFDC: ' || SQLERRM;             
            END;
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            
          -- Se encontrou o cheque e o mesmo já foi visualizado:
          ELSIF vr_achou_cheque = 'S' AND c2.indimgvis = 'S' THEN
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<Tarifacao>'||chr(13)||
               '<CdTarifa>'||vr_tarifa   ||'</CdTarifa>' ||chr(13)||              
               '<VlrTarifa>'||0          ||'</VlrTarifa>'||chr(13)||                               
               '<MsgErro>'  ||vr_msgerro ||'</MsgErro>'  ||chr(13)                           
              );
              
               -- gravar log da ação
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dscritic => vr_msgerro
                                   ,pr_dsorigem => pr_dsorigem
                                   ,pr_dstransa => 'Cheque visualizado - Nao cobrar tarifa'                                       
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                        ELSE 0 
                                                    END )
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nmdatela => pr_nmtela
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
               -- gravar item do log                                 
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Tipo'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => 'Sua Remessa');  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Cooperativa'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdcooper);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Banco do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdbanchq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Agência do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_cdagechq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Conta do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_nrctachq);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Número do Cheque'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_nrcheque);  
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Data de Compensação'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
               GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'IP Conectado'
                                        ,pr_dsdadant => null
                                        ,pr_dsdadatu => pr_dsip);  

            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            
          END IF;
        END IF;
      END LOOP;
      END IF;   
      
      -- Se não encontrou o cheque, e se já não gerou erro por estar bloqueado, retorna mensagem de erro
      IF vr_achou_cheque = 'N'and vr_msgerro is null THEN   
        vr_msgerro:= 'Dados do cheque não encontrado.';            
        -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
           '<Tarifacao>'||chr(13)||
           '<CdTarifa></CdTarifa>'  ||chr(13)||                                          
           '<VlrTarifa></VlrTarifa>'||chr(13)||                                                  
           '<MsgErro>'  ||vr_msgerro||'</MsgErro>'||chr(13)                           
          );
        -- Finaliza o nó
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</Tarifacao></ImagemCheque>',TRUE);            
        -- gravar log do erro
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_msgerro
                            ,pr_dsorigem => pr_dsorigem
                            ,pr_dstransa => 'Verifica Tarifa Erro - Imagem Cheque'                                        
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => (CASE WHEN vr_msgerro IS NULL THEN 1
                                                  ELSE 0 
                                             END )
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmtela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data de Compensação'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dtmvtolt);                                                                                                                                                                                                    
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
                            
      END IF;
      -- Converte o CLOB para o XML de retorno
      pr_xml := XMLType.createxml(vr_xml);
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_SITUACAO_IMAGEM_CHEQUE_COOP: ' || SQLERRM;
    END;
  END pc_efetiva_tarifacao_img_chq;
------------------------------------------------
  -- Grava LOG nos casos de geração de PDF da imagem
  PROCEDURE pc_grava_log_pdf_img_chq (pr_cdcooper IN crapchd.cdcooper%TYPE  --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número das conta                                      
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                     ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                     ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                     ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                     ,pr_nrcheque IN crapchd.nrctachq%TYPE  --> Número do cheque do cooperado
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2)	IS			 --> Desc. crítica
                                      		
  BEGIN
    /* .............................................................................
    Programa: pc_grava_log_pdf_img_chq
    Sistema : CERED
    Autor   : Márcio José de Carvalho
    Data    : Maio/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravação do log da geração do PDF da imagem do cheque no IB

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_msgerro  VARCHAR2(200);
      
      vr_urlorigem             VARCHAR2(300);
      vr_caminhofrentecheque   VARCHAR2(300);
      vr_caminhoversocheque    VARCHAR2(300);
      vr_indimgvis		         VARCHAR2(1);	
      vr_xml                   CLOB;             --> XML do retorno
      vr_texto_completo        VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB      
      vr_nrdrowid              ROWID; 
      
      vr_gravoulog VARCHAR2(1):='N';     
      vr_dstransa  VARCHAR2(1000);
      
          			
		BEGIN
      IF pr_cdcooper IS NULL THEN
         vr_cdcritic  := 1143;
         RAISE vr_exc_erro;
      ELSIF pr_nrcheque IS NULL THEN
         vr_cdcritic  := 1267;
         RAISE vr_exc_erro;  
      ELSIF pr_idseqttl IS NULL THEN
         vr_cdcritic  := 1268;
         RAISE vr_exc_erro; 
      ELSIF pr_dsorigem IS NULL THEN   
         vr_cdcritic  := 1269;
         RAISE vr_exc_erro; 
      ELSIF pr_nmtela IS NULL THEN   
         vr_cdcritic  := 1270;
         RAISE vr_exc_erro; 
      ELSIF pr_dsip IS NULL THEN   
         vr_cdcritic  := 1271;
         RAISE vr_exc_erro; 
      END IF;

      vr_dstransa:=  'Efetuado geração do PDF da Imagem do Cheque na conta on-line';
        
      -- gravar log
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996 -- Valor fixo
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => pr_dsorigem
                          ,pr_dstransa => vr_dstransa                                                                                     
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                ELSE 0 
                                           END )
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmtela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                            
      -- gravar item do log                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Numero do cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);
   
      COMMIT;    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_SITUACAO_IMAGEM_CHEQUE_COOP: ' || SQLERRM;
    END;
  END pc_grava_log_pdf_img_chq;

  PROCEDURE pc_consulta_detalhe_chq(pr_cdcooper IN crapfdc.cdcooper%TYPE  --> Cooperativa
                                   ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE  --> Código do Banco do cheque
                                   ,pr_cdagechq IN crapfdc.cdagechq%TYPE  --> Código da Agência do cheque
                                   ,pr_nrctachq IN crapfdc.nrctachq%TYPE  --> Número das conta                                      
                                   ,pr_nrcheque IN crapchd.nrcheque%TYPE  --> Número do cheque
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do titular
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador 
                                   ,pr_dsorigem IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                   ,pr_nmtela   IN craplgm.nmdatela%TYPE  --> Nome da tela
                                   ,pr_dsip     IN VARCHAR2               --> IP no qual o computador está conectado
                                   ,pr_cdorigem IN INTEGER                --> Código do Canal de Relacionamento – Valor '3' Internet ou '4' Caixa Eletrônico 
                                   ,pr_nrdcaixa IN INTEGER                --> Código de caixa do canal de atendimento – Valor fixo "900" para Internet e Caixa Eletrônico
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código de PA do canal de atendimento – Valor '90' para Internet ou '91' para Caixa Eletrônico
                                   ,pr_nmprogra IN VARCHAR2               --> Nome do programa – Valor "INTERNETBANK" Internet
                                   ,pr_xml      OUT xmltype               --> XML com os dados de retorno
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2)	IS			 --> Desc. crítica
                                      		
  BEGIN
    /* .............................................................................
    Programa: pc_consulta_imagem_chq
    Sistema : CERED
    Autor   : Márcio José de Carvalho
    Data    : Maio/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consulta do cheque, url da imagem do cheque e se necessario, chama tarifação

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

			-- Query para verificação do cheque -- Sua Remessa
			CURSOR cr_crapfdc IS
        SELECT
              c.incheque, -- Indicador do estado do cheque (0-Normal/ 1 e 2-Contra Ordem/ 5-Compensado/ 6 e 7-Compensado com ContraOrdem/ 8-Cancelado)              
              c.nrcheque||c.nrdigchq nrcheque_dig
         FROM        
              crapfdc c
        WHERE 
              c.cdcooper = pr_cdcooper
          AND c.cdbanchq = pr_cdbanchq
          AND c.cdagechq = pr_cdagechq
          AND c.nrdconta = pr_nrctachq
          AND c.nrcheque = pr_nrcheque;

		  -- Variavel de criticas
      vr_cdcritic       crapcri.cdcritic%TYPE;
      vr_dscritic       VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro       EXCEPTION;
      vr_msgerro        VARCHAR2(200);

      vr_xmllog         VARCHAR2(32600);      
      vr_xml            CLOB;             --> XML do retorno
      vr_retxml         xmltype;      
      
      vr_texto_completo VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB            
      vr_nmdcampo       VARCHAR2(100);
      vr_des_erro       VARCHAR2(1000);
      vr_nrdrowid       ROWID;            
      vr_achou_cheque   VARCHAR2(1):= 'N';
          
		BEGIN
      -- Inicializar as informações do XML de dados para o 
      dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      IF pr_cdcooper IS NULL THEN
         vr_cdcritic  := 1143;
         RAISE vr_exc_erro;
      ELSIF pr_nrctachq IS NULL THEN
         vr_cdcritic  := 1144;
         RAISE vr_exc_erro;  
      ELSIF pr_nrcheque IS NULL THEN
         vr_cdcritic  := 1267;
         RAISE vr_exc_erro;  
      ELSIF pr_idseqttl IS NULL THEN
         vr_cdcritic  := 1268;
         RAISE vr_exc_erro; 
      ELSIF pr_cdoperad IS NULL THEN         
         vr_cdcritic  := 87;
         RAISE vr_exc_erro; 
      ELSIF pr_dsorigem IS NULL THEN   
         vr_cdcritic  := 1269;
         RAISE vr_exc_erro; 
      ELSIF pr_nmtela IS NULL THEN   
         vr_cdcritic  := 1270;
         RAISE vr_exc_erro; 
      ELSIF pr_dsip IS NULL THEN   
         vr_cdcritic  := 1271;
         RAISE vr_exc_erro;                                                                                           
      END IF;
      
      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><InformacoesCheques>'||chr(13));

      -- Busca o incheque na tabela pois não 
      FOR C1 IN CR_CRAPFDC LOOP
        vr_achou_cheque:='S';
        -- Chama a rotina que retorna os dados do cheque
        cecred.cheq0001.pc_busca_cheque(pr_cdcooper => pr_cdcooper,
                                        pr_nrtipoop => 6,
                                        pr_nrdconta => pr_nrctachq,
                                        pr_nrcheque => pr_nrcheque,
                                        pr_nrregist => 1,
                                        pr_nriniseq => 0,
                                        pr_xmllog   => vr_xmllog,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic,
                                        pr_retxml   => vr_retxml,
                                        pr_nmdcampo => vr_nmdcampo,
                                        pr_des_erro => vr_des_erro);
      -- Verifica se ocorreram erros de execução
      IF vr_des_erro <> 'OK' THEN
        -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
           '<DetalheCheque>'       ||chr(13)||
           '<DataRetirada>'        ||' '||'</DataRetirada>'||chr(13)||
           '<Situacao>'            ||' '||'</Situacao>' ||chr(13)||
           '<DataCompensacao>'     ||' '||'</DataCompensacao>' ||chr(13)||
           '<NumeroCheque>'        ||' '||'</NumeroCheque>' ||chr(13)||
           '<BancoApresentacao>'   ||' '||'</BancoApresentacao>' ||chr(13)||
           '<AgenciaApresentacao>' ||' '||'</AgenciaApresentacao>' ||chr(13)||                                            
           '<ContaApresentacao>'   ||' '||'</ContaApresentacao>' ||chr(13)||           
           '<ValorCheque>'         ||' '||'</ValorCheque>' ||chr(13)||           
           '<ContraOrdem>'         ||' '||'</ContraOrdem>' ||chr(13)||           
           '<DataCancelamento>'    ||' '||'</DataCancelamento>' ||chr(13)||                                            
           '<MsgErro>'             ||vr_des_erro||chr(13)                           
          );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</DetalheCheque></InformacoesCheques>',TRUE); 
            
            -- gravar log da ação
            vr_dscritic:=vr_des_erro;        
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => '0'
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta detalhada do cheque'                                           
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                 ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrctachq
                                ,pr_nrdrowid => vr_nrdrowid);                  
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
      END IF; 

      IF gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'nrcheque') = c1.nrcheque_dig THEN
        -- Compensados 
        IF  c1.incheque = 5 AND
        gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtliqchq') is not null THEN
          -- Popula a linha de detalhes
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<DetalheCheque>'       ||chr(13)||
             '<DataRetirada>'        ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtretchq')||'</DataRetirada>'||chr(13)||
             '<Situacao>'            ||'Compensado'                                                                      ||'</Situacao>' ||chr(13)||
             '<DataCompensacao>'     ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtliqchq')||'</DataCompensacao>' ||chr(13)||
             '<NumeroCheque>'        ||pr_nrcheque                                                                       ||'</NumeroCheque>' ||chr(13)||
             '<BancoApresentacao>'   ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'cdbandep')||'</BancoApresentacao>' ||chr(13)||
             '<AgenciaApresentacao>' ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'cdagedep')||'</AgenciaApresentacao>' ||chr(13)||                                            
             '<ContaApresentacao>'   ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'nrctadep')||'</ContaApresentacao>' ||chr(13)||           
             '<ValorCheque>'         ||to_char(gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'vlcheque'),'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.')||'</ValorCheque>' ||chr(13)||           
             '<ContraOrdem>'         ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dscordem')||'</ContraOrdem>' ||chr(13)||           
             '<DataCancelamento>'    ||' '||'</DataCancelamento>' ||chr(13)||                                            
             '<MsgErro>'             ||''||'</MsgErro>'      ||chr(13)                           
            );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</DetalheCheque></InformacoesCheques>',TRUE); 
                     
            -- gravar log da ação
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => '0'
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta detalhada do cheque - Compensado'                              
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                 ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrctachq
                                ,pr_nrdrowid => vr_nrdrowid);        
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
          -- Cancelados 
          ELSIF c1.incheque = 8 THEN
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<DetalheCheque>'       ||chr(13)||
               '<DataRetirada>'        ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtretchq')||'</DataRetirada>'||chr(13)||
               '<Situacao>'            ||'Cancelado'                                                                      ||'</Situacao>' ||chr(13)||
               '<DataCompensacao>'     ||' '||'</DataCompensacao>' ||chr(13)||
               '<NumeroCheque>'        ||pr_nrcheque                                                                       ||'</NumeroCheque>' ||chr(13)||
               '<BancoApresentacao>'   ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'cdbandep')||'</BancoApresentacao>' ||chr(13)||
               '<AgenciaApresentacao>' ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'cdagedep')||'</AgenciaApresentacao>' ||chr(13)||                                            
               '<ContaApresentacao>'   ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'nrctadep')||'</ContaApresentacao>' ||chr(13)||           
               '<ValorCheque>'         ||to_char(gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'vlcheque'),'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.')||'</ValorCheque>' ||chr(13)||           
               '<ContraOrdem>'         ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dscordem')||'</ContraOrdem>' ||chr(13)||           
               '<DataCancelamento>'    ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtliqchq')||'</DataCancelamento>' ||chr(13)||                                            
               '<MsgErro>'             ||''||'</MsgErro>'      ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</DetalheCheque></InformacoesCheques>',TRUE); 
            -- gravar log da ação
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => '0'
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta detalhada do cheque - Cancelado'                               
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                 ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrctachq
                                ,pr_nrdrowid => vr_nrdrowid);         
            -- gravar item do log                                 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
          --Nao Compensados 
          ELSIF c1.incheque <> 8 AND
            gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtliqchq') is null AND      
            gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtretchq') is not null THEN          
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<DetalheCheque>'       ||chr(13)||
               '<DataRetirada>'        ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtretchq')||'</DataRetirada>'||chr(13)||
               '<Situacao>'            ||'Não Compensado'                                                                      ||'</Situacao>' ||chr(13)||
               '<DataCompensacao>'     ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dtliqchq')||'</DataCompensacao>' ||chr(13)||
               '<NumeroCheque>'        ||pr_nrcheque                                                                       ||'</NumeroCheque>' ||chr(13)||
               '<BancoApresentacao>'   ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'cdbandep')||'</BancoApresentacao>' ||chr(13)||
               '<AgenciaApresentacao>' ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'cdagedep')||'</AgenciaApresentacao>' ||chr(13)||                                            
               '<ContaApresentacao>'   ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'nrctadep')||'</ContaApresentacao>' ||chr(13)||           
               '<ValorCheque>'         ||to_char(gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'vlcheque'),'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.')||'</ValorCheque>' ||chr(13)||           
               '<ContraOrdem>'         ||gene0007.fn_valor_tag(pr_xml => vr_retxml,pr_pos_exc => 0,pr_nomtag => 'dscordem')||'</ContraOrdem>' ||chr(13)||           
               '<DataCancelamento>'    ||' '||'</DataCancelamento>' ||chr(13)||                                            
               '<MsgErro>'             ||''||'</MsgErro>'      ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</DetalheCheque></InformacoesCheques>',TRUE); 
            -- gravar log da ação
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => '0'
                                ,pr_dscritic => vr_msgerro
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta detalhada do cheque - Não Compensado'                          
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                 ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrctachq
                                ,pr_nrdrowid => vr_nrdrowid);                 
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
          ELSE
            -- Popula a linha de detalhes
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<DetalheCheque>'       ||chr(13)||
               '<DataRetirada>'        ||' '||'</DataRetirada>'||chr(13)||
               '<Situacao>'            ||' '||'</Situacao>' ||chr(13)||
               '<DataCompensacao>'     ||' '||'</DataCompensacao>' ||chr(13)||
               '<NumeroCheque>'        ||' '||'</NumeroCheque>' ||chr(13)||
               '<BancoApresentacao>'   ||' '||'</BancoApresentacao>' ||chr(13)||
               '<AgenciaApresentacao>' ||' '||'</AgenciaApresentacao>' ||chr(13)||                                            
               '<ContaApresentacao>'   ||' '||'</ContaApresentacao>' ||chr(13)||           
               '<ValorCheque>'         ||' '||'</ValorCheque>' ||chr(13)||           
               '<ContraOrdem>'         ||' '||'</ContraOrdem>' ||chr(13)||           
               '<DataCancelamento>'    ||' '||'</DataCancelamento>' ||chr(13)||                                            
               '<MsgErro>'             ||'Situação do cheque não identificada'||'</MsgErro>'      ||chr(13)                           
              );
            -- Finaliza o nó
            gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</DetalheCheque></InformacoesCheques>',TRUE); 
            -- gravar log da ação
            vr_dscritic:='Situação do cheque não tratada. Situação: '||c1.incheque;        
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => '0'
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'Consulta detalhada do cheque'                                           
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                 ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmtela
                                ,pr_nrdconta => pr_nrctachq
                                ,pr_nrdrowid => vr_nrdrowid);    
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
          END IF;
        END IF;                       
      END LOOP;
      IF vr_achou_cheque = 'N' THEN
        -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
           '<DetalheCheque>'       ||chr(13)||
           '<DataRetirada>'        ||' '||'</DataRetirada>'||chr(13)||
           '<Situacao>'            ||' '||'</Situacao>' ||chr(13)||
           '<DataCompensacao>'     ||' '||'</DataCompensacao>' ||chr(13)||
           '<NumeroCheque>'        ||' '||'</NumeroCheque>' ||chr(13)||
           '<BancoApresentacao>'   ||' '||'</BancoApresentacao>' ||chr(13)||
           '<AgenciaApresentacao>' ||' '||'</AgenciaApresentacao>' ||chr(13)||                                            
           '<ContaApresentacao>'   ||' '||'</ContaApresentacao>' ||chr(13)||           
           '<ValorCheque>'         ||' '||'</ValorCheque>' ||chr(13)||           
           '<ContraOrdem>'         ||' '||'</ContraOrdem>' ||chr(13)||           
           '<DataCancelamento>'    ||' '||'</DataCancelamento>' ||chr(13)||                                            
           '<MsgErro>'             ||'Número do cheque não emitido para esta conta'||'</MsgErro>'      ||chr(13)                           
          );
        -- Finaliza o nó
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</DetalheCheque></InformacoesCheques>',TRUE); 
        -- gravar log da ação
        vr_dscritic:='Número do cheque não emitido para esta conta';
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => '0'
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => pr_dsorigem
                            ,pr_dstransa => 'Consulta detalhada do cheque.'                                       
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                             ELSE 0 
                                             END )
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmtela
                            ,pr_nrdconta => pr_nrctachq
                            ,pr_nrdrowid => vr_nrdrowid);      
            -- gravar item do log 
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cooperativa'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdcooper);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Banco do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdbanchq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Agência do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_cdagechq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrctachq);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Número do Cheque'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_nrcheque);  
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'IP Conectado'
                               ,pr_dsdadant => null
                               ,pr_dsdadatu => pr_dsip);                                
      END IF;
      -- Converte o CLOB para o XML de retorno
      pr_xml := XMLType.createxml(vr_xml);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina pc_consulta_detalhe_chq: ' || SQLERRM;
    END;
  END pc_consulta_detalhe_chq;

/* Procedure que realiza a tarifação da visualização da imagem do cheque */
PROCEDURE pc_realiza_tarifa_imagem_chq(pr_cdcooper  IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                       pr_cdoperad  IN  crapope.cdoperad%TYPE, --> Código do operador 
                                       pr_nrdconta  IN  crapass.nrdconta%TYPE, --> Número da conta
                                       pr_cdbcc     IN  crapchd.cdbanchq%TYPE, -- Código do banco
                                       pr_cdagenci  IN  crapchd.cdagechq%TYPE, --> Agência
                                       pr_idorigem  IN  INTEGER,               --> Internet ou Ayllos
                                       pr_nmtela    IN  craplgm.nmdatela%TYPE, --> Nome da tela
                                       pr_idtipocns OUT INTEGER,               --> 0 - Pacote, 1 - Pacote sem saldo, 2 - Sem serviço no Pacote
                                       pr_cdcritic  OUT PLS_INTEGER,           --> Cód. crítica
                                       pr_dscritic  OUT VARCHAR2) IS           --> Desc. crítica
   -- Variaveis de erro
   vr_cdcritic       PLS_INTEGER; --> codigo retorno de erro
   vr_dscritic       VARCHAR2(4000); --> descricao do erro
   vr_exc_saida      EXCEPTION; --> Excecao prevista
    
   -- Tratamento de erros
   vr_exc_erro       EXCEPTION;

    --Variáveis locais
   vr_flpacote NUMBER := 0; --> Flag de Pacote
   vr_flservic NUMBER := 0; --> Flag de Sevico
   vr_qtopdisp NUMBER := 0; --> Quantidade de Operacoes Disponiveis   

   vr_qtacobra       INTEGER;
   vr_fliseope       INTEGER;  
   --Tipo de Dados para cursor data
   rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
   vr_des_erro       VARCHAR2(2000);
BEGIN
   BEGIN
      --Selecionar data
      OPEN BTCH0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
      --Posicionar primeiro registro
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      --Se encontrou
      IF BTCH0001.cr_crapdat%FOUND THEN
         NULL; -- Continua fluxo
      ELSE
         -- Efetuar busca da data
         vr_cdcritic := 0;
         vr_dscritic := 'Erro cheq0002.pc_realiza_tarifacao_imagem_chq: crapdat - '||SQLERRM;
         --Fechar Cursor
         CLOSE BTCH0001.cr_crapdat;
         -- Retorna as informacoes
         RAISE vr_exc_saida;			  
      END IF;
      --Fechar Cursor
      CLOSE BTCH0001.cr_crapdat;
   EXCEPTION
        WHEN OTHERS THEN
             -- Efetuar busca da data
             vr_cdcritic := 0;
             vr_dscritic := 'Erro cheq0002.pc_realiza_tarifacao_imagem_chq: tari0001(tarifa) - '||SQLERRM;
             -- Retorna as informacoes
             RAISE vr_exc_saida;			  
   END;
   -- Verificar se a conta do cooperado possui pacote de tarifa
   BEGIN
      --vertificar se no pacote existe o tipo de serviço - Imagem de Cheque 
      TARI0001.pc_verifica_pacote_tarifas(pr_cdcooper => pr_cdcooper,   --> Código da Cooperativa
                                          pr_nrdconta => pr_nrdconta,   --> Numero da Conta
                                          pr_idorigem => 3,             --> Origem
                                          pr_tpservic => 23,           --> Tipo de Servico
                                          pr_flpacote => vr_flpacote,   --> Flag de Pacote
                                          pr_flservic => vr_flservic,   --> Flag de Sevico
                                          pr_qtopdisp => vr_qtopdisp,   --> Quantidade de Operacoes Disponiveis
                                          pr_cdcritic => vr_cdcritic,   --> Código da crítica
                                          pr_dscritic => vr_dscritic); --> Descrição da crítica
   EXCEPTION
       WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro cheq0002.pc_realiza_tarifa_imagem_chq: tari0001 '||SQLERRM;
            RAISE vr_exc_saida;
   END;
   IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
   END IF;
   -- Encontrou pacote
   IF vr_flpacote = 1 THEN  
      -- Serviço ativo e consumiu o último
      IF vr_flservic        = 1 AND 
         nvl(vr_qtopdisp,0) > 0 THEN
         pr_idtipocns := 0; -- Sem tarifação, coberto pelo pacote do associado
      ELSE
         pr_idtipocns := 1; -- Com tarifação, estourou o serviço 
      END IF;
   ELSE
      pr_idtipocns := 2; -- Com tarifação, não possui o serviço
   END IF;
   BEGIN
      -- Verificar se deve ser isento de tarifa ou não
      tari0001.pc_verifica_tarifa_operacao(pr_cdcooper => pr_cdcooper,         -- Cooperativa
                                           pr_cdoperad => pr_cdoperad,         -- Operador  = '1'
                                           pr_cdagenci => pr_cdagenci,         -- PA = 1
                                           pr_cdbccxlt => pr_cdbcc,            -- Cód. Banco = 100
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt, -- Data de movimento
                                           pr_cdprogra => pr_nmtela,           -- Cód. programa
                                           pr_idorigem => pr_idorigem,         -- Identificador de origem
                                           pr_nrdconta => pr_nrdconta,         -- Nr. da conta
                                           pr_tipotari => 23,                  -- Tipo de tarifa 
                                           pr_tipostaa => 0,                   -- Tipo TAA
                                           pr_qtoperac => 0,                   -- Qtd. de operações
                                           pr_qtacobra => vr_qtacobra,         -- Qtd. de operações cobradas
                                           pr_fliseope => vr_fliseope,         -- Flag de isenção de operações 0 - não isenta/ 1 - isenta
                                           pr_cdcritic => vr_cdcritic,         -- Cód. da crítica
                                           pr_dscritic => vr_dscritic);        -- Desc. da crítica
   EXCEPTION
        WHEN OTHERS THEN
             -- Efetuar retorno do erro não tratado
             vr_cdcritic := 0;
             vr_dscritic := 'Erro cheq0002.pc_realiza_tarifacao_imagem_chq: tari0001(tarifa) - '||SQLERRM;
             -- Retorna as informacoes
             RAISE vr_exc_saida;			  
   END;
   -- Se ocorreu erro
   IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- gera log do erro ocorrido
      vr_dscritic:= vr_dscritic ||' Conta: '||gene0002.fn_mask_conta(pr_nrdconta)||' - '||'Tarifa 23'/*vr_cdbattar*/;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     =>  pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato,
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| 'IMGCHQON' || ' --> '|| vr_dscritic,
                                 pr_nmarqlog     => 'proc_message.log');
      RAISE vr_exc_saida;			  
   END IF;																								
   -- dbms_output.put_line('vr_fliseope: '||vr_fliseope);
   -- dbms_output.put_line('vr_qtacobra: '||vr_qtacobra);   
   IF vr_fliseope = 0 THEN -- Cobra tarifa
      BEGIN
         cheq0002.pc_cobra_tarifa_imgchq_online(pr_cdcooper  => pr_cdcooper,
                                                pr_cdagechq  => pr_cdagenci,
                                                pr_nrctachq  => pr_nrdconta,
                                                --pr_xmllog    => ,             --> XML com informac?es de LOG
                                                pr_cdcritic  => vr_cdcritic,        --> Codigo da critica
                                                pr_dscritic  => vr_dscritic,           --> Descricao da critica
                                                --pr_retxml    =>  , --> Arquivo de retorno do XML
                                                --pr_nmdcampo  => NULL,             --> Nome do campo com erro
                                                pr_des_erro  => vr_des_erro);
      EXCEPTION
	       WHEN OTHERS THEN
                -- Efetuar retorno do erro não tratado
                vr_cdcritic := 0;
                vr_dscritic := 'Erro cheq0002.pc_realiza_tarifacao_imagem_chq: tari0001(tarifa) - '||SQLERRM;
                -- Retorna as informacoes
                RAISE vr_exc_saida;	
      END;	  
   END IF;  
   -- Se ocorreu erro
   IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- gera log do erro ocorrido
      vr_dscritic:= vr_dscritic ||' Conta: '||gene0002.fn_mask_conta(pr_nrdconta)||' - '||'Tarifa 23'/*vr_cdbattar*/;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     =>  pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato,
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| 'IMGCHQON' || ' --> '|| vr_dscritic,
                                 pr_nmarqlog     => 'proc_message.log');
      RAISE vr_exc_saida;			  
   END IF;
   -- se tinha o serviço antes da tarifação chama rotina de notificação
   IF pr_idtipocns = 0 THEN
      cheq0002.pc_valida_ultima_img_chq(pr_cdcooper => pr_cdcooper, --> Cooperativa
                                        pr_nrdconta => pr_nrdconta, --> Número das conta
                                        pr_idseqttl => 1,           --> Sequência titular do cooperado -- AJUSTAR SEQ TITULAR
                                        pr_cdcritic => vr_cdcritic, --> Crítica encontrada
                                        pr_dscritic => vr_dscritic);
   END IF;
   IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- gera log do erro ocorrido
      vr_dscritic:= vr_dscritic ||' Conta: '||gene0002.fn_mask_conta(pr_nrdconta)||' - '||'Tarifa 23'/*vr_cdbattar*/;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     =>  pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato,
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| 'IMGCHQON' || ' --> '|| vr_dscritic,
                                 pr_nmarqlog     => 'proc_message.log');
      RAISE vr_exc_saida;			  
   END IF;
   COMMIT;
EXCEPTION
     WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descrição
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
          END IF;
          -- Retorna as informacoes
          ROLLBACK;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := 'Erro cheq0002.pc_realiza_tarifacao_imagem_chq: Erro geral - '||SQLERRM;
          -- Retorna as informacoes
          ROLLBACK;
END pc_realiza_tarifa_imagem_chq;


/* Rotina para bloquear / desbloquear a imagem do cheque a partir da tela IMGCHQ */
PROCEDURE pc_bloqueia_imagem_chq(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                                 pr_dtmvtolt IN VARCHAR2, --> Data de compenssção
                                 --pr_cdcmpchq IN crapchd.cdcmpchq%TYPE, --> Código de compensação
                                 pr_cdbanchq IN crapchd.cdbanchq%TYPE, --> Código do Banco do Cheque
                                 pr_cdagechq IN crapchd.cdagechq%TYPE, --> Código da Agência do cheque
                                 pr_nrctachq IN crapchd.nrctachq%TYPE, --> Número da conta do cheque 
                                 pr_nrcheque IN crapchd.nrcheque%TYPE, --> Número do cheque
                                 pr_tpremess IN VARCHAR2,              --> Tipo de remessa (S - Sua Remessa, N - Nossa Remessa)
                                 pr_flgblqim IN VARCHAR2,              --> Situação do bloqueio (N-Desbloqueio/S-Bloqueio)
                                 pr_xmllog   IN VARCHAR2 DEFAULT NULL, --XML com informações de LOG
                                 pr_cdcritic OUT PLS_INTEGER,          --> Cód. crítica
                                 pr_dscritic OUT VARCHAR2,             --> Desc. crítica
                                 pr_retxml   IN OUT NOCOPY XMLType,    --Arquivo de retorno do XML
                                 pr_nmdcampo OUT VARCHAR2,             --Nome do Campo
                                 pr_des_erro OUT VARCHAR2) IS         -- --Saida OK/NOK
                                 
   CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
    SELECT crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;                                 
                                 
   -- Variaveis de erro
   vr_cdcritic       PLS_INTEGER; --> codigo retorno de erro
   vr_dscritic       VARCHAR2(4000); --> descricao do erro
   vr_exc_saida      EXCEPTION; --> Excecao prevista
    
   -- Variaveis de log
   vr_cdcooper crapcop.cdcooper%TYPE;
   vr_cdoperad VARCHAR2(100);
   vr_nmdatela VARCHAR2(100);
   vr_nmeacao  VARCHAR2(100);
   vr_cdagenci VARCHAR2(100);
   vr_nrdcaixa VARCHAR2(100);
   vr_idorigem VARCHAR2(100);
   vr_dt_compen DATE;
    -- VARIÁVEIS
    vr_xml            CLOB;             --> XML do retorno
    vr_texto_completo VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB
   
BEGIN   
   pr_des_erro := 'OK';
   --Inicializar Variaveis
   vr_cdcritic:= 0;                         
   vr_dscritic:= NULL;
   
   OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);    
    FETCH cr_crapcop INTO rw_crapcop;    
    IF cr_crapcop%NOTFOUND THEN      
      CLOSE cr_crapcop;      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa não encontrada.';
      RAISE vr_exc_saida;    
    END IF;    
    
   -- Inicializar as informações do XML de dados para o 
   dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
   dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
   -- Inicializa o XML
   gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><InformacoesCheque>'||chr(13));
   
   -- Recupera dados de log para consulta posterior
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
   -- Verifica se houve erro recuperando informacoes de log                              
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_saida;
   END IF;
   vr_dt_compen := to_date(pr_dtmvtolt, 'DD/MM/YYYY');
   IF pr_tpremess = 'S' THEN
      BEGIN
         -- Atualiza o cheque bloqueado "Sua Remessa"
         UPDATE crapfdc c
            SET c.indblqvic = pr_flgblqim
          WHERE c.cdbanchq  = pr_cdbanchq
            AND c.cdagechq  = pr_cdagechq
            AND c.nrctachq  = pr_nrctachq
            AND c.nrcheque  = pr_nrcheque;
      EXCEPTION
           WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro CHEQ0002.pc_bloqueia_imagem_chq: crapfdc - '||SQLERRM;
                RAISE vr_exc_saida;			  
      END;
      -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemcheque>'||chr(13)||
             '<mensagem>'||'Sua Remessa Atualizada '||'</mensagem>'||chr(13));
   ELSE
      BEGIN
         -- Atualiza o cheque bloqueado "Nossa Remessa"
         UPDATE crapchd c
            SET c.indblqvic = pr_flgblqim
          WHERE c.cdcooper = pr_cdcooper
            AND c.dtmvtolt = vr_dt_compen
            --AND c.cdcmpchq = pr_cdcmpchq
            AND c.cdbanchq = pr_cdbanchq
            AND c.cdagechq = pr_cdagechq
            AND c.nrctachq = pr_nrctachq
            AND c.nrcheque = pr_nrcheque;
      EXCEPTION
           WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro CHEQ0002.pc_bloqueia_imagem_chq: crapchd - '||SQLERRM;
                RAISE vr_exc_saida;			  
      END;
      -- Popula a linha de detalhes
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<mensagemcheque>'||chr(13)||
             '<mensagem>'||'Nossa Remessa Atualizada '||'</mensagem>'||chr(13));
   END IF;
   -- Finaliza o nó
   gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'</mensagemcheque></InformacoesCheque>',TRUE);
   
   -- Criar cabeçalho do XML
   pr_retxml := XMLType.createxml(vr_xml);    
   COMMIT;
EXCEPTION
     WHEN vr_exc_saida THEN
          pr_des_erro:= 'NOK';
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descrição
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Retorna as informacoes
          ROLLBACK;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
          -- Existe para satisfazer exigência da interface. 
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
     WHEN OTHERS THEN
          pr_des_erro:= 'NOK';
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := 'Erro CHEQ0002.pc_bloqueia_imagem_chq: Erro geral - '||SQLERRM;
          -- Retorna as informacoes
          ROLLBACK;
          -- Existe para satisfazer exigência da interface. 
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
END pc_bloqueia_imagem_chq;
/* Efetua cobrança de tarifa */
PROCEDURE pc_cobra_tarifa_imgchq_online(pr_cdcooper  IN NUMBER,
                                        pr_cdagechq  IN NUMBER,
                                        pr_nrctachq  IN NUMBER,
                                        pr_cdcritic OUT PLS_INTEGER,          --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2,             --> Descricao da critica
                                        pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

   ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
   CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrctachq IN crapass.nrdconta%TYPE) IS
   SELECT inpessoa
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrdconta = pr_nrctachq;
   
   rw_crapass cr_crapass%ROWTYPE;
    
   -- Cursor genérico de calendário
   rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
   ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

   vr_chegoaki VARCHAR2(100);
   
   -- Tratamento de erros
   vr_exc_saida  EXCEPTION;
   vr_exc_fimprg EXCEPTION;
   vr_cdcritic   PLS_INTEGER;
   vr_dscritic   VARCHAR2(4000);
   vr_hasfound BOOLEAN;
    
   vr_cdhistor      INTEGER;
   vr_cdhisest      NUMBER;
   vr_vltarifa      NUMBER;
   vr_dtdivulg      DATE;
   vr_dtvigenc      DATE;
   vr_cdfvlcop      INTEGER;
   vr_tab_erro      GENE0001.typ_tab_erro;
   vr_rowid_craplat ROWID;
   vr_cdbattar      VARCHAR2(10);
   
BEGIN         
   pr_des_erro := 'OK';
   -- Leitura do calendário da cooperativa
   OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
   -- Se não encontrar
   IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
   ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
   END IF;
    
   OPEN cr_crapass(pr_cdcooper, pr_nrctachq);
   FETCH cr_crapass INTO rw_crapass;
   vr_hasfound := cr_crapass%FOUND;
   CLOSE cr_crapass;
   IF vr_hasfound THEN
      IF rw_crapass.inpessoa = 1 THEN
         vr_cdbattar := 'IMGCHQOPF';
      ELSE
         vr_cdbattar := 'IMGCHQOPJ';
      END IF;
   ELSE
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      RAISE vr_exc_saida;
   END IF;
    
   cecred.tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper,   --Codigo Cooperativa
                                                pr_cdbattar => vr_cdbattar,   --Codigo Tarifa
                                                pr_vllanmto => 0,             --Valor Lancamento
                                                pr_cdprogra => 'IMGCHQON',    --Codigo Programa
                                                pr_cdhistor => vr_cdhistor,   --Codigo Historico
                                                pr_cdhisest => vr_cdhisest,   --Historico Estorno
                                                pr_vltarifa => vr_vltarifa,   --Valor tarifa
                                                pr_dtdivulg => vr_dtdivulg,   --Data Divulgacao
                                                pr_dtvigenc => vr_dtvigenc,   --Data Vigencia
                                                pr_cdfvlcop => vr_cdfvlcop,   --Codigo faixa valor cooperativa
                                                pr_cdcritic => vr_cdcritic,   --Codigo Critica
                                                pr_dscritic => vr_dscritic,   --Descricao Critica
                                                pr_tab_erro => vr_tab_erro);  --Tabela de erros
    
   -- Se ocorreu erro
   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
         vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
         vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
         vr_cdcritic := 0;
         vr_dscritic := 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Levantar Excecao
      RAISE vr_exc_saida;
   END IF;
    
   cecred.tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrctachq,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_cdhistor => vr_cdhistor,
                                           pr_vllanaut => vr_vltarifa,
                                           pr_cdoperad => 1,
                                           pr_cdagenci => 1,
                                           pr_cdbccxlt => 100,
                                           pr_nrdolote => 10136,
                                           pr_tpdolote => 0,
                                           pr_nrdocmto => 0,
                                           pr_nrdctabb => pr_cdcooper,
                                           pr_nrdctitg => 0,
                                           pr_cdpesqbb => '',
                                           pr_cdbanchq => 85,
                                           pr_cdagechq => pr_cdagechq,
                                           pr_nrctachq => pr_cdcooper,
                                           pr_flgaviso => FALSE,
                                           pr_tpdaviso => 0,
                                           pr_cdfvlcop => vr_cdfvlcop,
                                           pr_inproces => rw_crapdat.inproces,
                                           pr_rowid_craplat => vr_rowid_craplat,
                                           pr_tab_erro => vr_tab_erro,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
   -- Se ocorreu erro
   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
         vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
         vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
         vr_cdcritic := 0;
         vr_dscritic := 'Nao foi possivel lancar a tarifa.';
      END IF;
      -- Levantar Excecao
      RAISE vr_exc_saida;
   END IF;
    
   -- Salvar informações atualizadas
   COMMIT;
EXCEPTION
     WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          pr_des_erro := 'NOK';
          ROLLBACK;        
     WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro Geral no Lancamento de Tarifa: ' || SQLERRM || ' ' || vr_chegoaki;
          pr_des_erro := 'NOK';
          ROLLBACK;  
END pc_cobra_tarifa_imgchq_online;
/* Envia mensagem para central de notificação quando encerra a quantidade do pacote */
PROCEDURE pc_valida_ultima_img_chq(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                                   pr_nrdconta IN crapass.nrdconta%TYPE, --> Número das conta
                                   pr_idseqttl IN crapsnh.idseqttl%TYPE, --> Sequência titular do cooperado
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Crítica encontrada
                                   pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/crítica encontrada
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    --Variáveis locais
    vr_flpacote NUMBER := 0; --> Flag de Pacote
    vr_flservic NUMBER := 0; --> Flag de Sevico
    vr_qtopdisp NUMBER := 0; --> Quantidade de Operacoes Disponiveis
BEGIN
   -- Verificar se a conta do cooperatdo possui pacote de tarifa
   BEGIN
      --vertificar se no pacote existe o tipo de serviço - Imagem de Cheque 
      TARI0001.pc_verifica_pacote_tarifas(pr_cdcooper => pr_cdcooper,   --> Código da Cooperativa
                                          pr_nrdconta => pr_nrdconta,   --> Numero da Conta
                                          pr_idorigem => 3,             --> Origem
                                          pr_tpservic => 23,           --> Tipo de Servico
                                          pr_flpacote => vr_flpacote,   --> Flag de Pacote
                                          pr_flservic => vr_flservic,   --> Flag de Sevico
                                          pr_qtopdisp => vr_qtopdisp,   --> Quantidade de Operacoes Disponiveis
                                          pr_cdcritic => vr_cdcritic,   --> Código da crítica
                                          pr_dscritic => vr_dscritic); --> Descrição da crítica
   EXCEPTION
       WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro cheq0002.pc_valida_ultima_img_chq: tari0001 '||SQLERRM;
            RAISE vr_exc_saida;
   END;
   IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
   END IF;
   -- Encontrou pacote
   IF vr_flpacote = 1 THEN  
      -- Serviço ativo e consumiu o último
      IF vr_flservic        = 1 AND 
         nvl(vr_qtopdisp,0) = 0 THEN
         BEGIN
            -- Gera notificação
            cecred.noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => 1,  -- CONFIRMAR
                                                pr_cdmotivo_mensagem => 12, -- CONFIRMAR MOTIVO 12 E MENSAGEM 205
                                                pr_dhenvio           => SYSDATE,
                                                pr_cdcooper          => pr_cdcooper,
                                                pr_nrdconta          => pr_nrdconta,
                                                pr_idseqttl          => pr_idseqttl);
         EXCEPTION
              WHEN OTHERS THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Erro cheq0002.pc_valida_ultima_img_chq: noti0001 '||SQLERRM;
                   RAISE vr_exc_saida;
         END;             
         -- Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
         END IF;
      END IF;
   END IF;
   COMMIT;
EXCEPTION
     WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descrição
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Retorna as informacoes
          ROLLBACK;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := 'Erro cheq0002.pc_valida_ultima_img_chq: '||SQLERRM;
          -- Retorna as informacoes
          ROLLBACK;
END pc_valida_ultima_img_chq;

/* Rotina para bloquear / desbloquear a imagem do cheque a partir da tela IMGCHQ */
PROCEDURE pc_consulta_cheque_imgchq(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                                    pr_dtmvtolt IN VARCHAR2, --> Data de compenssção
                                    pr_cdbanchq IN crapchd.cdbanchq%TYPE, --> Código do Banco do Cheque
                                    pr_cdagechq IN crapchd.cdagechq%TYPE, --> Código da Agência do cheque
                                    pr_nrctachq IN crapchd.nrctachq%TYPE, --> Número da conta do cheque 
                                    pr_nrcheque IN crapchd.nrcheque%TYPE, --> Número do cheque
                                    pr_tpremess IN VARCHAR2,              --> Tipo de remessa (S - Sua Remessa, N - Nossa Remessa)
                                    pr_xmllog   IN VARCHAR2 DEFAULT NULL, --XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER,          --> Cód. crítica
                                    pr_dscritic OUT VARCHAR2,             --> Desc. crítica
                                    pr_retxml   IN OUT NOCOPY XMLType,    --Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2,             --Nome do Campo
                                    pr_des_erro OUT VARCHAR2) IS         -- --Saida OK/NOK
                                 
   CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
    SELECT 
          cdagectl,
          nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
       
   -- Query para consulta do cheque -- Sua Remessa
   CURSOR cr_crapfdc IS
    SELECT
         replace(replace(replace(dsdocmc7,':',''),'<',''),'>','') dsdocmc7,
         cdcmpchq,
         cdtpdchq,
         indblqvic
     FROM        
          crapfdc c
    WHERE 
          c.cdcooper = pr_cdcooper
      AND c.cdbanchq = pr_cdbanchq             
      AND c.cdagechq = pr_cdagechq             
      AND c.nrctachq = pr_nrctachq
      AND c.nrcheque = pr_nrcheque;
    rw_crapfdc cr_crapfdc%ROWTYPE;

   -- Query para consulta do cheque -- Nossa Remessa
   CURSOR cr_crapchd IS
    SELECT
         replace(replace(replace(dsdocmc7,':',''),'<',''),'>','') dsdocmc7,
         indblqvic
     FROM        
          crapchd c
    WHERE 
          c.cdcooper = pr_cdcooper
      AND c.cdbanchq = pr_cdbanchq             
      AND c.cdagechq = pr_cdagechq             
      AND c.nrctachq = pr_nrctachq
      AND c.nrcheque = pr_nrcheque
      AND c.dtmvtolt = TO_DATE(pr_dtmvtolt,'DD/MM/YYYY');
    rw_crapchd cr_crapchd%ROWTYPE;                                 
                                 
   -- Variaveis de erro
   vr_cdcritic       PLS_INTEGER; --> codigo retorno de erro
   vr_dscritic       VARCHAR2(4000); --> descricao do erro
   vr_exc_saida      EXCEPTION; --> Excecao prevista
    
   -- Variaveis de log
   vr_cdcooper crapcop.cdcooper%TYPE;
   vr_cdoperad VARCHAR2(100);
   vr_nmdatela VARCHAR2(100);
   vr_nmeacao  VARCHAR2(100);
   vr_cdagenci VARCHAR2(100);
   vr_nrdcaixa VARCHAR2(100);
   vr_idorigem VARCHAR2(100);
   
BEGIN   
   pr_des_erro := 'OK';
   --Inicializar Variaveis
   vr_cdcritic:= 0;                         
   vr_dscritic:= NULL;
   
   OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);    
    FETCH cr_crapcop INTO rw_crapcop;    
    IF cr_crapcop%NOTFOUND THEN      
      CLOSE cr_crapcop;      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa não encontrada.';
      RAISE vr_exc_saida;    
    END IF;    
    
   
   -- Recupera dados de log para consulta posterior
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
   -- Verifica se houve erro recuperando informacoes de log                              
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_saida;
   END IF;
   
   -- Criar cabeçalho do XML
   pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
   gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                          pr_tag_pai  => 'Root',
                          pr_posicao  => 0,
                          pr_tag_nova => 'Dados',
                          pr_tag_cont => NULL,
                          pr_des_erro => vr_dscritic);
   
   IF pr_tpremess = 'S' THEN  
      OPEN cr_crapfdc;    
        FETCH cr_crapfdc INTO rw_crapfdc;    
        IF cr_crapfdc%FOUND THEN      
          CLOSE cr_crapfdc;
          
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'inf',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'nmrescop',
                                 pr_tag_cont => rw_crapcop.nmrescop,
                                 pr_des_erro => vr_dscritic);
                                 
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'dsdocmc7',
                                 pr_tag_cont => rw_crapfdc.dsdocmc7,
                                 pr_des_erro => vr_dscritic);
                                 
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'cdcmpchq',
                                 pr_tag_cont => rw_crapfdc.cdcmpchq,
                                 pr_des_erro => vr_dscritic);
                                 
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'cdtpdchq',
                                 pr_tag_cont => rw_crapfdc.cdtpdchq,
                                 pr_des_erro => vr_dscritic);
                                 
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'cdagechq',
                                 pr_tag_cont => rw_crapcop.cdagectl,
                                 pr_des_erro => vr_dscritic);                        
                                 
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'indblqvic',
                                 pr_tag_cont => rw_crapfdc.indblqvic,
                                 pr_des_erro => vr_dscritic);
         
        END IF;	
   ELSE
      OPEN cr_crapchd;    
        FETCH cr_crapchd INTO rw_crapchd;    
        IF cr_crapchd%FOUND THEN      
          CLOSE cr_crapchd;
          
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'inf',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'nmrescop',
                                 pr_tag_cont => rw_crapcop.nmrescop,
                                 pr_des_erro => vr_dscritic);
                                 
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'dsdocmc7',
                                 pr_tag_cont => rw_crapchd.dsdocmc7,
                                 pr_des_erro => vr_dscritic);
                                 
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'cdagechq',
                                 pr_tag_cont => rw_crapcop.cdagectl,
                                 pr_des_erro => vr_dscritic);                                
                                 
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'indblqvic',
                                 pr_tag_cont => rw_crapchd.indblqvic,
                                 pr_des_erro => vr_dscritic); 
                                               
        END IF;
   END IF;
    
EXCEPTION
     WHEN vr_exc_saida THEN
          pr_des_erro:= 'NOK';
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descrição
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Retorna as informacoes
          ROLLBACK;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
          -- Existe para satisfazer exigência da interface. 
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
     WHEN OTHERS THEN
          pr_des_erro:= 'NOK';
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := 'Erro CHEQ0002.pc_consulta_cheque_imgchq: Erro geral - '||SQLERRM;
          -- Retorna as informacoes
          ROLLBACK;
          -- Existe para satisfazer exigência da interface. 
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
END pc_consulta_cheque_imgchq;

END CHEQ0002;
/
