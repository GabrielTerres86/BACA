CREATE OR REPLACE PACKAGE CECRED.RECP0002 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : RECP0002
  --  Sistema  : Rotinas referentes ao WebService de Acordos
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho - 2016.                   Ultima atualizacao: 29/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----- 
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Acordos
  --
  -- Alteracoes: 19/09/2016 - Alterado soma de saldo da procedure pc_calcula_saldo_contrato,
  --     					            Prj. 302 (Jean Michel).
  --
  --             19/09/2016 - Incluido ROLLBACK na exceptio vr_exc_erro_det da procedure 
  --						              pc_cancelar_acordo, Prj. 302 (Jean Michel). 
  --
  --             19/09/2016 - Alterar o parâmetro “pr_nrcontrato” para VARCHAR2 da procedure
  --                          pc_consultar_saldo_contrato, Prj. 302 (Jean Michel).
  --
  --             19/09/2016 - Incluida validacao de contratos JUDICIAL/EXTRA-JUDICIAL na
  --                          procedure pc_gerar_acordo, Prj. 302 (Jean Michel). 
  --
  --             19/09/2016 - 19/09/2016 - Incluido novo parametro pr_dtcancel na
  --                          procedure pc_cancelar_acordo, Prj. 302 (Jean Michel).             
  --
  --             29/09/2016 - Incluida validacao de contratos de acordos na procedure
  --                          pc_gerar_acordo, Prj. 302 (Jean Michel).
  --             
  ---------------------------------------------------------------------------
  
  TYPE typ_rec_parcelas 
       IS RECORD (nrparcel INTEGER,
                  vltitulo crapcob.vltitulo%TYPE, 
                  vljurdia crapcob.vljurdia%TYPE,
                  vlrmulta crapcob.vlrmulta%TYPE,
                  vlroutro crapcob.vlrmulta%TYPE,
                  dtvencto crapcob.dtvencto%TYPE);
  TYPE typ_tab_parcelas IS TABLE OF typ_rec_parcelas
       INDEX BY PLS_INTEGER;
  
  --> Retornar o saldo do contrado do cooperado
  PROCEDURE pc_consultar_saldo_contrato(pr_nrgrupo    IN  NUMBER,       --> Número do Grupo
                                        pr_nrcontrato IN  VARCHAR2,     --> Número do Contrato
                                        pr_vlsdeved   OUT NUMBER,       --> Valor Saldo Devedor
                                        pr_vlsdprej   OUT NUMBER,       --> Valor Saldo Prejuizo
                                        pr_vlatraso   OUT NUMBER,       --> Valor Atraso
                                        pr_cdcritic   OUT NUMBER,       --> Código da Crítica
                                        pr_dscritic   OUT VARCHAR2,     --> Descrição da Crítica
                                        pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica
  
  --> Retornar o saldo dos contratos do CPF/CNPJ informado
  PROCEDURE pc_consultar_saldo_cooperado (pr_inPessoa    IN INTEGER,       --> Tipo de pessoa
                                          pr_nrcpfcgc    IN  NUMBER,       --> Número do CPF/CNPJ
                                          pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                          pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                          pr_dscritic   OUT VARCHAR2,     --> Descrição da Crítica
                                          pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica
                                          
  --> Rotina responsavel por gerar acordo e criar os boletos
  PROCEDURE pc_gerar_acordo (pr_xmlrequi    IN  xmltype,      --> XML de Requisição
                             pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                             pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                             pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                             pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
  
  --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_cancelar_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo
                                pr_dtcancel    IN  DATE,         --> Data de Cancelamento   
                                pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
  
  --> Rotina responsavel por retornar dados dos boletos do acordo
  PROCEDURE pc_consultar_boleto_acordo ( pr_cdcooper    IN  crapcop.cdcooper%TYPE,        --> Codigo da cooperativa
                                         pr_nrdconta    IN  crapass.nrdconta%TYPE,        --> Numero da conta
                                         pr_nracordo    IN  tbrecup_acordo.nracordo%TYPE, --> Numero do acordo
                                         pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                         pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                         pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                         pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
END RECP0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RECP0002 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : RECP0002
  --  Sistema  : Rotinas referentes ao WebService de Acordos
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho - 2016.                   Ultima atualizacao: 29/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Acordos
  --
  -- Alteracoes: 19/09/2016 - Alterado soma de saldo da procedure pc_calcula_saldo_contrato,
  --                           Prj. 302 (Jean Michel).
  --
  --             19/09/2016 - Incluido ROLLBACK na exceptio vr_exc_erro_det da procedure 
  --                          pc_cancelar_acordo, Prj. 302 (Jean Michel). 
  --
  --             19/09/2016 - Alterar o parâmetro “pr_nrcontrato” para VARCHAR2 da procedure
  --                          pc_consultar_saldo_contrato, Prj. 302 (Jean Michel).
  --
  --             19/09/2016 - Incluida validacao de contratos JUDICIAL/EXTRA-JUDICIAL na
  --                          procedure pc_gerar_acordo, Prj. 302 (Jean Michel). 
  --
  --             19/09/2016 - 19/09/2016 - Incluido novo parametro pr_dtcancel na
  --                          procedure pc_cancelar_acordo, Prj. 302 (Jean Michel).
  --
  --             29/09/2016 - Incluida validacao de contratos de acordos na procedure
  --                          pc_gerar_acordo, Prj. 302 (Jean Michel).
  --
  --             30/11/2017 - Ajuste para fixar o número de parcelar como 0 - zero ao chamar
  --                          a rotina que efetua o lançamento
  --                          (Adriano - SD 804308).
  --
  --             13/03/2018 - Chamado 806202 - ALterado update CRAPCYC para não atualizar motivos 2 e 7.
  -- 
  --             02/04/2018 - Gravar usuario cyber no cancelamento de acordo. Chamado 868775 (Heitor - Mouts)
  -- 
  --             05/06/2018 - Adicionado calculo do saldo devedor do desconto de títulos (Paulo Penteado (GFT)) 
  -- 
	--             29/10/2018 - Ajuste na "pc_cancelar_acordo" para estorno do IOF vinculado ao acordo para a 
	--                         tabela CRAPSLD (vliofmes) quando o acordo é cancelado.
	--  											 (Reginaldo - AMcom - P450)
  --
  ---------------------------------------------------------------------------
  -- Formato de retorno para numerico no xml
  vr_formtnum   VARCHAR2(30) := '99999999999990D00';
  -- Padrão do numerico no xml
  vr_pdrdonum   VARCHAR2(30) := 'NLS_NUMERIC_CHARACTERS=''.,''';
  -- Formato de retorno para data no xml
  vr_frmtdata   VARCHAR2(20) := 'DD/MM/RRRR';
  
  ---------------> CURSORES <-------------
  --> Buscar saldo do associado
  CURSOR cr_crapsld(pr_cdcooper  crapsld.cdcooper%TYPE,
                    pr_nrdconta  crapsld.nrdconta%TYPE) IS
    SELECT crapsld.vlsddisp
          ,crapsld.vliofmes
          ,crapsld.vlbasiof
      FROM crapsld
     WHERE crapsld.cdcooper = pr_cdcooper
       AND crapsld.nrdconta = pr_nrdconta;
  rw_crapsld cr_crapsld%ROWTYPE;

  PROCEDURE pc_quebra_desc_contrat(pr_nrcontrato  IN VARCHAR2,
                                   pr_cdcooper   OUT NUMBER,
                                   pr_cdorigem   OUT NUMBER,
                                   pr_nrdconta   OUT NUMBER,
                                   pr_nrctremp   OUT NUMBER )IS
  BEGIN
    
      -- Código da Cooperativa
      pr_cdcooper := substr(pr_nrcontrato,1,4);
      -- Origem
      pr_cdorigem := substr(pr_nrcontrato,5,4);
      -- Número da Conta
      pr_nrdconta := substr(pr_nrcontrato,9,8);
      -- Número do Contrato
      pr_nrctremp := substr(pr_nrcontrato,17,8);    
  
  END;
  
  --> Calcula o saldo do contrado do cooperado
  PROCEDURE pc_calcular_saldo_contrato (pr_cdcooper   IN  crapcop.cdcooper%TYPE,  --> Codigo da Cooperativa
                                        pr_nrdconta   IN  crapass.cdcooper%TYPE,  --> Número da Conta
                                        pr_cdorigem   IN  INTEGER,                --> Origem
                                        pr_nrctremp   IN  crapepr.nrctremp%TYPE,  --> Numero do Contrato
                                        pr_rw_crapdat IN  btch0001.cr_crapdat%ROWTYPE, --> Datas da cooperativa
                                        pr_vllimcre   IN crapass.vllimcre%TYPE,   --> Limite de credito do cooperado     
                                        pr_vlsdeved  OUT  NUMBER,                 --> Valor Saldo Devedor
                                        pr_vlsdprej  OUT  NUMBER,                 --> Valor Saldo Prejuizo
                                        pr_vlatraso  OUT  NUMBER,                 --> Valor Atraso
                                        pr_cdcritic  OUT  NUMBER,                 --> Código da Crítica
                                        pr_dscritic  OUT  VARCHAR2)  IS           --> Descrição da Crítica
  /* .............................................................................
   Programa: pc_calcula_saldo_contrato
   Sistema : Rotinas referentes ao WebService
   Sigla   : WEBS
   Autor   : Odirlei Busana - AMcom
   Data    : Julho/2016.                    Ultima atualizacao: 19/09/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Calcula o saldo do contrado do cooperado.

   Observacao: -----
   Alteracoes: 19/09/2016 - Alterado soma de saldo acumulado, Prj. 302 (Jean Michel).

               08/05/2018 - Inclusao dos valores de IOF provisionado ao acordo.
                            PRJ450 (Odirlei-AMcom) 

               05/06/2018 - Adicionado tratamento para saldo devedor do desconto de titulos (Paulo Penteado (GFT)) 

   ..............................................................................*/                                    
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(10000);
    vr_exc_erro    EXCEPTION;
    vr_des_reto    VARCHAR2(10000);        
    vr_tab_erro    gene0001.typ_tab_erro;
    
    vr_tab_saldos  extr0001.typ_tab_saldos;
    vr_index_saldo BINARY_INTEGER := 0;
    vr_vlsomato    NUMBER;
    
    vr_dstextab    craptab.dstextab%TYPE;
    vr_inusatab    BOOLEAN;
    vr_parempct    craptab.dstextab%TYPE;
    vr_digitali    craptab.dstextab%TYPE;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_qtregist    INTEGER;
    
    CURSOR cr_titcyb IS
    SELECT CASE
             WHEN bdt.inprejuz = 0 THEN (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof))
             ELSE 0
           END as vlsdeved    
          ,CASE
             WHEN bdt.inprejuz = 1 THEN nvl(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr) + (tdb.vlttmupr - tdb.vlpgmupr) + (tdb.vljraprj - tdb.vlpgjrpr) + (tdb.vliofprj - tdb.vliofppr),0)
             ELSE 0
           END as vlsdprej
          ,CASE
             WHEN bdt.inprejuz = 0 THEN (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof))
             ELSE 0
           END as vlatraso
    FROM   craptdb tdb
          ,tbdsct_titulo_cyber titcyb
          ,crapbdt bdt
    WHERE  tdb.dtresgat    IS NULL
    AND    tdb.dtlibbdt    IS NOT NULL
    AND    tdb.dtdpagto    IS NULL
    AND    bdt.nrborder    = tdb.nrborder
    AND    bdt.nrdconta    = tdb.nrdconta
    AND    bdt.cdcooper    = tdb.cdcooper
    AND    tdb.nrtitulo    = titcyb.nrtitulo
    AND    tdb.nrborder    = titcyb.nrborder
    AND    tdb.nrdconta    = titcyb.nrdconta
    AND    tdb.cdcooper    = titcyb.cdcooper
    AND    titcyb.nrctrdsc = pr_nrctremp
    AND    titcyb.nrdconta = pr_nrdconta
    AND    titcyb.cdcooper = pr_cdcooper;
    rw_titcyb cr_titcyb%ROWTYPE;
    
		-- Busca dados do prejuízo  de conta corrente para compor saldo do prejuízo
		CURSOR cr_prejuizo IS
		SELECT prj.vlsdprej
		     , prj.vljuprej
				 , prj.vljur60_ctneg
				 , prj.vljur60_lcred
		  FROM tbcc_prejuizo prj
		 WHERE prj.cdcooper = pr_cdcooper
		   AND prj.nrdconta = pr_nrdconta
			 AND prj.dtliquidacao IS NULL;
		rw_prejuizo cr_prejuizo%ROWTYPE;

		-- Busca os dados de cartoes
		CURSOR cr_cartoes(pr_cdcooper crapcyb.cdcooper%TYPE
		                 ,pr_nrdconta crapcyb.nrdconta%TYPE
										 ,pr_nrctremp crapcyb.nrctremp%TYPE
		                 ) IS
		  SELECT c.vlsdeved
						,0 vlsdprej
						,c.vlpreapg  vlatraso
			  FROM crapcyb c 
			 WHERE c.cdcooper = pr_cdcooper
				 AND c.nrdconta = pr_nrdconta
				 AND c.nrctremp = pr_nrctremp
				 AND c.cdorigem = 5; -- Cartoes
    --
		rw_cartoes cr_cartoes%ROWTYPE;
		--
  BEGIN
      
    ---> ESTOURO DE CONTA <---
    IF pr_cdorigem = 1 THEN
			--> Buscar saldo do associado
      OPEN cr_crapsld(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrdconta);
      FETCH cr_crapsld INTO rw_crapsld;
      CLOSE cr_crapsld;
			
			OPEN cr_prejuizo;
			FETCH cr_prejuizo INTO rw_prejuizo;
			
			IF cr_prejuizo%NOTFOUND THEN
      --Limpar tabela saldos
      vr_tab_saldos.DELETE;      
      --Obter Saldo do Dia
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_cdagenci   => 1 
                                 ,pr_nrdcaixa   => 1 
                                 ,pr_cdoperad   => '1'
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => pr_vllimcre
                                 ,pr_dtrefere   => pr_rw_crapdat.dtmvtolt
                                 ,pr_des_reto   => vr_des_reto                               
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_flgcrass   => FALSE
                                 ,pr_tab_erro   => vr_tab_erro);    
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 983; -- Não foi possivel calcular o saldo devedor
        END IF;
        --Sair com erro
        RAISE vr_exc_erro;
      END IF;
        
      --Buscar Indice
      vr_index_saldo := vr_tab_saldos.FIRST;
      IF vr_index_saldo IS NOT NULL THEN
        -- Acumular Saldo
        vr_vlsomato := ROUND( nvl(vr_tab_saldos(vr_index_saldo).vlsddisp, 0),2);
      END IF;
      
				--> Incrementar valor iof Calculado até o dia atual
				IF rw_crapsld.vliofmes > 0 THEN
					vr_vlsomato := nvl(vr_vlsomato,0) - ROUND( nvl(rw_crapsld.vliofmes, 0),2);
				END IF;

      IF vr_vlsomato < 0 THEN
        -- Saldo Devedor
        pr_vlsdeved := ABS(vr_vlsomato);
        -- Saldo Prejuizo
        pr_vlsdprej := 0;
        -- Valor em Atraso
        pr_vlatraso := ABS(vr_vlsomato);
      END IF;
			ELSE
				vr_vlsomato := nvl(rw_prejuizo.vlsdprej,0) + nvl(rw_prejuizo.vljuprej,0) + 
				               nvl(rw_prejuizo.vljur60_ctneg,0) + nvl(rw_prejuizo.vljur60_lcred,0) +
											 PREJ0003.fn_juros_remun_prov(pr_cdcooper, pr_nrdconta);
											 
				IF rw_crapsld.vliofmes > 0 THEN
					vr_vlsomato := nvl(vr_vlsomato,0) + rw_crapsld.vliofmes;
				END IF;
				
				pr_vlsdeved := 0;
				pr_vlsdprej := vr_vlsomato;
				pr_vlatraso := 0;
			END IF;
			
			CLOSE cr_prejuizo;
      
    ---> EMPRESTIMO <---
    ELSIF pr_cdorigem IN (2,3) THEN
    
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posição do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- É porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- Não existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- Não existe
        vr_inusatab := FALSE;
      END IF;
          
      -- Leitura do indicador de uso da tabela de taxa de juros                                                    
      vr_parempct := tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 1);       
                                                 
      -- busca o tipo de documento GED    
      vr_digitali := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'DIGITALIZA'
                                               ,pr_tpregist => 5);                                               
                                                 
      vr_tab_dados_epr.delete;
      
      -- Busca saldo total de emprestimos
      EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdagenci => 1                   --> Código da agência
                                      ,pr_nrdcaixa => 1                   --> Número do caixa
                                      ,pr_cdoperad => '1'                 --> Código do operador
                                      ,pr_nmdatela => 'WEBSERVICE'        --> Nome datela conectada
                                      ,pr_idorigem => 9                   --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                      ,pr_idseqttl => 1 -- pr_idseqttl    --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => pr_rw_crapdat     --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                      ,pr_nrctremp => pr_nrctremp         --> Número contrato empréstimo
                                      ,pr_cdprogra => 'WEBSERVICE'        --> Programa conectado
                                      ,pr_inusatab => vr_inusatab         --> Indicador de utilização da tabela
                                      ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                      ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => ' '                 --> Nome Primeiro Titular
                                      ,pr_tab_parempctl => vr_parempct    --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_digitali   --> Dados tabela parametro
                                      ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                      ,pr_nrregist => 0                   --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                      ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros

      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 983; -- Não foi possivel calcular o saldo devedor
        END IF;
        --Sair com erro
        RAISE vr_exc_erro;
      END IF;
    
      -- Condicao para verificar se encontrou contrato de emprestimo
      IF vr_tab_dados_epr.COUNT > 0 THEN
        -- Saldo Devedor
        pr_vlsdeved := nvl(vr_tab_dados_epr(1).vlsdeved,0) + nvl(vr_tab_dados_epr(1).vlmtapar,0) 
                     + nvl(vr_tab_dados_epr(1).vlmrapar,0) + nvl(vr_tab_dados_epr(1).vliofcpl,0);
        -- Saldo Prejuizo
        pr_vlsdprej := nvl(vr_tab_dados_epr(1).vlsdprej,0);
        -- Valor em Atraso
        pr_vlatraso := nvl(vr_tab_dados_epr(1).vltotpag,0);
      END IF;
        
    ---> DESCONTO DE TITULO <---
    ELSIF pr_cdorigem = 4 THEN
          OPEN  cr_titcyb;
          FETCH cr_titcyb INTO rw_titcyb;
          IF    cr_titcyb%FOUND THEN
                -- Saldo Devedor
                pr_vlsdeved := rw_titcyb.vlsdeved;
                -- Saldo Prejuizo
                pr_vlsdprej := rw_titcyb.vlsdprej;
                -- Valor em Atraso
                pr_vlatraso := rw_titcyb.vlatraso;
          END   IF;
          CLOSE cr_titcyb;
		-- CARTOES
		ELSIF pr_cdorigem = 5 THEN
			--
			OPEN cr_cartoes(pr_cdcooper
		                 ,pr_nrdconta
										 ,pr_nrctremp
		                 );
			--
			FETCH cr_cartoes INTO rw_cartoes;
			--
			IF cr_cartoes%NOTFOUND THEN
				--
				vr_cdcritic := 983;
				RAISE vr_exc_erro;
				--
    END IF;
			-- Saldo Devedor
			pr_vlsdeved := rw_cartoes.vlsdeved;
			-- Saldo Prejuizo
			pr_vlsdprej := rw_cartoes.vlsdprej;
			-- Valor em Atraso
			pr_vlatraso := rw_cartoes.vlatraso;
			--
			CLOSE cr_cartoes;
			--
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN    
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);          
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel calcular saldo do contrato '||pr_nrctremp||': '||SQLERRM;      
      
  END pc_calcular_saldo_contrato;  
  
  --> Retornar o saldo do contrado do cooperado
  PROCEDURE pc_consultar_saldo_contrato(pr_nrgrupo    IN  NUMBER,       --> Número do Grupo
                                        pr_nrcontrato IN  VARCHAR2,     --> Número do Contrato
                                        pr_vlsdeved   OUT NUMBER,       --> Valor Saldo Devedor
                                        pr_vlsdprej   OUT NUMBER,       --> Valor Saldo Prejuizo
                                        pr_vlatraso   OUT NUMBER,       --> Valor Atraso
                                        pr_cdcritic   OUT NUMBER,       --> Código da Crítica
                                        pr_dscritic   OUT VARCHAR2,     --> Descrição da Crítica
                                        pr_dsdetcri   OUT VARCHAR2)  IS --> Detalhe da critica
  /* .............................................................................
   Programa: pc_consultar_saldo_contrato
   Sistema : Rotinas referentes ao WebService
   Sigla   : WEBS
   Autor   : Odirlei Busana - AMcom
   Data    : Julho/2016.                    Ultima atualizacao: 19/09/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Retornar o saldo do contrado do cooperado.

   Observacao: -----
   Alteracoes: 19/09/2016 - Alterar o parâmetro “pr_nrcontrato” para VARCHAR2,
							Prj. 302 (Jean Michel).
   ..............................................................................*/                                    
    
    ---------------> CURSORES <-------------
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
    
    --> Buscar contrado no cyber
    CURSOR cr_crapcyb (pr_cdcooper  crapcyb.cdcooper%TYPE,
                       pr_nrdconta  crapcyb.nrdconta%TYPE,
                       pr_nrctremp  crapcyb.nrctremp%TYPE,
                       pr_cdorigem  crapcyb.cdorigem%TYPE) IS
      SELECT 1
        FROM crapcyb
       WHERE crapcyb.cdcooper = pr_cdcooper
         AND crapcyb.nrdconta = pr_nrdconta
         AND crapcyb.nrctremp = pr_nrctremp
         AND crapcyb.cdorigem = pr_cdorigem;
    rw_crapcyb cr_crapcyb%ROWTYPE;
    
    --> Buscar cooperado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
         
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic   VARCHAR2(10000);
    vr_cdcritic   INTEGER;    
    vr_exc_erro   EXCEPTION;
    vr_exc_erro_det EXCEPTION;
    
    vr_cdcooper   crapcop.cdcooper%TYPE;
    vr_cdorigem   INTEGER;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_nrctremp   crapepr.nrctremp%TYPE;
    
  BEGIN
      
    IF pr_nrcontrato IS NOT NULL THEN
      pc_quebra_desc_contrat(pr_nrcontrato => pr_nrcontrato,
                             pr_cdcooper   => vr_cdcooper,
                             pr_cdorigem   => vr_cdorigem,
                             pr_nrdconta   => vr_nrdconta,
                             pr_nrctremp   => vr_nrctremp);
    ELSE
      vr_cdcritic := 484; --> Contrato não encontrado
      RAISE vr_exc_erro;  
    END IF;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
        
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN      
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := 'Sistema sem data de movimento, tente novamente mais tarde';
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    IF nvl(rw_crapdat.inproces,0) <> 1 THEN
      vr_dscritic := 'Processo da Cooperativa nao finalizou, tente novamente mais tarde';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar contrado no cyber
    OPEN cr_crapcyb (pr_cdcooper  => vr_cdcooper,
                     pr_nrdconta  => vr_nrdconta,
                     pr_nrctremp  => vr_nrctremp,
                     pr_cdorigem  => vr_cdorigem);
    FETCH cr_crapcyb INTO rw_crapcyb;
    IF cr_crapcyb%NOTFOUND THEN
      CLOSE cr_crapcyb;
      vr_cdcritic := 484; --> Contrato não encontrado
      RAISE vr_exc_erro;  
    END IF;
    CLOSE cr_crapcyb;
    
    --> Buscar cooperado
    OPEN cr_crapass (pr_cdcooper  => vr_cdcooper,
                     pr_nrdconta  => vr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --> 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;  
    END IF;
    CLOSE cr_crapass;
    
    --> Calcula o saldo do contrado do cooperado
    pc_calcular_saldo_contrato (pr_cdcooper   => vr_cdcooper,        --> Codigo da Cooperativa
                                pr_nrdconta   => vr_nrdconta,        --> Número da Conta
                                pr_cdorigem   => vr_cdorigem,        --> Origem
                                pr_nrctremp   => vr_nrctremp,        --> Numero do Contrato
                                pr_rw_crapdat => rw_crapdat,         --> Datas da cooperativa
                                pr_vllimcre   => rw_crapass.vllimcre,--> Limite de credito do cooperado     
                                pr_vlsdeved   => pr_vlsdeved,        --> Valor Saldo Devedor
                                pr_vlsdprej   => pr_vlsdprej,        --> Valor Saldo Prejuizo
                                pr_vlatraso   => pr_vlatraso,        --> Valor Atraso
                                pr_cdcritic   => vr_cdcritic,        --> Código da Crítica
                                pr_dscritic   => vr_dscritic);       --> Descrição da Crítica
    
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN       
      RAISE vr_exc_erro_det;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro_det THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      --> Apenas critica generica e detalhe critica em outro parametro        
      pr_cdcritic := 983;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 983);
      pr_dsdetcri := vr_dscritic;
    
    WHEN vr_exc_erro THEN    
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||': '||vr_dscritic; 
      END IF;
      
      IF NVL(vr_cdcritic,0) = 0 THEN
        vr_cdcritic := 983;
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_dsdetcri := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 983;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      pr_dscritic := vr_dscritic;      
      pr_dsdetcri := SQLERRM;      
      
  END pc_consultar_saldo_contrato;
  
  --> Retornar o saldo dos contratos do CPF/CNPJ informado
  PROCEDURE pc_consultar_saldo_cooperado (pr_inPessoa    IN INTEGER,       --> Tipo de pessoa
                                          pr_nrcpfcgc    IN  NUMBER,       --> Número do CPF/CNPJ
                                          pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                          pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                          pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                          pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
  /* .............................................................................
   Programa: pc_consultar_saldo_cooperado
   Sistema : Rotinas referentes ao WebService
   Sigla   : WEBS
   Autor   : Odirlei Busana - AMcom
   Data    : Julho/2016.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Retornar o saldo dos contratos do CPF/CNPJ informado

   Observacao: -----
   Alteracoes:
   ..............................................................................*/                                    
    
    ---------------> CURSORES <-------------
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
    
    --> Buscar contrado no cyber
    CURSOR cr_crapcyb (pr_cdcooper crapcyb.cdcooper%TYPE,
                       pr_nrdconta crapcyb.nrdconta%TYPE,
                       pr_dtmvtolt crapcyb.dtmvtolt%TYPE) IS
      SELECT cyb.nrctremp,
             cyb.cdorigem
        FROM crapcyb cyb
       WHERE cyb.cdcooper = pr_cdcooper
         AND cyb.nrdconta = pr_nrdconta
         and (cyb.dtdbaixa IS NULL OR cyb.dtdbaixa > ADD_MONTHS(pr_dtmvtolt,-1));
    rw_crapcyb cr_crapcyb%ROWTYPE;
    
    --> Buscar cooperado
    CURSOR cr_crapass (pr_inpessoa  crapass.inpessoa%TYPE,
                       pr_nrcpfcgc  crapass.nrcpfcgc%TYPE) IS
      SELECT ass.cdcooper,
             ass.nrdconta,
             ass.vllimcre
        FROM crapass ass
       WHERE ass.inpessoa = pr_inpessoa
         AND ass.nrcpfcgc = pr_nrcpfcgc
       ORDER BY ass.cdcooper;
         
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic   VARCHAR2(10000);
    vr_cdcritic   INTEGER;    
    vr_exc_erro   EXCEPTION;
    vr_exc_erro_det EXCEPTION;
    
    vr_cdcooper   crapcop.cdcooper%TYPE;
    
    vr_vlsdeved   NUMBER;
    vr_vlsdprej   NUMBER;
    vr_vlatraso   NUMBER;
    
    vr_fcrapass   BOOLEAN;
    vr_fcrapcyb   BOOLEAN;
    
    vr_dsctremp   VARCHAR2(50);
    
    -- Variáveis para armazenar as informações em XML
    vr_dscdoxml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dscdoxml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
      
    vr_cdcooper := 0; 
    
    -- Inicializar o CLOB
    vr_dscdoxml := NULL;
    dbms_lob.createtemporary(vr_dscdoxml, TRUE);
    dbms_lob.open(vr_dscdoxml, dbms_lob.lob_readwrite);
    
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><contratos>');
    vr_fcrapass := FALSE;
    vr_fcrapcyb := FALSE;
        
    --> Buscar contas que possuem este CPF/CNPJ
    FOR rw_crapass IN cr_crapass(pr_inPessoa => pr_inPessoa,
                                 pr_nrcpfcgc => pr_nrcpfcgc ) LOOP    
      
      vr_fcrapass := TRUE;
      
      --> Buscar contrado no cyber
      FOR rw_crapcyb IN cr_crapcyb(pr_cdcooper => rw_crapass.cdcooper,
                                   pr_nrdconta => rw_crapass.nrdconta,
                                   pr_dtmvtolt => TRUNC(SYSDATE))LOOP      
        vr_fcrapcyb := TRUE;
        --> Buscar da data da cooperativa caso tenha mudado
        IF vr_cdcooper <> rw_crapass.cdcooper THEN 
          vr_cdcooper := rw_crapass.cdcooper;
          -- Leitura do calendário da cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
              
          -- Se não encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN      
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_dscritic := 'Sistema sem data de movimento, tente novamente mais tarde';
            RAISE vr_exc_erro;
          ELSE
            CLOSE btch0001.cr_crapdat;
          END IF;
          
          IF nvl(rw_crapdat.inproces,0) <> 1 THEN
            vr_dscritic := 'Processo da Cooperativa nao finalizou, tente novamente mais tarde';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        vr_vlsdeved := 0;
        vr_vlsdprej := 0;
        vr_vlatraso := 0;
        
        --> Calcula o saldo do contrado do cooperado
        pc_calcular_saldo_contrato (pr_cdcooper   => rw_crapass.cdcooper,        --> Codigo da Cooperativa
                                    pr_nrdconta   => rw_crapass.nrdconta,        --> Número da Conta
                                    pr_cdorigem   => rw_crapcyb.cdorigem,        --> Origem
                                    pr_nrctremp   => rw_crapcyb.nrctremp,        --> Numero do Contrato
                                    pr_rw_crapdat => rw_crapdat,         --> Datas da cooperativa
                                    pr_vllimcre   => rw_crapass.vllimcre,--> Limite de credito do cooperado     
                                    pr_vlsdeved   => vr_vlsdeved,        --> Valor Saldo Devedor
                                    pr_vlsdprej   => vr_vlsdprej,        --> Valor Saldo Prejuizo
                                    pr_vlatraso   => vr_vlatraso,        --> Valor Atraso
                                    pr_cdcritic   => vr_cdcritic,        --> Código da Crítica
                                    pr_dscritic   => vr_dscritic);       --> Descrição da Crítica        
        
        IF nvl(vr_cdcritic,0) > 0 OR  
           TRIM(vr_dscritic) IS NOT NULL THEN           
          RAISE vr_exc_erro_det;   
        END IF;
        
        vr_dsctremp := LPAD(rw_crapass.cdcooper,4,'0') || LPAD(rw_crapcyb.cdorigem,4,'0') || 
                       LPAD(rw_crapass.nrdconta,8,'0') || LPAD(rw_crapcyb.nrctremp,8,'0');
        
        pc_escreve_xml('<contrato>'||
                         '<Numero>'       || vr_dsctremp                                  || '</Numero>'       ||
                         '<Grupo>'        || '1'                                          || '</Grupo>'        ||
                         '<SaldoDevedor>' || to_char(nvl(vr_vlsdeved,0),vr_formtnum,vr_pdrdonum) || '</SaldoDevedor>' ||
                         '<SaldoPrejuizo>'|| to_char(nvl(vr_vlsdprej,0),vr_formtnum,vr_pdrdonum) || '</SaldoPrejuizo>'||
                         '<ValorAtraso>'  || to_char(nvl(vr_vlatraso,0),vr_formtnum,vr_pdrdonum) || '</ValorAtraso>'  ||
                       '</contrato>');
      
      END LOOP; --> Fim loop crapcyb  
    END LOOP;   --> Fim loop crapass
    
    IF vr_fcrapass = FALSE THEN
      vr_cdcritic := 9; --> Associado não encontrado
      RAISE vr_exc_erro; 
    END IF;
    
    IF vr_fcrapcyb = FALSE THEN
      vr_cdcritic := 484; --> 484 - Contrato nao encontrado.
      RAISE vr_exc_erro; 
    END IF;
    
    -- Finalizar xml
    pc_escreve_xml('</contratos>',TRUE);
    pr_xmlrespo := XMLType.createxml(vr_dscdoxml);    
    
  EXCEPTION
    WHEN vr_exc_erro_det THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      --> Apenas critica generica e detalhe critica em outro parametro        
      pr_cdcritic := 983;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 983);
      pr_dsdetcri := vr_dscritic;
      
    WHEN vr_exc_erro THEN
    
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||': '||vr_dscritic; 
      END IF;
      
      IF NVL(vr_cdcritic,0) = 0 THEN
        vr_cdcritic := 983;
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_dsdetcri := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 983;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      pr_dscritic := vr_dscritic;      
      pr_dsdetcri := SQLERRM; 
      
      
  END pc_consultar_saldo_cooperado;    
  
  --> Rotina para gravar os contratos do acordo
  PROCEDURE pc_gravar_contrato_acordo ( pr_nracordo   IN NUMBER,                  --> Numero do acordo
                                        pr_cdcooper   IN  crapcop.cdcooper%TYPE,  --> Codigo da Cooperativa
                                        pr_nrdconta   IN  crapass.cdcooper%TYPE,  --> Número da Conta
                                        pr_cdorigem   IN  INTEGER,                --> Origem
                                        pr_nrctremp   IN  crapepr.nrctremp%TYPE,  --> Numero do Contrato
                                        pr_nrdgrupo   IN INTEGER,                 --> Numero do grupo do contrato
                                        pr_cdcritic  OUT  NUMBER,                 --> Código da Crítica
                                        pr_dscritic  OUT  VARCHAR2)  IS           --> Descrição da Crítica
  
  /* .............................................................................
   Programa: pc_gravar_contrato_acordo
   Sistema : Rotinas referentes ao WebService
   Sigla   : WEBS
   Autor   : Odirlei Busana - AMcom
   Data    : Julho/2016.                    Ultima atualizacao: 30/01/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina para gravar os contratos do acordo

   Observacao: -----
   Alteracoes: 30/01/2017 - Nao permitir gerar boleto para Pos-Fixado. (Jaison/James - PRJ298)

               08/05/2018 - Inclusao dos valores de IOF provisionado ao acordo.
                            PRJ450 (Odirlei-AMcom)

			   26/09/2018 - Retirado a crítica para pós-fixado de forma a atender os requisitos do projeto PRJ298.2 (Adriano Nagasava - Supero)

   ..............................................................................*/                                    
   
    ---------------> CURSORES <-------------
    
    --> Buscar contrado no cyber
    CURSOR cr_crapcyb (pr_cdcooper  crapcyb.cdcooper%TYPE,
                       pr_nrdconta  crapcyb.nrdconta%TYPE,
                       pr_nrctremp  crapcyb.nrctremp%TYPE,
                       pr_cdorigem  crapcyb.cdorigem%TYPE) IS
      SELECT 1
        FROM crapcyb
       WHERE crapcyb.cdcooper = pr_cdcooper
         AND crapcyb.nrdconta = pr_nrdconta
         AND crapcyb.nrctremp = pr_nrctremp
         AND crapcyb.cdorigem = pr_cdorigem;
    rw_crapcyb cr_crapcyb%ROWTYPE;
    
    --> Buscar dados emprestimo
    CURSOR cr_crapepr (pr_cdcooper  crapcyb.cdcooper%TYPE,
                       pr_nrdconta  crapcyb.nrdconta%TYPE,
                       pr_nrctremp  crapcyb.nrctremp%TYPE) IS
    
      SELECT tpdescto
            ,tpemprst
            ,inprejuz
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
    
    --> Verificar se o contrato ja esta em algum acordo ativo
    CURSOR cr_tbrecup_contrato(pr_cdcooper  crapass.cdcooper%TYPE,
                              pr_nrdconta  crapass.nrdconta%TYPE,
                              pr_nrctremp  crapepr.nrctremp%TYPE,
                              pr_nrgrupo   INTEGER,
                              pr_cdorigem  crapcyb.cdorigem%TYPE) IS
     SELECT 1 
       FROM tbrecup_acordo_contrato contrato
       JOIN tbrecup_acordo acordo
         ON acordo.nracordo   = contrato.nracordo
      WHERE acordo.cdcooper   = pr_cdcooper
        AND acordo.nrdconta   = pr_nrdconta
        AND contrato.nrctremp = pr_nrctremp
        AND contrato.nrgrupo  = pr_nrgrupo
        AND contrato.cdorigem = pr_cdorigem
        AND acordo.cdsituacao = 1;
    rw_contrato cr_tbrecup_contrato%ROWTYPE;   
      
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic   VARCHAR2(10000);
    vr_cdcritic   INTEGER;
    vr_exc_erro   EXCEPTION;
    vr_vliofdev   NUMBER;
    vr_vlbasiof   NUMBER;
    
  BEGIN
  
    --> Buscar contrado no cyber
    OPEN cr_crapcyb (pr_cdcooper  => pr_cdcooper,
                     pr_nrdconta  => pr_nrdconta,
                     pr_nrctremp  => pr_nrctremp,
                     pr_cdorigem  => pr_cdorigem);
    FETCH cr_crapcyb INTO rw_crapcyb;
    IF cr_crapcyb%NOTFOUND THEN
      CLOSE cr_crapcyb;
      vr_cdcritic := 484; --> Contrato não encontrado
      RAISE vr_exc_erro;  
    END IF;
    CLOSE cr_crapcyb;  
    
    --> Buscar dados emprestimo
    OPEN cr_crapepr (pr_cdcooper  => pr_cdcooper,
                     pr_nrdconta  => pr_nrdconta,
                     pr_nrctremp  => pr_nrctremp);
    FETCH cr_crapepr INTO rw_crapepr;
      CLOSE cr_crapepr;

    -- Operacao nao permitida para emprestimos consignados
    IF rw_crapepr.tpdescto = 2 AND NVL(rw_crapepr.inprejuz,0) = 0 THEN
      vr_cdcritic := 987;
      RAISE vr_exc_erro;  
    END IF;
    
    --> Verificar se o contrato ja esta em algum acordo ativo
    OPEN cr_tbrecup_contrato (pr_cdcooper  => pr_cdcooper,
                            pr_nrdconta  => pr_nrdconta,
                            pr_nrctremp  => pr_nrctremp,
                            pr_nrgrupo   => pr_nrdgrupo ,
                            pr_cdorigem  => pr_cdorigem);
    FETCH cr_tbrecup_contrato INTO rw_contrato;
    IF cr_tbrecup_contrato%FOUND THEN
      CLOSE cr_tbrecup_contrato;
      vr_cdcritic := 988; -- Já existe acordo para este contrato;
      RAISE vr_exc_erro;  
    END IF;
    CLOSE cr_tbrecup_contrato;
   
    vr_vliofdev := 0;
    vr_vlbasiof := 0;
    -- Se a origem estiver indicando ESTOURO DE CONTA
    IF pr_cdorigem = 1 THEN

      --> Buscar saldo do associado
      OPEN cr_crapsld(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrdconta);
      FETCH cr_crapsld INTO rw_crapsld;
      CLOSE cr_crapsld;

      --------------------------------------------------------------------------------------------------
      -- Atualizar os dados do IOF
      --------------------------------------------------------------------------------------------------
      TIOF0001.pc_altera_iof(pr_cdcooper   => pr_cdcooper
                            ,pr_nrdconta   => pr_nrdconta
                            ,pr_dtmvtolt   => NULL
                            ,pr_tpproduto  => 5
                            ,pr_nrcontrato => 0
                            ,pr_nracordo   => pr_nracordo
                            ,pr_cdcritic   => vr_cdcritic
                            ,pr_dscritic   => vr_dscritic);

      -- Condicao para verificar se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      --> Buscar valor iof Calculado até o dia atual
      vr_vliofdev := rw_crapsld.vliofmes;
      vr_vlbasiof := rw_crapsld.vlbasiof;

      --> Atualizar crapsld
      BEGIN
        UPDATE crapsld sld
           SET sld.vliofmes = 0,
               sld.vlbasiof = 0
         WHERE sld.cdcooper = pr_cdcooper
           AND sld.nrdconta = pr_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar valor do IOF na crapsld: '||SQLERRM;
          --Sair do programa
          RAISE vr_exc_erro;
      END;

    END IF;

    --> Gravar contrato
    BEGIN
      INSERT INTO tbrecup_acordo_contrato
                   (nracordo, 
                    nrgrupo, 
                    cdorigem, 
                    nrctremp,
                    vliofdev,
                    vlbasiof)
             VALUES(pr_nracordo, --> nracordo
                    pr_nrdgrupo, --> nrgrupo  
                    pr_cdorigem, --> cdorigem 
                    pr_nrctremp, --> nrctrem
                    vr_vliofdev, --> vliofdev
                    vr_vlbasiof);--> vlbasiof

    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao gravar contrato de acordo: '||SQLERRM;
        RAISE vr_exc_erro;  
    END;
    
  EXCEPTION
    WHEN vr_exc_erro THEN          
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel gravar contrato do acordo '||pr_nrctremp||': '||SQLERRM;      
  END pc_gravar_contrato_acordo;
  
  --> Rotina para gerar os boletos e gravar as parcelas
  PROCEDURE pc_gravar_parcela ( pr_nracordo     IN NUMBER,                 --> Numero do acordo
                                pr_cdcooper     IN crapcop.cdcooper%TYPE,  --> Codigo da Cooperativa
                                pr_nrdconta     IN crapass.cdcooper%TYPE,  --> Número da Conta
                                pr_nrdconta_cob IN crapcob.nrdconta%TYPE,  --> Número da Conta da cobrança
                                pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE,  --> Numero do convenio de cobranca
                                pr_inpessoa     IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                pr_nrcpfcgc     IN crapass.nrcpfcgc%TYPE,  --> Numero do cpf/cnpj do cooperado
                                pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                
                                pr_tab_parcelas typ_tab_parcelas,          --> Parcelas a serem processadas
                                pr_xmlbolet    OUT  xmltype,               --> Xml de retorno dos boletos gerados 
                                pr_cdcritic    OUT  NUMBER,                --> Código da Crítica
                                pr_dscritic    OUT  VARCHAR2)  IS          --> Descrição da Crítica
  
   /* .............................................................................
    Programa: pc_gravar_parcela
    Sistema : Rotinas referentes ao WebService
    Sigla   : WEBS
    Autor   : Odirlei Busana - AMcom
    Data    : Julho/2016.                    Ultima atualizacao: 21/07/2016 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar os boletos e gravar as parcelas

    Observacao: -----
    Alteracoes:
    ..............................................................................*/                                    
   
    ---------------> CURSORES <-------------
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic   VARCHAR2(10000);
    vr_cdcritic   INTEGER;
    vr_exc_erro   EXCEPTION;
    
    vr_tab_cob    cobr0005.typ_tab_cob;
    vr_idxcob     PLS_INTEGER;
    
    -- Variáveis para armazenar as informações em XML
    vr_dscdoxml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dscdoxml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
    
    IF pr_tab_parcelas.count = 0 THEN
      vr_cdcritic := 989; -- Nenhuma parcela encontrada.
      RAISE vr_exc_erro;
    END IF;
    
    -- Inicializar o CLOB
    vr_dscdoxml := NULL;
    dbms_lob.createtemporary(vr_dscdoxml, TRUE);
    dbms_lob.open(vr_dscdoxml, dbms_lob.lob_readwrite);
    
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><boletos>');
    
    
    --> Varrer parcelas
    FOR idx IN pr_tab_parcelas.first..pr_tab_parcelas.last LOOP
      -- Procedure para a gera
      cobr0005.pc_gerar_titulo_cobranca(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta_cob
                                       ,pr_nrcnvcob => pr_nrcnvcob
                                       ,pr_inemiten => 2
                                       ,pr_cdbandoc => 085
                                       ,pr_cdcartei => 1
                                       ,pr_cddespec => 1
                                       ,pr_nrctasac => pr_nrdconta
                                       ,pr_cdtpinsc => pr_inpessoa
                                       ,pr_nrinssac => pr_nrcpfcgc
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dtdocmto => pr_dtmvtolt
                                       ,pr_dtvencto => pr_tab_parcelas(idx).dtvencto
                                       ,pr_cdmensag => 0
                                       ,pr_dsdoccop => pr_nracordo
                                       ,pr_vltitulo => pr_tab_parcelas(idx).vltitulo
                                       ,pr_dsinform => ' '
                                       ,pr_cdoperad => 1
                                       ,pr_vljurdia => pr_tab_parcelas(idx).vljurdia
                                       ,pr_vlrmulta => pr_tab_parcelas(idx).vlrmulta
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_tab_cob  => vr_tab_cob);

      -- Se retornou alguma crítica
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         --> Buscar descrição critica
        IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         END IF;
         vr_cdcritic := 0;
         
         -- Levanta exceção
         RAISE vr_exc_erro;
      END IF;
      
      vr_idxcob := vr_tab_cob.first;
      IF vr_idxcob IS NULL THEN
        vr_cdcritic := 985;
        RAISE vr_exc_erro;
      END IF;      
      
      --> Gravar parcela na tabela
      BEGIN
        INSERT INTO tbrecup_acordo_parcela
                    (nracordo,  
                     nrparcela,
                     nrboleto, 
                     nrconvenio,
                     nrdconta_cob)
             VALUES (pr_nracordo,             --nracordo
                     pr_tab_parcelas(idx).nrparcel,  --nrparcela
                     vr_tab_cob(vr_idxcob).nrdocmto, --nrboleto
                     pr_nrcnvcob,             --nrconveni
                     pr_nrdconta_cob);        --nrdconta_cob
      
      EXCEPTION
        WHEN dup_val_on_index THEN
          vr_cdcritic := 990; -- Parcela do acordo já cadastrada.
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir parcela do acordo: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      pc_escreve_xml('<boleto>'||
      
                       '<Beneficiario>'     || vr_tab_cob(vr_idxcob).nmprimtl                          || '</Beneficiario>'     ||
                       '<NossoNumero>'      || vr_tab_cob(vr_idxcob).nossonro                          || '</NossoNumero>'      ||
                       '<DataVencimento>'   || to_char(vr_tab_cob(vr_idxcob).dtvencto,vr_frmtdata)     || '</DataVencimento>'   ||
                       '<Valor>'            || to_char(vr_tab_cob(vr_idxcob).vltitulo,vr_formtnum,vr_pdrdonum) || '</Valor>'            ||
                       '<DataDocumento>'    || to_char(vr_tab_cob(vr_idxcob).dtmvtolt,vr_frmtdata)     || '</DataDocumento>'    ||
                       '<NumeroDocumento>'  || vr_tab_cob(vr_idxcob).nrdocmto || '</NumeroDocumento>'  || 
                       '<DataProcessamento>'|| to_char(vr_tab_cob(vr_idxcob).dtmvtolt,vr_frmtdata)     || '</DataProcessamento>'||
                       '<LinhaDigitavel>'   || vr_tab_cob(vr_idxcob).lindigit || '</LinhaDigitavel>'   ||
                       '<CodigoBarras>'     || vr_tab_cob(vr_idxcob).cdbarras || '</CodigoBarras>'     ||
                       '<NumeroParcela>'    || pr_tab_parcelas(idx).nrparcel || '</NumeroParcela>'    ||       
      
                     '</boleto>');
      
    
    END LOOP;
    
    -- Finalizar xml
    pc_escreve_xml('</boletos>',TRUE);
    pr_xmlbolet := XMLType.createxml(vr_dscdoxml); 
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      
  END pc_gravar_parcela;
  
  --> Rotina responsavel por gerar acordo e criar os boletos
  PROCEDURE pc_gerar_acordo (pr_xmlrequi    IN  xmltype,      --> XML de Requisição
                             pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                             pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                             pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                             pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
    /* .............................................................................
      Programa: pc_gerar_acordo
      Sistema : Rotinas referentes ao WebService
      Sigla   : WEBS
      Autor   : Odirlei Busana - AMcom
      Data    : Julho/2016.                    Ultima atualizacao: 29/09/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel por gerar acordo e criar os boletos

      Observacao: -----
      Alteracoes: 19/09/2016 - Incluida validacao de contratos JUDICIAL/EXTRA-JUDICIAL,
                               Prj. 302 (Jean Michel).

                  29/09/2016 - Incluida validacao de contratos de acordos, Prj. 302 (Jean Michel).             
                  
                  21/10/2016 - Incluir validação de cooperativa habilitada para gerar
                               acordos ( Renato Darosci - Supero )

                  11/09/2017 - Incluido substr na busca do campo bairro, limitando em 30 posicoes
                               pois o campo na CRAPENC e maior que o campo na CRAPSAB
                               Heitor (Mouts) - Chamado 752022

			      11/12/2017 - Limitar o campo de complemento em 40 posicoes, devido ao tamanho do campo
				               na tabela CRAPSAB.
                               Marcelo Coelho (Mouts) - Chamado 785483

			      04/10/2018 - Ajuste para o cursor cr_crapass delimitando enderecos com UF e CEP para o cooperado. (INC0024750 - Saquetta)
    ..............................................................................*/                                    
    
    ---------------> CURSORES <-------------
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
        
    --> Buscar cooperado    
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.vllimcre,
             ass.nrcpfcgc,
             ass.inpessoa,
             ass.nmprimtl,
             enc.dsendere,
             substr(enc.nmbairro,1,30) nmbairro,
             enc.nrcepend,
             enc.nmcidade,
             enc.nrendere,
             substr(enc.complend,1,40) complend,
             enc.cdufende,
             ass.cdcooper
                       
        FROM crapass ass,
             crapenc enc
       WHERE ass.cdcooper = enc.cdcooper
         AND ass.nrdconta = enc.nrdconta 
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
		 AND trim(enc.cdufende) is not null
         AND nvl(enc.nrcepend,0) <> 0;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Buscar sacado   
    CURSOR cr_crapsab (pr_cdcooper crapsab.cdcooper%TYPE
                      ,pr_nrdconta crapsab.nrdconta%TYPE
                      ,pr_nrinssac crapsab.nrinssac%TYPE) IS
      SELECT sab.rowid
        FROM crapsab sab
       WHERE sab.cdcooper = pr_cdcooper
         AND sab.nrdconta = pr_nrdconta
         AND sab.nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;     
    
    CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrdconta crapepr.nrdconta%TYPE
                     ,pr_dtmvtolt crapepr.dtmvtolt%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE) IS

      SELECT epr.cdcooper
            ,epr.nrdconta
        FROM crapepr epr
        JOIN crawepr wepr
          ON wepr.cdcooper = epr.cdcooper
         AND wepr.nrdconta = epr.nrdconta
         AND wepr.nrctremp = epr.nrctremp
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.dtmvtolt = pr_dtmvtolt
         AND (wepr.nrctrliq##1  = pr_nrctremp OR
              wepr.nrctrliq##2  = pr_nrctremp OR
              wepr.nrctrliq##3  = pr_nrctremp OR
              wepr.nrctrliq##4  = pr_nrctremp OR
              wepr.nrctrliq##5  = pr_nrctremp OR
              wepr.nrctrliq##6  = pr_nrctremp OR
              wepr.nrctrliq##7  = pr_nrctremp OR
              wepr.nrctrliq##8  = pr_nrctremp OR
              wepr.nrctrliq##9  = pr_nrctremp OR
              wepr.nrctrliq##10 = pr_nrctremp);  

  	rw_crapepr cr_crapepr%ROWTYPE;

    CURSOR cr_portab(pr_cdcooper crapepr.cdcooper%TYPE
                    ,pr_nrdconta crapepr.nrdconta%TYPE
                    ,pr_dtmvtolt crapepr.dtmvtolt%TYPE
                    ,pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT *
        FROM tbepr_portabilidade epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp
         AND epr.tpoperacao = 2
         AND epr.dtaprov_portabilidade >= pr_dtmvtolt;

    rw_portab cr_portab%ROWTYPE;
     
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic   VARCHAR2(10000);
    vr_cdcritic   INTEGER;
    vr_des_erro   VARCHAR2(10000);
    vr_exc_erro   EXCEPTION;
    vr_exc_erro_det EXCEPTION; 
    vr_exc_saida  EXCEPTION;   
    
    vr_cdcooper   crapcop.cdcooper%TYPE;
    vr_cdorigem   INTEGER;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_nrctremp   crapepr.nrctremp%TYPE;
    
    vr_cdcooper_aux crapcop.cdcooper%TYPE;
    vr_cdorigem_aux INTEGER;
    vr_nrdconta_aux crapass.nrdconta%TYPE;
    vr_nrctremp_aux crapepr.nrctremp%TYPE;
    
    vr_nrdconta_cob crapcob.nrdconta%TYPE;
    vr_nrcnvcob     crapcob.nrcnvcob%TYPE;
    
    vr_nracordo   INTEGER;  
    vr_dsctremp   VARCHAR2(50);
    vr_nrdgrupo   INTEGER;
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;    
    vr_nodo       xmldom.DOMNode;        
    vr_idx        VARCHAR2(500);
    
    vr_tab_campos gene0007.typ_mult_array;
    
    vr_tab_parcelas typ_tab_parcelas;
    v_idxparce      INTEGER;        
    
    -- Variáveis para armazenar as informações em XML
    vr_dscdoxml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dscdoxml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
      
    vr_cdcooper := 0; 
    BEGIN
      vr_dsctremp := TRIM(pr_xmlrequi.extract('/Root/Contratos/Contrato[1]/Numero/text()').getstringval());
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel identificar contrato.';
        RAISE vr_exc_erro;  
        
    END;
    
    IF vr_dsctremp IS NOT NULL THEN
      pc_quebra_desc_contrat(pr_nrcontrato => vr_dsctremp,
                             pr_cdcooper   => vr_cdcooper,
                             pr_cdorigem   => vr_cdorigem,
                             pr_nrdconta   => vr_nrdconta,
                             pr_nrctremp   => vr_nrctremp);
    ELSE
      vr_cdcritic := 484; --> Contrato não encontrado
      RAISE vr_exc_erro;  
    END IF;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
        
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN      
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := 'Sistema sem data de movimento, tente novamente mais tarde';
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    IF nvl(rw_crapdat.inproces,0) <> 1 THEN
      vr_dscritic := 'Processo da Cooperativa nao finalizou, tente novamente mais tarde';
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar se a cooperativa está habilitada para criação de acordos
    IF NVL(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdacesso => 'PERMISS_ACORDO'),'N') = 'N' THEN
      vr_dscritic := 'Cooperativa nao habilitada para geracao de Acordo';
      RAISE vr_exc_erro;
    END IF;
    
    -- Localizar conta do emitente do boleto, neste caso a cooperativa
    vr_nrdconta_cob := GENE0002.fn_char_para_number(gene0001.fn_param_sistema(pr_cdcooper => vr_cdcooper
                                                                             ,pr_nmsistem => 'CRED'
                                                                             ,pr_cdacesso => 'COBEMP_NRDCONTA_BNF'));
                                       
    -- Localizar convenio de cobrança
    vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'ACORDO_NRCONVEN');

    -- Busca dados do cooperado
    OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => vr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --> 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;  
    END IF;
    CLOSE cr_crapass;
      
    -- Verificar se existe o registro na crapsab com os dados do cooperado do empréstimo
    OPEN cr_crapsab (pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => vr_nrdconta_cob
                    ,pr_nrinssac => rw_crapass.nrcpfcgc);
    FETCH cr_crapsab INTO rw_crapsab;
    -- Se não encontrou registro, cria
    IF cr_crapsab%NOTFOUND THEN
       -- Fecha cursor
       CLOSE cr_crapsab;
       INSERT INTO crapsab (cdcooper,
                            nrdconta,
                            nrinssac,
                            cdtpinsc,
                            nmdsacad,
                            dsendsac,
                            nmbaisac,
                            nrcepsac,
                            nmcidsac,
                            cdufsaca,
                            cdoperad,
                            hrtransa,
                            dtmvtolt,
                            nrendsac,
                            complend,
                            cdsitsac)
                    VALUES (rw_crapass.cdcooper,
                            vr_nrdconta_cob,
                            rw_crapass.nrcpfcgc,
                            rw_crapass.inpessoa,
                            rw_crapass.nmprimtl,
                            rw_crapass.dsendere,
                            rw_crapass.nmbairro,
                            rw_crapass.nrcepend,
                            rw_crapass.nmcidade,
                            rw_crapass.cdufende,
                            '1',
                            GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
                            rw_crapdat.dtmvtolt,
                            rw_crapass.nrendere,
                            rw_crapass.complend,
                            1);
    ELSE
      -- Fecha cursor
      CLOSE cr_crapsab;       
      -- Se encontrou, atualiza dados de endereço
      UPDATE crapsab
         SET dsendsac = rw_crapass.dsendere,
             nmbaisac = rw_crapass.nmbairro,
             nrcepsac = rw_crapass.nrcepend,
             nmcidsac = rw_crapass.nmcidade,
             cdufsaca = rw_crapass.cdufende
       WHERE crapsab.rowid = rw_crapsab.rowid;
    END IF;
    
    ------------------------------------------------
    --          GRAVAR OS DADOS DO ACORDO         --
    ------------------------------------------------
    BEGIN
      vr_nracordo := TRIM(pr_xmlrequi.extract('/Root/Acordo/Numero/text()').getstringval());
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel identificar numero do acordo.';
        RAISE vr_exc_erro;          
    END;
    
    BEGIN 
      INSERT INTO tbrecup_acordo
                   (nracordo, cdcooper, nrdconta, dhacordo, cdsituacao)
            VALUES (vr_nracordo, vr_cdcooper, vr_nrdconta, SYSDATE , 1);
    EXCEPTION
      WHEN dup_val_on_index THEN
      
       --> Retornar dados dos boletos do acordo
       pc_consultar_boleto_acordo ( pr_cdcooper  => vr_cdcooper,    --> Codigo da cooperativa
                                    pr_nrdconta  => vr_nrdconta,    --> Numero da conta
                                    pr_nracordo  => vr_nracordo,    --> Numero do acordo
                                    pr_xmlrespo  => pr_xmlrespo,    --> XML de Resposta
                                    pr_cdcritic  => vr_cdcritic,    --> Código da Crítica
                                    pr_dscritic  => vr_dscritic,    --> Descrição da Crítica
                                    pr_dsdetcri  => pr_dsdetcri);   --> Detalhe da critica
      
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN 
          
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        
        RAISE vr_exc_saida;          
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel inserir acordo: '||SQLERRM;
        RAISE vr_exc_erro_det;                
    END;    
    
    vr_xmldoc:= xmldom.newDOMDocument(pr_xmlrequi);    
        
    ----------------------------------------------------
    --            GRAVAR OS DADOS DO CONTRATO         --
    ----------------------------------------------------      
    --> BUSCAR CONTRATOS DO ACORDO
    -- Listar nós contrado
    vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'Contrato');        
    FOR vr_linha IN 0..(xmldom.getLength(vr_lista_nodo)-1) LOOP
      --Buscar Nodo Corrente
      vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
      
      gene0007.pc_itera_nodos (pr_nodo       => vr_nodo      --> Xpath do nodo a ser pesquisado
                              ,pr_nivel      => 0            --> Nível que será pesquisado
                              ,pr_list_nodos => vr_tab_campos--> PL Table com os nodos resgatados
                              ,pr_des_erro   => vr_des_erro);
                      
      vr_idx := vr_tab_campos.first;
      WHILE vr_idx IS NOT NULL LOOP
      
        vr_nrdgrupo := vr_tab_campos(vr_idx)('Grupo');
        vr_dsctremp := vr_tab_campos(vr_idx)('Numero');  
        vr_idx := vr_tab_campos.next(vr_idx);
      END LOOP;
      
      IF vr_dsctremp IS NOT NULL THEN
        pc_quebra_desc_contrat(pr_nrcontrato => vr_dsctremp,
                               pr_cdcooper   => vr_cdcooper_aux,
                               pr_cdorigem   => vr_cdorigem_aux,
                               pr_nrdconta   => vr_nrdconta_aux,
                               pr_nrctremp   => vr_nrctremp_aux);
      ELSE
        vr_cdcritic := 484; --> Contrato não encontrado
        RAISE vr_exc_erro;  
      END IF;
      
      -- Verifica se contrato esta em acordo
      OPEN cr_portab(pr_cdcooper => vr_cdcooper_aux
                    ,pr_nrdconta => vr_nrdconta_aux
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_nrctremp => vr_nrctremp_aux);

      FETCH cr_portab INTO rw_portab;

      IF cr_portab%FOUND THEN
        CLOSE cr_portab;
        vr_dscritic := 'Nao e possivel realizar acordo, contrato ' || gene0002.fn_mask_contrato(vr_nrctremp_aux) || ' esta em processo de portabilidade.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_portab;
      END IF;

      -- Verifica se contrato esta para liquidar
      OPEN cr_crapepr(pr_cdcooper => vr_cdcooper_aux
                     ,pr_nrdconta => vr_nrdconta_aux
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrctremp => vr_nrctremp_aux);
      FETCH cr_crapepr INTO rw_crapepr;
      IF cr_crapepr%FOUND THEN
        CLOSE cr_crapepr;
        vr_dscritic := 'Nao e possivel realizar acordo, contrato ' || gene0002.fn_mask_contrato(vr_nrctremp_aux) || ' marcado para liquidar.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapepr;
      END IF;

      -- Validar contas
      IF vr_cdcooper_aux <> vr_cdcooper OR 
         vr_nrdconta_aux <> vr_nrdconta THEN
        vr_cdcritic := 992; -- Acordo possui contratos para contas diferentes.
        RAISE vr_exc_erro;         
      END IF;
      
      --> Gravar os contratos do acordo
      pc_gravar_contrato_acordo ( pr_nracordo  => vr_nracordo,     --> Numero do acordo
                                  pr_cdcooper  => vr_cdcooper,     --> Codigo da Cooperativa
                                  pr_nrdconta  => vr_nrdconta,     --> Número da Conta
                                  pr_cdorigem  => vr_cdorigem_aux, --> Origem
                                  pr_nrctremp  => vr_nrctremp_aux,  --> Numero do Contrato
                                  pr_nrdgrupo  => vr_nrdgrupo,       --> Numero do grupo do contrato
                                  pr_cdcritic  => vr_cdcritic,       --> Código da Crítica
                                  pr_dscritic  => vr_dscritic);     --> Descrição da Crítica
      
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN    
        -- Se apenas possui texto retorna critica padrão
        -- e texto no detalhe 
        IF nvl(vr_cdcritic,0) > 0 THEN   
          RAISE vr_exc_erro;   
        ELSE
          RAISE vr_exc_erro_det;   
        END IF;  
        
      END IF; 
      
    END LOOP;
    
    ---------------------------------------------------------
    --            GRAVAR OS DADOS DO PARCELA               --
    ---------------------------------------------------------
    -- Listar nós de parcelas
    vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'Parcela');        
    FOR vr_linha IN 0..(xmldom.getLength(vr_lista_nodo)-1) LOOP
      --Buscar Nodo Corrente
      vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
      
      gene0007.pc_itera_nodos (pr_nodo       => vr_nodo      --> Xpath do nodo a ser pesquisado
                              ,pr_nivel      => 0            --> Nível que será pesquisado
                              ,pr_list_nodos => vr_tab_campos--> PL Table com os nodos resgatados
                              ,pr_des_erro   => vr_des_erro);
                      
      vr_idx := vr_tab_campos.first;
      WHILE vr_idx IS NOT NULL LOOP      
        BEGIN
          v_idxparce := vr_tab_parcelas.count + 1;
          vr_tab_parcelas(v_idxparce).nrparcel := vr_tab_campos(vr_idx)('Numero');  
          vr_tab_parcelas(v_idxparce).vltitulo := gene0002.fn_char_para_number(vr_tab_campos(vr_idx)('Valor'));
          vr_tab_parcelas(v_idxparce).vljurdia := gene0002.fn_char_para_number(vr_tab_campos(vr_idx)('ValorJurosMora'));
          vr_tab_parcelas(v_idxparce).vlrmulta := gene0002.fn_char_para_number(vr_tab_campos(vr_idx)('ValorMulta'));
          vr_tab_parcelas(v_idxparce).vlroutro := gene0002.fn_char_para_number(vr_tab_campos(vr_idx)('ValorOutrosAcrescimos'));
          vr_tab_parcelas(v_idxparce).dtvencto := to_date(vr_tab_campos(vr_idx)('DataVencimento'),vr_frmtdata);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao ler dados da parcela: '||SQLERRM;
            RAISE vr_exc_erro;  
        END;
        vr_idx := vr_tab_campos.next(vr_idx);
      END LOOP;
      
    END LOOP;
    
    IF vr_tab_parcelas.count() > 0 THEN
      --> Rotina para gerar os boletos e gravar as parcelas
      pc_gravar_parcela ( pr_nracordo     => vr_nracordo,         --> Numero do acordo
                          pr_cdcooper     => vr_cdcooper,         --> Codigo da Cooperativa
                          pr_nrdconta     => vr_nrdconta,         --> Número da Conta
                          pr_nrdconta_cob => vr_nrdconta_cob,     --> Número da Conta da cobrança
                          pr_nrcnvcob     => vr_nrcnvcob,         --> Numero do convenio de cobranca
                          pr_inpessoa     => rw_crapass.inpessoa, --> Tipo de pessoa
                          pr_nrcpfcgc     => rw_crapass.nrcpfcgc, --> Numero do cpf/cnpj do cooperado
                          pr_dtmvtolt     => rw_crapdat.dtmvtolt, --> Data do movimento
                          pr_tab_parcelas => vr_tab_parcelas,     --> Parcelas a serem processadas
                          pr_xmlbolet     => pr_xmlrespo,         --> Xml de retorno dos boletos gerados 
                          pr_cdcritic     => vr_cdcritic,         --> Código da Crítica
                          pr_dscritic     => vr_dscritic);        --> Descrição da Crítica
                          
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN       
        -- Se apenas possui texto retorna critica padrão
        -- e texto no detalhe 
        IF nvl(vr_cdcritic,0) > 0 THEN   
          RAISE vr_exc_erro;   
        ELSE
          RAISE vr_exc_erro_det;   
        END IF; 
      END IF; 
    END IF;
    
  EXCEPTION
    --> apenas sair do programa
    WHEN vr_exc_saida THEN
      NULL;
    WHEN vr_exc_erro_det THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      --> Apenas critica generica e detalhe critica em outro parametro        
      pr_cdcritic := 993;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 993);
      pr_dsdetcri := vr_dscritic;
      
    WHEN vr_exc_erro THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        pr_dsdetcri := vr_dscritic; 
      END IF;
      
      IF NVL(vr_cdcritic,0) = 0 THEN
        vr_cdcritic := 993;
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_dsdetcri := nvl(pr_dsdetcri,vr_dscritic);
      
    WHEN OTHERS THEN
      pr_cdcritic := 993;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic); 
      pr_dscritic := vr_dscritic;      
      pr_dsdetcri := SQLERRM; 
	  pc_internal_exception(vr_cdcooper);
  END pc_gerar_acordo;
  
  --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_cancelar_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo
                                pr_dtcancel    IN  DATE,         --> Data de Cancelamento                                               
                                pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
    /* .............................................................................
      Programa: pc_cancelar_acordo
      Sistema : Rotinas referentes ao WebService
      Sigla   : WEBS
      Autor   : Odirlei Busana - AMcom
      Data    : Julho/2016.                    Ultima atualizacao: 29/10/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel por cancelar acordo

      Observacao: -----
      Alteracoes: 19/09/2016 - Incluido ROLLBACK na exceptio vr_exc_erro_det,
							                 Prj. 302 (Jean Michel).
                                    
                  19/09/2016 - Incluido novo parametro pr_dtcancel, Prj. 302 (Jean Michel).             

                  29/09/2016 - Incluido tratamento para desbloquear valor em C/C,
                               Prj. 302 (Jean Michel). 

                  22/02/2017 - Passagem de parametros rw_tbacordo para cr_crapass. (Jaison/James)
                  
                  30/11/2017 - Ajuste para fixar o número de parcelar como 0 - zero ao chamar
                               a rotina que efetua o lançamento
                               (Adriano - SD 804308).

                  17/04/2018 - Implementado codigo de erro para acordos ativos no Cyber
				               e inexistentes no Ayllos.
                               (GSaquetta - Chamado 848110).

									29/10/2018 - Ajuste para estorno do IOF vinculado ao acordo para a tabela CRAPSLD
									             quando o acordo é cancelado.
															 (Reginaldo - AMcom - P450) 

    ..............................................................................*/                                    
    
    ---------------> CURSORES <-------------
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
    
    --> Buscar situacao do acordo
    CURSOR cr_tbacordo IS
       SELECT aco.cdsituacao,
              aco.cdcooper,
              aco.nrdconta,
              aco.nracordo,
              aco.vlbloqueado
        FROM tbrecup_acordo aco
       WHERE nracordo = pr_nracordo;
    rw_tbacordo cr_tbacordo%ROWTYPE;  
    
		--> Buscar informações de IOF vinculado ao contrato (ADP)
		CURSOR cr_contrato IS
		   SELECT ctr.vliofdev
			      , ctr.vliofpag
			   FROM tbrecup_acordo_contrato ctr
				WHERE ctr.nracordo = pr_nracordo
				  AND cdorigem = 1;
		rw_contrato cr_contrato%ROWTYPE;

    --> Buscar parcelas do acordo
    CURSOR cr_parcelas IS         
      SELECT par.nrdconta_cob
            ,par.nrconvenio
            ,par.nrboleto
        FROM tbrecup_acordo_parcela par
       WHERE par.nracordo = pr_nracordo;
    
    --> Verificar cobrança
    CURSOR cr_crapcob (pr_cdcooper      crapcob.cdcooper%TYPE,
                       pr_nrdconta_cob  crapcob.nrdconta%TYPE,
                       pr_nrconvenio    crapcob.nrcnvcob%TYPE,
                       pr_nrboleto      crapcob.nrdocmto%TYPE) IS     
      SELECT crapcob.rowid
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.nrdconta = pr_nrdconta_cob
         AND crapcob.nrcnvcob = pr_nrconvenio
         AND crapcob.nrdocmto = pr_nrboleto
         AND crapcob.incobran NOT IN (3,5); -- (Baixado, Liquidado)
    rw_crapcob cr_crapcob%ROWTYPE;
        
    --> Buscar cooperado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
         
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic     VARCHAR2(10000);
    vr_cdcritic     INTEGER;    
    vr_exc_erro     EXCEPTION;
    vr_exc_erro_det EXCEPTION;
       
    -- Pl/Table utilizada na procedure de baixa
    vr_tab_lat_consolidada     paga0001.typ_tab_lat_consolidada;      
    
    vr_des_reto     VARCHAR2(10);
    vr_tab_erro    gene0001.typ_tab_erro;
    
  BEGIN
    
    --> Buscar situacao do acordo
    OPEN cr_tbacordo;
    FETCH cr_tbacordo INTO rw_tbacordo;
    IF cr_tbacordo%NOTFOUND THEN
      CLOSE cr_tbacordo;
      -- Retornar critica que o acordo não foi encontrado.
      vr_cdcritic := 1205;
      RAISE vr_exc_erro; 
    END IF;
    CLOSE cr_tbacordo;
    
    IF rw_tbacordo.cdsituacao = 2 THEN
       -- Retornar critica que o acordo esta quitado.
      vr_cdcritic := 986;
      RAISE vr_exc_erro;
    ELSIF rw_tbacordo.cdsituacao = 3 THEN
       -- Retornar critica que o acordo esta cancelado.
       vr_cdcritic := 984;
      RAISE vr_exc_erro;
    END IF;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_tbacordo.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN      
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := 'Sistema sem data de movimento, tente novamente mais tarde';
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
        
    IF nvl(rw_crapdat.inproces,0) <> 1 THEN
      vr_dscritic := 'Processo da Cooperativa nao finalizou, tente novamente mais tarde';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar parcelas do acordo
    FOR rw_parcelas IN cr_parcelas LOOP      
      --> Verificar cobrança
      OPEN cr_crapcob (pr_cdcooper      => rw_tbacordo.cdcooper,
                       pr_nrdconta_cob  => rw_parcelas.nrdconta_cob,
                       pr_nrconvenio    => rw_parcelas.nrconvenio,
                       pr_nrboleto      => rw_parcelas.nrboleto);
      FETCH cr_crapcob INTO rw_crapcob;
      IF cr_crapcob%FOUND THEN
        CLOSE cr_crapcob;
        
        -- Efetua baixa
        COBR0007.pc_inst_pedido_baixa(pr_idregcob => rw_crapcob.rowid
                                     ,pr_cdocorre => 0
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdoperad => 1
                                     ,pr_nrremass => 0
                                     ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                       
        -- Se retornou alguma crítica               
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro_det;
        END IF;
        
      ELSE
        CLOSE cr_crapcob;
      END IF;            
    END LOOP;  
    
    -- Condicao para verificar se possui valor de acordo
    IF rw_tbacordo.vlbloqueado > 0 THEN

      OPEN cr_crapass(pr_cdcooper => rw_tbacordo.cdcooper
                     ,pr_nrdconta => rw_tbacordo.nrdconta);   

      FETCH cr_crapass INTO rw_crapass;               

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
    
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper             --> Cooperativa conectada
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt     --> Movimento atual
                                    ,pr_cdagenci => rw_crapass.cdagenci     --> Código da agência
                                    ,pr_cdbccxlt => 100                     --> Número do caixa
                                    ,pr_cdoperad => '1'                     --> Código do Operador
                                    ,pr_cdpactra => rw_crapass.cdagenci     --> P.A. da transação
                                    ,pr_nrdolote => 650001                  --> Numero do Lote
                                    ,pr_nrdconta => rw_crapass.nrdconta             --> Número da conta
                                    ,pr_cdhistor => 2194                    --> Codigo historico 2194 - CR.DESB.ACORD
                                    ,pr_vllanmto => rw_tbacordo.vlbloqueado --> Valor da parcela emprestimo
                                    ,pr_nrparepr => 0                       --> Número parcelas empréstimo
                                    ,pr_nrctremp => 0                       --> Número do contrato de empréstimo
                                    ,pr_des_reto => vr_des_reto             --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);           --> Tabela com possíves erros
      --Se Retornou erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- Atribui críticas às variaveis
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao criar o lancamento de desbloqueio de acordo';
        END IF;
        
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    BEGIN
      -- Desmarcar o contrato como CIN
      UPDATE crapcyc
         SET flgehvip = decode(cdmotcin,2,flgehvip,7,flgehvip,flvipant),
             cdmotcin = decode(cdmotcin,2,cdmotcin,7,cdmotcin,cdmotant),
             crapcyc.dtaltera = rw_crapdat.dtmvtolt,
			 crapcyc.cdoperad = 'cyber'
         WHERE EXISTS(SELECT 1
                        FROM tbrecup_acordo_contrato
                        JOIN tbrecup_acordo
                          ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
                       WHERE tbrecup_acordo.cdcooper = crapcyc.cdcooper
                         AND tbrecup_acordo.nrdconta = crapcyc.nrdconta
                         AND tbrecup_acordo_contrato.nrctremp = crapcyc.nrctremp
                         AND DECODE(tbrecup_acordo_contrato.cdorigem,2,3,tbrecup_acordo_contrato.cdorigem) = crapcyc.cdorigem
                         AND tbrecup_acordo_contrato.nracordo = rw_tbacordo.nracordo);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar o CYBER: '||SQLERRM;
        RAISE vr_exc_erro_det;
    END;
		
		-- Busca valor de IOF pendente do acordo
		OPEN cr_contrato;
		FETCH cr_contrato INTO rw_contrato;
		
		IF nvl(rw_contrato.vliofdev, 0) - nvl(rw_contrato.vliofpag, 0) > 0 THEN
			BEGIN
				-- Atualiza o IOF provisionado na CRAPSLD com o valor do IOF pendente do acordo a ser cancelado
				UPDATE crapsld sld
				   SET sld.vliofmes = nvl(sld.vliofmes, 0) + nvl(rw_contrato.vliofdev, 0) - nvl(rw_contrato.vliofpag, 0)
				 WHERE sld.cdcooper = rw_tbacordo.cdcooper
				   AND sld.nrdconta = rw_tbacordo.nrdconta;
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Erro ao atualizar valor do IOF na CRAPSLD: ' || SQLERRM;
          RAISE vr_exc_erro_det;
			END;
			
			-- Remove o vínculo dos lançamentos de IOF da TBGEN_IOF_LANCAMENTO com o acordo que está sendo cancelado
			BEGIN
				UPDATE tbgen_iof_lancamento 
				   SET tbgen_iof_lancamento.nracordo = NULL
         WHERE tbgen_iof_lancamento.nracordo = pr_nracordo;
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Erro ao atualizar numero do acordo na TBGEN_IOF_LANCAMENTO: ' || SQLERRM;
          RAISE vr_exc_erro_det;
			END;
		END IF;
		
		CLOSE cr_contrato;

    BEGIN
      -- Alterar a situação do acordo para cancelado
      UPDATE tbrecup_acordo SET
             cdsituacao = 3 -- Cancelado
            ,dtcancela  = pr_dtcancel
       WHERE nracordo = rw_tbacordo.nracordo;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar acordo: '||SQLERRM;
        RAISE vr_exc_erro_det;   
    END;     
      
  EXCEPTION
    WHEN vr_exc_erro_det THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      --> Apenas critica generica e detalhe critica em outro parametro        
      pr_cdcritic := 994;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 994);
      pr_dsdetcri := vr_dscritic;
    WHEN vr_exc_erro THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        pr_dsdetcri := vr_dscritic;
      END IF;
      
      IF NVL(vr_cdcritic,0) = 0 THEN
        vr_cdcritic := 994;
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_dsdetcri := nvl(pr_dsdetcri,vr_dscritic);
      
    WHEN OTHERS THEN
      pr_cdcritic := 994;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      pr_dscritic := vr_dscritic;      
      pr_dsdetcri := SQLERRM; 
            
  END pc_cancelar_acordo;
  
  --> Rotina responsavel por retornar dados dos boletos do acordo
  PROCEDURE pc_consultar_boleto_acordo ( pr_cdcooper    IN  crapcop.cdcooper%TYPE,        --> Codigo da cooperativa
                                         pr_nrdconta    IN  crapass.nrdconta%TYPE,        --> Numero da conta
                                         pr_nracordo    IN  tbrecup_acordo.nracordo%TYPE, --> Numero do acordo
                                         pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                         pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                         pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                         pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
    /* .............................................................................
      Programa: pc_consultar_boleto_acordo
      Sistema : Rotinas referentes ao WebService
      Sigla   : WEBS
      Autor   : Odirlei Busana - AMcom
      Data    : Janeiro/2017.                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel por retornar dados dos boletos do acordo

      Observacao: -----
      Alteracoes: 
    ..............................................................................*/                                    
    
    ---------------> CURSORES <-------------
    --> Buscar parcelas do acordo
    CURSOR cr_acordo_parc( pr_cdcooper crapcop.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE,
                           pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
      SELECT par.nrboleto,
             par.nrconvenio,
             par.nrdconta_cob,
             par.nrparcela
        FROM tbrecup_acordo_parcela par,
             tbrecup_acordo         aco
       WHERE aco.cdcooper = pr_cdcooper
         AND aco.nrdconta = pr_nrdconta
         AND aco.nracordo = par.nracordo
         AND par.nracordo = pr_nracordo;
    
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic     VARCHAR2(10000);
    vr_cdcritic     INTEGER;
    vr_exc_erro     EXCEPTION;
    vr_exc_erro_det EXCEPTION; 
    
    vr_tab_cob    cobr0005.typ_tab_cob;
    vr_idxcob     PLS_INTEGER;
    vr_flexiste   BOOLEAN := FALSE;    
    
    -- Variáveis para armazenar as informações em XML
    vr_dscdoxml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dscdoxml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
    
  BEGIN
    
    -- Inicializar o CLOB
    vr_dscdoxml := NULL;
    dbms_lob.createtemporary(vr_dscdoxml, TRUE);
    dbms_lob.open(vr_dscdoxml, dbms_lob.lob_readwrite);
    
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><boletos>');
    
    -- Listar parcelas do acordo
    FOR rw_acordo_parc IN cr_acordo_parc( pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nracordo => pr_nracordo) LOOP
                                          
                                          
      cobr0005.pc_buscar_titulo_cobranca (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_acordo_parc.nrdconta_cob
                                         ,pr_nrcnvcob => rw_acordo_parc.nrconvenio
                                         ,pr_nrdocmto => rw_acordo_parc.nrboleto
                                         ,pr_cdoperad => 1
                                         ,pr_nriniseq => 1
                                         ,pr_nrregist => 1
                                         ,pr_cdcritic => pr_cdcritic
                                         ,pr_dscritic => pr_dscritic
                                         ,pr_tab_cob  => vr_tab_cob);
                                         
      -- Se retornou alguma crítica
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         --> Buscar descrição critica
        IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         END IF;
         vr_cdcritic := 0;
         
         -- Levanta exceção
         RAISE vr_exc_erro;
      END IF;
      
      vr_idxcob := vr_tab_cob.first;
      IF vr_idxcob IS NULL THEN
        vr_cdcritic := 'Boleto não encontrado.';
        RAISE vr_exc_erro_det;
      END IF; 
    
      pc_escreve_xml('<boleto>'||      
                       '<Beneficiario>'     || vr_tab_cob(vr_idxcob).nmprimtl                          || '</Beneficiario>'     ||
                       '<NossoNumero>'      || vr_tab_cob(vr_idxcob).nossonro                          || '</NossoNumero>'      ||
                       '<DataVencimento>'   || to_char(vr_tab_cob(vr_idxcob).dtvencto,vr_frmtdata)     || '</DataVencimento>'   ||
                       '<Valor>'            || to_char(vr_tab_cob(vr_idxcob).vltitulo,vr_formtnum,vr_pdrdonum) || '</Valor>'            ||
                       '<DataDocumento>'    || to_char(vr_tab_cob(vr_idxcob).dtmvtolt,vr_frmtdata)     || '</DataDocumento>'    ||
                       '<NumeroDocumento>'  || vr_tab_cob(vr_idxcob).nrdocmto || '</NumeroDocumento>'  || 
                       '<DataProcessamento>'|| to_char(vr_tab_cob(vr_idxcob).dtmvtolt,vr_frmtdata)     || '</DataProcessamento>'||
                       '<LinhaDigitavel>'   || vr_tab_cob(vr_idxcob).lindigit || '</LinhaDigitavel>'   ||
                       '<CodigoBarras>'     || vr_tab_cob(vr_idxcob).cdbarras || '</CodigoBarras>'     ||
                       '<NumeroParcela>'    || rw_acordo_parc.nrparcela || '</NumeroParcela>'    ||       
      
                     '</boleto>');
      vr_flexiste := TRUE;
    END LOOP;
    
    -- Finalizar xml
    pc_escreve_xml('</boletos>',TRUE);
    pr_xmlrespo := XMLType.createxml(vr_dscdoxml);
    
    --> Se nao achou nenhum registro apresenta critica
    IF vr_flexiste = FALSE THEN
      vr_cdcritic := 991; -- Numero do acordo ja cadastrado.
      pr_dsdetcri := 'Numero de acordo já cadastrado para outra conta ou boleto(s) não encontrado(s).';
      RAISE vr_exc_erro;        
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro_det THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      --> Apenas critica generica e detalhe critica em outro parametro        
      pr_cdcritic := 993;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := vr_dscritic;
    WHEN vr_exc_erro THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        pr_dsdetcri := vr_dscritic;
      END IF;
      
      IF NVL(vr_cdcritic,0) = 0 THEN
        vr_cdcritic := 993;
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_dsdetcri := nvl(pr_dsdetcri,vr_dscritic);
      
    WHEN OTHERS THEN
      pr_cdcritic := 993;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      pr_dscritic := vr_dscritic;      
      pr_dsdetcri := SQLERRM; 
  END pc_consultar_boleto_acordo;
                                                              	
END RECP0002;
/
