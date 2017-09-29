CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS526(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER                --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER               --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER               --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Texto de erro/critica encontrada
BEGIN
  /* .............................................................................
  
     Programa: pc_crps526 (Fontes/crps526.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Fernando
     Data    : ABRIL/2009                         Ultima atualizacao: 11/07/2014
  
     Dados referentes ao programa:
  
     Frequencia: Diario
     Objetivo  : Cadastramento da taxa CDI para o dia.
  
  
     Alteracoes: 15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                              leitura e gravacao dos arquivos (Elton).
                          
                 17/11/2011 - Inclusao das chamadas "cadastra_taxa_cdi_mensal" e
                              "cadastra_taxa_cdi_acumulado" para calcular de
                              forma automática a Taxa de CDI (Isara - RKAM)
  
                 30/03/2012 - Incluir parametro (dtmvtopr) na BO 128 (Ze).
                 
                 03/06/2014 - Incluir o VALIDATE e substituir glb_cdcooper por
                              crapcop.cdcooper (Ze/Rodrigo).
                              
                 11/07/2014 - Conversão Progress >> Oracle PLSQL (Jean Michel)

                 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
  
  ............................................................................ */

  DECLARE
  
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS526';
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);  
    
    vr_dscamarq VARCHAR2(500);
    vr_conteudo VARCHAR2(500);
    vr_dsdireto VARCHAR2(500);
    vr_typsaida VARCHAR2(100);
    vr_valortax NUMBER(20,6) := 0;
    
    vr_indarqle utl_file.file_type;
  
    ------------------------------- CURSORES ---------------------------------
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT
        cop.cdcooper
       ,cop.nmrescop
       ,cop.nmextcop
      FROM
        crapcop cop
      WHERE
        cop.cdcooper = pr_cdcooper;
    
    rw_crapcop cr_crapcop%ROWTYPE;    

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Cursor de consulta de taxa
    CURSOR cr_craptxi(pr_cddindex IN craptxi.cddindex%TYPE
                     ,pr_dtmvtolt IN craptxi.dtiniper%TYPE) IS

      SELECT
        txi.cddindex
       ,txi.dtiniper
       ,txi.dtfimper
       ,txi.vlrdtaxa
       ,txi.dtcadast
      FROM
        craptxi txi
      WHERE
        txi.cddindex = pr_cddindex AND          
        txi.dtiniper = pr_dtmvtolt AND
        txi.dtfimper = pr_dtmvtolt; 

    -- Cursor de consulta de taxa
    rw_craptxi cr_craptxi%ROWTYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
    -- PROCEDURE PARA CRIACAO DAS TAXAS
    PROCEDURE pc_cria_taxas(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa solicitada
                           ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) IS --> Data de movimento

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_' || UPPER(vr_cdprogra), pr_action => 'pc_cria_taxas');

      -- Monta nome do arquivo final                     
      vr_dscamarq := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_nmsubdir => 'integra');

      vr_dscamarq := vr_dscamarq || '/Taxa_Aplic_' || TO_CHAR(pr_dtmvtolt,'yyyymmdd') || '.txt';                                     

      -- Verifica se nome e caminho sao nulos
      IF vr_dscamarq IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao montar caminho do arquivo.';
        -- Sair do processo caso retorne caminho como null
        RAISE vr_exc_fimprg;
      END IF;
    
      -- Verifica se o arquivo existe
      IF GENE0001.fn_exis_arquivo(pr_caminho => vr_dscamarq) THEN
      
        -- Abrir arquivo em modo de leitura
        GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_dscamarq   --> Diretório do arquivo
                                ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_indarqle   --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic); --> Erro
      
        -- Verifica se houve excecao
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
        -- Le o conteudo da primeira linha do arquivo
        GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_indarqle,
                                     pr_des_text => vr_conteudo);
      
        -- Fecha arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_indarqle); --> Handle do arquivo aberto;

        -- Inicializa variavel
        vr_valortax := 0;

        -- Atribui e converte o conteudo da primeira linha
        vr_valortax := (TO_NUMBER(vr_conteudo) / 100);
            
        -- Busca do diretório arq da cooperativa logada
        vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> Usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'salvar');
      
        -- Mover o arquivo para o diretório salvar
        GENE0001.pc_oscommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'mv ' || vr_dscamarq || ' ' || vr_dsdireto 
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
      
        -- Verifica se houve erro no comando
        IF vr_typsaida = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_dscritic := 'Erro ao mover o arquivo ' || vr_dscamarq || ' para o diretório salvar: ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;

      END IF;

    END;
    -- FIM DECLARACAO PROCEDURES
  
  BEGIN
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || UPPER(vr_cdprogra)
                              ,pr_action => NULL);
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
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
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
  
    OPEN cr_craptxi(pr_cddindex => 1
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                   
    FETCH cr_craptxi INTO rw_craptxi;

    IF cr_craptxi%FOUND THEN
      -- Cria log para simples conferencia
      CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => vr_cdprogra, 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 2, --job
                             pr_tpocorrencia  => 4,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => 'TAXA JA CADASTRADA. Dtmvtolt: '||rw_crapdat.dtmvtolt, 
                             pr_idprglog      => vr_idprglog,
                             pr_nmarqlog      => NULL);

    ELSE
      -- Cria taxas
      pc_cria_taxas(pr_cdcooper => rw_crapcop.cdcooper   -- Codigo da cooperativa
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt); -- Data de movimento atual

      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_' || UPPER(vr_cdprogra), pr_action => NULL);

      IF NVL(vr_valortax,0) > 0 THEN              
        BEGIN
          -- Insere registro
          INSERT INTO craptxi
            (cddindex,dtiniper,dtfimper,vlrdtaxa,dtcadast)
          VALUES
            (1,rw_crapdat.dtmvtolt,rw_crapdat.dtmvtolt, vr_valortax ,rw_crapdat.dtmvtolt);
        EXCEPTION
          WHEN OTHERS THEN
            -- Descricao do erro na insercao de registros
            vr_dscritic := 'Erro ao inserir CDI. Erro: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        apli0004.pc_cadastra_taxa_cdi(pr_cdcooper => pr_cdcooper         --> Codigo da Cooperativa
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimentacao
                                     ,pr_vlmoefix => vr_valortax         --> Valor da Moeda
                                     ,pr_tpmoefix => 6                   --> Tipo da Moeda (1-CDI)
                                     ,pr_cdprogra => 'CRPS526'           --> Origrem da Requisicao (0 - Batch)
                                     ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                     ,pr_dscritic => vr_dscritic);       --> Descrição da crítica
                                         
        IF vr_cdcritic IS NOT NULL OR                                     
           vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;  

        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_' || UPPER(vr_cdprogra), pr_action => NULL);

      ELSE
        -- Cria log para simples conferencia
        CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra, 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 2, --job
                               pr_tpocorrencia  => 4,
                               pr_cdcriticidade => 0, --baixa
                               pr_dsmensagem    => 'VALOR TAXRDC INEXISTENTE',                             
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);

      END IF;
    END IF;
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Envio centralizado de log de erro
      CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => vr_cdprogra, 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 2, --job
                             pr_tpocorrencia  => 2,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => vr_dscritic,                             
                             pr_idprglog      => vr_idprglog,
                             pr_nmarqlog      => NULL);

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
      
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- Envio centralizado de log de erro
      CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => vr_cdprogra, 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 2, --job
                             pr_tpocorrencia  => 2,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => vr_dscritic,                             
                             pr_idprglog      => vr_idprglog,
                             pr_nmarqlog      => NULL);

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

      --Inclusão na tabela de erros Oracle - Chamado 744573
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => pr_dscritic );

      -- Efetuar rollback
      ROLLBACK;
  END;

END PC_CRPS526;
/
