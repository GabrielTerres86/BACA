CREATE OR REPLACE PACKAGE CECRED.INSS0003 AS

   /*---------------------------------------------------------------------------------------------------------------

   Programa : INSS0003
   Autor    : Douglas Quisinski
   Data     : 20/03/2017                        Ultima atualizacao: 22/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Importação da planilha de prova de vida

   Alterações: 
   
   -- 22/06/2017 - inclusão da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in
                 - Setado modulo pr_ind_tipo_log_in para variar se é erro ou alertar
                 - Chamado 660286 - (Belli - Envolti)
   
  --------------------------------------------------------------------------------------------------------------- */
  
  -- Tipo de registro para PlTable de listagem de benefícios do cooperado
  TYPE typ_reg_beneficio_inss IS
     RECORD (cdcooper crapcop.cdcooper%TYPE
            ,nrdconta crapass.nrdconta%TYPE
            ,cdagenci crapage.cdagenci%TYPE
            ,nrrecben crapdbi.nrrecben%TYPE
            ,cdorgins crapage.cdorgins%TYPE);
            
   -- Tipo de tabela para PlTable de tela-inss
   TYPE typ_tab_beneficio_inss IS
     TABLE OF typ_reg_beneficio_inss
     INDEX BY PLS_INTEGER;
  
  PROCEDURE pc_importar_prova_vida(pr_cdprogra   IN VARCHAR2     -- Programa que esta executando
                                  ,pr_dsdireto   IN VARCHAR2     -- Diretorio onde esta o arquivo
                                  ,pr_cdcritic  OUT PLS_INTEGER  -- Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2);   -- Descrição da crítica
  
  
  
  PROCEDURE pc_consultar_codigo_nai(pr_nrcpf  IN VARCHAR2          -- Numero CPF
                                   ,pr_retxml OUT NOCOPY XMLType); -- Retorno XML para SOA



  PROCEDURE pc_salvar_codigo_nai(pr_nrcpf         IN VARCHAR2          -- CPF do cooperado
                                ,pr_cdcodigo_nai  IN VARCHAR2          -- Codigo do NAI do cooperado
                                ,pr_nrcontrole    IN VARCHAR2          -- Numero de controle do Sicredi
                                ,pr_retxml        OUT NOCOPY XMLType); -- Retorno XML 

  PROCEDURE pc_consultar_beneficios(pr_cdcooper IN INTEGER,                          --> Codigo da Cooperativa
                                    pr_nrdconta IN INTEGER,                          --> Numero da Conta
                                    pr_nrcpfcgc IN NUMBER,                           --> CPF do Cooperado
                                    pr_tab_bene OUT INSS0003.typ_tab_beneficio_inss, --> PL TABLE para listar os beneficios
                                    pr_dscritic OUT VARCHAR2);                       --> Mensagem de erro 
  
  PROCEDURE pc_lista_beneficios(pr_cdcooper IN INTEGER,         --> Codigo da Cooperativa
                                pr_nrdconta IN INTEGER,         --> Numero da Conta
                                pr_nrcpfcgc IN NUMBER,          --> CPF do Cooperado
                                pr_dsbenefi OUT NOCOPY XMLType, --> XML com a lista de beneficios
                                pr_dscritic OUT VARCHAR2);      --> Mensagem de erro 

  PROCEDURE pc_gera_reg_emp_consignado(pr_cdcooper IN INTEGER    --> Codigo da Cooperativa
                                      ,pr_nrdconta IN INTEGER    --> Numero da Conta
                                      ,pr_cdorgins IN NUMBER     --> Codigo do Orgao Pagador
                                      ,pr_nrbenefi IN NUMBER     --> Numero do Benefício
                                      ,pr_tpoperac IN INTEGER    --> Tipo de operacao: (1 - Historico de emprestimos ativos, 2 - Consulta de margem consignavel)
                                      ,pr_cdcoptfn IN INTEGER    --> Cooperativa do TAA
                                      ,pr_cdagetfn IN INTEGER    --> Agencia do TAA
                                      ,pr_nrterfin IN INTEGER    --> Numero do TAA
                                      ,pr_nmdcanal IN VARCHAR2   --> Nome do Canal
                                      ,pr_nmusuari IN VARCHAR2); --> Nome do Usuário da consulta
                                  
  
END INSS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INSS0003 AS

  /*---------------------------------------------------------------------------------------------------------------
   Programa : INSS0003
   Autor    : Douglas Quisinski
   Data     : 20/03/2017                        Ultima atualizacao: 22/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Importação da planilha de prova de vida

   Alteracoes: 
   
   -- 22/06/2017 - inclusão da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in
                 - Setado modulo pr_ind_tipo_log_in para variar se é erro ou alertar
                 - Chamado 660286 - (Belli - Envolti)
  
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_gera_log_prova_vida(pr_cdcritic        IN crapcri.cdcritic%TYPE     -- Codigo do Erro
                                  ,pr_dscritic        IN crapcri.dscritic%TYPE     -- Descricao do Erro
                                  ,pr_ind_tipo_log_in IN NUMBER                    --> Tipo de mensagem do log
                                  ,pr_cdprograma_in   IN VARCHAR2                  --> programa ou job
                                  ,pr_dserro          OUT crapcri.dscritic%TYPE) IS -- Mensagem caso ocorra erro no log
  

    -- ..........................................................................
    --
    --  Programa : pc_gera_log_prova_vida
    --  Sistema  : Trata das informaçoes de INSS dos cooperados
    --  Sigla    : INSS
    --  Autor    :   - 
    --  Data     : .                   Ultima atualizacao: 22/06/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: 
    --   Objetivo  : Importação da planilha de prova de vida.
    --
    -- .............................................................................
    --   Alteracoes: 
    --   22/06/2017 - inclusão da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in 
    --              - Setado modulo pr_ind_tipo_log_in para variar se é erro ou alertar
    --              - Chamado 660286 - (Belli - Envolti)
    -- .............................................................................
    --                                  
  
    vr_dscriti2 VARCHAR2(20000);
    
  BEGIN
	  -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		GENE0001.pc_set_modulo(pr_module => pr_cdprograma_in, pr_action => 'INSS0003.pc_gera_log_prova_vida');
      
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscriti2 := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;

    IF TRIM(pr_dscritic) IS NOT NULL THEN
      vr_dscriti2 := pr_dscritic;
    END IF;

    -- Envio centralizado de log de erro
    -- LOG sempre será gerado na CECRED
    
    -- inclusão de informação do parâmetro de entrada - 22/06/2017 - Chamado 660286
    
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => pr_ind_tipo_log_in
                              ,pr_des_log      => vr_dscriti2
                              ,pr_nmarqlog     => 'log_crps700'
                              ,pr_cdprograma   => pr_cdprograma_in
                               );

  EXCEPTION
    WHEN OTHERS THEN
      pr_dserro := 'Erro na INSS0003.pc_gera_log_prova_vida --> ' || 
                   REPLACE(REPLACE(SQLERRM, '"', NULL), '''', NULL);
  END pc_gera_log_prova_vida;


  PROCEDURE pc_importar_prova_vida(pr_cdprogra   IN VARCHAR2     -- Programa que esta executando
                                  ,pr_dsdireto   IN VARCHAR2     -- Diretorio onde esta o arquivo
                                  ,pr_cdcritic  OUT PLS_INTEGER  -- Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2) IS -- Descrição da crítica

    -- ..........................................................................
    --
    --  Programa : pc_importar_prova_vida
    --  Sistema  : Trata das informaçoes de INSS dos cooperados
    --  Sigla    : INSS
    --  Autor    :   - 
    --  Data     : .                   Ultima atualizacao: 22/06/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: 
    --   Objetivo  : Trata das informaçoes de INSS dos cooperados.
    --
    --   Alteracoes: 
    --   22/06/2017 - inclusão da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in 
    --              - Setado modulo pr_ind_tipo_log_in para variar se é erro ou alertar
    --              - Chamado 660286 - (Belli - Envolti)
    --
    --
    -- .............................................................................
    --
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_valid  EXCEPTION;
    vr_exc_email  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    -- Variaveis
    vr_tab_linhas gene0009.typ_tab_linhas;
    vr_indice2    PLS_INTEGER;
    vr_contareg   PLS_INTEGER;
    vr_nmarquiv   CONSTANT VARCHAR2(20) := 'PV_CECRED.csv';
    vr_dsarqimp   VARCHAR2(500);
    vr_dsdanexo   VARCHAR2(1000);
    vr_dserro     VARCHAR2(10000); 

--    lt_d_nrsequen   NUMBER:=0;
--    lt_d_dtinclus   DATE;
    lt_d_nrrecben   NUMBER:=0;
    lt_d_cdorgins   NUMBER:=0;
    lt_d_dtvencpv   DATE;
    vr_houveerro    BOOLEAN:=FALSE;
    vr_linhaserro   VARCHAR2(2000);
    
    -- Variaveis - Chamado 665812 - 01/06/2017
    vr_ind_tipo_log    number    (2)     := 2;        -- erro tratado
    ds_ind_tipo_log    varchar2 (10)     := 'ERRO: '; -- erro tratado
    
    ------------------------------- CURSORES ---------------------------------

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Verificar se NB existe
    CURSOR cr_dcb(pr_nrrecben IN tbinss_dcb.nrrecben%TYPE)IS
      SELECT dcb.id_dcb
            ,dcb.dtvencpv
        FROM tbinss_dcb dcb
       WHERE dcb.nrrecben = pr_nrrecben;
    rw_dcb cr_dcb%ROWTYPE;

    -- Buscar o CPF do NB informado
    CURSOR cr_crapdbi(pr_nrrecben IN crapdbi.nrrecben%TYPE)IS
      SELECT dbi.rowid
            ,dbi.nrcpfcgc
        FROM crapdbi dbi
       WHERE dbi.nrrecben = pr_nrrecben
         AND rownum       = 1;
    rw_crapdbi cr_crapdbi%ROWTYPE;

    -- Buscar a Cooperativa do OP
    CURSOR cr_crapage(pr_cdorgins IN crapage.cdorgins%TYPE)IS
      SELECT age.cdagenci
            ,age.cdcooper
            ,cop.cdagesic
        FROM crapage age, crapcop cop
       WHERE cop.cdcooper = age.cdcooper
         AND age.cdorgins = pr_cdorgins;
    rw_crapage cr_crapage%ROWTYPE;

    -- Buscar as Contas do CPF
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE)IS
      SELECT ttl.nrdconta
            ,ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Verificar se a conta teve lancamento 1399 nos ultimos 3 meses
    CURSOR cr_craplcm_inss(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                          ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE) IS
      SELECT 1
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.cdhistor = 1399
         AND lcm.dtmvtolt <= pr_dtmvtolt
         AND lcm.dtmvtolt >= (pr_dtmvtolt - 90);
    rw_craplcm_inss cr_craplcm_inss%ROWTYPE;
    
  BEGIN

	  -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');

    vr_houveerro := FALSE;
    -- Arquivo para importar
    vr_dsarqimp  := pr_dsdireto || '/' || vr_nmarquiv;
    -- Arquivos enviados em anexo
    vr_dsdanexo  := vr_dsarqimp || ';' || 
                    gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                         ,pr_cdcooper => 3
                                         ,pr_nmsubdir => 'log')  ||
                    '/log_crps700.log';                 
    
    IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_dsdireto || '/' || vr_nmarquiv) THEN
      vr_dscritic := 'Nao existe arquivo ' || vr_nmarquiv || ' na pasta!';
      
      -- Gerar alerta - 22/06/2017 - Chamado 660286
      
      vr_ind_tipo_log              := 1;          -- mensagem tratada
      ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
      
      RAISE vr_exc_saida;        
    END IF;

    -- Importar o arquivo utilizando o Layout, separado por Virgula
    gene0009.pc_importa_arq_layout(pr_nmlayout   => 'INSSVIDA'
                                  ,pr_dsdireto   => pr_dsdireto
                                  ,pr_nmarquiv   => vr_nmarquiv
                                  ,pr_dscritic   => vr_dscritic
                                  ,pr_tab_linhas => vr_tab_linhas);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      vr_dscritic := vr_dscritic || ' , Arquivo: ' || vr_nmarquiv;
      RAISE vr_exc_saida;
    END IF;
                          
    -- Se menos que 2 linha (linha 1 = Cabeçalho)
    IF vr_tab_linhas.count < 2 THEN
      vr_dscritic := 'Arquivo ' || vr_nmarquiv || ' nao possui conteudo!';
      
      -- Gerar alerta - 22/06/2017 - Chamado 660286      
      vr_ind_tipo_log              := 1;          -- mensagem tratada
      ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
      
      RAISE vr_exc_saida;
    END IF;

    -- Leitura do calendário da cooperativa, apenas se o arquivo for valido 
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Gerar hora inicio no log
    vr_ind_tipo_log              := 1;          -- mensagem tratada
    ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
    pc_gera_log_prova_vida(pr_cdcritic => 0
                          ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                          ' - ' || pr_cdprogra  || ' --> ' ||
                                          ds_ind_tipo_log ||
                                           ' INICIO.'
                          ,pr_ind_tipo_log_in => vr_ind_tipo_log
                          ,pr_cdprograma_in   => pr_cdprogra
                          ,pr_dserro   => vr_dserro);

	  -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
    -- Assumir como padrão erro - 22/06/2017 - Chamado 660286
    vr_ind_tipo_log              := 2;        -- erro tratado
    ds_ind_tipo_log              := 'ERRO: '; -- erro tratado
                          
    
    vr_contareg := 0; -- Contador de Linhas

    -- Navegar em cada linha do arquivo aberto para leitura
    FOR vr_indice2 IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

      -- Assumir como padrão erro - 22/06/2017 - Chamado 660286
      vr_ind_tipo_log              := 2;        -- erro tratado
      ds_ind_tipo_log              := 'ERRO: '; -- erro tratado

      vr_contareg := vr_contareg + 1; --Conta qtd de linhas do arquivo

      -- Se for a linha de cabeçalho do arquivo
      IF  vr_contareg = 1 THEN
        CONTINUE;
      END IF;

      IF vr_tab_linhas(vr_indice2).exists('$ERRO$') THEN --Problemas com importacao do layout
        IF vr_houveerro THEN -- TRUE (Primeira vez, estará false)
          vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
        ELSE
          vr_linhaserro := vr_contareg;
        END IF;

        vr_houveerro  := TRUE;

        CONTINUE;
      END IF;

      -- Coloca o conteudo da linha/coluna em cada campo
      BEGIN
--        lt_d_nrsequen := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NRSEQUEN').texto,'"','')));
--        lt_d_dtinclus := to_date(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('DTINCLUS').texto,'"','')),'DD/MM/RRRR');
        lt_d_nrrecben := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NRRECBEN').texto,'"','')));
        lt_d_cdorgins := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('CDORGINS').texto,'"','')));
        lt_d_dtvencpv := to_date(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('DTVENCPV').texto,'"','')),'DD/MM/RRRR');
          
        IF (lt_d_nrrecben IS NULL OR lt_d_nrrecben = 0) OR
           (lt_d_cdorgins IS NULL OR lt_d_cdorgins = 0) OR
           (lt_d_dtvencpv IS NULL)                      THEN
          RAISE vr_exc_valid;
        END IF;
          
      EXCEPTION
        WHEN vr_exc_valid THEN -- Erro de Validação
          IF vr_houveerro THEN -- TRUE (Primeira vez, estará false)
            vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
          ELSE
            vr_linhaserro := vr_contareg;
          END IF;

          vr_houveerro  := TRUE;

          CONTINUE;
        
        WHEN OTHERS THEN   -- Erro de Atribuição / Tipo inválido
          IF vr_houveerro THEN -- TRUE (Primeira vez, estará false)
            vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
          ELSE
            vr_linhaserro := vr_contareg;
          END IF;

          vr_houveerro  := TRUE;

          CONTINUE;
      END;

      -- Verificar se o NB do arquivo já está na base
      OPEN cr_dcb(pr_nrrecben => lt_d_nrrecben);
      FETCH cr_dcb INTO rw_dcb;

      IF cr_dcb%NOTFOUND THEN -- Se o NB ainda não está na base, criar

        CLOSE cr_dcb;

        -- Buscar o CPF do NB do arquivo
        OPEN cr_crapdbi(pr_nrrecben => lt_d_nrrecben);
        FETCH cr_crapdbi INTO rw_crapdbi;
        IF cr_crapdbi%NOTFOUND THEN
          CLOSE cr_crapdbi;
      
          -- Gerar alerta - 22/06/2017 - Chamado 660286  
          vr_ind_tipo_log              := 1;          -- mensagem tratada
          ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado

          -- Gera LOG
          pc_gera_log_prova_vida(pr_cdcritic => 0
                                ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                ' - ' || pr_cdprogra  || ' --> ' ||
                                                ds_ind_tipo_log ||
                                                ' CPF do NB do arquivo nao localizado! NB: ' 
                                                || lt_d_nrrecben
                                ,pr_ind_tipo_log_in => vr_ind_tipo_log
                                ,pr_cdprograma_in   => pr_cdprogra
                                ,pr_dserro    => vr_dserro);
                                
	        -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		      GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
          -- Verificar se ocorreu erro na geração do LOG
          IF TRIM(vr_dserro) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          CONTINUE; -- Passa para próxima linha do arquivo
        END IF;
        CLOSE cr_crapdbi;

        -- Verificar a cooperativa do OP/NB
        OPEN cr_crapage(pr_cdorgins => lt_d_cdorgins);
        FETCH cr_crapage INTO rw_crapage;
        IF cr_crapage%NOTFOUND THEN
          CLOSE cr_crapage;
      
          -- Gerar alerta - 22/06/2017 - Chamado 660286      
          vr_ind_tipo_log              := 1;          -- mensagem tratada
          ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
          
          -- Gera LOG
          pc_gera_log_prova_vida(pr_cdcritic => 0
                                ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                 ' - ' || pr_cdprogra  || ' --> ' ||
                                                 ds_ind_tipo_log ||
                                                  ' OP do arquivo nao localizado! OP: '|| 
                                                 lt_d_cdorgins || ' - NB: ' || lt_d_nrrecben
                                ,pr_ind_tipo_log_in => vr_ind_tipo_log
                                ,pr_cdprograma_in   => pr_cdprogra
                                ,pr_dserro    => vr_dserro);
                                
	        -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		      GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
          -- Verificar se ocorreu erro na geração do LOG
          IF TRIM(vr_dserro) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          CONTINUE; -- Passa para próxima linha do arquivo
        END IF;
        CLOSE cr_crapage;

        -- Buscar as Contas do CPF
        OPEN cr_crapttl(pr_cdcooper => rw_crapage.cdcooper
                       ,pr_nrcpfcgc => rw_crapdbi.nrcpfcgc);
        FETCH cr_crapttl INTO rw_crapttl;
        IF cr_crapttl%NOTFOUND THEN
          CLOSE cr_crapttl;
          
          -- Gerar alerta - 22/06/2017 - Chamado 660286
          vr_ind_tipo_log              := 1;          -- mensagem tratada
          ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
          
          -- Gera LOG
          pc_gera_log_prova_vida(pr_cdcritic => 0
                                ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                ' - ' || pr_cdprogra  || ' --> ' ||
                                                ds_ind_tipo_log ||
                                                ' Titular nao localizado com o CPF: ' || 
                                                rw_crapdbi.nrcpfcgc||
                                                ' - NB: '||lt_d_nrrecben
                                ,pr_ind_tipo_log_in => vr_ind_tipo_log                                
                                ,pr_cdprograma_in   => pr_cdprogra
                                ,pr_dserro    => vr_dserro);
                                
	        -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		      GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
          -- Verificar se ocorreu erro na geração do LOG
          IF TRIM(vr_dserro) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          CONTINUE; -- Passa para próxima linha do arquivo
        ELSE -- SE Encontrou
      
          -- Para todas as contas que encontrar com esse CPF
          LOOP
            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapttl%NOTFOUND;

            -- Verificar se a conta possui LCM 1399 nos ultimos 3 meses
            OPEN cr_craplcm_inss(pr_cdcooper => rw_crapage.cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_nrdconta => rw_crapttl.nrdconta);
            FETCH cr_craplcm_inss INTO rw_craplcm_inss;

            IF cr_craplcm_inss%NOTFOUND THEN
              FETCH cr_crapttl INTO rw_crapttl;
              CLOSE cr_craplcm_inss;

              CONTINUE; -- Passa para próxima Conta TTL
            END IF;

            CLOSE cr_craplcm_inss;
            -- Gravar tbinss_dcb apenas para as contas que receberam
            -- credito de beneficio(1399) nos ultimos 3 meses.
            -- Se nao recebeu, não grava.

            -- Criar o registro
            INSERT INTO tbinss_dcb(id_dcb
                                  ,cdcooper
                                  ,nrdconta
                                  ,dtvencpv
                                  ,dtcompet
                                  ,nmemissor
                                  ,nrcnpj_emissor
                                  ,nmbenefi
                                  ,nrrecben
                                  ,cdorgins
                                  ,nrcpf_benefi
                                  ,cdagencia_conv  )
                            VALUES(fn_sequence('TBINSS_DCB','ID_DCB','ID_DCB')
                                  ,rw_crapage.cdcooper
                                  ,rw_crapttl.nrdconta
                                  ,lt_d_dtvencpv
                                  ,to_date('01/01/2008','dd/mm/RRRR')
                                  ,'INSTITUTO NACIONAL DO SEGURO SOCIAL'
                                  ,29979036000140
                                  ,rw_crapttl.nmextttl
                                  ,lt_d_nrrecben
                                  ,lt_d_cdorgins
                                  ,rw_crapdbi.nrcpfcgc
                                  ,rw_crapage.cdagesic
                                   ) RETURNING id_dcb INTO rw_dcb.id_dcb;

            FETCH cr_crapttl INTO rw_crapttl;
          END LOOP; -- FIM LOOP TTL
          CLOSE cr_crapttl;
        END IF; -- IF FOUND/NOTFOUND - cr_crapttl

      ELSE -- Se encontrou, atualizar

        -- Para DCB desse NB
        LOOP
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_dcb%NOTFOUND;

          -- Verificar se a data no Arquivo é Maior que a data da Base
          IF lt_d_dtvencpv > rw_dcb.dtvencpv OR
             rw_dcb.dtvencpv IS NULL         THEN

            -- Atualizar o registro
            UPDATE tbinss_dcb
               SET tbinss_dcb.dtvencpv = lt_d_dtvencpv
             WHERE tbinss_dcb.id_dcb   = rw_dcb.id_dcb;
             
          END IF;

          FETCH cr_dcb INTO rw_dcb;
        END LOOP;
        CLOSE cr_dcb;

      END IF;

      COMMIT; -- Ao termino de cada linha, COMMIT

    END LOOP;  -- LOOP de Linhas do Arquivo

    IF vr_houveerro THEN
      
      -- Gerar alerta - 22/06/2017 - Chamado 660286    
      vr_ind_tipo_log              := 1;          -- mensagem tratada
      ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
      
      vr_dscritic := 'Planilha foi importada com erro(s). Erro linha(s): ' 
                     || vr_linhaserro;
      
      -- Gera LOG
      pc_gera_log_prova_vida(pr_cdcritic => 0
                            ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                ' - ' || pr_cdprogra  || ' --> ' ||
                                                ds_ind_tipo_log ||
                                                vr_dscritic
                            ,pr_ind_tipo_log_in => vr_ind_tipo_log
                            ,pr_cdprograma_in   => pr_cdprogra
                            ,pr_dserro    => vr_dserro);
                                
	    -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
      -- Verificar se ocorreu erro na geração do LOG
      IF TRIM(vr_dserro) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
    END IF;

    -- Gerar hora Fim no log
    vr_ind_tipo_log              := 1;          -- mensagem tratada
    ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado    
    pc_gera_log_prova_vida(pr_cdcritic => 0
                          ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                          ' - ' || pr_cdprogra ||  ' --> ' ||
                                           'ALERTA: FINALIZADO COM SUCESSO.'
                          ,pr_ind_tipo_log_in => vr_ind_tipo_log
                          ,pr_cdprograma_in   => pr_cdprogra
                          ,pr_dserro   => vr_dserro);
                                
	  -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
	  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
    vr_ind_tipo_log              := 2;        -- erro tratado
    ds_ind_tipo_log              := 'ERRO: '; -- erro tratado

    -- Mandar email para INSS com o resultado do processo
    gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                              ,pr_cdprogra        => pr_cdprogra
                              ,pr_des_destino     => 'inss@ailos.coop.br'
                              ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - LOG'
                              ,pr_des_corpo       => 'Em anexo a PLANILHA e o LOG de processamento.'  ||
                                                     '</br></br>' ||
                                                     'Processado em: ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                              ,pr_des_anexo       => vr_dsdanexo
                              ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                              ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                              ,pr_des_erro        => vr_dscritic);
    -- Se houver erros
    IF vr_dscritic IS NOT NULL THEN
      -- Gera critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no envio do Email!' || '. Erro: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN -- SAIDA SEM ENVIO DE EMAIL
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Gerar hora Fim no log - 22/06/2017 - Chamado 660286
      
      pc_gera_log_prova_vida(pr_cdcritic => 0
                            ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                            ' - ' || pr_cdprogra ||  ' --> ' ||
                                            ds_ind_tipo_log ||
                                            pr_dscritic
                            ,pr_ind_tipo_log_in => vr_ind_tipo_log
                            ,pr_cdprograma_in   => pr_cdprogra
                            ,pr_dserro   => vr_dserro);
                                
                                
	    -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');

      -- Mandar email para INSS com o resultado do processo
      gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                                ,pr_cdprogra        => pr_cdprogra
                                ,pr_des_destino     => 'inss@ailos.coop.br'
                                ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - ERRO'
                                ,pr_des_corpo       => 'Houve erro no processamento da planilha.</br>' ||
                                                       'Em anexo a PLANILHA e o LOG de processamento.'  ||
                                                       '</br></br>' ||
                                                       'Processado em: ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                                ,pr_des_anexo       => vr_dsdanexo
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
  
    WHEN OTHERS THEN
      --Monta mensagem de critica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na INSS0003.pc_importar_prova_vida --> ' ||
                     SQLERRM || ' SEQ: ' || vr_contareg;

      -- Gerar hora Fim no log
      pc_gera_log_prova_vida(pr_cdcritic => 0
                            ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                            ' - ' || pr_cdprogra ||  ' --> ' ||
                                            'ERRO: FINALIZADO COM ERRO. ' ||
                                            pr_dscritic
                            ,pr_ind_tipo_log_in => vr_ind_tipo_log
                            ,pr_cdprograma_in   => pr_cdprogra
                            ,pr_dserro   => vr_dserro);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_cdcooper => 3
                                   ,pr_compleme => pr_dscritic );
                                                                
	    -- Incluir nome do módulo logado - 22/06/2017 - Chamado 660286
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');

      -- Mandar email para INSS com o resultado do processo
      gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                                ,pr_cdprogra        => pr_cdprogra
                                ,pr_des_destino     => 'inss@ailos.coop.br'
                                ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - ERRO'
                                ,pr_des_corpo       => 'Houve erro no processamento da planilha.</br>' ||
                                                       'Em anexo a PLANILHA e o LOG de processamento.'  ||
                                                       '</br></br>' ||
                                                       'Processado em: ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                                ,pr_des_anexo       => vr_dsdanexo
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

  END pc_importar_prova_vida;
  
  
  
  -- consulta codigo NAI na base CECRED
  PROCEDURE pc_consultar_codigo_nai(pr_nrcpf  IN VARCHAR2               -- Numero CPF
                                   ,pr_retxml OUT NOCOPY XMLType) AS    -- Retorno XML
       
       vr_xml_temp VARCHAR2(32726) := '';
       vr_clob     CLOB;
                                       
       -- cursor de busca do cod NAI                            
       CURSOR cr_busca_nai(vr_nrcpf VARCHAR2) IS
              SELECT nai.nrcpf_titular
                   , nai.cdnai
                   , nai.nrcontrole
                   , nai.dtgeracao
                FROM CECRED.TBINSS_NAI nai
               WHERE nai.nrcpf_titular = vr_nrcpf; 
       
       rw_busca_nai cr_busca_nai%ROWTYPE;                                        
  
   BEGIN

        -- Monta Retorno XML
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
          
        -- Cabecalho do XML
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?><Root>');
      
        -- abre cursor                                              
        OPEN cr_busca_nai(pr_nrcpf); 
           FETCH cr_busca_nai INTO rw_busca_nai;
         
        
        GENE0002.pc_escreve_xml(
                pr_xml => vr_clob, 
                pr_texto_completo => vr_xml_temp,
                pr_texto_novo => '<CPF>' || TRIM(rw_busca_nai.nrcpf_titular) ||'</CPF>' ||
                                 '<CodigoNAI>' || TRIM(rw_busca_nai.cdnai) ||'</CodigoNAI>' ||
                                 '<NumeroControle>' || TRIM(rw_busca_nai.nrcontrole) ||'</NumeroControle>' ||
                                 '<UltimaGeracao>' || to_char(rw_busca_nai.dtgeracao, 'DD/MM/RRRR HH24:MI:SS') ||'</UltimaGeracao>');                   
        
        CLOSE cr_busca_nai; --fecha cursor
        
        -- Encerrar a tag raiz
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Root>'
                               ,pr_fecha_xml      => TRUE);

         -- Atualiza o XML de retorno
         pr_retxml := xmltype(vr_clob);
         
         --dbms_output.put_line(pr_retxml.getStringVal()); --remover depois

         -- Libera a memoria do CLOB
         dbms_lob.close(vr_clob);
         dbms_lob.freetemporary(vr_clob);
                  
  END pc_consultar_codigo_nai;
  
  
  -- Salva codigo NAI na base CECRED
  PROCEDURE pc_salvar_codigo_nai(pr_nrcpf        IN VARCHAR2  -- Cod CPF Cooperado
					                      ,pr_cdcodigo_nai IN VARCHAR2  -- Cod NAI gerado
					                      ,pr_nrcontrole   IN VARCHAR2  -- Numero de Controle
                                ,pr_retxml       OUT NOCOPY XMLType) AS --Retorno XML
       
       vr_xml_temp VARCHAR2(32726) := '';
       vr_erro     VARCHAR2(32726) := NULL; --descricao erro 
       vr_clob     CLOB;
       
                                       
       -- cursor de busca do cod NAI                            
       CURSOR cr_busca_nai(vr_nrcpf VARCHAR2) IS
              SELECT nai.nrcpf_titular
                   , nai.cdnai
                   , nai.nrcontrole
                   , nai.dtgeracao
                FROM CECRED.TBINSS_NAI nai
               WHERE nai.nrcpf_titular = vr_nrcpf;
       rw_busca_nai cr_busca_nai%ROWTYPE;
       
  BEGIN 
                                           
        -- Monta Retorno XML
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
          
        -- Cabecalho do XML
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?><Root>');
                               
        -- abre cursor NAI
        OPEN cr_busca_nai(pr_nrcpf);
             FETCH cr_busca_nai INTO rw_busca_nai;
             
        -- ja tem NAI cadastrado neste CPF     
        IF rw_busca_nai.cdnai IS NOT NULL THEN
           BEGIN 
             UPDATE CECRED.TBINSS_NAI  
                SET cdnai = pr_cdcodigo_nai
                  , nrcontrole = pr_nrcontrole
                  , dtgeracao = sysdate
              WHERE nrcpf_titular = pr_nrcpf;
              EXCEPTION
                   WHEN OTHERS THEN    
                        vr_erro := 'Erro ao atualizar codigo NAI (pc_salvar_codigo_nai): '||SQLERRM;
            END;             
        -- nao tem NAI cadastrado neste CPF
        ELSE
           BEGIN
             INSERT INTO CECRED.TBINSS_NAI 
                       ( nrcpf_titular, cdnai, nrcontrole, dtgeracao ) 
                VALUES ( pr_nrcpf, pr_cdcodigo_nai, pr_nrcontrole, sysdate);
               EXCEPTION
                    WHEN OTHERS THEN    
                         vr_erro := 'Erro ao inserir codigo NAI (pc_salvar_codigo_nai): '||SQLERRM;
            END;              
        END IF;
        
        CLOSE cr_busca_nai; --fecha cursor
        
        -- se nao deu erro, da commit 
        IF vr_erro IS NULL THEN
           COMMIT; --commit transacao
           
           -- abre cursor NAI
           OPEN cr_busca_nai(pr_nrcpf);
                FETCH cr_busca_nai INTO rw_busca_nai;                       
            
           -- escreve tag xml
           GENE0002.pc_escreve_xml(
                   pr_xml => vr_clob, 
                   pr_texto_completo => vr_xml_temp,
                   pr_texto_novo => '<CPF>' || TRIM(rw_busca_nai.nrcpf_titular) ||'</CPF>' ||
                                    '<CodigoNAI>' || TRIM(rw_busca_nai.cdnai) ||'</CodigoNAI>' ||
                                    '<NumeroControle>' || TRIM(rw_busca_nai.nrcontrole) ||'</NumeroControle>' ||
                                    '<UltimaGeracao>' || to_char(rw_busca_nai.dtgeracao, 'DD/MM/RRRR HH24:MI:SS') ||'</UltimaGeracao>' || 
                                    '<MensagemSucesso>Código NAI cadastrado com sucesso.</MensagemSucesso>');
        -- ocorreu erro no PL
        ELSE
           ROLLBACK;
           -- escreve tag de erro
           GENE0002.pc_escreve_xml(
                    pr_xml => vr_clob, 
                    pr_texto_completo => vr_xml_temp,
                    pr_texto_novo => '<MensagemErro>' || TRIM(vr_erro) ||'</MensagemErro>');
        END IF;      
        
        CLOSE cr_busca_nai; --fecha cursor
        
        -- Encerrar a tag raiz
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Root>'
                               ,pr_fecha_xml      => TRUE);

         -- Atualiza o XML de retorno
         pr_retxml := xmltype(vr_clob);
         
         --dbms_output.put_line(pr_retxml.getStringVal()); --remover depois

         -- Libera a memoria do CLOB
         dbms_lob.close(vr_clob);
         dbms_lob.freetemporary(vr_clob);
  
  END pc_salvar_codigo_nai;                                 

  PROCEDURE pc_consultar_beneficios(pr_cdcooper IN INTEGER,                          --> Codigo da Cooperativa
                                    pr_nrdconta IN INTEGER,                          --> Numero da Conta
                                    pr_nrcpfcgc IN NUMBER,                           --> CPF do Cooperado
                                    pr_tab_bene OUT INSS0003.typ_tab_beneficio_inss, --> PL TABLE para listar os beneficios
                                    pr_dscritic OUT VARCHAR2) IS                     --> Mensagem de erro 
    /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consultar_beneficios
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Douglas Quisinski
    Data     : 01/08/2018                             Ultima atualizacao: 
    
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para listar todos os benefícios vinculados com o CPF
    
    Alterações : 
    ------------------------------------------------------------------------------------------------------------------*/
  
    -- Tratamento de erros
    vr_cdcritic INTEGER; -- Código da crítica
    vr_exc_saida EXCEPTION; -- Exceção
  
    vr_idx PLS_INTEGER;
  
    -- Cursor para verificacao do beneficiário do inss
    CURSOR cr_crapdbi(pr_nrcpfcgc IN NUMBER) IS
      SELECT dbi.nrrecben
        FROM crapdbi dbi
       WHERE dbi.nrcpfcgc = pr_nrcpfcgc;
  
    -- Verificar se a conta teve lancamento 1399 nos ultimos 3 meses
    CURSOR cr_craplcm_inss(pr_cdcooper IN crapcop.cdcooper%TYPE,
                           pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                           pr_nrdconta IN tbinss_dcb.nrdconta%TYPE,
                           pr_nrrecben IN tbinss_dcb.nrrecben%TYPE) IS
      SELECT 1
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.cdhistor = 1399
         AND lcm.dtmvtolt <= pr_dtmvtolt
         AND lcm.dtmvtolt >= (pr_dtmvtolt - 90)
            --Buscar cdpesqbb até o primeiro ';' que é o NB(numero do beneficio)
         AND SUBSTR(lcm.cdpesqbb, 1, INSTR(lcm.cdpesqbb, ';') - 1) = pr_nrrecben;
    rw_craplcm_inss cr_craplcm_inss%ROWTYPE;
  
    -- Buscar o orgão pagador
    CURSOR cr_cdorgins(pr_cdcooper IN INTEGER, pr_nrdconta IN INTEGER) IS
      SELECT age.cdorgins, age.cdagenci, ass.cdcooper, ass.nrdconta
        FROM crapage age, crapass ass
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_cdorgins cr_cdorgins%ROWTYPE;
  
    -- Cursor de DATA
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
  BEGIN
  
    -- Incluir nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => 'INSS0003',
                           pr_action => 'INSS0003.pc_consulta_beneficios');
  
    -- Buscar a data do sistema
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      vr_cdcritic := 1;
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_saida;
    ELSE
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    -- Buscar os dados do PA do cooperado, onde recebe o benefício do INSS
    OPEN cr_cdorgins(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_cdorgins
      INTO rw_cdorgins;
    IF cr_cdorgins%NOTFOUND THEN
      vr_cdcritic := 9;
      -- Fechar o cursor
      CLOSE cr_cdorgins;
      RAISE vr_exc_saida;
    ELSE
      -- Fechar o cursor
      CLOSE cr_cdorgins;
    END IF;
  
    -- Limpar a tabela de beneficios 
    pr_tab_bene.DELETE;
  
    -- Percorrer todos os benefícios da conta 
    FOR rw_crapdbi IN cr_crapdbi(pr_nrcpfcgc => pr_nrcpfcgc) LOOP
    
      -- Verificar se a conta possui LCM 1399 nos ultimos 3 meses
      OPEN cr_craplcm_inss(pr_cdcooper => rw_cdorgins.cdcooper,
                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                           pr_nrdconta => rw_cdorgins.nrdconta,
                           pr_nrrecben => rw_crapdbi.nrrecben);
      FETCH cr_craplcm_inss
        INTO rw_craplcm_inss;
    
      -- Verificar se existe lançamento nos ultimos tres meses
      IF cr_craplcm_inss%FOUND THEN
        -- Fechar Cursor
        CLOSE cr_craplcm_inss;
      
        -- carregar os dados para a PL TABLE
        vr_idx := pr_tab_bene.COUNT() + 1;
        pr_tab_bene(vr_idx).cdcooper := rw_cdorgins.cdcooper;
        pr_tab_bene(vr_idx).nrdconta := rw_cdorgins.nrdconta;
        pr_tab_bene(vr_idx).cdagenci := rw_cdorgins.cdagenci;
        pr_tab_bene(vr_idx).nrrecben := rw_crapdbi.nrrecben;
        pr_tab_bene(vr_idx).cdorgins := rw_cdorgins.cdorgins;
      
      ELSE
        -- Fechar Cursor
        CLOSE cr_craplcm_inss;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    
    WHEN OTHERS THEN
      pr_dscritic := 'INS0003.pc_consultar_beneficios - Erro na consulta dos beneficios do cooperado. ERRO: ' ||
                     SQLERRM;
    
  END pc_consultar_beneficios;

  PROCEDURE pc_lista_beneficios(pr_cdcooper IN INTEGER,         --> Codigo da Cooperativa
                                pr_nrdconta IN INTEGER,         --> Numero da Conta
                                pr_nrcpfcgc IN NUMBER,          --> CPF do Cooperado
                                pr_dsbenefi OUT NOCOPY XMLType, --> XML com a lista de beneficios
                                pr_dscritic OUT VARCHAR2) IS    --> Mensagem de erro 
                                
    /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_beneficios
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Douglas Quisinski
    Data     : 01/08/2018                             Ultima atualizacao: 
    
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para listar todos os benefícios vinculados com o CPF
    
    Alterações : 
    ------------------------------------------------------------------------------------------------------------------*/
  
    -- Tratamento de erros
    vr_dscritic VARCHAR(4000); -- Descrição da crítica
    vr_exc_saida EXCEPTION; -- Exceção
  
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);
    vr_dsbenefi CLOB;
  
    vr_tab_bene INSS0003.typ_tab_beneficio_inss;
  
  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => 'INSS0003',
                           pr_action => 'INSS0003.pc_lista_beneficios');
  
    pc_consultar_beneficios(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrcpfcgc => pr_nrcpfcgc,
                            pr_tab_bene => vr_tab_bene,
                            pr_dscritic => vr_dscritic);
  
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsbenefi, TRUE);
    dbms_lob.open(vr_dsbenefi, dbms_lob.lob_readwrite);
  
    -- Cabecalho do XML
    GENE0002.pc_escreve_xml(pr_xml            => vr_dsbenefi,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><BENEFICIOS>');
  
    IF vr_tab_bene.COUNT > 0 THEN
      -- Percorrer todos os benefícios da conta 
      FOR vr_idx IN vr_tab_bene.FIRST .. vr_tab_bene.LAST LOOP
        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_dsbenefi,
                                pr_texto_completo => vr_xml_temp,
                                pr_texto_novo     => '<beneficio>' ||
                                                       '<cdcooper>' || to_char(vr_tab_bene(vr_idx).cdcooper) || '</cdcooper>' ||
                                                       '<nrdconta>' || to_char(vr_tab_bene(vr_idx).nrdconta) || '</nrdconta>' ||
                                                       '<cdagenci>' || to_char(vr_tab_bene(vr_idx).cdagenci) || '</cdagenci>' ||
                                                       '<nrrecben>' || to_char(vr_tab_bene(vr_idx).nrrecben) || '</nrrecben>' ||
                                                       '<cdorgins>' || to_char(vr_tab_bene(vr_idx).cdorgins) || '</cdorgins>' ||
                                                     '</beneficio>');
      END LOOP;
    END IF;
  
    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_dsbenefi,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '</BENEFICIOS>',
                            pr_fecha_xml      => TRUE);
  
    -- Atualiza o XML de retorno
    pr_dsbenefi := xmltype(vr_dsbenefi);
  
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_dsbenefi);
    dbms_lob.freetemporary(vr_dsbenefi);
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'INS0003.pc_lista_beneficios - Erro na consulta dos beneficios do cooperado. ERRO: ' ||
                     SQLERRM;
    
  END pc_lista_beneficios;

  PROCEDURE pc_gera_reg_emp_consignado(pr_cdcooper IN INTEGER  --> Codigo da Cooperativa
                                      ,pr_nrdconta IN INTEGER  --> Numero da Conta
                                      ,pr_cdorgins IN NUMBER   --> Codigo do Orgao Pagador
                                      ,pr_nrbenefi IN NUMBER   --> Numero do Benefício
                                      ,pr_tpoperac IN INTEGER  --> Tipo de operacao: (1 - Historico de emprestimos ativos, 2 - Consulta de margem consignavel)
                                      ,pr_cdcoptfn IN INTEGER  --> Cooperativa do TAA
                                      ,pr_cdagetfn IN INTEGER  --> Agencia do TAA
                                      ,pr_nrterfin IN INTEGER  --> Numero do TAA
                                      ,pr_nmdcanal IN VARCHAR2 --> Nome do Canal
                                      ,pr_nmusuari IN VARCHAR2 --> Nome do Usuário da consulta
                                      ) IS

  /* ..........................................................................
    --
    --  Programa : pc_gera_reg_emp_consignado
    --  Autor    : Douglas Quisinski
    --  Data     : 13/08/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar o registro de LOG para cada consulta que está 
    --               sendo realizada para o INSS
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

  BEGIN
    -- Gerar o log de consulta
    BEGIN
      INSERT INTO CECRED.TBINSS_CONS_EMPR_CONSIGNADO 
        (cdcooper
        ,nrdconta
        ,cdorgins
        ,nrbenefi
        ,dttransa
        ,tpoperac
        ,cdcoptfn
        ,cdagetfn
        ,nrterfin
        ,nmdcanal
        ,nmusuari
        )
      VALUES
        (pr_cdcooper
        ,pr_nrdconta
        ,pr_cdorgins
        ,pr_nrbenefi
        ,SYSDATE
        ,pr_tpoperac
        ,pr_cdcoptfn
        ,pr_cdagetfn
        ,pr_nrterfin
        ,pr_nmdcanal
        ,pr_nmusuari
        );       
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBINSS_CONS_EMPR_CONSIGNADO: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pc_internal_exception(pr_cdcooper => pr_cdcooper
                           ,pr_compleme => vr_dscritic);
    WHEN OTHERS THEN
      pc_internal_exception(pr_cdcooper => pr_cdcooper
                           ,pr_compleme => 'Erro geral rotina INSS003.pc_gera_reg_emp_consignado: ' || SQLERRM);
      
  END pc_gera_reg_emp_consignado;
END INSS0003;
/
