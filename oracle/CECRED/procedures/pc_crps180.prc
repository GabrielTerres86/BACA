CREATE OR REPLACE PROCEDURE CECRED.pc_crps180(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN

  /* ............................................................................

   Programa: pc_crps180                      Antigo: Fontes/crps180.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Dezembro/96.                      Ultima atualizacao: 17/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 068. Ordem da solicitacao 89. Ordem prg 1.
               Gerar os debitos referentes a seguro de casa dos associados
               que recebem em cheque salario
               Emite relatorio 141.

   Alteracoes: 30/01/97 - Alterar selecao do AVS (Odair).
        
               28/04/97 - Alterado para tratar seguro auto (Edson).

               24/07/97 - Atualizar emp.inavsseg (Odair).

               21/08/97 - Alterado para tratar parcela unica (Edson).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               24/03/98 - Alterado para voltar a gerar p/secao em Jaragua
                          (Deborah).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               10/09/98 - Tratar tipo de conta 7 (Deborah).

               02/08/1999 - Desprezar seguro de vida (Deborah).

               20/01/2000 - Tratar seguro prestamista (Deborah).
               
               27/07/2001 - Provisionar no cheque salario os valores do seguro
                            de vida (Junior).

               08/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)
               
               29/06/2005 - Alimentado campo cdcooper da tabela crapavs (Diego).

               25/10/2005 - Acerto no programa (Ze Eduardo).
               
               15/02/2006 - Unificaao dos bancos - SQLWorks - Eder

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).
               
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva
                          - Desconsiderar os novos seguros AUTO (Gabriel).
               
               16/01/2014 - Inclusao de VALIDATE crapavs (Carlos)
                            
               17/06/2014 - Conversao Progress -> Oracle (Alisson - AMcom)
                            
               05/03/2018 - Alterada verificação "cdtipcta IN (5,6,7,17,18)" pela modalidade
                            do tipo de conta igual à "2" ou "3". PRJ366 (Lombardi).
                            
                
  ............................................................................. */

  DECLARE
  
    ------------------------ CONSTANTES  -------------------------------------
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS180';  -- Codigo do Programa
    vr_nmarqimp CONSTANT VARCHAR2(20):= 'crrl141.lst';       -- Nome do relatório

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------  
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
  
    ------------------------------- CURSORES ---------------------------------
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Selecionar informacoes da solicitação
    CURSOR cr_crapsol (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_dtrefere IN crapsol.dtrefere%TYPE) IS
      SELECT crapsol.cdempres
            ,crapsol.dsparame
            ,crapsol.rowid
        FROM crapsol crapsol
       WHERE crapsol.cdcooper = pr_cdcooper 
       AND   crapsol.dtrefere = pr_dtrefere 
       AND   crapsol.nrsolici = 68 
       AND   crapsol.insitsol = 1  -- Ativa
       ORDER BY crapsol.cdcooper, crapsol.nrsolici, crapsol.dtrefere, crapsol.nrseqsol;      
    rw_crapsol cr_crapsol%ROWTYPE;
  
    -- Cursor para busca de associados
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.inpessoa,
             crapass.cdsitdtl,
             crapass.dtelimin,
             crapass.cdagenci,
             crapass.cdsecext,
             crapass.nmprimtl
       FROM crapass crapass
           ,tbcc_tipo_conta tpcta
       WHERE crapass.cdcooper = pr_cdcooper 
        AND crapass.inpessoa = tpcta.inpessoa
        AND crapass.cdtipcta = tpcta.cdtipo_conta
        AND (crapass.cdsitdct = 5 OR tpcta.cdmodalidade_tipo IN (2,3))
       ORDER BY crapass.cdcooper, crapass.nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor para busca de titular da conta pf
    CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT  crapttl.nrdconta
             ,crapttl.cdempres
       FROM  crapttl crapttl
       WHERE crapttl.cdcooper = pr_cdcooper 
       AND   crapttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;
  
    -- Cursor para busca de titular da conta pj
    CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT crapjur.cdempres
        FROM crapjur crapjur
       WHERE crapjur.cdcooper = pr_cdcooper 
       AND   crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
  
    -- Cursor para busca de empresa
    CURSOR cr_crapemp (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdempres IN crapemp.cdempres%TYPE) IS
      SELECT crapemp.tpdebseg
            ,crapemp.tpconven
            ,crapemp.rowid
       FROM crapemp crapemp
       WHERE crapemp.cdcooper = pr_cdcooper 
       AND   crapemp.cdempres = pr_cdempres;
    rw_crapemp cr_crapemp%ROWTYPE;
  
    -- Cursor de historicos
    CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%type
                      ,pr_cdhistor IN craphis.cdhistor%type) IS
      SELECT craphis.cdhistor
            ,craphis.dshistor
      FROM craphis craphis
      WHERE craphis.cdcooper = pr_cdcooper
      AND   craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;
                             
    -- Cursor de Seguros
    CURSOR cr_crapseg (pr_cdcooper IN crapseg.cdcooper%type
                      ,pr_nrdconta IN crapass.nrdconta%type
                      ,pr_dtultdia IN crapseg.dtdebito%type
                      ,pr_dtlimite IN crapseg.dtdebito%type) IS
      SELECT /*+ INDEX (crapseg CRAPSEG##CRAPSEG2) */
             crapseg.nrctrseg
            ,crapseg.vlpreseg
            ,crapseg.tpseguro                
      FROM crapseg crapseg
      WHERE crapseg.cdcooper = pr_cdcooper      
      AND   crapseg.nrdconta = pr_nrdconta  
      AND   crapseg.tpseguro <> 4 --Prestamista
      AND   crapseg.cdsitseg = 1  --Ativo               
      AND   crapseg.flgconve = 0  --Convenio              
      AND   crapseg.flgunica = 0  --Parcela Unica
      AND   crapseg.dtdebito > pr_dtultdia
      AND   crapseg.dtdebito < pr_dtlimite      
      ORDER BY cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrctrseg;        
    rw_crapseg cr_crapseg%ROWTYPE;
            
    -- Cursor dos Avisos
    CURSOR cr_crapavs (pr_cdcooper IN crapavs.cdcooper%type
                      ,pr_dtrefere IN crapavs.dtrefere%type 
                      ,pr_dtmvtolt IN crapavs.dtmvtolt%type) IS
      SELECT /*+ INDEX (crapavs CRAPAVS##CRAPAVS2) */
             crapavs.nrdconta
            ,crapavs.vllanmto
            ,crapavs.cdempres
            ,crapavs.nrseqdig
            ,crapavs.nrdocmto
      FROM  crapavs crapavs
      WHERE crapavs.cdcooper = pr_cdcooper   
      AND   crapavs.dtrefere = pr_dtrefere   
      AND   crapavs.dtmvtolt = pr_dtmvtolt   
      AND   crapavs.tpdaviso = 1
      AND   crapavs.cdhistor IN (175,199,341)           
      ORDER BY cdcooper, nrdconta, dtrefere, cdhistor, nrseqdig, progress_recid;  
                    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    TYPE typ_tab_crapass IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    TYPE typ_tab_crapttl IS TABLE OF crapttl.cdempres%TYPE INDEX BY PLS_INTEGER;
    
    vr_tab_crapass typ_tab_crapass;   --Armazenar o nome do associado para relatorio
    vr_tab_crapttl typ_tab_crapttl;   --Armazenar codigo empresa primeiro titular
    
    ------------------------------- VARIAVEIS -------------------------------
  
	  -- Variaveis para controle de arquivos/diretorios
    vr_nom_direto_rl     VARCHAR2(100);                 -- Diretório onde será gerado o relatório
		
	  -- Variaveis utilizadas para o relatório
    vr_clobxml    CLOB;                                 -- Clob para conter o XML de dados    
    vr_cdempres   INTEGER;                              -- Código da empresa
		vr_texto_completo    VARCHAR2(32600);               -- String Completa para o CLOB
        
    --Variaveis Locais
    vr_regexist   BOOLEAN:= FALSE;                      -- Existe registro de aviso
    vr_craphis    BOOLEAN:= FALSE;                      -- Historico Cadastrado    
    vr_dtmvtolt   DATE;                                 -- Data do Movimento
    vr_dtrefere   DATE;                                 -- Data de referencia do aviso 
    vr_dtlimite   DATE;                                 -- Data Limite consulta seguro
    vr_nrseqdig   INTEGER;                              -- Numero Sequencial aviso
    vr_tpseguro   INTEGER;                              -- Indicador Tipo do Seguro 
    vr_cdhistor   INTEGER;                              -- Codigo do Historico
    vr_dshistor		VARCHAR2(4000);                       -- Descricao do Historico
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
    -- Subrotina para limpar tabelas de Memoria
    PROCEDURE pc_limpa_tabela IS
    BEGIN
      vr_tab_crapass.DELETE;
      vr_tab_crapttl.DELETE;
    EXCEPTION
      WHEN OTHERS THEN
        --Descricao do Erro
        vr_dscritic:= 'Erro ao limpar tabelas de Memoria. '||sqlerrm;
        --Sair
        RAISE vr_exc_saida;  
    END; 
    
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
  
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
    -- Limpar tabelas de Memoria
    pc_limpa_tabela;
    
    -- Carregar Tabela Memoria de Titulares
    FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapttl(rw_crapttl.nrdconta):= rw_crapttl.cdempres;
    END LOOP;
      
    -- Busca do diretório base da cooperativa para a geração de relatórios
	  vr_nom_direto_rl:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
							    									   	    ,pr_cdcooper => pr_cdcooper   --> Cooperativa
							  	   									      ,pr_nmsubdir => 'rl');        --> Utilizaremos o rl
    
   
		/*  Leitura das solicitacoes de integracao  */
    FOR rw_crapsol IN cr_crapsol(pr_cdcooper => pr_cdcooper                     -- Cod. Cooperativa
			                          ,pr_dtrefere => rw_crapdat.dtmvtolt) LOOP       -- Data movimento
																																
      -- Busca empresa
      OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                      ,pr_cdempres => rw_crapsol.cdempres);
      FETCH cr_crapemp INTO rw_crapemp;
		  -- Se não encontrou empresa
      IF cr_crapemp%NOTFOUND THEN
				-- Fecha cursor da crapemp
				CLOSE cr_crapemp;
				-- 040 - Empresa nao cadastrada.
        vr_cdcritic:= 40;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
				-- Gera log da crítica
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        -- Limpar Critica                                              
        vr_cdcritic:= 0;
        -- Proxima Solicitacao																											
        CONTINUE;
      ELSE
        -- Fecha cursor da crapemp
				CLOSE cr_crapemp;
        --Debito nao for Conta-Corrente
        IF rw_crapemp.tpdebseg <> 2 THEN
          -- Proxima Solicitacao																											
          CONTINUE;  
        END IF;  
      END IF;
      
      -- Primeiro dia Util do Mes
      IF rw_crapemp.tpconven = 2 THEN
        --Data Movimento igual ultimo dia
        vr_dtmvtolt:= rw_crapdat.dtultdia + 1;
        --Proximo dia util
        vr_dtmvtolt:= gene0005.fn_valida_dia_util (pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtmvtolt
                                                  ,pr_tipo     => 'P');
      ELSE
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;                                            
      END IF;
      
      --Validar Historicos
      FOR idx IN 1..3 LOOP
        --Somente processar os 3 historicos
        CASE idx 
          WHEN 1 THEN vr_cdhistor:= 175; --Seguro Casa
          WHEN 2 THEN vr_cdhistor:= 199; --Seguro Auto
          WHEN 3 THEN vr_cdhistor:= 341; --Seguro Vida
        END CASE;  
        --Selecionar Historicos
        OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                        ,pr_cdhistor => vr_cdhistor);
        FETCH cr_craphis INTO rw_craphis;
        --Determinar se achou
        vr_craphis:= cr_craphis%FOUND;
        --Fechar Cursor
        CLOSE cr_craphis;
        --Se nao encontrou
        IF NOT vr_craphis THEN
          CASE vr_cdhistor 
            WHEN 175 THEN 
              vr_dshistor:= '175 - Nao cadastrado';
            WHEN 199 THEN 
              vr_dshistor:= vr_dshistor||', 199 - Nao cadastrado';
            WHEN 341 THEN 
              vr_dshistor:= vr_dshistor||' e 341 - Nao cadastrado';
          END CASE; 
        ELSE
          CASE vr_cdhistor 
            WHEN 175 THEN 
              vr_dshistor:= rw_craphis.cdhistor||' - '||rw_craphis.dshistor;
            WHEN 199 THEN 
              vr_dshistor:= vr_dshistor||', '||rw_craphis.cdhistor||' - '||rw_craphis.dshistor;
            WHEN 341 THEN 
              vr_dshistor:= vr_dshistor||' e '||rw_craphis.cdhistor||' - '||rw_craphis.dshistor;
          END CASE; 
        END IF;    
      END LOOP; --idx IN 1..3 
      
      --Data Limite
      vr_dtlimite:= TO_DATE(TO_CHAR(rw_crapdat.dtultdia + 1,'MM')||
                    '11'||
                    TO_CHAR(rw_crapdat.dtultdia + 1,'YYYY'),'MMDDYYYY');
      
      -- Data Referencia 
      vr_dtrefere:= TO_DATE(SUBSTR(rw_crapsol.dsparame,1,8),'DDMMYYYY');  
      
      -- Selecionar os Associados
      FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
        -- Se for pessoa física
				IF rw_crapass.inpessoa = 1 THEN
				  -- Busca titular da conta
          IF vr_tab_crapttl.EXISTS(rw_crapass.nrdconta) THEN
						-- Atribui código da empresa do titular
						vr_cdempres:= vr_tab_crapttl(rw_crapass.nrdconta);
          ELSE
            vr_cdempres:= 0;  
					END IF;
				-- Se for pessoa jurídica
				ELSE
				  -- Abre cursor de pessoa jurídica
					OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
					FETCH cr_crapjur INTO rw_crapjur;
				  -- Se encontrou PJ
					IF cr_crapjur%FOUND THEN
						-- Pega código da empresa da PJ
						vr_cdempres:= rw_crapjur.cdempres;
          ELSE
            vr_cdempres:= 0;  
					END IF;
					-- Fecha cursor
          CLOSE cr_crapjur;
				END IF;
        --Se a empresa for diferente da solicitacao
        IF (vr_cdempres <> rw_crapsol.cdempres) OR 
           (vr_cdempres = 4 AND rw_crapass.cdagenci NOT IN (14,15)) THEN
          --Proxima Conta
          CONTINUE;
        END IF;
        
        --Selecionar Seguros
        FOR rw_crapseg IN cr_crapseg (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapass.nrdconta
                                     ,pr_dtultdia => rw_crapdat.dtultdia
                                     ,pr_dtlimite => vr_dtlimite) LOOP
          --Incrementar Sequencial
          vr_nrseqdig:= nvl(vr_nrseqdig,0) + 1;
                                     
          --Verificar tipo registro
          CASE rw_crapseg.tpseguro
            WHEN 1 THEN vr_tpseguro:= 175; -- Seguro Casa
            WHEN 2 THEN vr_tpseguro:= 199; -- Seguro Auto 
            ELSE vr_tpseguro:= 341;        -- Seguro Vida
          END CASE;

          --Criar Aviso
          BEGIN

            --Inserir Aviso
            INSERT INTO crapavs 
              (crapavs.dtmvtolt
              ,crapavs.cdagenci
              ,crapavs.cdempres
              ,crapavs.cdcooper
              ,crapavs.cdhistor
              ,crapavs.cdsecext
              ,crapavs.dtdebito
              ,crapavs.dtrefere
              ,crapavs.insitavs
              ,crapavs.nrdconta
              ,crapavs.nrseqdig
              ,crapavs.nrdocmto
              ,crapavs.vllanmto
              ,crapavs.tpdaviso
              ,crapavs.vldebito
              ,crapavs.vlestdif
              ,crapavs.flgproce)
            VALUES
              (vr_dtmvtolt
              ,rw_crapass.cdagenci
              ,vr_cdempres
              ,pr_cdcooper
              ,vr_tpseguro
              ,rw_crapass.cdsecext
              ,NULL
              ,vr_dtrefere
              ,0
              ,rw_crapass.nrdconta
              ,vr_nrseqdig
              ,rw_crapseg.nrctrseg
              ,rw_crapseg.vlpreseg
              ,1
              ,0
              ,0
              ,0); 
              
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir aviso na crapavs. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_saida;
          END;    
          --Marcar que existe registro
          vr_regexist:= TRUE;  
          --Inserir nome do associado no vetor para uso posterior
          vr_tab_crapass(rw_crapass.nrdconta):= rw_crapass.nmprimtl;
        END LOOP; --cr_crapseg
      END LOOP; --cr_crapass
        
      --Atualizar Solicitacao
      BEGIN
        UPDATE crapsol SET crapsol.insitsol = 2
        WHERE  crapsol.rowid = rw_crapsol.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar solicitacao na crapsol. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_saida;
      END;   
      
      --Atualizar Empresa
      BEGIN
        UPDATE crapemp SET crapemp.inavsseg = 1
        WHERE  crapemp.rowid = rw_crapemp.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar empresa na crapemp. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_saida;
      END;      
    END LOOP; --cr_crapsol
		
    --Se Houve aviso
    IF vr_regexist THEN
      
      -- Inicializar as informações do XML de dados para o relatório
			dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
			dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      
      --Gerar Cabecalho Relatorio
      gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
           '<crrl141 dtrefere="'||to_char(vr_dtrefere,'DD/MM/YYYY')||
           '" dshistor="'||vr_dshistor||'"><contas>');
      
      --Selecionar Avisos
      FOR rw_crapavs IN cr_crapavs (pr_cdcooper => pr_cdcooper
                                   ,pr_dtrefere => vr_dtrefere 
                                   ,pr_dtmvtolt => vr_dtmvtolt) LOOP
                                   
        --Verificar se associado existe
        IF NOT vr_tab_crapass.EXISTS(rw_crapavs.nrdconta) THEN                           
          -- Codigo Critica
          vr_cdcritic:= 251;
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
  				-- Gera log da crítica
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,
                                                                'hh24:mi:ss') ||
                                                        ' - '   || vr_cdprogra ||
                                                        ' --> ' ||to_char(rw_crapavs.nrdconta,'fm9999g999g0') ||
                                                        ' - '   || vr_dscritic);                            
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;  
        
        -- Escreve no relatório o dados do aviso
				gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
            '<conta>' || 
				        '<nrdconta>' || to_char(rw_crapavs.nrdconta,'fm9999g999g0') || '</nrdconta>' ||
						 	  '<cdempres>' || rw_crapavs.cdempres || '</cdempres>' ||
							  '<nrseqdig>' || to_char(rw_crapavs.nrseqdig,'fm999g990') || '</nrseqdig>' ||
							  '<nrdocmto>' || to_char(rw_crapavs.nrdocmto,'fm999g999g990') || '</nrdocmto>' ||
							  '<vllanmto>' || to_char(rw_crapavs.vllanmto,'fm999g999g990d00') || '</vllanmto>' ||
							  '<nmprimtl>' || SUBSTR(vr_tab_crapass(rw_crapavs.nrdconta),1,40) || '</nmprimtl>' ||
				    '</conta>');
				
      END LOOP; --cr_crapavs
      
      --Fechar Tag Contas e Relatorio
      gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,'</contas></crrl141>',TRUE);
      
      -- Gera relatório 141
			gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
																 ,pr_cdprogra  => vr_cdprogra                   --> Programa chamador
																 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt           --> Data do movimento atual
																 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
																 ,pr_dsxmlnode => '/crrl141/contas/conta'       --> Nó base do XML para leitura dos dados
																 ,pr_dsjasper  => 'crrl141.jasper'              --> Arquivo de layout do iReport
																 ,pr_dsparams  => NULL                          --> Sem parâmetros
																 ,pr_dsarqsaid => vr_nom_direto_rl||'/'||vr_nmarqimp  --> Arquivo final com o path
																 ,pr_qtcoluna  => 132                           --> 132 colunas
																 ,pr_flg_gerar => 'N'                           --> Geraçao na hora
																 ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
																 ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
																 ,pr_nrcopias  => 1                             --> Número de cópias
																 ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
																 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;  
      
      --Fechar Clob e Liberar Memoria	
	    dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
        
    END IF;  
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
   
    -- Limpar tabelas Memoria
    pc_limpa_tabela;

		-- Saída de termino da solicitação
		pr_infimsol:= 1;
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
															
		-- commit final
		COMMIT;
    
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar COMMIT;
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic:= NVL(vr_cdcritic, 0);
      pr_dscritic:= vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps180;
/

