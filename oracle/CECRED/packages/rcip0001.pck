CREATE OR REPLACE PACKAGE CECRED.rcip0001 AS
  
/*..............................................................................

   Programa: rcpr0001                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente ao Serviço de Reciprocidade

   Alteracoes: 
  
..............................................................................*/
  
  /* Esta função tem o intuito de buscar o tipo do indicador e formata-lo de acordo.*/
  FUNCTION fn_format_valor_indicador(pr_idindicador IN tbrecip_indicador.idindicador%TYPE -- ID Indicador
                                    ,pr_vlaformatar IN NUMBER)                            -- Valor a formatar
                                                              RETURN VARCHAR2;
                                                              
  /* Esta função tem o intuito de buscar o tipo do indicador e formata-lo de acordo.*/
  FUNCTION fn_indicador_valido(pr_idindicador IN tbrecip_indicador.idindicador%TYPE) -- ID Indicador
                                                              RETURN VARCHAR2;  
                                                              
  /* Calcular o valor de desconto conforme previstoXrealizado. */
  FUNCTION fn_percentu_desconto_indicador(pr_idparame    IN tbrecip_parame_calculo.idparame_reciproci%TYPE     -- Id da parametrização envolvida
                                         ,pr_idcalculo   IN tbrecip_calculo.idcalculo_reciproci%TYPE DEFAULT 0 -- Id do calculo (se houver)
                                         ,pr_idindicador IN tbrecip_indicador.idindicador%TYPE                 -- ID Indicador
                                         ,pr_vlrbase     IN NUMBER)                                            -- Valor base
                                                              RETURN NUMBER;                                                                                                                          
  
  /* Calcular o valor realizado do indicador no período solicitado */
  FUNCTION fn_valor_realizado_indicador(pr_cdcooper    IN crapcop.cdcooper%TYPE              --> Cooperativa desejada
                                       ,pr_nrdconta    IN crapass.nrdconta%TYPE              --> Conta desejada
                                       ,pr_idindicador IN tbrecip_indicador.idindicador%TYPE --> ID Indicador
                                       ,pr_numocorre   IN NUMBER DEFAULT 0                   --> Número da ocorrencia desejada (de 0 a N)
                                       ,pr_datinicio   IN DATE DEFAULT NULL                  --> Data de início da busca (opcional se passada ocorrencia)
                                       ,pr_datfinal    IN DATE DEFAULT NULL)                 --> Data de termino da busca (opcional se passada ocorrencia)
                                                              RETURN NUMBER;
                                                              
  /* Calcular, acular e atualizar um indicador em apuração */
  PROCEDURE pc_calcula_recipro_atingida(pr_cdcooper           IN tbrecip_apuracao.cdcooper%TYPE             -- Cooperativa da apuração
                                       ,pr_nrdconta           IN tbrecip_apuracao.nrdconta%TYPE             -- Conta da apuracação
                                       ,pr_idapuracao         IN tbrecip_apuracao.idapuracao_reciproci%TYPE -- Id da apuracação envolvida
                                       ,pr_idindicador        IN tbrecip_indicador.idindicador%TYPE         -- ID Indicador
                                       ,pr_dtinicio_apuracao  IN tbrecip_apuracao.dtinicio_apuracao%TYPE    -- Data ini apuração
                                       ,pr_dttermino_apuracao IN tbrecip_apuracao.dttermino_apuracao%TYPE   -- Data fim apuracação  
                                       ,pr_idconfig_recipro   IN tbrecip_apuracao.idconfig_recipro%TYPE     -- Config da reciprocidade
                                       ,pr_tpreciproci        IN tbrecip_apuracao.tpreciproci%TYPE          -- Tipo da reciprocidade
                                       ,pr_tpindicador        IN tbrecip_indicador.tpindicador%TYPE         -- Tipo do Indicador
                                       ,pr_flgatingido       OUT VARCHAR2                                   -- Retorno S/N de atingimento 
                                       ,pr_descr_error       OUT VARCHAR2);                                -- Erro encontrado
  
  /* Procedimento para remoção de calculos/parametrizações não utilizadas pelo sistema */
  PROCEDURE pc_remove_recipro_sem_uso;
  
  /* Calcular os períodos de apuracação expirados e aplicar as regras de reversão e debito */
  PROCEDURE pc_expira_reciproci_prevista(pr_cdcritic OUT PLS_INTEGER
                                        ,pr_dscritic OUT VARCHAR2);
  
  -- Procedure encarregada de buscar os periodos de apuracao
  PROCEDURE pc_periodo_apuracao_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                  ,pr_data_xml OUT CLOB
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2);
  
  -- Procedure encarregada de buscar a apuracao
  PROCEDURE pc_apuracao_ib(pr_idapurac  IN tbrecip_apuracao.idapuracao_reciproci%TYPE
                          ,pr_data_xml OUT CLOB
                          ,pr_cdcritic OUT PLS_INTEGER
                          ,pr_dscritic OUT VARCHAR2);

  -- Procedure encarregada de buscar os indicadores
  PROCEDURE pc_indicadores_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE
                             ,pr_idapurac  IN tbrecip_apuracao.idapuracao_reciproci%TYPE
                             ,pr_data_xml OUT CLOB
                             ,pr_cdcritic OUT PLS_INTEGER
                             ,pr_dscritic OUT VARCHAR2);  
  
END rcip0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.rcip0001 AS

  /*..............................................................................

   Programa: rcpr0001                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente ao Serviço de Reciprocidade

  ..............................................................................*/

  /* Esta função tem o intuito de buscar o tipo do indicador e formata-lo de acordo.*/
  FUNCTION fn_format_valor_indicador(pr_idindicador IN tbrecip_indicador.idindicador%TYPE -- ID Indicador
                                    ,pr_vlaformatar IN NUMBER)                            -- Valor a formatar
                                                              RETURN VARCHAR2 IS 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_format_valor_indicador                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função tem o intuito de buscar o tipo do indicador e formata-lo de acordo com 
  --             o tipo do indicador.
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Buscar o tipo do indicador
    CURSOR cr_indica IS
      SELECT upper(tpindicador)
        FROM tbrecip_indicador
       WHERE idindicador = pr_idindicador;
    vr_tpindicador tbrecip_indicador.tpindicador%TYPE;   

  BEGIN
    -- Busca o tipo do indicador
    OPEN  cr_indica;
    FETCH cr_indica 
     INTO vr_tpindicador;
    CLOSE cr_indica;
    -- Para indicadores do tipo Moeda
    IF vr_tpindicador = 'M' THEN
      RETURN TO_CHAR(pr_vlaformatar,'fm999g999g999g990d00');
    -- Para indicadores de Quantidade
    ELSIF vr_tpindicador = 'Q' THEN
      RETURN TO_CHAR(pr_vlaformatar,'fm999g999g999g990');
    -- Para Adesão
    ELSE 
     IF pr_vlaformatar = 0 THEN
        RETURN 'Não';
      ELSE
        RETURN 'Sim';
      END IF;
    END IF;
    
  END fn_format_valor_indicador;
  
  /* Esta função validará se o indicador está mapeado ou não */
  FUNCTION fn_indicador_valido(pr_idindicador IN tbrecip_indicador.idindicador%TYPE) -- ID Indicador
                                                                                    RETURN VARCHAR2 IS 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_indicador_valido                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função irá simular a chamada da rotina de cálculo do valor realizado.
  --             A função do valor realizado sempre retornará -1 quando o indicador não estiver mapeado
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    -- Acionar a função para calculo realizado e se a mesma retornar -1,
    -- significa que o indicador não está devidamente mapeado ou está com erro no cálculo
    IF fn_valor_realizado_indicador(pr_cdcooper    => 0
                                   ,pr_nrdconta    => 0
                                   ,pr_idindicador => pr_idindicador
                                   ,pr_numocorre   => 0
                                   ,pr_datinicio   => SYSDATE
                                   ,pr_datfinal    => SYSDATE) = -1 THEN
      RETURN 'N';
    ELSE
      RETURN 'S';
    END IF;
  END fn_indicador_valido;  
  
  /* Calcular o valor de desconto conforme previstoXrealizado. */
  FUNCTION fn_percentu_desconto_indicador(pr_idparame    IN tbrecip_parame_calculo.idparame_reciproci%TYPE     -- Id da parametrização envolvida
                                         ,pr_idcalculo   IN tbrecip_calculo.idcalculo_reciproci%TYPE DEFAULT 0 -- Id do calculo (se houver)
                                         ,pr_idindicador IN tbrecip_indicador.idindicador%TYPE                 -- ID Indicador
                                         ,pr_vlrbase     IN NUMBER)                                            -- Valor base
                                                              RETURN NUMBER IS 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_percentu_desconto_indicador                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função será responsável por calcular o percentual de desconto do indicador
  --             repassado conforme valores previsto/realizado e parametrização do cálculo de
  --             reciprocidade vinculado ao convênio.

  ---------------------------------------------------------------------------------------------------------------

    -- Buscar a parametrização e os dados do indicador
    CURSOR cr_indica IS
      SELECT idr.tpindicador
        FROM tbrecip_indicador idr
       WHERE idr.idindicador  = pr_idindicador;
    vr_tpindicador tbrecip_indicador.tpindicador%TYPE;
    
    -- Buscar a parametrização e os dados do indicador
    CURSOR cr_parame IS
      SELECT ipr.vlminimo
            ,ipr.vlmaximo
            ,ipr.perscore
        FROM tbrecip_parame_indica_calculo ipr
       WHERE ipr.idparame_reciproci = pr_idparame
         AND ipr.idindicador        = pr_idindicador;
    rw_parame cr_parame%ROWTYPE;

    -- Buscar os dados do histórico do calculo (pois pode não mais haver parametrização)
    CURSOR cr_histor IS
      SELECT idc.vlminimo
            ,idc.vlmaximo
            ,idc.perscore
        FROM tbrecip_indica_calculo idc
       WHERE idc.idcalculo_reciproci = pr_idcalculo
         AND idc.idindicador         = pr_idindicador;
   
    -- calculo
    vr_calculo NUMBER;
		vr_faixavl NUMBER;
		vr_vlating NUMBER;
  
  BEGIN
    -- Buscar dados do indicador
    OPEN  cr_indica;
    FETCH cr_indica 
     INTO vr_tpindicador;
    CLOSE cr_indica;
    -- Buscar a parametrização e os dados do indicador
    OPEN  cr_parame;
    FETCH cr_parame 
     INTO rw_parame;
    -- Se não encontrar
    IF cr_parame%NOTFOUND THEN 
      CLOSE cr_parame;
      -- Buscaremos do histórico
      OPEN cr_histor;
      FETCH cr_histor 
       INTO rw_parame;  
      CLOSE cr_histor;
    ELSE
    CLOSE cr_parame;
    END IF;  
    -- Para indicadores do tipo Adesão
    IF vr_tpindicador = 'A' THEN
			-- Se realizou indicador recebe desconto
			IF pr_vlrbase > 0 THEN
      -- o valor do desconto é o próprio valor do Score cadastrado
      RETURN rw_parame.perscore;
    ELSE
				-- Senão valor do cálculo é zero
				RETURN 0;
			END IF;
    ELSE
      -- Se o valor previsto repassado for inferior ao valor mínimo,
      -- ou não encontrarmos nenhum registro na Query acima,   
      IF vr_tpindicador IS NULL 
      OR rw_parame.vlminimo > pr_vlrbase THEN
        -- Não precisaremos realizar o cálculo e assumiremos como valor de retorno = 0 (zero).
        RETURN 0;
      ELSE
				-- Capturamos a faixa de valor do parametro
				vr_faixavl := rw_parame.vlmaximo - rw_parame.vlminimo;
				-- Calculamos o valor atingido (Valor base - Valor mínimo do indicador)
				vr_vlating := pr_vlrbase - rw_parame.vlminimo;

				IF (vr_faixavl = 0) THEN
					-- Devemos garantir que o calculo não efetue divisão por 0
					vr_faixavl := 1;
					IF (vr_vlating = 0) THEN
						 -- Valor máximo, mínimo e base são iguais, devemos conceder o desconto máximo do score
					   vr_vlating := 1;
				  END IF;
				END IF;
        -- Aplicaremos a formula da reciprocidade
        vr_calculo := (vr_vlating / vr_faixavl)*rw_parame.perscore;
        -- Calculo não pode ser superior ao Score
        IF vr_calculo > rw_parame.perscore THEN
          -- Usaremos o score
          RETURN rw_parame.perscore;
        ELSE
          RETURN vr_calculo;
        END IF;
      END IF;
    END IF;
  END fn_percentu_desconto_indicador;  
  
  /* Calcular o valor realizado do indicador no período solicitado */
  FUNCTION fn_valor_realizado_indicador(pr_cdcooper    IN crapcop.cdcooper%TYPE              --> Cooperativa desejada
                                       ,pr_nrdconta    IN crapass.nrdconta%TYPE              --> Conta desejada
                                       ,pr_idindicador IN tbrecip_indicador.idindicador%TYPE --> ID Indicador
                                       ,pr_numocorre   IN NUMBER DEFAULT 0                   --> Número da ocorrencia desejada (de 0 a N)
                                       ,pr_datinicio   IN DATE DEFAULT NULL                  --> Data de início da busca (opcional se passada ocorrencia)
                                       ,pr_datfinal    IN DATE DEFAULT NULL)                 --> Data de termino da busca (opcional se passada ocorrencia)
                                                              RETURN NUMBER IS 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_valor_realizado_indicador                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: 08/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função receberá os dados do cooperado, e qual o indicador desejado, 
  --             além de qual ocorrência desejamos visualizar ou o prazo inicial e final que
  --             iremos consultar, para então retornar o valor realizado naquele período
  --
  -- Alteracoes: 23/12/2016 - Indicador 3 deve considerar a quantidade de liquidações
  --                          realizadas no período. (AJFink - SD#578135)
  --
  --             08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
  ---------------------------------------------------------------------------------------------------------------

    -- Variáveis genéricas
    vr_dat_ini DATE;
    vr_dat_fim DATE;
    -- Busca do calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -- Retornos genéricos
    vr_retorno    NUMBER;
    vr_retorno_02 NUMBER;
		
		-- Varáveis auxiliáres
		vr_inusatab   BOOLEAN;
		vr_dstextab   craptab.dstextab%TYPE;
		vr_dstextab_digitaliza craptab.dstextab%TYPE;
		vr_dstextab_parempctl craptab.dstextab%TYPE;
		vr_qtregist   INTEGER;
		-- PLTable retornada da procedure pc_obtem_dados_empresti
		vr_tab_dados_epr EMPR0001.typ_tab_dados_epr;
		vr_index_epr     VARCHAR2(100);
		
		-- Tratamento de exceções
		vr_des_erro VARCHAR(3);
		vr_tab_erro gene0001.typ_tab_erro;
		
    -- Quantidade de boletos emitidos no mês
    CURSOR cr_indica01 IS
      SELECT COUNT(1)
        FROM crapcob 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND DTMVTOLT BETWEEN vr_dat_ini 
                          AND vr_dat_fim;
       
    -- Valor de boletos compensados no mês
    CURSOR cr_indica02 IS
      SELECT SUM(vltitulo)
        FROM crapcob 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND DTDPAGTO BETWEEN vr_dat_ini 
                          AND vr_dat_fim
         AND INCOBRAN = 5;
       
    -- Quantidade de pagamentos
    CURSOR cr_indica03 IS
      SELECT COUNT(1)
        FROM crapcob 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND DTDPAGTO BETWEEN vr_dat_ini 
                          AND vr_dat_fim
         AND INCOBRAN = 5 
         AND cdbandoc IN(85,1); -- SR[Sua remessa] e NR[Nossa remessa]
       
    -- Saldo Médio Mensal:
    CURSOR cr_indica04 IS
      SELECT AVG(vlsddisp)
        FROM crapsda 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtmvtolt BETWEEN vr_dat_ini 
                          AND vr_dat_fim;
                              
    -- Desconto de Cheques
    CURSOR cr_indica06 IS
      SELECT SUM(cdb.vlcheque)
        FROM crapcdb cdb
       WHERE cdb.cdcooper = pr_cdcooper
         AND cdb.nrdconta = pr_nrdconta
         AND cdb.dtlibbdc BETWEEN vr_dat_ini 
                              AND vr_dat_fim
         AND cdb.insitchq > 0;															
				 
    -- Desconto de Títulos
    CURSOR cr_indica07 IS
      SELECT SUM(tdb.vltitulo)
			  FROM craptdb tdb
			 WHERE tdb.cdcooper = pr_cdcooper
			   AND tdb.nrdconta = pr_nrdconta
				 AND tdb.dtlibbdt BETWEEN vr_dat_ini 
                              AND vr_dat_fim
				 AND tdb.insittit > 0;
    
    -- Limite de Cheque Especial:
    CURSOR cr_indica08 IS
      SELECT SUM(lim.vllimite)
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.tpctrlim = 1 -- Cheque Especial
         AND lim.nrdconta = pr_nrdconta
         -- Ativo ou Cancelado após a reciprocidade
         AND ( lim.insitlim = 2 OR ( lim.insitlim = 3 AND lim.dtcancel > vr_dat_fim) )   
         AND  lim.dtinivig < vr_dat_fim;
    
    -- Plano de Cotas:
    CURSOR cr_indica09 IS
      SELECT SUM(vllanmto)
        FROM craplct lct
       WHERE lct.cdcooper = pr_cdcooper
         AND lct.nrdconta = pr_nrdconta
         AND lct.cdhistor = 75 -- PG. PLANO C/C              
         AND lct.dtmvtolt BETWEEN vr_dat_ini
                              AND vr_dat_fim;
                  
    -- Valor das Cotas:
    CURSOR cr_indica10 IS
      SELECT vlsdcota
        FROM crapsda
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtmvtolt = vr_dat_fim;
    
    -- Aplicação/RDC:
    CURSOR cr_indica11 IS
      SELECT vlsdrdca 
        FROM crapsda
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtmvtolt = vr_dat_fim;
    
    -- Poupança Programada:
    CURSOR cr_indica12 IS
      SELECT vlsdrdpp 
        FROM crapsda
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtmvtolt = vr_dat_fim;
       
 		-- Adesão de Folha de Pagamento
		CURSOR cr_indica13 IS
		  SELECT 1
				FROM crapemp emp						
			 WHERE emp.cdcooper = pr_cdcooper
			   AND emp.nrdconta = pr_nrdconta
			   AND emp.flgpgtib = 1;				 				
                 
    -- Débito automático:
    CURSOR cr_indica14 IS
      SELECT count(1)
        FROM crapatr atr
      WHERE atr.cdcooper = pr_cdcooper
        AND atr.nrdconta = pr_nrdconta
        -- Autorizado dentro da Reciprocidade
        AND atr.dtiniatr <= vr_dat_fim
        -- Não cancelado ou cancelado após a Reciprocidade
        AND (atr.dtfimatr IS NULL OR atr.dtfimatr > vr_dat_fim )
        -- Não suspenso
        AND (   atr.dtinisus IS NULL OR atr.dtfimsus IS NULL
             OR atr.dtfimsus <=  vr_dat_fim
            );
            
    -- Cartão de Crédito:
    CURSOR cr_indica15 IS
      SELECT 1
        FROM crawcrd  w 
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.dtentreg <= vr_dat_fim         
         AND ( -- Em uso
               w.insitcrd IN (3,4)  
              OR
               -- Cancelado dentro do período da reciprocidade
               (w.insitcrd IN (5,6) AND w.dtcancel >= vr_dat_ini)
             );
						 
		-- Plano Poup Prog.		 
		CURSOR cr_indica16 IS
		  SELECT sum(lcm.vllanmto)
				FROM craplcm lcm						
			 WHERE lcm.cdcooper = pr_cdcooper
			   AND lcm.nrdconta = pr_nrdconta
			   AND lcm.cdhistor = 160
				 AND lcm.dtmvtolt BETWEEN vr_dat_ini 
                              AND vr_dat_fim;
    
		  
		-- Adesão Crédito Salário
		CURSOR cr_indica17 IS
		  SELECT distinct(1)
				FROM craplcm lcm						
			 WHERE lcm.cdcooper = pr_cdcooper
			   AND lcm.nrdconta = pr_nrdconta
			   AND (lcm.cdhistor IN (SELECT cdhiscre FROM crapofp WHERE crapofp.cdcooper = pr_cdcooper)
				 OR   lcm.cdhistor IN (SELECT cdhscrcp FROM crapofp WHERE crapofp.cdcooper = pr_cdcooper)
				 OR   lcm.cdhistor = 799)
				 AND lcm.dtmvtolt BETWEEN vr_dat_ini 
                              AND vr_dat_fim;
															
	  -- Adesão de consórcio
		CURSOR cr_indica18 IS
		  SELECT distinct(1)
			  FROM crapcns cns
			 WHERE cns.cdcooper = pr_cdcooper
			   AND cns.nrdconta = pr_nrdconta
				 AND cns.flgativo = 1;

	  -- Idade da conta
		CURSOR cr_indica19 IS
		  SELECT TRUNC(months_between(TRUNC(SYSDATE), ass.dtadmiss) / 12)
			  FROM crapass ass 
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta;
				 
		-- Quantidade de seguros ativos na conta
		CURSOR cr_indica20 IS
		  SELECT COUNT(1)
			  FROM crapseg seg
			 WHERE seg.cdcooper = pr_cdcooper
			   AND seg.nrdconta = pr_nrdconta
				 AND seg.tpseguro IN (1,11,3)
				 AND seg.cdsitseg IN (1,3);

  BEGIN
    -- Efetuaremos a busca do calendário
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat; 
    -- Montagem do período de busca das informações conforme o número da ocorrência  
    IF pr_numocorre = 0 THEN
      -- Ocorrência zero refere-se ao período total, então as
      -- datas das buscas já devem ser enviadas
      vr_dat_ini := pr_datinicio;
      vr_dat_fim := pr_datfinal;
    ELSE
      -- Calcularemos as datas com base na ocorrência solicitada
      -- Obs: As ocorrências vão de 1 a N, sendo cada uma um mês 
      --      no passado.
      vr_dat_ini := ADD_MONTHS(rw_crapdat.dtmvtolt,pr_numocorre*-1)+1;
      vr_dat_fim := ADD_MONTHS(rw_crapdat.dtmvtolt,(pr_numocorre-1)*-1);  
    END IF;
    -- Então, implementamos a regra de busca para cada um dos indicadores
    IF pr_idindicador = 1 THEN
      -- Quantidade de boletos emitidos no mês
      OPEN cr_indica01;
      FETCH cr_indica01
       INTO vr_retorno;
      CLOSE cr_indica01; 
    ELSIF pr_idindicador = 2 THEN
      -- Valor de boletos compensados no mês
      OPEN cr_indica02;
      FETCH cr_indica02
       INTO vr_retorno;
      CLOSE cr_indica02;
    ELSIF pr_idindicador = 3 THEN
      -- Valor dos pagamentos efetuados pelo cooperado
      OPEN cr_indica03;
      FETCH cr_indica03
       INTO vr_retorno;
      CLOSE cr_indica03;
    ELSIF pr_idindicador = 4 THEN
      -- Saldo Médio Mensal
      OPEN cr_indica04;
      FETCH cr_indica04
       INTO vr_retorno;
      CLOSE cr_indica04;    
		ELSIF pr_idindicador = 5 THEN
			-- Saldo devedor de Empréstimo/Financiamento
			
		  --Buscar Indicador Uso tabela
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
          --Nao usa tabela
          vr_inusatab:= FALSE;
        ELSE
          --Nao usa tabela
          vr_inusatab:= TRUE;
        END IF;    
      END IF;
      
      -- busca o tipo de documento GED    
      vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                          ,pr_nmsistem => 'CRED'
                                                          ,pr_tptabela => 'GENERI'
                                                          ,pr_cdempres => 00
                                                          ,pr_cdacesso => 'DIGITALIZA'
                                                          ,pr_tpregist => 5);
      
      -- Leitura do indicador de uso da tabela de taxa de juros                                                    
      vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                         ,pr_nmsistem => 'CRED'
                                                         ,pr_tptabela => 'USUARI'
                                                         ,pr_cdempres => 11
                                                         ,pr_cdacesso => 'PAREMPCTL'
                                                         ,pr_tpregist => 01);                                                           
      -- Obter dados do emprestimo																												 
			EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper        --> Cooperativa conectada
                                      ,pr_cdagenci => 1                  --> Código da agência
                                      ,pr_nrdcaixa => 0                  --> Número do caixa
                                      ,pr_cdoperad => '1'                --> Código do operador
                                      ,pr_nmdatela => 'RCIP0001'         --> Nome datela conectada
                                      ,pr_idorigem => 7 -- Batch         --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta        --> Conta do associado
                                      ,pr_idseqttl => 1                  --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => rw_crapdat       --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul => NULL               --> Data solicitada do calculo
                                      ,pr_nrctremp => 0                  --> Número contrato empréstimo
                                      ,pr_cdprogra => 'RCIP0001'         --> Programa conectado
                                      ,pr_inusatab => vr_inusatab        --> Indicador de utilização da tabela
                                      ,pr_flgerlog => 'N'                --> Gerar log S/N
                                      ,pr_flgcondc => FALSE              --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => NULL               --> Nome Primeiro Titular
																			,pr_tab_parempctl => vr_dstextab_parempctl    --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_dstextab_digitaliza  --> Dados tabela parametro
																			,pr_nriniseq => 0                  --> Numero inicial paginacao
                                      ,pr_nrregist => 0                  --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist        --> Qtd total de registros
																			,pr_tab_dados_epr => vr_tab_dados_epr --> Saida com os dados do empréstimo
																			,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
			-- Se retornou algum erro														
			IF vr_des_erro <> 'OK' THEN
				RETURN 0;
			END IF;
           
		  --Buscar primeiro registro da tabela de emprestimos
		  vr_index_epr:= vr_tab_dados_epr.FIRST;
			
		  --Se Retornou Dados
		  WHILE vr_index_epr IS NOT NULL LOOP
             			  
			  IF vr_tab_dados_epr(vr_index_epr).tpemprst IN (1,2) THEN -- PP ou POS
					-- Somar saldo devedor de emprestimo
					vr_retorno := nvl(vr_retorno,0) + nvl(vr_tab_dados_epr(vr_index_epr).vlsdeved,0);
        END IF;				
				
				IF (vr_tab_dados_epr(vr_index_epr).flgatras = 1) THEN 
					RETURN 0;
				END IF;
			  --Buscar proximo indice           
				vr_index_epr := vr_tab_dados_epr.next(vr_index_epr);
	    END LOOP;  
    ELSIF pr_idindicador = 6 THEN
      -- Desconto de Títulos
      OPEN cr_indica06;
      FETCH cr_indica06
       INTO vr_retorno;
      CLOSE cr_indica06;  
    ELSIF pr_idindicador = 7 THEN
      -- Desconto de Cheques
      OPEN cr_indica07;
      FETCH cr_indica07
       INTO vr_retorno;
      CLOSE cr_indica07;  
    ELSIF pr_idindicador = 8 THEN
      -- Limite de Cheque Especial
      OPEN cr_indica08;
      FETCH cr_indica08
       INTO vr_retorno;
      CLOSE cr_indica08;  
    ELSIF pr_idindicador = 9 THEN
      -- Plano de Cotas
      OPEN cr_indica09;
      FETCH cr_indica09
       INTO vr_retorno;
      CLOSE cr_indica09;  
    ELSIF pr_idindicador = 10 THEN
      -- Valor das Cotas
      OPEN cr_indica10;
      FETCH cr_indica10
       INTO vr_retorno;
      CLOSE cr_indica10;  
    ELSIF pr_idindicador = 11 THEN
      -- Aplicação/RDC
      OPEN cr_indica11;
      FETCH cr_indica11
       INTO vr_retorno;
      CLOSE cr_indica11;  
    ELSIF pr_idindicador = 12 THEN
      -- Poupança Programada
      OPEN cr_indica12;
      FETCH cr_indica12
       INTO vr_retorno;
      CLOSE cr_indica12;  
		ELSIF pr_idindicador = 13 THEN
			-- Adesão de Folha de Pagamento
      OPEN cr_indica13;
      FETCH cr_indica13
       INTO vr_retorno;
      CLOSE cr_indica13;
    ELSIF pr_idindicador = 14 THEN
      -- Débito automático
      OPEN cr_indica14;
      FETCH cr_indica14
       INTO vr_retorno;
      CLOSE cr_indica14;  
    ELSIF pr_idindicador = 15 THEN
      -- Cartão de crédito
      OPEN cr_indica15;
      FETCH cr_indica15
       INTO vr_retorno;
      CLOSE cr_indica15;
    ELSIF pr_idindicador = 16 THEN
			-- Plano Poup. Prog.
      OPEN cr_indica16;
      FETCH cr_indica16
       INTO vr_retorno;
      CLOSE cr_indica16;
		ELSIF pr_idindicador = 17 THEN
			-- Adesão Crédito Salário
      OPEN cr_indica17;
      FETCH cr_indica17
       INTO vr_retorno;
      CLOSE cr_indica17;
		ELSIF pr_idindicador = 18 THEN
			-- Adesão Consórcio
      OPEN cr_indica18;
      FETCH cr_indica18
       INTO vr_retorno;
      CLOSE cr_indica18;
		ELSIF pr_idindicador = 19 THEN			
			-- Tempo de conta
      OPEN cr_indica19;
      FETCH cr_indica19
       INTO vr_retorno;
      CLOSE cr_indica19;
		ELSIF pr_idindicador = 20 THEN			
			-- Quantidade de seguros ativos
      OPEN cr_indica20;
      FETCH cr_indica20
       INTO vr_retorno;
      CLOSE cr_indica20;

		ELSE
      -- Indicador não mapeado
      RETURN -1;
    END IF;
    -- Retorno genérico
    RETURN nvl(vr_retorno,0)+nvl(vr_retorno_02,0);    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END fn_valor_realizado_indicador;  
  
  /* Calcular, acular e atualizar um indicador em apuração */
  PROCEDURE pc_calcula_recipro_atingida(pr_cdcooper           IN tbrecip_apuracao.cdcooper%TYPE             -- Cooperativa da apuração
                                       ,pr_nrdconta           IN tbrecip_apuracao.nrdconta%TYPE             -- Conta da apuracação
                                       ,pr_idapuracao         IN tbrecip_apuracao.idapuracao_reciproci%TYPE -- Id da apuracação envolvida
                                       ,pr_idindicador        IN tbrecip_indicador.idindicador%TYPE         -- ID Indicador
                                       ,pr_dtinicio_apuracao  IN tbrecip_apuracao.dtinicio_apuracao%TYPE    -- Data ini apuração
                                       ,pr_dttermino_apuracao IN tbrecip_apuracao.dttermino_apuracao%TYPE   -- Data fim apuracação  
                                       ,pr_idconfig_recipro   IN tbrecip_apuracao.idconfig_recipro%TYPE     -- Config da reciprocidade
                                       ,pr_tpreciproci        IN tbrecip_apuracao.tpreciproci%TYPE          -- Tipo da reciprocidade
                                       ,pr_tpindicador        IN tbrecip_indicador.tpindicador%TYPE         -- Tipo do Indicador
                                       ,pr_flgatingido       OUT VARCHAR2                                   -- Retorno S/N de atingimento 
                                       ,pr_descr_error       OUT VARCHAR2) IS                               -- Erro encontrado
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calcula_recipro_atingida                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta procedure terá o intuito de buscar efetuar o cálculo da reciprocidade 
  --             para o indicador repassado, atualizar seus valores realizados e atingimento 
  --             da meta, e devolver S ou N de acordo com o atingimento ou não.
  ---------------------------------------------------------------------------------------------------------------
    
    -- Busca dos valores previstos
    CURSOR cr_calculo(pr_idcalculo tbrecip_apuracao.idconfig_recipro%TYPE) IS
      SELECT (ICR.VLCONTRATA * CRP.QTDMES_RETORNO_RECIPROCI) vr_vlarealizar
            ,ICR.PERTOLERA
        FROM TBRECIP_CALCULO        CRP 
            ,TBRECIP_INDICA_CALCULO ICR
       WHERE CRP.idcalculo_reciproci = ICR.idcalculo_reciproci
         AND CRP.idcalculo_reciproci = pr_idcalculo
         AND ICR.idindicador         = pr_idindicador;
    rw_calculo cr_calculo%ROWTYPE;
    
    -- Busca das faixas parametrizadas
    CURSOR cr_parame(pr_idparame tbrecip_apuracao.idconfig_recipro%TYPE) IS
       SELECT IPR.vlminimo
             ,IPR.pertolera
         FROM TBRECIP_PARAME_INDICA_CALCULO IPR
        WHERE IPR.idparame_reciproci = pr_idparame
          AND IPR.idindicador        = pr_idindicador;
    rw_parame cr_parame%ROWTYPE;
    
    -- Variáveis genéricas
    vr_vlrealizado NUMBER;
    
    -- Tratamento de erro
    vr_des_erro VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
  BEGIN
    -- Buscaremos o valor reaizado do indicador no período total da apuração
    vr_vlrealizado := FN_VALOR_REALIZADO_INDICADOR(pr_cdcooper    => pr_cdcooper
                                                  ,pr_nrdconta    => pr_nrdconta
                                                  ,pr_idindicador => pr_idindicador
                                                  ,pr_numocorre   => 0 --> Retornar a última ocorrência
                                                  ,pr_datinicio   => pr_dtinicio_apuracao
                                                  ,pr_datfinal    => pr_dttermino_apuracao);
    -- Para indicadores do tipo adesão
    IF pr_tpindicador = 'A' THEN
      -- Apenas precisaremos verificar se o mesmo está ativo, ou seja, VR_VLREALIZADO > 0:    
      IF vr_vlrealizado > 0 THEN
        -- Atingiu
        pr_flgatingido := 1;
      ELSE
        -- Não atingido
        pr_flgatingido := 0;
      END IF;
    ELSE -- Para todos os outros tipos de indicadores
      -- 1 - Para reciprocidade com base na previsão  
      IF pr_tpreciproci = 1 THEN
        -- Buscaremos o valor proposto do indicador * qtd meses de retorno e a tolerância:
        OPEN cr_calculo(pr_idconfig_recipro);
        FETCH cr_calculo
         INTO rw_calculo;
        CLOSE cr_calculo;
        -- Então, iremos testar se houve o atingimento: 
        IF rw_calculo.vr_vlarealizar > vr_vlrealizado + (vr_vlrealizado * (rw_calculo.pertolera / 100)) THEN
          pr_flgatingido := 0;
        ELSE
          pr_flgatingido := 1;
        END IF;
      ELSE -- 2 - Para reciprocidade com base na faixa mínima e máxima
        -- Buscaremos o valor mínimo da parametrização e a tolerância:
        OPEN cr_parame(pr_idconfig_recipro);
        FETCH cr_parame
         INTO rw_parame;
        CLOSE cr_parame;
        -- Então, iremos testar se houve o atingimento:
        IF rw_parame.vlminimo > vr_vlrealizado + (vr_vlrealizado * (rw_parame.pertolera / 100)) THEN
          pr_flgatingido := 0;
        ELSE
          pr_flgatingido := 1;
        END IF;
      END IF;
    END IF;  
    -- Atualizaremos a tabela para indicar o valor realizado e o atingimento ou não:
    BEGIN
      UPDATE TBRECIP_APURACAO_INDICA
         SET FLGATINGIDO = pr_flgatingido
            ,VLREALIZADO = vr_vlrealizado
       WHERE IDAPURACAO_RECIPROCI = pr_idapuracao
         AND IDINDICADOR          = pr_idindicador;
    EXCEPTION
      WHEN OTHERS THEN
        vr_des_erro := 'Erro ao atualizar o valor realizado --> '||SQLERRM;
        RAISE vr_exc_erro;
    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_descr_error := 'RCIP0001.pc_calcula_recipro_atingida --> '||vr_des_erro;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_descr_error := 'RCIP0001.pc_calculo_recipro_atingida --> Erro não tratado: '||SQLERRM;
  END pc_calcula_recipro_atingida;    
  
  /* Procedimento para remoção de calculos/parametrizações não utilizadas pelo sistema */
  PROCEDURE pc_remove_recipro_sem_uso IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_remove_recipro_sem_uso                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função terá de limpar os cálculos e parametrização de reciprocidade
  --             não mais utilizados, devido cancelamento do cadastro sem confirmação.
  ---------------------------------------------------------------------------------------------------------------
    vr_des_erro VARCHAR2(4000);
  BEGIN  
    -- Primeiro para os indicadores de cálculos não utilizados
    DELETE TBRECIP_INDICA_CALCULO ICR
     WHERE NOT EXISTS (SELECT 1
                         FROM TBRECIP_APURACAO APR
                        WHERE APR.idconfig_recipro = ICR.idcalculo_reciproci
                          AND APR.tpreciproci        = 1) /* Por previsão */
       AND NOT EXISTS (SELECT 1
                         FROM CRAPCEB CEB
                        WHERE CEB.idrecipr = ICR.idcalculo_reciproci);
    -- Após para os cálculos não utilizados
    DELETE TBRECIP_CALCULO CRP
     WHERE NOT EXISTS (SELECT 1
                         FROM TBRECIP_APURACAO APR
                        WHERE APR.idconfig_recipro = CRP.idcalculo_reciproci
                          AND APR.tpreciproci        = 1) /* Por previsão */
       AND NOT EXISTS (SELECT 1
                         FROM CRAPCEB CEB
                        WHERE CEB.idrecipr = CRP.idcalculo_reciproci);
    -- Seguindo, eliminados os indicadores de parametrização não utilizados:
    DELETE TBRECIP_PARAME_INDICA_CALCULO IPR
     WHERE NOT EXISTS (SELECT 1
                         FROM CRAPCCO CCO
                        WHERE CCO.idprmrec = IPR.idparame_reciproci)
       /*AND NOT EXISTS (SELECT 1
                         FROM TBTARIF_CONTAS_PACOTE CPC
                        WHERE CPC.cdreciprocidade = IPR.idparame_reciproci) ver marcos*/
       AND NOT EXISTS (SELECT 1
                         FROM TBRECIP_APURACAO APR
                        WHERE APR.idconfig_recipro = IPR.idparame_reciproci
                          AND APR.tpreciproci        = 2); /* Por faixa parametrizada */
    -- Por fim, as parametrizações não utilizadas:
    DELETE TBRECIP_PARAME_CALCULO PRP
     WHERE NOT EXISTS (SELECT 1
                         FROM CRAPCCO CCO
                        WHERE CCO.idprmrec = PRP.idparame_reciproci)
       /*AND NOT EXISTS (SELECT 1
                         FROM TBTARIF_CONTAS_PACOTE CPC
                        WHERE CPC.cdreciprocidade = IPR.idparame_reciproci) ver marcos*/
       AND NOT EXISTS (SELECT 1
                         FROM TBRECIP_APURACAO APR
                        WHERE APR.idconfig_recipro = PRP.idparame_reciproci
                          AND APR.tpreciproci        = 2); /* Por faixa parametrizada */
    -- Finalmente gravação dos dados
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      -- Cancelar o processo até então
      ROLLBACK;
      -- Enviar e-mail com o erro encontrado
      gene0003.pc_solicita_email(pr_cdcooper    => 3
                                ,pr_cdprogra    => 'RCIP0001'
                                ,pr_des_destino => gene0001.fn_param_sistema('CRED',3, 'ERRO_EMAIL_JOB')
                                ,pr_des_assunto => 'Reciprocidade – Erro na remoção de reciprocidade sem uso'
                                ,pr_des_corpo   => 'Olá, <br><br>'
                                                || 'Foram encontrados problemas durante o processo de remoção de reciprocidade sem uso. <br>'
                                                || 'Abaixo trazemos detalhes do erro:<br>'
                                                || SQLERRM
                                ,pr_des_anexo   => ''
                                ,pr_flg_enviar  => 'N'
                                ,pr_des_erro    => vr_des_erro);
      -- Commitar para o envio posterior
      COMMIT;
  END pc_remove_recipro_sem_uso;
  
  
  /* Calcular os períodos de apuracação expirados e aplicar as regras de reversão e debito */
  PROCEDURE pc_expira_reciproci_prevista(pr_cdcritic OUT PLS_INTEGER
                                        ,pr_dscritic OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_expira_reciproci_prevista                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: 22/12/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função terá o intuito de buscar todos os períodos de apuração 
  --             em aberto e expirados. A partir daí, irá checar todos os indicadores 
  --             propostos, e em caso de não atingimento irá efetuar a reversão e débitos
  --             das tarifas – se configurado – ou irá recriar o próximo período de apuração
  --             da reciprocidade.
  -- 
  -- Alteracoes 
  --      22/12/2017 - Chamado 802553 - Utilizar a estrutura de tarifas ao invés de histórico fixo
  --                   Andrei - Mouts

  ---------------------------------------------------------------------------------------------------------------
    -- Calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -- Tratamento de exceção
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_des_erro VARCHAR2(4000);
    vr_tab_erro gene0001.typ_tab_erro;
    -- Busca de todos os períodos de apuracação em aberto e expirados
    -- já vinculando a configuração de calculo da reciprocidade
    CURSOR cr_apura IS
      SELECT apr.idapuracao_reciproci
            ,apr.cdcooper
            ,apr.nrdconta
            ,apr.cdchave_produto
            ,apr.dtinicio_apuracao
            ,apr.dttermino_apuracao
            ,apr.idconfig_recipro
            ,apr.tpreciproci
            ,apr.cdproduto
            ,cal.flgreversao_tarifa
            ,cal.flgdebito_reversao
            ,cal.qtdmes_retorno_reciproci
            ,ass.inpessoa
        FROM tbrecip_apuracao        apr
            ,tbrecip_calculo         cal
            ,crapass                 ass 
       WHERE apr.cdcooper             = ass.cdcooper
         AND apr.nrdconta             = ass.Nrdconta
         AND apr.idconfig_recipro     = cal.idcalculo_reciproci
         AND apr.dttermino_apuracao   < SYSDATE
         AND apr.indsituacao_apuracao = 'A' -- Em apuração
         AND apr.tpreciproci          = 1; -- Com base em previsão 
    -- Indicadores para atingimento
    vr_flgatingido       CHAR(1);
    vr_flgatingido_total BOOLEAN;    
    vr_qtindicador_total PLS_INTEGER;
    vr_qtindicador_ating PLS_INTEGER;
    vr_per_atingido      NUMBER;
    vr_idapuracao_nova   tbrecip_apuracao.idapuracao_reciproci%TYPE;
    -- Busca de todos os indicadores do período em apuracação
    CURSOR cr_indica(pr_idapura tbrecip_apuracao.idapuracao_reciproci%TYPE) IS
      SELECT air.idindicador
            ,idr.tpindicador
        FROM tbrecip_apuracao_indica air
            ,tbrecip_indicador       idr
       WHERE air.idindicador = idr.idindicador
         AND air.idapuracao_reciproci = pr_idapura;
    -- Buscaremos o valor do desconto efetuado sobre as tarifas que possuem
    -- reversão durante o período da apuração:     
    CURSOR cr_desc_tarifa(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE
                         ,pr_cdchave  tbrecip_apuracao.cdchave_produto%TYPE
                         ,pr_dtinicio tbrecip_apuracao.dtinicio_apuracao%TYPE
                         ,pr_dttermin tbrecip_apuracao.dttermino_apuracao%TYPE) IS
      SELECT SUM(APT.vltarifa_original - APT.vltarifa_cobrado)
        FROM CRAPCAT CAT
            ,CRAPTAR TAR
            ,TBRECIP_APURACAO_TARIFA APT
       WHERE APT.cdcooper        = pr_cdcooper
         AND APT.nrdconta        = pr_nrdconta
         AND APT.cdchave_produto = pr_cdchave
         AND APT.dtocorre between pr_dtinicio 
                              and pr_dttermin
         AND APT.cdtarifa = TAR.cdtarifa
         AND TAR.cdcatego = CAT.cdcatego
         AND CAT.flrecipr = 1; -- Somente as vinculadas a reciprocidade terão reversão
    vr_vlr_desconto NUMBER;             
    -- Retorno da rotina de tarifas
    vr_cdhisdeb INTEGER;
    vr_cdhisest INTEGER;
    vr_dtdivulg DATE;
    vr_vltarfol NUMBER := 0;
    vr_dtvigenc DATE;
    vr_cdfvlcop INTEGER;
    vr_cdlantar craplat.cdlantar%TYPE;
    -- Lote do convênio de cobrança
    CURSOR cr_lote(pr_cdcooper crapcop.cdcooper%TYPE
                  ,pr_cdchave  tbrecip_apuracao.cdchave_produto%TYPE) IS
      SELECT nrdolote
        FROM crapcco
       WHERE cdcooper = pr_cdcooper
         AND nrconven = pr_cdchave;
    vr_nrdolote crapcco.nrdolote%TYPE;
    
  BEGIN
    -- Buscar todos os períodos de apuração em aberto e expirados
    FOR rw_apura IN cr_apura LOOP  
      BEGIN  
        -- Inicializar indicadores de atingimento total da reciprocidade e contadores
        vr_flgatingido_total := TRUE;
        vr_qtindicador_total := 0;
        vr_qtindicador_ating := 0;
        -- Buscar todos os indicadores contratados
        FOR rw_indica IN cr_indica(rw_apura.idapuracao_reciproci) LOOP
          -- Para cada indicador encontrado:
          -- Acumularemos a quantidade total de indicadores
          vr_qtindicador_total := vr_qtindicador_total + 1;
          -- Acionaremos a rotina que irá calcular o apurador, e sinalizar se o
          --  mesmo foi atingido ou não
          rcip0001.pc_calcula_recipro_atingida(pr_cdcooper           => rw_apura.cdcooper
                                              ,pr_nrdconta           => rw_apura.nrdconta
                                              ,pr_idapuracao         => rw_apura.idapuracao_reciproci
                                              ,pr_idindicador        => rw_indica.idindicador
                                              ,pr_dtinicio_apuracao  => rw_apura.dtinicio_apuracao
                                              ,pr_dttermino_apuracao => rw_apura.dttermino_apuracao
                                              ,pr_idconfig_recipro   => rw_apura.idconfig_recipro
                                              ,pr_tpreciproci        => rw_apura.tpreciproci
                                              ,pr_tpindicador        => rw_indica.tpindicador
                                              ,pr_flgatingido        => vr_flgatingido
                                              ,pr_descr_error        => vr_des_erro);
          -- Se encontrarmos erro
          IF vr_des_erro IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Se não atingimos a reciprocidade
          IF vr_flgatingido = 0 THEN
            -- Guardar na variável de controle se pelo menos um dos indicadores não atingiu:
            vr_flgatingido_total := FALSE;
          ELSE
            -- Acumularemos a quantidade de indicadores atingida
            vr_qtindicador_ating := vr_qtindicador_ating + 1;
          END IF;
        END LOOP; -- Fim todos indicadores
        
        -- Se algum dos indicadores não atingiu
        IF NOT vr_flgatingido_total THEN
          -- Se houver reversão de tarifa
          IF rw_apura.flgreversao_tarifa = 1 THEN
            -- Para o produto Cecred Cobrança
            IF rw_apura.cdproduto = 6 THEN  
              -- Atualizaremos todos os descontos previstos para grupos de tarifas
              -- de cobrança no convênio:
              BEGIN
                UPDATE tbcobran_categ_tarifa_conven
                   SET perdesconto = 0
                 WHERE cdcooper = rw_apura.cdcooper
                   AND nrdconta = rw_apura.nrdconta
                   AND nrconven = rw_apura.cdchave_produto;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_des_erro := 'Erro ao atualizar tbcobran_categ_tarifa_conven: '||SQLERRM;
              END;
              -- Então atualizar o convênio de cobrança removendo o cálculo de reciprocidade vinculado ao mesmo:
              BEGIN
                UPDATE crapceb
                   SET idrecipr = 0
                 WHERE cdcooper = rw_apura.cdcooper
                   AND nrdconta = rw_apura.nrdconta
                   AND nrconven = rw_apura.cdchave_produto;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_des_erro := 'Erro ao atualizar crapceb: '||SQLERRM;
              END;
            END IF;
          END IF;
          -- Se houver debito da tarifa revertida
          IF rw_apura.flgdebito_reversao = 1 THEN
            -- Buscaremos o valor do desconto efetuado sobre as tarifas que possuem
            -- reversão durante o período da apuração:
            vr_vlr_desconto := 0;
            OPEN cr_desc_tarifa(pr_cdcooper => rw_apura.cdcooper
                               ,pr_nrdconta => rw_apura.nrdconta
                               ,pr_cdchave  => rw_apura.cdchave_produto
                               ,pr_dtinicio => rw_apura.dtinicio_apuracao
                               ,pr_dttermin => rw_apura.dttermino_apuracao);
            FETCH cr_desc_tarifa
             INTO vr_vlr_desconto;
            CLOSE cr_desc_tarifa;
            -- Somente se houve desconto
            IF vr_vlr_desconto > 0 THEN
              -- Buscamos os valores da tarifa vigente no sistema de tarifação (CADTAR)
              tari0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => rw_apura.cdcooper     --Codigo Cooperativa
                                                   ,pr_nrdconta => rw_apura.nrdconta     --Conta da empresa
                                                   ,pr_nrconven => 0                     --Numero Convenio
                                                   ,pr_dsincide => 'COBRANCA'            --Descricao Incidencia
                                                   ,pr_cdocorre => 0                     --Codigo Ocorrencia
                                                   ,pr_cdmotivo => NULL                  --Codigo Motivo
                                                   ,pr_inpessoa => rw_apura.inpessoa     --Tipo Pessoa(PJ)
                                                   ,pr_vllanmto => vr_vlr_desconto       --Valor Lancamento
                                                   ,pr_cdprogra => 'RCIP0001'            --Nome Programa
                                                   ,pr_flaputar => 0                     --Apurar
                                                   ,pr_cdhistor => vr_cdhisdeb           --Codigo Historico
                                                   ,pr_cdhisest => vr_cdhisest           --Historico Estorno
                                                   ,pr_vltarifa => vr_vltarfol           --Valor Tarifa
                                                   ,pr_dtdivulg => vr_dtdivulg           --Data Divulgacao
                                                   ,pr_dtvigenc => vr_dtvigenc           --Data Vigencia
                                                   ,pr_cdfvlcop => vr_cdfvlcop
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_des_erro);
              -- Se ocorrer erro
              IF NVL(vr_cdcritic,0) > 0 OR vr_des_erro IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  

              -- Buscar o lote para lançamento da tarifa
              --  A busca abaixo é específica para produto de Cobrança, ou seja, tpproduto = 6,
              --  outros produtos devem ter suas regras de busca de lote implementadas em paralelo a esta:
              IF rw_apura.cdproduto = 6 THEN
                vr_nrdolote := 0;
                OPEN cr_lote(pr_cdcooper => rw_apura.cdcooper
                               ,pr_cdchave  => rw_apura.cdchave_produto);
                FETCH cr_lote
                 INTO vr_nrdolote;
                CLOSE cr_lote;                
              END IF;
              -- Se não encontrarmos lote ou histórico
              IF vr_nrdolote = 0 OR vr_cdhisdeb = 0 THEN
                vr_des_erro := 'Não foi possível encontrar lote ou histórico para débito da reversão.';
                RAISE vr_exc_erro;
              ELSE --> Tudo ok
                -- Buscar o calendário
                OPEN btch0001.cr_crapdat(rw_apura.cdcooper);
                FETCH btch0001.cr_crapdat
                 INTO rw_crapdat;
                CLOSE btch0001.cr_crapdat;
                
                -- Por fim, chamaremos a rotina responsável por tentar debitar a tarifa do cooperado:
                TARI0001.pc_lan_tarifa_online (pr_cdcooper => rw_apura.cdcooper    --Codigo Cooperativa
                                              ,pr_cdagenci => 1                    --Codigo Agencia destino
                                              ,pr_nrdconta => rw_apura.nrdconta    --Numero da Conta Destino
                                              ,pr_cdbccxlt => 100                  --Codigo banco/caixa
                                              ,pr_nrdolote => vr_nrdolote          --Numero do Lote
                                              ,pr_tplotmov => 1                    --Tipo Lote
                                                 ,pr_cdoperad => '1'                   --Codigo Operador
                                              ,pr_dtmvtlat => rw_crapdat.dtmvtolt  --Data Tarifa
                                              ,pr_dtmvtlcm => rw_crapdat.dtmvtolt  --Data lancamento
                                              ,pr_nrdctabb => rw_apura.nrdconta    --Numero Conta BB
                                              ,pr_nrdctitg => to_char(rw_apura.nrdconta,'fm00000000')  --Conta Integracao
                                              ,pr_cdhistor => vr_cdhisdeb          --Codigo Historico
                                                 ,pr_cdpesqbb => NULL                  --Codigo pesquisa
                                                 ,pr_cdbanchq => 0                     --Codigo Banco Cheque
                                                 ,pr_cdagechq => 0                     --Codigo Agencia Cheque
                                                 ,pr_nrctachq => 0                     --Numero Conta Cheque
                                              ,pr_flgaviso => FALSE                --Flag Aviso
                                              ,pr_tpdaviso => 0                    --Tipo Aviso
                                              ,pr_vltarifa => vr_vlr_desconto      --Valor tarifa
                                              ,pr_nrdocmto => 0                    --Numero Documento
                                              ,pr_cdcoptfn => 0                    --Codigo Cooperativa Terminal
                                              ,pr_cdagetfn => 0                    --Codigo Agencia Terminal
                                              ,pr_nrterfin => 0                    --Numero Terminal Financeiro
                                              ,pr_nrsequni => 0                    --Numero Sequencial Unico
                                              ,pr_nrautdoc => 0                    --Numero Autenticacao Documento
                                              ,pr_dsidenti => NULL                 --Descricao Identificacao
                                              ,pr_cdfvlcop => vr_cdfvlcop          --Codigo Faixa Valor Cooperativa
                                              ,pr_inproces => rw_crapdat.inproces  -- On-line --Indicador processo
                                              ,pr_cdlantar => vr_cdlantar          --Codigo Lancamento tarifa
                                              ,pr_tab_erro => vr_tab_erro          --Tabela de erro
                                              ,pr_cdcritic => vr_cdcritic          --Codigo do erro
                                              ,pr_dscritic => vr_des_erro);        --Descricao do erro
                -- Se ocorrer erro
                IF vr_cdcritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
                  --verificar o erro e criar log
                  IF vr_tab_erro.COUNT > 0 THEN
                    --Usar o erro da tab
                    vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic; --Descricao do erro
                  RAISE vr_exc_erro;
                  END IF;
                END IF;
              END IF;
              END IF;
            END IF;
          END IF;  
          -- Calculo do percentual de atingimento:
          IF vr_flgatingido_total THEN
            -- Todos foram atingidos = 100%:
            vr_per_atingido := 100;
          ELSE
            -- Devemos calcular a quantidade de atingimento com base nas quantidades acumuladas anteriormente:
            vr_per_atingido := ROUND((vr_qtindicador_ating * 100) / vr_qtindicador_total,2);
          END IF;
          -- Ao final, faremos atualização do período de apuração corrente com base nas
          -- informações buscadas acima:
          BEGIN
            UPDATE tbrecip_apuracao
               SET indsituacao_apuracao = 'E' --> Encerrada
                  ,perrecipro_atingida  = vr_per_atingido
                  ,flgtarifa_debitada   = rw_apura.flgdebito_reversao
                  ,flgtarifa_revertida  = rw_apura.flgreversao_tarifa
             WHERE idapuracao_reciproci = rw_apura.idapuracao_reciproci;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro na atualização da tabela TBRECIP_APURACAO: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          -- Então, verificaremos a necessidade de criação de novo período de apuração:
          -- Se todos os indicadores atingiram a Reciprocidade  
          -- ou se não atingiram, mas não houve reversão 
          IF vr_flgatingido_total OR rw_apura.flgreversao_tarifa = 0 THEN
            -- Recriamos o período de apuração
            BEGIN
              INSERT INTO TBRECIP_APURACAO(cdcooper
                                          ,nrdconta
                                          ,cdproduto
                                          ,cdchave_produto
                                          ,tpreciproci
                                          ,dtinicio_apuracao
                                          ,dttermino_apuracao
                                          ,idconfig_recipro
                                          ,indsituacao_apuracao
                                          ,perrecipro_atingida
                                          ,flgtarifa_revertida
                                          ,flgtarifa_debitada)
                              VALUES(rw_apura.cdcooper
                                    ,rw_apura.nrdconta
                                    ,rw_apura.cdproduto
                                    ,rw_apura.cdchave_produto
                                    ,rw_apura.tpreciproci
                                    ,rw_apura.dttermino_apuracao + 1
                                    ,add_months(rw_apura.dttermino_apuracao+1,rw_apura.qtdmes_retorno_reciproci)-1
                                    ,rw_apura.idconfig_recipro
                                    ,'A' -- Em apuração
                                    ,0
                                    ,0
                                    ,0)
                              returning idapuracao_reciproci into vr_idapuracao_nova;
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'Erro na recriação da TBRECIP_APURACAO: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
            -- Também recriaremos os indicadores do período
            BEGIN
              INSERT INTO TBRECIP_APURACAO_INDICA(idapuracao_reciproci
                                                 ,idindicador
                                                 ,vlrealizado
                                                 ,flgatingido)
                                           SELECT vr_idapuracao_nova
                                                 ,idindicador
                                                 ,0
                                                 ,0
                                             FROM TBRECIP_APURACAO_INDICA
                                            WHERE idapuracao_reciproci = rw_apura.idapuracao_reciproci; -- Id da apuracação anterior
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'Erro na recriação da TBRECIP_APURACAO_INDICA: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;
        -- Efetuar gravação a cada registro processado
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Cancelar o processo até então
          ROLLBACK;
          -- Enviar e-mail com o erro encontrado
          gene0003.pc_solicita_email(pr_cdcooper    => rw_apura.cdcooper
                                    ,pr_cdprogra    => 'RCIP0001'
                                    ,pr_des_destino => gene0001.fn_param_sistema('CRED',rw_apura.cdcooper, 'ERRO_EMAIL_JOB')
                                    ,pr_des_assunto => 'Reciprocidade – Erro na atualização da Reciprocidade'
                                    ,pr_des_corpo   => 'Olá, <br><br>'
                                                    || 'Foram encontrados problemas durante o processo de verificação de reciprocidade vencida. <br>'
                                                    || 'Abaixo trazemos detalhes da operação:<br>'
                                                    || 'Cooperativa: '||rw_apura.cdcooper||'<br>'
                                                    || 'Conta: '||rw_apura.nrdconta||'<br>'
                                                    || 'Convênio: '||rw_apura.cdchave_produto||'<br>'
                                                    || 'Prazo Reciprocidade: '||rw_apura.dtinicio_apuracao||' até ' || rw_apura.dttermino_apuracao||'<br><br>'
                                                    || 'Por fim, o erro tratado: '
                                                    || vr_des_erro
                                    ,pr_des_anexo   => ''
                                    ,pr_flg_enviar  => 'N'
                                    ,pr_des_erro    => vr_des_erro);
          -- Commitar para o envio posterior
          COMMIT;
          pr_dscritic := vr_des_erro;
          pr_cdcritic := 1051;
        WHEN OTHERS THEN
          -- Cancelar o processo até então
          ROLLBACK;
          -- Enviar e-mail com o erro encontrado
          gene0003.pc_solicita_email(pr_cdcooper    => rw_apura.cdcooper
                                    ,pr_cdprogra    => 'RCIP0001'
                                    ,pr_des_destino => gene0001.fn_param_sistema('CRED',rw_apura.cdcooper, 'ERRO_EMAIL_JOB')
                                    ,pr_des_assunto => 'Reciprocidade – Erro na atualização da Reciprocidade'
                                    ,pr_des_corpo   => 'Olá, <br><br>'
                                                    || 'Foram encontrados problemas durante o processo de verificação de reciprocidade vencida. <br>'
                                                    || 'Abaixo trazemos detalhes da operação:<br>'
                                                    || 'Cooperativa: '||rw_apura.cdcooper||'<br>'
                                                    || 'Conta: '||rw_apura.nrdconta||'<br>'
                                                    || 'Convênio: '||rw_apura.cdchave_produto||'<br>'
                                                    || 'Prazo Reciprocidade: '||rw_apura.dtinicio_apuracao||' até ' || rw_apura.dttermino_apuracao||'<br><br>'
                                                    || 'Por fim, o erro encontrado: '
                                                    || SQLERRM
                                    ,pr_des_anexo   => ''
                                    ,pr_flg_enviar  => 'N'
                                    ,pr_des_erro    => vr_des_erro);
          -- Commitar para o envio posterior
          COMMIT;
          pr_dscritic := vr_des_erro;
          pr_cdcritic := 1051;          
      END;  
    END LOOP; -- Fim períodos de apuração
  END pc_expira_reciproci_prevista;

  -- Procedure encarregada de buscar os periodos de apuracao
  PROCEDURE pc_periodo_apuracao_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                  ,pr_data_xml OUT CLOB
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_periodo_apuracao_ib
    --  Sistema  : Internet Banking
    --  Sigla    : CRED
    --  Autor    : Jaison
    --  Data     : Marco/2016.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure encarregada de buscar os periodos de apuracao.
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Busca os periodos
      CURSOR cr_periodos(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT apr.idapuracao_reciproci
              ,TO_CHAR(apr.dtinicio_apuracao,'DD/MM/RRRR')||' a '||TO_CHAR(apr.dttermino_apuracao,'DD/MM/RRRR') dsperiodo
          FROM tbrecip_apuracao apr
         WHERE apr.cdcooper    = pr_cdcooper
           AND apr.nrdconta    = pr_nrdconta
           AND apr.tpreciproci = 1 -- Somente aquelas com previsao / realizacao
      ORDER BY apr.idapuracao_reciproci DESC;

      -- Variaveis
      vr_xml_temp VARCHAR2(32726) := '';

    BEGIN
      -- Inicializa variavel
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<raiz>');

      -- Busca os periodos
      FOR rw_periodos IN cr_periodos(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP
          GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<periodo>'
                                                    || '  <idapuracao_reciproci>'||rw_periodos.idapuracao_reciproci||'</idapuracao_reciproci>'
                                                    || '  <dsperiodo>'||rw_periodos.dsperiodo||'</dsperiodo>'
                                                    || '</periodo>');
      END LOOP;

      -- Encerrar a tag raiz
      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina RCIP0001.pc_periodo_apuracao_ib: '||SQLERRM;
    END;

  END pc_periodo_apuracao_ib;

  -- Procedure encarregada de buscar a apuracao
  PROCEDURE pc_apuracao_ib(pr_idapurac  IN tbrecip_apuracao.idapuracao_reciproci%TYPE
                          ,pr_data_xml OUT CLOB
                          ,pr_cdcritic OUT PLS_INTEGER
                          ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_apuracao_ib
    --  Sistema  : Internet Banking
    --  Sigla    : CRED
    --  Autor    : Jaison
    --  Data     : Marco/2016.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure encarregada de buscar a apuracao.
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Busca a apuracao
      CURSOR cr_apuracao(pr_idapurac IN tbrecip_apuracao.idapuracao_reciproci%TYPE) IS
        SELECT prd.dsproduto       dstpproduto
              ,apr.cdchave_produto nrcontr_conven
              ,DECODE(apr.indsituacao_apuracao,'A',TRUNC(dat.dtmvtolt)-apr.dtinicio_apuracao
                                              ,'C',TRUNC(apr.dtcancela_apuracao)-apr.dtinicio_apuracao
                                              ,apr.dttermino_apuracao-apr.dtinicio_apuracao) qtdias_decorrido
              ,crp.qtdmes_retorno_reciproci * 30 qtdias_previsto
              ,DECODE(apr.indsituacao_apuracao,'A','Em apuração'
                                              ,'C','Cancelada'
                                              ,'Encerrada') dssituacao
          FROM tbcc_produto     prd
              ,tbrecip_apuracao apr
              ,tbrecip_calculo  crp
              ,crapdat          dat
         WHERE apr.idapuracao_reciproci = pr_idapurac
           AND apr.idconfig_recipro     = crp.idcalculo_reciproci
           AND prd.cdproduto            = apr.cdproduto
           AND apr.cdcooper             = dat.cdcooper;
      rw_apuracao cr_apuracao%ROWTYPE;

      -- Variaveis
      vr_xml_temp VARCHAR2(32726) := '';

    BEGIN
      -- Inicializa variavel
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Busca a apuracao
      OPEN  cr_apuracao(pr_idapurac => pr_idapurac);
      FETCH cr_apuracao INTO rw_apuracao;
      CLOSE cr_apuracao;

      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<raiz>');

      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '<apuracao>'
                                                   || '  <dstpproduto>'||rw_apuracao.dstpproduto||'</dstpproduto>'
                                                   || '  <nrcontr_conven>'||rw_apuracao.nrcontr_conven||'</nrcontr_conven>'
                                                   || '  <qtdias_decorrido>'||rw_apuracao.qtdias_decorrido||'</qtdias_decorrido>'
                                                   || '  <qtdias_previsto>'||rw_apuracao.qtdias_previsto||'</qtdias_previsto>'
                                                   || '  <dssituacao>'||rw_apuracao.dssituacao||'</dssituacao>'
                                                   || '</apuracao>');
      -- Encerrar a tag raiz
      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina RCIP0001.pc_apuracao_ib: '||SQLERRM;
    END;

  END pc_apuracao_ib;

  -- Procedure encarregada de buscar os indicadores
  PROCEDURE pc_indicadores_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE
                             ,pr_idapurac  IN tbrecip_apuracao.idapuracao_reciproci%TYPE
                             ,pr_data_xml OUT CLOB
                             ,pr_cdcritic OUT PLS_INTEGER
                             ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_indicadores_ib
    --  Sistema  : Internet Banking
    --  Sigla    : CRED
    --  Autor    : Jaison
    --  Data     : Marco/2016.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure encarregada de buscar os indicadores.
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Busca os indicadores
      CURSOR cr_indicador(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                         ,pr_idapurac IN tbrecip_apuracao.idapuracao_reciproci%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT idr.idindicador
              ,idr.nmindicador
              ,idr.tpindicador
              ,(icr.vlcontrata * crp.qtdmes_retorno_reciproci) vlcontrata
              ,DECODE(apr.indsituacao_apuracao,'A',RCIP0001.fn_valor_realizado_indicador(pr_cdcooper
                                                                                        ,pr_nrdconta
                                                                                        ,idr.idindicador
                                                                                        ,0
                                                                                        ,apr.dtinicio_apuracao
                                                                                        ,pr_dtmvtolt)
                                                  ,air.vlrealizado) vlrealizado
         FROM tbrecip_apuracao        apr
             ,tbrecip_calculo         crp 
             ,tbrecip_apuracao_indica air 
             ,tbrecip_indica_calculo  icr 
             ,tbrecip_indicador       idr
        WHERE apr.idapuracao_reciproci = pr_idapurac
          AND apr.idconfig_recipro     = crp.idcalculo_reciproci
          AND apr.idapuracao_reciproci = air.idapuracao_reciproci
          AND crp.idcalculo_reciproci  = icr.idcalculo_reciproci
          AND air.idindicador          = icr.idindicador
          AND icr.idindicador          = idr.idindicador;

      -- Variaveis
      vr_xml_temp VARCHAR2(32726) := '';
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Inicializa variavel
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Buscar calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat; 

      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<raiz>');

      -- Busca os indicadores
      FOR rw_indicador IN cr_indicador(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idapurac => pr_idapurac
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
          GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<indicador>'
                                                    || '  <nmindicador>'||rw_indicador.nmindicador||'</nmindicador>'
                                                    || '  <tpindicador>'||rw_indicador.tpindicador||'</tpindicador>'
                                                    || '  <vlcontrata>'||RCIP0001.fn_format_valor_indicador(rw_indicador.idindicador,rw_indicador.vlcontrata)||'</vlcontrata>'
                                                    || '  <vlrealizado>'||RCIP0001.fn_format_valor_indicador(rw_indicador.idindicador,rw_indicador.vlrealizado)||'</vlrealizado>'
                                                    || '</indicador>');
      END LOOP;

      -- Encerrar a tag raiz
      GENE0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina RCIP0001.pc_indicadores_ib: '||SQLERRM;
    END;

  END pc_indicadores_ib;


END rcip0001;
/
