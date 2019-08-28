CREATE OR REPLACE PACKAGE CECRED.COMP0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : COMP0001
--  Sistema  : Rotinas genericas da compel
--  Sigla    : COMPEL
--  Autor    : Lucas Reinert
--  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
--
-- Alteracoes: 12/06/2019 PJ565 - Jackson Barcellos AMcom (pc_gera_rel782) Inclusao da Rotina para unificar 2 relatorios em 1 (crrl238 + crrl287) = crrl782 
-- Alteracoes: 18/06/2019 PJ565 - Renato Cordeiro AMcom (pc_gera_rel782) Inclusão validação Nossa remessa
---------------------------------------------------------------------------------------------------------------
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_controla_bloqueio_previa(pr_cdcooper IN craptab.cdcooper%TYPE -- Cód. da cooperativa
		                                   ,pr_nmsistem IN craptab.nmsistem%TYPE -- Nome sistema
																			 ,pr_tptabela IN craptab.tptabela%TYPE -- Tipo da tabela
																			 ,pr_cdempres IN craptab.cdempres%TYPE -- Cód. da empresa
																			 ,pr_cdacesso IN craptab.cdacesso%TYPE -- Cód. de acesso
																			 ,pr_tpregist IN craptab.tpregist%TYPE -- Tipo de registro
																			 ,pr_cdoperad IN crapope.cdoperad%TYPE -- Cód. do operado
																			 ,pr_inbloque IN PLS_INTEGER);         -- Indicador de controle (1 - Bloqueia/2- Desbloqueia)

-- Gerar arquivos para cecred
  PROCEDURE pc_gerar_arquivos_compel(pr_dtmvtolt IN DATE         -- Data de movimento
																		,pr_cdcooper IN PLS_INTEGER  -- Cooperativa
																		,pr_cdageini IN PLS_INTEGER  -- PA inicio
																		,pr_cdagefim IN PLS_INTEGER  -- PA fim
																		,pr_cdoperad IN VARCHAR2     -- Cód. operador
																		,pr_nmdatela IN VARCHAR2     -- Nome da tela
																		,pr_nrdolote IN PLS_INTEGER  -- Nr. do lote
																		,pr_nrdcaixa IN PLS_INTEGER  -- Nr. do caixa
																		,pr_cdbccxlt IN VARCHAR2     -- Cód. do banco
                                    ,pr_cdcritic OUT PLS_INTEGER -- Cód. da crítica
																		,pr_dscritic OUT VARCHAR2    -- Desc. da crítica
																		,pr_qtarquiv OUT PLS_INTEGER -- Quantidade de arquivos
																		,pr_totregis OUT PLS_INTEGER -- Total de registros
																		,pr_vlrtotal OUT NUMBER);    -- Valor total																		
	-- Bloquear/Desbloquear resgate de cheque
	PROCEDURE pc_bloquear_resgate_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE
		                                  ,pr_dsresgat IN VARCHAR2
																			,pr_des_erro OUT VARCHAR2);
																			
  -- Gerar arquivo de prévia de custódia
	PROCEDURE pc_gerar_compel_custodia(pr_dtmvtolt IN DATE         -- Data de movimento
																		,pr_cdcooper IN PLS_INTEGER  -- Cooperativa
																		,pr_cdagenci IN PLS_INTEGER  -- PA inicio
																		,pr_cdoperad IN VARCHAR2     -- Cód. operador
																		,pr_nmdatela IN VARCHAR2     -- Nome da tela
																		,pr_nrdcaixa IN PLS_INTEGER  -- Nr. do caixa
																		,pr_cdbccxlt IN VARCHAR2     -- Cód. do banco
																		,pr_nrdolote IN PLS_INTEGER  -- Nr. do lote																		
                                    ,pr_cdcritic OUT PLS_INTEGER -- Cód. da crítica
																		,pr_dscritic OUT VARCHAR2    -- Desc. da crítica
																		,pr_qtarquiv OUT PLS_INTEGER -- Quantidade de arquivos
																		,pr_totregis OUT PLS_INTEGER -- Total de registros
																		,pr_vlrtotal OUT NUMBER);    -- Valor total
																		
  -- Rotina para unificar 2 relatorios em 1 (crrl238 + crrl287) = crrl782                                   
  PROCEDURE pc_gera_rel782(pr_cdcooper IN NUMBER,
                         pr_cdcritic OUT crapcri.cdcritic%TYPE,
                         pr_dscritic OUT VARCHAR2); 
						 
  -- PROJ.565                       
PROCEDURE pc_checa_compel(pr_cdcooper IN craptit.CDCOOPER%type,
                           pr_nmarquiv IN VARCHAR2,
                           pr_cdagectl IN crapcop.cdagectl%TYPE,
                           pr_cdagenci IN craptit.cdagenci%TYPE,
                           pr_dtmvtolt IN craptit.dtmvtolt%TYPE, -- Data da Mov
                           pr_totregis IN NUMBER,
                           pr_vltotarq IN NUMBER,
                           pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Código da crítica
                           pr_dscritic OUT VARCHAR2);			

   -- PROJ.565
PROCEDURE pc_checa_titulos(pr_cdcooper IN craptit.CDCOOPER%type,
                           pr_nmarquiv IN VARCHAR2,
                           pr_cdagectl IN crapcop.cdagectl%TYPE,
                           pr_cdagenci IN craptit.cdagenci%TYPE,
                           pr_dtmvtolt IN craptit.dtmvtolt%TYPE, -- Data da Mov
                           pr_totregis IN NUMBER,
                           pr_vltotarq IN NUMBER,
                           pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Código da crítica
                           pr_dscritic OUT VARCHAR2); 
   --PROJ.565      
PROCEDURE pc_checa_devolu (pr_cdcooper IN craptit.CDCOOPER%type,
                           pr_nmarquiv IN VARCHAR2,
                           pr_cdagectl IN crapcop.cdagectl%TYPE,
                           pr_cdagenci IN craptit.cdagenci%TYPE,
                           pr_dtmvtolt IN craptit.dtmvtolt%TYPE, -- Data da Mov
                           pr_totregis IN NUMBER,
                           pr_vltotarq IN NUMBER,
                           pr_tparquiv IN tbcompe_nossaremessa.tparquiv%TYPE,
                           pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Código da crítica
                           pr_dscritic OUT VARCHAR2);
                           																		
   --PROJ.565      
CURSOR cr_tbcompe_nossaremessa (pr_cdcooper IN tbcompe_nossaremessa.cdcooper%TYPE,
                                pr_cdagenci IN tbcompe_nossaremessa.cdagenci%TYPE,
                                pr_tparquiv IN tbcompe_nossaremessa.tparquiv%TYPE,
                                pr_dtmvtolt IN tbcompe_nossaremessa.dtarquiv%TYPE,
                                pr_nmarquiv IN tbcompe_nossaremessa.nmarquiv%TYPE) IS
    SELECT rowid FROM tbcompe_nossaremessa a 
    WHERE a.cdcooper = pr_cdcooper
      AND a.cdagenci = pr_cdagenci
      AND a.tparquiv = pr_tparquiv
      AND a.dtarquiv = pr_dtmvtolt
      AND a.nmarquiv = pr_nmarquiv;
rw_tbcompe_nossaremessa cr_tbcompe_nossaremessa%ROWTYPE;
  

                           
END COMP0001;                       
/
CREATE OR REPLACE PACKAGE BODY CECRED.COMP0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : COMP0001
--  Sistema  : Rotinas genericas da compel
--  Sigla    : COMPEL
--  Autor    : Lucas Reinert
--  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
--
-- Alteracoes: 
-- PJ565.1 - Tratamento para geração de dados para a tela MOVCMP - Renato Cordeiro - AMcom
---------------------------------------------------------------------------------------------------------------

  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_controla_bloqueio_previa(pr_cdcooper IN craptab.cdcooper%TYPE -- Cód. da cooperativa
		                                   ,pr_nmsistem IN craptab.nmsistem%TYPE -- Nome sistema
																			 ,pr_tptabela IN craptab.tptabela%TYPE -- Tipo da tabela
																			 ,pr_cdempres IN craptab.cdempres%TYPE -- Cód. da empresa
																			 ,pr_cdacesso IN craptab.cdacesso%TYPE -- Cód. de acesso
																			 ,pr_tpregist IN craptab.tpregist%TYPE -- Tipo de registro
																			 ,pr_cdoperad IN crapope.cdoperad%TYPE -- Cód. do operado
																			 ,pr_inbloque IN PLS_INTEGER) IS       -- Indicador de controle (1 - Bloqueia/2- Desbloqueia)
    -- Cria uma nova seção para commitar
    -- somente este escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
		BEGIN
    -- ..........................................................................
    -- Programa: pc_controla_bloqueio_previa
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Lucas Reinert
    -- Data    : Outubro/2016.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Sempre que for chamada
    -- Objetivo  : Rotina para bloquear/desbloquear o operador no processo da prévia

    -- Alteracoes:
    --
    -- .............................................................................
    DECLARE
		   
		  --Variáveis locais
			vr_rowid ROWID;
		
		  -- Buscar rowid para atualizar craptab
			CURSOR cr_craptab IS
			  SELECT /*+index_asc (tab CRAPTAB##CRAPTAB1)*/
				       tab.rowid
				  FROM craptab tab
     WHERE tab.cdcooper        = pr_cdcooper
       AND UPPER(tab.nmsistem) = pr_nmsistem
       AND UPPER(tab.tptabela) = pr_tptabela
       AND tab.cdempres        = pr_cdempres
       AND upper(tab.cdacesso) = nvl(pr_cdacesso, tab.cdacesso)
       AND tab.tpregist        = nvl(pr_tpregist, tab.tpregist);
			 
		BEGIN
			-- Abre cursor
		  OPEN cr_craptab;
			FETCH cr_craptab INTO vr_rowid;	

      IF cr_craptab%FOUND THEN
				-- Bloqueia
				IF pr_inbloque = 1 THEN
          UPDATE craptab tab
					   SET tab.dstextab = pr_cdoperad
					 WHERE tab.rowid = vr_rowid;
				-- Desbloqueia
				ELSIF pr_inbloque = 2 THEN
          UPDATE craptab tab
					   SET tab.dstextab = ' '
					 WHERE tab.rowid = vr_rowid;
				END IF;
			END IF;
			-- Fechar cursor
			CLOSE cr_craptab;
		  -- Efetuar commit
      COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				-- Efetuar rollback
				ROLLBACK;
		END;  
  END pc_controla_bloqueio_previa;
	
	-- Gerar arquivos para cecred
  PROCEDURE pc_gerar_arquivos_compel(pr_dtmvtolt IN DATE         -- Data de movimento
																		,pr_cdcooper IN PLS_INTEGER  -- Cooperativa
																		,pr_cdageini IN PLS_INTEGER  -- PA inicio
																		,pr_cdagefim IN PLS_INTEGER  -- PA fim
																		,pr_cdoperad IN VARCHAR2     -- Cód. operador
																		,pr_nmdatela IN VARCHAR2     -- Nome da tela
																		,pr_nrdolote IN PLS_INTEGER  -- Nr. do lote
																		,pr_nrdcaixa IN PLS_INTEGER  -- Nr. do caixa
																		,pr_cdbccxlt IN VARCHAR2     -- Cód. do banco
                                    ,pr_cdcritic OUT PLS_INTEGER -- Cód. da crítica
																		,pr_dscritic OUT VARCHAR2    -- Desc. da crítica
																		,pr_qtarquiv OUT PLS_INTEGER -- Quantidade de arquivos
																		,pr_totregis OUT PLS_INTEGER -- Total de registros
																		,pr_vlrtotal OUT NUMBER) IS  -- Valor total
  BEGIN
	-- ..........................................................................
	-- Programa: pc_gerar_arquivos_compel
	-- Sistema : Conta-Corrente - Cooperativa de Credito
	-- Sigla   : CRED
	-- Autor   : Lucas Reinert
	-- Data    : Outubro/2016.                     Ultima atualizacao:

	-- Dados referentes ao programa:

	-- Frequencia: Sempre que for chamada
	-- Objetivo  : Rotina para gerar arquivos da compel

	-- Alteracoes:
	--
	-- .............................................................................
		DECLARE
		  vr_des_erro VARCHAR2(5);
		BEGIN 
			-- Bloquear resgate de cheque durante envio para ABBC
		  pc_bloquear_resgate_cheque(pr_cdcooper => pr_cdcooper
			                          ,pr_dsresgat => 'S'
																,pr_des_erro => vr_des_erro);
																
      pc_gerar_compel_custodia(pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
															,pr_cdcooper => pr_cdcooper  -- Cooperativa
															,pr_cdagenci => pr_cdageini  -- PA inicio
															,pr_cdoperad => pr_cdoperad  -- Cód. operador
															,pr_nmdatela => pr_nmdatela  -- Nome da tela
															,pr_nrdcaixa => pr_nrdcaixa  -- Nr. do caixa
															,pr_cdbccxlt => pr_cdbccxlt  -- Cód. do banco
															,pr_nrdolote => pr_nrdolote  -- Nr. do lote																		
															,pr_cdcritic => pr_cdcritic -- Cód. da crítica
															,pr_dscritic => pr_dscritic  -- Desc. da crítica
															,pr_qtarquiv => pr_qtarquiv -- Quantidade de arquivos
															,pr_totregis => pr_totregis -- Total de registros
															,pr_vlrtotal => pr_vlrtotal);  -- Valor total
																					
			-- Desbloquear resgate de cheque durante envio para ABBC
		  pc_bloquear_resgate_cheque(pr_cdcooper => pr_cdcooper
			                          ,pr_dsresgat => 'N'
																,pr_des_erro => vr_des_erro);
					
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END pc_gerar_arquivos_compel;
	
	-- Bloquear/Desbloquear resgate de cheque
	PROCEDURE pc_bloquear_resgate_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE
		                                  ,pr_dsresgat IN VARCHAR2
																			,pr_des_erro OUT VARCHAR2) IS
	BEGIN
	-- ..........................................................................
	-- Programa: pc_bloquear_resgate_cheque
	-- Sistema : Conta-Corrente - Cooperativa de Credito
	-- Sigla   : CRED
	-- Autor   : Lucas Reinert
	-- Data    : Outubro/2016.                     Ultima atualizacao:

	-- Dados referentes ao programa:

	-- Frequencia: Sempre que for chamada
	-- Objetivo  : Rotina para bloquear/desbloquear resgate de cheque

	-- Alteracoes:
	--
	-- .............................................................................		
	DECLARE
	   -- Rowid da tab
     vr_rowid ROWID;

		/* Cursor genérico e padrão para busca da craptab */
		CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
										 ,pr_nmsistem IN craptab.nmsistem%TYPE
										 ,pr_tptabela IN craptab.tptabela%TYPE
										 ,pr_cdempres IN craptab.cdempres%TYPE
										 ,pr_cdacesso IN craptab.cdacesso%TYPE
										 ,pr_tpregist IN craptab.tpregist%TYPE) IS
			SELECT /*+index_asc (tab CRAPTAB##CRAPTAB1)*/
						 tab.rowid
				from craptab tab
			 where tab.cdcooper = pr_cdcooper
				 and upper(tab.nmsistem) = pr_nmsistem
				 and upper(tab.tptabela) = pr_tptabela
				 and tab.cdempres = pr_cdempres
				 and upper(tab.cdacesso) = nvl(pr_cdacesso, tab.cdacesso)
				 and tab.tpregist = nvl(pr_tpregist, tab.tpregist);
		  
	BEGIN

    -- Verifica se existe tab
    OPEN cr_craptab(pr_cdcooper => pr_cdcooper
		               ,pr_nmsistem => 'CRED'
									 ,pr_tptabela => 'USUARI'
									 ,pr_cdempres => 11
									 ,pr_cdacesso => 'BLQRESGCHQ'
									 ,pr_tpregist => 00);
		FETCH cr_craptab INTO vr_rowid;
		
		-- Se não encontrou
		IF cr_craptab%NOTFOUND THEN
			-- Cria registro
		  INSERT INTO craptab (nmsistem, tptabela, cdempres, cdacesso, tpregist, dstextab, cdcooper)
			             VALUES ('CRED', 'USUARI', 11, 'BLQRESGCHQ', 00, pr_dsresgat, pr_cdcooper);
		ELSE
			-- Atualiza registro
			UPDATE craptab tab
				 SET tab.dstextab = pr_dsresgat
			 WHERE tab.rowid = vr_rowid;
		END IF;
		
		-- Retorno OK
		pr_des_erro := 'OK';
		-- Efetuar commit
		COMMIT;
	
	EXCEPTION
		WHEN OTHERS THEN
			-- Retorno NOK
			pr_des_erro := 'NOK';			
		END;
	END pc_bloquear_resgate_cheque;
	
	
	PROCEDURE pc_gerar_compel_custodia(pr_dtmvtolt IN DATE         -- Data de movimento
																		,pr_cdcooper IN PLS_INTEGER  -- Cooperativa
																		,pr_cdagenci IN PLS_INTEGER  -- PA inicio
																		,pr_cdoperad IN VARCHAR2     -- Cód. operador
																		,pr_nmdatela IN VARCHAR2     -- Nome da tela
																		,pr_nrdcaixa IN PLS_INTEGER  -- Nr. do caixa
																		,pr_cdbccxlt IN VARCHAR2     -- Cód. do banco
																		,pr_nrdolote IN PLS_INTEGER  -- Nr. do lote																		
                                    ,pr_cdcritic OUT PLS_INTEGER -- Cód. da crítica
																		,pr_dscritic OUT VARCHAR2    -- Desc. da crítica
																		,pr_qtarquiv OUT PLS_INTEGER -- Quantidade de arquivos
																		,pr_totregis OUT PLS_INTEGER -- Total de registros
																		,pr_vlrtotal OUT NUMBER) IS  -- Valor total
	BEGIN
	-- ..........................................................................
	-- Programa: pc_gerar_compel_custodia (Antiga: B1wgen0012.p/gerar_comel_custodia )
	-- Sistema : Conta-Corrente - Cooperativa de Credito
	-- Sigla   : CRED
	-- Autor   : Lucas Reinert
	-- Data    : Outubro/2016.                     Ultima atualizacao:

	-- Dados referentes ao programa:

	-- Frequencia: Sempre que for chamada
	-- Objetivo  : Rotina para gerar arquivo de prévia de custódia

	-- Alteracoes: 26/05/2017 - Alterar o caracter de fim de linha (13), para o 
	--                          caracter (10), de forma que o programa gere o arquivo
	--                          igual ao Progress.   (Renato Darosci - Supero)
	-- .............................................................................		
		DECLARE
		  vr_exc_erro EXCEPTION;
		  vr_cdcritic PLS_INTEGER;
			vr_des_erro VARCHAR2(1000);
			vr_typ_said VARCHAR2(10);
			vr_dscritic VARCHAR2(1000);
			-- Variáveis auxiliares
			vr_dstextab craptab.dstextab%TYPE;
			vr_vlchqmai NUMBER;
			vr_cdcmpchq crapage.cdcomchq%TYPE;
			vr_mesarqui VARCHAR2(1);
			vr_nrseqarq NUMBER;
			vr_nmarqdat VARCHAR2(1000);
			vr_flcooper BOOLEAN := FALSE;
			vr_dschqctl VARCHAR2(45);
			vr_vltotcst NUMBER;
			vr_nrctachq VARCHAR2(12);
			vr_nrdigdv1 VARCHAR2(1);
			vr_nrdigdv2 VARCHAR2(1);
			vr_nrdigdv3 VARCHAR2(1);
      vr_dsdirmic	VARCHAR2(1000);
			vr_flgfctar BOOLEAN := FALSE;
			vr_vet_dados gene0002.typ_split;
			vr_cdoperad VARCHAR2(100);
			vr_caminarq VARCHAR2(200);
			vr_caminsal VARCHAR2(200);
			vr_dscomand VARCHAR2(4000);
			vr_dsarqshl VARCHAR2(200);
			-- Clob com dados do arquivo
			vr_clob CLOB;
			
			/* Cursor genérico e padrão para busca da craptab */
			CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
											 ,pr_nmsistem IN craptab.nmsistem%TYPE
											 ,pr_tptabela IN craptab.tptabela%TYPE
											 ,pr_cdempres IN craptab.cdempres%TYPE
											 ,pr_cdacesso IN craptab.cdacesso%TYPE
											 ,pr_tpregist IN craptab.tpregist%TYPE
											 ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
				SELECT /*+index_asc (tab CRAPTAB##CRAPTAB1)*/
							 tab.dstextab
					FROM craptab tab
				 WHERE tab.cdcooper = pr_cdcooper
					 AND UPPER(tab.nmsistem) = pr_nmsistem
					 AND UPPER(tab.tptabela) = pr_tptabela
					 AND tab.cdempres = pr_cdempres
					 AND UPPER(tab.cdacesso) = NVL(pr_cdacesso, tab.cdacesso)
					 AND tab.tpregist = nvl(pr_tpregist, tab.tpregist)
					 AND UPPER(tab.dstextab) LIKE '%#' || pr_cdoperad || '|%';
      rw_craptab cr_craptab%ROWTYPE;					 
			
			-- Selecionar os dados da Cooperativa
			CURSOR cr_crapcop( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				SELECT cop.cdbcoctl
				      ,cop.cdagectl
				      ,cop.nrdivctl
							,cop.dsdircop
					FROM crapcop cop
				 WHERE cop.cdcooper = pr_cdcooper;
			rw_crapcop cr_crapcop%ROWTYPE;
			
			-- Cursor para busca a agencia
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT 1
        FROM crapage crapage
        WHERE crapage.cdcooper = pr_cdcooper 
        AND   crapage.cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;   
			
			-- Buscar PA sede
			CURSOR cr_crapage_sede(pr_cdcooper IN crapage.cdcooper%TYPE) IS
			  SELECT age.cdcomchq
				  FROM crapage age
				 WHERE age.cdcooper = pr_cdcooper
				   AND age.flgdsede = 1;
			rw_crapage_sede cr_crapage_sede%ROWTYPE;
			
			CURSOR cr_crapdat_arq(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
			  SELECT DECODE(to_char(pr_dtmvtolt, 'MM')
										 ,10, 'O' -- Outubro
										 ,11, 'N' -- Novembro
										 ,12, 'D' -- Dezembro
										 ,to_number(to_char(pr_dtmvtolt, 'MM')))
					FROM dual;
					
		  -- Buscar registros de custodia
			CURSOR cr_crapcst(pr_cdcooper IN crapcst.cdcooper%TYPE
			                 ,pr_dtmvtolt IN crapcst.dtmvtolt%TYPE
											 ,pr_cdagenci IN crapcst.cdagenci%TYPE
											 ,pr_nrdolote IN crapcst.nrdolote%TYPE) IS
				SELECT cst.dtmvtolt
				      ,cst.nrdconta
							,cst.cdcmpchq							
							,cst.cdbanchq
							,cst.cdagechq
							,cst.inchqcop
							,cst.vlcheque
							,cst.dsdocmc7
							,cst.nrctachq
							,cst.nrcheque
							,cst.dtlibera
							,cst.rowid
							,COUNT(1) OVER (PARTITION BY cst.dtmvtolt) qtdreg
							,ROW_NUMBER() OVER(PARTITION BY cst.dtmvtolt ORDER BY cst.dtmvtolt DESC) SEQ
					FROM crapcst cst
				 WHERE cst.cdcooper = pr_cdcooper
					 AND cst.dtmvtolt = pr_dtmvtolt
					 AND cst.cdagenci = pr_cdagenci
					 AND cst.insitprv = 0
					 AND cst.nrdolote = pr_nrdolote
					 AND cst.insitchq IN (0,2)
					 ORDER BY cst.dtmvtolt;
			
		BEGIN
			-- Verifica se a cooperativa esta cadastrada
			OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
			FETCH cr_crapcop INTO rw_crapcop;
			-- Se não encontrar
			IF cr_crapcop%NOTFOUND THEN
				-- Fechar o cursor pois haverá raise
				CLOSE cr_crapcop;
				-- Montar mensagem de critica
				vr_cdcritic := 651;
				RAISE vr_exc_erro;
			ELSE
				-- Apenas fechar o cursor
				CLOSE cr_crapcop;
			END IF;
			
			--Selecionar Dados Agencia
			OPEN cr_crapage(pr_cdcooper => pr_cdcooper
										 ,pr_cdagenci => pr_cdagenci);
			FETCH cr_crapage INTO rw_crapage;
			--Se nao Encontrou            
			IF cr_crapage%NOTFOUND THEN
				--Fechar Cursor
				CLOSE cr_crapage;
				--Codigo Critica    
				vr_cdcritic:= 962;
				--Sair
				RAISE vr_exc_erro;
			END IF;  
			-- Fechar o cursor
			CLOSE cr_crapage;
	
	    -- Busca parametro
	    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
																							 ,pr_nmsistem => 'CRED'
																							 ,pr_tptabela => 'USUARI'
																							 ,pr_cdempres => 11
																							 ,pr_cdacesso => 'MAIORESCHQ'
																							 ,pr_tpregist => 01);
	    -- Se não encontrou                       
      IF TRIM(vr_dstextab) IS NULL THEN
				--Codigo Critica    
				vr_cdcritic:= 55;
				--Sair
				RAISE vr_exc_erro;				
			ELSE 
				-- Atribui valor do parametro
				vr_vlchqmai := to_number(substr(vr_dstextab, 1, 15));
			END IF;
	
	    -- Busca PA sede
	    OPEN cr_crapage_sede(pr_cdcooper => pr_cdcooper);
			FETCH cr_crapage_sede INTO rw_crapage_sede;
			
			-- Se não encontrou
			IF cr_crapage_sede%NOTFOUND THEN
				-- Atribui 0
				vr_cdcmpchq := 0;
			ELSE	
				-- Atribui código de compensação do cheque
				vr_cdcmpchq := rw_crapage_sede.cdcomchq;
			END IF;		
			-- Fecha cursor
      CLOSE cr_crapage_sede;
			
      -- Busca mês do arquivo
      OPEN cr_crapdat_arq(pr_dtmvtolt => pr_dtmvtolt);
			FETCH cr_crapdat_arq INTO vr_mesarqui;
	    -- Fecha cursor
			CLOSE cr_crapdat_arq;
	
	    -- Monta nome do arquivo e sequência
	    vr_nrseqarq := 1;
			vr_nmarqdat := 'custodia-' ||
			               to_char(pr_cdagenci, 'fm000')    || '-' ||
										 to_char(pr_dtmvtolt, 'RRRRMMDD') || '-' ||
										 to_char(pr_nrdolote, 'fm000000') || '.txt';

			-- Percorre os cheques em custódia
			FOR rw_crapcst IN cr_crapcst(pr_cdcooper => pr_cdcooper
																	,pr_dtmvtolt => pr_dtmvtolt
																	,pr_cdagenci => pr_cdagenci
																	,pr_nrdolote => pr_nrdolote) LOOP
					
				 -- Se for o primeiro registro
				 IF rw_crapcst.seq = 1 THEN
					 -- Gerar header do arquivo
					 vr_clob := rpad('0',47,'0')
									 || 'CUS605'                               -- Nome
									 || to_char(vr_cdcmpchq, 'fm000')          -- Compe
									 || '0001'                                 -- Versão
									 || to_char(rw_crapcop.cdbcoctl,'fm000')   -- Banco
									 || to_char(rw_crapcop.nrdivctl,'fm0')     -- DC
									 || '2'                                    -- Indicador de remessa
									 || to_char(pr_dtmvtolt, 'RRRR')           -- Ano
									 || to_char(pr_dtmvtolt, 'MM')             -- Mês
									 || to_char(pr_dtmvtolt, 'DD')             -- Dia										 
									 || rpad(' ',77,' ')
									 || to_char(vr_nrseqarq, 'fm0000000000')
									 || CHR(10);
				 END IF;
					 
				 -- Identificar se o cheque é da COOPER
				 IF pr_cdcooper = 1 AND
						vr_flcooper = FALSE THEN
				      
						-- Para os cheques do PA 1 ou 27 digitaliza na Sede
						IF rw_crapcst.nrdconta = 85448 AND
							(pr_cdagenci = 1             OR
							 pr_cdagenci = 27)           THEN
							 vr_flcooper := TRUE;
						END IF;
							
				 END IF;
					 					 
				 -- Se banco e agencia do cheque forem da cooperativa
				 IF rw_crapcst.cdbanchq = rw_crapcop.cdbcoctl AND
						rw_crapcst.cdagechq = rw_crapcop.cdagectl THEN
						vr_dschqctl	:= 'PG_CX ';
				 ELSE
					 IF pr_cdcooper = 16        AND
							rw_crapcst.inchqcop = 1 THEN
							vr_dschqctl	:= 'PG_CX ';
					 ELSE
							vr_dschqctl	:= '      ';
					 END IF;
				 END IF;
					 
				 -- Incrementa nr. de sequencia, total de registros e valor total 
				 vr_nrseqarq := nvl(vr_nrseqarq,0) + 1;
				 pr_totregis := nvl(pr_totregis,0) + 1;
				 vr_vltotcst := nvl(vr_vltotcst,0) + rw_crapcst.vlcheque;
					 
				 -- Banco do brasil
				 IF rw_crapcst.cdbanchq = 1 THEN
					 vr_nrctachq := '0' || substr(rw_crapcst.dsdocmc7, 22, 11);
				 ELSE
					 -- Outros bancos
					 vr_nrctachq := to_char(rw_crapcst.nrctachq, 'fm000000000000');
				 END IF;
					 
				 -- Busca digitos do cmc7
				 vr_nrdigdv2 := substr(rw_crapcst.dsdocmc7, 9, 1);
				 vr_nrdigdv1 := substr(rw_crapcst.dsdocmc7, 22, 1);
				 vr_nrdigdv3 := substr(rw_crapcst.dsdocmc7, 33, 1);
					 
				 vr_clob := vr_clob
								 || to_char(rw_crapcst.cdcmpchq, 'fm000')  -- Compe
								 || to_char(rw_crapcst.cdbanchq, 'fm000')  -- Banco destino 
								 || to_char(rw_crapcst.cdagechq, 'fm0000') -- Agência destino
								 || vr_nrdigdv2                            -- Número digito verificador 2
								 || vr_nrctachq                            -- Número da conta cheque
								 || vr_nrdigdv1                            -- Número digito verificador 1
								 || to_char(rw_crapcst.nrcheque,'fm000000')-- Número Cheque
								 || vr_nrdigdv3                            -- Número digito verificador 3
								 || '  '                                   -- UF
								 || to_char(rw_crapcst.vlcheque * 100, 'fm00000000000000000') -- Valor do cheque
								 || substr(rw_crapcst.dsdocmc7, 20, 1)     -- Tipificação
								 || '11'                                   -- Entrada
								 || '00'                                   -- Filler
								 || to_char(rw_crapcop.cdbcoctl, 'fm000')  -- Banco cecred
								 || to_char(rw_crapcop.cdagectl, 'fm0000') -- Agência cecred
								 || to_char(rw_crapcop.cdagectl, 'fm0000') -- Agência cecred
								 || to_char(rw_crapcst.nrdconta, 'fm000000000000') -- Número da conta
								 || to_char(vr_cdcmpchq, 'fm000')          -- Compe
								 || to_char(rw_crapcst.dtlibera, 'RRRR')   -- Ano liberação
								 || to_char(rw_crapcst.dtlibera, 'MM')     -- Mês liberação
								 || to_char(rw_crapcst.dtlibera, 'DD')     -- Dia liberação
								 || RPAD('0', 7, '0')                       -- Número lote
								 || RPAD('0', 3, '0')                       -- Sequência lote
								 || vr_dschqctl                            -- Centro processador
								 || RPAD('0', 24, '0') || '1'               -- Código identificador
								 || RPAD(' ', 17, ' ');                     -- Filler
					
				IF rw_crapcst.vlcheque >= vr_vlchqmai	THEN
					vr_clob := vr_clob
									|| '030'; -- TD
				ELSE
					vr_clob := vr_clob
									|| '034';	-- TD					
				END IF;
					
				vr_clob := vr_clob
								|| to_char(vr_nrseqarq,'fm0000000000')	-- Sequência
								|| chr(10);

				-- Último registro
				IF rw_crapcst.seq = rw_crapcst.qtdreg THEN
						
					vr_nrseqarq := vr_nrseqarq + 1;
					pr_qtarquiv := nvl(pr_qtarquiv,0) + 1;
						
					-- Montar trailer						
					vr_clob := vr_clob
									|| RPAD('9',47,'9')              -- Header
									|| 'CUS605'                     -- Nome
									|| to_char(vr_cdcmpchq,'fm000') -- Compe
									|| '0001'                       -- Vers
									|| to_char(rw_crapcop.cdbcoctl,'fm000') -- Banco
									|| to_char(rw_crapcop.nrdivctl,'fm0') -- dv
									|| '1'                          -- Indicador rem.
									|| to_char(pr_dtmvtolt, 'RRRR') -- Ano 
									|| to_char(pr_dtmvtolt, 'MM')   -- Mês 
									|| to_char(pr_dtmvtolt, 'DD')   -- Dia 
									|| to_char(vr_vltotcst * 100, 'fm00000000000000000')
									|| RPAD(' ',60,' ')              -- Filler
									|| to_char(vr_nrseqarq,'fm0000000000') -- SEQ
									|| chr(10);
							
					-- Tratamento para verificar se o operador está na força tarefa da viacredi			
					IF pr_cdcooper = 1 THEN
						-- Buscar registro de operadores destinos específicos para digitalização
						OPEN cr_craptab(pr_cdcooper => pr_cdcooper
													 ,pr_nmsistem => 'CRED'
													 ,pr_tptabela => 'GENERI'
													 ,pr_cdempres => 0
													 ,pr_cdacesso => 'OPEDIGITEXC'
													 ,pr_tpregist => 0
													 ,pr_cdoperad => upper(pr_cdoperad));
						FETCH cr_craptab INTO rw_craptab;
							
						vr_dsdirmic := '';
						-- Se encontrou				
						IF cr_craptab%FOUND THEN
							
							-- Efetuar o split das informacoes contidas na dstextab separados por ;
							vr_vet_dados := gene0002.fn_quebra_string(pr_string  => rw_craptab.dstextab
																											 ,pr_delimit => ';');
							-- Para cada registro encontrado
							FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP
								-- Guardar a informacao antes do |
								vr_cdoperad := substr(gene0002.fn_busca_entrada(1,vr_vet_dados(vr_pos),'|'),2);
									
								IF vr_cdoperad = UPPER(pr_cdoperad) THEN
									-- Guardar a informacao apos o # na aliquota
									vr_dsdirmic := substr(gene0002.fn_busca_entrada(2,vr_vet_dados(vr_pos),'|'),3);
									vr_flgfctar := TRUE;
								END IF;
							END LOOP;
	
						END IF;
						-- Fecha cursor
						CLOSE cr_craptab;
					END IF;

					-- Se não for da força tarefa						
					IF NOT vr_flgfctar THEN
							
						 vr_dsdirmic := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
																										 , pr_nmsistem => 'CRED'
																										 , pr_tptabela => 'GENERI'
																										 , pr_cdempres => 0
																										 , pr_cdacesso => 'MICROCUSTOD'
																										 , pr_tpregist => pr_cdagenci);
						vr_dsdirmic := substr(vr_dsdirmic, 3);
					END IF;
						
					-- Se não encontrou diretório
					IF trim(vr_dsdirmic) IS NULL THEN
						-- Atribui crítica
						vr_cdcritic := 782;
						-- Levanta exceção
						RAISE vr_exc_erro;
					END IF;
					
					-- Buscar diretório da coopertaiva
					vr_caminarq := gene0001.fn_diretorio(pr_tpdireto => 'C'
					                                   , pr_cdcooper => pr_cdcooper
																						 , pr_nmsubdir => 'arq');
					
					-- Gerar arquivo
					gene0002.pc_clob_para_arquivo(pr_clob => vr_clob
					                            , pr_caminho => vr_caminarq
																			, pr_arquivo => vr_nmarqdat
																			, pr_des_erro => vr_des_erro);

          -- Se ocorreu erro na criação do arquivo																			
					IF vr_des_erro IS NOT NULL THEN						
						vr_dscritic := 'Erro ao gerar arquivo ' || vr_nmarqdat || ': ' || vr_des_erro;
						RAISE vr_exc_erro;
					END IF;
					
					vr_dsarqshl := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => '0'
                                                  ,pr_cdacesso => 'ENVIA_ARQ_TRUNC');
					
 					vr_dscomand :=  vr_dsarqshl || ' ' ||
													vr_dsdirmic || ' CUS digit01 cecred.coop.br/digitalizar ' 
													|| vr_nmarqdat || ' ' || rw_crapcop.dsdircop || ' ' 
													|| to_char(pr_cdagenci,'fm0000') || ' 2>/dev/null';
													
					-- Executa o comando no shell
					gene0001.pc_OScommand_Shell(pr_des_comando => vr_dscomand
																		 ,pr_typ_saida   => vr_typ_said
																		 ,pr_des_saida   => vr_des_erro);
					-- Se houve saida com erro OU out
					IF vr_typ_said IN('ERR') THEN
						-- O comando shell executou com erro, gerar log e sair do processo
						vr_dscritic := 'Erro ao executar o comando de envio do arquivo '||vr_nmarqdat||': ' || vr_des_erro;
						
						-- Remove o arquivo
            vr_dscomand :=  'rm ' || vr_caminarq || '/' || vr_nmarqdat;   
					
						-- Executa o comando no shell
						gene0001.pc_OScommand_Shell(pr_des_comando => vr_dscomand
																			 ,pr_typ_saida   => vr_typ_said
																			 ,pr_des_saida   => vr_des_erro);
						
						RAISE vr_exc_erro;
					ELSE
						-- Buscar diretório da coopertaiva
						vr_caminsal := gene0001.fn_diretorio(pr_tpdireto => 'C'
																							 , pr_cdcooper => pr_cdcooper
																							 , pr_nmsubdir => 'salvar');

						-- Move para o salvar
						vr_dscomand :=  'mv ' || vr_caminarq || '/' || vr_nmarqdat || ' ' 
						                || vr_caminsal || '/' || vr_nmarqdat || '_' 
														|| TO_CHAR(SYSDATE, 'SSSSS');
					
						-- Executa o comando no shell
						gene0001.pc_OScommand_Shell(pr_des_comando => vr_dscomand
																			 ,pr_typ_saida   => vr_typ_said
																			 ,pr_des_saida   => vr_des_erro);
					END IF;
					
				END IF;			
				-- Atualiza situação da geração de prévia	
				UPDATE crapcst cst
					 SET cst.insitprv = 1
							,cst.dtprevia = trunc(SYSDATE)
				 WHERE cst.rowid = rw_crapcst.rowid;
				 
			END LOOP;
			-- Retornar valor total
		  pr_vlrtotal := nvl(vr_vltotcst,0);
	
		EXCEPTION
			WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				END IF;
				-- Atribui crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				ROLLBACK;
		END;	
	END pc_gerar_compel_custodia;
	 
  
  
  
PROCEDURE pc_gera_rel782(pr_cdcooper IN NUMBER,
                         pr_cdcritic OUT crapcri.cdcritic%TYPE,
                         pr_dscritic OUT VARCHAR2) is
  
  --Variaveis erro
  vr_des_erro varchar2(4000);  
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        VARCHAR2(4000);
  vr_exc_saida EXCEPTION;
  
  --variaveis
  vr_typsaida        VARCHAR2(100);
  vr_caminho_integra VARCHAR2(1000);
  vr_tab_craterr     GENE0001.typ_tab_erro; --> PL Table de erros do sistema
  vr_nmarqpdf        VARCHAR2(4000);
   
  --Busca os dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop, cop.nmextcop, cop.cdbcoctl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
   --Cursor para buscar relatorios
    CURSOR cr_crapslr(pr_cdcooper crapslr.cdcooper%TYPE,
                      pr_dtmvtolt crapslr.dtmvtolt%TYPE) IS
     select nrseqsol 
       from crapslr 
      where dtmvtolt = pr_dtmvtolt
            and cdprogra in ('CRPS341','CRPS290') 
            and cdcooper = pr_cdcooper;
    rw_crapslr cr_crapslr%ROWTYPE;
  
begin
  
  -- ..........................................................................
	-- Programa: pc_gera_rel782
	-- Sistema : Conta-Corrente - Cooperativa de Credito
	-- Sigla   : CRED
	-- Autor   : Jackson Barcellos AMcom
	-- Data    : Junho/2019.                     Ultima atualizacao:

	-- Dados referentes ao programa:

	-- Frequencia: Job Diario as 07:00
	-- Objetivo  : Rotina para unificar 2 relatorios em 1 (crrl238 + crrl287) = crrl782

	-- Alteracoes:
	-- .............................................................................	

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
  FETCH cr_crapcop
    INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Verificacao do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;
  -- Se nao encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  -- Apenas fechar o cursor
  CLOSE BTCH0001.cr_crapdat;
  
  --Loop nos registros para reimprimir
  FOR rw_crapslr IN cr_crapslr(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP  
    --gerar relatorios para unificar
    gene0002.pc_gera_relato(pr_nrseqsol => rw_crapslr.nrseqsol
                               ,pr_des_erro => vr_des_erro);
    IF vr_des_erro is not null then
       vr_cdcritic := 0;
       vr_dscritic := 'Erro ao gerar relatorio origem: '||vr_des_erro;
       DBMS_OUTPUT.PUT_LINE(vr_dscritic);
    END IF;
  END LOOP;
  -- busca caminho dos relatorios
  vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- unifica os relatorios
  gene0001.pc_OScommand(pr_typ_comando => 'S',
                        pr_des_comando => 'cat ' || vr_caminho_integra ||
                                          '/crrl238.lst ' ||
                                          vr_caminho_integra ||
                                          '/crrl287.lst > ' ||
                                          vr_caminho_integra ||
                                          '/crrl782.lst',
                        pr_typ_saida   => vr_typsaida,
                        pr_des_saida   => vr_dscritic);
  IF vr_dscritic is not null then
     vr_cdcritic := 0;
     vr_dscritic := 'Erro ao unificar os relatorio origem: '||vr_dscritic;
  END IF;

  -- imprime relatorio novo                      
  gene0002.pc_imprim(pr_cdcooper   => pr_cdcooper --> Cooperativa conectada
                    ,pr_cdprogra   => 'COMP0001' --> Nome do programa que solicitou o rep
                    ,pr_cdrelato   => 782 --> Código do relatório solicitado
                    ,pr_dtmvtolt   => rw_crapdat.dtmvtolt --> Data movimento atual
                    ,pr_caminho    => vr_caminho_integra --> Path arquivo origem
                    ,pr_nmarqimp   => 'crrl782.lst' --> Nome arquivo para impressao
                    ,pr_nmformul   => '132col' --> Nome do formulário de impressão
                    ,pr_nrcopias   => 1 --> Quantidade de Copias desejadas
                    ,pr_dircop_pdf => vr_nmarqpdf --> Retorna o caminho do PDF gerado pela imprim.p
                    ,pr_cdcritic   => vr_cdcritic --> Código do erro
                    ,pr_dscritic   => vr_dscritic); --> Saída com erro
                    
  IF vr_dscritic is not null then
     vr_cdcritic := 0;
     vr_dscritic := 'Erro ao imprimir novo relatorio unificado: '||vr_dscritic;
  END IF;

  -- remove relatorios originais                   
  gene0001.pc_OScommand(pr_typ_comando => 'S',
                        pr_des_comando => 'rm ' || vr_caminho_integra ||
                                          '/crrl238.lst ',
                        pr_typ_saida   => vr_typsaida,
                        pr_des_saida   => vr_dscritic);
  gene0001.pc_OScommand(pr_typ_comando => 'S',
                        pr_des_comando => 'rm ' || vr_caminho_integra ||
                                          '/crrl287.lst ',
                        pr_typ_saida   => vr_typsaida,
                        pr_des_saida   => vr_dscritic); 
                        
  IF vr_dscritic is not null then
     vr_cdcritic := 0;
     vr_dscritic := 'Erro ao remover relatorios origem: '||vr_dscritic;
  END IF;

  COMMIT;                                          
                    
EXCEPTION
  
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;        
end;

--PROJ.565
PROCEDURE pc_checa_compel(pr_cdcooper IN craptit.CDCOOPER%type,
                           pr_nmarquiv IN VARCHAR2,
                           pr_cdagectl IN crapcop.cdagectl%TYPE,
                           pr_cdagenci IN craptit.cdagenci%TYPE,
                           pr_dtmvtolt IN craptit.dtmvtolt%TYPE, -- Data da Mov
                           pr_totregis IN NUMBER,
                           pr_vltotarq IN NUMBER,
                           pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Código da crítica
                           pr_dscritic OUT VARCHAR2) IS

  -- Variáveis de erro 
  vr_exc_saida EXCEPTION;
  -- Variáveis de criticas 

BEGIN
  
   IF pr_nmarquiv = ' ' THEN
           DELETE tbcompe_nossaremessa a
           WHERE a.cdcooper = pr_cdcooper
             AND a.tparquiv = 3
             AND a.cdagenci = pr_cdagenci
             AND a.DTARQUIV = pr_dtmvtolt;
   ELSE
        IF cr_tbcompe_nossaremessa%ISOPEN THEN
          close cr_tbcompe_nossaremessa;
        END IF;
        OPEN cr_tbcompe_nossaremessa(pr_cdcooper, pr_cdagenci, 3, pr_dtmvtolt,pr_nmarquiv);
        FETCH cr_tbcompe_nossaremessa INTO rw_tbcompe_nossaremessa;
        IF cr_tbcompe_nossaremessa%FOUND THEN
          UPDATE tbcompe_nossaremessa a
             SET a.qtenviad = pr_totregis,
                 a.qtproces = 0,
                 a.vlenviad = pr_vltotarq,
                 a.vlproces = 0,
                 a.nmarquiv = pr_nmarquiv
           WHERE rowid = rw_tbcompe_nossaremessa.rowid;
        ELSE

          BEGIN
          -- fazer insert na nova tabela [tbcompe_nossaremessa]
          -- inicio
          INSERT INTO tbcompe_nossaremessa
            (cdcooper,
             cdagenci,
             tparquiv,
             dtarquiv,
             nmarquiv,
             qtenviad,
             vlenviad,
             qtproces,
             vlproces,
             insituac,
             dtevinst,
             dtrtinst)
          VALUES
            (pr_cdcooper,
             pr_cdagenci,
             3, -- Tipo de Arquivo: 1 - DEVOLUCAO DIURNA, 2 - DEVOLUCAO FRAUDES E IMPEDIMENTOS, 3 - COMPEL, 4 - TITULOS.
             pr_dtmvtolt,
             pr_nmarquiv,
             pr_totregis, --qtenviad,
             pr_vltotarq, --vlenviad,
             0, --qtproces,
             0, --vlproces,
             'Aguardando retorno ABBC', --insituac
             '', --dtevinst
             '' --dtrtinst
             );
          
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := SQLERRM;
            
        END;
        close cr_tbcompe_nossaremessa;
      END IF;

   END IF;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
END pc_checa_compel;

-- PROJ.565

PROCEDURE pc_checa_titulos(pr_cdcooper IN craptit.CDCOOPER%type,
                           pr_nmarquiv IN VARCHAR2,
                           pr_cdagectl IN crapcop.cdagectl%TYPE,
                           pr_cdagenci IN craptit.cdagenci%TYPE,
                           pr_dtmvtolt IN craptit.dtmvtolt%TYPE, -- Data da Mov
                           pr_totregis IN NUMBER,
                           pr_vltotarq IN NUMBER,
                           pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Código da crítica
                           pr_dscritic OUT VARCHAR2) IS
  --4 - TITILOS --TPARQUIV

  -- cursores --
  --Cursor para buscar a QTD e VL.Total de <registros enviados>
  CURSOR cr_craptit(pr_cdcooper IN craptit.CDCOOPER%type,
                    pr_cdagenci IN craptit.cdagenci%TYPE,
                    pr_dtmvtolt IN craptit.dtmvtolt%TYPE) IS
  
    SELECT COUNT(1) qtd, SUM(craptit.vldpagto) soma
      FROM craptit
     WHERE craptit.cdcooper = pr_cdcooper --<Cooperativa>
       AND craptit.dtmvtolt = pr_dtmvtolt --'28/03/2019'--<Data de envio>
       AND craptit.cdagenci = pr_cdagenci --1 --<PA>             
       AND craptit.insittit IN (0, 2, 4)
       AND craptit.tpdocmto = 20
       and craptit.intitcop = 0;
  rw_craptit cr_craptit%ROWTYPE;
  -------------------------------------------------------------------------
  --Cursor para buscar a QTD e VL.Total de <registros processados>
  CURSOR cr_gncptit(pr_cdcooper IN gncptit.cdcooper%TYPE,
                    pr_cdagenci IN gncptit.cdagenci%TYPE,
                    pr_dtmvtolt IN gncptit.dtmvtolt%TYPE) IS
  
    SELECT COUNT(1) qtd, SUM(vldpagto) soma
      FROM gncptit
     WHERE gncptit.cdcooper = pr_cdcooper --<Cooperativa>
       AND gncptit.dtmvtolt = pr_dtmvtolt --'28/03/2019'--<Data de envio>
       AND gncptit.cdagenci = pr_cdagenci --1 --pr_cdagenci --1 --<PA>
       and gncptit.cdoperad = '1';
       
  rw_gncptit cr_gncptit%ROWTYPE;

  -- Variáveis de erro 
  vr_exc_saida EXCEPTION;
  -- Variáveis de criticas 

BEGIN

   IF pr_nmarquiv = ' ' THEN
           DELETE tbcompe_nossaremessa a
           WHERE a.cdcooper = pr_cdcooper
             AND a.tparquiv = 4
             AND a.cdagenci = pr_cdagenci
             AND a.DTARQUIV = pr_dtmvtolt;
   ELSE
      OPEN cr_tbcompe_nossaremessa(pr_cdcooper, pr_cdagenci, 4, pr_dtmvtolt,pr_nmarquiv);
      FETCH cr_tbcompe_nossaremessa INTO rw_tbcompe_nossaremessa;
      IF cr_tbcompe_nossaremessa%FOUND THEN
        UPDATE tbcompe_nossaremessa a
           SET a.qtenviad = pr_totregis,
               a.qtproces = 0,
               a.vlenviad = pr_vltotarq,
               a.vlproces = 0
         WHERE rowid = rw_tbcompe_nossaremessa.rowid;
      ELSE
        BEGIN
          -- fazer insert na nova tabela [tbcompe_nossaremessa]
          -- inicio
          INSERT INTO tbcompe_nossaremessa
            (cdcooper,
             cdagenci,
             tparquiv,
             dtarquiv,
             nmarquiv,
             qtenviad,
             vlenviad,
             qtproces,
             vlproces,
             insituac,
             dtevinst,
             dtrtinst)
          VALUES
            (pr_cdcooper,
             pr_cdagenci,
             4, -- TITULOS.
             pr_dtmvtolt,
             pr_nmarquiv,
             pr_totregis, --qtenviad,
             pr_vltotarq, --vlenviad,
             0, --qtproces,
             0, --vlproces,
             'Aguardando retorno ABBC', --insituac
             '', --dtevinst
             '' --dtrtinst
             );
          
        EXCEPTION
          WHEN OTHERS THEN
            null;
            
        END;
      END IF;
      CLOSE cr_tbcompe_nossaremessa;
   END IF;


END pc_checa_titulos;

-- PROJ.565
PROCEDURE pc_checa_devolu (pr_cdcooper IN craptit.CDCOOPER%type,
                           pr_nmarquiv IN VARCHAR2,
                           pr_cdagectl IN crapcop.cdagectl%TYPE,
                           pr_cdagenci IN craptit.cdagenci%TYPE,
                           pr_dtmvtolt IN craptit.dtmvtolt%TYPE, -- Data da Mov
                           pr_totregis IN NUMBER,
                           pr_vltotarq IN NUMBER,
                           pr_tparquiv IN tbcompe_nossaremessa.tparquiv%TYPE,
                           pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Código da crítica
                           pr_dscritic OUT VARCHAR2) IS
  -- .......................................................................................................
  --1 - Dev.Diurna  --TPARQUIV
  -- cursores --
  --Cursor para buscar a QTD e VL.Total de <registros enviados>
  CURSOR cr_crapdev(pr_cdcooper IN crapdev.cdcooper%TYPE) IS
    SELECT COUNT(1) qtd, SUM(VLLANMTO) valor
      FROM crapdev
     WHERE crapdev.cdcooper = pr_cdcooper
       AND crapdev.cdhistor IN (47, 573)
       AND crapdev.indevarq = 2
       and cdbandep >= 0;
  rw_crapdev cr_crapdev%ROWTYPE;

  -- Variáveis de erro
  vr_exc_erro EXCEPTION;
  --vr_dscritic varchar2(4000);

BEGIN
  IF pr_nmarquiv = ' ' THEN
          DELETE tbcompe_nossaremessa a
          WHERE a.cdcooper = pr_cdcooper
            AND a.tparquiv = pr_tparquiv
            AND a.DTARQUIV = pr_dtmvtolt;
  ELSE
          -- fazer insert na nova tabela [tbcompe_nossaremessa]
          -- inicio
          INSERT INTO tbcompe_nossaremessa 
            (cdcooper,
             cdagenci,
             tparquiv,
             dtarquiv,
             nmarquiv,
             qtenviad,
             vlenviad,
             qtproces,
             vlproces,
             insituac,
             dtevinst,
             dtrtinst)
          VALUES
            (pr_cdcooper,
             0,
             pr_tparquiv, -- Tipo de Arquivo: 1 - DEVOLUCAO DIURNA, 2 - DEVOLUCAO FRAUDES E IMPEDIMENTOS, 3 - COMPEL, 4 - TITULOS.
             pr_dtmvtolt,
             pr_nmarquiv,
           pr_totregis, --qtenviad,
           pr_vltotarq, --vlenviad,
           0, --qtproces,
           0, --vlproces,
           'Aguardando retorno ABBC', --insituac
           '', --dtevinst
           '' --dtrtinst
           );

      --Verificar qtd e valor da crapchd <registros enviados>
      OPEN cr_crapdev(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapdev
        INTO rw_crapdev;
      CLOSE cr_crapdev;

      --
      IF (rw_crapdev.qtd) != pr_totregis or
         (rw_crapdev.valor) != pr_vltotarq then
        pr_cdcritic := 1465;
        pr_dscritic := 'Cooperativa: '||pr_cdcooper||' Arquivo: '||pr_nmarquiv||'. Qtd ou valor errado QTD:' ||
                       pr_totregis || ' ' || ' VALOR:' || pr_vltotarq ||
                       '. Na DEVOLU:' || rw_crapdev.qtd || ' ' ||
                       ' VALOR:' || rw_crapdev.valor;
             
          CECRED.gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                            ,pr_cdprogra        => null
                                            ,pr_des_destino     => 'compe@ailos.coop.br'
                                            ,pr_des_assunto     => 'Arquivo ABBC inconsistencia.'
                                            ,pr_des_corpo       => pr_dscritic
                                            ,pr_des_anexo       => NULL
                                            ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                            ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                            ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                            ,pr_des_erro        => pr_dscritic);

      END IF;

  END IF;

END pc_checa_devolu;	 
	 
END COMP0001;
/
