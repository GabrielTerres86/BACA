CREATE OR REPLACE PROCEDURE CECRED.pc_crps283 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_dsparame  IN VARCHAR2               --> Parametros auxiliares para análise 
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
                                              
    /* .............................................................................

       Programa: pc_crps83                    (Fontes/crps283.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Marco/2000.                       Ultima atualizacao:31/03/2015

       Dados referentes ao programa:

       Frequencia: Solicitacao (Batch - Background).
       Objetivo  : Atende a solicitacao 72.
                   Ordem 1
                   Emite relatorio dos associados admitidos no mes (230) 
                   para as empresas

       Alteracao : 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
       
                   01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                   
                   31/03/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)

    ............................................................................ */


    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS283';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    /*  Leitura do cadastro de admitidos no mes  */
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_dtrefere crapass.dtadmemp%TYPE)IS
      SELECT crapass.nrdconta,
             crapass.inpessoa,
             crapass.dtadmemp,
             crapass.nrcadast,
             crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.dtadmemp > pr_dtrefere;
    
    -- buscar titular da conta
    CURSOR cr_crapttl (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT crapttl.nrdconta,
             crapttl.cdempres
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;          
         
    -- buscar cadastro de pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT crapjur.nrdconta,
             crapjur.cdempres
        FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;    
    
    -- buscar cadastro da empresa
    CURSOR cr_crapemp (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_cdempres crapemp.cdempres%TYPE)IS
      SELECT crapemp.nmresemp,
             crapemp.cdempres
        FROM crapemp
       WHERE crapemp.cdcooper = pr_cdcooper
         AND crapemp.cdempres = pr_cdempres;
    rw_crapemp cr_crapemp%ROWTYPE;
         
         
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- type para armazenar os dados para o relatorio
    TYPE typ_rec_admitidos 
        IS RECORD(cdempres PLS_INTEGER,
                  nrdconta crapass.nrdconta%TYPE,
                  nmprimtl crapass.nmprimtl%TYPE,
                  dtadmemp crapass.dtadmemp%TYPE,
                  nrcadast crapass.nrcadast%TYPE);
    TYPE typ_tab_admitidos IS TABLE OF typ_rec_admitidos              
         INDEX BY VARCHAR2(100); --cdempres + nmprimtl + nrdconta
    vr_tab_admitidos typ_tab_admitidos;
    

    ------------------------------- VARIAVEIS -------------------------------
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(100);
    -- Nome do relatorio    
    vr_nmarqimp   VARCHAR2(100) := 'crrl230.lst'; 
    
    vr_dtrefere                 DATE;
    vr_flgfirst                 BOOLEAN;
    vr_rel_dsmesano             VARCHAR2(100);
    vr_cdempres                 crapttl.cdempres%TYPE;
    vr_idxass                   VARCHAR2(100);
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
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

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    
    IF pr_dsparame <>  '1' THEN
      RAISE vr_exc_fimprg;
    END IF;
    -- ultimo dia do mês, do mes anterior
    vr_dtrefere := last_day(add_months(rw_crapdat.dtmvtolt,-1));
    vr_flgfirst := TRUE;
    vr_rel_dsmesano := to_char(rw_crapdat.dtmvtolt,'MM/RRRR');
    
    /*  Leitura do cadastro de admitidos no mes  */
    FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper,
                                 pr_dtrefere => vr_dtrefere) LOOP
                                 
      IF rw_crapass.inpessoa = 1 THEN
        -- buscar dados do titular
        OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapttl INTO rw_crapttl;
        IF cr_crapttl%FOUND THEN
          vr_cdempres := rw_crapttl.cdempres;
        END IF;
        CLOSE cr_crapttl;
                         
      ELSE
        -- buscar dados de pessoa juridica
        OPEN cr_crapjur (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        IF cr_crapjur%FOUND THEN
          vr_cdempres := rw_crapjur.cdempres;
        END IF;
        CLOSE cr_crapjur;
      
      END IF;
      
      -- definir index
      vr_idxass := LPAD(vr_cdempres,10,'0')||rw_crapass.nmprimtl||LPAD(rw_crapass.nrdconta,10,'0');
      -- atribuir valores
      vr_tab_admitidos(vr_idxass).cdempres := vr_cdempres;
      vr_tab_admitidos(vr_idxass).nrdconta := rw_crapass.nrdconta;
      vr_tab_admitidos(vr_idxass).nmprimtl := rw_crapass.nmprimtl;
      vr_tab_admitidos(vr_idxass).dtadmemp := rw_crapass.dtadmemp;
      vr_tab_admitidos(vr_idxass).nrcadast := rw_crapass.nrcadast;
                                 
    END LOOP; -- Fim Loop crapass
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl230>');
    
    -- buscar 1º index
    vr_idxass := vr_tab_admitidos.first;
    vr_cdempres := -1;
    
    WHILE vr_idxass IS NOT NULL LOOP
      -- pegar a primeira vez que o cdempres aparece -- Simular first-of
      IF vr_cdempres <> vr_tab_admitidos(vr_idxass).cdempres THEN
        -- se nao for o primeiro, necessario fechar a tag
        IF vr_cdempres <> -1 THEN
          pc_escreve_xml('</empresa>');
        END IF;
        --guardar cdempres localizado
        vr_cdempres := vr_tab_admitidos(vr_idxass).cdempres;
        
        rw_crapemp := NULL;
        -- buscar dados da empresa
        OPEN cr_crapemp (pr_cdcooper => pr_cdcooper,
                         pr_cdempres => vr_tab_admitidos(vr_idxass).cdempres);
        FETCH cr_crapemp INTO rw_crapemp;
        CLOSE cr_crapemp;
        -- escrever cabecalho da empresa
        pc_escreve_xml('<empresa dsmesano="'|| vr_rel_dsmesano ||'" 
                                 cdempres="'|| rw_crapemp.cdempres ||'" 
                                 nmresemp="'|| rw_crapemp.nmresemp ||'">');
        
      END IF;
      
      -- escrever linha
      pc_escreve_xml('<cooperado>
                        <nrdconta>'|| gene0002.fn_mask_conta(vr_tab_admitidos(vr_idxass).nrdconta) ||'</nrdconta>
                        <nmprimtl>'|| substr(vr_tab_admitidos(vr_idxass).nmprimtl,1,40) ||'</nmprimtl> 
                        <dtadmemp>'|| to_char(vr_tab_admitidos(vr_idxass).dtadmemp,'DD/MM/RRRR') ||'</dtadmemp>
                        <nrcadast>'|| gene0002.fn_mask_conta(vr_tab_admitidos(vr_idxass).nrcadast) ||'</nrcadast>
                      </cooperado>');
      
      -- fechar nodo qnd for o ultimo registro
      IF vr_idxass = vr_tab_admitidos.last THEN
        pc_escreve_xml('</empresa>');
      END IF;
      
      -- buscar proximo index
      vr_idxass := vr_tab_admitidos.next(vr_idxass);
    END LOOP;
    
    --> descarregar buffer
    pc_escreve_xml('</crrl230>',TRUE);
    
    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    
    -- Efetuar solicitação de geração de relatório --
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl230/empresa/cooperado'    --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl230.jasper'    --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                --> Sem parametros
                               ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com código da agência
                               ,pr_qtcoluna  => 80                  --> 132 colunas
                               ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                               ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '80col'             --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                   --> Número de cópias
                               ,pr_flg_gerar => 'N'                 --> gerar PDF
                               ,pr_des_erro  => vr_dscritic);       --> Saída com erro
    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml); 
                      
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END pc_crps283;
/

